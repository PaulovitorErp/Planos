#INCLUDE 'totvs.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} PFUNA002
Ponto de entrada do cadastro de contratos da funerária
@type function
@version 1.0
@author Wellington Gonçalves
@since 10/08/2016
/*/
User Function PFUNA002()

	Local aParam 		:= PARAMIXB
	Local aSolucao		:= {}
	Local oObj			:= aParam[1]
	Local cIdPonto		:= aParam[2]
	Local cIdModel		:= IIf( oObj<> NIL, oObj:GetId(), aParam[3] )
	Local cClasse		:= IIf( oObj<> NIL, oObj:ClassName(), '' )
	Local oModelUF2		:= oObj:GetModel( 'UF2MASTER' )
	Local oModelUF4		:= oObj:GetModel( 'UF4DETAIL' )
	Local oModelUF9		:= oObj:GetModel( 'UF9DETAIL' )
	Local oModelUK2		:= Nil
	Local lRet 			:= .T.
	Local lRepTitulos	:= .F.
	Local nValorTit		:= 0
	Local lPrimVencto	:= SuperGetMv("MV_XPRIMVC",.F.,.F.)
	Local lAtivaLog		:= SuperGetMv("MV_XATILOG",.F.,.F.)
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local cFilAdmin		:= SuperGetMv("MV_XFILADM",.F.,"")
	Local cErroVindi	:= ""
	Local lContinua		:= .T.
	Local nI
	Local oVindi		:= Nil
	Local cCliAnt		:= ""
	Local cLojaAnt		:= ""
	Local lVindi		:= .F.
	Local lIntEmp		:= SuperGetMV("MV_XINTEMP", .F., .F.) // habilito o uso da integracao de empresas

	Private	aCposUF2	:= {}
	Private	aCposUF4	:= {}
	Private	aCposUF9	:= {}

	If cIdPonto == "MODELVLDACTIVE" // abertura da tela

		If FunName() == "RFUNA002" .And. (oObj:GetOperation() == 1 .OR. oObj:GetOperation() == 4)
			MostraMsg()
		EndIf

		//valido se a inclusão do contrato está de acordo com a filial de aministradora
		if oObj:GetOperation() == 3

			//caso o parametro MV_XFILADM nao exista ou esteja vazio, sera permitido a inclusao
			if !Empty(cFilAdmin) .And. !(cFilAnt $ cFilAdmin)

				aSolucao := {'A Inclusão do Contrato pode ser realizada apenas nas filiais (' + Alltrim(cFilAdmin) + ') '}

				Help( ,, 'Adm Planos',, 'Não é possivel incluir contrato!', 1, 0 ,;
					Nil, Nil, Nil, Nil, Nil, aSolucao )


				lRet := .F.

			endif

			if lPlanoPet

				oModelUK2 := oObj:GetModel( 'UK2DETAIL' )

				oModelUK2:SetNoInsertLine(.T.)
				oModelUK2:SetNoUpdateLine(.T.)
				oModelUK2:SetNoDeleteLine(.T.)

			endIf

			//Valido se é alteracao e se esta na mesma filial do contrato
		elseif  oObj:GetOperation() == 4 .Or. oObj:GetOperation() == 1

			//Se esta em filial diferente da inclusao nao permite
			if cFilAnt != UF2->UF2_MSFIL

				Help( ,, 'Help - MODELVLDACTIVE',, 'Alteracao ou Visualização do contrato so é permitida na filial onde ele foi incluido.', 1, 0 )

				lRet := .F.

			endif

			if lPlanoPet .And. oObj:GetOperation() == 4

				oModelUK2 := oObj:GetModel( 'UK2DETAIL' )

				if UF2->UF2_USO $ " |2" // caso nao estiver preenchido ou for  de uso humano

					oModelUK2:SetNoInsertLine(.T.)
					oModelUK2:SetNoUpdateLine(.T.)
					oModelUK2:SetNoDeleteLine(.T.)

				elseIf UF2->UF2_USO $ "1|3" // caso for de uso ambos e pet

					oModelUK2:SetNoInsertLine(.F.)
					oModelUK2:SetNoUpdateLine(.F.)
					oModelUK2:SetNoDeleteLine(.F.)

				endIf

			endIf

		endif

		if oObj:GetOperation() == 5 // se for exclusão
			if UF2->UF2_STATUS <> "P"
				Help( ,, 'Help - MODELVLDACTIVE',, 'Somente é permitido a exclusão de Contrato no status de Pré-cadastro.', 1, 0 )
				lRet := .F.
			endif

		endif

	elseif cIdPonto == "MODELPOS" // na validação na confirmação do cadastro

		//operacao de inclusao ou operacao de alteracao
		if oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4

			//funcao para validar se possui mais de um contrato ativo para o mesmo CPF
			lRet := U_ValCliInf(oModelUF2:GetValue('UF2_CODIGO'))

			if lRet

				//valido se os campos de vencimentos estao preenchidos
				if lPrimVencto

					if Empty(oModelUF2:GetValue('UF2_DIAVEN')) .And. Empty(oModelUF2:GetValue('UF2_PRIMVE'))

						lRet := .F.
						Help( ,, 'Help - MODELPOS',, 'Os campos de Vencimento das Parcelas não foram preenchidos, favor verifique os mesmos!', 1, 0 )

					endif

				else

					if Empty(oModelUF2:GetValue('UF2_DIAVEN'))

						lRet := .F.
						Help( ,, 'Help - MODELPOS',, ';O campo de Vencimento da Parcela não foi preenchido, favor verifique o mesmo!', 1, 0 )

					endif

				endif

				U60->(DbSetOrder(2)) //-- U60_FILIAL + U60_FORPG
				If lRet .And. U60->( MsSeek(xFilial("U60") + oModelUF2:GetValue('UF2_FORPG')) )

					if oObj:GetOperation() == 3 //-- Inclusao

						// se o metodo de pagamento estiver ativo
						If U60->U60_STATUS == "A"

							//-- Verifica se existe contrato em recorrência ativo para cliente
							lRet := U_RecNaoExist( oModelUF2:GetValue('UF2_CLIENT'), oModelUF2:GetValue('UF2_LOJA'))

						EndIf
					Else //-- Alteracao

						// se o metodo de pagamento estiver ativo
						If U60->U60_STATUS == "A";
								.And. AllTrim(oModelUF2:GetValue('UF2_FORPG')) <> AllTrim(UF2->UF2_FORPG)

							//-- Verifica se existe contrato em recorrência ativo para cliente
							lRet := U_RecNaoExist( oModelUF2:GetValue('UF2_CLIENT'), oModelUF2:GetValue('UF2_LOJA'))

						EndIf

					EndIf

				EndIf

				if lRet .And. lPlanoPet

					// cria o modelo de dados do UK2
					oModelUK2 := oObj:GetModel('UK2DETAIL')

					// verifico o uso do contrato
					if oModelUF2:GetValue("UF2_USO") == "1" // 1=ambos

						// caso nao tenha beneficiarios ou pets preenchido para uso ambos
						if oModelUF4:Length() == 1 .Or. oModelUK2:Length() == 1

							if Empty(oModelUF4:GetValue("UF4_NOME")) .And. Empty(oModelUK2:GetValue("UK2_NOME"))

								lRet := .F.
								Help( ,, 'Help - MODELPOS',, 'Para o uso do contrato ambos(Humano ou Pet) as grids de beneficiario ou pets devem ter itens preenchidos!', 1, 0 )

							endIf

						endIf

					elseIf oModelUF2:GetValue("UF2_USO") == "2" // 2=humano

						// caso nao tenha beneficiarios ou pets preenchido para uso ambos
						if oModelUF4:Length() == 1

							if Empty(oModelUF4:GetValue("UF4_NOME"))

								lRet := .F.
								Help( ,, 'Help - MODELPOS',, 'Para o uso do contrato Humano, as grids de beneficiario deve ter itens preenchidos!', 1, 0 )

							endIf

						endIf

					elseIf oModelUF2:GetValue("UF2_USO") == "3" // 3=pet

						// caso nao tenha beneficiarios ou pets preenchido para uso ambos
						if oModelUK2:Length() == 1

							if Empty(oModelUK2:GetValue("UK2_NOME"))

								lRet := .F.
								Help( ,, 'Help - MODELPOS',, 'Para o uso do contrato Pet a grid de Pets devem ter itens preenchidos!', 1, 0 )

							endIf

						endIf

					endIf

				endIf

			endif

		Endif

		if oObj:GetOperation() == 4 // se a operação for de alteração

			if lRet .And. !IsInCallStack("U_RFUNE002")

				//inicia o controle de transacao
				Begin Transaction

					if UF2->UF2_STATUS <> "P" // se o contrato já estiver ativado

						if UF2->UF2_VALOR <> oModelUF2:GetValue('UF2_VALOR') .OR. IsInCallStack("U_RFUNA006")

							if MsgYesNo("Foi realizada uma alteração no valor ou titular do contrato. " + chr(13)+chr(10) + "Serão reprocessados os títulos a receber em aberto a partir do próximo vencimento." + chr(13)+chr(10) + "Deseja continuar?")

								//reprocessa titulos em aberto
								lRepTitulos := .T.

							else
								lRet := .F.
								Help( ,, 'Help - MODELPOS',, 'Operação não realizada.', 1, 0 )
							endif

						endif

						//Valido se houve troca de titularidade reprocessa titulos
						If lRet .AND. IsInCallStack("U_RFUNA006")

							//Valido se trocou o titular
							If AllTrim(UF2->UF2_CLIENT) == oModelUF2:GetValue('UF2_CLIENT')  .And. AllTrim(UF2->UF2_LOJA) == oModelUF2:GetValue('UF2_LOJA')

								MsgInfo("O titular selecionado é igual ao atual titular, favor selecionar outro cliente.","Atenção")

								lRet := .F.
								lRepTitulos := .F.
							Endif

							//Valido se trocou o titular
							If Empty(oModelUF2:GetValue("UF2_MTVTRA"))

								MsgInfo("Favor informar o motivo da transferencia de Titularidade!","Atenção")

								lRet := .F.
								lRepTitulos := .F.
							Endif

							cCliAnt		:= UF2->UF2_CLIENT
							cLojaAnt	:= UF2->UF2_LOJA

							If lRet

								// posiciono no metodo de pagamento Vindi
								U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
								If U60->(DbSeek(xFilial("U60") + UF2->UF2_FORPG))

									//Variavel que indica forma de pagamento devera enviar para VINDI
									lVindi := .T.

									// tela para preenchimento do perfil de pagamento
									FWMsgRun(,{|oSay| lRet := IncPerfil()},'Aguarde...','Abrindo Perfil de Pagamento...')

									oVindi := IntegraVindi():New()

									If lRet

										lRepTitulos := .T.

									Else
										lRepTitulos := .F.

										Help(NIL, NIL, "Atenção!", NIL, "Não foi possível realizar a Inclusao do perfil de pagamento na Vindi!", 1, 0, NIL, NIL, NIL, NIL, NIL, {cErroVindi})

									Endif
								Endif

							Endif

						Endif

						//reprocesso titulos em aberto a vencer do contrato
						if lRepTitulos

							//-- Verifica se existe pendencias de processamentos VINDI --//
							lRet := U_PENDVIND(UF2->UF2_CODIGO, "F")

							If lRet

								// Valor da parcela + valor adicional (reajustes) + valor dos agregados
								nValorTit := oModelUF2:GetValue('UF2_VALOR') + oModelUF2:GetValue('UF2_VLADIC')

								// faz ajuste das parcelas do contrato
								FWMsgRun(,{|oSay| lRet := AjustaTitulos(oSay,UF2->UF2_CODIGO,nValorTit)},'Aguarde...','Reprocessando as parcelas do contrato...')

								if !lRet

									Help( ,, 'Help - MODELPOS',, 'Ocorreu um problema na atualização dos títulos do contrato.', 1, 0 )

									//Se ajustou titulos com sucesso valido se é pra arquivar cliente na VINDI
								else

									//Arquivo titular anterior na VINDI na troca de titularidade
									if IsInCallStack("U_RFUNA006") .AND. lVindi

										//Faz a troca do cliente na vindi
										lRet:= TrocaCliVindi(@cErroVindi,UF2->UF2_CODIGO,cCliAnt,cLojaAnt)

									Else

										Help(NIL, NIL, "Atenção!", NIL, "Não foi possível realizar a Inclusao do cliente na Vindi!", 1, 0, NIL, NIL, NIL, NIL, NIL, {cErroVindi})

									Endif

								Endif

							EndIf

						endif

					endif

					if lRet

						//Gravo historico de mudanca de titular
						If IsInCallStack("U_RFUNA006")


							//Valido se contrato possui Convalescente Ativo e faz mudanca de titular dos titulos
							FWMsgRun(,{|oSay| lRet:= AjustaConvalescente( oModelUF2:GetValue("UF2_CODIGO"), oSay , @cErroVindi,oModelUF2:GetValue("UF2_CLIENT"),oModelUF2:GetValue("UF2_LOJA")) },'Aguarde...','Reprocessando as parcelas do Convalescente...')


							If lRet

								//atribuo numero da sorte para o contrato
								if !Empty(oModelUF2:GetValue("UF2_PLNSEG"));
										.And. U_RFUNE31B( oModelUF2:GetValue("UF2_PLNSEG") )

									lRet := AtribuiNumSorte(UF2->UF2_CODIGO)

								endif

								if lRet

									RecLock("UF5",.T.)

									UF5->UF5_FILIAL	:= xFilial("UF5")
									UF5->UF5_CODIGO := GetSX8Num("UF5","UF5_CODIGO")
									UF5->UF5_CTRFUN	:= UF2->UF2_CODIGO
									UF5->UF5_DATA	:= dDataBase
									UF5->UF5_USER	:= cUserName
									UF5->UF5_CLIANT	:= cCliAnt
									UF5->UF5_LOJANT	:= cLojaAnt
									UF5->UF5_CLIATU	:= oModelUF2:GetValue("UF2_CLIENT")
									UF5->UF5_LOJATU	:= oModelUF2:GetValue("UF2_LOJA")
									UF5->UF5_MOTIVO	:= oModelUF2:GetValue("UF2_MTVTRA")
									UF5->(MsUnlock())

									UF5->(ConfirmSX8())

									if lIntEmp

										if UF2->UF2_TPCONT == "2"

											// atualizo os autorizados do contrato
											AtuAutorizadoInt(UF2->UF2_MSFIL, UF2->UF2_CODIGO, cCliAnt, cLojaAnt, oModelUF2:GetValue("UF2_CLIENT"), oModelUF2:GetValue("UF2_LOJA"))

										endIf

									endIf

								endif

							endif
						else

							//verifico se houve troca de plano e se o plano novo possui seguro
							if !Empty(oModelUF2:GetValue("UF2_PLNSEG"));
									.And. Empty(oModelUF2:GetValue("UF2_NUMSOR"));
									.And. U_RFUNE31B( oModelUF2:GetValue("UF2_PLNSEG") )

								lRet := AtribuiNumSorte(UF2->UF2_CODIGO)

							endif


						endif

					endif

					if lRet


						// chamo função que verifica as alterações ocorridas no contrato
						FWMsgRun(,{|oSay| GravaHist(oObj)},'Aguarde...','Gravando Histório de Alterações...')

					else
						DisarmTransaction()
					endif

					//Finalizo o contrao de transacao
				End Transaction
			endif

		endif

	endIf

Return(lRet)

/*/{Protheus.doc} MostraMsg
Funcao para visualizacao das mensagens do contrato
@type function
@version 1.0  
@author Raphael Martins
@since 19/08/2016
@return variant, return_description
/*/
Static Function MostraMsg()

	Local oDlgMsg
	Local oMsg
	Local oSay1
	Local aArea		:= GetArea()
	Local aAreaUF9	:= UF9->(GetArea())
	Local lMostra 	:= .F.
	Local cMsg    	:= ""

	UF9->( DbSetOrder(1) ) //UF9_FILIAL+UF9_CODIGO+UF9_ITEM

	If UF9->( DbSeek( xFilial("UF9") + UF2->UF2_CODIGO ) )

		While UF9->(!EOF()) .And. UF9->UF9_FILIAL == xFilial("UF2") .And. UF9->UF9_CODIGO == UF2->UF2_CODIGO

			If UF9->UF9_MOSTRA == "S" .And. UF9->UF9_DTVIGE >= dDataBase

				cMsg += Alltrim(UF9->UF9_DESCRI)
				cMsg += CRLF
				cMsg += Repl("_",92)
				cMsg += CRLF

			Endif

			UF9->(DbSkip())

		EndDo

		If !Empty(cMsg)
			lMostra := .T.
		Endif

	Endif

	If lMostra

		DEFINE MSDIALOG oDlgMsg TITLE "Mensagens" From 0,0 TO 400,600 PIXEL

		//Memo
		@ 005,005 Get oMsg Var cMsg MEMO Size 292,165 READONLY PIXEL OF oDlgMsg

		//Linha horizontal
		@ 170, 005 SAY oSay1 PROMPT Replicate("_",292) SIZE 292, 007 OF oDlgMsg COLORS CLR_GRAY, 16777215 PIXEL

		//Botao
		@ 181, 250 BUTTON oButton1 PROMPT "Ok" SIZE 040, 010 OF oDlgMsg ACTION oDlgMsg:End() PIXEL

		ACTIVATE MSDIALOG oDlgMsg CENTERED

	Endif

	RestArea(aAreaUF9)
	RestArea(aArea)

Return()

/*/{Protheus.doc} AjustaTitulos
Função que faz a exclusão dos títulos em aberto do contrato
@type function
@version 1.0  
@author Wellington Gonçalves
@since 30/09/2016
@param oSay, object, param_description
@param cContrato, character, param_description
@param nValorTit, numeric, param_description
@return variant, return_description
/*/
Static Function AjustaTitulos(oSay,cContrato,nValorTit)

	Local aArea 		:= GetArea()
	Local lRet			:= .T.
	Local aFin040		:= {}
	Local aTitulos		:= {}
	Local aRegras		:= {}
	Local cPulaLinha	:= chr(13)+chr(10)
	Local cQry			:= ""
	Local nX			:= 0
	Local cPrefixo 		:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
	Local cTipoAT		:= SuperGetMv("MV_XTIPFUN",.F.,"AT")
	Local cNatureza		:= UF2->UF2_NATURE
	Local cParcAdes		:= Alltrim(SuperGetMv("MV_XPPADES",.F.,'001'))
	Local lConsAniver	:= SuperGetMv("MV_XPARNIV",,.T.)
	Local lConsMesAtual	:= SuperGetMv("MV_XCONMAT",,.T.)
	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUF2 	:= oModel:GetModel("UF2MASTER")
	Local lContinua		:= .T.
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	DbSelectArea("SE1")

	cQry := " SELECT "                           								+ cPulaLinha
	cQry += " SE1.E1_FILIAL, "                   								+ cPulaLinha
	cQry += " SE1.E1_PREFIXO, "                  								+ cPulaLinha
	cQry += " SE1.E1_NUM, "                      								+ cPulaLinha
	cQry += " SE1.E1_PARCELA, "                  								+ cPulaLinha
	cQry += " SE1.E1_TIPO "                      								+ cPulaLinha
	cQry += " FROM"                              								+ cPulaLinha
	cQry += " " + RetSqlName("SE1") + " SE1 "									+ cPulaLinha
	cQry += " WHERE"                             								+ cPulaLinha
	cQry += " SE1.D_E_L_E_T_ <> '*' "            								+ cPulaLinha
	cQry += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' " 					+ cPulaLinha
	cQry += " AND SE1.E1_XCTRFUN = '" + cContrato + "' "						+ cPulaLinha

	if SE1->(FieldPos("E1_XCONCTR")) > 0

		cQry += " AND SE1.E1_XCONCTR= ''"

	endif

	cQry += " AND SE1.E1_VALOR = SE1.E1_SALDO " 								+ cPulaLinha

	//valido se considera o mes atual atual ou somente o mes subsequente para alterar as parcelas
	if lConsMesAtual
		cQry += " AND SE1.E1_VENCTO >= '" + DTOS(dDataBase) + "' "	+ cPulaLinha
	else
		cQry += " AND SUBSTRING(SE1.E1_VENCTO,1,6) > '" + AnoMes(dDataBase) + "' "	+ cPulaLinha
	endif
	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)

	// crio o alias temporario
	TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query

	// se existir contratos a serem reajustados
	if QRY->(!Eof())

		//valido se o contrato possui titulos em cobranca
		if U_VldCobranca(xFilial("SE1"),cContrato)

			While QRY->(!Eof())

				SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
				if SE1->(DbSeek(QRY->E1_FILIAL + QRY->E1_PREFIXO + QRY->E1_NUM + QRY->E1_PARCELA + QRY->E1_TIPO))

					//Valido se é a primeira parcela e se plano tem adesao
					if  SE1->E1_PARCELA == cParcAdes .And. SE1->E1_TIPO == Alltrim(cTipoAT)

						//Valido se plano tem adesao para nao deletar
						if UF2->UF2_ADESAO > 0

							lContinua := .F.
						endif

					else
						lContinua := .T.
					endif

					aFin040		:= {}
					lMsErroAuto := .F.
					lMsHelpAuto := .T.

					if lContinua

						oSay:cCaption := ("Excluindo parcela " + AllTrim(SE1->E1_PARCELA) + "...")
						ProcessMessages()

						If SE1->E1_VALOR == SE1->E1_SALDO // somente título que não teve baixa

							// faço a exclusão do título do bordero
							SEA->(DbSetOrder(1)) // EA_FILIAL + EA_NUMBOR + EA_PREFIXO + EA_NUM + EA_PARCELA + EA_TIPO + EA_FORNECE + EA_LOJA
							If SEA->(DbSeek(xFilial("SEA") + SE1->E1_NUMBOR + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO))

								if RecLock("SEA",.F.)
									SEA->(DbDelete())
									SEA->(MsUnlock())
								else
									SE1->(DisarmTransaction())
									BREAK
								endif

							Endif

							if RecLock("SE1",.F.)
								SE1->E1_SITUACA	:= "0"
								SE1->E1_OCORREN	:= ""
								SE1->E1_NUMBCO	:= ""
								SE1->E1_NUMBOR	:= ""
								SE1->E1_PORTADO := ""
								SE1->E1_CONTA   := ""
								SE1->E1_AGEDEP  := ""
								SE1->E1_DATABOR	:= Stod("")
								SE1->(MsUnLock())
							else
								SE1->(DisarmTransaction())
								BREAK
							endIf

							// faço a exclusão do título a receber
							AAdd(aFin040, {"E1_FILIAL"  , SE1->E1_FILIAL  	, Nil})
							AAdd(aFin040, {"E1_PREFIXO" , SE1->E1_PREFIXO 	, Nil})
							AAdd(aFin040, {"E1_NUM"     , SE1->E1_NUM	   	, Nil})
							AAdd(aFin040, {"E1_PARCELA" , SE1->E1_PARCELA	, Nil})
							AAdd(aFin040, {"E1_TIPO"    , SE1->E1_TIPO  	, Nil})

							// preencho o array de títulos para incluí-los novamente com o valor reajustado
							aadd(aTitulos,{ SE1->E1_FILIAL ,;
								SE1->E1_PARCELA,;
								SE1->E1_XPARCON,;
								iif(IsInCallStack("U_RFUNA006"),oModelUF2:GetValue("UF2_CLIENT"),SE1->E1_CLIENTE),;
								iif(IsInCallStack("U_RFUNA006"),oModelUF2:GetValue("UF2_LOJA"),SE1->E1_LOJA),;
								SE1->E1_VENCTO,;
								SE1->E1_VEND1,;
								SE1->E1_TIPO } )

							MSExecAuto({|x,y| Fina040(x,y)},aFin040,5)

							If lMsErroAuto
								MostraErro()
								lRet := .F.
								Exit
							EndIf

						endif

					endif

				endif

				QRY->(DbSkip())

			EndDo
		else

			lRet := .F.
			MsgInfo("O Contrato possui titulos em cobrança, operação cancelada.","Atenção")
			DisarmTransaction()

		endif

		// se a exclusão dos títulos foi realizada com sucessso
		if lRet

			//Valido se deverá ser limpado as regras gravadas para regravar
			//Quando parcelas sao excluidas e incluidas novamente
			UJR->(DbSetOrder(3))
			If UJR->(DbSeek(xFilial("UJR")+cContrato))
				While UJR->(!EOF()) ;
						.AND. UJR->UJR_FILIAL+UJR->UJR_CODIGO == xFilial("UJR")+cContrato

					//Deleto regras gravadas
					If RecLock("UJR",.F.)
						UJR->(DbDelete())
						UJR->(MsUnLock())
					Endif
					UJR->(DbSkip())
				EndDo
			Endif

			For nX := 1 To Len(aTitulos)

				lMsErroAuto := .F.
				lMsHelpAuto := .T.
				aFin040 	:= {}

				oSay:cCaption := ("Incluindo parcela " + AllTrim(aTitulos[nX,2]) + "...")
				ProcessMessages()

				//Valido se parametro que considera aniversarios no calculo da parcela, nao considera adesao
				if lConsAniver .AND. Val(aTitulos[nX,2]) > 1
					aRegras 	:= {}
					nValorTit 	:= U_RFUNE040(aTitulos[nX,6],cContrato,@aRegras,oModel)

				Endif


				aadd(aFin040, {"E1_FILIAL"	, aTitulos[nX,1]				, Nil } )
				aadd(aFin040, {"E1_PREFIXO"	, cPrefixo         				, Nil } )
				aadd(aFin040, {"E1_NUM"		, cContrato		 	   			, Nil } )
				aadd(aFin040, {"E1_PARCELA"	, aTitulos[nX,2]				, Nil } )
				aadd(aFin040, {"E1_XPARCON"	, aTitulos[nX,3]				, Nil } )
				aadd(aFin040, {"E1_TIPO"	, /*cTipo*/aTitulos[nX,8]		, Nil } )
				aadd(aFin040, {"E1_NATUREZ"	, cNatureza						, Nil } )
				aadd(aFin040, {"E1_CLIENTE"	, aTitulos[nX,4]				, Nil } )
				aadd(aFin040, {"E1_LOJA"	, aTitulos[nX,5]				, Nil } )
				aadd(aFin040, {"E1_EMISSAO"	, dDataBase						, Nil } )
				aadd(aFin040, {"E1_VENCTO"	, aTitulos[nX,6]				, Nil } )
				aadd(aFin040, {"E1_VENCREA"	, DataValida(aTitulos[nX,6])	, Nil } )
				aadd(aFin040, {"E1_VALOR"	, nValorTit						, Nil } )
				aadd(aFin040, {"E1_XCTRFUN"	, cContrato						, Nil } )
				aadd(aFin040, {"E1_XFORPG"	, UF2->UF2_FORPG				, Nil } )

				//===============================================================================
				// == PONTO DE ENTRADA PARA MANIPULACAO DO FINANCEIRO DA ATIVACAO DO CONTRATO ==
				//==============================================================================
				if ExistBlock("UF040PCO")
				
					aFin040 := AClone(ExecBlock( "UF040PCO", .F. ,.F., { aFin040 } ))

					// valido o conteudo retornado pelo
					if len(aFin040) == 0 .Or. ValType( aFin040 ) <> "A"
						lRet	:= .F.
						MsgAlert("Estrutura do Array de títulos da Ativacao inválida.", "UF040PCO")		
						Exit					
					endIf

				endIf

				MSExecAuto({|x,y| FINA040(x,y)},aFin040,3)

				If lMsErroAuto
					MostraErro()
					lRet := .F.
					Exit

				else

					//Gravo composicao do valor da parcela se parametro
					//por parcela idade estiver habilitado
					if lConsAniver.AND. Len(aRegras)>0

						U_RFUN40OK(cContrato,aRegras,Nil,.T.)
					Endif

				EndIf

			Next nX
		endif

	endif

	// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} GravaHist
