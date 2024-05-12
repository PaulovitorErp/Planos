#include "totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} RCPGE035
Função de cancelamento de contrato

(Antiga funcao CPGA001E)
@type function
@version 1.0
@author g.sampaio
@since 25/06/2020
@param cCodigoCtr, character, param_description
@return return_type, return_description
/*/
User Function RCPGE035(cCodigoCtr)

	Local aArea         := GetArea()
	Local aAreaU00      := U00->( GetArea() )
	Local aAreaUJV      := UJV->( GetArea() )
	Local cCodCan       := Space(6)
	Local cMotCan	    := Space(40)
	Local lContinua	    := .T.
	Local oSay1         := Nil
	Local oSay2         := Nil
	Local oSay3         := Nil
	Local oButton1      := Nil
	Local oButton2      := Nil
	Local oCodCan       := Nil
	Local oMotCan       := Nil
	Local oDlgCan       := Nil

	Default cCodigoCtr  := ""

	// posiciono no cadastro do codigo
	U00->( DbSetOrder(1) )
	if U00->( MsSeek( xFilial("U00")+cCodigoCtr ) )

		Do Case

		Case U00->U00_STATUS == "C" //Cancelado
			MsgInfo("O Contrato já se encontra Cancelado, operação não permitida.","Atenção")
			lContinua := .F.

		Case U00->U00_STATUS == "P" //Pré-cadastro
			MsgInfo("O Contrato se encontra Pré-cadastrado, operação não permitida.","Atenção")
			lContinua := .F.

		Case U00->U00_STATUS == "F" //Finalizado
			MsgInfo("O Contrato se encontra Finalizado, operação não permitida.","Atenção")
			lContinua := .F.

		EndCase

		if lContinua .And. U00->(FieldPos("U00_TPCONT")) > 0

			// contrato de integracao de empresas
			if U00->U00_STATUS == "A" .And. U00->U00_TPCONT == "2"
				MsgInfo("O Contrato de Integração de Empresas, operação não permitida.","Atenção")
				lContinua := .F.
			endIf

		endIf

	else // quando não posicionar no contrato
		lContinua := .F.
	endIf

	If lContinua

		DEFINE MSDIALOG oDlgCan TITLE "Cancelamento de Contrato" From 0,0 TO 140,600 PIXEL

		@ 005,005 SAY oSay1 PROMPT "Motivo" SIZE 030, 007 OF oDlgCan COLORS 0, 16777215 PIXEL
		@ 018,005 MSGET oCodCan VAR cCodCan SIZE 040,007 PIXEL OF oDlgCan PICTURE "@!" Valid(ValMotCan( cCodCan, @cMotCan, @oMotCan )) F3 "U31" HASBUTTON

		@ 005,055 SAY oSay2 PROMPT "Descrição" SIZE 030, 007 OF oDlgCan COLORS 0, 16777215 PIXEL
		@ 018,055 MSGET oMotCan VAR cMotCan SIZE 240,007 PIXEL OF oDlgCan PICTURE "@!" WHEN .F.

		//Linha horizontal
		@ 040, 005 SAY oSay3 PROMPT Repl("_",292) SIZE 292, 007 OF oDlgCan COLORS CLR_GRAY, 16777215 PIXEL

		//Botoes
		@ 051, 200 BUTTON oButton1 PROMPT "Confirmar" SIZE 040, 010 OF oDlgCan ACTION CanContr( cCodCan, cMotCan, @oDlgCan ) PIXEL
		@ 051, 250 BUTTON oButton2 PROMPT "Fechar" SIZE 040, 010 OF oDlgCan ACTION oDlgCan:End() PIXEL

		ACTIVATE MSDIALOG oDlgCan CENTERED
	Endif

	RestArea( aAreaUJV )
	RestArea( aAreaU00 )
	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} CanContr
Cancelamento do contrato
@author totvs
@since 23/08/2019
@param cCodCan,	caracter, Codigo do cancelamento de contrato
@version P12
@return Nil
@history 27/05/2020, g.sampaio, VPDV-473 - Implementado a variavel de log 'cLog' 
- Implementado a tela de Aviso para estorno/exclusao da comissao
@history 29/06/2020, g.sampaio, VPDV-474 - Implementado a classe VirtusFin para 
a exclusao do bordero.
@history 20/08/2020, g.sampaio, VPDV-508 - Implementado o parametro MV_XESTCOM, para
habilitar e desabilitar o estonrno de comissao. 
/*/

