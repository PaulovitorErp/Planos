#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RUTIL026
Cadastro de integracao de empresas
@type function
@version 1.0
@author g.sampaio
@since 22/07/2021
/*/
User Function RUTIL026()

	Local oBrowse	:= Nil
	Local lIntEmp	:= SuperGetMV("MV_XINTEMP", .F., .F.) // habilito o uso da integracao de empresas

	if lIntEmp

		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias( 'UZ4' )
		oBrowse:SetDescription( 'Integração de Empresas' )
		oBrowse:Activate()

	else
		MsgAlert("Integração de empresas não habilitada para este Grupo de Empresas!", "Integração de Empresas")
	endIf

Return(Nil)

/*/{Protheus.doc} MenuDef
monta o menu da rotina
@type function
@version 1.0
@author g.sampaio
@since 22/07/2021
@return array, rotinas de menu
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.RUTIL026' OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.RUTIL026' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.RUTIL026' OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.RUTIL026' OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'   Action 'VIEWDEF.RUTIL026' OPERATION 8 ACCESS 0
	ADD OPTION aRotina Title 'Copiar'     Action 'VIEWDEF.RUTIL026' OPERATION 9 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
funcao do modelo de dados
@type function
@version 1.0
@author g.sampaio
@since 22/07/2021
@return object, objeto do modelo de dados
/*/
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruUZ4 := FWFormStruct( 1, 'UZ4', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruUZ5 := FWFormStruct( 1, 'UZ5', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruUZ6 := FWFormStruct( 1, 'UZ6', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PUTIL026', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de fADormulário de edição por campo
	oModel:AddFields( 'UZ4MASTER', /*cOwner*/, oStruUZ4 )

	// defino a chave primaria do boleto de dados
	oModel:SetPrimaryKey({"UZ4_FILIAL","UZ4_CODIGO"})

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'UZ5DETAIL', 'UZ4MASTER', oStruUZ5, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'UZ6DETAIL', 'UZ5DETAIL', oStruUZ6, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'UZ5DETAIL', { { 'UZ5_FILIAL', 'xFilial( "UZ5" )' }, { 'UZ5_CODIGO' , 'UZ4_CODIGO'  } } , UZ5->( IndexKey( 1 ) )  )
	oModel:SetRelation( 'UZ6DETAIL', { { 'UZ6_FILIAL', 'xFilial( "UZ6" )' }, { 'UZ6_CODIGO' , 'UZ4_CODIGO'  }, { 'UZ6_ITDES', 'UZ5_ITEM' } } , UZ6->( IndexKey( 1 ) )  )

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'UZ5DETAIL' ):SetUniqueLine( { 'UZ5_FILDES' } )
	oModel:GetModel( 'UZ6DETAIL' ):SetUniqueLine( { 'UZ6_SRVORI'  } )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Integração de Empresas' )

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'UZ4MASTER' ):SetDescription( 'Filial de Planos' )
	oModel:GetModel( 'UZ5DETAIL' ):SetDescription( 'Filiais de Cemitério'  )
	oModel:GetModel( 'UZ6DETAIL' ):SetDescription( 'Serviços vs Produto de Cemitério' )

Return(oModel)

/*/{Protheus.doc} ViewDef
View de dados
@type function
@version 1.0 
@author g.sampaio
@since 22/07/2021
@return object, objeto de view de dados
/*/
Static Function ViewDef()

	// Cria a estrutura a ser usada na View
	Local oStruUZ4 := FWFormStruct( 2, 'UZ4' )
	Local oStruUZ5 := FWFormStruct( 2, 'UZ5' )
	Local oStruUZ6 := FWFormStruct( 2, 'UZ6' )

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'RUTIL026' )
	Local oView

	// Remove campos da estrutura
	oStruUZ5:RemoveField('UZ5_CODIGO')
	oStruUZ6:RemoveField('UZ6_CODIGO')
	oStruUZ6:RemoveField('UZ6_ITDES')

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_UZ4', oStruUZ4, 'UZ4MASTER' )

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid(  'VIEW_UZ5', oStruUZ5, 'UZ5DETAIL' )
	oView:AddGrid(  'VIEW_UZ6', oStruUZ6, 'UZ6DETAIL' )

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'EMCIMA' , 20 )
	oView:CreateHorizontalBox( 'MEIO'   , 40 )
	oView:CreateHorizontalBox( 'EMBAIXO', 40 )

	// Criar "box" vertical para receber algum elemento da view
	//oView:CreateVerticalBox( 'EMBAIXOESQ', 80, 'EMBAIXO' )
	//oView:CreateVerticalBox( 'EMBAIXODIR', 20, 'EMBAIXO' )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_UZ4', 'EMCIMA'   )
	oView:SetOwnerView( 'VIEW_UZ5', 'MEIO'     )
	oView:SetOwnerView( 'VIEW_UZ6', 'EMBAIXO'  )
	//oView:SetOwnerView( 'VIEW_UZ6', 'EMBAIXOESQ'  )

	// Liga a identificacao do componente
	oView:EnableTitleView( 'VIEW_UZ4' )
	oView:EnableTitleView( 'VIEW_UZ5', "Filiais de Cemitério", RGB( 224, 30, 43 )  )
	oView:EnableTitleView( 'VIEW_UZ6', "Serviços vs Produto de Cemitério", 0 )

	// itens incrementais das grids de filiais de cemiterio e serviços vs produto de cemiterio
	oView:AddIncrementField("VIEW_UZ5","UZ5_ITEM")
	oView:AddIncrementField("VIEW_UZ6","UZ6_ITEM")

