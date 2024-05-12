#include "protheus.ch" 
#include "fwmvcdef.ch"

/*/{Protheus.doc} RUTIL009
Profissionais
@author TOTVS
@since 20/03/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

/***********************/
User Function RUTIL009()
/***********************/

Local oBrowse

Private aRotina := {}

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("UJB")
oBrowse:SetDescription("Profissionais")   
oBrowse:AddLegend("UJB_STATUS == 'A'", "GREEN",	"Ativo")
oBrowse:AddLegend("UJB_STATUS == 'I'", "RED",	"Inativo") 
oBrowse:Activate()

Return Nil

/************************/
Static Function MenuDef()
/************************/

Local aRotina 	:= {}

ADD OPTION aRotina Title 'Visualizar' 	Action "VIEWDEF.RUTIL009"	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title "Incluir"    	Action "VIEWDEF.RUTIL009"	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title "Alterar"    	Action "VIEWDEF.RUTIL009"	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title "Excluir"    	Action "VIEWDEF.RUTIL009"	OPERATION 5 ACCESS 0
ADD OPTION aRotina Title 'Legenda'     	Action 'U_UTIL009L()' 		OPERATION 6 ACCESS 0    

Return aRotina

/*************************/
Static Function ModelDef()
/*************************/

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruUJB := FWFormStruct(1,"UJB",/*bAvalCampo*/,/*lViewUsado*/ )

Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("PUTIL009",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("UJBMASTER",/*cOwner*/,oStruUJB)

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({"UJB_FILIAL","UJB_CODIGO"})

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel("UJBMASTER"):SetDescription("Profissionais")

Return oModel

/************************/
Static Function ViewDef()
/************************/

// Cria a estrutura a ser usada na View
Local oStruUJB := FWFormStruct(2,"UJB")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel("RUTIL009")
Local oView

// Remove campos da estrutura
//oStruUJB:RemoveField('UJB_CODIGO')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_UJB",oStruUJB,"UJBMASTER")

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("PAINEL_CABEC", 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView("VIEW_UJB","PAINEL_CABEC")

// Liga a identificacao do componente
oView:EnableTitleView("VIEW_UJB","Profissionais")

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk( {||.T.} )

Return oView 

/***********************/
User Function UTIL009L()
/***********************/

BrwLegenda("Status","Legenda",{{"BR_VERDE","Ativo"},{"BR_VERMELHO","Inativo"}})

Return