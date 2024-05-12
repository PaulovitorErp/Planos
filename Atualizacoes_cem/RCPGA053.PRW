#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RCPGA053
Browse de Sincronizacao de contratos
por API de Integracao
@type function
@version 1.0
@author g.sampaio
@since 08/09/2023
/*/
User Function RCPGA053(cCodContrato)

	Local oBrowse		:= {}
	Local cRotinaAtual	:= FunName()

	Default cCodContrato := ""

	// Altero o nome da rotina para considerar o menu deste MVC
	SetFunName("RCPGA053")

	// crio o objeto do Browser
	oBrowse := FWmBrowse():New()

	// defino o Alias
	oBrowse:SetAlias("U94")

	// informo a descrição
	oBrowse:SetDescription("Solicitações de Manutenção")

	// crio as legendas
	oBrowse:AddLegend("U94_STATUS == 'P'", "WHITE"	,	"Pendente")
	oBrowse:AddLegend("U94_STATUS == 'E'", "GREEN"	,	"Em Execução")
	oBrowse:AddLegend("U94_STATUS == 'F'", "RED"	,	"Finalizado")

	If !Empty(cCodContrato)

		// pergunto ao usuario se quer filtrar apenas os apontamentos do contrato
		If MsgYesNo("Deseja filtrar as solicitações do contrato posicionado?")
			oBrowse:SetFilterDefault( "U94_FILIAL == '"+ U00->U00_MSFIL +"' .And. U94_CONTRA=='" + U00->U00_CODIGO + "'" ) // filtro apenas o contrato selecionado
		EndIf

	EndIf

	// ativo o browser
	oBrowse:Activate()

	//retorno a funcao em execucao
	SetFunName(cRotinaAtual)

Return(Nil)

/*/{Protheus.doc} MenuDef
Cria os Menus da Rotina
@type function
@version 1.0
@author  g.sampaio 
@since 20/09/2022
@return array, aRotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Pesquisar'   		Action 'PesqBrw'          					OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  		Action 'VIEWDEF.RCPGA053' 					OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'  		Action 'VIEWDEF.RCPGA053' 					OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'     		Action 'U_RCPGA53LEG()' 					OPERATION 10 ACCESS 0
	ADD OPTION aRotina Title 'Atualizar'    	Action 'U_RCPGA53E(U94->U94_CODIGO)' 		OPERATION 08 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
Cria o Modelo de Dados
@type function
@version 1.0
@author  g.sampaio 
@since 20/09/2022
@return object, oModel
/*/
Static Function ModelDef()

	Local oModel	:= NIL
	Local oStruU94 	:= FWFormStruct( 1, 'U94', /*bAvalCampo*/, /*lViewUsado*/ )

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PCPGA053', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Crio a Enchoice
	oModel:AddFields( 'U94MASTER', /*cOwner*/, oStruU94 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ 'U94_FILIAL' , 'U94_CODIGO' })

	// Preencho a descrição da entidade
	oModel:GetModel('U94MASTER'):SetDescription('Solicitações de Manutenção')

Return oModel

