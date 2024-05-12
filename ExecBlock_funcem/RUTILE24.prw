#include "totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} RUTILE24
fonte para executar as alteracoes no titulo do contas a receber
de campos que fazem parte do Virtus ERP no momento de gravar
a liquidacao a receber FINA460
@type function
@version 1.0
@author g.sampaio
@since 29/05/2020
@history 27/07/2021, nata.queiroz, adicionado rotina consulta clientes
@param oModelFO2, object, modelo de dados da tabela oModelFO2
/*/
User Function RUTILE24( oModelFO2, oModelFO0, oModelFO1 )

	Local aArea         := GetArea()
	Local aAuxRateio    := {}
	Local aRateio       := {}
	Local cChaveTit		:= ""
	Local cChaveFK7		:= ""
	Local lCemiterio    := SuperGetMV("MV_XCEMI",,.F.)
	Local lFuneraria    := SuperGetMV("MV_XFUNE",,.F.)
	Local lAtivMultNat	:= SuperGetMV("MV_XMULNPA",.F.,.F.)	// rateio de multiplas naturezas virtus
	Local lMulNatR		:= SuperGetMV("MV_MULNATR",.F.,.F.)	// rateio de multiplas naturezas padrão
	Local nTotRateio	:= 0
	Local nX            := 0
	Local nI			:= 0

	Default oModelFO2   := Nil
	Default oModelFO0   := Nil
	Default oModelFO1   := Nil

	//Se foi executado pela rotina de contrato de funeraria ou consulta clientes
	If lFuneraria .And. (IsInCallStack("U_RFUNA002") .Or. IsInCallStack("U_RUTIL023"))

		//Gravo numero do contrato nos titulos gerados
		For nX := 1 to oModelFO2:Length()

			// posiciono
			oModelFO2:GoLine(nX)
			If !oModelFO2:IsDeleted()

				//Posiciono no titulo que esta sendo feito a fatura e guardo o RECNO
				SE1->(DbSetOrder(1))
				If SE1->(MsSeek(xFilial("SE1")+oModelFO2:GetValue("FO2_PREFIX")+oModelFO2:GetValue("FO2_NUM")+oModelFO2:GetValue("FO2_PARCEL")+ oModelFO2:GetValue("FO2_TIPO")))

					RecLock("SE1",.F.)
					SE1->E1_XFORPG  := oModelFO2:GetValue("FO2_XFORPG")
					SE1->E1_XCTRFUN := UF2->UF2_CODIGO
					SE1->(MsUnLock())

				Endif
			endif

		Next nX

	// verifico se foi executado da rotina de contrato de cemiterio ou consulta clientes
	ElseIf lCemiterio .And. (IsInCallStack("U_RCPGA001") .Or. IsInCallStack("U_RUTIL023"))

		if lAtivMultNat .And. lMulNatR

			//Gravo numero do contrato nos titulos gerados
			For nX := 1 to oModelFO1:Length()

				oModelFO1:GoLine(nX)

				aAuxRateio := {}

				//-- Itens que foram marcados
				If oModelFO1:GetValue("FO1_MARK")

					// adiciono os dados dos titulos
					aAuxRateio := ValNaturezaTituloOrig( U00->U00_CODIGO, oModelFO1:GetValue("FO1_PREFIX"),;
						oModelFO1:GetValue("FO1_NUM"),;
						oModelFO1:GetValue("FO1_PARCEL"),;
						oModelFO1:GetValue("FO1_TIPO"))

					// verifico se o array auxliar
					if Len(aAuxRateio) > 0

						for nI := 1 to Len(aAuxRateio)

							nPos := AScan(aRateio,{ |x| x[1] == aAuxRateio[nI, 1] },/*nStart*/,/*nCount*/)

							if nPos == 0
								aAdd( aRateio, {aAuxRateio[nI, 1], aAuxRateio[nI, 2], 0})
							else
								aRateio[nPos, 2] += aAuxRateio[nI, 2]							
								aRateio[nPos, 3] := 0								
							endIf

							nTotRateio+=aAuxRateio[nI, 2]

						next nI

					endIf

				endIf

			Next nX

		endIf

		if Len(aRateio) .And. nTotRateio > 0
			For nX := 1 to Len(aRateio)
				aRateio[nX, 3] := aRateio[nX, 2] / nTotRateio
			Next nX
		endIf

		//Gravo numero do contrato nos titulos gerados
		For nX := 1 to oModelFO2:Length()

			// posiciono na linha
			oModelFO2:GoLine(nX)
			If !oModelFO2:IsDeleted()

				//Posiciono no titulo que esta sendo feito a fatura e guardo o RECNO
				SE1->(DbSetOrder(1))
				If SE1->(MsSeek(xFilial("SE1")+oModelFO2:GetValue("FO2_PREFIX")+oModelFO2:GetValue("FO2_NUM")+oModelFO2:GetValue("FO2_PARCEL")+ oModelFO2:GetValue("FO2_TIPO")))

					RecLock("SE1",.F.)
					SE1->E1_XFORPG := oModelFO2:GetValue("FO2_XFORPG")
					SE1->E1_XCONTRA := U00->U00_CODIGO

					if Len(aRateio) > 1
						SE1->E1_MULTNAT := "1" // habilito o rateio para o titulo da liquidacao
					endIf

					SE1->(MsUnLock())

				EndIf

				// monto a chave com as informacoes do titulo
				cChaveTit := xFilial("SE1",SE1->E1_FILORIG) + "|" +;
					SE1->E1_PREFIXO + "|" +;
					SE1->E1_NUM		+ "|" +;
					SE1->E1_PARCELA + "|" +;
					SE1->E1_TIPO	+ "|" +;
					SE1->E1_CLIENTE + "|" +;
					SE1->E1_LOJA

				// pego a chave da FK7 referente ao titulo da SE1
				cChaveFK7 := FINGRVFK7("SE1",cChaveTit,SE1->E1_FILORIG)

				// gero os registros do rateio
				if Len(aRateio) > 0
					GeraSEV(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_VALOR, cChaveFK7, aRateio)
				endIf

			Endif

		Next nX

	EndIf

	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} ValNaturezaTituloOrig
