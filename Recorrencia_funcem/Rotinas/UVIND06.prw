#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} IntegraVindi
Classe para Integração com a Plataforma Vindi
@type class
@version 1.0
@author Wellington Gonçalves
@since 21/01/2019
@obs Refatoracao - Marcos Nata Santos
/*/
Class IntegraVindi

	Data cKey
	Data cAuth
	Data aHeadOut
	Data nTimeOut
	Data cApiVindi
	Data cPathCliente
	Data cPathFatura
	Data cPathCobranca
	Data cPathPerfil
	Data cProdVindi
	Data cCodFaturaUso

	Method New() Constructor	// Método Construtor
	Method IncluiTabEnvio() 	// Método que inclui registro na tabela de integração de envio
	Method IncluiTabReceb() 	// Método que inclui registro na tabela de integração de recebimento
	Method ProcessaEnvio()		// Metodo que processa a tabela de envio
	Method ProcRecebi()			// Metodo que processa a tabela de recebimento
	Method IncluiCliente()		// Metodo que envia as Inclusões da entidade Cliente
	Method ExcluiCliente()		// Metodo que envia as Exclusoes da entidade Cliente
	Method AlteraCliente()		// Metodo que envia as Alterações da entidade Cliente
	Method UndelCliente()		// Metodo que envia os Desarquivamentos da entidade Cliente
	Method IncluiPerfil()		// Metodo que envia as Inclusões da entidade Perfil
	Method IncluiFatura()		// Metodo que envia as Inclusões da entidade Fatura
	Method ExcluiFatura()		// Metodo que envia as Exclusões da entidade Fatura
	Method AlteraFatura()		// Metodo que envia as Alterações da entidade Fatura
	Method CliOnline()			// Metodo que comunica com a Vindi Online
	Method PagarFatura()		// Metodo que realiza o pagamento da Fatura Vindi no Protheus
	Method EstornarFatura()		// Metodo que realiza o pagamento da Fatura Vindi no Protheus
	Method GravarTentativa()	// Metodo que realiza o pagamento da Fatura Vindi no Protheus
	Method IncManVind()			// Método que inclui o cliente e o perfil de pagamento Vindi manualmente
	Method ConsultaFatura()		// Consulta uma fatura na Vindi
	Method ConsultaCliente()	// Consulta um Cliente na Vindi pelo CPF
	Method ConsultaPerfil()		// Consulta um Perfil de pagamento na Vindi pelo ID
	Method ConsultaTel()		// Consulta telefones do cliente na Vindi pelo ID
	Method BuscarFaturaPorId()	// Busca uma fatura na vindi por id
	Method ReprocessarVindi()	// Reprocessa operacoes de envios/recebimentos por contrato
	Method BuscarFatPorData()	// Busca faturas na vindi por data
	Method ValidaEnvio()

EndClass

/*/{Protheus.doc} IntegraVindi::New
Construtor da Classe para Integracao com a Plataforma Vindi
@type method
@version 1.0
@author Wellington Goncalves
@since 21/01/2019
@obs Refatoracao - Marcos Nata Santos
/*/
Method New() Class IntegraVindi

	Self:cApiVindi		:= GetMV("MV_XAPIVIN") // "https://app.vindi.com.br/api"
	Self:cKey			:= GetMV("MV_XKEYVIN") // "ab9kQKu-HkPZ0VPE2q2zD4Dsfc27XNBQbnCA9kZ5kZU"
	Self:cAuth			:= "Basic " + Encode64(Self:cKey)
	Self:aHeadOut		:= {}
	Self:nTimeOut		:= 15
	Self:cPathCliente	:= "/v1/customers"
	Self:cPathFatura	:= "/v1/bills"
	Self:cPathCobranca	:= "/v1/charges"
	Self:cPathPerfil	:= "/v1/payment_profiles"
	Self:cProdVindi		:= SuperGetMv("MV_XCODVIN",,"393059")
	Self:cCodFaturaUso	:= ""

	aadd(Self:aHeadOut,"Content-Type:application/json")
	aadd(Self:aHeadOut,"Authorization: " + Self:cAuth)

Return()

/*/{Protheus.doc} IntegraVindi::IncluiTabEnvio
Método que inclui registro na tabela de envio
@type method
@version 1.0
@author Wellington Gonçalves
@since 21/01/2019
@param cCodModulo, character, cCodModulo
@param cTipoIntegracao, character, cTipoIntegracao
@param cTipoOperacao, character, cTipoOperacao
@param nIndice, numeric, nIndice
@param cChave, character, cChave
@param aProc, array, aProc
@param cOrigem, character, cOrigem
@param cOrigemDesc, character, cOrigemDesc
@obs Refatoracao - Marcos Nata Santos
/*/
Method IncluiTabEnvio(cCodModulo,cTipoIntegracao,cTipoOperacao,nIndice,cChave,aProc,cOrigem,cOrigemDesc) Class IntegraVindi

	Local aArea 		:= GetArea()
	Local aAreaU62		:= U62->(GetArea())
	Local cCodigo 		:= ""

	Default aProc		:= {}
	Default cOrigem		:= ""
	Default cOrigemDesc	:= ""

	//-- Avalia pontos de entrada na rotina FINA040, para setar origem de operacoes --//
	AvaliaF040(@cOrigem, @cOrigemDesc)

	// pego o próximo código da tabela
	cCodigo := GetSxeNum("U62","U62_CODIGO")

	U62->(DbSetOrder(1)) // U62_FILIAL + U62_CODIGO
	While U62->(MsSeek(xFilial("U62") + cCodigo))
		U62->(ConfirmSX8())
		cCodigo := GetSxeNum("U62","U62_CODIGO")
	EndDo

	if RecLock("U62",.T.)

		U62->U62_FILIAL := xFilial("U62")
		U62->U62_CODIGO	:= cCodigo
		U62->U62_MODULO	:= cCodModulo
		U62->U62_DTINC	:= dDataBase
		U62->U62_HRINC	:= SubStr(Time(),1,5)
		U62->U62_ENT	:= cTipoIntegracao
		U62->U62_OPER	:= cTipoOperacao
		U62->U62_INDICE	:= nIndice
		U62->U62_CHAVE	:= cChave
		U62->U62_MSFIL	:= cFilAnt
		U62->U62_ORIGEM	:= SubStr(cOrigem, 1, TamSX3("U62_ORIGEM")[1])
		U62->U62_ORGDES	:= SubStr(cOrigemDesc, 1, TamSX3("U62_ORGDES")[1])

		// verifico se já não foi ocorrido o envio
		// e está sendo gravada a tabela apenas para histórico
		if Empty(aProc)

			U62->U62_DTPROC	:= CTOD("  /  /    ")
			U62->U62_HRPROC	:= ""
			U62->U62_MSENV	:= ""
			U62->U62_MSRET	:= ""
			U62->U62_CODRET	:= ""
			U62->U62_DESRET	:= ""
			U62->U62_STATUS	:= "P"
			U62->U62_ERRO	:= ""

		else

			U62->U62_DTPROC	:= dDataBase
			U62->U62_HRPROC	:= Time()
			U62->U62_STATUS	:= aProc[1]
			U62->U62_MSENV	:= aProc[2]
			U62->U62_MSRET	:= aProc[3]
			U62->U62_CODRET	:= aProc[4]
			U62->U62_DESRET	:= aProc[5]
			U62->U62_ERRO	:= ""

		endif

		U62->(MsUnLock())

		// confirmo o controle de numeração
		U62->(ConfirmSX8())

	endif

	RestArea(aAreaU62)
	RestArea(aArea)

Return()

/*/{Protheus.doc} IntegraVindi::ConsultaCliente
Metodo que consultra cliente na Vindi
@type method
@version 1.0
@author Leandro Rodrigues
@since 21/01/2019
@param cChaveCliente, character, cChaveCliente
@param cErro, character, cErro
@param cContrato, character, cContrato
@param cIdMobile, character, cIdMobile
@param cIdVindi, character, cIdVindi
@return character, cStatus
@obs Refatoracao - Marcos Nata Santos
/*/
Method ConsultaCliente(cChaveCliente,cErro,cContrato,cIdMobile,cIdVindi) Class IntegraVindi

	Local oRest				:= NIL
	Local oJson				:= NIL
	Local aArea				:= GetArea()
	Local aAreaSA1			:= SA1->( GetArea() )
	Local aAreaU61			:= U61->( GetArea() )
	Local cJsonRetorno		:= ""
	Local cStatus			:= ""
	Local cChaveConsulta	:= ""
	Local lRet				:= .F.

	Default cIdVindi		:= ""

	oRest := FWRest():New(Self:cApiVindi)

	// defino o timeout da conexao
	oRest:nTimeOut := Self:nTimeOut

	SA1->(DbSetOrder(1))
	If SA1->(MsSeek(xFilial("SA1")+cChaveCliente))

		//Valido se o contrato foi do Virtus
		if !Empty(cIdVindi)

			//Filtra pelo id Vindi
			cJsonEnvio := "query=id="+ AllTrim(cIdVindi)

		elseif !Empty(cIdMobile)

			//Filtra pelo CPF
			cJsonEnvio := "query=registry_code="+ AllTrim(SA1->A1_CGC)

		else

			cChaveConsulta := Alltrim(cContrato) + Alltrim(cChaveCliente)

			cJsonEnvio := "query=code="+ cChaveConsulta

		endif

		// informo o path do metodo
		oRest:SetPath(Self:cPathCliente + "/?" + cJsonEnvio)

		// envio o comando
		lRet := oRest:Get(Self:aHeadOut)

		// pego o retorno da API
		cJsonRetorno := oRest:GetResult()

		// converto a string JSON
		if FWJsonDeserialize(cJsonRetorno,@oJson)

			cCodRet			:= oRest:oResponseh:cStatusCode
			cDescRetorno	:= oRest:oResponseh:cReason
			cDadosRetorno	:= cJsonRetorno

			// se a comunicacao REST ocorreu
			If lRet

				if cCodRet == "200"

					if Len(oJson:Customers) > 0

						cStatus	:= oJson:Customers[1]:Status  // pega status do cliente

						//valido se cliente ja esta cadastrado na U61
						U61->(DbSetOrder(2)) // U61_FILIAL+U61_CODIGO
						if !U61->( MsSeek( xFilial("U61") + cValToChar(oJson:Customers[1]:id) ) )

							// cria cliente Vindi no Protheus
							if RecLock("U61", .T.)

								U61->U61_FILIAL := xFilial("U61")
								U61->U61_CODIGO := cValToChar(oJson:Customers[1]:id)
								U61->U61_DATA	:= dDataBase
								U61->U61_HORA	:= SubStr(Time(),1,5)
								U61->U61_CONTRA	:= cContrato
								U61->U61_CLIENT	:= SA1->A1_COD
								U61->U61_LOJA	:= SA1->A1_LOJA
								U61->U61_STATUS	:= iif(cStatus == "archived","I","A")
								U61->U61_MSFIL	:= cFilAnt

								U61->(MsUnLock())

							endif

						endif

					endif

				endif

			else

				if AT('"parameter"',cJsonRetorno)
					cErro 	:= oJson:ERRORS[1]:PARAMETER + ": " + oJson:ERRORS[1]:MESSAGE
				endif

			endif

		else
			cErro 			:= "Erro Vindi - Estrutura do retorno inválida!"
			cDadosRetorno	:= cJsonRetorno
		endif
	endif

	RestArea(aArea)
	RestArea(aAreaSA1)
	RestArea(aAreaU61)

Return(cStatus)

/*/{Protheus.doc} IntegraVindi::ProcessaEnvio
Metodo que processa os registros pendentes de envio
@type method
@version 1.0
@author Wellington Gonçalves
@since 26/01/2019
@param cContrato, character, cContrato
@obs Refatoracao - Marcos Nata Santos
/*/
Method ProcessaEnvio(cContrato) Class IntegraVindi

	Local aArea 			:= GetArea()
	Local cQry				:= ""
	Local cPulaLinha		:= chr(13)+chr(10)
	Local cErro				:= ""
	Local cJsonEnvio		:= ""
	Local cCodRet			:= ""
	Local cDescRetorno		:= ""
	Local cDadosRetorno		:= ""
	Local nStart			:= Seconds()
	Local cMessage			:= ""
	Local nQtdDiaVindi		:= SuperGetMv("MV_XQTDDVI", .F., 60) // Qtd de dias anterior na consulta
	Local cMesVindi			:= DTOS( DaySub(dDatabase, nQtdDiaVindi) )

	Default cContrato := ""

	// limpo o codigo da fatura para tratativa de excesso de erro
	Self:cCodFaturaUso := ""

	// verifico se nao existe este alias criado
	If Select("QRYU62") > 0
		QRYU62->(DbCloseArea())
	EndIf

	cQry := " SELECT "													+ cPulaLinha
	cQry += " U62.U62_FILIAL AS FILIAL_INTEGRACAO, "         			+ cPulaLinha
	cQry += " U62.U62_CODIGO AS CODIGO_INTEGRACAO, "            		+ cPulaLinha
	cQry += " U62.U62_MODULO AS CODIGO_MODULO, "            			+ cPulaLinha
	cQry += " U62.U62_DTINC AS DATA_INCLUSAO, "                 		+ cPulaLinha
	cQry += " U62.U62_HRINC AS HORA_INCLUSAO, "                 		+ cPulaLinha
	cQry += " U62.U62_ENT AS ENTIDADE, " 								+ cPulaLinha
	cQry += " U62.U62_OPER AS OPERACAO, " 								+ cPulaLinha
	cQry += " U62.U62_INDICE AS INDICE_REGISTRO, " 						+ cPulaLinha
	cQry += " U62.U62_CHAVE AS CHAVE_REGISTRO, " 						+ cPulaLinha
	cQry += " U62.R_E_C_N_O_ RECU62 "			 						+ cPulaLinha
	cQry += " FROM "                                            		+ cPulaLinha
	cQry += " " + RetSqlName("U62") + " U62 "			        		+ cPulaLinha
	cQry += " WHERE "                                           		+ cPulaLinha
	cQry += " U62.D_E_L_E_T_ <> '*' "                           		+ cPulaLinha
	cQry += " AND U62.U62_MSFIL = '" + cFilAnt + "'"		   			+ cPulaLinha
	cQry += " AND U62.U62_STATUS <> 'C' "          						+ cPulaLinha
	
	If Empty(cContrato)
		cQry += " AND U62.U62_DTINC >= '"+ cMesVindi +"' "				+ cPulaLinha
	EndIf

	If !Empty(cContrato)
		cQry += " AND U62.U62_CHAVE LIKE '%"+ AllTrim(cContrato) +"%' "	+ cPulaLinha
	EndIf
	cQry += " ORDER BY U62.U62_DTINC , U62.U62_HRINC , U62.U62_CODIGO " + cPulaLinha

	// funcao que converte a query generica para o protheus
	cQry := ChangeQuery(cQry)

	// crio o alias temporario
	MPSysOpenQuery(cQry, "QRYU62")

	if QRYU62->(!Eof())

		While QRYU62->(!Eof())

			cErro 				:= ""
			cJsonEnvio 			:= ""
			cCodRet				:= ""
			cDescRetorno		:= ""
			cDadosRetorno		:= ""

			//Posiciono no registro da U62
			U62->(DbGoTo(QRYU62->RECU62))

			if QRYU62->ENTIDADE == "1" // Cliente

				if QRYU62->OPERACAO == "A" // Alteração
					::AlteraCliente(QRYU62->CODIGO_MODULO,@cErro,@cJsonEnvio,@cCodRet,@cDescRetorno,@cDadosRetorno,QRYU62->INDICE_REGISTRO,Rtrim(QRYU62->CHAVE_REGISTRO))
				endif

			elseif QRYU62->ENTIDADE == "3" // Cobrança

				// Inclusão de Fatura
				if QRYU62->OPERACAO == "I"

					//Valida se envia fatura para VINDI
					if ::ValidaEnvio(QRYU62->CODIGO_MODULO,Rtrim(QRYU62->CHAVE_REGISTRO))

						::IncluiFatura(QRYU62->CODIGO_MODULO,@cErro,@cJsonEnvio,@cCodRet,@cDescRetorno,@cDadosRetorno,QRYU62->INDICE_REGISTRO,QRYU62->CHAVE_REGISTRO)

					else

						cErro := "Processo nao validado pela rotina Valida Envio"
					Endif

				elseif QRYU62->OPERACAO == "E"
					::ExcluiFatura(QRYU62->CODIGO_MODULO,@cErro,@cJsonEnvio,@cCodRet,@cDescRetorno,@cDadosRetorno,QRYU62->INDICE_REGISTRO,QRYU62->CHAVE_REGISTRO)

				elseif QRYU62->OPERACAO == "A"
					::AlteraFatura(QRYU62->CODIGO_MODULO,@cErro,@cJsonEnvio,@cCodRet,@cDescRetorno,@cDadosRetorno,QRYU62->INDICE_REGISTRO,QRYU62->CHAVE_REGISTRO)
				endif

			endif

			U62->(DbSetOrder(1)) // U62_FILIAL + U62_CODIGO
			if U62->(MsSeek(QRYU62->FILIAL_INTEGRACAO + QRYU62->CODIGO_INTEGRACAO))

				If U62->(RecLock("U62",.F.))

					cMessage := "Log Processamento => " + AllTrim(QRYU62->CHAVE_REGISTRO)
					FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
					cMessage := "Erro: " + NoAcento(AnsiToOem(AllTrim(cErro)))
					FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
					cMessage := "Retorno: " + NoAcento(AnsiToOem(AllTrim(cDescRetorno)))
					FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

					U62->U62_DTPROC := dDataBase
					U62->U62_HRPROC := SubStr(Time(),1,5)
					U62->U62_STATUS := iif(Empty(cErro),"C","E")
					U62->U62_ERRO	:= NoAcento(AllTrim(cErro))
					
					If !Empty(cJsonEnvio)
						U62->U62_MSENV	:= DecodeUtf8(cJsonEnvio)
					EndIf
					
					If !Empty(cDadosRetorno)
						U62->U62_MSRET	:= DecodeUtf8(cDadosRetorno)
					EndIf

					If !Empty(cCodRet)
						U62->U62_CODRET	:= DecodeUtf8(cCodRet)
					EndIf

					If !Empty(cDescRetorno)
						U62->U62_DESRET	:= DecodeUtf8(cDescRetorno)
					EndIf
	
					U62->(MsUnLock())
				
				Else
					U62->(DisarmTransaction())

				endif

			endif

			QRYU62->(DbSkip())

		EndDo

	endif

	If Select("QRYU62") > 0
		QRYU62->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} IntegraVindi::IncluiCliente
Metodo que inclui o cliente na Vindi
@type method
@version 1.0
@author Wellington Gonçalves
@since 26/01/2019
@param cCodModulo, character, cCodModulo
@param cErro, character, cErro
@param cJsonEnvio, character, cJsonEnvio
@param cCodRet, character, cCodRet
@param cDescRetorno, character, cDescRetorno
@param cDadosRetorno, character, cDadosRetorno
@param cOrigem, character, cOrigem
@param cOrigemDesc, character, cOrigemDesc
@return logical, lRet
@obs Refatoracao - Marcos Nata Santos
/*/
Method IncluiCliente(cCodModulo,cErro,cJsonEnvio,cCodRet,cDescRetorno,cDadosRetorno,cOrigem,cOrigemDesc,cStatus) Class IntegraVindi

	Local lRet			:= .T.
	Local lInclui		:= .T.
	Local aArea			:= GetArea()
	Local aAreaSA1		:= SA1->( GetArea() )
	Local aAreaU61		:= U61->( GetArea() )
	Local cCodCliERP	:= ""
	Local cTelefone		:= ""
	Local cJsonRetorno	:= ""
	Local cCodVindi		:= ""
	Local cChaveCliente	:= ""
	Local cFilialCtr	:= ""
	Local cContrato		:= ""
	Local oRest			:= NIL
	Local oJson			:= NIL
	Local lUsaMsfil		:= SuperGetMV("MV_XVMSFIL", .F., .T.)	// parametro determinar se usa o UF2_MSFIL(.T.) ou UF2_FILIAL(.F.)
	Local nStart		:= Seconds()

	Default cOrigem := "UVIND06"
	Default cOrigemDesc := "IntegraVindi CliOnline"
	Default cStatus	:= ""

	FwLogMsg("INFO", , "REST", FunName(), "", "01","VINDI - Inclusao do Cliente", 0, (Seconds() - nStart), {})

	if cCodModulo == "F"

		//Valido se é mudanca de titularidade
		If IsInCallStack("U_RFUNA006")
			cChaveCliente 	:= M->UF2_CLIENT + M->UF2_LOJA

		Else
			cChaveCliente 	:= UF2->UF2_CLIENT + UF2->UF2_LOJA
		Endif
		cContrato		:= UF2->UF2_CODIGO
		cFilialCtr		:= iif(lUsaMsfil,UF2->UF2_MSFIL,UF2->UF2_FILIAL)
	else
		cChaveCliente 	:= U00->U00_CLIENT + U00->U00_LOJA
		cContrato		:= U00->U00_CODIGO
		cFilialCtr		:= iif(lUsaMsfil,U00->U00_MSFIL,U00->U00_FILIAL)
	endif

	SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD + A1_LOJA
	if SA1->(MsSeek(xFilial("SA1") + cChaveCliente))

		// posiciono no cliente da vindi
		U61->(DbSetOrder(3)) // U61_FILIAL + U61_CLIENT + U61_LOJA
		if U61->(MsSeek(cFilialCtr + SA1->A1_COD + SA1->A1_LOJA))

			if Empty(cStatus)
				cStatus := Self:ConsultaCliente(U61->U61_CLIENT + U61->U61_LOJA,@cErro,cContrato,"",U61->U61_CODIGO)
			endIf

			// se já existe este cliente com status ativo, não permito continuar a operação
			if U61->U61_STATUS == "A"
				lRet := .F.
				cErro := "Este cliente já existe na Vindi com Status Ativo!"
			else

				// verifico se o status e inativo
				if AllTrim(cStatus) == "inactive"

					// Undeleta o cliente Vindi no Protheus
					if U61->(RecLock("U61", .F.))

						U61->U61_STATUS := "A"
						U61->U61_CONTRA := cContrato
						U61->(MsUnLock())

					endif

				endIf

				lInclui := .F.
			endif

		endif

		if lRet

			// se a operação for de inclusão do cliente
			if lInclui

				oRest := FWRest():New(Self:cApiVindi)

				// defino o timeout da conexao
				oRest:nTimeOut := Self:nTimeOut

				// informo o path do metodo
				oRest:SetPath(Self:cPathCliente)

				cCodCliERP := cContrato + SA1->A1_COD + SA1->A1_LOJA

				if !Empty(SA1->A1_XCEL)
					cTelefone	:= "55" + AllTrim(SA1->A1_XDDDCEL) + StrTran(AllTrim(SA1->A1_XCEL),"-","")
				else
					cTelefone	:= "55" + AllTrim(SA1->A1_DDD) + StrTran(AllTrim(SA1->A1_TEL),"-","")
				endif


				cJsonEnvio := ' { '
				cJsonEnvio += '   "name": "' 					+ AllTrim(FwNoAccent(SA1->A1_NOME))+ '", ' 	// NOME

				if !Empty(SA1->A1_EMAIL) .AND. Alltrim(SA1->A1_EMAIL) != "@"
					cJsonEnvio += '   "email": "' 				+ AllTrim(SA1->A1_EMAIL) + '", ' 	// EMAIL
				endif

				cJsonEnvio += '   "registry_code": "' 			+ AllTrim(SA1->A1_CGC) + '", ' 		// CPF / CNPJ
				cJsonEnvio += '   "code": "' 					+ AllTrim(cCodCliERP) + '", ' 		// CODIGO DO ERP
				cJsonEnvio += '   "address": { '
				cJsonEnvio += '     "street": "' 				+ AllTrim(FwNoAccent(SA1->A1_END)) + '", ' 		// ENDERECO
				cJsonEnvio += '     "zipcode": "' 				+ AllTrim(SA1->A1_CEP) + '", ' 		// CEP
				cJsonEnvio += '     "neighborhood": "' 			+ AllTrim(FwNoAccent(SA1->A1_BAIRRO)) + '", ' 	// BAIRRO
				cJsonEnvio += '     "city": "' 					+ AllTrim(SA1->A1_MUN) + '", ' 		// CIDADE
				cJsonEnvio += '     "state": "' 				+ AllTrim(SA1->A1_EST) + '", ' 		// UF
				cJsonEnvio += '     "country": "' 				+ AllTrim("BR") + '" ' 				// PAIS
				cJsonEnvio += '   }, '
				cJsonEnvio += '   "phones": [ '
				cJsonEnvio += '     { '
				cJsonEnvio += '       "phone_type": "' 			+ 'landline' + '", ' 				// 'mobile' ou 'landline'
				cJsonEnvio += '       "number": "' 				+ AllTrim(cTelefone) + '" ' 		// NUMERO DO TELEFONE - 5511975416666
				cJsonEnvio += '     } '
				cJsonEnvio += '   ] '
				cJsonEnvio += ' } '

				// seto a string Json
				oRest:SetPostParams(cJsonEnvio)

				lRet := oRest:Post(Self:aHeadOut)

				// pego o retorno da API
				cJsonRetorno := oRest:GetResult()

				// converto a string JSON
				if FWJsonDeserialize(cJsonRetorno,@oJson)

					cCodRet			:= oRest:oResponseh:cStatusCode
					cDescRetorno	:= oRest:oResponseh:cReason
					cDadosRetorno	:= cJsonRetorno

					// se a comunicacao REST ocorreu
					If lRet

						cCodVindi := cValToChar(oJson:Customer:Id)

						if !Empty(cCodVindi)

							// cria cliente Vindi no Protheus
							if RecLock("U61",.T.)

								U61->U61_FILIAL := xFilial("U61")
								U61->U61_CODIGO := cCodVindi
								U61->U61_DATA	:= dDataBase
								U61->U61_HORA	:= SubStr(Time(),1,5)
								U61->U61_CONTRA	:= cContrato
								U61->U61_CLIENT	:= SA1->A1_COD
								U61->U61_LOJA	:= SA1->A1_LOJA
								U61->U61_STATUS	:= "A"
								U61->U61_MSFIL	:= cFilAnt

								U61->(MsUnLock())

							endif

						else
							cErro := "Erro Vindi - Não foi retornado o código do Cliente!"
						endif

					else

						if AT('"parameter"',cJsonRetorno)
							cErro := oJson:ERRORS[1]:PARAMETER + ": " + oJson:ERRORS[1]:MESSAGE
						endif

					endif

				else
					cErro 			:= "Erro Vindi - Estrutura do retorno inválida!"
					cDadosRetorno	:= cJsonRetorno
				endif

			else

				// altero o cliente para ativo na Vindi
				if AllTrim(cStatus) == "archived" // verifico se o cliente esta arquivodo
					lRet := Self:CliOnline("D",cCodModulo,@cErro,cOrigem,cOrigemDesc)
				endIf

				if lRet
					// atualizo os dados do cliente
					lRet := Self:CliOnline("A",cCodModulo,@cErro,cOrigem,cOrigemDesc)
				endif

			endif

		endif

	else
		cErro := "Não foi possível localizar o cadastro do Cliente!"
	endif

	// se tem mensagem de erro
	if !Empty(cErro)

		FwLogMsg("ERROR", , "REST", FunName(), "", "01", cErro, 0, (Seconds() - nStart), {})

		lRet := .F.
	endif

	RestArea(aArea)
	RestArea(aAreaSA1)
	RestArea(aAreaU61)

