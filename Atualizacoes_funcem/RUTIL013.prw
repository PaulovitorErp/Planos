#include "totvs.ch"

/*/{Protheus.doc} UTBCINFO
Funcao para listar os parametros de um projeto em especifico
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 12/03/2019
@version 1.0
@param nil
@return nil
@type function
/*/

User Function RUTIL013()

Local cDirOrig      := space(250)
Local cDirDest      := space(250)
Local cImgArq		:= "icone_file.png"
Local cImgFileHover	:= "icone_file_foco.png"
Local oButton1      := Nil
Local oButton2      := Nil
Local oGet1         := Nil
Local oGet2         := Nil
Local oGroup1       := Nil
Local oBtnOrig      := Nil
Local oBtnDest      := Nil
Local oSay1         := Nil
Local oSay2         := Nil
Local oSay          := Nil

Private aParam      := {}

Static oDlg         := Nil

DEFINE MSDIALOG oDlg TITLE "Lista Parametros" FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL

    @ 004, 003 GROUP oGroup1 TO 194, 296 PROMPT "Selecione" OF oDlg COLOR 0, 16777215 PIXEL

    @ 024, 017 SAY oSay1 PROMPT "Diretório de Origem" SIZE 057, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 022, 098 MSGET oGet1 VAR cDirOrig  SIZE 178, 010 OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON    

    // busco o diretorio de origem 
    oBtnOrig	:= TButton():New(019,275,"" , oDlg, {|| cDirOrig := cGetFile( '*.csv' , 'Selecione o diretorio de Origem', 16, , .F., nOr( GETF_LOCALHARD, GETF_RETDIRECTORY ),.F., .T. ) },22,22,,,.F.,.T.,.F.,,.F.,,,.F. )

    @ 039, 017 SAY oSay2 PROMPT "Diretório de Destino" SIZE 066, 007 OF oDlg COLORS 0, 16777215 PIXEL    
    @ 037, 098 MSGET oGet2 VAR cDirDest SIZE 177, 010 OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON

    // busco o diretorio de destino
    oBtnDest	:= TButton():New(034,275,"" , oDlg, {|| cDirDest := cGetFile( '*.csv' , 'Selecione o diretorio de Destino', 16, , .F., nOr( GETF_LOCALHARD, GETF_RETDIRECTORY ),.F., .T. ) },22,22,,,.F.,.T.,.F.,,.F.,,,.F. )
    
    @ 176, 208 BUTTON oButton2 PROMPT "Listar" SIZE 037, 012 OF oDlg PIXEL ACTION fValidar( cDirOrig, cDirDest, oSay )
    @ 176, 251 BUTTON oButton1 PROMPT "Cancelar" SIZE 037, 012 OF oDlg PIXEL ACTION oDlg:End()

    // estilo css dos botões
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

    oBtnOrig:SetCss(cCSSBtnFile)    // botão de origem
    oBtnDest:SetCss(cCSSBtnFile)    // botão de destino

ACTIVATE MSDIALOG oDlg CENTERED

Return()

/*/{Protheus.doc} fValidar
Funcao para validar os campos preenchidos
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 13/03/2019
@version 1.0
@param nil
@return nil
@type function
/*/

Static Function fValidar( cDirOrig, cDirDest, oSay )

Local lContinua     := .T.

Default cDirOrig    := ""
Default cDirDest    := ""

// valido o diretorio de origem
if lContinua .and. empty( cDirOrig )
    MsgAlert(" O campo <Diretório de Origem> não está preenchido!")
    lContinua := .F.
endIf

// valido se o diretorio de origem existe
if lContinua .and. !ExistDir( cDirOrig )
    MsgAlert(" O <Diretório de Origem> não é válido ou não existe!")
    lContinua := .F.
endIf

// vaido o diretorio de destino
if lContinua .and. empty( cDirDest )
    MsgAlert(" O campo <Diretório de Destino> não está preenchido!")
    lContinua := .F.
endIf

// valido se o diretorio de origem existe
if lContinua .and. !ExistDir( cDirDest )
    MsgAlert(" O <Diretório de Destino> não é válido ou não existe!")
    lContinua := .F.
