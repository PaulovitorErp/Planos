#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'

/*/{Protheus.doc} UVIND07
Cadastro de Perfil de Pagamento do Cliente Vindi	
@type function
@version 
@author Wellington Gonçalves
@since 23/01/2019
@return return_type, return_description
/*/
User Function UVIND07()

	Local oBrowse	:= {}
	Private aRotina := {}

	// crio o objeto do Browser
	oBrowse := FWmBrowse():New()

	// defino o Alias
	oBrowse:SetAlias("U64")

	// informo a descrição
	oBrowse:SetDescription("Perfil de Pagamento - Vindi")

	// crio as legendas
	oBrowse:AddLegend("U64_STATUS == 'A'", "GREEN"	,	"Ativo")
	oBrowse:AddLegend("U64_STATUS == 'I'", "RED"	,	"Inativo")

	// ativo o browser
	oBrowse:Activate()

Return(Nil)

/*/{Protheus.doc} MenuDef
Cria os Menus da Rotina
@type function
@version 
@author Wellington Gonçalves
@since 19/01/2019
@return return_type, return_description
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title 'Pesquisar'   	Action 'PesqBrw'          	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.UVIND07' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.UVIND07' 	OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.UVIND07' 	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.UVIND07' 	OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.UVIND07' 	OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'     	Action 'U_UVIND07L()'  		OPERATION 10 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
Cria o Modelo de Dados
@type function
@version 
@author Wellington Gonçalves
@since 19/01/2019
@return return_type, return_description
/*/
Static Function ModelDef()

	Local oStruU64 	:= FWFormStruct( 1, 'U64', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel	:= NIL

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'UVIND07P', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	/////////////////////////  CABEÇALHO  ////////////////////////////

	// Crio a Enchoice
	oModel:AddFields( 'U64MASTER', /*cOwner*/, oStruU64 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "U64_FILIAL" , "U64_CODIGO" })

	// Preencho a descrição da entidade
	oModel:GetModel('U64MASTER'):SetDescription('Dados do Perfil de Pagamento:')

Return(oModel)

