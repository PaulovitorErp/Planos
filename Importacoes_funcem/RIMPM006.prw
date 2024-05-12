#Include "protheus.CH"
#include "topconn.ch"

/*/{Protheus.doc} RIMPM004
Rotina de Processamento de Importacoes 
de Titulos a Receber
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RIMPM006(aTitulos,nHdlLog)

	Local aArea 		:= GetArea()
	Local aAreaSE1		:= SE1->(GetArea())
	Local aRatNat		:= {}
	Local aDadosTit		:= {}
	Local aLinhaTit		:= {}
	Local aAuxEV		:= {}
	Local aRatEv		:= {}
	Local cRatNat01		:= ""
	Local cRatNat02		:= ""
	Local cRatNat03		:= ""
	Local cRatNat04		:= ""
	Local cRatNat05		:= ""
	Local cRatNat06		:= ""
	Local cRatNat07		:= ""
	Local cRatNat08		:= ""
	Local cRatNat09		:= ""
	Local cRatNat10		:= ""
	Local nRatVal01		:= 0
	Local nRatVal02		:= 0
	Local nRatVal03		:= 0
	Local nRatVal04		:= 0
	Local nRatVal05		:= 0
	Local nRatVal06		:= 0
	Local nRatVal07		:= 0
	Local nRatVal08		:= 0
	Local nRatVal09		:= 0
	Local nRatVal10		:= 0
	Local lRet			:= .F.
	Local lAtivMultNat	:= SuperGetMV("MV_XMULNPA",.F.,.F.)	// rateio de multiplas naturezas virtus
	Local lMulNatR		:= SuperGetMV("MV_MULNATR",.F.,.F.)	// rateio de multiplas naturezas padrão
	Local nI			:= 0
	Local nX			:= 0
	Local nJ			:= 0
	Local nPosDtBx		:= 0
	Local nPosNumBco	:= 0
	Local nPosBanco		:= 0
	Local nPosAgencia	:= 0
	Local nPosConta		:= 0
	Local nPosLiquida	:= 0
	Local nPosCtrCem	:= 0
	Local nPosCtrFun	:= 0
	Local nVlrBaixa		:= 0
	Local nPosTipoTit	:= 0
	Local nPosPrefTit	:= 0
	Local nPosParcela	:= 0
	Local nImpSucesso	:= 0
	Local nPosConval	:= 0
	Local nPosNat01		:= 0
	Local nPosNat02		:= 0
	Local nPosNat03		:= 0
	Local nPosNat04		:= 0
	Local nPosNat05		:= 0
	Local nPosNat06		:= 0
	Local nPosNat07		:= 0
	Local nPosNat08		:= 0
	Local nPosNat09		:= 0
	Local nPosNat10		:= 0
	Local nPosVal01		:= 0
	Local nPosVal02		:= 0
	Local nPosVal03		:= 0
	Local nPosVal04		:= 0
	Local nPosVal05		:= 0
	Local nPosVal06		:= 0
	Local nPosVal07		:= 0
	Local nPosVal08		:= 0
	Local nPosVal09		:= 0
	Local nPosVal10		:= 0
	Local nPosValTit	:= 0
	Local nRatVal01		:= 0
	Local nRatVal02		:= 0
	Local nRatVal03		:= 0
	Local nRatVal04		:= 0
	Local nRatVal05		:= 0
	Local nRatVal06		:= 0
	Local nRatVal07		:= 0
	Local nRatVal08		:= 0
	Local nRatVal09		:= 0
	Local nRatVal10		:= 0
	Local nValorTitulo	:= 0
	Local nJuros		:= SuperGetMV("MV_TXPER",,0)
	Local nMulta		:= SuperGetMV("MV_LJMULTA",,0)
	Local cErroExec		:= ""
	Local cNossoNumero	:= ""
	Local cBanco		:= ""
	Local cAgencia		:= ""
	Local cConta		:= ""
	Local cCtrCem		:= ""
	Local cCtrFun		:= ""
	Local cTipoTit		:= ""
	Local cPrefTit		:= ""
	Local cCodConval	:= ""
	Local cParcela		:= ""
	Local dDataBaixa	:= STOD(Space(8))
	Local cPulaLinha	:= Chr(13) + Chr(10)
	Local cDirLogServer	:= ""
	Local cArqLog		:= "log_imp.log"

	// variavel interna da rotina automatica
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.

	//diretorio no server que sera salvo o retorno do execauto
	cDirLogServer := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	cDirLogServer += If(Right(cDirLogServer, 1) <> "\", "\", "")

	SetFunName("FINA040")

	For nX := 1 To Len(aTitulos)

		Begin Transaction

			aLinhaTit	:= aClone(aTitulos[nX])
			aDadosTit	:= {}

			//busco as posicoes de id titulo, dt baixa e nosso numero
			nPosDtBx		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "E1_BAIXA"})
			nPosNumBco		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "E1_NUMBCO"})
			nPosBanco		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "E1_PORTADO"})
			nPosAgencia		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "E1_AGEDEP"})
			nPosConta		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "E1_CONTA"})
			nPosLiquida		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "E1_VALLIQ"})
			nPosCtrCem		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "E1_XCONTRA"})
			nPosCtrFun		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "E1_XCTRFUN"})
			nPosTipoTit		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "E1_TIPO"})
			nPosPrefTit		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "E1_PREFIXO"})
			nPosParcela		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "E1_PARCELA"})
			nPosConval		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "COD_ANT"})
			nPosValTit		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "E1_VALOR"})

			// rateio de multiplas naturezas
			if lAtivMultNat .And. lMulNatR

				// posicao dos campos de natureza
				nPosNat01		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "NATUREZA01"})
				nPosNat02		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "NATUREZA02"})
				nPosNat03		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "NATUREZA03"})
				nPosNat04		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "NATUREZA04"})
				nPosNat05		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "NATUREZA05"})
				nPosNat06		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "NATUREZA06"})
				nPosNat07		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "NATUREZA07"})
				nPosNat08		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "NATUREZA08"})
				nPosNat09		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "NATUREZA09"})
				nPosNat10		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "NATUREZA10"})

				// posicao dos campos de valor
				nPosVal01		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "VALOR01"})
				nPosVal02		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "VALOR02"})
				nPosVal03		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "VALOR03"})
				nPosVal04		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "VALOR04"})
				nPosVal05		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "VALOR05"})
				nPosVal06		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "VALOR06"})
				nPosVal07		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "VALOR07"})
				nPosVal08		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "VALOR08"})
				nPosVal09		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "VALOR09"})
				nPosVal10		:= AScan(aLinhaTit,{|x| AllTrim(x[1]) == "VALOR10"})

			endIf

			//importo apenas Titulos com chave no layout
			if nPosPrefTit > 0 .And. nPosTipoTit > 0 .And. nPosParcela > 0 .And. ( nPosCtrCem > 0 .Or. nPosCtrFun > 0 )

				SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_TIPO

				//verifico se as posicoes foram preenchidas no layout de importacao

				//Data de Baixa do Titulo
				if nPosDtBx > 0
					dDataBaixa 		:= aLinhaTit[nPosDtBx,2]
				endif

				//Nosso Numero do Titulo
				if nPosNumBco > 0
					cNossoNumero	:= Alltrim(aLinhaTit[nPosNumBco,2])
				endif

				//Banco
				if nPosBanco > 0
					cBanco			:= Padr(Alltrim(aLinhaTit[nPosBanco,2]),TamSX3("A6_COD")[1])
				endif

				//Agencia
				if nPosAgencia > 0
					cAgencia		:= Padr(Alltrim(aLinhaTit[nPosAgencia,2]),TamSX3("A6_AGENCIA")[1])
				endif

				//Conta
				if nPosConta > 0
					cConta			:= Padr(Alltrim(aLinhaTit[nPosConta,2]),TamSX3("A6_NUMCON")[1])
				endif

				//Valor de Baixa
				if nPosLiquida > 0
					nVlrBaixa		:= aLinhaTit[nPosLiquida,2]
				endif

				//Codigo do Contrato Cemiterio
				if nPosCtrCem > 0
					cCtrCem			:= Alltrim(aLinhaTit[nPosCtrCem,2])
				endif

				//Codigo do Contrato Funeraria
				if nPosCtrFun > 0
					cCtrFun			:= Alltrim(aLinhaTit[nPosCtrFun,2])
				endif

				//Tipo do Titulo
				if nPosTipoTit > 0
					cTipoTit		:= Alltrim(aLinhaTit[nPosTipoTit,2])
				endif

				//Prefixo do Titulo
				if nPosPrefTit > 0
					cPrefTit		:= Alltrim(aLinhaTit[nPosPrefTit,2])
				endif

				//Codigo Convalescengte
				if nPosConval > 0
					cCodConval		:= Alltrim(aLinhaTit[nPosConval,2])
				endif

				//Parcela do Titulo
				if nPosParcela > 0
					cParcela 		:= PadR(Alltrim(aLinhaTit[nPosParcela,2]),TamSX3("E1_PARCELA")[1])
				endif

				if nPosValTit > 0
					nValorTitulo := aLinhaTit[nPosValTit,2]
				endIf

				//===================================================
				// Rateio de multiplas naturezas - Naturezas
				//===================================================

				// posicao do rateio de natureza 1
				if nPosNat01 > 0
					cRatNat01	:= PadR(Alltrim(aLinhaTit[nPosNat01,2]),TamSX3("E1_NATUREZA")[1])
				endIf

				// posicao do rateio de natureza 2
				if nPosNat02 > 0
					cRatNat02	:= PadR(Alltrim(aLinhaTit[nPosNat02,2]),TamSX3("E1_NATUREZA")[1])
				endIf

				// posicao do rateio de natureza 3
				if nPosNat03 > 0
					cRatNat03	:= PadR(Alltrim(aLinhaTit[nPosNat03,2]),TamSX3("E1_NATUREZA")[1])
				endIf

				// posicao do rateio de natureza 4
				if nPosNat04 > 0
					cRatNat04	:= PadR(Alltrim(aLinhaTit[nPosNat04,2]),TamSX3("E1_NATUREZA")[1])
				endIf

				// posicao do rateio de natureza 5
				if nPosNat05 > 0
					cRatNat05	:= PadR(Alltrim(aLinhaTit[nPosNat05,2]),TamSX3("E1_NATUREZA")[1])
				endIf

				// posicao do rateio de natureza 6
				if nPosNat06 > 0
					cRatNat06	:= PadR(Alltrim(aLinhaTit[nPosNat06,2]),TamSX3("E1_NATUREZA")[1])
				endIf

				// posicao do rateio de natureza 7
				if nPosNat07 > 0
					cRatNat07	:= PadR(Alltrim(aLinhaTit[nPosNat07,2]),TamSX3("E1_NATUREZA")[1])
				endIf

				// posicao do rateio de natureza 8
				if nPosNat08 > 0
					cRatNat08	:= PadR(Alltrim(aLinhaTit[nPosNat08,2]),TamSX3("E1_NATUREZA")[1])
				endIf

				// posicao do rateio de natureza 9
				if nPosNat09 > 0
					cRatNat09	:= PadR(Alltrim(aLinhaTit[nPosNat09,2]),TamSX3("E1_NATUREZA")[1])
				endIf

				// posicao do rateio de natureza 10
				if nPosNat10 > 0
					cRatNat10	:= PadR(Alltrim(aLinhaTit[nPosNat10,2]),TamSX3("E1_NATUREZA")[1])
				endIf

				//===================================================
				// Rateio de multiplas naturezas - Valores
				//===================================================

				// posicao do rateio de natureza 1
				if nPosVal01 > 0
					nRatVal01	:= aLinhaTit[nPosVal01,2]
				endIf

				// posicao do rateio de natureza 2
				if nPosVal02 > 0
					nRatVal02	:= aLinhaTit[nPosVal02,2]
				endIf

				// posicao do rateio de natureza 3
				if nPosVal03 > 0
					nRatVal03	:= aLinhaTit[nPosVal03,2]
				endIf

				// posicao do rateio de natureza 4
				if nPosVal04 > 0
					nRatVal04	:= aLinhaTit[nPosVal04,2]
				endIf

				// posicao do rateio de natureza 5
				if nPosVal05 > 0
					nRatVal05	:= aLinhaTit[nPosVal05,2]
				endIf

				// posicao do rateio de natureza 6
				if nPosVal06 > 0
					nRatVal06	:= aLinhaTit[nPosVal06,2]
				endIf

				// posicao do rateio de natureza 7
				if nPosVal07 > 0
					nRatVal07	:= aLinhaTit[nPosVal07,2]
				endIf

				// posicao do rateio de natureza 8
				if nPosVal08 > 0
					nRatVal08	:= aLinhaTit[nPosVal08,2]
				endIf

				// posicao do rateio de natureza 9
				if nPosVal09 > 0
					nRatVal09	:= aLinhaTit[nPosVal09,2]
				endIf

				// posicao do rateio de natureza 10
				if nPosVal10 > 0
					nRatVal10	:= aLinhaTit[nPosVal10,2]
				endIf

				//valido se o titulo esta vinculado a contrato cemiterio ou funeraria e vinculo os dados do titulo
				lRet := ValidaChave(cCtrCem,cCtrFun,@aDadosTit,cTipoTit,cPrefTit,cParcela,nHdlLog,cCodConval)

				if lRet

					DbSelectArea("SE1")
					SE1->( DbSetOrder(1) ) //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO

					//valido se o nosso numero esta duplicado
					if !Empty(cNossoNumero)

						lRet := VldNossoNumero(cBanco,cAgencia,cConta,cNossoNumero,nHdlLog)

					endif

					if lRet

						//monto array com os dados do cliente
						For nJ := 1 To Len(aLinhaTit)

							//nao preencho os campos de contrato, pois sao preenchidos pela funcao VinculaCtr e campos de Banco
							if Alltrim(aLinhaTit[nJ,1]) <> "E1_XCTRFUN" .And. Alltrim(aLinhaTit[nJ,1]) <> "E1_XCONTRA" .And.;
									Alltrim(aLinhaTit[nJ,1]) <> "E1_PORTADO" .And. Alltrim(aLinhaTit[nJ,1]) <> "E1_AGEDEP" .And.;
									Alltrim(aLinhaTit[nJ,1]) <> "E1_CONTA" .And. !("NATUREZA" $ Alltrim(aLinhaTit[nJ,1])) .And. !("VALOR" $ Alltrim(aLinhaTit[nJ,1]) .And. Alltrim(aLinhaTit[nJ,1]) <> "E1_VALOR" )

								aAdd(aDadosTit, {Alltrim(aLinhaTit[nJ,1]),	aLinhaTit[nJ,2],NIL})

							endif

						Next nJ

						if lMulNatR .And. lAtivMultNat

							if !Empty(cRatNat01)
								aAdd(aRatNat, { cRatNat01, nRatVal01 })
							endIf

							if !Empty(cRatNat02)
								aAdd(aRatNat, { cRatNat02, nRatVal02 })
							endIf

							if !Empty(cRatNat03)
								aAdd(aRatNat, { cRatNat03, nRatVal03 })
							endIf

							if !Empty(cRatNat04)
								aAdd(aRatNat, { cRatNat04, nRatVal04 })
							endIf

							if !Empty(cRatNat05)
								aAdd(aRatNat, { cRatNat05, nRatVal05 })
							endIf

							if !Empty(cRatNat06)
								aAdd(aRatNat, { cRatNat06, nRatVal06 })
							endIf

							if !Empty(cRatNat07)
								aAdd(aRatNat, { cRatNat07, nRatVal07 })
							endIf

							if !Empty(cRatNat08)
								aAdd(aRatNat, { cRatNat08, nRatVal08 })
							endIf

							if !Empty(cRatNat09)
								aAdd(aRatNat, { cRatNat09, nRatVal09 })
							endIf

							if !Empty(cRatNat10)
								aAdd(aRatNat, { cRatNat10, nRatVal10 })
							endIf

						endIf

						// verifico se tenho dados para o rateio de multiplas naturezas
						if Len(aRatNat) > 0

							aAdd(aDadosTit, {"E1_MULTNAT"	, "1"	,NIL})

							for nI := 1 to Len(aRatNat)
								aAuxEv := {}
								aAdd( aAuxEV, {"EV_NATUREZ"	, aRatNat[nI, 1], Nil })
								aAdd( aAuxEV, {"EV_VALOR"	, aRatNat[nI, 2], Nil })
								aAdd( aAuxEV, {"EV_PERC"	, (aRatNat[nI, 2]/nValorTitulo)*100, Nil })
								aAdd( aRatEv, aAuxEv )
							next nI

						endIf

						//para inclusao de titulos que possue banco vinculado e necessario posicionar na SA6
						if !Empty(cBanco)

							SA6->(DbSetOrder(1)) //A6_FILIAL + A6_COD + A6_AGENCIA + A6_NUMCON

							if SA6->(DbSeek(xFilial("SA6") + cBanco + cAgencia + cConta ))

								aAdd(aDadosTit, {"E1_PORTADO"	, SA6->A6_COD		,NIL})
								aAdd(aDadosTit, {"E1_AGEDEP"	, SA6->A6_AGENCIA	,NIL})
								aAdd(aDadosTit, {"E1_CONTA"		, SA6->A6_NUMCON	,NIL})

							endif

						endif

						//incluo o titulo a receber
						if Len(aRatEv) > 0 // para quando houver rateio de multiplas naturezas
							MSExecAuto({|x,y,z,a| FINA040(x,y,z,a)},aDadosTit,3,,aRatEv)
						else
							MSExecAuto({|x,y| FINA040(x,y)},aDadosTit,3)
						endIf

						If lMsErroAuto

							lRet := .F.

							//verifico se arquivo de log existe
							if nHdlLog > 0

								cErroExec := MostraErro(cDirLogServer, cArqLog)

								FErase(cDirLogServer + cArqLog )

								fWrite(nHdlLog , "Erro na Inclusao do Titulo:" )

								fWrite(nHdlLog , cPulaLinha )

								fWrite(nHdlLog , cErroExec )

								fWrite(nHdlLog , cPulaLinha )

							endif

							DisarmTransaction()
							SA1->( RollBackSX8() )

						else

							//verifico se o titulo esta baixado
							if !Empty(dDataBaixa) 

								if nJuros == 0 .And. nMulta == 0

									lRet := RealizaBx(SE1->(Recno()),dDataBaixa,nVlrBaixa,nHdlLog)

								else

									lRet := .F.

									//verifico se arquivo de log existe
									if nHdlLog > 0

										fWrite(nHdlLog , "Para importacao de Titulos, os parametros MV_TXPER e MV_LJMULTA devem ser zerados!" )
										fWrite(nHdlLog , cPulaLinha )

									endif

								endif

							endif

							//valido se possui banco e nosso numero preenchido para gerar bordero e id cnab
							if lRet

								if !Empty(cBanco) .And. !Empty(cAgencia) .And. !Empty(cConta) .And. !Empty(cNossoNumero)

									GeraBordero(SE1->(Recno()),cBanco,cAgencia,cConta,cNossoNumero)

								endif

								nImpSucesso++

							endif


						endif

						lMsErroAuto := .F.
						lMsHelpAuto := .F.

					endif

				endif

			else

				lRet := .F.

				//verifico se arquivo de log existe
				if nHdlLog > 0

					fWrite(nHdlLog , "Layout de importação não possui campo(s) Chave do Titulo, a definição do mesmo é obrigatória!" )

					fWrite(nHdlLog , cPulaLinha )

				endif

			endif

		End Transaction

		if !lRet
			Exit
		endif

	Next nX


	//verifico se arquivo de log existe
	if nHdlLog > 0

		fWrite(nHdlLog , "Titulos Importados com sucesso: " + cValToChar(nImpSucesso) + " !" )

		fWrite(nHdlLog , cPulaLinha )

	endif


	RestArea(aArea)
	RestArea(aAreaSE1)

Return(lRet)

/*/{Protheus.doc} RealizaBx
Funcao que realiza a baixa do titulo
importado
@author Raphael Martins
@since 13/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function RealizaBx(nRecno,dDataBaixa,nVlrBaixa,nHdlLog)

	Local aArea 		:= GetArea()
	Local aAreaSE1		:= SE1->(GetArea())
	Local aBaixa		:= {}
	Local nDesconto		:= 0
	Local nJuros		:= 0
	Local lRet			:= .T.
	Local cPulaLinha	:= Chr(13) + Chr(10)
	Local cDirLogServer	:= ""
	Local cArqLog		:= "log_imp_baixa.log"
	Local cMotBaixa 	:= SuperGetMV("MV_XMOTBXI",,"DAC")

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.

	SE1->(DbGoto(nRecno))

	//diretorio no server que sera salvo o retorno do execauto
	cDirLogServer := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	cDirLogServer += If(Right(cDirLogServer, 1) <> "\", "\", "")

	//caso a data da baixa seja futura, a mesma deve ser prenchda com a data atual
	dDataBaixa := If( dDataBaixa > dDataBase, dDataBase, dDataBaixa )

	//Valida se houve desconto ou juros no titulos a ser baixado
	if SE1->E1_VALOR > nVlrBaixa

		nDesconto := SE1->E1_VALOR - nVlrBaixa

	elseif SE1->E1_VALOR < nVlrBaixa

		nJuros := nVlrBaixa - SE1->E1_VALOR

	endif

	aBaixa := {	{"E1_PREFIXO"   ,SE1->E1_PREFIXO		 ,Nil},;
		{"E1_NUM"       ,SE1->E1_NUM			 ,Nil},;
		{"E1_PARCELA"   ,SE1->E1_PARCELA		 ,Nil},;
		{"E1_TIPO"      ,SE1->E1_TIPO			 ,Nil},;
		{"E1_CLIENTE" 	,SE1->E1_CLIENTE 		 ,Nil},;
		{"E1_LOJA" 		,SE1->E1_LOJA 			 ,Nil},;
		{"AUTMOTBX"     ,cMotBaixa				 ,Nil},;
		{"AUTDTBAIXA"   ,dDataBaixa				 ,Nil},;
		{"AUTDTCREDITO" ,dDataBaixa				 ,Nil},;
		{"AUTHIST"      ,"BAIXA DE TITULOS IMP." ,Nil},;
		{"AUTMULTA"		, 0					    , Nil},;
		{"AUTDESCONT"   ,nDesconto               ,Nil},;
		{"AUTJUROS"     ,nJuros   		         ,Nil},;
		{"AUTVALREC"    ,nVlrBaixa				 ,Nil}}

	MSExecAuto({|x,y| Fina070(x,y)}, aBaixa, 3) //Baixa conta a receber

	if lMsErroAuto

		lRet := .F.
		DisarmTransaction()

		//verifico se arquivo de log existe
		if nHdlLog > 0

			cErroExec := MostraErro(cDirLogServer, cArqLog)

			FErase(cDirLogServer + cArqLog )

			fWrite(nHdlLog , "Erro na Inclusao do Titulo:" )

			fWrite(nHdlLog , cPulaLinha )

			fWrite(nHdlLog , cErroExec )

			fWrite(nHdlLog , cPulaLinha )

		endif

	else

		fWrite(nHdlLog , "Titulo Baixado com sucesso!" )

		fWrite(nHdlLog , cPulaLinha )

	endif

	RestArea(aArea)
	RestArea(aAreaSE1)

Return(lRet)

/*/{Protheus.doc} ValidaChave
Funcao para vincular os dados do contrato
e cliente ao titulo
@author Raphael Martins
@since 13/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function ValidaChave(cCtrCem,cCtrFun,aDadosTit,cTipoTit,cPrefTit,cParcela,nHdlLog,cCodConval)

	Local aArea			:= GetArea()
	Local cPrefFun 		:= ""
	Local cTipoFun		:= ""
	Local cPrefCem 		:= ""
	Local cTipoCem		:= ""
	Local cPrefMnt 		:= ""
	Local cTipoMnt		:= ""
	Local cNatTxMnt		:= ""
	Local cTitulo		:= ""
	Local cNatureza		:= ""
	Local cLogError		:= ""
	Local cCodConv		:= ""
	Local cPulaLinha	:= Chr(13) + Chr(10)
	Local lCemiterio 	:= SuperGetMV("MV_XCEMI",,.F.)
	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lRet 			:= .T.

	SE1->(DbSetOrder(1)) //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO

	//valido se o titulo e proveniente de contrato cemiterios
	if lCemiterio .And. !Empty(cCtrCem)

		cPrefCem 		:= Alltrim(SuperGetMv("MV_XPREFCT",.F.,"CTR"))
		cTipoCem		:= Alltrim(SuperGetMv("MV_XTIPOCT",.F.,"AT"))
		cPrefMnt 		:= Alltrim(SuperGetMv("MV_XPREFMN",.F.,"CTR"))
		cTipoMnt		:= Alltrim(SuperGetMv("MV_XTIPOMN",.F.,"MNT"))
		cNatTxMnt		:= Alltrim(SuperGetMv("MV_XNATMN",.F.,"10101"))

		U00->(DbSetOrder(7)) //U00_FILIAL + U00_CODANT

		if U00->(DbSeek(xFilial("U00")+Alltrim(cCtrCem)))

			aAdd(aDadosTit, {"E1_FILIAL"	, xFilial("SE1")	,NIL})
			aAdd(aDadosTit, {"E1_CLIENTE"	, U00->U00_CLIENT	,NIL})
			aAdd(aDadosTit, {"E1_LOJA"		, U00->U00_LOJA		,NIL})
			aAdd(aDadosTit, {"E1_XCONTRA"	, U00->U00_CODIGO	,NIL})
			aAdd(aDadosTit, {"E1_NUM"		, U00->U00_CODIGO	,NIL})

			// valido os prefixos e tipos de titulos
			if ValFinDados(cPrefTit, cTipoTit)

				//valido o prefixo + tipo de titulo para amarrar a natureza do mesmo
				if Alltrim(cPrefTit) == cPrefCem .And. Alltrim(cTipoTit) == cTipoCem

					aAdd(aDadosTit, {"E1_NATUREZ"		, U00->U00_NATURE	,NIL})

				elseif Alltrim(cPrefTit) == cPrefMnt .And. Alltrim(cTipoTit) == cTipoMnt

					aAdd(aDadosTit, {"E1_NATUREZ"		, cNatTxMnt	,NIL})

				endIf

			else

				lRet := .F.

				//verifico se arquivo de log existe
				if nHdlLog > 0

					fWrite(nHdlLog , "Tipo e Prefixo do Contrato: " +Alltrim(cCtrCem)+ " não parametrizados no Protheus." )

					fWrite(nHdlLog , cPulaLinha )

				endif

			endif

			if lRet

				//compatibilizo o tamanho do campo para o tamanho da SE1
				cTitulo := PadR(U00->U00_CODIGO,TamSX3("E1_NUM")[1])

				//valido se a chave do titulo ja esta na base de dados
				if SE1->(DbSeek( xFilial("SE1") + cPrefTit + cTitulo + cParcela + cTipoTit) )

					lRet := .F.

					//verifico se arquivo de log existe
					if nHdlLog > 0

						fWrite(nHdlLog , "Titulo já cadastrado na base de dados." )

						fWrite(nHdlLog , cPulaLinha )

						fWrite(nHdlLog , "Prefixo: " + cPrefTit + " " )

						fWrite(nHdlLog , cPulaLinha )

						fWrite(nHdlLog , "Titulo: " + cCtrCem + " " )

						fWrite(nHdlLog , cPulaLinha )

						fWrite(nHdlLog , "Parcela:" + cParcela + " " )

						fWrite(nHdlLog , cPulaLinha )

						fWrite(nHdlLog , "Tipo:" + cTipoTit + " " )

						fWrite(nHdlLog , cPulaLinha )


					endif

				endif

			endif

		else

			lRet := .F.

			//verifico se arquivo de log existe
			if nHdlLog > 0

				fWrite(nHdlLog , "Contrato Legado: " + Alltrim(cCtrCem)+ " não encontrado!" )

				fWrite(nHdlLog , cPulaLinha )

			endif

		endif

		//valido se o titulo e proveniente de contrato funerarios
	elseif lFuneraria .And. !Empty(cCtrFun)

		cPrefFun 		:= Alltrim(SuperGetMv("MV_XPREFUN",.F.,"FUN"))
		cTipoFun		:= Alltrim(SuperGetMv("MV_XTIPFUN",.F.,"AT" ))
		cTipoCon		:= Alltrim(SuperGetMv("MV_XTIPOCV",.F.,"EQ" ))
		cPrefCon		:= Alltrim(SuperGetMv("MV_XPRFCON",.F.,"CVL"))

		UF2->(DbSetOrder(3)) //UF2_FILIAL + UF2_CODANT

		if UF2->(DbSeek(xFilial("UF2")+Alltrim(cCtrFun)))

			// valido os prefixos e tipos de titulos
			if ValFinDados(cPrefTit, cTipoTit)

				aAdd(aDadosTit, {"E1_FILIAL"	, xFilial("SE1")	,NIL})
				aAdd(aDadosTit, {"E1_CLIENTE"	, UF2->UF2_CLIENT	,NIL})
				aAdd(aDadosTit, {"E1_LOJA"		, UF2->UF2_LOJA		,NIL})
				aAdd(aDadosTit, {"E1_XCTRFUN"	, UF2->UF2_CODIGO	,NIL})
				aAdd(aDadosTit, {"E1_NUM"		, UF2->UF2_CODIGO	,NIL})
				aAdd(aDadosTit, {"E1_NATUREZ"	, UF2->UF2_NATURE	,NIL})

			else

				lRet := .F.

				//verifico se arquivo de log existe
				if nHdlLog > 0

					fWrite(nHdlLog , "Tipo e Prefixo do Contrato: " +Alltrim(cCtrCem)+ " não parametrizados no Protheus." )

					fWrite(nHdlLog , cPulaLinha )

				endif

			endif

			//Valido se é titulo de convalescente
			if !Empty(cCodConval)

				cCodConv :=  ContConva(cCodConval,cCtrFun)

				//Se achou o contrato convalescente grava no titulo
				if !Empty(cCodConv)

					aAdd(aDadosTit, {"E1_XCONCTR", cCodConv	,NIL})

				else

					lRet := .F.

					//verifico se arquivo de log existe
					if nHdlLog > 0

						fWrite(nHdlLog , "Contrato Convalescente Legado: " + Alltrim(cCodConval)+ " não encontrado!" )

						fWrite(nHdlLog , cPulaLinha )

					endif
				Endif

			endif

			if lRet

				//compatibilizo o tamanho do campo para o tamanho da SE1
				cTitulo := PadR(UF2->UF2_CODIGO,TamSX3("E1_NUM")[1])

				//valido se a chave do titulo ja esta na base de dados
				if SE1->(DbSeek( xFilial("SE1") + cPrefTit + cTitulo + cParcela + cTipoTit) )

					lRet := .F.

					//verifico se arquivo de log existe
					if nHdlLog > 0

						fWrite(nHdlLog , "Titulo já cadastrado na base de dados." )

						fWrite(nHdlLog , cPulaLinha )

						fWrite(nHdlLog , "Prefixo: " + cPrefTit + " " )

						fWrite(nHdlLog , cPulaLinha )

						fWrite(nHdlLog , "Titulo: " + cCtrFun + " " )

						fWrite(nHdlLog , cPulaLinha )

						fWrite(nHdlLog , "Parcela:" + cParcela + " " )

						fWrite(nHdlLog , cPulaLinha )

						fWrite(nHdlLog , "Tipo:" + cTipoTit + " " )

						fWrite(nHdlLog , cPulaLinha )


					endif

				endif

			endif

		else

			lRet := .F.

			//verifico se arquivo de log existe
			if nHdlLog > 0

				fWrite(nHdlLog , "Contrato Legado: " + Alltrim(cCtrFun)+ " não encontrado!" )

				fWrite(nHdlLog , cPulaLinha )

			endif

		endif

	else

		lRet := .F.

		//verifico se arquivo de log existe
		if nHdlLog > 0

			fWrite(nHdlLog , "Contrato não definido no layout de importação de dados." )

			fWrite(nHdlLog , cPulaLinha )

		endif

	endif

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} VldNossoNumero
Valido se o nosso numero esta duplicado
@author Raphael Martins
@since 13/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function VldNossoNumero(cBanco,cAgencia,cConta,cNossoNumero,nHdlLog)

	Local aArea			:= GetArea()
	Local aAreaSE1		:= SE1->( GetArea() )
	Local cQry 			:= ""
	Local cPulaLinha	:= Chr(13) + Chr(10)
	Local lRet			:= .T.


	cQry := " SELECT "
	cQry += " COUNT(*) QTD_DUPLI "
	cQry += " FROM  "
	cQry += " " + RetSQLName("SE1") + " SE1 "
	cQry += " WHERE "
	cQry += " D_E_L_E_T_ = ' ' "
	cQry += " AND E1_FILIAL = '" + xFilial("SE1") + "'  "
	cQry += " AND E1_NUMBCO = '"  + cNossoNumero + "' "
	cQry += " AND E1_PORTADO = '" + cBanco + "' "
	cQry += " AND E1_AGEDEP = '" + cAgencia + "' "
	cQry += " AND E1_CONTA = '" + cConta + "' "

// verifico se não existe este alias criado
	If Select("QRYNBCO") > 0
		QRYNBCO->(DbCloseArea())
	EndIf

// crio o alias temporario
	TcQuery cQry New Alias "QRYNBCO"


	If QRYNBCO->QTD_DUPLI > 0

		lRet	:= .F.

		//verifico se arquivo de log existe
		if nHdlLog > 0

			fWrite(nHdlLog , "Nosso Número já se encontra vinculado a outro titulo com o mesmo Banco + Agencia + Conta! " )

			fWrite(nHdlLog , cPulaLinha )

		endif

	endif

	RestArea(aArea)
	RestArea(aAreaSE1)

Return(lRet)

/*/{Protheus.doc} GeraBordero
Funcao para incluir bordero 
e gerar id cnab
@author Raphael Martins
@since 13/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

Static Function GeraBordero(nRecno,cBanco,cAgencia,cConta,cNossoNumero)

	Local aAreaSE1 := SE1->( GetArea() )
	Local aAreaSEA := SEA->( GetArea() )

	SE1->( DbSetOrder(1) ) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

	SE1->( DbGoto(nRecno) )

	//preencho o id cnab do titulo
	cIdCnab := CodigoCNAB()

	RecLock("SE1",.F.)

	SE1->E1_SITUACA := '1'
	SE1->E1_MOVIMEN := dDataBase
	SE1->E1_IDCNAB	:= cIdCnab

	SE1->( MsUnlock() )

	//Coloca Titulo em Cobrança - Carteira Simples
	RecLock("SEA",.T.)
	SEA->EA_FILIAL  := xFilial("SEA")
	SEA->EA_DATABOR := dDataBase
	SEA->EA_PORTADO := cBanco
	SEA->EA_AGEDEP  := cAgencia
	SEA->EA_NUMCON  := cConta
	SEA->EA_SITUACA := '1'
	SEA->EA_NUM 	:= SE1->E1_NUM
	SEA->EA_PARCELA := SE1->E1_PARCELA
	SEA->EA_PREFIXO := SE1->E1_PREFIXO
	SEA->EA_TIPO	:= SE1->E1_TIPO
	SEA->EA_CART	:= "R"
	SEA->EA_SITUANT := '0'
	SEA->EA_FILORIG := SE1->E1_FILORIG

	SEA->( MsUnlock() )

	RestArea( aAreaSE1 )
	RestArea( aAreaSEA )

Return()

/*/{Protheus.doc} CodigoCNAB
Funcao para Gerar o ID_CNAB do titulo
@author Raphael Martins
@since 14/11/2017
@version 1.0
@Param

/*/
Static Function CodigoCNAB()

	Local aArea      	:= GetArea()
	Local aAreaSE1   	:= SE1->( GetArea() )
	Local lNewIndex  	:= FaVerInd()
	Local cCodIdCnab	:= ""

	cCodIdCnab := GetSxENum("SE1","E1_IDCNAB","E1_IDCNAB"+cEmpAnt,If(lNewIndex,19,16))

	SE1->( DbSetOrder(16)) // E1_FILIAL+E1_IDCNAB

	While SE1->(DbSeek( xFilial("SE1") + cCodigo))
		ConfirmSX8()
		cCodIdCnab := GetSxENum("SE1","E1_IDCNAB","E1_IDCNAB"+cEmpAnt,If(lNewIndex,19,16))
	EndDo

	ConfirmSX8()


	RestArea(aArea)
	RestArea(aAreaSE1)

Return(cCodIdCnab)


/*/{Protheus.doc} CodigoCNAB
Funcao para buscar contrato convalescente
@author Leandro Rodrigues
@since 14/11/2017
@version 1.0
@Param

/*/
Static Function ContConva(cCodConv,cContrato)

	Local cQry := " "

	cQry := " SELECT"
	cQry += "	UJH_CODIGO"
	cQry += " FROM"
	cQry += " "+ RETSQLNAME("UJH") + " UJH"
	cQry += " INNER JOIN " + RETSQLNAME("UF2") + " UF2"
	cQry += " ON UF2_FILIAL = UJH_FILIAL"
	cQry += " 	AND UF2_CODIGO = UJH_CONTRA"
	cQry += " 	AND UF2_CODANT = '" + cContrato + "'"
	cQry += " 	AND UF2.D_E_L_E_T_= ' '"
	cQry += " WHERE UJH.D_E_L_E_T_= ' '"
	cQry += "	AND UJH_FILIAL = '" + xFilial("UJH") + "'"
	cQry += "	AND UJH_CODLEG = '" + cCodConv  	 + "'"

	cQry := ChangeQuery(cQry)

	if Select("QUJH") > 1
		QUJH->(DbCloseArea())
	endIf

	TcQuery cQry New Alias "QUJH"

Return(QUJH->UJH_CODIGO)

/*/{Protheus.doc} ValFinDados
Funcao para validacao do prefixo e tipo de titulo
@type function
@version 1.0
@author g.sampaio
@since 04/10/2022
@param cPrefTit, character, prefixo do titulo importado
@param cTipoTit, character, tipo do titulo importado
@return logical, retorno da validacao da importacao
/*/
Static Function ValFinDados(cPrefTit, cTipoTit)

	Local cPrefImp	:= AllTrim(SuperGetMV("MV_XPRFIMP",.F.,"FUN;CVL;CTR"))
	Local cTipImp	:= AllTrim(SuperGetMV("MV_XTIPIMP",.F.,"AT;EQ;MNT"))
	Local lRetorno 	:= .F.

	Default cPrefTit	:= ""
	Default cTipoTit	:= ""

	// verifico se o tipo de titulo é pertence aos tipos importados
	if AllTrim(cPrefTit) $ cPrefImp .And. AllTrim(cTipoTit) $ cTipImp
		lRetorno := .T.
	endIf

Return(lRetorno)
