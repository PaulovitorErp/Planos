#Include "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RUTIL024
Cadastro de Tipo de Pet e Raça
@type function
@version 1.0 
@author g.sampaio
@since 01/07/2021
/*/
User Function RUTIL024()

	Local aCoors 		:= FWGetDialogSize( oMainWnd )
	Local cTitulo		:= "Tipo de Pet"
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local oPanelUp		:= Nil
	Local oPanelDown	:= Nil
	Local oFWLayer		:= Nil
	Local oBrowseUp		:= Nil
	Local oBrowseDown	:= Nil
	Local oRelacUZ2		:= Nil

	Private oDlgPrinc	:= Nil

	if lPlanoPet

		DEFINE MSDIALOG oDlgPrinc Title cTitulo  From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

		// Cria o conteiner onde serão colocados os browses
		oFWLayer := FWLayer():New()
		oFWLayer:Init( oDlgPrinc, .F., .T. )

		////////////////////////// PAINEL SUPERIOR /////////////////////////////
		// Cria uma "linha" com 40% da tela
		oFWLayer:AddLine( 'UP', 40, .F. )

		// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
		oFWLayer:AddCollumn( 'COLUN_UP', 100, .T., 'UP' )

		// Pego o objeto desse pedaço do container
		oPanelUp := oFWLayer:GetColPanel( 'COLUN_UP', 'UP' )

		////////////////////////// PAINEL CENTRAL /////////////////////////////
		// Cria uma "linha" com 2% da tela, apenas para dar um espaço entre os grids
		oFWLayer:AddLine( 'CENTER_LINE', 2, .F. )

		////////////////////////// PAINEL INFERIOR /////////////////////////////
		// Cria uma "linha" com 48% da tela
		oFWLayer:AddLine( 'DOWN', 58, .F. )

		// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
		oFWLayer:AddCollumn( 'COLUN_DOWN', 100, .T., 'DOWN' )

		oPanelDown := oFWLayer:GetColPanel( 'COLUN_DOWN' , 'DOWN' )

		////////////////////// MONTO O BROWSER DO Tipo de Pet ////////////////////////
		oBrowseUp := FWmBrowse():New()
		oBrowseUp :SetOwner( oPanelUp )

		// Atribuo o título do Browser
		oBrowseUp:SetDescription( "Tipo de Pet" )

		// Atribuo o nome da tabela
		oBrowseUp:SetAlias( 'UZ1' )

		// Habilito a visualização do Menu
		oBrowseUp:SetMenuDef( 'RUTIL024' )

		// Desabilito o detalhamento do browser
		oBrowseUp:DisableDetails()
		oBrowseUp:SetProfileID( '1' )
		oBrowseUp:ForceQuitButton()
		oBrowseUp:Activate()

		////////////////////// MONTO O BROWSER DE Raças ////////////////////////
		oBrowseDown := FWMBrowse():New()
		oBrowseDown :SetOwner( oPanelDown )

		// Atribuo o título do Browser
		oBrowseDown :SetDescription( 'Raças' )

		// Desabilito a visualização do Menu, pois o usuário não pode incluir um nicho individualmente
		oBrowseDown :SetMenuDef('')

		// Desabilito o detalhamento do browser
		oBrowseDown:DisableDetails()

		// Atribuo o nome da tabela
		oBrowseDown:SetAlias( 'UZ2' )
		oBrowseDown:SetProfileID( '2' )

		// adiciona legenda no Browser
		oBrowseDown:Activate()

		////////////////////// DEFINO O RELACIONAMENTO ENTRE OS BROWSER's ////////////////////////
		oRelacUZ2 := FWBrwRelation():New()
		oRelacUZ2:AddRelation( oBrowseUp , oBrowseDown , { { 'UZ2_FILIAL', 'xFilial( "UZ2" )' }, { 'UZ2_CODIGO' , 'UZ1_CODIGO' } } )
		oRelacUZ2:Activate()

		Activate MsDialog oDlgPrinc Center

	else
		Help(,,'Help - PLANOPET',,"Não é possível acessar está rotina, pois a gestão de Plano Pet está desabilitada em seu ambiente, procure o administrador do sistema." ,1,0)
	endIf

Return(Nil)

/*/{Protheus.doc} MenuDef
Função que cria os menus	
@type function
@version1.0 
@author Wellington Gonçalves
@since 19/02/2016
@return array, retorno as rotinas dos menus
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title 'Pesquisar'   	Action 'PesqBrw'          	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.RUTIL024' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.RUTIL024' 	OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.RUTIL024' 	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.RUTIL024' 	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.RUTIL024' 	OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Copiar'      	Action 'VIEWDEF.RUTIL024' 	OPERATION 09 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'     	Action 'U_UTIL024LEG()' 	OPERATION 10 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
unção que cria o objeto model
@type function
@version 1.0
@author g.sampaio
@since 01/07/2021
@return object, retorna o model do MVC
/*/
Static Function ModelDef()

	Local oStruUZ1 := FWFormStruct( 1, 'UZ1', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruUZ2 := FWFormStruct( 1, 'UZ2', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PUTIL024', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	/////////////////////////  CABEÇALHO - Tipo de Pet  ////////////////////////////
	// Crio a Enchoice com os campos do cadastro de crematorio
	oModel:AddFields( 'UZ1MASTER', /*cOwner*/, oStruUZ1 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "UZ1_FILIAL" , "UZ1_CODIGO" })

	// Preencho a descrição da entidade
	oModel:GetModel('UZ1MASTER'):SetDescription('Tipo de Pet:')

	///////////////////////////  ITENS - Raças  //////////////////////////////
	// Crio o grid de Raças
	oModel:AddGrid( 'UZ2DETAIL', 'UZ1MASTER', oStruUZ2, /*bLinePre*/{|oMdlG,nLine,cAcao,cCampo| EditGrid(oMdlG,nLine,cAcao,cCampo)}, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faço o relaciomaneto entre o nicho e o Tipo de Pet
	oModel:SetRelation( 'UZ2DETAIL', { { 'UZ2_FILIAL', 'xFilial( "UZ2" )' } , { 'UZ2_CODIGO', 'UZ1_CODIGO' } } , UZ2->(IndexKey(1)) )

	// Seto a propriedade de não obrigatoriedade do preenchimento do grid
	oModel:GetModel('UZ2DETAIL'):SetOptional( .T. )

	// Preencho a descrição da entidade
	oModel:GetModel('UZ2DETAIL'):SetDescription('Raças:')

Return(oModel)

/*/{Protheus.doc} ViewDef
Função que cria o objeto View
@type function
@version 1.0  
@author g.sampaio
@since 01/07/2021
@return object, retorno o objeto de view do MVC
/*/
Static Function ViewDef()

	Local oStruUZ1 	:= FWFormStruct(2,'UZ1')
	Local oStruUZ2 	:= FWFormStruct(2,'UZ2')
	Local oModel   	:= FWLoadModel('RUTIL024')
	Local oView

	// Remove campos da estrutura
	oStruUZ2:RemoveField("UZ2_FILIAL")
	oStruUZ2:RemoveField("UZ2_CODIGO")

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	oView:AddField('VIEW_UZ1'	, oStruUZ1, 'UZ1MASTER') // cria o cabeçalho - Tipo de Pet
	oView:AddGrid('VIEW_UZ2'	, oStruUZ2, 'UZ2DETAIL') // Cria o grid - Raças

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_PET'	, 20)
	oView:CreateHorizontalBox('PANEL_RACA'	, 80)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_UZ1' , 'PANEL_PET')
	oView:SetOwnerView('VIEW_UZ2' , 'PANEL_RACA')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_UZ1')
	oView:EnableTitleView('VIEW_UZ2')

	// Define campos que terao Auto Incremento
	oView:AddIncrementField( "VIEW_UZ2", "UZ2_ITEM" )

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

Return(oView)

/*/{Protheus.doc} EditGrid
Validacao da edicao da grid
@type function
@version 1.0
@author g.sampaio
@since 01/07/2021
@param oModelGrid, object, Model da Grid
@param nLinha, numeric, Linha posicionada na grid
@param cAcao, character, acao realizada na grid
@param cCampo, character, campo da grid
@return logical, retorno sobre a acao
/*/
Static Function EditGrid(oModelGrid,nLinha,cAcao,cCampo)

	Local lRetorno		:= .T.
	Local oModel		:= FWModelActive()
	Local oModelUZ1		:= oModel:GetModel("UZ1MASTER")

	if cAcao == 'DELETE'

	elseIf cAcao == "CANSETVALUE"

	endIf

Return(lRetorno)
