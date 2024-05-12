#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMVCDEF.CH'

#DEFINE CRLF Chr(13) + Chr(10)

#DEFINE MODEL_OPERATION_COPY 09

/*/{Protheus.doc} RFUNA054
Cadastro de Regras de Reajuste de Contratos
@type function
@version 1.0
@author nata.queiroz
@since 16/12/2020
/*/
User Function RFUNA054()

	Local oBrowse	:= {}

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("UI4")
	oBrowse:SetDescription("Regras de Reajuste")
	oBrowse:SetMenuDef("RFUNA054")

	oBrowse:Activate()

Return Nil

/*/{Protheus.doc} MenuDef
MenuDef
@type function
@version 1.0
@author nata.queiroz
@since 16/12/2020
@return array, Menu Rotina
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.RFUNA054' OPERATION MODEL_OPERATION_VIEW   ACCESS 0
	ADD OPTION aRotina Title 'Incluir'    Action 'VIEWDEF.RFUNA054' OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina Title 'Alterar'    Action 'VIEWDEF.RFUNA054' OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina Title 'Excluir'    Action 'VIEWDEF.RFUNA054' OPERATION MODEL_OPERATION_DELETE ACCESS 0
	ADD OPTION aRotina Title 'Copiar'     Action 'VIEWDEF.RFUNA054' OPERATION MODEL_OPERATION_COPY   ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
ModelDef
@type function
@version 1.0
@author nata.queiroz
@since 16/12/2020
@return object, oModel
/*/
Static Function ModelDef()

	Local oStruUI4      := FWFormStruct( 1, 'UI4', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruUI5      := FWFormStruct( 1, 'UI5', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel        := Nil
	Local bPosValidacao := {|oModel| PosValida(oModel)}
	Local bLinePost     := {|oModelUI5, nLine| LinePost(oModelUI5, nLine)}

	oModel := MPFormModel():New( 'PFUNA054', /*bPreValidacao*/, bPosValidacao, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields( 'UI4MASTER', /*cOwner*/, oStruUI4 )

	oModel:GetModel('UI4MASTER'):SetDescription('Dados da Regra de Reajuste')

	oModel:AddGrid( 'UI5DETAIL', 'UI4MASTER', oStruUI5, /*bLinePre*/, bLinePost, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	oModel:GetModel('UI5DETAIL'):SetDescription('Definições da Regra de Reajuste')

	oModel:SetPrimaryKey({ "UI4_FILIAL" , "UI4_CODIGO" })

	oModel:SetRelation( 'UI5DETAIL', { { 'UI5_FILIAL', 'xFilial( "UI5" )' } , { 'UI5_CODIGO', 'UI4_CODIGO' } } , UI5->(IndexKey(1)) )

Return oModel

/*/{Protheus.doc} ViewDef
ViewDef
@type function
@version 1.0
@author nata.queiroz
@since 16/12/2020
@return object, oView
/*/
Static Function ViewDef()

	Local oStruUI4 	:= FWFormStruct(2,'UI4')
	Local oStruUI5 	:= FWFormStruct(2,'UI5')
	Local oModel   	:= FWLoadModel('RFUNA054')
	Local oView     := Nil

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField('VIEW_UI4' , oStruUI4, 'UI4MASTER')
	oView:AddGrid('VIEW_UI5' , oStruUI5, 'UI5DETAIL')

	oView:CreateHorizontalBox('PAINEL_CABECALHO' , 30)
	oView:CreateHorizontalBox('PAINEL_ITENS' , 70)

	oView:SetOwnerView('VIEW_UI4' , 'PAINEL_CABECALHO')
	oView:SetOwnerView('VIEW_UI5' , 'PAINEL_ITENS')

	oView:EnableTitleView('VIEW_UI4')
	oView:EnableTitleView('VIEW_UI5')

	oView:AddIncrementField( 'VIEW_UI5', 'UI5_ITEM' )

	oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} LinePost
Pos validacao de linha
@type function
@version 1.0
@author nata.queiroz
@since 12/28/2020
@param oModelUI5, object, Modelo
@param nLine, numeric, Linha posicionada
@return logical, lRet
/*/
Static Function LinePost(oModelUI5, nLine)
	Local lRet       := .T.
	Local nOperation := oModelUI5:GetOperation()

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

		If oModelUI5:GetValue('UI5_VIGFIM') < oModelUI5:GetValue('UI5_VIGINI')
			Help(Nil,Nil,"RFUNA054",Nil,"Vigência final não pode ser menor que vigência inicial.",;
				1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor ajuste a vigência final."})
			lRet := .F.
		EndIf

		If lRet
			lRet := PosValida( FWModelActive() )
		EndIf

	EndIf

Return lRet

/*/{Protheus.doc} PosValida
Pos validacao de todo o modelo
@type function
@version 1.0
@author nata.queiroz
@since 12/28/2020
@param oModel, object, Modelo
@return logical, lRet
/*/
Static Function PosValida(oModel)
	Local lRet			:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oModelUI5		:= oModel:GetModel("UI5DETAIL")
	Local nX			:= 0
	Local nI			:= 0
	Local aVigencias	:= {}
	Local aSaveLines 	:= FWSaveRows()

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

		//-----------------------------------------//
		//-- Validacao de vigencias selecionadas --//
		//-----------------------------------------//
		For nX := 1 To oModelUI5:Length()
			oModelUI5:GoLine(nX)
			If .Not. oModelUI5:IsDeleted()
				AADD(aVigencias, { oModelUI5:GetValue('UI5_VIGINI'), oModelUI5:GetValue('UI5_VIGFIM') })
			EndIf
		Next nX

		For nX := 1 To Len(aVigencias)
			For nI := 1 To Len(aVigencias)
				If nI <> nX
					//-- Valida Vigencia Inicial
					If aVigencias[nX][1] >= aVigencias[nI][1] .And. aVigencias[nX][1] <= aVigencias[nI][2]
						Help(Nil,Nil,"RFUNA054",Nil,"Existem períodos de vigência inválidos.",;
							1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor verificar as vigências das regras de reajute."})
						lRet := .F.
						Exit
					EndIf
					//-- Valida Vigencia Final
					If aVigencias[nX][2] >= aVigencias[nI][1] .And. aVigencias[nX][2] <= aVigencias[nI][2]
						Help(Nil,Nil,"RFUNA054",Nil,"Existem períodos de vigência inválidos.",;
							1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor verificar as vigências das regras de reajute."})
						lRet := .F.
						Exit
					EndIf
					//-- Valida Vigencia Iguais
					If aVigencias[nX][1] == aVigencias[nI][1] .And. aVigencias[nX][2] == aVigencias[nI][2]
						Help(Nil,Nil,"RFUNA054",Nil,"Existem períodos de vigência iguais.",;
							1,0,Nil,Nil,Nil,Nil,Nil,{"Por favor verificar as vigências das regras de reajute."})
						lRet := .F.
						Exit
					EndIf
				EndIf
			Next nI

			If !lRet
				Exit
			EndIf
		Next nX

	EndIf

	FWRestRows(aSaveLines)

Return(lRet)

/*/{Protheus.doc} FUNA055A
funcao para validar 
@type function
@version 1.0  
@author g.sampaio
@since 30/06/2021
@return logical, retorna se o plano esta em uso em outra regra
/*/
User Function FUNA054A()

	Local aArea			:= GetArea()
	Local aPlanos		:= {}
	Local cPlanos		:= ""
	Local cCodRegra		:= ""
	Local cRegraUso		:= ""
	Local cPlanoUso		:= ""
	Local cQuery		:= ""
	Local cFinalQuery	:= ""
	Local lContinua		:= .T.
	Local lRetorno		:= .T.
	Local nPlano		:= 0
	Local oModel 		:= FWModelActive()
	Local oModelUI4 	:= oModel:GetModel("UI4MASTER")
	Local oStatSQL		:= Nil

	// validacao para regras ativas
	if AllTrim(oModelUI4:GetValue("UI4_STATUS")) == "A"

		// pego os dados da regra de reajuste
		cCodRegra	:= oModelUI4:GetValue("UI4_CODIGO")
		cPlanos 	:= AllTrim(oModelUI4:GetValue("UI4_PLANOS"))

		// monto o array
		aPlanos := StrTokArr(cPlanos,";")

		cQuery := " SELECT UI4.UI4_CODIGO FROM " + RetSQLName("UI4") + " UI4 "
		cQuery += " WHERE UI4.D_E_L_E_T_ = ' ' "
		cQuery += " AND UI4.UI4_STATUS = 'A' "
		cQuery += " AND UI4.UI4_PLANOS LIKE ? "
		cQuery += " AND UI4.UI4_CODIGO <> '"+cCodRegra+"' "

		// inicio a classe para uso da query em loop
		oStatSQL := FWPreparedStatement():New()

		//Define a consulta e os parâmetros
		oStatSQL:SetQuery(cQuery)

		if Select("TRBUI4") > 0
			TRBUI4->(DBCloseArea())
		endIf

		// percorro os planos
		For nPlano := 1 to Len(aPlanos)

			if lContinua

				cPlanoUso := aPlanos[nPlano]

				oStatSQL:SetLike(1, cPlanoUso)
				cFinalQuery := oStatSQL:GetFixQuery()

				if !Empty(cFinalQuery)
					MPSysOpenQuery(cFinalQuery, "TRBUI4")

					if TRBUI4->(!Eof())
						cRegraUso	:= TRBUI4->UI4_CODIGO
						lContinua 	:= .F.
					endIf

				endIf

			endIF

			if !lContinua
				lRetorno := .F.
				oStatSQL := Nil
				FwFreeObj(oStatSQL)

				// mensagem de help para o ususario
				Help(,,"VALPLANOS" ,,"O Plano " + cPlanoUso + " ja está vinculado a regra de reajuste '"+cRegraUso+"'!" ,1,0,,,,,,{"Verifique o cadastro da regra de reajuste '"+cRegraUso+"'!"})

				Exit
			endIf

		Next nI

		if Select("TRBUI4") > 0
			TRBUI4->(DBCloseArea())
		endIf

	endIf

	RestArea(aArea)

Return(lRetorno)
