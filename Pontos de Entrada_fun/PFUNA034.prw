#include "protheus.ch"
#include "topconn.ch"
#include "fwmvcdef.ch"
#include "ap5mail.ch"

#DEFINE CRLF CHR(10)+CHR(13)

/*/{Protheus.doc} PFUNA034
Pontos de Entrada do Apontamentos de Serviço mod2
@type function
@version 1.0  
@author TOTVS
@since 26/08/2016
/*/
User Function PFUNA034()

	Local aArea			:= GetArea()
	Local aAreaUF2		:= UF2->(GetArea())
	Local aAreaUF4		:= UF4->(GetArea())
	Local aParam 		:= PARAMIXB
	Local oObj			:= aParam[1]
	Local cIdPonto		:= aParam[2]
	Local cRegraBen		:= ""
	Local oModelUJ0		:= oObj:GetModel("UJ0MASTER")
	Local oModelUJ2		:= oObj:GetModel("UJ2DETAIL")
	Local xRet 			:= .T.
	Local lAux			:= .F.
	Local lRet			:= .F.
	Local cPv1			:= ""
	Local cPv2			:= ""
	Local cTipoProd		:= ""
	Local lPv			:= .F.
	Local nI			:= 0
	Local cCodTab		:= SuperGetMv("MV_XTABSER",.F.,"001")
	Local dDtPresc		:= CToD("")
	Local lEnvSlc		:= SuperGetMv("MV_XENVSLC",.F.,.F.)
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local lIntEmp		:= SuperGetMV("MV_XINTEMP", .F., .F.) // habilito o uso da integracao de empresas
	Local lUpdateUJ2PV	:= SuperGetMV("MV_XUPUJ2P", .F., .F.) // Permite Atualizacao da UJ2 mesmo com Pedido de Venda Gerado
	Local lEnd		:= .F.
	Local oProcIntEmp	:= Nil
	Local aEnvSlc		:= {}
	Local aEnvPed		:= {}
	Local aDetalhes 	:= {}
	Local nTotItem		:= 0

	if cIdPonto == 'MODELVLDACTIVE' .And. oObj:GetOperation() == 4 //Ativação do model e Alteração

		//Caso possua pedido de venda ou requisicao armazem ou pedido de compras, pode alterar o apontamento exceto os produtos e serviços entregues: UJ2
		If !Empty(UJ0->UJ0_PV) .Or. U_VerReqArmazem(UJ0->UJ0_CODIGO) .Or. VerPedComp(UJ0->UJ0_CODIGO) .Or. (lIntEmp .and. UJ0->UJ0_TPAPON == "2")

			// bloqueio alteracao da grid UJ2
			oModelUJ2:SetNoInsertLine(.T.)

			if !lUpdateUJ2PV
				oModelUJ2:SetNoUpdateLine(.T.)
			endif

			oModelUJ2:SetNoDeleteLine(.T.)

		Else

			// libero alteracao da grid UJ2
			oModelUJ2:SetNoInsertLine(.F.)
			oModelUJ2:SetNoUpdateLine(.F.)
			oModelUJ2:SetNoDeleteLine(.F.)

		Endif


	elseIf cIdPonto == 'MODELVLDACTIVE' .And. oObj:GetOperation() == 3 //Ativação do model e Inclusão

		// libero alteracao da grid UJ2
		oModelUJ2:SetNoInsertLine(.F.)
		oModelUJ2:SetNoUpdateLine(.F.)
		oModelUJ2:SetNoDeleteLine(.F.)

	ElseIf cIdPonto == 'MODELPOS' .And. (oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4) //Confirmação da Inclusão ou Alteração

		//Validação preenchimento campo Beneficiário, caso o contrato seja informado
		If !Empty(oModelUJ0:GetValue("UJ0_CONTRA")) .And. Empty(oModelUJ0:GetValue("UJ0_CODBEN"))
			Help( ,, 'Help - MODELPOS',, 'Caso o contrato seja selecionado, obrigatoriamente o campo Beneficiario deve ser informado.', 1, 0 )
			xRet := .F.
		Endif

		//Validação para geração do PV contra adm. de planos
		If xRet .AND. oModelUJ0:GetValue("UJ0_TPSERV") != '3' //Orcamento

			If !Empty(oModelUJ0:GetValue("UJ0_CLIPA"))

				If Empty(oModelUJ0:GetValue("UJ0_LOJAPA")) .Or. Empty(oModelUJ0:GetValue("UJ0_CONDPA")) .Or. Empty(oModelUJ0:GetValue("UJ0_TABPRE"))
					Help( ,, 'Help - MODELPOS',, 'Caso seja necessária a geração de Pedido de Vendas contra a administradora de planos, os campos Loja, Cond Pagto e Cod. tabela devem ser preenchidos.', 1, 0 )
					xRet := .F.
				Endif

			ElseIf !Empty(oModelUJ0:GetValue("UJ0_LOJAPA"))

				If Empty(oModelUJ0:GetValue("UJ0_CLIPA")) .Or. Empty(oModelUJ0:GetValue("UJ0_CONDPA")) .Or. Empty(oModelUJ0:GetValue("UJ0_TABPRE"))
					Help( ,, 'Help - MODELPOS',, 'Caso seja necessária a geração de Pedido de Vendas contra a administradora de planos, os campos Cli Pv Adm, Cond Pagto e Cod. tabela devem ser preenchidos.', 1, 0 )
					xRet := .F.
				Endif

			ElseIf !Empty(oModelUJ0:GetValue("UJ0_TABPRE"))

				If Empty(oModelUJ0:GetValue("UJ0_CLIPA")) .Or. Empty(oModelUJ0:GetValue("UJ0_LOJAPA")) .Or. Empty(oModelUJ0:GetValue("UJ0_CONDPA"))
					Help( ,, 'Help - MODELPOS',, 'Caso seja necessária a geração de Pedido de Vendas contra a administradora de planos, os campos Cli Pv Adm, Loja e Cond Pagto devem ser preenchidos.', 1, 0 )
					xRet := .F.
				Endif
			Endif
		Endif

		If xRet

			//Valida a seleção de ao menos um item
			For nI := 1 To oModelUJ2:Length()

				// posiciono na linha atual
				oModelUJ2:Goline(nI)

				If !oModelUJ2:IsDeleted()

					If oModelUJ2:GetValue("UJ2_OK")

						If oModelUJ2:GetValue("UJ2_PV") == "S"
							lPv := .T.
						Endif

						If Empty(oModelUJ2:GetValue("UJ2_PRCVEN"))
							Help( ,, 'Help - MODELPOS',, 'O produto '+oModelUJ2:GetValue("UJ2_PRODUT")+' nao possui preço vigente na tabela de preco '+cCodTab+'.', 1, 0 )
							xRet := .F.
							Exit
						Endif

						// validacao da integracao de empresas
						if lIntEmp .And. !Empty(oModelUJ0:GetValue("UJ0_CONTRA"))

							// valida a integracao de empresas
							if !ValIntEmpresas(oObj:GetOperation(), oModelUJ0, nI, oModelUJ2)
								xRet := .F.
								Exit
							endIf

						endIf

						lAux := .T.
					Endif
				Endif
			Next nI

			If xRet .And. !lAux
				Help( ,, 'Help - MODELPOS',, 'Nenhum item apontado, operação não permitida.', 1, 0 )
				xRet := .F.
			Endif

		Endif

	ElseIf cIdPonto == 'MODELPOS' .And. oObj:GetOperation() == 5 //Confirmação da Exclusão

		// validação quanto aos pedidos de venda
		If !Empty(UJ0->UJ0_PV) .Or. !Empty(UJ0->UJ0_PVADM)
			Help( ,, 'Help - MODELPOS',, 'Não e possivel excluir o Apontamento de Serviço, pois há Pedido(s) de Venda relacionado(s).', 1, 0 )
			xRet := .F.
		Endif

		If xRet .and. U_VerReqArmazem(UJ0->UJ0_CODIGO)
			Help( ,, 'Help - MODELPOS',, 'Não e possivel excluir o Apontamento de Serviço, pois há Requisição ao Armazém relacionada.', 1, 0 )
			xRet := .F.
		EndIf

		// validacao da integracao de empresas
		If lIntEmp .And. xRet
			// valida a integracao de empresas
			If UJ0->UJ0_TPAPON == "2" .And. !ValIntEmpresas(oObj:GetOperation(), oModelUJ0) // apontamento integrado
				xRet := .F.
			EndIf
		EndIf

		// validação pedido de compras
		If xRet .and. VerPedComp(UJ0->UJ0_CODIGO)
			Help( ,, 'Help - MODELPOS',, 'Não e possível excluir o Apontamento de Serviço, pois há Pedido(s) de Compra(s) relacionado(s).', 1, 0 )
			xRet := .F.
		EndIf

	ElseIf cIdPonto == 'MODELCOMMITNTTS' //Após a gravação dos dados

		If oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4 //Inclusão ou Alteração

			If !FWIsInCallStack("U_RFUNE052") // se for por execauto

				//Valido se é orcamento
				If oModelUJ0:GetValue("UJ0_TPSERV") != '3'

					//Geração de PV contra cliente
					If !Empty(UJ0->UJ0_CLIPV) .And. Empty(UJ0->UJ0_PV) .And. Empty(UJ0->UJ0_PV2) .And. MsgYesNo("Deseja Gerar Pedido de Venda para o Cliente?") //Não tenha gerado PV contra o cliente

						BEGIN TRANSACTION

							//-- Detalhes para cabeçalho pedido de venda --//
							aDetalhes := {}
							AADD(aDetalhes, UJ0->UJ0_NOMEFA)
							AADD(aDetalhes, UJ0->UJ0_DTFALE)
							AADD(aDetalhes, UJ0->UJ0_DECOBT)
							AADD(aDetalhes, UJ0->UJ0_CADOBT)
							If !Empty(UJ0->UJ0_REMOCA)
								AADD(aDetalhes, AllTrim(Posicione("UJC", 1, xFilial("UJC") + UJ0->UJ0_REMOCA, "UJC_DESCRI")))
							Else
								AADD(aDetalhes, AllTrim(UJ0->UJ0_LOCREM))
							EndIf
							If !Empty(UJ0->UJ0_VELORI)
								AADD(aDetalhes, AllTrim(Posicione("UJD", 1, xFilial("UJD") + UJ0->UJ0_VELORI, "UJD_DESCRI")))
							Else
								AADD(aDetalhes, AllTrim(UJ0->UJ0_LOCVEL))
							EndIf
							AADD(aDetalhes, UJ0->UJ0_MOTORI)
							AADD(aDetalhes, AllTrim(Posicione("UJB", 1, xFilial("UJB") + UJ0->UJ0_MOTORI, "UJB_NOME")))
							AADD(aDetalhes, UJ0->UJ0_RELIGI)
							AADD(aDetalhes, AllTrim(Posicione("UG3", 1, xFilial("UG3") + UJ0->UJ0_RELIGI, "UG3_DESC")))
							AADD(aDetalhes, UJ0->UJ0_ATENDE)

							FWMsgRun(,{|oSay| lRet := U_GeraPV_J(@cPv1,@cPv2,;
								UJ0->UJ0_CLIPV,;
								UJ0->UJ0_LOJAPV,;
								UJ0->UJ0_CONDPV,;
								UJ0->UJ0_MENNFS,;
								UJ0->UJ0_CODIGO,;
								UJ0->UJ0_CONTRA,;
								"C",;
								UJ0->UJ0_TABPRC,;
								aDetalhes)},'Aguarde','Gerando Pedido de Venda contra o cliente...')

							//Atualiza status
							If lRet

								RecLock("UJ0",.F.)

								UJ0->UJ0_PV		:= cPv1
								UJ0->UJ0_PV2	:= cPv2

								UJ0->(MsUnlock())

							Endif

						END TRANSACTION

					endIf

				Endif

			EndIf

			//////////////////////////////////////////////////////
			/////// REALIZO SOLICITACAO AO ARMAZEM 		/////////
			/////////////////////////////////////////////////////
			if oObj:GetOperation() == 3 .Or. !U_VerReqArmazem(UJ0->UJ0_CODIGO)

				UJ2->(DbSetOrder(1)) //UJ2_FILIAL+UJ2_CODIGO+UJ2_ITEM

				If UJ2->(MsSeek(xFilial("UJ2")+UJ0->UJ0_CODIGO))

					While UJ2->(!EOF()) .And. xFilial("UJ2") == UJ2->UJ2_FILIAL .And. UJ2->UJ2_CODIGO == UJ0->UJ0_CODIGO

						cTipoProd := RetField("SB1",1,xFilial("SB1") + UJ2->UJ2_PRODUT,"B1_TIPO")

						If UJ2->UJ2_OK .And. !Empty(UJ2->UJ2_UNESTO) .And. cTipoProd <> 'SV' .And. Empty(UJ2->UJ2_CODFOR)

							If lEnvSlc

								AAdd(aEnvSlc,{UJ2->UJ2_UNESTO,UJ2->UJ2_LOCAL,UJ2->UJ2_PRODUT,UJ2->UJ2_QUANT,UJ2->UJ2_ITEM})

							Endif

						ElseIf !Empty(UJ2->UJ2_CODFOR) .and. !Empty(UJ2->UJ2_LOJFOR)

							If UJ2->UJ2_TOTAL > 0
								nTotItem := UJ2->UJ2_TOTAL / UJ2->UJ2_QUANT // Valor por minimo de item com financeiro
							Else
								nTotItem := UJ2->UJ2_SUBTOT / UJ2->UJ2_QUANT // Valor por item somente estoque
							EndIf

							AAdd(aEnvPed,{UJ2->UJ2_CODFOR,UJ2->UJ2_LOJFOR,UJ2->UJ2_LOCAL,UJ2->UJ2_PRODUT,UJ2->UJ2_QUANT,nTotItem,UJ2->(UJ2_FILIAL+UJ2_CODIGO+UJ2_ITEM),UJ2->UJ2_CODIGO})

						EndIf

						UJ2->(DbSkip())

					EndDo

				Endif

				If !FWIsInCallStack("U_RFUNE052") // se for por execauto

					If Len(aEnvSlc) > 0 .And. MsgYesNo("Deseja Gerar a Solicitacao ao Armazem?")

						//Ordena os dados de envio por filial
						aSort(aEnvSlc,,,{|x,y| x[1] < y[1]})

						//Inclui Solicitacao ao Armazen
						FWMsgRun(,{|oSay| U_USolicitaArmazem(oSay,aEnvSlc,UJ0->UJ0_CODIGO,UJ0->UJ0_CONTRA,UJ0->UJ0_SEXO,UJ0->UJ0_NOMEFA)},'Aguarde','Realizando Solicitação ao Armazem...')

					Endif

					If Len(aEnvPed) > 0 .And. MsgYesNo("Deseja Gerar os Pedidos de Compras?")

						//Ordena os dados do pedido por fornecedor/loja
						aSort(aEnvPed,,,{|x,y| x[1]+x[2] < y[1]+y[2]})

						//Inclui Solicitacao ao Armazen
						FWMsgRun(,{|oSay| U_FUNA034C(aEnvPed)},'Aguarde','Realizando Pedidos de Compras...')

					Endif

				EndIf

			endif

			//Se nao for orcamento
			If !FWIsInCallStack("U_RFUNE052") .And. oModelUJ0:GetValue("UJ0_TPSERV") != '3'

				//Geração de PV contra adm. de planos
				If !Empty(UJ0->UJ0_CONTRA) .And. Empty(UJ0->UJ0_PVADM) .And. MsgYesNo("Deseja Gerar pedido de venda contra a administradora?")

					lAux := .F.

					If !Empty(UJ0->UJ0_CLIPA) .And. !Empty(UJ0->UJ0_LOJAPA) .And. !Empty(UJ0->UJ0_CONDPA)

						//Valida a seleção de ao menos um item
						UJ2->(DbSetOrder(1)) //UJ2_FILIAL+UJ2_CODIGO+UJ2_ITEM

						If UJ2->(MsSeek(xFilial("UJ2")+UJ0->UJ0_CODIGO))

							While UJ2->(!EOF()) .And. xFilial("UJ2") == UJ2->UJ2_FILIAL .And. UJ2->UJ2_CODIGO == UJ0->UJ0_CODIGO

								If UJ2->UJ2_OK

									lAux := .T.
									Exit

								Endif

								UJ2->(DbSkip())

							EndDo

						Endif

						If lAux

							BEGIN TRANSACTION

								//-- Detalhes para cabeçalho pedido de venda --//
								aDetalhes := {}
								AADD(aDetalhes, UJ0->UJ0_NOMEFA)
								AADD(aDetalhes, UJ0->UJ0_DTFALE)
								AADD(aDetalhes, UJ0->UJ0_DECOBT)
								AADD(aDetalhes, UJ0->UJ0_CADOBT)
								If !Empty(UJ0->UJ0_REMOCA)
									AADD(aDetalhes, AllTrim(Posicione("UJC", 1, xFilial("UJC") + UJ0->UJ0_REMOCA, "UJC_DESCRI")))
								Else
									AADD(aDetalhes, AllTrim(UJ0->UJ0_LOCREM))
								EndIf
								If !Empty(UJ0->UJ0_VELORI)
									AADD(aDetalhes, AllTrim(Posicione("UJD", 1, xFilial("UJD") + UJ0->UJ0_VELORI, "UJD_DESCRI")))
								Else
									AADD(aDetalhes, AllTrim(UJ0->UJ0_LOCVEL))
								EndIf
								AADD(aDetalhes, UJ0->UJ0_MOTORI)
								AADD(aDetalhes, AllTrim(Posicione("UJB", 1, xFilial("UJB") + UJ0->UJ0_MOTORI, "UJB_NOME")))
								AADD(aDetalhes, UJ0->UJ0_RELIGI)
								AADD(aDetalhes, AllTrim(Posicione("UG3", 1, xFilial("UG3") + UJ0->UJ0_RELIGI, "UG3_DESC")))
								AADD(aDetalhes, UJ0->UJ0_ATENDE)

								FWMsgRun(,{|oSay| lRet := U_GeraPV_J(@cPv1,@cPv2,;
									UJ0->UJ0_CLIPA,;
									UJ0->UJ0_LOJAPA,;
									UJ0->UJ0_CONDPA,;
									"",;
									UJ0->UJ0_CODIGO,;
									UJ0->UJ0_CONTRA,;
									"A",;
									UJ0->UJ0_TABPRE,;
									aDetalhes)},'Aguarde','Gerando Pedido de Venda contra a administradora de planos...')

								//Atualiza status
								If lRet

									RecLock("UJ0",.F.)
									UJ0->UJ0_PVADM := cPv1
									UJ0->(MsUnlock())

								Endif

							END TRANSACTION

						Endif
					else
						MsgAlert("Nao foi possivel gerar pedido contra adiministradora,verifique se foi informado os dados da ADM de Planos","Pedido Administradora")

					Endif

				Endif
			Endif

			if !Empty(UJ0->UJ0_DTFALE)

				// quando houver plano pet habilitado
				if lPlanoPet

					if UJ0->UJ0_USO == "3" // pet

						UK2->(DbSetOrder(1))
						if UK2->(MsSeek( xFilial("UK2")+UJ0->UJ0_CONTRA+UJ0->UJ0_CODBEN ))

							RecLock("UK2",.F.)
							UK2->UK2_DTFALE := UJ0->UJ0_DTFALE
							UK2->(MsUnlock())

						endIf

					elseIf UJ0->UJ0_USO == "2" // humano

						DbSelectArea("UF4")
						UF4->(DbSetOrder(1)) //UF4_FILIAL+UF4_CODIGO+UF4_ITEM
						If UF4->(MsSeek(xFilial("UF4")+UJ0->UJ0_CONTRA+UJ0->UJ0_CODBEN))

							// verifico se tem regra para o beneficiario
							if !Empty(UF4->UF4_REGRA)
								cRegraBen := UF4->UF4_REGRA
							else// regra a do apontamento
								cRegraBen := UJ0->UJ0_REGRA
							endIf

							If !Empty(cRegraBen)
								// pego a data de prescricao do falecido
								dDtPresc := U_RetPresc(cRegraBen,UJ0->UJ0_DTFALE,UJ0->UJ0_CONTRA)
							endIf

							RecLock("UF4",.F.)

							UF4->UF4_FALECI := UJ0->UJ0_DTFALE

							if !Empty(dDtPresc)// preencho a data de prescricao do falecido
								UF4->UF4_DTFIM	:= dDtPresc
							endIf

							UF4->(MsUnlock())

						Endif
					Endif

				else

					DbSelectArea("UF4")
					UF4->(DbSetOrder(1)) //UF4_FILIAL+UF4_CODIGO+UF4_ITEM
					If UF4->(MsSeek(xFilial("UF4")+UJ0->UJ0_CONTRA+UJ0->UJ0_CODBEN))

						// verifico se tem regra para o beneficiario
						if !Empty(UF4->UF4_REGRA)
							cRegraBen := UF4->UF4_REGRA
						else// regra a do apontamento
							cRegraBen := UJ0->UJ0_REGRA
						endIf

						If !Empty(cRegraBen)
							// pego a data de prescricao do falecido
							dDtPresc := U_RetPresc(cRegraBen,UJ0->UJ0_DTFALE,UJ0->UJ0_CONTRA)
						endIf

						RecLock("UF4",.F.)

						UF4->UF4_FALECI := UJ0->UJ0_DTFALE

						if !Empty(dDtPresc)// preencho a data de prescricao do falecido
							UF4->UF4_DTFIM	:= dDtPresc
						endIf

						UF4->(MsUnlock())

					Endif

				Endif

			endIf

			// integracao de empresas inclusao ou altearacao e associado
			if !FWIsInCallStack("U_RFUNE052") .And. lIntEmp .And. (oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4) .And. oModelUJ0:GetValue("UJ0_TPSERV") == "1"

				UF2->(DbSetOrder(1)) //UF2_FILIAL + UF2_CODIGO

				if UF2->(DbSeek(xFilial("UF2") + oModelUJ0:GetValue("UJ0_CONTRA") ))

					// executo o programa da integracao de empresas
					oProcIntEmp := MsNewProcess():New( { | lEnd | U_RUTILE42( @lEnd, @oProcIntEmp, UF2->UF2_MSFIL, UJ0->UJ0_CONTRA, UJ0->UJ0_CODIGO) }, "Integracao de Empresas", "Aguarde, realizando a integracao de empresas ...", .F. )
					oProcIntEmp:Activate()

				endif

			endIf

		elseIf  oObj:GetOperation() == 5 //Exclusão

			// quando houver plano pet habilitado
			if lPlanoPet

				if UJ0->UJ0_USO == "3" // pet

					UK2->(DbSetOrder(1))
					if UK2->(MsSeek( xFilial("UK2")+UJ0->UJ0_CONTRA+UJ0->UJ0_CODBEN ))

						RecLock("UK2",.F.)
						UK2->UK2_DTFALE := Stod("")
						UK2->(MsUnlock())

					endIf

					//Posiciono no conrato
					UF2->(DbSetOrder(1)) // UF2_FILIAL + UF2_CODIGO
					If UF2->(MsSeek(xFilial("UF2") + UJ0->UJ0_CONTRA))

						//Se o contrato estava com status de F=FINALIZADO
						//e está sendo excluido um apontamento
						If UF2->UF2_STATUS == "F"

							//Volto seu status para A=ATIVO
							If RecLock("UF2",.F.)

								UF2->UF2_STATUS := "A"

								UF2->(MsUnlock())

								MsgInfo("Este contrato foi retornado para o Status Ativo!","Finalização de Contrato")

							Endif

						Endif

					Endif

				else

					DbSelectArea("UF4")
					UF4->(DbSetOrder(1)) //UF4_FILIAL+UF4_CODIGO+UF4_ITEM

					If UF4->(MsSeek(xFilial("UF4")+UJ0->UJ0_CONTRA+UJ0->UJ0_CODBEN))

						RecLock("UF4",.F.)

						UF4->UF4_FALECI	:= CToD("")

						UF4->UF4_DTFIM	:= CToD("")

						UF4->(MsUnlock())

					Endif

					//Posiciono no conrato
					UF2->(DbSetOrder(1)) // UF2_FILIAL + UF2_CODIGO

					If UF2->(MsSeek(xFilial("UF2") + UJ0->UJ0_CONTRA))

						//Se o contrato estava com status de F=FINALIZADO
						//e está sendo excluido um apontamento
						If UF2->UF2_STATUS == "F"

							//Volto seu status para A=ATIVO
							If RecLock("UF2",.F.)

								UF2->UF2_STATUS := "A"

								UF2->(MsUnlock())

								MsgInfo("Este contrato foi retornado para o Status Ativo!","Finalização de Contrato")

							Endif

						Endif

					Endif

				endIf

			else

				DbSelectArea("UF4")
				UF4->(DbSetOrder(1)) //UF4_FILIAL+UF4_CODIGO+UF4_ITEM

				If UF4->(MsSeek(xFilial("UF4")+UJ0->UJ0_CONTRA+UJ0->UJ0_CODBEN))

					RecLock("UF4",.F.)

					UF4->UF4_FALECI	:= CToD("")

					UF4->UF4_DTFIM	:= CToD("")

					UF4->(MsUnlock())

				Endif

				//Posiciono no conrato
				UF2->(DbSetOrder(1)) // UF2_FILIAL + UF2_CODIGO

				If UF2->(MsSeek(xFilial("UF2") + UJ0->UJ0_CONTRA))

					//Se o contrato estava com status de F=FINALIZADO
					//e está sendo excluido um apontamento
					If UF2->UF2_STATUS == "F"

						//Volto seu status para A=ATIVO
						If RecLock("UF2",.F.)

							UF2->UF2_STATUS := "A"

							UF2->(MsUnlock())

							MsgInfo("Este contrato foi retornado para o Status Ativo!","Finalização de Contrato")

						Endif

					Endif

				Endif

			endIf

			if lIntEmp

				// se apontamento de integracao
				if UJ0->UJ0_TPAPON == "2"

					// executo o programa da integracao de empresas
					oProcIntEmp := MsNewProcess():New( { | lEnd | ExcIntegracaoInt( @lEnd, @oProcIntEmp, UJ0->UJ0_FILIAL, UJ0->UJ0_CONTRA, UJ0->UJ0_CODIGO) }, "Integracao de Empresas", "Aguarde, realizando a exclusao dos dados da integracao de empresas ...", .F. )
					oProcIntEmp:Activate()

				EndIf

			endIf

		endIf

		////////////////////////////////////////////////
		//// executo ponto dentro no MODELPOS
		////////////////////////////////////////////////
		If cIdPonto == 'MODELPOS' // na validacao do modelo para qualquer operacao
			// para inclusao/alteracao/exclusao
			If xRet .And. oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4 .Or. oObj:GetOperation() == 5
				// executo ponto de entrada no MODELPOS para inclusao/alteracao/exclusao
				// para inclusao de validacoes e operacoes do cliente, retorno logico esperado
				If ExistBlock("PEFN34MPOS")
					xRet := ExecBlock( "PEFN34MPOS", .F., .F., { oObj:GetOperation(), oModelUJ0, oModelUJ2 } )
				EndIf
			EndIf
		EndIf

		//Reprocesso saldo do contrato dos itens do contrato
		RepContrato(UJ0->UJ0_CONTRA)

	ElseIf cIdPonto == 'BUTTONBAR'

		xRet := {	{"Legenda Carencia"		,"LEGCARAP" ,{|| LegCarApto()},"Legenda Carencia"	},;
			{"Legenda Estoque"		,"LEGESTAP" ,{|| LegEstApto()},"Legenda Estoque"	},;
			{"Posicao Produto[F4]"	,"POSPRODAP",{|| U_RFUNE032()},"Posicao Produto[F4]"}}
	Endif

	RestArea(aAreaUF2)
	RestArea(aAreaUF4)
	RestArea(aArea)

