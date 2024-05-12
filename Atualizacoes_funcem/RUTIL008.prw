#include "protheus.ch" 
#include "fwmvcdef.ch"

/*/{Protheus.doc} RUTIL008
Categoria de Profissionais
@author TOTVS
@since 20/03/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

/***********************/
User Function RUTIL008()
/***********************/

Local oBrowse

Private aRotina := {}

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("UJA")
oBrowse:SetDescription("Categoria de Profissionais")   
oBrowse:Activate()

Return Nil

/************************/
Static Function MenuDef()
/************************/

Local aRotina 	:= {}

ADD OPTION aRotina Title 'Visualizar' 	Action "VIEWDEF.RUTIL008"	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title "Incluir"    	Action "VIEWDEF.RUTIL008"	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title "Alterar"    	Action "VIEWDEF.RUTIL008"	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title "Excluir"    	Action "VIEWDEF.RUTIL008"	OPERATION 5 ACCESS 0

Return aRotina

/*************************/
Static Function ModelDef()
/*************************/

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruUJA := FWFormStruct(1,"UJA",/*bAvalCampo*/,/*lViewUsado*/ )

Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("PUTIL008",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("UJAMASTER",/*cOwner*/,oStruUJA)

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({"UJA_FILIAL","UJA_CODIGO"})

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel("UJAMASTER"):SetDescription("Categoria de Profissionais")

Return oModel

/************************/
Static Function ViewDef()
/************************/

// Cria a estrutura a ser usada na View
Local oStruUJA := FWFormStruct(2,"UJA")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel("RUTIL008")
Local oView

// Remove campos da estrutura
//oStruUJA:RemoveField('UJA_CODIGO')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_UJA",oStruUJA,"UJAMASTER")

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("PAINEL_CABEC", 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView("VIEW_UJA","PAINEL_CABEC")

// Liga a identificacao do componente
oView:EnableTitleView("VIEW_UJA","Categoria de Profissionais")

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk( {||.T.} )

Return oView