#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FILEIO.CH'

Static cJobPref := "JVIRTUS" //prefixo do nome do JOB (UNICO)
Static cJobType := "IPC"
Static cPrefGlb := "CTHRVIRTUS" //prefixo da variável global por JOB/Thread Ex.: "CTHRVIRTUS9834"

/*/{Protheus.doc} RUTILE59
Montitor de JOBs do Virtus: "orquestrador" de execução
Essa rotina faz o controle de execução dos JOBs que estão cadastrados no Agendamento de JOBS (UZG).

Exemplo de configuração do monitor a ser colocado no APPSERVER.INI e ser acionado na sessão ONSTART

;MONITOR DE JOBS DO VIRTUS
[MONITOR_JOB_VIRTUS]
Main=U_RUTILE59
Environment=VIRTUS
nParms=3
Parm1=99
Parm2=01
Parm3=2000

@type function
@author Pablo Nunes
@since 15/07/2022

@param cEmpTrab, characters, grupo de empresa
@param cFilTrab, characters, filiais (separado por ,)
@param cIntervalo, characters, intervalo e milisegundos
/*/
User Function RUTILE59(cEmpTrab, cFilTrab, cIntervalo)

	Local nHandle			   // Indica se o arquivo foi criado
	Local cFileName		:= ""  // Nome do arquivo
	Local nCount 		:= 1   // Contador
	Local cTemp			:= ""  // Temporario
	Local aFiliais   	:= {}  // Filiais
	Local lExProc 		:= .T. // Controla o while do Killapp
	Local lMultFil 		:= .F. // Verifica se eh passado mais de uma filial no parametro
	Local lCriouAmb		:= .F. // Verifica se o PREPARE ENVIRONMENT foi executado
	Local nSleep        := 0   // Utilizado para atribuicao na variavel nIntervalo
	Local nX

	Default cIntervalo := 2000 // Conteudo do terceiro parametro (Parm4 do mp8srv.ini) -> é definido em milissegundos.

//Ajusta o formato de data do Protheus
	SET DATE FORMAT TO "dd/mm/yyyy"
	SET CENTURY ON
	SET DATE BRITISH

//Tratamento caso o quarto parametro seja passado ou nao.
	If ValType(cIntervalo) <> "N"
		nSleep := Val(cIntervalo)
	Else
		nSleep := cIntervalo
	Endif

	While nCount <= Len( cFilTrab )
		cTemp := ""
		While SubStr( cFilTrab, nCount, 1 ) <> "," .AND. nCount <= Len( cFilTrab )
			cTemp += SubStr( cFilTrab, nCount, 1 )
			nCount++
		End
		AADD( aFiliais, { cTemp } )
		nCount++
	EndDo

	nCount := 1

//Verifica o numero de filiais que esta sendo passado.
	If Len(aFiliais) > 1
		lMultFil := .T.
	Endif

	For nX:=1 to Len(aFiliais)
		cFileName := cEmpTrab + aFiliais[ nX ][1] + cJobPref
		FErase("RUTILE59"+cFileName+".WRK")
	Next nX

