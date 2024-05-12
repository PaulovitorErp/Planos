#include "protheus.ch" 
#include "fwmvcdef.ch"

/*/{Protheus.doc} RUTILE09
Log Integracao Cadastros
@author TOTVS
@since 03/09/2018
@version P12
@param Nao recebe parametros            
@return nulo
/*/

/***********************/
User Function RUTILE09()
/***********************/
Local oBrowse
Private aRotina := {}

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("U56")
oBrowse:SetDescription("Log Integração Cadastros")  
oBrowse:AddLegend("'200' $ U56_RETORN", "GREEN", "Integrado")
oBrowse:AddLegend("!'200' $ U56_RETORN", "RED",	"Nao integrado")  
oBrowse:Activate()

Return Nil

/************************/
Static Function MenuDef()
/************************/

Local aRotina 	:= {}

ADD OPTION aRotina Title "Visualizar" 	Action "VIEWDEF.RUTILE09"	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Legenda'     	Action 'U_UTILE09L()' 		OPERATION 6 ACCESS 0  

Return aRotina

/*************************/
Static Function ModelDef()
/*************************/

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruU56 := FWFormStruct(1,"U56",/*bAvalCampo*/,/*lViewUsado*/ )

Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("PUTILE09",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("U56MASTER",/*cOwner*/,oStruU56)

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({"U56_FILIAL","U56_CODIGO"})

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel("U56MASTER"):SetDescription("Log Integração Cadastros")

Return oModel

/************************/
Static Function ViewDef()
/************************/

// Cria a estrutura a ser usada na View
Local oStruU56 := FWFormStruct(2,"U56")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel("RUTILE09")
Local oView

// Remove campos da estrutura
oStruU56:RemoveField('U56_CODIGO')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_U56",oStruU56,"U56MASTER")

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("PAINEL", 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView("VIEW_U56","PAINEL")

// Liga a identificacao do componente
oView:EnableTitleView("VIEW_U56","Log")

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk( {||.T.} )

Return oView 

/***********************/
User Function UTILE09L()
/***********************/

BrwLegenda("Status","Legenda",{{"BR_VERDE","Integrado"},{"BR_VERMELHO","Nao integrado"}})

Return 