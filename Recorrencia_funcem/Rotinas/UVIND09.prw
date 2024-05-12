#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH" 
#INCLUDE 'RESTFUL.CH'
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"  

/*###########################################################################
#############################################################################
## Programa  | UVIND09 | Auto r| Wellington Gonçalves  | Data | 19/02/2019 ##
##=========================================================================##
## Desc.     | Server API Rest da Funerária para baixa de títulos 		   ##
## 			 | recebidos na Vindi  										   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

User Function UVIND09()
Return()
	
WSRESTFUL APIVindi DESCRIPTION "EndPoint do Módulo Funerária para comunicacao com a plataforma Vindi"
	
	WSDATA cIdGrupo 	AS CHARACTER OPTIONAL
	WSDATA cIdFilial 	AS CHARACTER OPTIONAL
	
	WSMETHOD POST; 
	DESCRIPTION "POST"; 
	WSSYNTAX "apivindi/{cIdGrupo}/{cIdFilial}"
	
	WSMETHOD GET; 
	DESCRIPTION "GET"; 
	WSSYNTAX "[ GET ]"
  
END WSRESTFUL

/*###########################################################################
#############################################################################
## Programa  | POST |Autor| Wellington Gonçalves 		|Data|  19/02/2019 ##
##=========================================================================##
## Desc.     | Método POST												   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

WSMETHOD POST WSRECEIVE cIdGrupo,cIdFilial WSSERVICE APIVindi

	Local lConnect			:= .F.
	Local oJsonRetorno		:= NIL
	Local oVindi			:= NIL
	Local cBodyJson			:= ""
	Local oResponse			:= JsonObject():New()
	Local cTipoVindi		:= ""
	Local cCodVindi			:= ""
	Local cMetodoPag		:= ""
	Local cTipo				:= ""
	Local lFuneraria		:= ""
	Local lCemiterio		:= ""
	Local cCodModulo		:= ""
	Local nStart			:= Seconds()
	Local cMessage			:= ""
	Local cBkpEmpAnt 		:= cEmpAnt
	Local cBkpFilAnt		:= cFilAnt

	Default Self:cIdGrupo 	:= cEmpAnt
	Default Self:cIdFilial 	:= cFilAnt

	cEmpAnt := Self:cIdGrupo
	cFilAnt	:= Self:cIdFilial

	cMessage := "POST => API PARA WEBHOOKS VINDI => EMPRESA " + cEmpAnt + " FILIAL " + cFilAnt
	FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

	Self:SetContentType("application/json; charset=utf-8") 

	cBodyJson := AllTrim(Self:GetContent())

	//RpcSetType(3)
	//Reset Environment
	lConnect := .T. //RpcSetEnv(Self:cIdGrupo,Self:cIdFilial) 

	// se logou conseguiu logar na empresa
	if lConnect

		cMessage := "Conectou a filial com sucesso!"
		FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

		// converto a string JSON
		if FWJsonDeserialize(cBodyJson,@oJsonRetorno)

			cMessage := "Json recebido: " + cBodyJson
			FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})
			
			lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
			lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
		
			if lFuneraria
				cCodModulo := "F"
			elseif lCemiterio	
				cCodModulo := "C"
			endif
			
			// se o módulo funeraria ou cemitério estiverem habilitados
			if !Empty(cCodModulo)
			
				cTipoVindi := oJsonRetorno:Event:Type
				
				if AllTrim(cTipoVindi) == "bill_paid"
					cTipo := "1" // Pagamento
				elseif AllTrim(cTipoVindi) == "charge_refunded"
					cTipo := "2" // Estorno
				elseif AllTrim(cTipoVindi) == "charge_rejected"
					cTipo := "3" // Tentativa
				elseif AllTrim(cTipoVindi) == "test"
					cTipo := "4" // Teste
				endif
			
				if !Empty(cTipo)
					// crio o objeto de integracao com a vindi
					oVindi := IntegraVindi():New()

					If cTipo == "1" //-- Pagamento
						cCodVindi := cValToChar(oJsonRetorno:Event:Data:Bill:Id)
						cMetodoPag := oJsonRetorno:Event:Data:Bill:Charges[1]:Payment_method:Code
						If .Not. ExistU63(cCodVindi) .And. cMetodoPag <> "cash"
							// grava tabela de recebimento
							oVindi:IncluiTabReceb(cCodModulo,cTipo,cBodyJson)
						EndIf
					Else
						// grava tabela de recebimento
						oVindi:IncluiTabReceb(cCodModulo,cTipo,cBodyJson)
					EndIf
				
				endif
			
			endif
			
			oResponse["status"] := 200
				
		else
			cMessage := "Json recebido da Vindi esta invalido!"
			FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

			::SetResponse('{"status":500}')
		endif

	else
		cMessage := "Falha ao conectar a filial!"
		FwLogMsg("ERROR", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

		::SetResponse('{"status":500}')
	endif
		
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

	cEmpAnt := cBkpEmpAnt
	cFilAnt	:= cBkpFilAnt

Return(.T.)

/*###########################################################################
#############################################################################
## Programa  | GET |Autor| Wellington Gonçalves 		|Data|  19/02/2019 ##
##=========================================================================##
## Desc.     | Método GET												   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

WSMETHOD GET WSSERVICE APIVindi

	Local oResponse	:= JsonObject():New()
	Local nStart := Seconds()
	Local cMessage := ""

	cMessage := "GET => API PARA WEBHOOKS VINDI => EMPRESA " + cEmpAnt + " FILIAL " + cFilAnt
	FwLogMsg("INFO", , "REST", FunName(), "", "01", cMessage, 0, (Seconds() - nStart), {})

	Self:SetContentType("application/json") 

	oResponse["status"] := 200
		
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return(.T.)

/*/{Protheus.doc} ExistU63
Verifica se o pagamento já está gravado
@type function
@version 1.0
@author nata.queiroz
@since 20/03/2020
@param cCodVindi, character, cCodVindi
@return logical, lRet
/*/
Static Function ExistU63(cCodVindi)
    Local lRet := .F.
    Local cQry := ""
    Local nQtdReg := 0
    Local cTipo := "1" //-- 1 => Pagamento | 2 => Estorno | 3 => Tentativa | 4 => Teste

    Default cCodVindi := ""

    cQry := "SELECT U63_CODIGO CODIGO "
    cQry += "FROM " + RetSqlName("U63") +" (NOLOCK)"
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

Return lRet
