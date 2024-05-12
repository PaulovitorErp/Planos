#include "totvs.ch"
#include "fwmvcdef.ch"
#include 'FWEditPanel.ch'
#include 'topconn.ch'

Static oLocTotais  	:= NIL

/*/{Protheus.doc} RCPGA042
historico de locacao de nichos
@type function
@version 
@author g.sampaio
@since 02/03/2020
@return return_type, return_description
/*/
User Function RCPGA042()

	Local cName         := Funname()
	Local lCadContrato  := iif( AllTrim(cName) $ "RCPGA001", .T., .F. ) // verifico se estou no cadastro de contratos
	Local oBrowse       := Nil

	// Altero o nome da rotina para considerar o menu deste MVC
	SetFunName("RCPGA042")

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'U74' )
	oBrowse:SetDescription( 'Histórico de Taxa de Locação Nicho' )
	oBrowse:AddLegend("U74_STATUS=='1'", "GREEN", 	"Locação Vigente")
	oBrowse:AddLegend("U74_STATUS=='2'", "RED",		"Locação Encerrada")

	// se estiver no cadastro de contratos, filtro o contrato posicionado
	If lCadContrato .And. MsgYesNo("Deseja filtrar às Taxa de Locação de Nicho do contrato posicionado?")
		oBrowse:SetFilterDefault( "U74_CONTRA=='" + U00->U00_CODIGO + "'" )
	EndIf

	oBrowse:Activate()

	// Retorno o nome da rotina
	SetFunName(cName)

Return(NIL)

/*/{Protheus.doc} MenuDef
Função que cria os menus	
@type function
@version 
@author g.sampaio
@since 02/03/2020
@return Nil
/*/
Static Function MenuDef()

	Local aRotina           := {}
	Local aRotManut 		:= {}
	Local aRotAdiant        := {}
	Local lCadContrato      := iif( AllTrim(Funname()) $ "RCPGA001", .T., .F. ) // verifico se estou no cadastro de contratos

	// rotinas de "Manutenção Financeira"
	Aadd( aRotManut, {"Painel"      ,"U_RCPGE046(U74->U74_CONTRA)", 0, 4} )
	Aadd( aRotManut, {"Liquidação"  ,"U_RCPGE034(U74->U74_CONTRA)", 0, 4} )

	// adiantamento de parcelas
	Aadd( aRotAdiant, {"Adiantamento Tx.Locação"         ,"U_RCPGA044()", 0, 4} )
	Aadd( aRotAdiant, {"Histórico Adiant. Tx.Locação"    ,"U_RCPGA045()", 0, 4} )

	ADD OPTION aRotina Title 'Pesquisar'   			                Action 'PesqBrw'          	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  			                Action 'VIEWDEF.RCPGA042' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     			                Action 'VIEWDEF.RCPGA042' 	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    			                Action 'VIEWDEF.RCPGA042' 	OPERATION 06 ACCESS 0

	// caso nao esteja na rotina de contrato
	If !lCadContrato
		ADD OPTION aRotina Title 'Gerar Taxa de Locação'    			Action 'U_RCPGA041()' 	OPERATION 03 ACCESS 0
	EndIf

	ADD OPTION aRotina Title 'Exclusão em lote'		                Action 'U_RCPGA043()' 		OPERATION 10 ACCESS 0
	ADD OPTION aRotina Title 'Adiantamento de Parcelas'    			Action aRotAdiant 	        OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Manutenção Financeira'			    Action aRotManut			OPERATION 10 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
