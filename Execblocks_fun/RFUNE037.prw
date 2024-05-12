#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} RFUNE037
JOB para reativacao de contratos Suspensos Funeraria
@type function
@version 1.0
@author g.sampaio
@since 12/03/2024
@param aParam, array, parametros da rotina
		aParam[01], character, empresa
		aParam[02], character, filial
/*/
User Function RFUNE037(aParam)

	Local cMessage	:= ""
	Local nStart	:= Seconds()

	//Default aParam 	:= {"01","010101"}
	Default aParam 	:= {"99","01"}

	// mensagens no console log
	FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " ###################################################### ", 0, (nStart - Seconds()), {})
	FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " INICIO DO PROCESSO DE REATIVACAO DE CONTRATOS DE FUNERARIA", 0, (nStart - Seconds()), {})
	FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " DATA: " + DTOC( Date() ) + " HORA: " + Time() + " ", 0, (nStart - Seconds()), {})
	FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " EMPRESA: " + Alltrim(aParam[1]) + " FILIAL: " + Alltrim(aParam[2]) + " ", 0, (nStart - Seconds()), {})
	FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " ###################################################### ", 0, (nStart - Seconds()), {})

	//prepara a conexao com empresa
	RpcSetType(3)
	RpcClearEnv()  //-- Limpa ambiente
	RpcSetEnv(aParam[01], aParam[02])

	//-- Bloqueia rotina para apenas uma execução por vez
	//-- Criação de semáforo no servidor de licenças
	//-- LockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> lCreated
	If !LockByName("RFUNE037", .F., .T.)
		If IsBlind()
			cMessage := "[RFUNE037]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde..."
			FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		Else
			MsgAlert("[RFUNE037]["+ cFilAnt +"] Existe um JOB ativo no momento. Aguarde...")
		EndIf

		Return
	EndIf

	//-- Comando para o TopConnect alterar mensagem do Monitor --//
	FWMonitorMsg("RFUNE037: JOB REATIVACAO DE CONTRATOS => " + cEmpAnt + "-" + cFilAnt)

	//funcao para reativar os contratos
	FunReativaContratos()

	//-- Libera rotina para nova execução
	//-- Excluir semáforo
	//-- UnLockByName( cName, lEmpresa, lFilial, [ lMayIUseDisk ] ) --> Nil
	UnLockByName("RFUNE037", .F., .T.)

Return(Nil)

/*/{Protheus.doc} FunReativaContratos
Funcao para reativacao de contratos Suspensos
@type function
@version 1.0
@author g.sampaio
@since 12/03/2024
/*/
Static Function FunReativaContratos()

	Local aArea 	:= GetArea()
	Local aAreaUF2	:= UF2->(GetArea())
	Local cQry 		:= ""
	Local nParcs 	:= SuperGetMv("MV_XPARCFU",.F.,6)
	Local nStart	:= Seconds()
	Local lVencOrig	:= SuperGetMv("MV_XVEORIS",.F.,.T.)

	////////////////////////////////////////////////////////////////////////////////////////////
	////////// CONSULTO CONTRATOS QUE ESTAO SUSPENSOS COM MENOS DE nParcelas EM ABERTO	////////
	////////////////////////////////////////////////////////////////////////////////////////////
	cQry := " SELECT "
	cQry += " UF2_CODIGO CONTRATO  "
	cQry += " FROM  "
	cQry += RetSQLName("UF2") + " UF2 (NOLOCK) "
	cQry += " WHERE "
	cQry += " UF2.D_E_L_E_T_ = ' '  "
	cQry += " AND UF2.UF2_FILIAL = '" + xFilial("UF2")+ "'   "
	cQry += " AND UF2.UF2_STATUS = 'S'  "
	cQry += " AND NOT EXISTS ( SELECT "
	cQry += " 					COUNT(*) VENCIDA  "
	cQry += " 					FROM " + RetSQLName("SE1") + " E1A  "
	cQry += " 					WHERE  "
	cQry += "					E1A.D_E_L_E_T_ = ' ' "
	cQry += "					AND E1A.E1_FILIAL = UF2.UF2_MSFIL "
	cQry += "					AND E1A.E1_XCTRFUN = UF2.UF2_CODIGO "
	cQry += "					AND E1A.E1_SALDO > 0 "

	if !lVencOrig
		cQry += "				AND E1A.E1_VENCTO < '" + DTOS(dDatabase)+ "' "
	else
		cQry += " 				AND E1A.E1_VENCORI	< '"+DToS(dDataBase)+"' "
	endif

	cQry += "					HAVING COUNT(*) >= " + cValToChar(nParcs) + " ) "
	cQry += "ORDER BY CONTRATO DESC  "

	if Select("QRYSUS") > 0
		QRYSUS->(DbCloseArea())
	endif

	// atualizo o log de console
	FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", cQry, 0, (Seconds() - nStart), {})

	cQry := ChangeQuery(cQry)

	MPSysOpenQuery(cQry, "QRYSUS")

	While QRYSUS->(!Eof())

		UF2->(DbSetOrder(1)) //UF2_FILIAL + UF2_CODIGO
		if UF2->( MsSeek(xFilial("UF2")+QRYSUS->CONTRATO) )

			// atualizo o log de console
			FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "REATIVANDO CONTRATO: " + UF2->UF2_CODIGO + "", 0, (Seconds() - nStart), {})

			BEGIN TRANSACTION

				If UF2->(RecLock("UF2",.F.))
					UF2->UF2_STATUS := "A"
					UF2->(MsUnlock())
				Else
					UF2->(DisarmTransaction())
				EndIf

			END TRANSACTION

		endif

		QRYSUS->(DbSkip())
	EndDo

	if Select("QRYSUS") > 0
		QRYSUS->(DbCloseArea())
	endif

	RestArea(aAreaUF2)
	RestArea(aArea)

Return(Nil)
