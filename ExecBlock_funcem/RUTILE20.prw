#INCLUDE 'totvs.ch'
#INCLUDE "restful.ch"
#INCLUDE "APWEBSRV.CH" 
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH" 

/*/{Protheus.doc} RUTILE20
Server API Rest da Funerária para Integracao Virtus Cobranca
@author Leandro Rodrigues
@since 13/08/2019
@version P12
@param nulo
@return nulo
/*/
User Function RUTILE20()
Return()

WSRESTFUL ApiVirtusCob DESCRIPTION "EndPoint do Módulo Funerária para comunicacao com a plataforma Virtus Cobranca" 

	WSDATA cCnpjEmp 	AS CHARACTER 
	WSDATA dDataAtIni	AS DATE 
	WSDATA dDataAtFim	AS DATE 
	WSDATA dDataReag	AS DATE 
	WSDATA nIndiceIni	AS INTEGER
	WSDATA nIndiceFim	AS INTEGER 
	WSDATA cStatus		AS STRING 	
	WSDATA cChave		AS STRING
	WSDATA cCgcCliente	AS STRING 
	WSDATA cBairros		AS STRING OPTIONAL
	WSDATA cCEP			AS STRING OPTIONAL
	WSDATA cCobrador	AS STRING OPTIONAL
	WSDATA cContrato	AS STRING OPTIONAL
	WSDATA cFormaPto	AS STRING OPTIONAL
	WSDATA cObservacao	AS STRING OPTIONAL
	WSDATA cIdPerfil	AS STRING OPTIONAL
	
	WSMETHOD GET ConsultaTitulos;
	DESCRIPTION "Consulta de Contratos e titulos" ;
	PATH "/consultatitulos";
	WSSYNTAX "ApiVirtusCob/consultatitulos/{cCnpjEmp}{cBairros}{cCEP}{cCgcCliente}{cCobrador}{cStatus}{dDataAtIni}{dDataAtFim}{nIndiceIni}{nIndiceFim}"

	WSMETHOD GET PosicaoTitulo;
	DESCRIPTION "Consulta se titulo esta baixado" ;
	PATH "/posicaotitulo";
	WSSYNTAX "ApiVirtusCob/posicaotitulo/{cCnpjEmp}{cChave}"

	WSMETHOD POST BaixaTitulos ;
	DESCRIPTION "Baixa titulos recebidos pelo Virtus Cobranca"; 
	PATH "/baixatitulos";
	WSSYNTAX "ApiVirtusCob/baixatitulos/{cCnpjEmp}"

	WSMETHOD POST Reagendamento;
	DESCRIPTION "Faz o reagendamento de contato de cobranca";
	PATH "/reagendamento";
	WSSYNTAX "ApiVirtusCob/reagendamento/{cCnpjEmp}"

	WSMETHOD POST AlteraFormaPagamento;
	DESCRIPTION "Faz alteracao da forma de pagamento do contrato";  
	PATH "/AlteraFormaPagamento";
	WSSYNTAX "ApiVirtusCob/AlteraFormaPagamento/{cCnpjEmp}{cContrato}{cFormaPto}{cIdPerfil}"


END WSRESTFUL

/*/{Protheus.doc} RUTILE20
Método GET
@author Leandro Rodrigues
@since 13/08/2019
@version P12
@param nulo
@return nulo
/*/

