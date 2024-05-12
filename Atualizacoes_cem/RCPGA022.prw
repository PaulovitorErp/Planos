#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"
#include "totvs.ch"

/*/{Protheus.doc} RCPGA022
Geração da taxa de manutenção de contratos	
@type function
@version 
@author Wellington Gonçalves
@since 11/05/2016
@return nil
/*/
User Function RCPGA022()

	Local aArea			:= GetArea()
	Local aAreaU00		:= U00->(GetArea())
	Local cPerg 		:= "RCPGA022"
	Local cContratoDe	:= ""
	Local cContratoAte	:= ""
	Local cPlano		:= ""
	Local cIndice		:= ""
	Local lContinua		:= .T.
	Local lAtivaRegra	:= SuperGetMv("MV_XREGCEM",,.F.)
	Local nIndice		:= 0

	//-- Bloqueia rotina para apenas uma execução por vez
	//-- Criação de semáforo no servidor de licenças
	//-- LockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> lCreated
	If !LockByName("RCPGA022", .F., .T.)
		If IsBlind()
			cMessage := "[RCPGA022]["+ cFilAnt +"] Existe uma executacao ativa da rotina no momento. Aguarde..."
			FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		Else
			MsgAlert("[RCPGA022]["+ cFilAnt +"] Existe uma executacao ativa da rotina no momento. Aguarde...")
		EndIf

        Return
    EndIf

	//-- Comando para o TopConnect alterar mensagem do Monitor --//
	FWMonitorMsg("RCPGA022: PROCESSAMENTO GERACAO DE TAXA DE MANUTENCAO => " + cEmpAnt + "-" + cFilAnt)


	// verifico se a regra esta ativada
	if lAtivaRegra

		// se o uso de regra de manutencao estiver ativado chamo a nova rotina
		U_RCPGE044()

	else

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

	endIf

	RestArea(aAreaU00)
	RestArea(aArea)
	
	UnLockByName("RCPGA022", .F., .T.)

Return(Nil)

/*/{Protheus.doc} ValidParam
Função que valida os parâmetros informados.
@type function
@version 
@author Wellington Gonçalves
@since 13/05/2016
@param cContratoDe, character, param_description
@param cContratoAte, character, param_description
@param cPlano, character, param_description
@param cIndice, character, param_description
@param nIndice, numeric, param_description
@return return_type, return_description
/*/
Static Function ValidParam(cContratoDe,cContratoAte,cPlano,cIndice,nIndice)

	Local lRet 	:= .T.
	Local aRet	:= {}

	// verifico se foram preenchidos todos os parâmetros
	if Empty(cContratoDe) .AND. Empty(cContratoAte)

		lRet 	:= .F.
		Alert("Informe o intervalo dos contratos!")

	elseif Empty(cPlano)

		lRet 	:= .F.
		Alert("Informe o plano!")

	elseif Empty(cIndice)

		lRet 	:= .F.
		Alert("Informe o índice!")

	else

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

	endif

Return(lRet)

