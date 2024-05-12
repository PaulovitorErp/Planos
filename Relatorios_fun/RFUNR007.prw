#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} RFUNR007
Relatório Posição Financeira por Contrato (Receita x Despesa)
@author TOTVS
@since 28/09/2016
@version P12
@param nulo
@return nulo
@history 20/05/2020, g.sampaio, manutencao na função PrintReport e ReportDef
/*/

/***********************/
User Function RFUNR007()
/***********************/

	Local oReport
	Local cPerg := "RFUNR007"

	U_xPutSX1(cPerg,"01","Contrato De				?","","","mv_ch1","C",06,0,0,"G","","UF2","","","mv_par01","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"02","Contrato Ate				?","","","mv_ch2","C",06,0,0,"G","","UF2","","","mv_par02","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"03","Cliente De				?","","","mv_ch3","C",06,0,0,"G","","SA1","","","mv_par03","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"04","Loja De					?","","","mv_ch4","C",02,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"05","Cliente Ate				?","","","mv_ch5","C",06,0,0,"G","","SA1","","","mv_par05","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"06","Loja Ate					?","","","mv_ch6","C",02,0,0,"G","","","","","mv_par06","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"07","Dt Contrato De			?","","","mv_ch7","D",08,0,0,"G","","","","","mv_par07","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"08","Dt Contrato Ate			?","","","mv_ch8","D",08,0,0,"G","","","","","mv_par08","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"09","Plano De					?","","","mv_ch9","C",06,0,0,"G","","UF0","","","mv_par09","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"10","Plano Ate				?","","","mv_ch10","C",06,0,0,"G","","UF0","","","mv_par10","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"11","Emissao NF De			?","","","mv_ch11","D",08,0,0,"G","","","","","mv_par11","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"12","Emissao NF Ate			?","","","mv_ch12","D",08,0,0,"G","","","","","mv_par12","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"13","Dt Parcela Contr. De		?","","","mv_ch13","D",08,0,0,"G","","","","","mv_par13","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"14","Dt Parcela Contr. Ate	?","","","mv_ch14","D",08,0,0,"G","","","","","mv_par14","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	U_xPutSX1(cPerg,"15","Tipo                 	?","","","mv_ch15","C",1,0,1,"C","","","","","mv_par15","Analitico","","","","Sintetico","","","","","","","","","","","",{"",""},{"",""},{"",""})

	Pergunte(cPerg,.T.)
	oReport := ReportDef()
	oReport:PrintDialog()
	oReport:SetParam()

Return()

/*/{Protheus.doc} ReportDef
faz o inicio do relatorio
@type function
@version 
@author TOTVS
@since 28/09/2016
@return objetct, retorna o objeto de impressao
@history 20/05/2020, g.sampaio, VPDV-468 - Feito ajuste na declaração das variaveis
/*/
/**************************/
Static Function ReportDef()
/**************************/

	Local cTitle    := "Comparativo das receitas e despesas do contrato, possibilitando identificar o “ganho” sobre o mesmo."	
	Local oReport	:= Nil
	Local oSection1	:= Nil 
	Local oSection2	:= Nil 
	Local oSection3	:= Nil 
	Local oSection4	:= Nil
	
	oReport:= TReport():New("RFUNR007",cTitle,"RFUNR007",{|oReport| PrintReport(oReport,oSection1,oSection2,oSection3,oSection4)},"Este relatório apresenta o comparativo das receitas e despesas do contrato, possibilitando identificar o “ganho” sobre o mesmo.")
	oReport:SetPortrait()
	oReport:HideParamPage()
	oReport:SetUseGC(.F.) //Desabilita o botão <Gestao Corporativa> do relatório

	oSection1 := TRSection():New(oReport,"Contratos",{"QRYCONTR"})
	oSection1:SetHeaderPage(.F.)
	oSection1:SetHeaderSection(.T.)
	
	If MV_PAR15 == 1 //Analítico
		oSection1:SetPageBreak(.T.)
	Endif

	TRCell():New(oSection1,"UF2_CODIGO"	,"QRYCONTR", "CONTRATO",		PesqPict("UF2","UF2_CODIGO"),TamSX3("UF2_CODIGO")[1]+1)
	TRCell():New(oSection1,"UF2_CLIENT"	,"QRYCONTR", "CLIENTE",			PesqPict("UF2","UF2_CLIENT"),TamSX3("UF2_CLIENT")[1]+1)
	TRCell():New(oSection1,"UF2_LOJA"	,"QRYCONTR", "LOJA", 			PesqPict("UF2","UF2_LOJA"),TamSX3("UF2_LOJA")[1]+1)
	TRCell():New(oSection1,"UF2_NOMCLI"	,"QRYCONTR", "NOME", 			PesqPict("UF2","UF2_NOMCLI"),TamSX3("UF2_NOMCLI")[1]+1)
	TRCell():New(oSection1,"UF2_DATA"	,"QRYCONTR", "DATA", 			PesqPict("UF2","UF2_DATA"),TamSX3("UF2_DATA")[1]+2)
	TRCell():New(oSection1,"VLRCONT"	,"", 		 "VALOR CONTRATO",	PesqPict("UF2","UF2_VALOR"),TamSX3("UF2_VALOR")[1]+1)

	If MV_PAR15 == 2 //Sintético

		TRCell():New(oSection1,"TOTRECEITA"	,, "TOTAL RECEITA",				PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+1)
		TRCell():New(oSection1,"TOTDESPESA"	,, "TOTAL DESPESA",				PesqPict("SF2","F2_VALMERC"),TamSX3("F2_VALMERC")[1]+1)
		TRCell():New(oSection1,"SALDO"		,, "SALDO",						PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+1)

		oSection2 := TRSection():New(oReport,"TOTAL GERAL",{})
		oSection2:SetHeaderPage(.F.)
		oSection2:SetHeaderSection(.T.)

		TRCell():New(oSection2,"TGRECEITA"	,, "TOTAL RECEITA",				PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+1)
		TRCell():New(oSection2,"TGDESPESA"	,, "TOTAL DESPESA",				PesqPict("SF2","F2_VALMERC"),TamSX3("F2_VALMERC")[1]+1)
		TRCell():New(oSection2,"TGSALDO"	,, "SALDO",						PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+1)
	Else
		oSection2 := TRSection():New(oSection1,"Serviços",{"QRYSRV"})
		oSection2:SetHeaderPage(.F.)
		oSection2:SetHeaderSection(.T.)

		TRCell():New(oSection2,"NOMEUTIL"	,"QRYSRV", "NOME",				PesqPict("SA1","A1_NOME"),TamSX3("A1_NOME")[1]+1)
		TRCell():New(oSection2,"D2_TOTAL"	,"QRYSRV", "VLR SERVICO",		PesqPict("SD2","D2_TOTAL"),TamSX3("D2_TOTAL")[1]+1)
		TRCell():New(oSection2,"D2_EMISSAO"	,"QRYSRV", "DT EMISSAO",		PesqPict("SD2","D2_EMISSAO"),TamSX3("F2_EMISSAO")[1]+2)

		oSection3 := TRSection():New(oSection1,"Subtotal",{})
		oSection3:SetHeaderPage(.F.)
		oSection3:SetHeaderSection(.T.)

		TRCell():New(oSection3,"TOTRECEITA"	,, "SUBTOTAL RECEITA",			PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+1)
		TRCell():New(oSection3,"TOTDESPESA"	,, "SUBTOTAL DESPESA",			PesqPict("SF2","F2_VALMERC"),TamSX3("F2_VALMERC")[1]+1)
		TRCell():New(oSection3,"SALDO"		,, "SALDO",						PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+1)

		oSection4 := TRSection():New(oReport,"TOTAL GERAL",{})
		oSection4:SetHeaderPage(.F.)
		oSection4:SetHeaderSection(.T.)

		TRCell():New(oSection4,"TGRECEITA"	,, "TOTAL RECEITA",				PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+1)
		TRCell():New(oSection4,"TGDESPESA"	,, "TOTAL DESPESA",				PesqPict("SF2","F2_VALMERC"),TamSX3("F2_VALMERC")[1]+1)
		TRCell():New(oSection4,"TGSALDO"	,, "SALDO",						PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1]+1)
	Endif

