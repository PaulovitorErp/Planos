#include "totvs.ch"
#include "Msole.ch"
#include "topconn.ch"

#define oleWdFormatPDF "17"

/*/{Protheus.doc} RUTILR02
Faz Impressao do modelo de relatorio selecionado
@author g.sampaio
@since 04/06/2019
@version P12
@param cLayout	, caractere, layout de impressao selecionado
@param cContrato, caractere, contrato selecionado para impressao
@param cTabela  , caractere, tabela de contratos de acordo com o modulo
@return nulo
/*/

User Function RUTILR02( cLayout, cCodigo, cTabela, nIndice )

	Local aArea			:= GetArea()
	Local aAreaUJJ		:= UJJ->( GetArea() )
	Local aAreaUJK		:= UJK->( GetArea() )
	Local aAreaUJL		:= UJL->( GetArea() )
	Local aAreaUJM		:= UJM->( GetArea() )
	Local aAreaSA1		:= SA1->( GetArea() )
	Local aIndicador	:= {}
	Local aAux			:= {}
	Local aImpressao	:= {}
	Local aCtDominio	:= {}
	Local cDirModel  	:= GetTempPath()
	Local cPathCli 		:= ""
	Local cNomeModel	:= ""
	Local cNomeArq  	:= ""
	Local cMascara		:= ""
	Local cConteudo		:= ""
	Local cItem 		:= ""
	Local cCtDominioAux	:= ""
	Local lContinua		:= .T.
	Local lPosicRelac	:= .T.
	Local nCont			:= 0
	Local nIndicador	:= 0
	Local nImp			:= 0
	Local lImpWord		:= SuperGetMv("MV_XIMPWRD", .F., .F.) 
	Local oWord 		:= Nil

	Default cLayout		:= ""
	Default cCodigo 	:= ""
	Default cTabela		:= ""

	DbSelectArea("UJJ")
	DbSelectArea("UJK")
	DbSelectArea("UJL")
	DbSelectArea("UJM")

	//Valido de onde esta sendo chamado a rotina
	If IsInCallStack("U_RFUNA002")
		aAreaUF2	:= UF2->( GetArea() )
	Else
		aAreaU00	:= U00->( GetArea() )
	Endif

	// posiciono na tabela de Dados Modelo
	UJJ->( DbSetOrder(1) )
	If UJJ->( MsSeek( xFilial("UJJ")+cLayout ) )

		// diretorio local do client
		cPathCli 	:= Lower( AllTrim( UJJ->UJJ_DIRLOC ) )
		cPathCli 	:= Iif( SubStr(cPathCli,Len(cPathCli)) == Iif(GetRemoteType() == 2,"/","\"), cPathCli, cPathCli + Iif(GetRemoteType() == 2,"/","\") )

		// nome do arquivo a ser gerado
		cNomeModel	:= ALLTRIM(UJJ->UJJ_MODELO)

		// nome que sera gerado o arquivo do termo
		cNomeArq 	:= ALLTRIM(UJJ->UJJ_NMTERM)

		//Cria o diretorio local se nao existir, para copiar o documento Word
		If !ExistDir(cPathCli)
			MakeDir(cPathCli)
		EndIf

		//Caso encontre arquivo ja gerado na estacao, com o mesmo nome apaga primeiramente antes de gerar a nova impressao
		If File( cDirModel + cNomeModel )

			if FErase( cDirModel + cNomeModel ) == 0
				//Prepara o arquivo
				if !CpyS2T("\dots\"+cNomeModel,cDirModel,.T.,.T.) 	// Copia do Server para o Remote

					lContinua := .F.
					MsgAlert("Não foi possív+el copiar arquivo, talvez o arquivo não esteja no diretorio 'dots', ou o nome do arquivo deve ser com letra minusculo e nao conter caracter especial")

				endif
			endif

		Else
			//Prepara o arquivo
			if !CpyS2T("\dots\"+cNomeModel,cDirModel,.T.,.T.) 	// Copia do Server para o Remote

				lContinua := .F.
				MsgAlert("Não foi possív+el copiar arquivo, talvez o arquivo não esteja no diretorio 'dots', ou o nome do arquivo deve ser com letra minusculo e nao conter caracter especial")

			endif
		Endif

		if lContinua

			cFileOpen := Alltrim(cDirModel)+Alltrim(cNomeModel) //caminho arquivo local

			OLE_CloseFile(oWord)
			OLE_CloseLink(oWord)

			// Criar o link do Protheus com o Word.
			oWord := OLE_CreateLink()

			// Cria um novo baseado no modelo.
			OLE_NewFile( oWord, cFileOpen )

			// Exibe ou oculta a janela da aplicacao Word no momento em que estiver descarregando os valores.
			OLE_SetProperty( oWord, oleWdVisible, .F. )

			// Exibe ou oculta a aplicacao Word.
			OLE_SetProperty( oWord, oleWdWindowState, '0' )

			//Imprime DocVariables da tabela UJK
			// posiciono na tabela Variaveis Word
			UJK->( DbSetOrder(1) )
			If UJK->( MsSeek( xFilial("UJK")+UJJ->UJJ_CODIGO ) )

				While UJK->( !EOF() );
						.AND. UJK->UJK_FILIAL+UJK->UJK_CODIGO == xFilial("UJK")+UJJ->UJJ_CODIGO

					lPosicRelac := .T.

					//Valido se foi criado relacionamento para o campo
					If !Empty(UJK->UJK_CODREL)

						//posiciono no relacionamento
						UJO->( DbSetOrder(2) )// pego o indice da tabela de relacionamentos
						If UJO->(MsSeek(xFilial("UJO")+UJJ->UJJ_ROTINA+UJK->UJK_CODREL))

							// valido o preenchimento dos campos da chave
							if ValidaRelacionamento(UJO->UJO_DOM, UJO->UJO_RELACI)

								//Ordeno pelo indice do relacionamento
								(UJO->UJO_CDOM)->(DbSetOrder(UJO->UJO_ORDEM))
								if UJO->UJO_TIPO == "1" // comum

									//posiciono no indice do relacionamento
									If !(UJO->UJO_CDOM)->(MsSeek((UJO->UJO_DOM)->&(AllTrim(UJO->UJO_RELACI))))
										lContinua := .F.
									Endif

								elseIf UJO->UJO_TIPO == "2" // multiseleção

									if Empty(cItem) .And. AllTrim(cCtDominioAux) <> AllTrim(UJO->UJO_CDOM)

										nPosCtDom := AScan(aCtDominio,{|x| x[1] == UJO->UJO_CDOM})

										if nPosCtDom == 0

											// abro tela para selecao do item a ser impresso
											cItem := MultiSelecao(UJO->UJO_DOM, UJO->UJO_CDOM, UJO->UJO_RELACI, UJO->UJO_CHAVE)

											AAdd(aCtDominio,{UJO->UJO_CDOM, cItem})

										else

											cItem := aCtDominio[nPosCtDom, 2]

										endIf

										cCtDominioAux := UJO->UJO_CDOM

									endIf

									//posiciono no indice do relacionamento
									If !(UJO->UJO_CDOM)->(MsSeek((UJO->UJO_DOM)->&(AllTrim(UJO->UJO_RELACI))+cItem))
										lContinua := .F.
									Endif

								endIf

								lPosicRelac := (UJO->UJO_CDOM)->(Found())

							else
								lPosicRelac := .F.

							endIf

						Endif

					Endif

					// limpo a variavel de conteudo
					cConteudo := ""

					if lPosicRelac

						if lContinua

							if !Empty(UJK->UJK_CAMPO)

								if (UJK->UJK_TABELA)->(FieldPos(UJK->UJK_CAMPO)) > 0

									// pego o conteudo do campo X3_PICTURE
									if AllTrim(UJK->UJK_CAMPO) == "A1_CGC"
										if SA1->A1_PESSOA == "J"
											cMascara := "@R 99.999.999/9999-99"
										else
											cMascara := "@R 999.999.999-99"
										endIf
									else
										cMascara := GetSx3Cache( UJK->UJK_CAMPO, "X3_PICTURE" )

										// tratamento especifico para nao cortar o registro
										if "@!S" $ AllTrim( cMascara ) .Or. "@S" $ AllTrim( cMascara )
											cMascara := "@!"
										endIf

									endIf

								else
									cMascara	:= ""
								endIf
							else
								cMascara	:= ""
							endIf

							// verifico se tem formula preenchida
							If !Empty( AllTrim(UJK->UJK_FORMUL) )

								cConteudo := ExecVar(AllTrim(UJK->UJK_FORMUL), AllTrim(UJK->UJK_TABELA), AllTrim(UJK->UJK_CAMPO))
							Else // caso seja campo do sistema

								if (UJK->UJK_TABELA)->(FieldPos(UJK->UJK_CAMPO)) > 0

									if GetSx3Cache( UJK->UJK_CAMPO, "X3_CONTEXT" ) <> "V" // valido se o campo e real
										cConteudo	:= (UJK->UJK_TABELA)->&((UJK->UJK_CAMPO))
									else
										cConteudo := ""
									endIf

								else
									cConteudo := ""
								endIf

							Endif

							// verifico se a mascara esta preenchida
							If !Empty(cMascara)
								cConteudo	:= AllTrim(Transform(cConteudo, cMascara)) // aplico a mascara
							endIf

							// faco a impressao no word
							OLE_SetDocumentVar(oWord, Alltrim(UJK->UJK_VAR), cConteudo)

						endIf

					else

						// faco a impressao no word
						OLE_SetDocumentVar(oWord, Alltrim(UJK->UJK_VAR), cConteudo)

					endIf

					lContinua := .T.

					UJK->(DbSkip())
				EndDo

				OLE_UpdateFields( oWord )

			EndIf

		endIf

		if lContinua

			//Imprime Itens se tiver
			// posiciono na tabela Indicadores
			UJL->( DbSetOrder(1) )

			If UJL->( MsSeek( xFilial("UJL")+UJJ->UJJ_CODIGO ) )

				//percorre indicadores cadastrados
				While UJL->(!EOF()) ;
						.AND. UJL->UJL_FILIAL+UJL->UJL_CODIGO == xFilial("UJL")+UJJ->UJJ_CODIGO

					//posiciono no relacionamento
					UJO->( DbSetOrder(2) )
					If UJO->(MsSeek(xFilial("UJO")+UJJ->UJJ_ROTINA+UJL->UJL_CODREL))

						//Ordeno pelo indice do relacionamento
						(UJO->UJO_CDOM)->(DbSetOrder(UJO->UJO_ORDEM))

						//Valido se tem filtro cadastrado
						If !Empty(UJL->UJL_FILTRO)
							(UJO->UJO_CDOM)->(dbSetFilter(&("{|| " + UJL->UJL_FILTRO + " }"), UJL->UJL_FILTRO))

						Endif

						//posiciono no indice do relacionamento
						If (UJO->UJO_CDOM)->(MsSeek((UJO->UJO_DOM)->&(AllTrim(UJO->UJO_RELACI))))

							// monto a chave do relacionamento
							cChaveRel	:= (UJO->UJO_CDOM)->&(UJO->UJO_CHAVE)

							While (UJO->UJO_CDOM)->(!EOF()) ;
									.AND. cChaveRel == (UJO->UJO_CDOM)->&(UJO->UJO_CHAVE)

								//Posiciona na amarração Indicadores X Variaveis
								//posiciono na tabela Variaveis X Indicadores
								UJM->(DbSetOrder(1))
								If UJM->( MsSeek( xFilial("UJM")+UJJ->UJJ_CODIGO+UJL->UJL_INDICA ) )

									nCont++

									//percorre amarração fazendo impressao das variaveis
									While UJM->(!EOF());
											.AND. UJM->UJM_FILIAL+UJM->UJM_CODIGO+UJM->UJM_INDICA == xFilial("UJM")+UJJ->UJJ_CODIGO+UJL->UJL_INDICA

										// verifico se tem formula preenchida
										If !Empty( UJM->UJM_FORMUL )

											cConteudo := ExecVar(AllTrim(UJM->UJM_FORMUL), AllTrim(UJO->UJO_CDOM), AllTrim(UJM->UJM_CAMPO))
										Else // caso seja campo do sistema

											// pego o conteudo do campo X3_PICTURE
											cMascara := GetSx3Cache( UJM->UJM_CAMPO, "X3_PICTURE" )

											// tratamento especifico para nao cortar o registro
											if "@!S" $ AllTrim( cMascara ) .Or. "@S" $ AllTrim( cMascara )
												cMascara := "@!"
											endIf

											cConteudo	:= (UJO->UJO_CDOM)->&(UJM->UJM_CAMPO)

											// verifico se a mascara esta preenchida
											if !Empty(cMascara)
												cConteudo	:= AllTrim(Transform(cConteudo, cMascara)) // aplico a mascara
											endIf

										Endif

										aAdd(aAux,{Alltrim(UJM->UJM_VAR)+AllTrim(Str(nCont)), cConteudo})

										UJM->(DbSkip())
									EndDo

								Endif

								(UJO->UJO_CDOM)->(DbSkip())
							EndDo

						Endif
					Endif

					// verifico se tenho indicador para executar
					if Len(aAux) > 0

						// preencho o array de indicadores
						aAdd(aIndicador, {UJL->UJL_INDICA, nCont, aAux})

						// zero as variaveis
						aAux	:= {}
						nCont 	:= 0
					endIf

					UJL->(DbSkip())
				EndDo
			Endif

			// verifico se existem indicadores para serem impreessos
			if lContinua .And. Len(aIndicador) > 0

				// percorro o array de indicadores
				for nIndicador := 1 to Len(aIndicador)

					// preencho o array impressao dos indicadores
					aImpressao := aIndicador[nIndicador,3]

					OLE_SetDocumentVar(oWord, "prt_numitens",AllTrim( Str( aIndicador[nIndicador,2] ) ) )

					// percorro o array de impressao
					for nImp := 1 to Len(aImpressao)

						OLE_SetDocumentVar(oWord, aImpressao[nImp, 1], aImpressao[nImp, 2])

					next nImp

					OLE_ExecuteMacro(oWord,Alltrim(aIndicador[nIndicador,1]))

				next nInd

			endIf

			OLE_UpdateFields( oWord )

			// 3-Salvar formato PDF
			if !empty(cCodigo)
				cFileSave := cNomeArq + "_" + Alltrim(cCodigo) + "_" + CriaTrab(, .F.)
			else
				cFileSave := cNomeArq + "_" + CriaTrab(, .F.)
			endIf

			// pergunto se gero o PDF
			if MsgYesNo("Deseja gerar o arquivo PDF?")

				OLE_SaveAsFile( oWord, cPathCli+cFileSave,'','',.F., 17 ) //gera pdf
				ShellExecute("open",cPathCli+cFileSave+".pdf","","",5) // 5=SW_SHOW

			elseif lImpWord

				OLE_SaveAsFile( oWord, cPathCli+cFileSave+".doc",'','',.F. ) //gera word
				ShellExecute("open",cPathCli+cFileSave+".doc","","",5) // 5=SW_SHOW

			endIf

			OLE_CloseFile( oWord )

			// Fechar o link com a aplicação.
			OLE_CloseLink( oWord, .T. )

			//Apaga Arquivo Modelo
			FErase( cDirModel+cNomeArq )

			MS_FLUSH()

		endIf

	Else // retorno mensagem ao usuario caso nao for possivel realizar a impressao

		MsgAlert("Não foi possível realizar a impressão, modelo de relatório inválido!")

	EndIf

	//Restauro alias
	If IsInCallStack("U_RFUNA002")

		RestArea( aAreaUF2 )
	Else

		RestArea( aAreaU00 )
	Endif

	RestArea( aAreaSA1 )
	RestArea( aAreaUJM )
	RestArea( aAreaUJL )
	RestArea( aAreaUJK )
	RestArea( aAreaUJJ )
	RestArea( aArea )

Return

/*/{Protheus.doc} DataExtenso
Retorna data por extenso
@author Leandro Rodrigues
@since 25/06/2019
@version P12
@param
@return nulo
/*/

User Function DataExtenso(dData)

	Local cDataExt:= ""

	cDataExt += cValToChar(Day(dData))
	cDataExt += " de "
	cDataExt += Capital(MesExtenso(dData))
	cDataExt += " de "
	cDataExt += cValToChar(Year(dData))

Return cDataExt

/*/{Protheus.doc} ExecVar
funcao para executar as formulas
@type function
@version 
@author g.sampaio
@since 01/12/2020
@param cTabelaTermo, character, param_description
@param cFormulaTermo, character, param_description
@return return_type, return_description
/*/
Static Function ExecVar( cFormulaTermo, cTabelaTermo, cCampoTermo)

	Local aX3Cbox		:= {}
	Local cRetorno 		:= ""
	Local cQuery		:= ""
	Local cCodTab		:= SuperGetMV("MV_XTABPAD",.F.,"001")
	Local cConteudo		:= ""
	Local cX3Cbox		:= ""
	Local cPrefContrato	:= SuperGetMv("MV_XPREFCT",.F.,"CTR")
	Local cTipoContrato	:= SuperGetMv("MV_XTIPOCT",.F.,"AT")
	Local nPosX3Cbox	:= ""
	Local nPrecoTab		:= 0

	Default cFormulaTermo 	:= ""
	Default cTabelaTermo	:= ""

	// pego o conteudo do campo
	if !Empty(cTabelaTermo) .And. !Empty(cCampoTermo) .And. GetSx3Cache( cCampoTermo, "X3_CONTEXT" ) <> "V"
		cConteudo	:= (cTabelaTermo)->(&(cCampoTermo))
	else
		cConteudo	:= ""
	endIf

	// verifico as variaveis do gerador de termo
	if cTabelaTermo == "UJV" .And. cFormulaTermo == "ENDFALECIDO" // tabela de apontamento de servico e endereco do falecido

		if UJV->(FieldPos("UJV_ENDFAL")) > 0 .And. UJV->(FieldPos("UJV_CMPFAL")) > 0 .And. UJV->(FieldPos("UJV_BAIFAL")) > 0

			// preenche o endereco
			cRetorno := AllTrim(UJV->UJV_ENDFAL)
			cRetorno += if(!Empty(UJV->UJV_ENDFAL),"," ,"")

			// preenche o complemento
			cRetorno += AllTrim(UJV->UJV_CMPFAL)
			cRetorno += if(!Empty(UJV->UJV_CMPFAL),"," ,"")

			// preenche o bairro
			cRetorno += AllTrim(UJV->UJV_BAIFAL)
			cRetorno += if(!Empty(UJV->UJV_BAIFAL),"," ,"")

			// preenche o municipio
			cRetorno += AllTrim(UJV->UJV_MUN)
			cRetorno += if(!Empty(UJV->UJV_MUN),"/","")

			// preenche o estado
			cRetorno += UJV->UJV_UF
		else
			cRetorno := AllTrim(UJV->UJV_MUN) + if(!Empty(UJV->UJV_MUN),"/","") + UJV->UJV_UF
		endIf

	elseif cTabelaTermo == "U02" .And. cFormulaTermo == "ENDAUTORIZADO" // imprime o endreco do autorizado

		// preenche o endereco
		cRetorno := AllTrim(U02->U02_END)
		cRetorno += if(!Empty(U02->U02_END),"," ,"")

		// preenche o complemento
		cRetorno += AllTrim(U02->U02_COMPLE)
		cRetorno += if(!Empty(U02->U02_COMPLE),"," ,"")

		// preenche o bairro
		cRetorno += AllTrim(U02->U02_BAIRRO)
		cRetorno += if(!Empty(U02->U02_BAIRRO),"," ,"")

		// preenche o municipio
		cRetorno += AllTrim(U02->U02_MUN)
		cRetorno += if(!Empty(U02->U02_MUN),"/","")

		// preenche o estado
		cRetorno += U02->U02_EST

	elseIf cFormulaTermo == "VALORTAB" // valor da tabela de preco

		// verifico se tem conteudo
		if !Empty(cConteudo)

			if Select("TRBTAB") > 0
				TRBTAB->(DbCloseArea())
			endif

			cQuery := " SELECT "
			cQuery += " DA1_PRCVEN PRECO, "
			cQuery += " DA1_DATVIG VIGENCIA "
			cQuery += " FROM  "
			cQuery += + RetSQLName("DA1")
			cQuery += " WHERE "
			cQuery += " D_E_L_E_T_ = ' '  "
			cQuery += " AND DA1_FILIAL = '"+xFilial("DA1")+"' "
			cQuery += " AND DA1_CODPRO = '"+cConteudo+"'
			cQuery += " AND DA1_CODTAB = '"+cCodTab+"'
			cQuery += " ORDER BY DA1_DATVIG DESC"

			cQuery := ChangeQuery(cQuery)

			TcQuery cQuery NEW Alias "TRBTAB"

			//verifico se o preco esta vigente
			if STOD(TRBTAB->VIGENCIA) <= dDataBase
				nPrecoTab := TRBTAB->PRECO

				if cTabelaTermo == "UJX"
					cRetorno 	:= AllTrim(Transform(nPrecoTab * UJX->UJX_QTDE, GetSx3Cache( "UJX_VALOR", "X3_PICTURE" )))
				else
					cRetorno	:= AllTrim(Transform(nPrecoTab, "@E 999,999.99 "))
				endIf

			else
				cRetorno	:= "0,00"
			endIf

			if Select("TRBTAB") > 0
				TRBTAB->(DbCloseArea())
			endif

		else
			cRetorno	:= "0,00"
		endIf

	elseIf cFormulaTermo == "DATAEXTENSOAB" // data do dia em extensoa breviada Ex.: 01 de Dezembro de 2020
		cRetorno += cValToChar(Day(dDatabase))
		cRetorno += " de "
		cRetorno += MesExtenso(dDatabase)
		cRetorno += " de "
		cRetorno += cValToChar(Year(dDatabase))

	elseIf cFormulaTermo == "DATAEXTENSO" // data do dia em extenso Ex.: Pirmeiro de Dezembro de Dois Mil e Vinte
		cRetorno += Capital(Extenso(Day(dDatabase), .T.))
		cRetorno += " de "
		cRetorno += MesExtenso(dDatabase)
		cRetorno += " de "
		cRetorno += Capital(Extenso(Year(dDatabase), .T.))

	elseIf cFormulaTermo == "NUMNOTAFISCAL"

		if !empty(cConteudo)

			if Select("TRBNF") > 0
				TRBNF->(DbCloseArea())
			endif

			cQuery := " SELECT SF2.F2_NFELETR NUMNOTA FROM "+ RetSQLName("SF2") +" SF2"
			cQuery += " INNER JOIN "+ RetSQLName("SD2") +" SD2 ON SD2.D_E_L_E_T_ = ' '"
			cQuery += " AND SD2.D2_DOC = SF2.F2_DOC"
			cQuery += " AND SD2.D2_SERIE = SF2.F2_SERIE"
			cQuery += " AND SD2.D2_PEDIDO = '" + cConteudo + "'"
			cQuery += " WHERE SF2.D_E_L_E_T_ = ' ' "
			cQuery += " GROUP BY SF2.F2_NFELETR "

			TcQuery cQuery New Alias "TRBNF"

			if TRBNF->(!eof())
				cRetorno := TRBNF->NUMNOTA
			else
				cRetorno := "-"
			endIf

			if Select("TRBNF") > 0
				TRBNF->(DbCloseArea())
			endif
		else
			cRetorno := "-"
		endIf

	elseIf cFormulaTermo == "X3CBOX"

		if !Empty(cConteudo)
			// pego o conteudo do campo X3_CBOX do campo UF4_TIPO
			cX3Cbox := GetSx3Cache(cCampoTermo,"X3_CBOX")

			// alimento o array de dados
			aX3Cbox	:= StrToKarr( cX3Cbox, ";" )

			// pego os dados a posicao do tipo de servico para buscar a descricao conforme na X3_CBOX
			nPosX3Cbox 	:= aScan( aX3Cbox, { |x| SubStr( x, 1, len(Alltrim(cConteudo)) ) == AllTrim(cConteudo) } )

			// verifico se encontrei o tipo de servico
			If nPosX3Cbox > 0

				// procuro a posicao do sinal de igual(=)
				nAT := AT("=",aX3Cbox[nPosX3Cbox])

				// verifico se encontrou
				if nAT > 0
					cRetorno := SubStr( aX3Cbox[nPosX3Cbox], nAT+1 )
				else
					cRetorno := aX3Cbox[nPosX3Cbox]
				endIf

			EndIf
		else	
			cRetorno := ""
		endif

	elseIf cFormulaTermo == "DADOSJAZIGO"

		if Select("DADOSJAZIGO") > 0
			DADOSJAZIGO->(DbCloseArea())
		endIf

		cQuery := " SELECT U04."+cCampoTermo+" CAMPO"
		cQuery += " FROM "+ RetSQLName("U04") +" U04 "
		cQuery += " WHERE U04.D_E_L_E_T_ = ' '"
		cQuery += " AND U04.U04_FILIAL = '" + xFilial("U04") + "'"
		cQuery += " AND U04.U04_CODIGO = '" + U00->U00_CODIGO + "'"
		cQuery += " AND U04.U04_TIPO = 'J'"

		TcQuery cQuery New Alias "DADOSJAZIGO"

		if DADOSJAZIGO->(!Eof())
			cRetorno := DADOSJAZIGO->CAMPO
		endIf

		if Select("DADOSJAZIGO") > 0
			DADOSJAZIGO->(DbCloseArea())
		endIf

	elseif cFormulaTermo == "MESANOCARDIA"

		dDataCarencia := DaySum(U00->U00_DTATIV, U00->U00_CARDIA)

		cRetorno := MesExtenso(Month(dDataCarencia)) + " DE " + StrZero(Day(dDataCarencia),2)

	elseIf cFormulaTermo == "VALORTERRENO"

		if Select("TRBTER") > 0
			TRBTER->(DbCloseArea())
		endIf

		cQuery := " SELECT SUM(U01.U01_VLRTOT) VALOR FROM " + RetSQLName("U01") + " U01 "
		cQuery := " INNER JOIN " + RetSQLName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = ' ' "
		cQuery := " AND SB1.B1_COD = U01.U01_PRODUT "
		cQuery := " AND SB1.B1_XTPCEM = '4'"
		cQuery := " WHERE U01.D_E_L_E_T_ = ' ' "
		cQuery := " AND U01.U01_FILIAL = '" + xFilial("U01") + "' "
		cQuery := " AND U01.U01_CODIGO = '"+ U00->U00_CODIGO +"' "

		TcQuery cQuery New Alias "TRBTER"

		if TRBTER->(!Eof())
			cRetorno := AllTrim(Transform(TRBTER->VALOR, "@ 999,999,999.99"))
		endIf

		if Select("TRBTER") > 0
			TRBTER->(DbCloseArea())
		endIf

	elseIf cFormulaTermo == "VALORCONSTRUCAO"

		if Select("TRBCON") > 0
			TRBCON->(DbCloseArea())
		endIf

		cQuery := " SELECT SUM(U01.U01_VLRTOT) VALOR FROM " + RetSQLName("U01") + " U01 "
		cQuery := " INNER JOIN " + RetSQLName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = ' ' "
		cQuery := " AND SB1.B1_COD = U01.U01_PRODUT "
		cQuery := " AND SB1.B1_XTPCEM = '3'"
		cQuery := " WHERE U01.D_E_L_E_T_ = ' ' "
		cQuery := " AND U01.U01_FILIAL = '" + xFilial("U01") + "' "
		cQuery := " AND U01.U01_CODIGO = '"+ U00->U00_CODIGO +"' "

		TcQuery cQuery New Alias "TRBCON"

		if TRBCON->(!Eof())
			cRetorno := AllTrim(Transform(TRBCON->VALOR, "@ 999,999,999.99"))
		endIf

		if Select("TRBCON") > 0
			TRBCON->(DbCloseArea())
		endIf

	elseIf cFormulaTermo == "VALORPARCELA"

		oVirtusFin := VirtusFin():New()

		oVirtusFin:CRContratoCemiterio(U00->(Recno()), .F.)

		cRetorno := AllTrim(Transform(oVirtusFin:nValFinancParcela, "@E 999,999,999.99"))

	elseIf "ULTIMAPARCELA" $ AllTrim(cFormulaTermo)

		if Select("TRBSE1") > 0
			TRBSE1->(DbCloseArea())
		endIf

		cQuery := " SELECT MAX(SE1.E1_VENCTO) ULTIMAPAR "
		cQuery += " FROM " + RetSQLName("SE1") + " SE1 "
		cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' "
		cQuery += " AND SE1.E1_FILIAL 	= '" + xFilial("SE1") + "' "
		cQuery += " AND SE1.E1_PREFIXO	= '" + cPrefContrato + "' "
		cQuery += " AND SE1.E1_TIPO 	= '" + cTipoContrato + "' "
		cQuery += " AND SE1.E1_XCONTRA 	= '" + U00->U00_CODIGO + "' "

		TcQuery cQuery New Alias "TRBSE1"

		if TRBSE1->(!Eof())
			if "MES_ANOEX" $ AllTrim(cFormulaTermo)
				cRetorno := MesExtenso(Stod(TRBSE1->ULTIMAPAR)) + "/" + cValToChar(Year(Stod(TRBSE1->ULTIMAPAR)))
			else
				cRetorno := Dtoc(Stod(TRBSE1->ULTIMAPAR))
			endIf
		endIf

		if Select("TRBSE1") > 0
			TRBSE1->(DbCloseArea())
		endIf

	elseIf "PRIMEIRAPARCELA" $ AllTrim(cFormulaTermo)

		if Select("TRBSE1") > 0
			TRBSE1->(DbCloseArea())
		endIf

		cQuery := " SELECT MIN(SE1.E1_VENCTO) PRIMEIRAPAR "
		cQuery += " FROM " + RetSQLName("SE1") + " SE1 "
		cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' "
		cQuery += " AND SE1.E1_FILIAL 	= '" + xFilial("SE1") + "' "
		cQuery += " AND SE1.E1_PREFIXO	= '" + cPrefContrato + "' "
		cQuery += " AND SE1.E1_TIPO 	= '" + cTipoContrato + "' "
		cQuery += " AND SE1.E1_XCONTRA 	= '" + U00->U00_CODIGO + "' "

		TcQuery cQuery New Alias "TRBSE1"

		if TRBSE1->(!Eof())
			if "MES_ANOEX" $ AllTrim(cFormulaTermo)
				cRetorno := MesExtenso(Stod(TRBSE1->PRIMEIRAPAR)) + "/" + cValToChar(Year(Stod(TRBSE1->PRIMEIRAPAR)))
			else
				cRetorno := Dtoc(Stod(TRBSE1->PRIMEIRAPAR))
			endIf
		endIf

		if Select("TRBSE1") > 0
			TRBSE1->(DbCloseArea())
		endIf

	elseIf cFormulaTermo == "NACIONALIDADE_SA1"

		if SA1->A1_PAIS == "105" // brasil
			if SA1->A1_XSEXO == "M" // masculino
				cRetorno := "Brasileiro"
			else// feminino
				cRetorno := "Brasileira"
			endIf
		else
			cRetorno := ""
		endIf

	elseIf cFormulaTermo == "ESTCIVIL_SA1"

		if !Empty(cConteudo)

			// pego o conteudo do campo X3_CBOX do campo UF4_TIPO
			cX3Cbox := GetSx3Cache(cCampoTermo,"X3_CBOX")

			// alimento o array de dados
			aX3Cbox	:= StrToKarr( cX3Cbox, ";" )

			// pego os dados a posicao do tipo de servico para buscar a descricao conforme na X3_CBOX
			nPosX3Cbox 	:= aScan( aX3Cbox, { |x| SubStr( x, 1, len(Alltrim(cConteudo)) ) == AllTrim(cConteudo) } )

			// verifico se encontrei o tipo de servico
			If nPosX3Cbox > 0

				// procuro a posicao do sinal de igual(=)
				nAT := AT("=",aX3Cbox[nPosX3Cbox])

				// verifico se encontrou
				if nAT > 0
					cRetorno := SubStr( aX3Cbox[nPosX3Cbox], nAT+1 )
				else
					cRetorno := aX3Cbox[nPosX3Cbox]
				endIf

			EndIf

			if SA1->A1_XSEXO == "M" // masculino
				cRetorno := SubStr(cRetorno, 1, Len(AllTrim(cRetorno))-1) + "o"
			else// feminino
				cRetorno := SubStr(cRetorno, 1, Len(AllTrim(cRetorno))-1) + "a"
			endIf
		else
			cRetorno := ""
		endif

		// verifico as variaveis do gerador de termo
	elseif cTabelaTermo == "SA1" .And. cFormulaTermo == "FONESCLIENTE" // tabela de apontamento de servico e endereco do falecido

		cRetorno := if(!Empty(SA1->A1_DDD),SA1->A1_DDD,"")
		cRetorno += SA1->A1_TEL

		cRetorno += if(!Empty(SA1->A1_XDDDCEL), " | " + SA1->A1_XDDDCEL,"")
		cRetorno += SA1->A1_XCEL

		cRetorno += if(!Empty(SA1->A1_XDDDCEL), " | " + SA1->A1_XDDDCEL,"")
		cRetorno += SA1->A1_XCEL2

		// verifico as variaveis do gerador de termo
	elseif cTabelaTermo == "SA1" .And. cFormulaTermo == "ENDCLIENTE" // tabela de apontamento de servico e endereco do falecido

		// preenche o endereco
		cRetorno := AllTrim(SA1->A1_END)
		cRetorno += if(!Empty(SA1->A1_END),"," ,"")

		// preenche o complemento
		cRetorno += AllTrim(SA1->A1_COMPLEM)
		cRetorno += if(!Empty(SA1->A1_COMPLEM),"," ,"")

		// preenche o bairro
		cRetorno += AllTrim(SA1->A1_BAIRRO)
		cRetorno += if(!Empty(SA1->A1_BAIRRO),"," ,"")

		// preenche o municipio
		cRetorno += AllTrim(SA1->A1_MUN)
		cRetorno += if(!Empty(SA1->A1_MUN),"/","")

		// preenche o estado
		cRetorno += SA1->A1_EST

	elseIf cTabelaTermo == "SA1" .And. cFormulaTermo == "CLIAUTORIZADO"

		SA1->(DbSetOrder(1))
		if SA1->(MsSeek(xfilial("SA1")+U02->U02_CODCLI+U02->U02_LOJCLI))
			if cCampoTermo == "A1_XDESMUN"
				cRetorno 	:= POSICIONE("CC2",1,XFILIAL("CC2")+SA1->A1_XESTNAS+SA1->A1_XMUNNAT,"CC2_MUN")
			elseif !Empty(cCampoTermo)
				cRetorno	:= (cTabelaTermo)->(&(cCampoTermo))

				if !Empty(GetSx3Cache(cCampoTermo,"X3_CBOX"))

					cX3Cbox := GetSx3Cache(cCampoTermo,"X3_CBOX")

					// alimento o array de dados
					aX3Cbox	:= StrToKarr( cX3Cbox, ";" )

					// pego os dados a posicao do tipo de servico para buscar a descricao conforme na X3_CBOX
					nPosX3Cbox 	:= aScan( aX3Cbox, { |x| SubStr( x, 1, len(Alltrim(cConteudo)) ) == AllTrim(cConteudo) } )

					// verifico se encontrei o tipo de servico
					If nPosX3Cbox > 0

						// procuro a posicao do sinal de igual(=)
						nAT := AT("=",aX3Cbox[nPosX3Cbox])

						// verifico se encontrou
						if nAT > 0
							cRetorno := SubStr( aX3Cbox[nPosX3Cbox], nAT+1 )
						else
							cRetorno := aX3Cbox[nPosX3Cbox]
						endIf

					EndIf

				endIf

			endIf
		endIf

	elseIf cFormulaTermo == "VALORAPT"

		// verifico se o campo de preco de servico existe
		If UJV->(FieldPos("UJV_XPRCSV")) > 0 
			nValorApont := UJV->UJV_XPRCSV
		else
			nValorApont	:= U_RetPrecoVenda(UJV->UJV_TABPRC, UJV->UJV_SERVIC)
		EndIf

		If Select("TRBVLR") > 0
			TRBVLR->(DbCloseArea())
		Endif

		// consulta o valor dos servicos adicionais
		cQuery := " SELECT SUM(SERVADD.UJX_VALOR) TOTSERV 					"
		cQuery += " FROM " + RetSQLName("UJX") + " SERVADD					"
		cQuery += " WHERE SERVADD.D_E_L_E_T_ = '' 							"
		cQuery += " AND SERVADD.UJX_FILIAL = '" + xFilial("UJX") + "'		"
		cQuery += " AND SERVADD.UJX_CODIGO = '" + UJV->UJV_CODIGO +  "' 	"

		MPSysOpenQuery( cQuery, 'TRBVLR' )

		If TRBVLR->(!Eof())
			nValorApont += TRBVLR->TOTSERV
		EndIf

		if nValorApont > 0 
			cRetorno := AllTrim(Transform(nValorApont, "@E 999,999,999.99"))
		EndIf

		If Select("TRBVLR") > 0
			TRBVLR->(DbCloseArea())
		Endif
	
	elseif cFormulaTermo == "QTDGAVETA"
		
		cQuery := " SELECT "
		cQuery += " 	U10.U10_CODIGO, "
		cQuery += " 	U10.U10_DESC, "
		cQuery += "   U10.U10_QTDGAV, "
		cQuery += "   U09.U09_QTDGAV, "
		cQuery += "   U08.U08_QTDGAV "
		cQuery += " FROM " + RetSQLName("U10") + " U10 "
		cQuery += " INNER JOIN " + RetSQLName("U09") + " U09 ON U09.D_E_L_E_T_ = ' ' "
		cQuery += " 	AND U09.U09_QUADRA = U10.U10_QUADRA "
		cQuery += " 	AND U09.U09_CODIGO = U10.U10_MODULO "
		cQuery += " INNER JOIN " + RetSQLName("U08") + " U08 ON U08.D_E_L_E_T_ = ' ' "
		cQuery += " 	AND U08.U08_CODIGO = U10.U10_QUADRA "
		cQuery += " WHERE U10.D_E_L_E_T_ = ' '"
		cQuery += " 	AND U10.U10_FILIAL = '"+ xFilial("U10") + "'"
		cQuery += " 	AND U10.U10_STATUS = 'S'"
		cQuery += " 	AND U10.U10_QUADRA = '" +  U04->U04_QUADRA + "'"
		cQuery += " 	AND U10.U10_MODULO = '" +  U04->U04_MODULO + "'"
		cQuery += " 	AND U10.U10_CODIGO = '" +  U04->U04_JAZIGO + "'"

		MPSysOpenQuery( cQuery, 'TRBGAV' )

		If TRBGAV->(!Eof())
			If TRBGAV->U10_QTDGAV > 0
			
				cRetorno	:= TRBGAV->U10_QTDGAV
			
			ElseIf TRBGAV->U09_QTDGAV > 0
			
				cRetorno	:= TRBGAV->U09_QTDGAV
			
			ElseIf TRBGAV->U08_QTDGAV > 0
			
				cRetorno	:= TRBGAV->U08_QTDGAV
			
			Else
			
				cRetorno	:= SuperGetMv("MV_XQTDGVJ",.F.,3)
			
			EndIf
		else	
			cRetorno := SuperGetMv("MV_XQTDGVJ",.F.,3)
		endif
		
		If Select("TRBGAV") > 0
			TRBGAV->(DbCloseArea())
		Endif
		
	else// executa qualquer forma
		cRetorno := &(cFormulaTermo)
	endIf

Return(cRetorno)

/*/{Protheus.doc} ValidaRelacionamento
valido se os campos tem preenchimento 
@type function
@version 1.0
@author g.sampaio
@since 14/12/2020
@param cTabRelacionamento, character, param_description
@param cRelacionamento, character, param_description
@return return_type, return_description
/*/
Static Function ValidaRelacionamento(cTabRelacionamento, cRelacionamento)

	Local aArea 			:= GetArea()
	Local aRelacionamento	:= {}
	Local lRetorno			:= .T.
	Local nI				:= 0

	Default cTabRelacionamento	:= ""
	Default cRelacionamento		:= ""

	// verifico se tem relacionamento preenchido
	if !Empty(cRelacionamento)

		// monto quebro os campos do relacionamento
		aRelacionamento := StrToKarr(AllTrim(cRelacionamento), "+")

		// verifico se montou a chave
		if Len(aRelacionamento) > 0

			// percorro o array de relacionamento
			for nI := 1 to Len(aRelacionamento)

				// verifico se utilizo o xfilial
				if !("xFilial" $ aRelacionamento[nI])

					// verifico se o campo tem conteudo
					if lRetorno .And. Empty((cTabRelacionamento)->&(aRelacionamento[nI]))
						lRetorno := .F.
					endIf

				endIf

			next nI

		endIf

	endIf

	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} MultiSelecao
Tela para relacionamento multi selecao
@type function
@version 1.0
@author g.sampaio
@since 03/06/2021
@param cDominio, character, Tabela do Termo
@param cChaveDominio, character, Chave da tabela do termo
@param cContraDominio, character, Tabela do relacionamento do termo
@param cChaveContraDominio, character, Chave do relacionamento do termo
@return character, retorna o item selecionado
/*/
Static Function MultiSelecao(cDominio, cContraDominio, cChaveDominio, cChaveContraDominio)

	Local aBrwMulti				:= {}
	Local cRetorno				:= ""
	Local cDescTabela			:= ""
	Local oButton1				:= Nil
	Local oButton2				:= Nil
	Local oGroup1				:= Nil
	Local oDlgMulti				:= Nil
	Local oBrwMulti				:= Nil

	Private cRetorno			:= ""

	Default cDominio			:= ""
	Default cChaveDominio		:= ""
	Default cContraDominio		:= ""
	Default cChaveContraDominio	:= ""

	if !Empty(cContraDominio)
		cDescTabela := FwSX2Util():GetX2Name( cContraDominio )
	endIf

	aBrwMulti := RetDados(cDominio, cContraDominio, cChaveDominio, cChaveContraDominio)

	if Len(aBrwMulti) > 1

		DEFINE MSDIALOG oDlgMulti TITLE "Multiseleção - " + Capital(cDescTabela) FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL
		FwBrwMulti(cDominio, cContraDominio, cChaveDominio, cChaveContraDominio, @oDlgMulti, @oBrwMulti, @aBrwMulti)
		@ 002, 004 GROUP oGroup1 TO 193, 296 PROMPT "Seleção de " + Capital(cDescTabela) OF oDlgMulti COLOR 0, 16777215 PIXEL
		@ 173, 250 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF oDlgMulti PIXEL ACTION(cRetorno := aBrwMulti[oBrwMulti:nAt,1], oDlgMulti:End())
		@ 173, 209 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlgMulti PIXEL ACTION(cRetorno := "", oDlgMulti:End())

		ACTIVATE MSDIALOG oDlgMulti CENTERED

	elseIf Len(aBrwMulti) == 1
		if !Empty(aBrwMulti[1,1])
			cRetorno := aBrwMulti[1,1]
		endIf
	endif

Return(cRetorno)

/*/{Protheus.doc} FwBrwMulti
monto o browse de selecao do autorizado
@type function
@version 1.0
@author g.sampaio
@since 13/06/2021
@param cDominio, character, alias principal do termo
@param cContraDominio, character, alias auxiliar para a geracao do termo
@param cChaveDominio, character, chave do alias principal do termo
@param cChaveContraDominio, character, chave do alias auxiliar
@param oDlgMulti, object, objeto da tabela de selecao
@param oBrwMulti, object, objeto do browse de multiselecao
@param aBrwMulti, array, array de dados para multiselecao
/*/
Static Function FwBrwMulti(cDominio, cContraDominio, cChaveDominio, cChaveContraDominio, oDlgMulti, oBrwMulti, aBrwMulti)

	Local cQuery 				:= ""
	Local nUltPos				:= 0
	Local nI					:= 0

	Default cDominio			:= ""
	Default cContraDominio		:= ""
	Default cChaveDominio		:= ""
	Default cChaveDominio		:= ""
	Default cChaveContraDominio	:= ""
	Default oDlgMulti			:= Nil
	Default oBrwMulti			:= Nil
	Default aBrwMulti			:= {}

	// comparo se a chave do contra dominio e maior que a chave do dominio
	@ 012, 010 LISTBOX oBrwMulti Fields HEADER "Item","Descricao" SIZE 279, 156 OF oDlgMulti PIXEL ColSizes 50,50
	oBrwMulti:SetArray(aBrwMulti)
	oBrwMulti:bLine := {|| {;
		aBrwMulti[oBrwMulti:nAt,1],;
		aBrwMulti[oBrwMulti:nAt,2];
		}}

	// DoubleClick event
	oBrwMulti:bLDblClick := {|| cRetorno := aBrwMulti[oBrwMulti:nAt,1], oDlgMulti:End(),;
		oBrwMulti:DrawSelect()}

Return(Nil)

/*/{Protheus.doc} RetDados
retorna os dados para dados
@type function
@version 1.0 
@author g.sampaio
@since 24/07/2021
@param cDominio, character, param_description
@param cContraDominio, character, param_description
@param cChaveDominio, character, param_description
@param cChaveContraDominio, character, param_description
@return variant, return_description
/*/
Static Function RetDados(cDominio, cContraDominio, cChaveDominio, cChaveContraDominio)

	Local aRetorno				:= {}
	Local aChaveDominio			:= {}
	Local aChaveContraDominio	:= {}
	Local cQuery				:= ""
	Local nI 					:= 0

	Default cDominio			:= ""
	Default cContraDominio		:= ""
	Default cChaveDominio		:= ""
	Default cChaveContraDominio	:= ""

	// monto um array com a chave do dominio
	aChaveDominio	:= StrToKarr(cChaveDominio, "+")

	// monto a chave do contra dominio
	aChaveContraDominio	:= StrToKarr(cChaveContraDominio, "+")

	//=========================================================
	// A ideia e retornar o ultimo campo do indice para retornar
	// na multiselecao para o retorno
	//=========================================================

	nUltPos := Len(aChaveContraDominio)

	if SelecT("TRBMULTI") > 0
		TRBMULTI->(DbCloseArea())
	EndIf

	cQuery := " SELECT "
	cQuery += " " + AllTrim(aChaveContraDominio[nUltPos]) + " MULTITEM, "

	if cContraDominio == "U02"
		cQuery += " U02_NOME NOME"
	ElseIf cContraDominio == "U04"
		cQuery += " 'QD ' +U04.U04_QUADRA + '|| MD ' + U04.U04_MODULO + '|| JAZ ' +  U04.U04_JAZIGO + '-' + U04.U04_QUEMUT NOME"
	else
		cQuery += " " + cContraDominio + "_DESCRI NOME"
	endif

	cQuery += " FROM " + RetSQLName(cContraDominio) + " " + cContraDominio
	cQuery += " WHERE " + cContraDominio + ".D_E_L_E_T_ = ' ' "

	For nI := 1 To Len(aChaveDominio)
		cQuery += " AND " + cContraDominio + "." + aChaveContraDominio[nI] + " = '" + iif(nI==1, xFilial(cDominio), &(cDominio+"->"+aChaveDominio[nI]) ) + "' "
	Next nI

	if cContraDominio == "U02"
		cQuery += " AND U02_STATUS <> '2' "
	endIf

	MPSysOpenQuery( cQuery, "TRBMULTI" )

	if TRBMULTI->(!Eof())
		while TRBMULTI->(!Eof())

			Aadd(aRetorno,{TRBMULTI->MULTITEM, TRBMULTI->NOME})

			TRBMULTI->(DbSkip())
		endDo
	else
		Aadd(aRetorno,{"",""})
	endIf

	if SelecT("TRBMULTI") > 0
		TRBMULTI->(DbCloseArea())
	EndIf

	if Len(aRetorno) == 0
		Aadd(aRetorno,{"",""})
	endIf

Return(aRetorno)



IF(ALLTRIM(M->UJV_SERVIC)=="01030002","000005","")



flwdget

IF(FLWDGET("UJV_SERVIC")=="01030002",.F.,.T.)
