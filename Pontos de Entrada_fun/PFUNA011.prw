#INCLUDE 'PROTHEUS.CH'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} PFUNA011
Ponto de entrada do cadastro de historico de reajuste
da funerária
@type function
@version 1.0 
@author Wellington Gonçalves
@since 10/08/2016
/*/
User Function PFUNA011()

	Local aParam 		:= PARAMIXB
	Local oObj			:= aParam[1]
	Local cIdPonto		:= aParam[2]
	Local cIdModel		:= IIf( oObj<> NIL, oObj:GetId(), aParam[3] )
	Local cClasse		:= IIf( oObj<> NIL, oObj:ClassName(), '' )
	Local oModelUF7		:= oObj:GetModel( 'UF7MASTER' )
	Local oModelUF8		:= oObj:GetModel( 'UF8DETAIL' )
	Local lRet 			:= .T.
	Local lRejMd2		:= SuperGetMV("MV_XREJMD2", .F., .F.)
	Local aArea			:= GetArea()
	Local cCodigo		:= ""
	Local cContrato		:= ""
	Local nVlAdicional	:= 0

	if cIdPonto == "MODELVLDACTIVE" // ponto de entrada na abertura da tela

		// se a operação for de exclusão
		// devo validar se os títulos do reajuste não foram baixados
		if oObj:GetOperation() == 5

			// Verifica Reajuste Modelo 2
			if lRejMd2
				lRet := VerifReajMod2(oObj)
			endIf

			If lRet

				// percorro todos os itens do reajuste
				UF8->(DbSetOrder(1)) // UF8_FILIAL + UF8_CODIGO + UF8_ITEM
				if UF8->(DbSeek(xFilial("UF8") + UF7->UF7_CODIGO))

					While UF8->(!Eof()) .AND. UF8->UF8_FILIAL == xFilial("UF8") .And. UF8->UF8_CODIGO == UF7->UF7_CODIGO

						// posiciono no respectivo título a receber
						SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
						if SE1->(DbSeek(xFilial("SE1") + UF8->UF8_PREFIX + UF8->UF8_NUM + UF8->UF8_PARCEL + UF8->UF8_TIPO))

							//valido se o titulo esta em cobranca
							if !VldCobranca(UF8->UF8_PREFIX,UF8->UF8_NUM,UF8->UF8_PARCEL,UF8->UF8_TIPO)
								lRet := .F.
								Help( ,, "Help - MODELVLDACTIVE",, "Não é possível excluir este reajuste pois existem títulos em processo de cobrança!", 1, 0 )
								Exit
							elseIf SE1->E1_VALOR <> SE1->E1_SALDO // se o título já teve alguma baixa
								lRet := .F.
								Help( ,, "Help - MODELVLDACTIVE",, "Não é possível excluir este reajuste pois existem títulos que já foram baixados!", 1, 0 )
								Exit
							endif

						endif

						UF8->(DbSkip())

					EndDo

				endif

			EndIf

		endif

	elseIf cIdPonto ==  'MODELCOMMITTTS' // confirmação do cadastro

		if oObj:GetOperation() == 5 // se for exclusão

			// Verifica Reajuste Modelo 2
			if lRejMd2
				lRet := VerifReajMod2(oObj)
			endIf

			// Verifica Reajuste Modelo 2
			If lRet

				// Inicio o controle de transação
				BEGIN TRANSACTION

					cCodigo			:= oModelUF7:GetValue('UF7_CODIGO')
					cContrato 		:= oModelUF7:GetValue('UF7_CONTRA')
					nVlAdicional	:= oModelUF7:GetValue('UF7_VLADIC')

					// gero os títulos
					FWMsgRun(,{|oSay| lRet := ExcluiReaj(oSay, cCodigo, oObj)},'Aguarde...','Excluindo o reajuste do contrato...')

					// se foi realizada a exclusão dos títulos com sucesso, exclui os títulos da comissão
					if lRet

						UF2->(DbSetOrder(1)) // UF2_FILIAL + UF2_CODIGO
						if UF2->(DbSeek(xFilial("UF2") + cContrato))

							if RecLock("UF2",.F.)
								UF2->UF2_VLADIC -= nVlAdicional
								UF2->(MsUnLock())
							endif

						else
							lRet := .F.
						endif

					else
						// aborto a transação
						DisarmTransaction()
					endif

					// finalizo o controle de transação
				END TRANSACTION

			endif

		EndIf

	endif

	RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ExcluiReaj º Autor³ Wellington Gonçalves º Data³ 30/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que faz a exclusão dos títulos de reajuste		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funerária	                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ExcluiReaj(oSay,cCodigo,oModel)

	Local aArea			:= GetArea()
	Local aAreaUF8		:= UF8->(GetArea())
	Local aAreaSE1		:= SE1->(GetArea())
	Local aFin040		:= {}
	Local lRet 			:= .T.
	Local lRejMd2		:= SuperGetMV("MV_XREJMD2", .F., .F.)
	Local nX			:= 1
	Local oModelUF8		:= oModel:GetModel('UF8DETAIL')
	Local nLinhaAtual	:= oModelUF8:GetLine()
	Local cPrefixo		:= ""
	Local cNumero		:= ""
	Local cParcela		:= ""
	Local cTipo			:= ""

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	For nX := 1 To oModelUF8:Length()

		// posiciono na linha atual
		oModelUF8:Goline(nX)

		cPrefixo	:= oModelUF8:GetValue('UF8_PREFIX')
		cNumero		:= oModelUF8:GetValue('UF8_NUM')
		cParcela	:= oModelUF8:GetValue('UF8_PARCEL')
		cTipo		:= oModelUF8:GetValue('UF8_TIPO')

		SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
		if SE1->(DbSeek(xFilial("SE1") + cPrefixo + cNumero + cParcela + cTipo))

			aFin040		:= {}
			lMsErroAuto := .F.
			lMsHelpAuto := .T.

			oSay:cCaption := ("Excluindo parcela " + AllTrim(SE1->E1_PARCELA) + "...")
			ProcessMessages()

			If SE1->E1_VALOR == SE1->E1_SALDO // somente título que não teve baixa

				// faço a exclusão do título do bordero
				SEA->(DbSetOrder(1)) // EA_FILIAL + EA_NUMBOR + EA_PREFIXO + EA_NUM + EA_PARCELA + EA_TIPO + EA_FORNECE + EA_LOJA
				If SEA->(DbSeek(xFilial("SEA") + SE1->E1_NUMBOR + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO))

					if RecLock("SEA",.F.)
						SEA->(DbDelete())
						SEA->(MsUnlock())
					endif

					if RecLock("SE1",.F.)

						SE1->E1_SITUACA	:= "0"
						SE1->E1_OCORREN	:= ""
						SE1->E1_NUMBOR	:= ""
						SE1->E1_DATABOR	:= CTOD("  /  /    ")
						SE1->(MsUnLock())

					endif

				Endif

				// faço a exclusão do título a receber
				AAdd(aFin040, {"E1_FILIAL"  , SE1->E1_FILIAL  	, Nil})
				AAdd(aFin040, {"E1_PREFIXO" , SE1->E1_PREFIXO 	, Nil})
				AAdd(aFin040, {"E1_NUM"     , SE1->E1_NUM	   	, Nil})
				AAdd(aFin040, {"E1_PARCELA" , SE1->E1_PARCELA	, Nil})
				AAdd(aFin040, {"E1_TIPO"    , SE1->E1_TIPO  	, Nil})

				MSExecAuto({|x,y| Fina040(x,y)},aFin040,5)

				If lMsErroAuto
					MostraErro()
					Help( ,, 'Atenção',, "Ocorreu um erro na exclusão do título " + AllTrim(SE1->E1_NUM) + " parcela " + AllTrim(SE1->E1_PARCELA) + ". Não será possível continuar a operação.", 1, 0 )
					lRet := .F.
					Exit
				EndIf

			else
				Help( ,, 'Atenção',, "Foi realizada uma baixa para o título " + AllTrim(SE1->E1_NUM) + " parcela " + AllTrim(SE1->E1_PARCELA) + ". Não será possível continuar a operação.", 1, 0 )
				lRet := .F.
				Exit
			endif

		endif

	Next nX

	//-------------------------------//
	//-- Estorna reajuste modelo 2 --//
	//-------------------------------//
	If lRejMd2 .And. lRet
		lRet := EstornReaj2(oModel)
	EndIf

	// volto para a linha original
	oModelUF8:Goline(nLinhaAtual)

	RestArea(aAreaSE1)
	RestArea(aAreaUF8)
	RestArea(aArea)

Return(lRet)

////////////////////////////////////////////////////////////////////
////// FUNCAO PARA VALIDAR SE O TITULO ESTA EM COBRANCA		///////
///////////////////////////////////////////////////////////////////	
Static Function VldCobranca(cPrefixo,cTitulo,cParcela,cTipo)

	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local aAreaSE1	:= SE1->( GetArea() )
	Local aAreaSK1	:= SK1->( GetArea() )
	Local cQry 		:= ""

	cQry	:= " SELECT COUNT(*) QTD_COB "
	cQry 	+= " FROM "
	cQry	+= " 	" + RetSQLName("SK1") + " COBRANCA "
	cQry	+= " WHERE "
	cQry	+= " 	COBRANCA.K1_FILORIG = '" + xFilial("SK1") + "' "
	cQry	+= " 	AND COBRANCA.K1_PREFIXO = '" + cPrefixo + "' "
	cQry	+= " 	AND COBRANCA.K1_NUM 	= '" + cTitulo + "' "
	cQry	+= " 	AND COBRANCA.K1_PARCELA = '" + cParcela + "' "
	cQry	+= " 	AND COBRANCA.K1_TIPO	= '" + cTipo + "' "
	cQry 	+= " 	AND COBRANCA.K1_OPERAD	<> 'XXXXXX' " //XXXXXX Titulo marcado como excecao na cobranca

	If Select("QRYCOB") > 0
		QRYCOB->(DbCloseArea())
	Endif

	cQry := ChangeQuery(cQry)
	TcQuery cQry NEW Alias "QRYCOB"

	QRYCOB->( DbGotop() )

	If QRYCOB->QTD_COB > 0
		lRet	:= .F.
	endif

	RestArea(aArea)
	RestArea(aAreaSE1)
	RestArea(aAreaSK1)

Return( lRet )

/*/{Protheus.doc} EstornReaj2
Estorna reajuste modelo 2, retornando dados de regras e tabela de preço.
@type function
@version 1.0
@author nata.queiroz
@since 1/18/2021
@param oModel, object, oModel UF7 UF8
@return logical, lRet
/*/
Static Function EstornReaj2(oModel)
	Local lRet := .T.
	Local aArea := GetArea()
	Local aAreaU73 := U73->( GetArea() )
	Local oModelUF7 := oModel:GetModel('UF7MASTER')
	Local cCodHistAlt := oModelUF7:GetValue('UF7_HISALT')
	Local cContrato := oModelUF7:GetValue('UF7_CONTRA')
	Local aValoresCampo := {}
	Local oHistAlt := Nil

	If AllTrim( oModelUF7:GetValue('UF7_MOD2') ) == "S"

		//-- Prepara dados para histórico de alteração
		oHistAlt := JsonObject():New()
		oHistAlt["aUF4"] := {}
		oHistAlt["aUJ9"] := {}
		oHistAlt["aUF3"] := {}
		oHistAlt["aCampos"] := {}

		//-----------------------------------------------------//
		//-- Retorna valores de campos alterados no contrato --//
		//-----------------------------------------------------//
		U73->( DbSetOrder(1) )
		If U73->( MsSeek(xFilial("U73") + cCodHistAlt) )

			While U73->( !EOF() .AND. U73_FILIAL+U73_CODIGO == xFilial("U73") + cCodHistAlt )

				aValoresCampo := {}
				aValoresCampo := RetVlrsCpo()
				lRet := AlterarValorDoCampo(U73->U73_ALIAS, U73->U73_CHAVE, U73->U73_TIPCPO,;
					U73->U73_CAMPO, aValoresCampo[1], aValoresCampo[2], @oHistAlt)

				If !lRet
					Help(,, "EstornReaj2",, "Erro ao atualizar campo: " + U73->U73_CAMPO;
						+ ". Por favor verificar histórico de alteração: " + cCodHistAlt, 1, 0 )
					Exit
				EndIf

				U73->( DbSkip() )

			EndDo

		Else
			Help(,, "EstornReaj2",, "Histórico de alteração: " + cCodHistAlt + " não encontrado. Por favor verificar!", 1, 0 )
			lRet := .F.
		EndIf

		If lRet

			//------------------------------------------------------//
			//-- Atualiza dados de valores adicionais do contrato --//
			//------------------------------------------------------//
			lRet := AtualizarUJ9(cCodHistAlt, @oHistAlt)

		EndIf

		If lRet

			//----------------------------------------------------------//
			//-- Grava histórico de alterações realizadas no contrato --//
			//----------------------------------------------------------//
			lRet := GravaHist(cContrato, oHistAlt)

		EndIf

	EndIf

	RestArea( aArea )
	RestArea( aAreaU73 )

Return lRet

/*/{Protheus.doc} RetVlrsCpo
Retorna valores do campo no registro posicionado da tabela U73
@type function
@version 1.0
@author nata.queiroz
@since 1/18/2021
@return array, aValores
/*/
Static Function RetVlrsCpo()
	Local cTipo := U73->U73_TIPCPO
	Local aValores := {}

	If cTipo == "C"

		AADD(aValores, U73->U73_CVLANT)
		AADD(aValores, U73->U73_CVLPOS)

	ElseIf cTipo == "N"

		AADD(aValores, U73->U73_NVLANT)
		AADD(aValores, U73->U73_NVLPOS)

	ElseIf cTipo == "D"

		AADD(aValores, U73->U73_DVLANT)
		AADD(aValores, U73->U73_DVLPOS)

	ElseIf cTipo == "L"

		AADD(aValores, U73->U73_LVLANT)
		AADD(aValores, U73->U73_LVLPOS)

	ElseIf cTipo == "M"

		AADD(aValores, U73->U73_MVLANT)
		AADD(aValores, U73->U73_MVLPOS)

	EndIf

Return aValores

/*/{Protheus.doc} AlterarValorDoCampo
Altera valor do campo selecionado
@type function
@version 1.0
@author nata.queiroz
@since 1/20/2021
@param cAliasUtil, character, cAliasUtil
@param cChave, character, cChave
@param cTipoCampo, character, cTipoCampo
@param cCampo, character, cCampo
@param xValorAnt, param_type, xValorAnt
@param xValorPos, param_type, xValorPos
@param oHistAlt, object, oHistAlt
@return logical, lRet
/*/
Static Function AlterarValorDoCampo(cAliasUtil, cChave, cTipoCampo, cCampo, xValorAnt, xValorPos, oHistAlt)
	Local lRet := .T.
	Local aArea := GetArea()
	Local aAreaUF2 := UF2->( GetArea() )
	Local aAreaUF3 := UF3->( GetArea() )
	Local aAreaUF4 := UF4->( GetArea() )
	Local aCamposUF2 := {}
	Local aCamposUF3 := {}
	Local aCamposUF4 := {}
	Local aUF3 := {}
	Local aUF4 := {}

	If cAliasUtil == "UF2"

		UF2->( DbSetOrder(1) )
		If UF2->( MsSeek(xFilial("UF2") + cChave) )
			RecLock("UF2", .F.)
			UF2->&(cCampo) := xValorAnt
			UF2->( MsUnLock() )

			//-- Histórico Campos UF2
			aCamposUF2 := RetAltCpo(cAliasUtil, cChave, cCampo, xValorPos, xValorAnt)
			//-- Prepara histórico para gravação
			PrepHist(/*aUF4*/, /*aUJ9*/, /*aUF3*/, aCamposUF2, @oHistAlt)
		Else
			lRet := .F.
		EndIf

	ElseIf cAliasUtil == "UF3"

		UF3->( DbSetOrder(1) )
		If UF3->( MsSeek(xFilial("UF3") + cChave) )

			//-- Histórico UF3
			AADD(aUF3, {"U71_CONTRA", UF3->UF3_CODIGO	})
			AADD(aUF3, {"U71_ITEM"	, UF3->UF3_ITEM		})
			AADD(aUF3, {"U71_TIPO"	, UF3->UF3_TIPO		})
			AADD(aUF3, {"U71_PROD"	, UF3->UF3_PROD		})
			AADD(aUF3, {"U71_VLUNIT", UF3->UF3_VLRUNI	})
			AADD(aUF3, {"U71_QTD"	, UF3->UF3_QUANT	})
			AADD(aUF3, {"U71_VLTOT"	, UF3->UF3_VLRTOT	})
			AADD(aUF3, {"U71_TPALT"	, "A"				})

			RecLock("UF3", .F.)
			UF3->&(cCampo) := xValorAnt
			UF3->( MsUnLock() )

			//-- Histórico Campos UF3
			aCamposUF3 := RetAltCpo(cAliasUtil, cChave, cCampo, xValorPos, xValorAnt)
			//-- Prepara histórico para gravação
			PrepHist(/*aUF4*/, /*aUJ9*/, aUF3, aCamposUF3, @oHistAlt)

		Else
			lRet := .F.
		EndIf

	ElseIf cAliasUtil == "UF4"

		UF4->( DbSetOrder(1) )
		If UF4->( MsSeek(xFilial("UF4") + cChave) )

			//-- Histórico UF4
			AADD(aUF4, {"U69_CONTRA", UF4->UF4_CODIGO	})
			AADD(aUF4, {"U69_ITEM"	, UF4->UF4_ITEM		})
			AADD(aUF4, {"U69_NOME"	, UF4->UF4_NOME		})
			AADD(aUF4, {"U69_TPALT"	, "A"				})

			RecLock("UF4", .F.)
			UF4->&(cCampo) := xValorAnt
			UF4->( MsUnLock() )

			//-- Histórico Campos UF4
			aCamposUF4 := RetAltCpo(cAliasUtil, cChave, cCampo, xValorPos, xValorAnt)
			//-- Prepara histórico para gravação
			PrepHist(aUF4, /*aUJ9*/, /*aUF3*/, aCamposUF4, @oHistAlt)

		Else
			lRet := .F.
		EndIf

	EndIf

	RestArea( aArea )
	RestArea( aAreaUF3 )
	RestArea( aAreaUF4 )

