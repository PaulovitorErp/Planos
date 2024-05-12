#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} RCPGE030
Funcao gerar o historico e parcelas no financeiro
@type function
@version 
@author g.sampaio
@since 04/03/2020
@param cTrbContrato, character, param_description
@param cTrbParcelas, character, param_description
@return return_type, return_description
/*/
User Function RCPGE030( cTrbContrato, cTrbParcelas, cLog, oTempContrato, oTempParcelas, oProcess )

	Local aArea             := GetArea()
	Local aAreaSE1          := {}
	Local aHistorico        := {}
	Local aDados            := {}
	Local aParam            := {}
	Local cMesAno           := ""
	Local cXParCon          := ""
	Local cCodigo           := ""
	Local cStatusLoc        := ""
	Local cParcela          := ""
	Local dDtVencto         := Stod("")
	Local lJob              := IsBlind()
	Local lMsErroAuto       := .F.
	Local lRetorno          := .T.
	Local nTipo             := 0
	Local nCount            := 0
	Local nParcQuantidade   := SuperGetMV("MV_XPARLOC",,12)    // quantidade de parcelas

	Default cTrbContrato  := ""
	Default cTrbParcelas  := ""
	Default cLog          := ""

	// verifico se estou em job
	If lJob

		// vou criar o banco de dados
		U_RCPGE029( cTrbContrato, cTrbParcelas, aParam, cLog, @oTempContrato, @oTempParcelas  )

	EndIf

	// verifico se os alias tem dados
	If Select( cTrbContrato ) > 0 .And. Select( cTrbParcelas ) > 0

		// salvo a area de trabalho da SE1
		aAreaSE1    := SE1->( GetArea() )

		If Select("TMPCTR") > 0
			TMPCTR->( DbCloseArea() )
		EndIf

		// query para pegar os registros marcados
		cQuery := " SELECT * FROM " + oTempContrato:GetRealName() + " TMP "
		cQuery += " WHERE TMP.D_E_L_E_T_ = ' '   "
		cQuery += " AND TMP.TR_MARK = 'T' "

		// executo a query e crio o alias temporario
		MPSysOpenQuery( cQuery, 'TMPCTR' )

		// caso o alias for diferente de fial de arquivo
		If TMPCTR->(!Eof())

			// verifico se a variavel oBrowseTipo e objeto
			If ValType( oProcess ) == "O"

				// pego a quantidade de registros
				nCount := TMPCTR->(RECCOUNT())

				// atualizo o objeto de processamentp
				oProcess:SetRegua1(nCount)

			EndIf

			// posicione no primeiro registro
			TMPCTR->( DbGoTop() )

			While TMPCTR->(!Eof()) .And. lRetorno

				BEGIN TRANSACTION

					// limpo as variaveis
					cStatusLoc  := ""
					cCodigo     := ""
					cParcela    := ""

					// pego o status da locacao
					cStatusLoc := SubStr(TMPCTR->TR_STATUS,1,1)

					// para nova locacao
					if cStatusLoc == "N"

						cCodigo := GetSXENum("U74","U74_CODIGO")    // gero um novo codigo

					elseif cStatusLoc == "R"    // para reajuste

						cCodigo := TMPCTR->TR_CODIGO                // pego o codigo ja existente

					endIf

					// reinicio o conteudo da variavel
					aHistorico := {}

					// verifico se a variavel oBrowseTipo e objeto
					If ValType( oProcess ) == "O"

						// atualizo o objeto de processamento
						oProcess:IncRegua1("Contrato:" + TMPCTR->TR_CONTRAT )

					EndIf

					//------------------------------------
					//Executa query para leitura da tabela
					//------------------------------------
					If Select("TMPPAR") > 0
						TMPPAR->( DbCloseArea() )
					EndIf

					// query no alias temporario
					cQuery := " SELECT * FROM " + oTempParcelas:GetRealName() + " TMP "
					cQuery += " WHERE TMP.D_E_L_E_T_ = ' '   "
					cQuery += " AND TMP.TMP_CODIGO = '" + TMPCTR->TR_CODIGO + "'"

					// executo a query e crio o alias temporario
					MPSysOpenQuery( cQuery, 'TMPPAR' )

					// percorro o registros vinculados ao codigo do historico
					While TMPPAR->(!Eof()) .And. lRetorno

						// verifico se a variavel oBrowseTipo e objeto
						If ValType( oProcess ) == "O"

							// atualizo o objeto de processamento
							oProcess:IncRegua2("Parcela:" + TMPPAR->TMP_PARCEL + " / " + StrZero(nParcQuantidade,TamSX3("E1_PARCELA")[1]) )

						EndIf

						// pego o numero da parcela
						ParcTaxa( @cParcela, TMPCTR->TR_CONTRAT, TMPPAR->TMP_PREF, cCodigo, TMPPAR->TMP_TIPO )

						aDados 		:= {}
						lMsErroAuto	:= .F.
						dDtVencto   := Stod(TMPPAR->TMP_VENCTO)
						cMesAno 	:= SubStr(DTOC(dDtVencto),4,7)
						cXParCon    := TMPPAR->TMP_PARCEL + "/" + StrZero(nParcQuantidade,TamSX3("E1_PARCELA")[1])

						Aadd( aDados, {"E1_FILIAL"	, xFilial("SE1")			, Nil } )
						Aadd( aDados, {"E1_PREFIXO"	, TMPPAR->TMP_PREF   		, Nil } )
						Aadd( aDados, {"E1_NUM"		, cCodigo              		, Nil } )
						Aadd( aDados, {"E1_PARCELA"	, cParcela              	, Nil } )
						Aadd( aDados, {"E1_TIPO"	, TMPPAR->TMP_TIPO			, Nil } )
						Aadd( aDados, {"E1_NATUREZ"	, TMPPAR->TMP_NATURE		, Nil } )
						Aadd( aDados, {"E1_CLIENTE"	, TMPCTR->TR_CODCLI			, Nil } )
						Aadd( aDados, {"E1_LOJA"	, TMPCTR->TR_LOJCLI			, Nil } )
						Aadd( aDados, {"E1_EMISSAO"	, dDataBase					, Nil } )
						Aadd( aDados, {"E1_VENCTO"	, dDtVencto			        , Nil } )
						Aadd( aDados, {"E1_VENCREA"	, DataValida(dDtVencto)	    , Nil } )
						Aadd( aDados, {"E1_VALOR"	, TMPPAR->TMP_VALOR			, Nil } )
						Aadd( aDados, {"E1_HIST"	, "LOCACAO DE NICHO"		, Nil } )
						Aadd( aDados, {"E1_XCONTRA"	, TMPCTR->TR_CONTRAT    	, Nil } )
						Aadd( aDados, {"E1_XPARCON"	, cXParCon					, Nil } )

						SE1->( MSExecAuto({|x,y| FINA040(x,y)}, aDados, 3) )

						// erro de execauto
						if lMsErroAuto

							cLog  += MostraErro("/temp")

							SE1->( DisarmTransaction() )

							lRetorno     := .F.

						else

							// array de historico de manutenção
							Aadd(aHistorico,{ TMPPAR->TMP_PREF, cCodigo, cParcela, TMPPAR->TMP_TIPO, TMPPAR->TMP_VALOR, dDtVencto })

							lRetorno := .T.

						endif

						TMPPAR->(DbSkip())
					EndDo

					If Select("TMPPAR") > 0
						TMPPAR->( DbCloseArea() )
					EndIf

					// verifico se esta tudo certo
					If lRetorno

						// gravo o historico da rotina de taxa
						lRetorno := GravaHistorico( cStatusLoc, cCodigo, TMPCTR->TR_CONTRAT, TMPCTR->TR_TIPOEND, TMPCTR->TR_CREMOS, TMPCTR->TR_NICHO,;
							TMPCTR->TR_INDIC, TMPCTR->TR_TXLOCN, TMPCTR->TR_TXINDI, TMPCTR->TR_VLADIC, aHistorico, nParcQuantidade, @cLog )
					EndIf

					If !lRetorno
						DisarmTransaction()
                        BREAK
					EndIf

				END TRANSACTION

				TMPCTR->(DbSkip())
			EndDo

		EndIf

		// restauro a area de trabalho da SE1
		RestArea( aAreaSE1 )

	EndIf

	// verifico se estou executando o job
	If lJob

		// verifico se o objeto do alias temproario de contratos no banco
		If ValType( oTempContrato ) == "O"
			oTempContrato:Delete()
		EndIf

		// verifico se o objeto do alias temproario de parcelas no banco
		If ValType( oTempParcelas ) == "O"
			oTempParcelas:Delete()
		EndIf

	EndIf

	RestArea( aArea )

Return( lRetorno )

/*/{Protheus.doc} GravaHistorico
Função que grava o histórico da 
@type function
@version 
@author g.sampaio
@since 04/03/2020
@param cContrato, character, codigo do contrato
@param cTipoEnd, character, tipo de enderco
@param cCremOssuario, character, tipo do endereco
@param cNicho, character, codigo do nicho
@param cIndice, character, codigo do indice
@param aHistorico, array, array de dados do historico
@return logico, retorno se gravou o historico corretamente
/*/
Static Function GravaHistorico( cStatusLoc, cCodigo, cContrato, cTipoEnd, cCremOssuario, cNicho, cIndice, nTaxaLoc, nTxIndic, nVlAdic, aDados, nParcQuantidade, cLog )

	Local nX			    := 1
	Local nOper             := 0
	Local nAdic             := 0
	Local lRet     		    := .T.
	Local cItem 		    := PADL("1",TamSX3("U75_ITEM")[1],"0")

	Default cStatusLoc      := ""
	Default cCodigo         := ""
	Default cContrato       := ""
	Default cTipoEnd        := ""
	Default cCremOssuario   := ""
	Default cNicho          := ""
	Default cIndice         := ""
	Default nTaxaLoc        := 0
	Default aDados          := {}
	Default nParcQuantidade := 0
	Default cLog            := ""

	// codigo da taxa de locacao
	if cStatusLoc == "R"

		U74->(DbSetOrder(1))
		if U74->( MsSeek( xFilial("U74")+cCodigo ) )

			nAdic       := nVlAdic + U74->U74_VLADIC

		endIf

		// alteracao
		nOper   := 4

	elseif cStatusLoc == "N"

		// inclusao
		nOper   := 3

	endIf

	// proximo manutencao
	cProManut := StrTran( SubStr(DTOC( MonthSum(dDataBase, nParcQuantidade) ),4,7), "/", "" )

	// verifico se existem dados para gerar o historico
	if len(aDados) > 0

		// para inclusao
		if nOper == 3

			// crio um novo registro na U74
			U74->( Reclock("U74",.T.) )
			U74->U74_FILIAL := xFilial("U74")
			U74->U74_CODIGO := cCodigo
			U74->U74_DATA   := dDataBase
			U74->U74_INDICE := cIndice
			U74->U74_TAXA   := nTaxaLoc
			U74->U74_CONTRA := cContrato
			U74->U74_TPEND  := SubStr(AllTrim(cTipoEnd),1,1)
			U74->U74_CREMOS := AllTrim(cCremOssuario)
			U74->U74_NICHO  := AllTrim(cNicho)
			U74->U74_STATUS := "1"

		elseIf nOper == 4

			// altero um registro na U74
			U74->( Reclock("U74",.F.) )
			U74->U74_VLADIC := nAdic

		endIf

		U74->U74_PROMAN := cProManut

		U74->(MsUnlock())

	endIf

	// pego o proximo item
	ProxItem(cCodigo, @cItem)

	// percorro os dados do historico
	For nX := 1 To Len(aDados)

		U75->(Reclock("U75",.T.))
		U75->U75_FILIAL := xFilial("U75")
		U75->U75_CODIGO := cCodigo
		U75->U75_ITEM   := cItem
		U75->U75_PREFIX := aDados[nX,1]
		U75->U75_NUM    := aDados[nX,2]
		U75->U75_PARCEL := aDados[nX,3]
		U75->U75_TIPO   := aDados[nX,4]
		U75->U75_VALOR  := aDados[nX,5]
		U75->U75_VENCTO := aDados[nX,6]

		U75->( MsUnlock() )

		// incremento o item
		cItem := SOMA1(cItem)

	Next nX


	// gravo o reajuste
	if nOper == 4

		// grava o registro de reajuste
		GravaReajuste( cContrato, cCodigo, cIndice, cProManut, nTxIndic, nVlAdic )

	elseif nOper == 3

		// confirmo o codigo gerado
		U74->( ConfirmSX8() )

	endIf

Return(lRet)

/*/{Protheus.doc} GravaReajuste
gravo o historico de reajuste
@type function
@version 
@author g.sampaio
@since 02/07/2020
@param cContrato, character, param_description
@param cCodigo, character, param_description
@param cIndice, character, param_description
@param cProManut, character, param_description
@param nTxIndic, numeric, param_description
@param nVlAdic, numeric, param_description
@return return_type, return_description
/*/
Static Function GravaReajuste( cContrato, cCodigo, cIndice, cProManut, nTxIndic, nVlAdic )

	Local aArea     := GetArea()
	Local aAreaU78  := U78->( GetArea() )
	Local cCodReaj  := ""

	// gero o codigo do reajuste
	cCodReaj    := GetSXENum("U78","U78_CODIGO")

	// gravo o historico de reajuste
	if U78->( Reclock("U78",.T.) )
		U78->U78_FILIAL := xFilial("U78")
		U78->U78_CODIGO := cCodReaj
		U78->U78_DATA   := dDataBase
		U78->U78_CODLOC := cCodigo
		U78->U78_CONTRA := cContrato
		U78->U78_TPINDI := cIndice
		U78->U78_INDICE := nTxIndic
		U78->U78_VLADIC := nVlAdic
		U78->U78_PROREA := cProManut
		U78->(MsUnlock())
	else
		U78->(DisarmTransaction())
	endIf

	RestArea( aAreaU78 )
	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} ProxItem
description
@type function
@version 
@author g.sampaio
@since 03/07/2020
@param cCodigo, character, param_description
@param @cItem, param_type, param_description
@return return_type, return_description
/*/
Static Function ProxItem(cCodigo, cItem)

	Local aArea     := GetArea()
	Local aAreaU75  := U75->(GetArea())
	Local cQuery    := ""

	Default cCodigo := ""
	Default cITem   := ""

	if Select("TRBU75") > 0
		TRBU75->( DbCloseArea() )
	endIf

	// query para buscar o ultimo item
	cQuery := " SELECT MAX(U75.U75_ITEM) MAXITEM FROM " + RetSqlName("U75") + " U75 "
	cQuery += " WHERE U75.D_E_L_E_T_ = ' '"
	cQuery += " AND U75.U75_FILIAL = '" + xFilial("U75") + "' "
	cQuery += " AND U75.U75_CODIGO = '" + cCodigo + "' "

	TcQuery cQuery New Alias "TRBU75"

	if TRBU75->(!Eof())
		cItem   := Soma1(TRBU75->MAXITEM)
	endIf

	if Select("TRBU75") > 0
		TRBU75->( DbCloseArea() )
	endIf

	RestArea(aAreaU75)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} ParcTaxa
