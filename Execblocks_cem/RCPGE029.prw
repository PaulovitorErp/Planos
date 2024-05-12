#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} RCPGE029
funcao para gerar os dados da taxa de locacao de nicho
@type function
@version 
@author g.sampaio
@since 03/03/2020
@param cTrbContrato, character, param_description
@param cTrbParcelas, character, param_description
@param cDeContrato, character, param_description
@param cAteContrato, character, param_description
@param cPlanos, character, param_description
@param cIndice, character, param_description
@param nTipo, numeric, param_description
@param cLog, character, param_description
@param oBrowseContrato, object, param_description
@param oBrowseParcelas, object, param_description
@param oProcess, object, param_description
@param lEnd, logical, param_description
@return return_type, return_description
@history 22/07/2020, g.sampaio, VPDV-209 - retirado o uso da funcao DataValida, na exibição da previa das parcelas.
/*/
User function RCPGE029( cTrbContrato, cTrbParcelas, aParam, cLog,;
		oTempContrato, oTempParcelas, oBrowseContrato, oBrowseParcelas, oProcess, lEnd, nTotLocacao, nTotReaj )

	Local aAuxCtr           := {}
	Local aAuxParc          := {}
	Local aDadosCtr         := {}
	Local aDadosParc        := {}
	Local cQuery            := ""
	Local cAnoMes           := ""
	Local cDiaVenc          := ""
	Local cDtAux            := ""
	Local cCodHist          := ""
	Local cParcela          := ""
	Local cTipoEnd          := ""
	Local cDeContrato       := ""
	Local cAteContrato      := ""
	Local cPlanos           := ""
	Local cIndice           := ""
	Local cStatusLoc        := "Nova Locação"
	Local cPrefLoc          := AllTrim(SuperGetMv("MV_XPRELOC",.F.,"LOC"))
	Local cTipoLoc          := AllTrim(SuperGetMv("MV_XTIPLOC",.F.,"AT"))
	Local cNatLoc           := AllTrim(SuperGetMv("MV_XNATLOC",.F.,"10101"))
	Local dVencimento       := Stod("")
	Local dDataDe           := Stod("")
	Local dDataAt           := Stod("")
	Local lRetorno          := .F.
	Local nParcQuantidade   := SuperGetMV("MV_XPARLOC",,12)    // quantidade de parcelas
	Local nTxLocacao        := 0
	Local nI                := 0
	Local nTipo             := 0
	Local nStatus           := 0
	Local nIndice           := 0
	Local nValorAdic        := 0
	Local nDataLoc          := 0
	Local nDiasRet	        := SuperGetMv("MV_XDIASRE",.F.,30)

	Default lEnd            := .T.
	Default cLog            := ""
	Default aParam          := {}
	Default cTrbContrato    := "TRBCTR"
	Default cTrbParcelas    := "TRBPAR"
	Default nTotReaj        := 0
	Default nTotLocacao     := 0

	// zero as variaveis
	nTotReaj    := 0
	nTotLocacao := 0

	// valido o conteudo das variaveis de alias temporarios
	If Empty(cTrbContrato) // alias temporario de contratos
		cTrbContrato    := "TRBCTR"
	EndIf

	If Empty(cTrbParcelas) // alias temporario de parcelas
		cTrbParcelas    := "TRBPAR"
	EndIf

	// verifico se o array de parametros tem dados
	If Len( aParam ) > 0

		// preencho as variaveis de acordo com o array de parametros se houver dados
		If Len( aParam ) >= 1 .And. !Empty(aParam[1])
			cDeContrato     := aParam[1]
		EndIf

		// preencho as variaveis de acordo com o array de parametros se houver dados
		If Len( aParam ) >= 2 .And. !Empty(aParam[2])
			cAteContrato    := aParam[2]
		EndIf

		// preencho as variaveis de acordo com o array de parametros se houver dados
		If Len( aParam ) >= 3 .And. !Empty(aParam[3])
			cPlanos         := aParam[3]
		EndIf

		// preencho as variaveis de acordo com o array de parametros se houver dados
		If Len( aParam ) >= 4 .And. !Empty(aParam[4])
			cIndice         := aParam[4]
		EndIf

		// preencho as variaveis de acordo com o array de parametros se houver dados
		If Len( aParam ) >= 5 .And. aParam[5] > 0
			nTipo           := aParam[5]
		EndIf

		// preencho as variaveis de acordo com o array de parametros se houver dados
		If Len( aParam ) >= 6 .And. !Empty(aParam[6])
			dDataDe         := aParam[6]
		EndIf

		// preencho as variaveis de acordo com o array de parametros se houver dados
		If Len( aParam ) >= 7 .And. !Empty(aParam[7])
			dDataAt         := aParam[7]
		EndIf

		// preencho as variaveis de acordo com o array de parametros se houver dados
		If Len( aParam ) >= 8 .And. !Empty(aParam[8])
			nDataLoc         := aParam[8]
		EndIf

	EndIf

	//===========================
	// prencho a variavel de log
	//===========================
	cLog := ">> INICIO DO PROCESAMENTO" + CRLF
	cLog += CRLF

	If Select("TRBLOC") > 0
		TRBLOC->( DbCloseArea() )
	EndIf

	// pego o mes e o ano atual
	cAnoMes := AnoMes(dDatabase)

	cQuery := " SELECT "
	cQuery += " U00.U00_CODIGO 		CONTRATO, "
	cQuery += " U00.U00_CLIENT 		CODCLI, "
	cQuery += " U00.U00_LOJA 		LOJACLI, "
	cQuery += " U00.U00_NOMCLI 		CLIENTE, "
	cQuery += " U00.U00_PRIMVE 		DTVENCTO, "
	cQuery += " U00.U00_INDICE 		INDICE, "
	cQuery += " U00.U00_TXLOCN 		TXLOCACAO, "
	cQuery += " U04.U04_TIPO 		TIPOEND, "
	cQuery += " (CASE "
	cQuery += " WHEN U04.U04_CREMAT <> ' ' THEN U04.U04_CREMAT "
	cQuery += " 	ELSE U04.U04_OSSARI "
	cQuery += " END) AS CREMOSSU, "
	cQuery += " (CASE "
	cQuery += " WHEN U04.U04_NICHOC <> ' ' THEN U04.U04_NICHOC "
	cQuery += " 	ELSE U04.U04_NICHOO "
	cQuery += " END) AS NICHOCO, "
	cQuery += " ULTIMA_MANUTENCAO.DATA_PROXIMA_MANUTENCAO PROXMAN "
	cQuery += " FROM " + RetSqlName("U00") + " U00 "
	cQuery += " INNER JOIN " + RetSqlName("U04") + " U04 ON U04.D_E_L_E_T_ = ' ' "
	cQuery += " AND U04.U04_FILIAL = '"+ xFilial("U04") +"' "
	cQuery += " AND U04.U04_CODIGO = U00.U00_CODIGO "
	cQuery += " AND U04.U04_DTUTIL <> ' ' "

	// considera data de loacao
	if nDataLoc == 1

		// pego apenas os servicos feitos anterior a data de retirada
		cQuery += " AND U04.U04_DTUTIL < '"+Dtos(DaySub(dDataBase,nDiasRet))+"' "

	else

		// verifico se o parametro data ate esta preenchido
		if !Empty(dDataAt)
			cQuery += " AND U04.U04_DTUTIL BETWEEN '"+Dtos(dDataDe)+"' AND '"+Dtos(dDataAt)+"' "
		endIf

	endIf

	If nTipo == 1 .Or. nTipo == 0 // ambos
		cQuery  += " AND U04.U04_TIPO <> 'J' "
	ElseIf nTipo == 2 // crematorio
		cQuery  += " AND U04.U04_TIPO = 'C' "
	ElseIf nTipo == 3 // ossario
		cQuery  += " AND U04.U04_TIPO = 'O' "
	EndIf

	cQuery += " LEFT JOIN "
	cQuery += " (	SELECT "
	cQuery += "     U74.U74_CONTRA 	AS CODIGO_CONTRATO, "
	cQuery += "     U74.U74_TPEND 	AS TPEND, "
	cQuery += "     U74.U74_CREMOS 	AS CREMOS, "
	cQuery += "     U74.U74_NICHO 	AS NICHO, "
	cQuery += "     MAX(SUBSTRING(U74_PROMAN, 3, 4) + SUBSTRING(U74_PROMAN, 1, 2)) AS DATA_PROXIMA_MANUTENCAO "
	cQuery += " 	FROM "
	cQuery += " 	" + RetSqlName("U74") + " U74 "
	cQuery += " 	WHERE "
	cQuery += " 	U74.D_E_L_E_T_ = ' ' "
	cQuery += "     AND U74.U74_FILIAL = '" + xFilial("U74") + "' "
	cQuery += " 	AND U74.U74_STATUS = '1' "
	cQuery += " 	GROUP BY U74.U74_CONTRA, "
	cQuery += "                U74.U74_TPEND, "
	cQuery += "                U74.U74_CREMOS, "
	cQuery += "                U74.U74_NICHO "
	cQuery += " ) 	ULTIMA_MANUTENCAO "
	cQuery += " ON U00.U00_CODIGO = ULTIMA_MANUTENCAO.CODIGO_CONTRATO "

	cQuery += " WHERE U00.D_E_L_E_T_ = ' '    "
	cQuery += " AND U00.U00_FILIAL = '" + xFilial("U00") + "'"
	cQuery += " AND U00.U00_TXLOCN > 0 "

	// verifico se existe indice para ser filtrado
	If !Empty(cIndice)
		cQuery += " AND U00.U00_INDICE = '" + cIndice + "' "
	EndIf

	// pego os planos
	If !Empty(cPlanos)
		cQuery += " 	AND U00.U00_PLANO IN " + FormatIn( AllTrim(cPlanos),";") + " "
	Endif

	// pego os contratos
	If !Empty(cAteContrato)
		cQuery  += "      AND U00.U00_CODIGO BETWEEN '" + AllTrim(cDeContrato) + "' AND '" + AllTrim(cAteContrato) + "' "
	EndIf

	cQuery += " AND	ISNULL(ULTIMA_MANUTENCAO.DATA_PROXIMA_MANUTENCAO,'" + cAnoMes + "') <= '" + cAnoMes + "'"

	MemoWrite("c:\Temp\locnicho"+CriaTrab( , .F. )+".txt",cQuery)

	TcQuery cQuery New Alias "TRBLOC"

	// percorro os dados da consulta
	While TRBLOC->(!Eof())

		// limpo as variaveis
		aAuxCtr     := {}
		cDiaVenc    := ""
		dVencimento := StoD("")
		cParcela    := ""
		cTipoEnd    := ""
		nIndice     := 0
		nValorAdic  := 0
		cStatusLoc  := "Nova Locação"

		// pego a dia do vencimento
		cDiaVenc    := SubStr(TRBLOC->DTVENCTO, 7, 2)

		// preencho o tipo de enderecamento
		If TRBLOC->TIPOEND == "C" // para crematoio
			cTipoEnd := "C=Crematorio"
		Else // para ossuario
			cTipoEnd := "O=Ossuário"
		EndIf

		// pego o codigo do historico de taxa de locacao
		ProcHist( @cCodHist, @cStatusLoc, TRBLOC->CONTRATO, cTipoEnd, TRBLOC->CREMOSSU, TRBLOC->NICHOCO )

		// reajuste
		if SubStr(cStatusLoc,1,1) == "R"

			// quando for reajuste de locação de nicho
			nTxLocacao  := ProcReajuste( TRBLOC->INDICE, cCodHist, TRBLOC->CONTRATO, @nIndice, @nValorAdic )
			nTotReaj++

		else

			// taxa de tocacao para novas
			nTxLocacao  := TRBLOC->TXLOCACAO
			nTotLocacao++

		endIf

		// array auxiliar dos contratos
		Aadd( aAuxCtr, { "TR_MARK" 	    , .T.	            })
		Aadd( aAuxCtr, { "TR_STATUS"	, cStatusLoc  	    })
		Aadd( aAuxCtr, { "TR_CODIGO"	, cCodHist  	    })
		Aadd( aAuxCtr, { "TR_CONTRAT"	, TRBLOC->CONTRATO	})
		Aadd( aAuxCtr, { "TR_CODCLI"	, TRBLOC->CODCLI	})
		Aadd( aAuxCtr, { "TR_LOJCLI"	, TRBLOC->LOJACLI	})
		Aadd( aAuxCtr, { "TR_CLIENTE"	, TRBLOC->CLIENTE	})
		Aadd( aAuxCtr, { "TR_TIPOEND"	, cTipoEnd      	})
		Aadd( aAuxCtr, { "TR_CREMOS"	, TRBLOC->CREMOSSU	})
		Aadd( aAuxCtr, { "TR_NICHO"	    , TRBLOC->NICHOCO	})
		Aadd( aAuxCtr, { "TR_DIAVENC"	, cDiaVenc	        })
		Aadd( aAuxCtr, { "TR_INDIC"	    , TRBLOC->INDICE    })
		Aadd( aAuxCtr, { "TR_TXINDI"	, nIndice           })
		Aadd( aAuxCtr, { "TR_VLADIC"	, nValorAdic        })
		Aadd( aAuxCtr, { "TR_TXLOCN"	, nTxLocacao        })

		// quantidade de parcelas
		For nI := 1 to nParcQuantidade

			// limpa a variavel
			cDtAux      := ""
			aAuxParc    := {}

			// caso a data de vencimento estiver vazia
			If Empty( dVencimento )

				// monto a data auxiliar
				if Month( MonthSum( dDatabase, 1 ) ) == 2 .And. Val(cDiaVenc) > 28
					cDtAux     := SubStr( Dtos( MonthSum( dDatabase, 1 ) ), 1, 6 ) + "28"
				else
					cDtAux     := SubStr( Dtos( MonthSum( dDatabase, 1 ) ), 1, 6 ) + cDiaVenc
				endIf

			Else// caso a data de vencimento esitver preenchida

				// monto a data auxiliar
				if Month( MonthSum( dVencimento, 1 ) ) == 2 .And. Val(cDiaVenc) > 28
					cDtAux     := SubStr( Dtos( MonthSum( dVencimento, 1 ) ), 1, 6 ) + "28"
				else
					cDtAux     := SubStr( Dtos( MonthSum( dVencimento, 1 ) ), 1, 6 ) + cDiaVenc
				endIf

			EndIf

			// monto a data de vencimento
			dVencimento := Stod( cDtAux )

			// pego o numero da parcela
			ParcTaxa( @cParcela, TRBLOC->CONTRATO, cPrefLoc, cCodHist, cTipoLoc, aDadosParc )

			// array auxiliar de parcelas
			Aadd( aAuxParc, { "TMP_CODIGO" 	    , cCodHist                              	})
			Aadd( aAuxParc, { "TMP_PARCEL" 	    , cParcela	                                })
			Aadd( aAuxParc, { "TMP_PREF" 	    , cPrefLoc                              	})
			Aadd( aAuxParc, { "TMP_NATURE" 	    , cNatLoc                                 	})
			Aadd( aAuxParc, { "TMP_NUM" 	    , cCodHist      	                        })
			Aadd( aAuxParc, { "TMP_TIPO" 	    , cTipoLoc	                                })
			Aadd( aAuxParc, { "TMP_VALOR" 	    , nTxLocacao                             	})
			Aadd( aAuxParc, { "TMP_VENCTO" 	    , dVencimento	                            })

			// preencho o array de dados
			Aadd( aDadosParc, aAuxParc )

		Next nI

		// preencho o array de dados
		Aadd( aDadosCtr, aAuxCtr )

		TRBLOC->( DbSkip() )
	EndDo

	// verifico se o objeto do alias temproario de contratos existe no banco
	If ValType( oTempContrato ) == "O"
		oTempContrato:Delete()
	EndIf

	// zero o objeto
	oTempContrato := Nil

	// vou popular a tabela de dados - detalhes
	U_RCPGA41A( cTrbContrato, @oTempContrato, .F. )

	// chama a funcao para gravar os registros de tipo
	U_RCPGE29A( aDadosCtr, cTrbContrato, /*lGeraDados*/, @oBrowseContrato, @oBrowseParcelas )

	// vou popular a tabela de dados - detalhes
	If Len( aDadosParc ) > 0

		// verifico se o objeto do alias temproario de parcelas existe no banco
		If ValType( oTempParcelas ) == "O"
			oTempParcelas:Delete()
		EndIf

		// zero o objeto
		oTempParcelas := Nil

		// vou popular a tabela de dados - detalhes
		U_RCPGA41B( cTrbParcelas, @oTempParcelas )

		// vou popular a tabela de dados - detalhes
		U_RCPGE29A( aDadosParc, cTrbParcelas, /*lGeraDados*/, @oBrowseContrato, @oBrowseParcelas )

		If (cTrbContrato)->(!Eof()) .And. (cTrbParcelas)->(!Eof())
			lRetorno := .T.
		EndIf

	EndIf

	If Select("TRBLOC") > 0
		TRBLOC->( DbCloseArea() )
	EndIf

