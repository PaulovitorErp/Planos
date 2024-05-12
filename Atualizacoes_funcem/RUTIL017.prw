#Include 'totvs.ch'
#Include 'fwmvcdef.ch'

/*/{Protheus.doc} RUTIL017
Rotina para Cadastro de rotinas a serem utilizadas
como fonte de dados para o Gerador de Termos
@author g.sampaio
@since 07/06/2019
@version P12
@param nulo
@return nulo
/*/

User Function RUTIL017()

	Local oBrw

	Private __cRetSix	:= ""
	Private __cRetInd	:= ""
	Private __cRetCampo	:= ""

	oBrw := FWmBrowse():New(	)

	oBrw:SetAlias( 'UJN' )
	oBrw:SetDescription( 'Fonte de Dados Termos' )
	oBrw:Activate()

Return()

/*/{Protheus.doc} MenuDef
Função que cria os menus	
@author g.sampaio
@since 07/06/2019
@version P12
@param nulo
@return nulo
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar'	      	ACTION 'VIEWDEF.RUTIL017' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'         		ACTION 'VIEWDEF.RUTIL017' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'         		ACTION 'VIEWDEF.RUTIL017' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'         		ACTION 'VIEWDEF.RUTIL017' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     			ACTION 'VIEWDEF.RUTIL017' OPERATION 9 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
Função que cria o objeto model	
@author g.sampaio
@since 07/06/2019
@version P12
@param nulo
@return nulo
/*/
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruUJN  := FWFormStruct( 1, 'UJN', /*bAvalCampo*/,/*lViewUsado*/ ) // Dados Modelo
	Local oStruUJO  := FWFormStruct( 1, 'UJO', /*bAvalCampo*/,/*lViewUsado*/ ) // Variaveis Word

	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('PUTIL017', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formul·rio de ediÁ?o por campo
	oModel:AddFields( 'UJNMASTER', /*cOwner*/, oStruUJN, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	// Adiciona ao modelo uma componente de grid
	oModel:AddGrid( 'UJODETAIL', 'UJNMASTER', oStruUJO , /*bLinePre*/{|oMdlG,nLine,cAcao,cCampo| EditGrid(oMdlG,nLine,cAcao,cCampo)}, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'UJODETAIL', { {'UJO_FILIAL' , 'xFilial( "UJO" )'}, {'UJO_CODIGO','UJN_CODIGO' }}, UJO->( IndexKey(1)))

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "UJN_FILIAL" , "UJN_CODIGO" })

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'UJODETAIL' ):SetUniqueLine( { 'UJO_FILIAL','UJO_CODIGO','UJO_DOM','UJO_CDOM'} )

	// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel( 'UJODETAIL' ):SetDescription( 'Relacionamento entre Tabelas' )

Return(oModel)

/*/{Protheus.doc} ViewDef
Função que cria o objeto View
@author g.sampaio
@since 07/06/2019
@version P12
@param nulo
@return nulo
/*/
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'RUTIL017' )
	Local oView

	// Cria a estrutura a ser usada na View
	Local oStruUJN  := FWFormStruct( 2, 'UJN' )
	Local oStruUJO  := FWFormStruct( 2, 'UJO' )

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados ser· utilizado
	oView:SetModel( oModel )

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_UJN', oStruUJN, 'UJNMASTER' )

	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid( 'VIEW_UJO', oStruUJO,  'UJODETAIL' )

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_TELA'		, 100)

	oView:CreateVerticalBox('PANEL_CAMPOS'		, 045,'PANEL_TELA')
	oView:CreateVerticalBox('PANEL_GRID'		, 055,'PANEL_TELA')

	oView:CreateHorizontalBox('PANEL_RELACIONAMENTO'		, 100 , 'PANEL_GRID' )

	// Cria um "box" horizontal para receber cada elemento da view
	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_UJN'  , 'PANEL_CAMPOS' )
	oView:SetOwnerView( 'VIEW_UJO'  , 'PANEL_RELACIONAMENTO' )

	// titulo dos componentes
	oView:EnableTitleView('VIEW_UJN' ,"Fonte de Dados")
	oView:EnableTitleView('VIEW_UJO' ,"Relacionamento entre Tabelas"	)

	oView:SetCloseOnOk( { || .T. })  //Fecha a Tela ao confirmar

	//adiciona auto incremento no campo de sequencia
	oView:AddIncrementField( 'VIEW_UJO', 'UJO_SEQ'  )

	// Habilito a barra de progresso na abertura da tela
	oView:SetProgressBar(.T.)

