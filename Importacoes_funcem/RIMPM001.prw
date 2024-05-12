#include "protheus.ch"
#include "fwmvcdef.ch"
#include "topconn.ch"
#include 'FWEditPanel.CH'
#include 'Colors.ch'

/*/{Protheus.doc} RIMPM001
Cadastro de Layout de Importacao
@author Raphael Martins
@since 29/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RIMPM001()
/***********************/

	Local oBrowse

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias("UH8")
	oBrowse:SetDescription("Layout de Importacao")
	oBrowse:Activate()

Return Nil

/************************/
Static Function MenuDef()
/************************/

	Local aRotina 	:= {}
	Local aLayout	:= {}

	// rotinas para exportação do layout de importacao
	AAdd(aLayout, {"Estrutura dos Campos"			,"U_RIMPM01G()"			,0,4})
	AAdd(aLayout, {"Layout de Importacao"			,"U_RIMPM01H()"			,0,4})

	ADD OPTION aRotina Title "Visualizar" 						Action "VIEWDEF.RIMPM001"					OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Incluir"    						Action "VIEWDEF.RIMPM001"					OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title "Alterar"    						Action "VIEWDEF.RIMPM001"					OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Copiar'      						Action 'VIEWDEF.RIMPM001' 					OPERATION 9 ACCESS 0
	ADD OPTION aRotina Title "Excluir"    						Action "VIEWDEF.RIMPM001"					OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title "Exportar"    						Action aLayout								OPERATION 10 ACCESS 0
	ADD OPTION aRotina Title "Replicar Layouts"    				Action "U_VirtusImportacaoReplicaLayout()"	OPERATION 5 ACCESS 0

Return aRotina

