#Include "protheus.CH"
#include "topconn.ch"

/*/{Protheus.doc} RIMPM003
Rotina de Processamento de Importacoes 
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User function RIMPM003()

	Local oPanel		:= NIL
	Local oNewPag		:= NIL
	Local oStepWiz 		:= NIL
	Local oDlg 			:= NIL
	Local oPanelBkg		:= NIL

	Private cCodigo		:= Space(TamSX3("UH8_CODIGO")[1])
	Private cDescricao	:= Space(TamSX3("UH8_DESCRI")[1])
	Private cArquivo	:= Space(300)
	Private cArqRel		:= Space(300)
	Private nHdlLog		:= 0
	Private lImp		:= .T.

//crio dialog que ira receber o Wizard
	DEFINE DIALOG oDlg TITLE 'Assistente de Importacao de Dados - Totvs Servicos Postumos' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )

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

/////////////////////////////////////////////////////////////////
///crio a pagina 2 do wizard - Selecao do Layout Cadastrado
/////////////////////////////////////////////////////////////////

	oNewPag := oStepWiz:AddStep("2", {|Panel|Pag2Layout(Panel)})

//Altero a descrição do step
	oNewPag:SetStepDescription("Layout de Importacao")

	oNewPag:SetNextAction({||VldLayout(.F.)})

//Defino o bloco ao clicar no botão Cancelar
	oNewPag:SetCancelAction({||oDlg:End()})

//Defino o bloco ao clicar no botão Voltar
	oNewPag:SetPrevAction({||.T.})

//////////////////////////////////////////////////////////////////
///crio a pagina 3 do wizard - Selecao de Arquivo de Importacao
/////////////////////////////////////////////////////////////////

	oNewPag := oStepWiz:AddStep("3", {|Panel|ArquivoImp(Panel)})

//Altero a descrição do step
	oNewPag:SetStepDescription("Arquivo de Importacao")

	oNewPag:SetNextAction({||VldOpenFile()})

//Defino o bloco ao clicar no botão Cancelar
	oNewPag:SetCancelAction({||.T.,oDlg:End()})

/////////////////////////////////////////////////////////
///crio a pagina 4 do wizard - Relatorio de Importacao
/////////////////////////////////////////////////////////


	oNewPag := oStepWiz:AddStep("4", {|Panel|RelImport(Panel)})

//Altero a descrição do step
	oNewPag:SetStepDescription("Relatorio de Importacao")

	oNewPag:SetNextAction({|| VldArqRel() })

//Defino o bloco ao clicar no botão Cancelar
	oNewPag:SetCancelAction({||oDlg:End()})

/////////////////////////////////////////////////////////
///crio a pagina 5 do wizard - Processamento da Importacao
/////////////////////////////////////////////////////////

	oNewPag := oStepWiz:AddStep("5", {|Panel| TelaResult(Panel) })

//Altero a descrição do step
	oNewPag:SetStepDescription("Processamento da Importação")

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
Instrucoes Iniciais do Wizard de Importacao
 
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
	Local cPulaLinhaArq	:= Chr(13) + Chr(10)
	Local cTexto1		:= ""

	//crio a parte superior da tela do wizard
	CriaPartSup(oPanel)

	@ 045 , 020 SAY oSay4 PROMPT "Bem Vindo..." SIZE 200, 010 Font oFnt18 OF oPanel COLORS 0, 16777215 PIXEL

	cTexto1 += "Esta rotina tem como objetivo ajula-lo na importação de dados para Totvs Serviços Póstumos" + cPulaLinhaArq
	cTexto1 += "O primeiro passo é definir o layout a ser importado..."										+ cPulaLinhaArq

	@ 065 , 020 SAY oSay1 PROMPT cTexto1 SIZE 300, 300 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL


Return()

/*/{Protheus.doc} Pag2Layout
Tela de Selecao do Layout de 
importacao
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function Pag2Layout(oPanel)

	Local oFnt16		:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
	Local oFnt16N		:= TFont():New("Arial",,16,,.T.,,,,,.F.,.F.)
	Local oCodigo		:= NIL
	Local oDescricao	:= NIL
	Local nLarguraPnl	:= oPanel:nClientWidth / 2
	Local cPulaLinhaArq	:= Chr(13) + Chr(10)
	Local cTexto1		:= ""


