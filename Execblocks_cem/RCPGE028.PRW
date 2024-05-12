#Include 'totvs.ch'
#Include "topconn.ch"
#Include "FWBrowse.ch"

/////////////////////////////////////////////////////////////////
////////////// POSICOES DO ARRAY aEndereco  	////////////////
///////////////////////////////////////////////////////////////
#Define P_QUADRA		1	//Quadra
#Define P_MODULO		2	//Modulo
#Define P_JAZIGO		3	//Jazigo
#Define P_OSSARIO		4	//Ossario
#Define P_NICHOO		5	//Nicho Ossario

/*/{Protheus.doc} RCPGE028
Tela de Enderecamento Previo
@author Raphael Martins 
@since 06/02/2020
@version P12
@param nulo
@return nulo
/*/

User Function RCPGE028(cCodContrato)

	Local aEndereco 		:= {"","","","",""}
	Local aParamBox			:= {}
	Local cTipoEnd			:= ""
	Local lContinua     	:= .T.
	Local lRet 				:= .T.
	Local oPnlInfo			:= NIL
	Local oPnlQuadra		:= NIL
	Local oPnlModulo		:= NIL
	Local oPnlJazigo		:= NIL
	Local oPnlOssa			:= NIL
	Local oPnlNOssa			:= NIL
	Local oBrwQ				:= NIL
	Local oBrwM				:= NIL
	Local oBrwJ				:= NIL
	Local oBrwO				:= NIL
	Local oBrwNO			:= NIL
	Local oNewPag			:= NIL
	Local oStepWiz  		:= Nil
	Local oDlg     			:= Nil

	Default cCodContrato    := ""

	// verifico se o existe o ponto de entrada para mensagem de alerta antes do enderecamento
	if ExistBlock("ALERTEND")
		U_ALERTEND(cCodContrato)
	endIf

	// posiciono no contrato
	U00->(DbSetOrder(1))
	if U00->(MsSeek(xFilial("U00")+cCodContrato))

		Do Case

		Case U00->U00_STATUS == "P" //Pré-cadastro
			MsgInfo("O Contrato se encontra pré-cadastrado, operação não permitida.","Atenção")
			lContinua := .F.

		Case U00->U00_STATUS == "C" //Cancelado
			MsgInfo("O Contrato se encontra Cancelado, operação não permitida.","Atenção")
			lContinua := .F.

		Case U00->U00_STATUS == "S" //Suspenso
			MsgInfo("O Contrato se encontra Suspenso, operação não permitida.","Atenção")
			lContinua := .F.

		Case ExigTxManu(U00->U00_PLANO) .And. U00->U00_TXMANU <= 0 //contrato sem taxa de manutencao
			MsgAlert("O Contrato não possui valor de taxa de manutenção definido, operação não permitida.","Atenção")
			lContinua := .F.

		EndCase

		aParamBox := DefTipoEndereco()

		lContinua := aParamBox[1]

		cTipoEnd	:= aParamBox[2][1]
		// verifico se esta tudo certo
		if lContinua

			U04->(DbSetOrder(1))

			DEFINE DIALOG oDlg TITLE 'Endereçamento Prévio' PIXEL

			oDlg:nWidth := 700
			oDlg:nHeight:= 500

			//crio panel do wizard
			oPanelBkg:= TPanel():New(0,0,"",oDlg,,,,,,300,300)
			oPanelBkg:Align := CONTROL_ALIGN_ALLCLIENT
			oStepWiz    := FWWizardControl():New(oPanelBkg)

			oStepWiz:ActiveUISteps()

			// Pagina 1
			oNewPag := oStepWiz:AddStep("1")
			oNewPag:SetStepDescription("Instrucoes Iniciais")
			oNewPag:SetConstruction({|oPnlInfo| Pag1Intrucoes(oPnlInfo) })
			oNewPag:SetNextAction({||.T.})
			oNewPag:SetCancelAction({||.T.,oDlg:End()})

			if cTipoEnd == "J"
				/////////////////////////////////////////////////////////////
				////////////////            QUADRA              ////////////
				/////////////////////////////////////////////////////////////

				oNewPag := oStepWiz:AddStep("2")
				oNewPag:SetStepDescription("Quadra")
				oNewPag:SetConstruction({|oPnlQuadra| FwEndereca(oPnlQuadra,@oBrwQ,"QU08",aEndereco,cCodContrato)})
				oNewPag:SetNextAction({|| lRet := ValProxTela("QU08",aEndereco,oBrwM,cCodContrato) })
				oNewPag:SetCancelAction({||lRet := .F.,oDlg:End()})

				/////////////////////////////////////////////////////////////
				////////////////            MODULO              ////////////
				/////////////////////////////////////////////////////////////

				oNewPag := oStepWiz:AddStep("3", {|oPnlModulo| FwEndereca(oPnlModulo,@oBrwM,"QU09",aEndereco,cCodContrato)})
				oNewPag:SetStepDescription("Modulo")
				oNewPag:SetNextAction({||ValProxTela("QU09",aEndereco,oBrwJ)})
				oNewPag:SetCancelAction({||lRet := .F.,oDlg:End()})

				/////////////////////////////////////////////////////////////
				////////////////            JAZIGO              ////////////
				/////////////////////////////////////////////////////////////

				oNewPag := oStepWiz:AddStep("4", {|oPnlJazigo| FwEndereca(oPnlJazigo,@oBrwJ,"QU10",aEndereco,cCodContrato)})
				oNewPag:SetStepDescription("Jazigo")
				oNewPag:SetNextAction({||lRet := ValProxTela("QU10",aEndereco),oDlg:End() })
				oNewPag:SetCancelWhen({||.F.})
				oNewPag:SetCancelAction({||lRet := .F.,oDlg:End()})

			else

				/////////////////////////////////////////////////////////////
				////////////////            OSSARIO              ////////////
				/////////////////////////////////////////////////////////////

				oNewPag := oStepWiz:AddStep("2")
				oNewPag:SetStepDescription("Ossario")
				oNewPag:SetConstruction({|oPnlOssa| FwEndereca(oPnlOssa,@oBrwO,"QU13",aEndereco,cCodContrato)})
				oNewPag:SetNextAction({|| lRet := ValProxTela("QU13",aEndereco,oBrwNO) })
				oNewPag:SetCancelAction({||lRet := .F. ,oDlg:End()})

				/////////////////////////////////////////////////////////////
				////////////////      	NICHO OSSARIO            ////////////
				/////////////////////////////////////////////////////////////

				oNewPag := oStepWiz:AddStep("3", {|oPnlNOssa| FwEndereca(oPnlNOssa,@oBrwNO,"QU14",aEndereco,cCodContrato)})
				oNewPag:SetStepDescription("Nicho Columbario")
				oNewPag:SetNextAction({|| lRet := ValProxTela("QU14",aEndereco),oDlg:End() })
				oNewPag:SetCancelAction({||lRet := .F. ,oDlg:End()})
				oNewPag:SetCancelWhen({||.F.})

			endif

			oStepWiz:Activate()
			ACTIVATE DIALOG oDlg CENTER'
			oStepWiz:Destroy()

		else
			lRet := .F.

		endIf

	else
		lRet := .F.
		MsgAlerT("Não foi possível posicionar no contrato!")

	endIf

