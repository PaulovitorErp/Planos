#Include "PROTHEUS.CH"

/*/{Protheus.doc} CVTitulos
Classe CVTitulos
@type function
@version 1.0
@author nata.queiroz
@since 16/03/2020
/*/
User Function CVTitulos
Return

Class CVTitulos

    Data codVindi as character
    Data cgc as character
    Data cliente as character
    Data prefixo as character
    Data tipo as character
    Data titulo as character
    Data parcela as character
    Data valor as numeric
    Data saldo as numeric
    Data emissao as date
    Data vencto as date
    Data baixa as date

    Method New(codVindi) Constructor

EndClass

Method New(codVindi) Class CVTitulos

    ::codVindi := codVindi
    ::cgc := ""
    ::cliente := ""
    ::prefixo := ""
    ::tipo := ""
    ::titulo := ""
    ::parcela := ""
    ::valor := 0
    ::saldo := 0
    ::emissao := STOD(Space(8))
    ::vencto := STOD(Space(8))
    ::baixa := STOD(Space(8))

Return Self