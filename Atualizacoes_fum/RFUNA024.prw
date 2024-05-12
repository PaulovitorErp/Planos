#include 'protheus.ch'
#include 'parmtype.ch'
#include 'topconn.ch'

/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͺ��
���Programa  � RFUNA024 � Autor � Wellington Gon�alves         � Data� 21/12/2016 ���
���������������������������������������������������������������������������������ͺ��
���Desc.     � Fun��o que verifica se o contrato da funer�ria pode ser finalizado ���
���������������������������������������������������������������������������������ͺ��
���Uso       � Funer�ria 			              			                      ���
���������������������������������������������������������������������������������ͺ��
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/

User Function RFUNA024(cContrato)
	
Local aArea			:= GetArea()
Local aAreaUF2		:= UF2->(Getarea())
Local cPulaLinha	:= chr(13)+chr(10)  
Local cQry 			:= ""
Local lFinaliza		:= .F.
Local nQtdParc		:= 0

// verifico se n�o existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

cQry += " SELECT " 															+ cPulaLinha
cQry += " COUNT(*) AS PARCELAS_GERADAS, " 									+ cPulaLinha
cQry += " SE1.E1_XCTRFUN AS CODIGO_CONTRATO " 								+ cPulaLinha
cQry += " FROM " 															+ cPulaLinha
cQry += " " + RetSqlName("SE1") + " SE1 " 									+ cPulaLinha
cQry += " WHERE " 															+ cPulaLinha
cQry += " SE1.D_E_L_E_T_ <> '*' " 											+ cPulaLinha
cQry += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "					+ cPulaLinha
cQry += " AND SE1.E1_XCTRFUN = '" + cContrato + "'  "						+ cPulaLinha
cQry += " GROUP BY SE1.E1_XCTRFUN " 										+ cPulaLinha	

// fun��o que converte a query gen�rica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

// verifico quantas parcelas j� foram geradas para este contrato
if QRY->(!Eof())
	nQtdParc := QRY->PARCELAS_GERADAS
endif

// verifico se n�o existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf   

cQry := " SELECT "                                                    		+ cPulaLinha
cQry += " UF2.UF2_FILIAL AS FILIAL, "                                  		+ cPulaLinha
cQry += " UF2.UF2_CODIGO AS CONTRATO, "                               		+ cPulaLinha
cQry += " SE1.E1_NUM AS TITULO, "                                     		+ cPulaLinha
cQry += " SE1.E1_PARCELA AS PARCELA, " 	                              		+ cPulaLinha
cQry += " SE1.E1_VENCTO AS VENCIMENTO "                                		+ cPulaLinha
cQry += " FROM "                                                      		+ cPulaLinha
cQry +=   + RetSqlName("UF2") + " UF2 "                       	      		+ cPulaLinha
cQry += " 	INNER JOIN "                                              		+ cPulaLinha
cQry +=  	+ RetSqlName("SE1") + " SE1 "                             		+ cPulaLinha
cQry += " 	ON ( "                                                    		+ cPulaLinha
cQry += " 		SE1.D_E_L_E_T_	<> '*' "									+ cPulaLinha
cQry += " 		AND SE1.E1_FILIAL	= '" + xFilial("SE1") + "' "			+ cPulaLinha
cQry += " 		AND SE1.E1_SALDO	> 0 " // Em aberto						+ cPulaLinha
cQry += " 		AND SE1.E1_XCTRFUN	= UF2.UF2_CODIGO "						+ cPulaLinha
cQry += " 	 	) "                                                    		+ cPulaLinha
cQry += " WHERE "                                                     		+ cPulaLinha
cQry += " UF2.D_E_L_E_T_ <> '*' "                                     		+ cPulaLinha
cQry += " AND UF2.UF2_FILIAL = '" + xFilial("UF2") + "' "             		+ cPulaLinha
cQry += " AND UF2.UF2_CODIGO = '" + cContrato + "' "                   		+ cPulaLinha

// fun��o que converte a query gen�rica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

// se n�o existir t�tulos em aberto para este contrato
if QRY->(Eof())

	// verifico se n�o existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf   

	cQry := " SELECT "                                                    		+ cPulaLinha
	cQry += " UF2.UF2_FILIAL AS FILIAL, "                                  		+ cPulaLinha
	cQry += " UF2.UF2_CODIGO AS CONTRATO, "                               		+ cPulaLinha
	cQry += " UF4.UF4_ITEM AS BENEFICIARIO, "                              		+ cPulaLinha
	cQry += " UF4.UF4_NOME AS NOME " 	      	                        		+ cPulaLinha
	cQry += " FROM "                                                      		+ cPulaLinha
	cQry +=   + RetSqlName("UF2") + " UF2 "                       	      		+ cPulaLinha
	cQry += " 	INNER JOIN "                                              		+ cPulaLinha
	cQry +=  	+ RetSqlName("UF4") + " UF4 "                             		+ cPulaLinha
	cQry += " 	ON ( "                                                    		+ cPulaLinha
	cQry += " 		UF4.D_E_L_E_T_	<> '*' "									+ cPulaLinha
	cQry += " 		AND UF4.UF4_FILIAL	= '" + xFilial("UF4") + "' "			+ cPulaLinha
	cQry += " 		AND UF4.UF4_CODIGO	= UF2.UF2_CODIGO "						+ cPulaLinha
	cQry += " 		AND UF4.UF4_FALECI	= ' ' "									+ cPulaLinha
	cQry += " 	 	) "                                                    		+ cPulaLinha
	cQry += " WHERE "                                                     		+ cPulaLinha
	cQry += " UF2.D_E_L_E_T_ <> '*' "                                     		+ cPulaLinha
	cQry += " AND UF2.UF2_FILIAL = '" + xFilial("UF2") + "' "             		+ cPulaLinha
	cQry += " AND UF2.UF2_CODIGO = '" + cContrato + "' "                   		+ cPulaLinha

	// fun��o que converte a query gen�rica para o protheus
	cQry := ChangeQuery(cQry)
	
	// crio o alias temporario
	TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   
	
	// se todos os benefici�rios j� faleceram
	if QRY->(Eof())
		lFinaliza := .T.
	endif

endif

UF2->(DbSetOrder(1)) // UF2_FILIAL + UF2_CODIGO
if UF2->(DbSeek(xFilial("UF2") + cContrato))

	// se a quantidade de t�tulos for MENOR que a quantidade de parcelas do contrato
	if nQtdParc < UF2->UF2_QTPARC
		lFinaliza := .F.
	endif

	// altero o status do contrato para F=Finalizado
	if lFinaliza
			
		if RecLock("UF2",.F.)
			UF2->UF2_STATUS := "F" // Finalizado
			UF2->(MsUnlock())
			MsgInfo("Foram baixadas todas as parcelas deste contrato e todos os benefici�rios j� utilizaram os servi�os. Este contrato ser� finalizado!","Finaliza��o de Contrato")
		endif
			
	else
			
		// se o contrato estava com status de finalizado
		// e existem t�tulos em aberto, volto seu status para ativo
		if UF2->UF2_STATUS == "F"
	
			if RecLock("UF2",.F.)
				UF2->UF2_STATUS := "A" // Ativo
				UF2->(MsUnlock())
				MsgInfo("Este contrato foi retornado para o Status Ativo!","Finaliza��o de Contrato")
			endif
			
		endif
				
	endif

endif

// verifico se n�o existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf   

RestArea(aAreaUF2)
RestArea(aArea)
	
Return()