#Include "PROTHEUS.CH"
#include "topconn.ch"  

/*/{Protheus.doc} RIMPM002
//Consulta especifica de dicionario
de tabelas
@Author Raphael Martins
@Since 14/05/2018
@Version 1.0
@Return
@Type function
/*/

User Function RIMPM002()

Static cRetTabela	:= ""

// Tela de Pesquisa
FWMsgRun(,{|oSay| MontaTela(oSay)},'Aguarde...','Consultando Tabelas no Dicionario de Dados!')

Return(.T.)

/*/{Protheus.doc} RCPGE15A
//Retorno da Consulta 
@Author Raphael Martins
@Since 14/05/2018
@Version 1.0
@Return
@Type function
/*/
User Function RIMPM02A()

Return(cRetTabela)

/*/{Protheus.doc} MontaTela
//Funcao para montar a tela de 
pesquisa
de tabelas
@Author Raphael Martins
@Since 14/05/2018
@Version 1.0
@Return
@Type function
/*/
Static Function MontaTela()
                       
Local oGroup1		:= NIL
Local oGroup2		:= NIL
Local oGroup3		:= NIL
Local oSay1			:= NIL
Local oSay2			:= NIL
Local oDlg			:= NIL
Local oChave		:= NIL
Local oDescricao	:= NIL
Local oConfirmar	:= NIL
Local oCancelar		:= NIL
Local oGrid			:= NIL
Local oArial 		:= TFont():New("Arial Narrow",,016,,.F.,,,,,.F.,.F.)
Local oArialN 		:= TFont():New("Arial",,014,,.T.,,,,,.F.,.F.)
Local cChave		:= Space(3)
Local cDescricao	:= Space(35)

	
  	DEFINE MSDIALOG oDlg TITLE "Consulta Tabelas" FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL
    
    @ 003, 003 GROUP oGroup1 TO 033, 298 PROMPT "Filtros" OF oDlg COLOR 8421504, 16777215 PIXEL
    @ 014, 008 SAY oSay1 PROMPT "Chave:" SIZE 025, 007 OF oDlg FONT oArialN COLORS 0, 16777215 PIXEL
    @ 013, 032 MSGET oChave VAR cChave SIZE 087, 011 OF oDlg COLORS 0, 16777215 Picture "@!" FONT oArial PIXEL
    
    //monto a grid de tabelas
    oGrid := MsGridCTR(oDlg)
    
    oChave:bLostFocus := {|| RefreshGrid(oGrid,cChave,cDescricao)}
    
    @ 014, 125 SAY oSay2 PROMPT "Descricao:" SIZE 027, 007 OF oDlg FONT oArialN COLORS 0, 16777215 PIXEL
    @ 013, 156 MSGET oDescricao VAR cDescricao SIZE 139, 011 OF oDlg COLORS 0, 16777215 Picture "@!" FONT oArial PIXEL
    
    oDescricao:bLostFocus := {|| RefreshGrid(oGrid,cChave,cDescricao)}
    
    @ 035, 003 GROUP oGroup2 TO 177, 298 PROMPT "Dicionario de Dados - SX2" OF oDlg COLOR 8421504, 16777215 PIXEL
    
    // duplo clique no grid
    oGrid:oBrowse:bLDblClick := {|| cRetTabela := SelTabela(oDlg,oGrid)}

    @ 179, 003 GROUP oGroup3 TO 196, 298 OF oDlg COLOR 0, 16777215 PIXEL
    @ 183, 210 BUTTON oConfirmar PROMPT "Confirmar" SIZE 037, 010 OF oDlg Action( cRetTabela := SelTabela(oDlg,oGrid) ) FONT oArialN PIXEL
    @ 183, 256 BUTTON oCancelar PROMPT "Cancelar" SIZE 037, 010 OF oDlg Action(oDlg:End()) FONT oArialN PIXEL

    // caso não tenha encontrato tabelas
  	if !RefreshGrid(oGrid)
		
  		Alert("Não foram encontrados Tabelas no Dicionario de Dados!")
  		oDlg:End()
		
	endif
	
    ACTIVATE MSDIALOG oDlg CENTERED
    
Return(.T.)

/*/{Protheus.doc} MsGridCTR
//TODO Função que cria o grid de tabelas
@author Raphael Martins
@since 14/05/2018
@version 1.0
@param 	oTela	 	- Dialog da Tela de consulta
@return oGrid		- MsNewGetdados criada dos tabelas consultadas
@type function
/*/

