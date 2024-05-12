#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'
#include 'topconn.ch'

/*/{Protheus.doc} RCPGA031
Processa comissao de gerentes e supervisores (Tabela SE3).

@author pablocavalcante
@since 28/06/2016
@version undefined

@type function
/*/

#define cPulaLinha chr(13)+chr(10)

User Function RCPGA031()

Local aArea		:= GetArea()
Local dBkpDtB	:= dDataBase
Local cLog 		:= ""

Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5

Local oButton1
Local oButton2
Local oButton3
Local oButton4
Local oButton5

Local oComboBo1
Private cComboBo1 := "Ambos"

//Private cPerg 	:= "RCPGA031"

Private oGroup1
Private oGroup2
Private oGroup3

Private oGet1
Private oGet2
Private oGet3
Private oGet4

//variáveis de filtro
Private	cVendDe := space(tamsx3('A3_COD')[1])
Private	cVendAt := replicate("Z",tamsx3('A3_COD')[1])
Private dDataDe := ctod("")
Private dDataAt := ctod("")
Private	dDataVe := ctod("")

Private oGet1
Private oGet2
Private aGets := {}

	//AjustaSx1() // cria as perguntas do reprocessamento de comissão
	
	//Pergunte - Variável pública de pergunta ( cGroup [ lAsk ] [ cTitle ] [ lOnlyView ] ) --> lRet
	//If !Pergunte(cPerg,.T.)
	//	Return
	//EndIf
	
	//cVendDe	:= mv_par01
	//cVendAt := mv_par02
	//dDataDe := mv_par03
	//dDataAt := mv_par04
	//dDataVe := mv_par05
	//lProces := mv_par06

Private aDetalhes := {}
/*
	{"X","XXXXXX",{{"","","",...},{"","","",...}...}
	{"X","XXXXXX",{{"","","",...},{"","","",...}...}
	...
*/

Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Processamento de Comissões de Gerentes e Supervisores" FROM 000, 000  TO 500, 800 COLORS 0, 16777215 PIXEL
	
	@ 002, 002 GROUP oGroup1 TO 064, 212 PROMPT " Filtros " OF oDlg COLOR 0, 16777215 PIXEL
	
	@ 012, 007 SAY oSay1 PROMPT "Do Vendedor ?" SIZE 045, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 022, 007 MSGET oGet1 VAR cVendDe SIZE 060, 010 OF oDlg F3 "SA3" COLORS 0, 16777215 PIXEL
	
	@ 012, 080 SAY oSay2 PROMPT "Até o Vendedor ?" SIZE 052, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 022, 080 MSGET oGet2 VAR cVendAt SIZE 060, 010 OF oDlg F3 "SA3" COLORS 0, 16777215 PIXEL
	
	@ 037, 007 SAY oSay3 PROMPT "Da Data ?" SIZE 041, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 047, 007 MSGET oGet3 VAR dDataDe SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
	
	@ 038, 080 SAY oSay4 PROMPT "Até a Data ?" SIZE 051, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 047, 080 MSGET oGet4 VAR dDataAt SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
	
	@ 012, 150 SAY oSay5 PROMPT "Para ?" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 021, 150 MSCOMBOBOX oComboBo1 VAR cComboBo1 ITEMS {"Gerentes","Supervisores","Ambos"} SIZE 056, 010 OF oDlg COLORS 0, 16777215 PIXEL
	
	@ 045, 163 BUTTON oButton1 PROMPT "Processar" SIZE 041, 012 OF oDlg PIXEL ACTION ProcessCom(@cLog)
	    
	@ 067, 002 GROUP oGroup2 TO 140, 397 PROMPT " Gerentes e Supervisores " OF oDlg COLOR 0, 16777215 PIXEL
	oGet1 := fMSNewGe1()                                                                     	
	//bSvblDb1 := oGet1:oBrowse:bLDblClick
	//oGet1:oBrowse:bLDblClick := {|| if(oGet1:oBrowse:nColPos!=0, CLIQUE1(), GdRstDblClick(@oGet1, @bSvblDb1))}
	oGet1:oBrowse:bChange := {|| Refresh1()}
	    
	@ 143, 002 GROUP oGroup3 TO 229, 397 PROMPT " Detalhes da Comissão " OF oDlg COLOR 0, 16777215 PIXEL
	oGet2 := fMSNewGe2()
	    
	@ 232, 005 BUTTON oButton4 PROMPT "Log" SIZE 037, 012 OF oDlg PIXEL ACTION ShowLog(@cLog)
	//@ 232, 050 BUTTON oButton5 PROMPT "Excel" SIZE 037, 012 OF oDlg PIXEL
	@ 232, 310 BUTTON oButton3 PROMPT "Cancelar" SIZE 037, 012 OF oDlg PIXEL ACTION oDlg:End()
	@ 232, 355 BUTTON oButton2 PROMPT "Confirmar" SIZE 037, 012 OF oDlg PIXEL ACTION GeraComiss(@cLog)
	
	ACTIVATE MSDIALOG oDlg CENTERED

	dDataBase := dBkpDtB
	RestArea(aArea)

Return


/*/{Protheus.doc} Refresh1
Atualiza o grid de detalhes
@author pablocavalcante
@since 21/07/2016
@version undefined

@type function
/*/
Static Function Refresh1()

Local nX	:=1 
Local nLin 	:= oGet1:oBrowse:nAT
Local nPos 	:= aScan(aDetalhes,{|x| AllTrim(x[1]+x[2])==AllTrim(oGet1:aCols[nLin][1]+oGet1:aCols[nLin][2])})

	If nPos > 0
		oGet2:aCols := {}
		For nX:=1 to Len(aDetalhes[nPos][3])
			Aadd(oGet2:aCols, aDetalhes[nPos][3][nX])
		Next nX
	EndIf

	If Len(oGet2:aCols) == 0
		Aadd(oGet2:aCols, {" ", space(6), ctod(""), space(tamsx3("A3_COD")[1]), space(tamsx3("A3_NOME")[1]), space(tamsx3("B1_COD")[1]), space(tamsx3("B1_DESC")[1]), 0, 0, 0, 0, 0, space(50), .F.})
	EndIf

	oGet2:Refresh()

Return


/*/{Protheus.doc} A490Calc
Calcula o valor base da comissao
@author pablocavalcante
@since 21/07/2016
@version undefined

@type function
/*/
User Function U490Calc()
Local nRVar 		:= &(Alltrim(ReadVar()))
Local cRVar			:= AllTrim(ReadVar())
Local nColGet1 		:= oGet1:oBrowse:nColPos
Local nLinGet1		:= oGet1:oBrowse:nAT
Local nPE3_BASE 	:= aScan(oGet1:aHeader,{|x| AllTrim(x[2]) == "E3_BASE"})
Local nPE3_PORC 	:= aScan(oGet1:aHeader,{|x| AllTrim(x[2]) == "E3_PORC"})
Local nPE3_COMIS 	:= aScan(oGet1:aHeader,{|x| AllTrim(x[2]) == "E3_COMIS"})
Private lMsErroAuto := .F.

	If nColGet1 == nPE3_BASE
		oGet1:aCols[nLinGet1][nPE3_COMIS] := nRVar * (oGet1:aCols[nLinGet1][nPE3_PORC] / 100)
		M->E3_COMIS := oGet1:aCols[nLinGet1][nPE3_COMIS]
		oGet1:Refresh()
	ElseIf nColGet1 == nPE3_PORC
		oGet1:aCols[nLinGet1][nPE3_COMIS] := oGet1:aCols[nLinGet1][nPE3_BASE] * (nRVar / 100)
		M->E3_COMIS := oGet1:aCols[nLinGet1][nPE3_COMIS]
		oGet1:Refresh()
	ElseIf nColGet1 == nPE3_COMIS
		oGet1:aCols[nLinGet1][nPE3_PORC] := (nRVar * 100) / oGet1:aCols[nLinGet1][nPE3_BASE]
		M->E3_PORC := oGet1:aCols[nLinGet1][nPE3_PORC]
		oGet1:Refresh()
	EndIf

