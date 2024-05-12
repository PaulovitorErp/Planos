#include "totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} RCPGE039
Fun��o que faz a exclus�o das taxas de manuten��o em lote
antiga funcao ExcluiTxLocacao que estava na program RCPGA043 
@type function
@version 
@author g.sampaio
@since 02/03/2020
@param dDataDe, date, data de emissao do inicio do filtro 
@param dDataAte, date, data de emissao do fim do filtro 
@param cContratoDe, character, contrato do inicio do filtro 
@param cContratoAte, character, contrato do fim do filtro 
@param cPlano, character, plano a ser filtrado
@param cIndice, character, indice a ser filtrado
@return logico, retorno verdade ou falso da funcao
/*/
User Function RCPGE039(dDataDe,dDataAte,cContratoDe,cContratoAte,cPlano,cIndice)

	Local aArea			    := GetArea()
	Local cQry 		   	    := ""
	Local cPulaLinha	    := chr(13)+chr(10)
	Local oModel 		    := FWLoadModel("RCPGA042")
	Local lOK			    := .T.

    Default dDataDe         := Stod("")
    Default dDataAte        := Stod("")
    Default cContratoDe     := ""
    Default cContratoAte    := ""
    Default cPlano          := ""
    Default cIndice         := ""

	// verifico se n�o existe este alias criado
	If Select("TRBEXC") > 0
		TRBEXC->(DbCloseArea())
	EndIf

	// query de consulta de dados
	cQry := " SELECT "                                                         					
	cQry += " U74.U74_CODIGO, "                                                				
	cQry += " U74.U74_DATA, "                                                  					
	cQry += " U74.U74_CONTRA "                                                 				
	cQry += " FROM "                                                           				
	cQry += + RetSqlName("U74") + " U74 "                                      				
	cQry += " INNER JOIN "                                                     				
	cQry += 	+ RetSqlName("U00") + " U00 "                                  				
	cQry += " 	ON U00.D_E_L_E_T_ <> '*' "                                     				
	cQry += " 	AND U00.U00_FILIAL = '" + xFilial("U00") + "' "                				
	cQry += " 	AND U00.U00_CODIGO = U74.U74_CONTRA "                          				

	if !Empty(cPlano)
		cQry += " 	AND U00.U00_PLANO IN " + FormatIn( AllTrim(cPlano),";") 		 		
	endif

	cQry += " AND U00.U00_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' " 
	cQry += " WHERE "                                                          				
	cQry += " U74.D_E_L_E_T_ <> '*' "                                          				
	cQry += " AND U74.U74_FILIAL = '" + xFilial("U74") + "' "                               
	cQry += " AND U74.U74_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "

	if !Empty(cIndice)
		cQry += " AND U74.U74_TPINDI = '" + cIndice + "' "                         			
	endif

	// fun��o que converte a query gen�rica para o protheus
	cQry := ChangeQuery(cQry)

	// crio o alias temporario
	TcQuery cQry New Alias "TRBEXC" // Cria uma nova area com o resultado do query

	// se existir contratos a serem reajustados
	if TRBEXC->(!Eof())

		// Inicio o controle de transa��o
		BEGIN TRANSACTION

		While TRBEXC->(!Eof())

			U74->(DbSetOrder(1)) // U74_FILIAL + U74_CODIGO
			if U74->(DbSeek(xFilial("U74") + TRBEXC->U74_CODIGO))

				lActivate 	:= .F.
				lCommit		:= .F.

				// seto a opera��o de exclus�o
				oModel:SetOperation(5)

				// ativo o modelo
				lActivate := oModel:Activate()

				// se o modelo foi ativado com sucesso
				if lActivate

					// comito a opera��o
					lCommit := oModel:CommitData()

					// desativo o modelo
					oModel:DeActivate()

				else

					if !MsgYesNo("Ocorreu um erro na exclus�o da taxa de loca��o de nicho do contrato " + AllTrim(U74->U74_CONTRA) + "." + cPulaLinha + "Deseja continuar?","Aten��o!")

						// aborto a transa��o
						DisarmTransaction()

						lOK := .F.
						Exit

					endif

				endif

			endif

			TRBEXC->(DbSkip())

		EndDo

		END TRANSACTION

	else

		MsgAlert("N�o foram encontradas taxas de manuten��o para o filtro informado!")

	endif

	// verifico se n�o existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(lOK)
