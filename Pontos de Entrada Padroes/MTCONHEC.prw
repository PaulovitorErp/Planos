#include "totvs.ch"

/*/{Protheus.doc} MTCONHEC
Ponto de entrada para bloquear o botão "Banco Conhecimento para alguns usuários
@type function
@version 1.0
@author g.sampaio
@since 03/04/2024
@return logical, retorno se o usuário tem acesso ou não ao botão
/*/
User Function MTCONHEC()

	Local lRetorno              := .F.
	Local oVirtusGestaoAcessos	:= VirtusGestaoAcessos():New()

	oVirtusGestaoAcessos:AcessosUsuario()

	If oVirtusGestaoAcessos:ValidaAcessos(18) .Or. oVirtusGestaoAcessos:ValidaAcessos(19) .Or. oVirtusGestaoAcessos:ValidaAcessos(20)// acesso a base de conhecimento
		lRetorno := .T.
	EndIf

Return(lRetorno)