Return(xRet)

/*/{Protheus.doc} RepContrato
Reprocessa saldo do contrato
@author TOTVS
@since 03/09/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function RepContrato(cContrato)

	Local aArea 	:= GetArea()
	Local aAreaUF2	:= UF2->(GetArea())
	Local aAreaUJ0	:= UJ0->(GetArea())
	Local aAreaUJ2	:= UJ2->(GetArea())
	Local cQry 		:= ""

	cQry := " SELECT "
	cQry += " UF3_PROD PRODUTO, "
	cQry += " UF3_QUANT QTD_CONTRATO, "
	cQry += " COALESCE(SUM(UJ2_QUANT),0) QTD_OS "
	cQry += " FROM  "
	cQry += " " + RetSQLName("UF3") + " UF3 "
	cQry += " LEFT JOIN " + RetSQLName("UJ0") + " UJ0 "
	cQry += " ON "
	cQry += " UJ0.D_E_L_E_T_ = ' ' "
	cQry += " AND UF3_FILIAL = '" + xFilial("UF3") + "' "
	cQry += " AND UJ0.UJ0_FILIAL = '" + xFilial("UJ0") + "' "
	cQry += " AND UF3_CODIGO = UJ0.UJ0_CONTRA "
	cQry += " LEFT JOIN " + RetSQLName("UJ2") + " UJ2 "
	cQry += " ON "
	cQry += " UJ2.D_E_L_E_T_ = ' ' "
	cQry += " AND UJ0_FILIAL = UJ2.UJ2_FILIAL "
	cQry += " AND UJ0_CODIGO = UJ2.UJ2_CODIGO "
	cQry += " AND UF3.UF3_PROD = UJ2.UJ2_PRODUT"
	cQry += " WHERE  "
	cQry += " UF3.D_E_L_E_T_ = ' ' "
	cQry += " AND UF3_FILIAL = '" + xFilial("UF3") + "' "
	cQry += " AND UF3_CODIGO = '" + cContrato + "' "
	cQry += " GROUP BY UF3_PROD,UF3_QUANT "

	If Select("QSERV") > 0
		QSERV->(DbCloseArea())
	endif

	TcQuery cQry New Alias "QSERV"

	UF3->(DbSetOrder(2)) //UF3_FILIAL+UF3_CODIGO+UF3_PRODUT

	While QSERV->(!Eof())

		If UF3->(MsSeek(xFilial("UF3") + cContrato + QSERV->PRODUTO)) .And. UF3->UF3_CTRSLD == 'S'
			RecLock("UF3",.F.)
			UF3->UF3_SALDO := QSERV->QTD_CONTRATO - QSERV->QTD_OS
			UF3->(MsUnlock())
		Endif

		QSERV->(DbSkip())
	EndDo

	QSERV->(DbCloseArea())

Return()

/***************************/
Static Function LegCarApto()
	/***************************/

	BrwLegenda("Status","Legenda Carencia",{{"BR_VERDE","Sem Carencia"},{"BR_LARANJA","Em Carencia"}})