Return(lRetorno)

/*/{Protheus.doc} ProcHist
description
@type function
@version 
@author g.sampaio
@since 03/03/2020
@param cCodHist, character, param_description
@return return_type, return_description
/*/
Static Function ProcHist( cCodHist, cStatusLoc, cContrato, cTipoEnd, cCremOssu, cNicho )

	Local cQuery        := ""

	Default cCodHist    := ""
	Default cStatusLoc  := ""
	Default cContrato   := ""
	Default cTipoEnd    := ""
	Default cCremOssu   := ""
	Default cNicho      := ""

	if Select("TRBU74") > 0
		TRBU74->(DbCloseArea())
	endIf

	// query de consulta para ver ve estou reajustando a locacao
	cQuery := " SELECT U74.U74_CODIGO CODIGO FROM " + RetSqlName("U74") + " U74  "
	cQuery += " WHERE U74.D_E_L_E_T_ = ' '                          "
	cQuery += " AND U74.U74_CODIGO <> ' '                           "
	cQuery += " AND U74.U74_CONTRA = '" + cContrato + "'                "
	cQuery += " AND U74.U74_TPEND  = '" + SubStr(cTipoEnd,1,1) + "'                "
	cQuery += " AND U74.U74_CREMOS = '" + cCremOssu + "'                "
	cQuery += " AND U74.U74_NICHO  = '" + cNicho + "'                "
	cQuery += " AND U74.U74_STATUS = '1' "

	TcQuery cQuery New Alias "TRBU74"

	if TRBU74->(!Eof())

		// pego o codigo do historico
		cCodHist := TRBU74->CODIGO

		// status da locacao
		cStatusLoc := "Reajuste Locação"

	else

		// verifico se o codigo ja esta preenchido
		If !Empty(cCodHist)

			// incremento o codigo do historico de taxa
			cCodHist   := Soma1(AllTrim(cCodHist))

		Else// caso nao estiver preenchido

			// encerro o alias se estiver em uso
			If Select("TRBHST") > 0
				TRBHST->( DbCloseArea() )
			EndIf

			// query de consulta
			cQuery := " SELECT MAX(U74.U74_CODIGO) MAXCOD FROM " + RetSqlName("U74") + " U74 "
			cQuery += " WHERE U74.D_E_L_E_T_ = ' '      "
			cQuery += " AND U74.U74_CODIGO <> ' '       "

			TcQuery cQuery New Alias "TRBHST"

			If TRBHST->(!Eof())
				cCodHist    := Soma1(AllTRim(TRBHST->MAXCOD)) // incremento com o maior codigo de
			EndIf

			// verifico se o codigo do historico foi preenchido
			If Empty(AllTrim(cCodHist))
				cCodHist    := StrZero( 1, 6 )
			EndIf

			// encerro o alias se estiver em uso
			If Select("TRBHST") > 0
				TRBHST->( DbCloseArea() )
			EndIf

		EndIf

		if Select("TRBU74") > 0
			TRBU74->(DbCloseArea())
		endIf

	endIf

