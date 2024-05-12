#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT410ACE ºAutor ³ Wellington Gonçalves º Data ³ 23/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para validar a exclusão do pedido de vendaº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cemitério e Funerária                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MT410ACE()

Local aArea			:= GetArea()
Local aAreaSC5		:= SC5->(GetArea())
Local lRet 			:= .T.
Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
Local nOpc  		:= PARAMIXB[1]

if !IsBlind() // não será validado em rotinas automaticas

	if nOpc == 1 // se a operação for exclusão
	
		if lFuneraria // verifico se este pedido de venda é de um contrato da funerária
		
			if !Empty(SC5->C5_XAPTOFU)
				lRet := .F.
				MsgAlert("Não é possível excluir o pedido de venda, pois está vinculado ao Apontamento de Serviço " + AllTrim(SC5->C5_XCTRFUN) + ".")
			endif
		
		endif
		
		if lRet .AND. lCemiterio // verifico se este pedido de venda é de um contrato do cemitério
			if !Empty(SC5->C5_XCONTRA) .And. !IsInCallStack("U_RCPGA001")
				lRet := .F.
				MsgAlert("Não é possível excluir o pedido de venda, pois está vinculado ao contrato do Cemitério " + AllTrim(SC5->C5_XCONTRA) + ".")
			endif
		
		endif 
	
	endif

endif

RestArea(aAreaSC5)
RestArea(aArea)

Return(lRet)