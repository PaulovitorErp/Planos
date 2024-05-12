#include 'totvs.ch'
#include 'topconn.ch'

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RUTILE15
Gera Comissao de Contrato Cemiterio
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
@history 24/05/2020, g.sampaio, ajuste na funcao ValidaSE3
@history 02/06/2020, g.sampaio, VPDV-473 - ajuste na funcao UTILE15B
/*/

User Function RUTILE15( cTipModulo, cCodigoContrato, cCodVendedor, nVlrCtr, cLog, dDtEmissao, lGrava,;
		cCodCli, cLojaCli, lJob, nVlrComissao, nVlrTotal, nPerVend, cPrefCtr, cTipoCtr, cTipoEnt, cParcTit, cLstVend, dDataRef )

	Local aArea             := GetArea()
	Local aAreaSA3          := SA3->( GetArea() )
	Local aAreaSA1          := SA1->( GetArea() )
	Local aAreaU18          := U18->( GetArea() )
	Local aDados			:= {}
	Local cCategoria        := ""
	Local cChave			:= ""
	Local lRetorno			:= .T.
	Local lContinua			:= .T.
	Local nPComis			:= 0
	Local nComissao      	:= 0
	Local nContador			:= 0
	Local nI				:= 0
	Local nParcela			:= 0

	Default cTipModulo      := ""
	Default cCodigoContrato := ""
	Default cCodVendedor    := ""
	Default nVlrCtr         := 0
	Default cLog            := ""
	Default dDtEmissao      := StoD("")
	Default lGrava          := .F.
	Default cCodCli         := ""
	Default cLojaCli        := ""
	Default	lJob			:= .F.
	Default nVlrComissao   	:= 0
	Default nVlrTotal		:= 0
	Default nPerVend		:= 0
	Default cPrefCtr		:= ""
	Default cTipoCtr		:= ""
	Default cTipoEnt		:= ""
	Default cParcTit		:= "0"
	Default cLstVend		:= ""

	cLog += CRLF
	cLog += " >> RUTILE15 [INICIO] - ROTINA DE PROCESSAMENTO DE COMISSAO." + CRLF

	// defino o codigo do cliente
	If Empty( AllTrim(cCodCli) )
		cCodCli := GetMV("MV_CLIPAD")
	EndIf

	// defino a loja do cliente
	If Empty( Alltrim(cLojaCli) )
		cLojaCli := GetMV("MV_LOJAPAD")
	EndIf

	//Posiciona no Vendedor
	SA3->( DbSetOrder(1) ) //A3_FILIAL+A3_COD
	If SA3->( MsSeek( xFilial("SA3")+cCodVendedor ) )

		//Posiciona no Cliente/Loja
		SA1->( DbSetOrder(1) ) //A1_FILIAL+A1_COD+A1_LOJA
		If SA1->( MsSeek( xFilial("SA1")+cCodCli+cLojaCli ) )

			//Posiciona no Cliclo e Pgto de Comissão
			U18->( DbSetOrder(1) ) //U18_FILIAL+U18_CODIGO
			If U18->( MsSeek( xFilial("U18")+SA3->A3_XCICLO ) )

				// verifico se o alias esta em uso
				If Select("TRBCAT") > 0

					// fecho o alias
					TRBCAT->(dbCloseArea())

				EndIf

				// verifico se o contrato esta preenchido
				If !Empty( cCodigoContrato ) .And. cTipModulo <> "G"

					// pego os dados do plano
					DadosPlano( cTipModulo, cCodigoContrato, @cCategoria, @cLog )

				EndIf

				// verifica se a categoria esta preenchida
				If Empty( Alltrim( cCategoria ) )

					// pego a categoria do vendedor, se estiver vazio o plano
					cCategoria := SA3->A3_XCATEGO

				EndIf

				cLog += CRLF
				cLog += ">> Categoria : " + cCategoria + CRLF

				// query de categoria de vendedor
				cQuery := " SELECT U15.U15_CODIGO, U15.U15_TPCOMI, U16.U16_CODIGO, U16.U16_FXINIC, U16.U16_FXFIM, U16.U16_VLPORC, U17.U17_CODIGO, U15.U15_TPVAL, U17.U17_PERC, U17.U17_VALOR, U17.U17_PRAZO "
				cQuery += " FROM " + RetSqlName("U15") + " U15"
				cQuery += " INNER JOIN " + RetSqlName("U16") + " U16"
				cQuery += " ON (U15_FILIAL = U16_FILIAL and U15_CODIGO = U16_CATEGO and U16.D_E_L_E_T_ <> '*')"
				cQuery += " LEFT JOIN " + RetSqlName("U17") + " U17"
				cQuery += " ON (U15_FILIAL = U17_FILIAL and U15_CODIGO = U17_CATEGO and U16_CODIGO = U17_CONDIC and U17.D_E_L_E_T_ <> '*')"
				cQuery += " WHERE U15.D_E_L_E_T_ <> '*'"

				// verifico se o campo de bloqueio automatico existe
				If U15->( FieldPos("U15_MSBLQL") ) > 0
					cQuery += " AND U15.U15_MSBLQL <> '1' "
				EndIf

				cQuery += " AND U15.U15_FILIAL = '" + xFilial("U15") + "'"
				cQuery += " AND U15.U15_CODIGO = '" + cCategoria + "'"
				cQuery += " ORDER BY U15_CODIGO,U16_CODIGO,U17_CODIGO ASC "

				//===========================
				// prencho a variavel de log
				//===========================

				cLog += CRLF
				cLog += " >> QUERY Categoria: "
				cLog += CRLF
				cLog += cQuery
				cLog += CRLF
				cLog += CRLF

				cQuery := Changequery(cQuery)
				TcQuery cQuery New Alias "TRBCAT"

				TRBCAT->(dbGoTop())

				cE3_SEQ		:= PADL( '0', tamsx3('E3_SEQ')[1],'0')		//	-> sequencia

				If TRBCAT->(!Eof())

					// para supervisor/gerente
					If cTipModulo == "G"

						// o contador é o valor do contrato
						nContador := DadosVendedor( cTipModulo, cLstVend, TRBCAT->U15_TPCOMI, U18->U18_DIAFEC, @cLog )

					ElseIf TRBCAT->U15_TPCOMI <> "4"

						// pego os dados do vendedor
						nContador := DadosVendedor( cTipModulo, cCodVendedor, TRBCAT->U15_TPCOMI, U18->U18_DIAFEC, @cLog )

					EndIf

				Else

					// retorno falso
					lContinua := .F.

					// verifico se a log esta preenchido
					If !Empty(cLog)

						// preencho a log
						cLog += CRLF
						cLog += "   >> NAO FORAM ENCONTRADAS REGRAS DE CATEGORIA DE COMISSAO..." + CRLF

					Else

						If !lJob

							// mensagem de retorno para o usuario
							MsgInfo("Não foram encontradas regras de categoria de comissão para o vendedor "+SA3->A3_COD+" - "+AllTrim(SA3->A3_NOME)+".","Atenção")

						EndIf

					EndIf

				EndIf

				// Verificose a comissao e diferente de
				If TRBCAT->U15_TPCOMI <> "4"

					nParcela := 0
					While TRBCAT->(!Eof()) .and. lContinua

						cLog += CRLF
						cLog += ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + CRLF
						cLog += ">> Registros alias TRBCAT..." + CRLF
						cLog += ">> Faixa : " + Transform( nContador,"@E 9,999,999,999,999.99") + CRLF
						cLog += ">> Faixa Inicial 	: " + Transform( TRBCAT->U16_FXINIC,"@E 9,999,999,999,999.99") + CRLF
						cLog += ">> Faixa Final  	: "	+ Transform( TRBCAT->U16_FXFIM,"@E 9,999,999,999,999.99") + CRLF
						cLog += ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + CRLF

						// verifico a faixa que se enquadra
						If nContador >= TRBCAT->U16_FXINIC .And. nContador <= TRBCAT->U16_FXFIM

							cLog += CRLF
							cLog += ">> Faixa utilizada : " + StrZero( nContador, 3 ) + CRLF

							// monto o numero da parcela
							If cChave <> TRBCAT->U15_CODIGO+TRBCAT->U16_CODIGO
								nParcela 	:= 1
								cChave 		:= TRBCAT->U15_CODIGO+TRBCAT->U16_CODIGO
							Else
								nParcela++
							EndIf

							cE3_PARCELA := PADL( nParcela, tamsx3('E3_PARCELA')[1],'0') 	// 	-> parcela
							cE3_SEQ		:= Soma1(cE3_SEQ)

							// pego a quantidade de parcelas que serao geradoss
							nPComis 	:= ContaParcelas( TRBCAT->U15_CODIGO, TRBCAT->U16_CODIGO )

							// verifica o tipo de comissao
							If TRBCAT->U15_TPCOMI == "1" // por quantidade recebida

								//==================
								// preencho a log
								//==================

								cLog += ">> Faixa Inicial 	: " + StrZero( TRBCAT->U16_FXINIC, 3 ) + CRLF
								cLog += ">> Faixa Final  	: "	+ StrZero( TRBCAT->U16_FXFIM, 3 ) + CRLF
								cLog += CRLF
								cLog += ">> Por Quantidade Recebida : " + StrZero( nContador, 3 ) + CRLF
								cLog += "Valor faixa : " + Transform(TRBCAT->U16_VLPORC,"@E 9,999,999,999,999.99") + CRLF

								// calculo da comissao
								nComissao := TRBCAT->U16_VLPORC

								// preencho a log
								cLog += "Comissao : " + Transform(nComissao,"@E 9,999,999,999,999.99")

							ElseIf TRBCAT->U15_TPCOMI == "2" // por quantidade vendida

								//==================
								// preencho a log
								//==================

								cLog += ">> Faixa Inicial 	: " + StrZero( TRBCAT->U16_FXINIC, 3 ) + CRLF
								cLog += ">> Faixa Final  	: "	+ StrZero( TRBCAT->U16_FXFIM, 3 ) + CRLF
								cLog += CRLF
								cLog += ">> Por Quantidade Vendida : " + StrZero( nContador, 3 ) + CRLF
								cLog += "Valor faixa : " + Transform(TRBCAT->U16_VLPORC,"@E 9,999,999,999,999.99") + CRLF

								// calculo da comissao
								If cTipModulo == "G"
									nComissao := TRBCAT->U16_VLPORC * nContador
								Else
									nComissao := TRBCAT->U16_VLPORC
								EndIf

								// preencho a log
								cLog += "Comissao : " + Transform(nComissao,"@E 9,999,999,999,999.99")

							ElseIf TRBCAT->U15_TPCOMI == "3" // por total vendido

								//==================
								// preencho a log
								//==================

								cLog += ">> Faixa Inicial 	: " + Transform(TRBCAT->U16_FXINIC,"@E 9,999,999,999,999.99") + CRLF
								cLog += ">> Faixa Final  	: "	+ Transform(TRBCAT->U16_FXFIM,"@E 9,999,999,999,999.99") + CRLF
								cLog += CRLF
								cLog += ">> Por Total Vendido :" + Transform(nContador,"@E 9,999,999,999,999.99") + CRLF
								cLog += "Valor faixa : " + Transform(TRBCAT->U16_VLPORC,"@E 9,999,999,999,999.99") + CRLF

								// calculo da comissao
								nComissao := nVlrCtr * (TRBCAT->U16_VLPORC/100)

								// preencho a log
								cLog += "Comissao : " + Transform(nComissao,"@E 9,999,999,999,999.99")

							EndIf

							// alimento o valor da comissao
							nVlrComissao 	:= nComissao
							nVlrTotal		:= nVlrCtr
							nPerVend		:= (nComissao/nVlrTotal)*100 //TRBCAT->U16_VLPORC

							// verifico se faco o processo de comissao
							If lContinua .And. nComissao > 0 .And. lGrava

								// gero a comissao de acordo com o parcelamento
								If TRBCAT->U15_TPVAL == "P" .Or. Empty( TRBCAT->U15_TPVAL ) // por percentual
									nComissao 	:= nComissao * (TRBCAT->U17_PERC/100)
								ElseIf TRBCAT->U15_TPVAL == "V" // por valor
									nComissao	:= TRBCAT->U17_VALOR
								EndIf

								// gero o registro da comissao
								lContinua := U_UTILE15A( cCodigoContrato, cCodVendedor, nVlrCtr, cE3_PARCELA, cE3_SEQ, dDtEmissao, TRBCAT->U17_PRAZO, nComissao,;
									U18->U18_DIAFEC, cPrefCtr, cTipoCtr, cTipoEnt, SA1->A1_COD, SA1->A1_LOJA, @cLog, lJob, cTipModulo, nPComis, nContador, TRBCAT->U15_TPCOMI )

								// pego o retorno do lContinua
								lRetorno := lContinua
							Else

								// saio do laco de repeticao
								Exit

							EndIf

						EndIf

						TRBCAT->(dbSkip())
					EndDo

				ElseIf TRBCAT->U15_TPCOMI == "4" .And. lContinua// por parcelamento (representante)

					// busco os dados do representante
					aDados := DadosRepresentante( cTipModulo, cCodVendedor, TRBCAT->U15_TPCOMI, U18->U18_DIAFEC, @cLog, cPrefCtr, cTipoCtr, cTipoEnt, cCodigoContrato )

					// percorro os contatos do representante
					For nI := 1 To Len( aDados )

						nParcela := 0
						// percorro a query de categoria
						While TRBCAT->(!Eof())

							// verifico a faixa que se enquadra
							If aDados[nI,2] >= TRBCAT->U16_FXINIC .And. aDados[nI,2] <= TRBCAT->U16_FXFIM

								// monto o numero da parcela
								nParcela++ // incremento a parcela

								cE3_PARCELA := PADL( nParcela, tamsx3('E3_PARCELA')[1],'0') 	// 	-> parcela
								cE3_SEQ		:= Soma1(cE3_SEQ)

								// pego a quantidade de parcelas que serao geradoss
								nPComis 	:= ContaParcelas( TRBCAT->U15_CODIGO, TRBCAT->U16_CODIGO )

								//==================
								// preencho a logJ
								//==================

								cLog += ">> Faixa Inicial 		: " + Transform(TRBCAT->U16_FXINIC,"@E 9,999,999,999,999.99") + CRLF
								cLog += ">> Faixa Final  		: "	+ Transform(TRBCAT->U16_FXFIM,"@E 9,999,999,999,999.99") + CRLF
								cLog += CRLF
								cLog += ">> Por Total Vendido 	: " + Transform(aDados[nI,2],"@E 9,999,999,999,999.99") + CRLF
								cLog += ">> Valor faixa 		: " + Transform(TRBCAT->U16_VLPORC,"@E 9,999,999,999,999.99") + CRLF

								// calculo da comissao
								nComissao := nVlrCtr * (TRBCAT->U16_VLPORC/100)

								// preencho a log
								cLog += "Comissao : " + Transform(nComissao,"@E 9,999,999,999,999.99")

								// alimento o valor da comissao
								nVlrComissao 	:= nComissao
								nVlrTotal		:= nVlrCtr
								nPerVend		:= TRBCAT->U16_VLPORC

								// verifico se faco o processo de comissao
								If nComissao > 0 .And. lGrava

									// verifico se continuo gerando a consulta
									If lContinua

										// aplico percentual do parcelamento
										If TRBCAT->U15_TPVAL == "P" .Or. Empty( TRBCAT->U15_TPVAL ) // por percentual
											nComissao 	:= nComissao * (TRBCAT->U17_PERC/100)
										ElseIf TRBCAT->U15_TPVAL == "V" // por valor
											nComissao	:= TRBCAT->U17_VALOR
										EndIf

										// gero o registro da comissao
										lContinua := U_UTILE15A( cCodigoContrato, cCodVendedor, nVlrCtr, cE3_PARCELA, cE3_SEQ, dDtEmissao, TRBCAT->U17_PRAZO, nComissao,;
											U18->U18_DIAFEC, cPrefCtr, cTipoCtr, cTipoEnt, SA1->A1_COD, SA1->A1_LOJA, @cLog, lJob, cTipModulo, nPComis, aDados[nI,2], TRBCAT->U15_TPCOMI )

									Else
										// saio do laco de repeticao
										Exit

									EndIf

									// pego o retorno do lContinua
									lRetorno := lContinua

								EndIf

							EndIf

							TRBCAT->( DbSkip() )

						EndDo

					Next nI

				EndIf

			Else

				lRetorno	:= .F. // retorno falso da funcao

			EndIf

		Else

			lRetorno	:= .F. // retorno falso da funcao

		EndIf

	Else

		lRetorno	:= .F. // retorno falso da funcao

	EndIf

	If Select("TRBCAT") > 0

		TRBCAT->(dbCloseArea())

	EndIf

	cLog += CRLF
	cLog += " >> RUTILE15 [FIM] - ROTINA DE PROCESSAMENTO DE COMISSAO." + CRLF

	RestAreA( aAreaU18 )
	RestAreA( aAreaSA1 )
	RestAreA( aAreaSA3 )
	RestAreA( aArea )

Return( lRetorno )

/*/{Protheus.doc} DadosPlano
Gera Comissao de Contrato Cemiterio
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
/*/

Static Function DadosPlano( cTipModulo, cCodigoContrato, cCategoria, cLog )

	Local aArea             := GetArea()
	Local aAreaUF0          := {}
	Local aAreaUF2          := {}
	Local aAreaU05          := {}
	Local aAreaU00          := {}
	Local lFuneraria	    := SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	    := SuperGetMV("MV_XCEMI",,.F.)

	Default cTipModulo      := ""
	Default cCodigoContrato := ""
	Default cCategoria      := ""
	Default cLog			:= ""

	cLog += CRLF
	cLog += ">> Static Function DadosPlano [INICIO] : " + CRLF

// para funeraria
	If lFuneraria .And. cTipModulo == "F"

		// salvo a area das tabela
		aAreaUF0 := UF0->( GetArea() )
		aAreaUF2 := UF2->( GetArea() )

		// posiciono na tabela de contratos
		UF2->( DbSetOrder(1) )
		If UF2->( MsSeek( xFilial("UF2")+cCodigoContrato ) )

			// posiciona na tabela de planos
			UF0->( DbSetOrder(1) )
			If UF0->( MsSeek( xFilial("UF0")+UF2->UF2_PLANO ) )

				// verifico se a categoria do plano
				If !Empty( AllTrim( UF0->UF0_CATEGO ) )

					// categoria do plano
					cCategoria := AllTrim( UF0->UF0_CATEGO )

				EndIf

			EndIf

		EndIf

		cLog += ">> Modulo Funeraria : " + CRLF
		cLog += ">> Plano : " + UF2->UF2_PLANO + " - " + UF0->UF0_DESCRI + CRLF

		// restauro o area das tabelas
		RestArea( aAreaUF2 )
		RestArea( aAreaUF0 )

	EndIf

// para cemiterio
	If lCemiterio .And. cTipModulo == "C"

		// salvo a area das tabela
		aAreaU00 := U00->( GetArea() )
		aAreaU05 := U05->( GetArea() )

		// posiciono na tabela de contratos
		U00->( DbSetOrder(1) )
		If U00->( MsSeek( xFilial("U00")+cCodigoContrato ) )

			// posiciona na tabela de planos
			U05->( DbSetOrder(1) )
			If U05->( MsSeek( xFilial("U05")+U00->U00_PLANO ) )

				// verifico se a categoria do plano
				If !Empty( AllTrim( U05->U05_CATEGO ) )

					// categoria do plano
					cCategoria := AllTrim( U05->U05_CATEGO )

				EndIf

				cLog += ">> Modulo Cemiterio : " + CRLF
				cLog += ">> Plano : " + U00->U00_PLANO + " - " + U05->U05_DESCRI + CRLF

			EndIf

		EndIf

		// restauro o area das tabelas
		RestArea( aAreaU05 )
		RestArea( aAreaU00 )

	EndIf

// verifico se a categoria do plano esta preenchida
	If !Empty( cCategoria )

		cLog += ">> Categoria : " + cCategoria + " - " + Posicione( "U15", 1, xFilial("U15")+cCategoria, "U15_DESCRI" ) + CRLF

	Else

		cLog += ">> Categoria não preenchida dentro do plano!" + CRLF

	EndIf

	cLog += CRLF
	cLog += ">> Static Function DadosPlano [FIM] : " + CRLF

	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} DadosVendedor
Gera Comissao de Contrato Cemiterio
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
/*/