/*/{Protheus.doc} ViewDef
Cria a camada de Visão
@type function
@version 1.0
@author  g.sampaio 
@since 20/09/2022
@return object, oView
/*/
Static Function ViewDef()
	
	Local bBloco	:= {|| }
	Local oStruU94 	:= FWFormStruct(2,'U94')
	Local oModel 	:= FWLoadModel('RCPGA053')
	Local oView		:= Nil

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	// cria o cabeçalho
	oView:AddField('VIEW_U94', oStruU94, 'U94MASTER')

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_U94' , 'PANEL_CABECALHO')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_U94')

	// Habilita a quebra dos campos na Vertical
	oView:SetViewProperty( 'U94MASTER', 'SETLAYOUT', { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

	// Inicializacao do campo Contrato quando chamado pela rotina de Contrato
	bBloco := {|oView| IniCpoCem(oView)}
	oView:SetAfterViewActivate(bBloco)

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} RCPGA53LEG
Funcao de Legenda
@type function
@version 1.0
@author g.sampaio
@since 30/03/2024
/*/
User Function RCPGA53LEG()

	BrwLegenda("Status","Legenda",{{"BR_BRANCO","Pendente"},{"BR_VERDE","Em Execução"},{"BR_VERMELHO","Executado"}})

Return(Nil)

/*/{Protheus.doc} RCPGA53E
Funcao para excutar a Solicitacao
@type function
@version 1.0
@author g.sampaio
@since 30/03/2024
@param cCodSolicitacao, character, codigo da solicitacao
/*/
User Function RCPGA53E(cCodSolicitacao)

	Local aArea  			:= GetArea()
	Local aAreaU94			:= U94->(GetArea())
	Local aStatus			:= {}
	Local cObservacoes		:= ""
	Local cCSSGet			:= ""
	Local cBlueCSSButton	:= ""
	Local cGrayCSSButton	:= ""
	Local cGetHora 			:= Time()
	Local cGetUsuario 		:= UsrRetName(RetCodUsr())
	Local dGetData 			:= dDatabase
	Local lWhen				:= .T.
	Local nCmbStatus 		:= 1
	Local oBtnConfirmar		:= Nil
	Local oBtnFechar		:= Nil
	Local oCmbStatus		:= Nil
	Local oGetUsuario		:= Nil
	Local oGetData			:= Nil
	Local oGetHora			:= Nil
	Local oGroup1			:= Nil
	Local oGroup2			:= Nil
	Local oGroup3			:= Nil
	Local oSayUsuario		:= Nil
	Local oSayData			:= Nil
	Local oSayHora			:= Nil
	Local oSayStatus		:= Nil
	Local oDlgExec			:= Nil
	Local oButtonVirtus		:= VirtusEstiloCSS():New() // inicio a classe de butoes virtus

	Default cCodSolicitacao := ""

	// atribui o estilo dos botoes
	cBlueCSSButton		:= oButtonVirtus:CSSButtonBlue()
	cGrayCSSButton		:= oButtonVirtus:CSSButtonGray()
	cCSSGet				:= oButtonVirtus:CSSGet(Nil, 6)

	U94->(DBSetOrder(1))
	If U94->(MsSeek(xFilial("U94")+cCodSolicitacao)) .And. U94->U94_STATUS <> "F"

		// Carrega os Status
		AtuStatus(@nCmbStatus, @aStatus, @lWhen)

		DEFINE MSDIALOG oDlgExec TITLE "Atualizar Solicitação" FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL

		@ 003, 004 GROUP oGroup1 TO 040, 300 PROMPT "Dados Solicitação" OF oDlgExec COLOR 0, 16777215 PIXEL

		@ 010, 010 SAY oSayUsuario PROMPT "Usuário" SIZE 025, 007 OF oDlgExec COLORS 0, 16777215 PIXEL
		@ 020, 010 MSGET oGetUsuario VAR cGetUsuario WHEN .F. SIZE 120, 010 OF oDlgExec COLORS 0, 16777215 PIXEL HASBUTTON

		@ 010, 160 SAY oSayData PROMPT "Data" SIZE 025, 007 OF oDlgExec COLORS 0, 16777215 PIXEL
		@ 020, 160 MSGET oGetData VAR dGetData WHEN .F.  SIZE 060, 010 OF oDlgExec COLORS 0, 16777215 PIXEL HASBUTTON

		@ 010, 240 SAY oSayHora PROMPT "Hora" SIZE 025, 007 OF oDlgExec COLORS 0, 16777215 PIXEL
		@ 020, 240 MSGET oGetHora VAR cGetHora WHEN .F.  SIZE 040, 010 OF oDlgExec COLORS 0, 16777215 PIXEL HASBUTTON

		@ 045, 004 GROUP oGroup2 TO 160, 300 PROMPT "Observacoes" OF oDlgExec COLOR 0, 16777215 PIXEL

		@ 055, 177 SAY oSayStatus PROMPT "Status" SIZE 025, 007 OF oDlgExec COLORS 0, 16777215 PIXEL
		@ 053, 214 MSCOMBOBOX oCmbStatus VAR nCmbStatus ITEMS aStatus WHEN lWhen SIZE 066, 010 OF oDlgExec COLORS 0, 16777215 PIXEL

		@ 068, 010 Get oMemo Var cObservacoes Memo Size 285, 080 Of oDlgExec Pixel
		oMemo:bRClicked := { || AllwaysTrue() }

		@ 165, 004 GROUP oGroup3 TO 195, 300 OF oDlgExec COLOR 0, 16777215 PIXEL

		@ 175, 195 BUTTON oBtnFechar PROMPT "Fechar" SIZE 037, 012 OF oDlgExec PIXEL ACTION oDlgExec:End()
		@ 175, 245 BUTTON oBtnConfirmar PROMPT "Confirmar" SIZE 037, 012 OF oDlgExec PIXEL ACTION ;
			Confirmar( cGetUsuario, dGetData, cGetHora, cObservacoes, oCmbStatus:nAT, @oDlgExec)

		oBtnConfirmar:SetCSS(cBlueCSSButton)
		oBtnFechar:SetCSS(cGrayCSSButton)
		oGetUsuario:SetCSS(cCSSGet)
		oGetData:SetCSS(cCSSGet)
		oGetHora:SetCSS(cCSSGet)
		oCmbStatus:SetCSS(cCSSGet)
		oMemo:SetCSS(cCSSGet)

		ACTIVATE MSDIALOG oDlgExec CENTERED

	ElseIf U94->U94_STATUS == "F"
		MsgAlert("Solicitação já Finalizada")

	Else
		MsgStop("Solicitação não encontrada")

	EndIf

	RestArea(aAreaU94)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} RCPGA53I
Abre a tela de inclusao de Solicitacao
@type function
@version 1.0
@author g.sampaio
@since 30/03/2024
@param cCodContrato, character, codigo do contrato
/*/
User Function RCPGA53I(cCodContrato)

	Local aArea  		:= GetArea()
	Local aAreaU00		:= U00->(GetArea())
	Local cRotinaAtual 	:= FunName()

	Default cCodContrato := ""

	U00->(DBSetOrder(1))
	If U00->(MsSeek(xFilial("U00")+cCodContrato))

		// Altero o nome da rotina para considerar o menu deste MVC
		SetFunName("RCPGA053")

		FWExecView('INCLUIR','RCPGA053',3,,{|| .T. })

		//retorno a funcao em execucao
		SetFunName(cRotinaAtual)

	EndIf

	RestArea(aAreaU00)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} RCPGA53H
