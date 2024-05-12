#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTIL050
Browse de Anexo de Documentos
@type function
@version 1.0
@author g.sampaio
@since 20/09/2022
/*/
User Function RUTIL050()

	Local oBrowse	:= {}

	// Altero o nome da rotina para considerar o menu deste MVC
	SetFunName("RUTIL050")

	// crio o objeto do Browser
	oBrowse := FWmBrowse():New()

	// defino o Alias
	oBrowse:SetAlias("U95")

	// informo a descrição
	oBrowse:SetDescription("Anexo de Documentos")

	// crio as legendas
	oBrowse:AddLegend("U95_STSSIN == 'P'", "GREEN"	,	"Pendente")
	oBrowse:AddLegend("U95_STSSIN == 'C'", "RED"	,	"Concluído")
	oBrowse:AddLegend("U95_STSSIN == 'E'", "BLACK"	,	"Erro")

	// ativo o browser
	oBrowse:Activate()

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

	Local aRotina       := {}

	ADD OPTION aRotina Title 'Pesquisar'   			Action 'PesqBrw'          	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  			Action 'VIEWDEF.RUTIL050' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Enviar Documentos' 	Action 'U_RUTIL50C()'       OPERATION 11 ACCESS 0

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

	Local oModel	        := NIL
	Local oStruU95  	    := FWFormStruct( 1, 'U95', /*bAvalCampo*/, /*lViewUsado*/ )	// abro o parambox

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PUTIL050', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Crio a Enchoice
	oModel:AddFields( 'U95MASTER', /*cOwner*/, oStruU95 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ 'U95_FILIAL' , 'U95_CODIGO' })

	// Preencho a descrição da entidade
	oModel:GetModel('U95MASTER'):SetDescription('Dados do Agendamento')

Return(oModel)

