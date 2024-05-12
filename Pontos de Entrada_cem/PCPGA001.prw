#include 'totvs.ch'
#include 'topconn.ch'

#DEFINE CRLF CHR(10)+CHR(13)

/*/{Protheus.doc} PCPGA001
Pontos de Entrada do Cadastro Contrato
@author TOTVS
@since 08/03/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function PCPGA001()
/***********************/

	Local aParam 				:= PARAMIXB
	Local oObj					:= aParam[1]
	Local cIdPonto				:= aParam[2]
	Local oRegraNegociacao		:= Nil
	Local lAtivaNegociacao    	:= SuperGetMV("MV_XATVNEG",,.F.)       // ativa ou nao a regra de negociacao
	Local lAtivaManutencao		:= SuperGetMv("MV_XREGCEM",,.F.)		// parametro para ativacao da regra
	Local lRecorrencia			:= SuperGetMv("MV_XATVREC",.F.,.F.)
	Local lAtivaCobAdicional	:= SuperGetMV("MV_XCBADAU",, .F.)
	Local lContinua				:= .T.
	Local xRet 					:= .T.
	Local oSay1					:= NIL
	Local oMsg					:= NIL
	Local oButton1				:= NIL
	Local cMsg					:= ""
	Local lMostra				:= .F.

	Private	aCposU00			:= {}
	Private	aCposU02			:= {}
	Private	aCposU03			:= {}
	Private oModelU00			:= oObj:GetModel("U00MASTER")


	Static oDlgMsg

	If cIdPonto == "MODELVLDACTIVE"

		// caso for excluir
		if (oObj:GetOperation() == 5 .Or. oObj:GetOperation() == 4) .And. AllTrim(FunName()) == "RCPGA001" .And. U00->U00_TPCONT == "2"

			xRet := .F.
			Help( ,, 'Help - MODELPOS',, 'Contrato de Integração de Empresas, operação não permitida!', 1, 0 )

		endif

		// caso for diferente de inclusao e estiver na tela de contratos
		if oObj:GetOperation() <> 3 .And. AllTrim(FunName()) == "RCPGA001"

			// posiciono nas mensagens do contrato
			DbSelectArea("U03")
			U03->(DbSetOrder(1)) //U03_FILIAL+U03_CODIGO+U03_ITEM
			If U03->(MsSeek(xFilial("U03")+U00->U00_CODIGO))

				While U03->(!EOF()) .And. U03->U03_FILIAL == xFilial("U03") .And. U03->U03_CODIGO == U00->U00_CODIGO

					If U03->U03_MOSTRA == "S" .And. U03->U03_DTVIGE >= dDataBase

						cMsg += U03->U03_DESCRI
						cMsg += CRLF
						cMsg += Repl("_",92)
						cMsg += CRLF
					Endif

					U03->(DbSkip())
				EndDo

				If !Empty(cMsg)
					lMostra := .T.
				Endif
			Endif

			If lMostra

				DEFINE MSDIALOG oDlgMsg TITLE "Mensagens" From 0,0 TO 400,600 PIXEL

				//Memo
				@ 005,005 Get oMsg Var cMsg MEMO Size 292,165 READONLY PIXEL OF oDlgMsg
				//Linha horizontal
				@ 170, 005 SAY oSay1 PROMPT Repl("_",292) SIZE 292, 007 OF oDlgMsg COLORS CLR_GRAY, 16777215 PIXEL

				//Botao
				@ 181, 250 BUTTON oButton1 PROMPT "Ok" SIZE 040, 010 OF oDlgMsg ACTION oDlgMsg:End() PIXEL

				ACTIVATE MSDIALOG oDlgMsg CENTERED
			Endif

		endIf

	ElseIf cIdPonto == 'MODELPOS' .And. (oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4) //Confirmação da inclusão ou alteração

		if Empty(oModelU00:GetValue('U00_PRIMVE'))
			xRet := .F.
			Help( ,, 'Help - MODELPOS',, ';O campo de Primeiro de Vencimento das Parcelas não foi preenchido, favor verifique o campo "Prim. Vencto"!', 1, 0 )
		endif

		If xRet .And. oModelU00:GetValue('U00_VLRENT')  > 0 .And. Empty(oModelU00:GetValue('U00_DTENTR') ) //Houver valor de Entrada e a data de entrada não for informada
			xRet := .F.
			Help( ,, 'Help - MODELPOS',, 'Quando houver valor de entrada, obrigatoriamente deve haver a data desta entrada.', 1, 0 )
		Endif

		If xRet .And. oModelU00:GetValue('U00_VLRENT')  > oModelU00:GetValue('U00_VALOR') // Houver valor de Entrada e a data de entrada não for informada
			xRet := .F.
			Help( ,, 'Help - MODELPOS',, 'O valor da entrada não pode ser o maior que o valor do contrato!', 1, 0 )
		Endif

		If xRet .And. oModelU00:GetValue('U00_STATUS') == "P" .And. oModelU00:GetValue('U00_QTDPAR') == 1 .And. !Empty(oModelU00:GetValue('U00_DTENTR')) .And. oModelU00:GetValue('U00_VLRENT') <> oModelU00:GetValue('U00_VALOR') // Houver valor de Entrada e a data de entrada não for informada
			xRet := .F.
			Help( ,, 'Help - MODELPOS',, 'Quando houver apenas uma parcela e informações de entrada, obrigatoriamente o valor da entrada deve ser o mesmo que o valor do contrato!', 1, 0 )
		Endif

		// caso a regra de manutenção esteja habilitada
		if xRet .And. lAtivaManutencao

			// vefico se tem regra de manutencao preenchida
			if !Empty(oModelU00:GetValue('U00_REGRA'))

				// verifico se a forma de pagamento da taxa de manutencao esta preenchida
				if Empty(oModelU00:GetValue('U00_FPTAXA'))
					xRet := .F.
					Help( ,, 'Help - MODELPOS',, 'Quando houver regra de taxa de manutenção definida o campo de Forma de Pagamento da Taxa deve ser preenchido!', 1, 0 )

				elseIf oModelU00:GetValue('U00_TXMANU') == 0 // forma de pagamento
					xRet := .F.
					Help( ,, 'Help - MODELPOS',, 'Quando houver regra de taxa de manutenção definida o campo de Valor da Taxa de manutenção não pode ficar zerado!', 1, 0 )

				endIf

			endIf

			If oObj:GetOperation() == 4 // quando for alteracao da taxa de manutencao
				
				// ==================================================
				// validacoes sobre alteracao de taxa de manutencao
				// ==================================================

				if xRet .And. U00->U00_REGRA <> oModelU00:GetValue('U00_REGRA')
					xRet := .F.
					Help( ,, 'Help - MODELPOS',, 'Não é permitido a alteração da Regra de Manutenção, para alterar a Regra de Manutenção procure por "Outras Ações" > Taxa de Manutenção > "Altera Taxa de Manutenção"!', 1, 0 )

				EndIf

				if xRet .And. U00->U00_FPTAXA <> oModelU00:GetValue('U00_FPTAXA')
					xRet := .F.
					Help( ,, 'Help - MODELPOS',, 'Não é permitido a alteração a Forma de Pagamento da Manutenção, para alterar a Forma de Pagamento da Manutenção procure por "Outras Ações" > Taxa de Manutenção > "Altera Taxa de Manutenção"!', 1, 0 )

				EndIf

			EndIf

		endIf

		// verifico se a regra de negociacao esta ativa
		if xRet .And. lAtivaNegociacao .And. !Empty(oModelU00:GetValue('U00_REGNEG'))

			// verifico se a quantidade de parcelas esta dentro da regra
			if oModelU00:GetValue('U00_QTDPAR') < oModelU00:GetValue('U00_PARINI') .And. oModelU00:GetValue('U00_QTDPAR') > oModelU00:GetValue('U00_PARFIM')
				xRet := .F.
				Help( ,, 'Help - MODELPOS',, 'Quando houver regra de negociação a quantidade de parcelas deve estar entre a quantidade de parcelas minima e maxima!', 1, 0 )
			elseIf !Empty(oModelU00:GetValue('U00_FORPG'))

				// inicio a classe de regra de negociacao
				oRegraNegociacao := RegraNegociacao():New(oModelU00:GetValue('U00_REGNEG'), oModelU00:GetValue('U00_FORPG'))

				// verirfico se tem regra de negociacao
				if !oRegraNegociacao:lTemRegra
					xRet := .F.
					Help( ,, 'Help - MODELPOS',, 'Quando houver regra de negociação a forma de pagamento do contrato deve-se utilizar uma forma de pagamento configurada na regra de negociação!', 1, 0 )
				endIf

			endIf

		endIf

		// se a recorrencia estiver habilitada
		if lRecorrencia .And. (oObj:GetOperation() == 4 .Or. oObj:GetOperation() == 3)

			U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
			if lContinua .And. oModelU00:GetValue('U00_STATUS')  $ "A/S" .And. !Empty(oModelU00:GetValue('U00_FPTAXA')) .And.;
					U60->(MsSeek(xFilial("U60") + oModelU00:GetValue('U00_FPTAXA'))) .And. U60->U60_STATUS == "A"

				//verifico se nao possui contrato na recorrencia para o cliente
				if U_NaoExistCliRecor( oModelU00:GetValue('U00_CLIENT'), oModelU00:GetValue('U00_LOJA') , oModelU00:GetValue('U00_LOJA')  )

					// tela para preenchimento do perfil de pagamento
					FWMsgRun(,{|oSay| xRet := U_UIncPerfil()},'Aguarde...','Abrindo Perfil de Pagamento...')
				else
					lContinua	:= .F.
					xRet 		:= .F.
				endif

			endIf

		endIf

	ElseIf cIdPonto == 'MODELPOS' .And. oObj:GetOperation() == 5 //Confirmação da exclusão

		If U00->U00_STATUS <> "P" //Pré-cadastro
			xRet := .F.
			Help( ,, 'Help - MODELPOS',, 'Somente é permitido a exclusão de Contrato no status de Pré-cadastro.', 1, 0 )
		Endif

	ElseIf cIdPonto == 'BUTTONBAR' .And. (oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4)
		xRet := {{"Parcelamento financeiro","PARCFIN",{|| MsgRun("Calculando...","Aguarde",{|| U_RCPGE068()})}, "Parcelamento financeiro"}}

	elseIf cIdPonto == 'MODELCOMMITNTTS' .And. (oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4) //Confirmação da inclusão ou alteração com regra de negociacao ativada

		// vou validar se existe bloqueio de desconto
		if lAtivaNegociacao .And. U00->U00_STATUS == "P" .And. !Empty(U00->U00_REGNEG) .And. U00->U00_DESCON > U00->U00_DSCVEN

			// gravo os dados do bloqueio
			if U00->(Reclock("U00",.F.))
				U00->U00_DSCBLQ := "1"
				U00->U00_DTBLOQ	:= dDataBase
				U00->U00_USRLIB := ""
				U00->U00_DTLIBE := Stod("")
				U00->(MSUnlock())
			endIf

			// mensagem para o usuario
			Help( ,, 'Help - FORMCOMMITTTSPOS',, 'O desconto informado no contrato é maior que o permitido para o vendedor, o contrato será bloqueado e só poderá ser desbloqueado por um superior!', 1, 0 )

		endIf

		if oObj:GetOperation() == 4//Confirmação alteração com regra de negociacao ativada

			//verifico se a cobranca adicional por autorizado esta habilitado
			if lAtivaCobAdicional

				FWMsgRun(,{|oSay| xRet := U_RCPGE071()},'Aguarde...','Verificando cobranca adicional autorizado...')

			endif

		endIf

	Endif

