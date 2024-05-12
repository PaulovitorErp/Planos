#INCLUDE "PROTHEUS.CH"
#INCLUDE 'RESTFUL.CH'
#INCLUDE "TOPCONN.ch"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} UVIND17
API para painel de conciliação Vindi x Protheus
Consumida pelo painel Virtus
@type function
@version 1.0
@author nata.queiroz
@since 16/03/2020
/*/
User Function UVIND17
Return

	WSRESTFUL ConciliaVindi DESCRIPTION "Conciliação de títulos com a plataforma Vindi"

		WSDATA cnpj AS CHARACTER

		WSMETHOD GET TITULOS DESCRIPTION "Lista de títulos vencidos pendentes de baixa.";
			WSSYNTAX "/titulos" PATH "/titulos"

		WSMETHOD POST GRVPAGTOS DESCRIPTION "Grava pagamentos para baixa dos títulos financeiros.";
			WSSYNTAX "/grvpagtos" PATH "/grvpagtos"

	END WSRESTFUL

WSMETHOD GET TITULOS QUERYPARAM cnpj WSSERVICE ConciliaVindi
	Local lRet        := .T.
	Local aTitulos    := {}
	Local oResponse   := JsonObject():New()
	Local cJson       := ""
	Local cCodEmp     := ""
	Local cCodFil     := ""
	Local lConnect    := .F.
	Local nStart      := Seconds()
	Local cMessage    := ""

	//-- Busca empresa/filial pelo cnpj
	BscEmpFil(AllTrim(::cnpj), @cCodEmp, @cCodFil)

	If !Empty(cCodEmp) .And. !Empty(cCodFil)

		RpcSetType(3)
		RpcClearEnv() //-- Limpa ambiente
		lConnect := RpcSetEnv(cCodEmp, cCodFil) //-- Seta ambiente

		If lConnect
			cMessage := "API ConciliaVindi => GET TITULOS " + DTOC(dDataBase) + " " + Time()
			FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

			::SetContentType("application/json")

			aTitulos := GetTitulos()

			If Len(aTitulos) > 0
				oResponse["status"] := "200"
				oResponse["result"] := aTitulos
			Else
				oResponse["status"] := "500"
				oResponse["result"] := "titulos nao encontrados"
			EndIf

			cJson := LOWER(FWJsonSerialize(oResponse, .F.))
			::SetResponse(cJson)

			RpcClearEnv() //-- Limpa ambiente
		Else
			lRet := .F.
			SetRestFault(500, "nao foi possivel conectar a empresa informada")
		EndIf
	Else
		lRet := .F.
		SetRestFault(400, "nenhuma empresa encontrada para o cnpj informado")
	EndIf

	FreeObj(oResponse)

Return lRet

WSMETHOD POST GRVPAGTOS QUERYPARAM cnpj WSSERVICE ConciliaVindi
	Local lRet        := .T.
	Local cBody       := ""
	Local jBody		  := JsonObject():New()
	Local oResponse   := JsonObject():New()
	Local cCodEmp     := ""
	Local cCodFil     := ""
	Local lFuneraria  := .F.
	Local lCemiterio  := .F.
	Local cCodMod     := ""
	Local lConnect    := .F.
	Local nStart      := Seconds()
	Local cMessage    := ""
	Local cJson		  := ""
	Local cJsonRet	  := ""

	//-- Busca empresa/filial pelo cnpj
	BscEmpFil(AllTrim(::cnpj), @cCodEmp, @cCodFil)

	If !Empty(cCodEmp) .And. !Empty(cCodFil)

		RpcSetType(3)
		RpcClearEnv() //-- Limpa ambiente
		lConnect := RpcSetEnv(cCodEmp, cCodFil) //-- Seta ambiente

		If lConnect
			cMessage := "API ConciliaVindi => POST GRVPAGTOS " + DTOC(dDataBase) + " " + Time()
			FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

			lFuneraria	:= SuperGetMV("MV_XFUNE", .F., .F.)
			lCemiterio	:= SuperGetMV("MV_XCEMI", .F., .F.)

			//-- Verifica modulo ativo --//
			If lFuneraria
				cCodMod := "F"
			ElseIf lCemiterio
				cCodMod := "C"
			EndIf

			If !Empty(cCodMod)
				::SetContentType("application/json")

				cBody := ::GetContent()

				If ValidJson(cBody, @jBody, @oResponse)
					oResponse["status"] := "200"
					oResponse["result"] := ProcessGrv(cCodMod, jBody)
				EndIf

				cJson := LOWER(FWJsonSerialize(oResponse, .F.))
				::SetResponse(cJson)

				cMessage := cJson
				FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
			Else
				lRet := .F.
				SetRestFault(500, "modulo funeraria ou cemiterio nao ativado")
			EndIf

			RpcClearEnv() //-- Limpa ambiente
		Else
			lRet := .F.
			SetRestFault(500, "nao foi possivel conectar a empresa informada")
		EndIf
	Else
		lRet := .F.
		SetRestFault(400, "nenhuma empresa encontrada para o cnpj informado")
	EndIf

	FreeObj(jBody)
	FreeObj(oResponse)

Return lRet

/*/{Protheus.doc} GetTitulos
Busca titulos vencidos pendentes de baixa
@type function
@version 1.0
@author nata.queiroz
@since 16/03/2020
@return aTitulos, array
/*/
Static Function GetTitulos()
	Local cQry := ""
	Local nQtdReg := 0
	Local aTitulos := {}
	Local oCVTitulos := Nil

	cQry := "SELECT U65.U65_CODVIN CODVINDI, "
	cQry += "    SA1.A1_CGC CGC, "
	cQry += "    SA1.A1_NOME CLIENTE, "
	cQry += "    SE1.E1_PREFIXO PREFIXO, "
	cQry += "    SE1.E1_TIPO TIPO, "
	cQry += "    SE1.E1_NUM TITULO, "
	cQry += "    SE1.E1_PARCELA PARCELA, "
	cQry += "    SE1.E1_VALOR VALOR, "
	cQry += "    SE1.E1_SALDO SALDO, "
	cQry += "    SE1.E1_EMISSAO EMISSAO, "
	cQry += "    SE1.E1_VENCREA VENCTO, "
	cQry += "    SE1.E1_BAIXA BAIXA "
	cQry += "FROM "+ RetSqlName("U65") +" U65 "
	cQry += "INNER JOIN "+ RetSqlName("SE1") +" SE1 "
	cQry += "    ON SE1.D_E_L_E_T_ <> '*' "
	cQry += "    AND SE1.E1_FILIAL = '"+ xFilial("SE1") +"' "
	cQry += "    AND SE1.E1_PREFIXO = U65.U65_PREFIX "
	cQry += "    AND SE1.E1_NUM = U65.U65_NUM "
	cQry += "    AND SE1.E1_PARCELA = U65.U65_PARCEL "
	cQry += "    AND SE1.E1_TIPO = U65.U65_TIPO "
	cQry += "    AND SE1.E1_CLIENTE = U65.U65_CLIENT "
	cQry += "    AND SE1.E1_LOJA = U65.U65_LOJA "
	cQry += "    AND SE1.E1_SALDO > 0 "
	cQry += "    AND SE1.E1_BAIXA = ' ' "
	cQry += "    AND SE1.E1_VENCREA <= '"+ DTOS(dDataBase) +"' "
	cQry += "INNER JOIN "+ RetSqlName("SA1") +" SA1 "
	cQry += "    ON SA1.D_E_L_E_T_ <> '*' "
	cQry += "    AND SA1.A1_FILIAL = '"+ xFilial("SA1") +"' "
	cQry += "    AND SA1.A1_COD = SE1.E1_CLIENTE "
	cQry += "    AND SA1.A1_LOJA = SE1.E1_LOJA "
	cQry += "LEFT JOIN "+  RetSqlName("U63") +" U63 "
	cQry += "    ON U63.D_E_L_E_T_ <> '*' "
	cQry += "    AND U63.U63_MSFIL = '"+ xFilial("U65") +"' "
	cQry += "    AND U63.U63_ENT = '1' "
	cQry += "    AND U63.U63_IDVIND = U65.U65_CODVIN "
	cQry += "WHERE U65.D_E_L_E_T_ <> '*' "
	cQry += "    AND U65.U65_FILIAL = '"+ xFilial("U65") +"' "
	cQry += "    AND U65.U65_STATUS = 'A' "
	cQry += "    AND U63.U63_IDVIND IS NULL "
	cQry += "ORDER BY SE1.E1_NUM, SE1.E1_PARCELA "
	cQry := ChangeQuery(cQry)

	If Select("GETTITS") > 0
		GETTITS->( DbCloseArea() )
	EndIf

	MPSysOpenQuery(cQry, "GETTITS")

	If nGETTITS->(!Eof())
		While GETTITS->( !EOF() )
			oCVTitulos := Nil
			oCVTitulos := CVTitulos():New( AllTrim(GETTITS->CODVINDI) )
			oCVTitulos:cgc := AllTrim(GETTITS->CGC)
			oCVTitulos:cliente := AllTrim(GETTITS->CLIENTE)
			oCVTitulos:prefixo := GETTITS->PREFIXO
			oCVTitulos:tipo := GETTITS->TIPO
			oCVTitulos:titulo := AllTrim(GETTITS->TITULO)
			oCVTitulos:parcela := GETTITS->PARCELA
			oCVTitulos:valor := GETTITS->VALOR
			oCVTitulos:saldo := GETTITS->SALDO
			oCVTitulos:emissao := FormattDate(GETTITS->EMISSAO)
			oCVTitulos:vencto := FormattDate(GETTITS->VENCTO)
			oCVTitulos:baixa := FormattDate(GETTITS->BAIXA)

			aAdd(aTitulos, oCVTitulos)

			GETTITS->( dbSkip() )
		EndDo
	EndIf

	If Select("GETTITS") > 0
		GETTITS->( DbCloseArea() )
	EndIf

Return(aTitulos)

/*/{Protheus.doc} FormattDate
Formata data (aaaa-mm-dd)
@type function
@version 1.0
@author nata.queiroz
@since 16/03/2020
@param cDate, character
@return cFormatted, character
/*/
Static Function FormattDate(cDate)
	Local cFormatted := ""

	If !Empty(cDate)
		cFormatted := SubStr(cDate, 1, 4);
			+ "-" + SubStr(cDate, 5, 2);
			+ "-" + SubStr(cDate, 7, 2)
	EndIf

Return cFormatted

/*/{Protheus.doc} BscEmpFil
Encontra empresa/filial do CNPJ informado
@type function
@version 1.0
@author nata.queiroz
@since 17/03/2020
@param cCNPJ, character
@param cCodEmp, character
@param cCodFil, character
/*/
Static Function BscEmpFil(cCNPJ, cCodEmp, cCodFil)
	Local aEmpresas := FWLoadSM0()
	Local nI := 1

	//Encontra empresa e filial com o CNPJ enviado
	For nI := 1 to Len(aEmpresas)
		If aEmpresas[nI, 18] == cCNPJ
			cCodEmp := aEmpresas[nI,1] // Grupo
			cCodFil	:= aEmpresas[nI,2] // Filial
		EndIf
	Next nI

Return

/*/{Protheus.doc} ProcessGrv
Processa gravacao dos pagamentos
@type function
@version 1.0
@author nata.queiroz
@since 17/03/2020
@param cCodMod, character
@param jPagtos, jsonobject
@return aPagtos, array
/*/
Static Function ProcessGrv(cCodMod, jPagtos)
	Local nX := 0
	Local aPagtos := {}
	Local oItemPagtos := Nil
	Local cCodVindi := ""
	Local cStatus := ""
	Local cMsg := ""

	Default jPagtos := JsonObject():New()

	For nX := 1 To Len(jPagtos["faturas"])
		If ValType( jPagtos["faturas"][nX]:GetJsonObject("ret_vindi") ) == "J"
			If jPagtos["faturas"][nX]["ret_vindi"]["bill"]["status"] == "paid"
				cCodVindi := cValToChar( jPagtos["faturas"][nX]["ret_vindi"]["bill"]["id"] )
				If .Not. ExistU63(cCodVindi)
					//-- Grava pagamento da tabela U63 --//
					GrvPagto(cCodMod, jPagtos["faturas"][nX]["ret_vindi"]:ToJson())
					cMsg := "pagamento gravado com sucesso"
				Else
					cMsg := "pagamento ja foi gravado"
				EndIf

				FreeObj(oItemPagtos)
				cStatus := "ok"
				oItemPagtos := RetJsonMsg(cStatus, jPagtos["faturas"][nX]["codvindi"], cMsg)
			Else
				FreeObj(oItemPagtos)
				cStatus := "error"
				cMsg := "json de pagamento invalido"
				oItemPagtos := RetJsonMsg(cStatus, jPagtos["faturas"][nX]["codvindi"], cMsg)
			EndIf
		Else
			FreeObj(oItemPagtos)
			cStatus := "error"
			cMsg := "json de pagamento nao informado para o titulo"
			oItemPagtos := RetJsonMsg(cStatus, jPagtos["faturas"][nX]["codvindi"], cMsg)
		EndIf
		aAdd(aPagtos, oItemPagtos)
	Next nX

Return aPagtos

/*/{Protheus.doc} RetJsonMsg
Retorna mensagem json com status
@type function
@version 1.0
@author nata.queiroz
@since 18/03/2020
@param cStatus, character
@param cCodVindi, character
@param cResult, character
@return oJsonMsg, object
/*/
Static Function RetJsonMsg(cStatus, cCodVindi, cResult)
	Local oJsonMsg := Nil

	oJsonMsg := JsonObject():New()
	oJsonMsg["status"] := cStatus
	oJsonMsg["codvindi"] := cCodVindi
	oJsonMsg["result"] := cResult

Return oJsonMsg

/*/{Protheus.doc} GrvPagto
Grava pagamento pendente de baixa do titulo financeiro
@type function
@version 1.0
@author nata.queiroz
@since 18/03/2020
@param cCodMod, character
@param cJson, character
/*/
Static Function GrvPagto(cCodMod, cJson)
	Local oVindi := Nil
	Local cTipo := "1" //-- 1 => Pagamento | 2 => Estorno | 3 => Tentativa | 4 => Teste

	oVindi := IntegraVindi():New()
	oVindi:IncluiTabReceb(cCodMod, cTipo, cJson)

	FreeObj(oVindi)
Return

/*/{Protheus.doc} ExistU63
Verifica se o pagamento já está gravado
@type function
@version 1.0
@author nata.queiroz
@since 20/03/2020
@param cCodVindi, character
@return lRet, logic
/*/
Static Function ExistU63(cCodVindi)
	Local lRet := .F.
	Local cQry := ""
	Local nQtdReg := 0
	Local cTipo := "1" //-- 1 => Pagamento | 2 => Estorno | 3 => Tentativa | 4 => Teste

	Default cCodVindi := ""

	cQry := "SELECT U63_CODIGO CODIGO "
	cQry += "FROM " + RetSqlName("U63")
	cQry += "WHERE D_E_L_E_T_ <> '*' "
	cQry += "AND U63_MSFIL = '"+ xFilial("U65") +"' "
	cQry += "AND U63_ENT = '"+ cTipo +"' "
	cQry += "AND U63_IDVIND = '"+ AllTrim(cCodVindi) +"' "
	cQry := ChangeQuery(cQry)

	If Select("EXU63") > 0
		EXU63->( DbCloseArea() )
	EndIf

	MPSysOpenQuery(cQry, "EXU63")

	If EXU63->(!Eof())
		lRet := .T.
	EndIf

	If Select("EXU63") > 0
		EXU63->( DbCloseArea() )
	EndIf

Return(lRet)

/*/{Protheus.doc} ValidJson
Valida estrutura do json recebido
@type function
@version 1.0
@author nata.queiroz
@since 24/03/2020
@param cBody, character
@param jBody, jsonobject
@param oResponse, object
@return lRet, logic
/*/
Static Function ValidJson(cBody, jBody, oResponse)
	Local lRet := .T.
	Local cJsonRet := ""

	Default cBody := ""
	Default oResponse := JsonObject():New()
	Default jBody := JsonObject():New()

	If !Empty(cBody)
		cJsonRet := ValType( jBody:FromJson( LOWER(cBody) ) )
		If cJsonRet == "U"
			cJsonRet := ValType( jBody:GetJsonObject("faturas") )
			If cJsonRet == "A"
				If Len(jBody["faturas"]) <= 0
					lRet := .F.
					oResponse["status"] := "400"
					oResponse["result"] := "json sem pagamentos informados"
				EndIf
			Else
				lRet := .F.
				oResponse["status"] := "400"
				oResponse["result"] := "json nao contem array [faturas]"
			EndIf
		Else
			lRet := .F.
			oResponse["status"] := "400"
			oResponse["result"] := "json recebido invalido"
		EndIf
	Else
		lRet := .F.
		oResponse["status"] := "400"
		oResponse["result"] := "json body esta vazio"
	EndIf

Return lRet
