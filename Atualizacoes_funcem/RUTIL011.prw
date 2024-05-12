#include 'totvs.ch'
#include "fwmvcdef.ch"

#define CRLF chr(13)+chr(10)

/*/{Protheus.doc} UTBCIMP
Rotina de Importação de Ranges de Número da Sorte - Mongeral
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 26/02/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/
user function RUTIL011()

Local oPanel		    	:= NIL	
Local oNewPag		    	:= NIL
Local oStepWiz 		    := NIL
Local oDlg 			      := NIL
Local oPanelBkg		    := NIL

Private cArquivo	    := Space(300)
Private cArqRel		    := Space(300)
Private lContinua 	  := .T.

//crio dialog que ira receber o Wizard
DEFINE DIALOG oDlg TITLE 'Assistente de Importacao de Números da Sorte - Totvs Servicos Postumos' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )

oDlg:nWidth 	:= 800
oDlg:nHeight 	:= 620

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

//////////////////////////////////////////////////////////////////
///crio a pagina 2 do wizard - Estrutura do Arquivo
/////////////////////////////////////////////////////////////////

oNewPag := oStepWiz:AddStep("2", {|Panel|fEstruArquivo(Panel, @nHdlEstru)})

//Altero a descrição do step
oNewPag:SetStepDescription("Estrutura do Arquivo")

oNewPag:SetNextAction({||VldOpenFile()})

//Defino o bloco ao clicar no botão Cancelar
oNewPag:SetCancelAction({||.T.,oDlg:End()})

/////////////////////////////////////////////////////////
///crio a pagina 3 do wizard - Dados do Arquivo
/////////////////////////////////////////////////////////

oNewPag := oStepWiz:AddStep("3", {|Panel|RelImport(Panel)})

//Altero a descrição do step
oNewPag:SetStepDescription("Dados do Arquivo")

oNewPag:SetNextAction({|| VldArqRel() })

//Defino o bloco ao clicar no botão Cancelar
oNewPag:SetCancelAction({||oDlg:End()})

/////////////////////////////////////////////////////////
///crio a pagina 4 do wizard - Validação do Arquivo
/////////////////////////////////////////////////////////

oNewPag := oStepWiz:AddStep("4", {|Panel| TelaResult(Panel) })

//Altero a descrição do step
oNewPag:SetStepDescription("Validação do Arquivo")

oNewPag:SetNextAction({||oDlg:End(),.T.})

/////////////////////////////////////////////////////////
///crio a pagina 5 do wizard - Processamento do Arquivo
/////////////////////////////////////////////////////////

oNewPag := oStepWiz:AddStep("5", {|Panel| TelaResult(Panel) })

//Altero a descrição do step
oNewPag:SetStepDescription("Processamento do Arquivo")

oNewPag:SetNextAction({||oDlg:End(),.T.})

//Defino o bloco ao clicar no botão Cancelar
oNewPag:SetCancelAction({||.F.})

oNewPag:SetCancelWhen({||.F.})

oNewPag:SetPrevAction({||.F.})

oStepWiz:Activate()

ACTIVATE DIALOG oDlg CENTER

oStepWiz:Destroy()

Return()

/*/{Protheus.doc} ProcessaImp
Funcao para ler o arquivo de texto
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 21/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
static function ProcessaImp( oSay, nRowsProces, nSucess )

Local nHandle       := 0
Local aBuffer       := {}
Local cLine         := ""
Local aCabec        := {}
Local nI            := 0
Local lContinua     := .T.
Local nQtdProc      := 0
Local cDrive		:= "" 
Local cDiretorio	:= ""
Local cNomeArq		:= ""
Local cExtensao		:= ""
Local lRFUNE030		:= Existblock("RFUNE030")

Default nRowsProces := 0
Default nSucess     := 0

