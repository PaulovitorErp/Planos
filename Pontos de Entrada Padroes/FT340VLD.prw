#include "totvs.ch"

/*/{Protheus.doc} FT340VLD
FT340VLD: Valida se o usuário tem permissão para incluir, alterar ou excluir documentos
@type function
@version 1.0
@author g.sampaio
@since 03/04/2024
@return logical, retorno se o usuário tem permissão ou não
/*/
User Function FT340VLD()

	Local lRetorno              := .F.
	Local nOpc                  := ParamIXB[01] as numeric
	Local cFunName              := ParamIXB[02] as character
	Local oVirtusGestaoAcessos	:= VirtusGestaoAcessos():New()

	oVirtusGestaoAcessos:AcessosUsuario()

	If nOpc == 3 .And. oVirtusGestaoAcessos:ValidaAcessos(18) // incluir documentos
		lRetorno := .T.
	ElseIf  nOpc == 4 .And. oVirtusGestaoAcessos:ValidaAcessos(19) // alterar documentos
		lRetorno := .T.
	ElseIf  nOpc == 5 .And.oVirtusGestaoAcessos:ValidaAcessos(20) // excluir documentos
		lRetorno := .T.
	EndIf

Return(lRetorno)
