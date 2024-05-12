#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "topconn.ch"
#INCLUDE "FWEditPanel.CH"

/*/{Protheus.doc} RFUNA044
Locação Convalescencia
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

User Function RFUNA044()

	Local aArea			:= GetArea()
	Local oBrowse		:= Nil
	Local cRotinaAtual	:= FunName()

	Static oTotais  	:= NIL
	Static cPulaLinha	:= chr(13)+chr(10)

	SetFunName("RFUNA044")

	oBrowse := FWmBrowse():New()

	oBrowse:SetAlias("UJH")
	oBrowse:SetDescription("Locação Convalescencia")
	oBrowse:AddLegend("UJH_STATUS == 'A'", "BLUE",		"Aguardando Remessa")
	oBrowse:AddLegend("UJH_STATUS == 'L'", "WHITE",		"Remessa Realizada")
	oBrowse:AddLegend("UJH_STATUS == 'P'", "GREEN",		"Retorno Parcialmente")
	oBrowse:AddLegend("UJH_STATUS == 'D'", "RED",		"Retorno Realizado")

	If FwIsInCallStack("U_RFUNA002")
		// pergunto ao usuario se quer filtrar apenas os apontamentos do contrato
		If MsgYesNo("Deseja filtrar os Contratos de Convalescente do contrato posicionado?")
			oBrowse:SetFilterDefault( "UJH_FILIAL == '"+ xFilial("UJH",UF2->UF2_MSFIL) +"' .And. UJH_CONTRA == '" + UF2->UF2_CODIGO + "'" ) // filtro apenas o contrato selecionado
		EndIf
	EndIf

	oBrowse:Activate()

	SetFunName(cRotinaAtual)

	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} MenuDef	
Função que cria os menus			
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo.
/*/
Static Function MenuDef()

	Local aRotina 	:= {}

	ADD OPTION aRotina Title 'Visualizar' 			Action "VIEWDEF.RFUNA044"				OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Alterar"    			Action "VIEWDEF.RFUNA044"				OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Excluir"    			Action "VIEWDEF.RFUNA044"				OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title "Ativar"   			Action "U_GerarRemessa" 				OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Retornar"   			Action "U_RetornoRemessa('RETORNO')"    OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Troca Equipamentos"   Action "U_RetornoRemessa('TROCA')"  	OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'				Action 'U_FUNA043L(1)'			 		OPERATION 6 ACCESS 0
	ADD OPTION aRotina Title 'Impressao Contrato'	Action 'U_RFUNA44I()'			 		OPERATION 6 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