Return .T.

/*/{Protheus.doc} ProcessCom
Processa a comissão e atualiza os dados da tela

@author pablocavalcante
@since 19/07/2016
@version undefined
@param cLog, characters, descricao
@type function
/*/
Static Function ProcessCom(cLog)
Local oProcess
Local lEnd 	:= .F.
Private lProces
	
	oProcess := MsNewProcess():New({|lEnd| UAJUSCOM(@oProcess, @lEnd, @cLog) },"Processamento das Comissões - Gerentes/Supervisores","Aguarde! Processando as comissões...",.T.) 
	oProcess:Activate()
	
Return


/*/{Protheus.doc} ShowLog
Mostra o log do ultimo processamento

@author pablocavalcante
@since 19/07/2016
@version undefined
@param cLog, characters, descricao
@type function
/*/
Static Function ShowLog(cLog)
	
	If !Empty(cLog)
		
		cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cLog )
		Define Font oFont Name "Arial" Size 7, 16
		Define MsDialog oDlgDet Title "Log Gerado - último procesamento" From 3, 0 to 340, 417 Pixel

		@ 5, 5 Get oMemo Var cLog Memo Size 200, 145 Of oDlgDet Pixel
		oMemo:bRClicked := { || AllwaysTrue() }
		oMemo:oFont     := oFont

		Define SButton From 153, 175 Type  1 Action oDlgDet:End() Enable Of oDlgDet Pixel // Apaga
		Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
		MemoWrite( cFile, cLog ) ) ) Enable Of oDlgDet Pixel

		Activate MsDialog oDlgDet Center
	
	Else
		MsgInfo("Não existem logs a serem mostrados.","Atenção")
	EndIf
	
Return

//
// MsNewGetDados referente as comissões de gerentes e supervisores geradas...
//  
Static Function fMSNewGe1()
Local nX
Local aHeaderEx    := {}
Local aColsEx      := {}
Local aFieldFill   := {}
Local aFields      := {"TIPO","A3_COD","A3_NOME","E3_VENCTO","E3_BASE","E3_PORC","E3_COMIS"}
Local aAlterFields := {"E3_VENCTO","E3_BASE","E3_PORC","E3_COMIS"}
Local nLinMax 	   := 9999  // Quantidade delinha na getdados
Local oSX3			:= UGetSxFile():New
Local aSX3			:= {}

	// Define field properties
	Aadd(aHeaderEx,{'Tipo','TIPO','!@',1,0,'','€€€€€€€€€€€€€€','C','','','G=GERENTE;S=SUPERVISOR',''})

	For nX := 1 to Len(aFields)

		aSX3 := oSX3:GetInfoSX3(,aFields[nX])

		If Len(aSX3) > 0

			If AllTrim(aFields[nX]) $ "E3_BASE/E3_PORC/E3_COMIS"
		
				Aadd(aHeaderEx, {aSX3[1,2]:cTITULO,aSX3[1,2]:cCAMPO,aSX3[1,2]:cPICTURE,aSX3[1,2]:nTAMANHO,aSX3[1,2]:nDECIMAL,/*aSX3[1,2]:cVALID*/"U_U490Calc()",;
				aSX3[1,2]:cUSADO,aSX3[1,2]:cTIPO,aSX3[1,2]:cF3,aSX3[1,2]:cCONTEXT,aSX3[1,2]:cCBOX,/*aSX3[1,2]:cRELACAO*/""})		
		
			Else
		
				Aadd(aHeaderEx, {aSX3[1,2]:cTITULO,aSX3[1,2]:cCAMPO,aSX3[1,2]:cPICTURE,aSX3[1,2]:nTAMANHO,aSX3[1,2]:nDECIMAL,aSX3[1,2]:cVALID,;
				aSX3[1,2]:cUSADO,aSX3[1,2]:cTIPO,aSX3[1,2]:cF3,aSX3[1,2]:cCONTEXT,aSX3[1,2]:cCBOX,aSX3[1,2]:cRELACAO})
		
			EndIf
		Endif
	Next nX
	
	If Len(aColsEx) == 0
		Aadd(aColsEx, {" ", space(tamsx3("A3_COD")[1]), space(tamsx3("A3_NOME")[1]), ctod(""), 0, 0, 0, .F.})
	EndIf