/*/{Protheus.doc} ConsultaCTR
Função que consulta os contratos que irão gerar taxa de manutenção
@type function
@version 1.0
@author Wellington Gonçalves
@since 13/05/2016
@param cContratoDe, character, param_description
@param cContratoAte, character, param_description
@param cPlano, character, param_description
@param cIndice, character, param_description
@param nIndice, numeric, param_description
@return return_type, return_description
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

	DEFINE MSDIALOG oDlg TITLE "Contratos para geração da taxa de manutenção" From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] COLORS 0, 16777215 PIXEL

	EnchoiceBar(oDlg, {|| ConfirmaManut(oGrid,cIndice)},{|| oDlg:End()},,aButtons)

// crio o grid de bicos
	oGrid := MsGridCTR(aPosObj)

// duplo clique no grid
	oGrid:oBrowse:bLDblClick := {|| DuoClique(oGrid)}

// caso não tenha encontrato títulos
	if !RefreshGrid(oGrid,cContratoDe,cContratoAte,cPlano,cIndice,nIndice)

		Alert("Não foram encontrados contratos para geração da taxa de manutenção!")
		oDlg:End()

	endif

	ACTIVATE MSDIALOG oDlg CENTERED

Return()

/*/{Protheus.doc} MsGridCTR
Função que cria o grid de contratos
@type function
@version 1.0
@author Wellington Gonçalves	
@since 13/05/2016
@param aPosObj, array, param_description
@return return_type, return_description
/*/
Static Function MsGridCTR(aPosObj)

	Local nX			:= 1
	Local aHeaderEx 	:= {}
	Local aColsEx 		:= {}
	Local aFieldFill 	:= {}
	Local aFields 		:= {"MARK","CONTRATO","DATA","CLIENTE","LOJA","DIA_VENCIMENTO","TXATU","INDICE","VLREAJ","TXREAJ"}
	Local aAlterFields 	:= {}

	For nX := 1 To Len(aFields)

		if aFields[nX] == "MARK"
			Aadd(aHeaderEx, {"","MARK","@BMP",2,0,"","€€€€€€€€€€€€€€","C","","","",""})
		elseif aFields[nX] == "CONTRATO"
			Aadd(aHeaderEx, {"Contrato","CONTRATO","@!",6,0,"","€€€€€€€€€€€€€€","C","","","",""})
		elseif aFields[nX] == "DATA"
			Aadd(aHeaderEx, {"Manutenção","DATA","",8,0,"","€€€€€€€€€€€€€€","D","","","",""})
		elseif aFields[nX] == "CLIENTE"
			Aadd(aHeaderEx, {"Cliente","CLIENTE","@!",TamSX3("U00_CLIENT")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
		elseif aFields[nX] == "LOJA"
			Aadd(aHeaderEx, {"Loja","LOJA","@!",TamSX3("U00_LOJA")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
		elseif aFields[nX] == "DIA_VENCIMENTO"
			Aadd(aHeaderEx, {"Dia Venc.","DIA_VENCIMENTO","@!",2,0,"","€€€€€€€€€€€€€€","C","","","",""})
		elseif aFields[nX] == "TXATU"
			Aadd(aHeaderEx, {"Taxa atual","TXATU",PesqPict("U00","U00_TXMANU"),TamSX3("U00_TXMANU")[1],TamSX3("U00_TXMANU")[2],"","€€€€€€€€€€€€€€","N","","","",""})
		elseif aFields[nX] == "INDICE"
			Aadd(aHeaderEx, {"Índice","INDICE",PesqPict("U29","U29_INDICE"),TamSX3("U29_INDICE")[1],TamSX3("U29_INDICE")[2],"","€€€€€€€€€€€€€€","N","","","",""})
		elseif aFields[nX] == "VLREAJ"
			Aadd(aHeaderEx, {"Valor Reajuste","VLREAJ",PesqPict("U00","U00_TXMANU"),TamSX3("U00_TXMANU")[1],TamSX3("U00_TXMANU")[2],"","€€€€€€€€€€€€€€","N","","","",""})
		elseif aFields[nX] == "TXREAJ"
			Aadd(aHeaderEx, {"Taxa reajustada","TXREAJ",PesqPict("U00","U00_TXMANU"),TamSX3("U00_TXMANU")[1],TamSX3("U00_TXMANU")[2],"","€€€€€€€€€€€€€€","N","","","",""})
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
Função atualiza o grid de contratos

@type function
@version 
@author Wellington Gonçalves
@since 13/05/2016
@param oGrid, object, param_description
@param cContratoDe, character, param_description
@param cContratoAte, character, param_description
@param cPlano, character, param_description
@param cIndice, character, param_description
@param nIndice, numeric, param_description
@return return_type, return_description
/*/
Static Function RefreshGrid(oGrid,cContratoDe,cContratoAte,cPlano,cIndice,nIndice)

	Local aArea					:= GetArea()
	Local lRet					:= .F.
	Local lUsaPrimVencto		:= SuperGetMv("MV_XPRIMVC",.F.,.F.)
	Local cDVencFix				:= SuperGetMv("MV_XVENMNT",.F.,"  ")
	Local cMesRea				:= SuperGetMv("MV_XPERPRO",.F.,"  ")
	Local cStatusCtr			:= SuperGetMV("MV_XMANSTS",.F.,"A;S")
	Local nQtdProxReaj			:= SuperGetMv("MV_XQPROXR",.F.,6) // quantidade de meses para a proximo reajuste
	Local cPulaLinha			:= chr(13)+chr(10)
	Local cQry 					:= ""
	Local aFieldFill			:= {}
	Local nValReaj				:= 0
	Local nTaxaReaj				:= 0
	Local nIndAplic				:= 0

	// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	cQry := " SELECT " 																												+ cPulaLinha
	cQry += " U00.U00_CODIGO AS CONTRATO, "																							+ cPulaLinha
	cQry += " U00.U00_CLIENT AS CLIENTE, "																							+ cPulaLinha
	cQry += " U00.U00_LOJA AS LOJA, "																								+ cPulaLinha

	If lUsaPrimVencto
		cQry += " ( CASE WHEN U00.U00_PRIMVE <> ' ' THEN SUBSTRING(U00_PRIMVE,7,2) ELSE U00.U00_DIAVEN END ) AS DIA_VENCIMENTO, "	+ cPulaLinha
	Else
		cQry += " U00.U00_DIAVEN AS DIA_VENCIMENTO, "																				+ cPulaLinha
	Endif

	cQry += " MANUTENCAO.DATA_MANUTENCAO AS DATA_MANUTENCAO, "																		+ cPulaLinha
	cQry += " (U00.U00_TXMANU + U00.U00_ADIMNT) AS TAXA " 																			+ cPulaLinha
	cQry += " FROM " 																												+ cPulaLinha
	cQry += + RetSqlName("U00") + " U00 " 																							+ cPulaLinha
	cQry += " INNER JOIN " 																											+ cPulaLinha
	cQry += " ( " 																													+ cPulaLinha
	cQry += " 	SELECT " 																											+ cPulaLinha
	cQry += " 	U00.U00_CODIGO AS CODIGO_CONTRATO, " 																				+ cPulaLinha
	cQry += " 	ISNULL(ULTIMA_MANUTENCAO.DATA_PROXIMA_MANUTENCAO,SEPULTAMENTO.DATA_UTILIZACAO) AS DATA_MANUTENCAO " 				+ cPulaLinha
	cQry += " 	FROM " 																												+ cPulaLinha
	cQry += + 	RetSqlName("U00") + " U00 " 																						+ cPulaLinha
	cQry += " 	LEFT JOIN " 																										+ cPulaLinha
	cQry += "   	( " 																											+ cPulaLinha
	cQry += "        	SELECT " 																									+ cPulaLinha
	cQry += "         	U04.U04_CODIGO AS CODIGO_CONTRATO, "  																		+ cPulaLinha
	If Empty(cMesRea)
		cQry += "         	MIN(LEFT(CONVERT(varchar, DateAdd(Month,"+ cValToChar(nQtdProxReaj)+",CAST(U04.U04_DATA AS DATETIME)) ,112),6)) AS DATA_UTILIZACAO " + cPulaLinha
	else
		cQry += " MIN(LEFT(U04.U04_DATA,6)) AS DATA_UTILIZACAO "																	+ cPulaLinha
	Endif
	cQry += "         	FROM " 																										+ cPulaLinha
	cQry += +		  	RetSqlName("U04") + " U04 " 																				+ cPulaLinha
	cQry += "         	WHERE " 																									+ cPulaLinha
	cQry += "         	U04.D_E_L_E_T_ <> '*' " 																					+ cPulaLinha
	cQry += " 		  	AND U04.U04_FILIAL = '" + xFilial("U04") + "' " 															+ cPulaLinha
	cQry += "         	AND U04.U04_DATA <> ' ' " 																					+ cPulaLinha
	cQry += "         	GROUP BY U04.U04_CODIGO " 																					+ cPulaLinha
	cQry += "     	) AS SEPULTAMENTO " 																							+ cPulaLinha
	cQry += "     ON SEPULTAMENTO.CODIGO_CONTRATO = U00.U00_CODIGO " 																+ cPulaLinha
	cQry += " LEFT JOIN " 																											+ cPulaLinha
	cQry += " 		( " 																											+ cPulaLinha
	cQry += "         	SELECT " 																									+ cPulaLinha
	cQry += "         	U26.U26_CONTRA AS CODIGO_CONTRATO, " 																		+ cPulaLinha
	cQry += "         	MAX(SUBSTRING(U26_PROMAN,3,4) + SUBSTRING(U26_PROMAN,1,2)) AS DATA_PROXIMA_MANUTENCAO " 					+ cPulaLinha
	cQry += "         	FROM " 																										+ cPulaLinha
	cQry += +		  	RetSqlName("U26") + " U26 " 																				+ cPulaLinha
	cQry += "         	WHERE " 																									+ cPulaLinha
	cQry += "         	U26.D_E_L_E_T_ <> '*' " 																					+ cPulaLinha
	cQry += " 		  	AND U26.U26_FILIAL = '" + xFilial("U26") + "' " 															+ cPulaLinha
	cQry += "           GROUP BY U26.U26_CONTRA "																					+ cPulaLinha
	cQry += "     	) AS ULTIMA_MANUTENCAO " 																						+ cPulaLinha
	cQry += "     ON ULTIMA_MANUTENCAO.CODIGO_CONTRATO = U00.U00_CODIGO " 															+ cPulaLinha
	cQry += " 	WHERE " 																											+ cPulaLinha
	cQry += " 	U00.D_E_L_E_T_ <> '*' " 																							+ cPulaLinha
	cQry += " 	AND U00.U00_FILIAL = '" + xFilial("U00") + "' " 																	+ cPulaLinha
	cQry += " 	AND U00.U00_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' " 										+ cPulaLinha

	if !Empty(cPlano)
		cQry += " 	AND U00.U00_PLANO IN " + FormatIn( AllTrim(cPlano),";") 		 												+ cPulaLinha
	endif

	cQry += " ) AS MANUTENCAO " 																									+ cPulaLinha
	cQry += " ON MANUTENCAO.CODIGO_CONTRATO = U00.U00_CODIGO " 																		+ cPulaLinha
	cQry += " AND MANUTENCAO.DATA_MANUTENCAO <= '" + AnoMes(dDataBase) + "' "														+ cPulaLinha
	cQry += " WHERE " 																												+ cPulaLinha
	cQry += " U00.D_E_L_E_T_ <> '*' " 																								+ cPulaLinha
	cQry += " AND U00.U00_FILIAL = '" + xFilial("U00") + "' " 																		+ cPulaLinha
	cQry += " AND (U00.U00_INDICE = '" + cIndice + "' OR U00.U00_INDMAN = '" + cIndice + "')"		 								+ cPulaLinha
	cQry += " AND U00.U00_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' " 										+ cPulaLinha
	if !Empty(cPlano)
		cQry += " AND U00.U00_PLANO IN " + FormatIn( AllTrim(cPlano),";") 		 													+ cPulaLinha
	endif
	cQry += " AND U00.U00_STATUS IN " + FormatIn( cStatusCtr,";")
	cQry += " AND U00.U00_TXMANU > 0 " 																								+ cPulaLinha
	cQry += " ORDER BY TAXA,U00.U00_CODIGO "																						+ cPulaLinha

	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)

	MemoWrite("C:\Temp\Taxa_Manutencaoo.txt",cQry)

	// crio o alias temporario
	TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query

	// se existir contratos a serem reajustados
	if QRY->(!Eof())

		oGrid:Acols := {}
		lRet 		:= .T.

		While QRY->(!Eof())

			aFieldFill := {}

			// verifico se já existe historico de manutenção
			// caso exista, será aplicado o índice
			U26->(DbSetOrder(2)) // U26_FILIAL + U26_CONTRA
			if AcresIndice(QRY->CONTRATO)
				nIndAplic := nIndice
			endif

			nValReaj	:= QRY->TAXA  * (nIndAplic / 100)
			nTaxaReaj 	:= QRY->TAXA + nValReaj

			aadd(aFieldFill, "CHECKED")
			aadd(aFieldFill, QRY->CONTRATO)
			aadd(aFieldFill, SubStr(QRY->DATA_MANUTENCAO,5,2) + "/" + SubStr(QRY->DATA_MANUTENCAO,1,4))
			aadd(aFieldFill, QRY->CLIENTE)
			aadd(aFieldFill, QRY->LOJA)

			//valido se esta definido o dia fixo de vencimento das taxas de manutencoes
			if !Empty(cDVencFix)
				aadd(aFieldFill, cDVencFix )
			else
				aadd(aFieldFill, QRY->DIA_VENCIMENTO)
			endif

			aadd(aFieldFill, QRY->TAXA)
			aadd(aFieldFill, nIndAplic)
			aadd(aFieldFill, nValReaj)
			aadd(aFieldFill, nTaxaReaj)
			aadd(aFieldFill, .F.)
			aadd(oGrid:Acols,aFieldFill)

			QRY->(DbSkip())

			//limpo variavel de adicao de indice de reajuste da taxa de manutencao
			nIndAplic := 0

		EndDo

		oGrid:oBrowse:Refresh()

	endif

	// fecho o alias temporario criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} DuoClique
