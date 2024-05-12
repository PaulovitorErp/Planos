#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTIL027
Permissões de Usuários
@type function
@version 12.1.27
@author nata.queiroz
@since 05/08/2021
/*/
User Function RUTIL027()

	Local aGrupos 	:= UsrRetGrp(, __cUserID)				// grupo do usuario
	Local oBrowse	:= Nil
	Local nPos 		:= AScan(aGrupos, {|x| x == "000000" })	// verifico se o usuario pertence ao grupo de administradores

	If nPos > 0
		oBrowse := FWmBrowse():New()
		oBrowse:SetAlias("UZ7")
		oBrowse:SetDescription("Permissões de Usuários")
		oBrowse:Activate()
	else
		MsgAlert("Somente usuário do grupo administrador (Grupo '000000') tem acesso ao cadastro de 'Permissões de Usuários' do Painel Financeiro.", "Alerta!")
	EndIf

Return(Nil)

/*/{Protheus.doc} MenuDef
Cria os Menus da Rotina
@type function
@version 12.1.27
@author nata.queiroz
@since 05/08/2021
@return array, aRotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Pesquisar'  	Action 'PesqBrw'          OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar' 	Action 'VIEWDEF.RUTIL027' OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'    	Action 'VIEWDEF.RUTIL027' OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'    	Action 'VIEWDEF.RUTIL027' OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Copiar' 		Action 'VIEWDEF.RUTIL027' OPERATION 09 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'    	Action 'VIEWDEF.RUTIL027' OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'  	Action 'VIEWDEF.RUTIL027' OPERATION 08 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Cria o Modelo de Dados
@type function
@version 12.1.27
@author nata.queiroz
@since 05/08/2021
@return object, oModel
/*/
Static Function ModelDef()
	Local oStruUZ7   := FWFormStruct(1, 'UZ7', /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruUZ8   := FWFormStruct(1, 'UZ8', /*bAvalCampo*/, /*lViewUsado*/)
	Local oStruUZ9   := FWFormStruct(1, 'UZ9', /*bAvalCampo*/, /*lViewUsado*/)
	Local oModel     := Nil
	Local bLinePre   := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| linePreGrid(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}

	oModel := MPFormModel():New( 'PRUTIL27', /*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)

	oModel:AddFields('UZ7MASTER', /*cOwner*/, oStruUZ7 )
	oModel:GetModel('UZ7MASTER'):SetDescription('Dados Principais')

	oModel:AddGrid('UZ8DETAIL', 'UZ7MASTER', oStruUZ8, bLinePre, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/)
	oModel:GetModel('UZ8DETAIL'):SetDescription('Usuários e Grupos de Usuários')
	oModel:SetRelation('UZ8DETAIL', { { 'UZ8_FILIAL', 'xFilial( "UZ8" )' } , { 'UZ8_CODIGO', 'UZ7_CODIGO' } } , UZ8->(IndexKey(1)) )

	oModel:AddGrid('UZ9DETAIL', 'UZ8DETAIL', oStruUZ9, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/)
	oModel:GetModel('UZ9DETAIL'):SetDescription('Rotinas')
	oModel:GetModel('UZ9DETAIL'):SetForceLoad(.T.)
	oModel:SetRelation('UZ9DETAIL', { { 'UZ9_FILIAL', 'xFilial( "UZ9" )' } , { 'UZ9_CODIGO', 'UZ7_CODIGO' }, { 'UZ9_ITMGRP', 'UZ8_ITEM' } } , UZ9->(IndexKey(1)) )

	oModel:GetModel("UZ8DETAIL"):SetUniqueLine({"UZ8_ITEM"})
	oModel:GetModel("UZ9DETAIL"):SetUniqueLine({"UZ9_ITEM"})

	oModel:SetPrimaryKey({ 'UZ7_FILIAL' , 'UZ7_CODIGO' })

	oStruUZ8:AddTrigger('UZ8_USER', 'UZ8_USRNOM', /*bPre*/, {|| UsrRetName(M->UZ8_USER) })
	oStruUZ8:AddTrigger('UZ8_GRUPO', 'UZ8_GRPNOM', /*bPre*/, {|| GrpRetName(M->UZ8_GRUPO) })

	oStruUZ9:AddTrigger('UZ9_ITEM', 'UZ9_ROTINA', /*bPre*/, {|| POSICIONE("SX5",1,XFILIAL("SX5")+"Z9"+M->UZ9_ITEM,"X5_DESCRI") })

