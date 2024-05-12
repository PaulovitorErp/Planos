#include "protheus.ch" 
#include "topconn.ch"

/*/{Protheus.doc} RFUNE024
Contrato >> Manutenção Financeira >> Painel Financeiro
@author TOTVS
@since 02/06/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/
/***********************/
User Function RFUNE024()
/***********************/

Local cTitulo 		:= "Painel Financeiro"

Local oMenuLiq		:= Nil
Local oIt1Liq		:= Nil
Local oIt2Liq		:= Nil
Local oIt3Liq		:= Nil
Local oIt4Liq		:= Nil
Local oVirtusFin	:= Nil

Local oBmp1			:= NIL
Local oBmp2			:= NIL

Local oMenuBol		:= NIL
Local oIt1Bol		:= NIL
Local oIt2Bol		:= NIL
Local oMenuDiv		:= NIL
Local oIt1Div		:= NIL
Local oIt2Div		:= NIL
Local oIt3Div		:= NIL
Local oIt4Div		:= NIL
Local oIt5Div		:= NIL
Local oIt6Div		:= NIL
Local lIncTit		:= IIF(__cUserId $ SuperGetMv("MV_XINCTIT",.F.,"000000"),.T.,.F.)
Local lBaixaTitulo 	:= SuperGetMv("MV_XPNLBX",.F.,.F.)		

Private aCabec		:= {"","","Filial","Tipo","Descrição","Prefixo","Número","Parcela","Natureza","Portador","Depositaria","Num da Conta",;
						"Nome Banco","Cliente","Loja","Nome","Dt Emissão","Vencimento","Vencto Real","Valor","Valor Vencto","Valor c/ Juros","Saldo",;
						"Acréscimo","R_E_C_N_O_","Histórico","Parc.Titulo"}

Private aLarg		:= {20,20,30,30,60,30,40,30,60,30,40,40,60,40,30,140,60,60,60,60,60,60,60,60,40,60,30}

Private	oSay1		:= NIL	
Private oSay2		:= NIL
Private oSay3		:= NIL
Private oSay4		:= NIL
Private oSay5		:= NIL
Private oSay6		:= NIL
Private oSay7		:= NIL
Private oSay8		:= NIL
Private oSay9		:= NIL
Private oSay10		:= NIL
Private oSay11		:= NIL
Private oSay12		:= NIL
Private oSay14		:= NIL

Private oButton2	:= NIL

Private _oMark		:= LoadBitmap(GetResources(),"LBOK")
Private _oNoMark	:= LoadBitmap(GetResources(),"LBNO")

Private oCheckBox1	:= NIL
Private lCheckBox1	:= .T.

Private oLeg		:= NIL
Private oVerde		:= LoadBitmap(GetResources(),"BR_VERDE")
Private oLaranja	:= LoadBitmap(GetResources(),"BR_LARANJA")
Private oVermelha	:= LoadBitmap(GetResources(),"BR_VERMELHO")

Private aRegFin		:= {{.F.,oVerde,Space(Len(cFilAnt)),Space(6),Space(55),Space(3),Space(9),Space(1),Space(30),Space(3),Space(5),Space(10),;
						Space(40),Space(6),Space(2),Space(40),CToD(""),CToD(""),CToD(""),0,0,0,0,0,Space(9),Space(25),Space(TamSx3("E1_PARCELA")[1])}}

Private nCont 		:= 0 
Private nTot 		:= 0

Private nColOrder	:= 0 
Private cMod		:= "FUN" //Variavel de Controle de Modulo que esta sendo utilizado. 

Static oDlgPainel	:= NIL  

aObjects := {}
aSizeAut := MsAdvSize()

// inicio o objeto da classe de financeiro do Virtus ERP
oVirtusFin	:= VirtusFin():New()

//Largura, Altura, Modifica largura, Modifica altura
aAdd(aObjects, {100, 010, .F., .F.}) //Cabeçalho
aAdd(aObjects, {100, 070, .T., .T.}) //Browse
aAdd(aObjects, {100, 010, .T., .F.}) //Contadores e Legenda
aAdd(aObjects, {100, 010, .T., .F.}) //Botões

aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 4, 4 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlgPainel TITLE cTitulo From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

//Cabeçalho
@ aPosObj[1,1] - 30, aPosObj[1,2] SAY oSay1 PROMPT "Contrato:" SIZE 070, 007 OF oDlgPainel COLORS 0, 16777215 PIXEL
@ aPosObj[1,1] - 30, aPosObj[1,2] + 25 SAY oSay2 PROMPT UF2->UF2_CODIGO SIZE 200, 007 OF oDlgPainel COLORS 0, 16777215 PIXEL
@ aPosObj[1,1] - 17, aPosObj[1,2] SAY oSay3 PROMPT "Cliente:" SIZE 070, 007 OF oDlgPainel COLORS 0, 16777215 PIXEL
@ aPosObj[1,1] - 17, aPosObj[1,2] + 25 SAY oSay4 PROMPT AllTrim(UF2->UF2_CLIENT) + "/" + AllTrim(UF2->UF2_LOJA) + " - " + AllTrim(Posicione("SA1",1,xFilial("SA1") + UF2->UF2_CLIENT + UF2->UF2_LOJA , "A1_NOME")) SIZE 200, 007 OF oDlgPainel COLORS 0, 16777215 PIXEL

//Browse
oBrwManut := TWBrowse():New(aPosObj[2,1] - 16,aPosObj[2,2],aPosObj[2,4],aPosObj[2,3] - 70,,aCabec,aLarg,oDlgPainel,,,,,,,,,,,,.F.,,.T.,,.F.)
oBrwManut:SetArray(aRegFin)    
oBrwManut:blDblClick 	:= {|| MarkReg()}
oBrwManut:bHeaderClick 	:= {|oObj,nCol| IIF(nCol == 1 ,MarkAllReg(),)/*,(OrderGrid(oBrwManut,nCol), nColOrder := nCol)*/}
oBrwManut:bLine := {|| {IIF(aRegFin[oBrwManut:nAT][1],_oMark,_oNoMark),aRegFin[oBrwManut:nAT][2],aRegFin[oBrwManut:nAT][3],aRegFin[oBrwManut:nAT][4],;
					aRegFin[oBrwManut:nAT][5],aRegFin[oBrwManut:nAT][6],aRegFin[oBrwManut:nAT][7],aRegFin[oBrwManut:nAT][8],aRegFin[oBrwManut:nAT][9],;
					aRegFin[oBrwManut:nAT][10],aRegFin[oBrwManut:nAT][11],aRegFin[oBrwManut:nAT][12],aRegFin[oBrwManut:nAT][13],;
					aRegFin[oBrwManut:nAT][14],aRegFin[oBrwManut:nAT][15],aRegFin[oBrwManut:nAT][16],aRegFin[oBrwManut:nAT][17],;
					aRegFin[oBrwManut:nAT][18],aRegFin[oBrwManut:nAT][19],aRegFin[oBrwManut:nAT][20],aRegFin[oBrwManut:nAT][21],;
					aRegFin[oBrwManut:nAT][22],aRegFin[oBrwManut:nAT][23],aRegFin[oBrwManut:nAT][24],aRegFin[oBrwManut:nAT][25],;
					aRegFin[oBrwManut:nAT][26],aRegFin[oBrwManut:nAT][27]}} 

@ aPosObj[2,3] - 30, aPosObj[2,2] CHECKBOX oCheckBox1 VAR lCheckBox1 PROMPT "Considera juros por atraso"  Size 100, 007 PIXEL OF oDlgPainel COLORS 0, 16777215 PIXEL
oCheckBox1:bChange := ({||CliqueChk()})
			