Return(lRet)

/*/{Protheus.doc} InfoParam
Função que mostra tela de parametros
@type function
@version 1.0 
@author Raphael Martins
@since 02/04/2023
@return logical,Confirmado a tela de parametros
/*/
Static Function DefTipoEndereco()

	Local lRet 			:= .T.
	Local aPergs 		:= {}
	Local aRetPar 		:= {}
	Local cTipo			:= "J"

	aAdd(aPergs, {2, "Tipo Endereçamento",cTipo, {"J=Jazigo","O=Ossario"},90, ".T.", .F.})

	If !ParamBox(aPergs,"",@aRetPar,{|| .T.})
		lRet := .F.
	endif

Return({lRet,aRetPar})

/*/{Protheus.doc} RCPGE025
Monta tela para Enderecamento de Jazigo
@author Raphael Martins 
@since 06/11/2019
@version P12
@param nulo
@return nulo
/*/
Static Function FwEndereca(oPanel,oBrowse,cAlias,aEndereco,cCodContrato)

	Local oBtnPanel := TPanel():New(0,0,"",oPanel,,,,,,40,40)

	oBtnPanel:Align := CONTROL_ALIGN_ALLCLIENT

	// Cria tabela temporaria que vai conter os dADOS
	CriaTabTemp(cAlias,aEndereco,cCodContrato)

	// Define o Browse
	oBrowse := FWBrowse():New(oBtnPanel)
	oBrowse:SetDataTable(.T.)
	oBrowse:SetAlias(cAlias)
	oBrowse:DisableReport()

	if cAlias == "QU08"// quadra

		// Cria uma coluna de marca/desmarca
		oColumn := oBrowse:AddMarkColumns({||If( QU08->U08_OK == 'T','LBOK','LBNO')},{|oBrowse| MarkBrowse( oBrowse,cAlias,"U08_OK" ) },{|oBrowse|/* Função de HEADERCLICK*/})

		ADD COLUMN oColumn DATA { || U08_CODIGO } TITLE Alltrim(GetSx3Cache("U08_CODIGO","X3_TITULO")) SIZE TamSx3("U08_CODIGO")[1] OF oBrowse
		ADD COLUMN oColumn DATA { || U08_DESC   } TITLE Alltrim(GetSx3Cache("U08_DESC"  ,"X3_TITULO")) SIZE TamSx3("U08_DESC")[1]   OF oBrowse

	elseif cAlias == "QU09"// modulo

		oColumn := oBrowse:AddMarkColumns({||If( QU09->U09_OK == 'T','LBOK','LBNO')},{|oBrowse| MarkBrowse( oBrowse,cAlias,"U09_OK" ) },{|oBrowse|/* Função de HEADERCLICK*/})

		ADD COLUMN oColumn DATA { || U09_CODIGO } TITLE Alltrim(GetSx3Cache("U09_CODIGO","X3_TITULO")) SIZE TamSx3("U09_CODIGO")[1] OF oBrowse
		ADD COLUMN oColumn DATA { || U09_DESC   } TITLE Alltrim(GetSx3Cache("U09_DESC"  ,"X3_TITULO")) SIZE TamSx3("U09_DESC")[1]   OF oBrowse

	elseif cAlias == "QU10"// jazigo

		oColumn := oBrowse:AddMarkColumns({||If( QU10->U10_OK == 'T','LBOK','LBNO')},{|oBrowse| MarkBrowse( oBrowse,cAlias,"U10_OK" ) },{|oBrowse|/* Função de HEADERCLICK*/})

		ADD COLUMN oColumn DATA { || U10_CODIGO } TITLE Alltrim(GetSx3Cache("U10_CODIGO","X3_TITULO")) SIZE TamSx3("U10_CODIGO")[1] OF oBrowse
		ADD COLUMN oColumn DATA { || U10_DESC   } TITLE Alltrim(GetSx3Cache("U10_DESC"  ,"X3_TITULO")) SIZE 30   OF oBrowse
		ADD COLUMN oColumn DATA { || U10_QTDGAV } TITLE Alltrim(GetSx3Cache("U10_QTDGAV","X3_TITULO")) SIZE TamSx3("U10_QTDGAV")[1]   OF oBrowse

	elseif cAlias == "QU13"

		oColumn := oBrowse:AddMarkColumns({||If( QU13->U13_OK == 'T','LBOK','LBNO')},{|oBrowse| MarkBrowse( oBrowse,cAlias,"U13_OK" ) },{|oBrowse|/* Função de HEADERCLICK*/})

		ADD COLUMN oColumn DATA { || U13_CODIGO } TITLE Alltrim(GetSx3Cache("U13_CODIGO","X3_TITULO")) SIZE TamSx3("U13_CODIGO")[1] OF oBrowse
		ADD COLUMN oColumn DATA { || U13_DESC   } TITLE Alltrim(GetSx3Cache("U13_DESC"  ,"X3_TITULO")) SIZE TamSx3("U13_DESC")[1]   OF oBrowse

	elseif cAlias == "QU14"

		oColumn := oBrowse:AddMarkColumns({||If( QU14->U14_OK == 'T','LBOK','LBNO')},{|oBrowse| MarkBrowse( oBrowse,cAlias,"U14_OK" ) },{|oBrowse|/* Função de HEADERCLICK*/})

		ADD COLUMN oColumn DATA { || U14_CODIGO } TITLE Alltrim(GetSx3Cache("U14_CODIGO","X3_TITULO")) SIZE TamSx3("U14_CODIGO")[1] OF oBrowse
		ADD COLUMN oColumn DATA { || U14_DESC   } TITLE Alltrim(GetSx3Cache("U14_DESC"  ,"X3_TITULO")) SIZE TamSx3("U14_DESC")[1]   OF oBrowse

	endif

	oBrowse:SetSeek()
	oBrowse:Activate()

