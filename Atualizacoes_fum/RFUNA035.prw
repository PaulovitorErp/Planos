#include 'totvs.ch'
#include "fwmvcdef.ch"

#define CRLF chr(13)+chr(10)

/*/{Protheus.doc} RFUNA035
Rotina de Importação de Ranges de Número da Sorte - Mongeral
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 21/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
user function RFUNA035()

Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('UI1')
oBrowse:SetDescription('Ranges de Número da Sorte')
oBrowse:AddLegend( "UI1_UTIL=='1'", "RED"     , "Numero da Sorte Utilizado" )
oBrowse:AddLegend( "UI1_UTIL=='2'", "GREEN"   , "Numero da Sorte Nao Utilizado" )
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'VIEWDEF.RFUNA035' OPERATION 02 ACCESS 0
ADD OPTION aRotina TITLE 'Importar'     ACTION 'U_RFUNA35A()'     OPERATION 03 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'      ACTION 'VIEWDEF.RFUNA035' OPERATION 05 ACCESS 0
ADD OPTION aRotina TITLE 'Legenda'      ACTION 'U_FUN35LEG()'     OPERATION 06 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Rotina de Importação de Ranges de Número da Sorte - Mongeral
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 21/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruUI1 := FWFormStruct( 1, 'UI1', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('PFUNA035', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'UI1MASTER', /*cOwner*/, oStruUI1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( 'Importação de Ranges de Número da Sorte - Mongeral' )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'UI1MASTER' ):SetDescription( 'Importação de Ranges de Número da Sorte' )

// informo a chave primaria
oModel:SetPrimaryKey( { "UI1_FILIAL", "UI1_NUMPRO" } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Rotina de Importação de Ranges de Número da Sorte - Mongeral
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 21/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'RFUNA035' )
// Cria a estrutura a ser usada na View
Local oStruUI1 := FWFormStruct( 2, 'UI1' )

Local oView
Local cCampos := {}

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_UI1', oStruUI1, 'UI1MASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_UI1', 'TELA' )

Return oView

/*/{Protheus.doc} RFUNA35A
Rotina de Importação de Ranges de Número da Sorte - Mongeral
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 21/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
user function RFUNA35A()

Local oPanel		      := NIL	
Local oNewPag		      := NIL
Local oStepWiz 		    := NIL
Local oDlg 			      := NIL
Local oPanelBkg		    := NIL

Private cArquivo	    := Space(300)
Private cArqRel		    := Space(300)
Private nHdlLog		    := 0 
Private lContinua 	  := .T.

//crio dialog que ira receber o Wizard
DEFINE DIALOG oDlg TITLE 'Assistente de Importacao de Números da Sorte - Totvs Servicos Postumos' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )

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

//////////////////////////////////////////////////////////////////
///crio a pagina 2 do wizard - Selecao de Arquivo de Importacao
/////////////////////////////////////////////////////////////////

oNewPag := oStepWiz:AddStep("2", {|Panel|ArquivoImp(Panel)})

//Altero a descrição do step
oNewPag:SetStepDescription("Arquivo de Importacao")

oNewPag:SetNextAction({||VldOpenFile()})

//Defino o bloco ao clicar no botão Cancelar
oNewPag:SetCancelAction({||.T.,oDlg:End()})

/////////////////////////////////////////////////////////
///crio a pagina 3 do wizard - Relatorio de Importacao
/////////////////////////////////////////////////////////

oNewPag := oStepWiz:AddStep("3", {|Panel|RelImport(Panel)})

//Altero a descrição do step
oNewPag:SetStepDescription("Relatorio de Importacao")

oNewPag:SetNextAction({|| VldArqRel() })

//Defino o bloco ao clicar no botão Cancelar
oNewPag:SetCancelAction({||oDlg:End()})

/////////////////////////////////////////////////////////
///crio a pagina 4 do wizard - Processamento da Importacao
/////////////////////////////////////////////////////////

oNewPag := oStepWiz:AddStep("4", {|Panel| TelaResult(Panel) })

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
	        if lRFUNE030
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
	
	cTexto1 += "O Objetivo da rotina de importação de ranges do número da sorte é disponibilizar os números para a "        + CRLF
	cTexto1 += "participação dos titulares dos contratos em sorteios.  A importação será executada através da leitura do"		+ CRLF
  cTexto1 += "arquivo disponibilizado pela Mongeral"                                                                      + CRLF
	
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

Local oSay1 		      := NIL
Local oSay2 		      := NIL
Local oGroup1		      := NIL
Local oProcessados  	:= NIL
Local oSucesso	    	:= NIL
Local oFnt16	      	:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
Local oFnt16N	      	:= TFont():New("Arial",,16,,.T.,,,,,.F.,.F.)
Local nLarguraPnl     := oPanel:nClientWidth / 2
Local cTexto1		      := ""
Local nRowsProces	    := 0
Local nSucess		      := 0 

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


/*/{Protheus.doc} Pag2Layout
Panel de selecao do arquivo de importacao
@author g.sampaio
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
Local cTexto1		:= ""
Local cImgArq		:= "icone_file.png"
Local cImgFileHover	:= "icone_file_foco.png"
Local cCSSBtnFile	:= ""

//crio a parte superior da tela do wizard
CriaPartSup(oPanel)

@ 045 , 020 SAY oSay4 PROMPT "Informe o arquivo de importacao" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

cTexto1 += " O Arquivo de importação devera conter os numeros da sorte a serem importados	" + CRLF
cTexto1 += " Estes numeros da sorte deverão estar de acordo com o layout definido pela seguradora e no formato .CSV 					" + CRLF

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

/*/{Protheus.doc} FUN35LEG
Funcao para validar o arquivo digitado para
geracao do relatorio
@author g.sampaio
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function FUN35LEG()
  BrwLegenda("Ranges de Numero da Sorte","Legenda",{{"BR_VERDE","Numero da Sorte Nao Utilizado"},{"BR_VERMELHO","Numero da Sorte Utilizado"}})
return 