Return MsNewGetDados():New( 076, 005, 136, 395, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue",;
	aAlterFields, , nLinMax, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

//  oMSNewGe1 := MsNewGetDados():New( 076, 005, 136, 209, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

//
// MsNewGetDados referente ao detalhamento da comissão...
// 
Static Function fMSNewGe2()

Local nX
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields		:= {"ORIGEM","NUMERO","E3_EMISSAO","A3_COD","A3_NOME","B1_COD","B1_DESC","C6_QTDVEN","C6_PRCVEN","E3_BASE","E3_PORC","E3_COMIS","HISTORICO"}
Local aAlterFields	:= {}
Local nLinMax 	  	:= 9999  // Quantidade delinha na getdados
Local oSX3			:= UGetSxFile():New
Local aSX3			:= {}

	For nX := 1 to Len(aFields)

		aSX3 := oSX3:GetInfoSX3(,aFields[nX])

		If aFields[nX] == "ORIGEM"
		
			Aadd(aHeaderEx,{'Origem','ORIGEM','!@',1,0,'','€€€€€€€€€€€€€€','C','','','V=VD DIRETA;P=PD VENDA;C=CTR CEMITERIO;F=CTR FUNERARIA',''})
		
		ElseIf aFields[nX] == "NUMERO"
		
			Aadd(aHeaderEx,{'Número','NUMERO','!@',6,0,'','€€€€€€€€€€€€€€','C','','','',''})
		
		ElseIf aFields[nX] == "HISTORICO"
		
			Aadd(aHeaderEx,{'Histórico','HISTORICO','!@',50,0,'','€€€€€€€€€€€€€€','C','','','',''})
		
		ElseIf Len(aSX3) > 0
		
			If aFields[nX] == "A3_COD"

				Aadd(aHeaderEx, {AllTrim("Vendedor"),aSX3[1,2]:cCAMPO,aSX3[1,2]:cPICTURE,aSX3[1,2]:nTAMANHO,aSX3[1,2]:nDECIMAL,/*aSX3[1,2]:cVALID*/"",;
				aSX3[1,2]:cUSADO,aSX3[1,2]:cTIPO,aSX3[1,2]:cF3,aSX3[1,2]:cCONTEXT,aSX3[1,2]:cCBOX,aSX3[1,2]:cRELACAO})
			
			ElseIf aFields[nX] == "B1_COD"
			
				Aadd(aHeaderEx, {AllTrim("Produto"),aSX3[1,2]:cCAMPO,aSX3[1,2]:cPICTURE,aSX3[1,2]:nTAMANHO,aSX3[1,2]:nDECIMAL,/*aSX3[1,2]:cVALID*/"",;
				aSX3[1,2]:cUSADO,aSX3[1,2]:cTIPO,aSX3[1,2]:cF3,aSX3[1,2]:cCONTEXT,aSX3[1,2]:cCBOX,aSX3[1,2]:cRELACAO})
			
			Else
			
				Aadd(aHeaderEx, {aSX3[1,2]:cTITULO,aSX3[1,2]:cCAMPO,aSX3[1,2]:cPICTURE,aSX3[1,2]:nTAMANHO,aSX3[1,2]:nDECIMAL,/*aSX3[1,2]:cVALID*/"",;
				aSX3[1,2]:cUSADO,aSX3[1,2]:cTIPO,aSX3[1,2]:cF3,aSX3[1,2]:cCONTEXT,aSX3[1,2]:cCBOX,aSX3[1,2]:cRELACAO})
			
			EndIf		
		EndIf
	Next nX
	
	If Len(aColsEx) == 0
		Aadd(aColsEx, {" ", space(6), ctod(""), space(tamsx3("A3_COD")[1]), space(tamsx3("A3_NOME")[1]), space(tamsx3("B1_COD")[1]), space(tamsx3("B1_DESC")[1]), 0, 0, 0, 0, 0, space(50), .F.})
	EndIf

Return MsNewGetDados():New( 151, 005, 226, 395, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue",;
	aAlterFields, , nLinMax, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
//oMSNewGe2 := MsNewGetDados():New( 151, 005, 226, 209, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)


//
// Reprocessamento de comissões, conforme filtros informados.
//

Static Function UAJUSCOM(oProcess, lEnd, cLog)

	cLog := ">> INICIO DO PROCESSAMENTO DE COMISSÕES" + cPulaLinha
	cLog += cPulaLinha
	cLog += " >> VENDEDORES: " + cVendDe + " ATE " + cVendAt + cPulaLinha
	cLog += " >> DATA: " + DtoC(dDataDe) + " ATE " + DtoC(dDataAt) + cPulaLinha
	cLog += cPulaLinha
	
	//zero as variaveis de detalhamento (grids)
	aDetalhes   := {}
	oGet1:aCols := {}
	oGet2:aCols := {}
	
	If cComboBo1 == "Gerentes" .or. cComboBo1 == "Ambos" //gerente ou ambos
		PrComissao(oProcess, lEnd, @cLog, 1)
	EndIf
	
	If cComboBo1 == "Supervisores" .or. cComboBo1 == "Ambos" //supervidor ou ambos
		PrComissao(oProcess, lEnd, @cLog, 2)
	EndIf

	cLog += cPulaLinha
	cLog += ">> FIM PROCESSAMENTO DE COMISSÕES" + cPulaLinha
	
	If Len(oGet1:aCols) == 0
		Aadd( oGet1:aCols,{" ", space(tamsx3("A3_COD")[1]), space(tamsx3("A3_NOME")[1]), ctod(""), 0, 0, 0, .F.} )
	EndIf
	
	If Len(oGet2:aCols) == 0
		Aadd(oGet2:aCols, {" ", space(6), ctod(""), space(tamsx3("A3_COD")[1]), space(tamsx3("A3_NOME")[1]), space(tamsx3("B1_COD")[1]), space(tamsx3("B1_DESC")[1]), 0, 0, 0, 0, 0, space(50), .F.})
	EndIf

	oGet1:oBrowse:nAT := 1
	oGet1:Refresh()
    
	//atualizo grid de detalhes com os dados do supervisor ou gerente posicionado na grid
	Refresh1()

Return


Static Function PrComissao(oProcess, lEnd, cLog, nOpc)

Local aArea			:= GetArea()
Local nCountSA3		:= 0
Local nTotBase 		:= 0
Local nTotComis 	:= 0
Local nTotPorc		:= 0
Local nTotGBase 	:= 0
Local nTotGComis 	:= 0
Local nTotGPorc		:= 0
Local nPerVend		:= 0
Local cVendSub		:= ""
Local cLstVend		:= ""
Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
Local nY			:= 1
Local nX			:= 1
	
	aSubordinados := RetSubord(@cLog,nOpc)
	
	//dDataBase := dRefenc
	nCountSA3 := Len(aSubordinados)
	
	oProcess:SetRegua1(nCountSA3)
	
	cLog += cPulaLinha
	cLog += "  >> ARRAY aSubordinados: " + cPulaLinha + U_ToString(aSubordinados)
	cLog += cPulaLinha
	
	For nX:=1 to Len(aSubordinados)
		
		If lEnd	//houve cancelamento do processo
			Exit
		EndIf
		
		If nOpc == 1
			oProcess:IncRegua1("GERENTE: " + aSubordinados[nX][1] + " - " + Posicione("SA3",1,xFilial("SA3")+aSubordinados[nX][1],"A3_NOME"))
		Else
			oProcess:IncRegua1("SUPERVISOR: " + aSubordinados[nX][1] + " - " + Posicione("SA3",1,xFilial("SA3")+aSubordinados[nX][1],"A3_NOME"))
		EndIf
		nPerVend := Posicione("SA3",1,xFilial("SA3")+aSubordinados[nX][1],"A3_COMIS")
		cLog += cPulaLinha
		If nOpc == 1
			cLog += "   >> GERENTE: " + aSubordinados[nX][1] + " - " + Posicione("SA3",1,xFilial("SA3")+aSubordinados[nX][1],"A3_NOME")
			Aadd(aDetalhes, {"G",aSubordinados[nX][1],{}})
		Else
			cLog += "   >> SUPERVISOR: " + aSubordinados[nX][1] + " - " + Posicione("SA3",1,xFilial("SA3")+aSubordinados[nX][1],"A3_NOME")
			Aadd(aDetalhes, {"S",aSubordinados[nX][1],{}})
		EndIf
		
		/*
		*	VENDA DIRETA: SL1, SL2 e SB1
		*/
		
		cLog += cPulaLinha
		cLog += "   >> SELEÇÃO DAS COMISSOES DE VENDAS AVULSAS (VENDA DIRETA) DOS VENDEDORES RELACIONADOS... " + cPulaLinha
		
		cQry := "SELECT SL1.*, SL2.*, SB1.*" + cPulaLinha
		cQry += " FROM " + RetSqlName("SL1") + " SL1" + cPulaLinha
		cQry += " INNER JOIN" + cPulaLinha
		cQry += " " + RetSqlName("SL2") + " SL2 ON (SL1.L1_FILIAL = SL2.L2_FILIAL AND SL1.L1_NUM = SL2.L2_NUM AND SL2.D_E_L_E_T_ <> '*')" + cPulaLinha
		cQry += " INNER JOIN" + cPulaLinha
		cQry += " " + RetSqlName("SB1") + " SB1 ON (SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SL2.L2_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ <> '*')" + cPulaLinha
		cQry += " WHERE" + cPulaLinha
		cQry += " SL1.D_E_L_E_T_ <> '*'" + cPulaLinha
		
		cLstVend := ""
		For nY:=1 to Len(aSubordinados[nX][2])
			If Empty(cLstVend)
				cLstVend += "'" + aSubordinados[nX][2][nY] + "'"
			Else
				cLstVend += ", '" + aSubordinados[nX][2][nY] + "'"
			EndIf
		Next nY
		
		cQry += " AND SL1.L1_VEND IN (" + cLstVend + ")" + cPulaLinha
		cQry += " AND SL1.L1_EMISNF <> ''" + cPulaLinha
		cQry += " AND SL1.L1_EMISNF BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAt) + "'" + cPulaLinha
		cQry += " AND SB1.B1_XCOMISS = 'S'" + cPulaLinha
		cQry += " ORDER BY SL1.L1_FILIAL, SL1.L1_VEND, SL1.L1_NUM, SL1.L1_DOC, SL1.L1_SERIE, SL2.L2_ITEM" + cPulaLinha
		
		cLog += cPulaLinha
		cLog += " >> QUERY: "
		cLog += cPulaLinha
		cLog += cPulaLinha
		cLog += cQry
		cLog += cPulaLinha
		cLog += cPulaLinha
		
		If Select("QRYSL1") > 0
			QRYSL1->(DbCloseArea())
		EndIf
		
		cQry := ChangeQuery(cQry)
		TcQuery cQry New Alias "QRYSL1" // Cria uma nova area com o resultado do query
		
		cVendSub := ""
		
		QRYSL1->(dbEval({|| nCountSA3++}))
		QRYSL1->(dbGoTop())
		
		oProcess:SetRegua2(nCountSA3)
		
		While QRYSL1->(!Eof())
			
			If lEnd	//houve cancelamento do processo
				Exit
			EndIf
			
			oProcess:IncRegua2("...")
			
			If cVendSub <> QRYSL1->L1_VEND
				cLog += cPulaLinha
				cLog += "    >> VENDEDOR: " + QRYSL1->L1_VEND + " - " + Posicione("SA3",1,xFilial("SA3")+QRYSL1->L1_VEND,"A3_NOME")
				cVendSub := QRYSL1->L1_VEND
			EndIf
			
			//>>> PRODUTO - DESCRICAO - QTD - VLR UNIT - VLR TOTAL - % COMISSAO - VALOR COMISSAO
			cLog += cPulaLinha
			cLog += "     >> ORCAMENTO: " + QRYSL1->L1_NUM + cPulaLinha
			cLog += "     >> PRODUTO: " + QRYSL1->L2_PRODUTO + cPulaLinha
			cLog += "     >> DESCRICAO: " + QRYSL1->L2_DESCRI + cPulaLinha
			cLog += "     >> QUANTIDADE: " + Transform(QRYSL1->L2_QUANT,"@E 9,999,999,999,999.99") + cPulaLinha
			cLog += "     >> VALOR UNITARIA: " + Transform(QRYSL1->L2_VRUNIT,"@E 9,999,999,999,999.99") + cPulaLinha
			cLog += "     >> VALOR TOTAL: " + Transform(QRYSL1->L2_VLRITEM,"@E 9,999,999,999,999.99") + cPulaLinha
			cLog += "     >> % COMISSAO: " + Transform(nPerVend,"@E 999.99") + cPulaLinha
			cLog += "     >> VLR COMISSAO: " + Transform(QRYSL1->L2_VLRITEM * (nPerVend/100),"@E 9,999,999,999,999.99") + cPulaLinha
			
			nTotBase  += QRYSL1->L2_VLRITEM
			nTotComis += QRYSL1->L2_VLRITEM * (nPerVend/100)
			
			Aadd(aDetalhes[len(aDetalhes)][3], {"V", QRYSL1->L1_NUM, StoD(QRYSL1->L1_EMISNF), QRYSL1->L1_VEND, Posicione("SA3",1,xFilial("SA3")+QRYSL1->L1_VEND,"A3_NOME"), QRYSL1->L2_PRODUTO, QRYSL1->L2_DESCRI, QRYSL1->L2_QUANT, QRYSL1->L2_VRUNIT, QRYSL1->L2_VLRITEM, nPerVend, QRYSL1->L2_VLRITEM * (nPerVend/100), "COMISSOES DE VENDAS AVULSAS (VENDA DIRETA)", .F.})
			
			QRYSL1->(dbSkip())
		EndDo
		
		nTotPorc	:= NoRound((nTotComis/nTotBase)*100,2)
		
		cLog += cPulaLinha
		cLog += "     >> TOTAIS COMISSOES VENDAS AVULSAS (VENDA DIRETA)" + cPulaLinha
		cLog += "     >> BASE COMISSÃO: " + Transform(nTotBase,"@E 9,999,999,999,999.99") + cPulaLinha
		cLog += "     >> % COMISSAO: " + Transform(nTotPorc,"@E 999.99") + cPulaLinha
		cLog += "     >> VLR COMISSÃO: " + Transform(nTotComis,"@E 9,999,999,999,999.99") + cPulaLinha
		cLog += cPulaLinha
		
		If Select("QRYSL1") > 0
			QRYSL1->(DbCloseArea())
		EndIf
		
		nTotGBase 	+= nTotBase 
		nTotGComis 	+= nTotComis
		nTotGPorc	:= NoRound((nTotGComis/nTotGBase)*100,2)
		
		nTotBase 	:= 0
		nTotComis 	:= 0
		nTotPorc	:= 0
		
		/*
		*	PEDIDO DE VENDA: SC5, SC6 e SB1
		*/
		
		cLog += cPulaLinha
		cLog += "   >> SELEÇÃO DAS COMISSOES DE VENDAS AVULSAS (PEDIDO DE VENDA) DOS VENDEDORES RELACIONADOS... " + cPulaLinha
		
		cQry := "SELECT SC5.*, SC6.*, SB1.*" + cPulaLinha
		cQry += " FROM " + RetSqlName("SC5") + " SC5" + cPulaLinha
		cQry += " INNER JOIN" + cPulaLinha
		cQry += " " + RetSqlName("SC6") + " SC6 ON (SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM AND SC6.D_E_L_E_T_ <> '*')" + cPulaLinha
		cQry += " INNER JOIN" + cPulaLinha
		cQry += " " + RetSqlName("SB1") + "  SB1 ON (SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SC6.C6_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ <> '*')" + cPulaLinha
		cQry += " WHERE" + cPulaLinha
		cQry += " SC5.D_E_L_E_T_ <> '*'" + cPulaLinha
		cQry += " AND SC5.C5_VEND1 IN (" + cLstVend + ")" + cPulaLinha		
		cQry += " AND SC5.C5_XCONTRA = ''" + cPulaLinha
		cQry += " AND SC5.C5_XCTRFUN = ''" + cPulaLinha
		cQry += " AND SC6.C6_NOTA <> ''" + cPulaLinha
		cQry += " AND SC6.C6_DATFAT BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAt) + "'" + cPulaLinha
		cQry += " AND SB1.B1_XCOMISS = 'S'" + cPulaLinha
        cQry += " ORDER BY SC5.C5_FILIAL, SC5.C5_VEND1, SC6.C6_NOTA, SC6.C6_SERIE, SC6.C6_ITEM" + cPulaLinha
		
		cLog += cPulaLinha
		cLog += " >> QUERY: "
		cLog += cPulaLinha
		cLog += cPulaLinha
		cLog += cQry
		cLog += cPulaLinha
		cLog += cPulaLinha
		
		If Select("QRYSC5") > 0
			QRYSC5->(DbCloseArea())
		EndIf
		
		cQry := ChangeQuery(cQry)
		TcQuery cQry New Alias "QRYSC5" // Cria uma nova area com o resultado do query
		
		cVends := ""
		
		QRYSC5->(dbEval({|| nCountSA3++}))
		QRYSC5->(dbGoTop())
		
		oProcess:SetRegua2(nCountSA3)
		
		While QRYSC5->(!Eof())
			
			If lEnd	//houve cancelamento do processo
				Exit
			EndIf
			
			oProcess:IncRegua2("...")
			
			If cVends <> QRYSC5->C5_VEND1
				cLog += cPulaLinha
				cLog += "    >> VENDEDOR: " + QRYSC5->C5_VEND1 + " - " + Posicione("SA3",1,xFilial("SA3")+QRYSC5->C5_VEND1,"A3_NOME") + cPulaLinha
				cVends := QRYSC5->C5_VEND1
			EndIf
			
			//>>> PRODUTO - DESCRICAO - QTD - VLR UNIT - VLR TOTAL - % COMISSAO - VALOR COMISSAO
			cLog += cPulaLinha
			cLog += "     >> PEDIDO DE VENDA: " + QRYSC5->C5_NUM + cPulaLinha
			cLog += "     >> PRODUTO: " + QRYSC5->C6_PRODUTO + cPulaLinha
			cLog += "     >> DESCRICAO: " + QRYSC5->C6_DESCRI + cPulaLinha
			cLog += "     >> QUANTIDADE: " + Transform(QRYSC5->C6_QTDVEN,"@E 9,999,999,999,999.99") + cPulaLinha
			cLog += "     >> VALOR UNITARIA: " + Transform(QRYSC5->C6_PRCVEN,"@E 9,999,999,999,999.99") + cPulaLinha
			cLog += "     >> VALOR TOTAL: " + Transform(QRYSC5->C6_VALOR,"@E 9,999,999,999,999.99") + cPulaLinha
			cLog += "     >> % COMISSAO: " + Transform(nPerVend,"@E 999.99") + cPulaLinha
			cLog += "     >> VLR COMISSAO: " + Transform(QRYSC5->C6_VALOR * (nPerVend/100),"@E 9,999,999,999,999.99") + cPulaLinha
			
			nTotBase 	+= QRYSC5->C6_VALOR
			nTotComis 	+= QRYSC5->C6_VALOR * (nPerVend/100)
			
			Aadd(aDetalhes[len(aDetalhes)][3], {"P", QRYSC5->C5_NUM, StoD(QRYSC5->C6_DATFAT), QRYSC5->C5_VEND1, Posicione("SA3",1,xFilial("SA3")+QRYSC5->C5_VEND1,"A3_NOME"), QRYSC5->C6_PRODUTO, QRYSC5->C6_DESCRI, QRYSC5->C6_QTDVEN, QRYSC5->C6_PRCVEN, QRYSC5->C6_VALOR, nPerVend, QRYSC5->C6_VALOR * (nPerVend/100), "COMISSOES DE VENDAS AVULSAS (PEDIDO DE VENDA)", .F.})
			
			QRYSC5->(dbSkip())
		EndDo
		
		nTotPorc	:= NoRound((nTotComis/nTotBase)*100,2)
		
		cLog += cPulaLinha
		cLog += "     >> TOTAIS COMISSOES DE VENDAS AVULSAS (PEDIDO DE VENDA)" + cPulaLinha
		cLog += "     >> BASE COMISSÃO: " + Transform(nTotBase,"@E 9,999,999,999,999.99") + cPulaLinha
		cLog += "     >> % COMISSAO: " + Transform(nTotPorc,"@E 999.99") + cPulaLinha
		cLog += "     >> VLR COMISSÃO: " + Transform(nTotComis,"@E 9,999,999,999,999.99") + cPulaLinha
		cLog += cPulaLinha
		
		If Select("QRYSC5") > 0
			QRYSC5->(DbCloseArea())
		EndIf
		
		nTotGBase 	+= nTotBase 
		nTotGComis 	+= nTotComis
		nTotGPorc	:= NoRound((nTotGComis/nTotGBase)*100,2)
		
		nTotBase 	:= 0
		nTotComis 	:= 0
		nTotPorc	:= 0
				
		/*
		*	CONTRATO CEMITERIO: U00, U05
		*/
		
		If lCemiterio
		
			cLog += cPulaLinha
			cLog += "   >> SELEÇÃO DAS COMISSOES DE CONTRATOS (CEMITERIO) DOS VENDEDORES RELACIONADOS... " + cPulaLinha
			
			cQry := "SELECT U00.*, U05.*" + cPulaLinha
			cQry += " FROM " + RetSqlName("U00") + " U00" + cPulaLinha
			cQry += " INNER JOIN" + cPulaLinha
			cQry += " " + RetSqlName("U05") + " U05 ON (U05.U05_FILIAL = '" + xFilial("U05") + "' AND U00.U00_PLANO = U05.U05_CODIGO AND U05.D_E_L_E_T_ <> '*')" + cPulaLinha
			cQry += " WHERE" + cPulaLinha
			cQry += " U00.D_E_L_E_T_ <> '*'" + cPulaLinha
			cQry += " AND U00.U00_VENDED IN (" + cLstVend + ")" + cPulaLinha
			cQry += " AND U00.U00_DTATIV <> ''" + cPulaLinha
			cQry += " AND U00.U00_DTATIV BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAt) + "'" + cPulaLinha
			cQry += " AND U05.U05_COMISS = 'S'" + cPulaLinha
			cQry += " ORDER BY U00.U00_FILIAL, U00.U00_VENDED, U00.U00_CODIGO" + cPulaLinha
			
			cLog += cPulaLinha
			cLog += " >> QUERY: "
			cLog += cPulaLinha
			cLog += cPulaLinha
			cLog += cQry
			cLog += cPulaLinha
			cLog += cPulaLinha
			
			If Select("QRYU00") > 0
				QRYU00->(DbCloseArea())
			EndIf
			
			cQry := ChangeQuery(cQry)
			TcQuery cQry New Alias "QRYU00" // Cria uma nova area com o resultado do query
			
			cVends := ""
			
			QRYU00->(dbEval({|| nCountSA3++}))
			QRYU00->(dbGoTop())
			
			oProcess:SetRegua2(nCountSA3)
			
			While QRYU00->(!Eof())
				
				If lEnd	//houve cancelamento do processo
					Exit
				EndIf
			
				oProcess:IncRegua2("...")
			
				If cVends <> QRYU00->U00_VENDED
					cLog += cPulaLinha
					cLog += "    >> VENDEDOR: " + QRYU00->U00_VENDED + " - " + Posicione("SA3",1,xFilial("SA3")+QRYU00->U00_VENDED,"A3_NOME") + cPulaLinha
					cVends := QRYU00->U00_VENDED
				EndIf
			
				//>>> PRODUTO - DESCRICAO - QTD - VLR UNIT - VLR TOTAL - % COMISSAO - VALOR COMISSAO
				cLog += cPulaLinha
				cLog += "     >> CONTRATO: " + QRYU00->U00_CODIGO + cPulaLinha
				cLog += "     >> PLANO: " + QRYU00->U00_PLANO + cPulaLinha
				cLog += "     >> DESCRICAO: " + QRYU00->U05_DESCRI + cPulaLinha
				cLog += "     >> VALOR TOTAL: " + Transform(QRYU00->U00_VALOR,"@E 9,999,999,999,999.99") + cPulaLinha
				cLog += "     >> % COMISSAO: " + Transform(nPerVend,"@E 999.99") + cPulaLinha
				cLog += "     >> VLR COMISSAO: " + Transform(QRYU00->U00_VALOR * (nPerVend/100),"@E 9,999,999,999,999.99") + cPulaLinha
				
				nTotBase 	+= QRYU00->U00_VALOR
				nTotComis 	+= QRYU00->U00_VALOR * (nPerVend/100)
				
				Aadd(aDetalhes[len(aDetalhes)][3], {"C", QRYU00->U00_CODIGO, StoD(QRYU00->U00_DTATIV), QRYU00->U00_VENDED, Posicione("SA3",1,xFilial("SA3")+QRYU00->U00_VENDED,"A3_NOME"), QRYU00->U00_PLANO, QRYU00->U05_DESCRI, 1, QRYU00->U00_VALOR, QRYU00->U00_VALOR, nPerVend, QRYU00->U00_VALOR * (nPerVend/100), "COMISSOES DE CONTRATOS (CEMITERIO)", .F.})
				
				QRYU00->(dbSkip())
			EndDo
		
			nTotPorc	:= NoRound((nTotComis/nTotBase)*100,2)
		
			cLog += cPulaLinha
			cLog += "     >> TOTAIS COMISSOES DE CONTRATOS (CEMITERIO)" + cPulaLinha
			cLog += "     >> BASE COMISSÃO: " + Transform(nTotBase,"@E 9,999,999,999,999.99") + cPulaLinha
			cLog += "     >> % COMISSAO: " + Transform(nTotPorc,"@E 999.99") + cPulaLinha
			cLog += "     >> VLR COMISSÃO: " + Transform(nTotComis,"@E 9,999,999,999,999.99") + cPulaLinha
			cLog += cPulaLinha
			
			If Select("QRYU00") > 0
				QRYU00->(DbCloseArea())
			EndIf
			
			nTotGBase 	+= nTotBase 
			nTotGComis 	+= nTotComis
			nTotGPorc	:= NoRound((nTotGComis/nTotGBase)*100,2)
			
			nTotBase 	:= 0
			nTotComis 	:= 0
			nTotPorc	:= 0
		
		EndIf
		/*
		 *	CONTRATO FUNERARIA: UF2, UF0
		*/
		
		If lFuneraria
		
			cLog += cPulaLinha
			cLog += "   >> SELEÇÃO DAS COMISSOES DE CONTRATOS (FUNERARIOS) DOS VENDEDORES RELACIONADOS... " + cPulaLinha
			
			cQry := "SELECT UF2.*, UF0.*" + cPulaLinha
			cQry += " FROM " + RetSqlName("UF2") + " UF2" + cPulaLinha
			cQry += " INNER JOIN" + cPulaLinha
			cQry += " " + RetSqlName("UF0") + " UF0 ON (UF2.UF2_FILIAL = '" + xFilial("UF2") + "' AND UF2.UF2_PLANO = UF0.UF0_CODIGO AND UF0.D_E_L_E_T_ <> '*')" + cPulaLinha
			cQry += " WHERE" + cPulaLinha
			cQry += " UF2.D_E_L_E_T_ <> '*'" + cPulaLinha
			cQry += " AND UF2.UF2_VEND IN (" + cLstVend + ")" + cPulaLinha
			cQry += " AND UF2.UF2_DTATIV <> ''" + cPulaLinha
			cQry += " AND UF2.UF2_DTATIV BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAt) + "'" + cPulaLinha
			cQry += " AND UF0.UF0_COMISS = 'S'" + cPulaLinha
			cQry += " ORDER BY UF2.UF2_FILIAL, UF2.UF2_VEND, UF2.UF2_CODIGO" + cPulaLinha
			
			cLog += cPulaLinha
			cLog += " >> QUERY: "
			cLog += cPulaLinha
			cLog += cPulaLinha
			cLog += cQry
			cLog += cPulaLinha
			cLog += cPulaLinha
			
			If Select("QRYUF2") > 0
				QRYUF2->(DbCloseArea())
			EndIf
			
			cQry := ChangeQuery(cQry)
			TcQuery cQry New Alias "QRYUF2" // Cria uma nova area com o resultado do query
			
			cVends := ""
			
			QRYUF2->(dbEval({|| nCountSA3++}))
			QRYUF2->( DbGoTop() )
			
			oProcess:SetRegua2(nCountSA3)
			
			While QRYUF2->(!Eof())
				
				If lEnd	//houve cancelamento do processo
					Exit
				EndIf
				
				oProcess:IncRegua2("...")
				
				If cVends <> QRYUF2->UF2_VEND
					cLog += cPulaLinha
					cLog += "    >> VENDEDOR: " + QRYUF2->UF2_VEND + " - " + Posicione("SA3",1,xFilial("SA3")+QRYUF2->UF2_VEND,"A3_NOME") + cPulaLinha
					cVends := QRYUF2->UF2_VEND
				EndIf
				
				//>>> PRODUTO - DESCRICAO - QTD - VLR UNIT - VLR TOTAL - % COMISSAO - VALOR COMISSAO
				cLog += cPulaLinha
				cLog += "     >> CONTRATO: " + QRYUF2->UF2_CODIGO + cPulaLinha
				cLog += "     >> PLANO: " + QRYUF2->UF2_PLANO + cPulaLinha
				cLog += "     >> DESCRICAO: " + QRYUF2->UF0_DESCRI + cPulaLinha
				cLog += "     >> VALOR TOTAL: " + Transform(QRYUF2->UF2_VALOR,"@E 9,999,999,999,999.99") + cPulaLinha
				cLog += "     >> % COMISSAO: " + Transform(nPerVend,"@E 999.99") + cPulaLinha
				cLog += "     >> VLR COMISSAO: " + Transform(QRYUF2->UF2_VALOR * (nPerVend/100),"@E 9,999,999,999,999.99") + cPulaLinha
				
				nTotBase 	+= QRYUF2->UF2_VALOR
				nTotComis 	+= QRYUF2->UF2_VALOR * (nPerVend/100)
				
				Aadd(aDetalhes[len(aDetalhes)][3], {"F", QRYUF2->UF2_CODIGO, StoD(QRYUF2->UF2_DTATIV), QRYUF2->UF2_VEND, Posicione("SA3",1,xFilial("SA3")+QRYUF2->UF2_VEND,"A3_NOME"), QRYUF2->UF2_PLANO, QRYUF2->UF0_DESCRI, 1, QRYUF2->UF2_VALOR, QRYUF2->UF2_VALOR, nPerVend, QRYUF2->UF2_VALOR * (nPerVend/100), "COMISSOES DE CONTRATOS (FUNERARIA)", .F.})
				
				QRYUF2->(dbSkip())
			EndDo
		
			nTotPorc	:= NoRound((nTotComis/nTotBase)*100,2)
			
			cLog += cPulaLinha
			cLog += "     >> TOTAIS COMISSOES DE CONTRATOS (FUNERARIA)" + cPulaLinha
			cLog += "     >> BASE COMISSÃO: " + Transform(nTotBase,"@E 9,999,999,999,999.99") + cPulaLinha
			cLog += "     >> % COMISSAO: " + Transform(nTotPorc,"@E 999.99") + cPulaLinha
			cLog += "     >> VLR COMISSÃO: " + Transform(nTotComis,"@E 9,999,999,999,999.99") + cPulaLinha
			cLog += cPulaLinha
			
			If Select("QRYUF2") > 0
				QRYUF2->(DbCloseArea())
			EndIf
		
			nTotGBase 	+= nTotBase 
			nTotGComis 	+= nTotComis
			nTotGPorc	:= NoRound((nTotGComis/nTotGBase)*100,2)
			
			nTotBase 	:= 0
			nTotComis 	:= 0
			nTotPorc	:= 0
			
		EndIf
		
		// ...
		
		//Posiciona no Vendedor
		SA3->(dbSetOrder(1)) //A3_FILIAL+A3_COD
		SA3->(dbSeek(xFilial("SA3")+aSubordinados[nX][1]))
		
		nDiaFec := 0
		
		//Posiciona no Cliclo e Pgto de Comissão
		U18->(dbSetOrder(1)) //U18_FILIAL+U18_CODIGO
		If U18->(dbSeek(xFilial("U18")+SA3->A3_XCICLO))
			nDiaFec := U18->U18_DIAFEC
		Else
			nDiaFec := SA3->A3_DIA
		EndIf
		
		If nDiaFec <= 0
			nDiaFec := Day(dDataBase)
		EndIf
		
		dE3_VENCTO := dDataBase
		
		If Val(Day2Str(dE3_VENCTO)) <= nDiaFec //U18->U18_DIAFEC //A3_DIA e A3_DDD (F - Fora Mes)
			dE3_VENCTO := CtoD(PADL(nDiaFec,2,"0")+"/"+Month2Str(dE3_VENCTO)+"/"+Year2Str(dE3_VENCTO))
		Else
			dE3_VENCTO := CtoD(PADL(nDiaFec,2,"0")+"/"+Month2Str(MonthSum(dE3_VENCTO,1))+"/"+Year2Str(MonthSum(dE3_VENCTO,1)))
		EndIf
		
		If nOpc == 1
			Aadd(oGet1:aCols, {"G", SA3->A3_COD, SA3->A3_NOME, dE3_VENCTO, nTotGBase, nTotGPorc, nTotGComis, .F.})
		Else
			Aadd(oGet1:aCols, {"S", SA3->A3_COD, SA3->A3_NOME, dE3_VENCTO, nTotGBase, nTotGPorc, nTotGComis, .F.})
		EndIf
		
		cLog += cPulaLinha
		cLog += " >> TOTAIS GERAIS COMISSOES DO GERENTE: " + aSubordinados[nX][1] + " - " + Posicione("SA3",1,xFilial("SA3")+aSubordinados[nX][1],"A3_NOME") + cPulaLinha
		cLog += " >> BASE COMISSÃO: " + Transform(nTotGBase,"@E 9,999,999,999,999.99") + cPulaLinha
		cLog += " >> % COMISSAO: " + Transform(nTotGPorc,"@E 999.99") + cPulaLinha
		cLog += " >> VLR COMISSÃO: " + Transform(nTotGComis,"@E 9,999,999,999,999.99") + cPulaLinha
		cLog += cPulaLinha
		
		nTotGBase 	:= 0 
		nTotGComis 	:= 0
		nTotGPorc	:= 0
		
	Next nX
	
	RestArea(aArea)
	
Return

/* Retorna o array com os codigos dos gerentes/supervisores e subordinados
aSubordinados
	{"XXXXXX",{"","","",...}}
	{"XXXXXX",{"","","",...}}
	...
*/
Static Function RetSubord(cLog, nOpc)
Local cQry := ""
Local aSubordinados := {}
Local aVends := {}
	
	If nOpc == 1
		cLog += "  >> SELEÇÃO DOS GERENTES..." + cPulaLinha
	Else
		cLog += "  >> SELEÇÃO DOS SUPERVISORES..." + cPulaLinha
	EndIf
	
	cQry := "SELECT DISTINCT(SA3.A3_COD) AS A3_COD," + cPulaLinha
	If nOpc == 1
		cQry += " CASE WHEN SA3_1.A3_GEREN IS NOT NULL" + cPulaLinha
	Else
		cQry += " CASE WHEN SA3_1.A3_SUPER IS NOT NULL" + cPulaLinha
	EndIf
	cQry += 	" THEN 'S'" + cPulaLinha
	cQry += 	" ELSE 'N'" + cPulaLinha
	If nOpc == 1
		cQry += " END AS GERENTE" + cPulaLinha
	Else
		cQry += " END AS SUPERVISOR" + cPulaLinha
	EndIf
	cQry += " FROM " + RetSqlName("SA3") + " SA3" + cPulaLinha
	cQry += " LEFT OUTER JOIN" + cPulaLinha
	cQry += " " + RetSqlName("SA3") + " SA3_1" + cPulaLinha
	cQry += " ON SA3_1.A3_FILIAL = SA3.A3_FILIAL" + cPulaLinha
	If nOpc == 1
		cQry += 	" AND SA3_1.A3_GEREN = SA3.A3_COD" + cPulaLinha
	Else
		cQry += 	" AND SA3_1.A3_SUPER = SA3.A3_COD" + cPulaLinha
	EndIf
	cQry += 	" AND SA3_1.D_E_L_E_T_ <> '*'" + cPulaLinha
	cQry += " WHERE" + cPulaLinha
	cQry += " SA3.D_E_L_E_T_ <> '*'" + cPulaLinha
	cQry += " AND SA3.A3_FILIAL = '" + xFilial("SA3") + "'" + cPulaLinha
	cQry += " AND SA3.A3_COD BETWEEN '" + cVendDe + "' AND '" + cVendAt + "'" + cPulaLinha
	If nOpc == 1
		cQry += " AND SA3_1.A3_GEREN IS NOT NULL" + cPulaLinha
	Else
		cQry += " AND SA3_1.A3_SUPER IS NOT NULL" + cPulaLinha
	EndIf
	cQry += " ORDER BY SA3.A3_COD" + cPulaLinha
	
	cLog += cPulaLinha
	cLog += " >> QUERY: "
	cLog += cPulaLinha
	cLog += cPulaLinha
	cLog += cQry
	cLog += cPulaLinha
	cLog += cPulaLinha
	
	If Select("QRYSA3") > 0
		QRYSA3->(DbCloseArea())
	EndIf
	
	cQry := ChangeQuery(cQry)
	TcQuery cQry New Alias "QRYSA3" // Cria uma nova area com o resultado do query
	
	QRYSA3->(dbGoTop())
	While QRYSA3->(!Eof())
		
		cLog += cPulaLinha
		If nOpc == 1
		cLog += "  >> SELEÇÃO DOS SUBORDINADOS DO GERENTE "+QRYSA3->A3_COD+" - "+Posicione("SA3",1,xFilial("SA3")+QRYSA3->A3_COD,"A3_NOME")+"..." + cPulaLinha
		Else
		cLog += "  >> SELEÇÃO DOS SUBORDINADOS DO SUPERVISOR "+QRYSA3->A3_COD+" - "+Posicione("SA3",1,xFilial("SA3")+QRYSA3->A3_COD,"A3_NOME")+"..." + cPulaLinha
		EndIf
		
		cQry := "SELECT SA3.*" + cPulaLinha
		cQry += " FROM " + RetSqlName("SA3") + " SA3" + cPulaLinha
		cQry += " WHERE" + cPulaLinha
		cQry += " SA3.D_E_L_E_T_ <> '*'" + cPulaLinha
		cQry += " AND SA3.A3_FILIAL = '" + xFilial("SA3") + "'" + cPulaLinha
		If nOpc == 1
	   		cQry += " AND SA3.A3_GEREN = '" + QRYSA3->A3_COD + "'" + cPulaLinha
		Else
	   		cQry += " AND SA3.A3_SUPER = '" + QRYSA3->A3_COD + "'" + cPulaLinha
		EndIf
		cQry += " ORDER BY SA3.A3_FILIAL, SA3.A3_COD" + cPulaLinha
		
		cLog += cPulaLinha
		cLog += " >> QUERY: "
		cLog += cPulaLinha
		cLog += cPulaLinha
		cLog += cQry
		cLog += cPulaLinha
		cLog += cPulaLinha
		
		If Select("QRYSUBO") > 0
			QRYSUBO->(DbCloseArea())
		EndIf
		
		cQry := ChangeQuery(cQry)
		TcQuery cQry New Alias "QRYSUBO" // Cria uma nova area com o resultado do query
		
		aVends := {}
		
		QRYSUBO->(dbGoTop())
		While QRYSUBO->(!Eof())
			aadd(aVends,QRYSUBO->A3_COD)
			QRYSUBO->(dbSkip())
		EndDo
		
		If Select("QRYSUBO") > 0
			QRYSUBO->(DbCloseArea())
		EndIf
		
		aadd(aSubordinados, {QRYSA3->A3_COD,aVends})
		QRYSA3->(dbSkip())
	EndDo

	If Select("QRYSA3") > 0
		QRYSA3->(DbCloseArea())
	EndIf
	
Return aSubordinados

/*/{Protheus.doc} GeraComiss
// Confirma a geração da comissão dos gerentes

@author Pablo Cavalcante
@since 03/06/2016
@version undefined

@type function
/*/
Static Function GeraComiss(cLog)
Local lRet := .F.

	If Len(oGet1:aCols) > 0 .and. !Empty(oGet1:aCols[1][aScan(oGet1:aHeader,{|x| AllTrim(x[2]) == "A3_COD"})])
		If MsgYesNo("Confirma a geração das comissões dos gerentes e/ou supervisores?","Atenção")
			MsAguarde({|| lRet := GeraSE3(@cLog)},"Aguarde","Gerando comissões...",.F.)
		EndIf
	Else
		MsgInfo("Não existem comissões a serem confirmadas. Favor processar novamente.","Atenção")
	EndIf

	If lRet
		MsgInfo("Comissões geradas com sucesso!","Atenção")
		oDlg:End()
	EndIf
	
Return lRet

/*/{Protheus.doc} GeraSE3
// Confirma a geração da comissão dos gerentes e/ou supervisores

@author Pablo Cavalcante
@since 03/06/2016
@version undefined

@type function
/*/
Static Function GeraSE3(cLog)

Local nX			:= 1
Local lRet 			:= .T.
Local aAuto 		:= {}
Local nPTipo 		:= aScan(oGet1:aHeader,{|x| AllTrim(x[2]) == "TIPO"})
Local nPA3_COD 		:= aScan(oGet1:aHeader,{|x| AllTrim(x[2]) == "A3_COD"})
Local nPA3_NOME 	:= aScan(oGet1:aHeader,{|x| AllTrim(x[2]) == "A3_NOME"})
Local nPE3_VENCTO 	:= aScan(oGet1:aHeader,{|x| AllTrim(x[2]) == "E3_VENCTO"})
Local nPE3_BASE 	:= aScan(oGet1:aHeader,{|x| AllTrim(x[2]) == "E3_BASE"})
Local nPE3_PORC 	:= aScan(oGet1:aHeader,{|x| AllTrim(x[2]) == "E3_PORC"})
Local nPE3_COMIS 	:= aScan(oGet1:aHeader,{|x| AllTrim(x[2]) == "E3_COMIS"})
Local cCliPadrao	:= GetMV("MV_CLIPAD")
Local cLojPadrao	:= GetMV("MV_LOJAPAD")

Private lMsErroAuto := .F.

BeginTran()

For nX:=1 to Len(oGet1:aCols)
    
	If oGet1:aCols[nX][nPE3_COMIS] > 0 
		
		aAuto := {}
		aAdd(aAuto, {"E3_VEND", oGet1:aCols[nX][nPA3_COD], Nil}) //Vendedor
		aAdd(aAuto, {"E3_NUM", GetSxeNum("SE3","E3_NUM"), Nil}) //No. Titulo
		aAdd(aAuto, {"E3_EMISSAO", dDataBase, Nil}) //Data  de  emissão do título referente ao pagamento de comissão.
		aAdd(aAuto, {"E3_SERIE", "", Nil}) //Serie N.F.
		aAdd(aAuto, {"E3_CODCLI",cCliPadrao, Nil}) //Cliente
		aAdd(aAuto, {"E3_LOJA",cLojPadrao, Nil}) //Loja
		aAdd(aAuto, {"E3_BASE", oGet1:aCols[nX][nPE3_BASE], Nil}) //Valor base do título para cálculo de comissão.
		aAdd(aAuto, {"E3_PORC", oGet1:aCols[nX][nPE3_PORC], Nil}) //Percentual incidente ao valor do título para cálculo de comissão.
		aAdd(aAuto, {"E3_COMIS", oGet1:aCols[nX][nPE3_COMIS], Nil}) //Valor da Comissão
		aAdd(aAuto, {"E3_PREFIXO", Iif(oGet1:aCols[nX][nPTipo]=="G","GER","SUP"), Nil}) //Prefixo
		aAdd(aAuto, {"E3_PARCELA", "", Nil}) //Parcela
		aAdd(aAuto, {"E3_SEQ", "", Nil}) //Sequencia
		aAdd(aAuto, {"E3_TIPO", "", Nil}) //Tipo do título que originou a comissão.
		aAdd(aAuto, {"E3_PEDIDO", "", Nil}) //No. Pedido
		aAdd(aAuto, {"E3_VENCTO", oGet1:aCols[nX][nPE3_VENCTO], Nil}) //Data de vencimento da comissão.
		aAdd(aAuto, {"E3_PROCCOM", "", Nil}) //Proc. Com.
		aAdd(aAuto, {"E3_MOEDA", "01", Nil}) //Moeda
		aAdd(aAuto, {"E3_CCUSTO", "", Nil}) //Centro de Custo
		aAdd(aAuto, {"E3_BAIEMI", "E", Nil}) //Comissao gerada: B - Pela Baixa ou E - Pela Emissão 
		aAdd(aAuto, {"E3_ORIGEM", "R", Nil}) //Origem da Comissao
		 	/*****************************************
			 	Origem do SE3
			 	"E" //Emissao Financeiro
			 	"B" //Baixa Financeiro
				"F" //Faturamento
				"D" //Devolucao de Venda
				"R" //Recalculo quando nao ha origem
				"L" //SigaLoja
				" " //Desconhecido
			*****************************************/
		aAdd(aAuto, {"E3_XCONTRA", "", Nil}) //Codigo do Contrato
		aAdd(aAuto, {"E3_XPARCON", "", Nil}) //Referencia do Parcelamento do Contrato
		aAdd(aAuto, {"E3_XPARCOM", "", Nil}) //Referencia do Parcelamento da Comissao
		aAdd(aAuto, {"E3_XORIGEM", "G", Nil})
			/*****************************************
				Origem do SE3
				"C" //Cemiterio (Contrato)
				"F" //Funeraria (Contrato)
				"R" //Recebimento de Cobranca (Motoqueiro)
				"V" //Venda Avulsa (Pedido de Venda e/ou Venda Direta)
				"G" //Comissão de Gerente e Supervisor
			*****************************************/
		
		lMsErroAuto := .F.
		
		MSExecAuto({|x,y| Mata490(x,y)}, aAuto, 3) //Inclusão de Comissão
						
		If lMsErroAuto
			//cLog += MostraErro("\temp") + cPulaLinha
			MostraErro()
			lRet := .F.
			Exit
		EndIf
    
    EndIf
    
Next nX

If lRet
	EndTran()
	ConfirmSx8()
Else
	DisarmTransaction()
EndIf

Return lRet

