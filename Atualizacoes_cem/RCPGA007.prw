#Include 'Protheus.ch'

// Constantes utilizadas no c๓digo fonte
#Define CPG_ALTMAP 580 // altura da imagem do mapa em pixels
#Define CPG_LARGMAP 530 // largura da imagem do mapa em pixels
#Define CPG_CORATIVO "#FFFFFF" // cor do shape se a quadra/m๓dulo estiver ativo
#Define CPG_CORINATIVO "#FF0000" // cor do shape se a quadra/m๓dulo estiver inativo
#Define CPG_PERTRANSP "100" // percentual de solidez (nใo transpar๊ncia) quando o mouse estแ sobre o shape

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ RCPGA007 บ Autor ณ Wellington Gon็alves		   บ Dataณ 25/02/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Rotina para visualiza็ใo do mapa do cemit้rio					  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function RCPGA007()

Local oPanel1
Local oPanel2
Local oPaintPanel
Local oFntGroup	:= TFont():New("Arial",,22,,.T.,,,,,.F.,.F.)
Local oFntSay	:= TFont():New("Arial",,20,,.F.,,,,,.F.,.F.)
Local oFntSayN	:= TFont():New("Arial",,20,,.T.,,,,,.F.,.F.)
Local aSizeAut 	:= MsAdvSize(.F.) 
Local cTitulo	:= "Visualiza็ใo do Mapa"
Local aPanels	:= {}
Local nLinPaint	:= 0
Local aShapes	:= {}
Local lViewMap	:= .T.
Local cSayCodQd	:= ""
Local cSayDesQd	:= ""
Local cSayCodMd	:= ""
Local cSayDesMd	:= ""
Local aArea		:= GetArea()
Local aAreaU08	:= U08->(GetArea())
Local aAreaU09	:= U09->(GetArea())
Local aAreaU10	:= U10->(GetArea())
Local aLocaliza	:= Array(4)
Static oDlg

Private oScrl  := NIL


aadd(aPanels , {0 				, 0 					, (CPG_LARGMAP / 2) 						, ((aSizeAut[6] / 2) + 2) 	} ) // coordenadas do painel do mapa 
aadd(aPanels , {0 				, ( CPG_LARGMAP / 2 )	, (((aSizeAut[5] - CPG_LARGMAP) / 2) + 3 )	, ((aSizeAut[6] / 2) - 25) 	} ) // coordenadas do detalhamento 
aadd(aPanels , {aPanels[2,4] 	, ( CPG_LARGMAP / 2 )	, (((aSizeAut[5] - CPG_LARGMAP) / 2) + 3 )	, 25						} ) // coordenadas do rodape de botoes

DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] PIXEL //OF oMainWnd PIXEL

@ aPanels[1,1], aPanels[1,2] MSPANEL oPanel1 SIZE aPanels[1,3] , aPanels[1,4] OF oDlg COLORS 0, 16777215 

// cแlculo para centralizar a imagem verticalmente na tela
nLinPaint := (((oPanel1:nClientHeight - CPG_ALTMAP) / 2)) / 2   

// Paninel Container
oPaintPanel := TPaintPanel():new(nLinPaint,0,CPG_LARGMAP/2,CPG_ALTMAP/2,oPanel1)

// propriedade de duplo clique
oPaintPanel:blDblClick := {|x,y| ( CliqueShape(oPaintPanel,oPaintPanel:ShapeAtu,aShapes,@lViewMap,@oScrl,oPanel2,@cSayCodQd,@cSayDesQd,@cSayCodMd,@cSayDesMd) , oSay1:Refresh() , oSay2:Refresh() , oSay3:Refresh() , oSay4:Refresh() ) }

// Fun็ใo que cria o mapa geral
MapaGeral(oPaintPanel,aShapes,@lViewMap)

/////// PANEL COM O DETALHAMENTO DAS QUADRAS / MำDULOS / JAZIGOS

@ aPanels[2,1], aPanels[2,2] MSPANEL oPanel2 SIZE aPanels[2,3] , aPanels[2,4] OF oDlg COLORS 0, 16777215

