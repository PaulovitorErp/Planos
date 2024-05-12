#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'

/*/{Protheus.doc} RUTIL015
Rotina para Cadastro do modelo de Termos em Word
@author Leandro Rodrigues
@since 14/02/2018
@version P12
@param nulo
@return nulo
/*/

User Function RUTIL015()

	Local oBrw

	oBrw := FWmBrowse():New()

	oBrw:SetAlias( 'UJJ' )
	oBrw:SetDescription( 'Leiaute de Termos' )
	oBrw:Activate()

Return

/*/{Protheus.doc} MenuDef
Função que cria os menus	
@author Leandro Rodrigues
@since 14/02/2018
@version P12
@param nulo
@return nulo
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar'	      	ACTION 'VIEWDEF.RUTIL015' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'         		ACTION 'VIEWDEF.RUTIL015' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'         		ACTION 'VIEWDEF.RUTIL015' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'         		ACTION 'VIEWDEF.RUTIL015' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Impressão'         	ACTION 'U_RUTILE28()' OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     			ACTION 'VIEWDEF.RUTIL015' OPERATION 9 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Função que cria o objeto model	
@author Leandro Rodrigues
@since 14/02/2018
@version P12
@param nulo
@return nulo
/*/
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruUJJ  := FWFormStruct( 1, 'UJJ', /*bAvalCampo*/,/*lViewUsado*/ ) // Dados Modelo
	Local oStruUJK  := FWFormStruct( 1, 'UJK', /*bAvalCampo*/,/*lViewUsado*/ ) // Variaveis Word
	Local oStruUJL  := FWFormStruct( 1, 'UJL', /*bAvalCampo*/,/*lViewUsado*/ ) // Indicadores
	Local oStruUJM  := FWFormStruct( 1, 'UJM', /*bAvalCampo*/,/*lViewUsado*/ ) // Variaveis X Indicadores

	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('PUTIL015', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	//Adiciona ao modelo uma estrutura de formul·rio de ediÁ?o por campo
	oModel:AddFields( 'UJJMASTER', /*cOwner*/, oStruUJJ, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	// Adiciona ao modelo uma componente de grid
	oModel:AddGrid( 'UJKDETAIL', 'UJJMASTER', oStruUJK , /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'UJLDETAIL', 'UJJMASTER', oStruUJL , /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'UJMDETAIL', 'UJLDETAIL', oStruUJM , /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'UJKDETAIL', { {'UJK_FILIAL' , 'xFilial( "UJK" )'}, {'UJK_CODIGO','UJJ_CODIGO' }}, UJK->( IndexKey(1)))
	oModel:SetRelation( 'UJLDETAIL', { {'UJL_FILIAL' , 'xFilial( "UJL" )'}, {'UJL_CODIGO','UJJ_CODIGO' }}, UJL->( IndexKey(1)))
	oModel:SetRelation( 'UJMDETAIL', { {'UJM_FILIAL' , 'xFilial( "UJM" )'}, {'UJM_CODIGO','UJJ_CODIGO' }, {'UJM_INDICA','UJL_INDICA' }}, UJM->( IndexKey(1)))

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "UJJ_FILIAL" , "UJJ_CODIGO" })

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'UJKDETAIL' ):SetUniqueLine( { 'UJK_VAR','UJK_CAMPO'} )
	oModel:GetModel( 'UJLDETAIL' ):SetUniqueLine( { 'UJL_INDICA'} )
	oModel:GetModel( 'UJMDETAIL' ):SetUniqueLine( { 'UJM_VAR','UJM_CAMPO'} )

	// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel( 'UJKDETAIL' ):SetDescription( 'Variáveis Word (DOCVARIABLES)' )
	oModel:GetModel( 'UJLDETAIL' ):SetDescription( 'Indicadores' )
	oModel:GetModel( 'UJMDETAIL' ):SetDescription( 'Variáveis X Indicadores' )

	// gris opcionais
	oModel:GetModel('UJLDETAIL'):SetOptional( .T. )
	oModel:GetModel('UJMDETAIL'):SetOptional( .T. )

Return oModel

