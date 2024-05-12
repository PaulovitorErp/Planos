#include "totvs.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} RCPGE001
Responsável pela suspensão de Contratos, executado via Schedule
@author TOTVS.
@since 25/04/2016
@version P12
@param Nao recebe parametros
@return nulo
@history 02/06/2020, g.sampaio, VPDV-473 - feito alteracao no inicio do ambiente da empresa
na execucao do JOB.
- Implementado o controle de transacoes.
- Implementado o uso do parametro para considerar o vencimento origial (MV_XVEORIS)
- Implementado o uso do parametro para limpar o bordero dos titulos do contrato de cemiterio (MV_XLBORSC)
- Implementado o uso do parametro para verificar se o modulo de cemiterio esta habilitado (MV_XCEMI)
/*/

/***********************/
User Function RCPGE001(aEmpresas)
/***********************/

	Local cQry 			:= ""
	Local cEmpJob		:= ""
	Local cFilJbo		:= ""
	Local cMessage		:= ""
	Local cExcecoes		:= ""
	Local lExec			:= .F.
	Local lConsVencOri	:= .F.
	Local lLimpaBordero	:= .F.
	Local lCemiterio 	:= .F.
	Local nParcs		:= 0
	Local nStart		:= 0
	Local oVirtusFin	:= Nil

	Default aEmpresas	:= {"99","01"}

	//prepara a conexao com empresa
	RpcSetType(3)
	RpcClearEnv()  //-- Limpa ambiente
	RpcSetEnv(aEmpresas[01], aEmpresas[02])

	FwLogMsg("INFO", , "REST", FunName(), "", "01", "INICIO DO JOB RCPGE001 - SUSPENSÃO DE CONTRATO", 0, (nStart - Seconds()), {})

	//-- Comando para o TopConnect alterar mensagem do Monitor --//
	//FWMonitorMsg("RCPGE001: JOB SUSPENSAO DO CONTRATO DE CEMITERIO")

	While SM0->(!EOF()) .And. SM0->M0_CODIGO <> '99'

		FwLogMsg("INFO", , "REST", FunName(), "", "01", "RCPGE001 - SUSPENSAO DE CONTRATO: EMPRESA: "+SM0->M0_CODIGO+" FILIAL: " + SM0->M0_CODFIL , 0, (nStart - Seconds()), {})

		cEmpJob	:= Alltrim(SM0->M0_CODIGO)
		cFilJbo	:= Alltrim(SM0->M0_CODFIL)

		RpcSetType(3)
		RpcClearEnv()  //-- Limpa ambiente
		RpcSetEnv(cEmpJob, cFilJbo)

		// parametro de execucao do job de suspensao
		lExec := RetParametro("MV_XJOBSUS")

		// parametro do modulo de cemiterio
		lCemiterio := RetParametro("MV_XCEMI")

		// verifico se o parametro de execucao esta ativado e o modulo esta ativo para a filial
		If lExec .And. lCemiterio

			//-- Bloqueia rotina para apenas uma execução por vez
			//-- Criação de semáforo no servidor de licenças
			If !LockByName("RCPGE001", .F., .T.)
				If IsBlind()
					cMessage := "[RCPGE001]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde..."
					FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
				Else
					MsgAlert("[RCPGE001]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde...")
				EndIf

				Loop //-- Pula para proxima empresa
			EndIf

			// crio o objeto da classe de funcoes financeiras do Virtus ERP
			oVirtusFin := VirtusFin():New()

			// parametro para considerar o vencimento original ou real no job de suspensao
			lConsVencOri	:= RetParametro("MV_XVEORIS")

			// paraemtro para determinar se tiro os titulos do bordero quando realizar a suspensao
			lLimpaBordero	:= RetParametro("MV_XLBORSC")

			// parametro para determinar se considera o servicos executados no job de suspensao
			lConsServico	:= RetParametro("MV_XSRVSUS")

			nParcs := RetParametro("MV_XNRPARS")

			cExcecoes	:= RetParametro("MV_XEXCLS")

			If Select("QRYSUSP") > 0
				QRYSUSP->(DbCloseArea())
			Endif

			cQry := " SELECT U00.U00_CODIGO, COUNT(SE1.E1_NUM) "
			cQry += " FROM "+RetSqlName("U00")+" U00 (NOLOCK) "
			cQry += " INNER JOIN "+RetSqlName("SE1")+" SE1 (NOLOCK)" 
			cQry += " ON SE1.D_E_L_E_T_	= ' ' "
			cQry += " AND SE1.E1_FILIAL	= '"+xFilial("SE1")+"' "
			cQry += " AND U00.U00_CODIGO = SE1.E1_XCONTRA"
			cQry += " AND SE1.E1_SALDO	> 0 " //Em aberto

			// considero o vencimento original
			If lConsVencOri

				cQry += " AND SE1.E1_VENCORI	< '"+DToS(dDataBase)+"'"

			Else // vencimento real

				cQry += " AND SE1.E1_VENCREA 	< '"+DToS(dDataBase)+"'"

			EndIf

			// ignoro os seguintes titulos no momento da suspensao de contratos
			cQry += " AND SE1.E1_TIPO NOT IN ('AB-','FB-','FC-','FU-' " 
			cQry += " ,'PR','IR-','IN-','IS-','PI-','CF-','CS-','FE-' "	
			cQry += " ,'IV-','RA','NCC','NDC') "						

			cQry += " WHERE U00.D_E_L_E_T_ 	= ' '"
			cQry += " AND U00.U00_FILIAL 	= '"+xFilial("U00")+"'"
			cQry += " AND U00.U00_STATUS	= 'A'" //Ativo

			// verifico se consideros os apontamentos no job suepensao
			if lConsServico
				cQry += " AND U00.U00_CODIGO NOT IN (SELECT UJV.UJV_CONTRA "
				cQry += " 							FROM "+RetSqlName("UJV")+" UJV"
				cQry += "							WHERE UJV.D_E_L_E_T_	<> '*'"
				cQry += " 							AND UJV.UJV_FILIAL		= '"+xFilial("UJV")+"'"
				cQry += " 							AND UJV.UJV_CONTRA		= U00.U00_CODIGO)"
			endIf

			if !Empty(cExcecoes)

				cQry += " AND U00.U00_CLIENT NOT IN " + FormatIn( AllTrim(cExcecoes),";") "

			endif

			cQry += " GROUP BY U00.U00_CODIGO"
			cQry += " HAVING COUNT(SE1.E1_NUM) >= "+cValToChar(nParcs)+""

			cQry := ChangeQuery(cQry)

			FwLogMsg("INFO", , "REST", FunName(), "", "01", "Query => " + cQry , 0, (nStart - Seconds()), {})

			// executo a query e crio o alias temporario
			MPSysOpenQuery( cQry, 'QRYSUSP' )

			DbSelectArea("U00")

			While QRYSUSP->(!EOF())

				U00->(DbSetOrder(1)) //U00_FILIAL + U00_CODIGO
				If U00->(MsSeek(xFilial("U00")+QRYSUSP->U00_CODIGO))

					RecLock("U00",.F.)
					U00->U00_STATUS := "S" //Suspenso

					// verifico se o campo U00_DTSUSP esta criado no dicionario
					If U00->( FieldPos("U00_DTSUSP") ) > 0
						U00->U00_DTSUSP	:= dDataBase // gravo a data de suspensao
					EndIf

					U00->(MsUnlock())

					// se limpo o bordero na suspensao do contrato
					If lLimpaBordero

						// remove os titulos do contrato do bordero
						oVirtusFin:LimpaBorderoCemiterio( QRYSUSP->U00_CODIGO )

					EndIf

					FwLogMsg("INFO", , "REST", FunName(), "", "01", "Contrato cujo status foi atualizado para 'S'(suspenso) => " + U00->U00_CODIGO , 0, (nStart - Seconds()), {})

				Endif

				QRYSUSP->(DbSkip())
			EndDo

			//-- Libera rotina para nova execução
			//-- Excluir semáforo
			UnLockByName("RCPGE001", .F., .T.)

			If Select("QRYSUSP") > 0
				QRYSUSP->(DbCloseArea())
			Endif
		Else

			FwLogMsg("WARN", , "REST", FunName(), "", "01", "JOB RCPGE001 desabilitado.", 0, (nStart - Seconds()), {})

		Endif

		// reinicio o objeto
		oVirtusFin := Nil

		SM0->(DbSkip())

	EndDo

	FwLogMsg("INFO", , "REST", FunName(), "", "01", "FIM DO JOB RCPGE001 - SUSPENSÃO DE CONTRATO", 0, (nStart - Seconds()), {})

