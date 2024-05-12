#Include 'Protheus.ch'
#Include "topconn.ch"
#Include "FWBrowse.ch"

/*/{Protheus.doc} RCPGE038
Funcao para acrescentar ou excluir itens dos contratos
de acordo com a situação atual do cadastro de planos
@type function
@version 1.0
@author Raphael Martins 
@since 29/06/2020
/*/
User Function RCPGE038()

	Local oDlg          := NIL
	Local oPanelBkg     := NIL
	Local oStepWiz      := NIL
	Local oPnlPlano     := NIL
	Local oBrwPlano     := NIL
	Local oPnlPrd       := NIL
	Local oBrwPrd       := NIL
	Local nHdlLog       := 0
	Local cPlanoMark    := ""
	Local cRelProc      := ""

    //crio dialog que ira receber o Wizard
	DEFINE DIALOG oDlg TITLE 'Assistente de Atualização de Contratos - Plataforma Virtus' PIXEL STYLE nOR(  WS_VISIBLE ,  WS_POPUP )

	oDlg:nWidth := 800
	oDlg:nHeight := 620

    //crio panel do wizard
	oPanelBkg:= TPanel():New(0,0,"",oDlg,,,,,,300,300)

	oPanelBkg:Align := CONTROL_ALIGN_ALLCLIENT

    //instacio o objeto do wizard
	oStepWiz:= FWWizardControl():New(oPanelBkg)//Instancia a classe FWWizard
	oStepWiz:ActiveUISteps()

    ////////////////////////////////////////////////////////
    ///crio a pagina 1 do wizard - Instrucoes Iniciais
    ///////////////////////////////////////////////////////

	oNewPag := oStepWiz:AddStep("1")

    //Altero a descrição do step
	oNewPag:SetStepDescription("Instrucoes Iniciais")

    //Defino o bloco de construção
	oNewPag:SetConstruction({|Panel|Pag1Intrucoes(Panel)})

    //Defino o bloco ao clicar no botão Próxim
	oNewPag:SetNextAction({||.T.})

    //Defino o bloco ao clicar no botão Cancelar
	oNewPag:SetCancelAction({||oDlg:End()})

    ////////////////////////////////////////////////////////
    ///crio a pagina 2 do wizard - Planos Cadastrados
    ///////////////////////////////////////////////////////

	oNewPag := oStepWiz:AddStep("2")
	oNewPag:SetStepDescription("Planos Cadastrados")
	oNewPag:SetConstruction({|oPnlPlano| FwPlanos(oPnlPlano,@oBrwPlano,"QU05",cPlanoMark)})
	oNewPag:SetNextAction({|| lRet := ValProxTela("QU05",@cPlanoMark,oBrwPrd) })
	oNewPag:SetCancelAction({||lRet := .F.,oDlg:End()})

    ////////////////////////////////////////////////////////
    ///crio a pagina 3 do wizard - Servicos do Plano
    ///////////////////////////////////////////////////////
	oNewPag := oStepWiz:AddStep("3")
	oNewPag:SetStepDescription("Servicos do Plano")
	oNewPag:SetConstruction({|oPnlPrd| FwPlanos(oPnlPrd,@oBrwPrd,"QU36",cPlanoMark)})
	oNewPag:SetNextAction({|| lRet := ValProxTela("QU36",cPlanoMark,oBrwPrd) })
	oNewPag:SetCancelAction({||lRet := .F.,oDlg:End()})

    /////////////////////////////////////////////////////////
    ///crio a pagina 5 do wizard - Relatorio do Processamento
    /////////////////////////////////////////////////////////

	oNewPag := oStepWiz:AddStep("4", {|Panel|RelImport(Panel,@cRelProc)})

    //Altero a descrição do step
	oNewPag:SetStepDescription("Log do Processo")

	oNewPag:SetNextAction({|| VldArqRel(@nHdlLog,cRelProc) })

    //Defino o bloco ao clicar no botão Cancelar
	oNewPag:SetCancelAction({||oDlg:End()})

    /////////////////////////////////////////////////////////
    ///crio a pagina 6 do wizard - Processamento da Atualizacao
    /////////////////////////////////////////////////////////

	oNewPag := oStepWiz:AddStep("5", {|Panel| TelaResult(Panel,nHdlLog,cPlanoMark,cRelProc) })

    //Altero a descrição do step
	oNewPag:SetStepDescription("Resultado")

	oNewPag:SetNextAction({||oDlg:End(),.T.})

    //Defino o bloco ao clicar no botão Cancelar
	oNewPag:SetCancelAction({||.F.})

	oNewPag:SetCancelWhen({||.F.})

	oNewPag:SetPrevAction({||.F.})


	oStepWiz:Activate()

	ACTIVATE DIALOG oDlg CENTER

	oStepWiz:Destroy()

