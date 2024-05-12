#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT040VDE ºAutor ³ Wellington Gonçalves º Data ³ 17/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para validar a exclusão do vendedor		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cemitério e Funerária                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT040VDE()

Local aArea			:= GetArea()
Local aAreaSA3		:= SA3->(GetArea())
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
		
		cQry := " SELECT " 											+ cPulaLinha
		cQry += " UF2.UF2_FILIAL AS FILIAL, " 						+ cPulaLinha
		cQry += " UF2.UF2_CODIGO AS CONTRATO " 						+ cPulaLinha
		cQry += " FROM " 											+ cPulaLinha
		cQry += " " + RetSqlName("UF2") + " UF2 " 					+ cPulaLinha
		cQry += " WHERE " 											+ cPulaLinha
		cQry += " UF2.D_E_L_E_T_ <> '*' " 							+ cPulaLinha
		cQry += " AND UF2.UF2_VEND = '" + SA3->A3_COD + "' " 		+ cPulaLinha
		cQry += " AND UF2.UF2_FILIAL = '" + SA3->A3_FILIAL + "' " 	+ cPulaLinha
		
		// função que converte a query genérica para o protheus
		cQry := ChangeQuery(cQry)
		
		// crio o alias temporario
		TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   
		
		// se existir contratos da funerária vinculados ao cliente
		if QRY->(!Eof()) 
			lRet := .F.
			Help(" ",1,"NODELETA",,"Não é possível excluir o vendedor, pois está vinculado ao contrato da Funerária " + AllTrim(QRY->CONTRATO) + " filial " + AllTrim(QRY->FILIAL) + ".",2,0)
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
		
		cQry := " SELECT " 											+ cPulaLinha
		cQry += " U00.U00_FILIAL AS FILIAL, " 						+ cPulaLinha
		cQry += " U00.U00_CODIGO AS CONTRATO " 						+ cPulaLinha
		cQry += " FROM " 											+ cPulaLinha
		cQry += " " + RetSqlName("U00") + " U00 " 					+ cPulaLinha
		cQry += " WHERE " 											+ cPulaLinha
		cQry += " U00.D_E_L_E_T_ <> '*' " 							+ cPulaLinha
		cQry += " AND U00.U00_VENDED = '" + SA3->A3_COD + "' " 		+ cPulaLinha	
		cQry += " AND U00.U00_FILIAL = '" + SA3->A3_FILIAL + "' " 	+ cPulaLinha   
		
		// função que converte a query genérica para o protheus
		cQry := ChangeQuery(cQry)
		
		// crio o alias temporario
		TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   
		
		// se existir contratos da funerária vinculados ao cliente
		if QRY->(!Eof()) 
			lRet := .F.
			Help(" ",1,"NODELETA",,"Não é possível excluir o vendedor, pois está vinculado ao contrato do Cemitério " + AllTrim(QRY->CONTRATO) + " filial " + AllTrim(QRY->FILIAL) + ".",2,0)
		endif
		
		// fecho a área criada
		If Select("QRY") > 0
			QRY->(DbCloseArea())
		EndIf 
	
	endif
	
endif

RestArea(aAreaSA3)
RestArea(aArea)

Return(lRet)