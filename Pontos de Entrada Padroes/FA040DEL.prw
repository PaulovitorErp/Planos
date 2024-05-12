#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} FA040DEL
Tem como finalidade permitir executar rotinas personalizadas após o termino do processamento de exclusão do título,
a partir da opção 'Excluir' do cadastro de contas a receber.
@author TOTVS
@since 06/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function FA040DEL()
	/***********************/

	Local aArea			:= GetArea()
	Local aAreaU60		:= {}
	Local oVindi		:= NIL
	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
	Local lRecorrencia	:= SuperGetMv("MV_XATVREC",.F.,.F.)
	Local cCodModulo	:= ""

	// se o tipo do titulo não for de crédito ou abatimento
	if !( AllTrim(SE1->E1_TIPO) $ "NCC/RA/TX/IS/IR/CS/CF/PI/AB-" )

		if lRecorrencia .And. ((lFuneraria .AND. !Empty(SE1->E1_XCTRFUN)) .OR. (lCemiterio .AND. !Empty(SE1->E1_XCONTRA)))

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

					//Verifica rotinas que ja arquivaram o cliente na vindi
					//pois o arquivamento do cliente na vindi ja cancela as faturas
					if !IsInCallStack("U_MANUTRES"); 			//-- Resetar o contrato cemiterio
						.And. !IsInCallStack("U_RFUNA009"); 	//-- Resetar o contrato funerario
						.And. !IsInCallStack("U_RFUNA015"); 	//-- Cancelar o contrato funerario
						.And. !IsInCallStack("FINA460"); 		//-- Rotina Liquidacao a Receber
						.And. !IsInCallStack("U_RFUNA006"); 	//-- Transferencia de Titularidade
						.And. !IsInCallStack("U_RCPGE035");  	//-- Cancelamento de Contrato Cemiteio
						.And. !IsInCallStack("RemoverRecorrencia")  	//-- Remover da recorrencia

						// crio o objeto de integracao com a vindi
						oVindi := IntegraVindi():New()
						oVindi:IncluiTabEnvio(cCodModulo,"3","E",1,SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)
					Endif
				endif
			endif

			RestArea(aAreaU60)

		endif

	endif


	RestArea(aArea)

Return(Nil)
