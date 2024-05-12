#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWEditPanel.CH'

/*###########################################################################
#############################################################################
## Programa  | UVIND03 | Autor | Wellington Gon�alves  | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Cadastro de M�todos de Pagamento Vindi					   ##
##=========================================================================##
## Uso       | P�stumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND03()
             
Local oBrowse	:= {}
Private aRotina := {}

// crio o objeto do Browser
oBrowse := FWmBrowse():New()

// defino o Alias
oBrowse:SetAlias("U60")

// informo a descri��o
oBrowse:SetDescription("M�todos de Pagamento Vindi")  

// crio as legendas 
oBrowse:AddLegend("U60_STATUS == 'A'", "GREEN"	,	"Ativo")
oBrowse:AddLegend("U60_STATUS == 'I'", "RED"	,	"Inativo")  

// ativo o browser
oBrowse:Activate()

Return(Nil)

/*###########################################################################
#############################################################################
## Programa  | MenuDef | Autor | Wellington Gon�alves  | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Cria os Menus da Rotina									   ##
##=========================================================================##
## Uso       | P�stumos		                                               ##
#############################################################################
###########################################################################*/

Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   	Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.UVIND03' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.UVIND03' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.UVIND03' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.UVIND03' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.UVIND03' 	OPERATION 08 ACCESS 0     
ADD OPTION aRotina Title 'Legenda'     	Action 'U_UVIND03L()'  		OPERATION 10 ACCESS 0  

Return(aRotina)

/*###########################################################################
#############################################################################
## Programa  | ModelDef | Autor | Wellington Gon�alves | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Cria o Modelo de Dados									   ##
##=========================================================================##
## Uso       | P�stumos		                                               ##
#############################################################################
###########################################################################*/

Static Function ModelDef()

Local oStruU60 	:= FWFormStruct( 1, 'U60', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel	:= NIL

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'UVIND03P', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABE�ALHO  ////////////////////////////

// Crio a Enchoice
oModel:AddFields( 'U60MASTER', /*cOwner*/, oStruU60 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "U60_FILIAL" , "U60_CODIGO" })    

// Preencho a descri��o da entidade
oModel:GetModel('U60MASTER'):SetDescription('Dados do M�todo de Pagamento:')

Return(oModel)

/*###########################################################################
#############################################################################
## Programa  | ViewDef | Autor | Wellington Gon�alves  | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Cria a camada de Vis�o									   ##
##=========================================================================##
## Uso       | P�stumos		                                               ##
#############################################################################
###########################################################################*/

Static Function ViewDef()

Local oStruU60 	:= FWFormStruct(2,'U60')
Local oModel   	:= FWLoadModel('UVIND03')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_U60'	, oStruU60, 'U60MASTER') // cria o cabe�alho

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_U60' , 'PANEL_CABECALHO')

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_U60')

// Habilita a quebra dos campos na Vertical
oView:SetViewProperty( 'U60MASTER', "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } ) 

// Define fechamento da tela ao confirmar a opera��o
oView:SetCloseOnOk({||.T.})

Return(oView)     

/*###########################################################################
#############################################################################
## Programa  | UVIND03L | Autor | Wellington Gon�alves | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Tela de Legenda do Browser								   ##
##=========================================================================##
## Uso       | P�stumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND03L()

BrwLegenda("Status do M�todo de Pagamento","Legenda",{ {"BR_VERDE","Ativo"},{"BR_VERMELHO","Inativo"} })

Return()                    