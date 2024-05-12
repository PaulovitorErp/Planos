#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TBICONN.CH"

Static oGetMsg
Static cGetMsg := ""
Static oGridTags
Static aTagsDin := {}
Static aColsTag := {}

/*/{Protheus.doc} RUTIL030
Cadastro de Notificações para integração com Zenvia

@type function
@version 1.0
@author danilo brito
@since 30/12/2021
/*/
User Function RUTIL030()
	Local oBrowse	:= {}

	// crio o objeto do Browser
	oBrowse := FWmBrowse():New()

	// defino o Alias
	oBrowse:SetAlias("UZE")

	// informo a descricao
	oBrowse:SetDescription("Cadastro de Notificações (Zenvia)")

	//adiciono legendas
	oBrowse:AddLegend( "UZE_STATUS!='2' .AND. (empty(UZE_VIGINI) .OR. UZE_VIGINI <= dDataBase) .AND. (empty(UZE_VIGFIN) .OR. UZE_VIGFIN >= dDataBase) ", "GREEN" , "Ativa e Vigente" )
	oBrowse:AddLegend( "UZE_STATUS=='2' .OR. !((empty(UZE_VIGINI) .OR. UZE_VIGINI <= dDataBase) .AND. (empty(UZE_VIGFIN) .OR. UZE_VIGFIN >= dDataBase))", "BLACK" , "Inativo ou não vigente" )

	// ativo o browser
	oBrowse:Activate()

Return(nIL)

/*/{Protheus.doc} MenuDef
Cria os Menus da Rotina
@type function
@version 1.0
@author danilo brito
@since 30/12/2021
@return array, aRotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Pesquisar'                    Action 'PesqBrw'            OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title "Incluir"    					Action "VIEWDEF.RUTIL030"	OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title "Alterar"    					Action "VIEWDEF.RUTIL030"	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title "Excluir"    					Action "VIEWDEF.RUTIL030"	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'                   Action 'VIEWDEF.RUTIL030'   OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'                     Action 'VIEWDEF.RUTIL030'   OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Executar Envio'               Action 'U_RUTIL031()'  		OPERATION 10 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
Cria o Modelo de Dados
@type function
@version 1.0
@author danilo brito
@since 30/12/2021
@return object, oModel
/*/
Static Function ModelDef()
	Local oStruUZE 	:= FWFormStruct( 1, 'UZE', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel	:= NIL

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PUTIL030', /*bPreValidacao*/, {|oMdl| ValidaForm(oMdl) }/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Crio a Enchoice
	oModel:AddFields( 'UZEMASTER', /*cOwner*/, oStruUZE )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ 'UZE_FILIAL' , 'UZE_CODIGO' })

	// Preencho a descricao da entidade
	oModel:GetModel('UZEMASTER'):SetDescription('Cadastro de Notificações')

Return(oModel)