Função que faz a gravação do histórico de alterações	
@type function
@version 1.0 
@author Wellington Gonçalves
@since 11/06/2019
@param oModel, object, param_description
@return variant, return_description
/*/
Static Function GravaHist(oModel)

	Local aArea 		:= GetArea()
	Local nX	  		:= 0
	Local nY   			:= 0
	Local cCodigo		:= ""
	Local cUsuario		:= RetCodUsr()
	Local aUF4			:= {}
	Local aUJ9			:= {}
	Local aUF3			:= {}
	Local aUF9			:= {}
	Local aCampos		:= {}

	// função que verifica as alterações realizadas no contrato
	lAlterado := BuscaAlter(@aUF4,@aUJ9,@aUF3,@aUF9,@aCampos,oModel)

	// se houve alteração
	if lAlterado

		cCodigo := GetSXENum("U68","U68_CODIGO")

		///////////////////////////////////////////////////////////////////////
		/////////////////////   CABEÇALHO DA ALTERAÇÃO   //////////////////////
		///////////////////////////////////////////////////////////////////////

		if RecLock("U68",.T.)

			U68->U68_FILIAL 	:= xFilial("U68")
			U68->U68_CODIGO 	:= cCodigo
			U68->U68_DATA  		:= dDataBase
			U68->U68_HORA  		:= SubStr(Time(),1,5)
			U68->U68_TIPO		:= "C" // C=Contrato;R=Reajuste;E=Exclusao do Reajuste
			U68->U68_CONTRA		:= M->UF2_CODIGO
			U68->U68_CLIENT		:= M->UF2_CLIENT
			U68->U68_LOJA		:= M->UF2_LOJA
			U68->U68_CODUSR		:= cUsuario

			// confirmo a numeração
			U68->(ConfirmSx8())

		endif

		///////////////////////////////////////////////////////////////////////
		/////////////////////   BENEFICIARIOS ALTERADOS   /////////////////////
		///////////////////////////////////////////////////////////////////////

		For nX := 1 To Len(aUF4)

			if RecLock("U69",.T.)

				U69->U69_FILIAL := xFilial("U69")
				U69->U69_CODIGO	:= cCodigo

				For nY := 1 To Len(aUF4[nX])
					U69->&(aUF4[nX,nY,1]) := aUF4[nX,nY,2]
				Next nY

				U69->(MsUnLock())

			endif

		Next nX

		///////////////////////////////////////////////////////////////////////
		//////////////////   COBRANCAS ADICIONAIS ALTERADAS   /////////////////
		///////////////////////////////////////////////////////////////////////

		For nX := 1 To Len(aUJ9)

			if RecLock("U70",.T.)

				U70->U70_FILIAL := xFilial("U70")
				U70->U70_CODIGO	:= cCodigo

				For nY := 1 To Len(aUJ9[nX])
					U70->&(aUJ9[nX,nY,1]) := aUJ9[nX,nY,2]
				Next nY

				U70->(MsUnLock())

			endif

		Next nX

		///////////////////////////////////////////////////////////////////////
		///////////////////////   PRODUTOS E SERVIÇOS   ///////////////////////
		///////////////////////////////////////////////////////////////////////

		For nX := 1 To Len(aUF3)

			if RecLock("U71",.T.)

				U71->U71_FILIAL := xFilial("U71")
				U71->U71_CODIGO	:= cCodigo

				For nY := 1 To Len(aUF3[nX])
					U71->&(aUF3[nX,nY,1]) := aUF3[nX,nY,2]
				Next nY

				U71->(MsUnLock())

			endif

		Next nX

		///////////////////////////////////////////////////////////////////////
		////////////////////////////   MENSAGENS   ////////////////////////////
		///////////////////////////////////////////////////////////////////////

		For nX := 1 To Len(aUF9)

			if RecLock("U72",.T.)

				U72->U72_FILIAL := xFilial("U72")
				U72->U72_CODIGO	:= cCodigo

				For nY := 1 To Len(aUF9[nX])
					U72->&(aUF9[nX,nY,1]) := aUF9[nX,nY,2]
				Next nY

				U72->(MsUnLock())

			endif

		Next nX

		///////////////////////////////////////////////////////////////////////
		/////////////////////////   CAMPOS ALTERADOS   ////////////////////////
		///////////////////////////////////////////////////////////////////////

		// faço a gravação dos campos alterados
		For nX := 1 To Len(aCampos)

			if RecLock("U73",.T.)

				U73->U73_FILIAL := xFilial("U73")
				U73->U73_CODIGO	:= cCodigo

				For nY := 1 To Len(aCampos[nX])
					U73->&(aCampos[nX,nY,1]) := aCampos[nX,nY,2]
				Next nY

				U73->(MsUnLock())

			endif

		Next nX

	endif

	RestArea(aArea)

Return()

/*/{Protheus.doc} BuscaAlter
Função que verifica as entidades alteradas
@type function
@version 1.0 
@author Wellington Gonçalves
@since 11/06/2019
@param aUF4, array, param_description
@param aUJ9, array, param_description
@param aUF3, array, param_description
@param aUF9, array, param_description
@param aCpoAlt, array, param_description
@param oModel, object, param_description
@return variant, return_description
/*/
Static Function BuscaAlter(aUF4,aUJ9,aUF3,aUF9,aCpoAlt,oModel)

	Local aArea			:= GetArea()
	Local aAreaUF4		:= UF4->(GetArea())
	Local aAreaUJ9		:= UJ9->(GetArea())
	Local aAreaUF3		:= UF3->(GetArea())
	Local aAreaUF9		:= UF9->(GetArea())
	Local nOperation 	:= oModel:GetOperation()
	Local oModelUF2  	:= oModel:GetModel("UF2MASTER")
	Local oModelUF4  	:= oModel:GetModel("UF4DETAIL")
	Local oModelUJ9  	:= oModel:GetModel("UJ9DETAIL")
	Local oModelUF3  	:= oModel:GetModel("UF3DETAIL")
	Local oModelUF9  	:= oModel:GetModel("UF9DETAIL")
	Local aItens		:= {}
	Local cOperacao		:= ""
	Local lAlter		:= .F.
	Local nX			:= 1

	if nOperation == 4 // se a operação for de alteração

		////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////   CABEÇALHO DO CONTRATO   ////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////

		// gravo os campos alterados do cabeçalho do contrato
		RetAltCpo("UF2",M->UF2_CODIGO,oModelUF2,@aCpoAlt)

		////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////   BENEFICIÁRIOS   ////////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////

		// percorro todos os beneficiários
		For nX := 1 To oModelUF4:Length()

			aItens	 	:= {}
			cOperacao	:= ""

			// posiciono na linha
			oModelUF4:GoLine(nX)

			// se o beneficiario estiver preenchido
			if !Empty(oModelUF4:GetValue( "UF4_NOME" ))

				// se o beneficiario estiver deletado
				if oModelUF4:IsDeleted()
					cOperacao := "E"
				else

					// verifico se o beneficiário já existe na base e se o mesmo não está deletado
					UF4->(DbSetOrder(1)) // UF4_FILIAL + UF4_CODIGO + UF4_ITEM
					if UF4->(DbSeek(xFilial("UF4") + M->UF2_CODIGO + oModelUF4:GetValue( "UF4_ITEM" )))

						// verifico se ocorreu alteração de algum campo
						if RetAltCpo("UF4",M->UF2_CODIGO + oModelUF4:GetValue( "UF4_ITEM" ),oModelUF4,@aCpoAlt)
							cOperacao := "A"
						endif

					else
						cOperacao := "I"
					endif

				endif

			endif

			// se houve alteração
			if !Empty(cOperacao)

				aItens := {}

				aadd(aItens,{"U69_CONTRA"	, M->UF2_CODIGO						})
				aadd(aItens,{"U69_ITEM"		, oModelUF4:GetValue( "UF4_ITEM" )	})
				aadd(aItens,{"U69_NOME"		, oModelUF4:GetValue( "UF4_NOME" )	})
				aadd(aItens,{"U69_TPALT"	, cOperacao							})
				aadd(aUF4,aItens)

			endif

		Next nX

		////////////////////////////////////////////////////////////////////////////////////////////////////
		/////////////////////////////////////   COBRANÇAS ADICIONAIS   /////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////

		// percorro todas as cobranças adicionais
		For nX := 1 To oModelUJ9:Length()

			aItens 		:= {}
			cOperacao	:= ""

			oModelUJ9:GoLine(nX)

			// se a cobrança adicional estiver preenchida
			if !Empty(oModelUJ9:GetValue( "UJ9_REGRA" ))

				// se estiver deletado
				if oModelUJ9:IsDeleted()
					cOperacao := "E"
				else

					UJ9->(DbSetOrder(1)) // UJ9_FILIAL + UJ9_CODIGO + UJ9_ITEM
					if UJ9->(DbSeek(xFilial("UJ9") + M->UF2_CODIGO + oModelUJ9:GetValue( "UJ9_ITEM" )))

						// verifico se ocorreu alteração de algum campo
						if RetAltCpo("UJ9",M->UF2_CODIGO + oModelUJ9:GetValue( "UJ9_ITEM" ),oModelUJ9,@aCpoAlt)
							cOperacao := "A"
						endif

					else
						cOperacao := "I"
					endif

				endif

			endif

			// se houve alteração
			if !Empty(cOperacao)

				aItens := {}

				aadd(aItens,{"U70_CONTRA"	, M->UF2_CODIGO							})
				aadd(aItens,{"U70_ITBEN"	, oModelUJ9:GetValue( "UJ9_ITUF4" )		})
				aadd(aItens,{"U70_NOME"		, oModelUJ9:GetValue( "UJ9_NOME" )		})
				aadd(aItens,{"U70_ITEM"		, oModelUJ9:GetValue( "UJ9_ITEM" )		})
				aadd(aItens,{"U70_TIPO"		, oModelUJ9:GetValue( "UJ9_TPREGR" )	})
				aadd(aItens,{"U70_VLUNIT"	, oModelUJ9:GetValue( "UJ9_VLUNIT" )	})
				aadd(aItens,{"U70_QTD"		, oModelUJ9:GetValue( "UJ9_QTD" )		})
				aadd(aItens,{"U70_VLTOT"	, oModelUJ9:GetValue( "UJ9_VLTOT" )		})
				aadd(aItens,{"U70_TPALT"	, cOperacao								})
				aadd(aUJ9,aItens)

			endif

		Next nX

		////////////////////////////////////////////////////////////////////////////////////////////////////
		//////////////////////////////////////   PRODUTOS E SERVIÇOS   /////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////

		// percorro todos os produtos
		For nX := 1 To oModelUF3:Length()

			aItens 		:= {}
			cOperacao	:= ""

			oModelUF3:GoLine(nX)

			// se a cobrança adicional estiver preenchida
			if !Empty(oModelUF3:GetValue( "UF3_PROD" ))

				// se estiver deletado
				if oModelUF3:IsDeleted()
					cOperacao := "E"
				else

					UF3->(DbSetOrder(1)) // UF3_FILIAL + UF3_CODIGO + UF3_ITEM
					if UF3->(DbSeek(xFilial("UF3") + UF2->UF2_CODIGO + oModelUF3:GetValue( "UF3_ITEM" )))

						// verifico se ocorreu alteração de algum campo
						if RetAltCpo("UF3",M->UF2_CODIGO + oModelUF3:GetValue( "UF3_ITEM" ),oModelUF3,@aCpoAlt)
							cOperacao := "A"
						endif

					else
						cOperacao := "I"
					endif

				endif

			endif

			// se houve alteração
			if !Empty(cOperacao)

				aItens := {}

				aadd(aItens,{"U71_CONTRA"	, M->UF2_CODIGO							})
				aadd(aItens,{"U71_ITEM"		, oModelUF3:GetValue( "UF3_ITEM" )		})
				aadd(aItens,{"U71_TIPO"		, oModelUF3:GetValue( "UF3_TIPO" )		})
				aadd(aItens,{"U71_PROD"		, oModelUF3:GetValue( "UF3_PROD" )		})
				aadd(aItens,{"U71_VLUNIT"	, oModelUF3:GetValue( "UF3_VLRUNI" )	})
				aadd(aItens,{"U71_QTD"		, oModelUF3:GetValue( "UF3_QUANT" )		})
				aadd(aItens,{"U71_VLTOT"	, oModelUF3:GetValue( "UF3_VLRTOT" )	})
				aadd(aItens,{"U71_TPALT"	, cOperacao								})
				aadd(aUF3,aItens)

			endif

		Next nX

		////////////////////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////   MENSAGENS   //////////////////////////////////////////
		////////////////////////////////////////////////////////////////////////////////////////////////////

		// percorro todos os produtos
		For nX := 1 To oModelUF9:Length()

			aItens 		:= {}
			cOperacao	:= ""

			oModelUF9:GoLine(nX)

			// se a cobrança adicional estiver preenchida
			if !Empty(oModelUF9:GetValue( "UF9_HISTOR" ))

				// se estiver deletado
				if oModelUF9:IsDeleted()
					cOperacao := "E"
				else

					UF9->(DbSetOrder(1)) // UF9_FILIAL + UF9_CODIGO + UF9_ITEM
					if UF9->(DbSeek(xFilial("UF9") + UF2->UF2_CODIGO + oModelUF9:GetValue( "UF9_ITEM" )))

						// verifico se ocorreu alteração de algum campo
						if RetAltCpo("UF9",M->UF2_CODIGO + oModelUF9:GetValue( "UF9_ITEM" ),oModelUF9,@aCpoAlt)
							cOperacao := "A"
						endif

					else
						cOperacao := "I"
					endif

				endif

			endif

			// se houve alteração
			if !Empty(cOperacao)

				aItens := {}

				aadd(aItens,{"U72_CONTRA"	, M->UF2_CODIGO							})
				aadd(aItens,{"U72_ITEM"		, oModelUF9:GetValue( "UF9_ITEM" )		})
				aadd(aItens,{"U72_HIST"		, oModelUF9:GetValue( "UF9_HISTOR" )	})
				aadd(aItens,{"U72_TPALT"	, cOperacao								})
				aadd(aUF9,aItens)

			endif

		Next nX

		if Len(aUF4) > 0 .OR. Len(aUJ9) > 0 .OR. Len(aUF3) > 0 .OR. Len(aUF9) > 0 .OR. Len(aCpoAlt) > 0
			lAlter := .T.
		endif

	endif

	RestArea(aAreaUF4)
	RestArea(aAreaUJ9)
	RestArea(aAreaUF3)
	RestArea(aAreaUF9)
	RestArea(aArea)

Return(lAlter)

/*/{Protheus.doc} RetAltCpo
Função que verifica se algum campo foi alterado
@type function
@version 1.0 
@author Wellington Gonçalves
@since 11/06/2019
@param cAliasUtil, character, param_description
@param cChave, character, param_description
@param oModelAlias, object, param_description
@param aDetAlt, array, param_description
@return variant, return_description
/*/
Static Function RetAltCpo(cAliasUtil,cChave,oModelAlias,aDetAlt)

	Local aArea			:= GetArea()
	Local aAreaAlias	:= (cAliasUtil)->(GetArea())
	Local cCampoAlias	:= ""
	Local lAlterCPO		:= .F.
	Local aItens		:= {}
	Local lAlterAlias	:= .F.
	Local oSX3			:= UGetSxFile():New
	Local aSX3			:= {}
	Local nX			:= 1

	aSX3 := oSX3:GetInfoSX3(cAliasUtil)

	If Len(aSX3) > 0

		For nX := 1 to Len(aSX3)

			lAlterCPO 	:= .F.
			aItens 		:= {}

			if X3Uso(aSX3[nX,2]:cUSADO) .AND. cNivel >= aSX3[nX,2]:nNIVEL .AND. aSX3[nX,2]:cCONTEXT <> "V"

				cCampoAlias := AllTrim(aSX3[nX,2]:cCAMPO)

				if aSX3[nX,2]:cTIPO == "C" .OR. aSX3[nX,2]:cTIPO == "M" // se o campo for tipo texto ou memo, devo comparar o tamanho dos caracteres, pois o advpl considera que TEXTO = TEXTO 2

					if (cAliasUtil)->&cCampoAlias <> oModelAlias:GetValue( cCampoAlias ) .OR. Len((cAliasUtil)->&cCampoAlias) <> Len(oModelAlias:GetValue( cCampoAlias ))
						lAlterCPO 	:= .T.
					endif

				else

					if (cAliasUtil)->&cCampoAlias <> oModelAlias:GetValue( cCampoAlias )
						lAlterCPO 	:= .T.
					endif

				endif

				if lAlterCPO

					lAlterAlias := .T.

					aItens := {}

					// crio array com os dados do campo alterado
					aadd(aItens,{"U73_ALIAS"	, cAliasUtil})
					aadd(aItens,{"U73_CHAVE"	, cChave})
					aadd(aItens,{"U73_TIPCPO"	, aSX3[nX,2]:cTIPO})
					aadd(aItens,{"U73_CAMPO"	, cCampoAlias })

					if aSX3[nX,2]:cTIPO == "C"

						aadd(aItens,{"U73_CVLANT"	, (cAliasUtil)->&cCampoAlias})
						aadd(aItens,{"U73_CVLPOS"	, oModelAlias:GetValue( cCampoAlias )})

					elseif aSX3[nX,2]:cTIPO == "N"

						aadd(aItens,{"U73_NVLANT"	, (cAliasUtil)->&cCampoAlias})
						aadd(aItens,{"U73_NVLPOS"	, oModelAlias:GetValue( cCampoAlias )})

					elseif aSX3[nX,2]:cTIPO == "D"

						aadd(aItens,{"U73_DVLANT"	, (cAliasUtil)->&cCampoAlias})
						aadd(aItens,{"U73_DVLPOS"	, oModelAlias:GetValue( cCampoAlias )})

					elseif aSX3[nX,2]:cTIPO == "L"

						aadd(aItens,{"U73_LVLANT"	, (cAliasUtil)->&cCampoAlias})
						aadd(aItens,{"U73_LVLPOS"	, oModelAlias:GetValue( cCampoAlias )})

					elseif aSX3[nX,2]:cTIPO == "M"

						aadd(aItens,{"U73_MVLANT"	, (cAliasUtil)->&cCampoAlias})
						aadd(aItens,{"U73_MVLPOS"	, oModelAlias:GetValue( cCampoAlias )})

					endif

					aadd(aDetAlt,aItens)

				endif

			endif

		Next nX

	endif

	RestArea(aAreaAlias)
	RestArea(aArea)

Return(lAlterAlias)

/*/{Protheus.doc} IncPerfil
Abertura de cadastro MVC de Perfil de Pagamento
@type function
@version 1.0  
@author Wellington Gonçalves
@since 25/01/2019
@return variant, return_description
/*/
Static Function IncPerfil()

	Local lRet := .T.

	nInc := FWExecView('INCLUIR','UVIND07',3,,{|| .T. })

	if nInc <> 0
		MsgInfo("A Inclusão do Perfil de Pagamento não foi realizada. Não será possível ativar o contrato!","Atenção!")
		lRet := .F.
	endif

Return(lRet)

/*/{Protheus.doc} AtribuiNumSorte
Funcao para atribuir numero da sorte em contratos ativados
@type function
@version 1.0  
@author Raphael Martins
@since 25/01/2019
@param cContrato, character, param_description
@return variant, return_description
/*/
Static Function AtribuiNumSorte(cContrato)

	Local aArea 			:= GetArea()
	Local aAreaUF2			:= UF2->(GetArea())
	Local cNumSor			:= ""
	Local lRet				:= .F.
	Local lAtivaNumS2		:= SuperGetMV("MV_XATNMS2",,.F.)

	// pego o numero da sorte para o contrato
	cNumSor := U_RFUNE031()

	if !Empty(cNumSor)

		RecLock("UF2",.F.)

		if !lAtivaNumS2
			UF2->UF2_NUMSOR := cNumSor
		else
			UF2->UF2_NUMSO2	:= cNumSor
		endif

		UF2->(MsUnlock())

		U_RFUNE31A( cNumSor, cContrato)

		lRet := .T.
	endif

	RestArea(aArea)
	RestArea(aAreaUF2)

Return lRet

/*/{Protheus.doc} AjustaConvalescente
Funcao para mudar cliente dos titulos convalescente 
em caso de mudanca de titularidade do contrato funerario
@type function
@version 1.0  
@author g.sampaio
@since 11/11/2019
@param cContrato, character, param_description
@param oSay, object, param_description
@param cErroVindi, character, param_description
@param cCliente, character, param_description
@param cLoja, character, param_description
@return variant, return_description
/*/
Static Function AjustaConvalescente( cContrato,oSay,cErroVindi,cCliente,cLoja )

	Local lRet 			:= .T.
	Local cQry			:= ""
	Local lRecorrencia  := .F.
	Local cOrigem		:= "PFUNA002"
	Local cOrigemDesc	:= "Ajuste de Convalescente"

	U60->(DbSetOrder(2))
	U61->(DbSetOrder(1))

//Busco contratos ativos de convalescente
	cQry := " SELECT"
	cQry += " 	UJH_CODIGO,"
	cQry += " 	UJH_FORPG,"
	cQry += " 	UF2_CLIENT,"
	cQry += " 	UF2_LOJA"
	cQry += " FROM " + RETSQLNAME("UJH") + " UJH"
	cQry += " INNER JOIN " + RETSQLNAME("UF2") + " UF2"
	cQry += " ON UF2_FILIAL ='" + xFilial("UF2") + "'"
	cQry += " 	AND UF2_CODIGO = UJH_CONTRA"
	cQry += " 	AND UF2.D_E_L_E_T_ = ' '"
	cQry += " WHERE UJH.D_E_L_E_T_ = ' '"
	cQry += " 	AND UJH_STATUS IN ('L','P')"
	cQry += " 	AND UJH_FILIAL  = '"+ xFilial("UJH") 	+ "'"
	cQry += " 	AND UJH_CONTRA  = '"+ cContrato 		+ "'"

	cQry := ChangeQuery(cQry)

	If Select("QUJH") > 1
		QUJH->(DbCloseArea())
	endif

	TcQuery cQry New Alias "QUJH"

	While QUJH->(!EOF())

		//Valido se a forma de pagamento do convalescente nao é Recorrencia
		If U60->(DbSeek(xFilial("U60") + Alltrim(QUJH->UJH_FORPG)))

			lRecorrencia := .T.

			oVindi := IntegraVindi():New()

			//Valido se ja existe perfil de pagamento ativo para o cliente anterior
			if U61->(DbSeek(xFilial("U61")+cContrato+QUJH->UF2_CLIENT+QUJH->UF2_LOJA)) .AND. U61->U61_STATUS == "A"

				//Arquiva cliente anterior
				FWMsgRun(,{|oSay| lRet:= oVindi:CliOnline("E","F",@cErroVindi,cOrigem,cOrigemDesc)},'Aguarde...','Enviando Exclusão do titular anterior na Plataforma Vindi...')

			endif

			//Se cliente foi arquivado
			if lRet

				//Valido se novo cliente possui perfil ativo na VINDI
				if !U61->(DbSeek(xFilial("U61")+cContrato+cCliente+cLoja+"A"))

					if lRet

						// tela para preenchimento do perfil de pagamento
						FWMsgRun(,{|oSay| lRet := IncPerfil()},'Aguarde...','Abrindo Perfil de Pagamento...')

					endif
				else

					Help(NIL, NIL, "Atenção!", NIL, "Não foi possível cadastro cliente VINDI ativo!", 1, 0, NIL, NIL, NIL, NIL, NIL, {cErroVindi})

				endif

				if !lRet

					Help(NIL, NIL, "Atenção!", NIL, "Não foi possível realizar a Inclusao do perfil de pagamento na Vindi!", 1, 0, NIL, NIL, NIL, NIL, NIL, {cErroVindi})
					Exit

				Endif

			endif
		else

			lRet := .T.

		endif

		if lRet

			//Se tem Contrato ativo verifico se tem titulos de convalescente
			cQSE1 := " SELECT"
			cQSE1 += " 		A1_NOME,"
			cQSE1 += "		E1.R_E_C_N_O_ RECNOSE1 "
			cQSE1 += " FROM " + RETSQLNAME("SE1") + " E1"
			cQSE1 += " INNER JOIN " + RETSQLNAME("SA1")   + " A1"
			cQSE1 += " ON A1_FILIAL ='" + xFilial("SA1")  + "'"
			cQSE1 += " 		AND A1_COD = '" + cCliente + "'"
			cQSE1 += " 		AND A1_LOJA= '" + cLoja    + "'"
			cQSE1 += " 		AND A1.D_E_L_E_T_= ' '"
			cQSE1 += " WHERE E1.D_E_L_E_T_ = ' '"
			cQSE1 += " 		AND E1_FILIAL  = '" + xFilial("SE1")    + "'"
			cQSE1 += "		AND E1_XCONCTR = '" + QUJH->UJH_CODIGO  + "'"
			cQSE1 += "		AND E1_XCTRFUN = '" + cContrato			+ "'"
			cQSE1 += " 		AND E1.E1_VALOR = E1.E1_SALDO "
			cQSE1 += "		AND SUBSTRING(E1.E1_VENCTO,1,6) >= '" + AnoMes(dDataBase) + "'"

			cQSE1 := ChangeQuery(cQSE1)

			If Select("QCON") > 1
				QCON->(DbCloseArea())
			endif

			TcQuery cQSE1 New Alias "QCON"

			While QCON->(!EOF())

				//Posiciono no titulo
				SE1->(DbGoTo(QCON->RECNOSE1))

				//Valido se é recorrencia
				If !lRecorrencia

					oSay:cCaption := ("Ajustando cliente para parcelas Convalescente " + AllTrim(SE1->E1_PARCELA) + "...")
					ProcessMessages()

					//Atualiza cliente do titulo
					if Reclock("SE1", .F.)

						SE1->E1_CLIENTE := cCliente
						SE1->E1_LOJA    := cLoja
						SE1->E1_NOMCLI  := QCON->A1_NOME

						SE1->(MsUnLock())
					endif

					//Forma de pamento recorrencia
				else

					oSay:cCaption := ("Preparando titulos para enviar para VINDI " + AllTrim(SE1->E1_PARCELA) + "...")
					ProcessMessages()

					//Atualiza cliente do titulo
					if Reclock("SE1", .F.)

						SE1->E1_CLIENTE := cCliente
						SE1->E1_LOJA    := cLoja
						SE1->E1_NOMCLI  := QCON->A1_NOME

						SE1->(MsUnLock())
					endif

					//prepara envio do titulo para vindi
					EnviaTituloVindi(cOrigem,cOrigemDesc)

				Endif

				QCON->(DbSkip())
			EndDo

		endif

		QUJH->(DbSkip())
	EndDo

Return lRet

/*/{Protheus.doc} TrocaCliVindi
Arquiva cliente vindi para inclui novo cliente na troca
de titularidade do contrato funerario
@type function
@version 1.0
@author Leandro Rodrigues
@since 11/11/2019
@param cErroVindi, character, cErroVindi
@param cContrato, character, cContrato
@param cCliAnt, character, cCliAnt
@param cLojaAnt, character, cLojaAnt
@return Logical, lRet
/*/
Static Function TrocaCliVindi( cErroVindi,cContrato,cCliAnt,cLojaAnt )

	Local oVindi		:= IntegraVindi():New()
	Local aAreaU61		:= U61->(GetArea())
	Local lRet	 		:= .T.
	Local cStatus		:= ""
	Local cOrigem		:= "PFUNA002"
	Local cOrigemDesc	:= "Alteracao de Titularidade do Contrato"

	U61->(DbSetOrder(1))
	//Posiciono no cliente que sera arquivado
	If U61->(DbSeek(xFilial("U61")+cContrato+cCliAnt+cLojaAnt+"A"))

		//Arquivo cliente anterior na VINDI
		FWMsgRun(,{|oSay| lRet:= oVindi:CliOnline("E","F",@cErroVindi,cOrigem,cOrigemDesc)},'Aguarde...','Enviando Exclusão do titular anterior na Plataforma Vindi...')

	endif

	if lRet
		//Posiciono nas faturas do contrato para inativar
		U65->(DbSetOrder(4)) //U65_FILIAL + U65_CONTRA + U65_CLIENT + U65_LOJA
		if U65->(DbSeek(xFilial("U65") + UF2->UF2_CODIGO + UF2->UF2_CLIENT + UF2->UF2_LOJA ))

			While U65->(!EOF());
					.AND. 	U65->U65_FILIAL + U65->U65_CONTRA + U65->U65_CLIENT + AllTrim(U65->U65_LOJA) == xFilial("U65") + UF2->UF2_CODIGO + UF2->UF2_CLIENT + UF2->UF2_LOJA

				//Consulto status da fatura na VINDI
				cStatus := oVindi:ConsultaFatura("F",@cErroVindi,U65->U65_CODVIN,/*cCodRet*/,/*cDescRetorno*/,/*cDadosRetorno*/)

				If AllTrim(cStatus) == "canceled" .AND. U65->U65_STATUS == "A"
					If Reclock("U65",.F.)
						U65->U65_STATUS := "I"
						U65->(MsUnLock())
					EndIf
				ElseIf AllTrim(cStatus) <> "canceled" .AND. U65->U65_STATUS == "I"
					If Reclock("U65",.F.)
						U65->U65_STATUS := "A"
						U65->(MsUnLock())
					EndIf
				EndIf

				U65->(DbSkip())
			EndDo
		endif
	Else

		Help(NIL, NIL, "Atenção!", NIL, "Ocorreu um problema na exclusao do titular anterior na VINDI, favor acessar portal e excluir de forma manual !", 1, 0, NIL, NIL, NIL, NIL, NIL, {cErroVindi})

	Endif

	RestArea(aAreaU61)
