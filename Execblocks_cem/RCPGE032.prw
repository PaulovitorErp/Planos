#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} RCPGE032
funcao para selecionar o apontamento para imprimir 
a guia de autorizacao
@type function
@version 
@author g.sampaio
@since 13/05/2020
@return nil
/*/
User Function RCPGE032( cContrato, cApontamento )

    Local aArea             := GetArea()
    Local aAreaU00          := U00->(GetArea())
    Local aCampos           := {}
    Local aTitulo           := {}
    Local aDados	        := {}
    Local cQuery 		    := ""
    Local cItemMark	        := ""
    Local cMarca	 	    := ""
    Local cAliasTmp		    := ""
    Local cInfoCliente      := ""
    Local lImpFechar        := .F.
    Local nItem             := 0
    Local oBut1             := Nil
    Local oBut2             := Nil
    Local oBut3             := Nil
    Local oSay1             := Nil
    Local oSay2             := Nil
    Local oSay3             := Nil
    Local oSay4             := Nil
    Local oSay5             := Nil
    Local oTempTable	    := Nil
    Local oMark             := Nil
    Local oDlgImpAut        := Nil

    Default cContrato       := ""
    Default cApontamento    := ""

    // atribuo valor a variavel de marcacao do browse
    cMarca  := "mk"

    // verifico se o contrato foi informado
    If !Empty( cContrato )

        // posiciono no cadastro de contratos
        U00->( DbSetOrder(1) )
        If U00->( MsSeek( xFilial("U00")+cContrato ) )

            // pego dados do cliente no contrato
            cInfoCliente    := AllTrim(U00->U00_CLIENT) + "/" + AllTrim(U00->U00_LOJA) + " - " + U00->U00_NOMCLI

        EndIf

    EndIf

    // monto a estrutura dos campos da tabela
    aAdd( aCampos, { "OK"       , "C", 002                      , 0 } )
    aAdd( aCampos, { "ITEMSERV" , "C", 003                      , 0 } )
    aAdd( aCampos, { "APONTA"   , "C", TamSX3("UJV_CODIGO")[1]  , 0 } )
    aAdd( aCampos, { "SERVICO"  , "C", TamSX3("B1_COD")[1]      , 0 } )
    aAdd( aCampos, { "DESCSERV" , "C", TamSX3("B1_DESC")[1]     , 0 } )
    aAdd( aCampos, { "DATASERV" , "D", 8                        , 0 } )
    aAdd( aCampos, { "HORASERV" , "C", TamSX3("UJV_HORA")[1]    , 0 } )
    aAdd( aCampos, { "NOMEFALE" , "C", TamSX3("UJV_NOME")[1]    , 0 } )
    aAdd( aCampos, { "DTOBIT"   , "D", 8                        , 0 } )
    aAdd( aCampos, { "QUADRA"   , "C", TamSX3("UJV_QUADRA")[1]  , 0 } )
    aAdd( aCampos, { "MODULO"   , "C", TamSX3("UJV_MODULO")[1]  , 0 } )
    aAdd( aCampos, { "JAZIGO"   , "C", TamSX3("UJV_JAZIGO")[1]  , 0 } )
    aAdd( aCampos, { "GAVETA"   , "C", TamSX3("UJV_GAVETA")[1]  , 0 } )
    aAdd( aCampos, { "CREMAT"   , "C", TamSX3("UJV_CREMAT")[1]  , 0 } )
    aAdd( aCampos, { "NICHOC"   , "C", TamSX3("UJV_NICHOC")[1]  , 0 } )
    aAdd( aCampos, { "OSSARI"   , "C", TamSX3("UJV_OSSARI")[1]  , 0 } )
    aAdd( aCampos, { "NICHOO"   , "C", TamSX3("UJV_NICHOO")[1]  , 0 } )
    aAdd( aCampos, { "AUTORI"   , "C", TamSX3("UJV_AUTORI")[1]  , 0 } )

    // monto a estrutura dos campos da tabela
    aAdd( aTitulo, { "OK"       , "", ""                , "" } )
    aAdd( aTitulo, { "ITEMSERV" , "", "Item"            , "" } )
    aAdd( aTitulo, { "APONTA"   , "", "Apontamento"     , "" } )
    aAdd( aTitulo, { "SERVICO"  , "", "Serviço"         , "" } )
    aAdd( aTitulo, { "DESCSERV" , "", "Desc.Serviço"    , "" } )
    aAdd( aTitulo, { "DATASERV" , "", "Data"            , "" } )
    aAdd( aTitulo, { "HORASERV" , "", "Hora"            , "" } )
    aAdd( aTitulo, { "NOMEFALE" , "", "Nome Obito"      , "" } )
    aAdd( aTitulo, { "DTOBIT"   , "", "Data Obito"      , "" } )
    aAdd( aTitulo, { "QUADRA"   , "", "Quadra"          , "" } )
    aAdd( aTitulo, { "MODULO"   , "", "Modulo"          , "" } )
    aAdd( aTitulo, { "JAZIGO"   , "", "Jazigo"          , "" } )
    aAdd( aTitulo, { "GAVETA"   , "", "Gaveta"          , "" } )
    aAdd( aTitulo, { "CREMAT"   , "", "Crematório"      , "" } )
    aAdd( aTitulo, { "NICHOC"   , "", "Nicho Cremtório" , "" } )
    aAdd( aTitulo, { "OSSARI"   , "", "Ossuário"        , "" } )
    aAdd( aTitulo, { "NICHOO"   , "", "Nicho Ossuário"  , "" } )
    aAdd( aTitulo, { "AUTORI"   , "", "Autorizado"      , "" } )

    // crio o objeto do alias temporario
    oTempTable := FWTemporaryTable():New("TRBTMP")

    //Validação para o Gerador de Termos
    lRegSel	:= .F.

    //Inserindo campos no alias temporario
    oTempTable:SetFields(aCampos)

    //---------------------
    //Criação dos índices
    //---------------------
    oTempTable:AddIndex("01", {"ITEMSERV"} )

    //---------------------------------------------------------------
    //tabela criado no espaço temporário do DB
    //---------------------------------------------------------------
    oTempTable:Create()

    //------------------------------------
    //Pego o alias da tabela temporária
    //------------------------------------
    cAliasTmp := oTempTable:GetAlias()

    If Select("TRBUJV") > 0
        TRBUJV->(DbCloseArea())
    Endif

    cQuery := " SELECT 'SERVNOR'    DESCRI,
    cQuery += " UJV.UJV_CODIGO      APONTA,"
    cQuery += " SB1.B1_COD          SERVICO,"
    cQuery += " SB1.B1_DESC         DESCSERV, "
    cQuery += " UJV.UJV_DTSEPU      DATASERV, "
    cQuery += " UJV.UJV_HORASE      HORASERV, "
    cQuery += " UJV.UJV_NOME        NOMEFALE, "
    cQuery += " UJV.UJV_DTOBT       DTOBIT, "
    cQuery += " UJV.UJV_QUADRA      QUADRA, "
    cQuery += " UJV.UJV_MODULO      MODULO, "
    cQuery += " UJV.UJV_JAZIGO      JAZIGO, "
    cQuery += " UJV.UJV_GAVETA      GAVETA, "
    cQuery += " UJV.UJV_CREMAT      CREMAT, "
    cQuery += " UJV.UJV_NICHOC      NICHOC, "
    cQuery += " UJV.UJV_OSSARI      OSSARI, "
    cQuery += " UJV.UJV_NICHOO      NICHOO, "
    cQuery += " UJV.UJV_AUTORI      AUTORI "
    cQuery += " FROM " + RetSqlName("UJV") + " UJV "
    cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = ' ' "
    cQuery += " AND SB1.B1_COD = UJV.UJV_SERVIC "
    cQuery += " AND SB1.B1_XREQSER <> ' '"
    cQuery += " WHERE UJV.D_E_L_E_T_ = ' ' "
    cQuery += " AND UJV.UJV_FILIAL  = '" + xFilial("UJV") + "' "
    cQuery += " AND UJV.UJV_STENDE  = 'E' "

    // verifico se tenho contrato preenchido
    If !Empty( AllTrim( cContrato ) )
        cQuery += " AND UJV.UJV_CONTRA	= '" + cContrato + "' "
    Endif

    // verifico se tenho apontamento preenchido
    If !Empty( AllTrim( cApontamento ) )
        cQuery += " AND UJV.UJV_CODIGO	= '" + cApontamento + "' "
    Endif

    cQuery += " UNION ALL "
    cQuery += " SELECT 'SERVADC'    DESCRI, "
    cQuery += " UJV.UJV_CODIGO      APONTA,"
    cQuery += " SB1.B1_COD          SERVICO,"
    cQuery += " SB1.B1_DESC         DESCSERV, "
    cQuery += " UJV.UJV_DTSEPU      DATASERV, "
    cQuery += " UJV.UJV_HORASE      HORASERV, "
    cQuery += " UJV.UJV_NOME        NOMEFALE, "
    cQuery += " UJV.UJV_DTOBT       DTOBIT, "
    cQuery += " UJV.UJV_QUADRA      QUADRA, "
    cQuery += " UJV.UJV_MODULO      MODULO, "
    cQuery += " UJV.UJV_JAZIGO      JAZIGO, "
    cQuery += " UJV.UJV_GAVETA      GAVETA, "
    cQuery += " UJV.UJV_CREMAT      CREMAT, "
    cQuery += " UJV.UJV_NICHOC      NICHOC, "
    cQuery += " UJV.UJV_OSSARI      OSSARI, "
    cQuery += " UJV.UJV_NICHOO      NICHOO, "
    cQuery += " UJV.UJV_AUTORI      AUTORI "
    cQuery += " FROM " + RetSqlName("UJV") + " UJV "
    cQuery += " INNER JOIN " + RetSqlName("UJX") + " UJX ON UJX.D_E_L_E_T_ = ' ' "
    cQuery += " AND UJX.UJX_CODIGO = UJV.UJV_CODIGO "
    cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = ' ' "
    cQuery += " AND SB1.B1_COD = UJX.UJX_SERVIC "
    cQuery += " AND SB1.B1_XREQSER <> ' '"
    cQuery += " WHERE UJV.D_E_L_E_T_ = ' ' "
    cQuery += " AND UJV.UJV_FILIAL  = '" + xFilial("UJV") + "' "
    cQuery += " AND UJV.UJV_STENDE = 'E' "

    // verifico se tenho contrato preenchido
    If !Empty( AllTrim( cContrato ) )
        cQuery += " AND UJV.UJV_CONTRA	= '" + cContrato + "' "
    Endif

    // verifico se tenho apontamento preenchido
    If !Empty( AllTrim( cApontamento ) )
        cQuery += " AND UJV.UJV_CODIGO	= '" + cApontamento + "' "
    Endif

    cQuery += " ORDER BY 1"

    // compatibilziacao da query
    cQuery := ChangeQuery(cQuery)

    // executo a query e crio o alias temporario
    TcQuery cQuery NEW Alias "TRBUJV"

    If TRBUJV->(!Eof())

        While TRBUJV->(!EOF())

            // incremento a variavel de item
            nItem++

            (cAliasTmp)->( RecLock(cAliasTmp,.T.) )

            (cAliasTmp)->OK 		:= "  "
            (cAliasTmp)->ITEMSERV	:= StrZero( nItem, 3)
            (cAliasTmp)->APONTA     := TRBUJV->APONTA
            (cAliasTmp)->SERVICO    := TRBUJV->SERVICO
            (cAliasTmp)->DESCSERV	:= TRBUJV->DESCSERV
            (cAliasTmp)->DATASERV   := Stod(TRBUJV->DATASERV)
            (cAliasTmp)->HORASERV   := TRBUJV->HORASERV
            (cAliasTmp)->NOMEFALE	:= TRBUJV->NOMEFALE
            (cAliasTmp)->DTOBIT	    := Stod(TRBUJV->DTOBIT)
            (cAliasTmp)->QUADRA	    := TRBUJV->QUADRA
            (cAliasTmp)->MODULO	    := TRBUJV->MODULO
            (cAliasTmp)->JAZIGO	    := TRBUJV->JAZIGO
            (cAliasTmp)->GAVETA	    := TRBUJV->GAVETA
            (cAliasTmp)->CREMAT	    := TRBUJV->CREMAT
            (cAliasTmp)->NICHOC	    := TRBUJV->NICHOC
            (cAliasTmp)->OSSARI	    := TRBUJV->OSSARI
            (cAliasTmp)->NICHOO	    := TRBUJV->NICHOO
            (cAliasTmp)->AUTORI	    := TRBUJV->AUTORI

            (cAliasTmp)->( MsUnlock() )

            TRBUJV->(DbSkip())
        EndDo
        
        // posiciono no primeiro registro
        (cAliasTmp)->(DbGoTop())

        // monto a tela de exibicao
        DEFINE MSDIALOG oDlgImpAut TITLE "Serviços - Impressão de Autorização" From 000,000 TO 450,700 COLORS 0, 16777215 PIXEL

        //Cabeçalho
        @ 005, 005 SAY oSay1 PROMPT "Contrato:"     SIZE 070, 007 OF oDlgImpAut COLORS 0, 16777215 PIXEL
        @ 005, 030 SAY oSay2 PROMPT cContrato       SIZE 200, 007 OF oDlgImpAut COLORS 0, 16777215 PIXEL
        @ 018, 005 SAY oSay3 PROMPT "Cliente:"      SIZE 070, 007 OF oDlgImpAut COLORS 0, 16777215 PIXEL
        @ 018, 030 SAY oSay4 PROMPT cInfoCliente    SIZE 200, 007 OF oDlgImpAut COLORS 0, 16777215 PIXEL

        //Browse
        oMark := MsSelect():New(cAliasTmp,"OK","",aTitulo,,@cMarca,{030,005,190,348})
        oMark:bMark 				:= { || Marca2It( (cAliasTmp)->ITEMSERV, (cAliasTmp)->(Recno()), cAliasTmp, @cItemMark, @oMark )}
        oMark:oBrowse:LHASMARK    	:= .T.

        //Linha horizontal
        @ 198, 005 SAY oSay5 PROMPT Repl("_",342) SIZE 342, 007 OF oDlgImpAut COLORS CLR_GRAY, 16777215 PIXEL

        @ 208, 107 BUTTON oBut1 PROMPT "Autorização de Sepultamento" SIZE 100, 010 OF oDlgImpAut ACTION (ImpAutSep( cAliasTmp )) PIXEL
        @ 208, 212 BUTTON oBut2 PROMPT "Autorização de Cremação" SIZE 100, 010 OF oDlgImpAut ACTION (ImpAutCre( cAliasTmp )) PIXEL
        @ 208, 317 BUTTON oBut3 PROMPT "Fechar" SIZE 030, 010 OF oDlgImpAut ACTION FechImpAut( cAliasTmp, @oDlgImpAut, @lImpFechar ) PIXEL

        ACTIVATE MSDIALOG oDlgImpAut CENTERED VALID lImpFechar //impede o usuario fechar a janela atraves do [X]

    else

        // mensagem para o usuário
        MsgAlert("Não existe apontamento de serviços para o contrato posicionado!")

    EndIf

    If Select("TRBUJV") > 0
        TRBUJV->(DbCloseArea())
    Endif

    // verifico se o objeto do alias temproario de contratos no banco
    If ValType( oTempTable ) == "O"
        oTempTable:Delete()
    EndIf

    RestArea( aAreaU00 )
    RestArea( aArea )

Return( Nil )

/*/{Protheus.doc} ImpAutSep
funcao para executar a impressão da guia
de autorização de sepultamento
@type function
@version 
@author g.sampaio
@since 14/05/2020
@return nil
/*/
Static Function ImpAutSep( cAliasTmp )

    Local aArea         := GetArea()
    Local nCont         := 0

    Default cAliasTmp   := ""

    // verfico se o alias tem dados
    If !Empty(cAliasTmp) .And. Select(cAliasTmp) > 0

        // posiciono no primeiro registro da tabela temporaria
        (cAliasTmp)->(dbGoTop())

        // percorro o alias temporario
        While (cAliasTmp)->(!EOF())

            // verifico se o item esta marcado
            If (cAliasTmp)->OK == "mk" .And. !Empty((cAliasTmp)->SERVICO)

                nCont++
                U_RCPGR008( (cAliasTmp)->SERVICO, (cAliasTmp)->APONTA, U00->U00_CODIGO )
                Exit // imprimo e saio da rotina
            Endif

            (cAliasTmp)->(DbSkip())
        EndDo

        // caso nao tenha nenhum registro selecionado
        If nCont == 0
            MsgInfo("Nenhum registro selecionado.","Atenção")
            (cAliasTmp)->(DbGoTop())
        Endif

    EndIf

    RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} ImpAutCre
funcao para executar a impressão da guia
de autorização de cremacao
@type function
@version 
@author g.sampaio
@since 14/05/2020
@return Nil
/*/
Static Function ImpAutCre( cAliasTmp )

    Local aArea         := GetArea()
    Local nCont         := 0

    Default cAliasTmp   := ""

    // verfico se o alias tem dados
    If !Empty(cAliasTmp) .And. Select(cAliasTmp) > 0

        // posiciono no primeiro registro da tabela temporaria
        (cAliasTmp)->(dbGoTop())

        // percorro o alias temporario
        While (cAliasTmp)->(!EOF())

            // verifico se o item esta marcado
            If (cAliasTmp)->OK == "mk" .And. !Empty((cAliasTmp)->SERVICO)

                nCont++
                U_RCPGR009(( cAliasTmp)->SERVICO, (cAliasTmp)->APONTA, U00->U00_CODIGO )
                Exit // imprimo e saio da rotina
            Endif

            (cAliasTmp)->(DbSkip())
        EndDo

        // caso nao tenha nenhum registro selecionado
        If nCont == 0
            MsgInfo("Nenhum registro selecionado.","Atenção")
            (cAliasTmp)->(DbGoTop())
        Endif

    EndIf