Return(oView)

/*/{Protheus.doc} UTIL17TAB
Rotina para abrir os alias a serem utilizados pela rotina
@author g.sampaio
@since 10/06/2019
@version P12
@param cImpRotina	, caractere, rotina
@return nulo
/*/

User Function TAB( cImpRotina, cContrato, cTabela )

	Local aAreaUJN		:= UJN->( GetArea() )
	Local aAreaUJO		:= UJO->( GetArea() )
	Local cChave		:= ""

	Default cImpRotina 	:= ""
	Default cContrato	:= ""
	Default cTabela		:= ""

// posicina tabela UJN
	DbSelectArea("UJN")
	UJN->( DbSetOrder(1) )
	If UJN->( DbSeek( xFilial("UJN")+cImpRotina ) )

		// posiciono na tabela de contratos
		DbSelectArea(cTabela)
		(cTabela)->( DbSetOrder(1) )
		(cTabela)->( DbSeek(xFilial(cTabela)+cContrato) )

		// posicina tabela UJO
		DbSelectArea("UJO")
		UJO->( DbSetOrder(1) )
		If UJO->( DbSeek( xFilial("UJO")+UJN->UJN_CODIGO ) )

			// percorre os registros da UJO, por contrato
			While UJO->(!Eof()) .And. UJO->UJO_FILIAL+UJO->UJO_CODIGO == xFilial("UJO")+UJN->UJN_CODIGO

				// monto a chave do indice
				cChave := "xFilial('"+UJO->UJO_CDOM+"')+" + UJO->UJO_DOM + "->(" + AllTrim( UJO->UJO_RELACI ) + ")"

				// vou abrir os alias que foram determinados
				DbSelectArea( UJO->UJO_CDOM )
				(UJO->UJO_CDOM)->( DbSetOrder( UJO->UJO_ORDEM ) )
				(UJO->UJO_CDOM)->( DbSeek( &(cChave) ) )

				UJO->( DbSkip() )
			EndDo

		EndIf

	EndIf

	RestArea( aAreaUJO )
	RestArea( aAreaUJN )

Return()

/*/{Protheus.doc} GET17SX7
Preenche o campo UJO_DOM
@author g.sampaio
@since 10/06/2019
@version P12
@param cImpRotina	, caractere, rotina
@return nulo
/*/

User Function GET17SX7()
	Local aArea 			:= GetArea()
	Local nX				:= 0
	Local oModel  			:= FWModelActive()
	Local oModelUJO			:= oModel:GetModel('UJODETAIL')

// vou percorrer todos os itens da UJL
	For nX := 1 To oModelUJO:Length()

		// posiciono na linha atual
		oModelUJO:Goline(nX)

		// preencho o campo de tabela
		oModelUJO:SetValue('UJO_DOM' , M->UJN_TABELA)

	Next nX

Return(.T.)

/*/{Protheus.doc} RUTIL017
COnsulta especifica para retornar Indice
@author g.sampaio
@since 04/06/2019
@version P12
@param nulo            
@return nulo
/*/
User Function IndUJN(cChaveAnt,cIndiceAnt)


	Local aArea				:= GetArea()
	Local cChave            := ""
	Local cIndice           := ""
	Local nOrd 				:= 1, cOrd:="1",lOk := .F.
	Local nPosList			:= 0
	Local oListBox, oConf, oCanc, oVisu

	Local oCbx, aOrd		:= {"Chave"}
	Local oBigGet, cCampo 	:= Space(Len(SIX->ORDEM))

	Local oModel			:= FWModelActive()
	Local oModelUJN 		:= oModel:GetModel("UJNMASTER")
	Local cIndice			:= oModelUJN:GetValue("UJN_TABELA")
	Local oSIX				:= Nil
	Local nX				:= 1
	Local oIndice			:= UGetSxFile():New
	DEFAULT cChaveAnt  := Alltrim(&(ReadVar()))
	DEFAULT cIndiceAnt := Alltrim(&(ReadVar()))

