#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE  cPulaLinha CHR(13)+CHR(10)

/*/{Protheus.doc} RFUNR001
Impressão de Relatório de Titulos Financeiros de Contrato 
Orientação do tipo Retrato
@author André R. Barrero 
@since 02/09/2016
/*/

User Function RFUNR001()

	Local oReport
	Local cPerg := "RFUNR001"

	U_xPutSX1(cPerg,"01","Contrato De?"	 	,"","","mv_ch1","C",06,0,0,"G","","UF2"		,"","","MV_PAR01","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"02","Contrato Ate?"	 	,"","","mv_ch2","C",06,0,0,"G","","UF2"		,"","","MV_PAR02","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"03","Status Contrato?" 	,"","","mv_ch3","C",10,0,0,"G","","STFUN"	,"","","MV_PAR03","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"04","Cliente Negativado?"	,"","","mv_ch4","C",01,0,0,"C","",""   		,"","","MV_PAR04","Sim","","","","Nao","","","Ambos","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"05","Status Titulos?"		,"","","mv_ch5","C",01,0,0,"C","",""   		,"","","MV_PAR05","Aberto","","","","Pago","","","Ambos","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"06","Emissao Tit De?"		,"","","mv_ch6","D",08,0,0,"G","","" 		,"","","MV_PAR06","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"07","Emissao Tit Ate?"	,"","","mv_ch7","D",08,0,0,"G","",""   		,"","","MV_PAR07","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"08","Venc Tit De?"		,"","","mv_ch8","D",08,0,0,"G","","" 		,"","","MV_PAR08","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"09","Venc Tit Ate?"  		,"","","mv_ch9","D",08,0,0,"G","",""   		,"","","MV_PAR09","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"10","Servico Realizado?"	,"","","mv_ch10","C",01,0,0,"C","",""   	,"","","MV_PAR10","Sim","","","","Nao","","","Ambos","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"11","Tipo?"				,"","","mv_ch11","C",01,0,1,"C","",""		,"","","MV_PAR11","Analitico","","","","Sintetico","","","","","","","","","","","",{"",""},{"",""},{"",""})

	Pergunte(cPerg,.T.)
	oReport:= ReportDef()
	oReport:PrintDialog()
	oReport:SetParam()

Return

