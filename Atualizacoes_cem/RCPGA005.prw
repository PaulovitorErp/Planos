#Include 'totvs.ch'

/*/{Protheus.doc} RCPGA005
Rotina para geração de jazigos em lote.	
@type function
@version 1.0  
@author Wellington Gonçalves
@since 24/02/2016
/*/
User Function RCPGA005()

	Local aArea				:= GetArea()
	Local aAreaU08			:= U08->(GetArea())
	Local aAreaU09			:= U09->(GetArea())
	Local aAreaU10			:= U10->(GetArea())
	Local cPerg 			:= "RCPGA005"
	Local cQuadra			:= ""
	Local cModulo			:= ""
	Local cJazigoDe			:= ""
	Local cJazigoAte		:= ""
	Local cAtivo			:= ""
	Local nGeraOssuario		:= ""
	Local lContinua			:= .T.
	Local lJazigoOssuario 	:= SuperGetMV("MV_XJAZOSS",.F.,.F.)
	Local nQtdNichos		:= 0

	// cria as perguntas na SX1
	AjustaSx1(cPerg)

	// enquanto o usuário não cancelar a tela de perguntas
	While lContinua

		// chama a tela de perguntas
		lContinua := Pergunte(cPerg,.T.)

		if lContinua

			cQuadra 	:= MV_PAR01
			cModulo		:= MV_PAR02
			cJazigoDe	:= MV_PAR03
			cJazigoAte	:= MV_PAR04
			cAtivo		:= iif(MV_PAR05 == 1,"S","N")

			if lJazigoOssuario
				nGeraOssuario 	:= MV_PAR06
				nQtdNichos		:= MV_PAR07
			endIf

			if ValidParam(cQuadra, cModulo, cJazigoDe, cJazigoAte, cAtivo, nGeraOssuario, nQtdNichos)

				if MsgYesNo("Deseja gerar os jazigos para a quadra " + AllTrim(cQuadra) + " módulo " + AllTrim(cModulo) + "?")
					MsAguarde( {|| GeraJazigos(cQuadra, cModulo, cJazigoDe, cJazigoAte, cAtivo, nGeraOssuario, nQtdNichos)}, "Aguarde", "Processando registros...", .F. )
				endif

			endif

		endif

	EndDo

	RestArea(aAreaU08)
	RestArea(aAreaU09)
	RestArea(aAreaU10)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} ValidParam