Return

/*/{Protheus.doc} Pag1Intrucoes
Instrucoes Iniciais do Wizard de Processametno
@author Raphael Martins Garcia 
@since 06/02/2020
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function Pag1Intrucoes(oPanel)

	Local oSay1 		:= NIL
	Local oFnt18		:= TFont():New("Arial",,18,,.T.,,,,,.F.,.F.)
	Local oFnt16		:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
	Local cPulaLinha	:= Chr(13) + Chr(10)
	Local cTexto1		:= ""

	//crio a parte superior da tela do wizard
	CriaPartSup(oPanel)

	@ 045 , 020 SAY oSay4 PROMPT "Bem Vindo..." SIZE 200, 010 Font oFnt18 OF oPanel COLORS 0, 16777215 PIXEL

	cTexto1 += "Esta rotina tem como objetivo ajuda-lo realizar o enderecamento prévio" + cPulaLinha

	@ 065 , 020 SAY oSay1 PROMPT cTexto1 SIZE 300, 300 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

Return()

/*/{Protheus.doc} Pag2Layout
Cria parte superior do panel do
wizard com a logo e texto explicativo
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function CriaPartSup(oPanel)

	Local oSay1 		:= NIL
	Local oSay2 		:= NIL
	Local oSay3 		:= NIL
	Local oLgTotvs		:= NIL
	Local oGroup1		:= NIL
	Local oFnt18		:= TFont():New("Arial",,18,,.T.,,,,,.F.,.F.)
	Local oFnt16		:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
	Local nLarguraPnl	:= oPanel:nClientWidth / 2


