#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "fileio.ch"

Static aTagsDin := {}

/*/{Protheus.doc} RUTIL031
JOB para processamento de envio de mensagens Zenvia
@type function
@version 1.0
@author danilo
@since 21/01/2022
@param xParam1, variant, codigo da empresa
@param xParam2, variant, codigo da filial
/*/
User Function RUTIL031(xParam1, xParam2)

	Local cMessage	:= ""
	Local nStart	:= Seconds()
	Local aParam    := {}
	Local lContinua := .T.

	if valtype(xParam1) == "A"
		aParam := aClone(xParam1)
	elseif valtype(xParam1) == "C" .AND. valtype(xParam2) == "C"
		aParam := {xParam1, xParam2}
	elseif IsBlind()
		FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " PARAMETROS DE EMPRESA E FILIAL INVALIDOS ", 0, (nStart - Seconds()), {})
		lContinua := .F.
	else //execucao via interface
		aParam := {cEmpAnt, cFilAnt}
	endif

	If lContinua

		// mensagens no console log
		FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " ###################################################### ", 0, (nStart - Seconds()), {})
		FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " INICIO DO PROCESSO DE ENVIO DE MENSAGENS SMS ZENVIA", 0, (nStart - Seconds()), {})
		FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " DATA: " + DTOC( Date() ) + " HORA: " + Time() + " ", 0, (nStart - Seconds()), {})
		FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " EMPRESA: " + Alltrim(aParam[1]) + " FILIAL: " + Alltrim(aParam[2]) + " ", 0, (nStart - Seconds()), {})
		FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " ###################################################### ", 0, (nStart - Seconds()), {})

		//Valido se a execução é via Job
		If IsBlind()
			//prepara a conexao com empresa
			RpcSetType(3)
			RpcClearEnv()  //-- Limpa ambiente
			RpcSetEnv(aParam[01], aParam[02])
		Else
			if !MsgYesNo("Confirma a execução do JOB de envio de Mensagens?", "Atenção")
				lContinua := .F.
			endif
		Endif

	EndIf

	If lContinua

		//-- Bloqueia rotina para apenas uma execução por vez
		//-- Criação de semáforo no servidor de licenças
		//-- LockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> lCreated
		If !LockByName("RUTIL031", .F., .T.)
			If IsBlind()
				cMessage := "[RUTIL031]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde..."
				FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
			Else
				MsgAlert("[RUTIL031]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde...")
			EndIf

			lContinua := .F.
		EndIf

	EndIf

	If lContinua

		//-- Comando para o TopConnect alterar mensagem do Monitor --//
		FWMonitorMsg("RUTIL031: JOB ENVIO DE MENSAGENS SMS ZENVIA => " + cEmpAnt + "-" + cFilAnt)

		If IsBlind()
			ExecEnv()
		Else
			MsAguarde({|| ExecEnv() },"Aguarde","Processando envio",.F.)
		EndIf

		//-- Libera rotina para nova execução
		//-- Excluir semáforo
		//-- UnLockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> Nil
		UnLockByName("RUTIL031", .F., .T.)

	EndIf

Return(Nil)

/*/{Protheus.doc} ExecEnv
Função que faz a chamada da execução dos envios
@type function
@version 1.0
@author g.sampaio
@since 17/03/2024
/*/
Static Function ExecEnv()

	Private lCancEmu := .F. //flag para cancelar tela do emulador

	Conout("#==============================================================================================#")
	Conout(" Filial: "+cFilAnt+" - Data "+DtoC(Date())+" - Hora "+Time()+" | Inicio do JOB de SMS - ExecEnv")
	Conout("#==============================================================================================#")

	//Função para envio de Mensagens do tipo Cadastral
	EnvCadastral()

	//Função para envio de Mensagens do tipo Contrato
	EnvContratual()

	//Função para envio de Mensagens do tipo Financeiro
	EnvFinanceiro()

	//Função para envio de Mensagens do tipo Serviço
	EnvServico()

	Conout("#==============================================================================================#")
	Conout(" Filial: "+cFilAnt+" - Data "+DtoC(Date())+" - Hora "+Time()+" | Fim do JOB de SMS - ExecEnv")
	Conout("#==============================================================================================#")

Return(Nil)

/*/{Protheus.doc} EnvCadastral
Funcao para envio de mensagens do tipo Cadastral
@type function
@version 1.0
@author danilo
@since 21/01/2022
/*/
Static Function EnvCadastral()

	Local cQry 		:= ""
	Local nStart	:= Seconds()
	Local cDay      := cValToChar(Day(dDataBase))
	Local cMonth    := StrZero(Month(dDataBase),2)
	Local cDDI, cDDD, cTel
	Local cMsg := ""
	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
	Local lEnvSMSTeste  := SuperGetMV("MV_XSMSTST",.F.,.F.)
	Local nQtdSMSTeste  := SuperGetMV("MV_XQTDSMS",.F.,10)
	Local cCpNasc       := SuperGetMV("MV_XZENCDN",,"A1_XDTNASC") //campo data nascimento a usar

	if SA1->(FieldPos(cCpNasc)) == 0 //se o campo do parametor nao existir, jogo o padrao
		cCpNasc := "A1_DTNASC"
	endif

	DbSelectArea("UZE")

	//Verifico se há regras ativas/vigentes do tipo Cadastral a executar
	cQry := " SELECT "
	cQry += " UZE.R_E_C_N_O_ RECUZE "
	cQry += " FROM  "
	cQry += RetSQLName("UZE") + " UZE (NOLOCK) "
	cQry += " WHERE "
	cQry += " UZE.D_E_L_E_T_ = ' '  "
	cQry += " AND UZE.UZE_FILIAL = '" + xFilial("UZE")+ "'   "
	cQry += " AND UZE.UZE_TIPNOT = '1'  " //tipo cadastrais
	cQry += " AND UZE.UZE_STATUS <> '2'  " //status ativo
	cQry += " AND (UZE.UZE_VIGINI = ' ' OR UZE.UZE_VIGINI <= '"+DTOS(dDataBase)+"') "
	cQry += " AND (UZE.UZE_VIGFIN = ' ' OR UZE.UZE_VIGFIN >= '"+DTOS(dDataBase)+"') "

	//verifico o tipo de envio e se tenho que considerar ou nao
	//A=Aniversario;M=Mensalmente;D=Data Fixa
	cQry += " AND (
	cQry += "   UZE.UZE_TIPCAD = 'A' "
	cQry += "   OR (UZE.UZE_TIPCAD = 'M' AND UZE.UZE_DIACAD = "+cDay+" AND (UZE.UZE_MESINI = ' ' OR UZE.UZE_MESINI <= '"+cMonth+"') AND (UZE.UZE_MESFIM = ' ' OR UZE.UZE_MESFIM >= '"+cMonth+"') ) "
	cQry += "   OR (UZE.UZE_TIPCAD = 'D' AND UZE.UZE_DTFIXA = '"+DTOS(dDataBase)+"' ) "
	cQry += " )"

	cQry += " ORDER BY UZE.UZE_CODIGO "

	if Select("QRYUZE") > 0
		QRYUZE->(DbCloseArea())
	endif

	// atualizo o log de console
	FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "QRYUZE: "+cQry, 0, (Seconds() - nStart), {})

	cQry := ChangeQuery(cQry)

	MpSysOpenQuery(cQry, "QRYUZE")

	While QRYUZE->(!Eof())

		UZE->(DbGoTo(QRYUZE->RECUZE))

		cQry := " SELECT "

		If lEnvSMSTeste
			cQry += " TOP "+cValToChar(nQtdSMSTeste)+" "
		EndIf

		cQry += " SA1.R_E_C_N_O_ RECSA1 "
		cQry += " FROM  "
		cQry += RetSQLName("SA1") + " SA1 (NOLOCK) "
		cQry += " WHERE "
		cQry += " SA1.D_E_L_E_T_ = ' '  "
		cQry += " AND SA1.A1_FILIAL = '" + xFilial("SA1")+ "'   "

		if SA1->(FieldPos("A1_XDDDCEL")) > 0 .AND. SA1->(FieldPos("A1_XCEL")) > 0
			cQry += " AND (SA1.A1_XDDDCEL <> ' ' OR SA1.A1_DDD <> ' ')  "
			cQry += " AND (SA1.A1_XCEL <> ' ' OR SA1.A1_TEL <> ' ')   "
		else
			cQry += " AND SA1.A1_DDD <> ' '   "
			cQry += " AND SA1.A1_TEL <> ' '   "
		endif

		if !empty(UZE->UZE_SEXO)
			cQry += " AND SA1.A1_XSEXO = '" + UZE->UZE_SEXO + "'   "
		endif

		if !empty(UZE->UZE_FILCAD)
			cQry += " AND ("+Alltrim(UZE->UZE_FILCAD)+")   "
		endif

		if UZE->UZE_TIPCAD = 'A' //aniversario
			if UZE->UZE_ENVCAD == '1' //no dia
				cQry += " AND SUBSTRING(SA1."+cCpNasc+",5,4) = '" + SubStr(DTOS(dDataBase),5,4) + "'   "
			elseif UZE->UZE_ENVCAD == '2' //dias antes
				cQry += " AND SUBSTRING(SA1."+cCpNasc+",5,4) = '" + SubStr(DTOS(DaySum(dDataBase, UZE->UZE_DIACAD)),5,4) + "'   "
			elseif UZE->UZE_ENVCAD == '3' //dias depois
				cQry += " AND SUBSTRING(SA1."+cCpNasc+",5,4) = '" + SubStr(DTOS(DaySub(dDataBase, UZE->UZE_DIACAD)),5,4) + "'   "
			endif
		endif

		//por ultimo verifico se tem contrato (plano ou cimiterio)
		if lFuneraria
			cQry += " AND ("
			cQry += "   EXISTS ( SELECT UF2.UF2_CODIGO FROM " +RetSQLName("UF2") + " UF2 "
			cQry += "            WHERE UF2.D_E_L_E_T_ = ' ' AND UF2.UF2_FILIAL = '" + xFilial("UF2")+ "' "
			if !empty(UZE->UZE_CADCTR)
				cQry += "        AND UF2.UF2_STATUS = '"+UZE->UZE_CADCTR+"' "
			endif
			cQry += "            AND UF2.UF2_CLIENT = SA1.A1_COD AND UF2.UF2_LOJA = SA1.A1_LOJA ) "
			cQry += " )"
		elseif lCemiterio
			cQry += " AND ("
			cQry += "   EXISTS ( SELECT U00.U00_CODIGO FROM " +RetSQLName("U00") + " U00 "
			cQry += "            WHERE U00.D_E_L_E_T_ = ' ' AND U00.U00_FILIAL = '" + xFilial("U00")+ "' "
			if !empty(UZE->UZE_CADCTR)
				cQry += "        AND U00.U00_STATUS = '"+UZE->UZE_CADCTR+"' "
			endif
			cQry += "            AND U00.U00_CLIENT = SA1.A1_COD AND U00.U00_LOJA = SA1.A1_LOJA ) "
			cQry += " )"
		endif

		cQry += " ORDER BY SA1.A1_COD "

		// atualizo o log de console
		FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "QRYSA1: "+cQry, 0, (Seconds() - nStart), {})

		if Select("QRYSA1") > 0
			QRYSA1->(DbCloseArea())
		endif

		cQry := ChangeQuery(cQry)

		MpSysOpenQuery(cQry, "QRYSA1")

		While QRYSA1->(!Eof())

			Conout("#==========================================================#")
			Conout(" Envio Cadastral - EnvCadastral")
			Conout("#==========================================================#")

			SA1->(DbGoTo(QRYSA1->RECSA1))

			cMsg := UZE->UZE_MSG
			cDDI := SA1->A1_DDI

			cDDD := ""
			cTel := ""

			if SA1->(FieldPos("A1_XCEL")) > 0 .AND. !Empty(SA1->A1_XCEL)
				cTel := SA1->A1_XCEL
				cDDD := SA1->A1_XDDDCEL
			endif

			if empty(cTel) .OR. !ValidaTel(cTel)
				cDDD := SA1->A1_DDD
				cTel := SA1->A1_TEL
			endif

			if ValidaDDI(@cDDI) .AND. ValidaDDD(@cDDD) .AND. ValidaTel(@cTel)
				if ValidaMsg(@cMsg, UZE->UZE_TIPNOT)
					EnviaSMS(cDDI, cDDD, cTel, cMsg, SA1->A1_COD, SA1->A1_LOJA)
				endif
			else
				FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "Envio ignorado para cliente "+Alltrim(SA1->A1_NOME)+" pois formato telefone celular incorreto"  , 0, (Seconds() - nStart), {})
			endif

			QRYSA1->(DbSkip())
		EndDo

		If Select("QRYSA1") > 0
			QRYSA1->(DbCloseArea())
		EndIf

		QRYUZE->(DbSkip())
	EndDo

	If Select("QRYUZE") > 0
		QRYUZE->(DbCloseArea())
	EndIf