//Variavel lExProc inicializada como True
	While !KillApp() .AND. lExProc

		cFileName := cEmpTrab + aFiliais[nCount][1] + cJobPref
		If (!lMultFil .AND. lCriouAmb) .OR. (nHandle := MSFCreate("RUTILE59"+cFileName+".WRK")) >= 0
			If lMultFil .OR. !lCriouAmb
				//-- Preparar ambiente local na retagauarda
				//DBCloseAll()
				//RpcClearEnv()
				RPCSetType(3)  // Nao comer licensa //TODO: ao debugar deve-se comentar essa linha...
				RPCSetEnv(cEmpTrab, aFiliais[nCount][1]) //Retirado PREPARE ENVIRONMENT porque em alguns casos trava o JOB

				//TODO: ao debugar descomentar essas linhas
				//cEmpAnt := AllTrim(cEmpTrab)
				//cFilAnt := AllTrim(aFiliais[nCount][1])
				//PREPARE ENVIRONMENT EMPRESA cEmpAnt FILIAL cFilAnt MODULO "FRT" //modulo "FRT" para nao comer licensa

				lCriouAmb := .T.
			Endif

			//
			// Executa o MONITOR DE JOB
			//
			cFilAnt := aFiliais[nCount][1]
			dDataBase := Date() //data corrente
			U_RUTIL59A()

			If ( nSleep > 0 )
				Sleep(nSleep)
			EndIf

			If lMultFil
				FClose(nHandle)
				FErase("RUTILE59"+cFileName+".WRK")
			Endif

		Else
			lRetValue := .F.
			Exit //sai do While
		EndIf

		If nCount < LEN( aFiliais )
			nCount := nCount + 1
		Else
			nCount := 1
		EndIf

	End

	If (!lMultFil .OR. !lExProc)
		RESET ENVIRONMENT
	EndIf

	FClose(nHandle)
	FErase("RUTILE59"+cFileName+".WRK")

Return