/*******************************/
Static Function CanContr(cCodCan, cMotCan, oDlgCan)
/*******************************/

	Local aArea 				:= GetArea()
	Local aAreaUJV				:= UJV->( GetArea() )
	Local aAreaU31				:= U31->( GetArea() )
	Local aRecnoSE1				:= {}
	Local aRecnoU04				:= {}
	Local cQry					:= ""
	Local cLog					:= ""
	Local cMensComis			:= ""
	Local cArqLog				:= ""
	Local lUsaNovaComissao		:= SuperGetMv("ES_NEWCOMI",,.F.)
	Local lContinua 			:= .T.
	Local lRet					:= .T.
	Local lGeraRessarcimento    := SuperGetMv("MV_XRESCTR",,.F.)
	Local lRecorrencia	        := SuperGetMv("MV_XATVREC",.F.,.F.)
	Local lUsaEstornoComissao	:= SuperGetMv("MV_XESTCOM",.F.,.F.)
	Local lAtivaRegra			:= SuperGetMv("MV_XREGCEM",,.F.)
	Local nValorPago			:= 0
	Local nI					:= 1
	Local nOpcA					:= 0
	Local oLogVirtus			:= Nil
	Local oVirtusFin            := Nil
	Local oTaxaManutencao       := Nil
	Local oSay                  := Nil
	Local cOrigem				:= "RCPGE035"
	Local cOrigemDesc			:= "Cancelamento de Contrato"

	Default cCodCan             := ""
	Default cMotCan             := ""

	// chamo a classe do objeto
	oVirtusFin := VirtusFin():New()

	// caso o codigo do cancelamento esteja vazio
	If Empty( cCodCan )
		MsgInfo("Campo Motivo do Cancelmento obrigatório.","Atenção")
		lContinua := .F.
	Endif

	// verifico se devo continuar
	If lContinua

		// posiciono no cadastro de motivos
		U31->( DbSetOrder(1) )
		If U31->( MsSeek( xFilial("U31")+cCodCan ) )

			// verifico se houverram serviços executados
			UJV->( DbSetOrder(2) ) //UJV_FILIAL+UJV_CONTRA
			If UJV->( MsSeek( xFilial("UJV")+U00->U00_CODIGO ) )

				// quando o motivo de cancelamento estiver para cancelamento por inadimplencia
				If U31->U31_CANCIN == "1"

					// pergunto para o usuario se deseja continuar com o cancelamento mesmo com o servico executado
					If !MsgYesNo("Já houve serviço(s) realizado(s) para este Contrato, deseja realizar o cancelamento mesmo assim ?.","Atenção")

						// caso o usuario nao opte por continuar
						lContinua := .F.

					EndIf

				Else // sigo no processo normal

					MsgInfo("Já houve serviço(s) realizado(s) para este Contrato, operação não permitida.","Atenção")
					lContinua := .F.

				EndIf

			endIf

		EndIf

	EndIf

	// verifico se devo continuar
	If lContinua

		If MsgYesNo("O Contrato será cancelado, deseja continuar?")

			If Select("QRYSE1") > 0
				QRYSE1->(DbCloseArea())
			Endif

			cQry := " SELECT SE1.E1_FILIAL, SE1.E1_VALOR, SE1.E1_SALDO, SE1.E1_FATURA, SE1.E1_TIPOLIQ,
			cQry += " SE1.E1_ACRESC, SE1.E1_DECRESC, SE1.R_E_C_N_O_ AS SE1RECNO"
			cQry += " FROM "+RetSqlName("SE1")+" SE1"
			cQry += " WHERE SE1.D_E_L_E_T_ 	<> '*'"
			cQry += " AND SE1.E1_FILIAL 	= '"+xFilial("SE1")+"'"
			cQry += " AND SE1.E1_XCONTRA 	= '"+U00->U00_CODIGO+"'"

			cQry := ChangeQuery(cQry)

			TcQuery cQry NEW Alias "QRYSE1"

			BEGIN TRANSACTION

				If QRYSE1->(!EOF())

					//valido se o contrato possui titulo em cobranca
					If VldCobranca(QRYSE1->E1_FILIAL,U00->U00_CODIGO)

						While QRYSE1->(!EOF())

							If QRYSE1->E1_SALDO > 0 //Título em aberto

								// excluo o titulo do bordero
								oVirtusFin:ExcBordTit( QRYSE1->SE1RECNO )

								//caso seja fatura, sera realizado a baixa por dacao do mesmo e nao a exclusao
								if Alltrim(QRYSE1->E1_FATURA) == 'NOTFAT' .Or. QRYSE1->E1_TIPOLIQ == "LIQ" // baixo a liquidacao tambem

									lRet := BxFatura(QRYSE1->SE1RECNO)

								else

									Aadd( aRecnoSE1, QRYSE1->SE1RECNO )

								endif

								//Não considero baixas feitas por faturas
							ElseIf Empty(QRYSE1->E1_TIPOLIQ) .Or. Empty(QRYSE1->E1_FATURA) .Or. Alltrim(QRYSE1->E1_FATURA) == 'NOTFAT'
								//Somo os valores pagos para ressarcimento, nao considero juros e multa
								nValorPago	+= (QRYSE1->E1_VALOR + QRYSE1->E1_ACRESC) - QRYSE1->E1_DECRESC
							Endif

							QRYSE1->(DbSkip())
						EndDo
					Else
						MsgInfo("O Contrato possui titulos em cobrança, operação cancelada.","Atenção")
						DisarmTransaction()
						lRet := .F.
					Endif
				Endif

				//Exclui endereçamento prévio
				If lRet

					DbSelectArea("U04")
					U04->(DbSetOrder(1)) //U04_FILIAL+U04_CODIGO+U04_ITEM

					If Select("QRYU04") > 0
						QRYU04->(DbCloseArea())
					Endif

					cQry := "SELECT U04.U04_ITEM"
					cQry += " FROM "+RetSqlName("U04")+" U04"
					cQry += " WHERE U04.D_E_L_E_T_ 	<> '*'"
					cQry += " AND U04.U04_FILIAL 	= '"+xFilial("U04")+"'"
					cQry += " AND U04.U04_CODIGO 	= '"+U00->U00_CODIGO+"'"

					cQry := ChangeQuery(cQry)
					TcQuery cQry NEW Alias "QRYU04"

					//If U04->(DbSeek(xFilial("U04")+U00->U00_CODIGO))
					If QRYU04->(!EOF())

						While QRYU04->(!EOF()) //.And. U04->U04_FILIAL == xFilial("U04") .And. U04->U04_CODIGO == U00->U00_CODIGO

							// posicionamento no endereco
							If U04->(MsSeek(xFilial("U04")+U00->U00_CODIGO+QRYU04->U04_ITEM))

								// pego os recnos dos enderecos
								Aadd( aRecnoU04, U04->( Recno() ) )

								// verifico se tem enderecamento utilizado
								If !Empty( U04->U04_DTUTIL )

									// mensagem para o usuario
									MsgAlert( " O contrato possui endereço utilizado, não será possível realizar o cancelamento" )
									lRet := .F.
									Exit

								EndIf

							Endif

							QRYU04->(DbSkip())
						EndDo
					Endif
				Endif

				// caso estiver tudo certo faco o cancelamento do contrato - deleto os titulos da SE1
				If lRet

					// Executa destacado e centralizado
					FWMsgRun(, {|oSay| lRet := ProcExclusao( aRecnoSE1, @oSay )}, "Aguarde", "Realizando exclusão dos Títulos a Receber...")

				EndIf

				// caso estiver tudo certo faco o cancelamento do contrato - deleto o enderecamento U04
				If lRet

					// percorro os recnos da U04
					For nI := 1 To Len( aRecnoU04 )

						// se devo continuar
						If lRet

							U04->( DbGoTo( aRecnoU04[nI] ) )

							If U04->( RecLock("U04",.F.) )
								U04->(DbDelete())
								U04->(MsUnlock())
							Else
								U04->( DisarmTransaction() )
								lRet := .F.
								Exit
							EndIf

						EndIf

					Next nI

				EndIf

				// verifico se nao esta utilizando a nova comissao
				If lRet .And. !lUsaNovaComissao

					// executo a rotina de exclusao de comissao antigo
					MsgRun("Realizando exclusão dos Títulos de Comissão...","Aguarde",{|| lRet := U_RCPGB011(U00->U00_CODIGO)})

				ElseIf lRet .And. lUsaNovaComissao // verifico se estou usando a nova comissao

					// verifico se utilizo o estorno de comissao
					If lUsaEstornoComissao

						// estorno de comissao de contrato cemiterio
						lRet := U_UTILE15C( U00->U00_CODIGO, "C", @cLog )

						// verifico se deu tudo certo com o estorno da comissao
						If lRet
							cMensComis := "Foi gerado estorno ou exclusão da comissão do vendedor!"
						Else // caso tenha dado errado
							cMensComis := "Não possível realizar o estorno ou exclusão da comissão do Vendedor, favor anliasar o 'Log'"
						EndIf

						// aviso de comissao
						nOpcA := Aviso("Exclusão/Estorno de Comissão", cMensComis, { "Log","Fechar"}, 2)

						// gero o log do estorno
						If nOpcA == 1

							// crio o objeto para a log
							oLogVirtus := LogVirtus():New()

							// gero o arquivo de log
							cArqLog := oLogVirtus:Crialog( cLog )

							// verifico se tem arquivo de log
							If !Empty(cArqLog)

								// abro o arquivo de log
								ShellExecute("open",cArqLog,"",cArqLog, 1 )

							EndIf

						EndIf

					EndIf

				EndIf

				If lRet .And. lGeraRessarcimento .And. nValorPago > 0 .And. MsgYesNo("Deseja Gerar Ressarcimento para o cliente?")
					MsgRun("Verificando ressarcimento...","Aguarde",{|| lRet := VerRess(U00->U00_CODIGO, U00->U00_PLANO, U00->U00_CGC, U00->U00_VALOR, nValorPago, U00->U00_DTATIV, U00->U00_INDICE)})
				Endif

				// verifico se a recorrencia esta habilitada
				if lRecorrencia

					//realizo o arquivamento do cliente na Vindi, caso forma de pagamento seja recorrencia
					U_UVIND20( "C", U00->U00_CODIGO , U00->U00_CLIENT , U00->U00_LOJA, cOrigem, cOrigemDesc )

				endIf

				// verufuci
				if lRet .And. lAtivaRegra .And. !Empty(U00->U00_REGRA)

					// chamo a classe de taxa de manutencao
					oTaxaManutencao := RegraTaxaManutencao():New(U00->U00_REGRA)

					If Self:lTemRegra

						// verifico se tem taxa de manutencao
						lRet := oTaxaManutencao:ExcluiManutencao(Stod(""), Stod(""), U00->U00_CODIGO, U00->U00_CODIGO)

					EndIf

				endIf

				If lRet
					RecLock("U00",.F.)
					U00->U00_DTCANC := dDataBase
					U00->U00_CODCAN := cCodCan
					U00->U00_MOTCAN := cMotCan
					U00->U00_USRCAN := cUserName
					U00->U00_STATUS := "C" //Cancelado
					U00->(MsUnlock())
				Endif

				If !lRet
					DisarmTransaction()
					BREAK
				EndIf

			END TRANSACTION

			If lRet
				MsgInfo("Contrato cancelado.","Atenção")
			Endif

			oDlgCan:End()
		Endif
	Endif

	If Select("QRYU04") > 0
		QRYU04->(DbCloseArea())
	Endif

	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	Endif

	RestArea( aAreaU31 )
	RestArea( aAreaUJV )
	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} VerRess