Return

/***************************/
Static Function LegEstApto()
	/***************************/

	BrwLegenda("Status","Legenda Estoque",{;
		{"METAS_CIMA_16","Saldo em Estoque"},; //BR_AMARELO
	{"METAS_BAIXO_16","Sem saldo em Estoque"},; //BR_PRETO
	{"POSCLI","Serviço"},;
		{"DEPENDENTES","Terceiros ou Parceiros"};
		})

Return

/*/{Protheus.doc} USolicitaArmazem
@author Raphael Martins 
@since 04/06/2019
@version 1.0
@return ${return}, ${return_description}
@param oSay, object, Objeto da FWMsgRun
@param aEnvSlc, array, Dados da Solicitacao ao Armazem
@param cApontamento, characters, Codigo do Apontamento de Servico
@param cContrato, characters, Contrato do Apontamento
@param cContrato, characters, Contrato do Apontamento

@type function
/*/
User Function USolicitaArmazem(oSay,aEnvSlc,cApontamento,cContrato,cSexo,cNomeFal)

	Local aFilEnv 		:= {}
	Local aDadosCabec	:= {}
	Local aDadosProd	:= {}
	Local aProdutos		:= {}
	Local cNumSolicit	:= ""
	Local cFilSolicit	:= ""
	Local lRet			:= .T.
	Local nX			:= 0
	Local nY			:= 0
	Local nItemSolicit	:= 0
	Local cFilBkp		:= cFilAnt

	Private lMsErroAuto	:= .F.

	//Inclui registro de solicitacao ao armazem
	cFilSolicit	:= aEnvSlc[1,1]

	Begin Transaction

		For nY := 1 To Len(aEnvSlc)

			aDadosCabec := {}
			aDadosProd	:= {}

			nItemSolicit++

			//altero a filial logada para a filial que sera gerada a solicitacao
			cFilAnt := cFilSolicit

			////////////////////////////////////////////////////////
			///////////// ITENS DA SOLICITACAO AO ARMAZEM 	////////
			////////////////////////////////////////////////////////

			AAdd(aDadosProd,{"CP_ITEM" 		,StrZero(nItemSolicit,TamSX3("CP_ITEM")[1])			,Nil})

			AAdd(aDadosProd,{"CP_PRODUTO" 	,aEnvSlc[nY,3]										,Nil})

			AAdd(aDadosProd,{"CP_QUANT" 	,aEnvSlc[nY,4]										,Nil})

			AAdd(aDadosProd,{"CP_LOCAL" 	,aEnvSlc[nY,2]										,Nil})

			AAdd(aDadosProd,{"CP_CC" 		,SuperGetMv("MV_XCCAPTO",.F.,"1001001")				,Nil})

			AAdd(aDadosProd,{"CP_XCONTRA" 	,cContrato											,Nil})

			AAdd(aDadosProd,{"CP_XAPONT" 	,cApontamento										,Nil})

			AAdd(aDadosProd,{"CP_XTEMAP" 	,aEnvSlc[nY,5]										,Nil})

			AAdd(aDadosProd,{"CP_OBS" 		,"SOLICITACAO GERADA PELO APONTAMENTO DE SERVICO"	,Nil})

			AAdd(aDadosProd,{"CP_XSEXO" 	,cSexo												,Nil})

			AAdd(aDadosProd,{"CP_XNOMFAL" 	,cNomeFal											,Nil})


			AAdd(aProdutos,aDadosProd)

			//Proxima posicao do array
			nNextPos := nY + 1

			//verifico se alterou a filial ou chegou final do arquivo
			if nNextPos > Len(aEnvSlc) .Or. aEnvSlc[nNextPos,1] <> cFilSolicit

				cNumSolicit := GetSx8Num('SCP', 'CP_NUM')

				SCP->( DbSetOrder( 1 ) ) //CP_FILIAL+CP_NUM+CP_ITEM+DTOS(CP_EMISSAO)

				While SCP->( MsSeek( xFilial( 'SCP' ) + cNumSolicit ) )

					ConfirmSx8()

					cNumSolicit := GetSx8Num('SCP', 'CP_NUM')

				EndDo

				Aadd( aDadosCabec, { "CP_NUM" 		,cNumSolicit	, Nil })
				Aadd( aDadosCabec, { "CP_EMISSAO"	,dDataBase		, Nil })

				MsExecAuto( { | x, y, z | Mata105( x, y , z ) }, aDadosCabec, aProdutos , 3 )

				if lMsErroAuto

					MostraErro()
					DisarmTransaction()

					lRet := .F.

					Exit

				endif

				aProdutos	:= {}
				lMsErroAuto := .F.

				//altero a filial da solicitacao
				if nNextPos <= Len(aEnvSlc)
					cFilSolicit	:= aEnvSlc[nNextPos,1]
				endif

			endif

		Next nY

	End Transaction

	//retorno a filial logada
	cFilAnt := cFilBkp

	//valido se a solicitacao foi gerada com sucesso
	if lRet

		MsgInfo("Solicitação(ões) Gerada(s) com sucesso!","Atenção")

	endif

