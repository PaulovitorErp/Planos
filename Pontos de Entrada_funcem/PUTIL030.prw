#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PUTIL030
Ponto de Entrada do Cadastro de Notificações (Zenvia)
@type function
@version 1.0
@author danilo
@since 13/01/2022
/*/
User Function PUTIL030()

	Local aParam 				:= PARAMIXB
	Local oObj					:= aParam[1]
	Local cIdPonto				:= aParam[2]
	Local oModelUZE				:= oObj:GetModel("UZEMASTER")
	Local xRet 					:= .T.

	If cIdPonto == 'MODELPRE' .And. oObj:GetOperation() == 4 //alteracao

		//Tratamento para não dar a mensagem de formulário não alterado
		cBkpDs := oModelUZE:GetValue('UZE_DESCRI')
		oModelUZE:LoadValue('UZE_DESCRI',"TESTE")
		oModelUZE:LoadValue('UZE_DESCRI',cBkpDs)

	endIf

Return(xRet)
