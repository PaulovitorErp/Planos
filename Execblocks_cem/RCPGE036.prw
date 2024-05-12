#include "totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} RCPGE036
funcao para retornar o valor atual da
parcela do contrato 
antiga funcao RetVlrAtu que estava no RCPGA001
@type function
@version 1.0
@author g.sampaio
@since 29/06/2020
@param nVlr, numeric, valor do contrato
@param cIndice, character, indice do contrato
@param dDtAtiv, date, data da ativacao
@return numeric, retorna o valor atualizado
/*/
User Function RCPGE036(nVlr, cIndice, dDtAtiv)

    Local aArea     := GetArea()
	Local cQry		:= ""
    Local nVlrAtual := 0	

    Default nVlr    := 0
    Default cIndice := ""
    Default dDtAtiv := stod("")

	If Select("QRYIND") > 0
		QRYIND->(DbCloseArea())
	Endif

	cQry := " SELECT SUM(U29.U29_INDICE) AS SOMA_IND"
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

		If QRYIND->SOMA_IND > 0

			nVlrAtual := nVlr + (nVlr * (QRYIND->SOMA_IND / 100))

		Endif

	Endif

    RestArea(aArea)

Return(nVlrAtual)
