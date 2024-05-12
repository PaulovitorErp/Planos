#Include 'Protheus.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ RCPGA012 º Autor ³ Wellington Gonçalves		   º Data³ 24/03/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Rotina para visualização do status da gaveta do jazigo			  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Vale do Cerrado                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RCPGA012(cQuadra,cModulo,cJazigo)

Local oGroup1
Local oGroup2
Local oSay1
Local oSay2
Local oSay3
Local oSayJazigo
Local oSayModulo
Local oSayQuadra
Local oGridGavetas
Local aButtons 		:= {{"", {||ShowContrato(oGridGavetas)}, "Visualizar Contrato"},{"", {||ShowCadastro(cQuadra)}, "Visualizar Endereçamento"}}
Local nLin 			:= 35
Local cSayQuadra	:= ""
Local cSayModulo	:= ""
Local cSayJazigo	:= ""
Default cQuadra		:= ""
Default cModulo		:= ""
Default cJazigo		:= ""
Static oDlg

if Empty(cQuadra) 
	Aviso( "Atenção!", "Não foi informada a quadra!", {"Ok"} )
	Return()
elseif Empty(cModulo) 
	Aviso( "Atenção!", "Não foi informado o módulo!", {"Ok"} )
	Return()
elseif Empty(cJazigo) 
	Aviso( "Atenção!", "Não foi informado o jazigo!", {"Ok"} )
	Return()
else
	cSayQuadra	:= cQuadra
	cSayModulo	:= cModulo
	cSayJazigo	:= cJazigo
endif

DEFINE MSDIALOG oDlg TITLE " Detalhamento do Jazigo " FROM 000, 000  TO 280, 500 COLORS 0, 16777215 PIXEL

@ nLin, 005 GROUP oGroup1 TO nLin + 30, 247 PROMPT "  Endereçamento  " OF oDlg COLOR 0, 16777215 PIXEL

nLin += 13

@ nLin, 010 SAY oSay1 PROMPT "Quadra:" SIZE 023, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ nLin, 035 SAY oSayQuadra PROMPT cSayQuadra SIZE 016, 007 OF oDlg COLORS 0, 16777215 PIXEL

@ nLin, 060 SAY oSay2 PROMPT "Módulo:" SIZE 021, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ nLin, 085 SAY oSayModulo PROMPT cSayModulo SIZE 015, 007 OF oDlg COLORS 0, 16777215 PIXEL

@ nLin, 110 SAY oSay3 PROMPT "Jazigo:" SIZE 020, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ nLin, 135 SAY oSayJazigo PROMPT cSayJazigo SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL

nLin += 23 

@ nLin, 005 GROUP oGroup2 TO nLin + 65, 247 PROMPT "  Gavetas  " OF oDlg COLOR 0, 16777215 PIXEL

oGridGavetas := bGridGavetas(nLin)

//altero o scroll para barra de rolagem
oGridGavetas:oBrowse:nScrollType := 0

// função que atualiza o grid
AtuGrid(oGridGavetas,cQuadra,cModulo,cJazigo)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {||oDlg:End()}, {||oDlg:End()},,aButtons)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ bGridGavetas º Autor ³ Wellington Gonçalves	   º Data³ 24/03/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que cria o MsNewGetDados									  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Vale do Cerrado                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function bGridGavetas(nLin)

Local nX
Local aHeaderEx := {}
Local aColsEx := {}
Local aFieldFill := {}
Local aFields := {"U04_GAVETA","STATUS","U04_DTUTIL","U04_CODIGO","U04_QUEMUT"}
Local aAlterFields := {}
Local oMSNewGe1
Local oSX3 := UGetSxFile():New 
Local aSX3 := {} 

For nX := 1 to Len(aFields)

	If Alltrim(aFields[nX]) == "STATUS"
		Aadd(aHeaderEx,{'Status','STATUS','',10,0,'','€€€€€€€€€€€€€€','C','','','',''})
	else

		aSX3 := oSX3:GetInfoSX3("U04",aFields[nX])
			
		// pegos os dados da SX3
		If Len(aSX3) > 0
	    	Aadd(aHeaderEx, {AllTrim(X3Titulo()),aSX3[1,2]:cCAMPO,aSX3[1,2]:cPICTURE,aSX3[1,2]:nTAMANHO,aSX3[1,2]:nDECIMAL,aSX3[1,2]:cVALID,aSX3[1,2]:cUSADO,aSX3[1,2]:cTIPO,aSX3[1,2]:cF3,aSX3[1,2]:cCONTEXT,aSX3[1,2]:cCBOX,aSX3[1,2]:cRELACAO})
		Endif
		
	endif
	
Next nX

// crio a primeira linha em branco
For nX := 1 To Len(aHeaderEx)

	if aHeaderEx[nX,8] == "N"
		Aadd(aFieldFill,0)
	elseif aHeaderEx[nX,8] == "D"
		Aadd(aFieldFill,CTOD(""))
	elseif aHeaderEx[nX,8] == "L"
		Aadd(aFieldFill,.F.)
	else
		Aadd(aFieldFill,"")
	endif
	