Return(Nil)

/*/{Protheus.doc} EnvContratual
Funcao para envio de mensagens do tipo Cadastral
@type function
@version 1.0
@author danilo
@since 27/01/2022
/*/
Static Function EnvContratual()

	Local cQry 		    := ""
	Local cContrato     := ""
	Local nStart	    := Seconds()
	Local cDDI          := ""
	Local cDDD          := ""
	Local cTel          := ""
	Local cMsg          := ""
	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
	Local nParcsF 		:= SuperGetMv("MV_XPARCFU",.F.,6)
	Local lVencOrig	    := SuperGetMv("MV_XVEORIS",.F.,.T.)
	Local nParcsC 		:= SuperGetMv("MV_XNRPARS",.F.,6)
	Local lConsServico	:= SuperGetMv("MV_XSRVSUS",.F.,.T.)
	Local lEnvSMSTeste  := SuperGetMV("MV_XSMSTST",.F.,.F.)
	Local nQtdSMSTeste  := SuperGetMV("MV_XQTDSMS",.F.,10)

	DbSelectArea("UZE")

	//Verifico se há regras ativas/vigentes do tipo Cadastral a executar
	cQry := " SELECT "
	cQry += " UZE.R_E_C_N_O_ RECUZE "
	cQry += " FROM  "
	cQry += RetSQLName("UZE") + " UZE (NOLOCK) "
	cQry += " WHERE "
	cQry += " UZE.D_E_L_E_T_ = ' '  "
	cQry += " AND UZE.UZE_FILIAL = '" + xFilial("UZE")+ "'   "
	cQry += " AND UZE.UZE_TIPNOT = '2'  " //tipo contrato
	cQry += " AND UZE.UZE_STATUS <> '2'  " //status ativo
	cQry += " AND (UZE.UZE_VIGINI = ' ' OR UZE.UZE_VIGINI <= '"+DTOS(dDataBase)+"') "
	cQry += " AND (UZE.UZE_VIGFIN = ' ' OR UZE.UZE_VIGFIN >= '"+DTOS(dDataBase)+"') "
	cQry += " ORDER BY UZE.UZE_CODIGO "

	if Select("QRYUZE") > 0
		QRYUZE->(DbCloseArea())
	endif

	// atualizo o log de console
	FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "QRYUZE: "+cQry, 0, (Seconds() - nStart), {})

	cQry := ChangeQuery(cQry)

	MpSysOpenQuery(cQry, "QRYUZE")

	While QRYUZE->(!Eof())

		UZE->(DbGoTo(QRYUZE->RECUZE))

		if lFuneraria

			cQry := " SELECT "

			If lEnvSMSTeste
				cQry += " TOP "+cValToChar(nQtdSMSTeste)+" "
			EndIf

			cQry += " UF2.R_E_C_N_O_ RECCTR, "
			cQry += " SA1.R_E_C_N_O_ RECSA1 "
			cQry += " FROM "
			cQry += RetSQLName("UF2") + " UF2 (NOLOCK)"
			cQry += " INNER JOIN "
			cQry += RetSQLName("SA1") + " SA1 ON ("
			cQry += " 	A1_FILIAL = '"+ xFilial("SA1") + "'"
			cQry += " 	AND A1_COD = UF2_CLIENT"
			cQry += " 	AND A1_LOJA= UF2_LOJA"
			cQry += " 	AND SA1.D_E_L_E_T_ = ' '"
			cQry += " )"
			cQry += " WHERE "
			cQry += " UF2.D_E_L_E_T_ = ' '  "
			cQry += " AND UF2.UF2_FILIAL = '" + xFilial("UF2")+ "'   "

			if UZE->UZE_TIPCON == '1' //Ativacao do Contrato

				cQry += " AND UF2_STATUS = 'A' "
				if UZE->UZE_ENVCON == '1' //no dia
					cQry += " AND UF2_DTATIV = '" + DTOS(dDataBase) + "'   "
				elseif UZE->UZE_ENVCON == '3' //dias depois
					cQry += " AND UF2_DTATIV = '" + DTOS(DaySub(dDataBase,UZE->UZE_DIACON)) + "'   "
				endif

			elseif UZE->UZE_TIPCON == '2' //Liberação do Contrato

				//*** status não se aplica para funararia ***
				cQry+= " AND 1=2 "  //forço condição falsa para ignorar

			elseif UZE->UZE_TIPCON == '3' //Cancelamento do Contrato

				cQry+= " AND UF2_STATUS = 'C' "

				if UZE->UZE_ENVCON == '1' //no dia
					cQry += " AND UF2_DTCANC = '" + DTOS(dDataBase) + "'   "
				elseif UZE->UZE_ENVCON == '3' //dias depois
					cQry += " AND UF2_DTCANC = '" + DTOS(DaySub(dDataBase,UZE->UZE_DIACON)) + "'   "
				endif

			elseif UZE->UZE_TIPCON == '4' //Suspensao do Contrato

				if UZE->UZE_ENVCON == '1' //no dia
					cQry += " AND UF2_STATUS = 'S' "
					cQry += " AND UF2_DTSUSP = '" + DTOS(dDataBase) + "'   "

				elseif UZE->UZE_ENVCON == '2' //dias antes de suspender

					cQry += " AND UF2_STATUS = 'A' " //ativo

					cQry += " AND ("
					cQry += "   SELECT "
					cQry += "   COUNT(SE1.E1_NUM) AS PARCELAS "
					cQry += "   FROM "
					cQry +=     RetSqlName("SE1")+" SE1  "
					cQry += "   WHERE "
					cQry += "   UF2.UF2_CODIGO = SE1.E1_XCTRFUN "
					cQry += "   AND UF2.UF2_CLIENT  = SE1.E1_CLIENTE "
					cQry += "   AND UF2.UF2_LOJA	= SE1.E1_LOJA "
					cQry += "   AND SE1.E1_SALDO	> 0 " //Em aberto
					cQry += "   AND SE1.E1_FILIAL	= '"+xFilial("SE1")+"' "
					cQry += "   AND SE1.D_E_L_E_T_ = ' '  "
					//valido de considera o vencimento original
					if !lVencOrig
						cQry += " AND SE1.E1_VENCREA <= '"+DToS(DaySum(dDataBase,UZE->UZE_DIACON))+"'"
					else
						cQry += " AND SE1.E1_VENCORI <= '"+DToS(DaySum(dDataBase,UZE->UZE_DIACON))+"'"
					endif

					cQry += " ) >= "+cValToChar(nParcsF)+" "

				elseif UZE->UZE_ENVCON == '3' //dias depois
					cQry += " AND UF2_STATUS = 'S' "
					cQry += " AND UF2_DTSUSP = '" + DTOS(DaySub(dDataBase,UZE->UZE_DIACON)) + "'   "
				endif

			endif

			if !Empty(UZE->UZE_PROCON)
				cQry += " AND UF2.UF2_PLANO IN "+FormatIn(AllTrim(UZE->UZE_PROCON),";") + " "
			endif

		elseif lCemiterio

			cQry := " SELECT "

			If lEnvSMSTeste
				cQry += " TOP "+cValToChar(nQtdSMSTeste)+" "
			EndIf

			cQry += " U00.R_E_C_N_O_ RECCTR, "
			cQry += " SA1.R_E_C_N_O_ RECSA1 "
			cQry += " FROM "
			cQry += RetSQLName("U00") + " U00 (NOLOCK)"
			cQry += " INNER JOIN "
			cQry += RetSQLName("SA1") + " SA1 ON ("
			cQry += " 	A1_FILIAL = '"+ xFilial("SA1") + "'"
			cQry += " 	AND A1_COD = U00_CLIENT"
			cQry += " 	AND A1_LOJA= U00_LOJA"
			cQry += " 	AND SA1.D_E_L_E_T_ = ' '"
			cQry += " )"
			cQry += " WHERE "
			cQry += " U00.D_E_L_E_T_ = ' '  "
			cQry += " AND U00.U00_FILIAL = '" + xFilial("U00")+ "'   "

			if UZE->UZE_TIPCON == '1' //Ativacao do Contrato

				cQry += " AND U00_STATUS = 'A' "
				if UZE->UZE_ENVCON == '1' //no dia
					cQry += " AND U00_DTATIV = '" + DTOS(dDataBase) + "'   "
				elseif UZE->UZE_ENVCON == '3' //dias depois
					cQry += " AND U00_DTATIV = '" + DTOS(DaySub(dDataBase,UZE->UZE_DIACON)) + "'   "
				endif

			elseif UZE->UZE_TIPCON == '2' //Liberação do Contrato

				if UZE->UZE_ENVCON == '1' //no dia
					cQry += " AND U00_DTLIBE = '" + DTOS(dDataBase) + "'   "
				elseif UZE->UZE_ENVCON == '3' //dias depois
					cQry += " AND U00_DTLIBE = '" + DTOS(DaySub(dDataBase,UZE->UZE_DIACON)) + "'   "
				endif

			elseif UZE->UZE_TIPCON == '3' //Cancelamento do Contrato

				cQry+= " AND U00_STATUS = 'C' "

				if UZE->UZE_ENVCON == '1' //no dia
					cQry += " AND U00_DTCANC = '" + DTOS(dDataBase) + "'   "
				elseif UZE->UZE_ENVCON == '3' //dias depois
					cQry += " AND U00_DTCANC = '" + DTOS(DaySub(dDataBase,UZE->UZE_DIACON)) + "'   "
				endif

			elseif UZE->UZE_TIPCON == '4' //Suspensao do Contrato

				if UZE->UZE_ENVCON == '1' //no dia
					cQry += " AND U00_STATUS = 'S' "
					cQry += " AND U00_DTSUSP = '" + DTOS(dDataBase) + "'   "

				elseif UZE->UZE_ENVCON == '2' //dias antes de suspender

					cQry += " AND U00_STATUS = 'A' " //ativo

					// verifico se consideros os apontamentos no job suepensao
					if lConsServico
						cQry += " AND U00.U00_CODIGO NOT IN (SELECT UJV.UJV_CONTRA "
						cQry += " 							FROM "+RetSqlName("UJV")+" UJV"
						cQry += "							WHERE UJV.D_E_L_E_T_	= ' '"
						cQry += " 							AND UJV.UJV_FILIAL		= '"+xFilial("UJV")+"'"
						cQry += " 							AND UJV.UJV_CONTRA		= U00.U00_CODIGO)"
					endIf

					cQry += " AND ("
					cQry += "   SELECT "
					cQry += "   COUNT(SE1.E1_NUM) AS PARCELAS "
					cQry += "   FROM "
					cQry +=     RetSqlName("SE1")+" SE1  "
					cQry += "   WHERE "
					cQry += "   U00.U00_CODIGO = SE1.E1_XCONTRA "
					cQry += "   AND SE1.E1_SALDO	> 0 " //Em aberto
					cQry += "   AND SE1.E1_FILIAL	= '"+xFilial("SE1")+"' "
					cQry += "   AND SE1.D_E_L_E_T_ = ' '  "
					//valido de considera o vencimento original
					if !lVencOrig
						cQry += " AND SE1.E1_VENCREA <= '"+DToS(DaySum(dDataBase,UZE->UZE_DIACON))+"'"
					else
						cQry += " AND SE1.E1_VENCORI <= '"+DToS(DaySum(dDataBase,UZE->UZE_DIACON))+"'"
					endif

					cQry += " ) >= "+cValToChar(nParcsC)+" "

				elseif UZE->UZE_ENVCON == '3' //dias depois
					cQry += " AND U00_STATUS = 'S' "
					cQry += " AND U00_DTSUSP = '" + DTOS(DaySub(dDataBase,UZE->UZE_DIACON)) + "'   "
				endif
			endif

			if !Empty(UZE->UZE_PROCON)
				cQry += " AND U00.U00_PLANO IN "+FormatIn(AllTrim(UZE->UZE_PROCON),";") + " "
			endif

		endif

		if SA1->(FieldPos("A1_XDDDCEL")) > 0 .AND. SA1->(FieldPos("A1_XCEL")) > 0
			cQry += " AND (SA1.A1_XDDDCEL <> ' ' OR SA1.A1_DDD <> ' ')  "
			cQry += " AND (SA1.A1_XCEL <> ' ' OR SA1.A1_TEL <> ' ')   "
		else
			cQry += " AND SA1.A1_DDD <> ' '   "
			cQry += " AND SA1.A1_TEL <> ' '   "
		endif
		if !empty(UZE->UZE_FILCAD)
			cQry += " AND ("+Alltrim(UZE->UZE_FILCAD)+")   "
		endif

		// atualizo o log de console
		FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "QRYCTR: "+cQry, 0, (Seconds() - nStart), {})

		if Select("QRYCTR") > 0
			QRYCTR->(DbCloseArea())
		endif

		cQry := ChangeQuery(cQry)

		MpSysOpenQuery(cQry, "QRYCTR")

		While QRYCTR->(!Eof())

			Conout("#==========================================================#")
			Conout(" Envio Contratual - EnvCadastral")
			Conout("#==========================================================#")

			SA1->(DbGoTo(QRYCTR->RECSA1))
			if lFuneraria
				UF2->(DbGoTo(QRYCTR->RECCTR))
				cContrato := UF2->UF2_CODIGO
				Conout(" >> Envio Contratual - Funeraria <<")
			elseif lCemiterio
				U00->(DbGoTo(QRYCTR->RECCTR))
				cContrato := U00->U00_CODIGO
				Conout(" >> Envio Contratual - Cemiterio <<")
			endif

			cMsg := UZE->UZE_MSG
			cDDI := SA1->A1_DDI

			cDDD := ""
			cTel := ""
			if SA1->(FieldPos("A1_XCEL")) > 0 .AND. !Empty(SA1->A1_XCEL)
				cTel := SA1->A1_XCEL
				cDDD := SA1->A1_XDDDCEL
			endif
			if empty(cTel) .OR. !ValidaTel(cTel)
				cDDD := SA1->A1_DDD
				cTel := SA1->A1_TEL
			endif

			if ValidaDDI(@cDDI) .AND. ValidaDDD(@cDDD) .AND. ValidaTel(@cTel)
				if ValidaMsg(@cMsg, UZE->UZE_TIPNOT)
					EnviaSMS(cDDI, cDDD, cTel, cMsg, SA1->A1_COD, SA1->A1_LOJA, cContrato)
				endif
			else
				FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "Envio ignorado para cliente "+Alltrim(SA1->A1_NOME)+" pois formato telefone celular incorreto"  , 0, (Seconds() - nStart), {})
			endif

			QRYCTR->(DbSkip())
		EndDo

		If Select("QRYCTR") > 0
			QRYCTR->(DbCloseArea())
		EndIf

		QRYUZE->(DbSkip())
	EndDo

	If Select("QRYUZE") > 0
		QRYUZE->(DbCloseArea())
	EndIf

