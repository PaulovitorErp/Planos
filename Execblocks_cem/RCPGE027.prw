#Include 'Protheus.ch'
#Include "topconn.ch"
#Include "FWBrowse.ch"

/////////////////////////////////////////////////////////////////
////////////// POSICOES DO ARRAY aDadosApto		////////////////
///////////////////////////////////////////////////////////////
#Define P_MODEL 		1	//Model do Cabecalho do Apontamento
#Define P_SERVICO		2	//Codigo do Servico Selecionado
#Define P_CONTRATO		3	//Contrato Selecionado
#Define P_QUADRA		4	//Quadra
#Define P_MODULO		5	//Modulo
#Define P_JAZIGO		6	//Jazigo
#Define P_CREMATORIO	7	//Crematorio
#Define P_NICHOC		8	//Nicho Columbario
#Define P_OSSARIO		9	//Ossario
#Define P_NICHO			10	//Nicho Ossario
#Define P_ENDERECADO	11	//Endereco Utilizado
#Define P_TIPOSERVICO	12	//Tipo de Servico

/*/{Protheus.doc} RCPGE027
Tela para Enderecamento de Jazigo
(UJAZIG)
@author Leandro Rodrigues
@since 06/11/2019
@type function
@version P12
@param cTipoServ, character, tipo de servico
/*/
User Function RCPGE027(cTipoServ)

	Local aDadosJaz		:= {}
	Local aDadosApto	:= {}
	Local cServico		:= NIL
	Local cContrato		:= NIL
	Local cTipo			:= cTipoServ
	Local cFilBkp		:= cFilAnt
	Local cFilDestino	:= ""
	Local lRet 			:= .T.
	Local oPnlInfo		:= NIL
	Local oPnlQuadra	:= NIL
	Local oPnlModulo	:= NIL
	Local oPnlJazigo	:= NIL
	Local oPnlGaveta	:= NIL
	Local oPnlCremato	:= NIL
	Local oPnlNicho		:= NIL
	Local oPnlOssa		:= NIL
	Local oPnlNOssa		:= NIL
	Local oBrwQ			:= NIL
	Local oBrwM			:= NIL
	Local oBrwJ			:= NIL
	Local oBrwG			:= NIL
	Local oBrwC			:= NIL
	Local oBrwN			:= NIL
	Local oBrwO			:= NIL
	Local oBrwNO		:= NIL
	Local oNewPag		:= NIL
	Local oStepWiz  	:= Nil
	Local oDlg     		:= Nil
	Local oModel		:= FWModelActive()
	Local oModelRot 	:= NIL

	Static aRetorno		:= {}

	DEFINE DIALOG oDlg TITLE 'Endereçamento' PIXEL

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

	////////////////////////////////////////////////////////////////////////////////////////////////////
	//Array contendo os dados do apontamento e os enderecos utilizados nas telas do wizard.			////
	//utilizado por exemplo para consultar apenas modulos da quadra selecionada na tela anterior	///
	//////////////////////////////////////////////////////////////////////////////////////////////////

	//Apontamento de Servico
	if FWIsInCallStack("U_RCPGA040") .Or. FWIsInCallStack("U_RCPGA039")

		oModelRot	:= oModel:GetModel("UJVMASTER")
		cServico	:= oModelRot:GetValue("UJV_SERVIC")
		cContrato	:= oModelRot:GetValue("UJV_CONTRA")

	ElseIf FWIsInCallStack("U_RUTIL049") // agendamento

		oModelRot	:= oModel:GetModel("U92MASTER")
		cServico	:= oModelRot:GetValue("U92_SERVIC")
		cContrato	:= oModelRot:GetValue("U92_CONTRA")

	else //transferencia de enderecamento

		oModelRot	:= oModel:GetModel("U38MASTER")
		cServico	:= oModelRot:GetValue("U38_SERVDE")
		cContrato	:= oModelRot:GetValue("U38_CTRDES")
		cFilDestino	:= oModelRot:GetValue("U38_FILDES")

		// altero a filial logada para a filial de destino
		if !Empty(cFilDestino)

			cFilAnt 	:= cFilDestino

		endif

	endif

	// verifico se o existe o ponto de entrada para mensagem de alerta antes do enderecamento
	if ExistBlock("ALERTEND")
		U_ALERTEND(cContrato)
	endIf

	aDadosApto	:= 	{oModelRot,;	//Model do Cabecalho do Apontamento
	cServico,;		//Codigo do Servico Selecionado
	cContrato,;	//Contrato Selecionado
	"",;			//Quadra
	"",;			//Modulo
	"",;			//Jazigo
	"",;			//Crematorio
	"",;			//Nicho Columbario
	"",;			//Ossario
	"",;			//Nicho Ossario
	.F.,;			//Endereco utilizado
	cTipo}			//Tipo de Servico

	//##################################################################
	//					ENDERECAMENTO JAZIGO
	//##################################################################
	if cTipo == "J"

		SB1->(DbSetOrder(1))

		//Posiciona no servico para validar se é locacao
		If SB1->(MsSeek(xFilial("SB1")+aDadosApto[P_SERVICO]))
			cLocacao := SB1->B1_XLOCACA
		endif

		U04->(DbSetOrder(1))

		//Valido se ja existe enderecamento para o contrato e que nao seja locacao
		If !ValEndereco( cTipo, cContrato ) .Or. cLocacao == "S"

			//Pagina 2
			oNewPag := oStepWiz:AddStep("2")
			oNewPag:SetStepDescription("Quadra")
			oNewPag:SetConstruction({|oPnlQuadra| FwEndereca(oPnlQuadra,@oBrwQ,"QU08",aDadosApto)})
			oNewPag:SetNextAction({|| lRet := ValProxTela("QU08",aDadosApto,oBrwM) })
			oNewPag:SetCancelAction({||lRet := .F.,oDlg:End()})

			//Pagina 3
			oNewPag := oStepWiz:AddStep("3", {|oPnlModulo| FwEndereca(oPnlModulo,@oBrwM,"QU09",aDadosApto)})
			oNewPag:SetStepDescription("Modulo")
			oNewPag:SetNextAction({|| ValProxTela("QU09",aDadosApto,oBrwJ) })
			oNewPag:SetCancelAction({||lRet := .F.,oDlg:End()})

			//Pagina 4
			oNewPag := oStepWiz:AddStep("4", {|oPnlJazigo| FwEndereca(oPnlJazigo,@oBrwJ,"QU10",aDadosApto)})
			oNewPag:SetStepDescription("Jazigo")
			oNewPag:SetNextAction({||lRet := ValProxTela("QU10",aDadosApto,oBrwG)})
			oNewPag:SetCancelAction({||lRet := .F.,oDlg:End()})

			//Pagina 5
			oNewPag := oStepWiz:AddStep("5", {|oPnlGaveta| FwEndereca(oPnlGaveta,@oBrwG,"QTRB",aDadosApto)})
			oNewPag:SetStepDescription("Gavetas")
			oNewPag:SetNextAction({||lRet := ValProxTela("QTRB",aDadosApto,oBrwG)})
			oNewPag:SetCancelAction({||lRet := .F.,oDlg:End()})

			//Se ja estiver enderecado
		else

			// pego os dados do contrato
			aDadosJaz := U_DadosJazigo( cContrato )

			// verifico se o array de jazigos foi preenchido
			If Len(aDadosJaz) > 0

				// coloco o pedido de venda
				aDadosApto[P_ENDERECADO] 	:= .T.

				//Alimenta variaveis de endereco
				aDadosApto[P_QUADRA] 		:= aDadosJaz[1] //U04->U04_QUADRA
				aDadosApto[P_MODULO] 		:= aDadosJaz[2] //U04->U04_MODULO
				aDadosApto[P_JAZIGO] 		:= aDadosJaz[3] //U04->U04_JAZIGO

			EndIf

			//Pagina 2
			oNewPag := oStepWiz:AddStep("2", {|oPnlGaveta| FwEndereca(oPnlGaveta,@oBrwG,"QTRB",aDadosApto)})

		Endif

		oNewPag:SetStepDescription("Gaveta")
		oNewPag:SetNextAction({|| lRet := ValProxTela("QTRB",aDadosApto),oDlg:End()})
		oNewPag:SetCancelAction({||lRet := .F. ,oDlg:End()})
		oNewPag:SetCancelWhen({||.F.})


		//##################################################################
		//					ENDERECAMENTO CREMATORIO
		//##################################################################
	elseif cTipo == "C"

		//Pagina 2
		oNewPag := oStepWiz:AddStep("2")
		oNewPag:SetStepDescription("Crematorio")
		oNewPag:SetConstruction({|oPnlCremato| FwEndereca(oPnlCremato,@oBrwC,"QU11",aDadosApto)})
		oNewPag:SetNextAction({|| lRet := ValProxTela("QU11",aDadosApto,oBrwN) })
		oNewPag:SetCancelAction({||lRet := .F. ,oDlg:End()})

		//Pagina 3
		oNewPag := oStepWiz:AddStep("3", {|oPnlNicho| FwEndereca(oPnlNicho,@oBrwN,"QU12",aDadosApto)})
		oNewPag:SetStepDescription("Nicho Columbario")
		oNewPag:SetNextAction({|| lRet := ValProxTela("QU12",aDadosApto),oDlg:End() })
		oNewPag:SetCancelAction({||lRet := .F. ,oDlg:End()})
		oNewPag:SetCancelWhen({||.F.})

		//##################################################################
		//					ENDERECAMENTO OSSARIO
		//##################################################################
	elseif cTipo == "O"

		//Pagina 2
		oNewPag := oStepWiz:AddStep("2")
		oNewPag:SetStepDescription("Ossario")
		oNewPag:SetConstruction({|oPnlOssa| FwEndereca(oPnlOssa,@oBrwO,"QU13",aDadosApto)})
		oNewPag:SetNextAction({|| lRet := ValProxTela("QU13",aDadosApto,oBrwNO) })
		oNewPag:SetCancelAction({||lRet := .F. ,oDlg:End()})

		//Pagina 3
		oNewPag := oStepWiz:AddStep("3", {|oPnlNOssa| FwEndereca(oPnlNOssa,@oBrwNO,"QU14",aDadosApto)})
		oNewPag:SetStepDescription("Nicho Columbario")
		oNewPag:SetNextAction({|| lRet := ValProxTela("QU14",aDadosApto),oDlg:End() })
		oNewPag:SetCancelAction({||lRet := .F. ,oDlg:End()})
		oNewPag:SetCancelWhen({||.F.})

	endif

	oStepWiz:Activate()
	ACTIVATE DIALOG oDlg CENTER
	oStepWiz:Destroy()

	//restauro a filial logada
	cFilAnt := cFilBkp

