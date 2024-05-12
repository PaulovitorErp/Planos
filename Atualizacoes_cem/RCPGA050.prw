#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RCPGA050
Browse de Sincronizacao de contratos
por API de Integracao
@type function
@version 1.0
@author g.sampaio
@since 08/09/2023
/*/
User Function RCPGA050()

	Local oBrowse	:= {}

	// crio o objeto do Browser
	oBrowse := FWmBrowse():New()

	// defino o Alias
	oBrowse:SetAlias("U0A")

	// informo a descrição
	oBrowse:SetDescription("Sincronizacao de Contratos")

	// crio as legendas
	oBrowse:AddLegend("U0A_STATUS == 'P'", "WHITE"	,	"Pendente")
	oBrowse:AddLegend("U0A_STATUS == 'C'", "GREEN"	,	"Concluído")
	oBrowse:AddLegend("U0A_STATUS == 'E'", "RED"	,	"Erro no Processamento")

	// ativo o browser
	oBrowse:Activate()

Return

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

	ADD OPTION aRotina Title 'Pesquisar'   						Action 'PesqBrw'          	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  						Action 'VIEWDEF.RCPGA050' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    						Action 'VIEWDEF.RCPGA050' 	OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Processar' 						Action 'U_RCPGA50A()' 		OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'     						Action 'U_RCPGA50LEG()' 	OPERATION 10 ACCESS 0

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
	Local oStruU0A 	:= FWFormStruct( 1, 'U0A', /*bAvalCampo*/, /*lViewUsado*/ )

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PCPGA050', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Crio a Enchoice
	oModel:AddFields( 'U0AMASTER', /*cOwner*/, oStruU0A )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ 'U0A_FILIAL' , 'U0A_CODIGO' })

	// Preencho a descrição da entidade
	oModel:GetModel('U0AMASTER'):SetDescription('Contratos Sincronizados')

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
	Local oStruU0A := FWFormStruct(2,'U0A')
	Local oModel := FWLoadModel('RCPGA050')
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	// cria o cabeçalho
	oView:AddField('VIEW_U0A', oStruU0A, 'U0AMASTER')

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_U0A' , 'PANEL_CABECALHO')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_U0A')

	// Habilita a quebra dos campos na Vertical
	oView:SetViewProperty( 'U0AMASTER', 'SETLAYOUT', { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} RCPGA50A
Funcao de processamento de contratos sincronizados
@type function
@version 1.0
@author g.sampaio
@since 08/09/2023
@param aParam, array, array de parametros de schedule
/*/
User Function RCPGA50A(aParam)

	Local aArea         := GetArea()
	Local cMessage      := ""
	Local lCemiterio    := .F.
	Local nStart        := Seconds()
	Local oContratos    := Nil

	Default aParam := {"01", "01"}

	//Valido se a execução é via Job
	If IsBlind()

		cMessage := "[RCPGA50A][INICIO SINCRONIZACAO DE CONTRATOS API]"
		FwLogMsg("INFO", , "JOB", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		cMessage := "[RCPGA50A][EMPRESA: " + Alltrim(aParam[1]) + " FILIAL: " + Alltrim(aParam[2]);
			+ "DATA: " + DTOC( Date() ) + " HORA: " + Time() + "]"
		FwLogMsg("INFO", , "JOB", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

		RESET ENVIRONMENT
		PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] TABLES "U0A"

	Endif

	//-- Bloqueia rotina para apenas uma execução por vez
	//-- Criação de semáforo no servidor de licenças
	//-- LockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> lCreated
	If !LockByName("RCPGA50A", .F., .T.)
		If IsBlind()
			cMessage := "[RCPGA50A]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde..."
			FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		Else
			MsgAlert("[RCPGA50A]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde...")
		EndIf

		Return
	EndIf

	//-- Comando para o TopConnect alterar mensagem do Monitor --//
	FWMonitorMsg("RCPGA50A: JOB SINCRONIZACAO DE CONTRATOS API => " + cEmpAnt + "-" + cFilAnt)

	lCemiterio	:= SuperGetMV("MV_XCEMI", .F., .F.)

	//-- Verifica modulo ativo --//
	If lCemiterio
		oContratos := CemiterioContratos():New()

		FWMsgRun(,{|| oContratos:ProcessarContratos(.T.)},;
			'Aguarde...', 'Processando contratos sincronizados...')
	EndIf

	RestArea(aArea)

	//-- Libera rotina para nova execução
	//-- Excluir semáforo
	//-- UnLockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> Nil
	UnLockByName("RCPGA50A", .F., .T.)

Return(Nil)

User Function RCPGA50LEG()

	BrwLegenda("Status","Legenda",{{"BR_BRANCO","Pendente"},{"BR_VERDE","Concluido"},{"BR_VERMELHO","Erro"}})

Return(Nil)
