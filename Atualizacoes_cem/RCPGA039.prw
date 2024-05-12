#include "totvs.ch"
#include "fwmvcdef.ch"
#include 'FWEditPanel.ch'
#include 'topconn.ch'

Static oOSTotais  	:= NIL

/*{Protheus.doc} RCPGA039
Rotina para apontamento de Servico Cemitério
@author Leandro Rodrigues
@since 12/12/2019
@version P12
@type function
@version 1.0  
*/
User Function RCPGA039(lContrato, cCodContrato)

	Local aArea			:= GetArea()
	Local aAreaU00		:= U00->(GetArea())
	Local aCoors 		:= FWGetDialogSize( oMainWnd )
	Local cTitulo		:= "Apontamento de Servico Cemitério"
	Local cTipoServico	:= SuperGetMv("MV_XTPSERC",.F.,"1") // 1 - Faturamento Comum // 2 - Faturamento com Tipo de Servico x Filial // 3 - multifaturamento
	Local oPanelUp		:= NIL
	Local oFWLayer		:= NIL
	Local oPanelDown	:= NIL
	Local oBrowseUp		:= NIL
	Local oBrowseDown	:= NIL
	Local oRelacUJX		:= NIL

	Default lContrato		:= .F.
	Default cCodContrato	:= ""

	Private oDlgPrinc	:= NIL

	DEFINE MSDIALOG oDlgPrinc Title cTitulo  From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel Style DS_MODALFRAME

	// Cria o conteiner onde serão colocados os browses
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )

	////////////////////////// PAINEL SUPERIOR /////////////////////////////
	// Cria uma "linha" com 50% da tela
	oFWLayer:AddLine( 'UP', 65, .F. )

	// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )

	// Pego o objeto desse pedaço do container
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )

	////////////////////////// PAINEL CENTRAL /////////////////////////////
	// Cria uma "linha" com 2% da tela, apenas para dar um espaço entre os grids
	oFWLayer:AddLine( 'CENTER_LINE', 2, .F. )

	////////////////////////// PAINEL INFERIOR /////////////////////////////
	// Cria uma "linha" com 50% da tela
	oFWLayer:AddLine( 'DOWN', 33, .F. )

	// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'DOWN' )

	// Pego o objeto desse pedaço do container
	oPanelDown := oFWLayer:GetColPanel( 'ALL', 'DOWN' )

	////////////////////// MONTO O BROWSER DE QUADRAS ////////////////////////
	oBrowseUp := FWmBrowse():New()
	oBrowseUp :SetOwner( oPanelUp )

	// Atribuo o título do Browser
	oBrowseUp:SetDescription( "Dados do Serviço Principal" )

	// Atribuo o nome da tabela
	oBrowseUp:SetAlias( 'UJV' )

	// verifico se estou na rotina de contrato
	If lContrato .And. Empty(cCodContrato)

		// pergunto ao usuario se quer filtrar apenas os apontamentos do contrato
		If MsgYesNo("Deseja filtrar os apontamentos de serviços do contrato posicionado?")
			oBrowseUp:SetFilterDefault( "UJV_FILIAL == '"+ U00->U00_MSFIL +"' .And. UJV_CONTRA=='" + U00->U00_CODIGO + "'" ) // filtro apenas o contrato selecionado
		EndIf

	elseif lContrato .And. !Empty(cCodContrato)

		// posiciono no contrato
		U00->(DbSetOrder(1))
		if U00->(MsSeek(xFilial("U00")+cCodContrato))

			// filtro os apontamentos do contrato
			oBrowseUp:SetFilterDefault( "UJV_FILIAL == '"+ U00->U00_MSFIL +"' .And. UJV_CONTRA=='" + U00->U00_CODIGO + "'" ) // filtro apenas o contrato selecionado

		endIf

	EndIf

	// Habilito a visualização do Menu
	oBrowseUp:SetMenuDef( 'RCPGA039' )

	// Desabilito o detalhamento do browser
	oBrowseUp:DisableDetails()

	oBrowseUp:SetProfileID( '1' )
	oBrowseUp:ForceQuitButton()

	// adiciona legenda no Browser
	If cTipoServico $ "1/2" // 1 - Faturamento Comum // 2 - Faturamento com Tipo de Servico x Filial
		oBrowseUp:AddLegend( "UJV_STATUS == 'F' .And. UJV_STENDE == 'E' .And. Empty(UJV_PEDIDO)"	, "PINK" 	, "Finalizada / Sem Faturamento")
		oBrowseUp:AddLegend( "UJV_STATUS == 'F' .And. UJV_STENDE == 'R' .And. !Empty(UJV_PEDIDO)"	, "BROWN" 	, "Faturada / Endereço Reservado")
		oBrowseUp:AddLegend( "UJV_STATUS == 'F' .And. !Empty(UJV_PEDIDO)"	, "RED"  	, "Finalizada")
	ElseIf cTipoServico	== "3" // 3 - multifaturamento
		oBrowseUp:AddLegend( "UJV_STATUS == 'F' .And. UJV_STENDE == 'E' .And. (UJV_STSMFA == '1' .OR. Empty(UJV_STSMFA))"	, "PINK" 	, "Finalizada / Sem Faturamento")
		oBrowseUp:AddLegend( "UJV_STATUS == 'F' .And. UJV_STENDE == 'R' .And. (UJV_STSMFA == '2' .OR. UJV_STSMFA == '3')"	, "BROWN" 	, "Faturada / Endereço Reservado")
		oBrowseUp:AddLegend( "UJV_STATUS == 'F' .And. UJV_STENDE == 'E' .And. UJV_STSMFA == '2'"	, "BLUE" 	, "Finalizada / Faturamento Parcial")
		oBrowseUp:AddLegend( "UJV_STATUS == 'F' .And. UJV_STSMFA == '3'"	, "RED"  	, "Finalizada")
	EndIf

	oBrowseUp:AddLegend( "UJV_STATUS == 'E' .And. UJV_STENDE == 'X'"	, "YELLOW"	, "Em Execucao / Sem Endereço")
	oBrowseUp:AddLegend( "UJV_STATUS == 'E' .And. UJV_STENDE == 'R'"	, "ORANGE"	, "Em Execucao / Endereço Reservado")
	oBrowseUp:AddLegend( "UJV_STATUS == 'E' .And. UJV_STENDE == 'E'"	, "GREEN"	, "Em Execucao / Endereço Efetivado")

	oBrowseUp:Activate()

	////////////////////// MONTO O BROWSER DE MODULOS ////////////////////////
	oBrowseDown := FWMBrowse():New()
	oBrowseDown:SetOwner( oPanelDown )

	// Atribuo o título do Browser
	oBrowseDown:SetDescription( 'Produtos e Servicos Adicionais' )

	// Desabilito a visualização do Menu, pois o usuário não pode incluir um módulo individualmente
	oBrowseDown:SetMenuDef('')

	// Desabilito o detalhamento do browser
	oBrowseDown:DisableDetails()

	// Atribuo o nome da tabela
	oBrowseDown:SetAlias( 'UJX' )

	oBrowseDown:SetProfileID( '2' )

	oBrowseDown:Activate()


	////////////////////// DEFINO O RELACIONAMENTO ENTRE OS BROWSER's ////////////////////////
	oRelacUJX:= FWBrwRelation():New()
	oRelacUJX:AddRelation( oBrowseUp , oBrowseDown , { { 'UJX_FILIAL', 'UJV_FILIAL' }, { 'UJX_CODIGO' , 'UJV_CODIGO' } } )
	oRelacUJX:Activate()

	Activate MsDialog oDlgPrinc Center

	RestAreA(aAreaU00)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} MenuDef	
