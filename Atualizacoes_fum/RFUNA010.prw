#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} RFUNA010
Rotina de reajuste de contratos da funerária	
@type function
@version 1.0  
@author Wellington Gonçalves
@since 02/08/2016
/*/
User Function RFUNA010()

	Local aArea			:= GetArea()
	Local aAreaUF2		:= UF2->(GetArea())
	Local cPerg 		:= "RFUNA010"
	Local cContratoDe	:= ""
	Local cContratoAte	:= ""
	Local cPlano		:= ""
	Local cIndice		:= ""
	Local lContinua		:= .T.
	Local nIndice		:= 0


//-- Bloqueia rotina para apenas uma execução por vez
//-- Criação de semáforo no servidor de licenças
//-- LockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> lCreated
	If !LockByName("RFUNA010", .F., .T.)

		MsgAlert("[RFUNA010]["+ cFilAnt +"] Existe um PROCESSO de Reajuste ativo no momento. Aguarde...")

		Return()

	EndIf

//-- Comando para o TopConnect alterar mensagem do Monitor --//
	FWMonitorMsg("RFUNA010: PROCESSAMENTO DE REAJUSTES DE CONTRATOS => " + cEmpAnt + "-" + cFilAnt)

// cria as perguntas na SX1
	AjustaSx1(cPerg)

// enquanto o usuário não cancelar a tela de perguntas
	While lContinua


		// chama a tela de perguntas
		lContinua := Pergunte(cPerg,.T.)

		if lContinua

			cContratoDe 	:= MV_PAR01
			cContratoAte	:= MV_PAR02
			cPlano			:= MV_PAR03
			cIndice			:= MV_PAR04

			if ValidParam(cContratoDe,cContratoAte,cPlano,cIndice,@nIndice)

				MsAguarde( {|| ConsultaCTR(cContratoDe,cContratoAte,cPlano,cIndice,nIndice)}, "Aguarde", "Consultando os contratos...", .F. )

			endif

		endif

	EndDo

//-- Libera rotina para nova execução
//-- Excluir semáforo
//-- UnLockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> Nil
	UnLockByName("RFUNA010", .F., .T.)

	RestArea(aAreaUF2)
	RestArea(aArea)

Return()

/*/{Protheus.doc} ValidParam
Função que valida os parâmetros informados.	
@type function
@version 1.0
@author Wellington Gonçalves
@since 02/08/2016
@param cContratoDe, character, param_description
@param cContratoAte, character, param_description
@param cPlano, character, param_description
@param cIndice, character, param_description
@param nIndice, numeric, param_description
@return variant, return_description
/*/
Static Function ValidParam(cContratoDe,cContratoAte,cPlano,cIndice,nIndice)

	Local lRet 	:= .T.
	Local aRet	:= {}

// verifico se foram preenchidos todos os parâmetros
	if Empty(cContratoDe) .AND. Empty(cContratoAte)
		Alert("Informe o intervalo dos contratos!")
	elseif Empty(cPlano)
		Alert("Informe o plano!")
	elseif Empty(cIndice)
		Alert("Informe o índice!")
	endif

	// chamo função pra encontrar o índice INCC que será aplicado
	aRet := BuscaIndice(cIndice)
	nIndice	:= aRet[1]
	nQtdCad	:= aRet[2]

// valido se foi cadastrado os 12 ultimos meses do indice
	if nQtdCad < 12 .And. !MsgYesNo("Não foi realizado o cadastrado dos indices para os últimos 12 meses, deseja continuar a operação?","Atenção!")
		lRet := .F.
	else

		//se o indice retornado for negativo, zero o mesmo, pois as parcelas nao sofrerao reducao
		if nIndice < 0

			nIndice := 0

		endif

	endif


Return(lRet)

/*/{Protheus.doc} ConsultaCTR
Função que consulta os contratos aptos a serem reajustados	
@type function
@version 1.0
@author Wellington Gonçalves
@since 02/08/2016
@param cContratoDe, character, param_description
@param cContratoAte, character, param_description
@param cPlano, character, param_description
@param cIndice, character, param_description
@param nIndice, numeric, param_description
@return variant, return_description
/*/
Static Function ConsultaCTR(cContratoDe,cContratoAte,cPlano,cIndice,nIndice)

	Local aButtons	:= {}
	Local aObjects 	:= {}
	Local aSizeAut	:= MsAdvSize()
	Local aInfo		:= {}
	Local aPosObj	:= {}
	Local oGrid
	Static oDlg

//Largura, Altura, Modifica largura, Modifica altura
	aAdd( aObjects, { 100,	100, .T., .T. } ) //Browse

	aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG oDlg TITLE "Contratos a serem reajustados" From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] COLORS 0, 16777215 PIXEL

	EnchoiceBar(oDlg, {|| ConfirmaReajuste(oGrid,cIndice,nIndice)},{|| oDlg:End()},,aButtons)

// crio o grid de contratos
	oGrid := MsGridCTR(aPosObj)

// duplo clique no grid
	oGrid:oBrowse:bLDblClick := {|| DuoClique(oGrid)}

// caso não tenha encontrato títulos
	if !RefreshGrid(oGrid,cContratoDe,cContratoAte,cPlano,cIndice,nIndice)

		Alert("Não foram encontrados contratos para serem reajustados!")
		oDlg:End()

	endif

	ACTIVATE MSDIALOG oDlg CENTERED

Return()

/*/{Protheus.doc} MsGridCTR
Função que cria o grid de contratos	
@type function
@version 1.0
@author Wellington Gonçalves	 
@since 02/08/2016
@param aPosObj, array, param_description
@return variant, return_description
/*/
Static Function MsGridCTR(aPosObj)

	Local nX			:= 1
	Local aHeaderEx 	:= {}
	Local aColsEx 		:= {}
	Local aFieldFill 	:= {}
	Local aFields 		:= {"MARK","CONTRATO","PROX_REAJ","PARC_REST","PARC_GER","CLIENTE","LOJA","NOME","VALOR_CONTRATO","PERCENTUAL","VALOR_REAJUSTE","VALOR_TOTAL"}
	Local aAlterFields 	:= {}

	For nX := 1 To Len(aFields)

		if aFields[nX] == "MARK"
			Aadd(aHeaderEx, {"","MARK","@BMP",2,0,"","€€€€€€€€€€€€€€","C","","","",""})
		elseif aFields[nX] == "CONTRATO"
			Aadd(aHeaderEx, {"Contrato","CONTRATO","@!",6,0,"","€€€€€€€€€€€€€€","C","","","",""})
		elseif aFields[nX] == "PROX_REAJ"
			Aadd(aHeaderEx, {"Reajuste","PROX_REAJ","@R 99/9999",6,0,"","€€€€€€€€€€€€€€","C","","","",""})
		elseif aFields[nX] == "PARC_REST"
			Aadd(aHeaderEx, {"Parcelas Restantes","PARC_REST",PesqPict("UF2","UF2_QTPARC"),TamSX3("UF2_QTPARC")[1],0,"","€€€€€€€€€€€€€€","N","","","",""})
		elseif aFields[nX] == "PARC_GER"
			Aadd(aHeaderEx, {"Tot.Parc.Geradas","PARC_GER",PesqPict("UF2","UF2_QTPARC"),TamSX3("UF2_QTPARC")[1],0,"","€€€€€€€€€€€€€€","N","","","",""})
		elseif aFields[nX] == "NOME"
			Aadd(aHeaderEx, {"Nome","NOME",PesqPict("SA1","A1_NOME"),TamSX3("A1_NOME")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
		elseif aFields[nX] == "CLIENTE"
			Aadd(aHeaderEx, {"Cliente","CLIENTE","@!",TamSX3("UF2_CLIENT")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
		elseif aFields[nX] == "LOJA"
			Aadd(aHeaderEx, {"Loja","LOJA","@!",TamSX3("UF2_LOJA")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
		elseif aFields[nX] == "VALOR_CONTRATO"
			Aadd(aHeaderEx, {"Valor Contrato","VALOR_CTR",PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1],TamSX3("E1_VALOR")[2],"","€€€€€€€€€€€€€€","N","","","",""})
		elseif aFields[nX] == "PERCENTUAL"
			Aadd(aHeaderEx, {"% Reajuste","PERCENTUAL","@E 999.99",6,2,"","€€€€€€€€€€€€€€","N","","","",""})
		elseif aFields[nX] == "VALOR_REAJUSTE"
			Aadd(aHeaderEx, {"Valor do Reajuste","VALOR_REAJUSTE",PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1],TamSX3("E1_VALOR")[2],"","€€€€€€€€€€€€€€","N","","","",""})
		elseif aFields[nX] == "VALOR_TOTAL"
			Aadd(aHeaderEx, {"Valor Total","VALOR_TOTAL",PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1],TamSX3("E1_VALOR")[2],"","€€€€€€€€€€€€€€","N","","","",""})
		endif

	Next nX

// Define field values
	For nX := 1 To Len(aHeaderEx)

		if aHeaderEx[nX,2] == "MARK"
			Aadd(aFieldFill, "UNCHECKED")
		elseif aHeaderEx[nX,8] == "C"
			Aadd(aFieldFill, "")
		elseif aHeaderEx[nX,8] == "N"
			Aadd(aFieldFill, 0)
		elseif aHeaderEx[nX,8] == "D"
			Aadd(aFieldFill, CTOD("  /  /    "))
		elseif aHeaderEx[nX,8] == "L"
			Aadd(aFieldFill, .F.)
		endif

	Next nX

	Aadd(aFieldFill, .F.)
	Aadd(aColsEx, aFieldFill)

Return(MsNewGetDados():New( aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx))

/*/{Protheus.doc} RefreshGrid
Wellington Gonçalves  
@type function
@version 1.0
@author Wellington Gonçalves 
@since 15/04/2016
@param oGrid, object, param_description
@param cContratoDe, character, param_description
@param cContratoAte, character, param_description
@param cPlano, character, param_description
@param cIndice, character, param_description
@param nIndice, numeric, param_description
@return variant, return_description
/*/
Static Function RefreshGrid(oGrid,cContratoDe,cContratoAte,cPlano,cIndice,nIndice)

	Local lRet				:= .F.
	Local cQry 				:= ""
	Local aFieldFill		:= {}
	Local nValorAdicional	:= 0
	Local cPulaLinha		:= chr(13)+chr(10)
	Local cTipoParc			:= SuperGetMv("MV_XTIPFUN",.F.,"AT")
	Local cTipoRJ			:= SuperGetMv("MV_XTRJFUN",.F.,"RJ") // tipo do título
	Local cTipoAdt			:= SuperGetMv("MV_XTIPADT",.F.,"ADT")
	Local lUsaPrimVencto	:= SuperGetMv("MV_XPRIMVC",.F.,.F.)
	Local lConsCttSusp		:= SuperGetMv("MV_XCONSUS",.F.,.F.)
	Local lReajustaAdt		:= SuperGetMv("MV_XREJADT",.F.,.F.)
	Local lRoundParcela		:= SuperGetMv("MV_XARRPRC",.F.,.F.) //-- Arrendonda Parcelas Reajuste
	Local nAntecRJ          := SuperGetMv("MV_XANTREJ", .F., 0) //-- Quantidade de meses
	Local dDtFinRJ			:= dDataBase

//---------------------------------------------------------------------------------//
//-- Verifica se existe antecendência ativa para realização do reajuste.         --//
//-- Caso houver, aplica a antecendência na data base para filtro dos contratos. --//
//---------------------------------------------------------------------------------//
	If nAntecRJ > 0
		dDtFinRJ := MonthSum(dDataBase, nAntecRJ)
	EndIf

// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	cQry := " SELECT "																											+ cPulaLinha
	cQry += " UF2.UF2_CODIGO AS CONTRATO, "																						+ cPulaLinha
	cQry += " UF2.UF2_CLIENT AS CLIENTE, "																						+ cPulaLinha
	cQry += " UF2.UF2_LOJA AS LOJA, "																							+ cPulaLinha
	cQry += " UF2.UF2_VALOR AS VALOR_INICIAL, "																					+ cPulaLinha
	cQry += " UF2.UF2_VLADIC AS VALOR_ADICIONAL, "																				+ cPulaLinha
	cQry += " UF2.UF2_QTPARC AS QTD_PARCELAS, "																					+ cPulaLinha
	cQry += " ISNULL(TITULOS_CONTRATO.PARCELAS_GERADAS, 0) AS PARCELAS_GERADAS , " 															+ cPulaLinha
	cQry += " ISNULL(UF2.UF2_QTPARC - TITULOS_CONTRATO.PARCELAS_GERADAS, 0) AS PARCELAS_RESTANTES, "										+ cPulaLinha
	if lUsaPrimVencto
		cQry += " ( CASE WHEN UF2.UF2_PRIMVE <> ' ' THEN SUBSTRING(UF2_PRIMVE,7,2) ELSE UF2.UF2_DIAVEN END ) AS DIA_VENCIMENTO, "	+ cPulaLinha
	else
		cQry += " UF2.UF2_DIAVEN AS DIA_VENCIMENTO, "																			+ cPulaLinha
	endif
	cQry += " ISNULL(HISTORICO_REAJUSTE.PROXIMO_REAJUSTE,'') AS PROXIMO_REAJUSTE, "												+ cPulaLinha
	cQry += " ISNULL(TITULOS_ATIVACAO.ULTIMO_VENCIMENTO, '') AS ULTIMO_VENCIMENTO, "																				+ cPulaLinha
	cQry += " ISNULL(HISTORICO_REAJUSTE.PROXIMO_REAJUSTE,TITULOS_ATIVACAO.ULTIMO_VENCIMENTO) AS DATA_REAJUSTE "					+ cPulaLinha
	cQry += " FROM "																											+ cPulaLinha
	cQry += " " + RetSqlName("UF2") + " UF2 " 																					+ cPulaLinha
	cQry += " LEFT JOIN "																										+ cPulaLinha
	cQry += " 	( "																												+ cPulaLinha
	cQry += " 		SELECT "																									+ cPulaLinha
	cQry += " 		UF7.UF7_CONTRA AS CODIGO_CONTRATO, "																		+ cPulaLinha
	cQry += " 		MAX(SUBSTRING(UF7.UF7_PROREA,3,4) + SUBSTRING(UF7.UF7_PROREA,1,2)) AS PROXIMO_REAJUSTE "					+ cPulaLinha
	cQry += " 		FROM "																										+ cPulaLinha
	cQry += "       " + RetSqlName("UF7") + " UF7 " 																			+ cPulaLinha
	cQry += " 		WHERE "																										+ cPulaLinha
	cQry += " 		UF7.D_E_L_E_T_ <> '*' "																						+ cPulaLinha
	cQry += " 		AND UF7.UF7_FILIAL = '" + xFilial("UF7") + "' "																+ cPulaLinha
	cQry += " 		GROUP BY UF7.UF7_CONTRA "																					+ cPulaLinha
	cQry += " 	) AS HISTORICO_REAJUSTE "																						+ cPulaLinha
	cQry += " 	ON UF2.UF2_CODIGO = HISTORICO_REAJUSTE.CODIGO_CONTRATO "														+ cPulaLinha
	cQry += " LEFT JOIN "																										+ cPulaLinha
	cQry += " 	( "																												+ cPulaLinha
	cQry += " 		SELECT "																									+ cPulaLinha
	cQry += " 		SE1.E1_XCTRFUN AS CODIGO_CONTRATO, "																		+ cPulaLinha
	cQry += " 		MAX(SUBSTRING(SE1.E1_VENCTO,1,6)) AS ULTIMO_VENCIMENTO "													+ cPulaLinha
	cQry += " 		FROM "																										+ cPulaLinha
	cQry += "       " + RetSqlName("SE1") + " SE1 " 																			+ cPulaLinha
	cQry += " 		WHERE "																										+ cPulaLinha
	cQry += " 		SE1.D_E_L_E_T_ <> '*' "																						+ cPulaLinha
	cQry += " 		AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "																+ cPulaLinha

	//valido se considera Adiantamento de Parcelas para reajuste de Contratos
	if !lReajustaAdt
		cQry += "		AND SE1.E1_TIPO IN ('" + cTipoParc + "','" + cTipoRJ + "') "											+ cPulaLinha
	else
		cQry += "		AND SE1.E1_TIPO IN ('" + cTipoParc + "','" + cTipoRJ + "','" + cTipoAdt + "') "							+ cPulaLinha
	endif

	cQry += " 		AND E1_TIPOLIQ 		= ' '"
	cQry += " 		AND E1_FATURA 		= ' '"

	cQry += " 		GROUP BY SE1.E1_XCTRFUN "																					+ cPulaLinha
	cQry += " 	) AS TITULOS_ATIVACAO "																							+ cPulaLinha
	cQry += " 	ON UF2.UF2_CODIGO = TITULOS_ATIVACAO.CODIGO_CONTRATO  "														+ cPulaLinha
	cQry += " LEFT JOIN ( " 																												+ cPulaLinha
	cQry += " 	SELECT " 																										+ cPulaLinha
	cQry += " 	COUNT(*) AS PARCELAS_GERADAS, " 																				+ cPulaLinha
	cQry += " 	SE1.E1_XCTRFUN AS CODIGO_CONTRATO " 																			+ cPulaLinha
	cQry += " 	FROM " 																											+ cPulaLinha
	cQry += "	" + RetSqlName("SE1") + " SE1 " 																				+ cPulaLinha
	cQry += " 	WHERE " 																										+ cPulaLinha
	cQry += " 	SE1.D_E_L_E_T_ <> '*' " 																						+ cPulaLinha
	cQry += " 	AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "																	+ cPulaLinha
	cQry += " 	AND SE1.E1_XCTRFUN <> ' ' "																						+ cPulaLinha
	cQry += "   AND ( E1_TIPO IN ('"+ cTipoParc + "','" + cTipoAdt + "','" + cTipoRJ + "')"										+ cPulaLinha
	cQry += "			OR E1_NUMLIQ <> ' ' )"																					+ cPulaLinha
	cQry += " 	AND E1_TIPOLIQ 		= ' '"																						+ cPulaLinha
	cQry += " 	AND E1_FATURA 		= ' '"																						+ cPulaLinha

	//Nao retornar titulos de convalescente
	if SE1->(FieldPos("E1_XCONCTR")) > 0
		cQry += " AND SE1.E1_XCONCTR = ''"																						+ cPulaLinha
	endif

	cQry += " 	GROUP BY SE1.E1_XCTRFUN " 																						+ cPulaLinha
	cQry += " ) AS TITULOS_CONTRATO "
	cQry += " ON TITULOS_CONTRATO.CODIGO_CONTRATO = UF2.UF2_CODIGO  "															+ cPulaLinha
	cQry += " WHERE "																											+ cPulaLinha
	cQry += " UF2.D_E_L_E_T_ <> '*' "																							+ cPulaLinha
	cQry += " AND UF2.UF2_FILIAL = '" + xFilial("UF2") + "' "																	+ cPulaLinha

	//Valido se considera contratos suspensos no reajuste
	If lConsCttSusp
		cQry += " AND UF2.UF2_STATUS IN ('A','S') "																				+ cPulaLinha
	Else
		cQry += " AND UF2.UF2_STATUS IN ('A') "																					+ cPulaLinha
	Endif

	cQry += " AND UF2.UF2_DTATIV <> ' ' "																						+ cPulaLinha
	cQry += " AND UF2.UF2_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' " 									+ cPulaLinha
	cQry += " AND UF2.UF2_INDICE = '" + cIndice + "' "										 									+ cPulaLinha
	cQry += " AND ( "																											+ cPulaLinha
	cQry += " 	( "																												+ cPulaLinha
	cQry += " 		ISNULL(HISTORICO_REAJUSTE.CODIGO_CONTRATO,'') <> '' "														+ cPulaLinha
	cQry += " 		AND HISTORICO_REAJUSTE.PROXIMO_REAJUSTE <= '" + AnoMes(dDtFinRJ) + "' " 									+ cPulaLinha
	cQry += " 	) "																												+ cPulaLinha
	cQry += " 	OR "																											+ cPulaLinha
	cQry += " 	( "																												+ cPulaLinha
	cQry += " 		ISNULL(HISTORICO_REAJUSTE.CODIGO_CONTRATO,'') = '' "														+ cPulaLinha
	cQry += " 		AND TITULOS_ATIVACAO.CODIGO_CONTRATO <> '' "																+ cPulaLinha
	cQry += " 		AND TITULOS_ATIVACAO.ULTIMO_VENCIMENTO <= '" + AnoMes(dDtFinRJ) + "' "										+ cPulaLinha
	cQry += " 	) "																												+ cPulaLinha
	cQry += " ) "																												+ cPulaLinha

	if !Empty(cPlano)
		cQry += " 	AND UF2.UF2_PLANO IN " + FormatIn( AllTrim(cPlano),";") 		 											+ cPulaLinha
	endif

	cQry += "AND ISNULL(TITULOS_CONTRATO.PARCELAS_GERADAS, 0) < UF2.UF2_QTPARC"

	If ExistBlock("PEREA10QRY")
		cQry += ExecBlock("PEREA10QRY", .F., .F.)
	EndIf

	cQry += " ORDER BY UF2.UF2_CODIGO "																							+ cPulaLinha

	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)

	MemoWrite( GetTempPath() + "reajuste_rfuna010_" + DtoS(dDataBase) + StrTran(Time(),":","") + ".txt", cQry)

	// crio o alias temporario
	MpSysOpenQuery(cQry, "QRY")

	// se existir contratos a serem reajustados
	if QRY->(!Eof())

		oGrid:Acols := {}
		lRet 		:= .T.

		While QRY->(!Eof())

			aFieldFill := {}

			nValorContrato	:= QRY->VALOR_INICIAL + QRY->VALOR_ADICIONAL

			//valido se havera arrendondamento das parcelas
			if lRoundParcela
				nValorReajuste 	:= Round(nValorContrato * (nIndice / 100),1)
			else
				nValorReajuste 	:= nValorContrato * (nIndice / 100)
			endif

			aadd(aFieldFill, "CHECKED")
			aadd(aFieldFill, QRY->CONTRATO)
			aadd(aFieldFill, SubStr(QRY->DATA_REAJUSTE,5,2) + "/" + SubStr(QRY->DATA_REAJUSTE,1,4))
			aadd(aFieldFill, QRY->PARCELAS_RESTANTES)
			aadd(aFieldFill, QRY->PARCELAS_GERADAS)
			aadd(aFieldFill, QRY->CLIENTE)
			aadd(aFieldFill, QRY->LOJA)
			aadd(aFieldFill, Posicione("SA1",1,xFilial("SA1") + QRY->CLIENTE + QRY->LOJA,"A1_NOME"))
			aadd(aFieldFill, nValorContrato)
			aadd(aFieldFill, nIndice)
			aadd(aFieldFill, nValorReajuste)
			aadd(aFieldFill, nValorReajuste + nValorContrato)
			Aadd(aFieldFill, .F.)
			aadd(oGrid:Acols,aFieldFill)

			QRY->(DbSkip())

		EndDo

		oGrid:oBrowse:Refresh()

	endif

	// fecho o alias temporario criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

Return(lRet)

/*/{Protheus.doc} DuoClique
Função chamada no duplo clique no grid	
@type function
@version 1.0
@author Wellington Gonçalves
@since 15/04/2016
@param oGrid, object, param_description
@return variant, return_description
/*/
Static Function DuoClique(oGrid)

	if oGrid:aCols[oGrid:oBrowse:nAt][1] == "CHECKED"
		oGrid:aCols[oGrid:oBrowse:nAt][1] := "UNCHECKED"
	else
		oGrid:aCols[oGrid:oBrowse:nAt][1] := "CHECKED"
	endif

	oGrid:oBrowse:Refresh()

Return()

/*/{Protheus.doc} ConfirmaReajuste
Função chamada na confirmação da tela
@type function
@version 1.0
@author Wellington Gonçalves
@since 02/08/2016
@param oGrid, object, param_description
@param cIndice, character, param_description
@param nIndice, numeric, param_description
@return variant, return_description
/*/
Static Function ConfirmaReajuste(oGrid,cIndice,nIndice)

	Local lContinua			:= .T.
	Local nX				:= 1
	Local aArea				:= GetArea()
	Local aAreaUF2			:= UF2->(GetArea())
	Local nPosCtr			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CONTRATO"})
	Local nPosCli			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CLIENTE"})
	Local nPosLoja			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "LOJA"})
	Local nPosVlAdi			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "VALOR_REAJUSTE"})
	Local nPosVlTot			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "VALOR_TOTAL"})
	Local nPosInd			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "PERCENTUAL"})
	Local nPosParc			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "PARC_REST"})
	Local nPosGera			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "PARC_GER"})
	Local nPosData			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "PROX_REAJ"})
	Local cContrato			:= ""
	Local cCliente			:= ""
	Local cLoja				:= ""
	Local nIndice			:= 0
	Local nValParc			:= 0
	Local nValAdic			:= 0
	Local cDiaVenc			:= ""
	Local nQtdParc			:= SuperGetmv('MV_XQTDPAR',,12)
	Local cPrefixo 			:= SuperGetMv("MV_XPREFUN",.F.,"FUN") // prefixo do título
	Local cTipo				:= SuperGetMv("MV_XTRJFUN",.F.,"RJ") // tipo do título
	Local cNatureza			:= ""
	Local nAnosRenov		:= SuperGetMv("MV_XANOREN",.F.,4 )
	Local lUsaPrimVencto	:= SuperGetMv("MV_XPRIMVC",.F.,.F.)
	Local nAntecRJ 			:= SuperGetMv("MV_XANTREJ", .F., 0) //-- Quantidade de meses
	Local dUltData 			:= dDataBase //-- Data base ou prox reajuste ou ultimo vencimento

	UF4->(DbSetOrder(1))

	if Empty(cPrefixo)
		MsgAlert("Não foi informado o prefixo do título no parâmetro 'MV_XPREFUN'. ")
	elseif Empty(cTipo)
		MsgAlert("Não foi informado o tipo do título no parâmetro 'MV_XTRJFUN'. ")
	else

		if MsgYesNo("Deseja executar o reajuste dos contratos?")

			// percorro todo o grid
			For nX := 1 To Len(oGrid:aCols)

				// se a linha estiver marcada
				if oGrid:aCols[nX][1] == "CHECKED"

					// se o contrato estiver preenchido
					if !Empty(oGrid:aCols[nX][nPosCtr])

						UF2->(DbSetOrder(1)) // UF2_FILIAL + UF2_CODIGO
						if UF2->(DbSeek(xFilial("UF2") + oGrid:aCols[nX][nPosCtr]))

							// se a quantidade de parcelas default for maior que a quantidade de parcelas restantes
							if oGrid:aCols[nX][nPosParc] > 0 .And. nQtdParc > oGrid:aCols[nX][nPosParc]
								nQtdParc := oGrid:aCols[nX][nPosParc]
							endif

							//Valido se é necessario criar um novo ciclo para beneficiario do contrato
							If UF4->(DbSeek(xFilial("UF4")+UF2->UF2_CODIGO))

								While UF4->(!EOF()) ;
										.AND. UF4->UF4_FILIAL+UF4->UF4_CODIGO == UF2->UF2_FILIAL+UF2->UF2_CODIGO

									//Valido se beneficiario ja esta falecido
									if Empty(UF4->UF4_FALECI)

										//Valido se o reajuste esta no periodo de renovacao do ciclo
										If Year(UF4->UF4_DTFIM) <= Year(dDataBase)

											If RecLock("UF4",.F.)
												UF4->UF4_DTFIM := YearSum( UF4->UF4_DTFIM, nAnosRenov )
												UF4->(MsUnLock())
											Endif

										Endif

									Endif

									UF4->(DbSkip())
								EndDo

							Endif

							cContrato 	:= oGrid:aCols[nX][nPosCtr]
							if lUsaPrimVencto
								cDiaVenc	:= If(!Empty(UF2->UF2_PRIMVE),SubStr(DTOS(UF2->UF2_PRIMVE),7,2),UF2->UF2_DIAVEN)
							else
								cDiaVenc	:= UF2->UF2_DIAVEN
							endif
							cCliente	:= oGrid:aCols[nX][nPosCli]
							cLoja		:= oGrid:aCols[nX][nPosLoja]
							nValAdic	:= oGrid:aCols[nX][nPosVlAdi]
							nValParc	:= oGrid:aCols[nX][nPosVlTot]
							nIndice		:= oGrid:aCols[nX][nPosInd]
							If nAntecRJ > 0 //-- Caso houver antecedencia ativa
								//-- O calculo do proximo reajuste sera baseado no ultimo reajuste do contrato
								dDtAux := CTOD("01/" + oGrid:aCols[nX][nPosData])
								dUltData := dDtAux
							Else
								//-- O calculo do proximo reajuste sera com base na database do sistema
								dDtAux		:= dDataBase
							EndIf

							dDtAux		:= MonthSum(dDtAux,nQtdParc) // somo a quantidade de meses para a próxima manutenção
							cProxReaj	:= StrZero(Month(dDtAux),2) + StrZero(Year(dDtAux),4)
							cNatureza	:= UF2->UF2_NATURE

							if Empty(cNatureza)
								MsgAlert("Não foi informada a natureza financeira do contrato " + AllTrim(cContrato) + ". ")
							else

								// chamo função do reajuste
								FWMsgRun(,{|oSay| lContinua := ProcReajuste(oSay,cContrato,cCliente,cLoja,cIndice,nIndice,nQtdParc,nValParc,nValAdic,cProxReaj,cPrefixo,cTipo,cNatureza,cDiaVenc,dUltData)},'Aguarde...','Reajustando os contratos...')

								if !lContinua
									Exit
								endif

							endif

						endif

					endif

				endif

			Next nX

			if lContinua
				MsgInfo("Reajuste concluído!")
			endif

			// fecho a janela
			oDlg:End()

		endif

	endif

	RestArea(aAreaUF2)
	RestArea(aArea)

Return()

/*/{Protheus.doc} ProcReajuste
Função que faz o processamento do reajuste
@type function
@version 1.0
@author Wellington Gonçalves 
@since 02/08/2016
@param oSay, object, param_description
@param cContrato, character, param_description
@param cCliente, character, param_description
@param cLoja, character, param_description
@param cIndice, character, param_description
@param nIndice, numeric, param_description
@param nQtdParc, numeric, param_description
@param nValParc, numeric, param_description
@param nValAdic, numeric, param_description
@param cProxReaj, character, param_description
@param cPrefixo, character, param_description
@param cTipo, character, param_description
@param cNatureza, character, param_description
@param cDiaVenc, character, param_description
@param dUltData, date, param_description
@return variant, return_description
/*/
Static Function ProcReajuste(oSay,cContrato,cCliente,cLoja,cIndice,nIndice,nQtdParc,nValParc,nValAdic,cProxReaj,cPrefixo,cTipo,cNatureza,cDiaVenc,dUltData)

	Local aArea 		:= GetArea()
	Local aAreaSE1		:= SE1->(GetArea())
	Local aParcelas		:= {}
	Local aDados		:= {}
	Local aHistorico	:= {}
	Local aRegras		:= {}
	Local nDiaVenc		:= 0
	Local nX			:= 1
	Local cParcela		:= ""
	Local dVencimento	:= CTOD("  /  /    ")
	Local dEmissao		:= CTOD("  /  /    ")
	Local lOK			:= .F.
	Local cMesAno		:= ""
	Local lConsAniver	:= SuperGetMv("MV_XPARNIV",,.T.)
	Local lRoundParcela	:= SuperGetMv("MV_XARRPRC",.F.,.F.) //-- Arrendonda Parcelas Reajuste

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	Default dUltData := dDataBase //-- Data base ou Prox reajuste ou Ultimo vencimento

	BeginTran()

	dVencimento := MonthSum(dUltData,1)

	cParcela := RetParcela(xFilial("SE1"),cPrefixo,cContrato,cTipo)

	For nX := 1 To nQtdParc

		if cDiaVenc > StrZero(Day(LastDate(dVencimento)),2)
			dVencimento := LastDate(dVencimento)
		else
			dVencimento := CTOD(cDiaVenc + "/" + StrZero(Month(dVencimento),2) + "/" + StrZero(Year(dVencimento),4))
		endif

		aDados 		:= {}
		lMsErroAuto	:= .F.
		cMesAno 	:= SubStr(DTOC(dVencimento),4,7)

		oSay:cCaption := ("Contrato: " + AllTrim(cContrato) + ", gerando parcela " + cParcela + ", vencimento " + DTOC(dVencimento) + " ...")
		ProcessMessages()

		//Valido se parametro que considera aniversarios no calculo da parcela
		if lConsAniver
			aRegras  := {}

			//valida se arrendonda as parcelas
			if !lRoundParcela
				nValParc := U_RFUNE040(dVencimento,cContrato,@aRegras)
			else
				nValParc := Round(U_RFUNE040(dVencimento,cContrato,@aRegras),1)
			endif

			nValParc := nValParc + nValAdic

		Endif

		//caso o contrato seja reajustado em atraso, corrige a data de emissao
		dEmissao := if(dVencimento < dDataBase, dVencimento, dDataBase )

		AAdd(aDados, {"E1_FILIAL"	, xFilial("SE1")					, Nil } )
		AAdd(aDados, {"E1_PREFIXO"	, cPrefixo          				, Nil } )
		AAdd(aDados, {"E1_NUM"		, cContrato		 	   				, Nil } )
		AAdd(aDados, {"E1_PARCELA"	, cParcela							, Nil } )
		AAdd(aDados, {"E1_TIPO"		, cTipo		 						, Nil } )
		AAdd(aDados, {"E1_NATUREZ"	, cNatureza							, Nil } )
		AAdd(aDados, {"E1_CLIENTE"	, cCliente							, Nil } )
		AAdd(aDados, {"E1_LOJA"		, cLoja								, Nil } )
		AAdd(aDados, {"E1_EMISSAO"	, dEmissao							, Nil } )
		AAdd(aDados, {"E1_VENCTO"	, dVencimento						, Nil } )
		AAdd(aDados, {"E1_VENCREA"	, DataValida(dVencimento)			, Nil } )
		AAdd(aDados, {"E1_VALOR"	, nValParc							, Nil } )
		AAdd(aDados, {"E1_XCTRFUN"	, cContrato							, Nil } )
		AAdd(aDados, {"E1_XPARCON"	, cMesAno							, Nil } )
		AAdd(aDados, {"E1_XFORPG"	, UF2->UF2_FORPG					, Nil } )


		// array de historico de manutenção
		AAdd(aHistorico,{cPrefixo,cContrato,cParcela,cTipo,nValParc})

		MSExecAuto({|x,y| FINA040(x,y)},aDados,3)

		if lMsErroAuto
			MostraErro()
			DisarmTransaction()
			lOK := .F.
			Exit
		else
			lOK := .T.

			//Gravo composicao do valor da parcela se parametro
			//por parcela idade estiver habilitado
			if lConsAniver

				U_RFUN40OK(cContrato,aRegras,dDataBase)
			Endif
		endif

		// incremento a parcela
		cParcela	:= Soma1(cParcela)
		dVencimento := MonthSum(dVencimento,1)

	Next nX

	if lOK

		lOK := GravaHistorico(cContrato,cIndice,nIndice,cProxReaj,nValAdic,aHistorico)

		if lOK

			UF2->(DbSetOrder(1)) // UF2_FILIAL + UF2_CODIGO
			if UF2->(DbSeek(xFilial("UF2") + cContrato))

				if RecLock("UF2",.F.)
					UF2->UF2_VLADIC += nValAdic
					UF2->(MsUnLock())
					EndTran()
				endif

			endif

		else

			// aborto a transação
			DisarmTransaction()

		endif

	endif

	if !lOK

		MsgAlert("Ocorreu um problema no reajuste do contrato " + AllTrim(cContrato),"Atenção!")

		if MsgYesNo("Deseja continuar reajustando os contratos?")
			lOK := .T.
		endif

	endif

	RestArea(aAreaSE1)
	RestArea(aArea)

Return(lOK)

/*/{Protheus.doc} GravaHistorico
Função que grava o histórico do reajuste		
@type function
@version 1.0
@author Wellington Gonçalves
@since 05/08/2016
@param cContrato, character, param_description
@param cIndice, character, param_description
@param nIndice, numeric, param_description
@param cProxReaj, character, param_description
@param nValAdic, numeric, param_description
@param aDados, array, param_description
@return variant, return_description
/*/
Static Function GravaHistorico(cContrato,cIndice,nIndice,cProxReaj,nValAdic,aDados)

	Local oAux
	Local oStruct
	Local cMaster 		:= "UF7"
	Local cDetail		:= "UF8"
	Local aCpoMaster	:= {}
	Local aLinha		:= {}
	Local aCpoDetail	:= {}
	Local oModel  		:= FWLoadModel("RFUNA011") // instanciamento do modelo de dados
	Local nX			:= 1
	Local nI       		:= 0
	Local nJ       		:= 0
	Local nPos     		:= 0
	Local lRet     		:= .T.
	Local aAux	   		:= {}
	Local nItErro  		:= 0
	Local lAux     		:= .T.
	Local cItem 		:= PADL("1",TamSX3("UF8_ITEM")[1],"0")

	aadd(aCpoMaster,{"UF7_FILIAL"	, xFilial("UF7")	})
	aadd(aCpoMaster,{"UF7_DATA"		, dDataBase			})
	aadd(aCpoMaster,{"UF7_CONTRA"	, cContrato			})
	aadd(aCpoMaster,{"UF7_INDICE"	, nIndice			})
	aadd(aCpoMaster,{"UF7_PROREA"	, cProxReaj			})
	aadd(aCpoMaster,{"UF7_VLADIC"	, nValAdic			})
	aadd(aCpoMaster,{"UF7_TPINDI"	, cIndice			})

	For nX := 1 To Len(aDados)

		aLinha := {}

		aadd(aLinha,{"UF8_FILIAL"	, xFilial("UF8")	})
		aadd(aLinha,{"UF8_ITEM"		, cItem				})
		aadd(aLinha,{"UF8_PREFIX"	, aDados[nX,1]		})
		aadd(aLinha,{"UF8_NUM"		, aDados[nX,2]		})
		aadd(aLinha,{"UF8_PARCEL"	, aDados[nX,3]		})
		aadd(aLinha,{"UF8_TIPO"		, aDados[nX,4]		})
		aadd(aLinha,{"UF8_VALOR"	, aDados[nX,5]		})
		aadd(aCpoDetail,aLinha)

		cItem := SOMA1(cItem)

	Next nX

	(cDetail)->(DbSetOrder(1))
	(cMaster)->(DbSetOrder(1))

// defino a operação de inclusão
	oModel:SetOperation(3)

// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	lRet := oModel:Activate()

	If lRet

		// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
		oAux := oModel:GetModel( cMaster + 'MASTER' )

		// Obtemos a estrutura de dados do cabeçalho
		oStruct := oAux:GetStruct()
		aAux := oStruct:GetFields()

		If lRet

			For nI := 1 To Len(aCpoMaster)

				// Verifica se os campos passados existem na estrutura do cabeçalho
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoMaster[nI][1] ) } ) ) > 0

					// È feita a atribuicao do dado aos campo do Model do cabeçalho
					If !( lAux := oModel:SetValue( cMaster + 'MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )

						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						lRet    := .F.
						Exit

					EndIf

				EndIf

			Next nI

		EndIf

	EndIf

	If lRet

		// Intanciamos apenas a parte do modelo referente aos dados do item
		oAux := oModel:GetModel( cDetail + 'DETAIL' )

		// Obtemos a estrutura de dados do item
		oStruct := oAux:GetStruct()
		aAux := oStruct:GetFields()

		nItErro  := 0

		For nI := 1 To Len(aCpoDetail)

			// Incluímos uma linha nova
			// ATENCAO: O itens são criados em uma estrura de grid (FORMGRID), portanto já é criada uma primeira linha
			//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez

			If nI > 1

				// Incluimos uma nova linha de item

				If  ( nItErro := oAux:AddLine() ) <> nI

					// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
					// ele retorna a quantidade de linhas já
					// existem no grid. Se conseguir retorna a quantidade mais 1
					lRet    := .F.
					Exit

				EndIf

			EndIf

			For nJ := 1 To Len( aCpoDetail[nI] )

				// Verifica se os campos passados existem na estrutura de item
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0

					If !( lAux := oModel:SetValue( cDetail + 'DETAIL', aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )

						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						lRet    := .F.
						nItErro := nI
						Exit

					EndIf

				EndIf

			Next nJ

			If !lRet
				Exit
			EndIf

		Next nI

	EndIf

	If lRet

		// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
		// neste momento os dados não são gravados, são somente validados.
		If ( lRet := oModel:VldData() )

			// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
			lRet := oModel:CommitData()
			//FreeObj(oModel)
		EndIf

	EndIf

	If !lRet

		// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
		aErro   := oModel:GetErrorMessage()

		// A estrutura do vetor com erro é:
		//  [1] Id do formulário de origem
		//  [2] Id do campo de origem
		//  [3] Id do formulário de erro
		//  [4] Id do campo de erro
		//  [5] Id do erro
		//  [6] mensagem do erro
		//  [7] mensagem da solução
		//  [8] Valor atribuido
		//  [9] Valor anterior

		AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
		AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
		AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
		AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
		AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
		AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
		AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
		AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
		AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )

		If nItErro > 0
			AutoGrLog( "Erro no Item:              " + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' )
		EndIf

		MostraErro()

	EndIf

// Desativamos o Model
	oModel:DeActivate()

Return(lRet)

/*/{Protheus.doc} BuscaIndice
Função que calcula a média do índice	
@type function
@version 1.0
@author Wellington Gonçalves
@since 02/08/2016
@param cIndice, character, param_description
@return variant, return_description
/*/
Static Function BuscaIndice(cIndice)

	Local cQry 		   	:= ""
	Local cPulaLinha	:= chr(13)+chr(10)
	Local nIndice		:= 0
	Local nQtdCad		:= 0
	Local dDataRef		:= dDataBase

// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	cQry := " SELECT " 																				+ cPulaLinha
	cQry += " COUNT(*) QTDCAD, "																	+ cPulaLinha
	cQry += " SUM(U29.U29_INDICE) AS INDICE " 														+ cPulaLinha
	cQry += " FROM " 																				+ cPulaLinha
	cQry += + RetSqlName("U22") + " U22 " 															+ cPulaLinha
	cQry += " INNER JOIN " 																			+ cPulaLinha
	cQry += + RetSqlName("U28") + " U28 " 															+ cPulaLinha
	cQry += "    INNER JOIN " 																		+ cPulaLinha
	cQry += + 	 RetSqlName("U29") + " U29 " 														+ cPulaLinha
	cQry += "    ON ( " 																			+ cPulaLinha
	cQry += "        U29.D_E_L_E_T_ <> '*' " 														+ cPulaLinha
	cQry += "        AND U28.U28_CODIGO = U29.U29_CODIGO " 											+ cPulaLinha
	cQry += "        AND U28.U28_ITEM = U29.U29_IDANO " 											+ cPulaLinha
	cQry += " 		 AND U29.U29_FILIAL = '" + xFilial("U29") + "' " 								+ cPulaLinha
	cQry += "    ) " 																				+ cPulaLinha
	cQry += " ON ( " 																				+ cPulaLinha
	cQry += "    U28.D_E_L_E_T_ <> '*' " 															+ cPulaLinha
	cQry += "    AND U22.U22_CODIGO = U28.U28_CODIGO " 												+ cPulaLinha
	cQry += " 	 AND U28.U28_FILIAL = '" + xFilial("U28") + "' " 									+ cPulaLinha
	cQry += "    ) " 																				+ cPulaLinha
	cQry += " WHERE " 																				+ cPulaLinha
	cQry += " U22.D_E_L_E_T_ <> '*' " 																+ cPulaLinha
	cQry += " AND U22.U22_FILIAL = '" + xFilial("U22") + "' " 										+ cPulaLinha
	cQry += " AND U22.U22_STATUS IN ('A','S') "														+ cPulaLinha

	if !Empty(cIndice)
		cQry += " AND U22.U22_CODIGO = '" + cIndice + "' " 											+ cPulaLinha
	endif

	cQry += " AND U28.U28_ANO + U29.U29_MES " 														+ cPulaLinha
	cQry += " BETWEEN '" + AnoMes(MonthSub(dDataRef,11)) + "'  AND  '" + AnoMes(dDataRef) + "' " 	+ cPulaLinha

	MemoWrite("C:\Temp\indice.txt",cQry)

// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)

// crio o alias temporario
	TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query

// se existir contratos a serem reajustados
	if QRY->(!Eof())
		nIndice := Round(QRY->INDICE,TamSX3("U29_INDICE")[2])
		nQtdCad	:= QRY->QTDCAD
	endif

// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

Return({nIndice,nQtdCad})

/*/{Protheus.doc} AjustaSX1
Função que cria as perguntas na SX1.
@type function
@version 1.0
@author g.sampaio
@since 02/08/2016
@param cPerg, character, param_description
@return variant, return_description
/*/
Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relatório

	Local aHelpPor	:= {}
	Local aHelpEng	:= {}
	Local aHelpSpa	:= {}

//////////// Contrato ///////////////

	U_xPutSX1( cPerg, "01","Contrato De?","Contrato De?","Contrato De?","cContratoDe","C",6,0,0,"G","","UF2ESP","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	U_xPutSX1( cPerg, "02","Contrato Ate?","Contrato Ate?","Contrato Ate?","cContratoAte","C",6,0,0,"G","","UF2ESP","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

///////////// Plano /////////////////

	U_xPutSX1( cPerg, "03","Plano?","Plano?","Plano?","cPlano","C",99,0,0,"G","","UF0MRK","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// Índice ///////////////

	U_xPutSX1( cPerg, "04","Índice?","Índice?","Índice?","cIndice","C",3,0,0,"G","","U22","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return(Nil)

/*/{Protheus.doc} RetParcela
Função que retorna a próxima 
parcela do título a ser utilizada
@type function
@version 1.0
@author Wellington Gonçalves
@since 02/08/2016
@param cFilSE1, character, param_description
@param cPrefixo, character, param_description
@param cNumero, character, param_description
@param cTipo, character, param_description
@return variant, return_description
/*/
Static Function RetParcela(cFilSE1,cPrefixo,cNumero,cTipo)

	Local cRet 			:= ""
	Local cQry			:= ""
	Local aArea			:= GetArea()
	Local cPulaLinha	:= chr(13)+chr(10)

// verifico se não existe este alias criado
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	EndIf

	cQry := " SELECT "											+ cPulaLinha
	cQry += " MAX(SE1.E1_PARCELA) AS ULTIMA_PARCELA "			+ cPulaLinha
	cQry += " FROM " 											+ cPulaLinha
	cQry += " " + RetSqlName("SE1") + " SE1 " 					+ cPulaLinha
	cQry += " WHERE " 											+ cPulaLinha
	cQry += " SE1.D_E_L_E_T_ <> '*' " 							+ cPulaLinha
	cQry += " AND SE1.E1_FILIAL = '" + cFilSE1 + "' "			+ cPulaLinha
	cQry += " AND SE1.E1_PREFIXO = '" + cPrefixo + "' " 		+ cPulaLinha
	cQry += " AND SE1.E1_XCTRFUN = '" + cNumero + "' " 			+ cPulaLinha
	cQry += " AND SE1.E1_TIPO = '" + cTipo + "' " 				+ cPulaLinha

//verifico se o campo de importacao esta ativo na base
	If SE1->(FieldPos("E1_XIMP")) > 0
		cQry += " AND ( SE1.E1_PARCELA < '900' OR E1_XIMP = ' ' )"	+ cPulaLinha
	endif

// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)

// crio o alias temporario
	TcQuery cQry New Alias "QRYSE1" // Cria uma nova area com o resultado do query

// se existir títulos com este tipo
	if QRYSE1->(!Eof()) .AND. !Empty(QRYSE1->ULTIMA_PARCELA)
		cRet := Soma1(QRYSE1->ULTIMA_PARCELA)
	else
		cRet := Padl("1",TamSX3("E1_PARCELA")[1],"0")
	endif

// fecho o alias temporario criado
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(cRet)
