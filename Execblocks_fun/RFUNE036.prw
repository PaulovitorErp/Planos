#Include "Topconn.ch"
#Include "Totvs.ch"

/*/{Protheus.doc} RFUNE036
Funcao chamada na validacao do campo FO0_XFORPG na rotina de liquidacao
@author Leandro Rodrigues
@since 06/06/2019
@version P12
@param nulo
@return nulo
/*/
User Function RFUNE036()

Local oModel	:= FWModelActive()
Local oView		:= FWViewActive()
Local oModelFO1 := oModel:GetModel("TITSELFO1")
Local oModelFO2 := oModel:GetModel("TITGERFO2")
Local nX        := 1

For nX:= 1 to oModelFO2:Length()

    oModelFO2:GoLine(nX)

    oModelFO2:LoadValue("FO2_XFORPG", FWFldGet("FO0_XFORPG"))
    
Next nX

Return .T.