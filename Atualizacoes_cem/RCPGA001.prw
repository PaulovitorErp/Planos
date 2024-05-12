#include "totvs.ch"
#include "fwmvcdef.ch"
#include "topconn.ch"
#INCLUDE 'FWEditPanel.CH'

/*/{Protheus.doc} RCPGA001
Rotina de Contrato de Cemitério
@type function
@version 2.0
@author TOTVS
@since 18/02/2016
/*/
User Function RCPGA001()

	Local oBrowse
	Local lAtivaNegociacao    	:= SuperGetMV("MV_XATVNEG",, .F.)           // ativa ou nao a regra de negociacao
	Local lCemiterio 			:= SuperGetMV("MV_XCEMI",.F., .F.)

	Private l030Auto			:= .F.
	Private lRegSel				:= .F.

	if !lCemiterio
		MsgAlert("Parametro MV_XCEMI desabilitado para a filial, não é possível abrir o contrato de cemiterio!")
	else

		// atribuo atalhos do teclado na rotina de contratos de cemiterio
		SetKey(VK_F6,{|| U_RCPGE046(U00->U00_CODIGO)}) // painel financeiro
		SetKey(VK_F7,{|| U_RCPGA040(1)}) // apontamento de servicos
		SetKey(VK_F8,{|| U_RCPGE041()}) // consulta obitos
		SetKey(VK_F9,{|| U_RCPGE044()}) // gera taxa de manutencao

		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias("U00")
		oBrowse:SetDescription("Contrato Cemitério")

		// verifico se a regra de negociacao esta ativada
		if lAtivaNegociacao

			// legenda de bloqueio de desconto
			oBrowse:AddLegend("U00_STATUS == 'P' .And. U00_DSCBLQ == '1'", "YELLOW", 	"Bloqueio de Desconto")
			oBrowse:AddLegend("U00_STATUS == 'P' .And. U00_DSCBLQ == '2'" , "GRAY"	, 	"Desconto Rejeitado")

		endIf

		oBrowse:AddLegend("U00_STATUS == 'A' .And. U00_TPCONT == '2'", "PINK",		"Ativo | Integração de Empresas")
		oBrowse:AddLegend("U00_STATUS == 'P'", "WHITE", 	"Pré-Cadastro")
		oBrowse:AddLegend("U00_STATUS == 'A'", "GREEN",		"Ativo")
		oBrowse:AddLegend("U00_STATUS == 'S'", "ORANGE",	"Suspenso")
		oBrowse:AddLegend("U00_STATUS == 'C'", "BLUE",		"Cancelado")
		oBrowse:AddLegend("U00_STATUS == 'F'", "RED",		"Finalizado")
		oBrowse:Activate()

		// limpo os atalhos do teclado na rotina de contratos de cemiterio
		SetKey(VK_F6,{|| }) // painel financeiro
		SetKey(VK_F7,{|| }) // apontamento de servicos
		SetKey(VK_F8,{|| }) // consulta obitos
		SetKey(VK_F9,{|| }) // gera taxa de manutencao

	endIf

Return(Nil)

