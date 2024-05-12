#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTIL029
Browse de sincronizacao da API do Cliente
@type function
@version 1.0
@author g.sampaio
@since 08/12/2021
/*/
User Function RUTIL029()
	Local oBrowse	:= {}

	// crio o objeto do Browser
	oBrowse := FWmBrowse():New()

	// defino o Alias
	oBrowse:SetAlias("UZD")

	// informo a descrição
	oBrowse:SetDescription("Cadastro de WACC")

	// ativo o browser
	oBrowse:Activate()

Return(nIL)

/*/{Protheus.doc} MenuDef
Cria os Menus da Rotina
@type function
@version 1.0
@author g.sampaio
@since 08/12/2021
@return array, aRotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Pesquisar'                    Action 'PesqBrw'            OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title "Incluir"    					Action "VIEWDEF.RUTIL029"	OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title "Alterar"    					Action "VIEWDEF.RUTIL029"	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title "Excluir"    					Action "VIEWDEF.RUTIL029"	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'                   Action 'VIEWDEF.RUTIL029'   OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'                     Action 'VIEWDEF.RUTIL029'   OPERATION 08 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
Cria o Modelo de Dados
@type function
@version 1.0
@author g.sampaio
@since 08/12/2021
@return object, oModel
/*/
Static Function ModelDef()
	Local oStruUZD 	:= FWFormStruct( 1, 'UZD', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel	:= NIL

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PUTIL029', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Crio a Enchoice
	oModel:AddFields( 'UZDMASTER', /*cOwner*/, oStruUZD )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ 'UZD_FILIAL' , 'UZD_CODIGO' })

	// Preencho a descrição da entidade
	oModel:GetModel('UZDMASTER'):SetDescription('Cadastro WACC')

Return(oModel)

/*/{Protheus.doc} ViewDef
Cria a camada de Visão
@type function
@version 1.0
@author g.sampaio
@since 08/12/2021
@return object, oView
/*/
Static Function ViewDef()
	Local oStruUZD 	:= FWFormStruct(2,'UZD')
	Local oModel 	:= FWLoadModel('RUTIL029')
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	// cria o cabeçalho
	oView:AddField('VIEW_UZD', oStruUZD, 'UZDMASTER')

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_UZD' , 'PANEL_CABECALHO')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_UZD')

	// Habilita a quebra dos campos na Vertical
	oView:SetViewProperty( 'UZDMASTER', 'SETLAYOUT', { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

Return(oView)
