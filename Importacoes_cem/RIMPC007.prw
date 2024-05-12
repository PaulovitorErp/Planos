#Include "protheus.CH"
#include "topconn.ch"

/*/{Protheus.doc} RIMPC007
Rotina de Processamento de Taxa.
de Manutencao 
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User function RIMPC007()

	Local oPanel		:= NIL
	Local oNewPag		:= NIL
	Local oStepWiz 		:= NIL
	Local oDlg 			:= NIL
	Local oPanelBkg		:= NIL

	Private cArqRel		:= Space(300)
	Private cTpContrato	:= ""
	Private cConsIndice	:= ""
	Private nHdlLog		:= 0

	//crio dialog que ira receber o Wizard
	DEFINE DIALOG oDlg TITLE 'Assistente de Processamento de Taxa de Manutenção - Totvs Servicos Postumos' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )

	oDlg:nWidth := 800
	oDlg:nHeight := 620

//crio panel do wizard
	oPanelBkg:= TPanel():New(0,0,"",oDlg,,,,,,300,300)

	oPanelBkg:Align := CONTROL_ALIGN_ALLCLIENT

//instacio o objeto do wizard
	oStepWiz:= FWWizardControl():New(oPanelBkg)//Instancia a classe FWWizard
	oStepWiz:ActiveUISteps()


////////////////////////////////////////////////////////
///crio a pagina 1 do wizard - Instrucoes Iniciais
///////////////////////////////////////////////////////

	oNewPag := oStepWiz:AddStep("1")

//Altero a descrição do step
	oNewPag:SetStepDescription("Instrucoes Iniciais")

//Defino o bloco de construção
	oNewPag:SetConstruction({|Panel|Pag1Intrucoes(Panel)})

//Defino o bloco ao clicar no botão Próxim
	oNewPag:SetNextAction({||.T.})

//Defino o bloco ao clicar no botão Cancelar
	oNewPag:SetCancelAction({||oDlg:End()})

/////////////////////////////////////////////////////////
///crio a pagina 1 do wizard - Relatorio de Processamento
/////////////////////////////////////////////////////////

	oNewPag := oStepWiz:AddStep("1", {|Panel|RelImport(Panel)})

//Altero a descrição do step
	oNewPag:SetStepDescription("Relatorio de Processamento")

	oNewPag:SetNextAction({|| VldArqRel() })

//Defino o bloco ao clicar no botão Cancelar
	oNewPag:SetCancelAction({||oDlg:End()})

/////////////////////////////////////////////////////////
///crio a pagina 5 do wizard - Processamento da Importacao
/////////////////////////////////////////////////////////

	oNewPag := oStepWiz:AddStep("5", {|Panel| TelaResult(Panel) })

//Altero a descrição do step
	oNewPag:SetStepDescription("Processamento de Taxa de Manutencao")

	oNewPag:SetNextAction({||oDlg:End(),.T.})

//Defino o bloco ao clicar no botão Cancelar
	oNewPag:SetCancelAction({||.F.})

	oNewPag:SetCancelWhen({||.F.})

	oNewPag:SetPrevAction({||.F.})

	oStepWiz:Activate()

	ACTIVATE DIALOG oDlg CENTER

	oStepWiz:Destroy()

Return()


/*/{Protheus.doc} Pag1Intrucoes
Instrucoes Iniciais do Wizard de Processametno
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function Pag1Intrucoes(oPanel)

	Local oSay1 		:= NIL
	Local oLgTotvs		:= NIL
	Local oFnt18		:= TFont():New("Arial",,18,,.T.,,,,,.F.,.F.)
	Local oFnt16		:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
	Local cPulaLinha	:= Chr(13) + Chr(10)
	Local cTexto1		:= ""

	//crio a parte superior da tela do wizard
	CriaPartSup(oPanel)

	@ 045 , 020 SAY oSay4 PROMPT "Bem Vindo..." SIZE 200, 010 Font oFnt18 OF oPanel COLORS 0, 16777215 PIXEL

	cTexto1 += "Esta rotina tem como objetivo ajuda-lo no procedimento de reprocessamento de taxa de manutenção para Totvs Serviços Póstumos" + cPulaLinha

	@ 065 , 020 SAY oSay1 PROMPT cTexto1 SIZE 300, 300 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL


