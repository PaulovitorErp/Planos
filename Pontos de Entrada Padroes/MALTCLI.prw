#include 'totvs.ch'

/*/{Protheus.doc} MALTCLI
Executado após a gravação das alterações.
@type function
@version 1.0 
@author TOTVS
@since 29/06/2016
/*/
User Function MALTCLI()

	Local aArea					:= GetArea()
	Local lFuneraria			:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio			:= SuperGetMV("MV_XCEMI",,.F.)

	If lCemiterio

		//altero os dados do contrato do cliente
		If ExistBlock("RCPGE007")
			U_RCPGE007(SA1->A1_COD,SA1->A1_LOJA)
		EndIf

	elseif lFuneraria

		//altero os dados do contrato do cliente
		If ExistBlock("RFUNE034")
			U_RFUNE034(SA1->A1_COD,SA1->A1_LOJA)
		EndIf

	Endif

	RestArea(aArea)

Return(Nil)