Static Function DadosVendedor( cTipModulo, cCodVendedor, cTpComissao, nDiaFechamento, cLog )

	Local aArea				:= GetArea()
	Local aTmp				:= {}
	Local aContratos		:= {}
	Local cQuery            := ""
	Local lFuneraria	    := SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	    := SuperGetMV("MV_XCEMI",,.F.)
	Local cUltFechamento    := ""
	Local cAtuFechamento	:= ""
	Local cTmp				:= ""
	Local nRetorno			:= 0
	Local nX				:= 0
	Local nI				:= 0

	Default cTipModulo      := ""
	Default cCodVendedor    := ""
	Default cTpComissao     := ""
	Default nDiaFechamento  := 0
	Default cLog			:= ""

	cLog += CRLF
	cLog += ">> Static Function DadosVendedor [INICIO] : " + CRLF

	DataFechamento( nDiaFechamento, @cUltFechamento, @cAtuFechamento )

	// verifico se e por parcela recebidas (cobradores)
	If cTpComissao == "1"

		// verifico se o alias temporario esta em uso
		If Select("TRBTIT") > 0

			TRBTIT->( DbCloseArea() )

		EndIf

		//gera comissão para os titulos baixados no periodo de: dBaixaDe e dBaixaAt
		//remove os titulos do tipo abatimento
		aTmp := STRTOKARR(MVABATIM, "|")

		cTmp := " AND SE1.E1_TIPO NOT IN ("

		For nX:= 1 to Len(aTmp)

			If nX < Len(aTmp)

				cTmp += "'"+aTmp[nX]+"', "

			Else

				cTmp += "'"+aTmp[nX]+"'"

			EndIf

		Next nX

		cTmp += ") "

		cQuery := "SELECT SE1.* " + CRLF
		cQuery += " FROM " + RetSqlName("SE1") + " SE1" + CRLF
		cQuery += " WHERE SE1.D_E_L_E_T_ <> '*'" + CRLF
		cQuery += " AND SE1.E1_XFILVEN = '"  + xFilial("SA3") + "' " + CRLF
		cQuery += " AND SE1.E1_XVENDCB = '" + cCodVendedor + "'" + CRLF //vendedor da baixa

		// verifico se o ultimo fechamento esta preenchido
		If !Empty( cUltFechamento ) .And. !Empty( cAtuFechamento )

			cQuery += " AND SE1.E1_BAIXA BETWEEN '" + cUltFechamento + "' AND '" + cAtuFechamento + "' "

		EndIf

		cQuery += cTmp + CRLF //remove os titulos de abatimento
		cQuery += " ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO" + CRLF

		TcQuery cQuery New Alias "TRBTIT"

		//===========================
		// prencho a variavel de log
		//===========================

		cLog += CRLF
		cLog += " >> QUERY Cobradores: "
		cLog += CRLF
		cLog += cQuery
		cLog += CRLF
		cLog += CRLF

		// verifico se existem dados
		While TRBTIT->( !Eof() )

			// coloca a chave do titulo e saldo do titulo
			aAdd( aContratos, { TRBTIT->E1_NUM, TRBTIT->E1_SALDO, TRBTIT->E1_CLIENTE, TRBTIT->E1_LOJA } )

			TRBTIT->( DbSkip() )
		EndDo

		// substituo o valor do retorno
		nRetorno := Len( aContratos )

		// verifico se o alias temporario esta em uso
		If Select("TRBTIT") > 0

			TRBTIT->( DbCloseArea() )

		EndIf

	// para gerente e supervisor
	ElseIf cTipModulo == "G"

		// para o modulo de cemiterio
		If lCemiterio

			// verifico se o alias esta em uso
			If Select( "TRBCEM" ) > 0

				TRBCEM->( DbCloseArea() )

			EndIf

			// para quando for quantidade vendida e valor vendido
			If cTpComissao $ "2/3"

				cQuery := " SELECT "
				cQuery += " U00.U00_CODIGO, U00.U00_VALOR, U00.U00_CLIENT, U00.U00_LOJA"
				cQuery += " FROM " + RetSqlName("U00") + " U00
				cQuery += " WHERE U00.D_E_L_E_T_ = ' '
				cQuery += " AND U00.U00_STATUS IN ('A','F') "
				//cQuery += " AND U00.U00_CODANT = ' ' "

				// verifico se o ultimo fechamento esta preenchido
				If !Empty( cUltFechamento ) .And. !Empty( cAtuFechamento )

					cQuery += " AND U00.U00_DTATIV BETWEEN '" + cUltFechamento + "' AND '" + cAtuFechamento + "' "

				EndIf

				// verifico se tem lista de vendedores
				If !Empty( cCodVendedor )

					cQuery += " AND U00.U00_VENDED IN ("+ cCodVendedor +")"

				EndIf


				//===========================
				// prencho a variavel de log
				//===========================

				cLog += CRLF
				cLog += " >> QUERY Cemiterio: "
				cLog += CRLF
				cLog += cQuery
				cLog += CRLF
				cLog += CRLF

				cQuery := Changequery( cQuery )

				TcQuery cQuery New Alias "TRBCEM"

				// verifico se existem dados
				While TRBCEM->( !Eof() )

					// valor total
					aAdd( aContratos, { TRBCEM->U00_CODIGO, TRBCEM->U00_VALOR, TRBCEM->U00_CLIENT, TRBCEM->U00_LOJA } )

					TRBCEM->( DbSkip() )
				EndDo

				// se for por quantidade vendida eu pego a quantidade de contratos
				If cTpComissao == "2"

					// substituo o valor do retorno
					nRetorno := Len( aContratos )

				ElseIf cTpComissao == "3" // para valor recebido

					// percorro o array de contratos
					For nI := 1 To Len( aContratos )

						// incremento o nretorno apenas para o tipo de comissao 3 - valor vendido
						nRetorno += aContratos[nI,2]

					Next nI

				EndIf

			EndIf
		EndIf

		// para o modulo de funeraria
		If lFuneraria

			// verifico se o alias esta em uso
			If Select( "TRBFUN" ) > 0

				TRBFUN->( DbCloseArea() )

			EndIf

			cQuery := " SELECT "
			cQuery += " UF2.UF2_CODIGO, UF2.UF2_VALOR, UF2.UF2_CLIENT, UF2.UF2_LOJA "
			cQuery += " FROM " + RetSqlName("UF2") + " UF2
			cQuery += " WHERE UF2.D_E_L_E_T_ = ' '
			cQuery += " AND UF2.UF2_CODANT = ' ' "
			cQuery += " AND UF2.UF2_STATUS IN ('A','F') "

			// verifico se o ultimo fechamento esta preenchido
			If !Empty( cUltFechamento ) .And. !Empty( cAtuFechamento )

				cQuery += " AND UF2.UF2_DTATIV BETWEEN '" + cUltFechamento + "' AND '" + cAtuFechamento + "' "

			EndIf

			// verifico se tem lista de vendedores
			If !Empty( cCodVendedor )

				cQuery += " AND UF2.UF2_VEND IN (" + cCodVendedor + ")"

			EndIf

			//===========================
			// prencho a variavel de log
			//===========================

			cLog += CRLF
			cLog += " >> QUERY Funeraria : "
			cLog += CRLF
			cLog += cQuery
			cLog += CRLF
			cLog += CRLF

			cQuery := Changequery( cQuery )

			TcQuery cQuery New Alias "TRBFUN"

			// verifico se existem dados
			While TRBFUN->( !Eof() )

				// valor total
				aAdd( aContratos, { TRBFUN->UF2_CODIGO, TRBFUN->UF2_VALOR, TRBFUN->UF2_CLIENT, TRBFUN->UF2_LOJA } )

				// incremento o nretorno apenas para o tipo de comissao 3 - valor vendido
				nRetorno += TRBFUN->UF2_VALOR

				TRBFUN->( DbSkip() )
			EndDo

			// se for por quantidade vendida eu pego a quantidade de contratos
			If cTpComissao == "2"

				// substituo o valor do retorno
				nRetorno := Len( aContratos )

			EndIf
		EndIf

	// para o modulo de cemiterio
	ElseIf lCemiterio .And. cTipModulo == "C"

		// verifico se o alias esta em uso
		If Select( "TRBCEM" ) > 0

			TRBCEM->( DbCloseArea() )

		EndIf

		// para quando for quantidade vendida e valor vendido
		If cTpComissao $ "2/3"

			cQuery := " SELECT "
			cQuery += " U00.U00_CODIGO, U00.U00_VALOR, U00.U00_CLIENT, U00.U00_LOJA"
			cQuery += " FROM " + RetSqlName("U00") + " U00
			cQuery += " WHERE U00.D_E_L_E_T_ = ' '
			//cQuery += " AND U00.U00_CODANT = ' ' "
			cQuery += " AND U00.U00_STATUS IN ('A','F') "

			// verifico se o ultimo fechamento esta preenchido
			If !Empty( cUltFechamento ) .And. !Empty( cAtuFechamento )

				cQuery += " AND U00.U00_DTATIV BETWEEN '" + cUltFechamento + "' AND '" + cAtuFechamento + "' "

			EndIf

			cQuery += " AND U00.U00_VENDED = '" + cCodVendedor + "'"

			//===========================
			// prencho a variavel de log
			//===========================

			cLog += CRLF
			cLog += " >> QUERY Cemiterio: "
			cLog += CRLF
			cLog += cQuery
			cLog += CRLF
			cLog += CRLF

			cQuery := Changequery( cQuery )

			TcQuery cQuery New Alias "TRBCEM"

			// verifico se existem dados
			While TRBCEM->( !Eof() )

				// valor total
				aAdd( aContratos, { TRBCEM->U00_CODIGO, TRBCEM->U00_VALOR, TRBCEM->U00_CLIENT, TRBCEM->U00_LOJA } )

				TRBCEM->( DbSkip() )
			EndDo

			// se for por quantidade vendida eu pego a quantidade de contratos
			If cTpComissao == "2"

				// substituo o valor do retorno
				nRetorno := Len( aContratos )

			ElseIf cTpComissao == "3" // para valor recebido

				// percorro o array de contratos
				For nI := 1 To Len( aContratos )

					// incremento o nretorno apenas para o tipo de comissao 3 - valor vendido
					nRetorno += aContratos[nI,2]

				Next nI

			EndIf

		EndIf

	// para o modulo de funeraria
	ElseIf lFuneraria .And. cTipModulo == "F"

		// verifico se o alias esta em uso
		If Select( "TRBFUN" ) > 0

			TRBFUN->( DbCloseArea() )

		EndIf

		cQuery := " SELECT "
		cQuery += " UF2.UF2_CODIGO, UF2.UF2_VALOR, UF2.UF2_CLIENT, UF2.UF2_LOJA "
		cQuery += " FROM " + RetSqlName("UF2") + " UF2
		cQuery += " WHERE UF2.D_E_L_E_T_ = ' '
		cQuery += " AND UF2.UF2_STATUS IN ('A','F') "
		cQuery += " AND UF2.UF2_CODANT = ' ' "

		// verifico se o ultimo fechamento esta preenchido
		If !Empty( cUltFechamento ) .And. !Empty( cAtuFechamento )

			cQuery += " AND UF2.UF2_DTATIV BETWEEN '" + cUltFechamento + "' AND '" + cAtuFechamento + "' "

		EndIf

		cQuery += " AND UF2.UF2_VEND = '" + cCodVendedor + "'"

		//===========================
		// prencho a variavel de log
		//===========================

		cLog += CRLF
		cLog += " >> QUERY Funeraria : "
		cLog += CRLF
		cLog += cQuery
		cLog += CRLF
		cLog += CRLF

		cQuery := Changequery( cQuery )

		TcQuery cQuery New Alias "TRBFUN"

		// verifico se existem dados
		While TRBFUN->( !Eof() )

			// valor total
			aAdd( aContratos, { TRBFUN->UF2_CODIGO, TRBFUN->UF2_VALOR, TRBFUN->UF2_CLIENT, TRBFUN->UF2_LOJA } )

			// incremento o nretorno apenas para o tipo de comissao 3 - valor vendido
			nRetorno += TRBFUN->UF2_VALOR

			TRBFUN->( DbSkip() )
		EndDo

		// se for por quantidade vendida eu pego a quantidade de contratos
		If cTpComissao == "2"

			// substituo o valor do retorno
			nRetorno := Len( aContratos )

		EndIf

	EndIf

