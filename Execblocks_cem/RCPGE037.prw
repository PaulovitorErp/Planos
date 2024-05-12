#include "totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} RCPGE037
Funcao para validar o indice
antiga funcao PossuiInd que estava no RCPGA001
@type function
@version 
@author g.sampaio
@since 29/06/2020
@param dDtAtiv, date, param_description
@param cIndice, character, param_description
@return return_type, return_description
/*/
User Function RCPGE037(dDtAtiv,cIndice)

    Local aArea     := GetArea()
    Local cQry		:= ""
	Local lRet 		:= .T.
	Local nIndices	:= DateDiffMonth(dDtAtiv,dDataBase)	

	If Select("QRYIND") > 0
		QRYIND->(DbCloseArea())
	Endif

	cQry := " SELECT COUNT(U29.U29_INDICE) AS QTD_IND"
	cQry += " FROM "+RetSqlName("U22")+" U22 INNER JOIN "+RetSqlName("U28")+" U28 INNER JOIN "+RetSqlName("U29")+" U29"
	cQry += "    ON ("
	cQry += "        U29.D_E_L_E_T_ <> '*'"
	cQry += "        AND U28.U28_CODIGO = U29.U29_CODIGO "
	cQry += "        AND U28.U28_ITEM = U29.U29_IDANO "
	cQry += " 		 AND U29.U29_FILIAL = '"+xFilial("U29")+"'"
	cQry += "    )"
	cQry += " ON ("
	cQry += "    U28.D_E_L_E_T_ <> '*'"
	cQry += "    AND U22.U22_CODIGO = U28.U28_CODIGO"
	cQry += " 	 AND U28.U28_FILIAL = '"+xFilial("U28")+"'"
	cQry += "    ) "
	cQry += " WHERE "
	cQry += " U22.D_E_L_E_T_ <> '*'"
	cQry += " AND U22.U22_FILIAL = '"+xFilial("U22")+"'"
	cQry += " AND U22.U22_STATUS = 'A'"

	If !Empty(cIndice)
		cQry += " AND U22.U22_CODIGO = '"+cIndice+"'"
	Endif

	cQry += " AND U28.U28_ANO + U29.U29_MES"
	cQry += " BETWEEN '"+AnoMes(dDtAtiv)+"' AND '"+AnoMes(dDataBase)+"'"

	cQry := ChangeQuery(cQry)
	TcQuery cQry New Alias "QRYIND"

	If QRYIND->(!EOF())

		If nIndices + 1 <> QRYIND->QTD_IND
			lRet := .F.
		Endif
	Else
		lRet := .F.
	Endif

	If Select("QRYIND") > 0
		QRYIND->(DbCloseArea())
	EndIf

    RestArea(aArea)

Return(lRet)