Return lRet

/*/{Protheus.doc} AtualizarUJ9
Atualiza dados de valores adicionais do contrato
@type function
@version 1.0
@author nata.queiroz
@since 1/21/2021
@param cCodHistAlt, character, cCodHistAlt
@param oHistAlt, object, oHistAlt
@return logical, lRet
/*/
Static Function AtualizarUJ9(cCodHistAlt, oHistAlt)
	Local lRet := .T.
	Local cQry := ""
	Local aArea := GetArea()
	Local aAreaUJ9 := UJ9->( GetArea() )
	Local aAreaU70 := U70->( GetArea() )
	Local aUJ9 := {}

	cQry := "SELECT * FROM " + RetSQLName("U70")
	cQry += "WHERE D_E_L_E_T_ <> '*' "
	cQry += "AND U70_FILIAL = '"+ xFilial("U70") +"' "
	cQry += "AND U70_CODIGO = '"+ cCodHistAlt +"' "
	cQry := ChangeQuery(cQry)

	If Select("QRYU70") > 0
		QRYU70->( DbCloseArea() )
	EndIf

	TcQuery cQry New Alias "QRYU70"

	If QRYU70->( !EOF() )

		UJ9->( DbSetOrder(1) ) // UJ9_FILIAL+UJ9_CODIGO+UJ9_ITEM
		If UJ9->( MsSeek(xFilial("UJ9") + QRYU70->U70_CONTRA) )
			While UJ9->( !EOF() .AND. UJ9_FILIAL+UJ9_CODIGO == xFilial("UJ9")+QRYU70->U70_CONTRA )

				//-- Histórico UJ9
				aUJ9 := {}
				AADD(aUJ9, {"U70_CONTRA", UJ9->UJ9_CODIGO	})
				AADD(aUJ9, {"U70_ITBEN"	, UJ9->UJ9_ITUF4	})
				// AADD(aUJ9, {"U70_NOME"	, UJ9->UJ9_NOME		})
				AADD(aUJ9, {"U70_ITEM"	, UJ9->UJ9_ITEM		})
				AADD(aUJ9, {"U70_TIPO"	, UJ9->UJ9_TPREGR	})
				AADD(aUJ9, {"U70_VLUNIT", UJ9->UJ9_VLUNIT	})
				AADD(aUJ9, {"U70_QTD"	, UJ9->UJ9_QTD		})
				AADD(aUJ9, {"U70_VLTOT"	, UJ9->UJ9_VLTOT	})
				AADD(aUJ9, {"U70_TPALT"	, "E"				})

				If RecLock("UJ9", .F.)
					UJ9->( DbDelete() )
					UJ9->( MsUnlock() )
				EndIf

				//-- Prepara histórico para gravação
				PrepHist(/*aUF4*/, aUJ9, /*aUF3*/, /*aCampos*/, @oHistAlt)

				UJ9->( DbSkip() )
			EndDo
		EndIf

		While QRYU70->( !EOF() )

			If QRYU70->U70_TPALT == "E"

				RecLock("UJ9", .T.)
				UJ9->UJ9_FILIAL	:= xFilial("UJ9")
				UJ9->UJ9_ITEM	:= QRYU70->U70_ITEM
				UJ9->UJ9_CODIGO	:= QRYU70->U70_CONTRA
				UJ9->UJ9_REGRA	:= ""
				UJ9->UJ9_ITUJ5 	:= ""
				UJ9->UJ9_TPREGR	:= QRYU70->U70_TIPO
				UJ9->UJ9_VLRINI	:= 0
				UJ9->UJ9_VLRFIM	:= 0
				UJ9->UJ9_VLUNIT	:= QRYU70->U70_VLUNIT
				UJ9->UJ9_QTD	:= QRYU70->U70_QTD
				UJ9->UJ9_VLTOT	:= QRYU70->U70_VLTOT
				UJ9->UJ9_ITUF4	:= QRYU70->U70_ITBEN
				UJ9->( MsUnLock() )

				//-- Histórico UJ9
				aUJ9 := {}
				AADD(aUJ9, {"U70_CONTRA", UJ9->UJ9_CODIGO	})
				AADD(aUJ9, {"U70_ITBEN"	, UJ9->UJ9_ITUF4	})
				// AADD(aUJ9, {"U70_NOME"	, UJ9->UJ9_NOME		})
				AADD(aUJ9, {"U70_ITEM"	, UJ9->UJ9_ITEM		})
				AADD(aUJ9, {"U70_TIPO"	, UJ9->UJ9_TPREGR	})
				AADD(aUJ9, {"U70_VLUNIT", UJ9->UJ9_VLUNIT	})
				AADD(aUJ9, {"U70_QTD"	, UJ9->UJ9_QTD		})
				AADD(aUJ9, {"U70_VLTOT"	, UJ9->UJ9_VLTOT	})
				AADD(aUJ9, {"U70_TPALT"	, "I"				})

				//-- Prepara histórico para gravação
				PrepHist(/*aUF4*/, aUJ9, /*aUF3*/, /*aCampos*/, @oHistAlt)

			EndIf

			QRYU70->( DbSkip() )

		EndDo

	EndIf

	QRYU70->( DbCloseArea() )

	RestArea( aArea )
	RestArea( aAreaU70 )
	RestArea( aAreaUJ9 )

