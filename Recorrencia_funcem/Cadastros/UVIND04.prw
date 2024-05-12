#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "tbiconn.ch"

/*###########################################################################
#############################################################################
## Programa  | UVIND04 | Autor | Wellington Gon�alves  | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Lista de Envio para Integra��o Vindi						   ##
##=========================================================================##
## Uso       | P�stumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND04()
             
Local oBrowse	:= {}
Private aRotina := {}

// crio o objeto do Browser
oBrowse := FWmBrowse():New()

// defino o Alias
oBrowse:SetAlias("U62")

// informo a descri��o
oBrowse:SetDescription("Lista de Integra��o de Envio - Vindi")  

// crio as legendas 
oBrowse:AddLegend("U62_STATUS == 'P'", "GREEN"	,	"Pendente")
oBrowse:AddLegend("U62_STATUS == 'C'", "RED"	,	"Conclu�do")  
oBrowse:AddLegend("U62_STATUS == 'E'", "BLACK"	,	"Erro")  

// ativo o browser
oBrowse:Activate()

Return(Nil)

/*###########################################################################
#############################################################################
## Programa  | MenuDef | Autor | Wellington Gon�alves  | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Cria os Menus da Rotina									   ##
##=========================================================================##
## Uso       | P�stumos		                                               ##
#############################################################################
###########################################################################*/

Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   			Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  			Action 'VIEWDEF.UVIND04' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     			Action 'VIEWDEF.UVIND04' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     			Action 'VIEWDEF.UVIND04' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     			Action 'VIEWDEF.UVIND04' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    			Action 'VIEWDEF.UVIND04' 	OPERATION 08 ACCESS 0     
ADD OPTION aRotina Title 'Legenda'     			Action 'U_UVIND04L()'  		OPERATION 10 ACCESS 0  
ADD OPTION aRotina Title 'Executar Integra��o'	Action 'U_UVIND04A()' 		OPERATION 11 ACCESS 0  

Return(aRotina)

/*###########################################################################
#############################################################################
## Programa  | ModelDef | Autor | Wellington Gon�alves | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Cria o Modelo de Dados									   ##
##=========================================================================##
## Uso       | P�stumos		                                               ##
#############################################################################
###########################################################################*/

Static Function ModelDef()

Local oStruU62 	:= FWFormStruct( 1, 'U62', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel	:= NIL

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'UVIND04P', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABE�ALHO  ////////////////////////////

// Crio a Enchoice
oModel:AddFields( 'U62MASTER', /*cOwner*/, oStruU62 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "U62_FILIAL" , "U62_CODIGO" })    

// Preencho a descri��o da entidade
oModel:GetModel('U62MASTER'):SetDescription('Dados da Integra��o:')

Return(oModel)

/*###########################################################################
#############################################################################
## Programa  | ViewDef | Autor | Wellington Gon�alves  | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Cria a camada de Vis�o									   ##
##=========================================================================##
## Uso       | P�stumos		                                               ##
#############################################################################
###########################################################################*/

Static Function ViewDef()

Local oStruU62 	:= FWFormStruct(2,'U62')
Local oModel   	:= FWLoadModel('UVIND04')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_U62'	, oStruU62, 'U62MASTER') // cria o cabe�alho

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_U62' , 'PANEL_CABECALHO')

// Ligo a identificacao do componente
//oView:EnableTitleView('VIEW_U62')

// Habilita a quebra dos campos na Vertical
oView:SetViewProperty( 'U62MASTER', "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 2 } ) 

// Define fechamento da tela ao confirmar a opera��o
oView:SetCloseOnOk({||.T.})

Return(oView)     

/*###########################################################################
#############################################################################
## Programa  | UVIND04L | Autor | Wellington Gon�alves | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Tela de Legenda do Browser								   ##
##=========================================================================##
## Uso       | P�stumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND04L()

BrwLegenda("Status da Integra��o","Legenda",{ {"BR_VERDE","Pendente"},{"BR_VERMELHO","Conclu�do"}, {"BR_PRETO","Erro"} })

Return()     

/*###########################################################################
#############################################################################
## Programa  | UVIND04A | Autor | Wellington Gon�alves | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Chama fun�ao de processamento dos registros pendentes	   ##
##=========================================================================##
## Uso       | P�stumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND04A(aParam)

	Local cMessage	:= ""
	Local nStart	:= Seconds()
	Local oVindi 	:= NIL
	Local aArea		:= GetArea()

	Default aParam := {"01","010101"}

	//Valido se a execu��o � via Job
	If IsBlind()

		cMessage := "[UVIND04A][INICIO DO PROCESSAMENTO DE ENVIO VINDI]"
		FwLogMsg("INFO", , "JOB", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		cMessage := "[UVIND04A][EMPRESA: " + Alltrim(aParam[1]) + " FILIAL: " + Alltrim(aParam[2]);
			+ "DATA: " + DTOC( Date() ) + " HORA: " + Time() + "]"
		FwLogMsg("INFO", , "JOB", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

		RESET ENVIRONMENT
		PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] TABLES "UF2"

	Endif

	//-- Bloqueia rotina para apenas uma execu��o por vez
	//-- Cria��o de sem�foro no servidor de licen�as
	//-- LockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> lCreated
	If !LockByName("UVIND04A", .F., .T.)
		If IsBlind()
			cMessage := "[UVIND04A]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde..."
			FwLogMsg("INFO", , "JOB", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		Else
			MsgAlert("[UVIND04A]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde...")
		EndIf

        Return
    EndIf

	//-- Comando para o TopConnect alterar mensagem do Monitor --//
	FWMonitorMsg("UVIND04A: JOB ENVIO VINDI => " + cEmpAnt + "-" + cFilAnt)

	// crio o objeto de integracao com a vindi
	oVindi := IntegraVindi():New()

	FWMsgRun(,{|oSay| oVindi:ProcessaEnvio()},'Aguarde...','Realizando Integra��o com a Vindi...')

	RestArea(aArea)

	//-- Libera rotina para nova execu��o
	//-- Excluir sem�foro
	//-- UnLockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> Nil
	UnLockByName("UVIND04A", .F., .T.)

Return()

/*/{Protheus.doc} UVIND04B
Funcao especifica para ser executada no ONSTART
do appserver para o envio de titulos da VINDI
@type function
@version 1.0
@author g.sampaio
@since 26/11/2021
@param cParamEmp, character, codigo da empresa
@param cParamFil, character, codigo da filial
/*/
User Function UVIND04B(cParamEmp, cParamFil)
	Local aParam := {}

	Default cParamEmp	:= "99"
	Default cParamFil	:= "01"
	
	// monto o array de parametros
	aParam := {cParamEmp, cParamFil}

	// executo a funcao para executar o recebimento da vindi
	U_UVIND04A(aParam)

Return(Nil)