// Group divisor entre o mapa com o detalhamento
@ 005, 002 GROUP oGroup1 TO (oPanel2:nClientHeight/2) ,003 PROMPT "" OF oPanel2 COLOR 0, 16777215 PIXEL

// Group da quadra
@ 007, 007 GROUP oGroup2 TO 045,((oPanel2:nClientWidth/2) - 5) PROMPT " Quadra " OF oPanel2 COLOR 0, 16777215 PIXEL
oGroup2:oFont := oFntGroup

@ 025 , 020 SAY oSay1 PROMPT "C๓digo: " + cSayCodQd SIZE 050, 010 Font oFntSay OF oPanel2 COLORS 0, 16777215 PIXEL

@ 025 , 080 SAY oSay2 PROMPT "Descri็ใo: " + cSayDesQd SIZE 300, 010 Font oFntSay OF oPanel2 COLORS 0, 16777215 PIXEL

// Group do m๓dulo
@ 050, 007 GROUP oGroup3 TO 088,((oPanel2:nClientWidth/2) - 5) PROMPT " M๓dulo " OF oPanel2 COLOR 0, 16777215 PIXEL
oGroup3:oFont := oFntGroup

@ 068 , 020 SAY oSay3 PROMPT "C๓digo: " + cSayCodMd SIZE 050, 010 Font oFntSay OF oPanel2 COLORS 0, 16777215 PIXEL

@ 068 , 080 SAY oSay4 PROMPT "Descri็ใo: " + cSayDesMd SIZE 300, 010 Font oFntSay OF oPanel2 COLORS 0, 16777215 PIXEL

@ 095 , 007 SAY oSay5 PROMPT "Jazigos: " SIZE 050, 010 Font oFntSayN OF oPanel2 COLORS 0, 16777215 PIXEL

@ 110, 007 SCROLLBOX oScrl HORIZONTAL VERTICAL SIZE ((oPanel2:nClientHeight/2) - 117) , ((oPanel2:nClientWidth/2) - 12) OF oPanel2 BORDER 

/////// PANEL DE BOTAO NO RODAPE

@ aPanels[3,1], aPanels[3,2] MSPANEL oPanel3 SIZE aPanels[3,3] , aPanels[3,4] OF oDlg COLORS 0, 16777215

// Group divisor entre o mapa com o detalhamento
@ 000, 002 GROUP oGroup4 TO ((oPanel3:nClientHeight/2) - 4),003 PROMPT "" OF oPanel3 COLOR 0, 16777215 PIXEL

// Group divisor entre o detalhamento e o rodape de botoes
@ 000, 006 GROUP oGroup5 TO 001,((oPanel3:nClientWidth/2) - 6) PROMPT "" OF oPanel3 COLOR 0, 16777215 PIXEL

@ 007 , 007 BUTTON oBtnClose PROMPT "Retornar" SIZE 050, 015 OF oPanel3 PIXEL ACTION (( RetornaMapa(oPaintPanel,aShapes,@lViewMap,@oScrl,oPanel2,@cSayCodQd,@cSayDesQd,@cSayCodMd,@cSayDesMd) , oSay1:Refresh() , oSay2:Refresh() , oSay3:Refresh() , oSay4:Refresh()))
@ 007 , 065 BUTTON oBtnSearch PROMPT "Localizar Jazigo" SIZE 050, 015 OF oPanel3 PIXEL ACTION (U_RCPGE041(@aLocaliza) , iif(!Empty(aLocaliza[1]) ,LocalizaJazigo(aLocaliza,oPaintPanel,aShapes,@lViewMap,@oScrl,oPanel2,@cSayCodQd,@cSayDesQd,@cSayCodMd,@cSayDesMd,oSay1,oSay2,oSay3,oSay4),))