/*/{Protheus.doc} MenuDef
menu de rotinas vinculadas ao contrato
@type function
@version 1.0
@author TOTVS
@since 18/02/2016
@return array, array de retorno com as rotinas
@histouy 29/05/2020, g.sampaio, VPDV-473 - A rotina de liquidacao RCPGE034 no menu
do contrato, para executar a torina de Liquidacao.
- Feito a organização da declracao do array de menu.
/*/
Static Function MenuDef()

	Local aRotina 				:= {}
	Local aRotManut 			:= {}
	Local aRotEnd 				:= {}
	Local aRotServ 				:= {}
	Local aRotReaj				:= {}
	Local aRotTxMan				:= {}
	Local aRotTrsEnd			:= {}
	Local aRotRetCinz			:= {}
	Local aRotTermo				:= {}
	Local aRotApo				:= {}
	Local aRotNicho				:= {}
	Local aRotTransf			:= {}
	Local aRotCli				:= {}
	Local aRotEsp				:= {}
	Local aDocumentos			:= {}
	Local aSolicitacoes			:= {}
	Local aAgendamentos			:= {}
	Local lTermoCustomizado		:= SuperGetMV("MV_XTERMOC", .F., .F.) 		// parametro para informar se utilizo a impressao de termos customizada
	Local lAtivaNegociacao  	:= SuperGetMV("MV_XATVNEG", .F., .F.)           // ativa ou nao a regra de negociacao
	Local lAPICliente			:= SuperGetMV("MV_XAPICLI", .F.,.F.)
	Local lAtivaRegra			:= SuperGetMv("MV_XREGCEM", .F.,.F.)
	Local lAtuIndice			:= SuperGetMv("MV_XATUIND", .F.,.F.)
	Local lAnexaDoc				:= SuperGetMV("MV_XANXDOC", .F.,.F.)
	Local oVirtusGestaoAcessos	:= VirtusGestaoAcessos():New()

	// carrego os acessos do usuario
	oVirtusGestaoAcessos:AcessosUsuario()

	// rotinas de anexo de documentos
	Aadd( aDocumentos, {"Anexar documentos","U_RUTIL50A(U00->U00_CODIGO, 'C', 'RCPGA001', U00->U00_CODIGO)", 0, 4} )
	Aadd( aDocumentos, {"Documentos","U_RUTIL50B(U00->U00_CODIGO, 'C', 'RCPGA001', U00->U00_CODIGO)", 0, 4} )
	Aadd( aDocumentos, {"Historico","U_RUTIL050(U00->U00_CODIGO, 'C', 'RCPGA001', U00->U00_CODIGO)", 0, 4} )

	// rotinas de "Transferência de Cessionário"
	Aadd( aRotTransf, {"Transferência de Cessionario","U_RCPGE048(U00->U00_CODIGO, 'C')", 0, 4} )
	Aadd( aRotTransf, {"Transferência de Resp.Financeiro","U_RCPGE048(U00->U00_CODIGO, 'R')", 0, 4} )
	Aadd( aRotTransf, {"Imprimir transferência","U_RCPGE049(U00->U00_CODIGO)", 0, 4} )

	// rotinas de "Manutenção Financeira"
	Aadd( aRotManut, {"Resetar","U_RCPGE047(U00->U00_CODIGO)", 0, 4} )
	Aadd( aRotManut, {"Painel","U_RCPGE046(U00->U00_CODIGO)", 0, 4} )
	Aadd( aRotManut, {"Liquidação","U_RCPGE034(U00->U00_CODIGO)", 0, 4} )
	Aadd( aRotManut, {"Reprocessar Vindi","U_REPRVIND(U00->U00_CODIGO)", 0, 4} )

	If lAtuIndice
		Aadd( aRotManut, {"Atualiza Indices","U_RCPGE069()", 0, 4} )
	EndIf

	// rotinas de "Endereçamento Previo"
	Aadd( aRotEnd, {"Incluir","U_RCPGE028(U00->U00_CODIGO)", 0, 4} )
	Aadd( aRotEnd, {"Excluir","U_RCPGE28E()", 0, 4} )

	// rotinas de "Apontamento de Serviços"
	Aadd( aRotApo, {"Apontamento Servico"			,"Processa({|| U_RCPGA040(1),'Aguarde'})",0,2} )
	Aadd( aRotApo, {"Histórico de Apt. de Serviços"	,"Processa({|| U_RCPGA040(2),'Aguarde'})", 0, 2} )
	Aadd( aRotApo, {"Imprimir autorização"			,"U_RCPGE032(U00->U00_CODIGO)", 0, 4} )
	Aadd( aRotApo, {"Imprimir Nota"					,"U_RUTILE25()", 0, 4} )

	// rotinas de "Transferencia de Endereco"
	Aadd( aRotTrsEnd, {"Transferir Enderecamento"	,"U_RCPGA035()", 0, 2} )
	Aadd( aRotTrsEnd, {"Histórico de Transferencias","U_RCPGA034(U00->U00_CODIGO) ", 0, 2} )

	// rotinas de "Retirada de Cinzas"
	Aadd( aRotRetCinz, {"Retirar Cinzas"	,"Processa({|| U_RCPGE017(),'Aguarde'})", 0, 2} )
	Aadd( aRotRetCinz, {"Excluir Retirada"	,"Processa({|| U_RCPGE018(),'Aguarde'})", 0, 2} )
	Aadd( aRotRetCinz, {"Recibo de Entrega das Cinzas"," U_RCPGE019() ", 0, 2} )

	// rotinas de Solicitações
	If ExistBlock("RCPGA053")
		Aadd(aSolicitacoes, {"Incluir","U_RCPGA53I(U00->U00_CODIGO)", 0, 4})
		Aadd(aSolicitacoes, {"Atualizar Solicitação","U_RCPGA53H(U00->U00_CODIGO)", 0, 4})
		Aadd(aSolicitacoes, {"Histórico","U_RCPGA053(U00->U00_CODIGO)", 0, 4})
	EndIf

	// rotinas de Agendamentos
	If ExistBlock("RUTIL049")
		Aadd(aAgendamentos, {"Incluir","U_RUTIL49F(3, U00->U00_CODIGO)", 0, 4})
		Aadd(aAgendamentos, {"Executar","U_RUTIL49H(U00->U00_CODIGO)", 0, 4})
		Aadd(aAgendamentos, {"Histórico","U_RUTIL049(U00->U00_CODIGO)", 0, 4})
	EndIf

	// rotinas de "Serviços"
	Aadd( aRotServ, {"Endereçamento Previo"				,aRotEnd		,0,4} )
	Aadd( aRotServ, {"Apontamento de Serviços"			,aRotApo		,0,4} )
	Aadd( aRotServ, {"Transferência de Endereçamento"	,aRotTrsEnd		,0,4} )
	Aadd( aRotServ, {"Retirada de Cinzas"				,aRotRetCinz	,0,4} )

	If Len(aSolicitacoes) > 0
		Aadd( aRotServ, {"Solicitação de Manutenção"		,aSolicitacoes	,0,4} )
	EndIf

	If Len(aAgendamentos) > 0
		Aadd( aRotServ, {"Agendamentos"						,aAgendamentos	,0,4} )
	EndIf

	// rotinas de "Reajuste"
	Aadd( aRotReaj, {"Reajustar Contratos","U_RCPGA014()", 0, 2} )
	Aadd( aRotReaj, {"Histórico de Reajustes"," U_RCPGA013(U00->U00_CODIGO) ", 0, 2} )
	Aadd( aRotReaj, {"Inclusão manual de Reajustes"," U_RCPGE010(U00->U00_CODIGO)", 0, 2} )

	// rotinas de "Taxa de manutenção"
	Aadd( aRotTxMan, {"Gerar Taxa","U_RCPGA022()", 0, 2} )

	If lAtivaRegra
		Aadd( aRotTxMan, {"Adiantar Taxa de Manutenção"," U_RCPGE070(U00->U00_CODIGO) ", 0, 2} )
		Aadd( aRotTxMan, {"Altera Taxa de Manutenção"," U_VirtusCEMAlteraManutencao(U00->U00_CODIGO) ", 0, 2} )
	EndIf

	Aadd( aRotTxMan, {"Histórico de Manutenções"," U_RCPGA023(U00->U00_CODIGO) ", 0, 2} )

	// rotinas de "Cliente"
	Aadd( aRotCli, {"Incluir","U_CPGA001X(3)", 0, 2} )
	Aadd( aRotCli, {"Alterar","U_CPGA001X(4)", 0, 2} )
	Aadd( aRotCli, {"Visualizar","U_CPGA001X(2)", 0, 2} )

	// rotinas de "Locação de Nicho"
	Aadd( aRotNicho, {"Gerar Taxa de Locação"		, "Processa({|| U_RCPGA041(),'Aguarde'})", 0, 2} )
	Aadd( aRotNicho, {"Histórico Tx. de Locação"	, "Processa({|| U_RCPGA042(),'Aguarde'})", 0, 2} )

	// verifico se o cliente optou pela customizacao de termo
	If lTermoCustomizado

		// verifico se o ponto de entrada de termo de cliente esta compilado na base do cliente
		If ExistBlock("PTERMOCLI")

			// impressão de termos customizados pelo cliente
			aadd(aRotTermo ,{"Impressao Termo","U_PTERMOCLI()", 0, 2})

		Else

			// impressão de termos pelo modelo padrão do sistema (modelo word)
			aadd(aRotTermo ,{"Impressao Termo","U_RUTILE28(U00->U00_CODIGO)", 0, 2})

		EndIf

	Else// caso nao estiver coloco a impressao de termo padrao do template (modelo word)

		// impressão de termos pelo modelo padrão do sistema (modelo word)
		aadd(aRotTermo ,{"Impressao Termo","U_RUTILE28(U00->U00_CODIGO)", 0, 2})

	EndIf

	ADD OPTION aRotina Title "Visualizar" 						Action "VIEWDEF.RCPGA001"					OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title "Incluir"    						Action "VIEWDEF.RCPGA001"					OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title "Alterar"    						Action "VIEWDEF.RCPGA001"					OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title "Excluir"    						Action "VIEWDEF.RCPGA001"					OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title "Ativar"    						Action "U_RCPGE045(U00->U00_CODIGO)"		OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title "Cancelar"    						Action "U_RCPGE035(U00->U00_CODIGO)"		OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title "Reativar"    						Action "U_CPGA001R()"						OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title "Transferência"					Action aRotTransf							OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title "Manutenção Financeira"			Action aRotManut							OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title "Reajuste"							Action aRotReaj								OPERATION 06 ACCESS 0
	ADD OPTION aRotina Title "Taxa de manutenção"				Action aRotTxMan							OPERATION 06 ACCESS 0
	ADD OPTION aRotina Title "Cliente"							Action aRotCli								OPERATION 06 ACCESS 0
	ADD OPTION aRotina Title "Gerador de Termos"				Action aRotTermo							OPERATION 06 ACCESS 0
	ADD OPTION aRotina Title "Serviços"							Action aRotServ								OPERATION 06 ACCESS 0
	ADD OPTION aRotina Title "Locação de Nicho"					Action aRotNicho							OPERATION 06 ACCESS 0
	ADD OPTION aRotina Title "Termo de Quitação"				Action "U_RCPGE006()"						OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title "Consulta Contratos"				Action 'U_RCPGE022()'						OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title "Export. Dados Cliente"			Action "U_RCPG024B()" 						OPERATION 07 ACCESS 0
	ADD OPTION aRotina Title "Etiqueta Dados Cliente"			Action "U_RUTILR01()" 						OPERATION 07 ACCESS 0

	// valida se tem permissoes
	If oVirtusGestaoAcessos:ValidaAcessos(17) // acesso 017 - Anexar Documentos
		If lAnexaDoc
			ADD OPTION aRotina Title "Documentos"						Action aDocumentos							OPERATION 04 ACCESS 0
		Else
			ADD OPTION aRotina Title "Banco de Conhecimento"			Action "MSDOCUMENT"							OPERATION 04 ACCESS 0
		EndIf
	EndIf

	ADD OPTION aRotina Title "Legenda"     						Action "U_CPGA001L()" 						OPERATION 07 ACCESS 0
	ADD OPTION aRotina Title 'Alterar Perfil de Pagamento'		Action 'U_UVIND11()' 						OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Alterar Forma de Pagamento'		Action 'U_UVIND12("C")' 					OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title "Consulta Obitos"					Action 'U_RCPGE041()'						OPERATION 01 ACCESS 0

	// verifico se a negociacao esta habilitada
	if lAtivaNegociacao
		ADD OPTION aRotina Title "Liberar Desconto"					Action 'U_RCPGE052(U00->U00_CODIGO)'						OPERATION 06 ACCESS 0
	endIf

	// verifico se o programa do log de operacoes
	// da integracao do app de clientes esta compilado
	if lAPICliente .And. ExistBlock("RUTILE43")
		ADD OPTION aRotina Title "Integração APP"			Action 'U_RUTILE43(Posicione("SA1",1,xFilial("SA1")+U00->U00_CLIENT+U00->U00_LOJA,"A1_CGC"), .T.)'						OPERATION 06 ACCESS 0
	endIf

	//ponto de entrada para inclusao de rotinas especificas na tela do contratos
	if ExistBlock("CPG01MNU")

		aRotEsp := ExecBlock("CPG01MNU")

		ADD OPTION aRotina Title "Especificos"	Action aRotEsp		OPERATION 06 ACCESS 0

	endif

