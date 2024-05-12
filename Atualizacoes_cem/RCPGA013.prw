#Include "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RCPGA013
Cadastro de hist๓rico de reajuste de contratos.	
@type function
@version 
@author Wellington Gon็alves
@since 06/04/2016
@param cCodContrato, character, codigo do contrato corrente
@return return_type, return_description
/*/
User Function RCPGA013(cCodContrato)

	Local aArea		:= GetArea()
	Local aAreaU00	:= U00->( GetArea() )
	Local oBrowse
	Local cName 	:= Funname()

	Default cCodContrato	:= ""

	// Altero o nome da rotina para considerar o menu deste MVC
	SetFunName("RCPGA013")

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'U20' )
	oBrowse:SetDescription( 'Hist๓rico de Reajuste de Contratos' )

	// verifico se estou na rotina de contrato
	If !Empty(cCodContrato)

		// posiciono cadastro de contrato
		U00->( DbSetOrder(1) )
		if U00->( MsSeek( xFilial("U00")+cCodContrato ) )

			// pergunto ao usuario se quer filtrar apenas os apontamentos do contrato
			If MsgYesNo("Deseja filtrar os Reajustes do contrato posicionado?")
				oBrowse:SetFilterDefault( "U20_FILIAL == '"+ U00->U00_MSFIL +"' .And. U20_CONTRA=='" + U00->U00_CODIGO + "'" ) // filtro apenas o contrato selecionado
			EndIf

		EndIf

	EndIf

	oBrowse:Activate()

	// Retorno o nome da rotina
	SetFunName(cName)

	RestArea(aAreaU00)
	RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MenuDef บ Autor ณ Wellington Gon็alves บ Data ณ 06/04/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que cria os menus									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Vale do Cerrado                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MenuDef()

	Local aRotina := {}

//valido se o usuario tem permissao de alterar o reajuste
	If RetCodUsr() $ Alltrim( SuperGetMV("MV_XTUSRRE",,'000000/000001') )
		ADD OPTION aRotina Title "Alterar"				Action "U_RCPGE009()"	OPERATION 4 ACCESS 0
	endif

	ADD OPTION aRotina Title 'Pesquisar'   			Action 'PesqBrw'          	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  			Action 'VIEWDEF.RCPGA013' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     			Action 'VIEWDEF.RCPGA013' 	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    			Action 'VIEWDEF.RCPGA013' 	OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Exclusใo em lote'		Action 'U_RCPGA032()' 		OPERATION 10 ACCESS 0

Return(aRotina)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ModelDef บ Autor ณ Wellington Gon็alves บ Data ณ06/04/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que cria o objeto model							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Vale do Cerrado                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ModelDef()

	Local oStruU20 := FWFormStruct( 1, 'U20', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruU21 := FWFormStruct( 1, 'U21', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel

// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PCPGA013', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABEวALHO - REAJUSTE  ////////////////////////////

// Crio a Enchoice com os campos do reajuste
	oModel:AddFields( 'U20MASTER', /*cOwner*/, oStruU20 )

// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "U20_FILIAL" , "U20_CODIGO" })

// Preencho a descri็ใo da entidade
	oModel:GetModel('U20MASTER'):SetDescription('Dados do Reajuste:')

///////////////////////////  ITENS - PARCELAS REAJUSTADAS  //////////////////////////////

// Crio o grid de parcelas reajustadas
	oModel:AddGrid( 'U21DETAIL', 'U20MASTER', oStruU21, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Fa็o o relaciomaneto entre o cabe็alho e os itens
	oModel:SetRelation( 'U21DETAIL', { { 'U21_FILIAL', 'xFilial( "U21" )' } , { 'U21_CODIGO', 'U20_CODIGO' } } , U21->(IndexKey(1)) )

// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel('U21DETAIL'):SetOptional( .F. )

// Preencho a descri็ใo da entidade
	oModel:GetModel('U21DETAIL'):SetDescription('Tํtulos Reajustados:')

// Nใo permitir duplicar a chave da parcela
	oModel:GetModel('U21DETAIL'):SetUniqueLine( {'U21_PREFIX','U21_NUM','U21_PARCEL','U21_TIPO'} )

//////////////////////////  TOTALIZADORES  //////////////////////////////////

	oModel:AddCalc( 'CALC1', 'U20MASTER', 'U21DETAIL', 'U21_ACRINI', 'ACRESCIMO_ANTERIOR'	, 'SUM'		,,,'Acrescimo anterior' )
	oModel:AddCalc( 'CALC1', 'U20MASTER', 'U21DETAIL', 'U21_VLADIC', 'ADICIONAL'			, 'SUM'		,,,'Adicional aplicado' )
	oModel:AddCalc( 'CALC1', 'U20MASTER', 'U21DETAIL', 'U21_ACRFIM', 'ACRESCIMO_ATUAL'		, 'SUM'		,,,'Acrescimo atual' )

Return(oModel)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ViewDef บ Autor ณ Wellington Gon็alves บ Data ณ 06/04/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que cria o objeto View							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Vale do Cerrado                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ViewDef()

	Local oStruU20 	:= FWFormStruct(2,'U20')
	Local oStruU21 	:= FWFormStruct(2,'U21')
	Local oModel   	:= FWLoadModel('RCPGA013')
	Local oView
	Local oCalc1

// Cria o objeto de View
	oView := FWFormView():New()

// Define qual o Modelo de dados serแ utilizado
	oView:SetModel(oModel)

// crio o totalizador
	oCalc1 := FWCalcStruct( oModel:GetModel( 'CALC1') )

	oView:AddField('VIEW_U20'	, oStruU20	, 'U20MASTER') // cria o cabe็alho
	oView:AddGrid('VIEW_U21'	, oStruU21	, 'U21DETAIL') // Cria o grid
	oView:AddField('VIEW_CALC1'	, oCalc1	, 'CALC1' )

// Crio os Panel's horizontais 
	oView:CreateHorizontalBox('PANEL_CABECALHO' , 17)
	oView:CreateHorizontalBox('PANEL_ITENS'		, 73)
	oView:CreateHorizontalBox('PANEL_CALC'		, 10)

// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_U20' , 'PANEL_CABECALHO')
	oView:SetOwnerView('VIEW_U21' , 'PANEL_ITENS')
	oView:SetOwnerView('VIEW_CALC1' , 'PANEL_CALC')

// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_U20')
	oView:EnableTitleView('VIEW_U21')

// Define campos que terao Auto Incremento
	oView:AddIncrementField( 'VIEW_U21', 'U21_ITEM' )

// Define fechamento da tela ao confirmar a opera็ใo
	oView:SetCloseOnOk({||.T.})

Return(oView)