@ 007 , ((oPanel3:nClientWidth/2) - 55) BUTTON oBtnClose PROMPT "Fechar" SIZE 050, 015 OF oPanel3 PIXEL ACTION (oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED 

RestArea(aAreaU08)
RestArea(aAreaU09)
RestArea(aAreaU10)
RestArea(aArea)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ MapaGeral บ Autor ณ Wellington Gon็alves		   บ Dataณ 22/03/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que cria o mapa geral										  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function MapaGeral(oPaintPanel,aShapes,lViewMap)

Local cPngMap	:= GetMv("MV_XMAPA") 

// adiciono a imagem do mapa
oPaintPanel:addShape("id=99999;type=8;left=0;top=0;width=" + cValToChar(CPG_LARGMAP) + ";height=" + cValToChar(CPG_ALTMAP) + " ;image-file=rpo:" + cPngMap + ";tooltip=Mapa do cemit้rio;can-move=0;can-mark=1;is-blinker=1;is-container=1;")

// adiciono os chapes no mapa
AddQuadras(oPaintPanel,aShapes)

lViewMap := .T.

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ AddQuadras บ Autor ณ Wellington Gon็alves	   บ Dataณ 08/03/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que adiciona os shapes das quadras						  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function AddQuadras(oPaintPanel,aShapes)

Local aArea			:= GetArea()
Local aAreaU08		:= U08->(GetArea())
Local cCords 		:= ""
Local cIdShapeConv	:= ""
Local cDescQuadra	:= ""
Local nQtdCords		:= 0

U08->(DbSetOrder(1)) // U08_FILIAL + U08_CODIGO
U08->(DbGoTop())
While U08->(!Eof())

	cCords		:= ""
	nQtdCords 	:= 0
	cDescQuadra	:= AllTrim(U08->U08_DESC)
	
	if SubStr(U08->U08_COORD1,1,3) <> "000" .OR. SubStr(U08->U08_COORD1,5,3) <> "000"
		cCords += U08->U08_COORD1 + "," 
		nQtdCords++
	endif
	
	if SubStr(U08->U08_COORD2,1,3) <> "000" .OR. SubStr(U08->U08_COORD2,5,3) <> "000"
		cCords += U08->U08_COORD2 + ","
		nQtdCords++
	endif
	
	if SubStr(U08->U08_COORD3,1,3) <> "000" .OR. SubStr(U08->U08_COORD3,5,3) <> "000"
		cCords += U08->U08_COORD3 + ","
		nQtdCords++
	endif
	
	if SubStr(U08->U08_COORD4,1,3) <> "000" .OR. SubStr(U08->U08_COORD4,5,3) <> "000"
		cCords += U08->U08_COORD4 + ","
		nQtdCords++
	endif
	
	if SubStr(U08->U08_COORD5,1,3) <> "000" .OR. SubStr(U08->U08_COORD5,5,3) <> "000"
		cCords += U08->U08_COORD5 + ","
		nQtdCords++
	endif
	
	if SubStr(U08->U08_COORD6,1,3) <> "000" .OR. SubStr(U08->U08_COORD6,5,3) <> "000"
		cCords += U08->U08_COORD6 + ","
		nQtdCords++
	endif
	
	if SubStr(U08->U08_COORD7,1,3) <> "000" .OR. SubStr(U08->U08_COORD7,5,3) <> "000"
		cCords += U08->U08_COORD7 + ","
		nQtdCords++
	endif
	
	if SubStr(U08->U08_COORD8,1,3) <> "000" .OR. SubStr(U08->U08_COORD8,5,3) <> "000"
		cCords += U08->U08_COORD8 + ","
		nQtdCords++
	endif
	
	// para formar um polํgono, o usuแrio deve informar pelo menos 3 coordenadas
	if nQtdCords >= 3
		
		//converto o codigo da quadra para alphanumerico para numerico para criar os ids dos shapes
		cIdShapeConv := ConvLetraNum(U08->U08_CODIGO)
		
		// incremento variavel totalizadora de shapes
		aadd(aShapes,{U08->U08_CODIGO,cIdShapeConv}) // alimento o array de shapes com o id
	
		// retiro a ๚ltima vํrgula da string
		cCords := SubStr(cCords,1,(Len(cCords)-1))
		
		// crio o shape
		oPaintPanel:addShape("id=" + cIdShapeConv + ";type=5;polygon=" +  cCords + ";gradient=1,0,0,0,0,0.0,#0000FF0;gradient-hover=1,0,0,0,0,0.0," + iif(U08->U08_STATUS == "S",CPG_CORATIVO,CPG_CORINATIVO) + CPG_PERTRANSP + ";tooltip=" + cDescQuadra + ";pen-width=1;pen-color=#ffffff0;can-move=0;can-mark=1;is-container=0;is-blinker=01;")
		
	endif
	
	U08->(DbSkip())
	
EndDo

RestArea(aAreaU08)
RestArea(aArea)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ MapaQuadra บ Autor ณ Wellington Gon็alves	   บ Dataณ 22/03/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que cria o mapa das quadras								  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function MapaQuadra(oPaintPanel,nIdQuadra,aShapes,lViewMap,cCodQuadra)

Local cImagemQuadra	:= ""
Local cDescQuadra	:= ""

U08->(DbSetOrder(1)) // U08_FILIAL + U08_CODIGO
if U08->(DbSeek(xFilial("U08") + cCodQuadra ))

	if Empty(U08->U08_IMAGEM)
		
		Aviso( "Aten็ใo!", "Nใo foi cadastrado o nome da imagem desta quadra!", {"Ok"} )
		
		// retorno a visualiza็ใo para o mapa
		RetornaMapa(oPaintPanel,aShapes,@lViewMap)
		
	else
	
		cCodQuadra		:= U08->U08_CODIGO
		cImagemQuadra 	:= AllTrim(U08->U08_IMAGEM) 
		cDescQuadra		:= AllTrim(U08->U08_DESC)

		// imagem
		oPaintPanel:addShape("id=99999;type=8;left=0;top=0;width=" + cValToChar(CPG_LARGMAP) + ";height=" + cValToChar(CPG_ALTMAP) + " ;image-file=rpo:" + cImagemQuadra + ";tooltip=" + cDescQuadra + ";can-move=0;can-mark=1;is-blinker=1;is-container=1;")
		
		// adiciono os chapes dos m๓dulos no mapa da quadra
		AddModulos(oPaintPanel,cCodQuadra,aShapes,nIdQuadra)
		
		lViewMap := .F.
	
	endif

endif

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ AddModulos บ Autor ณ Wellington Gon็alves	   บ Dataณ 22/03/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que adiciona os shapes dos modulos						  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function AddModulos(oPaintPanel,cQuadra,aShapes,nIdQuadra)

Local aArea			:= GetArea()
Local aAreaU09		:= U09->(GetArea())
Local cDescModulo	:= ""
Local cIdShpModulo	:= ""
Local cCords 		:= ""
Local nQtdCords		:= 0

U09->(DbSetOrder(1)) // U09_FILIAL + U09_QUADRA + U09_CODIGO   
U09->(DbGoTop())
if U09->(DbSeek(xFilial("U09") + cQuadra))

	While U09->(!Eof()) .AND. U09->U09_FILIAL == xFilial("U09") .AND. U09->U09_QUADRA == cQuadra 
	
		cCords		:= ""
		nQtdCords 	:= 0
		cDescModulo	:= AllTrim(U09->U09_DESC)
		
		if SubStr(U09->U09_COORD1,1,3) <> "000" .OR. SubStr(U09->U09_COORD1,5,3) <> "000"
			cCords += U09->U09_COORD1 + "," 
			nQtdCords++
		endif
		
		if SubStr(U09->U09_COORD2,1,3) <> "000" .OR. SubStr(U09->U09_COORD2,5,3) <> "000"
			cCords += U09->U09_COORD2 + ","
			nQtdCords++
		endif
		
		if SubStr(U09->U09_COORD3,1,3) <> "000" .OR. SubStr(U09->U09_COORD3,5,3) <> "000"
			cCords += U09->U09_COORD3 + ","
			nQtdCords++
		endif
		
		if SubStr(U09->U09_COORD4,1,3) <> "000" .OR. SubStr(U09->U09_COORD4,5,3) <> "000"
			cCords += U09->U09_COORD4 + ","
			nQtdCords++
		endif
		
		if SubStr(U09->U09_COORD5,1,3) <> "000" .OR. SubStr(U09->U09_COORD5,5,3) <> "000"
			cCords += U09->U09_COORD5 + ","
			nQtdCords++
		endif
		
		if SubStr(U09->U09_COORD6,1,3) <> "000" .OR. SubStr(U09->U09_COORD6,5,3) <> "000"
			cCords += U09->U09_COORD6 + ","
			nQtdCords++
		endif
		
		if SubStr(U09->U09_COORD7,1,3) <> "000" .OR. SubStr(U09->U09_COORD7,5,3) <> "000"
			cCords += U09->U09_COORD7 + ","
			nQtdCords++
		endif
		
		if SubStr(U09->U09_COORD8,1,3) <> "000" .OR. SubStr(U09->U09_COORD8,5,3) <> "000"
			cCords += U09->U09_COORD8 + ","
			nQtdCords++
		endif
		
		// para formar um polํgono, o usuแrio deve informar pelo menos 3 coordenadas
		if nQtdCords >= 3
			
			//converto o codigo do modulo para alphanumerico para numerico para criar os ids dos shapes
			cIdShpModulo := ConvLetraNum(U09->U09_CODIGO)
		
			// incremento variavel totalizadora de shapes
			aadd(aShapes,{U09->U09_QUADRA,U09->U09_CODIGO,cValToChar(nIdQuadra) + cIdShpModulo}) // alimento o array de shapes com o id
		
			// retiro a ๚ltima vํrgula da string
			cCords := SubStr(cCords,1,(Len(cCords)-1))
			
			// crio o shape
			oPaintPanel:addShape("id=" + cValToChar(nIdQuadra) +  cIdShpModulo /*StrZero(nContShapes,2)*/ + ";type=5;polygon=" +  cCords + ";gradient=1,0,0,0,0,0.0,#0000FF0;gradient-hover=1,0,0,0,0,0.0," + iif(U09->U09_STATUS == "S",CPG_CORATIVO,CPG_CORINATIVO) + CPG_PERTRANSP + ";tooltip=" + cDescModulo + ";pen-width=1;pen-color=#ffffff0;can-move=0;can-mark=1;is-container=0;is-blinker=01;")
			
		endif
		
		U09->(DbSkip())
		
	EndDo

endif

RestArea(aAreaU09)
RestArea(aArea)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ CliqueShape บ Autor ณ Wellington Gon็alves	   บ Dataณ 22/03/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo chamada no duplo clique dos shapes						  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function CliqueShape(oPaintPanel,nId,aShapes,lViewMap,oScroll,oPanel2,cSayCodQd,cSayDesQd,cSayCodMd,cSayDesMd)

Local nX 			:= 1
Local cCodQuadra	:= ""
Local nPosCodigo	:= ""

if nId <> 99999 // se for o shape da imagem, nใo executa nada

	// se o shape visualizado ้ o mapa geral, entใo deverแ mostrar o mapa da quadra
	// caso contrแrio, significa que o usuแrio clicou no shape do m๓dulo, entใo serใo mostrados seus jazigos
	if lViewMap
	
		// deleto a imagem
		oPaintPanel:DeleteItem(99999)
		
		// deleto os shapes
		For nX := 1 To Len(aShapes) // incremento variavel totalizadora de shapes
		
			oPaintPanel:DeleteItem(Val(aShapes[nX,1]))
		
		Next nX		

		//pego a linha do codigo da quadra de acordo com o id do shape
		nPosCodigo := aScan(aShapes, {|x| Val(x[2]) == nId })

		//codigo da quadra de acordo com o id do shape
		cCodQuadra := aShapes[nPosCodigo,1]
				
		// limpo o array da shapes
		aShapes := {}
		
		// monto o mapa da quadra
		MapaQuadra(oPaintPanel,nId,aShapes,@lViewMap,cCodQuadra)
		
		// a fun็ใo MapaQuadra posiciona na quadra (U08)
		// entใo, atualizo as variแveis do say
		cSayCodQd := AllTrim(U08->U08_CODIGO)
		cSayDesQd := AllTrim(U08->U08_DESC)
	
	else
	
		// mostra os jazigos do m๓dulo
		MsAguarde( {|| ShowJazigos(nId,@oScroll,oPanel2,aShapes)}, "Aguarde", "Consultando jazigos...", .F. )

		// a fun็ใo ShowJazigos posiciona no m๓dulo (U09)
		// entใo, atualizo as variแveis do say		
		cSayCodMd := AllTrim(U09->U09_CODIGO)
		cSayDesMd := AllTrim(U09->U09_DESC)
	
	endif

endif

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ RetornaMapa บ Autor ณ Wellington Gon็alves	   บ Dataณ 22/03/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo chamada no botใo de retornar.								  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function RetornaMapa(oPaintPanel,aShapes,lViewMap,oScroll,oPanel2,cSayCodQd,cSayDesQd,cSayCodMd,cSayDesMd)

Local nAltura	:= oScroll:nClientHeight / 2 
Local nLargura	:= oScroll:nClientWidth / 2 
Local nX		:= 1

// deleto a imagem atual
oPaintPanel:DeleteItem(99999)

// deleto todos os shapes
For nX := 1 To Len(aShapes)

	oPaintPanel:DeleteItem(Val(aShapes[nX,1]))

Next nX

aShapes := {}

// Fun็ใo que cria o mapa geral
MapaGeral(oPaintPanel,aShapes,@lViewMap)

// limpo o scroll dos jazigos 
oScrl := NIL

@ 110, 007 SCROLLBOX oScroll HORIZONTAL VERTICAL SIZE nAltura , nLargura OF oPanel2 BORDER

// limpo os say's da quadra e do m๓dulo
cSayCodQd := ""
cSayDesQd := ""	
cSayCodMd := ""
cSayDesMd := ""

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ ShowJazigos บ Autor ณ Wellington Gon็alves	   บ Dataณ 18/03/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que adiciona os jazigos									  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ShowJazigos(nId,oScroll,oPanel2,aShapes)

Local nPos			:= 10
Local nSoma 		:= nPos
Local oFnt			:= TFont():New("Verdana",,26,,.T.,,,,,.F.,.F.)
Local nAltura		:= oScroll:nClientHeight / 2 
Local nLargura		:= oScroll:nClientWidth / 2 
Local nAltBtn		:= 50 // 60
Local nLargBtn		:= 47 // 30
Local nX			:= 0
Local nY			:= 0
Local nCont			:= 0
Local nLin			:= 10
Local nQtdBt		:= 80
Local nQtd			:= 1
Local cJazigo		:= ""
Local cModulo		:= ""
Local cQuadra		:= ""
Local nIdBtn		:= 0
Local cBlExec		:= ""
Local cQuadModulo	:= ""
Local cImagem		:= "lapide.png"
Local oSayJazigo	:= NIL
Local oBtnJazigo	:= NIL


// crio um novo scroll para sobrepor o que foi passado como refer๊ncia
oScrl := NIL
@ 110, 007 SCROLLBOX oScroll HORIZONTAL VERTICAL SIZE nAltura , nLargura OF oPanel2 BORDER

//pego a linha do codigo da quadra e modulo de acordo com o id do shape
nPosCodigo := aScan(aShapes, {|x| Val(x[3]) == nId })

//codigo da quadra e modulo de acordo com o id do shape
cQuadModulo := aShapes[nPosCodigo,1] + aShapes[nPosCodigo,2]
		
U09->(DbSetOrder(1)) // U09_FILIAL + U09_QUADRA + U09_CODIGO   
U09->(DbGoTop())
if U09->(DbSeek(xFilial("U09") + cQuadModulo ))

	U10->(DbSetOrder(1)) // U10_FILIAL + U10_QUADRA + U10_MODULO + U10_CODIGO
	U10->(DbGoTop())
	if U10->(DbSeek(xFilial("U10") + cQuadModulo ))
	
		// fa็o o cแlculo da quantidade de jazigos que irใo caber na horizontal
		While U10->(!Eof()) .AND. U10->U10_FILIAL == xFilial("U10") .AND. (U10->U10_QUADRA + U10->U10_MODULO) == cQuadModulo
				
			if nSoma + nLargBtn + nPos > nLargura
				Exit
			endif
				
			nSoma += nLargBtn + nPos
			nCont++
					
			U10->(DbSkip())
			
		EndDo
			
		nSoma 	:= (nLargura - (nSoma-10)) / 2
		nColuna := nSoma
			
		// posiciono no primeiro registro da tabela novamente
		U10->(DbGoTop())
			
		U10->(DbSetOrder(1)) // U10_FILIAL + U10_QUADRA + U10_MODULO + U10_CODIGO
		if U10->(DbSeek(xFilial("U10") + cQuadModulo ))
			
			While U10->(!Eof()) .AND. U10->U10_FILIAL == xFilial("U10") .AND. (U10->U10_QUADRA + U10->U10_MODULO) == cQuadModulo 
					
				if nQtd > nCont
					nLin += nAltBtn + 5 
					nQtd 	:= 1 
					nColuna := nSoma 
				endif
					
				cJazigo := U10->U10_CODIGO 
				
				// crio a imagem do jazigo
				@ nLin, nColuna REPOSITORY oBtnJazigo SIZE 94/2, 100/2 OF oScroll PIXEL NOBORDER
				oBtnJazigo:LoadBmp(cImagem)
				cBlExec := "{|| U_RCPGA012('" + U10->U10_QUADRA + "','" + U10->U10_MODULO + "','" + U10->U10_CODIGO + "')}"
				oBtnJazigo:BLCLICKED := &cBlExec
				
				// crio o texto do jazigo
				@ nLin + 12, nColuna + 13 SAY oSayJazigo PROMPT "" SIZE 030, 015 OF oScroll FONT oFnt COLORS 16777215, 0 PIXEL
				oSayJazigo:cCaption := cJazigo
						
				nColuna += nLargBtn + nPos
				nQtd++
				nIdBtn++
						
				U10->(DbSkip())
				
			EndDo  
			
		endif
	
	endif

endif

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ LocalizaJazigo บ Autor ณ Wellington Gon็alves   บ Dataณ 15/06/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que faz a abertura da quadra, modulo e jazigo				  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function LocalizaJazigo(aEnderecamento,oPaintPanel,aShapes,lViewMap,oScrl,oPanel2,cSayCodQd,cSayDesQd,cSayCodMd,cSayDesMd,oSay1,oSay2,oSay3,oSay4)

Local cQuadra 	:= aEnderecamento[2]
Local cModulo	:= aEnderecamento[3]
Local cJazigo	:= aEnderecamento[4]

// retorno para o mapa geral
RetornaMapa(oPaintPanel,aShapes,@lViewMap,@oScrl,oPanel2,@cSayCodQd,@cSayDesQd,@cSayCodMd,@cSayDesMd)

// abro a quadra
CliqueShape(oPaintPanel,Val(cQuadra),aShapes,@lViewMap,@oScrl,oPanel2,@cSayCodQd,@cSayDesQd,@cSayCodMd,@cSayDesMd)

// abro o modulo
CliqueShape(oPaintPanel,Val(cQuadra + cModulo),aShapes,@lViewMap,@oScrl,oPanel2,@cSayCodQd,@cSayDesQd,@cSayCodMd,@cSayDesMd)

// atualizo os labels
oSay1:Refresh()
oSay2:Refresh()
oSay3:Refresh()
oSay4:Refresh()

// chamo fun็ใo que abre a tela de visuzlia็ใo das gavetas do jazigo
U_RCPGA012(cQuadra,cModulo,cJazigo)

Return()


/*/{Protheus.doc} ConvLetraNum
Funcao para realizar a conversao 
do codigo dos enderecos de string 
para numericos. 
@author Raphael Martins 
@since 12/01/2019
@version P12
@return nPreco - Preco de Venda da Tabela
/*/
Static Function ConvLetraNum(cString)

Local cConvert := ""

//realizo a conversao de cada caractere da quadra, modulo ou jazigo
//em numericos
While !Empty(cString)
	
	cConvert += RetAsc(SubStr(cString,1,1),1,.F.)
	
	cString := SubStr(cString,2,Len(cString))

EndDo

Return(cConvert)
