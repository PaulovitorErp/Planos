#include "totvs.ch"
#include "fwmvcdef.ch"
#include "topconn.ch"
#include 'FWEditPanel.CH'

#DEFINE UJ0NOMEFA 1
#DEFINE UJ0DTFALE 2
#DEFINE UJ0DECOBT 3
#DEFINE UJ0CADOBT 4
#DEFINE UJ0LOCREM 5
#DEFINE UJ0LOCVEL 6
#DEFINE UJ0MOTORI 7
#DEFINE UJBNOME 8
#DEFINE UJ0RELIGI 9
#DEFINE UG3DESC 10
#DEFINE UJ0ATENDE 11
#DEFINE LENDET 11

Static lVldLinUJ2 	:= .T.

/*/{Protheus.doc} RFUNA034
Apontamentos de ServiÁo mod2.
@type function
@version 1.0  
@author TOTVS
@since 15/12/2018
/*/
User Function RFUNA034()

	Local lPlanoPet			:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local oBrowse			:= NIL

	Private oOSTotais		:= NIL

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias("UJ0")

	If !FWIsInCallStack("U_RFUNE052") .And. FwIsInCallStack("U_RFUNA002")
		// pergunto ao usuario se quer filtrar apenas os apontamentos do contrato
		If MsgYesNo("Deseja filtrar os apontamentos de serviÁos do contrato posicionado?")
			If lPlanoPet .And. AllTrim(FunName()) $ "RFUNA034"
				oBrowse:SetFilterDefault( "UJ0_FILIAL == '"+ xFilial("UJ0",UF2->UF2_MSFIL) +"' .And. UJ0_CONTRA=='" + UF2->UF2_CODIGO + "' .And. UJ0_USO <> '3' " ) // filtro apenas o contrato selecionado
			Else
				oBrowse:SetFilterDefault( "UJ0_FILIAL == '"+ xFilial("UJ0",UF2->UF2_MSFIL) +"' .And. UJ0_CONTRA=='" + UF2->UF2_CODIGO + "'" ) // filtro apenas o contrato selecionado
			EndIf
		EndIf
	EndIf

	oBrowse:SetDescription("Apontamento de ServiÁo mod2")
	oBrowse:AddLegend("UJ0->UJ0_TPSERV == '3' .AND. Empty(UJ0_DTCA)"					  									,		"WHITE",	"Orcamento em Aberto")
	oBrowse:AddLegend("UJ0->UJ0_TPSERV == '3' .AND. !Empty(UJ0_DTCA)"					  									,		"BLACK",	"Orcamento Cancelado")
	oBrowse:AddLegend("!U_UJ0STATU() .And. Empty(UJ0->UJ0_PV) .And. Empty(UJ0->UJ0_PV2) .And. Empty(UJ0->UJ0_PVADM)"		,		"GREEN",	"Em execuÁ„o")
	oBrowse:AddLegend("!U_UJ0STATU() .And. (!Empty(UJ0->UJ0_PV) .OR. !Empty(UJ0->UJ0_PV2)) .And. Empty(UJ0->UJ0_PVADM)"		,		"YELLOW",	"PV cliente gerado")
	oBrowse:AddLegend("!U_UJ0STATU() .And. !Empty(UJ0->UJ0_PVADM) .And. Empty(UJ0->UJ0_PV) .And. Empty(UJ0->UJ0_PV2)  "		,		"ORANGE",	"PV adm. planos gerado")
	oBrowse:AddLegend("!U_UJ0STATU() .And. (!Empty(UJ0->UJ0_PV) .OR. !Empty(UJ0->UJ0_PV2)) .And. !Empty(UJ0->UJ0_PVADM)"	,		"BLUE",		"PV cliente e adm. planos gerados")
	oBrowse:AddLegend("U_UJ0STATU()"																						,		"RED",		"Finalizado")
	oBrowse:Activate()

Return(Nil)

/************************/
Static Function MenuDef()
	/************************/

	Local aRotPvCli 		:= {}
	Local aRotPvAdm			:= {}
	Local aRotPCTer			:= {}
	Local aRotReqArm		:= {}
	Local aRotOrcam			:= {}
	Local aRotTermo			:= {}
	Local lPrepDoc			:= SuperGetMv("MV_XNFAPTF",.F.,.T.) // Parametro para perimtir o faturamento pelo o apontamento de funeraria
	Local lTermoCustomizado	:= SuperGetMV("MV_XTERMOC", .F., .F.) // parametro para informar se utilizo a impressao de termos customizada
	Local lIntEmp			:= SuperGetMV("MV_XINTEMP", .F., .F.) // habilito o uso da integracao de empresas
	Local aRotina 			:= {}

	////////////////////////////////////////////////////////////////
	///////////// ROTINAS PARA MANUTENCAO DE PEDIDO CLIENTE ////////
	/////////////////////////////////////////////////////////////////

	AAdd(aRotPvCli, {"Gerar"			,"U_FUNA034G()"			,0,4})
	AAdd(aRotPvCli, {"Excluir"			,"U_FUNA034E()"			,0,4})
	AAdd(aRotPvCli, {"Visualizar"		,"U_FUNA034V('C')"		,0,2})

	if lPrepDoc
		AAdd(aRotPvCli, {"Prep.Doc.Saida"	,"U_UPREPDOCSAIDA()"	,0,4})
	endIf

	AAdd(aRotPvCli, {"Transmitir Nota"	,"U_UTRANSNOTA(UJ0->UJ0_FILSER)"		,0,4})
	AAdd(aRotPvCli, {"Imprimir Nota"	,"U_RUTILE25(UJ0->UJ0_FILSER)"			,0,4})

	///////////////////////////////////////////////////////////////////////
	///////////// ROTINAS PARA MANUTENCAO DE PEDIDO ADMINISTRADORA ////////
	///////////////////////////////////////////////////////////////////////

	aRotPvAdm := {{"Gerar","U_FUNA034A()", 0, 4},;
		{"Excluir","U_FUNA034D()", 0, 4},;
		{"Visualizar","U_FUNA034V('A')", 0, 2}}

	/////////////////////////////////////////////////////////////////////////////
	///////////// ROTINAS PARA MANUTENCAO DE PEDIDOS DE COMPRAS PARCEIROS ///////
	/////////////////////////////////////////////////////////////////////////////

	aRotPCTer := {{"Gerar","U_FUNA034F()", 0, 4},;
		{"Excluir","U_FUNA034B()", 0, 4},;
		{"Visualizar","U_FUNA034B('V')", 0, 2}}

	////////////////////////////////////////////////////////////////
	///////////// ROTINAS PARA MANUTENCAO DE REQUISICAO ARMAZEM ////////
	////////////////////////////////////////////////////////////////////
	aRotReqArm := {{"Gerar","U_FUNA034H(UJ0->UJ0_CODIGO,UJ0->UJ0_CONTRA,UJ0->UJ0_SEXO)", 0, 4},;
		{"Excluir","U_FUNA034I(UJ0->UJ0_CODIGO)", 0, 4}}

	////////////////////////////////////////////////////////////////
	////// ROTINAS PARA INCLUSAO DE ORCAMENTO DE ATENDIMENTO////////
	////////////////////////////////////////////////////////////////
	aRotOrcam := {	{"Incluir" ,"U_RFUNE035(1)", 0, 3},;
		{"Efetivar","U_RFUNE035(2)", 0, 4},;
		{"Cancelar","U_RFUNE035(3)", 0, 4} }

	// verifico se o cliente optou pela customizacao de termo
	If lTermoCustomizado

		// verifico se o ponto de entrada de termo de cliente esta compilado na base do cliente
		If ExistBlock("PTERMOCLI")

			// impress„o de termos customizados pelo cliente
			aadd(aRotTermo ,{"Impressao Termo","U_PTERMOCLI()", 0, 2})

		Else

			// impress„o de termos pelo modelo padr„o do sistema (modelo word)
			aadd(aRotTermo ,{"Impressao Termo","U_RUTILE28(UJ0->UJ0_CONTRA)", 0, 2})

		EndIf

	Else// caso nao estiver coloco a impressao de termo padrao do template (modelo word)

		// impress„o de termos pelo modelo padr„o do sistema (modelo word)
		aadd(aRotTermo ,{"Impressao Termo","U_RUTILE28(UJ0->UJ0_CONTRA)", 0, 2})

	EndIf

	ADD OPTION aRotina Title 'Visualizar' 					Action "VIEWDEF.RFUNA034"						OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Incluir"    					Action "VIEWDEF.RFUNA034"						OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title "Alterar"    					Action "VIEWDEF.RFUNA034"						OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Excluir"    					Action "VIEWDEF.RFUNA034"						OPERATION 5 ACCESS 0
	ADD OPTION aRotina Title "Pedido de Venda Cliente"		Action aRotPvCli								OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Requisicao Armazem"			Action aRotReqArm								OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Pedido de Venda Adm. Planos"	Action aRotPvAdm								OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Pedido de Compra Parceiros"   Action aRotPCTer								OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Orcamento"					Action aRotOrcam								OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'     					Action 'U_FUNA034L()' 							OPERATION 6 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir O.S.'				Action 'U_RFUNR014( UJ0->( Recno() ) )' 		OPERATION 9 ACCESS 0
	ADD OPTION aRotina Title "Gerador de Termos"			Action aRotTermo								OPERATION 12 ACCESS 0

	If ExistBlock("RUTILE45") .And. lIntEmp
		ADD OPTION aRotina Title 'Integracao de Empresas'		Action 'U_RUTILE45(UJ0->UJ0_FILIAL, UJ0->UJ0_TPAPON, UJ0->UJ0_CONTRA, UJ0->UJ0_CODIGO)' 			OPERATION 13 ACCESS 0
	endIf

Return(aRotina)

