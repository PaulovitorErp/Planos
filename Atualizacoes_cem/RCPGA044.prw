#Include "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RCPGA044
//TODO Rotina de geracao de adiantamento de parcelas.
@author g.sampaio
@since 18/02/2020
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function RCPGA044()

	Local aArea 			:= GetArea()
	Local aAreaU00			:= U00->( GetArea() )
	Local cContrato			:= ""
	Local cTitular			:= ""
	Local dAtivacao			:= Stod("")
	Local dLocacao			:= Stod("")
	Local lContinua			:= .T.
	Local nParcelas			:= 0
	Local nParPagas			:= 0
	Local nParcVencidas		:= 0
	Local nParcRestantes	:= 0
	Local nValorParc		:= 0
	Local nGetParc			:= 0
	Local nGetVlr			:= 0
	Local oFont14 			:= TFont():New("Arial",,014,,.T.,,,,,.F.,.F.)
	Local oFont13 			:= TFont():New("Arial",,013,,.T.,,,,,.F.,.F.)
	Local oFont13N 			:= TFont():New("Arial",,013,,.T.,,,,,.F.,.F.)
	Local oDlg				:= NIL
	Local oGroup1			:= NIL
	Local oGroup2			:= NIL
	Local oGroup3			:= NIL
	Local oSay1				:= NIL
	Local oSay2				:= NIL
	Local oSay3				:= NIL
	Local oSay4				:= NIL
	Local oSay5				:= NIL
	Local oSay6				:= NIL
	Local oSay7				:= NIL
	Local oSay8				:= NIL
	Local oSay9				:= NIL
	Local oSay10			:= NIL
	Local oSay11			:= NIL
	Local oContrato			:= NIL
	Local oTitular			:= NIL
	Local oAtivacao			:= NIL
	Local oParcelas			:= NIL
	Local oParcPagas		:= NIL
	Local oParcVenc			:= NIL
	Local oParcRest			:= NIL
	Local oVlrParc			:= NIL
	Local oLocacao			:= NIL
	Local oGet1				:= NIL
	Local oGet2				:= NIL
	Local oButton1			:= NIL
	Local oButton2			:= NIL

	// posiciono no contrato de cemiterio
	U00->( DbSetOrder(1) )
	If !U00->( MsSeek( xFilial("U00")+U74->U74_CONTRA ) )

		lContinua := .F. // nao prossigo com a rotina
		MsgAlert("Contrato não encontrado!")

	EndIf

	//sera permitido apenas para contratos ativos realizar o adiantamento de parcelas
	If lContinua .And. ValidAntPar( U00->U00_CODIGO, U00->U00_PLANO, U00->U00_STATUS )

		//carrego as variaveis com os dados do contrato
		cContrato		:= U00->U00_CODIGO									// codigo do contrato
		dAtivacao		:= U00->U00_DTATIV										// data de ativacao do contrato
		dLocacao		:= RetDataLocacao(U00->U00_CODIGO)					// data de locacao que se iniciou a locacao
		nParcelas		:= RetParcLocacao(U00->U00_CODIGO) 					// parcelas geradas locacao
		nParPagas 		:= RetParcPagas(U00->U00_CODIGO)					// parcelas pagas locacao
		nParcVencidas	:= RetParcVenc(U00->U00_CODIGO)						// parcelas vencidas locacao
		nParcRestantes	:= nParcelas - nParPagas							// parcelas restantes locacao
		nValorParc		:= U74->U74_TAXA + U74_VLADIC						// valor da parcela conforme taxa
		nGetVlr			:= nValorParc										// inicializo o get de valores com da parcela do plano

		// carrego os dados do Titular do contrato
		cTitular := Alltrim(U00->U00_CLIENT)
		cTitular += "/"
		cTitular += Alltrim(U00->U00_LOJA)
		cTitular += " - "
		cTitular += Alltrim( RetField("SA1",1,xFilial("SA1")+U00->U00_CLIENT+U00->U00_LOJA,"A1_NOME") )

		DEFINE MSDIALOG oDlg TITLE "Adiantamento de Parcelas - Locação de Nicho" FROM 000, 000  TO 293, 597 COLORS 0, 16777215 PIXEL

		@ 003, 003 GROUP oGroup1 TO 084, 296 PROMPT " Dados do Contrato " OF oDlg COLOR 0, 16777215 PIXEL
		oGroup1:oFont := oFont14

		@ 015, 009 SAY oSay1 PROMPT "Contrato:" SIZE 025, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 015, 037 SAY oContrato PROMPT cContrato SIZE 025, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL

		@ 015, 068 SAY oSay2 PROMPT "Titular:" SIZE 025, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 015, 091 SAY oTitular PROMPT cTitular SIZE 134, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL

		@ 028, 009 SAY oSay3 PROMPT "Data Ativacao:" SIZE 050, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 028, 067 SAY oAtivacao PROMPT dAtivacao SIZE 035, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL

		@ 028, 110 SAY oSay4 PROMPT "Data Locacacao:" SIZE 045, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 028, 168 SAY oLocacao PROMPT dLocacao SIZE 025, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL

		@ 041, 009 SAY oSay5 PROMPT "Parcelas Pagas:" SIZE 052, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 041, 067 SAY oParcPagas PROMPT nParPagas SIZE 025, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL

		@ 041, 110 SAY oSay6 PROMPT "Qtd Parcelas:" SIZE 045, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 041, 168 SAY oParcelas PROMPT nParcelas SIZE 025, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL

		@ 054, 009 SAY oSay7 PROMPT "Parcelas Vencidas:" SIZE 055, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 054, 067 SAY oParcVenc PROMPT nParcVencidas SIZE 025, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL

		@ 054, 110 SAY oSay8 PROMPT "Restantes:" SIZE 031, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 054, 168 SAY oParcRest PROMPT nParcRestantes SIZE 025, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL

		@ 067, 009 SAY oSay9 PROMPT "Valor da Parcela:" SIZE 055, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 067, 067 SAY oVlrParc PROMPT  AllTrim(TransForm(nValorParc,"@E 999,999.99")) SIZE 037, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL

		@ 088, 003 GROUP oGroup2 TO 117, 296 PROMPT " Dados do Adiantamento " OF oDlg COLOR 0, 16777215 PIXEL
		oGroup2:oFont := oFont14

		@ 101, 009 SAY oSay10 PROMPT "Parcelas:" SIZE 031, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 100, 038 MSGET oGet1 VAR nGetParc SIZE 050, 010 OF oDlg COLORS 8421504, 16777215 PICTURE "@E 99999" HASBUTTON PIXEL

		@ 101, 108 SAY oSay11 PROMPT "Valor:" SIZE 025, 007 OF oDlg FONT oFont13N COLORS 0, 16777215  PIXEL
		@ 100, 131 MSGET oGet2 VAR nGetVlr SIZE 050, 010 OF oDlg COLORS 8421504, 16777215 PICTURE "@E 999,999.99" HASBUTTON PIXEL

		@ 121, 003 GROUP oGroup3 TO 142, 296 OF oDlg COLOR 0, 16777215 PIXEL

		@ 126, 209 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 Action(FWMsgRun(,{|oSay| ConfirmaAdt(oSay,oDlg,nGetParc,nGetVlr,cContrato) },'Aguarde...','Carregando Dados para Geracao de Adiantamento...')) OF oDlg PIXEL
		@ 126, 252 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 Action( oDlg:End()) OF oDlg PIXEL

		ACTIVATE MSDIALOG oDlg CENTERED

	endif

	RestArea( aAreaU00 )
	RestArea( aArea )