Return(Nil)

/*/{Protheus.doc} EnvFinanceiro
Funcao para envio de mensagens do tipo Financeiro
@type function
@version 1.0
@author danilo
@since 03/02/2022
/*/
Static Function EnvFinanceiro()

	Local cQry 		    := ""
	Local nStart	    := Seconds()
	Local cDDI          := ""
	Local cDDD          := ""
	Local cTel          := ""
	Local cMsg          := ""
	Local cContrato     := ""
	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
	Local lVencOrig	    := SuperGetMv("MV_XVEORIS",.F.,.T.)
	Local lEnvSMSTeste  := SuperGetMV("MV_XSMSTST",.F.,.F.)
	Local nQtdSMSTeste  := SuperGetMV("MV_XQTDSMS",.F.,10)

	DbSelectArea("UZE")

	//Verifico se há regras ativas/vigentes do tipo Financeiro a executar
	cQry := " SELECT "
	cQry += " UZE.R_E_C_N_O_ RECUZE "
	cQry += " FROM  "
	cQry += RetSQLName("UZE") + " UZE (NOLOCK) "
	cQry += " WHERE "
	cQry += " UZE.D_E_L_E_T_ = ' '  "
	cQry += " AND UZE.UZE_FILIAL = '" + xFilial("UZE")+ "'   "
	cQry += " AND UZE.UZE_TIPNOT = '3'  " //tipo financeiro
	cQry += " AND UZE.UZE_STATUS <> '2'  " //status ativo
	cQry += " AND (UZE.UZE_VIGINI = ' ' OR UZE.UZE_VIGINI <= '"+DTOS(dDataBase)+"') "
	cQry += " AND (UZE.UZE_VIGFIN = ' ' OR UZE.UZE_VIGFIN >= '"+DTOS(dDataBase)+"') "
	cQry += " ORDER BY UZE.UZE_CODIGO "

	if Select("QRYUZE") > 0
		QRYUZE->(DbCloseArea())
	endif

	// atualizo o log de console
	FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "QRYUZE: "+cQry, 0, (Seconds() - nStart), {})

	cQry := ChangeQuery(cQry)

	MpSysOpenQuery(cQry, "QRYUZE")

	While QRYUZE->(!Eof())

		UZE->(DbGoTo(QRYUZE->RECUZE))

		if lFuneraria

			cQry := " SELECT "

			If lEnvSMSTeste
				cQry += " TOP "+cValToChar(nQtdSMSTeste)+" "
			EndIf

			if UZE->UZE_TIPFIN == "1" //Qtd Parcelas em Atraso
				cQry += " UF2.R_E_C_N_O_ RECCTR, "
				cQry += " SA1.R_E_C_N_O_ RECSA1 "
			Elseif UZE->UZE_TIPFIN == "2" //Ultima parcela Vencida
				cQry += " UF2.R_E_C_N_O_ RECCTR, "
				cQry += " SA1.R_E_C_N_O_ RECSA1, "
				cQry += " SE1.R_E_C_N_O_ RECSE1 "
			Elseif UZE->UZE_TIPFIN == "3" //Proxima parcela a Vencer
				cQry += " UF2.R_E_C_N_O_ RECCTR, "
				cQry += " SA1.R_E_C_N_O_ RECSA1, "
				cQry += " SE1.R_E_C_N_O_ RECSE1 "
			Endif

			cQry += " FROM "

			cQry += RetSQLName("UF2") + " UF2 (NOLOCK)"

			cQry += " INNER JOIN "
			cQry += RetSQLName("SA1") + " SA1 (NOLOCK) ON SA1.D_E_L_E_T_ = ' '"
			cQry += " 	SA1.A1_FILIAL = '"+ xFilial("SA1") + "'"
			cQry += " 	AND SA1.A1_COD = UF2.UF2_CLIENT"
			cQry += " 	AND SA1.A1_LOJA= UF2.UF2_LOJA"

			cQry += " INNER JOIN "
			cQry += RetSQLName("SE1") + " SE1 (NOLOCK) ON SE1.D_E_L_E_T_ = ' ' "
			cQry += "   AND SE1.E1_FILIAL	= '"+xFilial("SE1")+"' "
			cQry += "   AND SE1.E1_XCTRFUN  = UF2.UF2_CODIGO "
			cQry += "   AND SE1.E1_SALDO	> 0 " //Em aberto

			if UZE->UZE_TIPFIN == "1" //Qtd Parcelas em Atraso

				If !lVencOrig
					cQry += " AND SE1.E1_VENCREA < '" + DToS(dDataBase) + "'"
				Else
					cQry += " AND SE1.E1_VENCORI < '" + DToS(dDataBase) + "'"
				EndIf

			Elseif UZE->UZE_TIPFIN == "2" //Ultima parcela Vencida

				//filtro titulo vencido a X dias
				if !lVencOrig
					if UZE->UZE_ENVFIN == '1' //no dia
						//considero hoje é o primeiro dia de vencido, ou seja, o vencimento do titulo foi ontem
						cQry += " AND SE1.E1_VENCREA = '" + DToS(DaySub(dDataBase,1)) + "'"
					elseif UZE->UZE_ENVFIN == '3' //dias depois
						cQry += " AND SE1.E1_VENCREA = '" + DToS(DaySub(dDataBase, UZE->UZE_DIAFIN)) + "'"
					endif
				else
					if UZE->UZE_ENVFIN == '1' //no dia
						cQry += " AND SE1.E1_VENCORI = '" + DToS(DaySub(dDataBase,1)) + "'"
					elseif UZE->UZE_ENVFIN == '3' //dias depois
						cQry += " AND SE1.E1_VENCORI = '" + DToS(DaySub(dDataBase, UZE->UZE_DIAFIN)) + "'"
					endif
				endif

			Elseif UZE->UZE_TIPFIN == "3" //Proxima parcela a Vencer

				//filtro titulo a X dias de Vencer
				if !lVencOrig
					if UZE->UZE_ENVFIN == '1' //no dia
						cQry += " AND SE1.E1_VENCREA = '" + DToS(dDataBase) + "'"
					elseif UZE->UZE_ENVFIN == '2' //dias antes
						cQry += " AND SE1.E1_VENCREA = '" + DToS(DaySum(dDataBase, UZE->UZE_DIAFIN)) + "'"
					endif
				else
					if UZE->UZE_ENVFIN == '1' //no dia
						cQry += " AND SE1.E1_VENCORI = '"+DToS(dDataBase)+"'"
					elseif UZE->UZE_ENVFIN == '2' //dias antes
						cQry += " AND SE1.E1_VENCORI = '" + DToS(DaySum(dDataBase, UZE->UZE_DIAFIN)) + "'"
					endif
				endif

			Endif

			cQry += " WHERE "
			cQry += " UF2.D_E_L_E_T_ = ' '  "
			cQry += " AND UF2.UF2_FILIAL = '" + xFilial("UF2")+ "'   "

			if !Empty(UZE->UZE_PROFIN)
				cQry += " AND UF2.UF2_PLANO IN "+FormatIn(AllTrim(UZE->UZE_PROFIN),";") + " "
			endif

			if SA1->(FieldPos("A1_XDDDCEL")) > 0 .AND. SA1->(FieldPos("A1_XCEL")) > 0
				cQry += " AND (SA1.A1_XDDDCEL <> ' ' OR SA1.A1_DDD <> ' ')  "
				cQry += " AND (SA1.A1_XCEL <> ' ' OR SA1.A1_TEL <> ' ')   "
			else
				cQry += " AND SA1.A1_DDD <> ' '   "
				cQry += " AND SA1.A1_TEL <> ' '   "
			endif

			if !empty(UZE->UZE_FILCAD)
				cQry += " AND ("+Alltrim(UZE->UZE_FILCAD)+")   "
			endif

			if UZE->UZE_TIPFIN == "1" //Qtd Parcelas em Atraso

				cQry += " GROUP BY UF2.R_E_C_N_O_,  SA1.R_E_C_N_O_ "
				cQry += " HAVING COUNT(*) BETWEEN "+cValToChar(UZE->UZE_QPARDE)+" AND "+cValToChar(UZE->UZE_QPARAT)+" "

				//filtro pelo ultimo vencimento dos titulos vencidos
				if !lVencOrig
					if UZE->UZE_ENVFIN == '1' //no dia
						//considero hoje é o primeiro dia de vencido, ou seja, o vencimento do titulo foi ontem
						cQry += " AND MAX(SE1.E1_VENCREA) = '"+ DToS(DaySub(dDataBase,1)) + "'"
					elseif UZE->UZE_ENVFIN == '3' //dias depois
						cQry += " AND MAX(SE1.E1_VENCREA) = '" + DToS(DaySub(dDataBase, Val(UZE->UZE_DIAFIN))) + "'"
					endif
				else
					if UZE->UZE_ENVFIN == '1' //no dia
						cQry += " AND MAX(SE1.E1_VENCORI) = '" + DToS(DaySub(dDataBase,1)) + "'"
					elseif UZE->UZE_ENVFIN == '3' //dias depois
						cQry += " AND MAX(SE1.E1_VENCORI) = '" + DToS(DaySub(dDataBase, Val(UZE->UZE_DIAFIN))) + "'"
					endif
				endif

			Endif

		elseif lCemiterio

			cQry := " SELECT "

			If lEnvSMSTeste
				cQry += " TOP "+cValToChar(nQtdSMSTeste)+" "
			EndIf

			if UZE->UZE_TIPFIN == "1" //Qtd Parcelas em Atraso
				cQry += " U00.R_E_C_N_O_ RECCTR, "
				cQry += " SA1.R_E_C_N_O_ RECSA1 "
			Elseif UZE->UZE_TIPFIN == "2" //Ultima parcela Vencida
				cQry += " U00.R_E_C_N_O_ RECCTR, "
				cQry += " SA1.R_E_C_N_O_ RECSA1, "
				cQry += " SE1.R_E_C_N_O_ RECSE1 "
			Elseif UZE->UZE_TIPFIN == "3" //Proxima parcela a Vencer
				cQry += " U00.R_E_C_N_O_ RECCTR, "
				cQry += " SA1.R_E_C_N_O_ RECSA1, "
				cQry += " SE1.R_E_C_N_O_ RECSE1 "
			Endif

			cQry += " FROM "
			cQry += RetSQLName("U00") + " U00 (NOLOCK) "

			cQry += " INNER JOIN "
			cQry += RetSQLName("SA1") + " SA1 (NOLOCK) ON SA1.D_E_L_E_T_ = ' '"
			cQry += " 	AND SA1.A1_FILIAL = '"+ xFilial("SA1") + "'"
			cQry += " 	AND SA1.A1_COD = U00.U00_CLIENT"
			cQry += " 	AND SA1.A1_LOJA= U00.U00_LOJA"

			cQry += " INNER JOIN "
			cQry += RetSQLName("SE1") + " SE1 (NOLOCK) ON SE1.D_E_L_E_T_ = ' ' "
			cQry += "   AND SE1.E1_FILIAL	= '"+xFilial("SE1")+"' "
			cQry += "   AND SE1.E1_XCONTRA = U00.U00_CODIGO "
			cQry += "   AND SE1.E1_SALDO	> 0 " //Em aberto

			if UZE->UZE_TIPFIN == "1" //Qtd Parcelas em Atraso

				If !lVencOrig
					cQry += " AND SE1.E1_VENCREA < '" + DToS(dDataBase) + "'"
				Else
					cQry += " AND SE1.E1_VENCORI < '" + DToS(dDataBase) + "'"
				EndIf

			Elseif UZE->UZE_TIPFIN == "2" //Ultima parcela Vencida

				//filtro titulo vencido a X dias
				if !lVencOrig
					if UZE->UZE_ENVFIN == '1' //no dia
						//considero hoje é o primeiro dia de vencido, ou seja, o vencimento do titulo foi ontem
						cQry += " AND SE1.E1_VENCREA = '" + DToS(DaySub(dDataBase,1)) + "'"
					elseif UZE->UZE_ENVFIN == '3' //dias depois
						cQry += " AND SE1.E1_VENCREA = '" + DToS(DaySub(dDataBase, UZE->UZE_DIAFIN)) + "'"
					endif
				else
					if UZE->UZE_ENVFIN == '1' //no dia
						cQry += " AND SE1.E1_VENCORI = '" + DToS(DaySub(dDataBase,1)) + "'"
					elseif UZE->UZE_ENVFIN == '3' //dias depois
						cQry += " AND SE1.E1_VENCORI = '" + DToS(DaySub(dDataBase, UZE->UZE_DIAFIN)) + "'"
					endif
				endif

			Elseif UZE->UZE_TIPFIN == "3" //Proxima parcela a Vencer

				//filtro titulo a X dias de Vencer
				if !lVencOrig
					if UZE->UZE_ENVFIN == '1' //no dia
						cQry += " AND SE1.E1_VENCREA = '" + DToS(dDataBase) + "'"
					elseif UZE->UZE_ENVFIN == '2' //dias antes
						cQry += " AND SE1.E1_VENCREA = '" + DToS(DaySum(dDataBase, UZE->UZE_DIAFIN)) + "'"
					endif
				else
					if UZE->UZE_ENVFIN == '1' //no dia
						cQry += " AND SE1.E1_VENCORI = '"+DToS(dDataBase)+"'"
					elseif UZE->UZE_ENVFIN == '2' //dias antes
						cQry += " AND SE1.E1_VENCORI = '" + DToS(DaySum(dDataBase, UZE->UZE_DIAFIN)) + "'"
					endif
				endif

			Endif

			cQry += " WHERE "
			cQry += " U00.D_E_L_E_T_ = ' '  "
			cQry += " AND U00.U00_FILIAL = '" + xFilial("U00")+ "'   "

			if !Empty(UZE->UZE_PROFIN)
				cQry += " AND U00.U00_PLANO IN "+FormatIn(AllTrim(UZE->UZE_PROFIN),";") + " "
			endif

			if SA1->(FieldPos("A1_XDDDCEL")) > 0 .AND. SA1->(FieldPos("A1_XCEL")) > 0
				cQry += " AND (SA1.A1_XDDDCEL <> ' ' OR SA1.A1_DDD <> ' ')  "
				cQry += " AND (SA1.A1_XCEL <> ' ' OR SA1.A1_TEL <> ' ')   "
			else
				cQry += " AND SA1.A1_DDD <> ' '   "
				cQry += " AND SA1.A1_TEL <> ' '   "
			endif
			if !empty(UZE->UZE_FILCAD)
				cQry += " AND ("+Alltrim(UZE->UZE_FILCAD)+")   "
			endif

			if UZE->UZE_TIPFIN == "1" //Qtd Parcelas em Atraso
				cQry += " GROUP BY U00.R_E_C_N_O_,  SA1.R_E_C_N_O_ "
				cQry += " HAVING COUNT(*) BETWEEN " + cValToChar(UZE->UZE_QPARDE) + " AND " + cValToChar(UZE->UZE_QPARAT) + " "

				//filtro pelo ultimo vencimento dos titulos vencidos
				if !lVencOrig
					if UZE->UZE_ENVFIN == '1' //no dia
						//considero hoje é o primeiro dia de vencido, ou seja, o vencimento do titulo foi ontem
						cQry += " AND MAX(SE1.E1_VENCREA) = '"+ DToS(DaySub(dDataBase,1)) + "'"
					elseif UZE->UZE_ENVFIN == '3' //dias depois
						cQry += " AND MAX(SE1.E1_VENCREA) = '" + DToS(DaySub(dDataBase, Val(UZE->UZE_DIAFIN))) + "'"
					endif
				else
					if UZE->UZE_ENVFIN == '1' //no dia
						cQry += " AND MAX(SE1.E1_VENCORI) = '" + DToS(DaySub(dDataBase,1)) + "'"
					elseif UZE->UZE_ENVFIN == '3' //dias depois
						cQry += " AND MAX(SE1.E1_VENCORI) = '" + DToS(DaySub(dDataBase, Val(UZE->UZE_DIAFIN))) + "'"
					endif
				endif

			Endif

		endif

		// atualizo o log de console
		FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "QRYFIN: "+cQry, 0, (Seconds() - nStart), {})
		Conout( " Envio de SMS - EnvFinanceiro - QRYFIN: "+cQry)

		if Select("QRYFIN") > 0
			QRYFIN->(DbCloseArea())
		endif

		cQry := ChangeQuery(cQry)

		MpSysOpenQuery(cQry, "QRYFIN")

		While QRYFIN->(!Eof())

			Conout("#==========================================================#")
			Conout(" Envio Financeiro - EnvFinanceiro")
			Conout("#==========================================================#")

			cContrato   := ""
			cDDI        := ""
			cDDD        := ""
			cTel        := ""
			cMsg        := ""

			SA1->(DbGoTo(QRYFIN->RECSA1))

			if lFuneraria
				UF2->(DbGoTo(QRYFIN->RECCTR))
				cContrato := UF2->UF2_CODIGO
				Conout(" >> Envio Financeiro - Funeraria <<")
			elseif lCemiterio
				U00->(DbGoTo(QRYFIN->RECCTR))
				cContrato := U00->U00_CODIGO
				Conout(" >> Envio Financeiro - Cemiterio <<")
			endif

			if UZE->UZE_TIPFIN <> "1"
				SE1->(DbGoTo(QRYFIN->RECSE1))
			endif

			cMsg := UZE->UZE_MSG
			cDDI := SA1->A1_DDI

			if SA1->(FieldPos("A1_XCEL")) > 0 .AND. !Empty(SA1->A1_XCEL)
				cTel := SA1->A1_XCEL
				cDDD := SA1->A1_XDDDCEL
			endif

			if Empty(cTel) .OR. !ValidaTel(cTel)
				cDDD := SA1->A1_DDD
				cTel := SA1->A1_TEL
			endif

			if ValidaDDI(@cDDI) .AND. ValidaDDD(@cDDD) .AND. ValidaTel(@cTel)
				if ValidaMsg(@cMsg, UZE->UZE_TIPNOT)
					EnviaSMS(cDDI, cDDD, cTel, cMsg, SA1->A1_COD, SA1->A1_LOJA, cContrato)
				endif
			else
				FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "Envio ignorado para cliente "+Alltrim(SA1->A1_NOME)+" pois formato telefone celular incorreto"  , 0, (Seconds() - nStart), {})
			endif

			QRYFIN->(DbSkip())
		EndDo

		if Select("QRYFIN") > 0
			QRYFIN->(DbCloseArea())
		endif

		QRYUZE->(DbSkip())
	EndDo

	if Select("QRYUZE") > 0
		QRYUZE->(DbCloseArea())
	endif