Return(oView)

/*/{Protheus.doc} UIntServico
Consulta Especifica para integracao de empresa
dos servicos executados (campo UZ6_SRVORI - SRVORI)
@type function
@version 1.0 
@author g.sampaio
@since 29/07/2021
@param cFilInt, character, filial de integracao
@return logical, retorno verdadeiro sobre 
/*/
User Function UIntServico(cFilInt)

	Local aBrwServProdutos 	:= {}
	Local bFiltro			:= Nil
	Local cGetServico 		:= Space(TamSX3("B1_COD")[1])
	Local oBtnFiltrar		:= Nil
	Local oBtnConfirmar		:= Nil
	Local oBtnFechar		:= Nil
	Local oBtnLimpar		:= Nil
	Local oGetServico		:= Nil
	Local oGrpFiltros		:= Nil
	Local oGrpPrdServ		:= Nil
	Local oSayServico		:= Nil
	Local oBrwServProdutos	:= Nil
	Local oDlgFiltro		:= Nil

	Static __cFilialServico	:= ""

	Default cFilInt			:= ""

	// defino o bloco de código
	bFiltro := {|| FiltraSB1(cFilInt, cGetServico, @aBrwServProdutos, @oBrwServProdutos, @oDlgFiltro) }

	// limpo a variavel estatica se ela estiver com conteudo
	if !Empty(__cFilialServico)
		__cFilialServico	:= ""
	endIf

	DEFINE MSDIALOG oDlgFiltro TITLE "Serviços/Produtos" FROM 000, 000  TO 450, 600 COLORS 0, 16777215 PIXEL

	// grupo de filtros
	@ 002, 004 GROUP oGrpFiltros TO 034, 300 PROMPT "Filtros" OF oDlgFiltro COLOR 0, 16777215 PIXEL

	@ 010, 015 SAY oSayServico PROMPT "Serviço" SIZE 025, 007 OF oDlgFiltro COLORS 0, 16777215 PIXEL
	@ 018, 014 MSGET oGetServico VAR cGetServico SIZE 180, 010 OF oDlgFiltro COLORS 0, 16777215 PIXEL VALID (iif(!Empty(cGetServico),Eval(bFiltro),.T.))

	@ 015, 205 BUTTON oBtnFiltrar PROMPT "Filtrar" SIZE 037, 012 OF oDlgFiltro PIXEL Action(Eval(bFiltro))
	@ 015, 245 BUTTON oBtnLimpar PROMPT "Limpar" SIZE 037, 012 OF oDlgFiltro PIXEL Action(cGetServico := "", Eval(bFiltro))

	// grupo de produtos e servicos
	@ 037, 004 GROUP oGrpPrdServ TO 195, 300 PROMPT "Produtos/Serviços" OF oDlgFiltro COLOR 0, 16777215 PIXEL
	BrwProdutoServico(cFilInt, cGetServico, @aBrwServProdutos, @oBrwServProdutos, @oDlgFiltro)

	@ 205, 245 BUTTON oBtnConfirmar PROMPT "Confirmar" SIZE 037, 012 OF oDlgFiltro PIXEL ACTION(__cFilialServico := aBrwServProdutos[oBrwServProdutos:nAT, 1], oDlgFiltro:End())
	@ 205, 205 BUTTON oBtnFechar PROMPT "Fechar" SIZE 037, 012 OF oDlgFiltro PIXEL ACTION(__cFilialServico := "", oDlgFiltro:End())

	ACTIVATE MSDIALOG oDlgFiltro CENTERED

Return(.T.)

/*/{Protheus.doc} RetServInt
retorno da consulta especifica de servicos
para integracao
@type function
@version 1.0
@author g.sampaio
@since 29/07/2021
@return character, retorna a variavel estatica
/*/
User Function RetServInt()
Return(__cFilialServico)