Return(Nil)

/*/{Protheus.doc} CriaPartSup
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

	@ 020 , 055 SAY oSay2 PROMPT "Siga atentamente os passos da rotina." SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

	@ 030 , 055 SAY oSay3 PROMPT "Atualização de Contratos - Plataforma Virtus" SIZE 200, 010 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

	@ 040 , 020 GROUP oGroup1 TO 042 , nLarguraPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL


Return()

/*/{Protheus.doc} Pag1Intrucoes
Instrucoes Iniciais do Wizard de Atualizacao
@author Raphael Martins
@since 29/06/2020
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

	cTexto1 += "Esta rotina tem como objetivo ajuda-lo no processo de atualização de contratos."                            + cPulaLinha
	cTexto1 += "Essa atualização consiste em atualizar os serviços habilitados de acordo com o cadastro de planos..."		+ cPulaLinha

	@ 065 , 020 SAY oSay1 PROMPT cTexto1 SIZE 300, 300 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL


Return()


/*/{Protheus.doc} FwPlanos
description
@type function
@version 
@author Raphael Martins 
@since 30/06/2020
@param oPanel, object, Panel onde sera criado a grid
@param oBrowse, object, Browse que sera criado
@param cAlias, character, Alias que sera criado
@param cPlanoMark, array, Dados do Plano selecionado
@return return_type, sem retorno
/*/
Static Function FwPlanos(oPanel,oBrowse,cAlias,cPlanoMark)

	Local oBtnPanel := TPanel():New(0,0,"",oPanel,,,,,,40,40)

	oBtnPanel:Align := CONTROL_ALIGN_ALLCLIENT

	//Cria tabela temporaria que vai conter os dADOS
	CriaTabTemp(cAlias,cPlanoMark)

	// Define o Browse
	oBrowse := FWBrowse():New(oBtnPanel)
	oBrowse:SetDataTable(.T.)
	oBrowse:SetAlias(cAlias)
	oBrowse:DisableReport()

	//##################################################################
	//					        DADOS DO PLANO
	//##################################################################


	if cAlias == "QU05"

		// Cria uma coluna de marca/desmarca
		oColumn := oBrowse:AddMarkColumns({||If( QU05->U05_OK == 'T','LBOK','LBNO')},{|oBrowse| MarkBrowse( oBrowse,cAlias,"U05_OK" ) },{|oBrowse|/* Função de HEADERCLICK*/})

		ADD COLUMN oColumn DATA { || U05_CODIGO } TITLE Alltrim(GetSx3Cache("U05_CODIGO","X3_TITULO")) SIZE TamSx3("U05_CODIGO")[1]     OF oBrowse
		ADD COLUMN oColumn DATA { || U05_DESCRI } TITLE Alltrim(GetSx3Cache("U05_DESCRI"  ,"X3_TITULO")) SIZE TamSx3("U05_DESCRI")[1]   OF oBrowse


	elseif cAlias == "QU36"

		oColumn := oBrowse:AddMarkColumns({||If( QU36->U36_OK == 'T','LBOK','LBNO')},{|oBrowse| MarkBrowse( oBrowse,cAlias,"U36_OK" ) },{|oBrowse|/* Função de HEADERCLICK*/})

		ADD COLUMN oColumn DATA { || U36_SERVIC } TITLE Alltrim(GetSx3Cache("U36_SERVIC","X3_TITULO")) SIZE TamSx3("U36_SERVIC")[1] OF oBrowse
		ADD COLUMN oColumn DATA { || U36_DESCRI } TITLE Alltrim(GetSx3Cache("U36_DESCRI"  ,"X3_TITULO")) SIZE TamSx3("U36_DESCRI")[1]   OF oBrowse
		ADD COLUMN oColumn DATA { || U36_QUANT } TITLE Alltrim(GetSx3Cache("U36_QUANT"  ,"X3_TITULO")) SIZE TamSx3("U36_QUANT")[1]   OF oBrowse


	endif

	oBrowse:SetSeek()
	oBrowse:Activate()