/*/{Protheus.doc} RUTIL59A
Controla o inicio e fim dos jobs cadastrados no Agentamento de JOB (UZG)

@type function
@author Pablo Nunes
@since 15/07/2022
/*/
User Function RUTIL59A()

	Local aTmp 		:= {}
	Local aTmp2 	:= {}
	Local aFilProc 	:= {}
	Local aLog		:= {}
	Local nX 		:= 0
	Local cPartName := ""
	Local nSecProc 	:= 0

	DbSelectArea("UZG")
	UZG->(DbSetOrder(3)) //UZG_FILIAL+UZG_RECORR+UZG_CODIGO

	conout(time() + " RUTIL59A [INICIO] ")

	DownThread(cJobPref + "_",.T.) //finaliza todas as threads ociosas

	UZG->(DbGoTop())
	While UZG->(!Eof())

		conout(time() + " RUTIL59A -> " + "CODIGO: [" + AllTrim(UZG->UZG_CODIGO) + "] - JOB: [" + AllTrim(UZG->UZG_ROTINA) + "]")

		If UZG->UZG_STATUS == '1' //1=Habilitado;2=Desabilitado

			cPartName := cJobPref+"_"+AllTrim(UZG->UZG_CODIGO)

			//
			// CONTROLE DE FINALIZAÇÃO DOS JOBS
			//

			If !Empty(UZG->UZG_DTINI) .and. (Empty(UZG->UZG_DTFIM) .or. (DtoS(UZG->UZG_DTFIM)+UZG->UZG_HRFIM) < (DtoS(UZG->UZG_DTINI)+UZG->UZG_HRINI)) ; //job foi inicializado, e ainda não gravado a hora da finalização
				.and. !RetJobAtiv(cPartName) //não esta rodando
				//grava a data/hora que "finalizou' o JOB
				Reclock("UZG",.F.)
				UZG->UZG_DTFIM := Date()
				UZG->UZG_HRFIM := Time()
				UZG->(MsUnLock())
				//grava o LOG para acompanhamento das execuções
				VtLogRec( AllTrim(UZG->UZG_CODIGO), AllTrim(UZG->UZG_ROTINA), AllTrim(UZG->UZG_EMPFIL), .F. )
			EndIf

			//
			// CONTROLE DE INICIALIZACAO DOS JOBS
			//

			If UZG->UZG_RECORR == "D" //D=Diário
			
				//
				// JOB DIARIO - roda apenas uma única vez ao dia, no horário específico em: UZG_HORA
				//
				If (Empty(UZG->UZG_DTINI) .or. (DtoS(Date()) > DtoS(UZG->UZG_DTINI))) .and. (SubStr(Time(),1,5) >= UZG->UZG_HORA) ; //ta na hora de rodar
					.and. !RetJobAtiv(cPartName) //não esta rodando

					aFilProc := {}
					aTmp := StrtoKarr2(UZG->UZG_EMPFIL,";")
					For nX:=1 to Len(aTmp)
						aTmp2 := StrtoKarr2(aTmp[nX],"/")
						If Len(aTmp2) == 2
							aadd(aFilProc,{aTmp2[01],aTmp2[02]})
						EndIf
					Next nX

					//grava o LOG para acompanhamento das execuções
					VtLogRec( AllTrim(UZG->UZG_CODIGO), AllTrim(UZG->UZG_ROTINA), AllTrim(UZG->UZG_EMPFIL), .T., @aLog )

					//executa o job para as filiais listadas
					If U_VJobProc(AllTrim(UZG->UZG_CODIGO),AllTrim(UZG->UZG_ROTINA),aFilProc, @aLog)
						//grava a data/hora que "iniciou' o JOB
						Reclock("UZG",.F.)
						UZG->UZG_DTINI := Date()
						UZG->UZG_HRINI := Time()
						UZG->(MsUnLock())
					EndIf

				EndIf

			ElseIf UZG->UZG_RECORR == "S" //S=Sempre Ativo
			
				//
				// JOB SEMPRE ATIVO - roda constantemente, com intevalos de tempo: UZG_HORA
				//

				nSecProc := 0 //tempo decorrido em segundos a partir do ultimo final de processamento
				If !Empty(UZG->UZG_DTINI) .and. !Empty(UZG->UZG_DTFIM) //calcula o tempo apenas se já finalizou alguma vez
					If UZG->UZG_DTFIM < Date()
						nSecProc := DateDiffDay(UZG->UZG_DTINI,Date()) * 86400 //transforma a diferença de dias em segundos
					EndIf

					If UZG->UZG_HRFIM < Time()
						nSecProc += TimeToSec(Time()) - TimeToSec(UZG->UZG_HRFIM)
					Else
						nSecProc -= TimeToSec(UZG->UZG_HRFIM) - TimeToSec(Time())
					EndIf
				EndIf

				If (Empty(UZG->UZG_DTINI) .or. Empty(UZG->UZG_DTFIM) ; //se nunca inicializou ou nunca finalizou
					.or. nSecProc > TimeToSec(UZG->UZG_HORA+":00")) ; //ou já passou o intervalo
					.and. !RetJobAtiv(cPartName) //e não esta rodando

					aFilProc := {}
					aTmp := StrtoKarr2(UZG->UZG_EMPFIL,";")
					For nX:=1 to Len(aTmp)
						aTmp2 := StrtoKarr2(aTmp[nX],"/")
						If Len(aTmp2) == 2
							aadd(aFilProc,{aTmp2[01],aTmp2[02]})
						EndIf
					Next nX

					//grava o LOG para acompanhamento das execuções
					VtLogRec( AllTrim(UZG->UZG_CODIGO), AllTrim(UZG->UZG_ROTINA), AllTrim(UZG->UZG_EMPFIL), .T., @aLog )

					//executa o job para as filiais listadas
					If U_VJobProc(AllTrim(UZG->UZG_CODIGO),AllTrim(UZG->UZG_ROTINA),aFilProc, @aLog)
						//grava a hora que "startou' o JOB
						Reclock("UZG",.F.)
						UZG->UZG_DTINI := Date()
						UZG->UZG_HRINI := Time()
						UZG->(MsUnLock())
					EndIf

				EndIf

			EndIf

		EndIf

		UZG->(DbSkip())
	EndDo

	conout(time() + " RUTIL59A [FIM]")

Return(Nil)

/*/{Protheus.doc} TimeToSec
Converte um horário (string) em segundos (inteiro).

@type function
@author Pablo Nunes
@since 15/07/2022
@param cTime, character, string do horário no seguinte formato: HH:MM:SS
@return nSeconds, numeric, horário (cTime) quantificado em segundos
/*/
Static Function TimeToSec(cTime)

	Local nHours   := 0 // horas
	Local nMinutes := 0 // minutos
	Local nSeconds := 0 // segundos

	// converte horas, minutos e segundos para valores numéricos
	If Len(cTime) = 8
		// formato "HH:MM:SS"
		nHours   := Val(Substr(cTime, 1, 2)) * 3600
		nMinutes := Val(Substr(cTime, 4, 2)) * 60
		nSeconds := Val(Substr(cTime, 7, 2))
	EndIf

