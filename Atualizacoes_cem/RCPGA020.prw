#include "protheus.ch" 
#include "fwmvcdef.ch"

/*/{Protheus.doc} RCPGA020
Salas de Locação de Velório
@author TOTVS
@since 04/05/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RCPGA020()
/***********************/ 

Local oBrowse

Private aRotina := {}

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("U24")
oBrowse:SetDescription("Salas de Locação de Velório")   
oBrowse:Activate()

Return Nil

/************************/
Static Function MenuDef()
/************************/

aRotina 	:= {}

ADD OPTION aRotina Title 'Visualizar' 	Action "VIEWDEF.RCPGA020"	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title "Incluir"    	Action "VIEWDEF.RCPGA020"	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title "Alterar"    	Action "VIEWDEF.RCPGA020"	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title "Excluir"    	Action "VIEWDEF.RCPGA020"	OPERATION 5 ACCESS 0

Return aRotina

/*************************/
Static Function ModelDef()
/*************************/

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruU24 := FWFormStruct(1,"U24",/*bAvalCampo*/,/*lViewUsado*/ )

Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("PCPGA020",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("U24MASTER",/*cOwner*/,oStruU24)

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({"U24_FILIAL","U24_CODIGO"})

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel("U24MASTER"):SetDescription("Salas de Locação de Velório")

Return oModel

/************************/
Static Function ViewDef()
/************************/

// Cria a estrutura a ser usada na View
Local oStruU24 := FWFormStruct(2,"U24")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel("RCPGA020")
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_U24",oStruU24,"U24MASTER")

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("PAINEL_CABEC", 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView("VIEW_U24","PAINEL_CABEC")

// Liga a identificacao do componente
oView:EnableTitleView("VIEW_U24","Salas de Locação de Velório")

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk( {||.T.} )

Return oView