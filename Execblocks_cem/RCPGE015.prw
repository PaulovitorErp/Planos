#Include "PROTHEUS.CH"
#include "topconn.ch"  

/*/{Protheus.doc} RCPGE015
//Consulta Especifica de Produtos
//para transferencia de enderecamento
@Author Raphael Martins
@Since 14/05/2018
@Version 1.0
@Return
@Type function
/*/

User Function RCPGE015(cFilCtro,cContrato)
                        
Local oGroup1		:= NIL
Local oGroup2		:= NIL
Local oGroup3		:= NIL
Local oSay1			:= NIL
Local oSay2			:= NIL
Local oDlg			:= NIL
Local oCodigo		:= NIL
Local oNome			:= NIL
Local oConfirmar	:= NIL
Local oCancelar		:= NIL
Local oGrid			:= NIL
Local oArial 		:= TFont():New("Arial Narrow",,016,,.F.,,,,,.F.,.F.)
Local oArialCinza 	:= TFont():New("Arial",,016,,.T.,,,,,.F.,.F.)
Local oArialN 		:= TFont():New("Arial",,016,,.T.,,,,,.F.,.F.)
Local cCodigo		:= Space(TamSx3("B1_COD")[1])
Local cNome			:= Space(TamSx3("B1_DESC")[1])
Local cFilBkp		:= cFilAnt
Static cRetServ		:= ""


	if !Empty(cFilCtro)
		cFilAnt := cFilCtro
	endif
	
  	DEFINE MSDIALOG oDlg TITLE "Consulta Serviços" FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL

    @ 003, 003 GROUP oGroup1 TO 033, 298 PROMPT "Filtros" OF oDlg COLOR 8421504, 16777215 PIXEL
    @ 014, 008 SAY oSay1 PROMPT "Código:" SIZE 025, 007 OF oDlg FONT oArialN COLORS 0, 16777215 PIXEL
    @ 013, 032 MSGET oCodigo VAR cCodigo SIZE 087, 011 OF oDlg COLORS 0, 16777215 Picture PesqPict("SB1","B1_COD") FONT oArial PIXEL
    
    oCodigo:bLostFocus := {|| RefreshGrid(oGrid,cFilCtro,cContrato,cCodigo,cNome)}
    
    @ 014, 125 SAY oSay2 PROMPT "Nome:" SIZE 027, 007 OF oDlg FONT oArialN COLORS 0, 16777215 PIXEL
    @ 013, 146 MSGET oNome VAR cNome SIZE 149, 011 OF oDlg COLORS 0, 16777215 Picture PesqPict("SB1","B1_DESC") FONT oArial PIXEL
    
    oNome:bLostFocus := {|| RefreshGrid(oGrid,cFilCtro,cContrato,cCodigo,cNome)}
    
    @ 035, 003 GROUP oGroup2 TO 177, 298 PROMPT "Serviços do Contrato" OF oDlg COLOR 8421504, 16777215 PIXEL
    
    //monto a grid de servicos
    oGrid := MsGridCTR(oDlg)
    
    // duplo clique no grid
    oGrid:oBrowse:bLDblClick := {|| cRetServ := SelServico(oDlg,oGrid)}

    @ 179, 003 GROUP oGroup3 TO 196, 298 OF oDlg COLOR 0, 16777215 PIXEL
    @ 183, 210 BUTTON oConfirmar PROMPT "Confirmar" SIZE 037, 010 OF oDlg Action( cRetServ := SelServico(oDlg,oGrid) ) FONT oArialN PIXEL
    @ 183, 256 BUTTON oCancelar PROMPT "Cancelar" SIZE 037, 010 OF oDlg Action(oDlg:End()) FONT oArialN PIXEL

    // caso não tenha encontrato servicos
  	if !RefreshGrid(oGrid,cFilCtro,cContrato)
		
  		Alert("Não foram encontrados servicos para o contrato!")
  		oDlg:End()
		
	endif
	
    ACTIVATE MSDIALOG oDlg CENTERED

  	
    cFilAnt := cFilBkp
    
Return(.T.)

/*/{Protheus.doc} RCPGE15A
//Retorno da Consulta 
@Author Raphael Martins
@Since 14/05/2018
@Version 1.0
@Return
@Type function
/*/
User Function RCPGE15A()

Return(cRetServ)