/*************************/
Static Function ModelDef()
/*************************/

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruUH8 := FWFormStruct(1,"UH8",/*bAvalCampo*/,/*lViewUsado*/ )//Cabecalho do Layout
	Local oStruUH9 := FWFormStruct(1,"UH9",/*bAvalCampo*/,/*lViewUsado*/ )//Campos
	Local oStruUI0 := FWFormStruct(1,"UI0",/*bAvalCampo*/,/*lViewUsado*/ )//De-para
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("PIMPM001",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("UH8MASTER",/*cOwner*/,oStruUH8)

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({"UH8_FILIAL","UH8_CODIGO"})

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid("UH9DETAIL","UH8MASTER",oStruUH9,/*bLinePre*/{|oMdlG,nLine,cAcao,cCampo| EditGrid(oMdlG, nLine, cAcao, cCampo)},/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)
	oModel:AddGrid("UI0DETAIL","UH9DETAIL",oStruUI0,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation("UH9DETAIL", {{"UH9_FILIAL", 'xFilial("UH9")'},{"UH9_CODIGO","UH8_CODIGO"}},UH9->(IndexKey(1)))
	oModel:SetRelation("UI0DETAIL", {{"UI0_FILIAL", 'xFilial("UI0")'},{"UI0_CODIGO","UH8_CODIGO"},{"UI0_ITEMPA","UH9_ITEM"}},UI0->(IndexKey(1)))

	// Liga o controle de nao repeticao de linha
	oModel:GetModel('UH9DETAIL'):SetUniqueLine( {'UH9_CAMPO'} )

	// Desobriga a digitacao de ao menos um item
	oModel:GetModel("UI0DETAIL"):SetOptional(.T.)

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("UH8MASTER"):SetDescription("Dados Layout de Importacao:")
	oModel:GetModel("UH9DETAIL"):SetDescription("Campos:")
	oModel:GetModel("UI0DETAIL"):SetDescription("De-para:")

Return(oModel)

/************************/
Static Function ViewDef()
/************************/

	// Cria a estrutura a ser usada na View
	Local oStruUH8 := FWFormStruct(2,"UH8")
	Local oStruUH9 := FWFormStruct(2,"UH9")
	Local oStruUI0 := FWFormStruct(2,"UI0")


	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel("RIMPM001")
	Local oView

	// Remove campos da estrutura
	oStruUH9:RemoveField('UH9_CODIGO')
	oStruUI0:RemoveField('UI0_CODIGO')
	oStruUI0:RemoveField('UI0_ITEMPA')

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField("VIEW_UH8",oStruUH8,"UH8MASTER")

	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid("VIEW_UH9",oStruUH9,"UH9DETAIL")
	oView:AddGrid("VIEW_UI0",oStruUI0,"UI0DETAIL")

	// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox("PAINEL_CABEC",20)

	//Panel de Grids
	oView:CreateHorizontalBox("PAINEL_GRID",80)

	//Panel de Grid de Campos
	oView:CreateVerticalBox("PAINEL_CAMPOS",40,"PAINEL_GRID")

	//Panel de Grids de De_para
	oView:CreateVerticalBox("PAINEL_DE_PARA",60,"PAINEL_GRID")

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView("VIEW_UH8","PAINEL_CABEC")
	oView:SetOwnerView("VIEW_UH9","PAINEL_CAMPOS")
	oView:SetOwnerView("VIEW_UI0","PAINEL_DE_PARA")

	// Liga a identificacao do componente
	oView:EnableTitleView("VIEW_UH8","Dados Layout de Importacao:")
	oView:EnableTitleView("VIEW_UH9","Monte o Layout de Importação:")
	oView:EnableTitleView("VIEW_UI0","De-para:")

	// Define campos que terao Auto Incremento
	oView:AddIncrementField("VIEW_UH9","UH9_ITEM")
	oView:AddIncrementField("VIEW_UI0","UI0_ITEM")

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk( {||.T.} )

	// Habilito a barra de progresso na abertura da tela
	oView:SetProgressBar(.T.)

Return(oView)

/*/{Protheus.doc} RIMPM01A
Retorna rotinas disponiveis
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function RIMPM01A()

	Local cRotinasImp	:= ""
	Local cRotCustom	:= ""
	Local cMVRotCustom	:= SuperGetMV("MV_XROTCUS", .F., "")
	Local lFuneraria 	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio 	:= SuperGetMV("MV_XCEMI",,.F.)
	Local lPlanoEmp	  	:= SuperGetMV("MV_XPLNEMP", .F., .F.) // habilito o uso do plano empresarial

	cRotinasImp := "SA3=VENDEDORES;"
	cRotinasImp += "SA1=CLIENTES;"
	cRotinasImp += "SE1=PARCELAS;"

	// rotinas para o modulo de funeraria/planos
	if lFuneraria
		cRotinasImp += "UF2=FUNERARIA - CONTRATOS;"
		cRotinasImp += "UF9=FUNERARIA - MENSAGENS;"
		cRotinasImp += "UF4=FUNERARIA - BENEFICARIOS;"
		cRotinasImp += "UF3=FUNERARIA - PRODUTOS/SERVICOS;"
		cRotinasImp += "UJH=FUNERARIA - CONVALESCENTE;"
		cRotinasImp += "UJI=FUNERARIA - ITENS CONVALESCENTE;"
		cRotinasImp += "SE1CON=FUNERARIA - PARC.CONVALESCENTE;"

		if lPlanoEmp
			cRotinasImp += "UF2EMP=FUNERARIA - CTR.EMP.(PAI);"
			cRotinasImp += "UF2FIL=FUNERARIA - CTR.EMP.(FILHO);"
		endIf
	endIf

	// rotinas para o modulo de cemiterio
	if lCemiterio
		cRotinasImp += "U00=CEMITERIO - CONTRATOS;"
		cRotinasImp += "U03=CEMITERIO - MENSAGENS;"
		cRotinasImp += "U02=CEMITERIO - AUTORIZADOS;"
		cRotinasImp += "UJV=CEMITERIO - ENDERECAMENTO;"
		cRotinasImp += "U38=CEMITERIO - HISTORICO TRANSFERENCIAS;"
		cRotinasImp += "U41=CEMITERIO - RETIRADA DE CINZAS;"
		cRotinasImp += "U19=CEMITERIO - HIST.TRANSF.CESSIONARIO;"
	endIf

	if !Empty(cMVRotCustom) .And. ExistBlock("PECUSUH8") // ponto de entrada para importacao customizada
		cRotCustom := ExecBlock( "PECUSUH8", .F. ,.F. )

		If !Empty(cRotCustom)
			cRotinasImp	+= cRotCustom
		EndIf
	endIf

Return(cRotinasImp)

/*/{Protheus.doc} RIMPM01B
Retorna campos obrigatorios
da entidade selecionado 
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RIMPM01B()

	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUH8 	:= oModel:GetModel("UH8MASTER")
	Local oModelUH9 	:= oModel:GetModel("UH9DETAIL")
	Local oModelUI0 	:= oModel:GetModel("UI0DETAIL")
	Local cRotinaImp	:= oModelUH8:GetValue("UH8_ROTINA")
	Local cRotinaBkp	:= ""
	Local cMVRotCustom	:= SuperGetMV("MV_XROTCUS", .F., "")
	Local aCposChaves	:= {}
	Local aArea			:= GetArea()
	Local aAreaSX3		:= SX3->(GetArea())
	Local lRet			:= .T.
	Local aCampos		:= {}
	Local oSX3			:= UGetSxFile():New
	Local nX			:= 1

	//campos chaves que nao deverao ser carregados
	aCposChaves := {"UF3_VLRUNI","UF3_QUANT","A3_XCODANT","U00_CODANT",;
		"E1_PREFIXO","E1_TIPO","E1_PARCELA"}

	// tratamento para rotinas que nao tao tabela
	if cRotinaImp == "UF2EMP" .Or. cRotinaImp == "UF2FIL"

		if 	cRotinaImp == "UF2FIL"

			//campos chaves que nao deverao ser carregados
			aCposChaves := {"UF3_VLRUNI","UF3_QUANT","A3_XCODANT","U00_CODANT",;
				"E1_PREFIXO","E1_TIPO","E1_PARCELA", "UF2_PRIMVE", "UF2_VEND", "UF2_FORPG", "UF2_INDICE", "UF2_DTVENE"}

		endIf

		cRotinaBkp := cRotinaImp
		cRotinaImp := "UF2"
	elseIf cRotinaImp == "SE1CON"
		cRotinaBkp := cRotinaImp
		cRotinaImp := "SE1"
	elseIf ExistBlock("PEROTIMP") .And. AllTrim(cRotinaImp) $ cMVRotCustom
		cRotinaImp	:= ExecBlock( "PEROTIMP", .F. ,.F., { cRotinaImp } )

		// customizcao dos campos da importacao
		If ExistBlock("PERIMPCPO")
			aCposChaves	:= ExecBlock( "PERIMPCPO", .F. ,.F., { aCposChaves } )
		EndIf
	endIf

	if !Empty(cRotinaImp)

		aCampos := oSX3:GetInfoSX3(cRotinaImp)

		if Len(aCampos) > 0

			//limpo a acols de campos
			U_LimpaAcolsMVC(oModelUH9,oView)

			//limpo a acols de De-para
			oModelUI0:DelAllLine()

			if !Empty(cRotinaBkp)
				cRotinaImp := cRotinaBkp
			endIf

			//carrego campo chaves para importacao
			LoadCpoChave(cRotinaImp,oModelUH9)

			For nX:= 1 to Len(aCampos)

				if Ascan(aCposChaves,{|x| AllTrim(x) == aCampos[nX,2]:cCAMPO })== 0

					//carrego apenas campos reais e obrigatorios
					if aCampos[nX,2]:cCONTEXT <> 'V' .And. X3Obrigat( aCampos[nX,2]:cCAMPO ) .And.;
							Empty(aCampos[nX,2]:cRELACAO) .And. aCampos[nX,2]:cVISUAL <> 'V' .And.;
							UPPER( AllTrim(aCampos[nX,2]:cTITULO) ) <> "CLIENTE" .And.;
							UPPER( AllTrim(aCampos[nX,2]:cTITULO) ) <> "LOJA" .And.;
							UPPER( aCampos[nX,2]:cCAMPO ) <> "U38_ITEMEN"


						oModelUH9:GoLine(oModelUH9:Length())

						oModelUH9:AddLine()
						oModelUH9:GoLine(oModelUH9:Length())

						oModelUH9:LoadValue("UH9_ITEM",StrZero(oModelUH9:Length(),3))
						oModelUH9:LoadValue("UH9_CAMPO",aCampos[nX,2]:cCAMPO )
						oModelUH9:LoadValue("UH9_DESCRI",aCampos[nX,2]:cTITULO)
						oModelUH9:LoadValue("UH9_OBRIGA","CHECKED")

					endif

				endif

			Next nX

		else

			Help(,,'Help',,"Entidade do rotina selecionada não encontrada, favor selecione outra rotina",1,0)
			lRet := .F.

		endif

	endif

	//reposiciono no top as grids
	oModelUH9:GoLine(1)
	oModelUI0:GoLine(1)

	RestArea(aArea)
	RestArea(aAreaSX3)

Return(lRet)

/*/{Protheus.doc} LoadCpoChave
Funcao para carregar campos chaves
para importacao. Estes campos
nao NECESSARIAMENTE
fazem parte da tabela selecionada,
porem sao campos de chaves estrangeiras.
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function LoadCpoChave(cRotinaImp,oModelUH9)

	Local nLengthGrid	:= oModelUH9:Length()
	Local lRet			:= .T.
	Local lIncLinha		:= .F.
	Local lPlanoEmp	  	:= SuperGetMV("MV_XPLNEMP", .F., .F.) // habilito o uso do plano empresarial
	Local cMVRotCustom	:= SuperGetMV("MV_XROTCUS", .F., "")
	Local aCamposChv	:= {}
	Local aCamposCustom	:= {}
	Local nX			:= 0
	Local nI			:= 0

	if cRotinaImp == "SA3"

		Aadd(aCamposChv,{"A3_XCODANT","COD.LEGADO"})

	elseif cRotinaImp == "UF2"

		Aadd(aCamposChv,{"CGC","CGC TITULAR"})
		Aadd(aCamposChv,{"UF2_CODANT","COD.ANTERIOR"})
		Aadd(aCamposChv,{"BEN_LEG","BEN.LEGADO"})

	elseif cRotinaImp == "U00"

		Aadd(aCamposChv,{"CGC","CGC TITULAR"})
		Aadd(aCamposChv,{"U00_CODANT","COD.ANTERIOR"})

	elseif cRotinaImp == "SE1"

		Aadd(aCamposChv,{"COD_ANT"		,"COD.LEGADO"})
		Aadd(aCamposChv,{"E1_PREFIXO"	,"PREFIXO"})
		Aadd(aCamposChv,{"E1_TIPO"		,"TIPO"})
		Aadd(aCamposChv,{"E1_PARCELA"	,"PARCELA"})
		Aadd(aCamposChv,{"E1_EMISSAO"	,"EMISSAO"})
		Aadd(aCamposChv,{"E1_VENCTO"	,"VENCIMENTO"})

	elseif cRotinaImp == "UF3"

		Aadd(aCamposChv,{"COD_ANT","COD.LEGADO"})
		Aadd(aCamposChv,{"UF3_VLRUNI","Vlr Unitario"})
		Aadd(aCamposChv,{"UF3_QUANT","Quantidade"})

	elseif cRotinaImp == "UJH"

		Aadd(aCamposChv,{"COD_ANT"	 ,"COD.LEGADO" })
		Aadd(aCamposChv,{"UJH_CODLEG","CONV.LEGADO"})
		Aadd(aCamposChv,{"BEN_ANT"	 ,"BEN.LEGADO" })

	elseif cRotinaImp == "UJI"

		Aadd(aCamposChv,{"UJI_CODIGO","COD.LEGADO"})

	elseif cRotinaImp == "SE1CON"

		Aadd(aCamposChv,{"COD_ANT"		,"COD.LEGADO"})
		Aadd(aCamposChv,{"E1_XCONCTR"	,"CONVALESCE"})
		Aadd(aCamposChv,{"E1_PREFIXO"	,"PREFIXO"})
		Aadd(aCamposChv,{"E1_TIPO"		,"TIPO"})
		Aadd(aCamposChv,{"E1_PARCELA"	,"PARCELA"})
		Aadd(aCamposChv,{"E1_EMISSAO"	,"EMISSAO"})
		Aadd(aCamposChv,{"E1_VENCTO"	,"VENCIMENTO"})

	elseif cRotinaImp == "UJV"

		Aadd(aCamposChv,{"COD_ANT","COD.LEGADO"})
		Aadd(aCamposChv,{"UJV_SERVIC","SERVICO"})
		Aadd(aCamposChv,{"END_PREVIO","END.PREVIO"})
		Aadd(aCamposChv,{"UJV_DTSEPU","DATA SEPULT."})

	elseif cRotinaImp == "U38"

		Aadd(aCamposChv,{"COD_ANT","COD.LEGADO"})
		Aadd(aCamposChv,{"COD_IMP","COD.IMPORT"})
		Aadd(aCamposChv,{"U38_TPTRAN","TP TRANSF."})

	elseif cRotinaImp == "U41"

		Aadd(aCamposChv,{"COD_ANT","COD.LEGADO"})
		Aadd(aCamposChv,{"COD_IMP","COD.IMPORT"})
		Aadd(aCamposChv,{"U30_CREMAT","CREMATORIO"})
		Aadd(aCamposChv,{"U30_NICHOC","NICHO COLUMB"})
		Aadd(aCamposChv,{"U30_DTUTIL","DATA UTILIZA"})
		Aadd(aCamposChv,{"U30_QUEMUT","OBITO"})

	elseif cRotinaImp == "U19"

		Aadd(aCamposChv,{"COD_ANT","COD.LEGADO"})
		Aadd(aCamposChv,{"CGC_CLIANT","CGC.CLIANT"})
		Aadd(aCamposChv,{"CLI_ANT","COD.CLIANT"})
		Aadd(aCamposChv,{"U19_DATA","DAT_TRANSF"})
		Aadd(aCamposChv,{"U19_MOTIVO","MOT_TRANSF"})

	elseIf lPlanoEmp .And. cRotinaImp == "UF2EMP"

		Aadd(aCamposChv,{"CGC","CGC EMPRESA"})
		Aadd(aCamposChv,{"UF2_CODANT","COD.ANTERIOR"})

	elseIf lPlanoEmp .And. cRotinaImp == "UF2FIL"

		Aadd(aCamposChv,{"CGC","CGC TITULAR"})
		Aadd(aCamposChv,{"UF2_CODANT","COD.ANTERIOR"})
		Aadd(aCamposChv,{"BEN_LEG","BEN.LEGADO"})
		Aadd(aCamposChv,{"CGCEMP","RESP.FINANC"})

	elseIf ExistBlock("PECMPCUSTOM") .And. AllTrim(cRotinaImp) $ AllTrim(cMVRotCustom)

		aCamposCustom := ExecBlock("PECMPCUSTOM", .F., .F.)

		if Len(aCamposCustom) > 0
			For nI := 1 To Len(aCamposCustom)
				aAdd( aCamposChv, {aCamposCustom[nI, 1], aCamposCustom[nI, 2]} )
			Next nI
		else
			Aadd(aCamposChv,{"COD_ANT","COD.LEGADO"})
		endIf

	elseif cRotinaImp <> "SA1"

		Aadd(aCamposChv,{"COD_ANT","COD.LEGADO"})

	endif

	//incluo as linhas com os campos chaves
	For nX := 1 To Len(aCamposChv)

		//posiciono na ultima linha da grid
		oModelUH9:GoLine( oModelUH9:Length() )

		if lIncLinha

			oModelUH9:AddLine()
			oModelUH9:GoLine( oModelUH9:Length() )

		endif

		oModelUH9:LoadValue("UH9_ITEM",StrZero(oModelUH9:Length(),3))
		oModelUH9:LoadValue("UH9_CAMPO",aCamposChv[nX,1])
		oModelUH9:LoadValue("UH9_DESCRI",aCamposChv[nX,2])
		oModelUH9:LoadValue("UH9_OBRIGA","BR_VERMELHO")

		lIncLinha := .T.

	Next nX

Return(lRet)

/*/{Protheus.doc} EditGrid
Funcao na delecao ou restauracao da
grid de campos
do contrato
@author Raphael Martins
@since 30/11/2018
@version 1.0
@return lRet
@type function
/*/
Static Function EditGrid(oMdlG,nLine,cAcao)

	Local oModel		:= FWModelActive()
	Local oModelUH9		:= oModel:GetModel("UH9DETAIL")
	Local oView			:= FWViewActive()
	Local aSaveLines    := FWSaveRows()
	Local lRet			:= .T.

	//não permito a exclusao de campos obrigatorios da grid
	if cAcao == 'DELETE' .And. !IsInCallStack("U_LimpaAcolsMVC") .And. Alltrim(oModelUH9:GetValue("UH9_OBRIGA")) == "BR_VERMELHO"

		lRet := .F.
		Help(,,'Help',,"Não é possivel excluir campos obrigatórios para importação!",1,0)

	endif

	FWRestRows( aSaveLines )

Return(lRet)

/*/{Protheus.doc} RIMPM01C
Funcao para alterar a ordem 
da grid de campos para importacao 
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RIMPM01C()

	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUH9 	:= oModel:GetModel("UH9DETAIL")
	Local oModelUI0 	:= oModel:GetModel("UI0DETAIL")
	Local nPosItem		:= 0
	Local nDifItem		:= 0
	Local nLinhaPos		:= oModelUH9:GetLine()
	Local cItemAnt		:= ""
	Local cObrigat		:= ""
	Local cCampo		:= ""
	Local cDescri		:= ""
	Local cItem			:= ""
	Local lRet 			:= .T.
	Local nX			:= 1

	//pego a posicao do item no array aFieldid da View
	nPosItem := aScan( oView:aViews[2][3]:aFieldid,{|x| AllTrim(x)== "UH9_ITEM"})

	//pego a quantidade anterior a alteracao realizada
	cItemAnt := oView:aViews[2][3]:oBrowse:oData:oFormGrid:oBrowse:oData:aShow[oModelUH9:nLine][nPosItem]

	//item digitado
	cItem := oModelUH9:GetValue("UH9_ITEM")

	//valido se a posicao digitado esta dentro das posicoes de campos chave
	lRet := VldOrdem(cItem)

	if lRet

		//diferenca entre a quantidade digitada e o valor anterior
		nDifItem := Val(cItem) -  Val(cItemAnt)

		//verifico se alterei para baixo
		if nDifItem > 0

			//primeira linha a ser alterada
			For  nX	:= Val(cItemAnt) + 1 To Val(cItem)

				oModelUH9:GoLine(nX)

				If oModelUH9:LineShift( nX, nX - 1 )

					oModelUH9:GoLine( nX - 1 )

					oModelUH9:LoadValue( "UH9_ITEM", StrZero(nX - 1,3) )

					oModelUI0:Goline(1)

					oModelUH9:GoLine( nX )

					oModelUH9:LoadValue( "UH9_ITEM", StrZero(nX,3) )

					oModelUI0:Goline(1)

				endIf

			Next nX

		elseif nDifItem < 0

			//primeira linha a ser alterada
			For  nX	:= Val(cItemAnt) - 1 To Val(cItem) Step -1

				oModelUH9:GoLine(nX)

				If oModelUH9:LineShift( nX, nX + 1 )

					oModelUH9:GoLine( nX + 1 )

					oModelUH9:LoadValue( "UH9_ITEM", StrZero(nX + 1,3) )

					oModelUI0:Goline(1)

					oModelUH9:GoLine( nX )

					oModelUH9:LoadValue( "UH9_ITEM", StrZero(nX,3) )

					oModelUI0:Goline(1)

				endIf

			Next nX

		endif

		oView:Refresh()

		//retorno a linha posicionada
		oModelUH9:Goline(nLinhaPos)

	endif


Return(lRet)

/*/{Protheus.doc} RIMPM01D
Funcao para validar o campo 
UH9_CAMPO e gatilhar os demais campos
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RIMPM01D()

	Local aArea			:= GetArea()
	Local oModel		:= FWModelActive()
	Local oModelUH8 	:= oModel:GetModel("UH8MASTER")
	Local oModelUH9 	:= oModel:GetModel("UH9DETAIL")
	Local lRet 			:= .T.
	Local lMultiNat		:= .F.
	Local lAtivMultNat	:= SuperGetMV("MV_XMULNPA",.F.,.F.)	// rateio de multiplas naturezas virtus
	Local lMulNatR		:= SuperGetMV("MV_MULNATR",.F.,.F.)	// rateio de multiplas naturezas padrão
	Local cRotinaImp	:= oModelUH8:GetValue("UH8_ROTINA")
	Local cCampoSel		:= oModelUH9:GetValue("UH9_CAMPO")
	Local cObriga		:= ""
	Local cSeqMultNat	:= ""
	Local cRotinaBkp	:= ""
	Local nLenSeq		:= 0
	Local nItem			:= 0
	Local nLinhaBkp		:= 0
	Local nLinha 		:= 0
	Local aCampos		:= {}
	Local oSX3			:= UGetSxFile():New()

	if !Empty(cRotinaImp)

		// ========================================================
		// verifico se estou no layou de importacao da financeiro
		// e estou adicionando o campo natureza, para habilitar
		// o rateio de multiplas naturezas
		// ========================================================
		if lAtivMultNat .And. lMulNatR .And. cRotinaImp == "SE1" .And. "NATUREZA" $ Upper(cCampoSel)
			lMultiNat 	:= .T. // importacao de multiplas naturezas
			cSeqMultNat := SubStr(cCampoSel,9) // pego o sequencial que deve ser preenchido
			nLenSeq		:= Len(AllTrim(cSeqMultNat)) // tamanho do sequencial informado
			nSeqMulti	:= Val(cSeqMultNat) // o sequencial informado na

			if nSeqMulti > 0
				aAdd(aCampos,{cCampoSel, "NATUREZA " + Alltrim(cSeqMultNat), "UNCHECKED"})
				aAdd(aCampos,{"VALOR"+StrZero(nSeqMulti,nLenSeq), "VALOR " + Alltrim(cSeqMultNat), "UNCHECKED"})
			endIf

		else

			// tratamento para rotinas que nao tao tabela
			if cRotinaImp == "UF2EMP" .Or. cRotinaImp == "UF2FIL"
				cRotinaBkp := cRotinaImp
				cRotinaImp := "UF2"
			elseIf cRotinaImp == "SE1CON"
				cRotinaBkp := cRotinaImp
				cRotinaImp := "SE1"
			endIf

			aCampos := oSX3:GetInfoSX3(cRotinaImp,cCampoSel)

			if !Empty(cRotinaBkp)
				cRotinaImp	:= cRotinaBkp
			endIf

		endIf

		//valido se o campo digitado esta no dicionario e pertence a rotina preenchida
		if Len(aCampos) > 0

			if lMultiNat

				nLinhaBkp := oModelUH9:GetLine()

				for nItem := 1 to Len(aCampos)

					if Empty(oModelUH9:GetValue("UH9_CAMPO"))
						oModelUH9:LoadValue("UH9_CAMPO"	,aCampos[nItem,1])
					endIf

					oModelUH9:LoadValue("UH9_DESCRI",aCampos[nItem,2])
					oModelUH9:LoadValue("UH9_OBRIGA",aCampos[nItem,3])

					if nItem <> Len(aCampos)
						// adiciono a proxima linha
						oModelUH9:AddLine()
						oModelUH9:GoLine(oModelUH9:Length())
					endIf

				next nItem

				oModelUH9:GoLine(nLinhaBkp)

			else

				//verifico se o campo e obrigatorio
				cObriga := if(X3Obrigat( aCampos[1,2]:cCAMPO ),"CHECKED","UNCHECKED")

				oModelUH9:LoadValue("UH9_CAMPO"	,aCampos[1,2]:cCAMPO  )
				oModelUH9:LoadValue("UH9_DESCRI",aCampos[1,2]:cTITULO )
				oModelUH9:LoadValue("UH9_OBRIGA",cObriga)

			endIf

		else

			lRet := .F.
			Help(,,'Help',,"Campo selecionado não encontrado no dicionario de dados, favor selecione um campo válido!",1,0)

		endif

	else

		lRet := .F.
		Help(,,'Help',,"Rotina não encontrada, favor selecione uma rotina válida!",1,0)

	endif

	FreeObj(oSX3)

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} RIMPM01E
Funcao para retornar
inicializar padrao do campo 
descricao 
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RIMPM01E()

	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUH9 	:= oModel:GetModel("UH9DETAIL")
	Local cRet 			:= ""
	Local cCampo		:= Alltrim(UH9->UH9_CAMPO)

	if oModel:GetOperation() <> MODEL_OPERATION_INSERT

		if cCampo == "CGC"

			cRet := "CPF/CNPJ"

		elseif cCampo == "BEN_ANT"

			cRet := "BEN.ANTERIOR"

		elseif cCampo == "COD_ANT"

			cRet := "COD.ANTERIOR"

		elseif cCampo == "BEN_LEG"

			cRet := "BEN.LEGADO"

		elseif cCampo == "END_PREVIO"

			cRet := "END.PREVIO"

		elseif cCampo == "COD_IMP"

			cRet := "COD.IMPORT"

		else

			cRet := FWX3Titulo(UH9->UH9_CAMPO)

		endif


	endif

Return(cRet)

/*/{Protheus.doc} RIMPM01F
Funcao para validar se a ordem
digitadda e permitida
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function VldOrdem(cItem)

	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUH9 	:= oModel:GetModel("UH9DETAIL")
	Local lRet 			:= .T.
	Local nLinhaPos		:= oModelUH9:GetLine()

	//valido se a ordem digitada e negativo ou maior que a grid
	if Empty(cItem) .Or. Val(cItem) <= 0 .Or. Val(cItem) > oModelUH9:Length()

		Help(,,'Help',,"A Ordem informada não é válida.",1,0)
		lRet := .F.

	else

		//posiciono na linha digitada
		oModelUH9:GoLine(Val(cItem))

		if Alltrim(oModelUH9:GetValue("UH9_OBRIGA")) == "BR_VERMELHO"

			Help(,,'Help',,"Devido as configurações padrões não será possível alterar a ordem para esta posição!",1,0)
			lRet := .F.

		endif

	endif

	oModelUH9:GoLine(nLinhaPos)

Return(lRet)

/*/{Protheus.doc} RIMPM01F
Funcao para validar o modo de edicao
do campo ordem
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RIMPM01F()

	Local lRet := .T.

	if !Inclui .Or. Alltrim(FWFldGet("UH9_OBRIGA")) == "BR_VERMELHO"

		lRet := .F.

	endif

Return(lRet)

/*/{Protheus.doc} RIMPM01G
Estrutura dos Campos
@type function
@version 1.0
@author g.sampaio
@since 17/01/2024
/*/
User Function RIMPM01G()

	Local aTitulo 				:= {"Campo","Descricao","Tipo","Tamanho","Decimal"}
	Local cRelatorio			:= "Estrutura dos Campos"
	Local cTipoDescricao 		:= ""
	Local aAux					:= {}
	Local aDados 				:= {}
	Local aInformacao			:= {}
	Local cQuery 				:= ""
	Local cDescriCmp			:= ""
	Local nTamanho				:= 0
	Local oVirtusRelPlanilha	:= Nil
	Local oSX3					:= Nil

	cQuery := " SELECT * FROM " + RetSQLName("UH9") + " UH9 "
	cQuery += " WHERE UH9.D_E_L_E_T_ = ' ' "
	cQuery += " AND UH9.UH9_FILIAL = '" + xFilial("UH9") + "' "
	cQuery += " AND UH9.UH9_CODIGO = '" + UH8->UH8_CODIGO + "' "
	cQuery += " ORDER BY UH9.UH9_ITEM "

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery( cQuery, 'TRBUH9' )

	If TRBUH9->(!Eof())

		While TRBUH9->(!Eof())

			// limpo a descricao
			cTipoDescricao := ""

			oSX3		:= UGetSxFile():New()
			aDadosSX3 	:= oSX3:GetInfoSX3(Nil, TRBUH9->UH9_CAMPO)
			aAux 		:= {}

			If Len(aDadosSX3) > 0

				If aDadosSX3[1, 2]:cTipo == "C"
					cTipoDescricao := "Caractere"
				ElseIf aDadosSX3[1, 2]:cTipo == "D"
					cTipoDescricao := "Data"
				ElseIf aDadosSX3[1, 2]:cTipo == "N"
					cTipoDescricao := "Numérico"
				ElseIf aDadosSX3[1, 2]:cTipo == "M"
					cTipoDescricao := "Texto"
				ElseIf aDadosSX3[1, 2]:cTipo == "L"
					cTipoDescricao := "Lógico"
				EndIf

				Aadd( aAux, aDadosSX3[1, 1])
				Aadd( aAux, aDadosSX3[1, 2]:cDescri)
				Aadd( aAux, cTipoDescricao)
				Aadd( aAux, aDadosSX3[1, 2]:nTamanho)
				Aadd( aAux, aDadosSX3[1, 2]:nDecimal)

				// array de informacao
				Aadd(aInformacao, aAux)

				// reseta o objeto da SX3
				FreeObj(oSX3)
				oSX3 := Nil

			Elseif AllTrim(TRBUH9->UH9_CAMPO) == "CGC"
				cDescriCmp 	:= "CPF/CNPJ"
				nTamanho	:= TamSX3("A1_CGC")[1]
			elseif AllTrim(TRBUH9->UH9_CAMPO) == "BEN_ANT"
				cDescriCmp := "BEN.ANTERIOR"
				nTamanho	:= TamSX3("UF4_ITEM")[1]
			elseif AllTrim(TRBUH9->UH9_CAMPO) == "COD_ANT"
				cDescriCmp := "COD.ANTERIOR"
				nTamanho	:= TamSX3("UF2_CODANT")[1]
			elseif AllTrim(TRBUH9->UH9_CAMPO) == "BEN_LEG"
				cDescriCmp := "BEN.LEGADO"
				nTamanho	:= TamSX3("UF2_CODANT")[1]
			elseif AllTrim(TRBUH9->UH9_CAMPO) == "END_PREVIO"
				cDescriCmp := "END.PREVIO"
				nTamanho	:= TamSX3("U04_PREVIO")[1]
			elseif AllTrim(TRBUH9->UH9_CAMPO) == "COD_IMP"
				cDescriCmp := "COD.IMPORT"
				nTamanho	:= 6
			EndIf

			If Len(aAux) == 0
				Aadd( aAux, AllTrim(TRBUH9->UH9_CAMPO))
				Aadd( aAux, cDescriCmp)
				Aadd( aAux, "Caractere")
				Aadd( aAux, nTamanho)
				Aadd( aAux, 0)

				// array de informacao
				Aadd(aInformacao, aAux)
			EndIf

			TRBUH9->(DbSkip())
		EndDo

		// faco tratamento dos dados
		aDados := U_UTrataDados(aTitulo, aInformacao, Nil, .T.)

	Else
		MsgAlert("Não existem dados para impressão do Layout!")

	EndIf

	// verificava os dados
	If Len(aDados) > 0

		// atribuo valor as variaveis
		oVirtusRelPlanilha	:= Nil

		// inicio a classe de geracao de planilha
		oVirtusRelPlanilha := VirtusRelPlanilha():New()

		// faco a impressao da planilha
		oVirtusRelPlanilha:Imprimir(Nil, Nil, cRelatorio + " " + UH8->UH8_DESCRI, aTitulo, aDados)

	EndIf

Return(Nil)

/*/{Protheus.doc} RIMPM01H
Layout de Importacao
@type function
@version 1.0
@author g.sampaio
@since 17/01/2024
/*/
User Function RIMPM01H()

	Local aDadosSX3				:= {}
	Local cRelatorio			:= "Layout de Importacao"
	Local aTitulo 				:= {}
	Local cQuery 				:= ""
	Local oVirtusRelPlanilha	:= Nil
	Local oSX3					:= Nil

	cQuery := " SELECT * FROM " + RetSQLName("UH9") + " UH9 "
	cQuery += " WHERE UH9.D_E_L_E_T_ = ' ' "
	cQuery += " AND UH9.UH9_FILIAL = '" + xFilial("UH9") + "' "
	cQuery += " AND UH9.UH9_CODIGO = '" + UH8->UH8_CODIGO + "' "
	cQuery += " ORDER BY UH9.UH9_ITEM "

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery( cQuery, 'TRBUH9' )

	If TRBUH9->(!Eof())

		While TRBUH9->(!Eof())

			oSX3 		:= UGetSxFile():New()
			aDadosSX3 	:= oSX3:GetInfoSX3(Nil, TRBUH9->UH9_CAMPO)

			If Len(aDadosSX3) > 0

				// array de informacao
				Aadd(aTitulo, AllTrim(aDadosSX3[1, 2]:cDescri) + "(" + AllTrim(aDadosSX3[1, 1]) + ")" )

				// reseta o objeto da SX3
				FreeObj(oSX3)
				oSX3 := Nil
			Elseif AllTrim(TRBUH9->UH9_CAMPO) == "CGC"
				Aadd(aTitulo, AllTrim(TRBUH9->UH9_CAMPO) + "(CPF/CNPJ do Cliente)" )
			elseif AllTrim(TRBUH9->UH9_CAMPO) == "BEN_ANT"
				Aadd(aTitulo, AllTrim(TRBUH9->UH9_CAMPO) + "(Cod.Beneficiario Anterior)" )
			elseif AllTrim(TRBUH9->UH9_CAMPO) == "COD_ANT"
				Aadd(aTitulo, AllTrim(TRBUH9->UH9_CAMPO) + "(Codigo Legado do Contrato)")
			elseif AllTrim(TRBUH9->UH9_CAMPO) == "BEN_LEG"
				Aadd(aTitulo, AllTrim(TRBUH9->UH9_CAMPO) + "(Codigo do Beneficiario Legado do Contrato)" )
			elseif AllTrim(TRBUH9->UH9_CAMPO) == "END_PREVIO"
				Aadd(aTitulo, AllTrim(TRBUH9->UH9_CAMPO) + "(Enderecamento Previo)" )
			elseif AllTrim(TRBUH9->UH9_CAMPO) == "COD_IMP"
				Aadd(aTitulo, AllTrim(TRBUH9->UH9_CAMPO) + "(Codigo da Importacao de Endereco)")
			EndIf

			TRBUH9->(DbSkip())
		EndDo
	Else
		MsgAlert("Não existem dados para impressão do Layout!")

	EndIf

	// verificava os dados
	If Len(aTitulo) > 0

		// atribuo valor as variaveis
		oVirtusRelPlanilha	:= Nil

		// inicio a classe de geracao de planilha
		oVirtusRelPlanilha := VirtusRelPlanilha():New()

		// faco a impressao da planilha
		oVirtusRelPlanilha:Imprimir(Nil, Nil, + " " + UH8->UH8_DESCRI, aTitulo)

	EndIf

Return(Nil)
