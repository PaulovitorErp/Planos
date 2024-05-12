#include "protheus.ch" 
#include "fwmvcdef.ch"

/*/{Protheus.doc} RUTIL006
Empresas Integração
@author TOTVS
@since 27/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RUTIL006()
/***********************/ 

Local oBrowse

Private aRotina := {}

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("UJ3")
oBrowse:SetDescription("Empresas Integração")   
oBrowse:Activate()

Return Nil

/************************/
Static Function MenuDef()
/************************/

aRotina 	:= {}

ADD OPTION aRotina Title 'Visualizar' 	Action "VIEWDEF.RUTIL006"	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title "Incluir"    	Action "VIEWDEF.RUTIL006"	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title "Alterar"    	Action "VIEWDEF.RUTIL006"	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title "Excluir"    	Action "VIEWDEF.RUTIL006"	OPERATION 5 ACCESS 0

Return aRotina

/*************************/
Static Function ModelDef()
/*************************/

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruUJ3 := FWFormStruct(1,"UJ3",/*bAvalCampo*/,/*lViewUsado*/ )

Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("PUTIL006",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("UJ3MASTER",/*cOwner*/,oStruUJ3)

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({"UJ3_FILIAL","UJ3_CODIGO"})

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel("UJ3MASTER"):SetDescription("Empresas Integração")

Return oModel

/************************/
Static Function ViewDef()
/************************/

// Cria a estrutura a ser usada na View
Local oStruUJ3 := FWFormStruct(2,"UJ3")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel("RUTIL006")
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_UJ3",oStruUJ3,"UJ3MASTER")

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("PAINEL_CABEC", 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView("VIEW_UJ3","PAINEL_CABEC")

// Liga a identificacao do componente
oView:EnableTitleView("VIEW_UJ3","Empresas Integração")

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk( {||.T.} )

Return oView