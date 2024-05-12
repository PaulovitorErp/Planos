#include "protheus.ch"

/*/{Protheus.doc} RCPGE005
Retorna Valor c/ Juros, utilizado no Grid (Parcelas/Taxas) do Contrato
@author TOTVS
@since 03/08/2016
@version P12
@param nVlrTit,nAcresc,dVencto
@return nRet
/*/

/******************************************************/
User Function RCPGE005(nVlrTit,nAcresc,dVencto,_nRecno)
/******************************************************/

	Local aArea			:= GetArea()
	Local nRet 			:= 0
	Local oVirtusFin	:= NIL

	Default nVlrTit		:= 0
	Default nVlrTit		:= 0
	Default dVencto		:= stod("")
	Default _nRecno		:= 0

	// verifico se o numero do recno foi informado
	If (_nRecno > 0 .And. (IsInCallStack("U_RCPGE003") .Or. IsInCallStack("U_RFUNE024")))

		// inicio o objeto de funcoes financeiras
		oVirtusFin := VirtusFin():New()

		// posiciono no registro do titulo
		DbSelectArea("SE1")
		SE1->(DbGoTo(_nRecno))

		// pego o saldo do titulo
		nRet := oVirtusFin:RetSaldoTitulo()

	EndIf

	RestArea(aArea)

Return(nRet)