Função chamada no duplo clique no grid

@type function
@version 
@author Wellington Gonçalves
@since 14/08/2020
@param oGrid, object, param_description
@return return_type, return_description
/*/
Static Function DuoClique(oGrid)

	if oGrid:aCols[oGrid:oBrowse:nAt][1] == "CHECKED"
		oGrid:aCols[oGrid:oBrowse:nAt][1] := "UNCHECKED"
	else
		oGrid:aCols[oGrid:oBrowse:nAt][1] := "CHECKED"
	endif

	oGrid:oBrowse:Refresh()

Return()

/*/{Protheus.doc} ConfirmaManut
Função chamada na confirmação da tela

@type function
@version 
@author Wellington Gonçalves
@since 13/05/2016
@param oGrid, object, param_description
@param cIndice, character, param_description
@return return_type, return_description
/*/
Static Function ConfirmaManut(oGrid,cIndice)

	Local nX		:= 1
	Local nPosCtr	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CONTRATO"})
	Local nPosVReaj	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "VLREAJ"})
	Local nPosTxAtu	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "TXATU"})
	Local nPosTaxa	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "TXREAJ"})
	Local nPosCli	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CLIENTE"})
	Local nPosLoja	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "LOJA"})
	Local nPosInd	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "INDICE"})
	Local nPosData	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "DATA"})
	Local nPosDia	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "DIA_VENCIMENTO"})
	Local nIndice	:= 0
	Local nTaxa		:= 0
	Local nValAdic	:= 0
	Local nMesesMan	:= SuperGetMv("MV_XINTTXA",.F.,6) // intervalo de meses para geração da segunda taxa
	Local nQtdManut	:= SuperGetMv("MV_XQTDTXA",.F.,2) // quantidade de taxas de manutenção que serão geradas
	Local cContrato	:= ""
	Local cCliente	:= ""
	Local cLoja		:= ""
	Local cProxReaj	:= ""
	Local dDtAux	:= CTOD("  /  /    ")
	Local lContinua	:= .T.

	Local cMesRea	:= SuperGetMv("MV_XPERPRO",.F.,"  ")

	if MsgYesNo("Deseja gerar a taxa de manutenção para os contratos?")

		//inicio a transacao
		BEGIN TRANSACTION

			// percorro todo o grid
			For nX := 1 To Len(oGrid:aCols)

				// se a linha estiver marcada
				if oGrid:aCols[nX][1] == "CHECKED"

					// se o contrato estiver preenchido
					if !Empty(oGrid:aCols[nX][nPosCtr])

						cContrato 	:= oGrid:aCols[nX][nPosCtr]
						cCliente	:= oGrid:aCols[nX][nPosCli]
						cLoja		:= oGrid:aCols[nX][nPosLoja]
						nTaxa		:= oGrid:aCols[nX][nPosTaxa]
						nValAdic	:= oGrid:aCols[nX][nPosVReaj]
						cDiaVenc	:= oGrid:aCols[nX][nPosDia]
						nIndice		:= oGrid:aCols[nX][nPosInd]

						//A data do proximo reajuste sera de acordo com a data de geracao da taxa
						//nao sera mais gerada de acordo com a data de enderecamento ou ultima taxa de manutencao gerada
						dDtAux := dDataBase
						If Empty(cMesRea)
							dDtAux		:= MonthSum(dDtAux,(nMesesMan * nQtdManut)) // somo a quantidade de meses para a próxima manutenção
							cProxReaj	:= StrZero(Month(dDtAux),2) + StrZero(Year(dDtAux),4)
						Else
							cProxReaj	:= StrZero(val(cMesRea),2) + StrZero(Year(dDtAux) + 1,4)
						Endif

						// chamo função do reajuste
						MsAguarde( {|| lContinua := U_ProcManut(cContrato,cCliente,cLoja,nTaxa,nValAdic,cDiaVenc,cIndice,nIndice,cProxReaj)}, "Aguarde", "Gerando taxa de manutenção ...", .F. )

					endif

					//caso nao inclui a taxa com sucesso, aborto o processo
					if !lContinua
						DisarmTransaction()
						Alert("Não foi possível concluir o processo de geração das taxas de manutenções, favor corrigir o erro especificado na mensagem anterior! " )
						Exit
					endif

				endif

			Next nX

			if lContinua
				Aviso("Sucesso!" , "Geração da taxa concluída!" , {"OK"} , 1)
			endif

		END TRANSACTION

		// fecho a janela
		oDlg:End()

	endif

Return(Nil)

/*/{Protheus.doc} ProcManut
Função que gera o título da taxa de manutenção	

