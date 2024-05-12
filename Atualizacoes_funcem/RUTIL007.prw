#include "protheus.ch"
#include "fwmvcdef.ch"
#include "topconn.ch"

/*/{Protheus.doc} RUTIL007
Clausulas
@author TOTVS
@since 03/01/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

/***********************/
User Function RUTIL007()
/***********************/

	Local oBrowse

	Private aRotina := {}

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias("UGB")
	oBrowse:SetDescription("Cláusulas Contratos")
	oBrowse:AddLegend("UGB_STATUS == 'A'", "GREEN",	"Ativa")
	oBrowse:AddLegend("UGB_STATUS == 'I'", "RED",	"Inativa")
	oBrowse:Activate()

Return Nil

/************************/
Static Function MenuDef()
/************************/

	Local aRotina 	:= {}

	ADD OPTION aRotina Title 'Visualizar' 	Action "VIEWDEF.RUTIL007"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Incluir"    	Action "VIEWDEF.RUTIL007"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title "Alterar"    	Action "VIEWDEF.RUTIL007"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Excluir"    	Action "VIEWDEF.RUTIL007"	OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'     	Action 'U_UTIL007L()' 		OPERATION 6 ACCESS 0

Return aRotina

/*************************/
Static Function ModelDef()
/*************************/

// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruUGB := FWFormStruct(1,"UGB",/*bAvalCampo*/,/*lViewUsado*/ )

	Local oModel

// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("PUTIL007",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("UGBMASTER",/*cOwner*/,oStruUGB)

// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({"UGB_FILIAL","UGB_CODIGO"})

// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("UGBMASTER"):SetDescription("Cláusulas Contratos")

Return oModel

/************************/
Static Function ViewDef()
/************************/

// Cria a estrutura a ser usada na View
	Local oStruUGB := FWFormStruct(2,"UGB")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel("RUTIL007")
	Local oView

// Remove campos da estrutura
//oStruUGB:RemoveField('UGB_CODIGO')

// Cria o objeto de View
	oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField("VIEW_UGB",oStruUGB,"UGBMASTER")

// Criar "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox("PAINEL_CABEC", 60)
	oView:CreateHorizontalBox("PAINEL_LEG", 40)

// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView("VIEW_UGB","PAINEL_CABEC")

// Liga a identificacao do componente
	oView:EnableTitleView("VIEW_UGB","Cláusulas Contratos")

// Cria componentes nao MVC
	oView:AddOtherObject("LEGENDA", {|oPanel| UTIL007R(oPanel)})
	oView:SetOwnerView("LEGENDA",'PAINEL_LEG')
	oView:EnableTitleView("LEGENDA","Legenda")

// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk( {||.T.} )

Return oView

/***********************/
User Function UTIL007L()
/***********************/

	BrwLegenda("Status","Legenda",{{"BR_VERDE","Ativa"},{"BR_VERMELHO","Inativa"}})

Return