/*/{Protheus.doc} ReportDef
// Na seção de definição do relatório, função ReportDef(), devem ser criados os componentes de impressão, 
as seções e as células, os totalizadores e demais componentes que o usuário poderá personalizar no relatório.
@author André R. Barrero
@since 02/09/2016
/*/
Static Function ReportDef()

	Local oReport

	Local oContrato
	Local oTitulos
	Local oSubtotal
	Local oTotal

	Local cTitle := "Relatório de Titulos Financeiros de Contrato"

	oReport:= TReport():New("RFUNR001",cTitle,"RFUNR001",{|oReport| PrintReport(oReport,oContrato,oTitulos,oSubtotal,oTotal)},"Este relatório apresenta a relação de Títulos Financeiros de Contrato do sistema.")
	oReport:SetPortrait()
	oReport:HideParamPage()
	oReport:SetUseGC(.F.) // Desabilita o botão <Gestao Corporativa> do relatório

	oContrato := TRSection():New(oReport,"Contrato",{"QRYCPRT"})
	oContrato:SetHeaderPage(.F.)
	oContrato:SetHeaderSection(.T.)
	oContrato:SetPageBreak(.T.)

	TRCell():New(oContrato,"UF2_CODIGO"	, "QRYCONTR", "CONTRATO",			PesqPict("UF2","UF2_CODIGO"),TamSX3("UF2_CODIGO")[1]+1)
	TRCell():New(oContrato,"UF2_CLIENT"	, "QRYCONTR", "CLIENTE",			PesqPict("UF2","UF2_CLIENT"),TamSX3("UF2_CLIENT")[1]+1)
	TRCell():New(oContrato,"UF2_LOJA"	, "QRYCONTR", "LOJA",				PesqPict("UF2","UF2_LOJA"),TamSX3("UF2_LOJA")[1]+1)
	TRCell():New(oContrato,"A1_NOME"	, "QRYCONTR", "NOME",				PesqPict("SA1","A1_NOME"),TamSX3("A1_NOME")[1]+1)
	TRCell():New(oContrato,"A1_XCLINEG"	, "QRYCONTR", "CLI NEGATIVADO",	PesqPict("SA1","A1_XCLINEG"),TamSX3("A1_XCLINEG")[1]+1)

	If MV_PAR11 == 2 //Sintético

		TRCell():New(oContrato,"QTDABERTO"	, "QRYCONTR", "QTD ABERTO", 	"@E 9,999,999",10)
		TRCell():New(oContrato,"TTABERTO"	, "QRYCONTR", "TOT ABERTO",		PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+1)
		TRCell():New(oContrato,"QTDPAGOS"	, "QRYCONTR", "QTD PAGOS",		"@E 9,999,999",10)
		TRCell():New(oContrato,"TTPAGOS"	, "QRYCONTR", "TOT PAGOS", 		PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+1)

	Else

		oTitulos := TRSection():New(oContrato,"Detalhe",{"QRYCONTR"})
		oTitulos:SetHeaderPage(.F.)
		oTitulos:SetHeaderSection(.T.)
		oTitulos:SetTotalInLine(.F.)

		TRCell():New(oTitulos,"E1_PREFIXO"	,"QRYCONTR", "PREFIXO",			PesqPict("SE1","E1_PREFIXO"),TamSX3("E1_PREFIXO")[1]+1)
		TRCell():New(oTitulos,"E1_NUM"		,"QRYCONTR", "NUMERO",			PesqPict("SE1","E1_NUM")  	,TamSX3("E1_NUM")[1]+10)
		TRCell():New(oTitulos,"E1_PARCELA"	,"QRYCONTR", "PARCELA",			PesqPict("SE1","E1_PARCELA"),TamSX3("E1_PARCELA")[1]+1)
		TRCell():New(oTitulos,"E1_TIPO"		,"QRYCONTR", "TIPO",			PesqPict("SE1","E1_TIPO")	,TamSX3("E1_TIPO")[1]+15)
		TRCell():New(oTitulos,"E1_VALOR"	,"QRYCONTR", "VALOR",			PesqPict("SE1","E1_VALOR")	,TamSX3("E1_VALOR")[1]+10)
		TRCell():New(oTitulos,"E1_SALDO"	,"QRYCONTR", "SALDO",			PesqPict("SE1","E1_SALDO")	,TamSX3("E1_SALDO")[1]+10)
		TRCell():New(oTitulos,"E1_EMISSAO"	,"QRYCONTR", "DT EMISSAO",		PesqPict("SE1","E1_EMISSAO"),TamSX3("E1_EMISSAO")[1]+10)
		TRCell():New(oTitulos,"E1_VENCTO"	,"QRYCONTR", "DT VENCTO",		PesqPict("SE1","E1_VENCTO") ,TamSX3("E1_VENCTO")[1]+10)

		oSubtotal := TRSection():New(oTitulos,"SUBTOTAL",{})
		oSubtotal:SetHeaderPage(.F.)
		oSubtotal:SetHeaderSection(.T.)

		TRCell():New(oSubtotal,"NQTDAB",,"QTD TIT ABERTO", 	"@E 9,999,999",10)
		TRCell():New(oSubtotal,"NVLRAB",,"VLR TIT ABERTO",	PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+1)
		TRCell():New(oSubtotal,"NQTDPG",,"QTD TIT PAGO", 	"@E 9,999,999",10)
		TRCell():New(oSubtotal,"NVLRPG",,"VLR TIT PAGO",	PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+1)
	Endif

	oTotal := TRSection():New(oReport,"TOTAL GERAL",{})
	oTotal:SetHeaderPage(.F.)
	oTotal:SetHeaderSection(.T.)

	TRCell():New(oTotal,"NTQTDAB",,"QTD GERAL TIT ABERTO", 		"@E 9,999,999",10)
	TRCell():New(oTotal,"NTVLRAB",,"VLR GERAL TIT ABERTO",		PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+1)
	TRCell():New(oTotal,"NTQTDPG",,"QTD GERAL TIT PAGO", 		"@E 9,999,999",10)
	TRCell():New(oTotal,"NTVLRPG",,"VLR GERAL TIT PAGO",		PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+1)
	TRCell():New(oTotal,"NTCLINEG",,"QTD CLI NEGATIVADO", 		"@E 9,999,999",10)
	TRCell():New(oTotal,"NTCLINNEG",,"QTD CLI NAO NEGATIVADO", 	"@E 9,999,999",10)