description
@type function
@version 
@author g.sampaio
@since 03/03/2020
@param cParcela, character, param_description
@param cPrefLoc, character, param_description
@param cContrato, param_type, param_description
@param cTipoLoc, character, param_description
@return return_type, return_description
/*/
Static Function ParcTaxa( cParcela, cCodContrato, cPrefLoc, cCodLocacao, cTipoLoc, aDadosParc )

	Local aArea             := GetArea()
	Local aAreaU75          := U75->( GetArea() )
	Local cQuery            := ""

	Default cParcela        := ""
	Default cCodContrato    := ""
	Default cPrefLoc        := ""
	Default cCodLocacao     := ""
	Default cTipoLoc        := ""
	Default aDadosParc      := {}

	// verifico se o codigo ja esta preenchido
	If !Empty(cParcela)

		// incremento o codigo do historico de taxa
		cParcela   := Soma1(AllTrim(cParcela))

	Else// caso nao estiver preenchido

		// encerro o alias se estiver em uso
		If Select("TRBPAR") > 0
			TRBPAR->( DbCloseArea() )
		EndIf

		// query de consulta
		cQuery := " SELECT MAX(U75.U75_PARCEL) MAXPARC FROM " + RetSQLName("U74") + " U74 "
		cQuery += " INNER JOIN " + RetSQLName("U75") + " U75 ON U75.D_E_L_E_T_ = ' ' "
		cQuery += " AND U75.U75_FILIAL	= '" + xFilial("SE1") + "'	"
		cQuery += " AND U75.U75_CODIGO = U74.U74_CODIGO "
		cquery += " AND U75.U75_PREFIX  = '" + cPrefLoc     + "' "
		cQuery += " AND U75.U75_NUM     = '" + cCodLocacao  + "' "
		cQuery += " AND U75.U75_TIPO    = '" + cTipoLoc     + "' "
		cQuery += " INNER JOIN " + RetSQLName("SE1") + " SE1 ON SE1.D_E_L_E_T_ = ' ' "
		cQuery += " AND SE1.E1_FILIAL	= '" + xFilial("SE1") + "'	"
		cQuery += " AND SE1.E1_PREFIXO	= U75.U75_PREFIX "
		cQuery += " AND SE1.E1_NUM		= U75.U75_NUM "
		cQuery += " AND SE1.E1_PARCELA	= U75.U75_PARCEL "
		cQuery += " AND SE1.E1_TIPO		= U75.U75_TIPO "
		cQuery += " WHERE U74.D_E_L_E_T_ = ' ' "
		cQuery += " AND U74.U74_CODIGO = '" + cCodLocacao + "'"

		TcQuery cQuery New Alias "TRBPAR"

		If TRBPAR->(!Eof())
			cParcela    := Soma1(AllTRim(TRBPAR->MAXPARC)) // incremento com o maior codigo de
		EndIf

		// verifico se a parcela foi preenchida
		If Empty(AllTrim(cParcela))
			cParcela    := StrZero( 1, TamSX3("E1_PARCELA")[1] )
		EndIf

		// encerro o alias se estiver em uso
		If Select("TRBPAR") > 0
			TRBPAR->( DbCloseArea() )
		EndIf

	EndIf

	RestArea( aAreaU75 )
	RestArea( aArea )

Return(Nil)
