#include 'protheus.ch'
#include 'topconn.ch'

/*/{Protheus.doc} RFUNE032
Consulta específica utilizada na rotina Apontamento de Serviços mod2
@author TOTVS
@since 08/04/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RFUNE032()
/***********************/

Local lRet			:= .T.
Local oDlg			:= NIL
Local oSay1			:= NIL
Local oSay2			:= NIL
Local oSay3			:= NIL
Local oSay4			:= NIL
Local oSay5			:= NIL
Local oSay6			:= NIL
Local oSay7			:= NIL
Local oSay8			:= NIL
Local oSay9			:= NIL
Local oModelUJ2		:= NIL
Local oModel		:= FWModelActive() 
Local cCodProd		:= ""
Local cDescProd		:= ""
Local nQtdeProd		:= 0
Local oQtdeFC

Private nQtdeFC		:= 0

//Verifica se o model está disponível
If oModel == Nil
	Return
Endif

oModelUJ2 	:= oModel:GetModel("UJ2DETAIL")
cCodProd	:= oModelUJ2:GetValue("UJ2_PRODUT")
cDescProd	:= Posicione("SB1",1,xFilial("SB1")+oModelUJ2:GetValue("UJ2_PRODUT"),"B1_DESC")
nQtdeProd	:= oModelUJ2:GetValue("UJ2_QUANT")

If Empty(cCodProd)
	MsgInfo("Nenhum produto selecionado.","Atenção")
	Return
Endif

DEFINE MSDIALOG oDlg TITLE "Consulta posição Produto" FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL

@ 010, 005 SAY oSay1 PROMPT "Codigo:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 010, 030 SAY oSay2 PROMPT cCodProd SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 010, 095 SAY oSay3 PROMPT "Descrição:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 010, 125 SAY oSay4 PROMPT cDescProd SIZE 120, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 010, 220 SAY oSay5 PROMPT "Qtde. necessária:" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 010, 260 SAY oSay6 PROMPT Transform(nQtdeProd,"@E 999,999.99") SIZE 60, 007 OF oDlg COLORS 0, 16777215 PIXEL

@ 020, 005 GROUP oGrupoFC TO 100, 295 PROMPT "Filial corrente" OF oDlg COLOR 8421504, 16777215 PIXEL

//Cria o Grid
oGridFC := GridFC(oGrupoFC)

@ 090, 008 SAY oSay7 PROMPT "Qtde. disponível na filial:" SIZE 120, 007 OF oGrupoFC COLORS 0, 16777215 PIXEL
@ 090, 070 SAY oQtdeFC PROMPT Transform(nQtdeFC,"@E 999,999.99") SIZE 60, 007 OF oGrupoFC COLORS 0, 16777215 PIXEL

//Preenche o Grid
CargaFC(oGridFC,oQtdeFC,cCodProd)

@ 102, 005 GROUP oGrupoDF TO 170, 295 PROMPT "Demais filiais" OF oDlg COLOR 8421504, 16777215 PIXEL

//Cria o Grid
oGridDF := GridDF(oGrupoDF)
//Preenche o Grid
CargaDF(oGridDF,cCodProd)
//Duplo click
oGridDF:oBrowse:bLDblClick := {||SelFor(oDlg,oGridDF)}

@ 168, 005 SAY oSay9 PROMPT Repl("_",290) SIZE 290, 007 OF oDlg COLORS CLR_GRAY, 16777215 PIXEL
@ 183, 210 BUTTON oConfirmar PROMPT "Selecionar" SIZE 037, 010 OF oDlg Action(SelFor(oDlg,oGridDF)) PIXEL
@ 183, 256 BUTTON oCancelar PROMPT "Fechar" SIZE 037, 010 OF oDlg Action(oDlg:End()) PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Return(lRet)

/*****************************/
Static Function GridFC(oGrupo)
/*****************************/

Local oGrid			:= Nil
Local nX
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {"LOCAL","SALDO","UN"}
Local aAlterFields 	:= {}