WSMETHOD GET ConsultaTitulos WSRECEIVE cCnpjEmp,cBairros,cCEP,cCgcCliente,cCobrador,cStatus,dDataAtIni,dDataAtFim,nIndiceIni,nIndiceFim WSSERVICE ApiVirtusCob

	Local oResponse		:= JsonObject():New()
	Local oVirtusCob	:=  Nil
	Local cCodEmp		:= ""
	Local cCodFil		:= ""
	Local lRet			:= .T.

	Conout("")
	Conout("")
	Conout("[ApiVirtusCob - RUTILE20 - ConsultaTitulos]")

	//Prepara Classe da integracao com Virtus Cobranca
	oVirtusCob:= VirtusCobranca():New()

	//Busca codig empresa e filial do CNPJ informado
	oVirtusCob:RetEmpFilial(Self:cCnpjEmp,@cCodEmp,@cCodFil)

	//Valido se encontrou empresa
	if Empty(cCodEmp)
		SetRestFault(400, "Nao foi localizado nenhuma empresa para o CNPJ informado")
		lRet := .F.
	Endif

	If lRet

		Self:SetContentType("application/json; charset=utf-8")  

		//prepara a conexao com empresa
		cEmpAnt := cCodEmp
		cFilAnt	:= cCodFil

		
		//Metodo de consulta de titulos
		oVirtusCob:ConsultaCtt(	Self:cBairros,;
									Self:cCEP,;
									Self:cCgcCliente,;
									Self:cCobrador,;
									Self:cStatus,;
									Self:dDataAtIni,;
									Self:dDataAtFim,; 
									Self:nIndiceIni,;
									Self:nIndiceFim,;
									@oResponse,;
									Self:cCnpjEmp)

		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	
	Endif

	FreeObj(oResponse)

Return lRet

/*/{Protheus.doc} RUTILE20
Método Put para Baixa de Titulos	
@author Leandro Rodrigues
@since 13/08/2019
@version P12
@param nulo
@return nulo
/*/
WSMETHOD POST baixatitulos WSRECEIVE cCnpjEmp WSSERVICE ApiVirtusCob

	Local oResponse			:= JsonObject():New()
	Local oJson				:= Nil
	Local cBodyJson			:= ""
	Local lConnect  		:= .F.
	Local cCodEmp			:= ""
	Local cCodFil			:= ""
	Local lRet				:= .T.

	Conout("")
	Conout("")
	Conout("[ApiVirtusCob - RUTILE20 - baixatitulos - Inicio]")

	//Prepara Classe da integracao com Virtus Cobranca
	oVirtusCob:= VirtusCobranca():New()

	//Busca codig empresa e filial do CNPJ informado
	oVirtusCob:RetEmpFilial(Self:cCnpjEmp,@cCodEmp,@cCodFil)

	Self:SetContentType("application/json; charset=utf-8")

	//Valido se encontrou empresa
	if Empty(cCodEmp)
		SetRestFault(400, "Nao foi localizado nenhuma empresa para o CNPJ informado")
		lRet := .F.
	Endif

	if lRet

		cBodyJson := AllTrim(Self:GetContent())

		cEmpAnt := cCodEmp
		cFilAnt	:= cCodFil

		If Alltrim(cCodFil) == Alltrim(cFilAnt)

			Conout("[ApiVirtusCob - RUTILE20 - baixatitulos - Conectado com sucesso]")
			Conout("")
			
			Conout("[ApiVirtusCob - RUTILE20 - baixatitulos - Cnpj: "+Alltrim(Self:cCnpjEmp) +" ]")
			Conout("")

			Conout("[ApiVirtusCob - RUTILE20 - baixatitulos - Filial: " + Alltrim(cFilAnt) + " ]")
			Conout("")
			
			Conout("[ApiVirtusCob - RUTILE20 - baixatitulos] - Json recebido: " + cBodyJson)
			Conout("")

			// converto a string JSON
			if FWJsonDeserialize(cBodyJson,@oJson)

				//Metodo de consulta de titulos
				lRet := oVirtusCob:BaixarTitulos(oJson, @oResponse)

				//valido se retorna o json, caso possua baixas dos titulos ou erros por titulos
				//caso contrario envia mensagem SetRestFault
				if lRet
					
					Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
					lRet := .T.

				else

					Conout("[ApiVirtusCob - RUTILE20 - baixatitulos] - Json recebido esta vazio")
					Conout("")

					SetRestFault(400, "O Json recebido esta vazio")
					lRet := .F.

				endif

			else

				Conout("[ApiVirtusCob - RUTILE20 - baixatitulos] - Json recebido esta invalido")
				Conout("")

				SetRestFault(400, "O Json recebido e invalido"	)
				lRet := .F.

			Endif
		else

			Conout("[ApiVirtusCob - RUTILE20 - baixatitulos] - Falha na conexao com a empresa e filial")
			Conout("")

			SetRestFault(500, "Falha na conexao com a empresa e filial"	)
			lRet := .F.
		
		Endif

	Endif

	Conout("[ApiVirtusCob - RUTILE20 - baixatitulos - Fim]")
	
	FreeObj(oResponse)

