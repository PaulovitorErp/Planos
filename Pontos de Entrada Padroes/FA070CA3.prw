#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} FA070CA3
------------------------------------------------
O ponto de entrada FA070CA3 sera executado
antes da entrada na rotina cancelamento de baixa
do contas a receber, para verificar se esta
pode ou nao ser cancelada.
------------------------------------------------
@type function
@version 1.0
@author nata.queiroz
@since 08/04/2020
@return lRet, logic
/*/
User Function FA070CA3
    Local lRet := .T.

    If FindFunction("U_UVIND18")
        //-- Valida atualização em títulos que estão em recorrência
        lRet := U_UVIND18(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
    EndIf

Return lRet