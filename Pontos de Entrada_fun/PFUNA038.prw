#include "protheus.ch"
#include "topconn.ch"
#include "FWMVCDef.ch"

/*/{Protheus.doc} PFUNA038
Pontos de Entrada de Regras de Contrato
@author TOTVS
@since 11/03/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function PFUNA038()
/***********************/
	
Local aArea			:= GetArea()
Local aAreaUJ5		:= UJ5->(GetArea())
Local aAreaUJ6		:= UJ6->(GetArea())
Local aAreaUJ7		:= UJ7->(GetArea())
Local aAreaUJ8		:= UJ8->(GetArea())
Local aParam 		:= PARAMIXB
Local oObj			:= aParam[1]
Local cIdPonto		:= aParam[2]
Local oModelUJ5		:= oObj:GetModel("UJ5MASTER")
Local oModelUJ6		:= oObj:GetModel("UJ6DETAIL")
Local oModelUJ7		:= oObj:GetModel("UJ7DETAIL")
Local oModelUJ8		:= oObj:GetModel("UJ8DETAIL")
Local xRet 			:= .T.

Local nI

If cIdPonto == 'MODELPOS' .And. (oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4) //Confirmação da Inclusão ou Alteração

	//Validação preenchimento campo "Prazo em", caso o campo "Tp prescricao" seja informado
	If !Empty(oModelUJ5:GetValue("UJ5_TPPRES")) .And. Empty(oModelUJ5:GetValue("UJ5_PRAZO")) 
		Help( ,, 'Help - MODELPOS',, 'Caso o tipo de prescricao seja selecionado, obrigatoriamente o campo Prazo deve ser informado.', 1, 0 )
		xRet := .F.
	Endif

ElseIf cIdPonto == 'MODELPOS' .And. oObj:GetOperation() == 5 //Confirmação da Exclusão

	If PossuiPl(oModelUJ5:GetValue("UJ5_CODIGO"))
		Help( ,, 'Help - MODELPOS',, 'Nao e possivel excluir a Regra de Contrato, pois ha Plano(s) relacionado(s).', 1, 0 )
		xRet := .F.
	Endif

	If xRet

		If PossuiCtr(oModelUJ5:GetValue("UJ5_CODIGO"))
			Help( ,, 'Help - MODELPOS',, 'Nao e possivel excluir a Regra de Contrato, pois ha Contrato(s) relacionado(s).', 1, 0 )
			xRet := .F.
		Endif
	Endif
Endif

RestArea(aAreaUJ5)
RestArea(aAreaUJ6)
RestArea(aAreaUJ7)
RestArea(aAreaUJ8)
RestArea(aArea)

Return xRet

/*******************************/
Static Function PossuiPl(cRegra)
/*******************************/

Local lRet 	:= .F.
Local cQry	:= ""

If Select("QRYUF0") > 0
	QRYUF0->(DbCloseArea())
Endif

cQry := "SELECT UF0_REGRA"
cQry += " FROM "+RetSqlName("UF0")+""
cQry += " WHERE D_E_L_E_T_ 	<> '*'"
cQry += " AND UF0_FILIAL 	= '"+xFilial("UF0")+"'"
cQry += " AND UF0_REGRA		= '"+cRegra+"'"

cQry := ChangeQuery(cQry)
TcQuery cQry NEW Alias "QRYUF0"

If QRYUF0->(!EOF())
	lRet := .T.
Endif

If Select("QRYUF0") > 0
	QRYUF0->(DbCloseArea())
Endif

Return lRet

/********************************/
Static Function PossuiCtr(cRegra)
/********************************/

Local lRet 	:= .F.
Local cQry	:= ""

If Select("QRYUF2") > 0
	QRYUF2->(DbCloseArea())
Endif

cQry := "SELECT UF2_REGRA"
cQry += " FROM "+RetSqlName("UF2")+""
cQry += " WHERE D_E_L_E_T_ 	<> '*'"
cQry += " AND UF2_FILIAL 	= '"+xFilial("UF2")+"'"
cQry += " AND UF2_REGRA		= '"+cRegra+"'"

cQry := ChangeQuery(cQry)
TcQuery cQry NEW Alias "QRYUF2"

If QRYUF2->(!EOF())
	lRet := .T.
Endif

If Select("QRYUF2") > 0
	QRYUF2->(DbCloseArea())
Endif

Return lRet