#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE 'FWEditPanel.CH'
/*/{Protheus.doc} RCPGA028
Rotina de Controle de Carnês
Bancarios

@author Raphael Martins
@since 24/03/2016
@version 1.0
@Param
/*/

User Function RCPGA028()

	Local oBrowse

	Private aRotina
	Private cCadastro := 'Controle de Entregas'

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'U32' )
	oBrowse:SetDescription( 'Controle de Entregas' )

	oBrowse:AddLegend( "U32_STATUS == '1'", "WHITE"  , "Gerada")
	oBrowse:AddLegend( "U32_STATUS == '2'", "GREEN"	 , "Entregue")
	oBrowse:AddLegend( "U32_STATUS == '3'", "BLACK"	 , "Não Recebido")
	oBrowse:AddLegend( "U32_STATUS == '4'", "YELLOW" , "Devolvido") //Pedro Neto
	oBrowse:AddLegend( "U32_STATUS == '5'", "ORANGE" , "Roteirizado") //Pedro Neto
	oBrowse:AddLegend( "U32_STATUS == '6'", "BLUE" 	 , "Em Rota") //Pedro Neto

	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()

	aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar'      					ACTION 'VIEWDEF.RCPGA028'	OPERATION 2 ACCESS	0
	ADD OPTION aRotina TITLE 'Incluir'         					ACTION 'VIEWDEF.RCPGA028'	OPERATION 3 ACCESS	0
	ADD OPTION aRotina TITLE 'Alterar'         					ACTION 'VIEWDEF.RCPGA028'	OPERATION 4 ACCESS	0
	ADD OPTION aRotina TITLE 'Excluir'         					ACTION 'VIEWDEF.RCPGA028'	OPERATION 5 ACCESS	0
	ADD OPTION aRotina Title 'Legenda'     	   					Action 'U_RCPG28LEG()'		OPERATION 10 ACCESS 0
	ADD OPTION aRotina Title 'Relatório'       					Action 'U_RCPGR021()'		OPERATION 11 ACCESS 0
	ADD OPTION aRotina Title 'Gera Protocolo em Lote'			Action 'U_RCPGA28C()'		OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Impressao Protocolo Avulso'       Action 'U_IMPAVULSO()' 	 	OPERATION 11 ACCESS 0
	ADD OPTION aRotina Title 'Impressao Protocolo em Lote'		Action 'U_RCPGA28F()'		OPERATION 11 ACCESS 0

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruU32  := FWFormStruct( 1, 'U32', /*bAvalCampo*/,/*lViewUsado*/ ) //CABECALHO DE CONTROLE DE ENTREGAS
	Local oStruU33  := FWFormStruct( 1, 'U33', /*bAvalCampo*/,/*lViewUsado*/ ) //TITULOS DOS ENTREGAS
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('PRCPG028', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formul·rio de ediÁ?o por campo
	oModel:AddFields( 'U32MASTER', /*cOwner*/, oStruU32, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	// Adiciona a chave primaria da tabela principal
	oModel:SetPrimaryKey({ "U32_FILIAL" ,"U32_CODIGO"})

	// Adiciona ao modelo uma componente de Titulos das ENTREGAS
	oModel:AddGrid( 'U33DETAIL', 'U32MASTER', oStruU33 , /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'U33DETAIL', { {'U33_FILIAL', 'xFilial( "U32" )'},{'U33_CODIGO', 'U32_CODIGO'}}, U33->( IndexKey( 1 ) ) )

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'U33DETAIL' ):SetUniqueLine( { 'U33_ITEM' } )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( 'Controle de Entregas' )

	// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel( 'U32MASTER' ):SetDescription( 'Dados da Entrega' )
	oModel:GetModel( 'U33DETAIL' ):SetDescription( 'Boletos da Entrega' )

	oModel:GetModel('U33DETAIL'):SetOptional( .T. )

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()

	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel	:= FWLoadModel( 'RCPGA028' )
	Local oView		:= NIL

	// Cria a estrutura a ser usada na View
	Local oStruU32 := FWFormStruct( 2, 'U32' )
	Local oStruU33 := FWFormStruct( 2, 'U33' )

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados ser· utilizado
	oView:SetModel( oModel )


	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_U32', oStruU32, 'U32MASTER' )

	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid( 'VIEW_U33', oStruU33, 'U33DETAIL' )

	// Define campos que terao Auto Incremento
	oView:AddIncrementField( 'VIEW_U33', 'U33_ITEM' )

	// Crio os Panel's horizontais
	oView:CreateHorizontalBox('PANEL_TELA'		, 100)

	oView:CreateVerticalBox('PANEL_CAMPOS'		, 065,'PANEL_TELA')
	oView:CreateVerticalBox('PANEL_GRID'		, 035,'PANEL_TELA')

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_U32' , 'PANEL_CAMPOS' )
	oView:SetOwnerView( 'VIEW_U33' , 'PANEL_GRID' )

	// titulo dos componentes
	oView:EnableTitleView('VIEW_U32' ,/*'cabecalho'*/)
	oView:EnableTitleView('VIEW_U33' , /*'item'*/)

	oView:SetViewProperty( "U32MASTER", "SETLAYOUT", {  FF_LAYOUT_VERT_DESCR_TOP   , 3 , 10 } )

	oView:SetViewProperty("U32MASTER", "SETCOLUMNSEPARATOR", {90})

Return oView


/*/{Protheus.doc} RCPGA028
Funcao de visualizacao das legendas

@author Raphael Martins
@since 24/03/2016
@version 1.0
@Param
/*/
User Function RCPG28LEG()

	BrwLegenda("Status dos Protocolos","Legenda",{ {"BR_BRANCO","Gerado"},{"BR_VERDE","Entregue"},{"BR_PRETO","Não recebido"},{"BR_AMARELO","Devolvido"} })

Return()



/*/{Protheus.doc} RCPG28B
//Funcao para informar o motivo de nao entregue.
@author rapha
@since 18/06/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function RCPG28B()

	Local cGet1   := Space(TamSX3("U32_MOTIVO")[1])
	Local cMotivo := ""
	Local lRet 	  := .T.
	Local oGroup1
	Local oGet1
	Local oMemo
	Local oDlg

	Private aButtons := {}

	DEFINE MSDIALOG oDlg TITLE "Motivo" FROM 000, 000  TO 238, 370 COLORS 0, 16777215 PIXEL Style DS_MODALFRAME

	oDlg:lEscClose     := .F.  //Nao permite sair ao se pressionar a tecla ESC.

	@ 038, 003 GROUP oGroup1 TO 099, 180 PROMPT "Preencha o motivo do não recebimentos dos boletos" OF oDlg COLOR 0, 16777215 PIXEL

	oMemo := TMultiget():Create(oDlg,{|u|if(Pcount()>0, cMotivo:=u,cMotivo)},047,007,169,047,,.T.,,,,.T.)
	oMemo:EnableHScroll(.T.)

	ACTIVATE MSDIALOG oDlg CENTERED  ON INIT EnchoiceBar(oDlg, {|| lRet := VldConf(oDlg,cMotivo)  },{||  lRet := VldConf(oDlg,cMotivo) },,aButtons)

Return(lRet)


Static Function VldConf(oDlg,cMotivo)
//***************************************
	Local lRet := .T.

	If Empty(cMotivo)
		lRet := .F.
		Aviso( "", "Preencha do campo motivo é obrigatório!", {"Ok"} )
	Else
		M->U32_MOTIVO := cMotivo
		oDlg:End()
	EndIf

Return(lRet)


//***************************************
/*/{Protheus.doc} IMPAVULSO
//Funcao para imprimir protocolo avulso
@author Raphael Martins Garcia
@since 19/06/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function IMPAVULSO(nLinha, nPosCodBar, nRowCodBar, nColCodBar, oPrinter)

	Local aArea 		:= GetArea()
	Local aAreaU32		:= U32->(GetArea())
	Local aDadosCliente	:= {}
	Local cDescRota		:= ""
	Local lMstEndCob	:= SuperGetMV("MV_XENDCOB",,.T.) // .T. - Mostra End. Cobranca | .F. - Mostra End. Principal

	Default nLinha 		:= 0
	Default nPosCodBar	:= 1
	Default nRowCodBar	:= 0
	Default nColCodBar	:= 0
	Default oPrinter	:= Nil

	SA1->(DbSetOrder(1) ) //A1_FILIAL + A1_COD + A1_LOJA
	if SA1->(DbSeek(xFilial("SA1")+U32->U32_CLIENT + U32->U32_LOJA))

		cDescRota := RetField("U34",1,xFilial("U34")+U32->U32_CODROT,"U34_DESCRI")

		If lMstEndCob .And. !Empty(SA1->A1_ENDCOB)

			aDadosCliente   := {AllTrim(SA1->A1_NOME)           ,;			// 	[1]Razão Social
			AllTrim(SA1->A1_COD )+SA1->A1_LOJA		            ,;   		// 	[2]Código
			AllTrim(SA1->A1_ENDCOB)								,;   		// 	[3]Endereço
			AllTrim(SA1->A1_MUNC )	                            ,;   		// 	[4]Cidade
			SA1->A1_ESTC	                                    ,;   		// 	[5]Estado
			SA1->A1_CEPC                                        ,;   		// 	[6]CEP
			SA1->A1_CGC											,;			// 	[7]CGC
			SA1->A1_PESSOA										,; 	    	// 	[8]PESSOA
			AllTrim(SA1->A1_BAIRROC)						    ,;      	// 	[9]Bairro
			U32->U32_CONTRA										,; 			//	[10] Codigo do Contrato ou Codigo do Cliente
			U32->U32_CODROT										,;			// 	[11]Codigo da Rota
			cDescRota  											,;			//	[12]//Descricao da Rota
			IIF(!Empty(SA1->A1_XREFCOB),SA1->A1_XREFCOB,SA1->A1_XREFERE),;	//  [13]Ponto de Referencia
			SA1->A1_NREDUZ,; 												//	[14]Nome Fantasia
			Alltrim(SA1->A1_XCOMPCO)}										//  [15]Complemento

		Else

			aDadosCliente   := {AllTrim(SA1->A1_NOME)       ,;			//	[1]Razão Social
			AllTrim(SA1->A1_COD )+SA1->A1_LOJA		        ,;      	//	[2]Código
			AllTrim(SA1->A1_END )							,;      	// 	[3]Endereço
			AllTrim(SA1->A1_MUN )                           ,;  		// 	[4]Cidade
			SA1->A1_EST                                     ,;     		// 	[5]Estado
			SA1->A1_CEP                                     ,;      	// 	[6]CEP
			SA1->A1_CGC										,;  		// 	[7]CGC
			SA1->A1_PESSOA									,; 	    	// 	[8]PESSOA
			AllTrim(SA1->A1_BAIRRO)							,;         	// 	[9]Bairro
			U32->U32_CONTRA									,;			//	[10]Codigo do Contrato ou Codigo do Cliente
			U32->U32_CODROT									,;			// 	[11]Codigo da Rota
			cDescRota										,;			//	[12]Descricao da Rota
			IIF(!Empty(SA1->A1_XREFERE),SA1->A1_XREFERE,SA1->A1_XREFCOB),;	//  [13]Ponto de Referencia
			SA1->A1_NREDUZ,; 											//	[14]Nome Fantasia
			Alltrim(SA1->A1_COMPLEM)}									//  [15]Complemento

		Endif

		//realizo a impressao do protocolo avulso
		FWMsgRun(,{|oSay| U_RCPGR003(nLinha,@oPrinter,aDadosCliente,U32->U32_REFINI,U32->U32_REFFIM,nPosCodBar,U32->U32_CONTRA, nRowCodBar, nColCodBar)},'Aguarde...','Impressao de Protocolo Avulso...')

	else

		lRet := .F.
		Help(,,'Help',,"Cliente não encontrado, favor verifico o protocolo selecionado!",1,0)

	endif

	RestArea(aArea)
	RestArea(aAreaU32)

Return(Nil)

/*/{Protheus.doc} RCPGA28A
Funcao para gerar o numero sequencial 
da tabela U32.
Antiga função RetNextProt
@type function
@version 1.0
@author g.sampaio
@since 07/04/2021
@return character, retorna o proximo codigo da tabela U32
/*/
User Function RCPGA28A()

	Local aArea      	:= GetArea()
	Local aAreaU32   	:= U32->( GetArea() )
	Local cCodigo		:= StrZero(0,TamSx3("U32_CODIGO")[1])
	Local cRetorno		:= ""
	Local cQry 			:= ""

	If Select("QRYMAX") > 0
		QRYMAX->( DbCloseArea() )
	EndIf

	cQry := " SELECT "
	cQry += " MAX(U32_CODIGO) MAX_CODIGO "
	cQry += " FROM "
	cQry += RetSQLName("U32") + " U32 (NOLOCK)"
	cQry += " WHERE "
	cQry += " U32.D_E_L_E_T_ = ' ' "
	cQry += " AND U32_FILIAL = '" + xFilial("U32")+ "' "

	cQry := ChangeQuery(cQry)

	TcQuery cQry New Alias "QRYMAX"

	If QRYMAX->(!Eof()) .And. !Empty(QRYMAX->MAX_CODIGO)
		cCodigo := Alltrim(QRYMAX->MAX_CODIGO)
	EndIf

	cRetorno := Soma1( Alltrim(cCodigo) )

	U32->( DbSetOrder(1)) // U32_FILIAL+U32_CODIGO

	// verifico se o codigo esta em uso
	FreeUsedCode()
	While !MayIUseCode( "U32"+xFilial("U32")+cRetorno )
		cRetorno := Soma1( Alltrim(cRetorno) ) // gero um novo codigo
	EndDo

	If Select("QRYMAX") > 0
		QRYMAX->( DbCloseArea() )
	EndIf

	RestArea(aAreaU32)
	RestArea(aArea)

Return(cRetorno)

/*/{Protheus.doc} RCPGA28B
Funcao para excluir os titulos vinculados ao protocolo
do cliente anterior a alteracao de cessionario ou alteracao
do titular.
@type function
@version 1.0	
@author g.sampaio
@since 06/05/2022
@param cCodContrato, character, codigo do contrato
@param cCodClienteAnterior, character, codigo do cliente anterior
@param cLojaAnterior, character, codigo da loja anterior
/*/
User Function RCPGA28B(cCodContrato, cCodClienteAnterior, cLojaAnterior)

	Local aArea		:= GetArea()
	Local aAreaU32	:= U32->( GetArea() )
	Local aAreaU33	:= U33->( GetArea() )
	Local cQuery 	:= ""

	Default cCodContrato		:= ""
	Default cCodClienteAnterior	:= ""
	Default cLojaAnterior		:= ""
	Default cCliTransf			:= ""
	Default cLojaTransf			:= ""

	if Select("TMPPRT") > 0
		TMPPRT->(DbCloseArea())
	endIf

	cQuery := " SELECT MAX(U32.R_E_C_N_O_) RECU32 FROM " + RetSQLName("U32") + " U32 "
	cQuery += " WHERE U32.D_E_L_E_T_ = ' ' "
	cQuery += " AND U32.U32_FILIAL = '" + xFilial("U32") + "' "
	cQuery += " AND U32.U32_BOLETO = 'T' "
	cQuery += " AND U32.U32_CONTRA = '" + cCodContrato + "' "
	cQuery += " AND U32.U32_CLIENT = '" + cCodClienteAnterior + "' "
	cQuery += " AND U32.U32_LOJA = '" + cLojaAnterior + "' "

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TMPPRT' )

	if !Empty(TMPPRT->RECU32)

		U32->(DbSetOrder(1))
		U32->(DBGoTo(TMPPRT->RECU32))

		BEGIN TRANSACTION

			U33->(DbSetOrder(1))
			if U33->(MsSeek( xFilial("U33") + U32->U32_CODIGO ))
				While U33->(!Eof()) .And. U33->U33_FILIAL == xFilial("U33") .And. U33->U33_CODIGO == U32->U32_CODIGO

					if U33->U33_VENCTO >= dDatabase
						if U33->(RecLock("U33", .F.))
							U33->(DbDelete())
							U33->(MsUnlock())
						else
							DisarmTransaction()
							BREAK
						endIf
					endIf

					U33->(DBSkip())
				EndDo
			endIf

			// altero a data final da referencia
			if U32->(RecLock("U32", .F.))
				U32->U32_REFFIM := dDatabase
				U32->(MsUnlock())
			else
				DisarmTransaction()
				BREAK
			endIf

		END TRANSACTION

	endIf

	if Select("TMPPRT") > 0
		TMPPRT->(DbCloseArea())
	endIf

	RestArea(aAreaU33)
	RestArea(aAreaU32)
	RestArea(aArea)

Return(niL)

/*/{Protheus.doc} RCPGA28C
Funcoo para geracao dos protocolos em lote
@type function
@version 1.0
@author g.sampaio
@since 18/12/2022
/*/
User Function RCPGA28C()

	Local cPerg				:= "RCPGA28C"
	Local lContinua			:= .T.
	Local lConsulta			:= .T.

	Private __XVEZ 			:= "0"
	Private __ASC       	:= .T.
	Private _nMarca			:= 0

	AjustaSX1(cPerg)

	// enquanto o usuário não cancelar a tela de perguntas
	While lContinua

		// chama a tela de perguntas
		lContinua := Pergunte(cPerg,.T.)

		If lContinua

			//consulto titulos de acordo com os parametros informados
			FWMsgRun(,{|oSay| lConsulta := ConsultaDados() },'Aguarde...','Consultando Contratos para Geração de Protocolo...')

			If lConsulta
				FWMsgRun(,{|oSay| MontaTela() },'Aguarde...','Consultando contratos para Geração de Protocolo...')
			Else
				Aviso( "", "A Consulta realizada não retornou registros, favor verifique os parametros digitados!", {"Ok"} )
			Endif

		EndIf

	EndDo

Return(Nil)

/*/{Protheus.doc} AjustaSX1
Funcao para criar grupos de perguntas
@type function
@version 1.0
@author g.sampaio
@since 05/12/2022
@param cPerg, character, grupo de perguntas de faturamento
/*/
Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relatório

	Local aHelpPor				:= {}
	Local aHelpEng				:= {}
	Local aHelpSpa				:= {}

	Default cPerg	:= ""

	If cPerg == "RCPGA28C" // geracao de protocolo em lote

		///////////// Contrato ////////////////
		U_xPutSX1( cPerg, "01","Do Contrato?","Do Contrato","Do Contrato","cContratoIni","C",6,0,0,"G","","UF2","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		U_xPutSX1( cPerg, "02","Até Contrato?","Até Contrato?","Até Contrato?","cContratoFim","C",6,0,0,"G","","UF2","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

		///////////// Cliente ////////////////
		U_xPutSX1( cPerg, "03","Do Cliente?","Do Cliente","Do Cliente","cDoCliente","C",6,0,0,"G","","SA1VIR","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		U_xPutSX1( cPerg, "04","Até Cliente?","Até Cliente?","Até Cliente?","cAteCliente","C",6,0,0,"G","","SA1VIR","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

		///////////// Intervalo de Ativacao ////////////////
		U_xPutSX1( cPerg, "05","Da Ativacao?","Da Ativacao?","Da Ativacao?","dAtivIni","D",8,0,0,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		U_xPutSX1( cPerg, "06","Até Ativacao?","Até Ativacao?","Até Ativacao?","dAtivFim","D",8,0,0,"G","","","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

		///////////// Plano ////////////////
		U_xPutSX1( cPerg, "07","Plano?","Plano?","Plano?","cPlano","C",99,0,0,"G","","UF0MRK","","","MV_PAR07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

		///////////// Obito ////////////////
		U_xPutSX1( cPerg, "08","Obito?","Obito?","Obito?","nObito","N",1,0,0,"C","","","","","MV_PAR08","Todos","Com Obito","Sem Obito","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

		///////////// Financeiro ////////////////
		U_xPutSX1( cPerg, "09","Financeiro?","Financeiro?","Financeiro?","nFinanceiro","N",1,0,0,"C","","","","","MV_PAR09","Todos","Inadimplente","Em Dia","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

		// informacoes para gravar no protocolo
		U_xPutSX1( cPerg, "10","Inicio Referencia","Inicio Referencia","Inicio Referencia","cIniRef","D",8,0,0,"G","","","","","MV_PAR10","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		U_xPutSX1( cPerg, "11","Fim da Referencia","Fim da Referencia","Fim da Referencia","cFimRef","D",8,0,0,"G","","","","","MV_PAR11","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		U_xPutSX1( cPerg, "12","Itens da Entrega?","Itens da Entrega?","Itens da Entrega?","cItemEtrega","C",99,0,0,"G","","U32ENT","","","MV_PAR12","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		U_xPutSX1( cPerg, "13","Descrivito Outros","Descrivito Outros","Descrivito Outros","cDescOutros","C",99,0,0,"G","","","","","MV_PAR13","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		U_xPutSX1( cPerg, "14","Responsavel Entrega?","Responsavel Entrega?","Descrivito Outros","cDescOutros","C",6,0,0,"G","","","","","MV_PAR14","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	ElseIf cPerg == "RFUNA28F" .Or. cPerg == "RCEMA28F"// impressao de protocolo em lote

		///////////// Contrato ////////////////
		U_xPutSX1( cPerg, "01","Do Contrato?","Do Contrato","Do Contrato","cContratoIni","C",6,0,0,"G","","UF2","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		U_xPutSX1( cPerg, "02","Até Contrato?","Até Contrato?","Até Contrato?","cContratoFim","C",6,0,0,"G","","UF2","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

		///////////// Cliente ////////////////
		U_xPutSX1( cPerg, "03","Do Cliente?","Do Cliente","Do Cliente","cDoCliente","C",6,0,0,"G","","SA1VIR","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		U_xPutSX1( cPerg, "04","Até Cliente?","Até Cliente?","Até Cliente?","cAteCliente","C",6,0,0,"G","","SA1VIR","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

		///////////// Intervalo de Ativacao ////////////////
		U_xPutSX1( cPerg, "05","Da Emissao?","Da Emissao?","Da Emissao?","dAtivIni","D",8,0,0,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		U_xPutSX1( cPerg, "06","Até Emissao?","Até Emissao?","Até Emissao?","dAtivFim","D",8,0,0,"G","","","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

		///////////// Intervalo de Ativacao ////////////////
		U_xPutSX1( cPerg, "07","Impresso?","Impresso?","Impresso?","nObito","N",1,0,0,"C","","","","","MV_PAR07","Todos","Sim","Nao","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

		///////////// Plano ////////////////
		If cPerg == "RFUNA28F"
			U_xPutSX1( cPerg, "08","Plano?","Plano?","Plano?","cPlano","C",99,0,0,"G","","UF0MRK","","","MV_PAR08","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		ElseIf cPerg == "RCEMA28F"
			U_xPutSX1( cPerg, "08","Produto?","Produto?","Produto?","cProduto","C",99,0,0,"G","","U05MRK","","","MV_PAR08","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
		EndIf

	EndIf

Return(Nil)

/*/{Protheus.doc} ConsultaDados
Funcao para consultar dados para medicao
@type function
@version 1.0
@author g.sampaio
@since 16/12/2022
@return logical, retorno se encontrei dados
/*/
Static Function ConsultaDados(cMod, nTipo)

	Local cQuery  			:= ""
	Local lRetorno			:= .T.
	Local cDeContrato 		:= ""
	Local cAteContrato 		:= ""
	Local cDeCliente 		:= ""
	Local cAteCliente 		:= ""
	Local cPlano 			:= ""
	Local nObito 			:= 0
	Local nFinanceiro		:= 0
	Local dDeAtivacao		:= StoD("")
	Local dAteAtivacao		:= StoD("")
	Local dIniRef 			:= StoD("")
	Local dFimRef 			:= StoD("")

	Default cMod	:= U_RetModul()
	Default nTipo 	:= 1

	cDeContrato 		:= MV_PAR01
	cAteContrato 		:= MV_PAR02
	cDeCliente 			:= MV_PAR03
	cAteCliente 		:= MV_PAR04
	dDeAtivacao			:= MV_PAR05
	dAteAtivacao		:= MV_PAR06

	If nTipo == 1 // geracao do protocolo em lote
		cPlano				:= MV_PAR07
		nObito				:= If(cMod == "FUN",MV_PAR08, 0)
		nFinanceiro			:= MV_PAR09
		dIniRef 			:= MV_PAR10
		dFimRef 			:= MV_PAR11
	ElseIf nTipo == 2 // impresao em lote
		nImpressao			:= MV_PAR07
		cPlano				:= MV_PAR08
	EndIf

	If Select("TRBPRO") > 1
		TRBPRO->(DbCloseArea())
	endif

	If nTipo == 1 // geracao do protocolo em lote

		If cMod == "FUN" // modoulo de planos

			cQuery := " SELECT "
			cQuery += " 	CONTRATO.UF2_CODIGO CODIGO, "
			cQuery += " 	CONTRATO.UF2_CLIENT CLIENTE, "
			cQuery += " 	CONTRATO.UF2_LOJA LOJACLI, "
			cQuery += " 	CONTRATO.UF2_DTATIV DATA_ATIVACAO, "
			cQuery += " 	CLIENTE.A1_NOME NOMECLIENTE, "
			cQuery += " 	ISNULL(OBITOS.OBITO,0) OBITO_BENEF, "
			cQuery += " 	ISNULL(OBITOS.OBITO_TITULAR,0) OBITO_TIULAR, "
			cQuery += " 	ISNULL(INADIMPLENCIA.TITULO_VENCIDO,0) TITULOS_VENCIDOS "
			cQuery += " FROM " + RetSQLName("UF2") + " CONTRATO "
			cQuery += " INNER JOIN " + RetSQLName("SA1") + " CLIENTE ON CLIENTE.D_E_L_E_T_ = ' ' "
			cQuery += " 	AND CLIENTE.A1_FILIAL = '" + xFilial("SA1") + "' "
			cQuery += " 	AND CLIENTE.A1_COD = CONTRATO.UF2_CLIENT "
			cQuery += " 	AND CLIENTE.A1_LOJA = CONTRATO.UF2_LOJA "
			cQuery += " LEFT JOIN ( "
			cQuery += " 		SELECT "
			cQuery += " 			BENEFICIARIO.UF4_CODIGO CONTRATO, "
			cQuery += " 			SUM(CASE WHEN BENEFICIARIO.UF4_FALECI <> ' ' AND BENEFICIARIO.UF4_TIPO <> '3' THEN 1 ELSE 0 END) OBITO, "
			cQuery += " 			SUM(CASE WHEN BENEFICIARIO.UF4_FALECI <> ' ' AND BENEFICIARIO.UF4_TIPO = '3' THEN 1 ELSE 0 END) OBITO_TITULAR "
			cQuery += " 		FROM " + RetSQLName("UF4") + " BENEFICIARIO "
			cQuery += " 		WHERE BENEFICIARIO.D_E_L_E_T_ = ' ' "
			cQuery += " 			AND BENEFICIARIO.UF4_FILIAL = '" + xFilial("UF4") + "' "
			cQuery += " 			AND BENEFICIARIO.UF4_FALECI <> ' ' "
			cQuery += " 		GROUP BY BENEFICIARIO.UF4_CODIGO "
			cQuery += " ) AS OBITOS ON OBITOS.CONTRATO = CONTRATO.UF2_CODIGO "
			cQuery += " LEFT JOIN ( "
			cQuery += " 		SELECT "
			cQuery += " 			TITULOS.E1_XCTRFUN CONTRATO, "
			cQuery += " 			COUNT(*) TITULO_VENCIDO "
			cQuery += " 		FROM " + RetSQLName("SE1") + " TITULOS "
			cQuery += " 		WHERE TITULOS.D_E_L_E_T_ = ' ' "
			cQuery += " 			AND TITULOS.E1_FILIAL = '" + xFilial("SE1") + "' "
			cQuery += " 			AND TITULOS.E1_VENCTO < '" + DtoS(dDatabase) + "'
			cQuery += " 			AND TITULOS.E1_SALDO > 0 "
			cQuery += " 			AND TITULOS.E1_XCTRFUN <> ' ' "
			cQuery += " 		GROUP BY TITULOS.E1_XCTRFUN "
			cQuery += " ) AS INADIMPLENCIA ON INADIMPLENCIA.CONTRATO = CONTRATO.UF2_CODIGO "
			cQuery += " WHERE CONTRATO.D_E_L_E_T_ = ' ' "
			cQuery += " AND CONTRATO.UF2_FILIAL = '" + xFilial("UF2") + "' "
			cQuery += " AND CONTRATO.UF2_STATUS IN ('A','S') "
			cQuery += " AND CONTRATO.UF2_DTATIV <> '' "

			If !Empty(dAteAtivacao)
				cQuery += " AND CONTRATO.UF2_DTATIV BETWEEN '" + DTOS(dDeAtivacao) + "' AND '" + DTOS(dAteAtivacao) + "'  "
			EndIf

			If !Empty(cAteCliente)
				cQuery += " AND CONTRATO.UF2_CLIENT BETWEEN '" + AllTrim(cDeCliente) + "' AND '" + AllTrim(cAteCliente) + "'  "
			EndIf

			If !Empty(cAteContrato)
				cQuery += " AND CONTRATO.UF2_CODIGO BETWEEN '" + AllTrim(cDeContrato) + "' AND '" + AllTrim(cAteContrato) + "'  "
			EndIf

			If !Empty(cPlano)
				cQuery += " AND CONTRATO.UF2_PLANO IN " + FormatIN(AllTrim(cPlano),";")
			EndIf

			If nObito == 2 // com obito
				cQuery += " AND OBITOS.OBITO > 0 OR OBITOS.OBITO_TITULAR > 0 "
			ElseIf nObito == 3 // sem obito
				cQuery += " AND OBITOS.OBITO = 0 OR OBITOS.OBITO_TITULAR = 0 "
			EndIf

			If nFinanceiro == 2 // inadimplente
				cQuery += " AND TITULOS_VENCIDOS > 0 OR TITULOS_VENCIDOS > 0 "
			ElseIf nFinanceiro == 3 // em dia
				cQuery += " AND TITULOS_VENCIDOS = 0 OR TITULOS_VENCIDOS = 0 "
			EndIf

			cQuery += " AND NOT EXISTS ( SELECT "
			cQuery += " PROTOCOLO.U32_CONTRA "
			cQuery += " FROM " + RetSQLName("U32") + " PROTOCOLO "
			cQuery += " WHERE PROTOCOLO.D_E_L_E_T_ = ' ' "
			cQuery += "	AND PROTOCOLO.U32_FILIAL = '" + xFilial("U32") + "' "
			cQuery += " AND PROTOCOLO.U32_CONTRA = CONTRATO.UF2_CODIGO "
			cQuery += " AND PROTOCOLO.U32_BOLETO = 'F' "
			cQuery += " AND PROTOCOLO.U32_REFINI >= '" + DtoS(dIniRef) + "' "
			cQuery += " AND PROTOCOLO.U32_REFFIM <= '" + DtoS(dFimRef) + "') "
			cQuery += " ORDER BY CLIENTE.A1_NOME "

		Else // modoulo de cemiterio

			cQuery := " SELECT "
			cQuery += " 	CONTRATO.U00_CODIGO CODIGO, "
			cQuery += " 	CONTRATO.U00_CLIENT CLIENTE, "
			cQuery += " 	CONTRATO.U00_LOJA LOJACLI, "
			cQuery += " 	CONTRATO.U00_DTATIV DATA_ATIVACAO, "
			cQuery += " 	CLIENTE.A1_NOME NOMECLIENTE, "
			cQuery += " 	ISNULL(INADIMPLENCIA.TITULO_VENCIDO,0) TITULOS_VENCIDOS "
			cQuery += " FROM " + RetSQLName("U00") + " CONTRATO "
			cQuery += " INNER JOIN " + RetSQLName("SA1") + " CLIENTE ON CLIENTE.D_E_L_E_T_ = ' ' "
			cQuery += " 	AND CLIENTE.A1_FILIAL = '" + xFilial("SA1") + "' "
			cQuery += " 	AND CLIENTE.A1_COD = CONTRATO.U00_CLIENT "
			cQuery += " 	AND CLIENTE.A1_LOJA = CONTRATO.U00_LOJA "
			cQuery += " LEFT JOIN ( "
			cQuery += " 		SELECT "
			cQuery += " 			TITULOS.E1_XCTRFUN CONTRATO, "
			cQuery += " 			COUNT(*) TITULO_VENCIDO "
			cQuery += " 		FROM " + RetSQLName("SE1") + " TITULOS "
			cQuery += " 		WHERE TITULOS.D_E_L_E_T_ = ' ' "
			cQuery += " 			AND TITULOS.E1_FILIAL = '" + xFilial("SE1") + "' "
			cQuery += " 			AND TITULOS.E1_VENCTO < '" + DtoS(dDatabase) + "'
			cQuery += " 			AND TITULOS.E1_SALDO > 0 "
			cQuery += " 			AND TITULOS.E1_XCTRFUN <> ' ' "
			cQuery += " 		GROUP BY TITULOS.E1_XCTRFUN "
			cQuery += " ) AS INADIMPLENCIA ON INADIMPLENCIA.CONTRATO = CONTRATO.U00_CODIGO "
			cQuery += " WHERE CONTRATO.D_E_L_E_T_ = ' ' "
			cQuery += " AND CONTRATO.U00_FILIAL = '" + xFilial("U00") + "' "
			cQuery += " AND CONTRATO.U00_STATUS IN ('A','S') "
			cQuery += " AND CONTRATO.U00_DTATIV <> '' "

			If !Empty(dAteAtivacao)
				cQuery += " AND CONTRATO.U00_DTATIV BETWEEN '" + DTOS(dDeAtivacao) + "' AND '" + DTOS(dAteAtivacao) + "'  "
			EndIf

			If !Empty(cAteCliente)
				cQuery += " AND CONTRATO.U00_CLIENT BETWEEN '" + AllTrim(cDeCliente) + "' AND '" + AllTrim(cAteCliente) + "'  "
			EndIf

			If !Empty(cAteContrato)
				cQuery += " AND CONTRATO.U00_CODIGO BETWEEN '" + AllTrim(cDeContrato) + "' AND '" + AllTrim(cAteContrato) + "'  "
			EndIf

			If !Empty(cPlano)
				cQuery += " AND CONTRATO.U00_PLANO IN " + FormatIN(AllTrim(cPlano),";")
			EndIf

			If nFinanceiro == 2 // inadimplente
				cQuery += " AND TITULOS_VENCIDOS > 0 OR TITULOS_VENCIDOS > 0 "
			ElseIf nFinanceiro == 3 // em dia
				cQuery += " AND TITULOS_VENCIDOS = 0 OR TITULOS_VENCIDOS = 0 "
			EndIf

			cQuery += " AND NOT EXISTS ( SELECT "
			cQuery += " PROTOCOLO.U32_CONTRA "
			cQuery += " FROM " + RetSQLName("U32") + " PROTOCOLO "
			cQuery += " WHERE PROTOCOLO.D_E_L_E_T_ = ' ' "
			cQuery += "	AND PROTOCOLO.U32_FILIAL = '" + xFilial("U32") + "' "
			cQuery += " AND PROTOCOLO.U32_CONTRA = CONTRATO.U00_CODIGO "
			cQuery += " AND PROTOCOLO.U32_BOLETO = 'F' "
			cQuery += " AND PROTOCOLO.U32_REFINI >= '" + DtoS(dIniRef) + "' "
			cQuery += " AND PROTOCOLO.U32_REFFIM <= '" + DtoS(dFimRef) + "') "
			cQuery += " ORDER BY CLIENTE.A1_NOME "

		EndIf

	ElseIf nTipo == 2 // impressao em lote

		cQuery := " SELECT
		cQuery += " 	PROTOCOLO.U32_CODIGO COD_PROTOCOLO,
		cQuery += " 	PROTOCOLO.U32_DATA DATA_PROTOCOLO,
		cQuery += " 	PROTOCOLO.U32_CONTRA CODIGO,
		cQuery += " 	PROTOCOLO.U32_CLIENT CLIENTE,
		cQuery += " 	PROTOCOLO.U32_LOJA LOJACLI,
		cQuery += " 	CLIENTE.A1_NOME NOMECLIENTE,
		cQuery += " 	PROTOCOLO.R_E_C_N_O_ RECU32
		cQuery += " FROM " + RetSQLName("U32") + " PROTOCOLO
		cQuery += " INNER JOIN " + RetSQLName("SA1") + " CLIENTE ON CLIENTE.D_E_L_E_T_ = ' '
		cQuery += "		AND CLIENTE.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery += " 	AND CLIENTE.A1_COD = PROTOCOLO.U32_CLIENT
		cQuery += " 	AND CLIENTE.A1_LOJA = PROTOCOLO.U32_LOJA

		If cMod == "FUN" // contrato de planos
			cQuery += " INNER JOIN " + RetSQLName("UF2") + " CONTRATO ON CONTRATO.D_E_L_E_T_ = ' '
			cQuery += "		AND CONTRATO.UF2_FILIAL = '" + xFilial("UF2") + "' "
			cQuery += " 	AND CONTRATO.UF2_CODIGO = PROTOCOLO.U32_CONTRA
		Else // contrato de cemiterio
			cQuery += " INNER JOIN " + RetSQLName("U00") + " CONTRATO ON CONTRATO.D_E_L_E_T_ = ' '
			cQuery += "		AND CONTRATO.U00_FILIAL = '" + xFilial("U00") + "' "
			cQuery += " 	AND CONTRATO.U00_CODIGO = PROTOCOLO.U32_CONTRA
		EndIf

		cQuery += " WHERE PROTOCOLO.D_E_L_E_T_ = ' '
		cQuery += "		AND PROTOCOLO.U32_FILIAL = '" + xFilial("U32") + "' "
		cQuery += " 	AND PROTOCOLO.U32_STATUS = '1'

		If cMod == "FUN" // contrato de planos
			If !Empty(cAteCliente)
				cQuery += " AND CONTRATO.UF2_CLIENT BETWEEN '" + AllTrim(cDeCliente) + "' AND '" + AllTrim(cAteCliente) + "'  "
			EndIf

			If !Empty(cAteContrato)
				cQuery += " AND CONTRATO.UF2_CODIGO BETWEEN '" + AllTrim(cDeContrato) + "' AND '" + AllTrim(cAteContrato) + "'  "
			EndIf
		Else // contrato de cemiterio
			If !Empty(cAteCliente)
				cQuery += " AND CONTRATO.U00_CLIENT BETWEEN '" + AllTrim(cDeCliente) + "' AND '" + AllTrim(cAteCliente) + "'  "
			EndIf

			If !Empty(cAteContrato)
				cQuery += " AND CONTRATO.U00_CODIGO BETWEEN '" + AllTrim(cDeContrato) + "' AND '" + AllTrim(cAteContrato) + "'  "
			EndIf
		EndIf

		If !Empty(dAteAtivacao)
			cQuery += " AND PROTOCOLO.U32_DATA BETWEEN '" + DTOS(dDeAtivacao) + "' AND '" + DTOS(dAteAtivacao) + "'  "
		EndIf

		If !Empty(cPlano)
			cQuery += " AND CONTRATO.UF2_PLANO IN " + FormatIN(AllTrim(cPlano),";")
		EndIf

		cQuery += " ORDER BY PROTOCOLO.U32_DATA ASC, CLIENTE.A1_NOME"

	EndIf

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery( cQuery, "TRBPRO" )

	TRBPRO->( DbGotop() )

	If TRBPRO->( Eof() )
		lRetorno := .F.
	EndIf

Return(lRetorno)

/*/{Protheus.doc} MontaTela
Funcao para montar tela
@type function
@version 1.0
@author g.sampaio
@since 16/12/2022
/*/
Static Function MontaTela(cMod, nTipo)

	Local cTitulo    := "Geração de Protocolo"
	Local nQtTotal   := 0
	local nColOrder	 := 0
	Local aSizeAut   := {}
	Local oPn1		:= Nil
	Local oPn2		:= Nil
	Local oPn3		:= Nil
	Local oTotal	:= Nil
	Local oQtTotal	:= Nil
	Local oGrid		:= Nil
	Local oFont     := TFont():New('Courier New',,-12,.T.)

	Private aButtons := {}

	Default	cMod	:= ""
	Default nTipo 	:= 1

	aSizeAut := MsAdvSize()

	DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	aAdd(aButtons, {"", {|| GdSeek(oGrid,"Pesquisa"/*,aCposFind*/) }, "Pesquisa" })

	@ 001,000 MSPANEL oPn1 SIZE 150, 050 OF oDlg
	@ 001,000 MSPANEL oPn2 SIZE 150, 050 OF oPn1
	@ 001,000 MSPANEL oPn3 SIZE 150, 050 OF oPn1

	oPn1:Align  := CONTROL_ALIGN_ALLCLIENT
	oPn2:Align  := CONTROL_ALIGN_TOP
	oPn3:Align  := CONTROL_ALIGN_BOTTOM

	oPn2:nHeight := (oMainWnd:nClientHeight / 2) + 150
	oPn3:nHeight := (oMainWnd:nClientHeight - oPn2:nHeight ) - 100

	@ 00, 005 SAY oTotal PROMPT "Quantidade Selecionada:" SIZE 100, 007 OF oPn3 COLORS CLR_RED Font oFont COLOR CLR_BLACK PIXEL
	@ 00, 090 MSGET oQtTotal VAR nQtTotal SIZE 100, 007 When .F. OF oPn3 HASBUTTON PIXEL COLOR CLR_BLACK Picture "@E 999999999"

	oGrid := MontaGrid(oPn2,oQtTotal,@nQtTotal,nTipo,cMod)

	oGrid:oBrowse:bLDblClick := {|| Clique(oGrid,oQtTotal,@nQtTotal) }
	oGrid:oBrowse:bHeaderClick := {|oBrw1,nCol| if(oGrid:oBrowse:nColPos <> 111 .And. nCol == 1,(MarcaTodos(oGrid,oQtTotal,@nQtTotal),;
		oBrw1:SetFocus()),(U_OrdGrid(oGrid,nCol) , nColOrder := nCol ))}

	oGrid:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oGrid:oBrowse:Refresh()

	EnchoiceBar(oDlg, {|| FWMsgRun(,{|oSay| Confirma(oSay,@oDlg,@oGrid,oQtTotal,@nQtTotal,nTipo) },'Aguarde...','Realizando a Geração do Protocolo em Lote...')},{|| oDlg:End()},,aButtons)

	ACTIVATE MSDIALOG oDlg CENTERED

Return(Nil)

//********************************************************
// Funcao para montar Grid de Visualização dos Titulos
//********************************************************
/*/{Protheus.doc} MontaGrid
Funcao para montar Grid de Visualização dos Titulos
@type function
@version 1.0
@author g.sampaio
@since 06/12/2022
@param oPainel, object, objeto do painel
@param oQtTotal, object, objeto da quantidade total
@param nQtTotal, numeric, quantidade total
@return object, retorna o objeto da grid
/*/
Static Function MontaGrid(oPainel, oQtTotal, nQtTotal, nTipo, cMod)

	Local oGrid
	Local aHeader       := {}
	Local aCols         := {}
	Local aAlterFields  := {}

	Default nTipo 	:= 1

	aHeader := NewHeader(nTipo, cMod)
	aAcols  := NewAcols(@nQtTotal, nTipo, cMod)

	oGrid := MsNewGetDados():New( 05,05,000, 000, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,;
		, 999, "AllwaysTrue", "", "AllwaysTrue",oPainel, aHeader, aAcols)

	oQtTotal:Refresh()

Return(oGrid)

/*/{Protheus.doc} NewHeader
Funcao para Montar aHeader da Grid
@author Raphael Martins
@since 03/06/2016
@version P11
@param
@return nulo
/*/
Static Function NewHeader(nTipo, cMod)

	Local aHeaderEx		:= {}
	Local nX            := 0
	Local aFields		:= 0
	Local oSX3			:= UGetSxFile():New()
	Local aSX3			:= {}

	Default nTipo 	:= 1
	Default cMod	:= ""

	If nTipo == 1 // geracao do protocolo em lote
		aFields := {"U32_CONTRA", "A1_COD","A1_LOJA","A1_NOME","UF2_DTATIV"}
	ElseIf nTipo == 2 // impressao do protocolo em lote
		aFields := {"U32_CODIGO", "U32_DATA", "U32_CONTRA", "A1_COD","A1_LOJA","A1_NOME"}
	EndIf

	Aadd(aHeaderEx, {"","MARK","@BMP",2,0,"","€€€€€€€€€€€€€€","C","","","",""})

	For nX := 1 to Len(aFields)

		aSX3 := oSX3:GetInfoSX3(,aFields[nX])

		If Len(aSX3) > 0

			Aadd(aHeaderEx, {aSX3[1,2]:cTITULO,aSX3[1,2]:cCAMPO,aSX3[1,2]:cPICTURE,aSX3[1,2]:nTAMANHO,aSX3[1,2]:nDECIMAL,aSX3[1,2]:cVALID,;
				aSX3[1,2]:cUSADO,aSX3[1,2]:cTIPO,aSX3[1,2]:cF3,aSX3[1,2]:cCONTEXT,aSX3[1,2]:cCBOX,aSX3[1,2]:cRELACAO})

		Endif

	Next nX

	If nTipo == 1 // geracao de protocolo em lote
		If cMod ==	"FUN"
			Aadd(aHeaderEx, {"Obito Benef.","OBTBEN","@ 999999999",9,0,"","€€€€€€€€€€€€€€","N","","","",""})
			Aadd(aHeaderEx, {"Obito Titular","OBTIT","@ 999999999",9,0,"","€€€€€€€€€€€€€€","N","","","",""})
		EndIf
		Aadd(aHeaderEx, {"Titulos Vencidos","TITVEN","@ 999999999",9,0,"","€€€€€€€€€€€€€€","N","","","",""})
	EndIf

Return( aClone(aHeaderEx) )

/*/{Protheus.doc} NewAcols
Funcao para Montar aCols da Grid
@author Raphael Martins
@since 03/06/2016
@version P12
@param
@return nulo
/*/
Static Function NewAcols(nQtTotal, nTipo, cMod)

	Local aArea 		:= GetArea()
	Local aAreaSE1 		:= SE1->(GetArea())
	Local aColsEx 		:= {}
	Local aFieldFill 	:= {}

	Default nQtTotal:= 0
	Default nTipo	:= 1
	Default cMod	:= ""

	TRBPRO->( DbGotop() )

	While TRBPRO->( !EOF() )

		Aadd(aFieldFill, "CHECKED")

		If nTipo == 2
			Aadd(aFieldFill, TRBPRO->COD_PROTOCOLO)
			Aadd(aFieldFill, Stod(TRBPRO->DATA_PROTOCOLO))
		EndIf

		Aadd(aFieldFill, TRBPRO->CODIGO)
		Aadd(aFieldFill, TRBPRO->CLIENTE)
		Aadd(aFieldFill, TRBPRO->LOJACLI)
		Aadd(aFieldFill, TRBPRO->NOMECLIENTE )

		If nTipo == 1
			Aadd(aFieldFill, StoD(TRBPRO->DATA_ATIVACAO))
			If cMod == "FUN"
				Aadd(aFieldFill, TRBPRO->OBITO_BENEF)
				Aadd(aFieldFill, TRBPRO->OBITO_TIULAR )
			EndIf
			Aadd(aFieldFill, TRBPRO->TITULOS_VENCIDOS )
		EndIf

		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)

		aFieldFill := {}

		nQtTotal++

		TRBPRO->( DbSkip() )
	EndDo

	RestArea(aAreaSE1)
	RestArea(aArea)

Return( aClone(aColsEx) )

/*/{Protheus.doc} Clique
Função chamada no duplo clique da linha do grid
@type function
@version 1.0 
@author Raphael Martins
@since 08/06/2016
@param oObj, object, objeto da gride
@param oQtTotal, object, objeto da quantidade total
@param nQtTotal, numeric, quantidade total de itens marcados
/*/
Static Function Clique(oObj,oQtTotal,nQtTotal)

	Local nPosMark	:= aScan(oObj:aHeader,{|x| AllTrim(x[2])== "MARK"})

	if oObj:aCols[oObj:nAt][nPosMark] == "CHECKED"
		oObj:aCols[oObj:nAt][nPosMark] 	:= "UNCHECKED"
		nQtTotal--
	else
		oObj:aCols[oObj:nAt][nPosMark] 	:= "CHECKED"
		nQtTotal++
	endif

	oQtTotal:Refresh()

	oObj:oBrowse:Refresh()

Return(Nil)

/*/{Protheus.doc} MarcaTodos
Função chamada pela ação de clicar no cabeçalho
dos grids para selecionar todos os checkbox
@type function
@version 1.0
@author Raphael Martins
@since 08/06/2016
@param oObj, object, objeto da gride
@param oGetTotal, object, objeto da totalizador 
@param nGetTotal, numeric, o valor total
@param oQtTotal, object, objeto da quantidade total
@param nQtTotal, numeric, quantidade total de itens marcados
/*/
Static Function MarcaTodos(_obj,oQtTotal,nQtTotal)

	Local nX		:= 1

	if __XVEZ == "0"
		__XVEZ := "1"
	else
		if __XVEZ == "1"
			__XVEZ := "2"
		endif
	endif

	If __XVEZ == "2"

		nQtTotal  := 0

		If _nMarca == 0

			For nX := 1 TO Len(_obj:aCols)
				_obj:aCols[nX][1] := "CHECKED"
				nQtTotal++
			Next

			_nMarca := 1

		Else

			FOR nX := 1 TO LEN(_obj:aCols)
				_obj:aCols[nX][1] := "UNCHECKED"
			Next

			_nMarca := 0

		Endif

		__XVEZ:="0"

		_obj:oBrowse:Refresh()
		oQtTotal:Refresh()

	Endif

Return(Nil)

Static Function Confirma(oSay, oDlg, oGrid, oQtTotal, nQtTotal, nTipo)

	Local aImpProtcolo 			:= {}
	Local aProtocolo			:= {}
	Local aItensEntrega 		:= {}
	Local cCodigoProt			:= ""
	Local cItensEntrega 		:= ""
	Local cDescritivo 			:= ""
	Local cRespEntre 			:= ""
	Local cCodCliente			:= ""
	Local cLojaCliente			:= ""
	Local cNomeCliente			:= ""
	Local dIniRef 				:= StoD("")
	Local dFimRef 				:= Stod("")
	Local nPosProtCodigo		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "U32_CODIGO"})
	Local nPosContra 			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "U32_CONTRA"})
	Local nPosCodCli 			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "A1_COD"})
	Local nPosLoja  			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "A1_LOJA"})
	Local nPosNome  			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "A1_NOME"})
	Local nPosMark				:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "MARK"})
	Local nX 					:= 0

	Default nTipo	:= 1

	If nTipo == 1 // geracao do protocolo em lote

		// atribui o valor dos parametros
		dIniRef 		:= MV_PAR10
		dFimRef 		:= MV_PAR11
		cItensEntrega 	:= MV_PAR12
		cDescritivo 	:= MV_PAR13
		cRespEntre 		:= MV_PAR14

		If Empty(dIniRef)
			dIniRef := dDataBase
		EndIf

		If Empty(dFimRef)
			dFimRef := dDataBase
		EndIf

		// pego os itens de entrega
		aItensEntrega	:= StrTokArr(cItensEntrega,";")

		// percorro os contratos a serem faturados
		For nX := 1 To Len(oGrid:aCols)

			If oGrid:aCols[nX][nPosMark] == 'CHECKED' // pego itens marcados

				cCodigoProt		:= ""
				cContrato 		:= ""
				cCodCliente 	:= ""
				cLojaCliente	:= ""
				cNomeCliente	:= ""

				If Len(aProtocolo) == 0

					cCodigoProt		:= U_RCPGA28A()
					cContrato 		:= oGrid:aCols[nX][nPosContra]
					cCodCliente 	:= oGrid:aCols[nX][nPosCodCli]
					cLojaCliente	:= oGrid:aCols[nX][nPosLoja]
					cNomeCliente	:= oGrid:aCols[nX][nPosNome]

					aAdd( aProtocolo, {'U32_FILIAL'    	, xFilial("U32") } )
					aAdd( aProtocolo, {'U32_CODIGO'    	, cCodigoProt } )
					aAdd( aProtocolo, {'U32_DATA'		, dDataBase } )
					aAdd( aProtocolo, {'U32_CONTRA'    	, cContrato  } )
					aAdd( aProtocolo, {'U32_CLIENT'    	, cCodCliente } )
					aAdd( aProtocolo, {'U32_LOJA'      	, cLojaCliente } )
					aAdd( aProtocolo, {'U32_NOME'      	, cNomeCliente } )
					aAdd( aProtocolo, {'U32_REFINI'    	, dIniRef } )
					aAdd( aProtocolo, {'U32_REFFIM'   	, dFimRef } )

					If !Empty(cRespEntre)
						aAdd( aProtocolo, {'U32_ENTREG'   	, cRespEntre } )
						aAdd( aProtocolo, {'U32_NOMENT'   	, Posicione("UJB", 1, xFilial("UJB")+cRespEntre, "UJB_NOME" ) } )
					EndIf

					If "1" $ AllTrim(cItensEntrega)	// guia de usuario
						aAdd( aProtocolo, {'U32_GUIA'    , .T. } )
					EndIf

					If "2" $ AllTrim(cItensEntrega) // carteirinha
						aAdd( aProtocolo, {'U32_CARTE'    , .T. } )
					EndIf

					If "3" $ AllTrim(cItensEntrega) .Or. Empty(AllTrim(cItensEntrega)) // outros
						aAdd( aProtocolo, {'U32_OUTROS'    , .T. } )
					EndIf

					aAdd( aProtocolo, {'U32_STATUS'   	, "1" } )

					If !Empty(cDescritivo)
						aAdd( aProtocolo, {'U32_DSCOUT'   	, cDescritivo } )
					EndIf

				EndIf

				If GeraProtocolo(aProtocolos, @aImpProtcolo)

					aProtocolo := {}
					oGrid:aCols[nX][nPosMark] := 'UNCHECKED'

				EndIf

			EndIf

		Next nX

	ElseIf nTipo == 2 // impressao do protocolo em lote

		// percorro os contratos a serem faturados
		For nX := 1 To Len(oGrid:aCols)

			If oGrid:aCols[nX][nPosMark] == 'CHECKED' // pego itens marcados
				cCodigoProt 	:= oGrid:aCols[nX][nPosProtCodigo]
				aAdd(aImpProtcolo, cCodigoProt)
			EndIf

		Next nX

	EndIf

	// faco a impressao em lote
	If Len(aImpProtcolo) > 0
		U_RCPGA28G(aImpProtcolo)
	EndIF

	oDlg:End()

Return(Nil)

/*/{Protheus.doc} GeraProtocolo
Funcao para Gerar Protocolo dos titulos
selecionados na Tela
@author Raphael Martins Garcia
@since 20/08/2019
@type function
/*/
Static Function GeraProtocolo(aProtocolo, aImpProtcolo)

	Local aArea		:= GetArea()
	Local aAreaU32	:= U32->(GetArea())
	Local nX		:= 0
	Local lRet		:= .T.

	DbSelectArea("U32")

	//incluo o cabecalho do protocolo gerado
	RecLock("U32",.T.)

	For nX := 1 To Len(aProtocolo)

		cNomeCampo		:= aProtocolo[nX,1]
		cConteudoCpo	:= aProtocolo[nX,2]
		nPosCampo		:= FieldPos(cNomeCampo)

		FieldPut(nPosCampo,cConteudoCpo)

	Next nX

	U32->(MsUnlock())

	// pego o condigo para impressao em lote
	aAdd(aImpProtcolo, U32->U32_CODIGO )

	U32->(ConfirmSX8()) // confirmo o uso da numeracao

	RestArea(aAreaU32)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} RCPGA28D
Consulta Especifica de Itens de Entrega
(U32ENT)
@type function
@version 1.0
@author g.sampaio
@since 12/12/2022
@return logical, retorno logico da consulta
/*/
User Function RCPGA28D()

	Local aDados	    := {}
	Local aItens      := ""
	Local cTitulo	    := "Itens de Entrega"
	Local cMvParDef	    := ""
	Local cVarIni	    := ""
	Local lRetorno 	    := .T.
	Local nX		    := 1
	Local nTamCod	    := 1

	Static __xxcRetItEnt	    := ""

	// verifico se a variavel ja tem conteudo
	If !Empty(__xxcRetItEnt)

		// limpo o conteudo da variavel
		__xxcRetItEnt := ""

	EndIf

	// alimento o array de dados
	Aadd(aItens, "1 - " + GetSx3Cache("U32_GUIA","X3_TITULO"))
	Aadd(aItens, "2 - " + GetSx3Cache("U32_CARTE","X3_TITULO"))
	Aadd(aItens, "3 - " + GetSx3Cache("U32_OUTROS","X3_TITULO"))

	For nX := 1 To Len(aItens)

		Aadd(aDados, aItens[nX] )
		cMvParDef += SubStr( aItens[nX], 1, 1 )

	Next nX

	If F_Opcoes(@cVarIni, cTitulo, aDados, cMvParDef, 12, 49, .F., nTamCod, 36)

		For nX := 1 To Len(cVarIni) Step nTamCod

			If substr(cVarIni, nX, nTamCod) # Replicate("*", nTamCod)

				If !Empty(__xxcRetItEnt)
					__xxcRetItEnt += ";"
				EndIf

				__xxcRetItEnt += substr(cVarIni,nX,nTamCod)

			EndIf

		Next nX

	EndIf

Return(lRetorno)

User Function RCPGA28E()
Return(__xxcRetItEnt)

/*/{Protheus.doc} RCPGA28F
Impressao de Protocolo em Lote
@type function
@version 1.0
@author g.sampaio
@since 2/12/2024
/*/
User Function RCPGA28F()

	Local cMod				:= ""
	Local cPerg				:= ""
	Local lContinua			:= .T.
	Local lConsulta			:= .T.

	Private __XVEZ 			:= "0"
	Private __ASC       	:= .T.
	Private _nMarca			:= 0

	// pego o modulo logado do sistema
	cMod := U_RetModul()

	// defino o nome do grupo de pergunas
	cPerg := If(cMod=='FUN', "RFUNA28F", 'RCEMA28F')

	// atualizo o grupo de perguntas
	AjustaSX1(cPerg)

	// enquanto o usuário não cancelar a tela de perguntas
	While lContinua

		// chama a tela de perguntas
		lContinua := Pergunte(cPerg,.T.)

		If lContinua

			//consulto titulos de acordo com os parametros informados
			FWMsgRun(,{|oSay| lConsulta := ConsultaDados(cMod, 2) },'Aguarde...','Consultando Protocolos para Impressao...')

			If lConsulta
				FWMsgRun(,{|oSay| MontaTela(cMod, 2) },'Aguarde...','Consultando Protocolos para Impressao em Lote...')
			Else
				Aviso( "", "A Consulta realizada não retornou registros, favor verifique os parametros digitados!", {"Ok"} )
			Endif

		EndIf

	EndDo

Return(Nil)

/*/{Protheus.doc} RCPGA28G
Funcao para realizar a impressao 
do protocolo em lote
@type function
@version 1.0
@author g.sampaio
@since 2/12/2024
@param aImpProtcolo, array, dados de impressao
/*/
User Function RCPGA28G(aImpProtcolo)

	Local aArea 		:= GetArea()
	Local aAreaU32 		:= U32->(GetArea())
	Local nX 			:= 0
	Local nLocalImp		:= 1
	Local nPagImp		:= 0
	Local nPagFim		:= 0
	Local nLinImpBol	:= 0
	Local nPosCodBar	:= 0
	Local oPrinter  	:= TmsPrinter():New("")

	Default aImpProtcolo := {}

	For nX := 1 To Len(aImpProtcolo)

		U32->(DbSetOrder(1))
		If U32->(MsSeek(xFilial("U32")+aImpProtcolo[nX]))

			If nLocalImp == 1

				oPrinter:StartPage()

				nPagFim++

				// posicao do codigo de barras
				nRowCodBar	:= 007.3
				nColCodBar	:= 015

			ElseIf nLocalImp == 2 //Impressao no Meio da Pagina

				nLinImpBol := 1058

				// posicao do codigo de barras
				nRowCodBar	:= 016.3
				nColCodBar	:= 015

			ElseIf nLocalImp == 3 //Impressao na parte Inferior da Pagina

				nLinImpBol 	:= 2136

				// posicao do codigo de barras
				nRowCodBar	:= 025.4
				nColCodBar	:= 015

			EndIf

			// chamo a funcao de impressao de protocolo avulso
			U_IMPAVULSO(nLinImpBol, nPosCodBar, nRowCodBar, nColCodBar, @oPrinter)

			// linha pontilhda de recorte
			oPrinter:Say((1000+nLinImpBol)+55,0063,Replicate("- -",200),,,0)

			// caso for o ultimo boleto a ser impresso
			If nLocalImp == 1
				nLocalImp 	:= 2
			ElseIf nLocalImp == 2
				nLocalImp  := 3
			ElseIf nLocalImp == 3

				//incremento o numero de paginas impressas
				nPagImp++

				// salto a pagina
				nLocalImp 	:= 1
				nLinImpBol	:= 0

				//imprimo o rodape com o controle de paginas
				ImpRodape(@oPrinter,nPagImp)

				// encerro a impressao da pagina
				oPrinter:EndPage()

			EndIf

		EndIf

	Next nX

	If oPrinter <> Nil
		oPrinter:Preview()
	EndIf

	RestArea(aAreaU32)
	RestArea(aArea)

Return(Nil)

///////////////////////////////////////////////////
////// IMPRESSAO DO RODAPE DA PAGINA 	  /////////
//////////////////////////////////////////////////
Static Function ImpRodape(oPrinter,nPagImp)

	Local oFont8	 :=	TFont():New("Arial",,8,,.F.,,,,,.F.,.F.)

	oPrinter:Line(3320,0120,3320,2240)
	oPrinter:Say(3350,0110,"Página: " + StrZero(nPagImp,4) + " - Plataforma Virtus - Protheus",oFont8)

Return(Nil)

