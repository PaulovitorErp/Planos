#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function URepUF2B() //-- U_URepUF2B()
    Processa({|| UpdateDb() }, "URepUF2B", "Processando...")
Return

Static Function UpdateDb()
    Local cQry := ""
    Local nQtdReg := 0
    Local aAreaUF2 := UF2->( GetArea() )

    cQry := "SELECT UF2.UF2_MSFIL FILIAL, "
    cQry += "    UF2.UF2_DATA DATA, "
    cQry += "    UF2.UF2_CODIGO CONTRATO, "
    cQry += "    UF2.UF2_STATUS STATUS, "
    cQry += "    UF2.UF2_ADESAO ADESAO, "
    cQry += "    SE1.E1_VALOR VALOR, "
    cQry += "    SE1.E1_DESCONT VLDESC, "
    cQry += "    UF2.R_E_C_N_O_ RECNO "
    cQry += "FROM UF2010 UF2 "
    cQry += "INNER JOIN SE1010 SE1 "
    cQry += "    ON SE1.D_E_L_E_T_ <> '*' "
    cQry += "    AND SE1.E1_FILIAL = UF2.UF2_MSFIL "
    cQry += "    AND SE1.E1_PREFIXO = 'FUN' "
    cQry += "    AND SE1.E1_NUM = UF2.UF2_CODIGO  "
    cQry += "    AND SE1.E1_TIPO = 'AT' "
    cQry += "    AND SE1.E1_PARCELA = '001' "
    cQry += "    AND SE1.E1_CLIENTE = UF2.UF2_CLIENT "
    cQry += "    AND SE1.E1_LOJA = UF2.UF2_LOJA "
    cQry += "WHERE UF2.D_E_L_E_T_ <> '*' "
    cQry += "    AND UF2.UF2_MSFIL = '010101' "
    cQry += "    AND UF2.UF2_IDMOBI <> ' ' "
    cQry += "    AND SE1.E1_DESCONT > 0 "
    cQry += "    AND UF2.UF2_XVLDES = 0 "
    cQry += "ORDER BY UF2.UF2_CODIGO "
    cQry := ChangeQuery(cQry)

    If Select("TMPUF2B") > 0
        TMPUF2B->( DbCloseArea() )
    EndIf

    TcQuery cQry New Alias "TMPUF2B"

    COUNT TO nQtdReg
    TMPUF2B->(dbGoTop())

    If nQtdReg > 0
        ProcRegua(nQtdReg)
        While TMPUF2B->( !EOF() )

            UF2->( dbGoTo(TMPUF2B->RECNO) )
            If RecLock("UF2", .F.)
                UF2->UF2_XPERAD := IIF(TMPUF2B->VLDESC > 0, cValToChar(((TMPUF2B->VLDESC * 100) / TMPUF2B->ADESAO)), "")
                UF2->UF2_XVLDES := TMPUF2B->VLDESC
                UF2->( MsUnLock() )
            EndIf

            IncProc()

            TMPUF2B->( dbSkip() )
        EndDo
    EndIf

    RestArea(aAreaUF2)
    TMPUF2B->( DbCloseArea() )
Return