Return lRet


/*/{Protheus.doc} RUTILE20
Método GET que retorna se titulo esta baixado
@author Leandro Rodrigues
@since 13/08/2019
@version P12
@param nulo
@return nulo
/*/
WSMETHOD GET posicaotitulo WSRECEIVE cCnpjEmp,cChave WSSERVICE ApiVirtusCob

	Local oResponse		:= JsonObject():New()
	Local lConnect  	:= .F.
	Local oVirtusCob	:=  Nil
	Local cCodEmp		:= ""
	Local cCodFil		:= ""
	Local lRet			:= .T.

	Conout("")
	Conout("")
	Conout("[ApiVirtusCob - RUTILE20 - posicaotitulo]")

	//Prepara Classe da integracao com Virtus Cobranca
	oVirtusCob:= VirtusCobranca():New()

	//Busca codig empresa e filial do CNPJ informado
	oVirtusCob:RetEmpFilial(Self:cCnpjEmp,@cCodEmp,@cCodFil)

	//Valido se encontrou empresa
	if Empty(cCodEmp)
		SetRestFault(400, "Nao foi localizado nenhuma empresa para o CNPJ informado")
		lRet := .F.
	Endif

	if lRet

		Self:SetContentType("application/json; charset=utf-8")  

		//prepara a conexao com empresa
		RpcSetType(3)
		RpcClearEnv()  //-- Limpa ambiente
		lConnect := RpcSetEnv(cCodEmp,cCodFil) 

		// se conseguiu logar na empresa
		if lConnect
			
			//consulta titulo pela chave enviada
			lRet := oVirtusCob:PosicaoTitulo(oResponse,Self:cChave)
		
			if lRet
				Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
			Endif
		else

			SetRestFault(500, "Falha na conexao com a empresa e filial"	)
			lRet:= .F.
		Endif

		RpcClearEnv()
	Endif

	FreeObj(oResponse)

Return lRet 


/*/{Protheus.doc} RUTILE20
Método PUT para fazer reagendamento de cobranca
@author Leandro Rodrigues
@since 13/08/2019
@version P12
@param nulo
@return nulo
/*/
WSMETHOD POST reagendamento WSRECEIVE cCnpjEmp WSSERVICE ApiVirtusCob

	Local oResponse			:= JsonObject():New()
	Local oJson				:= Nil
	Local cBodyJson			:= ""
	Local lConnect  		:= .F.
	Local cCodEmp			:= ""
	Local cCodFil			:= ""
	Local lRet				:= .T.
	Local cCodPreReag		:= ""
	Local lContinua			:= .T.

	Conout("")
	Conout("")
	Conout("[ApiVirtusCob - RUTILE20 - reagendamento]")

	//Prepara Classe da integracao com Virtus Cobranca
	oVirtusCob:= VirtusCobranca():New()

	//Busca codig empresa e filial do CNPJ informado
	oVirtusCob:RetEmpFilial(Self:cCnpjEmp,@cCodEmp,@cCodFil)

	Self:SetContentType("application/json; charset=utf-8")

	//Valido se encontrou empresa
	if Empty(cCodEmp)
		SetRestFault(400, "Nao foi localizado nenhuma empresa para o CNPJ informado")
		lRet := .F.
	Endif

	if lRet

		Self:SetContentType("application/json; charset=utf-8")  

		//prepara a conexao com empresa
		RpcSetType(3)
		RpcClearEnv()  //-- Limpa ambiente
		lConnect := RpcSetEnv(cCodEmp,cCodFil)

		// se conseguiu logar na empresa
		if lConnect

			cBodyJson := AllTrim(Self:GetContent())

			// converto a string JSON
			if FWJsonDeserialize(cBodyJson,@oJson)

				Conout("Json recebido: " + cBodyJson)

				lRet := oVirtusCob:PreReagendamento(@oResponse,oJson,@cCodPreReag)
				
				Begin Transaction 
				
				if lRet
					
					//start um job para atualizar reagendamento
					lRet:= StartJob( "U_StartReag", GetEnvServer(), .T. ,StrTran(oJson:dDataReag,"-",""),oJson:cObservacao,oJson:cCgcCliente,cCodEmp,cCodFil,cCodPreReag )

					If lRet
						
						oResponse["status"] 	:= 200
						oResponse["msg"] 		:= "Operacao realizado com sucesso"
					
					endif

					Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
				else
					
					oResponse["status"] 	:= 400
					oResponse["msg"] 		:= "Ocorreu erro no Reagendamento"	
				Endif

				//se houve falha no processamento
				If !lRet

					DisarmTransaction()

				Endif

				End Transaction
			Endif
		else
		
			SetRestFault(500, "Falha na conexao com a empresa e filial"	)
			lRet:= .F.
		Endif

		RpcClearEnv()

	Endif

	FreeObj(oResponse)

