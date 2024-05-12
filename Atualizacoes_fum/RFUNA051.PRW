#include 'totvs.ch'
#include 'topconn.ch'
#include 'tbiConn.ch'
#include 'fileio.ch'

#define CRLF chr(13)+chr(10)

/*/{Protheus.doc} RFUNA051
Rotina de cancelamento por lote
@author g.sampaio
@since 01/09/2019
@version 1.0
@type function
/*/
User Function RFUNA051()

	Local aArea			    := GetArea()
	Local aAreaUF2		    := UF2->( GetArea() )
	Local cPerg 		    := "RFUNA051"
	Local cPlano		    := ""
	Local cRota	            := ""
	Local nSituacao	        := 0
	Local dDtDaAtivacao     := stod("")
	Local dDtAteAtivacao    := stod("")
	Local lContinua		    := .T.
	Local nConsTipo			:= 0

	Private __XVEZ 		    := "0"
	Private __ASC           := .T.
	Private _nMarca		    := 0

	// cria as perguntas na SX1
	AjustaSx1(cPerg)

	// enquanto o usuário não cancelar a tela de perguntas
	While lContinua

		// chama a tela de perguntas
		lContinua := Pergunte(cPerg,.T.)

		// se estiver tudo certo
		if lContinua

			dDtDaAtivacao 	:= MV_PAR01
			dDtAteAtivacao	:= MV_PAR02
			cPlano			:= MV_PAR03
			cRota			:= MV_PAR04
			nSituacao		:= MV_PAR05
			nConsTipo		:= MV_PAR06

			// vou fazer a validacao dos parametros preenchidos
			if ValidParam( dDtDaAtivacao, dDtAteAtivacao, cPlano, cRota, nSituacao )

				// chamo a consulta de contratos para retornar a grid
				FWMsgRun(,{|oSay| ConsultaContratos( dDtDaAtivacao, dDtAteAtivacao, cPlano, cRota, nSituacao, nConsTipo ) },'Aguarde...','Consultando Contratos para cancelamento ...')

			endif

		endif

	EndDo

	RestArea(aAreaUF2)
	RestArea(aArea)

Return( Nil )

/*/{Protheus.doc} ValidParam
//TODO Função que valida os parâmetros informados
@author g.sampaio
@since 01/09/2019
@version 1.0
@param dDtDaAtivacao    , date      , da data de ativacao
@param dDtAteAtivacao   , date      , ate a data de ativacao
@param cPlano           , character , planos 
@param cRota            , character , rotas
@param nSituacao        , numeric , situacao dos planos
@type function
@return logical, retorno sobre a validacao dos parametros
/*/

Static Function ValidParam( dDtDaAtivacao, dDtAteAtivacao, cPlano, cRota, nSituacao )

	Local lRetorno              := .T.

	Default dDtDaAtivacao       := stod("")
	Default dDtAteAtivacao      := stod("")
	Default cPlano              := ""
	Default cRota               := ""
	Default nSituacao           := 0

	// verifico se foram preenchidos todos os parâmetros
	If Empty(dDtDaAtivacao)// verifico se a data de inicio do range esta preenchido
		Alert("Informe o parametro <Da Ativacao ?>")
		lRetorno := .F.

	ElseIf Empty(dDtAteAtivacao)// verifico se a data do fim do range esta preenchido
		Alert("Informe o parametro <Até a Ativacao ?>")
		lRetorno := .F.

	endif

Return( lRetorno )

/*/{Protheus.doc} ConsultaContratos
Função que consulta os contratos que irão ser cancelados
@author g.sampaio
@since 01/09/2019
@version 1.0
@type function
/*/
Static Function ConsultaContratos( dDtDaAtivacao, dDtAteAtivacao, cPlano, cRota, nSituacao, nConsTipo )

	Local aButtons		        := {}
	Local aObjects 		        := {}
	Local aSizeAut		        := MsAdvSize()
	Local aInfo			        := {}
	Local aPosObj		        := {}
	Local lContinua             := .T.
	Local nQtTotal		        := 0
	Local oPn1			        := Nil
	Local oPn2			        := Nil
	Local oPn3			        := Nil
	Local oTotal		        := Nil
	Local oQtTotal		        := Nil
	Local oGrid			        := Nil
	Local oDlg                  := Nil
	Local oBrw1					:= Nil

	Private	nColOrder			:= 0

	Default dDtDaAtivacao       := stod("")
	Default dDtAteAtivacao      := stod("")
	Default cPlano              := ""
	Default cRota               := ""
	Default nSituacao           := 3
	Default nConsTipo           := 1

	Private cCadastro           := "Cancelamento Por Lote"

	//Largura, Altura, Modifica largura, Modifica altura
	aAdd( aObjects, { 100,	100, .T., .T. } ) //Browse

	aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. )

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] COLORS 0, 16777215 PIXEL

	//defino os panels da tela
	@ 001,000 MSPANEL oPn1 SIZE 150, 050 OF oDlg
	@ 001,000 MSPANEL oPn2 SIZE 150, 050 OF oPn1
	@ 001,000 MSPANEL oPn3 SIZE 150, 050 OF oPn1

	oPn1:Align  := CONTROL_ALIGN_ALLCLIENT
	oPn2:Align  := CONTROL_ALIGN_TOP
	oPn3:Align  := CONTROL_ALIGN_BOTTOM

	oPn2:nHeight := (oMainWnd:nClientHeight / 2) + 150
	oPn3:nHeight := (oMainWnd:nClientHeight - oPn2:nHeight ) - 100

	EnchoiceBar(oDlg, {|| FWMsgRun(,{|oSay| Confirmar(oSay,oGrid,oDlg) },'Aguarde...','Cancelando contratos selecionados...')},{|| oDlg:End()},,aButtons)

	@ 000, 005 SAY oTotal PROMPT "Quantidade Selecionada:" SIZE 100, 007 OF oPn3 COLORS CLR_RED Font oFont COLOR CLR_BLACK PIXEL
	@ 000, 090 MSGET oQtTotal VAR nQtTotal SIZE 100, 007 When .F. OF oPn3 HASBUTTON PIXEL COLOR CLR_BLACK Picture "@E 999999999"

	// crio o grid de contratos
	oGrid := MsGridCTR(oPn2)

	// duplo clique no grid
	oGrid:oBrowse:bLDblClick := {|| DuoClique(oGrid,oQtTotal,@nQtTotal)}

	// clique no cabecalho da grid
	oGrid:oBrowse:bHeaderClick := {|oBrw1,nCol| if(oGrid:oBrowse:nColPos <> 111 .And. nCol == 1,(MarcaTodos(oGrid,oQtTotal,@nQtTotal),;
		oBrw1:SetFocus()),(U_OrdGrid(oGrid,nCol) , nColOrder := nCol ))}


	// objeto ocupa todo panel
	oGrid:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	// atualizo o objeto
	oGrid:oBrowse:Refresh()

	// caso não tenha encontrato títulos
	lContinua := RefreshGrid( @oGrid, dDtDaAtivacao, dDtAteAtivacao , cPlano, cRota, nSituacao, nConsTipo, oQtTotal, @nQtTotal )

	// caso eu deva fechar a tela
	If !lContinua

		// mensagem para o usuario
		Alert("Não foram encontrados contratos suspensos para serem cancelados!")
		oDlg:End()

	endif

	ACTIVATE MSDIALOG oDlg CENTERED

