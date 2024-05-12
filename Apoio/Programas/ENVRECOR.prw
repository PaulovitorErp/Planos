#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "tbiconn.ch"

#DEFINE CRLF CHR(13)+CHR(10)

User Function ENVRECOR() //-- U_ENVRECOR()

	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '010101'

	Processa({|| GerarU62() }, "ENVRECOR", "Processando...")

	RESET ENVIRONMENT

Return

Static Function GerarU62()
	Local cQry := ""
	Local nQtdReg := 0
	Local cLogs := ""
    Local nQtdProc := 0
    Local cCodModulo := "F"
	Local oVindi := Nil
	Local aAreaSE1 := SE1->( GetArea() )

	cQry := "SELECT UF2_CODIGO, UF2_CLIENT, UF2_LOJA "
	cQry += "FROM UF2010 "
	cQry += "WHERE D_E_L_E_T_ <> '*' "
	cQry += "AND UF2_MSFIL = '"+ cFilAnt +"' "
	cQry += "AND UF2_IDMOBI <> ' ' "
	cQry += "AND UF2_FORPG = 'CC' "
	cQry += "AND UF2_STATUS = 'A' "
	cQry += "AND UF2_DATA >= '20201020' "
	cQry += "AND EXISTS ( "
	cQry += "SELECT * FROM SE1010 "
	cQry += "WHERE D_E_L_E_T_ <> '*' "
	cQry += "AND E1_FILIAL = UF2_MSFIL "
	cQry += "AND E1_PREFIXO = 'FUN' "
	cQry += "AND E1_NUM = UF2_CODIGO "
	cQry += "AND E1_PARCELA = '002' "
	cQry += "AND E1_TIPO = 'AT' "
	cQry += "AND E1_CLIENTE = UF2_CLIENT "
	cQry += "AND E1_BAIXA = ' ') "
	cQry += "AND NOT EXISTS ( "
	cQry += "SELECT * FROM U65010 "
	cQry += "WHERE D_E_L_E_T_ <> '*' "
	cQry += "AND U65_FILIAL = UF2_MSFIL "
	cQry += "AND U65_NUM = UF2_CODIGO "
	cQry += "AND U65_PARCEL = '002' "
	cQry += "AND U65_TIPO = 'AT') "
	cQry := ChangeQuery(cQry)

	If Select("TMPUF2") > 0
		TMPUF2->( DbCloseArea() )
	EndIf

	TcQuery cQry New Alias "TMPUF2"

	COUNT TO nQtdReg
	TMPUF2->(dbGoTop())

	If nQtdReg > 0
		ProcRegua(nQtdReg)

		oVindi := IntegraVindi():New()

		While TMPUF2->( !EOF() )

			SE1->( dbSetOrder(1) )
			If SE1->( MsSeek(xFilial("SE1") + "FUN" + PadR(TMPUF2->UF2_CODIGO, 9) + "002" + "AT ") )

				oVindi:IncluiTabEnvio(cCodModulo,"3","I",1,;
					SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)

				nQtdProc++

			EndIf

			TMPUF2->( dbSkip() )
		EndDo
	EndIf

    cLogs += "Qtd Processada: " + cValToChar(nQtdProc)
	MemoWrite("C:\Users\marcos\Desktop\envrecor-logs.txt", cLogs)

	TMPUF2->( DbCloseArea() )
	RestArea(aAreaSE1)
Return
