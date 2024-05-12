#Include 'Protheus.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ RCPGA009 บ Autor ณ Wellington Gon็alves		   บ Dataณ 04/03/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Rotina para cadastro de coordenadas								  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function RCPGA009(cTabela,cImagem,aCampos)

Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Local oSay10
Local oSay11
Local oSay12
Local oSay13
Local oSay14
Local oSay15
Local oSay16
Local oGetPos1A
Local oGetPos2A
Local oGetPos3A
Local oGetPos4A
Local oGetPos5A
Local oGetPos6A
Local oGetPos7A
Local oGetPos8A
Local oGetPos1B
Local oGetPos2B
Local oGetPos3B
Local oGetPos4B
Local oGetPos5B
Local oGetPos6B
Local oGetPos7B
Local oGetPos8B
Local oGetHelp
Local oBtnConfirmar
Local oBtnCancelar
Local oBtnLimpar
Local oBtnVisualizar
Local oPanel1
Local oPanel2
Local oPanelShape
Local aArea			:= GetArea()
Local aAreaAlias	:= (cTabela)->(GetArea())
Local aButtons 		:= {}
Local cTitulo		:= "Visualiza็ใo do Mapa"
Local nAltMap		:= 580
Local nLargMap		:= 530
Local oFntGroup		:= TFont():New("Arial",,18,,.F.,,,,,.F.,.F.)
Local oFntSay		:= TFont():New("Swis721 Cn BT",,20,,.T.,,,,,.F.,.F.)
Local oFntGet		:= TFont():New("Swis721 Cn BT",,20,,.T.,,,,,.F.,.F.)
Local oFntBtn		:= TFont():New("Arial",,16,,.T.,,,,,.F.,.F.)
Local nLinIni		:= 1   
Local nGetPos1A		:= 0 
Local nGetPos1B		:= 0
Local nGetPos2A		:= 0
Local nGetPos2B		:= 0
Local nGetPos3A		:= 0
Local nGetPos3B		:= 0
Local nGetPos4A		:= 0
Local nGetPos4B		:= 0
Local nGetPos5A		:= 0
Local nGetPos5B		:= 0
Local nGetPos6A		:= 0
Local nGetPos6B		:= 0
Local nGetPos7A		:= 0
Local nGetPos7B		:= 0
Local nGetPos8A		:= 0   
Local nGetPos8B		:= 0 
Local cGetHelp		:= "Clique duas vezes sobre a posi็ใo do mapa desejada para preencher as coordenadas."
Local cVarFoco1		:= "nGetPos1A"
Local cVarFoco2		:= "nGetPos1B"
Local cObjFoco1		:= "oGetPos1A"
Local cObjFoco2		:= "oGetPos1B"
Local lOK			:= .F.
Local cCoordX		:= ""
Local cCoordY		:= ""
Local nX			:= 1
Static oDlg

// valido se foi informado o nome do alias
if Empty(cTabela)
	Aviso( "Aten็ใo!", "Nใo foi informado o nome da tabela!", {"Ok"} )
else

	// valido se foi informada a imagem do mapa
	if Empty(cImagem)
		Aviso( "Aten็ใo!", "Nใo foi informado o nome da imagem!", {"Ok"} )	
	else

		// valido se foi informado pelo menos 3 campos para as coordenadas
		if Len(aCampos) < 3
			Aviso( "Aten็ใo!", "O parใmetro de campos ้ invแlido! Deve conter pelo menos 3 campos para grava็ใo das coordenadas.", {"Ok"} )
		else
		
			// inicializo os gets com o conte๚do dos campos passados como parโmetro
			For nX := 1 To Len(aCampos)
				
				cCoordX := SubStr((cTabela)->&(aCampos[nX]),1,3)
				cCoordY := SubStr((cTabela)->&(aCampos[nX]),5,3)
			
				if nX == 1
					nGetPos1A := Val(cCoordX) 
					nGetPos1B := Val(cCoordY)
				elseif nX == 2
					nGetPos2A := Val(cCoordX)
					nGetPos2B := Val(cCoordY)
				elseif nX == 3
					nGetPos3A := Val(cCoordX)
					nGetPos3B := Val(cCoordY)				
				elseif nX == 4
					nGetPos4A := Val(cCoordX)
					nGetPos4B := Val(cCoordY)				
				elseif nX == 5
					nGetPos5A := Val(cCoordX)
					nGetPos5B := Val(cCoordY)				
				elseif nX == 6
					nGetPos6A := Val(cCoordX)
					nGetPos6B := Val(cCoordY)				
				elseif nX == 7
					nGetPos7A := Val(cCoordX)
					nGetPos7B := Val(cCoordY)				
				elseif nX == 8
					nGetPos8A := Val(cCoordX)
					nGetPos8B := Val(cCoordY)				
				endif
			
			Next nX
			
			lOK := .T.
		
		endif 
	
	endif

