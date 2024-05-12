#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} RFUNR009
Relatório de Serviços Executados
@author TOTVS
@since 05/10/2016
@version P12
@param nulo
@return nulo
/*/

/***********************/
User Function RFUNR009()
/***********************/

Local oReport

oReport:= ReportDef()
oReport:PrintDialog()

Return

/**************************/
Static Function ReportDef()
/**************************/

Local oReport

Local oSection1, oSection2

Local cTitle    := "Identifica os serviços executados."
Local nTamSX1   := Len(SX1->X1_GRUPO)

oReport:= TReport():New("RFUNR009",cTitle,"RFUNR009",{|oReport| PrintReport(oReport,oSection1,oSection2)},"Este relatório identifica os serviços executados.")
oReport:SetPortrait()   
oReport:HideParamPage()
oReport:SetUseGC(.F.) //Desabilita o botão <Gestao Corporativa> do relatório

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Ajusta grupo de perguntas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
dbSelectArea("SX1")
If dbSeek(PADR("RFUNR009",nTamSX1)+"01") .And. X1_GSC == "C"
	Reclock("SX1",.f.)
	dbDelete()
	MsUnlock()
EndIf	
If dbSeek(PADR("RFUNR009",nTamSX1)+"02") .And. X1_GSC == "C"
	Reclock("SX1",.f.)
	dbDelete()
	MsUnlock()
EndIf
If dbSeek(PADR("RFUNR009",nTamSX1)+"03") .And. X1_GSC == "C"
	Reclock("SX1",.f.)
	dbDelete()
	MsUnlock()
EndIf
If dbSeek(PADR("RFUNR009",nTamSX1)+"04") .And. X1_GSC == "C"
	Reclock("SX1",.f.)
	dbDelete()
	MsUnlock()
EndIf                                 
If dbSeek(PADR("RFUNR009",nTamSX1)+"05") .And. X1_GSC == "C"
	Reclock("SX1",.f.)
	dbDelete()
	MsUnlock()
EndIf  
If dbSeek(PADR("RFUNR009",nTamSX1)+"06") .And. X1_GSC == "C"
	Reclock("SX1",.f.)
	dbDelete()
	MsUnlock()
EndIf     
If dbSeek(PADR("RFUNR009",nTamSX1)+"07") .And. X1_GSC == "C"
	Reclock("SX1",.f.)
	dbDelete()
	MsUnlock()
EndIf     
If dbSeek(PADR("RFUNR009",nTamSX1)+"08") .And. X1_GSC == "C"
	Reclock("SX1",.f.)
	dbDelete()
	MsUnlock()
EndIf     
If dbSeek(PADR("RFUNR009",nTamSX1)+"09") .And. X1_GSC == "C"
	Reclock("SX1",.f.)
	dbDelete()
	MsUnlock()
EndIf                                    

