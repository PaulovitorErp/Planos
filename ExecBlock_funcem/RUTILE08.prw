#include "protheus.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} RUTILE08
Integração de Cadastros
@author Maiki Perin
@since 29/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

Static aSX2List 	:= {}
Static aSX2Control 	:= {}
Static aSX3List 	:= {}
Static aSX3Control 	:= {}
Static aSIXList 	:= {}
Static aSIXControl 	:= {}

/***********************/
User function RUTILE08()
/***********************/

Local oBrowse
Private aRotina := {}

Public __cRetSx2	:= ""
Public __cRetSx3	:= ""
Public __cRetSIX	:= ""

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("U54")
oBrowse:SetDescription("Integração de Cadastros")  
oBrowse:AddLegend("U54_STATUS == 'A'", "GREEN",	"Ativo")
oBrowse:AddLegend("U54_STATUS == 'I'", "RED",	"Inativo") 
oBrowse:Activate()

Return Nil

/************************/
Static Function MenuDef() 
/************************/

Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   	Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.RUTILE08' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.RUTILE08' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.RUTILE08' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Copiar'      	Action 'VIEWDEF.RUTILE08' 	OPERATION 09 ACCESS 0  
ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.RUTILE08' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Legenda'     	Action 'U_UTILE08L()' 		OPERATION 06 ACCESS 0    

Return(aRotina)

/*************************/
Static Function ModelDef()
/*************************/

Local oStruU54 := FWFormStruct(1,'U54',/*bAvalCampo*/,/*lViewUsado*/)
Local oStruU55 := FWFormStruct(1,'U55',/*bAvalCampo*/,/*lViewUsado*/) 
Local oStruU57 := FWFormStruct(1,'U57',/*bAvalCampo*/,/*lViewUsado*/) 
Local oStruU58 := FWFormStruct(1,'U58',/*bAvalCampo*/,/*lViewUsado*/) 
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('PUTILE08',/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)

// Crio a Enchoice
oModel:AddFields('U54MASTER',/*cOwner*/,oStruU54)

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({"U54_FILIAL" ,"U54_CODIGO"})    

// Preencho a descrição da entidade
oModel:GetModel('U54MASTER'):SetDescription('Cadastro')

// Crio o grid
oModel:AddGrid('U55DETAIL','U54MASTER',oStruU55,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)    
oModel:AddGrid('U57DETAIL','U54MASTER',oStruU57,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)    
oModel:AddGrid('U58DETAIL','U57DETAIL',oStruU58,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)    

// Faço o relaciomaneto entre o cabeçalho e os itens
oModel:SetRelation('U55DETAIL',{{'U55_FILIAL', 'xFilial("U55")'},{'U55_CODIGO','U54_CODIGO'}},U55->(IndexKey(1)) )  
oModel:SetRelation('U57DETAIL',{{'U57_FILIAL', 'xFilial("U57")'},{'U57_CODIGO','U54_CODIGO'}},U57->(IndexKey(1)) )  
oModel:SetRelation('U58DETAIL',{{'U58_FILIAL', 'xFilial("U58")'},{'U58_CODIGO','U54_CODIGO'},{"U58_TABFIL","U57_ITEM"}},U58->(IndexKey(1)) )  

// Seto a propriedade de não obrigatoriedade do preenchimento do grid
oModel:GetModel('U57DETAIL'):SetOptional(.T.) 
oModel:GetModel('U58DETAIL'):SetOptional(.T.) 

// Preencho a descrição da entidade
oModel:GetModel('U55DETAIL'):SetDescription('Campos') 
oModel:GetModel('U57DETAIL'):SetDescription('Tabelas Filhas') 
oModel:GetModel('U58DETAIL'):SetDescription('Campos Tabelas Filhas') 

// Não permitir duplicar o código do produto
oModel:GetModel('U55DETAIL'):SetUniqueLine({'U55_CAMPO'}) 
oModel:GetModel('U57DETAIL'):SetUniqueLine({'U57_TABELA','U57_JSON'}) 
oModel:GetModel('U58DETAIL'):SetUniqueLine({'U58_CAMPO','U58_JSON'}) 