//Contador e Totalizador
@ aPosObj[3,1] - 20, aPosObj[3,2] SAY oSay5 PROMPT "Registros selecionados:" SIZE 080, 007 OF oDlgPainel COLORS 0, 16777215 PIXEL
@ aPosObj[3,1] - 20, aPosObj[3,2] + 70 SAY oSay6 PROMPT cValToChar(nCont) SIZE 040, 007 OF oDlgPainel COLORS 0, 16777215 PIXEL

@ aPosObj[3,1] - 20, aPosObj[3,2] + 90 SAY oSay7 PROMPT ", totalizando R$" SIZE 080, 007 OF oDlgPainel COLORS 0, 16777215 PIXEL
@ aPosObj[3,1] - 20, aPosObj[3,2] + 130 SAY oSay8 PROMPT nTot SIZE 060, 007 OF oDlgPainel COLORS 0, 16777215 PIXEL Picture "@E 9,999,999,999,999.99"

//Legenda
@ aPosObj[3,1] - 5, aPosObj[3,2] SAY oSay9 PROMPT "Legenda:" SIZE 040, 007 OF oDlgPainel COLORS 0, 16777215 PIXEL

@ aPosObj[3,1] - 5, aPosObj[3,2] + 35 BITMAP oBmp1 ResName "BR_VERDE" OF oDlgPainel Size 10,10 NoBorder PIXEL
@ aPosObj[3,1] - 5, aPosObj[3,2] + 50 SAY oSay10 PROMPT "Titulo em aberto" SIZE 080, 007 OF oDlgPainel COLORS 0, 16777215 PIXEL

@ aPosObj[3,1] - 5, aPosObj[3,2] + 115 BITMAP oBmp2 ResName "BR_LARANJA" OF oDlgPainel Size 10,10 NoBorder PIXEL
@ aPosObj[3,1] - 5, aPosObj[3,2] + 130 SAY oSay12 PROMPT "Titulo em Recorrência" SIZE 080, 007 OF oDlgPainel COLORS 0, 16777215 PIXEL

@ aPosObj[3,1] - 5, aPosObj[3,2] + 205 BITMAP oBmp2 ResName "BR_VERMELHO" OF oDlgPainel Size 10,10 NoBorder PIXEL
@ aPosObj[3,1] - 5, aPosObj[3,2] + 220 SAY oSay12 PROMPT "Titulo Vencido" SIZE 080, 007 OF oDlgPainel COLORS 0, 16777215 PIXEL

//Linha horizontal
@ aPosObj[4,1] - 15, aPosObj[4,2] SAY oSay14 PROMPT Repl("_",aPosObj[2,4]) SIZE aPosObj[2,4], 007 OF oDlgPainel COLORS CLR_GRAY, 16777215 PIXEL

//Botões
// Cria Menu Fatura
oMenuLiq := TMenu():New(0,0,0,0,.T.)   

// Adiciona itens no Menu liquidacao
oIt1Liq := TMenuItem():New(oDlgPainel,"Gerar",,,,{|| Processa({|| oVirtusFin:ExecLiquidacao( 1 , "F", UF2->UF2_CODIGO ),"Aguarde"})},,,,,,,,,.T.)
oIt2Liq := TMenuItem():New(oDlgPainel,"Cancelar",,,,{|| Processa({|| oVirtusFin:ExecLiquidacao( 3, "F", UF2->UF2_CODIGO, aRegFin[oBrwManut:nAT][6], aRegFin[oBrwManut:nAT][7], aRegFin[oBrwManut:nAT][27], aRegFin[oBrwManut:nAT][4]) ,"Aguarde"})} ,,,,,,,,,.T.)
oIt3Liq := TMenuItem():New(oDlgPainel,"Detalhar",,,,{|| Processa({|| oVirtusFin:ExecLiquidacao( 2, "F", UF2->UF2_CODIGO, aRegFin[oBrwManut:nAT][6], aRegFin[oBrwManut:nAT][7], aRegFin[oBrwManut:nAT][27], aRegFin[oBrwManut:nAT][4]) ,"Aguarde"}) } ,,,,,,,,,.T.)
oIt4Liq := TMenuItem():New(oDlgPainel,"Reliquidar",,,,{|| Processa({|| oVirtusFin:ExecLiquidacao( 4, "F", UF2->UF2_CODIGO, aRegFin[oBrwManut:nAT][6], aRegFin[oBrwManut:nAT][7], aRegFin[oBrwManut:nAT][27], aRegFin[oBrwManut:nAT][4]),"Aguarde"}) } ,,,,,,,,,.T.)

oMenuLiq:Add(oIt1Liq)
oMenuLiq:Add(oIt2Liq)
oMenuLiq:Add(oIt3Liq)
oMenuLiq:Add(oIt4Liq)

@ aPosObj[4,1] - 3, aPosObj[4,2] BUTTON oButton1 PROMPT "Liquidação" SIZE 050, 010 OF oDlgPainel PIXEL  
oButton1:SetPopupMenu(oMenuLiq)

// Cria Menu Boleto
oMenuBol := TMenu():New(0,0,0,0,.T.)
// Adiciona itens no Menu Boleto
oIt1Bol := TMenuItem():New(oDlgPainel,"Gerar/Imprimir",,,,{|| U_RCPGA24A(UF2->UF2_CODIGO,aRegFin)} ,,,,,,,,,.T.)
oIt2Bol := TMenuItem():New(oDlgPainel,"Transferir",,,,{|| TransBol(aRegFin[oBrwManut:nAT][25])} ,,,,,,,,,.T.)

oMenuBol:Add(oIt1Bol)
oMenuBol:Add(oIt2Bol)

@ aPosObj[4,1] - 3, aPosObj[4,2] + 60 BUTTON oButton2 PROMPT "Boleto" SIZE 050, 010 OF oDlgPainel PIXEL
oButton2:SetPopupMenu(oMenuBol)

//valido se ativa a baixa de titulo pelo painel financeiro
if lBaixaTitulo

	@ aPosObj[4,1] - 3, aPosObj[4,2] + 120 BUTTON oButton3 PROMPT "Baixar" SIZE 050, 010 OF oDlgPainel ACTION Liq(aRegFin[oBrwManut:nAT][25]) PIXEL WHEN lBaixaTitulo  

endif

@ aPosObj[4,1] - 1, aPosObj[4,2] + 185 SAY oSay11 PROMPT "|" SIZE 020, 007 OF oDlgPainel COLORS CLR_BLUE, 16777215 PIXEL

// Cria Menu Diversos
oMenuDiv := TMenu():New(0,0,0,0,.T.)

// Adiciona itens no Menu Diversos
oIt1Div := TMenuItem():New(oDlgPainel,"Remover da Recorrência",,,,{|| RemoveRec(aRegFin) },,,,,,,,,.T.)
oIt2Div := TMenuItem():New(oDlgPainel,"Alterar Forma de Pagamento",,,,{||U_UVIND12("F")},,,,,,,,,.T.)
oIt3Div := TMenuItem():New(oDlgPainel,"Alterar Bco. Cobrança",,,,{||SelecionaBanco()},,,,,,,,,.T.)
oIt4Div := TMenuItem():New(oDlgPainel,"Alterar Título",,,,{||AltTit()},,,,,,,,,.T.)
oIt5Div := TMenuItem():New(oDlgPainel,"Posição do Cliente",,,,{||PosCli()},,,,,,,,,.T.)

If lIncTit
	oIt6Div := TMenuItem():New(oDlgPainel,"Incluir Titulo",,,,{||IncTit()},,,,,,,,,.T.)
Endif