Return lRet

/*/{Protheus.doc} RetAltCpo
Retorna array estruturado para gravacao do historico de alteracao de campo
@type function
@version 1.0
@author nata.queiroz
@since 1/8/2021
@param cAliasUtil, character, cAliasUtil
@param cChave, character, cChave
@param cCampoAlias, character, cCampoAlias
@param xVlrAnt, param_type, xVlrAnt
@param xVlrPos, param_type, xVlrPos
@return array, aItens
/*/
Static Function RetAltCpo(cAliasUtil, cChave, cCampoAlias, xVlrAnt, xVlrPos)
	Local cTipo := TamSX3(cCampoAlias)[3]
	Local aItens := {}

	Default cAliasUtil := ""
	Default cChave := ""
	Default cCampoAlias := ""
	Default xVlrAnt := Nil
	Default xVlrPos := Nil

	if !Empty(cAliasUtil) .And. !Empty(cTipo)
		aadd(aItens,{"U73_ALIAS"	, cAliasUtil})
		aadd(aItens,{"U73_CHAVE"	, cChave})
		aadd(aItens,{"U73_TIPCPO"	, cTipo})
		aadd(aItens,{"U73_CAMPO"	, cCampoAlias })

		if cTipo == "C"

			aadd(aItens,{"U73_CVLANT"	, xVlrAnt})
			aadd(aItens,{"U73_CVLPOS"	, xVlrPos})

		elseif cTipo == "N"

			aadd(aItens,{"U73_NVLANT"	, xVlrAnt})
			aadd(aItens,{"U73_NVLPOS"	, xVlrPos})

		elseif cTipo == "D"

			aadd(aItens,{"U73_DVLANT"	, xVlrAnt})
			aadd(aItens,{"U73_DVLPOS"	, xVlrPos})

		elseif cTipo == "L"

			aadd(aItens,{"U73_LVLANT"	, xVlrAnt})
			aadd(aItens,{"U73_LVLPOS"	, xVlrPos})

		elseif cTipo == "M"

			aadd(aItens,{"U73_MVLANT"	, xVlrAnt})
			aadd(aItens,{"U73_MVLPOS"	, xVlrPos})

		endif
	endif

