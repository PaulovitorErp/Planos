#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} RIMPC003
Rotina de Processamento de Importacoes de Mensagens do Contrato
@type function
@version 1.0
@author nata.queiroz
@since 04/03/2020
@param aMensCtr, array
@param nHdlLog, numeric
@return lRet, logic
/*/
User Function RIMPC003(aMensCtr, nHdlLog)
    Local aArea         := GetArea()
    Local aAreaU03      := U03->( GetArea() )
    Local aAreaU00      := U00->( GetArea() )
    Local aItensMsg		:= {}
    Local aMensagens    := {}
    Local aLinhaCtr     := {}
    Local aCabCtr       := {}
    Local lRet			:= .F.
    Local nX			:= 0
    Local nY            := 0

    Local nPosCod       := 0
    Local nPosHist      := 0

    Local cCodCtr   	:= ""
    Local cHist         := ""
    Local cErrLog		:= ""
    Local cPulaLinha	:= Chr(13) + Chr(10)

    //-- Variavel interna da rotina automatica
    Private lMsErroAuto := .F. 
    Private lMsHelpAuto := .F.

    //-- Valores do default dos parametros
    Default aMensCtr := {}
    Default nHdlLog  := 0

    For nX := 1 To Len(aMensCtr)

        BEGIN TRANSACTION

            U03->( dbSetOrder(1) ) //-- U03_FILIAL+U03_CODIGO+U03_ITEM

            aLinhaCtr := aClone(aMensCtr[nX])

            nPosCod := aScan(aLinhaCtr,{|x| AllTrim(x[1]) == "COD_ANT"})
            nPosHist := aScan(aLinhaCtr,{|x| AllTrim(x[1]) == "U03_HISTOR"})

            //-- Importa apenas mensagem com o codigo anterior do contrato
            If nPosCod > 0 .And. nPosHist > 0

                //-- Codigo do contrato a ser importado
                cCodAnt	:= AllTrim(aLinhaCtr[nPosCod,2])
                cHist	:= AllTrim(aLinhaCtr[nPosHist,2])

                //-- Verifico se o Codigo Anterior e o Titulo da Mensagem estao preenchidos
                If !Empty(cCodAnt) .And. !Empty(cHist)

                    U00->( DbOrderNickName("U00CODANT") ) //-- U00_FILIAL+U00_CODANT

                    If U00->( MsSeek( xFilial("U00") + AllTrim(cCodAnt) ) )

                        //-- Codigo do contrato do protheus
                        cCodCtr := U00->U00_CODIGO

                        //-- Valido se ja existe a mensagem no contrato
                        If !ExistMsg(cCodCtr, cHist)

                            aAdd(aCabCtr, {"U00_CODIGO", cCodCtr})

                            DbSelectArea("U03")
                            U03->( dbSetOrder(1) ) //U03_FILIAL+U03_CODIGO+U03_ITEM

                            //-- Codigo do item
                            aAdd(aItensMsg, {"U03_ITEM", ProxItem(cCodCtr)} )

                            For nY := 1 To Len(aLinhaCtr)

                                //-- Codigo anterior pula para o proximo
                                If AllTrim(aLinhaCtr[nY,1]) == "COD_ANT"
                                    Loop
                                EndIf

                                aAdd(aItensMsg, {AllTrim(aLinhaCtr[nY,1]), aLinhaCtr[nY,2]})

                            Next nY

                            If len(aItensMsg) > 0
                                aAdd(aMensagens, aItensMsg)
                            EndIf

                            If Len(aMensagens) > 0

                                If !U_RCPGE004(aCabCtr,, aMensagens, 4,,, @cErrLog)

                                    //-- Verifico se arquivo de log existe
                                    If nHdlLog > 0

                                        fWrite(nHdlLog , "Erro na Inclusao da Mensagem no Contrato:")

                                        fWrite(nHdlLog , cPulaLinha )

                                        fWrite(nHdlLog , cErrLog )

                                        fWrite(nHdlLog , cPulaLinha )

                                        cErrLog := ""

                                    EndIf

                                    DisarmTransaction()

                                Else

                                    //-- Verifico se arquivo de log existe
                                    If nHdlLog > 0 

                                        fWrite(nHdlLog , "Mensagem Cadastrada com sucesso no Contrato!")

                                        fWrite(nHdlLog , cPulaLinha )

                                        fWrite(nHdlLog , "Mensagem do contrato: " + AllTrim( cCodCtr ))

                                        fWrite(nHdlLog , cPulaLinha )

                                        lRet := .T.

                                    EndIf

                                EndIf

                            EndIf
                        Else

                            fWrite(nHdlLog , "Mensagem: " + cHist + " já existe no contrato!")

                            fWrite(nHdlLog , cPulaLinha )

                        EndIf
                    Else

                        //-- Verifico se arquivo de log existe
                        If nHdlLog > 0

                            fWrite(nHdlLog , "Contrato: " + AllTrim(cCodAnt) + " não encontrado no sistema! " )

                            fWrite(nHdlLog , cPulaLinha )

                        EndIf

                    EndIf
                Else

                    fWrite(nHdlLog , "Layout de importação não possui campo Codigo Anterior, a definição do mesmo é obrigatória!")

                    fWrite(nHdlLog , cPulaLinha )

                EndIf
            Else

                fWrite(nHdlLog , "Layout de importação não possui campo Codigo Anterior, a definição do mesmo é obrigatória!")

                fWrite(nHdlLog , cPulaLinha )

            EndIf

        END TRANSACTION

    Next nX

    RestArea(aAreaU00)
    RestArea(aAreaU03)
    RestArea(aArea)

Return lRet

/*/{Protheus.doc} ExistMsg
Verifica se a mensagem já existe no contrato
@type function
@version 1.0
@author nata.queiroz
@since 04/03/2020
@param cCodCtr, character
@param cHist, character
@return lRet, logic
/*/
Static Function ExistMsg(cCodCtr, cHist)
    Local aArea     := GetArea()
    Local lRet      := .F.
    Local cQry      := ""
    Local nQtdReg   := 0

    Default cCodCtr := ""
    Default cHist   := ""

    cQry := "SELECT U03_CODIGO "
    cQry += "FROM " + RetSqlName("U03")
    cQry += "WHERE D_E_L_E_T_ <> '*' "
    cQry += "AND U03_FILIAL = '"+ xFilial("U03") +"' "
    cQry += "AND U03_CODIGO = '"+ AllTrim(cCodCtr) +"' "
    cQry += "AND U03_HISTOR = '"+ AllTrim(cHist) +"' "
    cQry += "ORDER BY U03_CODIGO, U03_HISTOR "

    cQry := ChangeQuery(cQry)

    If Select("TRBU03") > 0
		TRBU03->( dbCloseArea() )
	EndIf
    
    MPSysOpenQuery(cQry, "TRBU03")

    //-- Existe registros na tabela --//
    If TRBU03->(!Eof())
        lRet := .T.
    EndIf

    TRBU03->( dbCloseArea() )

    RestArea(aArea)

Return lRet

/*/{Protheus.doc} ProxItem
Retorna proximo item para cadastro de mensagens do contrato
@type function
@version 1.0
@author nata.queiroz
@since 04/03/2020
@param cCodCtr, character
@return cProxItm, character
/*/
Static Function ProxItem(cCodCtr)
	Local aArea     := GetArea()
	Local cProxItm  := "01"
	Local cQry      := ""
    Local nQtdReg   := 0

	Default cCodCtr := ""

    cQry := "SELECT MAX(U03_ITEM) MAXITEM "
    cQry += "FROM " + RetSqlName("U03")
    cQry += "WHERE D_E_L_E_T_ <> '*' "
    cQry += "AND U03_FILIAL = '"+ xFilial("U03") +"' "
    cQry += "AND U03_CODIGO = '"+ AllTrim(cCodCtr) +"' "
    
    cQry := ChangeQuery(cQry)

    If Select("TRBU03") > 0
		TRBU03->( dbCloseArea() )
	EndIf
    
    MPSysOpenQuery(cQry, "TRBU03")

    //-- Existe registros na tabela --//
    If TRBU03->(!Eof()) > 0
        cProxItm := Soma1(TRBU03->MAXITEM)
    EndIf

    TRBU03->( dbCloseArea() )

	RestArea(aArea)

Return cProxItm