Return(oReport)

/*/{Protheus.doc} PrintReport
funcao para alimentar os dados do relatorio
@type function
@version 
@author TOTVS
@since 28/09/2016
@param oReport, object, objeto de impressao do relatorio
@param oSection1, object, objeto da secao 1 de contrato
@param oSection2, object, objeto da secao 2 de faturamento
@param oSection3, object, objeto da secao 3 de receita x despesa
@param oSection4, object, objeto da secao 4 de total receita x total despesa
@return Nil
@history 20/05/2020, g.sampaio, VPDV-468 - Alterado o uso da tabela UG0 (Apontamento de serviços antigo) 
para a o uso da tabela UJ0 (Apontamento de serviços Mod.2)
/*/
/***************************************************************************/
Static Function PrintReport(oReport,oSection1,oSection2,oSection3,oSection4)
/***************************************************************************/

	Local cQry			:= ""
	Local cQry2			:= ""
	Local nCont			:= 0

	Local nTotRec		:= 0
	Local nTotDesp 		:= 0

	Local nTGRec		:= 0
	Local nTGDesp 		:= 0

	If Select("QRYCONTR") > 0
		QRYCONTR->(DbCloseArea())
	Endif

	cQry := "SELECT DISTINCT UF2.UF2_CODIGO, UF2.UF2_CLIENT, UF2.UF2_LOJA, SA1.A1_NOME, UF2.UF2_DATA, UF2.UF2_VALOR, UF2.UF2_AGREOR"
	cQry += " FROM "+RetSqlName("UF2")+" UF2, "+RetSqlName("SA1")+" SA1"
	cQry += " WHERE UF2.D_E_L_E_T_ 	<> '*'"
	cQry += " AND SA1.D_E_L_E_T_ 	<> '*'"
	cQry += " AND UF2.UF2_FILIAL 	= '"+xFilial("UF2")+"'"
	cQry += " AND SA1.A1_FILIAL 	= '"+xFilial("SA1")+"'"
	cQry += " AND UF2.UF2_CLIENT	= SA1.A1_COD"
	cQry += " AND UF2.UF2_LOJA		= SA1.A1_LOJA"
	cQry += " AND UF2.UF2_CODIGO	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
	cQry += " AND UF2.UF2_CLIENT	BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"'"
	cQry += " AND UF2.UF2_LOJA		BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"'"

	If !Empty(MV_PAR07)
		cQry += " AND UF2.UF2_DATA		>= '"+DToS(MV_PAR07)+"'"
	Endif
	If !Empty(MV_PAR08)
		cQry += " AND UF2.UF2_DATA		<= '"+DToS(MV_PAR08)+"'"
	Endif

	cQry += " AND UF2.UF2_PLANO		BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'"

	cQry += " ORDER BY 1"

	cQry := ChangeQuery(cQry)
	TcQuery cQry NEW Alias "QRYCONTR"

	QRYCONTR->(dbEval({|| nCont++}))
	QRYCONTR->(dbGoTop())

	oReport:SetMeter(nCont)

	If MV_PAR15 == 2 //Sintético
		oSection1:Init()
		oSection2:Init()
	Endif

	While !oReport:Cancel() .And. QRYCONTR->(!EOF())

		oReport:IncMeter()

		If oReport:Cancel()
			Exit
		EndIf

		If MV_PAR15 == 1 //Analítico
			oSection1:Init()
			oSection2:Init()
			oSection3:Init()
		Endif

		nTotDesp := 0

		oSection1:Cell("UF2_CODIGO"):SetValue(QRYCONTR->UF2_CODIGO)
		oSection1:Cell("UF2_CLIENT"):SetValue(QRYCONTR->UF2_CLIENT)
		oSection1:Cell("UF2_LOJA"):SetValue(QRYCONTR->UF2_LOJA)
		oSection1:Cell("UF2_NOMCLI"):SetValue(QRYCONTR->A1_NOME)
		oSection1:Cell("UF2_DATA"):SetValue(DToC(SToD(QRYCONTR->UF2_DATA)))
		oSection1:Cell("VLRCONT"):SetValue(QRYCONTR->UF2_VALOR + QRYCONTR->UF2_AGREOR)

		If MV_PAR15 == 1 //Analítico
			oSection1:PrintLine()
		Endif

		If Select("QRYSRV") > 0
			QRYSRV->(DbCloseArea())
		Endif

		cQry2 := "SELECT UF4.UF4_NOME, SUM(SD2.D2_TOTAL) AS D2_TOTAL, SD2.D2_EMISSAO"
		cQry2 += " FROM "+RetSqlName("SD2")+" SD2, "+RetSqlName("SC5")+" SC5, "+RetSqlName("UJ0")+" UJ0, "+RetSqlName("UF4")+" UF4"
		cQry2 += " WHERE SD2.D_E_L_E_T_ <> '*'"
		cQry2 += " AND SC5.D_E_L_E_T_ 	<> '*'"
		cQry2 += " AND UJ0.D_E_L_E_T_ 	<> '*'"
		cQry2 += " AND UF4.D_E_L_E_T_ 	<> '*'"
		cQry2 += " AND SD2.D2_FILIAL 	= '"+xFilial("SD2")+"'"
		cQry2 += " AND SC5.C5_FILIAL 	= '"+xFilial("SC5")+"'"
		cQry2 += " AND UJ0.UJ0_FILIAL 	= '"+xFilial("UJ0")+"'"
		cQry2 += " AND UF4.UF4_FILIAL 	= '"+xFilial("UF4")+"'"
		cQry2 += " AND SD2.D2_PEDIDO	= SC5.C5_NUM"
		cQry2 += " AND SC5.C5_XAPTOFU	= UJ0.UJ0_CODIGO"
		cQry2 += " AND UJ0.UJ0_CONTRA	= UF4.UF4_CODIGO"
		cQry2 += " AND UJ0.UJ0_CODBEN	= UF4.UF4_ITEM"
		cQry2 += " AND SC5.C5_XCTRFUN	= '"+QRYCONTR->UF2_CODIGO+"'"

		If !Empty(MV_PAR11)
			cQry2 += " AND SD2.D2_EMISSAO	>= '"+DToS(MV_PAR11)+"'"
		Endif
		If !Empty(MV_PAR12)
			cQry2 += " AND SD2.D2_EMISSAO	<= '"+DToS(MV_PAR12)+"'"
		Endif

		cQry2 += " GROUP BY UF4.UF4_NOME, SD2.D2_EMISSAO"
		cQry2 += " ORDER BY 1"

		cQry2 := ChangeQuery(cQry2)
		TcQuery cQry2 NEW Alias "QRYSRV"

		While !oReport:Cancel() .And. QRYSRV->(!EOF())

			If oReport:Cancel()
				Exit
			EndIf

			If MV_PAR15 == 1 //Analítico

				oSection2:Cell("NOMEUTIL"):SetValue(QRYSRV->UF4_NOME)
				oSection2:Cell("D2_TOTAL"):SetValue(QRYSRV->D2_TOTAL)
				oSection2:Cell("D2_EMISSAO"):SetValue(DToC(SToD(QRYSRV->D2_EMISSAO)))

				oSection2:PrintLine()
			Endif

			nTotDesp += QRYSRV->D2_TOTAL

			QRYSRV->(dbSkip())
		EndDo

		nTGDesp	+= nTotDesp
		nTotRec	:= RetRec(QRYCONTR->UF2_CODIGO)
		nTGRec	+= nTotRec

		If MV_PAR15 == 1 //Analítico
			oSection3:Cell("TOTRECEITA"):SetValue(nTotRec)
			oSection3:Cell("TOTDESPESA"):SetValue(nTotDesp)
			oSection3:Cell("SALDO"):SetValue(nTotRec - nTotDesp)

			oSection3:PrintLine()
		Else
			oSection1:Cell("TOTRECEITA"):SetValue(nTotRec)
			oSection1:Cell("TOTDESPESA"):SetValue(nTotDesp)
			oSection1:Cell("SALDO"):SetValue(nTotRec - nTotDesp)

			oSection1:PrintLine()
		Endif

		If MV_PAR15 == 1 //Analítico
			oSection1:Finish()
			oSection2:Finish()
			oSection3:Finish()
		Endif

		QRYCONTR->(dbSkip())
	EndDo

	If MV_PAR15 == 1 //Analítico

		oSection4:Init()

		oSection4:Cell("TGRECEITA"):SetValue(nTGRec)
		oSection4:Cell("TGDESPESA"):SetValue(nTGDesp)
		oSection4:Cell("TGSALDO"):SetValue(nTGRec - nTGDesp)

		oSection4:PrintLine()

		oSection4:Finish()
	Else
		oSection1:Finish()
		oSection2:Init()

		oSection2:Cell("TGRECEITA"):SetValue(nTGRec)
		oSection2:Cell("TGDESPESA"):SetValue(nTGDesp)
		oSection2:Cell("TGSALDO"):SetValue(nTGRec - nTGDesp)

		oSection2:PrintLine()

		oSection2:Finish()
	Endif

	If Select("QRYSRV") > 0
		QRYSRV->(DbCloseArea())
	Endif

	If Select("QRYCONTR") > 0
		QRYCONTR->(DbCloseArea())
	Endif