Return(Nil)

/*/{Protheus.doc} EnvServico
Funcao para envio de mensagens do tipo Serviço
@type function
@version 1.0
@author danilo
@since 11/02/2022
/*/
Static Function EnvServico()

	Local cQry 		    := ""
	Local cFilSrv       := ""
	Local nStart	    := Seconds()
	Local cDDI          := ""
	Local cDDD          := ""
	Local cTel          := ""
	Local cMsg          := ""
	Local cContrato     := ""
	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
	Local lEnvSMSTeste  := SuperGetMV("MV_XSMSTST",.F.,.F.)
	Local nQtdSMSTeste  := SuperGetMV("MV_XQTDSMS",.F.,10)

	DbSelectArea("UZE")

	//Verifico se há regras ativas/vigentes do tipo Serviço a executar
	cQry := " SELECT "
	cQry += " UZE.R_E_C_N_O_ RECUZE "
	cQry += " FROM  "
	cQry += RetSQLName("UZE") + " UZE (NOLOCK) "
	cQry += " WHERE "
	cQry += " UZE.D_E_L_E_T_ = ' '  "
	cQry += " AND UZE.UZE_FILIAL = '" + xFilial("UZE")+ "'   "
	cQry += " AND UZE.UZE_TIPNOT = '4'  " //tipo Serviço
	cQry += " AND UZE.UZE_STATUS <> '2'  " //status ativo
	cQry += " AND (UZE.UZE_VIGINI = ' ' OR UZE.UZE_VIGINI <= '"+DTOS(dDataBase)+"') "
	cQry += " AND (UZE.UZE_VIGFIN = ' ' OR UZE.UZE_VIGFIN >= '"+DTOS(dDataBase)+"') "
	cQry += " ORDER BY UZE.UZE_CODIGO "

	if Select("QRYUZE") > 0
		QRYUZE->(DbCloseArea())
	endif

	// atualizo o log de console
	FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "QRYUZE: "+cQry, 0, (Seconds() - nStart), {})

	cQry := ChangeQuery(cQry)

	MpSysOpenQuery(cQry, "QRYUZE")

	While QRYUZE->(!Eof())

		UZE->(DbGoTo(QRYUZE->RECUZE))

		if lFuneraria

			//monto filtros da regra, para usar nos dois selects da UJ0
			if UZE->UZE_ENVSRV == '1' //no dia
				cFilSrv += " AND UJ0.UJ0_DTCADA = '"+DToS(dDataBase)+"'"
			elseif UZE->UZE_ENVSRV == '2' //dias depois
				cFilSrv += " AND UJ0.UJ0_DTCADA = '"+DToS(DaySub(dDataBase,UZE->UZE_DIASRV))+"'"
			endif
			if !empty(UZE->UZE_SERVIC)
				cFilSrv += " AND EXISTS ("
				cFilSrv += "    SELECT UJ2.UJ2_PRODUT FROM " +RetSQLName("UJ2") + " UJ2 "
				cFilSrv += "    WHERE UJ2.D_E_L_E_T_ = ' ' AND UJ2.UJ2_FILIAL = UJ0.UJ0_FILIAL "
				cFilSrv += "    AND UJ2.UJ2_CODIGO = UJ0.UJ0_CODIGO  "
				cFilSrv += "    AND UJ2.UJ2_PRODUT IN "+FormatIn(AllTrim(UZE->UZE_SERVIC),";") + " "
				cFilSrv += " )"
			endif

			cQry := " SELECT "

			If lEnvSMSTeste
				cQry += " TOP "+cValToChar(nQtdSMSTeste)+" "
			EndIf

			cQry += " TMPUJ0.*, SA1.R_E_C_N_O_ RECSA1 "
			cQry += " FROM  "
			cQry += " ( "
			cQry += "     SELECT UJ0.R_E_C_N_O_ RECSRV, UJ0.UJ0_CLIPV CLIENTE, UJ0.UJ0_LOJAPV AS LOJA, 0 AS RECCTR "
			cQry += "     FROM "+RetSQLName("UJ0")+" UJ0 (NOLOCK) "
			cQry += "     WHERE UJ0.D_E_L_E_T_ = ' ' "
			cQry += "     AND UJ0_FILIAL = '"+ xFilial("UJ0") + "' "
			cQry += "     AND UJ0_CONTRA = ' ' "
			cQry += cFilSrv

			cQry += "     UNION "

			cQry += "     SELECT UJ0.R_E_C_N_O_ RECSRV, UF2.UF2_CLIENT CLIENTE, UF2.UF2_LOJA AS LOJA, UF2.R_E_C_N_O_ RECCTR "
			cQry += "     FROM "+RetSQLName("UJ0")+" UJ0 (NOLOCK) "
			cQry += "     INNER JOIN "+RetSQLName("UF2")+" UF2 ON( "
			cQry += "         UF2_CODIGO = UJ0_CONTRA "
			cQry += "         AND UF2.D_E_L_E_T_ = ' '  "
			cQry += "         AND UF2.UF2_FILIAL = '"+ xFilial("UF2") + "' "
			cQry += "     ) "
			cQry += "     WHERE UJ0.D_E_L_E_T_ = ' ' "
			cQry += "     AND UJ0_FILIAL = '"+ xFilial("UJ0") + "' "
			cQry += cFilSrv

			cQry += " ) TMPUJ0 "

			cQry += " INNER JOIN "+RetSQLName("SA1")+" SA1 ON ( "
			cQry += "   SA1.D_E_L_E_T_ = ' '  "
			cQry += "   AND SA1.A1_FILIAL = '"+ xFilial("SA1") + "'  "
			cQry += "   AND A1_COD = TMPUJ0.CLIENTE "
			cQry += "   AND A1_LOJA = TMPUJ0.LOJA "
			cQry += " ) "

			cQry += " WHERE "
			if SA1->(FieldPos("A1_XDDDCEL")) > 0 .AND. SA1->(FieldPos("A1_XCEL")) > 0
				cQry += " (SA1.A1_XDDDCEL <> ' ' OR SA1.A1_DDD <> ' ')  "
				cQry += " AND (SA1.A1_XCEL <> ' ' OR SA1.A1_TEL <> ' ')   "
			else
				cQry += " SA1.A1_DDD <> ' '   "
				cQry += " AND SA1.A1_TEL <> ' '   "
			endif
			if !empty(UZE->UZE_FILCAD)
				cQry += " AND ("+Alltrim(UZE->UZE_FILCAD)+")   "
			endif

		elseif lCemiterio

			cQry := " SELECT

			If lEnvSMSTeste
				cQry += " TOP "+cValToChar(nQtdSMSTeste)+" "
			EndIf

			cQry += " UJV.R_E_C_N_O_ RECSRV, U00.R_E_C_N_O_ RECCTR, SA1.R_E_C_N_O_ RECSA1 "
			cQry += " FROM "+RetSQLName("UJV")+" UJV (NOLOCK) "

			cQry += " INNER JOIN "+RetSQLName("U00")+" U00 ON( "
			cQry += "     U00_CODIGO = UJV_CONTRA "
			cQry += "     AND U00.D_E_L_E_T_ = ' '  "
			cQry += "     AND U00.U00_FILIAL = '"+ xFilial("U00") + "' "
			cQry += " ) "

			cQry += " INNER JOIN "
			cQry += RetSQLName("SA1") + " SA1 ON ("
			cQry += " 	A1_FILIAL = '"+ xFilial("SA1") + "'"
			cQry += " 	AND A1_COD = U00_CLIENT"
			cQry += " 	AND A1_LOJA= U00_LOJA"
			cQry += " 	AND SA1.D_E_L_E_T_ = ' '"
			cQry += " )"

			cQry += " WHERE UJV.D_E_L_E_T_ = ' ' "
			cQry += " AND UJV_FILIAL = '"+ xFilial("UJV") + "' "

			if UZE->UZE_ENVSRV == '1' //no dia
				cQry += " AND UJV.UJV_DATA = '"+DToS(dDataBase)+"'"
			elseif UZE->UZE_ENVSRV == '2' //dias depois
				cQry += " AND UJV.UJV_DATA = '"+DToS(DaySub(dDataBase,UZE->UZE_DIASRV))+"'"
			endif
			if !empty(UZE->UZE_SERVIC)
				cQry += " AND UJV.UJV_SERVIC IN "+FormatIn(AllTrim(UZE->UZE_SERVIC),";") + " "
			endif

			if SA1->(FieldPos("A1_XDDDCEL")) > 0 .AND. SA1->(FieldPos("A1_XCEL")) > 0
				cQry += " AND (SA1.A1_XDDDCEL <> ' ' OR SA1.A1_DDD <> ' ')  "
				cQry += " AND (SA1.A1_XCEL <> ' ' OR SA1.A1_TEL <> ' ')   "
			else
				cQry += " AND SA1.A1_DDD <> ' '   "
				cQry += " AND SA1.A1_TEL <> ' '   "
			endif

			if !empty(UZE->UZE_FILCAD)
				cQry += " AND ("+Alltrim(UZE->UZE_FILCAD)+")   "
			endif

		endif

		// atualizo o log de console
		FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "QRYSRV: "+cQry, 0, (Seconds() - nStart), {})

		if Select("QRYSRV") > 0
			QRYSRV->(DbCloseArea())
		endif

		cQry := ChangeQuery(cQry)

		MpSysOpenQuery(cQry, "QRYSRV")

		While QRYSRV->(!Eof())

			Conout("#==========================================================#")
			Conout(" Envio Servico - Envservico")
			Conout("#==========================================================#")

			SA1->(DbGoTo(QRYSRV->RECSA1))
			if lFuneraria
				UJ0->(DbGoTo(QRYSRV->RECSRV))
				UF2->(DbGoTo(QRYSRV->RECCTR))
				cContrato := UF2->UF2_CODIGO
				Conout(" >> Envio Servico - Funeraria <<")
			elseif lCemiterio
				UJV->(DbGoTo(QRYSRV->RECSRV))
				U00->(DbGoTo(QRYSRV->RECCTR))
				cContrato := U00->U00_CODIGO
				Conout(" >> Envio Servico - Cemiterio <<")
			endif

			cMsg := UZE->UZE_MSG
			cDDI := SA1->A1_DDI

			cDDD := ""
			cTel := ""
			if SA1->(FieldPos("A1_XCEL")) > 0 .AND. !Empty(SA1->A1_XCEL)
				cTel := SA1->A1_XCEL
				cDDD := SA1->A1_XDDDCEL
			endif
			if empty(cTel) .OR. !ValidaTel(cTel)
				cDDD := SA1->A1_DDD
				cTel := SA1->A1_TEL
			endif

			if ValidaDDI(@cDDI) .AND. ValidaDDD(@cDDD) .AND. ValidaTel(@cTel)
				if ValidaMsg(@cMsg, UZE->UZE_TIPNOT)
					EnviaSMS(cDDI, cDDD, cTel, cMsg, SA1->A1_COD, SA1->A1_LOJA, cContrato)
				endif
			else
				FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "Envio ignorado para cliente "+Alltrim(SA1->A1_NOME)+" pois formato telefone celular incorreto"  , 0, (Seconds() - nStart), {})
			endif

			QRYSRV->(DbSkip())
		EndDo

		If Select("QRYSRV")
			QRYSRV->(DbCloseArea())
		EndIf

		QRYUZE->(DbSkip())
	EndDo

	If Select("QRYUZE")
		QRYUZE->(DbCloseArea())
	EndIf

