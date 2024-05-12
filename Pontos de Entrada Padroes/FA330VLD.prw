#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} FA330VLD
------------------------------------------------
O ponto de entrada FA330VLD tem como finalidade
possibilitar customização de uma validação na
confirmação dos títulos a compensar. Este ponto
de entrada não passa nenhum parametro e deve
ter retorno logico (.T. ou .F.) e será ativado
ao confirmar no botão OK.
------------------------------------------------
@type function
@version 1.0
@author nata.queiroz
@since 13/04/2020
@return lRet, logic
/*/
User Function FA330VLD
    Local lRet := .T.

    If FindFunction("U_UVIND18")
        //-- Valida atualização em títulos que estão em recorrência
        lRet := U_UVIND18(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
    EndIf

Return lRet