Return (nHours + nMinutes + nSeconds)

/*/{Protheus.doc} VJobProc
Executa o JOB para todas filiais informadas, criando uma thread para cada execução, através do ManualJob

@author Pablo Nunes
@since 15/07/2022
@version 1.0
@return lRet, lógico, se executou ou não
/*/
User Function VJobProc(cJobName,cRotina,aFilProc,aLog)

	Local nMinThread 	:= 1 //Número mínimo de threads do Job
	Local nMaxThread 	:= 1 //Número máximo de threads do Job
	Local nFreThread 	:= 1 //Número mínimo de threads livres do Job
	Local nIncThread 	:= 1 //Número de threads incrementadas/acrescidas no Job quando o minimo livre (nFreThread) for atingido
	Local nI 			:= 0
	Local nY 			:= 0
	Local cAuxJobName 	:= ""
	Local lRet 			:= .F.

	Default aLog		:= {}

	conout(time() + " VJobProc [INICIO] -> " + cJobName)
	conout("ThreadID: [" + cValtochar(ThreadID()) + "]")

	For nY := 1 to Len(aFilProc)

		//TODO: nome do JOB
		cAuxJobName := cJobPref + "_" + AllTrim(cJobName) + "_" + AllTrim(aFilProc[nY][01]) + AllTrim(aFilProc[nY][02])

		If DownThread(cAuxJobName)

			// documentacao da funcao ManualJob: https://tdn.totvs.com/display/tec/ManualJob
			ManualJob(;
				cAuxJobName /*Indica o nome do Job que será executado.*/,;
				GetEnvServer() /*Indica o nome do ambiente em que os Job será executado.*/,;
				cJobType /*Indica o tipo do Job.. Mantenha como Ipc*/,;
				"u_VJobStar" /*Função que será chamada quando uma nova thread subir*/,;
				"u_VJobConn" /*Função que será chamada toda vez que vc mandar um IpcGo para ela*/,;
				"u_VJobExit" /*Função que será invocada quando a thread cair pelo timeout dela*/,;
				AllTrim(aFilProc[nY][01])+CHR(255)+AllTrim(aFilProc[nY][02])+CHR(255)+cAuxJobName+CHR(255) /*Identificador da sessão (SessionKey)*/,;
				120 /*Tempo de inatividade das threads do Job (segundos). Vamos manter 2 minutos. Se não receber nada ela morre*/,;
				nMinThread /*Número mínimo de threads do Job*/,;
				nMaxThread /*Número máximo de threads do Job*/,;
				nFreThread /*Número mínimo de threads livres do Job*/,;
				nIncThread /*Número de threads incrementadas/acrescidas no Job quando o minimo livre (nFreThread) for atingido*/,;
				)

			conout(time() + " ManualJob -> " + cJobName)

			sleep(1000)

			//---------------------------------------------
			// Dispara thread para processamento           
			//---------------------------------------------
			For nI := 1 to 3 //faz 3 tentativas
				If IpcGo(cAuxJobName,AllTrim(cRotina),AllTrim(aFilProc[nY][01]),AllTrim(aFilProc[nY][02])) // se não consegui disparar JOB, aguarda 2 segundos
					lRet := .T.
					conout(time() + " ManualJob [IpcGo] OK -> " + cJobName)
					Exit //sai do For nI
				EndIf
				sleep(2000)
			Next nI

		Else

			Aadd(aLog, " Nao foi possivel encerrar o job em execucao [DownThread] -> " + cAuxJobName)
			conout(time() + " Nao foi possivel encerrar o job em execucao [DownThread] -> " + cAuxJobName)

		EndIf

	Next nY

	conout(time() + " VJobProc [FIM] -> " + cJobName)
	conout("ThreadID: [" + cValtochar(ThreadID()) + "]")

