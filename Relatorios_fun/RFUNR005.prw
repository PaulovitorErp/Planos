#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} RFUNR005
Relatório de Evolução de Valores
@author TOTVS
@since 22/09/2016
@version P12
@param nulo
@return nulo
/*/

/***********************/
User Function RFUNR005()
/***********************/

Local oReport
Local cPerg := "RFUNR005"

U_xPutSX1(cPerg,"01","Contrato De		?","","","mv_ch1","C",06,0,0,"G","","UF2","","","mv_par01","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
U_xPutSX1(cPerg,"02","Contrato Ate		?","","","mv_ch2","C",06,0,0,"G","","UF2","","","mv_par02","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
U_xPutSX1(cPerg,"03","Status			?","","","mv_ch3","C",10,0,0,"G","","STFUN","","","mv_par03","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
U_xPutSX1(cPerg,"04","Dt Reajuste De	?","","","mv_ch4","D",08,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
U_xPutSX1(cPerg,"05","Dt Reajuste Ate	?","","","mv_ch5","D",08,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
U_xPutSX1(cPerg,"06","Tipo             ?","","","mv_ch6","C",01,0,1,"C","","","","","mv_par06","Analitico","","","","Sintetico","","","","","","","","","","","",{"",""},{"",""},{"",""})

Pergunte(cPerg,.T.)
oReport:= ReportDef()
oReport:PrintDialog()
oReport:SetParam()

Return

/**************************/
Static Function ReportDef()
/**************************/

Local oReport

Local oSection1, oSection2, oSection3, oSection4

Local cTitle    := "Visualização da evolução dos valores dos contratos através dos reajustes realizados."
Local nTamSX1   := 10

oReport:= TReport():New("RFUNR005",cTitle,"RFUNR005",{|oReport| PrintReport(oReport,oSection1,oSection2,oSection3,oSection4)},"Este relatório apresenta a evolução dos valores dos contratos através dos reajustes realizados.")
oReport:SetPortrait()   
oReport:HideParamPage()
oReport:SetUseGC(.F.) //Desabilita o botão <Gestao Corporativa> do relatório

oSection1 := TRSection():New(oReport,"Contratos",{"QRYCONTR"})
oSection1:SetHeaderPage(.F.)
oSection1:SetHeaderSection(.T.)
oSection1:SetPageBreak(.T.)

TRCell():New(oSection1,"UF2_CODIGO"	,"QRYCONTR", "CONTRATO",		PesqPict("UF2","UF2_CODIGO"),TamSX3("UF2_CODIGO")[1]+1)
TRCell():New(oSection1,"UF2_CLIENT"	,"QRYCONTR", "CLIENTE",			PesqPict("UF2","UF2_CLIENT"),TamSX3("UF2_CLIENT")[1]+1)
TRCell():New(oSection1,"UF2_LOJA"	,"QRYCONTR", "LOJA", 			PesqPict("UF2","UF2_LOJA"),TamSX3("UF2_LOJA")[1]+1)
TRCell():New(oSection1,"UF2_NOMCLI"	,"QRYCONTR", "NOME", 			PesqPict("UF2","UF2_NOMCLI"),TamSX3("UF2_NOMCLI")[1]+1)
TRCell():New(oSection1,"UF2_DATA"	,"QRYCONTR", "DATA", 			PesqPict("UF2","UF2_DATA"),TamSX3("UF2_DATA")[1]+2)

If MV_PAR06 == 2 //Sintético

	TRCell():New(oSection1,"VLRORICONT"	,"", 		 "VLR ORIGINAL",		PesqPict("UF2","UF2_VALOR"),TamSX3("UF2_VALOR")[1]+1)
	TRCell():New(oSection1,"VLRATUCONT"	,"", 		 "VLR ATUAL",			PesqPict("UF2","UF2_VALOR"),TamSX3("UF2_VALOR")[1]+1)
	TRCell():New(oSection1,"VLREVOCONT"	,"", 		 "VLR EVOLUCAO",		PesqPict("UF2","UF2_VALOR"),TamSX3("UF2_VALOR")[1]+1)
	TRCell():New(oSection1,"PERCEVOLUC"	,"", 		 "% EVOLUCAO",			PesqPict("UF7","UF7_INDICE"),TamSX3("UF7_INDICE")[1]+1)

	oSection2 := TRSection():New(oReport,"TOTAL GERAL",{})
	oSection2:SetHeaderPage(.F.)
	oSection2:SetHeaderSection(.T.)
	
	TRCell():New(oSection2,"TVLRCONTOR"	,, "TOT ORI CONTRATO",	PesqPict("UF2","UF2_VALOR"),TamSX3("UF2_VALOR")[1]+1)
	TRCell():New(oSection2,"TVLRCONTRE"	,, "TOT ATU CONTRATO",	PesqPict("UF2","UF2_VALOR"),TamSX3("UF2_VALOR")[1]+1)
	TRCell():New(oSection2,"TVLREVOLUC"	,, "TOT EVOLUCAO",		PesqPict("UF2","UF2_VALOR"),TamSX3("UF2_VALOR")[1]+1)
	TRCell():New(oSection2,"TPERCEVOLU"	,, "MEDIA % EVOLUCAO",	PesqPict("UF7","UF7_INDICE"),TamSX3("UF7_INDICE")[1]+1)

Else
	oSection2 := TRSection():New(oSection1,"Reajustes",{"QRYREAJ"})
	oSection2:SetHeaderPage(.F.)
	oSection2:SetHeaderSection(.T.)
	
	TRCell():New(oSection2,"UF7_DATA"	,"QRYREAJ", "DATA",				PesqPict("UF7","UF7_DATA"),TamSX3("UF7_DATA")[1]+2)
	TRCell():New(oSection2,"UF7_VLADIC"	,"QRYREAJ", "VLR ADICIONADO",	PesqPict("UF7","UF7_VLADIC"),TamSX3("UF7_VLADIC")[1]+1)
	TRCell():New(oSection2,"UF7_INDICE"	,"QRYREAJ", "% REAJUSTE",		PesqPict("UF7","UF7_INDICE"),TamSX3("UF7_INDICE")[1]+1)
	TRCell():New(oSection2,"UF7_DESCIN"	,"QRYREAJ", "INDICE",			PesqPict("UF7","UF7_DESCIN"),TamSX3("UF7_DESCIN")[1]+1)
	
	oSection3 := TRSection():New(oSection2,"Subtotal",{})
	oSection3:SetHeaderPage(.F.)
	oSection3:SetHeaderSection(.T.)
	
	TRCell():New(oSection3,"VLRCONTORI"	,, "VLR CONTRATO ORI",	PesqPict("UF2","UF2_VALOR"),TamSX3("UF2_VALOR")[1]+1)
	TRCell():New(oSection3,"VLRCONTREA"	,, "VLR CONTRATO REA",	PesqPict("UF2","UF2_VALOR"),TamSX3("UF2_VALOR")[1]+1)
	TRCell():New(oSection3,"VLREVOLUC"	,, "VLR EVOLUCAO",		PesqPict("UF2","UF2_VALOR"),TamSX3("UF2_VALOR")[1]+1)
	TRCell():New(oSection3,"PERCEVOLU"	,, "% EVOLUCAO",		PesqPict("UF7","UF7_INDICE"),TamSX3("UF7_INDICE")[1]+1)
	
	oSection4 := TRSection():New(oReport,"TOTAL GERAL",{})
	oSection4:SetHeaderPage(.F.)
	oSection4:SetHeaderSection(.T.)
	
	TRCell():New(oSection4,"TVLRCONTOR"	,, "TOT ORI CONTRATO",	PesqPict("UF2","UF2_VALOR"),TamSX3("UF2_VALOR")[1]+1)
	TRCell():New(oSection4,"TVLRCONTRE"	,, "TOT ATU CONTRATO",	PesqPict("UF2","UF2_VALOR"),TamSX3("UF2_VALOR")[1]+1)
	TRCell():New(oSection4,"TVLREVOLUC"	,, "TOT EVOLUCAO",		PesqPict("UF2","UF2_VALOR"),TamSX3("UF2_VALOR")[1]+1)
	TRCell():New(oSection4,"TPERCEVOLU"	,, "MEDIA % EVOLUCAO",	PesqPict("UF7","UF7_INDICE"),TamSX3("UF7_INDICE")[1]+1)
Endif

Return(oReport)                                                               

/***************************************************************************/
Static Function PrintReport(oReport,oSection1,oSection2,oSection3,oSection4)
/***************************************************************************/

Local cQry			:= ""
Local cQry2			:= ""
Local nCont			:= 0

Local nVlrContOr 	:= 0
Local nVlrContRe 	:= 0
Local nVlrEvoluc 	:= 0
Local nPercEvolu 	:= 0
Local nVlrAdic		:= 0

Local nTContOr		:= 0
Local nTContRe		:= 0
Local nTEvoluc		:= 0
Local nTPercEv		:= 0
Local nAux			:= 0

If Select("QRYCONTR") > 0
	QRYCONTR->(DbCloseArea())
Endif

cQry := "SELECT DISTINCT UF2.UF2_CODIGO, UF2.UF2_CLIENT, UF2.UF2_LOJA, SA1.A1_NOME, UF2.UF2_DATA, UF2.UF2_VALOR, UF2.UF2_AGREOR"
cQry += " FROM "+RetSqlName("UF2")+" UF2, "+RetSqlName("SA1")+" SA1, "+RetSqlName("UF7")+" UF7"
cQry += " WHERE UF2.D_E_L_E_T_ 	<> '*'"
cQry += " AND SA1.D_E_L_E_T_ 	<> '*'" 
cQry += " AND UF7.D_E_L_E_T_ 	<> '*'"
cQry += " AND UF2.UF2_FILIAL 	= '"+xFilial("UF2")+"'"
cQry += " AND SA1.A1_FILIAL 	= '"+xFilial("SA1")+"'"
cQry += " AND UF7.UF7_FILIAL 	= '"+xFilial("UF7")+"'"
cQry += " AND UF2.UF2_CLIENT	= SA1.A1_COD"
cQry += " AND UF2.UF2_LOJA		= SA1.A1_LOJA"
cQry += " AND UF2.UF2_CODIGO	= UF7.UF7_CONTRA"
cQry += " AND UF2.UF2_CODIGO	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
If !Empty(MV_PAR03)
	cQry += " AND UF2.UF2_STATUS	IN "+FormatIn(AllTrim(MV_PAR03),";")"
Endif
If !Empty(MV_PAR04)
	cQry += " AND UF7.UF7_DATA		>= '"+DToS(MV_PAR04)+"'"
Endif
If !Empty(MV_PAR05)
	cQry += " AND UF7.UF7_DATA		<= '"+DToS(MV_PAR05)+"'"
Endif
cQry += " ORDER BY 1"

cQry := ChangeQuery(cQry)
TcQuery cQry NEW Alias "QRYCONTR"

QRYCONTR->(dbEval({|| nCont++}))
QRYCONTR->(dbGoTop())

oReport:SetMeter(nCont)

If MV_PAR06 == 2 //Sintético
	oSection1:Init()
	oSection2:Init()
Endif

While !oReport:Cancel() .And. QRYCONTR->(!EOF())
	
	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf    

	If MV_PAR06 == 1 //Analítico
		oSection1:Init()
		oSection2:Init()
		oSection3:Init()
	Endif

	nVlrContOr 	:= 0
	nVlrContRe 	:= 0
	nVlrEvoluc 	:= 0
	nPercEvolu 	:= 0
	nVlrAdic	:= 0
	
	oSection1:Cell("UF2_CODIGO"):SetValue(QRYCONTR->UF2_CODIGO)
	oSection1:Cell("UF2_CLIENT"):SetValue(QRYCONTR->UF2_CLIENT)
	oSection1:Cell("UF2_LOJA"):SetValue(QRYCONTR->UF2_LOJA)
	oSection1:Cell("UF2_NOMCLI"):SetValue(QRYCONTR->A1_NOME)
	oSection1:Cell("UF2_DATA"):SetValue(DToC(SToD(QRYCONTR->UF2_DATA)))
	
	If MV_PAR06 == 1 //Analítico
		oSection1:PrintLine()
	Endif
		
	nVlrContOr	:= QRYCONTR->UF2_VALOR + QRYCONTR->UF2_AGREOR
	nTContOr	+= nVlrContOr
	
	If Select("QRYREAJ") > 0
		QRYREAJ->(DbCloseArea())
	Endif
	
	cQry2 := "SELECT UF7.UF7_DATA, UF7.UF7_VLADIC, UF7.UF7_INDICE, U22.U22_DESC"
	cQry2 += " FROM "+RetSqlName("UF7")+" UF7, "+RetSqlName("U22")+" U22"
	cQry2 += " WHERE UF7.D_E_L_E_T_ <> '*'"
	cQry2 += " AND U22.D_E_L_E_T_ 	<> '*'"
	cQry2 += " AND UF7.UF7_FILIAL 	= '"+xFilial("UF7")+"'"
	cQry2 += " AND U22.U22_FILIAL 	= '"+xFilial("U22")+"'"
	cQry2 += " AND UF7.UF7_TPINDI	= U22.U22_CODIGO"
	cQry2 += " AND UF7.UF7_CONTRA	= '"+QRYCONTR->UF2_CODIGO+"'"
	cQry2 += " ORDER BY 1"
	
	cQry2 := ChangeQuery(cQry2)
	TcQuery cQry2 NEW Alias "QRYREAJ"

	While !oReport:Cancel() .And. QRYREAJ->(!EOF())

		If oReport:Cancel()
			Exit
		EndIf   
		
		If MV_PAR06 == 1 //Analítico
			oSection2:Cell("UF7_DATA"):SetValue(DToC(SToD(QRYREAJ->UF7_DATA)))
			oSection2:Cell("UF7_VLADIC"):SetValue(QRYREAJ->UF7_VLADIC)
			oSection2:Cell("UF7_INDICE"):SetValue(QRYREAJ->UF7_INDICE)
			oSection2:Cell("UF7_DESCIN"):SetValue(QRYREAJ->U22_DESC)
					
			oSection2:PrintLine()
		Endif
		
		nVlrAdic += QRYREAJ->UF7_VLADIC
		
		QRYREAJ->(dbSkip())
	EndDo

	nVlrContRe	:= nVlrContOr + nVlrAdic
	nTContRe	+= nVlrContRe
	nVlrEvoluc	:= nVlrContRe - nVlrContOr
	nTEvoluc	+= nVlrEvoluc
	nPercEvolu	:= ((nVlrContRe / nVlrContOr) - 1 ) * 100
	nAux		+= nPercEvolu

	If MV_PAR06 == 1 //Analítico

		oSection3:Cell("VLRCONTORI"):SetValue(nVlrContOr)
		oSection3:Cell("VLRCONTREA"):SetValue(nVlrContRe)
		oSection3:Cell("VLREVOLUC"):SetValue(nVlrEvoluc)
		oSection3:Cell("PERCEVOLU"):SetValue(nPercEvolu)
	
		oSection3:PrintLine()
	Else
		oSection1:Cell("VLRORICONT"):SetValue(nVlrContOr)
		oSection1:Cell("VLRATUCONT"):SetValue(nVlrContRe)
		oSection1:Cell("VLREVOCONT"):SetValue(nVlrEvoluc)
		oSection1:Cell("PERCEVOLUC"):SetValue(nPercEvolu)

		oSection1:PrintLine()	
	Endif
	
	If MV_PAR06 == 1 //Analítico
		oSection1:Finish()
		oSection2:Finish()
		oSection3:Finish()
	Endif
	
	QRYCONTR->(dbSkip())
EndDo

If MV_PAR06 == 1 //Analítico

	oSection4:Init()
	
	oSection4:Cell("TVLRCONTOR"):SetValue(nTContOr)
	oSection4:Cell("TVLRCONTRE"):SetValue(nTContRe)
	oSection4:Cell("TVLREVOLUC"):SetValue(nTEvoluc)
	nTPercEv := nAux / nCont
	oSection4:Cell("TPERCEVOLU"):SetValue(nTPercEv)
	
	oSection4:PrintLine()
	
	oSection4:Finish()
Else
	oSection1:Finish()
	oSection2:Init()
	
	oSection2:Cell("TVLRCONTOR"):SetValue(nTContOr)
	oSection2:Cell("TVLRCONTRE"):SetValue(nTContRe)
	oSection2:Cell("TVLREVOLUC"):SetValue(nTEvoluc)
	nTPercEv := nAux / nCont
	oSection2:Cell("TPERCEVOLU"):SetValue(nTPercEv)
	
	oSection2:PrintLine()
	
	oSection2:Finish()	
Endif

If Select("QRYREAJ") > 0
	QRYREAJ->(DbCloseArea())
Endif
	
If Select("QRYCONTR") > 0
	QRYCONTR->(DbCloseArea())
Endif

Return

/********************/
User Function StFun()
/********************/

Local cTitulo	:= "Status de Contrato"
Local MvParDef	:= ""
Local MvRetor	:= ""      
Local cVarIni	:= ""
Local nX		:= 1
Local nTamCod	:= 1 //TamSX3("UF2_CODIGO")[1]
Local aDados	:= {}

cVarIni := &(Alltrim(ReadVar()))

AAdd(aDados, "P" + " - " + "Pré-cadastro")
MvParDef += "P"
AAdd(aDados, "A" + " - " + "Ativo")
MvParDef += "A"
AAdd(aDados, "S" + " - " + "Suspenso")
MvParDef += "S"
AAdd(aDados, "C" + " - " + "Cancelado")
MvParDef += "C"
AAdd(aDados, "F" + " - " + "Finalizado")
MvParDef += "F"

If F_Opcoes(@cVarIni, cTitulo, aDados, MvParDef, 12, 49, .F., nTamCod, 36)
	
	For nX := 1 To Len(cVarIni) Step nTamCod
	
		If substr(cVarIni, nX, nTamCod) # "*"
			
			If !Empty(MvRetor)
				MvRetor += ";"
			EndIf
			
			MvRetor += substr(cVarIni,nX,nTamCod)
		EndIf
	Next nX
EndIf

&(ReadVar()) := MvRetor 

Return(.T.)
