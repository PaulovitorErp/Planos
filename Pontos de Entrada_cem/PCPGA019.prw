#include "protheus.ch"

/*/{Protheus.doc} PCPGA019
Pontos de Entrada do Cadastro Mala Direta
@author TOTVS
@since 25/04/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function PCPGA019()
/***********************/

Local aParam 		:= PARAMIXB
Local oObj			:= aParam[1]
Local cIdPonto		:= aParam[2]
Local oModelU23		:= oObj:GetModel("U23MASTER")

Local cCod			:= ""
Local cCodole		:= ""
Local cStatus		:= ""

Local xRet 			:= .T.

If cIdPonto == 'MODELPOS'

	cCod		:= oModelU23:GetValue('U23_CODIGO')
	cCodole		:= oModelU23:GetValue('U23_CONDOL')
	cStatus		:= oModelU23:GetValue('U23_STATUS')

	If oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4 //Confirmação das operações de inclusão ou alteração

		If cCodole == "S" .And. cStatus == "A" //Mala Direta de condolências e ativa
		
			If ExistU23(cCod)
			
				xRet := .F.
				Help( ,, 'Help - MODELPOS',, 'Não é permitido a inclusão de mais de 01 (uma) Mala Direta de condolência, em função do JOB de comunicação.', 1, 0 )
			Endif
		Endif	
	Endif
Endif

Return xRet

/*****************************/
Static Function ExistU23(cCod)
/*****************************/

Local lRet 	:= .F.
Local aArea	:= GetArea()

DbSelectArea("U23")
U23->(DbSetOrder(1)) //U23_FILIAL+U23_CODIGO
U23->(DbGoTop())

While U23->(!EOF()) .And. U23->U23_FILIAL == xFilial("U23") 
	
	If U23->U23_CODIGO <> cCod .And. U23->U23_CONDOLE == "S" .And. U23->U23_STATUS == "A"
	
		lRet:= .T.
		Exit
	Endif
	
	U23->(DbSkip())
EndDo

RestArea(aArea)

Return lRet