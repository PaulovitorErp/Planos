#include "totvs.ch"

/*/{Protheus.doc} MTGRVVLD
Ponto de entrada validar a gravacao das alteracoes 
do banco de conhecimento 
@type function
@version 1.0
@author g.sampaio
@since 03/04/2024
@return logical, retorno da validacao
/*/
User Function MTGRVVLD()

	Local lRetorno              := .F.
	Local oVirtusGestaoAcessos	:= VirtusGestaoAcessos():New()
	Local nObjeto			   	:= 0
	Local nPosRecno             := aScan(aHeader,{|x| AllTrim(x[2]) == "AC9_REC_WT"})
	Local nPosObjeto            := aScan(aHeader,{|x| AllTrim(x[2]) == "AC9_OBJETO"})

	// verifica se as rotinas estão ativas
	If oVirtusGestaoAcessos:Rotinas()

		// mudo o valor do retorno para falso
		lRetorno := .F.

		oVirtusGestaoAcessos:AcessosUsuario()

		If oVirtusGestaoAcessos:ValidaAcessos(18) // incluir documentos
			lRetorno := .T.
		ElseIf oVirtusGestaoAcessos:ValidaAcessos(19) // alterar documentos
			lRetorno := .T.
		Else
			MsgAlert("Usuário sem permissão para incluir/alterar documentos!", "Acesso Negado")
		EndIf

		For nObjeto := 1 To Len(aCols)

			// se o retorno for verdadeiro e o usuário não tem permissão para alterar documentos
			If lRetorno .And. !aCols[nObjeto][Len(aHeader)+1] .And. aCols[nObjeto][nPosRecno] > 0;
					.And. U_RTILE81A(aCols[nObjeto][nPosRecno], aCols[nObjeto][nPosObjeto]) .And. !oVirtusGestaoAcessos:ValidaAcessos(19)
				lRetorno := .F.
				MsgAlert("Usuário sem permissão para alterar documentos!", "Acesso Negado")
				Exit
			EndIf

		Next nObjeto

	EndIf

Return(lRetorno)