Return lRet


/*/{Protheus.doc} RUTILE20
Método PUT para fazer reagendamento de cobranca
@author Leandro Rodrigues
@since 13/08/2019
@version P12
@param nulo
@return nulo
/*/

WSMETHOD POST AlteraFormaPagamento WSRECEIVE cCnpjEmp,cContrato,cFormaPto,cIdPerfil WSSERVICE ApiVirtusCob

	Local oResponse	:= JsonObject():New()
	Local oJson		:= Nil
	Local cBodyJson	:= ""
	Local lConnect  := .F.
	Local cCodEmp	:= ""
	Local cCodFil	:= ""
	Local lRet		:= .T.

	Conout("")
	Conout("")
	Conout("[ApiVirtusCob - RUTILE20 - AlteraFormaPagamento]")

	//Prepara Classe da integracao com Virtus Cobranca
	oVirtusCob:= VirtusCobranca():New()

	//Busca codig empresa e filial do CNPJ informado
	oVirtusCob:RetEmpFilial(Self:cCnpjEmp,@cCodEmp,@cCodFil)

	Self:SetContentType("application/json; charset=utf-8")  

	//Valido se encontrou empresa
	if Empty(cCodEmp)
		SetRestFault(400, "Nao foi localizado nenhuma empresa para o CNPJ informado")
		lRet := .F.
	Endif

	if lRet

		Self:SetContentType("application/json; charset=utf-8")  

		//prepara a conexao com empresa
		RpcSetType(3)
		RpcClearEnv()  //-- Limpa ambiente
		lConnect := RpcSetEnv(cCodEmp,cCodFil) 

		// se conseguiu logar na empresa
		if lConnect

			lRet := oVirtusCob:AltFormaPgto(oResponse,Self:cContrato,Self:cFormaPto,Self:cIdPerfil)
			
			if lRet
				
				oResponse["status"] 	:= 200
				oResponse["msg"] 		:= "Processo concluido com sucesso!"

				Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
			Endif
		
		else
		
			SetRestFault(500, "Falha na conexao com a empresa e filial"	)
			lRet:= .F.
		Endif

		RpcClearEnv()

	Endif

	FreeObj(oResponse)

Return lRet

/*/{Protheus.doc} RUTILE20
Faz Start de JOB para reagendamento
@author Leandro Rodrigues
@since 13/08/2019
@version P12
@param nulo
@return nulo
/*/
User Function StartReag(dDataReag,cObservacao,cCgcCliente,cCodEmp,cCodFil,cCodPreReag)
	Local lRet := .T.

	//prepara a conexao com empresa
	RpcSetType(3)
	RpcClearEnv()  //-- Limpa ambiente
	lConnect := RpcSetEnv(cCodEmp,cCodFil)

	//Prepara Classe da integracao com Virtus Cobranca
	oVirtusCob:= VirtusCobranca():New()

	lContinua := oVirtusCob:RegCobranca(dDataReag,cObservacao,cCgcCliente)

	UJS->(DbSetOrder(2))
	If UJS->(DbSeek(xFilial("UJS")+cCodPreReag))

		//Atualiza status do processamento
		If RecLock("UJS",.F.)
			UJS->UJS_STATUS := 'S'
			UJS->UJS_ATEND	:= iif(lContinua,"S","N")
			UJS->(MsUnLock())
		Endif
	else
		lRet := .F.
	endif

	RpcClearEnv()

Return lRet