Return(lRet)

/*/{Protheus.doc} RCPGE025
Monta tela para Enderecamento de Jazigo
@author Leandro Rodrigues
@since 06/11/2019
@version P12
@param nulo
@return nulo
/*/
Static Function FwEndereca(oPanel,oBrowse,cAlias,aDadosApto)

	Local oBtnPanel := TPanel():New(0,0,"",oPanel,,,,,,40,40)

	oBtnPanel:Align := CONTROL_ALIGN_ALLCLIENT

	//Cria tabela temporaria que vai conter os dADOS
	CriaTabTemp(cAlias,aDadosApto)

	// Define o Browse
	oBrowse := FWBrowse():New(oBtnPanel)
	oBrowse:SetDataTable(.T.)
	oBrowse:SetAlias(cAlias)
	oBrowse:DisableReport()

	//##################################################################
	//					ENDERECAMENTO JAZIGO
	//##################################################################
	if aDadosApto[P_TIPOSERVICO] == "J"

		if cAlias == "QU08"

			// Cria uma coluna de marca/desmarca
			oColumn := oBrowse:AddMarkColumns({||If( QU08->U08_OK == 'T','LBOK','LBNO')},{|oBrowse| MarkBrowse( oBrowse,cAlias,"U08_OK" ) },{|oBrowse|/* Função de HEADERCLICK*/})

			ADD COLUMN oColumn DATA { || U08_CODIGO } TITLE Alltrim(GetSx3Cache("U08_CODIGO","X3_TITULO")) SIZE TamSx3("U08_CODIGO")[1] OF oBrowse
			ADD COLUMN oColumn DATA { || U08_DESC   } TITLE Alltrim(GetSx3Cache("U08_DESC"  ,"X3_TITULO")) SIZE TamSx3("U08_DESC")[1]   OF oBrowse

		elseif cAlias == "QU09"

			oColumn := oBrowse:AddMarkColumns({||If( QU09->U09_OK == 'T','LBOK','LBNO')},{|oBrowse| MarkBrowse( oBrowse,cAlias,"U09_OK" ) },{|oBrowse|/* Função de HEADERCLICK*/})

			ADD COLUMN oColumn DATA { || U09_CODIGO } TITLE Alltrim(GetSx3Cache("U09_CODIGO","X3_TITULO")) SIZE TamSx3("U09_CODIGO")[1] OF oBrowse
			ADD COLUMN oColumn DATA { || U09_DESC   } TITLE Alltrim(GetSx3Cache("U09_DESC"  ,"X3_TITULO")) SIZE TamSx3("U09_DESC")[1]   OF oBrowse


		elseif cAlias == "QU10"

			oColumn := oBrowse:AddMarkColumns({||If( QU10->U10_OK == 'T','LBOK','LBNO')},{|oBrowse| MarkBrowse( oBrowse,cAlias,"U10_OK" ) },{|oBrowse|/* Função de HEADERCLICK*/})

			ADD COLUMN oColumn DATA { || U10_CODIGO } TITLE Alltrim(GetSx3Cache("U10_CODIGO","X3_TITULO")) SIZE TamSx3("U10_CODIGO")[1] OF oBrowse
			ADD COLUMN oColumn DATA { || U10_DESC   } TITLE Alltrim(GetSx3Cache("U10_DESC"  ,"X3_TITULO")) SIZE 30   OF oBrowse
			ADD COLUMN oColumn DATA { || U10_QTDGAV } TITLE Alltrim(GetSx3Cache("U10_QTDGAV","X3_TITULO")) SIZE TamSx3("U10_QTDGAV")[1]   OF oBrowse

		elseif cAlias == "QTRB"

			oColumn := oBrowse:AddMarkColumns({||If( QTRB->TRB_OK == 'T','LBOK','LBNO')},{|oBrowse| MarkBrowse( oBrowse,cAlias,"TRB_OK" ) },{|oBrowse|/* Função de HEADERCLICK*/})

			ADD COLUMN oColumn DATA { || TRB_CODIGO } TITLE "Gaveta" 	SIZE TamSx3("U04_GAVETA")[1]  OF oBrowse
			ADD COLUMN oColumn DATA { || TRB_DESC   } TITLE "Descricao" SIZE 40 OF oBrowse


		endif

		//##################################################################
		//					ENDERECAMENTO CREMATORIO
		//##################################################################
	elseif aDadosApto[P_TIPOSERVICO] == "C"

		if cAlias == "QU11"

			oColumn := oBrowse:AddMarkColumns({||If( QU11->U11_OK == 'T','LBOK','LBNO')},{|oBrowse| MarkBrowse( oBrowse,cAlias,"U11_OK" ) },{|oBrowse|/* Função de HEADERCLICK*/})

			ADD COLUMN oColumn DATA { || U11_CODIGO } TITLE Alltrim(GetSx3Cache("U11_CODIGO","X3_TITULO")) SIZE TamSx3("U11_CODIGO")[1] OF oBrowse
			ADD COLUMN oColumn DATA { || U11_DESC   } TITLE Alltrim(GetSx3Cache("U11_DESC"  ,"X3_TITULO")) SIZE TamSx3("U11_DESC")[1]   OF oBrowse

		elseif cAlias == "QU12"

			oColumn := oBrowse:AddMarkColumns({||If( QU12->U12_OK == 'T','LBOK','LBNO')},{|oBrowse| MarkBrowse( oBrowse,cAlias,"U12_OK" ) },{|oBrowse|/* Função de HEADERCLICK*/})

			ADD COLUMN oColumn DATA { || U12_CODIGO } TITLE Alltrim(GetSx3Cache("U12_CODIGO","X3_TITULO")) SIZE TamSx3("U12_CODIGO")[1] OF oBrowse
			ADD COLUMN oColumn DATA { || U12_DESC   } TITLE Alltrim(GetSx3Cache("U12_DESC"  ,"X3_TITULO")) SIZE TamSx3("U12_DESC")[1]   OF oBrowse

		endif

		//##################################################################
		//					ENDERECAMENTO CREMATORIO
		//##################################################################
	elseif aDadosApto[P_TIPOSERVICO] == "O"

		if cAlias == "QU13"

			oColumn := oBrowse:AddMarkColumns({||If( QU13->U13_OK == 'T','LBOK','LBNO')},{|oBrowse| MarkBrowse( oBrowse,cAlias,"U13_OK" ) },{|oBrowse|/* Função de HEADERCLICK*/})

			ADD COLUMN oColumn DATA { || U13_CODIGO } TITLE Alltrim(GetSx3Cache("U13_CODIGO","X3_TITULO")) SIZE TamSx3("U13_CODIGO")[1] OF oBrowse
			ADD COLUMN oColumn DATA { || U13_DESC   } TITLE Alltrim(GetSx3Cache("U13_DESC"  ,"X3_TITULO")) SIZE TamSx3("U13_DESC")[1]   OF oBrowse

		elseif cAlias == "QU14"

			oColumn := oBrowse:AddMarkColumns({||If( QU14->U14_OK == 'T','LBOK','LBNO')},{|oBrowse| MarkBrowse( oBrowse,cAlias,"U14_OK" ) },{|oBrowse|/* Função de HEADERCLICK*/})

			ADD COLUMN oColumn DATA { || U14_CODIGO } TITLE Alltrim(GetSx3Cache("U14_CODIGO","X3_TITULO")) SIZE TamSx3("U14_CODIGO")[1] OF oBrowse
			ADD COLUMN oColumn DATA { || U14_DESC   } TITLE Alltrim(GetSx3Cache("U14_DESC"  ,"X3_TITULO")) SIZE TamSx3("U14_DESC")[1]   OF oBrowse

		endif


	endif

	oBrowse:SetSeek()
	oBrowse:Activate()