Return(lRet)

/*/{Protheus.doc} IntegraVindi::ExcluiCliente
Metodo que inclui o cliente na Vindi
@type method
@version 1.0
@author Wellington Gonçalves
@since 26/01/2019
@param cCodModulo, character, cCodModulo
@param cErro, character, cErro
@param cJsonEnvio, character, cJsonEnvio
@param cCodRet, character, cCodRet
@param cDescRetorno, character, cDescRetorno
@param cDadosRetorno, character, cDadosRetorno
@param nIndice, numeric, nIndice
@param cChave, character, cChave
@return logical, lRet
@obs Refatoracao - Marcos Nata Santos
/*/
Method ExcluiCliente(cCodModulo,cErro,cJsonEnvio,cCodRet,cDescRetorno,cDadosRetorno,nIndice,cChave) Class IntegraVindi

	Local lRet			:= .T.
	Local aArea			:= GetArea()
	Local aAreaU61		:= U61->(GetArea())
	Local oRest			:= NIL
	Local oJson			:= NIL
	Local nStart		:= Seconds()

	FwLogMsg("INFO", , "REST", FunName(), "", "01", "VINDI - Exclusao do Cliente", 0, (Seconds() - nStart), {})

	// posiciono no cliente da vindi
	U61->(DbSetOrder(nIndice))
	if U61->(MsSeek(cChave))

		oRest := FWRest():New(Self:cApiVindi)

		// defino o timeout da conexao
		oRest:nTimeOut := Self:nTimeOut

		cJsonEnvio := AllTrim(U61->U61_CODIGO)

		// informo o path do metodo
		oRest:SetPath(Self:cPathCliente + "/" + cJsonEnvio)

		// envio o comando de delete
		lRet := oRest:Delete(Self:aHeadOut)

		// pego o retorno da API
		cJsonRetorno := oRest:GetResult()

		// converto a string JSON
		if FWJsonDeserialize(cJsonRetorno,@oJson)

			cCodRet			:= oRest:oResponseh:cStatusCode
			cDescRetorno	:= oRest:oResponseh:cReason
			cDadosRetorno	:= cJsonRetorno

			// se a comunicacao REST ocorreu
			If lRet

				// inativa o cliente Vindi no Protheus
				if RecLock("U61",.F.)

					U61->U61_STATUS := "I"
					U61->(MsUnLock())

					// Perfis de pagamento do cliente vindi
					U64->(DbSetOrder(2)) // U64_FILIAL + U64_CONTRA + U64_CLIENT + U64_LOJA + U64_STATUS
					If U64->( MsSeek(xFilial("U64") + U61->U61_CONTRA + U61->U61_CLIENT + U61->U61_LOJA) )

						While U64->( !EOF() );
								.And. U64->U64_FILIAL == xFilial("U64");
								.And. U64->U64_CONTRA == U61->U61_CONTRA;
								.And. U64->U64_CLIENT == U61->U61_CLIENT;
								.And. U64->U64_LOJA == U61->U61_LOJA

							// Inativa o perfil de pagamento
							If U64->U64_STATUS == "A"
								If RecLock("U64", .F.)
									U64->U64_STATUS := "I"
									U64->(MsUnLock())
								EndIf
							EndIf

							U64->( DbSkip() )
						EndDo

					EndIf

				EndIf

			else

				if AT('"parameter"',cJsonRetorno)
					cErro := oJson:ERRORS[1]:PARAMETER + ": " + oJson:ERRORS[1]:MESSAGE
				endif

			endif

		else
			cErro 			:= "Erro Vindi - Estrutura do retorno inválida!"
			cDadosRetorno	:= cJsonRetorno
		endif

	else
		cErro := "Não foi possível localizar o cadastro do Cliente Vindi!"
	endif

	// se tem mensagem de erro
	if !Empty(cErro)

		FwLogMsg("ERROR", , "REST", FunName(), "", "01", cErro, 0, (Seconds() - nStart), {})

		lRet := .F.
	endif

	RestArea(aAreaU61)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} IntegraVindi::AlteraCliente
Metodo que altera o cliente na Vindi
@type method
@version 1.0
@author Wellington Gonçalves
@since 11/12/2019
@param cCodModulo, character, cCodModulo
@param cErro, character, cErro
@param cJsonEnvio, character, cJsonEnvio
@param cCodRet, character, cCodRet
@param cDescRetorno, character, cDescRetorno
@param cDadosRetorno, character, cDadosRetorno
@param nIndice, numeric, nIndice
@param cChave, character, cChave
@return logical, lRet
@obs Refatoracao - Marcos Nata Santos
/*/
Method AlteraCliente(cCodModulo,cErro,cJsonEnvio,cCodRet,cDescRetorno,cDadosRetorno,nIndice,cChave) Class IntegraVindi

	Local lRet			:= .T.
	Local aArea			:= GetArea()
	Local aAreaU61		:= U61->(GetArea())
	Local aAreaSA1		:= SA1->(GetArea())
	Local cCodCliERP	:= ""
	Local cTelefone		:= ""
	Local aPhones		:= {}
	Local oRest			:= NIL
	Local oJson			:= NIL
	Local nStart		:= Seconds()

	FwLogMsg("INFO", , "REST", FunName(), "", "01", "VINDI - Alteracao de Cliente", 0, (Seconds() - nStart), {})

	// posiciono no cliente da vindi
	U61->(DbSetOrder(nIndice))
	if U61->(MsSeek(cChave))

		SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD
		if SA1->(MsSeek(xFilial("SA1") + U61->U61_CLIENT + U61->U61_LOJA))

			aPhones := Self:ConsultaTel( AllTrim(U61->U61_CODIGO) )

			oRest := FWRest():New(Self:cApiVindi)

			// defino o timeout da conexao
			oRest:nTimeOut := Self:nTimeOut

			cCodCliERP 	:= U61->U61_CONTRA + SA1->A1_COD + SA1->A1_LOJA
			cTelefone	:= "55" + AllTrim(SA1->A1_DDD) + StrTran(AllTrim(SA1->A1_TEL),"-","")

			cJsonEnvio := ' { '
			cJsonEnvio += '   "name": "' 					+ AllTrim(SA1->A1_NOME) 	+ '", ' 	// NOME

			if !Empty(SA1->A1_EMAIL) .AND. Alltrim(SA1->A1_EMAIL) != "@"
				cJsonEnvio += '   "email": "' 				+ AllTrim(SA1->A1_EMAIL) 	+ '", ' 	// EMAIL
			endif

			cJsonEnvio += '   "registry_code": "' 			+ AllTrim(SA1->A1_CGC) 		+ '", ' 		// CPF / CNPJ
			cJsonEnvio += '   "code": "' 					+ AllTrim(cCodCliERP) 		+ '", ' 		// CODIGO DO ERP
			cJsonEnvio += '   "address": { '
			cJsonEnvio += '     "street": "' 				+ AllTrim(SA1->A1_END) 		+ '", ' 		// ENDERECO
			cJsonEnvio += '     "zipcode": "' 				+ AllTrim(SA1->A1_CEP) 		+ '", ' 		// CEP
			cJsonEnvio += '     "neighborhood": "' 			+ AllTrim(SA1->A1_BAIRRO) 	+ '", ' 	// BAIRRO
			cJsonEnvio += '     "city": "' 					+ AllTrim(SA1->A1_MUN) 		+ '", ' 		// CIDADE
			cJsonEnvio += '     "state": "' 				+ AllTrim(SA1->A1_EST) 		+ '", ' 		// UF
			cJsonEnvio += '     "country": "' 				+ AllTrim("BR") 			+ '" ' 				// PAIS
			cJsonEnvio += '   }, '
			cJsonEnvio += '   "phones": [ '
			cJsonEnvio += '     { '
			If Len(aPhones) > 0
				cJsonEnvio += '       "id": '+ cValToChar(aPhones[1][1]) +', '
			EndIf
			cJsonEnvio += '       "phone_type": "' 			+ 'landline' 				+ '", '
			cJsonEnvio += '       "number": "' 				+ AllTrim(cTelefone) 		+ '" '
			cJsonEnvio += '     } '
			cJsonEnvio += '   ] '
			cJsonEnvio += ' } '

			// informo o path do metodo
			oRest:SetPath(Self:cPathCliente + "/" + AllTrim(U61->U61_CODIGO))

			// envio o comando de alteração
			lRet := oRest:Put(Self:aHeadOut,cJsonEnvio)

			// pego o retorno da API
			cJsonRetorno := oRest:GetResult()

			// converto a string JSON
			if FWJsonDeserialize(cJsonRetorno,@oJson)

				cCodRet			:= oRest:oResponseh:cStatusCode
				cDescRetorno	:= oRest:oResponseh:cReason
				cDadosRetorno	:= cJsonRetorno

				// se a comunicacao REST não ocorreu
				If !lRet

					if AT('"parameter"',cJsonRetorno)
						cErro := oJson:ERRORS[1]:PARAMETER + ": " + oJson:ERRORS[1]:MESSAGE
					endif

				endif

			else
				cErro 			:= "Erro Vindi - Estrutura do retorno inválida!"
				cDadosRetorno	:= cJsonRetorno
			endif

		else
			cErro := "Não foi possível localizar o cadastro do Cliente!"
		endif

	else
		cErro := "Não foi possível localizar o cadastro do Cliente Vindi!"
	endif

	// se tem mensagem de erro
	if !Empty(cErro)

		FwLogMsg("ERROR", , "REST", FunName(), "", "01", cErro, 0, (Seconds() - nStart), {})
		lRet := .F.

	endif

	RestArea(aAreaU61)
	RestArea(aAreaSA1)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} IntegraVindi::UndelCliente
Metodo que desarquiva o cliente na Vindi
@type method
@version 1.0
@author Wellington Gonçalves
@since 11/12/2019
@param cCodModulo, character, cCodModulo
@param cErro, character, cErro
@param cJsonEnvio, character, cJsonEnvio
@param cCodRet, character, cCodRet
@param cDescRetorno, character, cDescRetorno
@param cDadosRetorno, character, cDadosRetorno
@param nIndice, numeric, nIndice
@param cChave, character, cChave
@param cContrato, character, cContrato
@return logical, lRet
@obs Refatoracao - Marcos Nata Santos
/*/
Method UndelCliente(cCodModulo,cErro,cJsonEnvio,cCodRet,cDescRetorno,cDadosRetorno,nIndice,cChave,cContrato) Class IntegraVindi

	Local lRet			:= .T.
	Local aArea			:= GetArea()
	Local aAreaU61		:= U61->(GetArea())
	Local aAreaSA1		:= SA1->(GetArea())
	Local oRest			:= NIL
	Local oJson			:= NIL
	Local nStart		:= Seconds()

	FwLogMsg("INFO", , "REST", FunName(), "", "01","VINDI - Desarquivamento do Cliente", 0, (Seconds() - nStart), {})

	// posiciono no cliente da vindi
	U61->(DbSetOrder(nIndice))
	if U61->(MsSeek(cChave))

		SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD
		if SA1->(MsSeek(xFilial("SA1") + U61->U61_CLIENT + U61->U61_LOJA ))

			oRest := FWRest():New(Self:cApiVindi)

			// defino o timeout da conexao
			oRest:nTimeOut := Self:nTimeOut

			cJsonEnvio := AllTrim(U61->U61_CODIGO)

			// informo o path do metodo
			oRest:SetPath(Self:cPathCliente + "/" + cJsonEnvio + "/unarchive")

			// envio o comando de delete
			lRet := oRest:Post(Self:aHeadOut)

			// pego o retorno da API
			cJsonRetorno := oRest:GetResult()

			// converto a string JSON
			if FWJsonDeserialize(cJsonRetorno,@oJson)

				cCodRet			:= oRest:oResponseh:cStatusCode
				cDescRetorno	:= oRest:oResponseh:cReason
				cDadosRetorno	:= cJsonRetorno

				// se a comunicacao REST ocorreu
				If lRet

					// Undeleta o cliente Vindi no Protheus
					if RecLock("U61", .F.)

						U61->U61_STATUS := "A"
						U61->U61_CONTRA := cContrato
						U61->(MsUnLock())

					endif

				else

					cErro := "Id: " + AllTrim(oJson:ERRORS[1]:ID);
						+ " Mensagem: " + AllTrim(oJson:ERRORS[1]:MESSAGE)

				endif

			else
				cErro 			:= "Erro Vindi - Estrutura do retorno inválida!"
				cDadosRetorno	:= cJsonRetorno
			endif

		else
			cErro := "Não foi possível localizar o cadastro do Cliente!"
		endif

	else
		cErro := "Não foi possível localizar o cadastro do Cliente Vindi!"
	endif

	// se tem mensagem de erro
	if !Empty(cErro)

		FwLogMsg("ERROR", , "REST", FunName(), "", "01", cErro, 0, (Seconds() - nStart), {})
		lRet := .F.

	endif

	RestArea(aArea)
	RestArea(aAreaU61)
	RestArea(aAreaSA1)