Return(Nil)

/*/{Protheus.doc} RetRec
retorna receita do contrato
@type function
@version 
@author TOTVS
@since 28/09/2016
@param cContrato, character, codigo do contrato
@return nRet, retorna a receita do contrato
@history 20/05/2020, g.sampaio, VPDV-468 - Criado cabecalho da funcao, 
ajustes na declaração das variáveis e retorno da função
/*/
/********************************/
Static Function RetRec(cContrato)
/********************************/

	Local cQry			:= ""
	Local nRet 			:= 0

	Default	cContrato	:= '"'

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
	cQry += " 	AND SE1.E1_XCTRFUN 	= '" + cContrato + "' "
	cQry += "  	AND SE5.E5_PREFIXO  = SE1.E1_PREFIXO "
	cQry += "  	AND SE5.E5_NUMERO 	= SE1.E1_NUM "
	cQry += "  	AND SE5.E5_PARCELA  = SE1.E1_PARCELA "
	cQry += "  	AND SE5.E5_TIPO 	= SE1.E1_TIPO "
	cQry += "  	WHERE "
	cQry += "  	SE5.D_E_L_E_T_ 		<> '*' "
	cQry += " 	AND SE5.E5_FILIAL 	= '" + xFilial("SE5") + "' "
	cQry += "  	AND E5_TIPODOC 		= 'VL' "

	If !Empty(MV_PAR11)
		cQry += " AND SE1.E1_EMISSAO	>= '"+DToS(MV_PAR13)+"'"
	Endif
	If !Empty(MV_PAR12)
		cQry += " AND SE1.E1_EMISSAO	<= '"+DToS(MV_PAR14)+"'"
	Endif

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
	cQry += " 	AND SE1.E1_XCTRFUN 	= '" + cContrato + "' "
	cQry += "  	AND SE5.E5_PREFIXO  = SE1.E1_PREFIXO "
	cQry += "  	AND SE5.E5_NUMERO 	= SE1.E1_NUM "
	cQry += "  	AND SE5.E5_PARCELA  = SE1.E1_PARCELA "
	cQry += "  	AND SE5.E5_TIPO 	= SE1.E1_TIPO "

	If !Empty(MV_PAR11)
		cQry += " AND SE1.E1_EMISSAO	>= '"+DToS(MV_PAR13)+"'"
	Endif
	If !Empty(MV_PAR12)
		cQry += " AND SE1.E1_EMISSAO	<= '"+DToS(MV_PAR14)+"'"
	Endif

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

Return(nRet)