Return

/*/{Protheus.doc} Pag1Intrucoes
Instrucoes Iniciais do Wizard de Processametno
@author Leandro Rodrigues
@since 30/11/2018
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

	cTexto1 += "Esta rotina tem como objetivo ajuda-lo realizar o enderecamento" + cPulaLinha

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

	@ 030 , 055 SAY oSay3 PROMPT "o endereçamento." SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

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
	if (cAlias)->(MsSeek("T"))

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

/*/{Protheus.doc} Pag2Layout
Cria Tabela temporaria
@author Leandro Rodrigues
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function CriaTabTemp(cAlias,aDadosApto)

	Local oTable 	:= Nil
	Local aCampos	:= {}
	Local cIndice1	:= ""
	Local cIndice2	:= ""

//##################################################################
//					ENDERECAMENTO JAZIGO
//##################################################################
	if aDadosApto[P_TIPOSERVICO] == "J"

		if cAlias == "QU08"

			aCampos:= {	{"U08_OK"		,"C",001,0},;
				{"U08_CODIGO"	,"C",TamSX3("U08_CODIGO")[1],0},;
				{"U08_DESC" 	,"C",TamSX3("U08_DESC")[1],0} }

			cIndice1 := "U08_CODIGO"
			cIndice2 := "U08_OK"

		elseif cAlias == "QU09"

			aCampos:= {	{"U09_OK"		,"C",001,0},;
				{"U09_CODIGO"	,"C",TamSX3("U09_CODIGO")[1],0},;
				{"U09_DESC"		,"C",TamSX3("U09_DESC")[1],0} }

			cIndice1 := "U09_CODIGO"
			cIndice2 := "U09_OK"

		elseif cAlias == "QU10"

			aCampos:= {	{"U10_OK"		,"C",001,0},;
				{"U10_CODIGO"	,"C",TamSX3("U10_CODIGO")[1],0},;
				{"U10_DESC"		,"C",TamSX3("U10_DESC")[1],0},;
				{"U10_QTDGAV"	,"N",TamSX3("U10_QTDGAV")[1],0}}

			cIndice1 := "U10_CODIGO"
			cIndice2 := "U10_OK"

		elseif cAlias == "QTRB"

			aCampos:= {	{"TRB_OK"		,"C",001,0},;
				{"TRB_CODIGO"	,"C",TamSX3("U04_GAVETA")[1],0},;
				{"TRB_DESC"		,"C",40,0} }

			cIndice1 := "TRB_CODIGO"
			cIndice2 := "TRB_OK"

		endif