//carrego a imagem do repositorio 
	@ 003, 003 REPOSITORY oLgTotvs SIZE 90, 90 OF oPanel PIXEL NOBORDER
	oLgTotvs:LoadBmp("APLOGO.JPG")

	@ 005 , 055 SAY oSay1 PROMPT "Atenção!" SIZE 060, 010 Font oFnt18 OF oPanel COLORS 0, 16777215 PIXEL

	@ 020 , 055 SAY oSay2 PROMPT "Siga atentamente os passos para realizar:" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

	@ 030 , 055 SAY oSay3 PROMPT "o endereçamento prévio." SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

	@ 040 , 020 GROUP oGroup1 TO 042 , nLarguraPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL


Return()

/*/{Protheus.doc} Pag2Layout
Marca e descarma Browse
@author Leandro Rodrigues
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

Static Function MarkBrowse(oBrowse,cAlias,cCampo)

	Local lRet 	   := .T.
	Local nPosAtu  := oBrowse:At()
	Local aArea	   := (cAlias)->(GetArea())

	(cAlias)->(DbSetOrder(2))

//Valido se tem algum item ja marcado
	if (cAlias)->(DbSeek("T"))

		//Desmarco item
		Reclock(cAlias,.F.)
		(cAlias)->&(cCampo) := ' '
		(cAlias)->(MsUnLock())

	endif

//Posiciona na linha que estava
	oBrowse:GoTo(nPosAtu)

//Marca item
	Reclock(cAlias,.F.)
	(cAlias)->&(cCampo) := 'T'
	(cAlias)->(MsUnLock())

	(cAlias)->(DbSetOrder(1))

	oBrowse:Refresh()

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} CriaTabTemp
Cria Tabela temporaria
@type function
@version 1.0 
@author raphaelgarcia
@since 4/2/2023
@param cAlias, character, Alias selecionada
@param aEndereco, array, endereco para carregar enderecos
@param cCodContrato, character, codigo do contrato
/*/
Static Function CriaTabTemp(cAlias,aEndereco,cCodContrato)

	Local oTable 			:= Nil
	Local aCampos			:= {}
	Local cIndice1			:= ""
	Local cIndice2			:= ""

	Default cAlias			:= ""
	Default aEndereco		:= {}
	Default cCodContrato	:= ""

	if cAlias == "QU08"// modulo

		aCampos:= {	{"U08_OK"		,"C",001,0},;
			{"U08_CODIGO"	,"C",TamSX3("U08_CODIGO")[1],0},;
			{"U08_DESC" 	,"C",TamSX3("U08_DESC")[1],0} }

		cIndice1 := "U08_CODIGO"
		cIndice2 := "U08_OK"

	elseif cAlias == "QU09"// quadra

		aCampos:= {	{"U09_OK"		,"C",001,0},;
			{"U09_CODIGO"	,"C",TamSX3("U09_CODIGO")[1],0},;
			{"U09_DESC"		,"C",TamSX3("U09_DESC")[1],0} }

		cIndice1 := "U09_CODIGO"
		cIndice2 := "U09_OK"

	elseif cAlias == "QU10"// jazigo

		aCampos:= {	{"U10_OK"		,"C",001,0},;
			{"U10_CODIGO"	,"C",TamSX3("U10_CODIGO")[1],0},;
			{"U10_DESC"		,"C",TamSX3("U10_DESC")[1],0},;
			{"U10_QTDGAV"	,"N",TamSX3("U10_QTDGAV")[1],0}}

		cIndice1 := "U10_CODIGO"
		cIndice2 := "U10_OK"

		//##################################################################
		//					ENDERECAMENTO CREMATORIO
		//##################################################################
	elseif cAlias == "QU13"


		aCampos:= {	{"U13_OK"		,"C",001,0},;
			{"U13_CODIGO"	,"C",TamSX3("U13_CODIGO")[1],0},;
			{"U13_DESC" 	,"C",TamSX3("U13_DESC")[1],0} }

		cIndice1 := "U13_CODIGO"
		cIndice2 := "U13_OK"

	elseif cAlias == "QU14"

		aCampos:= {	{"U14_OK"		,"C",001,0},;
			{"U14_CODIGO"	,"C",TamSX3("U14_CODIGO")[1],0},;
			{"U14_DESC" 	,"C",TamSX3("U14_DESC")[1],0} }

		cIndice1 := "U14_CODIGO"
		cIndice2 := "U14_OK"

	endif

	//Valida se ja existe a tabela criada
	if Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	endif

	oTable:= FWTemporaryTable():New(cAlias)

	//Inserindo campos no alias temporario
	oTable:SetFields(aCampos)

	//---------------------
	//Criação dos índices
	//---------------------
	oTable:AddIndex("01", { cIndice1	} )
	oTable:AddIndex("02", { cIndice2	} )

	//---------------------------------------------------------------
	//tabela criado no espaço temporário do DB
	//---------------------------------------------------------------
	oTable:Create()
	//------------------------------------

	//Carrega dados na tebela temporaria
	GetTabTemp(cAlias,aEndereco,cCodContrato)

Return(Nil)