Return aItens

/*/{Protheus.doc} PrepHist
Prepara dados de histórico para gravação
@type function
@version 1.0
@author nata.queiroz
@since 1/8/2021
@param aUF4, array, aUF4
@param aUJ9, array, aUJ9
@param aUF3, array, aUF3
@param aCampos, array, aCampos
@param oHistAlt, object, oHistAlt
/*/
Static Function PrepHist(aUF4, aUJ9, aUF3, aCampos, oHistAlt)
	Default aUF4 := {}
	Default aUJ9 := {}
	Default aUF3 := {}
	Default aCampos := {}
	Default oHistAlt := Nil

	If oHistAlt <> Nil

		//-- Beneficiários
		If Len(aUF4) > 0
			If aScan( oHistAlt["aUF4"], {|x| x[1][2]+x[2][2] == aUF4[1][2]+aUF4[2][2] } ) == 0
				AADD( oHistAlt["aUF4"], aUF4 )
			EndIf
		EndIf

		//-- Cobranças Adicionais
		If Len(aUJ9) > 0
			AADD( oHistAlt["aUJ9"], aUJ9 )
		EndIf

		//-- Produtos e Serviços
		If Len(aUF3) > 0
			If aScan( oHistAlt["aUF3"], {|x| x[1][2]+x[2][2] == aUF3[1][2]+aUF3[2][2] } ) == 0
				AADD( oHistAlt["aUF3"], aUF3 )
			EndIf
		EndIf

		//-- Campos
		If Len(aCampos) > 0
			AADD( oHistAlt["aCampos"], aCampos )
		EndIf

	EndIf