// verifico s eo arquivo de texto esta preenchido
if !empty(cArquivo)
	
  //faco a reparticao do arquivo para validar a extensao do arquivo
  SplitPath(cArquivo, @cDrive, @cDiretorio, @cNomeArq, @cExtensao )
  
  //valido a extensao do arquivo
  if Upper(Alltrim(cExtensao)) == ".CSV" 
  
	  // abro o arquivo de texto
	  nHandle 	:= FT_FUse(cArquivo)
	
	  // abriu o arquivo
	  If nHandle > 0
	
	    //verifico se arquivo de log existe 
	    if nHdlLog > 0 
	    
	      fWrite(nHdlLog , "#########  IMPORTACAO DE NUMEROS DA SORTE MONGERAL - TSP  #############")
	      fWrite(nHdlLog , CRLF )
	      fWrite(nHdlLog , " >> Data Inicio: " + DTOC( Date() ) )
	      fWrite(nHdlLog , CRLF )
	      fWrite(nHdlLog , " >> Hora Inicio: " + Time() )
	      fWrite(nHdlLog , CRLF ) 
	      fWrite(nHdlLog , " >> Arquivo Mongeral : " + cArquivo )
	      fWrite(nHdlLog , CRLF ) 
	    
	    endif
	    
	    //Carrega quantidade de linhas
	    nQtdProc := FT_FLASTREC()-1
	
	    FT_FGoTop() //Posiciona na primeira linha do arquivo texto de importação
	    
	    // vejo se nao estou no final do arquivo
	    If !FT_FEOF()
	
	      // vou pegar as informacoes do cabelho do arquivo
	      aBuffer 	:= {}                     // zero o array de dados
	      cLine  		:= FT_FReadLn()           // pego as informacoes da linha do arquivo
	      aBuffer	 	:= STRTOKARR(cLine, ";")  // quebro as informacoes da linha e alimento o array de dados
	      
	      aCabec := aBuffer
	      
	      FT_FSKIP() //passa para proxima linha
	      
	      // percorro o arquivo enquando nao chegar ao final
	      While !FT_FEOF()
	        
	        // retorno as variaveis para o seu valor inicial
	        cLine  		:= ""
	        aBuffer	 	:= ""
	        cLine  		:= FT_FReadLn()
	        lContinua := .T.
	
	        // criando o array de importacao
	        aBuffer	 	:= STRTOKARR(cLine, ";")
	
	        // conntador de linhas processadas
	        nRowsProces++
	
	        oSay:cCaption := "Lendo Linha " + cValToChar(nRowsProces) + " de um total de " + cValToChar(nQtdProc) + "."
	        ProcessMessages()
	
	        /**
	        layout do arquivo mongeral -
	        [1] parceiro
	        [2] numeroPropostaParceiro
	        [3] numeroSorte
	        [4] vazio
	        [5] #g36 (controle interno)
	        [6] empresa
	        */
	
	        // vou validar os dados do arquivo
	        for nI := 1 to len( aBuffer )
	          
	          // valido se existe dados para serem importados
	          if nI <> 4 .and. Empty( alltrim( aBuffer[nI] ) )
	             
	            //verifico se arquivo de log existe 
	            if nHdlLog > 0 
	        
	              fWrite(nHdlLog , '-----------------------------------------------' )
	              fWrite(nHdlLog , CRLF )
	              fWrite(nHdlLog , "Processando Linha: " + StrZero(nRowsProces,7) + " " )
	              fWrite(nHdlLog , CRLF )
	              fWrite(nHdlLog , '-----------------------------------------------' )
	              fWrite(nHdlLog , CRLF )
								fWrite(nHdlLog , " A posição: " + cValToChar(nI) + " faz com o que o Layout do arquivo esteja diferente do esperado!" )
								fWrite(nHdlLog , CRLF )
	
	              lContinua := .F.
	
	              Exit 
	
	            endIf
	            
	          endIf
	
	        next nI
	                
	        // vejo se a funcao esta compilada no repositorio
	        if lRFune030
	          if lContinua
	            lContinua := U_RFUNE030( aBuffer, @nHdlLog )
	          endIf
	        else
	          lContinua := .F.
	          
	          //verifico se arquivo de log existe 
	          if nHdlLog > 0
	          	fWrite(nHdlLog , "Função <RFUNE030> não encontrada no repositório, favor entrar em contato com o Equipe de TI ou Equipe TOTVS." )
							fWrite(nHdlLog , CRLF )
	          EndIf
	        endif
	
	        // mensagem de retorno
	        if lContinua
	          //verifico se arquivo de log existe
	          if nHdlLog > 0
	            fWrite(nHdlLog , "Linha:" + StrZero(nRowsProces,6) + " processada, número da sorte importado com sucesso!" )
	            fWrite(nHdlLog , CRLF )
	          EndIf
	        else
	          //verifico se arquivo de log existe
	          if nHdlLog > 0
	            fWrite(nHdlLog , "Linha:" + StrZero(nRowsProces,6) + " processada, número da sorte não foi importado" )
	            fWrite(nHdlLog , CRLF )
	          EndIf
	        endIf
	
	        // se importou todos os registros com sucesso
	        if lContinua
	          nSucess++
	        endIf
	
	        FT_FSKIP() //passa para proxima linha
	        
	      EndDo
	      
	    EndIf
	  else
	    lContinua := .F.
	
	    //verifico se arquivo de log existe 
	    if nHdlLog > 0
	     	
	    	fWrite(nHdlLog , "Não foi possível abrir o arquivo de importação!" )
			fWrite(nHdlLog , CRLF )
	    
	    EndIf
	  
	  endIf
   
   else
   		
   		//verifico se arquivo de log existe 
	    if nHdlLog > 0
	     	
	    	fWrite(nHdlLog , "É possivel importar apenas arquivos com extensão .CSV!" )
			fWrite(nHdlLog , CRLF )
	    
	    EndIf
   		
   
   endif
	
	
