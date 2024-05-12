#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} UVIND18
Valida atualiza��o em t�tulos que est�o em recorr�ncia
@type function
@version 1.0
@author nata.queiroz
@since 08/04/2020
@param cPrefix, character
@param cTitulo, character
@param cParcel, character
@param cTipo, character
@return lRet, logic
/*/
User Function UVIND18(cPrefix, cTitulo, cParcel, cTipo)
    Local lRet := .T.
    Local lFuneraria := SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio := SuperGetMV("MV_XCEMI",,.F.)
    Local lRecorrencia := SuperGetMv("MV_XATVREC", .F., .F.)
    Local aArea := GetArea()
    Local aAreaU65 := U65->( GetArea() )
    Local cStatus := "A"
    Local cChvTit := cPrefix + cTitulo + cParcel + cTipo
    Local cMsg := ""
    Local aSoluc := {}

    If lFuneraria .Or. lCemiterio
        If lRecorrencia
            //-- Permiti atualiza��es apenas pelo Job de Recebimento Vindi
            If !FWIsInCallStack("U_UVIND05A")
                U65->( dbSetOrder(1) ) //-- U65_FILIAL+U65_PREFIX+U65_NUM+U65_PARCEL+U65_TIPO+U65_STATUS
                If U65->( MsSeek(xFilial("U65") + cPrefix + cTitulo + cParcel + cTipo + cStatus) )
                    lRet := .F. //-- Titulo esta em recorr�ncia, existe fatura na Vindi
                    
                    If !IsBlind()
                        cMsg := "Este t�tulo est� em recorr�ncia. Nr.: " + cChvTit
                        aSoluc := {"Por favor retire o t�tulo da recorr�ncia antes de prosseguir com a movimenta��o."}
                        Help(Nil, Nil, "Aten��o!", Nil, cMsg, 1, 0, Nil, Nil, Nil, Nil, Nil, aSoluc)
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf

    RestArea(aArea)
    RestArea(aAreaU65)

Return lRet
