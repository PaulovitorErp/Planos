#Include "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RCPGA002
Rotina de cadastro de jazigos.
- Quadras >> Módulos >> Jazigos  
@type function
@version 1.0  
@author Wellington Gonçalves
@since 18/02/2016
/*/
User Function RCPGA002()

	Local aCoors 		:= FWGetDialogSize( oMainWnd )
	Local cTitulo		:= "Jazigo"
	Local lVincJazOss	:= SuperGetMV("MV_XJAZOSS", .F., .F.)
	Local oPanelUp
	Local oFWLayer
	Local oPanelLeft
	Local oPanelRight
	Local oBrowseUp
	Local oBrowseLeft
	Local oBrowseRight
	Local oRelacU09
	Local oRelacU10
	Private oDlgPrinc

	DEFINE MSDIALOG oDlgPrinc Title cTitulo  From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel Style DS_MODALFRAME

	// Cria o conteiner onde serão colocados os browses
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )

	////////////////////////// PAINEL SUPERIOR /////////////////////////////
	// Cria uma "linha" com 50% da tela
	oFWLayer:AddLine( 'UP', 50, .F. )

	// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )

	// Pego o objeto desse pedaço do container
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )

	////////////////////////// PAINEL CENTRAL /////////////////////////////
	// Cria uma "linha" com 2% da tela, apenas para dar um espaço entre os grids
	oFWLayer:AddLine( 'CENTER_LINE', 2, .F. )

	////////////////////////// PAINEL INFERIOR /////////////////////////////
	// Cria uma "linha" com 48% da tela
	oFWLayer:AddLine( 'DOWN', 48, .F. )

	// Na "linha" criada eu crio uma coluna com 49% da tamanho dela
	oFWLayer:AddCollumn( 'LEFT' , 49, .T., 'DOWN' )

	// Na "linha" criada eu crio uma coluna com 2% da tamanho dela, apenas para criar uma coluna separadora
	oFWLayer:AddCollumn( 'CENTER_COLUN', 2, .T., 'DOWN' )

	// Na "linha" criada eu crio uma coluna com 49% da tamanho dela
	oFWLayer:AddCollumn( 'RIGHT', 49, .T., 'DOWN' )

	// Pego o objeto do pedaço esquerdo
	oPanelLeft := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' )

	// Pego o objeto do pedaço direito
	oPanelRight := oFWLayer:GetColPanel( 'RIGHT', 'DOWN' )

	////////////////////// MONTO O BROWSER DE QUADRAS ////////////////////////
	oBrowseUp := FWmBrowse():New()
	oBrowseUp :SetOwner( oPanelUp )

	// Atribuo o título do Browser
	oBrowseUp:SetDescription( "Quadras" )

	// Atribuo o nome da tabela
	oBrowseUp:SetAlias( 'U08' )

	// Habilito a visualização do Menu
	oBrowseUp:SetMenuDef( 'RCPGA002' )

	// Desabilito o detalhamento do browser
	oBrowseUp:DisableDetails()

	oBrowseUp:SetProfileID( '1' )
	oBrowseUp:ForceQuitButton()

	// adiciona legenda no Browser
	if lVincJazOss
		oBrowseUp:AddLegend( "U08_STATUS == 'S' .And. !Empty(U08_VINOSS)"	, "YELLOW", "Ativa com Ossuario Vinculado")
	endIf

	oBrowseUp:AddLegend( "U08_STATUS == 'S'"	, "GREEN", "Ativa")
	oBrowseUp:AddLegend( "U08_STATUS == 'N'"	, "RED"  , "Inativa")

	oBrowseUp:Activate()

	////////////////////// MONTO O BROWSER DE MODULOS ////////////////////////

	oBrowseLeft := FWMBrowse():New()
	oBrowseLeft :SetOwner( oPanelLeft )

	// Atribuo o título do Browser
	oBrowseLeft :SetDescription( 'Módulos' )

	// Desabilito a visualização do Menu, pois o usuário não pode incluir um módulo individualmente
	oBrowseLeft :SetMenuDef('')

	// Desabilito o detalhamento do browser
	oBrowseLeft:DisableDetails()

	// Atribuo o nome da tabela
	oBrowseLeft:SetAlias( 'U09' )

	oBrowseLeft:SetProfileID( '2' )

	// adiciona legenda no Browser
	if lVincJazOss
		oBrowseLeft:AddLegend( "U09_STATUS == 'S' .And. !Empty(U09_VINOSS)"	, "YELLOW", "Ativo com Ossuario Vinculado")
	endIf

	oBrowseLeft:AddLegend( "U09_STATUS == 'S'"	, "GREEN", "Ativo")
	oBrowseLeft:AddLegend( "U09_STATUS == 'N'"	, "RED"  , "Inativo")

	oBrowseLeft:Activate()

	////////////////////// MONTO O BROWSER DE JAZIGOS ////////////////////////

	oBrowseRight:= FWMBrowse():New()
	oBrowseRight:SetOwner( oPanelRight )

	// Atribuo o título do Browser
	oBrowseRight:SetDescription( 'Jazigos' )

	// Desabilito a visualização do Menu, pois o usuário não pode incluir um jazigo individualmente
	oBrowseRight:SetMenuDef( '' )

	// Desabilito o detalhamento do browser
	oBrowseRight:DisableDetails()

	// Atribuo o nome da tabela
	oBrowseRight:SetAlias( 'U10' )

	oBrowseRight:SetProfileID( '3' )

	// adiciona legenda no Browser
	if lVincJazOss
		oBrowseRight:AddLegend( "U10_STATUS == 'S' .And. !Empty(U10_VINOSS)"	, "YELLOW", "Ativo com Ossuario Vinculado")
	endIf

	oBrowseRight:AddLegend( "U10_STATUS == 'S'"	, "GREEN", "Ativo")
	oBrowseRight:AddLegend( "U10_STATUS == 'N'"	, "RED"  , "Inativo")

	oBrowseRight:Activate()

	////////////////////// DEFINO O RELACIONAMENTO ENTRE OS BROWSER's ////////////////////////

	oRelacU09:= FWBrwRelation():New()
	oRelacU09:AddRelation( oBrowseUp , oBrowseLeft , { { 'U09_FILIAL', 'U08_FILIAL' }, { 'U09_QUADRA' , 'U08_CODIGO' } } )
	oRelacU09:Activate()

	oRelacU10:= FWBrwRelation():New()
	oRelacU10:AddRelation( oBrowseLeft, oBrowseRight, { { 'U10_FILIAL', 'U09_FILIAL' }, { 'U10_QUADRA' , 'U09_QUADRA' }, { 'U10_MODULO', 'U09_CODIGO' } } )
	oRelacU10:Activate()

	Activate MsDialog oDlgPrinc Center

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

	Local aRotina 			:= {}
	Local aMenuMapa 		:= {}
	Local lJazigoOssuario 	:= SuperGetMV("MV_XJAZOSS",.F.,.F.)

	aadd(aMenuMapa , {"Visualizar Mapa"	,"U_RCPGA007()", 0, 13})
	aadd(aMenuMapa , {"Coordenadas da Quadra",	'U_RCPGA009("U08",GetMv("MV_XMAPA"),{"U08_COORD1","U08_COORD2","U08_COORD3","U08_COORD4","U08_COORD5","U08_COORD6","U08_COORD7","U08_COORD8"} )', 0, 14})
	aadd(aMenuMapa , {"Coordenadas do Módulo",	'U_RCPGA009("U09",AllTrim(U08->U08_IMAGEM),{"U09_COORD1","U09_COORD2","U09_COORD3","U09_COORD4","U09_COORD5","U09_COORD6","U09_COORD7","U09_COORD8"} )', 0, 15})

	ADD OPTION aRotina Title 'Pesquisar'   					Action 'PesqBrw'          	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  					Action 'VIEWDEF.RCPGA002' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'     					Action 'VIEWDEF.RCPGA002' 	OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'     					Action 'VIEWDEF.RCPGA002' 	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     					Action 'VIEWDEF.RCPGA002' 	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    					Action 'VIEWDEF.RCPGA002' 	OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'     					Action 'U_CPGA002LEG()' 	OPERATION 10 ACCESS 0
	ADD OPTION aRotina Title 'Geração de Jazigos em Lote'   Action 'U_RCPGA005()' 		OPERATION 11 ACCESS 0
	ADD OPTION aRotina Title 'Mapa'				  			Action aMenuMapa	 		OPERATION 12 ACCESS 0

	if lJazigoOssuario
		ADD OPTION aRotina Title 'Geração de Ossuários em Lote'   Action 'U_RCPGE066()' 	OPERATION 13 ACCESS 0
	endIF

Return(aRotina)

/*/{Protheus.doc} ModelDef
função que cria o objeto model
@type function
@version 1.0
@author Wellington Gonçalves
@since 19/02/2016
@return object, retorna o model do MVC
/*/
Static Function ModelDef()

	Local oStruU08 := FWFormStruct( 1, 'U08', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruU09 := FWFormStruct( 1, 'U09', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruU10 := FWFormStruct( 1, 'U10', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PCPGA002', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	/////////////////////////  CABEÇALHO - QUADRAS  ////////////////////////////

	// Crio a Enchoice com os campos do cadastro de quadras
	oModel:AddFields( 'U08MASTER', /*cOwner*/, oStruU08 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "U08_FILIAL" , "U08_CODIGO" })

	// Preencho a descrição da entidade
	oModel:GetModel('U08MASTER'):SetDescription('Quadra:')

	///////////////////////////  ITENS - MODULOS  //////////////////////////////

	// Crio o grid de modulos
	oModel:AddGrid( 'U09DETAIL', 'U08MASTER', oStruU09, /*bLinePre*/{|oMdlG,nLine,cAcao,cCampo| EditGrid(oMdlG,nLine,cAcao,cCampo)}, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faço o relaciomaneto entre o modulo e a quadra
	oModel:SetRelation( 'U09DETAIL', { { 'U09_FILIAL', 'xFilial( "U09" )' } , { 'U09_QUADRA', 'U08_CODIGO' } } , U09->(IndexKey(1)) )

	// Seto a propriedade de não obrigatoriedade do preenchimento do grid
	oModel:GetModel('U09DETAIL'):SetOptional( .T. )

	// Preencho a descrição da entidade
	oModel:GetModel('U09DETAIL'):SetDescription('Módulos:')

	// Não permitir duplicar o código do módulo
	oModel:GetModel('U09DETAIL'):SetUniqueLine( {'U09_CODIGO'} )

	///////////////////////////  ITENS - JAZIGOS  //////////////////////////////

	// Crio o grid de jazigos
	oModel:AddGrid('U10DETAIL', 'U09DETAIL', oStruU10, /*bLinePre*/{|oMdlG,nLine,cAcao,cCampo| EditGrid(oMdlG,nLine,cAcao,cCampo)}, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)

	// Faço o relaciomaneto entre o jazigo e o modulo
	oModel:SetRelation('U10DETAIL', { { 'U10_FILIAL', 'xFilial( "U10" )' } , { 'U10_QUADRA', 'U08_CODIGO' } , { 'U10_MODULO', 'U09_CODIGO' } } , U10->(IndexKey(1)))

	// Seto a propriedade de não obrigatoriedade do preenchimento do grid
	oModel:GetModel('U10DETAIL'):SetOptional(.T.)

	// Preencho a descrição da entidade
	oModel:GetModel('U10DETAIL'):SetDescription('Jazigos:')

	// Não permitir duplicar o código do jazigo
	oModel:GetModel('U10DETAIL'):SetUniqueLine( {'U10_CODIGO'} )

	// Aumento a quantidade de linhas
	oModel:GetModel('U10DETAIL'):SetMaxLine(9999)

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

	Local oStruU08 	:= FWFormStruct(2,'U08')
	Local oStruU09 	:= FWFormStruct(2,'U09')
	Local oStruU10 	:= FWFormStruct(2,'U10')
	Local oModel   	:= FWLoadModel('RCPGA002')
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	oView:AddField('VIEW_U08'	, oStruU08, 'U08MASTER') // cria o cabeçalho - Quadra
	oView:AddGrid('VIEW_U09'	, oStruU09, 'U09DETAIL') // Cria o grid - Modulos
	oView:AddGrid('VIEW_U10'	, oStruU10, 'U10DETAIL') // Cria o grid - Jazigos

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_QUADRA' , 30)
	oView:CreateHorizontalBox('PANEL_MODULO' , 35)
	oView:CreateHorizontalBox('PANEL_JAZIGO' , 35)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_U08' , 'PANEL_QUADRA')
	oView:SetOwnerView('VIEW_U09' , 'PANEL_MODULO')
	oView:SetOwnerView('VIEW_U10' , 'PANEL_JAZIGO')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_U08')
	oView:EnableTitleView('VIEW_U09')
	oView:EnableTitleView('VIEW_U10')

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

Return(oView)

/*/{Protheus.doc} CPGA002LEG
Legenda do browser de cadastro de quadras
@type function
@version 1.0
@author Wellington Gonçalves
@since 13/04/2021
/*/
User Function CPGA002LEG()

	BrwLegenda("Status da Quadra","Legenda",{ {"BR_VERDE","Ativa"},{"BR_VERMELHO","Inativa"},{"BR_AMARELO","Ativo com Ossuario Vinculado"} })

Return(Nil)

/*/{Protheus.doc} CPGA002A
Função chamada na validação do campo U08_STATUS do cadastro de
quadras. Está sendo utilizado para desativar os módulos e jazigos
caso a quadra seja desativada.
@type function
@version 1.0
@author Wellington Gonçalves
@since 24/02/2016
@return logical, retorno sobre o status da quadra
/*/
User Function CPGA002A()

	Local aArea		:= GetArea()
	Local lRet 		:= .T.
	Local oModel	:= FWModelActive()
	Local oView		:= FWViewActive()
	Local oModelU08 := oModel:GetModel('U08MASTER')
	Local oModelU09 := oModel:GetModel('U09DETAIL')
	Local oModelU10	:= oModel:GetModel('U10DETAIL')
	Local aSaveLine := FWSaveRows()
	Local nX		:= 1
	Local nY		:= 1
	Local cMensagem	:= ""

	// Para a ativação da quadra, o sistema irá perguntar se o usuário deseja ativar todos os módulos e jazigos.
	// Caso não queira, apenas a quadra será ativada.
	// Para a desativação da quadra, o sistema irá perguntar se o usuário deseja desativar todos os módulos e jazigos.
	// Caso não queira, não será possível desativar a quadra.

	if M->U08_STATUS == "S" // ativação
		cMensagem := "Deseja ativar todos os Módulos e Jazigos?"
	else
		cMensagem := "Deseja desativar a Quadra? Todos os seus Módulos e Jazigos serão desativados!"
	endif

	if MsgYesNo(cMensagem)

		// atualizo o grid de módulos
		For nX := 1 To oModelU09:Length()

			// posiciono na linha atual
			oModelU09:Goline(nX)

			// se a linha não estiver em branco
			if !Empty(oModelU09:GetValue("U09_CODIGO"))
				oModelU09:LoadValue("U09_STATUS", M->U08_STATUS)
			endif

			// atualizo o grid de jazigos
			For nY := 1 To oModelU10:Length()

				// posiciono na linha atual
				oModelU10:Goline(nY)

				// se a linha não estiver em branco
				if !Empty(oModelU10:GetValue("U10_CODIGO"))
					oModelU10:LoadValue("U10_STATUS", M->U08_STATUS)
				endif

			Next nY

		Next nX

		// posiciono na primeira linha do grid de módulos
		oModelU09:Goline(1)

		// posiciono na primeira linha do grid de jazigos
		oModelU10:Goline(1)

		// atualizo a tela
		oView:Refresh()

	else

		// se for desativação da quadra e o usuário não optou por desativar os módulos e jazigos, não pode continuar a operação.
		if M->U08_STATUS == "N"
			lRet := .F.
			Help(,,'Help',,"Para desativar a Quadra é necessário desativar os Módulos e Jazigos!",1,0)
		endif

	endif

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} CPGA002B
Função chamada na validação do campo U09_STATUS do cadastro de
módulos. Está sendo utilizado para desativar os jazigos caso o
módulo seja desativado.
@type function
@version 1.0
@author Wellington Gonçalves
@since 24/02/2016
@return logical, retorno sobre status do modulo
/*/
User Function CPGA002B()

	Local aArea		:= GetArea()
	Local lRet 		:= .T.
	Local oModel	:= FWModelActive()
	Local oView		:= FWViewActive()
	Local oModelU08 := oModel:GetModel('U08MASTER')
	Local oModelU09 := oModel:GetModel('U09DETAIL')
	Local oModelU10	:= oModel:GetModel('U10DETAIL')
	Local aSaveLine := FWSaveRows()
	Local nX		:= 1
	Local nY		:= 1
	Local cMensagem	:= ""

	// será permitido ativar o módulo apenas se a quadra estiver ativa
	if oModelU08:GetValue("U08_STATUS") == "N"
		Help(,,'Help',,"Não é possível ativar o Módulo se a Quadra estiver desativada!",1,0)
		lRet := .F.
	else

		// Para a ativacão do módulo, o sistema irá perguntar se o usuário deseja ativar os jazigos.
		// Caso não queira, apenas o módulo será ativado.
		// Para a desativação do módulo, o sistema irá perguntar se o usuário deseja desativar os jazigos.
		// Caso não queira, não será possível desativar o módulo.

		if M->U09_STATUS == "S" // ativação
			cMensagem := "Deseja ativar os Jazigos?"
		else
			cMensagem := "Deseja desativar o Módulo? Todos os seus Jazigos serão desativados!"
		endif

		if MsgYesNo(cMensagem)

			// atualizo o grid de jazigos
			For nY := 1 To oModelU10:Length()

				// posiciono na linha atual
				oModelU10:Goline(nY)

				// se a linha não estiver em branco
				if !Empty(oModelU10:GetValue("U10_CODIGO"))
					oModelU10:LoadValue("U10_STATUS", M->U09_STATUS)
				endif

			Next nY

			// posiciono na primeira linha do grid de jazigos
			oModelU10:Goline(1)

			// atualizo a tela
			oView:Refresh()

		else

			// se for desativação da quadra e o usuário não optou por desativar os módulos e jazigos, não pode continuar a operação.
			if M->U09_STATUS == "N"
				Help(,,'Help',,"Para desativar o Módulo é necessário desativar os Jazigos!",1,0)
				lRet := .F.
			endif

		endif

	endif

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} CPGA002C
Função chamada na validação do campo U10_STATUS do cadastro de
jazigos. Está sendo utilizado para não permitir ativar o jazigo
se o módulo estiver desativado. 	
@type function
@version 1.0 
@author g.sampaio
@since 13/04/2021
@return logical, retorno sobre o status do jazigo
/*/
User Function CPGA002C()

	Local aArea		:= GetArea()
	Local lRet 		:= .T.
	Local oModel	:= FWModelActive()
	Local oView		:= FWViewActive()
	Local oModelU09 := oModel:GetModel('U09DETAIL')

	// será permitido ativar o jazigo apenas se o módulo estiver ativo
	if oModelU09:GetValue("U09_STATUS") == "N"
		Help(,,'Help',,"Não é possível ativar o Jazigo se o Módulo estiver desativado!",1,0)
		lRet := .F.
	endif

	RestArea(aArea)