Funcao para retornar a natureza e o valor da natureza
@type function
@version 1.0  
@author g.sampaio
@since 16/05/2021
@param cCodContrato, character, codigo do contrato
@param cPrefixoTit, character, prefixo do titulo
@param cNumeroTit, character, numero do titulo
@param cParcelaTit, character, parcela do titulo
@param cTipoTit, character, tipo do titulo
@return array, retorna os dados da natureza
/*/
Static Function ValNaturezaTituloOrig( cCodContrato, cPrefixoTit, cNumeroTit, cParcelaTit, cTipoTit )

	Local aRetorno	:= {}
	Local cQuery    := ""

	Default cCodContrato    := ""
	Default cPrefixoTit     := ""
	Default cNumeroTit      := ""
	Default cParcelaTit     := ""
	Default cTipoTit        := ""
	Default nValorTitulo    := 0

	if Select("TRBRAT") > 0
		TRBRAT->(DBCloseArea())
	endIf

	cQuery := " SELECT SE1.E1_NATUREZ NATUREZA, SE1.E1_VALOR VALORNAT "
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SE1.E1_FILIAL 	= '" + xFilial("SEV") + "' "
	cQuery += " AND SE1.E1_PREFIXO  = '" + cPrefixoTit + "' "
	cQuery += " AND SE1.E1_NUM      = '" + cNumeroTit + "' "
	cQuery += " AND SE1.E1_PARCELA  = '" + cParcelaTit + "' "
	cQuery += " AND SE1.E1_TIPO     = '" + cTipoTit + "' "
	cQuery += " AND SE1.E1_XCONTRA  = '" + cCodContrato + "' "
	cQuery += " AND SE1.E1_MULTNAT <> '1' "
	cQuery += " UNION ALL "
	cQuery += " SELECT SEV.EV_NATUREZ NATUREZA, SEV.EV_VALOR VALORNAT "
	cQuery += " FROM " + RetSqlName("SEV") + " SEV "
	cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 ON SE1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SE1.E1_FILIAL 	= SEV.EV_FILIAL "
	cQuery += " AND SE1.E1_PREFIXO 	= SEV.EV_PREFIXO "
	cQuery += " AND SE1.E1_NUM 		= SEV.EV_NUM "
	cQuery += " AND SE1.E1_TIPO 	= SEV.EV_TIPO "
	cQuery += " AND SE1.E1_PARCELA 	= SEV.EV_PARCELA "
	cQuery += " AND SE1.E1_XCONTRA  = '" + cCodContrato + "' "
	cQuery += " WHERE SEV.D_E_L_E_T_ = ' ' "
	cQuery += " AND SEV.EV_FILIAL 	= '" + xFilial("SEV") + "' "
	cQuery += " AND SEV.EV_PREFIXO  = '" + cPrefixoTit + "' "
	cQuery += " AND SEV.EV_NUM      = '" + cNumeroTit + "' "
	cQuery += " AND SEV.EV_PARCELA  = '" + cParcelaTit + "' "
	cQuery += " AND SEV.EV_TIPO     = '" + cTipoTit + "' "

	TcQuery cQuery New Alias "TRBRAT"

	while TRBRAT->(!Eof())

		aAdd(aRetorno, {TRBRAT->NATUREZA, TRBRAT->VALORNAT})

		TRBRAT->(DBSkip())
	endDo

	if Select("TRBRAT") > 0
		TRBRAT->(DBCloseArea())
	endIf

Return(aRetorno)

/*/{Protheus.doc} GeraSEV
funcao para gerar dados de rateio de multiplas
naturezas na tabela SEV
@type function
@version 1.0 
@author g.sampaio
@since 17/05/2021
@param cPrefixoTit, character, prefixo do titulo
@param cNumeroTit, character, numero do titulo
@param cParcelaTit, character, parcela do titulo
@param cTipoTit, character, tipo do titulo
@param cClienteTit, character, cliente do titulo
@param cLojaTit, character, loja do titulo
@param nValorTitulo, numeric, valor do titulo
@param cChaveFK7, character, chave de rastrei da FK7
@param aRateio, array, dados do rateio
/*/
Static Function GeraSEV( cPrefixoTit, cNumeroTit, cParcelaTit, cTipoTit, cClienteTit, cLojaTit, nValorTitulo, cChaveFK7, aRateio)

	Local aArea 		:= GetArea()
	Local aAreaSEV		:= SEV->(GetArea())
	Local nRateio		:= 0
	Local aAuxEV		:= {}
	Local aRatEv		:= {}
	Local oVirtusFin	:= Nil

	Default cPrefixoTit		:= ""
	Default cNumeroTit		:= ""
	Default cParcelaTit		:= ""
	Default cTipoTit		:= ""
	Default cClienteTit		:= ""
	Default cLojaTit		:= ""
	Default nValorTitulo	:= 0
	Default cChaveFK7		:= ""
	Default aRateio			:= {}

	// percorro os dados do rateio
	for nRateio := 1 to Len(aRateio)
		aAuxEV 			:= {}
		nValorRateio	:= 0
		nValorRateio 	:= Round(nValorTitulo * aRateio[nRateio, 3],TamSX3("EV_VALOR")[2])
		aAdd( aAuxEV, {"EV_NATUREZ"	, aRateio[nRateio, 1]		, Nil })
		aAdd( aAuxEV, {"EV_VALOR"	, nValorRateio				, Nil })
		aAdd( aAuxEV, {"EV_PERC"	, aRateio[nRateio, 3]*100	, Nil })
		aAdd( aRatEv, aAuxEv )
	next nRateio

	// abro a classe financeiro do virtus
	oVirtusFin := VirtusFin():New()

	// valido o array do rateio
	aRatEv := oVirtusFin:ValidaRateio(aRatEv, nValorTitulo)

	BEGIN TRANSACTION

		for nRateio := 1 to Len(aRatEv)

			if SEV->(Reclock("SEV", .T.))
				SEV->EV_FILIAL 	:= xFilial("SEV")
				SEV->EV_PREFIXO := cPrefixoTit
				SEV->EV_NUM		:= cNumeroTit
				SEV->EV_PARCELA	:= cParcelaTit
				SEV->EV_TIPO	:= cTipoTit
				SEV->EV_CLIFOR 	:= cClienteTit
				SEV->EV_LOJA	:= cLojaTit
				SEV->EV_NATUREZ	:= aRatEv[nRateio, 1, 2]
				SEV->EV_VALOR 	:= aRatEv[nRateio, 2, 2]
				SEV->EV_PERC 	:= aRatEv[nRateio, 3, 2]/100
				SEV->EV_RECPAG	:= "R"
				SEV->EV_RATEICC	:= "2"
				SEV->EV_IDENT	:= "1"
				SEV->EV_IDDOC	:= cChaveFK7
				SEV->(MsUnLock())
			else
				SEV->(DisarmTransaction())
			endIf

		next nRateio

	END TRANSACTION

	RestArea(aAreaSEV)
	RestArea(aArea)

Return(Nil)
