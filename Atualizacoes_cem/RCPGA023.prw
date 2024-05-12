#Include "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RCPGA023
Cadastro de histórico de taxa de manutenção
@type function
@version 1.0
@author Wellington Gonçalves
@since 11/05/2016
@param cCodContrato, character, codigo do contrato
/*/
User Function RCPGA023(cCodContrato)

	Local aArea         := GetArea()
	Local aAreaU00      := U00->(GetArea())
	Local cName         := Funname()
	Local oBrowse       := Nil
	Local lAtivaRegra	:= SuperGetMv("MV_XREGCEM",,.F.)

	Default Default   := ""

	// Altero o nome da rotina para considerar o menu deste MVC
	SetFunName("RCPGA023")

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'U26' )
	oBrowse:SetDescription( 'Histórico de Taxa de Manutenção' )

	// verifico se estou na rotina de contrato
	If !Empty(cCodContrato)

		// posiciono cadastro de contrato
		U00->( DbSetOrder(1) )
		if U00->( MsSeek( xFilial("U00")+cCodContrato ) )

			// pergunto ao usuario se quer filtrar apenas os apontamentos do contrato
			If MsgYesNo("Deseja filtrar as Taxas de Manutenção do contrato posicionado?")
				oBrowse:SetFilterDefault( "U26_FILIAL == '"+ U00->U00_MSFIL +"' .And. U26_CONTRA=='" + U00->U00_CODIGO + "'" ) // filtro apenas o contrato selecionado
			EndIf

		EndIf

	EndIf

	// adiciona legenda no Browser
	if lAtivaRegra		
		oBrowse:AddLegend( "U26_STATUS == '1'"	, "WHITE"   , "Provisionada")
		oBrowse:AddLegend( "U26_STATUS == '2'"	, "GREEN"   , "Efetivada")
		oBrowse:AddLegend( "U26_STATUS == '3'"	, "RED"     , "Finalizada")
	endIf

	oBrowse:Activate()

	// Retorno o nome da rotina
	SetFunName(cName)

	RestArea(aAreaU00)
	RestArea(aArea)

Return(NIL)

/*/{Protheus.doc} MenuDef
Função que cria os menu
@type function
@version 1.0
@author Wellington Gonçalves
@since 11/05/2016
@return array, outras acoes da rotina
/*/
Static Function MenuDef()

	Local aRotina 		:= {}
	Local lAtivaRegra	:= SuperGetMv("MV_XREGCEM",,.F.)

	ADD OPTION aRotina Title 'Pesquisar'   			Action 'PesqBrw'                        	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  			Action 'VIEWDEF.RCPGA023'               	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Gerar Taxa'   		Action 'U_RCPGA022()' 		                OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'     			Action 'VIEWDEF.RCPGA023'               	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     			Action 'VIEWDEF.RCPGA023'               	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    			Action 'VIEWDEF.RCPGA023' 	                OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Exclusão em lote'		Action 'U_RCPGA033()' 		                OPERATION 10 ACCESS 0

	if lAtivaRegra
		ADD OPTION aRotina Title 'Estorno Financeiro'		Action 'U_RCPGA23EF(U26->(Recno()))' 	    OPERATION 09 ACCESS 0
		ADD OPTION aRotina Title 'Legenda'     				Action 'U_RCPGA23LEG()' 	                OPERATION 11 ACCESS 0
		ADD OPTION aRotina Title 'Relatorio de Manutencao'  Action 'U_RCPGR041()' 	                OPERATION 11 ACCESS 0
	endIf

Return(aRotina)

/*/{Protheus.doc} ModelDef
Função que cria o objeto model	
@type function
@version 1.0 
@author Wellington Gonçalves
@since 11/05/2016
@return object, objeto do modelo de dados
/*/
Static Function ModelDef()

	Local oStruU26 := FWFormStruct( 1, 'U26', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruU27 := FWFormStruct( 1, 'U27', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PCPGA023', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	/////////////////////////  CABEÇALHO - TAXA  ////////////////////////////

	// Crio a Enchoice com os campos da taxa
	oModel:AddFields( 'U26MASTER', /*cOwner*/, oStruU26 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "U26_FILIAL" , "U26_CODIGO" })

	// Preencho a descrição da entidade
	oModel:GetModel('U26MASTER'):SetDescription('Taxa:')

	///////////////////////////  ITENS - TITULOS  //////////////////////////////

	// Crio o grid de títulos
	oModel:AddGrid( 'U27DETAIL', 'U26MASTER', oStruU27, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faço o relaciomaneto entre o cabeçalho e os itens
	oModel:SetRelation( 'U27DETAIL', { { 'U27_FILIAL', 'xFilial( "U27" )' } , { 'U27_CODIGO', 'U26_CODIGO' } } , U27->(IndexKey(1)) )

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel('U27DETAIL'):SetOptional( .T. )

	// Preencho a descrição da entidade
	oModel:GetModel('U27DETAIL'):SetDescription('Títulos:')

	// Não permitir duplicar a chave da parcela
	oModel:GetModel('U27DETAIL'):SetUniqueLine( {'U27_PREFIX','U27_NUM','U27_PARCEL','U27_TIPO'} )

	//////////////////////////  TOTALIZADORES  //////////////////////////////////
	oModel:AddCalc( 'CALC1', 'U26MASTER', 'U27DETAIL', 'U27_VALOR', 'VALOR'	, 'SUM'		,,,'Valor Total' )

Return(oModel)

/*/{Protheus.doc} ViewDef
Função que cria o objeto View	
@type function
@version 1.0 
@author Wellington Gonçalves
@since 11/05/2016
@return object, objeto da view
/*/
Static Function ViewDef()

	Local oStruU20 	:= FWFormStruct(2,'U26')
	Local oStruU21 	:= FWFormStruct(2,'U27')
	Local oModel   	:= FWLoadModel('RCPGA023')
	Local oView
	Local oCalc1

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	// crio o totalizador
	oCalc1 := FWCalcStruct( oModel:GetModel( 'CALC1') )

	oView:AddField('VIEW_U26'	, oStruU20	, 'U26MASTER') // cria o cabeçalho
	oView:AddGrid('VIEW_U27'	, oStruU21	, 'U27DETAIL') // Cria o grid
	oView:AddField('VIEW_CALC1'	, oCalc1	, 'CALC1' )

	// Crio os Panel's horizontais 
	oView:CreateHorizontalBox('PANEL_CABECALHO' , 45)
	oView:CreateHorizontalBox('PANEL_ITENS'		, 45)
	oView:CreateHorizontalBox('PANEL_CALC'		, 10)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_U26' 	, 'PANEL_CABECALHO')
	oView:SetOwnerView('VIEW_U27' 	, 'PANEL_ITENS')
	oView:SetOwnerView('VIEW_CALC1' , 'PANEL_CALC')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_U26')
	oView:EnableTitleView('VIEW_U27')

	// Define campos que terao Auto Incremento
	oView:AddIncrementField( 'VIEW_U27', 'U27_ITEM' )

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

Return(oView)

/*/{Protheus.doc} RCPGA23LEG
funcao de legenda
@type function
@version 1.0
@author g.sampaio
@since 07/10/2020
/*/
User Function RCPGA23LEG()

	BrwLegenda("Status do Apontamento"  ,"Legenda",;
		{{"BR_BRANCO"           ,"Provisionada"},;
		{"BR_VERDE"             ,"Efetivada"},;
		{"BR_VERMELHO"          ,"Finalizada"};
		})

Return(Nil)

/*/{Protheus.doc} RCPGA23EF
funcao de estorno financeiro
@type function
@version 1.0
@author g.sampaio
@since 07/10/2020
/*/
User Function RCPGA23EF(nRecnoU26)

	Local aArea     := GetArea()
	Local aAreaU26  := U26->(GetArea())
	Local lContinua := .T.

	Default nRecnoU26 := 0

	// posiciono no recno enviado
	U26->( DbGoTo(nRecnoU26) )

	// para caso estiver efetivoado
	if U26->U26_STATUS == "2" // status cancelado

		// Executa destacado e centralizado
		FWMsgRun(, {|oSay| lContinua := U_RCPGE054( U26->(Recno()) )}, "Aguarde", "Realizando o estorno dos Títulos a Receber gerados para a manutenção...")

		// faco o estorno sem excluir
		if lContinua

			// gravo o status de cancelado
			if U26->(RecLock("U26", .F.))
				U26->U26_STATUS := "1" // status provisionado
				U26->(MsUnLock())
			else
				U26->(DisarmTransaction())
			endIf

		endIf

	elseIf U26->U26_STATUS == "1" // status pendente

		// mensagem de alerta para o usuario
		MsgAlert("Não é possível realizar o estorno financeiro de manutenção sem estar efetivada!")

	elseIf U26->U26_STATUS == "3" // status finalizado

		// mensagem de alerta para o usuario
		MsgAlert("Não é possível realizar o estorno financeiro de manutenção que já esteja finalizada!")

	else

		// mensagem de alerta para o usuario
		MsgAlert("Manutenção não encontrada!")

	endIf

	RestArea(aAreaU26)
	RestArea(aArea)

Return(Nil)