/*/{Protheus.doc} ModelDef
Modelo de dados
@type function
@version 1.0
@author g.sampaio
@since 07/07/2021
@return object, retorna o modelo de dados
/*/
Static Function ModelDef()

	Local lPlanoPet			:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local lUsaTipoServico	:= SuperGetMv("MV_XUSATS",.F.,.F.,UJ0->UJ0_FILSER)

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruUJ0 			:= FWFormStruct(1,"UJ0",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruUJ1 			:= FWFormStruct(1,"UJ1",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruUJ2 			:= FWFormStruct(1,"UJ2",/*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel			:= Nil

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("PFUNA034",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formul·rio de ediÁ„o por campo
	oModel:AddFields("UJ0MASTER",/*cOwner*/,oStruUJ0)

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({"UJ0_FILIAL","UJ0_CODIGO"})

	// Adiciona ao modelo uma estrutura de formul·rio de ediÁ„o por grid
	oModel:AddGrid("UJ1DETAIL","UJ0MASTER",oStruUJ1,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)
	oModel:GetModel("UJ1DETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("UJ1DETAIL"):SetNoUpdateLine(.T.)
	oModel:GetModel("UJ1DETAIL"):SetNoDeleteLine(.T.)

	oModel:AddGrid("UJ2DETAIL","UJ0MASTER",oStruUJ2,/*bLinePre*/{|oMdlG,nLine,cAcao,cCampo| ValDelUJ2(oMdlG,nLine,cAcao,cCampo)},/*bLinePost*/{|oMdlG| ValLinUJ2(oMdlG)},/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation("UJ1DETAIL", {{"UJ1_FILIAL", 'xFilial("UJ1")'},{"UJ1_CODIGO","UJ0_CODIGO"}},UJ1->(IndexKey(1)))
	oModel:SetRelation("UJ2DETAIL", {{"UJ2_FILIAL", 'xFilial("UJ2")'},{"UJ2_CODIGO","UJ0_CODIGO"}},UJ2->(IndexKey(1)))

	// Desobriga a digitacao de ao menos um item
	oModel:GetModel("UJ1DETAIL"):SetOptional(.T.)

	//se estiver habilitado a geracao de PV por tipo de servico, permite duplicar a linha de produto
	if !lUsaTipoServico

		// Liga o controle de nao repeticao de linha
		oModel:GetModel("UJ2DETAIL"):SetUniqueLine({"UJ2_PRODUT"})

	endif

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel("UJ0MASTER"):SetDescription("Dados")
	oModel:GetModel("UJ1DETAIL"):SetDescription("Produtos e ServiÁos contratados")
	oModel:GetModel("UJ2DETAIL"):SetDescription("Produtos e ServiÁos entregues")

	if lPlanoPet

		if (FWIsInCallStack("U_RUTIL025") .Or. AllTrim(FunName()) == "RUTIL025") .Or. (FWIsInCallStack("U_RFUNA002") .And. UF2->UF2_USO == "3")

			oModel:SetDescription( 'Apontamento de ServiÁos PET' )

			// campos obrigatorio
			oStruUJ0:SetProperty( 'UJ0_TIPPET' 	, MODEL_FIELD_OBRIGAT, .T.)
			oStruUJ0:SetProperty( 'UJ0_RACA'	, MODEL_FIELD_OBRIGAT, .T.)
			oStruUJ0:SetProperty( 'UJ0_CORPEL' 	, MODEL_FIELD_OBRIGAT, .T.)
			oStruUJ0:SetProperty( 'UJ0_PORTE' 	, MODEL_FIELD_OBRIGAT, .T.)
			oStruUJ0:SetProperty( 'UJ0_IDADEF' 	, MODEL_FIELD_OBRIGAT, .T.)

			// altero a descricao dos campos
			// ATENCAO: DEVE-SE ALTERAR A DESCRICAO NO VIEW TAMBEM PARA FUNCIONAR NO FORMULARIO
			oStruUJ0:SetProperty( 'UJ0_CODBEN' 	, MODEL_FIELD_TITULO, "Pet")
			oStruUJ0:SetProperty( 'UJ0_NOMEFA' 	, MODEL_FIELD_TITULO, "Pet Falecido")
			oStruUJ0:SetProperty( 'UJ0_IDADEF' 	, MODEL_FIELD_TITULO, "Idade Pet")

			// inicializador padrao
			oStruUJ0:SetProperty( 'UJ0_USO' 	, MODEL_FIELD_INIT, FwBuildFeature( 3, "3") )

			// campo nao editavel
			oStruUJ0:SetProperty( 'UJ0_USO' 	, MODEL_FIELD_WHEN , FwBuildFeature( 2, ".F.") )

			// altero o combo box
			// ATENCAO: DEVE-SE ALTERAR O COMBOBOX NO VIEW TAMBEM PARA FUNCIONAR NO FORMULARIO
			if !FWIsInCallStack("U_RFUNA002") .And. !FWIsInCallStack("U_RUTIL023")

				if !INCLUI // diferente de incluir

					// diferente de associado
					if !(UJ0->UJ0_TPSERV == "1")
						oStruUJ0:SetProperty( 'UJ0_TPSERV' 	, MODEL_FIELD_VALUES, {"2=Particular","3=Orcamento"})
					endIf

				else
					oStruUJ0:SetProperty( 'UJ0_TPSERV' 	, MODEL_FIELD_VALUES, {"2=Particular","3=Orcamento"})
				endIf

			endIf

			oStruUJ0:SetProperty( 'UJ0_SEXO' 	, MODEL_FIELD_VALUES, {"M=Macho","F=Femea"})

		endIf

	endif

	//-- Gatilho para preencher a Nome do Fornecedor
	oStruUJ2:AddTrigger('UJ2_CODFOR', 'UJ2_LOJFOR', /*bPre*/, {|| POSICIONE("SA2",1,xFilial("SA2")+FWFLDGET("UJ2_CODFOR"),"A2_LOJA") })
	oStruUJ2:AddTrigger('UJ2_CODFOR', 'UJ2_NOMFOR', /*bPre*/, {|| POSICIONE("SA2",1,xFilial("SA2")+FWFLDGET("UJ2_CODFOR")+FWFLDGET("UJ2_LOJFOR"),"A2_NOME") })
	oStruUJ2:AddTrigger('UJ2_LOJFOR', 'UJ2_NOMFOR', /*bPre*/, {|| POSICIONE("SA2",1,xFilial("SA2")+FWFLDGET("UJ2_CODFOR")+FWFLDGET("UJ2_LOJFOR"),"A2_NOME") })
	oStruUJ2:AddTrigger('UJ2_CODFOR', 'UJ2_ESTOQU', /*bPre*/, {|| U_RFUNA34B() })
	oStruUJ2:AddTrigger('UJ2_LOJFOR', 'UJ2_ESTOQU', /*bPre*/, {|| U_RFUNA34B() })

Return(oModel)

/*/{Protheus.doc} ViewDef
Funcao da view de dados MVC
@type function
@version 10
@author g.sampaio
@since 07/07/2021
@return object, objeto da view de dados
/*/
Static Function ViewDef()

	// Cria a estrutura a ser usada na View
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local lIntEmp		:= SuperGetMV("MV_XINTEMP", .F., .F.) // habilito o uso da integracao de empresas
	Local oStruUJ0 		:= FWFormStruct(2,"UJ0")
	Local oStruUJ1 		:= FWFormStruct(2,"UJ1")
	Local oStruUJ2 		:= FWFormStruct(2,"UJ2")

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   		:= FWLoadModel("RFUNA034")
	Local oView			:= Nil

	// Remove campos da estrutura
	oStruUJ1:RemoveField('UJ1_CODIGO')
	oStruUJ2:RemoveField('UJ2_CODIGO')

	// verifico se tem plano pet
	if lPlanoPet

		if (FWIsInCallStack("U_RFUNA002") .And. UF2->UF2_USO == "3") .Or. (FWIsInCallStack("U_RUTIL025") .Or. AllTrim(FunName()) == "RUTIL025")// plano pet

			// cadastrais
			if FWIsInCallStack("U_RUTIL025")

				if !INCLUI // diferente de incluir

					// diferente de associado
					if !(UJ0->UJ0_TPSERV == "1")
						oStruUJ0:RemoveField('UJ0_CODBEN')
						oStruUJ0:RemoveField('UJ0_CONTRA')
						oStruUJ0:RemoveField('UJ0_CARENC')
						oStruUJ0:RemoveField('UJ0_NOMBEN')
						oStruUJ0:RemoveField('UJ0_PLANOC')
						oStruUJ0:RemoveField('UJ0_DESCPC')
						oStruUJ0:RemoveField('UJ0_REGRA')
						oStruUJ0:RemoveField('UJ0_DESCRG')
						oStruUJ0:RemoveField('UJ0_PERCDE')
					endIf
				else

					oStruUJ0:RemoveField('UJ0_CODBEN')
					oStruUJ0:RemoveField('UJ0_CONTRA')
					oStruUJ0:RemoveField('UJ0_CARENC')
					oStruUJ0:RemoveField('UJ0_NOMBEN')
					oStruUJ0:RemoveField('UJ0_PLANOC')
					oStruUJ0:RemoveField('UJ0_DESCPC')
					oStruUJ0:RemoveField('UJ0_REGRA')
					oStruUJ0:RemoveField('UJ0_DESCRG')
					oStruUJ0:RemoveField('UJ0_PERCDE')

				endIf

			endIf

			// remove campos da pasta "dados do obito"
			oStruUJ0:RemoveField('UJ0_CPF')
			oStruUJ0:RemoveField('UJ0_RG')
			oStruUJ0:RemoveField('UJ0_ESTCFA')
			oStruUJ0:RemoveField('UJ0_ALTUFA')
			oStruUJ0:RemoveField('UJ0_NATUFA')
			oStruUJ0:RemoveField('UJ0_CATEFA')
			oStruUJ0:RemoveField('UJ0_RELIGI')
			oStruUJ0:RemoveField('UJ0_NACION')
			oStruUJ0:RemoveField('UJ0_REMOCA')
			oStruUJ0:RemoveField('UJ0_LOCREM')
			oStruUJ0:RemoveField('UJ0_VELORI')
			oStruUJ0:RemoveField('UJ0_LOCVEL')
			oStruUJ0:RemoveField('UJ0_DTINIV')
			oStruUJ0:RemoveField('UJ0_HRVELO')
			oStruUJ0:RemoveField('UJ0_DTFIMV')
			oStruUJ0:RemoveField('UJ0_HRFIMV')
			oStruUJ0:RemoveField('UJ0_DTCORT')
			oStruUJ0:RemoveField('UJ0_DTCORT')
			oStruUJ0:RemoveField('UJ0_HRCORT')
			oStruUJ0:RemoveField('UJ0_SEPULT')
			oStruUJ0:RemoveField('UJ0_LOCSER')
			oStruUJ0:RemoveField('UJ0_DTSEPU')
			oStruUJ0:RemoveField('UJ0_HRSEPU')
			oStruUJ0:RemoveField('UJ0_DESREM')
			oStruUJ0:RemoveField('UJ0_DESVEL')
			oStruUJ0:RemoveField('UJ0_DESSEP')
			oStruUJ0:RemoveField('UJ0_DTCERT')
			oStruUJ0:RemoveField('UJ0_LOCFAL')
			oStruUJ0:RemoveField('UJ0_NOMAE')
			oStruUJ0:RemoveField('UJ0_UFFAL')
			oStruUJ0:RemoveField('UJ0_CODMUN')
			oStruUJ0:RemoveField('UJ0_MUN')
			oStruUJ0:RemoveField('UJ0_ENDFAL')
			oStruUJ0:RemoveField('UJ0_CMPFAL')
			oStruUJ0:RemoveField('UJ0_BAIFAL')
			oStruUJ0:RemoveField('UJ0_CEPFAL')
			oStruUJ0:RemoveField('UJ0_DTNASC')
			oStruUJ0:RemoveField('UJ0_DESCCA')
			oStruUJ0:RemoveField('UJ0_DESCRE')

			// remove campos da pasta "mao de obra"
			oStruUJ0:RemoveField('UJ0_UNATEN')
			oStruUJ0:RemoveField('UJ0_MOTREM')
			oStruUJ0:RemoveField('UJ0_NOMREM')
			oStruUJ0:RemoveField('UJ0_MOTRE2')
			oStruUJ0:RemoveField('UJ0_NOMRE2')
			oStruUJ0:RemoveField('UJ0_MOTORI')
			oStruUJ0:RemoveField('UJ0_NOMMOT')
			oStruUJ0:RemoveField('UJ0_MOTORS')
			oStruUJ0:RemoveField('UJ0_NOMMOS')
			oStruUJ0:RemoveField('UJ0_TECENA')
			oStruUJ0:RemoveField('UJ0_NOMTEA')
			oStruUJ0:RemoveField('UJ0_TECENS')
			oStruUJ0:RemoveField('UJ0_NOMTES')
			oStruUJ0:RemoveField('UJ0_DESCFI')
			oStruUJ0:RemoveField('UJ0_CPFREM')
			oStruUJ0:RemoveField('UJ0_CPFRE2')
			oStruUJ0:RemoveField('UJ0_CPFATE')
			oStruUJ0:RemoveField('UJ0_CPFSEP')
			oStruUJ0:RemoveField('UJ0_CPFTCS')
			oStruUJ0:RemoveField('UJ0_CPFTCA')

			// remove campos da pasta "Dados do Seguro"
			oStruUJ0:RemoveField('UJ0_PLNSEG')
			oStruUJ0:RemoveField('UJ0_DSCPLN')
			oStruUJ0:RemoveField('UJ0_NUMSOR')
			oStruUJ0:RemoveField('UJ0_PLNCAP')
			oStruUJ0:RemoveField('UJ0_PLNM')
			oStruUJ0:RemoveField('UJ0_PLNMAC')
			oStruUJ0:RemoveField('UJ0_PLNALI')
			oStruUJ0:RemoveField('UJ0_PLNFUN')

			// altero descricao dos campos
			// ATENCAO: DEVE-SE ALTERAR A DESCRICAO NO MODEL TAMBEM PARA FUNCIONAR NO FORMULARIO
			if !FWIsInCallStack("U_RUTIL025")
				oStruUJ0:SetProperty( 'UJ0_CODBEN' 	, MVC_VIEW_TITULO, "Pet")
			endIf
			oStruUJ0:SetProperty( 'UJ0_NOMEFA' 	, MVC_VIEW_TITULO, "Pet Falecido")
			oStruUJ0:SetProperty( 'UJ0_IDADEF' 	, MVC_VIEW_TITULO, "Idade Pet")

			// altero a consulta padrao do campo
			// ATENCAO: DEVE-SE ALTERAR O COMBOBOX NO MODEL TAMBEM PARA FUNCIONAR NO FORMULARIO
			if !FWIsInCallStack("U_RUTIL025")
				oStruUJ0:SetProperty( 'UJ0_CODBEN' 	, MVC_VIEW_LOOKUP, "UK2B")
			endIf

			// seto o campo como nao editavel
			oStruUJ0:SetProperty( 'UJ0_USO' 	, MVC_VIEW_CANCHANGE , .F. )

			// altero o combo box
			if !FWIsInCallStack("U_RFUNA002") .And. !FWIsInCallStack("U_RUTIL023")

				if !INCLUI // diferente de incluir

					// diferente de associado
					if !(UJ0->UJ0_TPSERV == "1")
						oStruUJ0:SetProperty( 'UJ0_TPSERV' 	, MVC_VIEW_COMBOBOX, {"2=Particular","3=Orcamento"})
					endIf

				else
					oStruUJ0:SetProperty( 'UJ0_TPSERV' 	, MVC_VIEW_COMBOBOX, {"2=Particular","3=Orcamento"})
				endIf

			endIf

			oStruUJ0:SetProperty( 'UJ0_SEXO' 	, MVC_VIEW_COMBOBOX, {"M=Macho","F=Femea"})

		else
			oStruUJ0:RemoveField('UJ0_USO')
			oStruUJ0:RemoveField('UJ0_USOENT')
			oStruUJ0:RemoveField('UJ0_TIPPET')
			oStruUJ0:RemoveField('UJ0_RACA')
			oStruUJ0:RemoveField('UJ0_CORPEL')
			oStruUJ0:RemoveField('UJ0_PORTE')
			oStruUJ0:RemoveField('UJ0_DSCTIP')
			oStruUJ0:RemoveField('UJ0_DSCRAC')
			oStruUJ0:RemoveField('UJ0_DSCCOR')

		endIf

	else

		// verifico se o campo existe no dicionario(SX3)
		if UJ0->(FieldPos("UJ0_USO")) > 0
			oStruUJ0:RemoveField('UJ0_USO')
		endIf

		// verifico se o campo existe no dicionario(SX3)
		if UJ0->(FieldPos("UJ0_USOENT")) > 0
			oStruUJ0:RemoveField('UJ0_USOENT')
		endIf

		// verifico se o campo existe no dicionario(SX3)
		if UJ0->(FieldPos("UJ0_TIPPET")) > 0
			oStruUJ0:RemoveField('UJ0_TIPPET')
		endIf

		// verifico se o campo existe no dicionario(SX3)
		if UJ0->(FieldPos("UJ0_RACA")) > 0
			oStruUJ0:RemoveField('UJ0_RACA')
		endIf

		// verifico se o campo existe no dicionario(SX3)
		if UJ0->(FieldPos("UJ0_CORPEL")) > 0
			oStruUJ0:RemoveField('UJ0_CORPEL')
		endIf

		// verifico se o campo existe no dicionario(SX3)
		if UJ0->(FieldPos("UJ0_PORTE")) > 0
			oStruUJ0:RemoveField('UJ0_PORTE')
		endIf

		// verifico se o campo existe no dicionario(SX3) - verificado campo raca pois a FieldPos nao valida campo virtual
		if UJ0->(FieldPos("UJ0_RACA")) > 0
			oStruUJ0:RemoveField('UJ0_DSCTIP')
		endIf

		// verifico se o campo existe no dicionario(SX3) - verificado campo raca pois a FieldPos nao valida campo virtual
		if UJ0->(FieldPos("UJ0_RACA")) > 0
			oStruUJ0:RemoveField('UJ0_DSCRAC')
		endIf

		// verifico se o campo existe no dicionario(SX3) - verificado campo raca pois a FieldPos nao valida campo virtual
		if UJ0->(FieldPos("UJ0_RACA")) > 0
			oStruUJ0:RemoveField('UJ0_DSCCOR')
		endIf

	endIf

	// caso nao utilize a integracao de empresas
	if !lIntEmp

		if UJ0->(FieldPos("UJ0_CLIINT")) > 0
			oStruUJ0:RemoveField('UJ0_CLIINT')
		endIf
		if UJ0->(FieldPos("UJ0_LOJINT")) > 0
			oStruUJ0:RemoveField('UJ0_LOJINT')
		endIf
		if UJ0->(FieldPos("UJ0_NOMINT")) > 0
			oStruUJ0:RemoveField('UJ0_NOMINT')
		endIf
		if UJ0->(FieldPos("UJ0_TPAPON")) > 0
			oStruUJ0:RemoveField('UJ0_TPAPON')
		endIf

	endIf

// Cria o objeto de View
	oView := FWFormView():New()

// Define qual o Modelo de dados ser· utilizado
	oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField("VIEW_UJ0",oStruUJ0,"UJ0MASTER")

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid("VIEW_UJ1",oStruUJ1,"UJ1DETAIL")
	oView:AddGrid("VIEW_UJ2",oStruUJ2,"UJ2DETAIL")

// Cria componentes nao MVC
	oView:AddOtherObject("RESUMO", {|oPanel| U_CriaTotais(oPanel) })

	oView:CreateVerticalBox("PANEL_ESQUERDA"		, 100)
	oView:CreateVerticalBox("PANEL_DIREITA"			, 100,,.T.)

	oView:CreateHorizontalBox("PAINEL_CABEC",	50	,	"PANEL_ESQUERDA")
	oView:CreateHorizontalBox("PAINEL_ITENS",	50	,	"PANEL_ESQUERDA")

	oView:CreateVerticalBox("PAINEL_ITENS_C", 50, "PAINEL_ITENS")
	oView:CreateVerticalBox("PAINEL_ITENS_E", 50, "PAINEL_ITENS")

	oView:CreateHorizontalBox("PAINEL_ITENS_E_BOTAO",50,"PAINEL_ITENS_E",.T.)
	oView:CreateHorizontalBox("PAINEL_ITENS_E_GRID",100,"PAINEL_ITENS_E")

	// Cria componentes nao MVC
	oView:AddOtherObject("BUTTONS_GRID", {|oPanel| CriaButtonsGrid(oPanel) })

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView("VIEW_UJ0"		,"PAINEL_CABEC")
	oView:SetOwnerView("VIEW_UJ1"		,"PAINEL_ITENS_C")
	oView:SetOwnerView("VIEW_UJ2"		,"PAINEL_ITENS_E_GRID")
	oView:SetOwnerView("RESUMO"			,"PANEL_DIREITA")
	oView:SetOwnerView("BUTTONS_GRID"	,"PAINEL_ITENS_E_BOTAO")

// Liga a identificacao do componente
	oView:EnableTitleView("VIEW_UJ1","Produtos e ServiÁos contratados")
	oView:EnableTitleView("VIEW_UJ2","Produtos e ServiÁos entregues")

// Define campos que terao Auto Incremento
	oView:AddIncrementField("VIEW_UJ1","UJ1_ITEM")
	oView:AddIncrementField("VIEW_UJ2","UJ2_ITEM")

// Habilita a quebra dos campos na Vertical
	oView:SetViewProperty( 'UJ0MASTER', "SETLAYOUT", { FF_LAYOUT_VERT_DESCR_TOP , 4  } )
	oView:SetViewProperty( "VIEW_UJ2", "ENABLENEWGRID" )

// Inicializacao do campo Contrato quando chamado pela rotina de Contrato
	bBloco := {|oView| U_IniCpoCont(oView)}
	oView:SetAfterViewActivate(bBloco)

	oView:SetViewAction( 'UNDELETELINE', { |oView,cIdView,nNumLine| UnDelGrid( oView,cIdView,nNumLine ) } )

//Valida se existe Pe Apos validacao do campo de peso
	If ExistBlock("PFUN34PS")

		Conout(" >> Usa PE PFUN34PS")

		oView:SetFieldAction('UJ0_PESOFA' ,  { |oView, cIDView, cField, xValue| ExecBlock("PFUN34PS",.F.,.F.,{xValue}) } )
	Endif

//Valida se existe Pe Apos validacao do campo de Altura
	If ExistBlock("PFUN34AT")

		Conout(" >> Usa PE PFUN34AT")

		oView:SetFieldAction('UJ0_ALTUFA' ,  { |oView, cIDView, cField, xValue| ExecBlock("PFUN34AT",.F.,.F.,{xValue}) } )
	Endif
//Acao de campo para verificar carencia do beneficiario informado
//Funcao dever· ser ajustada quando implantar regra de contrato
	oView:SetFieldAction("UJ0_CODBEN"	,{|oView, cIDView, cField, xValue| U_ValidaBeneficiario( oView, xValue, .F. ) })

// Define fechamento da tela ao confirmar a operaÁ„o
	oView:SetCloseOnOk( {||.T.} )

// Habilito a barra de progresso na abertura da tela
	oView:SetProgressBar(.T.)

Return(oView)

/***********************/
User Function FUNA034L()
	/***********************/

	BrwLegenda("Status","Legenda",{ {"BR_BRANCO"	,"Orcamento em Aberto"						},;
		{"BR_PRETO"		,"Orcamento Cancelado"						},;
		{"BR_VERDE"		,"Em execucao"								},;
		{"BR_AMARELO"	,"Em execucao, PV cliente gerado"			},;
		{"BR_LARANJA"	,"Em execucao, PV adm. planos gerado"		},;
		{"BR_AZUL"		,"Em execucao, PV cliente e adm. planos gerados"},;
		{"BR_VERMELHO"	,"Finalizado"								}})

Return(Nil)

/********************************************************/
Static Function ValDelUJ2(oModelGrid,nLinha,cAcao,cCampo)
	/********************************************************/

	Local lRet   		:= .T.
	Local oModel     	:= oModelGrid:GetModel()
	Local nOperation 	:= oModel:GetOperation()

	Local oModelAtivo	:= FWModelActive()
	Local oModelUJ0 	:= oModelAtivo:GetModel("UJ0MASTER")

	Local cProd			:= oModelGrid:GetValue("UJ2_PRODUT")

	//Valida se pode ou n„o deletar uma linha do Grid
	If cAcao == 'DELETE'  .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .And.;
			!Empty(cProd) .And. !IsInCallStack("U_VldPlanE")

		DbSelectArea("UF1")
		UF1->(DbSetOrder(2)) //UF1_FILIAL+UF1_CODIGO+UF1_PROD

		If !UF1->(DbSeek(xFilial("UF1")+oModelUJ0:GetValue("UJ0_PLANOE")+cProd)) .Or. Empty(oModelUJ0:GetValue("UJ0_CONTRA")) //Produto n„o encontrado no Plano Ou serviÁo particular

			//Atualiza o resumo
			If Type("oOSTotais") <> "U"
				oOSTotais:RefreshTot(cAcao,nLinha)
			EndIf

		Else
			Help( ,, 'DELETE',, 'Exclus„o permitida somente para itens que n„o constam no plano entregue selecionado.', 1, 0 )
			lRet := .F.
		Endif
	EndIf

Return lRet

/*/{Protheus.doc} UnDelGrid
FunÁ„o chamada na UndeleÁ„o da linha dos grids
@type function
@version 1.0
@author Raphael Martins
@since 03/05/2019
@param oView, object, objeto da view da rotina
@param cIdView, character, id da view da rotina
@param nNumLine, numeric, numero da linha
/*/
Static Function UnDelGrid( oView,cIdView,nNumLine )

	Local aArea := GetArea()

	if AllTrim(cIdView) == "UJ2DETAIL"

		// chamo funÁ„o que atualiza os valores do contrato
		If Type("oOSTotais") <> "U"
			oOSTotais:RefreshTot()
		EndIf

	endif

	RestArea(aArea)

Return(Nil)

/************************************/
Static Function ValLinUJ2(oModelGrid)
	/************************************/

	Local oModel		:= FWModelActive()
	Local oModelUJ0 	:= oModel:GetModel("UJ0MASTER")
	Local oModelUJ2		:= oModelGrid:GetModel("UJ2DETAIL")
	Local nOperation	:= oModelUJ2:GetOperation()
	Local nPercDesc		:= oModelUJ0:GetValue("UJ0_PERCDE")
	Local lRet			:= .T.
	Local nI			:= 0

	Local aSaveLines  	:= FWSaveRows()

	If (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE) .And. lVldLinUJ2

		If lRet .And. oModelGrid:GetValue("UJ2_OK") .And. Empty(oModelGrid:GetValue("UJ2_QUANT"))
			Help( ,,'Help',,'Campo Quantidade obrigatÛrio.',1,0)
			lRet := .F.
		Endif

		If lRet
			If !oModelGrid:GetValue("UJ2_OK") .And. !Empty(oModelGrid:GetValue("UJ2_QUANT"))
				Help( ,,'Help',,'Caso preencha a informaÁ„o Quantidade caracterizando a realizaÁ„o do serviÁo, deve-se selecionar o respectivo item.',1,0)
				lRet := .F.
			Endif
		Endif

		If lRet

			If oModelUJ0:GetValue("UJ0_CARENC") == "S" .And. oModelGrid:GetValue("UJ2_OK") .And. !Empty(oModelGrid:GetValue("UJ2_VLRDES"))

				DbSelectArea("SB1")
				SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD

				If SB1->(DbSeek(xFilial("SB1")+oModelGrid:GetValue("UJ2_PRODUT")))
					If SB1->B1_XPERDES == "N" //N„o permite desconto
						Help( ,,'Help',,'O produto relacionado ao item, n„o permite inclus„o de desconto.',1,0)
						lRet := .F.
					Endif
				Endif
			Endif
		Endif

		If lRet .And. oModelUJ0:GetValue("UJ0_CARENC") == "S"

			For nI := 1 To oModelGrid:Length()

				oModelGrid:Goline(nI)

				If !oModelGrid:IsDeleted()

					If oModelGrid:GetValue("UJ2_OK") .And. oModelGrid:GetValue("UJ2_PV") == "S" //Gera PV

						If oModelGrid:GetValue("UJ2_VLRDES") > 0 .And. oModelGrid:GetValue("UJ2_VLRDES") > oModelGrid:GetValue("UJ2_SUBTOT")
							Help( ,,'Help',,'O desconto do item n„o pode ser superior ao preÁo total do item.',1,0)
							lRet := .F.
							Exit
						Endif
					Endif
				Endif
			Next nI

			FWRestRows(aSaveLines)
		Endif

		If lRet
			If oModelGrid:GetValue("UJ2_OK") .And. !Empty(oModelGrid:GetValue("UJ2_UNESTO")) .And.;
					oModelGrid:GetValue("UJ2_UNESTO") <> cFilAnt .And. Empty(oModelGrid:GetValue("UJ2_LOCAL"))
				Help( ,,'Help',,'Caso a unidade/filial seja diferente da filial logada, o almoxarifado deve ser preenchido.',1,0)
				lRet := .F.
			Endif
		Endif

		If lRet
			If oModelGrid:GetValue("UJ2_OK") .And. Empty(oModelGrid:GetValue("UJ2_UNESTO")) .And.;
					!Empty(oModelGrid:GetValue("UJ2_LOCAL"))
				Help( ,,'Help',,'Caso o almoxarifado seja preenchido, a unidade/filial deve ser preenchida.',1,0)
				lRet := .F.
			Endif
		Endif

		If lRet
			If !oModelGrid:GetValue("UJ2_OK") .And. oModelGrid:GetValue("UJ2_OS") == "S"
				Help( ,,'Help',,'Caso deseje gerar Ordem de ServiÁo, deve-se selecionar o respectivo item.',1,0)
				lRet := .F.
			Endif
		Endif

		If lRet
			If oModelGrid:GetValue("UJ2_OK") .And. Empty(oModelGrid:GetValue("UJ2_PV"))
				Help( ,,'Help',,'Campo Gera PV obrigatÛrio.',1,0)
				lRet := .F.
			Endif
		Endif

		If lRet
			If Type("oOSTotais") <> "U"
				oOSTotais:RefreshTot()
			EndIf

		Endif
	Endif

Return lRet

/*/{Protheus.doc} FUNA034G
Funcao para gerar o pedido de venda
de cliente
@type function
@version 1.0
@author TOTVS
@since 02/12/2021
/*/
User Function FUNA034G()

	Local aDetalhes := {}
	Local cPv1		:= ""
	Local cPv2		:= ""
	Local lAux		:= .F.
	Local lRet		:= .F.

	//Valido se È orcamento
	If UJ0->UJ0_TPSERV != '3'

		If Empty(UJ0->UJ0_PV)

			if !Empty(UJ0->UJ0_CLIPV) .And. !Empty(UJ0->UJ0_LOJAPV)

				//Valida a seleÁ„o de ao menos um item p/ PV
				DbSelectArea("UJ2")
				UJ2->(DbSetOrder(1)) //UJ2_FILIAL+UJ2_CODIGO+UJ2_ITEM

				If UJ2->(DbSeek(xFilial("UJ2")+UJ0->UJ0_CODIGO))

					While UJ2->(!EOF()) .And. xFilial("UJ2") == UJ2->UJ2_FILIAL .And. UJ2->UJ2_CODIGO == UJ0->UJ0_CODIGO

						If UJ2->UJ2_OK .And. UJ2->UJ2_PV == "S"
							lAux := .T.
							Exit
						Endif
						UJ2->(DbSkip())
					EndDo
				Endif

				If lAux

					If MsgYesNo("Ser· gerado Pedido de Venda contra o cliente para o apontamento selecionado, deseja continuar?")

						BeginTran()

						//-- Detalhes para cabeÁalho pedido de venda --//
						AADD(aDetalhes, UJ0->UJ0_NOMEFA)
						AADD(aDetalhes, UJ0->UJ0_DTFALE)
						AADD(aDetalhes, UJ0->UJ0_DECOBT)
						AADD(aDetalhes, UJ0->UJ0_CADOBT)
						If !Empty(UJ0->UJ0_REMOCA)
							AADD(aDetalhes, AllTrim(Posicione("UJC", 1, xFilial("UJC") + UJ0->UJ0_REMOCA, "UJC_DESCRI")))
						Else
							AADD(aDetalhes, AllTrim(UJ0->UJ0_LOCREM))
						EndIf
						If !Empty(UJ0->UJ0_VELORI)
							AADD(aDetalhes, AllTrim(Posicione("UJD", 1, xFilial("UJD") + UJ0->UJ0_VELORI, "UJD_DESCRI")))
						Else
							AADD(aDetalhes, AllTrim(UJ0->UJ0_LOCVEL))
						EndIf
						AADD(aDetalhes, UJ0->UJ0_MOTORI)
						AADD(aDetalhes, AllTrim(Posicione("UJB", 1, xFilial("UJB") + UJ0->UJ0_MOTORI, "UJB_NOME")))
						AADD(aDetalhes, UJ0->UJ0_RELIGI)
						AADD(aDetalhes, AllTrim(Posicione("UG3", 1, xFilial("UG3") + UJ0->UJ0_RELIGI, "UG3_DESC")))
						AADD(aDetalhes, UJ0->UJ0_ATENDE)

						MsgRun("Gerando Pedido de Venda contra o cliente...",;
							"Aguarde",;
							{|| lRet := U_GeraPV_J(@cPv1,@cPv2,;
							UJ0->UJ0_CLIPV,;
							UJ0->UJ0_LOJAPV,;
							UJ0->UJ0_CONDPV,;
							UJ0->UJ0_MENNFS,;
							UJ0->UJ0_CODIGO,;
							UJ0->UJ0_CONTRA,;
							"C",;
							UJ0->UJ0_TABPRC,;
							aDetalhes)})

						//Atualiza status
						If lRet
							RecLock("UJ0",.F.)
							UJ0->UJ0_PV  := cPv1
							UJ0->UJ0_PV2 := cPv2
							UJ0->(MsUnlock())
						Endif

						EndTran()
					Endif
				Else
					MsgInfo("No apontamento n„o consta nenhum item configurado para gerar Pedido de Venda Ou diferente do plano contratado.","AtenÁ„o")
				Endif
			else
				MsgInfo("Campos 'Cliente PV' e 'Loja' n„o est„o preenchidos nas informaÁıes do 'Pedido de Venda - Cliente', favor preencher.","AtenÁ„o")
			endIf
		Else
			MsgInfo("Pedido de Venda contra o cliente j· gerado para o apontamento selecionado.","AtenÁ„o")
		Endif

	else
		MsgInfo("N„o È permitido gerar Pedido Cliente de Apontamento em fase de orcamento! ")
	Endif

Return(Nil)

/*/{Protheus.doc} FUNA034E
Funcao para estornar os Pedidos de Vendas do Apontamento
@type function
@version 1.0
@author TOTVS
@since 10/08/2020
@return return_type, return_description
/*//***********************/
User Function FUNA034E()
/***********************/

	Local aPedidos		:= {}
	Local lRet			:= .F.
	Local cFilLogada	:= cFilAnt
	Local nX			:= 0

	If UJ0->UJ0_TPSERV != '3'

		//altero a filial para a filial de servico
		if !Empty(UJ0->UJ0_FILSER)

			cFilAnt := UJ0->UJ0_FILSER

		endif

		If !Empty(UJ0->UJ0_PV) .Or. !Empty(UJ0->UJ0_PV2)

			If MsgYesNo("Ser· estornado o Pedido de Venda contra o cliente para o apontamento selecionado, deseja continuar?")

				BeginTran()

				//Verifica se tem PV relacionado, se sim, exclui
				DbSelectArea("SC5")
				SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM

				DbSelectArea("SC6")
				SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

				DbSelectArea("SC9")
				SC9->(DbSetOrder(1)) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

				//retorna pedidos gerados para estorno dos mesmos
				aPedidos := RetPedidosApontamento(UJ0->UJ0_CODIGO,UJ0->UJ0_CLIPV,UJ0->UJ0_LOJAPV)

				if Len(aPedidos) > 0

					For nX := 1 To Len(aPedidos)

						If SC5->(DbSeek(xFilial("SC5") + aPedidos[nX,1] ))

							If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))

								While SC6->(!EOF()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM

									//Estorna liberaÁ„o do PV
									If SC9->(DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM))
										a460Estorna()
									Endif

									SC6->(DbSkip())
								EndDo
							Endif

							MsgRun("Excluindo Pedido de Venda contra o cliente...","Aguarde",{|| lRet := ExcluiPV(SC5->C5_NUM,"C")})

							//nao continuo a operacao em caso de erro no execauto de exclusao
							if !lRet
								Exit
							endif

						Endif

					Next nX

					//Atualiza status
					If lRet
						RecLock("UJ0",.F.)
						UJ0->UJ0_PV := ""
						UJ0->UJ0_PV2 := ""
						UJ0->(MsUnlock())
					Endif

				else

					MsgInfo("N„o h· Pedido de Venda contra o cliente gerado para o apontamento selecionado.","AtenÁ„o")

				endif


				EndTran()

			Endif

			//restauro a filial logada
			cFilAnt := cFilLogada

		Else
			MsgInfo("N„o h· Pedido de Venda contra o cliente gerado para o apontamento selecionado.","AtenÁ„o")
		Endif

	else
		Msginfo("Servico em fase de Orcamento nao possui pedido !")
	Endif

Return

/*/{Protheus.doc} GeraPV_J
FunÁ„o para gerar o pedido de vendas no 
apontamento de servicos modelo 2
@type function
@version 1.0
@author g.sampaio
@since 04/05/2020
@param cPv, character, codigo do pedido de vendas 1
@param cPv, character, codigo do pedido de vendas 2 (Caso esteja habilitado o parametro MV_XUSATS )

@param cCliente, character, codigo do cliente
@param cLojaCli, character, codigo da loja do cliente	
@param cCondPagto, character, codigo da condicao de pagamento
@param cMenNfs, character, mensagem da nota fiscal
@param cApto, character, codigo do apontamento de serviÁos
@param cContrato, character, codigo do contrato
@param cTipo, character, tipo de pedido A=Administradora de Planos / C=Cliente
@param cTabPrc, character, codigo da tabela de precos
@param aDetalhes, array, array de detalhes do pedido de vendas
@return logico, retorno veradeiro ou falso para caso tenha gerado o pedido de vendas corretamente
/*/
/*********************************************************************************************/
User Function GeraPV_J(cPv1,cPv2,cCliente,cLojaCli,cCondPagto,cMenNfs,cApto,cContrato,cTipo,cTabPrc,aDetalhes)
/*********************************************************************************************/

	Local lRet				:= .T.

	Local aCab 				:= {}
	Local aDados			:= {}
	Local aItens 			:= {}
	Local aTipoServicos		:= {}
	Local nI
	Local lCarencia			:= IIF(UJ0->UJ0_CARENC == "S" .And. UJ0->UJ0_PERCDE > 0,.T.,.F.)
	Local cClassi			:= ""//A=Carencia;C=Contrato;E=Carente;I=Indigente;P=Particular
	Local cNatServico		:= ""
	Local cTipoOperacao		:= ""
	Local cTipoProduto		:= ""
	Local nTotItem			:= ""
	Local cFilLogada		:= cFilAnt
	Local nItem				:= 0
	Local nPesoItemNoPv		:= 0
	Local nDescontoItem		:= 0
	Local nX				:= 0
	Local cOpFinSEst		:= SuperGetMv("MV_XOPFSEN",.F.,"08",UJ0->UJ0_FILSER)
	Local cOpFinCEst		:= SuperGetMv("MV_XOPFSES",.F.,"09",UJ0->UJ0_FILSER)
	Local cOpNFinNEst		:= SuperGetMv("MV_XOPFNEN",.F.,"10",UJ0->UJ0_FILSER)
	Local cOpNFinCEst		:= SuperGetMv("MV_XOPFNES",.F.,"11",UJ0->UJ0_FILSER)
	Local lUsaTipoServico	:= SuperGetMv("MV_XUSATS",.F.,.F.,UJ0->UJ0_FILSER)
	Local nLenDet 			:= LENDET

	Default cPv				:= ""
	Default cCliente		:= ""
	Default cLojaCli		:= ""
	Default cCondPagto		:= ""
	Default cMenNfs			:= ""
	Default	cApto			:= ""
	Default cContrato		:= ""
	Default cTipo			:= ""
	Default cTabPrc			:= Alltrim(SuperGetMv("MV_XTABSER",.F.,"001",UJ0->UJ0_FILSER))
	Default aDetalhes 		:= {}

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.

	DbSelectArea("SC5")

	////////////////////////////////////////////////////////////////////////////////////
	////////////// VALIDANDO A NATUREZA A SER UTILIZADA NO PEDIDO	///////////////////
	///////////////////////////////////////////////////////////////////////////////////

	If UJ0->UJ0_TPSERV != '3' // caso for diferente de orÁamento

		// faco a validacao para verificar a classificacao A=Carencia;C=Contrato;E=Carente;I=Indigente;P=Particular
		If !Empty(cContrato) .And. lCarencia // com contrato e com carencia
			cClassi	:= "A" // carencia

		ElseIf !Empty(cContrato) .And. !lCarencia // com contrato e sem carencia
			cClassi	:= "C" // contrato
		ElseIf Empty(cContrato) .And. !lCarencia .And. UJ0->UJ0_TPSERV == "4" // sem contrato e sem carencia e tipo de servico igual 4=Indigente
			cClassi	:= "I" // indigente
		ElseIf Empty(cContrato) .And. !lCarencia .And. UJ0->UJ0_TPSERV == "5" // sem contrato e sem carencia e tipo de servico igual 5=Carente
			cClassi	:= "E" // carente
		Else// caso nao se enquadre em nenhuma das condicoes acima
			cClassi	:= "P" // particular
		EndIf

		/////////////////////////////////////////////////////////
		/////////    GERA PEDIDO ADM DE PLANOS	/////////////////
		/////////////////////////////////////////////////////////

		If cTipo == "A" //"A" - Administradora de Planos

			//OperaÁ„o gera Financeiro, n„o movimenta Estoque
			cOper := cOpFinSEst

			UJ1->(DbSetOrder(1)) //UJ1_FILIAL+UJ1_CODIGO+UJ1_ITEM
			UJ2->(DbSetOrder(2)) //UJ2_FILIAL+UJ2_CODIGO+UJ2_PRODUT

			If UJ1->(DbSeek(xFilial("UJ1")+cApto))

				While UJ1->(!EOF()) .And. xFilial("UJ1") == UJ1->UJ1_FILIAL .And. UJ1->UJ1_CODIGO == cApto

					UJ2->(DbSeek(xFilial("UJ2")+UJ1->(UJ1_CODIGO+UJ1_PRODUT)))
					If  UJ2->(Eof()) ; //N„o possui ServiÁos/Produtos prestados
						.or. Empty(UJ2->UJ2_CODFOR) //ServiÁos/Produtos N√O prestados por parceiros [Terceiros]

						aDados := {}
						nItem++

						AAdd(aDados,{"C6_ITEM" 		,StrZero(nItem,TamSX3("C6_ITEM")[1])	,Nil})
						AAdd(aDados,{"C6_PRODUTO" 	,UJ1->UJ1_PRODUTO						,Nil})
						AAdd(aDados,{"C6_QTDVEN" 	,UJ1->UJ1_QUANT							,Nil})
						AAdd(aDados,{"C6_PRCVEN" 	,UJ1->UJ1_PRCVEN					 	,Nil})
						AAdd(aDados,{"C6_OPER" 		,cOper									,Nil})

						AAdd(aItens,aDados)

					EndIf

					UJ1->(DbSkip())

				EndDo

			Endif

			////////////////////////////////////////////////////////
			/////////       GERA PEDIDO CLIENTE		////////////////
			////////////////////////////////////////////////////////

		Else //cTipo == "C" -> Cliente

			if Empty(UJ0->UJ0_PV) .And. Empty(UJ0->UJ0_PV2)

				//Verifico se o pedido sera gerado com os tipos de servicos, ou detalhado
				if !lUsaTipoServico

					UJ2->(DbSetOrder(1)) //UJ2_FILIAL+UJ2_CODIGO+UJ2_ITEM

					If UJ2->(DbSeek(xFilial("UJ2")+cApto))

						While UJ2->(!EOF()) .And. xFilial("UJ2") == UJ2->UJ2_FILIAL .And. UJ2->UJ2_CODIGO == cApto

							nPesoItemNoPv		:= 0 //Peso do Item sobre o Total do Contrato
							nDescontoItem		:= 0 //Valor de Desconto do item sobre o total

							If UJ2->UJ2_OK .And. UJ2->UJ2_PV == "S"

								cTipoProduto := RetField("SB1",1,xFilial("SB1") + UJ2->UJ2_PRODUTO ,"B1_TIPO")

								if UJ2->UJ2_TOTAL > 0

									nTotItem := UJ2->UJ2_TOTAL / UJ2->UJ2_QUANT // Valor por minimo de item com financeiro

								else

									nTotItem := UJ2->UJ2_SUBTOT / UJ2->UJ2_QUANT // Valor por item somente estoque

								endif

								//caso o valor a ser pago seja maior que o valor definido como fatura minima pega tes com financeiro
								if UJ2->UJ2_TOTAL  > 0

									if Alltrim(cTipoProduto) == 'SV'

										//OperaÁ„o GERA Financeiro, NAO movimenta Estoque
										cTipoOperacao := Alltrim(cOpFinSEst)

									else
										//OperaÁ„o GERA Financeiro, movimenta Estoque
										cTipoOperacao := Alltrim(cOpFinCEst)

									endif

								else

									if Alltrim(cTipoProduto) == 'SV'

										//OperaÁ„o gera NAO Financeiro, NAO movimenta Estoque
										cTipoOperacao := Alltrim(cOpNFinNEst)

									else

										//OperaÁ„o GERA Financeiro, movimenta Estoque
										cTipoOperacao := Alltrim(cOpNFinCEst)

									endif

								endif

								aDados	:= {}
								nItem++

								AAdd(aDados,{"C6_ITEM" 		, StrZero(nItem,TamSX3("C6_ITEM")[1])	,Nil})
								AAdd(aDados,{"C6_PRODUTO" 	, UJ2->UJ2_PRODUTO						,Nil})
								AAdd(aDados,{"C6_QTDVEN" 	, UJ2->UJ2_QUANT 						,Nil})
								AAdd(aDados,{"C6_PRCVEN" 	, nTotItem					 			,Nil})
								AAdd(aDados,{"C6_OPER" 		, cTipoOperacao							,Nil})

								AAdd(aItens,aDados)

							endif

							UJ2->(DbSkip())

						EndDo

					Endif

				else

					//------------------------------------------------------------------------------------------------------------------------------------
					//retorno os tipos de servicos que serao gerados no PV, lembrando que podera gerar mais de um, pois em caso de carencia ou desconto
					//em servicos de associado
					//------------------------------------------------------------------------------------------------------------------------------------
					aTipoServicos := PVComTiposDeServico(cApto)
					lRet	 		:= aTipoServicos[1]

				endif
			else

				lRet := .F.
				Help( ,, 'Help - GeraPV_J',, 'O Apontamento j· possui pedido de venda gerado, operaÁ„o n„o permitida.', 1, 0 )

			endif

		Endif

		if lRet

			//altero a filial para a filial de servico
			if !Empty(UJ0->UJ0_FILSER)

				cFilAnt := UJ0->UJ0_FILSER

			endif

			//valido a natureza para pedido particular
			if cTipo == 'C' .And. Empty(cContrato)

				cNatServico :=  Alltrim(SuperGetMv("MV_XNATPAR",.F.,"OUTROS",UJ0->UJ0_FILSER))

				//valido a natureza para servicos de contratos
			elseif cTipo == 'C' .And. !Empty(cContrato)

				cNatServico :=  Alltrim(SuperGetMv("MV_XNATCTR",.F.,"OUTROS",UJ0->UJ0_FILSER))
				cTabPrc		:= Alltrim(SuperGetMv("MV_XTABSER",.F.,"001",UJ0->UJ0_FILSER))

				//valido a natureza para administradora de planos
			else

				cNatServico :=  Alltrim(SuperGetMv("MV_XNATPRC",.F.,"OUTROS",UJ0->UJ0_FILSER))

			endif

			AAdd(aCab, {"C5_TIPO" 		,"N" 				,Nil})
			AAdd(aCab, {"C5_CLIENTE" 	,cCliente		 	,Nil})
			AAdd(aCab, {"C5_LOJACLI" 	,cLojaCli		 	,Nil})
			AAdd(aCab, {"C5_TABELA" 	,cTabPrc			,Nil})
			AAdd(aCab, {"C5_CONDPAG" 	,cCondPagto			,Nil})
			AAdd(aCab, {"C5_EMISSAO" 	,dDataBase 			,Nil})
			AAdd(aCab, {"C5_MOEDA" 		,1 					,Nil})
			AAdd(aCab, {"C5_NATUREZ" 	,cNatServico 		,Nil})
			AAdd(aCab, {"C5_XMENNFS"	,cMenNfs			,Nil})
			AAdd(aCab, {"C5_XAPTOFU"	,cApto				,Nil})
			AAdd(aCab, {"C5_XTPAPTO"	,cTipo				,Nil})
			AAdd(aCab, {"C5_XCTRFUN"	,cContrato			,Nil})
			AAdd(aCab, {"C5_XCLASSI"	,cClassi			,Nil})

			If Len(aDetalhes) = nLenDet
				AAdd(aCab, {"C5_XNOMEFA"	,aDetalhes[UJ0NOMEFA] ,Nil})
				AAdd(aCab, {"C5_XDTFALE"	,aDetalhes[UJ0DTFALE] ,Nil})
				AAdd(aCab, {"C5_XDECOBT"	,aDetalhes[UJ0DECOBT] ,Nil})
				AAdd(aCab, {"C5_XCADOBT"	,aDetalhes[UJ0CADOBT] ,Nil})
				AAdd(aCab, {"C5_XLOCREM"	,aDetalhes[UJ0LOCREM] ,Nil})
				AAdd(aCab, {"C5_XLOCVEL"	,aDetalhes[UJ0LOCVEL] ,Nil})
				AAdd(aCab, {"C5_XMOTORI"	,aDetalhes[UJ0MOTORI] ,Nil})
				AAdd(aCab, {"C5_XNOMMOT"	,aDetalhes[UJBNOME] ,Nil})
				AAdd(aCab, {"C5_XRELIGI"	,aDetalhes[UJ0RELIGI] ,Nil})
				AAdd(aCab, {"C5_XDESCRE"	,aDetalhes[UG3DESC] ,Nil})
				AAdd(aCab, {"C5_XATENDE"	,aDetalhes[UJ0ATENDE] ,Nil})
			EndIf


			//----------------------------------------------------------
			// VERIFICO OS TIPOS DE PEDIDOS QUE SERAO GERADOS
			//----------------------------------------------------------
			if Len(aCab)>0 .and. Len(aItens)>0 .and. (cTipo == "A" .Or. !lUsaTipoServico)

				MSExecAuto({|X,Y,Z|Mata410(X,Y,Z)},aCab,aItens,3)

				If lMsErroAuto

					lRet := .F.
					MostraErro()
					DisarmTransaction()
					cPv := ""
				else

					cPv1 := SC5->C5_NUM
					If cTipo == "C" //Contra o cliente
						MsgInfo("Pedido de Venda <"+AllTrim(cPv1)+"> contra o cliente gerado com sucesso.","AtenÁ„o")
					Else //Contra a adm. de planos
						MsgInfo("Pedido de Venda <"+AllTrim(cPv1)+"> contra a administradora de planos gerado com sucesso.","AtenÁ„o")
					Endif

				endif

			else

				//-----------------------------------------------------
				// GERO PEDIDO PELOS TIPOS DE SERVICO
				//-----------------------------------------------------
				For nX := 2 To Len(aTipoServicos)

					if Len(aTipoServicos[nX]) > 0

						//----------------------------------------------------------------------------------------------------------------------------
						//Quando o apontamento for de contrato, porem existem itens particulares, modifico a classificao do pedido para "Particular"
						//----------------------------------------------------------------------------------------------------------------------------
						if (cClassi == "C" .Or. cClassi == "A") .And. nX == 3

							aCab[13,2] := "P"

						else
							aCab[13,2] := cClassi
						endif

						MSExecAuto({|X,Y,Z|Mata410(X,Y,Z)},aCab,aTipoServicos[nX],3)

						If lMsErroAuto
							// ApontamentoServicos
							lRet := .F.
							If !FWIsInCallStack("ApontamentoServicos")
								MostraErro()
							Else
								MostraErro("/temp")
							EndIf

							DisarmTransaction()

						else

							Help( ,, 'Help - GeraPV_J',, 'Pedido de Venda ( ' + X3COMBO("C5_XCLASSI",aCab[13,2])  + ' ) <' + AllTrim(SC5->C5_NUM) + '> contra o cliente gerado com sucesso.', 1, 0 )

							if nX == 2

								cPv1 := SC5->C5_NUM

							else

								cPv2 := SC5->C5_NUM

							endif

						endif

					endif

				Next nX

			endif

			if lRet

				/////////////////////////////////////////////////////////////////////////////////////////
				////// Ponto de Entrada Apos a geracao do pedido de venda do apontamento de servico ////
				////////////////////////////////////////////////////////////////////////////////////////
				if cTipo <> 'A' .And. ExistBlock("PFUN34PI")

					Conout(" >> Usa PE PFUN34PI")

					ExecBlock("PFUN34PI",.F.,.F.,{cContrato,cCliente,cLojaCli})

				endif


			EndIf

			//restauro a filial de acordo com a filial logada
			cFilAnt := cFilLogada

		endif

	else
		MsgInfo("N„o È permitido gerar Pedido Adm de Apontamento em fase de orcamento! ")
		lRet := .F.
	Endif

Return(lRet)

/*************************************/
User Function ItAParte(cApto,cProduto)
	/*************************************/

	Local aRet 		:= {}

	Local lProdUJ1	:= .F.
	Local nQtdeUJ1	:= 0

	DbSelectArea("UJ1")
	UJ1->(DbSetOrder(1)) //UJ1_FILIAL+UJ1_CODIGO+UJ1_ITEM

	If UJ1->(DbSeek(xFilial("UJ1")+cApto))

		While UJ1->(!EOF()) .And. xFilial("UJ1") == UJ1->UJ1_FILIAL .And. UJ1->UJ1_CODIGO == cApto

			If UJ1->UJ1_PRODUTO == cProduto

				lProdUJ1 := .T.
				nQtdeUJ1 := UJ1->UJ1_QUANT

				Exit
			Endif

			UJ1->(DbSkip())
		EndDo

		If lProdUJ1
			AAdd(aRet,.T.)
			AAdd(aRet,nQtdeUJ1)
		Else
			AAdd(aRet,.F.)
			AAdd(aRet,0)
		Endif
	Endif

Return aRet

/**********************************/
Static Function ExcluiPV(cPv,cTipo)
	/**********************************/

	Local lRet			:= .T.

	Local aCab 			:= {}
	Local aItens 		:= {}
	Local cFilLogada	:= cFilAnt

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	If UJ0->UJ0_TPSERV != '3'

		//altero a filial para a filial de servico
		if !Empty(UJ0->UJ0_FILSER)

			cFilAnt := UJ0->UJ0_FILSER

		endif

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

					If cTipo == "C" //Contra o cliente

						///////////////////////////////////////////////////////////////////////////
						////// Ponto de Entrada Apos a Exclusao do Pedido de Venda do Cliente ////
						//////////////////////////////////////////////////////////////////////////
						if ExistBlock("PFUN34PE")

							Conout(" >> Usa PE PFUN34PE")

							ExecBlock("PFUN34PE",.F.,.F.,{UJ0->UJ0_CONTRA,UJ0->UJ0_CLIPV,UJ0->UJ0_LOJAPV})

						endif

						MsgInfo("Pedido de Venda <"+AllTrim(cPv)+"> contra o cliente excluÌdo com sucesso.","AtenÁ„o")

					Else //Contra a adm. de planos

						MsgInfo("Pedido de Venda <"+AllTrim(cPv)+"> contra a administradora de planos excluÌdo com sucesso.","AtenÁ„o")

					Endif

				EndIf
			Else

				If cTipo == "C" //Contra o cliente

					MsgInfo("Pedido de Venda <"+AllTrim(cPv)+"> contra o cliente n„o localizado.","AtenÁ„o")

				Else //Contra a adm. de planos

					MsgInfo("Pedido de Venda <"+AllTrim(cPv)+"> contra a administradora de planos n„o localizado.","AtenÁ„o")

				Endif

				lRet := .F.

			Endif

		Else

			If cTipo == "C" //Contra o cliente

				MsgInfo("N„o h· Pedido de Venda contra o cliente relacionado a este apontamento.","AtenÁ„o")

			Else //Contra a adm. de planos

				MsgInfo("N„o h· Pedido de Venda contra a administradora de planos relacionado a este apontamento.","AtenÁ„o")

			Endif

			lRet := .F.

		Endif

		//restauro a filial logada
		cFilAnt := cFilLogada

	else

		MsgInfo("OperaÁ„o nao È permitida para Servicos em fase de orcamento")
		lRet := .F.
	Endif
Return lRet

/*/{Protheus.doc} FUNA034A
//Funcao para validar e gerar pedido
de vendas contra a administradora de planos
@author TOTVS
@since 04/05/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function FUNA034A()

	Local lRet		:= .F.

	Local cPv1		:= ""
	Local cPv2		:= ""
	Local lAux		:= .F.
	Local aDetalhes := {}

	If UJ0->UJ0_TPSERV != '3'

		If !Empty(UJ0->UJ0_CONTRA)

			If Empty(UJ0->UJ0_PVADM)

				If !Empty(UJ0->UJ0_CLIPA) .And. !Empty(UJ0->UJ0_LOJAPA) .And. !Empty(UJ0->UJ0_CONDPA)

					//Valida a seleÁ„o de ao menos um item
					DbSelectArea("UJ2")
					UJ2->(DbSetOrder(1)) //UJ2_FILIAL+UJ2_CODIGO+UJ2_ITEM

					If UJ2->(DbSeek(xFilial("UJ2")+UJ0->UJ0_CODIGO))

						While UJ2->(!EOF()) .And. xFilial("UJ2") == UJ2->UJ2_FILIAL .And. UJ2->UJ2_CODIGO == UJ0->UJ0_CODIGO

							If UJ2->UJ2_OK
								lAux := .T.
								Exit
							Endif

							UJ2->(DbSkip())
						EndDo
					Endif

					If lAux

						If MsgYesNo("Ser· gerado Pedido de Venda contra a adminstradora de planos para o apontamento selecionado, deseja continuar?")

							BeginTran()

							//-- Detalhes para cabeÁalho pedido de venda --//
							AADD(aDetalhes, UJ0->UJ0_NOMEFA)
							AADD(aDetalhes, UJ0->UJ0_DTFALE)
							AADD(aDetalhes, UJ0->UJ0_DECOBT)
							AADD(aDetalhes, UJ0->UJ0_CADOBT)
							If !Empty(UJ0->UJ0_REMOCA)
								AADD(aDetalhes, AllTrim(Posicione("UJC", 1, xFilial("UJC") + UJ0->UJ0_REMOCA, "UJC_DESCRI")))
							Else
								AADD(aDetalhes, AllTrim(UJ0->UJ0_LOCREM))
							EndIf
							If !Empty(UJ0->UJ0_VELORI)
								AADD(aDetalhes, AllTrim(Posicione("UJD", 1, xFilial("UJD") + UJ0->UJ0_VELORI, "UJD_DESCRI")))
							Else
								AADD(aDetalhes, AllTrim(UJ0->UJ0_LOCVEL))
							EndIf
							AADD(aDetalhes, UJ0->UJ0_MOTORI)
							AADD(aDetalhes, AllTrim(Posicione("UJB", 1, xFilial("UJB") + UJ0->UJ0_MOTORI, "UJB_NOME")))
							AADD(aDetalhes, UJ0->UJ0_RELIGI)
							AADD(aDetalhes, AllTrim(Posicione("UG3", 1, xFilial("UG3") + UJ0->UJ0_RELIGI, "UG3_DESC")))
							AADD(aDetalhes, UJ0->UJ0_ATENDE)

							MsgRun("Gerando Pedido de Venda contra a administradora de planos...",;
								"Aguarde",;
								{|| lRet := U_GeraPV_J(@cPv1,@cPv2,;
								UJ0->UJ0_CLIPA,;
								UJ0->UJ0_LOJAPA,;
								UJ0->UJ0_CONDPA,;
								"",;
								UJ0->UJ0_CODIGO,;
								UJ0->UJ0_CONTRA,;
								"A",;
								UJ0->UJ0_TABPRE,;
								aDetalhes)})

							//Atualiza status
							If lRet
								RecLock("UJ0",.F.)
								UJ0->UJ0_PVADM := cPv1
								UJ0->(MsUnlock())
							Endif

							EndTran()
						Endif
					Else
						MsgInfo("No apontamento n„o consta nenhum item configurado para gerar Pedido de Venda.","AtenÁ„o")
					Endif
				Else
					MsgInfo("Para a geraÁ„o do Pedido de Vendas os campos [Cli PV Adm], [Loja] e [Cond Pagto] devem ser preenchidos.","AtenÁ„o")
				Endif
			Else
				MsgInfo("Pedido de Venda contra a administradora de planos j· gerado para o apontamento selecionado.","AtenÁ„o")
			Endif
		Else
			MsgInfo("N„o È possÌvel gerar Pedido de Venda contra a administradora de planos para apontamento particular.","AtenÁ„o")
		Endif
	else
		MsgInfo("N„o È permitido gerar Pedido contra Adm de Apontamento em fase de orcamento.","AtenÁ„o")
	Endif
Return

/*/{Protheus.doc} FUNA034D
//Funcao para estornar o pedido de vendas
contra a administradora de planos
@author TOTVS
@since 04/05/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function FUNA034D()

	Local cFilLogada	:= cFilAnt
	Local lRet			:= .F.

	If UJ0->UJ0_TPSERV != '3'

		//altero a filial para a filial de servico
		if !Empty(UJ0->UJ0_FILSER)

			cFilAnt := UJ0->UJ0_FILSER

		endif

		If !Empty(UJ0->UJ0_PVADM)

			If MsgYesNo("Ser· estornado o Pedido de Venda contra a administradora de planos para o apontamento selecionado, deseja continuar?")

				BeginTran()

				//Verifica se tem PV relacionado, se sim, exclui
				DbSelectArea("SC5")
				SC5->(DbOrderNickName("XAPONTSC5")) //C5_FILIAL+C5_XCTRFUN+C5_XAPTOFU+C5_XTPAPTO

				DbSelectArea("SC6")
				SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

				DbSelectArea("SC9")
				SC9->(DbSetOrder(1)) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

				If SC5->(DbSeek(xFilial("SC5")+UJ0->UJ0_CONTRA+UJ0->UJ0_CODIGO+"A"))

					If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))

						While SC6->(!EOF()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM

							//Estorna liberaÁ„o do PV
							If SC9->(DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM))
								a460Estorna()
							Endif

							SC6->(DbSkip())
						EndDo
					Endif

					MsgRun("Excluindo Pedido de Venda contra a administradora de planos...","Aguarde",{|| lRet := ExcluiPV(UJ0->UJ0_PVADM,"A")})
				Endif

				//Atualiza status
				If lRet
					RecLock("UJ0",.F.)
					UJ0->UJ0_PVADM := ""
					UJ0->(MsUnlock())
				Endif

				EndTran()
			Endif
		Else
			MsgInfo("N„o h· Pedido de Venda contra a administradora de planos gerado para o apontamento selecionado.","AtenÁ„o")
		Endif

		//restauro a filial logada
		cFilAnt := cFilLogada

	else

		MsgInfo("OperaÁ„o nao È permitida para Servicos em fase de orcamento")
	Endif