Return(xRet)

/*/{Protheus.doc} RetManutencaoAtiva
Query para retornar dados da 
taxa de manutencao ativa

@type function
@version 1.0 
@author g.sampaio
@since 23/10/2020
@param cCodContrato, character, Codigo do contrato
@return array, forma de pagamento e codigo da regra utilizada na manutencao
/*/
Static Function RetManutencaoAtiva( cCodContrato )

	Local cQuery 			:= ""
	Local cFormaPg			:= ""
	Local cRegra			:= ""

	Default cCodContrato	:= ""
	Default cRegra			:= ""

	// verifico se o alias esta em uso
	if Select("TRBU26") > 0
		TRBU26->(DbCloseArea())
	endIf

	// query de consulta
	cQuery := " SELECT U26.U26_REGRA, U26.U26_CONTRA, U26.U26_FORPG, U26.U26_STATUS "
	cQuery += " FROM " + RetSqlName("U26") + " U26 "
	cQuery += " WHERE U26.D_E_L_E_T_ = ' ' "
	cQuery += " AND U26.U26_STATUS <> '3' " // diferente de finalizado
	cQuery += " AND U26.U26_CONTRA = '" + cCodContrato + "'"

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, "TRBU26")

	// verifico se existem dados
	if TRBU26->(!Eof())
		cFormaPg 	:= TRBU26->U26_FORPG
		cRegra		:= TRBU26->U26_REGRA
	endIf

	// verifico se o alias esta em uso
	if Select("TRBU26") > 0
		TRBU26->(DbCloseArea())
	endIf

Return({cFormaPg,cRegra})
