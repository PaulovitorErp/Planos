#include "protheus.ch" 
#include "fwmvcdef.ch"

/*/{Protheus.doc} RFUNA033
Log Contratos
@author TOTVS
@since 08/08/2018
@version P12
@param Nao recebe parametros            
@return nulo
/*/

/***********************/
User Function RFUNA033()
/***********************/

Local oBrowse

Private aRotina := {}

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("UGA")
oBrowse:SetDescription("Log Contratos")   
oBrowse:Activate()

Return Nil

/************************/
Static Function MenuDef()
/************************/

Local aRotina 	:= {}

ADD OPTION aRotina Title "Visualizar" 	Action "VIEWDEF.RFUNA033"	OPERATION 2 ACCESS 0

Return aRotina

/*************************/
Static Function ModelDef()
/*************************/

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruUGA := FWFormStruct(1,"UGA",/*bAvalCampo*/,/*lViewUsado*/ )

Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("PFUNA033",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("UGAMASTER",/*cOwner*/,oStruUGA)

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({"UGA_FILIAL","UGA_CODIGO"})

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel("UGAMASTER"):SetDescription("Log")

Return oModel

/************************/
Static Function ViewDef()
/************************/

// Cria a estrutura a ser usada na View
Local oStruUGA := FWFormStruct(2,"UGA")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel("RFUNA033")
Local oView

// Remove campos da estrutura
oStruUGA:RemoveField('UGA_CODIGO')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_UGA",oStruUGA,"UGAMASTER")

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("PAINEL", 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView("VIEW_UGA","PAINEL")

// Liga a identificacao do componente
oView:EnableTitleView("VIEW_UGA","Log")

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk( {||.T.} )

Return oView 