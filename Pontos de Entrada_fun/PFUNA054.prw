#INCLUDE 'PROTHEUS.CH'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} PFUNA054
Ponto de entrada da rotina de cadastro de regras de reajuste
@type function
@version 1.0
@author g.sampaio
@since 22/09/2021
@return logical, retorno do ponto de entrada
/*/
User Function PFUNA054()

	Local aArea			:= GetArea()
	Local aAreaUI4		:= UI4->(GetArea())
	Local aParam 		:= PARAMIXB
	Local oObj			:= aParam[1]
	Local cIdPonto		:= aParam[2]
	Local lRet 			:= .T.

	If cIdPonto == 'MODELPOS' .And. (oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4)

		lRet := U_FUNA054A()

	EndIf

	RestArea(aAreaUI4)
	RestArea(aArea)

Return(lRet)
