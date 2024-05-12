#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} RCPGE014
Realiza alteração dados óbito
@author TOTVS
@since 21/04/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RCPGE014( cContrato, cApontamento )
/***********************/

	Local aArea				:= GetArea()
	Local aCampos			:= {}
	Local aTitulos			:= {}
	Local aDados			:= {}
	Local cQuery 			:= ""
	Local cMarca	 		:= "mk"
	Local cAlias			:= ""
	Local lRet				:= .T.
	Local lImpFechar		:= .F.
	Local nI				:= 0
	Local oBut1				:= Nil
	Local oBut2				:= Nil
	Local oSay1				:= Nil
	Local oTable 			:= Nil
	Local oMark     		:= Nil
	Local oDlgTer			:= Nil

	Default cContrato		:= ""
	Default cApontamento	:= ""

	// alimento as colunas da tabela temporaria
	aAdd( aCampos, {"OK"		,"C", 002						, 0} )
	aAdd( aCampos, {"ITEMSERV"	,"C", 3							, 0} )
	aAdd( aCampos, {"APONTA"	,"C", TamSX3("UJV_CODIGO")[1]	, 0} )
	aAdd( aCampos, {"SERVICO"	,"C", TamSX3("B1_COD")[1]	, 0} )
	aAdd( aCampos, {"DESCSERV"	,"C", TamSX3("B1_DESC")[1]		, 0} )
	aAdd( aCampos, {"DATASERV"	,"D", 8							, 0} )
	aAdd( aCampos, {"NOMEFALE"	,"C", TamSX3("UJV_NOME")[1]		, 0} )

	// alimento o array de titulos
	aAdd( aTitulos, {"OK"		,""	,""				,""} )
	aAdd( aTitulos, {"ITEMSERV"	,""	,"Item"			,""} )
	aAdd( aTitulos, {"APONTA"	,""	,"Apontamento"	,""} )
	aAdd( aTitulos, {"SERVICO"	,""	,"Cod.Serviço"	,""} )
	aAdd( aTitulos, {"DESCSERV"	,""	,"Desc.Serviço"	,""} )
	aAdd( aTitulos, {"DATASERV"	,""	,"Data"			,""} )
	aAdd( aTitulos, {"NOMEFALE"	,""	,"Nome obito"	,""} )

	// crio o objeto da tabela temporaria
	oTable := FWTemporaryTable():New("TRBSRV")

	//Inserindo campos no alias temporario
	oTable:SetFields(aCampos)

	//---------------------
	//Criação dos índices
	//---------------------
	oTable:AddIndex("01", {"ITEMSERV"} )

	//---------------------------------------------------------------
	//tabela criado no espaço temporário do DB
	//---------------------------------------------------------------
	oTable:Create()

	//------------------------------------
	//Pego o alias da tabela temporária
	//------------------------------------
	cAlias := oTable:GetAlias()

	If Select("QRYUJV") > 0
		QRYUJV->(DbCloseArea())
	Endif

	cQuery := " SELECT 'SERVNOR' DESCRI,
	cQuery += " UJV_CODIGO APONTA,"
	cQuery += " SB1.B1_COD SERVICO,"
	cQuery += " SB1.B1_DESC DESCSERV, "
	cQuery += " UJV.UJV_DTSEPU DATASERV, "
	cQuery += " UJV.UJV_NOME NOMEFALE "
	cQuery += " FROM " + RetSqlName("UJV") + " UJV "
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SB1.B1_COD = UJV.UJV_SERVIC "
	cQuery += " WHERE UJV.D_E_L_E_T_ = ' ' "
	cQuery += " AND UJV.UJV_STENDE  = 'E' "

	// verifico se tenho contrato preenchido
	If !Empty( AllTrim( cContrato ) )
		cQuery += " AND UJV.UJV_CONTRA	= '" + cContrato + "' "
	Endif

	// verifico se tenho apontamento preenchido
	If !Empty( AllTrim( cApontamento ) )
		cQuery += " AND UJV.UJV_CODIGO	= '" + cApontamento + "' "
	Endif

	cQuery += " UNION ALL "
	cQuery += " SELECT 'SERVADC' DESCRI, "
	cQuery += " UJV.UJV_CODIGO APONTA,"
	cQuery += " SB1.B1_COD SERVICO,"
	cQuery += " SB1.B1_DESC DESCSERV, "
	cQuery += " UJV.UJV_DTSEPU DATASERV, "
	cQuery += " UJV.UJV_NOME NOMEFALE "
	cQuery += " FROM " + RetSqlName("UJV") + " UJV "
	cQuery += " INNER JOIN " + RetSqlName("UJX") + " UJX ON UJX.D_E_L_E_T_ = ' ' "
	cQuery += " AND UJX.UJX_CODIGO = UJV.UJV_CODIGO "
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SB1.B1_COD = UJX.UJX_SERVIC "
	cQuery += " WHERE UJV.D_E_L_E_T_ = ' ' "
	cQuery += " AND UJV.UJV_STENDE = 'E' "

	// verifico se tenho contrato preenchido
	If !Empty( AllTrim( cContrato ) )
		cQuery += " AND UJV.UJV_CONTRA	= '" + cContrato + "' "
	Endif

	// verifico se tenho apontamento preenchido
	If !Empty( AllTrim( cApontamento ) )
		cQuery += " AND UJV.UJV_CODIGO	= '" + cApontamento + "' "
	Endif

	cQuery += " ORDER BY 1"

	// compatibilziacao da query
	cQuery := ChangeQuery(cQuery)

	// executo a query e crio o alias temporario
	TcQuery cQuery NEW Alias "QRYUJV"

	// percorro os dados do alias temporario
	While QRYUJV->(!EOF())

		// adlimento o array de dados
		AAdd(aDados,{ QRYUJV->APONTA, QRYUJV->SERVICO,  QRYUJV->DESCSERV, QRYUJV->DATASERV, QRYUJV->NOMEFALE})

		QRYUJV->(DbSkip())
	EndDo

	If Select("QRYUJV") > 0
		QRYUJV->(DbCloseArea())
	Endif

	// verifico se o array de dados esta preenchido
	If Len(aDados) > 0

		// preencheo o alias temporario do browse
		For nI := 1 to Len(aDados)

			(cAlias)->(DBAppend())
			(cAlias)->OK 			:= "  "
			(cAlias)->ITEMSERV		:= Strzero(nI, 3)
			(cAlias)->APONTA		:= aDados[nI][1]
			(cAlias)->SERVICO		:= aDados[nI][2]
			(cAlias)->DESCSERV 		:= aDados[nI][3]
			(cAlias)->DATASERV 		:= SToD(aDados[nI][4])
			(cAlias)->NOMEFALE 		:= aDados[nI][5]

		Next
	Else

		MsgInfo("Nenhum serviço selecionado.","Atenção")

		(cAlias)->(DBAppend())
		(cAlias)->OK			:= " "
		(cAlias)->ITEMSERV 		:= Space(3)
		(cAlias)->APONTA		:= Space(TamSX3("UJV_CODIGO")[1])
		(cAlias)->SERVICO		:= Space(TamSX3("B1_COD")[1])
		(cAlias)->DESCSERV 		:= Space(TamSX3("B1_DESC")[1])
		(cAlias)->DATASERV 		:= CToD("")
		(cAlias)->NOMEFALE 		:= Space(TamSX3("UJV_NOME")[1])

	Endif

	(cAlias)->(DbGoTop())

	DEFINE MSDIALOG oDlgTer TITLE "Alteração dados do obito" From 000,000 TO 450,700 COLORS 0, 16777215 PIXEL

	//Browse
	oMark := MsSelect():New( cAlias, "OK", "", aTitulos,, @cMarca, {005,005,205,348} )
	oMark:bMark 				:= {|| MarcaT( (cAlias)->ITEMSERV, (cAlias)->(Recno() ), cAlias, @oMark )}
	oMark:oBrowse:LHASMARK    	:= .T.

	//Linha horizontal
	@ 198, 005 SAY oSay1 PROMPT Repl("_",342) SIZE 342, 007 OF oDlgTer COLORS CLR_GRAY, 16777215 PIXEL

	@ 208, 270 BUTTON oBut1 PROMPT "Alterar" 	SIZE 040, 010 OF oDlgTer ACTION AltDados( cAlias, @oDlgTer ,@lImpFechar, @oMark ) PIXEL
	@ 208, 317 BUTTON oBut2 PROMPT "Fechar" 	SIZE 030, 010 OF oDlgTer ACTION {||oDlgTer:End()} PIXEL

	ACTIVATE MSDIALOG oDlgTer CENTERED

	RestArea( aArea )

