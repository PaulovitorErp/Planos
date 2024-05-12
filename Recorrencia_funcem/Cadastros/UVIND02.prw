#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWEditPanel.CH'

/*###########################################################################
#############################################################################
## Programa  | UVIND02 | Autor | Wellington Gonçalves  | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Cadastro de Clientes Enviados à Vindi					   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND02()
             
Local oBrowse	:= {}
Private aRotina := {}

// crio o objeto do Browser
oBrowse := FWmBrowse():New()

// defino o Alias
oBrowse:SetAlias("U61")

// informo a descrição
oBrowse:SetDescription("Clientes - Vindi")  

// crio as legendas 
oBrowse:AddLegend("U61_STATUS == 'A'", "GREEN"	,	"Ativo")
oBrowse:AddLegend("U61_STATUS == 'I'", "RED"	,	"Inativo")  

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
ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.UVIND02' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.UVIND02' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.UVIND02' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.UVIND02' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.UVIND02' 	OPERATION 08 ACCESS 0      
ADD OPTION aRotina Title 'Legenda'     	Action 'U_UVIND02L()'  		OPERATION 10 ACCESS 0  

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

Local oStruU61 	:= FWFormStruct( 1, 'U61', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel	:= NIL

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'UVIND02P', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABEÇALHO  ////////////////////////////

// Crio a Enchoice
oModel:AddFields( 'U61MASTER', /*cOwner*/, oStruU61 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "U61_FILIAL" , "U61_CONTRA" , "U61_CLIENT" , "U61_LOJA" })    

// Preencho a descrição da entidade
oModel:GetModel('U61MASTER'):SetDescription('Dados do Cliente:')

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

Local oStruU61 	:= FWFormStruct(2,'U61')
Local oModel   	:= FWLoadModel('UVIND02')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_U61'	, oStruU61, 'U61MASTER') // cria o cabeçalho

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_U61' , 'PANEL_CABECALHO')

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_U61')

// Habilita a quebra dos campos na Vertical
oView:SetViewProperty( 'U61MASTER', "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } ) 

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk({||.T.})

Return(oView) 

/*###########################################################################
#############################################################################
## Programa  | UVIND02L | Autor | Wellington Gonçalves | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Tela de Legenda do Browser								   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND02L()

BrwLegenda("Status do Cliente Vindi","Legenda",{ {"BR_VERDE","Ativo"},{"BR_VERMELHO","Inativo"} })

Return()                         