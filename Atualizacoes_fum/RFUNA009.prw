#Include "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RFUNA009
Função para resetar o contrato da funerária
@type function
@version 1.0  
@author Wellington Gonçalves
@since 28/07/2016
/*/
User Function RFUNA009()

	Local aArea 		:= GetArea()
	Local aAreaUF7		:= UF7->(GetArea())
	Local aAreaSA1		:= SA1->(GetArea())
	Local cNumSorte		:= UF2->UF2_NUMSOR
	Local lExcTit		:= .T.
	Local lStatus		:= .T.
	Local lRecorrencia	:= SuperGetMv("MV_XATVREC",.F.,.F.)
	Local lRet			:= .T.
	Local cOrigem		:= "RFUNA009"
	Local cOrigemDesc	:= "Reset de Contrato"
	
	if UF2->( FieldPos("UF2_NUMSO2") ) > 0 .And. !Empty(UF2->UF2_NUMSO2)
		cNumSorte := UF2->UF2_NUMSO2 
	endif					
	

	Do Case

	Case UF2->UF2_STATUS == "P" //Pré-cadastro
		MsgInfo("O Contrato já se encontra como pré-cadastro, operação não permitida.","Atenção")
	Case UF2->UF2_STATUS == "C" //Cancelado
		MsgInfo("O Contrato se encontra Cancelado, operação não permitida.","Atenção")
	Case UF2->UF2_MSFIL <> cFilAnt
		MsgInfo("Nao é permitido resetar contrato fora da filial de inclusao.","Atenção")
	OtherWise

		// verifico se o contrato já foi reajustado
		UF7->(DbSetOrder(2)) // UF7_FILIAL + UF7_CONTRA
		if UF7->(DbSeek(xFilial("UF7") + UF2->UF2_CODIGO))

			MsgInfo("O Contrato já foi reajustado, operação não permitida.","Atenção")

		elseif MsgYesNo("Deseja resetar este contrato?")

			// Inicio o controle de transação
			BEGIN TRANSACTION

				U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
				If lRecorrencia .And. U60->(MsSeek(xFilial("U60") + UF2->UF2_FORPG ))

					// Envia arquivamento do cliente para Vindi
					lRet := U_UVIND20( "F", UF2->UF2_CODIGO, UF2->UF2_CLIENT, UF2->UF2_LOJA, cOrigem, cOrigemDesc )

				endIf

				if lRet

					// gero os títulos
					FWMsgRun(,{|oSay| lExcTit := ResetCTRFun(oSay)},'Aguarde...','Resetando o contrato...')

					// se foi realizada a exclusão dos títulos com sucesso, exclui os títulos da comissão
					if lExcTit

						//Exclui regista da tabela regra x parcela se houver
						UJR->(DbSetOrder(3))
						If UJR->(DbSeek(xFilial("UJR")+UF2->UF2_CODIGO))

							While UJR->(!EOF()) ;
									.AND. UJR->UJR_FILIAL+UJR->UJR_CODIGO == xFilial("UJR")+UF2->UF2_CODIGO

								//Deleto regras gravadas
								If RecLock("UJR",.F.)
									UJR->(DbDelete())
									UJR->(MsUnLock())
								Endif
								UJR->(DbSkip())
							EndDo
						Endif

						if RecLock("UF2",.F.)

							UF2->UF2_STATUS := "P" // Ativo
							UF2->UF2_DTATIV	:= Stod("")
							UF2->UF2_NUMSOR	:= ""
							if UF2->( FieldPos("UF2_NUMSO2") ) > 0 
								UF2->UF2_NUMSO2 := ""
							endif


							UF2->(MsUnlock())

						else
							lStatus := .F.
						endif

					endif

					// se todo o processamento foi concluído com sucesso
					if lExcTit .AND. lStatus

						//libero o numero da sorte utilizado pelo contrato
						UI1->(DbSetOrder(1)) //UI1_FILIAL + UI1_NUMSOR

						if UI1->(DbSeek(xFilial("UI1")+cNumSorte))

							RecLock("UI1",.F.)

							UI1->UI1_CONTRA := ""
							UI1->UI1_UTIL	:= "2"
							UI1->UI1_DTATIV := CTOD("")
							UI1->(MsUnlock())

						endif

						// finalizo o controle de transação
						MsgInfo("Contrato resetado com sucesso!","Atenção!")

					else

						// aborto a transação
						DisarmTransaction()
						BREAK

						if !lExcTit
							MsgInfo("Ocorreu um problema na exclusão dos títulos do Contrato, operação cancelada.","Atenção")
						elseif !lStatus
							MsgInfo("Ocorreu um problema na atualização do status do Contrato, operação cancelada.","Atenção")
						endif

					endif

				else

					// aborto a transação
					DisarmTransaction()
					BREAK

					MsgInfo("Ocorreu um problema na exclusao do Cliente na Plataforma Vindi.","Atenção")

				endIf

			END TRANSACTION

		endif

	EndCase

	RestArea(aAreaSA1)
	RestArea(aAreaUF7)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} ResetCTRFun
Função que faz a exclusão dos títulos do contrato
@type function
@version 1.0
@author Wellington Gonçalves
@since 28/07/2016
@param oSay, object, objeto da barra de processamento
@return logical, retorno se excluiu os titulos no financeiro
/*/
Static Function ResetCTRFun(oSay)

	Local aArea		:= GetArea()
	Local aAreaSE1	:= SE1->(GetArea())
	Local cContrato	:= UF2->UF2_CODIGO
	Local lRet 		:= .T.
	Local aFin040	:= {}

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	SE1->(DbOrderNickName("E1_XCTRFUN")) // E1_FILIAL + E1_XCTRFUN
	if SE1->(DbSeek(xFilial("SE1") + cContrato))

		//valido se o contrato esta em cobranca
		If !U_VldCobranca(SE1->E1_FILIAL,UF2->UF2_CODIGO)
			MsgInfo("O Contrato possui titulos em cobrança, operação cancelada.","Atenção")
			DisarmTransaction()
			lRet := .F.
		else

			While SE1->(!Eof()) .AND. SE1->E1_FILIAL == xFilial("SE1") .AND. SE1->E1_XCTRFUN == cContrato

				aFin040		:= {}
				lMsErroAuto := .F.
				lMsHelpAuto := .T.

				oSay:cCaption := ("Excluindo parcela " + AllTrim(SE1->E1_PARCELA) + "...")
				ProcessMessages()

				If SE1->E1_VALOR == SE1->E1_SALDO // somente título que não teve baixa

					// faço a exclusão do título do bordero
					SEA->(DbSetOrder(1)) // EA_FILIAL + EA_NUMBOR + EA_PREFIXO + EA_NUM + EA_PARCELA + EA_TIPO + EA_FORNECE + EA_LOJA
					If SEA->(DbSeek(xFilial("SEA") + SE1->E1_NUMBOR + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO))

						if RecLock("SEA",.F.)
							SEA->(DbDelete())
							SEA->(MsUnlock())
						endif

						if RecLock("SE1",.F.)

							SE1->E1_SITUACA	:= "0"
							SE1->E1_OCORREN	:= ""
							SE1->E1_NUMBOR	:= ""
							SE1->E1_DATABOR	:= CTOD("  /  /    ")
							SE1->(MsUnLock())

						endif

					Endif

					// faço a exclusão do título a receber
					AAdd(aFin040, {"E1_FILIAL"  , SE1->E1_FILIAL  	, Nil})
					AAdd(aFin040, {"E1_PREFIXO" , SE1->E1_PREFIXO 	, Nil})
					AAdd(aFin040, {"E1_NUM"     , SE1->E1_NUM	   	, Nil})
					AAdd(aFin040, {"E1_PARCELA" , SE1->E1_PARCELA	, Nil})
					AAdd(aFin040, {"E1_TIPO"    , SE1->E1_TIPO  	, Nil})

					MSExecAuto({|x,y| Fina040(x,y)},aFin040,5)

					If lMsErroAuto
						MostraErro()
						lRet := .F.
						Exit
					EndIf

				else
					lRet := .F.
					MsgInfo("Foi realizada uma baixa para o título " + AllTrim(SE1->E1_NUM) + " parcela " + AllTrim(SE1->E1_PARCELA) + ". Não será possível continuar a operação.","Atenção")
					Exit
				endif

				SE1->(DbSkip())

			EndDo
		endif
	endif

	RestArea(aAreaSE1)
	RestArea(aArea)

Return(lRet)
