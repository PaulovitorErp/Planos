#include "protheus.ch" 
#include "fwmvcdef.ch"

/*/{Protheus.doc} RUTIL001
Cadastro de Bairro.
@author André R. Barrero
@since 09/08/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RUTIL001
/***********************/

Local oBrowse

Private aRotina := {}

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("ZFC")
oBrowse:SetDescription("Cadastro de Bairro")   
oBrowse:Activate()

Return Nil

/************************/
Static Function MenuDef()
/************************/

aRotina 	:= {}

ADD OPTION aRotina Title 'Visualizar' 	Action "VIEWDEF.RUTIL001"	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title "Incluir"    	Action "VIEWDEF.RUTIL001"	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title "Alterar"    	Action "VIEWDEF.RUTIL001"	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title "Excluir"    	Action "VIEWDEF.RUTIL001"	OPERATION 5 ACCESS 0

Return aRotina

/*************************/
Static Function ModelDef()
/*************************/

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZFC := FWFormStruct(1,"ZFC",/*bAvalCampo*/,/*lViewUsado*/ )

Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("PUTIL001",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("ZFCMASTER",/*cOwner*/,oStruZFC)

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({"ZFC_FILIAL","ZFC_EST","ZFC_CODMUN","ZFC_CODBAI"})

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel("ZFCMASTER"):SetDescription("Cadastro de Bairros")

Return oModel

/************************/
Static Function ViewDef()
/************************/

// Cria a estrutura a ser usada na View
Local oStruZFC := FWFormStruct(2,"ZFC")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel("RUTIL001")
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_ZFC",oStruZFC,"ZFCMASTER")

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("PAINEL_CABEC", 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView("VIEW_ZFC","PAINEL_CABEC")

// Liga a identificacao do componente
oView:EnableTitleView("VIEW_ZFC")

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk( {||.T.} )

Return oView