/*/{Protheus.doc} GetTabTemp
Rotina para carregar Tabela temporaria
@type function
@version 1.0 
@author raphaelgarcia
@since 4/2/2023
@param cAlias, character, Alias selecionada
@param aEndereco, array, array com os enderecos carregados
@param cCodContrato, character, Codigo do contrato
/*/
Static Function GetTabTemp(cAlias,aEndereco,cCodContrato)

	Local cQry 				:= ""
	Local cQuadQry			:= ""

	Default cAlias			:= ""
	Default aEndereco		:= {}
	Default cCodContrato	:= ""

	//Pega dados da Quadra
	If cAlias == "QU08"

		cQry := " SELECT"
		cQry += " 	U08_CODIGO,"
		cQry += " 	U08_DESC"
		cQry += " FROM " + RetSQLName("U08") + " U08"
		cQry += " WHERE U08.D_E_L_E_T_ = ' '"
		cQry += " 	AND U08_FILIAL = '"+ xFilial("U08") + "'"
		cQry += " 	AND U08_STATUS = 'S'"

		// ponto de entrada para tratar filtros especificos de quadra
		if ExistBlock("QUADQRY")

			// pego o fitro de quadra especifico
			cQuadQry := U_QUADQRY(cCodContrato)

			// verifico se a variavel tem conteudo
			if !Empty(cQuadQry)
				cQry += cQuadQry
			endIf

		endIf

		cQry += " 	ORDER BY  U08_CODIGO"

		cQry := ChangeQuery(cQry)

		if Select("TR08") > 0
			TR08->(DbCloseArea())
		endif

		TcQuery cQry New Alias "TR08"

		While TR08->(!EOF())

			Reclock("QU08",.T.)

			QU08->U08_OK 		:= " "
			QU08->U08_CODIGO	:= TR08->U08_CODIGO
			QU08->U08_DESC		:= TR08->U08_DESC

			QU08->(MsUnLock())

			TR08->(DbSkip())
		EndDo

		//Pega dados da Modulo
	elseIf cAlias == "QU09"

		cQry := " SELECT"
		cQry += " 	U09_CODIGO,"
		cQry += " 	U09_DESC"
		cQry += " FROM " + RetSQLName("U09") + " U09"
		cQry += " WHERE U09.D_E_L_E_T_ = ' '"
		cQry += " 	AND U09_FILIAL = '"+ xFilial("U09") + "'"
		cQry += " 	AND U09_STATUS = 'S'"
		cQry += " 	AND U09_QUADRA = '" + aEndereco[P_QUADRA] + "'"
		cQry += " 	ORDER BY U09_CODIGO"

		cQry := ChangeQuery(cQry)

		if Select("TR09") > 0
			TR09->(DbCloseArea())
		endif

		TcQuery cQry New Alias "TR09"

		While TR09->(!EOF())

			Reclock("QU09",.T.)

			QU09->U09_OK 		:= " "
			QU09->U09_CODIGO	:= TR09->U09_CODIGO
			QU09->U09_DESC		:= TR09->U09_DESC

			QU09->(MsUnLock())

			TR09->(DbSkip())
		EndDo

		//Pega dados da Jazigo
	elseIf cAlias == "QU10"

		SB1->(DbSetOrder(1))

		cQry := " SELECT"
		cQry += " 	U10.U10_CODIGO,"
		cQry += " 	U10.U10_DESC,"
		cQry += "   U10.U10_QTDGAV, "
		cQry += "   U09.U09_QTDGAV, "
		cQry += "   U08.U08_QTDGAV "
		cQry += " FROM " + RetSQLName("U10") + " U10 "
		cQry += " INNER JOIN " + RetSQLName("U09") + " U09 ON U09.D_E_L_E_T_ = ' ' "
		cQry += " 	AND U09.U09_QUADRA = U10.U10_QUADRA "
		cQry += " 	AND U09.U09_CODIGO = U10.U10_MODULO "
		cQry += " INNER JOIN " + RetSQLName("U08") + " U08 ON U08.D_E_L_E_T_ = ' ' "
		cQry += " 	AND U08.U08_CODIGO = U10.U10_QUADRA "
		cQry += " WHERE U10.D_E_L_E_T_ = ' '"
		cQry += " 	AND U10.U10_FILIAL = '"+ xFilial("U10") + "'"
		cQry += " 	AND U10.U10_STATUS = 'S'"
		cQry += " 	AND U10.U10_QUADRA = '" +  aEndereco[P_QUADRA] + "'"
		cQry += " 	AND U10.U10_MODULO = '" +  aEndereco[P_MODULO] + "'"
		cQry += "   AND U10.U10_CODIGO NOT IN ( SELECT "
		cQry += " 							        U04.U04_JAZIGO "
		cQry += " 							    FROM " + RetSQLName("U04") + " U04 "
		cQry += " 							    WHERE D_E_L_E_T_ =' '"
		cQry += " 							    AND U04.U04_FILIAL = '" + xFilial("U04") + "'"
		cQry += " 							    AND U04.U04_TIPO    = 'J' "
		cQry += "                               AND U04.U04_QUADRA  = U10.U10_QUADRA "
		cQry += "                               AND U04.U04_MODULO  = U10.U10_MODULO "
		cQry += " 							    GROUP BY U04_JAZIGO )"
		cQry += " 	ORDER BY U10.U10_CODIGO"

		// compatilidade de query com o banco corrente
		cQry := ChangeQuery(cQry)

		if Select("TR10") > 0
			TR10->(DbCloseArea())
		endif

		TcQuery cQry New Alias "TR10"

		// verifico se o alias tem registros
		If TR10->(!Eof())

			While TR10->(!EOF())

				Reclock("QU10",.T.)

				QU10->U10_OK 		:= " "
				QU10->U10_CODIGO	:= TR10->U10_CODIGO
				QU10->U10_DESC		:= TR10->U10_DESC

				//======================================================
				// exibe a quantidade de gavetas na seguinte hierarquia
				// J - Quantidade do Jazigo
				// M - Quantidade do Modulo
				// Q - Quantidade da Quadra
				// U - Quantidade do parametro MV_XQTDGVJ
				//======================================================

				If TR10->U10_QTDGAV > 0
					QU10->U10_QTDGAV	:= TR10->U10_QTDGAV
				ElseIf TR10->U09_QTDGAV > 0
					QU10->U10_QTDGAV	:= TR10->U09_QTDGAV
				ElseIf TR10->U08_QTDGAV > 0
					QU10->U10_QTDGAV	:= TR10->U08_QTDGAV
				Else
					QU10->U10_QTDGAV	:= SuperGetMv("MV_XQTDGVJ",.F.,3)
				EndIf

				QU10->(MsUnLock())

				TR10->(DbSkip())
			EndDo

		Else// caso nao houver retorno mensagem

			// mensagem para o usuario
			Help(,,'Help',,"Não existem jazigos disponiveis para endereçamento, na quadra <"+ aEndereco[P_QUADRA] +"> " + ;
				"e módulo <"+ aEndereco[P_MODULO] +"> que foram selecionados, volte a tela anterior e " + ;
				"selecione outro módulo, ou quadra!",1,0)

		EndIf
		//##################################################################
		//					ENDERECAMENTO OSSARIO
		//##################################################################
	elseif cAlias == "QU13"

		cQry := " SELECT "
		cQry += " 	U13_CODIGO CODIGO, "
		cQry += " 	U13_DESC   DESCRICAO "
		cQry += " FROM " + RETSQLNAME("U13") + " U13 "
		cQry += " WHERE U13.D_E_L_E_T_ = ' ' "
		cQry += " 	AND U13_FILIAL = '"+ xFilial("U13") + "' "
		cQry += " 	AND U13_STATUS = 'S' "
		cQry += " 	AND U13_TPOSS <> '2' "

		cQry := ChangeQuery(cQry)

		if Select("TR13") > 0
			TR13->(DbCloseArea())
		endif

		TcQuery cQry New Alias "TR13"

		While TR13->(!EOF())

			Reclock("QU13",.T.)

			QU13->U13_OK 		:= " "
			QU13->U13_CODIGO	:= TR13->CODIGO
			QU13->U13_DESC		:= TR13->DESCRICAO

			QU13->(MsUnLock())

			TR13->(DbSkip())
		EndDo

	elseif cAlias == "QU14"

		///////////////////////////////////////////////////////////////////////
		///////////////// CONSULTO NICHOS COM CAPACIDADE DISPONIVEL //////////
		//////////////////////////////////////////////////////////////////////
		cQry := " SELECT "
		cQry += " U14_CODIGO, "
		cQry += " U14_DESC "
		cQry += " FROM "
		cQry += RetSQLName("U14") + " U14 "
		cQry += " WHERE U14.D_E_L_E_T_ = ' ' "
		cQry += " 	AND U14_FILIAL = '" + xFilial("U14") + "'
		cQry += " 	AND U14_STATUS = 'S' "
		cQry += " 	AND U14_OSSARI = '" + aEndereco[P_OSSARIO] + "'  "
		cQry += " 	AND U14_CAPACI > (SELECT  "
		cQry += " 						COUNT(*) UTILIZADO "
		cQry += " 						FROM "
		cQry +=  						RetSQLName("U04") + " U04 "
		cQry += " 							WHERE "
		cQry += " 							U04.D_E_L_E_T_ = ' ' "
		cQry += " 							AND U04.U04_FILIAL = '" + xFilial("U04") + "'
		cQry += " 							AND U04.U04_TIPO = 'O' "
		cQry += " 							AND U04.U04_OSSARI = U14.U14_OSSARI "
		cQry += " 							AND U04.U04_NICHOO = U14.U14_CODIGO) "
		cQry += " ORDER BY U14_CODIGO "

		cQry := ChangeQuery(cQry)

		if Select("TR14") > 0
			TR14->(DbCloseArea())
		endif

		TcQuery cQry New Alias "TR14"

		While TR14->(!EOF())

			Reclock("QU14",.T.)

			QU14->U14_OK 		:= " "
			QU14->U14_CODIGO	:= TR14->U14_CODIGO
			QU14->U14_DESC		:= TR14->U14_DESC

			QU14->(MsUnLock())

			TR14->(DbSkip())
		EndDo

	endif

