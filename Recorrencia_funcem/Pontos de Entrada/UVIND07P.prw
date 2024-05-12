#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} UVIND07P
Ponto de Entrada do Perfil de Pagamento
@type function
@version 
@author Wellington Gonçalves
@since 26/01/2019
@return return_type, return_description
/*/
User Function UVIND07P()

	Local aParam 		:= PARAMIXB
	Local oObj			:= aParam[1]
	Local cIdPonto		:= aParam[2]
	Local cIdModel		:= IIf( oObj<> NIL, oObj:GetId(), aParam[3] )
	Local cClasse		:= IIf( oObj<> NIL, oObj:ClassName(), '' )
	Local oModelU64		:= oObj:GetModel( 'U64MASTER' )
	Local lRet 			:= .T.
	Local lRetExc		:= .F.
	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
	Local oVindi		:= NIL
	Local cErroVindi	:= ""
	Local cCodVindi		:= ""
	Local cToken		:= ""
	Local cCodModulo	:= ""
	Local cOrigem		:= "UVIND07"
	Local cOrigemDesc	:= "Cadastro de Perfil de Pagamento"

	If cIdPonto == "MODELPOS" // Confirmação do Cadastro

		// verifico a rotina e o parametro para verificar o modulo
		if lCemiterio .And. "CPG" $ AllTrim(FunName()) // para modulo de cemiterio
			cCodModulo := "C"
		elseIf lCemiterio .And. "FUN" $ AllTrim(FunName()) // para modulo de funeraria
			cCodModulo := "F"
		elseIf lCemiterio // para modulo de cemiterio
			cCodModulo := "C"
		elseIf lFuneraria // para modulo de funeraria
			cCodModulo := "F"
		endIf

		//-- Avalia origem das operacoes (Funeraria) --//
		If FWIsInCallStack("U_UVIND11")
			cOrigem := "UVIND11"
			cOrigemDesc := "Alteracao de Perfil de Pagamento"
		ElseIf FWIsInCallStack("U_UVIND12")
			cOrigem := "UVIND12"
			cOrigemDesc := "Alteracao para Recorrencia"
		ElseIf FWIsInCallStack("U_RFUNA004")
			cOrigem := "RFUNA004"
			cOrigemDesc := "Ativacao do Contrato Venda"
		ElseIf FWIsInCallStack("U_RFUNA006")
			cOrigem := "RFUNA006"
			cOrigemDesc := "Alteracao de Titularidade do Contrato"
		ElseIf FWIsInCallStack("U_PFUNA044")
			cOrigem := "PFUNA044"
			cOrigemDesc := "Locacao de Convalescencia"
		EndIf

		// se a operacao for inclusao
		if oObj:GetOperation() == 3

			// crio o objeto de integracao com a vindi
			oVindi := IntegraVindi():New()

			// envia cliente para a Vindi
			FWMsgRun(,{|oSay| lRet := oVindi:CliOnline("I",cCodModulo,@cErroVindi,cOrigem,cOrigemDesc)},'Aguarde...','Enviando Inclusão do Cliente na Plataforma Vindi...')

			if lRet

				// envia perfil de pagamento para vindi
				FWMsgRun(,{|oSay| lRet := oVindi:IncluiPerfil(cCodModulo,@cErroVindi,@cCodVindi,@cToken,;
					oModelU64:GetValue('U64_FORPG'),oModelU64:GetValue('U64_NOMCAR'),oModelU64:GetValue('U64_NUMCAR'),;
					oModelU64:GetValue('U64_VALIDA'),oModelU64:GetValue('U64_CVV'),;
					oModelU64:GetValue('U64_DESBAN'),cOrigem,cOrigemDesc)},'Aguarde...',;
					'Enviando Inclusão do Perfil do Cliente para Plataforma Vindi...')

				if lRet
					oModelU64:LoadValue("U64_CODVIN"	,	cCodVindi)
					oModelU64:LoadValue("U64_TOKEN"		,	cToken)
				else

					Help(NIL, NIL, "INCLUIPERFIL", NIL, "Não foi possível realizar a inclusão do Perfil do Cliente na Vindi!", 1, 0, NIL, NIL, NIL, NIL, NIL, {cErroVindi})

					// se ocorreu um erro no envio do perfil de pagamento, deve ser enviado a arquivação do cliente para vindi
					FWMsgRun(,{|oSay| lRetExc := oVindi:CliOnline("E",cCodModulo,@cErroVindi,cOrigem,cOrigemDesc)},'Aguarde...','Enviando Exclusão do Cliente na Plataforma Vindi...')

					if !lRetExc
						Help(NIL, NIL, "ERROINCLUIPERFIL", NIL, "Não foi possível realizar a exclusão do Cliente na Vindi!", 1, 0, NIL, NIL, NIL, NIL, NIL, {cErroVindi})
					endif

				endif

			else
				Help(NIL, NIL, "CLIONLINE", NIL, "Não foi possível realizar a inclusão do Cliente na Vindi!", 1, 0, NIL, NIL, NIL, NIL, NIL, {cErroVindi})
			endif

		elseif oObj:GetOperation() == 4 // Alteração

			// crio o objeto de integracao com a vindi
			oVindi := IntegraVindi():New()

			// envia perfil de pagamento para vindi
			FWMsgRun(,{|oSay| lRet := oVindi:IncluiPerfil(cCodModulo,@cErroVindi,@cCodVindi,@cToken,oModelU64:GetValue('U64_FORPG'),;
				oModelU64:GetValue('U64_NOMCAR'),oModelU64:GetValue('U64_NUMCAR'),oModelU64:GetValue('U64_VALIDA'),;
				oModelU64:GetValue('U64_CVV'),oModelU64:GetValue('U64_DESBAN'),cOrigem,cOrigemDesc)},;
				'Aguarde...','Enviando Alteração do Perfil do Cliente para Plataforma Vindi...')

			if lRet
				oModelU64:LoadValue("U64_CODVIN"	,	cCodVindi)
				oModelU64:LoadValue("U64_TOKEN"		,	cToken)
			else
				Help(NIL, NIL, "INCLUIPERFIL", NIL, "Não foi possível realizar a alteração do Perfil do Cliente na Vindi!", 1, 0, NIL, NIL, NIL, NIL, NIL, {cErroVindi})
			endif

		endif

	endif

Return(lRet)
