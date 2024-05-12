#include "totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} RCPGE039
rotina para validar existe locacao de nicho 
no momento da retirada de cinzas
@type function
@version 
@author g.sampaio
@since 02/07/2020
@param cContrato, character, param_description
@param cCrematorio, character, param_description
@param cNichoCremat, character, param_description
@return return_type, return_description
/*/
User Function RCPGE040( cContrato, cCrematorio, cNichoCremat )

	Local aArea             := GetArea()
	Local aAreaSE1          := SE1->(GetArea())
	Local aAreaU74          := U74->(GetArea())
	Local aAreaU75          := U75->(GetArea())
	Local lContinua         := .T.
	Local lRetorno          := .T.
	Local oVirtusFin        := Nil

	Default cContrato       := ""
	Default cCrematorio     := ""
	Default cNichoCremat    := ""

	if Select("TRBLOC") > 0
		TRBLOC->( DbCloseArea() )
	endIf

	// query para retornar a quantidade de parcelas para a locacao do nicho para o contrato
	cQuery := " SELECT U75.U75_PARCEL, U74.R_E_C_N_O_ RECU74, U75.R_E_C_N_O_ RECU75, SE1.R_E_C_N_O_ RECSE1 "
	cQuery += " FROM " + RetSQLName("U74") + " U74 "
	cQuery += " INNER JOIN " + RetSQLName("U75") + " U75 ON U75.D_E_L_E_T_ = ' ' "
	cQuery += " AND U75.U75_FILIAL	= '" + xFilial("SE1") + "'	"
	cQuery += " AND U75.U75_CODIGO = U74.U74_CODIGO "
	cQuery += " INNER JOIN " + RetSQLName("SE1") + " SE1 ON SE1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SE1.E1_FILIAL	    = '" + xFilial("SE1") + "'	"
	cQuery += " AND SE1.E1_PREFIXO  	= U75.U75_PREFIX "
	cQuery += " AND SE1.E1_NUM		    = U75.U75_NUM "
	cQuery += " AND SE1.E1_PARCELA	    = U75.U75_PARCEL "
	cQuery += " AND SE1.E1_TIPO		    = U75.U75_TIPO "
	cQuery += " WHERE U74.D_E_L_E_T_    = ' ' "
	cQuery += " AND U74.U74_CONTRA      = '"+ cContrato + "'"
	cQuery += " AND U74.U74_TPEND       = 'C'"
	cQuery += " AND U74.U74_CREMOS      = '"+ cCrematorio + "'"
	cQuery += " AND U74.U74_NICHO       = '"+ cNichoCremat + "'"
	cQuery += " AND U74.U74_STATUS      = '1'"
	cQuery += " ORDER BY U75.U75_PARCEL DESC"

	TcQuery cQuery New Alias "TRBLOC"

	// encontrei taxa de locacao
	if TRBLOC->(!Eof())

		// pergunta para o suario
		if MsgYesNo("Existe taxa de locação de nicho, deseja continuar com o processo de retirada de cinzas e encerrar a locação do Nicho? ")

			// crio o objeto da classe de funcoes financeiras do Virtus ERP
			oVirtusFin := VirtusFin():New()

			BEGIN TRANSACTION

				// pego o recno da U74
				nRecU74 := TRBLOC->RECU74

				// percorro os itens de locacao
				while TRBLOC->(!Eof())

					// posiciono no registro do financeiro
					SE1->( DbGoTo( TRBLOC->RECSE1 ) )

					// verifico se o saldo e maior que zero
					if lContinua .And. SE1->E1_SALDO > 0

						// marco como excessao
						lContinua := oVirtusFin:MarcaExcessaoSK1(SE1->(Recno()))

						if lContinua

							// faco a exclusao do titulo no bordero
							lContinua := oVirtusFin:ExcBordTit(SE1->(Recno()))

							// verifico se esta tudo certo
							if lContinua

								// excluo o titulo a receber
								lContinua := oVirtusFin:ExcluiTituloFin( SE1->(Recno()) )

								// verifico se esta tudo certo
								if lContinua

									// posiciono no historico de titulos
									U75->( DbGoTo( TRBLOC->RECU75 ) )

									if U75->( Reclock( "U75",.F. ) )
										U75->( DbDelete() )
										U75->(MsUnlock())
									else
										lContinua := .F.
										U75->(DisarmTranaction())
									endIf

								endIf

							endIf

						endIf

					endIf

					TRBLOC->(DbSkip())
				endDo

				if lContinua

					// posiciono no registro da U74
					U74->( DbGoTo(nRecU74) )

					if U74->( Reclock("U74",.F.) )
						U74->U74_STATUS := "2" // locação encerrada
						U74->(MsUnlock())
					else
						U74->(DisarmTranaction())
					endIf

				endIf

				lRetorno := lContinua

			END TRANSACTION

		else
			lRetorno    := .F. // caso o usuario nao queira continuar a operacao

		endIf

	endIf

	if Select("TRBLOC") > 0
		TRBLOC->( DbCloseArea() )
	endIf

	RestArea(aAreaU75)
	RestArea(aAreaU74)
	RestArea(aAreaSE1)
	RestArea(aArea)

Return(lRetorno)


/*/{Protheus.doc} VldCobranca
FUNCAO PARA VALIDAR SE O TITULO ESTA EM COBRANCA
@type function
@version 
@author g.sampaio
@since 29/06/2020
@param cFiltTit, character, param_description
@param cContrato, character, param_description
@return return_type, return_description
/*/
Static Function VldCobranca(cFiltTit,cContrato)

	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local aAreaSE1	:= SE1->( GetArea() )
	Local aAreaSK1	:= SK1->( GetArea() )
	Local cQry 		:= ""

	///////////////////////////////////////////////////////////////
	///// CONSULTO SE O CONTRATO POSSUI TITULOS EM COBRANCA	//////
	//////////////////////////////////////////////////////////////

	cQry 	:= " SELECT "
	cQry 	+= " K1_FILIAL FILIAL, "
	cQry 	+= " K1_PREFIXO PREFIXO, "
	cQry 	+= " K1_NUM NUMERO, "
	cQry 	+= " K1_PARCELA PARCELA, "
	cQry 	+= " K1_TIPO TIPO, "
	cQry 	+= " K1_FILORIG FILORIG "
	cQry	+= " FROM "
	cQry	+= + RetSQLName("SK1") + " COBRANCA
	cQry 	+= " INNER JOIN "
	cQry 	+= + RetSQLName("SE1") + " TITULO
	cQry 	+= " ON "
	cQry 	+= " COBRANCA.K1_PREFIXO = TITULO.E1_PREFIXO "
	cQry	+= " AND COBRANCA.K1_NUM 	= TITULO.E1_NUM "
	cQry	+= " AND COBRANCA.K1_PARCELA = TITULO.E1_PARCELA "
	cQry	+= " AND TITULO.E1_XCONTRA 	= '" + cContrato + "' "
	cQry	+= " AND TITULO.E1_FILIAL 	= '" + cFiltTit + "' "
	cQry	+= " AND TITULO.D_E_L_E_T_ 	= ' ' "
	cQry	+= " WHERE "
	cQry	+= "	COBRANCA.D_E_L_E_T_ = ' '"
	cQry	+= " 	AND COBRANCA.K1_FILORIG = '" + cFiltTit + "' "
	cQry 	+= " 	AND COBRANCA.K1_OPERAD	<> 'XXXXXX' " //XXXXXX Titulo marcado como excecao na cobranca

	If Select("QRYCOB") > 0
		QRYCOB->(DbCloseArea())
	Endif

	cQry := ChangeQuery(cQry)
	TcQuery cQry NEW Alias "QRYCOB"

	QRYCOB->( DbGotop() )

	//valido se possui cobranca para o contrato
	if QRYCOB->(!Eof())

		if MsgYesNo("O Contrato selecionado possui titulo(s) em cobrança.deseja continuar a operação? "+;
				Chr(13) + Chr(10) + " Os Titulos do contrato serão marcado como exceção no módulo de CallCenter.")

			SK1->(DbSetOrder(1)) //K1_FILIAL+K1_PREFIXO+K1_NUM+K1_PARCELA+K1_TIPO+K1_FILORIG

			While QRYCOB->(!Eof())

				//marco o titulo como excecao de cobranca, assim o mesmo estara apto para exclusao
				if SK1->(DbSeek(QRYCOB->FILIAL+QRYCOB->PREFIXO+QRYCOB->NUMERO+QRYCOB->PARCELA+QRYCOB->TIPO+QRYCOB->FILORIG))

					RecLock("SK1",.F.)
					SK1->K1_OPERAD := 'XXXXXX'
					SK1->(MsUnlock())

				endif

				QRYCOB->(DbSkip())

			EndDo

		else

			lRet := .F.

		endif

	endif

	RestArea(aArea)
	RestArea(aAreaSE1)
	RestArea(aAreaSK1)

Return( lRet )