Return(Nil)

/*/{Protheus.doc} FechImpAut
fecha a tela de impressao 
@type function
@version 
@author g.sampaio
@since 14/05/2020
@return nil
/*/
Static Function FechImpAut( cAliasTmp, oDlgImpAut, lImpFechar )

    Local aArea         := GetArea()

    Default cAliasTmp   := ""

    // verfico se o alias tem dados
    If !Empty(cAliasTmp) .And. Select(cAliasTmp) > 0

        If Select(cAliasTmp) > 0
            (cAliasTmp)->(DbCloseArea())
        Endif

    EndIf

    lImpFechar := .T.

    oDlgImpAut:End()

    RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} Marca2It
funcao para marcar o item selecionado no browse
@type function
@version 
@author g.sampaio
@since 13/05/2020
@param cItem, character     , codigo do item do alias temporario
@param nRecTabTmp, numeric  , recno do registro do alias temporario
@param cAliasTmp, character , alias temporario
@param cItemMark, character , item a ser marcado(referencia)
@param cItemMark, oMark     , objeto de markbrowse
@return return_type, return_description
@history 19/05/2020, g.sampaio, ajustado erro ao gravar no alias temporario, pois a variavel estavada errada ajustado cAlias por cAliasTmp
/*/
Static Function Marca2It( cItem, nRecTabTmp, cAliasTmp, cItemMark, oMark)

    Local aArea         := GetArea()

    Default cItem       := ""
    Default nRecTabTmp  := 0
    Default cAliasTmp   := ""
    Default cItemMark   := ""

    // posciono no primeiro registro do alias temporario
    (cAliasTmp)->(DbGoTop())

    // percorro os itens do alias temporario
    While (cAliasTmp)->(!EOF())

        // caso for diferente do item marcado
        If (cAliasTmp)->ITEMSERV <> cItem
            RecLock(cAliasTmp,.F.)
            (cAliasTmp)->OK := "  " // limpo o campo de marcacao
            (cAliasTmp)->(MsUnlock())
        Endif

        // caso tenha marcado gravo codigo item selecionado em memoria
        If !Empty((cAliasTmp)->OK) .And. !Empty((cAliasTmp)->ITEMSERV)
            lRegSel 	:= .T.
            cItemMark	:= (cAliasTmp)->ITEMSERV
        Endif

        (cAliasTmp)->(DbSkip())
    EndDo

    // posiciono no registro selecionado
    (cAliasTmp)->(DbGoTo(nRecTabTmp))

    // atualizo o browse de marccao
    oMark:oBrowse:Refresh()

    RestArea( aArea )

Return( Nil )