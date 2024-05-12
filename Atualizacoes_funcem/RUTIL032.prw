#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTIL032
Rotina de Histórico de Notificações - integração com Zenvia

@type function
@version 1.0
@author danilo brito
@since 15/02/2022
/*/
User Function RUTIL032()
	Local oBrowse	:= {}

	// crio o objeto do Browser
	oBrowse := FWmBrowse():New()

	// defino o Alias
	oBrowse:SetAlias("UZF")

	// informo a descricao
	oBrowse:SetDescription("Histórico de Envio - Notificações (Zenvia)")

	//adiciono legendas
	oBrowse:AddLegend( "UZF_STATUS=='1'", "GREEN" , "Mensagem Enviada" )
	oBrowse:AddLegend( "UZF_STATUS=='2'", "RED"   , "Mensagem não Enviada" )

	// ativo o browser
	oBrowse:Activate()

Return(nIL)

/*/{Protheus.doc} MenuDef
Cria os Menus da Rotina
@type function
@version 1.0
@author danilo brito
@since 15/02/2022
@return array, aRotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Pesquisar'                    Action 'PesqBrw'            OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title "Alterar"    					Action "VIEWDEF.RUTIL032"	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'                   Action 'VIEWDEF.RUTIL032'   OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title "Reenviar"    					Action "U_RUTIL32A()"	    OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title "Excluir"    					Action "VIEWDEF.RUTIL032"	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title "Excluir em Lote"				Action "U_RUTIL32B()"	    OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'                     Action 'VIEWDEF.RUTIL032'   OPERATION 08 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
Cria o Modelo de Dados
@type function
@version 1.0
@author danilo brito
@since 15/02/2022
@return object, oModel
/*/
Static Function ModelDef()
	Local oStruUZF 	:= FWFormStruct( 1, 'UZF', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel	:= NIL

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PUTIL032', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Crio a Enchoice
	oModel:AddFields( 'UZFMASTER', /*cOwner*/, oStruUZF )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ 'UZF_FILIAL' , 'UZF_CODIGO' })

	// Preencho a descricao da entidade
	oModel:GetModel('UZFMASTER'):SetDescription('Histórico de Envio SMS - Zenvia')

Return(oModel)