Return(Nil)

/*/{Protheus.doc} ValidaDDI
Valido e ajusto o formado do DDD informado no cadastro
@type function
@version 1.0
@author g.sampaio
@since 17/03/2024
@param cDDI, character, codigo do DDI
@return logical, retorno logico da funcao
/*/
Static Function ValidaDDI(cDDI)

	Local lRet := .F.
	Local cDDIDef := SuperGetMV("MV_XZENDDI",,"55") //DDI default
	Local nDDI := val(cDDI)

	if nDDI > 0
		cDDI := CValToChar(nDDI)
		lRet := .T.
	elseif val(cDDIDef) > 0
		cDDI := CValToChar(val(cDDIDef))
		lRet := .T.
	endif

Return(lRet)

/*/{Protheus.doc} ValidaDDD
Valido e ajusto o formado do DDD informado no cadastro
@type function
@version 1.0
@author g.sampaio
@since 17/03/2024
@param cDDD, character, codigo do DDD
@return logical, retorno logico da funcao
/*/
Static Function ValidaDDD(cDDD)

	Local lRet := .F.
	Local nDDD := val(cDDD)

	//DDDs definidos pela anatel, inicia com 11 e ultimo 99, ignorando as dezenas (10, 20.. 90)
	if nDDD >= 11 .AND. nDDD <= 99 .AND. nDDD % 10 <> 0
		cDDD := CValToChar(nDDD)
		lRet := .T.
	endif