Return

/*/{Protheus.doc} ConfirmaAdt
//Funcao para gerar os adiantamentos das parcelas
do contrato
@author g.sampaio
@since 18/02/2020
@version 1.0
@return lRet, Gerado ou nao adiantamento
@type function
/*/
Static Function ConfirmaAdt(oSay,oDlg,nQtdParc,nVlrParc,cContrato)

	Local aArea				:= GetArea()
	Local aAreaSE1			:= SE1->(GetArea())
	Local aAreaU00			:= U00->(GetArea())
	Local aDados			:= {}
	Local aHistorico		:= {}
	Local lUsaPrimVencto	:= SuperGetMv("MV_XPRIMVC",.F.,.F.)
	Local lRet				:= .T.
	Local lContinua			:= .T.
	Local cPrefixo 			:= AllTrim(SuperGetMv("MV_XPRELOC",.F.,"LOC"))	// prefixo do titulo de locação
	Local cTipo				:= AllTrim(SuperGetMv("MV_XTPADLO",.F.,"ADT"))	// tipo do titulo de adiantamento de locação
	Local cNatureza			:= AllTrim(SuperGetMv("MV_XNATLOC",.F.,U00->U00_NATURE))
	Local cMesAno			:= ""
	Local cParcela			:= ""
	Local nX				:= 0
	Local dLastVencto		:= CTOD("")
	Local dVencimento		:= CTOD("")

	Private lMsErroAuto		:= .F.

	Default nQtdParc		:= 0
	Default nVlrParc 		:= 0
	Default cContrato		:= ""

	// valida se o tipo de titulo existe
	lContinua	:= ValidaTipoFin(cTipo)

	//valido se está tudo certo
	if lContinua

		//valido se foi digitado a quantidade de parcelas e valores
		If nQtdParc > 0 .And. nVlrParc > 0

			//dia de vencimento das parcelas
			cDiaVencto	:= if(!Empty(U00->U00_DIAVEN),U00->U00_DIAVEN,SubStr(DTOC(U00->U00_PRIMVE),1,2))
			dLastVencto	:= LastVencto(U74->U74_CODIGO, cContrato)
			cParcela	:= LastParcela(U74->U74_CODIGO, cContrato)

			Begin Transaction

				For nX := 1 To nQtdParc

					//valido se o dia de vencimento e maior que o ultimo dia do proximo mes
					if Val(cDiaVencto) > Val(Day2Str( LastDay(MonthSum(dLastVencto,1) ) ) )

						dVencimento := CtoD( cValToChar(Day(LastDay(MonthSum(dLastVencto,1)))) + "/" + Month2Str( MonthSum(dLastVencto,1)) + "/" + Year2Str(MonthSum(dLastVencto,1) ) )

					else

						dVencimento := CtoD( cDiaVencto + "/" + Month2Str( MonthSum(dLastVencto,1)) + "/" + Year2Str(MonthSum(dLastVencto,1) ) )

					endif

					oSay:cCaption := ("Contrato: " + AllTrim(cContrato) + ", gerando parcela " + cParcela + ", vencimento " + DTOC(dVencimento) + " ...")
					ProcessMessages()

					cMesAno 	:= SubStr(DTOC(dVencimento),4,7)
					aDados		:= {}

					AAdd(aDados, {"E1_FILIAL"	, xFilial("SE1")					, Nil } )
					AAdd(aDados, {"E1_PREFIXO"	, cPrefixo          				, Nil } )
					AAdd(aDados, {"E1_NUM"		, U74->U74_CODIGO 	   				, Nil } )
					AAdd(aDados, {"E1_PARCELA"	, cParcela							, Nil } )
					AAdd(aDados, {"E1_TIPO"		, cTipo		 						, Nil } )
					AAdd(aDados, {"E1_NATUREZ"	, cNatureza							, Nil } )
					AAdd(aDados, {"E1_CLIENTE"	, U00->U00_CLIENT					, Nil } )
					AAdd(aDados, {"E1_LOJA"		, U00->U00_LOJA						, Nil } )
					AAdd(aDados, {"E1_EMISSAO"	, dDataBase							, Nil } )
					AAdd(aDados, {"E1_VENCTO"	, dVencimento						, Nil } )
					AAdd(aDados, {"E1_VENCREA"	, DataValida(dVencimento)			, Nil } )
					AAdd(aDados, {"E1_VALOR"	, nVlrParc							, Nil } )
					AAdd(aDados, {"E1_XCONTRA"	, cContrato							, Nil } )
					AAdd(aDados, {"E1_HIST"		, "ADIANTAMENTO DE TX LOCAÇÃO"		, Nil } )
					AAdd(aDados, {"E1_XPARCON"	, cMesAno							, Nil } )
					AAdd(aDados, {"E1_XFORPG"	, U00->U00_FORPG					, Nil } )

					// array de historico de adiantamento
					AAdd(aHistorico,{cPrefixo,cContrato,cParcela,cTipo,nVlrParc})

					//o ultimo vencimento sempre assume a data da ultima parcela
					dLastVencto := dVencimento
					cParcela	:= Soma1(cParcela)

					lMsErroAuto := .F.

					MSExecAuto({|x,y| FINA040(x,y)},aDados,3)

					if lMsErroAuto

						MostraErro()
						DisarmTransaction()
						lRet := .F.
						Exit

					else
						lRet := .T.
					endif

				Next nX

			End Transaction

			//se gravou os titulos corretamente, gravo historico de adiantamentos
			if lRet

				lRet := GravaHistorico(cContrato,U00->U00_CLIENT,U00->U00_LOJA,aHistorico)

			endif

			//adiantamento gerado com sucesso
			if lRet
				MsgInfo("Titulo(s) de Adiantamento gerados com sucesso!")
				oDlg:End()
			endif


		else

			lRet := .F.
			Help(,,'Help',,"Os campos Quantidade de Parcelas e Valor das Parcelas é obrigatório, Favor digite-os antes de confirmar!",1,0)

		endif

	endIf

	RestArea(aAreaSE1)
	RestArea(aAreaU00)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} LastVencto