// verifico se existem dados na query de cemiterio
	If Select( "TRBCEM" ) > 0
		TRBCEM->( DbCloseArea() )
	EndIf

// verifico se existem dados na query de funeraria
	If Select( "TRBFUN" ) > 0
		TRBFUN->( DbCloseArea() )
	EndIf

	cLog += CRLF
	cLog += ">> Static Function DadosVendedor [FIM] : " + CRLF

	RestArea( aArea )

Return( nRetorno )

/*/{Protheus.doc} UTILE15A
Gera Comissao de Contrato Cemiterio
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
/*/

User Function UTILE15A( cContrato, cCodVendedor, nVlrCtr, cE3_PARCELA, cE3_SEQ, dE3_EMISSAO, cPrazo, nComissao,;
		nDiaFec, cPrefCtr, cTipoCtr, cTipoEnt, cCodCli, cLojaCli, cLog, lJob, cTipModulo, nPComis,;
		nParcelas, cTpComissao, nPerVend, dE3_VENCTO  )

	Local aArea				:= GetArea()
	Local aAreaSE3			:= SE3->( GetArea() )
	Local aAuto				:= {}
	Local lRetorno 			:= .T.
	Local cTipoE3			:= ""
	Local dE3_DATA			:= StoD("")
	Local lEntrada			:= .F. //controle de parcela de entrada

	Default cContrato		:= ""
	Default cCodVendedor	:= ""
	Default	nVlrCtr			:= 0
	Default cE3_PARCELA		:= ""
	Default cE3_SEQ			:= ""
	Default dE3_EMISSAO		:= StoD("")
	Default cPrazo			:= ""
	Default nComissao		:= 0
	Default nDiaFec			:= 0
	Default cPrefCtr 		:= ""
	Default cTipoCtr		:= ""
	Default cTipoEnt		:= ""
	Default cCodCli			:= ""
	Default cLojaCli		:= ""
	Default cLog			:= ""
	Default lJob			:= .F.
	Default cTipModulo		:= ""
	Default nPComis			:= 1
	Default nParcelas		:= 0
	Default cTpComissao		:= ""
	Default	nPerVend		:= 0
	Default dE3_VENCTO		:= StoD("")

	Private lMsErroAuto		:= .F.

	cLog += CRLF
	cLog += " >> UTILE15A [INICIO] - GERA A COMISSAO." + CRLF

	// defino o codigo do cliente
	If Empty( AllTrim(cCodCli) )
		cCodCli := GetMV("MV_CLIPAD")
	EndIf

	// defino a loja do cliente
	If Empty( Alltrim(cLojaCli) )
		cLojaCli := GetMV("MV_LOJAPAD")
	EndIf

	if ValType(dE3_EMISSAO) == "C"
        if "/" $ AllTrim(dE3_EMISSAO)
            dE3_EMISSAO := CtoD(dE3_EMISSAO) // dd/MM/aaaa
        else
            dE3_EMISSAO := SToD(dE3_EMISSAO) // aaaaMMdd
        endIf
	endIf

	// data de emissao
	if Month(dE3_EMISSAO) == 1 .And. Val(cPrazo) == 30 // mes da emissao janeiro e prazo de 30 dias
		dE3_DATA    := MonthSum(dE3_EMISSAO, 1) //data do possivel pagamento da comissão
	else
		dE3_DATA    := DaySum(dE3_EMISSAO, Val(cPrazo)) //data do possivel pagamento da comissão
	endIf

	// verifico se o vencimento ja esta preenchido
	If Empty( dE3_VENCTO )

		If Val(Day2Str(dE3_DATA)) <= nDiaFec

			//valido se o dia de fechamento e maior que o ultimo dia do mes
			if Val(Day2Str( LastDay(dE3_DATA) ) ) >= nDiaFec

				dE3_VENCTO := CtoD(PADL(nDiaFec,2,"0")+"/"+Month2Str(dE3_DATA)+"/"+Year2Str(dE3_DATA))

			else

				dE3_VENCTO := CtoD(PADL(cValToChar(LastDay(dE3_DATA)),2,"0")+"/"+Month2Str(dE3_DATA)+"/"+Year2Str(dE3_DATA))

			endif

		Else

			//valido se o dia de fechamento e maior que o ultimo dia do mes
			if Val(Day2Str( LastDay(MonthSum(dE3_DATA,1)) ) ) >= nDiaFec

				dE3_VENCTO := CtoD(PADL(nDiaFec,2,"0")+"/"+Month2Str(MonthSum(dE3_DATA,1))+"/"+Year2Str(MonthSum(dE3_DATA,1)))

			else

				dE3_VENCTO := CtoD(PADL(cValToChar(LastDay(MonthSum(dE3_DATA,1))),2,"0")+"/"+Month2Str(MonthSum(dE3_DATA,1))+"/"+Year2Str(MonthSum(dE3_DATA,1)))

			endif

		EndIf

	EndIf

	// vou validar se ja tem comissao gerada e baixada para o contrato
	nComissao := ValidaSE3( cCodVendedor, cContrato, cTipModulo, nComissao, nDiaFec )

	// verifico se tem comissao para ser gerada
	If nComissao <> 0

		aAuto := {}

		//verifico se gera parcela de entrada
		If lEntrada

			cTipoE3		:= cTipoEnt
			lEntrada	:= .F.

		else

			cTipoE3		:= cTipoCtr

		endif


		// coloco o valor do percentual conforme a base e o valor de comissao
		nPerVend	:= (nComissao/nVlrCtr)*100

		aAdd( aAuto, {"E3_VEND"		, cCodVendedor				, Nil } ) //Vendedor
		aAdd( aAuto, {"E3_NUM"		, cContrato					, Nil } ) //No. Titulo
		aAdd( aAuto, {"E3_EMISSAO"	, dE3_EMISSAO    			, Nil } ) //Data  de  emissão do título referente ao pagamento de comissão.
		aAdd( aAuto, {"E3_SERIE"	, ""						, Nil } ) //Serie N.F.
		aAdd( aAuto, {"E3_CODCLI"	, cCodCli					, Nil } ) //Cliente
		aAdd( aAuto, {"E3_LOJA"		, cLojaCli					, Nil } ) //Loja
		aAdd( aAuto, {"E3_BASE"		, nVlrCtr					, Nil } ) //Valor base do título para cálculo de comissão.
		aAdd( aAuto, {"E3_PORC"		, nPerVend					, Nil } ) //Percentual incidente ao valor do título para cálculo de comissão.
		aAdd( aAuto, {"E3_COMIS"	, nComissao					, Nil } ) //Valor da Comissão
		aAdd( aAuto, {"E3_PREFIXO"	, cPrefCtr					, Nil } ) //Prefixo
		aAdd( aAuto, {"E3_PARCELA"	, cE3_PARCELA				, Nil } ) //Parcela
		aAdd( aAuto, {"E3_SEQ"		, cE3_SEQ					, Nil } ) //Sequencia
		aAdd( aAuto, {"E3_TIPO"		, cTipoE3					, Nil } ) //Tipo do título que originou a comissão.
		aAdd( aAuto, {"E3_PEDIDO"	, ""						, Nil } ) //No. Pedido
		aAdd( aAuto, {"E3_VENCTO"	, dE3_VENCTO				, Nil } ) //Data de vencimento da comissão.
		aAdd( aAuto, {"E3_PROCCOM"	, ""						, Nil } ) //Proc. Com.
		aAdd( aAuto, {"E3_MOEDA"	, "01"						, Nil } ) //Moeda
		aAdd( aAuto, {"E3_CCUSTO"	, ""						, Nil } ) //Centro de Custo
		aAdd( aAuto, {"E3_BAIEMI"	, "E"						, Nil } ) //Comissao gerada: B - Pela Baixa ou E - Pela Emissão

		// caso for recebimento de motoqueiros
		If cTipModulo == "R"

			aAdd( aAuto, {"E3_ORIGEM"	, "B"						, Nil } ) //Origem da Comissao

		ElseIf cTipModulo == "G"

			aAdd( aAuto, {"E3_ORIGEM"	, "R"						, Nil } ) //Origem da Comissao

		Else // para emissao de contrato

			aAdd( aAuto, {"E3_ORIGEM"	, "E"						, Nil } ) //Origem da Comissao

		EndIf

		/*****************************************
		Origem do SE3
			"E" //Emissao Financeiro
			"B" //Baixa Financeiro
			"F" //Faturamento
			"D" //Devolucao de Venda
			"R" //Recalculo quando nao ha origem
			"L" //SigaLoja
			" " //Desconhecido
		*****************************************/

		// para contratos do moddulo de cemiterio
		If cTipModulo == "C"

			// quantidade de parcelas do contrato cemiterio
			nParcel	:= ParcelasContrato( cContrato )

			aAdd( aAuto, { "E3_XCONTRA"	, cContrato			,	Nil}) //Codigo do Contrato
			aAdd( aAuto, { "E3_XPARCON"	,Iif(nParcel>1, STRZERO(nParcel,tamsx3('E3_PARCELA')[1],0)+" X", "À VISTA"), Nil}) //Referencia do Parcelamento do Contrato
		
		ElseIf cTipModulo == "F" // para contratos do modulo de funeraria
		
			aAdd( aAuto, { "E3_XCTRFUN"	, cContrato			,	Nil}) //Codigo do Contrato
	
		EndIf

		//aAdd( aAuto, { "E3_XPARCON"	, Iif(nParcel>1, STRZERO(nParcel,tamsx3('E3_PARCELA')[1],0)+" X", "À VISTA"), Nil}) //Referencia do Parcelamento do Contrato
		aAdd( aAuto, { "E3_XPARCOM"	, cE3_PARCELA+"/"+STRZERO(nPComis,tamsx3('E3_PARCELA')[1],0), Nil}) //Referencia do Parcelamento da Comissao
		
		If SE3->( FieldPos("E3_XORIGEM") ) > 0
		
			aAdd(aAuto, {"E3_XORIGEM",cTipModulo,Nil})
			
			/*****************************************
			Origem do SE3
			"C" //Cemiterio (Contrato)
			"F" //Funeraria (Contrato)
			"R" //Recebimento de Cobranca (Motoqueiro)
			"V" //Venda Avulsa (Pedido de Venda e/ou Venda Direta)
			"G" //Comissão de Gerente e Supervisor
			*****************************************/
		EndIf

		//===========================
		// prencho a variavel de log
		//===========================

		cLog += CRLF
		cLog += "  >> ARRAY aAuto de Inclusao: " + CRLF + U_ToString(aAuto)
		cLog += CRLF
		
		SE3->( MSExecAuto({|x,y| Mata490(x,y)}, aAuto, 3) ) //Inclusão de Comissão
					
		If lMsErroAuto
		
			If !Empty( cLog )
			
			//===========================
			// prencho a variavel de log
			//===========================

           	cLog += MostraErro("\temp") + CRLF
			
			Else
			
				If !lJob
			
           		MostraErro()
		
				EndIf
			EndIf
			
    	//DisarmTransaction()
		lRetorno  := .F.

		Else

		//===========================
		// prencho a variavel de log
		//===========================

		cLog += CRLF
		cLog += " >> Comissao gerada com sucesso. "
		cLog += CRLF
		cLog += " >> CHAVE DA COMISSÃO GERADA: RECNO - " + PADL( cValToChar( SE3->( Recno() ) ) , 10 ) + CRLF
		cLog += "   >> E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND = " + SE3->E3_FILIAL + SE3->E3_PREFIXO + SE3->E3_NUM + SE3->E3_PARCELA + SE3->E3_SEQ + SE3->E3_VEND + CRLF
		cLog += "   >> VALOR DA BASE (R$)     = " + PADL(cValToChar(SE3->E3_BASE) , 10) + CRLF 
		cLog += "   >> PERCENTUAL  (%)        = " + PADL(cValToChar(SE3->E3_PORC) , 10) + CRLF
		cLog += "   >> VALOR DA COMISSAO (R$) = " + PADL(cValToChar(SE3->E3_COMIS) , 10) + CRLF
		cLog += CRLF

		EndIf

	Else

		cLog += CRLF
		cLog += " >> Comissao não foi gerada. "
		cLog += CRLF
		cLog += "Ja existe comissao em aberto para o codigo de vendedor."

	EndIf

