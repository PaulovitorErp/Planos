#include "protheus.ch"
#include "fwmvcdef.ch"
#include "topconn.ch"

/*/{Protheus.doc} RFUNA038
Regras de Contrato
@author TOTVS
@since 25/02/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RFUNA038()
/***********************/ 

	Local oBrowse

	Private aRotina 	:= {}

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias("UJ5")
	oBrowse:SetDescription("Regras de Contrato")
	oBrowse:AddLegend("UJ5_STATUS == 'A'",	"GREEN", "Ativa")
	oBrowse:AddLegend("UJ5_STATUS == 'I'",	"RED",	 "Inativa")
	oBrowse:Activate()

Return Nil

/************************/
Static Function MenuDef()
/************************/

	aRotina := {}

	ADD OPTION aRotina Title 'Visualizar' 					Action "VIEWDEF.RFUNA038"				OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Incluir"    					Action "VIEWDEF.RFUNA038"				OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title "Alterar"    					Action "VIEWDEF.RFUNA038"				OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Excluir"    					Action "VIEWDEF.RFUNA038"				OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'     					Action 'U_FUNA038L()' 					OPERATION 6 ACCESS 0
	ADD OPTION aRotina Title 'Replica Regras'     			Action 'U_VirtusMRegrasMigracao()' 		OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title 'Copiar'     					Action 'VIEWDEF.RFUNA038'				OPERATION 9 ACCESS 0

Return aRotina