For nX := 1 To Len(aFields)
	
	If aFields[nX] == "LOCAL"
		AAdd(aHeaderEx, {"Local","LOCAL",PesqPict("SB2","B2_LOCAL"),TamSX3("B2_LOCAL")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	Elseif aFields[nX] == "SALDO"
		AAdd(aHeaderEx, {"Saldo atual","SALDO",PesqPict("SB2","B2_QATU"),TamSX3("B2_QATU")[1],2,"","€€€€€€€€€€€€€€","N","","","",""})
	Elseif aFields[nX] == "UN"
		AAdd(aHeaderEx, {"UN","UN",PesqPict("SB1","B1_UM"),TamSX3("B1_UM")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	Endif		
Next nX

// Define field values
For nX := 1 To Len(aHeaderEx)
	
	If aHeaderEx[nX,8] == "C"
		AAdd(aFieldFill, "")
	Elseif aHeaderEx[nX,8] == "N"
		AAdd(aFieldFill, 0)
	Elseif aHeaderEx[nX,8] == "D"
		AAdd(aFieldFill, CTOD("  /  /    "))
	Elseif aHeaderEx[nX,8] == "L"
		AAdd(aFieldFill, .F.)
	Endif	
Next nX

AAdd(aFieldFill, .F.)
AAdd(aColsEx, aFieldFill)

oGrid := MsNewGetDados():New(028, 008, 085, 292, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,;
		 , 999, "AllwaysTrue", "", "AllwaysTrue", oGrupo, aHeaderEx, aColsEx)                          

Return(oGrid)

/*****************************************/
Static Function CargaFC(oGrid,oQtde,cProd)
/*****************************************/

Local aArea		:= GetArea()
Local aAreaSB2	:= SB2->(GetArea())

Local nQtdEst	:= 0

oGrid:Acols := {}
aFieldFill 	:= {}
nQtdeFC		:= 0

DbSelectArea("SB2")
SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL

If SB2->(DbSeek(xFilial("SB2")+cProd))

	While SB2->(!EOF()) .And. SB2->B2_FILIAL == xFilial("SB2") .And. SB2->B2_COD == cProd

		nQtdEst := SaldoMov(Nil,Nil,Nil,Nil,Nil,Nil, /*lSaldoSemR*/.F., /*dDataEmis*/dDataBase)
		
		nQtdeFC += nQtdEst
	
		aFieldFill := {}
		
		AAdd(aFieldFill, SB2->B2_LOCAL)
		AAdd(aFieldFill, nQtdEst)
		AAdd(aFieldFill, Posicione("SB1",1,xFilial("SB1")+cProd,"B1_UM"))
		
		AAdd(aFieldFill, .F.)
		AAdd(oGrid:Acols,aFieldFill) 
		
		SB2->(DbSkip())
	EndDo
	
Else
	
	AAdd(aFieldFill, "")
	AAdd(aFieldFill, 0)
	AAdd(aFieldFill, "")
	AAdd(aFieldFill, .F.)
	
	AAdd(oGrid:Acols,aFieldFill) 	
Endif

oGrid:oBrowse:Refresh()
oQtde:Refresh()

RestArea(aAreaSB2)
RestArea(aArea)

Return

/*****************************/
Static Function GridDF(oGrupo)
/*****************************/

Local oGrid			:= Nil
Local nX
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {"FILIAL","LOCAL","SALDO","UN"}
Local aAlterFields 	:= {}

For nX := 1 To Len(aFields)
	
	If aFields[nX] == "FILIAL"
		AAdd(aHeaderEx, {"Filial","FILIAL","!@",FWSizeFilial(),0,"","€€€€€€€€€€€€€€","C","","","",""})
	ElseIf aFields[nX] == "LOCAL"
		AAdd(aHeaderEx, {"Local","LOCAL",PesqPict("SB2","B2_LOCAL"),TamSX3("B2_LOCAL")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	Elseif aFields[nX] == "SALDO"
		AAdd(aHeaderEx, {"Saldo atual","SALDO",PesqPict("SB2","B2_QATU"),TamSX3("B2_QATU")[1],2,"","€€€€€€€€€€€€€€","N","","","",""})
	Elseif aFields[nX] == "UN"
		AAdd(aHeaderEx, {"UN","UN",PesqPict("SB1","B1_UM"),TamSX3("B1_UM")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	Endif		
Next nX

// Define field values
For nX := 1 To Len(aHeaderEx)
	
	If aHeaderEx[nX,8] == "C"
		AAdd(aFieldFill, "")
	Elseif aHeaderEx[nX,8] == "N"
		AAdd(aFieldFill, 0)
	Elseif aHeaderEx[nX,8] == "D"
		AAdd(aFieldFill, CTOD("  /  /    "))
	Elseif aHeaderEx[nX,8] == "L"
		AAdd(aFieldFill, .F.)
	Endif	
Next nX

AAdd(aFieldFill, .F.)
AAdd(aColsEx, aFieldFill)

oGrid := MsNewGetDados():New(110, 008, 167, 292, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,;
		 , 999, "AllwaysTrue", "", "AllwaysTrue", oGrupo, aHeaderEx, aColsEx)                          

Return(oGrid)

/***********************************/
Static Function CargaDF(oGrid,cProd)
/***********************************/

Local aArea		:= GetArea()
Local aAreaSB2	:= SB2->(GetArea())

Local aFiliais 	:= FWAllFilial(,,cEmpAnt,.F.)
Local cBkpFil	:= cFilAnt
Local nQtdEst	:= 0
Local nI

oGrid:Acols := {}
aFieldFill 	:= {}

DbSelectArea("SB2")
SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL

For nI := 1 To Len(aFiliais)
	
	If cFilAnt == aFiliais[nI]
		Loop
	Endif 
	
	cFilAnt := aFiliais[nI]

	If SB2->(DbSeek(xFilial("SB2")+cProd))
	
		While SB2->(!EOF()) .And. SB2->B2_FILIAL == xFilial("SB2") .And. SB2->B2_COD == cProd
	
			nQtdEst := SaldoMov(Nil,Nil,Nil,Nil,Nil,Nil, /*lSaldoSemR*/.F., /*dDataEmis*/dDataBase)
			
			aFieldFill := {}
			
			AAdd(aFieldFill, cFilAnt)
			AAdd(aFieldFill, SB2->B2_LOCAL)
			AAdd(aFieldFill, nQtdEst)
			aadd(aFieldFill, Posicione("SB1",1,xFilial("SB1")+cProd,"B1_UM"))
			
			AAdd(aFieldFill, .F.)
			AAdd(oGrid:Acols,aFieldFill) 
			
			SB2->(DbSkip())
		EndDo
	Endif
Next nI

If Len(oGrid:Acols) == 0

	AAdd(aFieldFill, "")
	AAdd(aFieldFill, "")
	AAdd(aFieldFill, 0)
	AAdd(aFieldFill, "")
	AAdd(aFieldFill, .F.)
	
	AAdd(oGrid:Acols,aFieldFill) 	
Endif

cFilAnt := cBkpFil

oGrid:oBrowse:Refresh()

RestArea(aAreaSB2)
RestArea(aArea)

Return

/*********************************/
Static Function SelFor(oDlg,oGrid)
/*********************************/

Local oView			:= FWViewActive()
Local oModel		:= FWModelActive() 
Local oModelUJ2 	:= oModel:GetModel("UJ2DETAIL")

Local nPosFil  		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])== "FILIAL"})  
Local cContFil		:= oGrid:aCols[oGrid:nAT,nPosFil]
Local nPosLoc		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])== "LOCAL"})  
Local cContLoc		:= oGrid:aCols[oGrid:nAT,nPosLoc]

If !Empty(cContFil) .And. !Empty(cContLoc)
	
	oModelUJ2:LoadValue("UJ2_UNESTO",cContFil)
	oModelUJ2:LoadValue("UJ2_LOCAL",cContLoc)

	If oView <> Nil
		oView:Refresh() 
	EndIf
	
	oDlg:End()
Else
	MsgInfo("Produto indisponivel nas demais filiais.","Atenção")
Endif

Return