cLog += CRLF
cLog += " >> UTILE15A [FIM] - GERA A COMISSAO." + CRLF

RestArea( aAreaSE3 )
RestArea( aArea )

Return( lRetorno )

/*/{Protheus.doc} UTILE15B
Gera Comissao de Contrato Cemiterio
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
@history 02/06/2020, g.sampaio, VPDV-473 - Feito ajuste para deletar apenas comissoes maiores que zero (E3_COMIS > 0)
/*/

User Function UTILE15B( cCodVendedor, nDiaFechamento, cTipModulo, cLog, cContrato )

	Local aArea				:= GetArea()
	Local aAreaSE3			:= SE3->( GetArea() )
	Local cQuery			:= ""
	Local cUltFechamento    := ""
	Local cAtuFechamento	:= ""
	Local lRetorno			:= .T.

	Private lMsErroAuto		:= .F.

	Default cCodVendedor    := ""
	Default nDiaFechamento  := 0
	Default cTipModulo		:= ""
	Default cLog			:= ""
	Default cContrato		:= ""

	cLog += CRLF
	cLog += "   >> UTILE15B [INICIO] EXCLUSÃO DAS COMISSÕES EXISTENTES..." + CRLF

	// faço o tratamento para a data do fechamento
	DataFechamento( nDiaFechamento, @cUltFechamento, @cAtuFechamento )

	If Select("TRBSE3") > 0
		TRBSE3->( DbCloseArea() )
	EndIf

	cQuery := " SELECT R_E_C_N_O_ RECSE3 FROM  " + RetSqlName("SE3") + " SE3 "
	cQuery += " WHERE SE3.D_E_L_E_T_ =  ' ' "
	cQuery += " AND SE3.E3_FILIAL = '" + xFilial("SE3") + "' "
	cQuery += " AND SE3.E3_VEND = '" + cCodVendedor + "'"
	cQuery += " AND SE3.E3_DATA = '' "
	cQuery += " AND SE3.E3_COMIS > 0 " // faco a exclusao apenas de comissao maior que zero
	cQuery += " AND SE3.E3_EMISSAO BETWEEN '" + cUltFechamento + "' AND '" + cAtuFechamento + "' "
	
	// verifico a origem da comissao
	If !Empty( cTipModulo )

		// verifico se tem contrato informado
		If !Empty( cContrato )

			If cTipModulo == "C" // cemiterio

				cQuery += " AND SE3.E3_XCONTRA = '" + cContrato + "' "

			ElseIf cTipModulo == "F" // funeraria

				cQuery += " AND SE3.E3_XCTRFUN = '" + cContrato + "' "

			EndIf

		EndIf

		cQuery	+= " AND SE3.E3_XORIGEM = '" + cTipModulo + "'"

	EndIf

	cQuery += " AND NOT EXISTS ( 
	cQuery += " SELECT R_E_C_N_O_ RECSE3 FROM  " + RetSqlName("SE3") + " SE3B "
	cQuery += " WHERE SE3B.D_E_L_E_T_ =  ' ' "
	cQuery += " AND SE3B.E3_FILIAL = '" + xFilial("SE3") + "' "
	cQuery += " AND SE3B.E3_VEND = '" + cCodVendedor + "'"
	cQuery += " AND SE3B.E3_DATA <> '' "
	cQuery += " AND SE3B.E3_COMIS > 0 " // faco a exclusao apenas de comissao maior que zero
	cQuery += " AND SE3B.E3_EMISSAO BETWEEN '" + cUltFechamento + "' AND '" + cAtuFechamento + "' "

	// verifico a origem da comissao
	If !Empty( cTipModulo )

		// verifico se tem contrato informado
		If !Empty( cContrato )

			If cTipModulo == "C" // cemiterio

				cQuery += " AND SE3B.E3_XCONTRA = '" + cContrato + "' "

			ElseIf cTipModulo == "F" // funeraria

				cQuery += " AND SE3B.E3_XCTRFUN = '" + cContrato + "' "

			EndIf

		EndIf

		cQuery	+= " AND SE3B.E3_XORIGEM = '" + cTipModulo + "'"

	EndIf

	cQuery += " )"

	//===========================
	// prencho a variavel de log
	//===========================

	cLog += CRLF
	cLog += " >> QUERY: "
	cLog += CRLF
	cLog += cQuery
	cLog += CRLF
	cLog += CRLF

	cQuery := Changequery(cQuery)

	TcQuery cQuery New Alias "TRBSE3"

	While TRBSE3->(!Eof())

		// posiciona no registro da SE3 para ser deletado
		SE3->( DbSetOrder(3) )
		SE3->( DbGoTo( TRBSE3->RECSE3 ) )

		aAuto := {}

		aAdd(aAuto, {"E3_VEND"		, SE3->E3_VEND		,Nil})
		aAdd(aAuto, {"E3_NUM" 		, SE3->E3_NUM		,Nil})
		aAdd(aAuto, {"E3_CODCLI"	, SE3->E3_CODCLI	,Nil})
		aAdd(aAuto, {"E3_LOJA"		, SE3->E3_LOJA		,Nil})
		aAdd(aAuto, {"E3_PREFIXO"	, SE3->E3_PREFIXO	,Nil})
		aAdd(aAuto, {"E3_PARCELA"	, SE3->E3_PARCELA	,Nil})
		aAdd(aAuto, {"E3_TIPO"		, SE3->E3_TIPO		,Nil})

		//===========================
		// prencho a variavel de log
		//===========================

		cLog += CRLF
		cLog += "  >> ARRAY aAuto de Exclusao: " + CRLF + U_ToString(aAuto)
		cLog += CRLF

		MSExecAuto({|x,y| Mata490(x,y)}, aAuto, 5) //Exclusão de Comissão

		If lMsErroAuto

			cLog 	+= MostraErro("\temp") + CRLF
			//DisarmTransaction()
			lRetorno := .F.
		Else
			cLog += CRLF
			cLog += " Comissão excluída com Sucesso!!! "
			cLog += CRLF
			cLog += " >> CHAVE DA COMISSÃO EXCLUIDA: RECNO - " + PADL(cValToChar(TRBSE3->RECSE3) , 10) + CRLF
			cLog += "   >> E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND = " + SE3->E3_FILIAL + SE3->E3_PREFIXO + SE3->E3_NUM + SE3->E3_PARCELA + SE3->E3_SEQ + SE3->E3_VEND + CRLF
			cLog += "   >> VALOR DA BASE (R$)     = " + PADL(cValToChar(SE3->E3_BASE) , 10) + CRLF
			cLog += "   >> PERCENTUAL  (%)        = " + PADL(cValToChar(SE3->E3_PORC) , 10) + CRLF
			cLog += "   >> VALOR DA COMISSAO (R$) = " + PADL(cValToChar(SE3->E3_COMIS) , 10) + CRLF
			cLog += CRLF
		EndIf

		TRBSE3->( DbSkip() )
	EndDo

	If Select("TRBSE3") > 0
		TRBSE3->( DbCloseArea() )
	EndIf

	cLog += CRLF
	cLog += "   >> UTILE15B [FIM] EXCLUSÃO DAS COMISSÕES EXISTENTES..." + CRLF

	RestArea( aAreaSE3 )
	RestArea( aArea )