funcao para gerar o ressarcimento
@type function
@version 1.0
@author g.sampaio
@since 15/06/2021
@param cContrato, character, param_description
@param cPlano, character, param_description
@param cCgc, character, param_description
@param nVlr, numeric, param_description
@param nValorPago, numeric, param_description
@param dDtAtiv, date, param_description
@param cIndice, character, param_description
@return return_type, return_description
/*/
Static Function VerRess(cContrato,cPlano,cCgc,nVlr,nValorPago,dDtAtiv,cIndice)

	Local lRet					:= .T.
	Local lGeraRessarcimento	:= .F.
	Local nAux					:= 0
	Local cCond					:= ""
	Local nVlrAtual				:= 0

	U05->(DbSetOrder(1)) //U05_FILIAL+U05_CODIGO

	If nValorPago > 0

		If U05->(DbSeek(xFilial("U05")+cPlano))

			If U05->U05_MULTAR > 0

				If U_RCPGE037(dDtAtiv,cIndice)

					nVlrAtual := U_RCPGE036( nVlr, cIndice, dDtAtiv )
					nAux := nVlrAtual * (U05->U05_MULTAR / 100)

					If nValorPago >= nAux //Possui ressarcimento
						lGeraRessarcimento := .T.
					else
						MsgAlert("Não será possível gerar o ressarcimento, pois o valor pago R$ " + AllTrim(Transform(nValorPago, "@E 999,999,999.99"));
							+ " é inferior ao percentual de "+cValToChar(U05->U05_MULTAR)+"% do valor do contrato de R$ " + AllTrim(Transform(nVlr, "@E 999,999,999.99"));
							+ " determinado para ressarcimento, que seria R$ " + AllTrim(Transform(nAux, "@E 999,999,999.99")) +"!")
					Endif
				Else
					If MsgYesNo("Foi verificado que não foram cadastrados todos os índices mensais, desde ativação do Contrato até a data atual, deseja continuar?")

						nVlrAtual := U_RCPGE036(nVlr,cIndice,dDtAtiv)
						nAux := nVlrAtual * (U05->U05_MULTAR / 100)

						If nValorPago >= nAux //Possui ressarcimento
							lGeraRessarcimento := .T.
						else
							MsgAlert("Não será possível gerar o ressarcimento, pois o valor pago R$ " + AllTrim(Transform(nValorPago, "@E 999,999,999.99"));
								+ " é inferior ao percentual de "+cValToChar(U05->U05_MULTAR)+"% do valor do contrato de R$ " + AllTrim(Transform(nVlr, "@E 999,999,999.99"));
								+ " determinado para ressarcimento, que seria R$ " + AllTrim(Transform(nAux, "@E 999,999,999.99")) +"!")
						Endif
					Else
						MsgInfo("Operação cancelada.","Atenção")
						lRet := .F.
						DisarmTransaction()
					Endif
				Endif

				if lRet .And. lGeraRessarcimento
					SA2->(DbSetOrder(3)) //A2_FILIAL+A2_CGC
					If !SA2->(DbSeek(xFilial("SA2")+cCgc))
						if MsgYesNo("Fornecedor com o CGC <"+AllTrim(cCgc)+"> não cadastrado, deseja cadastrar?.","Atenção")
							MsAguarde( {|| lRet := IncFornecedor(cCgc)}, "Aguarde", "Incluindo fornecedor...", .F. )
						else
							lRet := .F.
						endIf
					Endif

					if lRet
						SA2->(DbSetOrder(3)) //A2_FILIAL+A2_CGC
						If SA2->(DbSeek(xFilial("SA2")+cCgc))
							cCond := InfCond()
							MsgRun("Realizando inclusão de Título a Pagar...","Aguarde",{|| lRet := IncTitRess(cContrato, SA2->A2_COD, SA2->A2_LOJA, nValorPago - nAux, cCond)})
						endIf
					endIf

					if !lRet
						DisarmTransaction()
						MsgAlert("Operação Cancelada", "Atenção")
					endIf

				endIf

			Endif
		Endif
	Endif

	If Select("QRYSE5") > 0
		QRYSE5->(DbCloseArea())
	Endif

Return(lRet)

/******************************/
Static Function ExcTit(nRecSE1,oSay)
/******************************/

	Local lRet 			:= .T.
	Local aFin040		:= {}
	Local aArea			:= GetArea()
	Local aAreaSE1		:= SE1->( GetArea() )

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	DbSelectArea("SE1")
	SE1->(DbGoTo(nRecSE1))

	// atualizo a caption do processamento
	oSay:cCaption := ("Excluindo Parcela: " + SE1->E1_PARCELA + "")

	AAdd(aFin040, {"E1_FILIAL"  , SE1->E1_FILIAL  	,Nil})
	AAdd(aFin040, {"E1_PREFIXO" , SE1->E1_PREFIXO 	,Nil})
	AAdd(aFin040, {"E1_NUM"     , SE1->E1_NUM	   	,Nil})
	AAdd(aFin040, {"E1_PARCELA" , SE1->E1_PARCELA	,Nil})
	AAdd(aFin040, {"E1_TIPO"    , SE1->E1_TIPO  	,Nil})

	MSExecAuto({|x,y| Fina040(x,y)},aFin040,5)

	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
		lRet := .F.
	EndIf

	RestArea(aArea)
	RestArea(aAreaSE1)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  BxFatura Raphael Martiins Garcia			ºData³ 04/11/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para realizar a baixa de Fatura por DACAO para o	  º±±