@type function
@version 
@author Wellington Gonçalves
@since 20/05/2016
@param cContrato, character, param_description
@param cCliente, character, param_description
@param cLoja, character, param_description
@param nTaxa, numeric, param_description
@param nValAdic, numeric, param_description
@param cDiaVenc, character, param_description
@param cIndice, character, param_description
@param nIndice, numeric, param_description
@param cProxReaj, character, param_description
@param nQtdPrimTx, numeric, param_description
@return return_type, return_description
/*/
User Function ProcManut(cContrato,cCliente,cLoja,nTaxa,nValAdic,cDiaVenc,cIndice,nIndice,cProxReaj,nQtdPrimTx)

	Local aArea 		:= GetArea()
	Local aAreaSE1		:= SE1->(GetArea())
	Local aAreaU00		:= U00->(GetArea())
	Local cPrefixo 		:= SuperGetMv("MV_XPREFMN",.F.,"CTR")
	Local cTipo			:= SuperGetMv("MV_XTIPOMN",.F.,"MNT")
	Local cNat			:= SuperGetMv("MV_XNATMN",.F.,"10101") // natureza da taxa de manutencao
	Local aDados		:= {}
	Local aHistorico	:= {}
	Local nMesesMan		:= SuperGetMv("MV_XINTTXA",.F.,6) // intervalo de meses para geração da segunda taxa
	Local nQtdManut		:= SuperGetMv("MV_XQTDTXA",.F.,2) // quantidade de taxas de manutenção que serão geradas
	Local nX			:= 1
	Local cParcela		:= ""
	Local dDataAux		:= CTOD("  /  /    ")
	Local dVencimento	:= CTOD("  /  /    ")
	Local lContinua		:= .F.
	Local lOK			:= .T.
	Local lRecorrencia	:= SuperGetMv("MV_XATVREC",.F.,.F.)
	Local cMesAno		:= ""
	Local lPropor		:= SuperGetMv("MV_XPROPOR",.F.,.F.)
	Local cMesRea		:= SuperGetMv("MV_XPERPRO",.F.,"  ")
	Local nVlrAux		:= 0

	Default nQtdPrimTx	:= 1

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	// o vencimento da parcela será para o próximo mês
	// o dia de vencimento será de acordo com o informado no contrato
	If Empty(cMesRea)
		dDataAux := MonthSum(dDataBase,nQtdPrimTx)

		if cDiaVenc > StrZero(Day(LastDay(dDataAux)),2)
			dVencimento := LastDay(dDataAux)
		else
			dVencimento := CTOD(cDiaVenc + "/" + StrZero(Month(dDataAux),2) + "/" + StrZero(Year(dDataAux),4))
		endif
	Else

		dDataAux := STOD(cValToChar(Year(dDataBase)) + cMesRea + cDiaVenc)

		if cDiaVenc > StrZero(Day(LastDay(dDataAux)),2)
			dVencimento := LastDay(dDataAux)
		else
			dVencimento := CTOD(cDiaVenc + "/" + StrZero(Val(cMesRea),2) + "/" + StrZero(Year(dDataAux),4))
		endif

		if dVencimento < dDatabase

			if !lContinua

				if MsgYesNo("A data de vencimento do titulo está inferior a data atual, a data de vencimento será ajustada para a data atual, deseja continuar?")

					lContinua	:= .T.
					dVencimento	:= dDatabase

				else
					lOk := .F.
				endif

			else

				dVencimento	:= dDatabase

			endif

		endif

	Endif

	if lOk

		// verifica proporcionalidade do valor da taxa
		If lPropor

			DbSelectArea("U00")
			U00->(DbSetOrder(1)) //U00_FILIAL+U00_CODIGO
			U00->(DbSeek(xFilial("U00")+cContrato))

			DbSelectArea("U26")
			U26->(DbSetOrder(1)) //U26_FILIAL+U26_CODIGO

			// somente para a primeira parcela
			If !U26->(DbSeek(xFilial("U26")+cContrato))

				nVlrAux := nTaxa / 12

				If Month(U00->U00_DTATIV) <> 12
					nTaxa := nVlrAux * (12 - Month(U00->U00_DTATIV))
				Endif
			Endif
		Endif

		For nX := 1 To nQtdManut

			cParcela 	:= RetParcela(xFilial("SE1"),cPrefixo,cContrato)
			aDados 		:= {}
			lMsErroAuto	:= .F.
			cMesAno 	:= SubStr(DTOC(dVencimento),4,7)

			AAdd(aDados, {"E1_FILIAL"	, xFilial("SE1")					, Nil } )
			AAdd(aDados, {"E1_PREFIXO"	, cPrefixo          				, Nil } )
			AAdd(aDados, {"E1_NUM"		, cContrato		 	   				, Nil } )
			AAdd(aDados, {"E1_PARCELA"	, cParcela							, Nil } )
			AAdd(aDados, {"E1_TIPO"		, cTipo		 						, Nil } )
			AAdd(aDados, {"E1_NATUREZ"	, cNat								, Nil } )
			AAdd(aDados, {"E1_CLIENTE"	, cCliente							, Nil } )
			AAdd(aDados, {"E1_LOJA"		, cLoja								, Nil } )
			AAdd(aDados, {"E1_EMISSAO"	, dDataBase							, Nil } )
			AAdd(aDados, {"E1_VENCTO"	, dVencimento						, Nil } )
			AAdd(aDados, {"E1_VENCREA"	, DataValida(dVencimento)			, Nil } )
			AAdd(aDados, {"E1_VALOR"	, nTaxa								, Nil } )
			AAdd(aDados, {"E1_XCONTRA"	, cContrato							, Nil } )
			AAdd(aDados, {"E1_XPARCON"	, cMesAno							, Nil } )

			if lRecorrencia
				// veifio se a forma de pagamento da taxa de manutencao esta preenchida
				if !Empty(U00->U00_FPTAXA)
					AAdd(aDados, {"E1_XFORPG"	, U00->U00_FPTAXA					, Nil } )
				else
					AAdd(aDados, {"E1_XFORPG"	, U00->U00_FORPG					, Nil } )
				endIf
			endif

			//============================================================================
			// == PONTO DE ENTRADA PARA MANIPULACAO DO FINANCEIRO DA TAXA DE MANUTENCAO ==
			//============================================================================
			if ExistBlock("PECPG43FIN")

				aDados := ExecBlock( "PECPG43FIN", .F. ,.F., { aDados, U00->(Recno()) } )

				// valido o conteudo retornado pelo
				if len(aDados) == 0 .Or. ValType( aDados ) <> "A"
					lContinua	:= .F.
					MsgAlert("Estrutura do Array de títulos da taxa de manutenção inválida.", "PECPG43FIN")
				endIf

			endIf

			// array de historico de manutenção
			AAdd(aHistorico,{cPrefixo,cContrato,cParcela,cTipo,nTaxa,dVencimento})

			MSExecAuto({|x,y| FINA040(x,y)},aDados,3)

			if lMsErroAuto
				MostraErro()
				lOK := .F.
				Exit
			else
				lOK := .T.
			endif

			// somo X meses para a próxima taxa
			dVencimento := MonthSum(dVencimento,nMesesMan)

		Next nX

		if lOK

			if GravaHistorico(cContrato,cIndice,nIndice,nTaxa,nValAdic,cProxReaj,aHistorico)

				U00->(DbSetOrder(1)) // U00_FILIAL + U00_CODIGO
				if U00->(DbSeek(xFilial("U00") + cContrato))

					if RecLock("U00",.F.)
						U00->U00_ADIMNT += nValAdic
						U00->(MsUnLock())
					endif

				endif

			else
				lOk	:= .F.
				Alert("Não foi possível gerar a taxa de manutenção do contrato " + AllTrim(cContrato))
			endif

		endif

	endif

	RestArea(aAreaSE1)
	RestArea(aAreaU00)
	RestArea(aArea)

Return(lOk)

/*/{Protheus.doc} GravaHistorico
Função que grava o histórico da taxa de manutenção

