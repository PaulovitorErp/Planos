#INCLUDE "PROTHEUS.CH"
#INCLUDE "hbutton.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} RUTIL010
Função que exporta o dicionário de dados.

@author [tbc] g.sampaio 
@since 18/02/2019
@version 1.0
@return nil
@param nil
@type function
/*/
User Function RUTIL010(cEmpExp,cFilExp)

	Local cMultSX2 	:= ""
	Local cMultSX3 	:= ""
	Local cMultSX6 	:= ""
	Local cMultSXB 	:= ""
	Local cDriver 	:= GetPVProfString("Drivers",'ACTIVE',"",GetADV97())
	Local lLevaSIX 	:= .T.
	Local lLevaSX7	:= .T.
	Local lLevaSXB	:= .T.
	Local lLevaSXA	:= .T.
	Local lLevaX3U	:= .T.
	Local lLevaSX9	:= .T.
	Local oButton1	:= Nil
	Local oButton2	:= Nil
	Local oButton3	:= Nil
	Local oButton4	:= Nil
	Local oGroupSX	:= Nil
	Local oGroupSX	:= Nil
	Local oGroupSX	:= Nil
	Local oGroupSX	:= Nil
	Local oGroupBT	:= Nil
	Local oSay1		:= Nil
	Local oSay2		:= Nil
	Local oMultSX2	:= Nil
	Local oMultSX3	:= Nil
	Local oMultSX6	:= Nil
	Local oMultSXB	:= Nil
	Local oLevaSIX	:= Nil
	Local oLevaSX7	:= Nil
	Local oLevaSXB	:= Nil
	Local oLevaSXA	:= Nil
	Local oLevaX3U	:= Nil
	Local oLevaSX9	:= Nil

	Default cEmpExp := ""
	Default cFilExp := ""

	Static oDlg		:= Nil

	DEFINE MSDIALOG oDlg TITLE " TBC - GERA DICIONÁRIO DE DADOS " FROM 000, 000  TO 624, 970 COLORS 0, 16777215 PIXEL

//////////////////////////////////////////////////  GRUPO SX2  ///////////////////////////////////////////////////////

	@ 005, 005 GROUP oGroupSX2 TO 105, 240 PROMPT "  SX2  " OF oDlg COLOR 0, 16777215 PIXEL
	@ 018, 010 SAY oSay7 PROMPT "Informe as tabelas separadas por espaço. Ex: SA1 SA2 SA3" SIZE 250, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 033, 010 GET oMultSX2 VAR cMultSX2 OF oDlg MULTILINE SIZE 225, 057 COLORS 0, 16777215 HSCROLL PIXEL

//////////////////////////////////////////////////  GRUPO SX3  ///////////////////////////////////////////////////////

	@ 005, 245 GROUP oGroupSX3 TO 105, 480 PROMPT "  SX3  " OF oDlg COLOR 0, 16777215 PIXEL
	@ 018, 250 SAY oSay7 PROMPT "Informe os campos separados por espaço. Ex: A1_COD A1_LOJA A1_NOME" SIZE 250, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 033, 250 GET oMultSX3 VAR cMultSX3 OF oDlg MULTILINE SIZE 225, 057 COLORS 0, 16777215 HSCROLL PIXEL

//////////////////////////////////////////////////  GRUPO SX6  ///////////////////////////////////////////////////////

	@ 110, 005 GROUP oGroupSX6 TO 215, 240 PROMPT "  SX6  " OF oDlg COLOR 0, 16777215 PIXEL
	@ 120, 010 SAY oSay7 PROMPT "Informe os parâmetros separados por espaço. Ex: MV_ESTNEG MV_CLIPAD" SIZE 250, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 138, 010 GET oMultSX6 VAR cMultSX6 OF oDlg MULTILINE SIZE 225, 067 COLORS 0, 16777215 HSCROLL PIXEL

//////////////////////////////////////////////////  GRUPO SXB  ///////////////////////////////////////////////////////

	@ 110, 245 GROUP oGroupSXB TO 215, 480 PROMPT "  SXB  " OF oDlg COLOR 0, 16777215 PIXEL
	@ 120, 250 SAY oSay7 PROMPT "Informe as consultas padrões separadas por espaço. Ex: ACY2 SA11" SIZE 250, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 138, 250 GET oMultSXB VAR cMultSXB OF oDlg MULTILINE SIZE 225, 067 COLORS 0, 16777215 HSCROLL PIXEL

///////////////////////////////////////////////  GRUPO DE CHECKBOX  ////////////////////////////////////////////////////

	@ 220, 005 GROUP oGroupBTN TO 290, 480 PROMPT "  Marque às Opções  " OF oDlg COLOR 0, 16777215 PIXEL

	@ 230, 010 CHECKBOX oLevaSIX VAR lLevaSIX PROMPT "Considerar Índices (SIX) das tabelas?" SIZE 150,10 OF oDlg PIXEL
	@ 240, 010 CHECKBOX oLevaSX7 VAR lLevaSX7 PROMPT "Considerar Gatilhos (SX7) dos campos?" SIZE 150,10 OF oDlg PIXEL
	@ 250, 010 CHECKBOX oLevaSXB VAR lLevaSXB PROMPT "Considerar Consultas (SXB) dos campos?" SIZE 150,10 OF oDlg PIXEL
	@ 260, 010 CHECKBOX oLevaSXA VAR lLevaSXA PROMPT "Considerar Pastas/Agrupadores (SXA) dos campos?" SIZE 150,10 OF oDlg PIXEL
	@ 270, 010 CHECKBOX oLevaX3U VAR lLevaX3U PROMPT "Considerar somente campos de usuário?" SIZE 150,10 OF oDlg PIXEL

	@ 230, 250 CHECKBOX oLevaSX9 VAR lLevaSX9 PROMPT "Considerar o relacionamento de tabelas(SX9)?" SIZE 150,10 OF oDlg PIXEL

///////////////////////////////////////////////  GRUPO DE BOTOES  ////////////////////////////////////////////////////

	@ 292, 255 BUTTON oButton1 PROMPT "Listar SX3" 	SIZE 040, 015 OF oDlg ACTION(fListSX3()) PIXEL
	@ 292, 300 BUTTON oButton2 PROMPT "Gerar Doc." 	SIZE 040, 015 OF oDlg ACTION(fGeraDoc(cMultSX2,cMultSX3,cMultSX6,cMultSXB,lLevaSIX,lLevaSX7,lLevaSXB,lLevaSXA)) PIXEL
	@ 292, 345 BUTTON oButton3 PROMPT "Gerar CSV"   SIZE 040, 015 OF oDlg ACTION(Confirmar(cMultSX2,cMultSX3,cMultSX6,cMultSXB,lLevaSIX,lLevaSX7,lLevaSXB,lLevaSXA,lLevaX3U,lLevaSX9)) PIXEL
	@ 292, 390 BUTTON oButton4 PROMPT "Cancelar"  	SIZE 040, 015 OF oDlg ACTION(oDlg:End()) PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return()

/*/{Protheus.doc} fListSX3
Carrega todos os campos de um intervalo de tabelas informada

