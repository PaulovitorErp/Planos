#include 'protheus.ch'

/*/{Protheus.doc} F040ALT
Valida os dados da alteração apos a confirmação da mesma
@author TOTVS
@since 19/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

/**********************/
User Function F040ALT()
/**********************/
	
Local aArea			:= GetArea()
Local oVindi		:= NIL
Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
Local cTipoAdt		:= SuperGetMv("MV_XTIPADT",.F.,"ADT")
Local cCodModulo	:= ""

// se o tipo do titulo não for de crédito ou abatimento
if !( AllTrim(SE1->E1_TIPO) $ ("NCC/RA/TX/IS/IR/CS/CF/PI/AB-/" + cTipoAdt) )
	
	if ((lFuneraria .AND. !Empty(SE1->E1_XCTRFUN)) .OR. (lCemiterio .AND. !Empty(SE1->E1_XCONTRA)))
	
		cCodModulo := iif(lFuneraria,"F","C")

		// posiciono no metodo de pagamento da vindi
		U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
		if U60->(DbSeek(xFilial("U60") + SE1->E1_XFORPG))
		
			// se o método estiver ativo
			if U60->U60_STATUS == "A"
	
				// crio o objeto de integracao com a vindi
				oVindi := IntegraVindi():New()
				
				// envia exclusão do título na vindi
				oVindi:IncluiTabEnvio(cCodModulo,"3","E",1,SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)
	
				// envia a inclusão do título atualizado
				oVindi:IncluiTabEnvio(cCodModulo,"3","I",1,SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)
				
			endif
	
		endif
		
		
	endif

endif


RestArea(aArea)		

Return()