/*/{Protheus.doc} BrwProdutoServico
grid de produtos e servicos
@type function
@version 1.0
@author g.sampaio
@since 29/07/2021
@param cFilInt, character, filial de origem da integracao
@param cGetServico, character, codigo/descricao para consulta dos servicos
@param aBrwServProdutos, array, array de servicos/produtos
@param oBrwServProdutos, object, objeto do browse de servicos/produtos
@param oDlgFiltro, object, objeto de dialog do browse de servicos/produtos
/*/
Static Function BrwProdutoServico(cFilInt, cGetServico, aBrwServProdutos, oBrwServProdutos, oDlgFiltro)

	Local cQuery 	:= ""
	Local cAliasTab	:= ""

	// limpo o array de produtos
	aBrwServProdutos := {}

	cQuery := " SELECT SB1.B1_COD, SB1.B1_DESC, SB1.B1_TIPO FROM " + RetSqlName("SB1") + " SB1 "
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SB1.B1_FILIAL = '" + U_IntRetFilial("SB1", cFilInt) + "'"
	cQuery += " AND SB1.B1_MSBLQL = '2' " // produtos disponiveis

	if !Empty(cGetServico)
		cQuery += " AND (SB1.B1_COD LIKE '%" + AllTrim(cGetServico) + "%' OR SB1.B1_DESC LIKE '%" + AllTrim(cGetServico) + "%')"
	endIf

	cQuery += " ORDER BY SB1.B1_DESC ASC"

	cQuery := ChangeQueru(cQuery)

	MPSysOpenQuery(cQuery, "TRBSB1")

	if TRBSB1->(!Eof())
		While TRBSB1->(!Eof())
			Aadd(aBrwServProdutos,{TRBSB1->B1_COD, TRBSB1->B1_DESC, TRBSB1->B1_TIPO})

			TRBSB1->(DBSkip())
		endDo
	else
		Aadd(aBrwServProdutos,{"","",""})
	endIf

	If Select("TRBSB1") > 0
		TRBSB1->(DbCloseArea())
	EndIf

	@ 043, 007 LISTBOX oBrwServProdutos Fields HEADER "Codigo","Descrição","Tipo" SIZE 290, 143 OF oDlgFiltro PIXEL ColSizes 50, 200, 25
	oBrwServProdutos:SetArray(aBrwServProdutos)
	oBrwServProdutos:bLine := {|| {;
		aBrwServProdutos[oBrwServProdutos:nAt,1],;
		aBrwServProdutos[oBrwServProdutos:nAt,2],;
		aBrwServProdutos[oBrwServProdutos:nAt,3];
		}}

	// DoubleClick event
	oBrwServProdutos:bLDblClick := {|| __cFilialServico :=  aBrwServProdutos[oBrwServProdutos:nAt,1],;
		oBrwServProdutos:DrawSelect(), oDlgFiltro:End()}

	if oBrwServProdutos <> Nil
		oBrwServProdutos:Refresh()
	endIf

	if oDlgFiltro <> Nil
		oDlgFiltro:Refresh()
	endIf

Return(Nil)

/*/{Protheus.doc} FiltraSB1
funcao para reconstruir o browse de servicos/produtos
@type function
@version 1.0
@author g.sampaio
@since 29/07/2021
@param cFilInt, character, filial de origem da integracao
@param cGetServico, character, codigo/descricao para consulta dos servicos
@param aBrwServProdutos, array, array de servicos/produtos
@param oBrwServProdutos, object, objeto do browse de servicos/produtos
@param oDlgFiltro, object, objeto de dialog do browse de servicos/produtos
/*/
Static Function FiltraSB1(cFilInt, cGetServico, aBrwServProdutos, oBrwServProdutos, oDlgFiltro)
	BrwProdutoServico(cFilInt, cGetServico, @aBrwServProdutos, @oBrwServProdutos, @oDlgFiltro)
Return(Nil)

/*/{Protheus.doc} IntRetFilial
Funcao para retornar o compartilahmento da tabela
de acordo com a filial de origem
@type function
@version 1.0  
@author g.sampaio
@since 29/07/2021
@param cAliasTab, character, alias da tabela
@return character, retorna o compartilhamento da tabela
/*/
User Function IntRetFilial(cAliasTab, cFilInt)

	Local cRetorno 	:= ""

	Default cAliasTab 	:= ""
	Default cFilInt		:= ""

	if !Empty(cFilInt)
		cRetorno := FWxFilial(cAliasTab, cFilInt)
	else
		cRetorno := xFilial(cAliasTab)
	endIf

Return(cRetorno)

