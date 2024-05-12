#include "totvs.ch"

/*/{Protheus.doc} OM010MNU
Ponto de entrada para criar opcoes no menu
da rotina de Tabela de Precos
@type function
@version 1.0
@author g.sampaio
@since 14/03/2024
/*/
User Function OM010MNU()

	Aadd(aRotina,{'Replica Tab.Preco', 'U_VirtusMTabPrecoMigracao()', 0, 3, 0, NIL})

Return(Nil)
