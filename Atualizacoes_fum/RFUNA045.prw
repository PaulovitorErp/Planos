#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*###########################################################################
#############################################################################
## Programa  | RFUNA045 | Autor | Wellington Gonçalves | Data | 25/05/2019 ##
##=========================================================================##
## Desc.     | Histórico de Alteracões do Contrato da Funerária			   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

User Function RFUNA045()    

Local oBrowse 		:= NIL

// CONTRATO 
Private oScrlUF2	:= NIL
Private oPnlCpoUF2 	:= NIL

// BENEFICIARIOS
Private oPnlCpoUF4	:= NIL
Private oScrlUF4	:= NIL

// VALORES ADICIONAIS
Private oPnlCpoUJ9 	:= NIL
Private oScrlUJ9	:= NIL 

// PRODUTOS E SERVIÇOS
Private oScrlUF3 	:= NIL
Private oPnlCpoUF3	:= NIL

// MENSAGENS
Private oPnlCpoUF9	:= NIL
Private oScrlUF9	:= NIL
 
oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'U68' )
oBrowse:SetDescription( 'Histórico de Alteração de Contratos' ) 

oBrowse:Activate()  

Return NIL 

/*###########################################################################
#############################################################################
## Programa  | MenuDef | Autor | Wellington Gonçalves  | Data | 25/05/2019 ##
##=========================================================================##
## Desc.     | Função para criação dos Menus do Browser					   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.RFUNA045' 	OPERATION 02 ACCESS 0      
ADD OPTION aRotina Title 'Incluir' 	 	Action 'VIEWDEF.RFUNA045' 	OPERATION 03 ACCESS 0  
ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.RFUNA045' 	OPERATION 08 ACCESS 0

Return aRotina

/*###########################################################################
#############################################################################
## Programa  | ModelDef | Autor | Wellington Gonçalves | Data | 25/05/2019 ##
##=========================================================================##
## Desc.     | Função para criação do Model								   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

Static Function ModelDef()

Local oStruU68 	:= FWFormStruct( 1, 'U68', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruU69 	:= FWFormStruct( 1, 'U69', /*bAvalCampo*/, /*lViewUsado*/ ) 
Local oStruU70 	:= FWFormStruct( 1, 'U70', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruU71 	:= FWFormStruct( 1, 'U71', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruU72 	:= FWFormStruct( 1, 'U72', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruU73 	:= FWFormStruct( 1, 'U73', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel	:= NIL

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PFUNA045', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

///////////////////////////////////////////////////////////////////////////////
/////////////////////////  CABEÇALHO DA ALTERAÇÃO  ////////////////////////////
///////////////////////////////////////////////////////////////////////////////

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'U68MASTER', /*cOwner*/, oStruU68 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "U68_FILIAL" , "U68_CODIGO" })

///////////////////////////////////////////////////////////////////////////////
//////////////////////////  ABA DE BENEFICIARIOS  /////////////////////////////
///////////////////////////////////////////////////////////////////////////////

// Cria o Grid de inclusoes
oModel:AddGrid( 'IU69DETAIL', 'U68MASTER', oStruU69, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faço o relaciomaneto
oModel:SetRelation( 'IU69DETAIL', { { 'U69_FILIAL', 'xFilial( "U69" )' } , { 'U69_CODIGO', 'U68_CODIGO' } , { 'U69_TIPO', "'I'" } } , U69->( IndexKey( 1 ) ) )  

// Crio o Grid de exclusoes
oModel:AddGrid( 'EU69DETAIL', 'U68MASTER', oStruU69, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faço o relaciomaneto 
oModel:SetRelation( 'EU69DETAIL', { { 'U69_FILIAL', 'xFilial( "U69" )' } , { 'U69_CODIGO', 'U68_CODIGO' } , { 'U69_TIPO', "'E'" } } , U69->( IndexKey( 1 ) ) )  

// Crio o Grid de alterações
oModel:AddGrid( 'AU69DETAIL', 'U68MASTER', oStruU69, /*bLinePre*/,/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faço o relaciomaneto
oModel:SetRelation( 'AU69DETAIL', { { 'U69_FILIAL', 'xFilial( "U69" )' } , { 'U69_CODIGO', 'U68_CODIGO' } , { 'U69_TIPO', "'A'" } } , U69->( IndexKey( 1 ) ) )   

oModel:GetModel('IU69DETAIL'):SetOptional( .T. ) 
oModel:GetModel('AU69DETAIL'):SetOptional( .T. )  
oModel:GetModel('EU69DETAIL'):SetOptional( .T. )

/////////////////////////////////////////////////////////////////////////////
//////////////////////  ABA DE VALORES ADICIONAIS  //////////////////////////    
/////////////////////////////////////////////////////////////////////////////

// Crio o Grid de inclusoes
oModel:AddGrid( 'IU70DETAIL', 'U68MASTER', oStruU70, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faço o relaciomaneto 
oModel:SetRelation( 'IU70DETAIL', { { 'U70_FILIAL', 'xFilial( "U70" )' } , { 'U70_CODIGO', 'U68_CODIGO' } , { 'U70_TIPO', "'I'" } } , U70->( IndexKey( 1 ) ) )  

// Crio o Grid de exclusões
oModel:AddGrid( 'EU70DETAIL', 'U68MASTER', oStruU70, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faço o relaciomaneto 
oModel:SetRelation( 'EU70DETAIL', { { 'U70_FILIAL', 'xFilial( "U70" )' } , { 'U70_CODIGO', 'U68_CODIGO' } , { 'U70_TIPO', "'E'" } } , U70->( IndexKey( 1 ) ) )  

// Crio o Grid de alterações
oModel:AddGrid( 'AU70DETAIL', 'U68MASTER', oStruU70, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faço o relaciomaneto entre o adicional e o cabeçalho do contrato
oModel:SetRelation( 'AU70DETAIL', { { 'U70_FILIAL', 'xFilial( "U70" )' } , { 'U70_CODIGO', 'U68_CODIGO' } , { 'U70_TIPO', "'A'" } } , U70->( IndexKey( 1 ) ) )   

oModel:GetModel('IU70DETAIL'):SetOptional( .T. )
oModel:GetModel('EU70DETAIL'):SetOptional( .T. )  
oModel:GetModel('AU70DETAIL'):SetOptional( .T. )

////////////////////////////////////////////////////////////////////////////
///////////////////////////  ABA DE SERVIÇOS  //////////////////////////////    
////////////////////////////////////////////////////////////////////////////

// Crio o Grid de inclusões
oModel:AddGrid( 'IU71DETAIL', 'U68MASTER', oStruU71, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faço o relaciomaneto 
oModel:SetRelation( 'IU71DETAIL', { { 'U71_FILIAL', 'xFilial( "U71" )' } , { 'U71_CODIGO', 'U68_CODIGO' } , { 'U71_TIPO', "'I'" } } , U71->( IndexKey( 1 ) ) )  

// Crio o Grid de exclusões
oModel:AddGrid( 'EU71DETAIL', 'U68MASTER', oStruU71, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faço o relaciomaneto
oModel:SetRelation( 'EU71DETAIL', { { 'ZV_FILIAL', 'xFilial( "U71" )' } , { 'U71_CODIGO', 'U68_CODIGO' } , { 'U71_TIPO', "'E'" } } , U71->( IndexKey( 1 ) ) )  

// Crio o Grid de alterações
oModel:AddGrid( 'AU71DETAIL', 'U68MASTER', oStruU71, /*bLinePre*/,/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faço o relaciomaneto
oModel:SetRelation( 'AU71DETAIL', { { 'ZV_FILIAL', 'xFilial( "U71" )' } , { 'U71_CODIGO', 'U68_CODIGO' } , { 'U71_TIPO', "'A'" } } , U71->( IndexKey( 1 ) ) )   

oModel:GetModel('IU71DETAIL'):SetOptional( .T. ) 
oModel:GetModel('AU71DETAIL'):SetOptional( .T. )  
oModel:GetModel('EU71DETAIL'):SetOptional( .T. )

////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////  ABA DE MENSAGENS  ///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////    

// Crio o Grid de inclusões
oModel:AddGrid( 'IU72DETAIL', 'U68MASTER', oStruU72, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faço o relaciomaneto
oModel:SetRelation( 'IU72DETAIL', { { 'U72_FILIAL', 'xFilial( "U72" )' } , { 'U72_CODIGO', 'U68_CODIGO' } , { 'U72_TIPO', "'I'" } } , U72->( IndexKey( 1 ) ) )  

// Crio o Grid de exclusões
oModel:AddGrid( 'EU72DETAIL', 'U68MASTER', oStruU72, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faço o relaciomaneto 
oModel:SetRelation( 'EU72DETAIL', { { 'U72_FILIAL', 'xFilial( "U72" )' } , { 'U72_CODIGO', 'U68_CODIGO' } , { 'U72_TIPO', "'E'" } } , U72->( IndexKey( 1 ) ) )  

// Crio o Grid de alterações
oModel:AddGrid( 'AU72DETAIL', 'U68MASTER', oStruU72, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faço o relaciomaneto
oModel:SetRelation( 'AU72DETAIL', { { 'U72_FILIAL', 'xFilial( "U72" )' } , { 'U72_CODIGO', 'U68_CODIGO' } , { 'U72_TIPO', "'A'" } } , U72->( IndexKey( 1 ) ) )  

oModel:GetModel('IU72DETAIL'):SetOptional( .T. ) 
oModel:GetModel('EU72DETAIL'):SetOptional( .T. )  
oModel:GetModel('AU72DETAIL'):SetOptional( .T. )

///////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'U68MASTER'  ):SetDescription( 'Dados da alteração:' 	)
oModel:GetModel( 'IU69DETAIL' ):SetDescription( 'Inclusões:'  			)   
oModel:GetModel( 'AU69DETAIL' ):SetDescription( 'Alterações:'  			)
oModel:GetModel( 'EU69DETAIL' ):SetDescription( 'Exclusões:'  			) 
oModel:GetModel( 'IU71DETAIL' ):SetDescription( 'Inclusões:'  			)   
oModel:GetModel( 'AU71DETAIL' ):SetDescription( 'Alterações:'  			)
oModel:GetModel( 'EU71DETAIL' ):SetDescription( 'Exclusões:'  			) 
oModel:GetModel( 'IU72DETAIL' ):SetDescription( 'Inclusões:'  			)   
oModel:GetModel( 'EU72DETAIL' ):SetDescription( 'Exclusões:'  			)
oModel:GetModel( 'AU72DETAIL' ):SetDescription( 'Alterações:'  			) 

Return oModel

/*###########################################################################
#############################################################################
## Programa  | ModelDef | Autor | Wellington Gonçalves | Data | 25/05/2019 ##
##=========================================================================##
## Desc.     | Função para criação da View								   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

Static Function ViewDef()

Local oStruU68 	:= FWFormStruct( 2, 'U68' )
Local oStruU69 	:= FWFormStruct( 2, 'U69' ) 
Local oStruU70	:= FWFormStruct( 2, 'U70' )
Local oStruU71	:= FWFormStruct( 2, 'U71' )
Local oStruU72	:= FWFormStruct( 2, 'U72' )
Local oModel   	:= FWLoadModel( 'RFUNA045' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddField('VIEW_CABEC'	, oStruU68, 'U68MASTER' ) // cria o cabeçalho das alterações
oView:AddGrid('VIEW_IU69'	, oStruU69, 'IU69DETAIL' ) // grid de beneficiários incluídos  
oView:AddGrid('VIEW_AU69'	, oStruU69, 'AU69DETAIL' ) // grid de beneficiários alterados    
oView:AddGrid('VIEW_EU69'	, oStruU69, 'EU69DETAIL' ) // grid de beneficiários excluídos 
oView:AddGrid('VIEW_IU70'	, oStruU70, 'IU70DETAIL' ) // grid de valores adicionais incluídos  
oView:AddGrid('VIEW_AU70'	, oStruU70, 'AU70DETAIL' ) // grid de valores adicionais alterados    
oView:AddGrid('VIEW_EU70'	, oStruU70, 'EU70DETAIL' ) // grid de valores adicionais excluídos    
oView:AddGrid('VIEW_IU71'	, oStruU71, 'IU71DETAIL' ) // grid de produtos incluídos 
oView:AddGrid('VIEW_AU71'	, oStruU71, 'AU71DETAIL' ) // grid de produtos alterados 
oView:AddGrid('VIEW_EU71'	, oStruU71, 'EU71DETAIL' ) // grid de produtos excluídos 
oView:AddGrid('VIEW_IU72'	, oStruU72, 'IU72DETAIL' ) // grid de mensagens incluídas 
oView:AddGrid('VIEW_AU72'	, oStruU72, 'AU72DETAIL' ) // grid de mensagens alteradas 
oView:AddGrid('VIEW_EU72'	, oStruU72, 'EU72DETAIL' ) // grid de mensagens excluídas 

oView:AddOtherObject("VIEW_CAMPOSUF2", {|oPanel| MostraCampos(oPanel , "UF2")}) // cria o panel com os campos alterados do cabeçalho 
oView:AddOtherObject("VIEW_CAMPOSUF4", {|oPanel| MostraCampos(oPanel , "UF4")}) // cria o panel com os campos alterados do beneficiario    
oView:AddOtherObject("VIEW_CAMPOSUJ9", {|oPanel| MostraCampos(oPanel , "UJ9")}) // cria o panel com os campos alterados do valor adicionail
oView:AddOtherObject("VIEW_CAMPOSUF3", {|oPanel| MostraCampos(oPanel , "UF3")}) // cria o panel com os campos alterados do produto
oView:AddOtherObject("VIEW_CAMPOSUF9", {|oPanel| MostraCampos(oPanel , "UF9")}) // cria o panel com os campos alterados da mensagem

// utiliza o bChange no grid 
oView:SetViewProperty('VIEW_AU69', "CHANGELINE", {{|| MostraCampos(oPnlCpoUF4 , "UF4")}})   
oView:SetViewProperty('VIEW_AU70', "CHANGELINE", {{|| MostraCampos(oPnlCpoUJ9 , "UJ9")}})
oView:SetViewProperty('VIEW_AU71', "CHANGELINE", {{|| MostraCampos(oPnlCpoUF3 , "UF3")}})
oView:SetViewProperty('VIEW_AU72', "CHANGELINE", {{|| MostraCampos(oPnlCpoUF9 , "UF9")}})

// Criar um "box" horizontal para receber algum elemento da view   
oView:CreateHorizontalBox( 'CABECALHO'		, 40 )
oView:CreateHorizontalBox( 'ITENS'			, 60 )     

oView:CreateFolder( 'PASTAS' , 'ITENS' )

oView:AddSheet( 'PASTAS', 'ABA01', 'Dados Cadastrais' )   
oView:AddSheet( 'PASTAS', 'ABA02', 'Beneficiários' ) 
oView:AddSheet( 'PASTAS', 'ABA03', 'Valores Adicionais' ) 
oView:AddSheet( 'PASTAS', 'ABA04', 'Produtos e Serviços' ) 
oView:AddSheet( 'PASTAS', 'ABA05', 'Mensagens' ) 

oView:CreateHorizontalBox( 'CAMPOS1'	, 100	,,, 'PASTAS' , 'ABA01' )

oView:CreateVerticalBox( 'ESQUERDA'		, 49	,,, 'PASTAS' , 'ABA02'  )
oView:CreateVerticalBox( 'SEPARADOR'	, 02	,,, 'PASTAS' , 'ABA02'  )
oView:CreateVerticalBox( 'DIREITA'		, 49	,,, 'PASTAS' , 'ABA02'  )

oView:CreateVerticalBox( 'ESQUERDA'		, 49	,,, 'PASTAS' , 'ABA03'  )
oView:CreateVerticalBox( 'SEPARADOR'	, 02	,,, 'PASTAS' , 'ABA03'  )
oView:CreateVerticalBox( 'DIREITA'		, 49	,,, 'PASTAS' , 'ABA03'  )

oView:CreateVerticalBox( 'ESQUERDA'		, 49	,,, 'PASTAS' , 'ABA04'  )
oView:CreateVerticalBox( 'SEPARADOR'	, 02	,,, 'PASTAS' , 'ABA04'  )
oView:CreateVerticalBox( 'DIREITA'		, 49	,,, 'PASTAS' , 'ABA04'  )

oView:CreateVerticalBox( 'ESQUERDA'		, 49	,,, 'PASTAS' , 'ABA05'  )
oView:CreateVerticalBox( 'SEPARADOR'	, 02	,,, 'PASTAS' , 'ABA05'  )
oView:CreateVerticalBox( 'DIREITA'		, 49	,,, 'PASTAS' , 'ABA05'  )

oView:CreateHorizontalBox( 'INCLUSOES1'	, 50	, 'ESQUERDA' , , 'PASTAS' , 'ABA02' )
oView:CreateHorizontalBox( 'EXCLUSOES1'	, 50	, 'ESQUERDA' , , 'PASTAS' , 'ABA02' )  

oView:CreateHorizontalBox( 'ALTERACOES1', 49	, 'DIREITA' , , 'PASTAS' , 'ABA02' ) 
oView:CreateHorizontalBox( 'SEPARADOR1'	, 02	, 'DIREITA' , , 'PASTAS' , 'ABA02' ) 
oView:CreateHorizontalBox( 'CAMPOS2'	, 49	, 'DIREITA' , , 'PASTAS' , 'ABA02' ) 

oView:CreateHorizontalBox( 'INCLUSOES2'	, 50	, 'ESQUERDA' , , 'PASTAS' , 'ABA03' )
oView:CreateHorizontalBox( 'EXCLUSOES2'	, 50	, 'ESQUERDA' , , 'PASTAS' , 'ABA03' )  

oView:CreateHorizontalBox( 'ALTERACOES2', 49	, 'DIREITA' , , 'PASTAS' , 'ABA03' )  
oView:CreateHorizontalBox( 'SEPARADOR2'	, 02	, 'DIREITA' , , 'PASTAS' , 'ABA03' ) 
oView:CreateHorizontalBox( 'CAMPOS3'	, 49	, 'DIREITA' , , 'PASTAS' , 'ABA03' ) 

oView:CreateHorizontalBox( 'INCLUSOES3'	, 50	, 'ESQUERDA' , , 'PASTAS' , 'ABA04' )
oView:CreateHorizontalBox( 'EXCLUSOES3'	, 50	, 'ESQUERDA' , , 'PASTAS' , 'ABA04' )  

oView:CreateHorizontalBox( 'ALTERACOES3', 49	, 'DIREITA' , , 'PASTAS' , 'ABA04' )  
oView:CreateHorizontalBox( 'SEPARADOR3'	, 02	, 'DIREITA' , , 'PASTAS' , 'ABA04' ) 
oView:CreateHorizontalBox( 'CAMPOS4'	, 49	, 'DIREITA' , , 'PASTAS' , 'ABA04' )  

oView:CreateHorizontalBox( 'INCLUSOES4'	, 50	, 'ESQUERDA' , , 'PASTAS' , 'ABA05' )
oView:CreateHorizontalBox( 'EXCLUSOES4'	, 50	, 'ESQUERDA' , , 'PASTAS' , 'ABA05' )  

oView:CreateHorizontalBox( 'ALTERACOES4', 49	, 'DIREITA' , , 'PASTAS' , 'ABA05' )  
oView:CreateHorizontalBox( 'SEPARADOR4'	, 02	, 'DIREITA' , , 'PASTAS' , 'ABA05' ) 
oView:CreateHorizontalBox( 'CAMPOS5'	, 49	, 'DIREITA' , , 'PASTAS' , 'ABA05' ) 
 
// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CABEC'	, 'CABECALHO' )
oView:SetOwnerView( 'VIEW_IU69'		, 'INCLUSOES1' )    
oView:SetOwnerView( 'VIEW_EU69' 	, 'EXCLUSOES1' ) 
oView:SetOwnerView( 'VIEW_AU69' 	, 'ALTERACOES1' )  
oView:SetOwnerView( 'VIEW_IU70'		, 'INCLUSOES2' )    
oView:SetOwnerView( 'VIEW_EU70' 	, 'EXCLUSOES2' ) 
oView:SetOwnerView( 'VIEW_AU70' 	, 'ALTERACOES2' )  
oView:SetOwnerView( 'VIEW_IU71'		, 'INCLUSOES3' )    
oView:SetOwnerView( 'VIEW_EU71' 	, 'EXCLUSOES3' ) 
oView:SetOwnerView( 'VIEW_AU71' 	, 'ALTERACOES3' ) 
oView:SetOwnerView( 'VIEW_IU72'		, 'INCLUSOES4' )    
oView:SetOwnerView( 'VIEW_EU72' 	, 'EXCLUSOES4' ) 
oView:SetOwnerView( 'VIEW_AU72' 	, 'ALTERACOES4' ) 
oView:SetOwnerView( 'VIEW_CAMPOSUF2', 'CAMPOS1')
oView:SetOwnerView( 'VIEW_CAMPOSUF4', 'CAMPOS2')
oView:SetOwnerView( 'VIEW_CAMPOSUJ9', 'CAMPOS3') 
oView:SetOwnerView( 'VIEW_CAMPOSUF3', 'CAMPOS4')
oView:SetOwnerView( 'VIEW_CAMPOSUF9', 'CAMPOS5') 

// Liga a identificacao do componente
//oView:EnableTitleView('VIEW_CABEC')
oView:EnableTitleView('VIEW_IU69') 
oView:EnableTitleView('VIEW_EU69')
oView:EnableTitleView('VIEW_AU69')   
oView:EnableTitleView('VIEW_IU70') 
oView:EnableTitleView('VIEW_EU70')
oView:EnableTitleView('VIEW_AU70')  
oView:EnableTitleView('VIEW_IU71') 
oView:EnableTitleView('VIEW_EU71')
oView:EnableTitleView('VIEW_AU71') 
oView:EnableTitleView('VIEW_IU72') 
oView:EnableTitleView('VIEW_EU72')
oView:EnableTitleView('VIEW_AU72') 
oView:EnableTitleView("VIEW_CAMPOSUF2","Campos Alterados")   
oView:EnableTitleView("VIEW_CAMPOSUF4","Campos Alterados") 
oView:EnableTitleView("VIEW_CAMPOSUJ9","Campos Alterados")    
oView:EnableTitleView("VIEW_CAMPOSUF3","Campos Alterados")   
oView:EnableTitleView("VIEW_CAMPOSUF9","Campos Alterados") 

// Define fechamento da tela
oView:SetCloseOnOk( {||.T.} )

// Habilito a barra de progresso na abertura da tela
oView:SetProgressBar(.T.)

Return oView         

/*###########################################################################
#############################################################################
## Programa  | MostraCampos |Autor| Wellington Gonçalves |Data| 25/05/2019 ##
##=========================================================================##
## Desc.     | Função que monta o panel para apresentar campos alterados   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/              

Static Function MostraCampos(oPanel,cAlias)  
  
Local oGroup1
Local oGroup2
Local oSay2
Local oSay3
Local nLinhaIni 	:= 10     
Local oFonteSay		:= TFont():New("Verdana",,016,,.F.,,,,,.F.,.F.) 
Local nHeigth		:= oPanel:nClientHeight / 2
Local nWhidth		:= oPanel:nClientWidth / 2   
Local oModel 		:= FWModelActive()        
Local oMaster		:= oModel:GetModel('U68MASTER')  
Local oModelU69A	:= oModel:GetModel('AU69DETAIL')
Local oModelU70A	:= oModel:GetModel('AU70DETAIL')
Local oModelU71A	:= oModel:GetModel('AU71DETAIL')
Local oModelU72A	:= oModel:GetModel('AU72DETAIL')
Local nOperation 	:= oModel:GetOperation() 
Local aArea			:= GetArea()
Local aAreaU73		:= U73->(GetArea())     
Local nX				:= 1   
Local aCampos		:= {}  
Local aOpcoes       := {}
Local cVarSay		:= ""  
Local cTitCpo		:= "" 
Local cOpcoes       := ""
Local oSX3			:= UGetSxFile():New
Local aSx3			:= {}

if cAlias == "UF2" // cabeçalho

	if ValType(oScrlUF2) <> "U" 
		oScrlUF2 := NIL
	endif 

elseif cAlias == "UF4" // beneficiarios

	if ValType(oScrlUF4) <> "U" 
		oScrlUF4 := NIL
	endif 

elseif cAlias == "UJ9" // valores adicionais

	if ValType(oScrlUJ9) <> "U" 
		oScrlUJ9 := NIL
	endif 
	
elseif cAlias == "UF3" // produtos e serviços

	if ValType(oScrlUF3) <> "U" 
		oScrlUF3 := NIL
	endif

elseif cAlias == "UF9" // mensagens

	if ValType(oScrlUF9) <> "U"
		oScrlUF9 := NIL
	endif

endif

@ 013, 005 SCROLLBOX oScrlUF4 HORIZONTAL VERTICAL SIZE nHeigth - 13 , nWhidth - nLinhaIni OF oPanel BORDER  

if cAlias == "UF2"
	oPnlCpoUF2 := oPanel 
elseif cAlias == "UF4"  
	oPnlCpoUF4 := oPanel 
elseif cAlias == "UJ9" 
	oPnlCpoUJ9 := oPanel 
elseif cAlias == "UF3" 
	oPnlCpoUF3 := oPanel 
elseif cAlias == "UF9" 
	oPnlCpoUF9 := oPanel 
endif

if nOperation <> 3 // apenas se for alteração ou visualização

	cCodigo := oMaster:GetValue("U68_CODIGO")  
	
	if cAlias == "UF2"
		cChave := oMaster:GetValue("U68_CONTRA")
	elseif cAlias == "UF4"
		cChave := oMaster:GetValue("U68_CONTRA") + oModelU69A:GetValue('U69_ITEM')
 	elseif cAlias == "UJ9"
 		cChave := oMaster:GetValue("U68_CONTRA") + oModelU70A:GetValue('U70_ITBEN') + oModelU70A:GetValue('U70_ITEM')
 	elseif cAlias == "UF3"
 		cChave := oMaster:GetValue("U68_CONTRA") + oModelU71A:GetValue('U71_ITEM')
 	elseif cAlias == "UF9"
 		cChave := oMaster:GetValue("U68_CONTRA") + oModelU72A:GetValue('U72_ITEM')
 	endif
 	
	U73->(DbSetOrder(1)) // U73_FILIAL + U73_CODIGO + U73_ALIAS + U73_CHAVE + U73_CAMPO  
	if U73->(DbSeek(xFilial("U73") + cCodigo + cAlias + cChave ))	
	
		While U73->(!Eof()) .AND. U73->U73_FILIAL == xFilial("U73") .AND. U73->U73_CODIGO == cCodigo .AND. U73->U73_ALIAS == cAlias .AND. AllTrim(U73->U73_CHAVE) == AllTrim(U73)  
		  
			// crio uma posição no array de campos
			aadd(aCampos,{{,} , {,}})
		  
			if U73->U73_TIPCPO == "N" 	  
				aCampos[Len(aCampos)][1][1] := U73->U73_NVLANT 	  
				aCampos[Len(aCampos)][2][1] := U73->U73_NVLPOS 
			elseif U73->U73_TIPCPO == "C"        
				aCampos[Len(aCampos)][1][1] := U73->U73_CVLANT 
				aCampos[Len(aCampos)][2][1] := U73->U73_CVLPOS		
			elseif U73->U73_TIPCPO == "D"   
				aCampos[Len(aCampos)][1][1] := DTOC(U73->U73_DVLANT)
				aCampos[Len(aCampos)][2][1] := DTOC(U73->U73_DVLPOS)		
			elseif U73->U73_TIPCPO == "L"    
				aCampos[Len(aCampos)][1][1] := iif(U73->U73_LVLANT,"SIM","NAO")
				aCampos[Len(aCampos)][2][1] := iif(U73->U73_LVLPOS,"SIM","NAO")			
			elseif U73->U73_TIPCPO == "M"    
				aCampos[Len(aCampos)][1][1] := U73->U73_MVLANT
				aCampos[Len(aCampos)][2][1] := U73->U73_MVLPOS 			
			endif 
			
			cVarSay := "cVarSay" + cValTochar(nX) 
			
			aSX3 := oSX3:GetInfoSX3(,U73->U73_CAMPO)

			if Len(aSX3) > 0
				cTitCpo := aSX3[1,2]:cDESCRIC 
				cOpcoes := aSX3[1,2]:cCBOX 
				aOpcoes := StrTokArr( cOpcoes ,";") 
			endif
				
			@ nLinhaIni	, 005 SAY &cVarSay PROMPT "" SIZE 100, 010 OF oScrlUF4 FONT oFonteSay COLORS 0, 16777215 PIXEL   
			&cVarSay:cCaption := cTitCpo + ":"
			
			@ nLinhaIni + 10, 005 GROUP oGroup1 TO nLinhaIni + 11, 400 OF oScrlUF4 COLOR 0, 16777215 PIXEL  
			
			@ nLinhaIni + 15, 005 SAY oSay2 PROMPT "Antes:" SIZE 050, 010 OF oScrlUF4 FONT oFonteSay COLORS 0, 16777215 PIXEL
			@ nLinhaIni + 15, 210 SAY oSay3 PROMPT "Depois:" SIZE 050, 010 OF oScrlUF4 FONT oFonteSay COLORS 0, 16777215 PIXEL 
			
			if U73->U73_TIPCPO == "M" // campo memo  
			
				@ nLinhaIni + 25, 005 Get aCampos[Len(aCampos)][1][2] Var aCampos[Len(aCampos)][1][1] Multiline hScroll Size 192,060 Memo OF oScrlUF4 PIXEL    
				@ nLinhaIni + 25, 210 Get aCampos[Len(aCampos)][2][2] Var aCampos[Len(aCampos)][2][1] Multiline hScroll Size 192,060 Memo OF oScrlUF4 PIXEL     
				
				aCampos[Len(aCampos)][1][2]:bSetGet  := &("{ | U | IF( PCOUNT() == 0, aCampos[" + cValToChar(Len(aCampos)) + "][1][1] , aCampos[" + cValToChar(Len(aCampos)) + "][1][1] := U ) }")   
				aCampos[Len(aCampos)][2][2]:bSetGet  := &("{ | U | IF( PCOUNT() == 0, aCampos[" + cValToChar(Len(aCampos)) + "][2][1] , aCampos[" + cValToChar(Len(aCampos)) + "][2][1] := U ) }") 
				
				nLinhaIni += 100 
			
			ElseIf U73->U73_TIPCPO == "C" .And. !Empty( cOpcoes ) // campo Combo  
				
				@ nLinhaIni + 25, 005 MSCOMBOBOX aCampos[Len(aCampos)][1][2] VAR aCampos[Len(aCampos)][1][1] ITEMS aOpcoes SIZE 192, 010 OF oScrlUF4 COLORS 0, 16777215 PIXEL
				
				@ nLinhaIni + 25, 210 MSCOMBOBOX aCampos[Len(aCampos)][2][2] VAR aCampos[Len(aCampos)][2][1] ITEMS aOpcoes SIZE 192, 010 OF oScrlUF4 COLORS 0, 16777215 PIXEL
				
				aCampos[Len(aCampos)][1][2]:bSetGet  := &("{ | U | IF( PCOUNT() == 0, aCampos[" + cValToChar(Len(aCampos)) + "][1][1] , aCampos[" + cValToChar(Len(aCampos)) + "][1][1] := U ) }")   
				aCampos[Len(aCampos)][2][2]:bSetGet  := &("{ | U | IF( PCOUNT() == 0, aCampos[" + cValToChar(Len(aCampos)) + "][2][1] , aCampos[" + cValToChar(Len(aCampos)) + "][2][1] := U ) }") 
				
				nLinhaIni += 50
		
			else   
			
				@ nLinhaIni + 25, 005 MSGET aCampos[Len(aCampos)][1][2] VAR aCampos[Len(aCampos)][1][1] SIZE 192, 010 OF oScrlUF4 COLORS 0, 16777215 PIXEL   
				@ nLinhaIni + 25, 210 MSGET aCampos[Len(aCampos)][2][2] VAR aCampos[Len(aCampos)][2][1] SIZE 192, 010 OF oScrlUF4 COLORS 0, 16777215 PIXEL 
				
				aCampos[Len(aCampos)][1][2]:bSetGet  := &("{ | U | IF( PCOUNT() == 0, aCampos[" + cValToChar(Len(aCampos)) + "][1][1] , aCampos[" + cValToChar(Len(aCampos)) + "][1][1] := U ) }")   
				aCampos[Len(aCampos)][2][2]:bSetGet  := &("{ | U | IF( PCOUNT() == 0, aCampos[" + cValToChar(Len(aCampos)) + "][2][1] , aCampos[" + cValToChar(Len(aCampos)) + "][2][1] := U ) }")   
				
				nLinhaIni += 50
				
			endif	
			
			U73->(DbSkip()) 
			
			nX++
		
		EndDo 
		
		@ nLinhaIni, 005 GROUP oGroup2 TO nLinhaIni + 1, 400 OF oScrlUF4 COLOR 0, 16777215 PIXEL   
	
	endif 

endif     

RestArea(aArea)
RestArea(aAreaU73) 

Return()      