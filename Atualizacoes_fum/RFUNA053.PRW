#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWEditPanel.CH'

/*/{Protheus.doc} RFUNA053
Cadastro de Produtos x Tipos de Servicos
@type function
@version 
@author Raphael Martins
@since 05/08/2020
@return return_type, return_description
/*/
User Function RFUNA053()
             
Local oBrowse	:= {}
Private aRotina := {}

// crio o objeto do Browser
oBrowse := FWmBrowse():New()

// defino o Alias
oBrowse:SetAlias("UK0")

// informo a descrição
oBrowse:SetDescription("Produtos x Tipos de Servicos")  

// ativo o browser
oBrowse:Activate()

Return(Nil)

/*/{Protheus.doc} MenuDef
Cria os Menus da Rotina
@type function
@version 
@author Raphael Martins
@since 05/08/2020
@return return_type, return_description
/*/
Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   	Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.RFUNA053' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.RFUNA053' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.RFUNA053' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.RFUNA053' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Copiar'      	Action 'VIEWDEF.RFUNA053' 	OPERATION 09 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.RFUNA053' 	OPERATION 08 ACCESS 0  
 

Return(aRotina)

/*/{Protheus.doc} ModelDef
Cria o Modelo de Dados
@type function
@version 
@author Raphael Martins
@since 05/08/2020
@return return_type, return_description
/*/
Static Function ModelDef()

Local oStruUK0	:= FWFormStruct( 1, 'UK0', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruUK1	:= FWFormStruct( 1, 'UK1', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel	:= NIL

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PFUNA053', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABEÇALHO   ////////////////////////////

// Crio a Enchoice
oModel:AddFields( 'UK0MASTER', /*cOwner*/, oStruUK0 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "UK0_FILIAL" , "UK0_CODIGO" })    

// Preencho a descrição da entidade
oModel:GetModel('UK0MASTER'):SetDescription('Tipos de Servicos')

///////////////////////////  ITENS  //////////////////////////////

// Crio o grid
oModel:AddGrid( 'UK1DETAIL', 'UK0MASTER', oStruUK1, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faz o relaciomaneto entre o cabeçalho e os itens
oModel:SetRelation( 'UK1DETAIL', { { 'UK1_FILIAL', 'xFilial( "UK1" )' } , { 'UK1_CODIGO', 'UK0_CODIGO' } } , UK1->(IndexKey(1)) )  

// Seta a propriedade de não obrigatoriedade do preenchimento do grid
oModel:GetModel('UK1DETAIL'):SetOptional( .T. ) 

// Preencho a descrição da entidade
oModel:GetModel('UK1DETAIL'):SetDescription('Produtos e Servicos') 

Return(oModel)

/*/{Protheus.doc} ViewDef
Cria a camada de Visão
@type function
@version 
@author Raphael Martins
@since 05/08/2020
@return return_type, return_description
/*/
Static Function ViewDef()

Local oStruUK0 	:= FWFormStruct(2,'UK0')
Local oStruUK1 	:= FWFormStruct(2,'UK1')
Local oModel   	:= FWLoadModel('RFUNA053')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_UK0'	, oStruUK0, 'UK0MASTER') // cria o cabeçalho
oView:AddGrid('VIEW_UK1'	, oStruUK1, 'UK1DETAIL') // Cria o grid

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABECALHO' , 40)
oView:CreateHorizontalBox('PANEL_ITENS' 	, 60)

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_UK0' , 'PANEL_CABECALHO')
oView:SetOwnerView('VIEW_UK1' , 'PANEL_ITENS')

oView:AddIncrementField( 'VIEW_UK1', 'UK1_ITEM' )

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_UK1')

// Habilita a quebra dos campos na Vertical
oView:SetViewProperty( 'UK0MASTER', "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 2 } ) 

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk({||.T.})

Return(oView)                