Função que cria os menus			
@author Leandro Rodrigues
@since 12/12/2019
@version P12
@param Nao recebe parametros            
@return nulo.
/*/
Static Function MenuDef()

	Local aRotina 	    	:= {}
	Local aRotPedCli    	:= {}
	Local aRotEndereco		:= {}
	Local aRotAutoriz		:= {}
	Local aRotTermo			:= {}
	Local aRotProjeto		:= {}
	Local lTermoCustomizado	:= SuperGetMV("MV_XTERMOC", .F., .F.) 		// parametro para informar se utilizo a impressao de termos customizada
	Local lImpNotaFiscal 	:= SuperGetMV("MV_XIMPNOT",.F., .T.) 		// parametro para habilitar e desabilitar a opcao de impressao de nota
	Local cTipoServico		:= SuperGetMv("MV_XTPSERC",.F.,"1")
	Local lIntFieldServ		:= SuperGetMv("MV_XINTEFS",.F.,.F.)			//Parametro para habilitar integracao com o FieldService
	////////////////////////////////////////////////////////////////
	///////////// ROTINAS PARA MANUTENCAO DE PEDIDO CLIENTE ////////
	/////////////////////////////////////////////////////////////////
	Aadd( aRotPedCli, {"Gerar"         		,"U_RCPGA39A()"        					, 0, 4} )

	if cTipoServico == "1"

		Aadd( aRotPedCli, {"Alterar"     		,"U_UVirtusAlteraPV(UJV->UJV_PEDIDO)" 	, 0, 4} )
		Aadd( aRotPedCli, {"Visualizar"     	,"U_UVirtusViewPV(UJV->UJV_PEDIDO)" 	, 0, 4} )
		Aadd( aRotPedCli, {"Prep.Doc.Saida"		,"U_RCPGA39C(UJV->UJV_PEDIDO)"			, 0, 4} )
		Aadd( aRotPedCli, {"Excluir"       		,"U_RCPGA39B()"        					, 0, 4} )

	elseIf cTipoServico == "2"

		Aadd( aRotPedCli, {"Pedido(s)"     		,"U_RCPGE072()" 						, 0, 4} )

	ElseIf cTipoServico == "3"

		Aadd( aRotPedCli, {"Pedido(s)"     		,"U_RCPGA39P(UJV->UJV_CODIGO)" 			, 0, 4} )

	endif

	Aadd( aRotPedCli, {"Excluir Doc.Saida"	,"MATA521A()"							, 0, 4} )
	Aadd( aRotPedCli, {"Transmitir Nota"	,"FISA022()"							, 0, 4} )

	If lImpNotaFiscal
		Aadd( aRotPedCli, {"Imprimir Nota"	,"U_RUTILE25()"						, 0, 4} )
	EndIf

	////////////////////////////////////////////////////////////////
	///////////// ROTINAS PARA MANUTENCAO DE ENDERECO		////////
	////////////////////////////////////////////////////////////////

	Aadd( aRotEndereco, {"Efetivar Endereco"	,"U_UConfEndereco(UJV->UJV_CODIGO,UJV->UJV_CONTRA)"		, 0, 4} )
	Aadd( aRotEndereco, {"Excluir"       		,"U_UExcluiEndereco(UJV->UJV_CODIGO)"   				, 0, 4} )

	////////////////////////////////////////////////////////////////
	///////////// ROTINAS PARA AUTORIZACAO DE SERVICO		////////
	////////////////////////////////////////////////////////////////

	Aadd( aRotAutoriz, {"Guia de autorização de Sepultamento"	,"U_RCPGR008(UJV->UJV_SERVIC, UJV->UJV_CODIGO, UJV->UJV_CONTRA)"		, 0, 4} )
	Aadd( aRotAutoriz, {"Guia de autorização de Cremação"       ,"U_RCPGR009(UJV->UJV_SERVIC, UJV->UJV_CODIGO, UJV->UJV_CONTRA)"		, 0, 4} )

	// verifico se o cliente optou pela customizacao de termo
	If lTermoCustomizado

		// verifico se o ponto de entrada de termo de cliente esta compilado na base do cliente
		If ExistBlock("PTERMOCLI")

			// impressão de termos customizados pelo cliente
			aadd(aRotTermo ,{"Impressao Termo","U_PTERMOCLI()", 0, 2})

		Else

			// impressão de termos pelo modelo padrão do sistema (modelo word)
			aadd(aRotTermo ,{"Impressao Termo","U_RUTILE28(UJV->UJV_CONTRA)", 0, 2})

		EndIf

	Else// caso nao estiver coloco a impressao de termo padrao do template (modelo word)

		// impressão de termos pelo modelo padrão do sistema (modelo word)
		aadd(aRotTermo ,{"Impressao Termo","U_RUTILE28(UJV->UJV_CONTRA)", 0, 2})

	EndIf

	////////////////////////////////////////////////////////////////
	///////////// INTEGRACAO COM O MODULO FIELD SERVICE		////////
	////////////////////////////////////////////////////////////////

	if lIntFieldServ
		aadd(aRotProjeto ,{"Gerar Projeto ","U_RUTILE68('C',3,UJV->UJV_CODIGO)", 0, 2})
		aadd(aRotProjeto ,{"Visualizar Projeto ","U_RUTILE68('C',2,UJV->UJV_CODIGO)", 0, 10})
		aadd(aRotProjeto ,{"Excluir Projeto ","U_RUTILE68('C',5,UJV->UJV_CODIGO)", 0, 10})
	endif

	ADD OPTION aRotina Title "Visualizar" 			Action "VIEWDEF.RCPGA039"	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title "Incluir"    	    	Action "VIEWDEF.RCPGA039"	OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title "Alterar"    			Action "VIEWDEF.RCPGA039"	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title "Excluir"    			Action "VIEWDEF.RCPGA039"	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title "Pedido de Venda"  	Action aRotPedCli	        OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title "Enderecamento"   		Action aRotEndereco 		OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title "Guias de Autorização"	Action aRotAutoriz 			OPERATION 06 ACCESS 0
	ADD OPTION aRotina Title "Gerador de Termo"		Action aRotTermo			OPERATION 06 ACCESS 0

	if lIntFieldServ
		ADD OPTION aRotina Title "Projeto x Tarefas"    Action aRotProjeto		OPERATION 10 ACCESS 0
	endif

	ADD OPTION aRotina Title "Legenda"     			Action "U_RCPGA39LEG()" 	OPERATION 10 ACCESS 0


	If ExistBlock("PERECOSCEM")
		ADD OPTION aRotina Title "Recibo"		Action "U_PERECOSCEM(UJV->UJV_CODIGO)"			OPERATION 06 ACCESS 0
	EndIf

Return(aRotina)

/*/{Protheus.doc} ModelDef
Função que cria o objeto model	
@type function
@version 1.0 
@author Leandro Rodrigues
@since 12/12/2019
/*/
Static Function ModelDef()

	Local cContrato		:= ""
	Local cServico		:= ""
	Local cQuadra		:= ""
	Local cModulo		:= ""
	Local cJazigo		:= ""
	Local cGaveta		:= ""
	Local cOssario		:= ""
	Local cNichoOss		:= ""
	Local cCrematorio	:= ""
	Local cNichoCrem	:= ""
	Local cAutoriza		:= ""
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruUJV 		:= FWFormStruct(1,"UJV",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruUJX 		:= FWFormStruct(1,"UJX",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruU25 		:= FWFormStruct(1,"U25",/*bAvalCampo*/,/*lViewUsado*/ )

	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("PCPGA039",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( "UJVMASTER", /*cOwner*/ , oStruUJV)
	oModel:AddFields( "U25DETAIL", "UJVMASTER", oStruU25)

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey( { "UJV_FILIAL", "UJV_CODIGO" } )

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( "UJXDETAIL" ,"UJVMASTER", oStruUJX, /*bLinePre*/{ | oMdlG, nLine, cAcao, cCampo | EditGrid( oMdlG, nLine, cAcao, cCampo ) },/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation("UJXDETAIL" , { {"UJX_FILIAL", 'xFilial("UJX")'}, {"UJX_CODIGO","UJV_CODIGO"}}, UJX->(IndexKey(1)))
	oModel:SetRelation("U25DETAIL" , { {"U25_FILIAL", 'xFilial("U25")'}, {"U25_CODAPO","UJV_CODIGO"}, {"U25_CONTRA","UJV_CONTRA"}}, U25->(IndexKey(4)) )

	// Liga o controle de nao repeticao de linha
	oModel:GetModel("UJXDETAIL"):SetUniqueLine( {"UJX_FILIAL", "UJX_SERVIC"} )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("UJVMASTER"):SetDescription("Dados do Contrato")
	oModel:GetModel("UJXDETAIL"):SetDescription("Servicos")

	// Desobriga a digitacao de ao menos um item
	oModel:GetModel("UJXDETAIL"):SetOptional(.T.)
	oModel:GetModel("U25DETAIL"):SetOptional(.T.)

	if lPlanoPet

		if (FWIsInCallStack("U_RCPGA001") .And. U00->U00_USO == "3")

			oModel:SetDescription( 'Apontamento de Serviços PET' )

			// campos obrigatorio
			oStruUJV:SetProperty( 'UJV_TIPPET' 	, MODEL_FIELD_OBRIGAT, .T.)
			oStruUJV:SetProperty( 'UJV_RACA'	, MODEL_FIELD_OBRIGAT, .T.)
			oStruUJV:SetProperty( 'UJV_CORPEL' 	, MODEL_FIELD_OBRIGAT, .T.)
			oStruUJV:SetProperty( 'UJV_PORTE' 	, MODEL_FIELD_OBRIGAT, .T.)

			// altero a descricao dos campos
			// ATENCAO: DEVE-SE ALTERAR A DESCRICAO NO VIEW TAMBEM PARA FUNCIONAR NO FORMULARIO
			oStruUJV:SetProperty( 'UJV_NOME' 	, MODEL_FIELD_TITULO, "Pet Falecido")

			// inicializador padrao
			oStruUJV:SetProperty( 'UJV_USO' 	, MODEL_FIELD_INIT, FwBuildFeature( 3, "3") )

			// campo nao editavel
			oStruUJV:SetProperty( 'UJV_USO' 	, MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") )
			oStruUJV:SetProperty( 'UJV_TIPPET' 	, MODEL_FIELD_WHEN , FwBuildFeature( 2, ".T.") )
			oStruUJV:SetProperty( 'UJV_RACA' 	, MODEL_FIELD_WHEN , FwBuildFeature( 2, ".T.") )
			oStruUJV:SetProperty( 'UJV_CORPEL' 	, MODEL_FIELD_WHEN , FwBuildFeature( 2, ".T.") )
			oStruUJV:SetProperty( 'UJV_PORTE' 	, MODEL_FIELD_WHEN , FwBuildFeature( 2, ".T.") )

			// mudo o combo de opcoes
			oStruUJV:SetProperty( 'UJV_SEXO' 	, MODEL_FIELD_VALUES, {"M=Macho","F=Femea"})

		endIf

	endif

	If FWIsInCallStack("U_RUTIL49B")

		cServico 	:= U92->U92_SERVIC
		cQuadra		:= U92->u92_QUADRA
		cModulo		:= U92->U92_MODULO
		cJazigo 	:= U92->U92_JAZIGO
		cGaveta 	:= U92->U92_GAVETA
		cOssario	:= U92->U92_OSSUAR
		cNichoOss	:= U92->U92_NICHOO
		cCrematorio	:= U92->U92_CREMAT
		cNichoCrem	:= U92->U92_NICHOC
		cContrato 	:= U92->U92_CONTRA
		cAutoriza	:= U92->U92_AUTORI

		oStruUJV:SetProperty( 'UJV_CONTRA' 	, MODEL_FIELD_INIT , {|| cContrato } )
		oStruUJV:SetProperty( 'UJV_SERVIC' 	, MODEL_FIELD_INIT , {|| cServico } )
		oStruUJV:SetProperty( 'UJV_AUTORI' 	, MODEL_FIELD_INIT , {|| cAutoriza } )
		oStruUJV:SetProperty( 'UJV_QUADRA' 	, MODEL_FIELD_INIT , {|| cQuadra } )
		oStruUJV:SetProperty( 'UJV_MODULO' 	, MODEL_FIELD_INIT , {|| cModulo } )
		oStruUJV:SetProperty( 'UJV_JAZIGO' 	, MODEL_FIELD_INIT , {|| cJazigo } )
		oStruUJV:SetProperty( 'UJV_GAVETA' 	, MODEL_FIELD_INIT , {|| cGaveta } )
		oStruUJV:SetProperty( 'UJV_OSSARI' 	, MODEL_FIELD_INIT , {|| cOssario } )
		oStruUJV:SetProperty( 'UJV_NICHOO' 	, MODEL_FIELD_INIT , {|| cNichoOss } )
		oStruUJV:SetProperty( 'UJV_CREMAT' 	, MODEL_FIELD_INIT , {|| cCrematorio } )
		oStruUJV:SetProperty( 'UJV_NICHOC' 	, MODEL_FIELD_INIT , {|| cNichoCrem } )

	EndIf

Return(oModel)

/*/{Protheus.doc} ViewDef
Função que cria o objeto View	
@type function
@version 1.0 
@author Leandro Rodrigues
@since 12/12/2019
/*/
Static Function ViewDef()

	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet

	// Cria a estrutura a ser usada na View
	Local oStruUJV 		:= FWFormStruct(2,"UJV")
	Local oStruUJX 		:= FWFormStruct(2,"UJX")
	Local oStruU25 		:= FWFormStruct(2,"U25")

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   		:= FWLoadModel("RCPGA039")
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "VIEW_UJV", oStruUJV, "UJVMASTER")
	oView:AddField( "VIEW_U25", oStruU25, "U25DETAIL")

	oView:AddGrid( "VIEW_UJX", oStruUJX, "UJXDETAIL")

	// Cria componentes nao MVC
	oView:AddOtherObject( "RESUMO", {|oPanel| CriaTotais(oPanel) } )

	//Cria Folder para organizar separacao de tela
	oView:CreateVerticalBox( "PAINEL_ESQUERDA"		, 100)
	oView:CreateVerticalBox( "PAINEL_DIREITA"		, 100,,.T.)

	oView:SetOwnerView( "RESUMO"		, "PAINEL_DIREITA")

	// Cria Folder na view
	oView:CreateFolder( 'FLD_APO', 'PAINEL_ESQUERDA')

	// Cria pastas nas folders
	oView:AddSheet( 'FLD_APO', 'ABA01', 'Apontamento'  )
	oView:AddSheet( 'FLD_APO', 'ABA02', 'Locacao Sala' )

	oView:CreateHorizontalBox( 'PAINEL_CABEC'   , 60 ,,, 'FLD_APO', 'ABA01' )
	oView:CreateHorizontalBox( 'PAINEL_SERVICO' , 40 ,,, 'FLD_APO', 'ABA01' )
	oView:CreateHorizontalBox( 'PAINEL_LOCACAO' , 100,,, 'FLD_APO', 'ABA02' )

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( "VIEW_UJV"	,"PAINEL_CABEC"  )
	oView:SetOwnerView( "VIEW_U25"	,"PAINEL_LOCACAO")
	oView:SetOwnerView( "VIEW_UJX"	,"PAINEL_SERVICO")

	// Liga a identificacao do componente
	oView:EnableTitleView( "VIEW_UJX", "Produtos/Servicos Adicionais:" )

	// Define campos que terao Auto Incremento
	oView:AddIncrementField( "VIEW_UJX", "UJX_ITEM" )

	// Habilita a quebra dos campos na Vertical
	oView:SetViewProperty( 'UJVMASTER', "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

	// Inicializacao do campo Contrato quando chamado pela rotina de Contrato
	bBloco := {|oView| IniCpoCem(oView)}
	oView:SetAfterViewActivate(bBloco)

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk( {||.T.} )

	// Habilito a barra de progresso na abertura da tela
	oView:SetProgressBar(.T.)

	if lPlanoPet

		if (FWIsInCallStack("U_RCPGA001") .And. U00->U00_USO == "3")

			oStruUJV:SetProperty( 'UJV_NOME' , MVC_VIEW_TITULO, "Pet Falecido")

			// seto o campo como nao editavel
			oStruUJV:SetProperty( 'UJV_USO' 	, MVC_VIEW_CANCHANGE, .F. )
			oStruUJV:SetProperty( 'UJV_TIPPET' 	, MVC_VIEW_CANCHANGE, .T. )
			oStruUJV:SetProperty( 'UJV_RACA' 	, MVC_VIEW_CANCHANGE, .T. )
			oStruUJV:SetProperty( 'UJV_CORPEL' 	, MVC_VIEW_CANCHANGE, .T. )
			oStruUJV:SetProperty( 'UJV_PORTE' 	, MVC_VIEW_CANCHANGE, .T. )

			// mudo o combo de opcoes
			oStruUJV:SetProperty( 'UJV_SEXO' 	, MVC_VIEW_COMBOBOX, {"M=Macho","F=Femea"})

			// removo alguns campos do apontamento
			oStruUJV:RemoveField('UJV_CPFFAL')
			oStruUJV:RemoveField('UJV_RGFAL')
			oStruUJV:RemoveField('UJV_RELIGI')
			oStruUJV:RemoveField('UJV_XMEDUR')
			oStruUJV:RemoveField('UJV_XMEDES')
			oStruUJV:RemoveField('UJV_XGRAUF')
			oStruUJV:RemoveField('UJV_ORIGEM')
			oStruUJV:RemoveField('UJV_ENDFAL')
			oStruUJV:RemoveField('UJV_CMPFAL')
			oStruUJV:RemoveField('UJV_BAIFAL')
			oStruUJV:RemoveField('UJV_DTCERT')
			oStruUJV:RemoveField('UJV_LOCFAL')
			oStruUJV:RemoveField('UJV_DTNASC')
			oStruUJV:RemoveField('UJV_ESTCIV')
			oStruUJV:RemoveField('UJV_NACION')
			oStruUJV:RemoveField('UJV_DESNAT')
			oStruUJV:RemoveField('UJV_UF')
			oStruUJV:RemoveField('UJV_CODMUN')
			oStruUJV:RemoveField('UJV_MUN')
			oStruUJV:RemoveField('UJV_NOMAE')
			oStruUJV:RemoveField('UJV_FUNERA')
			oStruUJV:RemoveField('UJV_CEPFAL')

		endIf

	else

		// verifico se o campo existe no dicionario(SX3)
		if UJV->(FieldPos("UJV_USO")) > 0
			oStruUJV:RemoveField('UJV_USO')
		endIf

		if UJV->(FieldPos("UJV_TIPPET")) > 0
			oStruUJV:RemoveField('UJV_TIPPET')
		endIf

		if UJV->(FieldPos("UJV_RACA")) > 0
			oStruUJV:RemoveField('UJV_RACA')
		endIf

		if UJV->(FieldPos("UJV_CORPEL")) > 0
			oStruUJV:RemoveField('UJV_CORPEL')
		endIf

		if UJV->(FieldPos("UJV_PORTE")) > 0
			oStruUJV:RemoveField('UJV_PORTE')
		endIf

	endIf

Return(oView)

/*/{Protheus.doc} CriaTotais
Função que cria o Other Object de Totalizadores
@type function
@version 1.0
@author g.sampaio
@since 03/05/2019
@param oPanel, object, param_description
@return return_type, return_description
/*/
Static Function CriaTotais(oPanel)

	oOSTotais := ObjOSFin():New(oPanel)

	//atualizo o tototalizador de contratado
	oOSTotais:ApoRefresh()

	//atualizo o totalizador de entregue e desconto
	oOSTotais:RefreshTot()

Return(Nil)

	/*/{Protheus.doc} ObjOSFin
	Classe do totalizador
	@type class
	@version
	@author g.sampaio
	@since 03/05/2019
	/*/
	Class ObjOSFin

		Data oVlrCttPago
		Data oVlrServicos
		Data oVlrAdicional
		Data oVlrReceber
		Data oSitFinanc

		Data nVlrCttPago
		Data nVlrServicos
		Data nVlrAdicional
		Data nVlrReceber
		Data cSitFinanc

		//Metodo Construtor da Classe
		Method New() Constructor

		//Metodo para Atualizar o Valor a Receber da OS
		Method RefreshTot()

		//Metodo para Atualizar o Total Contratado
		Method ApoRefresh()

	EndClass

/*/{Protheus.doc} ObjOSFin::New
Método construtor da classe ObjTotal
@type method
@version 
@author g.sampaio 
@since 03/05/2019
@param oPanel, object, param_description
@return return_type, return_description
/*/
Method New(oPanel) Class ObjOSFin

	Local oPanelCpo		:= NIL
	Local oPanelCont	:= NIL
	Local oPnlTotSev	:= NIL
	Local oPnlTotAdc	:= NIL
	Local oPnlTotRec	:= NIL
	Local oPnlStaFin	:= NIL
	Local oSay1			:= NIL
	Local oSay2			:= NIL
	Local oSay3			:= NIL
	Local oModel 		:= FWModelActive()
	Local oFont12N	   	:= TFont():New("Verdana",,12,,.T.,,,,.T.,.F.,.T.) // Fonte 12 Negrito, Itálico
	Local oFont14N	   	:= TFont():New("Verdana",,14,,.T.,,,,.T.,.F.,.F.) // Fonte 14 Negrito
	Local oFont18N	   	:= TFont():New("Verdana",,18,,.T.,,,,.T.,.F.,.T.) // Fonte 28 Negrito
	Local oFontNum	   	:= TFont():New("Verdana",08,18,,.F.,,,,.T.,.F.) ///Fonte 14 Negrito
	Local oFontSit	   	:= TFont():New("Cooper Black",,13,,.F.,,,,.T.,.F.,.F.) // Fonte 24 Nornal
	Local nHeigth		:= oPanel:nClientHeight / 2
	Local nWhidth		:= oPanel:nClientWidth / 2
	Local nOperation 	:= oModel:GetOperation()
	Local nLin			:= 3
	Local nClrPanes		:= 16777215
	Local nClrSay		:= 7303023
	Local nClrAdimp 	:= 41984
	Local nAltPanels	:= 0
	Local nClrSitFin	:= 12961221
	Local lAdimp		:= .F.
	Local nClrInadi		:= 987135
	Local cContrato 	:= ""

	// inicializo os novos totais zerados
	::nVlrCttPago	    := 0
	::nVlrServicos		:= 0
	::nVlrAdicional		:= 0
	::nVlrReceber		:= 0
	::cSitFinanc 		:= "INEXISTENTE"

	//Valido se OS é de contrato para validar situacao financeira
	if IsInCallStack("U_RCPGA001") .Or. IsInCallStack("U_RUTIL023")

		cContrato := U00->U00_CODIGO

	ElseIf FWIsInCallStack("U_RUTIL49B")

		cContrato := U92->U92_CONTRA

	elseif nOperation <> 3

		cContrato := UJV->UJV_CONTRA

	endif

	if !Empty(cContrato)

		// função que retorna a situação financeira do contrato
		lAdimp := RetSitFin(cContrato)

		if lAdimp
			::cSitFinanc 	:= "ADIMPLENTE"
			nClrSitFin		:= nClrAdimp
		else
			::cSitFinanc 	:= "PENDENTE"
			nClrSitFin		:= nClrInadi
		endif

		::nVlrCttPago := RetTotalPagoContrato(cContrato)

	endif

	//////////////////////////////////////////////////////////
	////////////////	PAINEL PRINCIPAL 	/////////////////
	/////////////////////////////////////////////////////////

	@ 002, 002 MSPANEL oPanelCpo SIZE nWhidth - 2 , nHeigth -2 OF oPanel COLORS 0, 12961221

	nAltPanels := INT(nHeigth - nLin - 5) / 5

	/////////////////////////////////////////////////////////////////
	////////////////	PANEL VALOR CONTRATADO		////////////////
	////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPanelCont SIZE nWhidth - 6 , nAltPanels OF oPanelCpo  COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay1 PROMPT "Total Pago Contrato" SIZE nWhidth - 6, 015 OF oPanelCont FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay2 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPanelCont FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 001 SAY oSay53 PROMPT "R$" SIZE 045, 010 OF oPanelCont FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 001 SAY ::oVlrCttPago PROMPT AllTrim(Transform(::nVlrCttPago,"@E 999,999.99")) SIZE 45, 010 OF oPanelCont FONT oFontNum COLORS 0, 16777215 PIXEL CENTER

	nLin += nAltPanels

	/////////////////////////////////////////////////////////////////
	////////////////	PANEL TOTAL SERVICOS		////////////////
	////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPnlTotSev SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay1 PROMPT "Total Servicos" SIZE nWhidth - 6, 015 OF oPnlTotSev FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay2 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPnlTotSev FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 001 SAY oSay3 PROMPT "R$" SIZE 045, 010 OF oPnlTotSev FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 001 SAY ::oVlrServicos PROMPT AllTrim(Transform(::nVlrServicos,"@E 999,999.99")) SIZE 45, 010 OF oPnlTotSev FONT oFontNum COLORS 0, 16777215 PIXEL CENTER

	nLin += nAltPanels

	/////////////////////////////////////////////////////////////////
	////////////////	PANEL SERVICOS ADICIONAIS	////////////////
	////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPnlTotAdc SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay1 PROMPT "Servicos Adicionais" SIZE nWhidth - 6, 015 OF oPnlTotAdc FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay2 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPnlTotAdc FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 001 SAY oSay3 PROMPT "R$" SIZE 045, 010 OF oPnlTotAdc FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 001 SAY ::oVlrAdicional PROMPT AllTrim(Transform(::nVlrAdicional,"@E 999,999.99")) SIZE 45, 010 OF oPnlTotAdc FONT oFontNum COLORS 0, 16777215 PIXEL CENTER

	nLin += nAltPanels

	/////////////////////////////////////////////////////////////////
	////////////////	PANEL VALOR RECEBER			////////////////
	////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPnlTotRec SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay1 PROMPT "Valor a Receber" SIZE nWhidth - 6, 015 OF oPnlTotRec FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay2 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPnlTotRec FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 001 SAY oSay3 PROMPT "R$" SIZE 045, 010 OF oPnlTotRec FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 001 SAY ::oVlrReceber PROMPT AllTrim(Transform(::nVlrReceber,"@E 999,999.99")) SIZE 45, 010 OF oPnlTotRec FONT oFontNum COLORS 0, 16777215 PIXEL CENTER

	nLin += nAltPanels

	/////////////////////////////////////////////////////////////////
	////////////////	PANEL STATUS FINANCIERO		////////////////
	////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPnlStaFin SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrSitFin RAISED
	@ 000 , 000 SAY oSay1 PROMPT "Situação Financeira" SIZE nWhidth - 6, 015 OF oPnlStaFin FONT oFont14N COLORS 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay2 PROMPT Replicate("- ",13) SIZE nWhidth - 6, 015 OF oPnlStaFin FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) + 5, 001 SAY ::oSitFinanc PROMPT ::cSitFinanc SIZE 45, 010 OF oPnlStaFin FONT oFontSit COLORS 16777215, nClrSitFin PIXEL CENTER

	// se não for inclusão, atualiza os valores atuais
	if nOperation <> 3

		// chamo função que atualiza os valores do apontamento
		::RefreshTot()

	endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RetSitFin º Autor³ Wellington Gonçalves º Data³ 09/04/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que consulta os títulos em aberto do contrato		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Postumos			                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RetSitFin(cContrato)

	Local lRet 			:= .T.
	Local cPulaLinha	:= chr(13)+chr(10)
	Local cQry			:= ""

	// verifico se nao existe este alias criado
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	EndIf

	cQry := " SELECT " 												+ cPulaLinha
	cQry += " SE1.E1_NUM " 											+ cPulaLinha
	cQry += " FROM " 												+ cPulaLinha
	cQry += " " + RetSqlName("SE1") + " SE1 "						+ cPulaLinha
	cQry += " WHERE " 												+ cPulaLinha
	cQry += " SE1.D_E_L_E_T_	<> '*' " 							+ cPulaLinha
	cQry += " AND SE1.E1_FILIAL 	= '" + xFilial("SE1") + "' " 	+ cPulaLinha
	cQry += " AND SE1.E1_XCONTRA	= '" + cContrato + "' "			+ cPulaLinha
	cQry += " AND SE1.E1_SALDO		> 0 "							+ cPulaLinha
	cQry += " AND SE1.E1_VENCREA	< '" + DTOS(dDataBase) + "' "	+ cPulaLinha
	cQry += " AND SE1.E1_TIPO NOT IN ('AB-','FB-','FC-','FU-' " 	+ cPulaLinha
	cQry += " ,'PR','IR-','IN-','IS-','PI-','CF-','CS-','FE-' "		+ cPulaLinha
	cQry += " ,'IV-','RA','NCC','NDC') "							+ cPulaLinha

	// funcao que converte a query generica para o protheus
	cQry := ChangeQuery(cQry)

	// verifico se nao existe este alias criado
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	EndIf

	// crio o alias temporario
	TcQuery cQry New Alias "QRYSE1"

	if QRYSE1->(!Eof())
		lRet := .F.
	endif


Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ContratadoRefresh º Autor ³ g.sampaio 	 ³ 03/05/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Método Refresh do Totais da Ordem de Servico				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Postumos			                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method ApoRefresh() Class ObjOSFin

	Local _aSaveLines	:= FWSaveRows()
	Local nI			:= 0
	Local oModel		:= FWModelActive()
	Local oModelUJX 	:= oModel:GetModel("UJXDETAIL")
	Local nLinhaAtual	:= oModelUJX:GetLine()

	/////////////////////////////////////////////////////
	//// CALCULO OS VALORES DOS PRODUTOS CONTRATADOS ///
	////////////////////////////////////////////////////
	For nI := 1 To oModelUJX:Length()

		oModelUJX:Goline(nI)

		if !oModelUJX:IsDeleted()

			::nVlrCttPago += oModelUJX:GetValue("UJX_VALOR")

		Endif

	Next nI

	::oVlrCttPago:Refresh()

	oModelUJX:Goline(nLinhaAtual)

	FWRestRows(_aSaveLines)

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RefreshEnt º Autor ³ g.sampaio   º Data ³ 03/05/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Método Refresh do Totais da Ordem de Servico				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Postumos			                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Method RefreshTot(cAcao,nLinha) Class ObjOSFin

	Local oModel		:= FWModelActive()
	Local oModelUJX 	:= oModel:GetModel("UJXDETAIL")
	Local nLinhaAtual	:= oModelUJX:GetLine()
	Local cServico		:= FwFldGet("UJV_SERVIC")
	Local cTabelaPreco	:= FwFldGet("UJV_TABPRC")
	Local nPrecoServico	:= 0
	Local nDesconto 	:= 0
	Local nI			:= 0
	Local _aSaveLines	:= FWSaveRows()
	Default cAcao		:= ""
	Default nLinha		:= 1

	if UJV->(FieldPos("UJV_DESCON")) > 0
		nDesconto := FwFldGet("UJV_DESCON")
	endif

	//Retorna o preco do servico principal
	if !Empty(cServico)
		nPrecoServico := U_RetPrecoVenda(cTabelaPreco,cServico)
	endif

	::nVlrServicos	:= nPrecoServico
	::nVlrAdicional	:= 0
	::nVlrReceber	:= 0

	For nI := 1 To oModelUJX:Length()

		oModelUJX:Goline(nI)

		//valido se esta deletando a linha
		If cAcao == "DELETE" .And. nI == nLinha
			Loop
		else
			If UJX->(FieldPos("UJX_DESCON")) > 0
				::nVlrAdicional	+= oModelUJX:GetValue("UJX_VALOR") - oModelUJX:GetValue("UJX_DESCON")
			Else
				::nVlrAdicional	+= oModelUJX:GetValue("UJX_VALOR")
			EndIf
		Endif

	Next nI

	::nVlrReceber := ::nVlrServicos + ::nVlrAdicional - nDesconto

	//atualizo totalizadores
	::oVlrServicos:Refresh()
	::oVlrAdicional:Refresh()
	::oVlrReceber:Refresh()

	oModelUJX:Goline(nLinhaAtual)

	FWRestRows(_aSaveLines)

Return(Nil)

/*/{Protheus.doc} IniCpoCont
//Funcao para inicializar campos 
de acordo com o contrato posicionado.
@author Leandro Rodrigues
@since 16/12/2019
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@type function.
/*/
Static Function IniCpoCem(oView)

	Local nOperation 	:= oView:GetOperation()

	//valido se e inclusao e chamada pela tela do contrato
	If nOperation == 3 .And. IsInCallStack("U_RCPGA040") //

		//Informacoes do contrato
		FwFldPut("UJV_CONTRA"	,U00->U00_CODIGO	,,,,.T.)

		//Informacoes do Cliente
		FwFldPut("UJV_LOJCLI"	,Alltrim(U00->U00_LOJA)  	,,,,.T.)
		FwFldPut("UJV_CODCLI"	,U00->U00_CLIENT			,,,,.T.)
		FwFldPut("UJV_NOMBEN"	,U00->U00_NOMCLI			,,,,.T.)

		oView:Refresh()

	EndIf

Return

/*/{Protheus.doc} 
//Funcao para Validar Servico selecionado
@author Leandro Rodrigues
@since 16/12/2019
@version 1.0
@param Nao recebe parametros            
@return nulo
/*/
User Function ValidaServico()

	Local cServico				:= ""
	Local cTabelaPreco			:= ""
	Local cContrato 			:= ""
	Local nPrecoServico			:= 0
	Local lRet 	 				:= .T.
	Local lRotAuto				:= FWIsInCallStack("U_RCPGE056")// quando estiver executando a rotina automatica
	Local lTransfEnd			:= FWIsInCallStack("U_PCPGA034") .Or. FWIsInCallStack("U_RCPGA34C")// quando estiver executando pela transferencia de endereco
	Local lPlanoPet				:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local oView					:= FWViewActive()
	Local oModel 				:= FWModelActive()
	Local oModelUJV				:= oModel:GetModel( 'UJVMASTER' )
	Local oStructUJV			:= oModelUJV:GetStruct()		// Estrutura da View - Cabecalho de servicos
	Local lValidAptAuto			:= SuperGetMV("MV_XVAPTAU", .F., .T.)
	Local lExecValidacao		:= .T.
	Local lValDadosObt			:= .T.

	// atribuo valor as variaveis
	cServico			:= FwFldGet("UJV_SERVIC")
	cTabelaPreco		:= FwFldGet("UJV_TABPRC")
	cContrato 			:= FwFldGet("UJV_CONTRA")

	SB1->(DbSetOrder(1))
	U37->(DbSetOrder(2)) //U37_FILIAL+U37_CODIGO+U37_SERVIC

	// posiciono no cadastro do pedido
	if SB1->(MsSeek(xFilial("SB1")+cServico))

		// vejo se esta tudo certo
		if lRet

			//valido a carencia do contrato para execucao do servico
			if FWIsInCallStack("U_RCPGA34C") .Or. CarenciaValida(cContrato)

				//Valida saldo do produto para o contrato
				if U37->(MsSeek(xFilial("U37") + cContrato + cServico))

					if U37->U37_CTRSLD == "S" .And. U37->U37_SALDO == 0

						Help(,,'Help',,"Servico selecionado não possui saldo no contrato !",1,0)
						lRet:= .F.
						//valido se o servico possui tabela de preco
					elseif (nPrecoServico := U_RetPrecoVenda(cTabelaPreco,cServico)) == 0

						Help(,,'Help',,"Servico selecionado não possui preco vigente, favor verifique a tabela de preço!",1,0)
						lRet:= .F.

					endif

				else

					Help(,,'Help',,"Serviço Selecionado não habilitado para o contrato, verifique os serviços do contrato!",1,0)
					lRet := .F.

				endif

			else

				lRet := .F.
				Help(,,'Help',,"Apontamento não permitido!",1,0)

			endif

		endif

		// verifico se irei validar os dados do obito para rotina automatica
		if !(FWIsInCallStack("U_RCPGA039") .Or. AllTrim(FunName()) $ "RCPGA039") .And. lRotAuto
			lExecValidacao := lValidAptAuto
		EndIf

		// vejo se esta tudo certo
		if lRet .And. !lTransfEnd .And. lExecValidacao

			/////////////////////////////////////////////////////////////
			//////// DESABILITO TODOS OS CAMPOS DE ENDERECO  ///////////
			/////////////////////////////////////////////////////////////

			//Valido se servico é necessario enderecar
			if !Empty(SB1->B1_XREQSER)

				// verifico se o plano pet esta habilitado
				if lPlanoPet

					if SB1->B1_XUSOSRV == "3" // pet
						lValDadosObt := .F.
					endIf

				endIf

				if lValDadosObt

					//Deixa campos obrigatorios
					oStructUJV:SetProperty( 'UJV_DTOBT' , MODEL_FIELD_OBRIGAT, .T.)
					oStructUJV:SetProperty( 'UJV_DTCERT', MODEL_FIELD_OBRIGAT, .T.)
					oStructUJV:SetProperty( 'UJV_CAUSA' , MODEL_FIELD_OBRIGAT, .T.)
					oStructUJV:SetProperty( 'UJV_LOCFAL', MODEL_FIELD_OBRIGAT, .T.)
					oStructUJV:SetProperty( 'UJV_NOME'  , MODEL_FIELD_OBRIGAT, .T.)
					oStructUJV:SetProperty( 'UJV_DTNASC', MODEL_FIELD_OBRIGAT, .T.)
					oStructUJV:SetProperty( 'UJV_NOMAE' , MODEL_FIELD_OBRIGAT, .T.)

				elseIf lPlanoPet

					oStructUJV:SetProperty( 'UJV_NOME'  , MODEL_FIELD_OBRIGAT, .T.)

				endIf

				// verifico o tipo de endereco para definir se o campo pode ser editado ou nao
				If AllTrim(SB1->B1_XREQSER) == "C" // crematorio
					oStructUJV:SetProperty( 'UJV_CREMAT' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".T.") ) // habilito a edicao do campo crematorio
					oStructUJV:SetProperty( 'UJV_QUADRA' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo quadra
					oStructUJV:SetProperty( 'UJV_OSSARI' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo ossruario

				ElseIf AllTrim(SB1->B1_XREQSER) == "J" // jazigo
					oStructUJV:SetProperty( 'UJV_CREMAT' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo crematorio
					oStructUJV:SetProperty( 'UJV_QUADRA' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".T.") ) // habilito a edicao do campo quadra
					oStructUJV:SetProperty( 'UJV_OSSARI' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo ossruario

				ElseIf AllTrim(SB1->B1_XREQSER) == "O" // ossuario
					oStructUJV:SetProperty( 'UJV_CREMAT' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo crematorio
					oStructUJV:SetProperty( 'UJV_QUADRA' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo quadra
					oStructUJV:SetProperty( 'UJV_OSSARI' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".T.") ) // habilito a edicao do campo ossruario

				EndIf

			else

				//Retira obrigatoriedade dos campos
				oStructUJV:SetProperty( 'UJV_DTOBT' , MODEL_FIELD_OBRIGAT, .F.)
				oStructUJV:SetProperty( 'UJV_DTCERT', MODEL_FIELD_OBRIGAT, .F.)
				oStructUJV:SetProperty( 'UJV_CAUSA' , MODEL_FIELD_OBRIGAT, .F.)
				oStructUJV:SetProperty( 'UJV_LOCFAL', MODEL_FIELD_OBRIGAT, .F.)
				oStructUJV:SetProperty( 'UJV_NOME'  , MODEL_FIELD_OBRIGAT, .F.)
				oStructUJV:SetProperty( 'UJV_DTNASC', MODEL_FIELD_OBRIGAT, .F.)
				oStructUJV:SetProperty( 'UJV_NOMAE' , MODEL_FIELD_OBRIGAT, .F.)

				// desabilito a edicao dos campos de endereco
				oStructUJV:SetProperty( 'UJV_CREMAT' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo crematorio
				oStructUJV:SetProperty( 'UJV_QUADRA' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo quadra
				oStructUJV:SetProperty( 'UJV_OSSARI' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo ossruario

			endif

		endif

	elseif !Empty(cServico) // caso o servico nao existir no cadastro de produtos

		Help(,,'Help',,"Serviço Selecionado inválido, verifique o cadastro de produtos!",1,0)
		lRet := .F.

	endif

	if lRet

		if oView <> NIL .And. !lRotAuto // nao atualizo os totalizadores via execauto

			//Atualiza os totalizadores
			oOSTotais:RefreshTot()

		endif

		// LIMPA TODOS OS CAMPOS DE ENDERECO
		FwFldPut("UJV_QUADRA"	,"" ,,,,.T.)
		FwFldPut("UJV_MODULO"	,"" ,,,,.T.)
		FwFldPut("UJV_JAZIGO"	,"" ,,,,.T.)
		FwFldPut("UJV_GAVETA"	,"" ,,,,.T.)
		FwFldPut("UJV_CREMAT"	,"" ,,,,.T.)
		FwFldPut("UJV_NICHOC"	,"" ,,,,.T.)
		FwFldPut("UJV_OSSARI"	,"" ,,,,.T.)
		FwFldPut("UJV_NICHOO"	,"" ,,,,.T.)

	endif

	//nao atualizo a view via execauto
	if !lRotAuto
		oView:Refresh("UJVMASTER")
	EndIf

Return lRet

/*/{Protheus.doc}  CarenciaValida
//Funcao para validar a carencia do contrato
@author g.sampaio 
@since 28/01/2020
@version 1.0
@param cContrato - Codigo do Contra]to do apontamento            
@return nulo
/*/
Static Function CarenciaValida(cContrato)

	Local lRet 					:= .T.
	Local aAreaU00				:= U00->(GetArea())
	Local lAtivaNegociacao    	:= SuperGetMV("MV_XATVNEG",, .F.)           // ativa ou nao a regra de negociacao
	Local lCarencia				:= .F.
	Local nCarDias				:= 0										// carencia em dias
	Local nCarFin				:= 0 										// carencia em valor recebido
	Local nPerCarFin			:= 0
	Local nDiasAtivacao			:= 0
	Local nRecebido				:= 0
	Local nPercRecebido			:= 0
	Local oSay1					:= NIL
	Local oSay2					:= NIL
	Local oSay3					:= NIL
	Local oSay4					:= NIL
	Local oSay5					:= NIL
	Local oSay6					:= NIL
	Local oSay7					:= NIL
	Local oSay8					:= NIL
	Local oSay9					:= NIL
	Local oSay10				:= NIL
	Local oSay11				:= NIL
	Local oSay12				:= NIL
	Local oSay13				:= NIL
	Local oDlgCar				:= NIL
	Local oRegraNegociacao		:= NIL

	U00->(DbSetOrder(1)) //U00_FILIAL + U00_CODIGO

	if U00->(MsSeek(xFilial("U00") + cContrato ))

		nRecebido 		:= RetTotalPagoContrato(cContrato)

		nPercRecebido 	:= Round( ( nRecebido / U00->U00_VALOR) * 100, 2 )

		// verifico se a regra de negociacao esta ativa
		if lAtivaNegociacao .And. !Empty(U00->U00_REGNEG)

			// difeerenca de dias entre a database e a data de ativacao
			nDiasAtivacao := DateDiffDay( U00->U00_DTATIV, dDataBase )

			// executo a classe de regra de negociacao
			oRegraNegociacao := RegraNegociacao():New(U00->U00_REGNEG, U00->U00_FORPG)

			// valido a regra do contrato
			oRegraNegociacao:ValidaRegra(U00->U00_QTDPAR)

			// dados de carencia do contrato
			nCarDias	:= U00->U00_CARDIA	// carencia em dias

			if oRegraNegociacao:cTipoCarenciaFinanceiro == "1" // percentual
				nPerCarFin	:= oRegraNegociacao:nCarenciaFinanceiro
				nCarFin 	:= U00->U00_VALOR * (nPerCarFin/ 100)
			else// valor
				nCarFin		:= U00->U00_CARFIN
			endIf

			// carencia
			if nCarFin > 0 .And. nCarDias > 0
				if nCarDias > nDiasAtivacao .And. nCarfin > nRecebido // valida ambos os tipos de carencia
					lCarencia := .T.
				endIf
			elseIf nCarFin > 0 // carencia financeira
				if nCarfin > nRecebido
					lCarencia := .T.
				endIf
			elseIf nCarDias > 0 // carencia em dias
				if nCarDias > nDiasAtivacao
					lCarencia := .T.
				endIf
			endIf

			// tela de aviso para carencia
			if lCarencia
				lRet := .F. // retorno falso da rotina
				oRegraNegociacao:ValRegraCarencia( U00->U00_REGNEG, U00->U00_DTATIV, U00->U00_VALOR, nPerCarFin, nCarFin, nCarDias, nDiasAtivacao, nRecebido )
			endIf

		else // sem regra de negociacao

			If nPercRecebido < U00->U00_CARENC

				MsgInfo("O contrato se encontra em carência, situação não permitida para realização deste serviço.")

				DEFINE MSDIALOG oDlgCar TITLE "Dados de Carência" From 0,0 TO 160,500 PIXEL

				@ 005,005 SAY oSay1 PROMPT "Valor contrato:" SIZE 060, 007 OF oDlgCar COLORS 0, 16777215 PIXEL
				@ 005,080 SAY oSay2 PROMPT U00->U00_VALOR SIZE 060, 007 OF oDlgCar COLORS 0, 16777215 PIXEL Picture "@E 999,999,999,999.99"

				@ 018,005 SAY oSay3 PROMPT "% Carencia:" SIZE 060, 007 OF oDlgCar COLORS 0, 16777215 PIXEL
				@ 018,095 SAY oSay4 PROMPT U00->U00_CARENC SIZE 060, 007 OF oDlgCar COLORS 0, 16777215 PIXEL Picture "@E 999"

				@ 031,005 SAY oSay5 PROMPT "Valor recebido:" SIZE 060, 007 OF oDlgCar COLORS 0, 16777215 PIXEL
				@ 031,080 SAY oSay6 PROMPT nRecebido SIZE 060, 007 OF oDlgCar COLORS 0, 16777215 PIXEL Picture "@E 999,999,999,999.99"

				@ 031,140 SAY oSay7 PROMPT "% Recebido:" SIZE 060, 007 OF oDlgCar COLORS 0, 16777215 PIXEL
				@ 031,215 SAY oSay8 PROMPT nPercRecebido SIZE 060, 007 OF oDlgCar COLORS 0, 16777215 PIXEL Picture "@E 999"

				@ 044,005 SAY oSay9 PROMPT "Valor minimo a receber:" SIZE 080, 007 OF oDlgCar COLORS 0, 16777215 PIXEL
				@ 044,080 SAY oSay10 PROMPT (U00->U00_VALOR * (U00->U00_CARENC / 100)) - nRecebido SIZE 060, 007 OF oDlgCar COLORS CLR_BLUE, 16777215 PIXEL Picture "@E 999,999,999,999.99"

				@ 044,140 SAY oSay11 PROMPT "% Minimo a receber:" SIZE 060, 007 OF oDlgCar COLORS 0, 16777215 PIXEL
				@ 044,215 SAY oSay12 PROMPT U00->U00_CARENC - nPercRecebido SIZE 060, 007 OF oDlgCar COLORS CLR_BLUE, 16777215 PIXEL Picture "@E 999"

				//Linha horizontal
				@ 050, 005 SAY oSay13 PROMPT Repl("_",240) SIZE 240, 007 OF oDlgCar COLORS CLR_GRAY, 16777215 PIXEL

				//Botoes
				@ 061, 205 BUTTON oButton1 PROMPT "Ok" SIZE 040, 010 OF oDlgCar ACTION oDlgCar:End() PIXEL

				ACTIVATE MSDIALOG oDlgCar CENTERED

				lRet := .F.

			endif

		endIf

	endif

	RestArea(aAreaU00)

Return(lRet)

/*/{Protheus.doc} 
//Funcao para definicao do Modo de Edicao
dos campos de Enderecamento
@author Leandro Rodrigues
@since 16/12/2019
@version 1.0
@param Nao recebe parametros            
@return nulo
/*/

User Function UWhenFieldEnd()

	Local lRet 			:= .F.
	Local cFieldEnd		:= ReadVar()
	Local oModel 		:= FWModelActive()
	Local oModelUJV		:= oModel:GetModel( 'UJVMASTER' )
	Local cServico 		:= oModelUJV:GetValue("UJV_SERVIC")
	Local cStatus 		:= oModelUJV:GetValue("UJV_STENDE")
	Local lTransfEnd	:= FWIsInCallStack("U_PCPGA034") .Or. FWIsInCallStack("U_RCPGA34C")// quando estiver executando pela transferencia de endereco
	Local lRotAuto		:= FWIsInCallStack("U_RCPGE056")// quando estiver executando a rotina automatica

	//nao permito alterar os campos de endereco para apontamento finalizado
	if cStatus <> "E"

		// verifico se o servico esta preenchido e estou em um campo de endereco
		If !Empty(cServico) .And. AllTrim( cFieldEnd ) $ "M->UJV_QUADRA|M->UJV_CREMAT|M->UJV_OSSARI"

			SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD

			if SB1->(MsSeek(xFilial("SB1") + cServico))

				//verifico se servico selecionado exige definicao de endereco
				if !Empty(SB1->B1_XREQSER)

					//ENDERECO DE JAZIGO HABILITO O CAMPO UJV_QUADRA
					if SB1->B1_XREQSER == "J"

						lRet := .T.

						//ENDERECO DE CREMACAO HABILITO O CAMPO UJV_CREMAT
					elseif SB1->B1_XREQSER == "C"

						lRet := .T.

						//ENDERECO DE OSSARIO HABILITO O CAMPO UJV_OSSARI
					elseif SB1->B1_XREQSER == "O"

						lRet := .T.

					endif

				endif

			endif

		EndIf

	endif

	if lTransfEnd .Or. lRotAuto
		lRet	:= .T.
	endIf

Return(lRet)

/*/{Protheus.doc} 
//Funcao para filtrar produtos da tabela de preco 
do apontamento de servico
@author g.sampaio 
@since 23/01/2020
@version 1.0
@param Nao recebe parametros            
@return nulo
@history 26/05/2020, g.sampaio, VPDV-473 - Altero o sinal para quando 
comparar o DA1_DATVIG para menor igual a data base
/*/
User Function UFiltraProduto()

	Local cQry 			:= ""
	Local oModel 		:= FWModelActive()
	Local oModelUJV		:= oModel:GetModel( 'UJVMASTER' )
	Local cTabelaPreco 	:= oModelUJV:GetValue("UJV_TABPRC")

	cQry := "@"
	cQry += "EXISTS "
	cQry += " (  "
	cQry += " 	SELECT DA1_CODPRO "
	cQry += " 	FROM "
	cQry += 	RetSQLName("DA1") + " DA1 "
	cQry += " 	WHERE "
	cQry += " 	DA1.D_E_L_E_T_ = ' ' "
	cQry += " 	AND DA1.DA1_FILIAL = '" + xFilial("DA1") + "' "
	cQry += "	AND B1_COD = DA1.DA1_CODPRO "
	cQry += " 	AND DA1.DA1_DATVIG <= '" + DTOS(dDataBase) + "'  "
	cQry += " 	AND DA1.DA1_CODTAB = '" + cTabelaPreco + "' "
	cQry += " ) "

Return(cQry)


/*/{Protheus.doc} UProdUJXValida
Funcao para validar o produto 
digitado na grid de produtos/servicos
adicionais do apontamento de servico
@type function
@version 
@author g.sampaio
@since 10/12/2020
@return return_type, return_description
/*/
User Function UProdUJXValida()

	Local aArea 		:= GetArea()
	Local lRet 			:= .T.
	Local oView			:= FWViewActive()
	Local oModel 		:= FWModelActive()
	Local oModelUJV		:= oModel:GetModel( 'UJVMASTER' )
	Local oModelUJX		:= oModel:GetModel( 'UJXDETAIL' )
	Local cTabelaPreco 	:= oModelUJV:GetValue("UJV_TABPRC")
	Local cServico		:= oModelUJX:GetValue("UJX_SERVIC")
	Local lValServAdic	:= SuperGetMV("MV_XSVADIC",.F.,.T.) // parametro para validar se o produto controla endereço
	Local nPreco		:= 0

	SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD

	if !Empty(cServico)

		// verifico se o servico ja esta preenchido no apontamento
		if AllTrim(cServico) == Alltrim(oModelUJV:GetValue("UJV_SERVIC"))

			lRet := .F.
			Help( ,, 'Help',, 'Não é permitido a inclusão nos Produtos/Serviços adicionais, o mesmo serviço já utilizado no apontamento de seviços! [' + Alltrim(oModelUJV:GetValue("UJV_SERVIC"));
				+ '-' + Posicione("SB1",1,xFilial("SB1")+oModelUJV:GetValue("UJV_SERVIC"),"B1_DESC") + ']' , 1, 0 )

		endIf

		// verifico se está tudo certo até aqui
		if lRet

			//valido se o produto existe
			if SB1->(MsSeek(xFilial("SB1")+ cServico))

				// verifico se o produto tem controle de endereco
				if lValServAdic .And. !Empty(SB1->B1_XREQSER)

					lRet := .F.
					Help( ,, 'Help',, 'Não é permitido o uso de serviços com controle de endereço nos itens Produtos/Serviços adicionais do apontamento de seviços! [' + SB1->B1_COD + '-' + SB1->B1_DESC + ']', 1, 0 )

				else
					if (nPreco := U_RetPrecoVenda(cTabelaPreco,cServico)) > 0

						FwFldPut("UJX_DESCRI"	, Alltrim(SB1->B1_DESC) ,,,,.F.)
						FwFldPut("UJX_QTDE"		, 1 ,,,,.T.)
						FwFldPut("UJX_VLUNIT"	, nPreco,,,,.F.)
						FwFldPut("UJX_VALOR"	, nPreco ,,,,.F.)

					else
						lRet := .F.
					endif
				endIf

			else

				lRet := .F.
				Help( ,, 'Help',, 'Produto digitado é inválido, verifique o cadastro de produtos!', 1, 0 )

			endif

		endIf
	else

		FwFldPut("UJX_DESCRI"	, "" ,,,,.F.)
		FwFldPut("UJX_QTDE"		, 0	 ,,,,.T.)
		FwFldPut("UJX_VLUNIT"	, 0  ,,,,.F.)
		FwFldPut("UJX_VALOR"	, 0  ,,,,.F.)

	endif

	if oView <> NIL

		//Atualiza os totalizadores
		oOSTotais:RefreshTot()

	endif

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} 
//Funcao para validar a quantidade digitada
adicionais do apontamento de servico
@author g.sampaio 
@since 23/01/2020
@version 1.0
@param Nao recebe parametros            
@return nulo
/*/
User Function UQuantUJXValida()

	Local aArea 			:= GetArea()
	Local lRet				:= .T.
	Local oView				:= FWViewActive()
	Local oModel 			:= FWModelActive()
	Local oModelUJX			:= oModel:GetModel( 'UJXDETAIL' )
	Local nQuantidade		:= oModelUJX:GetValue("UJX_QTDE")
	Local nUnitarioValor	:= oModelUJX:GetValue("UJX_VLUNIT")
	Local nVlrTotal			:= 0

	if nQuantidade > 0

		nVlrTotal := nQuantidade * nUnitarioValor

		FwFldPut("UJX_VALOR"	, nVlrTotal ,,,,.F.)

		if oView <> NIL

			//Atualiza os totalizadores
			oOSTotais:RefreshTot()

		endif

	else

		lRet := .F.
		Help( ,, 'Help',, 'Quantidade digitada deve ser superior a 0.', 1, 0 )


	endif

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} EditGrid
Funcao para validar a delecao e restauracao
da linha da tabelas UJX - Utilizada para
reprocessar o valor liquido do contrato
@author g.sampaio
@since 23/01/2020
@version P12
@return nPreco - Preco de Venda da Tabela
/*/
Static Function EditGrid(oModelGrid,nLinha,cAcao,cCampo)

	Local lRet := .T.

	if cAcao == 'DELETE' .Or. cAcao == 'UNDELETE'

		oOsTotais:RefreshTot(cAcao,nLinha)

	endif

Return(lRet)


/*/{Protheus.doc} RetTotalPagoContrato
Funcao para consultar o total pago do contrato
@type function
@version 1.0
@author g.sampaio
@since 24/09/2021
@param cContrato, character, codigo do contrato
@return numeric, retorna o valor pago para o contrato
/*/
Static Function RetTotalPagoContrato(cContrato)

	Local nTotal := 0
	Local cQuery 	 := ""

	cQuery := " SELECT "
	cQuery += " SUM(SE5.E5_VALOR) TOTAL_PAGO "
	cQuery += " FROM " + RetSqlName("SE5") + " SE5 "
	cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 ON SE1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SE1.E1_FILIAL 	= '" + xFilial("SE1") + "' "
	cQuery += " AND SE1.E1_PREFIXO 	= SE5.E5_PREFIXO "
	cQuery += " AND SE1.E1_NUM 		= SE5.E5_NUMERO "
	cQuery += " AND SE1.E1_PARCELA 	= SE5.E5_PARCELA "
	cQuery += " AND SE1.E1_TIPO 	= SE5.E5_TIPO "
	cQuery += " AND SE1.E1_XCONTRA = '" + cContrato + "' ""
	cQuery += " WHERE SE5.D_E_L_E_T_ = ' ' "
	cQuery += " AND SE5.E5_FILIAL = '" + xFilial("SE5") + "' "
	cQuery += " AND SE5.E5_RECPAG = 'R' "
	cQuery += " AND SE5.E5_TIPODOC <> 'ES' "
	cQuery += " AND SE5.E5_SITUACA <> 'C' "
	cQuery += " AND ( (SE5.E5_TIPODOC IN ('VL','CP') AND SE5.E5_MOTBX IN ('NOR','CMP') AND SE5.E5_ORIGEM <> 'LOJXREC' ) "
	cQuery += " OR (SE5.E5_TIPODOC = 'BA' AND SE5.E5_MOTBX <> 'LIQ') ) "
	cQuery += " AND SE5.E5_TIPODOC NOT IN ('MT','JR','ES','M2','J2','IB','AP','BL','C2','CB','CM','D2','DC','DV','NCC','SG','TC') "

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery( cQuery, "QRYTIT" )

	nTotal := QRYTIT->TOTAL_PAGO

Return(nTotal)

/*/{Protheus.doc} RCPGA39LEG
Funcao de legenda do apontamento de serviços
@author g.sampaio
@since 23/01/2020
@version P12
@return 
/*/
User Function RCPGA39LEG()

	BrwLegenda("Status do Apontamento","Legenda",{;
		{"BR_AMARELO","Em Execução / Sem Endereço"},;
		{"BR_LARANJA","Em Execução / Endreço Reservado"},;
		{"BR_VERDE","Em Execução / Endreço Efetivado"},;
		{"BR_AZUL","Finalizada / Faturamento Parcial"},;
		{"BR_PINK","Finalizada / Sem Faturamento"},;
		{"BR_MARROM","Finalizada / Sem Endereço"},;
		{"BR_VERMELHO","Finalizado"}})

Return(Nil)

/*/{Protheus.doc} UObitoSalaVelorio
Funcao para Preencher o nome do obito na sala 
de velorio 
@author g.sampaio
@since 24/01/2020
@version P12
@return 
/*/
User Function UObitoSalaVelorio()

	Local cNomeObito		:= ""
	Local lRet 				:= .T.
	Local oModel 			:= FWModelActive()
	Local oModelUJV			:= NIL
	Local oModelU25			:= NIL

	oModelUJV	:= oModel:GetModel( 'UJVMASTER' )
	oModelU25	:= oModel:GetModel( 'U25DETAIL' )
	cNomeObito	:= oModelUJV:GetValue("UJV_NOME")

	//se estiver preenchido
	if !Empty(Alltrim(cNomeObito))

		FwFldPut("U25_NOMOBT"	, Alltrim(cNomeObito) ,,,,.T.)

	endif

Return(lRet)

/*/{Protheus.doc} UConfEndereco
Funcao para efetivar o enderecamento na U04 (Enderecamento)
@author g.sampaio
@since 24/01/2020
@version P12
@return 
/*/
User Function UConfEndereco( cApontamento, cContrato, cMsgRet )

	Local aArea 			:= GetArea()
	Local aAreaU00			:= U04->(GetArea())
	Local aAreaU04			:= U04->(GetArea())
	Local aAreaUJV			:= UJV->(GetArea())
	Local cNextU04			:= ""
	Local dDataPrevio		:= stod("")
	Local lRet 				:= .T.
	Local lIncluiU04		:= .T.
	Local lLocNicho			:= .T.
	Local lPrevio			:= .F.
	Local lAtivaRegra	    := SuperGetMv("MV_XREGCEM",,.F.)	// parametro para ativacao da regra
	Local lAtivJazOssi  	:= SuperGetMV("MV_XJAZOSS",,.F.)
	Local nAnosExu			:= SuperGetMv("MV_XANOSEX",.F.,5)
	Local oRegraManutencao	:= Nil

	Default cApontamento	:= ""
	Default cContrato		:= ""
	Default cMsgRet			:= ""

	UJV->(DbSetOrder(1)) //UJV_FILIAL + UJV_CODIGO
	U37->(DbSetOrder(2)) //U37_FILIAL + U37_CODIGO + U37_SERVIC

	// posiciono na UJV
	if UJV->(MsSeek(xFilial("UJV") + cApontamento ))

		U00->(DbSetOrder(1))
		If U00->(MsSeek(xFilial("U00")+UJV->UJV_CONTRA))

			// verifico se o enedereco nao esta efetivado
			if UJV->UJV_STENDE <> "E"

				if !Empty(UJV->UJV_QUADRA) .Or. !Empty(UJV->UJV_CREMAT) .Or. !Empty(UJV->UJV_OSSARI)

					SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD

					if SB1->(MsSeek(xFilial("SB1") + UJV->UJV_SERVIC))

						if U37->(MsSeek(xFilial("U37")+ cContrato + UJV->UJV_SERVIC ))

							//Retorno o proximo item da U04
							cNextU04 := U_NextU04(cContrato)

							//verifico se servico selecionado exige definicao de endereco
							if !Empty(SB1->B1_XREQSER)

								//valido se o endereco selecionado possui enderecamento previo d
								if SB1->B1_XREQSER == "J" .Or. SB1->B1_XREQSER == "O"

									nRegistro := U_PosPrevio(cContrato,UJV->UJV_QUADRA,UJV->UJV_MODULO,UJV->UJV_JAZIGO,;
										UJV->UJV_OSSARI,UJV->UJV_NICHOO)

									//caso possua enderecamento previo apenas atualizo o registro da U04
									if nRegistro > 0

										U04->( DbGoTo(nRegistro) )

										if UJV->UJV_GAVETA == U04->U04_GAVETA .Or.;
												UJV->UJV_NICHOO == U04->U04_NICHOO
											cNextU04 	:= U04->U04_ITEM
											lIncluiU04	:= .F.
										endIf

										if U04->U04_PREVIO == 'S'
											dDataPrevio	:= U04->U04_DATA
											lPrevio 	:= .T.
										endIf

									endif

								endif

								BEGIN TRANSACTION

									// altero as informacoes do endereco
									RecLock("U04",lIncluiU04)
									U04->U04_FILIAL := xFilial("U04")
									U04->U04_CODIGO := UJV->UJV_CONTRA
									U04->U04_ITEM	:= cNextU04
									U04->U04_DTUTIL	:= UJV->UJV_DTSEPU
									U04->U04_QUEMUT	:= UJV->UJV_NOME
									U04->U04_APONTA	:= UJV->UJV_CODIGO

									// caso for uma nova inclusao
									if !lPrevio
										U04->U04_DATA	:= dDatabase
										U04->U04_PREVIO	:= "N"
									elseIf lPrevio .And. lIncluiU04
										U04->U04_DATA	:= dDataPrevio
										U04->U04_PREVIO	:= "S"
									endIf

									///////////////////////////////////////////////////////
									///////// 		ENDERECO DE GAVETA			///////////
									///////////////////////////////////////////////////////
									if SB1->B1_XREQSER == "J"

										U04->U04_TIPO	:= "J"
										U04->U04_QUADRA := UJV->UJV_QUADRA
										U04->U04_MODULO := UJV->UJV_MODULO
										U04->U04_JAZIGO := UJV->UJV_JAZIGO
										U04->U04_GAVETA := UJV->UJV_GAVETA
										U04->U04_LOCACA	:= SB1->B1_XLOCACA

										U04->U04_OCUPAG	:= SB1->B1_XOCUGAV

										//ocupa gaveta
										if SB1->B1_XOCUGAV == 'S'

											U04->U04_OCUPAG := SB1->B1_XOCUGAV
											U04->U04_PRZEXU	:= YearSum(UJV->UJV_DTSEPU,nAnosExu)

										else

											U04->U04_PRZEXU	:= UJV->UJV_DTSEPU

										endif

										///////////////////////////////////////////////////////
										///////// 		ENDERECO DE CREMACAO		///////////
										///////////////////////////////////////////////////////
									elseif SB1->B1_XREQSER == "C"

										U04->U04_TIPO	:= "C"
										U04->U04_CREMAT := UJV->UJV_CREMAT
										U04->U04_NICHOC	:= UJV->UJV_NICHOC

										///////////////////////////////////////////////////////
										///////// 		ENDERECO DE CREMACAO		///////////
										///////////////////////////////////////////////////////
									elseif SB1->B1_XREQSER == "O"

										U04->U04_TIPO	:= "O"
										U04->U04_OSSARI := UJV->UJV_OSSARI
										U04->U04_NICHOO	:= UJV->UJV_NICHOO

										// verifico se os campos de lacre existem
										if U04->(FieldPos("U04_LACOSS")) > 0 .And. UJV->(FieldPos("UJV_LACOSS")) > 0
											U04->U04_LACOSS	:= UJV->UJV_LACOSS
										endIf

										// verifico se tem o jazigo com ossario ativado
										if lAtivJazOssi

											U13->(DbSetOrder(1))
											if U13->(MsSeek(xFilial("U13")+UJV->UJV_OSSARI))

												if !Empty(U13->U13_QUADRA)
													U04->U04_QUADRA := U13->U13_QUADRA
													U04->U04_MODULO := U13->U13_MODULO
													U04->U04_JAZIGO := U13->U13_JAZIGO
												endIf

											endIf

										endIf

									endif

									U04->(MsUnlock())

									// altero as informacoes do apontamento
									RecLock("UJV",.F.)

									UJV->UJV_STENDE := "E"	// endereco efetivado

									//finalizo o apontamento
									if !Empty(UJV->UJV_PEDIDO)

										UJV->UJV_STATUS := "F"

									endif

									UJV->(MsUnlock())

									If !FWIsInCallStack("U_RIMPM003") //-- Importacao Enderecamento

										// se for ossario
										If lRet .And. !Empty(UJV->UJV_OSSARI) .And. Inclui

											// valido se o tipo de endereco e ossario e pergunto ao usuario se deseja gerar a taxa de locacao do nicho
											If SB1->B1_XREQSER == "O" .And. MsgYesNo("Deseja gerar a taxa de locacao do nicho ossuário para o apontamento?")

												// crio as informacoes da locacao do nicho ossuario
												lLocNicho := U_RCPGE031( cContrato )

												// verifico se a locacao de nicho gerou corretamente
												If lLocNicho

													// mensagem para o usuario
													MsgInfo("Taxa de locação de nicho gerada com sucesso!")

												Else

													// mensagem para o usuario
													MsgAlert('Não foi possível gerar a taxa de locação de nicho pelo apontamento,';
														+ 'tente gerar a taxa de locação para contrato manualmente!')

												EndIf

											EndIf

										elseIf lRet .And. lAtivaRegra .And. !Empty(Alltrim(UJV->UJV_JAZIGO)) // verifico se e jazigo e utilizo regra

											// inicio o ojeto de Regras de Manutencao
											oRegraManutencao    := RegraTaxaManutencao():New( U00->U00_REGRA, "E" )

											// caso tenha regra de taxa de manutencao preenchida no contrato0
											if oRegraManutencao:lTemRegra .And. !oRegraManutencao:ExisteManutencao( UJV->UJV_CONTRA )

												// vou validar a execucao do contrato
												// mensagem de processamento para o usuario
												FWMsgRun(,{|oSay| lRet := oRegraManutencao:ValidaRegra( UJV->UJV_CONTRA, Nil, .T. ) },"Aguarde","Gerando Taxa de Manutenção na efetivação do endereçamento do apontamento de serviços do contrato...")

											endIf

											if !lRet
												Help( ,, 'Help - Regras de Manutenção',, 'Não foi possível gerar a taxa de manutenção no endereçamento do apontamento de serviços, revise às regras de manutenção e as informações do contrato', 1, 0 )
											EndIf

											// fecho objeto
											FreeObj(oRegraManutencao)
											oRegraManutencao := Nil

										EndIf

									EndIf

									if !lRet
										DisarmTransaction()
										BREAK
									endif

								END TRANSACTION

								If !FWIsInCallStack("U_RIMPM003") //-- Importacao Enderecamento
									MsgInfo("Endereçamento efetivado com sucesso!")
								else
									cMsgRet := "Endereçamento efetivado com sucesso!"
								EndIf

							endif

							//caso o servico controle saldo, debito o saldo do contrato
							if U37->U37_CTRSLD == "S"

								RecLock("U37",.F.)

								U37->U37_SALDO -= 1

								U37->(MsUnlock())

							endif

						else

							lRet := .F.
							If !FWIsInCallStack("U_RIMPM003") //-- Importacao Enderecamento
								Help( ,, 'Help',, 'Serviço não habilito para o contrato, favor verifique o mesmo!', 1, 0 )
							else
								cMsgRet := "Serviço não habilito para o contrato, favor verifique o mesmo!"
							EndIf

						endif

					else

						lRet := .F.
						If !FWIsInCallStack("U_RIMPM003") //-- Importacao Enderecamento
							Help( ,, 'Help',, 'Serviço não encontrado, favor verifique o mesmo!', 1, 0 )
						else
							cMsgRet := "Serviço não encontrado, favor verifique o mesmo!"
						EndIf

					endif

				else

					lRet := .F.
					If !FWIsInCallStack("U_RIMPM003") //-- Importacao Enderecamento
						Help( ,, 'Help',, 'Apontamento não possui endereço definido, não é possivel efetivar!', 1, 0 )
					else
						cMsgRet := "Apontamento não possui endereço definido, não é possivel efetivar!"
					EndIf

				endif

			else

				lRet := .F.

				If !FWIsInCallStack("U_RIMPM003") //-- Importacao Enderecamento
					Help( ,, 'Help',, 'Apontamento já possui endereçamento efetivado!', 1, 0 )
				else
					cMsgRet := "Apontamento já possui endereçamento efetivado!"
				EndIf

			endif

		EndIf

	else

		lRet := .F.
		If !FWIsInCallStack("U_RIMPM003") //-- Importacao Enderecamento
			Help( ,, 'Help',, 'Apontamento não encontrado, favor verifique o mesmo!', 1, 0 )
		else
			cMsgRet := "Apontamento não encontrado, favor verifique o mesmo!"
		EndIf

	endif

	RestArea(aAreaU04)
	RestArea(aAreaU00)
	RestArea(aAreaUJV)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} UExcluiEndereco
Funcao para excluir o enderecamento na U04 (Enderecamento)
@author g.sampaio
@since 24/01/2020
@version P12
@return 
/*/

User Function UExcluiEndereco(cApontamento)

	Local aArea 			:= GetArea()
	Local aAreaU04			:= U04->(GetArea())
	Local cQuery			:= ""
	Local lAtivaRegra	    := SuperGetMv("MV_XREGCEM",,.F.)	// parametro para ativacao da regra
	Local lRetorno 			:= .T.

	UJV->(DbSetOrder(1)) //UJV_FILIAL + UJV_CODIGO
	U04->(DbSetOrder(5)) //U04_FILIAL + U04_APONTA

	if UJV->(MsSeek(xFilial("UJV") + cApontamento ))

		// verifico se o campo de origem do apontamento existe
		if UJV->(FieldPos("UJV_ORIGEM")) > 0

			// caso a origem do apontamento for da transferencia de enderecos
			if AllTrim(UJV->UJV_ORIGEM) == "RCPGA034"
				lRetorno := .F.
				Help( ,, 'Help',, 'O Apontamento foi gerado pela rotina de transferência de endereçamento, operação não permitida!', 1, 0 )
			endIf

		endIf

		// verifico se é endereco de cremacao ou ossario
		if lRetorno .And. (!Empty(UJV->UJV_CREMAT) .Or. !Empty(UJV->UJV_OSSARI))

			if Select("TRBLOC") > 0
				TRBLOC->( DbCloseArea() )
			endIf

			// query para retornar a quantidade de parcelas para a locacao do nicho para o contrato
			cQuery := " SELECT U75.U75_PARCEL, U74.R_E_C_N_O_ RECU74, U75.R_E_C_N_O_ RECU75, SE1.R_E_C_N_O_ RECSE1 "
			cQuery += " FROM " + RetSQLName("U74") + " U74 "
			cQuery += " INNER JOIN " + RetSQLName("U75") + " U75 ON U75.D_E_L_E_T_ = ' ' "
			cQuery += " AND U75.U75_FILIAL	= '" + xFilial("SE1") + "'	"
			cQuery += " AND U75.U75_CODIGO = U74.U74_CODIGO "
			cQuery += " INNER JOIN " + RetSQLName("SE1") + " SE1 ON SE1.D_E_L_E_T_ = ' ' "
			cQuery += " AND SE1.E1_FILIAL	    = '" + xFilial("SE1") + "'	"
			cQuery += " AND SE1.E1_PREFIXO  	= U75.U75_PREFIX "
			cQuery += " AND SE1.E1_NUM		    = U75.U75_NUM "
			cQuery += " AND SE1.E1_PARCELA	    = U75.U75_PARCEL "
			cQuery += " AND SE1.E1_TIPO		    = U75.U75_TIPO "
			cQuery += " WHERE U74.D_E_L_E_T_    = ' ' "
			cQuery += " AND U74.U74_CONTRA      = '"+ UJV->UJV_CONTRA + "'"

			if !Empty(UJV->UJV_CREMAT) // crematorio
				cQuery += " AND U74.U74_TPEND       = 'C'"
				cQuery += " AND U74.U74_CREMOS      = '"+ UJV->UJV_CREMAT + "'"
				cQuery += " AND U74.U74_NICHO       = '"+ UJV->UJV_NICHOC+ "'"
			elseif !Empty(UJV->UJV_OSSARI) // ossario
				cQuery += " AND U74.U74_TPEND       = 'O'"
				cQuery += " AND U74.U74_CREMOS      = '"+ UJV->UJV_OSSARI + "'"
				cQuery += " AND U74.U74_NICHO       = '"+ UJV->UJV_NICHOO + "'"
			endIf

			cQuery += " AND U74.U74_STATUS      = '1'"
			cQuery += " ORDER BY U75.U75_PARCEL DESC"

			cQuery := ChangeQuery(cQuery)

			MPSysOpenQuery(cQuery, "TRBLOC")

			if TRBLOC->(!Eof())
				lRetorno := .F.
				Help( ,, 'Help',, 'Endereço vinculado a Locação de Nicho, operação não permitida!', 1, 0 )
			endIf

			if Select("TRBLOC") > 0
				TRBLOC->( DbCloseArea() )
			endIf

		endif

		// verifico se esta tudo certo e devo continuar
		if lRetorno

			if MsgYesNo("Deseja Excluir o Endereçamento do Contrato?")

				if U04->(MsSeek(xFilial("U04")+cApontamento))

					RecLock("U04",.F.)
					U04->(DbDelete())
					U04->(MsUnlock())

					RecLock("UJV",.F.)

					UJV->UJV_STENDE := "R"
					UJV->UJV_STATUS := "E"

					UJV->(MsUnlock())

					// verifico se utilizo regra de contrato
					if lAtivaRegra // verifico se e jazigo e utilizo regra

						// inicio o ojeto de Regras de Manutencao
						oRegraManutencao    := RegraTaxaManutencao():New( "", "E" )

						// caso tenha regra de taxa de manutencao preenchida no contrato
						if oRegraManutencao:ValidaManutencao( UJV->UJV_CONTRA )

							// vou validar a execucao do contrato
							oRegraManutencao:ExcluiManutencao( UJV->UJV_DTSEPU, UJV->UJV_DTSEPU, UJV->UJV_CONTRA, UJV->UJV_CONTRA, "", "", "E" )

						endIf

						// fecho objeto
						FreeObj(oRegraManutencao)
						oRegraManutencao := Nil

					EndIf

					MsgInfo("Endereçamento excluído com sucesso!")

				else

					lRetorno := .F.
					Help( ,, 'Help',, 'Enderecamento não encontrado, verifique a rotina de transferência!', 1, 0 )

				endif

			endIf

		endif

	endif

	RestArea(aArea)
	RestArea(aAreaU04)

Return(lRetorno)


/*/{Protheus.doc} RCPGA39A
Funcao para gerar o pedido de venda
do apontamento - Chama a funcao
UGeraPedidoApontamento
@author g.sampaio 
@since 24/01/2020
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RCPGA39A()

	Local cTipoServico		:= SuperGetMv("MV_XTPSERC",.F.,"1") // 1 - Faturamento Comum // 2 - Faturamento com Tipo de Servico x Filial // 3 - multifaturamento
	Local lFatAptTransf		:= SuperGetMV("MV_XFTAPTR",.F.,.F.)
	Local lRetorno 			:= .T.

	// verifico se o campo de origem do apontamento existe
	if UJV->(FieldPos("UJV_ORIGEM")) > 0

		// caso a origem do apontamento for da transferencia de enderecos
		if !lFatAptTransf .And. AllTrim(UJV->UJV_ORIGEM) == "RCPGA034"
			lRetorno := .F.
			Help( ,, 'Help',, 'O Apontamento foi gerado pela rotina de transferência de endereçamento, operação não permitida!', 1, 0 )
		endIf

	endIf

	// verifico se esta tudo certo para continuar
	if lRetorno

		If cTipoServico <> "3"

			if Empty(UJV->UJV_PEDIDO)

				if !Empty(UJV->UJV_CLIENT) .And. !Empty(UJV->UJV_LOJA) .And. !Empty(UJV->UJV_CONDPG)

					if MsgYesNo("Deseja Gerar o Pedido de Venda do Apontamento selecionado!")

						FWMsgRun(,{|oSay| lRetorno := UGeraPedidoApontamento(UJV->UJV_CODIGO)},'Aguarde...','Gerando Pedido de Venda do Apontamento!')

					endif

				else

					lRetorno := .F.
					Help( ,, 'Help',, 'Favor preencher os campos de cliente e condição de pagamento para geração do pedido!', 1, 0 )


				endif
			else

				lRetorno := .F.
				Help( ,, 'Help',, 'Apontamento selecionado já possui pedido de venda relacionado!', 1, 0 )

			endif

		Else

			FWMsgRun(,{|oSay| lRetorno := UGeraPedidoApontamento(UJV->UJV_CODIGO)},'Aguarde...','Gerando Pedido de Venda do Apontamento!')

		EndIf

		// caso for possivel faturar o apontamento de servicos gerado pela transferncia de endereco
		If lRetorno .And. lFatAptTransf .And. AllTrim(UJV->UJV_ORIGEM) == "RCPGA034"
			AtuTransfFaturamento(UJV->UJV_CODIGO)
		EndIf

	endIf

Return(lRetorno)

/*/{Protheus.doc} UGeraPedidoApontamento
Funcao para Gerar o Pedido de Venda
do Apontamento Cemiterio
@author g.sampaio 
@since 24/01/2020
@version P12
@param Nao recebe parametros
@return nulo
/*/

Static Function UGeraPedidoApontamento(cApontamento)

	Local aArea 			:= GetArea()
	Local aAreaU00			:= U00->(GetArea())
	Local aAreaUJV			:= UJV->(GetArea())
	Local aCab				:= {}
	Local aItem				:= {}
	Local aDados			:= {}
	Local aPEAPTC5CEM		:= {}
	Local aPEAPTC6CEM		:= {}
	Local cSVOperacao		:= SuperGetMv("MV_XOPERCE",.F.,"07")
	Local cPrdcOperacao		:= SuperGetMv("MV_XOPERPR",.F.,"07")
	Local cNatureza			:= SuperGetMv("MV_XNATAPC",.F.,"OUTROS")
	Local cTipoServico		:= SuperGetMv("MV_XTPSERC",.F.,"1") // 1 - Faturamento Comum // 2 - Faturamento com Tipo de Servico x Filial // 3 - multifaturamento
	Local cOperacaoFiscal	:= ""
	Local cItemC6			:= ""
	Local lRet				:= .T.
	Local nPrecoItem		:= 0
	Local nItemPedido		:= 0
	Local nDesconto			:= 0 //valor do desconto (UJV_DESCON), que será rateado entre os itens
	Local nTotPedido 		:= 0
	Local nSalDesco			:= 0
	Local nQtdItens			:= 0 //controla a quantidade de itens adicionais
	Local nI 				:= 0

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	UJV->(DbSetOrder(1)) //UJV_FILIAL + UJV_CODIGO
	UJX->(DbSetOrder(1)) //UJX_FILIAL + UJX_CODIGO
	SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD

	BEGIN TRANSACTION

		if UJV->(MsSeek(xFilial("UJV") + cApontamento ))

			if cTipoServico == "1" // faturamento comum

				if UJV->(FieldPos("UJV_DESCON")) > 0
					nDesconto := UJV->UJV_DESCON
					nSalDesco := nDesconto
				endif

				if nDesconto > 0
					nTotPedido += U_RetPrecoVenda(UJV->UJV_TABPRC,UJV->UJV_SERVIC)
					if UJX->(MsSeek(xFilial("UJV")+cApontamento))
						While UJX->(!Eof()) .And. UJX->UJX_FILIAL == xFilial("UJX") .And. UJX->UJX_CODIGO == cApontamento
							SB1->(DbSetOrder(1))
							if SB1->(MsSeek(xFilial("SB1")+UJX->UJX_SERVIC))
								nTotPedido += UJX->UJX_VLUNIT
								nQtdItens++ //qtd itens adicionais (UJX)
							endif
							UJX->(DbSkip())
						End
					endif
					UJX->(DbGoTop())
				endif

				//valido a natureza do produto apontado
				SB1->(DbSetOrder(1))
				if SB1->(MsSeek(xFilial("SB1") + UJV->UJV_SERVIC )) .And. !Empty(SB1->B1_XNATURE)
					cNatureza := SB1->B1_XNATURE
				endif

				AAdd(aCab, {"C5_TIPO" 		, "N" 				,Nil})
				AAdd(aCab, {"C5_CLIENTE" 	, UJV->UJV_CLIENT 	,Nil})
				AAdd(aCab, {"C5_LOJACLI" 	, UJV->UJV_LOJA	 	,Nil})
				AAdd(aCab, {"C5_CONDPAG" 	, UJV->UJV_CONDPG	,Nil})
				AAdd(aCab, {"C5_XMENNFS"	, UJV->UJV_MENNFS	,Nil})
				AAdd(aCab, {"C5_TABELA" 	, UJV->UJV_TABPRC	,Nil})
				AAdd(aCab, {"C5_EMISSAO" 	, dDataBase 		,Nil})
				AAdd(aCab, {"C5_MOEDA" 		, 1 				,Nil})
				AAdd(aCab, {"C5_NATUREZ" 	, cNatureza	 		,Nil})
				AAdd(aCab, {"C5_XCONTRA"	, UJV->UJV_CONTRA	,Nil})
				AAdd(aCab, {"C5_XAPONTC"	, cApontamento		,Nil})
				AAdd(aCab, {"C5_XATENDE"	, UJV->UJV_USRATE	,Nil})
				AAdd(aCab, {"C5_XNOMEFA"	, UJV->UJV_NOME		,Nil})

				// customiacao do cacalho do Pedido de Vendas
				If ExistBlock("PEAPTC5CEM")
					aPEAPTC5CEM := ExecBlock("PEAPTC5CEM", .F., .F.)
					If Len(aPEAPTC5CEM) > 0
						For nI := 1 to Len(aPEAPTC5CEM)
							aAdd(aCab,{aPEAPTC5CEM[nI, 1], aPEAPTC5CEM[nI, 2], aPEAPTC5CEM[nI, 3]})
						Next nI
					EndIf
				EndIf

				//valido se possui servico principal
				if !Empty(UJV->UJV_SERVIC)

					nItemPedido++

					cItemC6	:= StrZero(nItemPedido,TamSX3("C6_ITEM")[1])

					//retorna o preco do item de acordo com a tabela de preco do apontamento
					nPrecoItem	:= U_RetPrecoVenda(UJV->UJV_TABPRC,UJV->UJV_SERVIC)
					if nDesconto > 0
						nPrecoItem := nPrecoItem - Round(nPrecoItem/nTotPedido * nDesconto, 2)
						nSalDesco -= Round(nPrecoItem/nTotPedido * nDesconto, 2)
					endif

					aItem := {}

					AAdd(aItem,{"C6_ITEM" 		, cItemC6			,Nil})
					AAdd(aItem,{"C6_PRODUTO" 	, UJV->UJV_SERVIC 	,Nil})
					AAdd(aItem,{"C6_QTDVEN" 	, 1					,Nil})
					AAdd(aItem,{"C6_PRCVEN" 	, nPrecoItem		,Nil})
					if nDesconto > 0
						AAdd(aItem,{"C6_PRUNIT" 	, nPrecoItem		,Nil})
					endif
					AAdd(aItem,{"C6_OPER" 		, cSVOperacao		,Nil})

					If ExistBlock("PEAPTC6CEM")
						aPEAPTC6CEM := ExecBlock("PEAPTC6CEM", .F., .F.)
						If Len(aPEAPTC6CEM) > 0
							For nI := 1 to Len(aPEAPTC6CEM)
								aAdd(aItem,{aPEAPTC6CEM[nI, 1], aPEAPTC6CEM[nI, 2], aPEAPTC6CEM[nI, 3]})
							Next nI
						EndIf
					EndIf

				endif

				If Len(aItem) > 0
					AAdd(aDados,aItem)
				EndIf

				//verifico se possui itens no apontamento para envio no pedido
				if UJX->(MsSeek(xFilial("UJV")+cApontamento))

					While UJX->(!Eof()) .And. UJX->UJX_FILIAL == xFilial("UJX") .And. UJX->UJX_CODIGO == cApontamento

						SB1->(DbSetOrder(1))

						if SB1->(MsSeek(xFilial("SB1")+UJX->UJX_SERVIC))

							aItem := {}
							nItemPedido++
							cItemC6	:= StrZero(nItemPedido,TamSX3("C6_ITEM")[1])

							//valido a operacao fiscal que sera gerado o item
							if SB1->B1_TIPO == 'SV'
								cOperacaoFiscal := cSVOperacao
							else
								cOperacaoFiscal := cPrdcOperacao
							endif

							AAdd(aItem,{"C6_ITEM" 		, cItemC6			,Nil})
							AAdd(aItem,{"C6_PRODUTO" 	, UJX->UJX_SERVIC 	,Nil})
							AAdd(aItem,{"C6_QTDVEN" 	, UJX->UJX_QTDE		,Nil})
							if nDesconto > 0
								if (nSalDesco < Round(UJX->UJX_VLUNIT/nTotPedido * nDesconto, 2)) .or. (nQtdItens <= 1)
									nPrecoItem := (UJX->UJX_VLUNIT - nSalDesco)
									nSalDesco -= nSalDesco
								else
									nPrecoItem := (UJX->UJX_VLUNIT - Round(UJX->UJX_VLUNIT/nTotPedido * nDesconto, 2))
									nSalDesco -= Round(UJX->UJX_VLUNIT/nTotPedido * nDesconto, 2)
								endif
								nQtdItens-- //qtd itens adicionais (UJX)
								AAdd(aItem,{"C6_PRCVEN" 	, nPrecoItem	,Nil})
								AAdd(aItem,{"C6_PRUNIT" 	, nPrecoItem	,Nil})
							else
								AAdd(aItem,{"C6_PRCVEN" 	, UJX->UJX_VLUNIT	,Nil})
							endif
							AAdd(aItem,{"C6_OPER" 		, cOperacaoFiscal	,Nil})

						endif

						If ExistBlock("PEAPTC6CEM")
							aPEAPTC6CEM := ExecBlock("PEAPTC6CEM", .F., .F.)
							If Len(aPEAPTC6CEM) > 0
								For nI := 1 to Len(aPEAPTC6CEM)
									aAdd(aItem,{aPEAPTC6CEM[nI, 1], aPEAPTC6CEM[nI, 2], aPEAPTC6CEM[nI, 3]})
								Next nI
							EndIf
						EndIf

						If Len(aItem) > 0
							AAdd(aDados,aItem)
						EndIf

						UJX->(DbSkip())
					EndDo

				endif

				MSExecAuto({|X,Y,Z|Mata410(X,Y,Z)},aCab,aDados,3)

				If lMsErroAuto
					lRet := .F.
					MostraErro()
					DisarmTransaction()
				Else
					MsgInfo("Pedido de Venda <"+AllTrim(SC5->C5_NUM)+"> gerado com sucesso.","Atenção")
				EndIf

			ElseIf cTipoServico == "2" // Faturamento com Tipo de Servico x Filial
				lRet := GeraPVTipoServico()
			ElseIf cTipoServico == "3" // multi-faturamento
				lRet := GeraMultiFaturamento(UJV->UJV_CODIGO)
			endif

			if lRet
				RecLock("UJV",.F.)

				If cTipoServico <> "3"
					UJV->UJV_PEDIDO := SC5->C5_NUM
				EndIf

				//caso o enderecamento esteja efetivado, finalizo o apontamento
				if UJV->UJV_STENDE == "E" .Or. (Empty(UJV->UJV_QUADRA) .And. Empty(UJV->UJV_CREMAT) .And. Empty(UJV->UJV_OSSARI) )
					UJV->UJV_STATUS := "F"
				endif

				UJV->(MsUnlock())
			endif

		else

			lRet := .F.
			Help( ,, 'Help',, 'Apontamento não encontrado, favor verifique o mesmo!', 1, 0 )

		endif

	END TRANSACTION

	RestArea(aArea)
	RestArea(aAreaU00)
	RestArea(aAreaUJV)

Return(lRet)

/*/{Protheus.doc} RCPGA39B
Funcao para EXCLUIR o Pedido de Venda
do Apontamento Cemiterio
@author g.sampaio 
@since 24/01/2020
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function RCPGA39B()

	Local aArea				:= GetArea()
	Local aAreaUJV			:= UJV->(GetArea())
	Local lRetorno			:= .T.
	Local lFatAptTransf		:= SuperGetMV("MV_XFTAPTR",.F.,.F.)

	// verifico se o campo de origem do apontamento existe
	if UJV->(FieldPos("UJV_ORIGEM")) > 0

		// caso a origem do apontamento for da transferencia de enderecos
		if !lFatAptTransf .And. AllTrim(UJV->UJV_ORIGEM) == "RCPGA034"
			lRetorno := .F.
			Help( ,, 'Help',, 'O Apontamento foi gerado pela rotina de transferência de endereçamento, operação não permitida!', 1, 0 )
		endIf

	endIf

	// verifico se está tudo certo para continuar
	if lRetorno

		if !Empty(UJV->UJV_PEDIDO)

			if MsgYesNo("Deseja excluir o Pedido de Venda do Apontamento selecionado!")

				FWMsgRun(,{|oSay| lRetorno := U_EstornaLibPedido(UJV->UJV_PEDIDO)},'Aguarde...','Estornando Pedido de Venda do Apontamento!')

				//Atualiza status
				if lRetorno

					// caso for possivel faturar o apontamento de servicos gerado pela transferncia de endereco
					If lFatAptTransf .And. AllTrim(UJV->UJV_ORIGEM) == "RCPGA034"

					EndIf

					RecLock("UJV",.F.)

					UJV->UJV_PEDIDO := ""
					UJV->UJV_STATUS := "E"

					UJV->(MsUnlock())

					MsgInfo("Pedido de Venda excluído com sucesso!")

				endif

			endif
		else

			lRetorno := .F.
			Help( ,, 'Help',, 'Apontamento não possui pedido gerado!', 1, 0 )

		endif

	endIf

	RestArea(aArea)
	RestArea(aAreaUJV)

Return(lRetorno)

/*/{Protheus.doc} UPrepDocSaida
Funcao para Preparar Documento de Saida
da Nota Fiscal do Cliente
@author g.sampaio 
@since 14/04/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RCPGA39C(cPedido)

	Local aArea			:= GetArea()
	Local aAreaSC5		:= SC5->(GetArea())
	Local aAreaSC6		:= SC6->(GetArea())

	SC5->(DbSetOrder(1))
	if SC5->(MsSeek(xFilial("SC5") + cPedido ))

		//Wizard de Preparacao de Doc de Saida
		FWMsgRun(,{|oSay| Ma410PvNfs("SC5",SC5->(Recno()),3)},'Aguarde...','Gerando o Documento de Saída do apontamento...')

		// veifico se tem nota fiscal gerada
		If !Empty(SC5->C5_NOTA)
			MsgInfo("Documento de Saída <"+ AllTrim(SC5->C5_SERIE) + "/" + AllTrim(SC5->C5_NOTA) + "> gerado com Sucesso!", "Faturamento")
		EndIf

	else
		MsgAlert("Pedido de Venda não encontrado.")
	endif

	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} UInitTabPreco
Funcao para retornar a tabela de repco
Inicializador do campo UJV_TABPRC

@author g.sampaio 
@since 05/04/2020
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function UInitTabPreco()

	Local aArea			:= GetArea()
	Local cRetorno 		:= ""

	// para de precos de servicos
	cRetorno	:= SuperGetMv("MV_XTABSER",,"001")

	RestArea( aArea )

Return(cRetorno)

/*/{Protheus.doc} UInitDescTab
Funcao para retornar a descricao da tabela 
de precos no apontamento de servicos
Inicializador do campo UJV_DESTAB

@author g.sampaio 
@since 05/02/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function UInitDescTab()

	Local aArea		:= GetArea()
	Local aAreaDA0	:= DA0->( GetArea() )
	Local cRetorno := ""

	if Inclui
		cRetorno := RetField("DA0",1,XFILIAL("DA0")+FwFldGet("UJV_TABPRC"),"DA0_DESCRI")
	else
		cRetorno := RetField("DA0",1,XFILIAL("DA0")+UJV->UJV_TABPRC,"DA0_DESCRI")
	endif

	RestArea( aAreaDA0 )
	RestArea( aArea )

Return(cRetorno)

/*/{Protheus.doc} UWhenApt
funcao que determina se pode alterar os campos 
do apontamento
@type function
@version 1.0
@author g.sampaio
@since 07/05/2020
@return logical, retorna se pode editar os campos
/*/
User Function UWhenApt()

	Local aArea			:= GetArea()
	Local cStatusEnd 	:= ""
	Local cFieldAlt		:= SubStr( AllTrim( ReadVar() ), 4 )
	Local cParamCmpAlt	:= SuperGetMv("MV_XAPTALT",,"UJV_NOME|UJV_DTSEPU|UJV_HORASE") // campos que podem ser alterados
	Local lRet 			:= .F.
	Local oModel 		:= FWModelActive()
	Local oModelUJV		:= oModel:GetModel('UJVMASTER')

	// alimento a variavel de status do endereco
	cStatusEnd	:=  oModelUJV:GetValue("UJV_STENDE")

	//nao permito alterar os campos do apontamento com endereco efetivado
	if cStatusEnd <> "E"
		lRet := .T.
	ElseIf cFieldAlt $ cParamCmpAlt // se o campo estiver no parametro eu deixo alterar os dados
		lRet := .T.
	endif

	RestArea( aArea )

Return(lRet)

/*/{Protheus.doc} UWhenPV
funcao para nao permitir a alteracao dos do pedido 
de vendas caso o apontamento ja esteja finalizado
@type function
@version 1.0
@author g.sampaio
@since 08/05/2020
@return logical, retorna se pode editar os campos
/*/
User Function UWhenPV()

	Local aArea			:= GetArea()
	Local cStatusApt 	:= ""
	Local lRet 			:= .F.
	Local oModel 		:= FWModelActive()
	Local oModelUJV		:= oModel:GetModel('UJVMASTER')

	// alimento a variavel de status do endereco
	cStatusApt	:=  oModelUJV:GetValue("UJV_STATUS")

	//nao permito alterar os campos do apontamento com endereco efetivado
	if cStatusApt <> "F"
		lRet := .T.
	endif

	RestArea( aArea )

Return(lRet)

/*/{Protheus.doc} GeraPVTipoServico
Funcao para preparar os dados para geracao de pedidos de acordo com o tipo de 
servico cadastrado
@type function
@version P12 
@author raphaelgarcia
@since 8/1/2023
@return logical,pedidos gerados com sucesso
/*/
Static Function GeraPVTipoServico()

	Local aArea 		:= GetArea()
	Local aAreaUJV		:= UJV->(GetArea())
	Local aAreaUJX		:= UJX->(GetArea())
	Local nTotPedido	:= 0
	Local lRetorno		:= .T.

	//consulto o total do apontamento para consultar desconto caso tenha
	if UJV->UJV_DESCON > 0
		nTotPedido := BuscaTpServico(.T.)
	endif

	//chamo a rotina para preparar pedidos a serem gerados
	lRetorno := BuscaTpServico(.F.,nTotPedido)

	RestArea(aArea)
	RestArea(aAreaUJV)
	RestArea(aAreaUJX)

Return(lRetorno)

/*/{Protheus.doc} BuscaTpServico
Funcao para buscar os dados do apontamento de acordo com os tipos
de servicos cadastrados para preparar os dados dos pedidos de vendas
@type function
@version p12 
@author raphaelgarcia
@since 8/1/2023
@param lConsulta, logical, rotina chamada para retornar o total do apontamento caso tenha desconto
@param nVlrTotalPedido, numeric, valor total do apontamento para calcular o desconto de acordo com o peso do item
@return logical , retorno de acordo com a chamada podera chamar logico ou numerico
/*/
Static Function BuscaTpServico(lConsulta,nVlrTotalPedido)

	Local cQuery 		:= ""
	Local cMensagem		:= ""
	Local xRetorno		:= 0
	Local nPrecoItem	:= 0
	Local nDescItem		:= 0
	Local cItemC6		:= ""
	Local aProdutos		:= {}
	Local aItem			:= {}
	Local aCab			:= {}

	Default lConsulta		:= .F.
	Default nVlrTotalPedido	:= 0


	cQuery := " SELECT "
	if !lConsulta
		cQuery += " SERV_FAT, "
		cQuery += " FIL_FAT, "
		cQuery += " OPERACAO, "
		cQuery += " NATUREZA, "
		cQuery += " SUM(VALOR) TOTAL, "
		cQuery += " GERAPV"
	else
		cQuery += " SUM(VALOR)TOTAL "
	endif
	cQuery += " FROM ( "
	cQuery += " SELECT  "
	cQuery += " UJV_SERVIC SERVICO, "
	cQuery += " DA1_PRCVEN VALOR, "
	cQuery += " UZR_SERVIC SERV_FAT, "
	cQuery += " UZR_FILFAT FIL_FAT, "
	cQuery += " UZR_OPER OPERACAO, "
	cQuery += " UZR_NATURE NATUREZA, "
	cQuery += " UZS_GERAPV GERAPV "
	cQuery += " FROM  "
	cQuery += RetSQLName("DA1") + " DA1 "
	cQuery += " INNER JOIN  "
	cQuery += RetSQLName("UJV") + " UJV "
	cQuery += " ON DA1.D_E_L_E_T_ = ' ' "
	cQuery += " AND UJV.D_E_L_E_T_ = ' ' "
	cQuery += " AND DA1.DA1_FILIAL = UJV.UJV_FILIAL "
	cQuery += " AND DA1.DA1_CODPRO = UJV.UJV_SERVIC "

	cQuery += " INNER JOIN " + RetSQLName("UZS") + " UZS "
	cQuery += " ON UZS.D_E_L_E_T_ = ' ' "
	cQuery += " AND UZS.D_E_L_E_T_ = ' ' "
	cQuery += " AND UZS_FILIAL = '" + xFilial("UZS") + "'  "
	cQuery += " AND UZS.UZS_PRODUT = UJV.UJV_SERVIC "

	cQuery += " INNER JOIN " + RetSQLName("UZR") + " UZR "
	cQuery += " ON UZR.D_E_L_E_T_ = ' ' "
	cQuery += " AND UZR_FILIAL = '" + xFilial("UZR") + "'  "
	cQuery += " AND UZR.UZR_CODIGO = UZS.UZS_CODIGO "

	cQuery += " WHERE  "
	cQuery += " DA1_FILIAL = '" + xFilial("DA1") + "'  "
	cQuery += " AND DA1_CODTAB = '" + UJV->UJV_TABPRC + "' "
	cQuery += " AND DA1_DATVIG <= '" + DTOS(dDatabase) + "' "
	cQuery += " AND UJV.UJV_CODIGO = '" + UJV->UJV_CODIGO + "' "

	cQuery += " UNION "

	cQuery += " SELECT
	cQuery += " UJX_SERVIC SERVICO, "
	cQuery += " (UJX_QTDE * DA1_PRCVEN) VALOR, "
	cQuery += " UZR_SERVIC SERV_FAT, "
	cQuery += " UZR_FILFAT FIL_FAT, "
	cQuery += " UZR_OPER OPERACAO, "
	cQuery += " UZR_NATURE NATUREZA, "
	cQuery += " UZS_GERAPV GERAPV "
	cQuery += " FROM  "
	cQuery += RetSQLName("DA1") + " DA1 "
	cQuery += " INNER JOIN "
	cQuery += RetSQLName("UJX") + " UJX "
	cQuery += " ON DA1.D_E_L_E_T_ = ' ' "
	cQuery += " AND UJX.D_E_L_E_T_ = ' ' "
	cQuery += " AND DA1.DA1_FILIAL = UJX.UJX_FILIAL "
	cQuery += " AND DA1.DA1_CODPRO = UJX.UJX_SERVIC "

	cQuery += " INNER JOIN " + RetSQLName("UZS") + " UZS "
	cQuery += " ON UZS.D_E_L_E_T_ = ' ' "
	cQuery += " AND UZS_FILIAL = '" + xFilial("UZS") + "'  "
	cQuery += " AND UZS.D_E_L_E_T_ = ' ' "
	cQuery += " AND UZS.UZS_PRODUT = UJX.UJX_SERVIC "

	cQuery += " INNER JOIN " + RetSQLName("UZR") + " UZR "
	cQuery += " ON UZR.D_E_L_E_T_ = ' ' "
	cQuery += " AND UZR_FILIAL = '" + xFilial("UZR") + "'  "
	cQuery += " AND UZR.UZR_CODIGO = UZS.UZS_CODIGO "

	cQuery += " WHERE  "
	cQuery += " DA1_FILIAL = '" + xFilial("DA1") + "' "
	cQuery += " AND DA1_CODTAB = '" + UJV->UJV_TABPRC + "' "
	cQuery += " AND DA1_DATVIG <= '" + DTOS(dDatabase) + "' "
	cQuery += " AND UJX.UJX_CODIGO = '" + UJV->UJV_CODIGO + "' "

	cQuery += " ) FATURAMENTO  "
	if !lConsulta
		cQuery += " GROUP BY SERV_FAT,FIL_FAT,OPERACAO,NATUREZA,GERAPV "
	endif

	// funcao que converte a query generica para o protheus
	cQuery := ChangeQuery(cQuery)

	// crio o alias temporario
	TcQuery cQuery New Alias "QRYAPTO"

	if QRYAPTO->(!Eof())

		if lConsulta
			xRetorno := QRYAPTO->TOTAL
		else

			While QRYAPTO->(!Eof())

				if UJV->UJV_DESCON > 0
					nDescItem := Round(QRYAPTO->TOTAL/nVlrTotalPedido * UJV->UJV_DESCON, 2)
				endif

				nPrecoItem := QRYAPTO->TOTAL - nDescItem

				if QRYAPTO->GERAPV == "S"

					cItemC6 := StrZero(1,TamSX3("C6_ITEM")[1])

					AAdd(aCab, {"C5_TIPO" 		, "N" 				,Nil})
					AAdd(aCab, {"C5_CLIENTE" 	, UJV->UJV_CLIENT 	,Nil})
					AAdd(aCab, {"C5_LOJACLI" 	, UJV->UJV_LOJA	 	,Nil})
					AAdd(aCab, {"C5_CONDPAG" 	, UJV->UJV_CONDPG	,Nil})
					AAdd(aCab, {"C5_XMENNFS"	, UJV->UJV_MENNFS	,Nil})
					AAdd(aCab, {"C5_TABELA" 	, UJV->UJV_TABPRC	,Nil})
					AAdd(aCab, {"C5_EMISSAO" 	, dDataBase 		,Nil})
					AAdd(aCab, {"C5_MOEDA" 		, 1 				,Nil})
					AAdd(aCab, {"C5_NATUREZ" 	, QRYAPTO->NATUREZA	,Nil})
					AAdd(aCab, {"C5_XCONTRA"	, UJV->UJV_CONTRA	,Nil})
					AAdd(aCab, {"C5_XAPONTC"	, UJV->UJV_CODIGO	,Nil})
					AAdd(aCab, {"C5_XATENDE"	, UJV->UJV_USRATE	,Nil})
					AAdd(aCab, {"C5_XNOMEFA"	, UJV->UJV_NOME		,Nil})

					AAdd(aItem,{"C6_ITEM" 		, cItemC6				,Nil})
					AAdd(aItem,{"C6_PRODUTO" 	, QRYAPTO->SERV_FAT 	,Nil})
					AAdd(aItem,{"C6_QTDVEN" 	, 1						,Nil})
					AAdd(aItem,{"C6_PRCVEN" 	, nPrecoItem			,Nil})
					AAdd(aItem,{"C6_PRUNIT" 	, nPrecoItem			,Nil})
					AAdd(aItem,{"C6_PRCVEN" 	, nPrecoItem			,Nil})
					AAdd(aItem,{"C6_OPER" 		, QRYAPTO->OPERACAO		,Nil})

					AAdd(aProdutos,aItem)

					xRetorno := ExecAutoPedido(QRYAPTO->FIL_FAT,aCab,aProdutos,@cMensagem,QRYAPTO->SERV_FAT,nPrecoItem)

					if !xRetorno
						exit
					endif

					aCab		:= {}
					aItem		:= {}
					aProdutos	:= {}

				else

					xRetorno := ExecAutoTitulo(QRYAPTO->FIL_FAT,nPrecoItem,QRYAPTO->NATUREZA,;
						UJV->UJV_CONTRA,UJV->UJV_CLIENT,UJV->UJV_LOJA,;
						@cMensagem,QRYAPTO->SERV_FAT)

				endif

				QRYAPTO->(DbSkip())
			EndDo

		endif

	endif

// verifico se nao existe este alias criado
	If Select("QRYAPTO") > 0
		QRYAPTO->(DbCloseArea())
	EndIf

Return(xRetorno)

/*/{Protheus.doc} ExecAutoPedido
Funcao para executar o ExecAuto do MATA410 
de acordo com os tipos de servicos definidos
@type function
@version p12 
@author raphaelgarcia
@since 8/1/2023
@param cFilFaturamento, character, Filial de Geracao do PV
@param aCab, array, Dados do Cabecalho do Pedido
@param aProdutos, array, Produtos do pedidos
@param cMensagem, Charactere, Mensagem contendo os pedidos gerados
@param cServico, Charactere, Produto do tipo de servico do pedido de venda
@param nPrecoItem, numeric, Valor do pedido de venda

@return logical, Pedido gerado com sucesso.
/*/
Static Function ExecAutoPedido(cFilFaturamento,aCab,aProdutos,cMensagem,cServico,nPrecoItem)

	Local aArea 		:= GetArea()
	Local aAreaUJV		:= UJV->(GetArea())
	Local aAreaUJX		:= UJX->(GetArea())
	Local lRetorno		:= .T.
	Local cFilBkp		:= cFilAnt
	Local cPulaLinha	:= Chr(13) + Chr(10)

	Private lMsErroAuto	:= .F.

//Altero a filial logada para inclusao do pedido na filial do tipo de servico
	cFilAnt := cFilFaturamento

	MSExecAuto({|X,Y,Z|Mata410(X,Y,Z)},aCab,aProdutos,3)

	If lMsErroAuto

		lRetorno := .F.
		MostraErro()
		DisarmTransaction()

	else

		cMensagem += " Numero: "+AllTrim(SC5->C5_NUM)+" Filial :" + QRYAPTO->FIL_FAT + " " + cPulaLinha

		GravaHistAptoPedido(UJV->UJV_CODIGO,SC5->C5_NUM,cServico,nPrecoItem,QRYAPTO->FIL_FAT,cFilBkp)

	endif

//restauro a filial logada
	cFilAnt := cFilBkp

	RestArea(aArea)
	RestArea(aAreaUJV)
	RestArea(aAreaUJX)

Return(lRetorno)


/*/{Protheus.doc} ExecAutoTitulo
Funcao para realizar a inclusao do titulo financeiro
do apontamento
@type function
@version 1.0 
@author raphaelgarcia
@since 8/13/2023
@param cFilFaturamento, character, Filial de Geracao do Titulo
@param nPrecoItem, numeric, Valor do Titulo que sera gerado
@param cNatureza, character, Natureza Financeiroa do Titulo
@param cContrato, character, Codigo do Contrato
@param cCliente, character, Codigo do Cliente
@param cLoja, character, Loja do Cliente
@return logical, Titulo gerado sim ou nao 
/*/
Static Function ExecAutoTitulo(cFilFaturamento,nPrecoItem,cNatureza,cContrato,cCliente,cLoja,cMensagem,cServico)

	Local aArea 		:= GetArea()
	Local aAreaUJV		:= UJV->(GetArea())
	Local aAreaUJX		:= UJX->(GetArea())
	Local aFin040		:= {}
	Local cFilBkp		:= cFilAnt
	Local cPulaLinha	:= Chr(13) + Chr(10)
	Local cPrefixo		:= Alltrim(SuperGetMv("MV_XPRFTAP",,"CEM"))
	Local cTipoTit		:= Alltrim(SuperGetMv("MV_XTPTAP",,"APT"))
	Local cChaveTit		:= ""
	Local lRet			:= .T.

	Private lMsErroAuto	:= .F.

//Altero a filial logada para inclusao do pedido na filial do tipo de servico
	cFilAnt := cFilFaturamento

	cParcela := LastParcela(cContrato)

	aadd(aFin040, {"E1_FILIAL"	, xFilial("SE1")											, Nil } )
	aadd(aFin040, {"E1_PREFIXO"	, cPrefixo         						   					, Nil } )
	aadd(aFin040, {"E1_NUM"		, cContrato		 	   										, Nil } )
	aadd(aFin040, {"E1_PARCELA"	, cParcela								   					, Nil } )
	aadd(aFin040, {"E1_TIPO"	, cTipoTit	 							   					, Nil } )
	aadd(aFin040, {"E1_NATUREZ"	, cNatureza													, Nil } )
	aadd(aFin040, {"E1_CLIENTE"	, cCliente								   					, Nil } )
	aadd(aFin040, {"E1_LOJA"	, cLoja									   					, Nil } )
	aadd(aFin040, {"E1_EMISSAO"	, dDataBase								   					, Nil } )
	aadd(aFin040, {"E1_VENCTO"	, dDataBase													, Nil } )
	aadd(aFin040, {"E1_VENCREA"	, DataValida(dDataBase)										, Nil } )
	aadd(aFin040, {"E1_VALOR"	, nPrecoItem							   					, Nil } )
	AAdd(aFin040, {"E1_XCONTRA"	, cContrato								   					, Nil } )

	MSExecAuto({|x,y| FINA040(x,y)},aFin040,3)

	If lMsErroAuto

		lRet := .F.
		MostraErro()
		DisarmTransaction()

	else

		cChaveTit	:= SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO

		cMensagem += " Filial: " + cFilFaturamento + " Titulo: "+AllTrim(cPrefixo)+" - " + cContrato + " - " + cParcela + " - " + cTipoTit + cPulaLinha

		GravaHistAptoPedido(UJV->UJV_CODIGO,"",cServico,nPrecoItem,QRYAPTO->FIL_FAT,cFilBkp,cChaveTit)

	endif

//restauro a filial logada
	cFilAnt := cFilBkp

	RestArea(aArea)
	RestArea(aAreaUJV)
	RestArea(aAreaUJX)

Return(lRet)

/*/{Protheus.doc} LastParcela
//Funcao para consultar a data de vencimento
da ultima parcela do contrato
do contrato
@author raphael
@since 13/08/2023
@version 1.0
@return Character,cLastParc, Proxima Parcela para Apontamento
@type function
/*/
Static Function LastParcela(cContrato)

	Local cPrefixo		:= Alltrim(SuperGetMv("MV_XPRFTAP",,"CEM"))
	Local cTipoTit		:= Alltrim(SuperGetMv("MV_XTPTAP",,"APT"))
	Local cQry 			:= ""
	Local cLastParc		:= ""

	If Select("QRYTIT") > 0
		QRYTIT->(DbCloseArea())
	EndIf

	cQry := " SELECT "
	cQry += " COUNT(*) QTD_PARC "
	cQry += " FROM "
	cQry += " " + RetSQLName("SE1") + " SE1 "
	cQry += " WHERE "
	cQry += " SE1.D_E_L_E_T_ = ' ' "
	cQry += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
	cQry += " AND SE1.E1_PREFIXO = '" + cPrefixo + "'"
	cQry += " AND SE1.E1_TIPO = '" + cTipoTit + "' "
	cQry += " AND SE1.E1_XCONTRA = '" + cContrato + "' "

	cQry := Changequery(cQry)

	TcQuery cQry New Alias "QRYTIT"

	// se existir títulos com este tipo
	if QRYTIT->(!Eof()) .AND. !Empty(QRYTIT->QTD_PARC)
		cLastParc := STRZERO(QRYTIT->QTD_PARC + 1,3)
	else
		cLastParc := Padl("1",TamSX3("E1_PARCELA")[1],"0")
	endif

	If Select("QRYTIT") > 0
		QRYTIT->(DbCloseArea())
	EndIf

Return(cLastParc)

/*/{Protheus.doc} GravaHistAptoPedido
Grava historico de Apotnamento x Pedidos de Venda
@type function
@version 1.0 
@author raphaelgarcia
@since 8/1/2023
@param cApontamento, character, Codigo do Apontamento
@param cPedido, character, Codigo do Pedido Gerado
@param cServico, character, Codigo do Produto do PV
@param nPrecoItem, numeric, Valor do PV
@param cFilFaturamento, character, Filial de Faturamento
@param cFilLogada, character, Filial de Inclusao do Registro
/*/
Static Function GravaHistAptoPedido(cApontamento,cPedido,cServico,nPrecoItem,cFilFaturamento,cFilLogada,cChaveTit)

	Local aArea := GetArea()

	Default cChaveTit := ""

	Reclock("UZT",.T.)

	UZT->UZT_FILIAL := xFilial("UZT",cFilLogada)
	UZT->UZT_APONTA := cApontamento
	UZT->UZT_PEDIDO := cPedido
	UZT->UZT_SERVIC := cServico
	UZT->UZT_VALOR 	:= nPrecoItem
	UZT->UZT_FILFAT := cFilFaturamento
	UZT->UZT_CHAVET	:= cChaveTit

	UZT->(MsUnlock())

	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} GeraMultiFaturamento
Funcao para gerar o Faturamento por Multi Faturamento
@type function
@version 1.0 
@author raphaelgarcia
@since 8/31/2023
@param cCodApontamento, character, Codigo do Apontamento
@return logical, faturamento gerado 
/*/
Static Function GeraMultiFaturamento(cCodApontamento)

	Local aArea 			:= GetArea()
	Local aAreaUJV 			:= UJV->(GetArea())
	Local lRetorno			:= .T.
	Local oFatCemiterio 	:= Nil

	// inicio a classe de faturamento do modulo cemiterio
	oFatCemiterio := VirtusMultiFaturamento():New("A", cCodApontamento)

	// valido se esta tudo certo para continur com o faturamento
	If oFatCemiterio:lOk
		lRetorno := oFatCemiterio:MultiFaturamento()
	else
		lRetorno := .F.
	EndIf

	RestArea(aAreaUJV)
	RestArea(aArea)

Return(lRetorno)

User Function RCPGA39F()

	Local cRetorno			:= ""
	Local cTipoServico		:= SuperGetMv("MV_XTPSERC",.F.,"1") // 1 - Faturamento Comum // 2 - Faturamento com Tipo de Servico x Filial // 3 - multifaturamento

	If cTipoServico == "1" .Or. cTipoServico == "2"
		If UJV->UJV_STATUS == "F" .And. Empty(UJV->UJV_PEDIDO)
			cRetorno := "A"
		ElseIf UJV->UJV_STATUS == "F" .And. !Empty(UJV->UJV_PEDIDO)
			cRetorno := "F"
		EndIf
	ElseIf cTipoServico == "3"

	EndIF

Return(cRetorno)

/*/{Protheus.doc} RCPGA39P
Metodo para exibir o historico do 
apontamento de servicos
@type function
@version 1.0
@author g.sampaio
@since 30/12/2023
@param cApontamento, character, Codigo do Apontamento de Servicos
/*/
User Function RCPGA39P(cApontamento)

	Local cBkpRotina := FunName()

	Default cApontamento := ""

	SetFunName("RCPGA049")

	U_RCPGA049(cApontamento)

	SetFunName(cBkpRotina)

Return(Nil)

Static Function AtuTransfFaturamento(cCodApontamento, cTipoExc)

	Local aArea 	:= GetArea()
	Local aAreaU38	:= U38->(GetArea())
	Local cQuery	:= ""

	Default cCodApontamento := ""
	Default cTipoExc		:= ""

	cQuery := " SELECT U38.R_E_C_N_O_ RECU38 FROM " + RetSQLName("U38") + " U38 "
	cQuery += " WHERE U38.D_E_L_E_T_ = ' '"
	cQuery += " AND U38.U38_FILIAL = '" + xFilial("U38") + "'"
	cQuery += " AND U38.U38_APONTA = '" + cCodApontamento + "' "

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, "TRBU38")

	If TRBU38->(!Eof())
		U38->(DbGoTo(TRBU38->RECU38))

		If U38->(Reclock("U38", .F.))
			U38->U38_PEDIDO := "PVAPONT"
			U38->(MsUnlock())
		Else
			U38->(DisarmTransaction())
		EndIf

	EndIf

	RestArea(aAreaU38)
	RestArea(aArea)

Return(cRetorno)

/*/{Protheus.doc} RCPGA39WMultFat
Funcao para validar se o campo de desconto 
e editavel de acordo com o parametro MV_XTPSERC
em caso de multifaturament, informo o desconto na tela
campos UJV_DESCON/UJX_DESCON - Iif(Existblock("RCPGA39WMultFat"),U_RCPGA39WMultFat(),.T.)
@type function
@version 1.0
@author g.sampaio
@since 03/05/2024
@return logical, retorna se o campo de desconto e editavel
/*/
User Function RCPGA39WMultFat()

	Local cTipoServico	:= SuperGetMv("MV_XTPSERC",.F.,"1") // 1 - Faturamento Comum // 2 - Faturamento com Tipo de Servico x Filial // 3 - multifaturamento
	Local lRetorno		:= .T.

	// para multifaturamento
	If cTipoServico == "3"
		lRetorno := .F.
	EndIf

Return(lRetorno)

/*/{Protheus.doc} RCPGA39Desc
Realiza a validacao do campo desconto
UJX_DESCON - ExecBlock("RCPGA39Desc")                                                                                                    
@type function
@version 1.0
@author g.sampaio
@since 03/05/2024
@return logical, retorno da funcao
/*/
User Function RCPGA39Desc()

	Local aArea 			:= GetArea()
	Local lRet				:= .T.
	Local oView				:= FWViewActive()
	Local oModel 			:= FWModelActive()
	Local oModelUJX			:= oModel:GetModel( 'UJXDETAIL' )
	Local nDesconto			:= 0
	Local nUnitarioValor	:= oModelUJX:GetValue("UJX_VLUNIT")
	Local nQuantidade		:= oModelUJX:GetValue("UJX_QTDE")
	Local nVlrTotal			:= 0

	If UJX->(FieldPos("UJX_DESCON")) > 0
		nDesconto := oModelUJX:GetValue("UJX_DESCON")
	EndIf

	if nDesconto > 0

		nVlrTotal := nQuantidade * (nUnitarioValor-nDesconto)

		FwFldPut("UJX_VALOR"	, nVlrTotal ,,,,.F.)

		if oView <> NIL
			oOSTotais:RefreshTot() //Atualiza os totalizadores
		endif

	endif

	RestArea(aArea)

Return(lRet)
