#Include "totvs.ch"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'

#Define ICON_ATIVO "ICON_ATIVO.PNG"
#Define ICON_FALECIDO "ICON_INAT.PNG"

/*/{Protheus.doc} RFUNA002
Rotina de contrato de funerแria	
@type function
@version 1.0
@author Wellington Gon็alves
@since 07/07/2016
/*/
User Function RFUNA002()

	Local oBrowse
	Local lFuneraria 			:= SuperGetMV("MV_XFUNE",.F., .F.)

	//Private aRotina 	:= {}
	Private oTotais		:= NIL
	Private oStatus		:= NIL
	Private oBkpCtr		:= NIL
	Private cPlanoBkp	:= ""
	Private nReajBkp	:= 0
	Private cAdesIgualPar	:= ""

	If !lFuneraria
		MsgAlert("Parametro MV_XFUNE desabilitado para a filial, nใo ้ possํvel abrir a rotina de contratos de Planos Funerแrios!")
	Else

		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias("UF2")
		oBrowse:SetDescription("Contrato Funerแrio")

		If ExistBlock("PEFUN02BR")
			oBrowse := ExecBlock("PEFUN02BR", .F., .F., { oBrowse })
		EndIf

		oBrowse:AddLegend("UF2_STATUS == 'P'", "WHITE"	, "Pre-cadastrado")
		oBrowse:AddLegend("UF2_STATUS == 'A'", "GREEN"	, "Ativo")
		oBrowse:AddLegend("UF2_STATUS == 'S'", "ORANGE"	, "Suspenso")
		oBrowse:AddLegend("UF2_STATUS == 'C'", "BLUE"	, "Cancelado")
		oBrowse:AddLegend("UF2_STATUS == 'F'", "RED"	, "Finalizado")

		oBrowse:SetAttach( .T. )

		oBrowse:Activate()

	EndIf

Return(Nil)

/*/{Protheus.doc} MenuDef
Fun็ใo que cria os menus
@type function
@version 1.0
@author Wellington Gon็alves
@since 05/07/2016
/*/
Static Function MenuDef()

	Local aRotina				:= {}
	Local aRotApt				:= {}
	Local aRotReaj				:= {}
	Local aRotManut				:= {}
	Local aRotAdt				:= {}
	Local aRotMnt				:= {}
	Local aRotCli				:= {}
	Local aRotConv				:= {}
	Local aRotTermo				:= {}
	Local aEspecificos			:= {}
	Local aRotinasMenus			:= {}
	Local aDocumentos			:= {}
	Local lAtivaMntFun			:= SuperGetMv("MV_XMNTFUN",.F.,.F.)
	Local lImpCartao			:= SuperGetMV("MV_XCARCTR",.F.,.F.) // habilita a impressao de cartao do contrato
	Local lUsaConvalescencia	:= SuperGetMv("MV_XUSACON",.F.,.F.)
	Local lTermoCustomizado		:= SuperGetMV("MV_XTERMOC", .F., .F.) // parametro para informar se utilizo a impressao de termos customizada
	Local lIntEmp				:= SuperGetMV("MV_XINTEMP", .F., .F.) // habilito o uso da integracao de empresas
	Local lNovPnFin				:= SuperGetMV("MV_XNVPNFN", .F., .F.) // Habilita o novo painel financeiro
	Local lAPICliente			:= SuperGetMV("MV_XAPICLI",.F.,.F.)
	Local lAnexaDoc				:= SuperGetMV("MV_XANXDOC", .F.,.F.)
	Local nRotMenus				:= 0
	Local oVirtusGestaoAcessos	:= VirtusGestaoAcessos():New()

	// carrego os acessos do usuario
	oVirtusGestaoAcessos:AcessosUsuario()

	// rotinas de anexo de documentos
	Aadd( aDocumentos, {"Anexar documentos","U_RUTIL50A(UF2->UF2_CODIGO, 'F', 'RFUNA002', UF2->UF2_CODIGO)", 0, 4} )
	Aadd( aDocumentos, {"Visualizar","U_RUTIL50B(UF2->UF2_CODIGO, 'F', 'RFUNA002', UF2->UF2_CODIGO)", 0, 4} )
	Aadd( aDocumentos, {"Historico","U_RUTIL050(UF2->UF2_CODIGO, 'F', 'RFUNA002', UF2->UF2_CODIGO)", 0, 4} )

	// Manuten็ใo financeira
	aadd(aRotManut , {"Resetar"		,"U_RFUNA009()", 0, 4})
	aadd(aRotManut , {"Painel"		, IIF(lNovPnFin, "U_RUTILE46()", "U_RFUNE024()"), 0, 4})
	aadd(aRotManut , {"Liquidacao"	,"U_RFUNE043(UF2->UF2_CODIGO)", 0, 4})
	aadd(aRotManut , {"Reprocessar Vindi","U_REPRVIND(UF2->UF2_CODIGO)", 0, 4})

	// Apontamento de servi็o
	aadd(aRotApt , {"Apontamento de Servico","U_RFUNA003()", 0, 4})
	aadd(aRotApt , {"Hist๓rico de Apt. de Servi็os"," U_RFUNA019() ", 0, 4})
	aadd(aRotApt , {"Imprimir Nota"," U_RUTILE25() ", 0, 4})

	// Reajuste de contrato
	aadd(aRotReaj , {"Reajustar Contratos","U_RFUNA032()", 0, 2})
	aadd(aRotReaj , {"Hist๓rico de Reajuste"," U_RFUNA011() ", 0, 2})
	aadd(aRotReaj , {"Inclusใo Manual de Reajustes"," U_RFUNE025(UF2->UF2_CODIGO) ", 0, 2})

	//Adiantamento de Parcelas
	aadd(aRotAdt , {"Adiantar Parcelas","U_RFUNA027()", 0, 2})
	aadd(aRotAdt , {"Hist๓rico de Adiantamentos"," U_RFUNA026() ", 0, 2})

	//Cadastro de Clientes
	aadd(aRotCli , {"Incluir","U_UManuCli(3)", 0, 2})
	aadd(aRotCli , {"Alterar"," U_UManuCli(4) ", 0, 2})
	aadd(aRotCli , {"Visualizar"," U_UManuCli(2) ", 0, 2})
	aadd(aRotCli , {"Contato"," U_UManuCli(5) ", 0, 2})

	//Valida se usa convalescencia
	If lUsaConvalescencia

		// Locacao Convalescencia
		aadd(aRotConv ,{"Incluir","U_RFUNA043()", 0, 4})
		aadd(aRotConv ,{"Ciclo Convalescencia"," U_RFUNA046() ", 0, 4})
		aadd(aRotConv ,{"Historico Convalesceente"," U_RFUNA044() ", 0, 4})
		aadd(aRotConv ,{"Historico cliclo Cobranca"," U_RFUNA047() ", 0, 4})

	Endif

	// verifico se o cliente optou pela customizacao de termo
	If lTermoCustomizado

		// verifico se o ponto de entrada de termo de cliente esta compilado na base do cliente
		If ExistBlock("PTERMOCLI")

			// impressใo de termos customizados pelo cliente
			aadd(aRotTermo ,{"Impressao Termo","U_PTERMOCLI()", 0, 2})

		Else

			// impressใo de termos pelo modelo padrใo do sistema (modelo word)
			aadd(aRotTermo ,{"Impressao Termo","U_RUTILE28(UF2->UF2_CODIGO)", 0, 2})

		EndIf

	Else// caso nao estiver coloco a impressao de termo padrao do template (modelo word)

		// impressใo de termos pelo modelo padrใo do sistema (modelo word)
		Aadd(aRotTermo ,{"Impressao Termo","U_RUTILE28(UF2->UF2_CODIGO)", 0, 2})
		Aadd(aRotTermo ,{"Ficha de Contrato","U_RFUNR033(UF2->UF2_CODIGO)", 0, 2})

	EndIf

	ADD OPTION aRotina Title 'Pesquisar'   						Action 'PesqBrw'          	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  						Action 'VIEWDEF.RFUNA002' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'     						Action 'VIEWDEF.RFUNA002' 	OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'     						Action 'VIEWDEF.RFUNA002' 	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     						Action 'VIEWDEF.RFUNA002' 	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    						Action 'VIEWDEF.RFUNA002' 	OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'     						Action 'U_FUNA002LEG()' 	OPERATION 10 ACCESS 0
	ADD OPTION aRotina Title 'Ativar'     						Action 'U_RFUNA004()'	 	OPERATION 11 ACCESS 0
	ADD OPTION aRotina Title "Reativar"							Action 'U_RFUNA025()'		OPERATION 13 ACCESS 0
	ADD OPTION aRotina Title "Cancelar"							Action 'U_RFUNA015()'		OPERATION 13 ACCESS 0
	ADD OPTION aRotina Title 'Transferencia de Titularidade'	Action 'U_RFUNA006()' 		OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Manuten็ใo Financeira'			Action aRotManut			OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Apontamento de Servico'			Action aRotApt 				OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Clientes'							Action aRotCli 				OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title "Reajuste"							Action aRotReaj				OPERATION 12 ACCESS 0
	ADD OPTION aRotina Title "Adiantamento"						Action aRotAdt				OPERATION 12 ACCESS 0

	If lUsaConvalescencia
		ADD OPTION aRotina Title "Convalescencia"					Action aRotConv				OPERATION 12 ACCESS 0
	Endif

	ADD OPTION aRotina Title "Gerador de Termos"							Action aRotTermo			OPERATION 12 ACCESS 0


	//Ativa Taxa de manuten็ใo no modulo funerแria
	if lAtivaMntFun

		//Taxa de Manutencao de Contratos
		aadd(aRotMnt , {"Gerar Taxa","U_RFUNA029()", 0, 2})
		aadd(aRotMnt , {"Hist๓rico de Manuten็๕es"," U_RFUNA028() ", 0, 2})

		ADD OPTION aRotina Title "Taxa de Manuten็ใo"				Action aRotMnt				OPERATION 12 ACCESS 0

	endif

	ADD OPTION aRotina Title "Consulta Contratos"				Action 'U_RFUNA022()'		OPERATION 01 ACCESS 0

	// valida se tem permissoes
	If oVirtusGestaoAcessos:ValidaAcessos(17) // acesso 017 - Anexar Documentos
		If lAnexaDoc
			ADD OPTION aRotina Title "Documentos"						Action aDocumentos							OPERATION 04 ACCESS 0
		Else
			ADD OPTION aRotina Title "Banco de Conhecimento"			Action "MSDOCUMENT"							OPERATION 04 ACCESS 0
		EndIf
	EndIf

	ADD OPTION aRotina Title 'Alterar Perfil de Pagamento'		Action 'U_UVIND11()' 		OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Alterar Forma de Pagamento'		Action 'U_UVIND12("F")' 	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title "Export. Dados Cliente"			Action "U_RCPG024B()" 		OPERATION 07 ACCESS 0
	ADD OPTION aRotina Title "Etiqueta Dados Cliente"			Action "U_RUTILR01()" 		OPERATION 07 ACCESS 0

	// verifico se a rotina de cancelamento por esta compilada
	If ExistBlock("RFUNA051")
		ADD OPTION aRotina Title 'Cancelamento Por Lote'		Action 'U_RFUNA051()' 			OPERATION 13 ACCESS 0
	EndIf

	// verifico se a impressao de cartao esta habilitada
	If ExistBlock("RFUNA052") .And. lImpCartao
		ADD OPTION aRotina Title "Impressใo de Cartใo"				Action "U_RFUNA052()"		OPERATION 4 ACCESS 0
	EndIf

	If ExistBlock("RUTILE45") .And. lIntEmp
		ADD OPTION aRotina Title 'Integracao de Empresas'		Action 'U_RUTILE45(UF2->UF2_MSFIL ,UF2->UF2_TPCONT, UF2->UF2_CODIGO)' 			OPERATION 13 ACCESS 0
	endIf

	// verifico se o programa do log de operacoes
	// da integracao do app de clientes esta compilado
	if lAPICliente .And. ExistBlock("RUTILE43")
		ADD OPTION aRotina Title "Integra็ใo APP"			Action 'U_RUTILE43(Posicione("SA1",1,xFilial("SA1")+UF2->UF2_CLIENT+UF2->UF2_LOJA,"A1_CGC"), .T.)'						OPERATION 06 ACCESS 0
	endIf

	// ponto de entrada para adicionar rotina customizada no menu
	If ExistBlock("PEFUN02ROT")

		// rotinas especificas do cliente
		aEspecificos := ExecBlock("PEFUN02ROT", .F., .F.)

		// verifico se tem rotinas
		If Len(aEspecificos) > 0
			ADD OPTION aRotina Title "Especificos"  Action aEspecificos  OPERATION 06 ACCESS 0
		EndIf

	EndIf

	// ponto de entrada para customizar
	If ExistBlock("PEFUN02MNU")

		// rotinas customizadas a serem adicionadas no menu
		aRotinasMenus	:= ExecBlock("PEFUN02MNU", .F., .F.)

		For nRotMenus := 1 To Len(aRotinasMenus)
			ADD OPTION aRotina Title aRotinasMenus[nRotMenus, 1]  Action aRotinasMenus[nRotMenus, 2]  OPERATION 06 ACCESS 0
		Next nRotMenus

	EndIf

Return(aRotina)