Return(lRet)


/*/{Protheus.doc} VerReqArmazem
//Funcao para Validar se o Apontamento
possui requisicao ao armazem 
@author Raphael Martins 
@since 04/06/2019
@version 1.0
@return ${return}, ${return_description}
@param cApontamento, characters, descricao
@type function
/*/
User Function VerReqArmazem(cApontamento)

	Local aArea		:= GetArea()
	Local aAreaUJ0	:= UJ0->(GetArea())
	Local aAreaSCP	:= SCP->(GetArea())
	Local lPossuiRA	:= .F.
	Local cQry 		:= ""

	cQry := " SELECT "
	cQry += " COUNT(*) REQUISICOES "
	cQry += " FROM "
	cQry += RetSQLName("UJ2") + " UJ2 "
	cQry += " INNER JOIN  "
	cQry += RetSQLName("SCP") + " SCP "
	cQry += " ON UJ2.D_E_L_E_T_ =  ' ' "
	cQry += " AND SCP.D_E_L_E_T_ = ' ' "
	cQry += " AND UJ2.UJ2_UNESTO = SCP.CP_FILIAL "
	cQry += " AND UJ2.UJ2_CODIGO = SCP.CP_XAPONT "
	cQry += " AND UJ2.UJ2_PRODUT = SCP.CP_PRODUTO "
	cQry += " WHERE  "
	cQry += " UJ2_FILIAL 		= '" + xFilial("UJ2")+ "' "
	cQry += " AND UJ2_CODIGO 	= '" + cApontamento + "' "

	if Select("QRYSCP") > 0
		QRYSCP->(DbCloseArea())
	endif

	TcQuery cQry NEW Alias "QRYSCP"

	if QRYSCP->REQUISICOES > 0
		lPossuiRA := .T.
	endif

	QRYSCP->(DbCloseArea())

	RestArea(aArea)
	RestArea(aAreaUJ0)
	RestArea(aAreaSCP)

