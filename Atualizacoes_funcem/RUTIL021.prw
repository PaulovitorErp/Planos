#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTIL021
Browse Sincronização Vendas Aprovadas
@type function
@version 1.0
@author nata.queiroz
@since 19/08/2020
/*/
User Function RUTIL021
	Local oBrowse	:= {}

	// crio o objeto do Browser
	oBrowse := FWmBrowse():New()

	// defino o Alias
	oBrowse:SetAlias("U82")

	// informo a descrição
	oBrowse:SetDescription("Sincronização Vendas Aprovadas")

	// crio as legendas
	oBrowse:AddLegend("U82_STATUS == 'P'", "GREEN"	,	"Pendente")
	oBrowse:AddLegend("U82_STATUS == 'C'", "RED"	,	"Concluído")
	oBrowse:AddLegend("U82_STATUS == 'E'", "BLACK"	,	"Erro")

	// ativo o browser
	oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Cria os Menus da Rotina
@type function
@version 1.0
@author nata.queiroz
@since 19/08/2020
@return aRotina, array
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Pesquisar'            Action 'PesqBrw'            OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'           Action 'VIEWDEF.RUTIL021'   OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'             Action 'VIEWDEF.RUTIL021'   OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Sincronizar Vendas'   Action 'U_RUTIL21A()'       OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title 'Processar Vendas'     Action 'U_RUTIL21B()'       OPERATION 11 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Cria o Modelo de Dados
@type function
@version 1.0
@author nata.queiroz
@since 19/08/2020
@return oModel, object
/*/
Static Function ModelDef()
	Local oStruU82 	:= FWFormStruct( 1, 'U82', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel	:= NIL

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'UVIND05P', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Crio a Enchoice
	oModel:AddFields( 'U82MASTER', /*cOwner*/, oStruU82 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ 'U82_FILIAL' , 'U82_CODIGO' })

	// Preencho a descrição da entidade
	oModel:GetModel('U82MASTER'):SetDescription('Dados Integração')

Return oModel