//##################################################################
//					ENDERECAMENTO CREMATORIO
//##################################################################
	elseif aDadosApto[P_TIPOSERVICO] == "C"

		if cAlias == "QU11"

			aCampos:= {	{"U11_OK"		,"C",001,0},;
				{"U11_CODIGO"	,"C",TamSX3("U11_CODIGO")[1],0},;
				{"U11_DESC" 	,"C",TamSX3("U11_DESC")[1],0} }

			cIndice1 := "U11_CODIGO"
			cIndice2 := "U11_OK"

		elseif cAlias == "QU12"

			aCampos:= {	{"U12_OK"		,"C",001,0},;
				{"U12_CODIGO"	,"C",TamSX3("U12_CODIGO")[1],0},;
				{"U12_DESC" 	,"C",TamSX3("U12_DESC")[1],0} }

			cIndice1 := "U12_CODIGO"
			cIndice2 := "U12_OK"
		endif

//##################################################################
//					ENDERECAMENTO CREMATORIO
//##################################################################
	elseif aDadosApto[P_TIPOSERVICO] == "O"

		if cAlias == "QU13"

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
	GetTabTemp(cAlias,aDadosApto)

Return(Nil)

/*/{Protheus.doc} Pag2Layout
Rotina para carregar Tabela temporaria
@author Leandro Rodrigues
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
@history 16/09/2020, g.sampaio, VP-458 - Retirado a validacao na posicao P_ENDERECADO do array aDadosApto para criar os dados
na tabela temporaria para as gavetas, e foi deixado apenas a funcao SaveGavetaDisponivel() para criar os dados da tabela temporaria QTRB.
/*/
Static Function GetTabTemp(cAlias,aDadosApto)

	Local cQry 			:= ""
	Local cDescricao	:= ""
	Local cLocacao		:= ""
	Local cQuadQry		:= ""
	Local lAtivJazOssi  := SuperGetMV("MV_XJAZOSS",,.F.)
	Local nQtde			:= 0

	//##################################################################
	//					ENDERECAMENTO JAZIGO
	//##################################################################
	if aDadosApto[P_TIPOSERVICO] == "J"

		//Pega dados da Quadra
		If cAlias == "QU08"

			cQry := " SELECT"
			cQry += " 	U08_CODIGO,"
			cQry += " 	U08_DESC"
			cQry += " FROM " + RETSQLNAME("U08") + " U08"
			cQry += " WHERE U08.D_E_L_E_T_ = ' '"
			cQry += " 	AND U08_FILIAL = '"+ xFilial("U08") + "'"
			cQry += " 	AND U08_STATUS = 'S'"

			// ponto de entrada para tratar filtros especificos de quadra
			if ExistBlock("QUADQRY")

				// pego o fitro de quadra especifico
				cQuadQry := U_QUADQRY(aDadosApto[P_CONTRATO])

				// verifico se a variavel tem conteudo
				if !Empty(cQuadQry)
					cQry += cQuadQry
				endIf

			endIf

			cQry += " 	ORDER BY  U08_CODIGO"

			if Select("TR08") > 0
				TR08->(DbCloseArea())
			endif

			// função que converte a query genérica para o protheus
			cQry := ChangeQuery(cQry)

			// executo a query e crio o alias temporario
			MPSysOpenQuery( cQry, 'TR08' )

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
			cQry += " FROM " + RETSQLNAME("U09") + " U09"
			cQry += " WHERE U09.D_E_L_E_T_ = ' '"
			cQry += " 	AND U09_FILIAL = '"+ xFilial("U09") + "'"
			cQry += " 	AND U09_STATUS = 'S'"
			cQry += " 	AND U09_QUADRA = '" +  aDadosApto[P_QUADRA] + "'"
			cQry += " 	ORDER BY U09_CODIGO"

			if Select("TR09") > 0
				TR09->(DbCloseArea())
			endif

			// função que converte a query genérica para o protheus
			cQry := ChangeQuery(cQry)

			// executo a query e crio o alias temporario
			MPSysOpenQuery( cQry, 'TR09' )

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

			//Posiciona no servico para validar se é locacao
			If SB1->(MsSeek(xFilial("SB1")+aDadosApto[P_SERVICO]))
				cLocacao := SB1->B1_XLOCACA
			endif

			cQry := " SELECT "
			cQry += " 	U10.U10_CODIGO, "
			cQry += " 	U10.U10_DESC, "
			cQry += "   U10.U10_QTDGAV, "
			cQry += "   U09.U09_QTDGAV, "
			cQry += "   U08.U08_QTDGAV "
			cQry += " FROM " + RetSQLName("U10") + " U10 "
			cQry += " INNER JOIN " + RetSQLName("U09") + " U09 ON U09.D_E_L_E_T_ = ' ' "
			cQry += " 	AND U09.U09_FILIAL = '"+ xFilial("U09") + "'"
			cQry += " 	AND U09.U09_QUADRA = U10.U10_QUADRA "
			cQry += " 	AND U09.U09_CODIGO = U10.U10_MODULO "
			cQry += " 	AND U09.U09_STATUS = 'S'"
			cQry += " INNER JOIN " + RetSQLName("U08") + " U08 ON U08.D_E_L_E_T_ = ' ' "
			cQry += " 	AND U08.U08_FILIAL = '"+ xFilial("U08") + "'"
			cQry += " 	AND U08.U08_CODIGO = U10.U10_QUADRA "
			cQry += " 	AND U08.U08_STATUS = 'S'"
			cQry += " WHERE U10.D_E_L_E_T_ = ' '"
			cQry += " 	AND U10.U10_FILIAL = '"+ xFilial("U10") + "'"
			cQry += " 	AND U10.U10_STATUS = 'S'"
			cQry += " 	AND U10.U10_QUADRA = '" +  aDadosApto[P_QUADRA] + "'"
			cQry += " 	AND U10.U10_MODULO = '" +  aDadosApto[P_MODULO] + "'"

			//Valida se for locacao permite mostrar jazigo ocupado
			//que ainda tenha gavetas livres
			cQry += " AND U10.U10_CODIGO NOT IN ( SELECT "
			cQry += " 								U04.U04_JAZIGO "
			cQry += " 							FROM " + RetSQLName("U04") + " U04 "
			cQry += " 							WHERE U04.D_E_L_E_T_ =' '"
			cQry += " 							AND U04.U04_FILIAL = '" + xFilial("U04") + "' "
			cQry += " 							AND U04.U04_TIPO = 'J' "
			cQry += "                           AND U04.U04_QUADRA  = U10.U10_QUADRA "
			cQry += "                           AND U04.U04_MODULO  = U10.U10_MODULO "
			cQry += "							AND U04.U04_OCUPAG = 'S' "

			//caso seja locacao visualiza jazigos disponiveis
			if cLocacao == "S"
				cQry += " 						AND U04.U04_LOCACA <> 'S' "
			endif

			cQry += " 							AND ( U04.U04_QUEMUT <> ' ' OR U04.U04_PREVIO = 'S' )  "
			cQry += " 							GROUP BY U04.U04_JAZIGO ) "
			cQry += " 	ORDER BY U10.U10_CODIGO "

			if Select("TR10") > 0
				TR10->(DbCloseArea())
			endif

			// função que converte a query genérica para o protheus
			cQry := ChangeQuery(cQry)

			// executo a query e crio o alias temporario
			MPSysOpenQuery( cQry, 'TR10' )

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

			//Pega dados da Gaveta
		elseIf cAlias == "QTRB"

			U08->(DbSetOrder(1))
			U09->(DbSetOrder(1))

			U10->(DbSetOrder(1))
			//posiciono no jazigo para pegar a descricao
			if U10->(MsSeek( xFilial("U10") + aDadosApto[P_QUADRA]+ aDadosApto[P_MODULO] + aDadosApto[P_JAZIGO]))

				cDescricao := U10->U10_DESC

				if U10->(FieldPos("U10_QTDGAV")) > 0
					If U10->U10_QTDGAV > 0

						nQtde := U10->U10_QTDGAV

					endif
				endIf

			endif

			if nQtde == 0

				//Posiciona no Modulo pra ver se esta preenchido a
				//quantidade de gavetas que será gerada
				if U09->(MsSeek(xFilial("U09") + aDadosApto[P_QUADRA] + aDadosApto[P_MODULO] ))

					cDescricao := U09->U09_DESC

					If U09->U09_QTDGAV > 0

						nQtde := U09->U09_QTDGAV

					endif
				endif

			endIf

			//Se no modulo nao estiver preenchido verifica se
			//esta preenchido na quadra
			if nQtde == 0

				if U08->(MsSeek(xFilial("U08") + aDadosApto[P_QUADRA]))

					If U08->U08_QTDGAV > 0

						nQtde := U08->U08_QTDGAV

					endif
				endif

			endif

			//Se nao estiver preenchido na quadra ou modulo pega do parametro
			if nQtde == 0

				nQtde := SuperGetMv("MV_XQTDGVJ",.F.,3)

			endif

			U04->(DbSetOrder(2))

			/////////////////////////////////////////////////////////////////////////////
			//////////// GRAVO NO ARQUIVO TEMPORARIO AS GAVETAS DISPONIVEIS     /////////
			/////////////////////////////////////////////////////////////////////////////
			SaveGavetaDisponivel(aDadosApto[P_QUADRA],aDadosApto[P_MODULO],aDadosApto[P_JAZIGO],nQtde,cDescricao,aDadosApto[P_SERVICO])

		endif

		//##################################################################
		//					ENDERECAMENTO CREMATORIO
		//##################################################################
	elseif aDadosApto[P_TIPOSERVICO] == "C"

		If cAlias == "QU11"

			cQry := " SELECT"
			cQry += " 	U11_CODIGO,"
			cQry += " 	U11_DESC"
			cQry += " FROM " + RETSQLNAME("U11") + " U11"
			cQry += " WHERE U11.D_E_L_E_T_ = ' '"
			cQry += " 	AND U11_FILIAL = '"+ xFilial("U11") + "'"
			cQry += " 	AND U11_STATUS = 'S'"
			cQry += " 	ORDER BY  U11_CODIGO"

			if Select("TR11") > 0
				TR11->(DbCloseArea())
			endif

			// função que converte a query genérica para o protheus
			cQry := ChangeQuery(cQry)

			// executo a query e crio o alias temporario
			MPSysOpenQuery( cQry, 'TR11' )

			While TR11->(!EOF())

				Reclock("QU11",.T.)

				QU11->U11_OK 		:= " "
				QU11->U11_CODIGO	:= TR11->U11_CODIGO
				QU11->U11_DESC		:= TR11->U11_DESC

				QU11->(MsUnLock())

				TR11->(DbSkip())
			EndDo

		elseif cAlias == "QU12"

			cQry := " SELECT "
			cQry += " 	U12_CODIGO, "
			cQry += " 	U12_DESC "
			cQry += " FROM  "
			cQry += RetSQLName("U12") + " U12 "
			cQry += " WHERE U12.D_E_L_E_T_ = ' ' "
			cQry += " 	AND U12_FILIAL = '" + xFilial("U12") + "'  "
			cQry += " 	AND U12_STATUS = 'S' "
			cQry += " 	AND U12_CREMAT = '" + aDadosApto[P_CREMATORIO] + "'  "
			cQry += " 	AND NOT EXISTS (SELECT "
			cQry += " 					U04_NICHOC NICHO "
			cQry += " 					FROM  "
			cQry += 					RetSQLName("U04") + " U04 "
			cQry += "					WHERE "
			cQry += "					U04.D_E_L_E_T_ = ' ' "
			cQry += "					AND U04.U04_FILIAL = '" + xFilial("U04") + "' "
			cQry += "					AND U04.U04_CREMAT = U12.U12_CREMAT "
			cQry += "					AND U04.U04_NICHOC = U12.U12_CODIGO) "
			cQry += " ORDER BY U12_CODIGO "

			if Select("TR12") > 0
				TR12->(DbCloseArea())
			endif

			// função que converte a query genérica para o protheus
			cQry := ChangeQuery(cQry)

			// executo a query e crio o alias temporario
			MPSysOpenQuery( cQry, 'TR12' )

			While TR12->(!EOF())

				Reclock("QU12",.T.)

				QU12->U12_OK 		:= " "
				QU12->U12_CODIGO	:= TR12->U12_CODIGO
				QU12->U12_DESC		:= TR12->U12_DESC

				QU12->(MsUnLock())

				TR12->(DbSkip())
			EndDo

		endif

