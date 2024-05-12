#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWEditPanel.CH'

/*###########################################################################
#############################################################################
## Programa  | UVIND16 | Autor | Leandro Rodrigues     | Data | 25/11/2019 ##
##=========================================================================##
## Desc.     | Cadastro de GateWay X Bandeiras          	   			   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND16()
             
Local oBrowse	:= {}
Private aRotina := {}

// crio o objeto do Browser
oBrowse := FWmBrowse():New()

// defino o Alias
oBrowse:SetAlias("UJT")

// informo a descrição
oBrowse:SetDescription("Gateway X Bandeira")  

// crio as legendas 
oBrowse:AddLegend("UJT_STATUS == 'A'", "GREEN"	,	"Ativo")
oBrowse:AddLegend("UJT_STATUS == 'I'", "RED"	,	"Inativo")  

// ativo o browser
oBrowse:Activate()

Return(Nil)

/*###########################################################################
#############################################################################
## Programa  | MenuDef | Autor | Leandro Rodrigues     | Data | 25/11/2019 ##
##=========================================================================##
## Desc.     | Cria os Menus da Rotina									   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   	Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.UVIND16' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.UVIND16' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.UVIND16' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.UVIND16' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.UVIND16' 	OPERATION 08 ACCESS 0  
ADD OPTION aRotina Title 'Legenda'     	Action 'U_UVIND16L()'  		OPERATION 10 ACCESS 0     

Return(aRotina)

/*###########################################################################
#############################################################################
## Programa  | ModelDef | Autor | Leandro Rodrigues    | Data | 25/11/2019 ##
##=========================================================================##
## Desc.     | Cria o Modelo de Dados									   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

Static Function ModelDef()

Local oStruUJT	:= FWFormStruct( 1, 'UJT', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruUJU 	:= FWFormStruct( 1, 'UJU', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel	:= NIL

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'UVIND16P', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABEÇALHO   ////////////////////////////

// Crio a Enchoice
oModel:AddFields( 'UJTMASTER', /*cOwner*/, oStruUJT )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "UJT_FILIAL" , "UJT_CODIGO" })    

// Preencho a descrição da entidade
oModel:GetModel('UJTMASTER'):SetDescription('Gateway')

///////////////////////////  ITENS  //////////////////////////////

// Crio o grid
oModel:AddGrid( 'UJUDETAIL', 'UJTMASTER', oStruUJU, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faz o relaciomaneto entre o cabeçalho e os itens
oModel:SetRelation( 'UJUDETAIL', { { 'UJU_FILIAL', 'xFilial( "UJU" )' } , { 'UJU_CODIGO', 'UJT_CODIGO' } } , UJU->(IndexKey(1)) )  

// Seta a propriedade de não obrigatoriedade do preenchimento do grid
oModel:GetModel('UJUDETAIL'):SetOptional( .T. ) 

// Preencho a descrição da entidade
oModel:GetModel('UJUDETAIL'):SetDescription('Bandeiras') 

Return(oModel)

/*###########################################################################
#############################################################################
## Programa  | ViewDef | Autor | Leandro Rodrigues     | Data | 25/11/2019 ##
##=========================================================================##
## Desc.     | Cria a camada de Visão									   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

Static Function ViewDef()

Local oStruUJT 	:= FWFormStruct(2,'UJT')
Local oStruUJU 	:= FWFormStruct(2,'UJU')
Local oModel   	:= FWLoadModel('UVIND16')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_UJT'	, oStruUJT, 'UJTMASTER') // cria o cabeçalho
oView:AddGrid('VIEW_UJU'	, oStruUJU, 'UJUDETAIL') // Cria o grid

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABECALHO' , 40)
oView:CreateHorizontalBox('PANEL_ITENS' 	, 60)

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_UJT' , 'PANEL_CABECALHO')
oView:SetOwnerView('VIEW_UJU' , 'PANEL_ITENS')

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_UJU')

// Habilita a quebra dos campos na Vertical
oView:SetViewProperty( 'UJTMASTER', "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 2 } ) 

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk({||.T.})

Return(oView)  

/*###########################################################################
#############################################################################
## Programa  | UVIND08L | Autor | Leandro Rodrigues    | Data | 25/11/2019 ##
##=========================================================================##
## Desc.     | Tela de Legenda do Browser								   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND16L()

BrwLegenda("Status Cadastro Gateway","Legenda",{ {"BR_VERDE","Ativo"},{"BR_VERMELHO","Inativo"} })

Return()                  