Return(lPossuiRA)


/*/{Protheus.doc} VerPedComp
Funcao para Validar se o Apontamento possui pedido de compras

@author Pablo Nunes 
@since 20/10/2022
@version 1.0
@return ${return}, ${return_description}
@param cApontamento, characters, descricao
@type function
/*/
Static Function VerPedComp(cApontamento)

	Local aArea		:= GetArea()
	Local aAreaSC7	:= SC7->(GetArea())
	Local lPossuiPC	:= .F.
	Local cQry 		:= ""

	cQry := " SELECT "
	cQry += " COUNT(*) PEDIDOS "
	cQry += " FROM "
	cQry += RetSQLName("UJ2") + " UJ2 "
	cQry += " INNER JOIN  "
	cQry += RetSQLName("SC7") + " SC7 "
	cQry += " ON UJ2.D_E_L_E_T_ =  ' ' "
	cQry += " AND SC7.D_E_L_E_T_ = ' ' "
	cQry += " AND UJ2.UJ2_FILIAL = SC7.C7_FILIAL "
	cQry += " AND UJ2.UJ2_CODIGO = SC7.C7_PLANILH "
	cQry += " AND UJ2.UJ2_PRODUT = SC7.C7_PRODUTO "
	cQry += " WHERE  "
	cQry += " UJ2_FILIAL 	 = '" + xFilial("UJ2")+ "' "
	cQry += " AND UJ2_CODIGO = '" + cApontamento + "' "

	If Select("QRYSC7") > 0
		QRYSC7->(DbCloseArea())
	EndIf

	TcQuery cQry NEW Alias "QRYSC7"

	If QRYSC7->PEDIDOS > 0
		lPossuiPC := .T.
	EndIf

	QRYSC7->(DbCloseArea())

	RestArea(aAreaSC7)
	RestArea(aArea)