@type function
@version 
@author Wellington Gonçalves
@since 15/04/2016
@param cContrato, character, param_description
@param cIndice, character, param_description
@param nIndice, numeric, param_description
@param nTaxa, numeric, param_description
@param nValAdic, numeric, param_description
@param cProxReaj, character, param_description
@param aDados, array, param_description
@return return_type, return_description
/*/
Static Function GravaHistorico(cContrato,cIndice,nIndice,nTaxa,nValAdic,cProxReaj,aDados)

	Local oAux
	Local oStruct
	Local cMaster 		:= "U26"
	Local cDetail		:= "U27"
	Local aCpoMaster	:= {}
	Local aLinha		:= {}
	Local aCpoDetail	:= {}
	Local oModel  		:= FWLoadModel("RCPGA023") // instanciamento do modelo de dados
	Local nX			:= 1
	Local nI       		:= 0
	Local nJ       		:= 0
	Local nPos     		:= 0
	Local lRet     		:= .T.
	Local aAux	   		:= {}
	Local nItErro  		:= 0
	Local lAux     		:= .T.
	Local cItem 		:= PADL("1",TamSX3("U27_ITEM")[1],"0")

	aadd(aCpoMaster,{"U26_FILIAL"	, xFilial("U26")	})
	aadd(aCpoMaster,{"U26_DATA"		, dDataBase			})
	aadd(aCpoMaster,{"U26_CONTRA"	, cContrato			})
	aadd(aCpoMaster,{"U26_TPINDI"	, cIndice			})
	aadd(aCpoMaster,{"U26_INDICE"	, nIndice			})
	aadd(aCpoMaster,{"U26_TAXA"		, nTaxa				})
	aadd(aCpoMaster,{"U26_VLADIC"	, nValAdic			})
	aadd(aCpoMaster,{"U26_PROMAN"	, cProxReaj			})

	For nX := 1 To Len(aDados)

		aLinha := {}

		aadd(aLinha,{"U27_FILIAL"	, xFilial("U27")	})
		aadd(aLinha,{"U27_ITEM"		, cItem				})
		aadd(aLinha,{"U27_PREFIX"	, aDados[nX,1]		})
		aadd(aLinha,{"U27_NUM"		, aDados[nX,2]		})
		aadd(aLinha,{"U27_PARCEL"	, aDados[nX,3]		})
		aadd(aLinha,{"U27_TIPO"		, aDados[nX,4]		})
		aadd(aLinha,{"U27_VALOR"	, aDados[nX,5]		})
		aadd(aLinha,{"U27_VENC"		, aDados[nX,6]		})
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

//limpo objetos da memoria
	FreeObj(oAux)
	FreeObj(oStruct)
	FreeObj(oModel)

Return(lRet)

/*/{Protheus.doc} BuscaIndice
Função que calcula a média do índice	