±±ºDesc.     ³ cancelamento dos contratos								  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cemiterio	                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function BxFatura(nRecnoSE1)

	Local aArea 	:= GetArea()
	Local aAreaSE1	:= SE1->(GetArea())
	Local aBaixa	:= {}
	Local lRet		:= .T.

	Private lMsErroAuto := .F.

	DbSelectArea("SE1")
	SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(DbGoTo(nRecnoSE1))

	aBaixa := {;
		{"E1_PREFIXO"   ,SE1->E1_PREFIXO										,Nil},;
		{"E1_NUM"       ,SE1->E1_NUM											,Nil},;
		{"E1_PARCELA"   ,SE1->E1_PARCELA										,Nil},;
		{"E1_TIPO"      ,SE1->E1_TIPO											,Nil},;
		{"E1_CLIENTE" 	,SE1->E1_CLIENTE										,Nil},;
		{"E1_LOJA" 		,SE1->E1_LOJA											,Nil},;
		{"AUTMOTBX"     ,"DAC"													,Nil},;
		{"AUTDTBAIXA"   ,dDatabase												,Nil},;
		{"AUTDTCREDITO" ,dDatabase												,Nil},;
		{"AUTHIST"      ,"BAIXA POR CANCELAMENTO CEM"							,Nil},;
		{"AUTJUROS"     ,0      												,Nil,.T.},;
		{"AUTMULTA"     ,0      												,Nil,.T.},;
		{"AUTVALREC"    ,SE1->E1_SALDO	+ SE1->E1_SDACRES - SE1->E1_SDDECRE		,Nil}}

	MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3) //Baixa conta a receber

	If lMsErroAuto

		MostraErro()

		lRet := .F.
		DisarmTransaction()

	endif

	RestArea(aArea)
	RestArea(aAreaSE1)