Funcao de Solicitacoes em Aberto
@type function
@version 1.0
@author g.sampaio
@since 30/03/2024
/*/
User Function RCPGA53H(cCodContrato)

	Local aArea  			:= GetArea()
	Local aAreaU00			:= U00->(GetArea())
	Local aWBSolicitacao 	:= {}
	Local cCessionario 		:= ""
	Local cBlueCSSButton	:= ""
	Local cGrayCSSButton	:= ""
	Local cGreenCSSButton	:= ""
	Local cCSSGet			:= ""
	Local oBtnExecutar		:= Nil
	Local oBtnFechar		:= Nil
	Local oBtnIncluir		:= Nil
	Local oGetContrato		:= Nil
	Local oGetCessionario	:= Nil
	Local oGroup1			:= Nil
	Local oGroup2			:= Nil
	Local oGroup3			:= Nil
	Local oSayContrato		:= Nil
	Local oSayCessionario	:= Nil
	Local oWBSolicitacao	:= Nil
	Local oDlgSolic			:= Nil
	Local oButtonVirtus		:= VirtusEstiloCSS():New() // inicio a classe de butoes virtus

	Default cCodContrato := ""

	// atribui o estilo dos botoes
	cBlueCSSButton		:= oButtonVirtus:CSSButtonBlue()
	cGrayCSSButton		:= oButtonVirtus:CSSButtonGray()
	cGreenCSSButton		:= oButtonVirtus:CSSButtonGreen()
	cCSSGet				:= oButtonVirtus:CSSGet(Nil, 6)

	U00->(DBSetOrder(1))
	If U00->(MsSeek(xFilial("U00")+cCodContrato))

		cCessionario := U00->U00_NOMCLI

		DEFINE MSDIALOG oDlgSolic TITLE "Solicitações em Aberto" FROM 000, 000  TO 500, 1000 COLORS 0, 16777215 PIXEL

		@ 003, 003 GROUP oGroup1 TO 038, 498 PROMPT "Dados" OF oDlgSolic COLOR 0, 16777215 PIXEL

		@ 010, 015 SAY oSayContrato PROMPT "Contrato" SIZE 025, 007 OF oDlgSolic COLORS 0, 16777215 PIXEL
		@ 020, 015 MSGET oGetContrato VAR cCodContrato WHEN .F. SIZE 060, 010 OF oDlgSolic COLORS 0, 16777215 PIXEL

		@ 010, 090 SAY oSayCessionario PROMPT "Cessionario" SIZE 034, 007 OF oDlgSolic COLORS 0, 16777215 PIXEL
		@ 020, 090 MSGET oGetCessionario VAR cCessionario WHEN .F. SIZE 190, 010 OF oDlgSolic COLORS 0, 16777215 PIXEL

		@ 040, 003 GROUP oGroup3 TO 218, 498 PROMPT "Solicitações" OF oDlgSolic COLOR 0, 16777215 PIXEL
		FWBSolicitacoes(cCodContrato, @aWBSolicitacao, @oWBSolicitacao, @oDlgSolic)

		@ 220, 003 GROUP oGroup2 TO 248, 498 OF oDlgSolic COLOR 0, 16777215 PIXEL

		@ 228, 010 BUTTON oBtnIncluir PROMPT "Incluir" SIZE 037, 012 OF oDlgSolic PIXEL ;
			ACTION FWMsgRun(,{|oSay| IncSolic(cCodContrato, @aWBSolicitacao, @oWBSolicitacao, @oDlgSolic)},;
			'Aguarde...', 'Incluindo uma nova solicitação...')

		@ 228, 400 BUTTON oBtnFechar PROMPT "Fechar" SIZE 037, 012 OF oDlgSolic PIXEL ACTION oDlgSolic:End()

		@ 228, 450 BUTTON oBtnExecutar PROMPT "Executar" SIZE 037, 012 OF oDlgSolic PIXEL ;
			ACTION FWMsgRun(,{|oSay| ExecSolic(aWBSolicitacao[oWBSolicitacao:nAt,2], cCodContrato, @aWBSolicitacao,;
			@oWBSolicitacao, @oDlgSolic)}, 'Aguarde...', 'Executando solicitação...')

		// atribui o estilo dos botoes
		oBtnIncluir:SetCSS(cGreenCSSButton)
		oBtnExecutar:SetCSS(cBlueCSSButton)
		oBtnFechar:SetCSS(cGrayCSSButton)
		oGetContrato:SetCSS(cCSSGet)
		oGetCessionario:SetCSS(cCSSGet)

		ACTIVATE MSDIALOG oDlgSolic CENTERED

	EndIf

	RestArea(aAreaU00)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} RCPGA53R
Funcao para retornar o campo do endereco
@type function
@version 1.0
@author g.sampaio
@since 06/04/2024
@param cCampo, character, campo do endereco
@return character, valor do campo
/*/
User Function RCPGA53R(cCampo)

	Local cRetorno 		:= ""
	Local cQuery		:= ""
	Local cCodContrato	:= ""
	Local cItemEnd		:= ""
	Local oModel		:= FWModelActive()
	Local oModelU94		:= oModel:GetModel("U94MASTER")

	// pego o codigo do contrto
	cCodContrato 	:= oModelU94:GetValue("U94_CONTRA")
	cItemEnd		:= oModelU94:GetValue("U94_ITEM")

	cQuery := " SELECT U04."+cCampo+" AS RETORNO FROM " + RetSQLName("U04") + " U04 "
	cQuery += " WHERE U04.D_E_L_E_T_ = ' ' "
	cQuery += " AND U04.U04_FILIAL = '" + xFilial("U04") + "'"
	cQuery += " AND U04.U04_CODIGO = '" + cCodContrato + "'"
	cQuery += " AND U04.U04_ITEM = '" + cItemEnd + "'"

	cQuery := ChangeQuery(cQuery)

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TRBU04' )

	If TRBU04->(!Eof())
		cRetorno := TRBU04->RETORNO
	EndIf

