#include "protheus.ch"
#include "topconn.ch"
#include "fwmvcdef.ch"

#DEFINE CRLF CHR(10)+CHR(13)

/*/{Protheus.doc} PCPGA039
Pontos de Entrada do Apontamentos de Serviço Cemiterio
@author g.sampaio.
@since 24/01/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function PCPGA039()

	Local aArea         := GetArea()
	Local aAreaUJV      := UJV->(GetArea())
	Local aAreaU00      := U00->(GetArea())
	Local aAreaSB1      := SB1->(GetArea())
	Local aAreaU37      := U37->(GetArea())
	Local aParam 		:= PARAMIXB
	Local aFieldsEnd    := {}
	Local oObj			:= aParam[1]
	Local cIdPonto		:= aParam[2]
	Local cServico      := ""
	Local cParamCmpAlt	:= SuperGetMv("MV_XAPTALT",,"UJV_NOME|UJV_DTSEPU|UJV_HORASE") // campos que podem ser alterados
	Local lTransfEnd	:= FWIsInCallStack("U_PCPGA034") .Or. FWIsInCallStack("U_RCPGA34C")// quando estiver executando pela transferencia de endereco
	Local lContinua     := .T.
	Local lValDados		:= .T.
	Local lUsaLacre     := SuperGetMv("MV_XUSALAC",.F.,.F.) 	// valido se deixo obrigatorio o lacre
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) 	// habilito o uso do plano pet
	Local lValidAptAuto	:= SuperGetMV("MV_XVAPTAU", .F., .T.)
	Local lRotAuto		:= FWIsInCallStack("U_RCPGE056")// quando estiver executando a rotina automatica
	Local nPosAlt       := 0
	Local nI            := 0
	Local nAnosExu      := SuperGetMv("MV_XANOSEX",.F.,5)
	Local oModelUJV	    := oObj:GetModel("UJVMASTER")
	Local oModelUJX		:= oObj:GetModel("UJXDETAIL")
	Local oStructUJV	:= Nil
	Local xRet 			:= .T.

	//Ativacao do Model
	If cIdPonto == 'MODELVLDACTIVE'

		If lContinua .And. oObj:GetOperation() == 4 //Ativação do model e Alteração

			// verifico se o campo de origem do apontamento existe
			if UJV->(FieldPos("UJV_ORIGEM")) > 0

				// caso a origem do apontamento for da transferencia de enderecos
				if UJV->UJV_TPAPON <> "2" .And. !Empty(UJV->UJV_ORIGEM) .And. AllTrim(UJV->UJV_ORIGEM) <> "RCPGA039"
					lContinua := .F.
					Help( ,, 'Help',, 'O Apontamento de Serviços gerado por outra rotina, operação não permitida!', 1, 0 )
				endIf

			endIf

			if lContinua

				//Caso tenha gerado pedido de venda, nao permito alteracao dos itens do apontamento
				If !Empty(UJV->UJV_PEDIDO)

					oModelUJX:SetNoInsertLine(.T.)
					oModelUJX:SetNoUpdateLine(.T.)
					oModelUJX:SetNoDeleteLine(.T.)

				Else

					oModelUJX:SetNoInsertLine(.F.)
					oModelUJX:SetNoUpdateLine(.F.)
					oModelUJX:SetNoDeleteLine(.F.)

				EndIf

				// verifico se o produto está preenchido
				if !Empty(UJV->UJV_SERVIC)

					SB1->(DbSetOrder(1))
					U37->(DbSetOrder(2)) //U37_FILIAL+U37_CODIGO+U37_SERVIC

					// posiciono no cadastro do pedido
					if SB1->(MsSeek(xFilial("SB1")+UJV->UJV_SERVIC))

						// pego a estrutura do modelo de dados da UJV
						oStructUJV := oModelUJV:GetStruct()

						// Valido se servico é necessario enderecar
						if !Empty(SB1->B1_XREQSER)
							lValDados := .T.
						endIf

						// verifico se o plano pet esta habilitado
						if lValDados .And. lPlanoPet

							if SB1->B1_XUSOSRV == "3" // pet
								lValDados := .F.
							endIf

						endIf

						/////////////////////////////////////////////////////////////
						//////// DESABILITO TODOS OS CAMPOS DE ENDERECO  ////////////
						/////////////////////////////////////////////////////////////

						if lValDados

							//Deixa campos obrigatorios
							oStructUJV:SetProperty( 'UJV_DTOBT' , MODEL_FIELD_OBRIGAT, .T.)
							oStructUJV:SetProperty( 'UJV_DTCERT', MODEL_FIELD_OBRIGAT, .T.)
							oStructUJV:SetProperty( 'UJV_CAUSA' , MODEL_FIELD_OBRIGAT, .T.)
							oStructUJV:SetProperty( 'UJV_LOCFAL', MODEL_FIELD_OBRIGAT, .T.)
							oStructUJV:SetProperty( 'UJV_NOME'  , MODEL_FIELD_OBRIGAT, .T.)
							oStructUJV:SetProperty( 'UJV_DTNASC', MODEL_FIELD_OBRIGAT, .T.)
							oStructUJV:SetProperty( 'UJV_NOMAE' , MODEL_FIELD_OBRIGAT, .T.)

							// verifico o tipo de endereco para definir se o campo pode ser editado ou nao
							If AllTrim(SB1->B1_XREQSER) == "C" // crematorio
								oStructUJV:SetProperty( 'UJV_CREMAT' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".T.") ) // habilito a edicao do campo crematorio
								oStructUJV:SetProperty( 'UJV_QUADRA' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo quadra
								oStructUJV:SetProperty( 'UJV_OSSARI' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo ossruario

							ElseIf AllTrim(SB1->B1_XREQSER) == "J" // jazigo
								oStructUJV:SetProperty( 'UJV_CREMAT' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo crematorio
								oStructUJV:SetProperty( 'UJV_QUADRA' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".T.") ) // habilito a edicao do campo quadra
								oStructUJV:SetProperty( 'UJV_OSSARI' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo ossruario

							ElseIf AllTrim(SB1->B1_XREQSER) == "O" // ossuario
								oStructUJV:SetProperty( 'UJV_CREMAT' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo crematorio
								oStructUJV:SetProperty( 'UJV_QUADRA' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo quadra
								oStructUJV:SetProperty( 'UJV_OSSARI' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".T.") ) // habilito a edicao do campo ossruario

							EndIf

							// desabilito os campos de enderecos - jazigo
							oStructUJV:SetProperty( 'UJV_MODULO' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo crematorio
							oStructUJV:SetProperty( 'UJV_JAZIGO' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo crematorio
							oStructUJV:SetProperty( 'UJV_GAVETA' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo quadra

							// desabilito os campos de enderecos - crematorio
							oStructUJV:SetProperty( 'UJV_NICHOC' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo nicho crematorio

							// desabilito os campos de enderecos - ossario
							oStructUJV:SetProperty( 'UJV_NICHOO' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo nicho ossuario

						else

							//Retira obrigatoriedade dos campos
							oStructUJV:SetProperty( 'UJV_DTOBT' , MODEL_FIELD_OBRIGAT, .F.)
							oStructUJV:SetProperty( 'UJV_DTCERT', MODEL_FIELD_OBRIGAT, .F.)
							oStructUJV:SetProperty( 'UJV_CAUSA' , MODEL_FIELD_OBRIGAT, .F.)
							oStructUJV:SetProperty( 'UJV_LOCFAL', MODEL_FIELD_OBRIGAT, .F.)
							oStructUJV:SetProperty( 'UJV_NOME'  , MODEL_FIELD_OBRIGAT, .F.)
							oStructUJV:SetProperty( 'UJV_DTNASC', MODEL_FIELD_OBRIGAT, .F.)
							oStructUJV:SetProperty( 'UJV_NOMAE' , MODEL_FIELD_OBRIGAT, .F.)

							if lPlanoPet .And. SB1->B1_XUSOSRV == "3" // pet

								// verifico o tipo de endereco para definir se o campo pode ser editado ou nao
								If AllTrim(SB1->B1_XREQSER) == "C" // crematorio
									oStructUJV:SetProperty( 'UJV_CREMAT' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".T.") ) // habilito a edicao do campo crematorio
									oStructUJV:SetProperty( 'UJV_QUADRA' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo quadra
									oStructUJV:SetProperty( 'UJV_OSSARI' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo ossruario

								ElseIf AllTrim(SB1->B1_XREQSER) == "J" // jazigo
									oStructUJV:SetProperty( 'UJV_CREMAT' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo crematorio
									oStructUJV:SetProperty( 'UJV_QUADRA' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".T.") ) // habilito a edicao do campo quadra
									oStructUJV:SetProperty( 'UJV_OSSARI' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo ossruario

								ElseIf AllTrim(SB1->B1_XREQSER) == "O" // ossuario
									oStructUJV:SetProperty( 'UJV_CREMAT' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo crematorio
									oStructUJV:SetProperty( 'UJV_QUADRA' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo quadra
									oStructUJV:SetProperty( 'UJV_OSSARI' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".T.") ) // habilito a edicao do campo ossruario

								EndIf

							else

								// desabilito a edicao dos campos de endereco
								oStructUJV:SetProperty( 'UJV_CREMAT' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo crematorio
								oStructUJV:SetProperty( 'UJV_QUADRA' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo quadra
								oStructUJV:SetProperty( 'UJV_OSSARI' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo ossruario

							endIf

							// desabilito os campos de enderecos - jazigo
							oStructUJV:SetProperty( 'UJV_MODULO' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo crematorio
							oStructUJV:SetProperty( 'UJV_JAZIGO' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo crematorio
							oStructUJV:SetProperty( 'UJV_GAVETA' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo quadra

							// desabilito os campos de enderecos - crematorio
							oStructUJV:SetProperty( 'UJV_NICHOC' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo nicho crematorio

							// desabilito os campos de enderecos - ossario
							oStructUJV:SetProperty( 'UJV_NICHOO' , MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") ) // desabilito a edicao do campo nicho ossuario

						endif

					endif

				endif

			endIf

		ElseIf lContinua .And. oObj:GetOperation() == 5 //Ativação do model e Alteração

			// verifico se o campo de origem do apontamento existe
			if UJV->(FieldPos("UJV_ORIGEM")) > 0

				// caso a origem do apontamento for da transferencia de enderecos
				if !FWIsInCallStack("ExcluiAptIntegracao") .And. (!Empty(UJV->UJV_ORIGEM) .And. AllTrim(UJV->UJV_ORIGEM) <> "RCPGA039")
					lContinua := .F.
					Help( ,, 'Help',, 'O Apontamento de Serviços gerado por outra rotina, operação não permitida!', 1, 0 )
				endIf

			endIf

			// nao permito a exclusao caso tenha pedido gerado
			If lContinua .And. !Empty(UJV->UJV_PEDIDO)

				lContinua := .F.
				Help( ,, 'Help',, 'Apontamento de Serviços com pedido de venda gerado!', 1, 0 )

			EndIf

			// nao permito a exclusao endereco efetivado
			If lContinua .And. UJV->UJV_STENDE == "E"

				lContinua := .F.
				Help( ,, 'Help',, 'Apontamento de Serviços com endereçamento efetivado!', 1, 0 )

			EndIf

		endIf

		// retorno da rotina
		xRet := lContinua

	ElseIf cIdPonto == 'MODELPOS'

		If oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4

			//caso o servico principal, esteja preenchido, valido se possui endereco
			cServico := oModelUJV:GetValue("UJV_SERVIC")

			SB1->(DBSetOrder(1)) //B1_FILIAL + B1_COD

			If SB1->(MsSeek(xFilial("SB1") + cServico))

				//verIfico se servico selecionado exige definicao de endereco
				If !Empty(SB1->B1_XREQSER)

					//ENDERECO DE JAZIGO HABILITO O CAMPO UJV_QUADRA
					If SB1->B1_XREQSER == "J" .And. ( Empty(oModelUJV:GetValue("UJV_QUADRA")) .Or. Empty(oModelUJV:GetValue("UJV_MODULO"));
							.Or. Empty(oModelUJV:GetValue("UJV_JAZIGO")) .Or. Empty(oModelUJV:GetValue("UJV_GAVETA")) )

						xRet := .F.
						Help( ,, 'Help',, 'Endereço de Jazigo não selecionado', 1, 0 )

						//ENDERECO DE CREMACAO HABILITO O CAMPO UJV_CREMAT
					ElseIf SB1->B1_XREQSER == "C" .And. ( Empty(oModelUJV:GetValue("UJV_CREMAT")) .Or. Empty(oModelUJV:GetValue("UJV_NICHOC")) )

						xRet := .F.
						Help( ,, 'Help',, 'Endereço de Crematório não selecionado', 1, 0 )

						//ENDERECO DE OSSARIO HABILITO O CAMPO UJV_OSSARI
					ElseIf SB1->B1_XREQSER == "O" .And. ( Empty(oModelUJV:GetValue("UJV_OSSARI")) .Or. Empty(oModelUJV:GetValue("UJV_NICHOO")) )

						xRet := .F.
						Help( ,, 'Help',, 'Endereço de Ossario não selecionado', 1, 0 )

					EndIf

				EndIf

			EndIf

		EndIf

	ElseIf cIdPonto == "MODELCOMMITNTTS"

		// operacao de inclusao ou alteracao
		If oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4

			// vejo se um dos campos de endereco estao preenchido
			If (FWIsInCallStack("U_RCPGA039") .Or. FWIsInCallStack("U_RCPGA001")) .And. !lTransfEnd .And. (!Empty(UJV->UJV_QUADRA) .Or. !Empty(UJV->UJV_CREMAT) .Or. !Empty(UJV->UJV_OSSARI))

				//Realizo a efetivacao do Endereco na U04
				If UJV->UJV_STENDE <> 'E' .And. MsgYesNo("Deseja efetivar o endereço selecionado neste Apontamento?")

					//realiza a efetivacao do endereco na tabela U04
					FWMsgRun(,{|oSay| xRet := U_UConfEndereco(UJV->UJV_CODIGO,UJV->UJV_CONTRA) },'Aguarde','Efetivando o endereçamento selecionado...')

				EndIf

			EndIf

		ElseIf oObj:GetOperation() == 5 // operacao de exclusao

			// verifico se o apontamento é vinculado ao contrato
			If !Empty( UJV->UJV_CONTRA )

				// posiciono no itens do contrato
				U37->( DbSetOrder(2) )
				if U37->(MsSeek(xFilial("U37")+ UJV->UJV_CONTRA + UJV->UJV_SERVIC ))

					//caso o servico controle saldo, debito o saldo do contrato
					if U37->U37_CTRSLD == "S"

						// travo o registro da U37
						If U37->( RecLock("U37",.F.) )
							U37->U37_SALDO += 1
						Else
							U37->(MsUnlock())
						EndIf

					endif

				endIf

			EndIf

		EndIf

		// se for inclusao
		If oObj:GetOperation() == 3

			// valida sala velorio
			ValidaSalaVelorio(UJV->UJV_CODIGO)

		endIf

		// caso for alteracao e o endereco estiver efetivado
		If oObj:GetOperation() == 4 .And. UJV->UJV_STENDE == 'E'

			// determino os campos do apontamento e suas referencia do endereco que precisa alterar o endereco
			aAdd( aFieldsEnd, {	"UJV_DTSEPU"    , "U04_DTUTIL"  })
			aAdd( aFieldsEnd, {	"UJV_DTSEPU"    , "U04_DATA"    })
			aAdd( aFieldsEnd, {	"UJV_DTSEPU"    , "U04_PRZEXU"  })
			aAdd( aFieldsEnd, {	"UJV_NOME"      , "U04_QUEMUT"  })

			// verifico se tem algum campo que preciro alterar na tabela de enderecos
			nPosAlt := Ascan( aFieldsEnd, { |x| x[1] $ cParamCmpAlt } )

			// caso tenha algum com referencia no endereco para serem alterados
			If nPosAlt > 0

				// posiciono no endereco vinculado ao apontamento
				U04->(DbSetOrder(5)) //U04_FILIAL + U04_APONTA
				If U04->( MsSeek( xFilial("U04")+UJV->UJV_CODIGO ) )

					BEGIN TRANSACTION

						// faco a alteracao na tabela U04
						If U04->( Reclock("U04", .F.) )

							// percorro os campos com vinculo
							For nI := 1 To Len( aFieldsEnd )

								// verifico se estou no campo para alterar no endereco
								If aFieldsEnd[nI, 1] $ cParamCmpAlt

									// verifico se altero data de exumacao
									If aFieldsEnd[nI, 2] == "U04_PRZEXU"

										// posiciono no cadastro de servico
										DbSelectArea("SB1")
										SB1->( DbSetOrder(1) ) //B1_FILIAL+B1_COD
										If SB1->( MsSeek( xFilial("SB1")+UJV->UJV_SERVIC ) )

											If SB1->B1_XOCUGAV == "S" // verifico se ocupa gaveta
												U04->U04_PRZEXU	:= YearSum( &("UJV->"+aFieldsEnd[nI, 1]), nAnosExu ) // altero o prazo de exeumacao
											Else
												U04->U04_PRZEXU	:= &("UJV->"+aFieldsEnd[nI, 1])
											Endif

										Endif

									Else

										// gravo o campo do endereco de acordo com sua referencia do apontamento
										&("U04->"+aFieldsEnd[nI, 2]) := &("UJV->"+aFieldsEnd[nI, 1])

									EndIf

								EndIf

							Next nI

							U04->( MsUnlock() )
						Else
							U04->( DisarmTransaction() )
						EndIf

					END TRANSACTION

				EndIf

			EndIf

		EndIf

	ElseIf cIdPonto == "FORMPOS"

		// para inclusao ou alteracao
		If oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4

			// valido se obrigo preenchimento do lacre
			if lContinua .And. lUsaLacre

				// valido se o campo lacre existe
				if UJV->(FieldPos("UJV_LACOSS")) > 0

					// verifico se o lacred do ossario esta preenchido
					if !Empty( M->UJV_OSSARI ) .And. Empty( M->UJV_LACOSS )

						lContinua := .F.
						Help( ,, 'Help',, 'Quando o Endereço for um Ossário, o Campo "Lacre Oss." não pode estar vazio no apontamento de serviços!', 1, 0 )

					endIf

				endIf

			endIf

			// valido se os campos de data de sepultamento ou hora de sepultamento
			if lContinua

				if Empty( M->UJV_DTSEPU ) // data do sepultamento

					lContinua := .F.
					Help( ,, 'Help',, 'O Campo "' + GetSx3Cache("UJV_DTSEPU","X3_TITULO") + '" não pode estar vazio no apontamento de serviços!', 1, 0 )

				elseIf Empty( M->UJV_HORASE ) // hora do sepultamento

					lContinua := .F.
					Help( ,, 'Help',, 'O Campo "' + GetSx3Cache("UJV_HORASE","X3_TITULO") + '" não pode estar vazio no apontamento de serviços!', 1, 0 )

				endIf

			endIf

			// verifico se esta tudo certo
			If lContinua

				//caso o servico principal, esteja preenchido, valido se possui endereco
				cServico := M->UJV_SERVIC

				SB1->(DBSetOrder(1)) //B1_FILIAL + B1_COD

				If !lTransfEnd .And. SB1->(MsSeek(xFilial("SB1") + cServico))

					// valido se o campo tipo servico esta preenchido
					if !Empty(SB1->B1_XREQSER)

						// para jazigo e nao ocupa gaveta eu nao valido os dados de enderecamento
						If SB1->B1_XREQSER == "J" .And. SB1->B1_XOCUGAV <> 'S'
							lValDados := .F.
						else
							lValDados := .T.
						EndIf

					else
						lValDados := .F.
					endIf

					// verifico se irei validar os dados do obito para rotina automatica
					if !(FWIsInCallStack("U_RCPGA039") .Or. AllTrim(FunName()) $ "RCPGA039") .And. lRotAuto
						lValDados := lValidAptAuto
					EndIf

					// verifico se o plano pet esta habilitado
					if lValDados .And. lPlanoPet

						if SB1->B1_XUSOSRV == "3" // pet
							lValDados := .F.
						endIf

					endIf

					//verIfico se servico selecionado exige definicao de endereco
					If lValDados

						// validacao para dados dos obitos e do falecido
						If Empty( M->UJV_DTOBT ) // verifico se a data do obito foi preenchida

							lContinua := .F.
							Help( ,, 'Help',, 'Para serviços com endereçamento os "Dados do Obito" precisam ser preenchidos,';
								+ 'favor preencher o campo "Data Obito (UJV_DTOBT)" e confirme novamente!', 1, 0 )

						ElseIf Empty( M->UJV_CAUSA ) // verifico se a causa foi preenchida

							lContinua := .F.
							Help( ,, 'Help',, 'Para serviços com endereçamento os "Dados do Obito" precisam ser preenchidos,';
								+ 'favor preencher o campo "Causa Morte (UJV_CAUSA)" e confirme novamente!', 1, 0 )

						ElseIf Empty( M->UJV_DTCERT ) // verifico se a data do obito foi preenchida

							lContinua := .F.
							Help( ,, 'Help',, 'Para serviços com endereçamento os "Dados do Obito" precisam ser preenchidos,';
								+ 'favor preencher o campo "Dt Certidao (UJV_DTCERT)" e confirme novamente!', 1, 0 )

						ElseIf Empty( M->UJV_LOCFAL ) // verifico se o local de falecimento foi preenchida

							lContinua := .F.
							Help( ,, 'Help',, 'Para serviços com endereçamento os "Dados do Obito" precisam ser preenchidos,';
								+ 'favor preencher o campo "Local Faleci (UJV_LOCFAL)" e confirme novamente!', 1, 0 )

						ElseIf Empty( M->UJV_NOME ) // verifico se o nome foi preenchida

							lContinua := .F.
							Help( ,, 'Help',, 'Para serviços com endereçamento os "Dados do Obito" precisam ser preenchidos,';
								+ 'favor preencher o campo "Nome Fal. (UJV_NOME)" e confirme novamente!', 1, 0 )

						ElseIf Empty( M->UJV_DTNASC ) // verifico se a data de neascimento foi preenchida

							lContinua := .F.
							Help( ,, 'Help',, 'Para serviços com endereçamento os "Dados do Obito" precisam ser preenchidos,';
								+ 'favor preencher o campo "Data Nasc (UJV_DTNASC)" e confirme novamente!', 1, 0 )

						ElseIf Empty( M->UJV_NOMAE ) // verifico se o nome da mae foi preenchida

							lContinua := .F.
							Help( ,, 'Help',, 'Para serviços com endereçamento os "Dados do Obito" precisam ser preenchidos,';
								+ 'favor preencher o campo "Nome Mae (UJV_NOMAE)" e confirme novamente!', 1, 0 )

						EndIf

					elseIf lPlanoPet

						if Empty( M->UJV_NOME )

							lContinua := .F.
							Help( ,, 'Help',, 'Para serviços com endereçamento os "Dados do Obito" precisam ser preenchidos,';
								+ 'favor preencher o campo "Nome Fal. (UJV_NOME)" e confirme novamente!', 1, 0 )

						endIf

					EndIf

				EndIf

			EndIf

			// alimento o retorno de acordo com a variavel lContinua
			xRet := lContinua

		EndIf

	EndIf

	RestArea(aAreaU37)
	RestArea(aAreaSB1)
	RestArea(aAreaU00)
	RestArea(aAreaUJV)
	RestArea(aArea)

Return(xRet)

/*/{Protheus.doc} ValidaSalaVelorio
funcao para validar a sala de velorio
se nao existir vinculo com sala
faco a exclusao do registro
@type function
@version 1.0
@author g.sampaio
@since 20/06/2021
@param cCodApto, character, codigo do apontamento
/*/
Static Function ValidaSalaVelorio(cCodApto)

	Local aArea		:= GetArea()
	Local aAreaU25	:= U25->(GetArea())
	Local cQuery 	:= ""

	Default cCodApto := ""

	if Select("TRBU25") > 0
		TRBU25->(DBCloseArea())
	endIf

	cQuery := " SELECT U25.R_E_C_N_O_ RECU25 FROM " + RetSQLName("U25") + " U25 "
	cQuery += " WHERE U25.D_E_L_E_T_ = ' ' "
	cQuery += " AND U25.U25_FILIAL = '" + xFilial("U25") + "' "
	cQuery += " AND U25.U25_CODAPO = '" + cCodApto + "' "
	cQuery += " AND U25.U25_SALA = ' ' "

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TRBU25' )

	if TRBU25->(!Eof())

		U25->(DBGoTo(TRBU25->RECU25))

		if U25->(RecLock("U25", .F.))
			U25->(DBDelete())
			U25->(MsUnlock())
		else
			U25->(DisarmTransaction())
		endIf

	endIf

	if Select("TRBU25") > 0
		TRBU25->(DBCloseArea())
	endIf

	RestArea(aAreaU25)
	RestArea(aArea)

Return(Nil)