Return(lRet)

/*/{Protheus.doc} MarcaT
funcao para marcar o item selecionado
e demarcar os demais itens
@type function
@version 
@author g.sampaio
@since 07/05/2020
@param cItemMark, character, item a ser marcado
@param nRecTRB, numeric, numero do recno do item
@param cAlias, character, alias temporario
@param oMark, character, objeto do markbrowse
@return return_type, return_description
/*/
/**************************************/
Static Function MarcaT( cItemMark, nRecTRB, cAlias, oMark )
/**************************************/

	Local aArea			:= GetArea()

	Default cItemMark	:= ""
	Default nRecTRB		:= 0
	Default cAlias		:= ""

	// verifico se o alias tem dados
	If Select(cAlias) > 0

		(cAlias)->(DbGoTop())

		While (cAlias)->(!EOF())

			If (cAlias)->ITEMSERV <> cItemMark
				RecLock(cAlias,.F.)
				(cAlias)->OK := "  "

				(cAlias)->(MsUnlock())
			Endif

			(cAlias)->(DbSkip())
		EndDo

		(cAlias)->(DbGoTop())
		(cAlias)->(DbGoTo(nRecTRB)) // volto para o registro anterior

	Endif

	// atualizo o markbrowse
	oMark:oBrowse:Refresh()

	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} AltDados
