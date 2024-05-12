#INCLUDE 'PROTHEUS.CH'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} PCPGA040
Ponto de entrada do cadastro de historico de taxa de
locacao de nicho
@type function
@version 
@author g.sampaio
@since 02/03/2020
@return return_type, return_description
/*/
User Function PCPGA042()

	Local aArea			:= GetArea()
	Local aAreaU74		:= U74->(GetArea())
	Local aAreaU75		:= U75->(GetArea())
	Local aParam 		:= {}
	Local cIdPonto		:= ""
	Local cIdModel		:= ""
	Local cClasse		:= ""
	Local cCodigo		:= ""
	Local cContrato		:= ""
	Local lRet 			:= .T.
	Local nVlAdicional	:= 0
	Local oObj			:= Nil
	Local oModelU74		:= Nil
	Local oModelU75		:= Nil
	Local oVirtusFin	:= Nil

	// preencho as variaveis
	aParam		:= PARAMIXB
	oObj		:= aParam[1]
	cIdPonto	:= aParam[2]
	cIdModel	:= IIf( oObj<> NIL, oObj:GetId(), aParam[3] )
	cClasse		:= IIf( oObj<> NIL, oObj:ClassName(), '' )
	oModelU74	:= oObj:GetModel('U74MASTER')
	oModelU75	:= oObj:GetModel('U75DETAIL')

	if cIdPonto == "MODELVLDACTIVE" // ponto de entrada na abertura da tela

		// se a operação for de exclusão
		// devo validar se os títulos da manutenção não foram baixados
		if oObj:GetOperation() == 5 // se for exclusão

			U75->(DbSetOrder(1)) // U75_FILIAL + U75_CODIGO + U75_ITEM
			if U75->(DbSeek(xFilial("U75") + U74->U74_CODIGO))

				// inicio o objeto de funcao financeiras da plataforma virtus
				oVirtusFin := VirtusFin():New()

				// percorro os dados dos titulos gravados no historico
				While U75->(!Eof()) .AND. U75->U75_FILIAL == xFilial("U75") .AND. U75->U75_CODIGO == U74->U74_CODIGO

					SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
					if SE1->(DbSeek(xFilial("SE1") + U75->U75_PREFIX + U75->U75_NUM + U75->U75_PARCEL + U75->U75_TIPO))

						//valido se o titulo ja se encontra em cobranca
						If !oVirtusFin:VldCobranca( "C", xFilial("SE1"), U74->U74_CONTRA, U75->U75_PREFIX, U75->U75_NUM, U75->U75_PARCEL, U75->U75_TIPO )

							Help( ,, 'Atenção',, "O título " + AllTrim(SE1->E1_NUM) + " parcela " + AllTrim(SE1->E1_PARCELA) + " se encontra em processo de cobranca. Não será possível continuar a operação.", 1, 0 )
							lRet := .F.
							Exit

						elseIf SE1->E1_VALOR <> SE1->E1_SALDO // se o título já teve alguma baixa

							lRet := .F.
							Help( ,, "Help - MODELVLDACTIVE",, "Não é possível excluir esta locação pois existem títulos que já foram baixados!", 1, 0 )
							Exit

						endif

					endif

					U75->(DbSkip())

				EndDo

			endif

		endif

	elseIf cIdPonto == "MODELCOMMITTTS" // confirmação do cadastro

		if oObj:GetOperation() == 5 // se for exclusão

			cCodigo 		:= oModelU74:GetValue('U74_CODIGO')
			cContrato 		:= oModelU74:GetValue('U74_CONTRA')
			nVlAdicional	:= oModelU74:GetValue('U74_VLADIC')

			// Inicio o controle de transação
			BEGIN TRANSACTION

				// faco a exclusao dos titulos no financeiro
				FWMsgRun(,{|oSay| lRet := ExcluiTxLocacao( oSay, cCodigo ,oModelU75)},'Aguarde...','Excluindo as taxas de manutenção...')

				// se todo o processamento foi concluído com sucesso
				if !lRet

					// aborto a transação	
					DisarmTransaction()

				endif

			END TRANSACTION

		EndIf

	EndIf
	
	RestArea(aAreaU75)
	RestArea(aAreaU74)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} ExcluiTxLocacao
Função que faz a exclusão dos títulos da manutenção
@type function
@version 
@author g.sampaio
@since 02/03/2020
@param oSay, object, param_description
@param cCodigo, character, param_description
@param oModelU75, object, param_description
@return return_type, return_description
/*/
Static Function ExcluiTxLocacao(oSay,cCodigo,oModelU75)

	Local aArea			:= GetArea()
	Local aAreaSE1		:= SE1->(GetArea())	
	Local aFin040		:= {}
	Local cPrefixo		:= ""
	Local cNumero		:= ""
	Local cParcela		:= ""
	Local cTipo			:= ""
	Local lRet 			:= .T.
	Local nX			:= 0
	Local nLinhaAtual	:= oModelU75:GetLine()
	Local oVirtusFin	:= Nil

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	For nX := 1 To oModelU75:Length()

		// posiciono na linha atual
		oModelU75:Goline(nX)

		cPrefixo	:= oModelU75:GetValue('U75_PREFIX')
		cNumero		:= oModelU75:GetValue('U75_NUM')
		cParcela	:= oModelU75:GetValue('U75_PARCEL')
		cTipo		:= oModelU75:GetValue('U75_TIPO')

		SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
		if SE1->(DbSeek(xFilial("SE1") + cPrefixo + cNumero + cParcela + cTipo))

			aFin040		:= {}
			lMsErroAuto := .F.
			lMsHelpAuto := .T.

			oSay:cCaption := ("Excluindo parcela " + AllTrim(SE1->E1_PARCELA) + "...")
			ProcessMessages()

			If SE1->E1_VALOR == SE1->E1_SALDO // somente título que não teve baixa

				// inicio o objeto de funcao financeiras da plataforma virtus
				oVirtusFin := VirtusFin():New()

				// faço a exclusão do título do bordero
				oVirtusFin:ExcBordTit(SE1->(Recno()))

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

				Help( ,, 'Atenção',, "Foi realizada uma baixa para o título " + AllTrim(SE1->E1_NUM) + " parcela " + AllTrim(SE1->E1_PARCELA) + ". Não será possível continuar a operação.", 1, 0 )
				lRet := .F.
				Exit

			endif

		endif

	Next nX

	// volto para a linha original
	oModelU75:Goline(nLinhaAtual)

	RestArea(aAreaSE1)
	RestArea(aArea)

Return(lRet)
