#include "protheus.ch"
#include "topconn.ch"
#include "fwmvcdef.ch"

#DEFINE CRLF CHR(10)+CHR(13)

User Function PUTIL049()

	Local aArea             := GetArea()
	Local aAreaU92          := U92->(GetArea())
	Local aParamBox         := {}
	Local aParam 		    := PARAMIXB
	Local oObj			    := aParam[1]
	Local cIdPonto		    := aParam[2]
	Local cTipoAgendamento  := ""
	Local lContinua         := .T.
	Local oModelU92	        := oObj:GetModel("U92MASTER")
	Local oStruU92  	    := FWFormStruct( 1, 'U92', /*bAvalCampo*/, /*lViewUsado*/ )	// abro o parambox
	Local xRet 			    := .T.

	//Ativacao do Model
	If cIdPonto == 'MODELVLDACTIVE'

	EndIf

	RestArea(aAreaU92)
	RestArea(aArea)

Return(xRet)
