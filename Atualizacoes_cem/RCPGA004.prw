#Include "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RCPGA004
Rotina de cadastro de ossários.
 - Ossários >> Nichos	
@type function
@version 1.0
@author Wellington Gonçalves
@since 19/02/2016
/*/
User Function RCPGA004()

	Local aCoors 	:= FWGetDialogSize( oMainWnd )
	Local cTitulo	:= "Ossários"
	Local oPanelUp
	Local oPanelDown
	Local oFWLayer
	Local oBrowseUp
	Local oBrowseDown
	Local oRelacU12
	Private oDlgPrinc

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

	////////////////////// MONTO O BROWSER DO OSSÁRIO ////////////////////////
	oBrowseUp := FWmBrowse():New()
	oBrowseUp :SetOwner( oPanelUp )

	// Atribuo o título do Browser
	oBrowseUp:SetDescription( "Ossários" )

	// Atribuo o nome da tabela
	oBrowseUp:SetAlias( 'U13' )

	// Habilito a visualização do Menu
	oBrowseUp:SetMenuDef( 'RCPGA004' )

	// Desabilito o detalhamento do browser
	oBrowseUp:DisableDetails()
	oBrowseUp:SetProfileID( '1' )
	oBrowseUp:ForceQuitButton()

	// adiciona legenda no Browser
	oBrowseUp:AddLegend( "U13_STATUS == 'S'"	, "GREEN", "Ativo")
	oBrowseUp:AddLegend( "U13_STATUS == 'N'"	, "RED"  , "Inativo")
	oBrowseUp:Activate()

	////////////////////// MONTO O BROWSER DE NICHOS ////////////////////////
	oBrowseDown := FWMBrowse():New()
	oBrowseDown :SetOwner( oPanelDown )

	// Atribuo o título do Browser
	oBrowseDown :SetDescription( 'Nichos' )

	// Desabilito a visualização do Menu, pois o usuário não pode incluir um nicho individualmente
	oBrowseDown :SetMenuDef('')

	// Desabilito o detalhamento do browser
	oBrowseDown:DisableDetails()

	// Atribuo o nome da tabela
	oBrowseDown:SetAlias( 'U14' )
	oBrowseDown:SetProfileID( '2' )

	// adiciona legenda no Browser
	oBrowseDown:AddLegend( "U14_STATUS == 'S'"	, "GREEN", "Ativo")
	oBrowseDown:AddLegend( "U14_STATUS == 'N'"	, "RED"  , "Inativo")

	oBrowseDown:Activate()

	////////////////////// DEFINO O RELACIONAMENTO ENTRE OS BROWSER's ////////////////////////
	oRelacU12 := FWBrwRelation():New()
	oRelacU12:AddRelation( oBrowseUp , oBrowseDown , { { 'U14_FILIAL', 'xFilial( "U14" )' }, { 'U14_OSSARI' , 'U13_CODIGO' } } )
	oRelacU12:Activate()

	Activate MsDialog oDlgPrinc Center

Return NIL

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
	ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.RCPGA004' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.RCPGA004' 	OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.RCPGA004' 	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.RCPGA004' 	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.RCPGA004' 	OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Copiar'      	Action 'VIEWDEF.RCPGA004' 	OPERATION 09 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'     	Action 'U_CPGA004LEG()' 	OPERATION 10 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
unção que cria o objeto model
@type function
@version 1.0
@author Wellington Gonçalves
@since 19/02/2016
@return object, retorna o model do MVC
/*/
Static Function ModelDef()

	Local oStruU13 := FWFormStruct( 1, 'U13', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruU14 := FWFormStruct( 1, 'U14', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PCPGA004', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	/////////////////////////  CABEÇALHO - OSSÁRIO  ////////////////////////////
	// Crio a Enchoice com os campos do cadastro de crematorio
	oModel:AddFields( 'U13MASTER', /*cOwner*/, oStruU13 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "U13_FILIAL" , "U13_CODIGO" })

	// Preencho a descrição da entidade
	oModel:GetModel('U13MASTER'):SetDescription('Ossário:')

	///////////////////////////  ITENS - NICHOS  //////////////////////////////
	// Crio o grid de nichos
	oModel:AddGrid( 'U14DETAIL', 'U13MASTER', oStruU14, /*bLinePre*/{|oMdlG,nLine,cAcao,cCampo| EditGrid(oMdlG,nLine,cAcao,cCampo)}, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faço o relaciomaneto entre o nicho e o ossário
	oModel:SetRelation( 'U14DETAIL', { { 'U14_FILIAL', 'xFilial( "U14" )' } , { 'U14_OSSARI', 'U13_CODIGO' } } , U14->(IndexKey(1)) )

	// Seto a propriedade de não obrigatoriedade do preenchimento do grid
	oModel:GetModel('U14DETAIL'):SetOptional( .T. )

	// Preencho a descrição da entidade
	oModel:GetModel('U14DETAIL'):SetDescription('Nichos:')

	// Não permitir duplicar o código do nicho
	oModel:GetModel('U14DETAIL'):SetUniqueLine( {'U14_CODIGO'} )

	// Aumento a quantidade de linhas
	oModel:GetModel('U14DETAIL'):SetMaxLine(9999)

Return(oModel)

/*/{Protheus.doc} ViewDef
Função que cria o objeto View
@type function
@version 1.0  
@author Wellington Gonçalves
@since 19/02/2016
@return object, retorno o objeto de view do MVC
/*/
Static Function ViewDef()

	Local oStruU13 	:= FWFormStruct(2,'U13')
	Local oStruU14 	:= FWFormStruct(2,'U14')
	Local oModel   	:= FWLoadModel('RCPGA004')
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	oView:AddField('VIEW_U13'	, oStruU13, 'U13MASTER') // cria o cabeçalho - Ossário
	oView:AddGrid('VIEW_U14'	, oStruU14, 'U14DETAIL') // Cria o grid - Nichos

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_OSSARIO'	 , 20)
	oView:CreateHorizontalBox('PANEL_NICHO'		 , 80)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_U13' , 'PANEL_OSSARIO')
	oView:SetOwnerView('VIEW_U14' , 'PANEL_NICHO')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_U13')
	oView:EnableTitleView('VIEW_U14')

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

Return(oView)

/*/{Protheus.doc} CPGA004LEG
Legenda do browser de cadastro de ossário
@type function
@version 1.0  
@author g.sampaio
@since 19/02/2016
/*/
User Function CPGA004LEG()

	BrwLegenda("Status do Ossário","Legenda",{ {"BR_VERDE","Ativo"},{"BR_VERMELHO","Inativo"} })

Return(Nil)

/*/{Protheus.doc} CPGA004WHEN
Validacao do Modo de Edicao
do Campo U13_TPOSS
@type function
@version 1.0
@author g.sampaio
@since 12/04/2021
@return loigcal, retorna se o campo é editavel
/*/

User Function CPGA004WHEN()

	Local lRetorno      := .T.
	Local lAtivJazOssi  := SuperGetMV("MV_XJAZOSS",,.F.)

	// veririfico se posso alterar o conteudo do ossuario
	if lAtivJazOssi
		lRetorno := Empty(FwFldGet("U13_QUADRA"))
	endIf

Return(lRetorno)

/*/{Protheus.doc} EditGrid
Validacao da edicao da grid
@type function
@version 1.0
@author g.sampaio
@since 13/04/2021
@param oModelGrid, object, Model da Grid
@param nLinha, numeric, Linha posicionada na grid
@param cAcao, character, acao realizada na grid
@param cCampo, character, campo da grid
@return logical, retorno sobre a acao
/*/
Static Function EditGrid(oModelGrid,nLinha,cAcao,cCampo)

	Local lRetorno		:= .T.
	Local lAtivJazOssi  := SuperGetMV("MV_XJAZOSS",,.F.)
	Local oModel		:= FWModelActive()
	Local oModelU13		:= oModel:GetModel("U13MASTER")

	if lAtivJazOssi

		if cAcao == 'DELETE'

			if !Empty(oModelU13:GetValue("U13_QUADRA"))
				lRetorno := .F.
				Help(,,'Help',,"Ossuario possui Jazigo vinculado, a exlusão não pode ser realizada!",1,0)
			endIf

		elseIf cAcao == "CANSETVALUE"

			if !Empty(oModelU13:GetValue("U13_QUADRA"))
				lRetorno := .F.
				Help(,,'Help',,"Ossuario possui Jazigo vinculado, a alteração não pode ser realizada!",1,0)
			endIf

		endIf

	endIf

Return(lRetorno)