Return(lRet)

/*/{Protheus.doc} ValMotCan
valido o motivo de cancelamento
@author totvs
@since 23/08/2019
@param cCodCan,	caracter, condigo do cancelamento
@version P12
@return Nil
/*/

/**********************************/
Static Function ValMotCan(cCodCan, cMotCan, oMotCan)
/**********************************/

	Local aArea			:= GetArea()
	Local aAreaU31		:= U31->( GetArea() )
	Local lRet 			:= .T.

	Default cCodCan	    := ""
	Default cMotCan     := ""
	Default oMotCan     := Nil

	// verifico se o código do cancelamento está preenchido
	If !Empty(cCodCan)

		DbSelectArea("U31")
		U31->(DbSetOrder(1)) //U31_FILIAL+U31_CODIGO

		If U31->(DbSeek(xFilial("U31")+cCodCan))
			cMotCan := U31->U31_DESCRI
		Else
			MsgInfo("Motivo de Cancelamento inválido.","Atenção")
			cMotCan := Space(40)
			lRet := .F.
		Endif
	Else
		cMotCan := Space(40)
	Endif

	oMotCan:Refresh()

	RestArea( aAreaU31 )
	RestArea( aArea )

Return(lRet)

/*/{Protheus.doc} ProcExclusao
processamento de exclusao
@type function
@version 
@author g.sampaio
@since 29/06/2020
@param aRecnoSE1, array, param_description
@return return_type, return_description
/*/
Static Function ProcExclusao( aRecnoSE1, oSay)

	Local nI            := 0
	Local lRet          := .T.

	Default aRecnoSE1   := {}

	// percorro os titulos da SE1
	For nI := 1 To Len( aRecnoSE1 )

		// verifico se continuo
		If lRet

			lRet := ExcTit( aRecnoSE1[nI], @oSay )

		EndIf

		// verifico se deu algum erro
		If !lRet

			DisarmTransaction()

			Exit

		Endif

	Next nI