Return( Nil )

/*********************/
User Function ContrJ()
/*********************/

	Local cRet

	cRet := M->UJ0_CONTRA

Return cRet

/*/{Protheus.doc} VldBenef
//Funcao para validar se o beneficiario
ja possui servico apontado para o mesmo
@author TOTVS
@since 04/05/2019
@version 1.0
@return ${return}, ${return_description}
@param cContra, characters, Contrato
@param cBenef, characters, Bencificiario
@type function
/*/
User Function VldBenef(cContra,cBenef)

	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUJ0		:= oModel:GetModel("UJ0MASTER")
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local lRet 			:= .T.

	if lPlanoPet

		// verifico se esta sendo executado pelo apontamento pet
		if (FWIsInCallStack("U_RUTIL025") .Or. AllTrim(FunName()) == "RUTIL025") .Or. (FWIsInCallStack("U_RFUNA002") .And. UF2->UF2_USO == "3")

			UK2->(DbSetOrder(1))
			if UK2->(MsSeek(xFilial("UK2")+cContra+cBenef))

				If !Empty(UK2->UK2_DTFALE)

					Help(,,'Help',,"Benefici·rio falecido, operaÁ„o n„o permitida.",1,0)
					lRet := .F.

				endIf

				if lRet

					oModelUJ0:LoadValue("UJ0_NOMBEN", AllTrim(UK2->UK2_NOME) )
					oModelUJ0:LoadValue("UJ0_NOMEFA", AllTrim(UK2->UK2_NOME) )
					oModelUJ0:LoadValue("UJ0_TIPPET", AllTrim(UK2->UK2_TIPO) )
					oModelUJ0:LoadValue("UJ0_DSCTIP", AllTrim(Posicione("UZ1",1,xFilial("UZ1")+UK2->UK2_TIPO,"UZ1_DESCRI")) )
					oModelUJ0:LoadValue("UJ0_RACA"	, AllTrim(UK2->UK2_RACA) )
					oModelUJ0:LoadValue("UJ0_DSCRAC", AllTrim(Posicione("UZ2",1,xFilial("UZ2")+UK2->UK2_TIPO+UK2->UK2_RACA,"UZ2_DESCRI")) )
					oModelUJ0:LoadValue("UJ0_CORPEL", AllTrim(UK2->UK2_CORPEL) )
					oModelUJ0:LoadValue("UJ0_DSCCOR", AllTrim(Posicione("SX5",1,xFilial("SX5")+"ZX"+UK2->UK2_CORPEL,"X5_DESCRI" )) )
					oModelUJ0:LoadValue("UJ0_PORTE"	, AllTrim(UK2->UK2_PORTE) )
					oModelUJ0:LoadValue("UJ0_IDADEF", UK2->UK2_IDADE )
					oModelUJ0:LoadValue("UJ0_SEXO"	, UK2->UK2_SEXO )


				endIf
			else
				lRet := .F.
				Help(,,'Help',,"Pet n„o encontrado no contrato, favor verificar os dados digitados!",1,0)

			endIf

		else

			UF4->(DbSetOrder(1)) //UF4_FILIAL+UF4_CODIGO+UF4_ITEM
			If UF4->(DbSeek(xFilial("UF4")+cContra+cBenef))

				If !Empty(UF4->UF4_FALECI)

					Help(,,'Help',,"Benefici·rio falecido, operaÁ„o n„o permitida.",1,0)
					lRet := .F.

					//Valido se o falecido È o titular
				elseif UF4->UF4_TIPO == "3"
					If !FWIsInCallStack("U_RFUNE052")
						if MsgYesNo("O falecido informado È o titular do contrato, favor realizar a transferÍncia de Titularidade,Deseja contitnuar ?")
							lRet := .T.
						else
							lRet := .F.
						Endif
					Else
						lRet := .T.
						Help(,,'Help',,"O falecido informado È o titular do contrato, avor realizar a transferÍncia de Titularidade.",1,0)
					EndIf
				Endif

				if lRet

					oModelUJ0:LoadValue("UJ0_NOMBEN"	, AllTrim(UF4->UF4_NOME) )
					oModelUJ0:LoadValue("UJ0_NOMEFA"	, AllTrim(UF4->UF4_NOME) )
					oModelUJ0:LoadValue("UJ0_IDADEF"	, UF4->UF4_IDADE )
					oModelUJ0:LoadValue("UJ0_ESTCFA"	, AllTrim(UF4->UF4_ESTCIV) )
					oModelUJ0:LoadValue("UJ0_CPF"		, AllTrim(UF4->UF4_CPF) )
					oModelUJ0:LoadValue("UJ0_SEXO"		, AllTrim(UF4->UF4_SEXO) )
					oModelUJ0:LoadValue("UJ0_DTNASC"	, UF4->UF4_DTNASC )

				endIf

			Else
				Help(,,'Help',,"Benefici·rio inv·lido.",1,0)
				lRet := .F.
			Endif

		endIf

	else

		UF4->(DbSetOrder(1)) //UF4_FILIAL+UF4_CODIGO+UF4_ITEM
		If UF4->(DbSeek(xFilial("UF4")+cContra+cBenef))

			If !Empty(UF4->UF4_FALECI)

				Help(,,'Help',,"Benefici·rio falecido, operaÁ„o n„o permitida.",1,0)
				lRet := .F.

				//Valido se o falecido È o titular
			elseif UF4->UF4_TIPO == "3"
				If !FWIsInCallStack("U_RFUNE052")
					if MsgYesNo("O falecido informado È o titular do contrato, favor realizar a transferÍncia de Titularidade,Deseja contitnuar ?")
						lRet := .T.
					else
						lRet := .F.
					Endif
				EndIf
			Endif

			if lRet

				oModelUJ0:LoadValue("UJ0_NOMBEN", AllTrim(UF4->UF4_NOME) )
				oModelUJ0:LoadValue("UJ0_NOMEFA", AllTrim(UF4->UF4_NOME) )
				oModelUJ0:LoadValue("UJ0_IDADEF", UF4->UF4_IDADE )
				oModelUJ0:LoadValue("UJ0_ESTCFA", AllTrim(UF4->UF4_ESTCIV) )
				oModelUJ0:LoadValue("UJ0_CPF"	, AllTrim(UF4->UF4_CPF) )
				oModelUJ0:LoadValue("UJ0_SEXO"	, AllTrim(UF4->UF4_SEXO) )

			endIf

		Else
			Help(,,'Help',,"Benefici·rio inv·lido.",1,0)
			lRet := .F.
		Endif

	endIf


Return(lRet)

/*************************************/
User Function VldCliPv(cTp,cCli,cLoja)
	/*************************************/

	Local lRet 	:= .T.

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

	If !Empty(cCli) .And. !Empty(cLoja)

		If !SA1->(DbSeek(xFilial("SA1")+cCli+cLoja))
			Help(,,'Help',,"Cliente inv·lido.",1,0)
			lRet := .F.
		Else
			If cTp == "A" //PV adm

				If SA1->A1_XADMFUN <> "S" //Dieferente de Adm. planos

					Help(,,'Help',,"Cliente n„o consta como Administradora de Planos.",1,0)
					lRet := .F.
				Endif
			Endif
		Endif
	Endif

Return lRet

/**************************/
User Function VldApto(lSel)
	/**************************/

	Local lRet 	:= .T.

	Local oModel		:= FWModelActive()
	Local oModelUJ0 	:= oModel:GetModel("UJ0MASTER")
	Local oModelUJ2 	:= oModel:GetModel("UJ2DETAIL")

	If !lSel .And. !oModelUJ2:IsDeleted()

		DbSelectArea("UF1")
		UF1->(DbSetOrder(2)) //UF1_FILIAL+UF1_CODIGO+UF1_PROD

		If UF1->(DbSeek(xFilial("UF1")+oModelUJ0:GetValue("UJ0_PLANOE")+oModelUJ2:GetValue("UJ2_PRODUT")))

			If UF1->UF1_APONTA == "O" //Apontamento obrigatÛrio
				Help(,,'Help',,"Conforme configuraÁ„o no Plano de entrega, este produto obrigatoriamente deve ser apontado.",1,0)
				lRet := .F.
			Endif
		Endif

		If lRet

			oModelUJ2:SetValue("UJ2_QUANT", 0)

			//Atualiza o resumo
			If Type("oOSTotais") <> "U"
				oOSTotais:RefreshTot()
			EndIf

		Endif

	Endif

Return lRet

/**************************/
User Function ()
	/**************************/

	Local lRet 	:= .T.
	Local oModel	:= FWModelActive()
	Local oModelUJ2 := oModel:GetModel("UJ2DETAIL")

	oModelUJ2:GetValue("UJ2_PRODUT")
	oModelUJ2:SetValue("UJ2_QUANT", 0)

Return lRet

