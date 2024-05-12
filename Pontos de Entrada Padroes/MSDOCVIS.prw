#include "totvs.ch"

/*/{Protheus.doc} MSDOCVIS
MSDOCVIS - Ponto de Entrada utilizado 
para somente visualizar o Conhecimento 
@type function
@version 1.0
@author g.sampaio
@since 03/04/2024
@return logical, retorno logico da funcao
/*/
User Function MSDOCVIS()

	Local lRetorno              := .T.
	Local oVirtusGestaoAcessos	:= VirtusGestaoAcessos():New()

	oVirtusGestaoAcessos:AcessosUsuario()

	If oVirtusGestaoAcessos:ValidaAcessos(18) // incluir documentos
		lRetorno := .F.
	ElseIf oVirtusGestaoAcessos:ValidaAcessos(19) // alterar documentos
		lRetorno := .F.
	ElseIf oVirtusGestaoAcessos:ValidaAcessos(20) // excluir documentos
		lRetorno := .F.
	EndIf

Return(lRetorno)