//Funcao para consultar a data de vencimento
da ultima parcela do contrato
do contrato
@author g.sampaio
@since 20/02/2020
@version 1.0
@return lRet, Gerado ou nao adiantamento
@type function
/*/
Static Function LastVencto(cCodLoc, cContrato)

	Local cPrefixo		:= AllTrim(SuperGetMv("MV_XPRELOC",.F.,"LOC"))
	Local cTipoADT		:= AllTrim(SuperGetMv("MV_XTPADLO",.F.,"ADT"))
	Local cTipoParc		:= AllTrim(SuperGetMv("MV_XTIPLOC",.F.,"AT"))
	Local cQry 			:= ""
	Local dLastVencto	:= CTOD("")
	Local cLastParc		:= ""

	Default cCodLoc		:= ""
	Default cContrato	:= ""

	If Select("QRYTIT") > 0
		QRYTIT->(DbCloseArea())
	EndIf

	cQry := " SELECT "
	cQry += " MAX(E1_VENCTO) VENCIMENTO "
	cQry += " FROM "
	cQry += " " + RetSQLName("SE1") + " SE1 "
	cQry += " WHERE "
	cQry += " SE1.D_E_L_E_T_ = ' ' "
	cQry += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
	cQry += " AND SE1.E1_PREFIXO = '" + cPrefixo + "'"
	cQry += " AND SE1.E1_TIPO IN ('" + cTipoADT + "','" + cTipoParc+ "') "
	cQry += " AND SE1.E1_NUM	 = '" + cCodLoc + "'"
	cQry += " AND SE1.E1_XCONTRA = '" + cContrato + "' "

	cQry := Changequery(cQry)

	TcQuery cQry New Alias "QRYTIT"

	dLastVencto := STOD(QRYTIT->VENCIMENTO)

	If Select("QRYTIT") > 0
		QRYTIT->(DbCloseArea())
	EndIf

Return(dLastVencto)

/*/{Protheus.doc} LastParcela
//Funcao para consultar a data de vencimento
da ultima parcela do contrato
do contrato
@author g.sampaio
@since 29/03/2018
@version 1.0
@return lRet, Gerado ou nao adiantamento
@type function
/*/
Static Function LastParcela(cCodLoc, cContrato)

	Local cPrefixo		:= AllTrim(SuperGetMv("MV_XPRELOC",.F.,"LOC"))
	Local cTipoADT		:= AllTrim(SuperGetMv("MV_XTPADLO",.F.,"ADT"))
	Local cTipoParc		:= AllTrim(SuperGetMv("MV_XTIPLOC",.F.,"AT"))
	Local cQry 			:= ""
	Local cLastParc		:= ""

	Default cCodLoc		:= ""
	Default cContrato	:= ""

	If Select("QRYTIT") > 0
		QRYTIT->(DbCloseArea())
	EndIf

	cQry := " SELECT "
	cQry += " COUNT(*) QTD_PARC "
	cQry += " FROM "
	cQry += " " + RetSQLName("SE1") + " SE1 "
	cQry += " WHERE "
	cQry += " SE1.D_E_L_E_T_ = ' ' "
	cQry += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
	cQry += " AND SE1.E1_PREFIXO = '" + cPrefixo + "'"
	cQry += " AND SE1.E1_TIPO IN ('" + cTipoADT + "','" + cTipoParc+ "') "
	cQry += " AND SE1.E1_NUM	 = '" + cCodLoc + "'"
	cQry += " AND SE1.E1_XCONTRA = '" + cContrato + "' "

	cQry := Changequery(cQry)

	TcQuery cQry New Alias "QRYTIT"

	// se existir títulos com este tipo
	if QRYTIT->(!Eof()) .AND. !Empty(QRYTIT->QTD_PARC)
		cLastParc := STRZERO(QRYTIT->QTD_PARC + 1,3)
	else
		cLastParc := Padl("1",TamSX3("E1_PARCELA")[1],"0")
	endif

	If Select("QRYTIT") > 0
		QRYTIT->(DbCloseArea())
	EndIf

Return(cLastParc)


/*/{Protheus.doc} GravaHistorico
//Funcao para gerar o historico do adiantamento gerado
da ultima parcela do contrato
do contrato
@author g.sampaio
@since 21/02/2020
@version 1.0
@return lRet, Gerado ou nao adiantamento
@type function
/*/
Static Function GravaHistorico(cContrato,cCliente,cLoja,aDados)

	Local oAux
	Local oStruct
	Local cMaster 		:= "U76"
	Local cDetail		:= "U77"
	Local aCpoMaster	:= {}
	Local aLinha		:= {}
	Local aCpoDetail	:= {}
	Local oModel  		:= FWLoadModel("RCPGA045") // instanciamento do modelo de dados
	Local nX			:= 1
	Local nI       		:= 0
	Local nJ       		:= 0
	Local nPos     		:= 0
	Local lRet     		:= .T.
	Local aAux	   		:= {}
	Local nItErro  		:= 0
	Local lAux     		:= .T.
	Local cItem 		:= PADL("1",TamSX3("U77_ITEM")[1],"0")

	aadd(aCpoMaster,{"U76_FILIAL"	, xFilial("U76")	})
	aadd(aCpoMaster,{"U76_DATA"		, dDataBase			})
	aadd(aCpoMaster,{"U76_CONTRA"	, cContrato			})
	aadd(aCpoMaster,{"U76_CLIENT"	, cCliente			})
	aadd(aCpoMaster,{"U76_LOJA"		, cLoja				})
	aadd(aCpoMaster,{"U76_USER"		, cUserName			})
	aadd(aCpoMaster,{"U76_CODLOC"	, U74->U74_CODIGO	})

	For nX := 1 To Len(aDados)

		aLinha := {}

		aadd(aLinha,{"U77_FILIAL"	, xFilial("U77")	})
		aadd(aLinha,{"U77_ITEM"		, cItem				})
		aadd(aLinha,{"U77_PREFIX"	, aDados[nX,1]		})
		aadd(aLinha,{"U77_NUM"		, aDados[nX,2]		})
		aadd(aLinha,{"U77_PARCEL"	, aDados[nX,3]		})
		aadd(aLinha,{"U77_TIPO"		, aDados[nX,4]		})
		aadd(aLinha,{"U77_VALOR"	, aDados[nX,5]		})

		aadd(aCpoDetail,aLinha)

		cItem := SOMA1(cItem)

	Next nX

	(cDetail)->(DbSetOrder(1))
	(cMaster)->(DbSetOrder(1))

	// defino a operação de inclusão
	oModel:SetOperation(3)

	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	lRet := oModel:Activate()

	If lRet

		// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
		oAux := oModel:GetModel( cMaster + 'MASTER' )

		// Obtemos a estrutura de dados do cabeçalho
		oStruct := oAux:GetStruct()
		aAux := oStruct:GetFields()

		If lRet

			For nI := 1 To Len(aCpoMaster)

				// Verifica se os campos passados existem na estrutura do cabeçalho
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoMaster[nI][1] ) } ) ) > 0

					// È feita a atribuicao do dado aos campo do Model do cabeçalho
					If !( lAux := oModel:SetValue( cMaster + 'MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )

						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						lRet    := .F.
						Exit

					EndIf

				EndIf

			Next nI

		EndIf

	EndIf

	If lRet

		// Intanciamos apenas a parte do modelo referente aos dados do item
		oAux := oModel:GetModel( cDetail + 'DETAIL' )

		// Obtemos a estrutura de dados do item
		oStruct := oAux:GetStruct()
		aAux := oStruct:GetFields()

		nItErro  := 0

		For nI := 1 To Len(aCpoDetail)

			// Incluímos uma linha nova
			// ATENCAO: O itens são criados em uma estrura de grid (FORMGRID), portanto já é criada uma primeira linha
			//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez

			If nI > 1

				// Incluimos uma nova linha de item

				If  ( nItErro := oAux:AddLine() ) <> nI

					// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
					// ele retorna a quantidade de linhas já
					// existem no grid. Se conseguir retorna a quantidade mais 1
					lRet    := .F.
					Exit

				EndIf

			EndIf

			For nJ := 1 To Len( aCpoDetail[nI] )

				// Verifica se os campos passados existem na estrutura de item
				If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0

					If !( lAux := oModel:SetValue( cDetail + 'DETAIL', aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )

						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						lRet    := .F.
						nItErro := nI
						Exit

					EndIf

				EndIf

			Next nJ

			If !lRet
				Exit
			EndIf

		Next nI

	EndIf

	If lRet

		// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
		// neste momento os dados não são gravados, são somente validados.
		If ( lRet := oModel:VldData() )

			// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
			lRet := oModel:CommitData()

		EndIf

	EndIf

	If !lRet

		// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
		aErro   := oModel:GetErrorMessage()

		// A estrutura do vetor com erro é:
		//  [1] Id do formulário de origem
		//  [2] Id do campo de origem
		//  [3] Id do formulário de erro
		//  [4] Id do campo de erro
		//  [5] Id do erro
		//  [6] mensagem do erro
		//  [7] mensagem da solução
		//  [8] Valor atribuido
		//  [9] Valor anterior

		AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
		AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
		AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
		AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
		AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
		AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
		AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
		AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
		AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )

		If nItErro > 0
			AutoGrLog( "Erro no Item:              " + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' )
		EndIf

		MostraErro()

	EndIf

// Desativamos o Model
	oModel:DeActivate()

Return(lRet)

/*/{Protheus.doc} ValidAntPar
description
@type function
@version 
@author g.sampaio
@since 11/03/2020
@param cCodCtr, param_type, param_description
@return return_type, return_description
/*/
Static Function ValidAntPar( cCodigoCtr, cCodPlano, cStatusCtr )

	Local aArea 		:= GetArea()
	Local aAreaU05		:= U05->( GetArea() )
	Local lRetorno		:= .T.

	Default cCodigoCtr	:= ""
	Default cCodPlano	:= ""
	Default cStatusCtr	:= ""

	// primeiro verifico se o contrato está ativo
	If cStatusCtr $ "P/S/C"

		// retorno falso pois o contrato não está ativo
		lRetorno	:= .F.
		Help(,,'Help',,"Permitido realizar adiantamento de taxa de locação apenas para contratos ativos ou finalizados!",1,0)

	EndIf

	// posiciono no plano
	U05->( DbSetOrder(1) )
	If lRetorno .And. U05->( MsSeek( xFilial("U05")+cCodPlano ) )

		// verifico se existe taxa de locacao maior que zero
		If !(U05->U05_TXLOCN > 0)

			// retorno falso pois o contrato não está ativo
			lRetorno	:= .F.
			Help(,,'Help',,"Não é permitido gerar o adiantamento de taxa de locação para o plano!",1,0)

		EndIf

	Else

		// retorno falso pois o contrato não está ativo
		lRetorno	:= .F.
		Help(,,'Help',,"Não é permitido gerar o adiantamento de taxa de locação para o plano!",1,0)

	EndIf

	// verifico se esta tudo certo
	If lRetorno

		// vou verificar se o contrato tem parcelas de locacao
		lRetorno := ValParcLocacao( cCodigoCtr )

	EndIf

	RestArea( aAreaU05 )
	RestArea( aArea )

Return( lRetorno )

/*/{Protheus.doc} ValParcLocacao
Funcao para validar se o contrato
possui parcelas de locacao de locacao
@type function
@version 
@author g.sampaio
@since 04/04/2020
@param cCodigoCtr, character, codigo do contrato
@return lógico, retorna verdadeiro ou falso sobre a locacao de nicho
/*/
Static Function ValParcLocacao( cCodigoCtr )

	Local aArea			:= GetArea()
	Local cQuery 		:= ""
	Local lRetorno		:= .F.

	Default cCodigoCtr	:= ""

	If Select("TRBLOC") > 0
		TRBLOC->( DbCloseArea() )
	EndIf

	// query para verificar se existem registros de locacao de nicho para o contrato
	cQuery := " SELECT U74.U74_CONTRA CONTRATO "
	cQuery += " FROM " + RetSQLName("U74") + " U74 "
	cQuery += " WHERE U74.D_E_L_E_T_ = ' ' "
	cQuery += " AND U74.U74_FILIAL = '" + xFilial("U74") +"' "
	cQuery += " AND U74.U74_CONTRA = '" + cCodigoCtr + "'"

	cQuery := Changequery(cQuery)

	TcQuery cQuery New Alias "TRBLOC"

	// verifico se a query retornou registros
	If TRBLOC->(!Eof())
		lRetorno := .T.
	Else
		Help(,,'Help',,"Não é permitido gerar o adiantamento de taxa de locação para contratos que não tenham gerado taxa de locação!",1,0)
	EndIf

	If Select("TRBLOC") > 0
		TRBLOC->( DbCloseArea() )
	EndIf

	RestArea( aArea )

Return( lRetorno )

/*/{Protheus.doc} RetDataLocacao
funcao para a retornar a data da locacao
do nicho
@type function
@version 
@author g.sampaio
@since 04/04/2020
@param cCodigoCtr, character, codigo do contrato
@return data, data de locacao
/*/
Static Function RetDataLocacao( cCodigoCtr )

	Local aArea			:= GetArea()
	Local cQuery 		:= ""
	Local dRetorno		:= stod("")

	Default cCodigoCtr	:= ""

	If Select("TRBDAT") > 0
		TRBDAT->( DbCloseArea() )
	EndIf

	// query para retornar a data de locacao do nicho para o contrato
	cQuery := " SELECT U74.U74_DATA DTLOCACAO "
	cQuery += " FROM " + RetSQLName("U74") + " U74 "
	cQuery += " WHERE U74.D_E_L_E_T_ = ' ' "
	cQuery += " AND U74.U74_FILIAL = '" + xFilial("U74") +"' "
	cQuery += " AND U74.U74_CONTRA = '" + cCodigoCtr + "'"

	cQuery := Changequery(cQuery)

	TcQuery cQuery New Alias "TRBDAT"

	// verifico se a query retornou registros
	If TRBDAT->(!Eof())
		dRetorno := Stod(TRBDAT->DTLOCACAO)
	EndIf

	If Select("TRBDAT") > 0
		TRBDAT->( DbCloseArea() )
	EndIf

	RestArea( aArea )

Return( dRetorno )

/*/{Protheus.doc} RetParcLocacao
funcao para retornar a quantidade de parcelas 
de locacaho de nicho para um contrato 
@type function
@version 
@author g.sampaio
@since 04/04/2020
@param cCodigoCtr, character, codigo do contrato
@return numerico, numero de parcelas de locacao do nicho
/*/
Static Function RetParcLocacao( cCodigoCtr )

	Local aArea			:= GetArea()
	Local cQuery 		:= ""
	Local nRetorno		:= 0

	Default cCodigoCtr	:= ""

	If Select("TRBPAR") > 0
		TRBPAR->( DbCloseArea() )
	EndIf

	// query para retornar a quantidade de parcelas para a locacao do nicho para o contrato
	cQuery := " SELECT COUNT(*) CONTA FROM " + RetSQLName("U74") + " U74 "
	cQuery += " INNER JOIN " + RetSQLName("U75") + " U75 ON U75.D_E_L_E_T_ = ' ' "
	cQuery += " AND U75.U75_FILIAL	= '" + xFilial("SE1") + "'	"
	cQuery += " AND U75.U75_CODIGO = U74.U74_CODIGO "
	cQuery += " INNER JOIN " + RetSQLName("SE1") + " SE1 ON SE1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SE1.E1_FILIAL	= '" + xFilial("SE1") + "'	"
	cQuery += " AND SE1.E1_PREFIXO	= U75.U75_PREFIX "
	cQuery += " AND SE1.E1_NUM		= U75.U75_NUM "
	cQuery += " AND SE1.E1_PARCELA	= U75.U75_PARCEL "
	cQuery += " AND SE1.E1_TIPO		= U75.U75_TIPO "
	cQuery += " WHERE U74.D_E_L_E_T_ = ' ' "
	cQuery += " AND U74.U74_CONTRA = '" + cCodigoCtr + "'"

	cQuery := Changequery(cQuery)

	TcQuery cQuery New Alias "TRBPAR"

	// verifico se a query retornou registros
	If TRBPAR->(!Eof())
		nRetorno := TRBPAR->CONTA
	EndIf

	If Select("TRBPAR") > 0
		TRBPAR->( DbCloseArea() )
	EndIf

	RestArea( aArea )

Return( nRetorno )

/*/{Protheus.doc} RetParcPagas
description
@type function
@version 
@author g.sampaio
@since 04/04/2020
@param cCodigoCtr, character, param_description
@return return_type, return_description
/*/
Static Function RetParcPagas( cCodigoCtr )

	Local aArea			:= GetArea()
	Local cQuery 		:= ""
	Local nRetorno		:= 0

	Default cCodigoCtr	:= ""

	If Select("TRBPPG") > 0
		TRBPPG->( DbCloseArea() )
	EndIf

	// query para retornar a quantidade de parcelas pagas para a locacao do nicho para o contrato
	cQuery := " SELECT COUNT(*) CONTAPG FROM " + RetSQLName("U74") + " U74 "
	cQuery += " INNER JOIN " + RetSQLName("U75") + " U75 ON U75.D_E_L_E_T_ = ' ' "
	cQuery += " AND U75.U75_FILIAL	= '" + xFilial("SE1") + "'	"
	cQuery += " AND U75.U75_CODIGO = U74.U74_CODIGO "
	cQuery += " INNER JOIN " + RetSQLName("SE1") + " SE1 ON SE1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SE1.E1_FILIAL	= '" + xFilial("SE1") + "'	"
	cQuery += " AND SE1.E1_PREFIXO	= U75.U75_PREFIX "
	cQuery += " AND SE1.E1_NUM		= U75.U75_NUM "
	cQuery += " AND SE1.E1_PARCELA	= U75.U75_PARCEL "
	cQuery += " AND SE1.E1_TIPO		= U75.U75_TIPO "
	cQuery += " AND SE1.E1_SALDO 	= 0 "
	cQuery += " WHERE U74.D_E_L_E_T_ = ' ' "
	cQuery += " AND U74.U74_CONTRA = '" + cCodigoCtr + "'"

	cQuery := Changequery(cQuery)

	TcQuery cQuery New Alias "TRBPPG"

	// verifico se a query retornou registros
	If TRBPPG->(!Eof())
		nRetorno := TRBPPG->CONTAPG
	EndIf

	If Select("TRBPPG") > 0
		TRBPPG->( DbCloseArea() )
	EndIf

	RestArea( aArea )

Return( nRetorno )

/*/{Protheus.doc} RetParcVenc
//Funcao para consultar as parcelas vencidas
do contrato
@author g.sampaio
@since 20/02/2020
@version 1.0
@return nQtdParc, Quantidade de Parcelas vencidas
@type function
/*/
Static Function RetParcVenc(cCodigoCtr)

	Local aArea			:= GetArea()
	Local cQuery 		:= ""
	Local nRetorno		:= 0

	Default cCodigoCtr	:= ""

	If Select("TRBVEN") > 0
		TRBVEN->( DbCloseArea() )
	EndIf

	// query para retornar a quantidade de parcelas pagas para a locacao do nicho para o contrato
	cQuery := " SELECT COUNT(*) CONTAPG FROM " + RetSQLName("U74") + " U74 "
	cQuery += " INNER JOIN " + RetSQLName("U75") + " U75 ON U75.D_E_L_E_T_ = ' ' "
	cQuery += " AND U75.U75_FILIAL	= '" + xFilial("SE1") + "'	"
	cQuery += " AND U75.U75_CODIGO = U74.U74_CODIGO "
	cQuery += " INNER JOIN " + RetSQLName("SE1") + " SE1 ON SE1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SE1.E1_FILIAL	= '" + xFilial("SE1") + "'	"
	cQuery += " AND SE1.E1_PREFIXO	= U75.U75_PREFIX "
	cQuery += " AND SE1.E1_NUM		= U75.U75_NUM "
	cQuery += " AND SE1.E1_PARCELA	= U75.U75_PARCEL "
	cQuery += " AND SE1.E1_TIPO		= U75.U75_TIPO "
	cQuery += " AND SE1.E1_SALDO 	> 0 "
	cQuery += " AND SE1.E1_VENCREA  < '" + Dtos( dDataBase ) + "'"
	cQuery += " WHERE U74.D_E_L_E_T_ = ' ' "
	cQuery += " AND U74.U74_CONTRA = '" + cCodigoCtr + "'"

	cQuery := Changequery(cQuery)

	TcQuery cQuery New Alias "TRBVEN"

	// verifico se a query retornou registros
	If TRBVEN->(!Eof())
		nRetorno := TRBVEN->CONTAPG
	EndIf

	If Select("TRBVEN") > 0
		TRBVEN->( DbCloseArea() )
	EndIf

	RestArea( aArea )

Return( nRetorno )

/*/{Protheus.doc} ValidaTipoFin
funcao para validar o tipo do titulo
@type function
@version 
@author Administrador
@since 13/07/2020
@param cTipo, character, tipo do titulo de adiantamento
@return return_type, retorno lógico se o tipo do titulo existe
/*/
Static Function ValidaTipoFin(cTipo)

	Local aArea 	:= GetArea()
	Local aAreaSX5	:= SX5->( GetArea() )
	Local lRetorno	:= .T.

	// vou posicionar da tabela SX5 e verificar se o tipo do tipo existe
	// na tabela 05 - Tipos de Títulos
	SX5->( DbSetOrder(1) )
	if !SX5->( MsSeek( xFilial("SX5")+"05"+cTipo ) )

		lRetorno := .F.
		MsgAlert("O tipo do título <b><" + cTipo + "></b> não existe na tabela 05 - Tipos de Títulos";
			+ " entre em contato com o responsável técnico do sistema para preencher o <b>parametro <MV_XTIPADT></b> e tente";
		+ " realizar o processo novamente!" )

	endIf

	RestArea(aAreaSX5)
	RestArea(aArea)

Return(lRetorno)