/*/{Protheus.doc} FUNA034P
validacao do campo UJ0_CONTRA
@type function
@version 1.0
@author g.sampaio
@since 06/07/2021
@param cContr, character, codigo do contrato
@return logical, retorno logico da validacao
/*/
User Function FUNA034P(cContr)

	Local cQry			:= ""
	Local aArea			:= GetArea()
	Local aAreaUF2		:= UF2->(GetArea())
	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUJ1 	:= oModel:GetModel("UJ1DETAIL")
	Local oModelUJ0		:= oModel:GetModel("UJ0MASTER")
	Local cCodTab		:= SuperGetMv("MV_XTABSER",.F.,"001")
	Local lDivideQtd	:= SuperGetMv("MV_XDIVQTD",.F.,.F.) //Carrega a quantidade de ServiÁos de acordo com a n˙mero de Agregados
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local lRetorno		:= .T.
	Local lContinua		:= .T.
	Local nQtdBenef		:= 1
	Local nOperation 	:= oModel:GetOperation()

	Default cContr		:= ""

	UF2->(DbSetOrder(1))
	if UF2->(MsSeek(xFilial("UF2")+cContr))

		oModel:GetModel("UJ1DETAIL"):SetNoInsertLine(.F.)
		oModel:GetModel("UJ1DETAIL"):SetNoUpdateLine(.F.)
		oModel:GetModel("UJ1DETAIL"):SetNoDeleteLine(.F.)

		// se a operaÁ„o for inclus„o, limpo o grid, sen„o deleto todas as linhas
		if nOperation == MODEL_OPERATION_INSERT

			// funÁ„o que limpa o grid
			U_LimpaAcolsMVC(oModelUJ1,oView)

		else

			// funÁ„o que deleta todas as linhas do grid
			oModelUJ1:DelAllLine()

		endif

		If Select("QRYUF3") > 0
			QRYUF3->(DbCloseArea())
		Endif

		cQry := " SELECT UF3.UF3_PROD, ISNULL(DA1.DA1_PRCVEN,0) AS DA1_PRCVEN, UF3.UF3_SALDO, UF3.UF3_TIPO TIPO "

		if lPlanoPet
			cQry += " , SB1.B1_XUSOSRV USOSERV"
		endIf

		cQry += " FROM "+RetSqlName("UF3")+" UF3 INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_ 	= ' '
		cQry += " 																	AND SB1.B1_FILIAL = '"+ xFilial("SB1") + "' "
		cQry += " 																	AND SB1.B1_COD 	= UF3.UF3_PROD "
		cQry += " LEFT JOIN "+RetSqlName("DA1")+" DA1 ON UF3.UF3_PROD = DA1.DA1_CODPRO "
		cQry += " 																		AND DA1.D_E_L_E_T_ 	<> '*'"
		cQry += " 																		AND DA1.DA1_FILIAL 	= '"+xFilial("DA1")+"'"
		cQry += " 																		AND DA1.DA1_CODTAB	= '"+cCodTab+"'"
		cQry += " WHERE UF3.D_E_L_E_T_ 	<> '*'"
		cQry += " AND UF3.UF3_FILIAL 	= '"+xFilial("UF3")+"'"
		cQry += " AND UF3.UF3_CODIGO 	= '"+cContr+"'"

		//nao possibilito incluir produto sem saldo no apontamento
		cQry += " AND UF3.UF3_SALDO > 0 "

		cQry += " ORDER BY 1 DESC"

		MemoWrite("C:\Temp\FUNA034P"+CriaTrab( , .F. ) +".txt",cQry)

		cQry := ChangeQuery(cQry)

		MpSysOpenQuery(cQry, "QRYUF3")

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// CASO O PARAMETRO MV_XDIVQTD ESTEJA ATIVO, SERA DIVIDIDO A SALDO DO ITEM PELA QUANTIDADE DE BENEFICIARIOS DO PLANO.  ///
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		if lDivideQtd .And. !Empty(cContr)

			nQtdBenef := SomaQtdBeneficarios(cContr)

		endif

		If QRYUF3->(!EOF())

			While QRYUF3->(!EOF())

				if lPlanoPet

					if oModelUJ0:GetValue("UJ0_USO") == "2" // humano

						if QRYUF3->USOSERV $ " |1|2" // vazio, ambos ou humano

							//Se a primeira linha n„o estiver em branco, insiro uma nova linha
							If !Empty(oModelUJ1:GetValue("UJ1_PRODUT"))
								oModelUJ1:AddLine()
								oModelUJ1:GoLine(oModelUJ1:Length())
							Endif

							//divide o saldo do item pela quantidade de beneficiarios caso o parametro MV_XDIVQTD esteja ativo

							if Alltrim(QRYUF3->TIPO) == "ADDITENS.PNG" .And. lDivideQtd .And. QRYUF3->UF3_SALDO > 1

								nQtdItem := Round(QRYUF3->UF3_SALDO / nQtdBenef,0)

							else

								nQtdItem := QRYUF3->UF3_SALDO

							endif

							oModelUJ1:LoadValue("UJ1_PRODUT",	QRYUF3->UF3_PROD)
							oModelUJ1:LoadValue("UJ1_DESC",		Posicione("SB1",1,xFilial("SB1")+QRYUF3->UF3_PROD,"B1_DESC"))
							oModelUJ1:LoadValue("UJ1_PRCVEN",	QRYUF3->DA1_PRCVEN)
							oModelUJ1:LoadValue("UJ1_QUANT",	nQtdItem)
							oModelUJ1:LoadValue("UJ1_TOTAL",	QRYUF3->DA1_PRCVEN * nQtdItem)
							oModelUJ1:LoadValue("UJ1_USOSRV",	QRYUF3->USOSERV)

						endIf

					elseif oModelUJ0:GetValue("UJ0_USO") == "3" // pet

						if QRYUF3->USOSERV $ "1|3" // ambos e pet

							//Se a primeira linha n„o estiver em branco, insiro uma nova linha
							If !Empty(oModelUJ1:GetValue("UJ1_PRODUT"))
								oModelUJ1:AddLine()
								oModelUJ1:GoLine(oModelUJ1:Length())
							Endif

							//divide o saldo do item pela quantidade de beneficiarios caso o parametro MV_XDIVQTD esteja ativo

							if Alltrim(QRYUF3->TIPO) == "ADDITENS.PNG" .And. lDivideQtd .And. QRYUF3->UF3_SALDO > 1

								nQtdItem := Round(QRYUF3->UF3_SALDO / nQtdBenef,0)

							else

								nQtdItem := QRYUF3->UF3_SALDO

							endif

							oModelUJ1:LoadValue("UJ1_PRODUT",	QRYUF3->UF3_PROD)
							oModelUJ1:LoadValue("UJ1_DESC",		Posicione("SB1",1,xFilial("SB1")+QRYUF3->UF3_PROD,"B1_DESC"))
							oModelUJ1:LoadValue("UJ1_PRCVEN",	QRYUF3->DA1_PRCVEN)
							oModelUJ1:LoadValue("UJ1_QUANT",	nQtdItem)
							oModelUJ1:LoadValue("UJ1_TOTAL",	QRYUF3->DA1_PRCVEN * nQtdItem)
							oModelUJ1:LoadValue("UJ1_USOSRV",	QRYUF3->USOSERV)

						endIf

					else // ambos

						//Se a primeira linha n„o estiver em branco, insiro uma nova linha
						If !Empty(oModelUJ1:GetValue("UJ1_PRODUT"))
							oModelUJ1:AddLine()
							oModelUJ1:GoLine(oModelUJ1:Length())
						Endif

						//divide o saldo do item pela quantidade de beneficiarios caso o parametro MV_XDIVQTD esteja ativo

						if Alltrim(QRYUF3->TIPO) == "ADDITENS.PNG" .And. lDivideQtd .And. QRYUF3->UF3_SALDO > 1

							nQtdItem := Round(QRYUF3->UF3_SALDO / nQtdBenef,0)

						else

							nQtdItem := QRYUF3->UF3_SALDO

						endif

						oModelUJ1:LoadValue("UJ1_PRODUT",	QRYUF3->UF3_PROD)
						oModelUJ1:LoadValue("UJ1_DESC",		Posicione("SB1",1,xFilial("SB1")+QRYUF3->UF3_PROD,"B1_DESC"))
						oModelUJ1:LoadValue("UJ1_PRCVEN",	QRYUF3->DA1_PRCVEN)
						oModelUJ1:LoadValue("UJ1_QUANT",	nQtdItem)
						oModelUJ1:LoadValue("UJ1_TOTAL",	QRYUF3->DA1_PRCVEN * nQtdItem)
						oModelUJ1:LoadValue("UJ1_USOSRV",	QRYUF3->USOSERV)

					endIf

				else

					//Se a primeira linha n„o estiver em branco, insiro uma nova linha
					If !Empty(oModelUJ1:GetValue("UJ1_PRODUT"))
						oModelUJ1:AddLine()
						oModelUJ1:GoLine(oModelUJ1:Length())
					Endif

					//divide o saldo do item pela quantidade de beneficiarios caso o parametro MV_XDIVQTD esteja ativo

					if Alltrim(QRYUF3->TIPO) == "ADDITENS.PNG" .And. lDivideQtd .And. QRYUF3->UF3_SALDO > 1

						nQtdItem := Round(QRYUF3->UF3_SALDO / nQtdBenef,0)

					else

						nQtdItem := QRYUF3->UF3_SALDO

					endif

					oModelUJ1:LoadValue("UJ1_PRODUT",	QRYUF3->UF3_PROD)
					oModelUJ1:LoadValue("UJ1_DESC",		Posicione("SB1",1,xFilial("SB1")+QRYUF3->UF3_PROD,"B1_DESC"))
					oModelUJ1:LoadValue("UJ1_PRCVEN",	QRYUF3->DA1_PRCVEN)
					oModelUJ1:LoadValue("UJ1_QUANT",	nQtdItem)
					oModelUJ1:LoadValue("UJ1_TOTAL",	QRYUF3->DA1_PRCVEN * nQtdItem)

				endIf

				QRYUF3->(DbSkip())
			EndDo
		Endif

		oModel:GetModel("UJ1DETAIL"):SetNoInsertLine(.T.)
		oModel:GetModel("UJ1DETAIL"):SetNoUpdateLine(.T.)
		oModel:GetModel("UJ1DETAIL"):SetNoDeleteLine(.T.)

		//Atualiza o resumo
		If Type("oOSTotais") <> "U"
			oOSTotais:ContratadoRefresh()
		EndIf

		oModelUJ1:GoLine(1)

		If Select("QRYUF3") > 0
			QRYUF3->(DbCloseArea())
		Endif

	else
		lContinua := .F.
		HELP(' ',1,"CONTRATO" ,,"Contrato n„o encontrado no sistema!",2,0,,,,,, "Selecione o contrato corretamente.")

	endIf

	RestArea(aAreaUF2)
	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} IniCpoCont
//Funcao para inicializar campos
de acordo com o contrato posicionado.
@author TOTVS
@since 04/05/2019
@version 1.0
@param oView, object, descricao
@type function.
/*/
User Function IniCpoCont(oView)

	Local nOperation 	:= oView:GetOperation()
	Local oModel		:= FWModelActive()
	Local oModelUJ0 	:= oModel:GetModel("UJ0MASTER")
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local nCarencia		:= 0
	Local cTabela		:= Alltrim(SuperGetMv("MV_XTABSER",.F.,"001"))
	Local cNumSorte		:= ""

	UI2->(DbSetOrder(1)) //UI2_FILIAL + UI2_CODIGO

	If nOperation == 3 //Inclus„o

		If FunName() == "RFUNA002" .Or. FWIsInCallStack("U_RUTIL025") //Contrato

			nCarencia := If(UF2->UF2_PERCEN > 0, 100 - UF2->UF2_PERCEN, 0  )

			if UF2->( FieldPos("UF2_NUMSO2") ) > 0 .And. !Empty(UF2->UF2_NUMSO2)
				cNumSorte := UF2->UF2_NUMSO2
			else
				cNumSorte := UF2->UF2_NUMSOR
			endif

			FwFldPut("UJ0_CONTRA"	,UF2->UF2_CODIGO	,,,,.F.)
			FwFldPut("UJ0_PLANOC"	,UF2->UF2_PLANO		,,,,.F.)
			FwFldPut("UJ0_DESCPC"	,RETFIELD("UF0",1,XFILIAL("UF0")+UF2->UF2_PLANO,"UF0_DESCRI")		,,,,.F.)
			FwFldPut("UJ0_PERCDE"	,nCarencia			,,,,.F.)
			FwFldPut("UJ0_NUMSOR"	,cNumSorte			,,,,.F.)
			FwFldPut("UJ0_REGRA"	,UF2->UF2_REGRA		,,,,.F.)
			FwFldPut("UJ0_DESCRG"	,RetField("UJ5",1,xFilial("UJ5")+UF2->UF2_REGRA,"UJ5_DESCRI"),,,,.F.)
			FwFldPut("UJ0_TABPRC"	,cTabela			,,,,.T.)
			FwFldPut("UJ0_DESTAB"	,RetField("DA0",1,xFilial("DA0")+cTabela,"DA0_DESCRI"),,,,.F.)

			if lPlanoPet
				FwFldPut("UJ0_US0",UF2->UF2_USO,,,,.T.)
			endIf

			//preencho os campos de seguro na Ordem de Servico
			if UI2->(DbSeek(xFilial("UI2")+UF2->UF2_PLNSEG))

				FwFldPut("UJ0_PLNSEG",UF2->UF2_PLNSEG,,,,.F.)
				FwFldPut("UJ0_DSCPLN",UI2->UI2_DESCRI,,,,.F.)
				FwFldPut("UJ0_PLNM"  ,UI2->UI2_MORTE,,,,.F.)
				FwFldPut("UJ0_PLNMAC",UI2->UI2_MORACD,,,,.F.)
				FwFldPut("UJ0_PLNALI",UI2->UI2_AUXALI,,,,.F.)
				FwFldPut("UJ0_PLNCAP",UI2->UI2_SORTE,,,,.F.)
				FwFldPut("UJ0_PLNFUN",UI2->UI2_AUXFUN,,,,.F.)

			endif

			oView:Refresh()

		elseIf lPlanoPet .And. (FWIsInCallStack("U_RUTIL025") .Or. AllTrim(FunName()) == "RUTIL025")

			if FWIsInCallStack("U_RUTIL025")
				FwFldPut("UJ0_US0","3",,,,.T.)
			else
				nCarencia := If(UF2->UF2_PERCEN > 0, 100 - UF2->UF2_PERCEN, 0  )

				if UF2->( FieldPos("UF2_NUMSO2") ) > 0 .And. !Empty(UF2->UF2_NUMSO2)
					cNumSorte := UF2->UF2_NUMSO2
				else
					cNumSorte := UF2->UF2_NUMSOR
				endif

				FwFldPut("UJ0_TPSERV"	,"1"				,,,,.F.)
				FwFldPut("UJ0_CONTRA"	,UF2->UF2_CODIGO	,,,,.F.)
				FwFldPut("UJ0_PLANOC"	,UF2->UF2_PLANO		,,,,.F.)
				FwFldPut("UJ0_DESCPC"	,RETFIELD("UF0",1,XFILIAL("UF0")+UF2->UF2_PLANO,"UF0_DESCRI")		,,,,.F.)
				FwFldPut("UJ0_PERCDE"	,nCarencia			,,,,.F.)
				FwFldPut("UJ0_NUMSOR"	,cNumSorte			,,,,.F.)
				FwFldPut("UJ0_REGRA"	,UF2->UF2_REGRA		,,,,.F.)
				FwFldPut("UJ0_DESCRG"	,RetField("UJ5",1,xFilial("UJ5")+UF2->UF2_REGRA,"UJ5_DESCRI"),,,,.F.)
				FwFldPut("UJ0_TABPRC"	,cTabela			,,,,.T.)
				FwFldPut("UJ0_DESTAB"	,RetField("DA0",1,xFilial("DA0")+cTabela,"DA0_DESCRI"),,,,.F.)
				FwFldPut("UJ0_US0"		,UF2->UF2_USO		,,,,.T.)
			endIf

			oView:Refresh()
		EndIf

	Elseif nOperation <> 5 //Exclusao

		UF2->(DbSetOrder(1))
		UI2->(DbSetOrder(1))

		//Posiciono no contrato
		If UF2->(DbSeek(xFilial("UF2")+UJ0->UJ0_CONTRA))

			if UF2->( FieldPos("UF2_NUMSO2") ) > 0 .And. !Empty(UF2->UF2_NUMSO2)
				cNumSorte := UF2->UF2_NUMSO2
			else
				cNumSorte := UF2->UF2_NUMSOR
			endif

			//Posiciono no cadastro de plano seguro
			If UI2->(DbSeek(xFilial("UI2")+UF2->UF2_PLNSEG))

				//Carrega campos virtuais nas operacoes de visual, altera e exclui
				oModelUJ0:LoadValue("UJ0_PLNSEG", UF2->UF2_PLNSEG)
				oModelUJ0:LoadValue("UJ0_DSCPLN", UI2->UI2_DESCRI)
				oModelUJ0:LoadValue("UJ0_NUMSOR", cNumSorte)
				oModelUJ0:LoadValue("UJ0_PLNM"	, UI2->UI2_MORTE)
				oModelUJ0:LoadValue("UJ0_PLNMAC", UI2->UI2_MORACD)
				oModelUJ0:LoadValue("UJ0_PLNALI", UI2->UI2_AUXALI)
				oModelUJ0:LoadValue("UJ0_PLNCAP", UI2->UI2_SORTE)
				oModelUJ0:LoadValue("UJ0_PLNFUN", UI2->UI2_AUXFUN)

			Endif

		Endif

		oView:Refresh()

	EndIf

Return(Nil)

/*/{Protheus.doc} VldCarCtr
//Funcao para validar a carencia do contrato.
@author Raphael Martins
@type function
@since 29/03/2018
@version 1.0
@return character, retorno sobre a carencia do cotntrato
/*/
User Function ValCarCtr(cContrato)

	Local cRet			:= "N"
	Local aArea			:= GetArea()
	Local aAreaUF2		:= UF2->(GetArea())
	Local cQry			:= ""
	Local cPrefixo		:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
	Local cTipoParc		:= SuperGetMv("MV_XTIPFUN",.F.,"AT")
	Local cTipoAdt		:= SuperGetMv("MV_XTIPADT",.F.,"ADT")

	UF2->(DbSetOrder(1)) //UF2_FILIAL+UF2_CODIGO

	//Posiciono no contrato a ser validado
	If UF2->(DbSeek(xFilial("UF2")+cContrato))

		//Valido o tipo de carencia, sendo por 1=tempo ou 2=parcelas
		If UF2->UF2_TIPOCA == '1'

			If dDataBase <= UF2->UF2_CARENC
				cRet := 'S'
			Endif
		Else

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
				QRYPARC->(DbCloseArea())
			EndIf

			cQry := Changequery(cQry)
			TcQuery cQry New Alias "QRYPARC"

			//Valido se a quantidade paga e maior que a quantidade da carencia
			If UF2->UF2_QTPCAR > QRYPARC->PARCEL_PAGAS
				cRet := 'S'
			Endif
		Endif
	Endif

	RestArea(aArea)
	RestArea(aAreaUF2)

Return(cRet)

/*/{Protheus.doc} RFUNA34A
//Funcao para validar a quantidade
digitada no apontamento de servico
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function RFUNA34A(nQtdIt)

	Local oModel		:= FWModelActive()
	Local oModelUJ0		:= oModel:GetModel("UJ0MASTER")
	Local oModelUJ2		:= oModel:GetModel("UJ2DETAIL")
	Local lRet 			:= .T.

	Local nSubTotal		:= 0
	Local nVlrDes		:= 0

	If oModelUJ0:GetValue("UJ0_CARENC") == "S" .And. oModelUJ0:GetValue("UJ0_PERCDE") > 0 .And. PrdContr(oModelUJ2:GetValue("UJ2_PRODUT"))

		nSubTotal 	:= nQtdIt * oModelUJ2:GetValue("UJ2_PRCVEN")
		nVlrDes		:= nSubTotal * (oModelUJ0:GetValue("UJ0_PERCDE") / 100)

		oModelUJ2:LoadValue("UJ2_SUBTOT",	nSubTotal)
		oModelUJ2:LoadValue("UJ2_VLRDES",	nVlrDes)
		oModelUJ2:LoadValue("UJ2_TOTAL",	nSubTotal - nVlrDes)
	Else

		nSubTotal 	:= nQtdIt * oModelUJ2:GetValue("UJ2_PRCVEN")

		oModelUJ2:LoadValue("UJ2_SUBTOT",	nSubTotal)
		oModelUJ2:LoadValue("UJ2_TOTAL",	nSubTotal)
	Endif

	//atualiza totalizadores
	If Type("oOSTotais") <> "U"
		oOSTotais:RefreshTot()
	EndIf

Return(lRet)


/*/{Protheus.doc} RFUNA34B
FunÁ„o que retorna a cor da legenda de estoque: UJ2_ESTOQU

Legenda de Estoque (Bitmaps Protheus)
	METAS_CIMA_16 - Saldo em Estoque
	METAS_BAIXO_16 - Sem saldo em Estoque
	POSCLI - ServiÁo
	DEPENDENTES - Terceiros ou Parceiros

@author Pablo Nunes
@since 18/10/2022
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function RFUNA34B(cProd,nQtdInf,cCodFor)

	Local cLegenda := ""
	Local cArmazem := "01"
	Local nQtdEst := 0

	Default cProd := FWFLDGET("UJ2_PRODUT")
	Default nQtdInf := 0
	Default cCodFor := FWFLDGET("UJ2_CODFOR")

	cArmazem := RetFldProd(cProd,"B1_LOCPAD")
	cTipProd := RetField("SB1",1,xFilial("SB1")+cProd,"B1_TIPO")

	SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
	If !Empty(cCodFor)
		cLegenda := "DEPENDENTES" // ->> Terceiros ou Parceiros
	ElseIf cTipProd $ "MO|SV" //tipo do produto È SERVI«O
		cLegenda := "POSCLI" // ->> ServiÁo
	ElseIf SB2->(DbSeek(xFilial('SB2') + cProd + cArmazem))
		nQtdEst := SaldoMov(Nil,Nil,Nil,Nil,Nil,Nil, /*lSaldoSemR*/.F., /*dDataEmis*/dDataBase)
		If nQtdEst < nQtdInf
			cLegenda := "METAS_BAIXO_16" // ->> Sem saldo em Estoque
		Else
			cLegenda := "METAS_CIMA_16" // ->> Saldo em Estoque
		EndIf
	Else //n„o tem SB2 (considera como serviÁo - default)
		cLegenda := "POSCLI" // ->> ServiÁo
	EndIf

Return cLegenda

/*/{Protheus.doc} FUNA034B
FunÁ„o que mostra (visualizar) ou excluir pedidos de compras 

@author Pablo Nunes
@since 18/10/2022
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function FUNA034B(cTipo)

	Local lExclui := .F.
	Default cTipo := ""

	If cTipo == "V" //visualizaÁ„o dos pedidos de compras
		Mata121()
	ElseIf MsgYesNo("Deseja excluir os pedidos de compras do apontamento de serviÁo posicionado?") //exclus„o dos pedidos de compras
		lExclui := .F.
		UJ2->(DbSetOrder(1)) //UJ2_FILIAL+UJ2_CODIGO+UJ2_ITEM
		If UJ2->(DbSeek(xFilial("UJ2")+UJ0->UJ0_CODIGO))
			While UJ2->(!EOF()) .And. xFilial("UJ2") == UJ2->UJ2_FILIAL .And. UJ2->UJ2_CODIGO == UJ0->UJ0_CODIGO
				If UJ2->UJ2_OK .and. !Empty(UJ2->UJ2_PEDCOM)
					lExclui := .T.
					Exit
				EndIf
				UJ2->(DbSkip())
			EndDo
		EndIf
		If lExclui
			FWMsgRun(,{|oSay| U_FUNA034N()},'Aguarde','Realizando exclus„o dos Pedidos de Compras...')
		Else
			MsgInfo("No apontamento n„o consta nenhum item configurado para excluir Pedido de Compra.","AtenÁ„o")
		EndIf
	EndIf

Return

/*/{Protheus.doc} FUNA034N
FunÁ„o que excluir pedidos de compras 

@author Pablo Nunes
@since 18/10/2022
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function FUNA034N()

	Local aCab 			:= {}
	Local aItens 		:= {}

	Local aArea := GetArea()
	Local aAreaSC7 := SC7->(GetArea())

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	SC7->(DbSetOrder(1)) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
	UJ2->(DbSetOrder(1)) //UJ2_FILIAL+UJ2_CODIGO+UJ2_ITEM

	If UJ2->(DbSeek(xFilial("UJ2")+UJ0->UJ0_CODIGO))
		While UJ2->(!EOF()) .And. xFilial("UJ2") == UJ2->UJ2_FILIAL .And. UJ2->UJ2_CODIGO == UJ0->UJ0_CODIGO
			If UJ2->UJ2_OK .and. !Empty(UJ2->UJ2_PEDCOM)
				aCab := {}
				aItens := {}
				If SC7->(DbSeek(xFilial("SC5")+UJ2->UJ2_PEDCOM))

					aadd(aCab,{"C7_NUM",SC7->C7_NUM})
					aadd(aCab,{"C7_EMISSAO",SC7->C7_EMISSAO})
					aadd(aCab,{"C7_FORNECE",SC7->C7_FORNECE})
					aadd(aCab,{"C7_LOJA",SC7->C7_LOJA})
					aadd(aCab,{"C7_COND",SC7->C7_COND})
					aadd(aCab,{"C7_CONTATO",SC7->C7_CONTATO})
					aadd(aCab,{"C7_FILENT", SC7->C7_FILENT})

					aLinha := {}
					aadd(aLinha,{"C7_ITEM", SC7->C7_ITEM,Nil})
					aadd(aLinha,{"C7_PRODUTO", SC7->C7_PRODUTO,Nil})
					aadd(aLinha,{"C7_QUANT", SC7->C7_QUANT,Nil})
					aadd(aLinha,{"C7_PRECO", SC7->C7_PRECO,Nil})
					aadd(aLinha,{"C7_TOTAL", SC7->C7_TOTAL,Nil})
					aadd(aItens,aLinha)

					MSExecAuto({|a,b,c,d,e| MATA120(a,b,c,d,e)},1,aCab,aItens,5,.F.)

					If lMsErroAuto
						MostraErro()
						Exit //sai do While UJ2
					EndIf
				EndIf

				RecLock("UJ2",.F.)
				UJ2->UJ2_PEDCOM := ""
				UJ2->(MsUnlock())

			EndIf
			UJ2->(DbSkip())
		EndDo
	EndIf

	RestArea(aAreaSC7)
	RestArea(aArea)

Return !lMsErroAuto

/*/{Protheus.doc} FUNA034F
Gera os pedidos de compras para o apontamento de serviÁo posicionado

@author Pablo Nunes
@since 18/10/2022
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function FUNA034F()

	Local aEnvPed := {}
	Local nTotItem := ""

	If MsgYesNo("Deseja gerar os pedidos de compras do apontamento de serviÁo posicionado?") //geraÁ„o dos pedidos de compras

		UJ2->(DbSetOrder(1)) //UJ2_FILIAL+UJ2_CODIGO+UJ2_ITEM
		If UJ2->(MsSeek(xFilial("UJ2")+UJ0->UJ0_CODIGO))
			While UJ2->(!EOF()) .And. xFilial("UJ2") == UJ2->UJ2_FILIAL .And. UJ2->UJ2_CODIGO == UJ0->UJ0_CODIGO
				If !Empty(UJ2->UJ2_CODFOR) .and. !Empty(UJ2->UJ2_LOJFOR) .and. Empty(UJ2->UJ2_PEDCOM)
					If UJ2->UJ2_TOTAL > 0
						nTotItem := UJ2->UJ2_TOTAL / UJ2->UJ2_QUANT // Valor por minimo de item com financeiro
					Else
						nTotItem := UJ2->UJ2_SUBTOT / UJ2->UJ2_QUANT // Valor por item somente estoque
					EndIf
					AAdd(aEnvPed,{UJ2->UJ2_CODFOR,UJ2->UJ2_LOJFOR,UJ2->UJ2_LOCAL,UJ2->UJ2_PRODUT,UJ2->UJ2_QUANT,nTotItem,UJ2->(UJ2_FILIAL+UJ2_CODIGO+UJ2_ITEM),UJ2->UJ2_CODIGO})
				EndIf
				UJ2->(DbSkip())
			EndDo
		EndIf

		If Len(aEnvPed) > 0
			//Ordena os dados do pedido por fornecedor/loja
			aSort(aEnvPed,,,{|x,y| x[1]+x[2] < y[1]+y[2]})
			FWMsgRun(,{|oSay| U_FUNA034C(aEnvPed)},'Aguarde','Realizando Pedidos de Compras...')
		Else
			MsgInfo("No apontamento n„o consta nenhum item configurado para gerar Pedido de Compra.","AtenÁ„o")
		EndIf

	EndIf

Return

/*/{Protheus.doc} FUNA034C
Gera os pedidos de compras para o arrray "aEnvPed".
aEnvPed -> {UJ2->UJ2_CODFOR,UJ2->UJ2_LOJFOR,UJ2->UJ2_LOCAL,UJ2->UJ2_PRODUT,UJ2->UJ2_QUANT,nTotItem,UJ2->(UJ2_FILIAL+UJ2_CODIGO+UJ2_ITEM),UJ2->UJ2_CODIGO}

