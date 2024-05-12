#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWEditPanel.CH'

/*/{Protheus.doc} RFUNA053
Cadastro de Produtos x Tipos de Servicos - Apto Cemiterio
@type function
@version 
@author Raphael Martins
@since 05/08/2020
@return return_type, return_description
/*/
User Function RCPGA048()
             
Local oBrowse	:= {}
Private aRotina := {}

// crio o objeto do Browser
oBrowse := FWmBrowse():New()

// defino o Alias
oBrowse:SetAlias("UZR")

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
ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.RCPGA048' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.RCPGA048' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.RCPGA048' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.RCPGA048' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Copiar'      	Action 'VIEWDEF.RCPGA048' 	OPERATION 09 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.RCPGA048' 	OPERATION 08 ACCESS 0  
 

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

Local oStruUZR	:= FWFormStruct( 1, 'UZR', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruUZS	:= FWFormStruct( 1, 'UZS', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel	:= NIL

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PCPGA048', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABEÇALHO   ////////////////////////////

// Crio a Enchoice
oModel:AddFields( 'UZRMASTER', /*cOwner*/, oStruUZR )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "UZR_FILIAL" , "UZR_CODIGO" })    

// Preencho a descrição da entidade
oModel:GetModel('UZRMASTER'):SetDescription('Tipos de Servicos')

///////////////////////////  ITENS  //////////////////////////////

// Crio o grid
oModel:AddGrid( 'UZSDETAIL', 'UZRMASTER', oStruUZS, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faz o relaciomaneto entre o cabeçalho e os itens
oModel:SetRelation( 'UZSDETAIL', { { 'UZS_FILIAL', 'xFilial( "UZS" )' } , { 'UZS_CODIGO', 'UZR_CODIGO' } } , UZS->(IndexKey(1)) )  

// Seta a propriedade de não obrigatoriedade do preenchimento do grid
oModel:GetModel('UZSDETAIL'):SetOptional( .T. ) 

// Preencho a descrição da entidade
oModel:GetModel('UZSDETAIL'):SetDescription('Produtos e Servicos') 

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

Local oStruUZR 	:= FWFormStruct(2,'UZR')
Local oStruUZS 	:= FWFormStruct(2,'UZS')
Local oModel   	:= FWLoadModel('RCPGA048')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_UZR'	, oStruUZR, 'UZRMASTER') // cria o cabeçalho
oView:AddGrid('VIEW_UZS'	, oStruUZS, 'UZSDETAIL') // Cria o grid

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABECALHO' , 40)
oView:CreateHorizontalBox('PANEL_ITENS' 	, 60)

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_UZR' , 'PANEL_CABECALHO')
oView:SetOwnerView('VIEW_UZS' , 'PANEL_ITENS')

oView:AddIncrementField( 'VIEW_UZS', 'UZS_ITEM' )

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_UZS')

// Habilita a quebra dos campos na Vertical
oView:SetViewProperty( 'UZRMASTER', "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 2 } ) 

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk({||.T.})

Return(oView)                