Return(lRet)

/*/{Protheus.doc} IntegraVindi::IncluiPerfil
Metodo que inclui o perfil do cliente na Vindi
@type method
@version 1.0
@author Wellington Gonçalves
@since 26/01/2019
@param cCodModulo, character, cCodModulo
@param cErro, character, cErro
@param cCodVindi, character, cCodVindi
@param cToken, character, cToken
@param cFormPag, character, cFormPag
@param cNome, character, cNome
@param cNumCartao, character, cNumCartao
@param cValidade, character, cValidade
@param cCVV, character, cCVV
@param cBandeira, character, cBandeira
@param cOrigem, character, cOrigem
@param cOrigemDesc, character, cOrigemDesc
@return logical, lRet
@obs Refatoracao - Marcos Nata Santos
/*/
	Method IncluiPerfil(cCodModulo,cErro,cCodVindi,cToken,cFormPag,cNome,;
		cNumCartao,cValidade,cCVV,cBandeira,cOrigem,cOrigemDesc) Class IntegraVindi

	Local lRet			:= .T.
	Local aArea			:= GetArea()
	Local aAreaSA1		:= SA1->( GetArea() )
	Local aAreaU61		:= U61->( GetArea() )
	Local aAreaU60		:= U60->( GetArea() )
	Local aDadosProc	:= {}
	Local cJsonEnvio	:= ""
	Local cJsonRetorno	:= ""
	Local cCodRet		:= ""
	Local cDescRetorno	:= ""
	Local cDadosRetorno	:= ""
	Local cChaveCliente	:= ""
	Local cFilialCtr	:= ""
	Local cContrato		:= ""
	Local oRest			:= NIL
	Local oJson			:= NIL
	Local nStart		:= Seconds()

	Default cOrigem := "UVIND06"
	Default cOrigemDesc := "IntegraVindi IncluiPerfil"

	FwLogMsg("INFO", , "REST", FunName(), "", "01","VINDI - Inclusao do Perfil de Pagamento", 0, (Seconds() - nStart), {})

	if cCodModulo == "F" // funeraria/plano

		//Se é transferencia de titularidade
		If IsInCallStack("U_RFUNA006")

			cChaveCliente 	:= M->UF2_CLIENT + M->UF2_LOJA
		Else

			cChaveCliente 	:= UF2->UF2_CLIENT + UF2->UF2_LOJA
		Endif

		cFilialCtr		:= xFilial("UF2")
		cContrato		:= UF2->UF2_CODIGO

	elseIf cCodModulo == "C" // cemiterio

		cChaveCliente 	:= U00->U00_CLIENT + U00->U00_LOJA
		cFilialCtr		:= xFilial("U00")
		cContrato		:= U00->U00_CODIGO

	endif

	SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD
	if SA1->(MsSeek(xFilial("SA1") + cChaveCliente))

		// posiciono no cliente da vindi
		U61->(DbSetOrder(1)) // U61_FILIAL + U61_CONTRA + U61_CLIENT + U61_LOJA
		if U61->(MsSeek(xFilial("U61") + cContrato + SA1->A1_COD + SA1->A1_LOJA))

			// posiciono no metodo de pagamento da vindi
			U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
			if U60->(MsSeek(xFilial("U60") + cFormPag))

				oRest := FWRest():New(Self:cApiVindi)

				// defino o timeout da conexao
				oRest:nTimeOut := Self:nTimeOut

				// informo o path do metodo
				oRest:SetPath(Self:cPathPerfil)

				cJsonEnvio := ' { '
				cJsonEnvio += '   "holder_name": "' 			+ AllTrim(cNome) 						+ '", '
				cJsonEnvio += '   "card_expiration": "' 		+ Transform(cValidade, "@R 99/9999") 	+ '", '
				cJsonEnvio += '   "card_number": "' 			+ AllTrim(cNumCartao) 					+ '", '
				cJsonEnvio += '   "card_cvv": "' 				+ AllTrim(cCVV) 						+ '", '
				cJsonEnvio += '   "payment_method_code": "' 	+ AllTrim(U60->U60_CODIGO) 				+ '", '
				cJsonEnvio += '   "payment_company_code": "' 	+ cBandeira 							+ '", '
				cJsonEnvio += '   "customer_id": '				+ AllTrim(U61->U61_CODIGO)
				cJsonEnvio += ' } '

				// seto a string Json
				oRest:SetPostParams(cJsonEnvio)

				lRet := oRest:Post(Self:aHeadOut)

				// pego o retorno da API
				cJsonRetorno := oRest:GetResult()

				// converto a string JSON
				if FWJsonDeserialize(cJsonRetorno,@oJson)

					cCodRet			:= oRest:oResponseh:cStatusCode
					cDescRetorno	:= oRest:oResponseh:cReason
					cDadosRetorno	:= cJsonRetorno

					// se a comunicacao REST ocorreu
					If lRet

						cCodVindi 		:= cValToChar(oJson:Payment_Profile:Id)
						//cToken 		:= oJson:Payment_Profile:Token
						cToken 			:= oJson:Payment_Profile:Gateway_Token

						if !Empty(cCodVindi)

							aadd(aDadosProc , "C"			) // Status
							aadd(aDadosProc , cJsonEnvio	) // Json Envio
							aadd(aDadosProc , cDadosRetorno	) // Json Retorno
							aadd(aDadosProc , cCodRet		) // Codigo do retorno
							aadd(aDadosProc , cDescRetorno	) // Descrição do retorno

							Self:IncluiTabEnvio(cCodModulo,"2","I",1,cFilialCtr + cContrato + SA1->A1_COD + SA1->A1_LOJA,;
								aDadosProc, cOrigem, cOrigemDesc)

						else
							cErro := "O codigo do Perfil do Cliente na Vindi esta vazio!"
						endif

					else

						if AT('"parameter"',cJsonRetorno)
							cErro := OemToAnsi(oJson:ERRORS[1]:PARAMETER + ": " + oJson:ERRORS[1]:MESSAGE)
						endif

					endif

				else
					cErro 			:= "Erro Vindi - Estrutura do retorno do Perfil inválida!"
					cDadosRetorno	:= cJsonRetorno
				endif

			else
				cErro := "Metodo de pagamento da Vindi nao encontrado!"
			endif

		else
			cErro := "Cliente nao cadastrado na Vindi!"
		endif

	else
		cErro := "Não foi possível localizar o cadastro do Cliente!"
	endif

	// se tem mensagem de erro
	if !Empty(cErro)

		FwLogMsg("ERROR", , "REST", FunName(), "", "01", cErro, 0, (Seconds() - nStart), {})
		lRet := .F.

	endif

	RestArea(aArea)
	RestArea(aAreaSA1)
	RestArea(aAreaU61)
	RestArea(aAreaU60)

Return(lRet)

/*/{Protheus.doc} IntegraVindi::IncluiFatura
Metodo que inclui a Fatura na Vindi
@type method
@version 1.0
@author Wellington Gonçalves
@since 14/02/2019
@param cCodModulo, character, cCodModulo
@param cErro, character, cErro
@param cJsonEnvio, character, cJsonEnvio
@param cCodRet, character, cCodRet
@param cDescRetorno, character, cDescRetorno
@param cDadosRetorno, character, cDadosRetorno
@param nIndice, numeric, nIndice
@param cChave, character, cChave
@param lFatAvulsa, logical, Fatura avulsa sem vinculo com perfil de pagamento
@return logical, lRet
@obs Refatoracao - Marcos Nata Santos
/*/
Method IncluiFatura(cCodModulo,cErro,cJsonEnvio,cCodRet,cDescRetorno,cDadosRetorno,nIndice,cChave,lFatAvulsa,nQtdParcelas) Class IntegraVindi

	Local oRest			:= NIL
	Local oJson			:= NIL
	Local lRet			:= .T.
	Local aArea			:= GetArea()
	Local aAreaSE1		:= SE1->( GetArea() )
	Local aAreaSA1		:= SA1->( GetArea() )
	Local aAreaU61		:= U61->( GetArea() )
	Local aAreaU60		:= U60->( GetArea() )
	Local aAreaU64		:= U64->( GetArea() )
	Local aAreaU65		:= U65->( GetArea() )
	Local cJsonRetorno	:= ""
	Local cCodVindi		:= ""
	Local cIdCliVindi	:= ""
	Local cMedotoPag	:= ""
	Local cDtCob		:= ""
	Local cIdPerfil		:= ""
	Local cCodigoFat	:= ""
	Local cCode			:= ""
	Local cContrato		:= ""
	Local nAbatimento	:= 0
	Local nValor		:= 0
	Local nStart		:= Seconds()

	Default lFatAvulsa		:= .F.
	Default nQtdParcelas	:= 1

	FwLogMsg("INFO", , "REST", FunName(), "", "01","VINDI - Inclusao da Fatura", 0, (Seconds() - nStart), {})

	// posiciono no título a receber
	SE1->(DbSetOrder(nIndice)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	if SE1->(MsSeek(cChave))

		//Valido se o titulo nao esta marcado como adiantamento ou tem saldo
		If Empty(SE1->E1_XPGTMOB) .AND. SE1->E1_SALDO > 0

			// posiciono no cliente
			SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD
			if SA1->(MsSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))

				if cCodModulo == "F"
					cContrato		:= SE1->E1_XCTRFUN
				else
					cContrato		:= SE1->E1_XCONTRA
				endif

				// posiciono no cliente da vindi
				U61->(DbSetOrder(1)) // U61_FILIAL + U61_CONTRA + U61_CLIENT + U61_LOJA + U61_STATUS
				if U61->(MsSeek(xFilial("U61") + cContrato + SE1->E1_CLIENTE + SE1->E1_LOJA + "A"))

					// posiciono no metodo de pagamento da vindi
					U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
					if U60->(MsSeek(xFilial("U60") + SE1->E1_XFORPG))

						// posiciono no perfil de pagamento do cliente vindi
						U64->(DbSetOrder(2)) // U64_FILIAL + U64_CONTRA + U64_CLIENT + U64_LOJA + U64_STATUS
						if lFatAvulsa .Or.;
								U64->(MsSeek(xFilial("U64") + cContrato + SE1->E1_CLIENTE + SE1->E1_LOJA + "A"))

							cIdCliVindi := AllTrim(U61->U61_CODIGO)
							cMedotoPag	:= AllTrim(U60->U60_CODIGO)
							cDtCob 		:= StrZero(Year(SE1->E1_VENCTO),4) + "-" + StrZero(Month(SE1->E1_VENCTO),2) + "-" + StrZero(Day(SE1->E1_VENCTO),2)

							//valido se data de vencimento é menor que data atual
							//para nao dar erro de rejeicao da vindi.
							if SE1->E1_VENCTO < dDataBase

								cDtCob := StrZero(Year(dDataBase),4) + "-" + StrZero(Month(dDataBase),2) + "-" + StrZero(Day(dDataBase),2)

							Endif

							if !lFatAvulsa
								cIdPerfil	:= AllTrim(U64->U64_CODVIN)
							endif

							nAbatimento	:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

							// pego o próximo código da tabela
							cCodigoFat := NextU65(Self:cCodFaturaUso)

							U65->(DbSetOrder(3)) // U65_FILIAL + U65_CODIGO
							While U65->(MsSeek(xFilial("U65") + cCodigoFat))
								cCodigoFat := Soma1(cCodigoFat)
							EndDo

							cCode := xFilial("U65") + cCodigoFat

							ConOut("========================")
							ConOut("Codigo Fatura: " + cCode)
							ConOut("========================")

							// se saldo > 0, considero o saldo, caso contrario, considero o valor total
							if SE1->E1_SALDO > 0
								nValor := SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE - nAbatimento
							else
								nValor := SE1->E1_VALOR + SE1->E1_ACRESC - SE1->E1_DECRESC - nAbatimento
							endif

							oRest := FWRest():New(Self:cApiVindi)

							// defino o timeout da conexao
							oRest:nTimeOut := Self:nTimeOut

							// informo o path do metodo
							oRest:SetPath(Self:cPathFatura)

							cJsonEnvio := ' { '
							cJsonEnvio += '   "customer_id": ' 				+ cIdCliVindi 		+ ', '
							cJsonEnvio += '   "code": "' 					+ cCode 			+ '", '
							cJsonEnvio += '   "installments": "'			+ cValToChar(nQtdParcelas)		+ '", '
							cJsonEnvio += '   "payment_method_code": "' 	+ cMedotoPag 		+ '", '

							if !lFatAvulsa
								cJsonEnvio += '   "billing_at": "' 				+ cDtCob 			+ '", '
							endif
							cJsonEnvio += '   "due_at": "' 					+ cDtCob 			+ '", '

							//caso seja geracao de link de pagamento, nao envia perfil de pagamento
							if !lFatAvulsa
								cJsonEnvio += '   "payment_profile": { '
								cJsonEnvio += ' 		"id": ' 				+ cIdPerfil
								cJsonEnvio += '   }, '
							endif
							cJsonEnvio += '   "bill_items": '
							cJsonEnvio += '     [ '
							cJsonEnvio += '     	{ '
							cJsonEnvio += '     		"product_id": ' 	+ Self:cProdVindi + ', '
							cJsonEnvio += ' 			"amount": ' 		+ cValTochar(nValor)
							cJsonEnvio += '     	} '
							cJsonEnvio += '     ] '
							cJsonEnvio += ' } '

							// seto a string Json
							oRest:SetPostParams(cJsonEnvio)

							lRet := oRest:Post(Self:aHeadOut)

							// pego o retorno da API
							cJsonRetorno := oRest:GetResult()

							// converto a string JSON
							if FWJsonDeserialize(cJsonRetorno,@oJson)

								cCodRet			:= oRest:oResponseh:cStatusCode
								cDescRetorno	:= oRest:oResponseh:cReason
								cDadosRetorno	:= cJsonRetorno

								// se a comunicacao REST ocorreu
								If lRet

									cCodVindi := cValToChar(oJson:Bill:Id)

									if !Empty(cCodVindi)

										// cria cliente Vindi no Protheus
										if RecLock("U65",.T.)

											U65->U65_FILIAL := xFilial("U65")
											U65->U65_CODIGO := cCodigoFat
											U65->U65_CONTRA := cContrato
											U65->U65_PREFIX := SE1->E1_PREFIXO
											U65->U65_NUM	:= SE1->E1_NUM
											U65->U65_PARCEL	:= SE1->E1_PARCELA
											U65->U65_TIPO	:= SE1->E1_TIPO
											U65->U65_CLIENT	:= SE1->E1_CLIENTE
											U65->U65_LOJA	:= SE1->E1_LOJA
											U65->U65_DATA	:= dDataBase
											U65->U65_HORA	:= SubStr(Time(),1,5)
											U65->U65_CODVIN	:= cCodVindi
											U65->U65_STATUS	:= "A"
											U65->U65_MSFIL	:= cFilAnt

											U65->(MsUnLock())

											// confirmo o controle de numeração
											U65->(ConfirmSX8())

										endif

									else
										U65->(RollbackSx8())
										cErro := "Erro Vindi - Não foi retornado o código do Cliente!"
									endif

								else
									U65->(RollbackSx8())

									if AT('"parameter"',cJsonRetorno)
										cErro := oJson:ERRORS[1]:PARAMETER + ": " + oJson:ERRORS[1]:MESSAGE

										If "code" $ AllTrim(oJson:ERRORS[1]:PARAMETER)
											Self:cCodFaturaUso := cCodigoFat
										EndIf
									else
										cErro := "Erro nao foi possivel realizar conexao com a Vindi"
									endif

								endif

							else
								U65->(RollbackSx8())
								cErro 			:= "Erro Vindi - Estrutura do retorno inválida!"
								cDadosRetorno	:= cJsonRetorno
							endif

						else
							cErro := "Não foi possível localizar o Perfil de Pagamento do Cliente Vindi!"
						endif

					else
						cErro := "Não foi possível localizar o Método de Pagamento da Vindi!"
					endif

				else
					cErro := "Não foi possível localizar o cadastro do Cliente da Vindi!"
				endif

			else
				cErro := "Não foi possível localizar o cadastro do Cliente!"
			endif
		Else
			cDescRetorno := "Pagamento pelo MOBILE VIRTUS"
		Endif
	else
		cErro := "Não foi possível localizar o Título a Receber!"
	endif

	// se tem mensagem de erro
	if !Empty(cErro)

		FwLogMsg("ERROR", , "REST", FunName(), "", "01", cErro, 0, (Seconds() - nStart), {})
		lRet := .F.

	endif

	RestArea(aArea)
	RestArea(aAreaSE1)
	RestArea(aAreaSA1)
	RestArea(aAreaU61)
	RestArea(aAreaU60)
	RestArea(aAreaU64)
	RestArea(aAreaU65)

