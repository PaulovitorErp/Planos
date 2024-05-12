#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PUTIL032
Ponto de Entrada do Historico de Envio Notificações (Zenvia)
@type function
@version 1.0
@author danilo
@since 13/01/2022
/*/
User Function PUTIL032()


	Local aParam 				:= PARAMIXB
	Local oObj					:= aParam[1]
	Local cIdPonto				:= aParam[2]
	Local xRet 					:= .T.
	Local nOperation			

	If cIdPonto == 'MODELVLDACTIVE' //Para validar se deve ou nao ativar o Model
		
		nOperation := oObj:GetOperation()

		if (nOperation == 4 .OR. nOperation == 5) .AND. (UZF->UZF_STATUS == "1")
			Help( ,, 'Help',, 'Mensagem de Notificação já enviada! Ação não permitida.', 1, 0 )
			xRet := .F.
		endif

	endIf

Return(xRet)