U_xPutSX1("RFUNR009","01","Cliente De","","","mv_ch1","C",06,0,0,"G","","SA1","","","mv_par01","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
U_xPutSX1("RFUNR009","02","Loja De","","","mv_ch2","C",02,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
U_xPutSX1("RFUNR009","03","Cliente Ate","","","mv_ch3","C",06,0,0,"G","","SA1","","","mv_par03","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
U_xPutSX1("RFUNR009","04","Loja Ate","","","mv_ch4","C",02,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
U_xPutSX1("RFUNR009","05","Emissao NF De","","","mv_ch5","D",08,0,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
U_xPutSX1("RFUNR009","06","Emissao NF Ate","","","mv_ch6","D",08,0,0,"G","","","","","mv_par06","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
U_xPutSX1("RFUNR009","07","Tipo de Serviço","","","mv_ch7","N",01,0,3,"C","","","","","mv_par07","Associado","","","","Particular","","","Ambos","","","","","","","","",{"",""},{"",""},{"",""})
U_xPutSX1("RFUNR009","08","Contrato De","","","mv_ch8","C",06,0,0,"G","","UF2","","","mv_par08","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
U_xPutSX1("RFUNR009","09","Contrato Ate","","","mv_ch9","C",06,0,0,"G","","UF2","","","mv_par09","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})

Pergunte(oReport:GetParam(),.F.)

oSection1 := TRSection():New(oReport,"Serviços",{"QRYSRV"})
oSection1:SetHeaderPage(.F.)
oSection1:SetHeaderSection(.T.)

TRCell():New(oSection1,"F2_CLIENTE"	,"QRYSRV", "CLIENTE",		PesqPict("SF2","F2_CLIENTE"),TamSX3("F2_CLIENTE")[1]+1)
TRCell():New(oSection1,"F2_LOJA"	,"QRYSRV", "LOJA",			PesqPict("SF2","F2_LOJA"),TamSX3("F2_LOJA")[1]+1)
TRCell():New(oSection1,"A1_NOME"	,"QRYSRV", "NOME", 			PesqPict("SA1","A1_NOME"),TamSX3("A1_NOME")[1]+1)
TRCell():New(oSection1,"F2_XCTRFUN"	,"QRYSRV", "CONTRATO",		PesqPict("SF2","F2_XCTRFUN"),TamSX3("F2_XCTRFUN")[1]+1)
TRCell():New(oSection1,"F2_DOC"		,"QRYSRV", "NF",			PesqPict("SF2","F2_DOC"),TamSX3("F2_DOC")[1]+1)
TRCell():New(oSection1,"F2_VALMERC"	,"QRYSRV", "VALOR NF",		PesqPict("SF2","F2_VALMERC"),TamSX3("F2_VALMERC")[1]+1)
TRCell():New(oSection1,"TIPO"		,"QRYSRV", "TIPO",			"@!",20)

oSection2 := TRSection():New(oReport,"TOTAL",{})
oSection2:SetHeaderPage(.F.)
oSection2:SetHeaderSection(.T.)

TRCell():New(oSection2,"TOTSRVPART"	,, "TOTAL SERV. PARTICULARES",	PesqPict("SF2","F2_VALMERC"),TamSX3("F2_VALMERC")[1]+1)
TRCell():New(oSection2,"QTDSRVPART"	,, "QTD. SERV. PARTICULARES",	"@E 9999",4)
TRCell():New(oSection2,"TOTSRVASSO"	,, "TOTAL SERV. ASSOCIADOS",	PesqPict("SF2","F2_VALMERC"),TamSX3("F2_VALMERC")[1]+1)
TRCell():New(oSection2,"QTDSRVASSO"	,, "QTD. SERV. ASSOCIADOS",		"@E 9999",4)

Return(oReport)                                                               

/*******************************************************/
Static Function PrintReport(oReport,oSection1,oSection2)
/*******************************************************/

Local cQry			:= ""
Local nCont			:= 0

Local nTotPart		:= 0
Local nQtdPart		:= 0
Local nTotAsso 		:= 0
Local nQtdAsso 		:= 0

Local lFin

If Select("QRYSRV") > 0
	QRYSRV->(DbCloseArea())
Endif

cQry := "SELECT 
cQry += " DISTINCT 
cQry += " SF2.F2_CLIENTE, 
cQry += " SF2.F2_LOJA, 
cQry += " SA1.A1_NOME, 
cQry += " SF2.F2_XCTRFUN, 
cQry += " SF2.F2_DOC, 
cQry += " SF2.F2_VALMERC"
cQry += " FROM "
cQry += RetSqlName("SF2") + " SF2
cQry += "  INNER JOIN  "
cQry += RetSQLName("SA1") + " SA1 "
cQry += " ON SF2.D_E_L_E_T_ 	= ' ' "
cQry += " AND SA1.D_E_L_E_T_ 	= ' ' "
cQry += " AND SF2.F2_FILIAL 	= '" + xFilial("SF2") + "' "
cQry += " AND SA1.A1_FILIAL 	= '" + xFilial("SA1") + "' "
cQry += " AND SF2.F2_CLIENTE	= SA1.A1_COD "
cQry += " AND SF2.F2_LOJA		= SA1.A1_LOJA "
cQry += "  INNER JOIN  "
cQry += RetSQLName("SC5") + " SC5 "
cQry += " ON SC5.D_E_L_E_T_ = ' ' " 
cQry += " AND SF2.F2_FILIAL = SC5.C5_FILIAL
cQry += " AND SF2.F2_SERIE = SC5.C5_SERIE 
cQry += " AND SF2.F2_DOC = SC5.C5_NOTA
cQry += " WHERE "
cQry += " SF2.F2_CLIENTE	BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR03 + "'"
cQry += " AND SF2.F2_LOJA		BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR04 + "'"

If !Empty(MV_PAR05)
	cQry += " AND SF2.F2_EMISSAO	>= '"+DToS(MV_PAR05)+"'"
Endif
If !Empty(MV_PAR06)
	cQry += " AND SF2.F2_EMISSAO	<= '"+DToS(MV_PAR06)+"'"
Endif

cQry += " AND SC5.C5_XCTRFUN		BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR09+"'"

cQry += " ORDER BY 1"

cQry := ChangeQuery(cQry)
TcQuery cQry NEW Alias "QRYSRV"

QRYSRV->(dbEval({|| nCont++}))
QRYSRV->(dbGoTop())

oReport:SetMeter(nCont)

oSection1:Init()
	
While !oReport:Cancel() .And. QRYSRV->(!EOF())
	
	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf    

	lFin := RetFin(QRYSRV->F2_DOC)
	
	If MV_PAR07 == 3 //Ambos

		oSection1:Cell("F2_CLIENTE"):SetValue(QRYSRV->F2_CLIENTE)
		oSection1:Cell("F2_LOJA"):SetValue(QRYSRV->F2_LOJA)
		oSection1:Cell("A1_NOME"):SetValue(QRYSRV->A1_NOME)
		oSection1:Cell("F2_XCTRFUN"):SetValue(QRYSRV->F2_XCTRFUN)
		oSection1:Cell("F2_DOC"):SetValue(QRYSRV->F2_DOC)
		oSection1:Cell("F2_VALMERC"):SetValue(QRYSRV->F2_VALMERC)
	
		If lFin
			oSection1:Cell("TIPO"):SetValue("PARTICULAR")
			nTotPart += QRYSRV->F2_VALMERC
			nQtdPart++
		Else
			If !Empty(QRYSRV->F2_XCTRFUN)
				oSection1:Cell("TIPO"):SetValue("ASSOCIADO")
				nTotAsso += QRYSRV->F2_VALMERC
				nQtdAsso++
			Endif
		Endif	

		oSection1:PrintLine()

	ElseIf MV_PAR07 == 1 //Associados
		
		If !lFin

			If !Empty(QRYSRV->F2_XCTRFUN)
		
				oSection1:Cell("F2_CLIENTE"):SetValue(QRYSRV->F2_CLIENTE)
				oSection1:Cell("F2_LOJA"):SetValue(QRYSRV->F2_LOJA)
				oSection1:Cell("A1_NOME"):SetValue(QRYSRV->A1_NOME)
				oSection1:Cell("F2_XCTRFUN"):SetValue(QRYSRV->F2_XCTRFUN)
				oSection1:Cell("F2_DOC"):SetValue(QRYSRV->F2_DOC)
				oSection1:Cell("F2_VALMERC"):SetValue(QRYSRV->F2_VALMERC)
				oSection1:Cell("TIPO"):SetValue("ASSOCIADO")

				oSection1:PrintLine()

				nTotAsso += QRYSRV->F2_VALMERC
				nQtdAsso++
			Endif
		Endif	
	Else

		If lFin

			oSection1:Cell("F2_CLIENTE"):SetValue(QRYSRV->F2_CLIENTE)
			oSection1:Cell("F2_LOJA"):SetValue(QRYSRV->F2_LOJA)
			oSection1:Cell("A1_NOME"):SetValue(QRYSRV->A1_NOME)
			oSection1:Cell("F2_XCTRFUN"):SetValue(QRYSRV->F2_XCTRFUN)
			oSection1:Cell("F2_DOC"):SetValue(QRYSRV->F2_DOC)
			oSection1:Cell("F2_VALMERC"):SetValue(QRYSRV->F2_VALMERC)
			oSection1:Cell("TIPO"):SetValue("PARTICULAR")

			oSection1:PrintLine()

			nTotPart += QRYSRV->F2_VALMERC
			nQtdPart++
		Endif
	Endif
		
	QRYSRV->(dbSkip())
EndDo

oSection1:Finish()

oSection2:Init()

oSection2:Cell("TOTSRVPART"):SetValue(nTotPart)
oSection2:Cell("QTDSRVPART"):SetValue(nQtdPart)
oSection2:Cell("TOTSRVASSO"):SetValue(nTotAsso)
oSection2:Cell("QTDSRVASSO"):SetValue(nQtdAsso)

oSection2:PrintLine()

oSection2:Finish()

If Select("QRYSRV") > 0
	QRYSRV->(DbCloseArea())
Endif

Return

/***************************/
Static Function RetFin(cDoc)
/***************************/

Local lRet
Local cQry := ""

If Select("QRYFIN") > 0
	QRYFIN->(DbCloseArea())
Endif

cQry := "SELECT TOP 1 SF4.F4_DUPLIC"
cQry += " FROM "+RetSqlName("SD2")+" SD2, "+RetSqlName("SF4")+" SF4"
cQry += " WHERE SD2.D_E_L_E_T_ 	<> '*'"
cQry += " AND SF4.D_E_L_E_T_ 	<> '*'"
cQry += " AND SD2.D2_FILIAL 	= '"+xFilial("SD2")+"'"
cQry += " AND SF4.F4_FILIAL 	= '"+xFilial("SF4")+"'"
cQry += " AND SD2.D2_TES		= SF4.F4_CODIGO"
cQry += " AND SD2.D2_DOC		= '"+cDoc+"'"

cQry := ChangeQuery(cQry)
TcQuery cQry NEW Alias "QRYFIN"

While QRYFIN->(!EOF())

	If QRYFIN->F4_DUPLIC == "S" //Gera Financeiro
		lRet := .T.
	Else
		lRet := .F.
	Endif
	
	QRYFIN->(DbSkip())
EndDo

If Select("QRYFIN") > 0
	QRYFIN->(DbCloseArea())
Endif

Return lRet