@author [tbc] g.sampaio
@since 18/02/2019
@version 1.0
@return nil
@param nil
@type function
/*/
Static Function fListSX3()

	Local cListCamp	:= ""
	Local cErro		:= ""
	Local cOpc  	:= "0"
	Local cAliasDe 	:= Space(3)
	Local cAliasAt 	:= Space(3)
	Local lCampCust	:= .T.
	Local oButton1
	Local oGet1
	Local oGet2
	Local oSay1
	Local oSay2

	Static oDlgGer

	DEFINE MSDIALOG oDlgGer TITLE "Filtro de Tabelas" FROM 000, 000  TO 150, 200 COLORS 0, 16777215 PIXEL

	@ 011, 004 SAY oSay1 PROMPT "Tabela Inical:" SIZE 036, 007 OF oDlgGer COLORS 0, 16777215 PIXEL
	@ 010, 042 MSGET oGet1 VAR cAliasDe PICTURE "@!" SIZE 030, 010 OF oDlgGer COLORS 0, 16777215 PIXEL VALID iif(!empty(allTrim(cAliasDe)),fValAlias(cAliasDe),.T.)

	@ 028, 004 SAY oSay2 PROMPT "Tabela Final:" SIZE 037, 007 OF oDlgGer COLORS 0, 16777215 PIXEL
	@ 027, 042 MSGET oGet2 VAR cAliasAt PICTURE "@!" SIZE 031, 010 OF oDlgGer COLORS 0, 16777215 PIXEL VALID iif(!empty(alltrim(cAliasAt)),fValAlias(cAliasAt),.T.)

	@ 045, 004 CHECKBOX oLevaSXB VAR lCampCust PROMPT "Apenas campos customizados?" SIZE 150,10 OF oDlgGer PIXEL

	@ 062, 058 BUTTON oButton1 PROMPT "OK" SIZE 037, 012 OF oDlgGer ACTION(cOpc:="1",oDlgGer:End()) PIXEL

	ACTIVATE MSDIALOG oDlgGer CENTERED

// verifico se o "ok" foi apertado
	If cOpc == "1"
		MsAguarde({|| cListCamp := fListaX3(@cErro, cAliasDe, cAliasAt, lCampCust) },"Aguarde! Listando as tabelas selecionadas...")
	EndIf

// verifico se a lista de branco esta vazia e se houveram erros
	If !Empty(cListCamp) .and. Empty(cErro)

		cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cListCamp )
		Define Font oFont Name "Mono AS" Size 5, 12
		Define MsDialog oDlgDet Title "Lista Gerada" From 3, 0 to 340, 417 Pixel

		@ 5, 5 Get oMemo Var cListCamp Memo Size 200, 145 Of oDlgDet Pixel
		oMemo:bRClicked := { || AllwaysTrue() }
		oMemo:oFont     := oFont

		Define SButton From 153, 175 Type  1 Action oDlgDet:End() Enable Of oDlgDet Pixel // Apaga
		Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cListCamp ) ) ) Enable Of oDlgDet Pixel

		Activate MsDialog oDlgDet Center

	ElseIf !Empty(cErro)
		Aviso( "Atenção!", "Ocorreu o seguinte erro:"+cErro, {"Ok"} )
	elseIf Empty(cListCamp) .and. Empty(cErro) .and. cOpc == "1"
		MsgAlert("Não foi possível gerar a lista de campos da SX3, favor verificar os campos preenchidos!")
	EndIf

Return()

/*/{Protheus.doc} fListaX3
funcao para listar SX3 e auxiliar na geracao do dicionario de dados

@author [tbc] g.sampaio
@since 18/02/2019
@version 1.0
@return cRet, characters, lista os campos da tela
@param cErro, characters, variavel de erro
@param cAliasDe, characters, alias de inicio do intervalo de tabelas
@param cAliasAt, characters, alias de fim do intervalo de tabelas
@type function
/*/
Static Function fListaX3(cErro, cAliasDe, cAliasAt, lCampCust)

	Local aArea			:= GetArea()
	Local aAreaSX3		:= SX3->(GetArea())
	Local cRetorno		:= ""

	Default cErro		:= ""
	Default cAliasDe	:= ""
	Default cAliasAt	:= ""
	Default	lCampCust	:= .F.

// vou percorrer a SX3
	SX3->(DbSetOrder(1)) // X3_ARQUIVO + X3_ORDEM
	If SX3->(DbSeek(cAliasDe))
		While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO >= cAliasDe .AND. SX3->X3_ARQUIVO <= cAliasAt
			if lCampCust // verifico se considero os campos customizados
				if SX3->X3_PROPRI == "U" // X3_PROPRI igual a "U" - Campo de usuário
					cRetorno += " "+AllTrim(SX3->X3_CAMPO)// incremento a variavel de retorno
				endIf
			else
				cRetorno += " "+AllTrim(SX3->X3_CAMPO)// incremento a variavel de retorno
			endIf

			SX3->(DbSkip())
		EndDo
	EndIf

// dou um alltrom na variavel de retorno para limpar os campos vazios 
	cRetorno := AllTrim(cRetorno)

	RestArea(aAreaSX3)
	RestArea(aArea)

Return(cRetorno)

/*/{Protheus.doc} Confirmar
Função chamada na confirmação da rotina.

@author pablo
@since 27/09/2018
@version 1.0
@return ${return}, ${return_description}
@param cGetIP1, characters, descricao
@param nGetPt1, numeric, descricao
@param cGetAmb1, characters, descricao
@param cGetIP2, characters, descricao
@param nGetPt2, numeric, descricao
@param cGetAmb2, characters, descricao
@param cMultSX2, characters, descricao
@param cMultSX3, characters, descricao
@param cMultSX6, characters, descricao
@param cMultSXB, characters, descricao
@param cGetEmp1, characters, descricao
@param cGetFil1, characters, descricao
@param cGetEmp2, characters, descricao
@param cGetFil2, characters, descricao
@param lLevaSIX, logical, descricao
@param lLevaSX7, logical, descricao
@param lSalvaCSV, logical, descricao
@type function
/*/
Static Function Confirmar(cMultSX2,cMultSX3,cMultSX6,cMultSXB,lLevaSIX,lLevaSX7,lLevaSXB,lLevaSXA,lLevaX3U,lLevaSX9)

	Local aArea 		:= GetArea()
	Local aRetorno1		:= {}
	Local aRetorno2		:= {}
	Local cErro			:= ""

	Default cMultSX2	:= ""
	Default	cMultSX3	:= ""
	Default cMultSX6	:= ""
	Default cMultSXB	:= ""
	Default lLevaSIX	:= .F.
	Default lLevaSX7	:= .F.
	Default	lLevaSXB	:= .F.
	Default lLevaSXA	:= .F.
	Default lLevaX3U 	:= .F.
	Default lLevaSX9	:= .F.

// validacao de dados a serem exportados
	if Empty(cMultSX2) .AND. Empty(cMultSX3) .AND. Empty(cMultSX6) .AND. Empty(cMultSXB)
		Aviso( "Atenção!", "Não foram informados registros para serem exportados!", {"Ok"} )
	else

		// chamo a funcao para a exportacao de dados
		MsAguarde({|| aRetorno1 := fExpDados(cMultSX2,cMultSX3,cMultSX6,cMultSXB,@cErro,lLevaSIX,lLevaSX7,lLevaSXB,lLevaX3U,lLevaSX9,lLevaSXA) },"Aguarde! Conectando no servidor de origem...")

		// se existir ao menos um registro para ser replicado
		if empty(cErro)
			SalvaCSV(aClone(aRetorno1),@cErro)
		endif

		// verifico se nao houveram errros
		if Empty(cErro)
			Aviso( "Concluído!", "Exportação CSV concluída com sucesso!", {"Ok"} )
		else
			Aviso( "Erro!", cErro, {"Ok"} )
		endif

	endif

Return()

/*/{Protheus.doc} fExpDados
Função que conecta no servidor de origem.

