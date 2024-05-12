#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTILW09
RestFul API para Integração ERP Protheus e App do Cliente
@type function
@version 1.0  
@author g.sampaio
@since 28/06/2021
/*/
User Function RUTILW09
Return(Nil)

WSRESTFUL ApiVirtusCliente DESCRIPTION "EndPoint Virtus ERP para comunicação com o VIRTUS App do Cliente"

	WSDATA cCnpjEmp		AS CHARACTER

	WSMETHOD POST EnviarAlteracoes;
		DESCRIPTION "Enviar alteracoes de dados de clientes";
		PATH "/enviaralteracoes/{cCnpjEmp}";
		WSSYNTAX "/apivirtuscliente/enviaralteracoes/{cCnpjEmp}"

END WSRESTFUL


/*/--------------EnviarAlteracoes------------------//
Metodo REST ppara receber as alteracoes de clientes
@version 1.0
@author g.sampaio
@since 22/09/2021
/*----------------------------------------------*/
WSMETHOD POST EnviarAlteracoes WSSERVICE ApiVirtusCliente

	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local cBodyJson				:= ""
	Local lRetorno				:= .T.
	Local oResponse				:= JsonObject():New()
	Local oAlteracoesClientes	:= Nil
	Local oDadosAlteracoes		:= Nil

	Self:SetContentType("application/json; charset=utf-8")
	Self:SetResponse('')

	If Len(::aURLParms) > 1
		Self:cCnpjEmp := ::aURLParms[2]
	else
		SetRestFault(400, "Obrigatorio informar parametro [cCnpjEmp] na URL.")
		lRetorno := .F.
	endif

	If lRetorno
		RetEmpFilial(Self:cCnpjEmp, @cCodEmp, @cCodFil)

		If Empty(cCodEmp)
			SetRestFault(400, "Nao foi localizado empresa para o CNPJ ["+Self:cCnpjEmp+"] informado.")
			lRetorno := .F.
		else
			cEmpAnt := cCodEmp
			cFilAnt := cCodFil
		EndIf
	Endif

	If lRetorno
		
		oAlteracoesClientes := VirtusAlteraCliente():New()

		cBodyJson := AllTrim( Self:GetContent() )

		//Se tiver algum erro no Parse, encerra a execução
		if Empty(cBodyJson)
			SetRestFault(500,'Nao foi possivel capturar o JSON.')
			lRetorno    := .F.
		else
			If FWJsonDeserialize(cBodyJson, @oDadosAlteracoes)

				If !(AttIsMemberOf(oDadosAlteracoes, "_id") .And. AttIsMemberOf(oDadosAlteracoes, "cgc_cliente"))
					SetRestFault(400, "Atributos _id e cgc_cliente nao informados!")
					lRetorno := .F.
				EndIf

				If lRetorno

					oResponse := oAlteracoesClientes:GravarAlteracoes(oDadosAlteracoes)
					if oResponse <> Nil
						Self:SetResponse( FWJsonSerialize(oResponse, .F., .F., .T.) )
					endif

				EndIf

			Else

				SetRestFault(400, "Body json recebido invalido")
				lRetorno := .F.

			EndIf

		EndIf

	EndIf

	FreeObj(oDadosAlteracoes)
	FreeObj(oResponse)

Return(lRetorno)

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

Return(Nil)
