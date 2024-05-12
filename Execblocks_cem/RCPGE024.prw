#include "totvs.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} RCPGE024
JOB para reativacao de contratos Suspensos
Cemiterio
@author g.sampaio 
@since 23/09/2019
@version P12
@param aEmpresas, array, parametros de dados das empresas 
@return nulo
@history 02/06/2020, g.sampaio, - VPDV-473 -Implementado o uso do parametro para verificar 
se o modulo de cemiterio esta habilitado (MV_XCEMI) 
/*/
User Function RCPGE024(aEmpresas)

    Local lExec         := .T.
    Local lCemiterio    := .F.
    Local nStart        := 0

    //Default aParam  := {"01","010101"}
    Default aEmpresas 	:= {"99","01"}

    // mensagens no console log
    FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " ###################################################### ", 0, (nStart - Seconds()), {}) // O log de Debug somente é ativado pela chave no environment FWLOGMSG_DEBUG=1
    FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " INICIO DO PROCESSO DE REATIVACAO DE CONTRATOS DE CEMITÉRIO", 0, (nStart - Seconds()), {}) // O log de Debug somente é ativado pela chave no environment FWLOGMSG_DEBUG=1
    FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " DATA: " + DTOC( Date() ) + " HORA: " + Time() + " ", 0, (nStart - Seconds()), {}) // O log de Debug somente é ativado pela chave no environment FWLOGMSG_DEBUG=1
    FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " EMPRESA: " + Alltrim(aEmpresas[1]) + " FILIAL: " + Alltrim(aEmpresas[2]) + " ", 0, (nStart - Seconds()), {}) // O log de Debug somente é ativado pela chave no environment FWLOGMSG_DEBUG=1
    FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " ###################################################### ", 0, (nStart - Seconds()), {}) // O log de Debug somente é ativado pela chave no environment FWLOGMSG_DEBUG=1

    //prepara a conexao com empresa
    RpcSetType(3)
    RpcClearEnv()  //-- Limpa ambiente
    RpcSetEnv(aEmpresas[01], aEmpresas[02])

    //-- Comando para o TopConnect alterar mensagem do Monitor --//
    FWMonitorMsg("RCPGE024: JOB DE REATIVAÇÃO DO CONTRATO DE CEMITERIO")

    // pego o conteudo do parametro do job de suspenso
    lExec := SuperGetMv("MV_XJOBSUS",.F.,.T.) //Default ativo

    lCemiterio := SuperGetMv("MV_XCEMI",.F.,.F.) //Default ativo

    // verifico se devo executar o job de reativacao
    If lExec .And. lCemiterio

        //-- Bloqueia rotina para apenas uma execução por vez
        //-- Criação de semáforo no servidor de licenças
        If !LockByName("RCPGE024", .F., .T.)
            If IsBlind()
                cMessage := "[RCPGE024]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde..."
                FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
            Else
                MsgAlert("[RCPGE024]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde...")
            EndIf
        Else

            //funcao para reativar os contratos
            CemReativaContratos()

        EndIf

        //-- Libera rotina para nova execução
        //-- Excluir semáforo
        UnLockByName("RCPGE024", .F., .T.)

    EndIf

Return( Nil )

/*/{Protheus.doc} CemReativaContratos
Funcao para reativacao de contratos Suspensos
cemiterio
@author g.sampaio 
@since 23/09/2019
@version P12
@param Nao recebe parametros
@return nulo
@history 02/06/2020, g.sampaio, - Implementado o uso do parametro para considerar o vencimento origial (MV_XVEORIS)
- Implementado o controle de transacoes.
/*/
Static Function CemReativaContratos()

    Local aArea 	    := GetArea()
    Local aAreaU00	    := U00->( GetArea() )
    Local cQry 		    := ""
    Local nParcs 	    := SuperGetMv("MV_XNRPARS",.F.,6)
    Local lConsVencOri  := SuperGetMv("MV_XVEORIS",.F.,.F.)
    Local nStart        := 0


    // verificpo se o alias esta em uso, e encerro ele
    if Select("QRYSUS") > 0
        QRYSUS->( DbCloseArea() )
    endif

    ////////////////////////////////////////////////////////////////////////////////////////////
    ////////// CONSULTO CONTRATOS QUE ESTAO SUSPENSOS COM MENOS DE nParcelas EM ABERTO	////////
    ////////////////////////////////////////////////////////////////////////////////////////////
    cQry := " SELECT "
    cQry += " U00_CODIGO CONTRATO  "
    cQry += " FROM  "
    cQry += RetSQLName("U00") + " U00 (NOLOCK) "
    cQry += " WHERE "
    cQry += " U00.D_E_L_E_T_ = ' '  "
    cQry += " AND U00.U00_FILIAL = '" + xFilial("U00")+ "'   "
    cQry += " AND U00.U00_STATUS = 'S'  "
    cQry += " AND NOT EXISTS ( SELECT "
    cQry += " 					COUNT(*) VENCIDA  "
    cQry += " 					FROM " + RetSQLName("SE1") + " E1A  "
    cQry += " 					WHERE  "
    cQry += "					E1A.D_E_L_E_T_ = ' ' "
    cQry += "					AND E1A.E1_FILIAL = U00.U00_MSFIL "
    cQry += "					AND E1A.E1_XCONTRA = U00.U00_CODIGO "
    cQry += "					AND E1A.E1_SALDO > 0 "

    // considero o vencimento original
    If lConsVencOri

        cQry += " 				AND E1A.E1_VENCORI	< '"+DToS(dDataBase)+"'"

    Else // vencimento real

        cQry += " 			    AND E1A.E1_VENCTO 	< '"+DToS(dDataBase)+"'"

    EndIf

    cQry += "					HAVING COUNT(*) >= " + cValToChar(nParcs) + " ) "
    cQry += " ORDER BY CONTRATO DESC  "

    // atualizo o log de console
    FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", cQry, 0, (nStart - Seconds()), {}) // O log de Debug somente é ativado pela chave no environment FWLOGMSG_DEBUG=1

    cQry := ChangeQuery(cQry)

    TcQuery cQry NEW Alias "QRYSUS"

    // percorro todos os contratos suspensos que seram reativads
    While QRYSUS->(!Eof())

        // posiciono no registro do contrato de cemiterio
        U00->( DbSetOrder(1) )
        if U00->( MsSeek( xFilial("U00")+QRYSUS->CONTRATO ) )

            // atualizo o log de console
            FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "REATIVANDO CONTRATO: " + U00->U00_CODIGO + "", 0, (nStart - Seconds()), {}) // O log de Debug somente é ativado pela chave no environment FWLOGMSG_DEBUG=1

            // inicio transacao
            BEGIN TRANSACTION

                RecLock( "U00", .F. )

                U00->U00_STATUS := "A" // altero o status para A=Ativo

                U00->( MsUnlock() )

                // fim transacao
            END TRANSACTION

        endif

        // pulo o para o proximo registro
        QRYSUS->( DbSkip() )

    EndDo

    // verificpo se o alias esta em uso, e encerro ele
    if Select("QRYSUS") > 0
        QRYSUS->( DbCloseArea() )
    endif

    RestArea( aAreaU00 )
    RestArea( aArea )

Return( Nil )