//##################################################################
//					ENDERECAMENTO OSSARIO
//##################################################################
	elseif aDadosApto[P_TIPOSERVICO] == "O"

		If cAlias == "QU13"

			cQry := " SELECT "
			cQry += " 	U13_CODIGO CODIGO, "
			cQry += " 	U13_DESC   DESCRICAO "
			cQry += " FROM " + RETSQLNAME("U13") + " U13 "
			cQry += " WHERE U13.D_E_L_E_T_ = ' ' "
			cQry += " 	AND U13_FILIAL = '"+ xFilial("U13") + "' "
			cQry += " 	AND U13_STATUS = 'S' "
			cQry += " 	AND U13_TPOSS <> '2' "

			//Pesquiso Ossario vinculado ao Contrato previamente
			cQry += " UNION "

			cQry += " SELECT U13_CODIGO CODIGO, "
			cQry += " U13_DESC DESCRICAO "
			cQry += " FROM "
			cQry += RetSQLName("U13") + " U13 "
			cQry += " INNER JOIN "
			cQry += RetSQLName("U04") + " U04 "
			cQry += " ON U13.D_E_L_E_T_ = ' ' "
			cQry += " AND U04.D_E_L_E_T_ = ' ' "
			cQry += " AND U13.U13_FILIAL = U04.U04_FILIAL "
			cQry += " AND U13.U13_CODIGO = U04.U04_OSSARI "
			cQry += " WHERE "
			cQry += " U13.U13_FILIAL = '" + xFilial("U13") + "' "
			cQry += " AND U04.U04_FILIAL = '" + xFilial("U04") + "' "
			cQry += " AND U04.U04_CODIGO = '" + aDadosApto[P_CONTRATO] + "' "
			cQry += " AND U13.U13_STATUS = 'S' "
			cQry += " AND U13.U13_TPOSS = '2' "
			cQry += " AND U04.U04_PREVIO = 'S' "

			//====================================================================
			// UNION COM OS OSSUARIOS VINCULADO AO JAZIGO DE ENDERECAMENTO PREVIO
			//====================================================================

			if lAtivJazOssi

				cQry += " UNION "
				cQry += " SELECT U13_CODIGO CODIGO, "
				cQry += "        U13_DESC DESCRICAO "
				cQry += " FROM " + RETSQLNAME("U13") + " U13 "
				cQry += " WHERE U13.D_E_L_E_T_ = ' ' "
				cQry += " AND U13_FILIAL = '"+ xFilial("U13") + "' "
				cQry += " AND U13_STATUS = 'S' "
				cQry += " AND U13_TPOSS = '2' "
				cQry += " AND EXISTS( "
				cQry += " SELECT U04.U04_CODIGO FROM " + RETSQLNAME("U04") + " U04 WHERE U04.D_E_L_E_T_ = ' ' "
				cQry += " AND U04.U04_FILIAL = '" + xFilial("U04") + "' "
				cQry += " AND U04.U04_CODIGO = '" + aDadosApto[P_CONTRATO] + "'  "
				cQry += " AND U04.U04_QUADRA = U13.U13_QUADRA "
				cQry += " AND U04.U04_MODULO = U13.U13_MODULO "
				cQry += " AND U04.U04_JAZIGO = U13.U13_JAZIGO "
				cQry += " ) "
				cQry += " 	ORDER BY  CODIGO"

			else
				cQry += " 	ORDER BY  CODIGO"
			endIf

			if Select("TR13") > 0
				TR13->(DbCloseArea())
			endif

			// função que converte a query genérica para o protheus
			cQry := ChangeQuery(cQry)

			// executo a query e crio o alias temporario
			MPSysOpenQuery( cQry, 'TR13' )

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
			cQry += " 	AND U14_OSSARI = '" + aDadosApto[P_OSSARIO] + "'  "
			cQry += " 	AND U14_CAPACI > (SELECT  "
			cQry += " 						COUNT(*) UTILIZADO "
			cQry += " 						FROM "
			cQry +=  						RetSQLName("U04") + " U04 "
			cQry += " 							WHERE " "
			cQry += " 							U04.D_E_L_E_T_ = ' ' "
			cQry += " 							AND U04.U04_FILIAL = '" + xFilial("U04") + "' "
			cQry += " 							AND U04.U04_TIPO = 'O' "
			cQry += " 							AND U04.U04_OSSARI = U14.U14_OSSARI "
			cQry += " 							AND U04.U04_NICHOO = U14.U14_CODIGO "
			cQry += " 							AND U04.U04_QUEMUT <> '' ) "

			//Retiro nichos que ja estao enderecados previamente a outros contratos
			cQry += " AND NOT EXISTS (SELECT  "
			cQry += " 						U04_CODIGO "
			cQry += " 						FROM "
			cQry +=  						RetSQLName("U04") + " U04 "
			cQry += " 							WHERE "
			cQry += " 							U04.D_E_L_E_T_ = ' ' "
			cQry += " 							AND U04.U04_FILIAL = '" + xFilial("U04") + "' "
			cQry += " 							AND U04.U04_TIPO = 'O' "
			cQry += " 							AND U04.U04_OSSARI = U14.U14_OSSARI "
			cQry += " 							AND U04.U04_NICHOO = U14.U14_CODIGO "
			cQry += " 							AND U04.U04_PREVIO = 'S' "
			cQry += " 							AND U04.U04_CODIGO <> '" + aDadosApto[P_CONTRATO] + "' ) "
			cQry += " ORDER BY U14_CODIGO "

			if Select("TR14") > 0
				TR14->(DbCloseArea())
			endif

			// função que converte a query genérica para o protheus
			cQry := ChangeQuery(cQry)

			// executo a query e crio o alias temporario
			MPSysOpenQuery( cQry, 'TR14' )

			While TR14->(!EOF())

				Reclock("QU14",.T.)

				QU14->U14_OK 		:= " "
				QU14->U14_CODIGO	:= TR14->U14_CODIGO
				QU14->U14_DESC		:= TR14->U14_DESC

				QU14->(MsUnLock())

				TR14->(DbSkip())
			EndDo

		endif

	endif

