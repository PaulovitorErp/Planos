#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} FA040FIN
Ponto de entrada localizado após a inclusão do
título a receber	
@type function
@version 
@author Wellington Gonçalves
@since 12/02/2019
@return return_type, return_description
/*/
User Function FA040FIN()

	Local aArea			:= GetArea()
	Local aAreaU60		:= {}
	Local oVindi		:= NIL
	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
	Local lRecorrencia	:= SuperGetMv("MV_XATVREC",.F.,.F.)
	Local cTiposNRecor	:= Alltrim(SuperGetMv("MV_XTPNREC ",.F.,"ENT/NCC/RA/TX/IS/IR/CS/CF/PI/AB-/"))
	Local cCodModulo	:= ""

	// se o tipo do titulo não for de crédito ou abatimento e se nao foi feito adiantamento pelo Mobile
	if !( AllTrim(SE1->E1_TIPO) $ cTiposNRecor)

		if SE1->(FieldPos("E1_XPGTMOB")) > 0 .And. Empty(SE1->E1_XPGTMOB)

			// verifico se os modulos de cemiterio e planos, e a recorrencia estao habilitados
			if lRecorrencia .And. ( ( lFuneraria .And. !Empty(SE1->E1_XCTRFUN) ) .OR. ( lCemiterio .And. !Empty(SE1->E1_XCONTRA) ) )

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

				aAreaU60	:= U60->(GetArea())

				// posiciono no metodo de pagamento da vindi
				U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
				if U60->(DbSeek(xFilial("U60") + SE1->E1_XFORPG))

					// se o método estiver ativo
					if U60->U60_STATUS == "A"

						// crio o objeto de integracao com a vindi
						oVindi := IntegraVindi():New()
						oVindi:IncluiTabEnvio(cCodModulo,"3","I",1,SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)

					endif

				endif

				RestArea(aAreaU60)

			endif
		endif

	endif

	RestArea(aArea)

Return()
