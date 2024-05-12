#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWEditPanel.CH'

/*/{Protheus.doc} RCPGA051
Cadastro de Servicos x Tarefas 
@type function
@version 1.0
@author Raphael Martins
@since 20/08/2023
/*/
User Function RCPGA051()
             
Local oBrowse	:= {}
Private aRotina := {}

// crio o objeto do Browser
oBrowse := FWmBrowse():New()

// defino o Alias
oBrowse:SetAlias("UZX")

// informo a descrição
oBrowse:SetDescription("Serviços x Tarefas")  

// ativo o browser
oBrowse:Activate()

Return(Nil)

/*/{Protheus.doc} MenuDef
Cria os Menus da Rotina
@type function
@version 1.0
@author Raphael Martins
@since 05/08/2020
/*/
Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   	Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.RCPGA051' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.RCPGA051' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.RCPGA051' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.RCPGA051' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Copiar'      	Action 'VIEWDEF.RCPGA051' 	OPERATION 09 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.RCPGA051' 	OPERATION 08 ACCESS 0  
 

Return(aRotina)

/*/{Protheus.doc} ModelDef
Cria o Modelo de Dados
@type function
@version 1.0
@author Raphael Martins
@since 05/08/2020
/*/
Static Function ModelDef()

Local oStruUZR	:= FWFormStruct( 1, 'UZX', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruUZS	:= FWFormStruct( 1, 'UZY', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel	:= NIL

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PCPGA049', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABEÇALHO   ////////////////////////////

// Crio a Enchoice
oModel:AddFields( 'UZXMASTER', /*cOwner*/, oStruUZR )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "UZX_FILIAL" , "UZX_CODIGO" })    

// Preencho a descrição da entidade
oModel:GetModel('UZXMASTER'):SetDescription('Servicos:')

///////////////////////////  ITENS  //////////////////////////////

// Crio o grid
oModel:AddGrid( 'UZYDETAIL', 'UZXMASTER', oStruUZS, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faz o relaciomaneto entre o cabeçalho e os itens
oModel:SetRelation( 'UZYDETAIL', { { 'UZY_FILIAL', 'xFilial( "UZY" )' } , { 'UZY_CODIGO', 'UZX_CODIGO' } } , UZY->(IndexKey(1)) )  

// Seta a propriedade de não obrigatoriedade do preenchimento do grid
oModel:GetModel('UZYDETAIL'):SetOptional( .T. ) 

// Preencho a descrição da entidade
oModel:GetModel('UZYDETAIL'):SetDescription('Tarefas do Servico:') 

Return(oModel)

/*/{Protheus.doc} ViewDef
Cria a camada de Visão
@type function
@version 1.0
@author Raphael Martins
@since 05/08/2020
/*/
Static Function ViewDef()

Local oStruUZR 	:= FWFormStruct(2,'UZX')
Local oStruUZS 	:= FWFormStruct(2,'UZY')
Local oModel   	:= FWLoadModel('RCPGA051')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_UZX'	, oStruUZR, 'UZXMASTER') // cria o cabeçalho
oView:AddGrid('VIEW_UZY'	, oStruUZS, 'UZYDETAIL') // Cria o grid

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABECALHO' , 40)
oView:CreateHorizontalBox('PANEL_ITENS' 	, 60)

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_UZX' , 'PANEL_CABECALHO')
oView:SetOwnerView('VIEW_UZY' , 'PANEL_ITENS')

oView:AddIncrementField( 'VIEW_UZY', 'UZY_ITEM' )

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_UZY')

// Habilita a quebra dos campos na Vertical
oView:SetViewProperty( 'UZXMASTER', "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 2 } ) 

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk({||.T.})

Return(oView)
