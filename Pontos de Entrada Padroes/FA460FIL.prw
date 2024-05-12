#include "totvs.ch"

/*/{Protheus.doc} FA460FIL
Pe na liquiacao para filtrar titulos do contrato
@type function
@author Leandro Rodrigues
@since 17/07/2019
@version P12
@return character, cFiltro
@history 29/05/2020, g.sampaio, VPDV-473 - adicionado tratativa para o contrato de cemiterio RCPGA001
/*/
User Function FA460FIL()

    Local cFiltro := ""

    //Valido se chamada foi da rotina e contrato
    If FwIsInCallStack("U_RFUNA002") // contrato de funeraria

        If FwIsInCallStack("U_RUTILE46") .And. FwIsInCallStack("CfrmAntecipacao") // Novo Painel Financeiro
            cFiltro := ".AND. E1_XCTRFUN = '"+ UF2->UF2_CODIGO + "'"
        Else
            cFiltro := "AND E1_XCTRFUN = '"+ UF2->UF2_CODIGO + "'"
        EndIf

    ElseIf FwIsInCallStack("U_RCPGA001") // contrato de cemiterio

        If FwIsInCallStack("U_RUTILE46") .And. FwIsInCallStack("CfrmAntecipacao") // Novo Painel Financeiro
            cFiltro := ".AND. E1_XCONTRA = '"+ U00->U00_CODIGO + "'"
        Else
            cFiltro := "AND E1_XCONTRA = '"+ U00->U00_CODIGO + "'"
        EndIf

    Endif

Return(cFiltro)
