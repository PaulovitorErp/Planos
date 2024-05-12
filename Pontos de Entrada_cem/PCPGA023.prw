#INCLUDE 'PROTHEUS.CH'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} PCPGA023
Ponto de entrada do cadastro de historico de taxa de
manutenção de contratos
@type function
@version 1.0
@author Wellington Gonçalves
@since 30/08/2016
@return return_type, return_description
/*/
User Function PCPGA023()

	Local aArea					:= GetArea()
	Local aAreaU27				:= U27->(GetArea())
	Local aParam 				:= PARAMIXB
	Local oObj					:= aParam[1]
	Local cIdPonto				:= aParam[2]
	Local cCodManutencaoAnt		:= ""
	Local cRegraManutencao		:= ""
	Local cFormaPagManutencao	:= ""
	Local oModelU26				:= oObj:GetModel('U26MASTER')
	Local oModelU27				:= oObj:GetModel('U27DETAIL')
	Local oVirtusFin			:= Nil
	Local lRet 					:= .T.
	Local lAtivaRegra	        := SuperGetMv("MV_XREGCEM",,.F.)	// parametro para ativacao da regra
	Local cCodigo				:= ""
	Local cContrato				:= ""
	Local nVlAdicional			:= 0
	Local nValorManutencao		:= 0

	If cIdPonto == "MODELVLDACTIVE" // ponto de entrada na abertura da tela

		// se a operação for de exclusão
		// devo validar se os títulos da manutenção não foram baixados
		If oObj:GetOperation() == 5 // se for exclusão

			// valido se a regra de negociacao esta habilitada
			If lAtivaRegra

				If lRet .And. U26->U26_STATUS == "3" // status finalizado
					lRet := .F.
					Help( ,, "Help - MODELVLDACTIVE",, "Não é possível excluir esta manutenção pois o ciclo da taxa de manutenção já está encerrado!", 1, 0 )
				EndIf

				// verIfico se existe enderecamento vinculado ao contrato da taxa de manutencao
				If lRet .And. U26->U26_STATUS == "2" .And. !ValidaEndereco(U26->U26_CONTRA) .And. PriManutencao(U26->U26_CONTRA)

					lRet := .F.
					Help( ,, "Help - MODELVLDACTIVE",, "Não é possível excluir esta manutenção pois existe endereço vinculado ao contrato!", 1, 0 )

				EndIf

				// verIfico se a regra ativada e
				If lRet .And. !IsInCallStack("U_RCPGE047")

					// valido o status do contrato
					If U26->U26_STATUS == "2" .And. U26->U26_CGERA == "1" .And. PriManutencao(U26->U26_CONTRA)

						U00->(DbSetOrder(1))
						If U00->(MsSeek(xFilial("U00")+U26->U26_CONTRA)) .And. U00->U00_STATUS $ "A/S"

							lRet := .F.
							Help( ,, "Help - MODELVLDACTIVE",, "Não é possível excluir esta manutenção pois foi gerada na ativação conforme a regra do contrato!", 1, 0 )

						EndIf

					EndIf

				EndIf

			EndIf

			U27->(DbSetOrder(1)) // U27_FILIAL + U27_CODIGO + U27_ITEM
			If lRet .And. U27->(DbSeek(xFilial("U27") + U26->U26_CODIGO))
				While lRet .And. U27->(!Eof()) .AND. U27->U27_FILIAL == xFilial("U27") .AND. U27->U27_CODIGO == U26->U26_CODIGO

					SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
					If lRet .And. SE1->(DbSeek(xFilial("SE1") + U27->U27_PREFIX + U27->U27_NUM + U27->U27_PARCEL + U27->U27_TIPO))

						// carrego a classe financeira do virtus
						oVirtusFin := VirtusFin():New()

						//valido se o titulo ja se encontra em cobranca
						If lRet .And. !oVirtusFin:VldCobranca( "C", xFilial("SE1"), U26->U26_CONTRA, U27->U27_PREFIX, U27->U27_NUM, U27->U27_PARCEL, U27->U27_TIPO)

							lRet := .F.
							Help( ,, 'Atenção',, "O título " + AllTrim(SE1->E1_NUM) + " parcela " + AllTrim(SE1->E1_PARCELA) + " se encontra em processo de cobranca. Não será possível continuar a operação.", 1, 0 )

						ElseIf lRet .And. SE1->E1_VALOR <> SE1->E1_SALDO // se o título já teve alguma baixa

							lRet := .F.
							Help( ,, "Help - MODELVLDACTIVE",, "Não é possível excluir esta manutenção pois existem títulos que já foram baixados!", 1, 0 )

						EndIf

					EndIf

					U27->(DbSkip())

				EndDo

			EndIf

		EndIf

	ElseIf cIdPonto == "MODELCOMMITTTS" // confirmação do cadastro

		If oObj:GetOperation() == 5 // se for exclusão

			cCodigo 		:= oModelU26:GetValue('U26_CODIGO')
			cContrato 		:= oModelU26:GetValue('U26_CONTRA')
			nVlAdicional	:= oModelU26:GetValue('U26_VLADIC')

			// Inicio o controle de transação
			BEGIN TRANSACTION

				// gero os títulos
				FWMsgRun(,{|oSay| lRet := ExcluiManut(oSay, cCodigo, cContrato, oModelU27, @cCodManutencaoAnt,;
					@cRegraManutencao, @cFormaPagManutencao, @nValorManutencao)},'Aguarde...','Excluindo as taxas de manutenção...')

				// se foi realizada a exclusão dos títulos com sucesso
				If lRet

					U00->(DbSetOrder(1)) // U00_FILIAL + U00_CODIGO
					If U00->(DbSeek(xFilial("U00") + cContrato))

						// volto o valor anterior da taxa de manutenção
						If U00->(RecLock("U00",.F.))

							If nValorManutencao > 0
								U00->U00_TXMANU := nValorManutencao
							EndIf

							If U00->U00_ADIMNT > 0
								U00->U00_ADIMNT -= nVlAdicional
							EndIf

							If !Empty(cFormaPagManutencao) .And. AllTrim(cFormaPagManutencao) <> AllTrim(U00->U00_FPTAXA)
								U00->U00_FPTAXA := cFormaPagManutencao
							EndIf

							If !Empty(cRegraManutencao) .And. AllTrim(cRegraManutencao) <> AllTrim(U00->U00_REGRA)
								U00->U00_REGRA	:= cRegraManutencao
							EndIf

							U00->(MsUnLock())
						Else
							U00->(DisarmTransaction())
						EndIf

					Else
						lRet := .F.
					EndIf

				EndIf

				// desfaco a transacao
				If !lRet
					DisarmTransaction()
				EndIf

			END TRANSACTION

		EndIf

	EndIf

	RestArea(aAreaU27)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} ExcluiManut
Função que faz a exclusão dos títulos da manutenção

@type function
@version 1.0
@author Wellington Gonçalves
@since 30/08/2016
@param oSay, object, objeto de dialogo
@param cCodigo, character, codigo da taxa de manutencao
@param oModelU27, object, modelo de dados da U27
@return logical, retorno se tudo deu certo
/*/
Static Function ExcluiManut(oSay, cCodigo, cContrato, oModelU27, cCodManutencao,;
		cRegraManutencao, cFormaPagManutencao, nValorManutencao)

	Local aArea				:= GetArea()
	Local aAreaSE1			:= SE1->(GetArea())
	Local aAreaU00			:= U00->(GetArea())
	Local lRetorno			:= .T.
	Local aFin040			:= {}
	Local lAtivaRegra		:= SuperGetMv("MV_XREGCEM",,.F.)	// parametro para ativacao da regra
	Local lRecorrencia		:= SuperGetMv("MV_XATVREC",.F.,.F.)
	Local nX				:= 0
	Local nLinhaAtual		:= oModelU27:GetLine()
	Local cPrefixo			:= ""
	Local cNumero			:= ""
	Local cParcela			:= ""
	Local cTipo				:= ""
	Local cStatusManutencao	:= ""
	Local oVirtusFin		:= Nil

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	Default cCodigo		:= ""
	Default cContrato	:= ""

	For nX := 1 To oModelU27:Length()

		// posiciono na linha atual
		oModelU27:Goline(nX)

		cPrefixo	:= oModelU27:GetValue('U27_PREFIX')
		cNumero		:= oModelU27:GetValue('U27_NUM')
		cParcela	:= oModelU27:GetValue('U27_PARCEL')
		cTipo		:= oModelU27:GetValue('U27_TIPO')

		SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
		If lRetorno .And. SE1->(MsSeek(xFilial("SE1") + cPrefixo + cNumero + cParcela + cTipo))

			aFin040		:= {}
			lMsErroAuto := .F.
			lMsHelpAuto := .T.

			oSay:cCaption := ("Excluindo parcelas da Taxa de Manutenção " + AllTrim(SE1->E1_PARCELA) + "...")
			ProcessMessages()

			If SE1->E1_VALOR == SE1->E1_SALDO // somente título que não teve baixa

				U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
				If lRecorrencia .And. U60->(MsSeek(xFilial("U60") + SE1->E1_XFORPG))

					U00->(DbSetOrder(1))
					If U00->(MsSeek(xFilial("SE1")+SE1->E1_XCONTRA))

						//verIfico se o contrato esta em recorrencia, caso nao esteja arquivo o cliente na Vindi
						If !U60->(MsSeek(xFilial("U60") + U00->U00_FORPG))

							// Envia arquivamento do cliente para Vindi
							lRetorno := U_UVIND20("C", cCodigoContrato, U00->U00_CLIENT, U00->U00_LOJA, cOrigem, cOrigemDesc)

							//se o contrato estiver em recorrencia, apenas excluo as parcelas da manutencao
						Else

							lRetorno := U_UExcTitulosVindi(cCodigoContrato, .T., cOrigem, cOrigemDesc)

						EndIf

					Else
						lRetorno := .F.
					EndIf

				EndIf

				If lRetorno

					// chamo a classe de financeiro da plataforma virtus
					oVirtusFin := VirtusFin():New()

					// faço a exclusão do título do bordero
					oVirtusFin:ExcBordTit( SE1->(Recno()) )

					lRetorno := oVirtusFin:ExcluiTituloFin( SE1->(Recno()) )

				EndIf

				// verIfico se deu tudo certo
				If !lRetorno
					Exit
				EndIf

			Else
				Help( ,, 'Atenção',, "Foi realizada uma baixa para o título " + AllTrim(SE1->E1_NUM) + " parcela " + AllTrim(SE1->E1_PARCELA) + ". Não será possível continuar a operação.", 1, 0 )
				lRetorno := .F.
				Exit
			EndIf

		EndIf

	Next nX

	If lRetorno .And. lAtivaRegra

		// volto o status da taxa de manutencao
		If lRetorno
			lRetorno := VoltaStatus(cContrato, cCodigo, @cCodManutencao, @cRegraManutencao,;
				@cFormaPagManutencao, @cStatusManutencao, @nValorManutencao)
		EndIf

		// valido se devo recriar o ciclo financeiro da taxa de manutencao anterior
		If lRetorno .And. !Empty(cCodManutencao) .And. cStatusManutencao <> "1"
			lRetorno := FinanceiroRegra(cCodManutencao)
		EndIf

		// ajusta o contrato conforme o historico da taxa de manuteencao
		If lRetorno .And. !Empty(cCodManutencao)
			lRetorno := AjustaContrato(cContrato, cCodManutencao)
		EndIf

	EndIf

	// volto para a linha original
	oModelU27:Goline(nLinhaAtual)

	RestArea(aAreaU00)
	RestArea(aAreaSE1)
	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} ValidaEndereco