Return( lRetorno )

/*/{Protheus.doc} UTILE15C
Funcao para gerar o estorno de comissao

@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
@history 27/05/2020, g.sampaio, VPDV-473 - feito o seek no cadastro do contrato 
cemiterio (U00) e funeraria (UF2)
- adicionado para o buscar o tipo e o prefixo de acordo com os parametros especificos
do modulo de cemiterio(MV_XTIPOCT, MV_XPREFCT, MV_XTIPOEN) ou funeraria(MV_XTIPFUN, MV_XPREFUN)
@history 20/08/2020, g.sampaio, VPDV-508 - Implementado o parametro MV_XESTCOM, para
habilitar e desabilitar o estonrno de comissao. 
/*/

User Function UTILE15C( cCodigoContrato, cTipModulo, cLog )

	Local aArea					:= GetArea()
	Local aAreaSA3				:= SA3->( GetArea() )
	Local aAreaSE3				:= SE3->( GetArea() )
	Local aAreaSA1				:= SA1->( GetArea() )
	Local aAreaU18				:= U18->( GetArea() )
	Local aAreaU00				:= {}
	Local aAreaUF2				:= {}
	Local aComissao				:= {}
	Local lRetorno				:= .T.
	Local lContinua				:= .T.
	Local cE3_PARCELA			:= ""
	Local cE3_SEQ				:= ""
	Local cTipoCem				:= SuperGetMv("MV_XTIPOCT",.F.,"AT")
	Local cTipoFun				:= SuperGetMv("MV_XTIPFUN",.F.,"AT")
	Local cTipoEnt				:= SuperGetMv("MV_XTIPOEN",.F.,"ENT")
	Local cPrefFun 				:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
	Local cPrefCem 				:= SuperGetMv("MV_XPREFCT",.F.,"CTR")
	Local lUsaEstornoComissao   := SuperGetMV("MV_XESTCOM",,.F.)
	Local nVlrComissao			:= 0
	Local nPerVend				:= 0
	Local nResultado			:= 0
	Local nI					:= 0

	Default cCodigoContrato	:= ""
	Default cTipModulo		:= ""
	Default cLog			:= ""

	cLog += CRLF
	cLog += " >> UTILE15C [INICIO] - ROTINA DE ESTORNO DE COMISSAO." + CRLF

	cE3_PARCELA := PADL('0',tamsx3('E3_PARCELA')[1],'0') 	// 	-> parcela
	cE3_SEQ		:= PADL('0',tamsx3('E3_SEQ')[1],'0')		//	-> sequencia

	// verifico se utilizo o estorno de comissao
	If lUsaEstornoComissao

		// para quando for contrato de cemiterio
		If cTipModulo == "C"

			cLog += " >> Contrato de Cemiterio : " + cCodigoContrato + CRLF

			// verifico se o alias temporario esta em uso
			If Select("TRBREC") > 0
				TRBREC->( DbCloseArea() )
			EndIf

			// query para descobrir as parcelas por contrato
			cQuery := " SELECT SUM(SE1.E1_VALOR - SE1.E1_SALDO + SE1.E1_ACRESC - SE1.E1_SDACRES - SE1.E1_DECRESC - SE1.E1_SDDECRE) CTRPAG, "
			cQuery += " (SELECT SUM(SE3.E3_COMIS) "
			cQuery += " FROM " + RetSqlName("SE3") + " SE3 "
			cQuery += " WHERE SE3.D_E_L_E_T_ = ' ' "
			cQuery += " AND SE3.E3_XCONTRA = U00.U00_CODIGO "
			cQuery += " AND SE3.E3_DATA <> ' ') COMPAG "
			cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
			cQuery += " INNER JOIN " + RetSqlName("U00") + " U00 "
			cQuery += " ON U00.U00_CODIGO = SE1.E1_XCONTRA "
			cQuery += " WHERE SE1.D_E_L_E_T_ =  ' ' "
			cQuery += " AND SE1.E1_PREFIXO = '" + cPrefCem + "' "
			cQuery += " AND SE1.E1_TIPO IN ('"+ cTipoCem +"','" + cTipoEnt + "') "
			cQuery += " AND SE1.E1_SALDO <> SE1.E1_VALOR "
			cQuery += " AND U00.D_E_L_E_T_ = ' ' "
			cQuery += " AND U00.U00_CODIGO = '" + cCodigoContrato + "' "
			cQuery += " GROUP BY U00.U00_CODIGO

			TcQuery cQuery New Alias "TRBREC"

			If TRBREC->(!Eof())

				// vejo a diferenca entre o valor de parcelas pagos e comissao pagas
				nResultado := TRBREC->CTRPAG - TRBREC->COMPAG

				cLog += ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + CRLF
				cLog += "Valor de Parcelas Pagas 		: " + Transform(TRBREC->CTRPAG,"@E 999,999,999.99") + CRLF
				cLog += "Valor de Comissao Paga 		: " + Transform(TRBREC->COMPAG,"@E 999,999,999.99") + CRLF
				cLog += "Saldo 							: " + Transform(nResultado,"@E 999,999,999.99") + CRLF
				cLog += ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + CRLF

			EndIf

			// verifico se o alias temporario esta em uso
			If Select("TRBREC") > 0
				TRBREC->( DbCloseArea() )
			EndIf

			// vejo se o cancelamento e antes da quantidade de dias limite
			If nResultado >= 0

				cLog += ">> Nao sera feito o estorno da comissao o valor pago é maior ou igual ao que o valor pago em comissao"

				// caso for maior que a quantidade de dias limite nao gera a comissao negativa
				lContinua 	:= .F.

				// retorno positino
				lRetorno	:= .T.

			EndIf

			// dou continuidade no processo
			If lContinua

				// salvo o ambiente da tabela de contratos
				aAreaU00 := U00->( GetAreA() )

				cLog += ">> Faco o estorno da comissao..."

				// posiciono no cadastro do vendedor
				U00->( DbSetOrder(1) )
				If U00->( MsSeek( xFilial("U00")+cCodigoContrato ) )

					//Posiciona no Vendedor
					SA3->( DbSetOrder(1) ) //A3_FILIAL+A3_COD
					If SA3->( MsSeek( xFilial("SA3")+U00->U00_VENDED ) )

						//Posiciona no Cliente/Loja
						SA1->( DbSetOrder(1) ) //A1_FILIAL+A1_COD+A1_LOJA
						If SA1->( MsSeek( xFilial("SA1")+U00->U00_CLIENT+U00->U00_LOJA ) )

							//Posiciona no Cliclo e Pgto de Comissão
							U18->( DbSetOrder(1) ) //U18_FILIAL+U18_CODIGO
							If U18->( MsSeek( xFilial("U18")+SA3->A3_XCICLO ) )

								// verifico se tem comissoes em no ciclo fechadas
								aComissao := DadosSE3( "C", cCodigoContrato, U18->U18_DIAFEC, U00->U00_DTATIV, @cLog )

							EndIf

						EndIf

					EndIf

				EndIf

				//===========================
				// prencho a variavel de log
				//===========================

				cLog += CRLF
				cLog += "  >> ARRAY aComissao de Estorno: " + CRLF + U_ToString(aComissao)
				cLog += CRLF

				// verifico se tem dados de dados de comissao
				If Len( aComissao ) > 0

					// percorro os registros de comissao
					For nI := 1 To Len( aComissao )

						// verifico se comissao ja foi paga
						If Empty(aComissao[nI,6]) .And. lContinua

							// deleto a comissao caso ela nao foi paga
							lContinua := U_UTILE15B( U00->U00_VENDED, U18->U18_DIAFEC, "C", @cLog, cCodigoContrato )

						EndIf

					Next nI

				Else // caso nao tenha dados de comissao

					lContinua	:= .F.

				EndIf

				// verifico se gero o estorno da comissao do contrato
				If lContinua

					// alimento as variaveis de sequencia e de parcela
					cE3_PARCELA		:= PADL( Len(aComissao)+1, tamsx3('E3_PARCELA')[1],'0')
					cE3_SEQ			:= "01"

					// incluo o estorno da comissao
					lContinua := U_UTILE15A( cCodigoContrato, U00->U00_VENDED, U00->U00_VALOR, cE3_PARCELA, cE3_SEQ, dDatabase, , nResultado,;
						U18->U18_DIAFEC, cPrefCem, cTipoCem, /*TipoEnt*/, U00->U00_CLIENT, U00->U00_LOJA, @cLog, /*lJob*/, "C", /*nPComis*/,;
						U00->U00_VALOR, /*cTpComissao*/, Round( ( nResultado / U00->U00_VALOR ) * 100, 2 ) )

				EndIf

				// atibuo o valor de lContinua para o retorno logico da rotina
				lRetorno := lContinua

				RestAreA( aAreaU00 )

			EndIf

		ElseIf cTipModulo == "F" // para quando for contrato de funeraria

			cLog += " >> Contrato de Funeraria : " + cCodigoContrato + CRLF

			// verifico se o alias temporario esta em uso
			If Select("TRBREC") > 0
				TRBREC->( DbCloseArea() )
			EndIf

			// query para descobrir as parcelas por contrato
			cQuery := " SELECT SUM(SE1.E1_VALOR - SE1.E1_SALDO + SE1.E1_ACRESC - SE1.E1_SDACRES - SE1.E1_DECRESC - SE1.E1_SDDECRE) CTRPAG, "
			cQuery += " (SELECT SUM(SE3.E3_COMIS) "
			cQuery += " FROM " + RetSqlName("SE3") + " SE3 "
			cQuery += " WHERE SE3.D_E_L_E_T_ = ' ' "
			cQuery += " AND SE3.E3_XCTRFUN = UF2.UF2_CODIGO "
			cQuery += " AND SE3.E3_DATA <> ' ') COMPAG "
			cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
			cQuery += " INNER JOIN " + RetSqlName("UF2") + " UF2 "
			cQuery += " ON UF2.UF2_CODIGO = SE1.E1_XCTRFUN
			cQuery += " WHERE SE1.D_E_L_E_T_ =  ' ' "
			cQuery += " AND SE1.E1_PREFIXO = '" + cPrefFun + "' "
			cQuery += " AND SE1.E1_TIPO IN ('" + cTipoFun + "') "
			cQuery += " AND SE1.E1_SALDO <> SE1.E1_VALOR "
			cQuery += " AND UF2.D_E_L_E_T_ = ' ' "
			cQuery += " AND UF2.UF2_CODIGO = '" + cCodigoContrato + "' "
			cQuery += " GROUP BY UF2.UF2_CODIGO

			TcQuery cQuery New Alias "TRBREC"

			If TRBREC->(!Eof())

				// vejo a diferenca entre o valor de parcelas pagos e comissao pagas
				nResultado := TRBREC->CTRPAG - TRBREC->COMPAG

				cLog += ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + CRLF
				cLog += "Valor de Parcelas Pagas 		: " + Transform(TRBREC->CTRPAG,"@E 999,999,999.99") + CRLF
				cLog += "Valor de Comissao Paga 		: " + Transform(TRBREC->COMPAG,"@E 999,999,999.99") + CRLF
				cLog += "Saldo 							: " + Transform(nResultado,"@E 999,999,999.99") + CRLF
				cLog += ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + CRLF

			EndIf

			// verifico se o alias temporario esta em uso
			If Select("TRBREC") > 0
				TRBREC->( DbCloseArea() )
			EndIf

			// vejo se o cancelamento e antes da quantidade de dias limite
			If nResultado > 0

				cLog += ">> Nao sera feito o estorno da comissao o valor pago é maior que o valor pago em comissao"

				// caso for maior que a quantidade de dias limite nao gera a comissao negativa
				lContinua 	:= .F.

				// retorno positivo para a rotina
				lRetorno	:= .T.

			EndIf

			// dou continuidade no processo
			If lContinua

				// salvo o ambiente da tabela de contratos
				aAreaUF2 := UF2->( GetAreA() )

				cLog += ">> Faco o estorno da comissao..."

				// posiciono no cadastro do vendedor
				UF2->( DbSetOrder(1) )
				If UF2->( MsSeek( xFilial("UF2")+cCodigoContrato ) )

					//Posiciona no Vendedor
					SA3->( DbSetOrder(1) ) //A3_FILIAL+A3_COD
					If SA3->( MsSeek( xFilial("SA3")+UF2->UF2_VEND ) )

						//Posiciona no Cliente/Loja
						SA1->( DbSetOrder(1) ) //A1_FILIAL+A1_COD+A1_LOJA
						If SA1->( MsSeek( xFilial("SA1")+UF2->UF2_CLIENT+UF2->UF2_LOJA ) )

							//Posiciona no Cliclo e Pgto de Comissão
							U18->( DbSetOrder(1) ) //U18_FILIAL+U18_CODIGO
							If U18->( MsSeek( xFilial("U18")+SA3->A3_XCICLO ) )

								// verifico se tem comissoes em no ciclo fechadas
								aComissao := DadosSE3( "F", cCodigoContrato, U18->U18_DIAFEC, UF2->UF2_DTATIV, @cLog )

							EndIf

						EndIf

					EndIf

				EndIf

				//===========================
				// prencho a variavel de log
				//===========================

				cLog += CRLF
				cLog += "  >> ARRAY aComissao de Estorno: " + CRLF + U_ToString(aComissao)
				cLog += CRLF

				// verifico se tem dados de comissao
				If Len( aComissao ) > 0

					// percorro os registros de comissao
					For nI := 1 To Len( aComissao )

						// verifico se comissao ja foi paga
						If Empty(aComissao[nI,6]) .And. lContinua

							// deleto a comissao caso ela nao foi paga
							lContinua := U_UTILE15B( UF2->UF2_VEND, U18->U18_DIAFEC, "F", @cLog, cCodigoContrato )

						EndIf

					Next nI

				Else // caso nao tenha dados

					lContinua := .F.

				EndIf

				// verifico se gero o estorno da comissao do contrato
				If lContinua

					// alimento as variaveis de sequencia e de parcela
					cE3_PARCELA		:= PADL( Len(aComissao)+1, tamsx3('E3_PARCELA')[1],'0')
					cE3_SEQ			:= "01"

					// incluo o estorno da comissao
					lContinua := U_UTILE15A( cCodigoContrato, UF2->UF2_VEND, UF2->UF2_VALOR, cE3_PARCELA, cE3_SEQ, dDatabase, , nResultado,;
						U18->U18_DIAFEC, cPrefFun, cTipoFun, /*TipoEnt*/, UF2->UF2_CLIENT, UF2->UF2_LOJA, @cLog, /*lJob*/, "F", /*nPComis*/,;
						UF2->UF2_VALOR, /*cTpComissao*/, Round( ( nResultado / UF2->UF2_VALOR ) * 100, 2 ) )

				EndIf

				// atibuo o valor de lContinua para o retorno logico da rotina
				lRetorno := lContinua

				RestArea( aAreaUF2 )

			EndIf

		EndIf

	endIf

	cLog += CRLF
	cLog += " >> UTILE15C [FIM] - ROTINA DE ESTORNO DE COMISSAO." + CRLF

	// verifico se ira gerar log
	If !Empty( cLog )

		// cria log de comissao
		CriaLogComissao( cLog )

	EndIf

	RestArea( aAreaU18 )
	RestArea( aAreaSA1 )
	RestArea( aAreaSA3 )
	RestArea( aAreaSE3 )
	RestArea( aArea )