Return(lRet)

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

	Local cQuadra		:= ""
	Local cModulo		:= ""
	Local cJazigo		:= ""
	Local cDescricao	:= ""
	Local lRetorno		:= .T.
	Local oOssVinc		:= Nil

	If oModelGrid:cId == "U09DETAIL" // grid modulos

		cQuadra 	:= oModelGrid:GetValue("U09_QUADRA")
		cModulo		:= oModelGrid:GetValue("U09_CODIGO")
		cDescricao	:= oModelGrid:GetValue("U09_DESC")

		if cAcao == 'DELETE' // exclusao

			if !Empty(cQuadra) .And. !Empty(cModulo)

				if U09->(FieldPos("U09_VINOSS")) > 0

					oOssVinc := OssuarioVinculado():New(.F.)
					if !oOssVinc:OssuarioUsado(cQuadra, cModulo)
						lRetorno := .F.
						Help(,,'Help',,"Endereço possui Ossuario vinculado, operação não pode ser realizada!",1,0)
					endIf

					FreeObj(oOssVinc)
					oOssVinc := Nil

				endIf

				if lRetorno
					// valido se o endereco esta sendo utilizado
					if U_CPGA002D(cQuadra, cModulo)
						lRetorno := .F.
						Help(,,'Help',,"O Endereco " + cDescricao + ", está sendo utilizado e não pode ser deletado!" ,1,0)
					endIf
				endIf

			endIf

		elseIf cAcao == "CANSETVALUE" // alteracao

			if lRetorno .And. AllTrim(cCampo) == "U09_CODIGO"

				if !Empty(cQuadra) .And. !Empty(cModulo)

					if U10->(FieldPos("U10_VINOSS")) > 0

						oOssVinc := OssuarioVinculado():New(.F.)
						if !oOssVinc:OssuarioUsado(cQuadra, cModulo)
							lRetorno := .F.
							Help(,,'Help',,"Endereço possui Ossuario vinculado, operação não pode ser realizada!",1,0)
						endIf

						FreeObj(oOssVinc)
						oOssVinc := Nil

					endIf

					if lRetorno
						// valido se o endereco esta sendo utilizado
						if U_CPGA002D(cQuadra, cModulo)
							lRetorno := .F.
							Help(,,'Help',,"O Endereco " + cDescricao + ", está sendo utilizado e não pode ser alterado!" ,1,0)
						endIf
					endIf

				endIf

			elseIf lRetorno .And. AllTrim(cCampo) == "U09_QTDGAV"

				if !Empty(cQuadra) .And. !Empty(cModulo)
					// valido se o endereco esta sendo utilizado
					if U_CPGA002D(cQuadra, cModulo)
						lRetorno := .F.
						Help(,,'Help',,"O Endereco " + cDescricao + ", está sendo utilizado e não pode ser alterado!" ,1,0)
					endIf
				endIf

			endIf

		endIf

	elseIf oModelGrid:cId == "U10DETAIL" // grid jazigos

		cQuadra 	:= oModelGrid:GetValue("U10_QUADRA")
		cModulo		:= oModelGrid:GetValue("U10_MODULO")
		cJazigo		:= oModelGrid:GetValue("U10_CODIGO")
		cDescricao	:= oModelGrid:GetValue("U10_DESC")

		if cAcao == 'DELETE' // exclusao

			if !Empty(cQuadra) .And. !Empty(cModulo) .And. !Empty(cJazigo)

				if U10->(FieldPos("U10_VINOSS")) > 0

					oOssVinc := OssuarioVinculado():New(.F.)
					if !oOssVinc:OssuarioUsado(cQuadra, cModulo, cJazigo)
						lRetorno := .F.
						Help(,,'Help',,"Endereço " + cDescricao + " possui Ossuario vinculado, a exclusão não pode ser realizada!",1,0)
					endIf

					FreeObj(oOssVinc)
					oOssVinc := Nil

				endIf

				if lRetorno
					// valido se o endereco esta sendo utilizado
					if U_CPGA002D(cQuadra, cModulo, cJazigo)
						lRetorno := .F.
						Help(,,'Help',,"O Endereco " + cDescricao + ", está sendo utilizado e não pode ser deletado!" ,1,0)
					endIf
				endIf

			endIf

		elseIf cAcao == "CANSETVALUE" // alteracao

			if !Empty(cQuadra) .And. !Empty(cModulo) .And. !Empty(cJazigo)

				if lRetorno .And. AllTrim(cCampo) == "U10_CODIGO"

					if U10->(FieldPos("U10_VINOSS")) > 0

						oOssVinc := OssuarioVinculado():New(.F.)
						if !oOssVinc:OssuarioUsado(cQuadra, cModulo, cJazigo)
							lRetorno := .F.
							Help(,,'Help',,"Endereço " + cDescricao + " possui Ossuario vinculado, operação não pode ser realizada!",1,0)
						endIf

						FreeObj(oOssVinc)
						oOssVinc := Nil

					endIf

					if lRetorno
						// valido se o endereco esta sendo utilizado
						if U_CPGA002D(cQuadra, cModulo, cJazigo)
							lRetorno := .F.
							Help(,,'Help',,"O Endereco " + cDescricao + ", está sendo utilizado e não pode ser alterado!" ,1,0)
						endIf
					endIf

				elseIf lRetorno .And. AllTrim(cCampo) == "U10_QTDGAV"

					// valido se o endereco esta sendo utilizado
					if U_CPGA002D(cQuadra, cModulo, cJazigo)
						lRetorno := .F.
						Help(,,'Help',,"O Endereco " + cDescricao + ", está sendo utilizado e não pode ser alterado!" ,1,0)
					endIf

				endIf

			endIf

		endIf

	endIf