/*/{Protheus.doc} UIntCemProduto
Consulta Especifica para integracao de empresa
dos servicos executados (campo UZ6_PRDDST - U05INT)
@type function
@version 1.0 
@author g.sampaio
@since 29/07/2021
@param cFilInt, character, filial de integracao
@return logical, retorno verdadeiro sobre 
/*/
User Function UIntCemProduto(cFilInt)

	Local aBrwProdCem	 	:= {}
	Local bFiltro			:= Nil
	Local cGetProdCem 		:= Space(TamSX3("U05_CODIGO")[1])
	Local oBtnFiltrar		:= Nil
	Local oBtnConfirmar		:= Nil
	Local oBtnFechar		:= Nil
	Local oBtnLimpar		:= Nil
	Local oGetServico		:= Nil
	Local oGrpFiltros		:= Nil
	Local oGrpPrdServ		:= Nil
	Local oSayServico		:= Nil
	Local oBrwProdCem		:= Nil
	Local oDlgProdCem		:= Nil

	Static __cFilialProCem	:= ""

	Default cFilInt			:= ""

	// defino o bloco de código
	bFiltro := {|| FiltraU05(cFilInt, cGetProdCem, @aBrwProdCem, @oBrwProdCem, @oDlgProdCem) }

	// limpo a variavel estatica se ela estiver com conteudo
	if !Empty(__cFilialProCem)
		__cFilialProCem	:= ""
	endIf

	DEFINE MSDIALOG oDlgProdCem TITLE "Produto de Cemiterio" FROM 000, 000  TO 450, 600 COLORS 0, 16777215 PIXEL

	// grupo de filtros
	@ 002, 004 GROUP oGrpFiltros TO 034, 300 PROMPT "Filtros" OF oDlgProdCem COLOR 0, 16777215 PIXEL

	@ 010, 015 SAY oSayServico PROMPT "Produto" SIZE 025, 007 OF oDlgProdCem COLORS 0, 16777215 PIXEL
	@ 018, 014 MSGET oGetServico VAR cGetProdCem PICTURE "@!" SIZE 180, 010 OF oDlgProdCem COLORS 0, 16777215 PIXEL VALID (iif(!Empty(cGetProdCem),Eval(bFiltro),.T.))

	@ 015, 205 BUTTON oBtnFiltrar PROMPT "Filtrar" SIZE 037, 012 OF oDlgProdCem PIXEL Action(Eval(bFiltro))
	@ 015, 245 BUTTON oBtnLimpar PROMPT "Limpar" SIZE 037, 012 OF oDlgProdCem PIXEL Action(cGetProdCem := "", Eval(bFiltro))

	// grupo de produtos e servicos
	@ 037, 004 GROUP oGrpPrdServ TO 195, 300 PROMPT "Produto de Cemiterio" OF oDlgProdCem COLOR 0, 16777215 PIXEL
	BrwProdCem(cFilInt, cGetProdCem, @aBrwProdCem, @oBrwProdCem, @oDlgProdCem)

	@ 205, 245 BUTTON oBtnConfirmar PROMPT "Confirmar" SIZE 037, 012 OF oDlgProdCem PIXEL ACTION(__cFilialProCem := aBrwProdCem[oBrwProdCem:nAT, 1], oDlgProdCem:End())
	@ 205, 205 BUTTON oBtnFechar PROMPT "Fechar" SIZE 037, 012 OF oDlgProdCem PIXEL ACTION(__cFilialProCem := "", oDlgProdCem:End())

	ACTIVATE MSDIALOG oDlgProdCem CENTERED

Return(.T.)

/*/{Protheus.doc} RetProdCemInt
retorno da consulta especifica de servicos
para integracao
@type function
@version 1.0
@author g.sampaio
@since 29/07/2021
@return character, retorna a variavel estatica
/*/
User Function RetProdCemInt()
Return(__cFilialProCem)

/*/{Protheus.doc} BrwProdCem
grid de produtos e servicos
@type function
@version 1.0
@author g.sampaio
@since 29/07/2021
@param cFilInt, character, filial de origem da integracao
@param cGetProdCem, character, codigo/descricao para consulta da composicao de produto
@param aBrwProdCem, array, array da composicao de produto
@param oBrwProdCem, object, objeto do browse da composicao de produto
@param oDlgProdCem, object, objeto de dialog do browse da composicao de produto
/*/
Static Function BrwProdCem(cFilInt, cGetProdCem, aBrwProdCem, oBrwProdCem, oDlgProdCem)

	Local cQuery 	:= ""
	Local cAliasTab	:= ""

	// limpo o array de produtos
	aBrwProdCem := {}

	cQuery := " SELECT U05.U05_CODIGO, U05.U05_DESCRI FROM " + RetSqlName("U05") + " U05 "
	cQuery += " WHERE U05.D_E_L_E_T_ = ' ' "
	cQuery += " AND U05.U05_FILIAL = '" + U_IntRetFilial("U05", cFilInt) + "'"
	cQuery += " AND U05.U05_SITUAC = 'A' "

	if !Empty(cGetProdCem)
		cQuery += " AND (U05.U05_CODIGO LIKE '%" + AllTrim(cGetProdCem) + "%' OR U05.U05_DESCRI LIKE '%" + AllTrim(cGetProdCem) + "%')"
	endIf

	cQuery += " ORDER BY U05.U05_DESCRI ASC"

	cQuery := ChangeQueru(cQuery)

	MPSysOpenQuery(cQuery, "TRBU05")

	if TRBU05->(!Eof())
		While TRBU05->(!Eof())
			Aadd(aBrwProdCem,{TRBU05->U05_CODIGO, TRBU05->U05_DESCRI})

			TRBU05->(DBSkip())
		endDo
	else
		Aadd(aBrwProdCem,{"",""})
	endIf

	If Select("TRBU05") > 0
		TRBU05->(DbCloseArea())
	EndIf

	@ 043, 007 LISTBOX oBrwProdCem Fields HEADER "Codigo","Descrição" SIZE 290, 143 OF oDlgProdCem PIXEL ColSizes 50, 200
	oBrwProdCem:SetArray(aBrwProdCem)
	oBrwProdCem:bLine := {|| {;
		aBrwProdCem[oBrwProdCem:nAt,1],;
		aBrwProdCem[oBrwProdCem:nAt,2];
		}}

	// DoubleClick event
	oBrwProdCem:bLDblClick := {|| __cFilialProCem :=  aBrwProdCem[oBrwProdCem:nAt,1],;
		oBrwProdCem:DrawSelect(), oDlgProdCem:End()}

	if oBrwProdCem <> Nil
		oBrwProdCem:Refresh()
	endIf

	if oDlgProdCem <> Nil
		oDlgProdCem:Refresh()
	endIf

Return(Nil)

