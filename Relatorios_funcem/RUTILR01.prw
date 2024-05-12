#include 'protheus.ch'
#include 'topconn.ch'

/*/{Protheus.doc} RUTILR01
Impressão de etiqueta de clientes
@author TOTVS
@since 07/08/2018
@version P12
@param Nao recebe parametros            
@return nulo
/*/

/***********************/
User function RUTILR01()
/***********************/

Private lCemiterio 		:= SuperGetMV("MV_XCEMI",,.F.)
	
Private oFont8			:= TFont():New('Courier new',,8,,.F.,,,,.F.,.F.) 			//Fonte 8 Normal
Private oFont8N			:= TFont():New('Courier new',,8,,.T.,,,,.F.,.F.) 			//Fonte 8 Negrito
Private oFont10			:= TFont():New('Courier new',,10,,.F.,,,,.F.,.F.) 			//Fonte 10 Normal
Private oFont10N		:= TFont():New('Courier new',,10,,.T.,,,,.F.,.F.) 			//Fonte 10 Negrito
Private oFont10NS		:= TFont():New('Courier new',,10,,.T.,,,,,.T.,.F.) 			//Fonte 10 Negrito e Sublinhado
Private oFont13N		:= TFont():New('Arial',,13,,.T.,,,,.F.,.F.) 				//Fonte 13 Negrito
Private oFont14			:= TFont():New('Arial',,14,,.F.,,,,.F.,.F.) 				//Fonte 14 Normal
Private oFont14N		:= TFont():New('Arial',,14,,.T.,,,,.F.,.F.) 				//Fonte 14 Negrito
Private oFont14NI		:= TFont():New('Times New Roman',,14,,.T.,,,,.F.,.F.,.T.) 	//Fonte 14 Negrito e Itálico
Private oFont16			:= TFont():New('Arial',,16,,.F.,,,,.F.,.F.) 				//Fonte 16 
Private oFont16N		:= TFont():New('Arial',,16,,.T.,,,,.F.,.F.) 				//Fonte 16 Negrito
Private oFont16NI		:= TFont():New('Times New Roman',,16,,.T.,,,,.F.,.F.,.T.) 	//Fonte 16 Negrito e Itálico
Private oFont18			:= TFont():New("Arial",,18,,.F.,,,,,.F.,.F.)				//Fonte 18 Negrito
Private oFont18N		:= TFont():New("Arial",,18,,.T.,,,,,.F.,.F.)				//Fonte 18 Negrito

Private nLin, nCol 			
Private oRel			:= TmsPrinter():New("")
Private nPag			:= 0    
Private cPerg 			:= IIF(lCemiterio,"UTILR01C","UTILR01F")  

oRel:SetPaperSize(DMPAPER_A4)
oRel:SetPortrait()///Define a orientacao da impressao como retrato

AjustaSX1()

If !Pergunte(cPerg,.T.)
	MsgInfo("Abortado pelo Usuário!","Atenção!")
	Return	
Endif

NovaPag()
Processa({||GeraEtq()},"Aguarde")

oRel:Preview()

Return

/************************/
Static Function NovaPag()
/************************/

If nPag > 0
	oRel:EndPage()
Endif

nLin := 100

nPag++

oRel:StartPage() //Inicia uma nova pagina

Return

/************************/
Static Function GeraEtq()
/************************/

Local cQry 		:= ""
Local nQtdReg	:= 0
Local lEsquerda	:= .T.
Local nLinAux	:= 0

If Select("QCLI") > 0                                            
	QCLI->(DbCloseArea())
EndIf

cQry := "SELECT SA1.A1_NOME, SA1.A1_END, SA1.A1_BAIRRO, SA1.A1_CEP, SA1.A1_MUN, SA1.A1_EST,"
If lCemiterio
	cQry += " U00.U00_CODIGO AS CONTRATO"
Else
	cQry += " UF2.UF2_CODIGO AS CONTRATO"