//If Empty(aSIXList)

	aSIXList 	:= {}
	aSIXControl	:= {}

	If !Empty(cIndice)

		aSIXList 	:= oIndice:GetInfoSIX(cIndice)

		For nX:= 1 to Len(aSIXList)

			AADD(aSIXControl,{aSIXList[nX,2]:cRECNOSIX })

			If !Empty(cChaveAnt) .And. cChaveAnt == AllTrim(aSIXList[nX,2]:cORDEM)
				nPosList := Len(aSIXList)
			EndIf

		Next nX
	Else
		Help(,,'Help',,"Campo Tabela obrigatório.",1,0)
		Return .F.
	Endif


	DEFINE MSDIALOG oSIX FROM 00,00 TO 400,490 PIXEL TITLE OemToAnsi("Pesquisa")

	@05,05 COMBOBOX oCBX VAR cOrd ITEMS aOrd SIZE 206,36 PIXEL OF oSIX FONT oSIX:oFont

	@22,05 MSGET oBigGet VAR cCampo SIZE 206,10 PIXEL
	@05,215 BUTTON oConf Prompt "Pesquisar" SIZE 30,10 FONT oSIX:oFont ACTION (oListBox:nAT := VerIndSIX(aSIXList, aSIXControl, cCampo, oListBox),;
		oListBox:bLine:={||{aSIXList[oListBox:nAT][2]:cOrdem,aSIXList[oListBox:nAT][2]:cCHAVE}},;
		oConf:SetFocus()) OF oSIX PIXEL

	oCbx:bChange := {|| nOrd := oCbx:nAt}

	@0,0 BITMAP oBmp RESNAME "INDICE" Of oSIX SIZE 100,300 NOBORDER When .F. PIXEL
	oListBox := TWBrowse():New( 40,05,204,140,,{"Chave","Descricao"},,oSIX,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oListBox:SetArray(aSIXList)
	oListBox:bLine := { ||{aSIXList[oListBox:nAT][2]:cOrdem,aSIXList[oListBox:nAT][2]:cCHAVE}}
	oListBox:bLDblClick := { ||Eval(oConf:bAction), oSIX:End()}

	@185,05 BUTTON oConf Prompt "Confirma" SIZE 45 ,10 FONT oSIX:oFont ACTION (lOk := .T.,cChave := aSIXList[oListBox:nAT][2]:cOrdem,cIndice := aSIXList[oListBox:nAT][2]:cCHAVE ,oSIX:End())  OF oSIX PIXEL
	@185,55 BUTTON oCanc Prompt "Cancela"  SIZE 45 ,10 FONT oSIX:oFont ACTION (lOk := .F.,oSIX:End())  OF oSIX PIXEL

	If nPosList > 0
		oListBox:nAT 	:= nPosList
		oListBox:bLine 	:= {||{aSIXList[oListBox:nAT][2]:cINDICE,aSIXList[oListBox:nAT][2]:cCHAVE}}
		oConf:SetFocus()
	Endif

	ACTIVATE MSDIALOG oSIX CENTERED


	If !lOk
		cChave := cChaveAnt
		cIndice:= cIndiceAnt
	Endif

//variavel utilizada no retorno sxb
	__cRetSix := cChave
	__cRetInd := cIndice

	RestArea(aArea)

Return lOk

/*/{Protheus.doc} RUTIL017
Retorna indice selecionado
@author g.sampaio
@since 04/06/2019
@version P12
@param nulo            
@return nulo
/*/
User Function RIndChv()

Return(__cRetSix)

/*/{Protheus.doc} RUTIL017
Retorna Chave selecionado
@author g.sampaio
@since 04/06/2019
@version P12
@param nulo            
@return nulo
/*/
User Function RIndUJN()

Return(__cRetInd)


/*/{Protheus.doc} RUTIL17A
Retorna o conteudo escolhido na consulta na SX3
@author Leandro Rodrigues
@since 14/02/2018
@version P12
@param nulo
@return nulo
/*/

User Function RUTIL17A()

	Local aCpos     := {}       					//Array com os dados
	Local aRet      := {}      						//Array do retorno da opcao selecionada
	Local cTitulo   := "Consulta Campos"
	Local cTabela	:= ""
	Local cPesq		:= Space(10)
	Local lRet		:= .F.
	Local oView		:= FWViewActive()
	Local oModel  	:= FWModelActive()
	Local oModelUJN	:= oModel:GetModel('UJNMASTER')
	Local oLbx		:= NIL
	Local cF3Campo	:= ""
	Local oIndice	:= ""
	Local oSX3		:= UGetSxFile():New
	Local aAux		:= {}
	Local nX		:= 1

	cTabela 	:= oModelUJN:GetValue("UJN_TABELA")
	cF3Campo	:= oModelUJN:GetValue("UJN_CONSUL")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Procurar campo no SX3³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAux:= oSX3:GetInfoSix(cEntidade)

	if Len(aAux) > 0

		For nX:= 1 to Len(aAux)
			if aAux[nX,2]:cCONTEXT <> "V"

				AADD(aCpos,{aAux[nX,2]:cCAMPO,aAux[nX,2]:cTITULO })

			endif
		Next nX
	endif

	If Len( aCpos ) > 0

		DEFINE MSDIALOG oIndice TITLE cTitulo FROM 0,0 TO 240,500 PIXEL

		@ 10,10 LISTBOX oLbx FIELDS HEADER "Campo", "Descrição"  SIZE 230,95 OF oIndice PIXEL

		oLbx:SetArray( aCpos )
		oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
		oLbx:bLDblClick := {|| {oIndice:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}}

		@107,110 MSGET oPesq VAR cPesq SIZE 050, 010  OF oIndice HASBUTTON  PIXEL
		@107,165 BUTTON oBtn PROMPT "Pesquisar" SIZE 40,12 ACTION PesqSX3(cPesq) PIXEL OF oIndice

		DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oIndice:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oIndice
		ACTIVATE MSDIALOG oIndice CENTER

		__cRetCampo := iif(Empty(cF3Campo),Alltrim(aRet[1]),Alltrim(cF3Campo)+','+Alltrim(aRet[1]))
	EndIf

Return(.T.)

/*/{Protheus.doc} RUTIL17B
Retorna Campo
@author Raphael Martins
@since 29/05/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RUTIL17B()
Return(__cRetCampo)

/*/{Protheus.doc} RUTIL17C
Validacao do campo UJN_CHAVE
@type function
@version 1.0
@author g.sampaio
@since 19/11/2021
@return logical, retorna logico
/*/
User Function RUTIL17C()

	Local oModel  		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUJN		:= oModel:GetModel('UJNMASTER')
	Local oModelUJO		:= oModel:GetModel('UJODETAIL')
	Local nOperation 	:= oModel:GetOperation()

	// se a operação for inclusão, limpo o grid, senão deleto todas as linhas
	if nOperation == MODEL_OPERATION_INSERT

		// função que limpa o grid
		U_LimpaAcolsMVC(oModelUJO, oView)

	Endif

	//Carregando dados do titular na grid beneficiarios
	oModelUJO:LoadValue("UJO_TIPO"		, "1" )
	oModelUJO:LoadValue("UJO_CDOM"		, oModelUJN:GetValue("UJN_TABELA") )
	oModelUJO:LoadValue("UJO_ORDEM"		, Val(oModelUJN:GetValue("UJN_INDICE")) )
	oModelUJO:LoadValue("UJO_CHAVE"		, oModelUJN:GetValue("UJN_CHAVE") )
	oModelUJO:LoadValue("UJO_RELACI"	, oModelUJN:GetValue("UJN_CHAVE") )

Return(.T.)

Static Function EditGrid(oModelGrid,nLine,cAcao,cCampo)
	
	Local oModel  		:= FWModelActive()
	Local oModelUJN		:= oModel:GetModel('UJNMASTER')
	Local lRetorno 		:= .T.

	//atualizo o valor do contrato de acordo em casos de delecao e restauracao da linha posicionada
	If !IsInCallStack("U_LimpaAcolsMVC")

		if oModelGrid:cId == "UJODETAIL"

			If cAcao == "CANSETVALUE"

				// caso for a sequencia 001 e tabela principal das fontes de dados, nao deixao ser editada
				if oModelGrid:GetValue("UJO_SEQ") == "001" .And. oModelGrid:GetValue("UJO_CDOM") == oModelUJN:GetValue("UJN_TABELA") 
					lRetorno := .F.
				endIf

			endIf

		endIf

	endIf

Return(lRetorno)

