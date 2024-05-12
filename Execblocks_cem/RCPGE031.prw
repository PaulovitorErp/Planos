#include "totvs.ch"

/*/{Protheus.doc} RCPGE031
fonte para executar a locacao de nicho sem interface
@type function
@version 1.0
@author g.sampaio
@since 06/04/2020
@param cContraNicho, character, codigo do contrato
@return logico, caso tenha gera corretamente as taxas de locacao
/*/
User Function RCPGE031( cContraNicho )

    Local aArea             := GetArea()
    Local aParam            := {}
    Local cTrbContrato      := ""
    Local cTrbParcelas      := ""
    Local lContinua         := .T.
    Local oTempContrato     := Nil
    Local oTempParcelas     := Nil

    Default cContraNicho    := ""

    // vou preencher o array de parametros
    aAdd( aParam, cContraNicho )
    aAdd( aParam, cContraNicho )
    aAdd( aParam, "" )
    aAdd( aParam, "" )
    aAdd( aParam, 0 )
    aAdd( aParam, stod("") )
    aAdd( aParam, stod("") )
    aAdd( aParam, 1 ) // ambos

    // executo a funcao para montar os dados para gerar a taxa de locaco do nicho
    lContinua := U_RCPGE029( @cTrbContrato, @cTrbParcelas, aParam, /*cLog*/,;
        @oTempContrato, @oTempParcelas, /*oBrowseContrato*/, /*oBrowseParcelas*/, /*oProcess*/, /*lEnd*/ )

    // se estiver tudo certo continua
    If lContinua

        // gero as parcelas da taxa de locacao
        lContinua := U_RCPGE030( cTrbContrato, cTrbParcelas, /*cLog*/, oTempContrato, oTempParcelas, /*oProcess*/ )

    EndIf

    // verifico se o alias esta em uso
    If Select(cTrbContrato)
        (cTrbContrato)->(DbCloseArea())
    EndIf

    // verifico se o alias esta em uso
    If Select(cTrbContrato)
        (cTrbParcelas)->(DbCloseArea())
    EndIf

    RestArea( aParam )

Return(lContinua)