Return(cRetorno)

/*/{Protheus.doc} IncSolic
Inclui solicitacao
@type function
@version 1.0
@author g.sampaio
@since 06/04/2024
@param cCodContrato, character, codigo do contrato
@param aWBSolicitacao, array, array de solicitacoes
@param oWBSolicitacao, object, objeto da tela de solicitacoes
@param oDlgSolic, object, objeto da tela de solicitacoes
/*/
Static Function IncSolic(cCodContrato, aWBSolicitacao, oWBSolicitacao, oDlgSolic)

	Default cCodContrato	:= ""
	Default aWBSolicitacao	:= {}
	Default oWBSolicitacao	:= Nil
	Default oDlgSolic		:= Nil

	// faco a inclusao da solicitacao
	U_RCPGA53I(cCodContrato)

	aWBSolicitacao	:= {}
	oWBSolicitacao 	:= Nil
	FreeObj(oWBSolicitacao)

	FWBSolicitacoes(cCodContrato, @aWBSolicitacao, @oWBSolicitacao, @oDlgSolic)

	If oDlgSolic <> Nil
		oDlgSolic:Refresh()
	EndIf

Return(Nil)

/*/{Protheus.doc} ExecSolic
Funcao para executar a Solicitacao
@type function
@version 1.0
@author g.sampaio
@since 06/04/2024
@param cCodigoSol, character, codigo da solicitacao
@param cCodContrato, character, codigo do contrato
@param aWBSolicitacao, array, array de solicitacoes
@param oWBSolicitacao, object, objeto da tela de solicitacoes
@param oDlgSolic, object, objeto da tela de solicitacoes
/*/
Static Function ExecSolic(cCodigoSol, cCodContrato, aWBSolicitacao, oWBSolicitacao, oDlgSolic)

	Default cCodigoSol 		:= ""
	Default cCodContrato	:= ""
	Default aWBSolicitacao	:= {}
	Default oWBSolicitacao	:= Nil
	Default oDlgSolic		:= Nil

	// executo a solicitacao
	U_RCPGA53E(cCodigoSol)

	aWBSolicitacao	:= {}
	oWBSolicitacao 	:= Nil
	FreeObj(oWBSolicitacao)

	FWBSolicitacoes(cCodContrato, @aWBSolicitacao, @oWBSolicitacao, @oDlgSolic)

	If oDlgSolic <> Nil
		oDlgSolic:Refresh()
	EndIf