/*/{Protheus.doc} FiltraU05
funcao para reconstruir o browse de servicos/produtos
@type function
@version 1.0
@author g.sampaio
@since 29/07/2021
@param cFilInt, character, filial de origem da integracao
@param cGetProdCem, character, codigo/descricao para consulta da composicao de produto
@param aBrwProdCem, array, array da composicao de produto
@param oBrwProdCem, object, objeto do browse da composicao de produto
@param oDlgProdCem, object, objeto de dialog do browse da composicao de produto
/*/
Static Function FiltraU05(cFilInt, cGetProdCem, aBrwProdCem, oBrwProdCem, oDlgProdCem)
	BrwProdCem(cFilInt, cGetProdCem, @aBrwProdCem, @oBrwProdCem, @oDlgProdCem)
Return(Nil)

/*/{Protheus.doc} UIntSrvHab
Consulta Especifica para integracao de empresa
dos servicos habilitados (campo UZ6_SRVDES - U36INT)
@type function
@version 1.0 
@author g.sampaio
@since 29/07/2021
@param cFilInt, character, filial de integracao
@return logical, retorno verdadeiro sobre 
/*/
User Function UIntSrvHab(cFilInt, cProdCem)

	Local aBrwServHab	 		:= {}
	Local bFiltro				:= Nil
	Local cGetServHab 			:= Space(TamSX3("B1_COD")[1])
	Local oBtnFiltrar			:= Nil
	Local oBtnConfirmar			:= Nil
	Local oBtnFechar			:= Nil
	Local oBtnLimpar			:= Nil
	Local oGetServico			:= Nil
	Local oGrpFiltros			:= Nil
	Local oGrpPrdServ			:= Nil
	Local oSayServico			:= Nil
	Local oBrwServHab			:= Nil
	Local oDlgServHab			:= Nil

	Static __cServHabilitado	:= ""

	Default cFilInt			:= ""
	Default cProdCem		:= ""

	// defino o bloco de código
	bFiltro := {|| FiltraU36(cFilInt, cProdCem, cGetServHab, @aBrwServHab, @oBrwServHab, @oDlgServHab) }

	// limpo a variavel estatica se ela estiver com conteudo
	if !Empty(__cServHabilitado)
		__cServHabilitado	:= ""
	endIf

	DEFINE MSDIALOG oDlgServHab TITLE "Serviços Habilitados" FROM 000, 000  TO 450, 600 COLORS 0, 16777215 PIXEL

	// grupo de filtros
	@ 002, 004 GROUP oGrpFiltros TO 034, 300 PROMPT "Filtros" OF oDlgServHab COLOR 0, 16777215 PIXEL

	@ 010, 015 SAY oSayServico PROMPT "Serviço" SIZE 025, 007 OF oDlgServHab COLORS 0, 16777215 PIXEL
	@ 018, 014 MSGET oGetServico VAR cGetServHab PICTURE "@!" SIZE 180, 010 OF oDlgServHab COLORS 0, 16777215 PIXEL VALID (iif(!Empty(cGetServHab),Eval(bFiltro),.T.))

	@ 015, 205 BUTTON oBtnFiltrar PROMPT "Filtrar" SIZE 037, 012 OF oDlgServHab PIXEL Action(Eval(bFiltro))
	@ 015, 245 BUTTON oBtnLimpar PROMPT "Limpar" SIZE 037, 012 OF oDlgServHab PIXEL Action(cGetServHab := "", Eval(bFiltro))

	// grupo de Serviços Habilitados
	@ 037, 004 GROUP oGrpPrdServ TO 195, 300 PROMPT "Serviços Habilitados" OF oDlgServHab COLOR 0, 16777215 PIXEL
	BrwServHabilitados(cFilInt, cProdCem, cGetServHab, @aBrwServHab, @oBrwServHab, @oDlgServHab)

	@ 205, 245 BUTTON oBtnConfirmar PROMPT "Confirmar" SIZE 037, 012 OF oDlgServHab PIXEL ACTION(__cServHabilitado := aBrwServHab[oBrwServHab:nAT, 1], oDlgServHab:End())
	@ 205, 205 BUTTON oBtnFechar PROMPT "Fechar" SIZE 037, 012 OF oDlgServHab PIXEL ACTION(__cServHabilitado := "", oDlgServHab:End())

	ACTIVATE MSDIALOG oDlgServHab CENTERED

Return(.T.)

/*/{Protheus.doc} RetSrvHabInt
retorno da consulta especifica de servicos
para integracao
@type function
@version 1.0
@author g.sampaio
@since 29/07/2021
@return character, retorna a variavel estatica
/*/
User Function RetSrvHabInt()
Return(__cServHabilitado)

