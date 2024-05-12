#Include "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE 'fwmvcdef.ch'

#define DS_MODALFRAME   128

/*/{Protheus.doc} RFUNA004
Função que faz a ativação do contrato e gera os títulos
@type function
@version 1.0 
@author Wellington Gonçalves
@since 15/07/2016
@param lJob, logical, sendo executada por job
@param nQtdParc, numeric, quantidade de parcelas
@param nQtdAdt, numeric, quantidade de adiantamento
@return logical, retorna que o contrato foi ativado
/*/
User Function RFUNA004(lJob,nQtdParc,nQtdAdt, cMsgErro)

	Local aArea				:= GetArea()
	Local aAreaSA1			:= SA1->(GetArea())
	Local aAreaUF2			:= UF2->(GetArea())
	Local cTpReajuste		:= SuperGetMV("MV_XTPREAJ",,'1')
	Local lAtivaNumS2		:= SuperGetMV("MV_XATNMS2",,.F.)
	Local cNumSor			:= ""									// variavel de numero da sorte
	Local lAtivacao			:= .T.
	Local lComissao			:= .T.
	Local lAtivZerado		:= .F.
	Local lOK				:= .T.
	Local lExstSort			:= .F.
	Local lUsaNovaComissao	:= SuperGetMv("ES_NEWCOMI",,.F.)	// ativo o uso da nova comissao

	Default nQtdParc	:= 0
	Default nQtdAdt		:= 0
	Default lJob		:= .F.
	Default cMsgErro	:= ""

	Do Case

	Case UF2->UF2_STATUS == "A" //Ativo

		If !lJob
			MsgInfo("O Contrato já se encontra Ativo, operação não permitida.","Atenção")
		endIf

	Case UF2->UF2_STATUS == "C" //Cancelado

		If !lJob
			MsgInfo("O Contrato se encontra Cancelado, operação não permitida.","Atenção")
		endIf

	Case UF2->UF2_STATUS == "S" //Suspenso

		If !lJob
			MsgInfo("O Contrato se encontra Suspenso, operação não permitida.","Atenção")
		endIf

	Case UF2->UF2_STATUS == "F" //Finalizado

		If !lJob
			MsgInfo("O Contrato se encontra Finalizado, operação não permitida.","Atenção")
		endIf

	OtherWise

		if !lJob

			if MsgYesNo("Deseja ativar este contrato?")

				// se a forma de pagamento estiver vinculada a um metodo de pagamento VINDI
				if UF2->( FieldPos("UF2_FORPG") ) > 0  .And. !Empty(UF2->UF2_FORPG)

					U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
					if U60->(DbSeek(xFilial("U60") + UF2->UF2_FORPG))

						// se o metodo de pagamento estiver ativo
						if U60->U60_STATUS == "A"

							// tela para preenchimento do perfil de pagamento
							FWMsgRun(,{|oSay| lOK := IncPerfil()},'Aguarde...','Abrindo Perfil de Pagamento...')

						endIf

					endIf

				endIf

				if lOK

					// Inicio o controle de transação
					BEGIN TRANSACTION

						//valido se o contrato posssui valor preenchido para gerar as parcelas
						if UF2->UF2_VALOR > 0

							//valido o tipo de reajuste de contratos, sendo 1= Reajuste por data de aniversario e 2 = Reajuste Global
							if cTpReajuste == "1"

								// gero os títulos
								FWMsgRun(,{|oSay| lAtivacao := AtivaCTRFun(oSay)},'Aguarde...','Ativando o contrato...')

							else
								//monta tela para definicao de quantidade de parcelas que serao geradas para o contrato
								lAtivacao := GeraParcelas(UF2->UF2_CODIGO,UF2->UF2_PLANO)
							endIf

							// se foi realizada a ativação com sucesso, gera a comissão
							if lAtivacao

								// verifica se a nova comissao
								If !lUsaNovaComissao

									// Processa comissao do contrato
									FWMsgRun(,{|oSay| lComissao := U_RFUNA012(UF2->UF2_CODIGO)},'Aguarde...','Gerando a comissão para o contrato...')

								endIf
							endIf

						else

							if MsgYesNo("O Contrato não possui valor digitado, portanto não será gerado parcelas, deseja continuar?")

								lAtivZerado := .T.

							endIf

						endIf

						// se foi gerada a comissão com sucesso, atualiza o status do contrato
						if lAtivacao .And. (lAtivZerado .Or. lComissao)

							If !Empty(UF2->UF2_PLNSEG)
								//-- Verifica se existe sorteio
								lExstSort := U_RFUNE31B(UF2->UF2_PLNSEG)
								If lExstSort
									cNumSor := U_RFUNE031()
								endIf
							endIf

							RecLock("UF2",.F.)
							if !lAtivaNumS2
								UF2->UF2_NUMSOR := cNumSor
							else
								UF2->UF2_NUMSO2 := cNumSor
							endif
							UF2->UF2_STATUS := "A"
							UF2->UF2_DTATIV	:= dDataBase
							UF2->(MsUnlock())

							// verifico se conseguiu gravar normalmente
							if !Empty(cNumSor)
								// gravo a utilizacao do numero da sorte
								U_RFUNE31A( cNumSor , UF2->UF2_CODIGO)
							endIf

						endIf

						// se todo o processamento foi concluído com sucesso
						if lAtivacao .AND. lComissao;
								.And. (Empty(UF2->UF2_PLNSEG) .Or. !Empty(cNumSor) .Or. !lExstSort)

							////////////////////////////////////////////////////////////////////////
							////// Ponto de Entrada Apos a finalizacao da ativacao do contrato ////
							///////////////////////////////////////////////////////////////////////
							if ExistBlock("PFUNA04F")

								ExecBlock("PFUNA04F",.F.,.F.,{UF2->UF2_CODIGO,UF2->UF2_CLIENT,UF2->UF2_LOJA})

							endIf

							MsgInfo("Contrato ativado com sucesso!","Atenção")

						else

							lOK := .F.
							// aborto a transação
							DisarmTransaction()

							if !lAtivacao
								MsgInfo("Ocorreu um problema na ativação do Contrato, operação cancelada.","Atenção")
							elseif !lComissao
								MsgInfo("Ocorreu um problema na geração de comissão(ões) referente ao Contrato, operação cancelada.","Atenção")
							endIf

						endIf

					END TRANSACTION

				endIf
			endif

		Elseif lJob

			// Inicio o controle de transação
			BEGIN TRANSACTION

				//valido se o contrato posssui valor preenchido para gerar as parcelas
				if UF2->UF2_VALOR > 0

					//valido o tipo de reajuste de contratos, sendo 1= Reajuste por data de aniversario e 2 = Reajuste Global
					if cTpReajuste == "1"

						// gero os títulos
						lAtivacao := AtivaCTRFun(,nQtdParc,.T.,nQtdAdt,@cMsgErro)

					else

						lAtivacao := AtivaCTRFun(,nQtdParc,.T.,nQtdAdt,@cMsgErro)

					endIf

					// se foi realizada a ativação com sucesso, gera a comissão
					if lAtivacao

						// verifica se a nova comissao
						If !lUsaNovaComissao

							// Processa comissao do contrato
							lComissao := U_RFUNA012(UF2->UF2_CODIGO)

						endIf

					endIf

				else

					lAtivZerado := .T.

				endIf

				// se foi gerada a comissão com sucesso, atualiza o status do contrato
				if lAtivacao .And. (lAtivZerado .Or. lComissao)

					If !Empty(UF2->UF2_PLNSEG)
						//-- Verifica se existe sorteio
						lExstSort := U_RFUNE31B(UF2->UF2_PLNSEG)
						If lExstSort
							cNumSor := U_RFUNE031()
						endIf
					endIf

					RecLock("UF2",.F.)
					if !lAtivaNumS2
						UF2->UF2_NUMSOR := cNumSor
					else
						UF2->UF2_NUMSO2 := cNumSor
					endif
					UF2->UF2_STATUS := "A"
					UF2->UF2_DTATIV	:= dDataBase
					UF2->(MsUnlock())

					// verifico se conseguiu gravar normalmente
					if !Empty(cNumSor)
						// gravo a utilizacao do numero da sorte
						U_RFUNE31A( cNumSor , UF2->UF2_CODIGO)
					endIf

				endIf

				// se todo o processamento foi concluído com sucesso
				if lAtivacao .AND. lComissao;
						.And. ( Empty(UF2->UF2_PLNSEG) .Or. !Empty(cNumSor) .Or. !lExstSort )

					////////////////////////////////////////////////////////////////////////
					////// Ponto de Entrada Apos a finalizacao da ativacao do contrato ////
					///////////////////////////////////////////////////////////////////////
					if ExistBlock("PFUNA04F")

						ExecBlock("PFUNA04F",.F.,.F.,{UF2->UF2_CODIGO,UF2->UF2_CLIENT,UF2->UF2_LOJA})

					endIf

				else

					lOK := .F.
					// aborto a transação
					DisarmTransaction()
				endIf

				// finalizo o controle de transação
			END TRANSACTION

		endIf

	EndCase

	RestArea(aAreaUF2)
	RestArea(aAreaSA1)
	RestArea(aArea)

