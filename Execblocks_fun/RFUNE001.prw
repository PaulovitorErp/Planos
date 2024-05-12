#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} RFUNE001
Responsável pela suspensão de Contratos de Funerária, executado via Schedule
@author TOTVS
@since 27/04/2016
@version P12
@param Nao recebe parametros
@return nulo
@history 02/06/2020, g.sampaio, VPDV-473 - ajustado a identacao do fonte. 
Feito ajuste na descricao do conteúdo da função PtInternal
/*/

/***********************/
User Function RFUNE001(aEmpresas)
/***********************/

	Local aArea			:= {}
	Local aAreaUF2		:= {}
	Local cMessage		:= ""
	Local nStart		:= Seconds()
	Local cQry 			:= ""
	Local cEmpJob		:= ""
	Local cFilJbo		:= ""
	Local lVencOrig		:= .T.
	Local nParcs		:= 0

	Default aEmpresas	:= {"01","010101"}

	//prepara a conexao com empresa
	RpcSetType(3)
	RpcClearEnv()  //-- Limpa ambiente
	RpcSetEnv(aEmpresas[01], aEmpresas[02])

	FwLogMsg("INFO", , "REST", FunName(), "", "01", "INICIO DO JOB RFUNE001 - SUSPENSÃO DE CONTRATO ", 0, (Seconds() - nStart), {})

	//-- Comando para o TopConnect alterar mensagem do Monitor --//
	FWMonitorMsg("RFUNE001: JOB SUSPENSAO DO CONTRATO DE PLANOS ASSISTENCIAIS")

	SM0->( DbGotop() )

	While SM0->(!EOF()) .And. SM0->M0_CODIGO <> '99'

		cEmpJob		:= Alltrim(SM0->M0_CODIGO)
		cFilJbo		:= Alltrim(SM0->M0_CODFIL)

		FwLogMsg("INFO", , "REST", FunName(), "", "01", "RFUNE001 - SUSPENSAO DE CONTRATO: EMPRESA: "+SM0->M0_CODIGO+" FILIAL: " + SM0->M0_CODFIL, 0, (Seconds() - nStart), {})

		RpcSetType(3)
		RpcClearEnv()  //-- Limpa ambiente
		RpcSetEnv(cEmpJob, cFilJbo)

		//-- Bloqueia rotina para apenas uma execução por vez
		//-- Criação de semáforo no servidor de licenças
		//-- LockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> lCreated
		If !LockByName("RFUNE001", .F., .T.)
			If IsBlind()
				cMessage := "[RFUNE001]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde..."
				FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
			Else
				MsgAlert("[RFUNE001]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde...")
			EndIf

			Loop //-- Pula para proxima empresa
		EndIf

		lExec 		:= SuperGetMv("MV_XSUSFUN",.F.,.T.) //Default ativo

		If lExec

			aArea 		:= GetArea()
			aAreaUF2 	:= UF2->(GetArea())
			nParcs 		:= SuperGetMv("MV_XPARCFU",.F.,6)
			lVencOrig	:= SuperGetMv("MV_XVEORIS",.F.,.T.)

			If Select("QRYSUSP") > 0
				QRYSUSP->(DbCloseArea())
			Endif

			cQry := "SELECT
			cQry += " UF2.UF2_CODIGO 	AS CONTRATO,
			cQry += " COUNT(SE1.E1_NUM) AS PARCELAS"
			cQry += " FROM "
			cQry += RetSqlName("UF2") + " UF2 (NOLOCK)"
			cQry += " INNER JOIN  "
			cQry += RetSqlName("SE1")+" SE1 (NOLOCK)"
			cQry += " ON SE1.D_E_L_E_T_		= ' '
			cQry += " AND SE1.E1_FILIAL		= '"+xFilial("SE1")+"' "
			cQry += " AND UF2.UF2_CODIGO 	= SE1.E1_XCTRFUN "
			cQry += " AND UF2.UF2_CLIENT  	= SE1.E1_CLIENTE "
			cQry += " AND UF2.UF2_LOJA		= SE1.E1_LOJA "
			cQry += " AND SE1.E1_SALDO	> 0 " //Em aberto

			//valido de considera o vencimento original
			if !lVencOrig
				cQry += " AND SE1.E1_VENCREA 	< '"+DToS(dDataBase)+"'"
			else
				cQry += " AND SE1.E1_VENCORI	< '"+DToS(dDataBase)+"'"
			endif

			// ignoro os seguintes titulos no momento da suspensao de contratos
			cQry += " AND SE1.E1_TIPO NOT IN ('AB-','FB-','FC-','FU-' "
			cQry += " ,'PR','IR-','IN-','IS-','PI-','CF-','CS-','FE-' "
			cQry += " ,'IV-','RA','NCC','NDC') "

			cQry += " WHERE UF2.D_E_L_E_T_ 	= ' '"
			cQry += " AND UF2.UF2_FILIAL 	= '"+xFilial("UF2")+"'"
			cQry += " AND UF2.UF2_STATUS	= 'A'" //Ativo
			cQry += " GROUP BY UF2.UF2_CODIGO "
			cQry += " HAVING COUNT(SE1.E1_NUM) >= "+cValToChar(nParcs)+""

			cQry := ChangeQuery(cQry)

			// executo a query e crio o alias temporario
			MPSysOpenQuery( cQry, 'QRYSUSP' )

			DbSelectArea("UF2")

			While QRYSUSP->(!EOF())

				UF2->(DbSetOrder(1)) //UF2_FILIAL + UF2_CODIGOs
				If UF2->(DbSeek(xFilial("UF2")+QRYSUSP->CONTRATO))

					BEGIN TRANSACTION

						If UF2->(RecLock("UF2",.F.))
							UF2->UF2_STATUS := "S" //Suspenso
							UF2->UF2_DTSUSP	:= dDataBase // gravo a data de suspensao
							UF2->(MsUnlock())
						Else
							UF2->(DisarmTransaction())
						EndIf

					END TRANSACTION

					FwLogMsg("INFO", , "REST", FunName(), "", "01", "Contrato cujo status foi atualizado para 'S'(suspenso) => " + UF2->UF2_CODIGO, 0, (Seconds() - nStart), {})

				Endif

				QRYSUSP->(DbSkip())
			EndDo

			UF2->(DbCloseArea())

			If Select("QRYSUSP") > 0
				QRYSUSP->(DbCloseArea())
			Endif

		Else

			FwLogMsg("WARN", , "REST", FunName(), "", "01", "JOB RFUNE001 desabilitado.", 0, (Seconds() - nStart), {})

		Endif

		RestArea(aAreaUF2)
		RestArea(aArea)

		aArea		:= {}
		aAreaUF2	:= {}

		//-- Libera rotina para nova execução
		//-- Excluir semáforo
		//-- UnLockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> Nil
		UnLockByName("RFUNE001", .F., .T.)

		SM0->(DbSkip())
	EndDo

	FwLogMsg("INFO", , "REST", FunName(), "", "01", "FIM DO JOB RFUNE001 - SUSPENSÃO DE CONTRATO", 0, (Seconds() - nStart), {})

Return(Nil)
