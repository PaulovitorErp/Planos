#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTIL028
Browse de sincronizacao da API do Cliente
@type function
@version 1.0
@author g.sampaio
@since 26/09/2021
@return variant, return_description
/*/
User Function RUTIL028()
	Local oBrowse	:= {}

	// crio o objeto do Browser
	oBrowse := FWmBrowse():New()

	// defino o Alias
	oBrowse:SetAlias("UZ3")

	// informo a descrição
	oBrowse:SetDescription("Sincronização API do Cliente")

	// crio as legendas
	oBrowse:AddLegend("UZ3_STATUS == '1'", "GREEN"	,	"Pendente")
	oBrowse:AddLegend("UZ3_STATUS == '3'", "RED"	,	"Concluído")
	oBrowse:AddLegend("UZ3_STATUS == '2'", "BLACK"	,	"Erro")

	// ativo o browser
	oBrowse:Activate()

Return(nIL)

/*/{Protheus.doc} MenuDef
Cria os Menus da Rotina
@type function
@version 1.0
@author g.sampaio
@since 26/09/2021
@return array, aRotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Pesquisar'                    Action 'PesqBrw'            OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'                   Action 'VIEWDEF.RUTIL028'   OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'                     Action 'VIEWDEF.RUTIL028'   OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Proc. Carga Diferencial'      Action 'U_RUTILE57()'       OPERATION 11 ACCESS 0
	ADD OPTION aRotina Title 'Proc. Carga Tit. Vencidos'    Action 'U_RUTILE58()'       OPERATION 11 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Cria o Modelo de Dados
@type function
@version 1.0
@author g.sampaio
@since 26/09/2021
@return object, oModel
/*/
Static Function ModelDef()
	Local oStruUZ3 	:= FWFormStruct( 1, 'UZ3', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel	:= NIL

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PRUTIL028', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Crio a Enchoice
	oModel:AddFields( 'UZ3MASTER', /*cOwner*/, oStruUZ3 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ 'UZ3_FILIAL' , 'UZ3_CODIGO' })

	// Preencho a descrição da entidade
	oModel:GetModel('UZ3MASTER'):SetDescription('Dados Integração')

Return(oModel)

/*/{Protheus.doc} ViewDef
Cria a camada de Visão
@type function
@version 1.0
@author g.sampaio
@since 26/09/2021
@return object, oView
/*/
Static Function ViewDef()
	Local oStruUZ3 	:= FWFormStruct(2,'UZ3')
	Local oModel 	:= FWLoadModel('RUTIL028')
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	// cria o cabeçalho
	oView:AddField('VIEW_UZ3', oStruUZ3, 'UZ3MASTER')

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_UZ3' , 'PANEL_CABECALHO')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_UZ3')

	// Habilita a quebra dos campos na Vertical
	oView:SetViewProperty( 'UZ3MASTER', 'SETLAYOUT', { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

Return oView
