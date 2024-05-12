#Include 'Protheus.ch'
#include "topconn.ch"

/*/{Protheus.doc} RUTILE54
Consulta Especifica PRDCTR para multselecao de produtos/planos
para rotina Mensagens SMS (Zenvia)

@author Danilo
@since 01/02/2022
@version P12
@param nulo
@return nulo
/*/
User Function RUTILE54()

Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)

if lFuneraria

    U_RFUNA013()

elseif lCemiterio

    U_RCPGA018()

    &(ReadVar()) := U_RCPGA18A()

endif

Return(.T.)