Return

/*/{Protheus.doc} CriaTabTemp
Cria tabela temporaria com os planos
@type function
@version 
@author Raphael Martins
@since 30/06/2020
@param cAlias, character, Alias que sera carregado
@param cPlanoMark, character, Dados do Plano que sera ou foi selecionado
@return return_type, sem retorno
/*/
Static Function CriaTabTemp(cAlias,cPlanoMark)

	Local oTable 	:= Nil
	Local aCampos	:= {}
	Local cIndice1	:= ""
	Local cIndice2	:= ""
	Local cIndice3  := ""

	if cAlias == "QU05"

		aCampos:= {	{"U05_OK"		,"C",001,0},;
			{"U05_CODIGO"	,"C",TamSX3("U05_CODIGO")[1],0},;
			{"U05_DESCRI" 	,"C",TamSX3("U05_DESCRI")[1],0} }

		cIndice1 := "U05_CODIGO"
		cIndice2 := "U05_OK"
		cIndice3 := "U05_DESCRI"

	elseif cAlias == "QU36"

		aCampos:= {	{"U36_OK"		,"C",001,0},;
			{"U36_SERVIC"	,"C",TamSX3("U36_SERVIC")[1],0},;
			{"U36_DESCRI"	,"C",TamSX3("U36_DESCRI")[1],0},;
			{"U36_QUANT"	,"N",TamSX3("U36_QUANT")[1],0} }

		cIndice1 := "U36_SERVIC"
		cIndice2 := "U36_OK"
		cIndice3 := "U36_DESCRI"

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
	GetTabTemp(cAlias,cPlanoMark)

Return

/*/{Protheus.doc} GetTabTemp
description
@type function
@version 
@author Raphael Martins
@since 30/06/2020
@param cAlias, character, Alias que sera carregado
@param cPlanoMark, character, Dados do Plano que sera ou foi selecionado
@return return_type, sem retorno
/*/
Static Function GetTabTemp(cAlias,cPlanoMark)

	Default cPlanoMark := ""
//Pega dados do Plano

	If cAlias == "QU05"

		cQry := " SELECT"
		cQry += " 	U05_CODIGO, "
		cQry += " 	U05_DESCRI "
		cQry += " FROM " + RETSQLNAME("U05") + " U05 "
		cQry += " WHERE U05.D_E_L_E_T_ = ' ' "
		cQry += " 	AND U05_FILIAL = '"+ xFilial("U05") + "' "
		cQry += " 	AND U05_SITUAC = 'A' "
		cQry += " 	ORDER BY U05_CODIGO "

		cQry := ChangeQuery(cQry)

		if Select("TR05") > 0
			TR05->(DbCloseArea())
		endif

		TcQuery cQry New Alias "TR05"

		While TR05->(!EOF())

			Reclock("QU05",.T.)

			QU05->U05_OK 		:= " "
			QU05->U05_CODIGO	:= TR05->U05_CODIGO
			QU05->U05_DESCRI	:= TR05->U05_DESCRI

			QU05->(MsUnLock())

			TR05->(DbSkip())
		EndDo

	else

		cQry := " SELECT"
		cQry += " 	U36_SERVIC,"
		cQry += " 	U36_DESCRI, "
		cQry += "   U36_QUANT "
		cQry += " FROM " + RETSQLNAME("U36") + " U36 "
		cQry += " WHERE U36.D_E_L_E_T_ = ' '"
		cQry += " 	AND U36_FILIAL = '"+ xFilial("U36") + "'"
		cQry += " 	AND U36_CODIGO = '" + cPlanoMark + "' "
		cQry += " 	ORDER BY U36_SERVIC"

		cQry := ChangeQuery(cQry)

		if Select("TR36") > 0
			TR36->(DbCloseArea())
		endif

		TcQuery cQry New Alias "TR36"

		While TR36->(!EOF())

			Reclock("QU36",.T.)

			QU36->U36_OK 		:= "T"
			QU36->U36_SERVIC	:= TR36->U36_SERVIC
			QU36->U36_DESCRI	:= TR36->U36_DESCRI
			QU36->U36_QUANT     := TR36->U36_QUANT

			QU36->(MsUnLock())

			TR36->(DbSkip())

		EndDo


	endif