Return lRet

/*/{Protheus.doc} EnviaTituloVindi
Funcao para enviar titulo novamente para vindi apos a troca
de titularidade do contrato funerario   
@type function
@version 1.0
@author Leandro Rodrigues
@since 11/11/2019
@param cOrigem, character, param_description
@param cOrigemDesc, character, param_description
@return variant, return_description
/*/
Static Function EnviaTituloVindi(cOrigem,cOrigemDesc)

	Local lRet := .T.

//valido se ja existe titulo na vindi e esta ativo e inativa se houver
	If U65->(DbSeek(xFilial("U65")+ SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + "A" ))

		If Reclock("U65",.F.)

			U65->U65_STATUS := "I"

			U65->(MsUnLock())
		endif
	endif

//Se nao tem titulo ativo envia VINDI
	if lRet

		If !ValidaU62(SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)

			//gravo titulo para envio a VINDI
			oVindi:IncluiTabEnvio("F","3","I",1,SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO,/*aProc*/,cOrigem,cOrigemDesc)
		endif

	Endif

Return

/*/{Protheus.doc} 
Valido se ja existe registro na U62 que ainda nao foi processado
gerados contra Adm Financeira
@author Leandro Rodrigues
@since 03/10/2019
@version P12
@param nulo
@return nulo
/*/
Static Function ValidaU62( cChave )

	Local cQry := ""
	Local lRet := .F.

	cQry := " SELECT "
	cQry += " 	U62_CHAVE"
	cQry += " FROM " + RETSQLNAME("U62")
	cQry += " WHERE D_E_L_E_T_ = ' '"
	cQry += " 	AND U62_ENT = '3'"
	cQry += " 	AND U62_OPER = 'I'"
	cQry += " 	AND U62_STATUS <> 'C'"
	cQry += " 	AND RTRIM(U62_CHAVE) = '"+ cChave +"'"

	cQry := ChangeQuery(cQry)

	If Select("QU62") > 1
		QU62->(DbCloseArea())
	endif

	TcQuery cQry New Alias "QU62"

	If QU62->(!EOF())
		lRet := .T.
	endif

