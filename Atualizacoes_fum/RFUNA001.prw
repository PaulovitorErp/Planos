#Include "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFUNA001 � Autor � Wellington Gon�alves � Data� 05/07/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de cadastro de planos		.						  ���
�������������������������������������������������������������������������͹��
���Uso       � Funer�ria	                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFUNA001()

	Local oBrowse
	Private aRotina := {}

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias("UF0")
	oBrowse:SetDescription("Plano Funer�rio")
	oBrowse:AddLegend("UF0_STATUS == 'A'", "GREEN",	"Ativo")
	oBrowse:AddLegend("UF0_STATUS == 'I'", "RED",	"Inativo")
	oBrowse:Activate()

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MenuDef � Autor � Wellington Gon�alves � Data � 05/07/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que cria os menus									  ���
�������������������������������������������������������������������������͹��
���Uso       � Funer�ria	                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina Title 'Pesquisar'   		Action 'PesqBrw'          			OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  		Action 'VIEWDEF.RFUNA001' 			OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Incluir'     		Action 'VIEWDEF.RFUNA001' 			OPERATION 03 ACCESS 0
	ADD OPTION aRotina Title 'Alterar'     		Action 'VIEWDEF.RFUNA001' 			OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Excluir'     		Action 'VIEWDEF.RFUNA001' 			OPERATION 05 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    		Action 'VIEWDEF.RFUNA001' 			OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Copiar'      		Action 'VIEWDEF.RFUNA001' 			OPERATION 09 ACCESS 0
	ADD OPTION aRotina Title 'Replica Planos'  	Action 'U_VirtusMPlanosMigracao()' 	OPERATION 06 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'     		Action 'U_FUNA001LEG()' 			OPERATION 10 ACCESS 0