/*/{Protheus.doc} ModelDef
Fun็ใo que cria o objeto model
@type function
@version 1.0 
@author Wellington Gon็alves
@since 05/07/2016
/*/
Static Function ModelDef()

	Local cRotApto		:= SuperGetMv("MV_XROTAPT",.F.,"RFUNA034")
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local lPersonFun	:= SuperGetMv("MV_XPERFUN",.F.,.F.)
	Local lExibeSE1		:= SuperGetMV("MV_XEXISE1",.F.,.T.)
	Local lExibeSE3		:= SuperGetMV("MV_XEXISE3",.F.,.T.)
	Local oStruUF2 		:= FWFormStruct( 1, 'UF2', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruUF3 		:= FWFormStruct( 1, 'UF3', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruUF4 		:= FWFormStruct( 1, 'UF4', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruUF9 		:= FWFormStruct( 1, "UF9",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruUG0 		:= Nil
	Local oStruUJ0 		:= Nil
	Local oStruSE3 		:= iif(lExibeSE3,FWFormStruct(1,"SE3",/*bAvalCampo*/,/*lViewUsado*/ ),Nil)
	Local oStruSE1 		:= iif(lExibeSE1,DefStrModel("SE1"),Nil)
	Local oStruSC5 		:= DefStrModel("SC5")
	Local oStruSC6 		:= DefStrModel("SC6")
	Local oStruUF5 		:= FWFormStruct( 1, 'UF5', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruUF7 		:= iif(lExibeSE1,FWFormStruct( 1, 'UF7', /*bAvalCampo*/, /*lViewUsado*/ ),Nil)
	Local oStruUJ9 		:= FWFormStruct( 1, 'UJ9', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruUK2		:= FWFormStruct( 1, 'UK2', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel		:= Nil

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PFUNA002', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	/////////////////////////  CABEวALHO - CONTRATO  ////////////////////////////

	// Crio a Enchoice
	oModel:AddFields( 'UF2MASTER', /*cOwner*/, oStruUF2 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "UF2_FILIAL" , "UF2_CODIGO" })

	// Preencho a descri็ใo da entidade
	oModel:GetModel('UF2MASTER'):SetDescription('Dados do Contrato')

	///////////////////////////  ITENS - PRODUTOS/SERVIวOS  //////////////////////////////

	// Crio o grid
	oModel:AddGrid( 'UF3DETAIL', 'UF2MASTER', oStruUF3, /*bLinePre*/ {|oMdlG,nLine,cAcao,cCampo| EditGrid(oMdlG,nLine,cAcao,cCampo)} , /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Fa็o o relaciomaneto entre o cabe็alho e os itens
	oModel:SetRelation( 'UF3DETAIL', { { 'UF3_FILIAL', 'xFilial( "UF3" )' } , { 'UF3_CODIGO', 'UF2_CODIGO' } } , UF3->(IndexKey(1)) )

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel('UF3DETAIL'):SetOptional( .T. )

	oModel:GetModel('UF3DETAIL'):SetUniqueLine( {'UF3_PROD'} )

	// Preencho a descri็ใo da entidade
	oModel:GetModel('UF3DETAIL'):SetDescription('Produtos/Servi็os:')

	///////////////////////////  ITENS - BENEFICIARIOS  //////////////////////////////

	// Crio o grid
	oModel:AddGrid( 'UF4DETAIL', 'UF2MASTER', oStruUF4, /*bLinePre*/{|oMdlG,nLine,cAcao,cCampo| EditaBenef(oMdlG,nLine,cAcao,cCampo)}, {|oMdlPos| LinhaBenef(oMdlPos)}, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Fa็o o relaciomaneto entre o cabe็alho e os itens
	oModel:SetRelation( 'UF4DETAIL', { { 'UF4_FILIAL', 'xFilial( "UF4" )' } , { 'UF4_CODIGO', 'UF2_CODIGO' } } , UF4->(IndexKey(1)) )

	//Quando for importacao desobriga o preenchimento de beneficiario
	If lPlanoPet
		oModel:GetModel('UF4DETAIL'):SetOptional( .T. )
	ElseIf Type("lImp") == 'U' .Or. !lImp
		oModel:GetModel('UF4DETAIL'):SetOptional( .F. )
	Else
		oModel:GetModel('UF4DETAIL'):SetOptional( .T. )
	EndIf

	///////////////////////////  ITENS - Mensagens  //////////////////////////////

	// Crio o grid
	oModel:AddGrid( 'UF9DETAIL', 'UF2MASTER', oStruUF9, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Fa็o o relaciomaneto entre o cabe็alho e os itens
	oModel:SetRelation( 'UF9DETAIL', { { 'UF9_FILIAL', 'xFilial( "UF9" )' } , { 'UF9_CODIGO', 'UF2_CODIGO' } } , UF9->(IndexKey(1)) )

	oModel:GetModel('UF9DETAIL'):SetDescription('Mensagens')

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel('UF9DETAIL'):SetOptional( .T. )

	// Preencho a descri็ใo da entidade
	oModel:GetModel('UF4DETAIL'):SetDescription('Beneficiแrios:')

	///////////////////////////  ITENS - APONTAMENTO DE SERVICOS  //////////////////////////////

	If cRotApto == "RFUNA034" //Apto. mod2

		oStruUJ0 := FWFormStruct( 1, "UJ0",/*bAvalCampo*/,/*lViewUsado*/ )

		// Crio o grid
		oModel:AddGrid( 'UJ0DETAIL', 'UF2MASTER', oStruUJ0, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

		// Fa็o o relaciomaneto entre o cabe็alho e os itens
		oModel:SetRelation( 'UJ0DETAIL', { { 'UJ0_FILIAL', 'xFilial( "UJ0" )' } , { 'UJ0_CONTRA', 'UF2_CODIGO' } } , UJ0->(IndexKey(2)) )

		// Seto a propriedade de obrigatoriedade do preenchimento do grid
		oModel:GetModel('UJ0DETAIL'):SetOptional( .T. )
		oModel:GetModel('UJ0DETAIL'):SetOnlyQuery()
		oModel:GetModel('UJ0DETAIL'):SetOnlyView()
		oModel:GetModel('UJ0DETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('UJ0DETAIL'):SetNoUpdateLine(.T.)
		oModel:GetModel("UJ0DETAIL"):SetNoDeleteLine(.T.)

		// Preencho a descri็ใo da entidade
		oModel:GetModel('UJ0DETAIL'):SetDescription('Apontamentos:')

	Else

		oStruUG0 := FWFormStruct( 1, "UG0",/*bAvalCampo*/,/*lViewUsado*/ )

		// Crio o grid
		oModel:AddGrid( 'UG0DETAIL', 'UF2MASTER', oStruUG0, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

		// Fa็o o relaciomaneto entre o cabe็alho e os itens
		oModel:SetRelation( 'UG0DETAIL', { { 'UG0_FILIAL', 'xFilial( "UG0" )' } , { 'UG0_CONTRA', 'UF2_CODIGO' } } , UG0->(IndexKey(2)) )

		// Seto a propriedade de obrigatoriedade do preenchimento do grid
		oModel:GetModel('UG0DETAIL'):SetOptional( .T. )
		oModel:GetModel('UG0DETAIL'):SetOnlyQuery()
		oModel:GetModel('UG0DETAIL'):SetOnlyView()
		oModel:GetModel('UG0DETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('UG0DETAIL'):SetNoUpdateLine(.T.)
		oModel:GetModel("UG0DETAIL"):SetNoDeleteLine(.T.)

		// Preencho a descri็ใo da entidade
		oModel:GetModel('UG0DETAIL'):SetDescription('Apontamentos:')

	Endif

	///////////////////////////  ITENS - PEDIDOS DE VENDA  //////////////////////////////

	// Crio o grid
	oModel:AddGrid( 'SC5DETAIL', 'UF2MASTER', oStruSC5, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Fa็o o relaciomaneto entre o cabe็alho e os itens
	oModel:SetRelation( 'SC5DETAIL', { { 'C5_FILIAL', 'xFilial( "SC5" )' } , { 'C5_XCTRFUN', 'UF2_CODIGO' } } , SC5->(IndexKey(1)) )

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel('SC5DETAIL'):SetOptional( .T. )
	oModel:GetModel('SC5DETAIL'):SetOnlyQuery()
	oModel:GetModel('SC5DETAIL'):SetOnlyView()
	oModel:GetModel('SC5DETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('SC5DETAIL'):SetNoUpdateLine(.T.)

	// Preencho a descri็ใo da entidade
	oModel:GetModel('SC5DETAIL'):SetDescription('Pedidos de venda:')

	///////////////////////////  ITENS - ITENS DO PEDIDOS DE VENDA  //////////////////////////////

	// Crio o grid
	oModel:AddGrid( 'SC6DETAIL', 'SC5DETAIL', oStruSC6, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Fa็o o relaciomaneto entre o cabe็alho e os itens
	oModel:SetRelation( 'SC6DETAIL', { { 'C6_FILIAL', 'xFilial( "SC6" )' } , { 'C6_NUM', 'C5_NUM' } } , SC6->(IndexKey(1)) )

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel('SC6DETAIL'):SetOptional( .T. )
	oModel:GetModel('SC6DETAIL'):SetOnlyQuery()
	oModel:GetModel('SC6DETAIL'):SetOnlyView()
	oModel:GetModel('SC6DETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('SC6DETAIL'):SetNoUpdateLine(.T.)

	// Preencho a descri็ใo da entidade
	oModel:GetModel('SC6DETAIL'):SetDescription('Itens do Pedido:')

	///////////////////////////  ITENS - TITULOS  //////////////////////////////
	if lExibeSE1
		// Crio o grid
		oModel:AddGrid( 'SE1DETAIL', 'UF2MASTER', oStruSE1, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

		// Fa็o o relaciomaneto entre o cabe็alho e os itens
		oModel:SetRelation( 'SE1DETAIL', { { 'E1_FILIAL', 'UF2_MSFIL' } , { 'E1_XCTRFUN', 'UF2_CODIGO' } } , SE1->(DBNICKINDEXKEY("E1_XCTRFUN")) )

		// Seto a propriedade de obrigatoriedade do preenchimento do grid
		oModel:GetModel('SE1DETAIL'):SetOptional( .T. )
		oModel:GetModel('SE1DETAIL'):SetOnlyQuery()
		oModel:GetModel('SE1DETAIL'):SetOnlyView()
		oModel:GetModel('SE1DETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('SE1DETAIL'):SetNoUpdateLine(.T.)

		// Preencho a descri็ใo da entidade
		oModel:GetModel('SE1DETAIL'):SetDescription('Tํtulos:')
	endIf

	///////////////////////////  ITENS - HISTำRICO TRANSF. TITULARIDADE  //////////////////////////////

	// Crio o grid
	oModel:AddGrid( 'UF5DETAIL', 'UF2MASTER', oStruUF5, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Fa็o o relaciomaneto entre o cabe็alho e os itens
	oModel:SetRelation( 'UF5DETAIL', { { 'UF5_FILIAL', 'xFilial( "UF5" )' } , { 'UF5_CTRFUN', 'UF2_CODIGO' } } , UF5->(IndexKey(1)) )

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel('UF5DETAIL'):SetOptional( .T. )

	// Preencho a descri็ใo da entidade
	oModel:GetModel('UF5DETAIL'):SetDescription('Hist๓rico Transf. Titularidade:')
	oModel:GetModel('UF5DETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('UF5DETAIL'):SetNoUpdateLine(.T.)
	oModel:GetModel("UF5DETAIL"):SetNoDeleteLine(.T.)

	/////////////////////////// ITENS - COMISSOES DO VENDEDOR ///////////////////////////////////////////
	if lExibeSE3
		//Crio a Grid
		oModel:AddGrid("SE3DETAIL","UF2MASTER",oStruSE3,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

		// Fa็o o relaciomaneto entre o cabe็alho e os itens
		oModel:SetRelation( 'SE3DETAIL', { { 'E3_FILIAL', 'xFilial( "UF2" )' } , { 'E3_XCTRFUN', 'UF2_CODIGO' } } , SE3->(IndexKey(6)) ) //E3_FILIAL+E3_XCTRFUN

		// Seto a propriedade de obrigatoriedade do preenchimento do grid
		oModel:GetModel('SE3DETAIL'):SetOptional( .T. )

		// Preencho a descri็ใo da entidade
		oModel:GetModel('SE3DETAIL'):SetDescription('Comiss๕es do Vendedor:')
		oModel:GetModel('SE3DETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('SE3DETAIL'):SetNoUpdateLine(.T.)
		oModel:GetModel("SE3DETAIL"):SetNoDeleteLine(.T.)
	endIf

	///////////////////////////  ITENS - REAJUSTES REALIZADOS  //////////////////////////////

	if lExibeSE1
		// Crio o grid
		oModel:AddGrid( 'UF7DETAIL', 'UF2MASTER', oStruUF7, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

		// Fa็o o relaciomaneto entre o cabe็alho e os itens
		oModel:SetRelation( 'UF7DETAIL', { { 'UF7_FILIAL', 'xFilial( "UF7" )' } , { 'UF7_CONTRA', 'UF2_CODIGO' } } , UF7->(IndexKey(2)) )

		// Seto a propriedade de obrigatoriedade do preenchimento do grid
		oModel:GetModel('UF7DETAIL'):SetOptional( .T. )

		//oModel:SetOnDemand(.T.)

		// Preencho a descri็ใo da entidade
		oModel:GetModel('UF7DETAIL'):SetDescription('Hist๓rico de Reajuste:')
		oModel:GetModel('UF7DETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('UF7DETAIL'):SetNoUpdateLine(.T.)
		oModel:GetModel('UF7DETAIL'):SetNoUpdateLine(.T.)
		oModel:GetModel("UF7DETAIL"):SetNoDeleteLine(.T.)
	endIf

	///////////////////////////  ITENS - VALORES ADICIONAIS  //////////////////////////////

	// Crio o grid
	oModel:AddGrid( 'UJ9DETAIL', 'UF2MASTER', oStruUJ9, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Fa็o o relaciomaneto entre o cabe็alho e os itens
	oModel:SetRelation( 'UJ9DETAIL', { { 'UJ9_FILIAL', 'xFilial( "UJ9" )' } , { 'UJ9_CODIGO', 'UF2_CODIGO' }} , UJ9->(IndexKey(1)) )

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel('UJ9DETAIL'):SetOptional( .T. )

	// Preencho a descri็ใo da entidade
	oModel:GetModel('UJ9DETAIL'):SetDescription('Cobran็as Adicionais:')
	oModel:GetModel('UJ9DETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('UJ9DETAIL'):SetNoUpdateLine(.T.)
	oModel:GetModel("UJ9DETAIL"):SetNoDeleteLine(.T.)

	///////////////////////////  ITENS - PETS  //////////////////////////////

	if lPlanoPet // verifico se esta habilitado no plano pet

		// Crio o grid
		oModel:AddGrid( 'UK2DETAIL', 'UF2MASTER', oStruUK2, /*bLinePre{|oMdlG,nLine,cAcao,cCampo| EditaBenef(oMdlG,nLine,cAcao,cCampo)}*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

		// Fa็o o relaciomaneto entre o cabe็alho e os itens
		oModel:SetRelation( 'UK2DETAIL', { { 'UK2_FILIAL', 'xFilial( "UK2" )' } , { 'UK2_CODIGO', 'UF2_CODIGO' } } , UK2->(IndexKey(1)) )

		//Quando for importacao desobriga o preenchimento de beneficiario
		oModel:GetModel('UK2DETAIL'):SetOptional( .T. )

	endIf

Return(oModel)

*/
/*/{Protheus.doc} ViewDef
Fun็ใo que cria o objeto View
@type function
@version 1.0 
@author Wellington Gon็alves
@since 05/07/2016
/*/
Static Function ViewDef()

	Local cRotApto	:= SuperGetMv("MV_XROTAPT",.F.,"RFUNA034")
	Local lPlanoPet	:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local lExibeSE1	:= SuperGetMV("MV_XEXISE1",.F.,.T.)
	Local lExibeSE3	:= SuperGetMV("MV_XEXISE3",.F.,.T.)
	Local oStruUF2 	:= FWFormStruct(2,'UF2')
	Local oStruUF3 	:= FWFormStruct(2,'UF3')
	Local oStruUF4 	:= FWFormStruct(2,'UF4')
	Local oStruUF9 	:= FWFormStruct(2,'UF9')
	Local oStruUG0 	:= FWFormStruct(2,'UG0')
	Local oStruUJ0 	:= FWFormStruct(2,'UJ0')
	Local oStruSE3  := iif(lExibeSE3,FWFormStruct(2,"SE3"),Nil)
	Local oStruSE1 	:= iif(lExibeSE1,DefStrView("SE1"),Nil)
	Local oStruUF5 	:= FWFormStruct(2,'UF5')
	Local oStruUF7 	:= FWFormStruct(2,'UF7')
	Local oStruUJ9 	:= FWFormStruct(2,'UJ9')
	Local oStruUK2	:= FWFormStruct(2,'UK2')
	Local oModel   	:= FWLoadModel('RFUNA002')
	Local oView		:= Nil

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados serแ utilizado
	oView:SetModel(oModel)

	oView:AddField('VIEW_UF2'		, oStruUF2, 'UF2MASTER') // ENCHOICE - CABAวALHO
	oView:AddGrid('VIEW_UF4'		, oStruUF4, 'UF4DETAIL') // GRID - BENEFICIARIOS

	if lExibeSE1
		oView:AddGrid('VIEW_SE1'		, oStruSE1, 'SE1DETAIL') // GRID - FINANCEIRO
	endIf

	oView:AddGrid('VIEW_UF5'		, oStruUF5, 'UF5DETAIL') // GRID - HISTORICO TRANSFERENCIA
	oView:AddGrid('VIEW_UF3'		, oStruUF3, 'UF3DETAIL') // GRID - PRODUTOS DO PLANO

	if lExibeSE3
		oView:AddGrid('VIEW_SE3'		, oStruSE3, 'SE3DETAIL') // GRID - COMISSAO
	endIf

	if lExibeSE1
		oView:AddGrid('VIEW_UF7'		, oStruUF7, 'UF7DETAIL') // GRID - REAJUSTES
	endIf

	oView:AddGrid('VIEW_UF9'		, oStruUF9, 'UF9DETAIL') // GRID - MENSAGENS
	oView:AddGrid('VIEW_UJ9'		, oStruUJ9, 'UJ9DETAIL') // GRID - COBRANCAS ADICIONAIS

	if lPlanoPet // verifico se esta habilitado no plano pet
		oView:AddGrid('VIEW_UK2'		, oStruUK2, 'UK2DETAIL') // GRID - COBRANCAS ADICIONAIS
	endIf

	oView:AddOtherObject('TOTAIS'	, {|oPanel| CriaTotais(oPanel) } ) // Totalizadores

	If cRotApto == "RFUNA034" //Apto. mod2

		oView:AddGrid('VIEW_UJ0'	, oStruUJ0, 'UJ0DETAIL') // GRID - APONTAMENTOS
	Else
		oView:AddGrid('VIEW_UG0'	, oStruUG0, 'UG0DETAIL') // GRID - APONTAMENTOS
	Endif

	oView:CreateVerticalBox("PANEL_ESQUERDA"		, 100)
	oView:CreateVerticalBox("PANEL_DIREITA"			, 200,,.T.)

	// Crio os Panel's horizontais
	if lPlanoPet
		oView:CreateHorizontalBox('PANEL_STATUS' 	, 6 ,  "PANEL_ESQUERDA")
		oView:CreateHorizontalBox('PANEL_CABECALHO' , 44 , "PANEL_ESQUERDA")
		oView:CreateHorizontalBox('PANEL_ITENS'		, 50 , "PANEL_ESQUERDA")
	else
		oView:CreateHorizontalBox('PANEL_CABECALHO' , 50 , "PANEL_ESQUERDA")
		oView:CreateHorizontalBox('PANEL_ITENS'		, 50 , "PANEL_ESQUERDA")
	endIf

	// Cria Folder na view
	oView:CreateFolder("PASTAS","PANEL_ITENS")
	oView:AddSheet("PASTAS","ABA01","Beneficiแrios do Contrato")
	oView:AddSheet("PASTAS","ABA05","Produtos e Servi็os")
	oView:AddSheet("PASTAS","ABA02","Apontamento de Servi็os")

	if lExibeSE1
		oView:AddSheet("PASTAS","ABA03","Financeiro")
	endIf

	oView:AddSheet("PASTAS","ABA04","Mensagens")
	oView:AddSheet("PASTAS","ABA06","Hist๓rico Transf. Titularidade")

	if lExibeSE3
		oView:AddSheet("PASTAS","ABA07","Comiss๕es do Vendedor")
	endIf

	// ABA BENEFICIมRIOS
	oView:CreateHorizontalBox( 'PANEL_PASTA1_ABA01'			, 100 , /*owner*/, /*lPixel*/, 'PASTAS', 'ABA01')
	oView:CreateFolder('PASTA2', 'PANEL_PASTA1_ABA01')
	oView:AddSheet('PASTA2','ABA_BENEFICIARIOS','Beneficiแrios')

	if lPlanoPet // verifico se esta habilitado no plano pet
		oView:AddSheet('PASTA2','ABA_PET','Pets')
	endIf

	oView:AddSheet('PASTA2','ABA_VALORES_ADICIONAIS','Cobran็as Adicionais')

	oView:CreateHorizontalBox("PANEL_BENEFICIARIOS"			,100,,,"PASTA2","ABA_BENEFICIARIOS")

	if lPlanoPet // verifico se esta habilitado no plano pet
		oView:CreateHorizontalBox("PANEL_PET"			,100,,,"PASTA2","ABA_PET")
	endIf

	oView:CreateHorizontalBox("PANEL_VALORES_ADICIONAIS"	,100,,,"PASTA2","ABA_VALORES_ADICIONAIS")

	// ABA DOS ITENS DO PLANO
	oView:CreateHorizontalBox("PANEL_PRODUTOS"		,100,,,"PASTAS","ABA05")

	// ABA APONTAMENTO DE SERVIวO
	oView:CreateHorizontalBox("PANEL_SERVICOS"	,100,,,"PASTAS","ABA02")

	// ABA FINANCEIRO
	if lExibeSE1
		oView:CreateHorizontalBox("PANEL_FINANCEIRO"	,100,,,"PASTAS","ABA03")
		oView:CreateVerticalBox("PANEL_TITULOS"			,059,"PANEL_FINANCEIRO",,"PASTAS","ABA03")
		oView:CreateVerticalBox("SEPARADOR_FIN"			,002,"PANEL_FINANCEIRO",,"PASTAS","ABA03")
		oView:CreateVerticalBox("PANEL_REAJUSTES"		,039,"PANEL_FINANCEIRO",,"PASTAS","ABA03")
	endIf

	// ABA Mensagens
	oView:CreateHorizontalBox("PANEL_MENSAGENS"		,100,,,"PASTAS","ABA04")

	// ABA HISTำRICO TRANSF. TITULARIDADE
	oView:CreateHorizontalBox("PANEL_HISTTRANSFTIT"	,100,,,"PASTAS","ABA06")

	// ABA COMISSOES
	if lExibeSE3
		oView:CreateHorizontalBox("PANEL_COMISOES"		,100,,,"PASTAS","ABA07")
	endIf

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_UF2' 		, 'PANEL_CABECALHO')
	oView:SetOwnerView('VIEW_UF4' 		, 'PANEL_BENEFICIARIOS')

	if lPlanoPet // verifico se esta habilitado no plano pet
		oView:SetOwnerView('VIEW_UK2' 		, 'PANEL_PET')
	endIf

	oView:SetOwnerView('VIEW_UJ9' 		, 'PANEL_VALORES_ADICIONAIS')

	if lExibeSE1
		oView:SetOwnerView('VIEW_SE1'		, 'PANEL_TITULOS')
	endIf

	oView:SetOwnerView('VIEW_UF5' 		, 'PANEL_HISTTRANSFTIT')
	oView:SetOwnerView('VIEW_UF3' 		, 'PANEL_PRODUTOS')

	if lExibeSE3
		oView:SetOwnerView('VIEW_SE3' 		, 'PANEL_COMISOES')
	endIf

	if lExibeSE1
		oView:SetOwnerView('VIEW_UF7' 		, 'PANEL_REAJUSTES')
	endIf

	oView:SetOwnerView('VIEW_UF9' 		, 'PANEL_MENSAGENS')
	oView:SetOwnerView('TOTAIS' 		, 'PANEL_DIREITA')

	If cRotApto == "RFUNA034" //Apto. mod2
		oView:SetOwnerView('VIEW_UJ0' 		, 'PANEL_SERVICOS')
	Else
		oView:SetOwnerView('VIEW_UG0' 		, 'PANEL_SERVICOS')
	Endif

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_UF2')

	if lExibeSE1
		oView:EnableTitleView('VIEW_SE1')
	endIf

	oView:EnableTitleView('VIEW_UF5')
	oView:EnableTitleView('VIEW_UF3')

	if lExibeSE3
		oView:EnableTitleView('VIEW_SE3')
	endIf

	if lExibeSE1
		oView:EnableTitleView('VIEW_UF7')
	endIf

	oView:EnableTitleView('VIEW_UF9')

	If cRotApto == "RFUNA034" //Apto. mod2
		oView:EnableTitleView('VIEW_UJ0')
	Else
		oView:EnableTitleView('VIEW_UG0')
	Endif

	if lPlanoPet // verifico se esta habilitado no plano pet
		oView:EnableTitleView('VIEW_UK2')
	endIf

	// Define campos que terao Auto Incremento
	oView:AddIncrementField( 'VIEW_UF3', 'UF3_ITEM' )
	oView:AddIncrementField( 'VIEW_UF4', 'UF4_ITEM' )
	oView:AddIncrementField( 'VIEW_UF9', 'UF9_ITEM' )
	oView:AddIncrementField( 'VIEW_UJ9', 'UJ9_ITEM' )

	if lPlanoPet // verifico se esta habilitado no plano pet
		oView:AddIncrementField( 'VIEW_UK2', 'UK2_ITEM' )
	endIf

	oView:SetCloseOnOk({||.T.})

	// Habilito a barra de progresso na abertura da tela
	oView:SetProgressBar(.T.)

	oView:SetViewProperty( "UF2MASTER", "SETLAYOUT", {  FF_LAYOUT_VERT_DESCR_TOP   , 3 , 10 } )

	oView:SetViewProperty("UF2MASTER", "SETCOLUMNSEPARATOR", {90})

	// Inicializo alguns campos
	oView:SetAfterViewActivate({|oView| IniCpoCopia(oView)})

	oView:SetViewAction( 'DELETELINE', { |oView,cIdView,nNumLine| DelGrid( oView,cIdView,nNumLine ) } )
	oView:SetViewAction( 'UNDELETELINE', { |oView,cIdView,nNumLine| UnDelGrid( oView,cIdView,nNumLine ) } )

	//Valida se existe Pe Apos troca de plano
	If ExistBlock("PFUN02PL")

		oView:SetFieldAction('UF2_PLANO' ,  { |oView, cIDView, cField, xValue| ExecBlock("PFUN02PL",.F.,.F.,{xValue}) } )
	Endif

	//Desabilito campo se nao for TRANSFERENCIA DE TITULARIDADE
	If !IsInCallStack("U_RFUNA006")
		oStruUF2:RemoveField('UF2_MTVTRA')
	Endif

	if lPlanoPet // verifico se esta habilitado no plano pet

		oStruUK2:RemoveField("UK2_CODIGO")

		// Cria componentes nao MVC
		oView:AddOtherObject("STATUS", {|oPanel| FUN002PET(oPanel)})
		oView:SetOwnerView("STATUS",'PANEL_STATUS')

	endIf

	//Adiciono botao que consulta forma do valor da parcela
	oView:AddUserButton("Parcelas x Regras","MAGIC_BMP",{|| U_RFUNE38P() },"Parcelas x Regras")

Return(oView)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFUNA002LEGบ Autor ณ Wellington Gon็alves บ Dataณ 05/07/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda do browser de cadastro do contrato de funerแria	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funerแria		                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function FUNA002LEG()

	Local aLegenda := {}

	aAdd(aLegenda, {"BR_BRANCO","Pr้-Cadastro"})
	aAdd(aLegenda, {"BR_VERDE","Ativo"})
	aAdd(aLegenda, {"BR_LARANJA","Suspenso"})
	aAdd(aLegenda, {"BR_AZUL","Cancelado"})
	aAdd(aLegenda, {"BR_VERMELHO","Finalizado"})

	If ExistBlock("PEFUN02BR")
		aLegenda := ExecBlock("PEFUN02BR", .F., .F., { aLegenda })
	EndIf

	BrwLegenda("Status do Contrato","Legenda",aLegenda)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DefStrModel บAutorณWellington Gon็alves บ Dataณ 13/07/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que monta a estrutura do alias no model			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funerแria		                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function DefStrModel(cAlias)

	Local aArea    		:= GetArea()
	Local bValid   		:= { || }
	Local bWhen    		:= { || }
	Local bRelac   		:= { || }
	Local aAux     		:= {}
	Local aCampos		:= {}
	Local oStruct 		:= FWFormModelStruct():New()
	Local oSx			:= UGetSxFile():New
	Local aSX2			:= {}
	Local aSIX			:= {}
	Local aSX3			:= {}
	Local aSX7			:= {}
	Local nX			:= 1

	if cAlias == "SE1"

		aCampos := {"E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","E1_CLIENTE","E1_LOJA","E1_NOMCLI","E1_VENCTO","E1_VALOR","E1_SALDO","E1_EMISSAO",;
			"E1_BAIXA","E1_XUSRBAX","E1_HIST"}
	elseif cAlias == "SC5"

		aCampos	:= {"C5_NUM","C5_EMISSAO","C5_CLIENTE","C5_LOJA","C5_CONDPAG"}
	elseif cAlias == "SC6"

		aCampos	:= {"C6_ITEM","C6_PRODUTO","C6_UM","C6_QTDVEN","C6_PRCVEN","C6_VALOR","C6_NOTA","C6_SERIE"}
	endif

	//--------
	// Tabela
	//--------
	aSX2:= oSX:GetInfoSX2(cAlias)

	oStruct:AddTable(aSX2[1,2]:cCHAVE,StrTokArr(Alltrim(aSX2[1,2]:cUNICO), '+') ,Alltrim(aSX2[1,2]:cNOME))


	aSIX:= oSX:GetInfoSIX(cAlias)
	//---------
	// Indices
	//---------
	nOrdem := 0

	For nX:= 1 to Len(aSIX)

		oStruct:AddIndex(nOrdem++,aSIX[nX,2]:cORDEM,aSIX[nX,2]:cCHAVE,SIXDescricao(),aSIX[nX,2]:cF3,aSIX[nX,2]:cNICKNAME ,(aSIX[nX,2]:cSHOWPESQ <> 'N'))

	Next nX

	//--------
	// Campos
	//--------

	if cAlias == "SE1"
		bRelac := {|A,B,C| FWINITCPO(A,B,C),XRET:=(IIF(SE1->E1_SALDO <> 0,IIF(SE1->E1_VALOR > SE1->E1_SALDO .And. SE1->E1_SALDO > 0 ,"BR_AZUL","BR_VERDE"),"BR_VERMELHO")),FWCLOSECPO(A,B,C,.T.),FWSETVARMEM(A,B,XRET),XRET }
		oStruct:AddField('','','STATUS','C',11,0,,,{},.F.,bRelac,,,.T.)
	endif

	For nX := 1 To Len(aCampos)

		aSX3:= oSX:GetInfoSX3(,aCampos[nX])

		If Len(aSX3) > 0

			bValid 	:= FwBuildFeature( 1, aSX3[1,2]:cVALID   )
			bWhen  	:= FwBuildFeature( 2, aSX3[1,2]:cWHEN    )
			bRelac 	:= FwBuildFeature( 3, aSX3[1,2]:cRELACAO )

			aBox	:= StrTokArr(AllTrim(aSX3[1,2]:cCBOX),';' )

			oStruct:AddField( 			;
				AllTrim(aSX3[1,2]:cTITULO), ;	// [01] Titulo do campo
			AllTrim(aSX3[1,2]:cDESCRI), ;	// [02] ToolTip do campo
			aSX3[1,2]:cCAMPO,	 		;	// [03] Id do Field
			aSX3[1,2]:cTIPO, 			;	// [04] Tipo do campo
			aSX3[1,2]:nTAMANHO,			;	// [05] Tamanho do campo
			aSX3[1,2]:nDECIMAL,			;	// [06] Decimal do campo
			bValid, 					;	// [07] Code-block de valida?o do campo
			bWhen, 						;	// [08] Code-block de valida?o When do campo
			aBox, 						;	// [09] Lista de valores permitido do campo
			.F., 						;	// [10] Indica se o campo tem preenchimento obrigat?io
			bRelac, 					;	// [11] Code-block de inicializacao do campo
			NIL, 						;	// [12] Indica se trata-se de um campo chave
			NIL, 						;	// [13] Indica se o campo pode receber valor em uma opera?o de update.
			(aSX3[1,2]:cCONTEXT == 'V'))// [14] Indica se o campo ?virtual

		Endif

	Next nX

	//----------
	// Gatilhos
	//----------
	For nX := 1 To Len(aCampos)

		aSX7 := oSX:GetInfoSX7(aCampos[nX])

		if Len(aSX7)>0

			aAux :=	FwStruTrigger(aSX7[1,2]:cCAMPO,aSX7[1,2]:cCDOMIN,aSX7[1,2]:cREGRA,aSX7[1,2]:cSEEK=='S',aSX7[1,2]:cALIAS,aSX7[1,2]:cORDEM,aSX7[1,2]:cCHAVE,aSX7[1,2]:cCONDIC,aSX7[1,2]:cSEQUENC)
			oStruct:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

		endif

	Next nX

	RestArea( aArea )

Return oStruct

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DefStrView บAutorณ Wellington Gon็alves บ Dataณ 13/07/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que monta a estrutura do alias na view			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funerแria		                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function DefStrView(cAlias)

	Local aArea     	:= GetArea()
	Local oStruct   	:= FWFormViewStruct():New()
	Local aCombo    	:= {}
	Local nInitCBox 	:= 0
	Local nMaxLenCb 	:= 0
	Local aAux      	:= {}
	Local nI        	:= 1
	Local nX			:= 1
	Local cGSC      	:= ''
	Local oSX			:= UGetSxFile():New
	Local aSX3			:= {}
	Local aSXA			:= {}

	if cAlias == "SE1"

		aCampos := {"E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","E1_CLIENTE","E1_LOJA","E1_NOMCLI","E1_VENCTO","E1_VALOR","E1_SALDO","E1_EMISSAO",;
			"E1_BAIXA","E1_XUSRBAX","E1_HIST"}
	elseif cAlias == "SC5"

		aCampos	:= {"C5_NUM","C5_EMISSAO","C5_CLIENTE","C5_LOJA","C5_CONDPAG"}
	elseif cAlias == "SC6"

		aCampos	:= {"C6_ITEM","C6_PRODUTO","C6_UM","C6_QTDVEN","C6_PRCVEN","C6_VALOR","C6_NOTA","C6_SERIE"}
	endif

	//--------
	// Campos
	//--------

	if cAlias == "SE1"
		oStruct:AddField('STATUS',"01",'','',NIL,'GET','@BMP',,'',.F.,'','',{},1,'BR_VERDE',.T.)
	endif

	For nX := 1 To Len(aCampos)


		aSX3:= oSX:GetInfoSX3(,aCampos[nX])

		If Len(aSX3) > 0

			aCombo := {}

			If !Empty(aSX3[1,2]:cCBOX)

				nInitCBox := 0
				nMaxLenCb := 0

				aAux := RetSX3Box( aSX3[1,2]:cCBOX , @nInitCBox, @nMaxLenCb,aSX3[1,2]:nTAMANHO )

				For nI := 1 To Len(aAux)
					aAdd( aCombo, aAux[nI][1] )
				Next nI

			EndIf

			bPictVar := FwBuildFeature( 4, aSX3[1,2]:cPICTVAR )
			cGSC     := IIf( Empty(aSX3[1,2]:cCBOX) , IIf( aSX3[1,2]:cTIPO == 'L', 'CHECK', 'GET' ) , 'COMBO' )

			oStruct:AddField( 			;
				aSX3[1,2]:cCAMPO, 			;	// [01] Campo
			aSX3[1,2]:cORDEM,			;	// [02] Ordem
			AllTrim(aSX3[1,2]:cTITULO),	;	// [03] Titulo
			AllTrim(aSX3[1,2]:cDESCRI), 		;	// [04] Descricao
			NIL, 						;	// [05] Help
			cGSC, 						;	// [06] Tipo do campo   COMBO, Get ou CHECK
			aSX3[1,2]:cPICTURE,			;	// [07] Picture
			bPictVar, 					;	// [08] PictVar
			aSX3[1,2]:cF3, 				;	// [09] F3
			aSX3[1,2]:cVISUAL <> 'V', 	;	// [10] Editavel
			aSX3[1,2]:cFOLDER, 			;	// [11] Folder
			aSX3[1,2]:cFOLDER, 			;	// [12] Group
			aCombo,						;	// [13] Lista Combo
			nMaxLenCb, 					;	// [14] Tam Max Combo
			aSX3[1,2]:cINIBRW, 			;	// [15] Inic. Browse
			(aSX3[1,2]:cCONTEXT == 'V'))   	// [16] Virtual

		EndIf

	Next nX

	//---------
	// Folders
	//---------

	aSXA:= oSX:GetInfoSXA(cAlias)

	For nX:= 1 To Len(aSXA)

		oStruct:AddFolder(aSXA[nX,2]:cORDEM,aSXA[nX,2]:cDESCRIC)

	Next nX

	RestArea(aArea)

Return oStruct

/*/{Protheus.doc} VlPlanFun
Fun็ใo chamada na valida็ใo do plano	
@type function
@version 1.0 
@author Wellington Gon็alves
@since 13/07/2016
@return logical, retorno da validacao do plano
/*/
User Function VlPlanFun()

	Local lRet			:= .T.
	Local lChangePlan	:= .F.
	Local aArea			:= GetArea()
	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUF2 	:= oModel:GetModel("UF2MASTER")
	Local oModelUF3 	:= oModel:GetModel("UF3DETAIL")
	Local oModelUF4		:= oModel:GetModel("UF4DETAIL")
	Local oModelUK2		:= Nil
	Local aSaveLines  	:= FWSaveRows()
	Local nOperation 	:= oModel:GetOperation()
	Local nPrecoItem	:= 0
	Local nValorCtr		:= 0
	Local nVlrAgreg		:= 0
	Local nDesconBkp	:= 0
	Local lPersonFun	:= SuperGetMv("MV_XPERFUN",.F.,.F.)
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local lRecalcImp 	:= SuperGetMV("MV_XFRCIMP", .F., .T.)
	Local nVlrLiq		:= 0
	Local nVlrPFUN2VLR  := 0

	//permito a exclusao das linhas da grid, depois restauro as propriedades originais
	oModel:GetModel('UF3DETAIL'):SetNoInsertLine(.F.)
	oModel:GetModel('UF3DETAIL'):SetNoUpdateLine(.F.)
	oModel:GetModel('UF3DETAIL'):SetNoUpdateLine(.F.)
	oModel:GetModel("UF3DETAIL"):SetNoDeleteLine(.F.)

	if lPlanoPet
		oModelUK2 := oModel:GetModel("UK2DETAIL")
	endIf

	// caso estiver usando plano pet
	if lPlanoPet .And. !Empty(oModelUF2:GetValue("UF2_CLIENT"))
		U_ValCliInf(oModelUF2:GetValue("UF2_CODIGO"))
	endIf

	// se a opera็ใo for inclusใo, limpo o grid, senใo deleto todas as linhas
	if nOperation == MODEL_OPERATION_INSERT

		// fun็ใo que limpa o grid
		U_LimpaAcolsMVC(oModelUF3,oView)
	else
		//se for alteracao valida se tem titulo vencido
		if nOperation == 4

			//se nao contrato nao estiver ativado
			if UF2->UF2_STATUS <> 'P'

				//Valido se o contrato esta adimplente
				lRet := U_VlContra(oModelUF2:GetValue("UF2_CODIGO"),"F",UF2->UF2_MSFIL)

				//Se esta Com titulos vencidos nao permite continuar
				if !lRet
					Return lRet
				Endif
			endif

			// fun็ใo que deleta todas as linhas do grid
			oModelUF3:DelAllLine()
		endif

	endif

	//verifico se o plano existe
	UF0->(DbSetOrder(1)) // UF0_FILIAL+UF0_CODIGO
	If UF0->(MsSeek(xFilial("UF0") + oModelUF2:GetValue("UF2_PLANO") ) )

		//Verifica como sera cobrada a adesao
		cAdesIgualPar := UF0->UF0_ADPARC

		If UF0->UF0_STATUS == "I" //Inativo

			Help(,,'Help',,"O plano digitado se encontra inativo.",1,0)
			lRet := .F.

		elseif (!Empty(UF0->UF0_DTINI) .And. UF0->UF0_DTINI > dDatabase) .Or. (!Empty(UF0->UF0_DTFIM) .And. UF0->UF0_DTFIM < dDatabase)

			Help(,,'Help',,"O plano digitado se encontra fora de vig๊ncia!.",1,0)
			lRet := .F.

		endif

		if lRet .And. lPlanoPet

			if lRet .And. nOperation == 4 .And. lPlanoPet

				if UF0->UF0_USO == "2" .And. UF2->UF2_USO $ "1|3" .And. !Empty(oModelUK2:GetValue("UK2_NOME"))
					Help(,,'Help',,"O plano digitado tem o uso para Humano, o contrato que estแ sendo alterado tem informa็๕es de Pet cadastradas!.",1,0)
					lRet := .F.
				endIf

			endIf

			// caso seja plano ambos ou pet
			if lRet .And. UF0->UF0_USO $ "1|3"

				oModelUK2 := oModel:GetModel("UK2DETAIL")

				oModelUK2:SetNoInsertLine(.F.)
				oModelUK2:SetNoUpdateLine(.F.)
				oModelUK2:SetNoDeleteLine(.F.)

			endIf

		endIf

	else

		Help(,,'Help',,"O plano invแlido, favor verifique o c๓digo digitado!",1,0)
		lRet := .F.

	Endif

	UF1->(DbSetOrder(1)) // UF1_FILIAL + UF1_CODIGO
	If lRet .And. UF1->(DbSeek(xFilial("UF1") + oModelUF2:GetValue("UF2_PLANO")))

		//verifico a tabela de preco do produto, caso a personalizacao esteja ativa
		if lPersonFun

			//valido se a tabela de preco padrao existe na base de dados
			DA0->(DbSetOrder(1)) // DA0_FILIAL + DA0_CODTAB
			if !Empty(UF0->UF0_TABPRE) .And. DA0->(DbSeek(xFilial("DA0")+UF0->UF0_TABPRE))

				//verifico a validade da tabela de preco
				if !(DA0->DA0_DATDE <= dDatabase .And. (Empty(DA0->DA0_DATATE) .Or. DA0->DA0_DATATE >= dDatabase))

					Help(,,'Help',,"Tabela de Pre็o padrใo para os itens nใo se encontra vigente, verifique o cadastro da tabela: " + UF0->UF0_TABPRE + "! ",1,0)
					lRet := .F.

				endif

			else

				Help(,,'Help',,"Tabela de Pre็o dos Itens do Plano nใo encontrada, Favor verifique o cadastro!",1,0)
				lRet := .F.

			endif

		endif

		//se possui tabela de preco dos itens, continua a inclusao dos produtos
		if lRet

			While UF1->(!Eof()) .AND. UF1->UF1_FILIAL == xFilial("UF1") .AND. UF1->UF1_CODIGO == oModelUF2:GetValue("UF2_PLANO")

				SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD

				if SB1->(DbSeek(xFilial("SB1")+UF1->UF1_PROD))

					//valido se a personalizacao de planos esta ativa
					if lPersonFun .And. ( nPrecoItem := RetPrecoVenda(UF0->UF0_TABPRE,UF1->UF1_PROD) ) == 0

						Help( ,, 'Help',, 'O Produto/Servico: '+ Alltrim(UF1->UF1_PROD) +' nใo possui pre็o vigente na tabela: ' +Alltrim(UF0->UF0_TABPRE)+'', 1, 0 )

						lRet := .F.
						Exit

					endif

					If !IsInCallStack("U_RUTILE26") //Se nใo for integra็ใo Mobile

						//Se a primeira linha nใo estiver em branco, insiro uma nova linha
						nQtdLinAntes := oModelUF3:Length()
						If !Empty(oModelUF3:GetValue("UF3_PROD"))

							nQtdLinApos := oModelUF3:AddLine()

							if nQtdLinApos == nQtdLinAntes

								Help(,,'Help',,"Ocorreu um problemana inclusใo os itens do plano!",1,0)
								lRet := .F.
								Exit
							else

								oModelUF3:GoLine(oModelUF3:Length())
							endif

						Endif

						oModelUF3:LoadValue("UF3_ITEM" 		,	StrZero( oModelUF3:Length(),TamSX3("UF3_ITEM")[1] ) )
						oModelUF3:LoadValue("UF3_TIPO"		,	"AVGBOX1.PNG")
						oModelUF3:LoadValue("UF3_PROD" 		,	UF1->UF1_PROD)
						oModelUF3:LoadValue("UF3_DESC"		,	Posicione("SB1",1,xFilial("SB1") + UF1->UF1_PROD,"B1_DESC"))
						oModelUF3:LoadValue("UF3_VLRUNI"	,	nPrecoItem)
						oModelUF3:LoadValue("UF3_QUANT"		,	UF1->UF1_QUANT)
						oModelUF3:LoadValue("UF3_VLRTOT"	,	nPrecoItem * UF1->UF1_QUANT)
						oModelUF3:LoadValue("UF3_SALDO"		,	UF1->UF1_QUANT)
						oModelUF3:LoadValue("UF3_CTRSLD"	,	If(!Empty(SB1->B1_XDEBPRE),SB1->B1_XDEBPRE,'N'))

						if lPlanoPet
							oModelUF3:LoadValue("UF3_USOSRV"	,	Posicione("SB1",1,xFilial("SB1") + UF1->UF1_PROD, "B1_XUSOSRV"))
						endIf

					Endif

					nValorCtr += nPrecoItem * UF1->UF1_QUANT

				else

					lRet := .F.
					Help(,,'Help',,"Produto: " + Alltrim(oModelUF3:GetValue("UF3_PROD")) + " nใo encontrado no cadastro de produtos!",1,0)
					Exit

				endif

				UF1->(DbSkip())

			EndDo

		endif

		// fun็ใo que verifica se existem cobran็as adicionais
		if oView <> Nil

			//verifico se houve mudanca de plano, se houver sera necessario reprocessar as idades e retirar os valores de reajustes
			if lRet .And. nOperation == MODEL_OPERATION_UPDATE .And. oModelUF2:GetValue("UF2_STATUS") <> 'P' .And. UF2->UF2_PLANO <> oModelUF2:GetValue("UF2_PLANO")

				cPlanoBkp	:= UF2->UF2_PLANO
				nReajBkp	:= UF2->UF2_VLADIC
				nDesconBkp	:= UF2->UF2_DESCON
				lChangePlan	:= .T.

				//elimino o valor de reajuste
				oModelUF2:SetValue("UF2_VLADIC",0)
				oModelUF2:SetValue("UF2_DESCON",0)
				M->UF2_VLADIC := 0
				M->UF2_DESCON := 0

				//caso tenha voltado o plano original, restauro o valor de reajuste do contrato
			elseif lRet .And. nOperation == MODEL_OPERATION_UPDATE .And. cPlanoBkp == oModelUF2:GetValue("UF2_PLANO")

				oModelUF2:SetValue("UF2_VLADIC",nReajBkp)
				oModelUF2:SetValue("UF2_DESCON",nDesconBkp)
				M->UF2_VLADIC := nReajBkp
				M->UF2_DESCON := nDesconBkp

			endif


			FWMsgRun(,{|oSay| RefreshUJ9(lChangePlan)},'Aguarde...','Consultando Cobran็as Adicionais...')

		else

			RefreshUJ9()

		endif

	endif

	//se a personalizacao de contrato estiver ativa, a composicao do contrato sera a soma dos itens
	if lPersonFun

		nVlrLiq := (nValorCtr + oModelUF2:GetValue("UF2_VLCOB") ) - oModelUF2:GetValue("UF2_DESCON")

		//-- Ponto Entrada para atualiza็ใo do valor lํquido do contrato --//
		If nOperation == MODEL_OPERATION_UPDATE
			If ExistBlock("PFUN2VLR")
				nVlrPFUN2VLR := ExecBlock("PFUN2VLR", .F., .F., { nVlrLiq })
				If ValType(nVlrPFUN2VLR) == "N"
					If nVlrPFUN2VLR > 0
						nVlrLiq := nVlrPFUN2VLR
					EndIf
				EndIf
			EndIf
		EndIf

		if IsInCallStack("U_RIMPM003") // para importacao do cabecalho do contrato
			if lRecalcImp
				oModelUF2:LoadValue("UF2_VLRBRU"	, nValorCtr)
				oModelUF2:LoadValue("UF2_VLSERV"	, 0)
				oModelUF2:LoadValue("UF2_VALOR"		, nVlrLiq )
			endIf
		else
			oModelUF2:LoadValue("UF2_VLRBRU"	, nValorCtr)
			oModelUF2:LoadValue("UF2_VLSERV"	, 0)
			oModelUF2:LoadValue("UF2_VALOR"		, nVlrLiq )
		endIf

		//Valido se adesao sera o valor da parcerla
		If cAdesIgualPar == "S"
			oModelUF2:LoadValue( "UF2_ADESAO", oModelUF2:GetValue("UF2_VALOR"))
		endif

		// caso utilizo o plano pet
		if lRet .And. lPlanoPet

			if UF0->UF0_USO == "3" // uso apenas pet

				// fun็ใo que limpa o grid
				U_LimpaAcolsMVC(oModelUF4,oView)

				// desabilito a inclusao, exclusao ou atulizacao da grid de beneficiarios
				oModelUF4:SetNoInsertLine(.T.)
				oModelUF4:SetNoUpdateLine(.T.)
				oModelUF4:SetNoDeleteLine(.T.)

			else

				// desabilito a inclusao, exclusao ou atulizacao da grid de beneficiarios
				oModelUF4:SetNoInsertLine(.F.)
				oModelUF4:SetNoUpdateLine(.F.)
				oModelUF4:SetNoDeleteLine(.F.)

			endIf

			// preencho o campo uso do plano
			oModelUF2:LoadValue("UF2_USO", UF0->UF0_USO)

		endIf


	else

		//bloqueio a grid de itens caso a personalizacao nao esteja ativa, se estiver nao e necessario
		oModel:GetModel('UF3DETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('UF3DETAIL'):SetNoUpdateLine(.T.)
		oModel:GetModel("UF3DETAIL"):SetNoDeleteLine(.T.)

	endif

	if lRet

		// posiciono na primeira linha
		oModelUF3:GoLine(1)

		if oView <> Nil

			// chamo fun็ใo que atualiza os valores do contrato
			oTotais:RefreshTot()

			if lPlanoPet
				oStatus:RefreshStatus()
			endIf

		endif

	endif

	RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ UBtnPed  บ Autorณ Wellington Gon็alves บ Data ณ 15/07/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para cria็ใo do botใo para visualizar os pedidos	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funerแria		                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function UBtnPed(oPanel)

	Local nHeigth	:= oPanel:nClientHeight / 2
	Local nWidth	:= oPanel:nClientWidth / 2
	Local nAltBtn	:= 60
	Local nLargBtn	:= 15
	Local oModel	:= FWModelActive()
	Local oModelSC5 := oModel:GetModel("SC5DETAIL")

	@ nHeigth - ( nLargBtn + 2 ) , nWidth - ( nAltBtn + 2 ) BUTTON oButton1 PROMPT "Visualizar Pedido" SIZE nAltBtn , nLargBtn OF oPanel ACTION (ShowPedido(oModelSC5:GetValue("C5_NUM"))) PIXEL

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ShowPedido บ AutorณWellington Gon็alves บ Dataณ 15/07/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que visualiza o pedido de venda					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funerแria		                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ShowPedido(cPedido)

	Local nRecno	:= 0
	Local aArea		:= GetArea()
	Local aAreaSC5	:= SC5->(GetArea())
	Private aRotina	:= {{ "","AxPesqui", 0 , 1},{ "","A410Visual", 0 , 2} }

	// se o pedido de venda estiver preenchido
	if !Empty(cPedido)

		SC5->(DbSetOrder(1))
		if SC5->(DbSeek(xFilial("SC5") + cPedido))

			// abro a visualiza็ใo do pedido de venda
			a410Visual("SC5",SC5->(RECNO()),2)

		else
			MsgAlert("Pedido invแlido!")
		endif

	else
		MsgAlert("Selecione o pedido de venda!")
	endif

	RestArea(aAreaSC5)
	RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ UCarenFun บ Autor ณWellington Gon็alves บ Dataณ 20/09/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo atualiza a data de car๊ncia do contrato e dos		  บฑฑ
ฑฑ		     ณ seus beneficiแrios										  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funerแria		                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function UCarenFun()

	Local lRet 		:= .T.
	Local aArea		:= GetArea()
	Local oModel	:= FWModelActive()
	Local oView		:= FWViewActive()
	Local oModelUF2 := oModel:GetModel("UF2MASTER")
	Local oModelUF4 := oModel:GetModel("UF4DETAIL")
	Local cRegra	:= FWFldGet("UF2_REGRA")
	Local nX 		:= 1
	Local cTpAgreg	:= "2"
	Local cTpPortab	:= "2"
	Local cTipoBen	:= ""

	Local aCarencia	:= {}

	// se o contrato for de portabilidade
	// a data de car๊ncia ้ a mesma data do contrato
	if oModelUF2:GetValue('UF2_PORTAB') == cTpPortab

		oModelUF2:LoadValue('UF2_CARENC' , oModelUF2:GetValue('UF2_DATA'))

	endif

	For nX := 1 To oModelUF4:Length()

		// posiciono na linha atual
		oModelUF4:Goline(nX)

		// se a linha nใo estiver em branco
		if !Empty(oModelUF4:GetValue('UF4_DTINC'))

			// se a data do contrato for maior que a data de inclusao do associado
			if oModelUF2:GetValue('UF2_DATA') > oModelUF4:GetValue('UF4_DTINC')
				oModelUF4:LoadValue('UF4_DTINC' , oModelUF2:GetValue('UF2_DATA'))
			endif

			// se o contrato for de portabilidade
			// a data de car๊ncia ้ a mesma data do contrato
			if oModelUF2:GetValue('UF2_PORTAB') == cTpPortab
				oModelUF4:LoadValue('UF4_CAREN' , oModelUF2:GetValue('UF2_DATA'))
			else

				//Valido se a regra utilizada sera a regra geral do plano
				//ou tem uma especifica para beneficiario
				if !Empty(oModelUF4:GetValue('UF4_REGRA'))
					cRegra := oModelUF4:GetValue('UF4_REGRA')
				Endif

				// verfico o tipo de beneficiario
				If FWFldGet("UF4_TIPO") == "1" // para benificario
					cTipoBen := "A/B"
				ElseIf FWFldGet("UF4_TIPO") == "2" // para agregado
					cTipoBen := "A/G"
				ElseIf FWFldGet("UF4_TIPO") == "3" // para titular
					cTipoBen := "A/T"
				EndIf

				//cContrato,cRegra,dDtRef,cPara,cCodBen,nIdadeBen
				aCarencia := U_RetCaren(FWFldGet("UF2_CODIGO"),;
					cRegra,;
					FWFldGet("UF4_DTINC"),;
					cTipoBen,;
					FWFldGet("UF4_ITEM"),;
					FWFldGet("UF4_IDADE"))

				If Len(aCarencia) == 2 //Obteve dados de car๊ncia

					If !Empty(aCarencia[1])
						oModelUF4:LoadValue('UF4_CAREN' , aCarencia[1])
					Else
						oModelUF4:LoadValue('UF4_CAREN' , dDataBase)
					Endif

					oModelUF4:LoadValue('UF4_ITREGC' , aCarencia[2])
				Endif
			endif

			If oView <> NIL
				oView:Refresh()
			EndIf

		endif

	Next nX

	// posiciono na primeira linha
	oModelUF4:GoLine(1)

	If oView <> nil
		oView:Refresh()
	EndIf

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} CarBenFun
Fun็ใo chamada na valida็ใo da data de inclusใo do 
beneficiแrio, para atualizar a data de car๊ncia.	
@type function
@version 1.0
@author Wellington Gon็alves
@since 22/09/2016
@return logical, retorno sobre as validacoes da rotina
/*/
User Function CarBenFun()

	Local aArea			:= GetArea()
	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUF2 	:= oModel:GetModel("UF2MASTER")
	Local oModelUF4 	:= oModel:GetModel("UF4DETAIL")
	Local cRegra		:= FWFldGet("UF2_REGRA")
	Local cTipoBen		:= ""
	Local aCarencia		:= {}
	Local nOperation 	:= oModel:GetOperation()
	Local lContinua		:= .T.
	Local lRetorno		:= .T.
	Local lRecalcImp 	:= SuperGetMV("MV_XFRCIMP", .F., .T.)

	//valido a data de nascimento preenchida
	if !Empty(FWFldGet("UF4_DTNASC")) .And. FWFldGet("UF4_DTNASC") > dDataBase

		lRetorno := .F.
		Help(,,'Help',,"Data de Nascimento nao pode ser superior a data atual",1,0)

	endif

	if lRetorno

		//Valido se ้ portabilidade e ้ inclusao, pois nao pode ter carencia
		If oModelUF2:GetValue("UF2_PORTAB") == "2" .AND. nOperation == 3
			lContinua	:= .F.
		Endif

		If lContinua

			//Valido se existe uma regra mais especifica para o beneficiario
			if !Empty(FWFldGet("UF4_REGRA"))
				cRegra := FWFldGet("UF4_REGRA")
			Endif

			// verfico o tipo de beneficiario
			If FWFldGet("UF4_TIPO") == "1" // para benificario
				cTipoBen := "A/B"
			ElseIf FWFldGet("UF4_TIPO") == "2" // para agregado
				cTipoBen := "A/G"
			ElseIf FWFldGet("UF4_TIPO") == "3" // para titular
				cTipoBen := "A/T"
			EndIf

			aCarencia := U_RetCaren(FWFldGet("UF2_CODIGO"),;
				cRegra,;
				FWFldGet("UF4_DTINC"),;
				cTipoBen,;
				FWFldGet("UF4_ITEM"),;
				U_UAgeCalculate(FWFldGet("UF4_DTNASC"),dDataBase))

			If Len(aCarencia) == 2 //Obteve dados de car๊ncia

				If !Empty(aCarencia[1])
					oModelUF4:LoadValue('UF4_CAREN' , aCarencia[1])
				Else
					oModelUF4:LoadValue('UF4_CAREN' , dDataBase)
				Endif

				oModelUF4:LoadValue('UF4_ITREGC' , aCarencia[2])

			Endif
		Else

			oModelUF4:LoadValue('UF4_CAREN' , dDataBase)

		Endif

		//calculo a idade do beneficario
		if !Empty(FWFldGet("UF4_DTNASC"))

			oModelUF4:LoadValue('UF4_IDADE' , U_UAgeCalculate(FWFldGet("UF4_DTNASC"),dDataBase))

		endif

		//atualizo valor total do contrato
		if IsInCallStack("U_RIMPM003")
			if lRecalcImp
				// fun็ใo que verifica se existem cobran็as adicionais
				FWMsgRun(,{|oSay| RefreshUJ9()},'Aguarde...','Consultando Cobran็as Adicionais...')

				CalcVlrLiq()
			endIf
		else

			// fun็ใo que verifica se existem cobran็as adicionais
			FWMsgRun(,{|oSay| RefreshUJ9()},'Aguarde...','Consultando Cobran็as Adicionais...')

			CalcVlrLiq()
		endIf

	endif

	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} IncTitBen
Fun็ใo para incluir o titular do Contrato como um
beneficiแrio
@type function
@version 1.0  
@author TOTVS
@since 21/09/2016
@param cTit, character, codigo do titular
@param cLojaTit, character, codigo da loja do titular
@return logical, retorno logico do uso da funcao
/*/
User Function IncTitBen(cTit,cLojaTit)

	Local aArea			:= GetArea()
	Local aAreaSA1		:= SA1->(GetArea())
	Local lRet 			:= .T.
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local lContinua		:= .T.
	Local lRecalcImp 	:= SuperGetMV("MV_XFRCIMP", .F., .T.)
	Local lCalcCarencia	:= SuperGetMV("MV_XCALCTT", .F., .T.) // Calcula Carencia na Transferencia de Titularidade
	Local dCarenciaTit	:= dDatabase
	Local nX			:= 1
	Local nI			:= 0
	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUF2 	:= oModel:GetModel("UF2MASTER")
	Local oModelUF4 	:= oModel:GetModel("UF4DETAIL")
	Local nOperation 	:= oModel:GetOperation()
	Local cGrauPar		:= "OU" //Outros
	Local cTpBen		:= "3" //Titular

	if lPlanoPet

		// nao incluso beneficiarios caso o plano for de uso pet
		if oModelUF2:GetValue("UF2_USO") == "3" // pet
			lContinua := .F.
		endIf

	endIf

	If lContinua .And. !Empty(cTit) .And. !Empty(cLojaTit)

		// se a opera็ใo for inclusใo, limpo o grid, senใo deleto todas as linhas
		if nOperation == MODEL_OPERATION_INSERT

			If !IsInCallStack("U_RFUNE028")

				// fun็ใo que limpa o grid
				U_LimpaAcolsMVC(oModelUF4,oView)

			endIf

		else
			//Valido se ้ chamado da transferenciIFa de titularidade
			if IsInCallStack("U_RFUNA006")

				Alert("Se o novo Titular for um beneficiario do plano ele deverแ " + CRLF +" ser removido para nใo haver duplicidade !","Aten็ใo")

				//Se trocou o titular
				If UF2->UF2_CLIENT != oModelUF2:GetValue("UF2_CLIENT")

					//Troco o tipo do titular atual para beneficiario para acrescentar o novo titular
					For nX := 1 to oModelUF4:Length()

						// posiciono na linha atual
						oModelUF4:Goline(nX)

						if !oModelUF4:IsDeleted()

							//Valido se o tipo ้ titular
							If oModelUF4:GetValue("UF4_TIPO") == "3"//Titular

								//Valido se ja foi trocado cliente antes sem confirmar
								if nLinNewTit == nX

									oModelUF4:DeleteLine()
								Else

									//Valido se ja tentou incluir outro cliente antes
									oModelUF4:LoadValue("UF4_TIPO","1") //Beneficiario
								Endif

								//se a carencia do titular atual ja estiver vencida, atribui a data atual de carencia
								//pra o novo titular, senao atribui a carencia do titular atual para o novo.
								if oModelUF4:GetValue("UF4_CAREN") > dDatabase

									dCarenciaTit := oModelUF4:GetValue("UF4_CAREN")

								endif

								Exit

							Endif

							oView:Refresh("UF4DETAIL")
						Endif
					Next nX
				Endif
			Else

				// fun็ใo que deleta todas as linhas do grid
				oModelUF4:DelAllLine()
			Endif
		endif


		if lContinua

			//Se a primeira linha nใo estiver em branco, insiro uma nova linha
			If !Empty(oModelUF4:GetValue("UF4_TIPO"))

				oModelUF4:AddLine()
				oModelUF4:GoLine(oModelUF4:Length())
			Endif

			//Para importacao, foi necessario incluir o preenchimento do campo de Item, pois
			//nao estava permitindo incluir nova linha na GRID sem o prenchimento deste campo.
			//apesar do metodo que define campos que terao Auto Incremento oView:AddIncrementField( 'VIEW_UF3', 'UF3_ITEM' )
			//esta definido para este campo.

			If Type("lImp") == 'L' .And. lImp

				oModelUF4:LoadValue("UF4_ITEM" 	, StrZero( oModelUF4:Length(),TamSX3("UF4_ITEM")[1] ) )

			EndIf

			oModelUF4:LoadValue("UF4_GRAU"		, cGrauPar)
			oModelUF4:LoadValue("UF4_TIPO"		, cTpBen)

			//posiciono no cliente
			SA1->(DbSetorder(1))
			if SA1->(DbSeek(xFilial("SA1")+cTit+cLojaTit))

				//valida se data de nascimento esta preenchida
				if !Empty(SA1->A1_XDTNASC)

					oModelUF4:LoadValue("UF4_DTNASC",SA1->A1_XDTNASC)
					oModelUF4:LoadValue("UF4_IDADE",U_UAgeCalculate(SA1->A1_XDTNASC,dDataBase))
				Endif

				//Carregando dados do titular na grid beneficiarios
				oModelUF4:LoadValue("UF4_CLIENT"	, cTit)
				oModelUF4:LoadValue("UF4_LOJA"		, cLojaTit)
				oModelUF4:LoadValue("UF4_NOMCLI"	, SA1->A1_NOME		)
				oModelUF4:LoadValue("UF4_NOME"		, SA1->A1_NOME 		)
				oModelUF4:LoadValue("UF4_SEXO"		, SA1->A1_XSEXO		)
				oModelUF4:LoadValue("UF4_CPF"		, SA1->A1_CGC		)
				oModelUF4:LoadValue("UF4_ESTCIV"	, SA1->A1_XESTCIV	)

				//preencho a data de inclusao se o plano estive preenchido
				if !Empty(oModelUF2:GetValue("UF2_PLANO"))
					oModelUF4:LoadValue("UF4_DTINC"		, dDatabase			)
				endif

				//Se for mudanca de titular
				if IsInCallStack("U_RFUNA006")

					//guardo a linha do novo cliente incluido para poder deletar
					//caso o usuario mude novamente o cliente antes de confirmar
					nLinNewTit := oModelUF4:Length()

				Endif

				//valido se calculo a carencia do titular na transferencia de titularidade
				if !IsInCallStack("U_RFUNA006") .Or. lCalcCarencia
					//chamo funcao para carregar UF4_CAREN
					U_CarBenFun()
				else
					oModelUF4:LoadValue("UF4_CAREN"		, dCarenciaTit			)
				endif

				//chamo a funcao para atualizar valores adicionais
				if !Empty(SA1->A1_XDTNASC)

					//Chamo funcao para atualizar totalzadores
					if IsInCallStack("U_RIMPM003")

						if lRecalcImp

							RefreshUJ9()

							//atualizo valor total do contrato
							CalcVlrLiq()

						endIf

					else

						RefreshUJ9()

						//atualizo valor total do contrato
						CalcVlrLiq()
					endIf

				endif

			endif

			// posiciono na primeira linha
			oModelUF4:GoLine(1)

		endIf

	Endif

	RestArea(aAreaSA1)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} EditaBenef
funcao para validar a edicao do beneficiario
@type function
@version 1.0 
@author g.sampaio
@since 28/07/2021
@param oModelGrid, object, modelo de dados da grid
@param nLinha, numeric, numero da linha
@param cAcao, character, acao executada
@param cCampo, character, campo que esta sendo alterado
/*/
Static Function EditaBenef(oModelGrid,nLinha,cAcao,cCampo)

	Local lRet   		:= .T.
	Local oModel		:= FWModelActive()
	Local oModelUF2 	:= oModel:GetModel("UF2MASTER")
	Local oModelUF4		:= oModel:GetModel("UF4DETAIL")
	Local nOperation 	:= oModel:GetOperation()
	Local cTipoBen		:= oModelGrid:GetValue("UF4_TIPO")
	Local cTit			:= oModelGrid:GetValue("UF4_CLIENT")
	Local cLojaTit		:= oModelGrid:GetValue("UF4_LOJA")
	Local dFalecimento	:= oModelGrid:GetValue("UF4_FALECI")

	// se a opera็ใo for inclusใo ou altera็ใo
	if nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

		// se o titular no cabe็aho do contrato nใo estiver preenchido
		if Empty(oModelUF2:GetValue('UF2_CLIENT'))

			lRet := .F.
			Help(,,'Help',,"Informe o Titular do contrato primeiramente!",1,0)
		else

			// se for dele็ใo da linha
			If cAcao == 'DELETE'

				// se for o titular atual
				if  cTipoBen == "3" .AND. cTit == M->UF2_CLIENT .AND. cLojaTit == M->UF2_LOJA
					lRet := .F.
					Help( ,,'Help',,'Nao ้ permitido excluir beneficiแrio do tipo Titular!',1,0)
				elseif !Empty(dFalecimento) // se foi realizado um apontamento para o beneficiแrio
					lRet := .F.
					Help( ,,'Help',,'Nao ้ permitido excluir um beneficiแrio com data de falecimento preenchida!',1,0)

				endif

			elseif cAcao == 'UNDELETE'

				// se for titular
				if cTipoBen == "3"
					lRet := .F.
					Help( ,,'Help',,'Nao ้ permitido excluir a dele็ใo de um beneficiแrio do tipo Titular!',1,0)
				endif

			else

				// se o usuario estiver alterando o campo do tipo do beneficiario
				if cAcao == "SETVALUE" .AND. cCampo <> NIL .AND. cCampo == "UF4_TIPO"

					// se o beneficiario ้ o titular do contrato, nใo pode alterar o tipo
					if ( Type("lImp") == 'U' .Or. !lImp ) .And. !Empty(cTit) .AND. !Empty(cLojaTit) .AND. cTipoBen == "3"

						lRet := .F.
						Help( ,,'Help',,'Este beneficiแrio ้ o Titular do Contrato!',1,0)
					elseif M->UF4_TIPO == "3" .AND. ( cTit <> M->UF2_CLIENT .OR. cLojaTit <> M->UF2_LOJA )
						lRet := .F.
						Help( ,,'Help',,'Este beneficiแrio nใo ้ o Titular do Contrato!',1,0)

					endif

				endif

				// se o usuario estiver alterando o campo do tipo do beneficiario
				if cAcao == "SETVALUE" .AND. cCampo <> NIL .AND. cCampo == "UF4_TPPLN"

					// verifico se esta tudo certo ate entao
					If lRet

						// valido a quantidade de beneficiarios
						lRet := U_NumMaxBeneficiario( oModelUF4, FwFldGet("UF2_PLNSEG") )

					EndIf

					// verifico se esta tudo certo ate entao
					If lRet

						// valido a quantidade de beneficiarios
						lRet := U_MaxBenAlimentacao( oModelUF4, FwFldGet("UF2_PLNSEG") )

					EndIf

				endif

			endif

		endif

	endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ UContAgreg บ Autor ณWellington Gon็alvesบ Dataณ 29/09/2016 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que faz a contagem dos beneficiแrios do tipo		  บฑฑ
ฑฑ		     ณ agregado e atualiza o valor dos agregados				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funerแria		                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function UContAgreg(lCPO,lDelGrid)

	Local lRet 			:= .T.
	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUF2 	:= oModel:GetModel("UF2MASTER")
	Local oModelUF4 	:= oModel:GetModel("UF4DETAIL")
	Local nOperation 	:= oModel:GetOperation()
	Local nValAdicional	:= 0
	Local nValAgregado	:= 0
	Local nQtdAgregado	:= 0
	Local cTpAgreg		:= "2"
	Local nLinhaAtual	:= oModelUF4:GetLine()
	Local nX			:= 0
	Default lDelGrid	:= .F.

	// se a opera็ใo for inclusใo ou altera็ใo
	if nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

		// pego o valor do agregado do contrato
		nValAgregado := M->UF2_VLPAGR

		if nValAgregado > 0

			For nX := 1 To oModelUF4:Length()

				// posiciono na linha atual
				oModelUF4:Goline(nX)

				// se a rotina foi chamada do campo "Tipo" do grid de beneficiarios
				// preciso pegar o tipo pela mem๓ria do campo
				if nX == nLinhaAtual

					// se a opera็ใo for de dele็ใo da linha atual, nใo devo computar o agregado
					if !lDelGrid

						// se foi chamado do campo TIPO de beneficiแrio
						if lCPO

							// se o tipo do beneficiแrio for agregado E nใo estiver prescristo
							if M->UF4_TIPO == cTpAgreg .And. (Empty(oModelUF4:GetValue('UF4_DTFIM')) .Or. oModelUF4:GetValue('UF4_DTFIM') > dDataBase)
								nQtdAgregado++
							endif

						else

							// se o tipo do beneficiแrio for agregado E nใo estiver prescristo
							if oModelUF4:GetValue('UF4_TIPO') == cTpAgreg .And. (Empty(oModelUF4:GetValue('UF4_DTFIM')) .Or. oModelUF4:GetValue('UF4_DTFIM') > dDataBase)
								nQtdAgregado++
							endif

						endif

					endif

				else

					if !oModelUF4:IsDeleted(nX)

						// se o tipo do beneficiแrio for agregado E nใo estiver prescristo
						if oModelUF4:GetValue('UF4_TIPO') == cTpAgreg .And. (Empty(oModelUF4:GetValue('UF4_DTFIM')) .Or. oModelUF4:GetValue('UF4_DTFIM') > dDataBase)
							nQtdAgregado++
						endif

					endif

				endif

			Next nX

		endif

		// calculo o valor adicional
		nValAdicional := Round(nQtdAgregado * nValAgregado,TamSX3("UF2_VLADAG")[2])

		// atribuo o valor ao contrato
		oModelUF2:SetValue('UF2_VLADAG' , nValAdicional)

		//reprocesso o valor total do contrato do contrato
		lRet := U_UVlrLiqFun()

	endif

	// volto para a linha original
	oModelUF4:Goline(nLinhaAtual)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ EditCarFun บ Autor ณRaphael Martins 		บDataณ 17/04/2018 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que valida o modo de edicao do campo de UF2_CARENC  บฑฑ
ฑฑ		     ณ permite ou nao editar o campo 							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funerแria		                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function EditCarFun()

	Local lRet			:= .F.
	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUF2 	:= oModel:GetModel("UF2MASTER")
	Local oModelUF4 	:= oModel:GetModel("UF4DETAIL")
	Local nOperation 	:= oModel:GetOperation()

	//valido se o tipo de carencia e por tempo ou quantidade de parcelas e se o usuario possui permissao
	if IsInCallStack("U_RIMPM003") .Or. (oModelUF2:GetValue('UF2_TIPOCA') == '1' .And.;
			Alltrim( RetCodUsr() ) $ SuperGetMV("MV_XUSRCAR",,"000000"))

		lRet := .T.

	endif

Return(lRet)
/*

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ IniCpoCopia บ Autor ณWellington Gon็alvesบDataณ 15/02/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que inicializa campos na c๓pia do contrato		  บฑฑ
ฑฑ		     ณ 															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funerแria		                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function IniCpoCopia(oView)

	Local aArea			:= GetArea()
	Local nOperation 	:= oView:GetOperation()

	If nOperation == 3 // Inclusใo-C๓pia

		FwFldPut("UF2_STATUS",'P',,,,.F.)

		// limpo o campo numero da sorte na copia
		FwFldPut("UF2_NUMSOR",'',,,,.F.)

		oView:Refresh()

	endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ UVldDtCar บAutor ณRaphael Martins	   บ Dataณ 10/11/2017 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo chamada no Valid do Campo de Carencia do Beneficiarioฑฑ
ฑฑ		     ณ para verificar se permite a alteracao da data de carencia  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funerแria		                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function UValidDtCar()

	Local lRet			:= .T.
	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUF2 	:= oModel:GetModel("UF2MASTER")
	Local oModelUF4 	:= oModel:GetModel("UF4DETAIL")

	//valido se a chamada e via Gatilho
	if !IsInCallStack("RUNTRIGGER" )

		//sera permitido a edicao do campo de carencia do agregado apenas para contrato de portabilidade
		if oModelUF2:GetValue("UF2_PORTAB") == '2'

			//data de carencia nao pode ser inferior a data de inclusao
			if oModelUF4:GetValue("UF4_DTINC") > oModelUF4:GetValue("UF4_CAREN")
				lRet := .F.
				Help(,,'Help',,"A Data de Car๊ncia nใo pode ser inferior a data de inclusao do beneficiario/agregado!",1,0)
			endif

		else
			lRet := .F.
			Help(,,'Help',,"A Data de Car๊ncia pode ser alterado apenas em contratos de portabilidade!",1,0)
		endif

	endif

Return( lRet )

/****************************/
User Function UManuCli(_nOpc)
	/****************************/
	Local cRotBkp		:= FunName()
	Private lAutoExec	:= .F.
	Private lInclui		:= .T.
	Private lAltera		:= .F.
	Private	l030Auto	:= .F.
	Private aRotina		:= {}
	Private aRotAuto	:= NIL
	Private cCadastro 	:= "Cadastro de Clientes"

	//Altero o nome da rotina para considerar o menu do cadastro de cliente
	SetFunName("MATA030")

	AAdd(aRotina, {"Pesquisar" 		,"PesqBrw"    	, 0 , 1	, 0    	, .F.} )
	AAdd(aRotina, {"Visualizar"		, "A030Visual" 	, 0 , 2	, 0   	, NIL} )
	AAdd(aRotina, {"Incluir"		, "A030Inclui" 	, 0 , 3	, 81  	, NIL} )
	AAdd(aRotina, {"Alterar"		, "A030Altera" 	, 0 , 4	, 143 	, NIL} )
	AAdd(aRotina, {"Excluir"		, "A030Deleta" 	, 0 , 5	, 144 	, NIL} )

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

	cAlias := "SA1"

	If _nOpc == 3 //Inclusใo de Cliente
		FWExecView("Incluir","CRMA980",MODEL_OPERATION_INSERT,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)
	Else

		If SA1->(DbSeek(xFilial("SA1")+UF2->UF2_CLIENT+UF2->UF2_LOJA))

			If _nOpc == 4 //Altera็ใo de Cliente
				A030Altera("SA1",SA1->(Recno()),4)

			elseif _nOpc == 5 //Contato

				FtContato( "SA1", SA1->(Recno()), 2, , 4 )

			Else //Visualiza็ใo de Cliente

				A030Visual("SA1",SA1->(Recno()),2)

			Endif

		Endif

	Endif

	//restauro a funcao do contrato
	SetFunName(cRotBkp)

Return

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
	cQry += " ORDER BY DA1_DATVIG DESC"

	if Select("QRYTAB") > 0
		QRYTAB->(DbCloseArea())
	endif

	cQry := ChangeQuery(cQry)

	TcQuery cQry NEW Alias "QRYTAB"

	//verifico se o preco esta vigente
	if STOD(QRYTAB->VIGENCIA) <= dDataBase
		nPreco := QRYTAB->PRECO
	else
		Help( ,, 'Help',, 'O Produto/Servico: '+ Alltrim(cProduto) +' nใo possui pre็o vigente na tabela: ' +Alltrim(cCodTab)+'', 1, 0 )
	endif

	RestArea(aAreaDA1)

Return(nPreco)

/*/{Protheus.doc} UCalcVlrLiq
Funcao para calcular o valor liquido do contrato funeraria
apos a digitacao de valor de desconto. Serแ utilizado para
executar a funcao CalcVlrLiq
@author Raphael Martins
@since 14/08/2018
@version P12
@return nPreco - Preco de Venda da Tabela
/*/

User Function UVlrLiqFun()

	Local aArea			:= GetArea()
	Local aAreaUF2		:= UF2->(GetArea())
	Local aAreaUF3		:= UF3->(GetArea())
	Local oView			:= FWViewActive()
	Local lRet			:= .T.
	Local lRecalcImp 	:= SuperGetMV("MV_XFRCIMP", .F., .T.)

	If !IsBlind() .And. !IsInCallStack("U_RUTILE26") .And. !IsInCallStack("U_RFUNE002")

		if IsInCallStack("U_RIMPM003")
			if lRecalcImp
				FWMsgRun(,{|oSay| lRet := CalcVlrLiq() },'Aguarde...','Reprocessando Valor do Contrato!')
			endIf
		else
			FWMsgRun(,{|oSay| lRet := CalcVlrLiq() },'Aguarde...','Reprocessando Valor do Contrato!')
		endIf

	Else

		if IsInCallStack("U_RIMPM003")
			if lRecalcImp
				lRet := CalcVlrLiq()
			endIf
		else
			lRet := CalcVlrLiq()
		endIf

	Endif

	if lRet .And. oView <> NIL

		// chamo fun็ใo que atualiza os totalizadores
		oTotais:RefreshTot()

	endif

	RestArea(aAreaUF2)
	RestArea(aAreaUF3)

Return(lRet)

/*/{Protheus.doc} CalcVlrLiq
Funcao para calcular o valor liquido do contrato funerario
apos a digitacao de valor de desconto e quantidade de itens.
@author Raphael Martins
@since 14/08/2018
@version P12
@return nPreco - Preco de Venda da Tabela
/*/
Static Function CalcVlrLiq()

	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUF2		:= oModel:GetModel("UF2MASTER")
	Local oModelUF3		:= oModel:GetModel("UF3DETAIL")
	Local oModelUF4		:= oModel:GetModel("UF4DETAIL")
	Local nOperation 	:= oModel:GetOperation()
	Local aSaveLines  	:= FWSaveRows()
	Local nX			:= 0
	Local nVlrItens		:= 0
	Local nVlrLiq		:= 0
	Local nValAdd		:= 0
	Local lRet			:= .T.
	Local lPersonFun	:= SuperGetMv("MV_XPERFUN",.F.,.F.)
	Local aAreaUF0		:= UF0->(GetArea())
	Local nVlrPFUN2VLR  := 0

	Local nCobrAd		:= 0
	Local aCobr			:= {}

	//o desconto nao pode ser superior ao valor das parcelas
	if oModelUF2:GetValue("UF2_DESCON") <= oModelUF2:GetValue("UF2_VALOR")

		if lPersonFun

			//libero para edicao a linha de itens
			oModel:GetModel('UF3DETAIL'):SetNoInsertLine(.F.)
			oModel:GetModel('UF3DETAIL'):SetNoUpdateLine(.F.)
			oModel:GetModel('UF3DETAIL'):SetNoUpdateLine(.F.)
			oModel:GetModel("UF3DETAIL"):SetNoDeleteLine(.F.)

			//Grid de Produtos/Servicos Habilitados

			For nX := 1 To oModelUF3:Length()

				oModelUF3:GoLine(nX)

				if !oModelUF3:IsDeleted()

					nQuantidade := oModelUF3:GetValue("UF3_QUANT")
					nVlrUnit	:= oModelUF3:GetValue("UF3_VLRUNI")

					if ReadVar() <> "M->UF2_DESCON" .And. ReadVar() <> "M->F2_VLADAG"

						oModelUF3:LoadValue("UF3_VLRTOT"	, nQuantidade * nVlrUnit )

					endif

					nVlrItens += nQuantidade * nVlrUnit

					If Alltrim(oModelUF3:GetValue("UF3_TIPO")) == "ADDITENS.PNG"

						nValAdd +=  nQuantidade * nVlrUnit
					Endif
				endif

			Next nX

			//Valor Liquido do Contrato = Valor dos Itens - Descontos
			if oModel:GetOperation() == 4

				nVlrLiq := nVlrItens + oModelUF2:GetValue("UF2_VLCOB")

				nVlrLiq -= CalcDesconto(nVlrLiq)

			else
				nVlrLiq := nVlrItens + oModelUF2:GetValue("UF2_VLCOB") - oModelUF2:GetValue("UF2_DESCON")
			endif

			if nVlrLiq < 0
				lRet := .F.
				Help( ,, 'Help - 1',, 'O Desconto nใo pode ser superior ao valor das parcelas, verifique o desconto digitado!', 1, 0 )
			endif

		else
			//Valor Liquido do Contrato sem os agregados = Descontos
			nVlrLiq := oModelUF2:GetValue("UF2_VLRBRU") - oModelUF2:GetValue("UF2_DESCON") + oModelUF2:GetValue("UF2_VLCOB")

		endif

		//atualizo campo de valor liquido do contrato
		if lRet

			//-- Ponto Entrada para atualiza็ใo do valor lํquido do contrato --//
			If nOperation == MODEL_OPERATION_UPDATE
				If ExistBlock("PFUN2VLR")
					nVlrPFUN2VLR := ExecBlock("PFUN2VLR", .F., .F., { nVlrLiq })
					If ValType(nVlrPFUN2VLR) == "N"
						If nVlrPFUN2VLR > 0
							nVlrLiq := nVlrPFUN2VLR
						EndIf
					EndIf
				EndIf
			EndIf

			oModelUF2:LoadValue("UF2_VLSERV" , nValAdd)
			oModelUF2:LoadValue("UF2_VALOR" , nVlrLiq )

			// Atualiza apenas para personalizacao de contrato
			If nVlrItens > 0
				oModelUF2:LoadValue("UF2_VLRBRU" , nVlrItens - nValAdd )
			EndIf

			UF0->(DbSetOrder(1))
			//Valido se adesao serแ o mesmo valor da parcela
			If UF0->(Dbseek(xFilial("UF0")+oModelUF2:GetValue("UF2_PLANO")))

				if UF0->UF0_ADPARC == "S" .And. oModelUF2:GetValue("UF2_STATUS") == "P"

					oModelUF2:LoadValue("UF2_ADESAO" , oModelUF2:GetValue("UF2_VALOR") )

				Endif
			endif

		endif

	else

		lRet := .F.
		Help( ,, 'Help - 2',, 'O Desconto nใo pode ser superior ao valor das parcelas, verifique o desconto digitado!', 1, 0 )

	endif

	//Valida se existe Pe Apos Atualizar dos totais
	If ExistBlock("PFUN02PL")

		ExecBlock("PFUN02PL",.F.,.F.)
	Endif

	//restauro as linhas posicionadas
	FWRestRows( aSaveLines )

	RestArea(aAreaUF0)
Return(lRet)

/*/{Protheus.doc} EditGrid
Funcao para validar a delecao e restauracao
da linha da tabelas UF3 - Utilizada para
reprocessar o valor liquido do contrato
@author Raphael Martins
@since 14/08/2018
@version P12
@return nPreco - Preco de Venda da Tabela
/*/
Static Function EditGrid(oModelGrid,nLinha,cAcao,cCampo)

	Local lRet 				:= .T.
	Local oModel			:= FWModelActive()
	Local oView				:= FWViewActive()
	Local oModelUF2			:= oModel:GetModel("UF2MASTER")
	Local oModelUF3			:= oModel:GetModel("UF3DETAIL")
	Local nOperation 		:= oModel:GetOperation()
	Local aSaveLines    	:= FWSaveRows()
	Local nVlrAtual			:= 0
	Local nX				:= 1
	Local nVlrItens			:= 0
	Local nQuantidade		:= 0
	Local nVlrUnit			:= 0
	Local nValProd			:= 0
	Local nValServ			:= 0
	Local nVlrLiq			:= 0
	Local nLinhaAtual		:= oModelGrid:GetLine()
	Local lPersonFun		:= SuperGetMv("MV_XPERFUN",.F.,.F.)
	Local cIconProdAvulso	:= "AVGBOX1.PNG"
	Local nVlrPFUN2VLR		:= 0

	//atualizo o valor do contrato de acordo em casos de delecao e restauracao da linha posicionada
	if lPersonFun .And. !IsInCallStack("U_LimpaAcolsMVC")

		if oModelGrid:cId == "UF3DETAIL"

			If cAcao == 'DELETE' .Or. cAcao == 'UNDELETE'

				nVlrAtual	:= oModelUF2:GetValue("UF2_VALOR")
				nVlrLinha	:= oModelGrid:GetValue("UF3_QUANT") * oModelGrid:GetValue("UF3_VLRUNI")

				if cAcao == 'DELETE'
					oModelUF2:LoadValue("UF2_VALOR"	, nVlrAtual - nVlrLinha )
				else
					oModelUF2:LoadValue("UF2_VALOR"	, nVlrAtual + nVlrLinha )
				endif

				//Valida se existe Pe Apos Atualizar dos totais
				If ExistBlock("PFUN02PL")

					ExecBlock("PFUN02PL",.F.,.F.)
				Endif

			elseIf AllTrim(cAcao) == 'SETVALUE' .AND. AllTrim(cCampo) == "UF3_QUANT"

				// atualizo o valor total do item
				if !IsInCallStack("U_RFUNE002")
					oModelGrid:LoadValue("UF3_VLRTOT" , M->UF3_QUANT * oModelGrid:GetValue("UF3_VLRUNI")  )
				else
					oModelGrid:LoadValue("UF3_VLRTOT" , FWFldGet("UF3_QUANT") * oModelGrid:GetValue("UF3_VLRUNI")  )
				endif

				// percorro o grid de produtos
				For nX := 1 To oModelGrid:Length()

					oModelGrid:GoLine(nX)

					if !oModelGrid:IsDeleted()

						// servi็os avulsos
						if AllTrim(oModelGrid:GetValue( "UF3_TIPO" )) <> cIconProdAvulso
							nValServ += oModelGrid:GetValue( "UF3_VLRTOT" )
						else
							nValProd += oModelGrid:GetValue( "UF3_VLRTOT" )
						endif

					endif

				Next nX

				// Valor Liquido do Contrato
				nVlrLiq := ( nValProd + nValServ + oModelUF2:GetValue("UF2_VLCOB") ) - oModelUF2:GetValue("UF2_DESCON")

				//-- Ponto Entrada para atualiza็ใo do valor lํquido do contrato --//
				If nOperation == MODEL_OPERATION_UPDATE
					If ExistBlock("PFUN2VLR")
						nVlrPFUN2VLR := ExecBlock("PFUN2VLR", .F., .F., { nVlrLiq })
						If ValType(nVlrPFUN2VLR) == "N"
							If nVlrPFUN2VLR > 0
								nVlrLiq := nVlrPFUN2VLR
							EndIf
						EndIf
					EndIf
				EndIf

				if nVlrLiq < 0
					lRet := .F.
					Help( ,, 'Help - 3',, 'O Desconto nใo pode ser superior ao valor das parcelas, verifique o desconto digitado!', 1, 0 )
				else

					oModelUF2:LoadValue("UF2_VALOR"		, nVlrLiq )
					oModelUF2:LoadValue("UF2_VLRBRU"	, nValProd )
					oModelUF2:LoadValue("UF2_VLSERV"	, nValServ )

				endif

				// chamo fun็ใo que atualiza os valores do contrato
				if oView <> Nil
					oTotais:RefreshTot()
				endif

			endif

			if oView <> Nil
				oView:Refresh("UF2MASTER")
			endif

		endif

	endif

	FWRestRows( aSaveLines )
	oModelGrid:GoLine( nLinhaAtual )

Return(lRet)

/***********************/
User Function INCPERSF()
/***********************/

	Local lContinua		:= .T.

	Private oResumoTotal := NIL

	Do Case

	Case UF2->UF2_STATUS == "C" //Cancelado
		MsgInfo("O Contrato se encontra Cancelado, opera็ใo nใo permitida.","Aten็ใo")
		lContinua := .F.

	Case UF2->UF2_STATUS == "F" //Finalizado
		MsgInfo("O Contrato se encontra Finalizado, opera็ใo nใo permitida.","Aten็ใo")
		lContinua := .F.
	EndCase

	If lContinua
		FWExecView('INCLUIR','RFUNE029',3,,{|| .T. })
	Endif

Return

/*/{Protheus.doc} UWhenFun
Funcao para definir o modo de edicao dos campos
@type function
@version 1.0  
@author Raphael Martins
@since 14/08/2018
@return logical, retorno sobre o uso do campo
/*/
User Function UWhenFun()

	Local lRet := .F.

	if Alltrim(ReadVar()) == "M->UF2_DESCON"

		//libero o campo de desconto apenas quando executado via ExecAuto ou o usuario estiver contido no parametro MV_XUSRDES
		if IsInCallStack("U_RFUNE002") .Or. RetCodUsr() $ SuperGetMv( "MV_XUSRDES", .F., "000000" )

			lRet := .T.

		endif

	elseif Inclui .Or. UF2->UF2_STATUS == "P" .Or. IsInCallStack("U_RFUNE002")

		lRet := .T.

	endif

Return(lRet)

/*/{Protheus.doc} CriaTotais
Fun็ใo que cria o Other Object de Totalizadores
@type function
@version 1.0 
@author Wellington Gon็alves
@since 16/03/2019
@param oPanel, object, painel da tela
/*/
Static Function CriaTotais(oPanel)

	oTotais := ObjTotalizador():New(oPanel)

Return(Nil)

/*/{Protheus.doc} ObjTotalizador
Classe do totalizador
@type class
@version 1.0  
@author Wellington Gon็alves
@since 16/03/2019
/*/
	Class ObjTotalizador

		Data oVlPlanOld
		Data oVlAdicOld
		Data oValDesOld
		Data oValLiqOld
		Data oVlPlanNew
		Data oVlAdicNew
		Data oValDesNew
		Data oValLiqNew
		Data oSitFinanc

		Data nVlPlanOld
		Data nVlAdicOld
		Data nValDesOld
		Data nValLiqOld
		Data nVlPlanNew
		Data nVlAdicNew
		Data nValDesNew
		Data nValLiqNew
		Data cSitFinanc

		Method New() Constructor
		Method RefreshTot()

	EndClass

/*/{Protheus.doc} ObjTotalizador::New
M้todo construtor da classe ObjTotal	
@type method
@version 1.0
@author Wellington Gon็alves
@since 16/03/2019
@param oPanel, object, objeto de painel da tela
/*/
Method New(oPanel) Class ObjTotalizador

	Local oPanelCpo		:= NIL
	Local oPanelSitFin	:= NIL
	Local oPanelFin		:= NIL
	Local oPanelPlan	:= NIL
	Local oPanelAdic	:= NIL
	Local oPanelDesc	:= NIL
	Local oPanelLiq		:= NIL
	Local oSay1			:= NIL
	Local oSay2			:= NIL
	Local oSay3			:= NIL
	Local oSay4			:= NIL
	Local oSay5			:= NIL
	Local oGroup1		:= NIL
	Local oModel 		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oFont12N	   	:= TFont():New("Verdana",,12,,.T.,,,,.T.,.F.,.T.) // Fonte 12 Negrito, Itแlico
	Local oFont14N	   	:= TFont():New("Verdana",,14,,.T.,,,,.T.,.F.,.F.) // Fonte 14 Negrito
	Local oFont18N	   	:= TFont():New("Verdana",,18,,.T.,,,,.T.,.F.,.T.) // Fonte 28 Negrito
	Local oFont24	   	:= TFont():New("Cooper Black",,24,,.F.,,,,.T.,.F.,.F.) // Fonte 24 Nornal
	Local oFontNum	   	:= TFont():New("Verdana",08,18,,.F.,,,,.T.,.F.) ///Fonte 14 Negrito
	Local nHeigth		:= oPanel:nClientHeight / 2
	Local nWhidth		:= oPanel:nClientWidth / 2
	Local nOperation 	:= oModel:GetOperation()
	Local nLin			:= 5
	Local nAltPnlFin	:= 30
	Local nAltPnlTit	:= 45
	Local nClrPanes		:= 16777215 // 12961221
	Local nClrAdimp 	:= 41984
	Local nClrInadi		:= 987135
	Local nClrCanc		:= 8388608
	Local nClrSitFin	:= 12961221
	Local nClrSay		:= 7303023
	Local nAltPanels	:= 0
	Local aTotais		:= {}
	Local lAdimp		:= .T.

	// se for inclusใo, zero os totais
	if nOperation == 3

		::nVlPlanOld	:= 0
		::nVlAdicOld	:= 0
		::nValDesOld	:= 0
		::nValLiqOld	:= 0
		::cSitFinanc	:= "INEXISTENTE"

	else

		::nVlPlanOld	:= UF2->UF2_VLRBRU
		::nVlAdicOld	:= UF2->UF2_VLCOB + UF2->UF2_VLSERV
		::nValDesOld	:= UF2->UF2_DESCON
		::nValLiqOld	:= UF2->UF2_VALOR

		if UF2->UF2_STATUS == 'C'

			::cSitFinanc 	:= "CANCELADO"
			nClrSitFin		:= nClrCanc

		else
			// fun็ใo que retorna a situa็ใo financeira do contrato
			lAdimp := RetSitFin(UF2->UF2_CODIGO)

			if lAdimp
				::cSitFinanc 	:= "ADIMPLENTE"
				nClrSitFin		:= nClrAdimp
			else
				::cSitFinanc 	:= "INADIMPLENTE"
				nClrSitFin		:= nClrInadi
			endif

		endif

	endif

	// inicializo os novos totais zerados
	::nVlPlanNew	:= 0
	::nVlAdicNew	:= 0
	::nValDesNew	:= 0
	::nValLiqNew	:= 0

	////////////////////////////////////////////////////
	////////////////		TอTULO		////////////////
	////////////////////////////////////////////////////

	@ 002, 002 MSPANEL oPanelCpo SIZE nWhidth - 2 , nHeigth -2 OF oPanel COLORS 0, 12961221 //15329769

	@ nLin 		, 015 SAY oSay1 PROMPT "Valor Atual" SIZE 025, 020 OF oPanelCpo FONT oFont12N COLORS 0, 16777215 PIXEL CENTER
	@ nLin 		, 055 SAY oSay2 PROMPT "ฺltima Negocia็ใo" SIZE 040, 020 OF oPanelCpo FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ 004		, 049 GROUP oGroup1 TO nLin + 15, 050 OF oPanelCpo COLOR 10197915, 16777215 PIXEL
	@ nLin + 08 , 001 SAY oSay5 PROMPT Replicate("- ",25) SIZE nWhidth - 4, 020 OF oPanelCpo FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	nLin += 20

	nAltPanels := INT(nHeigth - nLin - nAltPnlTit - 4) / 4

	////////////////////////////////////////////////////
	////////////////		TOTAIS		////////////////
	////////////////////////////////////////////////////

	nIniGroup := nLin

	@ nLin , 002 MSPANEL oPanelPlan SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay3 PROMPT "Valor do Plano" SIZE nWhidth - 6, 015 OF oPanelPlan FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 006 , 001 SAY oSay4 PROMPT Replicate("- ",25) SIZE nWhidth - 6, 015 OF oPanelPlan FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 000 SAY oSay5 PROMPT "R$" SIZE 45, 010 OF oPanelPlan FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 000 SAY ::oVlPlanNew PROMPT AllTrim(Transform(::nVlPlanNew,"@E 999,999,999.99")) SIZE 45, 010 OF oPanelPlan FONT oFontNum COLORS 0, 16777215 PIXEL CENTER

	@ 018 , 047 GROUP oGroup1 TO nAltPanels - 5, 048 OF oPanelPlan COLOR 10197915, 16777215 PIXEL

	@ (nAltPanels / 2) - 5, 050 SAY oSay5 PROMPT "R$" SIZE 45, 010 OF oPanelPlan FONT oFont18N COLORS 10197915, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 050 SAY ::oVlPlanOld PROMPT AllTrim(Transform(::nVlPlanOld,"@E 999,999,999.99")) SIZE 45, 010 OF oPanelPlan FONT oFontNum COLORS 10197915, 16777215 PIXEL CENTER

	nLin += nAltPanels

	@ nLin , 002 MSPANEL oPanelAdic SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay5 PROMPT "Valores Adicionais" SIZE nWhidth - 6, 015 OF oPanelAdic FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 006 , 001 SAY oSay6 PROMPT Replicate("- ",25) SIZE nWhidth - 6, 015 OF oPanelAdic FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 000 SAY oSay5 PROMPT "R$" SIZE 45, 010 OF oPanelAdic FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 000 SAY ::oVlAdicNew PROMPT AllTrim(Transform(::nVlAdicNew,"@E 999,999,999.99")) SIZE 45, 010 OF oPanelAdic FONT oFontNum COLORS 0, 16777215 PIXEL CENTER

	@ 018 , 047 GROUP oGroup1 TO nAltPanels - 5, 048 OF oPanelAdic COLOR 10197915, 16777215 PIXEL

	@ (nAltPanels / 2) - 5, 050 SAY oSay5 PROMPT "R$" SIZE 45, 010 OF oPanelAdic FONT oFont18N COLORS 10197915, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 050 SAY ::oVlAdicOld PROMPT AllTrim(Transform(::nVlAdicOld,"@E 999,999,999.99")) SIZE 45, 010 OF oPanelAdic FONT oFontNum COLORS 10197915, 16777215 PIXEL CENTER

	nLin += nAltPanels

	@ nLin , 002 MSPANEL oPanelDesc SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay5 PROMPT "Valor de Desconto" SIZE nWhidth - 6, 015 OF oPanelDesc FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 006 , 001 SAY oSay6 PROMPT Replicate("- ",25) SIZE nWhidth - 6, 015 OF oPanelDesc FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 000 SAY oSay5 PROMPT "R$" SIZE 45, 010 OF oPanelDesc FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 000 SAY ::oValDesNew PROMPT AllTrim(Transform(::nValDesNew,"@E 999,999,999.99")) SIZE 45, 010 OF oPanelDesc FONT oFontNum COLORS 0, 16777215 PIXEL CENTER

	@ 018 , 047 GROUP oGroup1 TO nAltPanels - 5, 048 OF oPanelDesc COLOR 10197915, 16777215 PIXEL

	@ (nAltPanels / 2) - 5, 050 SAY oSay5 PROMPT "R$" SIZE 45, 010 OF oPanelDesc FONT oFont18N COLORS 10197915, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 050 SAY ::oValDesOld PROMPT AllTrim(Transform(::nValDesOld,"@E 999,999,999.99")) SIZE 45, 010 OF oPanelDesc FONT oFontNum COLORS 10197915, 16777215 PIXEL CENTER

	nLin += nAltPanels

	@ nLin , 002 MSPANEL oPanelLiq SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay6 PROMPT "Valor Lํquido" SIZE nWhidth - 6, 015 OF oPanelLiq FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 006 , 001 SAY oSay6 PROMPT Replicate("- ",25) SIZE nWhidth - 6, 015 OF oPanelLiq FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 000 SAY oSay5 PROMPT "R$" SIZE 45, 010 OF oPanelLiq FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 000 SAY ::oValLiqNew PROMPT AllTrim(Transform(::nValLiqNew,"@E 999,999,999.99")) SIZE 45, 010 OF oPanelLiq FONT oFontNum COLORS 0, 16777215 PIXEL CENTER

	@ 018 , 047 GROUP oGroup1 TO nAltPanels - 5, 048 OF oPanelLiq COLOR 10197915, 16777215 PIXEL

	@ (nAltPanels / 2) - 5, 050 SAY oSay5 PROMPT "R$" SIZE 45, 010 OF oPanelLiq FONT oFont18N COLORS 10197915, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 050 SAY ::oValLiqOld PROMPT AllTrim(Transform(::nValLiqOld,"@E 999,999,999.99")) SIZE 45, 010 OF oPanelLiq FONT oFontNum COLORS 10197915, 16777215 PIXEL CENTER

	////////////////////////////////////////////////////
	////////		SITUAวรO FINANCEIRA			////////
	////////////////////////////////////////////////////

	@ nHeigth - (nAltPnlTit + 4) , 002 MSPANEL oPanelSitFin SIZE nWhidth - 6 , nAltPnlTit OF oPanelCpo COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay7 PROMPT "Situa็ใo Financeira" SIZE nWhidth - 6, 015 OF oPanelSitFin FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER

	@ nAltPnlTit - nAltPnlFin , 000 MSPANEL oPanelFin SIZE nWhidth - 6 , nAltPnlFin OF oPanelSitFin COLORS 0, nClrSitFin
	@ (nAltPnlFin / 2) - 10 , 0 SAY ::oSitFinanc PROMPT ::cSitFinanc SIZE nWhidth - 6, 020 OF oPanelFin FONT oFont24 COLORS 16777215, nClrSitFin PIXEL CENTER

	// se nใo for inclusใo, atualiza os valores atuais
	if nOperation <> 3
		// chamo fun็ใo que atualiza os valores do contrato
		::RefreshTot()
	endif

Return(Nil)

/*/{Protheus.doc} ObjTotalizador::RefreshTot
M้todo que atualiza os totalizadores	
@type method
@version 1.0 
@author Wellington Gon็alves
@since 26/03/2019
/*/
Method RefreshTot() Class ObjTotalizador

	Local lRet   			:= .T.
	Local oModel 			:= FWModelActive()
	Local oView				:= FWViewActive()
	Local nOperation 		:= oModel:GetOperation()
	Local oModelUF2  		:= oModel:GetModel("UF2MASTER") // CABEวALHO
	Local oModelUF3  		:= oModel:GetModel("UF3DETAIL") // PRODUTOS E SERVIวOS
	Local oModelUF4  		:= oModel:GetModel("UF4DETAIL") // BENEFICIARIOS
	Local oModelUJ9  		:= oModel:GetModel("UJ9DETAIL") // COBRANวAS ADICIONAIS
	Local nLinhaUF3			:= oModelUF3:GetLine()
	Local nLinhaUF4			:= oModelUF4:GetLine()
	Local nLinhaUJ9			:= oModelUJ9:GetLine()
	Local nX				:= 0
	Local nY				:= 0
	Local nValBrut			:= 0
	Local nValPlano			:= 0

	// zero os totalizadores
	::nVlPlanNew	:= oModelUF2:GetValue( "UF2_VLRBRU" ) + oModelUF2:GetValue( "UF2_VLADIC" )
	::nValDesNew	:= oModelUF2:GetValue( "UF2_DESCON" )
	::nVlAdicNew	:= oModelUF2:GetValue( "UF2_VLCOB" ) + oModelUF2:GetValue( "UF2_VLSERV" )
	::nValLiqNew 	:= (::nVlPlanNew + ::nVlAdicNew) - ::nValDesNew

	::oVlPlanNew:Refresh()
	::oVlAdicNew:Refresh()
	::oValDesNew:Refresh()
	::oValLiqNew:Refresh()

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RetSitFin บ Autorณ Wellington Gon็alves บ Dataณ 09/04/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que consulta os tํtulos em aberto do contrato		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Postumos			                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RetSitFin(cContrato)

	Local lRet 			:= .T.
	Local cPulaLinha	:= chr(13)+chr(10)
	Local cQry			:= ""

	// verifico se nao existe este alias criado
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	EndIf

	cQry := " SELECT " 												+ cPulaLinha
	cQry += " SE1.E1_NUM " 											+ cPulaLinha
	cQry += " FROM " 												+ cPulaLinha
	cQry += " " + RetSqlName("SE1") + " SE1 "						+ cPulaLinha
	cQry += " WHERE " 												+ cPulaLinha
	cQry += " SE1.D_E_L_E_T_	<> '*' " 							+ cPulaLinha
	cQry += " AND SE1.E1_FILIAL 	= '" + xFilial("SE1") + "' " 	+ cPulaLinha
	cQry += " AND SE1.E1_XCTRFUN	= '" + cContrato + "' "			+ cPulaLinha
	cQry += " AND SE1.E1_SALDO		> 0 "							+ cPulaLinha
	cQry += " AND SE1.E1_VENCREA	< '" + DTOS(dDataBase) + "' "	+ cPulaLinha
	cQry += " AND SE1.E1_TIPO NOT IN ('AB-','FB-','FC-','FU-' " 	+ cPulaLinha
	cQry += " ,'PR','IR-','IN-','IS-','PI-','CF-','CS-','FE-' "		+ cPulaLinha
	cQry += " ,'IV-','RA','NCC','NDC') "							+ cPulaLinha

	// funcao que converte a query generica para o protheus
	cQry := ChangeQuery(cQry)

	// crio o alias temporario
	TcQuery cQry New Alias "QRYSE1" // Cria uma nova area com o resultado do query

	if QRYSE1->(!Eof())
		lRet := .F.
	endif

	// verifico se nao existe este alias criado
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ DelGrid บ Autor ณ Wellington Gon็alves  บ Dataณ 01/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo chamada na dele็ใo da linha dos grids				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Postumos			                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function DelGrid( oView,cIdView,nNumLine )

	Local aArea 			:= GetArea()
	Local oModel			:= FWModelActive()
	Local oView				:= FWViewActive()
	Local oModelUF2 		:= oModel:GetModel("UF2MASTER")
	Local oModelUF3 		:= oModel:GetModel("UF3DETAIL")
	Local nLinhaUF3			:= oModelUF3:GetLine()
	Local nOperation 		:= oModel:GetOperation()
	Local cIconProdAvulso	:= "AVGBOX1.PNG"
	Local nX 				:= 1
	Local nValProd			:= 0
	Local nValServ			:= 0
	Local nVlrLiq			:= 0
	Local nVlrPFUN2VLR		:= 0
	Local aSaveLines   	 	:= FWSaveRows()

	if AllTrim(cIdView) == "UF3DETAIL"

		// percorro o grid de produtos
		For nX := 1 To oModelUF3:Length()

			oModelUF3:GoLine(nX)

			if !oModelUF3:IsDeleted()

				// servi็os avulsos
				if AllTrim(oModelUF3:GetValue( "UF3_TIPO" )) <> cIconProdAvulso
					nValServ += oModelUF3:GetValue( "UF3_VLRTOT" )
				else
					nValProd += oModelUF3:GetValue( "UF3_VLRTOT" )
				endif

			endif

		Next nX

		// Valor Liquido do Contrato
		nVlrLiq := ( nValProd + nValServ + oModelUF2:GetValue("UF2_VLCOB") ) - oModelUF2:GetValue("UF2_DESCON")

		//-- Ponto Entrada para atualiza็ใo do valor lํquido do contrato --//
		If nOperation == MODEL_OPERATION_UPDATE
			If ExistBlock("PFUN2VLR")
				nVlrPFUN2VLR := ExecBlock("PFUN2VLR", .F., .F., { nVlrLiq })
				If ValType(nVlrPFUN2VLR) == "N"
					If nVlrPFUN2VLR > 0
						nVlrLiq := nVlrPFUN2VLR
					EndIf
				EndIf
			EndIf
		EndIf

		oModelUF2:LoadValue("UF2_VALOR"		, nVlrLiq )
		oModelUF2:LoadValue("UF2_VLRBRU"	, nValProd )
		oModelUF2:LoadValue("UF2_VLSERV"	, nValServ )

		oModelUF3:GoLine( nLinhaUF3 )

		// chamo fun็ใo que atualiza os valores do contrato
		if oView <> NIL

			oTotais:RefreshTot()

			oView:Refresh("UF2MASTER")
			oView:Refresh("UF3DETAIL")

		endif

	elseif AllTrim(cIdView) == "UF4DETAIL"

		//atualizo as regras de cobranca adicionais
		RefreshUJ9()

		//atualizo valor total do contrato
		CalcVlrLiq()

		//atualizo totalizadores
		oTotais:RefreshTot()

		oView:Refresh("UF2MASTER")
		oView:Refresh("UF4DETAIL")

	endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ UnDelGrid บ Autor ณ Wellington Gon็alvesบ Dataณ 01/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo chamada na Undele็ใo da linha dos grids			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Postumos			                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function UnDelGrid( oView,cIdView,nNumLine )

	Local aArea 			:= GetArea()
	Local oModel			:= FWModelActive()
	Local oView				:= FWViewActive()
	Local oModelUF2 		:= oModel:GetModel("UF2MASTER")
	Local oModelUF3 		:= oModel:GetModel("UF3DETAIL")
	Local nLinhaUF3			:= oModelUF3:GetLine()
	Local nOperation 		:= oModel:GetOperation()
	Local cIconProdAvulso	:= "AVGBOX1.PNG"
	Local nX 				:= 1
	Local nValProd			:= 0
	Local nValServ			:= 0
	Local nVlrLiq			:= 0
	Local nVlrPFUN2VLR		:= 0
	Local aSaveLines   	 	:= FWSaveRows()

	if AllTrim(cIdView) == "UF3DETAIL"

		// percorro o grid de produtos
		For nX := 1 To oModelUF3:Length()

			oModelUF3:GoLine(nX)

			if !oModelUF3:IsDeleted()

				// servi็os avulsos
				if AllTrim(oModelUF3:GetValue( "UF3_TIPO" )) <> cIconProdAvulso
					nValServ += oModelUF3:GetValue( "UF3_VLRTOT" )
				else
					nValProd += oModelUF3:GetValue( "UF3_VLRTOT" )
				endif

			endif

		Next nX

		// Valor Liquido do Contrato
		nVlrLiq := ( nValProd + nValServ + oModelUF2:GetValue("UF2_VLCOB") ) - oModelUF2:GetValue("UF2_DESCON")

		//-- Ponto Entrada para atualiza็ใo do valor lํquido do contrato --//
		If nOperation == MODEL_OPERATION_UPDATE
			If ExistBlock("PFUN2VLR")
				nVlrPFUN2VLR := ExecBlock("PFUN2VLR", .F., .F., { nVlrLiq })
				If ValType(nVlrPFUN2VLR) == "N"
					If nVlrPFUN2VLR > 0
						nVlrLiq := nVlrPFUN2VLR
					EndIf
				EndIf
			EndIf
		EndIf

		oModelUF2:LoadValue("UF2_VALOR"		, nVlrLiq )
		oModelUF2:LoadValue("UF2_VLRBRU"	, nValProd )
		oModelUF2:LoadValue("UF2_VLSERV"	, nValServ )

		oModelUF3:GoLine( nLinhaUF3 )

		// chamo fun็ใo que atualiza os valores do contrato
		if oView <> NIL

			oView:Refresh("UF2MASTER")
			oView:Refresh("UF3DETAIL")

			oTotais:RefreshTot()

		endif

	elseif AllTrim(cIdView) == "UF4DETAIL"

		//atualizo as regras de cobranca adicionais
		RefreshUJ9()

		//atualizo valor total do contrato
		CalcVlrLiq()

		//atualizo totalizadores
		oTotais:RefreshTot()

		oView:Refresh("UF2MASTER")
		oView:Refresh("UF4DETAIL")

	endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RefreshUJ9 บ Autorณ Wellington Gon็alvesบ Dataณ 03/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que atualiza o grid de cobran็as adicionais		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Postumos			                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RefreshUJ9(lChangePlan)

	Local aArea			:= GetArea()
	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUF2 	:= oModel:GetModel("UF2MASTER")
	Local oModelUF4 	:= oModel:GetModel("UF4DETAIL")
	Local oModelUJ9 	:= oModel:GetModel("UJ9DETAIL")
	Local nX 			:= 1
	Local aRegras		:= {}
	Local lLinOK		:= .T.
	Local lRecalcImp 	:= SuperGetMV("MV_XFRCIMP", .F., .T.)
	Local nQtdLinAntes	:= 0
	Local nQtdLinApos	:= 0
	Local nValCobAd		:= 0
	Local nValAdesao	:= 0
	Local nLinhaUF4		:= oModelUF4:GetLine()
	Local nOperation 	:= oModel:GetOperation()

	Default	lChangePlan	:= .F.

	// fun็ใo que pesquisa as regras de cobran็as adicionais para o beneficiแrio
	PesqValAdic(@aRegras,lChangePlan)


	UF0->(DbSetOrder(1)) //UF0_FILIAL + UF0_CODIGO

	// habilito a inser็ใo de nova linha
	oModelUJ9:SetNoInsertLine(.F.)

	// habilito o grid para dele็ใo
	oModelUJ9:SetNoDeleteLine(.F.)

	// habilito a altera็ใo de linha
	oModelUJ9:SetNoUpdateLine(.F.)

	// se a opera็ใo for inclusใo, limpo o grid, senใo deleto todas as linhas
	if nOperation == MODEL_OPERATION_INSERT
		// fun็ใo que limpa o grid
		U_LimpaAcolsMVC(oModelUJ9,oView)
	else
		// fun็ใo que deleta todas as linhas do grid
		oModelUJ9:DelAllLine()
	endif

	if Len(aRegras) > 0

		For nX := 1 To Len(aRegras)

			lLinOK := .T.

			if !Empty(oModelUJ9:GetValue("UJ9_REGRA")) .OR. oModelUJ9:IsDeleted()

				nQtdLinAntes 	:= oModelUJ9:Length()
				nQtdLinApos 	:= oModelUJ9:AddLine()

				if nQtdLinApos == nQtdLinAntes
					Help(,,'Help',,"Ocorreu um erro na inclusao da Cobra็a Adicional!",1,0)
					lLinOK := .F.
					Exit
				else
					oModelUJ9:GoLine(oModelUJ9:Length())
					lLinOK := .T.
				endif

			endif

			// se a linha foi incluida com sucesso
			if lLinOK

				oModelUJ9:LoadValue( "UJ9_REGRA"  	, aRegras[nX , 01] 	)
				oModelUJ9:LoadValue( "UJ9_ITUJ5"   	, aRegras[nX , 02]  )
				oModelUJ9:LoadValue( "UJ9_TPREGR"   , aRegras[nX , 03] 	)
				oModelUJ9:LoadValue( "UJ9_VLRINI"   , aRegras[nX , 04] 	)
				oModelUJ9:LoadValue( "UJ9_VLRFIM"   , aRegras[nX , 05] 	)
				oModelUJ9:LoadValue( "UJ9_VLUNIT"   , aRegras[nX , 06] 	)
				oModelUJ9:LoadValue( "UJ9_QTD"   	, aRegras[nX , 07] 	)
				oModelUJ9:LoadValue( "UJ9_VLTOT" 	, aRegras[nX , 08] 	)
				oModelUJ9:LoadValue( "UJ9_ITUF4" 	, aRegras[nX , 09]	)
				oModelUJ9:LoadValue( "UJ9_NOME"   	, aRegras[nX , 10] 	)
				oModelUJ9:LoadValue( "UJ9_ADESAO"  	, aRegras[nX , 11] 	)

				nValCobAd	+= aRegras[nX , 08]
				nValAdesao	+= aRegras[nX , 11]

			endif

		Next nX

	endif

	// atualizo o valor do cabe็alho
	oModelUF2:LoadValue("UF2_VLCOB"	, nValCobAd )

	//-------------------------------------
	// Adesao por Regra de Contrato
	//-------------------------------------
	if oModelUF2:GetValue("UF2_STATUS") == "P"

		if UF0->(DbSeek(xFilial("UF0") + oModelUF2:GetValue("UF2_PLANO") ))

			if UF0->UF0_ADREGR == 'S'

				nValAdesao += UF0->UF0_ADESAO

				oModelUF2:LoadValue("UF2_ADESAO"	, nValAdesao )

			elseif UF0->UF0_ADPARC <> "S"

				oModelUF2:LoadValue("UF2_ADESAO"	, UF0->UF0_ADESAO )

			endif

		endif

	endif


	//restauro as linhas posicionadas
	oModelUF4:GoLine( nLinhaUF4 )
	oModelUJ9:GoLine( 1 )

	// desabilito a inser็ใo de nova linha
	oModelUJ9:SetNoInsertLine(.T.)

	// desabilito a dele็ใo de linha
	oModelUJ9:SetNoDeleteLine(.T.)

	// desabilito a altera็ใo de linha
	oModelUJ9:SetNoUpdateLine(.T.)

	// chamo fun็ใo que atualiza os valores do contrato
	if oView <> NIL

		//Chamo funcao para atualizar totalzadores
		if IsInCallStack("U_RIMPM003")
			if lRecalcImp
				oTotais:RefreshTot()
			endIf
		else
			oTotais:RefreshTot()
		endIf

	endif

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PesqValAdic บAutorณ Wellington Gon็alvesบ Dataณ 03/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo que pesqquisa as regras de contrato cobran็as adic. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Postumos			                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function PesqValAdic(aRegras,lChangePlan)

	Local aArea 		:= GetArea()
	Local aAreaUJ7 		:= UJ7->(GetArea())
	Local oModel 		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local nOperation 	:= oModel:GetOperation()
	Local oModelUF2  	:= oModel:GetModel("UF2MASTER") // CABEวALHO
	Local oModelUF3  	:= oModel:GetModel("UF3DETAIL") // PRODUTOS E SERVIวOS
	Local oModelUF4  	:= oModel:GetModel("UF4DETAIL") // BENEFICIARIOS
	Local oModelUJ9  	:= oModel:GetModel("UJ9DETAIL") // COBRANวAS ADICIONAIS
	Local cPulaLinha	:= chr(13)+chr(10)
	Local cQry			:= ""
	Local cTipoBenef	:= ""
	Local cTpRegra		:= ""
	Local cPlano		:= oModelUF2:GetValue( "UF2_PLANO" )
	Local cRegra		:= ""
	Local nQtdBenef		:= 0
	Local nQtd			:= 0
	Local nIdade		:= 0
	Local nValor		:= 0
	Local nNumDep		:= 0
	Local nLinAtUF4		:= oModelUF4:GetLine()
	Local aRegrasAux	:= {}
	Local aAux			:= {}
	Local aTipos		:= {}
	Local aDependentes	:= {"1","2"} // 1 - Beneficiario 2 - Agregado 3 - Titular
	Local lRegraValid	:= .T.
	Local nX			:= 1
	Local nY			:= 1
	//////////////////////////////////////////////////////////////
	////////////////// CONSULTA REGRAS POR IDADE /////////////////
	//////////////////////////////////////////////////////////////

	// grid de associados
	For nX := 1 To oModelUF4:Length()

		// posiciono na linha do grid
		oModelUF4:GoLine(nX)

		// se o beneficiario nao estiver deletado e estiver ativo
		if !oModelUF4:IsDeleted() .And. (Empty(oModelUF4:GetValue( "UF4_DTFIM" )) .Or. oModelUF4:GetValue( "UF4_DTFIM" ) >= dDatabase)

			// se a data de nascimento estiver preenchida
			if !Empty(oModelUF4:GetValue( "UF4_DTNASC" ))

				//caso houve mudanca de plano, reprocesso as idades dos beneficiarios
				if lChangePlan

					nIdade := U_UAgeCalculate(FWFldGet("UF4_DTNASC"),dDataBase)

					oModelUF4:LoadValue( "UF4_IDADE", nIdade )

				endif

				nIdade := oModelUF4:GetValue( "UF4_IDADE" )

				// 1 - Beneficiario 2 - Agregado 3 - Titular
				cTipoBenef := oModelUF4:GetValue( "UF4_TIPO" )

				//valido o tipo de regra
				if oModelUF4:GetValue( "UF4_TIPO" ) == '3'

					cTpRegra := "T"

				else

					cTpRegra := "I"

				endif


				// verifico se nao existe este alias criado
				If Select("QRYUJ5") > 0
					QRYUJ5->(DbCloseArea())
				EndIf

				//Valido se ้ regra especifica do beneficiario
				if Empty(FwFldGet("UF4_REGRA") ) .And. IsInCallStack("U_VlPlanFun")

					cQry := " SELECT "														+ cPulaLinha
					cQry += " UJ5_CODIGO AS CODIGO_REGRA, "                                 + cPulaLinha
					cQry += " UJ6_REGRA AS ITEM_REGRA, "                                    + cPulaLinha
					cQry += " UJ6_TPREGR AS TIPO_REGRA, "                                   + cPulaLinha
					cQry += " UJ6_VLRINI AS LIMITE_INICIAL, "                               + cPulaLinha
					cQry += " UJ6_VLRFIM AS LIMITE_FINAL, "                                 + cPulaLinha
					cQry += " UJ6_VLRCOB AS VALOR, "                                        + cPulaLinha
					cQry += " UJ6_ADESAO AS ADESAO, "										+ cPulaLinha
					cQry += " UJ6_INDIVI AS INDIVIDUAL "                                    + cPulaLinha
					cQry += " FROM "                                                        + cPulaLinha
					cQry += " " + RetSqlName("UF0") + " UF0 "                               + cPulaLinha
					cQry += " INNER JOIN "                                                  + cPulaLinha
					cQry += " " + RetSqlName("UJ5") + " UJ5 "                               + cPulaLinha
					cQry += " ON ( "                                                        + cPulaLinha
					cQry += " 	UJ5.D_E_L_E_T_ <> '*' "                                     + cPulaLinha
					cQry += " 	AND UJ5.UJ5_FILIAL = '" + xFilial("UJ5") + "' "             + cPulaLinha
					cQry += " 	AND UJ5.UJ5_CODIGO = UF0.UF0_REGRA "                        + cPulaLinha
					cQry += " ) "                                                           + cPulaLinha
					cQry += " INNER JOIN "                                                  + cPulaLinha
					cQry += " " + RetSqlName("UJ6") + " UJ6 "                               + cPulaLinha
					cQry += " ON ( "                                                        + cPulaLinha
					cQry += " 	UJ6.D_E_L_E_T_ <> '*' "                                     + cPulaLinha
					cQry += " 	AND UJ6.UJ6_FILIAL = '" + xFilial("UJ6") + "' "             + cPulaLinha
					cQry += " 	AND UJ6.UJ6_CODIGO = UF0.UF0_REGRA "                        + cPulaLinha
					cQry += " 	AND (  "                                                    + cPulaLinha
					cQry += " 		UJ6.UJ6_TPBENE = '" + cTipoBenef + "' "             	+ cPulaLinha
					cQry += "		AND UJ6.UJ6_TPREGR = '" + cTpRegra + "' "				+ cPulaLinha
					cQry += " 		AND UJ6.UJ6_VLRINI <= " + cValToChar(nIdade)         	+ cPulaLinha
					cQry += " 		AND UJ6.UJ6_VLRFIM >= " + cValToChar(nIdade)         	+ cPulaLinha
					cQry += " 	) "                                                         + cPulaLinha
					cQry += " ) "                                                           + cPulaLinha
					cQry += " WHERE "                                                       + cPulaLinha
					cQry += " UF0.D_E_L_E_T_ <> '*' "                                       + cPulaLinha
					cQry += " AND UF0.UF0_FILIAL = '" + xFilial("UF0") + "' "               + cPulaLinha
					cQry += " AND UF0.UF0_CODIGO = '" + cPlano + "' "                       + cPulaLinha

				else

					//valido se possui regra especifica para o beneficiario, se nao tiver e nao
					//for modificacao de plano, considera a regra ja carregada no campo UF2_REGRA
					if !Empty(FwFldGet("UF4_REGRA"))
						cRegra := FwFldGet("UF4_REGRA")
					else
						cRegra := FwFldGet("UF2_REGRA")
					endif

					cQry := " SELECT" 														+ cPulaLinha
					cQry += " 	UJ5_CODIGO AS CODIGO_REGRA,"								+ cPulaLinha
					cQry += " 	UJ6_REGRA AS ITEM_REGRA,"									+ cPulaLinha
					cQry += " 	UJ6_TPREGR AS TIPO_REGRA,"									+ cPulaLinha
					cQry += " 	UJ6_VLRINI AS LIMITE_INICIAL,"								+ cPulaLinha
					cQry += " 	UJ6_VLRFIM AS LIMITE_FINAL,"								+ cPulaLinha
					cQry += " 	UJ6_VLRCOB AS VALOR,"										+ cPulaLinha
					cQry += " 	UJ6_ADESAO AS ADESAO, "										+ cPulaLinha
					cQry += " 	UJ6_INDIVI AS INDIVIDUAL"									+ cPulaLinha
					cQry += " FROM " + RETSQLNAME("UJ5") + " UJ5" 							+ cPulaLinha
					cQry += " INNER JOIN " + RETSQLNAME("UJ6") + " UJ6" 					+ cPulaLinha
					cQry += " ON (UJ6.UJ6_FILIAL = UJ5.UJ5_FILIAL"							+ cPulaLinha
					cQry += " 		AND UJ6.UJ6_CODIGO = UJ5.UJ5_CODIGO"					+ cPulaLinha
					cQry += " 		AND UJ6.UJ6_TPBENE = '" + cTipoBenef + "'" 			+ cPulaLinha
					cQry += " 		AND UJ6.UJ6_TPREGR  = '" + cTpRegra + "' "				+ cPulaLinha
					cQry += " 		AND UJ6.UJ6_VLRINI <=  " + cValToChar(nIdade)			+ cPulaLinha
					cQry += " 		AND UJ6.UJ6_VLRFIM >=  " + cValToChar(nIdade)			+ cPulaLinha
					cQry += " 		AND UJ6.D_E_L_E_T_= ' '"								+ cPulaLinha
					cQry += " 	) "                                             			+ cPulaLinha
					cQry += " 	WHERE UJ5.D_E_L_E_T_= ' '"									+ cPulaLinha
					cQry += " 		AND UJ5_FILIAL = '" + xFilial("UJ5") 		+ "'"		+ cPulaLinha
					cQry += " 		AND UJ5_CODIGO = '" + cRegra + "'"						+ cPulaLinha

				Endif

				// funcao que converte a query generica para o protheus
				cQry := ChangeQuery(cQry)

				// crio o alias temporario
				TcQuery cQry New Alias "QRYUJ5"

				if QRYUJ5->(!Eof())

					While QRYUJ5->(!Eof())

						aAux := {}

						nValor := QRYUJ5->VALOR

						aadd(aAux , QRYUJ5->CODIGO_REGRA 			) // C๓digo da Regra
						aadd(aAux , QRYUJ5->ITEM_REGRA 				) // Item da Regra
						aadd(aAux , QRYUJ5->TIPO_REGRA 				) // Tipo da Regra
						aadd(aAux , QRYUJ5->LIMITE_INICIAL 			) // Limite Inicial
						aadd(aAux , QRYUJ5->LIMITE_FINAL 			) // Limite Final
						aadd(aAux , nValor 							) // Valor Unitแrio
						aadd(aAux , 1	 							) // Quantidade
						aadd(aAux , nValor 							) // Valor Total
						aadd(aAux , oModelUF4:GetValue("UF4_ITEM")	) // Item do Beneficiแrio
						aadd(aAux , oModelUF4:GetValue("UF4_NOME")	) // Nome do Beneficiแrio
						aadd(aAux , QRYUJ5->ADESAO					) // Adesao

						aadd(aRegrasAux , aAux)

						QRYUJ5->(DbSkip())

					EndDo

				endif

				// verifico se nao existe este alias criado
				If Select("QRYUJ5") > 0
					QRYUJ5->(DbCloseArea())
				EndIf

				//titular e beneficiario com regra especificia nao entra para contagem de beneficiarios
				if cTipoBenef <> "3" .AND. Empty(FwFldGet("UF4_REGRA") )

					//valido se o tipo de beneficario ja existe no array de aTipos para pesquisar as regras por quantidade
					nPosTipo := aScan( aTipos, { |x| Alltrim(x[1]) == Alltrim(cTipoBenef) } )

					if nPosTipo > 0

						aTipos[nPosTipo,2] += 1

					else

						Aadd(aTipos,{cTipoBenef,1})

					endif

				endif

			endif

		endif

	Next nX

	//verifico se existe regra para quantidade por tipo de beneficiario
	For nX := 1 To Len(aTipos)

		//////////////////////////////////////////////////////////////
		/////////////// CONSULTA REGRAS POR QUANTIDADE ///////////////
		//////////////////////////////////////////////////////////////

		// verifico se nao existe este alias criado
		If Select("QRYUJ5") > 0
			QRYUJ5->(DbCloseArea())
		EndIf

		//valido se foi chamado da rotina de validacao do campo UF2_PLANO, senao foi chamado, sera considerado a regra
		//ja vinculada ao campo UF2_REGRA
		if IsInCallStack("U_VlPlanFun")

			cQry := " SELECT "														+ cPulaLinha
			cQry += " UJ5.UJ5_CODIGO AS CODIGO_REGRA, "                             + cPulaLinha
			cQry += " UJ6.UJ6_REGRA AS ITEM_REGRA, "                                + cPulaLinha
			cQry += " UJ6.UJ6_TPREGR AS TIPO_REGRA, "                               + cPulaLinha
			cQry += " UJ6.UJ6_VLRINI AS LIMITE_INICIAL, "                           + cPulaLinha
			cQry += " UJ6.UJ6_VLRFIM AS LIMITE_FINAL, "                             + cPulaLinha
			cQry += " UJ6.UJ6_VLRCOB AS VALOR, "                                    + cPulaLinha
			cQry += " UJ6_ADESAO AS ADESAO, "										+ cPulaLinha
			cQry += " UJ6.UJ6_INDIVI AS INDIVIDUAL "                                + cPulaLinha
			cQry += " FROM "                                                        + cPulaLinha
			cQry += " " + RetSqlName("UF0") + " UF0 "                               + cPulaLinha
			cQry += " INNER JOIN "                                                  + cPulaLinha
			cQry += " " + RetSqlName("UJ5") + " UJ5 "                               + cPulaLinha
			cQry += " ON ( "                                                        + cPulaLinha
			cQry += " 	UJ5.D_E_L_E_T_ <> '*' "                                     + cPulaLinha
			cQry += " 	AND UJ5.UJ5_FILIAL = '" + xFilial("UJ5") + "' "             + cPulaLinha
			cQry += " 	AND UJ5.UJ5_CODIGO = UF0.UF0_REGRA "                        + cPulaLinha
			cQry += " ) "                                                           + cPulaLinha
			cQry += " INNER JOIN "                                                  + cPulaLinha
			cQry += " " + RetSqlName("UJ6") + " UJ6 "                               + cPulaLinha
			cQry += " ON ( "                                                        + cPulaLinha
			cQry += " 	UJ6.D_E_L_E_T_ <> '*' "                                     + cPulaLinha
			cQry += " 	AND UJ6.UJ6_FILIAL = '" + xFilial("UJ6") + "' "             + cPulaLinha
			cQry += " 	AND UJ6.UJ6_CODIGO = UF0.UF0_REGRA "                        + cPulaLinha
			cQry += " 	AND (  "                                                    + cPulaLinha
			cQry += "		UJ6.UJ6_TPREGR = 'N' "									+ cPulaLinha
			cQry += " 		AND UJ6.UJ6_TPBENE = '" + aTipos[nX,1] + "' "           + cPulaLinha
			cQry += " 		AND UJ6.UJ6_VLRINI <= " + cValToChar(aTipos[nX,2]) 	    + cPulaLinha
			cQry += " 		AND UJ6.UJ6_VLRFIM >= " + cValToChar(aTipos[nX,2])      + cPulaLinha
			cQry += " 	) "                                                         + cPulaLinha
			cQry += " ) "                                                           + cPulaLinha
			cQry += " WHERE "                                                       + cPulaLinha
			cQry += " UF0.D_E_L_E_T_ <> '*' "                                       + cPulaLinha
			cQry += " AND UF0.UF0_FILIAL = '" + xFilial("UF0") + "' "               + cPulaLinha
			cQry += " AND UF0.UF0_CODIGO = '" + cPlano + "' "                       + cPulaLinha
		else

			cQry := " SELECT "														+ cPulaLinha
			cQry += " UJ5.UJ5_CODIGO AS CODIGO_REGRA, "                             + cPulaLinha
			cQry += " UJ6.UJ6_REGRA AS ITEM_REGRA, "                                + cPulaLinha
			cQry += " UJ6.UJ6_TPREGR AS TIPO_REGRA, "                               + cPulaLinha
			cQry += " UJ6.UJ6_VLRINI AS LIMITE_INICIAL, "                           + cPulaLinha
			cQry += " UJ6.UJ6_VLRFIM AS LIMITE_FINAL, "                             + cPulaLinha
			cQry += " UJ6.UJ6_VLRCOB AS VALOR, "                                    + cPulaLinha
			cQry += " UJ6_ADESAO AS ADESAO, "										+ cPulaLinha
			cQry += " UJ6.UJ6_INDIVI AS INDIVIDUAL "                                + cPulaLinha
			cQry += " FROM "                                                        + cPulaLinha
			cQry += " " + RetSqlName("UJ5") + " UJ5 "                               + cPulaLinha
			cQry += " INNER JOIN "                                                  + cPulaLinha
			cQry += " " + RetSqlName("UJ6") + " UJ6 "                               + cPulaLinha
			cQry += " ON ( "                                                        + cPulaLinha
			cQry += " 	UJ6.D_E_L_E_T_ <> '*' "                                     + cPulaLinha
			cQry += " 	AND UJ5.UJ5_FILIAL = UJ6.UJ6_FILIAL "  				        + cPulaLinha
			cQry += " 	AND UJ5.UJ5_CODIGO = UJ6_CODIGO "                        	+ cPulaLinha
			cQry += "	AND UJ6.UJ6_TPREGR = 'N' "									+ cPulaLinha
			cQry += " 	AND UJ6.UJ6_TPBENE = '" + aTipos[nX,1] + "' "           	+ cPulaLinha
			cQry += " 	AND UJ6.UJ6_VLRINI <= " + cValToChar(aTipos[nX,2]) 	    	+ cPulaLinha
			cQry += " 	AND UJ6.UJ6_VLRFIM >= " + cValToChar(aTipos[nX,2])     	 	+ cPulaLinha
			cQry += " ) "                                                           + cPulaLinha
			cQry += " WHERE "                                                       + cPulaLinha
			cQry += " 	UJ5.UJ5_FILIAL = '" + xFilial("UJ5") + "' "             	+ cPulaLinha
			cQry += " 	AND UJ5.UJ5_CODIGO = '" + cRegra + "' "			           	+ cPulaLinha

		endif

		// funcao que converte a query generica para o protheus
		cQry := ChangeQuery(cQry)

		// crio o alias temporario
		TcQuery cQry New Alias "QRYUJ5"

		if QRYUJ5->(!Eof())

			While QRYUJ5->(!Eof())

				aAux := {}

				if QRYUJ5->INDIVIDUAL == "S"
					nQtd := aTipos[nX,2] - QRYUJ5->LIMITE_INICIAL + 1
				else
					nQtd := 1
				endif

				aadd(aAux , QRYUJ5->CODIGO_REGRA 			) // C๓digo da Regra
				aadd(aAux , QRYUJ5->ITEM_REGRA 				) // Item da Regra
				aadd(aAux , QRYUJ5->TIPO_REGRA 				) // Tipo da Regra
				aadd(aAux , QRYUJ5->LIMITE_INICIAL 			) // Limite Inicial
				aadd(aAux , QRYUJ5->LIMITE_FINAL 			) // Limite Final
				aadd(aAux , QRYUJ5->VALOR 					) // Valor Unitแrio
				aadd(aAux , nQtd	 						) // Quantidade
				aadd(aAux , QRYUJ5->VALOR * nQtd			) // Valor Total
				aadd(aAux , ""								) // Item do Beneficiแrio
				aadd(aAux , ""								) // Nome do Beneficiแrio
				aadd(aAux , QRYUJ5->ADESAO					) // Adesao

				aadd(aRegrasAux , aAux)

				QRYUJ5->(DbSkip())

			EndDo

		endif

	Next nX

	//////////////////////////////////////////////////////////////
	////////// VALIDAวรO DAS CONDIวีES DA COB. ADICIONAL /////////
	//////////////////////////////////////////////////////////////

	For nX := 1 To Len(aTipos)

		// verifico os tipos de beneficiแrios que sใo considerados como dependente
		if aScan( aDependentes, { |x| Alltrim(x) == Alltrim(aTipos[nX,1]) } ) > 0
			nNumDep += aTipos[nX,2]
		endif

	Next nX

	// verifico todas as regras consultadas
	For nX := 1 To Len(aRegrasAux)

		lRegraValid := .T.
		lIdadeDepOK	:= .F.

		// verifico se existe uma condi็ใo para a regra
		UJ7->(DbSetOrder(1)) // UJ7_FILIAL + UJ7_CODIGO + UJ7_REGRA + UJ7_ITEM
		if UJ7->(DbSeek(xFilial("UJ7") + aRegrasAux[nX,1] + aRegrasAux[nX,2]))

			While UJ7->(!Eof()) .AND. UJ7->UJ7_FILIAL == xFilial("UJ7") ;
					.AND. UJ7->UJ7_CODIGO == aRegrasAux[nX,1] ;
					.AND. UJ7->UJ7_REGRA == aRegrasAux[nX,2]

				if UJ7->UJ7_TPCOND == "I" // Tipo de condi็ใo = Idade do Dependente

					// percorro o grid de beneficiarios
					For nY := 1 To oModelUF4:Length()

						// posiciono na linha do grid
						oModelUF4:GoLine(nY)

						// se o beneficiario nao estiver deletado
						if !oModelUF4:IsDeleted()

							// verifico se o tipo do beneficiario ้ considerado como dependente
							if aScan( aDependentes, { |x| Alltrim(x) == Alltrim(oModelUF4:GetValue("UF4_TIPO")) } ) > 0

								// se a idade do dependente estiver no intervalo definido
								if oModelUF4:GetValue("UF4_IDADE") >= UJ7->UJ7_VLRINI .AND. oModelUF4:GetValue("UF4_IDADE") <= UJ7->UJ7_VLRFIM
									lIdadeDepOK := .T.
									Exit
								endif

							endif

						endif

					Next nY

					// se nใo foram encontrados dependentes com idade dentro do intervalo da regra
					if !lIdadeDepOK
						lRegraValid := .F.
						Exit
					endif

				elseif UJ7->UJ7_TPCOND == "T" // Tipo de condi็ใo = Idade do Titular

					// posiciono no beneficiario do tipo titular
					if oModelUF4:SeekLine({{"UF4_TIPO","3"}},.F.,.T.)

						// se a idade do titular nใo estiver no intervalo definido
						if !( oModelUF4:GetValue("UF4_IDADE") >= UJ7->UJ7_VLRINI .AND. oModelUF4:GetValue("UF4_IDADE") <= UJ7->UJ7_VLRFIM )
							lRegraValid := .F.
							Exit
						endif

					else

						// se nใo encontrou o beneficiario titular
						lRegraValid := .F.
						Exit

					endif

				elseif UJ7->UJ7_TPCOND == "N" // Tipo de condi็ใo = Numero de dependentes

					// se o n๚mero de dependentes nใo estiver no intervalo definido
					if !( nNumDep >= UJ7->UJ7_VLRINI .AND. nNumDep <= UJ7->UJ7_VLRFIM )
						lRegraValid := .F.
						Exit
					endif

				endif

				UJ7->(DbSkip())

			EndDo

		endif

		// se a regra foi validada
		if lRegraValid
			aadd(aRegras,aRegrasAux[nX])
		endif

	Next nX

	oModelUF4:Goline(nLinAtUF4)

	if oView <> Nil
		oView:Refresh("UF4DETAIL")
	endif

	RestArea(aAreaUJ7)
	RestArea(aArea)

Return()

/*/{Protheus.doc} CGCBeneficiarioValida
Funcao para validacao do CPF do Beneficiario do Contrato
@author g.sampaio
@since 23/05/2019
@param cCPFBeneficiario, caracter, CPF digitado para o beneficiario atual
@version 1.0
@return nil
@type function
/*/
User Function CGCBeneficiarioValida( cCPFBeneficiario )

	Local aCGCBenef				:= {}
	Local cCPFAtual				:= ""
	Local cItem 				:= ""
	Local lRetorno				:= .T.
	Local nX					:= 0
	Local nLinhaAtual			:= 0
	Local nPos					:= 0
	Local oModel   				:= FWModelActive()
	Local oModelUF4 			:= oModel:GetModel("UF4DETAIL")
	Local nLinhaAtual			:= oModelUF4:GetLine()

	Default	cCPFBeneficiario	:= ""

// pego a linha atual do acols
	nLinhaAtual := oModelUF4:GetLine()

// vou percorrer todos os itens da UF4
	For nX := 1 To oModelUF4:Length()

		// vou posicionar na UF4
		oModelUF4:Goline(nX)

		// pego o CPF do beneficiario
		cCPFAtual	:= oModelUF4:GetValue('UF4_CPF')

		// pego o item da linha
		cItem		:= oModelUF4:GetValue('UF4_ITEM')

		// vou atualizando os CPF dos beneficiarios
		If nX <> nLinhaAtual .And. !Empty( Alltrim(cCPFAtual) )
			aadd( aCGCBenef,{ Alltrim(cCPFAtual), cItem })
		EndIf

	Next nX

// valido se o CPF atual ja existe no contrato atual
	If Len( aCGCBenef ) > 0

		// valido no array de beneficiarios se existe o CPF digitado...
		nPos := aScan( aCGCBenef, { |x| Alltrim(x[1]) == Alltrim(cCPFBeneficiario) } )

		// caso nPos maior que zero, mando um help para o usuario
		If nPos > 0
			Help(,,'Help',,"O CPF digitado para o Beneficiario, jแ se encontra em uso por outro Beneficiario deste mesmo contrato! Item:" + aCGCBenef[nPos,2] ,1,0)
			lRetorno := .F.
		EndIf
	EndIf

	oModelUF4:Goline(nLinhaAtual)

Return(lRetorno)

/*/{Protheus.doc} ValPrimeiroVencimento
Funcao para validar o primeiro vencimento do contrato
@author g.sampaio
@since 27/05/2019
@param dPrimVenc, caracter, data do primeiro vencimento  
@version 1.0
@return nil
@type function
/*/

User Function ValPrimeiroVencimento( dPrimVenc )

	Local dDataInclusao	:= M->UF2_DATA
	Local lRetorno		:= .T.
	Local nLimite		:= SuperGetMV("ES_LPRIMVEN",,45)	// quantidade limite do primeiro vencimento
	Local oModel   		:= FWModelActive()
	Local oModelUF2 	:= oModel:GetModel("UF2MASTER")
	Local nOperation 	:= oModel:GetOperation()

	Default dPrimVenc 	:= Stod("")

	//quando for inclusao ou o contrato esteja como pre contrato, valido o limite maximo de dias para primeiro vencimento
	if nOperation == MODEL_OPERATION_INSERT .Or. UF2->UF2_STATUS = 'P'

		// verifico se a data do primeiro vencimento ้ menor que a database
		If lRetorno .And. dPrimVenc < dDataBase
			Help(,,'Help',," Data do primeiro vencimento ้ menor que a data base do sistema. Data Atual :" + ;
				DtoC(dDataBase) + ", primeiro vencimento :" + DtoC(dPrimVenc),1,0)
			lRetorno 	:= .F.
		EndIf

		// verifico se a diferenca entre a data de inclusao e o primeiro vencimento, ้ maior que o limite
		If lRetorno .And. DateDiffDay( dDataInclusao, dPrimVenc ) > nLimite
			Help(,,'Help',," Data do primeiro vencimento nใo pode ser superior a " + cValToChar(nLimite) + ;
				" dias, a partir da data de inclusao do contrato! Data da Inclusao do Contrato :" + DtoC(dDataInclusao),1,0)
			lRetorno	:= .F.
		EndIf

		//permite alterar apenas o dia de vencimento, mes e ano nao e permitido
	elseif Month(UF2->UF2_PRIMVE) <> Month(M->UF2_PRIMVE) .Or. Year(UF2->UF2_PRIMVE) <> Year(M->UF2_PRIMVE)

		Help(,,'Help',," Para contratos ativos ้ permitido apenas alteracao do dia de vencimento! ",1,0)
		lRetorno	:= .F.

	endif

Return(lRetorno)

/*/{Protheus.doc} ValPrimeiroVencimento
Funcao para validar edicao do campo cliente e loja do contrato
@author Leandro Rodrigues
@since 27/05/2019
@param Nenhum  
@version 1.0
@return nil
@type function
/*/
User Function ValCliEdit()

	Local lRet := .F.

	//Valida se permite edicao do campo cliente e loja
	If !Empty(M->UF2_PLANO) .And. ((Type("lImp") == 'L' .And. lImp) .Or. M->UF2_STATUS == 'P' .Or. IsInCallStack("U_RFUNA006"))
		lRet := .T.
	Endif


Return lRet

/*/{Protheus.doc} ValCliInf
Valida se Cliente informado possui contrato ativo
@type function
@version 1.0
@author Raphael Martins
@since 03/02/2021
@param cContrato, character, Codigo do Contrato 
/*/
User Function ValCliInf(cContrato)

	Local lRet 			:= .T.
	Local oModel  		:= FWModelActive()
	Local oModelUF2 	:= oModel:GetModel("UF2MASTER")
	Local lValClient	:= SuperGetMv("MV_XVALCLI",,.T.) //habilita checagem de cliente
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local nOperation 	:= oModel:GetOperation()
	Local cQry			:= ""
	Default	cContrato	:= oModelUF2:GetValue("UF2_CODIGO")

	//validar se cliente ja tem contrato ativo
	If lValClient

		cQry := " SELECT"
		cQry += "	COUNT(*) QTDE"
		cQry += "	FROM "+ RETSQLNAME("UF2") + " UF2"
		cQry += "	WHERE UF2.D_E_L_E_T_= ' '"
		cQry += "	AND UF2_STATUS <> 'C'"
		cQry += "	AND UF2_FILIAL = '"+ xFilial("UF2") +"'"
		cQry += "	AND UF2_CLIENT = '"+ oModelUF2:GetValue("UF2_CLIENT") + "'"
		cQry += "	AND UF2_CODIGO <> '" + cContrato + "' "

		// para plano pet desconsidero os contratos de uso 3-pet
		if lPlanoPet
			cQry += " AND UF2_USO <> '3' "
		endif

		cQry:= ChangeQuery(cQry)

		If Select("QUF2")>0
			QUF2->(DbCloseArea())
		Endif

		TcQuery cQry New Alias "QUF2"

		if lPlanoPet
			//Se cliente ja possui contrato ativo e o uso for ambos ou humano
			If QUF2->QTDE > 0 .And. oModelUF2:GetValue("UF2_USO") <> "3"
				Help(,,'Help',,"Cliente informado jแ possui contrato ativo, Opera็ใo Cancelada!",1,0)
				lRet := .F.
			Endif
		else

			//Se cliente ja possui contrato ativo
			If QUF2->QTDE > 0
				Help(,,'Help',,"Cliente informado jแ possui contrato ativo, Opera็ใo Cancelada!",1,0)
				lRet := .F.
			Endif

		endIf

	Endif

Return lRet

/*/{Protheus.doc} NumMaxBeneficiario
Valido se atingiu o numero maximo de beneficiarios
@author g.sampaio
@since 29/08/2019
@version P12
@param oModelUF4, 	objeto, 	modelo de dados de beneficiarios
@param cPlnSeg, 	caracter, 	codigo do plano de seguro
@return lRetorno, 	logico, 	retorno logico da validacao
/*/

User Function NumMaxBeneficiario( oModelUF4, cPlnSeg )

	Local aArea			:= GetArea()
	Local aAreaUI2		:= UI2->( GetArea() )
	Local aSolucao		:= {}
	Local cDscPlnSeg	:= ""
	Local lRetorno		:= .T.
	Local nMaxAli		:= 0
	Local nMaxBen 		:= 0
	Local nContBen		:= 0
	Local nContAli		:= 0
	Local nLinhaAtu 	:= 0
	Local nI			:= 0

	Default cPlnSeg		:= ""

// verifico se o plano de seguro esta preenchido
	If !Empty(cPlnSeg)

		// posiciono no plano e pego a quantidade
		UI2->( DbSetOrder(1) )
		If UI2->( MsSeek( xFilial("UI2")+cPlnSeg ) )

			// descricao do plano de seguro
			cDscPlnSeg	:= UI2->UI2_NOMSEG

			// numero maximo de beneficiario
			nMaxBen		:= UI2->UI2_MAXBEN

		EndIf

		// pego a linha atual
		nLinhaAtu := oModelUF4:GetLine()

		// percorro os beneficiarios digitados ate o momento
		For nI := 1 To oModelUF4:Length()

			// posiciono na linha atual
			oModelUF4:Goline(nI)

			// verifico se a linha esta deletada
			If !oModelUF4:IsDeleted()

				// verifico se o tipo e diferente do titular
				// verifico quantos beneficiarios do tipo alimentacao tem
				If (nI == nLinhaAtu) .And. (FwFldGet("UF4_TPPLN", nI)  <> "0" )
					nContBen++
				ElseIf (nI <> nLinhaAtu) .AND. Empty(oModelUF4:GetValue("UF4_TPPLN")) .And. oModelUF4:GetValue("UF4_TPPLN") <> "0"
					nContBen++
				EndIf

			EndIf

		Next nI

		// verifico se a quantida de beneficiarios e maior que o numero
		// maximo de benefeciarios do plano
		If nContBen > nMaxBen

			// zero o array de solucao
			aSolucao := {}

			// alimento o array de solucao da funcao Help
			Aadd( aSolucao, 'A Quantidade de beneficiarios deve ser menor ou igual a <b>' + cValToChar(nMaxBen) + '</b>' )

			// help de mensagem para o usuario
			Help( ,, 'NumMaxBeneficiario',, 'A Quantidade de beneficiarios deve respeitar a quantidade ';
				+ 'estipulada no <b>Plano de seguro : ' + cPlnSeg + ' - ' + cDscPlnSeg + '</b>', 1, 0 ,;
				Nil, Nil, Nil, Nil, Nil, aSolucao )

			// atualizo o retorno da funcao com o valor negativo
			lRetorno := .F.

		EndIf

		// posiciono na linha atual novamente
		oModelUF4:Goline(nLinhaAtu)

	EndIf

	RestArea( aAreaUI2 )
	RestArea( aArea )

Return( lRetorno )

/*/{Protheus.doc} MaxBenAlimentacao
Valido se atingiu o numero maximo de beneficiarios
@author g.sampaio
@since 29/08/2019
@version P12
@param oModelUF4, 	objeto, 	modelo de dados de beneficiarios
@param cPlnSeg, 	caracter, 	codigo do plano de seguro
@return lRetorno, 	logico, 	retorno logico da validacao
/*/

User Function MaxBenAlimentacao( oModelUF4, cPlnSeg )

	Local aArea			:= GetArea()
	Local aAreaUI2		:= UI2->( GetArea() )
	Local aSolucao		:= {}
	Local cDscPlnSeg	:= ""
	Local lRetorno		:= .T.
	Local nMaxAli		:= 0
	Local nContAli		:= 0
	Local nLinhaAtu 	:= 0
	Local nI			:= 0

	Default cPlnSeg		:= ""

	// verifico se o plano de seguro esta preenchido
	If !Empty(cPlnSeg)

		// posiciono no plano e pego a quantidade
		UI2->( DbSetOrder(1) )
		If UI2->( MsSeek( xFilial("UI2")+cPlnSeg ) )

			// descricao do plano de seguro
			cDscPlnSeg	:= UI2->UI2_NOMSEG

			// numero maximo de beneficiario do beneficio alimenticio
			nMaxAli		:= UI2->UI2_MAXALI

		EndIf

		// pego a linha atual
		nLinhaAtu := oModelUF4:GetLine()

		// percorro os beneficiarios digitados ate o momento
		For nI := 1 To oModelUF4:Length()

			// posiciono na linha atual
			oModelUF4:Goline(nI)

			// verifico se a linha esta deletada
			If !oModelUF4:IsDeleted()

				// verifico quantos beneficiarios do tipo alimentacao tem
				If (nI == nLinhaAtu) .And. (FwFldGet("UF4_TPPLN", nI)  $ "1/3")
					nContAli++
				ElseIf nI <> nLinhaAtu .And. oModelUF4:GetValue("UF4_TPPLN") $ "1/3"
					nContAli++
				EndIf

			EndIf

		Next nI

		// verifico se a quantida de beneficiarios e maior que o numero
		// maximo de benefeciarios do plano
		If lRetorno .And. (nContAli > nMaxAli)

			// zero o array de solucao
			aSolucao := {}

			// alimento o array de solucao da funcao Help
			Aadd( aSolucao, 'A Quantidade de beneficiarios do auxilio alimenticio deve ser menor ou igual a <b>' + cValToChar(nMaxAli) + '</b>' )

			// help de mensagem para o usuario
			Help( ,, 'MaxBenAlimentacao',, 'A Quantidade de beneficiarios do auxilio alimenticio deve respeitar a quantidade ';
				+ 'estipulada no <b>Plano de seguro : ' + cPlnSeg + ' - ' + cDscPlnSeg + '</b>', 1, 0 ,;
				Nil, Nil, Nil, Nil, Nil, aSolucao )

			// atualizo o retorno da funcao com o valor negativo
			lRetorno := .F.

		EndIf

		// posiciono na linha atual novamente
		oModelUF4:Goline(nLinhaAtu)

	EndIf

	RestArea( aAreaUI2 )
	RestArea( aArea )

Return( lRetorno )

/*/{Protheus.doc} VALTPPLN
Valido se atingiu o numero maximo de beneficiarios
@author g.sampaio
@since 29/08/2019
@version P12
@param oModelUF4, 	objeto, 	modelo de dados de beneficiarios
@param cPlnSeg, 	caracter, 	codigo do plano de seguro
@return lRetorno, 	logico, 	retorno logico da validacao
/*/

User Function VALTPPLN()

	Local aArea 	:= GetArea()
	Local lRetorno 	:= .T.
	Local oModel	:= FWModelActive()
	Local oModelUF4	:= oModel:GetModel("UF4DETAIL")
	Local nLinhaAtu :=	0

	nLinhaAtu := oModelUF4:GetLine()

	if FwFldGet("UF4_TPPLN", nLinhaAtu) <> "0"

		// verifico se o plano de seguro esta preenchido
		If Empty( FwFldGet("UF2_PLNSEG") )
			lRetorno	:= .F.
		EndIf

		// verifico se o beneficiario e titular
		If lRetorno .And. FwFldGet("UF4_TIPO", nLinhaAtu) == "3"
			lRetorno	:= .F.
		EndIf

	endif

	RestArea( aArea )

Return(lRetorno)

/*/{Protheus.doc} UWhenCarVencto
Valida o grupo de usuarios que podera alterar a carencia do contrato
@type function
@version 1.0
@author Raphael Martins
@since 22/12/2020
@return logico, permiti alterar ou nao o campo UF4_CAREN
/*/
User Function UWhenCarVencto()

	Local aArea 		:= GetArea()
	Local aGrupoUsr		:= {}
	Local cPermitidos	:= Alltrim(SuperGetMv("MV_XGRPCAR",,"")) //Grupos de Usuarios que podem alterar a carencia do contrato
	Local lRet 			:= .F.
	Local nI			:= ""
	Local oModel   		:= FWModelActive()
	Local oModelUF2 	:= oModel:GetModel("UF2MASTER")
	Local nOperation 	:= oModel:GetOperation()

	//para o campo primeiro vencimento, nao valido o grupo de usuario, caso seja inclusao ou pre contrato
	if ReadVar() == "M->UF2_PRIMVE" .And. (nOperation == MODEL_OPERATION_INSERT .Or. UF2->UF2_STATUS = 'P')

		lRet := .T.

	endif

	if !lRet

		//Retorno o grupo do usuario logado
		aGrupoUsr := UsrRetGrp(RetCodUsr())

		For nI := 1 To Len(aGrupoUsr)

			if aGrupoUsr[nI] $ cPermitidos

				lRet := .T.

			endif

		Next

	endif

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} FUN002PET
Descricao do plano no contrato
@type function
@version 1.0 
@author g.sampaio
@since 03/07/2021
@param oPanel, object, objeto do painel
/*/
Static Function FUN002PET(oPanel)

	oStatus := ObjStatus():New(oPanel)

Return(Nil)

/*/{Protheus.doc} ObjStatus
Classe de Status da tela
@type class
@version 1.0
@author g.sampaio
@since 05/07/2021
/*/
	Class ObjStatus

		Data oStatus
		Data cDescriPlano

		Method New() Constructor
		Method RefreshStatus()

	EndClass

/*/{Protheus.doc} ObjStatus::New
Metodo construtor da classe de status
@type method
@version 1.0  
@author g.sampaio
@since 05/07/2021
@param oPanel, object, objeto de painel da tela
/*/
Method New(oPanel) Class ObjStatus

	Local aArea 		:= GetArea()
	Local aAreaUF0		:= UF0->(GetArea())
	Local oModel		:= FWModelActive()
	Local oModelUF2 	:= oModel:GetModel("UF2MASTER")
	Local nOperation 	:= oModel:GetOperation()
	Local oFont20N		:= TFONT():New("Arial",,20,,.T.,,,,.T.,.F.) 	///Fonte 20 Negrito

	Default oPanel		:= Nil

	Self:cDescriPlano	:= "Plano sem uso definido"

	UF0->(DbSetOrder(1))
	if UF0->( MsSeek( xFilial("UF0") + oModelUF2:GetValue("UF2_PLANO") ) )

		if UF0->UF0_USO == "1"	// ambos
			Self:cDescriPlano 	:= "Uso do Plano para Humano e Pet - " + UF0->UF0_CODIGO + " - " + AllTrim(Capital(UF0->UF0_DESCRI))
		elseIf UF0->UF0_USO == "2" // humano
			Self:cDescriPlano 	:= "Uso do Plano para Humano - " + UF0->UF0_CODIGO + " - " + AllTrim(Capital(UF0->UF0_DESCRI))
		elseIf UF0->UF0_USO == "3" // pet
			Self:cDescriPlano 	:= "Uso do Plano para Pet - " + UF0->UF0_CODIGO + " - " + AllTrim(Capital(UF0->UF0_DESCRI))
		else
			Self:cDescriPlano	:= "Plano sem uso definido"

		endIf

	endIf

	@005,((oPanel:nClientWidth/2)/2) - 200 SAY Self:oStatus PROMPT Self:cDescriPlano SIZE 400, 010 OF oPanel FONT oFont20N COLORS CLR_GREEN,16777215 PIXEL CENTER

	// se nใo for inclusใo, atualiza os valores atuais
	if nOperation <> 3

		// chamo fun็ใo que atualiza os valores do contrato
		Self:RefreshStatus()

	endif

	RestArea(aAreaUF0)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} ObjStatus::RefreshStatus
Metodo para atualizar o objeto de status
@type method
@version 1.0
@author g.sampaio
@since 05/07/2021
/*/
Method RefreshStatus() Class ObjStatus

	Local aArea 		:= GetArea()
	Local aAreaUF0		:= UF0->(GetArea())
	Local oModel		:= FWModelActive()
	Local oModelUF2 	:= oModel:GetModel("UF2MASTER")

	UF0->(DbSetOrder(1))
	if UF0->( MsSeek( xFilial("UF0") + oModelUF2:GetValue("UF2_PLANO") ) )

		if UF0->UF0_USO == "1"	// ambos
			Self:cDescriPlano 	:= "Uso do Plano para Humano e Pet - " + UF0->UF0_CODIGO + " - " + AllTrim(Capital(UF0->UF0_DESCRI))
		elseIf UF0->UF0_USO == "2" // humano
			Self:cDescriPlano 	:= "Uso do Plano para Humano - " + UF0->UF0_CODIGO + " - " + AllTrim(Capital(UF0->UF0_DESCRI))
		elseIf UF0->UF0_USO == "3" // pet
			Self:cDescriPlano 	:= "Uso do Plano para Pet - " + UF0->UF0_CODIGO + " - " + AllTrim(Capital(UF0->UF0_DESCRI))
		else
			Self:cDescriPlano	:= "Plano sem uso definido"
		endIf

	endIf

	Self:oStatus:Refresh()

	RestArea(aAreaUF0)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} LinhaBenef
Funcao para a validacao do beneficiario
@type function
@version 1.0
@author g.sampaio
@since 06/09/2021
@param oMdlPos, object, modelo de dados da linha do beneficiario
@return logical, retorno sobre a validacao
/*/
Static Function LinhaBenef(oMdlPos)

	Local lRetorno          := .T.

	if Empty(oMdlPos:GetValue("UF4_DTNASC"))

		// retorno falso da validacao
		lRetorno := .F.

		// mensagem para o usuario
		oMdlPos:GetModel():SetErrorMessage('UF4DETAIL', "UF4_DTNASC" , 'UF4DETAIL' , 'UF4_DTNASC' , "Campo - Data de Nascimento",;
			'A Data de Nascimento <b>Dt.Nascimento</b> do beneficiario deve estar preenchida, para o bom funcionamento da rotina de contratos.',;
			'Preencha a data de nascimento do beneficiแrio.' )

	endIf

Return(lRetorno)

Static Function CalcDesconto(nVlrBrutoCont)

	Local aArea 		:= GetArea()
	Local aAreaUF2		:= UF2->(GetArea())
	Local nVlrRegra		:= 0
	Local nVlrReal		:= 0
	Local oModel		:= FWModelActive()
	Local oModelUF2 	:= oModel:GetModel("UF2MASTER")
	Local cRegra		:= oModelUF2:GetValue("UF2_REGRA")
	Local cFormaPg		:= oModelUF2:GetValue("UF2_FORPG")
	Local nDesconto		:= oModelUF2:GetValue("UF2_DESCON")
	Local nDescRegra	:= oModelUF2:GetValue("UF2_DESREG")
	Local nNovoDesc		:= 0


//zero desconto para reaplicar desconto de regra
	oModelUF2:LoadValue("UF2_DESCON" , nDesconto - nDescRegra)
	oModelUF2:LoadValue("UF2_DESREG" , 0)

//recarrego o valor de desconto sem o desconto de regra
	nDesconto		:= oModelUF2:GetValue("UF2_DESCON")

//-- Aplica desconto de regra, caso houver regra cadastrada
	UJZ->( dbSetOrder(2) ) //-- UJZ_FILIAL+UJZ_CODIGO+UJZ_FORPG
	If UJZ->( MsSeek(xFilial("UJZ") + cRegra + cFormaPg) )

		nVlrRegra		:= UJZ->UJZ_VALOR
		nVlrReal		:= nVlrBrutoCont - nDesconto

		If UJZ->UJZ_TPDESC == "R"
			nNovoDesc := nVlrRegra
		Else
			nNovoDesc := ((nVlrReal * nVlrRegra) / 100)
		EndIf

		oModelUF2:LoadValue("UF2_DESCON" , nDesconto + nNovoDesc)
		oModelUF2:LoadValue("UF2_DESREG" , nNovoDesc)

	EndIf

	RestArea(aArea)
	RestArea(aAreaUF2)

Return(nDesconto + nNovoDesc)