//crio a parte superior da tela do wizard 	
	CriaPartSup(oPanel)

	@ 045 , 020 SAY oSay4 PROMPT "Informe a entidade a ser importada" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	cTexto1 := "O Layout é necessário para definir em qual entidade os dados serão inseridos e a estrutura do arquivo de importação."

	@ 060 , 020 SAY oSay1 PROMPT cTexto1 SIZE 200, 200 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

	@ 080 , 020 SAY oSay2 PROMPT "Dados da Importação:" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 088 , 020 GROUP oGroup1 TO 090 , nLarguraPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL

	@ 095 , 020 SAY oSay3 PROMPT "Código:" SIZE 050, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 095 , 070 MSGET oCodigo VAR cCodigo  SIZE 050,010 PIXEL F3 "UH8" Font oFnt16 OF oPanel HasButton PICTURE "@!" Valid(VldLayout(.T.))

	@ 110 , 020 SAY oSay3 PROMPT "Descrição:" SIZE 050, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 110 , 070 MSGET oDescricao VAR cDescricao SIZE 200,010 PIXEL When .F. Font oFnt16 OF oPanel PICTURE "@!"

Return()

/*/{Protheus.doc} VldLayout
Valida layout de importacao informado
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function VldLayout(lVazio)

	Local lRet 		:= .T.
	Local aArea		:= GetArea()
	Local aAreaUH8	:= UH8->(GetArea())

	UH8->(DbSetOrder(1)) //UH8_FILIAL + UH8_CODIGO

	if !Empty(cCodigo)

		if !UH8->(DbSeek(xFilial("UH8")+cCodigo))

			lRet := .F.
			Help(,,'Help',,"O Layout digitado não encotrado, favor verifique-o!.",1,0)

		else

			cDescricao := UH8->UH8_DESCRI

		endif

	elseif lVazio

		cDescricao := Space(TamSX3("UH8_DESCRI")[1])

	else

		lRet := .F.
		Help(,,'Help',,"Favor selecionar layout para importação!.",1,0)

	endif


	RestArea(aArea)
	RestArea(aAreaUH8)

Return(lRet)

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

	@ 020 , 055 SAY oSay2 PROMPT "Siga atentamente os passos para realizar..." SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

	@ 030 , 055 SAY oSay3 PROMPT "Importação de dados para o Totvs Serviços Póstumos" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

	@ 040 , 020 GROUP oGroup1 TO 042 , nLarguraPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL


Return()

/*/{Protheus.doc} Pag2Layout
Panel de selecao do arquivo de importacao
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function ArquivoImp(oPanel)

	Local oFnt16		:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
	Local oFnt16N		:= TFont():New("Arial",,16,,.T.,,,,,.F.,.F.)
	Local oArquivo		:= NIL
	Local oBtnRel		:= NIL
	Local nLarguraPnl	:= oPanel:nClientWidth / 2
	Local cPulaLinhaArq	:= Chr(13) + Chr(10)
	Local cTexto1		:= ""
	Local cImgArq		:= "icone_file.png"
	Local cImgFileHover	:= "icone_file_foco.png"
	Local cCSSBtnFile	:= ""

//crio a parte superior da tela do wizard
	CriaPartSup(oPanel)

	@ 045 , 020 SAY oSay4 PROMPT "Informe o arquivo de importacao" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	cTexto1 += " O Arquivo de importação devera conter os dados a serem importados para a rotina definida anteriormente...	" + cPulaLinhaArq
	cTexto1 += " Estes dados deverão estar de acordo com o layout definido previamente e no formato .CSV 					" + cPulaLinhaArq

	@ 060 , 020 SAY oSay1 PROMPT cTexto1 SIZE 300, 300 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

	@ 090 , 020 SAY oSay2 PROMPT "Arquivo de Importação:" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 107 , 020 GROUP oGroup1 TO 109 , nLarguraPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL

	@ 115 , 020 SAY oSay3 PROMPT "Arquivo:" SIZE 050, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 115 , 070 MSGET oArquivo VAR cArquivo  SIZE 200,010 PIXEL Font oFnt16 OF oPanel PICTURE "@!" ReadOnly

	oBtnRel	:= TButton():New(114,275,"" ,oPanel,{|| cArquivo := cGetFile( '*.csv' , 'Selecione o arquivo para importação', 16, , .T.,GETF_LOCALHARD,.F., .T. )},22,22,,,.F.,.T.,.F.,,.F.,,,.F. )

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