/*/{Protheus.doc} ViewDef
Função que cria o objeto View
@author Leandro Rodrigues
@since 14/02/2018
@version P12
@param nulo
@return nulo
/*/
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'RUTIL015' )
	Local oView

	// Cria a estrutura a ser usada na View
	Local oStruUJJ  := FWFormStruct( 2, 'UJJ' )
	Local oStruUJK  := FWFormStruct( 2, 'UJK' )
	Local oStruUJL  := FWFormStruct( 2, 'UJL' )
	Local oStruUJM  := FWFormStruct( 2, 'UJM' )

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados ser· utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_UJJ', oStruUJJ, 'UJJMASTER' )

	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid( 'VIEW_UJK', oStruUJK,  'UJKDETAIL' )
	oView:AddGrid( 'VIEW_UJL', oStruUJL,  'UJLDETAIL' )
	oView:AddGrid( 'VIEW_UJM', oStruUJM,  'UJMDETAIL' )

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_TELA'		, 100)

	oView:CreateVerticalBox('PANEL_CAMPOS'		, 045,'PANEL_TELA')
	oView:CreateVerticalBox('PANEL_GRID'		, 055,'PANEL_TELA')

	oView:CreateHorizontalBox('PANEL_VARIAVEIS'		, 034 , 'PANEL_GRID' )
	oView:CreateHorizontalBox('PANEL_INDICADORES'	, 033 , 'PANEL_GRID')
	oView:CreateHorizontalBox('PANEL_INDIXVAR'		, 033 , 'PANEL_GRID')

	// Cria um "box" horizontal para receber cada elemento da view

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_UJJ'  , 'PANEL_CAMPOS' )
	oView:SetOwnerView( 'VIEW_UJK'  , 'PANEL_VARIAVEIS' )
	oView:SetOwnerView( 'VIEW_UJL'  , 'PANEL_INDICADORES' )
	oView:SetOwnerView( 'VIEW_UJM'  , 'PANEL_INDIXVAR' )

	// titulo dos componentes
	oView:EnableTitleView('VIEW_UJJ' ,"Dados do Leiaute")
	oView:EnableTitleView('VIEW_UJK' ,"Variáveis Word (DOCVARIABLES)"	)
	oView:EnableTitleView('VIEW_UJL' ,"Indicadores"	)
	oView:EnableTitleView('VIEW_UJM' ,"Variáveis X Indicadores"	)

	oView:SetCloseOnOk( { || .T. })  //Fecha a Tela ao confirmar

	//adiciona auto incremento no campo de sequencia
	oView:AddIncrementField( 'VIEW_UJK', 'UJK_ITEM'  )
	oView:AddIncrementField( 'VIEW_UJL', 'UJL_ITEM'  )
	oView:AddIncrementField( 'VIEW_UJM', 'UJM_ITEM'  )

	// Habilito a barra de progresso na abertura da tela
	oView:SetProgressBar(.T.)

Return oView

/*/{Protheus.doc} RETSX3
Retorna o conteudo escolhido na consulta na SX3
@author Leandro Rodrigues
@since 14/02/2018
@version P12
@param nulo
@return nulo
/*/