@type function
@version 
@author Wellington Gonçalves
@since 20/05/2016
@param cIndice, character, param_description
@return return_type, return_description
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
@version 
@author Wellington Gonçalves	
@since 20/05/2016
@param cPerg, character, param_description
@return return_type, return_description
/*/
Static Function AjustaSX1(cPerg)
// cria a tela de perguntas do relatório

	Local aHelpPor	:= {}
	Local aHelpEng	:= {}
	Local aHelpSpa	:= {}

	//////////// Contrato ///////////////
	U_xPutSX1( cPerg, "01","Contrato De?","Contrato De?","Contrato De?","cContratoDe","C",6,0,0,"G","","U00","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	U_xPutSX1( cPerg, "02","Contrato Ate?","Contrato Ate?","Contrato Ate?","cContratoAte","C",6,0,0,"G","","U00","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	///////////// Plano /////////////////
	U_xPutSX1( cPerg, "03","Plano?","Plano?","Plano?","cPlano","C",99,0,0,"G","","U05MRK","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	//////////// Índice ///////////////
	U_xPutSX1( cPerg, "04","Índice?","Índice?","Índice?","cIndice","C",3,0,0,"G","","U22","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return(Nil)

/*/{Protheus.doc} RetParcela
Função que retorna a próxima parcela do título a ser utilizada

