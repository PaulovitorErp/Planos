#include "totvs.ch"

/*/{Protheus.doc} MTVLDACE
Ponto de entrada validar o acesso a rotina quando chamada pelo menu
@type function
@version 1.0
@author g.sampaio
@since 03/04/2024
@return logical, retorno logio da funcao
/*/
User Function MTVLDACE()

	Local lRetorno              := .F.
	Local oVirtusGestaoAcessos	:= VirtusGestaoAcessos():New()

	oVirtusGestaoAcessos:AcessosUsuario()

	If oVirtusGestaoAcessos:ValidaAcessos(17) // acesso a base de conhecimento
		lRetorno := .T.
	EndIf

Return(lRetorno)
