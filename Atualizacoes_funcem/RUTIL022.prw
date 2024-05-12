#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTIL022
Browse Sincronização Cobranças Aprovadas
@type function
@version 1.0
@author nata.queiroz
@since 06/04/2021
/*/
User Function RUTIL022
    Local oBrowse	:= {}

    // crio o objeto do Browser
    oBrowse := FWmBrowse():New()

    // defino o Alias
    oBrowse:SetAlias("UZ0")

    // informo a descrição
    oBrowse:SetDescription("Sincronização Cobranças Aprovadas")

    // crio as legendas 
    oBrowse:AddLegend("UZ0_STATUS == 'P'", "GREEN"	,	"Pendente")
    oBrowse:AddLegend("UZ0_STATUS == 'C'", "RED"	,	"Concluído")
    oBrowse:AddLegend("UZ0_STATUS == 'E'", "BLACK"	,	"Erro")

    // ativo o browser
    oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Cria os Menus da Rotina
@type function
@version 1.0
@author nata.queiroz
@since 06/04/2021
@return array, aRotina
/*/
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina Title 'Pesquisar'            Action 'PesqBrw'                        OPERATION 01 ACCESS 0
    ADD OPTION aRotina Title 'Visualizar'           Action 'VIEWDEF.RUTIL022'               OPERATION 02 ACCESS 0
    ADD OPTION aRotina Title 'Imprimir'             Action 'VIEWDEF.RUTIL022'               OPERATION 08 ACCESS 0
    ADD OPTION aRotina Title 'Processar Cobrancas'  Action 'U_RUTIL22A()'                   OPERATION 11 ACCESS 0
    ADD OPTION aRotina Title 'Enviar Cobrancas'     Action 'U_RUTILE55(cEmpAnt,cFilAnt)'    OPERATION 12 ACCESS 0 

Return aRotina

/*/{Protheus.doc} ModelDef
Cria o Modelo de Dados
@type function
@version 1.0
@author nata.queiroz
@since 06/04/2021
@return object, oModel
/*/
Static Function ModelDef()
    Local oStruUZ0 	:= FWFormStruct( 1, 'UZ0', /*bAvalCampo*/, /*lViewUsado*/ )
    Local oModel	:= NIL

    // Cria o objeto do Modelo de Dados
    oModel := MPFormModel():New( 'PRUTIL022', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

    // Crio a Enchoice
    oModel:AddFields( 'UZ0MASTER', /*cOwner*/, oStruUZ0 )

    // Adiciona a chave primaria da tabela principal
    oModel:SetPrimaryKey({ 'UZ0_FILIAL' , 'UZ0_CODIGO' })

    // Preencho a descrição da entidade
    oModel:GetModel('UZ0MASTER'):SetDescription('Dados Integração')

Return oModel

/*/{Protheus.doc} ViewDef
Cria a camada de Visão
@type function
@version 1.0
@author nata.queiroz
@since 06/04/2021
@return object, oView
/*/
Static Function ViewDef()
    Local oStruUZ0 := FWFormStruct(2,'UZ0')
    Local oModel := FWLoadModel('RUTIL022')
    Local oView

    // Cria o objeto de View
    oView := FWFormView():New()

    // Define qual o Modelo de dados será utilizado
    oView:SetModel(oModel)

    // cria o cabeçalho
    oView:AddField('VIEW_UZ0', oStruUZ0, 'UZ0MASTER')

    // Crio os Panel's horizontais 
    oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

    // Relaciona o ID da View com os panel's
    oView:SetOwnerView('VIEW_UZ0' , 'PANEL_CABECALHO')

    // Ligo a identificacao do componente
    oView:EnableTitleView('VIEW_UZ0')

    // Habilita a quebra dos campos na Vertical
    oView:SetViewProperty( 'UZ0MASTER', 'SETLAYOUT', { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

    // Define fechamento da tela ao confirmar a operação
    oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} RUTIL22A
Job processamento cobrancas pendentes
@type function
@version 1.0
@author nata.queiroz
@since 08/04/2021
@param aParam, array, aParam
/*/
User Function RUTIL22A(aParam) //-- U_RUTIL22A()
	Local cMessage := ""
	Local nStart := Seconds()
	Local aArea := GetArea()
    Local oVirtusCobranca2 := Nil

	Default aParam := {"01", "01"}

	//Valido se a execução é via Job
	If IsBlind()

		cMessage := "[RUTIL22A][INICIO PROCESSAMENTO COBRANCAS PENDENTES VIRTUS]"
		FwLogMsg("INFO", , "JOB", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		cMessage := "[RUTIL22A][EMPRESA: " + Alltrim(aParam[1]) + " FILIAL: " + Alltrim(aParam[2]);
			+ "DATA: " + DTOC( Date() ) + " HORA: " + Time() + "]"
		FwLogMsg("INFO", , "JOB", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

		RESET ENVIRONMENT
		PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2]

	Endif

	//-- Bloqueia rotina para apenas uma execução por vez
	//-- Criação de semáforo no servidor de licenças
	//-- LockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> lCreated
	If !LockByName("RUTIL22A", .F., .T.)
		If IsBlind()
			cMessage := "[RUTIL22A]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde..."
			FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		Else
			MsgAlert("[RUTIL22A]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde...")
		EndIf

        Return
    EndIf

	//-- Comando para o TopConnect alterar mensagem do Monitor --//
	FWMonitorMsg("RUTIL22A: JOB PROCESSAMENTO COBRANCAS PENDENTES VIRTUS => " + cEmpAnt + "-" + cFilAnt)

    oVirtusCobranca2 := VirtusCobranca2():New()
    FWMsgRun(,{|| oVirtusCobranca2:processarCobrancas() },;
        'Aguarde...', 'Processando cobrancas pendentes...')

    FreeObj(oVirtusCobranca2)

	RestArea(aArea)

	//-- Libera rotina para nova execução
	//-- Excluir semáforo
	//-- UnLockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> Nil
	UnLockByName("RUTIL22A", .F., .T.)

Return(Nil)

/*/{Protheus.doc} RUTIL22B
Funcao especifica para ser executada no ONSTART
do appserver para o processamento de cobranças pendentes
do Virtus Cobranças
@type function
@version 1.0
@author g.sampaio
@since 26/11/2021
@param cParamEmp, character, codigo da empresa
@param cParamFil, character, codigo da filial
/*/
User Function RUTIL22B(cParamEmp, cParamFil)
	Local aParam := {}

	Default cParamEmp	:= "99"
	Default cParamFil	:= "01"
	
	// monto o array de parametros
	aParam := {cParamEmp, cParamFil}

	// executo a funcao para executar o recebimento da vindi
	U_RUTIL22A(aParam)

Return(Nil)

