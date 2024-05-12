#include "protheus.ch" 
#include "fwmvcdef.ch"

/*/{Protheus.doc} RFUNA042
Monitoramento Solicitações de Produtos entre Filiais
@author TOTVS
@since 16/04/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

/***********************/
User Function RFUNA042()
/***********************/
Local oBrowse
Private aRotina := {}

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("UJF")
oBrowse:SetDescription("Monitor Solicitações Estoque")  
oBrowse:AddLegend("UJF_STATUS == 'W'", "WHITE",		"Workflow Enviado")
oBrowse:AddLegend("UJF_STATUS == 'A'", "GREEN",		"Solicitação Aprovada")
oBrowse:AddLegend("UJF_STATUS == 'R'", "BLUE",		"Solicitação Rejeitada")
oBrowse:AddLegend("UJF_STATUS == 'T'", "RED",		"Transfência/Separação Concluída")  
oBrowse:Activate()

Return Nil

/************************/
Static Function MenuDef()
/************************/

Local aRotina 	:= {}

ADD OPTION aRotina Title "Visualizar" 							Action "VIEWDEF.RFUNA042"	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title "Aprovar" 								Action "U_FUNA042A()"		OPERATION 4 ACCESS 0
ADD OPTION aRotina Title "Rejeitar" 							Action "U_FUNA042R()"		OPERATION 4 ACCESS 0
ADD OPTION aRotina Title "Comunicar transferência/separação" 	Action "U_FUNA042T()"		OPERATION 4 ACCESS 0
ADD OPTION aRotina Title "Solicitação de Transferência" 		Action "U_FUNA042S()"		OPERATION 4 ACCESS 0
ADD OPTION aRotina Title 'Legenda'     							Action "U_FUNA042L()" 		OPERATION 6 ACCESS 0  

Return aRotina

/*************************/
Static Function ModelDef()
/*************************/

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruUJF := FWFormStruct(1,"UJF",/*bAvalCampo*/,/*lViewUsado*/ )
Local oStruUJG := FWFormStruct(1,"UJG",/*bAvalCampo*/,/*lViewUsado*/ )

Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("PFUNA042",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("UJFMASTER",/*cOwner*/,oStruUJF)

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({"UJF_FILIAL","UJF_CODIGO"})

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid("UJGDETAIL","UJFMASTER",oStruUJG,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation("UJGDETAIL", {{"UJG_FILIAL", 'xFilial("UJG")'},{"UJG_CODIGO","UJF_CODIGO"}},UJG->(IndexKey(1)))

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel("UJFMASTER"):SetDescription("Monitor Solicitações Estoque")
oModel:GetModel("UJGDETAIL"):SetDescription("Itens")

Return oModel

/************************/
Static Function ViewDef()
/************************/

// Cria a estrutura a ser usada na View
Local oStruUJF := FWFormStruct(2,"UJF")
Local oStruUJG := FWFormStruct(2,"UJG")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel("RFUNA042")
Local oView

// Remove campos da estrutura
oStruUJG:RemoveField('UJG_CODIGO')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_UJF",oStruUJF,"UJFMASTER")

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid("VIEW_UJG",oStruUJG,"UJGDETAIL")

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("PAINEL_CABEC", 60)
oView:CreateHorizontalBox("PAINEL_ITENS", 40)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView("VIEW_UJF","PAINEL_CABEC")
oView:SetOwnerView("VIEW_UJG","PAINEL_ITENS")

// Liga a identificacao do componente
oView:EnableTitleView("VIEW_UJF","Monitor Solicitações Estoque")
oView:EnableTitleView("VIEW_UJG","Itens")

// Define campos que terao Auto Incremento
oView:AddIncrementField("VIEW_UJG","UJG_ITEM")

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk( {||.T.} )

Return oView 

/***********************/
User Function FUNA042L()
/***********************/

BrwLegenda("Status","Legenda",{{"BR_BRANCO","Workflow Enviado"},;
								{"BR_VERDE","Solicitação Aprovada"},;
								{"BR_AZUL","Solicitação Rejeitada"},;
								{"BR_VERMELHO","Transfência/Separação Concluída"}})
								

Return 

/***********************/
User Function FUNA042A()
/***********************/

Local lContinua := .T.

Do Case

	Case UJF->UJF_STATUS == "A" //Aprovada
		MsgInfo("A solicitação de transferência já se encontra aprovada, operação não permitida.","Atenção")
		lContinua := .F.

	Case UJF->UJF_STATUS == "T" //Transferida/separada
		MsgInfo("A solicitação de transferência se encontra transferida/separada, operação não permitida.","Atenção")
		lContinua := .F.
EndCase

If lContinua
	
	If MsgYesNo("A solicitação de transferência será aprovada, deseja continuar?")
	
		RecLock("UJF",.F.)
		UJF->UJF_STATUS := "A" //Aprovada
		UJF->(MsUnlock())	
	Endif	

	MsgInfo("Solicitação de transferência aprovada.","Atenção")
Endif

Return

/***********************/
User Function FUNA042R()
/***********************/

Local lContinua := .T.

Do Case

	Case UJF->UJF_STATUS == "R" //Rejeitada
		MsgInfo("A solicitação de transferência já se encontra rejeitada, operação não permitida.","Atenção")
		lContinua := .F.

	Case UJF->UJF_STATUS == "T" //Transferida/separada
		MsgInfo("A solicitação de transferência se encontra transferida/separada, operação não permitida.","Atenção")
		lContinua := .F.
EndCase

If lContinua
	
	If MsgYesNo("A solicitação de transferência será rejeitada, deseja continuar?")
	
		RecLock("UJF",.F.)
		UJF->UJF_STATUS := "R" //Rejeitada
		UJF->(MsUnlock())	
	Endif	

	MsgInfo("Solicitação de transferência rejeitada.","Atenção")
Endif

Return

/***********************/
User Function FUNA042T()
/***********************/

Local lContinua := .T.

Do Case

	Case UJF->UJF_STATUS == "T" //Transferida/separada
		MsgInfo("A solicitação de transferência já se encontra concluída, operação não permitida.","Atenção")
		lContinua := .F.

	Case UJF->UJF_STATUS == "R" //Rejeitada
		MsgInfo("A solicitação de transferência se encontra rejeitada, operação não permitida.","Atenção")
		lContinua := .F.

	Case UJF->UJF_STATUS == "W" //Workflow
		MsgInfo("A solicitação de transferência se encontra pendente de análise, operação não permitida.","Atenção")
		lContinua := .F.
EndCase

If lContinua
	
	If MsgYesNo("A solicitação de transferência será concluída, deseja continuar?")
	
		RecLock("UJF",.F.)
		UJF->UJF_STATUS := "T" //Tranferida/separada
		UJF->(MsUnlock())	
	Endif	

	MsgInfo("Solicitação de transferência concluída.","Atenção")
Endif

Return

/***********************/
User Function FUNA042S()
/***********************/

FwExecView('Incluir',"MATA311",MODEL_OPERATION_INSERT,,{|| .T.})

Return