#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RCPGA016
Reprocessa comissao de vendedores (Tabela SE3) dos contratos de cemiterio. 

@author Pablo Cavalcante
@since 14/04/2016
@version undefined

@type function
/*/

Function U_RCPGA016()

Local oButOk
Local oGet1
Local oGet2
Local oGet3
Local oGet4
Local oGet5
Local oGet6
Local oGet7
Local oGet8

Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5

Local nOpc := "0"
Local cLog := ""

Local oProcess
Local lEnd := .F.

Private dDatDe := dDataBase
Private dDatAt := dDataBase
Private cVenDe := Space(tamsx3('E3_VEND')[1])
Private cVenAt := PADR("Z",tamsx3('E3_VEND')[1],"Z")
Private cConDe := Space(tamsx3('E3_XCONTRA')[1])
Private cConAt := PADR("Z",tamsx3('E3_XCONTRA')[1],"Z")
Private cDocDe := Space(9)
Private cDocAt := "ZZZZZZZZZ"

Private INCLUI := .F.
Private ALTERA := .T.

Static oDlg
Static oDlgDet

  DEFINE MSDIALOG oDlg TITLE "Reprocessa Comissões de Vendedores - Contratos" FROM 000, 000  TO 250, 400 COLORS 0, 16777215 PIXEL

    @ 007, 007 SAY oSay2 PROMPT "Filtros para reprocessamento:" SIZE 167, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 025, 007 SAY oSay1 PROMPT "Dt.Emiss:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 024, 035 MSGET oGet1 VAR dDatDe SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 024, 105 MSGET oGet2 VAR dDatAt SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 044, 007 SAY oSay3 PROMPT "Vendedor:" SIZE 026, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 043, 035 MSGET oGet3 VAR cVenDe SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "SA3"
    @ 043, 105 MSGET oGet4 VAR cVenAt SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "SA3"
    @ 063, 007 SAY oSay4 PROMPT "Contrato:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 062, 035 MSGET oGet5 VAR cConDe SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "U00"
    @ 062, 105 MSGET oGet6 VAR cConAt SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "U00"
    //@ 082, 007 SAY oSay5 PROMPT "Nota Fiscal:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    //@ 081, 035 MSGET oGet7 VAR cDocDe SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    //@ 081, 105 MSGET oGet8 VAR cDocAt SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    
    @ 106, 151 BUTTON oButOk PROMPT "OK" SIZE 037, 012 OF oDlg ACTION(nOpc:="1",oDlg:End()) PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED
  
  	If nOpc == "1"
		//MsAguarde({|lFim| UAJUSCOM(@lFim, @cLog) },"Reprocessamento das comissões","Aguarde! Reprocessando a comissões...")  
		
		oProcess := MsNewProcess():New({|lEnd| UAJUSCOM(@oProcess, @lEnd, @cLog) },"Reprocessamento das Comissões - Contratos","Aguarde! Reprocessando as comissões...",.T.) 
		oProcess:Activate()
		
	EndIf
	
	If !Empty(cLog)
		
		cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cLog )
		Define Font oFont Name "Arial" Size 7, 16
		Define MsDialog oDlgDet Title "Log Gerado" From 3, 0 to 340, 417 Pixel

		@ 5, 5 Get oMemo Var cLog Memo Size 200, 145 Of oDlgDet Pixel
		oMemo:bRClicked := { || AllwaysTrue() }
		oMemo:oFont     := oFont

		Define SButton From 153, 175 Type  1 Action oDlgDet:End() Enable Of oDlgDet Pixel // Apaga
		Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
		MemoWrite( cFile, cLog ) ) ) Enable Of oDlgDet Pixel

		Activate MsDialog oDlgDet Center
	
	EndIf

Return

//
// Reprocessamento de comissões, conforme filtros informados.
//
Static Function UAJUSCOM(oProcess, lEnd, cLog)

Local cQry 			:= ""
Local cPulaLinha	:= chr(13)+chr(10)
Local lContinua		:= .T.
Local nCountU00		:= 0
Local nCountSE3		:= 0

Private lMsErroAuto := .F.

	cLog += ">> INICIO DO REPROCESSAMENTO DE COMISSÕES" + cPulaLinha
	cLog += cPulaLinha
	
	//
	// 1 - Passo - SELEÇÃO DOS CONTRATOS
	//
	cLog += cPulaLinha
	cLog += "   >> SELEÇÃO DOS CONTRATOS..." + cPulaLinha
	
	cQry := "SELECT U00.*" + cPulaLinha
	cQry += " FROM " + RetSqlName("U00") + " U00" + cPulaLinha
	cQry += " WHERE" + cPulaLinha
	cQry += " U00.D_E_L_E_T_<> '*'" + cPulaLinha
	cQry += " AND U00_FILIAL = '" + xFilial("U00") + "'" + cPulaLinha
	cQry += " AND U00_CODIGO BETWEEN '" + cConDe + "' AND '" + cConAt + "'" + cPulaLinha
	cQry += " AND U00_VENDED BETWEEN '" + cVenDe + "' AND '" + cVenAt + "'" + cPulaLinha
	cQry += " AND U00_DATA BETWEEN '" + DToS(dDatDe) + "' AND '" + DToS(dDatAt) + "'" + cPulaLinha
	cQry += " AND U00_STATUS IN ('A','F')" //U00_STATUS => P=Pre-cadastrado;A=Ativo;S=Suspenso;C=Cancelado;F=Finalizado
	cQry += " ORDER BY U00_FILIAL, U00_CODIGO, U00_VENDED, U00_DATA" + cPulaLinha
	
	cLog += cPulaLinha
	cLog += " >> FILTROS: "
	cLog += "            >> CONTRATO DE '" + cConDe + "' ATE '" + cConAt + "'" + cPulaLinha
	cLog += "            >> VENDEDOR DE '" + cVenDe + "' ATE '" + cVenAt + "'" + cPulaLinha
	cLog += "            >> DT EMISSAO DE '" + DToC(dDatDe) + "' ATE '" + DToC(dDatAt) + "'" + cPulaLinha
	
	cLog += cPulaLinha
	cLog += " >> QUERY: "
	cLog += cPulaLinha
	cLog += cQry
	cLog += cPulaLinha
	cLog += cPulaLinha
	
	If Select("QRYU00") > 0
		QRYU00->(DbCloseArea())
	EndIf
	
	cQry := ChangeQuery(cQry)
	TcQuery cQry New Alias "QRYU00" // Cria uma nova area com o resultado do query
	
	QRYU00->(dbEval({|| nCountU00++}))
	QRYU00->(dbGoTop())
	
	oProcess:SetRegua1(nCountU00)
	
	While QRYU00->(!Eof())
		
		cLog += cPulaLinha
		cLog += cPulaLinha
		cLog += " >> INICIO DO PROCESSAMENTO DE COMISSAO DO CONTRATO " + QRYU00->U00_CODIGO + " ..." + cPulaLinha
	
		If lEnd	//houve cancelamento do processo
			Exit
		EndIf
	
		oProcess:IncRegua1("Comissões do Contrato: " + QRYU00->U00_CODIGO)
		oProcess:IncRegua2("...")
		
		//
		// 2 - Passo - EXCLUSAO DAS COMISSOES EXISTENTES...
		//
		cLog += cPulaLinha
		cLog += "   >> EXCLUSÃO DAS COMISSÕES EXISTENTES..." + cPulaLinha
		
		cQry := "SELECT SE3.*" + cPulaLinha
		cQry += " FROM " + RetSqlName("SE3") + " SE3" + cPulaLinha
		cQry += " WHERE" + cPulaLinha
		cQry += " SE3.D_E_L_E_T_<> '*'" + cPulaLinha
		cQry += " AND E3_FILIAL = '" + xFilial("SE3") + "'" + cPulaLinha
		//cQry += " AND E3_XORIGEM IN ('C','F')" + cPulaLinha //origem de contrato: "C - Cemiterio" ou "F - Funeraria"
		cQry += " AND E3_XCONTRA = '" + QRYU00->U00_CODIGO + "'" + cPulaLinha
		cQry += " ORDER BY E3_FILIAL, E3_XCONTRA, E3_VEND, E3_EMISSAO" + cPulaLinha
		
		cLog += cPulaLinha
		cLog += " >> FILTROS: "
		cLog += "            >> CONTRATO IGUAL A '" + QRYU00->U00_CODIGO + "'" + cPulaLinha
		
		cLog += cPulaLinha
		cLog += " >> QUERY: "
		cLog += cPulaLinha
		cLog += cQry
		cLog += cPulaLinha
		cLog += cPulaLinha
		
		If Select("QRYSE3") > 0
			QRYSE3->(DbCloseArea())
		EndIf
		
		cQry := ChangeQuery(cQry)
		TcQuery cQry New Alias "QRYSE3" // Cria uma nova area com o resultado do query
		
		QRYSE3->(dbEval({|| nCountSE3++}))
		QRYSE3->(dbGoTop())
		
		oProcess:SetRegua2(nCountU00)
		
		SE3->(DbSetOrder(1)) //E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND
		
		lContinua := .T.
		BeginTran() //controle de transacao
		
		While QRYSE3->(!Eof()) .and. lContinua
		
			If lEnd	//houve cancelamento do processo
				lContinua := .F.
				Exit
			EndIf
	
			oProcess:IncRegua2("Excluindo comissões...")
			
			//posiciono na SE3
			SE3->(DbGoTo(QRYSE3->R_E_C_N_O_))
	
			cLog += cPulaLinha
			cLog += " >> [EXCLUSAO] - CHAVE DA COMISSAO: RECNO - " + PADL(cValToChar(QRYSE3->R_E_C_N_O_) , 10) + cPulaLinha
			cLog += "   >> E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND = " + QRYSE3->E3_FILIAL + QRYSE3->E3_PREFIXO + QRYSE3->E3_NUM + QRYSE3->E3_PARCELA + QRYSE3->E3_SEQ + QRYSE3->E3_VEND + cPulaLinha
			cLog += "   >> VALOR DA BASE (R$)     = " + PADL(cValToChar(QRYSE3->E3_BASE) , 10) + cPulaLinha 
			cLog += "   >> PERCENTUAL  (%)        = " + PADL(cValToChar(QRYSE3->E3_PORC) , 10) + cPulaLinha
			cLog += "   >> VALOR DA COMISSAO (R$) = " + PADL(cValToChar(QRYSE3->E3_COMIS) , 10) + cPulaLinha
			cLog += cPulaLinha
		
			aAuto := {}
			aAdd(aAuto, {"E3_VEND"		, SE3->E3_VEND		,Nil})
			aAdd(aAuto, {"E3_NUM" 		, SE3->E3_NUM		,Nil})
			aAdd(aAuto, {"E3_CODCLI"	, SE3->E3_CODCLI	,Nil})
			aAdd(aAuto, {"E3_LOJA"		, SE3->E3_LOJA		,Nil})
			aAdd(aAuto, {"E3_PREFIXO"	, SE3->E3_PREFIXO	,Nil})
			aAdd(aAuto, {"E3_PARCELA"	, SE3->E3_PARCELA	,Nil})
			aAdd(aAuto, {"E3_TIPO"		, SE3->E3_TIPO		,Nil})
			
			lMsErroAuto := .F.
			
			MSExecAuto({|x,y| Mata490(x,y)}, aAuto, 5) //Exclusão de Comiss„o
			
			If lMsErroAuto
				cLog += MostraErro("\temp") + cPulaLinha
				DisarmTransaction()
				lContinua := .F.
				Exit
			EndIf
	
		QRYSE3->(DbSkip())
		EndDo

		If Select("QRYSE3") > 0
			QRYSE3->(DbCloseArea())
		EndIf
		
		//
		// 3 - Passo - GERAÇÃO DE NOVAS COMISSÕES...
		//
		If lContinua
			
			oProcess:SetRegua2(1)
			
			If lEnd	//houve cancelamento do processo
				lContinua := .F.
				Exit
			EndIf
			
			oProcess:IncRegua2("Gerando novas comissões..." )
			
			cLog += cPulaLinha
			cLog += "   >> GERAÇÃO DAS NOVAS COMISSÕES..." + cPulaLinha
			lContinua := U_RCPGA011(QRYU00->U00_CODIGO, @cLog)
			
		EndIf
		
		If lContinua
			EndTran() //finaliza a transacao
		Else
			DisarmTransaction() //desarma transação
		EndIf
		
	QRYU00->(DbSkip())
	EndDo
	
	If Select("QRYU00") > 0
		QRYU00->(DbCloseArea())
	EndIf
	
	cLog += cPulaLinha
	cLog += ">> FIM REPROCESSAMENTO DE COMISSÕES" + cPulaLinha

Return