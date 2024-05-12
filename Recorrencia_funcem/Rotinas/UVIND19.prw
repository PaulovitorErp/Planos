#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} UVIND19
Cancela fatura na plataforma VINDI
@type function
@version 1.0
@author nata.queiroz
@since 16/04/2020
@param cFilCtr, character
@param cPrefix, character
@param cNum, character
@param cParcela, character
@param cTipo, character
@param cFormPag, character
@return lRet, logic
/*/
User Function UVIND19(cFilCtr, cPrefix, cNum, cParcela, cTipo, cFormPag)
	Local lRet := .F.
	Local lFuneraria := SuperGetMV("MV_XFUNE", .F., .F.)
	Local cCodMod := IIF(lFuneraria, "F", "C")
	Local aAreaU65 := U65->( GetArea() )
	Local cStatus := "A"
	Local cChvU65 := cFilCtr + cPrefix + cNum + cParcela + cTipo
	Local oVindi := Nil
	Local cSttsFat := ""
	Local lRemInatVindi	:= SuperGetMV("MV_XRVINAT", .F., .F.)
	Local cErro := ""
	Local cJsonEnvio := ""
	Local cCodRet := ""
	Local cDescRetorno := ""
	Local cDadosRetorno := ""
	Local nIndice := 1
	Local aDadosProc := {}

	Local cOrigem		:= "UVIND19"
	Local cOrigemDesc	:= "Remocao da Recorrencia"

	Default cFormPag := ""

	// Verifica pendências de processamento com a Vindi --//
	lRet := U_PENDVIND(cNum, cCodMod)
	If !lRet
		Return lRet
	EndIf

	//-- Avalia origem das operacoes --//
	If FWIsInCallStack("U_RCPGE003")
		cOrigem := "RCPGE003"
	ElseIf FWIsInCallStack("U_RFUNE024")
		cOrigem := "RFUNE024"
	EndIf

	U65->(DbSetOrder(1)) //-- U65_FILIAL+U65_PREFIX+U65_NUM+U65_PARCEL+U65_TIPO+U65_STATUS
	If U65->( MsSeek(cChvU65 + cStatus) )
		oVindi := IntegraVindi():New()

		cSttsFat := oVindi:ConsultaFatura(cCodMod,;
			@cErro,;
			@cJsonEnvio,;
			@cCodRet,;
			@cDescRetorno,;
			@cDadosRetorno)

		If !(cSttsFat $ "paid|canceled")

			cErro := cJsonEnvio := cCodRet := cDescRetorno := cDadosRetorno := ""
			lRet := oVindi:ExcluiFatura(cCodMod,;
				@cErro,;
				@cJsonEnvio,;
				@cCodRet,;
				@cDescRetorno,;
				@cDadosRetorno,;
				nIndice,;
				cChvU65)

			If lRet
				//-- Atualiza forma de pagamento do titulo --//
				FWMsgRun(,{|oSay| AtuFPTit(cChvU65, cFormPag, @oSay)},'Aguarde...','Atualizando titulo...')

				//-- Inclui historico de exclusão --//
				aDadosProc := {}
				AADD(aDadosProc , "C") // Status
				AADD(aDadosProc , cJsonEnvio) // Json Envio
				AADD(aDadosProc , cDadosRetorno) // Json Retorno
				AADD(aDadosProc , cCodRet) // Codigo do retorno
				AADD(aDadosProc , cDescRetorno) // Descrição do retorno

				oVindi:IncluiTabEnvio(cCodMod, "3", "E", nIndice, cChvU65, aDadosProc, cOrigem, cOrigemDesc)
			Else
				MsgAlert("Não foi possível remover o título " + cChvU65 + " da recorrência.")
			EndIf

		Else
			If cSttsFat == "paid"
				MsgAlert("Título: " + cChvU65 + " - ";
					+ "Fatura código: " + AllTrim(cJsonEnvio) + " já foi paga na plataforma VINDI.")
			ElseIf cSttsFat == "canceled"
				//-- Atualiza forma de pagamento do titulo --//
				FWMsgRun(,{|oSay| AtuFPTit(cChvU65, cFormPag, @oSay)},'Aguarde...','Atualizando titulo...')
				lRet := .T.
			EndIf
		EndIf

		FreeObj(oVindi)
	Else

		// caso a fatura esteja inativa na Vindi, remove a fatura
		If lRemInatVindi
			U65->(DbSetOrder(1)) //-- U65_FILIAL+U65_PREFIX+U65_NUM+U65_PARCEL+U65_TIPO+U65_STATUS
			If U65->( MsSeek(cChvU65 + "I") ) // verifico se está inativo
				If MsgNoYes("A Fatura " + cChvU65 + "  não está ativa na recorrência, deseja alterar a forma de pagamento?","Atenção")
					//-- Atualiza forma de pagamento do titulo --//
					FWMsgRun(,{|oSay| AtuFPTit(cChvU65, cFormPag, @oSay)},'Aguarde...','Atualizando titulo...')
					lRet := .T.
				EndIf
			EndIf
		Else
			lRet := .F.
			MsgInfo("Título " + cChvU65 + " não está em recorrência. ";
				+ "Verifique se as faturas já estão disponíveis na plataforma VINDI.", "UVIND19")
		EndIf

	EndIf

	RestArea(aAreaU65)

Return(lRet)

/*/{Protheus.doc} AtuFPTit
Atualiza forma de pagamento do titulo
@type function
@version 1.0
@author nata.queiroz
@since 16/04/2020
@param cChvSE1, character
@param cFormPag, character
/*/
Static Function AtuFPTit(cChvSE1, cFormPag, oSay)

	Local aArea 		:= GetArea()
	Local aAreaSE1      := SE1->( GetArea() )
	Local aAreaU65      := U65->( GetArea() )
	Local cChvU65       := cChvSE1 + "A"
	Local lFuneraria    := SuperGetMV("MV_XFUNE", .F., .F.)
	Local lRemoveDesc   := SuperGetMV("MV_XREMDES", .F., .T.)
	Local oVirtusFin    := VirtusFin():New()

	If lFuneraria .And. lRemoveDesc

		SE1->(DbSetOrder(1))
		If SE1->(MsSeek(cChvSE1))

			If ValForPg(SE1->E1_XFORPG)

				// removo o desconto do titulo
				If oVirtusFin:RemoveDesconto(SE1->(Recno()), cFormPag)

					U65->(DbSetOrder(1)) //-- U65_FILIAL+U65_PREFIX+U65_NUM+U65_PARCEL+U65_TIPO+U65_STATUS
					If U65->( MsSeek(cChvU65) )
						RecLock("U65", .F.)
						U65->U65_STATUS := "I"
						U65->(MsUnLock())
					EndIf

				EndIf

			Else
				MsgAlert("Forma de pagamento selecionada é inválida, ";
					+ "Informe uma forma de pagamento da recorrência.", "Atenção")
				lRet := .F.
			EndIf

		EndIf
		
	Else

		SE1->(DbSetOrder(1)) //-- E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
		If SE1->( MsSeek(cChvSE1) )

			// marca a excessao na SK1
			oVirtusFin:MarcaExcessaoSK1(SE1->(Recno()))

			RecLock("SE1", .F.)
			SE1->E1_XFORPG := cFormPag
			SE1->( MsUnLock() )
		EndIf

		U65->(DbSetOrder(1)) //-- U65_FILIAL+U65_PREFIX+U65_NUM+U65_PARCEL+U65_TIPO+U65_STATUS
		If U65->( MsSeek(cChvU65) )
			RecLock("U65", .F.)
			U65->U65_STATUS := "I"
			U65->(MsUnLock())
		EndIf

	EndIf

	RestArea(aAreaSE1)
	RestArea(aAreaU65)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} ValForPg
Valida forma de pagamento recorrência
@type function
@version 1.0
@author nata.queiroz
@since 16/04/2020
@param cFormaPgto, character, cFormaPgto
@return logical, lRet
/*/
Static Function ValForPg(cFormaPgto)
	Local lRet := .F.
	Local aAreaU60 := U60->( GetArea() )

	Default cFormaPgto := ""

	U60->(DbSetOrder(2)) //-- U60_FILIAL + U60_FORPG
	if U60->( MsSeek(xFilial("U60") + cFormaPgto) )
		lRet := .T.
	endif

	RestArea(aAreaU60)

Return lRet