/*************************/
Static Function ModelDef()
/*************************/

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruUJ5 := FWFormStruct(1,"UJ5",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruUJ6 := FWFormStruct(1,"UJ6",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruUJ7 := FWFormStruct(1,"UJ7",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruUJ8 := FWFormStruct(1,"UJ8",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruUJZ := FWFormStruct(1,"UJZ",/*bAvalCampo*/,/*lViewUsado*/ )

	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("PFUNA038",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("UJ5MASTER",/*cOwner*/,oStruUJ5)

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({"UJ5_FILIAL","UJ5_CODIGO"})

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid("UJ6DETAIL","UJ5MASTER",oStruUJ6,/*bLinePre*/,/*bLinePost*/{|oMdlG| ValLinUJ6(oMdlG)},/*bPreVal*/,/*bPosVal*/,/*BLoad*/)
	oModel:AddGrid("UJ7DETAIL","UJ6DETAIL",oStruUJ7,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)
	oModel:AddGrid("UJ8DETAIL","UJ5MASTER",oStruUJ8,/*bLinePre*/,/*bLinePost*/{|oMdlG| ValLinUJ8(oMdlG)},/*bPreVal*/,/*bPosVal*/,/*BLoad*/)
	oModel:AddGrid("UJZDETAIL","UJ5MASTER",oStruUJZ,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation("UJ6DETAIL", {{"UJ6_FILIAL", 'xFilial("UJ6")'},{"UJ6_CODIGO","UJ5_CODIGO"}},UJ6->(IndexKey(1)))
	oModel:SetRelation("UJ7DETAIL", {{"UJ7_FILIAL", 'xFilial("UJ7")'},{"UJ7_CODIGO","UJ5_CODIGO"},{"UJ7_REGRA","UJ6_REGRA"}},UJ7->(IndexKey(1)))
	oModel:SetRelation("UJ8DETAIL", {{"UJ8_FILIAL", 'xFilial("UJ8")'},{"UJ8_CODIGO","UJ5_CODIGO"}},UJ8->(IndexKey(1)))
	oModel:SetRelation("UJZDETAIL", {{"UJZ_FILIAL", 'xFilial("UJZ")'},{"UJZ_CODIGO","UJ5_CODIGO"}},UJZ->(IndexKey(1)))

	// Desobriga a digitacao de ao menos um item
	oModel:GetModel("UJ6DETAIL"):SetOptional(.T.)
	oModel:GetModel("UJ7DETAIL"):SetOptional(.T.)
	oModel:GetModel("UJ8DETAIL"):SetOptional(.T.)
	oModel:GetModel("UJZDETAIL"):SetOptional(.T.)

	// Liga o controle de nao repeticao de linha
	oModel:GetModel("UJ6DETAIL"):SetUniqueLine({"UJ6_TPREGR","UJ6_TPBENE","UJ6_VLRINI","UJ6_VLRFIM"})
	oModel:GetModel("UJ7DETAIL"):SetUniqueLine({"UJ7_TPCOND"})
	oModel:GetModel("UJ8DETAIL"):SetUniqueLine({"UJ8_PARA","UJ8_TPREGR","UJ8_VLRINI","UJ8_VLRFIM","UJ8_PRODUT"})
	oModel:GetModel("UJZDETAIL"):SetUniqueLine({"UJZ_FORPG","UJZ_TPDESC"})

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("UJ5MASTER"):SetDescription("Dados")
	oModel:GetModel("UJ6DETAIL"):SetDescription("Cobrança Adicional")
	oModel:GetModel("UJ7DETAIL"):SetDescription("Condição Cobrança Adicional")
	oModel:GetModel("UJ8DETAIL"):SetDescription("Carência")
	oModel:GetModel("UJZDETAIL"):SetDescription("Regras de Desconto x Forma de Pagto")

Return(oModel)

/************************/
Static Function ViewDef()
/************************/

// Cria a estrutura a ser usada na View
	Local oStruUJ5 		:= FWFormStruct(2,"UJ5")
	Local oStruUJ6 		:= FWFormStruct(2,"UJ6")
	Local oStruUJ7 		:= FWFormStruct(2,"UJ7")
	Local oStruUJ8 		:= FWFormStruct(2,"UJ8")
	Local oStruUJZ 		:= FWFormStruct(2,"UJZ")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   		:= FWLoadModel("RFUNA038")
	Local oView
	Local oCalc1

// Remove campos da estrutura
	oStruUJ6:RemoveField('UJ6_CODIGO')
	oStruUJ7:RemoveField('UJ7_CODIGO')
	oStruUJ7:RemoveField('UJ7_REGRA')
	oStruUJ8:RemoveField('UJ8_CODIGO')
	oStruUJZ:RemoveField('UJZ_CODIGO')

// Cria o objeto de View
	oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

// Crio um agrupador de campos
	oStruUJ5:AddGroup('GRUPO01', 'Dados da Regra',	 		 '', 2)
	oStruUJ5:AddGroup('GRUPO02', 'Prescrição de Dependente', '', 2)

// Colocando todos os campos para o agrupamento 2
	oStruUJ5:SetProperty('*' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02')

// Trocando os campos do contrato para o agrupamento 1
	oStruUJ5:SetProperty('UJ5_CODIGO' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01')
	oStruUJ5:SetProperty('UJ5_DATA' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01')
	oStruUJ5:SetProperty('UJ5_DESCRI' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01')
	oStruUJ5:SetProperty('UJ5_STATUS' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01')

// Trocando os campos do contrato para o agrupamento 2
	oStruUJ5:SetProperty('UJ5_TPPRES' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02')
	oStruUJ5:SetProperty('UJ5_PRAZO' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02')

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField("VIEW_UJ5",oStruUJ5,"UJ5MASTER")

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid("VIEW_UJ6",oStruUJ6,"UJ6DETAIL")
	oView:AddGrid("VIEW_UJ7",oStruUJ7,"UJ7DETAIL")
	oView:AddGrid("VIEW_UJ8",oStruUJ8,"UJ8DETAIL")
	oView:AddGrid("VIEW_UJZ",oStruUJZ,"UJZDETAIL")

	oView:CreateHorizontalBox("PAINEL_CABEC", 45)
	oView:CreateHorizontalBox("PAINEL_ITENS", 55)

// Cria Folder na view
	oView:CreateFolder("PASTAS","PAINEL_ITENS")

// Cria pastas nas folders
	oView:AddSheet("PASTAS","ABA01","Cobrança Adicional")
	oView:AddSheet("PASTAS","ABA02","Carência")
	oView:AddSheet("PASTAS","ABA03","Descontos")

	oView:CreateVerticalBox("PAINEL_ITENS_R",50,,,"PASTAS","ABA01")
	oView:CreateVerticalBox("PAINEL_ITENS_C",50,,,"PASTAS","ABA01")
	oView:CreateHorizontalBox("PAINEL_ITENS_A",100,,,"PASTAS","ABA02")
	oView:CreateHorizontalBox("PAINEL_ITENS_F",100,,,"PASTAS","ABA03")

// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView("VIEW_UJ5","PAINEL_CABEC")
	oView:SetOwnerView("VIEW_UJ6","PAINEL_ITENS_R")
	oView:SetOwnerView("VIEW_UJ7","PAINEL_ITENS_C")
	oView:SetOwnerView("VIEW_UJ8","PAINEL_ITENS_A")
	oView:SetOwnerView("VIEW_UJZ","PAINEL_ITENS_F")

// Liga a identificacao do componente
//oView:EnableTitleView("VIEW_UJ5","Dados da Regra")
	oView:EnableTitleView("VIEW_UJ6","Cobrança Adcional")
	oView:EnableTitleView("VIEW_UJ7","Condição Cobrança Adcional")
//oView:EnableTitleView("VIEW_UJ8","Carência")
	oView:EnableTitleView("VIEW_UJZ","Regras de Desconto")

// Define campos que terao Auto Incremento
	oView:AddIncrementField("VIEW_UJ6","UJ6_REGRA")
	oView:AddIncrementField("VIEW_UJ7","UJ7_ITEM")
	oView:AddIncrementField("VIEW_UJ8","UJ8_ITEM")
	oView:AddIncrementField("VIEW_UJZ","UJZ_ITEM")

// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk( {||.T.} )

// Habilito a barra de progresso na abertura da tela
	oView:SetProgressBar(.T.)

Return oView

/***********************/
User Function FUNA038L()
/***********************/

	BrwLegenda("Status","Legenda",{{"BR_VERDE","Ativa"},;
		{"BR_VERMELHO","Inativa"}})

Return

/************************************/
Static Function ValLinUJ6(oModelGrid)
/************************************/

	Local lRet			:= .T.
	Local nI			:= 0

	Local oModel		:= FWModelActive()
	Local nOperation	:= oModelGrid:GetOperation()
	Local nLinAtual		:= oModelGrid:GetLine()

	Local cTipo			:= oModelGrid:GetValue("UJ6_TPREGR")
	Local cTpBenef		:= oModelGrid:GetValue("UJ6_TPBENE")
	Local nVlrIni		:= oModelGrid:GetValue("UJ6_VLRINI")
	Local nVlrFim		:= oModelGrid:GetValue("UJ6_VLRFIM")
	
	Local aSaveLines  	:= FWSaveRows()

	If nOperation == 3 .Or. nOperation == 4 //Inclusão Ou Alteração

		//Valida conflito de regras
		For nI := 1 To oModelGrid:Length()

			If nI == nLinAtual
				Loop
			Else

				oModelGrid:Goline(nI)

				If !oModelGrid:IsDeleted()

					If oModelGrid:GetValue("UJ6_TPREGR") == cTipo .And. oModelGrid:GetValue("UJ6_TPBENE") == cTpBenef

						If (nVlrIni >= oModelGrid:GetValue("UJ6_VLRINI") .And. nVlrIni <= oModelGrid:GetValue("UJ6_VLRFIM")) .Or.;
								(nVlrFim >= oModelGrid:GetValue("UJ6_VLRINI") .And. nVlrFim <= oModelGrid:GetValue("UJ6_VLRFIM")) .Or.;
								(nVlrIni <= oModelGrid:GetValue("UJ6_VLRINI") .And. nVlrFim >= oModelGrid:GetValue("UJ6_VLRFIM"))

							Help( ,,'Help',,'Esta regra entra em conflito com o item '+oModelGrid:GetValue("UJ6_REGRA")+'.',1,0)
							lRet := .F.
							Exit
						Endif
					Endif
				Endif
			Endif
		Next nI
	Endif

	FWRestRows(aSaveLines)

Return lRet

/************************************/
Static Function ValLinUJ8(oModelGrid)
/************************************/

	Local lRet			:= .T.
	Local nI			:= 0

	Local oModel		:= FWModelActive()
	Local nOperation	:= oModelGrid:GetOperation()
	Local nLinAtual		:= oModelGrid:GetLine()

	Local cPara			:= oModelGrid:GetValue("UJ8_PARA")
	Local cTipo			:= oModelGrid:GetValue("UJ8_TPREGR")
	Local nVlrIni		:= oModelGrid:GetValue("UJ8_VLRINI")
	Local nVlrFim		:= oModelGrid:GetValue("UJ8_VLRFIM")
	Local cProduto		:= oModelGrid:GetValue("UJ8_PRODUT")

	Local aSaveLines  	:= FWSaveRows()

	If nOperation == 3 .Or. nOperation == 4 //Inclusão Ou Alteração

		//Valida conflito de regras
		For nI := 1 To oModelGrid:Length()

			If nI == nLinAtual
				Loop
			Else

				oModelGrid:Goline(nI)

				If !oModelGrid:IsDeleted()

					If oModelGrid:GetValue("UJ8_PARA") == cPara .And. oModelGrid:GetValue("UJ8_TPREGR") == cTipo .And.;
						oModelGrid:GetValue("UJ8_PRODUT") == cProduto

						If (nVlrIni >= oModelGrid:GetValue("UJ8_VLRINI") .And. nVlrIni <= oModelGrid:GetValue("UJ8_VLRFIM")) .Or.;
								(nVlrFim >= oModelGrid:GetValue("UJ8_VLRINI") .And. nVlrFim <= oModelGrid:GetValue("UJ8_VLRFIM")) .Or.;
								(nVlrIni <= oModelGrid:GetValue("UJ8_VLRINI") .And. nVlrFim >= oModelGrid:GetValue("UJ8_VLRFIM"))

							Help( ,,'Help',,'Esta regra entra em conflito com o item '+oModelGrid:GetValue("UJ8_ITEM")+'.',1,0)
							lRet := .F.
							Exit
						Endif
					Endif
				Endif
			Endif
		Next nI
	Endif

	FWRestRows(aSaveLines)

Return lRet

/*********************/
User Function VlrUJ6()
/*********************/

	Local lRet := .T.

	If FwFldGet("UJ6_VLRFIM") > 0 .And. FwFldGet("UJ6_VLRINI") > FwFldGet("UJ6_VLRFIM")
		Help( ,, 'VlrUJ6',, 'O valor inicial nao pode ser superior que o valor final.', 1, 0 )
		lRet := .F.
	Endif

Return lRet

/*********************/
User Function VlrUJ7()
/*********************/

	Local lRet := .T.

	If FwFldGet("UJ7_VLRFIM") > 0 .And. FwFldGet("UJ7_VLRINI") > FwFldGet("UJ7_VLRFIM")
		Help( ,, 'VlrUJ7',, 'O valor inicial nao pode ser superior que o valor final.', 1, 0 )
		lRet := .F.
	Endif

Return lRet

/*******************************/
User Function VldTpCond(cTpCond)
/*******************************/

	Local lRet 			:= .T.

	Local oModel		:= FWModelActive()
	Local oModelUJ6 	:= oModel:GetModel("UJ6DETAIL")

	If cTpCond == oModelUJ6:GetValue("UJ6_TPREGR")
		Help( ,, 'VldTpCond',, 'O tipo da condição e o tipo da regra relacionada devem ser diferentes.', 1, 0 )
		lRet := .F.
	Endif

Return lRet

/***********************************/
User Function VldTpCar(cPara,cTpCar)
/***********************************/

	Local lRet 			:= .T.

	Local oModel		:= FWModelActive()
	Local oModelUJ8 	:= oModel:GetModel("UJ8DETAIL")

	If !Empty(cPara) .And. !Empty(cTpCar)

		If  cPara == "A" .And. cTpCar == "I" .Or.; //Contrato E Idade
			cPara == "B" .And. cTpCar == "P" .Or.; //Beneficiario E Quant. Parcelas
			cPara == "T" .And. cTpCar == "P" .Or.; //Titular E Quant. Parcelas
			cPara == "A" .And. cTpCar == "P" //Titular e Beneficiario E Quant. Parcelas

			Help( ,, 'VldTpCar',, 'O tipo da regra e a entidade a ser considerada sao incoerentes.', 1, 0 )
			lRet := .F.
		Endif
	Endif

Return lRet

/******************************************************/
User Function RetCobAd(oModelUF4,cRegra,cCodBen,nIdade)
/******************************************************/

	Local aRet			:= {0,Space(3)}
	Local aArea			:= GetArea()

	Local cQry			:= ""
	Local cQry2			:= ""

	Local aCondCobr		:= {}

	Local nI, nJ
	Local nQtdDep		:= 0
	Local lOk			:= .F.

	Local nCobrAd 		:= 0
	Local cItem			:= Space(3)

	Default cCodBen		:= ""
	Default nIdade		:= 0

	If !Empty(cRegra)

		//Lendo as regras e condições
		If Select("QRYUJ6") > 0
			QRYUJ6->(DbCloseArea())
		Endif

		cQry := "SELECT UJ6_REGRA, UJ6_TPREGR, UJ6_VLRINI, UJ6_VLRFIM, UJ6_VLRCOB, UJ6_INDIVI"
		cQry += " FROM "+RetSqlName("UJ6")+""
		cQry += " WHERE D_E_L_E_T_ 	<> '*'"
		cQry += " AND UJ6_FILIAL 	= '"+xFilial("UJ6")+"'"
		cQry += " AND UJ6_CODIGO	= '"+cRegra+"'"

		cQry := ChangeQuery(cQry)
		TcQuery cQry NEW Alias "QRYUJ6"

		If QRYUJ6->(!EOF())

			//Busca dependentes
			aDep := RetDep(oModelUF4,.F.)

			//Busca titular
			aTit := RetDep(oModelUF4,.T.)

			While QRYUJ6->(!EOF())

				aCondCobr 	:= {}

				If Select("QRYUJ7") > 0
					QRYUJ7->(DbCloseArea())
				Endif

				cQry2 := "SELECT UJ7_TPCOND, UJ7_VLRINI, UJ7_VLRFIM"
				cQry2 += " FROM "+RetSqlName("UJ7")+""
				cQry2 += " WHERE D_E_L_E_T_ 	<> '*'"
				cQry2 += " AND UJ7_FILIAL 	= '"+xFilial("UJ7")+"'"
				cQry2 += " AND UJ7_CODIGO	= '"+cRegra+"'"
				cQry2 += " AND UJ7_REGRA	= '"+QRYUJ6->UJ6_REGRA+"'"

				cQry2 := ChangeQuery(cQry2)
				TcQuery cQry2 NEW Alias "QRYUJ7"

				While QRYUJ7->(!EOF())

					AAdd(aCondCobr,{QRYUJ7->UJ7_TPCOND,;
						QRYUJ7->UJ7_VLRINI,;
						QRYUJ7->UJ7_VLRFIM})

					QRYUJ7->(DbSkip())
				EndDo

				//Possui condição para cobrança
				If Len(aCondCobr) > 0

					//Cobrança por nro. de dependente
					If QRYUJ6->UJ6_TPREGR == "N"

						nQtdDep := 0

						For nI := 1 To Len(aCondCobr)

							If aCondCobr[nI][1] == "I" //Cobrança por idade do dependente

								For nJ := 1 To Len(aDep)

									If aDep[nJ] >= aCondCobr[nI][2] .And. aDep[nJ] <= aCondCobr[nI][3]
										nQtdDep++
									Endif
								Next nJ
							Endif
						Next nI

						//Consta no range da regra
						If nQtdDep >= QRYUJ6->UJ6_VLRINI .And. nQtdDep <= QRYUJ6->UJ6_VLRFIM

							//Verifica o tipo da cobrança
							If QRYUJ6->UJ6_INDIVI == "I" //Individual
								nCobrAd := nQtdDep * QRYUJ6->UJ6_VLRCOB
								cItem	:= QRYUJ6->UJ6_REGRA
							Else
								nCobrAd := QRYUJ6->UJ6_VLRCOB
								cItem	:= QRYUJ6->UJ6_REGRA
							Endif
						Endif

					ElseIf QRYUJ6->UJ6_TPREGR == "I" //Cobrança por idade do dependente

						nQtdDep := 0

						For nI := 1 To Len(aCondCobr)

							If aCondCobr[nI][1] == "N" //Cobrança por nro. de dependentes

								If Len(aDep) >= aCondCobr[nI][2] .And. Len(aDep) <= aCondCobr[nI][3]
									lOk := .T.
								Else
									lOk := .F.
								Endif

							ElseIf aCondCobr[nI][1] == "T" //Cobrança por idade do titular

								If aTit[1] >= aCondCobr[nI][2] .And. aTit[1] <= aCondCobr[nI][3]
									lOk := .T.
								Else
									lOk := .F.
								Endif
							Endif
						Next nI

						If lOk

							//Consta no range da regra
							If nIdade >= QRYUJ6->UJ6_VLRINI .And. nIdade <= QRYUJ6->UJ6_VLRFIM

								nCobrAd := nQtdDep * QRYUJ6->UJ6_VLRCOB
								cItem	:= QRYUJ6->UJ6_REGRA
							Endif
						Endif

					Else //Cobrança por idade do titular

						For nI := 1 To Len(aCondCobr)

							If aCondCobr[nI][1] == "N" //Cobrança por nro. de dependentes

								If Len(aDep) >= aCondCobr[nI][2] .And. Len(aDep) <= aCondCobr[nI][3]
									lOk := .T.
								Else
									lOk := .F.
								Endif

							ElseIf aCondCobr[nI][1] == "I" //Cobrança por idade dos dependentes

								For nJ := 1 To Len(aDep)

									If aDep[nJ] >= aCondCobr[nI][2] .And. aDep[nJ] <= aCondCobr[nI][3]
										lOk := .T.
									Else
										lOk := .F.
										Exit
									Endif
								Next nJ
							Endif
						Next nI

						If lOk

							//Consta no range da regra
							If nIdade >= QRYUJ6->UJ6_VLRINI .And. nIdade <= QRYUJ6->UJ6_VLRFIM
								nCobrAd := QRYUJ6->UJ6_VLRCOB
								cItem	:= QRYUJ6->UJ6_REGRA
							Endif
						Endif
					Endif

				Else //Não possui condição para cobrança

					//Cobrança por nro. de dependente
					If QRYUJ6->UJ6_TPREGR == "N"

						//Consta no range da regra
						If Len(aDep) >= QRYUJ6->UJ6_VLRINI .And. Len(aDep) <= QRYUJ6->UJ6_VLRFIM

							//Verifica o tipo da cobrança
							If QRYUJ6->UJ6_INDIVI == "I" //Individual
								nCobrAd := Len(aDep) * QRYUJ6->UJ6_VLRCOB
								cItem	:= QRYUJ6->UJ6_REGRA
							Else
								nCobrAd := QRYUJ6->UJ6_VLRCOB
								cItem	:= QRYUJ6->UJ6_REGRA
							Endif
						Endif

					ElseIf QRYUJ6->UJ6_TPREGR == "I" //Cobrança por idade do dependente

						If nIdade >= QRYUJ6->UJ6_VLRINI .And. nIdade <= QRYUJ6->UJ6_VLRFIM

							nCobrAd := QRYUJ6->UJ6_VLRCOB
							cItem	:= QRYUJ6->UJ6_REGRA
						Endif

					Else //Cobrança por idade do titular

						If nIdade >= QRYUJ6->UJ6_VLRINI .And. nIdade <= QRYUJ6->UJ6_VLRFIM
							nCobrAd := QRYUJ6->UJ6_VLRCOB
							cItem	:= QRYUJ6->UJ6_REGRA
						Endif
					Endif
				Endif

				AAdd(aRet,{nCobrAd,cItem})

				QRYUJ6->(DbSkip())
			EndDo
		Endif
	Endif

//MsgInfo("De acordo com as Regras de Contrato, foi somado o valor de "+AllTrim(Transform(nCobrAd,"@E 9,999,999,999,999.99"))+" ao valor da parcela, referente a cobrança adicional do beneficiario "+cCodBen+".","Atenção")

	If Select("QRYUJ6") > 0
		QRYUJ6->(DbCloseArea())
	Endif

	If Select("QRYUJ7") > 0
		QRYUJ7->(DbCloseArea())
	Endif

	RestArea(aArea)

Return aRet

/****************************************/
Static Function RetDep(oModelUF4,lIncTit)
/****************************************/

	Local aRet			:= {}
	Local nX

	Local aSaveLines	:= FWSaveRows()

	For nX := 1 To oModelUF4:Length()

		oModelUF4:GoLine(nX)

		If !oModelUF4:IsDeleted()

			If oModelUF4:GetValue("UF4_FALECI") == '' //Não falecido

				If oModelUF4:GetValue("UF4_DTFIM") == '' .Or. oModelUF4:GetValue("UF4_DTFIM") > dDataBase //Válido

					//Considera o titular
					If !lIncTit
						oModelUF4:GetValue("UF4_TIPO") <> "3" //Diferente de titular
					Else
						oModelUF4:GetValue("UF4_TIPO") == "3" //Titular
					Endif

					AAdd(aRet,oModelUF4:GetValue("UF4_TIPO"))
				Endif
			Endif
		Endif
	Next nX

	FWRestRows(aSaveLines)

Return aRet

/*/{Protheus.doc} RetPresc
funcao para retorna a data de prescicao
conforme a regra.
@type function
@version 1.0
@author totvs
@since 25/02/2019
@param cRegra, character, param_description
@param cDtFalec, character, param_description
@return return_type, return_description
/*/
/**************************************/
User Function RetPresc(cRegra, dDtFalec, cContrato)
/**************************************/

	Local aArea			:= GetArea()
	Local aAreaUF2		:= UF2->(GetArea())
	Local cQry			:= ""
	Local cPresContra	:= SuperGetMv("MV_XDPRSBE",.F.,"1") // defino a prescricao do beneficiario - 1=Padrao;2=Considera a data do contrato
	Local dDtRet		:= Stod("")
	Local dDataRef		:= Stod("")

	Default cRegra		:= ""
	Default dDtFalec	:= Stod("")
	Default cContrato	:= ""

	If Select("QRYUJ5") > 0
		QRYUJ5->(DbCloseArea())
	Endif

	cQry := "SELECT UJ5_TPPRES, UJ5_PRAZO"
	cQry += " FROM "+RetSqlName("UJ5")+""
	cQry += " WHERE D_E_L_E_T_ 	<> '*'"
	cQry += " AND UJ5_FILIAL 	= '"+xFilial("UJ5")+"'"
	cQry += " AND UJ5_CODIGO	= '"+cRegra+"'"

	cQry := ChangeQuery(cQry)
	TcQuery cQry NEW Alias "QRYUJ5"

	If QRYUJ5->(!EOF())

		// data de referencia
		dDataRef := dDtFalec

		If !Empty(QRYUJ5->UJ5_TPPRES)

			//==================================================
			// Precriscao do contrato 1=Padrao:
			// Considera a data de falecimento como referencia
			// e o prazo definido na regra, contando o prazo
			// a partir desta data
			//==================================================
			if cPresContra == "1" // prescricao padrao

				If QRYUJ5->UJ5_TPPRES == "A" //Ano
					dDtRet := YearSum(dDataRef,QRYUJ5->UJ5_PRAZO)
				ElseIf QRYUJ5->UJ5_TPPRES == "M" //Mês
					dDtRet := MonthSum(dDataRef,QRYUJ5->UJ5_PRAZO)
				Else //Dia
					dDtRet := DaySum(dDataRef,QRYUJ5->UJ5_PRAZO)
				Endif

				//==================================================
				// Precriscao do contrato 2=Prescreve de acordo com o contrato:
				// Considera a data de ativacao como referencia
				// e o prazo definido na regra, contando o prazo
				// a partir desta data como base a data base do sistema
				// Ex: Contrato 2014
				// - Falecimento 2021
				// - Vai deixar de ser considerado em 2022
				//==================================================
			elseIf cPresContra == "2" // preescricao de acordo com a data de ativacao do contrato

				UF2->(DbSetOrder(1))
				if UF2->(MsSeek(xFilial("UF2")+cContrato))
					dDataRef := UF2->UF2_DTATIV
				endIf

				while dDataBase >= dDtRet

					if !Empty(dDtRet)
						dDataRef := dDtRet
					endIf

					If QRYUJ5->UJ5_TPPRES == "A" //Ano
						dDtRet := YearSum(dDataRef,QRYUJ5->UJ5_PRAZO)
					ElseIf QRYUJ5->UJ5_TPPRES == "M" //Mês
						dDtRet := MonthSum(dDataRef,QRYUJ5->UJ5_PRAZO)
					Else //Dia
						dDtRet := DaySum(dDataRef,QRYUJ5->UJ5_PRAZO)
					Endif

				endDo

			Endif
		
		Endif

	endIf

	If Select("QRYUJ5") > 0
		QRYUJ5->(DbCloseArea())
	Endif

	RestArea(aAreaUF2)
	RestArea(aArea)

Return(dDtRet)

/*/{Protheus.doc} RetCaren
funcao para retornar a regra de carencia conforme 
a regra e 'para' (UJ8_PARA) qiuem a regra é feita
Para: A= Parcelas Pagas;B=Beneficiario;P=Personalizacao;T=Titular;G=Agregado

@type function
@version 1.0 
@author totvs
@since 25/02/2019
@param cContrato, character, codigo do contrato
@param cRegra, character, codigo da regra
@param dDtRef, date, data de referencia
@param cPara, character, para quem é a regra
@param cCodBen, character, codigo do beneficiario do contrato
@param nIdadeBen, numeric, idade do beneficiario do contrato
@param cProduto, Character, Codigo do Produto Personalizado
@return array, retorna um array de duas posicoes [1] data da carencia [2] item da regra de carencia
/*/
/**********************************************************************/
User Function RetCaren(cContrato,cRegra,dDtRef,cPara,cCodBen,nIdadeBen,cProduto)
/**********************************************************************/

	Local aRet 			:= {CToD(""),Space(3)}
	Local aArea			:= GetArea()
	Local aPara			:= {}
	Local cAux			:= ""
	Local dDtContr		:= IIF(Empty(dDtRef),Posicione("UF2",1,xFilial("UF2")+cContrato,"UF2_DATA"),dDtRef)
	Local dCarencia		:= ""
	Local nLinha		:= 1
	Local nI			:= 1
	Local nX			:= 1
	Local oModel		:= FWModelActive()
	Local oModelUF4 	:= oModel:GetModel("UF4DETAIL")

	Default cContrato	:= ""
	Default cRegra		:= ""
	Default dDtRef		:= stod("")
	Default cPara		:= ""
	Default cCodBen		:= ""
	Default nIdadeBen	:= 0
	Default cProduto 	:= ""

	// verifico se a regra e data de refencia estao preenchidas
	If !Empty(cRegra) .And. !Empty(dDtRef)

		//Lendo as regras de carência
		If Select("QRYUJ8") > 0
			QRYUJ8->(DbCloseArea())
		Endif

		cQry := "SELECT UJ8_ITEM, UJ8_PARA, UJ8_TPREGR, UJ8_VLRINI, UJ8_VLRFIM, UJ8_TEMPO"
		cQry += " FROM "+RetSqlName("UJ8")+""
		cQry += " WHERE D_E_L_E_T_ 	<> '*'"
		cQry += " AND UJ8_FILIAL 	= '"+xFilial("UJ8")+"'"
		cQry += " AND UJ8_CODIGO	= '"+cRegra+"'"

		If !Empty(cPara)

			aPara := strTokArr(cPara,"/")

			cAux += "("
			For nI := 1 To Len(aPara)
				If nI == Len(aPara)
					cAux += "'" + aPara[nI] + "'"
				Else
					cAux += "'" + aPara[nI] + "',"
				Endif
			Next nI
			cAux += ")"

			cQry += " AND UJ8_PARA IN "+cAux+""
			
			cQry += " AND UJ8_PRODUT IN ('" + cProduto + "','') "

		Endif

		cQry += " ORDER BY UJ8_PARA"

		cQry := ChangeQuery(cQry)
	
		MPSysOpenQuery(cQry, "QRYUJ8")

		If QRYUJ8->(!EOF())

			While QRYUJ8->(!EOF())

				If AllTrim(QRYUJ8->UJ8_PARA) == "A" //Parcelas Pagas

					//Cobrança por qtde. parcelas pagas
					nParcPg := RetInfoParc(cContrato)  // retorna qtde parcelas pagas

					If nParcPg <= QRYUJ8->UJ8_TEMPO

						//valido se chamou da validacao de campo ou na rotina de contrato
						if !IsInCallStack("U_VLDPRODFUN") .AND. !IsInCallStack("U_CARBENFUN") .And. !IsInCallStack("U_UCARENFUN")

							//Busco data de vencimento da ultima parcela da carencia
							dCarencia := RetInfoParc(cContrato,cValToChar(QRYUJ8->UJ8_TEMPO) )

							//Valido se ja foi checado alguma regra
							if !Empty(aRet[1])

								if Valtype(aRet[1]) == "D" .AND. aRet[1] < dCarencia

									aRet[1] := dCarencia
									aRet[2] := QRYUJ8->UJ8_ITEM

								endif

							else

								aRet[1] := dCarencia
								aRet[2] := QRYUJ8->UJ8_ITEM

							endif

						else

							// verifico se estou na funcao de carencia
							If IsInCallStack("U_CARBENFUN") .Or. IsInCallStack("U_UCARENFUN")

								// verifico se o primeiro vencimento esta preenchido
								If !Empty(M->UF2_PRIMVE)

									//Faco previsao de carencia de acordo com o numero de parcela
									aRet[1] := MonthSum( M->UF2_PRIMVE, QRYUJ8->UJ8_TEMPO )

								Else// caso ainda não tenha preenchido o campo primeiro vencimento

									//Faco previsao de carencia de acordo com o numero de parcela
									aRet[1] := MonthSum( dDtRef, QRYUJ8->UJ8_TEMPO )

								EndIf

							Else// para as demais funcoes

								//Faco previsao de carencia de acordo com o numero de parcela
								aRet[1] := MonthSum( UF2->UF2_PRIMVE, QRYUJ8->UJ8_TEMPO )

							EndIf

						endif

						aRet[2] := QRYUJ8->UJ8_ITEM

					Endif
				Endif

				If AllTrim(QRYUJ8->UJ8_PARA) == "T" //Titular

					//Valido se foi chamado na inclusao beneficiario
					//Usa carencia do titular
					if "B" $ cPara .AND. Empty(aRet[1]) .OR. "P" $ cPara .AND. Empty(aRet[1])

						//salvo linha posicionada
						nLinha:= oModelUF4:nLine

						For nX := 1 To oModelUF4:Length()
							oModelUF4:GoLine(nX)
							//Tipo Titular
							if oModelUF4:GetValue("UF4_TIPO") == "3"
								aRet[1] := oModelUF4:GetValue("UF4_CAREN")
								aRet[2] := oModelUF4:GetValue("UF4_ITREGC")
								Exit
							endif
						Next nX

						//Retorno linha
						oModelUF4:GoLine(nLinha)

						//Busca carencia para Titular
					elseif !"B" $ cPara .AND. !"P" $ cPara

						If nIdadeBen >= QRYUJ8->UJ8_VLRINI .AND. nIdadeBen <= QRYUJ8->UJ8_VLRFIM

							dCarencia := DaySum(dDtContr, QRYUJ8->UJ8_TEMPO)

							//Valido se ja foi checado alguma regra e se carencia e qual é a maior carencia
							//da regra do titular ou a outra
							if !Empty(aRet[1])

								if Valtype(aRet[1]) == "D" .AND. aRet[1] < dCarencia

									aRet[1] := dCarencia
									aRet[2] := QRYUJ8->UJ8_ITEM

								endif

							else

								aRet[1] := dCarencia
								aRet[2] := QRYUJ8->UJ8_ITEM

							endif

						Endif
					Endif
				endif

				If AllTrim(QRYUJ8->UJ8_PARA) $ "B/G" //Beneficiário ou agregado

					If nIdadeBen >= QRYUJ8->UJ8_VLRINI .And. nIdadeBen <= QRYUJ8->UJ8_VLRFIM

						dCarencia := DaySum(dDtContr, QRYUJ8->UJ8_TEMPO)

						//Valido se ja foi checado alguma regra e se carencia e qual é a maior carencia
						//da regra do titular ou de qtde parcelas
						if !Empty(aRet[1])

							if Valtype(aRet[1]) == "D" .AND. aRet[1] < dCarencia

								aRet[1] := dCarencia
								aRet[2] := QRYUJ8->UJ8_ITEM

							endif

						else

							aRet[1] := dCarencia
							aRet[2] := QRYUJ8->UJ8_ITEM

						endif

					Endif

				Endif

				If AllTrim(QRYUJ8->UJ8_PARA) == "P" //Personalização

					aRet[1] := DaySum(dDtContr, QRYUJ8->UJ8_TEMPO)
					aRet[2] := QRYUJ8->UJ8_ITEM

				Endif

				QRYUJ8->(DbSkip())
			EndDo
		Endif
	Endif

	If Select("QRYUJ8") > 0
		QRYUJ8->(DbCloseArea())
	Endif

	RestArea(aArea)

Return(aRet)

/*/{Protheus.doc} RetInfoParc
funcao para retornar dados das parcelas do contrato
conforme os parametros

Quando o parametro 'cParcela' estiver fazio:
	- retorna a quantidade de parcelas pagas

Quando o parametro 'cParcela' estiver preenchido:
	- retorna a maior data de vencimento dentre as 
	parcelas do contrato

@type function
@version 
@author totvs
@since 25/02/2019
@param cContrato, character, codigo do contrato
@param cParcela, character, quantidade de parcelas
@return xRet, numerico ou dada, retorna a quantidade 
								parcelas pagas ou a maior data de vencimento
/*/
/***********************************/
Static Function RetInfoParc( cContrato, cParcela )
/***********************************/

	Local cPrefixo		:= SuperGetMv("MV_XPREFUN",.F.,"FUN")

	Local cTipoParc		:= SuperGetMv("MV_XTIPFUN",.F.,"AT")
	Local cTipoAdt		:= SuperGetMv("MV_XTIPADT",.F.,"ADT")
	Local cTipoRJ		:= SuperGetMv("MV_XTRJFUN",.F.,"RJ")

	Local cQry 			:= ""
	Local aAreaUF2		:= UF2->(GetArea())
	Local xRet			:= Nil

	Default cContrato	:= ""
	Default cParcela	:= ""

	If Select("QRYTIT") > 0
		QRYTIT->(dbCloseArea())
	EndIf

	//Chama para retornar quantidade de parcelas pagas
	if Empty(cParcela)

		cQry := " SELECT "
		cQry += " COUNT(*) QTD_PARCELAS "
		cQry += " FROM "
		cQry += " " + RetSQLName("SE1") + " "
		cQry += " WHERE "
		cQry += " D_E_L_E_T_ = ' ' "
		cQry += " AND E1_FILIAL = '" + xFilial("SE1") + "' "
		cQry += " AND ( 	E1_TIPO IN ('"+ cTipoParc + "','" + cTipoAdt + "','" + cTipoRJ + "')"
		cQry += "			OR E1_NUMLIQ <> ' ' )"
		cQry += " AND E1_XCTRFUN = '" + cContrato + "' "
		cQry += " AND E1_SALDO   = 0 "
		cQry += " AND E1_TIPOLIQ = ' '"
		cQry += " AND E1_FATURA  = ' '"

	else//chama para retornar data do vencimento da ultima parcela da carencia

		cQry := " SELECT MAX(TOP_VENC) TOP_VENC FROM( "
		cQry += " 	SELECT  TOP " + SOMA1(cParcela) + " E1_VENCREA TOP_VENC"
		cQry += " 	FROM "
		cQry += " "		+ RETSQLNAME("SE1") + " E1"
		cQry += " 	WHERE E1.D_E_L_E_T_	= ' '"
		cQry += " 	AND E1_FILIAL  		= '" + xFilial("SE1") 	+"'"
		cQry += " 	AND E1_XCTRFUN 		= '" + cContrato 		+ "'"
		cQry += "   AND ( 	E1_TIPO IN ('"+ cTipoParc + "','" + cTipoAdt + "','" + cTipoRJ + "')"
		cQry += "			OR E1_NUMLIQ <> ' ' )"
		cQry += " 	AND E1_TIPOLIQ 		= ' '"
		cQry += " 	AND E1_FATURA 		= ' '"
		cQry += " ) TOPFAT"

	endif

	cQry := Changequery(cQry)

	TcQuery cQry New Alias "QRYTIT"

	If QRYTIT->(!EOF())
		xRet := iif( Empty(cParcela), QRYTIT->QTD_PARCELAS, QRYTIT->TOP_VENC )
	Endif

	If Select("QRYTIT") > 0
		QRYTIT->(dbCloseArea())
	Endif

	RestArea(aAreaUF2)

Return(xRet)
