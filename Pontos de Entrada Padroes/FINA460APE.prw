#include 'totvs.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} FINA460A
Ponto de entrada da rotina de liquidação a receber
Obs.: Nome do arquivo não pode ser FINA460A, pois este
é o nome do fonte padrão. Utilizamos FINA460APE.
@author Leandro Rodrigues
@since 22/04/2019
@version 1.0
@history 14/04/2020, Marcos Natã Santos, Refactoring
@history 29/05/2020, g.sampaio, VPDV-473 - Ao realizar a liquidacao ira gravar 
para cada titulo gerado o vinculo com o contrato, via program RUTILE24
@return xRet
/*/
User function FINA460A()

	Local aParam 		:= PARAMIXB
	Local xRet 			:= .T.
	Local oObj 			:= ''
	Local oModelFO0		:= Nil
	Local oModelFO1 	:= Nil
	Local oModelFO2 	:= Nil
	Local cIdPonto 		:= ''
	Local cIdModel 		:= ''
	Local nX			:= 1

	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		oModelFO0 := oObj:GetModel("MASTERFO0")
		oModelFO1 := oObj:GetModel("TITSELFO1")
		oModelFO2 := oObj:GetModel("TITGERFO2")

		If cIdPonto == 'MODELPOS' // Bloco substitui o ponto de entrada F460TOK e FA460CON

			// verifico se o campo customizado de forma de pagamento existe
			if FO2->(FieldPos("FO2_XFORPG")) > 0

				//Valido se Forma de pagamento foi preenchida para as faturas/Liquidacao
				For nX := 1 to oModelFO2:Length()

					oModelFO2:GoLine(nX)

					//valida se preencheu a forma Pagto
					if Empty(oModelFO2:GetValue("FO2_XFORPG"))

						Help( ,, 'Atenção',, 'Forma de Pagamento não foi informada para todos os titulos gerados !', 1, 0 )
						xRet := .F.
						Exit
					endif
				Next nX

			endif

			If FindFunction("U_UVIND18")

				//-- Verifica se titulos selecionados estao em recorrência na plataforma Vindi
				For nX := 1 To oModelFO1:Length()

					oModelFO1:GoLine(nX)

					//-- Itens que foram marcados
					If oModelFO1:GetValue("FO1_MARK")

						//-- Valida atualização em títulos que estão em recorrência
						xRet := U_UVIND18(oModelFO1:GetValue("FO1_PREFIX"),;
							oModelFO1:GetValue("FO1_NUM"),;
							oModelFO1:GetValue("FO1_PARCEL"),;
							oModelFO1:GetValue("FO1_TIPO"))

						If !xRet
							Exit
						EndIf
					EndIf

				Next nX
			EndIf

		ElseIf cIdPonto == 'MODELCANCEL' // Bloco substitui os pontos de entrada F460CAN, F460CON e F460SAID no cancelamento da tela de geração de liquidação.
			xRet := .T.
		ElseIf cIdPonto == 'FORMLINEPRE' // Bloco substitui o ponto de entrada A460VALLIN.
			xRet := .T.
		ElseIf cIdPonto == 'FORMLINEPOS' // Substitui o ponto de entrada FA460LOK
			xRet := .T.
		ElseIf cIdPonto == 'MODELCOMMITNTTS' // Bloco substitui o ponto de entrada F460GRV.

			if oObj:GetOperation() == 3 // para inclusao

				// verifico se o program RUTILE24 esta compilado
				If ExistBlock("RUTILE24")

					// executo a implementacao do codigo gravar os dados da liquidacao no titulo
					U_RUTILE24( oModelFO2, oModelFO0, oModelFO1 )

				EndIf

			endif

		ElseIf cIdPonto == 'BUTTONBAR' // Bloco substitui o ponto de entrada F460BOT.
			xRet := .T.
		EndIf
	EndIf

Return xRet
