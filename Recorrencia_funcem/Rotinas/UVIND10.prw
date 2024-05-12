#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH" 
#INCLUDE "topconn.ch" 

/*###########################################################################
#############################################################################
## Programa  | IntegraVindi |Autor| Wellington Gonçalves |Data| 21/01/2019 ##
##=========================================================================##
## Desc.     | Funçao que consulta todos os contratos do cliente		   ##
## 		     | e envia a alteração para Vindi							   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND10(cCliente,cLoja)
	
Local aArea			:= GetArea()
Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
Local cQry			:= ""
Local cPulaLinha	:= chr(13)+chr(10)
Local oVindi		:= NIL
Local cOrigem		:= "UVIND10"
Local cOrigemDesc	:= "Alteracao Cadastro de Cliente"
		
// crio o objeto de integracao com a vindi
oVindi := IntegraVindi():New()

if lFuneraria

	// verifico se existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf 
	
	cQry := " SELECT " 										+ cPulaLinha
	cQry += " UF2.UF2_FILIAL AS FILIAL, " 					+ cPulaLinha
	cQry += " UF2.UF2_CODIGO AS CONTRATO, " 				+ cPulaLinha
	cQry += " UF2.UF2_CLIENT AS CLIENTE, " 					+ cPulaLinha
	cQry += " UF2.UF2_LOJA AS LOJA " 						+ cPulaLinha
	cQry += " FROM " 										+ cPulaLinha
	cQry += " " + RetSqlName("UF2") + " UF2 " 				+ cPulaLinha
	cQry += " INNER JOIN " 									+ cPulaLinha
	cQry += " " + RetSqlName("U61") + " U61 " 				+ cPulaLinha
	cQry += " ON ( " 										+ cPulaLinha
	cQry += " 	U61.D_E_L_E_T_ <> '*' " 					+ cPulaLinha
	cQry += " 	AND U61.U61_FILIAL = UF2.UF2_FILIAL "		+ cPulaLinha
	cQry += " 	AND U61.U61_CONTRA = UF2.UF2_CODIGO "		+ cPulaLinha
	cQry += " 	AND U61.U61_CLIENT = UF2.UF2_CLIENT "		+ cPulaLinha
	cQry += " 	AND U61.U61_LOJA = UF2.UF2_LOJA "			+ cPulaLinha
	cQry += " 	AND U61.U61_STATUS = 'A' "					+ cPulaLinha
	cQry += " ) " 											+ cPulaLinha
	cQry += " WHERE " 										+ cPulaLinha
	cQry += " UF2.D_E_L_E_T_ <> '*' " 						+ cPulaLinha
	cQry += " AND UF2.UF2_CLIENT = '" + cCliente 	+ "' " 	+ cPulaLinha
	cQry += " AND UF2.UF2_LOJA = '" + cLoja 		+ "' " 	+ cPulaLinha
	
	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)
	
	// crio o alias temporario
	TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   
	
	// se existir contratos da funerária vinculados ao cliente
	if QRY->(!Eof()) 
		
		While QRY->(!Eof()) 
		
			oVindi:IncluiTabEnvio("F","1","A",1,QRY->FILIAL + QRY->CONTRATO + QRY->CLIENTE + QRY->LOJA,/*aProc*/,cOrigem,cOrigemDesc)
			QRY->(DbSkip()) 
		
		EndDo
		
	endif
	
	// fecho a área criada
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf 

endif

if lCemiterio

	// verifico se existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf 
	
	cQry := " SELECT " 										+ cPulaLinha
	cQry += " U00.U00_FILIAL AS FILIAL, " 					+ cPulaLinha
	cQry += " U00.U00_CODIGO AS CONTRATO, " 				+ cPulaLinha
	cQry += " U00.U00_CLIENT AS CLIENTE, " 					+ cPulaLinha
	cQry += " U00.U00_LOJA AS LOJA " 						+ cPulaLinha
	cQry += " FROM " 										+ cPulaLinha
	cQry += " " + RetSqlName("U00") + " U00 " 				+ cPulaLinha
	cQry += " INNER JOIN " 									+ cPulaLinha
	cQry += " " + RetSqlName("U61") + " U61 " 				+ cPulaLinha
	cQry += " ON ( " 										+ cPulaLinha
	cQry += " 	U61.D_E_L_E_T_ <> '*' " 					+ cPulaLinha
	cQry += " 	AND U61.U61_FILIAL = U00.U00_FILIAL "		+ cPulaLinha
	cQry += " 	AND U61.U61_CONTRA = U00.U00_CODIGO "		+ cPulaLinha
	cQry += " 	AND U61.U61_CLIENT = U00.U00_CLIENT "		+ cPulaLinha
	cQry += " 	AND U61.U61_LOJA = U00.U00_LOJA "			+ cPulaLinha
	cQry += " 	AND U61.U61_STATUS = 'A' "					+ cPulaLinha
	cQry += " ) " 											+ cPulaLinha
	cQry += " WHERE " 										+ cPulaLinha
	cQry += " U00.D_E_L_E_T_ <> '*' " 						+ cPulaLinha
	cQry += " AND U00.U00_CLIENT = '" + cCliente 	+ "' " 	+ cPulaLinha
	cQry += " AND U00.U00_LOJA = '" + cLoja 		+ "' " 	+ cPulaLinha   
	
	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)
	
	// crio o alias temporario
	TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   
	
	// se existir contratos da funerária vinculados ao cliente
	if QRY->(!Eof()) 

		While QRY->(!Eof()) 
		
			oVindi:IncluiTabEnvio("C","1","A",1,QRY->FILIAL + QRY->CONTRATO + QRY->CLIENTE + QRY->LOJA,/*aProc*/,cOrigem,cOrigemDesc)
			QRY->(DbSkip()) 
		
		EndDo

	endif
	
	// fecho a área criada
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf 

endif

RestArea(aArea)
	
Return()