@author Pablo Nunes
@since 18/10/2022
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function FUNA034C(aEnvPed)

	Local aArea := GetArea()
	Local aAreaSC7 := SC7->(GetArea())

	Local cNumPc := ""
	Local aCab   := {}
	Local aItens := {}
	Local aLinha := {}
	Local cCodFor := ""
	Local cCodLoj := ""
	Local cItemPC := StrZero(1,TamSX3("C7_ITEM")[1])
	Local nX := 0, nY := 0
	Local cCondPg := SUPERGETMV("MV_XCONDFU",.F.,"001")
	Local aAponts := {}

	Private lMsErroAuto := .F.
	Private lMSHelpAuto := .T. // para mostrar os erros na tela

	Default aEnvPed := {}

	If Len(aEnvPed)>0

		For nX:=1 to Len(aEnvPed)

			If cCodFor <> aEnvPed[nX][1] .or. cCodLoj <> aEnvPed[nX][2]

				If Len(aCab) > 0 .and. Len(aItens) > 0
					MSExecAuto({|x,y,z| MATA121(x,y,z)},aCab,aItens,3)
					If lMSErroAuto  //Determina se houve alguma inconsistencia na execucao da rotina
						MostraErro()
						RollBackSX8()
					Else
						//EndTran()
						ConfirmSx8()
						aCab := {}
						aItens := {}
						UJ2->(DbSetOrder(1)) //UJ2_FILIAL+UJ2_CODIGO+UJ2_ITEM
						For nY := 1  to Len(aAponts)
							If UJ2->(MsSeek(aAponts[nY]))
								RecLock("UJ2",.F.)
								UJ2->UJ2_PEDCOM := SC7->C7_NUM
								UJ2->(MsUnlock())
							EndIf
						Next nY
						aAponts := {}
					EndIf
				EndIf

				cNumPc := GetSxeNum("SC7","C7_NUM")
				cCodFor := aEnvPed[nX][1]
				cCodLoj := aEnvPed[nX][2]
				aCab := {}
				aItens := {}
				cItemPC := StrZero(1,TamSX3("C7_ITEM")[1])

				aCab := {{"C7_FILIAL"         ,xFilial("SC7") 								,Nil},; //Filial
				{"C7_NUM"                     ,cNumPc        				 				,Nil},; //N˙mero do Pedido
				{"C7_EMISSAO"                 ,dDataBase   					  				,Nil},; //Data da Emiss„o do Pedido
				{"C7_FORNECE"                 ,cCodFor                                  	,Nil},; //Fornecedor
				{"C7_LOJA"                    ,cCodLoj                                  	,Nil},; //Loja
				{"C7_COND"                    ,cCondPg										,Nil},; //CondiÁ„o de Pagamento
				{"C7_FILENT"                  ,xFilEnt(xFilial("SC7"))        				,Nil};  //Filial
				}

			EndIf

			alinha := {}
			aLinha := {{"C7_FILIAL"      ,xFilial("SC7")												,Nil},; //Filial
			{"C7_ITEM"   				 ,cItemPC			               								,Nil},; //Item
			{"C7_PRODUTO"                ,aEnvPed[nX][4]          										,Nil},; //Produto
			{"C7_UM"					 ,Posicione("SB1",1,xFilial("SB1")+aEnvPed[nX][4],"B1_UM")  	,Nil},; //Unidade de Medida
			{"C7_QUANT" 				 ,aEnvPed[nX][5]    											,Nil},; //Quantidade
			{"C7_PRECO"                  ,aEnvPed[nX][6]							    				,Nil},; //PreÁo
			{"C7_LOCAL"                  ,Posicione("SB1",1,xFilial("SB1")+aEnvPed[nX][4],"B1_LOCPAD")	,Nil},; //Local
			{"C7_PLANILH"                ,aEnvPed[nX][8]												,Nil};  //Fabricante (Apontamento x Pedido)
			}

			cItemPC := Soma1(cItemPC)
			AAdd(aAponts,aEnvPed[nX][7])
			AAdd(aItens,aLinha)

		Next nX

		If Len(aCab) > 0 .and. Len(aItens) > 0
			MSExecAuto({|x,y,z| MATA121(x,y,z)},aCab,aItens,3)
			If lMSErroAuto  //Determina se houve alguma inconsistencia na execucao da rotina
				MostraErro()
				RollBackSX8()
			Else
				//EndTran()
				ConfirmSx8()
				aCab := {}
				aItens := {}
				UJ2->(DbSetOrder(1)) //UJ2_FILIAL+UJ2_CODIGO+UJ2_ITEM
				For nY := 1  to Len(aAponts)
					If UJ2->(MsSeek(aAponts[nY]))
						RecLock("UJ2",.F.)
						UJ2->UJ2_PEDCOM := SC7->C7_NUM
						UJ2->(MsUnlock())
					EndIf
				Next nY
				aAponts := {}
			EndIf
		EndIf

	EndIf

	RestArea(aAreaSC7)
	RestArea(aArea)

Return !lMSErroAuto


/*/{Protheus.doc} PrdContr
//Funcao para validar se o produto
digitado na GRID de produtos entregues
faz parte do plano contratado
@author TOTVS
@since 29/03/2018
@version 1.0
@type function
/*/
Static Function PrdContr(cProdUJ2)

	Local lRet			:= .F.

	Local oModel		:= FWModelActive()
	Local oModelUJ1 	:= oModel:GetModel("UJ1DETAIL")
	Local aSaveLines  	:= FWSaveRows()

	Local nI
	Local nAux		:= 0

	For nI := 1 To oModelUJ1:Length()

		//Posiciono na linha atual
		oModelUJ1:Goline(nI)

		If !oModelUJ1:IsDeleted()

			If oModelUJ1:GetValue("UJ1_PRODUT") == cProdUJ2
				lRet := .T.
				Exit
			Endif
		Endif
	Next nI

Return lRet

/*/{Protheus.doc} VldPlanE
Funcao para validar o plano entregue
selecionado
@type function
@version 1.0
@author TOTVS
@since 14/04/2019
/*/
User Function VldPlanE()

	Local aArea			:= GetArea()
	Local cQry			:= ""
	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUJ0 	:= oModel:GetModel("UJ0MASTER")
	Local oModelUJ2 	:= oModel:GetModel("UJ2DETAIL")
	Local cContr		:= oModelUJ0:GetValue("UJ0_CONTRA")
	Local cPlanoC		:= oModelUJ0:GetValue("UJ0_PLANOC")
	Local cPlanoE		:= oModelUJ0:GetValue("UJ0_PLANOE")
	Local cCodBen		:= oModelUJ0:GetValue("UJ0_CODBEN")
	Local cCodTab		:= oModelUJ0:GetValue("UJ0_TABPRC")
	Local cFilServ		:= oModelUJ0:GetValue("UJ0_FILSER")
	Local cFilContrato	:= xFilial("UF2")
	Local cFilLogada	:= cFilAnt
	Local lDivideQtd	:= SuperGetMv("MV_XDIVQTD",.F.,.F.)
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local lContinua		:= .T.
	Local lSemPlanoE	:= .F.
	Local lRetorno		:= .T.
	Local lCarencia		:= .F.
	Local nQtdBenef		:= 1
	Local nQtdItem		:= 0
	Local nOperation 	:= oModel:GetOperation()
	Local nSubTotal		:= 0
	Local nVlrDes		:= 0

	lVldLinUJ2 := .F.

	// valido se o plano entregue esta preenchido para seguir com as validacoes
	If Empty(AllTrim(cPlanoE)) .Or. Empty(oModelUJ0:GetValue("UJ0_PLANOE"))
		lSemPlanoE 	:= .T.
		lContinua 	:= .F.
	EndIf

	If lContinua .And. Empty(cCodBen) .AND. !Empty(oModelUJ0:GetValue("UJ0_CONTRA"))
		Help( ,, 'VldBen',, '… necess·rio preencher o beneficiario antes de selecionar o plano entregue !', 1, 0 )
		lContinua := .F.
	Endif

	If lContinua .And. Empty(oModelUJ0:GetValue("UJ0_FILSER"))
		Help( ,, 'VldFil',, '… necess·rio preencher a filial de serviÁo antes de selecionar o plano entregue !', 1, 0 )
		lContinua := .F.
	Endif

	// verifico se os campos de filial de servico
	if lContinua .And. !Empty(oModelUJ0:GetValue("UJ0_FILSER")) .And.;
			!Empty(oModelUJ0:GetValue("UJ0_TABPRC")) .And. !Empty(oModelUJ0:GetValue("UJ0_FILSER"))

		UF0->(DbSetOrder(1))
		if UF0->( MsSeek( xFilial("UF0",cFilServ)+cPlanoE ))

			FwFldPut("UJ0_DESCPE"	, UF0->UF0_DESCRI,,,,.T.)

			if lPlanoPet

				if oModelUJ0:GetValue("UJ0_USO") == "3"
					if !(UF0->UF0_USO $ "1|3")
						Help( ,, 'PLANOPET',, 'Quando o uso do apontamento È para Pet, o plano Entregue tambÈm tem que ser para uso pet!', 1, 0 )
						lContinua := .F.
					endIf
				endIf

				if lContinua
					FwFldPut("UJ0_USOENT"	, UF0->UF0_USO	,,,,.F.)
				endIf

			endIf

		elseif !Empty(cPlanoE)
			lContinua := .F.
			Help( ,, 'PLANO',, 'O Plano informado n„o existe, digite ou selecione um plano v·lido!', 1, 0 )

		endIf

	endIf

	if lContinua

		// se a operaÁ„o for inclus„o, limpo o grid, sen„o deleto todas as linhas
		if nOperation == MODEL_OPERATION_INSERT

			// funÁ„o que limpa o grid
			U_LimpaAcolsMVC(oModelUJ2,oView)

		else

			// funÁ„o que deleta todas as linhas do grid
			oModelUJ2:DelAllLine()

		endif

		If Select("QRYPROD") > 0
			QRYPROD->(DbCloseArea())
		Endif

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// CASO O PARAMETRO MV_XDIVQTD ESTEJA ATIVO, SERA DIVIDIDO A SALDO DO ITEM PELA QUANTIDADE DE BENEFICIARIOS DO PLANO.  ///
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		//Carrega a quantidade de ServiÁos de acordo com a n˙mero de Agregados
		if lDivideQtd .And. !Empty(cContr)

			nQtdBenef := SomaQtdBeneficarios(cContr)

		endif

		//Filial de Servico igual filial logada e Plano entregue igual ao Plano contratado
		if cFilAnt == cFilServ .And. cPlanoE == cPlanoC

			////////////////////////////////////////////////////////////
			/////////		PESQUISO OS ITENS DO CONTRATO		////////
			////////////////////////////////////////////////////////////

			cQry := " SELECT "
			cQry += " UF3.UF3_PROD AS				PRODUTO, "
			cQry += " ISNULL(DA1.DA1_PRCVEN,0) AS	PRECO_VENDA,  "
			cQry += " UF3.UF3_QUANT AS				QUANTIDADE, "
			cQry += " UF3.UF3_CARENC AS				CARENCIA, "
			cQry += " UF3.UF3_TIPO AS 				TIPO "
			cQry += " FROM "
			cQry += RetSqlName("UF3")+" UF3 "
			cQry += " LEFT JOIN "
			cQry += RetSqlName("DA1") + " DA1
			cQry += " ON UF3.UF3_PROD = DA1.DA1_CODPRO"
			cQry += " AND DA1.D_E_L_E_T_ 	<> '*' "
			cQry += " AND DA1.DA1_FILIAL 	= '" + xFilial("DA1") + "' "
			cQry += " AND DA1.DA1_CODTAB	= '" + cCodTab + "' "
			cQry += " WHERE UF3.D_E_L_E_T_ 	<> '*' "
			cQry += " AND UF3.UF3_FILIAL 	= '" + xFilial("UF3") + "' "
			cQry += " AND UF3.UF3_CODIGO 	= '" + cContr + "' "
			cQry += " AND (UF3.UF3_CTRSLD = 'S' AND UF3.UF3_SALDO > 0 OR UF3.UF3_CTRSLD = 'N')"

			cQry += " ORDER BY 1 DESC"

		else

			//altero a filial de acordo com a filial de servico
			cFilAnt 	:= cFilServ

			//Recarrego a tabela de acordo com a filial selecionada, em caso de servico associado
			if !Empty(cPlanoC)
				cCodTab		:= SuperGetMv("MV_XTABSER",.F.,"001")
			endif

			////////////////////////////////////////////////////////////////////////////////////////////////////////////
			/////////		PESQUISO OS ITENS DO PLANO SELECIONADO + OS ITENS PERSONALIZADOS DO CONTRATO		////////
			////////////////////////////////////////////////////////////////////////////////////////////////////////////

			cQry := "SELECT
			cQry += " UF1.UF1_PROD				AS PRODUTO ,
			cQry += " ISNULL(DA1.DA1_PRCVEN,0)	AS PRECO_VENDA,
			cQry += " UF1.UF1_QUANT				AS QUANTIDADE, "
			cQry += " '	' 						AS CARENCIA, "
			cQry += " ' ' 						AS TIPO "
			cQry += " FROM "
			cQry += RetSQLName("UF1") + " UF1 "
			cQry += " LEFT JOIN  "
			cQry += RetSqlName("DA1") + " DA1
			cQry += " ON UF1.UF1_PROD = DA1.DA1_CODPRO"
			cQry += " AND DA1.D_E_L_E_T_ 	<> '*'"
			cQry += " AND DA1.DA1_FILIAL 	= '" + xFilial("DA1") + "' "
			cQry += " AND DA1.DA1_CODTAB	= '" + cCodTab + "' "
			cQry += " WHERE UF1.D_E_L_E_T_ 	<> '*'"
			cQry += " AND UF1.UF1_FILIAL 	= '" + xFilial("UF1") + "' "
			cQry += " AND UF1.UF1_CODIGO 	= '"+cPlanoE+"'"
			cQry += " AND NOT EXISTS "
			cQry += " ( "
			cQry += " 	SELECT UF3_PROD "
			cQry += "	FROM "
			cQry += 	RetSQLName("UF3") + " ITENS "
			cQry += " 	WHERE "
			cQry += " 	ITENS.D_E_L_E_T_ = ' ' "
			cQry += " 	AND ITENS.UF3_FILIAL = '" + cFilContrato + "' "
			cQry += " 	AND ITENS.UF3_CODIGO = '" + cContr + "' "
			cQry += " 	AND ITENS.UF3_TIPO = 'ADDITENS.PNG' "
			cQry += "	AND ITENS.UF3_PROD = UF1.UF1_PROD "
			cQry += " )

			//consulto na tabela do contrato os itens personalizados, somente se o apontamento possui contrato preenchido
			if !Empty(cContr)

				cQry += " UNION "

				cQry += " SELECT "
				cQry += " UF3.UF3_PROD 					PRODUTO, "
				cQry += " ISNULL(DA1.DA1_PRCVEN,0) AS	PRECO_VENDA,  "
				cQry += " UF3.UF3_SALDO					QUANTIDADE, "
				cQry += " UF3.UF3_CARENC AS				CARENCIA, "
				cQry += " UF3.UF3_TIPO AS 				TIPO "
				cQry += " FROM "
				cQry += RetSqlName("UF3")+" UF3 "
				cQry += " LEFT JOIN "
				cQry += RetSqlName("DA1") + " DA1
				cQry += " ON UF3.UF3_PROD = DA1.DA1_CODPRO "
				cQry += " AND DA1.D_E_L_E_T_ 	<> '*' "
				cQry += " AND DA1.DA1_FILIAL 	= '" + xFilial("DA1") + "' "
				cQry += " AND DA1.DA1_CODTAB	= '" + cCodTab + "' "
				cQry += " WHERE UF3.D_E_L_E_T_ 	<> '*' "
				cQry += " AND UF3.UF3_FILIAL 	= '" + cFilContrato + "' "
				cQry += " AND UF3.UF3_CODIGO 	= '" + cContr + "' "
				cQry += " AND UF3.UF3_TIPO 		= 'ADDITENS.PNG' " //ITENS PERSONALIZADOS DO CONTRATO
				cQry += " AND (UF3.UF3_CTRSLD = 'S' AND UF3.UF3_SALDO > 0 OR UF3.UF3_CTRSLD = 'N')"

			endif

			cQry += " ORDER BY 1 DESC"

			Memowrite("C:\TOTVS\OS.SQL",cQry)
		endif

		cQry := ChangeQuery(cQry)

		MpSysOpenQuery(cQry, "QRYPROD")

		If QRYPROD->(!EOF())

			oModelUJ2:GoLine(oModelUJ2:Length())

			While QRYPROD->(!EOF())

				//divide o saldo do item pela quantidade de beneficiarios caso o parametro MV_XDIVQTD esteja ativo
				if Alltrim(QRYPROD->TIPO) = "ADDITENS.PNG" .And. lDivideQtd .And. QRYPROD->QUANTIDADE > 1

					nQtdItem := Round(QRYPROD->QUANTIDADE / nQtdBenef,0)

				else

					nQtdItem := QRYPROD->QUANTIDADE

				endif

				SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD

				//posiciono se na SB1 pra pegar nome e armazem
				If SB1->(DbSeek(xFilial("SB1")+QRYPROD->PRODUTO))

					if lPlanoPet // para plano pet ativo

						if oModelUJ0:GetValue("UJ0_USO") == "3" // uso pet

							if !Empty(SB1->B1_XUSOSRV) .And. SB1->B1_XUSOSRV $ "1|3"

								//Se a primeira linha n„o estiver em branco, insiro uma nova linha
								If !Empty(oModelUJ2:GetValue("UJ2_PRODUT"))

									oModelUJ2:AddLine()
									oModelUJ2:GoLine(oModelUJ2:Length())

								Endif

								oModelUJ2:LoadValue("UJ2_OK",		.T.)
								oModelUJ2:LoadValue("UJ2_PRODUT",	QRYPROD->PRODUTO)
								oModelUJ2:LoadValue("UJ2_DESC",		Alltrim(SB1->B1_DESC) )
								oModelUJ2:LoadValue("UJ2_PRCVEN",	QRYPROD->PRECO_VENDA)
								oModelUJ2:LoadValue("UJ2_QUANT",	nQtdItem)
								oModelUJ2:LoadValue("UJ2_SUBTOT",	nQtdItem * QRYPROD->PRECO_VENDA)
								oModelUJ2:LoadValue("UJ2_LOCAL",	SB1->B1_LOCPAD )

								////////////////////////////////////////////////////
								///////// VALIDO SALDO EM ESTOQUE DO PRODUTO //////
								///////////////////////////////////////////////////

								oModelUJ2:LoadValue("UJ2_ESTOQU",U_RFUNA34B(QRYPROD->PRODUTO,QRYPROD->QUANTIDADE))

								//se o item esta em carencia aplicado o desconto do mesmo
								If oModelUJ0:GetValue("UJ0_CARENC") == "S" .Or. ( !Empty(QRYPROD->CARENCIA) .And. dDataBase <= STOD(QRYPROD->CARENCIA) )

									nSubTotal 	:= nQtdItem * QRYPROD->PRECO_VENDA
									nVlrDes		:= nSubTotal * (oModelUJ0:GetValue("UJ0_PERCDE") / 100)

									oModelUJ2:LoadValue("UJ2_CARENC"	,	"BR_LARANJA")
									oModelUJ2:LoadValue("UJ2_PERDES"	,	oModelUJ0:GetValue("UJ0_PERCDE"))
									oModelUJ2:LoadValue("UJ2_VLRDES"	,	nVlrDes)
									oModelUJ2:LoadValue("UJ2_TOTAL"		,	nSubTotal - nVlrDes)

									lCarencia := .T.

								Else

									oModelUJ2:LoadValue("UJ2_CARENC"	,	"BR_VERDE")
									oModelUJ2:LoadValue("UJ2_TOTAL"		,	nQtdItem * QRYPROD->PRECO_VENDA)

								Endif

								oModelUJ2:LoadValue("UJ2_PV"		,	"S")
								oModelUJ2:LoadValue("UJ2_UNESTO"	,	xFilial("SCP") )
								oModelUJ2:LoadValue("UJ2_USOSRV"	,	SB1->B1_XUSOSRV )

							endIf

						elseIf oModelUJ0:GetValue("UJ0_USO") == "2" // uso humano

							if Empty(SB1->B1_XUSOSRV) .Or. SB1->B1_XUSOSRV $ "1|2"

								//Se a primeira linha n„o estiver em branco, insiro uma nova linha
								If !Empty(oModelUJ2:GetValue("UJ2_PRODUT"))

									oModelUJ2:AddLine()
									oModelUJ2:GoLine(oModelUJ2:Length())

								Endif

								oModelUJ2:LoadValue("UJ2_OK",		.T.)
								oModelUJ2:LoadValue("UJ2_PRODUT",	QRYPROD->PRODUTO)
								oModelUJ2:LoadValue("UJ2_DESC",		Alltrim(SB1->B1_DESC) )
								oModelUJ2:LoadValue("UJ2_PRCVEN",	QRYPROD->PRECO_VENDA)
								oModelUJ2:LoadValue("UJ2_QUANT",	nQtdItem)
								oModelUJ2:LoadValue("UJ2_SUBTOT",	nQtdItem * QRYPROD->PRECO_VENDA)
								oModelUJ2:LoadValue("UJ2_LOCAL",	SB1->B1_LOCPAD )

								////////////////////////////////////////////////////
								///////// VALIDO SALDO EM ESTOQUE DO PRODUTO //////
								///////////////////////////////////////////////////

								oModelUJ2:LoadValue("UJ2_ESTOQU",U_RFUNA34B(QRYPROD->PRODUTO,QRYPROD->QUANTIDADE))

								//se o item esta em carencia aplicado o desconto do mesmo
								If oModelUJ0:GetValue("UJ0_CARENC") == "S" .Or. ( !Empty(QRYPROD->CARENCIA) .And. dDataBase <= STOD(QRYPROD->CARENCIA) )

									nSubTotal 	:= nQtdItem * QRYPROD->PRECO_VENDA
									nVlrDes		:= nSubTotal * (oModelUJ0:GetValue("UJ0_PERCDE") / 100)

									oModelUJ2:LoadValue("UJ2_CARENC"	,	"BR_LARANJA")
									oModelUJ2:LoadValue("UJ2_PERDES"	,	oModelUJ0:GetValue("UJ0_PERCDE"))
									oModelUJ2:LoadValue("UJ2_VLRDES"	,	nVlrDes)
									oModelUJ2:LoadValue("UJ2_TOTAL"		,	nSubTotal - nVlrDes)

									lCarencia := .T.

								Else

									oModelUJ2:LoadValue("UJ2_CARENC"	,	"BR_VERDE")
									oModelUJ2:LoadValue("UJ2_TOTAL"		,	nQtdItem * QRYPROD->PRECO_VENDA)

								Endif

								oModelUJ2:LoadValue("UJ2_PV"		,	"S")
								oModelUJ2:LoadValue("UJ2_UNESTO"	,	xFilial("SCP") )
								oModelUJ2:LoadValue("UJ2_USOSRV"	,	SB1->B1_XUSOSRV )

							endIf

						else

							//Se a primeira linha n„o estiver em branco, insiro uma nova linha
							If !Empty(oModelUJ2:GetValue("UJ2_PRODUT"))

								oModelUJ2:AddLine()
								oModelUJ2:GoLine(oModelUJ2:Length())

							Endif

							oModelUJ2:LoadValue("UJ2_OK",		.T.)
							oModelUJ2:LoadValue("UJ2_PRODUT",	QRYPROD->PRODUTO)
							oModelUJ2:LoadValue("UJ2_DESC",		Alltrim(SB1->B1_DESC) )
							oModelUJ2:LoadValue("UJ2_PRCVEN",	QRYPROD->PRECO_VENDA)
							oModelUJ2:LoadValue("UJ2_QUANT",	nQtdItem)
							oModelUJ2:LoadValue("UJ2_SUBTOT",	nQtdItem * QRYPROD->PRECO_VENDA)
							oModelUJ2:LoadValue("UJ2_LOCAL",	SB1->B1_LOCPAD )

							////////////////////////////////////////////////////
							///////// VALIDO SALDO EM ESTOQUE DO PRODUTO //////
							///////////////////////////////////////////////////

							oModelUJ2:LoadValue("UJ2_ESTOQU",U_RFUNA34B(QRYPROD->PRODUTO,QRYPROD->QUANTIDADE))

							//se o item esta em carencia aplicado o desconto do mesmo
							If oModelUJ0:GetValue("UJ0_CARENC") == "S" .Or. ( !Empty(QRYPROD->CARENCIA) .And. dDataBase <= STOD(QRYPROD->CARENCIA) )

								nSubTotal 	:= nQtdItem * QRYPROD->PRECO_VENDA
								nVlrDes		:= nSubTotal * (oModelUJ0:GetValue("UJ0_PERCDE") / 100)

								oModelUJ2:LoadValue("UJ2_CARENC"	,	"BR_LARANJA")
								oModelUJ2:LoadValue("UJ2_PERDES"	,	oModelUJ0:GetValue("UJ0_PERCDE"))
								oModelUJ2:LoadValue("UJ2_VLRDES"	,	nVlrDes)
								oModelUJ2:LoadValue("UJ2_TOTAL"		,	nSubTotal - nVlrDes)

								lCarencia := .T.

							Else

								oModelUJ2:LoadValue("UJ2_CARENC"	,	"BR_VERDE")
								oModelUJ2:LoadValue("UJ2_TOTAL"		,	nQtdItem * QRYPROD->PRECO_VENDA)

							Endif

							oModelUJ2:LoadValue("UJ2_PV"		,	"S")
							oModelUJ2:LoadValue("UJ2_UNESTO"	,	xFilial("SCP") )

						endIf

					else

						//Se a primeira linha n„o estiver em branco, insiro uma nova linha
						If !Empty(oModelUJ2:GetValue("UJ2_PRODUT"))

							oModelUJ2:AddLine()
							oModelUJ2:GoLine(oModelUJ2:Length())

						Endif

						oModelUJ2:LoadValue("UJ2_OK",		.T.)
						oModelUJ2:LoadValue("UJ2_PRODUT",	QRYPROD->PRODUTO)
						oModelUJ2:LoadValue("UJ2_DESC",		Alltrim(SB1->B1_DESC) )
						oModelUJ2:LoadValue("UJ2_PRCVEN",	QRYPROD->PRECO_VENDA)
						oModelUJ2:LoadValue("UJ2_QUANT",	nQtdItem)
						oModelUJ2:LoadValue("UJ2_SUBTOT",	nQtdItem * QRYPROD->PRECO_VENDA)
						oModelUJ2:LoadValue("UJ2_LOCAL",	SB1->B1_LOCPAD )

						////////////////////////////////////////////////////
						///////// VALIDO SALDO EM ESTOQUE DO PRODUTO //////
						///////////////////////////////////////////////////

						oModelUJ2:LoadValue("UJ2_ESTOQU",U_RFUNA34B(QRYPROD->PRODUTO,QRYPROD->QUANTIDADE))

						//se o item esta em carencia aplicado o desconto do mesmo
						If oModelUJ0:GetValue("UJ0_CARENC") == "S" .Or. ( !Empty(QRYPROD->CARENCIA) .And. dDataBase <= STOD(QRYPROD->CARENCIA) )

							nSubTotal 	:= nQtdItem * QRYPROD->PRECO_VENDA
							nVlrDes		:= nSubTotal * (oModelUJ0:GetValue("UJ0_PERCDE") / 100)

							oModelUJ2:LoadValue("UJ2_CARENC"	,	"BR_LARANJA")
							oModelUJ2:LoadValue("UJ2_PERDES"	,	oModelUJ0:GetValue("UJ0_PERCDE"))
							oModelUJ2:LoadValue("UJ2_VLRDES"	,	nVlrDes)
							oModelUJ2:LoadValue("UJ2_TOTAL"		,	nSubTotal - nVlrDes)

							lCarencia := .T.

						Else

							oModelUJ2:LoadValue("UJ2_CARENC"	,	"BR_VERDE")
							oModelUJ2:LoadValue("UJ2_TOTAL"		,	nQtdItem * QRYPROD->PRECO_VENDA)

						Endif

						oModelUJ2:LoadValue("UJ2_PV"		,	"S")
						oModelUJ2:LoadValue("UJ2_UNESTO"	,	xFilial("SCP") )

					endIf

				else

					Help( ,, 'Help - VldPlanE',, "Produto: " + Alltrim(QRYPROD->PRODUTO)+ " n„o encontrado, favor verifique o cadastro de produtos!", 1, 0 )

				endif

				QRYPROD->(DbSkip())

			EndDo

			//restauro a filial logada
			cFilAnt := cFilLogada

			//Valido se benecifiario esta preenchido e chamo rotina para validar carencia do beneficiario
			if  !Empty(oModelUJ0:GetValue("UJ0_CODBEN")) .AND. !IsInCallStack("U_ValidaBeneficiario")
				MsgRun("Verificando carÍncias do contrato...","Aguarde",{|| U_ValidaBeneficiario( oView, oModelUJ0:GetValue("UJ0_CODBEN"), lCarencia,.F. )})
			endif

		Endif

		//Atualiza o resumo
		If Type("oOSTotais") <> "U"
			oOSTotais:RefreshTot()
		EndIf

		oModelUJ2:GoLine(1)

		If Select("QRYPROD") > 0
			QRYPROD->(DbCloseArea())
		Endif

	endIf

	// caso o nao deva continuar dou o retorno como falso
	if !lContinua .And. !lSemPlanoE
		lRetorno := .F.
	endif

	//restauro a filial logada
	cFilAnt := cFilLogada

	RestArea(aArea)

	lVldLinUJ2 := .T.

Return(lRetorno)