Return(aRotina)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ModelDef � Autor � Wellington Gon�alves � Data �05/07/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que cria o objeto model							  ���
�������������������������������������������������������������������������͹��
���Uso       � Funer�ria                         		                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ModelDef()

	Local oStruUF0 := FWFormStruct( 1, 'UF0', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruUF1 := FWFormStruct( 1, 'UF1', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oModel

// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PFUNA001', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABE�ALHO - PLANO  ////////////////////////////

// Crio a Enchoice
	oModel:AddFields( 'UF0MASTER', /*cOwner*/, oStruUF0 )

// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "UF0_FILIAL" , "UF0_CODIGO" })

// Preencho a descri��o da entidade
	oModel:GetModel('UF0MASTER'):SetDescription('Dados do Plano')

///////////////////////////  ITENS - PRODUTOS/SERVI�OS  //////////////////////////////

// Crio o grid
	oModel:AddGrid( 'UF1DETAIL', 'UF0MASTER', oStruUF1, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Fa�o o relaciomaneto entre o cabe�alho e os itens
	oModel:SetRelation( 'UF1DETAIL', { { 'UF1_FILIAL', 'xFilial( "UF1" )' } , { 'UF1_CODIGO', 'UF0_CODIGO' } } , UF1->(IndexKey(1)) )

// Seto a propriedade de n�o obrigatoriedade do preenchimento do grid
	oModel:GetModel('UF1DETAIL'):SetOptional( .F. )

// Preencho a descri��o da entidade
	oModel:GetModel('UF1DETAIL'):SetDescription('Produtos/Servi�os:')

// N�o permitir duplicar o c�digo do produto
	oModel:GetModel('UF1DETAIL'):SetUniqueLine( {'UF1_PROD'} )

Return(oModel)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ViewDef � Autor � Wellington Gon�alves � Data � 05/07/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que cria o objeto View							  ���
�������������������������������������������������������������������������͹��
���Uso       � Funer�ria                                            	  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ViewDef()

	Local oStruUF0 	:= FWFormStruct(2,'UF0')
	Local oStruUF1 	:= FWFormStruct(2,'UF1')
	Local oModel   	:= FWLoadModel('RFUNA001')
	Local oView

// Cria o objeto de View
	oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
	oView:SetModel(oModel)

	oView:AddField('VIEW_UF0'	, oStruUF0, 'UF0MASTER') // cria o cabe�alho
	oView:AddGrid('VIEW_UF1'	, oStruUF1, 'UF1DETAIL') // Cria o grid

// Crio os Panel's horizontais 
	oView:CreateHorizontalBox('PANEL_CABECALHO' , 40)
	oView:CreateHorizontalBox('PANEL_ITENS'		, 60)

// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_UF0' , 'PANEL_CABECALHO')
	oView:SetOwnerView('VIEW_UF1' , 'PANEL_ITENS')

// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_UF0')
	oView:EnableTitleView('VIEW_UF1')

// Define campos que terao Auto Incremento
	oView:AddIncrementField( 'VIEW_UF1', 'UF1_ITEM' )

// Define fechamento da tela ao confirmar a opera��o
	oView:SetCloseOnOk({||.T.})

Return(oView)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FUNA001LEG� Autor � Wellington Gon�alves � Data� 05/07/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Legenda do browser de cadastro do plano					  ���
�������������������������������������������������������������������������͹��
���Uso       � Funer�ria		                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function FUNA001LEG()

	BrwLegenda("Status do Plano","Legenda",{ {"BR_VERDE","Ativo"},{"BR_VERMELHO","Inativo"} })

Return(Nil)

/*/{Protheus.doc} FUNA001A
Validacao do campo UF1_PROD
@type function
@version 1.0  
@author g.sampaio
@since 12/07/2021
@return logical, retorno sobre a validacao do campo
/*/
User Function FUNA001A()

	Local aArea     := GetArea()
	Local aAreaSB1  := SB1->(GetArea())
	Local lPlanoPet := SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local lRetorno  := .T.
	Local oModel	:= FWModelActive()
	Local oModelUF0 := oModel:GetModel("UF0MASTER")
	Local oModelUF1 := oModel:GetModel("UF1DETAIL")

	if lPlanoPet

		SB1->(DBSetOrder(1))
		if SB1->( MsSeek( xFilial("SB1")+oModelUF1:GetValue("UF1_PROD") ) )

			if oModelUF0:GetValue("UF0_USO") == "3" .And. SB1->B1_XUSOSRV == "2"
				lRetorno := .F.
				Help( ,, 'PLANOPET',, 'Quando o uso do plano � para Pet, o servi�o tamb�m tem que ser para uso pet!', 1, 0 )

			elseIf oModelUF0:GetValue("UF0_USO") == "2" .And. SB1->B1_XUSOSRV == "3"
				lRetorno := .F.
				Help( ,, 'PLANO',, 'Quando o uso do plano � para Humano, o servi�o tamb�m tem que ser para uso humano!', 1, 0 )

			endIf

		endIf

		// quando o uso fosse para pet
		if lRetorno .And. SB1->B1_XUSOSRV == "3"

			// altero o uso do plano
			if oModelUF0:GetValue("UF0_USO") $ " |2"
				oModelUF0:LoadValue("UF0_USO", "1")
			endIf

		endIf

	endIf

	RestArea(aAreaSB1)
	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} FUNA001B
Validacao do campo UF0_USO
@type function
@version 1.0
@author g.sampaio
@since 26/07/2021
@return logical, retorno sobre a validacao do campo
/*/
User Function FUNA001B()

	Local cUsoPlano	:= ""
	Local lRetorno	:= .T.
	Local lPlanoPet := SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local nI		:= 0
	Local oModel	:= FWModelActive()
	Local oModelUF0 := oModel:GetModel("UF0MASTER")
	Local oModelUF1 := oModel:GetModel("UF1DETAIL")

	if lPlanoPet

		cUsoPlano := oModelUF0:GetValue("UF0_USO")

		For nI := 1 To oModelUF1:Length()

			oModelUF1:GoLine(nI)

			If !oModelUF1:IsDeleted()

				if cUsoPlano == "3" .And. oModelUF1:GetValue("UF1_USOSRV") == "2"
					lRetorno := .F.
					Help( ,, 'PLANOPET',, 'Quando o uso do plano � para Pet, o servi�o tamb�m tem que ser para uso pet!', 1, 0 )

				elseIf cUsoPlano == "2" .And. oModelUF1:GetValue("UF1_USOSRV") == "3"
					lRetorno := .F.
					Help( ,, 'PLANO',, 'Quando o uso do plano � para Humano, o servi�o tamb�m tem que ser para uso humano!', 1, 0 )
				endIf

			endIf

			if !lRetorno
				Exit
			endIf

		Next nI

		oModelUF1:GoLine(1)

	endIf

Return(lRetorno)