Valida o endereço
@type function
@version 1.0
@author g.sampaio
@since 07/10/2020
@return logical, retorna se tem endereco
/*/
Static Function ValidaEndereco(cCodContrato)

	Local aArea 	:= GetArea()
	Local aAreaU04	:= U04->(GetArea())
	Local lRetorno	:= .T.
	Local lValEnder := SuperGetMv("MV_XMNTEND", .F., .T.) 	// parametro para habilitar a validacao do endereco

	Default cCodContrato	:= ""

	// verIfico se existe enderecamento para
	U04->(DbSetOrder(1))
	If lValEnder .And. U04->(MsSeek(xFilial("U04")+cCodContrato))
		lRetorno := .F. // tem contrato entao não permito a exclusao da taxa de manutencao
	EndIf

	RestArea(aAreaU04)
	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} VoltaStatus
Volta o Status da Taxa de Manutencao
@type function
@version 1.0
@author g.sampaio
@since 19/06/2021
@param cCodContrato, character, codigo do contrato
/*/
Static Function VoltaStatus(cCodContrato, cCodigo, cCodManutencao, cRegraManutencao,;
		cFormaPagManutencao, cStatusManutencao, nValorManutencao)

	Local aArea 	:= GetArea()
	Local aAreaU26	:= U26->(GetArea())
	Local cQuery 	:= ""
	Local lRetorno	:= .T.

	Default cCodContrato		:= ""
	Default cCodigo				:= ""
	Default cCodManutencao		:= ""
	Default cRegraManutencao	:= ""
	Default cFormaPagManutencao	:= ""
	Default cStatusManutencao	:= ""
	Default nValorManutencao	:= 0

	If Select("TMPSTATUS") > 0
		TMPSTATUS->(DBCloseArea())
	EndIf

	// query para verIficar se o contrato será feito reajuste
	cQuery += "  SELECT TOP 1"
	cQuery += "      	U26.U26_CODIGO 	AS CODIGO, "
	cQuery += "			U26.U26_STATUS	AS STATUS, "
	cQuery += "			U26.U26_DATA	AS DATA "
	cQuery += "  FROM "
	cQuery += +	RetSqlName("U26") + " U26 "
	cQuery += " WHERE "
	cQuery += "  	U26.D_E_L_E_T_ = ' ' "
	cQuery += "   	AND U26.U26_FILIAL = '" + xFilial("U26") + "' "
	cQuery += "     AND U26.U26_CONTRA = '" + cCodContrato + "' "
	cQuery += " 	AND U26.U26_CODIGO <> '" + cCodigo + "' "
	cQuery += " 	AND U26.U26_STATUS <> '1' "
	cQuery += " ORDER BY U26.U26_DATA DESC, U26.U26_CODIGO DESC "

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery( cQuery, 'TMPSTATUS' )

	If TMPSTATUS->(!Eof())

		U26->(DBSetOrder(1))
		If U26->(MsSeek(xFilial("U26")+TMPSTATUS->CODIGO))

			// pego os dados da manutencao
			cCodManutencao 		:= U26->U26_CODIGO
			cRegraManutencao	:= U26->U26_REGRA
			cFormaPagManutencao	:= U26->U26_FORPG
			nValorManutencao	:= U26->U26_TAXA - U26->U26_VLADIC

			If U26->(RecLock("U26", .F.))

				// para manutencao finalizada, apos enderecamento e primeira manutencao
				If U26->U26_STATUS == "3" .And. U26->U26_CGERA == "3" .And. PriManutencao(U26->U26_CONTRA) .And. U26->U26_IMPORT <> "S"
					U26->U26_STATUS := "1"
				ElseIf U26->U26_STATUS == "3"
					U26->U26_STATUS := "2"
				ElseIf U26->U26_STATUS == "2"
					U26->U26_STATUS := "1"
				EndIf

				U26->(MsUnLock())

				cStatusManutencao 	:= U26->U26_STATUS // pego o status atual
			Else
				U26->(DisarmTransaction())
			EndIf

		Else
			lRetorno := .F.
		EndIf

	EndIf

	If Select("TMPSTATUS") > 0
		TMPSTATUS->(DBCloseArea())
	EndIf

	RestArea(aAreaU26)
	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} PriManutencao
