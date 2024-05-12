#Include "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RFUNA011
Cadastro de hist�rico de reajuste de contratos da funer�ria
@type function
@version 1.0
@author Wellington Gon�alves
@since 02/08/2016
/*/
User Function RFUNA011()

	Local oBrowse
	Local cName := Funname()

	// Altero o nome da rotina para considerar o menu deste MVC
	SetFunName("RFUNA011")

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'UF7' )

	If FwIsInCallStack("U_RFUNA002")
		// pergunto ao usuario se quer filtrar apenas os apontamentos do contrato
		If MsgYesNo("Deseja filtrar o hist�rico de reajuste do contrato posicionado?")
			oBrowse:SetFilterDefault( "UF7_FILIAL == '"+ xFilial("UF7",UF2->UF2_MSFIL) +"' .And. UF7_CONTRA=='" + UF2->UF2_CODIGO + "'" ) // filtro apenas o contrato selecionado
		EndIf
	EndIf

	oBrowse:SetDescription( 'Hist�rico de Reajuste de Contratos' )

	oBrowse:Activate()

	// Retorno o nome da rotina
	SetFunName(cName)

Return NIL

/*/{Protheus.doc} MenuDef
Fun��o que cria os menus		
@type function
@version 1.0
@author Wellington Gon�alves
@since 02/08/2016
@return array, menu de rotinas
/*/
Static Function MenuDef()

	Local aRotina := {}

//valido se o usuario tem permissao de alterar o reajuste
	If RetCodUsr() $ Alltrim( SuperGetMV("MV_XTUSRRE",,'000000/000001') )
		ADD OPTION aRotina Title "Alterar"				Action "U_RFUNE027()"	OPERATION 4 ACCESS 0
	endif

	ADD OPTION aRotina Title 'Pesquisar'   			Action 'PesqBrw'          	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  			Action 'VIEWDEF.RFUNA011' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     			Action 'VIEWDEF.RFUNA011' 	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    			Action 'VIEWDEF.RFUNA011' 	OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Exclus�o em lote'		Action 'U_RFUNA020()' 		OPERATION 10 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
Fun��o que cria o objeto model	
@type function
@version 1.0
@author Wellington Gon�alves
@since 02/08/2016
@return object, model do mvc
/*/
Static Function ModelDef()

	Local oStruUF7 := FWFormStruct( 1, 'UF7', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruUF8 := FWFormStruct( 1, 'UF8', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PFUNA011', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	/////////////////////////  CABE�ALHO - REAJUSTE  ////////////////////////////

	// Crio a Enchoice com os campos do reajuste
	oModel:AddFields( 'UF7MASTER', /*cOwner*/, oStruUF7 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "UF7_FILIAL" , "UF7_CODIGO" })

	// Preencho a descri��o da entidade
	oModel:GetModel('UF7MASTER'):SetDescription('Dados do Reajuste:')

	///////////////////////////  ITENS - TITULOS GERADOS  //////////////////////////////

	// Crio o grid de titulos
	oModel:AddGrid( 'UF8DETAIL', 'UF7MASTER', oStruUF8, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Fa�o o relaciomaneto entre o cabe�alho e os itens
	oModel:SetRelation( 'UF8DETAIL', { { 'UF8_FILIAL', 'xFilial( "UF8" )' } , { 'UF8_CODIGO', 'UF7_CODIGO' } } , UF8->(IndexKey(1)) )

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel('UF8DETAIL'):SetOptional( .F. )

	// Preencho a descri��o da entidade
	oModel:GetModel('UF8DETAIL'):SetDescription('T�tulos Gerados:')

	// N�o permitir duplicar a chave da parcela
	oModel:GetModel('UF8DETAIL'):SetUniqueLine( {'UF8_PREFIX','UF8_NUM','UF8_PARCEL','UF8_TIPO'} )

	//////////////////////////  TOTALIZADORES  //////////////////////////////////
	oModel:AddCalc( 'CALC1', 'UF7MASTER', 'UF8DETAIL', 'UF8_VALOR', 'TOTAL'	, 'SUM'		,,,'Valor Total' )

Return(oModel)

/*/{Protheus.doc} ViewDef
Fun��o que cria o objeto View
@type function
@version 1.0
@author Wellington Gon�alves
@since 02/08/2016
@return object, objeto da view do MVC
/*/
Static Function ViewDef()

	Local oStruUF7 	:= FWFormStruct(2,'UF7')
	Local oStruUF8 	:= FWFormStruct(2,'UF8')
	Local oModel   	:= FWLoadModel('RFUNA011')
	Local oView
	Local oCalc1

		// Cria o objeto de View
	oView := FWFormView():New()

		// Define qual o Modelo de dados ser� utilizado
	oView:SetModel(oModel)

	// crio o totalizador
	oCalc1 := FWCalcStruct( oModel:GetModel( 'CALC1') )

	oView:AddField('VIEW_UF7'	, oStruUF7	, 'UF7MASTER') // cria o cabe�alho
	oView:AddGrid('VIEW_UF8'	, oStruUF8	, 'UF8DETAIL') // Cria o grid
	oView:AddField('VIEW_CALC1'	, oCalc1	, 'CALC1' )

	// Crio os Panel's horizontais 
	oView:CreateHorizontalBox('PANEL_CABECALHO' , 20)
	oView:CreateHorizontalBox('PANEL_ITENS'		, 70)
	oView:CreateHorizontalBox('PANEL_CALC'		, 10)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_UF7' , 'PANEL_CABECALHO')
	oView:SetOwnerView('VIEW_UF8' , 'PANEL_ITENS')
	oView:SetOwnerView('VIEW_CALC1' , 'PANEL_CALC')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_UF7')
	oView:EnableTitleView('VIEW_UF8')

	// Define campos que terao Auto Incremento
	oView:AddIncrementField( 'VIEW_UF8', 'UF8_ITEM' )

	// Define fechamento da tela ao confirmar a opera��o
	oView:SetCloseOnOk({||.T.})

Return(oView)