Função que valida os parâmetros informados.
@type function
@version 1.0 
@author g.sampaio
@since 14/04/2021
@param cQuadra, character, codigo da quadra
@param cModulo, character, codigo do modulo
@param cJazigoDe, character, inicio da faixa do jazigo
@param cJazigoAte, character, fim da faixa do jazigo
@param cAtivo, character, jazigo ativo
@param nGeraOssuario, character, gera ossuario vinculado
@param nQtdNichos, numeric, quantidade de nichos
@return logical, retorno sobre a validacao
/*/
Static Function ValidParam(cQuadra, cModulo, cJazigoDe, cJazigoAte, cAtivo, nGeraOssuario, nQtdNichos)

	Local aArea				:= GetArea()
	Local aAreaU08			:= U08->(GetArea())
	Local aAreaU09			:= U09->(GetArea())
	Local lRet 				:= .F.	

	// verifico se foram preenchidos todos os parâmetros
	if Empty(cQuadra)
		Alert("Informe a Quadra!")
	elseif Empty(cModulo)
		Alert("Informe o Módulo!")
	elseif Empty(cJazigoDe) .OR. Empty(cJazigoAte)
		Alert("Informe o Jazigo inicial e final!")
	elseif Empty(cAtivo)
		Alert("Informe o status do Jazigo!")
	elseif cJazigoDe > cJazigoAte
		Alert("O Jazigo final deve ser maior ou igual ao Jazigo inicial!")
	else

		// verifico se a quadra informada é válida
		U08->(DbSetOrder(1)) // U08_FILIAL + U08_CODIGO
		if U08->(DbSeek(xFilial("U08") + cQuadra))

			// verifico se a quadra / módulo informado é válido
			U09->(DbSetOrder(1)) // U09_FILIAL + U09_QUADRA + U09_CODIGO
			if U09->(DbSeek(xFilial("U09") + cQuadra + cModulo))
				lRet := .T.
			else
				Alert("O módulo informado é inválido!")
			endif

		else
			Alert("A Quadra informada é inválida!")
		endif

	endif

	RestArea(aAreaU08)
	RestArea(aAreaU09)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} GeraJazigos
Função que faz a gravação dos jazigos.
@type function
@versio 1.0  
@author Wellington Gonçalves
@since 24/02/2016
@param cQuadra, character, codigo da quadara
@param cModulo, character, codigo do modulo
@param cJazigoDe, character, inicio da faixa de codigo do jazigo
@param cJazigoAte, character, fim fim da faixa de codigo do jazigo
@param cAtivo, character, jazigo ativo
/*/
Static Function GeraJazigos(cQuadra, cModulo, cJazigoDe, cJazigoAte, cAtivo, nGeraOssuario, nQtdNichos)

	Local aArea					:= GetArea()
	Local aAreaU10				:= U10->(GetArea())
	Local cCodigo				:= ""
	Local cDscQD				:= SuperGetMV("MV_XDSCQD",.F.,"QD")
	Local cDscMOD				:= SuperGetMV("MV_XDSCMOD",.F.,"MD")
	Local cDscJaz				:= SuperGetMV("MV_XDSCJAZ",.F.,"JZ")
	Local lSucesso				:= .T.
	Local lJazigoOssuario 		:= SuperGetMV("MV_XJAZOSS",.F.,.F.)
	Local nCapacidadeDefault  	:= SuperGetMV("MV_XCPJOSS",.F.,4)
	Local oJazOss				:= Nil

	Default cQuadra				:= ""
	Default cModulo				:= ""
	Default cJazigoDe			:= ""
	Default cJazigoAte			:= ""
	Default cAtivo				:= ""
	Default nGeraOssuario		:= 0
	Default nQtdNichos			:= 0

	cCodigo := AllTrim(cJazigoDe)

	if nQtdNichos == 0
		nQtdNichos := nCapacidadeDefault
	endIf

	// inicío o controle de transação
	BEGIN TRANSACTION

		While cCodigo >= AllTrim(cJazigoDe) .AND. cCodigo <= AllTrim(cJazigoAte)

			// verifico se a quadra / módulo / jazigo já existe, caso exista, não faço a inclusão
			U10->(DbSetOrder(1)) // U10_FILIAL + U10_QUADRA + U10_MODULO + U10_CODIGO
			if !(U10->(MsSeek(xFilial("U10") + cQuadra + cModulo + cCodigo)))

				if RecLock("U10",.T.)

					U10->U10_FILIAL := xFilial("U10")
					U10->U10_QUADRA	:= cQuadra
					U10->U10_MODULO	:= cModulo
					U10->U10_CODIGO	:= cCodigo
					U10->U10_STATUS	:= cAtivo
					U10->U10_DESC	:= cDscQD + " " + cQuadra + " " + cDscMOD + " " + cModulo + " " + cDscJaz + " " + cCodigo
					U10->(MsUnLock())

					if lJazigoOssuario .And. nGeraOssuario == 1

						oJazOss := OssuarioVinculado():New(.T., cQuadra, cModulo, cCodigo)
						
						if Len(oJazOss:aJazigos) > 0 
							oJazOss:IncluiOssuario(cQuadra, cModulo, cCodigo, nQtdNichos)
						endIf

					endIf

				else
					lSucesso := .F.
					Exit
				endif

			endif

			// incremento o código do jazigo
			cCodigo := Soma1(cCodigo)
		EndDo

		// se a transação foi realizada com sucesso
		if lSucesso
			// finalizo o controle de transação
			Aviso("Sucesso!" , "Jazigos gerados com sucesso!" , {"OK"} , 1)
		else
			// faço o rollback da transação
			DisarmTransaction()
			Alert("Ocorreu um problema na geração dos jazigos!")
		endif

	END TRANSACTION

	RestArea(aAreaU10)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} AjustaSX1
Função que cria as perguntas na SX1.	
@type function
@version 1.0  
@author Wellington Gonçalves
@since 24/02/2016
@param cPerg, character, Grupo de Perguntas
/*/
Static Function AjustaSX1(cPerg)

	Local aRegs			  := {}
	Local lJazigoOssuario := SuperGetMV("MV_XJAZOSS",.F.,.F.)

	Default cPerg	:= ""

	// verifico se o nome do grupo de pergunta foi passado
	if !Empty(cPerg)

		// parametros SX1
		aAdd(aRegs,{cPerg,'01','Quadra?'        	,'','','mv_ch1','C', TamSx3("U10_QUADRA")[1]    	, 0, 0,'G','','mv_par01','','','','','','U08'})
		aAdd(aRegs,{cPerg,'02','Módulo?'           	,'','','mv_ch2','C', TamSx3("U10_MODULO")[1]    	, 0, 0,'G','','mv_par02','','','','','','U09'})
		aAdd(aRegs,{cPerg,'03','Jazigo inicial?'  	,'','','mv_ch3','C', TamSx3("U10_CODIGO")[1]    	, 0, 0,'G','','mv_par03','','','','','',''})
		aAdd(aRegs,{cPerg,'04','Jazigo final?'    	,'','','mv_ch4','C', TamSx3("U10_CODIGO")[1]    	, 0, 0,'G','','mv_par04','','','','','',''})
		aAdd(aRegs,{cPerg,'05','Ativo?'         	,'','','mv_ch5','N', 1   							, 0, 0,'N','','mv_par05','Sim','Não','','','',''})

		if lJazigoOssuario
			aAdd(aRegs,{cPerg,'06','Ossuario Vinculado?'	,'','','mv_ch6','N', 1   							, 0, 0,'N','','mv_par06','Sim','Não','','','',''})
			aAdd(aRegs,{cPerg,'07','Capacidade Ossuario?'   ,'','','mv_ch7','N', 2   							, 0, 0,'G','','mv_par07','','','','','',''})
		endIf

		// cria os dados da SX1
		U_CriaSX1( aRegs )

	endIf

Return(Nil)