/*/{Protheus.doc} ViewDef
Cria a camada de Visao
@type function
@version 1.0
@author danilo brito
@since 30/12/2021
@return object, oView
/*/
Static Function ViewDef()
	Local oStruUZE 	:= FWFormStruct( 2, 'UZE', {|cCampo| alltrim(cCampo)!="UZE_MSG" }/*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel 	:= FWLoadModel('RUTIL030')
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	// cria o cabeÃ§alho
	oView:AddField('VIEW_UZE', oStruUZE, 'UZEMASTER')

	// monto painel de mensagens
	oView:AddOtherObject('OTHEROBJECT1',{|o| DoPnlMsg(o) },,)

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_GERAL' , 100)

	// Cria Folder na view
	oView:CreateFolder( 'PASTAS', 'PANEL_GERAL')

	oView:AddSheet('PASTAS', 'ABA01', 'Cadastro de Notificações')
	oView:CreateHorizontalBox( 'PANEL_ABA01', 100 ,,,'PASTAS', 'ABA01')
	oView:AddSheet('PASTAS', 'ABA02', 'Mensagem')
	oView:CreateHorizontalBox( 'PANEL_ABA02', 100 ,,,'PASTAS', 'ABA02')

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_UZE' , 'PANEL_ABA01')
	oView:SetOwnerView('OTHEROBJECT1' , 'PANEL_ABA02')

	// Ligo a identificacao do componente
	//oView:EnableTitleView('VIEW_UZE')

	// Habilita a quebra dos campos na Vertical
	oView:SetViewProperty( 'UZEMASTER', 'SETLAYOUT', { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

Return(oView)

//-------------------------------------------------------------------
// Função para montar painel de mensagens
//-------------------------------------------------------------------
Static Function DoPnlMsg(oPnl)

	Local nWidth, nHeight
	Local cObs := ""
	Local cCssTitle := "TSay{ font-size: 14px; font-weight: bold; color: #006078}"
	Local oPnlGrid
	Local aCampos := {"UZE_TAG","UZE_DSTAG"}

	nWidth := oPnl:nWidth/2
	nHeight := oPnl:nHeight/2

	//limpo campos
	cGetMsg := "" 
	if oGetMsg <> NIL
		FREEOBJ(oGetMsg)
		FREEOBJ(oGridTags)
	endif
	oGetMsg := Nil
	oGridTags := Nil

	if empty(aTagsDin)
		aTagsDin := U_RUTIL31A()
	endif

	if INCLUI
		aColsTag := {{"",""}}
	else
		cGetMsg := UZE->UZE_MSG 
		U_RUTIL30B(UZE->UZE_TIPNOT) //carrega acols
	endif

	@ 005, 005 SAY oSay0 PROMPT "Mensagem a enviar" SIZE nWidth-240, 010 OF oPnl COLORS 0, 16777215 PIXEL
	oSay0:SetCss(cCssTitle)
	@ 006, 005 SAY oSay0 PROMPT Replicate("_",nWidth) SIZE nWidth-240, 010 OF oPnl COLORS 0, 16777215 PIXEL
	oSay0:SetCss(cCssTitle)
	@ 020, 005 GET oGetMsg VAR cGetMsg OF oPnl MULTILINE SIZE nWidth-240, 80 COLORS 0, 16777215 PIXEL 
	if !INCLUI .AND. !ALTERA
		oGetMsg:lReadOnly := .T.
	endif

	cObs := "O conteúdo do SMS que será enviado tem limitação em 140 caracteres. Caso utilize as tags dinâmicas, esteja ciente que a mensagem poderá ser truncada caso ultrapasse o limite após as substituições. Se precisar de ajuda para configurar suas notificações, consulte os exemplos de notificações SMS."
	
	@ 005, nWidth-210 SAY oSay1 PROMPT "Atenção" SIZE 180, 010 OF oPnl COLORS 0, 16777215 PIXEL
	oSay1:SetCss(cCssTitle)
	@ 006, nWidth-210 SAY oSay1 PROMPT Replicate("_",180) SIZE 180, 010 OF oPnl COLORS 0, 16777215 PIXEL
	oSay1:SetCss(cCssTitle)
	@ 020, nWidth-210 SAY oSay2 PROMPT cObs SIZE 180, 250 OF oPnl COLORS 0, 16777215 PIXEL
	oSay2:SetCss("TSay{ font-size: 14px; color: #666666; }")


	@ 105, 005 SAY oSay1 PROMPT "Tags Dinâmicas" SIZE nWidth-20, 010 OF oPnl COLORS 0, 16777215 PIXEL
	oSay1:SetCss(cCssTitle)
	@ 106, 005 SAY oSay1 PROMPT Replicate("_",nWidth) SIZE nWidth-20, 010 OF oPnl COLORS 0, 16777215 PIXEL
	oSay1:SetCss(cCssTitle)

	//Grid
	@ 120, 005 MSPANEL oPnlGrid SIZE nWidth-20, nHeight-118 OF oPnl

	oGridTags := FWBrowse():New(oPnlGrid)
	oGridTags:SetDataArray(.T.)
	oGridTags:SetArray(aColsTag)
	oGridTags:DisableConfig()
	oGridTags:DisableReport()
	oGridTags:nRowHeight := 20
	MontaHeader(aCampos, "aColsTag", "oGridTags")
	if INCLUI .OR. ALTERA
		oGridTags:SetDoubleClick( {|| AddTagMsg() } )
	endif
	oGridTags:Activate()

Return

Static Function AddTagMsg()

	Local cTag := aColsTag[oGridTags:nAt][1]
	Local cMsgNew := ""
	
	if empty(cGetMsg)
		cMsgNew := "{{"+cTag+"}}"
	else
		cMsgNew := SubStr(cGetMsg,1,oGetMsg:nPos) + "{{"+cTag+"}}" + SubStr(cGetMsg,oGetMsg:nPos+1)
	endif

	cGetMsg := cMsgNew
	oGetMsg:Refresh()

Return

//-------------------------------------------------------------------
// Função para validar confirmação do cadastro (TudoOK)
//-------------------------------------------------------------------
Static Function ValidaForm(oModel)

	Local lRet     := .T.
	Local aAreaUZE := UZE->(GetArea())
	//Local oModel   := FWModelActive()
	Local nOperation := oModel:GetOperation() //3-inclusao, 4-alteracao, 5-exclusao

	if nOperation == 3 .OR. nOperation == 4
		
		if oModel:GetValue('UZEMASTER', 'UZE_TIPNOT') == "1" //cadastral
			if empty(oModel:GetValue('UZEMASTER', 'UZE_TIPCAD')) //A=Aniversario;M=Mensalmente;D=Data Fixa
				Help( ,, 'Help - MODELPOS',, 'Defina o Tipo de Envio da regra Cadastral', 1, 0 )
				lRet := .F.
			elseif oModel:GetValue('UZEMASTER', 'UZE_TIPCAD') != "D" .AND. empty(oModel:GetValue('UZEMASTER', 'UZE_ENVCAD'))	
				Help( ,, 'Help - MODELPOS',, 'Preencha o campo Envio da regra Cadastral', 1, 0 )
				lRet := .F.
			elseif oModel:GetValue('UZEMASTER', 'UZE_TIPCAD') == "D" .AND. empty(oModel:GetValue('UZEMASTER', 'UZE_DTFIXA'))	
				Help( ,, 'Help - MODELPOS',, 'Preencha o campo Data Fixa da regra Cadastral', 1, 0 )
				lRet := .F.
			elseif oModel:GetValue('UZEMASTER', 'UZE_TIPCAD') == "M" .AND. oModel:GetValue('UZEMASTER', 'UZE_DIACAD') <= 0
				Help( ,, 'Help - MODELPOS',, 'Informe o dia do mes da regra Cadastral Mensal', 1, 0 )
				lRet := .F.
			endif
		elseif oModel:GetValue('UZEMASTER', 'UZE_TIPNOT') == "2" //Contratos
			if empty(oModel:GetValue('UZEMASTER', 'UZE_TIPCON')) //1=Ativacao do Contrato;2=Liberacao do Contrato;3=Cancelamento do Contrato;4=Suspensao do Contrato
				Help( ,, 'Help - MODELPOS',, 'Defina o tipo de envio da regra Contratos', 1, 0 )
				lRet := .F.
			elseif empty(oModel:GetValue('UZEMASTER', 'UZE_ENVCON'))	
				Help( ,, 'Help - MODELPOS',, 'Preencha o campo Envio da regra Contratos', 1, 0 )
				lRet := .F.
			elseif oModel:GetValue('UZEMASTER', 'UZE_ENVCON') == '2' .AND. oModel:GetValue('UZEMASTER', 'UZE_TIPCON') <> '4'
				Help( ,, 'Help - MODELPOS',, 'O Envio 2-Dias Antes só é permitido para o tipo Suspensão de Contrato!', 1, 0 )
				lRet := .F.
			endif
		elseif oModel:GetValue('UZEMASTER', 'UZE_TIPNOT') == "3" //financeiro
			if empty(oModel:GetValue('UZEMASTER', 'UZE_TIPFIN')) //1=Qtd. Pacelas em Atraso;2=Ultima Parcela Vencida;3=Proxima Parcela a Vencer
				Help( ,, 'Help - MODELPOS',, 'Defina o tipo de envio da regra Financeiro', 1, 0 )
				lRet := .F.
			elseif oModel:GetValue('UZEMASTER', 'UZE_TIPFIN') == '1' .AND. empty(oModel:GetValue('UZEMASTER', 'UZE_QPARDE')+oModel:GetValue('UZEMASTER', 'UZE_QPARAT'))
				Help( ,, 'Help - MODELPOS',, 'Preencha os campos Qtd Parcelas em Atraso da regra Financeiro', 1, 0 )
				lRet := .F.
			elseif oModel:GetValue('UZEMASTER', 'UZE_TIPFIN') == '1' .AND. oModel:GetValue('UZEMASTER', 'UZE_QPARDE') > oModel:GetValue('UZEMASTER', 'UZE_QPARAT')
				Help( ,, 'Help - MODELPOS',, 'Campos Qtd Parcelas em Atraso da regra Financeiro inconsistentes!', 1, 0 )
				lRet := .F.
			elseif empty(oModel:GetValue('UZEMASTER', 'UZE_ENVFIN'))	
				Help( ,, 'Help - MODELPOS',, 'Preencha o campo Envio da regra Financeiro', 1, 0 )
				lRet := .F.
			elseif oModel:GetValue('UZEMASTER', 'UZE_TIPFIN') == '2' .AND. oModel:GetValue('UZEMASTER', 'UZE_ENVFIN') == '2'
				Help( ,, 'Help - MODELPOS',, 'Não é permitido Envio Dias Antes para o tipo Ultima Parcela Vencida!', 1, 0 )
				lRet := .F.
			elseif oModel:GetValue('UZEMASTER', 'UZE_TIPFIN') == '3' .AND. oModel:GetValue('UZEMASTER', 'UZE_ENVFIN') == '3'
				Help( ,, 'Help - MODELPOS',, 'Não é permitido Envio Dias Depois para o tipo Proxima Parcela a Vencer!', 1, 0 )
				lRet := .F.
			endif
		elseif oModel:GetValue('UZEMASTER', 'UZE_TIPNOT') == "4" //serviço
			if empty(oModel:GetValue('UZEMASTER', 'UZE_ENVSRV'))
				Help( ,, 'Help - MODELPOS',, 'Preencha o campo Envio da regra Serviços', 1, 0 )
				lRet := .F.
			endif
		endif

		if lRet .AND. Empty(cGetMsg)
			Help( ,, 'Help - MODELPOS',, 'Atenção! Informe uma mensagem para envio.', 1, 0 )
			lRet := .F.
		endif
		if lRet .AND. !ValTagsMsg(cGetMsg)
			Help( ,, 'Help - MODELPOS',, 'Atenção! Há tags inválidas ou desconfiguradas na mensagem.', 1, 0 )
			lRet := .F.
		endif

		//carrego valor para gravação
		oModel:LoadValue('UZEMASTER', 'UZE_MSG', cGetMsg)
		
	endif

	RestArea(aAreaUZE)

Return lRet

Static Function ValTagsMsg(cGetMsg)

	Local lOk := .T.
	Local nPos1 := nPos2 := 1
	Local cTagAt

	while (nPos1 := At("{{",cGetMsg, nPos2) ) > 0
		nPos2 := At("}}",cGetMsg, nPos1)
		if nPos2 > 0
			cTagAt := SubStr(cGetMsg,nPos1+2, (nPos2-nPos1-2))
			if aScan(aColsTag, {|x| x[1] == cTagAt}) == 0 
				lOk := .F.
				EXIT
			endif
		else
			lOk := .F.
			EXIT
		endif
	enddo

Return lOk

//--------------------------------------------------------------------------------------
// Monta aHeader de acordo com campos passados
//--------------------------------------------------------------------------------------
Static Function MontaHeader(aCampos, cDados, cObj, bLDblClick, bHeaderClick)

	Local nX := 0
	Local bLoad

	For nX := 1 to Len(aCampos)
		bLoad := &("{|| "+cDados+"["+cObj+":nAt]["+cValToChar(nX)+"] }")
		if aCampos[nX] == "LEG"
			&(cObj):AddStatusColumns( bLoad , bLDblClick )
		elseif aCampos[nX] == "MARK"
			&(cObj):AddMarkColumns( bLoad, bLDblClick, bHeaderClick )
		else
			AddColumn(aCampos[nX], bLoad, &(cObj))
		endif
	Next nX

Return

//--------------------------------------------------------------------------------------
// Adiciona coluna no fwBrowse
//--------------------------------------------------------------------------------------
Static Function AddColumn(cField, bData, oBrow)

	Local oColumn
	Local cCombo := GetSx3Cache(cField,"X3_CBOX")
	Local aCombo := {}
	Local cPfxTab := SubStr(cField,1,3)

	if Right(cPfxTab,1) == "_"
		cPfxTab := "S"+Left(cPfxTab,2)
	endif

	oColumn := FWBrwColumn():New()
	oColumn:SetType(GetSx3Cache(cField,"X3_TIPO"))
	oColumn:SetData(bData)
	oColumn:SetTitle(FWX3Titulo(cField))
	oColumn:SetSize(GetSx3Cache(cField,"X3_TAMANHO") + GetSx3Cache(cField,"X3_DECIMAL"))
	oColumn:SetPicture(PesqPict(cPfxTab,cField))
	oColumn:SetAlign(If(GetSx3Cache(cField,"X3_TIPO") == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT))

	if !empty(cCombo)
		if SubStr(cCombo,1,1)=="#"
			cCombo := &(SubStr(cCombo,2))
		endif
		aCombo := StrToKArr(cCombo,";")
		oColumn:SetOptions(aCombo)
	endif

	oBrow:SetColumns({oColumn})

Return oColumn


//-------------------------------------------------------------------
/*/{Protheus.doc} RUTIL30A
Consulta Específica para campo UZE_FILCAD
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
User Function RUTIL30A()
	
	Local cFiltroSA1 := ""

	cFiltroSA1 := M->UZE_FILCAD
	cFiltroSA1 := BuildExpr("SA1",,cFiltroSA1,.T.)

Return cFiltroSA1


//-------------------------------------------------------------------
/*/{Protheus.doc} RUTIL30B
Atualiza o grid de tags conforma o tipo de notificacao
Chamado na validacao do campo UZE_TIPNOT
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
User Function RUTIL30B(cTpNot)
	
	Local nX 

	aColsTag := {}

	for nX := 1 to len(aTagsDin)
		if cTpNot $ aTagsDin[nX][4]
			aadd(aColsTag, {aTagsDin[nX][1], aTagsDin[nX][2]} )
		endif
	next nX

	if Empty(aColsTag)
		aColsTag := {{"",""}}
	endif

	if oGridTags <> Nil
		oGridTags:SetArray(aColsTag)
		oGridTags:Refresh()
		oGridTags:GoTop()
	endif

Return .T.

