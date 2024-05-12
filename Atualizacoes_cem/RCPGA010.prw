#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'

User Function RCPGA010()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'U18' )
oBrowse:SetDescription( 'Ciclo de Cobrança' )  

oBrowse:Activate()

Return


//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   Action 'PesqBrw'          OPERATION 1 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  Action 'VIEWDEF.RCPGA010' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     Action 'VIEWDEF.RCPGA010' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     Action 'VIEWDEF.RCPGA010' OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     Action 'VIEWDEF.RCPGA010' OPERATION 5 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruU18 := FWFormStruct( 1, 'U18', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PCPGA010', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul·rio de ediÁ„o por campo
oModel:AddFields( 'U18MASTER', /*cOwner*/, oStruU18 )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Ciclo de Cobrança' )        

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "U18_FILIAL" , "U18_CODIGO" })

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'U18MASTER' ):SetDescription( 'Dados' )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef() 

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruU18 := FWFormStruct( 2, 'U18' )  

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'RCPGA010' )

Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser· utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_U18', oStruU18, 'U18MASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_U18', 'SUPERIOR' )

Return oView