Função que cria o objeto model
@type function
@version 
@author g.sampaio
@since 02/03/2020
@return nil
/*/
Static Function ModelDef()

	Local oStruU74  := FWFormStruct( 1, 'U74', /*bAvalCampo*/, /*lViewUsado*/ )  // cabecalho de tx locacao
	Local oStruU75  := FWFormStruct( 1, 'U75', /*bAvalCampo*/, /*lViewUsado*/ )  // itens de tx locacao
	Local oStruU76  := FWFormStruct( 1, 'U76', /*bAvalCampo*/, /*lViewUsado*/ )  // hist de adiantamento de tx locacao
	Local oStruU77  := FWFormStruct( 1, 'U77', /*bAvalCampo*/, /*lViewUsado*/ )  // itens hist de aditamento tx de loacao
	Local oStruU78  := FWFormStruct( 1, 'U78', /*bAvalCampo*/, /*lViewUsado*/ )  // reajuste de taxa de locacao
	Local oStruSE1  := DefStrModel("SE1")
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PCPGA042', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	/////////////////////////  CABEÇALHO - TAXA  ////////////////////////////

	// Crio a Enchoice com os campos da taxa
	oModel:AddFields( 'U74MASTER', /*cOwner*/, oStruU74 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "U74_FILIAL" , "U74_CODIGO" })

	// Preencho a descrição da entidade
	oModel:GetModel('U74MASTER'):SetDescription('Taxa:')

	///////////////////////////  ITENS - TITULOS  //////////////////////////////

	// Crio o grid de títulos
	oModel:AddGrid( 'U75DETAIL', 'U74MASTER', oStruU75, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faço o relaciomaneto entre o cabeçalho e os itens
	oModel:SetRelation( 'U75DETAIL', { { 'U75_FILIAL', 'xFilial( "U75" )' } , { 'U75_CODIGO', 'U74_CODIGO' } } , U75->(IndexKey(1)) )

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel('U75DETAIL'):SetOptional( .F. )

	// Preencho a descrição da entidade
	oModel:GetModel('U75DETAIL'):SetDescription('Histórico de Títulos:')

	// Não permitir duplicar a chave da parcela
	oModel:GetModel('U75DETAIL'):SetUniqueLine( {'U75_PREFIX','U75_NUM','U75_PARCEL','U75_TIPO'} )

	///////////////////////////  ITENS - TITULOS  //////////////////////////////

	// Crio o grid
	oModel:AddGrid( 'SE1DETAIL', 'U75DETAIL', oStruSE1, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faço o relaciomaneto entre o cabeçalho e os itens
	oModel:SetRelation( 'SE1DETAIL', { { 'E1_FILIAL', 'U75_FILIAL' }, { 'E1_PREFIXO', 'U75_PREFIX' }, { 'E1_NUM', 'U75_NUM' } }, SE1->(IndexKey(1)) )

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel('SE1DETAIL'):SetOptional( .T. )
	oModel:GetModel('SE1DETAIL'):SetOnlyQuery()
	oModel:GetModel('SE1DETAIL'):SetOnlyView()
	oModel:GetModel('SE1DETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('SE1DETAIL'):SetNoUpdateLine(.T.)

	// Preencho a descrição da entidade
	oModel:GetModel('SE1DETAIL'):SetDescription('Títulos da Locação:')

	///////////////////////////  ITENS - Reajuste  //////////////////////////////

	// Crio o grid de títulos
	oModel:AddGrid( 'U78DETAIL', 'U74MASTER', oStruU78, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faço o relaciomaneto entre o cabeçalho e os itens
	oModel:SetRelation( 'U78DETAIL', { { 'U78_FILIAL', 'xFilial( "U78" )' } , { 'U78_CODLOC', 'U74_CODIGO' } } , U78->(IndexKey(2)) )

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel('U78DETAIL'):SetOptional( .F. )

	// Preencho a descrição da entidade
	oModel:GetModel('U78DETAIL'):SetDescription('Reajuste:')

	// Não permitir duplicar a chave da parcela
	oModel:GetModel('U78DETAIL'):SetUniqueLine( {'U78_CODIGO'} )

	///////////////////////////  Adiantamento de Locacao  //////////////////////////////

	// Crio o grid de títulos
	oModel:AddGrid( 'U76DETAIL', 'U74MASTER', oStruU76, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faço o relaciomaneto entre o cabeçalho e os itens
	oModel:SetRelation( 'U76DETAIL', { { 'U76_FILIAL', 'xFilial( "U76" )' } , { 'U76_CODLOC', 'U74_CODIGO' } } , U76->(IndexKey(3)) )

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel('U76DETAIL'):SetOptional( .F. )

	// Preencho a descrição da entidade
	oModel:GetModel('U76DETAIL'):SetDescription('Adiantamento:')

	// Não permitir duplicar a chave da parcela
	oModel:GetModel('U76DETAIL'):SetUniqueLine( {'U76_CODIGO'} )

	///////////////////////////  Parcelas Adiantamento de Locacao  //////////////////////////////

	// Crio o grid de títulos
	oModel:AddGrid( 'U77DETAIL', 'U76DETAIL', oStruU77, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faço o relaciomaneto entre o cabeçalho e os itens
	oModel:SetRelation( 'U77DETAIL', { { 'U77_FILIAL', 'xFilial( "U77" )' } , { 'U77_CODIGO', 'U76_CODIGO' } } , U77->(IndexKey(1)) )

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel('U77DETAIL'):SetOptional( .F. )

	// Preencho a descrição da entidade
	oModel:GetModel('U77DETAIL'):SetDescription('Parc.Adiantamento:')

	// Não permitir duplicar a chave da parcela
	oModel:GetModel('U77DETAIL'):SetUniqueLine( {'U77_CODIGO'} )

	//////////////////////////  TOTALIZADORES  //////////////////////////////////

	oModel:AddCalc( 'CALC1', 'U74MASTER', 'U75DETAIL', 'U75_VALOR', 'VALOR'	, 'SUM'		,,,'Valor Total' )

Return(oModel)

/*/{Protheus.doc} ViewDef
Função que cria o objeto View
@type function
@version 
@author g.sampaio
@since 02/03/2020
@return nil
/*/
Static Function ViewDef()

	//Local bBloco    := {|| }
	Local oStruU74 	:= FWFormStruct(2,'U74')
	Local oStruU75 	:= FWFormStruct(2,'U75')
	Local oStruU76 	:= FWFormStruct(2,'U76')
	Local oStruU77 	:= FWFormStruct(2,'U77')
	Local oStruU78 	:= FWFormStruct(2,'U78')
	Local oStruSE1 	:= DefStrView("SE1")
	Local oModel   	:= FWLoadModel('RCPGA042')
	Local oView     := Nil
	Local oCalc1    := Nil

	// remove campos da estrutura
	oStruU74:RemoveField('U74_FILIAL')
	oStruU75:RemoveField('U75_FILIAL')
	oStruU75:RemoveField('U75_CODIGO')
	oStruU76:RemoveField('U76_FILIAL')
	oStruU75:RemoveField('U76_CODLOC')
	oStruU77:RemoveField('U77_FILIAL')
	oStruU75:RemoveField('U77_CODIGO')
	oStruU78:RemoveField('U78_FILIAL')
	oStruU75:RemoveField('U78_CODLOC')

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	// crio o totalizador
	oCalc1 := FWCalcStruct( oModel:GetModel( 'CALC1') )

	oView:AddField('VIEW_U74'	, oStruU74	, 'U74MASTER') // cria o cabeçalho
	oView:AddField('VIEW_CALC1'	, oCalc1	, 'CALC1' )

	oView:AddGrid('VIEW_U75'	, oStruU75	, 'U75DETAIL') // Cria o grid
	oView:AddGrid('VIEW_U76'	, oStruU76	, 'U76DETAIL') // Cria o grid
	oView:AddGrid('VIEW_U77'	, oStruU77	, 'U77DETAIL') // Cria o grid
	oView:AddGrid('VIEW_U78'	, oStruU78	, 'U78DETAIL') // Cria o grid
	oView:AddGrid('VIEW_SE1'	, oStruSE1  , 'SE1DETAIL') // GRID - FINANCEIRO


	// Cria componentes nao MVC
	oView:AddOtherObject( "RESUMO", {|oPanel| CriaTotais(oPanel) } )

	//Cria Folder para organizar separacao de tela
	oView:CreateVerticalBox( "PAINEL_ESQUERDA"		, 100)
	oView:CreateVerticalBox( "PAINEL_DIREITA"		, 200,,.T.)

	oView:SetOwnerView( "RESUMO"		, "PAINEL_DIREITA")

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_CABECALHO' , 30,"PAINEL_ESQUERDA")
	oView:CreateHorizontalBox('PANEL_ITENS'		, 60,"PAINEL_ESQUERDA")
	oView:CreateHorizontalBox('PANEL_CALC'		, 10,"PAINEL_ESQUERDA")

	// Cria Folder na view
	oView:CreateFolder("PASTAS","PANEL_ITENS")
	oView:AddSheet("PASTAS","ABA01","Parcelas")
	oView:AddSheet("PASTAS","ABA02","Adiantamento")

	// ABA PARCELAS
	oView:CreateHorizontalBox( 'PANEL_PASTA1_ABA01'			, 100 , /*owner*/, /*lPixel*/, 'PASTAS', 'ABA01')
	oView:CreateFolder('PASTA2', 'PANEL_PASTA1_ABA01')
	oView:AddSheet('PASTA2','ABA_PARCELAS'  , 'Histórico de Parcelas')
	oView:AddSheet('PASTA2','ABA_FINANCEIRO', 'Financeiro')
	oView:CreateHorizontalBox("PANEL_PARCELAS"			,100,,,"PASTA2","ABA_PARCELAS")
	oView:CreateHorizontalBox("PANEL_FINANCEIRO"	    ,100,,,"PASTA2","ABA_FINANCEIRO")

	// Detalhamento das Abas - Historico de Parcelas e Reajuste
	oView:CreateVerticalBox("PANEL_PARC"			, 070,  "PANEL_PARCELAS",,"PASTA2","ABA_PARCELAS")
	oView:CreateVerticalBox("PANEL_REAJ"			, 030,  "PANEL_PARCELAS",,"PASTA2","ABA_PARCELAS")

	// Detalhamento das Abas - Titulos no Financeiro
	oView:CreateVerticalBox("PANEL_TITULOS"			,100 ,"PANEL_FINANCEIRO",,"PASTA2","ABA_FINANCEIRO")

	// ABA ATENCIPAÇÃO
	oView:CreateHorizontalBox("PANEL_ATENCIPA"		,100,,,"PASTAS","ABA02")

	oView:CreateVerticalBox("ANTECIPA_CAB"			, 030,  "PANEL_ATENCIPA",,"PASTAS","ABA02")
	oView:CreateVerticalBox("ANTECIPA_ITENS"		, 070,  "PANEL_ATENCIPA",,"PASTAS","ABA02")

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_U74' 	, 'PANEL_CABECALHO')
	oView:SetOwnerView('VIEW_U75' 	, 'PANEL_PARC')
	oView:SetOwnerView('VIEW_U78' 	, 'PANEL_REAJ')
	oView:SetOwnerView('VIEW_SE1' 	, 'PANEL_FINANCEIRO')
	oView:SetOwnerView('VIEW_U76' 	, 'ANTECIPA_CAB')
	oView:SetOwnerView('VIEW_U77' 	, 'ANTECIPA_ITENS')
	oView:SetOwnerView('VIEW_CALC1' , 'PANEL_CALC')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_U74')
	oView:EnableTitleView('VIEW_U75')
	oView:EnableTitleView('VIEW_U78')

	// Define campos que terao Auto Incremento
	oView:AddIncrementField( 'VIEW_U75', 'U75_ITEM' )

	// Habilita a quebra dos campos na Vertical
	oView:SetViewProperty( 'U74MASTER', "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

	// Inicializacao do campo Contrato quando chamado pela rotina de Contrato
	bBloco := {|oView| IniCpoCont(oView)}
	oView:SetAfterViewActivate(bBloco)

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

	// Habilito a barra de progresso na abertura da tela
	oView:SetProgressBar(.T.)

Return(oView)

/*/{Protheus.doc} IniCpoCont
//Funcao para inicializar campos
de acordo com o contrato posicionado.
@type function
@version 
@author g.sampaio
@since 09/07/2020
@param oView, object, param_description
@return return_type, return_description
/*/
Static Function IniCpoCont(oView)

	Local aArea         := GetArea()
	Local aAreaU00      := U00->(GetArea())
	Local aAreaU04      := U04->(GetArea())
	Local nOperation 	:= oView:GetOperation()
	Local oModel		:= FWModelActive()
	Local oModelU74 	:= oModel:GetModel("U74MASTER")
	Local nPrazRetir    := SuperGetMV("MV_XDIASRE", .F., 30)

	// diferente de 5
	if nOperation <> 5

		// posiciono no registro da U00
		U00->( DbSetOrder(1) )
		if U00->( MsSeek( xFilial("U00")+U74->U74_CONTRA ) )

			//Carrega campos virtuais nas operacoes de visual, altera e exclui
			oModelU74:LoadValue("U74_CLIENT", U00->U00_CLIENT)
			oModelU74:LoadValue("U74_LOJA"  , U00->U00_LOJA)
			oModelU74:LoadValue("U74_DSCCLI", U00->U00_NOMCLI)
			oModelU74:LoadValue("U74_PLANO" , U00->U00_PLANO)
			oModelU74:LoadValue("U74_DSCPLN", U00->U00_DESCPL)

			// vejo o tipo do endereco
			if U74->U74_TPEND == "C"

				// posiciono no cadastro do endereco
				U04->( DbSetOrder(3) ) //U04_FILIAL+U04_CREMAT+U04_NICHOC
				if U04->( MsSeek( xFilial("U04")+U74->U74_CREMOS+U74_NICHO ) )

					// preencho os dados relacionados a endereco
					oModelU74:LoadValue("U74_DTEND" , U04->U04_DTUTIL)
					oModelU74:LoadValue("U74_PRAZO" , DaySum(U04->U04_DTUTIL, nPrazRetir))
					oModelU74:LoadValue("U74_DIALOC", DateDiffDay(U74->U74_DATA, dDatabase))
					oModelU74:LoadValue("U74_MESLOC", DateDiffMonth(U74->U74_DATA, dDatabase))

				endIf

			elseIf U74->U74_TPEND == "O"

				// posiciono no cadastro do endereco
				U04->( DbSetOrder(4) ) //U04_FILIAL+U04_OSSARI+U04_NICHOO
				if U04->( MsSeek( xFilial("U04")+U74->U74_CREMOS+U74_NICHO ) )

					// preencho os dados relacionados a endereco
					oModelU74:LoadValue("U74_PRAZO" , U04->U04_DTUTIL)
					oModelU74:LoadValue("U74_DIALOC", DateDiffDay(U74->U74_DATA, dDatabase))
					oModelU74:LoadValue("U74_MESLOC", DateDiffMonth(U74->U74_DATA, dDatabase))

				endIf

			endIf

			oModelU74:LoadValue("U74_DSCIND", Posicione("U22",1,xFilial("U22")+U74->U74_INDICE,"U22_DESC"))

		endIf

	endIf

	oView:Refresh()

	RestArea( aAreaU04 )
	RestArea( aAreaU00 )
	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} CriaTotais
Função que cria o Other Object de Totalizadores
@type function
@version 
@author g.sampaio
@since 03/05/2019
@param oPanel, object, param_description
@return return_type, return_description
/*/
Static Function CriaTotais(oPanel)

	oLocTotais := PainelLocNicho():New(oPanel)

	//atualizo o totalizador de entregue e desconto
	//oLocTotais:RefreshTot()

Return(Nil)

/*/{Protheus.doc} PainelLocNicho
Classe do totalizador
@type class
@version 
@author g.sampaio
@since 03/05/2019
/*/
	Class PainelLocNicho

		Data oParcGeradas
		Data oParcRecebidas
		Data oParcAbertas
		Data oParcAdiant
		Data oValorRecebido
		Data oValorAberto
		Data oSitFinanc

		Data nParcGeradas
		Data nParcRecebidas
		Data nParcAbertas
		Data nParcAdiant
		Data nValorRecebido
		Data nValorAberto
		Data cSitFinanc

		//Metodo Construtor da Classe
		Method New() Constructor

	EndClass

/*/{Protheus.doc} PainelLocNicho::New
Método construtor da classe ObjTotal
@type method
@version 
@author g.sampaio 
@since 03/05/2019
@param oPanel, object, param_description
@return return_type, return_description
/*/
Method New(oPanel) Class PainelLocNicho

	// pego o o modelo de dados ativo
	Local oModel 		        := FWModelActive()

	// declaracao de variaveis
	Local lAdimp		        := .F.
	Local nClrInadi		        := 987135
	Local nHeigth		        := oPanel:nClientHeight / 2
	Local nWhidth		        := oPanel:nClientWidth / 2
	Local nOperation 	        := oModel:GetOperation()
	Local nLin			        := 3
	Local nClrPanes		        := 16777215
	Local nClrSay		        := 7303023
	Local nClrAdimp 	        := 41984
	Local nAltPanels	        := 0
	Local nClrSitFin	        := 12961221
	Local oPnlFinanceiro		:= NIL
	Local oPnlGerParc	        := NIL
	Local oPnlRecParc		    := NIL
	Local oPnlAbtParc	        := NIL
	Local oPnlVlrAber		    := NIL
	Local oPnlVlrAber		    := NIL
	Local oPnlSitFin            := Nil
	Local oSay1			        := NIL
	Local oSay2			        := NIL
	Local oSay3			        := NIL
	Local oSay4			        := NIL
	Local oSay5			        := NIL
	Local oSay6			        := NIL
	Local oSay7			        := NIL
	Local oSay8			        := NIL
	Local oSay9			        := NIL
	Local oSay10		        := NIL
	Local oSay11		        := NIL
	Local oSay12		        := NIL
	Local oSay13		        := NIL
	Local oSay14		        := NIL
	Local oSay15		        := NIL
	Local oSay16		        := NIL
	Local oFont12N	   	        := TFont():New("Verdana",,12,,.T.,,,,.T.,.F.,.T.) // Fonte 12 Negrito, Itálico
	Local oFont14N	   	        := TFont():New("Verdana",,14,,.T.,,,,.T.,.F.,.F.) // Fonte 14 Negrito
	Local oFont18N	   	        := TFont():New("Verdana",,18,,.T.,,,,.T.,.F.,.F.) // Fonte 18 Negrito
	Local oFontNum	   	        := TFont():New("Verdana",08,18,,.F.,,,,.T.,.F.) ///Fonte 14 Negrito
	Local oFontSit	   	        := TFont():New("Verdana",,20,,.F.,,,,.T.,.F.,.F.) // Fonte 24 Nornal

	// inicializo os novos totais zerados
	::nParcGeradas	    := 0
	::nParcRecebidas	:= 0
	::nParcAbertas		:= 0
	::nParcAdiant		:= 0
	::nValorRecebido    := 0
	::nValorAberto		:= 0
	::cSitFinanc 		:= "INEXISTENTE"

	// função que retorna a situação financeira do contrato
	lAdimp := RetSitFin()

	if lAdimp
		::cSitFinanc 	:= "ADIMPLENTE"
		nClrSitFin		:= nClrAdimp
	else
		::cSitFinanc 	:= "PENDENTE"
		nClrSitFin		:= nClrInadi
	endif

	// parcelas geradas
	RetParGeradas( @::nParcGeradas )

	// pego as informacoes de titulos em aberto e recebidos
	RetParcRecebidas( @::nValorRecebido, @::nValorAberto, @::nParcRecebidas, @::nParcAbertas )

	// pego as parcelas adiantadas
	RetParcAdiant( @::nParcAdiant )

	//////////////////////////////////////////////////////////
	////////////////	PAINEL PRINCIPAL 	/////////////////
	/////////////////////////////////////////////////////////

	@ 002, 002 MSPANEL oPnlFinanceiro SIZE nWhidth - 2 , nHeigth -2 OF oPanel COLORS 0, 12961221

	nAltPanels := INT(nHeigth - nLin - 5) / 7

	/////////////////////////////////////////////////////////////////
	////////////////	PANEL PARCELAS GERADAS		////////////////
	////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPnlGerParc SIZE nWhidth - 6 , nAltPanels OF oPnlFinanceiro  COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay1 PROMPT "Parcelas Geradas" SIZE nWhidth - 6, 015 OF oPnlGerParc FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay2 PROMPT Replicate("- ",20) SIZE nWhidth - 6, 015 OF oPnlGerParc FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2), 001 SAY ::oParcGeradas PROMPT AllTrim(Transform(::nParcGeradas,"@E 999,999")) SIZE nWhidth - 6, 010 OF oPnlGerParc FONT oFont18N COLORS 0, 16777215 PIXEL CENTER

	nLin += nAltPanels

	/////////////////////////////////////////////////////////////////
	////////////////	PANEL VALOR RECEBIDO		////////////////
	////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPnlRecParc SIZE nWhidth - 6 , nAltPanels OF oPnlFinanceiro COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay3 PROMPT "Parcelas Recebidas" SIZE nWhidth - 6, 015 OF oPnlRecParc FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay4 PROMPT Replicate("- ",20) SIZE nWhidth - 6, 015 OF oPnlRecParc FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2), 001 SAY ::oParcRecebidas PROMPT AllTrim(Transform(::nParcRecebidas,"@E 999,999")) SIZE nWhidth - 6, 010 OF oPnlRecParc FONT oFont18N COLORS 0, 16777215 PIXEL CENTER

	nLin += nAltPanels

	/////////////////////////////////////////////////////////////////
	////////////////	PAINEL DE PARCELAS EM ABERTO   //////////////
	/////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPnlAbtParc SIZE nWhidth - 6 , nAltPanels OF oPnlFinanceiro COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay5 PROMPT "Parcelas em Aberto" SIZE nWhidth - 6, 015 OF oPnlAbtParc FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay6 PROMPT Replicate("- ",20) SIZE nWhidth - 6, 015 OF oPnlAbtParc FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2), 001 SAY ::oParcAbertas PROMPT AllTrim(Transform(::nParcAbertas,"@E 999,999")) SIZE nWhidth - 6, 010 OF oPnlAbtParc FONT oFont18N COLORS 0, 16777215 PIXEL CENTER

	nLin += nAltPanels

	////////////////////////////////////////////////////////////////////
	////////////////	PAINEL DE PARCELAS ADIANTADAS //////////////////
	////////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPnlAdiParc SIZE nWhidth - 6 , nAltPanels OF oPnlFinanceiro COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay7 PROMPT "Parcelas Adiantadas" SIZE nWhidth - 6, 015 OF oPnlAdiParc FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay8 PROMPT Replicate("- ",20) SIZE nWhidth - 6, 015 OF oPnlAdiParc FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2), 001 SAY ::oParcAdiant PROMPT AllTrim(Transform(::nParcAdiant,"@E 999,999")) SIZE nWhidth - 6, 010 OF oPnlAdiParc FONT oFont18N COLORS 0, 16777215 PIXEL CENTER

	nLin += nAltPanels

	/////////////////////////////////////////////////////////////////////
	////////////////	PAINEL DE VALOR RECEBIDO		////////////////
	////////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPnlVlrRec SIZE nWhidth - 6 , nAltPanels OF oPnlFinanceiro COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay9 PROMPT "Valor Recebido" SIZE nWhidth - 6, 015 OF oPnlVlrRec FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay10 PROMPT Replicate("- ",20) SIZE nWhidth - 6, 015 OF oPnlVlrRec FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 001 SAY oSay15 PROMPT "R$" SIZE nWhidth - 6, 010 OF oPnlVlrRec FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 001 SAY ::oValorRecebido PROMPT AllTrim(Transform(::nValorRecebido,"@E 999,999.99")) SIZE nWhidth - 6, 010 OF oPnlVlrRec FONT oFontNum COLORS 0, 16777215 PIXEL CENTER

	nLin += nAltPanels

	/////////////////////////////////////////////////////////////////
	////////////////	PAINEL DE VALOR EM AERTO	////////////////
	////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPnlVlrAber SIZE nWhidth - 6 , nAltPanels OF oPnlFinanceiro COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay11 PROMPT "Valor em Aberto" SIZE nWhidth - 6, 015 OF oPnlVlrAber FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay12 PROMPT Replicate("- ",20) SIZE nWhidth - 6, 015 OF oPnlVlrAber FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 001 SAY oSay16 PROMPT "R$" SIZE nWhidth - 6, 010 OF oPnlVlrAber FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 001 SAY ::oValorAberto PROMPT AllTrim(Transform(::nValorAberto,"@E 999,999.99")) SIZE nWhidth - 6, 010 OF oPnlVlrAber FONT oFontNum COLORS 0, 16777215 PIXEL CENTER

	nLin += nAltPanels

	/////////////////////////////////////////////////////////////////////
	////////////////    PAINEL STATUS FINANCIERO		/////////////////
	////////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPnlSitFin SIZE nWhidth - 6 , nAltPanels OF oPnlFinanceiro COLORS 0, nClrSitFin RAISED
	@ 000 , 000 SAY oSay13 PROMPT "Situação Financeira" SIZE nWhidth - 6, 015 OF oPnlSitFin FONT oFont14N COLORS 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay14 PROMPT Replicate("- ",20) SIZE nWhidth - 6, 015 OF oPnlSitFin FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) + 5, 001 SAY ::oSitFinanc PROMPT ::cSitFinanc SIZE nWhidth - 6, 010 OF oPnlSitFin FONT oFontSit COLORS 16777215, nClrSitFin PIXEL CENTER

Return(Nil)


/*/{Protheus.doc} RetSitFin
Função que consulta os títulos em aberto do contrato	
@type function
@version 1.0
@author g.sampaio
@since 22/12/2021
/*/
Static Function RetSitFin()

	Local cQuery	    := ""
	Local cPrefLoc      := AllTrim(SuperGetMv("MV_XPRELOC",.F.,"LOC"))
	Local lRet 			:= .T.

	// verifico se nao existe este alias criado
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	EndIf

	cQuery := " SELECT "
	cQuery += " SE1.E1_NUM "
	cQuery += " FROM "
	cQuery += " " + RetSqlName("SE1") + " SE1 "
	cQuery += " WHERE "
	cQuery += " SE1.D_E_L_E_T_	<> '*' "
	cQuery += " AND SE1.E1_FILIAL 	= '" + xFilial("SE1") + "' "
	cQuery += " AND SE1.E1_PREFIXO  = '" + cPrefLoc + "'"
	cQuery += " AND SE1.E1_NUM      = '" + U74->U74_CODIGO + "'"
	cQuery += " AND SE1.E1_XCONTRA	= '" + U74->U74_CONTRA + "' "
	cQuery += " AND SE1.E1_SALDO		> 0 "
	cQuery += " AND SE1.E1_VENCREA	< '" + DTOS(dDataBase) + "' "
	cQuery += " AND SE1.E1_TIPO NOT IN ('AB-','FB-','FC-','FU-' "
	cQuery += " ,'PR','IR-','IN-','IS-','PI-','CF-','CS-','FE-' "
	cQuery += " ,'IV-','RA','NCC','NDC') "

	// funcao que converte a query generica para o protheus
	cQuery := ChangeQuery(cQuery)

	// crio o alias temporario
	TcQuery cQuery New Alias "QRYSE1"

	if QRYSE1->(!Eof())
		lRet := .F.
	endif

	// verifico se nao existe este alias criado
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	EndIf

Return(lRet)

/*/{Protheus.doc} PainelLocNicho::RefreshTot
Método Refresh do Totais da Ordem de Servico
@type method
@version 
@author g.sampaio
@since 09/07/2020
@param cAcao, character, param_description
@param nLinha, numeric, param_description
@return return_type, return_description
/*/
Static Function RetParGeradas( nParcGeradas )

	Local nI			:= 0
	Local oModel		:= FWModelActive()
	Local oModelU75 	:= oModel:GetModel("U75DETAIL")

	For nI := 1 To oModelU75:Length()

		// posiciono na linha
		oModelU75:Goline(nI)

		nParcGeradas++

	Next nI

	// posiciono sempre na linha 1
	oModelU75:Goline(1)

Return(Nil)

/*/{Protheus.doc} RetParcRecebidas
Funcao para consultar o total pago do contrato
@author g.sampaio
@since 23/01/2020
@version P12
@param  cContrato - Codigo do Contrato
@return nTotal - Total Pago do Contrato
/*/
Static Function RetParcRecebidas( nValorRecebido, nValorAberto, nParcRecebidas, nParcAbertas )

	Local cPrefLoc          := AllTrim(SuperGetMv("MV_XPRELOC",.F.,"LOC"))
	Local cQuery 	        := ""

	Default nValorRecebido  := 0
	Default nValorAberto    := 0
	Default nParcRecebidas  := 0
	Default nParcAbertas    := 0

	nValorRecebido := 0

	if Select("QRYTIT") > 0
		QRYTIT->(DbCloseArea())
	endif

	cQuery := " SELECT "
	cQuery += "     *  "
	cQuery += " FROM "
	cQuery += RetSQLName("SE1") + " TITULO "
	cQuery += " WHERE "
	cQuery += " TITULO.D_E_L_E_T_ = ' ' "
	cQuery += " AND TITULO.E1_FILIAL = '" + xFilial("SE1") + "' "
	cQuery += " AND TITULO.E1_PREFIXO   = '" + cPrefLoc + "'"
	cQuery += " AND TITULO.E1_NUM       = '" + U74->U74_CODIGO + "'"
	cQuery += " AND TITULO.E1_XCONTRA   = '" + U74->U74_CONTRA + "' "
	cQuery += " AND TITULO.E1_FATPREF   = ' ' "
	cQuery += " AND TITULO.E1_NUMLIQ    = ' ' "

	cQuery := ChangeQuery(cQuery)

	TcQuery cQuery NEW Alias "QRYTIT"

	while QRYTIT->(!Eof())

		if (QRYTIT->E1_SALDO + QRYTIT->E1_SDACRES - QRYTIT->E1_SDDECRE) > 0

			nValorAberto    += (QRYTIT->E1_SALDO + QRYTIT->E1_SDACRES - QRYTIT->E1_SDDECRE) // valor em aberto
			nParcAbertas++

		else // valo recebido

			nValorRecebido += (QRYTIT->E1_VALOR + QRYTIT->E1_ACRESC - QRYTIT->E1_DECRESC) - (QRYTIT->E1_SALDO + QRYTIT->E1_SDACRES - QRYTIT->E1_SDDECRE)
			nParcRecebidas++
		endIf

		QRYTIT->(DbSkip())
	endDo

	if Select("QRYTIT") > 0
		QRYTIT->(DbCloseArea())
	endif

Return(Nil)

/*/{Protheus.doc} DefStrView
Função que monta a estrutura do alias na view	
@type function
@version 
@author Wellington Gonçalves
@since 13/07/2016
@param cAlias, character, param_description
@return return_type, return_description
/*/
Static Function DefStrView(cAlias)

	Local aArea     	:= GetArea()
	Local oStruct   	:= FWFormViewStruct():New()
	Local aCombo    	:= {}
	Local nInitCBox 	:= 0
	Local nMaxLenCb 	:= 0
	Local aAux      	:= {}
	Local nI        	:= 1
	Local nX			:= 1
	Local cGSC      	:= ''
	Local oSX			:= UGetSxFile():New
	Local aSX3			:= {}
	Local aSXA			:= {}

	if cAlias == "SE1"

		aCampos := {"E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","E1_CLIENTE","E1_LOJA","E1_NOMCLI","E1_VENCTO","E1_VALOR","E1_SALDO","E1_EMISSAO",;
			"E1_BAIXA","E1_XUSRBAX","E1_HIST"}

		oStruct:AddField('STATUS',"01",'','',NIL,'GET','@BMP',,'',.F.,'','',{},1,'BR_VERDE',.T.)
	endif

	For nX := 1 To Len(aCampos)


		aSX3:= oSX:GetInfoSX3(,aCampos[nX])

		If Len(aSX3) > 0

			aCombo := {}

			If !Empty(aSX3[1,2]:cCBOX)

				nInitCBox := 0
				nMaxLenCb := 0

				aAux := RetSX3Box( aSX3[1,2]:cCBOX , @nInitCBox, @nMaxLenCb,aSX3[1,2]:nTAMANHO )

				For nI := 1 To Len(aAux)
					aAdd( aCombo, aAux[nI][1] )
				Next nI

			EndIf

			bPictVar := FwBuildFeature( 4, aSX3[1,2]:cPICTVAR )
			cGSC     := IIf( Empty(aSX3[1,2]:cCBOX) , IIf( aSX3[1,2]:cTIPO == 'L', 'CHECK', 'GET' ) , 'COMBO' )

			oStruct:AddField( 			;
				aSX3[1,2]:cCAMPO, 			;	// [01] Campo
			aSX3[1,2]:cORDEM,			;	// [02] Ordem
			AllTrim(aSX3[1,2]:cTITULO),	;	// [03] Titulo
			AllTrim(aSX3[1,2]:cDESCRI), 		;	// [04] Descricao
			NIL, 						;	// [05] Help
			cGSC, 						;	// [06] Tipo do campo   COMBO, Get ou CHECK
			aSX3[1,2]:cPICTURE,			;	// [07] Picture
			bPictVar, 					;	// [08] PictVar
			aSX3[1,2]:cF3, 				;	// [09] F3
			aSX3[1,2]:cVISUAL <> 'V', 	;	// [10] Editavel
			aSX3[1,2]:cFOLDER, 			;	// [11] Folder
			aSX3[1,2]:cFOLDER, 			;	// [12] Group
			aCombo,						;	// [13] Lista Combo
			nMaxLenCb, 					;	// [14] Tam Max Combo
			aSX3[1,2]:cINIBRW, 			;	// [15] Inic. Browse
			(aSX3[1,2]:cCONTEXT == 'V'))   	// [16] Virtual

		EndIf

	Next nX

	//---------
	// Folders
	//---------

	aSXA:= oSX:GetInfoSXA(cAlias)

	For nX:= 1 To Len(aSXA)

		oStruct:AddFolder(aSXA[nX,2]:cORDEM,aSXA[nX,2]:cDESCRIC)

	Next nX

	RestArea(aArea)

Return(oStruct)

/*/{Protheus.doc} DefStrModel
Função que monta a estrutura do alias no model
@type function
@version 
@author Wellington Gonçalves
@since 13/07/2016
@param cAlias, character, param_description
@return return_type, return_description
/*/
Static Function DefStrModel(cAlias)

	Local aArea    		:= GetArea()
	Local bValid   		:= { || }
	Local bWhen    		:= { || }
	Local bRelac   		:= { || }
	Local aAux     		:= {}
	Local aCampos		:= {}
	Local oStruct 		:= FWFormModelStruct():New()
	Local oSx			:= UGetSxFile():New
	Local aSX2			:= {}
	Local aSIX			:= {}
	Local aSX3			:= {}
	Local aSX7			:= {}
	Local nX			:= 1

	if cAlias == "SE1"

		aCampos := {"E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","E1_CLIENTE","E1_LOJA","E1_NOMCLI","E1_VENCTO","E1_VALOR","E1_SALDO","E1_EMISSAO",;
			"E1_BAIXA","E1_XUSRBAX","E1_HIST"}

		bRelac := {|A,B,C| FWINITCPO(A,B,C),XRET:=(IIF(SE1->E1_SALDO <> 0,IIF(SE1->E1_VALOR > SE1->E1_SALDO .And. SE1->E1_SALDO > 0 ,"BR_AZUL","BR_VERDE"),"BR_VERMELHO")),FWCLOSECPO(A,B,C,.T.),FWSETVARMEM(A,B,XRET),XRET }
		oStruct:AddField('','','STATUS','C',11,0,,,{},.F.,bRelac,,,.T.)

	endif

	//--------
	// Tabela
	//--------
	aSX2:= oSX:GetInfoSX2(cAlias)

	oStruct:AddTable(aSX2[1,2]:cCHAVE,StrTokArr(Alltrim(aSX2[1,2]:cUNICO), '+') ,Alltrim(aSX2[1,2]:cNOME))


	aSIX:= oSX:GetInfoSIX(cAlias)
	//---------
	// Indices
	//---------
	nOrdem := 0

	For nX:= 1 to Len(aSIX)

		oStruct:AddIndex(nOrdem++,aSIX[nX,2]:cORDEM,aSIX[nX,2]:cCHAVE,SIXDescricao(),aSIX[nX,2]:cF3,aSIX[nX,2]:cNICKNAME ,(aSIX[nX,2]:cSHOWPESQ <> 'N'))

	Next nX

	For nX := 1 To Len(aCampos)

		aSX3:= oSX:GetInfoSX3(,aCampos[nX])

		If Len(aSX3) > 0

			bValid 	:= FwBuildFeature( 1, aSX3[1,2]:cVALID   )
			bWhen  	:= FwBuildFeature( 2, aSX3[1,2]:cWHEN    )
			bRelac 	:= FwBuildFeature( 3, aSX3[1,2]:cRELACAO )

			aBox	:= StrTokArr(AllTrim(aSX3[1,2]:cCBOX),';' )

			oStruct:AddField( 			;
				AllTrim(aSX3[1,2]:cTITULO), ;	// [01] Titulo do campo
			AllTrim(aSX3[1,2]:cDESCRI), ;	// [02] ToolTip do campo
			aSX3[1,2]:cCAMPO,	 		;	// [03] Id do Field
			aSX3[1,2]:cTIPO, 			;	// [04] Tipo do campo
			aSX3[1,2]:nTAMANHO,			;	// [05] Tamanho do campo
			aSX3[1,2]:nDECIMAL,			;	// [06] Decimal do campo
			bValid, 					;	// [07] Code-block de valida?o do campo
			bWhen, 						;	// [08] Code-block de valida?o When do campo
			aBox, 						;	// [09] Lista de valores permitido do campo
			.F., 						;	// [10] Indica se o campo tem preenchimento obrigat?io
			bRelac, 					;	// [11] Code-block de inicializacao do campo
			NIL, 						;	// [12] Indica se trata-se de um campo chave
			NIL, 						;	// [13] Indica se o campo pode receber valor em uma opera?o de update.
			(aSX3[1,2]:cCONTEXT == 'V'))// [14] Indica se o campo ?virtual

		Endif

	Next nX

	//----------
	// Gatilhos
	//----------
	For nX := 1 To Len(aCampos)

		aSX7 := oSX:GetInfoSX7(aCampos[nX])

		if Len(aSX7)>0

			aAux :=	FwStruTrigger(aSX7[1,2]:cCAMPO,aSX7[1,2]:cCDOMIN,aSX7[1,2]:cREGRA,aSX7[1,2]:cSEEK=='S',aSX7[1,2]:cALIAS,aSX7[1,2]:cORDEM,aSX7[1,2]:cCHAVE,aSX7[1,2]:cCONDIC,aSX7[1,2]:cSEQUENC)
			oStruct:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

		endif

	Next nX

	RestArea( aArea )

Return(oStruct)

/*/{Protheus.doc} RetParcAdiant
retorna a quantidade de parcelas
de adiantamento de locacao
@type function
@version 
@author Administrador
@since 14/07/2020
@param nParcAdiant, numeric, param_description
@return return_type, return_description
/*/
Static Function RetParcAdiant( nParcAdiant )

	Local aArea             := GetArea()
	Local cPrefixo 			:= AllTrim(SuperGetMv("MV_XPRELOC",.F.,"LOC"))	// prefixo do titulo de locação
	Local cTipo				:= AllTrim(SuperGetMv("MV_XTPADLO",.F.,"ADT"))	// tipo do titulo de adiantamento de locação
	Local cQuery            := ""

	Default nParcAdiant     := 0

	if Select("TRBADT") > 0
		TRBADT->( DbCloseArea() )
	endIf

	cQuery := " SELECT COUNT(*) CONTADT
	cQuery += " FROM " + RetSQLName("SE1") + " SE1
	cQuery += " WHERE SE1.D_E_L_E_T_ = ' '
	cQuery += " AND SE1.E1_FILIAL   = '" + xFilial("U74") + "'"
	cQuery += " AND SE1.E1_PREFIXO	= '" + cPrefixo + "'"
	cQuery += " AND SE1.E1_NUM	    = '" + U74->U74_CODIGO + "'"
	cQuery += " AND SE1.E1_TIPO 	= '" + cTipo + "'"
	cQuery += " AND SE1.E1_XCONTRA	= '" + U74->U74_CONTRA + "'"

	TcQuery cQuery New Alias "TRBADT"

	if TRBADT->(!Eof())
		nParcAdiant := TRBADT->CONTADT
	endIF

	if Select("TRBADT") > 0
		TRBADT->( DbCloseArea() )
	endIf

	RestArea(aArea)

Return(Nil)
