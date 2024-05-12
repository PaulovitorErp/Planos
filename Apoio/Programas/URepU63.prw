#Include "totvs.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} URepU63
Realiza consulta na Vindi, titulos
baixados na Vindi e nao baixado no Protheus
@author Raphael Martins 
@since 27/01/2020
@version P12
@param nulo
@return nulo
/*/
User Function URepU63() //-- U_URepU63()

    FWMsgRun(,{|oSay| U63Reprocessa(oSay) },'Aguarde...','Processando Baixas Vindi')

Return

/*/{Protheus.doc} URepU63
Realiza consulta na Vindi, titulos
baixados na Vindi e nao baixado no Protheus
@author Raphael Martins 
@since 27/01/2020
@version P12
@param nulo
@return nulo
/*/
Static Function U63Reprocessa(oSay)

    Local aArea         := GetArea()
    Local cQry          := ""
    Local cErro         := ""
    Local cCodRet       := ""
    Local cDescRetorno  := ""
    Local cDadosRetorno := ""
    Local cStatus       := ""
    Local cLogGerado	:= ""
    Local cPulaLinha	:= Chr(13) + Chr(10)
    Local nHdlLog		:= 0
    Local oJson			:= NIL
    Local oVindi		:= NIL
    Local nQtde			:= 0

    //cLogGerado	:=  cGetFile( '*.csv' , 'Selecione o arquivo para importação', 16, , .F.,GETF_LOCALHARD,.F., .T. )

    // crio o objeto de integracao com a vindi
    oVindi := IntegraVindi():New()

    cQry := "SELECT U65.R_E_C_N_O_ REGISTRO, "
    cQry += "   U65.U65_CODVIN CODVIN, "
    cQry += "	U65.U65_CONTRA CONTRATO, "
    cQry += "	SE1.E1_NUM TITULO, "
    cQry += "	SE1.E1_PARCELA PARCELA, "
    cQry += "	SE1.E1_VALOR VALOR, "
    cQry += "	SE1.E1_SALDO SALDO, "
    cQry += "	SE1.E1_BAIXA "
    cQry += "FROM U65010 U65 "
    cQry += "INNER JOIN SE1010 SE1 "
    cQry += "	ON SE1.D_E_L_E_T_ <> '*' "
    cQry += "	AND SE1.E1_FILIAL = '010101' "
    cQry += "	AND SE1.E1_PREFIXO = U65.U65_PREFIX "
    cQry += "	AND SE1.E1_NUM = U65.U65_NUM "
    cQry += "	AND SE1.E1_PARCELA = U65.U65_PARCEL "
    cQry += "	AND SE1.E1_TIPO = U65.U65_TIPO "
    cQry += "	AND SE1.E1_CLIENTE = U65.U65_CLIENT "
    cQry += "	AND SE1.E1_LOJA = U65.U65_LOJA "
    cQry += "	AND SE1.E1_SALDO > 0 "
    cQry += "	AND SE1.E1_BAIXA = ' ' "
    cQry += "	AND SE1.E1_VENCREA >= '20191001' AND SE1.E1_VENCREA <= '20200415' "
    cQry += "WHERE U65.D_E_L_E_T_ <> '*' "
    cQry += "	AND U65.U65_FILIAL = '010101' "
    cQry += "	AND U65.U65_STATUS = 'A' "

    If Select("QU65")>0
        QU65->(DbCloseArea())
    Endif

    TcQuery cQry New Alias "QU65"

    oVindi := IntegraVindi():New()

    //crio arquivo de relatorio do processamento da importacao
    /*
    nHdlLog := MsfCreate(cLogGerado + ".log",0) 

        if nHdlLog < 0
        
        lRet := .F.
        Help(,,'Help',,"Não foi possivel criar o arquivo de relatorio de importacao, favor o diretorio selecionado!",1,0)	
        else
        
        fWrite(nHdlLog , "#########  PROCESSANDO PARCELAS VINDI #############")
        fWrite(nHdlLog , cPulaLinha )
        fWrite(nHdlLog , " >> Data Inicio: " + DTOC( Date() ) )
        fWrite(nHdlLog , cPulaLinha )
        fWrite(nHdlLog , " >> Hora Inicio: " + Time() )
        fWrite(nHdlLog , cPulaLinha ) 
            
        endif
    */

    While QU65->(!EOF())

        U65->(DbGoto(QU65->REGISTRO))

        oSay:cCaption := ("Processando Fatura " + U65->U65_CODVIN + "...")
        ProcessMessages()

        cErro         := ""
        cCodRet       := ""
        cDescRetorno  := ""
        cDadosRetorno := ""
        cStatus       := ""

        Sleep(750) //-- Aguarda para proxima requisicao

        //Consulto status da fatura na VINDI
        cStatus := oVindi:ConsultaFatura("F",@cErro,U65->U65_CODVIN,@cCodRet,@cDescRetorno,@cDadosRetorno)

        If cStatus == "paid"
            // converto a string JSON
            //If FWJsonDeserialize(cDadosRetorno,@oJson)

            //pego o id da fatura pra consultar se ja existe na U63
            //cIdFatura := cValToChar(oJson:bill:id)

            //verifico se esta na U63
            //if VerificaU63(cIdFatura)


            // grava tabela de recebimento
            oVindi:IncluiTabReceb("F","1",cDadosRetorno)

            //endif

            //EndIf
        EndIf

        //limpo objeto da memoria
        //FreeObj(oJson)

        QU65->(DbSkip())

        nQtde++

    EndDo

    RestArea(aArea)

Return

/*/{Protheus.doc} VerificaU63
//Funcao para verificar se fatura possui U63
@author Raphael Martins 
@since 20/02/2020
@version 1.0
@return ${return}, ${return_description}
@param cIdFatura, characters, descricao
@type function
/*/
Static Function VerificaU63(cIdFatura)

    Local cQry := ""
    Local lRet := .T.

    cQry := " SELECT COUNT(*) QTD_REGISTRO "
    cQry += " FROM "
    cQry += RetSQLName("U63") + " U63 "
    cQry += " WHERE "
    cQry += " D_E_L_E_T_ <> '*' "
    cQry += " AND U63_ENT = '1'"
    cQry += " AND U63_MSFIL = '010101' "
    cQry += " AND CAST(CAST(U63_MSREC AS VARBINARY(8000)) AS VARCHAR(8000)) LIKE '%" + Alltrim(cIdFatura) + "%' "

    If Select("QU63")>0
        QU63->(DbCloseArea())
    Endif

    TcQuery cQry New Alias "QU63"

    if QU63->QTD_REGISTRO > 0

        lRet := .F.

    endif

Return lRet