else
  lContinua := .F.
  //verifico se arquivo de log existe 
  if nHdlLog > 0
   	fWrite(nHdlLog , "Arquivo de Importação de Ranges de Número da Sorte - Mongeral, não foi preenhcido!" )
	  fWrite(nHdlLog , CRLF )
  EndIf
endIf

//verifico se arquivo de log existe 
if nHdlLog > 0 		
	fWrite(nHdlLog , " >> Data Fim: " + DTOC( Date() ) )
	fWrite(nHdlLog , CRLF )
	fWrite(nHdlLog , " >> Hora Fim: " + Time() )
	fWrite(nHdlLog , CRLF )
endif

	//verifico se arquivo de log existe 
	if nHdlLog > 0 
		
		// fecho o arquivo de log
		fClose(nHdlLog)
	
	endif

return

/*/{Protheus.doc} Pag1Intrucoes
Instrucoes Iniciais do Wizard de Importacao
 
@author g.sampaio
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
	Local cTexto1		:= ""
	
	//crio a parte superior da tela do wizard
	CriaPartSup(oPanel)
	
	@ 045 , 020 SAY oSay4 PROMPT "Bem Vindo..." SIZE 200, 010 Font oFnt18 OF oPanel COLORS 0, 16777215 PIXEL
	
	cTexto1 += "O Objetivo da rotina de “Compatibilizador de Diconário de Dados” é compatibilizar a base do dicionário de dados " + CRLF 
	cTexto1 += " de acordo com os arquivos CSV, que estão no diretório “Systemload” do RootPath (Protheus_Data), validar a " + CRLF 
	cTexto1 += " estrutura dos arquivos, autenticando os dados a serem alterados ou criados no dicionário, de forma que o " + CRLF 
	cTexto1 += " usuário consiga fazer a compatibilização do dicionário de dados de forma simples e prática, parametrizando " + CRLF 
	cTexto1 += " os módulos de Gestão de Planos Funerários e Gestão de Cemitérios. " + CRLF 
	
	@ 065 , 020 SAY oSay1 PROMPT cTexto1 SIZE 300, 300 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL


Return()

/*/{Protheus.doc} TelaResult
Funcao para montar tela de resultado final
da importacao 
@author g.sampaio
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/										
Static Function TelaResult(oPanel)