Return()

/*/{Protheus.doc} MarkBrowse
description
@type function
@version 
@author Raphael Martins Garcia
@since 30/06/2020
@param oBrowse, object, Browse do objeto Grid
@param cAlias, character, Alias que esta sendo marcado
@param cCampo, character, Campo clicacdo
@return return_type, return_description
/*/
Static Function MarkBrowse(oBrowse,cAlias,cCampo)

	Local lRet 	    := .T.
	Local nPosAtu   := oBrowse:At()
	Local aArea	    := (cAlias)->(GetArea())
	Local cMark     := ""

	(cAlias)->(DbSetOrder(2))

	//Posiciona na linha que estava
	oBrowse:GoTo(nPosAtu)

	if cAlias == "QU05"

		//Valido se tem algum item ja marcado
		if (cAlias)->(MsSeek("T"))

			//Desmarco item
			Reclock(cAlias,.F.)
			(cAlias)->&(cCampo) := ' '
			(cAlias)->(MsUnLock())

		endif

	endif

	//Posiciona na linha que estava
	oBrowse:GoTo(nPosAtu)

	if (cAlias)->&(cCampo) == "T"
		cMark := ""
	else
		cMark := "T"
	endif

	//Marca item
	Reclock(cAlias,.F.)
	(cAlias)->&(cCampo) := cMark
	(cAlias)->(MsUnLock())

	(cAlias)->(DbSetOrder(1))

	oBrowse:Refresh()

	RestArea(aArea)

Return lRet
/*/{Protheus.doc} ValProxTela
description
@type function
@version 
@author Raphael Martins
@since 30/06/2020
@param cAlias, character, Alias Selecionado
@param cPlanoMark, character, Dados do Plano
@param oGrid, object, oGrid da Tela atual
@return return_type, return_description
/*/
Static Function ValProxTela(cAlias,cPlanoMark,oGrid)

	Local lRet 	   := .T.
	Local aArea	   := (cAlias)->(GetArea())

	(cAlias)->(DbSetOrder(2))

//Valido se tem algum item ja marcado
	if !(cAlias)->(MsSeek("T"))

		Aviso("Atenção","É necessário marcar um item pra prosseguir!",{"Ok"})
		lRet := .F.

	elseif cAlias == "QU05"

		cPlanoMark := (cAlias)->U05_CODIGO

		if Select("QU36") > 0 .And. oGrid <> NIL

			CriaTabTemp("QU36",cPlanoMark)

			oGrid:Refresh(.T.)

		endif

	endif


	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} RelImport
Funcao para montar panel de selecao
do arquivo de log a ser gerado da atualizacao
@author Raphael Martins
@since 02/07/2020
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function RelImport(oPanel,cRelProc)

	Local oFnt16		:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
	Local oFnt16N		:= TFont():New("Arial",,16,,.T.,,,,,.F.,.F.)
	Local oArqRel		:= NIL
	Local oBtnRel		:= NIL
	Local nLarguraPnl	:= oPanel:nClientWidth / 2
	Local cTexto1		:= ""
	Local cImgArq		:= "icone_file.png"
	Local cImgFileHover	:= "icone_file_foco.png"
	Local cCSSBtnFile	:= ""

