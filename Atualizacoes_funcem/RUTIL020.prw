#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} RUTIL020
Sincronização Virtus Vendas
@type function
@version 1.0
@author nata.queiroz
@since 22/07/2020
/*/
User Function RUTIL020
    Local oGroup1
    Local oPlan
    Local oPlanItem
    Local oPriceTab
    Local oProduct
    Local oRule
    Local oRuleCond
    Local oRuleItem
    Static oDlg

    DEFINE MSDIALOG oDlg TITLE "Sincronização Virtus Vendas" FROM 000, 000  TO 400, 400 COLORS 0, 16777215 PIXEL

    @ 010, 010 GROUP oGroup1 TO 190, 190 PROMPT "Sincronizações" OF oDlg COLOR 0, 16777215 PIXEL
    @ 025, 050 BUTTON oProduct PROMPT "Produtos" SIZE 100, 015 OF oDlg ACTION {|| U_RUTILW01() } PIXEL
    @ 045, 050 BUTTON oPriceTab PROMPT "Tabelas Preços" SIZE 100, 015 OF oDlg ACTION {|| U_RUTILW02() } PIXEL
    @ 065, 050 BUTTON oRule PROMPT "Regras" SIZE 100, 015 OF oDlg ACTION {|| U_RUTILW03() } PIXEL
    @ 085, 050 BUTTON oRuleItem PROMPT "Regras Itens" SIZE 100, 015 OF oDlg ACTION {|| U_RUTILW04() } PIXEL
    @ 105, 049 BUTTON oRuleCond PROMPT "Regras Condições" SIZE 100, 015 OF oDlg ACTION {|| U_RUTILW05() } PIXEL
    @ 125, 050 BUTTON oPlan PROMPT "Planos" SIZE 100, 015 OF oDlg ACTION {|| U_RUTILW06() } PIXEL
    @ 145, 050 BUTTON oPlanItem PROMPT "Planos Itens" SIZE 100, 015 OF oDlg ACTION {|| U_RUTILW07() } PIXEL
    @ 165, 050 BUTTON oPlanItem PROMPT "Bairros" SIZE 100, 015 OF oDlg ACTION {|| U_RUTILW11() } PIXEL


    ACTIVATE MSDIALOG oDlg CENTERED
Return

/*/{Protheus.doc} GrvLogU56
Grava Log de integracao na tabela U56
@type function
@version 1.0
@author nata.queiroz
@since 24/07/2020
@param cTabela, character
@param cJson, character
@param cRetorno, character
/*/
User Function GrvLogU56(cTabela, cJson, cRetorno)
    //Inclui log da integração
    RecLock("U56",.T.)
    U56->U56_FILIAL := xFilial("U56")
    U56->U56_CODIGO	:= GetSX8Num("U56","U56_CODIGO")
    U56->U56_TABELA	:= cTabela
    U56->U56_JSON	:= cJson
    U56->U56_RETORN	:= cRetorno
    U56->U56_DATA	:= dDataBase
    U56->U56_HORA	:= Time()
    U56->U56_USER	:= cUserName
    U56->(MsUnlock())
    ConfirmSX8()
Return
