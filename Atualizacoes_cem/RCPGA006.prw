#include "protheus.ch"
#include "fwmvcdef.ch"
#include "topconn.ch"


/*/{Protheus.doc} RCPGA006
Composição de Produtos
(Antiga cadastro de Planos)
@type function
@version 1.0
@author g.sampaio
@since 25/02/2016
/*/
User Function RCPGA006()

	Local oBrowse

	Private aRotina := {}

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias("U05")
	oBrowse:SetDescription("Composição de Produto")
	oBrowse:AddLegend("U05_SITUAC == 'A'", "GREEN",	"Ativo")
	oBrowse:AddLegend("U05_SITUAC == 'I'", "RED",	"Inativo")
	oBrowse:Activate()

Return(Nil)

/*/{Protheus.doc} MenuDef
menu de rotinas 
@type function
@version 1.0
@author g.sampaio
@since 06/05/2021
@return array, rotina do menu outras ações
/*/
Static Function MenuDef()

	Private aRotina 	:= {}

	ADD OPTION aRotina Title "Visualizar" 				Action "VIEWDEF.RCPGA006"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Incluir"    				Action "VIEWDEF.RCPGA006"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title "Alterar"    				Action "VIEWDEF.RCPGA006"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Excluir"    				Action "VIEWDEF.RCPGA006"	OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title "Copiar"    				Action "VIEWDEF.RCPGA006"	OPERATION 9 ACCESS 0
	ADD OPTION aRotina Title "Legenda"     				Action "U_CPGA006L()" 		OPERATION 6 ACCESS 0
	ADD OPTION aRotina Title "Banco de Conhecimento"	Action "MSDOCUMENT"			OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Atualiza Contratos"		Action "U_RCPGE038()"	    OPERATION 8 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