endif   

if !lOK
	RestArea(aAreaAlias)
	RestArea(aArea)
	Return()
endif

DEFINE MSDIALOG oDlg TITLE cTitulo From 0,0 TO 593,800 PIXEL //OF oMainWnd PIXEL

// Panel principal
@ 000, 000 MSPANEL oPanel1 SIZE 403 , 353 OF oDlg COLORS 0, 16777215  

// Panel da imagem
@ 002, 002 MSPANEL oPanel2 SIZE 267, 292 OF oPanel1 COLORS 0, 14869218 

//Group das cordenadas
@ 002, 272 GROUP oGroup2 TO 294, 399 PROMPT " Coordenadas " OF oPanel1 COLOR 0, 16777215 PIXEL
oGroup2:oFont := oFntGroup

// PaitPanel para cria็ใo dos Shapes
oPanel := TPaintPanel():new(01,01,nLargMap/2,nAltMap/2,oPanel2)

// Propriedade do duplo clique
oPanel:blDblClick := {|x,y| (&cVarFoco1 := x , &cVarFoco2 := y , &cObjFoco1:Refresh() , &cObjFoco2:Refresh() , AddShapeMap(oPanel,nGetPos1A,nGetPos1B,nGetPos2A,nGetPos2B,nGetPos3A,nGetPos3B,nGetPos4A,nGetPos4B,nGetPos5A,nGetPos5B,nGetPos6A,nGetPos6B,nGetPos7A,nGetPos7B,nGetPos8A,nGetPos8B,.F.) , MudaFoco(cVarFoco1,oGetPos1A,oGetPos2A,oGetPos3A,oGetPos4A,oGetPos5A,oGetPos6A,oGetPos7A,oGetPos8A)) }

// Imagem do gabarito
oPanel:addShape("id=1;type=8;left=0;top=0;width=" + cValToChar(nLargMap) + ";height=" + cValToChar(nAltMap) + " ;image-file=rpo:" + AllTrim(cImagem) + ";tooltip=Mapa;can-move=0;can-mark=1;is-blinker=1;is-container=1;")

// Campos das cordenadas
nLinIni += 15

@ nLinIni + 2	, 282 SAY oSay1 PROMPT "1ช:" SIZE 025, 007 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL
@ nLinIni		, 305 MSGET oGetPos1A VAR nGetPos1A SIZE 35,12 PIXEL Font oFntGet OF oPanel1 PICTURE "@E 999"
@ nLinIni + 2	, 345 SAY oSay2 PROMPT "x" SIZE 025, 007 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL
@ nLinIni		, 356 MSGET oGetPos1B VAR nGetPos1B SIZE 35,12 PIXEL Font oFntGet OF oPanel1 PICTURE "@E 999"

oGetPos1A:BGOTFOCUS := {|| (cVarFoco1 := "nGetPos1A", cVarFoco2 := "nGetPos1B" , cObjFoco1 := "oGetPos1A", cObjFoco2 := "oGetPos1B" )}  
oGetPos1B:BGOTFOCUS := {|| (cVarFoco1 := "nGetPos1A", cVarFoco2 := "nGetPos1B" , cObjFoco1 := "oGetPos1A", cObjFoco2 := "oGetPos1B" )}

nLinIni += 20

@ nLinIni + 2	, 282 SAY oSay3 PROMPT "2ช:" SIZE 025, 007 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL
@ nLinIni		, 305 MSGET oGetPos2A VAR nGetPos2A SIZE 35,12 PIXEL Font oFntGet OF oPanel1 PICTURE "@E 999"
@ nLinIni + 2	, 345 SAY oSay4 PROMPT "x" SIZE 025, 007 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL
@ nLinIni		, 356 MSGET oGetPos2B VAR nGetPos2B SIZE 35,12 PIXEL Font oFntGet OF oPanel1 PICTURE "@E 999"

