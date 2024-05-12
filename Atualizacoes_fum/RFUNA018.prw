#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFUNA018 � Autor � Wellington Gon�alves � Data� 25/08/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de religi�es									  ���
�������������������������������������������������������������������������͹��
���Uso       � Funer�ria		                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFUNA018()      

Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'UG3' )
oBrowse:SetDescription( 'Cadastro de Religi�es' )

oBrowse:Activate()

Return NIL 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MenuDef � Autor � Wellington Gon�alves � Data � 25/08/2016 ���
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
ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.RFUNA018' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.RFUNA018' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.RFUNA018' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.RFUNA018' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.RFUNA018' 	OPERATION 08 ACCESS 0
ADD OPTION aRotina Title 'Copiar'      	Action 'VIEWDEF.RFUNA018' 	OPERATION 09 ACCESS 0      

Return(aRotina)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ModelDef � Autor � Wellington Gon�alves � Data �25/08/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que cria o objeto model							  ���
�������������������������������������������������������������������������͹��
���Uso       � Funer�ria		                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ModelDef()

Local oStruUG3 := FWFormStruct( 1, 'UG3', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PFUNA018', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Crio a Enchoice com os campos do cadastro
oModel:AddFields( 'UG3MASTER', /*cOwner*/, oStruUG3 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "UG3_FILIAL" , "UG3_CODIGO" })    

// Preencho a descri��o da entidade
oModel:GetModel('UG3MASTER'):SetDescription('Dados da religi�o')

Return(oModel)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ViewDef � Autor � Wellington Gon�alves � Data � 25/08/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que cria o objeto View							  ���
�������������������������������������������������������������������������͹��
���Uso       � Funer�ria		                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ViewDef()

Local oStruUG3 	:= FWFormStruct(2,'UG3')
Local oModel   	:= FWLoadModel('RFUNA018')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_UG3' , oStruUG3, 'UG3MASTER') // cria o cabe�alho

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL' , 100)    

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_UG3' , 'PANEL')    

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_UG3') 

// Define fechamento da tela ao confirmar a opera��o
oView:SetCloseOnOk({||.T.})

Return(oView)                         