Funcao para verIficar a primeira manutencao
@type function
@version 1.0
@author g.sampaio
@since 04/01/2024
@param cCodContrato, character, codigo do contrato
@return logical, .T. - Não pode excluir apenas 1 registro, .F. - Pode excluir mais de um registro
/*/
Static Function PriManutencao(cCodContrato)

	Local cQuery 	:= ""
	Local lRetorno	:= .T.

	Default cCodContrato	:= ""

	// query para verIficar se o contrato será feito reajuste
	cQuery += "  SELECT COUNT(*) CONTA_U26"
	cQuery += "  FROM "
	cQuery += +	RetSqlName("U26") + " U26 "
	cQuery += " WHERE "
	cQuery += "  	U26.D_E_L_E_T_ = ' ' "
	cQuery += "   	AND U26.U26_FILIAL = '" + xFilial("U26") + "' "
	cQuery += "     AND U26.U26_CONTRA = '" + cCodContrato + "' "
	cQuery += " 	AND U26.U26_IMPORT <> 'S' "

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery( cQuery, 'TRBPRI' )

	If TRBPRI->(!Eof())
		If TRBPRI->CONTA_U26 > 1
			lRetorno := .F. // permito a excluasao
		EndIf
	EndIf

Return(lRetorno)

/*/{Protheus.doc} VoltaStatus
Volta o Status da Taxa de Manutencao
@type function
@version 1.0
@author g.sampaio
@since 19/06/2021
@param cCodigo, character, codigo da manutencao atual
/*/
Static Function FinanceiroRegra(cCodigo)

	Local aArea 				:= GetArea()
	Local lRetorno				:= .T.
	Local oRegraTaxaManutencao	:= Nil

	Default cCodigo			:= ""

	oRegraTaxaManutencao := RegraTaxaManutencao():New()
	lRetorno := oRegraTaxaManutencao:EfetivaRegra(cCodigo, .F., .T.)

	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} AjustaContrato
Funcao para ajustar os contratos com os da regra anterior
@type function
@version 1.0
@author g.sampaio
@since 2/25/2024
@param cContrato, character, codigo do contrato
@param cCodManutencao, character, codigo da manutencao
@return logical, retorno logico da funcao
/*/
Static Function AjustaContrato(cContrato, cCodManutencao)

	Local aArea 	:= GetArea()
	Local aAreaU00	:= U00->(GetArea())
	Local aAreaU26	:= U26->(GetArea())
	Local lRetorno	:= .T.

	Default cContrato		:= ""
	Default cCodManutencao	:= ""

	U00->(DbSetOrder(1))
	If U00->(MsSeek(xFilial("U00")+cContrato))

		U26->(DbSetOrder(1))
		If U26->(MsSeek(xFilial("U26")+cCodManutencao))

			// verifico se a forma de pagamento ou regra estao diferentes
			If AllTrim(U26->U26_FORPG) <> AllTrim(U00->U00_FPTAXA) .Or. AllTrim(U26->U26_REGRA) <> AllTrim(U00->U00_REGRA)

				// altero os dados no contrato
				If U00->(RecLock("U00", .F.))
					U00->U00_FPTAXA := AllTrim(U26->U26_FORPG)
					U00->U00_REGRA	:= AllTrim(U26->U26_REGRA)
					U00->(MsUnLock())
				Else
					U00->(DisarmTransaction())
				EndIf

			EndIf

		EndIf

	EndIf

	RestArea(aAreaU26)
	RestArea(aAreaU00)
	RestArea(aArea)

Return(lRetorno)