@author pablo
@since 27/09/2018
@version 1.0
@return ${return}, ${return_description}
@param cIP, characters, descricao
@param nPorta, numeric, descricao
@param cEnv, characters, descricao
@param cGetEmp, characters, descricao
@param cGetFil, characters, descricao
@param cMultSX2, characters, descricao
@param cMultSX3, characters, descricao
@param cMultSX6, characters, descricao
@param cMultSXB, characters, descricao
@param cErro, characters, descricao
@param lLevaSIX, logical, descricao
@param lLevaSX7, logical, descricao
@param lLevaSXB, logical, descricao
@type function
/*/
Static Function fExpDados(cMultSX2,cMultSX3,cMultSX6,cMultSXB,cErro,lLevaSIX,lLevaSX7,lLevaSXB,lLevaX3U,lLevaSX9,lLevaSXA)

	Local aRetorno	:= {{},{},{},{},{},{},{},{}}
	Local oRpcSrv
	Default cErro	:= ""

	Default cMultSX2 	:= ""
	Default cMultSX3 	:= ""
	Default cMultSX6 	:= ""
	Default cMultSXB	:= ""
	Default cErro		:= ""
	Default lLevaSIX	:= .F.
	Default lLevaSX7	:= .F.
	Default lLevaSXB	:= .F.
	Default	lLevaX3U	:= .F.
	Default lLevaSX9	:= .F.
	Default	lLevaSXA	:= .F.

// verefico se a funcao existe no repositorio
	if existblock("UEXPSXS")
		// executa a funcao de exportacao dos da SX
		aRetorno := U_UEXPSXS(cMultSX2,cMultSX3,cMultSX6,cMultSXB,@cErro,lLevaSIX,lLevaSX7,lLevaSXB,lLevaX3U,lLevaSX9,lLevaSXA)
	endIf

Return(aRetorno)

/*/{Protheus.doc} UEXPSXS
Função executada no servidor de origem.
Responsável por captar as informações do dicionário de dados.