/*******************************/
Static Function UTIL007R(oPanel)
/*******************************/

	Local oPanelPrinc
	Local oFont07N		:= TFont():New("Verdana",07,18,,.T.,,,,.T.,.F.) ///Fonte 14 Negrito
	Local oSay1
	Local cGet1

	Local cTexto		:= ""
	Local oFile
	Local cFile			:= ""
	Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
	Local lContinua		:= .F.
	Local cSystem		:= Upper(GetSrvProfString("STARTPATH",""))

	@ 000, 000 MSPANEL oPanelPrinc SIZE oPanel:nClientWidth / 2 , oPanel:nClientHeight / 2 OF oPanel COLORS 0, 15724527 RAISED
	@ 005, 005 SAY oSay1 PROMPT "Variáveis disponíveis:" SIZE 160, 010 OF oPanelPrinc FONT oFont07N COLORS CLR_BLUE,16777215 PIXEL
	@ 015, 005 GET oGet1 VAR cTexto MEMO SIZE (oPanelPrinc:nClientWidth / 2) - 10, (oPanelPrinc:nClientHeight / 2) - 20 OF oPanelPrinc COLORS 0, 16777215 PIXEL
	oGet1:lReadOnly := .T.

	If lCemiterio

		If File(cSystem + "\var_cemiterio.txt")
			cFile := cSystem + "\var_cemiterio.txt"
			lContinua := .T.
		Else
			cTexto := "Arquivo var_cemiterio nao localizado no diretorio \system\ do servidor de aplicacao."
		Endif
	Else
		If File(cSystem + "\var_funeraria.txt")
			cFile := cSystem + "\var_funeraria.txt"
			lContinua := .T.
		Else
			cTexto := "Arquivo var_cemiterio nao localizado no diretorio \system\ do servidor de aplicacao."
		Endif
	Endif

	If lContinua

		oFile := FWFileReader():New(cFile)

		If (oFile:Open())

			While (oFile:hasLine())
				cTexto += oFile:GetLine(.T.)
			EndDo

			oFile:Close()
		Endif
	Endif

	If Empty(cTexto)

		If lCemiterio
			cTexto := "Arquivo \system\var_cemiterio.txt vazio."
		Else
			cTexto := "Arquivo \system\var_funeraria.txt vazio."
		Endif
	Endif

	oGet1:Refresh()

Return

/***************************************/
User Function VlOrdImp(cClausula,nOrdem)
/***************************************/

	Local lRet := .T.

	If Select("QRYUGB") > 0
		QRYUGB->(DbCloseArea())
	Endif

	cQry := "SELECT UGB_ORDIMP"
	cQry += " FROM "+RetSqlName("UGB")+""
	cQry += " WHERE D_E_L_E_T_ 	<> '*'"
	cQry += " AND UGB_FILIAL 	= '"+xFilial("UGB")+"'"
	cQry += " AND UGB_ORDIMP 	= '"+cValToChar(nOrdem)+"'"
	cQry += " AND UGB_CODIGO 	<> '"+cClausula+"'"

	cQry := ChangeQuery(cQry)
	TcQuery cQry NEW Alias "QRYUGB"

	If QRYUGB->(!EOF())
		Help(,,'Help',,"Ordem ja utilizada em outro cadastro, favor alterar.",1,0)
		lRet := .F.
	Endif

	If Select("QRYUGB") > 0
		QRYUGB->(DbCloseArea())
	Endif

Return lRet