Return(NIl)

/*/{Protheus.doc} IniCpoCem
Inicializado padrao dos campos
@type function
@version 1.0
@author g.sampaio
@since 06/04/2024
@param oView, object, objeto da View
/*/
Static Function IniCpoCem(oView)

	Local cItemEnd		:= ""
	Local nOperation 	:= oView:GetOperation()

	//valido se e inclusao e chamada pela tela do contrato
	If nOperation == 3 .And. IsInCallStack("U_RCPGA001")

		// Pego o item do endereco
		cItemEnd := RetEndereco(U00->U00_CODIGO)

		//Informacoes do contrato
		FwFldPut("U94_CONTRA", U00->U00_CODIGO,,,,.T.)

		//Informacoes do endreco
		FwFldPut("U94_ITEM", cItemEnd,,,,.T.)
		FwFldPut("U94_QUADRA", U_RCPGA53R("U04_QUADRA"),,,,.T.)
		FwFldPut("U94_MODULO", U_RCPGA53R("U04_MODULO"),,,,.T.)
		FwFldPut("U94_JAZIGO", U_RCPGA53R("U04_JAZIGO"),,,,.T.)
		FwFldPut("U94_OSSARI", U_RCPGA53R("U04_OSSARI"),,,,.T.)
		FwFldPut("U94_NICHOO", U_RCPGA53R("U04_NICHOO"),,,,.T.)
		FwFldPut("U94_CREMAT", U_RCPGA53R("U04_CREMAT"),,,,.T.)
		FwFldPut("U94_NICHOC", U_RCPGA53R("U04_NICHOC"),,,,.T.)

		oView:Refresh()

	EndIf

