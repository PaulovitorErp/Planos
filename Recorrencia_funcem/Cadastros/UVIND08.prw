#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWEditPanel.CH'

/*###########################################################################
#############################################################################
## Programa  | UVIND08 | Autor | Wellington Gonçalves  | Data | 16/02/2019 ##
##=========================================================================##
## Desc.     | Cadastro de Faturas do Cliente Vindi			   			   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND08()
             
Local oBrowse	:= {}
Private aRotina := {}

// crio o objeto do Browser
oBrowse := FWmBrowse():New()

// defino o Alias
oBrowse:SetAlias("U65")

// informo a descrição
oBrowse:SetDescription("Faturas - Vindi")  

// crio as legendas 
oBrowse:AddLegend("U65_STATUS == 'A'", "GREEN"	,	"Ativo")
oBrowse:AddLegend("U65_STATUS == 'I'", "RED"	,	"Inativo")  

// ativo o browser
oBrowse:Activate()

Return(Nil)

/*###########################################################################
#############################################################################
## Programa  | MenuDef | Autor | Wellington Gonçalves  | Data | 16/02/2019 ##
##=========================================================================##
## Desc.     | Cria os Menus da Rotina									   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   	Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.UVIND08' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.UVIND08' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.UVIND08' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.UVIND08' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.UVIND08' 	OPERATION 08 ACCESS 0  
ADD OPTION aRotina Title 'Legenda'     	Action 'U_UVIND08L()'  		OPERATION 10 ACCESS 0     

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

Local oStruU65 	:= FWFormStruct( 1, 'U65', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruU66 	:= FWFormStruct( 1, 'U66', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel	:= NIL

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'UVIND08P', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABEÇALHO - FATURAS VINDI  ////////////////////////////

// Crio a Enchoice
oModel:AddFields( 'U65MASTER', /*cOwner*/, oStruU65 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "U65_FILIAL" , "U65_PREFIX" , "U65_NUM" , "U65_PARCEL" , "U65_TIPO" })    

// Preencho a descrição da entidade
oModel:GetModel('U65MASTER'):SetDescription('Dados do Cliente Vindi:')

///////////////////////////  ITENS - TENTATIVAS DE RECEBIMENTO  //////////////////////////////

// Crio o grid
oModel:AddGrid( 'U66DETAIL', 'U65MASTER', oStruU66, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faz o relaciomaneto entre o cabeçalho e os itens
oModel:SetRelation( 'U66DETAIL', { { 'U66_FILIAL', 'xFilial( "U66" )' } , { 'U66_CODIGO', 'U65_CODIGO' } } , U66->(IndexKey(1)) )  

// Seta a propriedade de não obrigatoriedade do preenchimento do grid
oModel:GetModel('U66DETAIL'):SetOptional( .T. ) 

// Preencho a descrição da entidade
oModel:GetModel('U66DETAIL'):SetDescription('Tentativas de Recebimento:') 

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

Local oStruU65 	:= FWFormStruct(2,'U65')
Local oStruU66 	:= FWFormStruct(2,'U66')
Local oModel   	:= FWLoadModel('UVIND08')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_U65'	, oStruU65, 'U65MASTER') // cria o cabeçalho
oView:AddGrid('VIEW_U66'	, oStruU66, 'U66DETAIL') // Cria o grid

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABECALHO' , 60)
oView:CreateHorizontalBox('PANEL_ITENS' 	, 40)

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_U65' , 'PANEL_CABECALHO')
oView:SetOwnerView('VIEW_U66' , 'PANEL_ITENS')

// Ligo a identificacao do componente
//oView:EnableTitleView('VIEW_U65')
oView:EnableTitleView('VIEW_U66')

// Habilita a quebra dos campos na Vertical
oView:SetViewProperty( 'U65MASTER', "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 2 } ) 

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk({||.T.})

Return(oView)  

/*###########################################################################
#############################################################################
## Programa  | UVIND08L | Autor | Wellington Gonçalves | Data | 17/02/2019 ##
##=========================================================================##
## Desc.     | Tela de Legenda do Browser								   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND08L()

BrwLegenda("Status da Fatura Vindi","Legenda",{ {"BR_VERDE","Ativo"},{"BR_VERMELHO","Inativo"} })

Return()                  