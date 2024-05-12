#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "tbiconn.ch"

/*###########################################################################
#############################################################################
## Programa  | UVIND05 | Autor | Wellington Gonçalves  | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Lista de Recebimento para Integração Vindi				   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND05()
             
Local oBrowse	:= {}
Private aRotina := {}

// crio o objeto do Browser
oBrowse := FWmBrowse():New()

// defino o Alias
oBrowse:SetAlias("U63")

// informo a descrição
oBrowse:SetDescription("Lista de Integração de Recebimento - Vindi")  

// crio as legendas 
oBrowse:AddLegend("U63_STATUS == 'P'", "GREEN"	,	"Pendente")
oBrowse:AddLegend("U63_STATUS == 'C'", "RED"	,	"Concluído")  
oBrowse:AddLegend("U63_STATUS == 'E'", "BLACK"	,	"Erro")  


// ativo o browser
oBrowse:Activate()

Return(Nil)

/*###########################################################################
#############################################################################
## Programa  | MenuDef | Autor | Wellington Gonçalves  | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Cria os Menus da Rotina									   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   			Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  			Action 'VIEWDEF.UVIND05' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     			Action 'VIEWDEF.UVIND05' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     			Action 'VIEWDEF.UVIND05' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     			Action 'VIEWDEF.UVIND05' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    			Action 'VIEWDEF.UVIND05' 	OPERATION 08 ACCESS 0
ADD OPTION aRotina Title 'Legenda'     			Action 'U_UVIND05L()'  		OPERATION 10 ACCESS 0
ADD OPTION aRotina Title 'Executar Integração'	Action 'U_UVIND05A()' 		OPERATION 11 ACCESS 0
ADD OPTION aRotina Title 'Buscar Fat Por Data'	Action 'U_UVIND05B()' 		OPERATION 12 ACCESS 0

Return(aRotina)

/*###########################################################################
#############################################################################
## Programa  | ModelDef | Autor | Wellington Gonçalves | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Cria o Modelo de Dados									   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

Static Function ModelDef()

Local oStruU63 	:= FWFormStruct( 1, 'U63', /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel	:= NIL

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'UVIND05P', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABEÇALHO  ////////////////////////////

// Crio a Enchoice
oModel:AddFields( 'U63MASTER', /*cOwner*/, oStruU63 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "U63_FILIAL" , "U63_CODIGO" })    

// Preencho a descrição da entidade
oModel:GetModel('U63MASTER'):SetDescription('Dados da Integração:')

Return(oModel)