Return(lRet)

/*/{Protheus.doc} VJobStar
Função para iniciar o ambiente pela empresas/filial informada na chamada da MANUALJOB
@type function
@version 1.0
@author Pablo Nunes
@since 07/15/2024
@param cParam, character, parametro para receber a empresa e filial
@return logical, sempre verdadeiro
/*/
User Function VJobStar(cParam)

	Local cGlbName 	:= cPrefGlb+cValToChar(ThreadId()) // define o nome da variavel global para trhead corrente
	Local aParam 	:= {}

	conout("Thread ->> [OCUPADO]")
	conout("Parametros da Rotina: " + cParam)
	PutGlbValue(cGlbName,"1") //thread ->> [OCUPADO]

	aParam := STRTOKARR(cParam,CHR(255))
	cLEmp := aParam[1]
	cLFil := aParam[2]
	//RpcSetType(3)
	//RpcSetEnv(cLEmp,cLFil)
	cUserName := aParam[3]

	//sleep(1000)
	conout(time() + " VJobStar -> " + cUserName)
	conout("ThreadID: [" + cValtochar(ThreadID()) + "]")
	conout("Thread ->> [DISPONÍVEL]")

	PutGlbValue(cGlbName,"0") //thread ->> [DISPONÍVEL]

Return(.T.)

/*/{Protheus.doc} VJobConn
Função a ser executada (ao acionar o IpcGo) pelo MANUALJOB
@type function
@version 1.0
@author Pablo Nunes
@since 15/07/2022
@param xPar01, variant, funcao a ser executada
@param xPar02, variant, empresa a ser executada
@param xPar03, variant, filial
@return logical, sempre verdadeiro
/*/
User Function VJobConn(xPar01,xPar02,xPar03)

	Local cGlbName := cPrefGlb+cValToChar(ThreadId()) // define o nome da variavel global para trhead corrente STATUS do JOB: [OCUPADO]/[DISPONÍVEL]

	If xPar01 == "##QUIT##"
		ClearGlbValue(cGlbName) //limpa a variavel global
		conout(time() + " VJobConn [##QUIT##] -> [" + RetUseVJob(cValtochar(ThreadID())) + "]")
		conout("ThreadID: [" + cValtochar(ThreadID()) + "]")
		KillApp(.T.) //finaliza a thread
	Else
		PutGlbValue(cGlbName,"1") //thread ->> [OCUPADO]
		&(xPar01+"({'"+xPar02+"','"+xPar03+"'})") //executa o JOB
		conout(time() + " VJobConn -> [" + RetUseVJob(cValtochar(ThreadID())) + "]")
		conout("ThreadID: [" + cValtochar(ThreadID()) + "]")
		sleep(2000) //fica 2 segundos dormindo
		KillApp(.T.) //finaliza a thread
	EndIf

	PutGlbValue(cGlbName,"0") //thread ->> [DISPONÍVEL]

Return(.T.)

/*/{Protheus.doc} VJobExit
Função ao encerrar a thread da chamada da MANUALJOB
@type function
@version 1.0
@author Pablo Nunes
@since 15/07/2022
@return logical, sempre verdadeiro
/*/
User Function VJobExit()
	//sleep(1000)
	conout(time() + " VJobExit -> [" + RetUseVJob(cValtochar(ThreadID())) + "]")
	conout("VJobExit -> ThreadID: [" + cValtochar(ThreadID()) + "]")
Return .T.