Static Function MsGridCTR(oTela)

Local oGrid			:= NIL
Local nX			:= 1
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {"ITEM","CHAVE","DESCRICAO"}
Local aAlterFields 	:= {}

For nX := 1 To Len(aFields)
	
	if aFields[nX] == "ITEM"
		Aadd(aHeaderEx, {"Item","ITEM","@E 9999",4,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "CHAVE"
		Aadd(aHeaderEx, {"Chave","CHAVE","@!",3,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "DESCRICAO"
		Aadd(aHeaderEx, {"Descricao","DESCRICAO","",35,0,"","€€€€€€€€€€€€€€","C","","","",""})
	endif
		
Next nX

// Define field values
For nX := 1 To Len(aHeaderEx)
	
	if aHeaderEx[nX,8] == "C"
		Aadd(aFieldFill, "")
	elseif aHeaderEx[nX,8] == "N"
		Aadd(aFieldFill, 0)
	elseif aHeaderEx[nX,8] == "D"
		Aadd(aFieldFill, CTOD("  /  /    "))
	elseif aHeaderEx[nX,8] == "L"
		Aadd(aFieldFill, .F.)
	endif
	
Next nX

Aadd(aFieldFill, .F.)
Aadd(aColsEx, aFieldFill)

oGrid := MsNewGetDados():New( 044,008,173, 293, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,;
		 , 999, "AllwaysTrue", "", "AllwaysTrue",oTela, aHeaderEx, aColsEx)                          


Return(oGrid)

/*{Protheus.doc} RefreshGrid
//TODO Função chamada para preencher a grid de tabelas
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param oGrid 			- Objeto da Grid de Tabelas 
@param cChave		 	- Codigo da Tabela do Dicionario
@param cDescricao	 	- Descricao da tabela

@return lRet			- Encontrado tabelas do dicionario
@type function
/*/
Static Function RefreshGrid(oGrid,cChave,cDescricao)

Local aArea			:= GetArea()
Local aAreaSX2		:= SX2->(GetArea())
Local lRet			:= .F.
Local lFiltro		:= .T.
Local aFields 		:= {"ITEM","CHAVE","DESCRICAO"}
Local nItem			:= 0
Local oSX2			:= UGetSxFile():New
Local aTabelas		:= {} 
Local nX			:= 1

Default cChave		:= ""
Default	cDescricao	:= "" 
	
oGrid:Acols := {}
aFieldFill 	:= {}

aTabelas := oSX2:GetInfoSX2( )

SX2->(DbGotop())

	// se existir contratos a serem reajustados
if Len(aTabelas) > 0

	For nX:= 1 to Len(aTabelas)
		
		lRet := .T.
		
		aFieldFill := {}
		
		//valido se posssui filtro de tabela
		if !Empty(cChave) .And. !( Alltrim(cChave) $ Alltrim(aTabelas[nX,2]:cCHAVE) ) 
			
			lFiltro := .F.
			
		elseif !Empty(cDescricao) .And. !( Alltrim(cDescricao) $ Alltrim(Upper(aTabelas[nX,2]:cNOME)) )  
			
			lFiltro := .F.
			
		endif
		 
		if lFiltro
			
			nItem++
		
			aadd(aFieldFill, StrZero(nItem,4))
			aadd(aFieldFill, aTabelas[nX,1])
			aadd(aFieldFill, aTabelas[nX,2])
		
			Aadd(aFieldFill, .F.)
			aadd(oGrid:Acols,aFieldFill) 
		
		endif
		
		lFiltro := .T.
	Next nX
	
else
	
	Aadd(aFieldFill, "")
	Aadd(aFieldFill, "")
	Aadd(aFieldFill, "")
	Aadd(aFieldFill, .F.)
	
	aadd(oGrid:Acols,aFieldFill) 
	
endif

oGrid:oBrowse:Refresh()

RestArea(aArea)
RestArea(aAreaSX2)

Return(lRet)

/*/{Protheus.doc} SelTabela
//TODO Funcao para confirmar chave selecionada

@author Raphael Martins
@since 08/05/2018
@version 1.0
@param oDlg	 			- Objeto Dialog
@param oGrid		 	- Grid de Tabelas
@return cRet			- chave Selecionado
@type function
/*/

Static Function SelTabela(oDlg,oGrid)
  
Local nPosChave	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])== "CHAVE"})  
Local cRet		:= oGrid:aCols[oGrid:nAT,nPosChave]

oDlg:End()

Return(cRet)
    