Return(lPossuiPC)

/*/{Protheus.doc} ValIntEmpresas
Funcao para validacao da integracao de empresas
@type function
@version 1.0 
@author g.sampaio
@since 05/08/2021
@param oModelUJ0, object, modelo de dados do cabecalho do apontamento(UJ0)
@param nLinha, numeric, numero da linha da grid
@param oModelUJ2, object, modelo de dados da grid de servicos executados do apontamento(UJ2)
@return logical, retorno sobre a validacao da integracao de empresas
/*/
Static Function ValIntEmpresas(nOperacao, oModelUJ0, nLinha, oModelUJ2)

	Local cTabPad				:= ""
	Local cFilBkp				:= ""
	Local lRetorno				:= .T.
	Local lValDados 			:= .T.
	Local lValidAptAuto			:= SuperGetMV("MV_XVAPTAU", .F., .T.)
	Local lPlanoPet				:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local lCEMPlanoPet			:= .F.
	Local nPosInt				:= 0
	Local oIntegraEmpresas    	:= Nil

	Default nOperacao	:= 0
	Default oModelUJ0 	:= Nil
	Default nLinha	  	:= 0
	Default oModelUJ2 	:= Nil

	// valido se os modelos de dados sao objeto
	if ValType( oModelUJ0 ) == "O"

		UF2->(DBSetOrder(1)) //UF2_FILIAL + UF2_CODIGO
		if UF2->(DbSeek(xFilial("UF2") + oModelUJ0:GetValue("UJ0_CONTRA") ))

			// inicio a classe de integracao de empresas
			oIntegraEmpresas := IntegraEmpresas():New( UF2->UF2_MSFIL, oModelUJ0:GetValue("UJ0_CONTRA"), oModelUJ0:GetValue("UJ0_CODIGO"))

			// inclusao ou alteracao
			if nOperacao == 3 .Or. nOperacao == 4

				// valido se o apontamento e integrado e tem vinculo de apontamento
				if oModelUJ0:GetValue("UJ0_TPAPON") == "2" .And. !Empty(oModelUJ2:GetValue("UJ2_APTINT"))
					Help( ,, 'Help - INTEGRACAOEMPRESAS',, 'Nao é possivel alterar apontamento de integracao!', 1, 0 )
					lRetorno := .F.
				endIf

				// verifico se o servico e de integracao
				oIntegraEmpresas:ServicoIntegracao(oModelUJ2:GetValue("UJ2_PRODUT"), oModelUJ0:GetValue("UJ0_PLANOC"))

				// validacao dos dados de obitos no apontamento de funeraria com o apontamento de cemiterio
				if lRetorno .And. oIntegraEmpresas:lServicoIntegracao .And. !Empty(oIntegraEmpresas:cTipoEndDes)

					cFilBkp := cFilAnt

					// verifico se o codigo do servico esta presente nos dados da integracao
					nPosInt := AScan(oIntegraEmpresas:aDadosInt, {|x| AllTrim(x[4]) == AllTrim(oModelUJ2:GetValue("UJ2_PRODUT")) })

					if nPosInt > 0

						// altero a filial de destino
						cFilAnt := oIntegraEmpresas:aDadosInt[nPosInt, 3]

						// pego a tabela de precos padrao da filial de destino
						cTabPad := SuperGetMv("MV_XTABSER", .F.,"001")

						// verifico se ja existe contrato para integracao
						if oIntegraEmpresas:ValidaIntegracao( cFilAnt )

							//Valida saldo do produto para o contrato
							if U37->(MsSeek( U_IntRetFilial("U37", oIntegraEmpresas:cFilialDes) + oIntegraEmpresas:cContratoDes + oIntegraEmpresas:aDadosInt[nPosInt, 6]))

								if U37->U37_SALDO == 0

									Help(,,'Help - INTGRACAOEMPRESAS',,"Servico " + oIntegraEmpresas:aDadosInt[nPosInt, 6] + " não possui saldo no contrato de cemiterio!",1,0)
									lRetorno := .F.

								endIf

							endIf

						endIf

						//valido se o servico possui tabela de preco
						if U_RetPrecoVenda(cTabPad, oIntegraEmpresas:aDadosInt[nPosInt, 6]) == 0

							Help(,,'Help - INTGRACAOEMPRESAS',,"Servico " + oIntegraEmpresas:aDadosInt[nPosInt, 6] + " não possui preco vigente para o módulo de cemiterio, favor verifique a tabela de preço '"+ cTabPad +"' !",1,0)
							lRetorno := .F.

						endIf

						// para plano pet habilitado
						if lPlanoPet

							// verifico se o plano pet está habilitado na filial de destino
							lCEMPlanoPet := SuperGetMV("MV_XPLNPET", .F., .F.)

							if !lCEMPlanoPet

								Help(,,'Help - INTGRACAOEMPRESAS',,"Gestão de Serviços PET(parametro 'MV_XPLNPET') não está habilitada na filial de Destino - " + cFilAnt + " - " + FWFilialName(cEmpAnt, cFilAnt) + ",";
									+ " procure o administrador do sistema!",1,0)
								lRetorno := .F.

							endIf

							// uso do apontamento
							if lRetorno .And. oModelUJ2:GetValue("UJ2_USOSRV") == "3" .And. oIntegraEmpresas:cUsoServico <> "3"

								Help(,,'Help - INTGRACAOEMPRESAS',,"Para o serviço '" + oIntegraEmpresas:aDadosInt[nPosInt, 6] + "' executado para PET, o serviço de habilitado na filial de destino também precisa ser PET!",1,0)
								lRetorno := .F.

							endIf

						endIf

						if !Empty(cFilBkp)
							cFilAnt := cFilBkp
						endIf

					endIf

					// verifico se valido os dados do obito
					lValDados := lValidAptAuto

					// para jazigo e nao ocupa gaveta eu nao valido os dados de enderecamento
					If lValDados .And. oIntegraEmpresas:cTipoEndDes == "J" .And. oIntegraEmpresas:cOcupaGavDes <> 'S'
						lValDados := .F.
					EndIf

					if lValDados .And. lPlanoPet

						// uso do apontamento
						if oModelUJ2:GetValue("UJ2_USOSRV") == "3" // pet
							lValDados := .F.
						endIf

					endIf

					//verIfico se servico selecionado exige definicao de endereco
					If lValDados

						// validacao para dados dos obitos e do falecido
						If Empty( oModelUJ0:GetValue("UJ0_DTFALE") ) // verifico se a data do obito foi preenchida

							lRetorno := .F.
							Help( ,, 'Help - INTEGRACAOEMPRESAS',, 'Para serviços executados no módulo de cemitério os "Dados do Obito" precisam ser preenchidos,';
								+ 'favor preencher o campo "'+ GetSx3Cache( "UJ0_DTFALE", "X3_TITULO") +' (UJ0_DTFALE)" e confirme novamente!', 1, 0 )

						ElseIf Empty( oModelUJ0:GetValue("UJ0_CAUSFA") ) // verifico se a causa foi preenchida

							lRetorno := .F.
							Help( ,, 'Help - INTEGRACAOEMPRESAS',, 'Para serviços executados no módulo de cemitério os "Dados do Obito" precisam ser preenchidos,';
								+ 'favor preencher o campo "'+ GetSx3Cache( "UJ0_CAUSFA", "X3_TITULO") +' (UJ0_CAUSFA)" e confirme novamente!', 1, 0 )

						ElseIf Empty( oModelUJ0:GetValue("UJ0_DTCERT") ) // verifico se a data do obito foi preenchida

							lRetorno := .F.
							Help( ,, 'Help - INTEGRACAOEMPRESAS',, 'Para serviços executados no módulo de cemitério os "Dados do Obito" precisam ser preenchidos,';
								+ 'favor preencher o campo "'+ GetSx3Cache( "UJ0_DTCERT", "X3_TITULO") +' (UJ0_DTCERT)" e confirme novamente!', 1, 0 )

						ElseIf Empty( oModelUJ0:GetValue("UJ0_LOCFAL") ) // verifico se o local de falecimento foi preenchida

							lRetorno := .F.
							Help( ,, 'Help - INTEGRACAOEMPRESAS',, 'Para serviços executados no módulo de cemitério os "Dados do Obito" precisam ser preenchidos,';
								+ 'favor preencher o campo "'+ GetSx3Cache( "UJ0_LOCFAL", "X3_TITULO") +' (UJ0_LOCFAL)" e confirme novamente!', 1, 0 )

						ElseIf Empty( oModelUJ0:GetValue("UJ0_NOMEFA") ) // verifico se o nome foi preenchida

							lRetorno := .F.
							Help( ,, 'Help - INTEGRACAOEMPRESAS',, 'Para serviços executados no módulo de cemitério os "Dados do Obito" precisam ser preenchidos,';
								+ 'favor preencher o campo "'+ GetSx3Cache( "UJ0_NOMEFA", "X3_TITULO") +' (UJ0_NOMEFA)" e confirme novamente!', 1, 0 )

						ElseIf Empty( oModelUJ0:GetValue("UJ0_DTNASC") ) // verifico se a data de neascimento foi preenchida

							lRetorno := .F.
							Help( ,, 'Help - INTEGRACAOEMPRESAS',, 'Para serviços executados no módulo de cemitério os "Dados do Obito" precisam ser preenchidos,';
								+ 'favor preencher o campo "'+ GetSx3Cache( "UJ0_DTNASC", "X3_TITULO") +' (UJ0_DTNASC)" e confirme novamente!', 1, 0 )

						ElseIf Empty( oModelUJ0:GetValue("UJ0_NOMAE") ) // verifico se o nome da mae foi preenchida

							lRetorno := .F.
							Help( ,, 'Help - INTEGRACAOEMPRESAS',, 'Para serviços executados no módulo de cemitério os "Dados do Obito" precisam ser preenchidos,';
								+ 'favor preencher o campo "'+ GetSx3Cache( "UJ0_NOMAE", "X3_TITULO") +' (UJ0_NOMAE)" e confirme novamente!', 1, 0 )

						EndIf

					EndIf

				endif

			elseIf nOperacao == 5 // exclusao

				// verifico o status do apontamento
				if !oIntegraEmpresas:StatusAptIntegracao()
					lRetorno := .F.
					Help( ,, 'Help - INTEGRACAOEMPRESAS',, 'Nao e possivel excluir o Apontamento de Servico, pois o apontamento do módulo de cemiterio está finalizado com o vinculo de integracao de empresas!', 1, 0 )
				endIf

				// nao permito a exclusao de apontament
				if lRetorno .And. oIntegraEmpresas:EnderecoIntegracao()
					lRetorno := .F.
					Help( ,, 'Help - INTEGRACAOEMPRESAS',, 'Nao e possivel excluir o Apontamento de Servico, pois existe endereçamento no módulo de cemiterio com o vinculo de integracao de empresas!', 1, 0 )
				endIf

			endIf

			FreeObj(oIntegraEmpresas)
			oIntegraEmpresas := Nil

		else
			lRetorno := .F.
			Help( ,, 'Help - INTEGRACAOEMPRESAS',, 'Contrato do apontamento nao encontrado!', 1, 0 )
		endif

	endIf