Return

/*/{Protheus.doc} ValProxTela
Rotina para validar se permite avancar
@author Leandro Rodrigues
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function ValProxTela(cAlias,aDadosApto,oGrid)

	Local aArea	   		:= (cAlias)->(GetArea())
	Local lRet	   		:= .T.
	Local oModelUJV		:= NIL
	Local cApontamento	:= ""
	Local cServico		:= ""

	// inicio as variaveis
	cServico	:= aDadosApto[P_SERVICO]

	SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD

	if SB1->(MsSeek(xFilial("SB1") + cServico ))

		//Apontamento de Servico
		if IsInCallStack("U_RCPGA039")

			oModelUJV		:= aDadosApto[P_MODEL]
			cApontamento	:= oModelUJV:GetValue("UJV_CODIGO")

		endif

		(cAlias)->(DbSetOrder(2))

		//Valido se tem algum item ja marcado
		if !(cAlias)->(MsSeek("T"))

			Aviso("Atenção","É necessário marcar um item pra prosseguir!",{"Ok"})
			lRet := .F.
		else

			//===========================================
			//Enderecamento Jazigo
			//===========================================
			if cAlias == "QU08"

				aDadosApto[P_QUADRA] := (cAlias)->U08_CODIGO

				if Select("QU09") > 0 .And. oGrid <> NIL

					CriaTabTemp("QU09",aDadosApto)

					oGrid:Refresh(.T.)

				endif

			elseif cAlias == "QU09"

				aDadosApto[P_MODULO] := (cAlias)->U09_CODIGO

				if Select("QU10") > 0 .And. oGrid <> NIL

					CriaTabTemp("QU10",aDadosApto)

					oGrid:Refresh(.T.)

				endif

			elseif cAlias == "QU10"

				aDadosApto[P_JAZIGO] := (cAlias)->U10_CODIGO

				//valido se Jazigo esta disponivel
				lRet := U_GavetaValida(aDadosApto[P_CONTRATO],aDadosApto[P_SERVICO],aDadosApto[P_QUADRA],aDadosApto[P_MODULO],aDadosApto[P_JAZIGO],,cApontamento)

				if lRet

					if Select("QTRB") > 0 .And. oGrid <> NIL

						CriaTabTemp("QTRB",aDadosApto)

						oGrid:Refresh(.T.)

					endif

				endif

			elseif cAlias == "QTRB"

				cGaveta := 	(cAlias)->TRB_CODIGO

				//so valido se a gaveta esta sendo usada, caso o servico apontado ocupe a gaveta
				if SB1->B1_XOCUGAV == "S"

					//valido se Gaveta esta disponivel
					lRet := U_GavetaValida(aDadosApto[P_CONTRATO],aDadosApto[P_SERVICO],aDadosApto[P_QUADRA],aDadosApto[P_MODULO],aDadosApto[P_JAZIGO],cGaveta,cApontamento)

				endif

				//Atribuo para o array static para o retorno da consulta padrao
				if lRet
					aRetorno := aClone(aDadosApto)
				endif

				//===========================================
				//Enderecamento Crematorio
				//===========================================
			elseif cAlias == "QU11"

				aDadosApto[P_CREMATORIO]  := (cAlias)->U11_CODIGO

				if Select("QU12") > 0 .And. oGrid <> NIL

					CriaTabTemp("QU12",aDadosApto)

					oGrid:Refresh(.T.)

				endif

			elseif cAlias == "QU12"

				aDadosApto[P_NICHOC]  := (cAlias)->U12_CODIGO

				aRetorno := aClone(aDadosApto)

				//=======================\====================
				//Enderecamento OSSARIO
				//===========================================
			elseif cAlias == "QU13"

				aDadosApto[P_OSSARIO]  := (cAlias)->U13_CODIGO

				if Select("QU14") > 0 .And. oGrid <> NIL

					CriaTabTemp("QU14",aDadosApto)

					oGrid:Refresh(.T.)

				endif

			elseif cAlias == "QU14"

				aDadosApto[P_NICHO]  := (cAlias)->U14_CODIGO

				aRetorno := aClone(aDadosApto)
			endif

		endif

	endif

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} RCPGE15A
//Retorno da Consulta Especifica de Jazigo
@Author Leandro Rodrigues
@Since 27/12/2019
@Version 1.0
@Return
@Type function
/*/
User Function RCPGE27A()

	Local cRetorno 		:= ""
	Local aArea			:= GetArea()
	Local nLinha		:= 0

	if Len(aRetorno) > 0

		cRetorno := aRetorno[P_QUADRA]

		//Grava todos as gavetas no browse
		QTRB->(DbGoTop())
		While QTRB->(!EOF())

			//Valido se esta marcado
			If !Empty(QTRB->TRB_OK)

				//apontamento de servico
				if IsInCallStack("U_RCPGA040")

					FwFldPut("UJV_QUADRA"	, AllTrim(aRetorno[P_QUADRA])	,,,,.F.)
					FwFldPut("UJV_MODULO"	, AllTrim(aRetorno[P_MODULO])	,,,,.F.)
					FwFldPut("UJV_JAZIGO"	, AllTrim(aRetorno[P_JAZIGO])	,,,,.F.)
					FwFldPut("UJV_GAVETA"	, AllTrim(QTRB->TRB_CODIGO)	,,,,.F.)

				ElseIf FWIsInCallStack("U_RUTIL049") // agendamento

					FwFldPut("U92_QUADRA"	, AllTrim(aRetorno[P_QUADRA])	,,,,.F.)
					FwFldPut("U92_MODULO"	, AllTrim(aRetorno[P_MODULO])	,,,,.F.)
					FwFldPut("U92_JAZIGO"	, AllTrim(aRetorno[P_JAZIGO])	,,,,.F.)
					FwFldPut("U92_GAVETA"	, AllTrim(QTRB->TRB_CODIGO)	,,,,.F.)

				else//transferencia de enderecamento

					FwFldPut("U38_QDDEST"	, AllTrim(aRetorno[P_QUADRA])	,,,,.F.)
					FwFldPut("U38_MDDEST"	, AllTrim(aRetorno[P_MODULO])	,,,,.F.)
					FwFldPut("U38_JZDEST"	, AllTrim(aRetorno[P_JAZIGO])	,,,,.F.)
					FwFldPut("U38_GVDEST"	, AllTrim(QTRB->TRB_CODIGO)	,,,,.F.)

				endif

			endif

			QTRB->(DbSkip())
		EndDo

	endif

	RestArea(aArea)

