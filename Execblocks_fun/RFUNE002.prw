#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
{Protheus.doc} RFUNE002
Rotina Automatica de
Inclusao/Alteracao/Exclusão
de Contratos Funerarios

@author Raphael Martins
@since 12/07/2016
@version 1.0
@Param
*/
User Function RFUNE002(aCabec,aBeneficiarios,aMensagens,nOpcao,aProdutos,cLogError)

	Local oModel
	Local oModelMaster
	Local oStructMaster
	Local aStructMaster
	//***************
	// Beneficiarios
	//***************
	Local oModelUF4
	Local oStructUF4
	Local aStructUF4
	//***************
	// Mensagens
	//***************
	Local oModelUF9
	Local oStructUF9
	Local aStructUF9

	//***************
	// Itens do Plano
	//***************
	Local oModelUF3
	Local oStructUF3
	Local aStructUF3

	Local aErro		:= {}
	Local cRet		:= ""
	Local nI 		:= 0
	Local nJ		:= 0
	Local lRet  	:= .T.
	Local nItErro	:= 0
	Local aAux		:= {}
	Local nStart	:= 0

	Default aCabec       	 := {}
	Default aBeneficiarios   := {}
	Default aMensagens       := {}
	Default aProdutos		 := {}
	Default nOpcao       	 := 3 //Inclusao de Contratos

	// Aqui ocorre o inst?ciamento do modelo de dados (Model)
	oModel := FWLoadModel( 'RFUNA002' ) // MVC do Cadastro de Contratos de Funerario

	// Temos que definir qual a operação deseja: 3-Inclusão / 4-Alteração / 5-Exclusão
	oModel:SetOperation(nOpcao)

	// Antes de atribuirmos os valores dos campos temos que ativar o modelo
	oModel:Activate()

	// objetos da enchoice
	oModelMaster 	:= oModel:GetModel('UF2MASTER') // Instanciamos apenas referentes aos dados
	oStructMaster 	:= oModelMaster:GetStruct() // Obtemos a estrutura de dados da enchoice
	aStructMaster	:= oStructMaster:GetFields() // Obtemos os campos

	// objetos do grid da tabela UF4 - Beneficiarios
	oModelUF4		:= oModel:GetModel('UF4DETAIL') // Intanciamos apenas a parte do modelo referente ao grid
	oStructUF4		:= oModelUF4:GetStruct() // Obtemos a estrutura de dados do grid
	aStructUF4		:= oStructUF4:GetFields() // Obtemos os campos

	// objetos do grid da tabela UF9 - Mensagens
	oModelUF9		:= oModel:GetModel('UF9DETAIL') // Intanciamos apenas a parte do modelo referente ao grid
	oStructUF9		:= oModelUF9:GetStruct() // Obtemos a estrutura de dados do grid
	aStructUF9		:= oStructUF9:GetFields() // Obtemos os campos

	// objetos do grid da tabela UF3 - Itens do Plano
	oModelUF3		:= oModel:GetModel('UF3DETAIL') // Intanciamos apenas a parte do modelo referente ao grid
	oStructUF3		:= oModelUF3:GetStruct() // Obtemos a estrutura de dados do grid
	aStructUF3		:= oStructUF3:GetFields() // Obtemos os campos

	// percorro os campos do cabeçalho
	For nI := 1 To Len(aCabec)
		// Verifica se os campos passados existem na estrutura do modelo
		If ( aScan(aStructMaster,{|x| AllTrim( x[3] )== AllTrim(aCabec[nI][1]) } ) ) > 0
			// ?feita a atribui?o do dado ao campo do Model
			If !( oModel:SetValue( 'UF2MASTER', aCabec[nI][1], (aCabec[nI][2] )) )
				lRet := .F.
				Exit
			EndIf
		EndIf
	Next nI

	// se os campos do cabeçalho foram setados com sucesso
	If lRet

		If lRet .And. Len(aBeneficiarios) > 0
			lRet := AddUF4(@oModel,@oModelUF4,aStructUF4,aBeneficiarios)
		EndIf

		If lRet .And. Len(aMensagens) > 0
			lRet := AddUF9(@oModel,@oModelUF9,aStructUF9,aMensagens)
		EndIf

		If lRet .And. Len(aProdutos) > 0
			lRet := AddUF3(@oModel,@oModelUF3,aStructUF3,aProdutos,"UF3DETAIL",'UF3_ITEM')
		EndIf

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

		cLogError := AllToChar(aErro[3]) + ' => ' + AllToChar(aErro[6])

		If !IsBlind() .And. !IsInCallStack("U_RIMPM003")
			MostraErro()
		Else
			FwLogMsg("ERROR", , "REST", FunName(), "", "01", cLogError, 0, (nStart - Seconds()), {}) // nStart é declarada no inicio da função
		Endif

	EndIf

	// Desativamos o Model
	oModel:DeActivate()

	//elimino os objetos da memoria
	FreeObj(oModelUF4)
	FreeObj(oStructUF4)
	FreeObj(oModelUF9)
	FreeObj(oStructUF9)
	FreeObj(oModelMaster)
	FreeObj(oStructMaster)
	FreeObj(oModel)