Return( Nil )

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

	Local cQuery            := ""
	Local nPosParc          := 0
	Local nI                := 0

	Default cParcela        := ""
	Default cCodContrato    := ""
	Default cPrefLoc        := ""
	Default cCodLocacao     := ""
	Default cTipoLoc        := ""
	Default aDadosParc      := {}

	// verifico se o array tem dados
	If Len(aDadosParc) > 0 .And. Empty(AllTrim(cParcela))

		// percorro as parcelas ja inseridas
		For nI := 1 To Len( aDadosParc )

			// verifico se ja encontrei alguma posicao
			If nPosParc > 0

				// verifico se existe mesmo contrato ja no array
				nPosParc    := Ascan( aDadosParc[nI], { |x| AllTrim(x[1]) == "TMP_NUM" .And. AllTrim(x[2]) == cCodLocacao }, nPosParc )

				// verifico se o
				If nPosParc > 0

					// pego a parcela atual
					cParcela    := aDadosParc[nI][2][2]

				EndIf

			ElseIf Empty(cParcela)

				// verifico se existe mesmo contrato ja no array
				nPosParc    := Ascan( aDadosParc[nI], { |x| AllTrim(x[1]) == "TMP_NUM" .And. AllTrim(x[2]) == cCodLocacao } )

				// verifico se o
				If nPosParc > 0

					// pego a parcela atual
					cParcela    := aDadosParc[nI][2][2]

				EndIf

			EndIf

		Next nI

	EndIf

	// verifico se o codigo ja esta preenchido
	If !Empty(cParcela)

		// incremento o codigo do historico de taxa
		cParcela   := Soma1(AllTrim(cParcela))

	Else// caso nao estiver preenchido

		// encerro o alias se estiver em uso
		If Select("TRBPAR") > 0
			TRBPAR->( DbCloseArea() )
		EndIf

		// query para retornar a quantidade de parcelas para a locacao do nicho para o contrato
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

