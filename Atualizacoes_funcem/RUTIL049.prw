#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTIL049
Browse de Agendamentos
@type function
@version 1.0
@author g.sampaio
@since 20/09/2022
/*/
User Function RUTIL049()

	Local oBrowse	:= {}

	// crio o objeto do Browser
	oBrowse := FWmBrowse():New()

	// defino o Alias
	oBrowse:SetAlias("U92")

	// informo a descrição
	oBrowse:SetDescription("Agendamentos")

	// crio as legendas
	oBrowse:AddLegend("U92_STATUS == 'P'", "WHITE"	,	"Pendente")
	oBrowse:AddLegend("U92_STATUS == 'E'", "RED"	,	"Efetivado")
	oBrowse:AddLegend("U92_STATUS == 'C'", "GRAY"	,	"Cancelado")

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

	ADD OPTION aRotina Title 'Pesquisar'   						Action 'PesqBrw'          				OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  						Action 'U_RUTIL49F(2)' 					OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'  						Action 'U_RUTIL49F(3)' 					OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'  						Action 'U_RUTIL49F(4)' 					OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'  						Action 'U_RUTIL49F(5)' 					OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    						Action 'VIEWDEF.RUTIL049' 				OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'     						Action 'U_RUTIL49LEG()' 				OPERATION 10 ACCESS 0
	ADD OPTION aRotina Title 'Efetivar'    						Action 'U_RUTIL49B(U92->U92_CODIGO)'	OPERATION 08 ACCESS 0

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

	Local aArea				:= GetArea()
	Local aAreaU00			:= U00->(GetArea())
	Local cContrato         := ""
	Local cTipoAgendamento  := ""
	Local cCodliente		:= ""
	Local cLojaCli			:= ""
	Local cNomeCli			:= ""
	Local lContinua         := .T.
	Local oModel	        := NIL
	Local oStruU92  	    := FWFormStruct( 1, 'U92', /*bAvalCampo*/, /*lViewUsado*/ )	// abro o parambox

	// abro a classe de parambox
	If INCLUI
		lContinua := U_RUTIL49D()
	EndIf

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PUTIL049', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Crio a Enchoice
	oModel:AddFields( 'U92MASTER', /*cOwner*/, oStruU92 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ 'U92_FILIAL' , 'U92_CODIGO' })

	// Preencho a descrição da entidade
	oModel:GetModel('U92MASTER'):SetDescription('Dados do Agendamento')

	If lContinua

		If INCLUI
			cContrato           := MV_PAR01
			cTipoAgendamento	:= MV_PAR02 // 1=Sepultamento;2=Exumacao;3=Transf.Titularidade;4=Saida de Restos Mortais;5=Entrada de Restos Mortais

			// inicializador padrao
			oStruU92:SetProperty( 'U92_CONTRA' 	, MODEL_FIELD_INIT, {|| cContrato } )

		Else
			cContrato           := U92->U92_CONTRA
			cTipoAgendamento	:= U92->U92_TIPO // 1=Sepultamento;2=Exumacao;3=Transf.Titularidade;4=Saida de Restos Mortais;5=Entrada de Restos Mortais
		EndIf

		U00->(DBSetOrder(1))
		If U00->(MsSeek(xFilial("U00")+cContrato))

			cCodliente 	:= U00->U00_CLIENT
			cLojaCli  	:= U00->U00_LOJA
			cNomeCli  	:= U00->U00_NOMCLI

			oStruU92:SetProperty( 'U92_TIPO' 	, MODEL_FIELD_INIT, FwBuildFeature( 3, cTipoAgendamento) )

			// campo nao editavel
			oStruU92:SetProperty( 'U92_CONTRA' 	, MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") )
			oStruU92:SetProperty( 'U92_TIPO' 	, MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") )

			If cTipoAgendamento == "1" // sepultamento
				oStruU92:SetProperty( 'U92_DESCRI' 	, MODEL_FIELD_INIT, {|| "AGENDAMENTO DE SEPULTAMENTO" } )
				oStruU92:SetProperty( 'U92_NOME' 	, MODEL_FIELD_OBRIGAT, .T.)

			ElseIf cTipoAgendamento == "2" // exumacao
				oStruU92:SetProperty( 'U92_DESCRI' 	, MODEL_FIELD_INIT, {|| "AGENDAMENTO DE EXUMACAO" } )
				oStruU92:SetProperty( 'U92_ITEM' 	, MODEL_FIELD_OBRIGAT, .T.)

			ElseIf cTipoAgendamento == "3" .Or. cTipoAgendamento == "8"// Transf.Titularidade

				If INCLUI
					oStruU92:SetProperty( 'U92_CLIATU' 	, MODEL_FIELD_INIT, {|| cCodliente } )
					oStruU92:SetProperty( 'U92_LOJATU' 	, MODEL_FIELD_INIT, {|| cLojaCli } )
				EndIf

				oStruU92:SetProperty( 'U92_NOMATU' 	, MODEL_FIELD_INIT, {|| cNomeCli  } )

				If cTipoAgendamento == "8"
					oStruU92:SetProperty( 'U92_DESCRI' 	, MODEL_FIELD_INIT, {|| "AGENDAMENTO DE TRANSFERENCIA DE RESPONSAVEL FINANCEIRO" } )
				Else
					oStruU92:SetProperty( 'U92_DESCRI' 	, MODEL_FIELD_INIT, {|| "AGENDAMENTO DE TRANSFERENCIA DE CESSIONARIO" } )
				EndIf

				oStruU92:SetProperty( 'U92_CLIATU' 	, MODEL_FIELD_OBRIGAT, .T.)
				oStruU92:SetProperty( 'U92_LOJATU' 	, MODEL_FIELD_OBRIGAT, .T.)
				oStruU92:SetProperty( 'U92_NMCLIN' 	, MODEL_FIELD_OBRIGAT, .T.)
				oStruU92:SetProperty( 'U92_MOTIVO' 	, MODEL_FIELD_OBRIGAT, .T.)

			ElseIf cTipoAgendamento == "4" // saida de restos mortais
				oStruU92:SetProperty( 'U92_DESCRI' 	, MODEL_FIELD_INIT, {|| "AGENDAMENTO SAIDA DE RESTOS MORTAIS" } )
				oStruU92:SetProperty( 'U92_ITEM' 	, MODEL_FIELD_OBRIGAT, .T.)`
				oStruU92:SetProperty( 'U92_LOCDES' 	, MODEL_FIELD_OBRIGAT, .T.)

			ElseIf cTipoAgendamento == "5" // entrada de restos mortais
				oStruU92:SetProperty( 'U92_DESCRI' 	, MODEL_FIELD_INIT, {|| "AGENDAMENTO ENTRADA DE RESTOS MORTAIS" } )
				oStruU92:SetProperty( 'U92_NOME' 	, MODEL_FIELD_OBRIGAT, .T.)
				oStruU92:SetProperty( 'U92_LOCORI' 	, MODEL_FIELD_OBRIGAT, .T.)

			ElseIf cTipoAgendamento == "6" // cremacao
				oStruU92:SetProperty( 'U92_DESCRI' 	, MODEL_FIELD_INIT, {|| "AGENDAMENTO DE CREMACAO" } )
				oStruU92:SetProperty( 'U92_NOME' 	, MODEL_FIELD_OBRIGAT, .T.)

			ElseIf cTipoAgendamento == "7" // retirada de cinzas
				oStruU92:SetProperty( 'U92_DESCRI' 	, MODEL_FIELD_INIT, {|| "AGENDAMENTO DE RETIRADA DE CINZAS" } )
				oStruU92:SetProperty( 'U92_ITEM' 	, MODEL_FIELD_OBRIGAT, .T.)

			EndIf

		EndIf

	EndIf

	RestArea(aAreaU00)
	RestArea(aArea)

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

	Local cContrato			:= ""
	Local cTipoAgendamento	:= ""
	Local oStruU92 			:= FWFormStruct(2,'U92')
	Local oModel 			:= FWLoadModel('RUTIL049')
	Local oView				:= Nil

	// pego o tipo de agendamento
	If INCLUI
		cContrato 			:= MV_PAR01
		cTipoAgendamento 	:= MV_PAR02
	Else
		cContrato 			:= U92->U92_CONTRA
		cTipoAgendamento 	:= U92->U92_TIPO
	EndIf

	// Cria o objeto de View
	oView := FWFormView():New()

	// trato a tela a ser exibida para o usuario
	If cTipoAgendamento == "1" // sepultamento

		oStruU92:RemoveField('U92_ITEM')
		oStruU92:RemoveField('U92_OSSUAR')
		oStruU92:RemoveField('U92_NICHOO')
		oStruU92:RemoveField('U92_CREMAT')
		oStruU92:RemoveField('U92_NICHOC')
		oStruU92:RemoveField('U92_LOCORI')
		oStruU92:RemoveField('U92_LOCDES')
		oStruU92:RemoveField('U92_CLIATU')
		oStruU92:RemoveField('U92_LOJATU')
		oStruU92:RemoveField('U92_CLINOV')
		oStruU92:RemoveField('U92_LOJNOV')
		oStruU92:RemoveField('U92_LOJNOV')
		oStruU92:RemoveField('U92_MOTIVO')
		oStruU92:RemoveField('U92_NMCLIN')
		oStruU92:RemoveField('U92_NOMATU')
		oStruU92:RemoveField('U92_DTSERV')
		oStruU92:RemoveField('U92_DTUTIL')
		oStruU92:RemoveField('U92_PRZEXU')
		oStruU92:RemoveField('U92_TAXA')

		oStruU92:SetProperty( 'U92_SERVIC' 	, MVC_VIEW_LOOKUP, "U37SEP")

	ElseIf cTipoAgendamento == "2" // exumacao

		oStruU92:RemoveField('U92_OSSUAR')
		oStruU92:RemoveField('U92_NICHOO')
		oStruU92:RemoveField('U92_CREMAT')
		oStruU92:RemoveField('U92_NICHOC')
		oStruU92:RemoveField('U92_LOCORI')
		oStruU92:RemoveField('U92_LOCDES')
		oStruU92:RemoveField('U92_CLIATU')
		oStruU92:RemoveField('U92_LOJATU')
		oStruU92:RemoveField('U92_CLINOV')
		oStruU92:RemoveField('U92_LOJNOV')
		oStruU92:RemoveField('U92_LOJNOV')
		oStruU92:RemoveField('U92_MOTIVO')
		oStruU92:RemoveField('U92_NMCLIN')
		oStruU92:RemoveField('U92_NOMATU')
		oStruU92:RemoveField('U92_TAXA')

		oStruU92:SetProperty( 'U92_SERVIC' 	, MVC_VIEW_LOOKUP, "U37EXU")

	ElseIf cTipoAgendamento == "3" .Or. cTipoAgendamento == "8" // transferencia de titularidade

		oStruU92:RemoveField('U92_ITEM')
		oStruU92:RemoveField('U92_NOME')
		oStruU92:RemoveField('U92_QUADRA')
		oStruU92:RemoveField('U92_MODULO')
		oStruU92:RemoveField('U92_JAZIGO')
		oStruU92:RemoveField('U92_GAVETA')
		oStruU92:RemoveField('U92_OSSUAR')
		oStruU92:RemoveField('U92_NICHOO')
		oStruU92:RemoveField('U92_CREMAT')
		oStruU92:RemoveField('U92_NICHOC')
		oStruU92:RemoveField('U92_LOCORI')
		oStruU92:RemoveField('U92_LOCDES')
		oStruU92:RemoveField('U92_DTSERV')
		oStruU92:RemoveField('U92_DTUTIL')
		oStruU92:RemoveField('U92_PRZEXU')
		oStruU92:RemoveField('U92_SERVIC')

	ElseIf cTipoAgendamento == "4" // saida de restos mortais

		oStruU92:RemoveField('U92_CREMAT')
		oStruU92:RemoveField('U92_NICHOC')
		oStruU92:RemoveField('U92_LOCORI')
		oStruU92:RemoveField('U92_CLIATU')
		oStruU92:RemoveField('U92_LOJATU')
		oStruU92:RemoveField('U92_CLINOV')
		oStruU92:RemoveField('U92_LOJNOV')
		oStruU92:RemoveField('U92_MOTIVO')
		oStruU92:RemoveField('U92_NMCLIN')
		oStruU92:RemoveField('U92_NOMATU')
		oStruU92:RemoveField('U92_SERVIC')
		oStruU92:RemoveField('U92_TAXA')

	ElseIf cTipoAgendamento == "5" // entrada de restos mortais

		oStruU92:RemoveField('U92_ITEM')
		oStruU92:RemoveField('U92_CREMAT')
		oStruU92:RemoveField('U92_NICHOC')
		oStruU92:RemoveField('U92_LOCORI')
		oStruU92:RemoveField('U92_CLIATU')
		oStruU92:RemoveField('U92_LOJATU')
		oStruU92:RemoveField('U92_CLINOV')
		oStruU92:RemoveField('U92_LOJNOV')
		oStruU92:RemoveField('U92_MOTIVO')
		oStruU92:RemoveField('U92_NMCLIN')
		oStruU92:RemoveField('U92_DTSERV')
		oStruU92:RemoveField('U92_DTUTIL')
		oStruU92:RemoveField('U92_PRZEXU')
		oStruU92:RemoveField('U92_NOMATU')
		oStruU92:RemoveField('U92_TAXA')

		oStruU92:SetProperty( 'U92_SERVIC'	, MVC_VIEW_LOOKUP, 'U37EXU')

	ElseIf cTipoAgendamento == "6" // cremacao

		oStruU92:RemoveField('U92_ITEM')
		oStruU92:RemoveField('U92_OSSUAR')
		oStruU92:RemoveField('U92_NICHOO')
		oStruU92:RemoveField('U92_QUADRA')
		oStruU92:RemoveField('U92_MODULO')
		oStruU92:RemoveField('U92_JAZIGO')
		oStruU92:RemoveField('U92_GAVETA')
		oStruU92:RemoveField('U92_LOCORI')
		oStruU92:RemoveField('U92_LOCDES')
		oStruU92:RemoveField('U92_CLIATU')
		oStruU92:RemoveField('U92_LOJATU')
		oStruU92:RemoveField('U92_CLINOV')
		oStruU92:RemoveField('U92_LOJNOV')
		oStruU92:RemoveField('U92_LOJNOV')
		oStruU92:RemoveField('U92_MOTIVO')
		oStruU92:RemoveField('U92_NMCLIN')
		oStruU92:RemoveField('U92_DTSERV')
		oStruU92:RemoveField('U92_DTUTIL')
		oStruU92:RemoveField('U92_PRZEXU')
		oStruU92:RemoveField('U92_NOMATU')
		oStruU92:RemoveField('U92_TAXA')

		oStruU92:SetProperty( 'U92_SERVIC'	, MVC_VIEW_LOOKUP, 'U37CRM')

	ElseIf cTipoAgendamento == "7" // retirada de cinzas

		oStruU92:RemoveField('U92_OSSUAR')
		oStruU92:RemoveField('U92_NICHOO')
		oStruU92:RemoveField('U92_QUADRA')
		oStruU92:RemoveField('U92_MODULO')
		oStruU92:RemoveField('U92_JAZIGO')
		oStruU92:RemoveField('U92_GAVETA')
		oStruU92:RemoveField('U92_LOCORI')
		oStruU92:RemoveField('U92_LOCDES')
		oStruU92:RemoveField('U92_CLIATU')
		oStruU92:RemoveField('U92_LOJATU')
		oStruU92:RemoveField('U92_CLINOV')
		oStruU92:RemoveField('U92_LOJNOV')
		oStruU92:RemoveField('U92_MOTIVO')
		oStruU92:RemoveField('U92_NMCLIN')
		oStruU92:RemoveField('U92_NOMATU')
		oStruU92:RemoveField('U92_SERVIC')
		oStruU92:RemoveField('U92_TAXA')

	EndIf

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	// cria o cabeçalho
	oView:AddField('VIEW_U92', oStruU92, 'U92MASTER')

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox("PAINEL_STATUS", 8)
	oView:CreateHorizontalBox('PANEL_CABECALHO' , 92)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_U92' , 'PANEL_CABECALHO')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_U92')

	// Habilita a quebra dos campos na Vertical
	oView:SetViewProperty( 'U92MASTER', 'SETLAYOUT', { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

	// Cria componentes nao MVC
	oView:AddOtherObject("STATUS", {|oPanel| UTIL49P(oPanel)})
	oView:SetOwnerView("STATUS",'PAINEL_STATUS')

Return(oView)

/*/{Protheus.doc} RUTIL49A
Funcao para montar os tipos de agendamento
@type function
@version 1.0
@author g.sampaio
@since 01/01/2024
@return character, retorno das opcoes
/*/
User Function RUTIL49A()

	Local cRetorno	:= ""

	cRetorno := "1=Sepultamento;"
	cRetorno += "2=Exumacao;"
	cRetorno += "3=Transf. Cessionario;"
	cRetorno += "4=Saida de Restos Mortais;"
	cRetorno += "5=Entrada de Restos Mortais;"
	cRetorno += "6=Cremacao;"
	cRetorno += "7=Retirada de Cinzas;"
	cRetorno += "8=Transf. Resp. Financeiro;"

Return(cRetorno)

/*/{Protheus.doc} UTIL49P
Funcao para descrever o tipo de agendamento
@type function
@version 1.0
@author g.sampaio
@since 31/12/2023
@param oPanel, object, painel de status
/*/
Static Function UTIL49P(oPanel)

	Local cTipoAgendamento	:= ""
	Local oSay1				:= Nil
	Local oSay2				:= Nil
	Local oModel			:= FWModelActive()
	Local oModelU92 		:= oModel:GetModel("U92MASTER")
	Local oFont20N			:= TFONT():New("Arial",,20,,.T.,,,,.T.,.F.) 	///Fonte 20 Negrito

	// pego o tipo de agendamento
	cTipoAgendamento := U_USX3CBOX("U92_TIPO", oModelU92:GetValue("U92_TIPO") )

	@005,((oPanel:nClientWidth/2)/2) - 60 SAY oSay1 PROMPT "Agendamento de " + cTipoAgendamento SIZE 200, 010 OF oPanel FONT oFont20N COLORS CLR_GREEN,16777215 PIXEL CENTER

	//Linha horizontal
	@010,005 SAY oSay2 PROMPT Repl("_",(oPanel:nClientWidth/2) - 5) SIZE (oPanel:nClientWidth/2) - 5, 007 OF oPanel COLORS CLR_GRAY, 16777215 PIXEL

Return(Nil)

/*/{Protheus.doc} RUTIL49D
Funcao para construir o parambox
@type function
@version 1.0
@author g.sampaio
@since 31/12/2023
/*/
User Function RUTIL49D()

	Local aPergs 		:= {}
	Local aX3Cbox       := {}
	Local aMvPar		:= {}
	Local cX3Cbox       := ""
	Local cContrato     := Space(TamSX3("U00_CODIGO")[1])
	Local lRetorno		:= .F.
	Local nMV			:= 0

	// pego o conteudo do campo X3_CBOX do campo UF4_TIPO
	cX3Cbox := U_RUTIL49A()

	// alimento o array de dados
	aX3Cbox	:= StrToKarr( cX3Cbox, ";" )

	aAdd(aPergs, {1, "Contrato",  cContrato,  "", ".T.", "U00", ".T.", 10,  .T.})
	aAdd(aPergs, {2, "Tipo Agendamento", 1, aX3Cbox, 90, ".T.", .T.})

	If ParamBox(aPergs,"Dados para Agendamento", /*aRet*/, {|| .T.}, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, "RUTIL049", .T., .T.)
		lRetorno := .T.

		// tratamento de problema de compatibilidade da funcao PARAMBOX
		// onde o primeiro item vem como numerico quando o tipo e combo (2)
		If ValType(MV_PAR02) == "N"
			MV_PAR02 := cValToChar(MV_PAR02)
		EndIf

		For nMV := 1 To 40
			aAdd( aMvPar, &( "MV_PAR" + StrZero( nMv, 2, 0 ) ) )
		Next nMV

		For nMv := 1 To Len( aMvPar )
			&( "MV_PAR" + StrZero( nMv, 2, 0 ) ) := aMvPar[ nMv ]
		Next nMv

	endif

Return(lRetorno)

/*/{Protheus.doc} RUTIL49LEG
Funcao para exibir as legendas
@type function
@version 1.0
@author g.sampaio
@since 07/04/2024
/*/
User Function RUTIL49LEG()

	BrwLegenda("Status do Agendamento","Legenda",{;
		{"BR_BRANCO","Pendente"},;
		{"BR_VERMELHO","Efetivado"},;
		{"BR_CINZA","Cancelado"}})

Return(Nil)

/*/{Protheus.doc} RUTIL49B
description
@type function
@version 1.0
@author g.sampaio
@since 07/04/2024
@return variant, return_description
/*/
User Function RUTIL49B(cAgendamento)

	Local aArea  			:= GetArea()
	Local aAreaU92			:= U92->(GetArea())
	Local aAreaU00			:= U00->(GetArea())
	Local aStatus			:= {}
	Local cObservacoes		:= ""
	Local cCSSGet			:= ""
	Local cBlueCSSButton	:= ""
	Local cGrayCSSButton	:= ""
	Local cGetHora 			:= Time()
	Local cGetUsuario 		:= UsrRetName(RetCodUsr())
	Local dGetData 			:= dDatabase
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
	Local oSayTipo			:= Nil
	Local oSayUsuario		:= Nil
	Local oSayData			:= Nil
	Local oSayHora			:= Nil
	Local oSayStatus		:= Nil
	Local oDlgExec			:= Nil
	Local oSayTAge			:= Nil
	Local oButtonVirtus		:= VirtusEstiloCSS():New() // inicio a classe de butoes virtus

	Default cAgendamento := ""

	// atribui o estilo dos botoes
	cBlueCSSButton		:= oButtonVirtus:CSSButtonBlue()
	cGrayCSSButton		:= oButtonVirtus:CSSButtonGray()
	cCSSGet				:= oButtonVirtus:CSSGet(Nil, 6)

	U92->(DBSetOrder(1))
	If U92->(MsSeek(xFilial("U92")+cAgendamento)) .And. U92->U92_STATUS == "P"

		U00->(DBSetOrder(1))
		If U00->(MsSeek(xFilial("U00")+U92->U92_CONTRA))

			aStatus 			:= {"Efetivar"}
			cTipoAgendamento 	:= U_USX3CBOX("U92_TIPO", U92->U92_TIPO )

			DEFINE MSDIALOG oDlgExec TITLE "Efetivar Agendamento - " + cTipoAgendamento FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL

			@ 003, 004 GROUP oGroup1 TO 040, 300 PROMPT "Dados Solicitação" OF oDlgExec COLOR 0, 16777215 PIXEL

			@ 010, 010 SAY oSayUsuario PROMPT "Usuário" SIZE 025, 007 OF oDlgExec COLORS 0, 16777215 PIXEL
			@ 020, 010 MSGET oGetUsuario VAR cGetUsuario WHEN .F. SIZE 120, 010 OF oDlgExec COLORS 0, 16777215 PIXEL HASBUTTON

			@ 010, 160 SAY oSayData PROMPT "Data" SIZE 025, 007 OF oDlgExec COLORS 0, 16777215 PIXEL
			@ 020, 160 MSGET oGetData VAR dGetData WHEN .F.  SIZE 060, 010 OF oDlgExec COLORS 0, 16777215 PIXEL HASBUTTON

			@ 010, 240 SAY oSayHora PROMPT "Hora" SIZE 025, 007 OF oDlgExec COLORS 0, 16777215 PIXEL
			@ 020, 240 MSGET oGetHora VAR cGetHora WHEN .F.  SIZE 040, 010 OF oDlgExec COLORS 0, 16777215 PIXEL HASBUTTON

			@ 045, 004 GROUP oGroup2 TO 160, 300 PROMPT "Observacoes" OF oDlgExec COLOR 0, 16777215 PIXEL

			@ 055, 010 SAY oSayTipo PROMPT "Tipo" SIZE 025, 007 OF oDlgExec COLORS 0, 16777215 PIXEL
			@ 055, 030 SAY oSayTAge PROMPT cTipoAgendamento SIZE 120, 010 OF oDlgExec COLORS 0, 16777215 PIXEL

			@ 055, 180 SAY oSayStatus PROMPT "Status" SIZE 025, 007 OF oDlgExec COLORS 0, 16777215 PIXEL
			@ 053, 220 MSCOMBOBOX oCmbStatus VAR nCmbStatus ITEMS aStatus WHEN .F. SIZE 066, 010 OF oDlgExec COLORS 0, 16777215 PIXEL

			@ 068, 010 Get oMemo Var cObservacoes Memo Size 285, 080 Of oDlgExec Pixel
			oMemo:bRClicked := { || AllwaysTrue() }

			@ 165, 004 GROUP oGroup3 TO 195, 300 OF oDlgExec COLOR 0, 16777215 PIXEL

			@ 175, 195 BUTTON oBtnFechar PROMPT "Fechar" SIZE 037, 012 OF oDlgExec PIXEL ACTION oDlgExec:End()
			@ 175, 245 BUTTON oBtnConfirmar PROMPT "Confirmar" SIZE 037, 012 OF oDlgExec PIXEL ACTION ;
				Confirmar( U92->U92_TIPO, cGetUsuario, dGetData, cGetHora, cObservacoes, @oDlgExec )

			cCSSTipo := "TSay{ font-size: 14px; font-weight: bold; color: #006078}"

			oSayTAge:SetCSS(cCSSTipo)
			oBtnConfirmar:SetCSS(cBlueCSSButton)
			oBtnFechar:SetCSS(cGrayCSSButton)
			oGetUsuario:SetCSS(cCSSGet)
			oGetData:SetCSS(cCSSGet)
			oGetHora:SetCSS(cCSSGet)
			oCmbStatus:SetCSS(cCSSGet)
			oMemo:SetCSS(cCSSGet)

			ACTIVATE MSDIALOG oDlgExec CENTERED

		EndIf

	ElseIf U94->U94_STATUS == "E"
		MsgAlert("Solicitação já Efetivada!")

	ElseIf U94->U94_STATUS == "C"
		MsgAlert("Solicitação está cancelada!")

	Else
		MsgStop("Solicitação não encontrada.")

	EndIf

	RestArea(aAreaU00)
	RestArea(aAreaU92)
	RestArea(aArea)

Return(Nil)

Static Function Confirmar(cTipoAgend, cGetUsuario, dGetData, cGetHora, cObservacoes, oDlgExec)

	Local cNovaObservacao 	:= ""
	Local cRotinaAtual		:= FunName()
	Local lContinua 		:= .T.

	Default cGetUsuario 	:= UsrRetName(RetCodUsr())
	Default dGetData 		:= dDatabase
	Default cGetHora 		:= Time()
	Default cObservacoes 	:= ""
	Default nStatus 		:= 0
	Default oDlgExec		:= Nil

	If cTipoAgend == "1" .Or. cTipoAgend == "5" .Or. cTipoAgend == "6"// sepultamento ou entrada de restos mortais ou cremacao

		INCLUI := .T.
		ALTERA := .F.

		// valido se devo continuar a executar a rotina
		If lContinua

			SetFunName("RCPGA039")
			FWExecView('INCLUIR',"RCPGA039",3,,{|| .T. })
			SetFunName(cRotinaAtual) //retorno a funcao em execucao

		EndIf

	ElseIf cTipoAgend == "2" .Or. cTipoAgend == "4" // exumacao ou saida de restos mortais

		if lContinua

			INCLUI := .T.
			ALTERA := .F.

			// Altero o nome da rotina para considerar o menu deste MVC
			SetFunName("RCPGA034")
			FWExecView('INCLUIR','RCPGA034',3,,{|| .T. })
			SetFunName(cRotinaAtual) //retorno a funcao em execucao

		endIf

	ElseIf cTipoAgend == "3" .Or. cTipoAgend == "8" // transferencia de titularidade ou transferencia de responsavel financeiro

		If Empty(U92->U92_CLINOV)

			If MsgYesNo("O novo cliente [" + AllTrim(U92->U92_NMCLIN);
					+ "] não tem cadastro de cliente. Deseja cadastrar?")

				FWMsgRun(,{|oSay| U_CPGA001X(3)},'Aguarde...','Abrindo o Cadstro de Clietnes...')

			EndIF

		EndIf

		If lContinua

			If cTipoAgend == "3" // cessionario

				If U92->U92_CLINOV == U00->U00_CLICES .And. U92->U92_LOJNOV == U00->U00_LOJCLI
					MsgStop("O novo Cessionario não pode ser o mesmo do Cessionario Atual.")
					lContinua := .F.
				EndIf

				If lContinua
					FWMsgRun(,{|oSay| lContinua := U_RCPGE048( U92->U92_CONTRA, "C" )},'Aguarde...','Abrindo a transferencia de Cessionario...')
				EndIf

			ElseIf cTipoAgend == "8" // responsavel financeiro

				If U92->U92_CLINOV == U00->U00_CLIENT .And. U92->U92_LOJNOV == U00->U00_LOJA
					MsgStop("O novo Responsavel Financeiro não pode ser o mesmo do Responsavel Financeiro Atual.")
					lContinua := .F.
				EndIf

				If lContinua
					FWMsgRun(,{|oSay| lContinua := U_RCPGE048( U92->U92_CONTRA, "R" )},'Aguarde...','Abrindo a transferencia de Responsavel Fincanceiro...')
				EndIf

			EndIf

		EndIf

	ElseIf cTipoAgend == "7" // retirada de cinzas

	EndIf

	If lContinua

		// pego a observacao atual
		cNovaObservacao := U92->U92_OBSEXE + CRLF + CRLF

		// nova observacao
		cNovaObservacao += "[EFETIVADA - "+cGetUsuario+" - "+ DtoC(dGetData) +" - "+cGetHora+"]" + CRLF

		// Verifico se o campo de observacoes esta preenchido
		If !Empty(cObservacoes)
			cNovaObservacao += cObservacoes + CRLF
		EndIf

		BEGIN TRANSACTION

			// Atualizo os campos
			If U92->(Reclock("U92", .F.))
				U92->U92_STATUS	:= "E"
				U92->U92_USRFIN	:= cGetUsuario
				U92->U92_DTFINA	:= dGetData
				U92->U92_HRFINA	:= cGetHora
				U92->U92_OBSEXE	:= cNovaObservacao
				U92->(MsUnlock())
			Else
				U92->(DisarmTransaction())
				BREAK
			EndIf

		END TRANSACTION

		// Atualizo a tela
		oDlgExec:End()
		MsgInfo("Agendamento efetivado com Sucesso.")

	Else
		// Atualizo a tela
		oDlgExec:End()
		MsgAlert("Não foi possível efetivar o agendamento.")

	EndIf

Return(Nil)

/*/{Protheus.doc} RUTIL49N
Funcao para retornar o nome do cliente atual
@type function
@version 1.0
@author g.sampaio
@since 06/04/2024
@return character, nome do cliente
/*/
User Function RUTIL49N()

	Local aArea		:= GetArea()
	Local aAreaSA1	:= SA1->(GetArea())
	Local cRetorno	:= ""
	Local oModel	:= FWModelActive()
	Local oModelU92 := oModel:GetModel("U92MASTER")

	SA1->(DBSetOrder(1))
	If SA1->(MsSeek(xFilial("SA1")+oModelU92:GetValue("U92_CLIATU")+oModelU92:GetValue("U92_LOJATU")))
		cRetorno := SA1->SA1_NOME
	EndIf

	RestArea(aAreaSA1)
	RestArea(aArea)

Return(cRetorno)

/*/{Protheus.doc} RUTIL49F
Funcao para realizar a inclusao/visualizar/exclusao/alteracao
Executo via execview para recarregar a tela
e o ViewDef e ModelDef para carregar os dados
@type function
@version 1.0
@author g.sampaio
@since 07/04/2024
/*/
User Function RUTIL49F(nOperacao, cContrato)

	Local aArea			:= GetArea()
	Local aAreaU00		:= U00->(GetArea())
	Local cRotinaAtual 	:= FunName()
	Local lContinua		:= .T.

	If FWIsInCallStack("U_RCPGA001")
		If !Empty(cContrato)
			U00->(DBSetOrder(1))
			U00->(MsSeek(xFilial("U00")+cContrato))
			If .Not. U00->(Found())
				lContinua := .F.
				MsgAlert("Contrato nao encontrado!")
			EndIf
		EndIf
	EndIf

	If lContinua

		SetFunName("RUTIL049")

		If nOperacao == 2
			FWExecView("VISUALIZAR","RUTIL049",nOperacao,,{|| .T. })
		ElseIf nOperacao == 3
			FWExecView("INCLUIR","RUTIL049",nOperacao,,{|| .T. })
		ElseIf nOperacao == 4
			FWExecView("ALTERAR","RUTIL049",nOperacao,,{|| .T. })
		ElseIf nOperacao == 5
			FWExecView("EXCLUIR","RUTIL049",nOperacao,,{|| .T. })
		Else
			MsgAlert("Opcao invalida [" + cValToChar(nOperacao) + "]")
		EndIf

		SetFunName(cRotinaAtual)

	EndIf

	RestArea(aAreaU00)
	RestArea(aArea)

Return(Nil)

User Function RUTIL49H(cCodContrato)

	Local aArea  			:= GetArea()
	Local aAreaU00			:= U00->(GetArea())
	Local aWBAgendamentos 	:= {}
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
	Local oWBAgendamentos	:= Nil
	Local oDlgAgend			:= Nil
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

		DEFINE MSDIALOG oDlgAgend TITLE "Solicitações em Aberto" FROM 000, 000  TO 500, 1000 COLORS 0, 16777215 PIXEL

		@ 003, 003 GROUP oGroup1 TO 038, 498 PROMPT "Dados" OF oDlgAgend COLOR 0, 16777215 PIXEL

		@ 010, 015 SAY oSayContrato PROMPT "Contrato" SIZE 025, 007 OF oDlgAgend COLORS 0, 16777215 PIXEL
		@ 020, 015 MSGET oGetContrato VAR cCodContrato WHEN .F. SIZE 060, 010 OF oDlgAgend COLORS 0, 16777215 PIXEL

		@ 010, 090 SAY oSayCessionario PROMPT "Cessionario" SIZE 034, 007 OF oDlgAgend COLORS 0, 16777215 PIXEL
		@ 020, 090 MSGET oGetCessionario VAR cCessionario WHEN .F. SIZE 190, 010 OF oDlgAgend COLORS 0, 16777215 PIXEL

		@ 040, 003 GROUP oGroup3 TO 218, 498 PROMPT "Solicitações" OF oDlgAgend COLOR 0, 16777215 PIXEL
		FWBAgendamentos(cCodContrato, @aWBAgendamentos, @oWBAgendamentos, @oDlgAgend)

		@ 220, 003 GROUP oGroup2 TO 248, 498 OF oDlgAgend COLOR 0, 16777215 PIXEL

		@ 228, 010 BUTTON oBtnIncluir PROMPT "Incluir" SIZE 037, 012 OF oDlgAgend PIXEL ;
			ACTION FWMsgRun(,{|oSay| IncSolic(cCodContrato, @aWBAgendamentos, @oWBAgendamentos, @oDlgAgend)},;
			'Aguarde...', 'Incluindo uma nova solicitação...')

		@ 228, 400 BUTTON oBtnFechar PROMPT "Fechar" SIZE 037, 012 OF oDlgAgend PIXEL ACTION oDlgAgend:End()

		@ 228, 450 BUTTON oBtnExecutar PROMPT "Executar" SIZE 037, 012 OF oDlgAgend PIXEL ;
			ACTION FWMsgRun(,{|oSay| ExecSolic(aWBAgendamentos[oWBAgendamentos:nAt,2], cCodContrato, @aWBAgendamentos,;
			@oWBAgendamentos, @oDlgAgend)}, 'Aguarde...', 'Executando solicitação...')

		// atribui o estilo dos botoes
		oBtnIncluir:SetCSS(cGreenCSSButton)
		oBtnExecutar:SetCSS(cBlueCSSButton)
		oBtnFechar:SetCSS(cGrayCSSButton)
		oGetContrato:SetCSS(cCSSGet)
		oGetCessionario:SetCSS(cCSSGet)

		ACTIVATE MSDIALOG oDlgAgend CENTERED

	EndIf

	RestArea(aAreaU00)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} RUTIL49S
Funcao para retornar os dados da U02 na tela
Gatilho do campo U92_AUTORI
@type function
@version 1.0
@author g.sampaio
@since 07/04/2024
@param cCampo, character, campo da tabela U02
@return character, conteudo do campo
/*/
User Function RUTIL49S(cCampo)

	Local cRetorno 		:= ""
	Local cQuery		:= ""
	Local cCodContrato	:= ""
	Local cAutorizado	:= ""
	Local oModel		:= FWModelActive()
	Local oModelU92		:= oModel:GetModel("U92MASTER")

	// pego o codigo do contrto
	cCodContrato 	:= oModelU92:GetValue("U92_CONTRA")
	cAutorizado		:= oModelU92:GetValue("U92_AUTORI")

	cQuery := " SELECT U02."+cCampo+" AS RETORNO FROM " + RetSQLName("U02") + " U02 "
	cQuery += " WHERE U02.D_E_L_E_T_ = ' ' "
	cQuery += " AND U02.U02_FILIAL = '" + xFilial("U02") + "'"
	cQuery += " AND U02.U02_CODIGO = '" + cCodContrato + "'"
	cQuery += " AND U02.U02_ITEM = '" + cAutorizado + "'"

	cQuery := ChangeQuery(cQuery)

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TRBU02' )

	If TRBU02->(!Eof())
		cRetorno := TRBU02->RETORNO
	EndIf

Return(cRetorno)

/*/{Protheus.doc} RUTIL49M
Funcao para validar o modo de edicao
do campo U92_AUTORI
@type function
@version 1.0
@author g.sampaio
@since 07/04/2024
@return logical, retorno da validacao
/*/
User Function RUTIL49M()

	Local lRetorno := .T.
	Local oModel	:= FWModelActive()
	Local oModelU92 := oModel:GetModel("U92MASTER")

	If Empty(oModelU92:GetValue("U92_AUTORI")) .And. !Empty(oModelU92:GetValue("U92_SOLICI"))
		lRetorno := .F.
	EndIf

Return(lRetorno)

/*/{Protheus.doc} RUTIL49E
Funcao para validar o campo de e-mail
Validacao do campo (U92_EMAIL)
@type function
@version 1.0
@author g.sampaio
@since 07/04/2024
@return logical, retorno da validacao
/*/
User Function RUTIL49E()

	Local lRetorno := .T.
	Local oModel	:= FWModelActive()
	Local oModelU92 := oModel:GetModel("U92MASTER")

	If .Not. "@" $ oModelU92:GetValue("U92_EMAIL")
		lRetorno := .F.
		Help(,,'Help',,"Digite um e-mail válido!",1,0)
	EndIf

Return(lRetorno)

/*/{Protheus.doc} RUTIL49T
Valido se foi digitado um telefone valido
Validacao do campo (U92_TELEFO)
@type function
@version 1.0
@author g.sampaio
@since 07/04/2024
@return logical, retorno da validacao
/*/
User Function RUTIL49T()

	Local lRetorno := .T.
	Local oModel	:= FWModelActive()
	Local oModelU92 := oModel:GetModel("U92MASTER")

	If Len(AllTrim(oModelU92:GetValue("U92_TELEFO"))) < 8
		lRetorno := .F.
		Help(,,'Help',,"Digite um telefone válido!",1,0)
	EndIf

Return(lRetorno)

/*/{Protheus.doc} RUTIL49C
Modo de edicao dos campos
U92_NMCLIN
@type function
@version 1.0
@author g.sampaio
@since 07/04/2024
@return logical, retorno da validacao
/*/
User Function RUTIL49C()

	Local lRetorno := .T.
	Local oModel	:= FWModelActive()
	Local oModelU92 := oModel:GetModel("U92MASTER")

	If !Empty(oModelU92:GetValue("U92_CLINOV")) .Or. !Empty(oModelU92:GetValue("U92_LOJNOV"))
		lRetorno := .F.
	EndIf

Return(lRetorno)

/*/{Protheus.doc} RUTIL49K
Modo de edicao dos campos 
U92_CLINOV e U92_LOJNOV
@type function
@version 1.0
@author g.sampaio
@since 07/04/2024
@return logical, retorno da validacao
/*/
User Function RUTIL49K()

	Local lRetorno := .T.
	Local oModel	:= FWModelActive()
	Local oModelU92 := oModel:GetModel("U92MASTER")

	If (Empty(oModelU92:GetValue("U92_CLINOV")) .Or. Empty(oModelU92:GetValue("U92_LOJNOV"))) .And. !Empty(oModelU92:GetValue("U92_NMCLIN"))
		lRetorno := .F.
	EndIf

Return(lRetorno)

/*/{Protheus.doc} FWBAgendamentos
Funcao para lista as Solicitacoes em Aberto
@type function
@version 1.0
@author g.sampaio
@since 30/03/2024
@param cCodContrato, character, codigo do contrato
@param aWBAgendamentos, array, array de solicitacoes
@param oWBAgendamentos, object, objeto da tela de solicitacoes
/*/
Static Function FWBAgendamentos(cCodContrato, aWBAgendamentos, oWBAgendamentos, oDlgAgend)

	Local cQuery 		:= ""
	Local oLegPendente	:= LoadBitmap( GetResources(), "BR_BRANCO")
	Local oLegExecucao	:= LoadBitmap( GetResources(), "BR_VERDE")

	cQuery := " SELECT * FROM " + RetSQLName("U94") + " U94 "
	cQuery += " WHERE U92.D_E_L_E_T_ = ' ' "
	cQuery += " AND U92.U92_FILIAL = '" + xFilial("U94") + "'"
	cQuery += " AND U92.U92_CONTRA = '" + cCodContrato + "'"
	cQuery += " AND U92.U92_STATUS = 'P' "

	cQuery := ChangeQuery(cQuery)

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TRBU92' )

	If TRBU92->(!Eof())

		While TRBU92->(!Eof())

			Aadd(aWBAgendamentos, {oLegPendente, AllTrim(TRBU92->U92_CODIGO), U_USX3CBOX("U92_TIPO", oModelU92:GetValue("U92_TIPO") ), AllTrim(TRBU92->U92_DESCRI), AllTrim(TRBU92->U92_SOLICI)})

			TRBU92->(DbSkip())
		EndDo
	Else
		Aadd(aWBAgendamentos,{".","","","",""})
	EndIf

	@ 050, 007 LISTBOX oWBAgendamentos Fields HEADER "","Codigo","Tipo","Descrição","Solicitante" SIZE 488, 163 OF oDlgAgend PIXEL ColSizes 50,50
	oWBAgendamentos:SetArray(aWBAgendamentos)
	oWBAgendamentos:bLine := {|| {;
		aWBAgendamentos[oWBAgendamentos:nAt,1],;
		aWBAgendamentos[oWBAgendamentos:nAt,2],;
		aWBAgendamentos[oWBAgendamentos:nAt,3],;
		aWBAgendamentos[oWBAgendamentos:nAt,4],;
		aWBAgendamentos[oWBAgendamentos:nAt,5];
		}}

Return(Nil)

/*/{Protheus.doc} IncSolic
Inclui solicitacao
@type function
@version 1.0
@author g.sampaio
@since 06/04/2024
@param cCodContrato, character, codigo do contrato
@param aWBSolicitacao, array, array de solicitacoes
@param oWBSolicitacao, object, objeto da tela de solicitacoes
@param oDlgAgend, object, objeto da tela de solicitacoes
/*/
Static Function IncSolic(cCodContrato, aWBAgendamentos, oWBAgendamentos, oDlgAgend)

	Default cCodContrato	:= ""
	Default aWBSolicitacao	:= {}
	Default oWBSolicitacao	:= Nil
	Default oDlgAgend		:= Nil

	// faco a inclusao da solicitacao
	U_RUTIL49F(3, cCodContrato)

	aWBSolicitacao	:= {}
	oWBSolicitacao 	:= Nil
	FreeObj(oWBSolicitacao)

	FWBSolicitacoes(cCodContrato, @aWBSolicitacao, @oWBSolicitacao, @oDlgAgend)

	If oDlgAgend <> Nil
		oDlgAgend:Refresh()
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
@param oDlgAgend, object, objeto da tela de solicitacoes
/*/
Static Function ExecSolic(cCodigoAgend, cCodContrato, aWBSolicitacao, oWBSolicitacao, oDlgAgend)

	Default cCodigoAgend 		:= ""
	Default cCodContrato	:= ""
	Default aWBSolicitacao	:= {}
	Default oWBSolicitacao	:= Nil
	Default oDlgAgend		:= Nil

	// executo a solicitacao
	U_RUTIL49B(cCodigoAgend)

	aWBSolicitacao	:= {}
	oWBSolicitacao 	:= Nil
	FreeObj(oWBSolicitacao)

	FWBSolicitacoes(cCodContrato, @aWBSolicitacao, @oWBSolicitacao, @oDlgAgend)

	If oDlgAgend <> Nil
		oDlgAgend:Refresh()
	EndIf

Return(NIl)