@author pablo
@since 27/09/2018
@version 1.0
@return ${return}, ${return_description}
@param cEmp, characters, descricao
@param cFil, characters, descricao
@param cMultSX2, characters, descricao
@param cMultSX3, characters, descricao
@param cMultSX6, characters, descricao
@param cMultSXB, characters, descricao
@param cErro, characters, descricao
@param lLevaSIX, logical, descricao
@param lLevaSX7, logical, descricao
@param lLevaSXB, logical, descricao
@type function
/*/
User Function UEXPSXS(cMultSX2,cMultSX3,cMultSX6,cMultSXB,cErro,lLevaSIX,lLevaSX7,lLevaSXB,lLevaX3U,lLevaSX9,lLevaSXA)

	Local aAreaSX2	:= {}
	Local aAreaSX3	:= {}
	Local aAreaSX6	:= {}
	Local aAreaSXB	:= {}
	Local aAreaSIX	:= {}
	Local aAreaSX7	:= {}
	Local aAreaSXA	:= {}
	Local aRet 		:= {{},{},{},{},{},{},{},{}}
	Local aSX2		:= {}
	Local aSX3		:= {}
	Local aSX6		:= {}
	Local aSXB		:= {}
	Local cCondicao	:= ""
	Local bCondicao
	Local nX		:= 0

	Default cMultSX2 	:= ""
	Default cMultSX3 	:= ""
	Default cMultSX6 	:= ""
	Default cMultSXB	:= ""
	Default cErro		:= ""
	Default lLevaSIX	:= .F.
	Default lLevaSX7	:= .F.
	Default lLevaSXB	:= .F.
	Default lLevaX3U	:= .F.
	Default lLevaSX9	:= .F.
	Default lLevaSXA	:= .F.

	aAreaSX2	:= SX2->(GetArea())
	aAreaSX3	:= SX3->(GetArea())
	aAreaSX6	:= SX6->(GetArea())
	aAreaSXB	:= SXB->(GetArea())
	aAreaSIX	:= SIX->(GetArea())
	aAreaSX7	:= SX7->(GetArea())
	aAreaSXA	:= SXA->(GetArea())
	aAreaSX9	:= SX9->(GetArea())

	aSX2 := StrToKarr(cMultSX2," ")
	aSX3 := StrToKarr(cMultSX3," ")
	aSX6 := StrToKarr(cMultSX6," ")
	aSXB := StrToKarr(cMultSXB," ")

	// para quando nao for preenchido os campos para paramtrizacao
	if len(aSX3) == 0

		// vou percorrer a SX2 e pegar os campos da tabela SX2
		For nX := 1 To Len( aSX2 )

			SX3->(dbSetOrder(1))
			SX3->(dbSeek(aSX2[nX]))
			while SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == aSX2[nX]

				// para quando eu considero apenas campos de usuario
				if lLevaX3U
					if SX3->X3_PROPRI == "U"	// campos de usuario
						aAdd(aSX3,SX3->X3_CAMPO)
					endIf
				else // para quando considerar todos os campos
					aAdd(aSX3,SX3->X3_CAMPO)
				endIf

				SX3->(DbSkip())

			EndDo
		Next nX

		SX3->( DbGoTop() )
	endIf

	SX2->(DbSetOrder(1)) // X2_CHAVE
	SX3->(DbSetOrder(2)) // X3_CAMPO
	SX6->(DbSetOrder(1)) // X6_FIL + X6_VAR
	SXB->(DbSetOrder(1)) // XB_ALIAS + XB_TIPO + XB_SEQ + XB_COLUNA
	SIX->(DbSetOrder(1)) // INDICE + ORDEM
	SX7->(DbSetOrder(1)) // X7_CAMPO + X7_SEQUENC
	SXA->(dbSetOrder(1)) // XA_ALIAS + XA_ORDEM
	SX9->(dbSetOrder(1)) // X9_DOM

	For nX := 1 To Len(aSX2)

		if SX2->(DbSeek(aSX2[nX]))

			aAux := {}

			aadd(aAux,{"X2_CHAVE"	,SX2->X2_CHAVE})
			aadd(aAux,{"X2_PATH"	,SX2->X2_PATH})
			aadd(aAux,{"X2_ARQUIVO"	,SX2->X2_ARQUIVO})
			aadd(aAux,{"X2_NOME"	,SX2->X2_NOME})
			aadd(aAux,{"X2_NOMESPA"	,SX2->X2_NOMESPA})
			aadd(aAux,{"X2_NOMEENG"	,SX2->X2_NOMEENG})
			aadd(aAux,{"X2_ROTINA"	,SX2->X2_ROTINA})
			aadd(aAux,{"X2_MODO"	,SX2->X2_MODO})
			aadd(aAux,{"X2_MODOUN"	,SX2->X2_MODOUN})
			aadd(aAux,{"X2_MODOEMP"	,SX2->X2_MODOEMP})
			aadd(aAux,{"X2_DELET"	,SX2->X2_DELET})
			aadd(aAux,{"X2_TTS"		,SX2->X2_TTS})
			aadd(aAux,{"X2_UNICO"	,SX2->X2_UNICO})
			aadd(aAux,{"X2_PYME"	,SX2->X2_PYME})
			aadd(aAux,{"X2_MODULO"	,SX2->X2_MODULO})
			aadd(aAux,{"X2_DISPLAY"	,SX2->X2_DISPLAY})

			aadd(aRet[1],{aSX2[nX],aAux})

			// vou popular os dados de indices
			if lLevaSIX
				if SIX->(DbSeek(aSX2[nX]))
					while SIX->(!Eof()) .AND. SIX->INDICE == aSX2[nX]
						aAux := {}

						aadd(aAux,{"INDICE"		,SIX->INDICE })
						aadd(aAux,{"ORDEM"		,SIX->ORDEM  })
						aadd(aAux,{"CHAVE"		,SIX->CHAVE  })
						aadd(aAux,{"DESCRICAO"	,SIX->DESCRICAO  })
						aadd(aAux,{"DESCSPA"	,SIX->DESCSPA })
						aadd(aAux,{"DESCENG"	,SIX->DESCENG  })
						aadd(aAux,{"PROPRI"		,SIX->PROPRI  })
						aadd(aAux,{"F3"			,SIX->F3  })
						aadd(aAux,{"NICKNAME"	,SIX->NICKNAME  })
						aadd(aAux,{"SHOWPESQ"	,SIX->SHOWPESQ  })

						aadd(aRet[5],{SIX->INDICE+SIX->ORDEM, aAux})

						SIX->(DbSkip())
					enddo
				endif
			endif

			// vou popular os dados de pastas e agrupadores
			if lLevaSXA
				if SXA->( dbSeek(aSX2[nX]) )
					While SXA->( !Eof() ) .and. SXA->XA_ALIAS == aSX2[nX]

						aAux := {}

						aadd(aAux,{"XA_ALIAS"		, SXA->XA_ALIAS })
						aadd(aAux,{"XA_ORDEM"		, SXA->XA_ORDEM })
						aadd(aAux,{"XA_DESCRIC"		, SXA->XA_DESCRIC})
						aadd(aAux,{"XA_DESCSPA"		, SXA->XA_DESCSPA })
						aadd(aAux,{"XA_DESCENG"		, SXA->XA_DESCENG })
						aadd(aAux,{"XA_PROPRI"		, SXA->XA_PROPRI })
						aadd(aAux,{"XA_AGRUP"		, SXA->XA_AGRUP })
						aadd(aAux,{"XA_TIPO"		, SXA->XA_TIPO })

						aadd(aRet[7],{SXA->XA_ALIAS+SXA->XA_ORDEM, aAux})

						SXA->( DbSkip() )
					EndDo
				endIf
			endIf

			// verifico se vou considerar o relacionamento de tabelas
			if lLevaSX9
				if SX9->(dbSeek(aSX2[nX]))
					While SX9->( !eof() ) .and. SX9->X9_DOM == aSX2[nX]

						aAux := {}

						aadd(aAux,{"X9_DOM"		, SX9->X9_DOM })
						aadd(aAux,{"X9_IDENT"	, SX9->X9_IDENT })
						aadd(aAux,{"X9_CDOM"	, SX9->X9_CDOM })
						aadd(aAux,{"X9_EXPDOM"	, SX9->X9_EXPDOM })

						aadd(aRet[8],{SX9->X9_DOM, aAux})

						SX9->( DbSkip() )
					EndDo
				EndIf
			endIf

		endif

	Next nX

	For nX := 1 To Len(aSX3)

		if SX3->(DbSeek(aSX3[nX]))

			aAux := {}

			aadd(aAux,{"X3_ARQUIVO"	,SX3->X3_ARQUIVO})
			aadd(aAux,{"X3_ORDEM"	,SX3->X3_ORDEM})
			aadd(aAux,{"X3_CAMPO"	,SX3->X3_CAMPO})
			aadd(aAux,{"X3_TIPO"	,SX3->X3_TIPO})
			aadd(aAux,{"X3_TAMANHO"	,SX3->X3_TAMANHO})
			aadd(aAux,{"X3_DECIMAL"	,SX3->X3_DECIMAL})
			aadd(aAux,{"X3_TITULO"	,SX3->X3_TITULO})
			aadd(aAux,{"X3_TITSPA"	,SX3->X3_TITSPA})
			aadd(aAux,{"X3_TITENG"	,SX3->X3_TITENG})
			aadd(aAux,{"X3_DESCRIC"	,SX3->X3_DESCRIC})
			aadd(aAux,{"X3_DESCSPA"	,SX3->X3_DESCSPA})
			aadd(aAux,{"X3_DESCENG"	,SX3->X3_DESCENG})
			aadd(aAux,{"X3_PICTURE"	,SX3->X3_PICTURE})
			aadd(aAux,{"X3_VALID"	,SX3->X3_VALID})
			aadd(aAux,{"X3_USADO"	,SX3->X3_USADO})
			aadd(aAux,{"X3_RELACAO"	,SX3->X3_RELACAO})
			aadd(aAux,{"X3_F3" 		,SX3->X3_F3})
			aadd(aAux,{"X3_NIVEL"	,SX3->X3_NIVEL})
			aadd(aAux,{"X3_RESERV"	,SX3->X3_RESERV})
			aadd(aAux,{"X3_CHECK"	,SX3->X3_CHECK})
			aadd(aAux,{"X3_TRIGGER"	,SX3->X3_TRIGGER})
			aadd(aAux,{"X3_PROPRI"	,SX3->X3_PROPRI})
			aadd(aAux,{"X3_BROWSE"	,SX3->X3_BROWSE})
			aadd(aAux,{"X3_VISUAL"	,SX3->X3_VISUAL})
			aadd(aAux,{"X3_CONTEXT"	,SX3->X3_CONTEXT})
			aadd(aAux,{"X3_OBRIGAT"	,SX3->X3_OBRIGAT})
			aadd(aAux,{"X3_VLDUSER"	,SX3->X3_VLDUSER})
			aadd(aAux,{"X3_CBOX"	,SX3->X3_CBOX})
			aadd(aAux,{"X3_CBOXSPA"	,SX3->X3_CBOXSPA})
			aadd(aAux,{"X3_CBOXENG"	,SX3->X3_CBOXENG})
			aadd(aAux,{"X3_PICTVAR"	,SX3->X3_PICTVAR})
			aadd(aAux,{"X3_WHEN"	,SX3->X3_WHEN})
			aadd(aAux,{"X3_INIBRW"	,SX3->X3_INIBRW})
			aadd(aAux,{"X3_GRPSXG"	,SX3->X3_GRPSXG})
			aadd(aAux,{"X3_FOLDER"	,SX3->X3_FOLDER})
			aadd(aAux,{"X3_PYME"	,SX3->X3_PYME})
			aadd(aAux,{"X3_CONDSQL"	,SX3->X3_CONDSQL})
			aadd(aAux,{"X3_CHKSQL"	,SX3->X3_CHKSQL})
			aadd(aAux,{"X3_IDXSRV"	,SX3->X3_IDXSRV})
			aadd(aAux,{"X3_ORTOGRA"	,SX3->X3_ORTOGRA})
			aadd(aAux,{"X3_IDXFLD"	,SX3->X3_IDXFLD})
			aadd(aAux,{"X3_TELA"	,SX3->X3_TELA})
			aadd(aAux,{"X3_AGRUP"	,SX3->X3_AGRUP})
			//aadd(aAux,{"X3_POSLGT"	,SX3->X3_POSLGT})

			aadd(aRet[2],{aSX3[nX],aAux})

			if lLevaSX7
				if SX7->(DbSeek(SX3->X3_CAMPO))
					while SX7->(!Eof()) .AND. SX7->X7_CAMPO == SX3->X3_CAMPO
						aAux := {}

						aadd(aAux,{"X7_CAMPO"	,SX7->X7_CAMPO })
						aadd(aAux,{"X7_SEQUENC"	,SX7->X7_SEQUENC  })
						aadd(aAux,{"X7_REGRA"	,SX7->X7_REGRA  })
						aadd(aAux,{"X7_CDOMIN"	,SX7->X7_CDOMIN  })
						aadd(aAux,{"X7_TIPO"	,SX7->X7_TIPO })
						aadd(aAux,{"X7_SEEK"	,SX7->X7_SEEK  })
						aadd(aAux,{"X7_ALIAS"	,SX7->X7_ALIAS  })
						aadd(aAux,{"X7_ORDEM"	,SX7->X7_ORDEM  })
						aadd(aAux,{"X7_CHAVE"	,SX7->X7_CHAVE  })
						aadd(aAux,{"X7_CONDIC"	,SX7->X7_CONDIC  })
						aadd(aAux,{"X7_PROPRI"	,SX7->X7_PROPRI  })

						aadd(aRet[6],{SX7->X7_CAMPO+SX7->X7_SEQUENC, aAux})

						SX7->(DbSkip())
					enddo
				endif
			endif

			if lLevaSXB .and. !Empty(SX3->X3_F3)
				if SXB->(DbSeek(SX3->X3_F3))
					while SXB->(!Eof()) .AND. SXB->XB_ALIAS == SX3->X3_F3
						if aScan(aRet[4],{|x| AllTrim(x[1])==AllTrim(SXB->(XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA))}) <= 0
							aAux := {}

							aadd(aAux,{"XB_ALIAS"	,SXB->XB_ALIAS})
							aadd(aAux,{"XB_TIPO"	,SXB->XB_TIPO})
							aadd(aAux,{"XB_SEQ"		,SXB->XB_SEQ})
							aadd(aAux,{"XB_COLUNA"	,SXB->XB_COLUNA})
							aadd(aAux,{"XB_DESCRI"	,SXB->XB_DESCRI})
							aadd(aAux,{"XB_DESCSPA"	,SXB->XB_DESCSPA})
							aadd(aAux,{"XB_DESCENG"	,SXB->XB_DESCENG})
							aadd(aAux,{"XB_CONTEM"	,SXB->XB_CONTEM})
							aadd(aAux,{"XB_WCONTEM"	,SXB->XB_WCONTEM})

							aadd(aRet[4],{SXB->XB_ALIAS + SXB->XB_TIPO + SXB->XB_SEQ + SXB->XB_COLUNA ,aAux})
						endif
						SXB->(DbSkip())
					enddo
				endif
			endif

		endif

	Next nX

	For nX := 1 To Len(aSX6)

		// limpo os filtros da SX6
		SX6->(DbClearFilter())

		cCondicao := " AllTrim(SX6->X6_VAR) = '" + aSX6[nX] + "' "
		bCondicao := "{|| " + cCondicao + " }"

		// faço um filtro na SX6
		SX6->(DbSetFilter(&bCondicao,cCondicao))

		SX6->(DbGoTop())

		While SX6->(!Eof())

			aAux := {}

			aadd(aAux,{"X6_FIL"		,SX6->X6_FIL})
			aadd(aAux,{"X6_VAR"		,SX6->X6_VAR})
			aadd(aAux,{"X6_TIPO"	,SX6->X6_TIPO})
			aadd(aAux,{"X6_DESCRIC"	,SX6->X6_DESCRIC})
			aadd(aAux,{"X6_DSCSPA"	,SX6->X6_DSCSPA})
			aadd(aAux,{"X6_DSCENG"	,SX6->X6_DSCENG})
			aadd(aAux,{"X6_DESC1"	,SX6->X6_DESC1})
			aadd(aAux,{"X6_DSCSPA1"	,SX6->X6_DSCSPA1})
			aadd(aAux,{"X6_DSCENG1"	,SX6->X6_DSCENG1})
			aadd(aAux,{"X6_DESC2"	,SX6->X6_DESC2})
			aadd(aAux,{"X6_DSCSPA2"	,SX6->X6_DSCSPA2})
			aadd(aAux,{"X6_DSCENG2"	,SX6->X6_DSCENG2})
			aadd(aAux,{"X6_CONTEUD"	,SX6->X6_CONTEUD})
			aadd(aAux,{"X6_CONTSPA"	,SX6->X6_CONTSPA})
			aadd(aAux,{"X6_CONTENG"	,SX6->X6_CONTENG})
			aadd(aAux,{"X6_PROPRI"	,SX6->X6_PROPRI})
			aadd(aAux,{"X6_VALID"	,SX6->X6_VALID})
			aadd(aAux,{"X6_INIT"	,SX6->X6_INIT})
			aadd(aAux,{"X6_DEFPOR"	,SX6->X6_DEFPOR})
			aadd(aAux,{"X6_DEFSPA"	,SX6->X6_DEFSPA})
			aadd(aAux,{"X6_DEFENG"	,SX6->X6_DEFENG})

			aadd(aRet[3],{SX6->X6_FIL + SX6->X6_VAR,aAux})

			SX6->(DbSkip())

		EndDo

		// limpo os filtros da SX6
		SX6->(DbClearFilter())

	Next nX

	For nX := 1 To Len(aSXB)

		// limpo os filtros da SXB
		SXB->(DbClearFilter())

		cCondicao := " AllTrim(XB_ALIAS) = '" + aSXB[nX] + "' "
		bCondicao := "{|| " + cCondicao + " }"

		// faço um filtro na SXB
		SXB->(DbSetFilter(&bCondicao,cCondicao))

		SXB->(DbGoTop())

		While SXB->(!Eof())
			if aScan(aRet[4],{|x| AllTrim(x[1])==AllTrim(SXB->(XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA))}) <= 0
				aAux := {}

				aadd(aAux,{"XB_ALIAS"	,SXB->XB_ALIAS})
				aadd(aAux,{"XB_TIPO"	,SXB->XB_TIPO})
				aadd(aAux,{"XB_SEQ"		,SXB->XB_SEQ})
				aadd(aAux,{"XB_COLUNA"	,SXB->XB_COLUNA})
				aadd(aAux,{"XB_DESCRI"	,SXB->XB_DESCRI})
				aadd(aAux,{"XB_DESCSPA"	,SXB->XB_DESCSPA})
				aadd(aAux,{"XB_DESCENG"	,SXB->XB_DESCENG})
				aadd(aAux,{"XB_CONTEM"	,SXB->XB_CONTEM})
				aadd(aAux,{"XB_WCONTEM"	,SXB->XB_WCONTEM})

				aadd(aRet[4],{SXB->XB_ALIAS + SXB->XB_TIPO + SXB->XB_SEQ + SXB->XB_COLUNA ,aAux})
			endif
			SXB->(DbSkip())

		EndDo

		// limpo os filtros da SXB
		SXB->(DbClearFilter())

	Next nX

	RestArea(aAreaSX2)
	RestArea(aAreaSX3)
	RestArea(aAreaSX6)
	RestArea(aAreaSXB)
	RestArea(aAreaSIX)
	RestArea(aAreaSX7)

Return(aRet)


/*/{Protheus.doc} UConDestino
Função executada no servidor de destino.
Responsável por atualizar o dicionário de dados.