Return

/*/{Protheus.doc} RCPGE27A
Funcao para gerar os registros em alias temporarios
@author g.sampaio
@since 13/06/2019
@version P12
@param aCampos
@param cFwAlias
@return nulo
/*/

User Function RCPGE29A( aCampos, cFwAlias, lGeraDados, oBrowseContrato, oBrowseParcelas, oTempContrato, oTempParcelas )

	Local aDados	:= {}
	Local aAux		:= {}
	Local nX		:= 0
	Local nI		:= 0

	Default aCampos		:= {}
	Default cFwAlias	:= ""
	Default lGeraDados	:= .F.

	// limpa os registros ja existentes
	LimpaDados( cFwAlias )

	// verifico se existe alias temporario
	If !Empty(cFwAlias)

		// caso forem gerados registros vazios
		If lGeraDados

			aAux := {}
			For nX := 1 To Len( aCampos )

				If aCampos[nX,2] == "L" // para o marcar

					Aadd( aAux, { aCampos[nX, 1] , .T. } )

				ElseIf aCampos[nX,2] == "C" // tipo caracter

					Aadd( aAux, { aCampos[nX, 1] , "" } )

				ElseIf aCampos[nX,2] == "D" // tipo data

					Aadd( aAux, { aCampos[nX, 1] , StoD("") } )

				ElseIf aCampos[nX,2] == "N" // tipo numerico

					Aadd( aAux, { aCampos[nX, 1] , 0 } )

				EndIf

			Next nX

			// monto o array aDados
			Aadd( aDados, aAux  )

		Else

			// a estrutura do aCampos se torna o aDados
			aDados := aCampos

		EndIf

		// posiciono no ultimo registro do alias
		(cFwAlias)->( DbGoBottom() )

		// inicio a transacao
		BEGIN TRANSACTION

			For nX := 1 To Len( aDados )

				// travo o registro para gravacao
				If (cFwAlias)->( RecLock( cFwAlias, .T. ) )

					For nI := 1 To Len( aDados[nX] )
						&( cFwAlias + "->" + aDados[nX,nI,1] ) := aDados[nX,nI,2]
					Next nI

					(cFwAlias)->( MsUnLock() )

				Else

					(cFwAlias)->( DisarmTransaction() )

				EndIf

			Next nX

		END TRANSACTION

		// posiciono no primeiro registro da tabela
		(cFwAlias)->( DbGoTop() )

	EndIf

	// verifico se a variavel oBrowseContrato e objeto
	If ValType( oBrowseContrato ) == "O"

		// limpa os filtros
		oBrowseContrato:CleanExFilter()

		// atualizo o objeto
		oBrowseContrato:Refresh()

		// atualizo a construcao do browse
		oBrowseContrato:UpdateBrowse(.T.)

	EndIf

	// verifico se a variavel oBrowseParcelas e objeto
	If ValType( oBrowseParcelas ) == "O"

		// limpa os filtros
		oBrowseParcelas:CleanExFilter()

		// atualizo o filtro
		oBrowseParcelas:SetFilterDefault( oBrowseParcelas:cAlias + "->TMP_CODIGO ==" + oBrowseContrato:cAlias + "->TR_CODIGO" )

		// atualizo o objeto
		oBrowseParcelas:Refresh()

		// atualizo a construcao do browse
		oBrowseParcelas:UpdateBrowse(.T.)

	EndIf

