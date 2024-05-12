#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RCPGA049
Browse de Cadastro de Faturamento em Lote
@type function
@version 1.0
@author g.sampaio
@since 20/09/2022
/*/
User Function RCPGA049(cApontamento)

	Local aArea			:= GetArea()
	Local aAreaUJV		:= UJV->(GetArea())
	Local oBrowse	    := Nil

	Default cApontamento    := ""

	// crio o objeto do Browser
	oBrowse := FWmBrowse():New()

	// defino o Alias
	oBrowse:SetAlias("U87")

	// posiciono no apontamento
	UJV->(DbSetOrder(1))
	If UJV->(MsSeek(xFilial("UJV")+cApontamento))

		// faco filtro dos pedidos gerados ara o paontamento
		oBrowse:SetFilterDefault( "U87_FILIAL == '"+ xFilial("U87") +"' .And. U87_APONTA =='" + UJV->UJV_CODIGO + "'" ) // filtro apenas o apontamento selecionado

	EndIf

	// informo a descrição
	oBrowse:SetDescription("Pedidos Multi-Faturamento")

	// crio as legendas
	oBrowse:AddLegend("U87_STATUS == '1'", "WHITE"	,	"Pedido Pendente")
	oBrowse:AddLegend("U87_STATUS == '2'", "GREEN"	,	"Pedido Gerado")
	oBrowse:AddLegend("U87_STATUS == '3'", "RED"	,	"Documento de Saída Gerado")

	// ativo o browser
	oBrowse:Activate()

	RestAreA(aAreaUJV)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} MenuDef
Cria os Menus da Rotina
@type function
@version 1.0
@author  g.sampaio 
@since 20/09/2022
@return array, aRotina
/*/
Static Function MenuDef()

	Local aRotina       := {}
	Local aRotPedCli    := {}

	// opcoes da rotina de pedido de vendas de cliente
	Aadd( aRotPedCli, {"Alterar"     		,"U_UVirtusAlteraPV(U87->U87_PEDIDO)" 	, 0, 4} )
	Aadd( aRotPedCli, {"Visualizar"     	,"U_UVirtusViewPV(U87->U87_PEDIDO)" 	, 0, 4} )
	Aadd( aRotPedCli, {"Prep.Doc.Saida"		,"U_RCPGA49A()"			                , 0, 4} )
	Aadd( aRotPedCli, {"Excluir"       		,"U_RCPGA49B()"        	                , 0, 4} )

	ADD OPTION aRotina Title 'Pesquisar'   						Action 'PesqBrw'          	OPERATION 01 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar'  						Action 'VIEWDEF.RCPGA049' 	OPERATION 02 ACCESS 0
	ADD OPTION aRotina Title 'Imprimir'    						Action 'VIEWDEF.RCPGA049' 	OPERATION 08 ACCESS 0
	ADD OPTION aRotina Title 'Copiar'      	                    Action 'VIEWDEF.RCPGA049' 	OPERATION 09 ACCESS 0
	ADD OPTION aRotina Title 'Pedido de Venda'                  Action aRotPedCli	        OPERATION 04 ACCESS 0
	ADD OPTION aRotina Title 'Legenda'     						Action 'U_RCPGA49LEG()' 	OPERATION 10 ACCESS 0

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
	Local oStruU87 	:= FWFormStruct( 1, 'U87', /*bAvalCampo*/, /*lViewUsado*/ )

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PCPGA049', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Crio a Enchoice
	oModel:AddFields( 'U87MASTER', /*cOwner*/, oStruU87 )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ 'U87_FILIAL' , 'U87_CODIGO' })

	// Preencho a descrição da entidade
	oModel:GetModel('U87MASTER'):SetDescription('Dados do Multi-Faturamento')

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
	Local oStruU87 := FWFormStruct(2,'U87')
	Local oModel := FWLoadModel('RCPGA049')
	Local oView

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	// cria o cabeçalho
	oView:AddField('VIEW_U87', oStruU87, 'U87MASTER')

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_CABECALHO' , 100)

	// Relaciona o ID da View com os panel's
	oView:SetOwnerView('VIEW_U87' , 'PANEL_CABECALHO')

	// Ligo a identificacao do componente
	oView:EnableTitleView('VIEW_U87')

	// Habilita a quebra dos campos na Vertical
	oView:SetViewProperty( 'U87MASTER', 'SETLAYOUT', { FF_LAYOUT_VERT_DESCR_TOP , 3 } )

	// Define fechamento da tela ao confirmar a operação
	oView:SetCloseOnOk({||.T.})

Return oView

// prepara doc.saida
User Function RCPGA49A()

	Local oVirtusMultiFaturamento := VirtusMultiFaturamento():New("A", U87->U87_APONTA)

	oVirtusMultiFaturamento:GerarDocSaida(U87->U87_PEDIDO)

Return(Nil)

