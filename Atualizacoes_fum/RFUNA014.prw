#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RCPGA016
Reprocessa comissao de vendedores (Tabela SE3) dos contratos de Funerario. 

@author Raphael Martins
@since 08/08/2016
@version undefined

@type function
/*/

User Function RFUNA014()

Local oDlgDet     
Local oMemo
Local oFont	
Local cLog    	:= ""
Local cPerg   	:= "RFUNA014"
Local lContinua := .T.
Local cMask		:= ""
Local cFile 	:= "" 

Private dDatDe  := CTOD(" / / ")
Private dDatAt  := CTOD(" / / ")
Private cVenDe  := ""
Private cVenAt  := ""
Private cConDe  := ""
Private cConAt  := ""


Private INCLUI := .F.
Private ALTERA := .T.

	
	AjustaSX1(cPerg)
	
	// enquanto o usu�rio n�o cancelar a tela de perguntas
	While lContinua
		
		// chama a tela de perguntas
		lContinua := Pergunte(cPerg,.T.)
		
		if lContinua 

			cConDe    := MV_PAR01
			cConAt    := MV_PAR02
			dEmisDe   := MV_PAR03
			dEmisAte  := MV_PAR04
			dVencDe	  := MV_PAR05
			dVencAte  := MV_PAR06
			dVendIni  := MV_PAR07
			dVendFim  := MV_PAR08
			
			// Processa comissao do contrato
			FWMsgRun(,{|oSay| Reprocessa(oSay,@cLog) },'Aguarde...','Reprocessamento de Comiss�es de Contratos Funer�rios...')
				 
			If !Empty(cLog)
		
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
			
			
		EndIf
	EndDo
	

Return

//
// Reprocessamento de comiss�es, conforme filtros informados.
//
Static Function Reprocessa(oSay,cLog)

Local cQry 			:= ""
Local cPulaLinha	:= chr(13)+chr(10)
Local lContinua		:= .T.

Private lMsErroAuto := .F.

	cLog += ">> INICIO DO REPROCESSAMENTO DE COMISS�ES" + cPulaLinha
	cLog += cPulaLinha
	
	//
	// 1 - Passo - SELE��O DOS CONTRATOS
	//
	cLog += cPulaLinha
	cLog += "   >> SELE��O DOS CONTRATOS..." + cPulaLinha
	
	cQry := " SELECT UF2_CODIGO " + cPulaLinha
	cQry += "  FROM "+RetSQLName("UF2")+" " + cPulaLinha
	cQry += " WHERE D_E_L_E_T_ = ' ' " + cPulaLinha
	cQry += "  AND UF2_FILIAL = '" + xFilial("UF2") + "' " + cPulaLinha
	cQry += "  AND UF2_CODIGO BETWEEN '"+cConDe+"' AND '" + cConAt + "' " + cPulaLinha
	cQry += "  AND UF2_VEND BETWEEN '"+dVendIni+"' AND '"+dVendFim+"' " + cPulaLinha 
	cQry += "  AND UF2_STATUS IN ('A','S') " + cPulaLinha
	cQry += "  AND UF2_DTATIV BETWEEN '" + DToS(dEmisDe) + "' AND '" + DToS(dEmisAte) + "'" + cPulaLinha
	
	cLog += cPulaLinha
	cLog += " >> FILTROS: "
	cLog += "            >> CONTRATO DE '" + cConDe + "' ATE '" + cConAt + "'" + cPulaLinha
	cLog += "            >> VENDEDOR DE '" + dVendIni + "' ATE '" + dVendFim + "'" + cPulaLinha
	cLog += "            >> DT EMISSAO DE '" + DToC(dEmisDe) + "' ATE '" + DToC(dEmisAte) + "'" + cPulaLinha
	cLog += "            >> DT VENCTO  DE '" + DToC(dVencDe) + "'   ATE '" + DToC(dEmisAte) + "' "+ cPulaLinha
	
	cLog += cPulaLinha
	cLog += " >> QUERY: "
	cLog += cPulaLinha
	cLog += cQry
	cLog += cPulaLinha
	cLog += cPulaLinha
	
	If Select("QRYUF2") > 0
		QRYUF2->(DbCloseArea())
	EndIf
	
	cQry := ChangeQuery(cQry)
	TcQuery cQry New Alias "QRYUF2" // Cria uma nova area com o resultado do query
	
	QRYUF2->( DbGoTop() )
	
	While QRYUF2->(!Eof())
		 
		oSay:cCaption := ("Reprocessando comiss�es do contrato: " + AllTrim(QRYUF2->UF2_CODIGO) + "...")
		ProcessMessages()
		
		cLog += cPulaLinha
		cLog += cPulaLinha
		cLog += " >> INICIO DO PROCESSAMENTO DE COMISSAO DO CONTRATO " + QRYUF2->UF2_CODIGO + " ..." + cPulaLinha
	
		//
		// 2 - Passo - EXCLUSAO DAS COMISSOES EXISTENTES...
		//
		cLog += cPulaLinha
		cLog += "   >> EXCLUS�O DAS COMISS�ES EXISTENTES..." + cPulaLinha
		
		cQry := "SELECT  R_E_C_N_O_ NUM_REGISTRO " + cPulaLinha
		cQry += " FROM " + RetSqlName("SE3") + " SE3" + cPulaLinha
		cQry += " WHERE" + cPulaLinha
		cQry += " SE3.D_E_L_E_T_<> '*'" + cPulaLinha
		cQry += " AND E3_FILIAL = '" + xFilial("SE3") + "'" + cPulaLinha
		cQry += " AND E3_XORIGEM IN ('F')" + cPulaLinha //origem de contrato: "C - Cemiterio" ou "F - Funeraria"
		cQry += " AND E3_XCTRFUN = '" + QRYUF2->UF2_CODIGO + "'" + cPulaLinha
		cQry += " AND E3_EMISSAO BETWEEN '"+DtoS(dEmisDe)+"' AND '"+DtoS(dEmisAte)+"' "
		cQry += " AND E3_VENCTO  BETWEEN '"+DtoS(dVencDe)+"' AND '"+DtoS(dVencAte)+"' "
		cQry += " ORDER BY E3_FILIAL, E3_XCONTRA, E3_VEND, E3_EMISSAO" + cPulaLinha
		
			
		cLog += cPulaLinha
		cLog += " >> FILTROS: "
		cLog += "            >> CONTRATO IGUAL A '" + QRYUF2->UF2_CODIGO + "'" + cPulaLinha
		
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
		
		
		SE3->(DbSetOrder(1)) //E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND
		
		lContinua := .T.
		BeginTran() //controle de transacao
		
		While QRYSE3->(!Eof()) .and. lContinua
		
			//posiciono na SE3
			SE3->(DbGoTo(QRYSE3->NUM_REGISTRO))
	
			cLog += cPulaLinha
			cLog += " >> [EXCLUSAO] - CHAVE DA COMISSAO: RECNO - " + PADL(cValToChar(QRYSE3->NUM_REGISTRO) , 10) + cPulaLinha
			cLog += "   >> E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND = " + SE3->E3_FILIAL + SE3->E3_PREFIXO + SE3->E3_NUM + SE3->E3_PARCELA + SE3->E3_SEQ + SE3->E3_VEND + cPulaLinha
			cLog += "   >> VALOR DA BASE (R$)     = " + PADL(cValToChar(SE3->E3_BASE) , 10) + cPulaLinha 
			cLog += "   >> PERCENTUAL  (%)        = " + PADL(cValToChar(SE3->E3_PORC) , 10) + cPulaLinha
			cLog += "   >> VALOR DA COMISSAO (R$) = " + PADL(cValToChar(SE3->E3_COMIS) , 10) + cPulaLinha
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
			
			MSExecAuto({|x,y| Mata490(x,y)}, aAuto, 5) //Exclus�o de Comiss�o
			
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
		// 3 - Passo - GERA��O DE NOVAS COMISS�ES...
		//
		If lContinua
		
			cLog += cPulaLinha
			cLog += "   >> GERA��O DAS NOVAS COMISS�ES..." + cPulaLinha
			lContinua := U_RFUNA012(QRYUF2->UF2_CODIGO,@cLog)
			
		EndIf
		
		If lContinua
			EndTran() //finaliza a transacao
		Else
			DisarmTransaction() //desarma transa��o
		EndIf
		
		QRYUF2->(DbSkip())

	EndDo
	
	If Select("QRYUF2") > 0
		QRYUF2->(DbCloseArea())
	EndIf
	
	cLog += cPulaLinha
	cLog += ">> FIM REPROCESSAMENTO DE COMISS�ES" + cPulaLinha

Return()


/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͺ��
���Programa  � AjustaSX1 � Autor � Raphael Martins  		   � Data� 03/06/2016 ���
���������������������������������������������������������������������������������ͺ��
���Desc.     � Fun��o que cria as perguntas na SX1.								  ���
���������������������������������������������������������������������������������ͺ��
���Uso       � Vale do Cerrado                    			                      ���
���������������������������������������������������������������������������������ͺ��
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/

Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relat�rio

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

///////////// Contrato ////////////////
U_xPutSX1( cPerg, "01","Do Contrato?","Do Contrato","Do Contrato","cContratoIni","C",6,0,0,"G","","UF2","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "02","At� Contrato?","At� Contrato?","At� Contrato?","cContratoFim","C",6,0,0,"G","","UF2","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

///////////// Intervalo de Emissao ////////////////
U_xPutSX1( cPerg, "03","Da Emiss�o?","Da Emiss�o?","Da Emiss�o?","dEmitDe","D",8,0,0,"G","","","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "04","At� Emiss�o?","At� Emiss�o?","At� Emiss�o?","dEmitAte","D",8,0,0,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)


///////////// Intervalo de Vencimento ////////////////
U_xPutSX1( cPerg, "05","Do Vencimento?","Do Vencimento?","Do Vencimento?","dVencIni","D",8,0,0,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "06","At� Vencimento?","At� Vencimento?","At� Vencimento?","dVencFim","D",8,0,0,"G","","","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)


///////////// Vendedor ////////////////
U_xPutSX1( cPerg, "07","Do Vendedor?","Do Vendedor","Do Vendedor","cVendIni","C",6,0,0,"G","","SA3","","","MV_PAR07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "08","At� Vendedor?","At� Vendedor?","At� Vendedor?","cVendFim","C",6,0,0,"G","","SA3","","","MV_PAR08","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)


Return() 