Return

/*/{Protheus.doc} GravaHist
Grava histórico de alterações realizadas no contrato
@type function
@version 1.0
@author nata.queiroz
@since 1/21/2021
@param cContrato, character, cContrato
@param oHistAlt, object, oHistAlt
@return logical, lRet
/*/
Static Function GravaHist(cContrato, oHistAlt)
	Local lRet := .T.
	Local aArea := GetArea()
	Local aAreaUF2 := UF2->( GetArea() )
	Local aAreaU68 := U68->( GetArea() )
	Local aAreaU69 := U69->( GetArea() )
	Local aAreaU70 := U70->( GetArea() )
	Local aAreaU71 := U71->( GetArea() )
	Local aAreaU73 := U73->( GetArea() )
	Local cCodigo := ""
	Local cUsuario := RetCodUsr()
	Local aUF4 := {}
	Local aUJ9 := {}
	Local aUF3 := {}
	Local aCampos := {}
	Local nX := 0
	Local nY := 0

	UF2->( DbSetOrder(1) ) // UF2_FILIAL+UF2_CODIGO
	If UF2->( MsSeek(xFilial("UF2") + cContrato) )

		If Len( oHistAlt["aCampos"] ) > 0

			aUF4 := oHistAlt["aUF4"]
			aUJ9 := oHistAlt["aUJ9"]
			aUF3 := oHistAlt["aUF3"]
			aCampos := oHistAlt["aCampos"]

			cCodigo := GetSXENum("U68", "U68_CODIGO")

			//----------------------------//
			//-- CABEÇALHO DA ALTERAÇÃO --//
			//----------------------------//
			If RecLock("U68",.T.)

				U68->U68_FILIAL	:= xFilial("U68")
				U68->U68_CODIGO	:= cCodigo
				U68->U68_DATA	:= dDataBase
				U68->U68_HORA	:= SubStr(Time(),1,5)
				U68->U68_TIPO	:= "E" // C=Contrato;R=Reajuste;E=Exclusao do Reajuste
				U68->U68_CONTRA	:= UF2->UF2_CODIGO
				U68->U68_CLIENT	:= UF2->UF2_CLIENT
				U68->U68_LOJA	:= UF2->UF2_LOJA
				U68->U68_CODUSR	:= cUsuario

				U68->(ConfirmSx8())
			EndIf

			//-----------------------------//
			//-- BENEFICIARIOS ALTERADOS --//
			//-----------------------------//
			For nX := 1 To Len(aUF4)

				If RecLock("U69",.T.)

					U69->U69_FILIAL := xFilial("U69")
					U69->U69_CODIGO	:= cCodigo

					For nY := 1 To Len(aUF4[nX])
						U69->&(aUF4[nX,nY,1]) := aUF4[nX,nY,2]
					Next nY

					U69->(MsUnLock())

				EndIf

			Next nX

			//------------------------------------//
			//-- COBRANCAS ADICIONAIS ALTERADAS --//
			//------------------------------------//
			For nX := 1 To Len(aUJ9)

				If RecLock("U70",.T.)

					U70->U70_FILIAL := xFilial("U70")
					U70->U70_CODIGO	:= cCodigo

					For nY := 1 To Len(aUJ9[nX])
						U70->&(aUJ9[nX,nY,1]) := aUJ9[nX,nY,2]
					Next nY

					U70->(MsUnLock())

				EndIf

			Next nX

			//-------------------------//
			//-- PRODUTOS E SERVIÇOS --//
			//-------------------------//
			For nX := 1 To Len(aUF3)

				If RecLock("U71",.T.)

					U71->U71_FILIAL := xFilial("U71")
					U71->U71_CODIGO	:= cCodigo

					For nY := 1 To Len(aUF3[nX])
						U71->&(aUF3[nX,nY,1]) := aUF3[nX,nY,2]
					Next nY

					U71->(MsUnLock())

				EndIf

			Next nX

			//----------------------//
			//-- CAMPOS ALTERADOS --//
			//----------------------//
			For nX := 1 To Len(aCampos)

				If RecLock("U73",.T.)

					U73->U73_FILIAL := xFilial("U73")
					U73->U73_CODIGO	:= cCodigo

					For nY := 1 To Len(aCampos[nX])
						U73->&(aCampos[nX,nY,1]) := aCampos[nX,nY,2]
					Next nY

					U73->(MsUnLock())

				EndIf

			Next nX

		EndIf

	EndIf

	RestArea( aArea )
	RestArea( aAreaUF2 )
	RestArea( aAreaU68 )
	RestArea( aAreaU69 )
	RestArea( aAreaU70 )
	RestArea( aAreaU71 )
	RestArea( aAreaU73 )

