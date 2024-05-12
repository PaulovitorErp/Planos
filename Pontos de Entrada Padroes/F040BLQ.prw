#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ F040BLQ º Autor ³ Wellington Gonçalves º Data ³ 23/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para validar a exclusão do título		  º±±
±±		     ³ a receber												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cemitério e Funerária                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function F040BLQ()

Local aArea			:= GetArea()
Local aAreaSE1		:= SE1->(GetArea())
Local aAreaU60		:= U60->(GetArea())
Local lRet 			:= .T.
Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
Local cCodModulo	:= IIF(lFuneraria, "F", "C")
Local cTipo			:= ""

if !IsBlind() // não será validado em rotinas automaticas

	if !ALTERA .AND. !INCLUI // se a operação for exclusão
	
		if lFuneraria // verifico se este título é de um contrato da funerária
		
			// título de cancelamento de contrato pode excluir manualmente
			cTipo := SuperGetMv("MV_XCANFUN",.F.,"CAN")
		
			if AllTrim(SE1->E1_TIPO) <> AllTrim(cTipo) .AND. !Empty(SE1->E1_XCTRFUN)
				lRet := .F.
				MsgAlert("Não é possível realizar esta operação para este título a receber, pois está vinculado ao contrato da Funerária " + AllTrim(SE1->E1_XCTRFUN) + ".")
			endif
		
		endif
		
		if lRet .AND. lCemiterio // verifico se este título é de um contrato do cemitério
		
			if !Empty(SE1->E1_XCONTRA)
				lRet := .F.
				MsgAlert("Não é possível realizar esta operação para este título a receber, pois está vinculado ao contrato do Cemitério " + AllTrim(SE1->E1_XCONTRA) + ".")
			endif
		
		endif 
	
	endif

	If ALTERA

		// Metodo de pagamento da vindi
		U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
		If U60->(DbSeek(xFilial("U60") + SE1->E1_XFORPG))
			// Metodo Ativo
			If U60->U60_STATUS == "A"
				//-- Verifica se existe pendencias de processamentos VINDI --//
				lRet := U_PENDVIND(SE1->E1_NUM, cCodModulo)
			EndIf
		EndIf

	EndIf

endif

RestArea(aAreaU60)
RestArea(aAreaSE1)
RestArea(aArea)

Return(lRet)