Return(lRetorno)

/*/{Protheus.doc} ExcIntegracaoInt
Funcao para excluir os dados da integracao
de empresas
@type function
@version 1.0 
@author g.sampaio
@since 09/08/2021
@param lEnd, logical, parametro da classe MsNewProcess
@param oProcIntEmp, object, objeto da classe MsNewProccess
@param cFilialOri, character, filial de origem
@param cCodContrato, character, contrato de origem
@param cCodApontamento, character, apontamento de origem
/*/
Static Function ExcIntegracaoInt( lEnd, oProcIntEmp, cFilialOri, cCodContrato, cCodApontamento )

	Local cQuery			:= ""
	Local cAliasTab			:= ""
	Local lIntEmp			:= SuperGetMV("MV_XINTEMP", .F., .F.) // habilito o uso da integracao de empresas
	Local oIntegraEmpresas	:= Nil

	Default lEnd			:= .F.
	Default oProcIntEmp		:= Nil
	Default cFilialOri		:= ""
	Default cCodContrato	:= ""
	Default cCodApontamento	:= ""

	// se integracao de empresas habilitada
	if lIntEmp

		// inicio a classe de integracao de empresas
		oIntegraEmpresas := IntegraEmpresas():New( cFilialOri, cCodContrato, cCodApontamento )

		// sinalizo que esclusao
		oIntegraEmpresas:lExclusaoApt := .T.

		// se existe dados de integracao e contratos ativos para o contrato de origem
		if oIntegraEmpresas:ValidaIntegracao()

			cQuery := " SELECT "
			cQuery += " COUNT(*) CONT_APT"
			cQuery += " FROM " + RetSQLName("UJV") + " UJV WHERE UJV.D_E_L_E_T_ = ' ' "
			cQuery += " AND UJV.UJV_FILIAL = '" + oIntegraEmpresas:cFilialDes + "'"
			cQuery += " AND UJV.UJV_CONTRA = '" + oIntegraEmpresas:cContratoDes + "'"
			cQuery += " AND UJV.UJV_FILINT = '" + oIntegraEmpresas:cFilialOri + "'"
			cQuery += " AND UJV.UJV_CTRINT = '" + oIntegraEmpresas:cContratoOri + "'"
			cQuery += " AND UJV.UJV_TPAPON = '2' " // apontamento de integracao

			cQuery := ChangeQuery(cQuery)

			MPSysOpenQuery( cQuery, cAliasTab)

			if (cAliasTab)->(!Eof())

				if (cAliasTab)->CONT_APT > 1

					// faco a exclusao do apontamento integracao
					oIntegraEmpresas:ExcluiAptIntegracao()

				else

					// faco a exclusao da integracao
					if oIntegraEmpresas:ExcluiIntegracao()

						UF2->(RecLock("UF2",.F.))
						UF2->UF2_TPCONT := "1"
						UF2->(MsUnlock())

					endIf

				endIf

			endIf

		endIf

	endIf

Return(Nil)
