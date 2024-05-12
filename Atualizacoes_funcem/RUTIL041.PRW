#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTIL041
Browse de Cadastro de Faturamento em Lote
@type function
@version 1.0
@author Raphael Martins
@since 20/09/2022
/*/
User Function RUTIL041
    Local oBrowse	:= {}

    // crio o objeto do Browser
    oBrowse := FWmBrowse():New()

    // defino o Alias
    oBrowse:SetAlias("UZO")

    // informo a descrição
    oBrowse:SetDescription("Cadastro de Parametros de Faturamento Lote")

    // crio as legendas 
    oBrowse:AddLegend("UZO_STATUS == 'A'", "GREEN"	,	"Ativo")
    oBrowse:AddLegend("UZO_STATUS == 'I'", "RED"	,	"Inativo")
    
    // ativo o browser
    oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Cria os Menus da Rotina
@type function
@version 1.0
@author Raphael Martins 
@since 20/09/2022
@return array, aRotina
/*/
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina Title 'Pesquisar'   						Action 'PesqBrw'          	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  						Action 'VIEWDEF.RUTIL041' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'     						Action 'VIEWDEF.RUTIL041' 	OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'     						Action 'VIEWDEF.RUTIL041' 	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     						Action 'VIEWDEF.RUTIL041' 	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    						Action 'VIEWDEF.RUTIL041' 	OPERATION 08 ACCESS 0
    ADD OPTION aRotina Title 'Copiar'      	                    Action 'VIEWDEF.RUTIL041' 	OPERATION 09 ACCESS 0  
	ADD OPTION aRotina Title 'Legenda'     						Action 'U_RUTIL41LEG()' 	OPERATION 10 ACCESS 0
    ADD OPTION aRotina Title 'Executar Faturamento'				Action 'U_RUTILE66' 	    OPERATION 11 ACCESS 0


Return aRotina

/*/{Protheus.doc} ModelDef
Cria o Modelo de Dados
@type function
@version 1.0
@author Raphael Martins 
@since 20/09/2022
@return object, oModel
/*/
Static Function ModelDef()
    
    Local oModel	:= NIL
    Local oStruUZO 	:= FWFormStruct( 1, 'UZO', /*bAvalCampo*/, /*lViewUsado*/ )

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New( 'PUTIL041', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

    // Crio a Enchoice
    oModel:AddFields( 'UZOMASTER', /*cOwner*/, oStruUZO )

    // Adiciona a chave primaria da tabela principal
    oModel:SetPrimaryKey({ 'UZO_FILIAL' , 'UZO_CODIGO' })

    // Preencho a descrição da entidade
    oModel:GetModel('UZOMASTER'):SetDescription('Dados da Parametrização')

Return oModel

/*/{Protheus.doc} ViewDef
Cria a camada de Visão
@type function
@version 1.0
@author Raphael Martins 
@since 20/09/2022
@return object, oView
/*/
Static Function ViewDef()
    Local oStruUZO := FWFormStruct(2,'UZO')
    Local oModel := FWLoadModel('RUTIL041')
    Local oView

    // Cria o objeto de View
    oView := FWFormView():New()

    // Define qual o Modelo de dados será utilizado
    oView:SetModel(oModel)

    // cria o cabeçalho
    oView:AddField('VIEW_UZO', oStruUZO, 'UZOMASTER')

    // Crio os Panel's horizontais 
    oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

    // Relaciona o ID da View com os panel's
    oView:SetOwnerView('VIEW_UZO' , 'PANEL_CABECALHO')

    // Ligo a identificacao do componente
    oView:EnableTitleView('VIEW_UZO')

    // Habilita a quebra dos campos na Vertical
    oView:SetViewProperty( 'UZOMASTER', 'SETLAYOUT', { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

    // Define fechamento da tela ao confirmar a operação
    oView:SetCloseOnOk({||.T.})

Return oView


User Function RUTIL41LEG()

	BrwLegenda("Status","Legenda",{{"BR_VERDE","Ativo"},{"BR_VERMELHO","Inativo"}})

Return(Nil)