Return(oReport)

/*/{Protheus.doc} PrintReport
// Inicia Logica Print Report
@author André R. Barrero
@since 02/09/2016
@history 20/05/2020, g.sampaio, Issue VPDV-467 - Alterado o uso da tabela UG0 (Apontamento de serviços antigo) 
para a o uso da tabela UJ0 (Apontamento de serviços Mod.2)
/*/
Static Function PrintReport(oReport,oContrato,oTitulos,oSubtotal,oTotal)

	Local cQry 		:= ""
	Local nCont		:= 0

	Local nQtdAb	:= 0
	Local nVlrAb	:= 0
	Local nQtdPg	:= 0
	Local nVlrPg	:= 0

	Local nTQtdAb	:= 0
	Local nTVlrAb	:= 0
	Local nTQtdPg	:= 0
	Local nTVlrPg	:= 0
	Local aTotNeg	:= {}
	Local aTotNNeg	:= {}

	If Select("QRYCONTR") > 0
		QRYCONTR->(dbCloseArea())
	EndIf

	cQry := "SELECT UF2.UF2_FILIAL, UF2.UF2_CODIGO, UF2.UF2_CLIENT, UF2.UF2_LOJA, SA1.A1_NOME, SA1.A1_XCLINEG, SE1.E1_XCTRFUN, SE1.E1_PREFIXO, SE1.E1_NUM,"
	cQry += " SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_VALOR, SE1.E1_SALDO, SE1.E1_EMISSAO, SE1.E1_VENCTO"
	cQry += " FROM "+RetSQLName("UF2")+" UF2 INNER JOIN "+RetSQLName("SE1")+" SE1	ON UF2.UF2_CODIGO	= SE1.E1_XCTRFUN"
	cQry += " 																		AND SE1.D_E_L_E_T_	<> '*'"
	cQry += "	 																	AND SE1.E1_FILIAL	= '"+xFilial("SE1")+"'"

	If !Empty(MV_PAR06)
		cQry += " 																		AND SE1.E1_EMISSAO 	>= '"+DToS(MV_PAR06)+"'"
	Endif
	If !Empty(MV_PAR07)
		cQry += " 																		AND SE1.E1_EMISSAO 	<= '"+DToS(MV_PAR07)+"'"
	Endif
	If !Empty(MV_PAR08)
		cQry += " 																		AND SE1.E1_VENCTO 	>= '"+DToS(MV_PAR08)+"'"
	Endif
	If !Empty(MV_PAR09)
		cQry += " 																		AND SE1.E1_VENCTO 	<= '"+DToS(MV_PAR09)+"'"
	Endif

	cQry += " INNER JOIN "+RetSQLName("SA1")+" SA1									ON UF2.UF2_CLIENT	= SA1.A1_COD"
	cQry += " 																		AND UF2.UF2_LOJA	= SA1.A1_LOJA
	cQry += " 																		AND SA1.D_E_L_E_T_	<> '*'"
	cQry += "	 																	AND SA1.A1_FILIAL	= '"+xFilial("SA1")+"'"

	If MV_PAR04 == 1 //Cliente Negativado = Sim
		cQry += " 																		AND SA1.A1_XCLINEG 	= 'S'"
	ElseIf MV_PAR04 == 2 //Cliente Negativado = Nao
		cQry += " 																		AND SA1.A1_XCLINEG 	= 'N'"
	Endif

	cQry += " WHERE UF2.D_E_L_E_T_	<> '*'"
	cQry += " AND UF2.UF2_FILIAL	= '"+xFilial("UF2")+"'"
	cQry += " AND UF2.UF2_CODIGO 	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"

	If !Empty(MV_PAR03)
		cQry += " AND UF2.UF2_STATUS	IN "+FormatIn(AllTrim(MV_PAR03),";")"
	Endif

	If MV_PAR10 == 1 //Serviço Realizado = Sim

		cQry += " AND UF2.UF2_FILIAL+UF2.UF2_CODIGO 	IN (SELECT UJ0.UJ0_FILIAL+UJ0.UJ0_CONTRA"
		cQry += " 											FROM "+RetSQLName("UJ0")+" UJ0"
		cQry += " 											WHERE UJ0.D_E_L_E_T_	<> '*'"
		cQry += " 											AND UJ0.UJ0_FILIAL		= '"+xFilial("UJ0")+"'"
		cQry += " 											AND UJ0.UJ0_CONTRA		= UF2.UF2_CODIGO)"

	ElseIf MV_PAR10 == 2 //Serviço Realizado = Nao

		cQry += " AND UF2.UF2_FILIAL+UF2.UF2_CODIGO NOT	IN (SELECT UJ0.UJ0_FILIAL+UJ0.UJ0_CONTRA"
		cQry += " 											FROM "+RetSQLName("UJ0")+" UJ0"
		cQry += " 											WHERE UJ0.D_E_L_E_T_	<> '*'"
		cQry += " 											AND UJ0.UJ0_FILIAL		= '"+xFilial("UJ0")+"'"
		cQry += " 											AND UJ0.UJ0_CONTRA		= UF2.UF2_CODIGO)"
	Endif

	cQry += " ORDER BY 1"

	cQry := ChangeQuery(cQry)
