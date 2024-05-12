#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RFUNA026 บ Autor ณ Raphael Martins 	   บ Dataณ 28/03/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cadastro de hist๓rico de adiantamento de parcelas 		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funeraria		                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function RFUNA026()      

Local oBrowse
Local cName := Funname()

// Altero o nome da rotina para considerar o menu deste MVC
SetFunName("RFUNA026")

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'UG8' )
oBrowse:SetDescription( 'Hist๓rico de Adiantamento de Parcelas' ) 

oBrowse:Activate()

// Retorno o nome da rotina
SetFunName(cName)

Return NIL 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MenuDef บ Autor ณ Raphael Martins	  บ Data ณ 28/03/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que cria os menus									  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funeraria	                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   			Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     			Action 'VIEWDEF.RFUNA026' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  			Action 'VIEWDEF.RFUNA026' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     			Action 'VIEWDEF.RFUNA026' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    			Action 'VIEWDEF.RFUNA026' 	OPERATION 08 ACCESS 0

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ModelDef บ Autor ณ Raphael Martins      บ Data ณ28/03/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que cria o objeto model							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funeraria		                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ModelDef()

Local oStruUG8 := FWFormStruct( 1, 'UG8', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruUG9 := FWFormStruct( 1, 'UG9', /*bAvalCampo*/, /*lViewUsado*/ ) 
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PFUNA026', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABEวALHO - DADOS DO ADIANTAMENTO  ////////////////////////////

// Crio a Enchoice com os campos do adiantamento
oModel:AddFields( 'UG8MASTER', /*cOwner*/, oStruUG8 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "UG8_FILIAL" , "UG8_CODIGO" })    

// Preencho a descri็ใo da entidade
oModel:GetModel('UG8MASTER'):SetDescription('Dados do Adiantamento:')

///////////////////////////  ITENS - TITULOS GERADOS  //////////////////////////////

// Crio o grid de titulos
oModel:AddGrid( 'UG9DETAIL', 'UG8MASTER', oStruUG9, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Fa็o o relaciomaneto entre o cabe็alho e os itens
oModel:SetRelation( 'UG9DETAIL', { { 'UG9_FILIAL', 'xFilial( "UG9" )' } , { 'UG9_CODIGO', 'UG8_CODIGO' } } , UG9->(IndexKey(1)) )  

// Seto a propriedade de obrigatoriedade do preenchimento do grid
oModel:GetModel('UG9DETAIL'):SetOptional( .F. ) 

// Preencho a descri็ใo da entidade
oModel:GetModel('UG9DETAIL'):SetDescription('Tํtulos Gerados:') 

// Nใo permitir duplicar a chave da parcela
oModel:GetModel('UG9DETAIL'):SetUniqueLine( {'UG9_PREFIX','UG9_NUM','UG9_PARCEL','UG9_TIPO'} ) 

//////////////////////////  TOTALIZADORES  //////////////////////////////////
  
oModel:AddCalc( 'CALC1', 'UG8MASTER', 'UG9DETAIL', 'UG9_VALOR', 'TOTAL'	, 'SUM'		,,,'Valor Total' )

Return(oModel)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ViewDef บ Autor ณ Raphael Martins	  บ Data ณ 02/08/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que cria o objeto View							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funeraria		                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ViewDef()

Local oStruUG8 	:= FWFormStruct(2,'UG8')
Local oStruUG9 	:= FWFormStruct(2,'UG9') 
Local oModel   	:= FWLoadModel('RFUNA026')
Local oView
Local oCalc1

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados serแ utilizado
oView:SetModel(oModel)

// crio o totalizador
oCalc1 := FWCalcStruct( oModel:GetModel( 'CALC1') )

oView:AddField('VIEW_UG8'	, oStruUG8	, 'UG8MASTER') // cria o cabe็alho
oView:AddGrid('VIEW_UG9'	, oStruUG9	, 'UG9DETAIL') // Cria o grid
oView:AddField('VIEW_CALC1'	, oCalc1	, 'CALC1' ) 

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABECALHO' , 30)
oView:CreateHorizontalBox('PANEL_ITENS'		, 60)   
oView:CreateHorizontalBox('PANEL_CALC'		, 10)   

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_UG8' , 'PANEL_CABECALHO')
oView:SetOwnerView('VIEW_UG9' , 'PANEL_ITENS')    
oView:SetOwnerView('VIEW_CALC1' , 'PANEL_CALC') 

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_UG8')
oView:EnableTitleView('VIEW_UG9') 

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_UG9', 'UG9_ITEM' )

// Define fechamento da tela ao confirmar a opera็ใo
oView:SetCloseOnOk({||.T.})

Return(oView)                         