Return lRet

/*/{Protheus.doc} AtuAutorizadoInt
Funcao para atualizar o autorizado
do contrato de integracao de empresas
@type function
@version 1.0 
@author g.sampaio
@since 06/08/2021
@param cFilialOri, character, param_description
@param cContrato, character, param_description
@param cCliAnt, character, param_description
@param cLojaAnt, character, param_description
@param cCliAtual, character, param_description
@param cLojAtual, character, param_description
@return variant, return_description
/*/
Static function AtuAutorizadoInt( cFilialOri, cContrato, cCliAnt, cLojaAnt, cCliAtual, cLojAtual)

	Local aArea				:= GetArea()
	Local aAreaU02			:= U02->(GetArea())
	Local aAreaSA1			:= SA1->(GetArea())
	Local cAliasTab			:= ""
	Local cQuery 			:= ""

	Default cFilialOri	:= ""
	Default cContrato	:= ""
	Default cCliAnt		:= ""
	Default	cLojaAnt	:= ""
	Default cCliAtual	:= ""
	Default cLojAtual 	:= ""

	cQuery := " SELECT "
	cQuery += " U00.U00_FILIAL, "
	cQuery += " U00.U00_CODIGO "
	cQuery += " FROM " + RetSqlName("U00") + " U00 "
	cQuery += " WHERE U00.D_E_L_E_T_ = ' ' "
	cQuery += " AND U00.U00_TPCONT = '2' "
	cQuery += " AND U00.U00_STATUS = 'A' "
	cQuery += " AND U00.U00_FILINT = '"+cFilialOri+"'"
	cQuery += " AND U00.U00_CTRINT = '"+cContrato+"'""

	cAliasTab := FwExecCachedQuery():OpenQuery( cQuery,/*cAlias*/, /*aSetField*/, /*cDriver*/, "240", "60")

	while (cAliasTab)->(!Eof())

		// posiciono no autorizado amarrado ao titular do contrato
		U02->(DbSetOrder(2))
		if U02->(MsSeek( U_IntRetFilial("U02", (cAliasTab)->U00_FILIAL)+(cAliasTab)->U00_CODIGO+cCliAnt+cLojaAnt))

			// deleto o
			if U02->(RecLock("U02",.F.))
				U02->(DBDelete())
				U02->(MsUnlock())
			else
				U02->(DisarmTransaction())
			endIf

		endIf

		// posiociono no cadastro de clientes
		SA1->(DbSetOrder(1))
		if SA1->( MsSeek( U_IntRetFilial("SA1", (cAliasTab)->U00_FILIAL) + cCliAtual + cLojAtual ) )

			// inclui o autorizado caso estiver habilitado
			if SA1->A1_XCEMAUT <> "2"

				// crio um novo autorizado
				if U02->(RecLock("U02",.T.))
					U02->U02_FILIAL := U_IntRetFilial("U02", (cAliasTab)->U00_FILIAL)
					U02->U02_CODIGO	:= (cAliasTab)->U00_CODIGO
					U02->U02_ITEM 	:= ProxItemU02( (cAliasTab)->U00_FILIAL, (cAliasTab)->U00_CODIGO )
					U02->U02_CODCLI	:= SA1->A1_COD
					U02->U02_LOJCLI	:= SA1->A1_LOJA
					U02->U02_NOME 	:= SA1->A1_NOME
					U02->U02_GRAUPA	:= "OU" // Outros
					U02->U02_CPF	:= SA1->A1_CGC
					U02->U02_CI		:= SA1->A1_PFISICA

					if !Empty(SA1->A1_XDTNASC)
						U02->U02_DTNASC	:= SA1->A1_XDTNASC
						U02->U02_IDADE	:= U_UAgeCalculate(SA1->A1_XDTNASC,dDataBase)
					EndIf

					U02->U02_SEXO 	:= SA1->A1_XSEXO
					U02->U02_ESTCIV	:= SA1->A1_XESTCIV
					U02->U02_END	:= SA1->A1_ENDCOB
					U02->U02_COMPLE	:= SA1->A1_COMPLEM
					U02->U02_BAIRRO	:= SA1->A1_BAIRROC
					U02->U02_CEP 	:= SA1->A1_CEP
					U02->U02_EST	:= SA1->A1_EST
					U02->U02_CODMUN	:= SA1->A1_CODMUN
					U02->U02_MUN 	:= SA1->A1_MUN
					U02->U02_DDD	:= SA1->A1_DDD
					U02->U02_FONE	:= SA1->A1_TEL
					U02->U02_CELULA := SA1->A1_XCEL
					U02->U02_EMAIL	:= SA1->A1_EMAIL

					U02->(MsUnlock())
				else
					U02->(DisarmTransaction())
				endIf

			endIf

		endIf

		(cAliasTab)->(DbSkip())
	endDo

	RestArea(aAreaSA1)
	RestArea(aAreaU02)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} ProxItemU02