oGetPos2A:BGOTFOCUS := {|| (cVarFoco1 := "nGetPos2A", cVarFoco2 := "nGetPos2B" , cObjFoco1 := "oGetPos2A", cObjFoco2 := "oGetPos2B")}  
oGetPos2B:BGOTFOCUS := {|| (cVarFoco1 := "nGetPos2A", cVarFoco2 := "nGetPos2B" , cObjFoco1 := "oGetPos2A", cObjFoco2 := "oGetPos2B" )}

nLinIni += 20

@ nLinIni + 2	, 282 SAY oSay5 PROMPT "3ช:" SIZE 025, 007 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL
@ nLinIni		, 305 MSGET oGetPos3A VAR nGetPos3A SIZE 35,12 PIXEL Font oFntGet OF oPanel1 PICTURE "@E 999"
@ nLinIni + 2	, 345 SAY oSay6 PROMPT "x" SIZE 025, 007 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL
@ nLinIni		, 356 MSGET oGetPos3B VAR nGetPos3B SIZE 35,12 PIXEL Font oFntGet OF oPanel1 PICTURE "@E 999"

oGetPos3A:BGOTFOCUS := {|| (cVarFoco1 := "nGetPos3A", cVarFoco2 := "nGetPos3B" , cObjFoco1 := "oGetPos3A", cObjFoco2 := "oGetPos3B")}  
oGetPos3B:BGOTFOCUS := {|| (cVarFoco1 := "nGetPos3A", cVarFoco2 := "nGetPos3B" , cObjFoco1 := "oGetPos3A", cObjFoco2 := "oGetPos3B" )}

nLinIni += 20

@ nLinIni + 2	, 282 SAY oSay7 PROMPT "4ช:" SIZE 025, 007 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL
@ nLinIni		, 305 MSGET oGetPos4A VAR nGetPos4A SIZE 35,12 PIXEL Font oFntGet OF oPanel1 PICTURE "@E 999"
@ nLinIni + 2	, 345 SAY oSay8 PROMPT "x" SIZE 025, 007 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL
@ nLinIni		, 356 MSGET oGetPos4B VAR nGetPos4B SIZE 35,12 PIXEL Font oFntGet OF oPanel1 PICTURE "@E 999"

oGetPos4A:BGOTFOCUS := {|| (cVarFoco1 := "nGetPos4A", cVarFoco2 := "nGetPos4B" , cObjFoco1 := "oGetPos4A", cObjFoco2 := "oGetPos4B")}  
oGetPos4B:BGOTFOCUS := {|| (cVarFoco1 := "nGetPos4A", cVarFoco2 := "nGetPos4B" , cObjFoco1 := "oGetPos4A", cObjFoco2 := "oGetPos4B" )}

nLinIni += 20

@ nLinIni + 2	, 282 SAY oSay9 PROMPT "5ช:" SIZE 025, 007 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL
@ nLinIni		, 305 MSGET oGetPos5A VAR nGetPos5A SIZE 35,12 PIXEL Font oFntGet OF oPanel1 PICTURE "@E 999"
@ nLinIni + 2	, 345 SAY oSay10 PROMPT "x" SIZE 025, 007 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL
@ nLinIni		, 356 MSGET oGetPos5B VAR nGetPos5B SIZE 35,12 PIXEL Font oFntGet OF oPanel1 PICTURE "@E 999"

oGetPos5A:BGOTFOCUS := {|| (cVarFoco1 := "nGetPos5A", cVarFoco2 := "nGetPos5B" , cObjFoco1 := "oGetPos5A", cObjFoco2 := "oGetPos5B")}  
oGetPos5B:BGOTFOCUS := {|| (cVarFoco1 := "nGetPos5A", cVarFoco2 := "nGetPos5B" , cObjFoco1 := "oGetPos5A", cObjFoco2 := "oGetPos5B" )}

nLinIni += 20

@ nLinIni + 2	, 282 SAY oSay11 PROMPT "6ช:" SIZE 025, 007 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL
@ nLinIni		, 305 MSGET oGetPos6A VAR nGetPos6A SIZE 35,12 PIXEL Font oFntGet OF oPanel1 PICTURE "@E 999"
@ nLinIni + 2	, 345 SAY oSay12 PROMPT "x" SIZE 025, 007 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL
@ nLinIni		, 356 MSGET oGetPos6B VAR nGetPos6B SIZE 35,12 PIXEL Font oFntGet OF oPanel1 PICTURE "@E 999"