User Function RCPGA49B()

	Local aClientes                 := {}
	Local aAux                      := {}
	Local cQuery                    := ""
	Local nTipFat                   := Iif(U87->U87_TIPAPT=="V",1,2)
	Local oVirtusMultiFaturamento   := VirtusMultiFaturamento():New("A", U87->U87_APONTA)

	cQuery := " SELECT U87.R_E_C_N_O_ RECU87 FROM " + RetSQLName("U87") + " U87 "
	cQuery += " WHERE U87.D_E_L_E_T_ = ' ' "
	cQuery += " AND U87.U87_FILIAL = '" + xFilial("U87") + "' "
	cQuery += " AND U87.U87_STATUS = '2' "
	cQuery += " AND U87.U87_PEDIDO = '"+ U87->U87_PEDIDO +"' "
	cQuery += " AND U87.U87_APONTA = '"+ U87->U87_APONTA +"' "
	cQuery += " AND U87.U87_CLIENT = '" + U87->U87_CLIENT + "'"
	cQuery += " AND U87.U87_LOJA = '" + U87->U87_LOJA + "'"

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, "TRBCLI")

	While TRBCLI->(!Eof())

		aAux := {}
		Aadd( aAux, .T.)
		Aadd( aAux, "P")
		Aadd( aAux, TRBCLI->U87_CLIENT)
		Aadd( aAux, TRBCLI->U87_LOJA)
		Aadd( aAux, Posicione("SA1",1,xFilial("SA1")+TRBCLI->U87_CLIENT+TRBCLI->U87_LOJA,"A1_NOME"))
		Aadd( aAux, TRBCLI->U87_PEDIDO)
		Aadd( aAux, TRBCLI->U87_ITEAPT)
		Aadd( aAux, TRBCLI->U87_PRODUT)
		Aadd( aAux, TRBCLI->U87_VALPED)
		Aadd( aAux, TRBCLI->U87_CODIGO)
		Aadd( aAux, TRBCLI->U87_ITEM)
		Aadd( aClientes, aAux)

		TRBCLI->(DbSkip())
	EndDo

	If Len(aClientes) > 0
		oVirtusMultiFaturamento:ExcluirPedido(aClientes, nTipFat)
	Endif

Return(Nil)

User Function RCPGA49LEG()

	BrwLegenda("Status","Legenda",{{"BR_BRANCO","Pedido Pendente"},{"BR_VERDE","Pedido Gerado"},{"BR_VERMELHO","Documento de Saída Gerado"}})

Return(Nil)

User Function RCPGA49C(cApontamento)

	Local oButton1
	Local oButton2
	Local oButton3
	Local oButton4
	Local oButton5
	Local oGroup1
	Local oGroup2
	Static oDlg

	Default cApontamento := ""

	DEFINE MSDIALOG oDlg TITLE "New Dialog" FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL

	@ 003, 000 GROUP oGroup1 TO 159, 294 PROMPT "Pedidos" OF oDlg COLOR 0, 16777215 PIXEL
	BrwPedidos(cApontamento)

	@ 161, 002 GROUP oGroup2 TO 195, 297 OF oDlg COLOR 0, 16777215 PIXEL
	@ 173, 250 BUTTON oButton1 PROMPT "Fechar" SIZE 037, 012 OF oDlg PIXEL
	@ 174, 053 BUTTON oButton2 PROMPT "Visualizar" SIZE 037, 012 OF oDlg PIXEL
	@ 174, 144 BUTTON oButton3 PROMPT "Prep.Doc Saida" SIZE 044, 012 OF oDlg PIXEL
	@ 174, 097 BUTTON oButton4 PROMPT "Excluir" SIZE 037, 012 OF oDlg PIXEL
	@ 174, 008 BUTTON oButton5 PROMPT "Gerar" SIZE 037, 012 OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return

Static Function BrwPedidos(cApontamento)

	Local cQuery 	:= ""
	Local oWBrowse1
	Local aWBrowse1 := {}

	cQuery := " SELECT "
	cQuery += "		U87.R_E_C_N_O_ RECU87"
	cQuery += "	FROM " + RetSQLName("U87") + " U87 "
	cQuery += "	WHERE U87.D_E_L_E_T_ = ' ' "
	cQuery += "	AND U87.U87_APONTA = '" + cApontamento + "' "

	// Insert items here
	Aadd(aWBrowse1,{"Pedido","Data","Codigo","Loja","Cliente","Doc Saida","Serie"})
	Aadd(aWBrowse1,{"Pedido","Data","Codigo","Loja","Cliente","Doc Saida","Serie"})

	@ 011, 004 LISTBOX oWBrowse1 Fields HEADER "Pedido","Data","Codigo","Loja","Cliente","Doc Saida","Serie" SIZE 286, 144 OF oDlg PIXEL ColSizes 50,50
	oWBrowse1:SetArray(aWBrowse1)
	oWBrowse1:bLine := {|| {;
		aWBrowse1[oWBrowse1:nAt,1],;
		aWBrowse1[oWBrowse1:nAt,2],;
		aWBrowse1[oWBrowse1:nAt,3],;
		aWBrowse1[oWBrowse1:nAt,4],;
		aWBrowse1[oWBrowse1:nAt,5],;
		aWBrowse1[oWBrowse1:nAt,6],;
		aWBrowse1[oWBrowse1:nAt,7];
		}}
	// DoubleClick event
	oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := !aWBrowse1[oWBrowse1:nAt,1],;
		oWBrowse1:DrawSelect()}

Return(Nil)
