#include 'protheus.ch'
#include 'parmtype.ch'

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} LJRECBXFIM
O ponto de entrada LJRECBXFIM é utilizado no final da gravação dos movimentos bancários após o recebimento de títulos.

(Comissões de Motoqueiros) 
Esta sendo utilizado para gravar o codigo do vendedor vinculado ao usuario logado (caixa) no campo "E1_XVENDCB" dos títulos recebidos.

@author Pablo Cavalcante.
@since 19/05/2016
@version undefined.
@param aSE5Bxas, Array que armazena as informações da tabela SE5 ao ser gerada.
@type function
/*/

User Function LJRECBXFIM()

Local aArea 		:= GetArea()
Local aAreaSE1 		:= SE1->(GetArea())
Local aAreaSE5 		:= SE5->(GetArea())
Local aSE5Bxas 		:= ParamIXB[1] 
Local cVendedor 	:= U_RetVend() //Obtem o codigo de vendedor do usuario logado, caso exista a associacao do usuario atual com um vendedor.
Local nX 			:= 0

Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)

If lCemiterio .Or. lFuneraria .And. Len(aSE5Bxas) > 0 
	
		For nX:=1 to Len(aSE5Bxas)
		
			DbSelectArea("SE5")
			SE5->(DbGoTo(aSE5Bxas[nX][1]))
				
			DbSelectArea("SE1")
			SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If SE1->(DbSeek(SE5->(E5_FILIAL+E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)))
				
				If !Empty(cVendedor)
					
					If Reclock("SE1", .F.)
						SE1->E1_XVENDCB := cVendedor
						SE1->E1_XFILVEN	:= xFilial("SA3")
						SE1->(MsUnlock())
					EndIf
				EndIf

			EndIf
			
		Next nX 
		
Endif

RestArea(aAreaSE5)
RestArea(aAreaSE1)
RestArea(aArea)

Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetVend ºAutor  ³Raphael Martins       º Data ³  10/03/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtem o codigo de vendedor do usuario logado, caso exista a º±±
±±º          ³associacao do usuario atual com um vendedor.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Vale                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RetVend()

Local aArea		:= GetArea()
Local aAreaSA3	:= SA3->(GetArea())
Local cVendedor	:= Space(TamSx3("A3_COD")[1])

DbSelectArea("SA3")
SA3->( DbSetOrder(7) ) //A3_FILIAL+A3_CODUSR
		
If SA3->( DbSeek(xFilial("SA3")+__cUserId) )
	cVendedor 		:= SA3->A3_COD
EndIf   

RestArea(aAreaSA3)
RestArea(aArea)

Return(cVendedor)              

               