Return(Nil)

/*/{Protheus.doc} MsGridCTR
//TODO Função que cria o grid de contratos
@author g.sampaio
@since 01/09/2019
@version 1.0
@return object, retorno o objeto da grid da tela
@type function
/*/

Static Function MsGridCTR(oPainel)

	Local oGrid			:= NIL
	Local nX			:= 1
	Local aHeaderEx 	:= {}
	Local aColsEx 		:= {}
	Local aFieldFill 	:= {}
	Local aFields 		:= {"MARK","CONTRATO","CLIENTE","LOJA","NOME","PLANO","DESCPLANO","DTCAD","DTATIV","DTSUSP","PARCELAS","VALOR"}
	Local aAlterFields 	:= {}

	// percorro os campos definidos previamente
	For nX := 1 To Len(aFields)

		if aFields[nX] == "MARK"

			Aadd(aHeaderEx, {"", aFields[nX] ,"@BMP",2,0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "CONTRATO"

			Aadd(aHeaderEx, {"Contrato",aFields[nX],"@!",6,0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "CLIENTE"

			Aadd(aHeaderEx, {"Cliente",aFields[nX],"@!",TamSX3("UF2_CLIENT")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "LOJA"

			Aadd(aHeaderEx, {"Loja",aFields[nX],"@!",TamSX3("UF2_LOJA")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "NOME"

			Aadd(aHeaderEx, {"Nome",aFields[nX],"@!",60,0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "PLANO"

			Aadd(aHeaderEx, {"Plano",aFields[nX],"@!",6,0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "DESCPLANO"

			Aadd(aHeaderEx, {"Descrição",aFields[nX],"@!",30,0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "DTCAD"

			Aadd(aHeaderEx, {"Dt.Cadastro",aFields[nX],"@D",8,0,"","€€€€€€€€€€€€€€","D","","","",""})

		elseif aFields[nX] == "DTATIV" // .and. MV_PAR04 <> 3 // exibe o tipo quando for diferente de remissivo

			Aadd(aHeaderEx, {"Dt.Ativação",aFields[nX],"@D",8,0,"","€€€€€€€€€€€€€€","D","","","",""})

		elseif aFields[nX] == "DTSUSP" //.and. MV_PAR04 <> 3 // exibe o tipo quando for diferente de remissivo

			Aadd(aHeaderEx, {"Dt.Suspensão",aFields[nX],"@D",8,0,"","€€€€€€€€€€€€€€","D","","","",""})

		elseif aFields[nX] == "PARCELAS" //.and. MV_PAR04 <> 3 // exibe o tipo quando for diferente de remissivo

			Aadd(aHeaderEx, {"Parcelas",aFields[nX],"@E 999",6,0,"","€€€€€€€€€€€€€€","N","","","",""})

		elseif aFields[nX] == "VALOR"

			Aadd(aHeaderEx, {"Valor em Aberto",aFields[nX],PesqPict("UF2","UF2_VALOR"),TamSX3("UF2_VALOR")[1],0,"","€€€€€€€€€€€€€€","N","","","",""})

		endif

	Next nX

	// defino valor default de acordo com o tipo do campo
	For nX := 1 To Len(aHeaderEx)

		if aHeaderEx[nX,2] == "MARK"
			Aadd(aFieldFill, "UNCHECKED")
		elseif aHeaderEx[nX,8] == "C"
			Aadd(aFieldFill, "")
		elseif aHeaderEx[nX,8] == "N"
			Aadd(aFieldFill, 0)
		elseif aHeaderEx[nX,8] == "D"
			Aadd(aFieldFill, CTOD("  /  /    "))
		elseif aHeaderEx[nX,8] == "L"
			Aadd(aFieldFill, .F.)
		endif

	Next nX

	Aadd(aFieldFill, .F.)
	Aadd(aColsEx, aFieldFill)

	oGrid := MsNewGetDados():New( 05,05,000, 000, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,;
		, 999, "AllwaysTrue", "", "AllwaysTrue",oPainel, aHeaderEx, aColsEx)


Return(oGrid)

/*/{Protheus.doc} RefreshGrid
//TODO Função atualiza o grid de contratos
@author g.sampaio
@since 01/09/2019
@version 1.0
@return logical, retorno sobre a montagem da grid
@type function
/*/

Static Function RefreshGrid( oGrid, dDtDaAtivacao, dDtAteAtivacao , cPlano, cRota, nSituacao, nConsTipo, oQtTotal, nQtTotal )

	Local aArea					:= GetArea()
	Local aFieldFill			:= {}
	Local cQuery 				:= ""
	Local lRetorno				:= .T.
	Local nMesSemObito			:= SuperGetMV("ES_MESSOBT",,3)	// quantidade meses suspensos a considerar sem obito
	Local nMesComObito			:= SuperGetMV("ES_MESCOBT",,3)	// quantidade meses suspensos a considerar com obito
	Local nQtdParcAtrasadas		:= SuperGetMV("MV_XQTDCAN",,11) // quantidade de parcelas atrasadas para cancelamento do contrato
	Local lUsaConvalescencia	:= SuperGetMv("MV_XUSACON",.F.,.F.)

	Default nConsTipo	    	:= 1
	Default nSituacao	    	:= 3
	Default cPlano          	:= ""
	Default cRota				:= ""
	Default nQtTotal        	:= 0
	Default dDtDaAtivacao   	:= stod("")
	Default dDtAteAtivacao  	:= stod("")

	// verifico se não existe este alias criado
	If Select("TRBCTR") > 0
		TRBCTR->(DbCloseArea())
	EndIf

	cQuery := " SELECT "
	cQuery += " UF2.UF2_CODIGO 		AS CONTRATO, "
	cQuery += " UF2.UF2_CLIENT 		AS CLIENTE, "
	cQuery += " UF2.UF2_LOJA 		AS LOJA, "
	cQuery += " CLIENTES.A1_NOME 	AS NOME, "
	cQuery += " UF2.UF2_PLANO		AS PLANO, "
	cQuery += " PLANO.UF0_DESCRI	AS DESCPLANO, "
	cQuery += " UF2.UF2_DTCAD		AS DTCAD, "
	cQuery += " UF2.UF2_DTATIV		AS DTATIV, "
	cQuery += " UF2.UF2_DTSUSP	 	AS DTSUSP, "
	cQuery += " COUNT(SE1.E1_NUM)	AS QTDPAR, "
	cQuery += " SUM(SE1.E1_SALDO)	AS VALOR "
	cQuery += " FROM "
	cQuery += RetSqlName("UF2") + " UF2 "

	cQuery += " INNER JOIN "
	cQuery += + RetSQLName("SA1") + " CLIENTES "
	cQuery += " ON "
	cQuery += " CLIENTES.D_E_L_E_T_ 	= ' ' "
	cQuery += " AND CLIENTES.A1_FILIAL 	= '" + xFilial("SA1") + "' "
	cQuery += " AND CLIENTES.A1_COD 	= UF2.UF2_CLIENT "
	cQuery += " AND CLIENTES.A1_LOJA 	= UF2.UF2_LOJA  "

	cQuery += " INNER JOIN "
	cQuery += + RetSQLName("UF0") + " PLANO "
	cQuery += " ON "
	cQuery += " PLANO.D_E_L_E_T_ 	 = ' ' "
	cQuery += " AND PLANO.UF0_FILIAL = '" + xFilial("UF0") + "' "
	cQuery += " AND PLANO.UF0_CODIGO = UF2.UF2_PLANO "

	cQuery += " INNER JOIN "
	cQuery += + RetSqlName("SE1")+" SE1
	cQuery += " ON "
	cQuery += " SE1.D_E_L_E_T_	= ' ' "
	cQuery += " AND SE1.E1_XCTRFUN  = UF2.UF2_CODIGO "
	cQuery += " AND SE1.E1_CLIENTE  = UF2.UF2_CLIENT "
	cQuery += " AND SE1.E1_LOJA     = UF2.UF2_LOJA "
	cQuery += " AND SE1.E1_FILIAL	= '"+xFilial("SE1")+"' "
	cQuery += " AND SE1.E1_SALDO	> 0" //Em aberto
	cQuery += " AND SE1.E1_VENCREA 	< '"+DToS(dDataBase)+"' "

	// verifico se a rota esta preenchida nos parametros
	If !Empty( Alltrim(cRota) )

		cQuery += " LEFT JOIN "
		cQuery += + RetSQLName("ZFC") + " BAIRROS "
		cQuery += " ON "
		cQuery += " BAIRROS.D_E_L_E_T_ 		= ' ' "
		cQuery += " AND BAIRROS.ZFC_FILIAL 	= '" + xFilial("ZFC") + "' "
		cQuery += " AND CLIENTES.A1_XCODBAI = BAIRROS.ZFC_CODBAI "

		cQuery += " LEFT JOIN "
		cQuery += + RetSQLName("U35") + " ITENS_ROTA "
		cQuery += " ON "
		cQuery += " ITENS_ROTA.D_E_L_E_T_ 		= ' ' "
		cQuery += " AND ITENS_ROTA.U35_FILIAL 	= '" + xFilial("U35") + "'"
		cQuery += " AND BAIRROS.ZFC_CODBAI 		= ITENS_ROTA.U35_CODBAI "

		cQuery += " LEFT JOIN "
		cQuery += + RetSQLName("U34") + " ROTA "
		cQuery += " ON "
		cQuery += " ROTA.D_E_L_E_T_ 			= ' ' "
		cQuery += " AND ITENS_ROTA.U35_FILIAL 	= ROTA.U34_FILIAL "
		cQuery += " AND ITENS_ROTA.U35_CODIGO 	= ROTA.U34_CODIGO "

	EndIf

	cQuery += " WHERE "
	cQuery += " UF2.D_E_L_E_T_ <> '*' "
	cQuery += " AND UF2.UF2_FILIAL = '" + xFilial("UF2") + "' "
	
	// verifico se o plano esta preenchido
	if !Empty( Alltrim( cPlano ) )
		cQuery += " AND UF2.UF2_PLANO IN " + FormatIn( AllTrim( cPlano ),";")
	endif

	// verifico se o rota esta preenchido
	if !Empty( Alltrim( cRota ) )
		cQuery += " AND ROTA.U34_CODIGO IN " + FormatIn( AllTrim( cRota ),";")
	endif

	cQuery += " AND UF2.UF2_DTATIV BETWEEN '" + dtos( dDtDaAtivacao ) + "' AND '" + dtos( dDtAteAtivacao ) + "'"
	
	If nConsTipo == 1 // 1=Por Data Suspensão | 2=Por Qtde Parc Atrasadas
		cQuery += " AND UF2.UF2_STATUS = 'S' "
	Else
		cQuery += " AND UF2.UF2_STATUS <> 'C' "
	EndIf

	// verifico se a data de suspensao e inferior a quantidade de meses estiPulada no parametro ES_MESSUSP
	If nSituacao == 1 // 1=Com Obito | 2=Sem Obito | 3=Ambos
		If nConsTipo == 1 // 1=Por Data Suspensão | 2=Por Qtde Parc Atrasadas
			cQuery += " AND UF2.UF2_DTSUSP < '" + DtoS( MonthSub( dDataBase, nMesComObito ) ) + "' "
		EndIf
		cQuery += " AND EXISTS "
	ElseIf nSituacao == 2 // 1=Com Obito | 2=Sem Obito | 3=Ambos
		If nConsTipo == 1 // 1=Por Data Suspensão | 2=Por Qtde Parc Atrasadas
			cQuery += " AND UF2.UF2_DTSUSP < '" + DtoS( MonthSub( dDataBase, nMesSemObito ) ) + "' "
		EndIf
		cQuery += " AND NOT EXISTS"
	ElseIf nSituacao == 3 // 1=Com Obito | 2=Sem Obito | 3=Ambos
		If nConsTipo == 1 // 1=Por Data Suspensão | 2=Por Qtde Parc Atrasadas
			cQuery += " AND UF2.UF2_DTSUSP < '" + DtoS( MonthSub( dDataBase, MIN(nMesComObito, nMesSemObito) ) ) + "' "
		EndIf
	EndIf

	/////////////////////////////////////////////////////////////////////////////////////////////////
	/////////// FILTRO CONTRATOS COM FALECIMENTO OU SEM DE ACORDO COM A VARIAVEL nSituacao /////////
	////////////////////////////////////////////////////////////////////////////////////////////////
	If nSituacao <> 3 // 1=Com Obito | 2=Sem Obito | 3=Ambos
		cQuery += " (
		cQuery += " 	SELECT UF4_CODIGO "
		cQuery += " 	FROM " + RetSQLName("UF4") + " UF4 "
		cQuery += " 	WHERE UF4.D_E_L_E_T_ = ' ' "
		cQuery += " 	AND UF4.UF4_FILIAL = UF2.UF2_FILIAL "
		cQuery += " 	AND UF4.UF4_CODIGO = UF2.UF2_CODIGO "
		cQuery += " 	AND UF4.UF4_FALECI <> ' ' "
		cQuery += "  )  "
	EndIf

	// verifico se usa convalescencia
	If lUsaConvalescencia

		cQuery += " AND NOT EXISTS ( SELECT UJH.UJH_CONTRA FROM " + RetSQLName("UJH") + " UJH "
		cQuery += " 				WHERE UJH.D_E_L_E_T_ = ' ' 	"
		cQuery += " 				AND UJH.UJH_FILIAL = '" + xFilial("UJH") + "'	"
		cQuery += " 				AND UJH.UJH_CONTRA =  UF2.UF2_CODIGO 		"
		cQuery += " 				AND UJH.UJH_STATUS IN ('L','P') )"

	EndIf

	cQuery += " GROUP BY "
	cQuery += "        UF2.UF2_CODIGO, "
	cQuery += "        UF2.UF2_CLIENT, "
	cQuery += "        UF2.UF2_LOJA , "
	cQuery += "        CLIENTES.A1_NOME, "
	cQuery += "        UF2.UF2_PLANO , "
	cQuery += "        PLANO.UF0_DESCRI,"
	cQuery += "        UF2.UF2_DTCAD, "
	cQuery += "        UF2.UF2_DTATIV, "
	cQuery += "        UF2.UF2_DTSUSP "

	If nConsTipo == 2 // 1=Por Data Suspensão | 2=Por Qtde Parc Atrasadas
		cQuery += " HAVING COUNT(SE1.E1_NUM) >= " + cValToChar(nQtdParcAtrasadas)
	EndIf

	cQuery += " ORDER BY UF2.UF2_CODIGO "

	// função que converte a query genérica para o protheus
	cQuery := ChangeQuery(cQuery)

	MEMOWRITE( "C:\TEMP\CANCELAMENTO.SQL", cQuery )

	// crio o alias temporario
	TcQuery cQuery New Alias "TRBCTR" // Cria uma nova area com o resultado do query

	If TRBCTR->(!Eof())

		// zero o acols
		oGrid:Acols := {}

		// se existir contratos a serem reajustados
		While TRBCTR->(!Eof())

			// zero as variaveis
			aFieldFill  := {}

			// fixo ou faixa etaria - monto o array de dados para montar a Grid
			aadd(aFieldFill, "CHECKED" )
			aadd(aFieldFill, TRBCTR->CONTRATO )
			aadd(aFieldFill, TRBCTR->CLIENTE )
			aadd(aFieldFill, TRBCTR->LOJA )
			aadd(aFieldFill, TRBCTR->NOME )
			aadd(aFieldFill, TRBCTR->PLANO )
			aadd(aFieldFill, TRBCTR->DESCPLANO )
			aadd(aFieldFill, Stod( TRBCTR->DTCAD ) )
			aadd(aFieldFill, Stod( TRBCTR->DTATIV ) )
			aadd(aFieldFill, Stod( TRBCTR->DTSUSP ) )
			aadd(aFieldFill, TRBCTR->QTDPAR )
			aadd(aFieldFill, TRBCTR->VALOR )

			aadd(aFieldFill, .F.)
			aadd(oGrid:Acols,aFieldFill)

			nQtTotal++

			TRBCTR->( DbSkip() )
		EndDo

		oQtTotal:Refresh()

	Else

		// retorno falso pois nao existem dados para serem exibidos
		lRetorno	:= .F.

	EndIf

	// fecho o alias temporario criado
	If Select("TRBCTR") > 0
		TRBCTR->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} DuoClique
//TODO Função chamada no duplo clique no grid
@author g.sampaio
@since 01/09/2019
@version 1.0
@type function
/*/
Static Function DuoClique(oObj,oQtTotal,nQtTotal)

	Local nPosMark	    := aScan(oObj:aHeader,{|x| AllTrim(x[2])== "MARK"})

// verifico se o registro esta selecionado
	if oObj:aCols[oObj:nAt][nPosMark] == "CHECKED"

		// se nao estiver selecionado diminuo dos contadores
		oObj:aCols[oObj:nAt][nPosMark] 	:= "UNCHECKED"
		nQtTotal--

	else

		// se nao estiver selecionado aumento os contatadores
		oObj:aCols[oObj:nAt][nPosMark] 	:= "CHECKED"
		nQtTotal++

	endif

	oQtTotal:Refresh()

	oObj:oBrowse:Refresh()

Return(Nil)

/*/{Protheus.doc} MarcaTodos
//TODO Função chamada pela ação de clicar no cabeçalho dos grids
para selecionar todos os checkbox
@author g.sampaio
@since 01/09/2019
@version 1.0
@type function
/*/

Static Function MarcaTodos(_obj,oQtTotal,nQtTotal)

	Local nX		    := 1

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

			For nX := 1 To Len(_obj:aCols)
				_obj:aCols[nX][1] := "UNCHECKED"
			Next

			_nMarca := 0

		Endif

		__XVEZ:="0"

		// atualizo objetos
		_obj:oBrowse:Refresh()
		oQtTotal:Refresh()


	Endif

Return(Nil)

/*/{Protheus.doc} AjustaSX1
//TODO Função que cria as perguntas na SX1.	
@author g.sampaio
@since 01/09/2019
@version 1.0
@type function
/*/
Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relatório

	Local aRegs		:= {}

	Default cPerg	:= ""

	// parametros SX1
	//////////// Ativação ///////////////
	aAdd(aRegs,{cPerg,'01','Da Ativação?'       		,'','','mv_ch1','D', TamSx3("UF2_DTATIV")[1]    , 0, 0,'G','','mv_par01','','','','','',''})
	aAdd(aRegs,{cPerg,'02','Até a Ativação?'    		,'','','mv_ch2','D', TamSx3("UF2_DTATIV")[1]    , 0, 0,'G','','mv_par02','','','','','',''})

	///////////// Plano /////////////////
	aAdd(aRegs,{cPerg,'03','Plano(s):' 					,'','','mv_ch3','C', 99                         , 0, 0,'G','','mv_par03','','','','','','UF0MRK'})

	//////////// Rota ///////////////
	aAdd(aRegs,{cPerg,'04','Rota(s):' 					,'','','mv_ch4','C', 99                         , 0, 0,'G','','mv_par04','','','','','','U34MAR'})

	//////////// Stiuação ///////////////
	aAdd(aRegs,{cPerg,'05','Situação do(s) Plano(s):' 	,'','','mv_ch4','N', 1                          , 0, 3,'N','','mv_par05','1=Com Óbito','2=Sem Óbito','3=Ambos','','',''})

	//////////// Considera Tipo de Cancelamento ///////////////
	aAdd(aRegs,{cPerg,'06','Considera?' 				,'','','mv_ch4','N', 1                          , 0, 1,'N','','mv_par06','1=Por Data Suspensão','2=Por Qtde Parc Atrasadas','','','',''})

	// cria os dados da SX1
	U_CriaSX1( aRegs )

Return(Nil)

/*/{Protheus.doc} Confirmar
//TODO Função que cria as perguntas na SX1.	
@author g.sampaio
@since 01/09/2019
@version 1.0
@type function
/*/

Static Function Confirmar( oSay,oGrid,oDlg )

	Local aArea     	:= GetArea()
	Local aAreaUF2		:= UF2->(GetArea())
	Local cCodCan		:= Space(TamSX3("U31_CODIGO")[1])
	Local cMotCan		:= Space(TamSX3("U31_DESCRI")[1])
	Local cCancMsg		:= ""
	Local lContinua		:= .T.
	Local nPos			:= 0
	Local oCodCan		:= Nil
	Local oMotCan		:= Nil
	Local oDlgCan		:= Nil
	Local oSay1			:= Nil
	Local oSay2			:= Nil
	Local oSay3			:= Nil
	Local oButton1		:= Nil
	Local oButton2		:= Nil

	// verifico se no acols existem itens marcados
	nPos := Ascan( oGrid:Acols, { |x| Upper( AllTrim(x[1]) ) == "CHECKED" } )

	// caso nao encontrar itens
	If nPos == 0

		// mensagem para o usuario
		MsgAlert(" Não foram selecionados títulos para o cancelamento em lote! ")

		// retorno falso para a rotina
		lContinua := .F.

	EndIf

	If lContinua

		DEFINE MSDIALOG oDlgCan TITLE "Cancelamento de Contrato" From 0,0 TO 140,600 PIXEL

		@ 005,005 SAY oSay1 PROMPT "Motivo" SIZE 030, 007 OF oDlgCan COLORS 0, 16777215 PIXEL
		@ 018,005 MSGET oCodCan VAR cCodCan SIZE 040,007 PIXEL OF oDlgCan PICTURE "@!" Valid(ValMotCan(cCodCan,@cMotCan,oMotCan)) F3 "U31" HASBUTTON

		@ 005,055 SAY oSay2 PROMPT "Descrição" SIZE 030, 007 OF oDlgCan COLORS 0, 16777215 PIXEL
		@ 018,055 MSGET oMotCan VAR cMotCan SIZE 240,007 PIXEL OF oDlgCan PICTURE "@!" WHEN .F.

		//Linha horizontal
		@ 040, 005 SAY oSay3 PROMPT Repl("_",292) SIZE 292, 007 OF oDlgCan COLORS CLR_GRAY, 16777215 PIXEL

		//Botoes
		@ 051, 200 BUTTON oButton1 PROMPT "Confirmar" SIZE 040, 010 OF oDlgCan ACTION FWMsgRun(,{ |oSay| lContinua := CancelaLote( oSay, oGrid, cCodCan, @cCancMsg, oDlgCan, oDlg ) },'Aguarde...','Realizando o cancelamento por lote...') PIXEL
		@ 051, 250 BUTTON oButton2 PROMPT "Fechar" SIZE 040, 010 OF oDlgCan ACTION oDlgCan:End() PIXEL

		ACTIVATE MSDIALOG oDlgCan CENTERED

	Endif

	RestArea(aArea)
	RestArea(aAreaUF2)

Return( Nil )

/*/{Protheus.doc} ValMotCan
Valida motivos de cancelamento
@author g.sampaio
@since 03/09/2019
@version 1.0
@return logical, valida o motivo de cancelamento
@type function
/*/

Static Function ValMotCan(cCodCan,cMotCan,oMotCan)

	Local lRet := .T.

	// limpo o campo da descrição do cancelamento
	cMotCan := Space(TamSX3("U31_DESCRI")[1])

	// se o código estiver preenchido
	If !Empty(cCodCan)

		U31->(DbSetOrder(1)) // U31_FILIAL + U31_CODIGO
		If U31->(MsSeek(xFilial("U31") + cCodCan))
			cMotCan := U31->U31_DESCRI
		Else
			lRet := .F.
			MsgInfo("Motivo de Cancelamento inválido.","Atenção")
		Endif

	Endif

	oMotCan:Refresh()

Return(lRet)

/*/{Protheus.doc} CancelaLote
Faco o cancelamento dos contratos marcados
@author g.sampaio
@since 03/09/2019
@version 1.0
@return logical, retorna sobre o cancelamento em lote
@type function
/*/

Static Function CancelaLote( oSay, oGrid, cCodCan, cCancMsg, oDlgCan, oDlg )

	Local aArea 		:= GetArea()
	Local aAreaUF2		:= UF2->( GetArea() )
	Local cDirDest		:= ""
	Local cArquivo		:= ""
	Local cArqGer		:= ""
	Local lRetorno		:= .T.
	Local nPosCtr		:= Ascan( oGrid:aHeader, { |x| Alltrim(x[2]) == "CONTRATO" } )
	Local nPosMark		:= Ascan( oGrid:aHeader, { |x| Alltrim(x[2]) == "MARK" } )
	Local nI			:= 0
	Local oWriter		:= Nil

	Default cCodCan		:= ""
	Default	cCancMsg	:= ""

	// verifico o acols esta populado e o codigo de cancelamento foi informado
	If Len( oGrid:Acols ) > 0 .And. !Empty( cCodCan )

		// percorro os itens do acols
		For nI := 1 To Len( oGrid:Acols )

			// verifico se o registro esta selecionado
			If oGrid:Acols[nI,nPosMark] == "CHECKED"

				// posiciono no contrato
				UF2->( DbSetOrder(1) )

				If UF2->( MsSeek( xFilial("UF2")+oGrid:Acols[nI,nPosCtr] ) )

					cCancMsg += "==============================================================" + CRLF
					cCancMsg += "Contrato : " + oGrid:Acols[nI,nPosCtr] + CRLF

					// executo a rotina de cancelamento
					lRetorno := CancelaCtr( oGrid:Acols[nI,nPosCtr], .T., cCodCan, @cCancMsg, oSay )

				EndIf

			EndIf

		Next nI

		// sinalizo o final do log
		cCancMsg += "==============================================================" + CRLF

		// verifico se a mensagem esta cancelada
		If !Empty(cCancMsg)

			// diretorio aonde sera gerado o log
			cDirDest 	:= GetTempPath()

			// descricao do arquivo de log
			cArquivo	:= "logcontratos" + Str( Year( date() ),4) + StrZero( Month( date() ), 2)+StrZero( Day( date() ),2) + Left(Time(),2) + Substr(Time(),4,2) + Right(Time(),2) + ".txt"

			// geracao do arquivo de log
			cArqGer 	:= cDirDest + iif( substr(alltrim(cDirDest),len(alltrim(cDirDest))) == iif(IsSrvUnix(),"/","\"),  cArquivo, iif(IsSrvUnix(),"/","\") + cArquivo )

			// crio o objeto de escrita de arquivo
			oWriter := FWFileWriter():New( cArqGer, .T.)

			// se houve falha ao criar, mostra a mensagem
			If !oWriter:Create()
				MsgStop("Houve um erro ao gerar o arquivo: " + CRLF + oWriter:Error():Message, "Atenção")
			Else// senão, continua com o processamento

				// escreve o conteudo o arquivo
				oWriter:Write(cCancMsg)

				// encerra o arquivo
				oWriter:Close()

				// pergunta se deseja abrir o arquivo
				If MsgYesNo("Arquivo de log de contratos cancelados gerado com sucesso (" + cArqGer + ")!" + CRLF + "Deseja abrir?", "Atenção")
					ShellExecute("OPEN", cArquivo, "", GetTempPath() , 1 )
				EndIf

			EndIf

			If lRetorno
				oDlgCan:End()
				oDlg:End()
			EndIf

		EndIf

	EndIf

	RestArea( aAreaUF2 )
	RestArea( aArea )

Return( lRetorno )

/*/{Protheus.doc} CancelaCtr
Cancelamento do contrato de funeraria
@author g.sampaio
@since 17/09/2019
@version 1.0
@return logical, retorna sobre o cancelamento do contrato
@type function
/*/

Static Function CancelaCtr( cContrato, lCancLote, cCodCan, cCancMsg, oSay )

	Local aArea 		:= GetArea()
	Local lRet			:= .T.
	Local cOrigem		:= "RFUNA051"
	Local cOrigemDesc	:= "Cancelamento em Lote"
	Default cContrato	:= ""
	Default lCancLote	:= .F.
	Default cCodCan		:= ""
	Default cCancMsg	:= ""

	BEGIN TRANSACTION

		// chamo função que faz a exclusão dos títulos em aberto
		FWMsgRun(,{|oSay| lRet := ExcluiTitulos(oSay,cContrato,@cCancMsg)},'Aguarde...','Excluindo os títulos a receber em aberto...')

		// verifico se deu tudo certo na exclusao dos titulos
		if lRet

			// Envia arquivamento do cliente para Vindi
			lRet := U_UVIND20("F", UF2->UF2_CODIGO, UF2->UF2_CLIENT, UF2->UF2_LOJA,cOrigem,cOrigemDesc,.F.,@cCancMsg)

			if lRet
			
				// gravo os flags de cancelamento do contrato
				if RecLock("UF2",.F.)

					UF2->UF2_STATUS := "C"
					UF2->UF2_CODCAN	:= cCodCan
					UF2->UF2_DTCANC	:= dDataBase
					UF2->UF2_USRCAN := cUserName
					UF2->(MsUnLock())

					cCancMsg += "Contrato cancelado com sucesso!" + CRLF

					lRet := .T.

				Else

					DisarmTransaction()
					BREAK

				endif
			else
				
				DisarmTransaction()
				BREAK
			
			endif


		else

			DisarmTransaction()
			BREAK

		endif

	END TRANSACTION

	RestArea( aArea )

Return( lRet )

/*/{Protheus.doc} ExcluiTitulos
Realiza a exclusao do titulo
@author g.sampaio
@since 17/09/2019
@version 1.0
@return logical, retorna sobre a exclusao dos titulos
@type function
/*/

Static Function ExcluiTitulos(oSay,cContrato,cCancMsg)

	Local aArea 		:= GetArea()
	Local aAreaSE1		:= SE1->( GetArea() )
	Local aFin040		:= {}
	Local lMsErroAuto	:= .F.
	Local lRet			:= .T.

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .T.
	Private lAutoErrNoFile 	:= .T.

	Default cContrato 		:= ""
	Default cCancMsg		:= ""

	SE1->(DbOrderNickName("E1_XCTRFUN")) // E1_FILIAL + E1_XCTRFUN
	if SE1->(MsSeek(xFilial("SE1") + cContrato))

		//valido se o contrato esta em cobranca
		If !VldCobranca( SE1->E1_FILIAL, cContrato, @cCancMsg )

			lRet := .F.
			cCancMsg += "O Contrato "+cContrato+" possui titulos em cobrança, operação cancelada." + CRLF
			DisarmTransaction()
			BREAK

		else

			// percorro os registros do titulo do contrato
			While SE1->(!Eof()) .AND. SE1->E1_FILIAL == xFilial("SE1") .AND. SE1->E1_XCTRFUN == cContrato

				// zero as variaveis
				aFin040			:= {}
				lMsErroAuto 	:= .F.
				lMsHelpAuto 	:= .T.
				lAutoErrNoFile 	:= .T.

				// atualizo o caption
				oSay:cCaption := ("Excluindo parcela " + AllTrim(SE1->E1_PARCELA) + "...")
				ProcessMessages()

				// verifico se o valor e igual ao saldo
				If SE1->E1_VALOR == SE1->E1_SALDO // somente título que não teve baixa

					//excluo parcelas de comissao
					If ExcComiss( SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_XCTRFUN, @cCancMsg )

						// faco a exclusao do bordero
						ExcBord( SE1->( Recno() ) )

						//caso seja fatura, sera realizado a baixa por dacao e nao a exclusao do titulo
						if Alltrim(SE1->E1_FATURA) == 'NOTFAT'

							// funcao para baixar fatura
							lRet := BxFatura( SE1->(Recno()), @cCancMsg )

						else

							// atualizo as variaveis
							lMsErroAuto := .F.
							lMsHelpAuto := .T.

							// faço a exclusão do título a receber
							AAdd(aFin040, {"E1_FILIAL"  , SE1->E1_FILIAL  	, Nil})
							AAdd(aFin040, {"E1_PREFIXO" , SE1->E1_PREFIXO 	, Nil})
							AAdd(aFin040, {"E1_NUM"     , SE1->E1_NUM	   	, Nil})
							AAdd(aFin040, {"E1_PARCELA" , SE1->E1_PARCELA	, Nil})
							AAdd(aFin040, {"E1_TIPO"    , SE1->E1_TIPO  	, Nil})

							// rotina automatica de exclucao
							MSExecAuto({|x,y| Fina040(x,y)},aFin040,5)

							// verifico se aconteceu erro
							If lMsErroAuto

								If !Empty(AllTrim(cCancMsg))// para cancelamento por lote

									cCancMsg += MostraErro("/temp") + CRLF

								Else

									MostraErro()

								EndIf

								lRet := .F.
								DisarmTransaction()
								BREAK

								Exit

							EndIf

						endif

					EndIf

				Else

					cCancMsg += "Titulo com baixa total ou parcial!" + CRLF
					cCancMsg += "Titulo - Prefixo : " + SE1->E1_PREFIXO + " /  Numero : " + SE1->E1_NUM + " / Parcela : " + SE1->E1_PARCELA + " / Tipo : " + SE1->E1_TIPO + CRLF

				endif

				// vou para o proximo titulo da SE1
				SE1->(DbSkip())

			EndDo

		Endif

	endif

	RestArea(aAreaSE1)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} BxFatura
Baixa de Fatura
@author g.sampaio
@since 17/09/2019
@version 1.0
@return logical, retorna que deu a baixa na faturamento corretamente
@type function
/*/

Static Function BxFatura( nRecnoSE1, cCancMsg )

	Local aArea 		:= GetArea()
	Local aAreaSE1		:= SE1->(GetArea())
	Local aBaixa		:= {}
	Local lRet			:= .T.

	Private lMsErroAuto := .F.

	Default nRecnoSE1	:= 0
	Default cCancMsg	:= ""

	SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(DbGoTo(nRecnoSE1))

	While SE1->E1_SALDO > 0

		aBaixa := {;
			{"E1_PREFIXO"   ,SE1->E1_PREFIXO										,Nil},;
			{"E1_NUM"       ,SE1->E1_NUM											,Nil},;
			{"E1_PARCELA"   ,SE1->E1_PARCELA										,Nil},;
			{"E1_TIPO"      ,SE1->E1_TIPO											,Nil},;
			{"E1_CLIENTE" 	,SE1->E1_CLIENTE										,Nil},;
			{"E1_LOJA" 		,SE1->E1_LOJA											,Nil},;
			{"AUTMOTBX"     ,"DAC"													,Nil},;
			{"AUTDTBAIXA"   ,dDatabase												,Nil},;
			{"AUTDTCREDITO" ,dDatabase												,Nil},;
			{"AUTHIST"      ,"BAIXA POR CANCELAMENTO FUN"							,Nil},;
			{"AUTJUROS"     ,0      												,Nil,.T.},;
			{"AUTMULTA"     ,0      												,Nil,.T.},;
			{"AUTVALREC"    ,SE1->E1_SALDO	+ SE1->E1_SDACRES - SE1->E1_SDDECRE		,Nil}}

		MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3) //Baixa conta a receber

		If lMsErroAuto

			If !Empty(AllTrim(cCancMsg))// para cancelamento por lote

				cCancMsg += MostraErro("/temp") + CRLF

			Else

				MostraErro()

			EndIf

			lRet := .F.
			DisarmTransaction()

		EndIf

		// posiciono novamente no registro que esta sendo baixado
		SE1->(DbGoTo(nRecnoSE1))

	EndDo

	RestArea(aArea)
	RestArea(aAreaSE1)

Return(lRet)

/*/{Protheus.doc} ExcComiss
Exclusao da comissao
@author g.sampaio
@since 17/09/2019
@version 1.0
@return logical, retorna se a exclusao da comissaoaconteceu corretamente
@type function
/*/

Static Function ExcComiss(cCliente,cLoja,cPrefixo,cTitulo,cParcela,cTipo,cContrato,cCancMsg)

	Local aArea				:= GetArea()
	Local aAreaSE1 	    	:= SE1->( GetArea() )
	Local aAreaSE3 	    	:= SE3->( GetArea() )
	Local aAuto				:= {}
	Local cVendedor			:= RetField("UF2",1, xFilial("UF2") +  cContrato, "UF2_VEND")
	Local lUsaNovaComissao	:= SuperGetMv("ES_NEWCOMI",,.F.)	// ativo o uso da nova comissao
	Local lRet		 		:= .T.

	Private lMsErroAuto 	:= .F.

	Default cCliente		:= ""
	Default cLoja			:= ""
	Default cPrefixo		:= ""
	Default cTitulo			:= ""
	Default cParcela		:= ""
	Default cTipo			:= ""
	Default cContrato		:= ""
	Default cCancMsg		:= ""

	// verifico se o vendedor esta preenchido
	If !Empty( cVendedor ) .And. !lUsaNovaComissao

		SE3->( DbSetOrder( 3 ) ) //E3_FILIAL+E3_VEND+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO+E3_SEQ

		//encontro parcela da comissao de acordo com a parcela do titulo
		If SE3->( MsSeek( xFilial("SE3") + cVendedor + cCliente + cLoja + cPrefixo + cTitulo + cParcela + cTipo ) )

			//valido se a comissao foi paga
			If Empty(SE3->E3_DATA)

				aAuto := {}
				aAdd(aAuto, {"E3_VEND"		, SE3->E3_VEND		,Nil})
				aAdd(aAuto, {"E3_NUM" 		, SE3->E3_NUM		,Nil})
				aAdd(aAuto, {"E3_CODCLI"	, SE3->E3_CODCLI	,Nil})
				aAdd(aAuto, {"E3_LOJA"		, SE3->E3_LOJA		,Nil})
				aAdd(aAuto, {"E3_PREFIXO"	, SE3->E3_PREFIXO	,Nil})
				aAdd(aAuto, {"E3_PARCELA"	, SE3->E3_PARCELA	,Nil})
				aAdd(aAuto, {"E3_TIPO"		, SE3->E3_TIPO		,Nil})

				MSExecAuto({|x,y| Mata490(x,y)}, aAuto, 5) //Exclusão de Comissão

				// verifico se tem erro
				If lMsErroAuto

					If !Empty(AllTrim(cCancMsg))// para cancelamento por lote

						cCancMsg += MostraErro("/temp") + CRLF

					Else

						MostraErro()

					EndIf

					lRet := .F.

				EndIf
			Else
				MsgInfo("Comissão da Parcela: ( "+cParcela+" ) já encontra-se baixada, não será possivel estornar a comissão!","Atenção")
				lRet := .F.
			EndIf

		EndIf

	EndIf

	RestArea( aAreaSE1 )
	RestArea( aAreaSE3 )
	RestArea( aArea )

	lMsErroAuto := .F.

Return( lRet )

/*/{Protheus.doc} VldCobranca
Valida a cobranca
@author g.sampaio
@since 18/09/2019
@version 1.0
@return logical, retorno se tem cobranca na SK1
@type function
/*/

Static Function VldCobranca( cFiltTit, cContrato, cCancMsg)

	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local aAreaSE1	:= SE1->( GetArea() )
	Local aAreaSK1	:= SK1->( GetArea() )
	Local cQry 		:= ""

///////////////////////////////////////////////////////////////
///// CONSULTO SE O CONTRATO POSSUI TITULOS EM COBRANCA	//////
//////////////////////////////////////////////////////////////

	cQry 	:= " SELECT "
	cQry 	+= " K1_FILIAL FILIAL, "
	cQry 	+= " K1_PREFIXO PREFIXO, "
	cQry 	+= " K1_NUM NUMERO, "
	cQry 	+= " K1_PARCELA PARCELA, "
	cQry 	+= " K1_TIPO TIPO, "
	cQry 	+= " K1_FILORIG FILORIG "
	cQry	+= " FROM "
	cQry	+= + RetSQLName("SK1") + " COBRANCA
	cQry 	+= " INNER JOIN "
	cQry 	+= + RetSQLName("SE1") + " TITULO
	cQry 	+= " ON "
	cQry 	+= " COBRANCA.K1_PREFIXO = TITULO.E1_PREFIXO "
	cQry	+= " AND COBRANCA.K1_NUM 	= TITULO.E1_NUM "
	cQry	+= " AND COBRANCA.K1_PARCELA = TITULO.E1_PARCELA "
	cQry	+= " AND TITULO.E1_XCTRFUN 	= '" + cContrato + "' "
	cQry	+= " AND TITULO.E1_FILIAL 	= '" + cFiltTit + "' "
	cQry	+= " AND TITULO.D_E_L_E_T_ 	= ' ' "
	cQry	+= " WHERE "
	cQry	+= "	COBRANCA.D_E_L_E_T_ = ' '"
	cQry	+= " 	AND COBRANCA.K1_FILORIG = '" + cFiltTit + "' "
	cQry 	+= " 	AND COBRANCA.K1_OPERAD	<> 'XXXXXX' " //XXXXXX Titulo marcado como excecao na cobranca


	If Select("QRYCOB") > 0
		QRYCOB->(DbCloseArea())
	Endif

	cQry := ChangeQuery(cQry)
	TcQuery cQry NEW Alias "QRYCOB"

	QRYCOB->( DbGotop() )

	//valido se possui cobranca para o contrato
	if QRYCOB->(!Eof())

		// coloco a mensagem de log de contratos
		cCancMsg += "O Contrato "+ cContrato +" selecionado possui titulo(s) em cobrança. " + CRLF
		cCancMsg += "Os Titulos do contrato serão marcado como exceção no módulo de CallCenter." + CRLF

		SK1->(DbSetOrder(1)) //K1_FILIAL+K1_PREFIXO+K1_NUM+K1_PARCELA+K1_TIPO+K1_FILORIG

		While QRYCOB->(!Eof())

			//marco o titulo como excecao de cobranca, assim o mesmo estara apto para exclusao
			if SK1->(MsSeek(QRYCOB->FILIAL+QRYCOB->PREFIXO+QRYCOB->NUMERO+QRYCOB->PARCELA+QRYCOB->TIPO+QRYCOB->FILORIG))

				// gravo os registros
				If SK1->( RecLock("SK1",.F.) )

					SK1->K1_OPERAD := 'XXXXXX'
					SK1->(MsUnlock())

				Else

					DisarmTransaction()
					BREAK

				EndIf

			endif

			QRYCOB->(DbSkip())

		EndDo

	endif

	RestArea(aArea)
	RestArea(aAreaSE1)
	RestArea(aAreaSK1)

Return( lRet )

/*/{Protheus.doc} ExcBord
Funcao para Excluir Borderos 
existentes do contrato
@type function
@version 1.0
@author Raphael Martins
@since 23/08/2018
@param nRecSE1, numeric, recno do titulo
/*/
Static Function ExcBord(nRecSE1)

	Local aArea		:= GetArea()
	Local aAreaSE1	:= SE1->( GetArea() )
	Local aAreaSEA	:= SEA->( GetArea() )

	Default nRecSE1	:= 0

	SE1->(DbSetOrder(1))
	SE1->(DbGoTo(nRecSE1))

	SEA->(DbSetOrder(1)) //EA_FILIAL+EA_NUMBOR+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA

	//Se houver borderô associado, exclui
	If SEA->(DbSeek(xFilial("SEA")+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))

		if RecLock("SEA",.F.)
			SEA->(DbDelete())
			SEA->(MsUnlock())
		else
			SE1->(DisarmTransaction())
			BREAK
		endif

	Endif

	if RecLock("SE1",.F.)
		SE1->E1_SITUACA	:= "0"
		SE1->E1_OCORREN	:= ""
		SE1->E1_NUMBCO	:= ""
		SE1->E1_NUMBOR	:= ""
		SE1->E1_PORTADO := ""
		SE1->E1_CONTA   := ""
		SE1->E1_AGEDEP  := ""
		SE1->E1_DATABOR	:= Stod("")
		SE1->(MsUnLock())
	else
		SE1->(DisarmTransaction())
		BREAK
	endIf

	RestArea(aAreaSEA)
	RestArea(aAreaSE1)
	RestArea(aArea)

Return( Nil )
