#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
{Protheus.doc} RCPGA028
Rotina Automatica de 
Inclusao/Alteracao/Exclusão
de Contratos

@author Raphael Martins
@since 12/07/2016
@version 1.0
@Param
*/
User Function RCPGE004(aCabec, aAutorizados, aMensagens, nOpcao, aProdutos, aServicos, cLog, lLogError)

	Local oModel		:= NIL
	Local oModelMaster	:= NIL
	Local oStructMaster := NIL
	Local aStructMaster	:= NIL

	//***************
	// Autorizados
	//***************
	Local oModelU02 	:= NIL
	Local oStructU02	:= NIL
	Local aStructU02	:= NIL

	//***************
	// Mensagens
	//***************
	Local oModelU03 	:= NIL
	Local oStructU03	:= NIL
	Local aStructU03	:= NIL

	//***************
	// Produtos
	//***************
	Local oModelU01		:= NIL
	Local oStructU01	:= NIL
	Local aStructU01	:= NIL

	//***************
	// Servicos
	//***************
	Local oModelU37		:= NIL
	Local oStructU37	:= NIL
	Local aStructU37	:= NIL

	Local nI 			:= 0
	Local lRet  		:= .T.
	Local nStart		:= 0

	Default aCabec       := {}
	Default aAutorizados := {}
	Default aMensagens   := {}
	Default aProdutos	 := {}
	Default aServicos	 := {}
	Default cLog		 := ""
	Default lLogError    := .T.

	Default nOpcao       := 3 //Inclusao de Contratos

	// Aqui ocorre o inst?ciamento do modelo de dados (Model)
	oModel := FWLoadModel( 'RCPGA001' ) // MVC do Cadastro de Contratos

	// Temos que definir qual a operação deseja: 3-Inclusão / 4-Alteração / 5-Exclusão
	oModel:SetOperation(nOpcao)

	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	oModel:Activate()

	// objetos da enchoice
	oModelMaster 	:= oModel:GetModel('U00MASTER') // Instanciamos apenas referentes aos dados
	oStructMaster 	:= oModelMaster:GetStruct() // Obtemos a estrutura de dados da enchoice
	aStructMaster	:= oStructMaster:GetFields() // Obtemos os campos

	// objetos do grid da tabela U02 - Autorizados
	oModelU02		:= oModel:GetModel('U02DETAIL') // Intanciamos apenas a parte do modelo referente ao grid
	oStructU02		:= oModelU02:GetStruct() // Obtemos a estrutura de dados do grid
	aStructU02		:= oStructU02:GetFields() // Obtemos os campos

	// objetos do grid da tabela U03 - Mensagens
	oModelU03		:= oModel:GetModel('U03DETAIL') // Intanciamos apenas a parte do modelo referente ao grid
	oStructU03   	:= oModelU03:GetStruct() // Obtemos a estrutura de dados do grid
	aStructU03	    := oStructU03:GetFields() // Obtemos os campos

	// objetos do grid da tabela U01 - Produtos
	oModelU01		:= oModel:GetModel('U01DETAIL') // Intanciamos apenas a parte do modelo referente ao grid
	oStructU01   	:= oModelU01:GetStruct() // Obtemos a estrutura de dados do grid
	aStructU01	    := oStructU01:GetFields() // Obtemos os campos

	// objetos do grid da tabela U37 - Servicos
	oModelU37		:= oModel:GetModel('U37DETAIL') // Intanciamos apenas a parte do modelo referente ao grid
	oStructU37   	:= oModelU37:GetStruct() // Obtemos a estrutura de dados do grid
	aStructU37	    := oStructU37:GetFields() // Obtemos os campos

	if nOpcao <> 5 // diferente de exclusao

		// percorro os campos do cabeçalho
		For nI := 1 To Len(aCabec)
			// Verifica se os campos passados existem na estrutura do modelo
			If ( aScan(aStructMaster,{|x| AllTrim( x[3] )== AllTrim(aCabec[nI][1]) } ) ) > 0
				// ?feita a atribui?o do dado ao campo do Model
				If !( oModel:SetValue( 'U00MASTER', aCabec[nI][1], aCabec[nI][2] ) )
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nI

		// se os campos do cabeçalho foram setados com sucesso
		If lRet

			If lRet .And. Len(aAutorizados) > 0
				lRet := AddGrids(@oModel,@oModelU02,aStructU02,aAutorizados,"U02DETAIL",'U02_ITEM')
			EndIf

			If lRet .And. Len(aMensagens) > 0
				lRet := AddGrids(@oModel,@oModelU03,aStructU03,aMensagens,"U03DETAIL",'U03_ITEM')
			EndIf

			If lRet .And. Len(aProdutos) > 0
				lRet := AddGrids(@oModel,@oModelU01,aStructU01,aProdutos,"U01DETAIL",'U01_ITEM')
			EndIf

			If lRet .And. Len(aServicos) > 0
				lRet := AddGrids(@oModel,@oModelU37,aStructU37,aServicos,"U37DETAIL",'U37_ITEM')
			EndIf

		EndIf

	endIf

	// Faz-se a validacao dos dados
	If lRet .And. ( lRet := oModel:VldData() )
		// Se o dados foram validados faz-se a grava?o efetiva dos dados (commit)
		oModel:CommitData()
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

		If !IsBlind()
			If IsInCallStack("U_RIMPM003") .Or. !lLogError//-- Processamento de Importacoes
				cLog := MostraErro("\system\")
			Else
				cLog := MostraErro()
			EndIf
		Else

			FwLogMsg("ERROR", , "REST", FunName(), "", "01","Erro na inclusão do cliente.", 0, (nStart - Seconds()), {})

		Endif
	EndIf

	// Desativamos o Model
	oModel:DeActivate()

	//elimino os objetos da memoria
	FreeObj(oModel)
	FreeObj(oModelMaster)
	FreeObj(oStructMaster)
	FreeObj(oModelU03)
	FreeObj(oStructU03)
	FreeObj(oModelU02)
	FreeObj(oStructU02)

Return(lRet)

/*************************************************************************************/
Static Function AddGrids(oModel,oModelGrid,aStructDetail,aArray,cModelDt,cUniqueCpo)
/*************************************************************************************/

	Local nI         := 0
	Local nJ	     := 0
	Local nItErro    := 0
	Local nLinhaItem := 0
	Local nPosItem	 := 0
	Local lRetorno   := .T.

	For nI := 1 To Len(aArray)

		// Incluímos uma linha nova
		// ATENCAO: O itens são criados em uma estrura de grid (FORMGRID), portanto já é criada uma primeira linha
		//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
		nPosItem   := aScan( aArray[nI], { |x| AllTrim( x[1] ) ==  AllTrim( cUniqueCpo ) } )

		//pesquiso se item ja existe na grid, caso sim, apenas atualizo a mesma.
		If nPosItem > 0
			nLinhaItem := FindItem(oModelGrid,cUniqueCpo,aArray[nI][nPosItem][2])
		EndIf

		If nLinhaItem == 0

			If nI >= 1
				// Incluimos uma nova linha de item
				If  ( nItErro := oModelGrid:AddLine() ) = 0
					// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
					// ele retorna a quantidade de linhas já
					// existem no grid. Se conseguir retorna a quantidade mais 1
					lRetorno := .F.
					Exit
				EndIf
			EndIf
		Else
			oModelGrid:GoLine( nLinhaItem )
		EndIf

		For nJ := 1 To Len( aArray[nI] )
			// Verifica se os campos passados existem na estrutura de item
			If ( aScan( aStructDetail, { |x| AllTrim( x[3] ) ==  AllTrim( aArray[nI][nJ][1] ) } ) ) > 0
				If !( oModel:SetValue(cModelDt, aArray[nI][nJ][1], aArray[nI][nJ][2] ) )
					// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
					// o método SetValue retorna .F.
					lRetorno    := .F.
					nItErro     := nI
					Exit

				EndIf
			EndIf
		Next

		If !lRetorno
			Exit
		EndIf
	Next nI

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

		oModelGrid:GoLine( nI )

		If Alltrim(oModelGrid:GetValue(cCampo)) == Alltrim(cItem)
			nRetLinha  := nI
			Exit
		EndIf

	Next nI

Return(nRetLinha)