funcao para alterar os dados do obito
@type function
@version 
@author g.sampaio
@since 07/05/2020
@param cAlias, character, alias temporario com os dados para serem alterados
@return nil
/*/
/************************/
Static Function AltDados( cAlias, oDlgTer ,lImpFechar, oMark )
/************************/

	Local aArea 	:= GetArea()
	Local aAreaUJV	:= UJV->( GetArea() )
	Local aAreaU04	:= U04->( GetArea() )
	Local cIniCpo1 	:= Space(TamSX3("UJV_NOME")[1])
	Local dIniCpo2 	:= Stod("")
	Local nAnosExu	:= SuperGetMv("MV_XANOSEX",.F.,5)
	Local nCont 	:= 0

	(cAlias)->(DbGoTop())

	// percorro os dados do alias
	While (cAlias)->(!EOF())

		// verifico o item marcado
		If (cAlias)->OK == "mk" .And. !Empty((cAlias)->APONTA)

			// pego o conteudo atual do obito
			cIniCpo1 := (cAlias)->NOMEFALE
			dIniCpo2 := (cAlias)->DATASERV

			// chamo a tela para o preenchimento dos novos dados
			If TelaDados( @cIniCpo1, @dIniCpo2 )

				UJV->(DbSetOrder(1)) // UJV_FILIAL+UJV_CODIGO
				If UJV->(DbSeek(xFilial("UJV")+(cAlias)->APONTA))

					BEGIN TRANSACTION

						// altero o registro da tabela de apontamnetos
						If UJV->( RecLock("UJV",.F.) )
							UJV->UJV_NOME 	:= cIniCpo1
							UJV->UJV_DTSEPU := dIniCpo2
							UJV->(MsUnlock())
						Else
							UJV->( DisarmTransaction() )
						EndIf

						// altero os dados do enderecamento
						U04->(DbSetOrder(5)) //U04_FILIAL+U04_APONTA
						If U04->(DbSeek(xFilial("U04")+UJV->UJV_CODIGO))

							If U04->(RecLock("U04",.F.))
								U04->U04_QUEMUT := cIniCpo1
								U04->U04_DATA	:= dIniCpo2
								U04->U04_DTUTIL := dIniCpo2

								// posiciono no cadastro de servico
								DbSelectArea("SB1")
								SB1->(DbSetOrder(1)) //B1_FILIAL+B1_COD
								If SB1->(DbSeek(xFilial("SB1")+(cAlias)->SERVICO))

									If SB1->B1_XOCUGAV == "S" // verifico se ocupa gaveta
										U04->U04_PRZEXU	:= YearSum( dIniCpo2, nAnosExu ) // altero o prazo de exeumacao
									Else
										U04->U04_PRZEXU	:= dIniCpo2
									Endif

								Endif

								U04->(MsUnlock())
							Else
								U04->( DisarmTransaction() )
							EndIf

						Endif

					END TRANSACTION

					MsgInfo("Dados alterados com sucesso.","Atenção")
					nCont++
				Endif
			Endif
		Endif

		(cAlias)->(DbSkip())
	EndDo

	// verifico se tem algum registro selecionado
	If nCont == 0
	
		MsgInfo("Nenhum registro selecionado.","Atenção")

		(cAlias)->(DbGoTop())
		oMark:oBrowse:Refresh()

	Else

		FechDlgT( @oDlgTer, @lImpFechar, cAlias )
	
	Endif

	RestArea( aAreaU04 )
	RestArea( aAreaUJV )
	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} FechDlgT