/*/{Protheus.doc} BrwServHabilitados
grid de produtos e servicos
@type function
@version 1.0
@author g.sampaio
@since 29/07/2021
@param cFilInt, character, filial de origem da integracao
@param cGetServico, character, codigo/descricao para consulta dos servicos
@param aBrwServProdutos, array, array de servicos/produtos
@param oBrwServProdutos, object, objeto do browse de servicos/produtos
@param oDlgFiltro, object, objeto de dialog do browse de servicos/produtos
/*/
Static Function BrwServHabilitados(cFilInt, cProdCem, cGetServHab, aBrwServHab, oBrwServHab, oDlgServHab)

	Local cQuery 	:= ""

	// limpo o array de produtos
	aBrwServHab := {}

	cQuery := " SELECT U36.U36_SERVIC, U36.U36_DESCRI FROM " + RetSqlName("U36") + " U36 "
	cQuery += " WHERE U36.D_E_L_E_T_ = ' ' "
	cQuery += " AND U36.U36_FILIAL = '" + U_IntRetFilial("U36", cFilInt) + "' "
	cQuery += " AND U36.U36_CODIGO = '" + cProdCem + "' "

	if !Empty(cGetServHab)
		cQuery += " AND (U36.U36_SERVIC LIKE '%" + AllTrim(cGetServHab) + "%' OR U36.U36_DESCRI LIKE '%" + AllTrim(cGetServHab) + "%')"
	endIf

	cQuery += " ORDER BY U36.U36_DESCRI ASC"

	cQuery := ChangeQueru(cQuery)

	MPSysOpenQuery(cQuery, "TRBU36")

	if TRBU36->(!Eof())
		While TRBU36->(!Eof())
			Aadd(aBrwServHab,{TRBU36->U36_SERVIC, TRBU36->U36_DESCRI})

			TRBU36->(DBSkip())
		endDo
	else
		Aadd(aBrwServHab,{"",""})
	endIf

	If Select("TRBU36") > 0
		TRBU36->(DbCloseArea())
	EndIf

	@ 043, 007 LISTBOX oBrwServHab Fields HEADER "Codigo","Descrição" SIZE 290, 143 OF oDlgServHab PIXEL ColSizes 50, 200
	oBrwServHab:SetArray(aBrwServHab)
	oBrwServHab:bLine := {|| {;
		aBrwServHab[oBrwServHab:nAt,1],;
		aBrwServHab[oBrwServHab:nAt,2];
		}}

	// DoubleClick event
	oBrwServHab:bLDblClick := {|| __cServHabilitado :=  aBrwServHab[oBrwServHab:nAt,1],;
		oBrwServHab:DrawSelect(), oDlgServHab:End()}

	if oBrwServHab <> Nil
		oBrwServHab:Refresh()
	endIf

	if oDlgServHab <> Nil
		oDlgServHab:Refresh()
	endIf

Return(Nil)

/*/{Protheus.doc} FiltraU36
funcao para reconstruir o browse de servicos/produtos
@type function
@version 1.0
@author g.sampaio
@since 29/07/2021
@param cFilInt, character, filial de origem da integracao
@param cGetServico, character, codigo/descricao para consulta dos servicos
@param aBrwServProdutos, array, array de servicos/produtos
@param oBrwServProdutos, object, objeto do browse de servicos/produtos
@param oDlgFiltro, object, objeto de dialog do browse de servicos/produtos
/*/
Static Function FiltraU36(cFilInt, cProdCem, cGetServHab, aBrwServHab, oBrwServHab, oDlgServHab)
	BrwServHabilitados(cFilInt, cProdCem, cGetServHab, @aBrwServHab, @oBrwServHab, @oDlgServHab)
Return(Nil)

/*/{Protheus.doc} UIntSrvHab
Consulta Especifica para integracao de empresa
dos planos contratados (campo UZ6_PLNORI - UF0INT)
@type function
@version 1.0 
@author g.sampaio
@since 29/07/2021
@param cFilInt, character, filial de integracao
@return logical, retorno verdadeiro sobre 
/*/
User Function UIntPlanos(cFilInt)

	Local aBrwPlanos	 	:= {}
	Local bFiltro			:= Nil
	Local cGetPlanos 		:= Space(TamSX3("UF0_DESCRI")[1])
	Local oBtnFiltrar		:= Nil
	Local oBtnConfirmar		:= Nil
	Local oBtnFechar		:= Nil
	Local oBtnLimpar		:= Nil
	Local oGetServico		:= Nil
	Local oGrpFiltros		:= Nil
	Local oGrpPrdServ		:= Nil
	Local oSayServico		:= Nil
	Local oBrwPlano			:= Nil
	Local oDlgPlano			:= Nil

	Static __cPlanoOrigem	:= ""

	Default cFilInt			:= ""

	// defino o bloco de código
	bFiltro := {|| FiltraUF0(cFilInt, cGetPlanos, @aBrwPlanos, @oBrwPlano, @oDlgPlano) }

	// limpo a variavel estatica se ela estiver com conteudo
	if !Empty(__cPlanoOrigem)
		__cPlanoOrigem	:= ""
	endIf

	DEFINE MSDIALOG oDlgPlano TITLE "Planos" FROM 000, 000  TO 450, 600 COLORS 0, 16777215 PIXEL

	// grupo de filtros
	@ 002, 004 GROUP oGrpFiltros TO 034, 300 PROMPT "Filtros" OF oDlgPlano COLOR 0, 16777215 PIXEL

	@ 010, 015 SAY oSayServico PROMPT "Planos" SIZE 025, 007 OF oDlgPlano COLORS 0, 16777215 PIXEL
	@ 018, 014 MSGET oGetServico VAR cGetPlanos PICTURE "@!" SIZE 180, 010 OF oDlgPlano COLORS 0, 16777215 PIXEL VALID (iif(!Empty(cGetPlanos),Eval(bFiltro),.T.))

	@ 015, 205 BUTTON oBtnFiltrar PROMPT "Filtrar" SIZE 037, 012 OF oDlgPlano PIXEL Action(Eval(bFiltro))
	@ 015, 245 BUTTON oBtnLimpar PROMPT "Limpar" SIZE 037, 012 OF oDlgPlano PIXEL Action(cGetPlanos := "", Eval(bFiltro))

	// grupo de Serviços Habilitados
	@ 037, 004 GROUP oGrpPrdServ TO 195, 300 PROMPT "Planos" OF oDlgPlano COLOR 0, 16777215 PIXEL
	BrwPlanos(cFilInt, cGetPlanos, @aBrwPlanos, @oBrwPlano, @oDlgPlano)

	@ 205, 245 BUTTON oBtnConfirmar PROMPT "Confirmar" SIZE 037, 012 OF oDlgPlano PIXEL ACTION(__cPlanoOrigem := aBrwPlanos[oBrwPlano:nAT, 1], oDlgPlano:End())
	@ 205, 205 BUTTON oBtnFechar PROMPT "Fechar" SIZE 037, 012 OF oDlgPlano PIXEL ACTION(__cPlanoOrigem := "", oDlgPlano:End())

	ACTIVATE MSDIALOG oDlgPlano CENTERED