//crio a parte superior da tela do wizard
	CriaPartSup(oPanel)

	@ 045 , 020 SAY oSay4 PROMPT "Informe o local do relatório de Atualizacao" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	cTexto1 := " Após a atualizacao dos contratos o sistema irá gerar um relatório constando todas os contratos atualizados.	"


	@ 060 , 020 SAY oSay1 PROMPT cTexto1 SIZE 300, 300 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

	@ 090 , 020 SAY oSay2 PROMPT "Relatório de Atualizacao:" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 107 , 020 GROUP oGroup1 TO 109 , nLarguraPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL

	@ 115 , 020 SAY oSay3 PROMPT "Diretório:" SIZE 050, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 115 , 070 MSGET oArqRel VAR cRelProc  SIZE 200,010 PIXEL  Font oFnt16 OF oPanel PICTURE "@!"

	oBtnRel	:= TButton():New(114,275,"" ,oPanel,{|| cRelProc := cGetFile( '*.csv' , 'Selecione o local', 16, , .F.,GETF_LOCALHARD,.F., .T. ) },22,22,,,.F.,.T.,.F.,,.F.,,,.F. )

	cCSSBtnFile := "QPushButton {"
	cCSSBtnFile += " background-image: url(rpo:" + cImgArq + ");background-repeat: none; margin: 2px;"
	cCSSBtnFile += " border-width: 1px;"
	cCSSBtnFile += " border-radius: 0px;"
	cCSSBtnFile += " }"
	cCSSBtnFile += "QPushButton:hover {"
	cCSSBtnFile += " background-image: url(rpo:" + cImgFileHover + ");background-repeat: none; margin: 2px; cover"
	cCSSBtnFile += " border-width: 1px;"
	cCSSBtnFile += " border-radius: 0px;"
	cCSSBtnFile += "}"

	oBtnRel:SetCss(cCSSBtnFile)

Return()

