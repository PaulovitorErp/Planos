#include "protheus.ch"

/*/{Protheus.doc} RESTA001
Mapa do Cemitério
@author TOTVS
@since 05/11/2015
@version P11
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RESTA001()
/***********************/

Local cTitulo 		:= "Mapa Cemitério" 

Local cToolQd01		:= "Quadra 01"
Local bQd01			:= {|| VisQd01()}

Local cToolMd010	:= "Módulo 010"
Local cToolMd011	:= "Módulo 011"
Local bMd010		:= {|| VisMd010()}
Local bMd011		:= {|| VisMd011()}

Local bWhen			:= {|| }

Local oFntSay	 	:= TFont():New("Verdana",,022,,.F.,,,,,.F.,.F.)

Private oImg, oImgQd 
Private oLink, oLinkMd010, oLinkMd011 
Private oButton1, oButton2, oBJz001, oBJz002, oBJz003, oBJz004, oBJz005, oBJz006, oBJz007, oBJz008, oBJz009, oBJz010, oBJz011, oBJz012 

Private oSayLocaliz 
Private cLocaliz	:= "Visão Geral >> Quadras"

Static oDlg   

aObjects := {}
aSizeAut := MsAdvSize()

//Largura, Altura, Modifica largura, Modifica altura
aAdd(aObjects, {100, 005, .F., .T.}) //Botao
aAdd(aObjects, {100, 095, .T., .T.}) //Imagem

aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

//Botão fechar
@ aPosObj[1,1] - 20, aPosObj[2,4] - 40 BUTTON oButton1 PROMPT "Fechar" SIZE 040, 015 OF oDlg ACTION oDlg:End() PIXEL  

//Botão Voltar
@ aPosObj[1,1] - 20, aPosObj[2,4] - 86 BUTTON oButton2 PROMPT "Voltar" SIZE 040, 015 OF oDlg ACTION bButton2() PIXEL  
oButton2:lVisible := .F.

//Localização
@ aPosObj[1,1], aPosObj[1,2] SAY oSayLocaliz PROMPT cLocaliz SIZE 250, 010 OF oDlg FONT oFntSay COLOR CLR_BLUE, 16777215 PIXEL

//Imagem Full
@ aPosObj[2,1], aPosObj[2,2] + 200 BITMAP oImg ResName "MAPA.png" SIZE aPosObj[2,4], aPosObj[2,3] OF oDlg PIXEL NOBORDER

oLink := THButton():New(245, 238, "", oDlg, bQd01, 044, 039,,cToolQd01, bWhen)

//Imagem QD01
@ aPosObj[2,1], aPosObj[2,2] + 200 BITMAP oImgQd ResName "QUADRA01.png" SIZE aPosObj[2,4], aPosObj[2,3] OF oDlg PIXEL NOBORDER
oImgQd:lVisible := .F.

oLinkMd010 := THButton():New(125, 256, "", oDlg, bMd010, 035, 035,,cToolMd010, bWhen)
oLinkMd011 := THButton():New(125, 290, "", oDlg, bMd011, 021, 035,,cToolMd011, bWhen)  

@ aPosObj[1,1] + 20, aPosObj[1,2] BUTTON oBJz001 PROMPT "JZ 001" SIZE 020, 030 OF oDlg ACTION bJz001() PIXEL  
oBJz001:lVisible := .F.
@ aPosObj[1,1] + 20, aPosObj[1,2] + 25 BUTTON oBJz002 PROMPT "JZ 002" SIZE 020, 030 OF oDlg ACTION {|| } PIXEL  
oBJz002:lVisible := .F.
@ aPosObj[1,1] + 20, aPosObj[1,2] + 50 BUTTON oBJz003 PROMPT "JZ 003" SIZE 020, 030 OF oDlg ACTION {|| } PIXEL  
oBJz003:lVisible := .F.
@ aPosObj[1,1] + 20, aPosObj[1,2] + 75 BUTTON oBJz004 PROMPT "JZ 004" SIZE 020, 030 OF oDlg ACTION {|| } PIXEL  
oBJz004:lVisible := .F.
@ aPosObj[1,1] + 20, aPosObj[1,2] + 100 BUTTON oBJz005 PROMPT "JZ 005" SIZE 020, 030 OF oDlg ACTION {|| } PIXEL  
oBJz005:lVisible := .F.                                           
@ aPosObj[1,1] + 20, aPosObj[1,2] + 125 BUTTON oBJz006 PROMPT "JZ 006" SIZE 020, 030 OF oDlg ACTION {|| } PIXEL  
oBJz006:lVisible := .F.
@ aPosObj[1,1] + 20, aPosObj[1,2] + 150 BUTTON oBJz007 PROMPT "JZ 007" SIZE 020, 030 OF oDlg ACTION {|| } PIXEL  
oBJz007:lVisible := .F.                                           
@ aPosObj[1,1] + 20, aPosObj[1,2] + 175 BUTTON oBJz008 PROMPT "JZ 008" SIZE 020, 030 OF oDlg ACTION {|| } PIXEL  
oBJz008:lVisible := .F.
@ aPosObj[1,1] + 20, aPosObj[1,2] + 200 BUTTON oBJz009 PROMPT "JZ 009" SIZE 020, 030 OF oDlg ACTION {|| } PIXEL  
oBJz009:lVisible := .F.
@ aPosObj[1,1] + 20, aPosObj[1,2] + 225 BUTTON oBJz010 PROMPT "JZ 010" SIZE 020, 030 OF oDlg ACTION {|| } PIXEL  
oBJz010:lVisible := .F.
@ aPosObj[1,1] + 20, aPosObj[1,2] + 250 BUTTON oBJz011 PROMPT "JZ 011" SIZE 020, 030 OF oDlg ACTION {|| } PIXEL  
oBJz011:lVisible := .F.
@ aPosObj[1,1] + 20, aPosObj[1,2] + 275 BUTTON oBJz012 PROMPT "JZ 012" SIZE 020, 030 OF oDlg ACTION {|| } PIXEL  
oBJz012:lVisible := .F.