User Function RETSX3()

	Local aCpos     := {}       					//Array com os dados
	Local aRet      := {}      						//Array do retorno da opcao selecionada
	Local cTitulo   := "Consulta Campos"
	Local cTabela	:= ""
	Local cPesq		:= Space(10)
	Local lRet		:= .F.
	Local oView		:= FWViewActive()
	Local oModel  	:= FWModelActive()
	Local oModelUJK	:= oModel:GetModel('UJKDETAIL')
	Local oModelUJL	:= oModel:GetModel('UJLDETAIL')
	Local oModelUJM	:= oModel:GetModel('UJMDETAIL')
	Local oLbx		:= Nil
	Local oCampos	:= Nil
	Local aAux		:= {}
	Local nX		:= 1

	Static cRet		:= ""
	Static cRet2	:= ""

	If ReadVar() == "M->UJK_CAMPO"
		cTabela := oModelUJK:GetValue("UJK_TABELA")
	Else
		cTabela := "SD4"
	Endif

	//Instancia objeto de consulta a dicionario
	oCampos:= UGetSxFile():New

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procurar campo no SX3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAux := oCampos:GetInfoSX3(cTabela)

	//Valido se retornou os campos
	if Len(aAux) > 0

		//Preparo array de campos
		For nX:= 1 to Len(aAux)

			AADD(aCpos,{aAux[nX,2]:CAMPO,aAux[nX,2]:DESCRICAO })

		Next nX

	endif

	If Len( aCpos ) > 0

		DEFINE MSDIALOG oSX3 TITLE cTitulo FROM 0,0 TO 240,500 PIXEL

		@ 10,10 LISTBOX oLbx FIELDS HEADER "Campo", "Descrição"  SIZE 230,95 OF oSX3 PIXEL

		oLbx:SetArray( aCpos )
		oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
		oLbx:bLDblClick := {|| {oSX3:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}}

		@107,110 MSGET oPesq VAR cPesq SIZE 050, 010  OF oSX3 HASBUTTON  PIXEL
		@107,165 BUTTON oBtn PROMPT "Pesquisar" SIZE 40,12 ACTION PesqSX3(cPesq) PIXEL OF oSX3

		DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oSX3:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oSX3
		ACTIVATE MSDIALOG oSX3 CENTER

		//Posiciona no campo
		if Len(aRet) > 0

			cRet  := aRet[1]
			cRet2 := aRet[2]

		Endif

	EndIf

Return .T.

/*/{Protheus.doc} SX3MOD
//Retorno da consulta SX3MOD
@Author Leandro Rodrigues
@Since 13/08/2018
@Version 1.0
@Return
@Type function
/*/

User Function URetSx3Fun(nOpc)

	Local cRetCon:= ""

	If nOpc == 1
		cRetCon := cRet

		&(ReadVar()) := cRet
	else
		cRetCon := cRet2

		&(ReadVar()) := cRet2
	endif

Return(cRetCon)

/*/{Protheus.doc} RUTIL15A
Retorna rotinas disponiveis
@author Raphael Martins
@since 29/05/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function RUTIL15A()

	Local cRotinasImp	:= ""

	cRotinasImp := "01=DADOS CONTRATO;"

Return(cRotinasImp)

/*/{Protheus.doc} UTILIND
Consulta para exibir os indicadores cadastrados no modelo
@author g.sampaio
@since 30/05/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function UTIL15IND()

	Local aArea 			:= GetArea()
	Local aDados			:= {}
	Local aRetorno			:= {}
	Local cTitulo			:= "Consulta Indicadores"
	Local cPesq				:= Space(10)
	Local lRetorno			:= .T.
	Local nX				:= 0
	Local oModel  			:= FWModelActive()
	Local oModelUJL			:= oModel:GetModel('UJLDETAIL')
	Local oLblInd			:= Nil
	Local oDlgInd			:= Nil

	Public __xcIndicador 		:= ""
	Public __xcItemIndicador 	:= ""

	// caso a variavel publica estiver preenchida, eu limpo
	If !Empty(__xcIndicador)
		__xcIndicador := ""
	EndIf

	If !Empty(__xcItemIndicador)
		__xcItemIndicador := ""
	EndIf

	// vou percorrer todos os itens da UJL
	For nX := 1 To oModelUJL:Length()

		// posiciono na linha atual
		oModelUJL:Goline(nX)

		Aadd( aDados, { oModelUJL:GetValue('UJL_ITEM'), oModelUJL:GetValue('UJL_INDICA'), oModelUJL:GetValue('UJL_DESCRI') } )

	Next nX

	// verifico se existem dados para montar a grid
	If Len( aDados ) > 0

		DEFINE MSDIALOG oDlgInd TITLE cTitulo FROM 0,0 TO 240,500 PIXEL

		@ 10,10 LISTBOX oLblInd FIELDS HEADER "Item", "Indicador", "Descrição"  SIZE 230,95 OF oDlgInd PIXEL

		oLblInd:SetArray( aDados )
		oLblInd:bLine     	:= {|| { aDados[oLblInd:nAt,1], aDados[oLblInd:nAt,2], aDados[oLblInd:nAt,3] }}
		oLblInd:bLDblClick 	:= {|| { oDlgInd:End(), aRetorno := {oLblInd:aArray[oLblInd:nAt,1],oLblInd:aArray[oLblInd:nAt,2],oLblInd:aArray[oLblInd:nAt,3] }}}

		@107,110 MSGET oPesq VAR cPesq SIZE 050, 010  OF oDlgInd HASBUTTON  PIXEL

		@107,165 BUTTON oBtn PROMPT "Pesquisar" SIZE 40,12 ACTION PesqSX3(cPesq) PIXEL OF oDlgInd

		DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlgInd:End(), aRetorno := {oLblInd:aArray[oLblInd:nAt,1],oLblInd:aArray[oLblInd:nAt,2],oLblInd:aArray[oLblInd:nAt,3]})  ENABLE OF oDlgInd

		ACTIVATE MSDIALOG oDlgInd CENTER

		//Posiciona no campo
		if Len( aRetorno ) > 0
			__xcItemIndicador 	:= AllTrim( aRetorno[1] )
			__xcIndicador 		:= AllTrim( aRetorno[2] )
		Endif

	EndIf

	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} URETIND
