#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MTA010OK ºAutor ³ Wellington Gonçalves º Data ³ 17/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para validar a exclusão do produto		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cemitério e Funerária                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MTA010OK()

Local aArea			:= GetArea()
Local aAreaSB1		:= SB1->(GetArea())
Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
Local lRet			:= .T.
Local cQry			:= ""
Local cPulaLinha	:= chr(13)+chr(10)

if !IsBlind() // não será validado em rotinas automaticas

	if lFuneraria
	
		// verifico se existe este alias criado
		If Select("QRY") > 0
			QRY->(DbCloseArea())
		EndIf 
		
		cQry := " SELECT " 										+ cPulaLinha
		cQry += " UF1.UF1_FILIAL AS FILIAL, " 					+ cPulaLinha
		cQry += " UF1.UF1_CODIGO AS PLANO, " 					+ cPulaLinha
		cQry += " '' AS CONTRATO " 								+ cPulaLinha
		cQry += " FROM " 										+ cPulaLinha
		cQry += " " + RetSqlName("UF1") + " UF1 " 				+ cPulaLinha
		cQry += " WHERE " 										+ cPulaLinha
		cQry += " UF1.D_E_L_E_T_ <> '*' " 						+ cPulaLinha
		cQry += " AND UF1.UF1_PROD = '" + SB1->B1_COD + "' " 	+ cPulaLinha
		cQry += " UNION " 										+ cPulaLinha
		cQry += " SELECT " 										+ cPulaLinha
		cQry += " UF3.UF3_FILIAL AS FILIAL, " 					+ cPulaLinha
		cQry += " '' AS PLANO, " 								+ cPulaLinha
		cQry += " UF3.UF3_CODIGO AS CONTRATO "					+ cPulaLinha
		cQry += " FROM " 										+ cPulaLinha
		cQry += " " + RetSqlName("UF3") + " UF3 " 				+ cPulaLinha
		cQry += " WHERE " 										+ cPulaLinha
		cQry += " UF3.D_E_L_E_T_ <> '*' " 						+ cPulaLinha
		cQry += " AND UF3.UF3_PROD = '" + SB1->B1_COD + "' " 	+ cPulaLinha   
		
		// função que converte a query genérica para o protheus
		cQry := ChangeQuery(cQry)
		
		// crio o alias temporario
		TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   
		
		// se existir contratos da funerária vinculados ao cliente
		if QRY->(!Eof()) 
		
			lRet := .F.
			
			// verifico se o produto tem a amarração com os planos do cemitério
			// caso não tenha, verifico se está em algum item do contrato
			if !Empty(QRY->PLANO)
				MsgAlert("Não é possível excluir o produto, pois está vinculado ao plano da Funerária " + AllTrim(QRY->PLANO) + " filial " + AllTrim(QRY->FILIAL) + ".")
			else
				MsgAlert("Não é possível excluir o produto, pois está vinculado ao contrato da Funerária " + AllTrim(QRY->CONTRATO) + " filial " + AllTrim(QRY->FILIAL) + ".")
			endif
			
		endif
		
		// fecho a área criada
		If Select("QRY") > 0
			QRY->(DbCloseArea())
		EndIf 
	
	endif
	
	if lRet .AND. lCemiterio
	
		// verifico se existe este alias criado
		If Select("QRY") > 0
			QRY->(DbCloseArea())
		EndIf 
		
		cQry := " SELECT " 										+ cPulaLinha
		cQry += " U06.U06_FILIAL AS FILIAL, " 					+ cPulaLinha
		cQry += " U06.U06_CODIGO AS PLANO, " 					+ cPulaLinha
		cQry += " '' AS CONTRATO " 								+ cPulaLinha
		cQry += " FROM " 										+ cPulaLinha
		cQry += " " + RetSqlName("U06") + " U06 " 				+ cPulaLinha
		cQry += " WHERE " 										+ cPulaLinha
		cQry += " U06.D_E_L_E_T_ <> '*' " 						+ cPulaLinha
		cQry += " AND U06.U06_PRODUT = '" + SB1->B1_COD + "' " 	+ cPulaLinha
		cQry += " UNION " 										+ cPulaLinha
		cQry += " SELECT " 										+ cPulaLinha
		cQry += " U01.U01_FILIAL AS FILIAL, " 					+ cPulaLinha
		cQry += " '' AS PLANO, " 								+ cPulaLinha
		cQry += " U01.U01_CODIGO AS CONTRATO "					+ cPulaLinha
		cQry += " FROM " 										+ cPulaLinha
		cQry += " " + RetSqlName("U01") + " U01 " 				+ cPulaLinha
		cQry += " WHERE " 										+ cPulaLinha
		cQry += " U01.D_E_L_E_T_ <> '*' " 						+ cPulaLinha
		cQry += " AND U01.U01_PRODUT = '" + SB1->B1_COD + "' " 	+ cPulaLinha   
		
		// função que converte a query genérica para o protheus
		cQry := ChangeQuery(cQry)
		
		// crio o alias temporario
		TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   
		
		// se existir contratos da funerária vinculados ao cliente
		if QRY->(!Eof()) 
		
			lRet := .F.
			
			// verifico se o produto tem a amarração com os planos do cemitério
			// caso não tenha, verifico se está em algum item do contrato
			if !Empty(QRY->PLANO)
				MsgAlert("Não é possível excluir o produto, pois está vinculado ao plano do Cemitério " + AllTrim(QRY->PLANO) + " filial " + AllTrim(QRY->FILIAL) + ".")
			else
				MsgAlert("Não é possível excluir o produto, pois está vinculado ao contrato do Cemitério " + AllTrim(QRY->CONTRATO) + " filial " + AllTrim(QRY->FILIAL) + ".")
			endif
			
		endif
		
		// fecho a área criada
		If Select("QRY") > 0
			QRY->(DbCloseArea())
		EndIf 
	
	endif

endif

RestArea(aAreaSB1)
RestArea(aArea)

Return(lRet)