oMenuDiv:Add(oIt1Div)
oMenuDiv:Add(oIt2Div)
oMenuDiv:Add(oIt3Div)
oMenuDiv:Add(oIt4Div)
oMenuDiv:Add(oIt5Div)

If lIncTit
	oMenuDiv:Add(oIt6Div)
Endif

@ aPosObj[4,1] - 3, aPosObj[4,2] + 190 BUTTON oButton4 PROMPT "Diversos" SIZE 050, 010 OF oDlgPainel PIXEL
oButton4:SetPopupMenu(oMenuDiv)

@ aPosObj[4,1] - 3, aPosObj[4,4] - 110 BUTTON oButton5 PROMPT "Imprimir Grade" SIZE 060,010 OF oDlgPainel ACTION ImpGrid(aRegFin) PIXEL  
@ aPosObj[4,1] - 3, aPosObj[4,4] - 40 BUTTON oButton6 PROMPT "Fechar" SIZE 040, 010 OF oDlgPainel ACTION oDlgPainel:End() PIXEL  

Processa({|| Filtro(),"Aguarde"})

ACTIVATE MSDIALOG oDlgPainel CENTERED 

Return  

/**************************/
Static Function CliqueChk()                                                                                                                
/**************************/

Local nI

nTot := 0

For nI := 1 To Len(aRegFin)
	
	If aRegFin[nI][1]
		
		If lCheckBox1
		
			If Val(StrTran(StrTran(aRegFin[nI][22],".",""),",",".")) > 0
				nTot += Val(StrTran(StrTran(aRegFin[nI][22],".",""),",","."))//Valor c/ Juros
			Endif
		Else
		
			If Val(StrTran(StrTran(aRegFin[nI][21],".",""),",",".")) > 0
				nTot += Val(StrTran(StrTran(aRegFin[nI][21],".",""),",","."))//Valor Vencto
			Endif
		Endif
	Endif
Next

oBrwManut:Refresh()

oSay8:Refresh()

Return

/***********************/
Static Function Filtro()
/***********************/

Local cQry 		:= ""
Local cTpTit	:= ""
Local oSX5		:= UGetSxFile():New 
Local aSX5		:= {}

nCont	:= 0
nTot	:= 0

aSize(aRegFin,0) //Limpa o array

If Select("QRYFIN") > 0
	QRYFIN->(dbCloseArea())
Endif

cQry := "SELECT SE1.E1_FILIAL,"
cQry += " SE1.E1_TIPO,"
cQry += " SE1.E1_PREFIXO,"
cQry += " SE1.E1_NUM,"
cQry += " SE1.E1_XPARCON," 
cQry += " SED.ED_DESCRIC," 
cQry += " SE1.E1_PORTADO," 
cQry += " SE1.E1_AGEDEP,"
cQry += " SE1.E1_CONTA,"
cQry += " SA6.A6_NOME,"
cQry += " SE1.E1_CLIENTE," 
cQry += " SE1.E1_LOJA," 
cQry += " SA1.A1_NOME," 
cQry += " SE1.E1_EMISSAO," 
cQry += " SE1.E1_VENCTO," 
cQry += " SE1.E1_VENCREA," 
cQry += " SE1.E1_VALOR," 
cQry += " SE1.E1_SALDO," 
cQry += " SE1.E1_ACRESC," 
cQry += " SE1.R_E_C_N_O_ AS RECNO,"
cQry += " SE1.E1_PARCELA," 
cQry += " SE1.E1_HIST," 
cQry += " SE1.E1_XFORPG"
cQry += " FROM "+RetSqlName("SE1")+" SE1	INNER JOIN "+RetSqlName("SED")+" SED 	ON SE1.E1_NATUREZ	= SED.ED_CODIGO" 
cQry += "																			AND SED.D_E_L_E_T_	<> '*'"
cQry += " 																			AND SED.ED_FILIAL	= '"+xFilial("SED")+"'"

cQry += " 									INNER JOIN "+RetSqlName("SA1")+" SA1	ON SE1.E1_CLIENTE	= SA1.A1_COD"   
cQry += " 																			AND SE1.E1_LOJA		= SA1.A1_LOJA"   
cQry += " 																			AND SA1.D_E_L_E_T_	<> '*'"
cQry += " 																			AND SA1.A1_FILIAL	= '"+xFilial("SA1")+"'"

cQry += " 									LEFT JOIN "+RetSqlName("SA6")+" SA6		ON SE1.E1_PORTADO	= SA6.A6_COD"
cQry += " 																			AND SE1.E1_AGEDEP	= SA6.A6_AGENCIA"
cQry += " 																			AND SE1.E1_CONTA	= SA6.A6_NUMCON"
cQry += " 																			AND SA6.D_E_L_E_T_	<> '*'"
cQry += " 																			AND SA6.A6_FILIAL	= '"+xFilial("SA6")+"'"

cQry += " WHERE SE1.D_E_L_E_T_	<> '*'"
cQry += " AND SE1.E1_FILIAL		= '"+xFilial("SE1")+"'" 
cQry += " AND SE1.E1_XCTRFUN	= '"+UF2->UF2_CODIGO+"'"
cQRY += " AND SE1.E1_SALDO		> 0"
cQry += " ORDER BY 2,3,4,5"

cQry := ChangeQuery(cQry)
//MemoWrite("c:\temp\RCPGE003.txt",cQry)
TcQuery cQry NEW Alias "QRYFIN"

ProcRegua(1)

