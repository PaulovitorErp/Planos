#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RCPGA003 � Autor � Wellington Gon�alves � Data� 19/02/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de cadastro de cremat�rio.						  ���
���          � - Cremat�rio >> Nichos		                              ���
�������������������������������������������������������������������������͹��
���Uso       � Vale do Cerrado                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RCPGA003()      

Local aCoors 	:= FWGetDialogSize( oMainWnd )   
Local cTitulo	:= "Cremat�rios" 
Local oPanelUp    
Local oPanelDown
Local oFWLayer
Local oBrowseUp
Local oBrowseDown
Local oRelacU12
Private oDlgPrinc

DEFINE MSDIALOG oDlgPrinc Title cTitulo  From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

// Cria o conteiner onde ser�o colocados os browses
oFWLayer := FWLayer():New() 
oFWLayer:Init( oDlgPrinc, .F., .T. )

////////////////////////// PAINEL SUPERIOR /////////////////////////////

// Cria uma "linha" com 50% da tela
oFWLayer:AddLine( 'UP', 40, .F. ) 

// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oFWLayer:AddCollumn( 'COLUN_UP', 100, .T., 'UP' )

// Pego o objeto desse peda�o do container
oPanelUp := oFWLayer:GetColPanel( 'COLUN_UP', 'UP' )

////////////////////////// PAINEL CENTRAL ///////////////////////////// 

// Cria uma "linha" com 2% da tela, apenas para dar um espa�o entre os grids
oFWLayer:AddLine( 'CENTER_LINE', 2, .F. )

////////////////////////// PAINEL INFERIOR /////////////////////////////   

// Cria uma "linha" com 48% da tela
oFWLayer:AddLine( 'DOWN', 58, .F. ) 

// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
oFWLayer:AddCollumn( 'COLUN_DOWN', 100, .T., 'DOWN' )  

oPanelDown := oFWLayer:GetColPanel( 'COLUN_DOWN' , 'DOWN' ) 

////////////////////// MONTO O BROWSER DO CREMATORIO ////////////////////////

oBrowseUp := FWmBrowse():New()
oBrowseUp :SetOwner( oPanelUp ) 

// Atribuo o t�tulo do Browser
oBrowseUp:SetDescription( "Cremat�rios" )

// Atribuo o nome da tabela
oBrowseUp:SetAlias( 'U11' )

// Habilito a visualiza��o do Menu
oBrowseUp:SetMenuDef( 'RCPGA003' )  

// Desabilito o detalhamento do browser
oBrowseUp:DisableDetails() 

oBrowseUp:SetProfileID( '1' )
oBrowseUp:ForceQuitButton() 

// adiciona legenda no Browser
oBrowseUp:AddLegend( "U11_STATUS == 'S'"	, "GREEN", "Ativo")
oBrowseUp:AddLegend( "U11_STATUS == 'N'"	, "RED"  , "Inativo")  

oBrowseUp:Activate()

////////////////////// MONTO O BROWSER DE NICHOS //////////////////////// 

oBrowseDown := FWMBrowse():New()
oBrowseDown :SetOwner( oPanelDown )

// Atribuo o t�tulo do Browser
oBrowseDown :SetDescription( 'Nichos' )     

// Desabilito a visualiza��o do Menu, pois o usu�rio n�o pode incluir um nicho individualmente
oBrowseDown :SetMenuDef('') 

// Desabilito o detalhamento do browser
oBrowseDown:DisableDetails() 

// Atribuo o nome da tabela
oBrowseDown:SetAlias( 'U12' ) 

oBrowseDown:SetProfileID( '2' )

// adiciona legenda no Browser
oBrowseDown:AddLegend( "U12_STATUS == 'S'"	, "GREEN", "Ativo")
oBrowseDown:AddLegend( "U12_STATUS == 'N'"	, "RED"  , "Inativo") 

oBrowseDown:Activate()

////////////////////// DEFINO O RELACIONAMENTO ENTRE OS BROWSER's //////////////////////// 

oRelacU12 := FWBrwRelation():New()
oRelacU12:AddRelation( oBrowseUp , oBrowseDown , { { 'U12_FILIAL', 'xFilial( "U12" )' }, { 'U12_CREMAT' , 'U11_CODIGO' } } )
oRelacU12:Activate()    

