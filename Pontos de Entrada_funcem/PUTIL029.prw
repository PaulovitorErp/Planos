#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PUTIL029
Ponto de Entrada do Cadastro de WACC.
@type function
@version 1.0
@author g.sampaio
@since 08/12/2021
/*/
User Function PUTIL029()


	Local aParam 				:= PARAMIXB
	Local oObj					:= aParam[1]
	Local cIdPonto				:= aParam[2]
	Local oModelUZD				:= oObj:GetModel("UZDMASTER")
	Local xRet 					:= .T.

	If cIdPonto == 'MODELPOS' .And. (oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4) //Confirmação da inclusão ou alteração

		// valido se existe o ano
		if ExisteAno(oModelUZD:GetValue("UZD_ANO"))
			xRet := .F.
			Help( ,, 'Help - MODELPOS',, 'Já existe cadastro para o ano informado, '+ oModelUZD:GetValue("UZD_ANO") +'.', 1, 0 )
		endIf

	endIf

Return(xRet)

/*/{Protheus.doc} ExisteAno
Verifico se existem dados para o ano cadastrado

@type function
@version 1.0
@author g.sampaio
@since 08/12/2021
@param cAno, character, ano de cadastro do WACC
@return logical, retorna se existe outro cadastro para o ano
/*/
Static Function ExisteAno(cAno)

	Local cQuery    := ""
	Local lRetorno  := .F.

	Default cAno    := ""

	if Select("TRBANO") > 0
		TRBANO->(DBCloseArea())
	endIf

	cQuery := " SELECT UZD.UZD_ANO ANO FROM " + RetSQLName("UZD") + " UZD "
	cQuery += " WHERE UZD.D_E_L_E_T_ = ' ' "
	cQuery += " AND UZD.UZD_ANO = '" + cAno + "'"

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TRBANO' )

	// caso tenha dados retorno verdadeiro
	if TRBANO->(!Eof())
		lRetorno := .T.
	endIf

	if Select("TRBANO") > 0
		TRBANO->(DBCloseArea())
	endIf

Return(lRetorno)