função que criar a camada de manipulação dos dados(model)
@type function
@version 1.0
@author g.sampaio
@since 06/05/2021
@return object, modelo de dados
/*/
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruU05 := FWFormStruct(1,"U05",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruU06 := FWFormStruct(1,"U06",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruU36 := FWFormStruct(1,"U36",/*bAvalCampo*/,/*lViewUsado*/ )

	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("PCPGA006",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("U05MASTER",/*cOwner*/,oStruU05)

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({"U05_FILIAL","U05_CODIGO"})

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid("U06DETAIL","U05MASTER",oStruU06,/*bLinePre*/{|oMdlG,nLine,cAcao,cCampo| EditGrid(oMdlG,nLine,cAcao,cCampo)},/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)
	oModel:AddGrid("U36DETAIL","U05MASTER",oStruU36,/*bLinePre*/{|oMdlG,nLine,cAcao,cCampo| EditGrid(oMdlG,nLine,cAcao,cCampo)},/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation("U06DETAIL", {{"U06_FILIAL", 'xFilial("U06")'},{"U06_CODIGO","U05_CODIGO"}},U06->(IndexKey(1)))
	oModel:SetRelation("U36DETAIL", {{"U36_FILIAL", 'xFilial("U36")'},{"U36_CODIGO","U05_CODIGO"}},U36->(IndexKey(1)))

	// Desobriga a digitacao de ao menos um item
	//oModel:GetModel("SE1DETAIL"):SetOptional(.T.)

	// Liga o controle de nao repeticao de linha
	oModel:GetModel("U06DETAIL"):SetUniqueLine({"U06_PRODUT"})
	oModel:GetModel("U36DETAIL"):SetUniqueLine({"U36_SERVIC"})

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("U05MASTER"):SetDescription("Tipo de Plano")
	oModel:GetModel("U06DETAIL"):SetDescription("Itens")
	oModel:GetModel("U36DETAIL"):SetDescription("Serviços Habilitados")

Return(oModel)

/*/{Protheus.doc} ViewDef
Monta a camada de interação com o usuario(view)
@type function
@version 1.0 
@author g.sampaio
@since 06/05/2021
@return object, retorno o objeto view
/*/
Static Function ViewDef()

	// Cria a estrutura a ser usada na View
	Local oStruU05 := FWFormStruct(2,"U05")
	Local oStruU06 := FWFormStruct(2,"U06")
	Local oStruU36 := FWFormStruct(2,"U36")

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel("RCPGA006")
	Local oView

	// Remove campos da estrutura
	oStruU06:RemoveField('U06_CODIGO')
	oStruU36:RemoveField('U36_CODIGO')

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField("VIEW_U05",oStruU05,"U05MASTER")

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid("VIEW_U06",oStruU06,"U06DETAIL")
	oView:AddGrid("VIEW_U36",oStruU36,"U36DETAIL")

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox("PAINEL_CABEC", 50)
	oView:CreateHorizontalBox("PAINEL_ITENS", 50)

	oView:CreateVerticalBox("PAINEL_ITENS_1", 60, "PAINEL_ITENS")
	oView:CreateVerticalBox("PAINEL_ITENS_2", 40, "PAINEL_ITENS")

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView("VIEW_U05","PAINEL_CABEC")
	oView:SetOwnerView("VIEW_U06","PAINEL_ITENS_1")
	oView:SetOwnerView("VIEW_U36","PAINEL_ITENS_2")

	// Liga a identificacao do componente
	oView:EnableTitleView("VIEW_U05","Tipo de Plano")
	oView:EnableTitleView("VIEW_U06","Produtos")
	oView:EnableTitleView("VIEW_U36","Serviços Habilitados")

	// Define campos que terao Auto Incremento
	oView:AddIncrementField("VIEW_U06","U06_ITEM")
	oView:AddIncrementField("VIEW_U36","U36_ITEM")

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk( {||.T.} )

Return(oView)

/*/{Protheus.doc} CPGA006L
Funcao para exibir as legendas do contrato
@type function
@version 1.0  
@author g.sampaio
@since 06/05/2021
/*/
User Function CPGA006L()

	BrwLegenda("Status do Tipo de Plano","Legenda",{{"BR_VERDE","Ativo"},{"BR_VERMELHO","Inativo"}})

Return(Nil)
/*/{Protheus.doc} EditGrid
Funcao para validacao da Grid
@type function
@version 1.0  
@author g.sampaio
@since 06/05/2021
@param oModelGrid, object, modelo de dados da grid
@param nLinha, numeric, numero da linha
@param cAcao, character, acao feita na linha
@param cCampo, character, campo 
@return logical, retorno
/*/
Static Function EditGrid(oModelGrid, nLinha, cAcao, cCampo)

	Local aArea         := GetArea()
	Local aAreaSB1      := SB1->(GetArea())
	Local aSaveLines    := FWSaveRows()
	Local cCodProduto   := "" // variavel do codigo da composicao de produtos
	Local cTabPreco     := ""
	Local lRetorno      := .T.	
	Local nValProduto   := 0
	Local oModel	    := FwModelActive()	
	Local oModelU05	    := oModel:GetModel("U05MASTER")
	Local nLinhaAtual	:= oModelGrid:GetLine()

	// grid de produtos da composicao do produto
	if oModelGrid:cId == "U06DETAIL"

		cCodProduto := oModelU05:GetValue("U05_CODIGO")
		cTabPreco   := oModelU05:GetValue("U05_TABPRE")

		// atualizo o valor do produto independente da acao
		nValProduto := U_CPGA006A(cCodProduto, cTabPreco, oModelGrid)

		oModelU05:LoadValue("U05_VLRPRO", nValProduto)

	endIf

	oModelGrid:GoLine( nLinhaAtual )
	FWRestRows( aSaveLines )

	RestArea(aAreaSB1)
	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} CPGA006A
Funcao para retornar o valor atualizado
@type function
@version 1.0
@author g.sampaio
@since 06/05/2021
@param cProdutoCem, character, codigo da composicao de produto
@param cTabelaPreco, character, codigo da tabela de preco
@param oModelProdutos, object, modelo de dados
@return numeric, retorna o valor atualizado da composicao de produtos
/*/
User Function CPGA006A(cProdutoCem, cTabelaPreco, oModelProdutos)

	Local aSaveLines  		:= {}
	Local cProduto      	:= ""
	Local cCampoProduto   	:= ""
	Local cCampoQuantidade	:= ""
	Local cQuery 			:= ""
	Local nRetorno      	:= 0
	Local nLinha        	:= 0
	Local nValProduto   	:= 0
	Local nQuantidade   	:= 0
	Local nLinhaAtual		:= 0

	Default cProdutoCem     := ""
	Default cTabelaPreco    := ""
	Default oModelProdutos  := Nil

	// verifico se o modelo de dados tem dados
	if ValType(oModelProdutos) <> "U"

		if oModelProdutos:cId == "U06DETAIL"

			aSaveLines			:= FWSaveRows()
			cCampoProduto       := "U06_PRODUT"
			cCampoQuantidade    := "U06_QUANT"
			nLinhaAtual			:= oModelProdutos:GetLine()

		endIf

		//Grid de Produtos Habilitados
		For nLinha := 1 To oModelProdutos:Length()

			oModelProdutos:GoLine(nLinha)

			if !oModelProdutos:IsDeleted()

				cProduto    := oModelProdutos:GetValue( cCampoProduto )
				nQuantidade := oModelProdutos:GetValue( cCampoQuantidade )

				nValProduto := U_RetPrecoVenda(cTabelaPreco, cProduto)

				// alimento a variavel com o retorno do valor total do produto
				nRetorno += nQuantidade * nValProduto

			endif

		Next nLinha

		oModelProdutos:GoLine( nLinhaAtual )
		FWRestRows( aSaveLines )

	elseIf !Empty(cProdutoCem) // verifico se o codigo do protudo de cemiterio esta preenchido

		if Select("TRBVAL") > 0
			TRBVAL->(DBCloseArea())
		endIf

		cQuery := " SELECT U06.U06_PRODUT PRODUTO, "
		cQuery += " U06.U06_QUANT QUANTIDADE, "
		cQuery += " DA1.DA1_PRCVEN VALOR_TABLEA "
		cQuery += " FROM " + RetSqlName("U05") + " U05 "
		cQuery += " INNER JOIN " + RetSqlName("U06") + " U06 ON U06.D_E_L_E_T_ = ' ' "
		cQuery += " AND U06.U06_FILIAL = '" + xFilial("U06") + "' "
		cQuery += " AND U06.U06_CODIGO = U05.U05_CODIGO"
		cQuery += " INNER JOIN " + RetSqlName("DA1") + " DA1 ON DA1.D_E_L_E_T_ = ' ' "
		cQuery += " AND DA1.DA1_FILIAL = '" + xFilial("DA1") + "' "
		cQuery += " AND DA1.DA1_CODTAB = U05.U05_TABPRE "
		cQuery += " AND DA1.DA1_CODPRO = U06.U06_PRODUT "
		cQuery += " WHERE U05.D_E_L_E_T_ = ' '"
		cQuery += " AND U05.U05_FILIAL = '" + xFilial("U05") + "'"
		cQuery += " AND U05.U05_CODIGO = '" + cProdutoCem + "' "

		TcQuery cQuery New Alias "TRBVAL"

		while TRBVAL->(!Eof())
			nRetorno += (TRBVAL->QUANTIDADE * TRBVAL->VALOR_TABLEA)
			TRBVAL->(DBSkip())
		endDo

		if Select("TRBVAL") > 0
			TRBVAL->(DBCloseArea())
		endIf

	endIf

Return(nRetorno)

/*/{Protheus.doc} U06FastFilterSB1
Funcao para filtro rapido da
consulta padao SB1U06
@type function
@version 1.0  
@author g.sampaio
@since 07/05/2021
@return character, retorno do filtro
/*/
User Function U06FastFilterSB1()
	Local cRetorno := ""

	cRetorno := "@#"
	cRetorno += "SB1->(B1_XTPCEM $ '1/3/4')"
	cRetorno += "@#"

Return(cRetorno)

/*/{Protheus.doc} U36FastFilterSB1
Funcao para filtro rapido da
consulta padao SB1U36
@type function
@version 1.0
@author g.sampaio
@since 07/05/2021
@return character, retorno do filtro
/*/
User Function U36FastFilterSB1()
	Local cRetorno := ""

	cRetorno := "@#"
	cRetorno += "SB1->(B1_XTPCEM == '2' .And. B1_TIPO = 'SV')"
	cRetorno += "@#"

Return(cRetorno)

/*/{Protheus.doc} CPGA006B
funcao para atualizar o valor conforme o preenchido 
na tabela de preco
@type function
@version 1.0 
@author g.sampaio
@since 19/05/2021
@return numeric, retorno o valor atualizado do contrato
/*/
User Function CPGA006B()

	Local aArea         := GetArea()
	Local aSaveLines    := FWSaveRows()
	Local cCodProduto   := "" // variavel do codigo da composicao de produtos
	Local cTabPreco     := ""
	Local cProduto      := ""
	Local nRetorno      := 0
	Local nValPreco     := 0
	Local nI			:= 0
	Local oModel	    := FwModelActive()
	Local oView			:= FwViewActive()
	Local oModelU05	    := oModel:GetModel("U05MASTER")
	Local oModelU06	    := oModel:GetModel("U06DETAIL")
	Local nLinhaAtual	:= oModelU06:GetLine()

	// grid de produtos da composicao do produto
	if oModelU06 <> Nil

		cCodProduto := oModelU05:GetValue("U05_CODIGO")
		cTabPreco   := oModelU05:GetValue("U05_TABPRE")

		For nI := 1 to oModelU06:Length()

			oModelU06:GoLine(nI)

			cProduto    := oModelU06:GetValue("U06_PRODUT")

			if !Empty(cProduto)

				if !Empty(cTabPreco) .And. !Empty(cProduto)

					// busco o preco do produto na tabela de preco
					nValPreco := U_RetPrecoVenda(cTabPreco, cProduto, .F.)

					// preencho o preco do produto
					oModelU06:LoadValue("U06_PRCVEN", nValPreco)
					oModelU06:LoadValue("U06_VALOR ", oModelU06:GetValue("U06_QUANT") * nValPreco)

				endIf

			endIf

		next nI

		oModelU06:GoLine(nLinhaAtual)

		// atualizo o valor do produto independente da acao
		nRetorno := U_CPGA006A(cCodProduto, cTabPreco, oModelU06)

		oView:Refresh("U06DETAIL")
		FWRestRows( aSaveLines )

	endIf

	RestArea(aArea)

Return(nRetorno)

/*/{Protheus.doc} CPGA006C
Validacao do campo U06_PRODUT 
@type function
@version 1.0 
@author g.sampaio
@since 20/05/2021
@return logical, retorno para validacao do campo
/*/
User Function CPGA006C()

	Local cCodProduto   := "" // variavel do codigo da composicao de produtos
	Local cTabPreco     := ""
	Local cProduto      := ""
	Local lRetorno		:= .T.
	Local nValProduto   := 0
	Local nValPreco     := 0
	Local oModel	    := FWModelActive()
	Local oModelU05	    := oModel:GetModel("U05MASTER")
	Local oModelU06	    := oModel:GetModel("U06DETAIL")

	cCodProduto := oModelU05:GetValue("U05_CODIGO")
	cTabPreco   := oModelU05:GetValue("U05_TABPRE")
	cProduto    := oModelU06:GetValue("U06_PRODUT")

	if !Empty(cProduto)

		SB1->(DBSetOrder(1))
		if SB1->(MsSeek(xFilial("SB1")+cProduto))

			SB1->(DBSetOrder(1))
			if SB1->(MsSeek(xFilial("SB1")+cProduto))

				// valido se esta preenchido e nao e servico
				if Empty(SB1->B1_XTPCEM) .Or. SB1->B1_XTPCEM == "2"
					lRetorno := .F.
					Help(,,'Help - PRODUTO',,"O Serviço " + SB1->B1_DESC + " não pode ser utilizado na grid de itens da composição de produtos!",1,0)
				endIf

			endIf

			if lRetorno .And. !Empty(cTabPreco) .And. !Empty(cProduto)

				// busco o preco do produto na tabela de preco
				nValPreco := U_RetPrecoVenda(cTabPreco, cProduto)

				// preencho o preco do produto
				oModelU06:LoadValue("U06_PRCVEN", nValPreco)
				oModelU06:LoadValue("U06_VALOR ", oModelU06:GetValue("U06_QUANT") * nValPreco)

				if nValPreco == 0 .And. !(SB1->B1_XTPCEM $ "1/3/4" .And. SB1->B1_XLOCACA == 'S')
					lRetorno := .F.
				endIf

			endIf

		endIf

		if lRetorno

			// atualizo o valor do produto independente da acao
			nValProduto := U_CPGA006A(cCodProduto, cTabPreco, oModelU06)

			oModelU05:LoadValue("U05_VLRPRO", nValProduto)

		endIf

	endIf

Return(lRetorno)

/*/{Protheus.doc} CPGA006D
Validacao do campo U36_SERVIC
@type function
@version 1.0
@author g.sampaio
@since 21/05/2021
@return logical, retorno sobre a validacao
/*/
User Function CPGA006D()

	Local aArea 		:= GetArea()
	Local aAreaSB1		:= SB1->(GetArea())
	Local cServico      := ""
	Local lRetorno		:= .T.
	Local oModel	    := FWModelActive()
	Local oModelU36	    := oModel:GetModel("U36DETAIL")

	cServico := oModelU36:GetValue("U36_SERVIC")

	SB1->(DBSetOrder(1))
	if SB1->(MsSeek(xFilial("SB1")+cServico))

		// valido se esta preenchido e nao e servico
		if Empty(SB1->B1_XTPCEM) .Or. SB1->B1_XTPCEM $ "1/3/4"
			lRetorno := .F.
			Help(,,'Help - SERVICO',,"O Produto " + SB1->B1_DESC + " não pode ser utilizado na grid de serviços da composição de produtos!",1,0)
		endIf

	endIf

	RestArea(aAreaSB1)
	RestArea(aArea)

Return(lRetorno)