//MemoWrite("c:\temp\RFUNR001.txt",cQry)
	TCQUERY cQry NEW ALIAS "QRYCONTR"

	QRYCONTR->(dbEval({|| nCont++}))
	QRYCONTR->(dbGoTop())

	oReport:SetMeter(nCont)

	If MV_PAR11 == 2 //Sintético
		oContrato:Init()
	Endif

	While !oReport:Cancel() .And. QRYCONTR->(!EOF())

		If oReport:Cancel()
			Exit
		EndIf

		If QRYCONTR->A1_XCLINEG == "S" //Cliente negativado

			If Len(aTotNeg) == 0
				AAdd(aTotNeg,{QRYCONTR->UF2_CLIENT,QRYCONTR->UF2_LOJA})
			Else
				If aScan(aTotNeg,{|x| x[1] == QRYCONTR->UF2_CLIENT .And. x[2] == QRYCONTR->UF2_LOJA}) == 0
					AAdd(aTotNeg,{QRYCONTR->UF2_CLIENT,QRYCONTR->UF2_LOJA})
				Endif
			Endif
		Else

			If Len(aTotNNeg) == 0
				AAdd(aTotNNeg,{QRYCONTR->UF2_CLIENT,QRYCONTR->UF2_LOJA})
			Else
				If aScan(aTotNNeg,{|x| x[1] == QRYCONTR->UF2_CLIENT .And. x[2] == QRYCONTR->UF2_LOJA}) == 0
					AAdd(aTotNNeg,{QRYCONTR->UF2_CLIENT,QRYCONTR->UF2_LOJA})
				Endif
			Endif
		Endif

		If MV_PAR11 == 1 //Analítico

			oContrato:Init()
			oTitulos:Init()
			oSubtotal:Init()
		Endif

		cContrato := QRYCONTR->UF2_CODIGO

		nQtdAb	:= 0
		nVlrAb	:= 0
		nQtdPg	:= 0
		nVlrPg	:= 0

		oContrato:Cell("UF2_CODIGO"):SetValue(QRYCONTR->UF2_CODIGO)
		oContrato:Cell("UF2_CLIENT"):SetValue(QRYCONTR->UF2_CLIENT)
		oContrato:Cell("UF2_LOJA"):SetValue(QRYCONTR->UF2_LOJA)
		oContrato:Cell("A1_NOME"):SetValue(QRYCONTR->A1_NOME)
		oContrato:Cell("A1_XCLINEG"):SetValue(IIF(Empty(QRYCONTR->A1_XCLINEG) .Or. QRYCONTR->A1_XCLINEG == "N","NAO","SIM"))

		If MV_PAR11 == 1 //Analítico
			oContrato:PrintLine()
		Endif

		While QRYCONTR->(!EOF()) .And. cContrato == QRYCONTR->E1_XCTRFUN

			oReport:IncMeter()

			If oReport:Cancel()
				Exit
			EndIf

			If MV_PAR11 == 1 //Analítico

				oTitulos:Cell("E1_PREFIXO"):SetValue(QRYCONTR->E1_PREFIXO)
				oTitulos:Cell("E1_NUM"):SetValue(QRYCONTR->E1_NUM)
				oTitulos:Cell("E1_PARCELA"):SetValue(QRYCONTR->E1_PARCELA)
				oTitulos:Cell("E1_TIPO"):SetValue(QRYCONTR->E1_TIPO)
				oTitulos:Cell("E1_VALOR"):SetValue(QRYCONTR->E1_VALOR)
				oTitulos:Cell("E1_SALDO"):SetValue(QRYCONTR->E1_SALDO)
				oTitulos:Cell("E1_EMISSAO"):SetValue(DToC(SToD(QRYCONTR->E1_EMISSAO)))
				oTitulos:Cell("E1_VENCTO"):SetValue(DToC(SToD(QRYCONTR->E1_VENCTO)))

				oTitulos:PrintLine()
			Endif

			If QRYCONTR->E1_SALDO < QRYCONTR->E1_VALOR

				nQtdPg++
				nVlrPg	+= RetVlrPg(QRYCONTR->E1_PREFIXO,QRYCONTR->E1_NUM,QRYCONTR->E1_PARCELA,QRYCONTR->E1_TIPO)
			Else

				nQtdAb++
				nVlrAb	+= QRYCONTR->E1_VALOR
			Endif

			QRYCONTR->(DbSkip())
		EndDo

		If MV_PAR11 == 2 //Sintético

			oContrato:Cell("QTDABERTO"):SetValue(nQtdAb)
			oContrato:Cell("TTABERTO"):SetValue(nVlrAb)
			oContrato:Cell("QTDPAGOS"):SetValue(nQtdPg)
			oContrato:Cell("TTPAGOS"):SetValue(nVlrPg)

			oContrato:PrintLine()

		Else
			oSubtotal:Cell("NQTDAB"):SetValue(nQtdAb)
			oSubtotal:Cell("NVLRAB"):SetValue(nVlrAb)
			oSubtotal:Cell("NQTDPG"):SetValue(nQtdPg)
			oSubtotal:Cell("NVLRPG"):SetValue(nVlrPg)

			oSubtotal:PrintLine()

			oSubTotal:Finish()
			oTitulos:Finish()
			oContrato:Finish()
		Endif

		nTQtdPg += nQtdPg
		nTVlrPg	+= nVlrPg
		nTQtdAb += nQtdAb
		nTVlrAb += nVlrAb

		QRYCONTR->(DbSkip())
	EndDo

	If MV_PAR11 == 2 //Sintético
		oContrato:Finish()
	Endif

	oTotal:Init()

	oTotal:Cell("NTQTDAB"):SetValue(nTQtdAb)
	oTotal:Cell("NTVLRAB"):SetValue(nTVlrAb)
	oTotal:Cell("NTQTDPG"):SetValue(nTQtdPg)
	oTotal:Cell("NTVLRPG"):SetValue(nTVlrPg)
	oTotal:Cell("NTCLINEG"):SetValue(Len(aTotNeg))
	oTotal:Cell("NTCLINNEG"):SetValue(Len(aTotNNeg))

	oTotal:PrintLine()

	oTotal:Finish()

	If Select("QRYCONTR") > 0
		QRYCONTR->(dbCloseArea())
	EndIf