Função que cria o objeto model			
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruUJH 		:= FWFormStruct(1,"UJH",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruUJI 		:= FWFormStruct(1,"UJI",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruSE1 		:= DefStrModel("SE1")
	Local bVldActive	:= {|oModel| AddFiltro(oModel) }

	Local oModel

// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("PFUNA044",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("UJHMASTER",/*cOwner*/,oStruUJH)

// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({"UJH_FILIAL","UJH_CODIGO"})

// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid("UJIDETAIL","UJHMASTER",oStruUJI,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/{|oMdlG,nLine,cAcao,cCampo| ValDelLinha(oMdlG,nLine,cAcao,cCampo)},/*bPosVal*/,/*BLoad*/)

	oModel:AddGrid("SE1DETAIL","UJHMASTER",oStruSE1,/*bLinePre*//*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation("UJIDETAIL", {{"UJI_FILIAL", 'xFilial("UJI")'},{"UJI_CODIGO","UJH_CODIGO"}},UJI->(IndexKey(1)))

// Liga o controle de nao repeticao de linha
	oModel:GetModel("UJIDETAIL"):SetUniqueLine({"UJI_CHAPA","UJI_DATARE"})

// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("UJHMASTER"):SetDescription("Dados do Contrato")
	oModel:GetModel("UJIDETAIL"):SetDescription("Equipamentos Entregues")
	oModel:GetModel("SE1DETAIL"):SetDescription("Resumo Financeiro")

// não permite receber inserção de linha.
	oModel:GetModel('SE1DETAIL'):SetOptional( .T. )
	oModel:GetModel('SE1DETAIL'):SetOnlyQuery()
	oModel:GetModel('SE1DETAIL'):SetNoInsertLine(.T.)


//Validacao na ativacao do Model
	oModel:SetVldActivate(bVldActive)

//Adiciona regra de dependencia no model
	oModel:AddRules( 'UJIDETAIL', 'UJI_CHAPA', 'UJHMASTER', 'UJH_TABPRC', 3)

Return oModel

/*/{Protheus.doc} ModelDef
Função que cria o objeto View			
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function ViewDef()


// Cria a estrutura a ser usada na View
	Local oStruUJH 		:= FWFormStruct(2,"UJH")
	Local oStruUJI 		:= FWFormStruct(2,"UJI")
	Local oStruSE1 		:= DefStrView("SE1")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   		:= FWLoadModel("RFUNA044")
	Local oView

// Remove campos da estrutura
	oStruUJI:RemoveField('UJI_CODIGO')

// Cria o objeto de View
	oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField("VIEW_UJH",oStruUJH,"UJHMASTER")

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid("VIEW_UJI",oStruUJI,"UJIDETAIL")
	oView:AddGrid("VIEW_SE1",oStruSE1,"SE1DETAIL")

// Cria componentes nao MVC
	oView:AddOtherObject("RESUMO", {|oPanel| RefreshTotais(oPanel) })

	oView:CreateVerticalBox("PANEL_ESQUERDA"		, 100)
	oView:CreateVerticalBox("PANEL_DIREITA"			, 100,,.T.)

	oView:CreateHorizontalBox("PAINEL_CABEC",	50	,	"PANEL_ESQUERDA")
	oView:CreateHorizontalBox("PAINEL_ITENS",	50	,	"PANEL_ESQUERDA")

	oView:CreateVerticalBox("PAINEL_ITENS_C", 50, "PAINEL_ITENS")
	oView:CreateVerticalBox("PAINEL_ITENS_E", 50, "PAINEL_ITENS")

// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView("VIEW_UJH"	,"PAINEL_CABEC")
	oView:SetOwnerView("VIEW_UJI"	,"PAINEL_ITENS_C")
	oView:SetOwnerView("VIEW_SE1"	,"PAINEL_ITENS_E")
	oView:SetOwnerView("RESUMO"		,"PANEL_DIREITA")

// Liga a identificacao do componente
	oView:EnableTitleView("VIEW_UJI","Equipamentos Entregues")
	oView:EnableTitleView("VIEW_SE1","Resumo Financeiro")


// Define campos que terao Auto Incremento
	oView:AddIncrementField("VIEW_UJI","UJI_ITEM")

// Habilita a quebra dos campos na Vertical
	oView:SetViewProperty( 'UJHMASTER', "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

// Inicializacao do campo Contrato quando chamado pela rotina de Contrato
	oView:SetViewAction( 'UNDELETELINE', { |oView,cIdView,nNumLine| UnDelGrid( oView,cIdView,nNumLine ) } )

//Habila acao no preechimento do campo
	oView:SetFieldAction('UJH_CONTRA' ,  { |oView, cIDView, cField, xValue| CarregaDados(oView, cIDView, cField, xValue) } )
	oView:SetFieldAction('UJH_CODBEN' ,  { |oView, cIDView, cField, xValue| CarregaDados(oView, cIDView, cField, xValue) } )
	oView:SetFieldAction('UJH_FORPG'  ,  { |oView, cIDView, cField, xValue| CarregaDados(oView, cIDView, cField, xValue) } )
	oView:SetFieldAction('UJH_TABPRC' ,  { |oView, cIDView, cField, xValue| CarregaDados(oView, cIDView, cField, xValue) } )
	oView:SetFieldAction('UJI_CHAPA'  ,  { |oView, cIDView, cField, xValue| CarregaDados(oView, cIDView, cField, xValue) } )
	oView:SetFieldAction('UJI_QUANT'  ,  { |oView, cIDView, cField, xValue| CarregaDados(oView, cIDView, cField, xValue) } )
	oView:SetFieldAction('UJI_OK'  	  ,  { |oView, cIDView, cField, xValue| TrocaEquipamento(oView, cIDView, cField, xValue) } )

	oView:SetAfterViewActivate({|oView| ResumoFin(),IniCpoCont(oView)  } )

// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk( {||.T.} )

// Habilito a barra de progresso na abertura da tela
	oView:SetProgressBar(.T.)

//Desabilito campo se nao for troca ou retorno
	If !IsInCallStack("U_RetornoRemessa")
		oStruUJI:RemoveField('UJI_OK')
	Endif

//Adiciono botao de legenda
	oView:AddUserButton("Legenda Titulo","MAGIC_BMP",{|| U_FUNA043L() },"Legenda")


Return oView

/*/{Protheus.doc} RFUNA44I
Impressao do Contrato de Convalescente
@type function
@version 1.0
@author g.sampaio
@since 20/04/2024
/*/
User Function RFUNA44I()

	Local cMVImpContrato	:= "RFUNR037"//SuperGetMV("MV_XICTRCV", .F., "RFUNR013")

	&("U_" + AllTrim(cMVImpContrato) + "(UJH->UJH_CONTRA)")

Return(Nil)

/*/{Protheus.doc} ModelDef
Função que cria estrutura da SE1 par model			
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function DefStrModel(cAlias)


	Local aArea    		:= GetArea()
	Local bValid   		:= { || }
	Local bWhen    		:= { || }
	Local bRelac   		:= { || }
	Local aAux     		:= {}
	Local aCampos		:= {}
	Local oStruct 		:= FWFormModelStruct():New()
	Local oSx			:= UGetSxFile():New
	Local aSX2			:= {}
	Local aSIX			:= {}
	Local aSX3			:= {}
	Local aSX7			:= {}
	Local nX			:= 1

//--------
// Campos
//--------

	aCampos	:= {"E1_XLEGEND","E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","E1_CLIENTE","E1_LOJA",;
		"E1_XNOME","E1_EMISSAO","E1_VENCTO","E1_VALOR","E1_SALDO"}

//--------
// Tabela
//--------
	aSX2:= oSX:GetInfoSX2(cAlias)

	oStruct:AddTable(aSX2[1,2]:cCHAVE,StrTokArr(Alltrim(aSX2[1,2]:cUNICO), '+') ,Alltrim(aSX2[1,2]:cNOME))

	aSIX:= oSX:GetInfoSIX(cAlias)

//---------                                             	
// Indices
//---------
	nOrdem := 0

	For nX:= 1 to Len(aSIX)

		oStruct:AddIndex(nOrdem++,aSIX[nX,2]:cORDEM,aSIX[nX,2]:cCHAVE,SIXDescricao(),aSIX[nX,2]:cF3,aSIX[nX,2]:cNICKNAME ,(aSIX[nX,2]:cSHOWPESQ <> 'N'))

	Next nX

	For nX := 1 To Len(aCampos)

		aSX3:= oSX:GetInfoSX3(,aCampos[nX])

		//Crio campo virtual para add legenda do titulo
		If aCampos[nX] == "E1_XLEGEND"


			If SE1->E1_SALDO == 0 //Titulo baixado

				bRelac 	:=  { || "BR_VERMELHO"}

			Elseif  SE1->E1_SALDO > 0 .AND. SE1->E1_VENCREA < dDataBase	//Titulo em atraso

				bRelac 	:=  { || "BR_AMARELO"}

			else

				bRelac 	:=  { || "BR_VERDE"}   // valor a receber
			endif

			oStruct:AddField('','','E1_XLEGEND','C',50,0,,,{},.F.,bRelac,,,.T.)


		Elseif aCampos[nX] == "E1_XNOME"

			oStruct:AddField('Nome Cliente','Nome Cliente','E1_XNOME','C',50,0,,,{},.F.,Nil,,,.T.)

		Elseif Len(aSX3) > 0


			bValid 	:= FwBuildFeature( 1, aSX3[1,2]:cVALID   )
			bWhen  	:= FwBuildFeature( 2, aSX3[1,2]:cWHEN    )
			bRelac 	:= FwBuildFeature( 3, aSX3[1,2]:cRELACAO )

			aBox	:= StrTokArr(AllTrim(aSX3[1,2]:cCBOX),';' )

			oStruct:AddField( 			;
				AllTrim(aSX3[1,2]:cTITULO), ;	// [01] Titulo do campo
			AllTrim(aSX3[1,2]:cDESCRI), ;	// [02] ToolTip do campo
			aSX3[1,2]:cCAMPO,	 		;	// [03] Id do Field
			aSX3[1,2]:cTIPO, 			;	// [04] Tipo do campo
			aSX3[1,2]:nTAMANHO,			;	// [05] Tamanho do campo
			aSX3[1,2]:nDECIMAL,			;	// [06] Decimal do campo
			bValid, 					;	// [07] Code-block de valida?o do campo
			bWhen, 						;	// [08] Code-block de valida?o When do campo
			aBox, 						;	// [09] Lista de valores permitido do campo
			.F., 						;	// [10] Indica se o campo tem preenchimento obrigat?io
			bRelac, 					;	// [11] Code-block de inicializacao do campo
			NIL, 						;	// [12] Indica se trata-se de um campo chave
			NIL, 						;	// [13] Indica se o campo pode receber valor em uma opera?o de update.
			(aSX3[1,2]:cCONTEXT == 'V'))// [14] Indica se o campo ?virtual

		Endif
	Next nX


//----------
// Gatilhos
//----------
	For nX := 1 To Len(aCampos)

		aSX7 := oSX:GetInfoSX7(aCampos[nX])

		if Len(aSX7)>0

			aAux :=	FwStruTrigger(aSX7[1,2]:cCAMPO,aSX7[1,2]:cCDOMIN,aSX7[1,2]:cREGRA,aSX7[1,2]:cSEEK=='S',aSX7[1,2]:cALIAS,aSX7[1,2]:cORDEM,aSX7[1,2]:cCHAVE,aSX7[1,2]:cCONDIC,aSX7[1,2]:cSEQUENC)
			oStruct:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

		endif

	Next nX

	RestArea(aArea)

Return oStruct

/*/{Protheus.doc} ModelDef
Função que cria estrutura da SE1 par View			
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

Static Function DefStrView(cAlias)

	Local oStruct   	:= FWFormViewStruct():New()
	Local aArea     	:= GetArea()
	Local aCampos		:= {}
	Local aEdit			:= {}
	Local aCombo    	:= {}
	Local aAux      	:= {}
	Local nInitCBox 	:= 0
	Local nMaxLenCb 	:= 0
	Local nI        	:= 1
	Local nX			:= 1
	Local cGSC      	:= ''
	Local oSX			:= UGetSxFile():New
	Local aSX3			:= {}
	Local aSXA			:= {}

//--------
// Campos
//--------
	aCampos	:= {"E1_XLEGEND","E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO","E1_CLIENTE","E1_LOJA",;
		"E1_XNOME","E1_EMISSAO","E1_VENCTO","E1_VALOR","E1_SALDO"}

	For nX := 1 To Len(aCampos)

		aSX3:= oSX:GetInfoSX3(,aCampos[nX])

		//Add campo virtual de legenda do titulos
		If aCampos[nX] == "E1_XLEGEND"

			oStruct:AddField( 			;
				"E1_XLEGEND", 				;	// [01] Campo
			'00',           			;	// [02] Ordem
			"", 						;	// [03] Titulo
			"", 						;	// [04] Descricao
			NIL, 						;	// [05] Help
			"C", 						;	// [06] Tipo do campo   COMBO, Get ou CHECK
			'@BMP', 					;	// [07] Picture
			Nil, 						;	// [08] PictVar
			"", 						;	// [09] F3
			.F. ,                       ;   // [10] Editavel
			Nil, 						;	// [11] Folder
			Nil, 						;	// [12] Group
			Nil,						;	// [13] Lista ComboDEFSTRVIEW
			0, 							;	// [14] Tam Max Combo
			"", 						;	// [15] Inic. Browse
			.T.    						)  	// [16] Virtual

		Elseif aCampos[nX] == "E1_XNOME"

			oStruct:AddField( 			;
				"E1_XNOME", 				;	// [01] Campo
			'11',           			;	// [02] Ordem
			"Nome Cliente", 			;	// [03] Titulo
			"Nome do Cliente",			;	// [04] Descricao
			NIL, 						;	// [05] Help
			"C", 						;	// [06] Tipo do campo   COMBO, Get ou CHECK
			'@!', 						;	// [07] Picture
			Nil, 						;	// [08] PictVar
			"", 						;	// [09] F3
			.F. ,                       ;   // [10] Editavel
			Nil, 						;	// [11] Folder
			Nil, 						;	// [12] Group
			Nil,						;	// [13] Lista ComboDEFSTRVIEW
			0, 							;	// [14] Tam Max Combo
			"", 						;	// [15] Inic. Browse
			.T.    						)  	// [16] Virtual

		Elseif Len(aSX3) > 0

			aCombo := {}

			If !Empty(aSX3[1,2]:cCBOX)

				nInitCBox := 0
				nMaxLenCb := 0

				aAux := RetSX3Box( aSX3[1,2]:cCBOX , @nInitCBox, @nMaxLenCb,aSX3[1,2]:nTAMANHO )

				For nI := 1 To Len(aAux)
					aAdd( aCombo, aAux[nI][1] )
				Next nI

			EndIf

			bPictVar := FwBuildFeature( 4, aSX3[1,2]:cPICTVAR )
			cGSC     := IIf( Empty(aSX3[1,2]:cCBOX) , IIf( aSX3[1,2]:cTIPO == 'L', 'CHECK', 'GET' ) , 'COMBO' )

			oStruct:AddField( 			;
				aSX3[1,2]:cCAMPO, 			;	// [01] Campo
			aSX3[1,2]:cORDEM,			;	// [02] Ordem
			AllTrim(aSX3[1,2]:cTITULO),	;	// [03] Titulo
			AllTrim(aSX3[1,2]:cDESCRI), 		;	// [04] Descricao
			NIL, 						;	// [05] Help
			cGSC, 						;	// [06] Tipo do campo   COMBO, Get ou CHECK
			aSX3[1,2]:cPICTURE,			;	// [07] Picture
			bPictVar, 					;	// [08] PictVar
			aSX3[1,2]:cF3, 				;	// [09] F3
			aSX3[1,2]:cVISUAL <> 'V', 	;	// [10] Editavel
			aSX3[1,2]:cFOLDER, 			;	// [11] Folder
			aSX3[1,2]:cFOLDER, 			;	// [12] Group
			aCombo,						;	// [13] Lista Combo
			nMaxLenCb, 					;	// [14] Tam Max Combo
			aSX3[1,2]:cINIBRW, 			;	// [15] Inic. Browse
			(aSX3[1,2]:cCONTEXT == 'V'))   	// [16] Virtual

		EndIf

	Next nX

	RestArea(aArea)

Return oStruct


/*/{Protheus.doc} DadosContrato
Função que carrega informacoes do contrato			
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function CarregaDados(oView, cIDView, cField, xValue)


	Local oModel		:= FWModelActive()
	Local oModelUJH 	:= oModel:GetModel("UJHMASTER")
	Local oModelUJI 	:= oModel:GetModel("UJIDETAIL")
	Local lCarenciaTit	:= SuperGetMv("MV_XCARTIT",,.T.)
	Local cCarencia     := ""
	Local dPrimVcto     := cTod("")
	Local nValItem		:= 0
	Local oSX5			:= UGetSxFile():New


	If cField == "UJH_CONTRA" //Chama para atualizar dados do contrato

		UF2->(DbSetOrder(1))

		//Posiciono no contrato e carrego campos
		If UF2->(DbSeek(xFilial("UF2")+xValue))

			UF0->(DbSetOrder(1))

			//Posiciono no plano
			If UF0->(DbSeek(xFilial("UF0")+UF2->UF2_PLANO))

				oModelUJH:LoadValue("UJH_PLANO"     ,UF2->UF2_PLANO )     // Codigo do Plano
				oModelUJH:LoadValue("UJH_DESPLA"    ,UF0->UF0_DESCRI)     // Descricao do Plano

			Endif
		Endif
	ElseIF cField == "UJH_CODBEN" //Chama para carregar dados beneficiario

		//carrego o nome do beneficiario selecionado
		If UF4->(DbSeek(xFilial("UF4")+oModelUJH:GetValue("UJH_CONTRA")+xValue))

			oModelUJH:LoadValue("UJH_NOMBEN"    ,Alltrim(UF4->UF4_NOME) )     // Nome Beneficiario

		Endif

		//caso considere a carencia do titular, sera modificado o xValue para o item do titular do contrato principal
		if lCarenciaTit

			xValue 	:= RetUF4Titular(oModelUJH:GetValue("UJH_CONTRA"))

		endif

		UF4->(DbSetOrder(1))


		If UF4->(DbSeek(xFilial("UF4")+oModelUJH:GetValue("UJH_CONTRA")+xValue))

			//Valido se esta em carencia
			cCarencia := iif(dDataBase <= UF4->UF4_CAREN, "S","N")

			//Atualiza campo de carencia
			oModelUJH:LoadValue("UJH_CAREN"     ,cCarencia              )     // Em Carencia


		Endif

	Elseif cField == "UJH_FORPG"  // Chama para carregar dados de pagamento

		aSX5 := oSX5:GetInfoSX5("24",xValue)

		//Posiciono na forma de pagamento
		if Len(aSX5) > 0

			oModelUJH:LoadValue("UJH_DESFOR" ,Alltrim(aSX5[1,2]:cDESCRICAO)  )     // Descricao da Forma

			//Valido data do primeiro vencimento
			//Se estiver em carencia primeiro vencimento é imediato
			if oModelUJH:GetValue("UJH_CAREN") == "S"

				//Verifico primeiro vencimento considerando se default data+dias
				//para beneficiario em carencia e data valida
				dPrimVcto:= DataValida(DaySum( dDataBase , SuperGetMv("MV_XDIAPRI",,1), .T.))

				//se nao estiver em carencia usa parametro de dias carencia para primeiro vecto
			Else

				dPrimVcto:= DataValida(DaySum( dDataBase , SuperGetMv("MV_XCARPRI",,60), .T.))
			Endif

			//Atualizo campo com a data
			oModelUJH:LoadValue("UJH_DPVENC",dPrimVcto )

		endif

	Elseif cField == "UJH_TABPRC"  // Chama para carregar dados de pagamento

		DA0->(DbSetOrder(1))

		If DA0->(DbSeek(xFilial("DA0")+xValue))

			//Atualiza campo de Tabela de Preco
			oModelUJH:LoadValue("UJH_DESTAB"  ,Alltrim(DA0->DA0_DESCRI)      )     // Em Tabela Preco

		endif

		//Valido se ja foi selecionado Equipamento na grid de itens
		If oModelUJI:Length() > 1 .OR. !Empty(oModelUJI:GetValue("UJI_CHAPA"))

			//Busco preco de tabela do item
			GetTabelaPreco(cField,xValue,oModelUJH,oModelUJI)
		Endif

	Elseif cField == "UJI_CHAPA"

		If !Empty(oModelUJI:GetValue("UJI_CHAPA"))

			//Busco preco de tabela do item
			GetTabelaPreco(cField,oModelUJH:GetValue("UJH_TABPRC"),oModelUJH,oModelUJI)
		Endif
	Elseif cField == "UJI_QUANT"

		//Atualizo total do item
		oModelUJI:LoadValue("UJI_VLTOTA", oModelUJI:GetValue("UJI_QUANT") * oModelUJI:GetValue("UJI_VLUNIT") )

		//Chamo funcao para carregar titulos do contrato convalescencia
		FWMsgRun(,{|oSay| TitulosConvalescencia(oModelUJH:GetValue("UJH_CODIGO"))	},'Aguarde...','Atualizando Resumo Financeiro...')

	Endif

	oView:Refresh()

Return


/*/{Protheus.doc} RefreshTotais
Função que cria o Other Object de Totalizadores
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

Static Function RefreshTotais(oPanel)

	oTotais := ObjResumo():New(oPanel)

//atualizo o totalizador 
	oTotais:RefreshTot()

Return()

/*/{Protheus.doc} ObjResumo
Classe do totalizador
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

	Class ObjResumo

		Data oVlrContratado
		Data oVlrPago
		Data oVlrAtraso
		Data oVlrReceber

		Data nVlrContratado
		Data nVlrPago
		Data nVlrAtraso
		Data nVlrReceber

		//Metodo Construtor da Classe
		Method New() Constructor

		//Metodo para Atualizar os totalizadores da rotina
		Method RefreshTot()

	EndClass

/*/{Protheus.doc} ObjResumo
Método construtor da classe ObjTotal
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/


Method New(oPanel) Class ObjResumo

	Local oPanelCpo		:= NIL
	Local oPanelCont	:= NIL
	Local oPanelEnt		:= NIL
	Local oPanelDesc	:= NIL
	Local oPanelRec		:= NIL
	Local oSay1			:= NIL
	Local oSay2			:= NIL
	Local oModel 		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oFont12N	   	:= TFont():New("Verdana",,12,,.T.,,,,.T.,.F.,.T.) // Fonte 12 Negrito, Itálico
	Local oFont14N	   	:= TFont():New("Verdana",,14,,.T.,,,,.T.,.F.,.F.) // Fonte 14 Negrito
	Local oFont18N	   	:= TFont():New("Verdana",,18,,.T.,,,,.T.,.F.,.T.) // Fonte 28 Negrito
	Local oFontNum	   	:= TFont():New("Verdana",08,18,,.F.,,,,.T.,.F.) ///Fonte 14 Negrito
	Local nHeigth		:= oPanel:nClientHeight / 2
	Local nWhidth		:= oPanel:nClientWidth / 2
	Local nOperation 	:= oModel:GetOperation()
	Local nLin			:= 3
	Local nClrPanes		:= 16777215
	Local nClrSay		:= 7303023
	Local nAltPanels	:= 0


// inicializo os novos totais zerados
	::nVlrContratado	:= 0
	::nVlrPago			:= 0
	::nVlrAtraso		:= 0
	::nVlrReceber		:= 0


//////////////////////////////////////////////////////////
////////////////	PAINEL PRINCIPAL 	/////////////////
/////////////////////////////////////////////////////////

	@ 002, 002 MSPANEL oPanelCpo SIZE nWhidth - 2 , nHeigth -2 OF oPanel COLORS 0, 12961221

	nAltPanels := INT(nHeigth - nLin - 4) / 4


/////////////////////////////////////////////////////////////////
////////////////	PANEL VALOR CONTRATADO		////////////////
////////////////////////////////////////////////////////////////


	@ nLin , 002 MSPANEL oPanelCont SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay1 PROMPT "Valor Contratado" SIZE nWhidth - 6, 015 OF oPanelCont FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay2 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPanelCont FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 001 SAY oSay5 PROMPT "R$" SIZE 045, 010 OF oPanelCont FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 001 SAY ::oVlrContratado PROMPT AllTrim(Transform(::nVlrContratado,"@E 999,999.99")) SIZE 45, 010 OF oPanelCont FONT oFontNum COLORS 0, 16777215 PIXEL CENTER


	nLin += nAltPanels

/////////////////////////////////////////////////////////////////
////////////////	PANEL VALOR TOTAL PAGO		////////////////
////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPanelEnt SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay1 PROMPT "Valor Pago" SIZE nWhidth - 6, 015 OF oPanelEnt FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay2 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPanelEnt FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 001 SAY oSay5 PROMPT "R$" SIZE 045, 010 OF oPanelEnt FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 001 SAY ::oVlrPago PROMPT AllTrim(Transform(::nVlrPago,"@E 999,999.99")) SIZE 45, 010 OF oPanelEnt FONT oFontNum COLORS 0, 16777215 PIXEL CENTER


	nLin += nAltPanels

/////////////////////////////////////////////////////////////////
////////////////	PANEL VALOR DESCONTO		////////////////
////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPanelDesc SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay1 PROMPT "Valor em Atraso" SIZE nWhidth - 6, 015 OF oPanelDesc FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay2 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPanelDesc FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 001 SAY oSay5 PROMPT "R$" SIZE 045, 010 OF oPanelDesc FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 001 SAY ::oVlrAtraso PROMPT AllTrim(Transform(::nVlrAtraso,"@E 999,999.99")) SIZE 45, 010 OF oPanelDesc FONT oFontNum COLORS 0, 16777215 PIXEL CENTER


	nLin += nAltPanels

/////////////////////////////////////////////////////////////////
////////////////	PANEL VALOR RECEBER			////////////////
////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPanelRec SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay1 PROMPT "Valor a Receber" SIZE nWhidth - 6, 015 OF oPanelRec FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay2 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPanelRec FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 001 SAY oSay5 PROMPT "R$" SIZE 045, 010 OF oPanelRec FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 001 SAY ::oVlrReceber PROMPT AllTrim(Transform(::nVlrReceber,"@E 999,999.99")) SIZE 45, 010 OF oPanelRec FONT oFontNum COLORS 0, 16777215 PIXEL CENTER


Return()

/*/{Protheus.doc} ObjResumo
Método Refresh do Totais da Convalescencia
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

Method RefreshTot(cAcao,nLinha) Class ObjResumo

	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUJH 	:= oModel:GetModel("UJHMASTER")
	Local oModelUJI 	:= oModel:GetModel("UJIDETAIL")
	Local oModelSE1 	:= oModel:GetModel("SE1DETAIL")
	Local nLinhaSE1		:= oModelSE1:GetLine()
	Local nLinhaUJI		:= oModelUJI:GetLine()
	Local nOperation 	:= oModel:GetOperation()

	Local nI			:= 0
	Local lLimpa		:= .T.
	Default cAcao		:= ""
	Default nLinha		:= 1

	::nVlrContratado	:= 0
	::nVlrPago		 	:= 0
	::nVlrAtraso		:= 0
	::nVlrReceber		:= 0


//Atualizando o valor contratado
	For nI := 1 To oModelUJI:Length()

		oModelUJI:Goline(nI)

		If cAcao == 'DELETE' .AND. nI == nLinha

			Loop

		Elseif !oModelUJI:IsDeleted()

			if oModelUJH:GetValue("UJH_STATUS") == "D" .Or. Empty(oModelUJI:GetValue("UJI_DATARE"))

				::nVlrContratado += oModelUJI:GetValue("UJI_VLUNIT")

			endif

			lLimpa:= 	.F.

		Endif
	Next nI

//Se nao ficou nenhum registro apaga linhas da SE1
	if ::nVlrContratado == 0

		// se a operação for inclusão, limpo o grid, senão deleto todas as linhas
		if nOperation == MODEL_OPERATION_INSERT .AND. !Empty(oModelUJH:GetValue("UJH_CONTRA")) .AND. lLimpa

			// função que deleta todas as linhas do grid
			oModelSE1:DelAllLine(.T.)

		endif
	Endif

//Atualizando resumo financeiro
	For nI := 1 To oModelSE1:Length()

		oModelSE1:Goline(nI)

		If !oModelSE1:IsDeleted()

			//Posiciono no titulo
			if oModelSE1:GetValue("E1_SALDO")  == 0 //Titulo baixao

				::nVlrPago += oModelSE1:GetValue("E1_VALOR")

			Else

				//Valido se titulo esta vencido
				if oModelSE1:GetValue("E1_VENCTO") < dDataBase

					::nVlrAtraso  += oModelSE1:GetValue("E1_SALDO")

				Endif

				::nVlrReceber += oModelSE1:GetValue("E1_SALDO")
			endif

		Endif

	Next nI


//atualizo totalizadores
	::oVlrContratado:Refresh()
	::oVlrPago:Refresh()
	::oVlrAtraso:Refresh()
	::oVlrReceber:Refresh()


//nao atualizo os campos quando for chamado na criacao da tela
	if !IsInCallStack("RefreshTotais")

		//Atualizo o campo totalizar do cabecalho
		oModelUJH:LoadValue("UJH_VALCON",::nVlrContratado)

	endif


	oModelSE1:GoLine(nLinhaSE1)
	oModelUJI:GoLine(nLinhaUJI)

Return()

/*/{Protheus.doc} TitulosConvalescencia
Funcao carregar titulos na grid de resumo financeiro
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

Static Function TitulosConvalescencia(cCodConvale)

	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUJH 	:= oModel:GetModel("UJHMASTER")
	Local oModelUJI 	:= oModel:GetModel("UJIDETAIL")
	Local oModelSE1 	:= oModel:GetModel("SE1DETAIL")
	Local nOperation 	:= oModel:GetOperation()
	Local nI			:= 1
	Local nVlrTotal		:= 0
	Local nQtdParcela	:= SuperGetMv("MV_XPCONVA",,12) // Qtde Parcelas gerados no convalescencia
	Local cPrefixo		:= SuperGetMv("MV_XPRFCON",,"CVL") //Prefixo do titulo de convalescencia
	Local cTipo			:= SuperGetMv("MV_XTIPOCV",,"EQ")  //Tipo do titulo de convalescencia
	Local cStatus		:= oModelUJH:GetValue("UJH_STATUS")//Status do processamento
	Local cContrato		:= oModelUJH:GetValue("UJH_CONTRA")
	Local cQry 			:= ""
	Local dVencimento	:= oModelUJH:GetValue("UJH_DPVENC")//Data Primeiro vencimento

	UF2->(DbSetOrder(1))
	SE1->(DbSetOrder(1))

//Desabilita bloqueio para inserir linha
	oModel:GetModel('SE1DETAIL'):SetNoInsertLine(.F.)

	if nOperation == 3 .OR. cStatus == "A" .OR. cStatus == "D"

		//Posiciono no contrato para pegar cliente
		if UF2->(DbSeek(xFilial("UF2")+cContrato))

			cNomeCliente := Posicione("SA1",1,xFilial("SA1")+UF2->UF2_CLIENT+UF2->UF2_LOJA,"A1_NOME")

			For nI := 1 to oModelUJI:Length()

				oModelUJI:Goline(nI)

				If !oModelUJI:IsDeleted()

					//Somo valor total que o cliente deverá pagar
					nVlrTotal += oModelUJI:GetValue("UJI_VLUNIT")
				Endif
			Next nI

			//se ja tiver gerado as linhas do parcelas somente atualizo o valor
			if oModelSE1:Length(.T.) > 1

				oModelSE1:GoLine(1)

				For nI := 1 to oModelSE1:Length()

					oModelSE1:GoLine(nI)

					If !oModelSE1:IsDeleted()

						//Atualizo o valor da parcela
						oModelSE1:LoadValue("E1_SALDO", nVlrTotal)
					Endif
				Next nI

			Else

				For nI := 1 to nQtdParcela


					//Valido se a primeira linha esta preenchida
					If !Empty(oModelSE1:GetValue("E1_NUM"))

						oModelSE1:AddLine(.T.)
						oModelSE1:GoLine(oModelSE1:Length())
					Endif

					//Valido se foi retornado equipamentos
					if cStatus == "D"

						//Se ja foi retornado verifico se titulo existe na base ou ja foi excluido
						If SE1->(DbSeek(xFilial("SE1")+cPrefixo+PADR(cCodConvale,TamSX3("E1_NUM")[1])+StrZero(oModelSE1:Length(),TamSx3("E1_PARCELA")[1])+cTipo ))

							//Legenda do titulo
							If SE1->E1_SALDO == 0 									  			//Titulo baixado

								oModelSE1:LoadValue("E1_XLEGEND"	,"BR_VERMELHO")

							Elseif  SE1->E1_SALDO > 0 .AND. SE1->E1_VENCREA < dDataBase			//Titulo em atraso

								oModelSE1:LoadValue("E1_XLEGEND"	,"BR_AMARELO")

							Else

								oModelSE1:LoadValue("E1_XLEGEND"	,"BR_VERDE")				//Titulo em Aberto
							Endif

							nVlrTotal := SE1->E1_SALDO

						Else

							oModelSE1:LoadValue("E1_XLEGEND"	,"BR_PRETO"					)  //Titulo excluido
						Endif
					Else

						//Carrego os titulos a receber
						oModelSE1:LoadValue("E1_XLEGEND"	,"BR_VERDE"					)  //Legenda do titulo
					Endif

					oModelSE1:LoadValue("E1_PREFIXO"	,cPrefixo					)  //Prefixo
					oModelSE1:LoadValue("E1_NUM"		,cCodConvale				)  //Num
					oModelSE1:LoadValue("E1_PARCELA"	,StrZero(oModelSE1:Length(.T.),TamSx3("E1_PARCELA")[1]))  //Parcela
					oModelSE1:LoadValue("E1_TIPO"		,cTipo						) 	//parcela
					oModelSE1:LoadValue("E1_CLIENTE"	,Alltrim(UF2->UF2_CLIENT)	) 	//Cliente
					oModelSE1:LoadValue("E1_LOJA"		,Alltrim(UF2->UF2_LOJA)		) 	//Loja
					oModelSE1:LoadValue("E1_XNOME"		,Alltrim(cNomeCliente)		)	//Nome Cliente
					oModelSE1:LoadValue("E1_EMISSAO"	,dDataBase					)   //Data Emissao

					//Valido se é a primeira parcela
					If oModelSE1:Length() == 1
						oModelSE1:LoadValue("E1_VENCTO"	,dVencimento)   //Data Emissao

					Else

						dVencimento := DataValida(DaySum( dVencimento , 30, .T.))
						oModelSE1:LoadValue("E1_VENCTO"   ,dVencimento)
					Endif

					oModelSE1:LoadValue("E1_VALOR"	, nVlrTotal	) 		//valor Parcela
					oModelSE1:LoadValue("E1_SALDO"	, nVlrTotal	) 		//Saldo Parcela

				Next nI

				oModelSE1:GoLine(1)
			Endif
		Endif

	Else // se Convalescencia foi feito remessa

		cQry := " SELECT " 												+ cPulaLinha
		cQry += " 	SE1.E1_NUM," 										+ cPulaLinha
		cQry += " 	SE1.E1_PREFIXO," 									+ cPulaLinha
		cQry += " 	SE1.E1_PARCELA," 									+ cPulaLinha
		cQry += " 	SE1.E1_TIPO," 										+ cPulaLinha
		cQry += " 	SE1.E1_CLIENTE," 									+ cPulaLinha
		cQry += " 	SE1.E1_LOJA," 										+ cPulaLinha
		cQry += " 	SE1.E1_EMISSAO," 									+ cPulaLinha
		cQry += " 	SE1.E1_VENCTO,"										+ cPulaLinha
		cQry += " 	SE1.E1_VENCREA,"									+ cPulaLinha
		cQry += " 	SE1.E1_SALDO,"										+ cPulaLinha
		cQry += " 	SE1.E1_VALOR,"										+ cPulaLinha
		cQry += " 	SA1.A1_NOME"										+ cPulaLinha
		cQry += " FROM " 												+ cPulaLinha
		cQry += " " + RetSqlName("SE1") + " SE1 "						+ cPulaLinha
		cQry += " INNER JOIN "											+ cPulaLinha
		cQry += " " + RetSqlName("SA1")+ " SA1"							+ cPulaLinha
		cQry += " ON A1_FILIAL = '" + xFilial("SA1") + "'"				+ cPulaLinha
		cQry += " AND A1_COD   = E1_CLIENTE	"							+ cPulaLinha
		cQry += " AND A1_LOJA  = E1_LOJA	"							+ cPulaLinha
		cQry += " AND SA1.D_E_L_E_T_ = ' '  "							+ cPulaLinha
		cQry += " WHERE " 												+ cPulaLinha
		cQry += " SE1.D_E_L_E_T_	<> '*' " 							+ cPulaLinha
		cQry += " AND SE1.E1_FILIAL 	= '" + xFilial("SE1") + "' " 	+ cPulaLinha
		cQry += " AND SE1.E1_XCONCTR	= '" + cCodConvale	  + "' "    + cPulaLinha
		cQry += " AND SE1.E1_XCTRFUN	= '" + cContrato 	  + "' "	+ cPulaLinha
		cQry += " AND SE1.E1_TIPO NOT IN ('AB-','FB-','FC-','FU-' " 	+ cPulaLinha
		cQry += " ,'PR','IR-','IN-','IS-','PI-','CF-','CS-','FE-' "		+ cPulaLinha
		cQry += " ,'IV-','RA','NCC','NDC') "							+ cPulaLinha

		cQry := ChangeQuery(cQry)

		If Select("QSE1") >1
			QSE1->(DbCloseArea())
		Endif

		TcQuery cQry New Alias "QSE1"

		While QSE1->(!EOF())

			//Valido se a primeira linha esta preenchida
			If !Empty(oModelSE1:GetValue("E1_NUM"))

				oModelSE1:AddLine(.T.)
				oModelSE1:GoLine(oModelSE1:Length())
			Endif

			//Legenda do titulo
			If QSE1->E1_SALDO == 0 //Titulo baixado

				oModelSE1:LoadValue("E1_XLEGEND"	,"BR_VERMELHO")

			Elseif  QSE1->E1_SALDO > 0 .AND. QSE1->E1_VENCREA < dTos(dDataBase)	//Titulo em atraso

				oModelSE1:LoadValue("E1_XLEGEND"	,"BR_AMARELO")

			Else

				oModelSE1:LoadValue("E1_XLEGEND"	,"BR_VERDE")				//Titulo em Aberto
			Endif


			//Carrego os titulos a receber

			oModelSE1:LoadValue("E1_PREFIXO"	,QSE1->E1_PREFIXO			)  //Prefixo
			oModelSE1:LoadValue("E1_NUM"		,QSE1->E1_NUM				)  //Num
			oModelSE1:LoadValue("E1_PARCELA"	,QSE1->E1_PARCELA			)  //Parcela
			oModelSE1:LoadValue("E1_TIPO"		,QSE1->E1_TIPO				)  //parcela
			oModelSE1:LoadValue("E1_CLIENTE"	,QSE1->E1_CLIENTE			)  //Cliente
			oModelSE1:LoadValue("E1_LOJA"		,QSE1->E1_LOJA				)  //Loja
			oModelSE1:LoadValue("E1_XNOME"		,QSE1->A1_NOME				)  //Nome Cliente
			oModelSE1:LoadValue("E1_EMISSAO"	,sTod(QSE1->E1_EMISSAO)		)  //Data Emissao
			oModelSE1:LoadValue("E1_VENCTO"		,sTod(QSE1->E1_VENCTO)		)  //Vencimento
			oModelSE1:LoadValue("E1_VALOR"		,QSE1->E1_VALOR				)  //valor Parcela
			oModelSE1:LoadValue("E1_SALDO"		,QSE1->E1_SALDO				)  //Saldo Titulo

			QSE1->(DbSkip())
		EndDo

		oModelSE1:GoLine(1)
	Endif

//Atualizo totalizadores
	oTotais:RefreshTot()

//Retorno bloqueio para inserir linha
	oModel:GetModel('SE1DETAIL'):SetNoInsertLine(.T.)
	oView:Refresh()

Return



/*/{Protheus.doc} UnDelGrid
Função chamada na Undeleção da linha dos grids
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function UnDelGrid( oView,cIdView,nNumLine )

	Local aArea := GetArea()

	if AllTrim(cIdView) == "UJIDETAIL"

		// chamo função que atualiza os Totalizadores
		oTotais:RefreshTot()

	endif

	RestArea(aArea)

Return()


/*/{Protheus.doc} ValDelLinha
Função no delete da linha de produtos
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function ValDelLinha(oModelGrid,nLinha,cAcao,cCampo)


	Local lRet   		:= .T.
	Local oModel		:= FWModelActive()
	Local oModelUJI		:= oModel:GetModel("UJIDETAIL")
	Local cChapaTroca	:= oModelUJI:GetValue("UJI_CHAPAT")
	Local dDataDev		:= oModelUJI:GetValue("UJI_DATARE")
	Local nOperation 	:= oModel:GetOperation()


//Valida se pode ou não deletar uma linha do Grid se tiver gravado troca ou foi devolvido
	If cAcao == 'DELETE'  .AND. !IsInCallStack("RefreshTotais")

		If nOperation == 3 .OR. nOperation == 4

			//se nao tiver gravado troca ou foi devolvido
			if Empty(cChapaTroca) .OR. Empty(dDataDev)

				//Atualiza o resumo
				oTotais:RefreshTot(cAcao,nLinha)

			Else

				Help( ,, 'DELETE',, 'Exclusão permitida somente para itens que não foram trocados ou devolvidos.', 1, 0 )
				lRet := .F.
			Endif
		Endif
	EndIf

Return lRet

/*/{Protheus.doc} GerarRemessa
Função para gerar a Remessa do contrato Convalescencia
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

User Function GerarRemessa()

	Local lRet := .T.


//Valido se financeiro ja foi gerado
	If UJH->UJH_STATUS != "A"
		Help( ,, 'Help',, 'Rotina permitida somente para registros com Status Aguardando Remessa.', 1, 0 )
		lRet := .F.
	Endif

	If lRet
		Begin Transaction

			//Chamo funcao que vai fazer remessa de bens em terceiro
			FWMsgRun(,{|oSay| lRet := U_GeraBensTeceiro(oSay)	},'Aguarde...','Gerando Controle de Bens em Terceiro...')'

			If lRet

				//Chamo funcao que vai gerar o financeiro da convalescencia
				FWMsgRun(,{|oSay| lRet := GeraFinanceiro(oSay)	},'Aguarde...','Gerando Titulos a Receber Convalescencia...')

				If lRet

					//Atualizo o status do registro
					If Reclock("UJH",.F.)

						UJH->UJH_STATUS := 	"L" // Remessa Realizada
						UJH->(MsUnLock())
					Endif
				Else
					DisarmTransaction()
				Endif
			else
				DisarmTransaction()
			Endif

		End Transaction
	Endif

Return

/*/{Protheus.doc} ResumoFin
Função para Carregar resumo funanceiro
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

Static Function ResumoFin()

	Local oView		 := FWViewActive()
	Local oModel  	 := FWModelActive()
	Local oModelUJH	 := oModel:GetModel("UJHMASTER")
	Local nOperation := oModel:GetOperation()

//Se nao for inclusao
	if nOperation != 3 .AND. nOperation != 5

		//Chamo rotina para carregar grid de titulos
		TitulosConvalescencia(oModelUJH:GetValue("UJH_CODIGO"))
	Endif

Return

/*/{Protheus.doc} GeraFinanceiro
Função para gerar titulos a receber no financeiro
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function GeraFinanceiro(oSay)


	Local dVencimento	:= UJH->UJH_DPVENC
	Local cParcela		:= ""
	Local cNatureza 	:= &(SuperGetMV("MV_NATCONV"))
	Local cTipo			:= Alltrim(SuperGetMv("MV_XTIPOCV",,"EQ" )) //Tipo do titulo de convalescencia
	Local cPrefixo		:= Alltrim(SuperGetMv("MV_XPRFCON",,"CVL")) //Prefixo do titulo de convalescencia
	Local nQtdParcela	:= SuperGetMv("MV_XPCONVA",,12)    // Qtde Parcelas gerados no convalescencia
	Local nI			:= 1
	Local lRet			:= .T.

	Private lMsErroAuto	:= .F.

	UF2->(DbSetOrder(1))

//Inicia controle da transacao
	Begin Transaction

		//Posiciono no contrato
		If UF2->(DbSeek(xFilial("UF2")+UJH->UJH_CONTRA))

			For nI := 1 To nQtdParcela

				oSay:cCaption := "Gerando Titulos a Receber Convalescencia Parcela "+ cValToChar(nI) +"..."
				ProcessMessages()

				lMsErroAuto	:= .F.

				//Pego vencimento da parcela
				if nI > 1
					dVencimento := DataValida(DaySum( dVencimento , 30, .T.))
				Endif

				//Proxima parcela
				cParcela := StrZero(nI,TamSx3("E1_PARCELA")[1])

				//preparo array dos titulos
				aTitulos := {	{ "E1_PREFIXO"  , cPrefixo					  					, NIL },;
					{ "E1_NUM"      , UJH->UJH_CODIGO			    				, NIL },;
					{ "E1_PARCELA"  , cParcela										, NIL },;
					{ "E1_TIPO"     , PADR(cTipo, TamSx3("E1_TIPO")[1])        		, NIL },;
					{ "E1_NATUREZ"  , cNatureza          							, NIL },;
					{ "E1_CLIENTE"  , UF2->UF2_CLIENT								, NIL },;
					{ "E1_LOJA"     , UF2->UF2_LOJA									, NIL },;
					{ "E1_EMISSAO"  , dDataBase										, NIL },;
					{ "E1_VENCTO"   , dVencimento									, NIL },;
					{ "E1_VALOR"    , UJH->UJH_VALCON								, NIL },;
					{ "E1_XCTRFUN"  , UF2->UF2_CODIGO								, NIL },;
					{ "E1_XFORPG"   , UJH->UJH_FORPG								, NIL },;
					{ "E1_XCONCTR"  , UJH->UJH_CODIGO								, NIL },;
					{ "E1_XPARCON"	, cParcela + "/" + StrZero(nQtdParcela,3)  		, Nil } }


				MsExecAuto( { |x,y| FINA040(x,y)} , aTitulos, 3)

				If lMsErroAuto

					Help( ,, 'Help',, 'Falha inclusão Titulo a Receber.', 1, 0 )
					MostraErro()
					DisarmTransaction()
					lRet := .F.
					Exit
				Endif

			Next nI

		Endif
	End Transaction


Return lRet

/*/{Protheus.doc} GeraBensTeceiro
Função para gravar o controle de bens em terceiro
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
User Function GeraBensTeceiro(oSay,oModelUJI)

	Local cContato  := ""
	Local cCodigo   := ""
	Local cChapa    := ""
	Local cDescricao:= ""
	Local cLocal	:= ""
	Local nItem 	:= 0
	Local nVlUnit	:= 0
	Local lRet		:= .T.
	Local nI		:= 1

	SN1->(DbSetOrder(2))
	UJI->(DbSetOrder(1))
	UF2->(DbSetOrder(1))

//Posiciono no contrato 
	If UF2->(DbSeek(xFilial("UF2")+UJH->UJH_CONTRA))

		///Se nao foi chamado da rotina de troca
		If !IsInCallStack("TrocaBensTerceiro")

			//Nome do Contato que sera usado
			cContato := Posicione("SA1",1,xFilial("SA1")+UF2->UF2_CLIENT+UF2->UF2_LOJA,"A1_NOME")

			//Posiciono nos itens do convalescencia
			If UJI->(DbSeek(xFilial("UJI")+UJH->UJH_CODIGO))

				While UJI->(!EOF()) ;
						.AND. UJI->UJI_FILIAL+UJI->UJI_CODIGO == xFilial("UJH")+UJH->UJH_CODIGO

					//somente itens que ainda nao gerou controle de terceiro
					If Empty(UJI->UJI_CODTER)

						//Pego Proxima Numeracao disponivel
						cCodigo := GETSXENUM('SNP','NP_CODIGO')

						//Sequencia do Item
						nItem++

						//Confirma gravacao
						lRet := GravaControle(cCodigo,UJI->UJI_CHAPA,nItem,cContato)

						If !lRet
							Exit
						Else

							//Confirmo controle de numeracao
							ConfirmSx8()

							//Gravo codigo do controle de Bens em terceitos
							If Reclock("UJI",.F.)
								UJI->UJI_CODTER	:= cCodigo
								UJI->(MsUnLock())
							Endif

						Endif
					Endif

					UJI->(DbSKip())
				EndDo
			Endif

			/////////////////////////////////////////////////////////////////////////////////////
			// ------------------------TROCA DE EQUIPAMENTO	-----------------------------------//
			/////////////////////////////////////////////////////////////////////////////////////
		Else

			//Gera novo contro de terceiro no item da troca
			For nI := 1 to oModelUJI:Length()

				oModelUJI:GoLine(nI)

				If !oModelUJI:IsDeleted()

					//Valido item que esta sendo trocado
					If !Empty(oModelUJI:GetValue("UJI_CHAPAT")) .AND. Empty(oModelUJI:GetValue("UJI_DATARE"))

						//Pego Proxima Numeracao disponivel
						cCodigo := GETSXENUM('SNP','NP_CODIGO')

						//Confirma gravacao
						lRet := GravaControle(cCodigo,oModelUJI:GetValue("UJI_CHAPAT"),nI,cContato)

						If !lRet

							Exit
						Else

							//Confirmo controle de numeracao
							ConfirmSx8()

							//Gravo codigo do controle de Bens em terceitos
							oModelUJI:LoadValue("UJI_CODTER", cCodigo)

							//Salvo dados para inclusao da nova chapa
							cChapa 		:= oModelUJI:GetValue("UJI_CHAPAT")
							cDescricao	:= Alltrim(Posicione("SN1",2,xFilial("SN1")+cChapa,"N1_DESCRIC"))
							cLocal		:= oModelUJI:GetValue("UJI_LOCAL" )
							nVlUnit		:= oModelUJI:GetValue("UJI_VLUNIT")

							//Gravo novo registro com a nova chapa
							oModelUJI:AddLine(.T.)
							oModelUJI:GoLine(oModelUJI:Length())

							//Pego sequencia de item
							nItem := MaxItem(cCodigo)

							//Inclui novo item de locacao no controle de convalescencia
							oModelUJI:LoadValue("UJI_CODIGO", cCodigo						 	 )
							oModelUJI:LoadValue("UJI_ITEM"	, StrZero(nItem,TamSx3("UJI_ITEM")[1]))
							oModelUJI:LoadValue("UJI_CHAPA"	, cChapa							 )
							oModelUJI:LoadValue("UJI_DESC"	, cDescricao						 )
							oModelUJI:LoadValue("UJI_LOCAL"	, cLocal			  				 )
							oModelUJI:LoadValue("UJI_QUANT"	, 1									 )
							oModelUJI:LoadValue("UJI_VLUNIT", nVlUnit			 				 )
							oModelUJI:LoadValue("UJI_VLTOTA", nVlUnit							 )
							oModelUJI:LoadValue("UJI_DATAIN", dDataBase							 )
							oModelUJI:LoadValue("UJI_CODTER", cCodigo							 )


						Endif
					Endif
				Endif
			Next nI
		Endif
	Endif


Return lRet


/*/{Protheus.doc} RetornoRemessa
Função para fazer o retorno de locacao bens
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
User Function RetornoRemessa(cIdRotina)

	Local bExecRot 		:= {|| iif(cIdRotina == "RETORNO",UFUNA043OK(),TrocaBensTerceiro()) }
	Static cRotina		:= ""

	//valido o status do registro
	If UJH->UJH_STATUS == "L" .OR. UJH->UJH_STATUS == "P" // Remessa realizada ou Retorno Parcial

		cRotina := cIdRotina

		//Faz execução da rotina de retorno e troca
		FWExecView(cRotina,'RFUNA044', MODEL_OPERATION_UPDATE,, { || .T. },bExecRot)


	Else

		Help( ,, 'RETORNO',, 'Status atual não permite Troca ou Retorno.', 1, 0 )
	Endif


Return

/*/{Protheus.doc} UFUNA043OK
Função no Botao Ok da tela para processar retorno/troca
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function UFUNA043OK()

	Local oView		 	:= FWViewActive()
	Local oModel  	 	:= FWModelActive()
	Local oModelUJH	 	:= oModel:GetModel("UJHMASTER")
	Local oModelUJI	 	:= oModel:GetModel("UJIDETAIL")
	Local lRet 			:= .F.
	Local lRetTotal		:= .T.
	Local nValRetorno	:= 0
	Local cCodigo		:= oModelUJH:GetValue("UJH_CODIGO")
	Local cContrato		:= oModelUJH:GetValue("UJH_CONTRA")

	Begin transaction

		FWMsgRun(,{|oSay| lRet := RetornaBensTerceiro(oModelUJI,@lRetTotal,@nValRetorno)	},'Aguarde...','Retorno Bens em Terceiro..')

		//Valido se estorno financeiro foi processado com sucesso
		If lRetTotal
			oModelUJH:LoadValue("UJH_STATUS","D") // Retorno Total Realizada
		Else
			oModelUJH:LoadValue("UJH_STATUS","P") // Retorno parcial Realizada

			FwFldPut("UJH_VALCON" ,nValRetorno,,,,.T.)
		Endif

		//Valido se retorno do bem foi processado com sucesso
		If lRet

			//-- Valido se o contrato esta em cobranca --//
			If !U_VldCobranca(SE1->E1_FILIAL, cContrato, cCodigo)
				MsgInfo("O Contrato possui titulos em cobrança, operação cancelada.","Atenção")
				DisarmTransaction()
				lRet := .F.
			Else
				FWMsgRun(,{|oSay| lRet := RetornaFinanceiro(oModelUJH,oSay,nValRetorno)	},'Aguarde...','Estornando titulos de Convalescencia ...')

				If !lRet

					//se retornou erro no estorno interrompe a transacao
					DisarmTransaction()
					Help(" ",1,"Retorno",,"Retorno falhou.",1,0)
				Else
					//Se nao foi retorno parcial grava retorno total da locacao
					If nValRetorno == 0

						oModelUJH:LoadValue("UJH_DATARE", dDataBase	)  //Data Retorno
					Endif
				Endif
			EndIf
		Endif

	End Transaction


Return lRet


/*/{Protheus.doc} RetornaBensTerceiro
Função que faz processo de retorno do equipamento 
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function RetornaBensTerceiro(oModelUJI,lRetTotal,nValRetorno)

	Local nI		 := 1
	Local lRet		 := .F.

	SNP->(dbSetOrder(1))
	SN1->(DBSetOrder(2))

	Begin Transaction

		For nI := 1 to oModelUJI:Length()

			oModelUJI:GoLine(nI)


			If !Empty(oModelUJI:GetValue("UJI_CODTER"))

				//Valido se item nao foi retornado
				If Empty(oModelUJI:GetValue("UJI_DATARE") ) .AND. oModelUJI:GetValue("UJI_OK")

					//Posiciono no item para retornar
					If SNP->(dbSeek(xFilial("SNP")+oModelUJI:GetValue("UJI_CODTER")  ) )

						//Atualizo o status para Encerrado
						If RecLock("SNP",.F.)

							SNP->NP_STATUS := '2' 			//Encerrado
							SNP->NP_VIGFIM := dDataBase		//Atualiza fim da vigencia
							SNP->(MsUnLock())

						Endif

						//Atualizo dados do Bem para permitir nova locacao
						If SN1->(DbSeek(xFilial("SN1")+oModelUJI:GetValue("UJI_CHAPA")))

							If RecLock("SN1",.F.)

								SN1->N1_TPCTRAT:= "1"
								SN1->N1_FORNEC	:= ''
								SN1->N1_LOJA	:= ''
								SN1->(MsUnLock())
							Endif
						Else

							Help(" ",1,"Retorno",,"Codigo Bem em Terceiro nao foi localizado.",1,0)
							DisarmTransaction()
							lRet := .F.
							Exit
						Endif

						//Atualizo data do retorno da rotina convalescencia
						oModelUJI:LoadValue("UJI_DATARE", dDataBase	)  //Data Retorno
						oModelUJI:LoadValue("UJI_MOTRET",iif(!IsInCallStack("TrocaBensTerceiro"),"1","2"))  //Motivo retorno

						lRet := .T.

					Else

						Help(" ",1,"Retorno",,"Codigo Bem em Terceiro nao foi localizado.",1,0)
						lRet := .F.
						Exit

					Endif

					//Valido se ficara algum item sem retorno para atualizar status com parcial
				ElseIf !oModelUJI:GetValue("UJI_OK") .AND. Empty(oModelUJI:GetValue("UJI_DATARE"))

					//Salvo valor para ajustar titulos financeiro
					nValRetorno	+= oModelUJI:GetValue("UJI_QUANT") * oModelUJI:GetValue("UJI_VLUNIT")
					lRetTotal 	:= .F.
				Endif
			Endif

		Next nI

	End Transaction

Return lRet

/*/{Protheus.doc} RetornaFinanceiro
Função que faz processo de retorno financeiro
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function RetornaFinanceiro(oModelUJH,oSay,nValRetorno)

	Local lRet 				:= .T.
	Local cQry 				:= ""
	Local cCodigo			:= oModelUJH:GetValue("UJH_CODIGO")
	Local cContrato			:= oModelUJH:GetValue("UJH_CONTRA")
	Local dDataPrim 		:= oModelUJH:GetValue("UJH_DPVENC")
	Local aTitulos			:= {}
	Local nOperacao			:= 5
	Local nQtdParcela		:= SuperGetMv("MV_XPCONVA",,12) 	// Qtde Parcelas gerados no convalescencia
	Local nVlrParcela		:= 0
	Local cTipoEstorno		:= SuperGetMv("MV_XTPESTC",,"3")	// Tipo de Estorno de parcelas
	Local nConsDiasVenc 	:= SuperGetMv("MV_XVENCCO",,1)		// Quantos dias de vencimento considera no estorno das parcelas

	Private lMsErroAuto	:= .F.

	//Busco titulo que deverao ser extornados considerado titulos fora mes atual
	cQry := " SELECT " 														+ cPulaLinha
	cQry += " 	SE1.R_E_C_N_O_ RECSE1"										+ cPulaLinha
	cQry += " FROM " 														+ cPulaLinha
	cQry += " " + RetSqlName("SE1") + " SE1 "								+ cPulaLinha
	cQry += " WHERE " 														+ cPulaLinha
	cQry += " SE1.D_E_L_E_T_	 <> '*' " 									+ cPulaLinha
	cQry += " AND SE1.E1_SALDO 	 > 0"										+ cPulaLinha
	cQry += " AND SE1.E1_FILIAL  = '" + xFilial("SE1") + "' " 				+ cPulaLinha
	cQry += " AND SE1.E1_XCONCTR = '" + cCodigo		  + "' "    			+ cPulaLinha
	cQry += " AND SE1.E1_XCTRFUN = '" + cContrato 	  + "' "				+ cPulaLinha

	//Valido se devolucao esta ocorrendo em periodo de carencia de pagamento
	//se estiver estorna todos os titulos se nao somente a vencer fora do mes vigente
	if dDataBase > dDataPrim

		//Considera Mês no momento do estorno das parcelas
		if cTipoEstorno == "1"
			cQry += " AND SE1.E1_VENCREA > '" + dTos(LastDay(dDataBase))  + "' 		"+ cPulaLinha
		elseif cTipoEstorno == "2"
			cQry += " AND SE1.E1_VENCREA > '" + dTos(dDataBase)  		  + "' 		"+ cPulaLinha
		elseif cTipoEstorno == "3"
			cQry += " AND SE1.E1_VENCREA >= '" + dTos(DaySub(dDataBase,nConsDiasVenc))  	+ "' "+ cPulaLinha
		endif
	Endif

	cQry += " AND SE1.E1_TIPO NOT IN ('AB-','FB-','FC-','FU-' " 			+ cPulaLinha
	cQry += " ,'PR','IR-','IN-','IS-','PI-','CF-','CS-','FE-' "				+ cPulaLinha
	cQry += " ,'IV-','RA','NCC','NDC') "									+ cPulaLinha

	cQry := ChangeQuery(cQry)

	If Select("QSE1") >1
		QSE1->(DbCloseArea())
	Endif

	TcQuery cQry New Alias "QSE1"

	While QSE1->(!EOF())

		//Posicionando no titulo
		SE1->(DbGoTo(QSE1->RECSE1))

		oSay:cCaption := "Estornando Titulos a Receber Convalescencia Parcela "+ SE1->E1_PARCELA +"..."
		ProcessMessages()

		//-- Remove o título do bordero --//
		U_ExcBord(QSE1->RECSE1)

		lMsErroAuto := .F.
		aTitulos	:= {}

		AAdd(aTitulos, {"E1_FILIAL"  , SE1->E1_FILIAL  	,Nil})
		AAdd(aTitulos, {"E1_PREFIXO" , SE1->E1_PREFIXO 	,Nil})
		AAdd(aTitulos, {"E1_NUM"     , SE1->E1_NUM	   	,Nil})
		AAdd(aTitulos, {"E1_PARCELA" , SE1->E1_PARCELA	,Nil})
		AAdd(aTitulos, {"E1_TIPO"    , SE1->E1_TIPO  	,Nil})

		//Se foi parcial ajusta valor do titulo
		If nValRetorno > 0

			nVlrParcela	:= Round(nValRetorno,TamSx3("E1_VALOR")[2])

			AAdd(aTitulos, {"E1_VALOR"  , nVlrParcela 	,Nil})

			//troca operacao para ajustar titulo
			nOperacao := 4
		Endif

		MSExecAuto({|x,y| Fina040(x,y)},aTitulos,nOperacao)

		If lMsErroAuto
			MostraErro()
			lRet := .F.
			Exit
		EndIf

		QSE1->(DbSkip())

	EndDo

Return lRet

/*/{Protheus.doc} TrocaEquipamento
Função no campo para abrir consulta de equipamentos simulares 
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function TrocaEquipamento(oView, cIDView, cField, lMark)

	Local oModel  	 := FWModelActive()
	Local oModelUJH	 := oModel:GetModel("UJHMASTER")
	Local oModelUJI	 := oModel:GetModel("UJIDETAIL")
	Local nOperation := oModel:GetOperation()
	Local lRet		 := .F.
	Local cFiltro 	 := ""

	SN1->(DbSetOrder(2))

//Somente troca
	If IsInCallStack("U_RetornoRemessa") .AND. cRotina == "TROCA"

		//Valido se marcou ou desmarcou check
		if lMark

			If SN1->(DbSeek(xFilial("SN1")+oModelUJI:GetValue("UJI_CHAPA")))

				//Consulta padrao para buscar produto igual que esteja disponivel
				FWMsgRun(,{|oSay|  lRet:= 	ConPad1(,,, "SNPTRO"  ,,, .F.,,,,,,)	},'Aguarde...','Consultando produtos disponiveis para troca...')

				If lRet

					//Atualizo o campo de chapa de troca
					oModelUJI:LoadValue("UJI_CHAPAT", Alltrim(SN1->N1_CHAPA)	 )
					oModelUJI:LoadValue("UJI_MOTRET", "2"						 ) //Troca

				Else

					Alert("E necessario que seja selecionado um item substituto para troca!")

					//Atualizo o campo de chapa de troca
					oModelUJI:LoadValue("UJI_OK"	, .F.)
					oModelUJI:LoadValue("UJI_CHAPAT", "")
					oModelUJI:LoadValue("UJI_MOTRET", "")
				Endif

			Endif
		Else

			//Atualizo o campo de chapa de troca
			oModelUJI:LoadValue("UJI_CHAPAT", "")
			oModelUJI:LoadValue("UJI_MOTRET", "")

		Endif

		oView:Refresh()
	Endif

Return

/*/{Protheus.doc} TrocaBensTeceiro
Função que faz processo de inclusao do item de troca do equipamento 
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function TrocaBensTerceiro()

	Local oModel  	 	:= FWModelActive()
	Local oModelUJH	 	:= oModel:GetModel("UJHMASTER")
	Local oModelUJI	 	:= oModel:GetModel("UJIDETAIL")
	Local lRet		 	:= .F.
	Local lRetTotal		:= .T.
	Local nValRetorno	:= 0

	Begin Transaction

		//Chamo funcao que vai fazer remessa de bens em terceiro
		FWMsgRun(,{|oSay| lRet := U_GeraBensTeceiro(oSay,oModelUJI)	},'Aguarde...','Gerando Controle de Bens em Terceiro...')'

		//Se remessa da chapa de troca foi realizada com sucesso
		//Finalizado controle da item que foi trocado
		If lRet

			lRet := RetornaBensTerceiro(oModelUJI,@lRetTotal,@nValRetorno)

			//Valido se estorno financeiro foi processado com sucesso
			If lRetTotal
				oModelUJH:LoadValue("UJH_STATUS","D") // Retorno Total Realizada
			Else
				oModelUJH:LoadValue("UJH_STATUS","P") 			// Retorno parcial Realizada
				oModelUJH:LoadValue("UJH_VALCON",nValRetorno)	// Retorno parcial Realizada
			Endif

			//se retornou erro no estorno interrompe a transacao
			If !lRet
				DisarmTransaction()
				Help(" ",1,"Troca",,"Troca Equipamento falhou.",1,0)
			Endif

		Endif

	End Transaction

Return lRet


/*/{Protheus.doc} GetTabelaPreco
Busco valor na tabela de preco para atualiza itens 
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function GetTabelaPreco(cField,cTabPreco,oModelUJH,oModelUJI)

	Local nI	:= 1

	SN1->(DbSetOrder(2))
	SB1->(DbSetOrder(1))
	DA1->(DbSetOrder(1))

//Valido de onde foi chamado a funcao
	If cField == "UJH_TABPRC"

		For nI:= 1 to oModelUJI:Length()

			oModelUJI:Goline(nI)

			if !oModelUJI:IsDeleted()

				//Posiciono no Ativo para pegar o codigo do produto vinculado
				If SN1->(DbSeek(xFilial("SN1")+oModelUJI:GetValue("UJI_CHAPA")))

					//Posiciono no produto
					If SB1->(DbSeek(xFilial("SB1")+SN1->N1_PRODUTO))

						nValItem:= U_RetPrecoVenda(cTabPreco,SB1->B1_COD)

						//Preenche valor do item
						oModelUJI:LoadValue("UJI_VLUNIT", nValItem)

						//Atualizo total do item
						oModelUJI:LoadValue("UJI_VLTOTA", oModelUJI:GetValue("UJI_QUANT") * nValItem )
					Endif
				Endif
			Endif
		Next nI

		oModelUJI:Goline(1)
	Else

		if !oModelUJI:IsDeleted()

			//Posiciono no Ativo para pegar o codigo do produto vinculado
			If SN1->(DbSeek(xFilial("SN1")+oModelUJI:GetValue("UJI_CHAPA")))

				//Atualiza descricao do campo
				oModelUJI:LoadValue("UJI_DESC",Alltrim(SN1->N1_DESCRIC))


				//Posiciono no produto
				If SB1->(DbSeek(xFilial("SB1")+SN1->N1_PRODUTO))

					//Atualiza Armazem de produto
					oModelUJI:LoadValue("UJI_LOCAL", SB1->B1_LOCPAD)

					//Valida se tabela esta preenchida
					if !Empty(cTabPreco)

						//busca valor do item na tabela de preco
						nValItem:= U_RetPrecoVenda(oModelUJH:GetValue("UJH_TABPRC"),SB1->B1_COD)

						//Preenche valor do item
						oModelUJI:LoadValue("UJI_VLUNIT", nValItem)

						//Preenche quantidade do item inicializando com 1
						oModelUJI:LoadValue("UJI_QUANT ", 1		  )

						//Preenche valor Total do item
						oModelUJI:LoadValue("UJI_VLTOTA", nValItem)

					Endif
				Endif
			Endif
		Endif
	Endif


//Chamo funcao para carregar titulos do contrato convalescencia
	FWMsgRun(,{|oSay| TitulosConvalescencia(oModelUJH:GetValue("UJH_CODIGO"))	},'Aguarde...','Atualizando Resumo Financeiro...')


Return

/*/{Protheus.doc} AddFiltro
Adiciono fiiltro na ativacao da tela
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function AddFiltro(oModel)

	Local nOperation	:= oModel:GetOperation()
	Local oModelUJI		:= oModel:GetModel("UJIDETAIL")
	Local aLoadFilter	:= {}
	Local lRet 			:= .T.

	IF ( nOperation == MODEL_OPERATION_UPDATE )

		If IsInCallStack("U_RetornoRemessa")

			//Filtro somente registros que nao foram retornados ainda
			oModel:GetModel( 'UJIDETAIL' ):SetLoadFilter( { { 'UJI_DATARE', "' '" } } )
		EndIf

	Endif

Return lRet

/*/{Protheus.doc} GravaControle
Grava Controle do Bem Terceiro
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function GravaControle(cCodigo,cCodChapa,cSequencia,cContato)

	Local dDataFim	:= SuperGetMv("MV_XDATFIM",,cTod("31/12/2049"))	//Data Default devolucao
	Local lRet		:= .T.

//Posiciono no cadastro do bem
	If SN1->(DbSeek(xFilial("SN1")+cCodChapa))

		//Valida Bem baixado
		If !Empty(SN1->N1_BAIXA)
			Help(" ",1,"RFUNA044",,"Nao é possível fazer o controle em terceiros de um bem baixado",1,0)
			lRet := .F.
		Elseif SN1->N1_TPCTRAT == '3'
			Help(" ",1,"RFUNA044",,"Equipamento selecionado se encontra locado para outro contrato",1,0)
			lRet := .F.
		EndIf

		If lRet

			//Gravo controle de Bens em Terceiro
			If Reclock("SNP",.T.)

				SNP->NP_FILIAL 	:= xFilial("SNP")
				SNP->NP_CODIGO	:= cCodigo
				SNP->NP_CBASE 	:= SN1->N1_CBASE
				SNP->NP_ITEM 	:= SN1->N1_ITEM
				SNP->NP_FORNEC  := UF2->UF2_CLIENT
				SNP->NP_LOJA 	:= UF2->UF2_LOJA
				SNP->NP_TIPCES	:= 'L'
				SNP->NP_SEQ 	:= StrZero(cSequencia,TamSx3("NP_SEQ")[1])
				SNP->NP_STATUS 	:= '1'
				SNP->NP_VIGINI 	:= dDataBase
				SNP->NP_VIGFIM	:= dDataFim
				SNP->NP_CONTATO := cContato

				SNP->(MsUnLock())

			Endif

			//Atualizo status do cadastro do bem
			If RecLock("SN1",.F.)
				SN1->N1_STATUS  := "1"
				SN1->N1_FORNEC	:= SNP->NP_FORNEC
				SN1->N1_LOJA	:= SNP->NP_LOJA
				SN1->N1_TPCTRAT := "3"

				SN1->(MsUnLock())
			Endif
		Endif
	Endif

Return lRet

/*/{Protheus.doc} IniCpoCont
//Funcao para inicializar campos
de acordo com o contrato posicionado.
@author TOTVS
@since 04/05/2019
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@type function
/*/
Static Function IniCpoCont(oView)

	Local nOperation 	:= oView:GetOperation()

	If nOperation == 3 //Inclusão

		If IsInCallStack("U_RFUNA002")

			FwFldPut("UJH_CONTRA" ,UF2->UF2_CODIGO,,,,.F.)
			FwFldPut("UJH_PLANO"  ,UF2->UF2_PLANO ,,,,.F.)
			FwFldPut("UJH_DESPLA" ,Posicione("UF0",1,xFilial("UF0")+ UF2->UF2_PLANO,"UF0_DESCRI")  ,,,,.F.)

			oView:Refresh()
		EndIf

	EndIf

Return


/*/{Protheus.doc} FUNA043L
//Funcao para adicionar legenda a tela inicial
@author TOTVS
@since 04/05/2019
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@type function
/*/

User Function FUNA043L(nOpc)

	if nOpc == 1 //Legenda do Browse

		BrwLegenda("Status","Legenda",{	{"BR_AZUL","Aguardando Remessa"		},;
			{"BR_BRANCO","Remessa Realizada"	},;
			{"BR_VERDE","Retorno Parcialmente"	},;
			{"BR_VERMELHO","Retorno Realizado"	}})

	Else//Legenda dos Titulos

		BrwLegenda("Status","Legenda",{	{"BR_VERMELHO","Titulo Baixado"		},;
			{"BR_AMARELO" ,"Titulo em Atraso"	},;
			{"BR_VERDE"	  ,"Valor a Receber"	},;
			{"BR_PRETO"   ,"Titulo Excluido"	}})

	Endif

Return

/*/{Protheus.doc} MaxItem
//Funcao para Max de itens 
@author TOTVS
@since 04/05/2019
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@type function
/*/
Static Function MaxItem(cCodigo)

	Local cQMax := ""

	cQMax := " SELECT MAX(UJI_ITEM) MAXITEM"
	cQMax += " FROM " + RETSQLNAME("UJI")
	cQMax += " WHERE D_E_L_E_T_ = ' '"
	cQMax += " AND UJI_FILIAL = '" + xFilial("UJI") + "'"
	cQMax += " AND UJI_CODIGO = '" + cCodigo 		+ "'"

	cQMax := ChangeQuery(cQMax)

	If Select("QUJI") > 1
		QUJI->(DbCloseArea())
	Endif

	TcQuery cQMax New Alias "QUJI"


Return Val(Soma1(QUJI->MAXITEM))

/*/{Protheus.doc} MaxItem
//Filtro troca de equipamentos chamado no filtro do SXB
@author TOTVS
@since 04/05/2019
@version 1.0
@return 
@param 
@type function
/*/
User Function FilTroca()

	Local cFiltro 	:= ""
	Local oModel  	:= FWModelActive()
	Local oModelUJI	:= oModel:GetModel("UJIDETAIL")
	Local cChapa	:= oModelUJI:GetValue("UJI_CHAPA")
	Local cQryN1	:= ""

	cQryN1 := " SELECT"
	cQryN1 += "		N1_PRODUTO"
	cQryN1 += " FROM " + RETSQLNAME("SN1")
	cQryN1 += " WHERE D_E_L_E_T_= ' '"
	cQryN1 += " AND N1_FILIAL ='" + xFilial("SN1") 	+ "'"
	cQryN1 += " AND N1_CHAPA  ='" + cChapa 			+ "'"

	cQryN1:= ChangeQuery(cQryN1)

	If Select("QSN1")
		QSN1->(DbCloseArea())
	Endif

	TcQuery cQryN1 New Alias "QSN1"

Return Alltrim(QSN1->N1_PRODUTO)

/*/{Protheus.doc} RetUF4Titular
Funcao para retornar o item da UF4 do Titular do Contrato
para buscar a carencia do mesmo
@type function
@version 
@author VIRTUS-PC
@since 25/08/2020
@param cContrato, character, Codigo do Contrato Principal do Convalescente
@return return_type, return_description
/*/
Static Function RetUF4Titular(cContrato)

	Local aArea := GetArea()
	Local cQry 	:= ""
	Local cItem	:= ""

	cQry := " SELECT "
	cQry += " UF4_ITEM ITEM "
	cQry += " FROM "
	cQry += RetSQLName("UF4")
	cQry += " WHERE "
	cQry += " D_E_L_E_T_ = ' ' "
	cQry += " AND UF4_FILIAL = '" + xFilial("UF4") + "' "
	cQry += " AND UF4_CODIGO = '" + cContrato + "' "
	cQry += " AND UF4_TIPO = '3' "

	If Select("QUF4T")
		QUF4T->(DbCloseArea())
	Endif

	TcQuery cQry New Alias "QUF4T"

	if QUF4T->(!Eof())

		cItem := QUF4T->ITEM

	endif

	RestArea(aArea)

	QUF4T->(DbCloseArea())

Return(cItem)