/*/{Protheus.doc} ViewDef
Cria a camada de Visão
@type function
@version 1.0
@author nata.queiroz
@since 19/08/2020
@return oView, object
/*/
Static Function ViewDef()
	Local oStruU82 := FWFormStruct(2,'U82')
	Local oModel := FWLoadModel('RUTIL021')
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	// cria o cabeçalho
	oView:AddField('VIEW_U82', oStruU82, 'U82MASTER')

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_U82' , 'PANEL_CABECALHO')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_U82')

	// Habilita a quebra dos campos na Vertical
	oView:SetViewProperty( 'U82MASTER', 'SETLAYOUT', { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} RUTIL21A
Job sincronizacao de vendas aprovadas no Virtus
@type function
@version 1.0
@author nata.queiroz
@since 19/08/2020
@param aParam, array, parametros da rotina
/*/
User Function RUTIL21A(aParam) //-- U_RUTIL21A()
	Local cMessage := ""
	Local nStart := Seconds()
	Local aArea := GetArea()
	Local aSM0Data := {}
	Local cCnpj := ""
	Local lFuneraria  := .F.
	Local cCodigoModulo := "F"

	Default aParam := {"01", "01"}

	//Valido se a execução é via Job
	If IsBlind()

		cMessage := "[RUTIL21A][INICIO SINCRONIZACAO VENDAS VIRTUS]"
		FwLogMsg("INFO", , "JOB", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		cMessage := "[RUTIL21A][EMPRESA: " + Alltrim(aParam[1]) + " FILIAL: " + Alltrim(aParam[2]);
			+ "DATA: " + DTOC( Date() ) + " HORA: " + Time() + "]"
		FwLogMsg("INFO", , "JOB", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

		RESET ENVIRONMENT
		PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] TABLES "U82"

	Endif

	//-- Bloqueia rotina para apenas uma execução por vez
	//-- Criação de semáforo no servidor de licenças
	//-- LockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> lCreated
	If !LockByName("RUTIL21A", .F., .T.)
		If IsBlind()
			cMessage := "[RUTIL21A]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde..."
			FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		Else
			MsgAlert("[RUTIL21A]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde...")
		EndIf

		Return
	EndIf

	//-- Comando para o TopConnect alterar mensagem do Monitor --//
	FWMonitorMsg("RUTIL21A: JOB SINCRONIZACAO VENDAS VIRTUS => " + cEmpAnt + "-" + cFilAnt)

	aSM0Data := FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, { "M0_CGC" })
	cCnpj := AllTrim( aSM0Data[1][2] )
	lFuneraria	:= SuperGetMV("MV_XFUNE", .F., .F.)

	//-- Verifica modulo ativo --//
	If lFuneraria
		FWMsgRun(,{|| IntegraVendasVirtus():BuscarVendasAprovadas(cCnpj, cCodigoModulo)},;
			'Aguarde...', 'Sincronizando vendas aprovadas...')
	EndIf

	//-- Libera rotina para nova execução
	//-- Excluir semáforo
	//-- UnLockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> Nil
	UnLockByName("RUTIL21A", .F., .T.)

	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} RUTIL21B
Job processamento de vendas pendentes
@type function
@version 1.0
@author nata.queiroz
@since 19/08/2020
@param aParam, array
/*/
User Function RUTIL21B(aParam) //-- U_RUTIL21B()
	Local cMessage := ""
	Local nStart := Seconds()
	Local aArea := GetArea()
	Local lFuneraria  := .F.
	Local oIntegraVendasVirtus := Nil

	Default aParam := {"01", "01"}

	//Valido se a execução é via Job
	If IsBlind()

		cMessage := "[RUTIL21B][INICIO PROCESSAMENTO VENDAS PENDENTES VIRTUS]"
		FwLogMsg("INFO", , "JOB", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		cMessage := "[RUTIL21B][EMPRESA: " + Alltrim(aParam[1]) + " FILIAL: " + Alltrim(aParam[2]);
			+ "DATA: " + DTOC( Date() ) + " HORA: " + Time() + "]"
		FwLogMsg("INFO", , "JOB", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

		RESET ENVIRONMENT
		PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2]

	Endif

	//-- Bloqueia rotina para apenas uma execução por vez
	//-- Criação de semáforo no servidor de licenças
	//-- LockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> lCreated
	If !LockByName("RUTIL21B", .F., .T.)
		If IsBlind()
			cMessage := "[RUTIL21B]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde..."
			FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		Else
			MsgAlert("[RUTIL21B]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde...")
		EndIf

		Return
	EndIf

	//-- Comando para o TopConnect alterar mensagem do Monitor --//
	FWMonitorMsg("RUTIL21B: JOB PROCESSAMENTO VENDAS PENDENTES VIRTUS => " + cEmpAnt + "-" + cFilAnt)

	lFuneraria	:= SuperGetMV("MV_XFUNE", .F., .F.)

	//-- Verifica modulo ativo --//
	If lFuneraria
		oIntegraVendasVirtus := IntegraVendasVirtus():New()
		FWMsgRun(,{|| oIntegraVendasVirtus:processarVendas() },;
			'Aguarde...', 'Processando vendas pendentes...')
	EndIf

	FreeObj(oIntegraVendasVirtus)

	//-- Libera rotina para nova execução
	//-- Excluir semáforo
	//-- UnLockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> Nil
	UnLockByName("RUTIL21B", .F., .T.)

	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} RUTIL21C
Funcao especifica para ser executada no ONSTART
do appserver para a sincronização do Virtus Vendas
@type function
@version 1.0
@author g.sampaio
@since 26/11/2021
@param cParamEmp, character, codigo da empresa
@param cParamFil, character, codigo da filial
/*/
User Function RUTIL21C(cParamEmp, cParamFil)
	Local aParam := {}

	Default cParamEmp	:= "99"
	Default cParamFil	:= "01"

	// monto o array de parametros
	aParam := {cParamEmp, cParamFil}

	// executo a funcao para executar o recebimento da vindi
	U_RUTIL21A(aParam)

Return(Nil)

/*/{Protheus.doc} RUTIL21D
Funcao especifica para ser executada no ONSTART
do appserver para o processamento do vendas pendentes
do Virtus Vendas
@type function
@version 1.0
@author g.sampaio
@since 26/11/2021
@param cParamEmp, character, codigo da empresa
@param cParamFil, character, codigo da filial
/*/
User Function RUTIL21D(cParamEmp, cParamFil)
	Local aParam := {}

	Default cParamEmp	:= "99"
	Default cParamFil	:= "01"

	// monto o array de parametros
	aParam := {cParamEmp, cParamFil}

	// executo a funcao para executar o recebimento da vindi
	U_RUTIL21B(aParam)

Return(Nil)