Return( lRetorno )

/*/{Protheus.doc} DadosSE3
Pego os dados de comissao a serem gerados,
exceto estornos
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
@history 02/07/2020, g.sampaio, Issue VPDV-473 - manutencao na query para considerar apenas 
comissoes geradas e desconsiderar estorno de comissao.
/*/

Static Function DadosSE3( cTipModulo, cCodigoContrato, nDiaFec, dDataEmissao, cLog )

	Local aArea				:= GetArea()
	Local aAreaSE3			:= SE3->( GetArea() )
	Local aRetorno			:= {}
	Local cQuery 			:= ""
	Local cDataPassada		:= ""
	Local cDataAtual		:= ""
	Local cUltFechamento	:= ""
	Local cAtuFechamento	:= ""

	Default cTipModulo		:= ""
	Default cCodigoContrato	:= ""
	Default nDiaFec			:= 0
	Default dDataEmissao	:= StoD("")
	Default cLog			:= ""

	cLog += CRLF
	cLog += " Funcao DadosSE3 [INICIO] "

	// faço o tratamento para a data do fechamento
	DataFechamento( nDiaFec, @cUltFechamento, @cAtuFechamento, dDataEmissao )

	If Select("TRBSE3") > 0
		TRBSE3->( DbCloseArea() )
	EndIf

	cQuery := " SELECT SE3.E3_VEND VENDEDOR,
	cQuery += " SE3.E3_NUM NUMERO,
	cQuery += " SE3.E3_SEQ SEQ,
	cQuery += " SE3.E3_PARCELA PARC,
	cQuery += " SE3.E3_EMISSAO EMISSAO,
	cQuery += " SE3.E3_DATA CONFIRMADA,
	cQuery += " SE3.R_E_C_N_O_ RECSE3
	cQuery += " FROM " + RetSqlName("SE3") + " SE3
	cQuery += " WHERE SE3.D_E_L_E_T_ = ' '"
	cQuery += " AND SE3.E3_FILIAL = '" + xFilial("SE3") + "' "
	cQuery += " AND SE3.E3_EMISSAO BETWEEN '" + cUltFechamento + "' AND '" + cAtuFechamento + "' "

	If cTipModulo == "C"

		cQuery += " AND SE3.E3_XCONTRA = '" + cCodigoContrato + "'"

	ElseIf cTipModulo == "F"

		cQuery += " AND SE3.E3_XCTRFUN = '" + cCodigoContrato + "'"

	EndIf

	cQuery += " AND SE3.E3_COMIS > 0"

	cQuery += " AND NOT EXISTS ( 
	cQuery += " SELECT R_E_C_N_O_ RECSE3 FROM  " + RetSqlName("SE3") + " SE3B "
	cQuery += " WHERE SE3B.D_E_L_E_T_ =  ' ' "
	cQuery += " AND SE3B.E3_FILIAL = '" + xFilial("SE3") + "' "
	cQuery += " AND SE3B.E3_DATA <> '' "
	cQuery += " AND SE3B.E3_COMIS > 0 " // faco a exclusao apenas de comissao maior que zero
	cQuery += " AND SE3B.E3_EMISSAO BETWEEN '" + cUltFechamento + "' AND '" + cAtuFechamento + "' "

	// verifico a origem da comissao
	If !Empty( cTipModulo )

		// verifico se tem contrato informado
		If !Empty( cCodigoContrato )

			If cTipModulo == "C" // cemiterio

				cQuery += " AND SE3B.E3_XCONTRA = '" + cCodigoContrato + "' "

			ElseIf cTipModulo == "F" // funeraria

				cQuery += " AND SE3B.E3_XCTRFUN = '" + cCodigoContrato + "' "

			EndIf

		EndIf

		cQuery	+= " AND SE3B.E3_XORIGEM = '" + cTipModulo + "'"

	EndIf

	cQuery += " )"

	//===========================
	// prencho a variavel de log
	//===========================

	cLog += CRLF
	cLog += " >> QUERY Categoria: "
	cLog += CRLF
	cLog += cQuery
	cLog += CRLF
	cLog += CRLF

	cQuery := Changequery(cQuery)

	TcQuery cQuery New Alias "TRBSE3"

	While TRBSE3->( !Eof() )

		// pego o recno da SE3
		Aadd( aRetorno, { TRBSE3->RECSE3, TRBSE3->VENDEDOR, TRBSE3->NUMERO, TRBSE3->SEQ, TRBSE3->PARC, TRBSE3->CONFIRMADA } )

		TRBSE3->( DbSkip() )
	EndDo

	If Select("TRBSE3") > 0
		TRBSE3->( DbCloseArea() )
	EndIf

	cLog += CRLF
	cLog += " Funcao DadosSE3 [FIM] "

	RestArea( aAreaSE3 )
	RestArea( aArea )

