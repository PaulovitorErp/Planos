#include 'totvs.ch'

/*/{Protheus.doc} LJGRVTIT
O ponto de entrada é para validar os titulos recebido no momento da confirma do atendimento
Controle de Lojas - rotina Venda Assistida - opcao gravar como venda

Esta sendo utilizado para gravar integracao VINDI para os titulos que foram enviado

@author Leandro Rodrigues
@since 01/05/2019
@version undefined
@param  aPgtos - Descricao das formas de pagamentos.
lRe -    Retorno logico da funcao principal de Gravacao de Titulos
aTitulo- Array com os titulos carregados
cTotRecNFis -  Nome do totalizador nao fiscal.
aTitImpr - Array com os titulos a serem impressos
nTroco   - valor do troco

@type function
@history 13/04/2020 - Marcos Natã Santos
/*/
User Function LJGRVTIT(aPgtos , lRet, aTitulo, cTotRecNFis , aTitImpr, nTroco)

	Local aAreaSE1      := SE1->(GetArea())
	Local nX			:= 1
	
	DEFAULT aPgtos      := {}
	DEFAULT aTitulo     := {}
	DEFAULT aTitImpr    := {}
	DEFAULT cTotRecNFis := ""
	DEFAULT nTroco      := 0
	DEFAULT lRet        := .T.

	If Len(aTitulo) > 0

		DbSelectArea("SE1")
		SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

		For nX :=1 To Len(aTitulo)
			//Valido se esta marcado
			if aTitulo[nX,1]
				if SE1->(DbSeek(xFilial("SE1") + aTitulo[nX,13] + aTitulo[nX,14] + aTitulo[nX,2] + aTitulo[nX,3] + aTitulo[nX,4] + aTitulo[nX,11]))
					If FindFunction("U_UVIND18")
						//-- Valida atualização em títulos que estão em recorrência
						lRet := U_UVIND18(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
						If !lRet
							Exit
						EndIf
					EndIf
				endif
			endif
		next nX
	endif

	RestArea(aAreaSE1)
Return lRet