Return(lRetorno)

/*/{Protheus.doc} CPGA002D
Funcao para validar se o endereco 
esta sendo utilizado
@type function
@version 1.0  
@author g.sampaio
@since 19/04/2021
@param cQuadra, character, codigo da quadra
@param cModulo, character, codigo do modulo
@param cJazigo, character, codigo do jazigo
@return logical, retorno sobre o uso do endereco - .T. - Livre | .F. - Utilizado
/*/
User Function CPGA002D(cQuadra, cModulo, cJazigo)

	Local cQuery 	:= ""
	Local lRetorno	:= .F.

	Default cQuadra	:= ""
	Default cModulo	:= ""
	Default cJazigo	:= ""

	if Select("CPGA002D") > 0
		CPGA002D->(DBCloseArea())
	endIf

	cQuery := " SELECT U04.U04_CODIGO FROM " + RetSqlName("U04") + " U04 "
	cQuery += " WHERE U04.D_E_L_E_T_ = ' ' "
	cQuery += " AND U04.U04_TIPO = 'J' "

	if !Empty(cQuadra)
		cQuery += " AND U04.U04_QUADRA = '" + cQuadra + "' "
	endIf

	if !Empty(cModulo)
		cQuery += " AND U04.U04_MODULO = '" + cModulo + "' "
	endIf

	if !Empty(cJazigo)
		cQuery += " AND U04.U04_JAZIGO = '" + cJazigo + "' "
	endIf

	cQuery += " AND (U04.U04_PREVIO = 'S' OR U04.U04_QUEMUT <> ' ') "

	TcQuery cQuery New Alias "CPGA002D"

	if CPGA002D->(!Eof())
		lRetorno := .T.
	endIf

	if Select("CPGA002D") > 0
		CPGA002D->(DBCloseArea())
	endIf

Return(lRetorno)