oGetPos6A:BGOTFOCUS := {|| (cVarFoco1 := "nGetPos6A", cVarFoco2 := "nGetPos6B" , cObjFoco1 := "oGetPos6A", cObjFoco2 := "oGetPos6B")}  
oGetPos6B:BGOTFOCUS := {|| (cVarFoco1 := "nGetPos6A", cVarFoco2 := "nGetPos6B" , cObjFoco1 := "oGetPos6A", cObjFoco2 := "oGetPos6B" )}

nLinIni += 20

@ nLinIni + 2	, 282 SAY oSay13 PROMPT "7ช:" SIZE 025, 007 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL
@ nLinIni		, 305 MSGET oGetPos7A VAR nGetPos7A SIZE 35,12 PIXEL Font oFntGet OF oPanel1 PICTURE "@E 999"
@ nLinIni + 2	, 345 SAY oSay14 PROMPT "x" SIZE 025, 007 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL
@ nLinIni		, 356 MSGET oGetPos7B VAR nGetPos7B SIZE 35,12 PIXEL Font oFntGet OF oPanel1 PICTURE "@E 999"

oGetPos7A:BGOTFOCUS := {|| (cVarFoco1 := "nGetPos7A", cVarFoco2 := "nGetPos7B" , cObjFoco1 := "oGetPos7A", cObjFoco2 := "oGetPos7B")}  
oGetPos7B:BGOTFOCUS := {|| (cVarFoco1 := "nGetPos7A", cVarFoco2 := "nGetPos7B" , cObjFoco1 := "oGetPos7A", cObjFoco2 := "oGetPos7B" )}

nLinIni += 20

@ nLinIni + 2	, 282 SAY oSay15 PROMPT "8ช:" SIZE 025, 007 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL
@ nLinIni		, 305 MSGET oGetPos8A VAR nGetPos8A SIZE 35,12 PIXEL Font oFntGet OF oPanel1 PICTURE "@E 999"
@ nLinIni + 2	, 345 SAY oSay16 PROMPT "x" SIZE 025, 007 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL
@ nLinIni		, 356 MSGET oGetPos8B VAR nGetPos8B SIZE 35,12 PIXEL Font oFntGet OF oPanel1 PICTURE "@E 999"

oGetPos8A:BGOTFOCUS := {|| (cVarFoco1 := "nGetPos8A", cVarFoco2 := "nGetPos8B" , cObjFoco1 := "oGetPos8A", cObjFoco2 := "oGetPos8B")}  
oGetPos8B:BGOTFOCUS := {|| (cVarFoco1 := "nGetPos8A", cVarFoco2 := "nGetPos8B" , cObjFoco1 := "oGetPos8A", cObjFoco2 := "oGetPos8B" )}

nLinIni += 20

cActionClean := "( LimpaCPO(@nGetPos1A,@nGetPos1B,@nGetPos2A,@nGetPos2B,@nGetPos3A,@nGetPos3B,@nGetPos4A,@nGetPos4B,@nGetPos5A,@nGetPos5B,@nGetPos6A,@nGetPos6B,@nGetPos7A,@nGetPos7B,@nGetPos8A,@nGetPos8B) , "
cActionClean += "RefreshCPO(oGetPos1A,oGetPos1B,oGetPos2A,oGetPos2B,oGetPos3A,oGetPos3B,oGetPos4A,oGetPos4B,oGetPos5A,oGetPos5B,oGetPos6A,oGetPos6B,oGetPos7A,oGetPos7B,oGetPos8A,oGetPos8B) , "
cActionClean += "oPanel:DeleteItem(2) , oGetPos1A:SetFocus() )

@ nLinIni		, 282 BUTTON oBtnLimpar PROMPT "Limpar" SIZE 050, 015 Font oFntBtn OF oPanel1 PIXEL ACTION (&cActionClean)
@ nLinIni		, 340 BUTTON oBtnVisualizar PROMPT "Visualizar" SIZE 050, 015 Font oFntBtn OF oPanel1 PIXEL ACTION (AddShapeMap(oPanel,nGetPos1A,nGetPos1B,nGetPos2A,nGetPos2B,nGetPos3A,nGetPos3B,nGetPos4A,nGetPos4B,nGetPos5A,nGetPos5B,nGetPos6A,nGetPos6B,nGetPos7A,nGetPos7B,nGetPos8A,nGetPos8B,.T.))