Return lRet

/*/{Protheus.doc} VerifReajMod2
Verifica reajuste modelo 2
@type function
@version 1.0
@author nata.queiroz
@since 1/22/2021
@param oModel, object, oModel
@return logical, lRet
/*/
Static Function VerifReajMod2(oModel)
	Local lRet := .T.
	Local cQry := ""
	Local nQtdReg := 0
	Local aArea := GetArea()
	Local aAreaU68 := U68->( GetArea() )
	Local oModelUF7 := oModel:GetModel("UF7MASTER")
	Local cMod2 := ""
	Local cCodHistAlt := ""

	If !oModelUF7:lActivate
		oModelUF7:Activate()
	EndIf

	cMod2 := oModelUF7:GetValue("UF7_MOD2")
	cCodHistAlt := oModelUF7:GetValue("UF7_HISALT")

	If AllTrim(cMod2) == "S"

		If !Empty(cCodHistAlt)

			U68->( DbSetOrder(1) )
			If U68->( MsSeek(xFilial("U68") + cCodHistAlt) )

				cQry := " SELECT U68_CODIGO, U68_HORA "
				cQry += " FROM " + RetSQLName("U68")
				cQry += " WHERE D_E_L_E_T_ <> '*' "
				cQry += " AND U68_FILIAL = '"+ xFilial("U68") +"' "
				cQry += " AND U68_CODIGO <> '" + AllTrim(U68->U68_CODIGO) + "' "
				cQry += " AND U68_DATA >= '"+ DTOS(U68->U68_DATA) +"' "
				cQry += " AND U68_CONTRA = '"+ U68->U68_CONTRA +"' "
				cQry += " ORDER BY U68_CODIGO "

				cQry := ChangeQuery(cQry)

				If Select("QRYU68") > 0
					QRYU68->( DbCloseArea() )
				EndIf

				TcQuery cQry New Alias "QRYU68"

				While QRYU68->(!Eof()) .And. lRet

					If QRYU68->U68_HORA > U68->U68_HORA

						Help(,, "VerifReajMod2",, "Reajuste não pode ser excluído, pois houveram atualizações no contrato após este reajuste.", 1, 0 )
						lRet := .F.

					EndIf

					QRYU68->(DbSkip())
				EndDo

				QRYU68->( DbCloseArea() )

			EndIf

		Else
			Help(,, "VerifReajMod2",, "Reajuste Modelo 2 sem código de histórico de alteração. Por favor verificar!", 1, 0 )
			lRet := .F.
		EndIf

	EndIf

	RestArea( aArea )
	RestArea( aAreaU68 )

Return lRet