Return(lRet)

/*/{Protheus.doc} IntegraVindi::ExcluiFatura
Metodo que exclui a Fatura na Vindi
@type method
@version 1.0
@author Wellington Gonçalves
@since 17/02/2019
@param cCodModulo, character, cCodModulo
@param cErro, character, cErro
@param cJsonEnvio, character, cJsonEnvio
@param cCodRet, character, cCodRet
@param cDescRetorno, character, cDescRetorno
@param cDadosRetorno, character, cDadosRetorno
@param nIndice, numeric, nIndice
@param cChave, character, cChave
@return logical, lRet
@obs Refatoracao - Marcos Nata Santos
/*/
Method ExcluiFatura(cCodModulo,cErro,cJsonEnvio,cCodRet,cDescRetorno,cDadosRetorno,nIndice,cChave) Class IntegraVindi

	Local oRest			:= NIL
	Local oJson			:= NIL
	Local lRet			:= .T.
	Local lExistClient	:= .F.
	Local lContinua		:= .T.
	Local aArea			:= GetArea()
	Local aAreaSA1		:= SA1->(GetArea())
	Local aAreaU65		:= U65->(GetArea())
	Local cJsonRetorno	:= ""
	Local cStatus		:= ""
	Local nTamChave		:= TamSX3("E1_FILIAL")[1] + TamSX3("E1_PREFIXO")[1] + TamSX3("E1_NUM")[1] + TamSX3("E1_PARCELA")[1] + TamSX3("E1_TIPO")[1]
	Local cNvChave		:= SubStr(cChave, 1, nTamChave) + "A"
	Local nStart		:= Seconds()
	Local cMessage		:= ""

	// posiciono na fatura da vindi
	U65->(DbSetOrder(1)) //-- U65_FILIAL+U65_PREFIX+U65_NUM+U65_PARCEL+U65_TIPO+U65_STATUS
	if U65->( MsSeek(cNvChave) )

		// posiciono no cliente da vindi
		U61->(DbSetOrder(1)) // U61_FILIAL + U61_CONTRA + U61_CLIENT + U61_LOJA + U61_STATUS
		if U61->( MsSeek( xFilial("U61") + U65->U65_CONTRA + U65->U65_CLIENT + AllTrim(U65->U65_LOJA) ) )

			if U61->U61_STATUS == "A"
				lExistClient := .T.
			endif

		endif

		if lExistClient

			/////////////////////////////////////////////////////////////////////////
			//Verifico status da fatura antes do envio de arquivamento
			/////////////////////////////////////////////////////////////////////////

			cStatus := ::ConsultaFatura(cCodModulo,@cErro,@cJsonEnvio,@cCodRet,@cDescRetorno,@cDadosRetorno)

			//Valido retorno para Vindi
			if cStatus == "paid" // se pago na Vindi fatura nao pode ser arquivada
				cErro := ""
				lContinua := .F.
				cDescRetorno := "Fatura nao pode ser arquivada na Vindi porque ja esta com status de Paid!"
				cMessage := "Fatura Chave "+ cChave +" nao pode ser arquivada na Vindi porque ja esta com status de Paid!"
				FwLogMsg("ERROR", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
			elseif cStatus == "canceled"
				cErro := ""
				lContinua := .F.
				cDescRetorno := "Fatura nao pode ser arquivada na Vindi porque ja esta com status de Canceled!"
				cMessage := "Fatura Chave "+ cChave +" nao pode ser arquivada na Vindi porque ja esta com status de Canceled!"
				FwLogMsg("ERROR", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
			endif

			//Valido se processo de arquivamento continua
			If lContinua

				oRest := FWRest():New(Self:cApiVindi)

				// defino o timeout da conexao
				oRest:nTimeOut := Self:nTimeOut

				cJsonEnvio := AllTrim(U65->U65_CODVIN)

				// informo o path do metodo
				oRest:SetPath(Self:cPathFatura + "/" + cJsonEnvio)

				// envio o comando de delete
				lRet := oRest:Delete(Self:aHeadOut)

				// pego o retorno da API
				cJsonRetorno := oRest:GetResult()

				// converto a string JSON
				if FWJsonDeserialize(cJsonRetorno,@oJson)

					cCodRet			:= oRest:oResponseh:cStatusCode
					cDescRetorno	:= oRest:oResponseh:cReason
					cDadosRetorno	:= cJsonRetorno

					// se a comunicacao REST ocorreu
					If lRet

						// inativa o cliente Vindi no Protheus
						if RecLock("U65",.F.)

							U65->U65_STATUS := "I"
							U65->(MsUnLock())

						endif

					else

						if AT('"parameter"',cJsonRetorno)
							cErro := oJson:ERRORS[1]:PARAMETER + ": " + oJson:ERRORS[1]:MESSAGE
						endif

					endif

				else
					cErro 			:= "Erro Vindi - Estrutura do retorno inválida!"
					cDadosRetorno	:= cJsonRetorno
				endif
			endif
		else
			//Consulto status da fatura na VINDI
			cStatus := ::ConsultaFatura(cCodModulo,@cErro,@cJsonEnvio,@cCodRet,@cDescRetorno,@cDadosRetorno)

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

			cDescRetorno := "Cliente arquivado na VINDI! Arquivamento ja exclui suas faturas!"
		endif

	else
		cErro := "Não foi possível localizar a Fatura do Cliente Vindi!"
	endif

	// se tem mensagem de erro
	if !Empty(cErro)
		lRet := .F.
	endif

	RestArea(aAreaSA1)
	RestArea(aAreaU65)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} IntegraVindi::AlteraFatura
Metodo para alteracao de fatura na VINDI
Altera apenas perfil de pagamento da fatura
@type method
@version 1.0
@author nata.queiroz
@since 23/09/2020
@param cCodModulo, character, cCodModulo
@param cErro, character, cErro
@param cJsonEnvio, character, cJsonEnvio
@param cCodRet, character, cCodRet
@param cDescRetorno, character, cDescRetorno
@param cDadosRetorno, character, cDadosRetorno
@param nIndice, numeric, nIndice
@param cChave, character, cChave
@return logical, lRet
/*/
Method AlteraFatura(cCodModulo,cErro,cJsonEnvio,cCodRet,cDescRetorno,cDadosRetorno,nIndice,cChave) Class IntegraVindi

	Local oRest			:= NIL
	Local oJson			:= NIL
	Local lRet			:= .T.
	Local lExistClient	:= .F.
	Local lContinua		:= .T.
	Local aArea			:= GetArea()
	Local aAreaU65		:= U65->(GetArea())
	Local aAreaU61		:= U61->(GetArea())
	Local aAreaU64		:= U64->(GetArea())
	Local cJsonRetorno	:= ""
	Local cStatus		:= ""
	Local nTamChave		:= TamSX3("E1_FILIAL")[1] + TamSX3("E1_PREFIXO")[1] + TamSX3("E1_NUM")[1] + TamSX3("E1_PARCELA")[1] + TamSX3("E1_TIPO")[1]
	Local cNvChave		:= SubStr(cChave, 1, nTamChave) + "A"
	Local nStart		:= Seconds()
	Local cMessage		:= ""
	Local cIdPerfil		:= ""
	Local cPayLoad		:= ""

	// Fatura da Vindi
	U65->(DbSetOrder(1)) //-- U65_FILIAL+U65_PREFIX+U65_NUM+U65_PARCEL+U65_TIPO+U65_STATUS
	if U65->( MsSeek(cNvChave) )

		// Cliente da vindi
		U61->(DbSetOrder(1)) // U61_FILIAL + U61_CONTRA + U61_CLIENT + U61_LOJA
		if U61->(MsSeek( xFilial("U61") + U65->U65_CONTRA + U65->U65_CLIENT + AllTrim(U65->U65_LOJA) ))

			if U61->U61_STATUS == "A"
				lExistClient := .T.
			endif

		endif

		if lExistClient

			// Verifico status da fatura antes do envio de arquivamento
			cStatus := ::ConsultaFatura(cCodModulo,@cErro,@cJsonEnvio,@cCodRet,@cDescRetorno,@cDadosRetorno)

			// Valido retorno Vindi
			if cStatus == "paid"
				cErro := ""
				lContinua := .F.
				cDescRetorno := "Fatura nao pode ser alterada na Vindi porque ja esta com status de Paid!"
				cMessage := "Fatura Chave "+ cChave +" nao pode ser alterada na Vindi porque ja esta com status de Paid!"
				FwLogMsg("ERROR", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
			elseif cStatus == "canceled"
				cErro := ""
				lContinua := .F.
				cDescRetorno := "Fatura nao pode ser alterada na Vindi porque ja esta com status de Canceled!"
				cMessage := "Fatura Chave "+ cChave +" nao pode ser alterada na Vindi porque ja esta com status de Canceled!"
				FwLogMsg("ERROR", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
			endif

			If lContinua

				// Perfil de pagamento do cliente Vindi
				U64->(DbSetOrder(2)) // U64_FILIAL + U64_CONTRA + U64_CLIENT + U64_LOJA + U64_STATUS
				If U64->(MsSeek(xFilial("U64") + U65->U65_CONTRA + U65->U65_CLIENT + SubStr(U65->U65_LOJA, 1, TamSX3("U64_LOJA")[1]) + "A"))

					cJsonEnvio := AllTrim(U65->U65_CODVIN)
					cIdPerfil := AllTrim(U64->U64_CODVIN)

					cPayLoad := '{'
					cPayLoad += '   "payment_profile": { '
					cPayLoad += ' 		"id": ' + cIdPerfil
					cPayLoad += '   } '
					cPayLoad += '}'

					oRest := FWRest():New(Self:cApiVindi)

					// defino o timeout da conexao
					oRest:nTimeOut := Self:nTimeOut

					// informo o path do metodo
					oRest:SetPath(Self:cPathFatura + "/" + cJsonEnvio)

					// envio o comando de update
					lRet := oRest:Put(Self:aHeadOut, cPayLoad)

					// pego o retorno da API
					cJsonRetorno := oRest:GetResult()

					// converto a string JSON
					if FWJsonDeserialize(cJsonRetorno, @oJson)

						cCodRet			:= oRest:oResponseh:cStatusCode
						cDescRetorno	:= oRest:oResponseh:cReason
						cDadosRetorno	:= cJsonRetorno

						If !lRet

							if AT('"parameter"',cJsonRetorno)
								cErro := oJson:ERRORS[1]:PARAMETER + ": " + oJson:ERRORS[1]:MESSAGE
							endif

						endif

					else
						cErro 			:= "Erro Vindi - Estrutura do retorno inválida!"
						cDadosRetorno	:= cJsonRetorno
					endif

				Else
					cErro := "Não foi possível localizar o Perfil de Pagamento Vindi!"
				EndIf

			EndIf

		Else

			//Consulto status da fatura na VINDI
			cStatus := ::ConsultaFatura(cCodModulo,@cErro,@cJsonEnvio,@cCodRet,@cDescRetorno,@cDadosRetorno)

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

			cDescRetorno := "Cliente arquivado na VINDI! Arquivamento ja exclui suas faturas!"
		EndIf

	else
		cErro := "Não foi possível localizar a Fatura do Cliente Vindi!"
	endif

	// Se tem mensagem de erro
	if !Empty(cErro)
		lRet := .F.
	endif

	RestArea(aArea)
	RestArea(aAreaU65)
	RestArea(aAreaU61)
	RestArea(aAreaU64)

Return lRet

/*/{Protheus.doc} IntegraVindi::IncluiTabReceb
Método que inclui registro na tabela de recebimento
@type method
@version 1.0
@author Wellington Gonçalves
@since 06/03/2019
@param cCodModulo, character, cCodModulo
@param cTipoIntegracao, character, cTipoIntegracao
@param cJson, character, cJson
@obs Refatoracao - Marcos Nata Santos
/*/
Method IncluiTabReceb(cCodModulo,cTipoIntegracao,cJson) Class IntegraVindi

	Local aArea 		:= GetArea()
	Local aAreaU63		:= U63->(GetArea())
	Local cCodigo 		:= ""
	Local cIdVindi		:= ""
	Local oJson			:= Nil
	Local nStart		:= Seconds()
	Local cMessage		:= ""

	Default cJson := ""

	//-- Verifica codigo da fatura no json recebido
	If ExistCodFat(cJson)

		//--Id Vindi --//
		If FWJsonDeserialize(cJson, @oJson)
			If AttIsMemberOf(oJson , "event")
				If oJson:event:type == "bill_paid" // Pagamento
					cIdVindi := cValToChar(oJson:event:data:bill:id)
				ElseIf oJson:event:type == "charge_refunded" // Estorno
					cIdVindi := cValToChar(oJson:event:data:charge:bill:id)
				EndIf
			Else
				If oJson:bill:status == "paid"
					cIdVindi := cValToChar(oJson:bill:id)
				EndIf
			EndIf
		EndIf

		// pego o proximo codigo da tabela
		cCodigo := GetSxeNum("U63","U63_CODIGO")

		U63->(DbSetOrder(1)) // U65_FILIAL + U63_CODIGO
		While U63->(MsSeek(xFilial("U63") + cCodigo))
			U63->(ConfirmSX8())
			cCodigo := GetSxeNum("U63","U63_CODIGO")
		EndDo

		If RecLock("U63",.T.)

			U63->U63_FILIAL := xFilial("U63")
			U63->U63_CODIGO	:= cCodigo
			U63->U63_MODULO	:= cCodModulo
			U63->U63_DTINC	:= dDataBase
			U63->U63_HRINC	:= SubStr(Time(),1,5)
			U63->U63_DTPROC	:= CTOD("  /  /    ")
			U63->U63_HRPROC	:= ""
			U63->U63_ENT	:= cTipoIntegracao // 1=Pagamento;2=Estorno;3=Tentativa;4=Teste
			U63->U63_IDVIND := cIdVindi
			U63->U63_STATUS	:= "P"
			U63->U63_MSREC	:= cJson
			U63->U63_MSFIL	:= cFilAnt

			U63->(MsUnLock())

			// confirmo o controle de numeraçao
			U63->(ConfirmSX8())

			cMessage := "[UVIND06 - IncluiTabReceb]"
			FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
			cMessage := "Recebimento gravado com sucesso!"
			FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

		EndIf

		FreeObj(oJson)

	EndIf

	RestArea(aAreaU63)
	RestArea(aArea)

Return()

/*/{Protheus.doc} IntegraVindi::CliOnline
Método para envio Online de Clientes a Vindi
@type method
@version 1.0
@author Wellington Gonçalves
@since 19/02/2019
@param cOperacao, character, cOperacao
@param cCodModulo, character, cCodModulo
@param cErro, character, cErro
@param cOrigem, character, cOrigem
@param cOrigemDesc, character, cOrigemDesc
@return logical, lRet
@obs Refatoracao - Marcos Nata Santos
/*/
Method CliOnline(cOperacao,cCodModulo,cErro,cOrigem,cOrigemDesc) Class IntegraVindi

	Local aDadosProc	:= {}
	Local cJsonEnvio	:= ""
	Local cCodRet		:= ""
	Local cDescRetorno	:= ""
	Local cDadosRetorno	:= ""
	Local cChaveCliente	:= ""
	Local cStatus		:= ""
	Local cContrato		:= ""
	Local lRet			:= .T.
	Local lUsaMsfil		:= SuperGetMV("MV_XVMSFIL", .F., .T.)	// parametro determinar se usa o UF2_MSFIL(.T.) ou UF2_FILIAL(.F.)
	Local cIdMobile		:= ""
	Local nStart		:= Seconds()

	Default cOrigem := "UVIND06"
	Default cOrigemDesc := "IntegraVindi CliOnline"

	if cCodModulo == "F" // funeraria e planos

		//Valido se é transferencia de titular
		if IsInCallStack("U_RFUNA006")

			If cOperacao == "E"

				cChave 			:= U61->U61_FILIAL + U61->U61_CLIENT + U61->U61_LOJA
				cChaveCliente 	:= U61->U61_CLIENT + U61->U61_LOJA
			else

				if lUsaMsfil
					cChave 			:= M->UF2_MSFIL + M->UF2_CLIENT + M->UF2_LOJA
				else
					cChave 			:= M->UF2_FILIAL + M->UF2_CLIENT + M->UF2_LOJA
				endIf

				cChaveCliente 	:= M->UF2_CLIENT + M->UF2_LOJA

			Endif

			cContrato			:=  UF2->UF2_CODIGO

		else

			if lUsaMsfil
				cChave 			:= UF2->UF2_MSFIL + UF2->UF2_CLIENT + UF2->UF2_LOJA
			else
				cChave 			:= UF2->UF2_FILIAL + UF2->UF2_CLIENT + UF2->UF2_LOJA
			endIf

			cChaveCliente 	:= UF2->UF2_CLIENT + UF2->UF2_LOJA
			cContrato		:= UF2->UF2_CODIGO

		endif

		cIdMobile		:= UF2->UF2_IDMOBI

	elseIf cCodModulo == "C" // cemiterio

		if lUsaMsfil
			cChave 			:= U00->U00_MSFIL + U00->U00_CLIENT + U00->U00_LOJA
		else
			cChave 			:= U00->U00_FILIAL + U00->U00_CLIENT + U00->U00_LOJA
		endIf

		cChaveCliente 	:= U00->U00_CLIENT + U00->U00_LOJA
		cContrato		:= U00->U00_CODIGO

	endif

	// verifico se foram preenchidas as variaveis para integracao VINDI
	if !Empty(cChave) .And. !Empty(cChaveCliente) .And. !Empty(cContrato)

		if cOperacao == "I"

			//chamo metodo para checar cliente na vindi
			cStatus := Self:ConsultaCliente(cChaveCliente,@cErro,cContrato,cIdMobile)

			//Se cliente estiver arquivado
			if cStatus == "archived"

				lRet := Self:UndelCliente(cCodModulo,@cErro,@cJsonEnvio,@cCodRet,@cDescRetorno,@cDadosRetorno,3,cChave,cContrato)
			Endif

			if Empty(cStatus)

				lRet := Self:IncluiCliente(cCodModulo,@cErro,@cJsonEnvio,@cCodRet,@cDescRetorno,@cDadosRetorno,cOrigem,cOrigemDesc,cStatus)
			Endif

		elseif cOperacao == "A"
			lRet := Self:AlteraCliente(cCodModulo,@cErro,@cJsonEnvio,@cCodRet,@cDescRetorno,@cDadosRetorno,3,cChave)
		elseif cOperacao == "E"
			lRet := Self:ExcluiCliente(cCodModulo,@cErro,@cJsonEnvio,@cCodRet,@cDescRetorno,@cDadosRetorno,3,cChave)
		elseif cOperacao == "D"
			lRet := Self:UndelCliente(cCodModulo,@cErro,@cJsonEnvio,@cCodRet,@cDescRetorno,@cDadosRetorno,3,cChave,cContrato)
		endif

		if lRet

			if !Empty(cJsonEnvio)

				aadd(aDadosProc , "C"			) // Status
				aadd(aDadosProc , cJsonEnvio	) // Json Envio
				aadd(aDadosProc , cDadosRetorno	) // Json Retorno
				aadd(aDadosProc , cCodRet		) // Codigo do retorno
				aadd(aDadosProc , cDescRetorno	) // Descrição do retorno

				Self:IncluiTabEnvio(cCodModulo,"1",cOperacao,3,cChave,aDadosProc,cOrigem,cOrigemDesc)

			endif

		else
			FwLogMsg("ERROR", , "REST", FunName(), "", "01", cErro, 0, (Seconds() - nStart), {})
		endif

	else

		lRet := .F.
		FwLogMsg("ERROR", , "REST", FunName(), "", "01", "Chave, Chave do Cliente ou Contrato não foram informados corretamente!", 0, (Seconds() - nStart), {})

	endIf

Return(lRet)

/*/{Protheus.doc} IntegraVindi::ProcRecebi
Metodo que processa os registros pendentes de recebimento
@type method
@version 1.0
@author Wellington Gonçalves
@since 09/03/2019
@param cContrato, character, cContrato
@obs Refatoracao - Marcos Nata Santos
/*/
Method ProcRecebi(cContrato) Class IntegraVindi

	Local aArea 			:= GetArea()
	Local aAreaU63			:= U63->(GetArea())
	Local cQry				:= ""
	Local cErro				:= ""
	Local cMsgSucesso		:= "Registro processado com sucesso!"
	Local lProcessa			:= .T.
	Local cJsonRetorno		:= ""
	Local nQtdDiaVindi		:= SuperGetMv("MV_XQTDDVI", .F., 60) // Qtd de dias anterior na consulta
	Local cMesVindi			:= DTOS( DaySub(dDatabase, nQtdDiaVindi) )

	Default cContrato := ""

	// verifico se nao existe este alias criado
	If Select("QRYU63") > 0
		QRYU63->(DbCloseArea())
	EndIf

	If !Empty(cContrato)

		cQry := "SELECT "
		cQry += "U63.U63_FILIAL AS FILIAL_INTEGRACAO, "
		cQry += "U63.U63_CODIGO AS CODIGO_INTEGRACAO, "
		cQry += "U63.U63_MODULO AS CODIGO_MODULO, "
		cQry += "U63.U63_DTINC AS DATA_INCLUSAO, "
		cQry += "U63.U63_HRINC AS HORA_INCLUSAO, "
		cQry += "U63.U63_ENT AS ENTIDADE "
		cQry += "FROM "+ RetSqlName("U63") +" U63 "
		cQry += "INNER JOIN "+ RetSqlName("U65") +" U65 "
		cQry += "ON U65.D_E_L_E_T_ <> '*' "
		cQry += "AND U65.U65_FILIAL = U63.U63_FILIAL "
		cQry += "AND U65.U65_CODVIN = U63.U63_IDVIND "
		cQry += "WHERE U63.D_E_L_E_T_ <> '*' "
		cQry += "AND U63.U63_FILIAL = '"+ xFilial("U63") +"' "
		cQry += "AND U63.U63_MSFIL = '"+ cFilAnt +"' "
		cQry += "AND U63.U63_STATUS <> 'C' "
		cQry += "AND U65.U65_CONTRA = '"+ AllTrim(cContrato) +"' "

	Else

		cQry := "SELECT "
		cQry += "U63.U63_FILIAL AS FILIAL_INTEGRACAO, "
		cQry += "U63.U63_CODIGO AS CODIGO_INTEGRACAO, "
		cQry += "U63.U63_MODULO AS CODIGO_MODULO, "
		cQry += "U63.U63_DTINC AS DATA_INCLUSAO, "
		cQry += "U63.U63_HRINC AS HORA_INCLUSAO, "
		cQry += "U63.U63_ENT AS ENTIDADE "
		cQry += "FROM "+ RetSqlName("U63") +" U63 "
		cQry += "WHERE U63.D_E_L_E_T_ <> '*' "
		cQry += "AND U63.U63_FILIAL = '" + xFilial("U63") + "' "
		cQry += "AND U63.U63_MSFIL =  '" + cFilAnt  + "' "
		cQry += "AND U63.U63_STATUS <> 'C' "
		cQry += "AND U63.U63_DTINC >= '"+ cMesVindi +"' "
		cQry += "ORDER BY U63.U63_DTINC , U63.U63_HRINC , U63.U63_CODIGO "

	EndIf

	// funcao que converte a query generica para o protheus
	cQry := ChangeQuery(cQry)

	// crio o alias temporario
	MPSysOpenQuery(cQry, "QRYU63")// Cria uma nova area com o resultado do query

	if QRYU63->(!Eof())

		While QRYU63->(!Eof())

			cErro 		:= ""
			lProcessa	:= .T.
			cJsonRetorno := ""

			U63->(DbSetOrder(1)) // U63_FILIAL + U63_CODIGO
			if U63->(MsSeek(QRYU63->FILIAL_INTEGRACAO + QRYU63->CODIGO_INTEGRACAO))

				if QRYU63->ENTIDADE == "1" // Pagamento

					::PagarFatura(U63->U63_FILIAL,U63->U63_MODULO,U63->U63_MSREC,@cErro,@lProcessa)

				elseif QRYU63->ENTIDADE == "2" // Estorno

					::EstornarFatura(U63->U63_FILIAL,U63->U63_MODULO,U63->U63_MSREC,@cErro)

				elseif QRYU63->ENTIDADE == "3" // Tentativa

					::GravarTentativa(U63->U63_FILIAL,U63->U63_MODULO,U63->U63_MSREC,@cErro)

				else
					lProcessa := .F.
				endif

				if lProcessa

					if RecLock("U63",.F.)

						U63->U63_DTPROC := dDataBase
						U63->U63_HRPROC := SubStr(Time(),1,5)
						U63->U63_STATUS := iif(Empty(cErro),"C","E")
						U63->U63_MSPROC	:= iif(Empty(cErro),cMsgSucesso,cErro)
						U63->(MsUnLock())

					endif

				endif

				// Pagamento com erro apos processamento
				// Atualiza dados, refazendo a busca da fatura na vindi
				If U63->U63_STATUS == "E" .And. U63->U63_ENT == "1"
					cJsonRetorno := ::BuscarFaturaPorId( U63->U63_IDVIND )

					If !Empty(cJsonRetorno)
						If RecLock("U63", .F.)
							U63->U63_MSREC := cJsonRetorno
							U63->(MsUnLock())
						EndIf
					EndIf
				EndIf

			endif

			QRYU63->(DbSkip())

		EndDo

	endif

	If Select("QRYU63") > 0
		QRYU63->(DbCloseArea())
	EndIf

	RestArea(aAreaU63)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} IntegraVindi::PagarFatura
Metodo que realiza o pagamento do título no Protheus
@type method
@version 1.0
@author Wellington Gonçalves
@since 09/03/2019
@param cFilialIntegracao, character, cFilialIntegracao
@param cCodModulo, character, cCodModulo
@param cJson, character, cJson
@param cErro, character, cErro
@param lProcessa, logical, lProcessa
@obs Refatoracao - Marcos Nata Santos
/*/
Method PagarFatura(cFilialIntegracao,cCodModulo,cJson,cErro,lProcessa) Class IntegraVindi

	Local aArea			:= GetArea()
	Local aAreaUJT		:= UJT->(GetArea())
	Local aAreaUJU		:= UJU->(GetArea())
	Local aAreaU65		:= U65->(GetArea())
	Local cCodFat		:= ""
	Local dDataPag		:= StoD("")
	Local nValRec		:= 0
	Local oJson			:= NIL
	Local cLoteBx		:= ""
	Local cCaixa		:= SuperGetMv("MV_XCXVIND")
	Local cCodAdm		:= ""
	Local cFormaPgto	:= SuperGetMv("MV_XFPGADQ",,"CC")
	Local cChaveSE1		:= ""
	Local cAdmVindi		:= ""
	Local cBandeira		:= ""
	Local cAutorizacao	:= ""
	Local cCodNsu		:= ""
	Local nQtdParc		:= 1
	Local lRet			:= .T.
	Local nStart		:= Seconds()

	// converto a string JSON
	if FWJsonDeserialize(cJson,@oJson)

		//////////////////////////////////////////////////////////////////////////////////////////
		///caso a U63 nao seja gerada a partir o Webhoock, nao possui a estrutura event e data///
		////////////////////////////////////////////////////////////////////////////////////////
		if AttIsMemberOf(oJson , "event")

			dDataPag 	:= CTOD(SubStr(oJson:event:created_at,9,2) + "/" + SubStr(oJson:event:created_at,6,2) + "/" + SubStr(oJson:event:created_at,1,4))
			cCodFat		:= cValToChar(oJson:event:data:bill:code)
			nValRec		:= Val(oJson:event:data:bill:amount)
			nQtdParc	:= oJson:event:data:bill:installments

			If Len(oJson:event:data:bill:charges) > 0
				cAdmVindi	:= cValToChar(oJson:event:data:bill:charges[1]:last_transaction:gateway:id)
				cBandeira	:= Alltrim(oJson:event:data:bill:charges[1]:last_transaction:payment_profile:payment_company:code)

				If AttIsMemberOf(oJson:event:data:bill:charges[1]:last_transaction:gateway_response_fields, "authorizationCode")
					cAutorizacao := AllTrim(oJson:event:data:bill:charges[1]:last_transaction:gateway_response_fields:authorizationCode)

					//tratativa para a adquirente stone
				elseif AttIsMemberOf(oJson:event:data:bill:charges[1]:last_transaction:gateway_response_fields, "stone_id_rcpt_tx_id")
					cAutorizacao := AllTrim(oJson:event:data:bill:charges[1]:last_transaction:gateway_response_fields:stone_id_rcpt_tx_id)

					//para stone o codigo do nsu sera o mesmo do codigo de autorizacao
					cCodNsu		 := cAutorizacao

				EndIf

			else
				//Valido se veio com valor zerado
				if nValRec == 0
					lRet := .F.
				endif
			endif

		else

			If AllTrim(oJson:bill:status) == "paid"
				dDataPag 	:= CTOD(SubStr(oJson:bill:charges[1]:paid_at,9,2) + "/" + SubStr(oJson:bill:charges[1]:paid_at,6,2) + "/" + SubStr(oJson:bill:charges[1]:paid_at,1,4))
				cCodFat		:= cValToChar(oJson:bill:code)
				nValRec		:= Val(oJson:bill:amount)
				nQtdParc	:= oJson:bill:installments

				If Len(oJson:bill:charges) > 0
					cAdmVindi	:= cValToChar(oJson:bill:charges[1]:last_transaction:gateway:id)
					cBandeira	:= Alltrim(oJson:bill:charges[1]:last_transaction:payment_profile:payment_company:code)

					If AttIsMemberOf(oJson:bill:charges[1]:last_transaction:gateway_response_fields, "authorizationCode")

						cAutorizacao := AllTrim(oJson:bill:charges[1]:last_transaction:gateway_response_fields:authorizationCode)

						//tratativa para a adquirente stone
					elseif AttIsMemberOf(oJson:bill:charges[1]:last_transaction:gateway_response_fields, "stone_id_rcpt_tx_id")

						cAutorizacao := AllTrim(oJson:bill:charges[1]:last_transaction:gateway_response_fields:stone_id_rcpt_tx_id)

						//para stone o codigo do nsu sera o mesmo do codigo de autorizacao
						cCodNsu		 := cAutorizacao

					EndIf

				else
					//Valido se veio com valor zerado
					if nValRec == 0
						lRet := .F.
					endif
				endif
			Else
				lRet := .F.
			EndIf

		endif

		//Valida se contina a execucao
		If lRet

			//Validio se caixa Vindi foi criado
			if !Empty(cCaixa)

				UJT->(DbSetOrder(2))
				UJU->(DbSetOrder(1))

				//Posiciono no cadastro da amarracao Gateway x Bandeira
				if UJT->(MsSeek(xFilial("UJT")+ PADR(cAdmVindi,TamSx3("UJT_IDVIND")[1] ) )) .AND. UJT->UJT_STATUS == "A"

					//Posiciona na bandeira da gateway
					if UJU->(MsSeek(xFilial("UJU")+UJT->UJT_CODIGO+UPPER(cBandeira)))

						SAE->(DbOrderNickName("IDVINDI"))

						//Posiciono na administradora financeira
						If SAE->(MsSeek(xFilial("SAE")+UJU->UJU_CODIGO+UJU->UJU_ITEM))

							cCodAdm := SAE->AE_COD

							//caso a U63 nao seja gerada a partir o Webhoock, nao possui a estrutura event e data
							if AttIsMemberOf(oJson , "event")

								//Valido se existe a tag nsu no retorno e pego nsu do pagamento
								if AT('"nsu"',cJson)

									cCodNsu		:= oJson:event:data:bill:charges[1]:last_transaction:gateway_response_fields:nsu

								elseif AT('"proof_of_sale"',cJson) //bandeira cielo utiliza proof_of_sale

									cCodNsu		:= oJson:event:data:bill:charges[1]:last_transaction:gateway_response_fields:proof_of_sale

								Endif

							else

								//Valido se existe a tag nsu no retorno e pego nsu do pagamento
								if AT('"nsu"',cJson)

									cCodNsu		:= oJson:bill:charges[1]:last_transaction:gateway_response_fields:nsu

								elseif AT('"proof_of_sale"',cJson) //bandeira cielo utiliza proof_of_sale

									cCodNsu		:= oJson:bill:charges[1]:last_transaction:gateway_response_fields:proof_of_sale

								Endif

							endif
							// se a fatura estiver preenchida e se pertence a filial logada
							if !Empty(cCodFat) .AND. SubStr(cCodFat,1,TamSx3("U65_FILIAL")[1]) == xFilial("U65")

								// posiciono na fatura da vindi
								U65->(DbSetOrder(3)) // U65_FILIAL + U65_CODIGO
								if U65->(MsSeek(cCodFat))

									cChaveSE1 := xFilial("U65") + U65->U65_PREFIX + U65->U65_NUM + U65->U65_PARCEL + U65->U65_TIPO

									// Inicio o controle de transação
									BEGIN TRANSACTION

										// função que realiza a baixa do titulo
										lRet := U_BxTitulosFin(cChaveSE1,cFormaPgto,dDataPag,nValRec,cCaixa,@cLoteBx,@cErro,@lProcessa,0,0,0)

										// se a baixa foi realizada com sucesso
										if lRet

											// função que inclui um título contra a administradora financeira
											// e caso necessário, inclui um contas a pagar para a administradora
											lRet := U_CriaTitAdmin(cFormaPgto,dDataPag,nValRec,cCaixa,cCodAdm,;
												cLoteBx,cCodModulo,U65->U65_CONTRA,@cErro,cCodNsu,cAutorizacao, nQtdParc)

										endif

										// caso estiver com algum problema, disfaco a transacao
										if !lRet
											DisarmTransaction()
										endif

									END TRANSACTION

								else
									cErro := "Fatura Vindi nao localizada"
								endif

							else
								cErro := "Codigo da fatura Vindi nao informado no Json"
							endif
						else
							cErro := "Adm Financeira para bandeira "+ cBandeira + " nao foi localizada"
							FwLogMsg("ERROR", , "REST", FunName(), "", "01", cErro, 0, (Seconds() - nStart), {})
						endif
					else

						cErro := "Bandeira "+ cBandeira + " nao foi localizada na amarracao Gateway x Bandeira"
						FwLogMsg("ERROR", , "REST", FunName(), "", "01", cErro, 0, (Seconds() - nStart), {})

					endif
				else

					cErro := "Codigo da Gateway Vindi "+ cAdmVindi + " nao foi encontrado na tabela UJT"
					FwLogMsg("ERROR", , "REST", FunName(), "", "01", cErro, 0, (Seconds() - nStart), {})

				endif
			else
				cErro := "Codigo do Caixa VINDI nao foi encontrado, verifique o parametro MV_XCXVIND"
				FwLogMsg("ERROR", , "REST", FunName(), "", "01", cErro, 0, (Seconds() - nStart), {})
			endif
		endif
	else
		cErro := "Json com erro de sintaxe"
	endif

	RestArea(aAreaUJT)
	RestArea(aAreaUJU)
	RestArea(aAreaU65)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} IntegraVindi::EstornarFatura