/*/{Protheus.doc} VldArqRel
Funcao para validar o arquivo digitado para
geracao do relatorio
@author Raphael Martins
@since 30/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

Static Function VldArqRel(nHdlLog,cRelProc)

	Local lRet 		:= .T.

	if !Empty(cRelProc)

		//crio arquivo de relatorio do processamento da atualizacao
		nHdlLog := MsfCreate(cRelProc + ".log",0)

		if nHdlLog < 0

			lRet := .F.
			Help(,,'Help',,"Não foi possivel criar o arquivo de relatorio do processamento, favor o diretorio selecionado!",1,0)

		endif

	endif

Return(lRet)

/*/{Protheus.doc} TelaResult
Funcao para montar tela de resultado final
da atualizacao 
@author Raphael Martins
@since 02/07/2020
@version P12
@param Nao recebe parametros
@return nulo
/*/										
Static Function TelaResult(oPanel,nHdlLog,cPlanoMark,cRelProc)

	Local oSay1 		:= NIL
	Local oSay2 		:= NIL
	Local oGroup1		:= NIL
	Local oProcessados	:= NIL
	Local oSucesso		:= NIL
	Local oFnt16		:= TFont():New("Arial",,16,,.F.,,,,,.F.,.F.)
	Local oFnt16N		:= TFont():New("Arial",,16,,.T.,,,,,.F.,.F.)
	Local nLarguraPnl	:= oPanel:nClientWidth / 2
	Local cTexto1		:= ""
	Local nRowsProces	:= 0

//crio a parte superior da tela do wizard
	CriaPartSup(oPanel)

	FWMsgRun(,{|oSay| ProcAtualizacao(oSay,@nRowsProces,nHdlLog,cPlanoMark)},'Aguarde...','Processando Atualizacao de Contratos.')

	@ 045 , 020 SAY oSay4 PROMPT "Processo de Atualizacao finalizado" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	cTexto1 := "Processo de Atualizacao finalizado, abaixo segue os dados processados!	"

	@ 060 , 020 SAY oSay1 PROMPT cTexto1 SIZE 300, 300 Font oFnt16 OF oPanel COLORS 0, 16777215 PIXEL

	@ 090 , 020 SAY oSay2 PROMPT "Resultado da Importação:" SIZE 200, 010 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 100 , 020 GROUP oGroup1 TO 102 , nLarguraPnl - 2 PROMPT "" OF oPanel COLOR 0, 16777215 PIXEL

	@ 107 , 020 SAY oSay3 PROMPT "Contratos Processados:" SIZE 080, 007 Font oFnt16N OF oPanel COLORS 0, 16777215 PIXEL

	@ 107 , 100 MSGET oProcessados VAR nRowsProces  SIZE 080,010 READONLY PIXEL  Font oFnt16 OF oPanel PICTURE "@E 9999999"

	@ 140 , 020 BUTTON oBtnImp PROMPT "Visualizar Log" SIZE 070, 015 OF oPanel PIXEL ACTION (ShellExecute("Open", cRelProc + ".log", " ", "C:\", 1 ))

Return()

/*/{Protheus.doc} ProcAtualizacao
Processa atualizacao
@type function
@version 1.0
@author Raphael Martins
@since 02/07/2020
@param oSay, object, Objeto do FWMsgRun
@param nProcessados, numeric, Contador de Contratos Atualizados
@param nArqLog, numeric, Arquivo de Log da Atualizacao
@param cPlanoMark, character, Plano selecionado
/*/
Static Function ProcAtualizacao(oSay,nProcessados,nArqLog,cPlanoMark)

	Local aArea         := GetArea()
	Local cQry          := ""
	Local cPulaLinha    := Chr(13) + Chr(10)
	Local nPrxItem      := 0
	Local nTamItem      := TamSX3("U37_ITEM")[1]

	//verifico se arquivo de log existe
	if nArqLog > 0

		fWrite(nArqLog , "#########  ATUALIZACAO CONTRATOS CEMITÉRIO #############")
		fWrite(nArqLog , cPulaLinha )
		fWrite(nArqLog , " >> Data Inicio: " + DTOC( Date() ) )
		fWrite(nArqLog , cPulaLinha )
		fWrite(nArqLog , " >> Hora Inicio: " + Time() )
		fWrite(nArqLog , cPulaLinha )

	endif

	U00->(DbSetOrder(1)) //U00_FILIAL + U00_CODIGO
	U37->(DbSetOrder(2)) //U37_FILIAL + U37_CODIGO + U37_SERVIC

	cQry := " SELECT "
	cQry += " U00_CODIGO AS CONTRATO "
	cQry += " FROM "
	cQry += RetSQLName("U00")
	cQry += " WHERE "
	cQry += " D_E_L_E_T_ = ' ' "
	cQry += " AND U00_FILIAL = '" + xFilial("U00") + "' "
	cQry += " AND U00_PLANO = '" + cPlanoMark + "' "
	cQry += " AND U00_STATUS NOT IN ('C','F') "

	cQry += " ORDER BY CONTRATO "

	if Select("QU00") > 0
		QU00->(DbCloseArea())
	endif

	TcQuery cQry New Alias "QU00"

	While QU00->(!Eof())

		oSay:cCaption := ("Atualizando o contrato: " + QU00->CONTRATO + " ...")
		ProcessMessages()

		QU36->(DbGotop())

		//Deleto Itens nao utilizados no Contrato
		DelNaoUtilizados(QU00->CONTRATO)

		//Corrijo o sequencial dos itens e retorno o ultimo item
		nPrxItem := CorrigeSequencial(QU00->CONTRATO)

		While QU36->(!Eof())

			//valido se o item esta marcado
			if !Empty(QU36->U36_OK)

				//valido se o produto esta ja esta no contrato
				if !U37->(MsSeek(xFilial("U37") + QU00->CONTRATO + QU36->U36_SERVIC ))

					cCtrSaldo := RetField("SB1",1,xFilial("SB1") + QU36->U36_SERVIC, "B1_XDEBPRE")
					cCtrSaldo := If(cCtrSaldo=="S","S","N")

					RecLock("U37",.T.)

					U37->U37_FILIAL      := xFilial("U37")
					U37->U37_CODIGO      := QU00->CONTRATO
					U37->U37_TIPO        := "AVGBOX1.PNG"
					U37->U37_ITEM        := StrZero(nPrxItem,nTamItem)
					U37->U37_SERVIC      := QU36->U36_SERVIC
					U37->U37_DESCRI      := QU36->U36_DESCRI
					U37->U37_CTRSLD      := cCtrSaldo
					U37->U37_QUANT       := QU36->U36_QUANT
					U37->U37_SALDO       := QU36->U36_QUANT

					U37->(MsUnlock())

					nPrxItem++

				endif

			endif

			QU36->(DbSkip())

		EndDo

		if nArqLog > 0

			fWrite(nArqLog , cPulaLinha )
			fWrite(nArqLog , " >> Contrato: " + QU00->CONTRATO + " processado com sucesso! " )
			fWrite(nArqLog , cPulaLinha )

		endif

		nProcessados++

		QU00->(DBSkip())

	Enddo

	//verifico se arquivo de log existe
	if nArqLog > 0

		// fecho o arquivo de log
		fClose(nArqLog)

	endif

	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} DelNaoUtilizados
Deleto Servicos nao utilizados no contrato
@type function
@version 
@author Raphael Martins 
@since 02/07/2020
@param cContrato, character, Codigo do Contrato
@return return_type, return_description
/*/
Static Function DelNaoUtilizados(cContrato)

	Local aArea     := GetArea()
	Local aAreaU37  := U37->(GetArea())
	Local cQry      := ""

	cQry := " SELECT "
	cQry += " U37_ITEM ITEM, "
	cQry += " U37_SERVIC SERVICO "
	cQry += " FROM "
	cQry += RetSQLName("U37") + " U37 "
	cQry += " WHERE "
	cQry += " U37.D_E_L_E_T_ = ' ' "
	cQry += " AND U37_FILIAL = '" + xFilial("U37") + "' "
	cQry += " AND U37_CODIGO = '" + cContrato + "' "
