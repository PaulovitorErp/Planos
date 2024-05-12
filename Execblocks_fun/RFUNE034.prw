#Include 'Protheus.ch'
#Include 'Topconn.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ RCPGE007 º Autor ³ Raphael Martins 			   º Data³ 27/07/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Rotina para replicar os dados alterados do cliente para os contratos±±
±±º			 ³ dos mesmo														   ±±		
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ POSTUMOS	- Funeraria                			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


User Function RFUNE034(cCliente,cLoja)

Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->( GetArea() )
Local aAreaUF2	:= UF2->( GetArea() )
Local aAreaUF4	:= UF4->( GetArea() )


UF2->( DbSetOrder(2) ) //U00_FILIAL + U00_CLIENT + U00_LOJA
SA1->( DbSetOrder(1) ) //A1_FILIAL + A1_COD + A1_LOJA
UF4->( DbSetOrder(3) ) //UF4_FILIAL + UF4_CODIGO + UF4_CLIENT + UF4_LOJA

If SA1->( DbSeek( xFilial("SA1") + cCliente + cLoja ) )
	
	If UF2->( DbSeek( xFilial("UF2") + cCliente + cLoja ) )
	
		While UF2->( !EOF() ) .And. UF2->UF2_CLIENT == cCliente .And. UF2->UF2_LOJA == cLoja
		
			if UF4->(MsSeek(xFilial("UF4") + UF2->UF2_CODIGO + cCliente + cLoja ))
			
				RecLock("UF4",.F.)
			
				UF4->UF4_CPF 	:= SA1->A1_CGC
				UF4->UF4_SEXO	:= SA1->A1_XSEXO
				UF4->UF4_ESTCIV	:= SA1->A1_XESTCIV
				UF4->UF4_NOME	:= SA1->A1_NOME
				UF4->UF4_DTNASC	:= SA1->A1_XDTNASC	
				UF4->UF4_IDADE	:= Calc_Idade(dDataBase,SA1->A1_XDTNASC)
				
				UF4->(MsUnlock())
				
			endif
			
			UF2->(DbSkip())
			
		EndDo
		
	endif
	
endif
	
	
RestArea(aArea)
RestArea(aAreaSA1)
RestArea(aAreaUF2)
RestArea(aAreaUF4)
	
Return()
