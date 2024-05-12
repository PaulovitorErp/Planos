#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTILW08
RestFul API para Integração Virtus Cobranca
@type function
@version 1.0
@author nata.queiroz
@since 25/02/2021
/*/
User Function RUTILW08
Return

	WSRESTFUL ApiVirtusCob2 DESCRIPTION "EndPoint Virtus ERP para comunicação com a plataforma Virtus Cobranca"

		WSDATA cCnpjEmp		AS CHARACTER
		WSDATA cBairros		AS STRING    OPTIONAL
		WSDATA cCEP			AS STRING    OPTIONAL
		WSDATA cCgcCliente	AS STRING    OPTIONAL
		WSDATA cStatus		AS STRING    OPTIONAL
		WSDATA dDataAtIni	AS DATE      OPTIONAL
		WSDATA dDataAtFim	AS DATE      OPTIONAL
		WSDATA nSkip		AS INTEGER   OPTIONAL
		WSDATA nLimit		AS INTEGER   OPTIONAL

		WSMETHOD GET TotalCobrancas;
			DESCRIPTION "Consulta Total de Cobrancas";
			PATH "/totalcobrancas";
			WSSYNTAX "ApiVirtusCob2/totalcobrancas/{cCnpjEmp}{cBairros}{cCEP}{cCgcCliente}{cStatus}{dDataAtIni}{dDataAtFim}"

		WSMETHOD GET ConsultarCobrancas;
			DESCRIPTION "Consulta de Cobrancas";
			PATH "/consultarcobrancas";
			WSSYNTAX "ApiVirtusCob2/consultarcobrancas/{cCnpjEmp}{cBairros}{cCEP}{cCgcCliente}{cStatus}{dDataAtIni}{dDataAtFim}{nSkip}{nLimit}"

		WSMETHOD POST EnviarPagamentos;
			DESCRIPTION "Enviar Pagamentos";
			PATH "/enviarpagamentos/{cCnpjEmp}";
			WSSYNTAX "ApiVirtusCob2/enviarpagamentos/{cCnpjEmp}"

	END WSRESTFUL

	WSMETHOD GET TotalCobrancas WSRECEIVE cCnpjEmp, cBairros, cCEP, cCgcCliente,;
		cStatus, dDataAtIni, dDataAtFim WSSERVICE ApiVirtusCob2

	Local oResponse			:= JsonObject():New()
	Local lConnect			:= .F.
	Local oVirtusCobranca2	:=  Nil
	Local cCodEmp			:= ""
	Local cCodFil			:= ""
	Local lRet				:= .T.

	Conout("")
	Conout("")
	Conout("[ApiVirtusCob2 - RUTILW08 - TotalCobrancas]")

	RetEmpFilial(Self:cCnpjEmp, @cCodEmp, @cCodFil)

	If Empty(cCodEmp)
		SetRestFault(400, "Nao foi localizado empresa para o CNPJ ["+Self:cCnpjEmp+"] informado.")
		lRet := .F.
	else
		cEmpAnt := cCodEmp
		cFilAnt := cCodFil
	EndIf

	If lRet

		oVirtusCobranca2 := VirtusCobranca2():New()

		If Empty(cCodEmp)
			SetRestFault(400, "Nao foi localizado nenhuma empresa para o CNPJ informado.")
			lRet := .F.
		EndIf

		If lRet

			Self:SetContentType("application/json; charset=utf-8")

			If lConnect

				oVirtusCobranca2:totalCobrancas(Self:cCnpjEmp,;
					Self:cBairros,;
					Self:cCEP,;
					Self:cCgcCliente,;
					Self:cStatus,;
					Self:dDataAtIni,;
					Self:dDataAtFim,;
					@oResponse)

				Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )

			Else

				SetRestFault(500, "Nao conectou na empresa e filial")
				lRet:= .F.

			EndIf

		EndIf

	EndIf

	FreeObj(oResponse)

Return lRet

	WSMETHOD GET ConsultarCobrancas WSRECEIVE cCnpjEmp, cBairros, cCEP, cCgcCliente,;
		cStatus, dDataAtIni, dDataAtFim, nSkip, nLimit WSSERVICE ApiVirtusCob2

	Local oResponse			:= JsonObject():New()
	Local lConnect			:= .F.
	Local oVirtusCobranca2	:=  Nil
	Local cCodEmp			:= ""
	Local cCodFil			:= ""
	Local lRet				:= .T.

	Conout("")
	Conout("")
	Conout("[ApiVirtusCob2 - RUTILW08 - ConsultarCobrancas]")

	RetEmpFilial(Self:cCnpjEmp, @cCodEmp, @cCodFil)

	If Empty(cCodEmp)
		SetRestFault(400, "Nao foi localizado empresa para o CNPJ ["+Self:cCnpjEmp+"] informado.")
		lRet := .F.
	else
		cEmpAnt := cCodEmp
		cFilAnt := cCodFil
	EndIf

	If lRet

		oVirtusCobranca2 := VirtusCobranca2():New()

		If Empty(cCodEmp)
			SetRestFault(400, "Nao foi localizado nenhuma empresa para o CNPJ informado.")
			lRet := .F.
		EndIf

		If lRet

			Self:SetContentType("application/json; charset=utf-8")

			If lConnect

				oVirtusCobranca2:consultarCobrancas(Self:cCnpjEmp,;
					Self:cBairros,;
					Self:cCEP,;
					Self:cCgcCliente,;
					Self:cStatus,;
					Self:dDataAtIni,;
					Self:dDataAtFim,;
					Self:nSkip,;
					Self:nLimit,;
					@oResponse)

				Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )

			Else

				SetRestFault(500, "Nao conectou na empresa e filial")
				lRet:= .F.

			EndIf

			RpcClearEnv()

		EndIf

	EndIf

	FreeObj(oResponse)

Return(lRet)

WSMETHOD POST EnviarPagamentos PATHPARAM cCnpjEmp WSSERVICE ApiVirtusCob2

	Local oResponse			:= JsonObject():New()
	Local lRet				:= .T.
	Local oVirtusCobranca2	:=  Nil
	Local cCodEmp			:= ""
	Local cCodFil			:= ""
	Local cBodyJson			:= ""
	Local oPagamento		:= Nil
	Local lFuneraria		:= ""
	Local lCemiterio		:= ""
	Local cCodModulo		:= ""
	Local cTipoEnt			:= ""

	Conout("")
	Conout("")
	Conout("[ApiVirtusCob2 - RUTILW08 - EnviarPagamentos]")

	RetEmpFilial(Self:cCnpjEmp, @cCodEmp, @cCodFil)

	If Empty(cCodEmp) .Or. Empty(cCodFil)
		SetRestFault(500, "Nao foi localizado empresa para o CNPJ ["+Self:cCnpjEmp+"] informado.")
		lRet := .F.
	else
		cEmpAnt := cCodEmp
		cFilAnt := cCodFil
		
		Conout("")
		Conout("")
		Conout("[ApiVirtusCob2 - RUTILW08 - cCodEmp: "+cCodEmp+" | cCodFil: "+cCodFil+" ")
	EndIf

	If lRet

		oVirtusCobranca2 := VirtusCobranca2():New()

		Self:SetContentType("application/json; charset=utf-8")

		cBodyJson := AllTrim( Self:GetContent() )

		If FWJsonDeserialize(cBodyJson, @oPagamento)

			If !(AttIsMemberOf(oPagamento, "_id") .And. AttIsMemberOf(oPagamento, "add_recorrencia"))
				SetRestFault(400, "Atributos _id ou add_recorrencia nao informados")
				lRet:= .F.
			EndIf

			If lRet

				lFuneraria	:= SuperGetMV("MV_XFUNE", .F., .F.)
				lCemiterio	:= SuperGetMV("MV_XCEMI", .F., .F.)

				If lFuneraria
					cCodModulo := "F"
				ElseIf lCemiterio
					cCodModulo := "C"
				EndIf

				If oPagamento:add_recorrencia
					cTipoEnt := "2" // Recorrencia
				Else
					cTipoEnt := "1" // Pagamento
				EndIf

				oResponse := oVirtusCobranca2:gravarPagamento(cCodModulo, cTipoEnt, oPagamento:_id, cBodyJson)


				Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )

			EndIf

		Else

			SetRestFault(400, "Body json recebido invalido")
			lRet:= .F.

		EndIf

	EndIf

	FreeObj(oVirtusCobranca2)
	FreeObj(oResponse)

Return(lRet)

/*/{Protheus.doc} RetEmpFilial
Retorna codigo da empresa/filial pelo cnpj
@type function
@version 1.0
@author nata.queiroz
@since 3/1/2021
@param cCnpj, character, cCnpj
@param cCodEmp, character, cCodEmp
@param cCodFil, character, cCodFil
/*/
Static Function RetEmpFilial(cCnpj, cCodEmp, cCodFil)
	Local aEmpresas		:= FWLoadSM0()
	Local nI			:= 1

	// Encontra empresa e filial com o CNPJ enviado
	For nI := 1 To Len(aEmpresas)

		If aEmpresas[nI,18] == cCnpj

			cCodEmp := aEmpresas[nI,1] // Grupo
			cCodFil	:= aEmpresas[nI,2] // Filial

		EndIf

	Next nI

Return
