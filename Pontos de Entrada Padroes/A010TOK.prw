#include "totvs.ch"

/*/{Protheus.doc} A010TOK
LOCALIZAÇÃO : Function A010TudoOK - Função de Validação para 
inclusão ou alteração do Produto.

EM QUE PONTO: No início das validações após a confirmação da 
inclusão ou alteração, antes da gravação do Produto; deve 
ser utilizado para validações adicionais para a INCLUSÃO ou ALTERAÇÃO do Produto.

Eventos

@type function
@version 1.0 
@author totvs
@since 06/05/2021
@return logical, Deve retornar .T. se validação OK, para continuar e incluir ou atualizar o produto ou .F. para retornar a tela de inclusao ou alteracao, interrompendo o processo.
/*/
User Function A010TOK()

	Local lRetorno := .T.

	// executo a valida
	if ExistBlock("RCPGE067") .And. ALTERA
		lRetorno := U_RCPGE067( SB1->B1_COD, M->B1_XTPCEM )
	endIf

Return(lRetorno)
