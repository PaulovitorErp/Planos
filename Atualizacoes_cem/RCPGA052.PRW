#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RCPGA052
Browse de Sincronizacao de contratos
por API de Integracao
@type function
@version 1.0
@author g.sampaio
@since 08/09/2023
/*/
User Function RCPGA052()

	Local oBrowse	:= {}

	// crio o objeto do Browser
	oBrowse := FWmBrowse():New()

	// defino o Alias
	oBrowse:SetAlias("U93")

	// informo a descrição
	oBrowse:SetDescription("Tipos de Solicitação")

	// ativo o browser
	oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Cria os Menus da Rotina
@type function
@version 1.0
@author  g.sampaio 
@since 20/09/2022
@return array, aRotina
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Pesquisar'   						Action 'PesqBrw'          	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  						Action 'VIEWDEF.RCPGA052' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'  						Action 'VIEWDEF.RCPGA052' 	OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'  						Action 'VIEWDEF.RCPGA052' 	OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    						Action 'VIEWDEF.RCPGA052' 	OPERATION 08 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ModelDef
Cria o Modelo de Dados
@type function
@version 1.0
@author  g.sampaio 
@since 20/09/2022
@return object, oModel
/*/
Static Function ModelDef()

	Local oModel	:= NIL
	Local oStruU93 	:= FWFormStruct( 1, 'U93', /*bAvalCampo*/, /*lViewUsado*/ )

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PCPGA052', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Crio a Enchoice
	oModel:AddFields( 'U93MASTER', /*cOwner*/, oStruU93 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ 'U93_FILIAL' , 'U93_CODIGO' })

	// Preencho a descrição da entidade
	oModel:GetModel('U93MASTER'):SetDescription('Tipos de Solicitação')

Return oModel

/*/{Protheus.doc} ViewDef
Cria a camada de Visão
@type function
@version 1.0
@author  g.sampaio 
@since 20/09/2022
@return object, oView
/*/
Static Function ViewDef()
	Local oStruU93 := FWFormStruct(2,'U93')
	Local oModel := FWLoadModel('RCPGA052')
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	// cria o cabeçalho
	oView:AddField('VIEW_U93', oStruU93, 'U93MASTER')

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_U93' , 'PANEL_CABECALHO')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_U93')

	// Habilita a quebra dos campos na Vertical
	oView:SetViewProperty( 'U93MASTER', 'SETLAYOUT', { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

Return(oView)

/*/{Protheus.doc} RCPGA52A
Retorno os tipos de solicitacao
@type function
@version 1.0
@author g.sampaio
@since 19/03/2024
@return character, retorno os tipos de solicitacao
/*/
User Function RCPGA52A(cTipoSol)

	Local aArea 	:= GetArea()
	Local aAreaU93	:= U93->(GetArea())
	Local cRetorno	:= ""
	Local cQuery	:= ""
	Local cTipo		:= ""

	Default	cTipoSol	:= ""

	If Select("TRPTPS") > 0
		TRPTPS->(DbCloseArea())
	EndIf

	cQuery := " SELECT * FROM " + RetSQLName("U93") + " U93 "
	cQuery += " WHERE U93.D_E_L_E_T_ = ' ' "
	cQuery += " AND U93.U93_FILIAL = '" + xFilial("U93") + "' "
	cQuery += " AND U93.U93_MSBLQL <> '1' "

	If !Empty(cTipoSol)
		cQuery += " AND U93.U93_CODIGO = '" + cTipoSol + "' 
	EndIf

	cQuery := ChangeQuery(cQuery)

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TRPTPS' )

	While TRPTPS->(!Eof())

		// pego tipo de solicitacao
		cTipo := GetTipo(TRPTPS->U93_TIPO)

		cRetorno += AllTrim(TRPTPS->U93_CODIGO) + "=" + AllTrim(cTipo) + "-" + Capital(AllTrim(U_SpecialNoChar(TRPTPS->U93_DESCRI))) + ";"

		TRPTPS->(DBSkip())
	EndDo

	If Select("TRPTPS") > 0
		TRPTPS->(DbCloseArea())
	EndIf

	RestArea(aAreaU93)
	RestArea(aArea)

Return(cRetorno)

/*/{Protheus.doc} GetTipo
Retorno o tipo de solicitacao
@type function
@version 1.0
@author g.sampaio
@since 19/03/2024
@param cTipo, character, tipo de solicitacao
@return character, retorno o tipo de solicitacao
/*/
Static Function GetTipo(cTipo As Character)

	Local cRetorno  As Character

	Default cTipo := ""

	// 1=Lapide;2=Floreira;3=Lote;4=Ossuario;5=Columbario
	cRetorno := Capital(U_USX3CBOX("U93_TIPO", cTipo))

Return(cRetorno)