Return(lRet)

/*/{Protheus.doc} VldCobranca
FUNCAO PARA VALIDAR SE O TITULO ESTA EM COBRANCA
@type function
@version 1.0
@author g.sampaio
@since 29/06/2020
@param cFiltTit, character, param_description
@param cContrato, character, param_description
@return return_type, return_description
/*/
Static Function VldCobranca(cFiltTit,cContrato)

	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local aAreaSE1	:= SE1->( GetArea() )
	Local aAreaSK1	:= SK1->( GetArea() )
	Local cQry 		:= ""

	///////////////////////////////////////////////////////////////
	///// CONSULTO SE O CONTRATO POSSUI TITULOS EM COBRANCA	//////
	//////////////////////////////////////////////////////////////

	cQry 	:= " SELECT "
	cQry 	+= " K1_FILIAL FILIAL, "
	cQry 	+= " K1_PREFIXO PREFIXO, "
	cQry 	+= " K1_NUM NUMERO, "
	cQry 	+= " K1_PARCELA PARCELA, "
	cQry 	+= " K1_TIPO TIPO, "
	cQry 	+= " K1_FILORIG FILORIG "
	cQry	+= " FROM "
	cQry	+= + RetSQLName("SK1") + " COBRANCA
	cQry 	+= " INNER JOIN "
	cQry 	+= + RetSQLName("SE1") + " TITULO
	cQry 	+= " ON "
	cQry 	+= " COBRANCA.K1_PREFIXO = TITULO.E1_PREFIXO "
	cQry	+= " AND COBRANCA.K1_NUM 	= TITULO.E1_NUM "
	cQry	+= " AND COBRANCA.K1_PARCELA = TITULO.E1_PARCELA "
	cQry	+= " AND TITULO.E1_XCONTRA 	= '" + cContrato + "' "
	cQry	+= " AND TITULO.E1_FILIAL 	= '" + cFiltTit + "' "
	cQry	+= " AND TITULO.D_E_L_E_T_ 	= ' ' "
	cQry	+= " WHERE "
	cQry	+= "	COBRANCA.D_E_L_E_T_ = ' '"
	cQry	+= " 	AND COBRANCA.K1_FILORIG = '" + cFiltTit + "' "
	cQry 	+= " 	AND COBRANCA.K1_OPERAD	<> 'XXXXXX' " //XXXXXX Titulo marcado como excecao na cobranca

	If Select("QRYCOB") > 0
		QRYCOB->(DbCloseArea())
	Endif

	cQry := ChangeQuery(cQry)
	TcQuery cQry NEW Alias "QRYCOB"

	QRYCOB->( DbGotop() )

	//valido se possui cobranca para o contrato
	if QRYCOB->(!Eof())

		if MsgYesNo("O Contrato selecionado possui titulo(s) em cobrança.deseja continuar a operação? "+;
				Chr(13) + Chr(10) + " Os Titulos do contrato serão marcado como exceção no módulo de CallCenter.")

			SK1->(DbSetOrder(1)) //K1_FILIAL+K1_PREFIXO+K1_NUM+K1_PARCELA+K1_TIPO+K1_FILORIG

			While QRYCOB->(!Eof())

				//marco o titulo como excecao de cobranca, assim o mesmo estara apto para exclusao
				if SK1->(DbSeek(QRYCOB->FILIAL+QRYCOB->PREFIXO+QRYCOB->NUMERO+QRYCOB->PARCELA+QRYCOB->TIPO+QRYCOB->FILORIG))

					RecLock("SK1",.F.)
					SK1->K1_OPERAD := 'XXXXXX'
					SK1->(MsUnlock())

				endif

				QRYCOB->(DbSkip())

			EndDo

		else

			lRet := .F.

		endif

	endif

	RestArea(aArea)
	RestArea(aAreaSE1)
	RestArea(aAreaSK1)