Return(.T.)

/*/{Protheus.doc} RetPlanoInt
retorno da consulta especifica de servicos
para integracao
@type function
@version 1.0
@author g.sampaio
@since 29/07/2021
@return character, retorna a variavel estatica
/*/
User Function RetPlanoInt()
Return(__cPlanoOrigem)

/*/{Protheus.doc} BrwPlanos
grid de produtos e servicos
@type function
@version 1.0
@author g.sampaio
@since 29/07/2021
@param cFilInt, character, filial de origem da integracao
@param cGetServico, character, codigo/descricao para consulta dos servicos
@param aBrwServProdutos, array, array de servicos/produtos
@param oBrwServProdutos, object, objeto do browse de servicos/produtos
@param oDlgFiltro, object, objeto de dialog do browse de servicos/produtos
/*/
Static Function BrwPlanos(cFilInt, cGetPlanos, aBrwPlanos, oBrwPlano, oDlgPlano)

	Local cQuery 	:= ""

	// limpo o array de produtos
	aBrwPlanos := {}

	cQuery := " SELECT UF0.UF0_CODIGO, UF0.UF0_DESCRI FROM " + RetSqlName("UF0") + " UF0 "
	cQuery += " WHERE UF0.D_E_L_E_T_ = ' ' "
	cQuery += " AND UF0.UF0_FILIAL = '" + U_IntRetFilial("UF0", cFilInt) + "' "

	if !Empty(cGetPlanos)
		cQuery += " AND ((UF0.UF0_CODIGO LIKE '%" + AllTrim(cGetPlanos) + "%' OR UF0.UF0_CODIGO LIKE '%" + AllTrim(cGetPlanos) + "%')"
		cQuery += " OR (UF0.UF0_DESCRI LIKE '%" + AllTrim(cGetPlanos) + "%' OR UF0.UF0_DESCRI LIKE '%" + AllTrim(cGetPlanos) + "%'))"
	endIf

	cQuery += " ORDER BY UF0.UF0_DESCRI ASC"

	cQuery := ChangeQueru(cQuery)

	MPSysOpenQuery(cQuery, "TRBUF0")

	if TRBUF0->(!Eof())
		While TRBUF0->(!Eof())
			Aadd(aBrwPlanos,{TRBUF0->UF0_CODIGO, TRBUF0->UF0_DESCRI})

			TRBUF0->(DBSkip())
		endDo
	else
		Aadd(aBrwPlanos,{"",""})
	endIf

	If Select("TRBUF0") > 0
		TRBUF0->(DbCloseArea())
	EndIf

	@ 043, 007 LISTBOX oBrwPlano Fields HEADER "Codigo","Descrição" SIZE 290, 143 OF oDlgPlano PIXEL ColSizes 50, 200
	oBrwPlano:SetArray(aBrwPlanos)
	oBrwPlano:bLine := {|| {;
		aBrwPlanos[oBrwPlano:nAt,1],;
		aBrwPlanos[oBrwPlano:nAt,2];
		}}

	// DoubleClick event
	oBrwPlano:bLDblClick := {|| __cPlanoOrigem :=  aBrwPlanos[oBrwPlano:nAt,1],;
		oBrwPlano:DrawSelect(), oBrwPlano:End()}

	if oBrwPlano <> Nil
		oBrwPlano:Refresh()
	endIf

	if oDlgPlano <> Nil
		oDlgPlano:Refresh()
	endIf

Return(Nil)

/*/{Protheus.doc} FiltraUF0
funcao para reconstruir o browse de planos
@type function
@version 1.0
@author g.sampaio
@since 29/07/2021
@param cFilInt, character, filial de origem da integracao
@param cGetServico, character, codigo/descricao para consulta dos servicos
@param aBrwServProdutos, array, array de servicos/produtos
@param oBrwServProdutos, object, objeto do browse de servicos/produtos
@param oDlgFiltro, object, objeto de dialog do browse de servicos/produtos
/*/
Static Function FiltraUF0(cFilInt, cGetPlanos, aBrwServHab, oBrwServHab, oDlgServHab)
	BrwPlanos(cFilInt, cGetPlanos, @aBrwServHab, @oBrwServHab, @oDlgServHab)
