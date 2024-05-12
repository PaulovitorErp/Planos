#include "totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} PCPGA026
Pontos de Entrada do Cadastro Motivos de Cancelamento
@author TOTVS
@since 29/07/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function PCPGA026()
/***********************/

	Local aParam 		:= PARAMIXB
	Local oObj			:= aParam[1]
	Local cIdPonto		:= aParam[2]
	Local oModelU31		:= oObj:GetModel("U31MASTER")

	Local xRet 			:= .T.

	If cIdPonto == 'MODELPOS' .And. oObj:GetOperation() == 5 //Confirmação da exclusão

		// valido se o codigo do cancelamento esta vinculado a algum contrato
		If ExistU31()

			xRet := .F.
			Help( ,, 'Help - MODELPOS',, 'Não é permitido a exclusão deste motivo de cancelamento, pois o mesmo se encontra associado a contrato(s). Para concluir a exclusão, favor excluir os contratos relacionados.', 1, 0 )

		Endif

	Endif

Return xRet

/*/{Protheus.doc} ExistU31
funcao para validar se existe codigo de cancelemnto
ja utilizado no contratos de cemiterio ou funceraria
@type function
@version 
@author g.sampaio
@since 26/03/2020
@return return_type, return_description
/*/
/*************************/
Static Function ExistU31()
/*************************/

	Local aArea			:= GetArea()
	Local cQuery		:= ""
	Local lUsaFuneraria	:= SuperGetMv("MV_XFUNE",.F.,.F.)
	Local lUsaCemiterio	:= SuperGetMv("MV_XCEMI",.F.,.F.)
	Local lRet 			:= .F.

	// verifico se o alias esta em uso
	If Select("TRBCAN") > 0
		TRBCAN->( DbCloseArea() ) // fecho o alias
	EndIf

	// verifico se o uso o modulo de cemiterio
	If lUsaCemiterio

		// query para contrato no modulo de cemiterio
		cQuery := " SELECT "
		cQuery += " 'CEM' MODULO, "
		cQuery += "	U00.U00_CODIGO CONTRATO,"
		cQuery += "	U00.U00_CODCAN CODCAN,"
		cQuery += "	U00.R_E_C_N_O_ RECCTR"
		cQuery += " FROM "+ RetSqlName("U00") +" U00"
		cQuery += " WHERE U00.D_E_L_E_T_ = ' '"
		cQuery += " AND U00.U00_FILIAL = '"+xFilial("U00")+"'"
		cQuery += " AND U00.U00_STATUS = 'C'"
		cQuery += " AND U00.U00_CODCAN = '" + U31->U31_CODIGO + "' "

	EndIf

	// verifico o uso do modulo de funeraria
	If lUsaFuneraria

		// verifico se a variavel de query ja esta preenchida, para fazer o union
		If !Empty(cQuery)
			cQuery += " UNION ALL"
		EndIf

		// query para contrato no modulo de funeraria
		cQuery += " SELECT "
		cQuery += "	'FUN' MODULO,"
		cQuery += "	UF2.UF2_CODIGO CONTRATO,"
		cQuery += "	UF2.UF2_CODCAN CODCAN,"
		cQuery += "	UF2.R_E_C_N_O_ RECCTR"
		cQuery += " FROM "+ RetSqlName("UF2") +" UF2"
		cQuery += " WHERE UF2.D_E_L_E_T_ = ' '"
		cQuery += " AND UF2.UF2_FILIAL = '"+xFilial("UF2")+"'"
		cQuery += " AND UF2.UF2_STATUS = 'C'"
		cQuery += " AND UF2.UF2_CODCAN = '" + U31->U31_CODIGO + "' "

	EndIf
	
	// verifico se a variavel de query ja esta preenchida, para fazer o order by
	If !Empty(cQuery)
		cQuery += " ORDER BY CONTRATO "
	EndIf

	TcQuery cQuery New Alias "TRBCAN"

	// verifico se existem registros para o codigo de cancelamento
	If TRBCAN->(!Eof())
		lRet := .T.
	EndIf

	// verifico se o alias esta em uso
	If Select("TRBCAN") > 0
		TRBCAN->( DbCloseArea() ) // fecho o alias
	EndIf

	RestArea( aArea )

Return(lRet)