Activate MsDialog oDlgPrinc Center

Return NIL 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MenuDef � Autor � Wellington Gon�alves � Data � 19/02/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que cria os menus									  ���
�������������������������������������������������������������������������͹��
���Uso       � Vale do Cerrado                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   	Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.RCPGA003' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.RCPGA003' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.RCPGA003' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.RCPGA003' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.RCPGA003' 	OPERATION 08 ACCESS 0
ADD OPTION aRotina Title 'Copiar'      	Action 'VIEWDEF.RCPGA003' 	OPERATION 09 ACCESS 0  
ADD OPTION aRotina Title 'Legenda'     	Action 'U_CPGA003LEG()' 	OPERATION 10 ACCESS 0    

Return(aRotina)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ModelDef � Autor � Wellington Gon�alves � Data �19/02/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que cria o objeto model							  ���
�������������������������������������������������������������������������͹��
���Uso       � Vale do Cerrado                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ModelDef()

Local oStruU11 := FWFormStruct( 1, 'U11', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruU12 := FWFormStruct( 1, 'U12', /*bAvalCampo*/, /*lViewUsado*/ ) 
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PCPGA003', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABE�ALHO - CREMATORIO  ////////////////////////////

// Crio a Enchoice com os campos do cadastro do cremat�rio
oModel:AddFields( 'U11MASTER', /*cOwner*/, oStruU11 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "U11_FILIAL" , "U11_CODIGO" })    

// Preencho a descri��o da entidade
oModel:GetModel('U11MASTER'):SetDescription('Cremat�rio:')

///////////////////////////  ITENS - NICHOS  //////////////////////////////

// Crio o grid de nichos
oModel:AddGrid( 'U12DETAIL', 'U11MASTER', oStruU12, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Fa�o o relaciomaneto entre o nicho e o crematorio
oModel:SetRelation( 'U12DETAIL', { { 'U12_FILIAL', 'xFilial( "U12" )' } , { 'U12_CREMAT', 'U11_CODIGO' } } , U12->(IndexKey(1)) )  

// Seto a propriedade de n�o obrigatoriedade do preenchimento do grid
oModel:GetModel('U12DETAIL'):SetOptional( .T. ) 

// Preencho a descri��o da entidade
oModel:GetModel('U12DETAIL'):SetDescription('Nichos:') 

// N�o permitir duplicar o c�digo do nicho
oModel:GetModel('U12DETAIL'):SetUniqueLine( {'U12_CODIGO'} ) 

Return(oModel)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ViewDef � Autor � Wellington Gon�alves � Data � 19/02/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que cria o objeto View							  ���
�������������������������������������������������������������������������͹��
���Uso       � Vale do Cerrado                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ViewDef()

Local oStruU11 	:= FWFormStruct(2,'U11')
Local oStruU12 	:= FWFormStruct(2,'U12') 
Local oModel   	:= FWLoadModel('RCPGA003')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_U11'	, oStruU11, 'U11MASTER') // cria o cabe�alho - Crematorio
oView:AddGrid('VIEW_U12'	, oStruU12, 'U12DETAIL') // Cria o grid - Nichos

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CREMATORIO' , 20)
oView:CreateHorizontalBox('PANEL_NICHO'		 , 80)    

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_U11' , 'PANEL_CREMATORIO')
oView:SetOwnerView('VIEW_U12' , 'PANEL_NICHO')    

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_U11')
oView:EnableTitleView('VIEW_U12') 

// Define fechamento da tela ao confirmar a opera��o
oView:SetCloseOnOk({||.T.})

Return(oView)                         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CPGA003LEG� Autor � Wellington Gon�alves � Data� 19/02/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Legenda do browser de cadastro de cremat�rio				  ���
�������������������������������������������������������������������������͹��
���Uso       � Vale do Cerrado                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CPGA003LEG()

BrwLegenda("Status do Cremat�rio","Legenda",{ {"BR_VERDE","Ativo"},{"BR_VERMELHO","Inativo"} })

Return()