Metodo que realiza o estorno do título no Protheu
@type method
@version 1.0
@author Wellington Gonçalves
@since 09/03/2019
@param cFilialIntegracao, character, cFilialIntegracao
@param cCodModulo, character, cCodModulo
@param cJson, character, cJson
@param cErro, character, cErro
@obs Refatoracao - Marcos Nata Santos
/*/
Method EstornarFatura(cFilialIntegracao,cCodModulo,cJson,cErro) Class IntegraVindi

	Local aArea			:= GetArea()
	Local cCodFat		:= ""
	Local dDataEst		:= CTOD("  /  /    ")
	Local nValEst		:= 0
	Local oJson			:= NIL
	Local cChaveSE1		:= ""

	// converto a string JSON
	if FWJsonDeserialize(cJson,@oJson)

		//////////////////////////////////////////////////////////////////////////////////////////
		///caso a U63 nao seja gerada a partir o Webhoock, nao possui a estrutura event e data///
		////////////////////////////////////////////////////////////////////////////////////////
		If At("event", cJson) > 0
			dDataEst 	:= CTOD(SubStr(oJson:event:created_at,9,2) + "/" + SubStr(oJson:event:created_at,6,2) + "/" + SubStr(oJson:event:created_at,1,4))
			cCodFat		:= cValToChar(oJson:event:data:charge:bill:code)
			nValEst		:= Val(oJson:event:data:charge:amount)
		Else
			//-- Para processar estornor de titulos com data de baixas divergentes
			dDataEst 	:= CTOD(SubStr(oJson:bill:created_at,9,2) + "/" + SubStr(oJson:bill:created_at,6,2) + "/" + SubStr(oJson:bill:created_at,1,4))
			cCodFat		:= cValToChar(oJson:bill:code)
			nValRec		:= Val(oJson:bill:amount)
		EndIf

		// se a fatura está preenchida
		if !Empty(cCodFat)

			// posiciono na fatura da vindi
			U65->(DbSetOrder(3)) // U65_FILIAL + U65_CODIGO
			if U65->(MsSeek(cCodFat))

				cChaveSE1 := xFilial("U65") + U65->U65_PREFIX + U65->U65_NUM + U65->U65_PARCEL + U65->U65_TIPO

				// função que realiza a baixa do titulo
				lRet := EstornaBaixa(cChaveSE1,dDataEst,nValEst,@cErro)

			else
				cErro := "Fatura Vindi nao localizada"
			endif

		else
			cErro := "Codigo da fatura Vindi nao informado no Json"
		endif

	else
		cErro := "Json com erro de sintaxe"
	endif

	RestArea(aArea)

Return()

/*/{Protheus.doc} IntegraVindi::GravarTentativa
Metodo que grava a tentativa de cobrança da Vindi
@type method
@version 1.0
@author Wellington Gonçalves
@since 09/03/2019
@param cFilialIntegracao, character, cFilialIntegracao
@param cCodModulo, character, cCodModulo
@param cJson, character, cJson
@param cErro, character, cErro
@obs Refatoracao - Marcos Nata Santos
/*/
Method GravarTentativa(cFilialIntegracao,cCodModulo,cJson,cErro) Class IntegraVindi

	Local aArea			:= GetArea()
	Local cCodFat		:= ""
	Local cSequencia	:= ""
	Local dData			:= CTOD("  /  /    ")
	Local cCodRet		:= ""
	Local cDesRet		:= ""
	Local oJson			:= NIL

	// converto a string JSON
	if FWJsonDeserialize(cJson,@oJson)

		dData 	:= CTOD(SubStr(oJson:event:created_at,9,2) + "/" + SubStr(oJson:event:created_at,6,2) + "/" + SubStr(oJson:event:created_at,1,4))
		cCodFat	:= cValToChar(oJson:event:data:charge:bill:code)
		cCodRet := oJson:event:data:charge:last_transaction:gateway_response_code
		cDesRet := oJson:event:data:charge:last_transaction:gateway_message

		// se a fatura estï¿½ preenchida
		if !Empty(cCodFat)

			// posiciono na fatura da vindi
			U65->(DbSetOrder(3)) // U65_FILIAL + U65_CODIGO
			if U65->(MsSeek(cCodFat))

				// verifico se já havia uma tentativa para esta fatura
				U66->(DbSetOrder(1)) // U66_FILIAL + U66_CODIGO + U66_SEQ
				if U66->(MsSeek(xFilial("U66") + U65->U65_CODIGO))

					While U66->(!Eof()) .AND. U66->U66_FILIAL == xFilial("U66") .AND. U66->U66_CODIGO == U65->U65_CODIGO

						// pego última sequencia
						cSequencia := U66->U66_SEQ

						U66->(DbSkip())

					EndDo

					cSequencia := Soma1(cSequencia)

				else
					cSequencia := StrZero(1,TamSX3("U66_SEQ")[1])
				endif

				if RecLock("U66",.T.)

					U66->U66_FILIAL := xFilial("U66")
					U66->U66_CODIGO	:= U65->U65_CODIGO
					U66->U66_SEQ	:= cSequencia
					U66->U66_DATA	:= dData
					U66->U66_CODRET	:= cCodRet
					U66->U66_DESC	:= cDesRet
					U66->U66_MSFIL	:= cFilAnt

					U66->(MsUnLock())

				endif

			else
				cErro := "Fatura Vindi nao encontrada"
			endif

		else
			cErro := "Codigo da fatura Vindi nao informado no Json"
		endif

	else
		cErro := "Json com erro de sintaxe"
	endif

	RestArea(aArea)

Return()

/*/{Protheus.doc} BxTitulosFin
Função que realiza a baixa do título
@type function
@version 1.0
@author Wellington Gonçalves
@since 10/03/2019
@param cChaveSE1, character, chave do titulo da SE1
@param cFormaPgto, character, forma de pagamento
@param dDataPag, date, data do pagamento
@param nValRec, numeric, valor recebimento
@param cCaixa, character, caixa de recebimento
@param cLoteBx, character, lote do recebimento
@param cErro, character, variavel de erro
@param lProcessa, logical, processa?
@param nJuros, numeric, juros
@param nMulta, numeric, multa
@param nDesconto, numeric, desconto
@return logical, retorna se baixou
/*/
User Function BxTitulosFin(cChaveSE1,cFormaPgto,dDataPag,nValRec,cCaixa,cLoteBx,cErro,lProcessa,nJuros,nMulta,nDesconto)

	Local aArea			:= GetArea()
	Local aAreaSE1		:= SE1->( GetArea() )
	Local aAreaSA1		:= SA1->( GetArea() )
	Local aAreaSA6		:= SA6->( GetArea() )
	Local aAreaMDM		:= MDM->( GetArea() )
	Local aAreaMDN		:= MDN->( GetArea() )
	Local cNomeUsr		:= ""
	//Local cMvLjReceb	:= SuperGetMv("MV_LJRECEB",.F.,"1")		// Parametro de controle do Recebimento
	Local lDinMDM		:= SuperGetMV("MV_XDINMDM",.F.,.F.)		// verifico se gera MDM para recebimentos em dinheiro
	Local lLote			:= .T.
	Local lRet			:= .T.
	Local lContinua		:= .T.
	Local dDataAnt		:= dDataBase

	Default dDataPag	:= dDataBase
	Default nMulta		:= 0
	Default nJuros		:= 0
	Default nDesconto	:= 0

	oVirtusFin := VirtusFin():New()

	// posiciono no título a receber
	SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	if SE1->(MsSeek(cChaveSE1))

		If SE1->E1_SALDO > 0

			// posiciono no cliente
			SA1->(DbSetOrder(1)) // A1_COD + A1_LOJA
			if SA1->(MsSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))

				SA6->(DbSetOrder(1))
				If SA6->(MsSeek(xFilial("SA6")+cCaixa))

					//-- Processa baixa na data de pagamento
					dDataBase := dDataPag

					cNomeUsr := SA6->A6_NOME

					lContinua := oVirtusFin:ULJRecBX(;
						nMulta				, nJuros				, ;
						nDesconto			, nValRec				, Nil					, ;
						cFilAnt				, cFormaPgto			, Nil			   		, Nil					, ;
						Nil					, Nil					, Nil			 		, Nil					, ;
						.F.					, cNomeUsr				, 0				 		, Nil					, ;
						Nil					, ""					, Nil			 		, 0						, ;
						1 																							)

					if lContinua

						//-- Retorna database para atual
						dDataBase := dDataAnt

						//========================================================================
						// verifico se o parametro esta para gerar a MDM para baixa em dinheiro
						// e a forma de pagamento não é CC ou CD
						//========================================================================
						if !lDinMDM .And. !(cFormaPgto $ "CC/CD")
							lContinua := .F.
						endIf

						// se a baixa do título foi realizada com sucesso
						if lContinua

							//Se foi chamado na rotina de baixa Virtus Cobranca
							If IsInCallStack("POST_BAIXATITULOS") .AND. !Empty(cLoteBx)
								lLote := .F.
							Endif

							//Se chamou de baixa virtus so pega lote se ainda nao tem
							If lLote

								// pego o próximo código do lote
								cLoteBx := GetSx8Num("MDN","MDN_LOTE",,2)

								MDN->(DbSetOrder(2)) // MDN_FILIAL + MDN_LOTE
								While MDN->(MsSeek(xFilial("MDN") + cLoteBx))
									MDN->(ConfirmSX8())
									cLoteBx := GetSx8Num("MDN","MDN_LOTE",,2)
								EndDo

								// se ja estiver em uso eu pego um novo numero para o banco de conhecimento
								While !MayIUseCode("MDN"+xFilial("MDN")+cLoteBx ) // Reserva nome no semaforo
									MDN->(ConfirmSX8())
									cLoteBx := GetSx8Num("MDN","MDN_LOTE",,2)
								EndDo

							Endif

							// gravo o log de títulos baixados
							if RecLock("MDM",.T.)

								MDM->MDM_FILIAL	:= xFilial("MDM")
								MDM->MDM_BXFILI	:= SE1->E1_FILIAL
								MDM->MDM_PREFIX	:= SE1->E1_PREFIXO
								MDM->MDM_NUM	:= SE1->E1_NUM
								MDM->MDM_PARCEL	:= SE1->E1_PARCELA
								MDM->MDM_TIPO	:= SE1->E1_TIPO
								MDM->MDM_SEQ	:= SE5->E5_SEQ
								MDM->MDM_DATA	:= SE1->E1_EMISSAO
								MDM->MDM_LOTE	:= cLoteBx
								MDM->MDM_ESTORN	:= "2"

								MDM->(MsUnlock())

								// confirmo o controle de numeração
								MDN->(ConfirmSX8())

								// Libera nome reservado no semaforo
								Leave1Code("MDN"+xFilial("MDN")+cLoteBx)

							endif

						endIf

					else
						cErro := "Nao foi possivel realizar a baixa do titulo"
					endif
				Else
					cErro := "Caixa "+ Alltrim(cCaixa) + " nao encontrado na SA6"
				Endif
			else
				cErro := "Cliente nao encontrado"
			endif
		else

			lProcessa	:= .F.

			If !IsInCallStack("POST_BAIXATITULOS")

				//Atualiza status do registro na U63 para processado se titulo ja estiver baixado
				If U63->(Reclock("U63",.F.))

					U63->U63_DTPROC := dDataBase
					U63->U63_HRPROC := SubStr(Time(),1,5)
					U63->U63_STATUS := "C"
					U63->U63_MSPROC	:= "Titulo nao possui saldo disponivel para baixa"

					U63->(MsUnLock())

				Endif
			Endif
		Endif
	else
		cErro := "Titulo a receber nao encontrado"
	endif

	if !Empty(cErro)
		lRet := .F.
	endif

	FreeObj(oVirtusFin)
	oVirtusFin := Nil

	RestArea( aAreaMDN )
	RestArea( aAreaSE1 )
	RestArea( aAreaSA1 )
	RestArea( aAreaSA6 )
	RestArea( aAreaMDM )
	RestArea( aArea	)

Return(lRet)

/*/{Protheus.doc} CriaTitAdmin
Função que cria o titulo contra a administradora financeira
@type function
@version 1.0
@author Wellington Gonçalves
@since 10/03/2019
@param cFormaPgto, character, cFormaPgto
@param dDataPag, date, dDataPag
@param nValRec, numeric, nValRec
@param cCaixa, character, cCaixa
@param cCodAdm, character, cCodAdm
@param cLoteBx, character, cLoteBx
@param cCodModulo, character, cCodModulo
@param cContrato, character, cContrato
@param cErro, character, cErro
@param cCodNsu, character, cCodNsu
@param cAutorizacao, character, cAutorizacao
@param nQtdParc, numeric, nQtdParc
@return logical, lRet
@obs Refatoracao - Marcos Nata Santos
/*/
User Function CriaTitAdmin(cFormaPgto,dDataPag,nValRec,cCaixa,cCodAdm,;
		cLoteBx,cCodModulo,cContrato,cErro,cCodNsu,cAutorizacao, nQtdParc)

	Local lRet			:= .T.
	Local aArea 		:= GetArea()
	Local aAreaSAE		:= SAE->(GetArea())
	Local aAreaSA1		:= SA1->(GetArea())
	Local aAreaMDN		:= MDM->(GetArea())
	Local cPrefixo		:= SuperGetMV("MV_LJTITGR",,"REC")	// Prefixo de gravacao do titulo
	Local cNatureza		:= &(SuperGetMV("MV_NATCART"))
	Local lMvLjGerTx	:= SuperGetMV( "MV_LJGERTX",, .F. )
	Local dDataVencto	:= dDataPag
	Local cCodFornec	:= ""
	Local cNumTitulo	:= ""
	Local cParcela		:= ""
	Local aSE1			:= {}
	Local aVetorSE2		:= {}
	Local aAdmValTax	:= {}
	Local nTaxa			:= 0
	Local nValorTaxa	:= 0
	Local nVlrReal		:= 0
	Local nVlrParc		:= 0
	Local nVlrSobra		:= 0
	Local nI			:= 0
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	Default cAutorizacao := ""
	Default nQtdParc	:= 1

	// posiciono na administradora financeira
	SAE->(DbSetOrder(1)) //AE_FILIAL + AE_COD
	If SAE->(MsSeek(xFilial("SAE") + cCodAdm))

		If SAE->AE_FINPRO == "N"

			// verifica se a adm financeira está cadastrada como cliente
			// se não estiver, realiza o cadastro
			L070IncSA1()

		endif

		SA1->(DbSetOrder(1)) // A1_FILIAL + A1_COD
		if SA1->(MsSeek(xFilial("SA1") + SAE->AE_COD))

			///////////////////////////////////////////////////////////////////////
			//Chamada da rotina LJ7_TxAdm para calculo da taxa da Adm Financeira  //
			//de acordo com o cadastrado na tabela MEN							  //
			//Par?etros utilizados:						    					  //
			// 1 - Quantidade de parcelas					  					  //
			// 2 - Valor total das parcelas					 					  //
			///////////////////////////////////////////////////////////////////////
			aAdmValTax := LJ7_TxAdm( SAE->AE_COD, nQtdParc, nValRec)

			nTaxa := Iif(aAdmValTax[03] > 0, aAdmValTax[03], SAE->AE_TAXA)

			// se o parametro MV_LJGERTX estiver desabilitado, é descontada a taxa da Administradora Financeira
			// na inclusão do título a receber contra a Administradora
			// se estiver habiltiado, será gerado um contas a pagar contra a Administradora
			If lMvLjGerTx
				nValorTaxa := 0
			Else
				nValorTaxa := (nValRec * nTaxa) / 100
			EndIf

			// Deducao da taxa administrativa
			nVlrReal    := nValRec - nValorTaxa

			// Valor da parcela contra a administradora
			nVlrParc    := Round((nVlrReal / nQtdParc),2)

			// Valor de sobra pra adicionar na ultima parcela
			nVlrSobra   := nVlrReal - (nVlrParc * nQtdParc)

			dDataVencto += SAE->AE_DIAS

			For nI := 1 To nQtdParc

				// A partir da segunda parcela, adicionamos 30d a data de cada parcela?
				If nI > 1
					dDataVencto += 30
				EndIf

				// Adicionamos a sobra ao valor da ultima parcela
				If nI == nQtdParc
					nVlrParc += nVlrSobra
				EndIf

				//Chama funcao do loja(GetNumSE1) Obtemos o numero do titulo disponivel
				//para gerar o titulo contra administradora
				cNumTitulo 	:= U_GetNumMDM(cPrefixo)
				cParcela	:= StrZero(nI,TamSX3("E1_PARCELA")[1])

				aSE1 := {	{"E1_FILIAL"	,	xFilial("SE1")				,Nil},;
					{"E1_PREFIXO"	,	cPrefixo							,Nil},;
					{"E1_NUM"	  	,	cNumTitulo							,Nil},;
					{"E1_PARCELA" 	,	cParcela 							,Nil},;
					{"E1_TIPO"	 	,	AllTrim(cFormaPgto)					,Nil},;
					{"E1_NATUREZ" 	,	cNatureza							,Nil},;
					{"E1_PORTADO" 	,	cCaixa								,Nil},;
					{"E1_CLIENTE" 	,	SA1->A1_COD							,Nil},;
					{"E1_LOJA"	  	,	SA1->A1_LOJA						,Nil},;
					{"E1_EMISSAO" 	,	dDataPag							,Nil},;
					{"E1_VENCTO"  	,	dDataVencto							,Nil},;
					{"E1_VENCREA" 	,	DataValida(dDataVencto)				,Nil},;
					{"E1_MOEDA" 	,	1									,Nil},;
					{"E1_ORIGEM"	,	"LOJA701"							,Nil},;
					{"E1_FLUXO"		,	"S"									,Nil},;
					{"E1_VALOR"	  	,	nVlrParc							,Nil},;
					{"E1_VLRREAL"  	,	nVlrReal							,Nil},;
					{"E1_NSUTEF"  	,	cCodNsu								,Nil},;
					{"E1_CARTAUT"	,	cAutorizacao						,Nil},;
					{"E1_HIST"		,	""									,Nil}}

				MsExecAuto({|x,y| Fina040(x,y)},aSE1,3) //Inclusao

				// Verifica se houve algum erro durante a execucao da rotina automatica
				If lMsErroAuto
					cErro := MostraErro("\temp")
				Else

					// grava a tabela MDN (Log de Titulos Gerados)
					if RecLock("MDN" , .T.)

						MDN_FILIAL	:= xFilial("MDN")
						MDN_GRFILI	:= xFilial("SE1")
						MDN_PREFIX	:= cPrefixo
						MDN_NUM		:= cNumTitulo
						MDN_PARCEL	:= cParcela
						MDN_TIPO	:= cFormaPgto
						MDN_LOTE	:= cLoteBx

						MDN->(MsUnlock())

					endif

					// se o parametro estiver habilitado para geração
					// do contas a pagar para a administradora financeira
					If lMvLjGerTx .AND. AllTrim(cFormaPgto) $ "CC|CD|PX"

						// inclui Administradora como Fornecedor
						cCodFornec := L070IncSA2()	//retorna o coigo do Fornecedor(SA2)

						// se o fornecedor já existe ou foi criado com sucesso
						if !Empty(cCodFornec)

							// calculo a taxa a ser paga
							nValorTaxa := A410Arred( (nValRec * nTaxa) / 100, "L2_VRUNIT" )

							aVetorSE2 :={	{"E2_PREFIXO"	, SE1->E1_PREFIXO		, Nil}	,;
								{"E2_NUM"	   	, SE1->E1_NUM    		, Nil}	,;
								{"E2_PARCELA"	, SE1->E1_PARCELA		, Nil}	,;
								{"E2_TIPO"		, SE1->E1_TIPO   		, Nil}	,;
								{"E2_NATUREZ"	, SE1->E1_NATUREZ		, Nil}	,;
								{"E2_FORNECE"	, cCodFornec 			, Nil}	,;
								{"E2_LOJA"		, SE1->E1_LOJA   		, Nil}	,;
								{"E2_EMISSAO"	, dDataPag      		, NIL}	,;
								{"E2_VENCTO"	, SE1->E1_VENCTO 		, NIL}	,;
								{"E2_VENCREA"	, SE1->E1_VENCREA		, NIL}	,;
								{"E2_VALOR"		, nValorTaxa 			, NIL}	,;
								{"E2_HIST"		, AllTrim(SE1->E1_NUM)	, NIL}	}

							MSExecAuto( {|x,y,z| FINA050(x,y,z)}, aVetorSE2, Nil, 3 )

							// Verifica se houve algum erro durante a execucao da rotina automatica
							If lMsErroAuto
								cErro := MostraErro("\temp")
							EndIf

						endif

					EndIf

				EndIf

			Next nI

		else
			cErro := "Cliente vinculado a administradora financeira nao encontrado"
		endif

	else
		cErro := "Administradora financeira nao encontrada"
	endif

	if !Empty(cErro)
		lRet := .F.
	endif

	RestArea(aAreaMDN)
	RestArea(aAreaSAE)
	RestArea(aAreaSA1)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} EstornaBaixa
Função que realiza o estorno da baixa do título
@type function
@version 1.0
@author Wellington Gonçalves
@since 10/03/2019
@param cChaveSE1, character, cChaveSE1
@param dDataEst, date, dDataEst
@param nValEst, numeric, nValEst
@param cErro, character, cErro
@return logical, lRet
/*/
Static Function EstornaBaixa(cChaveSE1,dDataEst,nValEst,cErro)

	Local aArea			:= GetArea()
	Local aAreaSE1		:= SE1->(GetArea())
	Local aAreaSA1		:= SA1->(GetArea())
	Local lRet			:= .T.
	Local cDirLogServer	:= ""

	Private lMsErroAuto	:= .F.
	Private lMsHelpAuto := .T.

	//diretorio no server que sera salvo o retorno do execauto
	cDirLogServer := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	cDirLogServer += If(Right(cDirLogServer, 1) <> "\", "\", "")

	// posiciono no título a receber
	SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	if SE1->(MsSeek(cChaveSE1))

		// posiciono no cliente
		SA1->(DbSetOrder(1)) // A1_COD + A1_LOJA
		if SA1->(MsSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))

			// função que faz o estorno da baixa realizada no sigaloja
			lRet := U_UVIND15(SE1->E1_FILIAL,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,@cErro)

		else
			cErro := "Cliente nao encontrado"
		endif

	else
		cErro := "Titulo nao encontrado"
	endif

	RestArea(aArea)
	RestArea(aAreaSE1)
	RestArea(aAreaSA1)