Return(Nil)

/*/{Protheus.doc} ValIntSB1
Valida o produto/servico informado
de acordo com a filial
@type function
@version 1.0
@author g.sampaio
@since 31/07/2021
@param cFilInt, character, filial de integracao
@param cProdSB1, character, codigo do produto/servico 
@return logical, retorna se o produto/servico existe
/*/
User Function ValIntSB1(cFilInt, cProdSB1, cProdOri)

	Local cQuery		:= ""
	Local lRetorno		:= .F.
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.)
	Local cUsoServico	:= ""

	Default cFilInt		:= ""
	Default cProdSB1	:= ""
	Default cProdOri	:= ""

	If Select("TRBSB1")
		TRBSB1->(DbCloseArea())
	EndIf

	cQuery := " SELECT SB1.B1_COD "

	// para uso do plano pet
	if lPlanoPet
		cQuery += ",SB1.B1_XUSOSRV "
	endIf

	cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SB1.B1_FILIAL = '" + U_IntRetFilial("SB1", cFilInt) + "'"
	cQuery += " AND SB1.B1_COD = '" + AllTrim(cProdSB1) + "' "

	cQuery := ChangeQueru(cQuery)

	MPSysOpenQuery(cQuery, "TRBSB1")

	if TRBSB1->(!Eof())
		lRetorno	:= .T.

		// para uso do plano pet
		if lPlanoPet
			cUsoServico := TRBSB1->B1_XUSOSRV
		endIf

	else
		Help(,,'Help',,"Produto/Servicos não cadastrado na filial!",1,0)
	endIf

	If Select("TRBSB1")
		TRBSB1->(DbCloseArea())
	EndIf

	// para validar o
	if lRetorno .And. lPlanoPet .And. !Empty(cProdOri) .And. !Empty(cUsoServico)

		cQuery := " SELECT SB1.B1_COD, SB1.B1_XUSOSRV FROM " + RetSqlName("SB1") + " SB1 "
		cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' "
		cQuery += " AND SB1.B1_FILIAL = '" + U_IntRetFilial("SB1", M->UZ4_FILIAL) + "'"
		cQuery += " AND SB1.B1_COD = '" + AllTrim(cProdOri) + "' "

		cQuery := ChangeQueru(cQuery)

		MPSysOpenQuery(cQuery, "TRBSB1")

		if TRBSB1->(!Eof())
			if TRBSB1->B1_XUSOSRV <> cUsoServico
				lRetorno := .F.
				Help(,,'Help',,"O uso do serviço de origem deve ser o mesmo do serviço de destino!",1,0)
			endIf
		endIf

		If Select("TRBSB1")
			TRBSB1->(DbCloseArea())
		EndIf

	endIf

Return(lRetorno)

/*/{Protheus.doc} ValIntSM0
Valida o codigo da filial digitado
@type function
@version 1.0
@author g.sampaio
@since 31/07/2021
@param cFilInt, character, codigo da filial
@return logical, retorna se a filial existe
/*/
User Function ValIntSM0(cFilInt)

	Local aEmpresas		:= {}
	Local lRetorno		:= .F.
	Local nPosFilial	:= 0

	Default cFilInt		:= ""

	// pego as informacoes das empresas da SM0
	aEmpresas	:= FWLoadSM0()

	nPosFilial	:= AScan(aEmpresas, {|x| x[2] == cFilInt})

	if nPosFilial > 0
		lRetorno	:= .T.
	else
		Help(,,'Help',,"Filial digitada não faz parte do grupo de empresas!",1,0)
	endIf

Return(lRetorno)

/*/{Protheus.doc} ValIntU05
Valida o produto/servico informado
de acordo com a filial
@type function
@version 1.0
@author g.sampaio
@since 31/07/2021
@param cFilInt, character, filial de integracao
@param cProdSB1, character, codigo do produto/servico 
@return logical, retorna se o produto/servico existe
/*/
User Function ValIntU05(cFilInt, cProdU05)

	Local cQuery		:= ""
	Local lRetorno		:= .F.

	Default cFilInt		:= ""
	Default cProdSB1	:= ""

	cQuery := " SELECT U05.U05_CODIGO FROM " + RetSqlName("U05") + " U05 "
	cQuery += " WHERE U05.D_E_L_E_T_ = ' ' "
	cQuery += " AND U05.U05_FILIAL = '" + U_IntRetFilial("U05", cFilInt) + "'"
	cQuery += " AND U05.U05_CODIGO = '" + AllTrim(cProdU05) + "' "

	cQuery := ChangeQueru(cQuery)

	MPSysOpenQuery(cQuery, "TRBU05")

	if TRBU05->(!Eof())
		lRetorno	:= .T.
	else
		Help(,,'Help',,"Produto de cemitério não cadastrado na filial!",1,0)
	endIf

	If Select("TRBU05")
		TRBU05->(DbCloseArea())
	EndIf

Return(lRetorno)