nLinIni += 23

@ nLinIni 		, 282 SAY oSay17 PROMPT "Help:" SIZE 025, 010 Font oFntSay OF oPanel1 COLORS 0, 16777215 PIXEL

nLinIni += 13

@ nLinIni 		, 282 Get oGetHelp Var cGetHelp MEMO Size 108,050 READONLY PIXEL OF oPanel1

nLinIni += 60

@ nLinIni		, 282 BUTTON oBtnCancelar PROMPT "Cancelar" SIZE 050, 015 Font oFntBtn OF oPanel1 PIXEL ACTION (oDlg:End())
@ nLinIni		, 340 BUTTON oBtnConfirmar PROMPT "Confirmar" SIZE 050, 015 Font oFntBtn OF oPanel1 PIXEL ACTION (iif( Confirmar(cTabela,aCampos,{{nGetPos1A,nGetPos1B},{nGetPos2A,nGetPos2B},{nGetPos3A,nGetPos3B},{nGetPos4A,nGetPos4B},{nGetPos5A,nGetPos5B},{nGetPos6A,nGetPos6B},{nGetPos7A,nGetPos7B},{nGetPos8A,nGetPos8B}}) , oDlg:End() ,))

// inicio o foco na primeira coordenada
oGetPos1A:SetFocus()

// chamo fun็ใo que cria o shape, caso os campos estejam preenchidos
AddShapeMap(oPanel,nGetPos1A,nGetPos1B,nGetPos2A,nGetPos2B,nGetPos3A,nGetPos3B,nGetPos4A,nGetPos4B,nGetPos5A,nGetPos5B,nGetPos6A,nGetPos6B,nGetPos7A,nGetPos7B,nGetPos8A,nGetPos8B,.F.)

ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aAreaAlias)
RestArea(aArea)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ LimpaCPO บ Autor ณ Wellington Gon็alves		   บ Dataณ 08/03/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que limpa os campos das coordenadas						  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function LimpaCPO(nGetPos1A,nGetPos1B,nGetPos2A,nGetPos2B,nGetPos3A,nGetPos3B,nGetPos4A,nGetPos4B,nGetPos5A,nGetPos5B,nGetPos6A,nGetPos6B,nGetPos7A,nGetPos7B,nGetPos8A,nGetPos8B)

nGetPos1A := 0
nGetPos1B := 0
nGetPos2A := 0
nGetPos2B := 0
nGetPos3A := 0
nGetPos3B := 0
nGetPos4A := 0
nGetPos4B := 0
nGetPos5A := 0
nGetPos5B := 0
nGetPos6A := 0
nGetPos6B := 0
nGetPos7A := 0
nGetPos7B := 0
nGetPos8A := 0
nGetPos8B := 0

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ RefreshCPO บ Autor ณ Wellington Gon็alves	   บ Dataณ 08/03/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que faz um refresh nos campos das coordenadas				  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function RefreshCPO(oGetPos1A,oGetPos1B,oGetPos2A,oGetPos2B,oGetPos3A,oGetPos3B,oGetPos4A,oGetPos4B,oGetPos5A,oGetPos5B,oGetPos6A,oGetPos6B,oGetPos7A,oGetPos7B,oGetPos8A,oGetPos8B)

oGetPos1A:Refresh()
oGetPos1B:Refresh()
oGetPos2A:Refresh()
oGetPos2B:Refresh()
oGetPos3A:Refresh()
oGetPos3B:Refresh()
oGetPos4A:Refresh()
oGetPos4B:Refresh()
oGetPos5A:Refresh()
oGetPos5B:Refresh()
oGetPos6A:Refresh()
oGetPos6B:Refresh()
oGetPos7A:Refresh()
oGetPos7B:Refresh()
oGetPos8A:Refresh()
oGetPos8B:Refresh()

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ AddShapeMap บ Autor ณ Wellington Gon็alves	   บ Dataณ 08/03/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que adiciona o poligono no mapa							  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function AddShapeMap(oPanel,nX1,nY1,nX2,nY2,nX3,nY3,nX4,nY4,nX5,nY5,nX6,nY6,nX7,nY7,nX8,nY8,lMsgErro)

Local cCords 	:= ""
Local nQtdCords	:= 0