Return(Nil)

/*/{Protheus.doc} ValProxTela
Rotina para validar se permite avancar
@author Leandro Rodrigues
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function ValProxTela(cAlias,aEndereco,oGrid,cCodContrato)

	Local aArea	   			:= (cAlias)->(GetArea())
	Local lRet	   			:= .T.

	Default cAlias			:= ""
	Default aEndereco		:= {}
	Default cCodContrato	:= ""

	(cAlias)->(DbSetOrder(2))

	//Valido se tem algum item ja marcado
	if !(cAlias)->(DbSeek("T"))

		Aviso("Atenção","É necessário marcar um item pra prosseguir!",{"Ok"})
		lRet := .F.
	else

		//===========================================
		//Enderecamento Jazigo
		//===========================================
		if cAlias == "QU08"// quadra

			aEndereco[P_QUADRA] := (cAlias)->U08_CODIGO

			if Select("QU09") > 0 .And. oGrid <> NIL

				CriaTabTemp("QU09",aEndereco,cCodContrato)

				oGrid:Refresh(.T.)

			endif

		elseif cAlias == "QU09"// modulo

			aEndereco[P_MODULO] := (cAlias)->U09_CODIGO

			if Select("QU10") > 0 .And. oGrid <> NIL

				CriaTabTemp("QU10",aEndereco)

				oGrid:Refresh(.T.)

			endif

		elseif cAlias == "QU10"// jazigo

			aEndereco[P_JAZIGO] := (cAlias)->U10_CODIGO

			ConfirmaEndereco(aEndereco)
			//=======================\====================
			//Enderecamento OSSARIO
			//===========================================
		elseif cAlias == "QU13"

			aEndereco[P_OSSARIO]  := (cAlias)->U13_CODIGO

			if Select("QU14") > 0 .And. oGrid <> NIL

				CriaTabTemp("QU14",aEndereco)

				oGrid:Refresh(.T.)

			endif

		elseif cAlias == "QU14"

			aEndereco[P_NICHOO]  := (cAlias)->U14_CODIGO
			ConfirmaEndereco(aEndereco)

		endif

	endif

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} ConfirmaEndereco
Funcao para confirmar o enderecamento
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function ConfirmaEndereco(aEndereco)

	Local aArea             := GetArea()
	Local lRet              := .T.
	Local lAtivaRegra	    := SuperGetMv("MV_XREGCEM",,.F.)	// parametro para ativacao da regra
	Local oRegraManutencao  := Nil

	if MsgYesNo("Confirma a inclusão do endereçamento prévio?")

		RecLock("U04",.T.)

		U04->U04_FILIAL := xFilial("U04")
		U04->U04_CODIGO	:= U00->U00_CODIGO
		U04->U04_ITEM	:= StrZero(1,3)
		U04->U04_TIPO	:= if(!Empty(aEndereco[1]),"J","O")
		U04->U04_QUADRA	:= aEndereco[P_QUADRA]
		U04->U04_MODULO	:= aEndereco[P_MODULO]
		U04->U04_JAZIGO	:= aEndereco[P_JAZIGO]
		U04->U04_GAVETA	:= StrZero(1,2)
		U04->U04_CREMAT	:= ""
		U04->U04_NICHOC	:= ""
		U04->U04_OSSARI	:= aEndereco[P_OSSARIO]
		U04->U04_NICHOO	:= aEndereco[P_NICHOO]
		U04->U04_DATA	:= dDataBase
		U04->U04_DTUTIL	:= CToD("")
		U04->U04_QUEMUT	:= ""
		U04->U04_PRZEXU	:= CToD("")
		U04->U04_PREVIO	:= "S"
		U04->U04_OCUPAG := "S"
		U04->U04_LOCACA	:= "N"

		U04->(MsUnlock())

		// verifico se utilizo regra de contrato
		if !Empty(aEndereco[1]) .And. lAtivaRegra // verifico se e jazigo e utilizo regra

			// inicio o ojeto de Regras de Manutencao
			oRegraManutencao    := RegraTaxaManutencao():New( U00->U00_REGRA, "E" )

			// caso tenha regra de taxa de manutencao preenchida no contrato
			if oRegraManutencao:lTemRegra

				// vou validar a execucao do contrato
				// mensagem de processamento para o usuario
				FWMsgRun(,{|oSay| lRetorno := oRegraManutencao:ValidaRegra( U00->U00_CODIGO, Nil, .T. ) },"Aguarde","Gerando Taxa de Manutenção no endereçamento prévio do contrato...")

			endIf

			// fecho objeto
			FreeObj(oRegraManutencao)
			oRegraManutencao := Nil

		EndIf

		MsgInfo("Endereçamento Prévio realizado com sucesso!")

	endif

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} RCPGE28E
Funcao para excluir o enderecamento previo
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RCPGE28E()

	Local aArea             := GetArea()
	Local aAreaU00          := U00->(GetArea())
	Local aAreaU04          := U04->(GetArea())
	Local aDadosEndPrevio   := {}
	Local aRetorno 			:= {}
	Local lAtivaRegra	    := SuperGetMv("MV_XREGCEM",,.F.)	// parametro para ativacao da regra
	Local lRet              := .T.
	Local lPossuiJazigo		:= .F.
	Local nX				:= 0

	//retorna os enderecos do contrato

	aRetorno := BuscaPreviosEnd( U00->U00_CODIGO)
	aDadosEndPrevio := aRetorno[1]
	lPossuiJazigo	:= aRetorno[2]

	//caso possua jazigo
	if Len(aDadosEndPrevio) > 0

		if MsgYesNo("Deseja Excluir o endereçamento prévio realizado?")

			BEGIN TRANSACTION

				For nX := 1 To Len(aDadosEndPrevio)

					U04->(DbGoto(aDadosEndPrevio[nX]))

					RecLock("U04",.F.)

					U04->(DbDelete())

					U04->(MsUnlock() )


				Next nX

				// verifico se utilizo regra de contrato
				if lPossuiJazigo .And. lAtivaRegra // verifico se e jazigo e utilizo regra

					// inicio o ojeto de Regras de Manutencao
					oRegraManutencao    := RegraTaxaManutencao():New( U00->U00_REGRA, "E" )

					// caso tenha regra de taxa de manutencao preenchida no contrato
					if oRegraManutencao:ValidaManutencao( U00->U00_CODIGO )

						// vou validar a execucao do contrato
						lRet := oRegraManutencao:ExcluiManutencao( Stod(""), Stod(""), U00->U00_CODIGO, U00->U00_CODIGO, "", "", "E" )

					endIf

					// fecho objeto
					FreeObj(oRegraManutencao)
					oRegraManutencao := Nil

				EndIf

				// caso tiver um problema desafaco a transacaso
				If !lRet
					DisarmTransaction()
				EndIf

			END TRANSACTION

			If lRet
				MsgInfo("Endereçamento excluido com sucesso!")
			Else
				MsgAlert("Nao foi possivel excluir o endereçamento prévio!")
			endIf

		endif

	else

		MsgAlert("O Contrato selecionado não possui endereçamento prévio!")

		lRet := .F.

	endif

	RestArea(aAreaU04)
	RestArea(aAreaU00)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} BuscaPreviosEnd
Busca enderecamento previo do contrato para deletar
@type function
@version 1.0 
@author raphaelgarcia
@since 4/2/2023
@param cContrato, character, Codigo do Contrato
@return Array, aRecnos -  Enderecamentos previos do contrato
/*/
Static Function BuscaPreviosEnd(cContrato)

	Local cQuery	:= ""
	Local aRecnos	:= {}
	Local lJazigo	:= .F.

	If Select("TRBJAZ") > 0
		TRBJAZ->( DbCloseArea() )
	EndIf

