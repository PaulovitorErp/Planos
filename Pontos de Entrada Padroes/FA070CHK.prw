#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} FA070CHK
----------------------------------
O ponto de entrada FA070CHK sera
executado na entrada da funcao
antes de carregar a tela de
baixa do contas a receber.
----------------------------------
@type function
@version 1.0
@author nata.queiroz
@since 13/04/2020
@return lRet, logic
/*/
User Function FA070CHK
    Local lRet := .T.

    If FindFunction("U_UVIND18")
        //-- Valida atualização em títulos que estão em recorrência
        lRet := U_UVIND18(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
    EndIf

Return lRet