////////////////////////////////////////////////////////////
//NAO RETORNA SERVICOS QUE POSSUE APONTAMENTO DE SERVICO ///
////////////////////////////////////////////////////////////
	cQry += " AND NOT EXISTS ( SELECT "
	cQry += " 					UJV_CONTRA "
	cQry += " 				    FROM " + RetSQLName("UJV") + " UJV "
	cQry += " 				    WHERE UJV.D_E_L_E_T_ = '' "
	cQry += " 				    AND UJV_FILIAL = '" + xFilial("UJV") + "' "
	cQry += " 				    AND UJV_CONTRA = U37.U37_CODIGO "
	cQry += " 				    AND UJV.UJV_SERVIC = U37.U37_SERVIC "
	cQry += " 				  ) "
//////////////////////////////////////////////////////////////////////
//NAO RETORNA SERVICOS UTLIZADOS NA TRANSFERENCIA DE ENDERECAMENTO ///
/////////////////////////////////////////////////////////////////////
	cQry += " AND NOT EXISTS ( SELECT "
	cQry += " 					U38_CTRORI "
	cQry += " 				    FROM " + RetSQLName("U38") + " U38 "
	cQry += " 				    WHERE U38.D_E_L_E_T_ = '' "
	cQry += " 				    AND U38_FILIAL = ' ' "
	cQry += " 				    AND U38_CTRORI = U37.U37_CODIGO "
	cQry += " 				    AND U38.U38_SERVDE = U37.U37_SERVIC "
	cQry += " 				) "

	if Select("QU37") > 0
		QU37->(DbCloseArea())
	endif

	TcQuery cQry New Alias "QU37"

	U37->(DbSetOrder(1)) //U37_FILIAL + U37_CODIGO + U37_ITEM

	While QU37->(!Eof())

		if U37->(MSSeek( xFilial("U37") + cContrato + QU37->ITEM ))

			RecLock("U37",.F.)

			U37->(DbDelete())

			U37->(MsUnlock())

		endif

		QU37->(DbSkip())

	EndDo

	RestArea(aArea)
	RestArea(aAreaU37)

Return()
/*/{Protheus.doc} CorrigeSequencial
Funcao para Corrigir o Sequencial dos Itens
de Servico do Contrato
@type function
@version 
@author Raphael Martins 
@since 02/07/2020
@param cContrato, character, param_description
@return return_type, return_description
/*/
Static Function CorrigeSequencial(cContrato)

	Local aArea     := GetArea()
	Local aAreaU37  := U37->(GetArea())
	Local nTamItem  := TamSX3("U37_ITEM")[1]
	Local nItem     := 1

	U37->(DbSetOrder(1)) //U37_FILIAL + U37_CODIGO + U37_ITEM

	if U37->(MSSeek( xFilial("U37") + cContrato ))

		While U37->(!Eof()) .And. U37->U37_FILIAL == xFilial("U37") .And. U37->U37_CODIGO == cContrato

			//valido se o item do servico e diferente do contador sequencial,
			//caso seja diferente realizo a correcao do item.
			if U37->U37_ITEM <> StrZero(nItem,nTamItem)

				RecLock("U37",.F.)

				U37->U37_ITEM := StrZero(nItem,nTamItem)

			endif

			nItem++

			U37->(DbSkip())

		EndDo

	endif

	RestArea(aArea)
	RestArea(aAreaU37)

Return(nItem)