If QRYFIN->(!EOF())

	DbSelectArea("SX5")
	SX5->(DbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE

	While QRYFIN->(!EOF())
	
		//Legenda
		Do Case
			Case ValForPg(QRYFIN->E1_XFORPG)
				oLeg := oLaranja
			Case SToD(QRYFIN->E1_VENCREA) < dDataBase
				oLeg := oVermelha
			OtherWise
				oLeg := oVerde
		EndCase
		
		aSX5 := oSX5:GetInfoSX5("05",QRYFIN->E1_TIPO)

		If Len(aSX5) > 0
			cTpTit := aSX5[1,2]:cDESCRICAO
		Else
			cTpTit := Space(55)
		Endif
		
	    aAdd(aRegFin,{.F.,; 																									//[1]
	    			oLeg,;  																									//[2]
	    			QRYFIN->E1_FILIAL,; 																						//[3]
	    			QRYFIN->E1_TIPO,; 																							//[4]
	    			AllTrim(cTpTit),; 																							//[5]
	    			QRYFIN->E1_PREFIXO,; 																						//[6]
	    			QRYFIN->E1_NUM,; 																							//[7]
	    			QRYFIN->E1_XPARCON,; 																						//[8]
	    			AllTrim(QRYFIN->ED_DESCRIC),; 																				//[9]
	    			QRYFIN->E1_PORTADO,; 																						//[10]
					QRYFIN->E1_AGEDEP,; 																						//[11]
					QRYFIN->E1_CONTA,; 																							//[12]
					AllTrim(QRYFIN->A6_NOME),; 																					//[13]
	    			QRYFIN->E1_CLIENTE,; 																						//[14]
	    			QRYFIN->E1_LOJA,; 																							//[15]
	    			AllTrim(QRYFIN->A1_NOME),; 																					//[16]
	    			DToC(SToD(QRYFIN->E1_EMISSAO)),; 																			//[17]
	    			DToC(SToD(QRYFIN->E1_VENCTO)),; 																			//[18]
	    			DToC(SToD(QRYFIN->E1_VENCREA)),; 																			//[19]
	    			Transform(QRYFIN->E1_VALOR,"@E 9,999,999,999,999.99"),; 													//[20]
	    			Transform(QRYFIN->E1_VALOR + QRYFIN->E1_ACRESC,"@E 9,999,999,999,999.99"),; 								//[21]
	    			Transform(U_RCPGE005(QRYFIN->E1_VALOR,QRYFIN->E1_ACRESC,SToD(QRYFIN->E1_VENCREA),QRYFIN->RECNO),"@E 9,999,999,999,999.99"),;	//[22]
	    			Transform(QRYFIN->E1_SALDO,"@E 9,999,999,999,999.99"),; 													//[23]
	    			Transform(QRYFIN->E1_ACRESC,"@E 9,999,999,999,999.99"),; 													//[24]
	    			QRYFIN->RECNO,;																								//[25]
	    			QRYFIN->E1_HIST,;																							//[26]
						QRYFIN->E1_PARCELA})								    														//[27]
	    			
		QRYFIN->(dbSkip())
    EndDo
Else
	aRegFin	:= {{.F.,oVerde,Space(Len(cFilAnt)),Space(6),Space(55),Space(3),Space(9),Space(1),Space(30),Space(3),Space(5),Space(10),;
				Space(40),Space(6),Space(2),Space(40),CToD(""),CToD(""),CToD(""),0,0,0,0,0,Space(9),Space(25),Space(TamSx3("E1_PARCELA")[1])}}                                                                               
EndIf

IncProc()

oBrwManut:SetArray(aRegFin) 
oBrwManut:bLine := {|| {IIF(aRegFin[oBrwManut:nAT][1],_oMark,_oNoMark),aRegFin[oBrwManut:nAT][2],aRegFin[oBrwManut:nAT][3],aRegFin[oBrwManut:nAT][4],;
					aRegFin[oBrwManut:nAT][5],aRegFin[oBrwManut:nAT][6],aRegFin[oBrwManut:nAT][7],aRegFin[oBrwManut:nAT][8],aRegFin[oBrwManut:nAT][9],;
					aRegFin[oBrwManut:nAT][10],aRegFin[oBrwManut:nAT][11],aRegFin[oBrwManut:nAT][12],aRegFin[oBrwManut:nAT][13],;
					aRegFin[oBrwManut:nAT][14],aRegFin[oBrwManut:nAT][15],aRegFin[oBrwManut:nAT][16],aRegFin[oBrwManut:nAT][17],;
					aRegFin[oBrwManut:nAT][18],aRegFin[oBrwManut:nAT][19],aRegFin[oBrwManut:nAT][20],aRegFin[oBrwManut:nAT][21],;
					aRegFin[oBrwManut:nAT][22],aRegFin[oBrwManut:nAT][23],aRegFin[oBrwManut:nAT][24],aRegFin[oBrwManut:nAT][25],;
					aRegFin[oBrwManut:nAT][26],aRegFin[oBrwManut:nAT][27]}}  

oBrwManut:Refresh()

oSay6:Refresh() //Contador
oSay8:Refresh() //Totalizador

If Select("QRYFIN") > 0
	QRYFIN->(dbCloseArea())
Endif

oBrwManut:SetFocus()

Return 

/************************/
Static Function MarkReg()
/************************/

If !Empty(aRegFin[oBrwManut:nAT][4]) //Tipo/Registro válido

	If aRegFin[oBrwManut:nAT][1]

		aRegFin[oBrwManut:nAT][1] := .F.
		nCont--

		If lCheckBox1

			If Val(StrTran(StrTran(aRegFin[oBrwManut:nAT][22],".",""),",",".")) > 0
				nTot -= Val(StrTran(StrTran(aRegFin[oBrwManut:nAT][22],".",""),",",".")) //Valor c/ Juros
			Endif
		Else
			If Val(StrTran(StrTran(aRegFin[oBrwManut:nAT][21],".",""),",",".")) > 0
				nTot -= Val(StrTran(StrTran(aRegFin[oBrwManut:nAT][21],".",""),",",".")) //Valor Vencto
			Endif
		Endif
	Else
		aRegFin[oBrwManut:nAT][1] := .T.
		nCont++
		
		If lCheckBox1
		
			If Val(StrTran(StrTran(aRegFin[oBrwManut:nAT][22],".",""),",",".")) > 0
				nTot += Val(StrTran(StrTran(aRegFin[oBrwManut:nAT][22],".",""),",",".")) //Valor c/ Juros
			Endif
		Else
			If Val(StrTran(StrTran(aRegFin[oBrwManut:nAT][21],".",""),",",".")) > 0
				nTot += Val(StrTran(StrTran(aRegFin[oBrwManut:nAT][21],".",""),",",".")) //Valor Vencto
			Endif
		Endif
	Endif
Endif

oBrwManut:Refresh()

oSay6:Refresh()
oSay8:Refresh()

Return

/***************************/
Static Function MarkAllReg()
/***************************/                 

Local nI

nCont	:= 0
nTot  	:= 0

If !Empty(aRegFin[oBrwManut:nAT][4]) //Tipo/Registro válido
	
	If aRegFin[oBrwManut:nAT][1]
		
		For nI := 1 To Len(aRegFin)
			aRegFin[nI][1] := .F.
		Next
	Else
		
		For nI := 1 To Len(aRegFin)

			aRegFin[nI][1] := .T.
			nCont++                             

			If lCheckBox1

				If Val(StrTran(StrTran(aRegFin[nI][22],".",""),",",".")) > 0
					nTot += Val(StrTran(StrTran(aRegFin[nI][22],".",""),",","."))//Valor c/ Juros
				Endif
			Else
				If Val(StrTran(StrTran(aRegFin[nI][21],".",""),",",".")) > 0
					nTot += Val(StrTran(StrTran(aRegFin[nI][21],".",""),",","."))//Valor Vencto
				Endif
			Endif
		Next
	Endif
Endif

oBrwManut:Refresh()

oSay6:Refresh()
oSay8:Refresh()

Return

/***********************************/
Static Function TransBol(_nRecnoSE1)
 /***********************************/

Local nI       
Local nCont		:= 0
Local lAux 		:= .T.     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se data do movimento não é menor que data limite de ³
//³ movimentacao no financeiro									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !DtMovFin()
	Return
Endif

For nI := 1 To Len(aRegFin)

	If aRegFin[nI][1] == .T.
		nCont++
	Endif
Next

If nCont == 0
	MsgInfo("Nenhum registro selecionado!!","Atenção")
	lAux := .F.
ElseIf nCont > 1
	MsgInfo("A transferência deve ser realizada para um título de cada vez!!","Atenção")
	lAux := .F.           
Endif

If lAux  

	If _nRecnoSE1 <> 0
		If !MsgYesNo("Haverá a transferência do registro selecionado, deseja continuar?")
			Return
		Else  
			DbSelectArea("SE1")
			SE1->(DbGoto(_nRecnoSE1))

			FINA060(2) //Função padrão
			Processa({|| Filtro(),"Aguarde"})
		Endif
	Else
		MsgInfo("Registro não localizado!!","Atenção")
	Endif
Endif

Return

/******************************/
Static Function Liq(_nRecnoSE1)
/******************************/

Local nI  
Local nCont		:= 0
Local lAux 		:= .T.
Local nSaldo	:= 0 

Local lRet		:= .T. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se data do movimento não é menor que data limite de ³
//³ movimentacao no financeiro									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !DtMovFin()
	Return
Endif

For nI := 1 To Len(aRegFin)

	If aRegFin[nI][1] == .T.
		nSaldo := Val(StrTran(StrTran(aRegFin[nI][23],".",""),",",".")) //Saldo
		nCont++
	Endif
Next

If nCont == 0
	MsgInfo("Nenhum registro selecionado!!","Atenção")
	lAux := .F.
ElseIf nCont > 1
	MsgInfo("A liquidação deve ser realizada para um título de cada vez!!","Atenção")
	lAux := .F.           
Endif

If lAux  
	
	If nSaldo > 0	
	
		If _nRecnoSE1 <> 0

			If !MsgYesNo("Haverá a liquidação do registro selecionado, deseja continuar?")
				Return
			Else  
				DbSelectArea("SE1")
				SE1->(DbGoto(_nRecnoSE1))

				INCLUI := .F.
				ALTERA := .T.
	
				lRet := FINA070(,3,.T.) //Função padrão

				If lRet
					Processa({|| Filtro(),"Aguarde"})
				Endif
			Endif
		Else
			MsgInfo("Registro não localizado!!","Atenção")
		Endif
	Else
		MsgInfo("Título já liquidado, operação não permitida!!","Atenção")
	Endif
Endif  

Return   


/*/{Protheus.doc} SelencionaBanco
//Seleciona Banco para alteracao do titulo
@author rapha
@since 21/06/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function SelecionaBanco() 

Local nI			:= 0 
Local nAux			:= 0

Local oButton1		:= NIL
Local oButton2		:= NIL

Private oSay1		:= NIL
Private oSay2		:= NIL
Private oSay3		:= NIL
Private oSay4		:= NIL

Private oBco		:= NIL
Private oAgencia	:= NIL
Private oConta      := NIL  
Private oNomeBco	:= NIL
Private cBco 		:= Space(3)
Private cAgencia	:= Space(5)
Private cConta		:= Space(10)
Private cNomeBco	:= ""
Static oDlgBco    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se data do movimento não é menor que data limite de ³
//³ movimentacao no financeiro									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !DtMovFin()
	Return
Endif

For nI := 1 To Len(aRegFin)
	If aRegFin[nI][1] == .T.
		nAux++
	Endif
Next

If nAux == 0
	MsgInfo("Nenhum registro selecionado!!","Atenção")	
	Return
Endif

U60->(DbSetOrder(1)) //U60_FILIAL + U60_CODIGO

//valido se a forma de pagamento e refente assinatura de pagamento
if !Empty(UF2->UF2_FORPG) .And. U60->(DbSeek(xFilial("U60")+Alltrim(UF2->UF2_FORPG)))
	
	MsgAlert("A Forma de Pagamento do contrato é referente a pagamento por assinatura, portanto não é possivel alterar o banco de cobrança!")
	Return()
	
endif
 
DEFINE MSDIALOG oDlgBco TITLE "Selecionar Banco Cobrança" From 000,000 TO 115,400 PIXEL

@ 005, 005 SAY oSay1 PROMPT "Portador:" SIZE 040, 007 OF oDlgBco COLORS CLR_BLUE, 16777215 PIXEL
@ 005, 040 MSGET oBco VAR cBco SIZE 020, 010 OF oDlgBco COLORS 0, 16777215 HASBUTTON PIXEL Valid IIF(!Empty(cBco),ValBco(),.T.) F3 "SA6" Picture "@!"
@ 005, 080 SAY oNomeBco PROMPT cNomeBco SIZE 120, 007 OF oDlgBco COLORS 0, 16777215 PIXEL
@ 018, 005 SAY oSay2 PROMPT "Agência:" SIZE 040, 007 OF oDlgBco COLORS 0, 16777215 PIXEL
@ 018, 040 MSGET oAgencia VAR cAgencia SIZE 030, 010 OF oDlgBco COLORS 0, 16777215 PIXEL WHEN .F.
@ 018, 080 SAY oSay3 PROMPT "Conta:" SIZE 040, 007 OF oDlgBco COLORS 0, 16777215 PIXEL
@ 018, 115 MSGET oConta VAR cConta SIZE 060, 010 OF oDlgBco COLORS 0, 16777215 PIXEL WHEN .F.

//Linha horizontal
@ 030, 005 SAY oSay4 PROMPT Repl("_",190) SIZE 190, 007 OF oDlgBco COLORS CLR_GRAY, 16777215 PIXEL

@ 041, 110 BUTTON oButton1 PROMPT "Confirmar" SIZE 040, 010 OF oDlgBco ACTION ConfSel() PIXEL  
@ 041, 155 BUTTON oButton2 PROMPT "Fechar" SIZE 040, 010 OF oDlgBco ACTION oDlgBco:End() PIXEL  

ACTIVATE MSDIALOG oDlgBco CENTERED

Return()

/***********************/
Static Function ValBco() 
/***********************/

Local lRet := .T.

dbSelectArea("SA6")
SA6->(dbSetOrder(1)) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON

If !Empty(cBco)                                                                                         
	
	cAgencia	:= ""
	cConta		:= ""	
	
	If !SA6->(DbSeek(xFilial("SA6")+cBco+cAgencia+cConta)) //Compartilhado

		MsgInfo("Banco inválido!!","Atenção")

		cNomeBco 	:= ""
		cAgencia	:= ""
		cConta		:= ""

		lRet 		:= .F.
	Else
		cNomeBco	:= SA6->A6_NOME
		cAgencia	:= SA6->A6_AGENCIA
		cConta		:= SA6->A6_NUMCON
	Endif
Else
	cNomeBco 	:= ""
	cAgencia	:= ""
	cConta		:= ""
Endif

oNomeBco:Refresh()
oConta:Refresh()
oAgencia:Refresh()

Return lRet               

/************************/
Static Function ConfSel()          
/************************/      

Local nI       

If !Empty(cBco)

	dbSelectArea("SE1")
	
	For nI := 1 To Len(aRegFin)

		If aRegFin[nI][1] == .T.
			
			SE1->(DbGoTo(aRegFin[nI][25])) //R_E_C_N_O_
			
			If !Empty(SE1->E1_NUMBOR)
			
				//Exclui título do borderô
				ExcBord(aRegFin[nI][25]) //R_E_C_N_O_
			
			EndIf
			
			if RecLock("SE1",.F.)

				SE1->E1_SITUACA	:= "0"
				SE1->E1_OCORREN	:= ""
				SE1->E1_NUMBOR	:= ""
				SE1->E1_DATABOR	:= CTOD("  /  /    ")
				SE1->E1_NUMBCO  := ""
				SE1->E1_CODBAR  := ""
				SE1->E1_XDVNNUM := ""
				SE1->E1_IDCNAB	:= ""
				SE1->E1_PORTADO := cBco			
				SE1->E1_AGEDEP	:= cAgencia
				SE1->E1_CONTA	:= cConta
				SE1->E1_XFORPG	:= UF2->UF2_FORPG 
				
				SE1->(MsUnLock())

			endif
			
			SE1->(MsUnlock())
		
		Endif
	
	Next
		
	MsgInfo("Alteração realizada com sucesso!!","Atenção")	
	oDlgBco:End()
	Processa({|| Filtro(),"Aguarde"}) 
Else
	MsgInfo("Campo <Portador> obrigatório!!","Atenção")
Endif    

Return                    

/**********************/
Static Function Reneg()
/**********************/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se data do movimento não é menor que data limite de ³
//³ movimentacao no financeiro									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !DtMovFin()
	Return
Endif

Alert("Rotina em desenvolvimento.")

Return  

/***********************/
Static Function EstRen()
/***********************/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se data do movimento não é menor que data limite de ³
//³ movimentacao no financeiro									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !DtMovFin()
	Return
Endif

Alert("Rotina em desenvolvimento.")

Return 

/***********************/
Static Function AltTit()
/***********************/

Local nI  
Local nCont		:= 0 

Local nRecSE1	:= 0 

Private lIntegracao := .F.
Private LF040AUTO	:= .F.
Private cCadastro 	:= "Contas a Receber - Alterar"

aAdd( aRotina,	{ "Pesquisar", "AxPesqui" , 0 , 1,,.F. })
aAdd( aRotina,	{ "Visualizar" ,"FA280Visua", 0 , 2})
aAdd( aRotina,	{ "Incluir" ,"FA040Inclu", 0 , 3}) 
aAdd( aRotina,	{ "Alterar" ,"FA040Alter", 0 , 4}) 
aAdd( aRotina,	{ "Excluir" ,"FA040Delet", 0 , 5}) 
aAdd( aRotina,	{ "Substituir" ,"FA040Subst", 0 , 6}) 
aAdd( aRotina,	{ "Conhecimento" ,"MSDOCUMENT"  , 0 , 4})
aAdd( aRotina,	{ "Tracker Contábil" ,"CTBC662"  , 0 , 7})
aAdd( aRotina,	{ "Legenda" ,"FA040Legenda", 0 , 6, ,.F.}) 
aAdd( aRotina,	{ "Histórico do Título" ,"FinaCsLog", 0 , 8}) 

For nI := 1 To Len(aRegFin)

	If aRegFin[nI][1] == .T.
		
		nRecSE1	:= aRegFin[nI][25] //R_E_C_N_O_
		nCont++
	Endif
Next

If nCont == 0
	MsgInfo("Nenhum registro selecionado!!","Atenção")
	Return
Endif
                         
If nCont > 1
	MsgInfo("A alteração de Título deve ser realizada para um título de cada vez!!","Atenção")
	Return
Endif

SE1->(DbSelectArea("SE1"))
SE1->(DbGoTo(nRecSE1))

INCLUI := .F.
ALTERA := .T.          
              
FA040Alter("SE1",nRecSE1,4)

Return 

/*******************************/
Static Function ExcBord(nRecSE1)
/*******************************/

//Se houver borderô associado, exclui
DbSelectArea("SE1")
SE1->(DbGoTo(nRecSE1))

DbSelectArea("SEA")
SEA->(DbSetOrder(1)) //EA_FILIAL+EA_NUMBOR+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA

If SEA->(DbSeek(xFilial("SEA")+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))

	RecLock("SEA")
	
	SEA->(DbDelete())
	
	SEA->(MsUnlock())
	
endif

Return

/*******************************/
Static Function ImpGrid(aRegFin)
/*******************************/

Local oReport 

Private _aRegFin := aRegFin

oReport := ReportDef()
oReport:PrintDialog()

Return

/**************************/
Static Function ReportDef()
/**************************/

Local oReport

Local oSection1

Local cTitle    := "Relação de Títulos - Painel Financeiro"

oReport:= TReport():New("Relação de Títulos",cTitle,"Relação de Títulos",{|oReport| PrintReport(oReport)},"RELACAO DE TITULOS")
oReport:SetLandscape()	//Define a orientação do relatório como paisagem(Lanscape) 
oReport:HideParamPage()

oSection1 := TRSection():New(oReport,"PainelFin",{"aRegFin"})
oSection1:SetHeaderPage(.F.)
oSection1:SetHeaderSection(.T.)

TRCell():New(oSection1,"col1",,	"FILIAL"			,,)
TRCell():New(oSection1,"col2",, "TIPO"				,,)
TRCell():New(oSection1,"col3",, "DESCRICAO"			,,20)
TRCell():New(oSection1,"col4",, "PREFIXO"			,,)
TRCell():New(oSection1,"col5",,	"NUMERO"			,,9)
TRCell():New(oSection1,"col6",,	"PARCELA"			,,)
TRCell():New(oSection1,"col7",,	"NATUREZA"			,,)
TRCell():New(oSection1,"col8",,	"PORTADOR"			,,)
TRCell():New(oSection1,"col9",,	"DEPOSITARIA"		,,)
TRCell():New(oSection1,"col10",,"Nº CONTA"			,,)
TRCell():New(oSection1,"col11",,"NOME BANCO"		,,)
TRCell():New(oSection1,"col12",,"CLIENTE"			,,)
TRCell():New(oSection1,"col13",,"LOJA"				,,)
TRCell():New(oSection1,"col14",,"NOME"				,,20)
TRCell():New(oSection1,"col15",,"DT. EMISSAO"		,,)
TRCell():New(oSection1,"col16",,"DT. VENCTO"		,,)
TRCell():New(oSection1,"col17",,"DT. VENCTO REAL"	,,)
TRCell():New(oSection1,"col18",,"VALOR"				,,8)
TRCell():New(oSection1,"col19",,"VALOR VENCTO"		,,8)
TRCell():New(oSection1,"col20",,"VALOR C/ JUROS"	,,8)
TRCell():New(oSection1,"col21",,"SALDO"				,,8)
TRCell():New(oSection1,"col22",,"ACRESCIMO"			,,8)

oSection2 := TRSection():New(oReport,"PainelFin",{"aRegFin"})
oSection3 := TRSection():New(oReport,"PainelFin",{"aRegFin"})
oSection4 := TRSection():New(oReport,"PainelFin",{"aRegFin"})

oSection1:SetPageBreak(.T.)

Return(oReport)                                                               

/***********************************/
Static Function PrintReport(oReport)
/***********************************/

Local SumValor 	:= 0
Local SumValorJ := 0
Local nI, nJ
Local oSection1	:= oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local oSection3 := oReport:Section(3)
Local oSection4 := oReport:Section(4)

Local nCont		:= Len(_aRegFin)

oSection1:Init()
oReport:SetMeter(nCont)

for nI := 1 to Len(_aRegFin)	
	
	oReport:IncMeter()

	If oReport:Cancel()
		Exit
	Endif   
	 
	nJ := 3
	oSection1:Cell("col1"):SetValue(_aRegFin[nI][nJ])
	nJ++
	oSection1:Cell("col2"):SetValue(_aRegFin[nI][nJ])
	nJ++
	oSection1:Cell("col3"):SetValue(_aRegFin[nI][nJ])
	nJ++
	oSection1:Cell("col4"):SetValue(_aRegFin[1][nJ])
	nJ++
	oSection1:Cell("col5"):SetValue(_aRegFin[nI][nJ])
	nJ++
	oSection1:Cell("col6"):SetValue(_aRegFin[nI][nJ])
	nJ++
	oSection1:Cell("col7"):SetValue(_aRegFin[nI][nJ])
	nJ++
	oSection1:Cell("col8"):SetValue(_aRegFin[nI][nJ])
	nJ++
	oSection1:Cell("col9"):SetValue(_aRegFin[nI][nJ])
	nJ++
	oSection1:Cell("col10"):SetValue(_aRegFin[nI][nJ])
	nJ++
	oSection1:Cell("col11"):SetValue(_aRegFin[nI][nJ])
	nJ++
	oSection1:Cell("col12"):SetValue(_aRegFin[nI][nJ])
	nJ++
	oSection1:Cell("col13"):SetValue(_aRegFin[nI][nJ])
	nJ++
	oSection1:Cell("col14"):SetValue(_aRegFin[nI][nJ])
	nJ++
	oSection1:Cell("col15"):SetValue(_aRegFin[nI][nJ])
	nJ++
	oSection1:Cell("col16"):SetValue(_aRegFin[nI][nJ])
	nJ++
	oSection1:Cell("col17"):SetValue(AllTrim(_aRegFin[nI][nJ]))
	nJ++
	oSection1:Cell("col18"):SetValue(AllTrim(_aRegFin[nI][nJ]))
	nJ++
	oSection1:Cell("col19"):SetValue(AllTrim(_aRegFin[nI][nJ]))
	SumValor += Val(StrTran(StrTran(AllTrim(_aRegFin[nI][nJ]),".",""),",","." )) 
	nJ++
	oSection1:Cell("col20"):SetValue(AllTrim(_aRegFin[nI][nJ]))
	SumValorJ += Val(StrTran(StrTran(AllTrim(_aRegFin[nI][nJ]),".",""),",","." )) 
	nJ++
	oSection1:Cell("col21"):SetValue(AllTrim(_aRegFin[nI][nJ]))
	nJ++
	oSection1:Cell("col22"):SetValue(AllTrim(_aRegFin[nI][nJ]))
	nJ++

	oSection1:PrintLine()
	oReport:IncMeter()
Next

oSection1:Finish()
oReport:ThinLine() //imprime uma linha

oSection2:Init()
TRCell():New(oSection2,"col1",, "Total de Registros:",,)
TRCell():New(oSection2,"col2",, cValToChar(nI-1) ,,)
oSection2:PrintLine()
oSection2:Finish()

oSection3:Init()
TRCell():New(oSection3,"col1",, "Valor Total Vencimento:",,)
TRCell():New(oSection3,"col2",, Transform(SumValor,"@E 9,999,999,999,999.99") ,,)
oSection3:Printline()
oSection3:Finish()

oSection4:Init()
TRCell():New(oSection4,"col1",, "Valor Total c/ Juros:",,)
TRCell():New(oSection4,"col2",, Transform(SumValorJ,"@E 9,999,999,999,999.99") ,,)
oSection4:Printline()
oSection4:Finish()

Return

/***********************/
Static Function PosCli()
/***********************/

Private cCadastro	:= "Consulta Posicao Clientes"
Private	aRotina		:= {	{ "Pesquisar", "AxPesqui" , 0 , 1},;  //"Pesquisar"
							{ "Visualizar", "AxVisual", 0 , 2},;   //"Visualizar"
							{ "Consultar" , "FC010CON" , 0 , 2},;  //"Consultar"
							{ "Impressao" , "FC010IMP" , 0 , 4}}   //"Impressao"
							
DbSelectArea("SA1")
SA1->(DbSetorder(1))

If DbSeek(xFilial("SA1")+UF2->UF2_CLIENT + UF2->UF2_LOJA)
	
    If Pergunte("FIC010",.T.)
		Fc010Con("SA1",SA1->(Recno()),2)
		lRet := .T.
	Endif	
Endif

Return

/***********************/
Static Function IncTit()
/***********************/

Local oSay1, oSay2, oSay3, oSay4
Local oVlr, oCond, oHist
Local nVlr 	:= 0
Local cCond	:= Space(3)
Local cHist	:= Space(25)
Local oButton1, oButton2

Static oDlgIncTit   

DEFINE MSDIALOG oDlgIncTit TITLE "Inclusão de Título" From 000,000 TO 115,400 PIXEL

@ 005, 005 SAY oSay1 PROMPT "Valor:" SIZE 040, 007 OF oDlgIncTit COLORS CLR_BLUE, 16777215 PIXEL
@ 005, 040 MSGET oVlr VAR nVlr SIZE 060, 010 OF oDlgIncTit COLORS 0, 16777215 PIXEL Picture "@E 9,999,999,999,999.99" HASBUTTON
@ 005, 110 SAY oSay2 PROMPT "Cond.Pagto.:" SIZE 40, 007 OF oDlgIncTit COLORS CLR_BLUE, 16777215 PIXEL
@ 005, 145 MSGET oCond VAR cCond SIZE 020, 010 OF oDlgIncTit COLORS 0, 16777215 PIXEL Valid(VldCond(cCond)) F3 "SE4" Picture "@!" HASBUTTON
@ 020, 005 SAY oSay3 PROMPT "Histórico:" SIZE 040, 007 OF oDlgIncTit COLORS CLR_BLUE, 16777215 PIXEL
@ 020, 040 MSGET oHist VAR cHist SIZE 130, 010 OF oDlgIncTit COLORS 0, 16777215 PIXEL Picture "@!"

//Linha horizontal
@ 030, 005 SAY oSay4 PROMPT Repl("_",190) SIZE 190, 007 OF oDlgIncTit COLORS CLR_GRAY, 16777215 PIXEL

@ 041, 110 BUTTON oButton1 PROMPT "Confirmar" SIZE 040, 010 OF oDlgIncTit ACTION ConfInc(nVlr,cCond,cHist) PIXEL  
@ 041, 155 BUTTON oButton2 PROMPT "Fechar" SIZE 040, 010 OF oDlgIncTit ACTION oDlgIncTit:End() PIXEL  

ACTIVATE MSDIALOG oDlgIncTit CENTERED

Return

/*****************************/
Static Function VldCond(cCond)
/*****************************/

Local lRet := .T.

DbSelectArea("SE4")
SE4->(DbSetOrder(1)) //E4_FILIAL+E4_CODIGO

If !Empty(cCond)

	If !SE4->(DbSeek(xFilial("SE4")+cCond))
		MsgInfo("Condição de Pagamento inválida.","Atenção")
		lRet := .F.
	Endif
Endif

Return lRet

/****************************************/
Static Function ConfInc(nVlr,cCond,cHist)
/****************************************/

Local lRet 		:= .T.
Local lContinua	:= .T.

If Empty(nVlr)
	MsgInfo("Campo valor obrigatório.","Atenção")
	lContinua := .F.
Endif

If lContinua .And. Empty(cCond)
	MsgInfo("Campo Cond.Pagto. obrigatório.","Atenção")
	lContinua := .F.
Endif

If lContinua .And. Empty(cHist)
	MsgInfo("Campo Histórico obrigatório.","Atenção")
	lContinua := .F.
Endif

If lContinua

	If MsgYesNo("Confirma a inclusão do(s) título(s)?")

		MsgRun("Gerando Título(s)...","Aguarde",{|| lRet := GeraTit(UF2->UF2_CODIGO,UF2->UF2_CLIENT,UF2->UF2_LOJA,nVlr,cCond,cHist)})
		
		If lRet
			MsgInfo("Título(s) gerado(s) com sucesso.")
			Processa({|| Filtro(),"Aguarde"})
		Endif
	Endif
Endif

Return

/****************************************************************/
Static Function GeraTit(cContrato,cCli,cLojaCli,nVlr,cCond,cHist)
/****************************************************************/

Local lRet 			:= .T.
Local cParc			:= ""
Local nI
Local aFin040 		:= {}

Local aParcelas		:= Condicao(nVlr,cCond,0.00,dDatabase,0.00,{},,0)

Local cPref 		:= SuperGetMv("MV_XPREFAV",.F.,"AVS")
Local cTipo			:= SuperGetMv("MV_XTIPOAV",.F.,"AV")
Local cNat			:= SuperGetMv("MV_XNATUAV",.F.,"10101") //Teste

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

If Select("QRYSE1") > 0
	QRYSE1->(DbCloseArea())
Endif

cQry := "SELECT MAX(E1_PARCELA) AS NROPARC"
cQry += " FROM "+RetSqlName("SE1")+""
cQry += " WHERE D_E_L_E_T_ 	<> '*'"
cQry += " AND E1_FILIAL 	= '"+xFilial("SE1")+"'"
cQry += " AND E1_XCTRFUN 	= '"+cContrato+"'"
cQry += " AND E1_PREFIXO 	= '"+cPref+"'"
cQry += " AND E1_TIPO 		= '"+cTipo+"'"

cQry := ChangeQuery(cQry)
TcQuery cQry NEW Alias "QRYSE1"

If QRYSE1->(!EOF())
	cParc := QRYSE1->NROPARC
Else
	cParc := "000"
Endif

If Select("QRYSE1") > 0
	QRYSE1->(DbCloseArea())
Endif

For nI := 1 To Len(aParcelas)
	
	cParc := Soma1(cParc)
	
	aFin040 := {}

	AAdd(aFin040, {"E1_FILIAL"	, xFilial("SE1")											   					,Nil } )
	AAdd(aFin040, {"E1_PREFIXO"	, cPref          						   					   					,Nil } ) 
	AAdd(aFin040, {"E1_NUM"		, cContrato		 	   															,Nil } ) 
	AAdd(aFin040, {"E1_PARCELA"	, cParc									   					   					,Nil } )
	AAdd(aFin040, {"E1_TIPO"	, cTipo		 							   										,Nil } )
	AAdd(aFin040, {"E1_NATUREZ"	, cNat														   					,Nil } )
	AAdd(aFin040, {"E1_CLIENTE"	, cCli									   					   					,Nil } )
	AAdd(aFin040, {"E1_LOJA"	, cLojaCli								   										,Nil } )
	AAdd(aFin040, {"E1_EMISSAO"	, dDataBase								   										,Nil } )
	AAdd(aFin040, {"E1_VENCTO"	, IIF(Empty(aParcelas[nI][1]),dDataBase,aParcelas[nI][1])						,Nil } )
	AAdd(aFin040, {"E1_VENCREA"	, DataValida(IIF(Empty(aParcelas[nI][1]),dDataBase,aParcelas[nI][1]))			,Nil } )
	AAdd(aFin040, {"E1_VALOR"	, aParcelas[nI][2]						   										,Nil } )
	AAdd(aFin040, {"E1_HIST"	, cHist									   										,Nil } )
	AAdd(aFin040, {"E1_XCTRFUN"	, cContrato								   										,Nil } )
	
	MSExecAuto({|x,y| FINA040(x,y)},aFin040,3)
	
	If lMsErroAuto
		MostraErro()                    
		DisarmTransaction()
		lRet := .F.
		Exit
	EndIf
Next nI

Return lRet

/*/{Protheus.doc} ValForPg
Valida forma de pagamento recorrência
@type function
@version 1.0
@author nata.queiroz
@since 16/04/2020
@param cFormPag, character
@return lRet, logic
/*/
Static Function ValForPg(cFormPag)
	Local lRet := .F.
	Local aAreaU60 := U60->( GetArea() )

	Default cFormPag := ""

	U60->(DbSetOrder(2)) //-- U60_FILIAL + U60_FORPG
	if U60->( MsSeek(xFilial("U60") + cFormPag) )
		lRet := .T.
	endif

	RestArea(aAreaU60)

Return lRet

/*/{Protheus.doc} RemoveRec
Remove título da recorrência na plataforma VINDI
@type function
@version 1.0
@author nata.queiroz
@since 16/04/2020
@param aTitulos, array
/*/
Static Function RemoveRec(aTitulos)
	Local nX := 0
	Local nCount := 0
	Local cFormPag := ""
	Local nPosFlag := 1

	Default aTitulos := {}

	For nX := 1 To Len(aTitulos)
		If aTitulos[nX][nPosFlag]
			nCount++
		EndIf
	Next

	If nCount == 0
		MsgInfo("Nenhum registro selecionado!", "Atenção")
		Return
	Endif

	If DlgRmRec(@cFormPag)

		//-- Realiza processamento --//
		Processa(ProcRmRec(aTitulos, cFormPag, nCount), "Removendo título da recorrência. Aguarde...")

		//-- Atualiza gridview
		Processa( {|| Filtro() }, "Aguarde...")

	EndIf

Return

/*/{Protheus.doc} ProcRmRec
Realiza processamento dos titulos
@type function
@version 1.0
@author nata.queiroz
@since 16/04/2020
@param aTitulos, array
@param cFormPag, character
@param nCount, numeric
/*/
Static Function ProcRmRec(aTitulos, cFormPag, nCount)
	Local lRet := .T.
	Local nX := 0

	Local nPosFlag := 1
	Local nPosFil := 3
	Local nPosPref := 6
	Local nPosNum := 7
	Local nPosParc := 27
	Local nPosTipo := 4

	Local cFilCtr := ""
	Local cPrefix := ""
	Local cNum := ""
	Local cParcela := ""
	Local cTipo := ""

	ProcRegua(nCount)

	For nX := 1 To Len(aTitulos)
		If aTitulos[nX, nPosFlag]
			cFilCtr := aTitulos[nX, nPosFil]
			cPrefix := aTitulos[nX, nPosPref]
			cNum := aTitulos[nX, nPosNum]
			cParcela := aTitulos[nX, nPosParc]
			cTipo := aTitulos[nX, nPosTipo]

			lRet := U_UVIND19(cFilCtr, cPrefix, cNum, cParcela, cTipo, cFormPag)

			IncProc()
			
			If !lRet
				Exit
			EndIf
		EndIf
	Next nX

Return

/*/{Protheus.doc} DlgRmRec
Tela para informar forma de pagamento
@type function
@version 1.0
@author nata.queiroz
@since 16/04/2020
@param cFormPag, character
@return lRet, logic
/*/
Static Function DlgRmRec(cFormPag)
	Local lRet := .F.
	Local cTitle := "Remover da Recorrência"
	Local oCancel
	Local oConfirm
	Local oGet1
	Local cGet1 := Space( TamSx3("UF2_FORPG")[1] )
	Local oGroup1
	Local oSay1
	Local cSay1 := "Para remover o(s) título(s) da recorrência informe a nova forma de pagamento."
	Local oSay2
	Local cSay2 := "Forma de Pagamento"

	Static oDlg

	Default cFormPag := ""

	DEFINE MSDIALOG oDlg TITLE cTitle FROM 000, 000  TO 160, 500  COLORS 0, 16777215 PIXEL STYLE 128

		@ 005, 015 GROUP oGroup1 TO 040, 235 PROMPT "Info" OF oDlg COLOR 0, 16777215 PIXEL
		@ 019, 025 SAY oSay1 PROMPT cSay1 SIZE 200, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 045, 015 SAY oSay2 PROMPT cSay2 SIZE 053, 007 OF oDlg COLORS 0, 16777215 PIXEL
		@ 055, 015 MSGET oGet1 VAR cGet1 SIZE 045, 010 OF oDlg COLORS 0, 16777215 F3 "24" PIXEL
		@ 062, 197 BUTTON oCancel PROMPT "Cancelar" SIZE 037, 012 OF oDlg ACTION {|| oDlg:End() } PIXEL
		@ 062, 155 BUTTON oConfirm PROMPT "Confirmar" SIZE 037, 012 OF oDlg;
			ACTION {|| lRet := .T., lRet := VldRmRec(lRet, cGet1, @cFormPag) } PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return lRet

/*/{Protheus.doc} VldRmRec
Valida input do usuário
@type function
@version 1.0
@author nata.queiroz
@since 16/04/2020
@param lRet, logical, lRet
@param cGet1, character, cGet1
@param cFormPag, character, cFormPag
@return logical, lRet
/*/
Static Function VldRmRec(lRet, cGet1, cFormPag)
	Default cFormPag := ""

	If lRet
		If !Empty(cGet1)
			oDlg:End()

			//-- Forma de pagamento selecionada
			cFormPag := cGet1

			If ValForPg(cFormPag)
				lRet := .F.
				MsgAlert("Forma de pagamento selecionada é inválida. ";
					+ "Informe uma forma de pagamento diferente da recorrência.", "Atenção")
			EndIf
		Else
			lRet := .F.
			MsgInfo("Forma de pagamento não selecionada.", "Atenção")
		EndIf
	EndIf

Return lRet