Return(Nil)

/*/{Protheus.doc} RetEndereco
Retorna o endereco do contrato
@type function
@version 1.0
@author g.sampaio
@since 06/04/2024
@param cCodContrato, character, codigo do contrato
@return character, item do endereco
/*/
Static Function RetEndereco(cCodContrato)

	Local cRetorno 	:= ""
	Local cQuery	:= ""

	cQuery := " SELECT U04.U04_ITEM AS ITEMEND FROM " + RetSQLName("U04") + " U04 "
	cQuery += " WHERE U04.D_E_L_E_T_ = ' ' "
	cQuery += " AND U04.U04_FILIAL = '" + xFilial("U04") + "'"
	cQuery += " AND U04.U04_CODIGO = '" + cCodContrato + "'"
	cQuery += " ORDER BY U04.U04_ITEM ASC "

	cQuery := ChangeQuery(cQuery)

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TRBU04' )

	If TRBU04->(!Eof())
		cRetorno := TRBU04->ITEMEND
	EndIf

Return(cRetorno)

/*/{Protheus.doc} AtuStatus
Atualizo o status da Solicitação
@type function
@version 1.0
@author g.sampaio
@since 30/03/2024
@param nCmbStatus, numeric, posicao do combo
@param aStatus, array, statys disponiveis
@param lWhen, logical, defino se o campo esta habilitado
/*/
Static Function AtuStatus(nCmbStatus, aStatus, lWhen)

	Default nCmbStatus 	:= 1
	Default aStatus		:= {}
	Default lWhen		:= .T.

	// Carrega os Status
	aStatus := {"Em Execução", "Finalizado"}

	// caso estiver em execução ja mudo para status finalizado
	If U94->U94_STATUS == "E"
		nCmbStatus	:= 2
		lWhen 		:= .F.
	EndIf

Return(Nil)

/*/{Protheus.doc} Confirmar
Confirma a execução da Solicitação
@type function
@version 1.0
@author g.sampaio
@since 30/03/2024
@param cGetUsuario, character, usuario que esta registarando a execucao
@param dGetData, date, data da execucao
@param cGetHora, character, hora da execucao
@param cObservacoes, character, observacoes da execucao
@param nStatus, numeric, status da execucao
@param oDlgExec, object, objeto da tela de execucao
/*/
Static Function Confirmar(cGetUsuario, dGetData, cGetHora, cObservacoes, nStatus, oDlgExec)

	Local cNovaObservacao := ""

	Default cGetUsuario 	:= UsrRetName(RetCodUsr())
	Default dGetData 		:= dDatabase
	Default cGetHora 		:= Time()
	Default cObservacoes 	:= ""
	Default nStatus 		:= 0
	Default oDlgExec		:= Nil

	// pego a observacao atual
	cNovaObservacao := U94->U94_OBSEXE + CRLF + CRLF

	// nova observacao
	cNovaObservacao += "["+IIF(nStatus == 1, "EM EXECUCAO", "FINALIZADO")+" - "+cGetUsuario+" - "+ DtoC(dGetData) +" - "+cGetHora+"]" + CRLF

	// Verifico se o campo de observacoes esta preenchido
	If !Empty(cObservacoes)
		cNovaObservacao += cObservacoes + CRLF
	EndIf

	BEGIN TRANSACTION

		// Atualizo os campos
		If U94->(Reclock("U94", .F.))
			If nStatus == 1 .And. U94->U94_STATUS == "P"
				U94->U94_STATUS	:= "E"
				U94->U94_USREXE	:= cGetUsuario
				U94->U94_DTEXEC	:= dGetData
				U94->U94_HREXEC	:= cGetHora
			Else
				U94->U94_STATUS	:= "F"
				U94->U94_USRFIN	:= cGetUsuario
				U94->U94_DTFINA	:= dGetData
				U94->U94_HRFINA	:= cGetHora
			EndIf
			U94->U94_OBSEXE		:= cNovaObservacao
			U94->(MsUnlock())
		Else
			U94->(DisarmTransaction())
			BREAK
		EndIf

	END TRANSACTION

	// Atualizo a tela
	oDlgExec:End()
	MsgInfo("Solicitação Atualizada com Sucesso")