Return(Nil)

/*/{Protheus.doc} RCPGE001
Retorna conteudo do parametro
Funcao é necessario para nao criticar no CodeAnalysis
@author TOTVS.
@since 25/04/2016
@version P12
@param Nao recebe parametros
@return nulo
@history 02/06/2020, g.sampaio, VPDV-473 - alterado a declaracao da variavel cRetorno para
xRetorno devido ela ser iniciado como Nil e durante o programa ser incrementada com valores
de tipos diferentes.
/*/
Static Function RetParametro(cParametro)

	Local xRetorno 		:= Nil

	Default cParametro	:= ""

	// parametro de ativacao do job de suspensao
	if AllTrim(cParametro) == "MV_XJOBSUS"

		xRetorno := SuperGetMv("MV_XJOBSUS",.F.,.T.) //Default ativo

	elseIf AllTrim(cParametro) == "MV_XNRPARS" // parametro de quantidade de parcelas para suspensao

		xRetorno := SuperGetMv("MV_XNRPARS",.F.,6)

	elseIf AllTrim(cParametro) == "MV_XVEORIS" // parametro que para considerar o vencimento original

		xRetorno := SuperGetMv("MV_XVEORIS",.F.,.F.)

	elseIf AllTrim(cParametro) == "MV_XLBORSC"	// parametro de limpeza de bordero dos tiulos de cemiterio

		xRetorno := SuperGetMv("MV_XLBORS",.F.,.F.)

	elseIf AllTrim(cParametro) == "MV_XCEMI"	// parametro de ativacao do modulo de cemiterio

		xRetorno := SuperGetMv("MV_XCEMI",.F.,.F.)

	elseIf AllTrim(cParametro) == "MV_XSRVSUS"	// parametro para determinar se considera o servicos executados no job de suspensao

		xRetorno := SuperGetMv("MV_XSRVSUS",.F.,.F.)

	elseif AllTrim(cParametro) == "MV_XEXCLS" //Parametro para definir execoes de clientes nas suspensoes de contratos

		xRetorno := SuperGetMv("MV_XEXCLS",.F.,"")

	endif

Return(xRetorno)
