#Include "Totvs.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTIL019
Rotina que consulta de titulos para integracao Virtus Cobranca
@author Leandro Rodrigues
@since 12/08/2019
@version P12
@param nulo
@return nulo
/*/

Class VirtusCobranca

	Data aHeadOut
	Data nTimeOut

	Method New() Constructor		// Método Construtor
	Method ConsultaCtt() 	   		// Método que consulta titulos para integracao com Virtus
	Method FunerariaConsulta()		// Metodo de Consulta Titulos de contratos funerarios
	Method CemiterioConsulta()		// Metodo de Consulta Titulos de Contratos Cemiterio
	Method BaixarTitulos()			// Metodo que vai fazer a baixa dos titulos recebidos na cobranca
	Method GeraTitAdmFin()			// Metodo que vai incluir titulos contra administradora financeira
	Method RetEmpFilial()			// Metodo que retorna empresa e filial para o CNPJ informado
	Method PosicaoTitulo()			// Metodo que se titulo esta baixado
	Method RegCobranca()			// Metodo que se faz o reagendamento de cobranca do cliente
	Method AltFormaPgto()			// Metodo que se faz alteracao da forma de pagamento do contrato
	Method PreReagendamento()		// Metodo que se faz gravacao do pre reagendamento de retorno do Call Center

EndClass

/*/{Protheus.doc} RUTIL019
Construtor da Classe de Integracao Virtus
@author Leandro Rodrigues
@since 12/08/2019
@version P12
@param nulo
@return nulo
/*/

Method New() Class VirtusCobranca

	Self:aHeadOut		:= {}
	Self:nTimeOut		:= 15

Return()

/*/{Protheus.doc} RUTIL019
Metodo para consultar titulos
@author Leandro Rodrigues
@since 12/08/2019
@version P12
@param Filtro
@return nulo
/*/

Method ConsultaCtt(cBairros,cCEP,cCgcCliente,cCobrador,cStatus,dDataAtIni,dDataAtFim,nIndiceIni,nIndiceFim,oResponse,cCnpjEmp) Class VirtusCobranca

	Local cQCTT	 		:= ""
	Local oJsonCtt 		:= Nil
	Local cContrato 	:= ""
	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
	Local dDataAgenda	:= dDataBase
	Local nJuros		:= 0
	Local nMulta		:= 0
	Local lConsJrMult	:= SuperGetMV("MV_XJURMRV",,.T.)

//verifico se o CNPJ da integracao e de gestao de planos
	if lFuneraria

		cQCTT := ::FunerariaConsulta(cBairros,cCEP,cCgcCliente,cCobrador,cStatus,dDataAtIni,dDataAtFim,nIndiceIni,nIndiceFim)

	elseif lCemiterio

		cQCTT := ::CemiterioConsulta(cBairros,cCEP,cCgcCliente,cCobrador,cStatus,dDataAtIni,dDataAtFim,nIndiceIni,nIndiceFim)

	endif

	cQCTT:= ChangeQuery(cQCTT)

	If Select("QCTT")>1
		QCTT->(DbCloseArea())
	Endif

	TcQuery cQCTT New Alias "QCTT"


	if QCTT->(!Eof())

		oResponse["status"] 	:= 200
		oResponse["contratos"] 	:= {}

		While QCTT->(!EOF())

			FreeObj(oJsonCtt)
			oJsonCtt := JsonObject():New()

			SE1->(DbSetOrder(1)) //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO

			//posiciono no registro para calcular o valor do titulo considerando juros e multa
			cChave:= xFilial("SE1") + QCTT->PREFIXO + QCTT->TITULO + QCTT->PARCELA + QCTT->TIPO

			if SE1->(DbSeek(cChave))

				//considero data de agendamento para definir o valor do titulo que sera enviado para o Virtus
				if !Empty(QCTT->DT_AGENDA)

					dDataAgenda := STOD(QCTT->DT_AGENDA)
				else

					dDataAgenda	:= dDataBase

				endif

				//retona saldo atual do titulo, considerando juros e multa de acordo com a data de agendamento
				if lConsJrMult
					nSaldoAtual := RetSaldoTitulo(dDataAgenda)
				else
					nSaldoAtual := QCTT->SALDO
				endif

				// verifico se o titulo para a cobranca tem saldo
				if nSaldoAtual > 0

					oJsonCtt["contrato" ]  			:= AllTrim(QCTT->CONTRATO)
					oJsonCtt["plano"]  				:= AllTrim(QCTT->PLANO)
					oJsonCtt["dt_ativacao"]			:= AllTrim(QCTT->ATIVACAO)
					oJsonCtt["cgc_cliente"]			:= Alltrim(QCTT->CGC)
					oJsonCtt["nome"]				:= Alltrim(QCTT->NOME)

					// verifico se o endereco de cobranca esta preenchido
					if !Empty(Alltrim(QCTT->ENDERECO_COB))
						oJsonCtt["endereco"]		:= Alltrim(QCTT->ENDERECO_COB)
						oJsonCtt["complemento"]		:= Alltrim(QCTT->COMPLEMENTO_COB)
						oJsonCtt["bairro"]			:= Alltrim(QCTT->BAIRRO_COB)
						oJsonCtt["cep"]				:= Alltrim(QCTT->CEP_COB)
						oJsonCtt["estado"]			:= Alltrim(QCTT->ESTADO_COB)
						oJsonCtt["municipio"]		:= Alltrim(QCTT->MUNICIPIO_COB)
						oJsonCtt["pto_referencia"]	:= Alltrim(QCTT->REF_COBRANCA)
					else
						oJsonCtt["endereco"]		:= Alltrim(QCTT->ENDERECO)
						oJsonCtt["complemento"]		:= Alltrim(QCTT->COMPLEMENTO)
						oJsonCtt["bairro"]			:= Alltrim(QCTT->BAIRRO)
						oJsonCtt["cep"]				:= Alltrim(QCTT->CEP)
						oJsonCtt["estado"]			:= Alltrim(QCTT->ESTADO)
						oJsonCtt["municipio"]		:= Alltrim(QCTT->MUNICIPIO)
						oJsonCtt["pto_referencia"]	:= Alltrim(QCTT->REFERENCIA)
					endIf
					
					oJsonCtt["ddd"]					:= AllTrim(QCTT->DDD)
					oJsonCtt["telefone"]			:= AllTrim(QCTT->TELEFONE)
					oJsonCtt["ddd_celular"]			:= AllTrim(QCTT->DDD_CEL)
					oJsonCtt["celular"]				:= AllTrim(QCTT->CELULAR)
					oJsonCtt["email"]				:= AllTrim(QCTT->EMAIL)

					//somente envia no jason caso exista o campo no dicionario
					if (lFuneraria .And. UF2->(FieldPos("UF2_XCOBDO")) > 0) .Or. (lCemiterio .And. U00->(FieldPos("U00_XCOBDO")) > 0 )
						oJsonCtt["cobra_domicilio"]	:= AllTrim(QCTT->COB_DOMICILIO)
					endif

					oJsonCtt["status_contrato"]		:= AllTrim(QCTT->STATUS)
					oJsonCtt["cnpj"]				:= AllTrim(cCnpjEmp)
					oJsonCtt["dt_agenda"]			:= AllTrim(QCTT->DT_AGENDA)
					oJsonCtt["hora_agenda"]			:= AllTrim(QCTT->HR_AGENDA)

					oJsonCtt["chave"]  		 		:=	AllTrim(cChave)
					oJsonCtt["vencto"] 		 		:=	Alltrim(QCTT->VENCIMENTO)
					oJsonCtt["forma_de_pagamento"] 	:=	AllTrim(QCTT->FORMAPAG)

					oJsonCtt["valor_titulo"] 		:=	cValToChar(nSaldoAtual)

					//add o contrato ao objeto de retorno
					aadd(oResponse["contratos"] , oJsonCtt)

				endIf

			endif

			QCTT->(DbSkip())
		EndDo

	else

		oResponse["status"] := 200
		oResponse["msg"]	:= "Nao ha titulos para consulta especificada"

	Endif

Return

/*/{Protheus.doc} VirtusCobranca::FunerariaConsulta
Metodo para consultar titulos de contratos
funerarios
@author Leandro Rodrigues
@since 12/08/2019
@type function
@version P12
@param cBairros, character, parametro de bairros
@param cCEP, character, parametro de cep
@param cCgcCliente, character, parametro de CGC do cliente
@param cCobrador, character, parametro do cobrador
@param cStatus, character, parametro do status
@param dDataAtIni, date, parametro de data de ativacao inicial
@param dDataAtFim, date, parametro de data de ativacao final
@param nIndiceIni, numeric, parametro de indice inicial
@param nIndiceFim, numeric, parametro de indice final
@return character, retorna a query para consulta
/*/

Method FunerariaConsulta(cBairros,cCEP,cCgcCliente,cCobrador,cStatus,dDataAtIni,dDataAtFim,nIndiceIni,nIndiceFim) Class VirtusCobranca

	Local cQCTT 	:= ""
	Local aArea		:= GetArea()
	Local cXForPgts := FPRecorr()

	Default cBairros	:= ""
	Default cCEP		:= ""
	Default cCgcCliente	:= ""
	Default cCobrador	:= ""
	Default cStatus		:= ""
	Default dDataAtIni	:= Stod("")
	Default dDataAtFim	:= Stod("")
	Default nIndiceIni	:= 0
	Default nIndiceFim	:= 0

	DBSelectArea("UF2")

	//Consulta contratos e beneficiarios
	cQCTT := " SELECT * FROM (
	cQCTT += " 	SELECT"
	cQCTT += "		ROW_NUMBER() OVER (ORDER BY COUNT(UF2_CODIGO) ) AS INDICE,"
	cQCTT += "		UF2_CODIGO		AS CONTRATO, "
	cQCTT += "		UF2_PLANO		AS PLANO, "
	cQCTT += "		UF2_DTATIV		AS ATIVACAO, "
	cQCTT += "		UF2_STATUS		AS STATUS, "

	if UF2->(FieldPos("UF2_XCOBDO")) > 0
		cQCTT += "		UF2_XCOBDO		AS COB_DOMICILIO, "
	endif

	cQCTT += "		A1_CGC			AS CGC, "
	cQCTT += "		A1_NOME			AS NOME,"

	// dados de endereco normal
	cQCTT += "		A1_END			AS ENDERECO,"
	cQCTT += "		A1_COMPLEM		AS COMPLEMENTO,"
	cQCTT += "		A1_BAIRRO		AS BAIRRO,"
	cQCTT += "		A1_CEP			AS CEP ,"
	cQCTT += "		A1_EST			AS ESTADO,"
	cQCTT += "		A1_MUN			AS MUNICIPIO,"
	cQCTT += "		A1_XREFERE		AS REFERENCIA,"

	// dados de dendereco de cobranca
	cQCTT += "		A1_ENDCOB		AS ENDERECO_COB,"
	cQCTT += "		A1_XCOMPCO		AS COMPLEMENTO_COB,"
	cQCTT += "		A1_BAIRROC		AS BAIRRO_COB,"
	cQCTT += "		A1_CEPC			AS CEP_COB,"
	cQCTT += "		A1_ESTC			AS ESTADO_COB,"
	cQCTT += "		A1_MUNC			AS MUNICIPIO_COB,"	
	cQCTT += "		A1_XREFCOB		AS REF_COBRANCA,"
	cQCTT += "		A1_DDD			AS DDD,"
	cQCTT += "		A1_TEL			AS TELEFONE,"
	cQCTT += "		A1_XDDDCEL		AS DDD_CEL,"
	cQCTT += "		A1_XCEL			AS CELULAR,"
	cQCTT += "		A1_EMAIL		AS EMAIL,"
	cQCTT += "		E1_PREFIXO		AS PREFIXO,"
	cQCTT += "		E1_NUM			AS TITULO,"
	cQCTT += "		E1_PARCELA		AS PARCELA,"
	cQCTT += "		E1_TIPO			AS TIPO,"
	cQCTT += "		E1_VENCTO		AS VENCIMENTO,"
	cQCTT += "		E1_SALDO		AS SALDO,"
	cQCTT += "		E1_VALJUR		AS JUROS,"
	cQCTT += "		E1_CLIENTE		AS CLIENTE,"
	cQCTT += "		E1_LOJA			AS LOJA, "
	cQCTT += " 		E1_XFORPG		AS FORMAPAG,"
	cQCTT += " 		E1_XDTCOB		AS DT_AGENDA, "
	cQCTT += " 		E1_XHRCOB		AS HR_AGENDA "
	cQCTT += " 	FROM "
	cQCTT += 	RetSQLName("UF2")   + " UF2"
	cQCTT += " 	INNER JOIN "
	cQCTT +=	RetSQLName("SA1")  + " A1"
	cQCTT += " 	ON A1_FILIAL = '"+ xFilial("SA1") + "'"
	cQCTT += " 	AND A1_COD = UF2_CLIENT"
	cQCTT += " 	AND A1_LOJA= UF2_LOJA"
	cQCTT += " 	AND A1.D_E_L_E_T_ = ' '"
	cQCTT += " 	INNER JOIN ("
	cQCTT += " 					SELECT"
	cQCTT += " 						E1_PREFIXO,"
	cQCTT += " 						E1_NUM,"
	cQCTT += " 						E1_PARCELA,"
	cQCTT += " 						E1_TIPO,"
	cQCTT += " 						E1_VENCTO,"
	cQCTT += " 						E1_SALDO,"
	cQCTT += " 						E1_VALJUR,"
	cQCTT += " 						E1_CLIENTE,"
	cQCTT += " 						E1_LOJA,"
	cQCTT += "						E1_XFORPG,"
	cQCTT += "  					E1_XCTRFUN,"
	cQCTT += "  					E1_XDTCOB, "
	cQCTT += "  					E1_XHRCOB "
	cQCTT += "  					FROM " + RetSQLName("SE1") + " E1 "
	cQCTT += "  					WHERE E1.D_E_L_E_T_  =' '"
	cQCTT += "  					AND E1_FILIAL  = '" + xFilial("SE1") + "' "
	cQCTT += "  					AND E1_SALDO > 0 "
	cQCTT += "  					AND E1_TIPO NOT IN ('NCC','RA','TX','IS','IR','CS','CF','PI','AB')"
	cQCTT += "  					AND E1_VENCTO BETWEEN '" + dTos(dDataAtIni) + "' AND '" + dTos(dDataAtFim) +"' ) AS TITULOS"
	cQCTT += " 	ON  TITULOS.E1_XCTRFUN = UF2.UF2_CODIGO"
	cQCTT += " WHERE UF2.D_E_L_E_T_ = ' '"
	cQCTT += " AND UF2_FILIAL = '"+ xFilial("UF2") + "'"

	//--------------------------------------------------------------------
	//=================== adicionando filtros na query ===================
	//--------------------------------------------------------------------

	//Filtro Status do contrato A-ATIVO | S-SUSPENSO
	cQCTT+= " 	AND UF2_STATUS IN ('" 	+ StrTran(cStatus,",","','" ) + "')"

	// Filtro retira formas de pagtos da recorrencia
	cQCTT += "	AND UF2_FORPG NOT IN " + FormatIn( AllTrim(cXForPgts),";") + " "

	//Filtro por bairros
	If !Empty(cBairros)

		cQCTT+= " AND ( A1_BAIRRO LIKE ('%" + StrTran(Alltrim(cBairros),","," %' OR A1_BAIRRO LIKE '%" ) + "%'))"

	Endif

	//Filtro por Cep
	If !Empty(cCEP)

		cQCTT+= " 	AND A1_CEP IN ('" 	+ StrTran(cCEP,",","','" ) + "')"

	Endif

	//Filtra por cliente
	If !Empty(cCgcCliente)

		cQCTT+= " 	AND  A1_CGC ='"+ Alltrim(cCgcCliente) +  "'"

	Endif

	cQCTT+= "	 GROUP BY UF2_CODIGO,UF2_PLANO,UF2_STATUS,UF2_DTATIV,A1_CGC,A1_NOME,A1_END,"
	cQCTT+= "	 A1_COMPLEM,A1_BAIRRO,A1_CEP,A1_EST,A1_MUN, A1_ENDCOB, A1_XCOMPCO, A1_BAIRROC, A1_CEPC, A1_ESTC, A1_MUNC,A1_XREFERE,A1_XREFCOB,A1_DDD,A1_TEL,A1_XDDDCEL,A1_XCEL,A1_EMAIL,E1_PREFIXO,E1_NUM,"

	if UF2->(FieldPos("UF2_XCOBDO")) > 0

		cQCTT += " UF2_XCOBDO, "

	endif

	cQCTT+= "	 E1_PARCELA,E1_TIPO,E1_VENCTO,E1_SALDO,E1_VALJUR,E1_CLIENTE,E1_LOJA, E1_XFORPG, E1_XDTCOB, E1_XHRCOB "

	cQCTT+= " ) CONTRATOS"

	//limita quantidade de registro que sera retornado
	cQCTT+= " WHERE INDICE >= '" + cValtoChar(nIndiceIni) + "' AND INDICE <= '" + cValToChar(nIndiceFim) + "'"
	cQCTT+= " ORDER BY CONTRATO,TITULO,PARCELA,TIPO"

	RestArea(aArea)

Return(cQCTT)

/*/{Protheus.doc} VirtusCobranca::CemiterioConsulta
Metodo para consultar titulos de contratos
cemiterio
@author Leandro Rodrigues
@type function
@since 12/08/2019
@version P12
@param cBairros, character, parametro de bairros
@param cCEP, character, parametro de cep
@param cCgcCliente, character, parametro de CGC do cliente
@param cCobrador, character, parametro do cobrador
@param cStatus, character, parametro do status
@param dDataAtIni, date, parametro de data de ativacao inicial
@param dDataAtFim, date, parametro de data de ativacao final
@param nIndiceIni, numeric, parametro de indice inicial
@param nIndiceFim, numeric, parametro de indice final
@return character, retorna a query para consulta
/*/

Method CemiterioConsulta(cBairros,cCEP,cCgcCliente,cCobrador,cStatus,dDataAtIni,dDataAtFim,nIndiceIni,nIndiceFim) Class VirtusCobranca

	Local cQCTT 	:= ""
	Local cXForPgts := FPRecorr()

	Default cBairros	:= ""
	Default cCEP		:= ""
	Default cCgcCliente	:= ""
	Default cCobrador	:= ""
	Default cStatus		:= ""
	Default dDataAtIni	:= Stod("")
	Default dDataAtFim	:= Stod("")
	Default nIndiceIni	:= 0
	Default nIndiceFim	:= 0

	DbSelectArea("U00")

	//Consulta contratos e beneficiarios
	cQCTT := " SELECT * FROM (
	cQCTT += " 	SELECT"
	cQCTT += "		ROW_NUMBER() OVER (ORDER BY COUNT(U00_CODIGO) ) AS INDICE,"
	cQCTT += "		U00_CODIGO		AS CONTRATO, "
	cQCTT += "		U00_PLANO		AS PLANO, "
	cQCTT += "		U00_DTATIV		AS ATIVACAO, "
	cQCTT += "		U00_STATUS		AS STATUS, "

	// verifico se o campo existe
	if U00->(FieldPos("U00_XCOBDO")) > 0
		cQCTT += "		''				AS COB_DOMICILIO, "
	endif

	cQCTT += "		A1_CGC			AS CGC, "
	cQCTT += "		A1_NOME			AS NOME,"

	// dados de endereco normal
	cQCTT += "		A1_END			AS ENDERECO,"
	cQCTT += "		A1_COMPLEM		AS COMPLEMENTO,"
	cQCTT += "		A1_BAIRRO		AS BAIRRO,"
	cQCTT += "		A1_CEP			AS CEP ,"
	cQCTT += "		A1_EST			AS ESTADO,"
	cQCTT += "		A1_MUN			AS MUNICIPIO,"
	cQCTT += "		A1_XREFERE		AS REFERENCIA,"

	// dados de dendereco de cobranca
	cQCTT += "		A1_ENDCOB		AS ENDERECO_COB,"
	cQCTT += "		A1_XCOMPCO		AS COMPLEMENTO_COB,"
	cQCTT += "		A1_BAIRROC		AS BAIRRO_COB,"
	cQCTT += "		A1_CEPC			AS CEP_COB,"
	cQCTT += "		A1_ESTC			AS ESTADO_COB,"
	cQCTT += "		A1_MUNC			AS MUNICIPIO_COB,"
	cQCTT += "		A1_XREFCOB		AS REF_COBRANCA,"

	cQCTT += "		A1_DDD			AS DDD,"
	cQCTT += "		A1_TEL			AS TELEFONE,"
	cQCTT += "		A1_XDDDCEL		AS DDD_CEL,"
	cQCTT += "		A1_XCEL			AS CELULAR,"
	cQCTT += "		A1_EMAIL		AS EMAIL,"
	cQCTT += "		E1_PREFIXO		AS PREFIXO,"
	cQCTT += "		E1_NUM			AS TITULO,"
	cQCTT += "		E1_PARCELA		AS PARCELA,"
	cQCTT += "		E1_TIPO			AS TIPO,"
	cQCTT += "		E1_VENCTO		AS VENCIMENTO,"
	cQCTT += "		E1_SALDO		AS SALDO,"
	cQCTT += "		E1_VALJUR		AS JUROS,"
	cQCTT += "		E1_CLIENTE		AS CLIENTE,"
	cQCTT += "		E1_LOJA			AS LOJA, "
	cQCTT += " 		E1_XFORPG		AS FORMAPAG,"
	cQCTT += " 		E1_XDTCOB		AS DT_AGENDA, "
	cQCTT += " 		E1_XHRCOB		AS HR_AGENDA "
	cQCTT += " 	FROM "
	cQCTT += 	RetSQLName("U00")   + " U00 "
	cQCTT += " 	INNER JOIN "
	cQCTT +=	RetSQLName("SA1")  + " A1"
	cQCTT += " 	ON A1_FILIAL = '"+ xFilial("SA1") + "'"
	cQCTT += " 	AND A1_COD = U00_CLIENT"
	cQCTT += " 	AND A1_LOJA= U00_LOJA"
	cQCTT += " 	AND A1.D_E_L_E_T_ = ' '"
	cQCTT += " 	INNER JOIN ("
	cQCTT += " 					SELECT"
	cQCTT += " 						E1_PREFIXO,"
	cQCTT += " 						E1_NUM,"
	cQCTT += " 						E1_PARCELA,"
	cQCTT += " 						E1_TIPO,"
	cQCTT += " 						E1_VENCTO,"
	cQCTT += " 						E1_SALDO,"
	cQCTT += " 						E1_VALJUR,"
	cQCTT += " 						E1_CLIENTE,"
	cQCTT += " 						E1_LOJA,"
	cQCTT += "						E1_XFORPG,"
	cQCTT += "  					E1_XCONTRA,"
	cQCTT += "  					E1_XDTCOB, "
	cQCTT += "  					E1_XHRCOB "
	cQCTT += "  					FROM " + RetSQLName("SE1") + " E1 "
	cQCTT += "  					WHERE E1.D_E_L_E_T_  =' '"
	cQCTT += "  					AND E1_FILIAL  = '" + xFilial("SE1") + "' "
	cQCTT += "  					AND E1_SALDO > 0 "
	cQCTT += "  					AND E1_TIPO NOT IN ('NCC','RA','TX','IS','IR','CS','CF','PI','AB')"
	cQCTT += "  					AND E1_VENCTO BETWEEN '" + dTos(dDataAtIni) + "' AND '" + dTos(dDataAtFim) +"' ) AS TITULOS"
	cQCTT += " 	ON  TITULOS.E1_XCONTRA = U00.U00_CODIGO"
	cQCTT += " WHERE U00.D_E_L_E_T_ = ' '"
	cQCTT += " AND U00_FILIAL = '"+ xFilial("U00") + "'"

	//--------------------------------------------------------------------
	//=================== adicionando filtros na query ===================
	//--------------------------------------------------------------------

	//Filtro Status do contrato A-ATIVO | S-SUSPENSO
	cQCTT+= " 	AND U00_STATUS IN ('" 	+ StrTran(cStatus,",","','" ) + "')"

	// Filtro retira formas de pagtos da recorrencia
	cQCTT += "	AND U00_FORPG NOT IN " + FormatIn( AllTrim(cXForPgts),";") + " "

	//Filtro por bairros
	If !Empty(cBairros)

		cQCTT+= " AND ( A1_BAIRRO LIKE ('%" + StrTran(Alltrim(cBairros),","," %' OR A1_BAIRRO LIKE '%" ) + "%'))"

	Endif

	//Filtro por Cep
	If !Empty(cCEP)

		cQCTT+= " 	AND A1_CEP IN ('" 	+ StrTran(cCEP,",","','" ) + "')"

	Endif

	//Filtra por cliente
	If !Empty(cCgcCliente)

		cQCTT+= " 	AND  A1_CGC ='"+ Alltrim(cCgcCliente) +  "'"

	Endif

	cQCTT+= "	 GROUP BY U00_CODIGO,U00_PLANO,U00_FORPG,U00_STATUS,U00_DTATIV,A1_CGC,A1_NOME,A1_END,"
	cQCTT+= "	 A1_COMPLEM,A1_BAIRRO,A1_CEP,A1_EST,A1_MUN,A1_ENDCOB, A1_XCOMPCO, A1_BAIRROC, A1_CEPC, A1_ESTC, A1_MUNC,A1_XREFERE,A1_XREFCOB,A1_DDD,A1_TEL,A1_XDDDCEL,A1_XCEL,A1_EMAIL,E1_PREFIXO,E1_NUM,"
	cQCTT+= "	 E1_PARCELA,E1_TIPO,E1_VENCTO,E1_SALDO,E1_VALJUR,E1_CLIENTE,E1_LOJA, E1_XFORPG, E1_XDTCOB, E1_XHRCOB "

	cQCTT+= " ) CONTRATOS"

	//limita quantidade de registro que sera retornado
	cQCTT+= " WHERE INDICE >= '" + cValtoChar(nIndiceIni) + "' AND INDICE <= '" + cValToChar(nIndiceFim) + "'"
	cQCTT+= " ORDER BY CONTRATO,TITULO,PARCELA,TIPO"

Return(cQCTT)

/*/{Protheus.doc} RUTIL019
Metodo retonar Empresa e filial do CNPJ informado
@author Leandro Rodrigues
@since 12/08/2019
@version P12
@param Filtro
@return nulo
/*/

Method RetEmpFilial(cCNPJ,cCodEmp,cCodFil) Class VirtusCobranca

	Local aEmpresas		:= FWLoadSM0()
	Local nI			:= 1

	//Encontra empresa e filial com o CNPJ enviado
	For nI := 1 to Len(aEmpresas)

		If aEmpresas[nI,18] == cCNPJ

			cCodEmp := aEmpresas[nI,1] // Grupo
			cCodFil	:= aEmpresas[nI,2] // Filial

		Endif

	Next nI

Return

/*/{Protheus.doc} RUTIL019
Metodo para baixar titulos recebidos pelo Virtus Cobranca
@author Leandro Rodrigues
@since 12/08/2019
@version P12
@param Filtro
@return nulo
/*/
Method BaixarTitulos(oJson, oResponse) Class VirtusCobranca

	Local lRet 		:= .T.
	Local nX		:= 0
	Local oJsonRes 	:= Nil

	Conout("[VirtusCobranca - RUTIL019 - BaixarTitulos - Inicio]")

	oResponse["result"] := {}

	If Len(oJson) > 0
		For nX := 1 To Len(oJson)
			oJsonRes := Nil
			oJsonRes := BaixaTit(oJson[nX])
			aAdd(oResponse["result"], oJsonRes)
		Next nX
	Else
		lRet := .F.
	EndIf

	Conout("[VirtusCobranca - RUTIL019 - BaixarTitulos - Fim]")

Return lRet

/*/{Protheus.doc} RUTIL019
Metodo para consultar posicao do titulo
@author Leandro Rodrigues
@since 12/08/2019
@version P12
@param nulo
@return nulo
/*/

Method PosicaoTitulo(oResponse,cChave) Class VirtusCobranca

	Local lRet := .T.

	SE1->(DbSetOrder(1))

//Posiciono no titulo da chave enviada
	If SE1->(DbSeek(cChave))

		oResponse["status"] 	:= 200
		oResponse["baixado"] 	:= iif(SE1->E1_SALDO == 0,"true","false")

	else
		lRet := .F.
		SetRestFault(400, "Nao foi localizado titulo com a chave "+ cChave + "!")
	Endif

Return lRet


/*/{Protheus.doc} RUTIL019
Metodo para fazer o reagendamento de cobranca do cliente
@author Leandro Rodrigues
@since 12/08/2019
@version P12
@param nulo
@return nulo
/*/

Method RegCobranca(dDataRet,cObservacao,cCgcCliente) Class VirtusCobranca

	Local lRet 		:= .T.
	Local cQry 		:= ""
	Local nDiasCob 	:= SuperGetMv("MV_XDIARET",,1)

	Default dDataRet 	:= ""
	Default cObservacao := ""
	Default cCgcCliente := ""

	cQry := " SELECT
	cQry += " 	TOP 1"
	cQry += " 	ACF_CLIENT,"
	cQry += " 	ACF_PENDEN,"
	cQry += " 	ACF.R_E_C_N_O_ RECNOACF"
	cQry += " FROM " + RETSQLNAME("ACF") + " ACF"
	cQry += " INNER JOIN " + RETSQLNAME("SA1") + " A1"
	cQry += " ON A1_FILIAL = '" + xFilial("SA1") + "'"
	cQry += " 	AND A1_COD = ACF_CLIENT"
	cQry += " 	AND A1_LOJA = ACF_LOJA"
	cQry += " 	AND A1.D_E_L_E_T_ = ' '"
	cQry += " WHERE ACF.D_E_L_E_T_= ' '"
	cQry += " 	AND ACF_FILIAL  = '" + xFilial("ACF") + "'"
	cQry += " 	AND ACF_STATUS  = '2'"
	cQry += " 	AND ACF_OPERA 	= '2'"
	cQry += " 	AND A1_CGC 		='"  + cCgcCliente  + "'"
	cQry += " ORDER BY  ACF_DATA DESC"

	cQry:= ChangeQuery(cQry)

	If Select("QACF")>1
		QACF->(DbCloseArea())
	Endif

	TcQuery cQry New Alias "QACF"

	if QACF->(!EOF())

		//Posiciona no registro
		ACF->(DbGoTo( QACF->RECNOACF ))

		//Valido se a data de retorno é maior que a data do reagendamento informada
		if ACF->ACF_PENDEN < DaySum(sTod(dDataRet) ,nDiasCob)

			dDataRet := DaySum(sTod(dDataRet) ,nDiasCob)

			//Faz alteracao do atendimento
			lRet := AlteraCobranca(ACF->ACF_CODIGO,ACF->ACF_CLIENT,ACF->ACF_LOJA,dDataRet,cObservacao)

		Endif
	else
		lRet := .F.
	endif

Return lRet


/*/{Protheus.doc} RUTIL019
Metodo para fazer o alteracao da forma de pagamento do cliente
@author Leandro Rodrigues
@since 12/08/2019
@version P12
@param nulo
@return nulo
/*/

Method AltFormaPgto(oResponse,cContrato,cFormaPgto,cIdPerfil) Class VirtusCobranca

	Local lRet 			:= .T.
	Local cOldForPg 	:= ""
	Local cCodCli		:= ""
	Local cLoja			:= ""
	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
	Local cCodModulo	:= iif(lFuneraria,"F","C")
	Local cErro			:= ""
	Local cCodBan		:= ""
	Local aCartao		:= {}
	Local cOrigem		:= "RUTIL019"
	Local cOrigemDesc	:= "Alterar Para Recorrencia"

//valido se e filial de funeraria
	if lFuneraria

		UF2->(DbSetOrder(1)) //UF2_FILIAL + UF2_CODIGO

		//Posiciona no contrato
		If UF2->(DbSeek(xFilial("UF2")+ cContrato ))

			cOldForPg := UF2->UF2_FORPG
			cCodCli := UF2->UF2_CLIENT
			cLoja := UF2->UF2_LOJA

		else
			lRet := .F.
			SetRestFault(400, "Contrato informado nao foi localizado!")

		endif

	else

		U00->(DbSetOrder(1)) //U00_FILIAL + U00_CODIGO

		//Posiciona no contrato
		If U00->(DbSeek(xFilial("U00") + cContrato ))

			cOldForPg := U00->U00_FORPG
			cCodCli := U00->U00_CLIENT
			cLoja := U00->U00_LOJA

		else
			lRet := .F.
			SetRestFault(400, "Contrato informado nao foi localizado!")

		endif

	endif

// crio o objeto de integracao com a vindi
	oVindi := IntegraVindi():New()

	if cOldForPg <> cFormaPgto

		// se a forma de pagamento anterior está vinculada a um método de pagamento Vindi
		if !Empty(cOldForPg)

			U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
			if U60->(DbSeek(xFilial("U60") + cOldForPg))

				// Envia arquivamento do cliente para Vindi				
				lRet := U_UVIND20( cCodModulo, cContrato, cCodCli, cLoja, cOrigem, cOrigemDesc )

				if !lRet
					lRet := .F.
					SetRestFault(400, "Não foi possível realizar a exclusão do Cliente/faturas na Vindi!")
				endif

			endif

		endif


		if lRet

			// se a nova forma de pagamento estiver vinculada a um metodo de pagamento VINDI.
			U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
			if U60->(DbSeek(xFilial("U60") + cFormaPgto))

				//-- Verifica se existe contrato em recorrência ativo para cliente
				lRet := U_RecNaoExist( cCodCli, cLoja)
				If lRet

					Begin Transaction

						//Pega dados do perfil de pagamento para gravar no Protheus
						aCartao := oVindi:ConsultaPerfil(cIdPerfil,@cErro,cContrato)

						//De perfil foi encontrado
						if len(aCartao) > 0

							cCodBan := RetCodBan(UPPER(aCartao[05]))

							//Inclui cliente vindi e Perfil de pagamento
							lRet := oVindi:IncManVind(aCartao[06],UF2->UF2_CODIGO,UF2->UF2_CLIENT,UF2->UF2_LOJA,cIdPerfil,;
								cFormaPgto,aCartao[01],aCartao[04],aCartao[02],cCodBan,aCartao[07],cOrigem, cOrigemDesc)

							if lRet

								// atualiza a forma de pagamento do contrato
								U_AtuCtr(cCodModulo,cContrato, cFormaPgto)

								// função que atualiza a forma de pagamento dos títulos a receber
								U_AtuTit( cCodModulo,cContrato, cOldForPg,cFormaPgto)


								// função que altera a forma de pagamento dos títulos em aberto
								// envia a inclusao das faturas para vindi com a nova forma de pagamento
								U_IncFatVindi(cCodModulo,cContrato, cFormaPgto)

							Else

								Ret := .F.
								SetRestFault(400, "Ocorreu um erro na inclusao do Cliente ou Perfil de pagamento no Protheus!")

								DisarmTransaction()
							endif

						else

							Ret := .F.
							SetRestFault(400, "Perfil de pagamento "+ cIdPerfil + " nao foi encontrado na VINDI !")

						endif

					End Transaction

				Else
					Ret := .F.
					SetRestFault(400, "Já existe contrato em recorrência para o cliente informado.")
				EndIf

				//Nao é titulo da vindi
			else

				// atualiza a forma de pagamento do contrato
				U_AtuCtr(cCodModulo,cContrato, cFormaPgto)

				// função que atualiza a forma de pagamento dos títulos a receber
				U_AtuCtr(cCodModulo,cContrato, cOldForPg,cFormaPgto)

			endif

		endif
	else
		Ret := .F.
		SetRestFault(400, "Forma de pagamento do contrato ja esta como "+ Alltrim(cFormaPgto) + "!")
	endif

Return lRet


/*/{Protheus.doc} RUTIL019
Metodo para gravacao de pre reagendamento de retorno Call Center
@author Leandro Rodrigues
@since 12/08/2019
@version P12
@param nulo
@return nulo
/*/
Method PreReagendamento(Response,oJson,cCodPreReag) Class VirtusCobranca

	Local lRet 		  := .T.
	Local cCobrador	  := Padr(Alltrim(oJson:cobrador),TamSx3("UJS_COBRA")[1] )
	Local cCgcCliente := Padr(Alltrim(oJson:cCgcCliente),TamSx3("UJS_CGC")[1] )

	UJS->(DbSetOrder(1))

//Valido se ja existe reagendamento
	If !UJS->(DbSeek(xFilial("UJS") + cCobrador + cCgcCliente + StrTran(oJson:dDataReag,"-","") ))

		cCodPreReag :=GetSX8Num("UJS","UJS_CODIGO")

		//Grava tabela de pre processamento do reagendamento
		If Reclock("UJS",.T.)

			UJS->UJS_FILIAL := xFilial("UJS")
			UJS->UJS_CODIGO := cCodPreReag
			UJS->UJS_DATA	:= dDataBase
			UJS->UJS_HORA	:= Time()
			UJS->UJS_COBRA	:= oJson:cobrador
			UJS->UJS_CGC	:= oJson:cCgcCliente
			UJS->UJS_REAGEN	:= sTod(StrTran(oJson:dDataReag,"-",""))
			UJS->UJS_CONTAT := oJson:Contato
			UJS->UJS_OBSERV	:= oJson:cObservacao
			UJS->UJS_STATUS := "N"  //Nao Processado

			UJS->(MsUnLock())
		EndIf

		ConfirmSX8()
	else
		lRet := .F.
		SetRestFault(400, "Reagendamento ja existe para a data informada!")
	endif

Return lRet

/*/{Protheus.doc} RUTIL019
Execauto de alteracao do atendimento Cobranca
@author Leandro Rodrigues
@since 12/08/2019
@version P12
@param nulo
@return nulo
/*/

Static Function AlteraCobranca(cAtendimento,cCliente,cLoja,dDataRet,cObservacao)

	Local lRet	 := .T.
	Local aCabec := {}
	Local aItens := {}
	local cArqLog		:= "log_imp.log"

	Private lMsErroAuto := .F.
	Private INCLUI 		:= .F.
	Private Altera 		:= .T.

	SetFunName("TMKA271")
	nModulo := 13

//diretorio no server que sera salvo o retorno do execauto
	cDirLogServer := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	cDirLogServer += If(Right(cDirLogServer, 1) <> "\", "\", "")


//Preparo Array de Cabecalho para alteracao
	AADD(aCabec,{"ACF_CODIGO"   ,ACF->ACF_CODIGO   		,Nil})  //Codigo do Atendimento para alteracao
	AADD(aCabec,{"ACF_CLIENT"   ,ACF->ACF_CLIENT   		,Nil})  //Codigo do cliente
	AADD(aCabec,{"ACF_LOJA"     ,ACF->ACF_LOJA      	,Nil})  //Codigo da loja
	AADD(aCabec,{"ACF_PENDEN"   ,dDataRet       		,Nil})  //Data de Retorno
	AADD(aCabec,{"ACF_OBS"      ,cObservacao    		,Nil})	//Observacao
	AADD(aCabec,{"ACF_STATUS"	,"2"					,Nil})
	AADD(aCabec,{"ACF_HRPEND"	,Time()					,Nil})
	AADD(aCabec,{"ACF_FCOM  "	,"ROTINA AUTOMATICA"	,Nil})

	ACG->(DbSetOrder(1))

	If ACG->(DbSeek(xFilial("ACG")+ACF->ACF_CODIGO))

		While !ACG->(Eof()) ;
				.AND. xFilial("ACG") == ACG->ACG_FILIAL .AND. ACG->ACG_CODIGO  == ACF->ACF_CODIGO

			aLinha := {}
			aadd(aLinha,{"ACG_PREFIX"           ,ACG->ACG_PREFIX 		,Nil})  //Prefixo do titulo
			aadd(aLinha,{"ACG_PARCEL"           ,ACG->ACG_PARCEL     	,Nil})  //Parcela do titulo
			aadd(aLinha,{"ACG_TIPO  "           ,ACG->ACG_TIPO       	,Nil})  //Tipo do Titulo
			aadd(aLinha,{"ACG_FILORI"           ,ACG->ACG_FILORI 		,Nil})  //Filial de Origem
			aadd(aLinha,{"ACG_TITULO"           ,ACG->ACG_TITULO 		,Nil})  //Numero do Titulo


			aadd(aItens,aLinha)

			ACG->(Dbskip())
		EndDo
	Endif

	MSExecAuto({|x,y,z,w| TMKA271(x,y,z,w)},aCabec,aItens,4,"3")

	If lMsErroAuto

		cErroExec := MostraErro(cDirLogServer + cArqLog )
		lRet := .F.

	Endif

Return lRet


/*/{Protheus.doc} RUTIL019
Execauto de alteracao do atendimento Cobranca
@author Leandro Rodrigues
@since 12/08/2019
@version P12
@param nulo
@return nulo
/*/

Static Function RetCodBan(cBandeira)

	Local cQryBan := ""

	cQryBan := " SELECT"
	cQryBan	+= " 	U67_CODIGO"
	cQryBan	+= " FROM " + RETSQLNAME("U67")
	cQryBan	+= " WHERE D_E_L_E_T_= ' '"
	cQryBan	+= " 	AND U67_FILIAL  = '"+ xFilial("U67") +"'"
	cQryBan	+= "	AND U67_DESC LIKE '%" + Alltrim(cBandeira) + "%'"

	cQryBan	+= ChangeQuery(cQryBan)

	If Select("QU67")>1
		QU67->(DbCloseArea())
	Endif

	TcQuery cQryBan New Alias "QU67"


Return ( QU67->U67_CODIGO )


/*/{Protheus.doc} NextUF9
Retorna o ultimo item da UF9
@author Raphael Martins Garcia
@since 07/02/2020
@version P12
@param Codigo de Contrato
@return nulo
/*/
Static Function NextUF9(cContrato)

	Local aArea 	:= GetArea()
	Local aAreaSE1	:= SE1->(GetArea())
	Local cQry 		:= ""
	Local cProximo  := StrZero(1,TamSX3("UF9_ITEM")[1])


	if select("TRBUF9") > 0

		TRBUF9->( dbCloseArea() )

	endIf

	cQry := " SELECT "
	cQry += " MAX( UF9.UF9_ITEM ) MAXITEM "
	cQry += " FROM " + RetSqlName("UF9") + " UF9 "
	cQry += " WHERE UF9.D_E_L_E_T_ = ' ' "
	cQry += " AND UF9.UF9_CODIGO = '" + Alltrim(cContrato) + "' "
	cQry += " AND UF9.UF9_FILIAL = '" + xFilial("UF9") +"' "

	cQuery  := ChangeQuery( cQry )

	TcQuery cQuery new alias "TRBUF9"

// verifico se existe registro
	if TRBUF9->( !eof() )

		cProximo := soma1( TRBUF9->MAXITEM )

	endIf


	RestArea(aArea)
	RestArea(aAreaSE1)

Return(cProximo)

/*/{Protheus.doc} NextUF9
Retorna o ultimo item da UF9
@author Raphael Martins Garcia
@since 07/02/2020
@version P12
@param Codigo de Contrato
@return nulo
/*/
Static Function NextU03(cContrato)

	Local aArea 	:= GetArea()
	Local aAreaSE1	:= SE1->(GetArea())
	Local cQry 		:= ""
	Local cProximo  := StrZero(1,TamSX3("U03_ITEM")[1])


	if select("TRBU03") > 0

		TRBU03->( dbCloseArea() )

	endIf

	cQry := " SELECT "
	cQry += " MAX( U03.U03_ITEM ) MAXITEM "
	cQry += " FROM " + RetSqlName("U03") + " U03 "
	cQry += " WHERE U03.D_E_L_E_T_ = ' ' "
	cQry += " AND U03.U03_CODIGO = '" + Alltrim(cContrato) + "' "
	cQry += " AND U03.U03_FILIAL = '" + xFilial("U03") +"' "

	cQuery  := ChangeQuery( cQry )

	TcQuery cQuery new alias "TRBU03"

// verifico se existe registro
	if TRBU03->( !eof() )

		cProximo := soma1( TRBU03->MAXITEM )

	endIf


	RestArea(aArea)
	RestArea(aAreaSE1)

Return(cProximo)


/*/{Protheus.doc} RetSaldoTitulo
Funcao para retornar o saldo atual do titulo
considerando juros e multa
@author Raphael Martins Garcia
@since 07/02/2020
@version P12
@param Codigo de Contrato
@return nulo
/*/
Static Function RetSaldoTitulo(dDataAgenda)

	Local aArea		:= GetArea()
	Local aAreaSE1	:= SE1->(GetArea())
	Local nValor	:= 0
	Local nJuros	:= 0
	Local nMulta	:= 0
	Local nSaldoAt	:= 0

//retorna o saldo do titulo naquela data
	nValor := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,;
		SE1->E1_MOEDA,,dDataAgenda,SE1->E1_LOJA,,,1)

//retorna Juros 
	nJuros := LojxRJur(, , , ,  SE1->E1_SALDO,;
		SE1->E1_ACRESC  , "SE1", , SE1->E1_MOEDA, dDataAgenda,SE1->E1_VENCREA, ,SE1->E1_JUROS)


//Retorna a Multa em caso de atraso
	nMulta := LojxRMul( .F., , ,SE1->E1_SALDO, SE1->E1_ACRESC, SE1->E1_VENCREA, dDataAgenda , , SE1->E1_MULTA, ,;
		SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, "SE1",.T. )

//Saldo Atual do Titulo considerando Juros e Multa
	nSaldoAt := nValor + nJuros + nMulta

	RestArea(aArea)
	RestArea(aAreaSE1)

Return(nSaldoAt)

/*/{Protheus.doc} BaixaTit
Baixa titulos do cobrador no contas a receber
Gera titulo contra a administradora
@type function
@version 1.0
@author nata.queiroz
@since 06/03/2020
@param oJson, object
@return oJsonCob, object
/*/
Static Function BaixaTit(oJson)

	Local aArea			:= GetArea()
	Local aAreaSE1		:= SE1->( GetArea() )
	Local aAreaSA6		:= SA6->( GetArea() )
	Local aAreaSA3		:= SA3->( GetArea() )
	Local aAreaSE3		:= SE3->( GetArea() )
	Local aFormaPg		:= {}
	Local nI			:= 0
	Local nValDesc		:= 0
	Local nValJuros		:= 0
	Local nTotalRec		:= 0
	Local nValorParcela	:= 0
	Local nQtdParc		:= 1
	Local cCaixa		:= ""
	Local cAdmCredito	:= SuperGetMv("MV_XCODADQ",,"002")
	Local cAdmDebito	:= SuperGetMv("MV_XFPCD",,"CD")
	Local cFormaPgto	:= ""
	Local cCodModulo	:= ""
	Local cLoteBx		:= ""
	Local cErro			:= ""
	Local lProcessa		:= .T.
	Local lRet			:= .F.
	Local cCodNsu		:= ""
	Local cCobrador		:= ""
	Local cAutorizacao	:= ""
	Local cBandeira		:= Upper(Alltrim(SuperGetMv("MV_XBANDPA",,"master")))
	Local oJsonCob		:= Nil
	Local oJsonTit		:= Nil

	Conout(Replicate("#",80))

	Conout("[VirtusCobranca - RUTIL019 - Cobrador "+ AllTrim(oJson:CPF_COBRADOR) +"]")

	FreeObj(oJsonCob)
	oJsonCob := JsonObject():New()
	oJsonCob["cobrador"] := AllTrim(oJson:CPF_COBRADOR)

	SA6->(DbSetOrder(1))

	cForPgto 	:= Alltrim(oJson:Forma_Pagamento)
	nQtdParc	:= Val(oJson:quantidade_parcelas)

	//caso nao seja informado a quantidade, sera sempre gerado 1 parcela
	if Val(oJson:quantidade_parcelas) <> NIL
		nQtdParc	:= Val(oJson:quantidade_parcelas)
	endif

	//Posiciono no titulos enviado
	SE1->(DbSetOrder(1))
	SA3->(DbSetOrder(3))

	//Posiciono no vendedor com CGC
	IF SA3->(DbSeek(xFilial("SA3") + PADR(Alltrim(oJson:CPF_COBRADOR),TamSx3("A3_CGC")[1]) ))

		Conout("[VirtusCobranca - RUTIL019 - Filial/Codigo/Nome Cobrador: "+ SA3->A3_FILIAL + "/" + SA3->A3_COD + "/" + SA3->A3_NOME + "")

		//Pego o caixa e o codigo do cobrador
		cCaixa 		:= SA3->A3_BCO1
		cCobrador	:= SA3->A3_COD

		//Posiciona no banco
		If SA6->(DbSeek(xFilial("SA6")+cCaixa))

			//Inicializo Status de retorno dos titulos
			oJsonCob["titulos"] := {}

			For nI:= 1 to Len(oJson:Baixas)

				Conout(Replicate("#",80))

				Conout("[VirtusCobranca - RUTIL019 - Titulo "+ cValToChar(nI) +" => "+ oJson:Baixas[nI]:Chave +"]")

				Begin Transaction

					FreeObj(oJsonTit)
					oJsonTit:= JsonObject():New()

					//posiciono no titulo
					if SE1->(DbSeek( oJson:Baixas[nI]:Chave ))

						//Verifico se é contrato de funeraria ou Cemiterio
						if Empty(SE1->E1_XCTRFUN)
							cCodModulo:= "F"
							cContrato := SE1->E1_XCTRFUN
						else
							cCodModulo:= "C"
							cContrato := SE1->E1_XCONTRA
						Endif

						If SE1->E1_SALDO > 0

							//Altero a data base do sistem para baixar o titulo
							dDataBase := sTod(oJson:Baixas[nI]:Data_Baixa)

							//Atualiza Variaveis
							nValRec	 	:= Val(oJson:Baixas[nI]:Valor_Titulo)
							nValJuros	:= Val(oJson:Baixas[nI]:Valor_Juros)
							nValDesc 	:= Val(oJson:Baixas[nI]:Valor_Desconto)
							nValMulta	:= Val(oJson:Baixas[nI]:Valor_Multa)

							//Valido se a forma de pagamento é cartao para pegar NSU, gateway e codigo de autorizacao
							if cForPgto $ "CC|CD"
								cCodNsu	  		:= oJson:Baixas[nI]:Nsu

								//caso seja recebimento manual, utiliza a adquirente do parametro MV_XCODADQ
								if oJson:Baixas[nI]:gateway <> Nil
									cCodAdm			:= oJson:Baixas[nI]:gateway

									//cartao de credito
								elseif Alltrim(cForPgto) == "CC"
									cCodAdm := cAdmCredito
									//cartao de debito
								elseif 	Alltrim(cForPgto) == "CD"
									cCodAdm := cAdmDebito
								endif

								cAutorizacao	:= oJson:Baixas[nI]:aut

								//para recebimento manual nao possui bandeira
								if oJson:Baixas[nI]:bandeira <> NIL
									cBandeira		:= oJson:Baixas[nI]:bandeira
								endif

							else
								cCodNsu	  := ""
							Endif

							//Guardo valor pra gerar contra adm finan
							nTotalRec += (nValRec+nValJuros+nValMulta) - nValDesc

							//Chamo funcao para baixar titulos pelo loja
							If !U_BxTitulosFin(oJson:Baixas[nI]:Chave,cForPgto,dDataBase,nValRec,cCaixa,@cLoteBx,@cErro,@lProcessa,nValJuros,nValMulta,nValDesc)

								//retorno de erro
								oJsonTit["chave"]	:= oJson:Baixas[nI]:Chave
								oJsonTit["erro" ]	:= cErro

								Conout("[VirtusCobranca - RUTIL019] - Erro na baixa do titulo da cobranca!")
								Conout("[VirtusCobranca - RUTIL019]- " + cErro)

								//Se ocorreu erro desfaz operacao
								DisarmTransaction()

							else

								//Se titulo foi baixado com sucesso gravo o codigo do cobrado no titulo
								If SE1->( Reclock("SE1",.F.) )
									SE1->E1_XCOBMOB := cCobrador
									SE1->(MsUnLock())
								Endif

								//retorno de sucesso
								lRet		:= .T.
								oJsonTit["chave"]		:= oJson:Baixas[nI]:Chave
								oJsonTit["response" ]	:= "Titulo baixado com sucesso"

								if ValType( oJson:Baixas[nI]:Chave ) == "C"
									Conout("[VirtusCobranca - RUTIL019] - " + oJson:Baixas[nI]:Chave )
								endIf 

								Conout("[VirtusCobranca - RUTIL019] - Titulo baixado com sucesso")

							EndIf
						else
							//retorno do erro
							oJsonTit["chave"]	:= oJson:Baixas[nI]:Chave
							oJsonTit["erro" ]	:= "Titulo nao possui saldo"

							Conout("[VirtusCobranca - RUTIL019] - Titulo nao possui saldo")

						Endif
					Else

						//retorno do erro
						oJsonTit["chave"]	:= oJson:Baixas[nI]:Chave
						oJsonTit["erro" ]	:= "Titulo nao encontrado no contas a receber"

						Conout("[VirtusCobranca - RUTIL019 - Titulo nao encontrado no contas a receber")

					endif

				End Transaction

				aadd(oJsonCob["titulos"] , oJsonTit)

				Conout(Replicate("#",80))

			Next nI

			//Se baixou titulos e forma de pagamento for cartao inclui titulo contra adm
			If lRet .AND. cForPgto $ "CH|CC|CD"

				nValorParcela := nTotalRec / nQtdParc

				aFormaPg := {cForPgto,;			//Forma de Pagamento
				cCodAdm,;						//Codigo da Gateway
				"",;							//Numero Cheque (Nao utilizado)
				"",;							//portador (Nao Utilizado)
				"",;							//agencia (Nao utilizado)
				"",;							//conta (Nao utilizado)
				nValorParcela,;					//valor total recebido
				nQtdParc,;						//quantidade de parcelas
				"",;							//vencimento cheque (nao utilizado)
				cBandeira,;						//bandeira utilizada
				cCodNsu,;						//codigo NSU
				cAutorizacao}					//codigo de autorizacao

				//gero titulo contra a administradora
				lRet := U_LjIncTitRec(aFormaPg,,cLoteBx,dDataBase,,,nQtdParc,@cErro)

				if !lRet
					Conout("[VirtusCobranca - RUTIL019 - Erro na geracao do titulo contra a administradora")
				endif

			endif

		else

			lRet 		:= .F.
			oJsonCob["fault"] := "Banco vinculado para o cobrador nao foi encontrado"
			Conout("[VirtusCobranca - RUTIL019 - Banco vinculado para o cobrador nao foi encontrado")

		Endif

	else

		lRet := .F.
		oJsonCob["fault"] := "Cadastro do cobrador nao foi encontrado"
		Conout("[VirtusCobranca - RUTIL019 - Cadastro do cobrador nao foi encontrado")

	endif

	Conout(Replicate("#",80))

	RestArea(aAreaSE3)
	RestArea(aAreaSA3)
	RestArea(aAreaSE1)
	RestArea(aAreaSA6)
	RestArea(aArea)

Return oJsonCob

/*/{Protheus.doc} FPRecorr
Retorna formas de pagto cadastrados na recorrencia
@type function
@version 1.0
@author nata.queiroz
@since 23/12/2020
@return character, cXForPgts
/*/
Static Function FPRecorr()
	Local aArea := GetArea()
	Local aAreaU60 := U60->( GetArea() )
	Local cXForPgts := ""

	U60->( DbSetOrder(1) )	
	If U60->( MsSeek( xFilial("U60") ) )
		While U60->(!EOF()) .And. U60->U60_FILIAL == xFilial("U60")

			// verifico se tem conteudo, e adiciono o separador ';'
			if !Empty(cXForPgts)
				cXForPgts += ";"
			endIf

			cXForPgts += AllTrim(U60->U60_FORPG)

			U60->( DbSkip() )
		EndDo
	EndIf

	RestArea(aAreaU60)
	RestArea(aArea)	

Return cXForPgts
