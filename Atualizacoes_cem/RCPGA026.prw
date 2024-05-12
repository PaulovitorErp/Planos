#include "protheus.ch" 
#include "fwmvcdef.ch"

/*/{Protheus.doc} RCPGA026
Motivos de Cancelamento
@author TOTVS
@since 08/06/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RCPGA026
/***********************/

Local oBrowse

Private aRotina := {}

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("U31")
oBrowse:SetDescription("Motivos de Cancelamento")   
oBrowse:Activate()

Return Nil

/************************/
Static Function MenuDef()
/************************/

aRotina 	:= {}

ADD OPTION aRotina Title 'Visualizar' 	Action "VIEWDEF.RCPGA026"	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title "Incluir"    	Action "VIEWDEF.RCPGA026"	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title "Alterar"    	Action "VIEWDEF.RCPGA026"	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title "Excluir"    	Action "VIEWDEF.RCPGA026"	OPERATION 5 ACCESS 0

Return aRotina

/*************************/
Static Function ModelDef()
/*************************/

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruU31 := FWFormStruct(1,"U31",/*bAvalCampo*/,/*lViewUsado*/ )

Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("PCPGA026",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("U31MASTER",/*cOwner*/,oStruU31)

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({"U31_FILIAL","U31_CODIGO"})

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel("U31MASTER"):SetDescription("Motivos de Cancelamento")

Return oModel

/************************/
Static Function ViewDef()
/************************/

// Cria a estrutura a ser usada na View
Local oStruU31 := FWFormStruct(2,"U31")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel("RCPGA026")
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_U31",oStruU31,"U31MASTER")

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("PAINEL_CABEC", 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView("VIEW_U31","PAINEL_CABEC")

// Liga a identificacao do componente
oView:EnableTitleView("VIEW_U31","Motivos de Cancelamento")

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk( {||.T.} )

Return oView