Return(cRetorno)

/*/{Protheus.doc} RCPGE27B
//Retorno da Consulta Especifica de Crematorio
@Author Raphael Martins 
@Since 21/01/2019
@Version 1.0
@Return
@Type function
/*/
User Function RCPGE27B()

	Local cRetorno 		:= ""
	Local aArea			:= GetArea()
	Local nLinha		:= 0

	if Len(aRetorno) > 0
		cRetorno := aRetorno[P_CREMATORIO]

		//Grava todos as gavetas no browse
		QU12->(DbGoTop())
		While QU12->(!EOF())

			//Valido se esta marcado
			If !Empty(QU12->U12_OK)

				//apontamento de servico
				if IsInCallStack("U_RCPGA040")

					FwFldPut("UJV_CREMAT"	,aRetorno[P_CREMATORIO]	,,,,.F.)
					FwFldPut("UJV_NICHOC"	,aRetorno[P_NICHOC]	,,,,.F.)

				ElseIf FWIsInCallStack("U_RUTIL049") // agendamento

					FwFldPut("U92_CREMAT"	, AllTrim(aRetorno[P_CREMATORIO])	,,,,.F.)
					FwFldPut("U92_NICHOC"	, AllTrim(aRetorno[P_NICHOC])	,,,,.F.)

				else

					FwFldPut("U38_CRDEST"	,aRetorno[P_CREMATORIO]	,,,,.F.)
					FwFldPut("U38_NCDEST"	,aRetorno[P_NICHOC]	,,,,.F.)

				endif

			endif

			QU12->(DbSkip())
		EndDo

	endif

	RestArea(aArea)