Funcao para retornoar o conteudo da variavel publica __xcIndicador
que é preenchida na funcao UTIL15IND
@author g.sampaio
@since 30/05/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function URETIND(nOpc)

	Local cRetorno	:= ""

	if nOpc == 1
		cRetorno := __xcItemIndicador
	elseIf nOpc == 2
		cRetorno := __xcIndicador
	endIf

Return(cRetorno)

/*/{Protheus.doc} UTILIND
Consulta para exibir as variaveis cadastradas no modelo de dados
@author g.sampaio
@since 30/05/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function UTIL15VAR()

	Local aArea 			:= GetArea()
	Local aDados			:= {}
	Local aRetorno			:= {}
	Local cTitulo			:= "Consulta Indicadores"
	Local cPesq				:= Space(10)
	Local lRetorno			:= .T.
	Local nX				:= 0
	Local oModel  			:= FWModelActive()
	Local oModelUJK			:= oModel:GetModel('UJKDETAIL')
	Local oLblInd			:= Nil
	Local oDlgInd			:= Nil

	Public __xcVariavel 	:= ""
	Public __xcCampo		:= ""
	Public __xcTitulo		:= ""
	Public __xcFormula		:= ""

// caso a variavel publica estiver preenchida, eu limpo
	If !Empty(__xcVariavel) .Or. !Empty(__xcCampo) .Or. !Empty(__xcTitulo) .Or. !Empty(__xcFormula)
		__xcVariavel 	:= ""
		__xcCampo		:= ""
		__xcTitulo		:= ""
		__xcFormula		:= ""
	EndIf

// vou percorrer todos os itens da UJK
	For nX := 1 To oModelUJK:Length()

		// posiciono na linha atual
		oModelUJK:Goline(nX)

		Aadd( aDados, { oModelUJK:GetValue('UJK_ITEM'), oModelUJK:GetValue('UJK_VAR'), oModelUJK:GetValue('UJK_CAMPO'), oModelUJK:GetValue('UJK_NOME'), oModelUJK:GetValue('UJK_FORMUL') } )

	Next nX

// verifico se existem dados para montar a grid
	If Len( aDados ) > 0

		DEFINE MSDIALOG oDlgInd TITLE cTitulo FROM 0,0 TO 240,500 PIXEL

		@ 10,10 LISTBOX oLblInd FIELDS HEADER "Item", "Variavel", "Campo", "Titulo", "Fórmula"  SIZE 230,95 OF oDlgInd PIXEL

		oLblInd:SetArray( aDados )
		oLblInd:bLine     	:= {|| { aDados[oLblInd:nAt,1], aDados[oLblInd:nAt,2], aDados[oLblInd:nAt,3], aDados[oLblInd:nAt,4], aDados[oLblInd:nAt,5] }}
		oLblInd:bLDblClick 	:= {|| { oDlgInd:End(), aRetorno := { oLblInd:aArray[oLblInd:nAt,1], oLblInd:aArray[oLblInd:nAt,2], oLblInd:aArray[oLblInd:nAt,3], aDados[oLblInd:nAt,4], aDados[oLblInd:nAt,5] }}}

		@107,110 MSGET oPesq VAR cPesq SIZE 050, 010  OF oDlgInd HASBUTTON  PIXEL

		@107,165 BUTTON oBtn PROMPT "Pesquisar" SIZE 40,12 ACTION PesqSX3(cPesq) PIXEL OF oDlgInd

		DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlgInd:End(), aRetorno := { oLblInd:aArray[oLblInd:nAt,1], oLblInd:aArray[oLblInd:nAt,2], oLblInd:aArray[oLblInd:nAt,3], aDados[oLblInd:nAt,4], aDados[oLblInd:nAt,5] })  ENABLE OF oDlgInd

		ACTIVATE MSDIALOG oDlgInd CENTER

		//Posiciona no campo
		if Len( aRetorno ) > 0
			__xcVariavel 	:= AllTrim( aRetorno[2] )
			__xcCampo		:= AllTrim( aRetorno[3] )
			__xcTitulo		:= AllTrim( aRetorno[4] )
			__xcFormula		:= AllTrim( aRetorno[5] )
		Endif

	EndIf

	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} URETVAR
Funcao para retornoar o conteudo da variaveis publicas
que são preenchidas na funcao UTIL15VAR
@author g.sampaio
@since 30/05/2019
@version P12
@param nTipo, numerico, tipo de retorno
@return nulo
/*/