Return

/*********************************************/
Static Function RetVlrPg(cPref,cNum,cParc,cTp)
/*********************************************/

	Local nRet := 0

	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	cQry := " SELECT "
	cQry += " BAIXAS.VALOR AS VALOR_BAIXADO, "
	cQry += " ESTORNOS.VALOR AS VALOR_ESTORNO, "
	cQry += " (BAIXAS.VALOR - ESTORNOS.VALOR) AS VALOR_PAGO "
	cQry += " FROM "
	cQry += " ( "
	cQry += "	SELECT "
	cQry += "	'BAIXA' AS TIPO, "
	cQry += "	SUM(SE5.E5_VALOR) AS VALOR "
	cQry += "  	FROM "
	cQry += " 	" + RetSqlName("SE5") + " SE5 "
	cQry += "  	INNER JOIN "
	cQry += " 	" + RetSqlName("SE1") + " SE1 "
	cQry += "  	ON SE1.D_E_L_E_T_ 	<> '*' "
	cQry += " 	AND SE1.E1_FILIAL 	= '" + xFilial("SE1") + "' "
	cQry += "  	AND SE5.E5_PREFIXO  = SE1.E1_PREFIXO "
	cQry += "  	AND SE5.E5_NUMERO 	= SE1.E1_NUM "
	cQry += "  	AND SE5.E5_PARCELA  = SE1.E1_PARCELA "
	cQry += "  	AND SE5.E5_TIPO 	= SE1.E1_TIPO "
	cQry += "  	AND SE1.E1_PREFIXO 	= '"+cPref+"'"
	cQry += "  	AND SE1.E1_NUM 		= '"+cNum+"' "
	cQry += "  	AND SE1.E1_PARCELA 	= '"+cParc+"' "
	cQry += "  	AND SE1.E1_TIPO 	= '"+cTp+"' "
	cQry += "  	WHERE "
	cQry += "  	SE5.D_E_L_E_T_ 		<> '*' "
	cQry += " 	AND SE5.E5_FILIAL 	= '" + xFilial("SE5") + "' "
	cQry += "  	AND E5_TIPODOC 		= 'VL' "
	cQry += " ) AS BAIXAS, "
	cQry += " ( "
	cQry += "  	SELECT "
	cQry += "  	'ESTORNO' AS TIPO, "
	cQry += "  	SUM(SE5.E5_VALOR) AS VALOR "
	cQry += "  	FROM "
	cQry += " 	" + RetSqlName("SE5") + " SE5 "
	cQry += "  	INNER JOIN "
	cQry += " 	" + RetSqlName("SE1") + " SE1 "
	cQry += "  	ON SE1.D_E_L_E_T_ 	<> '*' "
	cQry += " 	AND SE1.E1_FILIAL 	= '" + xFilial("SE1") + "' "
	cQry += "  	AND SE5.E5_PREFIXO  = SE1.E1_PREFIXO "
	cQry += "  	AND SE5.E5_NUMERO 	= SE1.E1_NUM "
	cQry += "  	AND SE5.E5_PARCELA  = SE1.E1_PARCELA "
	cQry += "  	AND SE5.E5_TIPO 	= SE1.E1_TIPO "
	cQry += "  	AND SE1.E1_PREFIXO 	= '"+cPref+"'"
	cQry += "  	AND SE1.E1_NUM 		= '"+cNum+"' "
	cQry += "  	AND SE1.E1_PARCELA 	= '"+cParc+"' "
	cQry += "  	AND SE1.E1_TIPO 	= '"+cTp+"' "
	cQry += "  	WHERE "
	cQry += "  	SE5.D_E_L_E_T_ 		<> '*' "
	cQry += " 	AND SE5.E5_FILIAL 	= '" + xFilial("SE5") + "' "
	cQry += "  	AND E5_TIPODOC 		= 'ES' "
	cQry += " ) AS ESTORNOS "

	cQry := ChangeQuery(cQry)
	TcQuery cQry New Alias "QRY"

	if QRY->(!Eof())
		nRet := QRY->VALOR_BAIXADO - QRY->VALOR_ESTORNO
	endif

	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

Return nRet