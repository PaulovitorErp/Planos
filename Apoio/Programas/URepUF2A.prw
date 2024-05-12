#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

User Function URepUF2A() //-- U_URepUF2A()
    Processa({|| UpdateDb() }, "URepUF2A", "Processando...")
Return

Static Function UpdateDb()
    Local cQry := ""
    Local nQtdReg := 0
    Local aAreaUF2 := UF2->( GetArea() )

    cQry := "SELECT UF2.UF2_MSFIL FILIAL, "
    cQry += "    UF2.UF2_CODIGO CONTRATO, "
    cQry += "    UF2.UF2_STATUS STATUS, "
    cQry += "    UF2.UF2_DATA DATA, "
    cQry += "    UF2.UF2_ADESAO ADESAO, "
    cQry += "    SE1.E1_VALOR VALOR, "
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
    cQry += "    AND UF2.UF2_ADESAO <> SE1.E1_VALOR "
    cQry += "    AND EXISTS (SELECT U68_CONTRA "
    cQry += "                FROM U68010 "
    cQry += "                WHERE D_E_L_E_T_ <> '*' "
    cQry += "                    AND U68_FILIAL = UF2.UF2_MSFIL "
    cQry += "                    AND U68_CONTRA = UF2.UF2_CODIGO) "
    cQry += "ORDER BY UF2.UF2_CODIGO "
    cQry := ChangeQuery(cQry)

    If Select("TMPUF2A") > 0
        TMPUF2A->( DbCloseArea() )
    EndIf

    TcQuery cQry New Alias "TMPUF2A"

    COUNT TO nQtdReg
    TMPUF2A->(dbGoTop())

    If nQtdReg > 0
        ProcRegua(nQtdReg)
        While TMPUF2A->( !EOF() )

            UF2->( dbGoTo(TMPUF2A->RECNO) )
            If RecLock("UF2", .F.)
                UF2->UF2_ADESAO := TMPUF2A->VALOR
                UF2->( MsUnLock() )
            EndIf

            IncProc()

            TMPUF2A->( dbSkip() )
        EndDo
    EndIf

    RestArea(aAreaUF2)
    TMPUF2A->( DbCloseArea() )
Return