User Function URETVAR( nTipo )

	Local cRetorno	:= ""

	Default nTipo := 0

	If nTipo == 1 // retorna a variavel
		cRetorno	:= __xcVariavel
	ElseIf nTipo == 2 // retorna o campo
		cRetorno	:= __xcCampo
	ElseIf nTipo == 3 // retorna o titulo do campo
		cRetorno 	:= __xcTitulo
	ElseIf nTipo == 4 // retorna a formula
		cRetorno 	:= __xcFormula
	EndIf

Return(cRetorno)

/*/{Protheus.doc} VALDIRT
Validacao do campo UJJ_DIRDOC

@type function
@version 
@author g.sampaio
@since 23/11/2020
@return return_type, return_description
/*/
User Function VALDIRT()

	Local cDirAux			:= ""
	Local cNomeArquivo		:= ""
	Local cBarraDir			:= Iif(IsSrvUnix(),"/","\")
	Local lRetorno			:= .T.
	Local nPosBarra			:= 0
	Local nPosAux			:= 1
	Local oModel  			:= FWModelActive()
	Local oModelUJJ			:= oModel:GetModel('UJJMASTER')
	Local oView				:= FWViewActive()

	// caso o diretorio esteja preenchido
	if !Empty(oModelUJJ:GetValue("UJJ_DIRLOC"))

		// gravo o direto rio em uma variavel auxiliar
		cDirAux	:= Alltrim( oModelUJJ:GetValue("UJJ_DIRLOC") )

		while nPosBarra < nPosAux

			// pego a posicao da barra
			nPosBarra := AT(cBarraDir,cDirAux, nPosAux)

			// verifico se existe outra barra
			nPosAux	:= AT(cBarraDir,cDirAux, nPosBarra+1)

		EndDo

		// verifico se existe barra
		if nPosBarra > 0

			// corto o diretorio ate a barra
			cDirAux := SubStr(cDirAux, 1, nPosBarra)

			// atualizo o nome do diretorio
			oModelUJJ:LoadValue("UJJ_DIRLOC", cDirAux)

			if ValType( oView ) == "O"
				oView:Refresh()
			endIf

		endIf

	endIf

Return(lRetorno)

/*/{Protheus.doc} VALDIRT
Validacao do campo UJJ_DIRDOC

@type function
@version 
@author g.sampaio
@since 23/11/2020
@return return_type, return_description
/*/
User Function VALARQT()

	Local cDirAux			:= ""
	Local cNomeArquivo		:= ""
	Local cBarraDir			:= Iif(IsSrvUnix(),"/","\")
	Local lRetorno			:= .T.
	Local nPosBarra			:= 0
	Local nPosAux			:= 1
	Local oModel  			:= FWModelActive()
	Local oModelUJJ			:= oModel:GetModel('UJJMASTER')
	Local oView				:= FWViewActive()

	// caso o diretorio esteja preenchido
	if !Empty(oModelUJJ:GetValue("UJJ_MODELO"))

		// gravo o direto rio em uma variavel auxiliar
		cDirAux	:= Alltrim( oModelUJJ:GetValue("UJJ_MODELO") )

		while nPosBarra < nPosAux

			// pego a posicao da barra
			nPosBarra := AT(cBarraDir,cDirAux, nPosAux)

			// verifico se existe outra barra
			nPosAux	:= AT(cBarraDir,cDirAux, nPosBarra+1)

		EndDo

		// verifico se existe barra
		if nPosBarra > 0

			// corto o diretorio ate a barra
			cNomeArquivo := SubStr(cDirAux, nPosBarra+1)

			// atualizo o nome do diretorio
			oModelUJJ:LoadValue("UJJ_MODELO", cNomeArquivo)

			if ValType( oView ) == "O"
				oView:Refresh()
			endIf

		endIf

	endIf

Return(lRetorno)

/*/{Protheus.doc} UValUJKCmp
Validacao do campo UJK_CODREL para preencher 
o campo UJK_TABELA
@type function
@version 1.0
@author g.sampaio
@since 19/11/2021
@return logical, retorno positivo da validacao
/*/
User Function UValUJKCmp()

	Local cRetorno 		:= ""
	Local cQuery		:= ""
	Local cCodRotina	:= ""
	Local cCodRelac		:= ""
	Local lRetorno		:= .T.
	Local oModel    	:= FWModelActive()
	Local oModelUJK		:= oModel:GetModel('UJKDETAIL')
	
	// pego o conteudo dos campos
	cCodRotina	:= oModel:GetValue('UJJMASTER','UJJ_ROTINA') // codigo da rotina
	cCodRelac 	:= oModel:GetValue('UJKDETAIL','UJK_CODREL') // codigo do relacionamento

	if Select("TRBUJO") > 0
		TRBUJO->(DBCloseArea())
	endIf

	// query de consulta
	cQuery	:= " SELECT UJO.UJO_CDOM TABELA FROM " + RetSQLName("UJO") +" UJO "
	cQuery	+= " WHERE UJO.D_E_L_E_T_ = ' ' "
	cQuery	+= " AND UJO.UJO_FILIAL = '" + xFilial("UJO") + "' "
	cQuery 	+= " AND UJO.UJO_CODIGO = '" + cCodRotina + "' "
	cQuery 	+= " AND UJO.UJO_SEQ 	= '" + cCodRelac + "' "

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TRBUJO' )

	if TRBUJO->(!Eof())
		cRetorno := TRBUJO->TABELA
	else
		MsgAlert("Não foi encontrado o código do relacionamento digitado para a rotina preenchida no leiaute do termo!", "Aviso!")
		lRetorno := .F.
	endIf
	
	// preenche o campo de tabela
	oModelUJK:LoadValue("UJK_TABELA"	, cRetorno )

	if Select("TRBUJO") > 0
		TRBUJO->(DBCloseArea())
	endIf

Return(lRetorno)

/*/{Protheus.doc} UJKFastFilterUJO
Filtro para consulta padrao UJO
@type function
@version 1.0  
@author g.sampaio
@since 21/11/2021
@return character, retorno da consulta
/*/
User Function UJKFastFilterUJO()

	Local cRetorno 		:= ""
	Local oModel    	:= FWModelActive()
	
	// filtro da consulta otmizada	
	cRetorno := "@#UJO->(UJO_CODIGO == '" + oModel:GetValue('UJJMASTER','UJJ_ROTINA') + "')@#"	

Return(cRetorno)

/*/{Protheus.doc} UValUJLCmp
Validacao do campo UJL_CODREL para preencher 
o campo UJL_TABELA
@type function
@version 1.0
@author g.sampaio
@since 19/11/2021
@return logical, retorno positivo da validacao
/*/
User Function UValUJLCmp()

	Local cRetorno 		:= ""
	Local cQuery		:= ""
	Local cCodRotina	:= ""
	Local cCodRelac		:= ""
	Local lRetorno		:= .T.
	Local oModel    	:= FWModelActive()
	Local oModelUJL		:= oModel:GetModel('UJLDETAIL')
	
	// pego o conteudo dos campos
	cCodRotina	:= oModel:GetValue('UJJMASTER','UJJ_ROTINA') // codigo da rotina
	cCodRelac 	:= oModel:GetValue('UJLDETAIL','UJL_CODREL') // codigo do relacionamento

	if Select("TRBUJO") > 0
		TRBUJO->(DBCloseArea())
	endIf

	// query de consulta
	cQuery	:= " SELECT UJO.UJO_CDOM TABELA FROM " + RetSQLName("UJO") +" UJO "
	cQuery	+= " WHERE UJO.D_E_L_E_T_ = ' ' "
	cQuery	+= " AND UJO.UJO_FILIAL = '" + xFilial("UJO") + "' "
	cQuery 	+= " AND UJO.UJO_CODIGO = '" + cCodRotina + "' "
	cQuery 	+= " AND UJO.UJO_SEQ 	= '" + cCodRelac + "' "

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TRBUJO' )

	if TRBUJO->(!Eof())
		cRetorno := TRBUJO->TABELA
	else
		MsgAlert("Não foi encontrado o código do relacionamento digitado para a rotina preenchida no leiaute do termo!", "Aviso!")
		lRetorno := .F.
	endIf
	
	// preenche o campo de tabela
	oModelUJL:LoadValue("UJL_TABELA"	, cRetorno )

	if Select("TRBUJO") > 0
		TRBUJO->(DBCloseArea())
	endIf

Return(lRetorno)

/*/{Protheus.doc} UInicTabCmp
Inicializador padrao do campo para retornar
a tabela do relacionamento
@type function
@version 1.0
@author g.sampaio
@since 19/11/2021
@return character, retorna o conteudo do campo
/*/
User Function UInicTabCmp()

	Local cRetorno 		:= ""
	Local cQuery		:= ""
	Local cCodRotina	:= ""
	Local cCodRelac		:= ""	
	
	// pego o conteudo dos campos
	cCodRotina	:= UJJ->UJJ_ROTINA// codigo da rotina
	cCodRelac 	:= UJL->UJL_CODREL // codigo do relacionamento

	if Select("TRBUJO") > 0
		TRBUJO->(DBCloseArea())
	endIf

	// query de consulta
	cQuery	:= " SELECT UJO.UJO_CDOM TABELA FROM " + RetSQLName("UJO") +" UJO "
	cQuery	+= " WHERE UJO.D_E_L_E_T_ = ' ' "
	cQuery	+= " AND UJO.UJO_FILIAL = '" + xFilial("UJO") + "' "
	cQuery 	+= " AND UJO.UJO_CODIGO = '" + cCodRotina + "' "
	cQuery 	+= " AND UJO.UJO_SEQ 	= '" + cCodRelac + "' "

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TRBUJO' )

	if TRBUJO->(!Eof())
		cRetorno := TRBUJO->TABELA
	endIf
	
	if Select("TRBUJO") > 0
		TRBUJO->(DBCloseArea())
	endIf

Return(cRetorno)

/*/{Protheus.doc} UInicUJMTab
Inicializador padrao do campo para retornar
a tabela do relacionamento
@type function
@version 1.0
@author g.sampaio
@since 19/11/2021
@return character, retorna o conteudo do campo
/*/
User Function UInicUJMTab()

	Local cRetorno 		:= ""
	Local cQuery		:= ""
	Local cCodRotina	:= ""
	Local cCodIndicador	:= ""		
	Local cCodLayout	:= ""
	
	// pego o conteudo dos campos
	cCodLayout		:= UJJ->UJJ_CODIGO	// codigo do leiaute
	cCodRotina		:= UJJ->UJJ_ROTINA	// codigo da rotina
	cCodIndicador 	:= UJM->UJM_ITIND	// item do indicador	

	if Select("TRBUJO") > 0
		TRBUJO->(DBCloseArea())
	endIf

	// query de consulta
	cQuery	:= " SELECT UJO.UJO_CDOM TABELA FROM " + RetSQLName("UJO") +" UJO "
	cQuery	+= " WHERE UJO.D_E_L_E_T_ = ' ' "
	cQuery	+= " AND UJO.UJO_FILIAL = '" + xFilial("UJO") + "' "
	cQuery 	+= " AND UJO.UJO_CODIGO = '" + cCodRotina + "' "
	cQuery 	+= " AND UJO.UJO_SEQ IN (
	cQuery 	+= " SELECT UJL.UJL_CODREL FROM " + RetSQLName("UJL") +" UJL 
	cQuery 	+= " WHERE UJL.D_E_L_E_T_ = ' ' 
	cQuery 	+= " AND UJL.UJL_CODIGO = '" + cCodLayout + "'"  
	cQuery 	+= " AND UJL.UJL_ITEM = '" + cCodIndicador + "' )

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TRBUJO' )

	if TRBUJO->(!Eof())
		cRetorno := TRBUJO->TABELA
	endIf
	
	if Select("TRBUJO") > 0
		TRBUJO->(DBCloseArea())
	endIf

Return(cRetorno)

/*/{Protheus.doc} UValUJLCmp
Validacao do campo UJL_CODREL para preencher 
o campo UJL_TABELA
@type function
@version 1.0
@author g.sampaio
@since 19/11/2021
@return logical, retorno positivo da validacao
/*/
User Function UValUJMCmp()

	Local cRetorno 		:= ""
	Local cQuery		:= ""
	Local cCodRotina	:= ""
	Local cCodIndicador	:= ""		
	Local cCodLayout	:= ""
	Local lRetorno		:= .T.
	Local oModel    	:= FWModelActive()
	Local oModelUJM		:= oModel:GetModel('UJMDETAIL')
	
	// pego o conteudo dos campos
	cCodLayout		:= oModel:GetValue('UJJMASTER','UJJ_CODIGO')	// codigo do leiaute
	cCodRotina		:= oModel:GetValue('UJJMASTER','UJJ_ROTINA')	// codigo da rotina
	cCodIndicador 	:= oModel:GetValue('UJMDETAIL','UJM_ITIND')	// item do indicador	

	if Select("TRBUJO") > 0
		TRBUJO->(DBCloseArea())
	endIf

	// query de consulta	
	cQuery	:= " SELECT UJO.UJO_CDOM TABELA FROM " + RetSQLName("UJO") +" UJO "
	cQuery	+= " WHERE UJO.D_E_L_E_T_ = ' ' "
	cQuery	+= " AND UJO.UJO_FILIAL = '" + xFilial("UJO") + "' "
	cQuery 	+= " AND UJO.UJO_CODIGO = '" + cCodRotina + "' "
	cQuery 	+= " AND UJO.UJO_SEQ IN (
	cQuery 	+= " SELECT UJL.UJL_CODREL FROM " + RetSQLName("UJL") +" UJL 
	cQuery 	+= " WHERE UJL.D_E_L_E_T_ = ' ' 
	cQuery 	+= " AND UJL.UJL_CODIGO = '" + cCodLayout + "'"  
	cQuery 	+= " AND UJL.UJL_ITEM = '" + cCodIndicador + "' )

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TRBUJO' )

	if TRBUJO->(!Eof())
		cRetorno := TRBUJO->TABELA
	else
		MsgAlert("Não foi encontrado o código do relacionamento digitado para a rotina preenchida no leiaute do termo!", "Aviso!")
		lRetorno := .F.
	endIf
	
	// preenche o campo de tabela
	oModelUJM:LoadValue("UJM_TABELA"	, cRetorno )

	if Select("TRBUJO") > 0
		TRBUJO->(DBCloseArea())
	endIf

Return(lRetorno)
