#include "totvs.ch"
#include "fwmvcdef.ch"
#include "topconn.ch"
#include 'FWEditPanel.CH'

/*/{Protheus.doc} RUTIL025
Apontamento de Servicos PET
@type function
@version 1.0 
@author g.sampaio
@since 07/07/2021
/*/
User Function RUTIL025()
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local oBrowse 		:= Nil

	Private oOSTotais	:= NIL

	if lPlanoPet

		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('UJ0')
		oBrowse:SetDescription("Apontamentos de Serviço PET")
		oBrowse:AddLegend("UJ0->UJ0_TPSERV == '3' .AND. Empty(UJ0_DTCA)"					  									,		"WHITE",	"Orcamento em Aberto")
		oBrowse:AddLegend("UJ0->UJ0_TPSERV == '3' .AND. !Empty(UJ0_DTCA)"					  									,		"BLACK",	"Orcamento Cancelado")
		oBrowse:AddLegend("!U_UJ0STATU() .And. Empty(UJ0->UJ0_PV) .And. Empty(UJ0->UJ0_PV2) .And. Empty(UJ0->UJ0_PVADM)"		,		"GREEN",	"Em execução")
		oBrowse:AddLegend("!U_UJ0STATU() .And. (!Empty(UJ0->UJ0_PV) .OR. !Empty(UJ0->UJ0_PV2)) .And. Empty(UJ0->UJ0_PVADM)"		,		"YELLOW",	"PV cliente gerado")
		oBrowse:AddLegend("!U_UJ0STATU() .And. !Empty(UJ0->UJ0_PVADM) .And. Empty(UJ0->UJ0_PV) .And. Empty(UJ0->UJ0_PV2)  "		,		"ORANGE",	"PV adm. planos gerado")
		oBrowse:AddLegend("!U_UJ0STATU() .And. (!Empty(UJ0->UJ0_PV) .OR. !Empty(UJ0->UJ0_PV2)) .And. !Empty(UJ0->UJ0_PVADM)"	,		"BLUE",		"PV cliente e adm. planos gerados")
		oBrowse:AddLegend("U_UJ0STATU()"																						,		"RED",		"Finalizado")

		if FwIsInCallStack("U_RFUNA002")
			// pergunto ao usuario se quer filtrar apenas os apontamentos do contrato
			If MsgYesNo("Deseja filtrar os apontamentos de serviços do contrato posicionado?")

				oBrowse:SetFilterDefault( "UJ0_FILIAL == '"+ UF2->UF2_MSFIL +"' .And. UJ0_CONTRA=='" + UF2->UF2_CODIGO + "' .And. UJ0_USO == '3' " ) // filtro apenas o contrato selecionado
			else
				oBrowse:SetFilterDefault("UJ0_USO == '3'")
			EndIf
		else
			oBrowse:SetFilterDefault("UJ0_USO == '3'")
		endIf

		oBrowse:Activate()

	else
		MsgAlert("Plano PET não habilitado para está empresa!")
	endIf

Return(Nil)