funcao para retornar o proximo item da U02
@type function
@version 1.0
@author g.sampaio
@since 16/12/2020
@param cCodContrato, Characteracter, codigo do contrato
@return Character, retorna o proximo item do autorizado
/*/
Static Function ProxItemU02( cCodFilial, cCodContrato )

	Local cQuery As Character

	// atribuo valor das variaveis
	cQuery := ""

	if Select("TRBU02") > 0
		TRBU02->(DbCloseArea())
	endIf

	cQuery := " SELECT MAX(U02_ITEM) MAXITEM FROM " + RetSqlName("U02") + " U02 "
	cQuery += " WHERE U02.D_E_L_E_T_ = ' '"
	cQuery += " AND U02.U02_FILIAL = '" + U_IntRetFilial("U02", cCodFilial) + "'"
	cQuery += " AND U02.U02_CODIGO = '" + cCodContrato + "' "

	TcQuery cQuery New Alias "TRBU02"

	if TRBU02->(!Eof())
		cRetorno	:= Soma1(AllTrim(TRBU02->MAXITEM))
	endIf

	if Empty(cRetorno)
		cRetorno := StrZero(1,TamSX3("U02_ITEM")[1])
	endIf

	if Select("TRBU02") > 0
		TRBU02->(DbCloseArea())
	endIf

Return(cRetorno)
