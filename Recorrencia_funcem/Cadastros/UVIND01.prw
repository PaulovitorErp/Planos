#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWEditPanel.CH'

/*###########################################################################
#############################################################################
## Programa  | UVIND01 | Autor | Wellington Gonçalves  | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Cadastro de Status de retorno Vindi HTTP					   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND01()
             
Local oBrowse	:= {}
Private aRotina := {}

// crio o objeto do Browser
oBrowse := FWmBrowse():New()

// defino o Alias
oBrowse:SetAlias("U59")

// informo a descrição
oBrowse:SetDescription("Status de Retorno HTTP - Vindi")  

// ativo o browser
oBrowse:Activate()

Return(Nil)

/*###########################################################################
#############################################################################
## Programa  | MenuDef | Autor | Wellington Gonçalves  | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Cria os Menus da Rotina									   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   	Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.UVIND01' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.UVIND01' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.UVIND01' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.UVIND01' 	OPERATION 08 ACCESS 0      

Return(aRotina)

/*###########################################################################
#############################################################################
## Programa  | ModelDef | Autor | Wellington Gonçalves | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Cria o Modelo de Dados									   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

Static Function ModelDef()

Local oStruU59 	:= FWFormStruct( 1, 'U59', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel	:= NIL

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'UVIND01P', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABEÇALHO  ////////////////////////////

// Crio a Enchoice
oModel:AddFields( 'U59MASTER', /*cOwner*/, oStruU59 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "U59_FILIAL" , "U59_CODIGO" })    

// Preencho a descrição da entidade
oModel:GetModel('U59MASTER'):SetDescription('Dados do Status HTTP:')

Return(oModel)

/*###########################################################################
#############################################################################
## Programa  | ViewDef | Autor | Wellington Gonçalves  | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Cria a camada de Visão									   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

Static Function ViewDef()

Local oStruU59 	:= FWFormStruct(2,'U59')
Local oModel   	:= FWLoadModel('UVIND01')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_U59'	, oStruU59, 'U59MASTER') // cria o cabeçalho

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_U59' , 'PANEL_CABECALHO')

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_U59')

// Habilita a quebra dos campos na Vertical
oView:SetViewProperty( 'U59MASTER', "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } ) 

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk({||.T.})

Return(oView)                         