/*/{Protheus.doc} DownThread
Função que baixa das working thread abertas, onde o controle é feito através de variaveis globais

@author Pablo Nunes
@since 15/07/2022
@version 1.0
@return logico - sempre verdadeiro
/*/
Static Function DownThread(cJobName,lLike)

	Local lLoop
	Local nI
	Local nCntThread
	Local aUsers
	Local cGlbName
	Local cGlbValue
	Local cIDThread
	Local lRet := .T.
	Local nQtdTen := 3 //número do limite tentativas para finalizar as threads

	Default lLike := .F.

	lLoop := .T.
	nI := 0
	aUsers := {}

	While lLoop // loop de controle para encerramento de todas as working threads
		aUsers := GetUserInfoArray() //-> aUsers - array multidimensional com os números e dados de cada uma das threads
		For nI := 1 to len(aUsers)
			If UPPER(aUsers[nI][1]) == UPPER(cJobName) .or. (lLike .and. UPPER(cJobName) $ UPPER(aUsers[nI][1])) // semaforo (aUsers[x][01] - Nome de usuário)
				lRet := .F.
				nCntThread++ // conta qtas working threads abertas
				cIDThread := cValToChar(aUsers[nI][3])  // ID da working thread
				cGlbName := cPrefGlb+cIDThread // define o nome da variavel global
				cGlbValue := GetGlbValue(cGlbName) // Verifica valor da variável
				conout(time() + " DownThread -> [" + UPPER(aUsers[nI][1]) + "] - PROGRAMA [" + AllTrim(UPPER(aUsers[nI][5])) + "]")
				If (cGlbValue == "0") .or. (AllTrim(UPPER(aUsers[nI][5])) == "U_VJOBSTAR") //thread ->> [DISPONÍVEL] ou apenas INICIALIZADA
					If IpcGo(AllTrim(UPPER(aUsers[nI][1])),"##QUIT##")
						lRet := .T.
						conout(time() + " DownThread [##QUIT##] -> [" + UPPER(aUsers[nI][1]) + "]")
					EndIf
				EndIf
			EndIf
		Next nI
		aUsers := aSize(aUsers,0)
		If nCntThread == 0
			lLoop := .F.
		EndIf
		nCntThread := 0
		sleep(1000)
		nQtdTen--
		If (nQtdTen < 0) //limita o total de tentativas pelo nQtdTen
			lLoop := .F.
		EndIf
	EndDo

Return lRet

/*/{Protheus.doc} RetUseVJob
Retorna o nome da thread (nome do JOB), baseado no ID da thread informado
[Nome do JOB]: "JVIRTUS" + "_" + [UZG_CODIGO] + "_" + [EMP] + [FIL]

@author Pablo Nunes
@since 15/07/2022
@version 1.0
@return cUser, character, Nome do JOB
/*/
Static Function RetUseVJob(cIDThread)

	Local cUser := ""
	Local nI := 0
	Local aUsers

	aUsers := GetUserInfoArray() //-> aUsers - array multidimensional com os números e dados de cada uma das threads
	For nI := 1 to len(aUsers)
		If AllTrim(cValToChar(aUsers[nI][3])) == AllTrim(cIDThread) //aUsers[x][03] - ID da Thread
			cUser := AllTrim(UPPER(aUsers[nI][1])) // semaforo (aUsers[x][01] - Nome de usuário)
			Exit //sai do For nI
		EndIf
	Next nI

	aUsers := aSize(aUsers,0)

Return cUser

/*/{Protheus.doc} RetTheaJob
Retorna o ID da thread, baseado no nome da thread (nome do JOB) informado
[Nome do JOB]: "JVIRTUS" + "_" + [UZG_CODIGO] + "_" + [EMP] + [FIL]

@author Pablo Nunes
@since 15/07/2022
@version 1.0
@return cIDThread, character, ID da thread
/*/
Static Function RetTheaJob(cUser)

	Local cIDThread := ""
	Local nI := 0
	Local aUsers

	aUsers := GetUserInfoArray() //-> aUsers - array multidimensional com os números e dados de cada uma das threads
	For nI := 1 to len(aUsers)
		If AllTrim(UPPER(cUser)) == AllTrim(UPPER(aUsers[nI][1])) // semaforo (aUsers[x][01] - Nome de usuário)
			cIDThread := AllTrim(cValToChar(aUsers[nI][3])) //aUsers[x][03] - ID da Thread
			Exit //sai do For nI
		EndIf
	Next nI

	aUsers := aSize(aUsers,0)