/*/{Protheus.doc} MenuDef
Monta o menu da rotina
@type function
@version 1.0  
@author g.sampaio
@since 07/07/2021
@return array, array de rotinas
/*/
Static Function MenuDef()
	Local aRotina 		:= {}
	Local aRotPvCli 	:= {}
	Local aRotPvAdm		:= {}
	Local aRotReqArm	:= {}
	Local aRotOrcam		:= {}
	Local lPrepDoc		:= SuperGetMv("MV_XNFAPTF",.F.,.T.) // Parametro para perimtir o faturamento pelo o apontamento de funeraria

	////////////////////////////////////////////////////////////////
	///////////// ROTINAS PARA MANUTENCAO DE PEDIDO CLIENTE ////////
	/////////////////////////////////////////////////////////////////

	AAdd(aRotPvCli, {"Gerar"			,"U_FUNA034G()"			,0,4})
	AAdd(aRotPvCli, {"Excluir"			,"U_FUNA034E()"			,0,4})
	AAdd(aRotPvCli, {"Visualizar"		,"U_FUNA034V('C')"		,0,2})

	if lPrepDoc
		AAdd(aRotPvCli, {"Prep.Doc.Saida"	,"U_UPREPDOCSAIDA()"	,0,4})
	endIf

	AAdd(aRotPvCli, {"Transmitir Nota"	,"FISA022()"			,0,4})
	AAdd(aRotPvCli, {"Imprimir Nota"	,"U_RUTILE25()"			,0,4})

	/////////////////////////////////////////////////////////////////////////
	///////////// ROTINAS PARA MANUTENCAO DE PEDIDO ADMINISTRADORA ////////
	////////////////////////////////////////////////////////////////////////

	aRotPvAdm := {{"Gerar","U_FUNA034A()", 0, 4},;
		{"Excluir","U_FUNA034D()", 0, 4},;
		{"Visualizar","U_FUNA034V('A')", 0, 2}}

	////////////////////////////////////////////////////////////////
	///////////// ROTINAS PARA MANUTENCAO DE REQUISICAO ARMAZEM ////////
	////////////////////////////////////////////////////////////////////
	aRotReqArm := {{"Gerar","U_FUNA034H(UJ0->UJ0_CODIGO,UJ0->UJ0_CONTRA,UJ0->UJ0_SEXO)", 0, 4},;
		{"Excluir","U_FUNA034I(UJ0->UJ0_CODIGO)", 0, 4}}


	////////////////////////////////////////////////////////////////
	////// ROTINAS PARA INCLUSAO DE ORCAMENTO DE ATENDIMENTO////////
	////////////////////////////////////////////////////////////////
	aRotOrcam := {	{"Incluir" ,"U_RFUNE035(1)", 0, 4},;
		{"Efetivar","U_RFUNE035(2)", 0, 4},;
		{"Cancelar","U_RFUNE035(3)", 0, 4} }


	ADD OPTION aRotina Title 'Visualizar' 					Action "VIEWDEF.RFUNA034"						OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Incluir"						Action "VIEWDEF.RFUNA034"						OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title "Alterar"    					Action "VIEWDEF.RFUNA034"						OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Excluir"    					Action "VIEWDEF.RFUNA034"						OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title "Pedido de Venda cliente"		Action aRotPvCli								OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Requisicao Armazem"			Action aRotReqArm								OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Pedido de Venda adm. planos"	Action aRotPvAdm								OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Orcamento"					Action aRotOrcam								OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'     					Action 'U_FUNA034L()' 							OPERATION 6 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir O.S.'				Action 'U_RFUNR014( UJ0->( Recno() ) )' 		OPERATION 9 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} ViewDef
Funcao da view de dados MVC
@type function
@version 10
@author g.sampaio
@since 07/07/2021
@return object, objeto da view de dados
/*/
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   		:= FWLoadModel("RFUNA034")
	Local oView			:= FWLoadView("RFUNA034")

Return(oView)

/*/{Protheus.doc} RUTL025A
modo de edicao do campo UJ0_USO
@type function
@version 1.0
@author g.sampaio
@since 07/07/2021
@return logical, retorno se pode editar o campo
/*/
User Function RUTL025A()

	Local lRetorno	:= .T.
	Local lPlanoPet	:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet

	if lPlanoPet

		if FWIsInCallStack("U_RUTIL025")
			lRetorno := .F.
		endIf

	else
		lRetorno := .F.
	endIf

Return(lRetorno)

/*/{Protheus.doc} RUTL025B
Inicializador padrao do campo UJ0_USO
@type function
@version 1.0
@author g.sampaio
@since 07/07/2021
@return character, inicializar padrao
/*/
User Function RUTL025B()

	Local cRetorno	:= "2"
	Local lPlanoPet	:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet

	if lPlanoPet

		if (FWIsInCallStack("U_RUTIL025") .Or. AllTrim(FunName()) == "RUTIL025")
			cRetorno := "3"
		endIf

	else
		cRetorno := "2"
	endIf

Return(cRetorno)

/*/{Protheus.doc} RUTIL25C
consulta especifica de beneficiario ou pet
CODBEN
@type function
@version 1.0
@author g.sampaio
@since 13/07/2021
@return logical, retorno sobre o uso da consulta
/*/
User Function RUTIL25C()

	Local lRetorno := .T.

	If FWIsInCallStack("U_RUTIL025") // apontamento de servico pet
		lRetorno := ConPad1(,,, "UK2B")
	else
		lRetorno := ConPad1(,,, "UF42")
	endIf

	//valido se houve retorno da consulta padrao
	if Len(aCpoRet) > 0
		__cRetBenPet := aCpoRet[1]
	endif

Return(lRetorno)

/*/{Protheus.doc} UTIL25CR
Retorno da consulta especifica RUTIL25C
@type function
@version 1.0
@author g.sampaio
@since 13/07/2021
@return character, retorno da consulta
/*/
User Function UTIL25CR()
Return(__cRetBenPet)