/***********************/
User Function UJ0STATU()
/***********************/

	Local lRet 				:= .F.
	Local aArea				:= GetArea()
	Local lPossuiPv			:= .F.
	Local lPossuiPvA		:= .F.
	Local lGeraAssociado	:= .F.
	Local cFilLogada		:= cFilAnt

	//Altero a filial de acordo com a filial de servico
	if !Empty(UJ0->UJ0_FILSER)

		cFilAnt := UJ0->UJ0_FILSER

	endif

	//verifica se gera PV associado
	lGeraAssociado := SuperGetMv("MV_XGERASS",.F.,.F.,UJ0->UJ0_FILSER)

	DbSelectArea("SC5")

	SC5->(DbSetOrder(1)) //C5_FILIAL + C5_NUM

	//Verifica se o Pv gerado contra o cliente encontra-se faturado
	If !Empty(UJ0->UJ0_PV)

		lPossuiPv := .T.

		If SC5->(DbSeek(xFilial("SC5")+UJ0->UJ0_PV))

			If !Empty(SC5->C5_NOTA) .Or. SC5->C5_LIBEROK=='E' .And. Empty(SC5->C5_BLQ) //Faturado
				lRet := .T.
			Else
				lRet := .F.
			Endif

		Endif

	Endif

	if !lPossuiPv

		If !Empty(UJ0->UJ0_PV2)

			lPossuiPv := .T.

			If SC5->(DbSeek(xFilial("SC5")+UJ0->UJ0_PV2))

				If !Empty(SC5->C5_NOTA) .Or. SC5->C5_LIBEROK=='E' .And. Empty(SC5->C5_BLQ) //Faturado
					lRet := .T.
				Else
					lRet := .F.
				Endif

			Endif

		Endif

	endif

	//Verifica se o Pv gerado contra a adm. de planos encontra-se faturado
	If (lPossuiPv .And. lRet) .Or. !lPossuiPv

		If !Empty(UJ0->UJ0_PVADM)

			SC5->(DbSetOrder(1)) //C5_FILIAL + C5_NUM

			lPossuiPvA := .T.

			If SC5->(DbSeek(xFilial("SC5")+UJ0->UJ0_PVADM))

				If !Empty(SC5->C5_NOTA) .Or. SC5->C5_LIBEROK == 'E' .And. Empty(SC5->C5_BLQ) //Faturado
					lRet := .T.
				Else
					lRet := .F.
				Endif

			Endif

		Endif

	Endif

	//verifico se possui pedido gerado, caso nao possua verifico se possui dados de PV preenchido caso nao tenha, valido o
	//parametro MV_XGERASS para mostrar legenda como finalizado
	if !lPossuiPv .And. !lPossuiPvA .And. !lGeraAssociado .And. Empty(UJ0->UJ0_CLIPV)

		lRet := .T.

	endif

	//restaurar a filial logada
	cFilAnt := cFilLogada

	RestArea(aArea)

Return lRet

/**************************/
User Function FUNA034V(cTp)
/**************************/
	Local cFilLogada 	:= cFilAnt
	Local aPedidos		:= {}
	Local aOpcoes		:= {}
	Local nOpcaoSel		:= 1

	If UJ0->UJ0_TPSERV != '3'

		//altero a filial para a filial de servico
		if !Empty(UJ0->UJ0_FILSER)

			cFilAnt := UJ0->UJ0_FILSER

		endif

		If cTp == "C" //PV

			//------------------------------------------------------------------------
			// VERIFICO OS PEDIDOS DO APONTAMENTO, CASO TENHA GERADO MAIS DE 1,
			// O USUARIO DEVE SELECIONAR QUAL PEDIDO SERA VISUALIZADO
			//------------------------------------------------------------------------
			aPedidos := RetPedidosApontamento(UJ0->UJ0_CODIGO,UJ0->UJ0_CLIPV,UJ0->UJ0_LOJAPV)

			if Len(aPedidos) > 1

				aOpcoes := {aPedidos[1,1] + "( " + Alltrim( X3COMBO("C5_XCLASSI",aPedidos[1,2]) )   + " )",;
					aPedidos[2,1] + "( " + Alltrim( X3COMBO("C5_XCLASSI",aPedidos[2,2]) )   + " )"}

				nOpcaoSel := Aviso("AtenÁ„o!","O Apontamento possui 2 pedidos de vendas gerados, Qual pedido deseja visualizar?", aOpcoes, 1)

				if nOpcaoSel == 1
					MsgRun("Visualizando Pedido de Venda...","Aguarde",{|| VisPV(aPedidos[1,1])})
				else
					MsgRun("Visualizando Pedido de Venda...","Aguarde",{|| VisPV(aPedidos[2,1])})
				endif

			elseIf Len(aPedidos) > 0

				MsgRun("Visualizando Pedido de Venda...","Aguarde",{|| VisPV(aPedidos[1,1])})

			else
				if !Empty(UJ0->UJ0_PV)
					MsgRun("Visualizando Pedido de Venda...","Aguarde",{|| VisPV(UJ0->UJ0_PV)})
				elseIf !Empty(UJ0->UJ0_PV2)
					MsgRun("Visualizando Pedido de Venda...","Aguarde",{|| VisPV(UJ0->UJ0_PV2)})
				else
					MsgInfo("N„o h· Pedido de Venda contra o cliente gerado para o apontamento selecionado.","AtenÁ„o")
				endIf

			endif

		Else //PV adm
			MsgRun("Visualizando Pedido de Venda...","Aguarde",{|| VisPV(UJ0->UJ0_PVADM)})
		Endif

		//restauro a filial logada
		cFilAnt := cFilLogada

	else
		Msginfo("Servico em fase de Orcamento nao possui pedido !")
	Endif

Return

/*/{Protheus.doc} VisPv
funcao para visualizar o pedido de vendas
@type function
@version 1.0
@author g.sampaio
@since 21/06/2021
@param cPv, character, numero do pedido de vendas
/*/
Static Function VisPv(cPv)

	Local aArea		:= GetArea()
	Local aAreaSC5	:= SC5->(GetArea())

	If !Empty(cPv)
		U_UVirtusViewPV(cPv) // rotina gerenica para visualizacao do pedido de vendas
	Else
		MsgAlert("Pedido de Venda n„o gerado.")
	Endif

	RestArea(aAreaSC5)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} UPrepDocSaida
Funcao para Preparar Documento de Saida
da Nota Fiscal do Cliente
@author TOTVS
@since 14/04/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function UPrepDocSaida()

	Local cFilLogada	:= cFilAnt
	Local aArea			:= GetArea()
	Local aAreaUJ0		:= UJ0->(GetArea())
	Local aAreaUJ1		:= UJ1->(GetArea())
	Local aAreaUJ2		:= UJ2->(GetArea())
	Local aAreaSC5		:= SC5->(GetArea())
	Local aAreaSC6		:= SC6->(GetArea())
	Local lContinua		:= .T.

	SC5->(DbSetOrder(1))

	If UJ0->UJ0_TPSERV != '3'

		//altero a filial para a filial de servico
		if !Empty(UJ0->UJ0_FILSER)

			cFilAnt := UJ0->UJ0_FILSER

		endif

		if !Empty(UJ0->UJ0_PV) .And. !Empty(UJ0->UJ0_PV2)

			Aviso( "", "O Apontamento gerou 2 pedidos de vendas, ser· necess·rio gerar 2 documentos de saÌda, finalizando o primeiro È iniciado automaticamente o processo do segundo documento", {"Ok"} )

		elseif Empty(UJ0->UJ0_PV) .And. Empty(UJ0->UJ0_PV2)

			MsgAlert("Pedido de Venda n„o encontrado.")

			lContinua := .F.

		endif

		if lContinua

			if !Empty(UJ0->UJ0_PV) .And. SC5->(DbSeek(xFilial("SC5") + UJ0->UJ0_PV ))

				MsgInfo("Ser· gerado o documento de saÌda para o pedido do tipo: " + Alltrim( X3COMBO("C5_XCLASSI",SC5->C5_XCLASSI) )  + ", verifique a sÈrie que dever· ser utilizada")

				//Wizard de Preparacao de Doc de Saida
				Ma410PvNfs("SC5",SC5->(Recno()),3)

			endif

			if !Empty(UJ0->UJ0_PV2) .And. SC5->(DbSeek(xFilial("SC5") + UJ0->UJ0_PV2 ))

				MsgInfo("Ser· gerado o documento de saÌda para o pedido do tipo: " + Alltrim( X3COMBO("C5_XCLASSI",SC5->C5_XCLASSI) )  + ", verifique a sÈrie que dever· ser utilizada")

				//Wizard de Preparacao de Doc de Saida
				Ma410PvNfs("SC5",SC5->(Recno()),3)

			endif

		endif

		//restauro a filial logada
		cFilAnt := cFilLogada

	else
		Msginfo("Servico em fase de Orcamento nao pode ser faturado !")
	endif

	RestArea(aArea)
	RestArea(aAreaUJ0)
	RestArea(aAreaUJ1)
	RestArea(aAreaUJ2)
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)

Return(Nil)

/****************************/
User Function VldPrdTb(cProd)
/****************************/

	Local lRet 			:= .T.
	Local cQry			:= ""
	Local cArmazem		:= ""
	Local oModel		:= FWModelActive()
	Local oModelUJ0 	:= oModel:GetModel("UJ0MASTER")
	Local oModelUJ2 	:= oModel:GetModel("UJ2DETAIL")

	Local cPlanoC		:= oModelUJ0:GetValue("UJ0_PLANOC")
	Local cPlanoE		:= oModelUJ0:GetValue("UJ0_PLANOE")
	Local cCodTab		:= oModelUJ0:GetValue("UJ0_TABPRC")
	Local cFilServ		:= oModelUJ0:GetValue("UJ0_FILSER")
	Local cFilLogada	:= cFilAnt

	If !Empty(cFilServ) .And. !Empty(cProd)

		//altero a filial de acordo com a filial de servico
		cFilAnt := cFilServ

		//carrego o preco do produto de acordo com a filial de servico
		if !Empty(cPlanoC)

			cCodTab := Alltrim(SuperGetMv("MV_XTABSER",.F.,"001"))

		endif

		If Select("QRYTAB") > 0
			QRYTAB->(DbCloseArea())
		Endif

		cQry := "SELECT
		cQry += " DA1.DA1_PRCVEN AS PRECO_VENDA "
		cQry += " FROM
		cQry += RetSqlName("DA0")+" DA0
		cQry += " INNER JOIN "
		cQry += RetSqlName("DA1")+" DA1
		cQry += " ON DA0.DA0_CODTAB = DA1.DA1_CODTAB "
		cQry += " AND DA1.D_E_L_E_T_ = ' ' "
		cQry += " AND DA1.DA1_FILIAL 	= '"+xFilial("DA1")+"'"
		cQry += " AND DA1.DA1_CODPRO 	= '"+cProd+"'"
		cQry += " AND (DA1.DA1_DATVIG   <= '"+DtoS(dDataBase)+ "' OR DA1.DA1_DATVIG = '"+Dtos(Ctod("//"))+ "')"
		cQry += " WHERE DA0.D_E_L_E_T_ 	<> '*'"
		cQry += " AND DA0.DA0_FILIAL 	= '"+xFilial("DA0")+"'"
		cQry += " AND DA0.DA0_CODTAB 	= '"+cCodTab+"'"

		cQry := ChangeQuery(cQry)

		MpSysOpenQuery(cQry, "QRYTAB")

		If QRYTAB->(EOF())
			Help( ,, 'VLDPRODTB',, 'O produto '+cProd+' nao possui preÁo vigente na tabela de preco '+cCodTab+'.', 1, 0 )
			lRet := .F.
		else

			SB1->(DbSetOrder(1)) //B1_FILIAL + B1_PROD

			//posiciono se na SB1 pra pegar nome e armazem
			If SB1->(DbSeek(xFilial("SB1")+cProd))

				oModelUJ2:LoadValue("UJ2_OK"	,	.T.)
				oModelUJ2:LoadValue("UJ2_PRODUT",	cProd)
				oModelUJ2:LoadValue("UJ2_DESC"	,	SB1->B1_DESC)
				oModelUJ2:LoadValue("UJ2_PRCVEN",	QRYTAB->PRECO_VENDA)
				oModelUJ2:LoadValue("UJ2_QUANT"	,	1)
				oModelUJ2:LoadValue("UJ2_SUBTOT",	QRYTAB->PRECO_VENDA)
				oModelUJ2:LoadValue("UJ2_PV"	,	"S")
				oModelUJ2:LoadValue("UJ2_TOTAL",	QRYTAB->PRECO_VENDA)
				oModelUJ2:LoadValue("UJ2_LOCAL",	SB1->B1_LOCPAD )

				////////////////////////////////////////////////////
				///////// VALIDO SALDO EM ESTOQUE DO PRODUTO ///////
				///////////////////////////////////////////////////

				oModelUJ2:LoadValue("UJ2_ESTOQU",U_RFUNA34B(cProd,1))

			endif

			//Atualizo os totalizadores
			If Type("oOSTotais") <> "U"
				oOSTotais:RefreshTot()
			EndIf

		Endif

		//restauro a filial logada
		cFilAnt := cFilLogada

	else

		lRet := .F.
		Help( ,, 'VldProd',, 'Selecione a filial de serviÁo ou verifique o produto digitado', 1, 0 )

	Endif

Return lRet

/*/{Protheus.doc} VldTabPr
//Funcao para validar produto digitado
na GRID de Produtos Entregues
@author Totvs
@since 04/05/2019
@version 1.0
@return ${return}, ${return_description}
@param cCodTab, Codigo da Tabela de Preco
@type function
/*/
User Function VldTabPr(cCodTab)

	Local lRet 			:= .T.
	Local cQry			:= ""
	Local nI			:= 0
	Local oModel		:= FWModelActive()
	Local oModelUJ1 	:= oModel:GetModel("UJ1DETAIL")

	Local aSaveLines  	:= FWSaveRows()

	If !Empty(cCodTab)

		For nI := 1 To oModelUJ1:Length()

			// posiciono na linha atual
			oModelUJ1:Goline(nI)

			If !oModelUJ1:IsDeleted()

				If Select("QRYTAB") > 0
					QRYTAB->(DbCloseArea())
				Endif

				cQry := "SELECT DA1.DA1_PRCVEN"
				cQry += " FROM "+RetSqlName("DA0")+" DA0 INNER JOIN "+RetSqlName("DA1")+" DA1 ON DA0.DA0_CODTAB 	= DA1.DA1_CODTAB"
				cQry += " 																		AND DA1.D_E_L_E_T_ 	<> '*'"
				cQry += " 																		AND DA1.DA1_FILIAL 	= '"+xFilial("DA1")+"'"
				cQry += " 																		AND DA1.DA1_CODPRO 	= '"+oModelUJ1:GetValue("UJ1_PRODUT")+"'"
				cQry += " 																		AND (DA1.DA1_DATVIG <= '"+DtoS(dDataBase)+ "' OR DA1.DA1_DATVIG = '"+Dtos(Ctod("//"))+ "')"
				cQry += " WHERE DA0.D_E_L_E_T_ 	<> '*'"
				cQry += " AND DA0.DA0_FILIAL 	= '"+xFilial("DA0")+"'"
				cQry += " AND DA0.DA0_CODTAB 	= '"+cCodTab+"'"

				cQry := ChangeQuery(cQry)
				TcQuery cQry NEW Alias "QRYTAB"

				If QRYTAB->(EOF())
					Help( ,, 'VldTabPr',, 'O produto '+oModelUJ1:GetValue("UJ1_PRODUT")+' nao possui preÁo vigente na tabela de preco '+cCodTab+'.', 1, 0 )
					lRet := .F.
					Exit
				Endif
			Endif
		Next nI
	Endif

	oModelUJ1:Goline(1)

	If Select("QRYTAB") > 0
		QRYTAB->(DbCloseArea())
	Endif

	FWRestRows(aSaveLines)

Return lRet

/*/{Protheus.doc} DescUJ2
Funcao para validar o desconto digitado
para o item
@author TOTVS
@since 15/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function DescUJ2(cCampo)

	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUJ0		:= oModel:GetModel("UJ0MASTER")
	Local oModelUJ2		:= oModel:GetModel("UJ2DETAIL")
	Local lRet 			:= .T.
	Local nSubTotal		:= 0
	Local nVlrDes		:= 0
	Local nPercDes		:= 0

	If cCampo == "UJ2_PERDES"

		//nao permite atribuir desconto superior a 100 percento
		nValor		:= oModelUJ2:GetValue("UJ2_PERDES")

		if nValor <= 100

			nSubTotal 	:= oModelUJ2:GetValue("UJ2_QUANT") * oModelUJ2:GetValue("UJ2_PRCVEN")

			If nValor > 0
				nVlrDes	:= nSubTotal * (nValor / 100)
			Else
				nVlrDes := 0
			Endif

		else
			Help( ,, 'Desconto',,'N„o È possivel atribuir desconto superior a 100%, favor verifique o valor digitado!', 1, 0 )
			lRet := .F.

		endif

		oModelUJ2:LoadValue("UJ2_SUBTOT",	nSubTotal)
		oModelUJ2:LoadValue("UJ2_VLRDES",	nVlrDes)
		oModelUJ2:LoadValue("UJ2_TOTAL",	nSubTotal - nVlrDes)

	ElseIf cCampo == "UJ2_VLRDES"

		nValor		:= oModelUJ2:GetValue("UJ2_VLRDES")


		nSubTotal 	:= oModelUJ2:GetValue("UJ2_QUANT") * oModelUJ2:GetValue("UJ2_PRCVEN")

		//Valido se desconto È maior que valor do produto
		if nValor <= nSubTotal

			If nValor > 0
				nPercDes := (nValor / nSubTotal) * 100
			Else
				nPercDes := 0
			Endif

			oModelUJ2:LoadValue("UJ2_SUBTOT",	nSubTotal)
			oModelUJ2:LoadValue("UJ2_PERDES",	nPercDes)
			oModelUJ2:LoadValue("UJ2_TOTAL",	nSubTotal - nValor)
		else

			Help( ,, 'Desconto',,'N„o È possivel atribuir desconto superior ao valor do item,verifique o valor digitado!', 1, 0 )
			lRet := .F.

		endif
	Endif

	//atualizo os totalizadores
	If Type("oOSTotais") <> "U"
		oOSTotais:RefreshTot()
	EndIf

Return(lRet)

/*/{Protheus.doc} SomaQtdBeneficarios
Funcao para Retornar a Quantidade
de Beneficiarios nao falecidos do contrato
@author TOTVS
@since 15/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function SomaQtdBeneficarios(cContrato)

	Local aArea		:= GetArea()
	Local aAreaUJ1	:= UJ1->(GetArea())
	Local aAreaUJ2	:= UJ2->(GetArea())
	Local cQry 		:= ""
	Local nQtdBen	:= 0

	cQry := " SELECT "
	cQry += " COUNT(*) QUANTIDADE "
	cQry += " FROM "
	cQry += RetSQLName("UF4") + " "
	cQry += " WHERE  "
	cQry += " D_E_L_E_T_ = ' ' "
	cQry += " AND UF4_FILIAL = '" + xFilial("UF4")+ "' "
	cQry += " AND UF4_CODIGO = '" + cContrato+ "' "
	cQry += " AND UF4_FALECI = ' '  "

	if Select("QRYBEN") > 0
		QRYBEN->(DbCloseArea())
	endif

	TcQuery cQry NEW Alias "QRYBEN"

	nQtdBen := QRYBEN->QUANTIDADE

	RestArea(aArea)
	RestArea(aAreaUJ1)
	RestArea(aAreaUJ2)

Return(nQtdBen)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ CriaTotais ∫Autor ≥ Raphael Martins	 	∫Data≥ 03/05/2019 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ FunÁ„o que cria o Other Object de Totalizadores			  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Postumos			                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function CriaTotais(oPanel)

	oOSTotais := ObjResumoOS():New(oPanel)

	//atualizo o tototalizador de contratado
	oOSTotais:ContratadoRefresh()

	//atualizo o totalizador de entregue e desconto
	oOSTotais:RefreshTot()

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ ObjTotalizador ∫Autor≥Raphael Martins     ∫Data≥03/05/2019 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Classe do totalizador									  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Postumos			                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

	Class ObjResumoOS

		Data oVlrContratado
		Data oVlrEntregue
		Data oVlrDesconto
		Data oVlrReceber
		Data oSitFinanc

		Data nVlrContratado
		Data nVlrEntregue
		Data nVlrDesconto
		Data nVlrReceber
		Data cSitFinanc

		//Metodo Construtor da Classe
		Method New() Constructor

		//Metodo para Atualizar o Valor a Receber da OS
		Method RefreshTot()

		//Metodo para Atualizar o Total Contratado
		Method ContratadoRefresh()

	EndClass

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ New ∫ Autor ≥ Raphael Martins 	 	  ∫ Data ≥ 03/05/2019 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ MÈtodo construtor da classe ObjTotal						  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Postumos			                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Method New(oPanel) Class ObjResumoOS

	Local oPanelCpo		:= NIL
	Local oPanelCont	:= NIL
	Local oPanelEnt		:= NIL
	Local oPanelDesc	:= NIL
	Local oPanelRec		:= NIL
	Local oSay1			:= NIL
	Local oSay2			:= NIL
	Local oSay3			:= NIL
	Local oSay4			:= NIL
	Local oSay5			:= NIL
	Local oGroup1		:= NIL
	Local oModel 		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUJ0 	:= oModel:GetModel("UJ0MASTER")
	Local oFont12N	   	:= TFont():New("Verdana",,12,,.T.,,,,.T.,.F.,.T.) // Fonte 12 Negrito, It·lico
	Local oFont14N	   	:= TFont():New("Verdana",,14,,.T.,,,,.T.,.F.,.F.) // Fonte 14 Negrito
	Local oFont18N	   	:= TFont():New("Verdana",,18,,.T.,,,,.T.,.F.,.T.) // Fonte 28 Negrito
	Local oFontNum	   	:= TFont():New("Verdana",08,18,,.F.,,,,.T.,.F.) ///Fonte 14 Negrito
	Local oFontSit	   	:= TFont():New("Cooper Black",,13,,.F.,,,,.T.,.F.,.F.) // Fonte 24 Nornal
	Local nHeigth		:= oPanel:nClientHeight / 2
	Local nWhidth		:= oPanel:nClientWidth / 2
	Local nOperation 	:= oModel:GetOperation()
	Local nLin			:= 3
	Local nAltPnlFin	:= 30
	Local nClrPanes		:= 16777215
	Local nClrSay		:= 7303023
	Local nClrAdimp 	:= 41984
	Local nAltPanels	:= 0
	Local nClrSitFin	:= 12961221
	Local lAdimp		:= .F.
	Local nClrInadi		:= 987135

	// inicializo os novos totais zerados
	::nVlrContratado	:= 0
	::nVlrEntregue		:= 0
	::nVlrDesconto		:= 0
	::nVlrReceber		:= 0
	::cSitFinanc 		:= "INEXISTENTE"

	//Valido se OS È de contrato para validar situacao financeira
	If (FunName() == "RFUNA002" .Or. FunName() == "RUTIL025") .OR. (nOperation != 3 .AND. !Empty(oModelUJ0:GetValue("UJ0_CONTRA")))

		// funÁ„o que retorna a situaÁ„o financeira do contrato
		lAdimp := RetSitFin(UF2->UF2_CODIGO)

		if lAdimp
			::cSitFinanc 	:= "ADIMPLENTE"
			nClrSitFin		:= nClrAdimp
		else
			::cSitFinanc 	:= "PENDENTE"
			nClrSitFin		:= nClrInadi
		endif
	Endif


	//////////////////////////////////////////////////////////
	////////////////	PAINEL PRINCIPAL 	/////////////////
	/////////////////////////////////////////////////////////

	@ 002, 002 MSPANEL oPanelCpo SIZE nWhidth - 2 , nHeigth -2 OF oPanel COLORS 0, 12961221

	nAltPanels := INT(nHeigth - nLin - 5) / 5

	/////////////////////////////////////////////////////////////////
	////////////////	PANEL VALOR CONTRATADO		////////////////
	////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPanelCont SIZE nWhidth - 6 , nAltPanels OF oPanelCpo  COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay3 PROMPT "Valor Contratado" SIZE nWhidth - 6, 015 OF oPanelCont FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay4 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPanelCont FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 001 SAY oSay5 PROMPT "R$" SIZE 045, 010 OF oPanelCont FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 001 SAY ::oVlrContratado PROMPT AllTrim(Transform(::nVlrContratado,"@E 999,999.99")) SIZE 45, 010 OF oPanelCont FONT oFontNum COLORS 0, 16777215 PIXEL CENTER

	nLin += nAltPanels

	/////////////////////////////////////////////////////////////////
	////////////////	PANEL VALOR ENTREGUE		////////////////
	////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPanelEnt SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay3 PROMPT "Valor Entregue" SIZE nWhidth - 6, 015 OF oPanelEnt FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay4 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPanelEnt FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 001 SAY oSay5 PROMPT "R$" SIZE 045, 010 OF oPanelEnt FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 001 SAY ::oVlrEntregue PROMPT AllTrim(Transform(::nVlrEntregue,"@E 999,999.99")) SIZE 45, 010 OF oPanelEnt FONT oFontNum COLORS 0, 16777215 PIXEL CENTER

	nLin += nAltPanels

	/////////////////////////////////////////////////////////////////
	////////////////	PANEL VALOR DESCONTO		////////////////
	////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPanelDesc SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay3 PROMPT "Valor de Desconto" SIZE nWhidth - 6, 015 OF oPanelDesc FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay4 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPanelDesc FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 001 SAY oSay5 PROMPT "R$" SIZE 045, 010 OF oPanelDesc FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 001 SAY ::oVlrDesconto PROMPT AllTrim(Transform(::nVlrDesconto,"@E 999,999.99")) SIZE 45, 010 OF oPanelDesc FONT oFontNum COLORS 0, 16777215 PIXEL CENTER

	nLin += nAltPanels

	/////////////////////////////////////////////////////////////////
	////////////////	PANEL VALOR RECEBER			////////////////
	////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPanelRec SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED
	@ 000 , 000 SAY oSay3 PROMPT "Valor a Receber" SIZE nWhidth - 6, 015 OF oPanelRec FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay4 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPanelRec FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) - 5, 001 SAY oSay5 PROMPT "R$" SIZE 045, 010 OF oPanelRec FONT oFont18N COLORS 0, 16777215 PIXEL CENTER
	@ (nAltPanels / 2) + 5, 001 SAY ::oVlrReceber PROMPT AllTrim(Transform(::nVlrReceber,"@E 999,999.99")) SIZE 45, 010 OF oPanelRec FONT oFontNum COLORS 0, 16777215 PIXEL CENTER

	nLin += nAltPanels

	/////////////////////////////////////////////////////////////////
	////////////////	PANEL STATUS FINANCIERO		////////////////
	////////////////////////////////////////////////////////////////

	@ nLin , 002 MSPANEL oPanelRec SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrSitFin RAISED
	@ 000 , 000 SAY oSay3 PROMPT "SituaÁ„o Financeira" SIZE nWhidth - 6, 015 OF oPanelRec FONT oFont14N COLORS 16777215  PIXEL CENTER
	@ 010 , 001 SAY oSay4 PROMPT Replicate("- ",13) SIZE nWhidth - 6, 015 OF oPanelRec FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

	@ (nAltPanels / 2) + 5, 001 SAY ::oSitFinanc PROMPT ::cSitFinanc SIZE 45, 010 OF oPanelRec FONT oFontSit COLORS 16777215, nClrSitFin PIXEL CENTER

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ ContratadoRefresh ∫ Autor ≥ Raphael Martins 	 ≥ 03/05/2019 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ MÈtodo Refresh do Totais da Ordem de Servico				  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Postumos			                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Method ContratadoRefresh() Class ObjResumoOS

	Local _aSaveLines	:= FWSaveRows()
	Local nI			:= 0
	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUJ1 	:= oModel:GetModel("UJ1DETAIL")
	Local oModelUJ0 	:= oModel:GetModel("UJ0MASTER")

	/////////////////////////////////////////////////////
	//// CALCULO OS VALORES DOS PRODUTOS CONTRATADOS ///
	////////////////////////////////////////////////////
	For nI := 1 To oModelUJ1:Length()

		oModelUJ1:Goline(nI)

		if !oModelUJ1:IsDeleted()

			::nVlrContratado += oModelUJ1:GetValue("UJ1_TOTAL")

		Endif

	Next nI

	if oView:GetOperation() == 3

		//atualizo valor contratado no cabecalho da OS
		oModelUJ0:LoadValue("UJ0_VLRCON",::nVlrContratado)

	endif

	::oVlrContratado:Refresh()

	FWRestRows(_aSaveLines)

Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ RefreshEnt ∫ Autor ≥ Raphael Martins   ∫ Data ≥ 03/05/2019 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ MÈtodo Refresh do Totais da Ordem de Servico				  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Postumos			                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Method RefreshTot(cAcao,nLinha) Class ObjResumoOS

	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUJ0 	:= oModel:GetModel("UJ0MASTER")
	Local oModelUJ1 	:= oModel:GetModel("UJ1DETAIL")
	Local oModelUJ2 	:= oModel:GetModel("UJ2DETAIL")
	Local nLinhaAtual	:= oModelUJ2:GetLine()
	Local cCarencia		:= oModelUJ0:GetValue("UJ0_CARENC")
	Local nAux 			:= 0
	Local nI			:= 0

	Default cAcao		:= ""
	Default nLinha		:= 1

	::nVlrEntregue	:= 0
	::nVlrDesconto	:= 0
	::nVlrReceber	:= 0

	For nI := 1 To oModelUJ2:Length()

		oModelUJ2:Goline(nI)

		//valido se esta deletando a linha
		If cAcao == "DELETE" .And. nI == nLinha

			Loop

		elseIf !oModelUJ2:IsDeleted() .And. oModelUJ2:GetValue("UJ2_OK")

			::nVlrEntregue	+= oModelUJ2:GetValue("UJ2_SUBTOT")
			::nVlrDesconto	+= oModelUJ2:GetValue("UJ2_VLRDES")
			::nVlrReceber	+= oModelUJ2:GetValue("UJ2_TOTAL")

		Endif

	Next nI

	if ::nVlrReceber < 0

		::nVlrReceber := 0

	endif

	//atualizo totalizadores
	::oVlrEntregue:Refresh()
	::oVlrDesconto:Refresh()
	::oVlrReceber:Refresh()

	//atualizo valores no cabecalho da OS

	//nao atualizo os campos quando for chamado na criacao da tela
	if !IsInCallStack("U_CriaTotais")

		oModelUJ0:LoadValue("UJ0_VLRENT",::nVlrEntregue)
		oModelUJ0:LoadValue("UJ0_VLRDES",::nVlrDesconto)
		oModelUJ0:LoadValue("UJ0_VLRREC",::nVlrReceber)

	endif

	oModelUJ2:GoLine(nLinhaAtual)