Return(cRetorno)

/*/{Protheus.doc} RCPGE27C
//Retorno da Consulta Especifica de Ossario
@Author Raphael Martins 
@Since 21/01/2019
@Version 1.0
@Return
@Type function
/*/
User Function RCPGE27C()

	Local cRetorno 		:= ""
	Local aArea			:= GetArea()
	Local nLinha		:= 0

	if Len(aRetorno) > 0

		cRetorno := aRetorno[P_OSSARIO]

		//Grava todos as gavetas no browse
		QU14->(DbGoTop())
		While QU14->(!EOF())

			//Valido se esta marcado
			If !Empty(QU14->U14_OK)

				//apontamento de servico
				if IsInCallStack("U_RCPGA040")

					FwFldPut("UJV_OSSARI"	,aRetorno[P_OSSARIO]	,,,,.F.)
					FwFldPut("UJV_NICHOO"	,aRetorno[P_NICHO]		,,,,.F.)

				ElseIf FWIsInCallStack("U_RUTIL049") // agendamento

					FwFldPut("U92_OSSUAR"	, AllTrim(aRetorno[P_OSSARIO])	,,,,.F.)
					FwFldPut("U92_NICHOO"	, AllTrim(aRetorno[P_NICHO])	,,,,.F.)

				else

					FwFldPut("U38_OSDEST"	,aRetorno[P_OSSARIO]	,,,,.F.)
					FwFldPut("U38_NODEST"	,aRetorno[P_NICHO]		,,,,.F.)

				endif

			endif

			QU14->(DbSkip())
		EndDo

	endif

	RestArea(aArea)

Return(cRetorno)

/*/{Protheus.doc} RetGavetaDisponivel
//Grava Gavetas Disponiveis para o Endereco no arquivo temporario
@Author Raphael Martins 
@Since 27/12/2019
@Version 1.0
@Return
@Type function
/*/
Static Function SaveGavetaDisponivel(cQuadra,cModulo,cJazigo,nQtdGavetas,cDescricao,cServico)

	Local aArea 	:= GetArea()
	Local aGavetas	:= {}
	Local cQry		:= ""
	Local nTamGav	:= TamSX3("U04_GAVETA")[1]
	Local nX		:= 0

	SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD

	if SB1->(MsSeek(xFilial("SB1")+cServico))

		if SB1->B1_XOCUGAV == "S"

			cQry := " SELECT "
			cQry += " U04.U04_CODIGO  AS CONTRATO, "
			cQry += " U04.U04_GAVETA  AS GAVETA  "
			cQry += " FROM "
			cQry += RetSQLName("U04") + " U04 "
			cQry += " WHERE D_E_L_E_T_ = ' ' "
			cQry += " AND U04_FILIAL = '" + xFilial("U04") + "'
			cQry += " AND U04_QUADRA = '" + cQuadra + "'
			cQry += " AND U04_MODULO = '" + cModulo + "'
			cQry += " AND U04_JAZIGO = '" + cJazigo + "'
			cQry += " AND U04_OCUPAG = 'S' "
			cQry += " AND U04_DTUTIL <> ' ' "

			// verifico se nao existe este alias criado
			If Select("QRYU04") > 0
				QRYU04->(DbCloseArea())
			EndIf

			// crio o alias temporario
			TcQuery cQry New Alias "QRYU04"

			if QRYU04->(!Eof())

				While QRYU04->(!Eof())

					Aadd(aGavetas,QRYU04->GAVETA)

					QRYU04->(DbSkip())

				EndDo

			endif

		endif

		//verifico se a gaveta ja esta enderecada
		For nX := 1 To nQtdGavetas

			if Ascan(aGavetas,{|x| x == StrZero(nX,nTamGav) }) == 0

				Reclock("QTRB",.T.)

				QTRB->TRB_OK 		:= " "
				QTRB->TRB_CODIGO	:= StrZero(nX,nTamGav)
				QTRB->TRB_DESC		:= Alltrim(cDescricao) + " GV "+ StrZero(nX,nTamGav)

				QTRB->(MsUnLock())

			endif

		Next nX

	endif

	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} ValEndereco
Validacao do endereco
@type function
@version 1.0 
@author g.sampaio
@since 01/05/2021
@param cTipoEnd, character, tipo do endereco
@param cContrato, character, codigo do contrato
@return logical, retorna se o endereco esta vinculado ao 
contrato .T. - contrato sem endereco / .F. - contrato com endereco
/*/
Static Function ValEndereco(cTipoEnd, cContrato)

	Local cQuery 	:= ""
	Local lRetorno	:= .F.

	if Select("TRBU04") > 0
		TRBU04->(DbCloseArea())
	endIf

	cQuery := " SELECT U04.U04_CODIGO "
	cQuery += " FROM " + RetSQLName("U04") + " U04 "
	cQuery += " WHERE U04.D_E_L_E_T_ = ' ' "
	cQuery += " AND U04.U04_FILIAL = '"+ xFilial("U04") +"' "
	cQuery += " AND U04.U04_CODIGO = '" + cContrato + "' "

	if cTipoEnd == "J" // para endereco de jazigos
		cQuery += " AND U04.U04_LOCACA <> 'S' " // contrato com endereco sem locacao
		cQuery += " AND (U04.U04_TIPO   = 'J' OR U04.U04_QUADRA <> ' ') "
	else
		cQuery += " AND U04.U04_TIPO = '"+cTipoEnd+"' "
	endIf

	TcQuery cQuery New Alias "TRBU04"

	if TRBU04->(!Eof())
		lRetorno := .T. // tem registros de endereco
	endIf

	if Select("TRBU04") > 0
		TRBU04->(DbCloseArea())
	endIf

Return(lRetorno)
