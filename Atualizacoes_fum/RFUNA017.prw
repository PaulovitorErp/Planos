#include "protheus.ch"
#include "fwmvcdef.ch"
#include "topconn.ch"

/*/{Protheus.doc} RFUNA017
Apontamentos de Serviço
@author TOTVS
@since 25/08/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RFUNA017()
/***********************/ 

	Local oBrowse

	Private aRotina := {}
	Private oGetCalc
	Private nGetCalc := 0

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias("UG0")
	oBrowse:SetDescription("Apontamentos de Serviço")
	oBrowse:AddLegend("UG0_STATUS == 'A'", "BLUE",	"Apontamento")
	oBrowse:AddLegend("UG0_STATUS == 'P'", "GREEN",	"Gerou PV")
	oBrowse:AddLegend("UG0_STATUS == 'N'", "RED",	"Gerou NF")
	oBrowse:Activate()

Return Nil

/************************/
Static Function MenuDef()
/************************/

	aRotina 	:= {}

	ADD OPTION aRotina Title 'Visualizar' 				Action "VIEWDEF.RFUNA017"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Incluir"    				Action "VIEWDEF.RFUNA017"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title "Alterar"    				Action "VIEWDEF.RFUNA017"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Excluir"    				Action "VIEWDEF.RFUNA017"	OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title "Gerar PV"    				Action 'U_FUNA017G()'		OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Excluir PV" 				Action 'U_FUNA017E()'		OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'     				Action 'U_FUNA017L()' 		OPERATION 6 ACCESS 0

Return aRotina

/*************************/
Static Function ModelDef()
/*************************/

// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruUG0 := FWFormStruct(1,"UG0",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruUG1 := FWFormStruct(1,"UG1",/*bAvalCampo*/,/*lViewUsado*/ )

	Local oModel

// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("PFUNA017",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("UG0MASTER",/*cOwner*/,oStruUG0)

// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({"UG0_FILIAL","UG0_CODIGO"})

// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid("UG1DETAIL","UG0MASTER",oStruUG1,/*bLinePre*/{|oMdlG,nLine,cAcao,cCampo| ValDelUG1(oMdlG,nLine,cAcao,cCampo)},/*bLinePost*/{|oMdlG| ValLinUG1(oMdlG)},/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation("UG1DETAIL", {{"UG1_FILIAL", 'xFilial("UG1")'},{"UG1_CODIGO","UG0_CODIGO"}},UG1->(IndexKey(1)))

// Desobriga a digitacao de ao menos um item
//oModel:GetModel("SE1DETAIL"):SetOptional(.T.)

// Liga o controle de nao repeticao de linha
//oModel:GetModel("UG1DETAIL"):SetUniqueLine({"UG1_PRODUT"})

// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("UG0MASTER"):SetDescription("Dados")
	oModel:GetModel("UG1DETAIL"):SetDescription("Itens")

Return oModel

/************************/
Static Function ViewDef()
/************************/

// Cria a estrutura a ser usada na View
	Local oStruUG0 := FWFormStruct(2,"UG0")
	Local oStruUG1 := FWFormStruct(2,"UG1")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel("RFUNA017")
	Local oView
	Local oCalc1

// Remove campos da estrutura
	oStruUG1:RemoveField('UG1_CODIGO')
	oStruUG1:RemoveField('UG1_ITEM')

// Cria o objeto de View
	oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

// Crio um agrupador de campos
	oStruUG0:AddGroup( 'GRUPO01', 'Dados do Contrato', 		'', 2 )
	oStruUG0:AddGroup( 'GRUPO02', 'Dados do Beneficiário', 	'', 2 )
	oStruUG0:AddGroup( 'GRUPO03', 'Dados do PV', 			'', 2 )
	oStruUG0:AddGroup( 'GRUPO04', 'Demais dados', 			'', 2 )

// Colocando todos os campos para o agrupamento 2
	oStruUG0:SetProperty( '*' , MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )

// Trocando os campos do contrato para o agrupamento 1
	oStruUG0:SetProperty( 'UG0_CONTRA' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruUG0:SetProperty( 'UG0_CARENC' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruUG0:SetProperty( 'UG0_PERCDE' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )

// Trocando os campos do contrato para o agrupamento 2
	oStruUG0:SetProperty( 'UG0_CODBEN' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruUG0:SetProperty( 'UG0_NOMBEN' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )

// Trocando os campos do contrato para o agrupamento 3
	oStruUG0:SetProperty( 'UG0_CLIPV' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruUG0:SetProperty( 'UG0_LOJAPV' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruUG0:SetProperty( 'UG0_NOMPV' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruUG0:SetProperty( 'UG0_CONDPV' 	, MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruUG0:SetProperty( 'UG0_PV' 		, MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruUG0:SetProperty( 'UG0_MENNFS'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField("VIEW_UG0",oStruUG0,"UG0MASTER")

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid("VIEW_UG1",oStruUG1,"UG1DETAIL")

// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox("PAINEL_CABEC", 40)
	oView:CreateHorizontalBox("PAINEL_ITENS", 50)
	oView:CreateHorizontalBox("PAINEL_CALC", 10)

// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView("VIEW_UG0","PAINEL_CABEC")
	oView:SetOwnerView("VIEW_UG1","PAINEL_ITENS")

// Liga a identificacao do componente
//oView:EnableTitleView("VIEW_UG0","Dados")
	oView:EnableTitleView("VIEW_UG1","Itens")

// Define campos que terao Auto Incremento
	oView:AddIncrementField("VIEW_UG1","UG1_ITEM")

// Cria componentes nao MVC
	oView:AddOtherObject("TOTDESC", {|oPanel| FUNA017I(oPanel)})
	oView:SetOwnerView("TOTDESC",'PAINEL_CALC')

// Inicializacao do campo Contrato quando chamado pela rotina de Contrato
	bBloco := {|oView| IniCpoCont(oView)}
	oView:SetAfterViewActivate(bBloco)

// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk( {||.T.} )

Return oView

/***********************/
User Function FUNA017L()
/***********************/

	BrwLegenda("Status","Legenda",{{"BR_AZUL","Apontamento"},{"BR_VERDE","Gerou PV"},{"BR_VERMELHO","Gerou NF"}})

Return

/*******************************/
Static Function FUNA017I(oPanel)
/*******************************/

	Local oModel	:= FWModelActive()
	Local oModelUG1 := oModel:GetModel("UG1DETAIL")

	Local oSayCalc
	Local nAux		:= 0
	Local nI		:= 1

	@ (oPanel:nClientHeight / 2) - 25,005 SAY oSayCalc PROMPT "% desconto itens" SIZE 120, 010 OF oPanel COLORS 0,16777215 PIXEL
	@ (oPanel:nClientHeight / 2) - 15,005 MSGET oGetCalc VAR nGetCalc SIZE 040,010 WHEN .F. PIXEL OF oPanel PICTURE "@E 999.99" HASBUTTON

//Atualiza o Calc de acordo com o Grid
	For nI := 1 To oModelUG1:Length()

		// posiciono na linha atual
		oModelUG1:Goline(nI)

		If !oModelUG1:IsDeleted()

			If oModelUG1:GetValue("UG1_OK") .And. oModelUG1:GetValue("UG1_PV") == "S" //Gera PV
				nAux += (oModelUG1:GetValue("UG1_VLRDES") / oModelUG1:GetValue("UG1_PRCVEN")) * 100
			Endif
		Endif
	Next

	nGetCalc := nAux
	oGetCalc:Refresh()
Return

/********************************************************/
Static Function ValDelUG1(oModelGrid,nLinha,cAcao,cCampo)
/********************************************************/

	Local lRet   		:= .T.
	Local oModel     	:= oModelGrid:GetModel()
	Local nOperation 	:= oModel:GetOperation()

	Local cProd			:= oModelGrid:GetValue("UG1_PRODUT")

//Valida se pode ou não deletar uma linha do Grid
	If cAcao == 'DELETE' .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .And. !Empty(cProd)
		lRet := .F.
		Help( ,,'Help',,'Nao é permitido excluir linhas preenchidas automaticamente, de acordo com o Contrato selecionado.',1,0)
	EndIf

Return lRet

/************************************/
Static Function ValLinUG1(oModelGrid)
/************************************/

	Local oModel		:= FWModelActive()
	Local oModelUG0 	:= oModel:GetModel("UG0MASTER")
	Local oModelUG1		:= oModelGrid:GetModel("UG1DETAIL")
	Local nOperation	:= oModelUG1:GetOperation()
	Local nPercDesc		:= oModelUG0:GetValue("UG0_PERCDE")
	Local lRet			:= .T.
	Local nI			:= 0
	Local nTotDesc		:= 0
	Local nTotVal		:= 0
	Local nPerAplic		:= 0

	If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

		If oModelGrid:GetValue("UG1_OK") .And. Empty(oModelGrid:GetValue("UG1_QUANT"))
			Help( ,,'Help',,'Campo Quantidade obrigatório.',1,0)
			lRet := .F.
		Endif

		If lRet
			If !oModelGrid:GetValue("UG1_OK") .And. !Empty(oModelGrid:GetValue("UG1_QUANT"))
				Help( ,,'Help',,'Caso preencha a informação Quantidade caracterizando a realização do serviço, deve-se selecionar o respectivo item.',1,0)
				lRet := .F.
			Endif
		Endif

		If lRet

			If oModelUG0:GetValue("UG0_CARENC") == "S" .And. oModelGrid:GetValue("UG1_OK") .And. !Empty(oModelGrid:GetValue("UG1_VLRDES"))

				DbSelectArea("SB1")
				SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD

				If SB1->(DbSeek(xFilial("SB1")+oModelGrid:GetValue("UG1_PRODUT")))
					If SB1->B1_XPERDES == "N" //Não permite desconto
						Help( ,,'Help',,'O produto relacionado ao item, não permite inclusão de desconto.',1,0)
						lRet := .F.
					Endif
				Endif

			Endif

		Endif

		If lRet .And. oModelUG0:GetValue("UG0_CARENC") == "S"

			If nPercDesc > 0

				For nI := 1 To oModelGrid:Length()

					// posiciono na linha atual
					oModelGrid:Goline(nI)

					If !oModelGrid:IsDeleted()

						If oModelGrid:GetValue("UG1_PV") == "S" //Gera PV

							// Alterado por Wellington Gonçalves dia 24/04/2017
							// nAux += (oModelGrid:GetValue("UG1_VLRDES") / oModelGrid:GetValue("UG1_PRCVEN")) * 100

							if oModelGrid:GetValue("UG1_VLRDES") >= oModelGrid:GetValue("UG1_PRCVEN")
								Help( ,,'Help',,'O desconto do item não pode ser igual ou superior ao preço de venda.',1,0)
								lRet := .F.
								Exit
							else
								nTotDesc 	+= oModelGrid:GetValue("UG1_VLRDES")
								nTotVal 	+= oModelGrid:GetValue("UG1_PRCVEN")
							endif

						Endif

					Endif

				Next

				if lRet

					nPerAplic := nTotDesc / nTotVal * 100

					If nPerAplic > nPercDesc
						Help( ,,'Help',,'A soma dos valores de desconto excede o percentual de '+AllTrim(Transform(nPercDesc,"@E 999.99"))+' de acordo com o Contrato selecionado.',1,0)
						lRet := .F.
					Endif

					If lRet
						nGetCalc := nPerAplic
						oGetCalc:Refresh()
					Endif

				endif

			Endif

		Endif

		If lRet
			If oModelGrid:GetValue("UG1_OK") .And. Empty(oModelGrid:GetValue("UG1_PV"))
				Help( ,,'Help',,'Campo Gera PV obrigatório.',1,0)
				lRet := .F.
			Endif
		Endif

	Endif

Return lRet

/***********************/
User Function FUNA017G()
/***********************/

	Local lRet		:= .F.

	Local cPv		:= ""
	Local lAux		:= .F.

	If Empty(UG0->UG0_PV)

		//Valida a seleção de ao menos um item p/ PV
		DbSelectArea("UG1")
		UG1->(DbSetOrder(1)) //UG1_FILIAL+UG1_CODIGO+UG1_ITEM

		If UG1->(DbSeek(xFilial("UG1")+UG0->UG0_CODIGO))

			While UG1->(!EOF()) .And. xFilial("UG1") == UG1->UG1_FILIAL .And. UG1->UG1_CODIGO == UG0->UG0_CODIGO

				If UG1->UG1_OK .And. UG1->UG1_PV == "S"
					lAux := .T.
					Exit
				Endif

				UG1->(DbSkip())
			EndDo
		Endif

		If lAux

			If MsgYesNo("Será gerado Pedido de Venda para o apontamento selecionado, deseja continuar?")

				BeginTran()

				MsgRun("Gerando Pedido de Venda...","Aguarde",{|| lRet := U_GeraPV_F(@cPv)})

				//Atualiza status
				If lRet
					RecLock("UG0",.F.)
					UG0->UG0_PV 	:= cPv
					UG0->UG0_STATUS := "P" //Gerou PV
					UG0->(MsUnlock())
				Endif

			EndTran()
		Endif
	Else
		MsgInfo("No apontamento não consta nenhum item configurado para gerar Pedido de Venda.","Atenção")
	Endif
Else
	MsgInfo("Pedido de Venda já gerado para o apontamento selecionado.","Atenção")
Endif

Return

/***********************/
User Function FUNA017E()
/***********************/

	Local lRet	:= .F.

	If !Empty(UG0->UG0_PV)

		If MsgYesNo("Será estornado o Pedido de Venda para o apontamento selecionado, deseja continuar?")

			BeginTran()

			//Verifica se tem PV relacionado, se sim, exclui
			DbSelectArea("SC5")
			SC5->(DbOrderNickName("XAPONTSC5")) //C5_FILIAL+C5_XCTRFUN+C5_XAPTOFU

			DbSelectArea("SC6")
			SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

			DbSelectArea("SC9")
			SC9->(DbSetOrder(1)) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

			If SC5->(DbSeek(xFilial("SC5")+UG0->UG0_CONTRA+UG0->UG0_CODIGO))

				If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))

					While SC6->(!EOF()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM

						//Estorna liberação do PV
						If SC9->(DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM))
							a460Estorna()
						Endif

						SC6->(DbSkip())
					EndDo
				Endif

				MsgRun("Excluindo Pedido de Venda...","Aguarde",{|| lRet := ExcluiPV(UG0->UG0_PV)})
			Endif

			//Atualiza status
			If lRet
				RecLock("UG0",.F.)
				UG0->UG0_PV 	:= ""
				UG0->UG0_STATUS := "A" //Apontamento
				UG0->(MsUnlock())
			Endif

		EndTran()
	Endif
Else
	MsgInfo("Não há Pedido de Venda gerado para o apontamento selecionado.","Atenção")
Endif

Return

/*/{Protheus.doc} GeraPV_F
funcao para gerar o peddido de vendas do apontamento
de servicos funerario
@type function
@version 
@author totvs
@since 04/05/2020
@param cPv, character, numero do pedido de vendas
@return logico, retorna se gerou o pedido de venda corretamente
/*/
User Function GeraPV_F(cPv)

	Local lRet			:= .T.

	Local aCab 			:= {}
	Local aDados		:= {}
	Local aItens 		:= {}
	Local nI

	Local lCarencia		:= IIF(UG0->UG0_CARENC == "N",.F.,.T.)
	Local cClassi		:= IIF(lCarencia,"A","C") //A=Carencia;C=Contrato;E=Carente;I=Indigente
	Local cNat			:= Posicione("UF2",1,xFilial("UF2") + UG0->UG0_CONTRA ,"UF2_NATURE")
	Local cTabPad		:= Alltrim(SuperGetMv("MV_XTABPAD","001"))
	Local cOpFinSEst	:= SuperGetMv("MV_XOPFSEN",.F.,"08")
	Local cOpFinCEst	:= SuperGetMv("MV_XOPFSES",.F.,"09")
	Local cOpNFinNEst	:= SuperGetMv("MV_XOPFNEN",.F.,"10")
	Local cOpNFinCEst	:= SuperGetMv("MV_XOPFNES",.F.,"11")
	Local cOper			:= ""

	Local nItem			:= 0

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	Default cPv			:= ""

	DbSelectArea("SC5")

	AAdd(aCab, {"C5_TIPO" 		,"N" 				,Nil})
	AAdd(aCab, {"C5_CLIENTE" 	,UG0->UG0_CLIPV 	,Nil})
	AAdd(aCab, {"C5_LOJACLI" 	,UG0->UG0_LOJAPV 	,Nil})
	AAdd(aCab, {"C5_CONDPAG" 	,UG0->UG0_CONDPV	,Nil})
	AAdd(aCab, {"C5_EMISSAO" 	,dDataBase 			,Nil})
	AAdd(aCab, {"C5_MOEDA" 		,1 					,Nil})
	AAdd(aCab, {"C5_NATUREZ" 	,cNat		 		,Nil})
	AAdd(aCab, {"C5_XMENNFS"	,UG0->UG0_MENNFS	,Nil})
	AAdd(aCab, {"C5_XAPTOFU"	,UG0->UG0_CODIGO	,Nil})
	AAdd(aCab, {"C5_XCTRFUN"	,UG0->UG0_CONTRA	,Nil})
	AAdd(aCab, {"C5_XCLASSI"	,cClassi			,Nil})
	AAdd(aCab, {"C5_TABELA"		,cTabPad			,Nil})

	DbSelectArea("UG1")
	UG1->(DbSetOrder(1)) //UG1_FILIAL+UG1_CODIGO+UG1_ITEM

	If UG1->(DbSeek(xFilial("UG1")+UG0->UG0_CODIGO))

		While UG1->(!EOF()) .And. xFilial("UG1") == UG1->UG1_FILIAL .And. UG1->UG1_CODIGO == UG0->UG0_CODIGO

			If UG1->UG1_OK .And. UG1->UG1_PV == "S"

				aDados	:= {}
				nItem++

				AAdd(aDados,{"C6_ITEM" 		,StrZero(nItem,TamSX3("C6_ITEM")[1])	,Nil})
				AAdd(aDados,{"C6_PRODUTO" 	,UG1->UG1_PRODUTO						,Nil})

				If lCarencia

					If Posicione("SB1",1,xFilial("SB1")+UG1->UG1_PRODUTO,"B1_TIPO") == "SV" //Serviço

						cOper := Alltrim(cOpFinSEst) //Operação gera Financeiro, não movimenta Estoque
					Else
						cOper := Alltrim(cOpFinCEst)//Operação gera Financeiro, movimenta Estoque
					Endif
				Else

					If Posicione("SB1",1,xFilial("SB1")+UG1->UG1_PRODUTO,"B1_TIPO") == "SV" //Serviço

						cOper := Alltrim(cOpNFinNEst)//Operação não gera Financeiro, não movimenta Estoque
					Else
						cOper := Alltrim(cOpNFinCEst) //Operação não gera Financeiro, movimenta Estoque
					Endif
				Endif

				AAdd(aDados,{"C6_QTDVEN" 	,UG1->UG1_QUANT							,Nil})
				AAdd(aDados,{"C6_PRCVEN" 	,UG1->UG1_PRCVEN - UG1->UG1_VLRDES		,Nil})
				AAdd(aDados,{"C6_OPER" 		,cOper									,Nil})
				//AAdd(aDados,{"C6_TES" 		,cTes									,Nil})

				AAdd(aItens,aDados)
			Endif

			UG1->(DbSkip())
		EndDo
	Endif

	MSExecAuto({|X,Y,Z|Mata410(X,Y,Z)},aCab,aItens,3)

	If lMsErroAuto
		lRet := .F.
		MostraErro()
		DisarmTransaction()
		cPv := ""
	Else
		cPv := SC5->C5_NUM
		MsgInfo("Pedido de Venda <"+AllTrim(cPv)+"> gerado com sucesso.","Atenção")
	EndIf

Return(lRet)

/****************************/
Static Function ExcluiPV(cPv)
/****************************/

	Local lRet			:= .T.

	Local aCab 			:= {}
	Local aItens 		:= {}

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	If !Empty(cPv)

		DbSelectArea("SC5")
		SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM

		If SC5->(DbSeek(xFilial("SC5")+cPv))

			AAdd(aCab, {"C5_NUM" 	,SC5->C5_NUM 	,Nil})

			AAdd(aItens,{"C6_NUM" 	,SC5->C5_NUM	,Nil})

			MSExecAuto({|X,Y,Z|Mata410(X,Y,Z)},aCab,{aItens},5)

			If lMsErroAuto
				lRet := .F.
				MostraErro()
				DisarmTransaction()
			Else
				MsgInfo("Pedido de Venda <"+AllTrim(cPv)+"> excluído com sucesso.","Atenção")
			EndIf
		Else
			MsgInfo("Pedido de Venda <"+AllTrim(cPv)+"> não localizado.","Atenção")
			lRet := .F.
		Endif
	Else
		MsgInfo("Não Pedido de Venda relacionado a este apontamento.","Atenção")
		lRet := .F.
	Endif

Return lRet

/*********************/
User Function ContrF()
/*********************/

	Local cRet

	cRet := M->UG0_CONTRA

Return cRet

/*************************************/
User Function ValBenef(cContra,cBenef)
/*************************************/

	Local lRet 	:= .T.
	Local cQry	:= ""

	DbSelectArea("UF4")
	UF4->(DbSetOrder(1)) //UF4_FILIAL+UF4_CODIGO+UF4_ITEM

	If UF4->(DbSeek(xFilial("UF4")+cContra+cBenef))

		If Select("QRYAPT") > 0
			QRYAPT->(DbCloseArea())
		Endif

		cQry := "SELECT UG0_CODIGO"
		cQry += " FROM "+RetSqlName("UG0")+""
		cQry += " WHERE D_E_L_E_T_ 	<> '*'"
		cQry += " AND UG0_FILIAL 	= '"+xFilial("UG0")+"'"
		cQry += " AND UG0_CONTRA 	= '"+cContra+"'"
		cQry += " AND UG0_CODBEN 	= '"+cBenef+"'"

		cQry := ChangeQuery(cQry)
		TcQuery cQry NEW Alias "QRYAPT"

		If QRYAPT->(!EOF())
			Help(,,'Help',,"Beneficiário possui Apontamento de Serviço relacionado, operação não permitida.",1,0)
			lRet := .F.
		Endif

		If Select("QRYAPT") > 0
			QRYAPT->(DbCloseArea())
		Endif
	Else
		Help(,,'Help',,"Beneficiário inválido.",1,0)
		lRet := .F.
	Endif

Return lRet

/*********************************/
User Function ValCliPv(cCli,cLoja)
/*********************************/

	Local lRet 	:= .T.

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

	If !Empty(cCli) .And. !Empty(cLoja)

		If !SA1->(DbSeek(xFilial("SA1")+cCli+cLoja))
			Help(,,'Help',,"Cliente inválido.",1,0)
			lRet := .F.
		Endif
	Endif

Return lRet

/*****************************/
User Function FUNA017P(cContr)
/*****************************/

	Local cQry		:= ""
	Local cCodTab	:= SuperGetMv("MV_XTABPAD",.F.,"001")
	Local aArea		:= GetArea()

	Local oModel	:= FWModelActive()
	Local oView		:= FWViewActive()
	Local oModelUG0 := oModel:GetModel("UG0MASTER")
	Local oModelUG1 := oModel:GetModel("UG1DETAIL")

	U_LimpaAcolsMVC(oModelUG1,oView)

	If Select("QRYUF3") > 0
		QRYUF3->(DbCloseArea())
	Endif

	cQry := "SELECT UF3.UF3_PROD, ISNULL(DA1.DA1_PRCVEN,0) AS DA1_PRCVEN"
	cQry += " FROM "+RetSqlName("UF3")+" UF3 LEFT JOIN "+RetSqlName("DA1")+" DA1 ON UF3.UF3_PROD 		= DA1.DA1_CODPRO"
	cQry += " 																		AND DA1.D_E_L_E_T_ 	<> '*'"
	cQry += " 																		AND DA1.DA1_FILIAL 	= '"+xFilial("DA1")+"'"
	cQry += " 																		AND DA1.DA1_CODTAB	= '"+cCodTab+"'"
	cQry += " WHERE UF3.D_E_L_E_T_ 	<> '*'"
	cQry += " AND UF3.UF3_FILIAL 	= '"+xFilial("UF3")+"'"
	cQry += " AND UF3.UF3_CODIGO 	= '"+cContr+"'"
//nao possibilito incluir produto sem saldo no apontamento
	cQry += " AND UF3.UF3_SALDO > 0 "


	cQry += " ORDER BY 1 DESC"

	cQry := ChangeQuery(cQry)
	TcQuery cQry NEW Alias "QRYUF3"

	If QRYUF3->(!EOF())

		While QRYUF3->(!EOF())

			//Se a primeira linha não estiver em branco, insiro uma nova linha
			If !Empty(oModelUG1:GetValue("UG1_PRODUT"))
				oModelUG1:AddLine()
				oModelUG1:GoLine(oModelUG1:Length())
			Endif

			oModelUG1:LoadValue("UG1_OK",		.F.)
			oModelUG1:LoadValue("UG1_PRODUT",	QRYUF3->UF3_PROD)
			oModelUG1:LoadValue("UG1_DESC",		Posicione("SB1",1,xFilial("SB1")+QRYUF3->UF3_PROD,"B1_DESC"))
			oModelUG1:LoadValue("UG1_PRCVEN",	QRYUF3->DA1_PRCVEN)
			oModelUG1:LoadValue("UG1_QUANT",	0)
			oModelUG1:LoadValue("UG1_VLRDES",	0)

			QRYUF3->(DbSkip())
		EndDo
	Endif

	oModelUG1:GoLine(1)

	If oView <> nil
		oView:Refresh()
	EndIf

	RestArea(aArea)

Return .T.

/********************************/
Static Function IniCpoCont(oView)
/********************************/

	Local nOperation := oView:GetOperation()

	If nOperation == 3 //Inclusão

		If AllTrim(FunName()) == "RFUNA002" //Contrato

			FwFldPut("UG0_CONTRA",UF2->UF2_CODIGO,,,,.F.)

			oView:Refresh()
		EndIf
	EndIf

Return

/*/{Protheus.doc} VldCarCtr
//Funcao para validar a carencia do contrato.
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function VldCarCtr(cContrato)

	Local cRet			:= "N"
	Local aArea			:= GetArea()
	Local aAreaUF2		:= UF2->(GetArea())
	Local cQry			:= ""
	Local cPrefixo		:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
	Local cTipoParc		:= SuperGetMv("MV_XTIPFUN",.F.,"AT")
	Local cTipoAdt		:= SuperGetMv("MV_XTIPADT",.F.,"ADT")

	UF2->(DbSetOrder(1)) //UF2_FILIAL+UF2_CODIGO

//posiciono no contrato a ser validado
	if UF2->(DbSeek(xFilial("UF2")+cContrato))

		//valido o tipo de carencia, sendo por 1=tempo ou 2=parcelas
		if UF2->UF2_TIPOCA == '1'

			if dDataBase <= UF2->UF2_CARENC

				cRet := 'S'

			endif

		else

			// consulto as parcelas pagas do contrato
			cQry := " SELECT "
			cQry += " COUNT(*) PARCEL_PAGAS  "
			cQry += " FROM " + RetSQLName("SE1") "
			cQry += " WHERE
			cQry += " D_E_L_E_T_ = ' '
			cQry += " AND E1_FILIAL = '" + xFilial("SE1") + "'
			cQry += " AND E1_PREFIXO = '"+cPrefixo+"'
			cQry += " AND E1_NUM = '" + cContrato + "'
			cQry += " AND E1_TIPO IN ('" + cTipoParc + "','" + cTipoAdt + "') "
			cQry += " AND E1_XCTRFUN = '" + cContrato + "'
			cQry += " AND E1_SALDO = 0
			cQry += " AND E1_BAIXA <> ' '

			If Select("QRYPARC") > 0
				QRYPARC->(dbCloseArea())
			EndIf

			cQry := Changequery(cQry)

			TcQuery cQry New Alias "QRYPARC"


			//valido se a quantidade paga e maior que a quantidade da carencia
			if UF2->UF2_QTPCAR > QRYPARC->PARCEL_PAGAS

				//dentro da carencia
				cRet := 'S'

			endif

		endif


	endif


	RestArea(aArea)
	RestArea(aAreaUF2)

Return(cRet)