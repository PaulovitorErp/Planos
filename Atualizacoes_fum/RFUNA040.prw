#include "protheus.ch" 
#include "fwmvcdef.ch"

/*/{Protheus.doc} RFUNA040
Cadastro de Locais de Velorio
@author Raphael Martins
@since 09/04/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

User Function RFUNA040()

Local oBrowse

Private aRotina := {}

oBrowse := FWmBrowse():New()

oBrowse:SetAlias("UJD")

oBrowse:SetDescription("Locais de Velorio")   

oBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
Função que cria os menus			
@author Raphael Martins
@since 09/04/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function MenuDef()

Local aRotina 	:= {}

ADD OPTION aRotina Title 'Visualizar' 	Action "VIEWDEF.RFUNA040"	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title "Incluir"    	Action "VIEWDEF.RFUNA040"	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title "Alterar"    	Action "VIEWDEF.RFUNA040"	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title "Excluir"    	Action "VIEWDEF.RFUNA040"	OPERATION 5 ACCESS 0

Return aRotina


/*/{Protheus.doc} ModelDef
Função que cria o objeto model			
@author Raphael Martins
@since 09/04/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruUJD := FWFormStruct(1,"UJD",/*bAvalCampo*/,/*lViewUsado*/ )

Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("PFUNA040",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("UJDMASTER",/*cOwner*/,oStruUJD)

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({"UJD_FILIAL","UJD_CODIGO"})

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel("UJDMASTER"):SetDescription("Locais de Velorio")

Return oModel

/*/{Protheus.doc} ModelDef
Função que cria o objeto View			
@author Raphael Martins
@since 09/04/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function ViewDef()

// Cria a estrutura a ser usada na View
Local oStruUJD := FWFormStruct(2,"UJD")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel("RFUNA040")
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_UJD",oStruUJD,"UJDMASTER")

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("PAINEL_CABEC", 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView("VIEW_UJD","PAINEL_CABEC")

// Liga a identificacao do componente
oView:EnableTitleView("VIEW_UJD","Locais de Velorio")

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk( {||.T.} )

Return oView 
