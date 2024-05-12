#include "protheus.ch" 
#include "fwmvcdef.ch"
#include "topconn.ch"

/*/{Protheus.doc} RFUNE029
Personalizar Plano - Funeraria
@author TOTVS
@since 28/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RFUNE029()
/***********************/
	
Local oBrowse
Local cName	:= Funname()

// Altero o nome da rotina para considerar o menu deste MVC
SetFunName("RFUNE029")

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("UH2")
oBrowse:SetDescription("Personalizar Plano")   
oBrowse:Activate()

// Retorno o nome da rotina
SetFunName(cName)

Return Nil

/************************/
Static Function MenuDef()
/************************/

Local aRotina 	:= {}

ADD OPTION aRotina Title 'Pesquisar'   						Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  						Action 'VIEWDEF.RFUNE029' 	OPERATION 02 ACCESS 0

Return aRotina

/*************************/
Static Function ModelDef()
/*************************/

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruUH2 := FWFormStruct(1,"UH2",/*bAvalCampo*/,/*lViewUsado*/ )//Cabecalho da Personalizacao
Local oStruUH3 := FWFormStruct(1,"UH3",/*bAvalCampo*/,/*lViewUsado*/ )//Produtos e Servicos Atuais do Contrato
Local oStruUH4 := FWFormStruct(1,"UH4",/*bAvalCampo*/,/*lViewUsado*/ )//Produtos e Servicos Novos do Contrato
Local oStruUH5 := FWFormStruct(1,"UH5",/*bAvalCampo*/,/*lViewUsado*/ )//Inclusao de Produtos e Servicos do Contrato
Local oStruUH6 := FWFormStruct(1,"UH6",/*bAvalCampo*/,/*lViewUsado*/ )//Alteracao de Produtos e Servicos do Contrato
Local oStruUH7 := FWFormStruct(1,"UH7",/*bAvalCampo*/,/*lViewUsado*/ )//Exclusao de Produtos e Servicos do Contrato

Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("PFUNE029",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("UH2MASTER",/*cOwner*/,oStruUH2)

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({"UH2_FILIAL","UH2_CODIGO"})

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid("UH3DETAIL","UH2MASTER",oStruUH3,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)
oModel:AddGrid("UH4DETAIL","UH2MASTER",oStruUH4,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)
oModel:AddGrid("UH5DETAIL","UH2MASTER",oStruUH5,/*bLinePre*/{|oMdlG,nLine,cAcao,cCampo| EditGrid(oMdlG,nLine,cAcao,cCampo,"UH5_VLRTOT")},/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)
oModel:AddGrid("UH6DETAIL","UH2MASTER",oStruUH6,/*bLinePre*/{|oMdlG,nLine,cAcao,cCampo| EditGrid(oMdlG,nLine,cAcao,cCampo,"UH6_VLRTOT")},/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)
oModel:AddGrid("UH7DETAIL","UH2MASTER",oStruUH7,/*bLinePre*/{|oMdlG,nLine,cAcao,cCampo| EditGrid(oMdlG,nLine,cAcao,cCampo,"UH7_VLRTOT")},/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation("UH3DETAIL", {{"UH3_FILIAL", 'xFilial("UH3")'},{"UH3_CODIGO","UH2_CODIGO"}},UH3->(IndexKey(1)))
oModel:SetRelation("UH4DETAIL", {{"UH4_FILIAL", 'xFilial("UH4")'},{"UH4_CODIGO","UH2_CODIGO"}},UH4->(IndexKey(1)))
oModel:SetRelation("UH5DETAIL", {{"UH5_FILIAL", 'xFilial("UH5")'},{"UH5_CODIGO","UH2_CODIGO"}},UH5->(IndexKey(1)))
oModel:SetRelation("UH6DETAIL", {{"UH6_FILIAL", 'xFilial("UH6")'},{"UH6_CODIGO","UH2_CODIGO"}},UH6->(IndexKey(1)))
oModel:SetRelation("UH7DETAIL", {{"UH7_FILIAL", 'xFilial("UH7")'},{"UH7_CODIGO","UH2_CODIGO"}},UH7->(IndexKey(1)))

// Liga o controle de nao repeticao de linha
oModel:GetModel('UH3DETAIL'):SetUniqueLine( {'UH3_PRODUT'} ) 
oModel:GetModel('UH4DETAIL'):SetUniqueLine( {'UH4_PRODUT'} ) 
oModel:GetModel('UH5DETAIL'):SetUniqueLine( {'UH5_PRODUT'} ) 
oModel:GetModel('UH6DETAIL'):SetUniqueLine( {'UH6_PRODUT'} ) 
oModel:GetModel('UH7DETAIL'):SetUniqueLine( {'UH7_PRODUT'} ) 

// Desobriga a digitacao de ao menos um item
oModel:GetModel("UH4DETAIL"):SetOptional(.T.)
oModel:GetModel("UH5DETAIL"):SetOptional(.T.)
oModel:GetModel("UH6DETAIL"):SetOptional(.T.)
oModel:GetModel("UH7DETAIL"):SetOptional(.T.)

oModel:GetModel("UH3DETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("UH3DETAIL"):SetNoUpdateLine(.T.)
oModel:GetModel("UH3DETAIL"):SetNoDeleteLine(.T.)

oModel:GetModel("UH4DETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("UH4DETAIL"):SetNoUpdateLine(.T.)
oModel:GetModel("UH4DETAIL"):SetNoDeleteLine(.T.)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel("UH2MASTER"):SetDescription("Dados Personalização:")
oModel:GetModel("UH3DETAIL"):SetDescription("Produtos/Serviços (Atual):")
oModel:GetModel("UH4DETAIL"):SetDescription("Produtos/Serviços (Novo):")
oModel:GetModel("UH5DETAIL"):SetDescription("Inclusão:")
oModel:GetModel("UH6DETAIL"):SetDescription("Alteração:")
oModel:GetModel("UH7DETAIL"):SetDescription("Exclusão:")

Return oModel

/************************/
Static Function ViewDef()
/************************/

// Cria a estrutura a ser usada na View
Local oStruUH2 := FWFormStruct(2,"UH2")
Local oStruUH3 := FWFormStruct(2,"UH3")
Local oStruUH4 := FWFormStruct(2,"UH4")
Local oStruUH5 := FWFormStruct(2,"UH5")
Local oStruUH6 := FWFormStruct(2,"UH6")
Local oStruUH7 := FWFormStruct(2,"UH7")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel("RFUNE029")
Local oView

// Remove campos da estrutura
oStruUH3:RemoveField('UH3_CODIGO')
oStruUH4:RemoveField('UH4_CODIGO')
oStruUH5:RemoveField('UH5_CODIGO')
oStruUH6:RemoveField('UH6_CODIGO')
oStruUH7:RemoveField('UH7_CODIGO')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_UH2",oStruUH2,"UH2MASTER")

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid("VIEW_UH3",oStruUH3,"UH3DETAIL")
oView:AddGrid("VIEW_UH4",oStruUH4,"UH4DETAIL")
oView:AddGrid("VIEW_UH5",oStruUH5,"UH5DETAIL")
oView:AddGrid("VIEW_UH6",oStruUH6,"UH6DETAIL")
oView:AddGrid("VIEW_UH7",oStruUH7,"UH7DETAIL")

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("PAINEL_CABEC", 40)

oView:CreateVerticalBox("PANEL_CAMPOS",090,"PAINEL_CABEC")
oView:CreateVerticalBox("PANEL_RESUMO",010,"PAINEL_CABEC")

oView:CreateHorizontalBox("PAINEL_ITENS", 60)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView("VIEW_UH2","PANEL_CAMPOS")

// Cria componentes nao MVC
oView:AddOtherObject("RESUMO", {|oPanel| oResumoTotal := CriaResumo(oPanel)})
oView:SetOwnerView("RESUMO",'PANEL_RESUMO')

// Cria Folder na view
oView:CreateFolder("PASTAS","PAINEL_ITENS")

// Cria pastas nas folders
oView:AddSheet("PASTAS","ABA01","Alteração de Plano")
oView:AddSheet("PASTAS","ABA02","Inclusão, Alteração e Exclusão de Produtos/Serviços")

//Panels de Alteracao de Planos
oView:CreateHorizontalBox("PANEL_ALTERACAO_PLANO",100,,,"PASTAS","ABA01")
oView:CreateVerticalBox("PANEL_PLANO_ATUAL",050,"PANEL_ALTERACAO_PLANO",,"PASTAS","ABA01")
oView:CreateVerticalBox("PANEL_NOVO_PLANO",050,"PANEL_ALTERACAO_PLANO",,"PASTAS","ABA01")

//Panels de Personalizacao de Planos
oView:CreateHorizontalBox("PANEL_PERSONALIZACAO_PLANO",100,,,"PASTAS","ABA02")

oView:CreateVerticalBox("PANEL_ESQUERDO_PRODUTOS",050,"PANEL_PERSONALIZACAO_PLANO",,"PASTAS","ABA02")
oView:CreateVerticalBox("PANEL_DIREITO_PRODUTOS",050,"PANEL_PERSONALIZACAO_PLANO",,"PASTAS","ABA02")

//Crio Panels Esquerdo da Aba de Produtos - Inclusao e Exclusao de Produtos
oView:CreateHorizontalBox("PANEL_INCLUSAO_PRODUTOS",050,"PANEL_ESQUERDO_PRODUTOS",,"PASTAS","ABA02")
oView:CreateHorizontalBox("PANEL_EXCLUSAO_PRODUTOS",050,"PANEL_ESQUERDO_PRODUTOS",,"PASTAS","ABA02")

//Crio Panel Direito da Aba de Produtos - Alteracao de Produtos
oView:CreateHorizontalBox("PANEL_ALTERACAO_PRODUTOS",050,"PANEL_DIREITO_PRODUTOS",,"PASTAS","ABA02")


oView:SetOwnerView("VIEW_UH3","PANEL_PLANO_ATUAL")
oView:SetOwnerView("VIEW_UH4","PANEL_NOVO_PLANO")

oView:SetOwnerView("VIEW_UH5","PANEL_INCLUSAO_PRODUTOS")
oView:SetOwnerView("VIEW_UH6","PANEL_ALTERACAO_PRODUTOS")

oView:SetOwnerView("VIEW_UH7","PANEL_EXCLUSAO_PRODUTOS")


// Liga a identificacao do componente
oView:EnableTitleView("VIEW_UH2","Dados Personalização:")
oView:EnableTitleView("VIEW_UH3","Produtos/Serviços (Atual):")
oView:EnableTitleView("VIEW_UH4","Produtos/Serviços (Novo):")
oView:EnableTitleView("VIEW_UH5","Inclusão:")
oView:EnableTitleView("VIEW_UH6","Alteração:")
oView:EnableTitleView("VIEW_UH7","Exclusão:")

// Define campos que terao Auto Incremento
oView:AddIncrementField("VIEW_UH3","UH3_ITEM")
oView:AddIncrementField("VIEW_UH4","UH4_ITEM")
oView:AddIncrementField("VIEW_UH5","UH5_ITEM")
oView:AddIncrementField("VIEW_UH6","UH6_ITEM")
oView:AddIncrementField("VIEW_UH7","UH7_ITEM")


// Inicializo alguns campos
oView:SetAfterViewActivate({|oView| IniCpos(oModel,oView)})

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk( {||.T.} )

// Habilito a barra de progresso na abertura da tela
oView:SetProgressBar(.T.)

Return oView    

/************************************/
Static Function IniCpos(oModel,oView)
/************************************/

Local oModelUH2		:= oModel:GetModel("UH2DETAIL")
Local oModelUH3		:= oModel:GetModel("UH3DETAIL")
Local nOperation	:= oView:GetOperation()
Local cDescProd		:= ""

If nOperation == 3 //Inclusão
 
	//Cabeçalho
	FwFldPut("UH2_CONTRA",UF2->UF2_CODIGO,,,,.F.)
	FwFldPut("UH2_HORA",SubStr(Time(),1,5),,,,.F.)
	FwFldPut("UH2_USER",__cUserId,,,,.F.)
	FwFldPut("UH2_NOUSER",cUserName,,,,.F.)
	
	//Aba Alteração e Plano - Grid Produtos (atual)
	//libero alteracao da grid e posteriormente bloqueio novamente - itens do contrato
	oModel:GetModel("UH3DETAIL"):SetNoInsertLine(.F.)
	oModel:GetModel("UH3DETAIL"):SetNoUpdateLine(.F.)
	oModel:GetModel("UH3DETAIL"):SetNoDeleteLine(.F.)
	
	U_LimpaAcolsMVC(oModelUH3,oView)

	DbSelectArea("UF3")
	UF3->(DbSetOrder(1)) //UF3_FILIAL+UF3_CODIGO+UF3_ITEM
	
	If UF3->(DbSeek(xFilial("UF3")+UF2->UF2_CODIGO))
		
		While UF3->(!EOF()) .And. UF3->UF3_FILIAL == xFilial("UF3") .And. UF3->UF3_CODIGO == UF2->UF2_CODIGO
			
			//Se a primeira linha não estiver em branco, insiro uma nova linha
			If !Empty(oModelUH3:GetValue("UH3_PRODUT")) 
				oModelUH3:AddLine()
				oModelUH3:GoLine(oModelUH3:Length())
		   	Endif
			
			cDescProd := RetField("SB1",1,xFilial("SB1")+UF3->UF3_PROD,"B1_DESC")
			
			oModelUH3:LoadValue("UH3_ITEM",StrZero(oModelUH3:Length(),3))	   			
			oModelUH3:LoadValue("UH3_TIPO",UF3->UF3_TIPO)
			oModelUH3:LoadValue("UH3_PRODUT",UF3->UF3_PROD)
			oModelUH3:LoadValue("UH3_DESCRI",cDescProd)
			oModelUH3:LoadValue("UH3_VLRUNI",UF3->UF3_VLRUNI)
			oModelUH3:LoadValue("UH3_QUANT",UF3->UF3_QUANT)
			oModelUH3:LoadValue("UH3_VLRTOT",UF3->UF3_VLRTOT)
			oModelUH3:LoadValue("UH3_SALDO",UF3->UF3_SALDO)
			oModelUH3:LoadValue("UH3_CTRSLD",UF3->UF3_CTRSLD)
			
			UF3->(DbSkip())
		EndDo
	
	Endif

	//Aba Alteração e Plano - Grid Serviços (atual)
	//libero alteracao da grid e posteriormente bloqueio novamente - servicos do contrato
	oModel:GetModel("UH3DETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("UH3DETAIL"):SetNoUpdateLine(.T.)
	oModel:GetModel("UH3DETAIL"):SetNoDeleteLine(.T.)
	
	oModelUH3:GoLine(1)
  
	oView:Refresh()
	
Endif

Return
/*/{Protheus.doc} CriaResumo
Funcao para criar os objetos resumo 
@author Raphael Martins
@since 13/08/2018
@version 1.0
@return lRet			- Servico Validado
@type function
/*/
Static Function CriaResumo(oPanel)

Local oTotal := ObjTotFun():New(oPanel) 


Return(oTotal)

/*/{Protheus.doc} ObjTotal
Classe para criar os objetos totalizadores 
@author Raphael Martins
@since 13/08/2018
@version 1.0
@return lRet			- Servico Validado
@type function
/*/
Class ObjTotFun 

//atributos da classe
Data oValAtual
Data oNewValor

Data nValAtual
Data nNewValor

//metodo construtor da classe
Method New() Constructor 

//metodo de refresh dos objetos
Method RefreshTot()
        
EndClass

/*/{Protheus.doc} ObjTotal
Método construtor da classe ObjTotal
@author Raphael Martins
@since 13/08/2018
@version 1.0
@return lRet			- Servico Validado
@type function
/*/
Method New(oPanel) Class ObjTotFun 

Local oPanelCpo		:= NIL
Local oSayVlAtual	:= NIL
Local oPanelPrinc	:= NIL
Local oPanelAtual	:= NIL
Local oPanelNovo	:= NIL
Local oSayVlNew		:= NIL
Local oModel		:= FWModelActive()
Local oFont07N	   	:= TFont():New("Verdana",07,18,,.T.,,,,.T.,.F.) ///Fonte 14 Negrito
Local oFontNum	   	:= TFont():New("Verdana",07,18,,.F.,,,,.T.,.F.) ///Fonte 14 Negrito
Local nHeigth		:= oPanel:nClientHeight / 2
Local nWhidth		:= oPanel:nClientWidth / 2 
Local nAltPnl		:= (nHeigth / 2) - 5
Local nLargPn		:= nWhidth - 7
Local nLinPnl2		:= (nHeigth / 2)

if oModel:GetOperation() == MODEL_OPERATION_INSERT

	::nValAtual := (UF2->UF2_VALOR + UF2->UF2_VLADIC + UF2->UF2_VLADAG)
	::nNewValor := (UF2->UF2_VALOR + UF2->UF2_VLADIC + UF2->UF2_VLADAG)

else
	
	::nValAtual := UH2->UH2_VLRANT
	::nNewValor := UH2->UH2_NEWVLR
	
endif


@ 000, 000 MSPANEL oPanelPrinc SIZE nWhidth , nHeigth OF oPanel COLORS 0, 15724527 RAISED

@ 002, 005 MSPANEL oPanelAtual SIZE nLargPn , nAltPnl OF oPanelPrinc COLORS 0, 15724527 RAISED

@ 005, 002 SAY oSayVlAtual PROMPT "Valor Vigente:" SIZE 150, 010 OF oPanelAtual FONT oFont07N COLORS 32896, 16777215 PIXEL 

@ 016, 002 SAY ::oValAtual PROMPT "R$ " + AllTrim(Transform(::nValAtual,"@E 999,999,999.99")) SIZE 150, 010 OF oPanelAtual FONT oFontNum COLORS 7566195, 16777215 PIXEL 


@ nLinPnl2 , 005 MSPANEL oPanelNovo SIZE nLargPn , nAltPnl OF oPanelPrinc COLORS 0, 15724527 RAISED

@ 005, 002 SAY oSayVlNew PROMPT "Valor Atual:" SIZE 150, 010 OF oPanelNovo FONT oFont07N COLORS /*7566195*/ 32896, 16777215 PIXEL 

@ 016, 002 SAY ::oNewValor PROMPT "R$ " + AllTrim(Transform(::nNewValor,"@E 999,999,999.99")) SIZE 150, 010 OF oPanelNovo FONT oFontNum COLORS 7566195, 16777215 PIXEL

Return

/*/{Protheus.doc} ObjTotal
Método para atualizar totalizadores
do contrato
@author Raphael Martins
@since 13/08/2018
@version 1.0
@return lRet			- Servico Validado
@type function
/*/
Method RefreshTot(nVlrDel,lSoma) Class ObjTotFun  

Local oModel		:= FWModelActive()     
Local oView			:= FWViewActive()
Local oModelUH2		:= oModel:GetModel("UH2MASTER")

Default nVlrDel		:= 0 
Default lSoma		:= .F.

if Empty(oModelUH2:GetValue("UH2_PLANNO"))
	
	aCamposProd := {"UH3_TIPO","UH3_PRODUT","UH3_DESCRI","UH3_VLRUNI","UH3_QUANT","UH3_VLRTOT","UH3_SALDO","UH3_CTRSLD"}
				
	nTotal	:= RetTotProd(oModel,"UH3DETAIL",aCamposProd)
	
else
	
	aCamposGrid := {"UH4_TIPO","UH4_PRODUT","UH4_DESCRI","UH4_VLRUNI","UH4_QUANT","UH4_VLRTOT","UH4_SALDO","UH4_CTRSLD"}
				
	nTotal	:= RetTotProd(oModel,"UH4DETAIL",aCamposGrid)
	
endif

if !lSoma
	nTotal	-= nVlrDel
else
	nTotal	+= nVlrDel
endif

::nNewValor := nTotal
::oNewValor:Refresh()

Return()

/*/{Protheus.doc} RetTotProd
Funcao para retornar o total da nova
negociacao do contrato
@author Raphael Martins
@since 13/08/2018
@version 1.0
@return lRet			- Servico Validado
@type function
/*/
Static Function RetTotProd(oObj,cModelGrid,aCamposGrid)

	Local oModelUH2		:= oObj:GetModel("UH2MASTER")
	Local oModelGrid	:= oObj:GetModel(cModelGrid)
	Local oModelUH5		:= oObj:GetModel("UH5DETAIL")
	Local oModelUH6		:= oObj:GetModel("UH6DETAIL")
	Local oModelUH7		:= oObj:GetModel("UH7DETAIL")
	Local nLineUH5		:= oModelUH5:GetLine()
	Local nLineUH6		:= oModelUH6:GetLine()
	Local nLineUH7		:= oModelUH7:GetLine()
	Local nLineGrid		:= oModelGrid:GetLine()
	Local nX			:= 0
	Local nJ			:= 0 
	Local nY			:= 0 
	Local nRetTot		:= 0 
	Local lExcluido		:= .F.
	Local lAlterado		:= .F.
	 
	
	//verifico se houve alteracao do item
	For nX := 1 To oModelGrid:Length()
		
		lExcluido := .F.
		lAlterado := .F.
		
		oModelGrid:GoLine(nX)
					
		if !oModelGrid:IsDeleted() .And. !Empty(oModelGrid:GetValue(aCamposGrid[2])) 
			
			//verifico se o item esta na tabela de exclusao 
			For nY := 1 To oModelUH7:Length()
			
				oModelUH7:GoLine(nY)
				
				if !oModelUH7:IsDeleted() .And. !Empty(oModelUH7:GetValue("UH7_PRODUT"))
					
					if oModelUH7:GetValue("UH7_PRODUT") == oModelGrid:GetValue(aCamposGrid[2])
						
						lExcluido := .T.
					
					endif
					
						
				endif
				
			Next nY
		
			
			if !lExcluido
			
				//verifico se o produto foi alterado, caso sim, sera gravado as informacoes da alteracao
				For nJ := 1 To oModelUH6:Length()
				
					oModelUH6:GoLine(nJ)
					
					
					if !oModelUH6:IsDeleted() .And. !Empty(oModelUH6:GetValue("UH6_PRODUT"))
						
						if oModelGrid:GetValue(aCamposGrid[2]) == oModelUH6:GetValue("UH6_PRODUT") 
							
							nRetTot += oModelUH6:GetValue("UH6_VLRTOT")
							
							lAlterado := .T.
							
							Exit 
							
						endif
						
					endif
					
				Next nJ
				
				//senao houve alteracao e exclusao para o item, adiciono o original
				if !lAlterado .And. !lExcluido
					
					nRetTot += oModelGrid:GetValue(aCamposGrid[6])
					
				endif
			
			endif
				
		endif
		
	Next nX
	
	//verifico se houve inclusao de produtos 
	For nX := 1 To oModelUH5:Length()
		
		aItem := {}
			
		oModelUH5:GoLine(nX)
				
		if !oModelUH5:IsDeleted() .And. !Empty(oModelUH5:GetValue("UH5_PRODUT"))
			
			nRetTot += oModelUH5:GetValue("UH5_VLRTOT") 
		
		endif 
		
	Next nX
	
	//restauro as linhas posicionadas
	oModelUH5:GoLine(nLineUH5)
	oModelUH6:GoLine(nLineUH6)
	oModelUH7:GoLine(nLineUH7)
	oModelGrid:GoLine(nLineGrid)


Return(nRetTot)

/*/{Protheus.doc} RFUNE29A
Funcao para validar o novo plano 
digitado 
@author Raphael Martins
@since 15/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RFUNE29A()

Local lRet 			:= .T.
Local oModel		:= FWModelActive()     
Local oView			:= FWViewActive()
Local oModelUH2		:= oModel:GetModel("UH2MASTER")
Local oModeLUH4		:= oModel:GetModel("UH4DETAIL")
Local cPlanNovo		:= oModelUH2:GetValue("UH2_PLANNO")
Local aSoluc		:= {}
Local nVlrTotal		:= 0


If !Empty(cPlanNovo)
	
	//limpo as grids da tela
	LimpaGrids()
	
	//verifico se o plano novo e o mesmo do plano atual
	if cPlanNovo <> UF2->UF2_PLANO
		
		DbSelectArea("UF0")
		UF0->(DbSetOrder(1)) //UF0_FILIAL+UF0_CODIGO
		
		If !UF0->(DbSeek(xFilial("UF0")+cPlanNovo))
			
			aSoluc := {"Verifique se o plano digitado esta cadastrado na base do sistema!"}
			Help( NIL, NIL ,,,"Plano inválido.",1,0,/*lPop*/,/*hWnd*/,/*hHeight*/,/*nWidth*/,/*lGravaLog*/.F.,aSoluc)	
			
			lRet := .F.
		
		else
		
			If UF0->UF0_STATUS == "I" //Inativo
		
				Help(,,'Help',,"O plano digitado se encontra inativo.",1,0)	
				lRet := .F.
				
			elseif (!Empty(UF0->UF0_DTINI) .And. UF0->UF0_DTINI > dDatabase) .Or. (!Empty(UF0->UF0_DTFIM) .And. UF0->UF0_DTFIM < dDatabase)  
				
				Help(,,'Help',,"O plano digitado se encontra fora de vigência!.",1,0)	
				lRet := .F.
				
			endif		
		
		endif
		
		//libero alteracao da grid e posteriormente bloqueio novamente - itens do contrato
		oModel:GetModel("UH4DETAIL"):SetNoInsertLine(.F.)
		oModel:GetModel("UH4DETAIL"):SetNoUpdateLine(.F.)
		oModel:GetModel("UH4DETAIL"):SetNoDeleteLine(.F.)
		
		
		//Prencho os servicos do novo plano
		if lRet
			
			UF1->(DbSetOrder(1)) //UF1_FILIAL+UF1_CODIGO+UF1_ITEM
			           
			If UF1->(DbSeek(xFilial("UF1")+UF0->UF0_CODIGO))
			
				While UF1->(!Eof()) .And. UF1->UF1_FILIAL == xFilial("UF1") .And. UF1->UF1_CODIGO == UF0->UF0_CODIGO
					
					SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD
					
					if SB1->(DbSeek(xFilial("SB1")+UF1->UF1_PROD))
					
						//valido se a personalizacao de planos esta ativa
						if ( nPrecoItem := RetPrecoVenda(UF0->UF0_TABPRE,UF1->UF1_PROD) ) == 0
							
							Help(,,'Help',,"Produto: " + Alltrim(UF1->UF1_PROD) + " não possui preço definido!",1,0)	
							lRet := .F.
							Exit 
					
						endif
						
						oModelUH4:GoLine(oModelUH4:Length())
						
						cDescProd := RetField("SB1",1,xFilial("SB1")+UF1->UF1_PROD,"B1_DESC")
						
						//Se a primeira linha não estiver em branco, insiro uma nova linha
						If !Empty(oModelUH4:GetValue("UH4_PRODUT")) .Or. oModelUH4:isDeleted() 
							oModelUH4:AddLine()
							oModelUH4:GoLine(oModelUH4:Length())
						Endif
						
						oModelUH4:LoadValue("UH4_ITEM",StrZero(oModelUH4:Length(),3))   	
					   	oModelUH4:LoadValue("UH4_TIPO","AVGBOX1.PNG")		
						oModelUH4:LoadValue("UH4_PRODUT",UF1->UF1_PROD)
						oModelUH4:LoadValue("UH4_DESCRI",cDescProd)
						
						oModelUH4:LoadValue("UH4_VLRUNI",nPrecoItem)
						oModelUH4:LoadValue("UH4_QUANT",UF1->UF1_QUANT)
						oModelUH4:LoadValue("UH4_VLRTOT",nPrecoItem * UF1->UF1_QUANT)
						oModelUH4:LoadValue("UH4_SALDO",UF1->UF1_QUANT)
						oModelUH4:LoadValue("UH4_CTRSLD",If(!Empty(SB1->B1_XDEBPRE),SB1->B1_XDEBPRE,'N'))
						
						nVlrTotal += nPrecoItem * UF1->UF1_QUANT
						
					else
						
						lRet := .F.
						Help(,,'Help',,"Produto: " + Alltrim(UF1->UF1_PROD) + " não encontrado no cadastro de produtos!",1,0)	
						Exit 
				
					endif
						
					UF1->(DbSkip())
				EndDo
				
				// bloqueio novamente - servicos do contrato
				oModel:GetModel("UH4DETAIL"):SetNoInsertLine(.T.)
				oModel:GetModel("UH4DETAIL"):SetNoUpdateLine(.T.)
				oModel:GetModel("UH4DETAIL"):SetNoDeleteLine(.T.)
		
				oModelUH4:GoLine(1)
				oView:Refresh()
				
			Endif  
		
		endif
		
		//atualizo o totalizador da tela
		if lRet
			oResumoTotal:RefreshTot()
		endif

	else
		
		lRet := .F.
		cMensagem	:= "Plano selecionado é o atual do contrato!"
		aSoluc 		:= {"Selecione outro plano ou utilize a aba Inclusao e Exclusão de Serviços para personalizar o plano!"}
		Help( NIL, NIL ,,,cMensagem,1,0,/*lPop*/,/*hWnd*/,/*hHeight*/,/*nWidth*/,/*lGravaLog*/.F.,aSoluc)	
			
	endif
	
Else
	
	oModelUH2:LoadValue("UH2_DESPNO",Space(TamSx3("UH2_DESPNO")[1]))	
						
	//limpo as grids da tela
	LimpaGrids()
	
	oResumoTotal:RefreshTot()
	
Endif

Return(lRet)

/*/{Protheus.doc} LimpaGrids
Funcao para limpar as grids da tela de 
personalizacoes
@author Raphael Martins 
@since 21/05/2018
@version P12
@return nPreco - Preco de Venda da Tabela
/*/
Static Function LimpaGrids()

Local oModel		:= FWModelActive()     
Local oView			:= FWViewActive()
Local oModelUH4		:= oModel:GetModel("UH4DETAIL")
Local oModelUH5		:= oModel:GetModel("UH5DETAIL")
Local oModelUH6		:= oModel:GetModel("UH6DETAIL")
Local oModelUH7		:= oModel:GetModel("UH7DETAIL")
Local aSaveLines	:= FWSaveRows() 


//libero alteracao da grid e posteriormente bloqueio novamente - itens do contrato
oModel:GetModel("UH4DETAIL"):SetNoInsertLine(.F.)
oModel:GetModel("UH4DETAIL"):SetNoUpdateLine(.F.)
oModel:GetModel("UH4DETAIL"):SetNoDeleteLine(.F.)
	
oModelUH4:DelAllLine() 
oModelUH5:DelAllLine() 
oModelUH6:DelAllLine() 
oModelUH7:DelAllLine() 

oModel:GetModel("UH4DETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("UH4DETAIL"):SetNoUpdateLine(.T.)
oModel:GetModel("UH4DETAIL"):SetNoDeleteLine(.T.)



//restauro as linhas posicionadas
FWRestRows( aSaveLines )
	
oView:Refresh()	


Return()

/*/{Protheus.doc} RetPrecoVenda
Funcao para retornar o preco de venda do item
de acordo com a tabela
@author Raphael Martins 
@since 21/05/2018
@version P12
@return nPreco - Preco de Venda da Tabela
/*/
Static Function RetPrecoVenda(cCodTab,cProduto)

Local aAreaDA1	:= DA1->(GetArea())
Local cQry 		:= ""
Local nPreco	:= 0

cQry := " SELECT "
cQry += " DA1_PRCVEN PRECO, "
cQry += " DA1_DATVIG VIGENCIA " 
cQry += " FROM  "
cQry += + RetSQLName("DA1")
cQry += " WHERE "
cQry += " D_E_L_E_T_ = ' '  "
cQry += " AND DA1_FILIAL = '"+xFilial("DA1")+"' "
cQry += " AND DA1_CODPRO = '"+cProduto+"'
cQry += " AND DA1_CODTAB = '"+cCodTab+"'
cQry += " ORDER BY DA1_DATVIG DESC

if Select("QRYTAB") > 0 
	QRYTAB->(DbCloseArea())
endif

cQry := ChangeQuery(cQry)

TcQuery cQry NEW Alias "QRYTAB"

//verifico se o preco esta vigente
if STOD(QRYTAB->VIGENCIA) <= dDataBase
	nPreco := QRYTAB->PRECO
endif

RestArea(aAreaDA1)

Return(nPreco)

/*/{Protheus.doc} RFUNE29B
//TODO Funcao para validar o produto digitado na grid
de inclusao na tela de personalizacao de planos
@author Raphael Martins
@since 13/08/2018
@version 1.0
@return lRet			- Produto Validado
@type function
/*/

User Function RFUNE29B()

Local aArea			:= GetArea()
Local aAreaSB1		:= SB1->(GetArea())
Local aAreaUH5		:= UH5->(GetArea())
Local aSaveLines	:= FWSaveRows() 
Local oModel		:= FWModelActive()     
Local oView			:= FWViewActive()
Local oModelUH2		:= oModel:GetModel("UH2MASTER") 
Local oModelUH5		:= oModel:GetModel("UH5DETAIL") 
Local cPlanoSel		:= oModelUH2:GetValue("UH2_PLANNO")
Local cProduto		:= oModelUH5:GetValue("UH5_PRODUT")
Local cPlano		:= UF2->UF2_PLANO
Local lRet			:= .T.
Local nVlrTotal		:= 0 
Local nVlrDeb		:= 0 

//valido se o produto existe no cadastro de produtos
SB1->(DBSetOrder(1)) //B1_FILIAL + B1_COD

if !Empty(cProduto)
	
	if SB1->(DbSeek(xFilial("SB1")+cProduto))
		
		//verifico se produto digitado ja esta contido no plano alterado
		if !Empty(cPlanoSel)
				
			cPlano	:= cPlanoSel 
				
			if !(lRet 	:= IPrdPlan("UH4DETAIL","UH4_PRODUT",cProduto))
					
				Help(,,'Help',,"Produto selecionado já está contido no plano alterado, favor selecione outro produto!",1,0)
				
			endif
				
		//senao possui plano alterado, verifico se esta contido no plano atual 
		elseif !IPrdPlan("UH3DETAIL","UH3_PRODUT",cProduto)
				
			lRet := .F.
			Help(,,'Help',,"Produto selecionado já está contido no plano atual, favor selecione outro produto!",1,0)
				
		endif
			
		if lRet
				
			if ( nPreco := RetPrecoVenda(M->UH2_TABPRE,cProduto) ) > 0 
					
				UF1->(DbSetOrder(2)) //UF1_FILIAL+UF1_CODIGO+UF1_PRODUT
				
				//valor a ser debitado antes do recaculo do produto digitado
				nVlrDeb := oModelUH5:GetValue("UH5_VLRTOT")
						
				if UF1->(DbSeek(xFilial("UF1")+cPlano+cProduto))
						
					oModelUH5:LoadValue("UH5_TIPO"		, "AVGBOX1.PNG" )
					oModelUH5:LoadValue("UH5_QUANT"		, UF1->UF1_QUANT )
					oModelUH5:LoadValue("UH5_SALDO"		, UF1->UF1_QUANT )
					oModelUH5:LoadValue("UH5_VLRTOT"	, nPreco * UF1->UF1_QUANT)
					
					nVlrTotal := nPreco * UF1->UF1_QUANT
						
				else
						
					oModelUH5:LoadValue("UH5_TIPO"		, "ADDITENS.PNG" )
					oModelUH5:LoadValue("UH5_QUANT"		, 1 )
					oModelUH5:LoadValue("UH5_SALDO"		, 1 )
					oModelUH5:LoadValue("UH5_VLRTOT"	, nPreco)
					
				endif
					
				oModelUH5:LoadValue("UH5_DESCRI"	, SB1->B1_DESC ) 
				oModelUH5:LoadValue("UH5_VLRUNI"	, nPreco) 
				oModelUH5:LoadValue("UH5_CTRSLD"	, If(!Empty(SB1->B1_XDEBPRE),SB1->B1_XDEBPRE,'N')) 
					
				nVlrTotal := nPreco 
					
			else
				
				lRet := .F.
				
			endif
			
		endif
		
	else
		
		lRet := .F.
		Help(,,'Help',,"Produto não encontrado no cadastro de produtos!",1,0)	
		
	endif

else
	
	//valor a ser debitado antes do recaculo do produto digitado
	nVlrDeb := oModelUH5:GetValue("UH5_VLRTOT")
				
	oModelUH5:LoadValue("UH5_TIPO"		, "" )
	oModelUH5:LoadValue("UH5_QUANT"		, 0	 )
	oModelUH5:LoadValue("UH5_SALDO"		, 0  )
	oModelUH5:LoadValue("UH5_VLRTOT"	, 0  )
	oModelUH5:LoadValue("UH5_DESCRI"	, "" ) 
	oModelUH5:LoadValue("UH5_VLRUNI"	, 0  ) 
	oModelUH5:LoadValue("UH5_CTRSLD"	, "" ) 
				
endif

if lRet 
	
	//atualizo totalizador do contrato
	oResumoTotal:RefreshTot() 
	
	
	//restauro as linhas posicionadas
	FWRestRows( aSaveLines )
		
endif

RestArea(aArea)
RestArea(aAreaSB1)
RestArea(aAreaUH5)

Return(lRet)

/*/{Protheus.doc} ProdPlanAlt
Funcao para validar se o produto digitado
esta contido no plano alterado ou atual
@author Raphael Martins 
@since 14/08/2018
@version P12
/*/
Static Function IPrdPlan(cModelGrid,cCampo,cProduto)

Local aSaveLines	:= FWSaveRows() 
Local oModel		:= FWModelActive() 
Local oView			:= FWViewActive() 
Local oModelGrid	:= oModel:GetModel(cModelGrid) 
Local nX			:= 0
Local lRet			:= .T.

//verifico se o item selecionado esta contido na grid de produtos atuais do plano
For nX := 1 To  oModelGrid:Length()
	
	oModelGrid:GoLine(nX)
	if !oModelGrid:isDeleted() .And. oModelGrid:GetValue(cCampo) == cProduto
		
		lRet := .F.
		
	endif
	
Next nX 

//restauro as linhas posicionadas
FWRestRows( aSaveLines )

oModelGrid:GoLine(1)

Return(lRet)

/*/{Protheus.doc} RFUNE29C
//TODO Funcao para validar o produto digitado na grid
de alteracao na tela de personalizacao de planos
@author Raphael Martins
@since 13/08/2018
@version 1.0
@return lRet			- Produto Validado
@type function
/*/

User Function RFUNE29C()

Local aArea			:= GetArea()
Local aAreaSB1		:= SB1->(GetArea())
Local aAreaUH6		:= UH6->(GetArea())
Local aSaveLines	:= FWSaveRows() 
Local oModel		:= FWModelActive()     
Local oView			:= FWViewActive()
Local oModelUH2		:= oModel:GetModel("UH2MASTER") 
Local oModelUH6		:= oModel:GetModel("UH6DETAIL") 
Local oModelUH3		:= oModel:GetModel("UH3DETAIL") 
Local oModelUH4		:= oModel:GetModel("UH4DETAIL") 
Local cPlanoSel		:= oModelUH2:GetValue("UH2_PLANNO")
Local cProduto		:= oModelUH6:GetValue("UH6_PRODUT")
Local cPlano		:= UF2->UF2_PLANO
Local lRet			:= .F.
Local nX			:= 1

//valido se o produto existe no cadastro de produtos
SB1->(DBSetOrder(1)) //B1_FILIAL + B1_COD

if !Empty(cProduto)
	
	if SB1->(DbSeek(xFilial("SB1")+cProduto))
	
		if IPrdPlan("UH7DETAIL","UH7_PRODUT",cProduto)
		
			//valor a ser debitado, antes da inclusao do proximo item
			nVlrDeb := oModelUH6:GetValue("UH6_VLRTOT")
			
			if !Empty(cPlanoSel)
			
				//verifico se o item selecionado esta contido na grid de produtos alterados do plano
				For nX := 1 To  oModelUH4:Length()
		
					oModelUH4:GoLine(nX)
		
					if oModelUH4:GetValue("UH4_PRODUT") == cProduto
						
						if oModelUH6:GetValue("UH6_VLRTOT") > 0 
							
							nVlrAdd := oModelUH6:GetValue("UH6_VLRTOT")
							
						endif
						
						oModelUH6:LoadValue("UH6_TIPO"		, oModelUH4:GetValue("UH4_TIPO") )
						oModelUH6:LoadValue("UH6_QUANT"		, oModelUH4:GetValue("UH4_QUANT") )
						oModelUH6:LoadValue("UH6_SALDO"		, oModelUH4:GetValue("UH4_SALDO") )
						oModelUH6:LoadValue("UH6_VLRTOT"	, oModelUH4:GetValue("UH4_VLRTOT"))
						oModelUH6:LoadValue("UH6_DESCRI"	, oModelUH4:GetValue("UH4_DESCRI") ) 
						oModelUH6:LoadValue("UH6_VLRUNI"	, oModelUH4:GetValue("UH4_VLRUNI") ) 
						oModelUH6:LoadValue("UH6_CTRSLD"	, oModelUH4:GetValue("UH4_CTRSLD") ) 
				
						lRet := .T.
						
						Exit
					
						
					endif
			
				Next nX 
	
				oModelUH4:GoLine(1)
				
				if !lRet
					
					Help(,,'Help',,"Produto Selecionado não está contido nos produtos do plano alterado do contrato!",1,0)
					
				endif
				
			else
				
				//verifico se o item selecionado esta contido na grid de produtos alterados do plano
				For nX := 1 To  oModelUH3:Length()
		
					oModelUH3:GoLine(nX)
		
					if oModelUH3:GetValue("UH3_PRODUT") == cProduto
					
						nVlrAdd := oModelUH6:GetValue("UH6_VLRTOT")
						
						oModelUH6:LoadValue("UH6_TIPO"		, oModelUH3:GetValue("UH3_TIPO") )
						oModelUH6:LoadValue("UH6_QUANT"		, oModelUH3:GetValue("UH3_QUANT") )
						oModelUH6:LoadValue("UH6_SALDO"		, oModelUH3:GetValue("UH3_SALDO") )
						oModelUH6:LoadValue("UH6_VLRTOT"	, oModelUH3:GetValue("UH3_VLRTOT"))
						oModelUH6:LoadValue("UH6_DESCRI"	, oModelUH3:GetValue("UH3_DESCRI") ) 
						oModelUH6:LoadValue("UH6_VLRUNI"	, oModelUH3:GetValue("UH3_VLRUNI") ) 
						oModelUH6:LoadValue("UH6_CTRSLD"	, oModelUH3:GetValue("UH3_CTRSLD") ) 
						
						lRet := .T.
						
						Exit
						
					endif
			
				Next nX 
	
				oModelUH3:GoLine(1)
				
				if !lRet
					
					Help(,,'Help',,"Produto Selecionado não está contido nos produtos atuais do plano!",1,0)
					
				endif
				
			
			endif
		
		else
			
			lRet := .F.
			Help(,,'Help',,"Produto Selecionado está contido nos produtos excluídos do contrato, favor selecione outro produto!",1,0)
			
		endif
			
		
	else
		
		lRet := .F.
		Help(,,'Help',,"Produto não encontrado no cadastro de produtos!",1,0)	
		
	endif
	
else
	
	//valor a ser debitado, antes da inclusao do proximo item
	nVlrDeb := oModelUH6:GetValue("UH6_VLRTOT")
	
	if oModelUH6:GetValue("UH6_VLRTOT") > 0 
	
		nVlrAdd := oModelUH6:GetValue("UH6_VLRTOT")
		
	endif
			
	oModelUH6:LoadValue("UH6_TIPO"		, "" )
	oModelUH6:LoadValue("UH6_QUANT"		, 0	 )
	oModelUH6:LoadValue("UH6_SALDO"		, 0  )
	oModelUH6:LoadValue("UH6_VLRTOT"	, 0  )
	oModelUH6:LoadValue("UH6_DESCRI"	, "" ) 
	oModelUH6:LoadValue("UH6_VLRUNI"	, 0  ) 
	oModelUH6:LoadValue("UH6_CTRSLD"	, "" ) 
				
endif

if lRet 
	
	oResumoTotal:RefreshTot() 
	 
	//restauro as linhas posicionadas
	FWRestRows( aSaveLines )

endif

RestArea(aArea)
RestArea(aAreaSB1)
RestArea(aAreaUH6)

Return(lRet)

/*/{Protheus.doc} RFUNE29C
//TODO Funcao para validar o produto digitado na grid
de Exclusao na tela de personalizacao de planos
@author Raphael Martins
@since 13/08/2018
@version 1.0
@return lRet			- Produto Validado
@type function
/*/

User Function RFUNE29D()

Local aArea			:= GetArea()
Local aAreaSB1		:= SB1->(GetArea())
Local aSaveLines	:= FWSaveRows() 
Local oModel		:= FWModelActive()     
Local oView			:= FWViewActive()
Local oModelUH2		:= oModel:GetModel("UH2MASTER") 
Local oModelUH3		:= oModel:GetModel("UH3DETAIL") 
Local oModelUH4		:= oModel:GetModel("UH4DETAIL") 
Local oModelUH5		:= oModel:GetModel("UH5DETAIL")
Local oModelUH6		:= oModel:GetModel("UH6DETAIL")
Local oModelUH7		:= oModel:GetModel("UH7DETAIL")
Local cPlanoSel		:= oModelUH2:GetValue("UH2_PLANNO")
Local cProduto		:= oModelUH7:GetValue("UH7_PRODUT")
Local cPlano		:= UF2->UF2_PLANO
Local lRet			:= .F.
Local nValorItem	:= 0 
Local nX			:= 1

//valido se o produto existe no cadastro de produtos
SB1->(DBSetOrder(1)) //B1_FILIAL + B1_COD

if !Empty(cProduto)
	 
	if SB1->(DbSeek(xFilial("SB1")+cProduto))
		
		//valido se o item digitado esta contido na grid de alteracao 
		if IPrdPlan("UH6DETAIL","UH6_PRODUT",cProduto)
				
			//retorno as linhas excluidas da grid de exclusao de servicos
			nQtdExc 	:= ContLinExc(oModelUH7)
			
				
			if !Empty(cPlanoSel)
				
				nExcOrig	:= ContLinExc(oModelUH4)
				
				//nao autoriza excluir todos os itens 
				if ((oModelUH4:Length() - nExcOrig) > ( oModelUH7:Length() - nQtdExc ) ) .Or. ExistInc(oModelUH5,"UH5_PRODUT") 	

					//verifico se o item selecionado esta contido na grid de produtos alterados do plano
					For nX := 1 To  oModelUH4:Length()
		
						oModelUH4:GoLine(nX)
		
						if oModelUH4:GetValue("UH4_PRODUT") == cProduto
			
							oModelUH7:LoadValue("UH7_TIPO"		, oModelUH4:GetValue("UH4_TIPO") )
							oModelUH7:LoadValue("UH7_QUANT"		, oModelUH4:GetValue("UH4_QUANT") )
							oModelUH7:LoadValue("UH7_SALDO"		, oModelUH4:GetValue("UH4_SALDO") )
							oModelUH7:LoadValue("UH7_VLRTOT"	, oModelUH4:GetValue("UH4_VLRTOT"))
							oModelUH7:LoadValue("UH7_DESCRI"	, oModelUH4:GetValue("UH4_DESCRI") ) 
							oModelUH7:LoadValue("UH7_VLRUNI"	, oModelUH4:GetValue("UH4_VLRUNI") ) 
							oModelUH7:LoadValue("UH7_CTRSLD"	, oModelUH4:GetValue("UH4_CTRSLD") ) 
						
							nValorItem := oModelUH7:GetValue("UH7_VLRTOT")
							lRet := .T.
						
							Exit
					
						
						endif
			
					Next nX 
	
					oModelUH4:GoLine(1)
				
					if !lRet
					
						Help(,,'Help',,"Produto Selecionado não está contido nos produtos do plano alterado do contrato!",1,0)
					
					endif
					
				else
					lRet := .F.
					Help(,,'Help',,"Não é permitido excluir todos os produtos do contrato!",1,0)
				endif
				
			else
				
				nExcOrig	:= ContLinExc(oModelUH3)
				
				//nao autoriza excluir todos os itens 
				if (oModelUH3:Length() > ( oModelUH7:Length() - nQtdExc ) ) .Or. ExistInc(oModelUH5,"UH5_PRODUT") 
				
					//verifico se o item selecionado esta contido na grid de produtos alterados do plano
					For nX := 1 To  oModelUH3:Length()
			
						oModelUH3:GoLine(nX)
			
						if oModelUH3:GetValue("UH3_PRODUT") == cProduto
				
							oModelUH7:LoadValue("UH7_TIPO"		, oModelUH3:GetValue("UH3_TIPO") )
							oModelUH7:LoadValue("UH7_QUANT"		, oModelUH3:GetValue("UH3_QUANT") )
							oModelUH7:LoadValue("UH7_SALDO"		, oModelUH3:GetValue("UH3_SALDO") )
							oModelUH7:LoadValue("UH7_VLRTOT"	, oModelUH3:GetValue("UH3_VLRTOT"))
							oModelUH7:LoadValue("UH7_DESCRI"	, oModelUH3:GetValue("UH3_DESCRI") ) 
							oModelUH7:LoadValue("UH7_VLRUNI"	, oModelUH3:GetValue("UH3_VLRUNI") ) 
							oModelUH7:LoadValue("UH7_CTRSLD"	, oModelUH3:GetValue("UH3_CTRSLD") ) 
							
							nValorItem := oModelUH7:GetValue("UH7_VLRTOT")
							
							lRet := .T.
							
							Exit
							
						endif
				
					Next nX 
		
					oModelUH3:GoLine(1)
					
					if !lRet
						
						Help(,,'Help',,"Produto Selecionado não está contido nos produtos atuais do plano!",1,0)
						
					endif
				
				else
					lRet := .F.
					Help(,,'Help',,"Não é permitido excluir todos os produtos do contrato!",1,0)
				endif
				
			endif
			
			
		else
			
			lRet := .F.
			Help(,,'Help',,"O Produto digitado está contido na Grid de Alteração de produtos, favor selecione outro produto!",1,0)	
			
		endif
	
	else
		
		lRet := .F.
		Help(,,'Help',,"Produto não encontrado no cadastro de produtos!",1,0)	
		
	endif
	
else
	
	oModelUH7:LoadValue("UH7_TIPO"		, "" )
	oModelUH7:LoadValue("UH7_QUANT"		, 0	 )
	oModelUH7:LoadValue("UH7_SALDO"		, 0  )
	oModelUH7:LoadValue("UH7_VLRTOT"	, 0  )
	oModelUH7:LoadValue("UH7_DESCRI"	, "" ) 
	oModelUH7:LoadValue("UH7_VLRUNI"	, 0  ) 
	oModelUH7:LoadValue("UH7_CTRSLD"	, "" ) 
				
endif

if lRet 
	
	//atualizo o totalizador da tela 
	oResumoTotal:RefreshTot() 
	
	//restauro as linhas posicionadas
	FWRestRows( aSaveLines )

endif

RestArea(aArea)
RestArea(aAreaSB1)

Return(lRet)

/*/{Protheus.doc} ExistInc
Funcao para verificar se possivel 
inclusao de produto ou servico
do contrato
@author Raphael Martins
@since 13/08/2018
@version 1.0
@return lRet			- Servico Validado
@type function
/*/
Static Function ExistInc(oModelGrid,cCampoProd)

Local aSaveLines    := FWSaveRows() 
Local lRet			:= .F.
Local nX			:= 0 

For nX := 1 To oModelGrid:Length()
	
	oModelGrid:GoLine(nX)
	
	//verifico se possui produtos ou servicos inclusos 
	if !oModelGrid:isDeleted() .And. !Empty(oModelGrid:GetValue(cCampoProd))
	
		lRet := .T.
		Exit 
		
	endif
	
Next nX

//reposiciono linhas 
oModelGrid:GoLine(1)
FWRestRows( aSaveLines ) 

Return(lRet)

/*/{Protheus.doc} CPGE021D
Funcao para calcular o saldo e o 
valor toda da grid de alteração.
@author Raphael Martins 
@since 14/08/2018
@version P12
/*/
User Function RFUNE29E(cModelGrid,cCpoSaldo,cCpoQuant,cCpoVlrUni,cCpoVlrTot,nPosView)

Local oModel		:= FWModelActive() 
Local oView			:= FWViewActive() 
Local oModelGrid	:= oModel:GetModel(cModelGrid) 
Local nLinAtu		:= oModelGrid:nLine
Local nPosQuant		:= 0 
Local nPosVlr		:= 0 
Local nSaLdo		:= 0 
Local nSldQuant		:= 0 
Local nQuantAnt		:= 0 
Local lRet			:= .T.

//pego a posicao da quantidade no array aFieldid da View 
nPosQuant := aScan( oView:aViews[nPosView][3]:aFieldid,{|x| AllTrim(x)== cCpoQuant})

//pego a quantidade anterior a alteracao realizada	                                 
nQuantAnt := oView:aViews[nPosView][3]:oBrowse:oData:oFormGrid:oBrowse:oData:aShow[nLinAtu][nPosQuant]

//diferenca entre a quantidade digitada e o valor anterior
nSldQuant := oModelGrid:GetValue(cCpoQuant) -  nQuantAnt

nSaldo := oModelGrid:GetValue(cCpoSaldo) +  nSldQuant

//nao permito saldo negativo
if nSaldo >= 0
	
	oModelGrid:LoadValue(cCpoVlrTot,oModelGrid:GetValue(cCpoQuant) * oModelGrid:GetValue(cCpoVlrUni)) 
	oModelGrid:LoadValue(cCpoSaldo,nSaldo) 
	
	//atualizo o totalizador da tela 
	oResumoTotal:RefreshTot()
	
	
else
	lRet := .F.
	Help(,,'Help',,"Saldo do produto não pode ser negativo!",1,0)
endif


Return(lRet)

/*/{Protheus.doc} EditGrid
Funcao na delecao ou restauracao das
grids de personalizacao
do contrato
@author Raphael Martins
@since 13/08/2018
@version 1.0
@return lRet			- Servico Validado
@type function
/*/
Static Function EditGrid(oModelGrid,nLinha,cAcao,cCampo,cCampoTot)
Local oModel		:= FWModelActive()
Local oModelUH2		:= oModel:GetModel("UH2MASTER") 
Local oModelUH3		:= oModel:GetModel("UH3DETAIL")
Local oModelUH4		:= oModel:GetModel("UH4DETAIL")
Local oModelUH6		:= oModel:GetModel("UH6DETAIL")
Local oView			:= FWViewActive()
Local aSaveLines    := FWSaveRows()
Local aModelOrig	:= {}
Local aModelAlt		:= {} 
Local nDiferenca	:= 0
Local lRet			:= .T. 
Local cModelProd 	:= ""
Local cCampoProd 	:= ""
Local nX			:= 1					

if cAcao == 'UNDELETE'
	
	lRet := .F.
	Help(,,'Help',,"Ação não permitida, favor inclua uma nova linha!",1,0)
	
elseif cAcao == 'DELETE' .And. !IsInCallStack("U_RFUNE29A")

	///verifico a permissao para excluir a linha de inclusao de produtos e servicos
	if oModelGrid:cId == "UH5DETAIL"
				
		if Empty(oModelUH2:GetValue("UH2_PLANNO"))
					
			cModelProd := "UH3DETAIL"
			cCampoProd := "UH3_PRODUT"
			
		else
					
			cModelProd := "UH4DETAIL"
			cCampoProd := "UH4_PRODUT"
					
		endif
				
		lRet := PermitExLin("UH5DETAIL","UH5_PRODUT","UH7DETAIL","UH7_PRODUT",cModelProd,cCampoProd)
		
		//atualizo o valor total 
		if lRet 
			
			oResumoTot:RefreshTot()
			
			
		endif
		
	//grid de alteracao
	elseif oModelGrid:cId == "UH6DETAIL" 
	
		if Empty(oModelUH2:GetValue("UH2_PLANNO"))
			aModelOrig	:= {oModelUH3,"UH3_PRODUT","UH3_VLRTOT"} 
		else
			aModelOrig	:= {oModelUH4,"UH4_PRODUT","UH4_VLRTOT"} 
		endif
	
		//verifico se foi alterado o plano, verifico o item deletado na tabela 
		For nX := 1 To aModelOrig[1]:Length()
			
			aModelOrig[1]:GoLine(nX)
			
			if !aModelOrig[1]:isDeleted()
			
				if oModelUH6:GetValue("UH6_PRODUT") == aModelOrig[1]:GetValue(aModelOrig[2])
					
					nDiferenca := oModelUH6:GetValue("UH6_VLRTOT") - aModelOrig[1]:GetValue(aModelOrig[3]) 
					
					if nDiferenca > 0 
						
						oResumoTot:RefreshTot(nDiferenca,.F.)
						
					else
							
						oResumoTot:RefreshTot(Abs(nDiferenca),.T.)
							
					endif
					
					Exit 
					
				endif
			
			endif
			
		Next nX
		
		
	//grid de exclusao
	else
	
		oResumoTot:RefreshTot(oModelGrid:GetValue(cCampoTot),.T.)
	
	endif
		
	
	FWRestRows( aSaveLines ) 
	
	oView:Refresh()
	
endif


Return(lRet)

/*/{Protheus.doc} PermitExLin
Funcao para permitir ou nao 
a delecao da linha de inclusao de
produtos e servicos 
do contrato
@author Raphael Martins
@since 13/08/2018
@version 1.0
@return lRet - Continua ou nao a Operacao
@type function
/*/ 
Static Function PermitExLin(cModelInc,cCampoInc,cModelExc,cCampoExc,cModelProd,cCampoProd)

Local oModel		:= FWModelActive()
Local oModelUH2		:= oModel:GetModel("UH2MASTER") 
Local oModelInc		:= oModel:GetModel(cModelInc) 
Local oModelExc		:= oModel:GetModel(cModelExc) 
Local oModelProd	:= oModel:GetModel(cModelProd) 
Local nLinInc		:= oModelInc:GetLine()

Local oView			:= FWViewActive()
Local aSaveLines    := FWSaveRows()
Local nX			:= 0
Local nLinhasExc	:= 0 
Local nLinhasInc	:= 0
Local nLinhasProd	:= 0
Local lRet			:= .T.

	
//verifico quantas linhas excluidas possui
For nX := 1 To oModelExc:Length()
	
	oModelExc:GoLine(nX)
	
	if !oModelExc:IsDeleted() .And. !Empty(oModelExc:GetValue(cCampoExc)) 
		
		nLinhasExc++
		
	endif
	
Next nX

//verifico quantas linhas Inclusas possui
For nX := 1 To oModelInc:Length()
	
	oModelInc:GoLine(nX)
	
	if !oModelInc:IsDeleted() .And. !Empty(oModelInc:GetValue(cCampoInc))  
		
		nLinhasInc++
		
	endif
	
Next nX

	
//verifico quantas linhas possui o plano atual do contrato
For nX := 1 To oModelProd:Length()
	
	oModelProd:GoLine(nX)

	if !oModelProd:IsDeleted() .And. !Empty(oModelProd:GetValue(cCampoProd)) 
	
		nLinhasProd++
	
	endif
	
Next nX

if (nLinhasProd + nLinhasInc - 1) <= nLinhasExc
	
	lRet := .F.
	Help(,,'Help',,"Não é permitido excluir todos os produtos ou Servicos do contrato!",1,0)
	
endif

//reposiciono linhas 
oModelInc:GoLine(nLinInc)


FWRestRows( aSaveLines ) 

Return(lRet)

/*/{Protheus.doc} ContLinExc
Funcao para contar as linhas deletadas

do contrato
@author Raphael Martins
@since 13/08/2018
@version 1.0
@return lRet - Continua ou nao a Operacao
@type function
/*/ 
Static Function ContLinExc(oModelGrid)

Local nLinExc		:= 0 
Local nX			:= 0 
Local aSaveLines    := FWSaveRows()

For nX := 1 To oModelGrid:Length()
	
	oModelGrid:GoLine(nX)
	
	if oModelGrid:isDeleted()
		
		nLinExc++
		
	endif
	

Next nX
 

FWRestRows( aSaveLines ) 

Return(nLinExc)

/*/{Protheus.doc} RFUNE29F
Funcao inicializador padrao
do campo UH2_DESTAB
@author Raphael Martins
@since 22/01/2018
@version 1.0
@type function
/*/ 
User Function RFUNE29F()

Local aArea		:= GetArea()
Local cRet		:= ""
Local oModel	:= FWModelActive()

if oModel:GetOperation() ==  MODEL_OPERATION_INSERT
	
	cRet := RetField("DA0",1,xFilial("DA0")+UF2->UF2_TABPRE,"DA0_DESCRI")

else

	cRet := RetField("DA0",1,xFilial("DA0")+UH2->UH2_TABPRE,"DA0_DESCRI")
	
endif

RestArea(aArea)

Return(cRet)