Endif
cQry += " FROM"
cQry += " "+RetSQLName("SA1")+" SA1"

If lCemiterio
	
	cQry += " INNER JOIN"
	cQry += " "+RetSQLName("U00")+" U00"
	cQry += " ON  SA1.A1_COD 		= U00.U00_CLIENT"
	cQry += " AND SA1.A1_LOJA 		= U00.U00_LOJA"
	cQry += " AND U00.D_E_L_E_T_	= ' '"
	cQry += " AND U00.U00_FILIAL 	= '"+xFilial("U00")+"'"
	cQry += " AND U00.U00_CODIGO 	BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	
	If !Empty(MV_PAR07)
		cQry += " AND U00.U00_PLANO IN "+FormatIn(AllTrim(MV_PAR07),";")+""
	Endif
	
	If !Empty(MV_PAR08) .And. !Empty(MV_PAR09)
		cQry += " INNER JOIN"
		cQry += " "+RetSQLName("U20")+" U20"
		cQry += " ON  U00.U00_CODIGO	= U20.U20_CONTRA"
		cQry += " AND U20.U20_DATA 		BETWEEN '"+DToS(MV_PAR08)+"' AND '"+DToS(MV_PAR09)+"'"
		cQry += " AND U20.D_E_L_E_T_	= ' '"
		cQry += " AND U20.U20_FILIAL 	= '"+xFilial("U20")+"'"
	Endif
Else                                                                                                         
                                                                                                          
	cQry += " INNER JOIN"
	cQry += " "+RetSQLName("UF2")+" UF2"
	cQry += " ON  SA1.A1_COD 		= UF2.UF2_CLIENT"
	cQry += " AND SA1.A1_LOJA 		= UF2.UF2_LOJA"
	cQry += " AND UF2.D_E_L_E_T_	= ' '"
	cQry += " AND UF2.UF2_FILIAL 	= '"+xFilial("UF2")+"'"
	cQry += " AND UF2.UF2_CODIGO 	BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	
	If !Empty(MV_PAR07)
		cQry += " AND UF2.UF2_PLANO IN "+FormatIn(AllTrim(MV_PAR07),";")+""
	Endif

	If !Empty(MV_PAR08) .And. !Empty(MV_PAR09)
		cQry += " INNER JOIN"
		cQry += " "+RetSQLName("UF7")+" UF7"
		cQry += " ON  UF2.UF2_CODIGO	= UF7.UF7_CONTRA"
		cQry += " AND UF7.UF7_DATA 		BETWEEN '"+DToS(MV_PAR08)+"' AND '"+DToS(MV_PAR09)+"'"
		cQry += " AND UF7.D_E_L_E_T_	= ' '"
		cQry += " AND UF7.UF7_FILIAL 	= '"+xFilial("UF7")+"'"
	Endif
Endif

cQry += " WHERE SA1.D_E_L_E_T_ 	= ' '"
cQry += " AND SA1.A1_FILIAL 	= '"+xFilial("SA1")+"'"
cQry += " AND SA1.A1_COD	 	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR03+"'"
cQry += " AND SA1.A1_LOJA 		BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR04+"'"

cQry += " ORDER BY SA1.A1_NOME"

If Select("QCLI") > 0                                            
	QCLI->(DbCloseArea())
EndIf

cQry := ChangeQuery(cQry)
//MemoWrite("c:\temp\RUTILR01.txt",cQry)
TcQuery cQry NEW Alias "QCLI"

QCLI->(DbGoTop())
QCLI->(DbEval({|| nQtdReg++})) 
QCLI->(DbGoTop())

ProcRegua(nQtdReg)

