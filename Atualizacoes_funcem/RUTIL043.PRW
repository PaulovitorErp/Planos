#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTIL043
Historico de Faturamento em Lote
@type function
@version 1.0
@author Raphael Martins
@since 20/09/2022
/*/
User Function RUTIL043
    Local oBrowse	:= {}

    // crio o objeto do Browser
    oBrowse := FWmBrowse():New()

    // defino o Alias
    oBrowse:SetAlias("UZP")

    // informo a descrição
    oBrowse:SetDescription("Historico de Faturamento Lote")

    // crio as legendas 
    oBrowse:AddLegend("UZP_STATUS == 'I'", "ORANGE"	,	"Iniciado")
    oBrowse:AddLegend("UZP_STATUS == 'F'", "GREEN"	,	"Finalizado")
    oBrowse:AddLegend("UZP_STATUS == 'E'", "RED"	,	"Erro")
    
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
	ADD OPTION aRotina Title 'Visualizar'  						Action 'VIEWDEF.RUTIL043' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'     						Action 'VIEWDEF.RUTIL043' 	OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'     						Action 'VIEWDEF.RUTIL043' 	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     						Action 'VIEWDEF.RUTIL043' 	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    						Action 'VIEWDEF.RUTIL043' 	OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'     						Action 'U_RUTIL43LEG()' 	OPERATION 10 ACCESS 0
    

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
    Local oStruUZP 	:= FWFormStruct( 1, 'UZP', /*bAvalCampo*/, /*lViewUsado*/ )

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New( 'PRUTIL043', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

    // Crio a Enchoice
    oModel:AddFields( 'UZPMASTER', /*cOwner*/, oStruUZP )

    // Adiciona a chave primaria da tabela principal
    oModel:SetPrimaryKey({ 'UZP_FILIAL' , 'UZP_CODIGO' })

    // Preencho a descrição da entidade
    oModel:GetModel('UZPMASTER'):SetDescription('Dados da Parametrização')

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
    Local oStruUZP := FWFormStruct(2,'UZP')
    Local oModel := FWLoadModel('RUTIL043')
    Local oView

    // Cria o objeto de View
    oView := FWFormView():New()

    // Define qual o Modelo de dados será utilizado
    oView:SetModel(oModel)

    // cria o cabeçalho
    oView:AddField('VIEW_UZP', oStruUZP, 'UZPMASTER')

    // Crio os Panel's horizontais 
    oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

    // Relaciona o ID da View com os panel's
    oView:SetOwnerView('VIEW_UZP' , 'PANEL_CABECALHO')

    // Ligo a identificacao do componente
    oView:EnableTitleView('VIEW_UZP')

    // Habilita a quebra dos campos na Vertical
    oView:SetViewProperty( 'UZPMASTER', 'SETLAYOUT', { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

    // Define fechamento da tela ao confirmar a operação
    oView:SetCloseOnOk({||.T.})

Return oView


User Function RUTIL43LEG()

	BrwLegenda("Status","Legenda",{{"BR_LARANJA","Iniciado"},{"BR_VERDE","Finalizado"},{"BR_VERMELHO","Erro"}})

Return(Nil)