Return(aRotina)

/*************************/
Static Function ModelDef()
/*************************/

	Local lUsaHistTransf	:= SuperGetMV("MV_XUSAU38",.F.,.F.)
	Local lExibeSE1			:= SuperGetMV("MV_XEXISE1",.F.,.T.)
	Local lExibeSE3			:= SuperGetMV("MV_XEXISE3",.F.,.T.)

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruU00 		:= FWFormStruct(1,"U00",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruU01 		:= FWFormStruct(1,"U01",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruU37 		:= FWFormStruct(1,"U37",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruU02 		:= FWFormStruct(1,"U02",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruSE1 		:= iif(lExibeSE1,DefStrModel("SE1"),Nil)
	Local oStruU03 		:= FWFormStruct(1,"U03",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruU04 		:= FWFormStruct(1,"U04",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruHist 	:= FWFormStruct(1,iif(lUsaHistTransf,"U38","U30"),/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruSE3 		:= iif(lExibeSE3,FWFormStruct(1,"SE3",/*bAvalCampo*/,/*lViewUsado*/ ),Nil)
	Local oStruUJV 		:= FWFormStruct(1,"UJV",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruU19 		:= FWFormStruct(1,"U19",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruU41 		:= FWFormStruct(1,"U41",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("PCPGA001",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

	///////////////////////////  CABEÇALHO - CONTRATO  //////////////////////////////

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("U00MASTER",/*cOwner*/,oStruU00)

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({"U00_FILIAL","U00_CODIGO"})

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("U00MASTER"):SetDescription('Dados do Contrato:')

	///////////////////////////  ITENS - ITENS DO PLANOS  //////////////////////////////

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid("U01DETAIL","U00MASTER",oStruU01,/*bLinePre*/ {|oMdlG,nLine,cAcao,cCampo| EditGrid(oMdlG,nLine,cAcao,cCampo)},/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation("U01DETAIL", {{"U01_FILIAL", 'xFilial("U01")'},{"U01_CODIGO","U00_CODIGO"}},U01->(IndexKey(1)))

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("U01DETAIL"):SetDescription('Itens:')

	oModel:GetModel('U01DETAIL'):SetUniqueLine( {'U01_PRODUT'} )

	if !IsInCallStack("U_RCPGE004")

		oModel:GetModel("U01DETAIL"):SetNoInsertLine(.T.)
		oModel:GetModel("U01DETAIL"):SetNoUpdateLine(.T.)
		oModel:GetModel("U01DETAIL"):SetNoDeleteLine(.T.)

	endif

	///////////////////////////  ITENS - SERVICOS HABILITADOS //////////////////////////////
	oModel:AddGrid("U37DETAIL","U00MASTER",oStruU37,/*bLinePre*/ {|oMdlG,nLine,cAcao,cCampo| EditGrid(oMdlG,nLine,cAcao,cCampo)} ,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

	// Faço o relaciomaneto entre o cabeçalho e os itens
	oModel:SetRelation("U37DETAIL", {{"U37_FILIAL", 'xFilial("U37")'},{"U37_CODIGO","U00_CODIGO"}},U37->(IndexKey(1)))

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("U37DETAIL"):SetDescription('Servicos Habilitados:')

	oModel:GetModel('U37DETAIL'):SetUniqueLine( {'U37_SERVIC'} )

	if !IsInCallStack("U_RCPGE004")

		oModel:GetModel("U37DETAIL"):SetNoInsertLine(.T.)
		oModel:GetModel("U37DETAIL"):SetNoUpdateLine(.T.)
		oModel:GetModel("U37DETAIL"):SetNoDeleteLine(.T.)

	endif

	///////////////////////////  ITENS - AUTORIZADOS  //////////////////////////////
	oModel:AddGrid("U02DETAIL","U00MASTER",oStruU02,/*bLinePre*/{|oMdlG,nLine,cAcao,cCampo| EditGrid(oMdlG,nLine,cAcao,cCampo)},/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

	// Faço o relaciomaneto entre o cabeçalho e os itens
	oModel:SetRelation("U02DETAIL", {{"U02_FILIAL", 'xFilial("U02")'},{"U02_CODIGO","U00_CODIGO"}},U02->(IndexKey(1)))

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("U02DETAIL"):SetDescription('Autorizados:')

	// Desobriga a digitacao de ao menos um item
	oModel:GetModel("U02DETAIL"):SetOptional(.T.)

	///////////////////////////  ITENS - TITULOS  //////////////////////////////
	if lExibeSE1

		oModel:AddGrid("SE1DETAIL","U00MASTER",oStruSE1,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

		// Faço o relaciomaneto entre o cabeçalho e os itens
		oModel:SetRelation("SE1DETAIL", {{"E1_FILIAL" , 'xFilial("SE1")'},{"E1_XCONTRA","U00_CODIGO"}},SE1->(IndexKey(29))) //E1_FILIAL+E1_XCONTRA

		// Adiciona a descricao do Componente do Modelo de Dados
		oModel:GetModel("SE1DETAIL"):SetDescription('Titulos:')

		// Seto a propriedade de obrigatoriedade do preenchimento do grid
		oModel:GetModel('SE1DETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('SE1DETAIL'):SetNoUpdateLine(.T.)

		oModel:GetModel('SE1DETAIL'):SetOnlyQuery()
		oModel:GetModel('SE1DETAIL'):SetOnlyView()

		// Desobriga a digitacao de ao menos um item
		oModel:GetModel("SE1DETAIL"):SetOptional(.T.)

	endIf

	///////////////////////////  ITENS - COMISSOES  //////////////////////////////
	if lExibeSE3

		oModel:AddGrid("SE3DETAIL","U00MASTER",oStruSE3,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

		// Faço o relaciomaneto entre o cabeçalho e os itens
		oModel:SetRelation("SE3DETAIL", {{"E3_FILIAL" , 'xFilial("SE3")'},{"E3_XCONTRA","U00_CODIGO"}},SE3->(IndexKey(5))) //E3_FILIAL+E3_XCONTRA

		// Adiciona a descricao do Componente do Modelo de Dados
		oModel:GetModel("SE3DETAIL"):SetDescription('Comissões:')

		oModel:GetModel('SE3DETAIL'):SetOnlyQuery()
		oModel:GetModel('SE3DETAIL'):SetOnlyView()

		// Desobriga a digitacao de ao menos um item
		oModel:GetModel("SE3DETAIL"):SetOptional(.T.)

		// Seto a propriedade de obrigatoriedade do preenchimento do grid
		oModel:GetModel('SE3DETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('SE3DETAIL'):SetNoUpdateLine(.T.)

	endIf

	///////////////////////////  ITENS - MENSAGENS  //////////////////////////////
	oModel:AddGrid("U03DETAIL","U00MASTER",oStruU03,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

	// Faço o relaciomaneto entre o cabeçalho e os itens
	oModel:SetRelation("U03DETAIL", {{"U03_FILIAL", 'xFilial("U03")'},{"U03_CODIGO","U00_CODIGO"}},U03->(IndexKey(1)))

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("U03DETAIL"):SetDescription('Mensagens:')

	// Desobriga a digitacao de ao menos um item
	oModel:GetModel("U03DETAIL"):SetOptional(.T.)

	///////////////////////////  ITENS - SERVICOS  //////////////////////////////
	oModel:AddGrid("UJVDETAIL","U00MASTER",oStruUJV,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

	// Faço o relaciomaneto entre o cabeçalho e os itens
	oModel:SetRelation("UJVDETAIL", {{"UJV_FILIAL", 'xFilial("UJV")'},{"UJV_CONTRA","U00_CODIGO"}},UJV->(IndexKey(2)))

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("UJVDETAIL"):SetDescription('Serviços executados:')

	// Desobriga a digitacao de ao menos um item
	oModel:GetModel("UJVDETAIL"):SetOptional(.T.)

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel("UJVDETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("UJVDETAIL"):SetNoUpdateLine(.T.)
	oModel:GetModel("UJVDETAIL"):SetNoDeleteLine(.T.)

	///////////////////////////  ITENS - ENDERECAMENTO - APONTAMENTO  //////////////////////////////
	oModel:AddGrid("U04DETAIL","U00MASTER",oStruU04,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation("U04DETAIL", {{"U04_FILIAL", 'xFilial("U04")'},{"U04_CODIGO","U00_CODIGO"}},U04->(IndexKey(1)))

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("U04DETAIL"):SetDescription('Enderecamentos:')

	// Desobriga a digitacao de ao menos um item
	oModel:GetModel("U04DETAIL"):SetOptional(.T.)

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel("U04DETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("U04DETAIL"):SetNoUpdateLine(.T.)
	oModel:GetModel("U04DETAIL"):SetNoDeleteLine( .T. )

	///////////////////////////  ITENS - ENDERECAMENTO - HISTORICO DE APONTAMENTO  //////////////////////////////
	oModel:AddGrid("HSTDETAIL","U04DETAIL",oStruHist,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

	// Faz relaciomaneto entre os compomentes do model
	if lUsaHistTransf
		oModel:SetRelation("HSTDETAIL", {{"U38_FILORI", 'xFilial("U00")'},{"U38_CTRORI","U00_CODIGO"}},U38->(IndexKey(3)))
	else
		oModel:SetRelation("HSTDETAIL", {{"U30_FILIAL", 'xFilial("U00")'},{"U30_CODIGO","U00_CODIGO"}},U30->(IndexKey(1)))
	endIf

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("HSTDETAIL"):SetDescription('Histórico:')

	// Desobriga a digitacao de ao menos um item
	oModel:GetModel("HSTDETAIL"):SetOptional(.T.)

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel("HSTDETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("HSTDETAIL"):SetNoUpdateLine(.T.)
	oModel:GetModel("HSTDETAIL"):SetNoDeleteLine(.T.)

	///////////////////////////  ITENS - ENDERECAMENTO - RETIRADA DE CINZAS  //////////////////////////////

	// Faz relaciomaneto entre os compomentes do model
	oModel:AddGrid("U41DETAIL","U00MASTER",oStruU41,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation("U41DETAIL", {{"U41_FILIAL", 'xFilial("U41")'},{"U41_CODIGO","U00_CODIGO"}},U41->(IndexKey(1))) //U41_FILIAL+U41_CODIGO

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("U41DETAIL"):SetDescription('Retirada de Cinzas:')

	// Desobriga a digitacao de ao menos um item
	oModel:GetModel("U41DETAIL"):SetOptional(.T.)

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel("U41DETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("U41DETAIL"):SetNoUpdateLine(.T.)
	oModel:GetModel("U41DETAIL"):SetNoDeleteLine(.T.)

	///////////////////////////  ITENS - TRANSFERENCIA DE CESSIONARIO  //////////////////////////////

	oModel:AddGrid("U19DETAIL","U00MASTER",oStruU19,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation("U19DETAIL", {{"U19_FILIAL", 'xFilial("U19")'},{"U19_CONTRA","U00_CODIGO"}},U19->(IndexKey(2))) //U19_FILIAL+U19_CONTRA

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("U19DETAIL"):SetDescription('Transf. de Cessionário:')

	// Desobriga a digitacao de ao menos um item
	oModel:GetModel("U19DETAIL"):SetOptional(.T.)

	// Seto a propriedade de obrigatoriedade do preenchimento do grid
	oModel:GetModel("U19DETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("U19DETAIL"):SetNoUpdateLine(.T.)
	oModel:GetModel("U19DETAIL"):SetNoDeleteLine( .T. )

Return(oModel)

/************************/
Static Function ViewDef()
/************************/

	Local lUsaHistTransf := SuperGetMV("MV_XUSAU38",.F.,.F.)

	Local lExibeSE1	:= SuperGetMV("MV_XEXISE1",.F.,.T.)
	Local lExibeSE3	:= SuperGetMV("MV_XEXISE3",.F.,.T.)

	// Cria a estrutura a ser usada na View
	Local oStruU00  := FWFormStruct(2,"U00")
	Local oStruU01  := FWFormStruct(2,"U01")
	Local oStruU37  := FWFormStruct(2,"U37")
	Local oStruU02  := FWFormStruct(2,"U02")
	Local oStruSE1  := iif(lExibeSE1,DefStrView("SE1"),Nil)
	Local oStruU03  := FWFormStruct(2,"U03")
	Local oStruU04  := FWFormStruct(2,"U04")
	Local oStruHist := FWFormStruct(2,iif(lUsaHistTransf,"U38","U30"))
	Local oStruSE3  := iif(lExibeSE3,FWFormStruct(2,"SE3"),Nil)
	Local oStruUJV  := FWFormStruct(2,"UJV")
	Local oStruU19  := FWFormStruct(2,"U19")
	Local oStruU41  := FWFormStruct(2,"U41")

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel("RCPGA001")
	Local oView

	// Remove campos da estrutura
	oStruU01:RemoveField('U01_CODIGO')
	oStruU37:RemoveField('U37_CODIGO')
	oStruU02:RemoveField('U02_CODIGO')
	oStruU03:RemoveField('U03_CODIGO')
	oStruU04:RemoveField('U04_CODIGO')

	if lUsaHistTransf
		oStruHist:RemoveField('U38_CODANT')
	else
		oStruHist:RemoveField('U30_CODIGO')
	endIf

	oStruUJV:RemoveField('UJV_CONTRA')
	oStruUJV:RemoveField('UJV_DESTAB')
	oStruUJV:RemoveField('UJV_MUN')
	oStruU19:RemoveField('U19_CONTRA')
	oStruU19:RemoveField('U41_CODIGO')

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField("VIEW_U00",oStruU00,"U00MASTER")

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid("VIEW_U01",oStruU01,"U01DETAIL")
	oView:AddGrid("VIEW_U37",oStruU37,"U37DETAIL")
	oView:AddGrid("VIEW_U02",oStruU02,"U02DETAIL")

	if lExibeSE1
		oView:AddGrid("VIEW_SE1",oStruSE1,"SE1DETAIL")
	endIf

	if lExibeSE3
		oView:AddGrid("VIEW_SE3",oStruSE3,"SE3DETAIL")
	endIf

	oView:AddGrid("VIEW_U03",oStruU03,"U03DETAIL")
	oView:AddGrid("VIEW_U04",oStruU04,"U04DETAIL")
	oView:AddGrid("VIEW_HST",oStruHist,"HSTDETAIL")
	oView:AddGrid("VIEW_UJV",oStruUJV,"UJVDETAIL")
	oView:AddGrid("VIEW_U19",oStruU19,"U19DETAIL")
	oView:AddGrid("VIEW_U41",oStruU41,"U41DETAIL")

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox("PAINEL_STATUS", 8)
	oView:CreateHorizontalBox("PAINEL_CABEC", 42)
	oView:CreateHorizontalBox("PAINEL_ITENS", 50)

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView("VIEW_U00","PAINEL_CABEC")

	// Cria Folder na view
	oView:CreateFolder("PASTAS","PAINEL_ITENS")

	// Cria pastas nas folders
	oView:AddSheet("PASTAS","ABA01","Itens do Plano")
	oView:AddSheet("PASTAS","ABA02","Autorizados")

	if lExibeSE1
		oView:AddSheet("PASTAS","ABA03","Parcelas/Taxas")
	endIf

	if lExibeSE3
		oView:AddSheet("PASTAS","ABA04","Comissão")
	endIf

	oView:AddSheet("PASTAS","ABA05","Mensagens")
	oView:AddSheet("PASTAS","ABA06","Serviços Executados")
	oView:AddSheet("PASTAS","ABA07","Enderecamentos")
	oView:AddSheet("PASTAS","ABA09","Transf. de Cessionário")

	oView:CreateVerticalBox("PAINEL_ITENS01_1",60,,,"PASTAS","ABA01")
	oView:CreateVerticalBox("PAINEL_ITENS01_2",40,,,"PASTAS","ABA01")
	oView:CreateHorizontalBox("PAINEL_ITENS02",100,,,"PASTAS","ABA02")

	if lExibeSE1
		oView:CreateHorizontalBox("PAINEL_ITENS03",100,,,"PASTAS","ABA03")
	endIf

	if lExibeSE3
		oView:CreateHorizontalBox("PAINEL_ITENS04",100,,,"PASTAS","ABA04")
	endIf

	oView:CreateHorizontalBox("PAINEL_ITENS05",100,,,"PASTAS","ABA05")
	oView:CreateHorizontalBox("PAINEL_ITENS06",100,,,"PASTAS","ABA06")

	// ABA BENEFICIÁRIOS
	oView:CreateHorizontalBox( 'PANEL_PASTA1_ABA07'			, 100 , /*owner*/, /*lPixel*/, 'PASTAS', 'ABA07')
	oView:CreateFolder('PASTA2', 'PANEL_PASTA1_ABA07')

	// crio as pastas
	oView:AddSheet('PASTA2','ABA_ENDERECAMENTOS','Endereçamento Atual')
	oView:AddSheet('PASTA2','ABA_HISTORICO','Historico do Endereço')
	oView:AddSheet('PASTA2','ABA_RET_CINZAS','Retirada de Cinzas')

	// grids ABA_ENDERECAMENTOS
	oView:CreateHorizontalBox("PANEL_ENDERECAMENTOS"	,100,,,"PASTA2","ABA_ENDERECAMENTOS")
	oView:CreateHorizontalBox("PANEL_HISTORICO"			,100,,,"PASTA2","ABA_HISTORICO")
	oView:CreateHorizontalBox("PANEL_RETCINZAS"			,100,,,"PASTA2","ABA_RET_CINZAS")

	oView:CreateHorizontalBox("PAINEL_ITENS09",100,,,"PASTAS","ABA09")

	oView:SetOwnerView("VIEW_U01","PAINEL_ITENS01_1")
	oView:SetOwnerView("VIEW_U37","PAINEL_ITENS01_2")
	oView:SetOwnerView("VIEW_U02","PAINEL_ITENS02")

	if lExibeSE1
		oView:SetOwnerView("VIEW_SE1","PAINEL_ITENS03")
	endIf

	if lExibeSE3
		oView:SetOwnerView("VIEW_SE3","PAINEL_ITENS04")
	endIf

	oView:SetOwnerView("VIEW_U03","PAINEL_ITENS05")
	oView:SetOwnerView("VIEW_UJV","PAINEL_ITENS06")
	oView:SetOwnerView("VIEW_U04","PANEL_ENDERECAMENTOS")
	oView:SetOwnerView("VIEW_HST","PANEL_HISTORICO")
	oView:SetOwnerView("VIEW_U41","PANEL_RETCINZAS")

	oView:SetOwnerView("VIEW_U19","PAINEL_ITENS09")

	// Define campos que terao Auto Incremento
	oView:AddIncrementField("VIEW_U01","U01_ITEM")
	oView:AddIncrementField("VIEW_U37","U37_ITEM")
	oView:AddIncrementField("VIEW_U02","U02_ITEM")
	oView:AddIncrementField("VIEW_U03","U03_ITEM")

	oView:SetViewProperty('VIEW_UJV',"GRIDSEEK",{.T.})

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_U00')
	oView:EnableTitleView('VIEW_U01')
	oView:EnableTitleView('VIEW_U37')
	oView:EnableTitleView('VIEW_U02')
	oView:EnableTitleView('VIEW_U03')

	if lExibeSE1
		oView:EnableTitleView('VIEW_SE1')
	endIf

	if lExibeSE3
		oView:EnableTitleView('VIEW_SE3')
	endIf

	oView:EnableTitleView('VIEW_UJV')
	oView:EnableTitleView('VIEW_U04')
	oView:EnableTitleView('VIEW_HST')
	oView:EnableTitleView('VIEW_U41')
	oView:EnableTitleView('VIEW_U19')
	oView:EnableTitleView('VIEW_U37')

	oView:SetViewProperty( "U00MASTER", "SETLAYOUT", {  FF_LAYOUT_VERT_DESCR_TOP   , 3 , 10 } )

	oView:SetViewProperty("U00MASTER", "SETCOLUMNSEPARATOR", {90})

	// Cria componentes nao MVC
	oView:AddOtherObject("STATUS", {|oPanel| CPG001S(oPanel)})
	oView:SetOwnerView("STATUS",'PAINEL_STATUS')

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk( {||.T.} )

	// Habilito a barra de progresso na abertura da tela
	oView:SetProgressBar(.T.)

Return(oView)

/******************************/
Static Function CPG001S(oPanel)
/******************************/

	Local oSay1, oSay2
	Local lPossuiEnd	:= .F.

	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelU04 	:= oModel:GetModel("U04DETAIL")

	Local nI

	Local oFont20N	:= TFONT():New("Arial",,20,,.T.,,,,.T.,.F.) 	///Fonte 20 Negrito

	For nI := 1 To oModelU04:Length()

		// posiciono na linha atual
		oModelU04:Goline(nI)

		If !oModelU04:IsDeleted()

			If !Empty(oModelU04:GetValue("U04_TIPO"))
				lPossuiEnd := .T.
				Exit
			Endif
		Endif

	Next nI

	If lPossuiEnd
		@005,((oPanel:nClientWidth/2)/2) - 60 SAY oSay1 PROMPT "Endereçado" SIZE 120, 010 OF oPanel FONT oFont20N COLORS CLR_RED,16777215 PIXEL CENTER
	Else
		@005,((oPanel:nClientWidth/2)/2) - 60 SAY oSay1 PROMPT "Sem endereço" SIZE 120, 010 OF oPanel FONT oFont20N COLORS CLR_GREEN,16777215 PIXEL CENTER
	Endif

	//Linha horizontal
	@010,005 SAY oSay2 PROMPT Repl("_",(oPanel:nClientWidth/2) - 5) SIZE (oPanel:nClientWidth/2) - 5, 007 OF oPanel COLORS CLR_GRAY, 16777215 PIXEL

Return(Nil)

/*/{Protheus.doc} CPGA001L
funcao para exibir as legendas de contrato
no menu oturas acoes

@type function
@version 1.0
@author totvs
@since 24/09/2020
/*/
User Function CPGA001L()

	Local aLegenda				:= {}
	Local lAtivaNegociacao    	:= SuperGetMV("MV_XATVNEG",, .F.)           // ativa ou nao a regra de negociacao

	AAdd(aLegenda, {"BR_BRANCO","Pré-Cadastro"})
	AAdd(aLegenda, {"BR_VERDE","Ativo"})
	AAdd(aLegenda, {"BR_LARANJA","Suspenso"})
	AAdd(aLegenda, {"BR_AZUL","Cancelado"})
	AAdd(aLegenda, {"BR_VERMELHO","Finalizado"})

	if lAtivaNegociacao
		AAdd(aLegenda, {"BR_AMARELO","Bloqueio de Desconto"})
		AAdd(aLegenda, {"BR_CINZA","Desconto Rejeitado"})
	endIf

	AAdd(aLegenda, {"BR_PINK","Ativo | Integração de Empresas"})

	BrwLegenda("Status do Contrato","Legenda", aLegenda)

Return(Nil)

/*/{Protheus.doc} DefStrModel
Estrutura para montar o modelo de dados
da tabela SE1 para o contrato de cemiterio
@type function
@version 1.0 
@author g.sampaio
@since 25/11/2021
@param cAlias, character, alias para a estrutura
@return object, estrutura do modelo de dados
/*/
Static Function DefStrModel(cAlias)

	Local aArea    		:= GetArea()
	Local bValid   		:= { || }
	Local bWhen    		:= { || }
	Local bRelac   		:= { || }
	Local aAux     		:= {}
	Local aCampos		:= {"E1_PREFIXO","E1_NUM","E1_XPARCON","E1_TIPO","E1_CLIENTE","E1_LOJA","E1_NOMCLI","E1_EMISSAO","E1_VENCTO","E1_VENCREA",;
		"E1_VALOR","E1_XVLRVEN","E1_XVLRJUR","E1_SALDO","E1_BAIXA","E1_VALLIQ","E1_MULTA","E1_JUROS","E1_ACRESC","E1_SDACRES",;
		"E1_FATURA","E1_MOEDA","E1_TXMOEDA","E1_PARCELA","E1_VALJUR","E1_PORCJUR","E1_ORIGEM","E1_XUSRBAX"}
	Local oStruct 		:= FWFormModelStruct():New()
	Local nX			:= 1
	Local oSx			:= UGetSxFile():New()
	Local aSX2			:= {}
	Local aSIX			:= {}
	Local aSX3			:= {}
	Local aSX7			:= {}
	Local nX			:= 1

	//--------
	// Tabela
	//--------
	aSX2:= oSX:GetInfoSX2(cAlias)

	oStruct:AddTable(aSX2[1,2]:cCHAVE,StrTokArr(Alltrim(aSX2[1,2]:cUNICO), '+') ,Alltrim(aSX2[1,2]:cNOME))

	//---------
	// Indices
	//---------
	aSIX:= oSX:GetInfoSIX(cAlias)

	nOrdem := 0

	For nX:= 1 to Len(aSIX)

		oStruct:AddIndex(nOrdem++,aSIX[nX,2]:cORDEM,aSIX[nX,2]:cCHAVE,SIXDescricao(),aSIX[nX,2]:cF3,aSIX[nX,2]:cNICKNAME ,(aSIX[nX,2]:cSHOWPESQ <> 'N'))

	Next nX

	//--------
	// Campos
	//--------
	bRelac := {|A,B,C| FWINITCPO(A,B,C),XRET:=(IIF(SE1->E1_SALDO <> 0,IIF(SE1->E1_VALOR > SE1->E1_SALDO .And. SE1->E1_SALDO > 0 ,"BR_AZUL","BR_VERDE"),"BR_VERMELHO")),FWCLOSECPO(A,B,C,.T.),FWSETVARMEM(A,B,XRET),XRET }
	oStruct:AddField('','','STATUS','C',11,0,,,{},.F.,bRelac,,,.T.)

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

Return(oStruct)

/*/{Protheus.doc} DefStrView
Funcao para montar a view do alias SE1
para o contrato de cemiterio
@type function
@version 1.0 
@author g.sampaio
@since 25/11/2021
@param cAlias, character, alias
@return object, retorna a estrutura da view para o programa
/*/
Static Function DefStrView(cAlias)

	Local aArea     	:= GetArea()
	Local lExibeSE1		:= SuperGetMV("MV_XEXISE1",.F.,.T.)
	Local aCampos		:= {"E1_PREFIXO","E1_NUM","E1_XPARCON","E1_TIPO","E1_CLIENTE","E1_LOJA","E1_NOMCLI","E1_EMISSAO","E1_VENCTO","E1_VENCREA",;
		"E1_VALOR","E1_XVLRVEN","E1_XVLRJUR","E1_SALDO","E1_BAIXA","E1_VALLIQ","E1_MULTA","E1_JUROS","E1_ACRESC","E1_SDACRES",;
		"E1_FATURA","E1_MOEDA","E1_TXMOEDA","E1_PARCELA","E1_VALJUR","E1_PORCJUR","E1_ORIGEM","E1_XUSRBAX"}
	Local oStruct   	:= iif(lExibeSE1,FWFormViewStruct():New(),Nil)
	Local aCombo    	:= {}
	Local nInitCBox 	:= 0
	Local nMaxLenCb 	:= 0
	Local aAux      	:= {}
	Local nI        	:= 1
	Local nX			:= 1
	Local cGSC      	:= ''
	Local oSX			:= iif(lExibeSE1,UGetSxFile():New(),Nil)
	Local aSX3			:= {}
	Local aSXA			:= {}

	if lExibeSE1

		//--------
		// Campos
		//--------
		oStruct:AddField('STATUS',"01",'','',NIL,'GET','@BMP',,'',.F.,'','',{},1,'BR_VERDE',.T.)

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

	endIf

	RestArea(aArea)

Return(oStruct)

/*/{Protheus.doc} CPGA001R
Funcao para reativar o contrato manual
@type function
@version 1.0
@author g.sampaio
@since 14/01/2024
/*/
User Function CPGA001R()

	Local lContinua := .T.

	Do Case

	Case U00->U00_STATUS == "P" //Pré-cadastro
		MsgInfo("O Contrato se encontra pré-cadastrado, operação não permitida.","Atenção")
		lContinua := .F.

	Case U00->U00_STATUS == "A" //Ativo
		MsgInfo("O Contrato já se encontra Ativo, operação não permitida.","Atenção")
		lContinua := .F.

	Case U00->U00_STATUS == "C" //Cancelado
		MsgInfo("O Contrato se encontra Cancelado, operação não permitida.","Atenção")
		lContinua := .F.

	Case U00->U00_STATUS == "F" //Finalizado
		MsgInfo("O Contrato se encontra Finalizado, operação não permitida.","Atenção")
		lContinua := .F.

	EndCase

	if lContinua .And. U00->(FieldPos("U00_TPCONT")) > 0

		// contrato de integracao de empresas
		if U00->U00_STATUS == "A" .And. U00->U00_TPCONT == "2"
			MsgInfo("O Contrato de Integração de Empresas, operação não permitida.","Atenção")
			lContinua := .F.
		endIf

	endIf

	If lContinua

		If MsgYesNo("O Contrato será reativado, deseja continuar?")

			RecLock("U00",.F.)
			U00->U00_STATUS := "A" //Ativo
			U00->(MsUnlock())
		Endif

		MsgInfo("Contrato reativado.","Atenção")
	Endif

Return(Nil)

/*****************************/
User Function Adimp(cContrato)
/*****************************/

	Local lRet := .T.

	DbSelectArea("SE1")
	SE1->(DbOrderNickName("XCTRCEM")) //E1_FILIAL+E1_XCONTRA
	SE1->(DbGoTop())

	If SE1->(DbSeek(xFilial("SE1")+U00->U00_CODIGO))

		While SE1->(!EOF()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_XCONTRA == U00->U00_CODIGO

			If SE1->E1_VENCREA < dDataBase .And. SE1->E1_SALDO > 0 //Inadimplente
				lRet := .F.
				Exit
			Endif

			SE1->(DbSkip())
		EndDo
	Endif

Return lRet

/*********************************/
User Function RetVlrRec(cContrato)
/*********************************/

	Local nRet := 0

	DbSelectArea("SE1")
	SE1->(DbOrderNickName("XCTRCEM")) //E1_FILIAL+E1_XCONTRA
	SE1->(DbGoTop())

	If SE1->(DbSeek(xFilial("SE1")+U00->U00_CODIGO))

		While SE1->(!EOF()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_XCONTRA == U00->U00_CODIGO

			nRet += (SE1->E1_VALOR + SE1->E1_ACRESC - SE1->E1_DECRESC) - (SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE)

			SE1->(DbSkip())
		EndDo
	Endif

Return nRet

/****************************/
User Function CPGA001X(_nOpc)
/****************************/

	Local cRotBkp		:= FunName()
	Local lSA1MVC		:= SuperGetMV("MV_MVCSA1", .F., .F.)

	Private lAutoExec	:= .F.
	Private lInclui		:= .T.
	Private lAltera		:= .F.
	Private	l030Auto	:= .F.
	Private aRotina		:= {}
	Private aRotAuto	:= NIL
	Private cCadastro 	:= "Cadastro de Clientes"

	//Altero o nome da rotina para considerar o menu do cadastro de cliente
	If lSA1MVC
		SetFunName("CRMA980")
	Else
		SetFunName("MATA030")
	EndIf

	AAdd(aRotina, {"Pesquisar" 		,"PesqBrw"    	, 0 , 1	, 0    	, .F.} )
	AAdd(aRotina, {"Visualizar"		, "A030Visual" 	, 0 , 2	, 0   	, NIL} )
	AAdd(aRotina, {"Incluir"		, "A030Inclui" 	, 0 , 3	, 81  	, NIL} )
	AAdd(aRotina, {"Alterar"		, "A030Altera" 	, 0 , 4	, 143 	, NIL} )
	AAdd(aRotina, {"Excluir"		, "A030Deleta" 	, 0 , 5	, 144 	, NIL} )

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

	If _nOpc == 3 //Inclusão de Cliente
		FWExecView("Incluir","CRMA980",MODEL_OPERATION_INSERT,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)
	Else

		If SA1->(DbSeek(xFilial("SA1")+U00->U00_CLIENT+U00->U00_LOJA))

			If _nOpc == 4 //Alteração de Cliente
				if lSA1MVC
					FWExecView("Alterar","CRMA980",MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)
				Else
					A030Altera("SA1",SA1->(Recno()),4)
				EndIf
			Else //Visualização de Cliente
				if lSA1MVC
					FWExecView("Visualizar","CRMA980",MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)
				Else
					A030Visual("SA1",SA1->(Recno()),2)
				EndIf
			Endif

		Endif
	Endif

	//restauro a funcao do contrato
	SetFunName(cRotBkp)

Return(Nil)

/*/{Protheus.doc} UCalcVlrLiq
Funcao para calcular o valor liquido do contrato cemiterio
apos a digitacao de valor de desconto. Será utilizado para 
executar a funcao CalcVlrLiq
@author Raphael Martins 
@since 14/08/2018
@version P12
@return nPreco - Preco de Venda da Tabela
/*/

User Function UCalcLiqCem()

	Local aArea					:= GetArea()
	Local aAreaU00				:= U00->(GetArea())
	Local aAreaU05				:= U05->(GetArea())
	Local lRet					:= .T.
	Local lAtivaNegociacao    	:= SuperGetMV("MV_XATVNEG",, .F.)                               // ativa ou nao a regra de negociacao

	// verifico se está tudo certo até aqui
	if lAtivaNegociacao

		// valido o valor de desconto de acorodo com a regra
		lRet := U_UValDesconto()

	endIf

	If lRet .And. !IsInCallStack("U_RUTILE11") //Se integração Mobile
		FWMsgRun(,{|oSay| lRet := CalcVlrLiq() },'Aguarde...','Reprocessando Valor do Contrato!')
	ElseIf lRet
		lRet := CalcVlrLiq()
	Endif

	// caso nao estiver na rotina de importacao nao considero a regra de negociacao
	if .NOT. FunName() == "RIMPM003"

		if lRet .And. lAtivaNegociacao
			U_USetNegociacaoCemiterio()
		endIf

	endIf

	RestArea(aArea)
	RestArea(aAreaU00)
	RestArea(aAreaU05)


Return(lRet)

/*/{Protheus.doc} CalcVlrLiq
Funcao para calcular o valor liquido do contrato cemiterio
apos a digitacao de valor de desconto.
@author Raphael Martins 
@since 14/08/2018
@version P12
@return nPreco - Preco de Venda da Tabela
/*/
Static Function CalcVlrLiq()

	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelU00		:= oModel:GetModel("U00MASTER")
	Local oModelU01		:= oModel:GetModel("U01DETAIL")
	Local oModelU37		:= oModel:GetModel("U37DETAIL")
	Local aSaveLines  	:= FWSaveRows()
	Local nX			:= 0
	Local nVlrItens		:= 0
	Local nVlrLiq		:= 0
	Local lRet			:= .T.

	nVlrLiq := oModelU00:GetValue("U00_VLRBRU") - oModelU00:GetValue("U00_DESCON")

	oModelU00:LoadValue("U00_VALOR"	, nVlrLiq )

	//restauro as linhas posicionadas
	FWRestRows( aSaveLines )

	If oView <> nil
		oView:Refresh()
	EndIf

Return(lRet)

/*/{Protheus.doc} EditGrid
Funcao para validar a delecao e restauracao 
da linha das tabelas U01 e U37 - Utilizada para 
reprocessar o valor liquido do contrato
@author Raphael Martins 
@since 14/08/2018
@version P12
@return nPreco - Preco de Venda da Tabela
/*/
Static Function EditGrid(oModelGrid,nLinha,cAcao,cCampo)

	Local lRet 			:= .T.
	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelU00		:= oModel:GetModel("U00MASTER")

	Local aSaveLines    := FWSaveRows()
	Local nVlrAtual		:= 0
	Local nLinhaAtual	:= oModelGrid:GetLine()

	//atualizo o valor do contrato de acordo em casos de delecao e restauracao da linha posicionada
	If !IsInCallStack("U_LimpaAcolsMVC")

		if oModelGrid:cId == "U02DETAIL"

			if cAcao == 'DELETE'

				if oModelGrid:GetValue("U02_STATUS") $ "2/3" // titular e transferencia de titularidade

					// mensagem para o usuario
					lRet := .F.
					Help(,,'Help - DELAUTORIZADO',,"Não é permitido a exclusao do autorizado vinculado ao titular do contrato!" ,1,0)

				endIf

			elseIf cAcao == "CANSETVALUE"

				if oModelGrid:GetValue("U02_STATUS") == "2" // titular

					if AllTrim(cCampo) == "U02_CPF"

						// mensagem para o usuario
						lRet := .F.
						Help(,,'Help - ALTAUTORIZADO',,"Não é permitido a alteração do campo 'CPF' do autorizado vinculado ao titular do contrato!" ,1,0)

					elseIf AllTrim(cCampo) == "U02_CODCLI"

						// mensagem para o usuario
						lRet := .F.
						Help(,,'Help - ALTAUTORIZADO',,"Não é permitido a alteração do campo 'Cod.Cliente' do autorizado vinculado ao titular do contrato!" ,1,0)

					elseIf AllTrim(cCampo) == "U02_LOJCLI"

						// mensagem para o usuario
						lRet := .F.
						Help(,,'Help - ALTAUTORIZADO',,"Não é permitido a alteração do campo 'Loja Cliente' autorizado vinculado ao titular do contrato!" ,1,0)

					endIf

				elseIf oModelGrid:GetValue("U02_STATUS") == "3" // tranferencia de titularidade

					// mensagem para o usuario
					lRet := .F.
					Help(,,'Help - ALTAUTORIZADO',,"Não é permitido a alteração dos dados do titular que foi feita a transferência de titularidade!" ,1,0)

				endIf

			EndIf

		endIf

	endif

	FWRestRows( aSaveLines )
	oModelGrid:GoLine( nLinhaAtual )

Return(lRet)

/***********************/
User Function INCPERSO()
/***********************/

	Local lContinua := .T.

	Private oResumoTotal	:= NIL

	Do Case

	Case U00->U00_STATUS == "C" //Cancelado
		MsgInfo("O Contrato se encontra Cancelado, operação não permitida.","Atenção")
		lContinua := .F.

	Case U00->U00_STATUS == "F" //Finalizado
		MsgInfo("O Contrato se encontra Finalizado, operação não permitida.","Atenção")
		lContinua := .F.
	EndCase

	If lContinua
		FWExecView('INCLUIR','RCPGE021',3,,{|| .T. })
	Endif

Return

/***********************/
User Function HISPERSO()
/***********************/

	U_RCPGE021()

Return

/*/{Protheus.doc} UWhenCemit
Funcao para definir o modo de edicao dos campos 
@author Raphael Martins 
@since 14/08/2018
@version P12
@return nPreco - Preco de Venda da Tabela
/*/
User Function UWhenCemit()

	Local lRet := .F.

	if Inclui .OR. U00->U00_STATUS == "P" .Or. IsInCallStack("U_RCPGE004")

		lRet := .T.

	endif

Return(lRet)

/*********************************/
User Function ContrQuit(cContrato)
/*********************************/

	Local lRet 		:= .T.

	Local cTipo		:= Alltrim(SuperGetMv("MV_XTIPOCT",.F.,"AT"))
	Local cTipoEnt	:= Alltrim(SuperGetMv("MV_XTIPOEN",.F.,"ENT"))

	DbSelectArea("SE1")
	SE1->(DbOrderNickName("XCTRCEM")) //E1_FILIAL+E1_XCONTRA
	SE1->(DbGoTop())

	If SE1->(DbSeek(xFilial("SE1")+U00->U00_CODIGO))

		While SE1->(!EOF()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_XCONTRA == U00->U00_CODIGO

			If SE1->E1_SALDO > 0 .And. (Alltrim(SE1->E1_TIPO) == cTipo .Or. Alltrim(SE1->E1_TIPO) == cTipoEnt) //Título em aberto E ser parcela do Contrato
				lRet := .F.
				Exit
			Endif

			SE1->(DbSkip())
		EndDo
	Endif

Return lRet

/*/{Protheus.doc} UWhenJurosCemiterio
funcaoa para definir a edicao do campo U00_JUROS

@type function
@version 
@author g.sampaio
@since 11/09/2020
@return return_type, return_description
/*/
User Function UWhenJurosCemiterio()

	Local lAtivaNegociacao    	:= SuperGetMV("MV_XATVNEG",, .F.)                               // ativa ou nao a regra de negociacao
	Local lRetorno				:= .T.

	// caso nao estiver na rotina de importacao nao considero a regra de negociacao
	if .NOT. FunName() == "RIMPM003"

		// verifico se estou na inclusao ou contrato esta pendente de ativacao e com a regra de negociacao ativada para edicao
		if (INCLUI .OR. M->U00_STATUS == "P") .And. lAtivaNegociacao
			lRetorno := .F.
		endIf

	endIf

Return(lRetorno)

/*/{Protheus.doc} UValEntMinContrato
description
@type function
@version 
@author g.sampaio
@since 11/09/2020
@return return_type, return_description
/*/
User Function UValEntMinContrato()

	Local lAtivaNegociacao    	:= SuperGetMV("MV_XATVNEG",, .F.)                               // ativa ou nao a regra de negociacao
	Local lRetorno				:= .T.
	Local oModel				:= FWModelActive()
	Local oView					:= FWViewActive()
	Local oModelU00				:= oModel:GetModel("U00MASTER")

	// caso nao estiver na rotina de importacao nao considero a regra de negociacao
	if .NOT. FunName() == "RIMPM003"

		// verifico se estou na inclusao ou contrato esta pendente de ativacao e com a regra de negociacao ativada para edicao
		if oModelU00:GetValue('U00_STATUS') == "P" .And. lAtivaNegociacao

			// verifico se o valor de entrada é menor que a entrada minima digitada
			if oModelU00:GetValue('U00_VLRENT') < oModelU00:GetValue('U00_ENTMIN')
				lRetorno := .F.
				Help(,,'Help - ENTRADAMINIMA',,"O Valor da Entrada não pode ser menor que R$ " + Transform(oModelU00:GetValue('U00_ENTMIN'),"@E 999,999.99") + ", que é a entrada minima pré estabelecida na regra de negociação, favor consultar a Aba 'Regra de Negociação' " ,1,0)
			endIf

		endIf

	endIf

Return(lRetorno)

/*/{Protheus.doc} UValEntMinContrato
description
@type function
@version 
@author g.sampaio
@since 11/09/2020
@return return_type, return_description
/*/
User Function UValDesconto()

	Local lAtivaNegociacao    	:= SuperGetMV("MV_XATVNEG",, .F.)                               // ativa ou nao a regra de negociacao
	Local lRetorno				:= .T.
	Local oModel				:= FWModelActive()
	Local oModelU00				:= oModel:GetModel("U00MASTER")

	// caso nao estiver na rotina de importacao nao considero a regra de negociacao
	if .NOT. FunName() == "RIMPM003"

		// verifico se estou na inclusao ou contrato esta pendente de ativacao e com a regra de negociacao ativada para edicao
		if oModelU00:GetValue('U00_STATUS') == "P" .And. lAtivaNegociacao

			// verifico se o valor de entrada é menor que a entrada minima digitada
			if oModelU00:GetValue('U00_DSCSUP') < oModelU00:GetValue('U00_DESCON')
				lRetorno := .F.
				MsgAlert("O Valor do Desconto não pode ser maior que o limite do superior que é R$ " + AllTrim(Transform(oModelU00:GetValue('U00_DSCSUP'),"@E 999,999.99")) + " pré-estabelecido na regra de negociação, favor consultar a Aba 'Regra de Negociação' ","Valor de Desconto")
			endIf

		endIf

	endIf

Return(lRetorno)

/*/{Protheus.doc} UINIENDU04
Funcao para inicializar Campo de Estrutura
da U04
@type function
@version 
@author Raphael Martins
@since 23/07/2021
@return return_type, return_description
/*/
User Function UINIU04END()

	Local aArea := GetArea()
	Local oModel				:= FWModelActive()
	Local oModelU00				:= oModel:GetModel("U00MASTER")
	Local cEstrutura			:= ""

// verifico se estou na inclusao ou contrato esta pendente de ativacao e com a regra de negociacao ativada para edicao
	if oModelU00:GetValue('U00_STATUS') <> "P" .and. !Empty(U04->U04_TIPO)

		//verifico se possui endereco de jazigo
		if U04->U04_TIPO == "J"

			cEstrutura := "QD:" + U04->U04_QUADRA + " | MD:" + U04->U04_MODULO + " | JAZ:" + U04->U04_JAZIGO + " | GAV:" + U04->U04_GAVETA

		elseif U04->U04_TIPO == "O"

			cEstrutura := "OSSARIO:" + U04->U04_OSSARI + " | NICHO:" + U04->U04_NICHOO

		else

			cEstrutura := "CREMAT:" + U04->U04_CREMAT + " | NICHO:" + U04->U04_NICHOC

		endif

	endif
	//"QD:01 | MD:0001 | JAZ:0005 | GAV:11"

	RestArea(aArea)

Return(cEstrutura)

/*/{Protheus.doc} UINIENDU04
Funcao para inicializar Campo de Estrutura
da U30
@type function
@version 1.0 
@author Raphael Martins
@since 23/07/2021
@return return_type, return_description
/*/
User Function UINIU30END()

	Local aArea := GetArea()
	Local oModel				:= FWModelActive()
	Local oModelU00				:= oModel:GetModel("U00MASTER")
	Local cEstrutura			:= ""

// verifico se estou na inclusao ou contrato esta pendente de ativacao e com a regra de negociacao ativada para edicao
	if oModelU00:GetValue('U00_STATUS') <> "P"

		//verifico se possui endereco de jazigo
		if !Empty(U30->U30_QUADRA)

			cEstrutura := "QD:" + U30->U30_QUADRA + " | MD:" + U30->U30_MODULO + " | JAZ:" + U30->U30_JAZIGO + " | GAV:" + U30->U30_GAVETA

		elseif !Empty(U30->U30_OSSARI)

			cEstrutura := "OSSARIO:" + U30->U30_OSSARI + " | NICHO:" + U30->U30_NICHOO

		else

			cEstrutura := "CREMAT:" + U30->U30_CREMAT + " | NICHO:" + U30->U30_NICHOC

		endif

	endif

	RestArea(aArea)

Return(cEstrutura)

/*/{Protheus.doc} UGATADAUT
Funcao para gatilho para cobranca adicional autorizado
@type function
@version 1.0 
@author Raphael Martins
@since 23/07/2021
@return return_type, return_description
/*/

User Function UGATADAUT()

	Local aArea 				:= GetArea()
	Local aAreaU00 				:= U00->(GetArea())
	Local aAreaU02 				:= U02->(GetArea())
	Local oModel				:= FWModelActive()
	Local oModelU00				:= oModel:GetModel("U00MASTER")
	Local oModelU02				:= oModel:GetModel("U02DETAIL")
	Local lAtivaCobAdicional	:= SuperGetMV("MV_XCBADAU",, .F.)
	Local nPrazoPermitido		:= SuperGetMV("MV_XPRZAUT",, 30)
	Local cRetorno 				:= "N"
	Local cContrato				:= oModelU00:GetValue("U00_CODIGO")
	Local cItem					:= oModelU02:GetValue("U02_ITEM")
	Local nOperation 			:= oModel:GetOperation()


	if nOperation == 4 .And. lAtivaCobAdicional

		U02->(DbSetOrder(1))

		//verifico se o autorizado ja esta cadastrado, caso nao, verifico o prazo
		if !U02->(MsSeek( xFilial("U02") + cContrato + cItem ))

			if dDatabase - oModelU00:GetValue("U00_DTATIV") > nPrazoPermitido

				cRetorno := "S"

			endif

		endif

	endif

//verifico 
	RestArea(aArea)
	RestArea(aAreaU00)
	RestArea(aAreaU02)

Return(cRetorno)
