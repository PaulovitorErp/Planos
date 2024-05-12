#include 'totvs.ch'

/*/{Protheus.doc} FIN460E1
O ponto de entrada FIN460EI pode ser utilizado para tratamento 
complementar no registro da tabela de contas a receber (SE1),  
antes da exclusão do título gerado pela liquidação, 
no cancelamento do processo de liquidação.  
@type function
@version 1.0  
@author g.sampaio
@since 26/05/2021
/*/
User Function FIN460E1()

	Local oVirtusFin := Nil

    oVirtusFin := VirtusFin():New()

    // vou excluir as multiplas naturezas da liquidaao
    oVirtusFin:ExcluiMultiNatLiquidacao(SE1->(Recno()))

Return(Nil)
