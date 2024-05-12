#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} RFUNE040
Rotina para calcular valor da parcela levando em consideracao 
aniversario do titular e beneficiarios
@author Leandro Rodrigues
@since 24/08/2019
@param dDatavenc,cContrato
@return Valor da Parcela
/*/
User Function RFUNE040(dDataVenc, cContrato, aRegras, oModel)

	Local nValParc      := 0
	Local nIdade        := 0
	Local nValAdt       := 0
	Local nNumDep       := 0
	Local nX            := 0
	Local nI            := 0
	Local nJ            := 0
	Local aRegrasAux    := {}
	Local aDependentes  := {"1","2"} // 1 - Beneficiario 2 - Agregado 3 - Titular
	Local aTipos        := {}
	Local lRegraValid   := .T.
	Local oModelUF2     := Nil
	Local aBeneficiarios:= {}
	Local cRegraAtual   := ""

	//Posiciono no contrato
	UF2->(DbSetOrder(1))
	If UF2->(DbSeek(xFilial("UF2")+ cContrato))

		//se for alteracao considera variaveis de memoria
		//porque podem ter sido alterado valores
		If IsInCallStack("U_PFUNA002")

			//Carrego model da UF2
			oModelUF2   := oModel:GetModel("UF2MASTER")
			cRegraAtual := oModelUF2:GetValue("UF2_REGRA")

			//Valor do plano + Serd Add
			nValParc := ( oModelUF2:GetValue("UF2_VLRBRU") + oModelUF2:GetValue("UF2_VLSERV") + oModelUF2:GetValue("UF2_VLADIC") ) - oModelUF2:GetValue("UF2_DESCON")

		else

			//Valor do plano + Serd Add + Valor Adicional
			nValParc    := (UF2->UF2_VLRBRU + UF2->UF2_VLSERV + UF2->UF2_VLADIC ) - UF2->UF2_DESCON
			cRegraAtual := UF2->UF2_REGRA

		endif

		//Carrega array de beneficiarios
		GetBeneficiarios( UF2->UF2_CODIGO, @aBeneficiarios, dDataVenc, oModel )

		For nX := 1 to Len(aBeneficiarios)

			//Verifico a idade do beneficiario cnsiderando o mes de vencimento da parcela
			if Empty(aBeneficiarios[nX,7])
				nIdade := U_UAgeCalculate(aBeneficiarios[nX,2],dDataVenc)
			else
				nIdade := aBeneficiarios[nX,6]
			endif

			//valido o tipo de regra 1-Beneficiario 2-Agregado 3-Titular
			cTpRegra    := iif(aBeneficiarios[nX,5] == '3',"T","I")

			//////////////////////////////////////////////////////////////
			////////////////// CONSULTA REGRAS POR IDADE /////////////////
			//////////////////////////////////////////////////////////////
			RegPorIdade(nIdade,cTpRegra,aBeneficiarios[nX,3],aBeneficiarios[nX,4],aBeneficiarios[nX,1],aBeneficiarios[nX,5],@aRegrasAux,@aTipos,cRegraAtual)

		Next nX

		//////////////////////////////////////////////////////////////
		///// VERIFICA SE EXISTE REGRA PARA QTDE DE BENEFICIARIO ////
		//////////////////////////////////////////////////////////////
		If Len(aTipos) > 0

			RegPorQtdBen(aTipos,@aRegrasAux,cRegraAtual)

		Endif

		//////////////////////////////////////////////////////////////
		////////// VALIDAÇÃO DAS CONDIÇÕES DA COB. ADICIONAL /////////
		//////////////////////////////////////////////////////////////

		For nX := 1 To Len(aTipos)

			// verifico os tipos de beneficiários que são considerados como dependente
			if aScan( aDependentes, { |x| Alltrim(x) == Alltrim(aTipos[nX,1]) } ) > 0
				nNumDep += aTipos[nX,2]
			endif

		Next nX

		/////////////////////////////////////////////////////////
		//////// VERIFICO TODAS AS REGRAS CONSULTADAS ///////////
		/////////////////////////////////////////////////////////
		For nX := 1 To Len(aRegrasAux)

			lRegraValid := .T.
			lIdadeDepOK	:= .F.

			// verifico se existe uma condição para a regra
			UJ7->(DbSetOrder(1)) // UJ7_FILIAL + UJ7_CODIGO + UJ7_REGRA + UJ7_ITEM
			if UJ7->(DbSeek(xFilial("UJ7") + aRegrasAux[nX,1] + aRegrasAux[nX,2]))

				While UJ7->(!Eof()) ;
						.AND. UJ7->UJ7_FILIAL == xFilial("UJ7") ;
						.AND. UJ7->UJ7_CODIGO == aRegrasAux[nX,1] ;
						.AND. UJ7->UJ7_REGRA  == aRegrasAux[nX,2]

					if UJ7->UJ7_TPCOND == "I" // Tipo de condição = Idade do Dependente

						// percorro o grid de beneficiarios
						For nI := 1 to Len(aBeneficiarios)

							//Verifico a idade do beneficiario cnsiderando o mes de vencimento da parcela
							if Empty(aBeneficiarios[nX,7])
								nIdade := U_UAgeCalculate(aBeneficiarios[nX,2],dDataVenc)
							else
								nIdade := aBeneficiarios[nX,6]
							endif

							// verifico se o tipo do beneficiario é considerado como dependente
							if aScan( aDependentes, { |x| Alltrim(x) == Alltrim(aBeneficiarios[nI,5]) } ) > 0

								// se a idade do dependente estiver no intervalo definido
								if nIdade >= UJ7->UJ7_VLRINI .AND. nIdade <= UJ7->UJ7_VLRFIM
									lIdadeDepOK := .T.
									Exit
								endif

							endif

						Next nI

						// se não foram encontrados dependentes com idade dentro do intervalo da regra
						if !lIdadeDepOK
							lRegraValid := .F.
							Exit
						endif

					elseif UJ7->UJ7_TPCOND == "T" // Tipo de condição = Idade do Titular

						lRegraValid := .T.

						For nJ := 1 to Len(aBeneficiarios)

							// posiciono no beneficiario do tipo titular
							if aBeneficiarios[nJ,5] == "3"

								if Empty(aBeneficiarios[nJ,7])
									nIdade := U_UAgeCalculate(aBeneficiarios[nJ,2],dDataVenc)
								else
									nIdade := aBeneficiarios[nJ,6]
								endif

								// se a idade do titular não estiver no intervalo definido
								if !(nIdade >= UJ7->UJ7_VLRINI .AND. nIdade <= UJ7->UJ7_VLRFIM )
									lRegraValid := .F.
									Exit
								endif

							endIf

						Next nJ

						// se não encontrou o beneficiario titular
						If !lRegraValid
							Exit
						Endif

					elseif UJ7->UJ7_TPCOND == "N" // Tipo de condição = Numero de dependentes

						// se o número de dependentes não estiver no intervalo definido
						if !( nNumDep >= UJ7->UJ7_VLRINI .AND. nNumDep <= UJ7->UJ7_VLRFIM )
							lRegraValid := .F.
							Exit
						endif

					endif

					UJ7->(DbSkip())

				EndDo

			endif

			// se a regra foi validada
			if lRegraValid
				aadd(aRegras,aRegrasAux[nX])
			endif

		Next nX

		//Calculo valor total adicional
		For nX := 1 To Len(aRegras)

			nValAdt += aRegras[nX , 08]

		Next nX

	Endif

Return(nValParc + nValAdt)

/*/{Protheus.doc} RFUNE040
Rotina Verifica se existe regra para quantidade
por tipo de beneficiario
@author Leandro Rodrigues
@since 24/08/2019
@param dDatavenc,cContrato36
@return Valor da Parcela
/*/

Static Function RegPorQtdBen(aTipos,aRegrasAux,cRegraAtual)

	Local cQryJ5        := ""
	Local nX            := 0
	Local nQtd          := 0
	Local aAux          := {}
	Local cPulaLinha	:= chr(13)+chr(10)

//verifico se existe regra para quantidade por tipo de beneficiario
	For nX := 1 To Len(aTipos)

		//////////////////////////////////////////////////////////////
		/////////////// CONSULTA REGRAS POR QUANTIDADE ///////////////
		//////////////////////////////////////////////////////////////

		// verifico se nao existe este alias criado
		If Select("QRYUJ5") > 0
			QRYUJ5->(DbCloseArea())
		EndIf

		cQryJ5 := " SELECT "												    + cPulaLinha
		cQryJ5 += " UJ5.UJ5_CODIGO AS CODIGO_REGRA, "                           + cPulaLinha
		cQryJ5 += " UJ6.UJ6_REGRA AS ITEM_REGRA, "                              + cPulaLinha
		cQryJ5 += " UJ6.UJ6_TPREGR AS TIPO_REGRA, "                             + cPulaLinha
		cQryJ5 += " UJ6.UJ6_VLRINI AS LIMITE_INICIAL, "                         + cPulaLinha
		cQryJ5 += " UJ6.UJ6_VLRFIM AS LIMITE_FINAL, "                           + cPulaLinha
		cQryJ5 += " UJ6.UJ6_VLRCOB AS VALOR, "                                  + cPulaLinha
		cQryJ5 += " UJ6.UJ6_INDIVI AS INDIVIDUAL "                              + cPulaLinha
		cQryJ5 += " FROM "                                                      + cPulaLinha
		cQryJ5 += " " + RetSqlName("UJ5") + " UJ5 "                             + cPulaLinha
		cQryJ5 += " INNER JOIN "                                                + cPulaLinha
		cQryJ5 += " " + RetSqlName("UJ6") + " UJ6 "                             + cPulaLinha
		cQryJ5 += " ON "                                                        + cPulaLinha
		cQryJ5 += " 	UJ5.D_E_L_E_T_ = ' ' "                                  + cPulaLinha
		cQryJ5 += " 	AND UJ6.D_E_L_E_T_ = ' ' "                              + cPulaLinha
		cQryJ5 += " 	AND UJ6.UJ6_FILIAL = '" + xFilial("UJ6") + "' "         + cPulaLinha
		cQryJ5 += " 	AND UJ5.UJ5_FILIAL = UJ6.UJ6_FILIAL "                   + cPulaLinha
		cQryJ5 += " 	AND UJ6.UJ6_CODIGO = UJ5.UJ5_CODIGO"                    + cPulaLinha
		cQryJ5 += " 	AND UJ6.UJ6_TPREGR = 'N' "	                            + cPulaLinha
		cQryJ5 += " 	AND UJ6.UJ6_TPBENE = '" + aTipos[nX,1] + "' "           + cPulaLinha
		cQryJ5 += " 	AND UJ6.UJ6_VLRINI <= " + cValToChar(aTipos[nX,2]) 	    + cPulaLinha
		cQryJ5 += " 	AND UJ6.UJ6_VLRFIM >= " + cValToChar(aTipos[nX,2])      + cPulaLinha
		cQryJ5 += " WHERE "                                                     + cPulaLinha
		cQryJ5 += " UJ5.UJ5_FILIAL = '" + xFilial("UJ5") + "' "                 + cPulaLinha
		cQryJ5 += " AND UJ5.UJ5_CODIGO = '" + cRegraAtual    + "' "             + cPulaLinha

		// funcao que converte a query generica para o protheus
		cQryJ5 := ChangeQuery(cQryJ5)

		// crio o alias temporario
		TcQuery cQryJ5 New Alias "QRYUJ5"

		if QRYUJ5->(!Eof())

			While QRYUJ5->(!Eof())

				aAux := {}

				if QRYUJ5->INDIVIDUAL == "S"
					nQtd := aTipos[nX,2] - QRYUJ5->LIMITE_INICIAL + 1
				else
					nQtd := 1
				endif

				aadd(aAux , QRYUJ5->CODIGO_REGRA 			) // Código da Regra
				aadd(aAux , QRYUJ5->ITEM_REGRA 				) // Item da Regra
				aadd(aAux , QRYUJ5->TIPO_REGRA 				) // Tipo da Regra
				aadd(aAux , QRYUJ5->LIMITE_INICIAL 			) // Limite Inicial
				aadd(aAux , QRYUJ5->LIMITE_FINAL 			) // Limite Final
				aadd(aAux , QRYUJ5->VALOR 					) // Valor Unitário
				aadd(aAux , nQtd	 						) // Quantidade
				aadd(aAux , QRYUJ5->VALOR * nQtd			) // Valor Total
				aadd(aAux , ""								) // Item do Beneficiário
				aadd(aAux , ""								) // Nome do Beneficiário

				aadd(aRegrasAux , aAux)

				QRYUJ5->(DbSkip())

			EndDo

		endif

	Next nX

Return

/*/{Protheus.doc} RFUNE040
Rotina Verifica se existe regra por Idade
@author Leandro Rodrigues
@since 24/08/2019
@param 
@return Valor da Parcela
/*/

Static Function RegPorIdade(nIdade,cTpRegra,cRegraBen,cNomeBen,cItem,cTipoBen,aRegrasAux,aTipos,cRegraAtual)

	Local nPosTipo      := 0
	Local nValor        := 0
	Local cPulaLinha	:= chr(13)+chr(10)
	Local cRegra        := ""

	// verifico se nao existe este alias criado
	If Select("QRYUJ5") > 0
		QRYUJ5->(DbCloseArea())
	EndIf

	//defino qual regra sera consultada, sendo Regra do Beneficiario ou Regra do Contrato
	cRegra := If(!Empty(cRegraBen),cRegraBen,cRegraAtual)

	cQryJ5 := " SELECT" 													+ cPulaLinha
	cQryJ5 += " 	UJ5_CODIGO AS CODIGO_REGRA,"							+ cPulaLinha
	cQryJ5 += " 	UJ6_REGRA AS ITEM_REGRA,"								+ cPulaLinha
	cQryJ5 += " 	UJ6_TPREGR AS TIPO_REGRA,"								+ cPulaLinha
	cQryJ5 += " 	UJ6_VLRINI AS LIMITE_INICIAL,"							+ cPulaLinha
	cQryJ5 += " 	UJ6_VLRFIM AS LIMITE_FINAL,"							+ cPulaLinha
	cQryJ5 += " 	UJ6_VLRCOB AS VALOR,"									+ cPulaLinha
	cQryJ5 += " 	UJ6_INDIVI AS INDIVIDUAL"								+ cPulaLinha
	cQryJ5 += " FROM " + RETSQLNAME("UJ5") + " UJ5" 						+ cPulaLinha
	cQryJ5 += " INNER JOIN " + RETSQLNAME("UJ6") + " UJ6" 				    + cPulaLinha
	cQryJ5 += "     ON UJ6.D_E_L_E_T_ = ' ' "                              + cPulaLinha
	cQryJ5 += "     AND UJ6.UJ6_FILIAL = UJ5.UJ5_FILIAL"					+ cPulaLinha
	cQryJ5 += " 	AND UJ6.UJ6_CODIGO = UJ5.UJ5_CODIGO"					+ cPulaLinha
	cQryJ5 += " 	AND UJ6.UJ6_TPBENE = '" + cTipoBen + "'        " 		+ cPulaLinha
	cQryJ5 += " 	AND UJ6.UJ6_TPREGR  = '" + cTpRegra + "' "				+ cPulaLinha
	cQryJ5 += " 	AND UJ6.UJ6_VLRINI <=  " + cValToChar(nIdade)			+ cPulaLinha
	cQryJ5 += " 	AND UJ6.UJ6_VLRFIM >=  " + cValToChar(nIdade)			+ cPulaLinha
	cQryJ5 += " 	WHERE  UJ5.D_E_L_E_T_= ' ' "                 			+ cPulaLinha
	cQryJ5 += " 		AND UJ5_FILIAL = '" + xFilial("UJ5")    + "'"	       + cPulaLinha
	cQryJ5 += " 		AND UJ5_CODIGO = '" + cRegra + "'"	    	        + cPulaLinha

	// funcao que converte a query generica para o protheus
	cQryJ5 := ChangeQuery(cQryJ5)

	// crio o alias temporario
	MPSysOpenQuery( cQryJ5, "QRYUJ5" )

	if QRYUJ5->(!Eof())

		While QRYUJ5->(!Eof())

			aAux := {}

			nValor := QRYUJ5->VALOR

			aadd(aAux , QRYUJ5->CODIGO_REGRA 		) // Código da Regra
			aadd(aAux , QRYUJ5->ITEM_REGRA 			) // Item da Regra
			aadd(aAux , QRYUJ5->TIPO_REGRA 			) // Tipo da Regra
			aadd(aAux , QRYUJ5->LIMITE_INICIAL 		) // Limite Inicial
			aadd(aAux , QRYUJ5->LIMITE_FINAL 		) // Limite Final
			aadd(aAux , nValor 						) // Valor Unitário
			aadd(aAux , 1	 						) // Quantidade
			aadd(aAux , nValor 						) // Valor Total
			aadd(aAux , cItem                       ) // Item do Beneficiário
			aadd(aAux , cNomeBen                    ) // Nome do Beneficiário
			aadd(aRegrasAux , aAux)

			QRYUJ5->(DbSkip())

		EndDo
	endif

	// verifico se nao existe este alias criado
	If Select("QRYUJ5") > 0
		QRYUJ5->(DbCloseArea())
	EndIf

	//titular e beneficiarios com regra especifica nao entra para contagem de beneficiarios
	if cTipoBen <> "3" .AND. Empty(cRegraBen)

		//valido se o tipo de beneficario ja existe no array de aTipos para pesquisar as regras por quantidade
		nPosTipo := aScan( aTipos, { |x| Alltrim(x[1]) == Alltrim(cTipoBen) } )

		if nPosTipo > 0

			aTipos[nPosTipo,2] += 1

		else

			Aadd(aTipos,{cTipoBen,1})

		endif

	endif

Return

/*/{Protheus.doc} GetBeneficiarios
Rotina para carregar array de beneficiarios do contrato
@type function
@version 1.0
@author Leandro Rodrigues
@since 24/08/2019
@param cCtrCodigo, character, codigo do contrato
@param aBeneficiarios, array, array de beneficiarios a ser alimentado na rotina
@param dDataVenc, date, data de vencimento da vigencia
/*/
Static Function GetBeneficiarios( cCtrCodigo, aBeneficiarios, dDataVenc, oModel )

	Local cQryF4    := ""
	Local nI        := 1
	Local oModelUF4	:= Nil

	Default cCtrCodigo      := ""
	Default aBeneficiarios  := {}
	Default dDataVenc       := dDatabase

	//Limpo array para recarregar
	aBeneficiarios := {}

	//Chamado da rotina de ativacao do contrato
	if IsInCallStack("U_RFUNA004") .OR. IsInCallStack("U_RFUNA010");
			.OR. IsInCallStack("U_RFUNA031") .OR. IsInCallStack("U_RFUNA055")

		if Select("QRYUF4") > 0
			QRYUF4->(DbCloseArea())
		endIf

		//Consulta Benficiarios do contrato
		cQryF4 := " SELECT "
		cQryF4 += "	UF4_ITEM, "
		cQryF4 += "	UF4_DTNASC, "
		cQryF4 += "	UF4_REGRA, "
		cQryF4 += "	UF4_NOME, "
		cQryF4 += "	UF4_TIPO, "
		cQryF4 += "	UF4_IDADE,	"
		cQryF4 += "	UF4_DTFIM "
		cQryF4 += " FROM " + RetSQLName("UF4") + " UF4"
		cQryF4 += " WHERE UF4.D_E_L_E_T_= ' '"
		cQryF4 += "   AND UF4_FILIAL = '"+ xFilial("UF4") +"'"
		cQryF4 += "   AND UF4_DTNASC <> ' ' "
		cQryF4 += "   AND ( UF4_DTFIM  = ' ' OR UF4_DTFIM >= '" + dTos(dDataVenc) + "')"
		cQryF4 += "   AND UF4_CODIGO   = '" + cCtrCodigo   + "'"
		cQryF4 += " ORDER BY UF4_ITEM"

		cQryF4 := ChangeQuery(cQryF4)

		MPSysOpenQuery( cQryF4, "QRYUF4" )

		While QRYUF4->(!EOF())

			AADD(aBeneficiarios,{  QRYUF4->UF4_ITEM,;
				sTod(QRYUF4->UF4_DTNASC),;
				QRYUF4->UF4_REGRA,;
				QRYUF4->UF4_NOME,;
				QRYUF4->UF4_TIPO,;
				QRYUF4->UF4_IDADE,;
				QRYUF4->UF4_DTFIM })

			QRYUF4->(DbSkip())
		EndDo

		// fecho o alias utilizado na consulta
		if Select("QRYUF4") > 0
			QRYUF4->(DbCloseArea())
		endIf

	else

		//Carrega Model de Beneficiarios
		oModelUF4 := oModel:GetModel("UF4DETAIL")

		// percorro todos os beneficiários
		For nI := 1 To oModelUF4:Length()

			// posiciono na linha
			oModelUF4:GoLine(nI)

			if !oModelUF4:IsDeleted() .And. (Empty(oModelUF4:GetValue( "UF4_DTFIM" )) .Or. oModelUF4:GetValue( "UF4_DTFIM" ) >= dDataVenc)

				// se a data de nascimento estiver preenchida
				if !Empty(oModelUF4:GetValue( "UF4_DTNASC" ))

					AADD(aBeneficiarios,{ oModelUF4:GetValue("UF4_ITEM"   ),;
						oModelUF4:GetValue("UF4_DTNASC" ),;
						oModelUF4:GetValue("UF4_REGRA"  ),;
						oModelUF4:GetValue("UF4_NOME"   ),;
						oModelUF4:GetValue("UF4_TIPO"   ),;
						oModelUF4:GetValue("UF4_IDADE"  ),;
						oModelUF4:GetValue("UF4_DTFIM"  )})

				endIf

			Endif
		Next nI

	endIf

Return(Nil)

/*/{Protheus.doc} RFUNE040
Rotina Grava Log de composicao parcela
@author Leandro Rodrigues
@since 24/08/2019
@param 
@return Valor da Parcela
/*/

User Function RFUN40OK(cContrato,aRegras,dDataReaj,lAltera)

	Local nX        := 1
	Local cCodBen   := ""

	Default dDataReaj := cTod("")
	Default lAltera   := .F.

	Static nPosRegra := 01
	Static nPosItReg := 02
	Static nPosTpReg := 03
	Static nPosVlIni := 04
	Static nPosVlFim := 05
	Static nPosValor := 06
	Static nPosQtde  := 07
	Static nPosVlTot := 08
	Static nPosBenef := 09

//Gravo regras que compoem as parcelas 
	For nX :=1 to Len(aRegras)

		cCodBen := Padr(Alltrim(aRegras[nX,nPosBenef]),TamSx3("UJR_CODBEN")[1])

		UJR->(DbSetOrder(1))

		//Valido se ja existe historico
		If UJR->(DbSeek(xFilial("UJR")+aRegras[nX,nPosRegra]+aRegras[nX,nPosItReg]+cCodBen+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_TIPO))

			//Gravo parcela no renge de parcelas ja gravadas para regra
			If !(SE1->E1_PARCELA >= UJR->UJR_PARCDE .AND. SE1->E1_PARCELA <= UJR->UJR_PARCAT)

				If RecLock("UJR",.F.)
					UJR->UJR_DTREAJ := dDataReaj
					UJR->UJR_PARCAT := SE1->E1_PARCELA
					UJR->(MsUnLock())
				Endif
			Endif
		else

			UJR->(DbSetOrder(3))

			//Valido se beneficiaio ja tem uma regra cadastrada
			If UJR->(DbSeek(xFilial("UJR")+cContrato+aRegras[nX,nPosRegra]+cCodBen))

				//Encerro clico da regra para iniciar uma nova
				If RecLock("UJR",.F.)
					UJR->UJR_PARCAT := StrZero(Val(SE1->E1_PARCELA) -1,TamSx3("E1_PARCELA")[1])
					UJR->(MsUnLock())
				Endif
			Endif

			//Gravo Log de composicao de regra da parcela
			If RecLock("UJR",.T.)

				UJR->UJR_FILIAL := xFilial("UJR")
				UJR->UJR_CODIGO := cContrato
				UJR->UJR_PREFIX := SE1->E1_PREFIXO
				UJR->UJR_NUM    := SE1->E1_NUM
				UJR->UJR_TIPO   := SE1->E1_TIPO
				UJR->UJR_REGRA  := aRegras[nX,nPosRegra]
				UJR->UJR_ITEMRE := aRegras[nX,nPosItReg]
				UJR->UJR_TIPORE := aRegras[nX,nPosTpReg]
				UJR->UJR_VLRINI := aRegras[nX,nPosVlIni]
				UJR->UJR_VLRFIM := aRegras[nX,nPosVlFim]
				UJR->UJR_QTDE   := aRegras[nX,nPosQtde ]
				UJR->UJR_VLUNIT := aRegras[nX,nPosValor]
				UJR->UJR_VLTOT  := aRegras[nX,nPosVlTot]
				UJR->UJR_CODBEN := aRegras[nX,nPosBenef]
				UJR->UJR_PARCDE := SE1->E1_PARCELA
				UJR->UJR_PARCAT := SE1->E1_PARCELA
				UJR->UJR_DTREAJ := dDataReaj

				UJR->(MsUnLock())

			Endif

		Endif

	Next nX

Return