endIf

// vou executar a rotina de parametros
if lContinua
    FWMsgRun(,{|oSay| fListar( cDirOrig, oSay )},'Aguarde...','Processando os arquivos selecionados no diretorio de Origem - Totvs Serviços Póstumos.')    
endIf

// verifico se foram encontrados os parametros
if lContinua .and. Len(aParam) > 0

    // limpo a variavel oSay
    FreeObj(oSay)
    oSay := Nil

    // chama a funcao para gerar o arquivo no diretorio de destino
    FWMsgRun(,{|oSay| fGeraArq( cDirDest, aParam, oSay )},'Aguarde...','Processando os arquivos selecionados no diretorio de Destino - Totvs Serviços Póstumos.')
endIf

Return()

/*/{Protheus.doc} fListar
Listo os diretorios e arquivos
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 12/03/2019
@version 1.0
@param nil
@return nil
@type function
/*/

Static Function fListar( cDirOrig, oSay )
    
Local aFiles        := {}   // O array receberá os nomes dos arquivos e do diretório    
Local nX            := 0    // variavel contadora
Local nCount        := 0
Local cPath         := ""

Default cDirOrig    := ""

// atualizo a mensagem
oSay:cCaption := "Lendo diretório : " + cDirOrig
ProcessMessages()

// vou listar os arquivos ou diretorios com base no diretorio de origem
aFiles := Directory(alltrim(cDirOrig) + "*.prw", "D")

// faco a contagem do tamanho do array
nCount := Len( aFiles )