ACTIVATE MSDIALOG oDlg CENTERED 

Return   

/************************/
Static Function VisQd01()
/************************/

oImg:lVisible 		:= .F.
oLink:lVisible		:= .F.

oImgQd:lVisible 	:= .T.  
oLinkMd010:lVisible	:= .T.
oLinkMd011:lVisible	:= .T.

oButton2:lVisible 	:= .T.

cLocaliz := "Visão Geral >> Quadra 01 >> Módulos"
oSayLocaliz:Refresh()

oButton2:SetFocus()

Return                                                                                               

/*************************/
Static Function bButton2()
/*************************/

If oImgQd:lVisible //Visualizando de Quadras

	oImgQd:lVisible 	:= .F.
	oLinkMd010:lVisible	:= .F.
	oLinkMd011:lVisible	:= .F.

	oImg:lVisible 		:= .T.
	oLink:lVisible		:= .T. 

	oButton2:lVisible 	:= .F. 

	cLocaliz := "Visão Geral >> Quadras"
	oSayLocaliz:Refresh()
	
	oButton1:SetFocus()	 

Else //Visualizando de Módulos

	oImgQd:lVisible 	:= .T.  
	oLinkMd010:lVisible	:= .T.
	oLinkMd011:lVisible	:= .T.

	oBJz001:lVisible	:= .F.
	oBJz002:lVisible	:= .F.
	oBJz003:lVisible	:= .F.
	oBJz004:lVisible	:= .F.
	oBJz005:lVisible	:= .F.
	oBJz006:lVisible	:= .F.
	oBJz007:lVisible	:= .F.
	oBJz008:lVisible	:= .F.
	oBJz009:lVisible	:= .F.
	oBJz010:lVisible	:= .F.
	oBJz011:lVisible	:= .F.
	oBJz012:lVisible	:= .F.

	cLocaliz := "Visão Geral >> Quadra 01 >> Módulos"
	oSayLocaliz:Refresh()
Endif

Return

/*************************/
Static Function VisMd010()
/*************************/

oImgQd:lVisible 	:= .F.  
oLinkMd010:lVisible	:= .F.
oLinkMd011:lVisible	:= .F.

oBJz001:lVisible	:= .T.
oBJz002:lVisible	:= .T.
oBJz003:lVisible	:= .T.
oBJz004:lVisible	:= .T.
oBJz005:lVisible	:= .T.
oBJz006:lVisible	:= .T.
oBJz007:lVisible	:= .T.
oBJz008:lVisible	:= .T.
oBJz009:lVisible	:= .T.
oBJz010:lVisible	:= .T.
oBJz011:lVisible	:= .T.
oBJz012:lVisible	:= .T.

oButton2:lVisible 	:= .T.   

cLocaliz := "Visão Geral >> Quadra 01 >> Módulo 010 >> Jazigos"
oSayLocaliz:Refresh()

oButton2:SetFocus()

Return    

/*************************/
Static Function VisMd011()
/*************************/

MsgInfo("Módulo 011 se encontra inativo, visualização não permitida!!","Atenção")

Return    

/***********************/
Static Function bJz001()
/***********************/ 

Local cTitulo 	:= "Detalhes" 

Local oSay1, oSay2, oSay3, oSay4
Local oButton1          

Local oFntSay	:= TFont():New("Verdana",,014,,.F.,,,,,.F.,.F.)
                                                             

Static oDlgJz001

DEFINE MSDIALOG oDlgJz001 TITLE cTitulo From 000,000 TO 200,300 PIXEL 

//Botão fechar
@ 010, 105 BUTTON oButton1 PROMPT "Fechar" SIZE 040, 015 OF oDlgJz001 ACTION oDlgJz001:End() PIXEL  

//Textos
@ 030, 010 SAY oSay1 PROMPT "Endereço: QD: 01 MD: 010 JZ: 001" SIZE 200, 010 OF oDlgJz001 FONT oFntSay COLOR CLR_BLUE, 16777215 PIXEL

@ 050, 010 SAY oSay2 PROMPT "GV 01: Ocupada em 02/06/2015 - JOAO SILVERO" SIZE 250, 007 OF oDlgJz001 COLOR 0, 16777215 PIXEL
@ 065, 010 SAY oSay3 PROMPT "GV 02: Livre" SIZE 100, 007 OF oDlgJz001 COLOR 0, 16777215 PIXEL
@ 080, 010 SAY oSay4 PROMPT "GV 03: Livre" SIZE 100, 007 OF oDlgJz001 COLOR 0, 16777215 PIXEL

ACTIVATE MSDIALOG oDlgJz001 CENTERED

Return   