Return(lRet)

/*/{Protheus.doc} ValidaTel
Valido e ajusto o formado do telefone informado no cadastro
@type function
@version 1.0
@author g.sampaio
@since 17/03/2024
@param cTel, character, numero do telefone
@return logical, retorno logico da funcao
/*/
Static Function ValidaTel(cTel)

	Local lRet := .F.
	Local nQtdDigCel := SuperGetMV("MV_XZENQDC",,9) //define quantidade de digitos tem no numero de telefone celular
	Local nTel := val(cTel)

	if nTel > 0
		cTel := CValToChar(nTel)
		if len(cTel) == nQtdDigCel
			lRet := .T.
		endif
	endif

Return(lRet)

/*/{Protheus.doc} ValidaMsg
Gera mensagem e valida 
@type function
@version 1.0
@author g.sampaio
@since 17/03/2024
@param cMsg, character, mensagem a ser validada
@param cTpMsg, character, tipo da mensagem
@return logical, retorno logico da funcao
/*/
Static Function ValidaMsg(cMsg, cTpMsg)

	Local lRet := .T.
	Local nX

	//limpo aspas
	cMsg := StrTran(cMsg, "'", "")
	cMsg := StrTran(cMsg, '"', "")
	cMsg := StrTran(cMsg, Chr(13)+chr(10), " ")

	//pego lista das tags dinamicas
	if empty(aTagsDin)
		aTagsDin := U_RUTIL31A()
	endif

	for nX := 1 to len(aTagsDin)
		if "{{"+aTagsDin[nX][1]+"}}" $ cMsg
			cMsg := StrTran(cMsg, "{{"+aTagsDin[nX][1]+"}}", &(aTagsDin[nX][3]) )
		endif
	next nX

	cMsg := EncodeUTF8(cMsg)