Return( lRet )

/*/{Protheus.doc} InfCond
Funcao para se informar a condicao de pagamento
@type function
@version 1.0 
@author gsamp
@since 17/06/2021
@return character, retorna o codigo da condicao de pagamento
/*/
Static Function InfCond()

	Local oSay1 	:= Nil
	Local oSay2		:= Nil
	Local oButton1	:= Nil
	Local oCond		:= Nil
	Local oDlgCond	:= Nil
	Local cCond 	:= Space(3)

	DEFINE MSDIALOG oDlgCond TITLE "Ressarcicmento" From 0,0 TO 140,300 PIXEL

	@ 005,005 SAY oSay1 PROMPT "Cond. pagamento" SIZE 070, 007 OF oDlgCond COLORS 0, 16777215 PIXEL
	@ 018,005 MSGET oCond VAR cCond SIZE 060,007 PIXEL OF oDlgCond HASBUTTON VALID(IIF(Empty(cCond) .Or. (!Empty(cCond) .And. ExistCpo("SE4",cCond)),.T.,.F.)) PICTURE "@!" F3 "SE4"

	//Linha horizontal
	@ 040, 005 SAY oSay2 PROMPT Repl("_",140) SIZE 140, 007 OF oDlgCond COLORS CLR_GRAY, 16777215 PIXEL

	//Botoes
	@ 051, 100 BUTTON oButton1 PROMPT "Ok" SIZE 040, 010 OF oDlgCond ACTION ConfCond(cCond, @oDlgCond) PIXEL

	ACTIVATE MSDIALOG oDlgCond CENTERED

Return(cCond)

/*/{Protheus.doc} ConfCond
funcao para confirmar a condicao de pagamento
@type functionadmin
@version 1.0
@author gsamp
@since 17/06/2021
@param cCond, character, codigo da condicao de pagamento
/*/
Static Function ConfCond(cCond, oDlgCond)

	Default cCond 		:= ""
	Default oDlgCond	:= Nil

	If Empty(cCond)
		MsgInfo("Campo <Cond. pagamento> obrigatório.","Atenção")
	Else
		oDlgCond:End()
	Endif

Return(Nil)

/*/{Protheus.doc} IncFornecedor
Função para cadastrar o cliente como fornecedor
@type function
@version 1.0  
@author gsamp
@since 17/06/2021
@param cCgc, character, CGC(CPF/CNPJ) do cliente
@return logical, retorna se a 
/*/
Static Function IncFornecedor(cCgc)

	Local aArea			:= GetArea()
	Local aAreaSA1		:= SA1->(GetArea())
	Local aAuxPE		:= {}
	Local aFornecedor	:= {}
	Local cCodigo 		:= ""
	Local cSX3Aux		:= ""
	Local lRetorno		:= .F.
	Local nI			:= 0

	Private lMsErroAuto	:= .F.

	//=================================================
	// verifico se existem campos obrigatorios na SA2
	//================================================

	// posiociono no cadastro de clientes pelo CPF/CNPJ
	SA1->(DbSetOrder(3))
	if SA1->(MsSeek(xFilial("SA1")+cCgc))

		//=============================================
		// pego o incializador padrao do campo A2_COD
		//=============================================

		cSX3Aux := GetSx3Cache("A2_COD","X3_RELACAO")

		if !Empty(cSX3Aux)
			cCodigo := &(GetSx3Cache("A2_COD","X3_RELACAO"))
		else
			cCodigo := GETSXENUM("SA2","A2_COD")
		endIf

		cLoja := StrZero(1,TamSX3("A2_LOJA")[1])

		aAdd(aFornecedor,{"A2_COD"    	, AllTrim(cCodigo)                      ,Nil})
		aAdd(aFornecedor,{"A2_LOJA"   	, AllTrim(cLoja)						,Nil})
		aAdd(aFornecedor,{"A2_NOME"   	, AllTrim(SA1->A1_NOME)                	,Nil})
		aAdd(aFornecedor,{"A2_NREDUZ" 	, AllTrim(SA1->A1_NREDUZ)              	,Nil})
		aAdd(aFornecedor,{"A2_END"    	, AllTrim(SA1->A1_END)					,Nil})
		aAdd(aFornecedor,{"A2_BAIRRO" 	, AllTrim(SA1->A1_BAIRRO)			 	,Nil})
		aAdd(aFornecedor,{"A2_EST"    	, AllTrim(SA1->A1_EST)                 	,Nil})
		aAdd(aFornecedor,{"A2_COD_MUN"	, AllTrim(SA1->A1_COD_MUN)	 			,Nil})
		aAdd(aFornecedor,{"A2_MUN"    	, AllTrim(SA1->A1_MUN)                 	,Nil})
		aAdd(aFornecedor,{"A2_CEP"    	, AllTrim(SA1->A1_CEP)					,Nil})
		aAdd(aFornecedor,{"A2_TIPO"   	, AllTrim(SA1->A1_PESSOA)				,Nil})
		aAdd(aFornecedor,{"A2_CGC"    	, AllTrim(SA1->A1_CGC)					,Nil})
		aAdd(aFornecedor,{"A2_TEL"    	, AllTrim(SA1->A1_TEL)					,Nil})
		aAdd(aFornecedor,{"A2_INSCR"  	, AllTrim(SA1->A1_INSCR)				,Nil})
		aAdd(aFornecedor,{"A2_PAIS"   	, "105"                                 ,Nil})
		aAdd(aFornecedor,{"A2_EMAIL"  	, AllTrim(SA1->A1_EMAIL)				,Nil})
		aAdd(aFornecedor,{"A2_CODPAIS"	, "01058"                               ,Nil})
		aAdd(aFornecedor,{"A2_TPESSOA"  , IIF(SA1->A1_PESSOA=="F", "PF", "OS")	,Nil})

		//-- Ponto Entrada para adicionar campos de usuario ou obrigatorops para incluir na SA2 --//
		If ExistBlock("PCPG35A2")
			aAuxPE := ExecBlock("PCPG35A2", .F., .F.)
			If Len(aAuxPE) > 0
				For nI := 1 to Len(aAuxPE)
					aAdd(aFornecedor,{aAuxPE[nI, 1], aAuxPE[nI, 2], aAuxPE[nI, 3]})
				Next nI
			EndIf
		EndIf

		BEGIN TRANSACTION

			SA2->(MSExecAuto({|x,y| Mata020(x,y)},aFornecedor,3)) //Inclusao

			if lMsErroAuto
				MostraErro()
				SA2->(DisarmTransaction())
			else
				lRetorno	:= .T.
				SA2->(ConfirmSX8())
				MsgInfo("Fornecedor incluido com Sucesso!")
			endIf

		END TRANSACTION

	endIf

	RestArea(aAreaSA1)
	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} IncTitRess
