#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTILW12
para Integacao com o Modulo Gestão de Cemiterios
@type function
@version 1.0  
@author g.sampaio
@since 22/04/2023
/*/
User Function RUTILW12
Return(Nil)

	/*/{Protheus.doc} ApiVirtusConnector
	API Virtus Connector
	@type method
	@version 1.0
	@author g.sampaio
	@since 22/12/2023
	/*/
	WSRESTFUL ApiVirtusConnector DESCRIPTION "API Virtus Connector para Integracao com os Módutos ERP da Plataforma Virtus: Gestão de Cemitérios e Gestão de Planos Assintenciais e Serviços Funerários"

		WSDATA cCnpjEmp			AS CHARACTER
		WSDATA cProduto			AS CHARACTER	OPTIONAL
		WSDATA cFormaPag		AS CHARACTER	OPTIONAL
		WSDATA nQtdPar			AS INTEGER		OPTIONAL
		WSDATA nValorEntrada	AS INTEGER		OPTIONAL
		WSDATA nValorDesconto	AS INTEGER		OPTIONAL
		WSDATA cQuadra			AS CHARACTER	OPTIONAL
		WSDATA cModulo			AS CHARACTER	OPTIONAL
		WSDATA cJazigo			AS CHARACTER	OPTIONAL
		WSDATA cLocacao			AS CHARACTER	OPTIONAL
		WSDATA cCGCCliente		AS CHARACTER	OPTIONAL
		WSDATA cNomeCliente		AS CHARACTER	OPTIONAL
		WSDATA cContrato		AS CHARACTER	OPTIONAL
		WSDATA cCNPJServicos 	AS CHARACTER	OPTIONAL
		WSDATA cBeneficiario 	AS CHARACTER	OPTIONAL
		WSDATA cProdServ 		AS CHARACTER	OPTIONAL
		WSDATA cTabAlias 		AS CHARACTER	OPTIONAL
		WSDATA cUsaContrato 	AS CHARACTER	OPTIONAL
		WSDATA cDataIni 		AS CHARACTER	OPTIONAL
		WSDATA cDataFim 		AS CHARACTER	OPTIONAL
		WSDATA nSkip			AS INTEGER   	OPTIONAL
		WSDATA nLimit			AS INTEGER   	OPTIONAL

		WSMETHOD GET PrecoVenda;
			DESCRIPTION "Cemiterio - Consulta de Preco de Venda de Produtos";
			PATH "/precovenda";
			WSSYNTAX "ApiVirtusConnector/precovenda"

		WSMETHOD GET TotalJazigos;
			DESCRIPTION "Cemiterio - Consulta do Total de Jazigos Disponiveis";
			PATH "/totaljazigos";
			WSSYNTAX "ApiVirtusConnector/totaljazigos

		WSMETHOD GET GetCliente;
			DESCRIPTION "Cemiterio e Planos Funerarios - Consulta de Clientes";
			PATH "/consultacliente";
			WSSYNTAX "ApiVirtusConnector/consultacliente"

		WSMETHOD GET GetContrato;
			DESCRIPTION "Cemiterio e Planos Funerarios - Consulta de Contratos";
			PATH "/consultacontrato";
			WSSYNTAX "ApiVirtusConnector/consultacontrato"

		WSMETHOD GET GetEnderecados;
			DESCRIPTION "Cemiterio - Sepultados e Enderecados no Contrato";
			PATH "/sepultadoscontrato";
			WSSYNTAX "ApiVirtusConnector/sepultadoscontrato"

		WSMETHOD GET GetJazigoContrato;
			DESCRIPTION "Cemiterio - Consulta de Jazigo do Contrato";
			PATH "/jazigocontrato";
			WSSYNTAX "ApiVirtusConnector/jazigocontrato"

		WSMETHOD GET CemContrato;
			DESCRIPTION "Cemiterio - Dados de Contrato de Cemiterio";
			PATH "/contratocemiterio";
			WSSYNTAX "ApiVirtusConnector/contratocemiterio"

		WSMETHOD GET ConsultaJazigo;
			DESCRIPTION "Cemiterio - Consulta de disponibilidade de Jazigos";
			PATH "/consultajazigo";
			WSSYNTAX "ApiVirtusConnector/consultajazigo"

		WSMETHOD GET PrecosFuneraria;
			DESCRIPTION "Serviços Funerários - Consulta de precos no apontamento de servicos.";
			PATH "/precosfuneraria";
			WSSYNTAX "ApiVirtusConnector/precosfuneraria"

		WSMETHOD GET GetModelVirtus;
			DESCRIPTION "Modelo de Dados - Metodo para retorno do modelo de dados para inclusao de apontamentos de servicos.";
			PATH "/getmodelvirtus";
			WSSYNTAX "ApiVirtusConnector/getmodelvirtus"

		WSMETHOD GET GetAgendamento;
			DESCRIPTION "Cemiterio - Metodo para consultar os agendamentos.";
			PATH "/getagendamento";
			WSSYNTAX "ApiVirtusConnector/getagendamento"

		WSMETHOD GET TotalAgendamento;
			DESCRIPTION "Cemiterio - Metodo para retornar o totalizadores de agendamento.";
			PATH "/totalagendamento";
			WSSYNTAX "ApiVirtusConnector/totalagendamento"

		WSMETHOD GET GetTipoSolicitacao;
			DESCRIPTION "Cemiterio - Metodo para retornar os tipos de solicitacao.";
			PATH "/tiposolicitacao";
			WSSYNTAX "ApiVirtusConnector/tiposolicitacao"

		WSMETHOD GET GetSolicitacao;
			DESCRIPTION "Cemiterio - Metodo para consultar as solicitacoes.";
			PATH "/getsolicitacao";
			WSSYNTAX "ApiVirtusConnector/getsolicitacao"

		WSMETHOD GET TotalSolicitacao;
			DESCRIPTION "Cemiterio - Metodo para retornar o totalizadores de solicitacao.";
			PATH "/totalsolicitacao";
			WSSYNTAX "ApiVirtusConnector/totalsolicitacao"

		WSMETHOD GET GetGrauParentesco;
			DESCRIPTION "Consulta de Grau de Parentesco do ERP.";
			PATH "/grauparentesco";
			WSSYNTAX "ApiVirtusConnector/grauparentesco"

		WSMETHOD POST ReservaJazigo;
			DESCRIPTION "Cemiterio - Reserva de Jazigos";
			PATH "/reservajazigo/" PRODUCES APPLICATION_JSON;
			WSSYNTAX "ApiVirtusConnector/reservajazigo"

		WSMETHOD POST IncluiContrato;
			DESCRIPTION "Cemiterio - Inclusão de contratos";
			PATH "/incluicontrato/" PRODUCES APPLICATION_JSON;
			WSSYNTAX "ApiVirtusConnector/incluicontrato"

		WSMETHOD POST IncAgendamento;
			DESCRIPTION "Cemiterio - Inclusão de Agendamentos";
			PATH "/incluiagendamento/" PRODUCES APPLICATION_JSON;
			WSSYNTAX "ApiVirtusConnector/incluiagendamento"

		WSMETHOD POST IncSolicitacao;
			DESCRIPTION "Cemiterio - Inclusão de Solicitação";
			PATH "/incluisolicitacao/" PRODUCES APPLICATION_JSON;
			WSSYNTAX "ApiVirtusConnector/incluisolicitacao"

		WSMETHOD POST IncApontamento;
			DESCRIPTION "Cemiterio e Funeraria - Inclusão de Apontamentos";
			PATH "/incluiapontamento/" PRODUCES APPLICATION_JSON;
			WSSYNTAX "ApiVirtusConnector/incluiapontamento"

		WSMETHOD PUT EncerraReservaJazigo;
			DESCRIPTION "Cemiterio - Encerra a resrva de jazigos";
			PATH "/encerrareservajazigo/";
			WSSYNTAX "ApiVirtusConnector/encerrareservajazigo"

		WSMETHOD PUT CancelaContrato;
			DESCRIPTION "Cemiterio e Planos Funerarios - Cancelamento de contratos";
			PATH "/cancelacontrato/" PRODUCES APPLICATION_JSON;
			WSSYNTAX "ApiVirtusConnector/cancelacontrato"

	END WSRESTFUL

/*/{Protheus.doc} GET_PrecoVenda
Metodo para consulta do 
Preco de Venda de Produtos de Cemiterio
@type method
@version 1.0
@author g.sampaio
@since 22/12/2023
/*/
WSMETHOD GET PrecoVenda WSRECEIVE cCnpjEmp, cProduto, cFormaPag, nQtdPar, nValorEntrada, nValorDesconto WSSERVICE ApiVirtusConnector

	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local lRetorno				:= .T.
	Local oResponse				:= JsonObject():New()
	Local oContrato			:= Nil
	Local oDadosConsulta		:= Nil

	Default cCnpjEmp		:= ""
	Default cProduto		:= ""
	Default cFormaPag		:= ""
	Default nQtdPar			:= 0
	Default nValorEntrada	:= 0
	Default nValorDesconto	:= 0

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - PrecoVenda]")

	Self:SetContentType("application/json; charset=utf-8")
	Self:SetResponse('')

	If lRetorno .And. Empty(Self:cCnpjEmp) // cnpj
		SetRestFault(400, "Obrigatorio informar parametro [cCnpjEmp] na URL.")
		lRetorno := .F.
	endif

	If lRetorno .And. Empty(Self:cProduto)
		SetRestFault(400, "Obrigatorio informar parametro [cProduto] na URL.")
		lRetorno := .F.
	endif

	If lRetorno .And. Empty(Self:cFormaPag)
		SetRestFault(400, "Obrigatorio informar parametro [cFormaPag] na URL.")
		lRetorno := .F.
	endif

	If lRetorno .And. Empty(Self:nQtdPar)
		SetRestFault(400, "Obrigatorio informar parametro [nQtdPar] na URL.")
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

		oContrato := CemiterioContratos():New()
		oContrato:Consulta(Self:cProduto,;
			Self:cFormaPag,;
			Self:nQtdPar,;
			Self:nValorEntrada,;
			Self:nValorDesconto,;
			@oResponse)

		Self:SetResponse(oResponse:toJson())

	EndIf

	FreeObj(oDadosConsulta)
	FreeObj(oResponse)

Return(lRetorno)

/*/{Protheus.doc} GET_TotalJazigos
Metodo para consulta do Total de Jazigos
@type method
@version 1.0
@author g.sampaio
@since 22/12/2023
/*/
WSMETHOD GET TotalJazigos WSRECEIVE cCnpjEmp, cQuadra, cModulo, cLocacao, nLimit WSSERVICE ApiVirtusConnector

	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local lRetorno				:= .T.
	Local oResponse				:= JsonObject():New()
	Local oJazigos				:= Nil
	Local oDadosConsulta		:= Nil

	Default cCnpjEmp	:= ""
	Default cQuadra		:= ""
	Default cModulo		:= ""
	Default cLocacao	:= ""
	Default nLimit		:= 200

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - TotalJazigos]")

	Self:SetContentType("application/json; charset=utf-8")
	Self:SetResponse('')

	If lRetorno .And. Empty(Self:cCnpjEmp) // cnpj
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

		oJazigos := CemiterioJazigos():New()
		oJazigos:TotalJazigos(Self:cQuadra,;
			Self:cModulo,;
			Self:cLocacao,;
			@oResponse)

		Self:SetResponse(oResponse:toJson())

	EndIf

	FreeObj(oDadosConsulta)
	FreeObj(oResponse)

Return(lRetorno)

/*/{Protheus.doc} GET_ConsultaJazigo
Metodo para consulta de dados de jazigo
@type method
@version 1.0
@author g.sampaio
@since 22/12/2023
/*/
WSMETHOD GET ConsultaJazigo WSRECEIVE cCnpjEmp, cQuadra, cModulo, cLocacao, nSkip, nLimit WSSERVICE ApiVirtusConnector

	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local lRetorno				:= .T.
	Local oResponse				:= JsonObject():New()
	Local oJazigos				:= Nil
	Local oDadosConsulta		:= Nil

	Default cCnpjEmp	:= ""
	Default cQuadra		:= ""
	Default cModulo		:= ""
	Default cLocacao	:= ""
	Default nSkip		:= 0
	Default nLimit		:= 100

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - ConsultaJazigo]")

	Self:SetContentType("application/json; charset=utf-8")
	Self:SetResponse('')

	If lRetorno .And. Empty(Self:cCnpjEmp) // cnpj
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

		oJazigos := CemiterioJazigos():New()
		oJazigos:Consulta(Self:cQuadra,;
			Self:cModulo,;
			Self:cLocacao,;
			Self:nSkip,;
			Self:nLimit,;
			@oResponse)

		Self:SetResponse(oResponse:toJson())

	EndIf

	FreeObj(oDadosConsulta)
	FreeObj(oResponse)

Return(lRetorno)

/*/{Protheus.doc} GET_GetGrauParentesco
Metodo para consulta de Grau de Parentesco
@type method
@version 1.0
@author g.sampaio
@since 14/01/2024
/*/
WSMETHOD GET GetGrauParentesco WSRECEIVE cCnpjEmp WSSERVICE ApiVirtusConnector

	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local lRetorno				:= .T.
	Local jResponse				:= JsonObject():New()
	Local oClientes				:= Nil

	Default cCnpjEmp		:= ""
	Default cCGCCliente		:= ""
	Default cNomeCliente	:= ""
	Default cContrato		:= ""

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - Consulta Grau de Parentesco]")

	Self:SetContentType("application/json; charset=utf-8")
	Self:SetResponse('')

	If lRetorno .And. Empty(Self:cCnpjEmp) // cnpj
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

		oClientes := VirtusConsulta():New()
		oClientes:GrauParentesco(@jResponse)

		Self:SetResponse(jResponse:toJson())

	EndIf

	FreeObj(jResponse)

Return(lRetorno)

/*/{Protheus.doc} GET_GetCliente
Metodo para consulta de cliente
@type method
@version 1.0
@author g.sampaio
@since 22/12/2023
/*/
WSMETHOD GET GetCliente WSRECEIVE cCnpjEmp, cCGCCliente, cNomeCliente, cContrato WSSERVICE ApiVirtusConnector

	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local lRetorno				:= .T.
	Local jResponse				:= JsonObject():New()
	Local oClientes				:= Nil

	Default cCnpjEmp		:= ""
	Default cCGCCliente		:= ""
	Default cNomeCliente	:= ""
	Default cContrato		:= ""

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - ConsultaCliente]")

	Self:SetContentType("application/json; charset=utf-8")
	Self:SetResponse('')

	If lRetorno .And. Empty(Self:cCnpjEmp) // cnpj
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

		oClientes := VirtusConsulta():New()
		oClientes:ConsultaCliente(Self:cCGCCliente,;
			Self:cNomeCliente,;
			Self:cContrato,;
			@jResponse)

		Self:SetResponse(jResponse:toJson())

	EndIf

	FreeObj(jResponse)

Return(lRetorno)

/*/{Protheus.doc} GET_GetContrato
Metodo para consulta de contrato
@type method
@version 1.0
@author g.sampaio
@since 22/12/2023
/*/
WSMETHOD GET GetContrato WSRECEIVE cCnpjEmp, cCGCCliente, cNomeCliente, cContrato WSSERVICE ApiVirtusConnector

	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local lRetorno				:= .T.
	Local jResponse				:= JsonObject():New()
	Local oContratos			:= Nil

	Default cCnpjEmp		:= ""
	Default cCGCCliente		:= ""
	Default cNomeCliente	:= ""
	Default cContrato		:= ""

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - ConsultaCliente]")

	Self:SetContentType("application/json; charset=utf-8")
	Self:SetResponse('')

	If lRetorno .And. Empty(Self:cCnpjEmp) // cnpj
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

		oContratos := VirtusConsulta():New()
		oContratos:ConsultaContrato(Self:cCGCCliente,;
			Self:cNomeCliente,;
			Self:cContrato,;
			@jResponse)

		Self:SetResponse(jResponse:toJson())

	EndIf

	FreeObj(oContratos)

Return(lRetorno)

/*/{Protheus.doc} GET_GetContrato
Metodo para consulta de contrato
@type method
@version 1.0
@author g.sampaio
@since 22/12/2023
/*/
WSMETHOD GET GetEnderecados WSRECEIVE cCnpjEmp, cContrato WSSERVICE ApiVirtusConnector

	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local lRetorno				:= .T.
	Local jResponse				:= JsonObject():New()
	Local oContratos			:= Nil

	Default cCnpjEmp		:= ""
	Default cCGCCliente		:= ""
	Default cNomeCliente	:= ""
	Default cContrato		:= ""

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - Consulta Sepultados]")

	Self:SetContentType("application/json; charset=utf-8")
	Self:SetResponse('')

	If lRetorno .And. Empty(Self:cCnpjEmp) // cnpj
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

		oContratos := VirtusConsulta():New()
		oContratos:ConsultaSepultados(Self:cContrato,;
			@jResponse)

		Self:SetResponse(jResponse:toJson())

	EndIf

	FreeObj(oContratos)

Return(lRetorno)

/*/{Protheus.doc} GET_GetJazigoContrato
Metodo para consulta de contrato
@type method
@version 1.0	
@author g.sampaio
@since 22/12/2023
/*/
WSMETHOD GET GetJazigoContrato WSRECEIVE cCnpjEmp, cContrato WSSERVICE ApiVirtusConnector

	Local cCodEmp			:= ""
	Local cCodFil			:= ""
	Local lRetorno			:= .T.
	Local jResponse			:= JsonObject():New()
	Local oJazigo			:= Nil

	Default cCnpjEmp		:= ""
	Default cContrato		:= ""

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - Consulta Jazigo do Contrato]")

	Self:SetContentType("application/json; charset=utf-8")
	Self:SetResponse('')

	If lRetorno .And. Empty(Self:cCnpjEmp) // cnpj
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

		oJazigo := CemiterioJazigos():New()
		oJazigo:JazigoContrato(Self:cContrato,;
			@jResponse)

		Self:SetResponse(jResponse:toJson())

	EndIf

	FreeObj(oJazigo)

Return(lRetorno)

/*/{Protheus.doc} GET_CemContrato
Metodo para retorno dos de contrato
@type method
@version 1.0
@author g.sampaio
@since 22/12/2023
/*/
WSMETHOD GET CemContrato WSRECEIVE cCnpjEmp, cContrato	WSSERVICE ApiVirtusConnector

	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local lRetorno				:= .T.
	Local jResponse				:= JsonObject():New()
	Local oContratos			:= Nil

	Default cCnpjEmp		:= ""
	Default cContrato		:= ""

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - Consulta de dados do Contrato]")

	Self:SetContentType("application/json; charset=utf-8")
	Self:SetResponse('')

	If lRetorno .And. Empty(Self:cCnpjEmp) // cnpj
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

		oContratos := VirtusConsulta():New()
		oContratos:ContratoCemiterio(Self:cContrato,;
			@jResponse)

		Self:SetResponse(jResponse:toJson())

	EndIf

	FreeObj(oContratos)

Return(lRetorno)

/*/{Protheus.doc} GET_PrecosFuneraria
Metodo para consulta de precos
para a prestacao de servicos funerarios
@type method
@version 1.0
@author g.sampaio
@since 22/12/2023
/*/
WSMETHOD GET PrecosFuneraria WSRECEIVE cCnpjEmp, cCNPJServicos, cContrato, cBeneficiario, cProdServ WSSERVICE ApiVirtusConnector

	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local lRetorno				:= .T.
	Local jResponse				:= JsonObject():New()
	Local oServicosFuneraria	:= Nil

	Default cCnpjEmp			:= ""
	Default cCNPJServicos		:= ""
	Default cContrato			:= ""
	Default cBeneficiario		:= ""
	Default cProdServ			:= ""

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - PrecosFuneraria]")

	Self:SetContentType("application/json; charset=utf-8")
	Self:SetResponse('')

	If lRetorno .And. Empty(Self:cCnpjEmp) // cnpj
		SetRestFault(400, "Obrigatorio informar parametro [cCnpjEmp] na URL.")
		lRetorno := .F.
	endif

	If lRetorno .And. Empty(Self:cCNPJServicos)
		SetRestFault(400, "Obrigatorio informar parametro [cCNPJServicos] na URL.")
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

		oServicosFuneraria := ServicosFuneraria():New()
		oServicosFuneraria:ConsultaPrecos(Self:cCNPJServicos,;
			Self:cContrato,;
			Self:cBeneficiario,;
			Self:cProdServ,;
			@jResponse)

		Self:SetResponse(jResponse:toJson())

	EndIf

	FreeObj(jResponse)

Return(lRetorno)

/*/{Protheus.doc} GET_GetModelVirtus
Metodo para retornar o modelo 
de dados do apontamento
@type method
@version 1.0
@author g.sampaio
@since 22/12/2023
/*/
WSMETHOD GET GetModelVirtus WSRECEIVE cCnpjEmp, cTabAlias, cUsaContrato WSSERVICE ApiVirtusConnector

	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local lRetorno				:= .T.
	Local jResponse				:= JsonObject():New()
	Local oModelVirtusConnector	:= Nil

	Default cCnpjEmp			:= ""
	Default cCNPJServicos		:= ""
	Default cContrato			:= ""
	Default cBeneficiario		:= ""
	Default cProdServ			:= ""

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - PrecosFuneraria]")

	Self:SetContentType("application/json; charset=utf-8")
	Self:SetResponse('')

	If lRetorno .And. Empty(Self:cCnpjEmp) // cnpj
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

		oModelVirtusConnector := ModelVirtusConnector():New()
		oModelVirtusConnector:GetModel( Self:cTabAlias, Self:cUsaContrato, @jResponse)

		Self:SetResponse(jResponse:toJson())

	EndIf

	FreeObj(jResponse)

Return(lRetorno)

//TotalSolicitacao

/*/{Protheus.doc} GET_TotalSolicitacao
Metodo para retornar o Total de Solicitacoes
@type method
@version 1.0
@author g.sampaio
@since 27/01/2024
/*/
WSMETHOD GET TotalSolicitacao WSRECEIVE cCnpjEmp, cDataIni, cDataFim WSSERVICE ApiVirtusConnector

	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local lRetorno				:= .T.
	Local jResponse				:= JsonObject():New()
	Local oVirtusSolicitacao	:= Nil

	Default cCnpjEmp	:= ""
	Default cDataIni	:= DtoS(FirstDate(dDatabase))
	Default cDataFim	:= DtoS(LastDate(dDatabase))

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - TotalAgendamento]")

	Self:SetContentType("application/json; charset=utf-8")
	Self:SetResponse('')

	If lRetorno .And. Empty(Self:cCnpjEmp) // cnpj
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

		oVirtusSolicitacao := VirtusSolicitacao():New()
		oVirtusSolicitacao:Total( Self:cDataIni, Self:cDataFim, @jResponse )

		Self:SetResponse(jResponse:toJson())

	EndIf

	FreeObj(jResponse)

Return(lRetorno)

/*/{Protheus.doc} GET_TotalAgendamento
Metodo para retornar o Total de Agendamentos
@type method
@version 1.0
@author g.sampaio
@since 27/01/2024
/*/
WSMETHOD GET TotalAgendamento WSRECEIVE cCnpjEmp, cDataIni, cDataFim WSSERVICE ApiVirtusConnector

	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local lRetorno				:= .T.
	Local jResponse				:= JsonObject():New()
	Local oVirtusAgendamento	:= Nil

	Default cCnpjEmp	:= ""
	Default cDataIni	:= DtoS(FirstDate(dDatabase))
	Default cDataFim	:= DtoS(LastDate(dDatabase))

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - TotalAgendamento]")

	Self:SetContentType("application/json; charset=utf-8")
	Self:SetResponse('')

	If lRetorno .And. Empty(Self:cCnpjEmp) // cnpj
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

		oVirtusAgendamento := VirtusAgendamento():New()
		oVirtusAgendamento:Total( Self:cDataIni, Self:cDataFim, @jResponse )

		Self:SetResponse(jResponse:toJson())

	EndIf

	FreeObj(jResponse)

Return(lRetorno)

/*/{Protheus.doc} GET_GetTipoSolicitacao
Metodo para retornar os Tipos de Solicitacao
@type method
@version 1.0
@author g.sampaio
@since 13/01/2024
/*/
WSMETHOD GET GetTipoSolicitacao WSRECEIVE cCnpjEmp WSSERVICE ApiVirtusConnector

	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local lRetorno				:= .T.
	Local jResponse				:= JsonObject():New()
	Local oVirtusSolicitacao	:= Nil

	Default cCnpjEmp			:= ""
	Default cCNPJServicos		:= ""
	Default cContrato			:= ""
	Default cBeneficiario		:= ""
	Default cProdServ			:= ""

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - GetTipoSolicitacao]")

	Self:SetContentType("application/json; charset=utf-8")
	Self:SetResponse('')

	If lRetorno .And. Empty(Self:cCnpjEmp) // cnpj
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

		oVirtusSolicitacao := VirtusSolicitacao():New()
		oVirtusSolicitacao:TipoSolicitacao(@jResponse)

		Self:SetResponse(jResponse:toJson())

	EndIf

	FreeObj(jResponse)

Return(lRetorno)

/*/{Protheus.doc} GET_GetSolicitacao
Metodo para retornar as solicitacoes
@type method
@version 1.0
@author g.sampaio
@since 14/01/2024
/*/
WSMETHOD GET GetSolicitacao WSRECEIVE cCnpjEmp, cContrato WSSERVICE ApiVirtusConnector

	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local lRetorno				:= .T.
	Local jResponse				:= JsonObject():New()
	Local oVirtusSolicitacao	:= Nil

	Default cCnpjEmp			:= ""
	Default cCNPJServicos		:= ""
	Default cContrato			:= ""
	Default cBeneficiario		:= ""
	Default cProdServ			:= ""

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - Consulta Solicitacoes]")

	Self:SetContentType("application/json; charset=utf-8")
	Self:SetResponse('')

	If lRetorno .And. Empty(Self:cCnpjEmp) // cnpj
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

		oVirtusSolicitacao := VirtusSolicitacao():New()
		oVirtusSolicitacao:Consulta(Self:cContrato, @jResponse)

		Self:SetResponse(jResponse:toJson())

	EndIf

	FreeObj(jResponse)

Return(lRetorno)

/*/{Protheus.doc} POST_IncSolicitacao
Metodo para inclusao de Solicitacao
@type method
@version 1.0
@author g.sampaio
@since 14/01/2024
/*/
WSMETHOD POST IncSolicitacao WSRECEIVE cCnpjEmp WSSERVICE ApiVirtusConnector

	Local aPropri				:= {}
	Local cCnpjEmp				:= ""
	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local cBodyJson				:= ""
	Local cError				:= ""
	Local cIdIntegracao			:= ""
	Local jResponse				:= JsonObject():New()
	Local jDadosSolicitacao		:= JsonObject():New()
	Local lRetorno				:= .T.
	Local oVirtusSolicitacao	:= Nil

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - Inclusao de Solicitacao de Manutencao]")

	cBodyJson := Self:getContent()

	Conout("JSON: " + cBodyJson)

	Self:SetContentType("application/json")
	cError := jDadosSolicitacao:FromJson(cBodyJson)

	If Empty(cError)

		ConOut("cnpjemp = " + jDadosSolicitacao["cnpjemp"] )

		aPropri := jDadosSolicitacao:GetNames()
		Conout(U_ToString(aPropri))

		If jDadosSolicitacao["cnpjemp"] == Nil
			SetRestFault(400, "Atributo [cnpjemp] precisa ser informado!")
			lRetorno := .F.
		EndIf

		If lRetorno

			cCnpjEmp			:= jDadosSolicitacao["cnpjemp"]
			cIdIntegracao		:= jDadosSolicitacao["id_integracao"]

			// pego o coidog da empresa
			RetEmpFilial(cCnpjEmp, @cCodEmp, @cCodFil)

			If Empty(cCodEmp)
				SetRestFault(400, "Nao foi localizado empresa para o CNPJ [" + cCnpjEmp + "] informado.")
				lRetorno := .F.
			Else
				cEmpAnt	:= cCodEmp
				cFilAnt	:= cCodFil
			EndIf

			If lRetorno

				oVirtusSolicitacao := VirtusSolicitacao():New()
				oVirtusSolicitacao:Incluir(cBodyJson, cIdIntegracao, @jResponse)

				if jResponse <> Nil
					Self:SetResponse( jResponse )
				endif

			EndIf

		EndIf

	Else

		SetRestFault(400, "Body json recebido invalido! " + cError)
		lRetorno := .F.

	EndIf

	FreeObj(jDadosSolicitacao)
	FreeObj(jResponse)

Return(lRetorno)

/*/{Protheus.doc} POST_ReservaJazigo
Metodo para incluir uma reserva de jazigo
@type method
@version 1.0
@author g.sampaio
@since 22/12/2023
/*/
WSMETHOD POST ReservaJazigo WSRECEIVE cCnpjEmp WSSERVICE ApiVirtusConnector

	Local aPropri			:= {}
	Local cCnpjEmp			:= ""
	Local cQuadra			:= ""
	Local cModulo			:= ""
	Local cJazigo			:= ""
	Local cCodEmp			:= ""
	Local cCodFil			:= ""
	Local cBodyJson			:= ""
	Local cError			:= ""
	Local cIdIntegracao		:= ""
	Local lRetorno			:= .T.
	Local nPosIntegracao	:= 0
	Local oResponse			:= JsonObject():New()
	Local oJazigos			:= Nil
	Local oDadosReserva		:= JsonObject():New()

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - ReservaJazigo]")

	oJazigos := CemiterioJazigos():New()

	If lRetorno

		cBodyJson := Self:getContent()

		Conout("JSON: " + cBodyJson)

		Self:SetContentType("application/json")
		cError := oDadosReserva:FromJson(cBodyJson)

		If Empty(cError)

			ConOut("cnpjemp = " + iif(oDadosReserva["cnpjemp"] <> Nil, oDadosReserva["cnpjemp"], "Nil"))
			ConOut("quadra = " + iif(oDadosReserva["quadra"] <> Nil, oDadosReserva["quadra"], "Nil"))
			ConOut("modulo = " + iif(oDadosReserva["modulo"] <> Nil, oDadosReserva["modulo"], "Nil"))
			ConOut("jazigo = " + iif(oDadosReserva["jazigo"] <> Nil, oDadosReserva["jazigo"], "Nil"))

			aPropri := oDadosReserva:GetNames()
			Conout(U_ToString(aPropri))

			If oDadosReserva["cnpjemp"] == Nil .Or. oDadosReserva["quadra"] == Nil .Or. oDadosReserva["modulo"] == Nil .Or. oDadosReserva["jazigo"] == Nil
				SetRestFault(400, "Atributo [cnpjemp], [quadra], [modulo] ou [jazigo] precisa ser informado!")
				lRetorno := .F.
			EndIf

			If lRetorno

				cCnpjEmp		:= oDadosReserva["cnpjemp"]
				cQuadra			:= PADR( UPPER(oDadosReserva["quadra"]) , TamSX3("U04_QUADRA")[1] )
				cModulo			:= PADR( UPPER(oDadosReserva["modulo"]) , TamSX3("U04_MODULO")[1] )
				cJazigo			:= PADR( UPPER(oDadosReserva["jazigo"]) , TamSX3("U04_JAZIGO")[1] )

				If U04->(FieldPos("U04_IDINTE")) > 0
					nPosIntegracao 	:= aScan( aPropri, { |x| AllTrim(x) == "id_integracao" } )
					cIdIntegracao	:= PADR( iif( nPosIntegracao > 0, oDadosReserva["id_integracao"], "") , TamSX3("U04_IDINTE")[1] )
				EndIf

				// pego o coidog da empresa
				RetEmpFilial(cCnpjEmp, @cCodEmp, @cCodFil)

				If Empty(cCodEmp)
					SetRestFault(400, "Nao foi localizado empresa para o CNPJ [" + cCnpjEmp + "] informado.")
					lRetorno := .F.
				Else
					cEmpAnt	:= cCodEmp
					cFilAnt	:= cCodFil
				EndIf

				If lRetorno

					oJazigos:Reserva(cQuadra, cModulo, cJazigo, cIdIntegracao, @oResponse)
					if oResponse <> Nil
						Self:SetResponse( oResponse )
					endif

				EndIf

			EndIf

		Else

			SetRestFault(400, "Body json recebido invalido! " + cError)
			lRetorno := .F.

		EndIf

	EndIf

	FreeObj(oDadosReserva)
	FreeObj(oResponse)

Return(lRetorno)

/*/{Protheus.doc} POST_IncluiContrato
Metodo para inclusao de contrato de Cemiterio
@type method
@version 1.0
@author g.sampaio
@since 22/12/2023
/*/
WSMETHOD POST IncluiContrato WSRECEIVE cCnpjEmp WSSERVICE ApiVirtusConnector

	Local aPropri			:= {}
	Local cCnpjEmp			:= ""
	Local cCodEmp			:= ""
	Local cCodFil			:= ""
	Local cBodyJson			:= ""
	Local cError			:= ""
	Local cIdIntegracao		:= ""
	Local lRetorno			:= .T.
	Local oResponse			:= JsonObject():New()
	Local oContrato			:= Nil
	Local oDadosInclusao	:= JsonObject():New()

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - IncluiContrato]")

	oContrato := CemiterioContratos():New()

	If lRetorno

		cBodyJson := Self:getContent()

		Conout("JSON: " + cBodyJson)

		Self:SetContentType("application/json")
		cError := oDadosInclusao:FromJson(cBodyJson)

		If Empty(cError)

			ConOut("cnpjemp = " + oDadosInclusao["cnpjemp"] )

			aPropri := oDadosInclusao:GetNames()
			Conout(U_ToString(aPropri))

			If oDadosInclusao["cnpjemp"] == Nil
				SetRestFault(400, "Atributo [cnpjemp] precisa ser informado!")
				lRetorno := .F.
			EndIf

			If lRetorno

				cCnpjEmp			:= oDadosInclusao["cnpjemp"]
				cIdIntegracao		:= oDadosInclusao["id_integracao"]
				cContratoJson		:= cBodyJson

				// pego o coidog da empresa
				RetEmpFilial(cCnpjEmp, @cCodEmp, @cCodFil)

				If Empty(cCodEmp)
					SetRestFault(400, "Nao foi localizado empresa para o CNPJ [" + cCnpjEmp + "] informado.")
					lRetorno := .F.
				Else
					cEmpAnt	:= cCodEmp
					cFilAnt	:= cCodFil
				EndIf

				If lRetorno

					oContrato:GravarContrato(cBodyJson, cIdIntegracao, @oResponse)
					if oResponse <> Nil
						Self:SetResponse( oResponse )
					endif

				EndIf

			EndIf

		Else

			SetRestFault(400, "Body json recebido invalido! " + cError)
			lRetorno := .F.

		EndIf

	EndIf

	FreeObj(oDadosInclusao)
	FreeObj(oResponse)

Return(lRetorno)

/*/{Protheus.doc} POST_IncApontamento
Metodo para inclusao de Apontamento de Servicos
@type method
@version 1.0
@author g.sampaio
@since 22/12/2023
/*/
WSMETHOD POST IncApontamento WSRECEIVE cCnpjEmp WSSERVICE ApiVirtusConnector

	Local aPropri			:= {}
	Local cCnpjEmp			:= ""
	Local cCodEmp			:= ""
	Local cCodFil			:= ""
	Local cBodyJson			:= ""
	Local cError			:= ""
	Local cIdIntegracao		:= ""
	Local jResponse			:= JsonObject():New()
	Local jDadosApontamento	:= JsonObject():New()
	Local lRetorno			:= .T.
	Local oApontamento		:= Nil

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - Inclusao de Apontamento de Servicos]")

	cBodyJson := Self:getContent()

	Conout("JSON: " + cBodyJson)

	Self:SetContentType("application/json")
	cError := jDadosApontamento:FromJson(cBodyJson)

	If Empty(cError)

		ConOut("cnpjemp = " + jDadosApontamento["cnpjemp"] )

		aPropri := jDadosApontamento:GetNames()
		Conout(U_ToString(aPropri))

		If jDadosApontamento["cnpjemp"] == Nil
			SetRestFault(400, "Atributo [cnpjemp] precisa ser informado!")
			lRetorno := .F.
		EndIf

		If lRetorno

			cCnpjEmp			:= jDadosApontamento["cnpjemp"]
			cIdIntegracao		:= jDadosApontamento["id_integracao"]

			// pego o coidog da empresa
			RetEmpFilial(cCnpjEmp, @cCodEmp, @cCodFil)

			If Empty(cCodEmp)
				SetRestFault(400, "Nao foi localizado empresa para o CNPJ [" + cCnpjEmp + "] informado.")
				lRetorno := .F.
			Else
				cEmpAnt	:= cCodEmp
				cFilAnt	:= cCodFil
			EndIf

			If lRetorno

				oApontamento := ServicosFuneraria():New()
				oApontamento:GravarApontamento(cBodyJson, cIdIntegracao, @jResponse)

				if jResponse <> Nil
					Self:SetResponse( jResponse )
				endif

			EndIf

		EndIf

	Else

		SetRestFault(400, "Body json recebido invalido! " + cError)
		lRetorno := .F.

	EndIf

	FreeObj(jDadosApontamento)
	FreeObj(jResponse)

Return(lRetorno)

/*/{Protheus.doc} POST_IncAgendamento
Metodo para inclusao de Apontamento de Servicos
@type method
@version 1.0
@author g.sampaio
@since 22/12/2023
/*/
WSMETHOD POST IncAgendamento WSRECEIVE cCnpjEmp WSSERVICE ApiVirtusConnector

	Local aPropri			:= {}
	Local cCnpjEmp			:= ""
	Local cCodEmp			:= ""
	Local cCodFil			:= ""
	Local cBodyJson			:= ""
	Local cError			:= ""
	Local cIdIntegracao		:= ""
	Local jResponse			:= JsonObject():New()
	Local jDadosAgendamento	:= JsonObject():New()
	Local lRetorno			:= .T.
	Local oAgendamento		:= Nil

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - Inclusao de Agendamento]")

	cBodyJson := Self:getContent()

	Conout("JSON: " + cBodyJson)

	Self:SetContentType("application/json")
	cError := jDadosAgendamento:FromJson(cBodyJson)

	If Empty(cError)

		ConOut("cnpjemp = " + jDadosAgendamento["cnpjemp"] )

		aPropri := jDadosAgendamento:GetNames()
		Conout(U_ToString(aPropri))

		If jDadosAgendamento["cnpjemp"] == Nil
			SetRestFault(400, "Atributo [cnpjemp] precisa ser informado!")
			lRetorno := .F.
		EndIf

		If lRetorno

			cCnpjEmp			:= jDadosAgendamento["cnpjemp"]
			cIdIntegracao		:= jDadosAgendamento["id_integracao"]

			// pego o coidog da empresa
			RetEmpFilial(cCnpjEmp, @cCodEmp, @cCodFil)

			If Empty(cCodEmp)
				SetRestFault(400, "Nao foi localizado empresa para o CNPJ [" + cCnpjEmp + "] informado.")
				lRetorno := .F.
			Else
				cEmpAnt	:= cCodEmp
				cFilAnt	:= cCodFil
			EndIf

			If lRetorno

				oAgendamento := VirtusAgendamento():New()
				oAgendamento:Incluir(cBodyJson, cIdIntegracao, @jResponse)

				if jResponse <> Nil
					Self:SetResponse( jResponse )
				endif

			EndIf

		EndIf

	Else

		SetRestFault(400, "Body json recebido invalido! " + cError)
		lRetorno := .F.

	EndIf

	FreeObj(jDadosAgendamento)
	FreeObj(jResponse)

Return(lRetorno)

/*/{Protheus.doc} PUT_CancelaContrato
Metodo para inclusao de Apontamento de Servicos
@type method
@version 1.0
@author g.sampaio
@since 22/12/2023
/*/
WSMETHOD PUT CancelaContrato WSRECEIVE cCnpjEmp WSSERVICE ApiVirtusConnector

	Local aPropri				:= {}
	Local cCnpjEmp				:= ""
	Local cCodEmp				:= ""
	Local cCodFil				:= ""
	Local cBodyJson				:= ""
	Local cError				:= ""
	Local cIdIntegracao			:= ""
	Local lRetorno				:= .T.
	Local jResponse				:= JsonObject():New()
	Local oCancelamento			:= Nil
	Local jDadosCancelamento	:= JsonObject():New()

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - CancelaContrato]")

	oCancelamento := CancelamentoContratoIntegracao():New()

	If lRetorno

		cBodyJson := Self:getContent()

		Conout("JSON: " + cBodyJson)

		Self:SetContentType("application/json")
		cError := jDadosCancelamento:FromJson(cBodyJson)

		If Empty(cError)

			ConOut("cnpjemp = " + jDadosCancelamento["cnpjemp"] )

			aPropri := jDadosCancelamento:GetNames()
			Conout(U_ToString(aPropri))

			If jDadosCancelamento["cnpjemp"] == Nil
				SetRestFault(400, "Atributo [cnpjemp] precisa ser informado!")
				lRetorno := .F.
			EndIf

			If lRetorno

				cCnpjEmp			:= jDadosCancelamento["cnpjemp"]
				cIdIntegracao		:= jDadosCancelamento["id_integracao"]
				cContratoJson		:= cBodyJson

				// pego o coidog da empresa
				RetEmpFilial(cCnpjEmp, @cCodEmp, @cCodFil)

				If Empty(cCodEmp)
					SetRestFault(400, "Nao foi localizado empresa para o CNPJ [" + cCnpjEmp + "] informado.")
					lRetorno := .F.
				Else
					cEmpAnt	:= cCodEmp
					cFilAnt	:= cCodFil
				EndIf

				If lRetorno

					oCancelamento:GravarCancelamento(cBodyJson, cIdIntegracao, @jResponse)
					if jResponse <> Nil
						Self:SetResponse( jResponse )
					endif

				EndIf

			EndIf

		Else

			SetRestFault(400, "Body json recebido invalido! " + cError)
			lRetorno := .F.

		EndIf

	EndIf

	FreeObj(oDadosInclusao)
	FreeObj(oResponse)

Return(lRetorno)

/*/{Protheus.doc} PUT_EncerraReservaJazigo
Metodo para inclusao de Apontamento de Servicos
@type method
@version 1.0
@author g.sampaio
@since 22/12/2023
/*/
WSMETHOD PUT EncerraReservaJazigo WSRECEIVE cCnpjEmp WSSERVICE ApiVirtusConnector

	Local aPropri			:= {}
	Local cCnpjEmp			:= ""
	Local cQuadra			:= ""
	Local cModulo			:= ""
	Local cJazigo			:= ""
	Local cCodEmp			:= ""
	Local cCodFil			:= ""
	Local cBodyJson			:= ""
	Local cError			:= ""
	Local lRetorno			:= .T.
	Local oResponse			:= JsonObject():New()
	Local oJazigos			:= Nil
	Local oDadosReserva		:= JsonObject():New()

	Conout("")
	Conout("")
	Conout("[ApiVirtusConnector - RUTILW12 - ReservaJazigo]")

	oJazigos := CemiterioJazigos():New()

	If lRetorno

		cBodyJson := Self:getContent()

		Conout("JSON: " + cBodyJson)

		Self:SetContentType("application/json")
		cError := oDadosReserva:FromJson(cBodyJson)

		If Empty(cError)

			ConOut("cnpjemp = " + oDadosReserva["cnpjemp"] )
			ConOut("quadra = " + oDadosReserva["quadra"] )
			ConOut("modulo = " + oDadosReserva["modulo"] )
			ConOut("jazigo = " + oDadosReserva["jazigo"] )

			aPropri := oDadosReserva:GetNames()
			Conout(U_ToString(aPropri))

			If Len(aPropri) <> 4
				SetRestFault(400, "Atributo [cnpjemp], [quadra], [modulo] ou [jazigo] precisa ser informado!")
				lRetorno := .F.
			EndIf

			If lRetorno

				cCnpjEmp		:= oDadosReserva["cnpjemp"]
				cQuadra			:= PADR( UPPER(oDadosReserva["quadra"]) , TamSX3("U04_QUADRA")[1] )
				cModulo			:= PADR( UPPER(oDadosReserva["modulo"]) , TamSX3("U04_MODULO")[1] )
				cJazigo			:= PADR( UPPER(oDadosReserva["jazigo"]) , TamSX3("U04_JAZIGO")[1] )

				If U04->(FieldPos("U04_IDINTE")) > 0
					cIdIntegracao	:= PADR( UPPER(oDadosReserva["id_integracao"]) , TamSX3("U04_IDINTE")[1] )
				EndIf

				// pego o coidog da empresa
				RetEmpFilial(cCnpjEmp, @cCodEmp, @cCodFil)

				If Empty(cCodEmp)
					SetRestFault(400, "Nao foi localizado empresa para o CNPJ [" + cCnpjEmp + "] informado.")
					lRetorno := .F.
				Else
					cEmpAnt	:= cCodEmp
					cFilAnt	:= cCodFil
				EndIf

				If lRetorno

					oJazigos:EncerraReserva(cQuadra, cModulo, cJazigo, cIdIntegracao, @oResponse)
					if oResponse <> Nil
						Self:SetResponse( oResponse )
					endif

				EndIf

			EndIf

		Else

			SetRestFault(400, "Body json recebido invalido! " + cError)
			lRetorno := .F.

		EndIf

	EndIf

	FreeObj(oDadosReserva)
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