@author pablo
@since 27/09/2018
@version 1.0
@return ${return}, ${return_description}
@param cEmp, characters, descricao
@param cFil, characters, descricao
@param aDados, array, descricao
@param cErro, characters, descricao
@type function
/*/
/*User Function UConDestino(cEmp,cFil,aDados,cErro)

Local aAreaSX2
Local aAreaSX3
Local aAreaSX6
Local aAreaSXB
Local aAreaSIX
Local aAreaSX7
Local aRet 		:= {}
Local lLock		:= .F.
Default cErro	:= ""

*/  
/*
	If !MyOpenSm0(.F.,@cErro)
	cErro := "SEM ACESSO EXCLUSIVO A EMPRESA"
	CONOUT(">> " + cErro  )
	Return(aRet)
	EndIf
*/

/*  
// preparo o ambiente para empresa e filial passados como parâmetro
RpcSetType(3)
Reset Environment
lConect := RpcSetEnv(cEmp,cFil)

	if lConect
	CONOUT(">> CONEXAO REALIZADA COM SUCESSO NA EMPRESA: " + Alltrim(cEmp) + " FILIAL: " + Alltrim(cFil))
	else
	cErro :=  "NAO FOI POSSIVEL REALIZAR CONEXAO NA EMPRESA: " + Alltrim(cEmp) + " FILIAL: " + Alltrim(cFil)
	CONOUT(">> " + cErro  )
	Return(aRet)
	endif

aAreaSX2	:= SX2->(GetArea())
aAreaSX3	:= SX3->(GetArea())
aAreaSX6	:= SX6->(GetArea())
aAreaSXB	:= SXB->(GetArea())
aAreaSIX	:= SIX->(GetArea())
aAreaSX7	:= SX7->(GetArea())

SX2->(DbSetOrder(1)) // X2_CHAVE
SX3->(DbSetOrder(2)) // X3_CAMPO
SX6->(DbSetOrder(1)) // X6_FIL + X6_VAR
SXB->(DbSetOrder(1)) // XB_ALIAS + XB_TIPO + XB_SEQ + XB_COLUNA
SIX->(DbSetOrder(1)) // INDICE + ORDEM
SX7->(DbSetOrder(1)) // X7_CAMPO + X7_SEQUENC

	For nX := 1 To Len(aDados[1])

		if SX2->(DbSeek(aDados[1][nX][1]))
		lLock := RecLock("SX2",.F.)
		else
		lLock := RecLock("SX2",.T.)
		endif

		if lLock

			For nY := 1 To Len(aDados[1][nX][2])
			&(aDados[1][nX][2][nY][1]) := aDados[1][nX][2][nY][2]
			Next nY

		SX2->(MsUnLock())

		endif

	Next nX

	For nX := 1 To Len(aDados[2])

		if SX3->(DbSeek(aDados[2][nX][1]))
		lLock := RecLock("SX3",.F.) // Altera
		else
		lLock := RecLock("SX3",.T.) // Inclui
		endif

		if lLock

			For nY := 1 To Len(aDados[2][nX][2])
			&(aDados[2][nX][2][nY][1]) := aDados[2][nX][2][nY][2]
			Next nY

		SX3->(MsUnLock())

		endif

	Next nX

	For nX := 1 To Len(aDados[3])

		if SX6->(DbSeek(aDados[3][nX][1]))
		CONOUT(">> ALTERACAO - " + aDados[3][nX][1])
		lLock := RecLock("SX6",.F.) // Altera
		else
		CONOUT(">> INCLUSAO - " + aDados[3][nX][1])
		lLock := RecLock("SX6",.T.) // Inclui
		endif

		if lLock

			For nY := 1 To Len(aDados[3][nX][2])
			&(aDados[3][nX][2][nY][1]) := aDados[3][nX][2][nY][2]
			Next nY

		SX6->(MsUnLock())

		endif

	Next nX

	For nX := 1 To Len(aDados[4])

		if SXB->(DbSeek(aDados[4][nX][1]))
		CONOUT(">> ALTERACAO - " + aDados[4][nX][1])
		lLock := RecLock("SXB",.F.) // Altera
		else
		CONOUT(">> INCLUSAO - " + aDados[4][nX][1])
		lLock := RecLock("SXB",.T.) // Inclui
		endif

		if lLock

			For nY := 1 To Len(aDados[4][nX][2])
			&(aDados[4][nX][2][nY][1]) := aDados[4][nX][2][nY][2]
			Next nY

		SXB->(MsUnLock())

		endif

	Next nX

	For nX := 1 To Len(aDados[5])

		if SIX->(DbSeek(aDados[5][nX][1]))
		lLock := RecLock("SIX",.F.)
		else
		lLock := RecLock("SIX",.T.)
		endif

		if lLock

			For nY := 1 To Len(aDados[5][nX][2])
			&(aDados[5][nX][2][nY][1]) := aDados[5][nX][2][nY][2]
			Next nY

		SIX->(MsUnLock())

		endif

	Next nX

	For nX := 1 To Len(aDados[6])

		if SX7->(DbSeek(aDados[6][nX][1]))
		lLock := RecLock("SX7",.F.)
		else
		lLock := RecLock("SX7",.T.)
		endif

		if lLock

			For nY := 1 To Len(aDados[6][nX][2])
			&(aDados[6][nX][2][nY][1]) := aDados[6][nX][2][nY][2]
			Next nY

		SX7->(MsUnLock())

		endif

	Next nX

RestArea(aAreaSX2)
RestArea(aAreaSX3)
RestArea(aAreaSX6)
RestArea(aAreaSXB)
RestArea(aAreaSIX)
RestArea(aAreaSX7)

Return(aRet)*/