Return(lRet)

/*/{Protheus.doc} EnviaSMS
Faz o envio do SMS para platafrma Zenvia
@type function
@version 1.0
@author g.sampaio
@since 17/03/2024
@param cDDI, character, codigo do DDI
@param cDDD, character, codigo do DDD
@param cTel, character, numero do telefone
@param cMsg, character, mensagem a ser enviada
@param cCliente, character, codigo do cliente
@param cLoja, character, codigo da loja
@param cContrato, character, codigo do contrato
@return logical, retorno logico da funcao
/*/
Static Function EnviaSMS(cDDI, cDDD, cTel, cMsg, cCliente, cLoja, cContrato)

	Local lRet := .F.
	Local cFrom				    := SuperGetMV("MV_XZENFRO",.F., "") //tbcgestao.smscpaas
	Local cToken				:= SuperGetMV("MV_XZENTOK",.F., "") //n2FD3SA_jzdkpcbonbcdZVpyoVQOHoA1Uqu7
	Local cHost             	:= SuperGetMV("MV_XZENAPI", .F., "https://api.zenvia.com/v2")
	Local lActEmula             := SuperGetMV("MV_XZENEMU",.F.,.F.)
	Local lEnvSMSTeste          := SuperGetMV("MV_XSMSTST",.F.,.F.)
	Local cDDDSMSTeste          := SuperGetMV("MV_XSMSDDD",.F.,"")
	Local cTelSMSTeste          := SuperGetMV("MV_XSMSTEL",.F.,"")
	Local cIntegradorSMS        := SuperGetMV("MV_XINTSMS",.F.,"Z")
	Local cPathSms      	    := SuperGetMV("MV_XPATSMS",.F.,"/channels/sms/messages")
	Local aHeadStr          	:= {}
	Local oRestEnvSMS      	    := Nil
	Local cJSON                 := ""
	Local cIdZenvia             := ""
	Local cStatusEnv            := ""
	Local cResponse             := ""
	Local oResponse         	:= JsonObject():New()

	Conout("#==========================================================#")
	Conout(">> Inicio do Envio de SMS")

	if lActEmula
		lRet := U_RUT031EM("Atencao",cMsg, cDDI+cDDD+cTel)
		cIdZenvia := "EMULADOR"
		cResponse := "EMULADOR"
	else

		If lEnvSMSTeste
			Conout(">> SMS de Teste")
			cDDD    := cDDDSMSTeste
			cTel    := cTelSMSTeste
		EndIf

		///////////////////////////////
		/// ENVIO PARA ZENVIA   //////
		/////////////////////////////
		if cIntegradorSMS == "Z"

			Aadd(aHeadStr, "Content-Type: application/json")
			Aadd(aHeadStr, "X-API-TOKEN: "+cToken)

			cJSON := '{' + ;
				'"from": "'+cFrom+'",' + ;
				'"to": "'+cDDI+cDDD+cTel+'",' + ;
				'"contents": [{' + ;
				'"type": "text",' + ;
				'"text": "'+cMsg+'"' + ;
				'}]' + ;
				'}'

			///////////////////////////////
			/// ENVIO PARA WEBSMS   //////
			/////////////////////////////
		elseif cIntegradorSMS == "W""

			Aadd(aHeadStr, "Content-Type: application/json")

			cJSON := ' { '
			cJSON += '    "hash":"' + cToken + '", '
			cJSON += '    "mensagem":"' + cMsg + '",
			cJSON += '    "acao":"enviar",
			cJSON += '    "numero":[
			cJSON += '        "' +cDDD+cTel +  '"
			cJSON += '    ]
			cJSON += '}

		else
			cJSON := ' [ '
			cJSON += '  {  '
			cJSON += '        "key" : "' + Alltrim(cToken) + '", '
			cJSON += '       "type" : 9, '
			cJSON += '        "number" : ' +cDDD+cTel +  ', '
			cJSON += '        "msg" : "' + cMsg + '" '
			cJSON += '    } '
			cJSON += ' ] '

		endif

		oRestEnvSMS := FWRest():New(cHost)
		oRestEnvSMS:SetPath(cPathSms)
		oRestEnvSMS:SetPostParams( cJSON )

		Conout( " >> Enviando SMS para: " + cDDI+cDDD+cTel)
		Conout( " >> Contrato: " + cContrato)
		Conout( " >> Cliente/Loja: " + cCliente + "/" + cLoja)
		Conout( " >> JSON de Envio: " + cJSON)

		If oRestEnvSMS:Post( aHeadStr )

			Conout( " >> Ok! SMS Enviado - Retorno do Envio: " + oRestEnvSMS:GetResult())

			lRet := .T.
			cResponse := oRestEnvSMS:GetResult()
			oResponse:fromJson(cResponse)
			if cIntegradorSMS == "Z"

				cIdZenvia := oResponse["id"]

				cStatusEnv := iif(empty(cIdZenvia),'2','1')

			elseif cIntegradorSMS == "W"

				if Alltrim(UPPER(oResponse["status"]))  == "SUCESSO"
					cStatusEnv := "1"
				else
					cStatusEnv := "2"
				endif

			else

				if AllTrim(UPPER(oResponse[1]['situacao']))  == "OK"
					cStatusEnv := "1"
				else
					cStatusEnv := "2"
				endif

				cIdZenvia := AllTrim(oResponse[1]['id'])

			endif
		else

			Conout( " >> Erro! SMS Nao enviado - Retorno do Envio: " + oRestEnvSMS:GetResult())

			cStatusEnv  := "2"
			cResponse   := oRestEnvSMS:GetResult()
		endIf

		FreeObj(oResponse)
		FreeObj(oRestEnvSMS)

	endif

	//grava o historico de envio
	if !lActEmula .OR. lRet
		U_RU032GRV(cDDI+cDDD+cTel, cMsg, cIdZenvia, cResponse, cStatusEnv, cCliente, cLoja, cContrato)
	endif

	Conout(">> Fim do Envio de SMS")
	Conout("#==========================================================#")

