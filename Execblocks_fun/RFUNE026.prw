#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} RFUNE026
Preenche o campo E1_XUSRBAX
@type function
@version 1.0 
@author TOTVS
@since 18/10/2017
@return character, retorna o usuario responsavel pela baixa
/*/
User Function RFUNE026()

	Local aArea			:= GetArea()
	Local aAreaSE5		:= SE5->(GetArea())
	Local cRet			:= ""
	Local cQry			:= ""
	Local cBancoDeDados	:= ""

	// pego o banco de dados da aplicacao
	cBancoDeDados := TcGetDB()

	// caso nao tenha retorno coloco o conteudo padrao
	if Empty(cBancoDeDados)
		cBancoDeDados	:= "MSSQL" // conteudo padrao para SQL Server
	endIf

	If Select("QRYUSR") > 0
		QRYUSR->(DbCloseArea())
	Endif

	if Alltrim(Upper(cBancoDeDados)) == "MSSQL" // sql server

		cQry := "SELECT TOP 1 SE5.R_E_C_N_O_ AS RECNOSE5"
		cQry += " FROM "+RetSqlName("SE1")+" SE1 INNER JOIN "+RetSqlName("SE5")+" SE5 ON SE1.E1_PREFIXO		= SE5.E5_PREFIXO"
		cQry += " 																		AND SE1.E1_NUM		= SE5.E5_NUMERO"
		cQry += " 																		AND SE1.E1_PARCELA 	= SE5.E5_PARCELA"
		cQry += " 																		AND SE1.E1_TIPO 	= SE5.E5_TIPO"
		cQry += " 																		AND SE1.E1_CLIENTE 	= SE5.E5_CLIFOR"
		cQry += " 																		AND SE1.E1_LOJA 	= SE5.E5_LOJA"
		cQry += " 																		AND SE5.D_E_L_E_T_	<> '*'"
		cQry += " 																		AND SE5.E5_FILIAL	= '"+xFilial("SE5")+"'"
		cQry += " WHERE SE1.D_E_L_E_T_ 	<> '*'"
		cQry += " AND SE1.E1_FILIAL 	= '"+xFilial("SE1")+"'"
		cQry += " AND SE1.E1_PREFIXO	= '"+SE1->E1_PREFIXO+"'"
		cQry += " AND SE1.E1_NUM		= '"+SE1->E1_NUM+"'"
		cQry += " AND SE1.E1_PARCELA 	= '"+SE1->E1_PARCELA+"'"
		cQry += " AND SE1.E1_TIPO 		= '"+SE1->E1_TIPO+"'"
		cQry += " AND SE1.E1_CLIENTE 	= '"+SE1->E1_CLIENTE+"'"
		cQry += " AND SE1.E1_LOJA 		= '"+SE1->E1_LOJA+"'"
		cQry += " AND SE5.E5_USERLGI	<> ' '"
		cQry += " ORDER BY SE5.E5_SEQ DESC"

	elseIf Alltrim(Upper(cBancoDeDados)) == "ORACLE" // oracle

		cQry := "SELECT SE5.R_E_C_N_O_ AS RECNOSE5"
		cQry += " FROM "+RetSqlName("SE1")+" SE1 INNER JOIN "+RetSqlName("SE5")+" SE5 ON SE1.E1_PREFIXO		= SE5.E5_PREFIXO"
		cQry += " 																		AND SE1.E1_NUM		= SE5.E5_NUMERO"
		cQry += " 																		AND SE1.E1_PARCELA 	= SE5.E5_PARCELA"
		cQry += " 																		AND SE1.E1_TIPO 	= SE5.E5_TIPO"
		cQry += " 																		AND SE1.E1_CLIENTE 	= SE5.E5_CLIFOR"
		cQry += " 																		AND SE1.E1_LOJA 	= SE5.E5_LOJA"
		cQry += " 																		AND SE5.D_E_L_E_T_	<> '*'"
		cQry += " 																		AND SE5.E5_FILIAL	= '"+xFilial("SE5")+"'"
		cQry += " WHERE SE1.D_E_L_E_T_ 	<> '*'"
		cQry += " AND SE1.E1_FILIAL 	= '"+xFilial("SE1")+"'"
		cQry += " AND SE1.E1_PREFIXO	= '"+SE1->E1_PREFIXO+"'"
		cQry += " AND SE1.E1_NUM		= '"+SE1->E1_NUM+"'"
		cQry += " AND SE1.E1_PARCELA 	= '"+SE1->E1_PARCELA+"'"
		cQry += " AND SE1.E1_TIPO 		= '"+SE1->E1_TIPO+"'"
		cQry += " AND SE1.E1_CLIENTE 	= '"+SE1->E1_CLIENTE+"'"
		cQry += " AND SE1.E1_LOJA 		= '"+SE1->E1_LOJA+"'"
		cQry += " AND SE5.E5_USERLGI	<> ' '"
		cQry += " AND ROWNUM  = 1 "
		cQry += " ORDER BY SE5.E5_SEQ DESC"

	endIf

	if !Empty(cQry)

		cQry := ChangeQuery(cQry)
		//MemoWrite("c:\temp\RFUNE026.txt",cQry)

		// executo a query e crio o alias temporario
		MPSysOpenQuery( cQry, 'QRYUSR' )

		If QRYUSR->(!EOF())
			DbSelectArea("SE5")
			SE5->(DbGoTo(QRYUSR->RECNOSE5))

			cRet := AllTrim(FWLeUserlg("E5_USERLGI",1))
		Endif

	endIf

	RestArea(aAreaSE5)
	RestArea(aArea)

Return(cRet)