Return(lOK)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AtivaCTRFun ºAutor³Wellington Gonçalves º Data³ 15/07/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que gera os títulos do contrato					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funerária	                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AtivaCTRFun(oSay,nQtdParc,lJob,nQtdAdt,cMsgErro)

	Local aArea				:= GetArea()
	Local aAreaUF0			:= UF0->(GetArea())
	Local aAreaSE1			:= SE1->(GetArea())
	Local aParcelas			:= {}
	Local aRegras			:= {}
	Local lRet				:= .T.
	Local lDiaAlt			:= .F.
	Local lUsaPrimVencto	:= SuperGetMv("MV_XPRIMVC",.F.,.F.)
	Local cPrefixo 			:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
	Local cTipo				:= SuperGetMv("MV_XTIPFUN",.F.,"AT")
	Local cNatureza			:= UF2->UF2_NATURE
	Local cParcela			:= ""
	Local cContrato			:= UF2->UF2_CODIGO
	Local cCliente			:= UF2->UF2_CLIENT
	Local cLoja				:= UF2->UF2_LOJA
	Local cVendedor			:= UF2->UF2_VEND
	Local cDiaVenc			:= UF2->UF2_DIAVEN
	Local nValParc			:= UF2->UF2_VALOR 				// valor do plano
	Local nAdesao			:= UF2->UF2_ADESAO 				// valor da taxa de adesão
	Local nParcCtr			:= UF2->UF2_QTPARC				// Qtd3 Parcelas Contrato
	Local cFormaPgto		:= UF2->UF2_FORPG							// forma de pagamento
	Local nContVal			:= 0
	Local nValUltParc		:= 0
	Local nTamParcela		:= 3
	Local nValorTit			:= 0
	Local nQtdAdesao		:= iif(UF2->UF2_ADESAO > 0,1,0)
	Local nX 				:= 1
	Local dFirstVencto		:= IIF(lUsaPrimVencto,UF2->UF2_PRIMVE,CToD("")) // data de vencimento da primeira parcela
	Local dVenctoAux		:= CTOD("")
	Local dVencimento		:= CTOD("")
	Local nParcAdt			:= 0
	Local nPercJuros		:= GetMV("MV_TXPER")
	Local cAdesIgualPar 	:= ""
	Local lConsAniver		:= SuperGetMv("MV_XPARNIV",,.T.)

	Default nQtdAdt			:= 0
	Default	nQtdParc		:= 0
	Default lJob			:= .F.
	Default cMsgErro		:= ""

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.


	UF0->(DbSetOrder(1))

	//Valido se adesao será o mesmo valor da parcela
	If UF0->(Dbseek(xFilial("UF0")+UF2->UF2_PLANO))

		cAdesIgualPar:= UF0->UF0_ADPARC

	endIf

	//se chamado da funcao GeraParcelas a quantidade de parcelas estara preenchido
	if nQtdParc == 0

		nQtdParc := SuperGetmv('MV_XQTDATI',,12)

		//se a quantidade de parcelas do contrato for inferir a quantidade do parametro, gera a quantidade do contrato
		if nParcCtr < nQtdParc

			nQtdParc := nParcCtr

		endIf

	endIf

	For nX := 1 To (nQtdParc + nQtdAdesao)

		lMsErroAuto := .F.
		lMsHelpAuto := .T.
		aFin040 	:= {}
		cParcela 	:= StrZero(nX,nTamParcela)

		If !lJob
			oSay:cCaption := ("Gerando parcela " + cParcela + "...")
			ProcessMessages()
		endIf

		//utiliza o campo UF2_PRIMVE
		if lUsaPrimVencto

			// se for a primeira parcela e tiver taxa de adesão
			// o primeiro vencimento é a data base do sistema
			// e o valor do título é o valor da taxa de adesão
			if nX == 1 .AND. nQtdAdesao > 0

				dVencimento := dDataBase
				nValorTit	:= nAdesao
				nDesconto	:= 0 //valor de desconto nao se aplica a valor de entrada
			else

				// defino a data de vencimento da primeira parcela
				// e todos os vencimentos assumiram o mesmo dia de vencimento da primeira parcela
				if !Empty(dVenctoAux)

					//valido se o dia de vencimento e maior que o ultimo dia do proximo mes
					if Val(Day2Str( dVenctoAux ) ) > Val(Day2Str( LastDay(MonthSum(dVenctoAux,1)) ) )

						dVenctoAux	:= MonthSum(dVenctoAux,1)

						lDiaAlt	:= .T.

					else

						//Se o ultimo dia foi alterado, o proximo mes assume o dia de vencimento da primeira parcela novamente
						if lDiaAlt

							dVenctoAux	:= CtoD( Day2Str( dFirstVencto ) + "/" + Month2Str( MonthSum(dVenctoAux,1)) + "/" + Year2Str(MonthSum(dVenctoAux,1) ) )

							lDiaAlt	:= .F.

						else

							dVenctoAux	:= MonthSum(dVenctoAux,1)

						endIf

					endIf

				else

					dVenctoAux	:=  dFirstVencto

				endIf

				dVencimento	:= dVenctoAux
				nValorTit	:= nValParc

			endIf

		else

			// se for a primeira parcela e tiver taxa de adesão
			// o primeiro vencimento é a data base do sistema
			// e o valor do título é o valor da taxa de adesão
			if nX == 1 .AND. nQtdAdesao > 0
				dVencimento := dDataBase

				//Valido se Adesao considera o mesmo valor da parcela
				If cAdesIgualPar == "S"
					nValorTit	:= nValParc
				Else
					nValorTit	:= nAdesao
				endIf

				nDesconto	:= 0 //valor de desconto nao se aplica a valor de entrada
			else

				// as próximas parcelas iniciarão no próximo mês
				if nX == 1 .AND. nQtdAdesao == 0

					// se o dia de vencimento do contrato for maior que o dia da data base
					// o vencimento será para o próximo mês
					if Day(dDataBase) > Val(cDiaVenc)
						dDataAux	:= CTOD("01/" + StrZero(Month(dDataBase),2) + "/" + StrZero(Year(dDataBase),4))
						dDataAux	:= MonthSum(dDataAux,1) // somo um mes a data auxiliar
					else
						dDataAux	:= dDataBase
					endIf

				else

					dDataAux 	:= CTOD("01/" + StrZero(Month(dVencimento),2) + "/" + StrZero(Year(dVencimento),4))
					dDataAux	:= MonthSum(dDataAux,1) // somo um mes a data auxiliar

				endIf

				// se o dia de vencimento for maior que o último dia do mês
				// considera o último dia do mês
				if Val(cDiaVenc) > Day(LastDate(dDataAux))
					dVencimento := CTOD(StrZero(Day(LastDate(dDataAux)),2) + "/" + StrZero(Month(dDataAux),2) + "/" + StrZero(Year(dDataAux),4))
				else
					dVencimento := CTOD(cDiaVenc + "/" + StrZero(Month(dDataAux),2) + "/" + StrZero(Year(dDataAux),4))
				endIf

				nValorTit := nValParc

			endIf

		endIf

		//Valido se parametro que considera aniversarios no calculo da parcela, nao considera adesao
		if lConsAniver

			//Valido se nao é primeira parcela ou se adesao vai ser igual valor da parcela
			If nX > 1 .OR. (nX == 1 .AND. cAdesIgualPar == "S")
				aRegras   := {}
				nValorTit := U_RFUNE040(dVencimento,cContrato,@aRegras)
			endIf
		endIf

		DbSelectArea("SE1")

		aadd(aFin040, {"E1_FILIAL"	, xFilial("SE1")											, Nil } )
		aadd(aFin040, {"E1_PREFIXO"	, cPrefixo         						   					, Nil } )
		aadd(aFin040, {"E1_NUM"		, cContrato		 	   										, Nil } )
		aadd(aFin040, {"E1_PARCELA"	, cParcela								   					, Nil } )
		aadd(aFin040, {"E1_XPARCON"	, cParcela + "/" + StrZero(Len(aParcelas),nTamParcela)		, Nil } )
		aadd(aFin040, {"E1_TIPO"	, cTipo		 							   					, Nil } )
		aadd(aFin040, {"E1_NATUREZ"	, cNatureza													, Nil } )
		aadd(aFin040, {"E1_CLIENTE"	, cCliente								   					, Nil } )
		aadd(aFin040, {"E1_LOJA"	, cLoja									   					, Nil } )
		aadd(aFin040, {"E1_EMISSAO"	, dDataBase								   					, Nil } )
		aadd(aFin040, {"E1_VENCTO"	, dVencimento												, Nil } )
		aadd(aFin040, {"E1_VENCREA"	, DataValida(dVencimento)									, Nil } )
		aadd(aFin040, {"E1_VALOR"	, nValorTit								   					, Nil } )
		AAdd(aFin040, {"E1_PORCJUR"	, nPercJuros									   			, Nil } )
		AAdd(aFin040, {"E1_XCTRFUN"	, cContrato								   					, Nil } )
		AAdd(aFin040, {"E1_XFORPG"	, cFormaPgto							   					, Nil } )

		//Valido se recebimento foi feito pelo Mobile para nao enviar parcelas adiantadas para Vindi
		If SE1->(FieldPos("E1_XPGTMOB")) > 0  .And. (nQtdAdt > 0 .OR. nQtdAdesao > 0)
			If nParcAdt < (nQtdAdt + nQtdAdesao)
				AAdd(aFin040, {"E1_XPGTMOB"	, "S"												, Nil } ) //Pagamento mobile S= Sim N=Nao
				nParcAdt++
			endIf
		endIf
		
		//===============================================================================
		// == PONTO DE ENTRADA PARA MANIPULACAO DO FINANCEIRO DA ATIVACAO DO CONTRATO ==
		//==============================================================================
		if ExistBlock("UF040PCO")
		
			aFin040 := AClone(ExecBlock( "UF040PCO", .F. ,.F., { aFin040 } ))

			// valido o conteudo retornado pelo
			if len(aFin040) == 0 .Or. ValType( aFin040 ) <> "A"
				lRet	:= .F.
				Help(,,'Help - UF040PCO',,"Estrutura do Array de títulos da Ativacao inválida!" ,1,0)
				cMsgErro += "Estrutura do Array de títulos da Ativacao inválida."
				Exit					
			endIf

		endIf

		if lRet

			MSExecAuto({|x,y| FINA040(x,y)},aFin040,3)

			If lMsErroAuto

				If !IsBlind()
					MostraErro()
				Else
					cMsgErro += "FINA040: " + U_toString(aFin040)
					cMsgErro += MostraErro("/temp")
				endIf

				lRet := .F.
				Exit
			else

				//Gravo composicao do valor da parcela se parametro
				//por parcela idade estiver habilitado
				if lConsAniver

					U_RFUN40OK(cContrato,aRegras)
				endIf

			endIf
		
		endif

	Next nX

	RestArea(aAreaSE1)
	RestArea(aAreaUF0)
	RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GeraParcelas ºAutor³Raphael Martins 	   º Data³ 15/07/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para definicao da quantidade de titulos para ativacao±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funerária	                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeraParcelas(cContrato,cPlano)

	Local oArial8 			:= TFont():New("Arial",,016,,.F.,,,,,.F.,.F.)
	Local oArial8N			:= TFont():New("Arial",,016,,.T.,,,,,.F.,.F.)
	Local oDlg				:= NIL
	Local oContrato			:= NIL
	Local oFirstParc		:= NIL
	Local oQtdParc			:= NIL
	Local oLastVencto		:= NIL
	Local dFirstParc		:= CTOD("")
	Local dLastVencto		:= CTOD("")
	Local dDataAux			:= CTOD("")
	Local nQtdParc			:= 0
	Local lRet				:= .F.

	//valido se possui taxa de adesao
	if UF2->UF2_ADESAO > 0

		dFirstParc := dDataBase

		//valido a data de vencimento da primeira parcela
	elseif !Empty(UF2->UF2_PRIMVE)

		dFirstParc := UF2->UF2_PRIMVE

	else

		// se o dia de vencimento do contrato for maior que o dia da data base
		// o vencimento será para o próximo mês
		if Day(dDataBase) > Val(UF2->UF2_DIAVEN)

			dDataAux	:= CTOD("01/" + StrZero(Month(dDataBase),2) + "/" + StrZero(Year(dDataBase),4))
			dDataAux	:= MonthSum(dDataAux,1) // somo um mes a data auxiliar

			// se o dia de vencimento for maior que o último dia do proximo mês
			// considera o último dia do proximo mês
			if Val(UF2->UF2_DIAVEN) > Day(LastDate(dDataAux))
				dFirstParc := CTOD(StrZero(Day(LastDate(dDataAux)),2) + "/" + StrZero(Month(dDataAux),2) + "/" + StrZero(Year(dDataAux),4))
			else
				dFirstParc := CTOD(UF2->UF2_DIAVEN + "/" + StrZero(Month(dDataAux),2) + "/" + StrZero(Year(dDataAux),4))
			endIf

		else

			dFirstParc	:= CTOD(UF2->UF2_DIAVEN + "/" + StrZero(Month(dDataBase),2) + "/" + StrZero(Year(dDataBase),4))

		endIf

	endIf

	DEFINE MSDIALOG oDlg TITLE "Ativacao de Contratos" FROM 000, 000  TO 160, 530 COLORS 0, 16777215 PIXEL Style DS_MODALFRAME

	oDlg:lEscClose := .F.

	@ 003, 003 GROUP oGroup1 TO 054, 265 PROMPT "Dados da Ativação" OF oDlg COLOR 0, 16777215 PIXEL
	oGroup1:oFont := oArial8N

	@ 015, 008 SAY oSay1 PROMPT "Contrato:" SIZE 045, 007 OF oDlg FONT oArial8N COLORS 0, 16777215 PIXEL
	@ 014, 054 MSGET oContrato VAR cContrato SIZE 060, 011 OF oDlg COLORS 0, 16777215 When .F. PICTURE "@!" FONT oArial8 PIXEL

	@ 015, 130 SAY oSay2 PROMPT "Vencto 1ª Parcela:" SIZE 054, 007 OF oDlg FONT oArial8N COLORS 0, 16777215 PIXEL
	@ 014, 184 MSGET oFirstParc VAR dFirstParc SIZE 060, 010 OF oDlg COLORS 0, 16777215 When .F. FONT oArial8 PIXEL

	@ 036, 007 SAY oSay3 PROMPT "Qtd Parcelas:" SIZE 041, 007 OF oDlg FONT oArial8N COLORS 0, 16777215 PIXEL
	@ 035, 053 MSGET oQtdParc VAR nQtdParc SIZE 060, 010 OF oDlg COLORS 0, 16777215 PICTURE "9999" Valid( CalcLstVenc(nQtdParc,@dLastVencto,dFirstParc,cPlano) ) FONT oArial8 PIXEL

	@ 036, 130 SAY oSay4 PROMPT "Último Vencto:" SIZE 046, 007 OF oDlg FONT oArial8N COLORS 0, 16777215 PIXEL
	@ 035, 184 MSGET oLastVencto VAR dLastVencto SIZE 060, 010 OF oDlg COLORS 0, 16777215 When .F. FONT oArial8 PIXEL

	@ 055, 003 GROUP oGroup2 TO 077, 265 OF oDlg COLOR 0, 16777215 PIXEL

	@ 061, 176 BUTTON oConfirmar PROMPT "Confirmar" SIZE 037, 012 OF oDlg Action( lRet := ConfAtivacao(nQtdParc,oDlg) ) FONT oArial8N PIXEL

	@ 061, 222 BUTTON oCancelar PROMPT "Cancelar" SIZE 037, 012 OF oDlg Action( oDlg:End() ) FONT oArial8N PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return(lRet)

