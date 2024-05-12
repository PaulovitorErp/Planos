#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*/{Protheus.doc} RFUNA028
//TODO Rotina de Historico de Taxa de Manutencao - Funeraria.
@author Raphael Martins
@since 03/04/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

User Function RFUNA028()      

Local oBrowse
Local cName := Funname()

// Altero o nome da rotina para considerar o menu deste MVC
SetFunName("RFUNA028")

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'UH0' )
oBrowse:SetDescription( 'Histórico de Taxa de Manutenção' ) 

oBrowse:Activate()

// Retorno o nome da rotina
SetFunName(cName)

Return NIL 

/*/{Protheus.doc} RFUNA028
//TODO Função que cria os menus	
@author Raphael Martins
@since 03/04/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   			Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  			Action 'VIEWDEF.RFUNA028' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     			Action 'VIEWDEF.RFUNA028' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     			Action 'VIEWDEF.RFUNA028' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     			Action 'VIEWDEF.RFUNA028' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    			Action 'VIEWDEF.RFUNA028' 	OPERATION 08 ACCESS 0
ADD OPTION aRotina Title 'Exclusão em lote'		Action 'U_RFUNA030()' 		OPERATION 10 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} RFUNA028
//TODO Função que cria o objeto model	
@author Raphael Martins
@since 03/04/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function ModelDef()

Local oStruUH0 := FWFormStruct( 1, 'UH0', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruUH1 := FWFormStruct( 1, 'UH1', /*bAvalCampo*/, /*lViewUsado*/ ) 
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PFUNA028', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABEÇALHO - TAXA  ////////////////////////////

// Crio a Enchoice com os campos da taxa
oModel:AddFields( 'UH0MASTER', /*cOwner*/, oStruUH0 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "UH0_FILIAL" , "UH0_CODIGO" })    

// Preencho a descrição da entidade
oModel:GetModel('UH0MASTER'):SetDescription('Taxa:')

///////////////////////////  ITENS - TITULOS  //////////////////////////////

// Crio o grid de títulos
oModel:AddGrid( 'UH1DETAIL', 'UH0MASTER', oStruUH1, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faço o relaciomaneto entre o cabeçalho e os itens
oModel:SetRelation( 'UH1DETAIL', { { 'UH1_FILIAL', 'xFilial( "UH1" )' } , { 'UH1_CODIGO', 'UH0_CODIGO' } } , UH1->(IndexKey(1)) )  

// Seto a propriedade de obrigatoriedade do preenchimento do grid
oModel:GetModel('UH1DETAIL'):SetOptional( .F. ) 

// Preencho a descrição da entidade
oModel:GetModel('UH1DETAIL'):SetDescription('Títulos:') 

// Não permitir duplicar a chave da parcela
oModel:GetModel('UH1DETAIL'):SetUniqueLine( {'UH1_PREFIX','UH1_NUM','UH1_PARCEL','UH1_TIPO'} ) 

//////////////////////////  TOTALIZADORES  //////////////////////////////////
  
oModel:AddCalc( 'CALC1', 'UH0MASTER', 'UH1DETAIL', 'UH1_VALOR', 'VALOR'	, 'SUM'		,,,'Valor Total' )

Return(oModel)

/*/{Protheus.doc} RFUNA028
//TODO Função que cria o objeto View	
@author Raphael Martins
@since 03/04/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function ViewDef()

Local oStruU20 	:= FWFormStruct(2,'UH0')
Local oStruU21 	:= FWFormStruct(2,'UH1') 
Local oModel   	:= FWLoadModel('RFUNA028')
Local oView 
Local oCalc1		

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

// crio o totalizador
oCalc1 := FWCalcStruct( oModel:GetModel( 'CALC1') )

oView:AddField('VIEW_UH0'	, oStruU20	, 'UH0MASTER') // cria o cabeçalho
oView:AddGrid('VIEW_UH1'	, oStruU21	, 'UH1DETAIL') // Cria o grid
oView:AddField('VIEW_CALC1'	, oCalc1	, 'CALC1' ) 

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABECALHO' , 25)
oView:CreateHorizontalBox('PANEL_ITENS'		, 65)   
oView:CreateHorizontalBox('PANEL_CALC'		, 10)   

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_UH0' 	, 'PANEL_CABECALHO')
oView:SetOwnerView('VIEW_UH1' 	, 'PANEL_ITENS')    
oView:SetOwnerView('VIEW_CALC1' , 'PANEL_CALC') 

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_UH0')
oView:EnableTitleView('VIEW_UH1') 

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_UH1', 'UH1_ITEM' )

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk({||.T.})

Return(oView)                         