/*/{Protheus.doc} SalvaCSV
Salva o dicionario em arquivo CSV local...

@author pablo
@since 27/09/2018
@version 1.0

@return ${return}, ${return_description}
@param cGetEmp2, characters, descricao
@param cGetFil2, characters, descricao
@param aRetorno1, array, descricao
@param cErro, characters, descricao
@type function
/*/
Static Function SalvaCSV(aRet,cErro)

	Local aArea		:= GetArea()
	Local cPathSX 	:= ""
	Local cCab 		:= "", cLin := ""
	Local cPrefix 	:= "tbcpar"//dtos(date()) + strTran(time(),":","") + "_" + criatrab(,.F.)
	Local cArqGer	:= ""
	Local nX 		:= 1, nY := 1, nZ := 1
	Local oWriter	:= Nil

	Default aRet		:= {}
	Default cErro		:= ""

// pego o diretorio aonde serão criados os arquivos de compatibilizacao
	cPathSX := cGetFile( "Selecione Diretoriro CSV | " , OemToAnsi( "Selecione Diretorio CSV" ) , NIL , "C:\" , .F. , GETF_LOCALHARD+GETF_RETDIRECTORY )
	iif((len(cPathSX)>0) .and. (substr(cPathSX,Len(cPathSX),1)<>iif(IsSrvUnix(),"/","\")), cPathSX:=cPathSX+iif(IsSrvUnix(),"/","\"), )

	For nZ:=1 to Len(aRet)

		// limpo o nome do arquivo
		cNomeArq := ""

		DO CASE
		case nZ == 1 .and. len(aRet[1]) > 0 // para SX2 - tabelas
			cNomeArq := "sx2_" + cPrefix + ".csv"
		case nZ == 2 .and. len(aRet[2]) > 0 // para SX3 - campos
			cNomeArq := "sx3_" + cPrefix + ".csv"
		case nZ == 3 .and. len(aRet[3]) > 0 // para SX6 - parametros
			cNomeArq := "sx6_" + cPrefix + ".csv"
		case nZ == 4 .and. len(aRet[4]) > 0 // para SXB - consultas padrao
			cNomeArq := "sxb_" + cPrefix + ".csv"
		case nZ == 5 .and. len(aRet[5]) > 0 // para SIX - indices
			cNomeArq := "six_" + cPrefix + ".csv"
		case nZ == 6 .and. len(aRet[6]) > 0 // para SX7 - gatilhos
			cNomeArq := "sx7_" + cPrefix + ".csv"
		case nZ == 7 .and. len(aRet[7]) > 0 // para SXA - pastas e agrupadores
			cNomeArq := "sxa_" + cPrefix + ".csv"
		case nZ == 8 .and. len(aRet[8]) > 0 // para SX9 - relacionamentos de tabelas
			cNomeArq := "sx9_" + cPrefix + ".csv"
		ENDCASE

		// verifico se o nome do arquivo foi preenchido
		if !Empty(cNomeArq)

			cCab := ""; cLin := ""
			nPosX3Obr := 0 //--tratamento para caracter NUL dentro do campo X3_OBRIGAT
			nPosX3cB1 := 0 //--tratamento para caracteres ";" dentro dos campo X3_CBOX
			nPosX3cB2 := 0 //--tratamento para caracteres ";" dentro dos campo X3_CBOXSPA
			nPosX3cB3 := 0 //--tratamento para caracteres ";" dentro dos campo X3_CBOXENG

			For nX:=1 to Len(aRet[nZ])
				For nY:=1 to Len(aRet[nZ][nX][2])

					//-- preenche o array de cabeçalho
					If nX==1
						cCab += aRet[nZ][nX][2][nY][1] + iif(nY<>Len(aRet[nZ][nX][2]),";","")

						If AllTrim(aRet[nZ][nX][2][nY][1]) == "X3_OBRIGAT"
							nPosX3Obr := nY
						EndIf

						If AllTrim(aRet[nZ][nX][2][nY][1]) == "X3_CBOX"
							nPosX3cB1 := nY
						EndIf

						If AllTrim(aRet[nZ][nX][2][nY][1]) == "X3_CBOXSPA"
							nPosX3cB2 := nY
						EndIf

						If AllTrim(aRet[nZ][nX][2][nY][1]) == "X3_CBOXENG"
							nPosX3cB3 := nY
						EndIf
					EndIf

					//-- preenche o array de linhas
					//--tratamento para caracter NUL dentro do campo X3_OBRIGAT
					If nPosX3Obr>0 .and. nPosX3Obr=nY
						cLin += ""  + iif(nY<>Len(aRet[nZ][nX][2]),";","")
						//--tratamento para caracteres ";" dentro dos campos: X3_CBOX, X3_CBOXSPA,X3_CBOXENG
					ElseIf (nPosX3cB1>0 .and. nPosX3cB1=nY) .or. (nPosX3cB2>0 .and. nPosX3cB2=nY) .or. (nPosX3cB3>0 .and. nPosX3cB3=nY)
						cLin += StrTran( AllTrim(UtoString(aRet[nZ][nX][2][nY][2])), ";", "|" )  + iif(nY<>Len(aRet[nZ][nX][2]),";","")
					Else
						cLin += AllTrim(UtoString(aRet[nZ][nX][2][nY][2]))  + iif(nY<>Len(aRet[nZ][nX][2]),";","")
					EndIf

				Next nY
				cLin += iif(nX<>Len(aRet[nZ]),CRLF,"")
			Next nX

			// monto o texto do arquivo
			cTexto := cLin

			// vou criar a variavel para gerar o arquivo de parametros
			cArqGer := cPathSX + iif( substr(alltrim(cPathSX),len(alltrim(cPathSX))) == iif(IsSrvUnix(),"/","\"),  cNomeArq, iif(IsSrvUnix(),"/","\") + cNomeArq )

			// crio o objeto de escrita de arquivo
			oWriter := FWFileWriter():New( cArqGer, .T.)

			// se houve falha ao criar, mostra a mensagem
			If !oWriter:Create()
				MsgStop("Houve um erro ao gerar o arquivo: " + CRLF + oWriter:Error():Message, "Atenção")

				RestArea(aArea)

				Return()

			Else// senão, continua com o processamento

				// escreve uma frase qualquer no arquivo
				oWriter:Write( cCab + CRLF)

				// escrevo os dados do arquivo
				oWriter:Write( cTexto )

				// encerra o arquivo
				oWriter:Close()

			EndIf

			FreeObj(oWriter)
			oWriter := Nil

		endIf

	Next nZ

	RestArea( aArea )

Return

/*/{Protheus.doc} UtoString
Funcao para transformar variavis em string.

@author pablo
@since 27/09/2018
@version 1.0
@return ${return}, ${return_description}
@param xValue, , descricao
@type function
/*/
Static Function UtoString(xValue)

	Local cRet, nI, cType
	Local cAspas := ''//'"'

	cType := valType(xValue)

	DO CASE
	case cType == "C"
		return cAspas+ xValue +cAspas
	case cType == "N"
		return CvalToChar(xValue)
	case cType == "L"
		return if(xValue,'.T.','.F.')
	case cType == "D"
		return cAspas+ DtoC(xValue) +cAspas
	case cType == "U"
		return "null"
	case cType == "A"
		cRet := '['
		For nI := 1 to len(xValue)
			if(nI != 1)
				cRet += ', '
			endif
			cRet += UtoString(xValue[nI])
		Next
		return cRet + ']'
	case cType == "B"
		return cAspas+'Type Block'+cAspas
	case cType == "M"
		return cAspas+'Type Memo'+cAspas
	case cType =="O"
		return cAspas+'Type Object'+cAspas
	case cType =="H"
		return cAspas+'Type Object'+cAspas
	ENDCASE

return("invalid type")


/*/{Protheus.doc} XUPDTSP
Funcao para compatibilizacao do modulo de postumos

@author g.sampaio - guilherme.sampaio@totvs.com.br
@since 16/01/2019
@version 1.0
@return ${return}, ${return_description}
@param xValue, , descricao
@type function
/*/
//User Function XUPDTSP()

//msgAlert("Essa funcao ainda esta em desenvolvimento!")

//Return()


/*/{Protheus.doc} fGeraDoc
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fGeraDoc(cMultSX2,cMultSX3,cMultSX6,cMultSXB,lLevaSIX,lLevaSX7,lLevaSXB,lLevaSXA)

	Local aArea		:= GetArea()
	Local aSX2		:= {}		// array para receber os dados da SX2 - Tabelas
	Local aSX3		:= {}		// array para receber os dados da SX3 - Campos
	Local aSX6		:= {}		// array para receber os dados da SX6 - Parametros
	Local aSIX 		:= {}		// array para receber os dados da SIX - Indices
	Local cOpc		:= ""
	Local cPasta	:= ""
	Local lCheckBo1 := .T.
	Local lCheckBo2 := .T.
	Local lCheckBo3 := .T.
	Local lCheckBo4 := .T.
	Local lCheckBo5 := .T.
	Local lCheckBo6 := .T.
	Local oButton1
	Local oButton2
	Local oCheckBo1
	Local oCheckBo2
	Local oCheckBo3
	Local oCheckBo4
	Local oCheckBo5
	Local oCheckBo6
	Local oGroup1

	Static oDlgDoc

	Default cMultSX2 	:= ""
	Default cMultSX3	:= ""
	Default cMultSX6	:= ""
	Default cMultSXB	:= ""
	Default lLevaSIX	:= .F.
	Default lLevaSX7	:= .F.
	Default lLevaSXA	:= .F.
	Default lLevaSXB	:= .F.

	DEFINE MSDIALOG oDlgDoc TITLE "Gera Documentacao" FROM 000, 000  TO 350, 500 COLORS 0, 16777215 PIXEL

	@ 003, 003 GROUP oGroup1 TO 170, 245 PROMPT "Gera Documentacao" OF oDlgDoc COLOR 0, 16777215 PIXEL

	@ 020, 015 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT "Completa" SIZE 048, 008 OF oDlgDoc COLORS 0, 16777215 PIXEL VALID fMarcTodos(lCheckBo1,@lCheckBo2,@lCheckBo3,@lCheckBo4,@lCheckBo5,@lCheckBo6,@oCheckBo1,@oCheckBo2,@oCheckBo3,@oCheckBo4,@oCheckBo5,@oCheckBo6)
	@ 035, 030 CHECKBOX oCheckBo2 VAR lCheckBo2 PROMPT "SX2 - Tabelas" SIZE 110, 008 OF oDlgDoc COLORS 0, 16777215 PIXEL VALID fValMarc(@lCheckBo1,@oCheckBo1,lCheckBo2)
	@ 050, 030 CHECKBOX oCheckBo3 VAR lCheckBo3 PROMPT "SX3 - Campos" SIZE 048, 008 OF oDlgDoc COLORS 0, 16777215 PIXEL VALID fValMarc(@lCheckBo1,@oCheckBo1,lCheckBo3)
	@ 065, 030 CHECKBOX oCheckBo4 VAR lCheckBo4 PROMPT "SIX - Indices" SIZE 048, 008 OF oDlgDoc COLORS 0, 16777215 PIXEL VALID fValMarc(@lCheckBo1,@oCheckBo1,lCheckBo4)
	@ 080, 030 CHECKBOX oCheckBo5 VAR lCheckBo5 PROMPT "SX7 - Gatilhos" SIZE 048, 008 OF oDlgDoc COLORS 0, 16777215 PIXEL VALID fValMarc(@lCheckBo1,@oCheckBo1,lCheckBo5)
	@ 095, 030 CHECKBOX oCheckBo6 VAR lCheckBo6 PROMPT "SXB - Consultas Padrão" SIZE 084, 008 OF oDlgDoc COLORS 0, 16777215 PIXEL VALID fValMarc(@lCheckBo1,@oCheckBo1,lCheckBo6)

	@ 150, 160 BUTTON oButton2 PROMPT "Confirmar" SIZE 037, 012 OF oDlgDoc PIXEL ACTION(cOpc:="1",oDlgDoc:End())
	@ 150, 200 BUTTON oButton1 PROMPT "Cancelar" SIZE 037, 012 OF oDlgDoc PIXEL ACTION oDlgDoc:End()

	ACTIVATE MSDIALOG oDlgDoc CENTERED

// caso a opcao de confirmar tenha sido assinalada
	if cOpc == "1"

		// pego o diretorio onde serao gravados os arquivos html com a documentacao
		cPasta		:= cGetFile( "Arquivo Html(*.html) |*.HTML | ", "Selecione a pasta e nome do arquivo *.html",1,'C:\',.F.,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY  ))

		// alimento os arraus de dicionarios
		aSX2 := StrToKarr(cMultSX2," ")	// pego as tabelas
		aSX3 := StrToKarr(cMultSX3," ")	// pego os campos
		aSX6 := StrToKarr(cMultSX6," ")	// pego os parametros
		aSXB := StrToKarr(cMultSXB," ")	// pego as consultas padrao

	/**
	nTipo: Tipo da documentação:								  
 		1 =	Completa (tabela, campos, indices, gatilhos)	  
 		2 =	Tabela (SX2)									  
 		3 =	Campos (SX3)									  
 		4 =	Indices (SIX)									  
 		5 =	Gatilhos (SX7)							  		  
 		6 =	Consulta Padrão (SXB)	
	*/
		// 1 =	Completa (tabela, campos, indices, gatilhos)
		if lCheckBo1
			U_RUTIL012(1,, cPasta, aSX2, aSX3, aSX6, aSXB, lLevaSIX, lLevaSX7, lLevaSXA, lLevaSXB,  )
		else

			// 2 =	Tabela (SX2)
			if lCheckBo2
				U_RUTIL012(2,, cPasta, aSX2, aSX3, aSX6, aSXB, lLevaSIX, lLevaSX7, lLevaSXA, lLevaSXB, lCheckBo2, lCheckBo3, lCheckBo4, lCheckBo5, lCheckBo6 )
			endIf

			// 3 =	Campos (SX3)
			if lCheckBo3
				U_RUTIL012(3,, cPasta, aSX2, aSX3, aSX6, aSXB, lLevaSIX, lLevaSX7, lLevaSXA, lLevaSXB, lCheckBo2, lCheckBo3, lCheckBo4, lCheckBo5, lCheckBo6 )
			endIf

			// 4 =	Indices (SIX)
			if lCheckBo4
				U_RUTIL012(4,, cPasta, aSX2, aSX3, aSX6, aSXB, lLevaSIX, lLevaSX7, lLevaSXA, lLevaSXB, lCheckBo2, lCheckBo3, lCheckBo4, lCheckBo5, lCheckBo6 )
			endIf

			// 5 =	Gatilhos (SX7)
			if lCheckBo5
				U_RUTIL012(5,, cPasta, aSX2, aSX3, aSX6, aSXB, lLevaSIX, lLevaSX7, lLevaSXA, lLevaSXB, lCheckBo2, lCheckBo3, lCheckBo4, lCheckBo5, lCheckBo6 )
			endIf

			// 6 =	Consulta Padrão (SXB)
			if lCheckBo6
				U_RUTIL012(6,, cPasta, aSX2, aSX3, aSX6, aSXB, lLevaSIX, lLevaSX7, lLevaSXA, lLevaSXB, lCheckBo2, lCheckBo3, lCheckBo4, lCheckBo5, lCheckBo6 )
			endIf

		endIf

	endIf

	RestArea( aArea )

Return()

/*/{Protheus.doc} fValAlias
Funcao para validacao do alias a ser utilizado
@type  Static Function
@author [tbc] g.sampaio 
@since 18/02/2019
@version 1.0
@param cTabAlias, characters, alias que sera visto se existe no dicionario de dados
@return lRet, logico, retorno logico da validacao
@example
(examples)
@see (links_or_references)
/*/
Static Function fValAlias( cTabAlias )

	Local aArea 		:= GetArea()
	Local aAreaSX2		:= SX2->( GetArea() )
	Local lRet			:= .T.

	Default cTabAlias	:= ""

// verifico se o alias esta preenchido
	if empty(alltrim(cTabAlias))
		MsgAlert("Alias não preenchido!")
		lRet := .F.
	endIf

// verifico se o alias tem 3 caracres
	if lRet .and. len(AllTrim(cTabAlias)) < 3
		MsgAlert("O Alias preenchido <"+cTabAlias+">, foi preenchido com menos de três caracteres!")
		lRet := .F.
	endIf

// verifico se o alias existe na SX2
	if lRet
		SX2->(DbSetOrder(1)) // X2_CHAVE
		if !SX2->(DbSeek( cTabAlias ))
			MsgAlert("O Alias preenchido <"+cTabAlias+"> não existe no dicionario!")
			lRet := .F.
		endIf
	endIf

	RestArea( aAreaSX2 )
	RestArea( aArea )

Return(lRet)

/*/{Protheus.doc} fMarcTodos
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fMarcTodos( lCompleta, lCheckBo2, lCheckBo3, lCheckBo4, lCheckBo5, lCheckBo6,;
		oCheckBo1, oCheckBo2, oCheckBo3, oCheckBo4, oCheckBo5, oCheckBo6 )

	Local aArea			:= GetArea()
	Local lRet			:= .T.

	Default lCompleta	:= .T.
	Default lCheckBo2	:= .T.
	Default lCheckBo3	:= .T.
	Default lCheckBo4	:= .T.
	Default lCheckBo5	:= .T.
	Default lCheckBo6	:= .T.

	// atualizo os valores a seguir
	lCheckBo2	:= lCompleta
	lCheckBo3	:= lCompleta
	lCheckBo4	:= lCompleta
	lCheckBo5	:= lCompleta
	lCheckBo6	:= lCompleta

	// atualizo os objetos
	oCheckBo1:Refresh()
	oCheckBo2:Refresh()
	oCheckBo3:Refresh()
	oCheckBo4:Refresh()
	oCheckBo5:Refresh()
	oCheckBo6:Refresh()

	RestArea( aArea )

Return(lRet)

/*/{Protheus.doc} fValMarc
	(long_descr
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fValMarc()

	Local lRet	:= .T.

Return(lRet)