Return()
/*/{Protheus.doc} Pag2Layout
Cria parte superior do panel do
wizard com a logo e texto explicativo
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function CriaPartSup(oPanel)

	Local oSay1 		:= NIL
	Local oSay2 		:= NIL
	Local oSay3 		:= NIL
	Local oLgTotvs		:= NIL
	Local oGroup1		:= NIL
	Local oFnt18		:= TFont():New("Arial",,18,,.T.,,,,,.F.,.F.)
	Local oFnt16		:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
	Local nLarguraPnl	:= oPanel:nClientWidth / 2


//carrego a imagem do repositorio 
	@ 003, 003 REPOSITORY oLgTotvs SIZE 90, 90 OF oPanel PIXEL NOBORDER
	oLgTotvs:LoadBmp("APLOGO.JPG")

	@ 005 , 055 SAY oSay1 PROMPT "Atenção!" SIZE 060, 010 Font oFnt18 OF oPanel COLORS 0, 16777215 PIXEL

	@ 020 , 055 SAY oSay2 PROMPT "Siga atentamente os passos para realizar:" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

	@ 030 , 055 SAY oSay3 PROMPT "Processamento de Taxa de Manutenção - Totvs Serviços Póstumos" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

	@ 040 , 020 GROUP oGroup1 TO 042 , nLarguraPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL


Return()

/*/{Protheus.doc} RelImport
Funcao para montar panel de selecao
do arquivo de log a ser gerado do
processamento
@author Raphael Martins
@since 16/01/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function RelImport(oPanel)

	Local cTexto1		:= ""
	Local cImgArq		:= "icone_file.png"
	Local cImgFileHover	:= "icone_file_foco.png"
	Local cCSSBtnFile	:= ""
	Local nLarguraPnl	:= oPanel:nClientWidth / 2
	Local oFnt16		:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
	Local oFnt16N		:= TFont():New("Arial",,16,,.T.,,,,,.F.,.F.)
	Local oArqRel		:= NIL
	Local oBtnRel		:= NIL
	Local oComboCont	:= NIL
	Local oComboCons	:= NIL

//crio a parte superior da tela do wizard
	CriaPartSup(oPanel)

	@ 045 , 020 SAY oSay4 PROMPT "Informe os dados para o processamento" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	cTexto1 := " Após o procedimento o sistema irá gerar um relatório constando todas informações referentes ao processamento.	"

	@ 060 , 020 SAY oSay1 PROMPT cTexto1 SIZE 300, 300 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

	@ 085 , 020 SAY oSay2 PROMPT "Relatório do Processamento:" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 100 , 020 GROUP oGroup1 TO 102 , nLarguraPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL

	@ 110 , 020 SAY oSay3 PROMPT "Diretório:" SIZE 050, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 110 , 070 MSGET oArqRel VAR cArqRel  SIZE 200,010 PIXEL  Font oFnt16 OF oPanel PICTURE "@!"

	@ 132 , 020 SAY oSay2 PROMPT "Contratos a serem processados:" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 149 , 020 GROUP oGroup2 TO 151 , nLarguraPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL

	@ 157 , 020 SAY oSay3 PROMPT "Contratos:" SIZE 050, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 156, 067 MSCOMBOBOX oComboCont VAR cTpContrato ITEMS {"ENDERECADOS","TODOS"} SIZE 080,013 PIXEL OF oPanel

	//@ 157 , 170 SAY oSay3 PROMPT "Considera Indice no Proximo Reajuste:" SIZE 150, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	//@ 156, 297 MSCOMBOBOX oComboCons VAR cConsIndice ITEMS {"S=SIM","N=NAO"} SIZE 050,013 PIXEL OF oPanel


	oBtnRel	:= TButton():New(109,275,"" ,oPanel,{|| cArqRel := cGetFile( '*.csv' , 'Diretorio para salvar o relatorio de processamento', 16, , .F.,GETF_LOCALHARD,.F., .T. ) },22,22,,,.F.,.T.,.F.,,.F.,,,.F. )

	cCSSBtnFile := "QPushButton {"
	cCSSBtnFile += " background-image: url(rpo:" + cImgArq + ");background-repeat: none; margin: 2px;"
	cCSSBtnFile += " border-width: 1px;"
	cCSSBtnFile += " border-radius: 0px;"
	cCSSBtnFile += " }"
	cCSSBtnFile += "QPushButton:hover {"
	cCSSBtnFile += " background-image: url(rpo:" + cImgFileHover + ");background-repeat: none; margin: 2px; cover"
	cCSSBtnFile += " border-width: 1px;"
	cCSSBtnFile += " border-radius: 0px;"
	cCSSBtnFile += "}"

	oBtnRel:SetCss(cCSSBtnFile)