Return(Nil)

/*/{Protheus.doc} FWBSolicitacoes
Funcao para lista as Solicitacoes em Aberto
@type function
@version 1.0
@author g.sampaio
@since 30/03/2024
@param cCodContrato, character, codigo do contrato
@param aWBSolicitacao, array, array de solicitacoes
@param oWBSolicitacao, object, objeto da tela de solicitacoes
/*/
Static Function FWBSolicitacoes(cCodContrato, aWBSolicitacao, oWBSolicitacao, oDlgSolic)

	Local cQuery 		:= ""
	Local oLegPendente	:= LoadBitmap( GetResources(), "BR_BRANCO")
	Local oLegExecucao	:= LoadBitmap( GetResources(), "BR_VERDE")

	cQuery := " SELECT * FROM " + RetSQLName("U94") + " U94 "
	cQuery += " WHERE U94.D_E_L_E_T_ = ' ' "
	cQuery += " AND U94.U94_FILIAL = '" + xFilial("U94") + "'"
	cQuery += " AND U94.U94_CONTRA = '" + cCodContrato + "'"
	cQuery += " AND U94.U94_STATUS <> 'F' "

	cQuery := ChangeQuery(cQuery)

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TRBU94' )

	If TRBU94->(!Eof())

		While TRBU94->(!Eof())

			If TRBU94->U94_STATUS == "P"
				Aadd(aWBSolicitacao, {oLegPendente, AllTrim(TRBU94->U94_CODIGO), U_RCPGA52A(TRBU94->U94_TIPO), AllTrim(TRBU94->U94_DESCRI), AllTrim(TRBU94->U94_SOLICI)})
			Else
				Aadd(aWBSolicitacao, {oLegExecucao, AllTrim(TRBU94->U94_CODIGO), U_RCPGA52A(TRBU94->U94_TIPO), AllTrim(TRBU94->U94_DESCRI), AllTrim(TRBU94->U94_SOLICI)})
			EndIf

			TRBU94->(DbSkip())
		EndDo
	Else
		Aadd(aWBSolicitacao,{".","","","",""})
	EndIf

	@ 050, 007 LISTBOX oWBSolicitacao Fields HEADER "","Codigo","Tipo","Descrição","Solicitante" SIZE 488, 163 OF oDlgSolic PIXEL ColSizes 50,50
	oWBSolicitacao:SetArray(aWBSolicitacao)
	oWBSolicitacao:bLine := {|| {;
		aWBSolicitacao[oWBSolicitacao:nAt,1],;
		aWBSolicitacao[oWBSolicitacao:nAt,2],;
		aWBSolicitacao[oWBSolicitacao:nAt,3],;
		aWBSolicitacao[oWBSolicitacao:nAt,4],;
		aWBSolicitacao[oWBSolicitacao:nAt,5];
		}}

Return(Nil)