User Function UTIL007V(cTexto)

	Local aRetorno 	:= {}
	Local cAuxTexto	:= ""
	Local cPosTexto	:= ""
	Local cValTroca	:= ""
	Local nPos 		:= 1
	Local nPosVar	:= 0

	Default cTexto	:= ""

	//======================================
	// Trata a variável {{DATA_RETIRADA}}
	//======================================
	While (nPos > 0)
		nPos := At("{{CNV_DATA_RETIRADA}}", cTexto, nPos)
		if (nPos > 0)
			cValTroca := U_RFUNR37V("{{CNV_DATA_RETIRADA}}")
			cTexto := StrTran(cTexto, "{{CNV_DATA_RETIRADA}}", cValTroca)
			nPos++
		endif
	EndDo

	// reinicio a variavel
	nPos := 1

	//======================================
	// Trata a variável {{DATA_DEVOLUCAO}}
	//======================================
	While (nPos > 0)
		nPos := At("{{CNV_DATA_DEVOLUCAO}}", cTexto, nPos)
		if (nPos > 0)
			cValTroca := U_RFUNR37V("{{CNV_DATA_DEVOLUCAO}}")
			cTexto := StrTran(cTexto, "{{CNV_DATA_DEVOLUCAO}}", cValTroca)
			nPos++
		endif
	EndDo

	// reinicio a variavel
	nPos := 1

	//======================================
	// Trata a variável {{DATA_DEVOLUCAO}}
	//======================================
	While (nPos > 0)
		nPos := At("{{CNV_DIAS_RETORNO}}", cTexto, nPos)
		if (nPos > 0)
			cValTroca := U_RFUNR37V("{{CNV_DIAS_RETORNO}}")
			cTexto := StrTran(cTexto, "{{CNV_DIAS_RETORNO}}", cValTroca)
			nPos++
		endif
	EndDo

	// reinicio a variavel
	nPos := 1

	//======================================
	// Trata a variável {{CNV_DIAS_RETORNO_EXTENSO}}
	//======================================
	While (nPos > 0)
		nPos := At("{{CNV_DIAS_RETORNO_EXTENSO}}", cTexto, nPos)
		if (nPos > 0)
			cValTroca := U_RFUNR37V("{{CNV_DIAS_RETORNO_EXTENSO}}")
			cTexto := StrTran(cTexto, "{{CNV_DIAS_RETORNO_EXTENSO}}", cValTroca)
			nPos++
		endif
	EndDo

	// reinicio a variavel
	nPos := 1

	//======================================
	// Trata a variável {{CNV_VALOR_EQUIP}}
	//======================================
	While (nPos > 0)
		nPos := At("{{CNV_VALOR_EQUIP}}", cTexto, nPos)
		if (nPos > 0)
			cValTroca := U_RFUNR37V("{{CNV_VALOR_EQUIP}}")
			cTexto := StrTran(cTexto, "{{CNV_VALOR_EQUIP}}", cValTroca)
			nPos++
		endif
	EndDo

	// reinicio a variavel
	nPos := 1

	//======================================
	// Trata a variável {{CNV_VALOR_EQUIP_EXTENSO}}
	//======================================
	While (nPos > 0)
		nPos := At("{{CNV_VALOR_EQUIP_EXTENSO}}", cTexto, nPos)
		if (nPos > 0)
			cValTroca := U_RFUNR37V("{{CNV_VALOR_EQUIP_EXTENSO}}")
			cTexto := StrTran(cTexto, "{{CNV_VALOR_EQUIP_EXTENSO}}", cValTroca)
			nPos++
		endif
	EndDo

	// reinicio a variavel
	nPos := 1

	//======================================
	// Trata a variável {{CNV_DIA_VENC}}
	//======================================
	While (nPos > 0)
		nPos := At("{{CNV_DIA_VENC}}", cTexto, nPos)
		if (nPos > 0)
			cValTroca := U_RFUNR37V("{{CNV_DIA_VENC}}")
			cTexto := StrTran(cTexto, "{{CNV_DIA_VENC}}", cValTroca)
			nPos++
		endif
	EndDo

	// reinicio a variavel
	nPos := 1

	//======================================
	// Trata a variável {{CNV_DIA_VENC_EXTENSO}}
	//======================================
	While (nPos > 0)
		nPos := At("{{CNV_DIA_VENC_EXTENSO}}", cTexto, nPos)
		if (nPos > 0)
			cValTroca := U_RFUNR37V("{{CNV_DIA_VENC_EXTENSO}}")
			cTexto := StrTran(cTexto, "{{CNV_DIA_VENC_EXTENSO}}", cValTroca)
			nPos++
		endif
	EndDo

	// reinicio a variavel
	nPos := 1

	//======================================
	// Trata a variável {{CNV_EQUIPAMENTOS}}
	//======================================
	While (nPos > 0)
		nPos := At("{{CNV_EQUIPAMENTOS}}", cTexto, nPos)
		nPosVar := Len("{{CNV_EQUIPAMENTOS}}" + chr(13)+chr(10) + chr(13)+chr(10))
		if (nPos > 0)
			cAuxTexto := SubStr(cTexto, 1, nPos - 1)
			cPosTexto := SubStr(cTexto, nPos + nPosVar)
			Aadd(aRetorno, {"{{CNV_EQUIPAMENTOS}}", cAuxTexto, cPosTexto, nPos, nPos + nPosVar})
			nPos++
		endif
	EndDo

Return(aRetorno)