Return(Nil)

/*/{Protheus.doc} ValidaBeneficiario
Funcao para validar a carencia do beneficiario informado
@type function
@version 1.0  
@author Leandro Rodrigues
@since 13/05/2019
@param oView, object, objeto da view
@param xValue, variant, valor indefinido
@param lCarencia, logical, indica se o contrato se em carencia
@param lLoadPlano, logical, indica se o carrega itens do plano 
@return logical, retorno logico da validacao
/*/
User Function ValidaBeneficiario(oView,xValue,lCarencia,lLoadPlano)

	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUJ0		:= oModel:GetModel("UJ0MASTER")
	Local oModelUJ2		:= oModel:GetModel("UJ2DETAIL")
	Local aAreaUJ1		:= UJ1->(GetArea())
	Local aAreaUF2		:= UF2->(GetArea())
	Local aAreaUF4		:= UF4->(GetArea())
	Local cPlanoC		:= oModelUJ0:GetValue("UJ0_PLANOC")
	Local cPlanoE		:= oModelUJ0:GetValue("UJ0_PLANOE")
	Local lCarCustom	:= .T. //validacao de carencia customizada pelo ponto de entrada PFUN34CR
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local lConsCarCust	:= SuperGetMV("MV_XCOCCUS", .F., .F.) // Considera Carencia Customizada
	Local lContinua		:= .T.
	Local nVlrDes		:= 0
	Local nSubTotal		:= 0
	Local nPercDes		:= 0
	Local nDescItem     := 0
	Local nPercDesc		:= 0
	Local nI			:= 1
	Local nRetorno		:= 0

	Default lCarencia	:= .F.
	Default lLoadPlano	:= .T.

	Conout("Passou na ValidaBeneficiario")

	// plano pet ativo
	if lPlanoPet

		if oModelUJ0:GetValue("UJ0_USO") == "3" // para pet nao valido o beneficiario

			lContinua	:= .F.

			// nao existe carencia para apontamento pet ate o momento
			oModelUJ0:LoadValue("UJ0_CARENC","N")

			nPercDes := 100

			//chamada funcao carregar a grid novamente se plano estiver preenchido
			if !Empty(cPlanoE)

				U_VldPlanE()

				//Valor que sera descontado com ou sem carencia
				If Type("oOSTotais") <> "U"
					nVlrDes := ROUND(oOSTotais:nVlrContratado * (nPercDes/100),TamSx3("UJ2_VLRDES")[2])
				Else
					nVlrDes := UJ1CalculaValorContratado()
				EndIf

				For nI := 1 to oModelUJ2:Length()

					UF3->(DbSetOrder(2)) //UF3_FILIAL + UF3_CODIGO + UF3_PROD

					oModelUJ2:Goline(nI)

					if !oModelUJ2:IsDeleted() .AND. oModelUJ2:GetValue("UJ2_OK")

						//se o contrato nao estiver em carencia, mas o item estiver, nao entra para o rateio de desconto
						if cPlanoC == cPlanoE .And. nPercDes == 0 .And. oModelUJ2:GetValue("UJ2_PERDES") > 0

							Loop

						endif

						//Calcula valor do desconto
						nSubTotal	:= oModelUJ2:GetValue("UJ2_SUBTOT")

						//Valor do desconto da OS
						if nVlrDes > 0

							//Valido se o saldo o item È menor que o saldo a aplicar de desconto
							if nSubTotal <= nVlrDes

								//Diminui saldo que ainda precisa ser aplicado
								nVlrDes 	-= nSubTotal
								nDescItem	:= nSubTotal
								nSubTotal 	:= 0

							else

								nSubTotal := nSubTotal - nVlrDes
								nDescItem := nVlrDes
								nVlrDes   := 0

							Endif

							//Calculo o percentual de desconto
							nPercDesc	:= Round((nDescItem / oModelUJ2:GetValue("UJ2_SUBTOT")) * 100,TamSx3("UJ2_PERDES")[2] )

						Else
							nPercDesc := 0
							nDescItem := 0
						Endif

						oModelUJ2:LoadValue("UJ2_PERDES",	nPercDesc			)
						oModelUJ2:LoadValue("UJ2_VLRDES",	nDescItem			)
						oModelUJ2:LoadValue("UJ2_TOTAL",	nSubTotal 			)

					endif

				Next nI

				//atualiza totalizadores
				If Type("oOSTotais") <> "U"
					oOSTotais:RefreshTot()
				EndIf

				//Retorno para primeira linha
				oModelUJ2:Goline(1)

			endif

		endIf

	endIf

	if lContinua

		UF4->(DbSetOrder(1))
		UF3->(DbSetOrder(2))

		//Posiciono no beneficiario do contrato
		if UF4->(DbSeek(xFilial("UF2")+oModelUJ0:GetValue("UJ0_CONTRA")+xValue))

			//Ponto de entrada que indica se dever· ou nao cobrar carencia do cliente
			If ExistBlock("PFUN34CR")

				Conout(" >> Usa PE PFUN34CR")

				lCarCustom := ExecBlock("PFUN34CR",.F.,.F.,{oModelUJ0:GetValue("UJ0_CARENC")})

			endif

			//-------------------------------------------------------
			// RETORNOS DA FUNCAO VldQuantParcelas
			//0 = Nao possui carencia por Quantidade de Parcelas
			//1 = Possui Regra e esta na Carencia
			//2 = Possui Regra e nao esta na Carencia
			//-------------------------------------------------------
			nRetorno := VldQuantParcelas()

			if  nRetorno <> 0

				if nRetorno == 1
					lCarencia := .T.
				else
					lCarencia := .F.
				endif

				//valido se beneficiario ainda esta em carencia
			elseif UF4->UF4_CAREN > dDatabase
				lCarencia := .T.
			else
				lCarencia := .F.
			endif

			if (lCarencia .And. lCarCustom) .Or. (lCarCustom .And. lConsCarCust)

				oModelUJ0:LoadValue("UJ0_CARENC","S")

				//Busco percentual de desconto
				nPercDes := oModelUJ0:GetValue("UJ0_PERCDE")

			else

				oModelUJ0:LoadValue("UJ0_CARENC","N")

				//Nao esta em carencia, aplica 100% de desconto
				nPercDes := 100

				If Type("oOSTotais") <> "U"
					nVlrDes := oOSTotais:nVlrContratado
				Else
					nVlrDes := UJ1CalculaValorContratado()
				EndIf

			endif

			//valido se carrego os dados do plano
			if lLoadPlano
				U_VldPlanE()
			else

				//Se a chamada for via botao Recalcula Iten, devo consultar itens em carencia para debitar do saldo a ser desconto.
				//caso o chamada for de outra origem, o processo e realizado pela funcao VldPlanE.
				if !lCarencia .And. !lCarCustom

					nVlrDes := BuscaItensCarencia(oModelUJ0:GetValue("UJ0_CONTRA"),oModelUJ0:GetValue("UJ0_PERCDE"))

				endif

			endif

			For nI := 1 to oModelUJ2:Length()

				UF3->(DbSetOrder(2)) //UF3_FILIAL + UF3_CODIGO + UF3_PROD

				oModelUJ2:Goline(nI)

				if !oModelUJ2:IsDeleted() .AND. oModelUJ2:GetValue("UJ2_OK")

					//se o contrato nao estiver em carencia, mas o item estiver, nao entra para o rateio de desconto
					if !Empty(cPlanoE) .And. cPlanoC == cPlanoE .And. nPercDes == 0 .And. oModelUJ2:GetValue("UJ2_PERDES") > 0

						Loop

					endif

					//verifico se o produto esta na carencia, caso o produto seja personalizado e se encontra na carencia, nao entra para o calculo do rateio.
					if !(lCarencia .And. lCarCustom) .Or. Alltrim(oModelUJ2:GetValue("UJ2_CARENC")) <> "BR_LARANJA"

						//Calcula valor do desconto
						nSubTotal	:= oModelUJ2:GetValue("UJ2_SUBTOT")

						//Valor do desconto da OS
						if nVlrDes > 0

							//Valido se o saldo o item È menor que o saldo a aplicar de desconto
							if nSubTotal <= nVlrDes

								//Diminui saldo que ainda precisa ser aplicado
								nVlrDes 	-= nSubTotal
								nDescItem	:= nSubTotal
								nSubTotal 	:= 0

							else

								nSubTotal := nSubTotal - nVlrDes
								nDescItem := nVlrDes
								nVlrDes   := 0

							Endif

							//Calculo o percentual de desconto
							nPercDesc	:= Round((nDescItem / oModelUJ2:GetValue("UJ2_SUBTOT")) * 100,TamSx3("UJ2_PERDES")[2] )

						Else

							nPercDesc := 0
							nDescItem := 0
						Endif

						oModelUJ2:LoadValue("UJ2_PERDES",	nPercDesc			)
						oModelUJ2:LoadValue("UJ2_VLRDES",	nDescItem			)
						oModelUJ2:LoadValue("UJ2_TOTAL",	nSubTotal 			)

					endif

				endIf

			Next nI

			//atualiza totalizadores
			If Type("oOSTotais") <> "U"
				oOSTotais:RefreshTot()
			EndIf

			//Retorno para primeira linha
			oModelUJ2:Goline(1)

		endif

	endIf

	//Retorno para primeira linha
	oModelUJ2:Goline(1)

	If Type("oView") <> "U"
		oView:Refresh("UJ2DETAIL")
	EndIf

	//Restaura area ativa
	RestArea(aAreaUJ1)
	RestArea(aAreaUF2)
	RestArea(aAreaUF4)

Return(.T.)

/*/{Protheus.doc} FUNA034H
//Rotina de Geracao de Requisicao ao Armazem
@author Raphael Martins
@since 04/06/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function FUNA034H(cApontamento,cContrato,cSexo)

	Local aEnvSlc		:= {}
	Local aArea			:= GetArea()
	Local aAreaUJ0		:= UJ0->(GetArea())
	Local aAreaUJ2		:= UJ2->(GetArea())
	Local aAreaSCP		:= SCP->(GetArea())
	Local cTipoProd		:= ""
	Local cFilLogada	:= cFilAnt
	Local lRet			:= .T.

	If !FWIsInCallStack("U_RFUNE052") .And. UJ0->UJ0_TPSERV != '3'

		//verifico se ja possui solicitacao ao armazem
		if U_VerReqArmazem(cApontamento)

			lRet := .F.
			Help( ,, 'EXISTE',, 'O Apontamento Selecionado j· possui solicitaÁ„o ao Armazem!', 1, 0 )

		elseif MsgYesNo("Deseja Gerar SolicitaÁ„o Armazem para o Apontamento?")

			//////////////////////////////////////////////////////
			/////// REALIZO SOLICITACAO AO ARMAZEM 		/////////
			/////////////////////////////////////////////////////

			UJ2->(DbSetOrder(1)) //UJ2_FILIAL+UJ2_CODIGO+UJ2_ITEM

			If UJ2->(DbSeek(xFilial("UJ2") + cApontamento))

				While UJ2->(!EOF()) .And. xFilial("UJ2") == UJ2->UJ2_FILIAL .And. UJ2->UJ2_CODIGO == cApontamento

					cTipoProd := RetField("SB1",1,xFilial("SB1") + UJ2->UJ2_PRODUT,"B1_TIPO")

					If UJ2->UJ2_OK .And. !Empty(UJ2->UJ2_UNESTO) .And. cTipoProd <> 'SV'

						AAdd(aEnvSlc,{UJ2->UJ2_UNESTO,UJ2->UJ2_LOCAL,UJ2->UJ2_PRODUT,UJ2->UJ2_QUANT,UJ2->UJ2_ITEM})

					Endif

					UJ2->(DbSkip())

				EndDo

			Endif

			If Len(aEnvSlc) > 0

				//Ordena os dados de envio por filial
				aSort(aEnvSlc,,,{|x,y| x[1] < y[1]})

				//Inclui Solicitacao ao Armazen
				FWMsgRun(,{|oSay| U_USolicitaArmazem(oSay,aEnvSlc,cApontamento,cContrato,cSexo)},'Aguarde','Realizando SolicitaÁ„o ao Armazem...')

			else

				Help( ,, 'EXISTE',, 'N„o existem itens aptos para gerar a requisiÁ„o armazÈm, verifique o cadastro de produtos e veja se o tipo est· diferente de "SV"(ServiÁo)!', 1, 0 )

			Endif

		endif

		//restauro a filial logada
		cFilAnt := cFilLogada

	else
		MsgInfo("OperaÁ„o nao È permitida para Servicos em fase de orcamento")
	Endif

	RestArea(aArea)
	RestArea(aAreaUJ0)
	RestArea(aAreaUJ2)
	RestArea(aAreaSCP)

Return(Nil)

/*/{Protheus.doc} FUNA034I
//Rotina de Geracao de Requisicao ao Armazem
@author Raphael Martins
@since 04/06/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function FUNA034I(cApontamento)

	Local lRet 			:= .F.
	Local cFilLogada	:= cFilAnt


	if UJ0->UJ0_TPSERV != '3'

		FWMsgRun(,{|oSay| lRet := RequisicaoExclui(cApontamento)},'Aguarde','Realizando a Exclus„o da SolicitaÁ„o ao Armazem...')

		//restauro a filial logada
		cFilAnt := cFilLogada

	else
		MsgInfo("OperaÁ„o nao È permitida para Servicos em fase de orcamento")
	Endif

Return(lRet)

/*/{Protheus.doc} RequisicaoExclui
//Rotina de Geracao de Requisicao ao Armazem
@author Raphael Martins
@since 04/06/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function RequisicaoExclui(cApontamento)

	Local aArea			:= GetArea()
	Local aAreaUJ0		:= UJ0->(GetArea())
	Local aAreaUJ2		:= UJ2->(GetArea())
	Local aAreaSCP		:= SCP->(GetArea())
	Local aDadosCabec	:= {}
	Local aDadosProd	:= {}
	Local aProdutos		:= {}
	Local cQry			:= ""
	Local cFilLogada	:= cFilAnt
	Local lRet			:= .T.
	Local nParamBkp		:= 0

	Private lMsErroAuto := .F.

	cQry := " SELECT "
	cQry += " MIN(CP_ITEM) 	AS ITEM, "
	cQry += " CP_NUM		AS REQUISICAO, "
	cQry += " CP_FILIAL 	AS FILIAL_REQ
	cQry += " FROM "
	cQry += RetSQLName("UJ2") + " UJ2 "
	cQry += " INNER JOIN "
	cQry += RetSQLName("SCP") + " SCP "
	cQry += " ON UJ2.D_E_L_E_T_ =  ' '  "
	cQry += " AND SCP.D_E_L_E_T_ = ' '  "
	cQry += " AND UJ2.UJ2_UNESTO = SCP.CP_FILIAL "
	cQry += " AND UJ2.UJ2_CODIGO = SCP.CP_XAPONT "
	cQry += " AND UJ2.UJ2_PRODUT = SCP.CP_PRODUTO "
	cQry += " WHERE "
	cQry += " UJ2_FILIAL = '" + xFilial("UJ2") + "' "
	cQry += " AND UJ2_CODIGO 	= '" + cApontamento + "' "
	cQry += " GROUP BY CP_NUM,CP_FILIAL "

	if Select("QRYSCP") > 0
		QRYSCP->(DbCloseArea())
	endif

	TcQuery cQry NEW Alias "QRYSCP"

	if QRYSCP->(!Eof())

		Begin Transaction

			While QRYSCP->(!Eof())

				//retorna o codigo da Filial contendo todos os niveis (Empresa / Unidade de NegÛcio / Filial)
				cFilAnt := FWArrFilAtu( cEmpAnt , QRYSCP->FILIAL_REQ)[2]

				SCP->(DbSetOrder(1)) //CP_FILIAL + CP_NUM + CP_ITEM

				if SCP->(DbSeek(QRYSCP->FILIAL_REQ + QRYSCP->REQUISICAO + QRYSCP->ITEM ))

					aDadosCabec := {}
					aDadosProd	:= {}
					aProdutos	:= {}

					lMsErroAuto := .F.

					Aadd(aDadosCabec,{"CP_NUM"			, QRYSCP->REQUISICAO	,Nil})

					AAdd(aDadosProd,{"CP_ITEM"			, QRYSCP->ITEM			,Nil})

					AAdd(aProdutos,aDadosProd)

					// Carrega o grupo de perguntas
					Pergunte("MTA105", .F.)
					if MV_PAR02 == 1 // se exclusao por item
						nParamBkp := MV_PAR02
						SetMVValue("MTA105","MV_PAR02", 2) // altero para exclusao por Documento
					endIf

					MsExecAuto({ | x, y, z | Mata105( x, y, z ) }, aDadosCabec, aProdutos, 5)

					if lMsErroAuto

						MostraErro()
						DisarmTransaction()

						lRet := .F.

						Exit

					endif

					if lRet .And. nParamBkp > 0
						SetMVValue("MTA105","MV_PAR02", nParamBkp) // altero o parametro com o documento
					endIf
				else

					MsgAlert("N„o existe requisiÁ„o para o apontamento selecionado!")

					DisarmTransaction()

					lRet := .F.

				endif

				QRYSCP->(DbSkip())

			EndDo

		End Transaction

		//valido se a requisicao foi excluida com sucesso
		if lRet

			MsgInfo("SolicitaÁ„o(ıes) ExcluÌda(s) com sucesso!","AtenÁ„o")

		endif

	else
		Help( ,, 'NAOSOLI',, 'N„o existe requisiÁ„o para o apontamento selecionado!', 1, 0 )
	endif

	cFilAnt := cFilLogada

	RestArea(aArea)
	RestArea(aAreaUJ0)
	RestArea(aAreaUJ2)
	RestArea(aAreaSCP)

Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ RetSitFin ∫ Autor≥ Wellington GonÁalves ∫ Data≥ 09/04/2019 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ FunÁ„o que consulta os tÌtulos em aberto do contrato		  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Postumos			                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function RetSitFin(cContrato)

	Local lRet 			:= .T.
	Local cPulaLinha	:= chr(13)+chr(10)
	Local cQry			:= ""

	// verifico se nao existe este alias criado
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	EndIf

	cQry := " SELECT " 												+ cPulaLinha
	cQry += " SE1.E1_NUM " 											+ cPulaLinha
	cQry += " FROM " 												+ cPulaLinha
	cQry += " " + RetSqlName("SE1") + " SE1 "						+ cPulaLinha
	cQry += " WHERE " 												+ cPulaLinha
	cQry += " SE1.D_E_L_E_T_	<> '*' " 							+ cPulaLinha
	cQry += " AND SE1.E1_FILIAL 	= '" + xFilial("SE1") + "' " 	+ cPulaLinha
	cQry += " AND SE1.E1_XCTRFUN	= '" + cContrato + "' "			+ cPulaLinha
	cQry += " AND SE1.E1_SALDO		> 0 "							+ cPulaLinha
	cQry += " AND SE1.E1_VENCREA	< '" + DTOS(dDataBase) + "' "	+ cPulaLinha
	cQry += " AND SE1.E1_TIPO NOT IN ('AB-','FB-','FC-','FU-' " 	+ cPulaLinha
	cQry += " ,'PR','IR-','IN-','IS-','PI-','CF-','CS-','FE-' "		+ cPulaLinha
	cQry += " ,'IV-','RA','NCC','NDC') "							+ cPulaLinha

	// funcao que converte a query generica para o protheus
	cQry := ChangeQuery(cQry)

	// crio o alias temporario
	TcQuery cQry New Alias "QRYSE1" // Cria uma nova area com o resultado do query

	if QRYSE1->(!Eof())
		lRet := .F.
	endif

	// verifico se nao existe este alias criado
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	EndIf

Return(lRet)

/*/{Protheus.doc} ValidaData
//Valida data informada nos campo
@author Leandro Rodrigues
@since 04/06/2019
@version 1.0
@return .T. ou .F.
@param 
@type function
/*/

User Function ValidaData()

	Local oModel		:= FWModelActive()
	Local oModelUJ0		:= oModel:GetModel("UJ0MASTER")
	Local dDataIniVel	:= oModelUJ0:GetValue("UJ0_DTINIV")
	Local dDataFimVel	:= oModelUJ0:GetValue("UJ0_DTFIMV")
	Local dDataCort		:= oModelUJ0:GetValue("UJ0_DTCORT")
	Local dDtSepul		:= oModelUJ0:GetValue("UJ0_DTSEPU")
	Local lRet   		:= .T.

	If !Empty(dDataIniVel) .AND. dDataIniVel < dDataBase

		lRet := .F.
		Help( ,, 'Help - ValidaData',, 'Data de Inicio do Velorio nao pode ser menor que a data da OS!', 1, 0 )

	Elseif !Empty(dDataFimVel) .AND. dDataFimVel < dDataBase

		lRet := .F.
		Help( ,, 'Help - ValidaData',, 'Data fim do Velorio nao pode ser menor que a data da OS!', 1, 0 )

	Elseif !Empty(dDataCort) .AND. dDataCort < dDataBase

		lRet := .F.
		Help( ,, 'Help - ValidaData',, 'Data do Cortejo nao pode ser menor que a data da OS!', 1, 0 )

	Elseif !Empty(dDtSepul) .AND. dDtSepul < dDataBase

		lRet := .F.
		Help( ,, 'Help - ValidaData',, 'Data do Velorio nao pode ser menor que a data da OS!', 1, 0 )

	Endif

Return lRet

/*/{Protheus.doc} UFilServValida
//Funcao para validar a filial de servico
digitada
@author Raphael Martins 
@since 04/06/2019
@version 1.0
@return .T. ou .F.
@param 
@type function
/*/

User Function UFilServValida()

	Local aArea 		:= GetArea()
	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUJ0		:= oModel:GetModel("UJ0MASTER")
	Local oModelUJ2		:= oModel:GetModel("UJ2DETAIL")
	Local cFilServico	:= oModelUJ0:GetValue("UJ0_FILSER")
	Local lRet			:= .T.
	Local nLinhasUJ2	:= oModelUJ2:Length()
	Local nLinhaPos		:= oModelUJ2:nLine
	Local nX			:= 0

	if ExistCpo('SM0',cEmpAnt + cFilServico,1)

		For nX := 1 To nLinhasUJ2

			oModelUJ2:Goline(nX)

			oModelUJ2:LoadValue("UJ2_UNESTO",cFilServico)

		Next nX

	else

		lRet := .F.

	endif

	oView:Refresh("UJ2DETAIL")

	//restauro a linha posicionada
	oModelUJ2:Goline(nLinhaPos)

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} FUNA034J
funcao para retornar a descricao do plano
na rotina de apontamento de servicos mod2
@type function
@version 
@author g.sampaio
@since 21/04/2020
@param cPlano, character, codigo do plano
@return character, descricao do plano
/*/
User Function FUNA034J( cPlano, cFilApt )

	Local aArea 	:= GetArea()
	Local aAreaUF0	:= UF0->( GetArea() )
	Local cRetorno	:= ""
	Local cFilBkp	:= ""

	Default cPlano	:= ""
	Default cFilApt	:= ""

	// verifico se nao esta preenchido
	If !Empty(cFilApt)

		// faco o bakcup da filial cfilant
		cFilBkp	:= cFilAnt

		// coloco a filial corrente na filial do apontamento
		cFilAnt := cFilApt

	EndIf

	// posicao no cadastro de planos
	UF0->( DbSetOrder(1) )
	If UF0->( MsSeek( xFilial("UF0")+cPlano ) )
		cRetorno := UF0->UF0_DESCRI // descricao do plano
	EndIf

	// verifico se nao esta preenchido
	If !Empty(cFilApt)

		// restauto a filial do backup
		cFilAnt := cFilBkp

	EndIf

	RestArea( aAreaUF0 )
	RestArea( aArea )

Return( cRetorno )

/*/{Protheus.doc} FUNA034K
funcao para o modo de edicao do campo 'UJ0_TPSERV'
Valida se tem contrato preenchido para nao deixar 
alterar o coneteudo do campo, pois o conteudo deve
ser sempre '1=Associado' para apontamento com contrato
@type function
@version 
@author g.sampaio
@since 04/05/2020
@return logio, retorna se pode editar o campo ou nao
/*/
User Function FUNA034K()

	Local aArea 		:= GetArea()
	Local cCodigoCtr	:= ""
	Local lRetorno		:= .T.
	Local oModel		:= FWModelActive()
	Local oModelUJ0		:= oModel:GetModel("UJ0MASTER")

	// preencho a variavel com o codigo do contrato
	cCodigoCtr	:= oModelUJ0:GetValue("UJ0_CONTRA")

	// valido se o contrato esta preenchido
	If lRetorno .And. !Empty( cCodigoCtr )
		lRetorno := .F.
	EndIf

	// verifico se estou incluindo um orcamento
	If lRetorno .And. IsInCallStack("U_RFUNE035")
		lRetorno := .F.
	EndIf

	RestArea( aArea )

Return(lRetorno)