Return(lRet)

//Funcao para retornar a lista de tags disponiveis para a mensagem
User Function RUTIL31A()
	if empty(aTagsDin)
		LoadTagsDin()
	endif
Return aTagsDin

//-------------------------------------------------------------------
// Função para montagem do array de tags dinamicas
//-------------------------------------------------------------------
Static Function LoadTagsDin()

	Local lPETagZen	:= ExistBlock("RUT31TAG")
	Local aTagsPE := {}

	aTagsDin := {}

	//{Tag, Descricao, Regra ADVPL, Tipo Notificao}
	//em que Tipo Notificacao: 1=Cadastral;2=Contrato;3=Financeiro;4=Servico
	aadd(aTagsDin, {"nome_cliente"      ,"Nome Completo do Cliente"             ,"Alltrim(SA1->A1_NOME)"            , "1234"})
	aadd(aTagsDin, {"nome_reduzido"     ,"Nome Reduzido do Cliente"             ,"Alltrim(SA1->A1_NREDUZ)"          , "1234"})
	aadd(aTagsDin, {"endereco_cliente"  ,"Endereço do Cliente"                  ,"Alltrim(SA1->A1_END)"             , "1234"})
	aadd(aTagsDin, {"nr_contrato"       ,"Número do Contrato"                   ,"GetCtrInfo('nr_contrato')"        , "23"})
	aadd(aTagsDin, {"valor_contrato"    ,"Valor Total do Contrato"              ,"GetCtrInfo('valor_contrato')"     , "23"})
	aadd(aTagsDin, {"produto_plano"     ,"Descricao do Produto/Plano"           ,"GetCtrInfo('produto_plano')"      , "23"})
	aadd(aTagsDin, {"vencimento"        ,"Vencimento da parcela"                ,"GetFinInfo('vencimento')"         , "3"})
	aadd(aTagsDin, {"linha_digitavel"   ,"Linha Digitavel do titulo filtrado"   ,"GetFinInfo('linha_digitavel')"    , "3"})
	aadd(aTagsDin, {"valor_parcela"     ,"Valor da parcela"                     ,"GetFinInfo('valor_parcela')"      , "3"})
	aadd(aTagsDin, {"data_servico"      ,"Data do Serviço Prestado"             ,"GetServInfo('data_servico')"      , "4"})


	//---------------------------------------------------------------------------------
	// PE para alterar ou adicionar tags conforme necessidade do cliente!
	// Posições do array aTagsDin: {Nome da tag, Descrição da tag, Regra ADVPL}
	// Para a Regra ADVPL, quando o programa for executar a troca das tags, pode-se
	// considerar a tabela UZE (cadastro notificacoes) ja posicionada.
	// *** Essa regra deve sempre retornar um conteudo Caractere ***
	//---------------------------------------------------------------------------------
	if lPETagZen
		aTagsPE := ExecBlock("RUT31TAG",.F.,.F.,aTagsDin)
		If ValType(aTagsPE) == "A"
			aTagsDin := aClone(aTagsPE)
		EndIf
	endif

Return

//Funcao para retorno de informacoes do contrato
//Considera-se ja posicionado no registro U00 ou UF2
Static Function GetCtrInfo(cInfo)

	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
	Local cRet := ''

	if lFuneraria
		if cInfo == "nr_contrato"
			cRet := UF2->UF2_CODIGO
		elseif cInfo == "valor_contrato"
			cRet := Alltrim(Transform(UF2->UF2_VALOR,PesqPict("U00","U00_VALOR")))
		elseif cInfo == "produto_plano"
			cRet := Alltrim(Posicione("UF0",1,xFilial("UF0")+UF2->UF2_PLANO,"UF0_DESCRI"))
		endif
	elseif lCemiterio
		if cInfo == "nr_contrato"
			cRet := U00->U00_CODIGO
		elseif cInfo == "valor_contrato"
			cRet := Alltrim(Transform(U00->U00_VALOR,PesqPict("U00","U00_VALOR")))
		elseif cInfo == "produto_plano"
			cRet := Alltrim(Posicione("U05",1,xFilial("U05")+U00->U00_PLANO,"U05_DESCRI"))
		endif
	endif

Return cRet

//Funcao para retorno de informacoes de titulos a receber
//Considera-se ja posicionado no registro SE1
Static Function GetFinInfo(cInfo)

	Local cRet := ''
	Local lVencOrig	    := SuperGetMv("MV_XVEORIS",.F.,.T.)

	if cInfo == "vencimento"
		if !lVencOrig
			cRet := DTOC(SE1->E1_VENCREA)
		else
			cRet := DTOC(SE1->E1_VENCORI)
		endif
	elseif cInfo == "linha_digitavel"
		cRet := Alltrim(SE1->E1_CODBAR)
	elseif cInfo == "valor_parcela"
		cRet := Alltrim(Transform(SE1->E1_VALOR,PesqPict("SE1","E1_VALOR")))
	endif

Return cRet


//Funcao para retorno de informacoes de servicos
//Considera-se ja posicionado no registro UJ0 ou UJV
Static Function GetServInfo(cInfo)

	Local cRet := ''
	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)

	if lFuneraria
		if cInfo == "data_servico"
			cRet := DTOC(UJ0->UJ0_DTCADA)
		endif
	elseif lCemiterio
		if cInfo == "data_servico"
			cRet := DTOC(UJV->UJV_DATA)
		endif
	endif

Return cRet

/* EMULADOR DE ENVIO DE SMS */
User Function RUT031EM(cTitulo, cMsg, cTel)

	Local oGetMsg
	Local cGetMsg := ""
	Local oSButton1
	Local cNomeArq := "zenvia_emulador_"+DTOS(dDataBase)+".log"
	Local cQLin := Chr(13)+Chr(10)
	Private oHelp

	Default cTitulo := "HELP"
	Default cMsg := ""

	cGetMsg := cQLin
	cGetMsg += "Para:" + cTel + cQLin
	cGetMsg += "Mensagem: "+ cMsg + cQLin
	cGetMsg += "Dt/Hora: "+ DTOC(date()) + " " + Time() + cQLin

	if IsBlind()

		CriaLog("\AUTOCOM\ZENVIA\", cNomeArq, cGetMsg)

	elseif !lCancEmu

		DEFINE MSDIALOG oHelp TITLE cTitulo FROM 000, 000  TO 300, 290 COLORS 0, 16777215 PIXEL

		@ 006, 010 SAY "Mensagem" SIZE 031, 007 OF oHelp COLORS 0, 16777215 PIXEL
		@ 014, 010 GET oGetMsg VAR cGetMsg OF oHelp MULTILINE SIZE 125, 100 COLORS 0, 16777215 READONLY NOBORDER PIXEL

		DEFINE SBUTTON oSButton1 FROM 131, 108 TYPE 01 OF oHelp ACTION (oHelp:end()) ENABLE
		DEFINE SBUTTON oSButton2 FROM 131, 070 TYPE 02 OF oHelp ACTION (lCancEmu:=.T.,oHelp:end()) ENABLE

		ACTIVATE MSDIALOG oHelp CENTERED ON INIT (oSButton1:SetFocus())
	endif

Return !lCancEmu


/*/{Protheus.doc} UCriaLog
Cria arquivo de log.

@author Totvs GO
@since 19/01/2015
@version 1.0

@return Nil

@param cPasta, characters, descricao
@param cNomeArq, characters, descricao
@param cTexto, characters, descricao

@type function
/*/
Static Function CriaLog(cPasta,cNomeArq,cTexto)
	Local cFile := cPasta+cNomeArq//"\temp\arquivo.txt"
	Local nHdlFile
	Local lExistDir	:= .T.
	Default lHelp := .T.

	If !ExistDir(cPasta)	// Verifica se existe a pasta.
		nRet := MakeDir( cPasta )	// Cria a pasta.
		If nRet != 0	// Verifica se a pasta foi criada.
			lExistDir	:= .F.
		EndIf
	EndIf

	If lExistDir

		If !File(cFile)	// Verifica se existe o arquivo
			nHdlFile := fCreate(cFile,FC_NORMAL)	// Cria o arquivo
			If nHdlFile == -1
				Return
			EndIf
		Else
			nHdlFile := fOpen(cFile , FO_READWRITE + FO_SHARED)	// Abre o arquivo
			If nHdlFile == -1
				Return
			EndIf
		EndIf

		// Posiciona no fim do arquivo
		FSeek(nHdlFile, 0, FS_END)

		// Escreve o texto mais a quebra de linha CRLF
		fWrite(nHdlFile, cTexto + CRLF)

		fClose(nHdlFile)

	EndIf

Return