While QCLI->(!EOF())

	IncProc()

	If nLin > 3200
		NovaPag()	
		lEsquerda := .T.
	Endif
	
	If lEsquerda
		nCol 		:= 50
		lEsquerda 	:= .F.
		nLinAux 	:= nLin
	Else
		nCol 		:= 1200
		lEsquerda 	:= .T.
		nLin 		:= nLinAux
	Endif

	oRel:Say(nLin,nCol,QCLI->A1_NOME,oFont8)
	oRel:Say(nLin,nCol+600,"INSCRICAO " + QCLI->CONTRATO,oFont8)
	
	nLin += 50
	
	oRel:Say(nLin,nCol,QCLI->A1_END,oFont8)

	nLin += 50

	oRel:Say(nLin,nCol,QCLI->A1_BAIRRO,oFont8)

	nLin += 50

	oRel:Say(nLin,nCol,"CEP " + Transform(QCLI->A1_CEP,"@R 99999-999"),oFont8)
	oRel:Say(nLin,nCol+300,AllTrim(QCLI->A1_MUN) + "-" + QCLI->A1_EST,oFont8)

	If lEsquerda
		nLin += 200
	Endif
	
	QCLI->(DbSkip())
EndDo

Return

/**************************/
Static Function AjustaSX1()
/**************************/

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

Local cF3		:= ""

U_xPutSX1(cPerg, "01","Do Cliente ?                 ","","","mv_ch1","C",6,0,0,"G",'',"SA1","","",;
"mv_par01","","","","","","","","","","","","","","","","",;
{'Informe o código inicial dos clientes a ','serem processados.                  '},aHelpEng,aHelpSpa) 

U_xPutSX1(cPerg, "02","Da Loja ?                 ","","","mv_ch3","C",2,0,0,"G",'',"","","",;
"mv_par03","","","","","","","","","","","","","","","","",;
{'Informe o código inicial das lojas a ','serem processados.                  '},aHelpEng,aHelpSpa) 

U_xPutSX1(cPerg, "03","Ate o Cliente ?              ","","","mv_ch2","C",6,0,0,"G",'',"SA1","","",;
"mv_par02","","","","ZZZZZZ","","","","","","","","","","","","",;
{'Informe o código final dos clientes a ','serem processados.                      '},aHelpEng,aHelpSpa) 

U_xPutSX1(cPerg, "04","Ate a Loja ?              ","","","mv_ch4","C",2,0,0,"G",'',"","","",;
"mv_par04","","","","ZZ","","","","","","","","","","","","",;
{'Informe o código final das lojas a ','serem processados.                      '},aHelpEng,aHelpSpa) 

cF3 := IIF(lCemiterio,'U00','UF2')
U_xPutSX1(cPerg, "05","Do Contrato  ?                 ","","","mv_ch5","C",6,0,0,"G",'',cF3,"","",;
"mv_par05","","","","","","","","","","","","","","","","",;
{'Informe o código inicial dos contratos a ','serem processados.                     '},aHelpEng,aHelpSpa) 

U_xPutSX1(cPerg, "06","Ate o Contrato  ?              ","","","mv_ch6","C",6,0,0,"G",'',cF3,"","",;
"mv_par06","","","","ZZZZZZ","","","","","","","","","","","","",;
{'Informe o código final dos contratos a ','serem processados.                       '},aHelpEng,aHelpSpa)

cF3 := IIF(lCemiterio,"U05MRK","UF0MRK")
U_xPutSX1(cPerg, "07","Plano  ?						  ","","","mv_ch7","C",99,0,0,"G","",cF3,"","",;
"mv_par07","","","","","","","","","","","","","","","","",;
aHelpPor,aHelpEng,aHelpSpa)

U_xPutSX1(cPerg, "08","Da data Reajuste  ?			  ","","","mv_ch8","D",8,0,0,"G","","","","",;
"mv_par08","","","","","","","","","","","","","","","","",;
aHelpPor,aHelpEng,aHelpSpa)

U_xPutSX1(cPerg, "09","Ate data Reajuste  ?			  ","","","mv_ch9","D",8,0,0,"G","","","","",;
"mv_par09","","","","","","","","","","","","","","","","",;
aHelpPor,aHelpEng,aHelpSpa)

Return 