Return(oModel)

/************************/
Static Function ViewDef()
/************************/

Local oStruU54 	:= FWFormStruct(2,'U54')
Local oStruU55 	:= FWFormStruct(2,'U55') 
Local oStruU57 	:= FWFormStruct(2,'U57') 
Local oStruU58 	:= FWFormStruct(2,'U58') 
Local oModel   	:= FWLoadModel('RUTILE08')
Local oView

// Remove campos da estrutura
oStruU55:RemoveField('U55_CODIGO')
oStruU57:RemoveField('U57_CODIGO')
oStruU58:RemoveField('U58_CODIGO')
oStruU58:RemoveField('U58_TABFIL')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_U54',oStruU54,'U54MASTER')
oView:AddGrid('VIEW_U55',oStruU55,'U55DETAIL')
oView:AddGrid('VIEW_U57',oStruU57,'U57DETAIL')
oView:AddGrid('VIEW_U58',oStruU58,'U58DETAIL')

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABECALHO',30)
oView:CreateHorizontalBox('PANEL_ITENS',35)    
oView:CreateHorizontalBox('PANEL_TABFIL',35)    
oView:CreateVerticalBox("PANEL_TABELAS",050,"PANEL_TABFIL")
oView:CreateVerticalBox("PANEL_CAMPOS",050,"PANEL_TABFIL")

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_U54','PANEL_CABECALHO')
oView:SetOwnerView('VIEW_U55','PANEL_ITENS')    
oView:SetOwnerView('VIEW_U57','PANEL_TABELAS')    
oView:SetOwnerView('VIEW_U58','PANEL_CAMPOS')    

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_U54')
oView:EnableTitleView('VIEW_U55') 
oView:EnableTitleView('VIEW_U57') 
oView:EnableTitleView('VIEW_U58') 

// Define campos que terao Auto Incremento
oView:AddIncrementField('VIEW_U55','U55_ITEM')
oView:AddIncrementField('VIEW_U57','U57_ITEM')
oView:AddIncrementField('VIEW_U58','U58_ITEM')

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk({||.T.})

// Habilito a barra de progresso na abertura da tela
oView:SetProgressBar(.T.)

Return(oView)

/***********************/
User Function UTILE08L()
/***********************/

BrwLegenda("Status","Legenda",{{"BR_VERDE","Ativo"},{"BR_VERMELHO","Inativo"}})

Return 

/******************************/
User Function TabU54(cChaveAnt)
/******************************/

Local aArea		:= GetArea()
Local cChave
Local nOrd 		:= 1, cOrd:="1",lOk := .F.
Local nPosList	:= 0
Local oListBox, oConf, oCanc, oVisu

Local oDlg
Local oCbx, aOrd		:= {"Chave"}
Local oBigGet, cCampo 	:= Space(3)
Local oSX2			 	:= UGetSxFile():New
Local nX				:= 1

DEFAULT cChaveAnt := &(ReadVar())

If Empty(aSX2List)
	
	aSx2List	:= oSX2:GetInfoSX2( )
	
	For nX:= 1 to Len(aSx2List)		

		AAdd(aSx2Control,{	aSx2List[nX,2]:cRECNOSX2}) 

		If !Empty(cChaveAnt) .And. cChaveAnt == AllTrim(aSx2List[nX,1]:cCHAVE)
			nPosList := Len(aSX2List)
		EndIf
   	
 	Next nX 
Else
	nPosList := aScan(aSX2List,{|aVal| aVal[1] == Upper(cChaveAnt)})
Endif	

DEFINE MSDIALOG oDlg FROM 00,00 TO 400,490 PIXEL TITLE OemToAnsi("Pesquisa")

@05,05 COMBOBOX oCBX VAR cOrd ITEMS aOrd SIZE 206,36 PIXEL OF oDlg FONT oDlg:oFont

