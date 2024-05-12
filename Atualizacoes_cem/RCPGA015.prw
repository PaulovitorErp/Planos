#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RCPGA015 � Autor � Wellington Gon�alves � Data� 06/04/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de �ndice de reajuste							  ���
�������������������������������������������������������������������������͹��
���Uso       � Vale do Cerrado                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RCPGA015()      

Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'U22' )
oBrowse:SetDescription( 'Cadastro de �ndices' ) 

// adiciono as legendas
oBrowse:AddLegend("U22_STATUS == 'A'", "GREEN"	, "Ativo")
oBrowse:AddLegend("U22_STATUS == 'I'", "RED"	, "Inativo")

oBrowse:Activate()

Return NIL 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MenuDef � Autor � Wellington Gon�alves � Data � 06/04/2016 ���
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
ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.RCPGA015' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.RCPGA015' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.RCPGA015' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.RCPGA015' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.RCPGA015' 	OPERATION 08 ACCESS 0
ADD OPTION aRotina Title 'Legenda'     	Action 'U_CPGA015LEG()' 	OPERATION 10 ACCESS 0

Return(aRotina)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ModelDef � Autor � Wellington Gon�alves � Data �06/04/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que cria o objeto model							  ���
�������������������������������������������������������������������������͹��
���Uso       � Vale do Cerrado                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ModelDef()

Local oStruU22 := FWFormStruct( 1, 'U22', /*bAvalCampo*/, /*lViewUsado*/ ) 
Local oStruU28 := FWFormStruct( 1, 'U28', /*bAvalCampo*/, /*lViewUsado*/ ) 
Local oStruU29 := FWFormStruct( 1, 'U29', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PCPGA015', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABE�ALHO - INDICE  ////////////////////////////

// Crio a Enchoice com os campos do reajuste
oModel:AddFields( 'U22MASTER', /*cOwner*/, oStruU22 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "U22_FILIAL" , "U22_REF" })    

// Preencho a descri��o da entidade
oModel:GetModel('U22MASTER'):SetDescription('Dados do �ndice:')

///////////////////////////  ITENS - ANOS  //////////////////////////////

// Crio o grid de modulos
oModel:AddGrid( 'U28DETAIL', 'U22MASTER', oStruU28, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Fa�o o relaciomaneto entre o modulo e a quadra
oModel:SetRelation( 'U28DETAIL', { { 'U28_FILIAL', 'xFilial( "U28" )' } , { 'U28_CODIGO', 'U22_CODIGO' } } , U28->(IndexKey(1)) )  

// Seto a propriedade de obrigatoriedade do preenchimento do grid
oModel:GetModel('U28DETAIL'):SetOptional( .F. ) 

// Preencho a descri��o da entidade
oModel:GetModel('U28DETAIL'):SetDescription('Anos') 

// N�o permitir duplicar o ano
oModel:GetModel('U28DETAIL'):SetUniqueLine( {'U28_ANO'} ) 

///////////////////////////  ITENS - MESES  //////////////////////////////

// Crio o grid de jazigos
oModel:AddGrid('U29DETAIL', 'U28DETAIL', oStruU29, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)    

// Fa�o o relaciomaneto entre o jazigo e o modulo
oModel:SetRelation('U29DETAIL', { { 'U29_FILIAL', 'xFilial( "U29" )' } , { 'U29_CODIGO', 'U22_CODIGO' } , { 'U29_IDANO', 'U28_ITEM' } } , U29->(IndexKey(1)))  

// Seto a propriedade de obrigatoriedade do preenchimento do grid
oModel:GetModel('U29DETAIL'):SetOptional(.F.)

// Preencho a descri��o da entidade
oModel:GetModel('U29DETAIL'):SetDescription('Meses:') 

// N�o permitir duplicar o mes
oModel:GetModel('U29DETAIL'):SetUniqueLine( {'U29_MES'} ) 

Return(oModel)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ViewDef � Autor � Wellington Gon�alves � Data � 06/04/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que cria o objeto View							  ���
�������������������������������������������������������������������������͹��
���Uso       � Vale do Cerrado                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ViewDef()

Local oStruU22 	:= FWFormStruct(2,'U22')
Local oStruU28 	:= FWFormStruct(2,'U28') 
Local oStruU29 	:= FWFormStruct(2,'U29')
Local oModel   	:= FWLoadModel('RCPGA015')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_U22'	, oStruU22	, 'U22MASTER') // cria o cabe�alho
oView:AddGrid('VIEW_U28'	, oStruU28	, 'U28DETAIL') // Cria o grid - anos
oView:AddGrid('VIEW_U29'	, oStruU29	, 'U29DETAIL') // Cria o grid - meses  

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABECALHO' , 20)    
oView:CreateHorizontalBox('PANEL_ITENS'		, 80) 

oView:CreateVerticalBox('PANEL_ANOS'		, 19	, "PANEL_ITENS")
oView:CreateVerticalBox('SEPARADOR_V'		, 02	, "PANEL_ITENS") 
oView:CreateVerticalBox('PANEL_MESES'		, 79	, "PANEL_ITENS") 

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_U22' , 'PANEL_CABECALHO')
oView:SetOwnerView('VIEW_U28' , 'PANEL_ANOS')
oView:SetOwnerView('VIEW_U29' , 'PANEL_MESES')

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_U22') 
oView:EnableTitleView('VIEW_U28') 
oView:EnableTitleView('VIEW_U29') 

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_U28', 'U28_ITEM' )
oView:AddIncrementField( 'VIEW_U29', 'U29_ITEM' )

// Define fechamento da tela ao confirmar a opera��o
oView:SetCloseOnOk({||.T.})

Return(oView)        

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CPGA015LEG� Autor � Wellington Gon�alves � Data� 06/04/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Legenda do browser de �ndices de reajuste				  ���
�������������������������������������������������������������������������͹��
���Uso       � Vale do Cerrado                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CPGA015LEG()

BrwLegenda("Status","Legenda",{ {"BR_VERDE","Ativo"},{"BR_VERMELHO","Inativo"} })

Return()      

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ValidRef � Autor � Wellington Gon�alves � Data� 06/04/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que valida a refer�ncia do �ndice					  ���
�������������������������������������������������������������������������͹��
���Uso       � Vale do Cerrado                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function ValidRef(cReferencia)

Local lRet := .F.

if Len(AllTrim(SubStr(cReferencia,1,2))) < 2
	Help(,,'Help',,"Informe os 2 d�gitos do m�s!",1,0)
elseif Len(AllTrim(SubStr(cReferencia,3,4))) < 4
	Help(,,'Help',,"Informe os 4 d�gitos do ano!",1,0)
else

	if SubStr(cReferencia,1,2) < "01" .OR. SubStr(cReferencia,1,2) > "12" 
		Help(,,'Help',,"O m�s informado � inv�lido!",1,0)
	elseif SubStr(cReferencia,3,4) < "0000" .OR. SubStr(cReferencia,3,4) > "9999"
		Help(,,'Help',,"O ano informado � inv�lido!",1,0)
	else
		lRet := .T.
	endif 

endif

Return(lRet)           