Return cIDThread

/*/{Protheus.doc} RetJobAtiv
Retorna existe thread ativa para determinado nome da thread (nome do JOB) informado
[Nome do JOB]: "JVIRTUS" + "_" + [UZG_CODIGO] + "_" + [EMP] + [FIL]

@author Pablo Nunes
@since 15/07/2022
@version 1.0
@return lRet, logic, Verdadeiro, quadno existe thread ativa
/*/
Static Function RetJobAtiv(cUser)

	Local lRet := .F.
	Local nI := 0
	Local aUsers

	aUsers := GetUserInfoArray() //-> aUsers - array multidimensional com os números e dados de cada uma das threads
	For nI := 1 to len(aUsers)
		If AllTrim(UPPER(cUser)) $ AllTrim(UPPER(aUsers[nI][1])) // semaforo (aUsers[x][01] - Nome de usuário)
			lRet := .T.
			Exit //sai do For nI
		EndIf
	Next nI

	aUsers := aSize(aUsers,0)

Return lRet

/*/{Protheus.doc} VtLogRec
Grava o LOG dos processamentos do MONITOR VIRTUS na pasta AUTOCOM

@author Pablo Nunes
@since 15/07/2022
@version 1.0
/*/
Static Function VtLogRec( cArquivo, cRotina, cEmpFil, lInic, aLog)

	Local cDtProc 	:= DtoS(Date())
	Local cLogPath	:= "\AUTOCOM\VIRTUS" + cEmpAnt + StrTran(AllTrim(cFilAnt)," ","")+"\"
	Local lMV_XVTLOGR := SuperGetMV("MV_XVTLOGR",,.T.)	//Grava LOG do Monitor de Jobs

	Default aLog 	:= {}
	Default lInic 	:= .F.

	If lMV_XVTLOGR
		If lInic
			aadd(aLog, cArquivo + " - INICIO")
			aadd(aLog, "[INICIO] Data: " + DtoC(Date()) + " / Hora: " + Time())
			aadd(aLog, "ROTINA: " + cRotina)
			aadd(aLog, "EMPRESA/FILIAL: " + cEmpFil)
		Else
			aadd(aLog, "[FIM] Data: " + DtoC(Date()) + " / Hora: " + Time())
			aadd(aLog, cArquivo + " - FIM")
		EndIf

		U_VtWriteLog(cLogPath + cArquivo + "_" + cDtProc + '.LOG', aLog)

		aLog := {}
	EndIf

Return(Nil)

/*/{Protheus.doc} VtWriteLog
Função criada para a gravação dos Logs do VIRTUS

@author Pablo Nunes
@since 15/07/2022
@version 1.0
/*/
User Function VtWriteLog( cArq, uTexto )

	Local nHandle := 0
	Local nAuxFor := 0
	Local cTexto  := ""

	cArq := StrTran(AllTrim(cArq)," ","")
	If !File( cArq )
		MakeDir( "\AUTOCOM" )
		MakeDir( "\AUTOCOM\VIRTUS" + cEmpAnt + StrTran(AllTrim(cFilAnt)," ","") )
		nHandle := FCreate( cArq )
		FClose( nHandle )
	Endif
	If File( cArq )
		nHandle := FOpen( cArq, 2 )
		FSeek ( nHandle, 0, 2 )			// Posiciona no final do arquivo.
		If ValType(uTexto) == "C"
			cTexto := dtoc(dDataBase) + " " + Time() + " " + uTexto
			FWrite( nHandle, cTexto + CRLF, Len(cTexto) + 2 )
		ElseIf ValType(uTexto) == "A"
			For nAuxFor := 1 to len(uTexto)
				cTexto := dtoc(dDataBase) + " " + Time() + " " + uTexto[nAuxFor]
				FWrite( nHandle, cTexto + CRLF, Len(cTexto) + 2 )
			Next nAuxFor
		EndIf
		FClose( nHandle )
	EndIf

Return Nil
