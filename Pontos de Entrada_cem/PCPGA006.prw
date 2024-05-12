#include "protheus.ch"

/*/{Protheus.doc} PCPGA006
Pontos de Entrada do Cadastro de Composição de Produtos
@type function
@version 1.0
@author TOTVS
@since 22/04/2016
/*/

User Function PCPGA006()

	Local aParam 		:= PARAMIXB
	Local oObj			:= aParam[1]
	Local cIdPonto		:= aParam[2]
	Local oModelU05		:= oObj:GetModel("U05MASTER")
	Local xRet 			:= .T.

	If cIdPonto == 'MODELPOS'

		If oObj:GetOperation() == 5 //Confirmação da exclusão

			If ExistU05()

				xRet := .F.
				Help( ,, 'Help - MODELPOS',, 'Não é permitido a exclusão deste tipo de plano, pois o mesmo se encontra associado a contrato(s). Para concluir a exclusão, favor excluir os contratos relacionados.', 1, 0 )
			Endif

		ElseIf oObj:GetOperation() == 4 .Or. oObj:GetOperation() == 3 //Confirmação alteração ou inclusao

			// verifico se o campo uso existe no ambiente
			if U05->(FieldPos("U05_USO")) > 0

				// caso for utilizado o uso para ambos no apontamento de cemiterio
				if oModelU05:GetValue("U05_USO") == "1"
					xRet := .F.
					Help( ,, 'Help - MODELPOS',, 'Não é permitido o uso do produto para "1=Ambos", no módulo de cemitério.', 1, 0 )
				endIf

			endIf

		endIf

	Endif

Return(xRet)

/*************************/
Static Function ExistU05()
/*************************/

	Local lRet := .F.

	DbSelectArea("U00")
	U00->(DbSetOrder(6)) //U00_FILIAL+U00_PLANO

	If U00->(DbSeek(xFilial("U00")+U05->U05_CODIGO))
		lRet := .T.
	Endif

Return lRet
