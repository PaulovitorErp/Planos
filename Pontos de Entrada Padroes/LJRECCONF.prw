#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} LJRECCONF
-----------------------------------------------------------
O ponto de entrada LJRECCONF
está localizado antes da função
de estorno do recebimento de
títulos, no módulo Controle de Lojas,
rotina Venda Assistida, que permite
fazer customizações na opção Recebimentos (CTRL+D)

LJRECCONF - ( [ cOper ], [ nTotal ], [ aTitulo ] ) --> lRet
Retorno:
- lRet (logico)
- Retorno lógico:
- True (.T.) = Confirma
- False (.F.) = Não confirma
-----------------------------------------------------------
@type function
@version 1.0
@author nata.queiroz
@since 14/04/2020
@return lRet, logic
/*/
User Function LJRECCONF()
	Local lRet := .T.
	Local aArea := GetArea()
	Local cOpc := PARAMIXB[1]
	Local aTit := PARAMIXB[3]
	Local nX := 0

	If cOpc == "2"

		If FindFunction("U_UVIND18")
			For nX := 1 To Len(aTit)

				//-- aTit[nX][1]  => Flag marcada
				//-- aTit[nX][2]  => Prefixo
				//-- aTit[nX][3]  => Titulo
				//-- aTit[nX][4]  => Parcela
				//-- aTit[nX][11] => Tipo

				If aTit[nX][1]
					//-- Valida atualização em títulos que estão em recorrência
					lRet := U_UVIND18(aTit[nX][2], aTit[nX][3], aTit[nX][4], aTit[nX][11])
					
					If !lRet
						Exit
					EndIf
				EndIf

			Next nX
		EndIf

	EndIf

	RestArea(aArea)

Return lRet
