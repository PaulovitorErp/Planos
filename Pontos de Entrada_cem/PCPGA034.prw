#Include "totvs.CH"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'

/*/{Protheus.doc} PCPGA026
Pontos de Entrada
Cadastro de Transferencia de Enderecamento
@author Raphael Martins 
@since 17/05/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function PCPGA034()

	Local aParam 		:= PARAMIXB
	Local oObj			:= aParam[1]
	Local cIdPonto		:= aParam[2]
	Local oModelU38		:= oObj:GetModel("U38MASTER")
	Local lRetorno 		:= .T.
	Local lUsaLacre     := SuperGetMv("MV_XUSALAC",.F.,.F.) // valido se deixo obrigatorio o lacre

	// na abertura da tela
	if cIdPonto == 'MODELVLDACTIVE'

		// para alteracao da transferencia
		If oObj:GetOperation() == 4

			//Caso tenha gerado pedido de venda, nao permito alteracao dos itens da transferencia
			If !Empty(U38->U38_PEDIDO) .And. U38->U38_STATUS == "2"

				lRetorno := .F.
				Help( ,, 'Help',, 'Transferência de Endereço já foi faturada, não é possível a alteração! Pedido de Vendas: ' + U38->U38_PEDIDO , 1, 0 )

			EndIf

		endIf

	ElseIf cIdPonto == "MODELCOMMITTTS"// confirmação do cadastro

		if oObj:GetOperation() == 3 //Confirmação da inclusao

			// confirma transferencia
			FWMsgRun(,{|oSay| lRetorno := U_RCPGA34C(oModelU38)},'Aguarde...','Confirmando a Transferencia de Endereçamento!')

		elseIf oObj:GetOperation() == 4 //Confirmação da alteracao

			if !Empty(U38->U38_CLIPV) .And. !Empty(U38->U38_LOJAPV)

				// pergunto ao usuario deseja gerar o pedido de vendas
				if Empty(U38->U38_PEDIDO) .And. MsgYesNo("Deseja gerar o pedido de venda da transferencia realizada?")

					// inclusao do pedido de vendas da transferencia de enderecos
					cPedido := U_PCPGA34A(U38->U38_CTRORI,U38->U38_SERVDE,U38->U38_CODIGO)

					if !Empty(cPedido)

						MsgInfo("Pedido de Venda: " + cPedido + " gerado com sucesso!" )

					endif

				endif

			endIf

		endIf

	ElseIf cIdPonto == 'MODELPOS'

		if oObj:GetOperation() == 3 //Confirmação da inclusao

			FWMsgRun(,{|oSay| lRetorno := ValidTransf(oModelU38)},'Aguarde...','Validando Dados da Transferência')

		endif

		if lRetorno .And. (oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4) //Confirmação da inclusao ou alteracao

			if Empty(oModelU38:GetValue('U38_DATA'))

				lRetorno := .F.
				Help( ,, 'Help',, 'Campo Data(U38_DATA) não pode estar vazio para inclusao da transferencia!', 1, 0 )

			endIf

			// verifico se e o uso do lacre é necessario
			if lUsaLacre .And. lRetorno

				// verifico se o campo lacre destino existe
				if U38->(FieldPos("U38_LACDST")) > 0

					// valido o preenchido do campo lacre de destino
					if !Empty(oModelU38:GetValue('U38_OSDEST')) .And. Empty(oModelU38:GetValue('U38_LACDST'))

						lRetorno := .F.
						Help( ,, 'Help',, 'Quando o endereço de destino for um Ossário, o Campo "Lac.Oss.Dest"(Lacre do Oassario de Destino) não pode estar vazio no apontamento de serviços!', 1, 0 )

					endIf

				endIf

			endIf

		elseif lRetorno .And. oObj:GetOperation() == 5

			lRetorno := U_RCPGA34E(U38->U38_CODIGO)

			If lRetorno
				// faco o estorno da transferencia de enderecos
				U_RCPGA34D(U38->U38_CODIGO)
			EndIf

		endIf

	endif

Return(lRetorno)

/*/{Protheus.doc} ValidTransf
Funcao para validar se os dados 
da transferencia foram preenchidos com sucesso
@type function
@version 1.0
@author Raphael Martins
@since 02/03/2020
@param oModelU38, object, Ojeto model da tela
@return logical, Continua a transferencia
/*/
Static Function ValidTransf(oModelU38)

	Local aArea			:= GetArea()
	Local aAreaU38		:= U38->(GetArea())
	Local aAreaSB1		:= SB1->(GetArea())
	Local cTpTransf		:= oModelU38:GetValue('U38_TPTRAN')
	Local cServico		:= oModelU38:GetValue('U38_SERVDE')
	Local lRet 			:= .T.

	//caso seja transferencia interna verifique se o endereco de destino foi preenchido
	if cTpTransf == "I"// transferencia interna

		SB1->(DBSetOrder(1)) //B1_FILIAL + B1_COD

		if SB1->(MsSeek(xFilial("SB1") + cServico ))

			//caso seja endereco de jazigo, valido se os enderecos estao selecionados
			if SB1->B1_XREQSER == "J"

				if Empty(oModelU38:GetValue('U38_GVDEST'))

					lRet := .F.
					Help( ,, 'Help',, 'Endereco da Gaveta não selecionado!', 1, 0 )

				endif

				//caso seja endereco de crematorio, valido se os enderecos estao selecionados
			elseif SB1->B1_XREQSER == "C"

				if Empty(oModelU38:GetValue('U38_NCDEST'))

					lRet := .F.
					Help( ,, 'Help',, 'Endereco da Crematorio não selecionado!', 1, 0 )

				endif

				//caso seja endereco de ossario, valido se os enderecos estao selecionados
			elseif SB1->B1_XREQSER == "O"

				if Empty(oModelU38:GetValue('U38_NODEST'))

					lRet := .F.
					Help( ,, 'Help',, 'Endereco da Ossario não selecionado!', 1, 0 )

				endif

			else
				lRet := .F.
				Help( ,, 'Help',, 'Serviço não possui tipo de endereco definido, favor verifique o cadastro do produto!', 1, 0 )
			endif

		else

			lRet := .F.
			Help( ,, 'Help',, 'Serviço não selecionado ou inválido, favor verifique!', 1, 0 )

		endif

	elseIf cTpTransf == "E" // transferencia externa

		SB1->(DBSetOrder(1)) //B1_FILIAL + B1_COD

		if SB1->(MsSeek(xFilial("SB1") + cServico ))

			// pverifico se o campo tipo de endereco esta preenchido
			if !Empty(SB1->B1_XREQSER)

				lRet := .F.
				Help( ,, 'Help',, 'Para transferência externa o Cadastro do Serviço não pode ter o tipo de endereço preenchido, favor verifique o cadastro do produto ou escolha um outro serviço disponível no plano!', 1, 0 )

			endIf

		endIf

	endif

	RestArea(aAreaU38)
	RestArea(aAreaSB1)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} PCPGA34A
Funcao para gerar pedido de venda 
das transferencias realizadas
@author Raphael Martins 
@since 21/05/2018
@version P12
@return lRet - Continua a Operacao
/*/
User Function PCPGA34A(cContrato,cServico,cCodTransf)

	Local aCab 			:= {}
	Local aItens 		:= {}
	Local aArea			:= GetArea()
	Local aAreaU00		:= U00->(GetArea())
	Local aAreaSB1		:= SB1->(GetArea())
	Local aAreaU38		:= U38->(GetArea())
	Local aAreaUJV		:= UJV->(GetArea())
	Local cCodTab		:= SuperGetMv("MV_XTABPAD",.F.,"001")
	Local cCondPagto	:= SuperGetMv("MV_XCONDCE",.F.,"001")
	Local cOperacao		:= SuperGetMv("MV_XOPERCE",.F.,"07") //Prestação de Serviços
	Local cPedido		:= ""
	Local lContinua		:= .T.
	Local nPrecoServico	:= 0

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	Default cContrato	:= ""
	Default cServico	:= ""
	Default cCodTransf	:= ""

	U00->(DbSetOrder(1)) //U00_FILIAL + U00_CODIGO
	SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD
	U38->(DbSetOrder(1))

	if U38->( MsSeek( xFilial("U38")+cCodTransf ) )

		// verifico se os campos de cliente e loja do pedido de venda existem
		if U38->(FieldPos("U38_CLIPV")) > 0 .And. U38->(FieldPos("U38_LOJAPV")) > 0

			// verifico se o campo cliente pv esta preenchido
			if Empty(U38->U38_CLIPV)

				lContinua := .F.

				if FWIsInCallStack("U_RCPGA034") .Or. FWIsInCallStack("U_RCPGA001")
					MsgAlert('Para gerar o pedido de vendas o campo "Cliente PV" deve estar preenchido!')
				else
					Help( ,, 'Help',, 'Para gerar o pedido de vendas o campo "Cliente PV" deve estar preenchido!', 1, 0 )
				endIf

			elseIf Empty(U38->U38_LOJAPV)// verifico se o campo loja pv esta preenchido

				lContinua := .F.

				if FWIsInCallStack("U_RCPGA034") .Or. FWIsInCallStack("U_RCPGA001")
					MsgAlert('Para gerar o pedido de vendas o campo "Loja PV" deve estar preenchido!')
				else
					Help( ,, 'Help',, 'Para gerar o pedido de vendas o campo "Loja PV" deve estar preenchido!', 1, 0 )
				endIf

			endIf

		endIf

		//realiza a inclusao do pedido se tiver preco vigente
		if lContinua .And. (nPrecoServico := U_RetPrecoVenda(cCodTab,cServico))  > 0

			if U00->(MsSeek(xFilial("U00")+cContrato))

				if SB1->(MsSeek(xFilial("SB1")+cServico))

					// verifico se no produto tem a natureza preenchida
					if Empty(SB1->B1_XNATURE)

						lContinua := .F.

						if FWIsInCallStack("U_RCPGA034") .Or. FWIsInCallStack("U_RCPGA001")
							MsgAlert('Para gerar o pedido de vendas o produto deve ter o campo "Natureza" no cadastro do Produto preenchido, não é possível gerar o pedido de vendas!')
						else
							Help( ,, 'Help',, 'Para gerar o pedido de vendas o produto deve ter o campo "Natureza" no cadastro do Produto preenchido, não é possível gerar o pedido de vendas!', 1, 0 )
						endIf

					endIf

					// vejo se esta tudo certo
					if lContinua

						DbSelectArea("SC5")

						/////////////////////////////////////////////////////
						////////////// CABECALHO DO PEDIDO     //////////////
						/////////////////////////////////////////////////////

						AAdd(aCab, {"C5_TIPO" 		,"N" 				, Nil})

						// verifico se os campos cliente pv e loja pv existem
						if U38->(FieldPos("U38_CLIPV")) > 0 .And. U38->(FieldPos("U38_LOJAPV")) > 0
							AAdd(aCab, {"C5_CLIENTE" 	, U38->U38_CLIPV 	, Nil})
							AAdd(aCab, {"C5_LOJACLI" 	, U38->U38_LOJAPV 	, Nil})

						else
							AAdd(aCab, {"C5_CLIENTE" 	, U00->U00_CLIENT 	, Nil})
							AAdd(aCab, {"C5_LOJACLI" 	, U00->U00_LOJA	 	, Nil})

						endIf

						AAdd(aCab, {"C5_TABELA"		, cCodTab				, Nil })
						AAdd(aCab, {"C5_CONDPAG" 	, cCondPagto 			, Nil })
						AAdd(aCab, {"C5_EMISSAO" 	, dDataBase 			, Nil })
						AAdd(aCab, {"C5_MOEDA" 		, 1 					, Nil })
						AAdd(aCab, {"C5_NATUREZ" 	, SB1->B1_XNATURE		, Nil })

						// campo de mensagem para a nota
						if U38->(FieldPos("U38_MENNFS")) > 0
							AAdd(aCab, {"C5_XMENNFS"	, U38->U38_MENNFS	,Nil})
						EndIf

						// verifico se o campo apontamento existe
						if U38->(FieldPos("U38_APONTA")) > 0
							AAdd(aCab, {"C5_XAPONTC"	,U38->U38_APONTA	,Nil})
						endIf

						AAdd(aCab, {"C5_XCONTRA"	,U00->U00_CODIGO	,Nil})

						/////////////////////////////////////////////////////
						//////////////     ITENS DO PEDIDO     //////////////
						/////////////////////////////////////////////////////

						AAdd(aItens,{"C6_ITEM" 		,StrZero(1,TamSX3("C6_ITEM")[1])	,Nil})
						AAdd(aItens,{"C6_PRODUTO" 	,cServico		 					,Nil})
						AAdd(aItens,{"C6_QTDVEN" 	,1									,Nil})
						AAdd(aItens,{"C6_PRCVEN" 	,nPrecoServico						,Nil})
						AAdd(aItens,{"C6_OPER" 		,cOperacao							,Nil})

						MSExecAuto({|X,Y,Z|Mata410(X,Y,Z)},aCab,{aItens},3)

						If lMsErroAuto
							MostraErro()
						Else
							cPedido := SC5->C5_NUM

							if U38->(RecLock("U38",.F.))
								U38->U38_PEDIDO := cPedido
								U38->(MsUnlock())
							else
								U38->(DisarmTransaction())
							endIf

							// verifico se o campo do apontamento existe na tabela de transferencia de endereco
							if U38->(FieldPos("U38_APONTA")) > 0

								// posiciono no apontamento de servicos da transferencia
								UJV->(DbSetOrder(1))
								if UJV->(MsSeek( xFilial("UJV")+U38->U38_APONTA ))

									// gravo os dados do pedido e finalizo o apontamento
									if UJV->(RecLock("UJV",.F.))

										// verifico se os campos de cliente e loja do pedido de venda existem
										if U38->(FieldPos("U38_CLIPV")) > 0 .And. U38->(FieldPos("U38_LOJAPV")) > 0
											UJV->UJV_CLIENT	:= U38->U38_CLIPV
											UJV->UJV_LOJA	:= U38->U38_LOJAPV
										endIf

										UJV->UJV_PEDIDO	:= cPedido
										UJV->UJV_STATUS := "F"

									else
										UJV->(DisarmTransaction())
									endIf

								endIf

							endIf

						EndIf

					endIf

				endif

			else
				Help( ,, 'Help',, 'Contrato: '+ cContrato + ' não encontrado na filial: '+Alltrim(cFilAnt)+' , a transferencia não será realizada! ', 1, 0 )
			endif

		endif

	endIf

	RestArea(aAreaU38)
	RestArea(aAreaUJV)
	RestArea(aAreaU00)
	RestArea(aAreaSB1)
	RestArea(aArea)

Return(cPedido)