Return(lRet)

/*/{Protheus.doc} IntegraVindi::IncManVind
Metodo que inclui manualmente o cliente e perfil de pgto
@type method
@version 1.0
@author Wellington Gonçalves
@since 28/03/2019
@param cCodCliVindi, character, cCodCliVindi
@param cContrato, character, cContrato
@param cCliente, character, cCliente
@param cLoja, character, cLoja
@param cCodPerVindi, character, cCodPerVindi
@param cFormaPgto, character, cFormaPgto
@param cNomeCart, character, cNomeCart
@param cDigCart, character, cDigCart
@param cValidade, character, cValidade
@param cBandeira, character, cBandeira
@param cToken, character, cToken
@param cOrigem, character, cOrigem
@param cOrigemDesc, character, cOrigemDesc
@return logical, lRet
@obs Refatoracao - Marcos Nata Santos
/*/
	Method IncManVind(cCodCliVindi,cContrato,cCliente,cLoja,cCodPerVindi,cFormaPgto,;
		cNomeCart,cDigCart,cValidade,cBandeira,cToken,cOrigem,cOrigemDesc) Class IntegraVindi

	Local lRet 				:= .T.
	Local lIncClienteVindi	:= .T.
	Local cCodigo			:= ""
	Local aArea				:= GetArea()
	Local lFuneraria		:= SuperGetMV("MV_XFUNE",,.F.)
	Local cCodModulo		:= IIF(lFuneraria, "F", "C")
	Local cFilialCtr		:= IIF(lFuneraria, xFilial("UF2"), xFilial("U00"))

	Default cOrigem := "UVIND06"
	Default cOrigemDesc := "IntegraVindi IncManVind"

	// verifico se este cliente vindi já foi cadastrado
	U61->(DbSetOrder(3)) // U61_FILIAL + U61_CLIENT + U61_LOJA

	if U61->(MsSeek( xFilial("U61") + cCliente + cLoja))
		lIncClienteVindi := .F.
	endif

	//-- Inclui ou atualiza cliente vindi
	RecLock("U61", lIncClienteVindi)
	U61->U61_FILIAL := xFilial("U61")
	U61->U61_CODIGO := cCodCliVindi
	U61->U61_DATA	:= dDataBase
	U61->U61_HORA	:= SubStr(Time(),1,5)
	U61->U61_CONTRA	:= cContrato
	U61->U61_CLIENT	:= cCliente
	U61->U61_LOJA	:= cLoja
	U61->U61_STATUS	:= "A"
	U61->(MsUnLock())

	// pego o próximo código da tabela
	cCodigo := GetSxeNum("U64","U64_CODIGO")

	U64->(DbSetOrder(1)) // U64_FILIAL + U64_CODIGO
	While U64->(MsSeek(xFilial("U64") + cCodigo))
		U64->(ConfirmSX8())
		cCodigo := GetSxeNum("U64","U64_CODIGO")
	EndDo

	if RecLock("U64",.T.)

		U64->U64_FILIAL	:= xFilial("U64")
		U64->U64_CODIGO	:= cCodigo
		U64->U64_CONTRA	:= cContrato
		U64->U64_CLIENT	:= cCliente
		U64->U64_LOJA	:= cLoja
		U64->U64_DATA	:= dDataBase
		U64->U64_HORA	:= SubStr(Time(),1,5)
		U64->U64_FORPG	:= cFormaPgto
		U64->U64_CODVIN	:= cCodPerVindi
		U64->U64_NOMCAR	:= cNomeCart
		U64->U64_DIGCAR	:= cDigCart
		U64->U64_VALIDA	:= cValidade
		U64->U64_BANDEI	:= cBandeira
		U64->U64_TOKEN	:= cToken
		U64->U64_STATUS	:= "A"
		U64->U64_MSFIL	:= cFilAnt

		U64->(MsUnLock())

	endif

	//---------------------------------------------------------------------------------//
	//-- Inclui historico de inclusao de cliente/perfil de pagamento pelo Virtus App --//
	//---------------------------------------------------------------------------------//
	aDadosProc := {}
	AADD(aDadosProc , "C") // Status
	AADD(aDadosProc , "") // Json Envio
	AADD(aDadosProc , "") // Json Retorno
	AADD(aDadosProc , "201") // Codigo do retorno
	AADD(aDadosProc , "Created! Enviado pelo Virtus App") // Descrição do retorno

	Self:IncluiTabEnvio(cCodModulo, "1", "I", 1, cFilialCtr + cContrato + cCliente + cLoja, aDadosProc, cOrigem, cOrigemDesc)
	Self:IncluiTabEnvio(cCodModulo, "2", "I", 1, cFilialCtr + cContrato + cCliente + cLoja, aDadosProc, cOrigem, cOrigemDesc)

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} IntegraVindi::ConsultaFatura
Metodo que consulta uma Fatura na Vindi
@type method
@version 1.0
@author Leandro Rodrigues
@since 22/04/2019
@param cCodModulo, character, cCodModulo
@param cErro, character, cErro
@param cJsonEnvio, character, cJsonEnvio
@param cCodRet, character, cCodRet
@param cDescRetorno, character, cDescRetorno
@param cDadosRetorno, character, cDadosRetorno
@return character, cStatus
/*/
Method ConsultaFatura(cCodModulo,cErro,cJsonEnvio,cCodRet,cDescRetorno,cDadosRetorno) Class IntegraVindi

	Local oRest			:= NIL
	Local oJson			:= NIL
	Local lRet			:= .T.
	Local aArea			:= GetArea()
	Local aAreaU65		:= U65->(GetArea())
	Local cJsonRetorno	:= ""
	Local cStatus		:= ""

	Default cCodRet := ""
	Default cDescRetorno := ""
	Default cDadosRetorno := ""

	oRest := FWRest():New(Self:cApiVindi)

	// defino o timeout da conexao
	oRest:nTimeOut := Self:nTimeOut

	cJsonEnvio := AllTrim(U65->U65_CODVIN)

	// informo o path do metodo
	oRest:SetPath(Self:cPathFatura + "/" + cJsonEnvio)

	// envio o comando de delete
	lRet := oRest:Get(Self:aHeadOut)

	// pego o retorno da API
	cJsonRetorno := oRest:GetResult()

	// converto a string JSON
	if FWJsonDeserialize(cJsonRetorno,@oJson)

		cCodRet			:= oRest:oResponseh:cStatusCode
		cDescRetorno	:= oRest:oResponseh:cReason
		cDadosRetorno	:= cJsonRetorno

		// se a comunicacao REST ocorreu
		If lRet

			cStatus	:= oJson:Bill:Status  // pega status da fatura
		else

			if AT('"parameter"',cJsonRetorno)
				cErro 	:= oJson:ERRORS[1]:PARAMETER + ": " + oJson:ERRORS[1]:MESSAGE
			endif

		endif

	else
		cErro 			:= "Erro Vindi - Estrutura do retorno inválida!"
		cDadosRetorno	:= cJsonRetorno
	endif

	// se tem mensagem de erro
	if !Empty(cErro)
		lRet := .F.
	endif

	RestArea(aAreaU65)
	RestArea(aArea)

Return(cStatus)

/*/{Protheus.doc} ValidaEnvio
Valida se deverá ser enviado titulo para Vindi
@type function
@version 1.0
@author Leandro Rodrigues
@since 22/09/2019
@param cCodModulo, character, cCodModulo
@param cChave, character, cChave
@return logical, lRet
/*/
Method ValidaEnvio(cCodModulo,cChave,cRetornoVindi) Class IntegraVindi

	Local lRet 			:= .T.
	Local cStatus 		:= ""
	Local cQry 			:= ""
	Local cErro			:= ""
	Local cCodRet		:= ""
	Local cDescRetorno	:= ""
	Local cDadosRetorno	:= ""
	Local nTamFilial	:= TamSX3("U65_FILIAL")[1]
	Local nTamPrefixo	:= TamSX3("U65_PREFIX")[1]
	Local nTamNumero	:= TamSX3("U65_NUM")[1]
	Local nTamParcel	:= TamSX3("U65_PARCEL")[1]
	Local nTamTipo		:= TamSX3("U65_TIPO")[1]
	Local nPosIniPref	:= nTamFilial + 1
	Local nPosIniNum	:= nPosIniPref + nTamPrefixo
	Local nPosParcel	:= nPosIniNum + nTamNumero
	Local nPosIniTipo	:= nPosParcel + nTamPrefixo

	Default cRetornoVind := ""

	cQry := " SELECT"
	cQry += "	U65_CODVIN,"
	cQry += "	U65_STATUS,"
	cQry += "	R_E_C_N_O_ RECU65"
	cQry += " FROM "+ RETSQLNAME("U65")
	cQry += " WHERE "
	cQry += " D_E_L_E_T_ = ' ' "
	cQry += " AND U65_FILIAL 	= '" + SubStr(cChave,1,nTamFilial)+ "' "
	cQry += " AND U65_PREFIX 	= '" + SubStr(cChave,nPosIniPref,nTamPrefixo)+ "' "
	cQry += " AND U65_NUM 		= '" + SubStr(cChave,nPosIniNum,nTamNumero)+ "' "
	cQry += " AND U65_PARCEL 	= '" + SubStr(cChave,nPosParcel,nTamParcel)+ "' "
	cQry += " AND U65_TIPO 		= '" + SubStr(cChave,nPosIniTipo,nTamTipo)+ "' "

	cQry := ChangeQuery(cQry)

	If Select("QU65")>1
		QU65->(DbCloseArea())
	Endif

	TcQuery cQry New Alias "QU65"


	While QU65->(!EOF())

		U65->(DbGoTo( QU65->RECU65 ))

		oVindi := IntegraVindi():New()

		//Consulto status da fatura na VINDI
		cStatus := oVindi:ConsultaFatura(cCodModulo,@cErro,U65->U65_CODVIN,@cCodRet,@cDescRetorno,@cDadosRetorno)

		//Valido fatura esta arquivada na VINDI e no protheus esta Ativo
		if cStatus == "canceled" .AND. U65->U65_STATUS == "A"

			//Atualizo status da Fatura no Protheus
			If Reclock("U65",.F.)

				U65->U65_STATUS := "I"
				U65->(MsUnLock())
			Endif

			lRet := .T.

			//se o titulo na vindi nao esta cancelado e o status no protheus esta Inativo
		elseIf cStatus <> "canceled" .AND. U65->U65_STATUS == "I"

			//Atualizo status da Fatura no Protheus para ativo
			If Reclock("U65",.F.)

				U65->U65_STATUS := "A"
				U65->(MsUnLock())
			Endif

			lRet := .F.


		Endif

		cRetornoVind := cDadosRetorno

		QU65->(DbSkip())
	EndDo

Return lRet

/*/{Protheus.doc} IntegraVindi::ConsultaPerfil
Metodo que consultra Perfil de pagamento na Vindi
@type method
@version 1.0
@author Leandro Rodrigues
@since 21/01/2019
@param cIdPerfil, character, cIdPerfil
@param cErro, character, cErro
@param cContrato, character, cContrato
@return array, aCartao
/*/
Method ConsultaPerfil(cIdPerfil,cErro,cContrato) Class IntegraVindi

	Local oRest			:= NIL
	Local oJson			:= NIL
	Local aArea			:= GetArea()
	Local aAreaU64		:= U64->( GetArea() )
	Local cJsonRetorno	:= ""
	Local aCartao		:= {}

	oRest := FWRest():New(Self:cApiVindi)

	// defino o timeout da conexao
	oRest:nTimeOut := Self:nTimeOut

	cJsonEnvio := AllTrim(cIdPerfil)

	// informo o path do metodo
	oRest:SetPath(Self:cPathPerfil + "/" + cJsonEnvio)

	// envio o comando de Get
	lRet := oRest:Get(Self:aHeadOut)

	// pego o retorno da API
	cJsonRetorno := oRest:GetResult()

	// converto a string JSON
	if FWJsonDeserialize(cJsonRetorno,@oJson)

		cCodRet			:= oRest:oResponseh:cStatusCode
		cDadosRetorno	:= cJsonRetorno

		// se a comunicacao REST ocorreu
		If lRet

			//Valido se ja existe Perfil ou esta inativo
			U64->(DbSetOrder(4))
			If !U64->(MsSeek(xFilial("U64")+cIdPerfil))

				if cCodRet == "200"

					aCartao 	:= {}
					cValidade	:= SubStr(SubStr(oJson:Payment_Profile:card_expiration,1,7),6,2) // Mes
					cValidade	+= SubStr(SubStr(oJson:Payment_Profile:card_expiration,1,7),1,4) // Ano

					//Carrega dados de retorno
					AADD(aCartao, Alltrim(oJson:Payment_Profile:holder_name)				)	// Nome Cartao
					AADD(aCartao, cValidade													)	// Data Vencimento Cartao
					AADD(aCartao, oJson:Payment_Profile:Card_Number_First_six				)	// 6 Ultimos Digitos
					AADD(aCartao, oJson:Payment_Profile:Card_Number_Last_Four				)	// 4 Ultimos Digitos
					AADD(aCartao, oJson:Payment_Profile:Payment_Company:Code				)	// Bandeira
					AADD(aCartao, cValtoChar(oJson:Payment_Profile:Customer:id	)			)	// Id Cliente Vindi
					AADD(aCartao, oJson:Payment_Profile:Token								)	// Token

				endif
			else

				cErro 	:= "Perfil de pagamento ja esta cadastrado !"
			Endif
		endif

	else

		cErro 			:= "Erro Vindi - Estrutura do retorno inválida!"
		cDadosRetorno	:= cJsonRetorno

	endif

	RestArea(aArea)
	RestArea(aAreaU64)

Return(aCartao)

/*/{Protheus.doc} IntegraVindi::ConsultaTel
Consulta telefones do cliente na Vindi pelo ID
@type method
@version 1.0
@author nata.queiroz
@since 31/03/2020
@param cClientId, character, cClientId
@return array, aPhones
/*/
Method ConsultaTel(cClientId) Class IntegraVindi
	Local oRest := Nil
	Local cResponse := ""
	Local jResponse := Nil
	Local cRet := ""
	Local nX := 0
	Local aPhones := {}
	Local nStart := Seconds()
	Local cMessage := ""

	Default cClientId := ""

	If !Empty(cClientId)
		oRest := FWRest():New(Self:cApiVindi)
		oRest:nTimeOut := Self:nTimeOut

		oRest:SetPath(Self:cPathCliente + "/" + cClientId)

		lRet := oRest:Get(Self:aHeadOut)

		cResponse := oRest:GetResult()

		If !Empty(cResponse)
			jResponse := JsonObject():New()
			cRet := jResponse:FromJson(cResponse)

			If ValType(cRet) == "U"
				if ValidaErro(jResponse, @cMessage) // funcao para validar se o retorno veio como erro
					For nX := 1 To Len(jResponse["customer"]["phones"])
						aAdd(aPhones, {jResponse["customer"]["phones"][nX]["id"],;
							jResponse["customer"]["phones"][nX]["phone_type"],;
							jResponse["customer"]["phones"][nX]["number"]} )
					Next nX
				else
					FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
				endIf
			Else
				cMessage := "[IntegraVindi::ConsultaTel] => Json recebido esta invalido"
				FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
			EndIf
		Else
			cMessage := "[IntegraVindi::ConsultaTel] => Resposta WS vazia"
			FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		EndIf
	EndIf

	FreeObj(oRest)
	FreeObj(jResponse)

Return(aPhones)

/*/{Protheus.doc} IntegraVindi::BuscarFaturaPorId
Busca fatura vindi por id
@type method
@version 1.0
@author nata.queiroz
@since 04/05/2021
@param cIdFatura, character, cIdFatura
@return character, cJsonRetorno
/*/
Method BuscarFaturaPorId(cIdFatura) Class IntegraVindi
	Local lRet := .T.
	Local oRest := Nil
	Local cJsonRetorno := ""

	Default cIdFatura := ""

	If !Empty(cIdFatura)
		oRest := FWRest():New(Self:cApiVindi)

		oRest:nTimeOut := Self:nTimeOut

		oRest:SetPath(Self:cPathFatura + "/" + AllTrim(cIdFatura))

		lRet := oRest:Get(Self:aHeadOut)

		If lRet
			cJsonRetorno := oRest:GetResult()
		EndIf
	EndIf

Return cJsonRetorno

/*/{Protheus.doc} IntegraVindi::ReprocessarVindi
Reprocessa operacoes de envios/recebimentos por contrato
@type method
@version 1.0
@author nata.queiroz
@since 19/05/2021
@param cContrato, character, cContrato
/*/
Method ReprocessarVindi(cContrato) Class IntegraVindi
	Default cContrato := ""

	If !Empty(cContrato)

		//-- Reprocessa operacoes de envios para plataforma VINDI --//
		If LockByName("UVIND04A", .F., .T.)
			::ProcessaEnvio(cContrato)
			UnLockByName("UVIND04A", .F., .T.)
		Else
			Help(NIL, NIL, "ReprocessarVindi", NIL,;
				"[UVIND04A]["+ cFilAnt +"] Existe um JOB ativo no momento.",1, 0, NIL, NIL,;
				NIL, NIL, NIL,{"Por favor, aguarde e tente novamente mais tarde."})
		EndIf

		//-- Reprocessa operacoes de recebimento da plataforma VINDI --//
		If LockByName("UVIND05A", .F., .T.)
			::ProcRecebi(cContrato)
			UnLockByName("UVIND05A", .F., .T.)
		Else
			Help(NIL, NIL, "ReprocessarVindi", NIL,;
				"[UVIND05A]["+ cFilAnt +"] Existe um JOB ativo no momento.",1, 0, NIL, NIL,;
				NIL, NIL, NIL,{"Por favor, aguarde e tente novamente mais tarde."})
		EndIf

	EndIf

Return

/*/{Protheus.doc} IntegraVindi::BuscarFatPorData
Busca todas faturas pela data informada
@type method
@version 12.1.27
@author nata.queiroz
@since 8/18/2021
@param dDataRef, date, dDataRef
@param nPage, numeric, nPage
@return array, aFaturas
/*/
Method BuscarFatPorData(dDataRef, nPage) Class IntegraVindi
	Local lRet := .T.
	Local xRet := Nil
	Local aFaturas := {}
	Local oRest := Nil
	Local cQryParams := ""
	Local cUpdAt := ""
	Local oJsonRet := JsonObject():new()
	Local oJsonBill := JsonObject():new()
	Local cJsonRetorno := ""
	Local nX := 0

	Default dDataRef := dDatabase
	Default nPage := 1

	If !Empty(dDataRef)
		cUpdAt := DTOS(dDataRef)
		cUpdAt := SubStr(cUpdAt, 1, 4) + "-" + SubStr(cUpdAt, 5, 2) + "-" + SubStr(cUpdAt, 7, 2)

		oRest := FWRest():New(Self:cApiVindi)
		oRest:nTimeOut := Self:nTimeOut

		// Parametros
		cQryParams := "?page="+ cValToChar(nPage) +"&per_page=50&query=updated_at%3D"+ cUpdAt +"%20AND%20status%3Dpaid&sort_by=created_at&sort_order=asc"

		oRest:SetPath(Self:cPathFatura + cQryParams)

		lRet := oRest:Get(Self:aHeadOut)

		If lRet
			cJsonRetorno := oRest:GetResult()

			If !Empty(cJsonRetorno)
				xRet := oJsonRet:fromJSON(cJsonRetorno)

				If ValType(xRet) == "U"
					If Len(oJsonRet["bills"]) > 0
						For nX := 1 To Len(oJsonRet["bills"])
							oJsonBill["bill"] := oJsonRet["bills"][nX]
							AADD(aFaturas, oJsonBill:toJSON())

							FreeObj(oJsonBill)
							oJsonBill := JsonObject():new()
						Next nX
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	FreeObj(oJsonRet)
	FreeObj(oJsonBill)

Return aFaturas

/*/{Protheus.doc} ExistCodFat
Verifica se existe codigo externo gravado na fatura da Vindi
Codigo externo é chave para tabela de faturas U65
Faturas sem codigo externo na Vindi significa que não foram enviadas via Virtus ERP
@type function
@version 1.0
@author nata.queiroz
@since 09/04/2020
@param cJson, character, cJson
@return logical, lRet
/*/
Static Function ExistCodFat(cJson)
	Local lRet := .T.
	Local oJson := Nil
	Local cCodFat := ""
	Local nStart := Seconds()
	Local cMessage := ""

	If FWJsonDeserialize(cJson, @oJson)
		If AttIsMemberOf(oJson , "event")
			If oJson:event:type == "bill_paid"

				cCodFat := cValToChar(oJson:event:data:bill:code)

			ElseIf oJson:event:type == "charge_rejected";
					.Or. oJson:event:type == "charge_refunded"

				cCodFat := cValToChar(oJson:event:data:charge:bill:code)

			EndIf
		Else
			cCodFat := cValToChar(oJson:bill:code)
		EndIf
	EndIf

	If Empty(cCodFat)
		lRet := .F.

		cMessage := "[UVIND06 - ExistCodFat]"
		FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
		cMessage := "Nao existe codigo de fatura no json recebido!"
		FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
	EndIf

	FreeObj(oJson)

Return lRet

/*/{Protheus.doc} AvaliaF040
Avalia pontos de entrada na rotina FINA040, para setar origem de operacoes
@type function
@version 1.0
@author nata.queiroz
@since 11/05/2021
@param cOrigem, character, cOrigem
@param cOrigemDesc, character, cOrigemDesc
/*/
Static Function AvaliaF040(cOrigem, cOrigemDesc)

	//-- Avalia origem das operacoes --//
	If FWIsInCallStack("U_F040ALT")
		cOrigem := "F040ALT"
		cOrigemDesc := "Alteracao de Titulo Financeiro"
	ElseIf FWIsInCallStack("U_FA040FIN")
		cOrigem := "FA040FIN"
		cOrigemDesc := "Inclusao de Titulo Financeiro"
	ElseIf FWIsInCallStack("U_FA040DEL")
		cOrigem := "FA040DEL"
		cOrigemDesc := "Exclusao de Titulo Financeiro"
	EndIf

Return

/*/{Protheus.doc} PENDVIND
Verifica pendencias de processamento de registros (Envios/Recebimentos) da plataforma VINDI
@type function
@version 1.0
@author nata.queiroz
@since 14/05/2021
@param cContrato, character, cContrato
@param cCodModulo, character, cCodModulo
@return logical, lRet
/*/
User Function PENDVIND(cContrato, cCodModulo)
	Local lRet := .T.
	Local cQry := ""

	Default cCodModulo := "F" //-- Funeraria

	If !Empty(cContrato)

		//-------------------------------------------------------//
		//-- Analisa pendencias de ENVIO para plataforma VINDI --//
		//-------------------------------------------------------//
		cQry := "SELECT U62_CHAVE FROM " + RetSqlName("U62")
		cQry += "WHERE D_E_L_E_T_ <> '*' "
		cQry += "AND U62_FILIAL = '"+ xFilial("U62") +"' "
		cQry += "AND U62_STATUS <> 'C' "
		cQry += "AND U62_MODULO = '"+ AllTrim(cCodModulo) +"' "
		cQry += "AND U62_CHAVE LIKE '%"+ AllTrim(cContrato) +"%' "
		cQry := ChangeQuery(cQry)

		If Select("TMPU62") > 0
			TMPU62->( DbCloseArea() )
		EndIf

		MPSysOpenQuery(cQry, "TMPU62")

		If TMPU62->(!Eof())
			lRet := .F.
			Help(NIL, NIL, "PENDVIND", NIL,;
				"Existem pendências de processamento (ENVIO) da plataforma VINDI para este contrato.",1, 0, NIL, NIL,;
				NIL, NIL, NIL,{"Por favor, aguarde o JOB processar estes registros, antes de prosseguir com alterações."})
		EndIf

		TMPU62->( DbCloseArea() )

		If !lRet

			//-------------------------------------------------------------//
			//-- Analisa pendencias de RECEBIMENTO para plataforma VINDI --//
			//-------------------------------------------------------------//
			cQry := "SELECT U65.U65_PREFIX, U65.U65_CONTRA, U65.U65_PARCEL, U65.U65_TIPO "
			cQry += "FROM "+ RetSqlName("U63") +" U63 "
			cQry += "INNER JOIN "+ RetSqlName("U65") +" U65 "
			cQry += "ON U65.D_E_L_E_T_ <> '*' "
			cQry += "AND U65.U65_FILIAL = U63.U63_FILIAL "
			cQry += "AND U65.U65_CODVIN = U63.U63_IDVIND "
			cQry += "WHERE U63.D_E_L_E_T_ <> '*' "
			cQry += "AND U63.U63_FILIAL = '"+ xFilial("U63") +"' "
			cQry += "AND U63.U63_STATUS <> 'C' "
			cQry += "AND U63.U63_MODULO = '"+ AllTrim(cCodModulo) +"' "
			cQry += "AND U65.U65_CONTRA = '"+ AllTrim(cContrato) +"' "
			cQry := ChangeQuery(cQry)

			If Select("TMPU63") > 0
				TMPU63->( DbCloseArea() )
			EndIf

			MPSysOpenQuery(cQry, "TMPU63")

			If TMPU63->(!Eof())
				lRet := .F.
				Help(NIL, NIL, "PENDVIND", NIL,;
					"Existem pendências de processamento (RECEBIMENTO) da plataforma VINDI para este contrato.",1, 0, NIL, NIL,;
					NIL, NIL, NIL,{"Por favor, aguarde o JOB processar estes registros, antes de prosseguir com alterações."})
			EndIf

			If Select("TMPU63") > 0
				TMPU63->( DbCloseArea() )
			EndIf

		EndIf

	EndIf

Return lRet

/*/{Protheus.doc} REPRVIND
Funcao para chamada do reprocessamento de operacoes VINDI por contrato
@type function
@version 1.0
@author nata.queiroz
@since 19/05/2021
@param cContrato, character, cContrato
/*/
User Function REPRVIND(cContrato)

	Local oVindi := Nil

	//verificar se existe parcelas na tabela de integração com a VINDI
	FWMsgRun(,;
		{|| ValTabEnvio(cContrato) },;
		'Aguarde...','Realizando a conferência das parcelas na tabela de envio para VINDI (U62)...')

	If !Empty(cContrato)
		oVindi := IntegraVindi():New()
		FWMsgRun(,{|| oVindi:ReprocessarVindi(cContrato)},'Aguarde...','Reprocessando Registros Pendentes...')
	EndIf

	FreeObj(oVindi)
	oVindi := Nil

Return

/*/{Protheus.doc} ValTabEnvio
Valida se os dados de envio das parcelas estão gravados na tabela de envio para VINDI: tabela 'U62'
@type function
@version 12.1.33
@author Pablo Nunes
@since 20/12/2022
@param cContrato, character, cContrato
/*/
Static Function ValTabEnvio(cContrato)

	Local aArea := GetArea()
	Local aAreaSE1 := SE1->(GetArea())
	Local cQry := ""
	Local cCodModulo := ""
	Local lFuneraria := SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio := SuperGetMV("MV_XCEMI",,.F.)

	//verifica a existencia do PE FA040FIN
	IF !ExistBlock("FA040FIN")
		MsgAlert("Para o correto funcionamento da integração do ERP com a VINDI é necessário a existencia do Ponto de Entrada FA040FIN. Favor entrar em contato com o Administrador do sistema.")
		Return
	EndIf

	// verifico a rotina e o parametro para verificar o modulo
	If lCemiterio .And. "CPG" $ AllTrim(FunName()) // para modulo de cemiterio
		cCodModulo := "C"
	ElseIf lCemiterio .And. "FUN" $ AllTrim(FunName()) // para modulo de funeraria
		cCodModulo := "F"
	ElseIf lCemiterio // para modulo de cemiterio
		cCodModulo := "C"
	ElseIf lFuneraria // para modulo de funeraria
		cCodModulo := "F"
	EndIf

	cQry := "SELECT "
	cQry += "    SE1.R_E_C_N_O_ AS RECNOSE1 "
	cQry += "FROM "+ RetSqlName("SE1") +" SE1 "
	cQry += "INNER JOIN "+ RetSqlName("SED") +" SED "
	cQry += "    ON SED.D_E_L_E_T_ <> '*' "
	cQry += "    AND SED.ED_FILIAL = '"+ xFilial("SED") +"' "
	cQry += "    AND SED.ED_CODIGO = SE1.E1_NATUREZ "
	cQry += "INNER JOIN "+ RetSqlName("SA1") +" SA1 "
	cQry += "    ON SA1.D_E_L_E_T_ <> '*' "
	cQry += "    AND SA1.A1_COD = SE1.E1_CLIENTE "
	cQry += "    AND SA1.A1_LOJA = SE1.E1_LOJA "
	cQry += "WHERE SE1.D_E_L_E_T_ = ' ' "
	cQry += "    AND SE1.E1_FILIAL = '"+ xFilial("SE1") +"' "
	If cCodModulo == "F" // Funerária
		cQry += "    AND SE1.E1_XCTRFUN = '"+ cContrato +"' "
	Else //cemitério
		cQry += "    AND SE1.E1_XCONTRA = '"+ cContrato +"' "
	EndIf
	cQry += "ORDER BY SE1.E1_VENCTO, SE1.E1_TIPO, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA"

	If Select("QRYSE1") > 0
		QRYSE1->( DbCloseArea() )
	EndIf

	cQry := ChangeQuery(cQry)
	TcQuery cQry New Alias "QRYSE1"

	If QRYSE1->( !Eof() )
		SE1->( DbSetOrder(1) )//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		While QRYSE1->( !Eof() )
			SE1->( DbGoTo(QRYSE1->RECNOSE1) )
			If SE1->( !Eof() )
				If !ExisteU62(SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
					U_FA040FIN() //PE FA040FIN localizado após a inclusão do título a receber, utilizado para incluir as parcelas na integracao com a vindi
				EndIf
			EndIf
			QRYSE1->( DbSkip() )
		EndDo
	EndIf

	QRYSE1->( DbCloseArea() )

	RestArea(aAreaSE1)
	RestArea(aArea)

Return

/*/{Protheus.doc} ExisteU62
Valido se ja existe inclusão de registro, da entidade cobrança, na U62 para a chave de título informada...
@type function
@version 12.1.33
@author Pablo Nunes
@since 20/12/2022
@param cChave, character, chave do título
@return logical, caso exista retorna .T.
/*/	
Static Function ExisteU62( cChave )

	Local cQry := ""
	Local lRet := .F.

	cQry := " SELECT "
	cQry += " 	U62_CHAVE"
	cQry += " FROM " + RETSQLNAME("U62")
	cQry += " WHERE D_E_L_E_T_ = ' '"
	cQry += " 	AND U62_ENT = '3'" //Entidade da Integracao: 1=Cliente;2=Perfil de Pagamento;3=Cobranca
	cQry += " 	AND U62_OPER = 'I'" //Tipo de Operacao: I=Inclusao;A=Alteracao;E=Exclusao
	//cQry += " 	AND U62_STATUS <> 'C'" //Status da Integracao: P=Pendente;C=Concluido;E=Erro
	cQry += " 	AND RTRIM(U62_CHAVE) = '"+ cChave +"'"

	If Select("QRYU62") > 1
		QRYU62->(DbCloseArea())
	EndIf

	cQry := ChangeQuery(cQry)
	TcQuery cQry New Alias "QRYU62"

	If QRYU62->(!EOF())
		lRet := .T.
	EndIf

	QRYU62->(DbCloseArea())

Return lRet

/*/{Protheus.doc} ValidaErro
Funcao para validar se existem erros
vindos da vindi
@type function
@version 1.0
@author g.sampaio
@since 26/11/2021
@param oJsonVindi, object, objeto do json a ser tratado
@param cMessage, character, mensagem a ser atualizada
@return logical, retorna sobre existir ou nao erros
/*/
Static Function ValidaErro(oJsonVindi, cMessage)

	Local lRetorno	:= .T.
	Local nX		:= 0

	Default oJsonVindi 	:= Nil
	Default cMessage	:= ""

	if ValType(oJsonVindi["errors"]) == "A"
		lRetorno := .F.
		for nX := 1 to Len(oJsonVindi["errors"])
			cMessage += "[IntegraVindi::ConsultaTel] =>" + oJsonVindi["errors"][nX]["message"]
		next nX
	endIf

Return(lRetorno)

/*/{Protheus.doc} NextU65
Funcao para criar a U65
@type function
@version 1.0
@author g.sampaio
@since 21/12/2023
@return character, retorno da numercao da U65
/*/
Static Function NextU65(cCodFaturaUso)

	Local cQuery 		:= ""
	Local cRetorno 		:= ""
	Local nTamU65Num	:= TamSX3("U65_CODIGO")[1]

	Default cCodFaturaUso := ""

	cQuery := " SELECT MAX(U65.U65_CODIGO) MAX_COD "
	cQuery += " FROM " + RetSqlName("U65") + " U65 "
	cQuery += " WHERE U65.U65_MSFIL = '" + cFilAnt + "' "

	If !Empty(cCodFaturaUso)
		cQuery += " AND U65.U65_CODIGO BETWEEN '" + cCodFaturaUso + "' AND '" +Replicate("9", nTamU65Num)+ "'"
	EndIf

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, "TRBU65")

	If TRBU65->(!Eof())
		If !Empty(AllTrim(TRBU65->MAX_COD))
			cRetorno := Soma1(AllTrim(TRBU65->MAX_COD))
		ElseIf !Empty(cCodFaturaUso)
			cRetorno := Soma1(cCodFaturaUso)
		Else
			cRetorno := StrZero(1,TamSX3("U65_CODIGO")[1])
		EndIf
	Else
		cRetorno := StrZero(1,TamSX3("U65_CODIGO")[1])
	EndIf

	// verifico se o codigo esta em uso
	FreeUsedCode()
	While !MayIUseCode( "U65"+xFilial("U65")+cRetorno )
		// gero uma nova fatura
		cRetorno := Soma1( Alltrim(cRetorno) )
	EndDo

Return(cRetorno)