/*/{Protheus.doc} FUNA034M
Validacao do campo UJ0_TPSERV
@type function
@version 
@author g.sampaio
@since 04/05/2020
@return logico, retorno se o conteudo do campo È v·lido
/*/
User Function FUNA034M()

	Local aArea 		:= GetArea()
	Local cCodigoCtr	:= ""
	Local cTipoServ		:= ""
	Local cCarencia		:= ""
	Local lCarencia		:= .F.
	Local lRetorno		:= .T.
	Local nPercCaren	:= 0
	Local oModel		:= FWModelActive()
	Local oModelUJ0		:= oModel:GetModel("UJ0MASTER")

	// preencho a variavel com o codigo do contrato
	cCodigoCtr	:= oModelUJ0:GetValue("UJ0_CONTRA")

	// preencho a variavel com o tipo de servico
	cTipoServ	:= oModelUJ0:GetValue("UJ0_TPSERV")

	// preencho as variaveis de carencia
	cCarencia	:= oModelUJ0:GetValue("UJ0_CARENC")
	nPercCaren	:= oModelUJ0:GetValue("UJ0_PERCDE")

	// verifico se tem carencia
	lCarencia			:= IIF(cCarencia == "S" .And. nPercCaren > 0,.T.,.F.)

	// valido se tem contato e foi preenchido o tipo 1=Associado
	If lRetorno .And. Empty( AllTrim( cCodigoCtr ) ) .And. cTipoServ == "1"

		// retorno falto para o campo
		lRetorno := .F.

		// mensagem para o usuario
		Help(,,'Help',,"Para apontamento sem vinculo com contrato, o campo '<b>Tipo ServiÁo</b>'";
			+ " n„o pode ser preenchido com o conte˙do '<b>1=Associado</b>'" ,1,0)

	EndIf

	// valido se tem contato e foi preenchido o tipo 1=Associado
	If lRetorno .And. Empty( AllTrim( cCodigoCtr ) ) .And. cTipoServ == "3" .And. !IsInCallStack("U_RFUNE035")

		// retorno falto para o campo
		lRetorno := .F.

		// mensagem para o usuario
		Help(,,'Help',,"Para apontamento sem vinculo com contrato, o campo '<b>Tipo ServiÁo</b>'";
			+ " n„o pode ser preenchido com o conte˙do '<b>3=OrÁamento</b>'" ,1,0)

	EndIf

	// valido se tem contato e foi preenchido o tipo 1=Associado
	If lRetorno .And. Empty( AllTrim( cCodigoCtr ) ) .And. cTipoServ $ "4/5" .And. lCarencia

		// retorno falto para o campo
		lRetorno := .F.

		// mensagem para o usuario
		Help(,,'Help',,"Para apontamento com carencia de contrato, o campo '<b>Tipo ServiÁo</b>'";
			+ " n„o pode ser preenchido com o conte˙do '<b>4=Indigente</b>' ou '<b>5=Carente</b>'" ,1,0)

	EndIf

	RestArea( aArea )

Return(lRetorno)

/*/{Protheus.doc} VldQuantParcelas
Funcao para validar se o contrato possui carencia por 
quantidade de parcelas pagas
@type function
@version 
@author Raphael Martins 
@since 09/06/2020
@return nRetorno, Numerico, 
0 = Nao possui carencia por Quantidade de Parcelas
1 = Possui Regra e esta na Carencia
2 = Possui Regra e nao esta na Carencia
/*/
Static Function VldQuantParcelas()

	Local aArea 		:= GetArea()
	Local aAreaUJ0		:= UJ0->(GetArea())
	Local oModel		:= FWModelActive()
	Local oModelUJ0		:= oModel:GetModel("UJ0MASTER")
	Local cRegra		:= oModelUJ0:GetValue("UJ0_REGRA")
	Local cContrato		:= oModelUJ0:GetValue("UJ0_CONTRA")
	Local cQry 			:= ""
	Local nRetorno 		:= 0

	UF2->(DbSetOrder(1)) //UF2_FILIAL + UF2_CODIGO

	//valido se possui regra por quantidade de parcelas
	if !Empty(cRegra)

		cQry += " SELECT "
		cQry += " UJ8_TEMPO QTD_PARCELAS "
		cQry += " FROM "
		cQry += RetSQLName("UJ8") + " UJ8 "
		cQry += " WHERE D_E_L_E_T_ = ' '
		cQry += " AND UJ8_FILIAL = '" + xFilial("UJ8") + "' "
		cQry += " AND UJ8_CODIGO = '" + cRegra + "'
		cQry += " AND UJ8_PARA = 'A'

		// verifico se nao existe este alias criado
		If Select("QRYUJ8") > 0
			QRYUJ8->(DbCloseArea())
		EndIf

		// funcao que converte a query generica para o protheus
		cQry := ChangeQuery(cQry)

		// crio o alias temporario
		TcQuery cQry New Alias "QRYUJ8"

		//-------------------------------------------------------
		//0 = Nao possui carencia por Quantidade de Parcelas
		//1 = Possui Regra e esta na Carencia
		//2 = Possui Regra e nao esta na Carencia
		//-------------------------------------------------------
		if QRYUJ8->(!Eof())

			if UF2->(MsSeek(xFilial("UF2")+cContrato))

				nValorParcelas := UF2->UF2_VALOR * QRYUJ8->QTD_PARCELAS

				nParcelasPagas := GetParcelasPagas(cContrato)

				//valido se ja pagou parcelas o suficiente para sair da carencia
				if nParcelasPagas < nValorParcelas

					nRetorno := 1
				else

					nRetorno := 2

				endif
			endif

		endif


	endif


	RestArea(aArea)
	RestArea(aAreaUJ0)

Return(nRetorno)

/*/{Protheus.doc} GetParcelasPagas
Funcao para retornar parcelas pagas do contrato
@type function
@version 
@author Raphael Martins 
@since 10/06/2020
@param cContrato, character, Codigo do Contrato
@return Numerico, Qtd de Parcelas pagas 
/*/
Static Function GetParcelasPagas(cContrato)

	Local aArea 		:= GetArea()
	Local cQry			:= ""
	Local cTipo			:= SuperGetMv("MV_XTPMNF",.F.,"MNT")
	Local nParcPagas	:= 0

	cQry := " SELECT "
	cQry += " SUM(E1_VALOR) VLR_PAGO "
	cQry += " FROM  "
	cQry += RetSQLName("SE1") + " SE1  (NOLOCK) "
	cQry += " WHERE D_E_L_E_T_ = ' ' "
	cQry += " AND E1_FILIAL = '" + xFilial("SE1") + "' "
	cQry += " AND E1_XCTRFUN = '" + cContrato + "' "
	//-------------------------------------------
	// NAO CONSIDERO TITULOS DE TAXA DE MANUTENCAO
	//-------------------------------------------
	cQry += " AND E1_TIPO NOT IN ('" + cTipo + "') "
	cQry += " AND E1_SALDO = 0 "
	//------------------------------------------------------------
	// NAO CONSIDERO TITULOS BAIXADOS POR LIQUIDACAO OU FATURA
	//------------------------------------------------------------
	cQry += " AND E1_TIPOLIQ <> 'LIQ' "
	cQry += " AND E1_FATURA IN ('','NOTFAT') "

	// verifico se nao existe este alias criado
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	EndIf

// funcao que converte a query generica para o protheus
	cQry := ChangeQuery(cQry)

// crio o alias temporario
	TcQuery cQry New Alias "QRYSE1"

	nParcPagas := QRYSE1->VLR_PAGO


	QRYSE1->(DbCloseArea())

	RestArea(aArea)

Return(nParcPagas)

/*/{Protheus.doc} PVComTiposDeServico
Funcao para preparar os itens do PV do cliente
de acordo com os tipos de servicos cadastrados (Tabela UK0 e UK1)
@type function
@version 
@author Raphael Martins Garcia
@since 07/08/2020
@param cApontamento, character, Codigo do Apontamento de Servico
@return return_type, return_description
/*/
Static Function PVComTiposDeServico(cApontamento)

	Local aArea 			:= GetArea()
	Local aAreaUJ2			:= UJ2->(GetArea())
	Local aTipoSV			:= {} //guarda os dados do tipo de servico vinculado
	Local aItensAssociado	:= {} //itens do pedido associado
	Local aItensDemais		:= {} //Itens do Pedido de Vendas demais tipos de servico
	Local cTipoApontamento	:= ""
	Local nItem				:= 0
	Local lRet				:= .T.
	Local lGeraAssociado	:= SuperGetMv("MV_XGERASS",.F.,.F.,UJ0->UJ0_FILSER)

	UJ0->(DBSetOrder(1))  //UJ0_FILIAL+UJ0_CODIGO
	UJ2->(DbSetOrder(1)) //UJ2_FILIAL+UJ2_CODIGO+UJ2_ITEM

	if UJ0->( MSSeek(xFilial("UJ0") + cApontamento ) )

		// alimento o tipo de apontmento
		cTipoApontamento := UJ0->UJ0_TPSERV

		If UJ2->( MSSeek(xFilial("UJ2") + cApontamento ) )

			While UJ2->(!EOF()) .And. xFilial("UJ2") == UJ2->UJ2_FILIAL .And. UJ2->UJ2_CODIGO == cApontamento

				aDados := {}`
				nItem++

				If UJ2->UJ2_OK .And. UJ2->UJ2_PV == "S"

					//----------------------------------------------------------------------------------------------------------------------------------------------------------
					//quando o tipo de servico e diferente de associado, procuro direto pelo tipo no cadastro,
					//quando for associado, verifico se possui valor a pagar e procuro o tipo de servico particular e quando tiver desconto, verifico o valor de desconto para
					//tipo de servico associado.
					//-----------------------------------------------------------------------------------------------------------------------------------------------------------

					if UJ0->UJ0_TPSERV <> "1"

						aTipoSV := RetTipoServico(cTipoApontamento,UJ2->UJ2_PRODUT)

						if Len(aTipoSV) == 0

							lRet := .F.
							Help( ,, 'Help - PVComTiposDeServico',, 'O Produto: ' + Alltrim(UJ2->UJ2_PRODUT) + ' nao possui tipo de servico cadastrado, favor revise o cadastro de tipo de servico! ', 1, 0 )
							Exit

						else

							AdicionaArray(aTipoSV,@aItensDemais,UJ2->UJ2_TOTAL)

						endif

					else

						//se possui valor, pesquiso para tipo de servico particular
						if UJ2->UJ2_TOTAL > 0

							aTipoSV := RetTipoServico("2",UJ2->UJ2_PRODUT)

							if Len(aTipoSV) == 0

								lRet := .F.
								Help( ,, 'Help - PVComTiposDeServico',, 'O Produto: ' + Alltrim(UJ2->UJ2_PRODUT) + ' nao possui tipo de servico cadastrado, favor revise o cadastro de tipo de servico! ', 1, 0 )
								Exit

							else

								AdicionaArray(aTipoSV,@aItensDemais,UJ2->UJ2_TOTAL)

							endif

						endif

						//preparo os dados do pedido associado
						if lGeraAssociado .And. UJ2->UJ2_VLRDES > 0

							aTipoSV	:= {}

							aTipoSV := RetTipoServico("1",UJ2->UJ2_PRODUT)

							if Len(aTipoSV) == 0

								lRet := .F.
								Help( ,, 'Help - PVComTiposDeServico',, 'O Produto: ' + Alltrim(UJ2->UJ2_PRODUT) + ' nao possui tipo de servico cadastrado, favor revise o cadastro de tipo de servico! ', 1, 0 )
								Exit

							else

								AdicionaArray(aTipoSV,@aItensAssociado,UJ2->UJ2_VLRDES)

							endif

						endif


					endif


				endif

				UJ2->(DbSkip())

			EndDo

		endif

	endif

	RestArea(aArea)
	RestArea(aAreaUJ2)

Return({lRet,aItensAssociado,aItensDemais})

/*/{Protheus.doc} RetTipoServico
Consulto o tipo de servico 
@type function
@version 
@author Raphael Martins Garcia
@since 07/08/2020
@param cTipoApontamento, character, Tipo de Apontamento
@param cProduto, character, Codigo do Produto
@return return_type, return_description
/*/
Static Function RetTipoServico(cTipoApontamento,cProduto)

	Local aArea 		:= GetArea()
	Local aRetorno		:= ""
	Local cQry 			:= ""

	cQry := " SELECT "
	cQry += " UK0_PRODUT AS PRODUTO, "
	cQry += " UK0_OPER	 AS OPERACAO "
	cQry += " FROM  "
	cQry += RetSQLName("UK0") + " UK0 "
	cQry += " INNER JOIN "
	cQry += RetSQLName("UK1") + " UK1 "
	cQry += " ON UK0.D_E_L_E_T_ = ' '
	cQry += " AND UK1.D_E_L_E_T_ = ' '
	cQry += " AND UK0.UK0_FILIAL = UK1.UK1_FILIAL
	cQry += " AND UK0.UK0_CODIGO = UK1.UK1_CODIGO
	cQry += " WHERE
	cQry += " UK0_FILIAL = '" + xFilial("UK0") + "'
	cQry += " AND UK0_TPSERV = '" + cTipoApontamento + "'
	cQry += " AND UK1_PRODUT = '" + cProduto + "'


	If Select("QRYTPSER") > 0
		QRYTPSER->(DbCloseArea())
	Endif

	cQry := ChangeQuery(cQry)

	TcQuery cQry NEW Alias "QRYTPSER"

	RestArea(aArea)

	if QRYTPSER->(!Eof())

		aRetorno := {QRYTPSER->PRODUTO,QRYTPSER->OPERACAO}

	endif

Return(aRetorno)

/*/{Protheus.doc} AdicionaArray
Funcao para adicionar os itens no Array do Pedido de Venda
@type function
@version 
@author Raphael Martins 
@since 10/08/2020
@param aTipoSV, array, Dados do Tipo de Servico
@param aItens, array, Array com os dados dos itens
@param nValorItem, numeric, param_description
@return return_type, return_description
/*/
Static Function AdicionaArray(aTipoSV,aItens,nValorItem)

	Local aDados		:= {}
	Local nLinhaItem	:= 0
	Local nItem			:= 0

//Pesquiso se o item ja existe no array de itens, caso sim, realizo a somatoria no item
	nLinhaItem := aScan(aItens,{|x| AllTrim(x[2,2]) == Alltrim( aTipoSV[1] ) })

	if nLinhaItem > 0

		aItens[nLinhaItem,4,2] += nValorItem

	else

		nItem := Len(aItens) + 1

		AAdd(aDados,{"C6_ITEM" 		, StrZero(nItem,TamSX3("C6_ITEM")[1])	,Nil})
		AAdd(aDados,{"C6_PRODUTO" 	, aTipoSV[1]							,Nil})
		AAdd(aDados,{"C6_QTDVEN" 	, 1	 									,Nil})
		AAdd(aDados,{"C6_PRCVEN" 	, nValorItem				 			,Nil})
		AAdd(aDados,{"C6_OPER" 		, aTipoSV[2]							,Nil})

		Aadd(aItens,aDados)

	endif


Return()
/*/{Protheus.doc} RetPedidosApontamento
Funcao para retornar os pedidos de vendas dos apontamento
de servico - Pedidos de Clientes
@type function
@version 1.0
@author Raphael Martins
@since 11/08/2020
@param cApontamento, character, Codigo do Apontamento
@param cClientePV, character, Cliente PV do apontamento
@param cLojaPV, character, Loja PV do apontamento
@return return_type, return_description
/*/
Static Function RetPedidosApontamento(cApontamento,cClientePV,cLojaPV)

	Local aArea 	:= GetArea()
	Local cQry 		:= ""
	Local aPedidos	:= {}

	cQry := " SELECT "
	cQry += " C5_NUM 	 AS PEDIDO, "
	cQry += " C5_XCLASSI AS TIPO "
	cQry += " FROM "
	cQry += RetSQLName("SC5") + " SC5 "
	cQry += " WHERE "
	cQry += " SC5.D_E_L_E_T_ = ' ' "
	cQry += " AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
	cQry += " AND SC5.C5_XAPTOFU = '" + cApontamento + "'  "
	cQry += " AND SC5.C5_CLIENTE = '" + cClientePV + "' "
	cQry += " AND SC5.C5_LOJACLI = '" + cLojaPV + "' "

	if Select("QRYSC5") > 0

		QRYSC5->(DBCloseArea())

	endif

	TcQuery cQry NEW Alias "QRYSC5"

	While QRYSC5->(!Eof())

		Aadd(aPedidos,{QRYSC5->PEDIDO,QRYSC5->TIPO})

		QRYSC5->(DbSkip())

	EndDo

	RestArea(aArea)

Return(aPedidos)

/*/{Protheus.doc} UFUN34ED
Funcao para edicao dos campos do apontamento
@type function
@version 1.0
@author g.sampaio
@since 21/06/2021
@return logical, retorno se o campos esta editavel
/*/
User Function UFUN34ED()

	Local cFielApt		:= ReadVar()
	Local lRetorno 		:= .T.
	Local lPDesc		:= SuperGetMv("MV_XPDESC",.F.,.T.)
	Local lEstApt		:= SuperGetMv("MV_XESTAPT",.F.,.F.)
	Local lOsApt		:= SuperGetMv("MV_XOSAPTO",.F.,.F.)
	Local cCamposLib	:= SuperGetMv("MV_XCPLIB",.F.,"UJ2_QUANT/UJ2_LOCAL")
	Local lUpdateUJ2PV	:= SuperGetMV("MV_XUPUJ2P", .F., .F.)

	if !Inclui

		// caso o campo de percentual de desconto e desconto
		if AllTrim(cFielApt) $ "M->UJ2_PERDES|M->UJ2_VLRDES"
			lRetorno := lPDesc	// considero o parametro
		elseIf AllTrim(cFielApt) $ "M->UJ2_UNESTO|M->UJ2_LOCAL"
			lRetorno := lEstApt	// considero o parametro
		elseIf AllTrim(cFielApt) $ "M->UJ2_OS"
			lRetorno := lOsApt	// considero o parametro
		endIf

		// verifico se tem pedido de vendas gerado ou apontamento de servicos
		If lRetorno .And. (!Empty(UJ0->UJ0_PV) .Or. U_VerReqArmazem(UJ0->UJ0_CODIGO))

			if lUpdateUJ2PV .And. !SubStr(Alltrim(cFielApt),4,13) $ Alltrim(cCamposLib)

				lRetorno := .F.

			endif

		endIf

	endIf

Return(lRetorno)

Static Function CriaButtonsGrid(oPanel)

	Local oPanelCpo			:= NIL
	Local oBotaoRecalcula	:= NIL
	Local oBotaoEstoque		:= NIL
	Local nHeigth			:= oPanel:nClientHeight / 2
	Local nWhidth			:= oPanel:nClientWidth / 2
	Local cBotaoCSSCinza	:= ""
	Local cBotaoCSSAzul		:= ""

	@ 002, 002 MSPANEL oPanelCpo SIZE nWhidth - 2 , nHeigth -5 OF oPanel COLORS 0, 16777215

	cBotaoCSSCinza  := CSSBotoesCinza()
	cBotaoCSSAzul	:= CSSBotoesAzul()

	oBotaoRecalcula := TButton():New( 002, 002, "Recalcula Itens", oPanelCpo,{ || AcoesButtonsGrid(1) }, 090, 015,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBotaoRecalcula:SetCss(cBotaoCSSCinza)

	oBotaoEstoque := TButton():New( 002, 100, "Consulta Estoque", oPanelCpo,{ || AcoesButtonsGrid(2)}, 090, 015,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBotaoEstoque:SetCss(cBotaoCSSAzul)

Return()


Static Function AcoesButtonsGrid(nAcao)

	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUJ0 	:= oModel:GetModel("UJ0MASTER")

	//Recalcula Grid
	If nAcao == 1

		MsgRun("Verificando carÍncias do contrato...","Aguarde",{|| U_ValidaBeneficiario( oView, oModelUJ0:GetValue("UJ0_CODBEN"),,.F. )})

	else

		MsgRun("Consultando Saldo em Estoque do Produto","Aguarde",{|| U_RFUNE032()})

	endif

Return()

/*/{Protheus.doc} CSSBotoesCinza
description
@type function
@version 
@author g.sampaio
@since 28/07/2020
@return return_type, return_description
/*/
Static Function CSSBotoesCinza()

	Local cRetorno	:= ""

	// implementacao do CSS
	cRetorno    := " QPushButton { background: #d2d2d2; "
	cRetorno    += " border: 1px solid #696969;"
	cRetorno    += " outline:0;"
	cRetorno    += " border-radius: 5px;"
	cRetorno    += " font-family: Arial;"
	cRetorno    += " font-size: 12px;"
	cRetorno    += " font-weight: bold;"
	cRetorno    += " padding: 6px;"
	cRetorno    += " color: #000000;}"
	cRetorno    += " QPushButton:hover { background-color: #696969;"
	cRetorno    += " border-style: inset;"
	cRetorno    += " font-family: Arial;"
	cRetorno    += " font-size: 12px;"
	cREtorno    += " font-weight: bold;"
	cRetorno    += " border-color: #d2d2d2;"
	cRetorno    += " color: #ffffff; }"

Return(cRetorno)

/*/{Protheus.doc} CSSBotoesAzul
description
@type function
@version 
@author g.sampaio
@since 28/07/2020
@return return_type, return_description
/*/
Static Function CSSBotoesAzul()

	Local cRetorno := ""

	// implementacao do CSS
	cRetorno    := " QPushButton { background: #35ACCA; "
	cRetorno    += " border: 1px solid #1f6779;"
	cRetorno    += " outline:0;"
	cRetorno    += " border-radius: 5px;"
	cRetorno    += " font-family: Arial;"
	cRetorno    += " font-size: 12px;"
	cREtorno    += " font-weight: bold;"
	cRetorno    += " padding: 6px;"
	cRetorno    += " color: #ffffff;}"
	cRetorno    += " QPushButton:hover { background-color: #1f6779;"
	cRetorno    += " border-style: inset;"
	cRetorno    += " font-family: Arial;"
	cRetorno    += " font-size: 12px;"
	cREtorno    += " font-weight: bold;"
	cRetorno    += " border-color: #35ACCA;"
	cRetorno    += " color: #ffffff; }"

Return(cRetorno)

/*/{Protheus.doc} BuscaItensCarencia
description
@type function
@version 1.0
@author g.sampaio
@since 07/12/2021
@param cContrato, character, param_description
@param nPerDesconto, numeric, param_description
@return variant, return_description
/*/
Static Function BuscaItensCarencia(cContrato,nPerDesconto)

	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUJ2		:= oModel:GetModel("UJ2DETAIL")
	Local nX			:= 0
	Local nDesconto 	:= If(oOSTotais <> Nil, oOSTotais:nVlrContratado, 0 )
	Local nVlrTotal		:= 0
	Local nVlrDes		:= 0
	Local nSubTotal		:= 0
	Local nQtdBenef		:= 1
	Local nQtdItem		:= 1
	Local lDivideQtd	:= SuperGetMv("MV_XDIVQTD",.F.,.F.)

	If lDivideQtd
		nQtdBenef := SomaQtdBeneficarios(cContrato)
	endif

	For nX := 1 To oModelUJ2:Length()

		UF3->(DbSetOrder(2)) //UF3_FILIAL + UF3_CODIGO + UF3_PROD

		oModelUJ2:Goline(nX)

		if !oModelUJ2:IsDeleted() .AND. oModelUJ2:GetValue("UJ2_OK")

			if UF3->(MsSeek(xFilial("UF3") + cContrato + oModelUJ2:GetValue("UJ2_PRODUT") )) .And. UF3->UF3_CARENC > dDatabase

				if lDivideQtd .And. UF3->UF3_SALDO > 1
					nQtdItem 	:= Round(UF3->UF3_SALDO / nQtdBenef,0)
				endif

				nSubTotal 	:= oModelUJ2:GetValue("UJ2_QUANT") * oModelUJ2:GetValue("UJ2_PRCVEN")
				nVlrDes		:= (nQtdItem * oModelUJ2:GetValue("UJ2_PRCVEN")) * (nPerDesconto / 100)
				nVlrTotal	:= nSubTotal - nVlrDes
				nDesconto	-= nQtdItem * oModelUJ2:GetValue("UJ2_PRCVEN")

				oModelUJ2:LoadValue("UJ2_CARENC"	,	"BR_LARANJA")
				oModelUJ2:LoadValue("UJ2_PERDES"	,	nPerDesconto)
				oModelUJ2:LoadValue("UJ2_VLRDES"	,	nVlrDes)
				oModelUJ2:LoadValue("UJ2_TOTAL"		,	nVlrTotal)

			endif

		endif


	Next nX

Return(nDesconto)

/*/{Protheus.doc} UFilUF0
Filtro da UF0
@type function
@version 1.0
@author g.sampaio
@since 07/12/2021
@return character, retorno do filtro
/*/
User Function UF0FastFilterUJ0()

	Local oModel	:= FWModelActive()
	Local oModelUJ0	:= oModel:GetModel("UJ0MASTER")
	Local cRetorno 	:= ""

	cRetorno := "@#"
	cRetorno += "UF0->(UF0_STATUS == 'A' .And. UF0_FILIAL == '" + oModelUJ0:GetValue("UJ0_FILSER") + "')"
	cRetorno += "@#"

Return(cRetorno)

/*/{Protheus.doc} VldFServ
Funcao para validar a filial de servico
@type function
@version 1.0
@author g.sampaio
@since 18/01/2024
@return logical, retorno sobre a validacao da filial de servico
/*/
User Function VldFServ()

	Local aArea 		:= GetArea()
	Local aAreaUF0 		:= UF0->(GetArea())
	Local cTabela		:= ""
	Local cFilServ		:= ""
	Local cFilBkp		:= ""
	Local lRetorno		:= .T.
	Local oModel		:= FWModelActive()
	Local oView			:= FWViewActive()
	Local oModelUJ0 	:= oModel:GetModel("UJ0MASTER")

	cFilServ		:= oModelUJ0:GetValue("UJ0_FILSER")

	if !Empty(cFilServ)

		cFilBkp := cFilAnt
		cFilAnt := cFilServ

		cTabela			:= Alltrim(SuperGetMv("MV_XTABSER",.F.,"001"))
		FwFldPut("UJ0_TABPRC"	,cTabela			,,,,.T.)
		FwFldPut("UJ0_DESTAB"	,RetField("DA0",1,xFilial("DA0")+cTabela,"DA0_DESCRI"),,,,.T.)

		cFilAnt := cFilBkp
	endIf

	If oView <> Nil
		oView:Refresh()
	EndIf

	RestArea(aAreaUF0)
	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} UTRANSNOTA
Funcao para preparar a filial de acordo com a filial de servico
para realizar a transmissao da nota
@type function
@version  1.0
@author raphaelgarcia
@since 9/18/2022
@param cFilServ, character, filial de servico
/*/
User Function UTRANSNOTA(cFilServ)

	Local cFilBkp := cFilAnt

	Default cFilServ := cFilAnt

//altero a filial logada para a filial de servico para possibilitar a visualizacao dos documentos
	cFilAnt := cFilServ

//funcao para transmitir nota fiscal
	FISA022()

//restauro backup
	cFilAnt := cFilBkp

Return()

/*/{Protheus.doc} UJ1CalculaValorContratado
Funcao para preenchimento o valor contrad
@type function
@version 1.0
@author g.sampaio
@since 30/11/2023
@return numeric, valor contrato
/*/
Static Function UJ1CalculaValorContratado()

	Local aSaveLines		:= FWSaveRows()
	Local nI				:= 0
	Local nRetorno			:= 0
	Local nValorEntregue	:= 0
	Local nValorDesconto	:= 0
	Local nValorReceber		:= 0
	Local oModel			:= FWModelActive()
	Local oModelUJ1 		:= oModel:GetModel("UJ1DETAIL")
	Local oModelUJ2 		:= oModel:GetModel("UJ2DETAIL")
	Local oModelUJ0 		:= oModel:GetModel("UJ0MASTER")

	/////////////////////////////////////////////////////
	//// CALCULO OS VALORES DOS PRODUTOS CONTRATADOS ///
	////////////////////////////////////////////////////
	For nI := 1 To oModelUJ1:Length()

		oModelUJ1:Goline(nI)

		if !oModelUJ1:IsDeleted()

			nRetorno += oModelUJ1:GetValue("UJ1_TOTAL")

		Endif

	Next nI

	/////////////////////////////////////////////////////
	//// CALCULO OS VALORES DOS PRODUTOS ENTREGUES /////
	////////////////////////////////////////////////////
	For nI := 1 To oModelUJ2:Length()

		oModelUJ2:Goline(nI)

		if !oModelUJ2:IsDeleted() .And. oModelUJ2:GetValue("UJ2_OK")

			nValorEntregue += oModelUJ2:GetValue("UJ2_SUBTOT")
			nValorDesconto += oModelUJ2:GetValue("UJ2_VLRDES")
			nValorReceber += oModelUJ2:GetValue("UJ2_TOTAL")

		Endif

	Next nI

	if oModel:GetOperation() == 3

		//atualizo valor contratado no cabecalho da OS
		oModelUJ0:LoadValue("UJ0_VLRCON", nRetorno)
		oModelUJ0:LoadValue("UJ0_VLRENT", nValorEntregue)
		oModelUJ0:LoadValue("UJ0_VLRDES", nValorDesconto)
		oModelUJ0:LoadValue("UJ0_VLRREC", nValorReceber)

	endif

	FWRestRows(aSaveLines)

Return(nRetorno)