@22,05 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL
@05,215 BUTTON oConf Prompt "Pesquisar" SIZE 30,10 FONT oDlg:oFont ACTION (oListBox:nAT := VerTabSX2(aSX2List, aSX2Control, cCampo, oListBox),;
																									oListBox:bLine:={||{aSX2List[oListBox:nAT][1],aSX2List[oListBox:nAT][2]}},;
																									oConf:SetFocus()) OF oDlg PIXEL

oCbx:bChange := {|| nOrd := oCbx:nAt}

@0,0 BITMAP oBmp RESNAME "PROJETOAP" Of oDlg SIZE 100,300 NOBORDER When .F. PIXEL
oListBox := TWBrowse():New( 40,05,204,140,,{"Chave","Descricao"},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oListBox:SetArray(aSX2List)
oListBox:bLine := { ||{aSX2List[oListBox:nAT][1],aSX2List[oListBox:nAT][2]}}
oListBox:bLDblClick := { ||Eval(oConf:bAction), oDlg:End()}
	
@185,05 BUTTON oConf Prompt "Confirma" SIZE 45 ,10 FONT oDlg:oFont ACTION (lOk := .T.,cChave := aSX2List[oListBox:nAT][1],oDlg:End())  OF oDlg PIXEL
@185,55 BUTTON oCanc Prompt "Cancela" SIZE 45 ,10 FONT oDlg:oFont ACTION (lOk := .F.,oDlg:End())  OF oDlg PIXEL

If nPosList > 0
	oListBox:nAT 	:= nPosList	
	oListBox:bLine 	:= {||{aSX2List[oListBox:nAT][1],aSX2List[oListBox:nAT][2]}}
	oConf:SetFocus()
Endif

ACTIVATE MSDIALOG oDlg CENTERED

If !lOk
	cChave := cChaveAnt
Endif

//variavel utilizada no retorno sxb
__cRetSx2 := cChave

RestArea(aArea)

Return lOk

/**********************/
User Function RTabU54()
/**********************/

Return(__cRetSx2)

/**************************************************************/
Static Function VerTabSX2(aSX2List,aSX2Control,cCampo,oListBox)	
/**************************************************************/

Local nPos
Local aArea := GetArea()

nPos := aScan(aSX2List,{|aVal| aVal[1] == Upper(cCampo)})

If nPos == 0
	
	DbSelectArea("SX2")
	DbSetOrder(1) //X2_CHAVE
	DbSeek(AllTrim(Upper(cCampo)),.T.)
	
	nPos := aScan(aSX2Control,{|aVal| aVal[1] == Recno()})
	
	If nPos == 0
		nPos := oListBox:nAt
	EndIf
EndIf

RestArea(aArea)

Return nPos

/******************************/
User Function CpoU55(cCampoAnt)
/******************************/

Local aArea				:= GetArea()
Local nOrd 				:= 1, cOrd:="1",lOk := .F.
Local nPosList			:= 0
Local nX				:= 1
Local oListBox, oConf, oCanc, oVisu

Local oDlg
Local oCbx, aOrd			:= {"Campo"}
Local oBigGet, cCampo 		:= Space(3)
Local oSX3					:= Nil 
Local oModel				:= FWModelActive()    
Local oModelU54 			:= oModel:GetModel("U54MASTER")
Local cTabela				:= oModelU54:GetValue("U54_TABELA")

DEFAULT cCampoAnt 		:= &(ReadVar())

//If Empty(aSX3List)

	aSx3List 	:= {}
	aSx3Control	:= {}
	
	//Instancia objeto de consulta ao dicionario
	oSX3 		:= UGetSxFile():New
	
	If !Empty(cTabela)

		aSx3List	:= oSX3:GetInfoSX3(cTabela)

		For nX:= 1 to Len(aSx3List)	

			AADD(aSx3Control,{ aSX3List[nX,2]:cRECNOSX3 } )

			If !Empty(cCampoAnt) .And. cCampoAnt == aSX3List[nX,2]:cCAMPO
				nPosList := Len(aSX3List)
			Endif

		Next nX
	Else
		Help(,,'Help',,"Campo Tabela obrigatório.",1,0)
		Return .F.
	Endif
//Else
//	nPosList := aScan(aSX3List,{|aVal| aVal[1] == Upper(cCampoAnt)})
//Endif	

DEFINE MSDIALOG oDlg FROM 00,00 TO 400,490 PIXEL TITLE OemToAnsi("Pesquisa")

@05,05 COMBOBOX oCBX VAR cOrd ITEMS aOrd SIZE 206,36 PIXEL OF oDlg FONT oDlg:oFont

@22,05 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL
@05,215 BUTTON oConf Prompt "Pesquisar" SIZE 30,10 FONT oDlg:oFont ACTION (oListBox:nAT := VerTabSX3(aSX3List, aSX3Control, cCampo, oListBox),;
																									oListBox:bLine:={||{aSX3List[oListBox:nAT][1],aSX3List[oListBox:nAT][2]}},;
																									oConf:SetFocus()) OF oDlg PIXEL

oCbx:bChange := {|| nOrd := oCbx:nAt}

@0,0 BITMAP oBmp RESNAME "PROJETOAP" Of oDlg SIZE 100,300 NOBORDER When .F. PIXEL
oListBox := TWBrowse():New( 40,05,204,140,,{"Campo","Titulo"},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oListBox:SetArray(aSX3List)
oListBox:bLine := { ||{aSX3List[oListBox:nAT][1],aSX3List[oListBox:nAT][2]}}
oListBox:bLDblClick := { ||Eval(oConf:bAction), oDlg:End()}
	
@185,05 BUTTON oConf Prompt "Confirma" SIZE 45 ,10 FONT oDlg:oFont ACTION (lOk := .T.,cCampo := aSX3List[oListBox:nAT][1],oDlg:End())  OF oDlg PIXEL
@185,55 BUTTON oCanc Prompt "Cancela" SIZE 45 ,10 FONT oDlg:oFont ACTION (lOk := .F.,oDlg:End())  OF oDlg PIXEL

If nPosList > 0
	oListBox:nAT 	:= nPosList	
	oListBox:bLine 	:= {||{aSX3List[oListBox:nAT][1],aSX3List[oListBox:nAT][2]}}
	oConf:SetFocus()
Endif

ACTIVATE MSDIALOG oDlg CENTERED

If !lOk
	cCampo := cCampoAnt
Endif

//variavel utilizada no retorno sxb
__cRetSx3 := cCampo

RestArea(aArea)

Return lOk

/**********************/
User Function RCpoU55()
/**********************/

Return(__cRetSx3)

/**************************************************************/
Static Function VerTabSX3(aSX3List,aSX3Control,cCampo,oListBox)	
/**************************************************************/

Local nPos
Local aArea  := GetArea()
Local oSX3	 := UGetSxFile():New
Local aRecno := {}

nPos := aScan(aSX3List,{|aVal| aVal[1] == Upper(cCampo)})

If nPos == 0
	
	aRecno	:= oSX3:GetInfoSX3( ,cCampo )
	
	nPos := ASCAN(aSX3Control,{|aVal| aVal[1] == aRecno[1,2]:cRECNOSX3 })
	
	If nPos == 0
		nPos := oListBox:nAt
	EndIf
EndIf

RestArea(aArea)

Return nPos

/*****************************/
User Function U55CAMPO(cCampo)
/*****************************/

Local lRet					:= .T.
Local lAchou				:= .F.

Local oModel				:= FWModelActive()    
Local oModelU54 			:= oModel:GetModel("U54MASTER")
Local cTabela				:= oModelU54:GetValue("U54_TABELA")
Local oSX3	 				:= UGetSxFile():New
Local aCampo				:= {}

If !Empty(cTabela)

	If DbSeek(cTabela)

		aCampo	:= oSX3:GetInfoSX3(cTabela,cCampo)

		If AllTrim(cCampo) == AllTrim(aCampo[1,2]:cCAMPO)
				
			lAchou := .T.
		Endif
			
	Endif
Endif

If !lAchou .And. !Empty(cCampo)
	Help(,,'Help',,"Campo inválido para a tabela |"+AllTrim(cTabela)+"| selecionada.",1,0)
	lRet := .F.
Endif

Return lRet

/******************************/
User Function TabU57(cChaveAnt)
/******************************/

Local aArea		:= GetArea()
Local cChave
Local nOrd 		:= 1, cOrd:="1",lOk := .F.
Local nPosList	:= 0
Local oListBox, oConf, oCanc, oVisu

Local oDlg
Local oCbx, aOrd		:= {"Chave"}
Local oBigGet, cCampo 	:= Space(3)
Local oSX2				:= UGetSxFile():New
Local nX				:= 1
DEFAULT cChaveAnt := &(ReadVar())

If Empty(aSX2List)
	
	aSx2List	:= oSX2:GetInfoSX2()

	For nX:= 1 to Len(aSx2List)
		
		AAdd(aSx2Control,{	aSx2List[nX,2]:cRECNOSX2	}) 
		
		If !Empty(cChaveAnt) .And. cChaveAnt == AllTrim(aSx2List[nX,2]:cCHAVE )
			nPosList := Len(aSX2List)
		EndIf
   	
	Next nX 
Else
	nPosList := aScan(aSX2List,{|aVal| aVal[1] == Upper(cChaveAnt)})
Endif	

DEFINE MSDIALOG oDlg FROM 00,00 TO 400,490 PIXEL TITLE OemToAnsi("Pesquisa")

@05,05 COMBOBOX oCBX VAR cOrd ITEMS aOrd SIZE 206,36 PIXEL OF oDlg FONT oDlg:oFont

@22,05 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL
@05,215 BUTTON oConf Prompt "Pesquisar" SIZE 30,10 FONT oDlg:oFont ACTION (oListBox:nAT := TabSX2_2(aSX2List, aSX2Control, cCampo, oListBox),;
																									oListBox:bLine:={||{aSX2List[oListBox:nAT][1],aSX2List[oListBox:nAT][2]}},;
																									oConf:SetFocus()) OF oDlg PIXEL

oCbx:bChange := {|| nOrd := oCbx:nAt}

@0,0 BITMAP oBmp RESNAME "PROJETOAP" Of oDlg SIZE 100,300 NOBORDER When .F. PIXEL
oListBox := TWBrowse():New( 40,05,204,140,,{"Chave","Descricao"},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oListBox:SetArray(aSX2List)
oListBox:bLine := { ||{aSX2List[oListBox:nAT][1],aSX2List[oListBox:nAT][2]}}
oListBox:bLDblClick := { ||Eval(oConf:bAction), oDlg:End()}
	
@185,05 BUTTON oConf Prompt "Confirma" SIZE 45 ,10 FONT oDlg:oFont ACTION (lOk := .T.,cChave := aSX2List[oListBox:nAT][1],oDlg:End())  OF oDlg PIXEL
@185,55 BUTTON oCanc Prompt "Cancela" SIZE 45 ,10 FONT oDlg:oFont ACTION (lOk := .F.,oDlg:End())  OF oDlg PIXEL

If nPosList > 0
	oListBox:nAT 	:= nPosList	
	oListBox:bLine 	:= {||{aSX2List[oListBox:nAT][1],aSX2List[oListBox:nAT][2]}}
	oConf:SetFocus()
Endif

ACTIVATE MSDIALOG oDlg CENTERED

If !lOk
	cChave := cChaveAnt
Endif

//variavel utilizada no retorno sxb
__cRetSx2 := cChave

RestArea(aArea)

Return lOk

/**********************/
User Function RTabU57()
/**********************/

Return(__cRetSx2)

/*************************************************************/
Static Function TabSX2_2(aSX2List,aSX2Control,cCampo,oListBox)	
/*************************************************************/

Local nPos
Local aArea := GetArea()
Local oSX2				:= UGetSxFile():New
Local aRecno			:= {}

nPos := aScan(aSX2List,{|aVal| aVal[1] == Upper(cCampo)})

If nPos == 0
	
	aRecno := oSX2:GetInfoSX2(cCampo)
	
	nPos := aScan(aSX2Control,{|aVal| aVal[1] == aRecno[1,2]:cRECNOSX2 })
	
	If nPos == 0
		nPos := oListBox:nAt
	EndIf
EndIf

RestArea(aArea)

Return nPos

/******************************/
User Function CpoU58(cCampoAnt)
/******************************/

Local aArea				:= GetArea()
Local nOrd 				:= 1, cOrd:="1",lOk := .F.
Local nPosList			:= 0
Local nX				:= 1
Local oListBox, oConf, oCanc, oVisu

Local oDlg
Local oCbx, aOrd		:= {"Campo"}
Local oBigGet
Local cCampo 				:= Space(TamSx3("X3_CAMPO")[1])

Local oModel				:= FWModelActive()    
Local oModelU57 			:= oModel:GetModel("U57DETAIL")
Local cTabela				:= oModelU57:GetValue("U57_TABELA")
Local oSX3					:= UGetSxFile():New

DEFAULT cCampoAnt 		:= &(ReadVar())

//If Empty(aSX3List)

	aSx3List 	:= {}
	aSx3Control	:= {}
	
	If !Empty(cTabela)

		aSx3List	:= oSX3:GetInfoSX3(cTabela)
	
		For nX:= 1 to Len(aSx3List)

		 	AAdd(aSx3Control,{SX3->( aSx3List[nX,2]:cRECNOSX3 )}) 
				
			If !Empty(cCampoAnt) .And. Alltrim(CampoAnt) == Alltrim(aSx3List[nX,2]:cCAMPO)
				nPosList := Len(aSX3List)
			Endif

		Next nX
	Else
		Help(,,'Help',,"Campo Tabela obrigatório.",1,0)
		Return .F.
	Endif
//Else
//	nPosList := aScan(aSX3List,{|aVal| aVal[1] == Upper(cCampoAnt)})
//Endif	

DEFINE MSDIALOG oDlg FROM 00,00 TO 400,490 PIXEL TITLE OemToAnsi("Pesquisa")

@05,05 COMBOBOX oCBX VAR cOrd ITEMS aOrd SIZE 206,36 PIXEL OF oDlg FONT oDlg:oFont

@22,05 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL
@05,215 BUTTON oConf Prompt "Pesquisar" SIZE 30,10 FONT oDlg:oFont ACTION (oListBox:nAT := TabSX3_2(aSX3List, aSX3Control, cCampo, oListBox),;
																									oListBox:bLine:={||{aSX3List[oListBox:nAT][1],aSX3List[oListBox:nAT][2]}},;
																									oConf:SetFocus()) OF oDlg PIXEL

oCbx:bChange := {|| nOrd := oCbx:nAt}

@0,0 BITMAP oBmp RESNAME "PROJETOAP" Of oDlg SIZE 100,300 NOBORDER When .F. PIXEL
oListBox := TWBrowse():New( 40,05,204,140,,{"Campo","Titulo"},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oListBox:SetArray(aSX3List)
oListBox:bLine := { ||{aSX3List[oListBox:nAT][1],aSX3List[oListBox:nAT][2]}}
oListBox:bLDblClick := { ||Eval(oConf:bAction), oDlg:End()}
	
@185,05 BUTTON oConf Prompt "Confirma" SIZE 45 ,10 FONT oDlg:oFont ACTION (lOk := .T.,cCampo := aSX3List[oListBox:nAT][1],oDlg:End())  OF oDlg PIXEL
@185,55 BUTTON oCanc Prompt "Cancela" SIZE 45 ,10 FONT oDlg:oFont ACTION (lOk := .F.,oDlg:End())  OF oDlg PIXEL

If nPosList > 0
	oListBox:nAT 	:= nPosList	
	oListBox:bLine 	:= {||{aSX3List[oListBox:nAT][1],aSX3List[oListBox:nAT][2]}}
	oConf:SetFocus()
Endif

ACTIVATE MSDIALOG oDlg CENTERED

If !lOk
	cCampo := cCampoAnt
Endif

//variavel utilizada no retorno sxb
__cRetSx3 := cCampo

RestArea(aArea)

Return lOk

/**********************/
User Function RCpoU58()
/**********************/

Return(__cRetSx3)

/*************************************************************/
Static Function TabSX3_2(aSX3List,aSX3Control,cCampo,oListBox)	
/*************************************************************/

Local nPos
Local aArea 	:= GetArea()
Local oSX3		:= UGetSxFile():New
Local aRecno	:= {}

nPos := aScan(aSX3List,{|aVal| aVal[1] == Upper(cCampo)})

If nPos == 0
		
	aRecno := oSX3:GetInfoSX3(cTabela, cCampo )

	nPos := ASCAN(aSX3Control,{|aVal| aVal[1] == aRecno[1,2]:cRECNOSX3})
	
	If nPos == 0
		nPos := oListBox:nAt
	EndIf
EndIf

RestArea(aArea)

Return nPos

/*****************************/
User Function U58CAMPO(cCampo)
/*****************************/

Local lRet					:= .T.
Local lAchou				:= .F.

Local oModel				:= FWModelActive()    
Local oModelU57 			:= oModel:GetModel("U57DETAIL")
Local cTabela				:= oModelU57:GetValue("U57_TABELA")
Local oSX3					:= UGetSxFile():New
Local aCampo				:= {}
Local nX					:= 1

If !Empty(cTabela)

	
	If DbSeek(cTabela)

		aCampo := oSX3:GetInfoSX3(cTabela)

		For nX := 1 to Len(aCampo)
		
			If AllTrim(cCampo) == AllTrim(aCampo[nX,2]:cCAMPO)
				
				lAchou := .T.
				Exit
			Endif

		Next nX

	Endif

Endif

If !lAchou .And. !Empty(cCampo)
	Help(,,'Help',,"Campo inválido para a tabela |"+AllTrim(cTabela)+"| selecionada.",1,0)
	lRet := .F.
Endif

Return lRet

/******************************/
User Function IndU57(cChaveAnt)
/******************************/

Local aArea				:= GetArea()
Local cChave
Local nOrd 				:= 1, cOrd:="1",lOk := .F.
Local nPosList			:= 0
Local nX				:= 1
Local oListBox, oConf, oCanc, oVisu

Local oDlg
Local oCbx, aOrd		:= {"Chave"}
Local oBigGet, cCampo 	:= Space(Len(SIX->ORDEM))

Local oModel			:= FWModelActive()    
Local oModelU57 		:= oModel:GetModel("U57DETAIL")
Local cIndice			:= oModelU57:GetValue("U57_TABELA")
Local oSIX				:= UGetSxFile():New

DEFAULT cChaveAnt 		:= &(ReadVar())

//If Empty(aSIXList)

	aSIXList 	:= {}
	aSIXControl	:= {}


	If !Empty(cIndice)
		
		aSIXList 	:= oSIX:GetInfoSIX(cIndice)

		For nX:= 1 to Len(aSIXList)	

			AADD(aSIXControl,{aSIXList[nX,2]:cRECNOSIX })

			If !Empty(cChaveAnt) .And. cChaveAnt == AllTrim(aSIXList[nX,2]:cCHAVE)
				nPosList := Len(aSIXList)
			EndIf
	   	
		Next nX
	Else
		Help(,,'Help',,"Campo Tabela obrigatório.",1,0)
		Return .F.
	Endif
//Else
	//nPosList := aScan(aSIXList,{|aVal| aVal[1] == Upper(cChaveAnt)})
//Endif	

DEFINE MSDIALOG oDlg FROM 00,00 TO 400,490 PIXEL TITLE OemToAnsi("Pesquisa")

@05,05 COMBOBOX oCBX VAR cOrd ITEMS aOrd SIZE 206,36 PIXEL OF oDlg FONT oDlg:oFont

@22,05 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL
@05,215 BUTTON oConf Prompt "Pesquisar" SIZE 30,10 FONT oDlg:oFont ACTION (oListBox:nAT := VerIndSIX(aSIXList, aSIXControl, cCampo, oListBox),;
																									oListBox:bLine:={||{aSIXList[oListBox:nAT][1],aSIXList[oListBox:nAT][2]}},;
																									oConf:SetFocus()) OF oDlg PIXEL

oCbx:bChange := {|| nOrd := oCbx:nAt}

@0,0 BITMAP oBmp RESNAME "PROJETOAP" Of oDlg SIZE 100,300 NOBORDER When .F. PIXEL
oListBox := TWBrowse():New( 40,05,204,140,,{"Chave","Descricao"},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oListBox:SetArray(aSIXList)
oListBox:bLine := { ||{aSIXList[oListBox:nAT][1],aSIXList[oListBox:nAT][2]}}
oListBox:bLDblClick := { ||Eval(oConf:bAction), oDlg:End()}
	
@185,05 BUTTON oConf Prompt "Confirma" SIZE 45 ,10 FONT oDlg:oFont ACTION (lOk := .T.,cChave := aSIXList[oListBox:nAT][1],oDlg:End())  OF oDlg PIXEL
@185,55 BUTTON oCanc Prompt "Cancela" SIZE 45 ,10 FONT oDlg:oFont ACTION (lOk := .F.,oDlg:End())  OF oDlg PIXEL

If nPosList > 0
	oListBox:nAT 	:= nPosList	
	oListBox:bLine 	:= {||{aSIXList[oListBox:nAT][1],aSIXList[oListBox:nAT][2]}}
	oConf:SetFocus()
Endif

ACTIVATE MSDIALOG oDlg CENTERED

If !lOk
	cChave := cChaveAnt
Endif

//variavel utilizada no retorno sxb
__cRetSIX := cChave

RestArea(aArea)

Return lOk

/**********************/
User Function RIndU57()
/**********************/

Return(__cRetSIX)

/**************************************************************/
Static Function VerIndSIX(aSIXList,aSIXControl,cCampo,oListBox)	
/**************************************************************/

Local nPos
Local aArea 	:= GetArea()
Local oSIX		:= UGetSxFile():New

nPos := aScan(aSIXList,{|aVal| aVal[1] == Upper(cCampo)})

If nPos == 0
	
	aRecno := oSIX:GetInfoSIX(SubStr(Alltrim(cCampo),1,3),SubStr(Alltrim(cCampo),4,1))

	nPos := aScan(aSIXControl,{|aVal| aVal[1] == aRecno[1,2]:cRECNOSIX })
	
	If nPos == 0
		nPos := oListBox:nAt
	EndIf
EndIf

RestArea(aArea)

Return nPos

/***************************/
User Function U57IND(cOrdem)
/***************************/

Local lRet					:= .T.
Local lAchou				:= .F.
Local nX					:= 1
Local oModel				:= FWModelActive()    
Local oModelU57 			:= oModel:GetModel("U57DETAIL")
Local cTabela				:= oModelU57:GetValue("U57_TABELA")
Local oSIX					:= UGetSxFile():New
Local aIndice				:= {}

If !Empty(cTabela)

	aIndice := oSIX:GetInfoSIX(cTabela,cOrdem)

	For nX:=1 to Len(aIndice)
		
		If AllTrim(cOrdem) == AllTrim(aIndice[nX,2]:cORDEM)
				
			lAchou := .T.
			Exit
		Endif
			
	Next nX
	
Endif

If !lAchou .And. !Empty(cOrdem)
	Help(,,'Help',,"Índice inválido para a tabela |"+AllTrim(cTabela)+"| selecionada.",1,0)
	lRet := .F.
Endif

Return lRet

/***************************/
User Function U57GAT(cOrdem)
/***************************/

Local cRet					:= ""

Local oModel				:= FWModelActive()    
Local oModelU57 			:= oModel:GetModel("U57DETAIL")
Local cTabela				:= oModelU57:GetValue("U57_TABELA")
Local oSIX					:= UGetSxFile():New
Local aIndice				:= {}

If !Empty(cTabela)

	aIndice := oSIX:GetInfoSIX(cTabela,cOrdem)
	
	If Len(aIndice) > 0
		cRet := aIndice[1,2]:cCHAVE
	Else
		Help(,,'Help',,"Índice inválido para a tabela |"+AllTrim(cTabela)+"| selecionada.",1,0)
		cRet := ""
	Endif
Endif

Return cRet