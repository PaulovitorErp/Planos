#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FA070CA2 ºAutor ³ Wellington Gonçalves º Data ³ 21/12/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada executado após a conclusão do cancelamentoº±±
±±		     ³ da baixa dos títulos a receber.							  º±±
±±		     ³ Está sendo utilizado para voltar o contrato da funerária   º±±
±±			 ³ para Status A=Ativo, caso esteja finalizado..				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cemitério e Funerária                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FA070CA2()
/*
Local aArea			:= GetArea()
Local aAreaUF2		:= {}
Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
Local nOpc  		:= PARAMIXB[1] // 5=Cancelamento da baixa ; 6=Exclusao da baixa

if lFuneraria
	
	aAreaUF2 := UF2->(GetArea())
	
	// posiciono no conrato
	UF2->(DbSetOrder(1)) // UF2_FILIAL + UF2_CODIGO
	
	if UF2->(DbSeek(xFilial("UF2") + SE1->E1_XCTRFUN))
		
		// se o contrato estava com status de F=FINALIZADO
		// e está sendo excluido um apontamento
		if UF2->UF2_STATUS == "F"
	
			// volto seu status para A=ATIVO
			if RecLock("UF2",.F.)
				UF2->UF2_STATUS := "A"
				UF2->(MsUnlock())
				MsgInfo("Este contrato foi retornado para o Status Ativo!","Finalização de Contrato")
			endif
			
		endif
		
	endif
	
	RestArea(aAreaUF2)
		
endif

RestArea(aArea)
*/
Return(Nil)
