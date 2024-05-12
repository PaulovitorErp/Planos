#Include "protheus.CH"
#include "topconn.ch"  

/*/{Protheus.doc} RIMPC007
Rotina de Geracao de Taxa.
de Manutencao automatica
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User function RIMPC008()

Local oPanel		:= NIL	
Local oNewPag		:= NIL
Local oStepWiz 		:= NIL
Local oDlg 			:= NIL
Local oPanelBkg		:= NIL

Private cArqRel			:= Space(300)
Private dDataInicial	:= CTOD("")
Private cContIni		:= Space(TamSx3("U00_CODIGO")[1])
Private cContFim		:= Space(TamSx3("U00_CODIGO")[1])
Private nHdlLog			:= 0 


//crio dialog que ira receber o Wizard
DEFINE DIALOG oDlg TITLE 'Assistente de Geração Automatica de Taxa de Manutenção - Totvs Servicos Postumos' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )

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
oNewPag:SetStepDescription("Geração Automatica de Taxa de Manutencao")

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
	
	cTexto1 += "Esta rotina tem como objetivo ajuda-lo no procedimento de Geração Automatica de taxa de manutenção para Totvs Serviços Póstumos" + cPulaLinha
	
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

@ 030 , 055 SAY oSay3 PROMPT "Geração Automatica de Taxa de Manutenção - Totvs Serviços Póstumos" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

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
Local oDataInicial	:= NIL
Local oContIni		:= NIL
Local oContFim		:= NIL

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

@ 145 , 020 GROUP oGroup2 TO 151 , nLarguraPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL

@ 157 , 020 SAY oSay3 PROMPT "Data inicial de Geração das Taxas:" SIZE 150, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

@ 156 , 137 MSGET oDataInicial VAR dDataInicial  SIZE 90,010 PIXEL  Font oFnt16 OF oPanel 

@ 175 , 020 SAY oSay4 PROMPT "Contrato(s):" SIZE 150, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

@ 174 , 137 MSGET oContIni VAR cContIni  SIZE 050,010 PIXEL  F3 "U00" Font oFnt16 OF oPanel 

@ 175 , 200 SAY oSay4 PROMPT " a " SIZE 10, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

@ 174 , 223 MSGET oContFim VAR cContFim SIZE 050,010 PIXEL  F3 "U00" Font oFnt16 OF oPanel 


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
Local cQry				:= ""
Local cProxReaj			:= ""
Local cIndice			:= ""
Local cContrato			:= ""
Local cCliente			:= ""
Local cLoja				:= ""
Local cPulaLinha		:= Chr(13) + Chr(10)
Local dDtAux			:= CTOD("")
Local lRet				:= .T.
Local nValReaj			:= 0 
Local nTaxaReaj			:= 0 
Local nIndAplic			:= 0 
Local nIndice			:= 0 
Local nSucesso			:= 0
Local nMesesMan			:= SuperGetMv("MV_XINTTXA",.F.,6) // intervalo de meses para geração da segunda taxa
Local nQtdManut			:= SuperGetMv("MV_XQTDTXA",.F.,2) // quantidade de taxas de manutenção que serão geradas
Local nQtdProxReaj		:= SuperGetMv("MV_XQPROXR",.F.,6) // quantidade de meses para a proximo reajuste
Local dBkpData			:= dDataBase

//verifico se arquivo de log existe 
if nHdlLog > 0 
	
	fWrite(nHdlLog , "#########  GERAÇÃO AUTOMATICA DE TAXA DE MANUTENÇÃO - TSP  #############")
	fWrite(nHdlLog , cPulaLinha )
	fWrite(nHdlLog , " >> Data Inicio: " + DTOC( Date() ) )
	fWrite(nHdlLog , cPulaLinha )
	fWrite(nHdlLog , " >> Hora Inicio: " + Time() )
	fWrite(nHdlLog , cPulaLinha ) 
	
endif
	
While dDataInicial <= dBkpData
	
	//altero a data base do sistema para a data inicial
	dDataBase	:= dDataInicial
	
	/////////////////////////////////////////////////////////////////////
	//////////// CONSULTO OS CONTRATOS PARA GERACAO DAS TAXAS ///////////
	/////////////////////////////////////////////////////////////////////
	
	cQry := " SELECT "
	cQry += " CONTRATO.U00_CODIGO AS CONTRATO, "
	cQry += " CONTRATO.U00_CLIENT AS CLIENTE, "
	cQry += " CONTRATO.U00_LOJA AS LOJA, "
	cQry += " CONTRATO.U00_INDICE AS INDICE, "
	cQry += " (CONTRATO.U00_TXMANU + CONTRATO.U00_ADIMNT) AS TAXA, "
	cQry += " SUBSTRING(U00_PRIMVE,7,2) AS DIA_VENCIMENTO, "
	cQry += " ULTIMA_MANUTENCAO.DATA_PROXIMA_MANUTENCAO "
	cQry += " FROM  "
	cQry += RetSQLName("U00") + " CONTRATO "
	cQry += " INNER JOIN  "
	cQry += " ( "
	cQry += " 	SELECT "
	cQry += " 	U26.U26_CONTRA AS CODIGO_CONTRATO,  "
	cQry += " 	MAX(SUBSTRING(U26_PROMAN,3,4) + SUBSTRING(U26_PROMAN,1,2)) AS DATA_PROXIMA_MANUTENCAO  "
	cQry += " 	FROM  "
	cQry += RetSQLName("U26") + " U26  "
	cQry += " 	WHERE  "
	cQry += " 	U26.D_E_L_E_T_ = ' '  "
	cQry += " 	AND U26.U26_FILIAL = '" + xFilial("U26") + "'  "
	cQry += " 	GROUP BY U26.U26_CONTRA  "
	cQry += " ) AS ULTIMA_MANUTENCAO  "
	cQry += " ON CONTRATO.D_E_L_E_T_ = ' '   "
	cQry += " AND CONTRATO.U00_CODIGO = ULTIMA_MANUTENCAO.CODIGO_CONTRATO   "
	cQry += " WHERE  " 
	cQry += " 	CONTRATO.U00_FILIAL = '" + xFilial("U00") + "'  " 
	cQry += " 	AND CONTRATO.U00_STATUS = 'A'  "
	cQry += " 	AND CONTRATO.U00_TXMANU > 0  "
	
	if !Empty(cContIni) .Or. !Empty(cContFim)
		
		cQry += " AND CONTRATO.U00_CODIGO BETWEEN '" + cContIni + "' AND '" + cContFim + "' "
	
	endif
	
	cQry += " 	AND ULTIMA_MANUTENCAO.DATA_PROXIMA_MANUTENCAO <= '" + AnoMes(dDataBase) + "'  "
	cQry += " ORDER BY CONTRATO "
	
	If Select("QRYTX") > 0
		QRYTX->( DbCloseArea() )
	Endif
	
	TcQuery cQry NEW Alias "QRYTX"

	// se existir contratos a serem reajustados
	if QRYTX->(!Eof())
		
		While QRYTX->(!Eof())
			
			oSay:cCaption := ("Processando Mês: " + AnoMes(dDataBase) + "  - Contrato: " + Alltrim( QRYTX->CONTRATO ) + " ")
			ProcessMessages()
	
			// verifico se já existe historico de manutenção
			// caso exista, será aplicado o índice
			U26->(DbSetOrder(2)) // U26_FILIAL + U26_CONTRA
			
			cIndice := QRYTX->INDICE
			
			//limpo variavel de adicao de indice de reajuste da taxa de manutencao
			nIndAplic	:= 0 
			nIndice		:= 0
			
			//valido se aplica o indice de reajuste 
			if AcresIndice(QRYTX->CONTRATO)
				
				nIndice	:= BuscaIndice(cIndice)
				
				//se o indice retornado for negativo, zero o mesmo, pois as parcelas nao sofrerao reducao
				if nIndice < 0
				
					nIndice := 0
				
				endif
			
				nIndAplic := nIndice 
			
			endif
			
			
			cContrato 	:= QRYTX->CONTRATO
			cCliente	:= QRYTX->CLIENTE
			cLoja		:= QRYTX->LOJA
			cDiaVenc	:= QRYTX->DIA_VENCIMENTO  
			nValReaj	:= QRYTX->TAXA  * (nIndAplic / 100)  
			nTaxaReaj 	:= QRYTX->TAXA + nValReaj 
			
			// somo a quantidade de meses para a próxima manutenção 
			dDtAux		:= MonthSum(dDatabase,(nMesesMan * nQtdManut))  
			cProxReaj	:= StrZero(Month(dDtAux),2) + StrZero(Year(dDtAux),4)   
				
			//realizo o reajuste do contrato
			lRet := U_ProcManut( cContrato, cCliente, cLoja , nTaxaReaj , nValReaj , cDiaVenc , cIndice, nIndAplic ,cProxReaj )
			
			if !lRet 
				
				//verifico se arquivo de log existe 
				if nHdlLog > 0 
					
					fWrite(nHdlLog , "Não possivel gerar taxa de manutenção para o contrato: " + cContrato + " ")
					fWrite(nHdlLog , cPulaLinha )
	
				endif
				
			else 
				
				nSucesso++ 
				
			endif
			
			
			QRYTX->(DbSkip())
			
			//contratos processados
			nProcess++ 
			
		EndDo
					
	endif
	
	//acrescento o proximo mes para geracao das taxas
	dDataInicial := MonthSum(dDataInicial,1)
		
EndDo

//verifico se arquivo de log existe 
if nHdlLog > 0 
					
	fWrite(nHdlLog , "Contratos Processados com sucesso: " + cValToChar( nSucesso ) + " ")
	fWrite(nHdlLog , cPulaLinha )
	
	fWrite(nHdlLog , "-------------------------------------------" ) 
	fWrite(nHdlLog , cPulaLinha )
	fWrite(nHdlLog , " >> Data Fim: " + DTOC( Date() ) )
	fWrite(nHdlLog , cPulaLinha )
	fWrite(nHdlLog , " >> Hora Fim: " + Time() )
	fWrite(nHdlLog , cPulaLinha )
	
	// fecho o arquivo de log
	fClose(nHdlLog)
	
	
endif

//restauro a data base
dDataBase := dBkpData
		
RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} AcresIndice
Funcao para validar se acrescenta indice no proximo
reajuste
para o contrato consultado
@author Raphael Martins
@since 17/01/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function AcresIndice(cContrato)

Local aArea 	:= GetArea()
Local aAreaU00	:= U00->(GetArea())
Local aAreaU26	:= U26->(GetArea())
Local cQry 		:= ""
Local lRet      := .F.

cQry := " SELECT "
cQry += " COUNT(*) QTD_ACRESC "
cQry += " FROM "
cQry += RetSQLName("U26") + " U26 "
cQry += " WHERE "
cQry += " D_E_L_E_T_ = ' ' "
cQry += " AND U26.U26_FILIAL = '" + xFilial("U26")+ "' "
cQry += " AND U26_CONTRA = '" + cContrato + "' "
cQry += " AND U26_CONREA <> 'N' "

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

// verifico se não existe este alias criado
If Select("QRYREAJ") > 0
	QRYREAJ->(DbCloseArea())
EndIf  

// crio o alias temporario
TcQuery cQry New Alias "QRYREAJ" 

// se existir contratos a serem reajustados
if QRYREAJ->QTD_ACRESC > 0 
	
	lRet := .T.
	
endif

RestArea(aArea)
RestArea(aAreaU00)
RestArea(aAreaU26)

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ BuscaIndice º Autor ³ Wellington Gonçalves	   º Data³ 20/05/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que calcula a média do índice								  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Vale do Cerrado                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function BuscaIndice(cIndice)

Local cQry 		   	:= ""     
Local cPulaLinha	:= chr(13)+chr(10) 
Local nIndice		:= 0
Local nQtdCad		:= 0  
Local dDataRef		:= dDataBase

// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf        

cQry := " SELECT " 																				+ cPulaLinha
cQry += " COUNT(*) QTDCAD, "																	+ cPulaLinha
cQry += " SUM(U29.U29_INDICE) AS INDICE " 														+ cPulaLinha 
cQry += " FROM " 																				+ cPulaLinha 
cQry += + RetSqlName("U22") + " U22 " 															+ cPulaLinha 
cQry += " INNER JOIN " 																			+ cPulaLinha 
cQry += + RetSqlName("U28") + " U28 " 															+ cPulaLinha
cQry += "    INNER JOIN " 																		+ cPulaLinha
cQry += + 	 RetSqlName("U29") + " U29 " 														+ cPulaLinha
cQry += "    ON ( " 																			+ cPulaLinha
cQry += "        U29.D_E_L_E_T_ <> '*' " 														+ cPulaLinha
cQry += "        AND U28.U28_CODIGO = U29.U29_CODIGO " 											+ cPulaLinha
cQry += "        AND U28.U28_ITEM = U29.U29_IDANO " 											+ cPulaLinha 
cQry += " 		 AND U29.U29_FILIAL = '" + xFilial("U29") + "' " 								+ cPulaLinha
cQry += "    ) " 																				+ cPulaLinha
cQry += " ON ( " 																				+ cPulaLinha
cQry += "    U28.D_E_L_E_T_ <> '*' " 															+ cPulaLinha
cQry += "    AND U22.U22_CODIGO = U28.U28_CODIGO " 												+ cPulaLinha
cQry += " 	 AND U28.U28_FILIAL = '" + xFilial("U28") + "' " 									+ cPulaLinha
cQry += "    ) " 																				+ cPulaLinha
cQry += " WHERE " 																				+ cPulaLinha 
cQry += " U22.D_E_L_E_T_ <> '*' " 																+ cPulaLinha
cQry += " AND U22.U22_FILIAL = '" + xFilial("U22") + "' " 										+ cPulaLinha 
cQry += " AND U22.U22_STATUS IN ('A','S') "														+ cPulaLinha

if !Empty(cIndice)
	cQry += " AND U22.U22_CODIGO = '" + cIndice + "' " 											+ cPulaLinha
endif
 
cQry += " AND U28.U28_ANO + U29.U29_MES " 														+ cPulaLinha 
cQry += " BETWEEN '" + AnoMes(MonthSub(dDataRef,11)) + "'  AND  '" + AnoMes(dDataRef) + "' " 	+ cPulaLinha

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRYIND" // Cria uma nova area com o resultado do query   

// se existir contratos a serem reajustados
if QRYIND->(!Eof())
	nIndice := Round(QRYIND->INDICE,TamSX3("U29_INDICE")[2])
	nQtdCad	:= QRYIND->QTDCAD
endif

// verifico se não existe este alias criado
If Select("QRYIND") > 0
	QRYIND->(DbCloseArea())
EndIf  

Return(nIndice)


						