/*###########################################################################
#############################################################################
## Programa  | ViewDef | Autor | Wellington Gonçalves  | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Cria a camada de Visão									   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

Static Function ViewDef()

Local oStruU63 	:= FWFormStruct(2,'U63')
Local oModel   	:= FWLoadModel('UVIND05')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_U63'	, oStruU63, 'U63MASTER') // cria o cabeçalho

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_U63' , 'PANEL_CABECALHO')

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_U63')

// Habilita a quebra dos campos na Vertical
oView:SetViewProperty( 'U63MASTER', "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } ) 

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk({||.T.})

Return(oView)     

/*###########################################################################
#############################################################################
## Programa  | UVIND04L | Autor | Wellington Gonçalves | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Tela de Legenda do Browser								   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND05L()

BrwLegenda("Status da Integração","Legenda",{   {"BR_VERDE","Pendente"      },;
                                                {"BR_VERMELHO","Concluído"  },;
                                                {"BR_PRETO","Erro"          } })

Return()   

/*###########################################################################
#############################################################################
## Programa  | UVIND05A | Autor | Wellington Gonçalves | Data | 19/01/2019 ##
##=========================================================================##
## Desc.     | Funçao de processamento dos registros pendentes recebidos   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND05A(aParam)

	Local cMessage	:= ""
	Local nStart	:= Seconds()
	Local oVindi 	:= NIL
	Local aArea		:= GetArea()

	Default aParam := {"01","010101"}

	//Valido se a execução é via Job
	If IsBlind()

		cMessage := "[UVIND05A][INICIO DO PROCESSO DE RECEBIMENTO VINDI]"
		FwLogMsg("INFO", , "JOB", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		cMessage := "[UVIND05A][EMPRESA: " + Alltrim(aParam[1]) + " FILIAL: " + Alltrim(aParam[2]);
			+ "DATA: " + DTOC( Date() ) + " HORA: " + Time() + "]"
		FwLogMsg("INFO", , "JOB", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

		RESET ENVIRONMENT
		PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] TABLES "UF2"

	Endif

	//-- Bloqueia rotina para apenas uma execução por vez
	//-- Criação de semáforo no servidor de licenças
	//-- LockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> lCreated
	If !LockByName("UVIND05A", .F., .T.)
		If IsBlind()
			cMessage := "[UVIND05A]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde..."
			FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		Else
			MsgAlert("[UVIND05A]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde...")
		EndIf

        Return
    EndIf

	//-- Comando para o TopConnect alterar mensagem do Monitor --//
	FWMonitorMsg("UVIND05A: JOB RECEBIMENTO VINDI => " + cEmpAnt + "-" + cFilAnt)

	// crio o objeto de integracao com a vindi
	oVindi := IntegraVindi():New()

	FWMsgRun(,{|oSay| oVindi:ProcRecebi()},'Aguarde...','Processando os Registros Pendentes...')

	RestArea(aArea)

	//-- Libera rotina para nova execução
	//-- Excluir semáforo
	//-- UnLockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> Nil
	UnLockByName("UVIND05A", .F., .T.)

Return()

/*/{Protheus.doc} UVIND05B
Busca faturas pela data informada e grava na tabela U63
@type function
@version 12.1.27
@author nata.queiroz
@since 18/08/2021
/*/
User Function UVIND05B()
	Local dDataRef := dDatabase

	Local oGroup1 := Nil
	Local oSay1 := Nil
	Local oSay2 := Nil
	Local oSay3 := Nil
	Local oSay4 := Nil
	Local oGet1 := Nil
	Local oButton1 := Nil
	Local oButton2 := Nil

	Local cSay1 := "Executar rotina, preferencialmente, em período com menor número de usuários ativos."
	Local cSay2 := "A plataforma Vindi limita o número de requisições por minuto, isso pode influenciar"
	Local cSay3 := "em outras requisições relacionadas as operações na plataforma."

	Static oDlg := Nil

	DEFINE MSDIALOG oDlg TITLE "Buscar Faturas Por Data" From 0,0 TO 200,500 PIXEL

	@ 005,005 GROUP oGroup1 TO 55,245 LABEL "Info" PIXEL
	@ 020,010 SAY oSay1 PROMPT cSay1 SIZE 230,010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030,010 SAY oSay2 PROMPT cSay2 SIZE 230,010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 040,010 SAY oSay3 PROMPT cSay3 SIZE 230,010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 060,010 SAY oSay4 PROMPT "Data Referência" SIZE 150,010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070,010 MSGET oGet1 VAR dDataRef SIZE 050,010 PIXEL OF oDlg

	@ 070, 140 BUTTON oButton1 PROMPT "Confirmar" SIZE 045, 014 OF oDlg ACTION FWMsgRun(,{|oSay| GrvFatPorData(dDataRef)},'Aguarde...','Buscando faturas pela data informada...') PIXEL
	@ 070, 190 BUTTON oButton2 PROMPT "Fechar" SIZE 045, 014 OF oDlg ACTION oDlg:End() PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} GrvFatPorData
Grava faturas pela data informada na tabela U63
@type function
@version 12.1.27
@author nata.queiroz
@since 19/08/2021
@param dDataRef, date, dDataRef
/*/
Static Function GrvFatPorData(dDataRef)
	Local lFuneraria := SuperGetMV("MV_XFUNE", .F., .F.)
	Local cCodModulo := IIF(lFuneraria, "F", "C")
	Local oVindi := Nil
	Local oJSON := JsonObject():New()
	Local cPagto := "1"
	Local cEstorno := "2"
	Local aFaturas := {}
	Local nPage := 1
	Local nX := 0

	Default dDataRef := dDatabase

	oVindi := IntegraVindi():New()
	aFaturas := oVindi:BuscarFatPorData(dDataRef, nPage)

	While Len(aFaturas) > 0
		For nX := 1 To Len(aFaturas)
			oJSON:fromJSON( aFaturas[nX] )

			If oJSON["bill"]["status"] == "paid" .And. !ExistU63( cValToChar(oJSON["bill"]["id"]), cPagto ) // Pagamento
				If oJSON["bill"]["charges"][1]["payment_method"]["code"] <> "cash"
					oVindi:IncluiTabReceb(cCodModulo, cPagto, aFaturas[nX])
				EndIf
			ElseIf oJSON["bill"]["status"] == "canceled" .And. !ExistU63( cValToChar(oJSON["bill"]["id"]), cEstorno ) // Estorno
				oVindi:IncluiTabReceb(cCodModulo, cEstorno, aFaturas[nX])
			EndIf
		Next nX

		nPage++
		FreeObj(oJSON)
		oJSON := JsonObject():New()
		aFaturas := {}
		aFaturas := oVindi:BuscarFatPorData(dDataRef, nPage)
	EndDo

Return

/*/{Protheus.doc} ExistU63
Verifica se o pagamento já está gravado
@type function
@version 1.0
@author nata.queiroz
@since 20/03/2020
@param cCodVindi, character, cCodVindi
@param cTipo, character, cTipo
@return logical, lRet
/*/
Static Function ExistU63(cCodVindi, cTipo)
    Local lRet := .F.
    Local cQry := ""

    Default cCodVindi := ""
	Default cTipo := "1" //-- 1 => Pagamento | 2 => Estorno | 3 => Tentativa | 4 => Teste

    cQry := "SELECT U63_CODIGO CODIGO "
    cQry += "FROM " + RetSqlName("U63") +" (NOLOCK)"
    cQry += "WHERE D_E_L_E_T_ <> '*' "
    cQry += "AND U63_MSFIL = '"+ cFilAnt +"' "
    cQry += "AND U63_ENT = '"+ cTipo +"' "
    cQry += "AND U63_IDVIND = '"+ AllTrim(cCodVindi) +"' "
    
	cQry := ChangeQuery(cQry)

    If Select("EXU63") > 0
        EXU63->( DbCloseArea() )
    EndIf

	MPSysOpenQuery(cQry, "EXU63")

    If EXU63->(!Eof())
        lRet := .T.
    EndIf

    If Select("EXU63") > 0
        EXU63->( DbCloseArea() )
    EndIf

Return(lRet)

/*/{Protheus.doc} UVIND05C
Funcao especifica para ser executada no ONSTART
do appserver para o recebimento de titulos da VINDI
@type function
@version 1.0
@author g.sampaio
@since 26/11/2021
@param cParamEmp, character, codigo da empresa
@param cParamFil, character, codigo da filial
/*/
User Function UVIND05C(cParamEmp, cParamFil)
	Local aParam := {}

	Default cParamEmp	:= "99"
	Default cParamFil	:= "01"
	
	// monto o array de parametros
	aParam := {cParamEmp, cParamFil}

	// executo a funcao para executar o recebimento da vindi
	U_UVIND05A(aParam)

Return(Nil)