/*/{Protheus.doc} VldArquivo
Funcao para validar o get do arquivo 
de importacao
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function VldOpenFile()

	Local lRet := .T.

	if Empty(cArquivo)

		lRet := .F.
		Help(,,'Help',,"Selecione o arquivo de importação antes de prosseguir!",1,0)

	elseif !File(cArquivo)

		lRet := .F.
		Help(,,'Help',,"Não foi possivel encontrar o arquivo selecionado, favor verifique-o!",1,0)

	endif


Return(lRet)

/*/{Protheus.doc} RelImport
Funcao para montar panel de selecao
do arquivo de log a ser gerado da importacao
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function RelImport(oPanel)

	Local oFnt16		:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
	Local oFnt16N		:= TFont():New("Arial",,16,,.T.,,,,,.F.,.F.)
	Local oArqRel		:= NIL
	Local oBtnRel		:= NIL
	Local nLarguraPnl	:= oPanel:nClientWidth / 2
	Local cPulaLinhaArq	:= Chr(13) + Chr(10)
	Local cTexto1		:= ""
	Local cImgArq		:= "icone_file.png"
	Local cImgFileHover	:= "icone_file_foco.png"
	Local cCSSBtnFile	:= ""

//crio a parte superior da tela do wizard
	CriaPartSup(oPanel)

	@ 045 , 020 SAY oSay4 PROMPT "Informe o local do relatório de importação" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	cTexto1 := " Após a importação dos dados o sistema irá gerar um relatório constando todas informações referentes a importação de dados.	" + cPulaLinhaArq

	@ 060 , 020 SAY oSay1 PROMPT cTexto1 SIZE 300, 300 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

	@ 090 , 020 SAY oSay2 PROMPT "Relatório de Importação:" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 107 , 020 GROUP oGroup1 TO 109 , nLarguraPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL

	@ 115 , 020 SAY oSay3 PROMPT "Diretório:" SIZE 050, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 115 , 070 MSGET oArqRel VAR cArqRel  SIZE 200,010 PIXEL  Font oFnt16 OF oPanel PICTURE "@!"

	oBtnRel	:= TButton():New(114,275,"" ,oPanel,{|| cArqRel := cGetFile( '*.csv' , 'Selecione o arquivo para importação', 16, , .F.,GETF_LOCALHARD,.F., .T. ) },22,22,,,.F.,.T.,.F.,,.F.,,,.F. )

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

		//crio arquivo de relatorio do processamento da importacao
		nHdlLog := MsfCreate(cArqRel + ".log",0)

		if nHdlLog < 0

			lRet := .F.
			Help(,,'Help',,"Não foi possivel criar o arquivo de relatorio de importacao, favor o diretorio selecionado!",1,0)

		endif

	endif

Return(lRet)