if nCount == 0

    aFiles := Directory(alltrim(cDirOrig) + "*.*", "D")
    
    nCount := Len( aFiles )

    // percorro os diretorios
    For nX := 1 to nCount
        
        // vou percorrer os diretorios que nao tenham pontos na descricao
        if !("." $ aFiles[nX,1] )
            
            // monto o novo diretorio de origem
            cPath := alltrim(cDirOrig) + iif( substr(alltrim(cDirOrig),len(alltrim(cDirOrig))) == iif(IsSrvUnix(),"/","\"), Lower( aFiles[nX,1] ), iif(IsSrvUnix(),"/","\") + Lower(aFiles[nX,1]) ) + iif(IsSrvUnix(),"/","\") 

            // vou listar os diretorios
            fListar( cPath, oSay  )        
        endIf
    Next nX

else
    
    // percorro os arquivos
    For nX := 1 to nCount

        // atualizo a mensagem
        oSay:cCaption := "Lendo Arquivos " +  StrZero(nX,6) + " de " + StrZero(nCount,6) + "."
        ProcessMessages()

        if (".prw" $ Lower(aFiles[nX,1]) .Or. ".tlpp" $ Lower(aFiles[nX,1])) .and. aFiles[nX,5] <> "D" .and. !( Lower(FunName()) $ Lower(aFiles[nX,1]) ) .and. (!"utbcpar" $ Lower(aFiles[nX,1]))

            // atualizo a mensagem
            oSay:cCaption := "Lendo Arquivo : " + aFiles[nX,1]
            ProcessMessages()
    
            // vou ler o arquivo 
            fLerArq( @aParam, alltrim(cDirOrig) + alltrim(aFiles[nX,1]), alltrim(aFiles[nX,1]) )

        elseIf aFiles[nX,5] == "D"
            
            // monto o novo diretorio de origem
            cPath := alltrim(cDirOrig) + iif( substr(alltrim(cDirOrig),len(alltrim(cDirOrig))) == iif(IsSrvUnix(),"/","\"), Lower( aFiles[nX,1] ), iif(IsSrvUnix(),"/","\") + Lower(aFiles[nX,1]) ) + iif(IsSrvUnix(),"/","\") 

            // vou listar os diretorios
            fListar( cPath, oSay  )  
        endIf        
    Next nX

endIf

Return()

/*/{Protheus.doc} fLerArq
Listo os diretorios e arquivos
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 12/03/2019
@version 1.0
@param nil
@return nil
@type function
/*/

Static Function fLerArq( aParam, cArquivo, cFonte )

Local aArea         := GetArea()
Local aFuncao       := {}
Local aFile         := {}
Local aAux          := {}
Local aDescPar      := {}
Local cFuncao       := ""
Local cParam        := ""
Local cDetParam     := ""
Local cTpParam      := ""
Local cAux          := ""
Local cContSX6      := ""
Local nI            := 0
Local nIni          := 0
Local nFim          := 0
Local nAux          := 0
Local oFile         := Nil

Default aParam      := {}
Default cArquivo    := ""
Default cFonte      := ""

// abro o arquivo utilizando a classe FWFileReader
oFile := FWFileReader():New(Lower(cArquivo))

// verifico se abriu o arquivo
    if (oFile:Open())

    // retorna as linhas do arquivo em um array
    aFile := oFile:getAllLines()

    // verifico se ja leu o arquivo inteiro
    For nI := 1 To Len( aFile )

        // para caso for uma funcao
        if "function" $ lower(aFile[nI])

            // vou pegar a posicao da funcao
            nAux := AT( "function", lower( aFile[nI] ) )

            // monto o ponto inicial do corte
            nIni := nAux+len("function")

            // monto o ponto final do corte
            nFim := AT( "(", lower( aFile[nI] ) )

            if "user" $ lower(aFile[nI]) // vejo se trata de uma user function
                cFuncao := "User (Funcao de Usuário)," + substr( aFile[nI], nIni, nFim-nIni )
            elseif "static" $ lower(aFile[nI]) // vejo se trata de static function
                cFuncao := "Static (Funcao Estatica)," + substr( aFile[nI], nIni, nFim-nIni )
            endIf        

        // para caso por parametro
        elseif "getmv" $ lower(aFile[nI])

            // sempre vou limpar o array a funcao
            aFuncao := {}

            // verifico se a variavel cfuncao esta preenchida
            if !empty(cFuncao)
                aFuncao := Strtokarr( cFuncao, ",")
            else// para quando estiver vazio
                aFuncao := {"",""}
            endIf

            // quando o array tiver uma posicao
            if len(aFuncao)==1
                aadd( aFuncao, "" )
            endIf

            // se for supergetmv eu detalho ele e monto o array aParam
            if "supergetmv" $ lower( aFile[nI] )

                // verifico a posicao inicial
                nAux        := AT( "supergetmv", lower( aFile[nI] ) )

                // vou definir o valor da variavel de inicio
                nIni        := len("supergetmv")+nAux+2
            
                // verifico a posicao final
                nFim        := AT( ",", lower( aFile[nI] ), nIni )-1

                // pego a descricao do parametro
                cParam      := substr(aFile[nI],nIni,nFim-nIni)

                // verifico um novo final para o detalhamento do parametro
                nFim        := AT( ")", lower( aFile[nI] ), nAux, nFim )

                // declaracao completa do parametro
                cDetParam   := substr(aFile[nI],nAux,nFim-nAux+1)

                //---------------------
                // tipo do parametro
                //---------------------
                nAux := AT( "(", lower( aFile[nI] ), nAux, nFim  ) + 1

                // vou pegar apenas o conteudo do supergetmv
                cAux := substr(aFile[nI],nAux,nFim-nAux)

                // pego o tipo de parametro no dicionario de dados
                cTpParam    := fDescPar( cParam, 2 )

                // para quando o tipo de programa esta preenchido
                if empty( cTpParam ) .or. alltrim(cTpParam) == "-"

                    // vou quebrar 
                    aAux := Strtokarr(cAux,",")

                    // verifico se o conteudo tem mais de 3 posicoes
                    if Len(aAux) >= 3
                        cTpParam := ValType( &(aAux[3]) )
                    else// para caso nao se aplique
                        cTpParam := "N/A"
                    endIf
                endIf

                // vou pegar a descricao do parametro
                aDescPar := fDescPar( cParam )

                // verifico se o parametro existe
                if !empty(alltrim(cParam)) .and. FWSX6Util():ExistsParam(cParam)

                    // vou pegar o conteudo do parametro
                    if ValType( getmv(cParam) ) == "N" // numerico
                        cContSX6 := cValToChar( getmv(cParam) )
                    elseif ValType( getmv(cParam) ) == "D" // data
                        cContSX6 := DtoS( getmv(cParam) ) 
                    elseif ValType( getmv(cParam) ) == "L" // logico
                        if getmv(cParam)
                            cContSX6 := ".T."
                        else
                            cContSX6 := ".F."
                        endIf                    
                    else // caracter
                        cContSX6 := getmv(cParam)
                    endIf
                
                else
                    cContSX6 := "-"
                endIf

                // preencho o array de parametros
                aadd( aParam, { cFonte, alltrim( aFuncao[1] ), alltrim( aFuncao[2] ), cParam, cDetParam, cTpParam, aDescPar[1], aDescPar[2], aDescPar[3], cContSX6 })

            // se for getmv eu detalho ele e monto o array aParam
            elseif "getmv" $ lower( aFile[nI] )

                // verifico a posicao inicial
                nAux        := AT( "getmv", lower( aFile[nI] ) )

                // vou definir o valor da variavel de inicio
                nIni        := len("getmv")+nAux+2
            
                // verifico a posicao final
                nFim        := AT( ")", lower( aFile[nI] ), nIni )-1

                // pego a descricao do parametro
                cParam      := substr(aFile[nI],nIni,nFim-nIni)

                // verifico um novo final para o detalhamento do parametro
                nFim        := AT( ")", lower( aFile[nI] ), nFim  )

                // declaracao completa do parametro
                cDetParam   := substr(aFile[nI],nAux,nFim )

                // para getmv nao se aplica o tipo do parametro
                cTpParam    := fDescPar( cParam, 2 )
                
                // verifico se o tipo do parametreo estad
                if empty( cTpParam )
                    cTpParam := "N/A"
                endIf

                // vou pegar a descricao do parametro
                aDescPar := fDescPar( cParam )

                // verifico se o parametro existe
                if !empty(alltrim(cParam)) .and. FWSX6Util():ExistsParam(cParam)

                    // vou pegar o conteudo do parametro
                    if ValType( getmv(cParam) ) == "N" // numerico
                        cContSX6 := cValToChar( getmv(cParam) )
                    elseif ValType( getmv(cParam) ) == "D" // data
                        cContSX6 := DtoS( getmv(cParam) ) 
                    elseif ValType( getmv(cParam) ) == "L" // logico
                        if getmv(cParam)
                            cContSX6 := ".T."
                        else
                            cContSX6 := ".F."
                        endIf                    
                    else // caracter
                        cContSX6 := getmv(cParam)
                    endIf
                
                else
                    cContSX6 := "-"
                endIf

                // preencho o array de parametros
                aadd( aParam, { cFonte, alltrim( aFuncao[1] ), alltrim( aFuncao[2] ), cParam, cDetParam, cTpParam, aDescPar[1], aDescPar[2], aDescPar[3], cContSX6 })

            endIf

        endIf
    Next nI

    // fecho o arquivo
    oFile:Close()

else
    Conout("Erro: " + oFile:oErroLog:Message )
endif

FreeObj(oFile)
oFile := Nil

RestArea( aArea )

Return()

/*/{Protheus.doc} fGeraArq
funcao para gerar o arquivo de parametros
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 12/03/2019
@version 1.0
@param nil
@return nil
@type function
/*/

Static Function fGeraArq( cDirDest, aParam, oSay )

Local aArea             := GetArea()
Local cArquivo          := "partsp.csv"
Local cArqGer           := ""
Local cArqNew           := ""
Local nI                := 0
Local nRename           := 0
Local oWriter           := Nil

Default cDirDest        := ""
Default aParam          := {}

// vou verificar se o array de parametros esta preenchido
if Len( aParam ) > 0

    // vou criar a variavel para gerar o arquivo de parametros
    cArqGer := cDirDest + iif( substr(alltrim(cDirDest),len(alltrim(cDirDest))) == iif(IsSrvUnix(),"/","\"),  cArquivo, iif(IsSrvUnix(),"/","\") + cArquivo )

    // atualizo a mensagem
    oSay:cCaption := "Gerando arquivo : " + cArqGer
    ProcessMessages()

    // verifico se o arquivo ja existe
    if File(cArqGer)

        MsgAlert("O Arquivo de Parametros ja existe no diretorio selecionado " + cDirDest + ", o arquivo atual sera renomeado!")

        // nome do novo arquivo
        cArqNew := cDirDest + iif( substr(alltrim(cDirDest),len(alltrim(cDirDest))) == iif(IsSrvUnix(),"/","\"), "bkp_" + Criatrab( nil,.F.) + "_" + cArquivo, iif(IsSrvUnix(),"/","\") + "bkp_" + Criatrab( nil,.F.) + "_" + cArquivo )

        // renomeio o arquivo atual
        nRename := FRename( cArqGer, cArqNew )
        
        // quando renomear o arquivo atual der certo
        if nRename == 0
            MsgInfo("O arquivo foi renomedo com sucesso, para " + cArqNew )
        elseIf nRename < 0
            MsgAlert("Falha na renomeação do arquivo : FError " +str(ferror(),4))
        endIF
    endIf

    // crio o objeto de escrita de arquivo
    oWriter := FWFileWriter():New( cArqGer, .T.)

    // se houve falha ao criar, mostra a mensagem
    If !oWriter:Create()
        MsgStop("Houve um erro ao gerar o arquivo: " + CRLF + oWriter:Error():Message, "Atenção")

        RestArea(aArea)

        Return()
                     
    Else// senão, continua com o processamento

        // escreve uma frase qualquer no arquivo
        oWriter:Write('Programa;Tipo de Funcao;Funcao;Parametro;Detalhamento do Parametro;Tipo do Parametro;Descricao;Descricao 1;Descricao 2;Conteudo' + CRLF)

        // percorre todos os dados de parametros
        For nI := 1 To Len( aParam )

            // atualizo a mensagem
            oSay:cCaption := "Linha " + StrZero(nI,6) + " de " + StrZero(Len(aParam),6)
            ProcessMessages()

            // escrevo os dados de parametros
            oWriter:Write( aParam[nI,1] + ';' + aParam[nI,2] + ';' + aParam[nI,3] + ';' + aParam[nI,4] + ';' + aParam[nI,5] + ';' + aParam[nI,6] + ';' + aParam[nI,7] + ';' + aParam[nI,8] + ';' + aParam[nI,9] + ';' + aParam[nI,10] + CRLF)

        Next nI
         
        // encerra o arquivo
        oWriter:Close()
         
        // pergunta se deseja abrir o arquivo
        If MsgYesNo("Arquivo gerado com sucesso (" + cArqGer + ")!" + CRLF + "Deseja abrir?", "Atenção")
            ShellExecute("OPEN", cArquivo, "", cDirDest, 1 )
        EndIf
    EndIf
endIf

RestArea( aArea )

FreeObj(oWriter)
oWriter := Nil

Return()

/*/{Protheus.doc} fDescPar
funcao para buscar a descricao do parametro
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 12/03/2019
@version 1.0
@param nil
@return nil
@type function
/*/
Static Function fDescPar( cParam, nTipo )

Local aArea     := getArea()
Local aRet      := {"-","-","-"}   

Default cParam  := ""
Default nTipo   := 1

DbSelectArea("SX6") //Abre a tabela SX6
SX6->(DbSetOrder(1)) //Se posiciona no primeiro indice
if SX6->(DbSeek(xFilial("SX6")+alltrim(cParam))) //Verifique se o parametro existe
    // array de retorno
    if nTipo == 1   // para retornar a descricao
        aRet := { SX6->X6_DESCRIC, iif(empty(alltrim(SX6->X6_DESC1)),"-",SX6->X6_DESC1), iif(empty(alltrim(SX6->X6_DESC2)),"-",SX6->X6_DESC2) }
    elseIf nTipo == 2 // para retornar o tipo
        aRet    := { SX6->X6_TIPO }
    endIf
endIf

RestArea( aArea ) 

Return(iif(nTipo==2 .and. len(aRet) > 0,aRet[1],aRet))