// query para buscar os endereço do contrato
	cQuery := " SELECT "
	cQuery += " R_E_C_N_O_	REGISTRO, "
	cQuery += " U04_TIPO	TIPO "
	cQuery += " FROM " + RetSQLName("U04") + " U04 "
	cQuery += " WHERE U04.D_E_L_E_T_ = ' ' "
	cQuery += " AND U04.U04_FILIAL = '" + xFilial("U04") + "'	"
	cQuery += " AND U04.U04_CODIGO = '" + cContrato + "' "
	cQuery += " AND U04_QUEMUT = ' ' "
	cQuery += " AND U04_PREVIO = 'S' "

	cQuery := ChangeQuery(cQuery)

	TcQuery cQuery New Alias "TRPREV"

	While TRPREV->(!Eof())

		Aadd(aRecnos,TRPREV->REGISTRO)

		if TRPREV->TIPO == "J"

			lJazigo := .T.

		endif

		TRPREV->(DbSkip())
	Enddo

Return({aRecnos,lJazigo})

/*/{Protheus.doc} RCPGA040
Rotina para verificar se Plano exige 
preenchimento de taxa de manutencao
@author Leandro Rodrigues
@since 16/12/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

Static Function ExigTxManu( cPlanoCtr )

	Local aArea			:= GetArea()
	Local aAreaU00		:= U00->( GetArea() )
	Local aAreaU05		:= U05->( GetArea() )
	Local lExigeTxMnt	:= .F.

	U05->( DbSetOrder(1) ) //U05_FILIAL + U05_CODIGO

	//valido se o plano exige o preenchimento do campo de taxa de manutencao
	If U05->( DbSeek( xFilial("U05") + cPlanoCtr ) ) .And. U05->U05_EXIMNT == 'S'
		lExigeTxMnt	:= .T.
	EndIf

	RestArea(aArea)
	RestArea(aAreaU00)
	RestArea(aAreaU05)

Return(lExigeTxMnt)
