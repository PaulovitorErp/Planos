#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RIMPC006
Rotina de Processamento de Importacoes de Retirada de Cinzas Cemiterio
@type function
@version 1.0
@author nata.queiroz
@since 09/10/2020
@param aRetCinzas, array
@param nHdlLog, numeric
@return lRet, logical
/*/
User Function RIMPC006(aRetCinzas, nHdlLog)
    Local aArea 			:= GetArea()
    Local aAreaU00			:= U00->(GetArea())
    Local aLinhaCt			:= {}
    Local lRet				:= .F.
    Local nX				:= 0

    Local nPosLeg			:= 0
    Local nPosCodImp        := 0

    Local cCodLeg			:= ""
    Local cCodImp			:= ""

    Local cErrorLog			:= ""

    BEGIN TRANSACTION

        For nX := 1 To Len(aRetCinzas)

            aLinhaCt := aClone(aRetCinzas[nX])

            nPosLeg := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "COD_ANT"})
            nPosCodImp := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "COD_IMP"})

            cCodLeg := AllTrim(aLinhaCt[nPosLeg,2])
            cCodImp := AllTrim(aLinhaCt[nPosCodImp,2])

            if !Empty(cCodLeg) .And. !Empty(cCodImp)

                U00->( DbOrderNickName("U00CODANT") ) //-- U00_FILIAL+U00_CODANT

                // Busca contrato
                if U00->( MsSeek( xFilial("U00") + cCodLeg) )

                    //-- Inclui Retirada de Cinzas
                    If IncRetCinzas(@nHdlLog, @aLinhaCt, @cErrorLog)
                        lRet := .T.
                        fWrite(nHdlLog , "Retirada de Cinzas Incluída com Sucesso!")
                        fWrite(nHdlLog , CRLF )
                    Else
                        fWrite(nHdlLog , "Erro ao Incluir Retirada de Cinzas!")
                        fWrite(nHdlLog , CRLF )

                        //-- Encerra toda transação  --//
                        //-- Ignora linhas seguintes --//
                        DisarmTransaction()
                        BREAK
                    EndIf

                else

                    fWrite(nHdlLog , "Contrato codigo legado " + cCodLeg + " nao encontrado!")
                    fWrite(nHdlLog , CRLF )

                EndIf

            else

                If Empty(cCodLeg)
                    fWrite(nHdlLog , "Codigo Legado nao preenchido,";
                        + " campo obrigatório para a importação!" )
                    fWrite(nHdlLog , CRLF )
                Else
                    fWrite(nHdlLog , "Codigo Importação nao preenchido,";
                        + " campo obrigatório para a importação!" )
                    fWrite(nHdlLog , CRLF )
                EndIf

            endif

        Next nX

    END TRANSACTION

    RestArea(aArea)
    RestArea(aAreaU00)

Return lRet

/*/{Protheus.doc} IncRetCinzas
Inclui Retirada de Cinzas
@type function
@version 1.0
@author nata.queiroz
@since 09/10/2020
@param nHdlLog, numeric
@param aLinhaCt, array
@param cErrorLog, character
@return lRet, logical
/*/
Static Function IncRetCinzas(nHdlLog, aLinhaCt, cErrorLog)
    Local lRet := .T.
    Local aArea := GetArea()
    Local aAreaU41 := U41->( GetArea() )
    Local aAreaU30 := U30->( GetArea() )
    Local cContrato := U00->U00_CODIGO
    Local cProxItemU30 := ""
    Local cProxItemU41 := ""

    Local nPosCodImp := 0
    Local nPosCremat := 0
    Local nPosNichoC := 0
    Local nPosDtUtil := 0
    Local nPosQuemUt := 0
    Local nPosDtReti := 0
    Local nPosHrReti := 0
    Local nPosNorInv := 0
    Local nPosCPF    := 0
    Local nPosRG     := 0
    Local nPosOrgao  := 0
    Local nPosNome   := 0

    nPosCodImp := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "COD_IMP"})
    nPosCremat := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U30_CREMAT"})
    nPosNichoC := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U30_NICHOC"})
    nPosDtUtil := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U30_DTUTIL"})
    nPosQuemUt := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U30_QUEMUT"})
    nPosDtReti := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U41_DTRETI"})
    nPosHrReti := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U41_HORARE"})
    nPosNorInv := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U41_NORINV"})
    nPosCPF    := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U41_CPF"})
    nPosRG     := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U41_RG"})
    nPosOrgao  := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U41_ORGAO"})
    nPosNome   := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U41_NOMERE"})

    //-- Valida campos obrigatorios importacao
    lRet := ValCposObg(@nHdlLog, @aLinhaCt, @cErrorLog)
    If lRet

        //-- Avalia se dados já foram registrados --//
        U41->( dbSetOrder(2) ) //-- U41_FILIAL+U41_CODANT
        If U41->( MsSeek(xFilial("U41") + aLinhaCt[nPosCodImp, 2]) )
            lRet := .F.
            fWrite(nHdlLog , "Dados da Retirada de Cinzas já Importados!")
            fWrite(nHdlLog , CRLF )
        EndIf

        If lRet

            //--------------------------------------//
            //-- Histórico Transferência Endereço --//
            //--------------------------------------//
            cProxItemU30 := MaxItemU30(cContrato)

            If RecLock("U30", .T.)
                U30->U30_FILIAL := xFilial("U30")
                U30->U30_CODIGO := cContrato
                U30->U30_ITEM	:= cProxItemU30
                U30->U30_CREMAT	:= AllTrim( aLinhaCt[nPosCremat, 2] )
                U30->U30_NICHOC	:= AllTrim( aLinhaCt[nPosNichoC, 2] )
                If nPosDtUtil > 0
                    U30->U30_DTUTIL := aLinhaCt[nPosDtUtil, 2]
                EndIf
                If nPosQuemUt > 0
                    U30->U30_QUEMUT := AllTrim( aLinhaCt[nPosQuemUt, 2] )
                EndIf
                U30->U30_TRANSF	:= "N" //-- Transferencia
                U30->U30_DTHIST := dDataBase
                U30->(MsUnlock())
            Else
                lRet := .F.
                fWrite(nHdlLog , "Erro ao gravar historico da transferencia!")
                fWrite(nHdlLog , CRLF )
            EndIf

            If lRet

                //------------------------//
                //-- Retirada de Cinzas --//
                //------------------------//
                cProxItemU41 := MaxItemU41(cContrato)

                If RecLock("U41", .T.)
                    U41->U41_FILIAL := xFilial("U41")
                    U41->U41_CODIGO := cContrato
                    U41->U41_ITEM   := cProxItemU41
                    U41->U41_DTRETI := aLinhaCt[nPosDtReti, 2]
                    U41->U41_HORARE := SubStr(aLinhaCt[nPosHrReti, 2], 1, 5)
                    If nPosNorInv > 0
                        U41->U41_NORINV := AllTrim( aLinhaCt[nPosNorInv, 2] )
                    EndIf
                    U41->U41_USER   := __cUserId
                    U41->U41_USRNOM	:= UsrFullName(__cUserId)
                    U41->U41_CPF    := AllTrim( aLinhaCt[nPosCPF, 2] )
                    U41->U41_RG     := AllTrim( aLinhaCt[nPosRG, 2] )
                    U41->U41_ORGAO  := AllTrim( aLinhaCt[nPosOrgao, 2] )
                    U41->U41_NOMERE := AllTrim( aLinhaCt[nPosNome, 2] )
                    U41->U41_RECU30 := U30->(Recno())
                    U41->U41_CODANT := AllTrim( aLinhaCt[nPosCodImp, 2] )
                    U41->(MsUnlock())
                Else
                    lRet := .F.
                    fWrite(nHdlLog , "Erro ao gravar dados da retirada de cinzas!")
                    fWrite(nHdlLog , CRLF )
                EndIf

            EndIf

        EndIf

    EndIf

    RestArea(aArea)
    RestArea(aAreaU41)
    RestArea(aAreaU30)

Return lRet

/*/{Protheus.doc} ValCposObg
Valida campos obrigatorios importacao
@type function
@version 1.0
@author nata.queiroz
@since 09/10/2020
@param nHdlLog, numeric
@param aLinhaCt, array
@param cErrorLog, character
@return lRet, logical
/*/
Static Function ValCposObg(nHdlLog, aLinhaCt, cErrorLog)
    Local lRet := .T.

    Local nPosCremat := 0
    Local nPosNichoC := 0
    Local nPosDtReti := 0
    Local nPosHrReti := 0
    Local nPosCPF    := 0
    Local nPosRG     := 0
    Local nPosOrgao  := 0
    Local nPosNome   := 0

    nPosCremat := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U30_CREMAT"})
    nPosNichoC := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U30_NICHOC"})
    nPosDtReti := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U41_DTRETI"})
    nPosHrReti := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U41_HORARE"})
    nPosCPF    := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U41_CPF"})
    nPosRG     := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U41_RG"})
    nPosOrgao  := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U41_ORGAO"})
    nPosNome   := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U41_NOMERE"})

    //-- Crematorio
    If nPosCremat > 0
        If Empty( AllTrim(aLinhaCt[nPosCremat,2]) )
            lRet := .F.
            fWrite(nHdlLog , "Crematorio nao preenchido,";
                + " a definição do mesmo é obrigatória!" )
            fWrite(nHdlLog , CRLF )
        EndIf
    Else
        lRet := .F.
        fWrite(nHdlLog , "Layout de importação não possui campo Crematorio,";
            + " a definição do mesmo é obrigatória!" )
        fWrite(nHdlLog , CRLF )
    EndIf

    //-- Nicho Columbario
    If nPosNichoC > 0
        If Empty( AllTrim(aLinhaCt[nPosNichoC,2]) )
            lRet := .F.
            fWrite(nHdlLog , "Nicho Columbario nao preenchido,";
                + " a definição do mesmo é obrigatória!" )
            fWrite(nHdlLog , CRLF )
        EndIf
    Else
        lRet := .F.
        fWrite(nHdlLog , "Layout de importação não possui campo Nicho Columbario,";
            + " a definição do mesmo é obrigatória!" )
        fWrite(nHdlLog , CRLF )
    EndIf

    //-- Data Retirada
    If nPosDtReti <= 0
        lRet := .F.
        fWrite(nHdlLog , "Layout de importação não possui campo Data Retirada,";
            + " a definição do mesmo é obrigatória!" )
        fWrite(nHdlLog , CRLF )
    EndIf

    //-- Hora Retirada
    If nPosHrReti <= 0
        lRet := .F.
        fWrite(nHdlLog , "Layout de importação não possui campo Hora Retirada,";
            + " a definição do mesmo é obrigatória!" )
        fWrite(nHdlLog , CRLF )
    EndIf

    //-- CPF
    If nPosCPF <= 0
        lRet := .F.
        fWrite(nHdlLog , "Layout de importação não possui campo CPF RESG.,";
            + " a definição do mesmo é obrigatória!" )
        fWrite(nHdlLog , CRLF )
    EndIf

    //-- RG
    If nPosRG <= 0
        lRet := .F.
        fWrite(nHdlLog , "Layout de importação não possui campo RG RESG.,";
            + " a definição do mesmo é obrigatória!" )
        fWrite(nHdlLog , CRLF )
    EndIf

    //-- Orgao
    If nPosOrgao <= 0
        lRet := .F.
        fWrite(nHdlLog , "Layout de importação não possui campo ORGAO,";
            + " a definição do mesmo é obrigatória!" )
        fWrite(nHdlLog , CRLF )
    EndIf

    //-- Nome
    If nPosNome <= 0
        lRet := .F.
        fWrite(nHdlLog , "Layout de importação não possui campo NOME RESG.,";
            + " a definição do mesmo é obrigatória!" )
        fWrite(nHdlLog , CRLF )
    EndIf

Return lRet

/*/{Protheus.doc} MaxItemU30
Proximo item da tabela U30
@author Raphael Martins
@since 17/05/2018
@version 1.0
@param cContrato, character
@return cProxItem, character
@obs Refatorado - Marcos Natã Santos
/*/
Static Function MaxItemU30(cContrato)
    Local cQry      := ""
    Local cProxItem := ""

    cQry := " SELECT "
    cQry += " ISNULL(MAX(U30_ITEM),'00') MAX_ITEM "
    cQry += " FROM " + RetSQLName("U30") + " HIST "
    cQry += " WHERE "
    cQry += " HIST.D_E_L_E_T_ = ' ' "
    cQry += " AND U30_FILIAL = '"+xFilial("U30")+"' "
    cQry += " AND U30_CODIGO = '" + cContrato + "' "
    cQry := ChangeQuery(cQry)

    If Select("QRYU30") > 0
        QRYU30->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "QRYU30"

    cProxItem := StrZero(Val(QRYU30->MAX_ITEM) + 1, TamSX3("U30_ITEM")[1])

    QRYU30->(DbCloseArea())

Return cProxItem

/*/{Protheus.doc} MaxItemU41
Proximo item da tabela U41
@type function
@version 1.0
@author nata.queiroz
@since 09/10/2020
@param cContrato, character
@return cProxItem, character
/*/
Static Function MaxItemU41(cContrato)
    Local cQry := ""
    Local cProxItem := ""

    cQry := " SELECT "
    cQry += " ISNULL(MAX(U41_ITEM),'00') MAX_ITEM "
    cQry += " FROM "
    cQry += + RetSQLName("U41") + " HIST "
    cQry += " WHERE "
    cQry += " HIST.D_E_L_E_T_ = ' ' "
    cQry += " AND U41_FILIAL = '"+xFilial("U41")+"' "
    cQry += " AND U41_CODIGO = '"+cContrato+"' "
    cQry := ChangeQuery(cQry)

    If Select("QRYU41") > 0
        QRYU41->(DbCloseArea())
    EndIf

    TcQuery cQry New Alias "QRYU41"

    cProxItem := StrZero(Val(QRYU41->MAX_ITEM) + 1,2)

    QRYU41->(DbCloseArea())

Return cProxItem