Return()


/*/{Protheus.doc} VldArqRel
Funcao para validar o arquivo digitado para
geracao do relatorio
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

Static Function VldArqRel()

	Local lRet 		:= .T.

	if !Empty(cArqRel)

		//crio arquivo de relatorio do processamento
		nHdlLog := MsfCreate(cArqRel + ".log",0)

		if nHdlLog < 0

			lRet := .F.
			Help(,,'Help',,"Não foi possivel criar o arquivo de relatorio de processamento, favor o diretorio selecionado!",1,0)

		endif

	endif

Return(lRet)

/*/{Protheus.doc} TelaResult
Funcao para montar tela de resultado final
do processamento
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/										
Static Function TelaResult(oPanel)

	Local oSay1 		:= NIL
	Local oSay2 		:= NIL
	Local oGroup1		:= NIL
	Local oProcessados	:= NIL
	Local oSucesso		:= NIL
	Local oFnt16		:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
	Local oFnt16N		:= TFont():New("Arial",,16,,.T.,,,,,.F.,.F.)
	Local nLarguraPnl	:= oPanel:nClientWidth / 2
	Local cPulaLinha	:= Chr(13) + Chr(10)
	Local cTexto1		:= ""
	Local nRowsProces	:= 0

//crio a parte superior da tela do wizard
	CriaPartSup(oPanel)

	FWMsgRun(,{|oSay| ProcessaTxMnt(oSay,@nRowsProces)},'Aguarde...','Processando Taxa de Manutenção - Totvs Serviços Póstumos.')

	@ 045 , 020 SAY oSay4 PROMPT "Processo de geração de histórico de taxa de manutenção" SIZE 300, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	cTexto1 := "Processo finalizado, abaixo segue os dados processados com sucesso!	" + cPulaLinha

	@ 060 , 020 SAY oSay1 PROMPT cTexto1 SIZE 300, 300 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

	@ 090 , 020 SAY oSay2 PROMPT "Resultado do Processamento:" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 100 , 020 GROUP oGroup1 TO 102 , nLarguraPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL

	@ 107 , 020 SAY oSay3 PROMPT "Contratos Processados:" SIZE 080, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 107 , 100 MSGET oProcessados VAR nRowsProces  SIZE 080,010 READONLY PIXEL  Font oFnt16 OF oPanel PICTURE "@E 9999999"

	@ 140 , 020 BUTTON oBtnImp PROMPT "Visualizar Log" SIZE 070, 015 OF oPanel PIXEL ACTION (if(!Empty(cArqRel),ShellExecute("Open", cArqRel + ".log", " ", "C:\", 1 ),.T.))

Return()

/*/{Protheus.doc} ProcessaImp
Funcao para tratar os dados dos arquivos
e gerar executar processamento
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

Static Function ProcessaTxMnt(oSay,nProcess)

	Local aArea 			:= GetArea()
	Local aAreaU00			:= U00->(GetArea())
	Local aAreaU26			:= U26->(GetArea())
	Local aRetRegras		:= {}
	Local cQry				:= ""
	Local cProxReaj			:= ""
	Local cPulaLinha		:= Chr(13) + Chr(10)
	Local dDtAux			:= CTOD("")
	Local lRet				:= .T.
	Local lAtivaRegra	  	:= SuperGetMv("MV_XREGCEM",,.F.)	// parametro para ativacao da regra

	//verifico se arquivo de log existe
	if nHdlLog > 0

		fWrite(nHdlLog , "#########  GERAÇÃO DE HISTÓRICO DE TAXA DE MANUTENÇÃO - TSP  #############")
		fWrite(nHdlLog , cPulaLinha )
		fWrite(nHdlLog , " >> Data Inicio: " + DTOC( Date() ) )
		fWrite(nHdlLog , cPulaLinha )
		fWrite(nHdlLog , " >> Hora Inicio: " + Time() )
		fWrite(nHdlLog , cPulaLinha )

	endif

	//consulto os contratos importados que nao possui historico de taxa de manutencao
	cQry := " SELECT DISTINCT U00_CODIGO CONTRATO "
	cQry += " FROM "
	cQry += " " + RetSQLName("U00")+" U00 "

	//verifico se reprocesso apenas contratos enderecados ou todos
	if Alltrim(cTpContrato) == "ENDERECADOS"

		cQry += " INNER JOIN "
		cQry += " " + RetSQLName("U04")+" U04 "
		cQry += " ON U04.D_E_L_E_T_ = ' '    "
		cQry += " AND U04.U04_FILIAL = '"+ xFilial("U04") +"' "
		cQry += " AND U04.U04_CODIGO = U00.U00_CODIGO "

	endif

	cQry += " WHERE "
	cQry += " U00.D_E_L_E_T_ = ' '  "
	cQry += " AND U00.U00_FILIAL = '"+ xFilial("U00") +"' "
	cQry += " AND U00.U00_STATUS = 'A' "
	cQry += " AND U00.U00_TXMANU > 0 "
	cQry += " AND NOT EXISTS (
	cQry += " 							SELECT U26.U26_CONTRA FROM " + RetSQLName("U26") + " U26 "
	cQry += " 							WHERE U26.D_E_L_E_T_ = ' '
	cQry += " 							AND U26.U26_FILIAL = '"+ xFilial("U26")+"'
	cQry += " 							AND U26.U26_CONTRA = U00.U00_CODIGO
	cQry += " ) "
	cQry += " ORDER BY U00.U00_CODIGO  "

	cQry := ChangeQuery(cQry)

	If Select("QRYCTR") > 0
		QRYCTR->( DbCloseArea() )
	Endif

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQry, 'QRYCTR' )

	While QRYCTR->( !Eof() )

		oSay:cCaption := ("Processando Contrato: " + Alltrim( QRYCTR->CONTRATO ) + " ")
		ProcessMessages()

		U00->(DbSetOrder(1)) //U00_FILIAL + U00_CODIGO
		U26->(DbSetOrder(2)) //U26_FILIAL + U26_CONTRA

		//gero historico para contratos que nao possuem historico
		if U00->(MsSeek(xFilial("U00")+QRYCTR->CONTRATO)) .And. !U26->(MsSeek(xFilial("U26")+QRYCTR->CONTRATO))

			if lAtivaRegra

				// verifico se tem regra preenchida
				if !Empty(U00->U00_REGRA)

					aRetRegras := BuscaRegras(U00->U00_CODIGO)

				endIf

			else
				//calculo a data do proximo reajuste
				if Month(dDataBase) < Month(Stod(TRBMNT->DATATIV))
					dDtAux := Stod(cValToChar(Year(dDataBase)-1) + SubStr(TRBMNT->DATATIV,5))
				else
					dDtAux := Stod(cValToChar(Year(dDataBase)) + SubStr(TRBMNT->DATATIV,5))
				EndIf

				cProxReaj	:= StrZero(Month(dDtAux),2) + StrZero(Year(dDtAux),4)

			endIf

			if lAtivaRegra .And. Len(aRetRegras) > 0

				If U26->(RecLock("U26",.T.))

					U26->U26_FILIAL   := xFilial("U26")
					U26->U26_CODIGO   := U_GetProxNumeroU26()
					U26->U26_DATA     := dDataBase
					U26->U26_CONTRA   := U00->U00_CODIGO
					U26->U26_IMPORT   := "S"
					U26->U26_CONREA   := SubStr(cConsIndice,1,1)

					cProxReaj := aRetRegras[1]

					U26->U26_PROMAN		:= cProxReaj
					U26->U26_TAXA		:= aRetRegras[2]
					U26->U26_TPINDI		:= aRetRegras[3]
					U26->U26_INDICE		:= 0
					U26->U26_VLADIC		:= 0
					U26->U26_TXBRU		:= aRetRegras[2]
					U26->U26_VLDESC		:= 0
					U26->U26_REGRA		:= aRetRegras[7]
					U26->U26_STATUS		:= "2"
					U26->U26_FORPG		:= aRetRegras[6]
					U26->U26_CGERA		:= aRetRegras[8]
					U26->( MsUnlock() )

					nProcess++

				EndIf

				//verifico se arquivo de log existe
				if nHdlLog > 0

					fWrite(nHdlLog , "-------------------------------------------" )
					fWrite(nHdlLog , cPulaLinha )
					fWrite(nHdlLog , ">> Contrato: " + U00->U00_CODIGO )
					fWrite(nHdlLog , cPulaLinha )
					fWrite(nHdlLog , ">> Regra: " + U00->U00_REGRA )
					fWrite(nHdlLog , cPulaLinha )
					fWrite(nHdlLog , ">> Proximo Reajuste: " + cProxReaj  )
					fWrite(nHdlLog , cPulaLinha )

				endif

			ElseIf !lAtivaRegra

				If U26->(RecLock("U26",.T.))

					U26->U26_FILIAL   := xFilial("U26")
					U26->U26_CODIGO   := U_GetProxNumeroU26()
					U26->U26_DATA     := dDataBase
					U26->U26_CONTRA   := U00->U00_CODIGO
					U26->U26_IMPORT   := "S"
					U26->U26_CONREA   := SubStr(cConsIndice,1,1)
					U26->U26_PROMAN   	:= cProxReaj
					U26->U26_TPINDI		:= U00->U00_INDICE
					U26->U26_TAXA		:= U00->U00_TXMANU
					U26->( MsUnlock() )

					nProcess++

				EndIf

				//verifico se arquivo de log existe
				if nHdlLog > 0

					fWrite(nHdlLog , "-------------------------------------------" )
					fWrite(nHdlLog , cPulaLinha )
					fWrite(nHdlLog , ">> Contrato: " + U00->U00_CODIGO )
					fWrite(nHdlLog , cPulaLinha )
					fWrite(nHdlLog , ">> Proximo Reajuste: " + cProxReaj  )
					fWrite(nHdlLog , cPulaLinha )

				endif

			endIf

		endif

		QRYCTR->( DbSkip() )
	EndDo

	//verifico se arquivo de log existe
	if nHdlLog > 0

		fWrite(nHdlLog , "-------------------------------------------" )
		fWrite(nHdlLog , cPulaLinha )
		fWrite(nHdlLog , " >> Data Fim: " + DTOC( Date() ) )
		fWrite(nHdlLog , cPulaLinha )
		fWrite(nHdlLog , " >> Hora Fim: " + Time() )
		fWrite(nHdlLog , cPulaLinha )

		// fecho o arquivo de log
		fClose(nHdlLog)

	endif

	RestArea(aAreaU26)
	RestArea(aAreaU00)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} BuscaRegras
funcao para buscar as regras de contratos
@type function
@version 1.0  
@author g.sampaio
@since 08/03/2021
@param cCodigoContrato, character, codigo do contrato de cemiterio
@return array, retorna os dados da regra para reajuste
/*/
Static Function BuscaRegras(cCodigoContrato)

	Local aRetorno			:= {}
	Local cQuery 			:= ""
	Local cProxMan			:= ""
	Local dDataAniversario	:= Stod("")
	Local dDataAtual		:= Stod("")
	Local dDataReajuste		:= Stod("")
	Local lContinua			:= .T.

	Default cCodigoContrato := ""

	if Select("TRBMNT") > 0
		TRBMNT->(DbCloseArea())
	endIf

	cQuery := " SELECT U00.U00_FILIAL 		FILIALCTR, "
	cQuery += " 	   U00.U00_CODIGO 		CODIGOCTR, "
	cQuery += "        U00.U00_DTATIV 		DATATIV, "
	cQuery += "        U00.U00_TXMANU 		TXMANUCTR, "
	cQuery += "        U00.U00_FPTAXA 		FPTAXACTR, "
	cQuery += " 	   U00.U00_INDICE		TIPOINDI, "
	cQuery += "        U00.U00_REGRA  		REGRACTR, "
	cQuery += "        REGRAMNT.COMOGERA 	COMOGERA, "
	cQuery += "        REGRAMNT.TIPOVALOR 	TIPOVALOR,     "
	cQuery += "        REGRAMNT.TIPODESC 	TIPODESC, "
	cQuery += "        REGRAMNT.DESCONTO 	DESCONTO, "
	cQuery += "        REGRAMNT.VENCIMENTO 	VENCIMENTO, "
	cQuery += "        REGRAMNT.QUANDO 		QUANDO, "
	cQuery += "        REGRAMNT.QTDPAR 		QTDPAR, "
	cQuery += "        REGRAMNT.INTERVALO 	INTERVALO, "
	cQuery += "        REGRAMNT.CICLO 		CICLO,"
	cQuery += "        REGRAMNT.ATIVINI		ATIVINI,"
	cQuery += "        REGRAMNT.ATIVFIM 	ATIVINI,"
	cQuery += "        REGRAMNT.GERACAO		GERACAO"
	cQuery += " FROM " + RetSQLName("U00") + " U00 "
	cQuery += " INNER JOIN  "
	cQuery += "   (SELECT U79.U79_FILIAL FILIAL,  "
	cQuery += "           U79.U79_CODIGO REGRA,  "
	cQuery += "           U79.U79_CGERA COMOGERA,  "
	cQuery += "           U79.U79_VLTAXA TIPOVALOR, "
	cQuery += "           U80.U80_FORMA FORMAPAG, "
	cQuery += "           U80.U80_TPDESC TIPODESC, "
	cQuery += "           U80.U80_DESC DESCONTO, "
	cQuery += "           U81.U81_VENCIM VENCIMENTO, "
	cQuery += "           U81.U81_QUANDO QUANDO, "
	cQuery += "           U81.U81_QTDPAR QTDPAR, "
	cQuery += "           U81.U81_INTERV INTERVALO, "
	cQuery += "           U81.U81_CICLO CICLO, "
	cQuery += " 		  U81.U81_ATVINI ATIVINI, "
	cQuery += " 	      U81.U81_ATVFIM ATIVFIM, "
	cQuery += "           U81.U81_GERACA GERACAO "
	cQuery += "    FROM " + RetSQLName("U79") + " U79 "
	cQuery += " INNER JOIN " + RetSQLName("U80") + " U80 ON U80.D_E_L_E_T_ = ' ' "
	cQuery += "    AND U80.U80_FILIAL = '" + xFilial("U80") + "' "
	cQuery += "    AND U80.U80_CODIGO = U79.U79_CODIGO "
	cQuery += " INNER JOIN " + RetSQLName("U81") + " U81 ON U81.D_E_L_E_T_ = ' ' "
	cQuery += "    AND U81.U81_FILIAL = '" + xFilial("U81") + "' "
	cQuery += "    AND U81.U81_CODIGO = U80.U80_CODIGO "
	cQuery += "    AND U81.U81_ITEMFO = U80.U80_ITEM "
	cQuery += "    WHERE U79.D_E_L_E_T_ = ' ' "
	cQuery += "    AND U79.U79_FILIAL = '" + xFilial("U79") + "' "
	cQuery += " ) AS REGRAMNT ON REGRAMNT.FILIAL = U00.U00_FILIAL "
	cQuery += " AND REGRAMNT.REGRA = U00.U00_REGRA "
	cQuery += " AND REGRAMNT.FORMAPAG = U00.U00_FPTAXA "
	cQuery += " WHERE U00.D_E_L_E_T_ = ' ' "
	cQuery += " AND U00.U00_FILIAL = '" + xFilial("U00") + "' "
	cQuery += " AND U00.U00_STATUS IN ('A','S') "
	cQuery += " AND U00.U00_CODIGO = '" + cCodigoContrato + "' "
	cQuery += " AND NOT EXISTS( "
	cQuery += " 	SELECT U26.U26_CONTRA FROM " + RetSQLName("U26") + " U26 "
	cQuery += " 	WHERE U26.D_E_L_E_T_ = ' ' "
	cQuery += " 	AND U26.U26_FILIAL = '" + xFilial("U26") + "' "
	cQuery += " 	AND U26.U26_CONTRA = U00.U00_CODIGO "
	cQuery += " ) "

	cQuery := ChangeQuery(cQuery)

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TRBMNT' )

	While TRBMNT->(!Eof())

		lContinua := .F.

		// pego a data de aniversario do contrato
		dDataAniversario := Stod(TRBMNT->DATATIV)

		If TRBMNT->COMOGERA == "2" .And. Val(TRBMNT->ATIVINI) >= Month(dDataAniversario) .And. TRBMNT->ATIVFIM <= Month(dDataAniversario)

			If Val(TRBMNT->GERACAO) <= Month(dDataBase)
				dDataAtual := cValToChar(Year(dDataBase)-1) + SubStr(Dtos(dDataAniversario), 5, 2) + StrZero(Val(TRBMNT->GERACAO),2)
			Else
				dDataAtual := cValToChar(Year(dDataBase)) + SubStr(Dtos(dDataAniversario), 5, 2) + StrZero(Val(TRBMNT->GERACAO),2)
			EndIf

			lContinua := .T.

		ElseIf TRBMNT->COMOGERA <> "2"

			// verifico se o mes da data de ativacao é maior que a data base
			if Month(dDataBase) < Month(dDataAniversario)
				dDataAtual := cValToChar(Year(dDataBase)-1) + SubStr(Dtos(dDataAniversario),5)
			else
				dDataAtual := cValToChar(Year(dDataBase)) + SubStr(Dtos(dDataAniversario),5)
			EndIf

			lContinua := .T.

		EndIf

		If lContinua

			// data do proixmo reajuste
			dDataReajuste := MonthSum( Stod(dDataAtual), TRBMNT->CICLO  - 1 )

			// data da proxima manutencao
			cProxMan := StrZero( Month( dDataReajuste ), 2 ) + StrZero( Year( dDataReajuste ), 4 )

			aRetorno := {}
			aAdd( aRetorno, cProxMan )
			aAdd( aRetorno, TRBMNT->TXMANUCTR )
			aAdd( aRetorno, TRBMNT->TIPOINDI )
			aAdd( aRetorno, TRBMNT->FILIALCTR )
			aAdd( aRetorno, TRBMNT->CODIGOCTR )
			aAdd( aRetorno, TRBMNT->FPTAXACTR )
			aAdd( aRetorno, TRBMNT->REGRACTR )
			aAdd( aRetorno, TRBMNT->COMOGERA )

		EndIf

		TRBMNT->(DbSkip())
	EndDo

	if Select("TRBMNT") > 0
		TRBMNT->(DbCloseArea())
	endIf

Return(aRetorno)
