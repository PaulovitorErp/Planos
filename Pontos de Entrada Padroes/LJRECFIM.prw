#include 'protheus.ch'
#include 'parmtype.ch'

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} LJRECFIM
O ponto de entrada LJRECFIM é executado após a confirmação do recebimento\estorno de títulos no módulo 
Controle de Lojas - rotina Venda Assistida - opção Recebimentos (CTRL + D).

(Comissões de Motoqueiros) 
Esta sendo utilizado para limpar o codigo do vendedor vinculado ao usuario logado (caixa) no campo "E1_XVENDCB" dos títulos recebidos,
quando estornado alguma baixa.

@author Pablo Cavalcante
@since 22/06/2016
@version undefined
@param  cOper, Tipo da operação:1- Recebimento ,2- Estorno
		lRet, Controle da validação, retorno da funcao
		nValorTot, Valor Total
		aTitulo, Array com os dados dos títulos selecionados
		aDadosEst, Dados dos títulos estornados
		
@type function
@return nil
@history 21/05/2020, g.sampaio, Retirado a função toString do ponto de entrada LJRECFIM
/*/
User Function LJRECFIM()

Local aArea 	:= GetArea()
Local aAreaSE1 	:= SE1->(GetArea())
Local cOper 	:= ParamIXB[1]
Local lRet 		:= ParamIXB[2]
Local nValorTot := ParamIXB[3]
Local aTitulo 	:= ParamIXB[4]
Local aDadosEst := ParamIXB[5]

Local cVendedor := FT300VEND() //-> Obtem o codigo de vendedor do usuario logado, caso exista a associacao do usuario atual com um vendedor.
Local nX := 0

Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)

If lCemiterio .Or. lFuneraria 
						
	If !Empty(cVendedor) .and. cOper == "2" .and. Len(aDadosEst) > 0
		
		For nX:=1 to Len(aDadosEst)
		
				
			DbSelectArea("SE1")
			SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If SE1->(DbSeek(xFilial("SE1")+aDadosEst[nX,5]+aDadosEst[nX,6]+aDadosEst[nX,1]+aDadosEst[nX,2]+aDadosEst[nX,3]+aDadosEst[nX,4]))
				
				If Reclock("SE1", .F.)
					SE1->E1_XVENDCB := "" 
					SE1->E1_XFILVEN := "" 
					SE1->(MsUnlock())
				EndIf

			EndIf
				
		Next nX
	
	EndIf
Endif

RestArea(aAreaSE1)
RestArea(aArea)
	
Return(Nil)