/*/{Protheus.doc} ViewDef
Cria a camada de Visão
@type function
@version 1.0
@author  g.sampaio 
@since 20/09/2022
@return object, oView
/*/
Static Function ViewDef()

	Local oStruU95 			:= FWFormStruct(2,'U95')
	Local oModel 			:= FWLoadModel('RUTIL050')
	Local oView				:= Nil

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	// cria o cabeçalho
	oView:AddField('VIEW_U95', oStruU95, 'U95MASTER')

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox("PAINEL_STATUS", 8)
	oView:CreateHorizontalBox('PANEL_CABECALHO' , 92)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_U95' , 'PANEL_CABECALHO')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_U95')

	// Habilita a quebra dos campos na Vertical
	oView:SetViewProperty( 'U95MASTER', 'SETLAYOUT', { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

Return(oView)

/*/{Protheus.doc} RUTIL50A
Funcao para anexar arquivos
@type function
@version 1.0
@author g.sampaio
@since 23/03/2024
@param cCodigo, character, codigo da entidade
@param cModulo, character, modulo do documento
@param cRotina, character, rotina que esta sendo utilizada
@param cContrato, character, codigo do contrato
/*/
User Function RUTIL50A(cCodigo, cModulo, cRotina, cContrato)

	Local oAnexarArquivos 		:= Nil
	Local oVirtusGestaoAcessos	:= VirtusGestaoAcessos():New()

	Default cCodigo 	:= ""
	Default cModulo		:= ""
	Default cRotina 	:= ""
	Default cContrato 	:= ""

	oVirtusGestaoAcessos:AcessosUsuario()

	If oVirtusGestaoAcessos:ValidaAcessos(18) // acesso a base de conhecimento

		oAnexarArquivos := AnexaDocumentos():New(cCodigo, cModulo, cRotina, cContrato)
		oAnexarArquivos:Wizard()

		FreeObj(oAnexarArquivos)
		oAnexarArquivos := Nil

	Else
		MsgAlert("Usuário sem acesso para anexar documentos!")
	EndIf

Return(Nil)

/*/{Protheus.doc} RUTIL50B
Tela de visualizcao dos documentos
@type function
@version 1.0
@author g.sampaio
@since 23/03/2024
@param cCodigo, character, codigo da entidade
@param cModulo, character, modulo do documento
@param cRotina, character, rotina que esta sendo utilizada
@param cContrato, character, codigo do contrato
/*/
User Function RUTIL50B(cCodigo, cModulo, cRotina, cContrato)

	SetFunName("RUTIL50B")

	Local aBrwDocumentos 		As Array
	Local cGetFilial			As Character
	Local cGetContrato			As Character
	Local cBlueCSSButton 		As Character
	Local cRedCSSButton 		As Character
	Local cGreenCSSButton 		As Character
	Local cOrangeCSSButton 		As Character
	Local cGrayCSSButton		As Character
	Local oBtnFechar			As Object
	Local oBtnVisualizar		As Object
	Local oBtnEditar			As Object
	Local oBtnExcluir			As Object
	Local oBtnAnexar			As Object
	Local oGetFilial			As Object
	Local oGetContrato			As Object
	Local oGroup1				As Object
	Local oGroup2				As Object
	Local oGroup3				As Object
	Local oSayFilial			As Object
	Local oSayContrato			As Object
	Local oBrwDocumentos		As Object
	Local oDlgDoc				As Object
	Local oButtonVirtus			As Object
	Local oVirtusGestaoAcessos	As Object

	Default cCodigo 	:= ""
	Default cModulo		:= ""
	Default cRotina 	:= ""
	Default cContrato 	:= ""

	oButtonVirtus			:= VirtusEstiloCSS():New() // inicio a classe de butoes virtus
	cBlueCSSButton			:= oButtonVirtus:CSSButtonBlue()
	cRedCSSButton			:= oButtonVirtus:CSSButtonRed()
	cGreenCSSButton			:= oButtonVirtus:CSSButtonGreen()
	cOrangeCSSButton		:= oButtonVirtus:CSSButtonOrange()
	cGrayCSSButton			:= oButtonVirtus:CSSButtonGray()
	cCSSGet					:= oButtonVirtus:CSSGet(Nil, 6)
	oVirtusGestaoAcessos	:= VirtusGestaoAcessos():New()

	// carrego os acessos do usuario
	oVirtusGestaoAcessos:AcessosUsuario()

	// atribui valor a variavel
	cGetFilial 		:= cFilAnt + "-" + FwFilialName()
	cGetContrato 	:= cContrato + " - " + GetContrato(cContrato, cModulo)

	DEFINE MSDIALOG oDlgDoc TITLE "Documentos" FROM 000, 000  TO 600, 1000 COLORS 0, 16777215 PIXEL

	@ 003, 002 GROUP oGroup1 TO 041, 495 PROMPT "Contrato" OF oDlgDoc COLOR 0, 16777215 PIXEL
	@ 012, 010 SAY oSayFilial PROMPT "Filial" SIZE 025, 007 OF oDlgDoc COLORS 0, 16777215 PIXEL
	@ 011, 239 SAY oSayContrato PROMPT "Contrato" SIZE 025, 007 OF oDlgDoc COLORS 0, 16777215 PIXEL
	@ 021, 010 MSGET oGetFilial VAR cGetFilial WHEN .F. SIZE 196, 010 OF oDlgDoc COLORS 0, 16777215 PIXEL
	@ 021, 238 MSGET oGetContrato VAR cGetContrato WHEN .F. SIZE 250, 010 OF oDlgDoc COLORS 0, 16777215 PIXEL

	@ 044, 003 GROUP oGroup2 TO 250, 496 PROMPT "Documentos" OF oDlgDoc COLOR 0, 16777215 PIXEL
	ListaDocumentos(cContrato, @aBrwDocumentos, @oBrwDocumentos, @oDlgDoc)

	@ 255, 004 GROUP oGroup3 TO 293, 496 PROMPT "" OF oDlgDoc COLOR 0, 16777215 PIXEL

	@ 270, 059 BUTTON oBtnVisualizar PROMPT "Visualizar" SIZE 037, 012 OF oDlgDoc PIXEL ;
		ACTION ( VisualizarDocumento(cContrato, aBrwDocumentos[oBrwDocumentos:nAt,2]) )

	If oVirtusGestaoAcessos:ValidaAcessos(19) // acesso a base de conhecimento
		@ 270, 108 BUTTON oBtnEditar PROMPT "Editar" SIZE 037, 012 OF oDlgDoc PIXEL ;
			ACTION ( FWMsgRun(,{|oSay| EditarDocumento(cContrato, aBrwDocumentos[oBrwDocumentos:nAt,2], @aBrwDocumentos,;
			@oBrwDocumentos, @oDlgDoc ) }, 'Aguarde...','Preparando os dados do documento.')   )
	EndIf

	If oVirtusGestaoAcessos:ValidaAcessos(20) // acesso a base de conhecimento
		@ 270, 158 BUTTON oBtnExcluir PROMPT "Excluir" SIZE 037, 012 OF oDlgDoc PIXEL ;
			ACTION ( FWMsgRun(,{|oSay| ExcluirDocumento(cContrato, aBrwDocumentos[oBrwDocumentos:nAt,2], @aBrwDocumentos,;
			@oBrwDocumentos, @oDlgDoc ) }, 'Aguarde...','Relizando a exclusao do documento.')   )
	EndIf

	If oVirtusGestaoAcessos:ValidaAcessos(18) // acesso a base de conhecimento
		@ 270, 011 BUTTON oBtnAnexar PROMPT "Anexar" SIZE 037, 012 OF oDlgDoc PIXEL ;
			ACTION ( U_RUTIL50A(cContrato, cModulo, cRotina, cContrato) )
	EndIf

	@ 269, 446 BUTTON oBtnFechar PROMPT "Fechar" SIZE 037, 012 OF oDlgDoc PIXEL ACTION ( oDlgDoc:End() )

	oBtnVisualizar:SetCSS(cOrangeCSSButton)
	If oBtnEditar <> Nil
		oBtnEditar:SetCSS(cBlueCSSButton)
	EndIf

	If oBtnExcluir <> Nil
		oBtnExcluir:SetCSS(cRedCSSButton)
	EndIf

	If oBtnAnexar <> Nil
		oBtnAnexar:SetCSS(cGreenCSSButton)
	EndIf

	oBtnFechar:SetCSS(cGrayCSSButton)
	oGetFilial:SetCSS(cCSSGet)
	oGetContrato:SetCSS(cCSSGet)

	ACTIVATE MSDIALOG oDlgDoc CENTERED

	SetFunName("RUTIL50B")

Return(Nil)

/*/{Protheus.doc} RUTIL50C
Funcao para enviar os documentos
@type function
@version 1.0
@author g.sampaio
@since 23/03/2024
/*/
User Function RUTIL50C(aParam)

	Local cMessage 			:= ""
	Local nStart 			:= Seconds()
	Local aArea 			:= GetArea()
	Local oAnexaDocumentos 	:= Nil

	Default aParam := {"01", "01"}

	//Valido se a execução é via Job
	If IsBlind()

		cMessage := "[RUTIL50C][INICIO PROCESSAMENTO DE DOCUMENTOS PENDENTES]"
		FwLogMsg("INFO", , "JOB", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		cMessage := "[RUTIL50C][EMPRESA: " + Alltrim(aParam[1]) + " FILIAL: " + Alltrim(aParam[2]);
			+ "DATA: " + DTOC( Date() ) + " HORA: " + Time() + "]"
		FwLogMsg("INFO", , "JOB", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

		RESET ENVIRONMENT
		PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2]

	Endif

	//-- Bloqueia rotina para apenas uma execução por vez
	//-- Criação de semáforo no servidor de licenças
	//-- LockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> lCreated
	If !LockByName("RUTIL50C", .F., .T.)
		If IsBlind()
			cMessage := "[RUTIL50C]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde..."
			FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		Else
			MsgAlert("[RUTIL50C]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde...")
		EndIf

		Return
	EndIf

	//-- Comando para o TopConnect alterar mensagem do Monitor --//
	FWMonitorMsg("RUTIL50C: JOB PROCESSAMENTO DOCUMENTOS PENDENTES => " + cEmpAnt + "-" + cFilAnt)

	oAnexaDocumentos := AnexaDocumentos():New()
	FWMsgRun(,{|| oAnexaDocumentos:ProcessaDocumentos() },;
		'Aguarde...', 'Processando documentos pendentes...')

	FreeObj(oAnexaDocumentos)

	//-- Libera rotina para nova execução
	//-- Excluir semáforo
	//-- UnLockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> Nil
	UnLockByName("RUTIL50C", .F., .T.)

	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} ListaDocumentos
Funcao para listar os documentos
@type function
@version 1.0
@author g.sampaio
@since 23/03/2024
@param cContrato, character, codigo do contrato
/*/
Static Function ListaDocumentos(cContrato, aBrwDocumentos, oBrwDocumentos, oDlgDoc)

	Local oLegenda 			As Object
	Local oVirtusAPIDigidoc As Object
	Local nDocumento		As Numeric
	Local nPosCategoria		As Numeric

	Default cContrato 		:= ""
	Default aBrwDocumentos 	:= {}
	Default oBrwDocumentos 	:= Nil
	Default oDlgDoc 		:= Nil

	// atribui valor as variaveis
	oLegenda 	:= LoadBitmap( GetResources(), "BR_BRANCO")

	oVirtusAPIDigidoc := VirtusAPIDigidoc():New()
	oVirtusAPIDigidoc:BuscarDocumentoContrato(cContrato)

	// verifico se existe a lista de documentos
	If Len(oVirtusAPIDigidoc:aListaDocumentos) > 0

		// percorro a lista de documentos
		For nDocumento := 1 To Len(oVirtusAPIDigidoc:aListaDocumentos)

			// Validacao do documento
			If ValidaDocumento(@oLegenda, oVirtusAPIDigidoc:aListaDocumentos[nDocumento]["id"], oVirtusAPIDigidoc:aListaDocumentos[nDocumento]["filial"], cContrato)

				// posicao da categoria
				nPosCategoria 	:= AScan(oVirtusAPIDigidoc:aDadosCategoria,{|x| oVirtusAPIDigidoc:aListaDocumentos[nDocumento]["categoria_id"] == x[1] })

				aAux := {}
				Aadd(aAux,oLegenda)
				Aadd(aAux,oVirtusAPIDigidoc:aListaDocumentos[nDocumento]["id"] )

				If nPosCategoria > 0
					Aadd(aAux, U_SpecialNoChar( oVirtusAPIDigidoc:aDadosCategoria[nPosCategoria][2]) )
				Else
					Aadd(aAux, oVirtusAPIDigidoc:aListaDocumentos[nDocumento]["categoria_id"])
				EndIf

				Aadd(aAux,oVirtusAPIDigidoc:aListaDocumentos[nDocumento]["titulo"] )
				Aadd(aAux,oVirtusAPIDigidoc:aListaDocumentos[nDocumento]["ocr"] )
				Aadd(aBrwDocumentos,aAux)

			EndIf

		Next nDocumento

	Else
		Aadd(aBrwDocumentos, {oLegenda, "", "", "", ""})
	EndIf

	@ 054, 007 LISTBOX oBrwDocumentos Fields HEADER "","ID","Categoria","Arquivo","Título" SIZE 483, 189 OF oDlgDoc PIXEL ColSizes 5, 40, 40, 120, 120
	oBrwDocumentos:SetArray(aBrwDocumentos)
	oBrwDocumentos:bLine := {|| {;
		aBrwDocumentos[oBrwDocumentos:nAt,1],;
		aBrwDocumentos[oBrwDocumentos:nAt,2],;
		aBrwDocumentos[oBrwDocumentos:nAt,3],;
		aBrwDocumentos[oBrwDocumentos:nAt,4],;
		aBrwDocumentos[oBrwDocumentos:nAt,5];
		}}

Return(Nil)

/*/{Protheus.doc} ValidaDocumento
Funcao para validar o documento
@type function
@version 1.0
@author g.sampaio
@since 23/03/2024
@param oLegenda, object, objeto da legenda
@param cIDDigiDoc, character, ID do documento no Digidoc
@param cFilDigidoc, character, filial do documento no Digidoc
@param cContrato, character, contrato do documento
@return logical, retorno da validacao do documento
/*/
Static Function ValidaDocumento(oLegenda, nIDDigiDoc, cFilDigidoc, cContrato)

	Local cQuery 	As Character
	Local lRetorno 	As Logical

	Default oLegenda 		:= Nil
	Default nIDDigiDoc 		:= 0
	Default cFilDigidoc 	:= ""
	Default cContrato 		:= ""

	// atribui valor as variaveis
	lRetorno := .T.

	cQuery := " SELECT "
	cQuery += " 	U95.U95_CODIGO "
	cQuery += " FROM " + RetSQLName("U95") + " U95 "
	cQuery += " WHERE U95.D_E_L_E_T_ = ' ' "
	cQuery += " AND U95.U95_IDAPI = '" + cValToChar(nIDDigiDoc) + "' "
	cQuery += " AND U95.U95_CONTRA = '" + cContrato + "'"

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery( cQuery, 'TRBU95' )

	If TRBU95->(!Eof())
		oLegenda := LoadBitmap( GetResources(), "BR_VERDE")
	Else
		oLegenda := LoadBitmap( GetResources(), "BR_BRANCO")
	EndIf

	// valido se a filial do documento
	If Alltrim(cFilDigidoc) # Alltrim(cFilAnt)
		lRetorno := .F.
	EndIf

Return(lRetorno)

/*/{Protheus.doc} EditarDocumento
Funcao para editar o documento
@type function
@version 1.0
@author g.sampaio
@since 25/03/2024
@param cContrato, character, param_description
@param nIDDigiDoc, numeric, param_description
@param aBrwDocumentos, array, param_description
@param oBrwDocumentos, object, param_description
@param oDlgDoc, object, param_description
@return variant, return_description
/*/
Static Function EditarDocumento(cContrato, nIDDigiDoc, aBrwDocumentos, oBrwDocumentos, oDlgDoc)

	Local aCategoria
	Local oBtnFechar
	Local oBrnConfirmar
	Local oComboBo1
	Local nCategoria := 1
	Local oGet1
	Local cFilDoc := cFilAnt + "-" + FwFilialName()
	Local oGet2
	Local oGet3
	Local oGet4
	Local cTituloDoc
	Local cObservacoesOCR	:= ""
	Local cObservDoc
	Local cBlueCSSButton
	Local cGrayCSSButton
	Local cCSSGet
	Local oGroup1
	Local oGroup2
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oDlgAtuDoc
	Local oButtonVirtus

	Default cContrato 	:= ""
	Default nIDDigiDoc 	:= 0

	oButtonVirtus		:= VirtusEstiloCSS():New() // inicio a classe de butoes virtus
	cBlueCSSButton		:= oButtonVirtus:CSSButtonBlue()
	cGrayCSSButton		:= oButtonVirtus:CSSButtonGray()
	cCSSGet				:= oButtonVirtus:CSSGet(Nil, 6)

	// Busca as informações do documento
	GetInfoDoc(nIDDigiDoc, @cTituloDoc, @cObservDoc, @cObservacoesOCR, @nCategoria, @aCategoria)

	DEFINE MSDIALOG oDlgAtuDoc TITLE "Alteração dos Documentos" FROM 000, 000  TO 500, 625 COLORS 0, 16777215 PIXEL

	@ 003, 002 GROUP oGroup1 TO 100, 310 PROMPT "Alteracao dos Documento" OF oDlgAtuDoc COLOR 0, 16777215 PIXEL

	@ 015, 010 SAY oSay1 PROMPT "Filial" SIZE 025, 007 OF oDlgAtuDoc COLORS 0, 16777215 PIXEL
	@ 025, 010 MSGET oGet1 VAR cFilDoc WHEN .F. SIZE 130, 010 OF oDlgAtuDoc COLORS 0, 16777215 PIXEL

	@ 015, 155 SAY oSay2 PROMPT "Contrato" SIZE 025, 007 OF oDlgAtuDoc COLORS 0, 16777215 PIXEL
	@ 025, 155 MSGET oGet2 VAR cContrato WHEN .F. SIZE 060, 010 OF oDlgAtuDoc COLORS 0, 16777215 PIXEL

	@ 015, 225 SAY oSay3 PROMPT "Categoria" SIZE 025, 007 OF oDlgAtuDoc COLORS 0, 16777215 PIXEL
	@ 025, 225 MSCOMBOBOX oComboBo1 VAR nCategoria ITEMS aCategoria WHEN .T. SIZE 072, 010 OF oDlgAtuDoc COLORS 0, 16777215 PIXEL

	@ 045, 010 SAY oSay4 PROMPT "Titulo" SIZE 025, 007 OF oDlgAtuDoc COLORS 0, 16777215 PIXEL
	@ 055, 010 MSGET oGet3 VAR cTituloDoc SIZE 290, 010 OF oDlgAtuDoc COLORS 0, 16777215 PIXEL

	@ 072, 010 SAY oSay5 PROMPT "Observacoes" SIZE 037, 007 OF oDlgAtuDoc COLORS 0, 16777215 PIXEL
	@ 082, 010 MSGET oGet4 VAR cObservDoc SIZE 290, 010 OF oDlgAtuDoc COLORS 0, 16777215 PIXEL

	@ 102, 003 SAY oSay6 PROMPT "Resumo do Documento (OCR)" SIZE 078, 007 OF oDlgAtuDoc COLORS 0, 16777215 PIXEL

	@ 112, 003 Get oMemo Var cObservacoesOCR Memo Size 307, 095 Of oDlgAtuDoc Pixel
	oMemo:bRClicked := { || AllwaysTrue() }

	@ 211, 003 GROUP oGroup2 TO 245, 310 OF oDlgAtuDoc COLOR 0, 16777215 PIXEL

	@ 222, 260 BUTTON oBtnFechar PROMPT "Fechar" SIZE 037, 012 OF oDlgAtuDoc PIXEL ACTION ( oDlgAtuDoc:End() )

	@ 222, 210 BUTTON oBrnConfirmar PROMPT "Confirmar" SIZE 037, 012 OF oDlgAtuDoc PIXEL ;
		ACTION ( FWMsgRun(,{|oSay| AtualizarDocumento(cContrato, nIDDigiDoc, cFilDoc, oComboBo1:nAT, Alltrim(cTituloDoc),;
		Alltrim(cObservDoc), Alltrim(cObservacoesOCR), @oDlgAtuDoc)},'Aguarde...','Atualizando os dados do documento.') )

	oBrnConfirmar:SetCSS(cBlueCSSButton)
	oBtnFechar:SetCSS(cGrayCSSButton)
	oGet1:SetCSS(cCSSGet)
	oGet2:SetCSS(cCSSGet)
	oComboBo1:SetCSS(cCSSGet)
	oGet3:SetCSS(cCSSGet)
	oGet4:SetCSS(cCSSGet)
	oMemo:SetCSS(cCSSGet)

	ACTIVATE MSDIALOG oDlgAtuDoc CENTERED

	// atualizo a grid de informacoes
	FWMsgRun(,{|oSay| ReloadGrid(cContrato, @aBrwDocumentos, @oBrwDocumentos, @oDlgDoc) },'Aguarde...','Atualizando os dados da tela...')

Return(Nil)

/*/{Protheus.doc} GetInfoDoc
description
@type function
@version 1.0
@author g.sampaio
@since 24/03/2024
@param nIDDigiDoc, numeric, param_description
@param cTituloDoc, character, param_description
@param cObservDoc, character, param_description
@param cObservacoesOCR, character, param_description
@param nCategoria, numeric, param_description
@param aCategoria, array, param_description
@return variant, return_description
/*/
Static Function GetInfoDoc(nIDDigiDoc, cTituloDoc, cObservDoc, cObservacoesOCR, nCategoria, aCategoria)

	Local nX 					As Numeric
	Local nPosCategoria 		As Numeric
	Local nIDCategoria 			As Numeric
	Local oVirtusAPIDigidoc 	As Object

	Default nIDDigiDoc 		:= 0
	Default cTituloDoc 		:= ""
	Default cObservDoc 		:= ""
	Default cObservacoesOCR := ""
	Default nCategoria 		:= 1
	Default aCategoria 		:= {}

	oVirtusAPIDigidoc := VirtusAPIDigidoc():New()
	oVirtusAPIDigidoc:BuscarDocumento(nIDDigiDoc)

	If Len(oVirtusAPIDigidoc:aDadosDocumneto) > 0
		cTituloDoc 		:= PADR(oVirtusAPIDigidoc:aDadosDocumneto[1]["titulo"], 120)
		cObservDoc 		:= PADR(oVirtusAPIDigidoc:aDadosDocumneto[1]["observacoes"], 200)
		cObservacoesOCR := oVirtusAPIDigidoc:aDadosDocumneto[1]["ocr"]
		nIDCategoria	:= oVirtusAPIDigidoc:aDadosDocumneto[1]["categoria_id"]
		nPosCategoria 	:= AScan(oVirtusAPIDigidoc:aDadosCategoria,{|x| nIDCategoria == x[1] })

		For nX := 1 To Len(oVirtusAPIDigidoc:aDadosCategoria)
			Aadd(aCategoria, U_SpecialNoChar( oVirtusAPIDigidoc:aDadosCategoria[nX][2]) )
		Next nX

		If nPosCategoria > 0
			nCategoria := nPosCategoria
		EndIf

	EndIf

Return(Nil)

/*/{Protheus.doc} AtualizarDocumento
description
@type function
@version 1.0
@author g.sampaio
@since 24/03/2024
@param cContrato, character, param_description
@param nIDDigiDoc, numeric, param_description
@param cFilDoc, character, param_description
@param nCategoria, numeric, param_description
@param cTituloDoc, character, param_description
@param cObservDoc, character, param_description
@param cObservacoesOCR, character, param_description
@return variant, return_description
/*/
Static Function AtualizarDocumento(cContrato, nIDDigiDoc, cFilDoc, nCategoria, cTituloDoc, cObservDoc, cObservacoesOCR, oDlgAtuDoc)

	Local oVirtusAPIDigidoc As Object

	Default nIDDigiDoc 		:= 0
	Default nCategoria 		:= 1
	Default cTituloDoc 		:= ""
	Default cObservDoc 		:= ""
	Default cObservacoesOCR := ""

	If MsgNoYes("Confirma a alteração dos dados do documento?", "Alteração de Documento")

		oVirtusAPIDigidoc := VirtusAPIDigidoc():New()
		oVirtusAPIDigidoc:EditarDocumento(nIDDigiDoc, oVirtusAPIDigidoc:aDadosCategoria[nCategoria][1], cTituloDoc, cObservDoc, cObservacoesOCR)

		If oVirtusAPIDigidoc:lAtualizado
			MsgInfo("Documento atualizado com sucesso!")
		Else
			MsgAlert("Erro ao atualizar o documento!")
		EndIf

		oDlgAtuDoc:End()

	EndIf

Return(Nil)

/*/{Protheus.doc} ExcluirDocumento
description
@type function
@version 1.0
@author g.sampaio
@since 24/03/2024
@param cContrato, character, param_description
@param cIDDigiDoc, character, param_description
@param aBrwDocumentos, array, param_description
@param oBrwDocumentos, object, param_description
@param oDlgDoc, object, param_description
@return variant, return_description
/*/
Static Function ExcluirDocumento(cContrato, cIDDigiDoc, aBrwDocumentos, oBrwDocumentos, oDlgDoc)

	Local oVirtusAPIDigidoc As Object

	Default cContrato 	:= ""
	Default cIDDigiDoc 	:= ""

	If MsgNoYes("Confirma a exclusão do documento?", "Exclusão de Documento")

		oVirtusAPIDigidoc := VirtusAPIDigidoc():New()
		oVirtusAPIDigidoc:ExcluirDocumento(cIDDigiDoc)

		If oVirtusAPIDigidoc:lExcluido
			MsgInfo("Documento excluido com sucesso!")
		Else
			MsgAlert("Erro ao excluir o documento!")
		EndIf

		// atualizo a grid de informacoes
		FWMsgRun(,{|oSay| ReloadGrid(cContrato, @aBrwDocumentos, @oBrwDocumentos, @oDlgDoc) },'Aguarde...','Atualizando os dados da tela...')

	EndIf

Return(Nil)

/*/{Protheus.doc} VisualizarDocumento
description
@type function
@version 1.0
@author g.sampaio
@since 24/03/2024
@param cContrato, character, param_description
@param cIDDigiDoc, character, param_description
@return variant, return_description
/*/
Static Function VisualizarDocumento(cContrato, cIDDigiDoc)
//cLink := "https://terminaldeinformacao.com"
//ShellExecute("Open", cLink, "", "", 1)
Return(Nil)

/*/{Protheus.doc} ReloadGrid
description
@type function
@version 1.0
@author g.sampaio
@since 24/03/2024
@param cContrato, character, param_description
@param aBrwDocumentos, array, param_description
@param oBrwDocumentos, object, param_description
@param oDlgDoc, object, param_description
@return variant, return_description
/*/
Static Function ReloadGrid( cContrato, aBrwDocumentos, oBrwDocumentos, oDlgDoc )

	Default cContrato 		:= ""
	Default aBrwDocumentos 	:= {}
	Default oBrwDocumentos 	:= Nil
	Default oDlgDoc 		:= Nil

	// Limpo a grid
	oBrwDocumentos 	:= Nil
	aBrwDocumentos	:= {}

	// Atualizo a grid
	ListaDocumentos(cContrato, @aBrwDocumentos, @oBrwDocumentos, @oDlgDoc)

	If oBrwDocumentos <> Nil
		oBrwDocumentos:Refresh()
	EndIf

	If oDlgDoc <> Nil
		oDlgDoc:Refresh()
	EndIf

Return(Nil)

/*/{Protheus.doc} GetContrato
Funcao para retornar informacoes do contrato
@type function
@version 1.0
@author g.sampaio
@since 25/03/2024
@param cContrato, character, codigo do contrato
@param cModulo, character, identificacao do modulo
@return character, retorno das informacoes do contrato
/*/
Static Function GetContrato(cContrato, cModulo)

	Local aArea		As Array
	Local aAreaSA1	As Array
	Local aAreaCTR	As Array
	Local cRetorno	As Character

	Default cContrato 	:= ""
	Default cModulo 	:= ""

	aArea		:= GetArea()
	aAreaSA1	:= SA1->(GetArea())

	If Alltrim(cModulo) == "F"

		aAreaCTR := UF2->(GetArea())
		UF2->(DBSetOrder(1))
		If UF2->(MsSeek(xFilial("UF2")+cContrato))

			SA1->(DBSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1")+UF2->UF2_CLIENT + UF2->UF2_LOJA))
				cRetorno := SA1->A1_NOME
			EndIf

		EndIf

		RestArea(aAreaCTR)

	ElseIf Alltrim(cModulo) == "C"

		aAreaCTR := U00->(GetArea())
		U00->(DBSetOrder(1))
		If U00->(MsSeek(xFilial("U00")+cContrato))

			SA1->(DBSetOrder(1))
			If SA1->(MsSeek(xFilial("SA1")+U00->U00_CLIENT + U00->U00_LOJA))
				cRetorno := SA1->A1_NOME
			EndIf

		EndIf

		RestArea(aAreaCTR)

	EndIf

	RestArea(aAreaSA1)
	RestArea(aArea)

Return(cRetorno)