Next nX

Aadd(aFieldFill, .F.) // flag de não deletado
Aadd(aColsEx, aFieldFill)

oMSNewGe1 := MsNewGetDados():New( nLin + 10, 010, nLin + 60, 242,GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return(oMSNewGe1)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ AtuGrid º Autor ³ Wellington Gonçalves	 		 Data³ 24/03/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que atualiza o grid com o status das gavetas				  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Vale do Cerrado                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function AtuGrid(oGrid,cQuadra,cModulo,cJazigo)

Local aFieldFill 	:= {}
Local aAuxAcols		:= {}
Local nQtdGavetas	:= 3
Local nX			:= 0
Local nY			:= 0
Local cGaveta		:= ""
Local cStatus		:= ""
Local dDataUtil		:= CTOD("  /  /    ")
Local cContrato 	:= ""
Local cUtilizador	:= ""

U04->(DbSetOrder(2)) // U04_FILIAL + U04_QUADRA + U04_MODULO + U04_JAZIGO + U04_GAVETA

For nX := 1 To nQtdGavetas
	
	aFieldFill := {}
	
	// se existe U04 e a data de utilização estiver preenchida é porque a gaveta já está utilizada
	if U04->(DbSeek(xFilial("U04") + cQuadra + cModulo + cJazigo + StrZero(nX,TamSX3("U04_GAVETA")[1]))) .AND. !Empty(U04->U04_DTUTIL)
	
		cStatus		:= "Ocupada"
		dDataUtil	:= U04->U04_DTUTIL
		cContrato 	:= U04->U04_CODIGO
		cUtilizador	:= U04->U04_QUEMUT
	
	else
	
		cStatus		:= "Livre"
		dDataUtil	:= CTOD("  /  /    ")
		U04->(DbGoTop())
		if U04->(DbSeek(xFilial("U04") + cQuadra + cModulo + cJazigo + StrZero(nX,TamSX3("U04_GAVETA")[1]))) //Endereçamento prévio
			cContrato 	:= U04->U04_CODIGO
		else
			cContrato 	:= ""
		endif
		cUtilizador	:= ""
			
	endif

	For nY := 1 to Len(oGrid:aHeader)
		
		If oGrid:aHeader[nY,2] == "U04_GAVETA"
			Aadd(aFieldFill , StrZero(nX,TamSX3("U04_GAVETA")[1]))
		elseif oGrid:aHeader[nY,2] == "STATUS"
			Aadd(aFieldFill , cStatus)
		elseif oGrid:aHeader[nY,2] == "U04_DTUTIL"
			Aadd(aFieldFill , dDataUtil)
		elseif oGrid:aHeader[nY,2] == "U04_CODIGO"
			Aadd(aFieldFill , cContrato)
		elseif oGrid:aHeader[nY,2] == "U04_QUEMUT"
			Aadd(aFieldFill , cUtilizador)
		Endif
		
	Next nY
	
	aadd(aFieldFill,.F.)
	aadd(aAuxAcols,aFieldFill)
	
Next nX

// atualizo o array do grid
oGrid:aCols := aClone(aAuxAcols)

// faço um refresh no grid
oGrid:oBrowse:Refresh()  

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ ShowContrato º Autor ³ Wellington Gonçalves 		 Data³ 24/03/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função de visualização do contrato								  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Vale do Cerrado                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ShowContrato(oGrid)

Local cContrato := oGrid:aCols[oGrid:oBrowse:nAt,aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "U04_CODIGO"})] 
Local aArea		:= GetArea()
Local aAreaU00	:= U00->(GetArea())

if Empty(cContrato)
	Aviso( "Atenção!", "Esta gaveta não está vinculada a um contrato!", {"Ok"} )
else

	U00->(DbSetOrder(1)) // U00_FILIAL + U00_CODIGO   
	if U00->(DbSeek(xFilial("U00") + cContrato ))
		MsAguarde({|| FWExecView('Visualização', 'RCPGA001',1,, {|| .T. })},"Aguarde","Localizando contrato...",.F.)
	else
		Aviso( "Atenção!", "Contrato não localizado!", {"Ok"} )
	endif

endif

RestArea(aAreaU00)
RestArea(aArea)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ ShowCadastro º Autor ³ Wellington Gonçalves	 	 Data³ 24/03/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função de visualização do endereçamento							  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Vale do Cerrado                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ShowCadastro(cQuadra)

Local aArea		:= GetArea()
Local aAreaU08	:= U08->(GetArea())

if Empty(cQuadra)
	Aviso( "Atenção!", "A quadra não foi informada!", {"Ok"} )
else

	U08->(DbSetOrder(1)) // U08_FILIAL + U08_CODIGO  
	if U08->(DbSeek(xFilial("U08") + cQuadra ))
		MsAguarde({|| FWExecView('Visualização', 'RCPGA002',1,, {|| .T. })},"Aguarde","Localizando endereçamento...",.F.)
	else
		Aviso( "Atenção!", "Quadra não localizada!", {"Ok"} )
	endif

endif

RestArea(aAreaU08)
RestArea(aArea)

Return()