/*/{Protheus.doc} CalcLstVenc
Funcao para calcular o utlimo vencimento de acordo com a 
quantidade de parcelas
@type function
@version 
@author Raphael Martins 
@since 15/07/2016
@param nQtdParc, numeric, param_description
@param dL, param_type, param_description
@param dFirstParc, date, param_description
@param cPlano, character, param_description
@return return_type, return_description
/*/
Static Function CalcLstVenc(nQtdParc,dLastVencto,dFirstParc,cPlano)

	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local aAreaUF0	:= UF0->(GetArea())

	//verifico se o valor digitado e valido
	if nQtdParc >= 0

		//valido se a quantidade digitada e superior a quantidade de parcelas do plano
		if UF0->(DbSeek( xFilial("UF0") + cPlano))

			if UF0->UF0_QTDPAR < nQtdParc

				lRet := .F.
				MsgInfo("Quantidade de Parcelas digitada supera a parcelas definidas no Plano!","Atenção")

			else

				//provisiono a ultima parcela de acordo com a quantidade digitada
				dLastVencto := MonthSum(dFirstParc,nQtdParc)

			endIf

		else

			lRet := .F.
			MsgInfo("Plano do Contrato não encontrado!","Atenção")

		endIf

	else

		lRet := .F.
		MsgInfo("Valor digitado deve ser superior a zero!","Atenção")

	endIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ConfAtivacao ºAutor³Raphael Martins 	   º Data³ 15/07/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Confirmacao de Ativacao pela tela de geracao de parcelas   ¹±±
±±º			   															  ¹±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funerária	                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ConfAtivacao(nQtdParc,oDlg)

	Local lRet := .T.

	if nQtdParc > 0

		FWMsgRun(,{|oSay| lRet := AtivaCTRFun(oSay,nQtdParc)},'Aguarde...','Ativando o contrato...')

		if lRet

			oDlg:End()

		endIf

	else

		MsgInfo("Valor digitado deve ser superior a zero!","Atenção")

	endIf

Return(lRet)

/*###########################################################################
#############################################################################
## Programa  | IncPerfil |Autor| Wellington Gonçalves 	|Data|  25/01/2019 ##
##=========================================================================##
## Desc.     | Abertura de cadastro MVC de Perfil de Pagamento			   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

Static Function IncPerfil()

	Local lRet := .T.

	nInc := FWExecView('INCLUIR','UVIND07',3,,{|| .T. })

	if nInc <> 0
		MsgInfo("A Inclusão do Perfil de Pagamento não foi realizada. Não será possível ativar o contrato!","Atenção!")
		lRet := .F.
	endIf

Return(lRet)