if nX1 > 0 .AND. nY1 > 0
	cCords += cValToChar(nX1) + ":" + cValToChar(nY1) + "," 
	nQtdCords++
endif

if nX2 > 0 .AND. nY2 > 0
	cCords += cValToChar(nX2) + ":" + cValToChar(nY2) + ","
	nQtdCords++
endif

if nX3 > 0 .AND. nY3 > 0
	cCords += cValToChar(nX3) + ":" + cValToChar(nY3) + ","
	nQtdCords++
endif

if nX4 > 0 .AND. nY4 > 0
	cCords += cValToChar(nX4) + ":" + cValToChar(nY4) + ","
	nQtdCords++
endif

if nX5 > 0 .AND. nY5 > 0
	cCords += cValToChar(nX5) + ":" + cValToChar(nY5) + ","
	nQtdCords++
endif

if nX6 > 0 .AND. nY6 > 0
	cCords += cValToChar(nX6) + ":" + cValToChar(nY6) + ","
	nQtdCords++
endif

if nX7 > 0 .AND. nY7 > 0
	cCords += cValToChar(nX7) + ":" + cValToChar(nY7) + ","
	nQtdCords++
endif

if nX8 > 0 .AND. nY8 > 0
	cCords += cValToChar(nX8) + ":" + cValToChar(nY8) + ","
	nQtdCords++
endif

// para formar um polํgono, o usuแrio deve informar pelo menos 3 coordenadas
if nQtdCords >= 3

	// retiro a ๚ltima vํrgula da string
	cCords := SubStr(cCords,1,(Len(cCords)-1))
	
	// deleto o shape antigo
	oPanel:DeleteItem(2)
	
	// crio o nome shape
	oPanel:addShape("id=2;type=5;polygon=" +  cCords + ";gradient=1,0,0,0,0,0.0,#0000FF80;gradient-hover=1,0,0,0,0,0.0,#0000FF80;tooltip=Poligono;pen-width=1;pen-color=#ffffff0;can-move=0;can-mark=1;is-container=0;is-blinker=01;")
	
elseif lMsgErro
	Aviso( "Aten็ใo!", "Informe pelo menos 3 coordenadas para visualiza็ใo!", {"Ok"} )
endif

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ Confirmar บ Autor ณ Wellington Gon็alves	  	   บ Dataณ 08/03/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que grava as coordenadas do mapa							  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function Confirmar(cTabela,aCampos,aCoords)

Local lRet := .F.
Local nX   := 1

if MsgYesNo("Deseja gravar as coordenadas?")

	if RecLock(cTabela,.F.)
		
		// percorro todos os campos das coordenadas
		For nX := 1 To Len(aCampos)
		
			// valida็ใo para nใo dar erro caso chamem esta rotina passando mais de 8 campos de coordenadas
			if nX > Len(aCoords)
				Exit
			endif
			  
			(cTabela)->&(aCampos[nX]) := StrZero(aCoords[nX][1],3) + ":" + StrZero(aCoords[nX][2],3) 
				
		Next nX
	
		(cTabela)->(MsUnLock())
		
		lRet := .T.
	
	else	
		Aviso( "Aten็ใo!", "Nใo foi possํvel realizar a grava็ใo das coordenadas!", {"Ok"} )	
	endif

endif

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ MudaFoco บ Autor ณ Wellington Gon็alves	  	   บ Dataณ 11/03/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que muda o foco dos campos das coordenadas.				  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function MudaFoco(cVarFoco1,oGetPos1A,oGetPos2A,oGetPos3A,oGetPos4A,oGetPos5A,oGetPos6A,oGetPos7A,oGetPos8A)

if cVarFoco1 == "nGetPos1A" 
	oGetPos2A:SetFocus()
elseif cVarFoco1 == "nGetPos2A"
	oGetPos3A:SetFocus()
elseif cVarFoco1 == "nGetPos3A"
	oGetPos4A:SetFocus()
elseif cVarFoco1 == "nGetPos4A"
	oGetPos5A:SetFocus()
elseif cVarFoco1 == "nGetPos5A"
	oGetPos6A:SetFocus()
elseif cVarFoco1 == "nGetPos6A"
	oGetPos7A:SetFocus()
elseif cVarFoco1 == "nGetPos7A"
	oGetPos8A:SetFocus()
elseif cVarFoco1 == "nGetPos8A"
	oGetPos1A:SetFocus()
endif

Return()