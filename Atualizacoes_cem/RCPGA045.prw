#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*/{Protheus.doc} RCPGA045
rotina de histórico de adiantamento de parcelas 
de locacao de nicho
@type function
@version 
@author g.sampaio
@since 05/04/2020
@return return_type, return_description
/*/
User Function RCPGA045()      

Local oBrowse
Local cName := Funname()

// Altero o nome da rotina para considerar o menu deste MVC
SetFunName("RCPGA045")

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'U76' )
oBrowse:SetDescription( 'Histórico de Adiantamento de Parcelas' ) 

oBrowse:Activate()

// Retorno o nome da rotina
SetFunName(cName)

Return NIL 

/*/{Protheus.doc} MenuDef
Função que cria os menus
@type function
@version 
@author g.sampaio
@since 05/04/2020
@return return_type, return_description
/*/
Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   			Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     			Action 'VIEWDEF.RCPGA045' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  			Action 'VIEWDEF.RCPGA045' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     			Action 'VIEWDEF.RCPGA045' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    			Action 'VIEWDEF.RCPGA045' 	OPERATION 08 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
Função que cria o objeto model
@type function
@version 
@author g.sampaio
@since 05/04/2020
@return return_type, return_description
/*/
Static Function ModelDef()

Local oStruU76 := FWFormStruct( 1, 'U76', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruU77 := FWFormStruct( 1, 'U77', /*bAvalCampo*/, /*lViewUsado*/ ) 
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PFUNA026', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABEÇALHO - DADOS DO ADIANTAMENTO  ////////////////////////////

// Crio a Enchoice com os campos do adiantamento
oModel:AddFields( 'U76MASTER', /*cOwner*/, oStruU76 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "U76_FILIAL" , "U76_CODIGO" })    

// Preencho a descrição da entidade
oModel:GetModel('U76MASTER'):SetDescription('Dados do Adiantamento:')

///////////////////////////  ITENS - TITULOS GERADOS  //////////////////////////////

// Crio o grid de titulos
oModel:AddGrid( 'U77DETAIL', 'U76MASTER', oStruU77, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faço o relaciomaneto entre o cabeçalho e os itens
oModel:SetRelation( 'U77DETAIL', { { 'U77_FILIAL', 'xFilial( "U77" )' } , { 'U77_CODIGO', 'U76_CODIGO' } } , U77->(IndexKey(1)) )  

// Seto a propriedade de obrigatoriedade do preenchimento do grid
oModel:GetModel('U77DETAIL'):SetOptional( .F. ) 

// Preencho a descrição da entidade
oModel:GetModel('U77DETAIL'):SetDescription('Títulos Gerados:') 

// Não permitir duplicar a chave da parcela
oModel:GetModel('U77DETAIL'):SetUniqueLine( {'U77_PREFIX','U77_NUM','U77_PARCEL','U77_TIPO'} ) 

//////////////////////////  TOTALIZADORES  //////////////////////////////////
  
oModel:AddCalc( 'CALC1', 'U76MASTER', 'U77DETAIL', 'U77_VALOR', 'TOTAL'	, 'SUM'		,,,'Valor Total' )

Return(oModel)

/*/{Protheus.doc} ViewDef
Função que cria o objeto View
@type function
@version 
@author g.sampaio
@since 05/04/2020
@return return_type, return_description
/*/
Static Function ViewDef()

Local oStruU76 	:= FWFormStruct(2,'U76')
Local oStruU77 	:= FWFormStruct(2,'U77') 
Local oModel   	:= FWLoadModel('RCPGA045')
Local oView
Local oCalc1

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

// crio o totalizador
oCalc1 := FWCalcStruct( oModel:GetModel( 'CALC1') )

oView:AddField('VIEW_U76'	, oStruU76	, 'U76MASTER') // cria o cabeçalho
oView:AddGrid('VIEW_U77'	, oStruU77	, 'U77DETAIL') // Cria o grid
oView:AddField('VIEW_CALC1'	, oCalc1	, 'CALC1' ) 

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABECALHO' , 30)
oView:CreateHorizontalBox('PANEL_ITENS'		, 60)   
oView:CreateHorizontalBox('PANEL_CALC'		, 10)   

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_U76' , 'PANEL_CABECALHO')
oView:SetOwnerView('VIEW_U77' , 'PANEL_ITENS')    
oView:SetOwnerView('VIEW_CALC1' , 'PANEL_CALC') 

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_U76')
oView:EnableTitleView('VIEW_U77') 

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_U77', 'U77_ITEM' )

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk({||.T.})

Return(oView)                         