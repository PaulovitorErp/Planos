#include 'protheus.ch'

/*/{Protheus.doc} FA070POS
Executado antes da montagem da tela de baixa do contas a receber.
@author TOTVS
@since 04/08/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function FA070POS()
/***********************/

Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
Local nPercMulta	:= GetMV("MV_LJMULTA")

If lCemiterio .OR. lFuneraria

	If nMulta > 0
	
		If nPercMulta > 0
	
			nMulta := (SE1->E1_SALDO + SE1->E1_SDACRES) * (nPercMulta / 100)
			
		Endif
	Endif
	
Endif

Return