Local oSay1 		   	:= NIL
Local oSay2 		   	:= NIL
Local oGroup1		    := NIL
Local oProcessados  	:= NIL
Local oSucesso	    	:= NIL
Local oFnt16	      	:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
Local oFnt16N	      	:= TFont():New("Arial",,16,,.T.,,,,,.F.,.F.)
Local nLarguraPnl     	:= oPanel:nClientWidth / 2
Local cTexto1		   	:= ""
Local nRowsProces	    := 0
Local nSucess		    := 0 

//crio a parte superior da tela do wizard
CriaPartSup(oPanel)

FWMsgRun(,{|oSay| ProcessaImp(oSay,@nRowsProces,@nSucess)},'Aguarde...','Processando Importação de Números da Sorte - Totvs Serviços Póstumos.')

@ 045 , 020 SAY oSay4 PROMPT "Processo de Importação finalizado" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

cTexto1 := "Processo de Importação finalizado, abaixo segue os dados processos e os dados importados com sucesso!	" + CRLF

@ 060 , 020 SAY oSay1 PROMPT cTexto1 SIZE 300, 300 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

@ 090 , 020 SAY oSay2 PROMPT "Resultado da Importação:" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

@ 100 , 020 GROUP oGroup1 TO 102 , nLarguraPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL

@ 107 , 020 SAY oSay3 PROMPT "Linhas Processadas:" SIZE 080, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

@ 107 , 100 MSGET oProcessados VAR nRowsProces  SIZE 080,010 READONLY PIXEL  Font oFnt16 OF oPanel PICTURE "@E 9999999"

@ 120 , 020 SAY oSay4 PROMPT "Linhas Importadas:" SIZE 080, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

@ 120 , 100 MSGET oSucesso VAR nSucess  SIZE 080,010 PIXEL  READONLY Font oFnt16 OF oPanel PICTURE "@E 9999999"