/*/{Protheus.doc} TelaResult
Funcao para montar tela de resultado final
da importacao 
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
	Local cPulaLinhaArq	:= Chr(13) + Chr(10)
	Local cTexto1		:= ""
	Local nRowsProces	:= 0
	Local nSucess		:= 0

//crio a parte superior da tela do wizard
	CriaPartSup(oPanel)

	FWMsgRun(,{|oSay| ProcessaImp(oSay,@nRowsProces,@nSucess)},'Aguarde...','Processando Importação Totvs Serviços Póstumos.')

	@ 045 , 020 SAY oSay4 PROMPT "Processo de Importação finalizado" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	cTexto1 := "Processo de Importação finalizado, abaixo segue os dados processos e os dados importados com sucesso!	" + cPulaLinhaArq

	@ 060 , 020 SAY oSay1 PROMPT cTexto1 SIZE 300, 300 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

	@ 090 , 020 SAY oSay2 PROMPT "Resultado da Importação:" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 100 , 020 GROUP oGroup1 TO 102 , nLarguraPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL

	@ 107 , 020 SAY oSay3 PROMPT "Linhas Processadas:" SIZE 080, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 107 , 100 MSGET oProcessados VAR nRowsProces  SIZE 080,010 READONLY PIXEL  Font oFnt16 OF oPanel PICTURE "@E 9999999"

	@ 120 , 020 SAY oSay4 PROMPT "Linhas Importadas:" SIZE 080, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 120 , 100 MSGET oSucesso VAR nSucess  SIZE 080,010 PIXEL  READONLY Font oFnt16 OF oPanel PICTURE "@E 9999999"

	@ 140 , 020 BUTTON oBtnImp PROMPT "Visualizar Log" SIZE 070, 015 OF oPanel PIXEL ACTION (ShellExecute("Open", cArqRel + ".log", " ", "C:\", 1 ))

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

Static Function ProcessaImp(oSay,nLinha,nSucess)

	Local lRet			:= .T.
	Local aArea			:= GetArea()
	Local aAreaUH9		:= UH9->(GetArea())
	Local aAreaUI0		:= UI0->(GetArea())
	Local aLayout		:= {}
	Local aLinhaArq		:= {}
	Local aColunaVld	:= {}
	Local aLinhaValida	:= {}
	Local nHandle		:= 0
	Local cConteudoCpo	:= ""
	Local cPulaLinha	:= Chr(13) + Chr(10)
	Local nX			:= 1
	Local oSX3			:= UGetSxFile():New
	Local aCampos		:= {}

/* 
	Validacoes do Arquivo de Importacao
	1 - Quantidade de Colunas do Arquivo esta de acordo com o layout cadastrado?
	2 - O tipo de dado das colunas sao equivalentes a estrutura do dicionario de dados
	3 - Booleano sera recebido como True ou False e ser realizado a conversao 
*/

	UH8->(DbSetOrder(1)) //UH8_FILIAL + UH8_CODIGO
	UH9->(DbSetOrder(1)) //UH9_FILIAL + UH9_CODIGO + UH9_ITEM

	if UH8->(DbSeek(xFilial("UH8")+cCodigo))

		//verifico se arquivo de log existe
		if nHdlLog > 0

			fWrite(nHdlLog , "#########  IMPORTACAO DE DADOS - TSP  #############")
			fWrite(nHdlLog , cPulaLinha )
			fWrite(nHdlLog , " >> Data Inicio: " + DTOC( Date() ) )
			fWrite(nHdlLog , cPulaLinha )
			fWrite(nHdlLog , " >> Hora Inicio: " + Time() )
			fWrite(nHdlLog , cPulaLinha )
			fWrite(nHdlLog , " >> Rotina: " + UH8->UH8_ROTINA + " - " + Alltrim( UH8->UH8_DESCRI ) )
			fWrite(nHdlLog , cPulaLinha )

		endif

		//faco a abertura do arquivo
		oReader := FWFileReader():New(Lower(cArquivo))

		if oReader:Open()

			if UH9->(DbSeek(xFilial("UH9")+cCodigo))

				//crio o array com a estrutura do layout configurado
				While UH9->(!Eof()) .And. UH9->UH9_CODIGO == cCodigo

					aCampos := oSX3:GetInfoSX3(,UH9->UH9_CAMPO)

					if Len(aCampos) > 0

						Aadd(aLayout,{UH9->UH9_CAMPO,aCampos[1,2]:cTIPO,aCampos[1,2]:nTAMANHO })

						//campos chaves
					elseif 	Alltrim(UH9->UH9_CAMPO) == "COD_ANT" .Or. Alltrim(UH9->UH9_CAMPO) == "CGC" ;
							.OR. Alltrim(UH9->UH9_CAMPO) == "BEN_ANT".OR. Alltrim(UH9->UH9_CAMPO) == "BEN_LEG";
							.Or. Alltrim(UH9->UH9_CAMPO) == "END_PREVIO" .Or. Alltrim(UH9->UH9_CAMPO) == "COD_IMP";
							.Or. Alltrim(UH9->UH9_CAMPO) == "CGC_CLIANT" .Or. Alltrim(UH9->UH9_CAMPO) == "CLI_ANT";

						Aadd(aLayout,{UH9->UH9_CAMPO,"C",14})

					elseIf "NATUREZA" $ UH9->UH9_CAMPO
						AADD(aLayout,{ UH9->UH9_CAMPO, "C", TamSX3("E1_NATUREZ")[1]})
					elseIf "VALOR" $ UH9->UH9_CAMPO .And. Alltrim(UH9->UH9_CAMPO) <> "E1_VALOR"
						AADD(aLayout,{ UH9->UH9_CAMPO, "N", TamSX3("E1_VALOR")[1]})
					else

						lRet := .F.

						//verifico se arquivo de log existe
						if nHdlLog > 0

							fWrite(nHdlLog , " Campo cadastrado no layout não encontrado no dicionario de dados!" )
							fWrite(nHdlLog , cPulaLinha )

						endif

					endif

					UH9->( DbSkip() )

				EndDo

				if lRet

					While oReader:hasLine() //!FT_FEOF()

						//contador das linhas processadas
						nLinha++

						oSay:cCaption := ("Processando a Linha: " + StrZero(nLinha,7) + "...")
						ProcessMessages()

						//verifico se arquivo de log existe
						if nHdlLog > 0

							fWrite(nHdlLog , '-----------------------------------------------' )
							fWrite(nHdlLog , cPulaLinha )
							fWrite(nHdlLog , "Processando Linha: " + StrZero(nLinha,7) + " " )
							fWrite(nHdlLog , cPulaLinha )
							fWrite(nHdlLog , '-----------------------------------------------' )
							fWrite(nHdlLog , cPulaLinha )
						endif

						//faco a leitura da corrente
						cLinha := oReader:GetLine() //FT_FReadLn()
						lRet := .T.

						if !Empty(cLinha)

							AADD(aLinhaArq, StrTokArr2(cLinha, ";" , .T. ) )

							//valido se a quantidade de colunas do arquivo esta de acordo com o layout configurado
							if Len(aLinhaArq[1]) == Len(aLayout)

								//valido os tipos de dados das colunas esta de acordo com o dicionario
								For nX := 1 To Len(aLayout)

									//valido se o tipo de dados e numerico
									if aLayout[nX,2] == 'N'

										if (isAlpha(Alltrim(aLinhaArq[1,nX])) .And. Len(Alltrim(aLinhaArq[1,nX])) > aLayout[nX,3])

											lRet := .F.

										else

											//realizo o de-para do conteudo
											cConteudoCpo := Val(DeParaImp(cCodigo,Alltrim(aLinhaArq[1,nX]),aLayout[nX,1]))

										endif

										//valido se o tipo de dados e data
									elseif aLayout[nX,2] == 'D'

										//valido se possui letra em campo data e se e data valida
										if isAlpha(Alltrim(aLinhaArq[1,nX])) .Or. Empty( DataValida( ConverteData( Alltrim( aLinhaArq[1,nX] ) ) ) )

											lRet := .F.
										else

											cConteudoCpo := ConverteData(DeParaImp(cCodigo,Alltrim(aLinhaArq[1,nX]),aLayout[nX,1]))

										endif

										//valido se o tipo de dados e logico
									elseif aLayout[nX,2] == 'L'

										if Lower(Alltrim(aLinhaArq[1,nX])) <> 'true' .And. Lower(Alltrim(aLinhaArq[1,nX])) <> 'false'

											lRet := .F.

										else

											if Lower(Alltrim(aLinhaArq[1,nX])) == 'true'

												cConteudoCpo := .T.

											else

												cConteudoCpo := .F.

											endif

										endif

									elseif aLayout[nX,2] == 'C' .Or. aLayout[nX,2] == 'M'

										//realizo o de-para do conteudo
										cConteudoCpo := Alltrim( DeParaImp(cCodigo,Alltrim(aLinhaArq[1,nX]),aLayout[nX,1]))

									endif

									if !lRet

										//verifico se arquivo de log existe
										if nHdlLog > 0

											fWrite(nHdlLog , " A coluna " + aLayout[nX,1] + ": " + cValToChar(nX) + "  da linha não está de acordo com o dicionario de dados! Tipo do campo '" + aLayout[nX,2] + "'"  )
											fWrite(nHdlLog , cPulaLinha )


										endif

									else

										//aLayout[nX,1] 	= Campo do Layout
										//aLinhaArq[nX,1]	= Conteudo da Linha

										aAdd(aColunaVld, { aLayout[nX,1] ,cConteudoCpo } )

									endif

									//reseto o conteudo da linha
									cConteudoCpo := ""

								Next nX

							else

								lRet := .F.

								//verifico se arquivo de log existe
								if nHdlLog > 0

									fWrite(nHdlLog , "O arquivo de importação não está de acordo com o layout configurado!" )
									fWrite(nHdlLog , cPulaLinha )

								endif

								Exit

							endif

						endif

						//valido se a linha esta de acordo com o layout
						if lRet

							Aadd(aLinhaValida, aClone( aColunaVld ) )

						endif

						///////////////////////////////////////////////////////
						////	VERIFICO A ROTINA QUE SERA EXECUTADA	//////
						//////////////////////////////////////////////////////

						if lRet

							//cadastro de clientes
							if UH8->UH8_ROTINA == "SA1"

								if U_RIMPM004(aLinhaValida,nHdlLog)

									//registros importados com sucesso
									nSucess++

								endif

								//cadastro de vendedores
							elseif UH8->UH8_ROTINA == "SA3"

								if U_RIMPM005(aLinhaValida,nHdlLog)

									//registros importados com sucesso
									nSucess++

								endif

								//cabecalho de contratos funerarios
							elseif UH8->UH8_ROTINA == "UF2"

								if U_RIMPF001(aLinhaValida,nHdlLog)

									//registros importados com sucesso
									nSucess++

								endif

								//cabecalho de titulos
							elseif UH8->UH8_ROTINA == "SE1"

								if U_RIMPM006(aLinhaValida,nHdlLog)

									//registros importados com sucesso
									nSucess++

								endif

								//Produtos/Servicos Funeraria
							elseif UH8->UH8_ROTINA == "UF3"

								if U_RIMPF005(aLinhaValida,nHdlLog)

									//registros importados com sucesso
									nSucess++

								endif

								//cabecalho de Beneficiarios
							elseif UH8->UH8_ROTINA == "UF4"

								if U_RIMPF003(aLinhaValida,nHdlLog)

									//registros importados com sucesso
									nSucess++

								endif

								//cabecalho de Mensagens
							elseif UH8->UH8_ROTINA == "UF9"

								if U_RIMPF004(aLinhaValida,nHdlLog)

									//registros importados com sucesso
									nSucess++

								endif

								//cabecalho de Convalescente
							elseif UH8->UH8_ROTINA == "UJH"

								if U_RIMPM008(aLinhaValida,nHdlLog,cCodigo)

									//registros importados com sucesso
									nSucess++

								endif

								//Itens de Convalescente
							elseif UH8->UH8_ROTINA == "UJI"

								if U_RIMPM009(aLinhaValida,nHdlLog,cCodigo)

									//registros importados com sucesso
									nSucess++

								endif

								//Cabecalho de contratos cemiterios
							elseif UH8->UH8_ROTINA == "U00"

								if U_RIMPC001(aLinhaValida, nHdlLog)

									//registros importados com sucesso
									nSucess++

								endif

								//Autorizados dos contratos cemiterios
							elseif UH8->UH8_ROTINA == "U02"

								if U_RIMPC002(aLinhaValida, nHdlLog)

									//registros importados com sucesso
									nSucess++

								endif

								//Mensagens dos contratos cemiterios
							elseif UH8->UH8_ROTINA == "U03"

								if U_RIMPC003(aLinhaValida, nHdlLog)

									//registros importados com sucesso
									nSucess++

								endif

								//Enderecamento cemiterios
							elseif UH8->UH8_ROTINA == "UJV"

								if U_RIMPC004(aLinhaValida, nHdlLog)

									//registros importados com sucesso
									nSucess++

								endif

								//Historico Transferencias cemiterios
							elseif UH8->UH8_ROTINA == "U38"

								if U_RIMPC005(aLinhaValida, nHdlLog)

									//registros importados com sucesso
									nSucess++

								endif

								//Retira de Cinzas Cemiterios
							elseif UH8->UH8_ROTINA == "U41"

								if U_RIMPC006(aLinhaValida, nHdlLog)

									//registros importados com sucesso
									nSucess++

								endif


								//Retira de historico de transferencia
							elseif UH8->UH8_ROTINA == "U19"

								if U_RIMPC009(aLinhaValida, nHdlLog)

									//registros importados com sucesso
									nSucess++

								endif

							endif

						endif

						// pula para próxima linha
						//FT_FSKIP()

						//reseto array de colunas validas
						aColunaVld		:= {}
						aLinhaArq		:= {}
						aLinhaValida	:= {}

					EndDo

					oReader:Close()

				endif

			endif

			//verifico se arquivo de log existe
			if nHdlLog > 0

				fWrite(nHdlLog , cPulaLinha )
				fWrite(nHdlLog , " >> Data Fim: " + DTOC( Date() ) )
				fWrite(nHdlLog , cPulaLinha )
				fWrite(nHdlLog , " >> Hora Fim: " + Time() )
				fWrite(nHdlLog , cPulaLinha )

			endif

		else

			lRet := .F.
			Help(,,'Help',,"Não foi possivel abrir o arquivo de importação, favor verifique o diretório selecionado!",1,0)

		endif

		//verifico se arquivo de log existe
		if nHdlLog > 0

			// fecho o arquivo de log
			fClose(nHdlLog)

		endif

	else
		lRet := .F.
		Help(,,'Help',,"Layout selecionado não encontrado, favor verifique o cadastro de layout de importacao!",1,0)
	endif