Return(Nil)

/*/{Protheus.doc} LimpaDados
Mostra o log do ultimo processamento

@author g.sampaio
@since 19/07/2016
@version undefined
@param cLog, characters, descricao
@type function
/*/

Static Function LimpaDados( cFwAlias )

	Default cFwAlias    := ""

	// posiciono no primeiro registro
	(cFwAlias)->( DbGoTop() )

	// percorro todo o alias ate o seu fim
	While ( cFwAlias )->( !Eof() )

		BEGIN TRANSACTION

			If ( cFwAlias )->( RecLock( cFwAlias, .F. ) )

				// deleto o registro do alias
				( cFwAlias )->( DbDelete() )

			Else
				( cFwAlias )->( MsUnLock() )
			EndIf

		END TRANSACTION

		( cFwAlias )->( DbSkip() )
	EndDo

Return(Nil)

/*/{Protheus.doc} ProcReajuste
description
@type function
@version 
@author g.sampaio
@since 02/07/2020
@param cIndice, character, param_description
@param cCodHist, character, param_description
@param cContrato, character, param_description
@return return_type, return_description
/*/
Static Function ProcReajuste( cIndice, cCodHist, cContrato, nIndice, nValorAdic )

	Local nRetorno      := 0
	Local nIndice       := 0
	Local nValorAdic    := 0

	Default cIndice     := ""
	Default cCodHist    := ""
	Default cContrato   := ""
	Default nIndice       := 0
	Default nValorAdic    := 0

	if Select("TRBREJ") > 0
		TRBREJ->(DbCloseArea())
	endIf

	// query de consulta para ver ve estou reajustando a locacao
	cQuery := " SELECT U74.U74_TAXA, U74.U74_VLADIC FROM " + RetSqlName("U74") + " U74  "
	cQuery += " WHERE U74.D_E_L_E_T_ = ' '                          "
	cQuery += " AND U74.U74_CODIGO = '" + cCodHist + "'                           "
	cQuery += " AND U74.U74_CONTRA = '" + cContrato + "'                "
	cQuery += " AND U74.U74_STATUS = '1' "

	TcQuery cQuery New Alias "TRBREJ"

	if TRBREJ->(!eof())

		// pego o valor do indice
		nIndice     := BuscaIndice(cIndice)

		// valor a ser reajustado
		nValorAdic  := TRBREJ->U74_TAXA * (nIndice / 100)

		// valor atualizado da taxa de locacao no reajuste
		nRetorno    := TRBREJ->U74_TAXA + TRBREJ->U74_VLADIC + nValorAdic

	endIf