/*/{Protheus.doc} ViewDef
Cria a camada de Visao
@type function
@version 1.0
@author danilo brito
@since 15/02/2022
@return object, oView
/*/
Static Function ViewDef()
	Local oStruUZF 	:= FWFormStruct( 2, 'UZF', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel 	:= FWLoadModel('RUTIL032')
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	// cria o cabeÃ§alho
	oView:AddField('VIEW_UZF', oStruUZF, 'UZFMASTER')

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_GERAL' , 100)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_UZF' , 'PANEL_GERAL')

	// Ligo a identificacao do componente
	//oView:EnableTitleView('VIEW_UZF')

	// Habilita a quebra dos campos na Vertical
	oView:SetViewProperty( 'UZFMASTER', 'SETLAYOUT', { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

Return(oView)


//-------------------------------------------------------------------
// Função para Reenvio de Mensagens
//-------------------------------------------------------------------
User Function RUTIL32A()

	Local cPerg := "RUTIL32A"

	AjustaSX1(cPerg)

	if Pergunte(cPerg,.T.)

		MsAguarde({|| ReenvSMS() },"Aguarde","Processando Reenvio",.F.)

	endif

Return

//-----------------------------------------------------------
// Processa o reenvio de SMS
//-----------------------------------------------------------
Static Function ReenvSMS()

	Local cQry
	Local aArea := UZF->(GetArea())
	Local nCount := 0
	Private lCancEmu := .F. //flag para cancelar tela do emulador

	cQry := " SELECT "
	cQry += " UZF.R_E_C_N_O_ RECUZF "
	cQry += " FROM  "
	cQry += RetSQLName("UZF") + " UZF (NOLOCK) "
	cQry += " WHERE "
	cQry += " UZF.D_E_L_E_T_ = ' '  "
	cQry += " AND UZF.UZF_FILIAL = '" + xFilial("UZF")+ "'   "
	if MV_PAR01 > 1
		cQry += " AND UZF.UZF_TIPNOT = '" + cValToChar(MV_PAR01 - 1) + "'   "
	endif
	cQry += " AND UZF.UZF_REGRA BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"'  "
	cQry += " AND UZF.UZF_EMISSA BETWEEN '"+DTOS(MV_PAR04)+"' AND '"+DTOS(MV_PAR05)+"'  "
	if MV_PAR06 > 1
		cQry += " AND UZF.UZF_STATUS = '" + cValToChar(MV_PAR06 - 1) + "'   "
	endif

	if Select("QRYREENV") > 0
		QRYREENV->(DbCloseArea())
	endif
	cQry := ChangeQuery(cQry)

	TcQuery cQry NEW Alias "QRYREENV"

	While QRYREENV->(!Eof())
		UZF->(DbGoTo(QRYREENV->RECUZF))

		EnviaSMS()
		nCount++

		QRYREENV->(DbSkip())
	EndDo

	MsgInfo("Foram reenviadas " +cvaltochar(nCount)+ " mensagens!", "Fim")

	RestArea(aArea)

Return

//-----------------------------------------------------------
// Faz o envio do SMS para platafrma Zenvia
//-----------------------------------------------------------
Static Function EnviaSMS()

	Local aArea					:= GetArea()
	Local aAreaUZF				:= UZF->(GetArea())
	Local lRet 					:= .F.
	Local cFrom				    := SuperGetMV("MV_XZENFRO",.F., "") //tbcgestao.smscpaas
	Local cToken				:= SuperGetMV("MV_XZENTOK",.F., "") //n2FD3SA_jzdkpcbonbcdZVpyoVQOHoA1Uqu7
	Local cHost             	:= SuperGetMV("MV_XZENAPI", .F., "https://api.zenvia.com/v2")
	Local cPathSms      	    := "/channels/sms/messages"
	Local lActEmula             := SuperGetMV("MV_XZENEMU",.F.,.F.)
	Local aHeadStr          	:= {}
	Local oRestZenvia      	    := Nil
	Local cJSON
	Local cIdZenvia             := ""
	Local cStatus				:= '2' //nao enviada
	Local cResponse
	Local oResponse         	:= JsonObject():New()
	Local cMsg

	if lActEmula

		lRet := U_RUT031EM("Atencao",UZF->UZF_MSG, UZF->UZF_TEL)
		cIdZenvia := "EMULADOR"
		cResponse := "EMULADOR"
		cStatus := '1'

	else
		//limpo aspas
		cMsg := UZF->UZF_MSG
		cMsg := StrTran(cMsg, "'", "")
		cMsg := StrTran(cMsg, '"', "")
		cMsg := StrTran(cMsg, Chr(13)+chr(10), " ")

		Aadd(aHeadStr, "Content-Type: application/json")
		Aadd(aHeadStr, "X-API-TOKEN: "+cToken)

		cJSON := '{' + ;
			'"from": "'+cFrom+'",' + ;
			'"to": "'+UZF->UZF_TEL+'",' + ;
			'"contents": [{' + ;
			'"type": "text",' + ;
			'"text": "'+cMsg+'"' + ;
			'}]' + ;
			'}'

		oRestZenvia := FWRest():New(cHost)
		oRestZenvia:SetPath(cPathSms)
		oRestZenvia:SetPostParams( cJSON )

		If oRestZenvia:Post( aHeadStr)
			lRet := .T.
			cStatus := '1'
			cResponse := oRestZenvia:GetResult()
			oResponse:fromJson(cResponse)
			cIdZenvia := oResponse["id"]
		else
			cResponse := oRestZenvia:GetResult()
		endIf

		FreeObj(oResponse)
		FreeObj(oRestZenvia)

	endif

	//atualizo o historico
	if !lActEmula .OR. lRet
		If UZF->(RecLock("UZF", .F.))
			UZF->UZF_STATUS := cStatus
			if !empty(cIdZenvia)
				UZF->UZF_DENVIO := Date()
				UZF->UZF_HENVIO := Time()
				UZF->UZF_IDZEN := cIdZenvia
			endif
			UZF->UZF_ERRO   := cResponse
			UZF->(MsUnlock())
		Else
			UZF->(DisarmTransaction())
		EndIf
	endif

	RestArea(aAreaUZF)
	RestArea(aArea)

Return(lRet)

//-------------------------------------------------------------------
// Função para exclusão de mensagens em Lote
//-------------------------------------------------------------------
User Function RUTIL32B()

	Local cPerg := "RUTIL32B"

	AjustaSX1(cPerg)

	if Pergunte(cPerg,.T.)

		MsAguarde({|| ExcluiUZF() },"Aguarde","Processando exclusão",.F.)

	endif

Return

//-----------------------------------------------------------
// Processa o reenvio de SMS
//-----------------------------------------------------------
Static Function ExcluiUZF()

	Local cQry
	Local nCount := 0

	cQry := " SELECT "
	cQry += " UZF.R_E_C_N_O_ RECUZF "
	cQry += " FROM  "
	cQry += RetSQLName("UZF") + " UZF (NOLOCK) "
	cQry += " WHERE "
	cQry += " UZF.D_E_L_E_T_ = ' '  "
	cQry += " AND UZF.UZF_FILIAL = '" + xFilial("UZF")+ "'   "

	if MV_PAR01 > 1
		cQry += " AND UZF.UZF_TIPNOT = '" + cValToChar(MV_PAR01 - 1) + "'   "
	endif

	cQry += " AND UZF.UZF_REGRA BETWEEN '"+MV_PAR02+"' AND '"+MV_PAR03+"'  "
	cQry += " AND UZF.UZF_EMISSA BETWEEN '"+DTOS(MV_PAR04)+"' AND '"+DTOS(MV_PAR05)+"'  "
	cQry += " AND UZF.UZF_STATUS = '2'   "  //apenas nao enviadas

	if Select("QRYREENV") > 0
		QRYREENV->(DbCloseArea())
	endif

	cQry := ChangeQuery(cQry)

	MpSysOpenQuery(cQry, "QRYREENV")

	While QRYREENV->(!Eof())

		UZF->(DbGoTo(QRYREENV->RECUZF))

		If UZF->(RecLock("UZF", .F.))
			UZF->(DbDelete())
			UZF->(MsUnlock())
		Else
			UZF->(DisarmTransaction())
		EndIf

		nCount++

		QRYREENV->(DbSkip())
	EndDo

	If Select("QRYREENV") > 0
		QRYREENV->(DbCloseArea())
	EndIf

	MsgInfo("Foram excluidas " +cvaltochar(nCount)+ " mensagens!", "Fim")

Return(Nil)

//-------------------------------------------------------------------
// Função para montar parambox de pergunta das rotinas Renvio e Exclusao Lote
//-------------------------------------------------------------------
Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relatório

	Local aHelpPor	:= {}
	Local aHelpEng	:= {}
	Local aHelpSpa	:= {}

	U_xPutSX1( cPerg, "01","Tipo Notificação?","Tipo Notificação?","Tipo Notificação?","nTipo","N",1,0,0,"C","","","","","MV_PAR01",'1-Todos',;
		'1-Todos','1-Todos','1-Todos','2-Cadastral','2-Cadastral','2-Cadastral',"3-Contrato","3-Contrato","3-Contrato","4-Financeiro","4-Financeiro","4-Financeiro","5-Serviço","5-Serviço","5-Serviço",aHelpPor,aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg, "02","Regra De?","Regra De?","Regra De?","cRegraDe","C",6,0,0,"G","","UZE","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	U_xPutSX1( cPerg, "03","Regra Ate?","Regra Ate?","Regra Ate?","cRegraAte","C",6,0,0,"G","","UZE","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg, "04","Da Dt.Emissao?","Da Dt.Emissao?","Da Dt.Emissao?","dEmiIni","D",8,0,0,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	U_xPutSX1( cPerg, "05","Até Dt.Emissao?","Até Dt.Emissao?","Até Dt.Emissao?","dEmiFim","D",8,0,0,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	if cPerg == "RUTIL32A"
		U_xPutSX1( cPerg, "06","Status?","Status?","Status?","nStatus","N",1,0,0,"C","","","","","MV_PAR06",'1-Todos',;
			'1-Todos','1-Todos','1-Todos','2-Enviadas','2-Enviadas','2-Enviadas',"3-Não Enviadas","3-Não Enviadas","3-Não Enviadas","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	endif

Return(Nil)

/*/{Protheus.doc} RU032GRV
funcao para gravacao de log zenvia
@type function
@version 1.0
@author g.sampaio
@since 17/03/2024
@param cTel, character, telefone do destinatario
@param cMsg, character, mensagem enviada
@param cIdZenvia, character, id da mensagem enviada
@param cErr, character, erro de envio
@param cStatus, character, status do envio
@param cCliente, character, codigo do cliente
@param cLoja, character, loja do cliente
@param cContrato, character, codigo do contrato
/*/
User Function RU032GRV(cTel, cMsg,cIdZenvia, cErr,cStatus, cCliente, cLoja, cContrato)

	Local aArea 	:= GetArea()
	Local aAreaUZF 	:= UZF->(GetArea())

	Default cErr 		:= ""
	Default cStatus		:= ""
	Default cCliente	:= ""
	Default cLoja		:= ""
	Default cContrato	:= ""

	If UZF->(RecLock("UZF", .T.))
		UZF->UZF_FILIAL := xFilial("UZF")
		UZF->UZF_CODIGO := CriaVar("UZF_CODIGO", .T.)
		UZF->UZF_REGRA  := UZE->UZE_CODIGO
		UZF->UZF_TIPNOT := UZE->UZE_TIPNOT
		UZF->UZF_STATUS := cStatus
		UZF->UZF_TEL    := cTel
		UZF->UZF_MSG    := cMsg
		UZF->UZF_EMISSA := Date()
		UZF->UZF_HREMIS := Time()
		UZF->UZF_DENVIO := Date()
		UZF->UZF_HENVIO := Time()
		if !empty(cIdZenvia)
			UZF->UZF_IDZEN := cIdZenvia
		endif
		UZF->UZF_ERRO   := cErr

		If UZF->(FieldPos("UZF_CONTRA")) > 0
			UZF->UZF_CONTRA := cContrato
		EndIf

		If UZF->(FieldPos("UZF_CLIENT")) > 0
			UZF->UZF_CLIENT := cContrato
		EndIf

		If UZF->(FieldPos("UZF_LOJA")) > 0
			UZF->UZF_LOJA := cContrato
		EndIf

		UZF->(MsUnlock())
	Else
		UZF->(DisarmTransaction())
	EndIf

	RestArea(aAreaUZF)
	RestArea(aArea)

Return(Nil)

