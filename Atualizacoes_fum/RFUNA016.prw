#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFUNA016 � Autor � Wellington Gon�alves � Data� 24/08/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de motoristas									  ���
�������������������������������������������������������������������������͹��
���Uso       � Funer�ria		                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFUNA016()      

Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'UF6' )
oBrowse:SetDescription( 'Cadastro de Motoristas' )

// adiciono as legendas
oBrowse:AddLegend("UF6_STATUS == 'I'", "RED"	, "Inativo")
oBrowse:AddLegend("UF6_STATUS == 'A'", "GREEN"	, "Ativo")

oBrowse:Activate()

Return NIL 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MenuDef � Autor � Wellington Gon�alves � Data � 24/08/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que cria os menus									  ���
�������������������������������������������������������������������������͹��
���Uso       � Funer�ria		                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   	Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.RFUNA016' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.RFUNA016' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.RFUNA016' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.RFUNA016' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.RFUNA016' 	OPERATION 08 ACCESS 0
ADD OPTION aRotina Title 'Copiar'      	Action 'VIEWDEF.RFUNA016' 	OPERATION 09 ACCESS 0  
ADD OPTION aRotina Title 'Legenda'     	Action 'U_FUNA016LEG()' 	OPERATION 10 ACCESS 0    

Return(aRotina)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ModelDef � Autor � Wellington Gon�alves � Data �24/08/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que cria o objeto model							  ���
�������������������������������������������������������������������������͹��
���Uso       � Funer�ria		                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ModelDef()

Local oStruUF6 := FWFormStruct( 1, 'UF6', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PFUNA016', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Crio a Enchoice com os campos do cadastro
oModel:AddFields( 'UF6MASTER', /*cOwner*/, oStruUF6 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "UF6_FILIAL" , "UF6_CPF" })    

// Preencho a descri��o da entidade
oModel:GetModel('UF6MASTER'):SetDescription('Dados do motorista')

Return(oModel)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ViewDef � Autor � Wellington Gon�alves � Data � 24/08/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que cria o objeto View							  ���
�������������������������������������������������������������������������͹��
���Uso       � Funer�ria		                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ViewDef()

Local oStruUF6 	:= FWFormStruct(2,'UF6')
Local oModel   	:= FWLoadModel('RFUNA016')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_UF6'	, oStruUF6, 'UF6MASTER') // cria o cabe�alho

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL' , 100)    

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_UF6' , 'PANEL')    

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_UF6') 

// Define fechamento da tela ao confirmar a opera��o
oView:SetCloseOnOk({||.T.})

Return(oView)                         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CPGA003LEG� Autor � Wellington Gon�alves � Data� 24/08/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Legenda do browser										  ���
�������������������������������������������������������������������������͹��
���Uso       � Funer�ria		                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FUNA016LEG()

BrwLegenda("Status do Motorista","Legenda",{ {"BR_VERDE","Ativo"},{"BR_VERMELHO","Inativo"} })

Return()