Função para incluir o titulo de ressarcimento
no Contas a Pagar(SE2)
@type function
@version 1.0
@author gsamp
@since 17/06/2021
@param cContrato, character, codigo do contrato
@param cFornece, character, codigo do fornecedor
@param cLoja, character, codigo da loja
@param nVlr, numeric, valor do ressarcimento
@param cCond, character, condicao de pagamento para gerar o titulo a pagar
@return logical, retorna se incluiu o titulo de ressar
cimento
/*/
Static Function IncTitRess(cContrato,cFornece,cLoja,nVlr,cCond)

	Local aFin050 		:= {}
	Local aParcelas		:= Condicao(nVlr,cCond,0.00,dDatabase,0.00,{},,0)
	Local cPref 		:= SuperGetMv("MV_XPREFRE",.F.,"CTR")
	Local cTipo			:= SuperGetMv("MV_XTIPORE",.F.,"RSC")
	Local cNat			:= SuperGetMv("MV_XNATRES",.F.,"10101") // Natureza de ressarcimento
	Local lRetorno		:= .T.
	Local nI			:= 0

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	For nI := 1 To Len(aParcelas)

		if lRetorno

			AAdd(aFin050, {"E2_FILIAL"	, xFilial("SE2")				,Nil } )
			AAdd(aFin050, {"E2_PREFIXO"	, cPref							,Nil } )
			AAdd(aFin050, {"E2_NUM"		, cContrato						,Nil } )
			AAdd(aFin050, {"E2_TIPO"	, cTipo							,Nil } )
			AAdd(aFin050, {"E2_NATUREZ"	, cNat							,Nil } )
			AAdd(aFin050, {"E2_FORNECE"	, cFornece						,Nil } )
			AAdd(aFin050, {"E2_LOJA"	, cLoja							,Nil } )
			AAdd(aFin050, {"E2_EMISSAO"	, dDataBase						,Nil } )
			AAdd(aFin050, {"E2_VENCTO"	, aParcelas[nI][1]		   		,Nil } )
			AAdd(aFin050, {"E2_VENCREA"	, DataValida(aParcelas[nI][1])	,Nil } )
			AAdd(aFin050, {"E2_VALOR"	, aParcelas[nI][2]				,Nil } )
			AAdd(aFin050, {"E2_XCONTRA"	, cContrato			 			,Nil } )

			MSExecAuto({|x,y| FINA050(x,y)},aFin050,3)

			If lMsErroAuto
				MostraErro()
				DisarmTransaction()
				lRetorno := .F.
			EndIf

		endIf

	Next nI

Return(lRetorno)