funcao para encerrar a rotina
@type function
@version 
@author g.sampaio
@since 07/05/2020
@param oDlgTer, object, objeto do browse da tela
@param lImpFechar, logical, param_description
@param cAlias, character, alias temporario criado para ser encerrado
@return return_type, return_description
/*/
/*************************/
Static Function FechDlgT( oDlgTer, lImpFechar, cAlias )
/*************************/

	Local aArea			:= GetArea()

	Default cAlias		:= ""
	Default lImpFechar	:= .F.

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	Endif

	//????????????????????????????????????
	//?Apagando arquivo temporario       ?
	//????????????????????????????????????
	FErase(cAlias + GetDBExtension())
	FErase(cAlias + OrdBagExt())

	oDlgTer:End()

	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} TelaDados
funcao para exibir a tela para o usuario informar
os novos dados do obito
@type function
@version 
@author g.sampaio
@since 08/05/2020
@param cIniCpo1, character, nome do obito
@param dIniCpo2, character, data do obito
@return return_type, return_description
/*/
Static Function TelaDados( cNomeObt, dDataObt )

	Local cNomeOld		:= ""
	Local dDataOld		:= ""
	Local lRetorno		:= .T.
	Local oButton1		:= Nil
	Local oButton2		:= Nil
	Local oFont1 		:= TFont():New("MS Sans Serif",,016,,.T.,,,,,.F.,.F.)
	Local oGet1			:= Nil
	Local oGet2			:= Nil
	Local oGroup1		:= Nil
	Local oSay1			:= Nil
	Local oSay2			:= Nil
	Local oDlgNew		:= Nil

	Default cNomeObt	:= Space(TamSX3("UJV_NOME")[1])
	Default dDataObt	:= Stod("")

	// faco o backup do nome e da data anteriores
	cNomeOld	:= cNomeObt
	dDataOld	:= dDataObt

	DEFINE MSDIALOG oDlgNew TITLE "Alteração de dados do Óbito" FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL

	@ 001, 002 GROUP oGroup1 TO 096, 247 PROMPT "Novos de Dados do Óbito" OF oDlgNew COLOR 0, 16777215 PIXEL

	// novo nome
	@ 025, 015 SAY oSay1 PROMPT "Novo Nome" SIZE 050, 007 OF oDlgNew FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 026, 066 MSGET oGet1 VAR cNomeObt PICTURE "@!" SIZE 167, 010 OF oDlgNew COLORS 0, 16777215 PIXEL

	// nova data
	@ 040, 015 SAY oSay2 PROMPT "Nova Data" SIZE 050, 007 OF oDlgNew FONT oFont1 COLORS 0, 16777215 PIXEL
	@ 041, 066 MSGET oGet2 VAR dDataObt SIZE 060, 010 OF oDlgNew COLORS 0, 16777215 PIXEL PICTURE "@D" HASBUTTON

	@ 078, 150 BUTTON oButton1 PROMPT "Cancelar" SIZE 037, 012 OF oDlgNew PIXEL ACTION ( CancelaAlteracao( cNomeOld, dDataOld, @cNomeObt, @dDataObt, @oDlgNew ) )
	@ 078, 200 BUTTON oButton2 PROMPT "Confirmar" SIZE 037, 012 OF oDlgNew PIXEL ACTION ( lRetorno := ValidaDados( cNomeOld, dDataOld, cNomeObt, dDataObt, @oDlgNew ) )

	ACTIVATE MSDIALOG oDlgNew CENTERED

Return(lRetorno)

/*/{Protheus.doc} ValidaDados
funcao para validar os dados alterados do obito
@type function
@version 
@author g.sampaio
@since 08/05/2020
@param cNomeOld, character, nome antigo 
@param dDataOld, character, data antiga
@param cNomeObt, character, nome novo
@param dDataObt, character, data nova
@param oDlg, objeto, objeto da tela
@return logico, retorna se esta tudo certo ou nao
/*/
Static Function ValidaDados( cNomeOld, dDataOld, cNomeObt, dDataObt, oDlgNew )

	Local aArea			:= GetArea()
	Local lRetorno		:= .T.

	Default cNomeOld	:= ""
	Default dDataOld	:= Stod("")
	Default cNomeObt	:= ""
	Default dDataObt	:= Stod("")

	// verifico se os novos dados estao preenchidos
	// verifico se o novo nome do obito esta preenchido
	If lRetorno .And. Empty( AllTrim( cNomeObt ) )

		lRetorno	:= .F. // retorno

		// mensagem para o usuario
		MsgAlert(" Para confirmar o campo <Novo nome> não pode estar sem preenchimento, retorne e preencha o conteúdo novamente! ")

	EndIf

	// verifico se o nova data do obito esta preenchida
	If lRetorno .And. Empty( dDataObt )

		lRetorno	:= .F. // retorno

		// mensagem para o usuario
		MsgAlert(" Para confirmar o campo <Nova data> não pode estar sem preenchimento, retorne e preencha o conteúdo novamente! ")

	EndIf

	// verifico se os dados estao iguais
	If lRetorno .And. AllTrim(cNomeObt) == AllTrim(cNomeOld) .And. dDataObt == dDataOld

		lRetorno	:= .F.// retorno

		// mensagem para o usuario
		MsgAlert(" Não houve nenhuma alteração, para confirmar altere o formulário ou cancele a operação. ")

	EndIf

	// verifico se esta tudo certo
	If lRetorno

		// fecho a tela de alteracao e sigo com o processo
		oDlgNew:End()

	EndIf

	RestArea( aArea )

Return( lRetorno )

/*/{Protheus.doc} CancelaAlteracao
funcao para cancelar a operacao
@type function
@version 
@author g.sampaio
@since 08/05/2020
@param cNomeOld, character, nome antigo 
@param dDataOld, character, data antiga
@param cNomeObt, character, nome novo
@param dDataObt, character, data nova
@param oDlg, objeto, objeto da tela
@return nil
/*/
Static Function CancelaAlteracao( cNomeOld, dDataOld, cNomeObt, dDataObt, oDlgNew )

	Local aArea			:= GetArea()

	Default cNomeOld	:= ""
	Default dDataOld	:= Ctod(Space(8))
	Default cNomeObt	:= ""
	Default dDataObt	:= Ctod(Space(8))

	// restauro os valores antigos nas variaveis
	cNomeObt	:= cNomeOld	// restauro o nome
	dDataObt	:= dDataOld // restauro a data

	RestArea( aArea )

Return(Nil)