@type function
@version 
@author Wellington Gonçalves
@since 20/05/2016
@param cFilSE1, character, param_description
@param cPrefixo, character, param_description
@param cNumero, character, param_description
@return return_type, return_description
/*/
Static Function RetParcela(cFilSE1,cPrefixo,cNumero)

	Local cRet 		:= ""
	Local aArea		:= GetArea()
	Local aAreaSE1	:= SE1->(GetArea())

	SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	if SE1->(DbSeek(cFilSE1 + cPrefixo + cNumero))

		While SE1->(!Eof()) .AND. SE1->E1_FILIAL == cFilSE1 .AND. SE1->E1_PREFIXO == cPrefixo .AND. AllTrim(SE1->E1_NUM) == cNumero

			cRet := SE1->E1_PARCELA
			SE1->(DbSkip())

		Enddo

		// pego a última parcela e incremento 1
		cRet := Soma1(cRet)

	else
		cRet := Padl("1",TamSX3("E1_PARCELA")[1],"0")
	endif

	RestArea(aAreaSE1)
	RestArea(aArea)

Return(cRet)

/*/{Protheus.doc} AcresIndice
Funcao para validar se acrescenta indice no proximo
reajuste
para o contrato consultado
@author Raphael Martins
@since 17/01/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function AcresIndice(cContrato)

	Local aArea 	:= GetArea()
	Local aAreaU00	:= U00->(GetArea())
	Local aAreaU26	:= U26->(GetArea())
	Local cQry 		:= ""
	Local lRet      := .F.

	cQry := " SELECT "
	cQry += " COUNT(*) QTD_ACRESC "
	cQry += " FROM "
	cQry += RetSQLName("U26") + " U26 "
	cQry += " WHERE "
	cQry += " D_E_L_E_T_ = ' ' "
	cQry += " AND U26.U26_FILIAL = '" + xFilial("U26")+ "' "
	cQry += " AND U26_CONTRA = '" + cContrato + "' "
	cQry += " AND U26_CONREA <> 'N' "

	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)

	// verifico se não existe este alias criado
	If Select("QRYREAJ") > 0
		QRYREAJ->(DbCloseArea())
	EndIf

	// crio o alias temporario
	TcQuery cQry New Alias "QRYREAJ"

	// se existir contratos a serem reajustados
	if QRYREAJ->QTD_ACRESC > 0

		lRet := .T.

	endif

	RestArea(aArea)
	RestArea(aAreaU00)
	RestArea(aAreaU26)

Return(lRet)
