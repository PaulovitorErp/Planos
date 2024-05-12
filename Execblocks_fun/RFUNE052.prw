#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} RFUNE052
Rotina Automatica de
Inclusao/Alteracao/Exclusão
de Apontamento de Serviços Funerarios
@type function
@version 1.0 
@author g.sampaio
@since 10/11/2023
@param aCabec, array, Dados do Cabecalho de Apontamento
@param aEntregues, array, Produtos e Servicos Entregues
@return logical, inclusao realizada com sucesso.
/*/
User Function RFUNE052(aCabec, aEntregues, nOpcao, cLogError)

	Local oModel
	Local oModelMaster
	Local oStructMaster
	Local aStructMaster
	Local nPosBen	:= 0

	//**************************************
	// Produtos e Servicos Entregues
	//**************************************
	Local oModelUJ2    := NIL
	Local oStructUJ2   := NIL
	Local aStructUJ2   := NIL

	Local nI 		    := 0
	Local lRet  	    := .T.
	Local nStart    	:= 0

	Default aCabec       	 := {}
	Default aEntregues		 := {}
	Default nOpcao       	 := 3 //Inclusao de Apontamentos
	Default cLogError		 := ""

	// Aqui ocorre o inst?ciamento do modelo de dados (Model)
	oModel := FWLoadModel( 'RFUNA034' ) // MVC do Cadastro de Apontamento de servicos

	// Temos que definir qual a operação deseja: 3-Inclusão / 4-Alteração / 5-Exclusão
	oModel:SetOperation(nOpcao)

	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	oModel:Activate()

	// objetos da enchoice
	oModelMaster 	:= oModel:GetModel('UJ0MASTER') // Instanciamos apenas referentes aos dados
	oStructMaster 	:= oModelMaster:GetStruct() // Obtemos a estrutura de dados da enchoice
	aStructMaster	:= oStructMaster:GetFields() // Obtemos os campos

	// objetos do grid da tabela UJ2 - Produtos e Servicos Internos
	oModelUJ2		:= oModel:GetModel('UJ2DETAIL') // Intanciamos apenas a parte do modelo referente ao grid
	oStructUJ2		:= oModelUJ2:GetStruct() // Obtemos a estrutura de dados do grid
	aStructUJ2		:= oStructUJ2:GetFields() // Obtemos os campos

	Conout("Execauto - Cabec: " + U_toString(aCabec))

	// percorro os campos do cabeçalho
	For nI := 1 To Len(aCabec)

		// Verifica se os campos passados existem na estrutura do modelo
		If ( aScan(aStructMaster,{|x| AllTrim( x[3] )== AllTrim(aCabec[nI][1]) } ) ) > 0
			// ?feita a atribui?o do dado ao campo do Model
			If !( oModel:SetValue( 'UJ0MASTER', aCabec[nI][1], (aCabec[nI][2] )) )
				Conout(">> Erro Execauto - Cabecalho: " + AllTrim(aCabec[nI][1]))
				cLogError := "[UJ0 - Cabecalho] Erro ao atribuir valor ao campo " + AllTrim(aCabec[nI][1])
				lRet := .F.
				Exit
			EndIf
		EndIf

	Next nI

	// se os campos do cabeçalho foram setados com sucesso
	If lRet

		Conout("Execauto - Itens Entregues: " + U_toString(aEntregues))

		If lRet .And. Len(aEntregues) > 0
			lRet := AddUJ2(@oModel,@oModelUJ2,aStructUJ2,aEntregues,"UJ2_ITEM", @cLogError)
		EndIf

		If lRet
			nPosBen := aScan(aCabec,{|x| AllTrim(x[1])== "UJ0_CODBEN" } )
			If nPosBen > 0
				If !Empty(aCabec[nPosBen][2])
					U_ValidaBeneficiario( Nil, aCabec[nPosBen][2],,.F. )
				EndIf
			EndIf
		EndIF

		// Faz-se a valida?o dos dados
		If lRet .And. ( lRet := oModel:VldData() )
			// Se o dados foram validados faz-se a grava?o efetiva dos dados (commit)
			oModel:CommitData()
		EndIf
	EndIf

	If !lRet
		// Se os dados n? foram validados obtemos a descri?o do erro para gerar LOG ou mensagem de aviso
		aErro := oModel:GetErrorMessage()

		AutoGrLog( "Id do formulário de origem:" 	+ ' [' + AllToChar( aErro[1] ) + ']' )
		AutoGrLog( "Id do campo de origem: " 		+ ' [' + AllToChar( aErro[2] ) + ']' )
		AutoGrLog( "Id do formulário de erro: " 	+ ' [' + AllToChar( aErro[3] ) + ']' )
		AutoGrLog( "Id do campo de erro: " 			+ ' [' + AllToChar( aErro[4] ) + ']' )
		AutoGrLog( "Id do erro: " 					+ ' [' + AllToChar( aErro[5] ) + ']' )
		AutoGrLog( "Mensagem do erro: " 			+ ' [' + AllToChar( aErro[6] ) + ']' )
		AutoGrLog( "Mensagem da solução: " 			+ ' [' + AllToChar( aErro[7] ) + ']' )
		AutoGrLog( "Valor atribuído: " 				+ ' [' + AllToChar( aErro[8] ) + ']' )
		AutoGrLog( "Valor anterior: " 				+ ' [' + AllToChar( aErro[9] ) + ']' )

		cLogError += AllToChar(aErro[3]) + ' => ' + AllToChar(aErro[6])

		If !IsBlind()
			cLogError += MostraErro("\temp")
		Else
			FwLogMsg("ERROR", , "REST", FunName(), "", "01", cLogError, 0, (nStart - Seconds()), {}) // nStart é declarada no inicio da função
		Endif

		Conout("==> Erro Execauto (RFUNE052): " + cLogError)

	EndIf

	// Desativamos o Model
	oModel:DeActivate()

	//elimino os objetos da memoria
	FreeObj(oModelMaster)
	FreeObj(oStructMaster)
	FreeObj(oModelUJ2)
	FreeObj(oStructUJ2)
	FreeObj(oModel)

Return(lRet)

/*/{Protheus.doc} AddUJ2
Funcao para adicionar ou editar linhas
da grid de produtos e servicos entregues
@type function
@version 1.0 
@author raphaelgarcia
@since 10/11/2023
@param oModel, object, Objeto Modelo da tela
@param oModelUJ2, object, Modelo da grid de produtos e servicos entregues
@param aStructUJ2, array, Array da estrutura da UJ2
@param aEntregues, array, Array com os produtos e servicos entregues
@return logical, Incluir com sucesso a crig de produtos e servicos entregues
/*/
Static Function AddUJ2(oModel,oModelUJ2,aStructUJ2,aEntregues,cUniqueCpo,cLogError)

	Local aArea 		:= GetArea()
	Local nI       		:= 0
	Local nJ	   		:= 0
	Local nItErro  		:= 0
	Local nLinhaItem	:= 0
	Local nPosItem		:= 0
	Local lRetorno 		:= .T.

	UJ2->( DbSetOrder(1) ) //UJ2_FILIAL + UJ2_CODIGO + UJ2_ITEM

	For nI := 1 To Len(aEntregues)

		// zero o valor das variaveis
		nLinhaItem 	:= 0
		nPosItem	:= 0

		// Incluímos uma linha nova
		// ATENCAO: O itens são criados em uma estrura de grid (FORMGRID), portanto já é criada uma primeira linha
		//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
		nPosItem   := aScan( aEntregues[nI], { |x| AllTrim( x[1] ) ==  AllTrim( cUniqueCpo ) } )

		//pesquiso se item ja existe na grid, caso sim, apenas atualizo a mesma.
		If nPosItem > 0
			nLinhaItem := FindItem(oModelUJ2,cUniqueCpo,aEntregues[nI][nPosItem][2])
		EndIf

		If nLinhaItem == 0

			If  ( nItErro := oModelUJ2:AddLine() ) = 0

				// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
				// ele retorna a quantidade de linhas já
				// existem no grid. Se conseguir retorna a quantidade mais 1
				lRetorno    := .F.
				Exit
			EndIf
		Else
			oModelUJ2:GoLine( nLinhaItem )
		EndIf

		if lRetorno

			For nJ := 1 To Len( aEntregues[nI] )

				// Verifica se os campos passados existem na estrutura de item
				If ( aScan( aStructUJ2, { |x| AllTrim( x[3] ) ==  AllTrim( aEntregues[nI][nJ][1] ) } ) ) > 0

					If !( oModel:SetValue('UJ2DETAIL', aEntregues[nI][nJ][1], aEntregues[nI][nJ][2] ) )
						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						Conout(">> Erro Execauto - Itens: " + AllTrim(aEntregues[nI][nJ][1]))
						cLogError := "[UJ2 - Itens] Erro ao atribuir valor ao campo " + AllTrim(aEntregues[nI][nJ][1])	
						lRetorno    := .F.
						nItErro     := nI
						Exit

					EndIf
				EndIf

			Next nJ

		endIf

		If !lRetorno
			Exit
		EndIf

	Next nI

	RestArea(aArea)

Return(lRetorno)

/*
{Protheus.doc} FindItem
Funcao para validar se a linha a ser adicionada
ja existe na GRID.
@author Raphael Martins
@since 12/07/2016
@version 1.0
@Param
*/
Static Function FindItem(oModelGrid,cCampo,cItem)

	Local nRetLinha := 0
	Local nI        := 0

	For nI := 1 To oModelGrid:Length()

		oModelGrid:GoLine(nI)

		If Alltrim(oModelGrid:GetValue(cCampo)) == Alltrim(cItem)
			nRetLinha  := nI
			Exit
		EndIf

	Next nI

Return(nRetLinha)