Return(lRet)

/*
{Protheus.doc} RFUNE002
Funcao para adicionar ou editar linhas
da grid de beneficiarios/agregados
@author Raphael Martins
@since 12/07/2016
@version 1.0
@Param
*/

Static Function AddUF4(oModel,oModelGrid,aStructDetail,aArray)

	Local nI       := 0
	Local nJ	   := 0
	Local nItErro  := 0
	Local lRetorno := .T.

	UF4->( DbSetOrder(1) ) //UF4_FILIAL + UF4_CODIGO + UF4_ITEM

	For nI := 1 To Len(aArray)

		If  ( nItErro := oModelGrid:AddLine() ) = 0

			// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
			// ele retorna a quantidade de linhas já
			// existem no grid. Se conseguir retorna a quantidade mais 1
			lRetorno    := .F.
			Exit
		EndIf

		if lRetorno

			For nJ := 1 To Len( aArray[nI] )
				// Verifica se os campos passados existem na estrutura de item
				If ( aScan( aStructDetail, { |x| AllTrim( x[3] ) ==  AllTrim( aArray[nI][nJ][1] ) } ) ) > 0

					If !( oModel:SetValue('UF4DETAIL', aArray[nI][nJ][1], aArray[nI][nJ][2] ) )
						// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
						// o método SetValue retorna .F.
						lRetorno    := .F.
						nItErro     := nI
						Exit

					EndIf
				EndIf
			Next

		endIf

		If !lRetorno
			Exit
		EndIf

	Next nI

Return(lRetorno)

/*
{Protheus.doc} RFUNE002
Funcao para adicionar ou editar linhas
da grid de Mensagens
@author Raphael Martins
@since 12/07/2016
@version 1.0
@Param
*/
Static Function AddUF9(oModel,oModelGrid,aStructDetail,aArray)

	Local nI          := 0
	Local nJ	      := 0
	Local lRetorno    := .T.
	Local nItErro     := 0

	UF9->( DbSetOrder(1) ) //UF9_FILIAL + UF9_CODIGO + UF9_ITEM

	For nI := 1 To Len(aArray)

		// Incluimos uma nova linha de item
		If  ( nItErro := oModelGrid:AddLine() ) = 0
			// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
			// ele retorna a quantidade de linhas já
			// existem no grid. Se conseguir retorna a quantidade mais 1
			lRetorno    := .F.
			Exit
		EndIf

		For nJ := 1 To Len( aArray[nI] )
			// Verifica se os campos passados existem na estrutura de item
			If ( aScan( aStructDetail, { |x| AllTrim( x[3] ) ==  AllTrim( aArray[nI][nJ][1] ) } ) ) > 0
				If !( oModel:SetValue('UF9DETAIL', aArray[nI][nJ][1], aArray[nI][nJ][2] ) )
					// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
					// o método SetValue retorna .F.
					lRetorno    := .F.
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
{Protheus.doc} RFUNE002
Funcao para adicionar ou editar linhas
da grid de Produtos
@author Raphael Martins
@since 12/07/2016
@version 1.0
@Param
*/
Static Function AddUF3(oModel,oModelGrid,aStructDetail,aArray,cModelDt,cUniqueCpo)

	Local nI         := 0
	Local nJ	     := 0
	Local nItErro    := 0
	Local nLinhaItem := 0
	Local nPosItem	 := 0
	Local lRetorno   := .T.
	Local lRecalcImp := SuperGetMV("MV_XFRCIMP", .F., .T.)

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

			If nI > 1
				// Incluimos uma nova linha de item
				If  ( nItErro := oModelGrid:AddLine() ) = 0
					// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
					// ele retorna a quantidade de linhas já
					// existem no grid. Se conseguir retorna a quantidade mais 1
					lRetorno    := .F.
					Exit
				EndIf
			EndIf
		Else
			oModelGrid:GoLine( nLinhaItem )
		EndIf

		For nJ := 1 To Len( aArray[nI] )
			// Verifica se os campos passados existem na estrutura de item
			If ( aScan( aStructDetail, { |x| AllTrim( x[3] ) ==  AllTrim( aArray[nI][nJ][1] ) } ) ) > 0
				If !( oModel:SetValue('UF3DETAIL', aArray[nI][nJ][1], aArray[nI][nJ][2] ) )
					// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
					// o método SetValue retorna .F.
					lRetorno    := .F.
					nItErro     := nI
					Exit

				EndIf
			EndIf
		Next nJ

		If !lRetorno
			Exit
		EndIf
	Next nI

	//Chamo funcao para atualizar totalzadores
	if IsInCallStack("U_RIMPM003")
		if lRecalcImp
			U_UVlrLiqFun()
		endIf
	else
		U_UVlrLiqFun()
	endIf

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
