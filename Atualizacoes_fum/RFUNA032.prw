#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} RFUNA032
Define qual rotina de reajuste de contrato sera utilizada
@type function
@version 1.0 
@author Raphael Martins
@since 08/05/2018
/*/
User Function RFUNA032()

Local aArea			:= GetArea()
Local aAreaUF2		:= UF2->(GetArea())
Local cTpReajuste	:= SuperGetMV("MV_XTPREAJ", .F., '1')
Local lRejMd2		:= SuperGetMV("MV_XREJMD2", .F., .F.)

//valido o tipo de reajuste de contratos, sendo 1= Reajuste por data de aniversario e 2 = Reajuste Global
if cTpReajuste == "1"
	If lRejMd2
		U_RFUNA055()
	Else
		U_RFUNA010()
	EndIf
else
	U_RFUNA031()
endif

RestArea(aArea)
RestArea(aAreaUF2)

Return(Nil)