/*/{Protheus.doc} ViewDef
Cria a camada de Visão
@type function
@version 
@author Wellington Gonçalves
@since 19/01/2019
@return return_type, return_description
/*/
Static Function ViewDef()

	Local oStruU64 	:= FWFormStruct(2,'U64')
	Local oModel   	:= FWLoadModel('UVIND07')
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	oView:AddField('VIEW_U64'	, oStruU64, 'U64MASTER') // cria o cabeçalho

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_U64' , 'PANEL_CABECALHO')

	// Ligo a identificacao do componente
	//oView:EnableTitleView('VIEW_U64')

	// Habilita a quebra dos campos na Vertical
	oView:SetViewProperty( 'U64MASTER', "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 2 } )

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

	// Funcao chamada na abertura da tela
	oView:SetAfterViewActivate({|oView| IniCpo(oView)} )

Return(oView)

/*/{Protheus.doc} UVIND07L
Tela de Legenda do Browser	
@type function
@version 
@author Wellington Gonçalves
@since 23/01/2019
@return return_type, return_description
/*/
User Function UVIND07L()

	BrwLegenda("Status do Perfil de Pagamento","Legenda",{ {"BR_VERDE","Ativo"},{"BR_VERMELHO","Inativo"} })

Return()

/*/{Protheus.doc} IniCpo
Funcao para preenchimento de campos na abertura da tela

@type function
@version 
@author Wellington Gonçalves
@since 26/01/2019
@param oView, object, param_description
@return return_type, return_description
@history 27/10/2020, g.sampaio, VPDV-497 - Implementacao de tratativa para gerar a taxa de manutencao para recorrencia
/*/
Static Function IniCpo(oView)

	Local cNome			:= ""
	Local cDesFor		:= ""
	Local cCodModulo	:= ""
	Local cFormaPag		:= ""
	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
	Local nOperation 	:= oView:GetOperation()
	Local oModel	 	:= FWModelActive()
	Local oView		 	:= FWViewActive()
	Local oModelU64  	:= oModel:GetModel("U64MASTER")

	// verifico a rotina e o parametro para verificar o modulo
	if lCemiterio .And. "CPG" $ AllTrim(FunName()) // para modulo de cemiterio
		cCodModulo := "C"
	elseIf lCemiterio .And. "FUN" $ AllTrim(FunName()) // para modulo de funeraria
		cCodModulo := "F"
	elseIf lCemiterio // para modulo de cemiterio
		cCodModulo := "C"
	elseIf lFuneraria // para modulo de funeraria
		cCodModulo := "F"
	endIf

	If nOperation == 3 // Inclusao

		// se a inclusao foi chamada da ativacao do contrato da funeraria
		if cCodModulo == "F"

			cDesFor	:= Posicione("SX5",1,xFilial("SX5") + "24" + UF2->UF2_FORPG,"X5_DESCRI")

			oModelU64:LoadValue("U64_CONTRA"	, UF2->UF2_CODIGO	)

			//Se foi chamado da rotina de transferencia de titularidade
			if IsInCallStack("U_RFUNA006")
				oModelU64:LoadValue("U64_CLIENT"	, M->UF2_CLIENT	)
				oModelU64:LoadValue("U64_LOJA"		, M->UF2_LOJA	)

				cNome	:= Posicione("SA1",1,xFilial("SA1") + M->UF2_CLIENT + M->UF2_LOJA,"A1_NOME")
			Else
				oModelU64:LoadValue("U64_CLIENT"	, UF2->UF2_CLIENT	)
				oModelU64:LoadValue("U64_LOJA"		, UF2->UF2_LOJA		)

				cNome	:= Posicione("SA1",1,xFilial("SA1") + UF2->UF2_CLIENT + UF2->UF2_LOJA,"A1_NOME")
			Endif


			oModelU64:LoadValue("U64_NOME"		, AllTrim(cNome)	)

			//Se é chamado da rotina de convalescente usa forma de pagamento convalescente
			if IsIncallStack("U_PFUNA044")

				oModelU64:LoadValue("U64_FORPG"		, Alltrim(M->UJH_FORPG ))

			else

				oModelU64:LoadValue("U64_FORPG"		, Alltrim(UF2->UF2_FORPG)	)

			endif

			oModelU64:LoadValue("U64_DESFOR"	, AllTrim(cDesFor)	)

		elseif cCodModulo == "C" // modulo de cemiterio

			cNome	:= Posicione("SA1",1,xFilial("SA1") + U00->U00_CLIENT + U00->U00_LOJA,"A1_NOME")

			oModelU64:LoadValue("U64_CONTRA"	, U00->U00_CODIGO	)
			oModelU64:LoadValue("U64_CLIENT"	, U00->U00_CLIENT	)
			oModelU64:LoadValue("U64_LOJA"		, U00->U00_LOJA		)
			oModelU64:LoadValue("U64_NOME"		, AllTrim(cNome)	)

			// taxa de manutencao
			if IsInCallStack("U_RCPGE055")// alteracao da forma de pagamento da taxa de manutencao

				// preencho o campo de forma de pagamento
				oModelU64:LoadValue("U64_FORPG"		, U00->U00_FPTAXA	)

				// descricao da forma de pagamento
				cDesFor	:= Posicione("SX5",1,xFilial("SX5") + "24" + U00->U00_FPTAXA,"X5_DESCRI")

			elseIf IsInCallStack("U_RCPGE045")// ativacao do contrato

				// verifico se a forma de pagamento estiver vinculada a um metodo de pagamento VINDI
				U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
				if U60->(MsSeek(xFilial("U60") + U00->U00_FORPG))
					cFormaPag := U00->U00_FORPG
				endIf

				// verifico se a forma de pagamento estiver vinculada a um metodo de pagamento VINDI
				U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
				if Empty(cFormaPag) .And. U60->(MsSeek(xFilial("U60") + U00->U00_FPTAXA))
					cFormaPag := U00->U00_FPTAXA
				endIf

				// preencho o campo de forma de pagamento
				oModelU64:LoadValue("U64_FORPG"		, cFormaPag	)

				// descricao da forma de pagamento
				cDesFor	:= Posicione("SX5",1,xFilial("SX5") + "24" + cFormaPag,"X5_DESCRI")

			elseif IsInCallStack("U_RCPGE044")// geracao de taxa de manutencao cemiterio
				
				// verifico se a forma de pagamento estiver vinculada a um metodo de pagamento VINDI
				U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
				if Empty(cFormaPag) .And. U60->(MsSeek(xFilial("U60") + U00->U00_FPTAXA))
					cFormaPag := U00->U00_FPTAXA
				endIf

				// preencho o campo de forma de pagamento
				oModelU64:LoadValue("U64_FORPG"		, cFormaPag	)

				// descricao da forma de pagamento
				cDesFor	:= Posicione("SX5",1,xFilial("SX5") + "24" + cFormaPag,"X5_DESCRI")

			else // contrato
				
				//verifico se o model do contrato esta ativo, caso esteja pego o conteudo 
				if Type( "oModelU00" ) == "O"
					cFormaPag := oModelU00:GetValue("U00_FPTAXA")
				else
					cFormaPag := U00->U00_FORPG	
				endif

				// preencho o campo de forma de pagamento
				oModelU64:LoadValue("U64_FORPG"		, cFormaPag	)

				// descricao da forma de pagamento
				cDesFor	:= Posicione("SX5",1,xFilial("SX5") + "24" + cFormaPag,"X5_DESCRI")
			endIf

			oModelU64:LoadValue("U64_DESFOR"	, AllTrim(cDesFor)	)

		endif

		// atualizo a View
		oView:Refresh()

	endif

Return(Nil)

/*/{Protheus.doc} UVIND07X
Funcao chamada na validação dos campos do Perfil	
@type function
@version 
@author Wellington Gonçalves
@since 17/02/2019
@param cOpc, character, param_description
@return return_type, return_description
/*/
User Function UVIND07X(cOpc)

	Local lRet 				:= .T.
	Local oModel 			:= FWModelActive()
	Local oModelU64  		:= oModel:GetModel("U64MASTER") // CABEÇALHO
	Local nTamCartao		:= Len(AllTrim(M->U64_NUMCAR))
	Local nTamData			:= TamSX3("U64_VALIDA")[1]
	Local cUltimosDigitos	:= ""
	Local nMinNumCartoes	:= SuperGetMV("MV_XMINCART",,13)
	Local nMinCVV			:= SuperGetMV("MV_XMINCVV",,3)

	if cOpc == "1" // U64_NUMCAR - Numero do Cartao

		if Len(AllTrim(M->U64_NUMCAR)) < nMinNumCartoes 
			lRet := .F.
			Help(NIL, NIL, "Atenção!", NIL, "Número do Cartão Inválido.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe todos os dígitos!"})
		else

			cUltimosDigitos := Alltrim(SubStr(M->U64_NUMCAR,(nTamCartao - 4) + 1 , nTamCartao))

			oModelU64:LoadValue( "U64_DIGCAR", cUltimosDigitos )

		endif

	elseif cOpc == "2" // U64_VALIDA - Validade

		if Len(AllTrim(M->U64_VALIDA)) < nTamData
			lRet := .F.
			Help(NIL, NIL, "Atenção!", NIL, "Data de validade Inválida.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe todos os dígitos!"})
		else

			cMes 	:= SubStr(M->U64_VALIDA,1,2)
			cAno	:= SubStr(M->U64_VALIDA,3,4)

			if cMes < "01" .OR. cMes > "12"
				lRet := .F.
				Help(NIL, NIL, "Atenção!", NIL, "o Mês informado é Inválido.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe o mês corretamente!"})
			else

				if (cAno + cMes) < AnoMes(dDataBase)
					lRet := .F.
					Help(NIL, NIL, "Atenção!", NIL, "Validade expirada.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Não é possível informar um cartão já vencido!"})
				endif

			endif

		endif

	elseif cOpc == "3" // U64_CVV - CVV

		if Len(AllTrim(M->U64_CVV)) < nMinCVV
			lRet := .F.
			Help(NIL, NIL, "Atenção!", NIL, "CVV Inválido.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe todos os dígitos!"})
		endif

	endif

Return(lRet)