/*/{Protheus.doc} MsGridCTR
//TODO Função que cria o grid de servicos
@author Raphael Martins
@since 14/05/2018
@version 1.0
@param 	oTela	 	- Dialog da Tela de consulta
@return oGrid		- MsNewGetdados criada dos servicos consultados
@type function
/*/

Static Function MsGridCTR(oTela)

Local oGrid			:= NIL
Local nX			:= 1
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {"ITEM","CODIGO","DESCRICAO"}
Local aAlterFields 	:= {}

For nX := 1 To Len(aFields)
	
	if aFields[nX] == "ITEM"
		Aadd(aHeaderEx, {"Item","ITEM","@E 999",3,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "CODIGO"
		Aadd(aHeaderEx, {"Codigo","CODIGO",PesqPict("SB1","B1_COD"),TamSX3("B1_COD")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "DESCRICAO"
		Aadd(aHeaderEx, {"Descricao","DESCRICAO",PesqPict("SB1","B1_DESC"),TamSX3("B1_DESC")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
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
//TODO Função chamada para preencher a grid de servicos
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param oGrid 			- Objeto da Grid de Contratos 
@param cContrato	 	- Codigo do Contrato em que sera consultado os seus servicos
@param cFilCtro		 	- Filial do Contrato
@param cServico		 	- Codigo do Servico do Contrato
@param cDescricao	 	- Descricao do Servico do Contrato

@return lRet			- Encontrado contratos para reajustar
@type function
/*/
Static Function RefreshGrid(oGrid,cFilCtro,cContrato,cServico,cDescricao)

Local aArea			:= GetArea()
Local aAreaU00		:= U00->(GetArea())
Local aAreaU02		:= U02->(GetArea())
Local cQry			:= ""
Local lRet			:= .F.
Local aFields 		:= {"ITEM","CODIGO","DESCRICAO"}

Default cServico	:= ""
Default	cDescricao	:= "" 
	
// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

cQry := " SELECT "
cQry += " U37_ITEM ITEM,"
cQry += " U37_SERVIC PRODUTO, "
cQry += " U37_DESCRI DESCRICAO "
cQry += " FROM "
cQry += + RetSQLName("U37") + " SERVICOS "
cQry += " WHERE "
cQry += " SERVICOS.D_E_L_E_T_ = ' ' "
cQry += " AND SERVICOS.U37_FILIAL = '" + xFilial("U37") + "' "
cQry += " AND SERVICOS.U37_CODIGO = '" + cContrato + "' "

//valido se o codigo esta preenchido
if !Empty(cServico)
	
	cQry += " AND SERVICOS.U37_SERVIC LIKE '%" + Alltrim(cServico) + "%' "

endif

//valido se o descricao esta preenchido
if !Empty(cDescricao)

	cQry += " AND SERVICOS.U37_DESCRI LIKE '%" + Alltrim(cDescricao) + "%' "

endif


cQry += " ORDER BY ITEM "

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

oGrid:Acols := {}
aFieldFill 	:= {}

// se existir contratos a serem reajustados
if QRY->(!Eof())

	
	lRet 		:= .T. 

	While QRY->(!Eof()) 
	
		
		aFieldFill := {}
		
		aadd(aFieldFill, QRY->ITEM)
		aadd(aFieldFill, QRY->PRODUTO)
		aadd(aFieldFill, QRY->DESCRICAO)
		
		Aadd(aFieldFill, .F.)
		aadd(oGrid:Acols,aFieldFill) 
		
		QRY->(DbSkip())
		
	EndDo
	
else
	
	Aadd(aFieldFill, "")
	Aadd(aFieldFill, "")
	Aadd(aFieldFill, "")
	Aadd(aFieldFill, .F.)
	
	aadd(oGrid:Acols,aFieldFill) 
	
endif

oGrid:oBrowse:Refresh()

RestArea(aArea)
RestArea(aAreaU00)
RestArea(aAreaU02)

Return(lRet)

/*/{Protheus.doc} SelServico
//TODO Funcao para confirmar do servico selecionado

@author Raphael Martins
@since 08/05/2018
@version 1.0
@param oDlg	 			- Objeto Dialog
@param oGrid		 	- Grid de Servicos
@return cRet			- Servico Selecionado
@type function
/*/

Static Function SelServico(oDlg,oGrid)
  
Local nPosServico   := aScan(oGrid:aHeader,{|x| AllTrim(x[2])== "CODIGO"})  
Local cRet			:= oGrid:aCols[oGrid:nAT,nPosServico]

oDlg:End()

Return(cRet)
    