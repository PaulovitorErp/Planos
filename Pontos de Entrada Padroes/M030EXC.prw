#include 'protheus.ch'

/*/{Protheus.doc} M030EXC
Executado após o usuário confirmar a exclusão; Depois da execução do mesmo, será feita a exclusão efetiva dos dados 
do Cliente no arquivo.
@author TOTVS
@since 20/09/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

/**********************/
User Function M030EXC()
/**********************/

Local aArea	:= GetArea()
	
RestArea(aArea)

Return