Return(nRetorno)

/*/{Protheus.doc} BuscaIndice
description
@type function
@version 
@author g.sampaio
@since 02/07/2020
@param cIndice, character, param_description
@return return_type, return_description
/*/
Static Function BuscaIndice(cIndice)

	Local cQry 		   	:= ""
	Local nRet			:= 0
	Local dDataRef		:= dDataBase

	// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	cQry := " SELECT "
	cQry += " SUM(U29.U29_INDICE) AS INDICE "
	cQry += " FROM "
	cQry += + RetSqlName("U22") + " U22 "
	cQry += " INNER JOIN "
	cQry += + RetSqlName("U28") + " U28 "
	cQry += "    INNER JOIN "
	cQry += + 	 RetSqlName("U29") + " U29 "
	cQry += "    ON ( "
	cQry += "        U29.D_E_L_E_T_ <> '*' "
	cQry += "        AND U28.U28_CODIGO = U29.U29_CODIGO "
	cQry += "        AND U28.U28_ITEM = U29.U29_IDANO "
	cQry += " 		 AND U29.U29_FILIAL = '" + xFilial("U29") + "' "
	cQry += "    ) "
	cQry += " ON ( "
	cQry += "    U28.D_E_L_E_T_ <> '*' "
	cQry += "    AND U22.U22_CODIGO = U28.U28_CODIGO "
	cQry += " 	 AND U28.U28_FILIAL = '" + xFilial("U28") + "' "
	cQry += "    ) "
	cQry += " WHERE "
	cQry += " U22.D_E_L_E_T_ <> '*' "
	cQry += " AND U22.U22_FILIAL = '" + xFilial("U22") + "' "
	cQry += " AND U22.U22_STATUS = 'A' "

	if !Empty(cIndice)
		cQry += " AND U22.U22_CODIGO = '" + cIndice + "' "
	endif

	cQry += " AND U28.U28_ANO + U29.U29_MES "
	cQry += " BETWEEN '" + AnoMes(MonthSub(dDataRef,11)) + "'  AND  '" + AnoMes(dDataRef) + "' "

	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)

	// crio o alias temporario
	TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query

	// se existir contratos a serem reajustados
	if QRY->(!Eof())
		nRet := Round(QRY->INDICE,TamSX3("U29_INDICE")[2])
	endif

	// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

Return(nRet)