Return( aRetorno )

/*/{Protheus.doc} CriaLogComissao
Funcao para criar o log de comissao
@author g.sampaio
@since 07/05/2019
@version P12
@param cTextoLog, caracter, texto da log a ser gerado
@return nulo
/*/

Static Function CriaLogComissao( cTextoLog )

	Local cDestinoDiretorio := ""
	Local cGeradoArquivo    := ""
	Local cArquivo          := "utile15c_logcomissao_" + CriaTrab(NIL, .F.) + ".txt"
	Local oWriter           := Nil

	Default cTextoLog       := ""

// vou gravar o log no diretorio de arquivos temporarios
	cDestinoDiretorio := GetTempPath()

// arquivo gerado no diretorio
	cGeradoArquivo := cDestinoDiretorio + iif( substr(alltrim(cDestinoDiretorio),len(alltrim(cDestinoDiretorio))) == iif(IsSrvUnix(),"/","\"),  cArquivo, iif(IsSrvUnix(),"/","\") + cArquivo )

// crio o objeto de escrita de arquivo
	oWriter := FWFileWriter():New( cGeradoArquivo, .T.)

// se houve falha ao criar, mostra a mensagem
	If !oWriter:Create()

		MsgStop("Houve um erro ao gerar o arquivo: " + CRLF + oWriter:Error():Message, "Atenção")

	Else// senão, continua com o processamento

		// escreve uma frase qualquer no arquivo
		oWriter:Write( cTextoLog + CRLF)

		// encerra o arquivo
		oWriter:Close()

	EndIf

Return()

/*/{Protheus.doc} ValidaSE3
funcao para validar se existe comissao gerada
@type function
@version 1.0
@author g.sampaio
@since 07/05/2019
@param cCodVendedor, character, codigo do vendedor
@param cContrato, character, codigo do contrato
@param cTipModulo, character, modulo que esta conferindo - F=Funeraria - C=Cemiterio
@param nComissao, numeric, valor de comissao
@param nDiaFec, numeric, dia de fechamento
@return numeric, retorno numerico caso exista comissao para o contrato eu zero a comissao
@history 24/05/2020, g.sampaio, ajuste na declarao do getarea e no cabecalho da funcao
/*/
Static Function ValidaSE3( cCodVendedor, cContrato, cTipModulo, nComissao, nDiaFec )

	Local aArea 			:= GetArea()
	Local cQuery 			:= ""
	Local cUltFechamento	:= ""
	Local cAtuFechamento	:= ""
	Local nRetorno			:= 0

	Default cCodVendedor	:= ""
	Default cContrato		:= ""
	Default cTipModulo		:= ""
	Default nComissao		:= 0
	Default nDiaFec			:= 0

	// faço o tratamento para a data do fechamento
	DataFechamento( nDiaFec, @cUltFechamento, @cAtuFechamento )

	// vou verificar se o alias esta em uso
	If Select("TRBSE3")
		TRBSE3->( DbCloseArea() )
	EndIf

	cQuery := " SELECT R_E_C_N_O_ RECSE3 FROM  " + RetSqlName("SE3") + " SE3 "
	cQuery += " WHERE SE3.D_E_L_E_T_ =  ' ' "
	cQuery += " AND SE3.E3_FILIAL = '" + xFilial("SE3") + "' "
	cQuery += " AND SE3.E3_VEND   = '" + cCodVendedor + "'"
	cQuery += " AND SE3.E3_DATA   <> '' "
	cQuery += " AND SE3.E3_EMISSAO BETWEEN '" + cUltFechamento + "' AND '" + cAtuFechamento + "'

	// verifico a origem da comissao
	If !Empty( cTipModulo )

		// verifico se tem contrato informado
		If !Empty( cContrato )

			If cTipModulo == "C" // cemiterio

				cQuery += " AND SE3.E3_XCONTRA = '" + cContrato + "' "

			ElseIf cTipModulo == "F" // funeraria

				cQuery += " AND SE3.E3_XCTRFUN = '" + cContrato + "' "

			EndIf

		EndIf

		cQuery	+= " AND SE3.E3_XORIGEM = '" + cTipModulo + "'"

	EndIf

	cQuery := Changequery( cQuery )

	TcQuery cQuery New Alias "TRBSE3"

	If TRBSE3->(!Eof())
		nComissao := 0
	EndIf

	// alimento a variavel de retorno
	nRetorno := nComissao

	RestArea( aArea )

Return( nRetorno )

/*/{Protheus.doc} UTILE15D
Funcao para enquadrar gerente e supervisor na categoria
@author g.sampaio
@since 25/07/2019
@version P12
@param cTextoLog, caracter, texto da log a ser gerado
@return nulo
/*/

User Function UTILE15D()

Return()

/*/{Protheus.doc} DadosRepresentante
Funcao para retornar os contratos de representante
@author g.sampaio
@since 29/07/2019
@version P12
@param cTextoLog, caracter, texto da log a ser gerado
@return nulo
/*/

Static Function DadosRepresentante( cTipModulo, cCodVendedor, cTpComissao, nDiaFec, cLog, cPrefCtr, cTipoCtr, cTipoEnt, cCodigoContrato )

	Local aRetorno 	:= {}
	Local cQuery 	:= ""

	Default cTipModulo      := ""
	Default cCodVendedor    := ""
	Default cTpComissao     := ""
	Default nDiaFec			:= 0
	Default cLog			:= ""
	Default cPrefCtr		:= ""
	Default cTipoCtr		:= ""
	Default cTipoEnt		:= ""
	Default cCodigoContrato	:= ""

// fecho o alias caso esteja em uso
	If Select("TRBREP") > 0
		TRBREP->( DbCloseArea() )
	EndIf

	If cTipModulo == "C" // para cemiterio

		// query para descobrir as parcelas por contrato
		cQuery := " SELECT U00.U00_CODIGO CODIGO, COUNT(*) AS QTDPAR
		cQuery += " FROM " + RetSqlName("SE1")  + " SE1
		cQuery += " INNER JOIN " + RetSqlName("U00")  + " U00
		cQuery += " ON U00.U00_CODIGO = SE1.E1_XCONTRA
		cQuery += " WHERE SE1.D_E_L_E_T_ =  ' '
		cQuery += " AND SE1.E1_PREFIXO = '" + cPrefCtr + "'
		cQuery += " AND SE1.E1_TIPO IN ('" + cTipoCtr + "','" + cTipoEnt + "')
		cQuery += " AND U00.D_E_L_E_T_ = ' '
		cQuery += " AND U00.U00_STATUS IN ('A','F')
		cQuery += " AND U00.U00_VENDED = '" + cCodVendedor + "'

		// verifio se tem codigo de contrato informado
		If !Empty( cCodigoContrato )
			cQuery += " AND U00.U00_CODIGO = '" + cCodigoContrato + "' "
		EndIf

		cQuery += " GROUP BY U00.U00_CODIGO"

	ElseIf cTipModulo == "F" // para funeraria

		// query para descobrir as parcelas por contrato
		cQuery := " SELECT UF2.UF2_CODIGO CODIGO, COUNT(*) AS QTDPAR
		cQuery += " FROM " + RetSqlName("SE1")  + " SE1
		cQuery += " INNER JOIN " + RetSqlName("UF2")  + " UF2
		cQuery += " ON UF2.UF2_CODIGO = SE1.E1_XCTRFUN
		cQuery += " WHERE SE1.D_E_L_E_T_ =  ' '
		cQuery += " AND SE1.E1_PREFIXO = '" + cPrefCtr + "'
		cQuery += " AND SE1.E1_TIPO IN ('" + cTipoCtr + "','" + cTipoEnt + "')
		cQuery += " AND UF2.D_E_L_E_T_ = ' '
		cQuery += " AND UF2.UF2_STATUS IN ('A','F')
		cQuery += " AND UF2.UF2_VEND = '" + cCodVendedor + "'

		// verifio se tem codigo de contrato informado
		If !Empty( cCodigoContrato )
			cQuery += " AND UF2.UF2_CODIGO = '" + cCodigoContrato + "' "
		EndIf

		cQuery += " GROUP BY UF2.UF2_CODIGO"

	EndIf

	TcQuery cQuery New Alias "TRBREP"

	While TRBREP->( !Eof() )

		// adiciono os contratos do vendedor, com a quantidade de parcelas do contrato
		aAdd( aRetorno, { TRBREP->CODIGO, TRBREP->QTDPAR } )

		TRBREP->( DbSkip() )
	EndDo

// fecho o alias caso esteja em uso
	If Select("TRBREP") > 0
		TRBREP->( DbCloseArea() )
	EndIf

Return( aRetorno )

/*/{Protheus.doc} DataFechamento
Funcao para o trataemtno da data de de fechamento
@author g.sampaio
@since 29/07/2019
@version P12
@param cTextoLog, caracter, texto da log a ser gerado
@return nulo
@histoy 27/05/2020, g.sampaio, VPDV-473 - adicionado o parametro dDataEmissao, 
para ser passado a data de referencia para a funcao. Valor default = dDatabase.
- implementado a variavel dDataEmissao aonde considerava o dDatabase.
/*/

Static Function DataFechamento( nDiaFechamento, cUltFechamento, cAtuFechamento, dDataEmissao )

	Local aArea 			:= GetArea()
	Local cDataAtual        := ""
	Local cDataPassada      := ""
	Local cDataFutura		:= ""
	Local nDiaFecIni		:= 0

	Default nDiaFechamento	:= 0
	Default cUltFechamento	:= ""
	Default cAtuFechamento	:= ""
	Default dDataEmissao	:= dDatabase

	// atualizo os dados de dados
	cDataAtual 		:= DtoS( dDataEmissao )
	cDataPassada	:= DtoS( MonthSub( dDataEmissao, 1 ) )
	cDataFutura 	:= DtoS( MonthSum( dDataEmissao, 1 ) )

	// verifico se dia do fechamento é igual a zero
	If nDiaFechamento == 0
		nDiaFechamento := Day(dDataEmissao)
	EndIf

	// tratamento para considerar a primeira data do fechamento
	If nDiaFechamento > Day( LastDay( dDataEmissao ) )
		nDiaFecIni := 1
	Else
		nDiaFecIni := nDiaFechamento
	EndIf

	// caso o dia do fechamento for do maior que o dia atual
	If nDiaFechamento >= Day(dDataEmissao)

		// pego a data do ultimo fechamento
		cUltFechamento := DtoS( Stod( SubStr( cDataPassada, 1, 6 ) + StrZero( nDiaFecIni, 2 ) ) ) 

		// monto a data do fechamento atual
		cAtuFechamento := DtoS( Stod( SubStr( cDataAtual, 1, 6 ) + StrZero( nDiaFechamento, 2 ) ) ) 

	Else// caso o dia do fechamento for do menor que o dia atual

		// pego a data do ultimo fechamento
		cUltFechamento := DtoS( Stod( SubStr( cDataAtual, 1, 6 ) + StrZero( nDiaFecIni, 2 ) ) )

		// monto a data do fechamento atual
		cAtuFechamento := DtoS( Stod( SubStr( cDataFutura, 1, 6 ) + StrZero( nDiaFechamento, 2 ) ) ) 

	EndIf

	RestArea( aArea )

Return( Nil )

/*/{Protheus.doc} ContaParcelas
conta a quantida de parcelas
@author g.sampaio
@since 02/09/2019
@version P12
@param cTextoLog, caracter, texto da log a ser gerado
@return nulo
/*/

Static Function ContaParcelas( cCategoria, cCondicao )

	Local aArea			:= GetArea()
	Local cQuery		:= ""
	Local nRetorno 		:= 0

	Default cCategoria	:= ""
	Default cCondicao	:= ""

	If Select("TRBCONT") > 0
		TRBCONT->( DbCloseArea() )
	EndIf

	cQuery := " SELECT"
	cQuery += " COUNT(*) CONTAPARC"
	cQuery += " FROM " + RetSqlName("U15") + " U15 "
	cQuery += " INNER JOIN " + RetSqlName("U16") + " U16 "
	cQuery += " ON U16.U16_FILIAL = U15.U15_FILIAL "
	cQuery += " AND U16.U16_CATEGO = U15.U15_CODIGO "
	cQuery += " INNER JOIN " + RetSqlName("U17") + " U17 "
	cQuery += " ON U17.U17_FILIAL = U15.U15_FILIAL "
	cQuery += " AND U17.U17_CATEGO = U15.U15_CODIGO "
	cQuery += " AND U17.U17_CONDIC = U16.U16_CODIGO "
	cQuery += " WHERE U15.D_E_L_E_T_ = ' ' "
	cQuery += " AND U17.D_E_L_E_T_ = ' ' "
	cQuery += " AND U16.D_E_L_E_T_ = ' ' "
	cQuery += " AND U15.U15_FILIAL = '" + xFilial("U15") + "' "
	cQuery += " AND U15.U15_CODIGO = '" + cCategoria + "' "
	cQuery += " AND U16.U16_CODIGO = '" + cCondicao + "'"

	TcQuery cQuery New Alias "TRBCONT"

	If TRBCONT->( !Eof() )
		nRetorno	:= TRBCONT->CONTAPARC
	EndIf

	RestArea( aArea )

Return( nRetorno )

/*/{Protheus.doc} ParcelasContrato
conta a quantida de parcelas a receber do contrato
@author g.sampaio
@since 02/09/2019
@version P12
@param cTextoLog, caracter, texto da log a ser gerado
@return nulo
/*/

Static Function ParcelasContrato( cContrato )

	Local aArea 	:= GetArea()
	Local cQuery	:= ""
	Local cPrefCtr	:= SuperGetMv("MV_XPREFCT",.F.,"CTR")
	Local nRetorno	:= 0

	Default cContrato	:= ""

	If Select("TRBTIT") > 0
		TRBTIT->( DbCloseArea() )
	EndIf

	cQuery := " SELECT COUNT(*) CONTATIT FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
	cQuery += " AND SE1.E1_PREFIXO = '" + cPrefCtr + "' "
	cQuery += " AND SE1.E1_XCONTRA = '" + cContrato + "'"

	TcQuery cQuery New Alias "TRBTIT"

	If TRBTIT->( !Eof() )
		nRetorno := TRBTIT->CONTATIT
	EndIf

	If Select("TRBTIT") > 0
		TRBTIT->( DbCloseArea() )
	EndIf

	RestArea( aArea )


Return( nRetorno )