Return(lRet)

/*/{Protheus.doc} DeParaImp
Funcao para realizar o DE-PARA
das infomracoes de importacao 
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function DeParaImp(cCodLayout,cConteudoCpo,cCampo)

	Local aArea			:= GetArea()
	Local aAreaUH9		:= UH9->(GetArea())
	Local aAreaUI0		:= UI0->(GetArea())
	Local cQry 			:= ""

	cQry := " SELECT "
	cQry += " UI0_CONTPR CONT_PROTHEUS "
	cQry += " FROM  "
	cQry += " " + RetSQLName("UH8") + " UH8  "
	cQry += " INNER JOIN "
	cQry += " " + RetSQLName("UH9") + " UH9  "
	cQry += " ON UH8.D_E_L_E_T_ = ' '  "
	cQry += " AND UH9.D_E_L_E_T_ = ' ' "
	cQry += " AND UH8.UH8_FILIAL = UH9.UH9_FILIAL "
	cQry += " AND UH8.UH8_CODIGO = UH9.UH9_CODIGO "
	cQry += " INNER JOIN  "
	cQry += " " + RetSQLName("UI0") + " UI0 "
	cQry += " ON UI0.D_E_L_E_T_ = ' '  "
	cQry += " AND UH9.UH9_FILIAL = UI0.UI0_FILIAL "
	cQry += " AND UH9.UH9_CODIGO = UI0.UI0_CODIGO "
	cQry += " AND UH9.UH9_ITEM = UI0.UI0_ITEMPA "
	cQry += " WHERE "
	cQry += " UH8.UH8_FILIAL = '" + xFilial("UH8")+ "'  "
	cQry += " AND UH8_CODIGO = '" + cCodLayout + "'  "
	cQry += " AND UH9_CAMPO = '" + Alltrim(cCampo) + "'  "
	cQry += " AND UPPER(RTRIM(LTRIM(UI0_CONTLE))) = UPPER('" + Alltrim(cConteudoCpo) + "') "

	cQry := ChangeQuery(cQry)

	If Select("QRYDP") > 0
		QRYDP->(DbCloseArea())
	Endif

	TcQuery cQry NEW Alias "QRYDP"

	if QRYDP->(!Eof())

		cConteudoCpo := Alltrim(QRYDP->CONT_PROTHEUS)

	endif

	RestArea(aAreaUI0)
	RestArea(aAreaUH9)
	RestArea(aArea)

Return(cConteudoCpo)

/*/{Protheus.doc} ConverteData
Função para converter em Data
@type function
@version 1.0 
@author g.sampaio
@since 24/02/2022
@param cData, character, Data preenchida no arquivo de texto
@return date, data convertida
/*/
Static Function ConverteData(cData)

	Local dRetorno  := Stod("")

	Default cData := ""

	if !Empty(cData)

		if "/" $ AllTrim(cData)
			dRetorno := CtoD(cData) // dd/MM/aaaa
		else
			dRetorno := SToD(cData) // aaaaMMdd
		endIf

	endIf

Return(dRetorno)