Return oModel

/*/{Protheus.doc} ViewDef
Cria a camada de Visão
@type function
@version 12.1.27
@author nata.queiroz
@since 05/08/2021
@return object, oView
/*/
Static Function ViewDef()
	Local oStruUZ7 := FWFormStruct(2, 'UZ7')
	Local oStruUZ8 := FWFormStruct(2, 'UZ8')
	Local oStruUZ9 := FWFormStruct(2, 'UZ9')
	Local oModel := FWLoadModel('RUTIL027')
	Local oView  := Nil

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:AddField('VIEW_UZ7', oStruUZ7, 'UZ7MASTER')
	oView:AddGrid('VIEW_UZ8', oStruUZ8, 'UZ8DETAIL')
	oView:AddGrid('VIEW_UZ9', oStruUZ9, 'UZ9DETAIL')

	oStruUZ8:RemoveField('UZ8_CODIGO')
	oStruUZ9:RemoveField('UZ9_CODIGO')
	oStruUZ9:RemoveField('UZ9_ITMGRP')

	oStruUZ7:AddGroup('GRUPO01', 'Dados Principais', '', 2)

	oStruUZ7:SetProperty('*', MVC_VIEW_GROUP_NUMBER, 'GRUPO01')

	oView:CreateHorizontalBox('MAIN_PANEL', 40)
	oView:CreateHorizontalBox('FIRST_PANEL', 30)
	oView:CreateHorizontalBox('SECOND_PANEL', 30)

	oView:SetOwnerView('VIEW_UZ7', 'MAIN_PANEL')
	oView:SetOwnerView('VIEW_UZ8', 'FIRST_PANEL')
	oView:SetOwnerView('VIEW_UZ9', 'SECOND_PANEL')

	oView:AddIncrementField("VIEW_UZ8","UZ8_ITEM")

	oView:SetViewProperty( 'UZ7MASTER', 'SETLAYOUT', { FF_LAYOUT_VERT_DESCR_TOP, 1 } )

	oView:EnableTitleView("VIEW_UZ8", "Usuários e Grupos de Usuários")
	oView:EnableTitleView("VIEW_UZ9", "Rotinas")

	oView:SetCloseOnOk({||.T.})

Return oView

/*/{Protheus.doc} linePreGrid
Bloco de código de pré-edição da linha do grid.
O bloco é invocado na deleção de linha, no undelete da linha e nas tentativas de atribuição de valor.
@type function
@version 12.1.27
@author nata.queiroz
@since 13/08/2021
@param oGridModel, object, oGridModel
@param nLine, numeric, nLine
@param cAction, character, cAction
@param cIDField, character, cIDField
@param xValue, variant, xValue
@param xCurrentValue, variant, xCurrentValue
@return logical, lRet
/*/
Static Function linePreGrid(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local lRet := .T.

	If cAction == "SETVALUE"
		If (cIDField == "UZ8_USER" .And. !Empty( oGridModel:GetValue("UZ8_GRUPO") ));
				.Or. (cIDField == "UZ8_GRUPO" .And. !Empty( oGridModel:GetValue("UZ8_USER") ))
			lRet := .F.
			Help(,, "HELP",, "Selecione um usuário ou grupo, não é possível preencher ambos.", 1, 0)
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} RUTIL27R
Retorno as rotinas homologadas na Gestao de Acessos
@type function
@version 1.0
@author g.sampaio
@since 31/03/2024
@return character, retorno das rotinas homologadas na Gestao de Acessos
/*/
User Function RUTIL27R()

	Local cRetorno	:= ""

	cRetorno += "1=Painel Financeiro;"
	cRetorno += "2=Contrato Cemiterio;"
	cRetorno += "3=Contrato Plano;"
	cRetorno += "4=Documentos;"

Return(cRetorno)