@ 140 , 020 BUTTON oBtnImp PROMPT "Visualizar Log" SIZE 070, 015 OF oPanel PIXEL ACTION (ShellExecute("Open", cArqRel + ".log", " ", "C:\", 1 ))

Return()

/*/{Protheus.doc} RelContinuaort
Funcao para montar panel de selecao
do arquivo de log a ser gerado da importacao
@author g.sampaio
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
Local cTexto1		:= ""
Local cImgArq		:= "icone_file.png"
Local cImgFileHover	:= "icone_file_foco.png"
Local cCSSBtnFile	:= ""

//crio a parte superior da tela do wizard
CriaPartSup(oPanel)

@ 045 , 020 SAY oSay4 PROMPT "Informe o local do relatório de importação" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

cTexto1 := " Após a importação dos dados o sistema irá gerar um relatório constando todas informações referentes a importação de dados.	" + CRLF

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

/*/{Protheus.doc} VldArquivo
Funcao para validar o get do arquivo 
de importacao
@author g.sampaio
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

/*/{Protheus.doc} fEstruArquivo
Panel de validacao da estrutura do arquivo
@author g.sampaio
@since 12/04/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function fEstruArquivo(oPanel, nHdlEstru)

Local oFnt16				:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
Local oFnt16N				:= TFont():New("Arial",,16,,.T.,,,,,.F.,.F.)
Local oArquivo			:= NIL
Local oBtnRel				:= NIL
Local nLarguraPnl		:= oPanel:nClientWidth / 2
Local cTexto1				:= ""
Local cImgArq				:= "icone_file.png"
Local cImgFileHover	:= "icone_file_foco.png"
Local cCSSBtnFile		:= ""
Local cArqEstru			:= ""
Local oBmp1					:= Nil
Local oBtnLog				:= Nil

Default nHdlEstru		:= 0

//crio a parte superior da tela do wizard
CriaPartSup(oPanel)

@ 045 , 020 SAY oSay1 PROMPT "Status dos Arquivos de Compatibilização" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

@ 060 , 020 BITMAP oBmp1 ResName fLegSX("SX2", nHdlEstru) OF oPanel Size 10,10 NoBorder When .F. Pixel
@ 060 , 030 SAY oSay2 PROMPT "SX2 - Tabelas" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

@ 075 , 020 BITMAP oBmp1 ResName fLegSX("SX3", nHdlEstru) OF oPanel Size 10,10 NoBorder When .F. Pixel
@ 075 , 030 SAY oSay3 PROMPT "SX3 - Campos" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

@ 090 , 020 BITMAP oBmp1 ResName fLegSX("SX6", nHdlEstru) OF oPanel Size 10,10 NoBorder When .F. Pixel
@ 090 , 030 SAY oSay4 PROMPT "SX6 - Parametros" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

@ 105 , 020 BITMAP oBmp1 ResName fLegSX("SX7", nHdlEstru) OF oPanel Size 10,10 NoBorder When .F. Pixel
@ 105 , 030 SAY oSay5 PROMPT "SX7 - Gatilhos" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

@ 120 , 020 BITMAP oBmp1 ResName fLegSX("SX9", nHdlEstru) OF oPanel Size 10,10 NoBorder When .F. Pixel
@ 120 , 030 SAY oSay6 PROMPT "SX9 - Relacionamento de Tabelas" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

@ 135 , 020 BITMAP oBmp1 ResName fLegSX("SIX", nHdlEstru) OF oPanel Size 10,10 NoBorder When .F. Pixel
@ 135 , 030 SAY oSay7 PROMPT "SIX - Indices" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

@ 150 , 020 BITMAP oBmp1 ResName fLegSX("SXA", nHdlEstru) OF oPanel Size 10,10 NoBorder When .F. Pixel
@ 150 , 030 SAY oSay8 PROMPT "SXA - Pastas/Agrupadores" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

@ 165 , 020 BITMAP oBmp1 ResName fLegSX("SXB", nHdlEstru) OF oPanel Size 10,10 NoBorder When .F. Pixel
@ 165 , 030 SAY oSay9 PROMPT "SXB - Consultas Padrão" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

// descricao das legendas
@ 190 , 080 BITMAP oBmp1 ResName "BR_VERDE" OF oPanel Size 10,10 NoBorder When .F. Pixel
@ 190 , 090 SAY oSay10 PROMPT "Arquivo Validado" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

@ 190 , 160 BITMAP oBmp1 ResName "BR_AMARELO" OF oPanel Size 10,10 NoBorder When .F. Pixel
@ 190 , 170 SAY oSay11 PROMPT "Arquivo Não Validado" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

@ 190 , 240 BITMAP oBmp1 ResName "BR_VERMELHO" OF oPanel Size 10,10 NoBorder When .F. Pixel
@ 190 , 250 SAY oSay12 PROMPT "Arquivo Não Existente" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

// visualizar log
@ 165 , 300 BUTTON oBtnLog PROMPT "Visualizar Log" SIZE 070, 015 OF oPanel PIXEL ACTION (ShellExecute("Open", cArqLog + ".log", " ", "C:\", 1 ))

Return()

/*/{Protheus.doc} Pag2Layout
Cria parte superior do panel do
wizard com a logo e texto explicativo
@author g.sampaio
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

@ 030 , 055 SAY oSay3 PROMPT "Importação de Número da Sorte para o Totvs Serviços Póstumos" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

@ 040 , 020 GROUP oGroup1 TO 042 , nLarguraPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL

Return()

/*/{Protheus.doc} VldArqRel
Funcao para validar o arquivo digitado para
geracao do relatorio
@author g.sampaio
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

/*/{Protheus.doc} RUT011LG
Funcao para lengenda
@author g.sampaio
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function RUT011LG()
  BrwLegenda("Ranges de Numero da Sorte","Legenda",{{"BR_VERDE","Numero da Sorte Nao Utilizado"},{"BR_VERMELHO","Numero da Sorte Utilizado"}})
return()

/*/{Protheus.doc} fLegSX
Pega o status do arquivo de compatiblizacao e valida a estrutura do arquivo
geracao do relatorio
@author g.sampaio
@since 15/04/2019
@version P12
@return cRet, caracter, status do dicionario
@param cTabela, caracter, descricao do arquivo
@return nulo
/*/

Static Function fLegSX( cTabela )

Local aArea 	:= GetArea()
Local cRet		:= ""
Local cPrefix 	:= "tbcpar"
Local cArquivo	:= ""
Local lEstrut	:= .T. 

Default cTabela := ""

// verifico se o arquivo esta presente na systemload
if !empty( Alltrim( cTabela ) )

	// monto a descricao do arquivo
	cArquivo := iif(IsSrvUnix(),"/","\") + "systemload" + iif(IsSrvUnix(),"/","\") + "partsp" + iif(IsSrvUnix(),"/","\") + Alltrim(cTabela) + "_" + cPrefix + ".csv" 

	// verifico se o arquivo existe
	if File(cArquivo)

		// verifico a estrutura do arquivo
		lEstrut := fEstruSX( cTabela, cArquivo )

		// verifico se a estrutura esta correta
		if lEstrut
			cRet := "BR_VERDE"
		else
			cRet := "BR_AMARELO"
		endIf

	else
		cRet := "BR_VERMELHO"
	endIf

else
	cRet := "BR_VERMELHO"
endIf

RestArea(aArea)

Return(cRet)

/*/{Protheus.doc} fEstruSX
Valigo a estrutura do arquivo
geracao do relatorio
@author g.sampaio
@since 15/04/2019
@version P12
@return cRet, caracter, status do dicionario
@param cTabela, caracter, descricao do arquivo
@param cArquivo, caracter, endereco do arquivo
@return nulo
/*/

Static Function fEstruSX( cTabela, cArquivo )

Local aArea 	:= GetArea()
Local aFile		:= {}
Local aCabec	:= {}
Local aSX2		:= {}
Local aSX3		:= {}
Local aSX6		:= {}
Local aSX7		:= {}
Local aSX9		:= {}
Local aSIX		:= {}
Local aSXA		:= {}
Local aSXB		:= {}
Local aStru		:= {}
Local cLinha	:= ""
Local lRet 		:= .T.
Local oFile		:= Nil
Local oWriter	:= Nil

Default cTabela		:= ""
Default cArquivo	:= ""

// vou alimentar a estrutura da SX - SX2
aadd(aSX2,{"X2_CHAVE"	})
aadd(aSX2,{"X2_PATH"	})
aadd(aSX2,{"X2_ARQUIVO"	})
aadd(aSX2,{"X2_NOME"	})
aadd(aSX2,{"X2_NOMESPA"	})
aadd(aSX2,{"X2_NOMEENG"	})
aadd(aSX2,{"X2_ROTINA"	})
aadd(aSX2,{"X2_MODO"	})
aadd(aSX2,{"X2_MODOUN"	})
aadd(aSX2,{"X2_MODOEMP"	})
aadd(aSX2,{"X2_DELET"	})
aadd(aSX2,{"X2_TTS"		})
aadd(aSX2,{"X2_UNICO"	})
aadd(aSX2,{"X2_PYME"	})
aadd(aSX2,{"X2_MODULO"	})
aadd(aSX2,{"X2_DISPLAY"	})

// vou alimentar a estrutura da SX - SX3
aadd(aSX3,{"X3_ARQUIVO"	})
aadd(aSX3,{"X3_ORDEM"	})
aadd(aSX3,{"X3_CAMPO"	})
aadd(aSX3,{"X3_TIPO"	})
aadd(aSX3,{"X3_TAMANHO"	})
aadd(aSX3,{"X3_DECIMAL"	})
aadd(aSX3,{"X3_TITULO"	})
aadd(aSX3,{"X3_TITSPA"	})
aadd(aSX3,{"X3_TITENG"	})
aadd(aSX3,{"X3_DESCRIC"	})
aadd(aSX3,{"X3_DESCSPA"	})
aadd(aSX3,{"X3_DESCENG"	})
aadd(aSX3,{"X3_PICTURE"	})
aadd(aSX3,{"X3_VALID"	})
aadd(aSX3,{"X3_USADO"	})
aadd(aSX3,{"X3_RELACAO"	})
aadd(aSX3,{"X3_F3" 		})
aadd(aSX3,{"X3_NIVEL"	})
aadd(aSX3,{"X3_RESERV"	})
aadd(aSX3,{"X3_CHECK"	})
aadd(aSX3,{"X3_TRIGGER"	})
aadd(aSX3,{"X3_PROPRI"	})
aadd(aSX3,{"X3_BROWSE"	})
aadd(aSX3,{"X3_VISUAL"	})
aadd(aSX3,{"X3_CONTEXT"	})
aadd(aSX3,{"X3_OBRIGAT"	})
aadd(aSX3,{"X3_VLDUSER"	})
aadd(aSX3,{"X3_CBOX"	})
aadd(aSX3,{"X3_CBOXSPA"	})
aadd(aSX3,{"X3_CBOXENG"	})
aadd(aSX3,{"X3_PICTVAR"	})
aadd(aSX3,{"X3_WHEN"	})
aadd(aSX3,{"X3_INIBRW"	})
aadd(aSX3,{"X3_GRPSXG"	})
aadd(aSX3,{"X3_FOLDER"	})
aadd(aSX3,{"X3_PYME"	})
aadd(aSX3,{"X3_CONDSQL"	})
aadd(aSX3,{"X3_CHKSQL"	})
aadd(aSX3,{"X3_IDXSRV"	})
aadd(aSX3,{"X3_ORTOGRA"	})
aadd(aSX3,{"X3_IDXFLD"	})
aadd(aSX3,{"X3_TELA"	})
aadd(aSX3,{"X3_AGRUP"	})

// vou alimentar a estrutura da SX - SX6
aadd(aSX6,{"X6_FIL"		})
aadd(aSX6,{"X6_VAR"		})
aadd(aSX6,{"X6_TIPO"	})
aadd(aSX6,{"X6_DESCRIC"	})
aadd(aSX6,{"X6_DSCSPA"	})
aadd(aSX6,{"X6_DSCENG"	})
aadd(aSX6,{"X6_DESC1"	})
aadd(aSX6,{"X6_DSCSPA1"	})
aadd(aSX6,{"X6_DSCENG1"	})
aadd(aSX6,{"X6_DESC2"	})
aadd(aSX6,{"X6_DSCSPA2"	})
aadd(aSX6,{"X6_DSCENG2"	})
aadd(aSX6,{"X6_CONTEUD"	})
aadd(aSX6,{"X6_CONTSPA"	})
aadd(aSX6,{"X6_CONTENG"	})
aadd(aSX6,{"X6_PROPRI"	})
aadd(aSX6,{"X6_VALID"	})
aadd(aSX6,{"X6_INIT"	})
aadd(aSX6,{"X6_DEFPOR"	})
aadd(aSX6,{"X6_DEFSPA"	})
aadd(aSX6,{"X6_DEFENG"	})

// vou alimentar a estrutura da SX - SX7
aadd(aSX7,{"X7_CAMPO"	})
aadd(aSX7,{"X7_SEQUENC"	})
aadd(aSX7,{"X7_REGRA"	})
aadd(aSX7,{"X7_CDOMIN"	})
aadd(aSX7,{"X7_TIPO"	})
aadd(aSX7,{"X7_SEEK"	})
aadd(aSX7,{"X7_ALIAS"	})
aadd(aSX7,{"X7_ORDEM"	})
aadd(aSX7,{"X7_CHAVE"	})
aadd(aSX7,{"X7_CONDIC"	})
aadd(aSX7,{"X7_PROPRI"	})

// vou alimentar a estrutura da SX - SX9
aadd(aSX9,{"X9_DOM"		})
aadd(aSX9,{"X9_IDENT"	})
aadd(aSX9,{"X9_CDOM"	})
aadd(aSX9,{"X9_EXPDOM"	})

// vou alimentar a estrutura da SX - SIX
aadd(aSIX,{"INDICE"		})
aadd(aSIX,{"ORDEM"		})
aadd(aSIX,{"CHAVE"		})
aadd(aSIX,{"DESCRICAO"	})
aadd(aSIX,{"DESCSPA"	})
aadd(aSIX,{"DESCENG"	})
aadd(aSIX,{"PROPRI"		})
aadd(aSIX,{"F3"			})
aadd(aSIX,{"NICKNAME"	})
aadd(aSIX,{"SHOWPESQ"	})

// vou alimentar a estrutura da SX - SXA
aadd(aSXA,{"XA_ALIAS"		})
aadd(aSXA,{"XA_ORDEM"		})
aadd(aSXA,{"XA_DESCRIC"		})
aadd(aSXA,{"XA_DESCSPA"		})
aadd(aSXA,{"XA_DESCENG"		})
aadd(aSXA,{"XA_PROPRI"		})
aadd(aSXA,{"XA_AGRUP"		})
aadd(aSXA,{"XA_TIPO"		})

// vou alimentar a estrutura da SX - SXB
aadd(aSXB,{"XB_ALIAS"	})
aadd(aSXB,{"XB_TIPO"	})
aadd(aSXB,{"XB_SEQ"		})
aadd(aSXB,{"XB_COLUNA"	})
aadd(aSXB,{"XB_DESCRI"	})
aadd(aSXB,{"XB_DESCSPA"	})
aadd(aSXB,{"XB_DESCENG"	})
aadd(aSXB,{"XB_CONTEM"	})
aadd(aSXB,{"XB_WCONTEM"	})

// verifica se o arquivo esta preenchido
if Empty( Alltrim( cArquivo ) )

	// abro o arquivo utilizando a classe FWFileReader
	oWriter := FWFileReader():New(Lower(cArquivo))
	
	// verifico se abriu o arquivo
  if (oWriter:Open())
        
		// retorna as linhas do arquivo em um array
        aFile := oWriter:getAllLines()

		// verifico se o aFiles esta preenchido corretamente
		if Len(aFile) > 0
			if Len(aFile) > 1

			else
				lRet := .F.
				fGeraLog( @oWriter, "Arquivo <" + cArquivo  + "> sem dados para importação!" )				
			endIf
		else
			fGeraLog( @oWriter, "Arquivo <" + cArquivo  + "> com arquivo vazio!" )				
			lRet := .F.
		endIf

		// fecho o arquivo
    oWriter:Close()
	else
		fGeraLog( @oWriter, "Arquivo <" + cArquivo  + "> não foi aberto corretamente, erro : " + oWriter:oErroLog:Message )				
		lRet := .F.
  endIf

  // libero o alias 
  FreeObj(oWriter)
  oWriter := Nil

endIf

// verifico qual dicionario estou validando
Do Case
	Case Alltrim( cTabela ) == "SX2"
	
	Case Alltrim( cTabela ) == "SX3"
	
	Case Alltrim( cTabela ) == "SX6"
	
	Case Alltrim( cTabela ) == "SX7"
	
	Case Alltrim( cTabela ) == "SX9"
	
	Case Alltrim( cTabela ) == "SIX"
	
	Case Alltrim( cTabela ) == "SXA"
	
	Case Alltrim( cTabela ) == "SXB"
	
	Otherwise
		lRet := .F.
EndCase

RestArea( aArea )

Return(lRet)

/*/{Protheus.doc} fGeraLog
Gero o arquivo de log da estrutura
geracao do relatorio
@author g.sampaio
@since 15/04/2019
@version P12
@return cRet, caracter, status do dicionario
@param oWriter, objeto, objeto de montagem do arquivo
@param cTexto, caracter, texto a ser escrito no arquivo
@return nulo
/*/

Static Function fGeraLog( oWriter, cTexto )

Local aArea		:= GetArea()

Default cTexto	:= ""

// se o objeto oWriter estiver como nulo
if oWriter == Nil

	// gero o nome do arquivo
	cArqLog := iif(IsSrvUnix(),"/","\") + "systemload" + iif(IsSrvUnix(),"/","\") + "partsp" + iif(IsSrvUnix(),"/","\") + "logtbcimp_" + criatrab( Nil, .F. ) + ".txt"

	// crio o objeto de escrita de arquivo
	oWriter := FWFileWriter():New( cArqLog, .T.)

else// caso nao for nulo
	oWriter:Write( CRLF )
	oWriter:Write( cTexto + CRLF)
	oWriter:Write( CRLF )
endIf

RestArea( aArea )

Return()