#include "protheus.ch"
#include "topconn.ch"


/*/{Protheus.doc} RCPGE017
Rotina de Retirada de Cinzas
@author Raphael Martins
@since 30/07/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function RCPGE017()


	Local oAria10N 		:= TFont():New("@Arial Unicode MS",,016,,.F.,,,,,.F.,.F.)
	Local oArialV8 		:= TFont():New("@Arial Unicode MS",,016,,.F.,,,,,.F.,.F.)
	Local oDlg			:= NIL
	Local oGroup1		:= NIL
	Local oGroup2		:= NIL
	Local oGroup3		:= NIL
	Local oGroup4		:= NIL
	Local oSay1			:= NIL
	Local oSay2			:= NIL
	Local oSay3			:= NIL
	Local oSay4			:= NIL
	Local oSay5			:= NIL
	Local oSay6			:= NIL
	Local oSay7			:= NIL
	Local oSay8			:= NIL
	Local oData			:= NIL
	Local oHora			:= NIL
	Local oCodUsr		:= NIL
	Local oNomeUsr		:= NIL
	Local oCPF			:= NIL
	Local oRG			:= NIL
	Local oOrgao		:= NIL
	Local oNomeResg		:= NIL
	Local oGrid			:= NIL
	Local oConfirmar	:= NIL
	Local oFechar		:= NIL
	Local dData			:= dDataBase
	Local cHora			:= SubStr(Time(),1,5)
	Local cCodUsr		:= RetCodUsr()
	Local cNomeUsr		:= UsrFullName(cCodUsr)
	Local cCPF			:= Space(TamSX3("U41_CPF")[1])
	Local cRG			:= Space(TamSX3("U41_RG")[1])
	Local cOrgao		:= Space(TamSX3("U41_ORGAO")[1])
	Local cNomeResg		:= Space(TamSX3("U41_NOMERE")[1])

	Private __XVEZ 		:= "0"
	Private __ASC       := .T.
	Private _nMarca		:= 0

	DEFINE MSDIALOG oDlg TITLE "Retirada de Cinzas" FROM 000, 000  TO 425, 550 COLORS 0, 16777215 PIXEL

	//monto a grid de enderecos
	oGrid := MsGridCTR(oDlg)

	// duplo clique no grid
	bSvblDblClick := oGrid:oBrowse:bLDblClick
	oGrid:oBrowse:bLDblClick := {|| if(oGrid:oBrowse:nColPos <> 1,GdRstDblClick(@oGrid,@bSvblDblClick),DuoClique(oGrid))}

	// clique no cabecalho da grid
	oGrid:oBrowse:bHeaderClick := {|oBrw1,nCol| MarcaTodos(oGrid),oBrw1:SetFocus() }

	@ 003, 002 GROUP oGroup1 TO 048, 274 PROMPT "Dados da Retirada" OF oDlg COLOR 0, 16777215 PIXEL

	@ 016, 005 SAY oSay1 PROMPT "Data:" SIZE 049, 007 OF oDlg FONT oAria10N COLORS 0, 16777215 PIXEL
	@ 015, 036 MSGET oData VAR dData SIZE 046, 007 When .F. OF oDlg COLORS 0, 16777215 PIXEL

	@ 016, 094 SAY oSay2 PROMPT "Hora:" SIZE 025, 007 OF oDlg FONT oAria10N COLORS 0, 16777215 PIXEL
	@ 015, 122 MSGET oHora VAR cHora SIZE 033, 007 When .F. Picture "@R 99:99" OF oDlg COLORS 0, 16777215 PIXEL

	@ 034, 005 SAY oSay3 PROMPT "Usuário:" SIZE 028, 007 OF oDlg FONT oAria10N COLORS 0, 16777215 PIXEL
	@ 032, 036 MSGET oCodUsr VAR cCodUsr SIZE 046, 007 When .F. OF oDlg COLORS 0, 16777215 PIXEL

	@ 034, 094 SAY oSay8 PROMPT "Nome:" SIZE 025, 007 OF oDlg FONT oAria10N COLORS 0, 16777215 PIXEL
	@ 032, 122 MSGET oNomeUsr VAR cNomeUsr SIZE 144, 007 When .F. OF oDlg COLORS 0, 16777215 PIXEL

	@ 051, 003 GROUP oGroup2 TO 099, 274 PROMPT "Dados do Resgatador:" OF oDlg COLOR 0, 16777215 PIXEL

	@ 064, 005 SAY oSay4 PROMPT "*CPF:" SIZE 025, 007 OF oDlg  FONT oArialV8 COLORS 8421504, 16777215 PIXEL
	@ 064, 029 MSGET oCPF VAR cCPF SIZE 067, 007 OF oDlg Valid(If(!Empty(cCPF),CGC(cCPF,,.T.),.T.)) Picture '@R 999.999.999-99' COLORS 0, 16777215 PIXEL

	@ 064, 100 SAY oSay5 PROMPT "RG:" SIZE 025, 007 OF oDlg FONT oAria10N COLORS 0, 16777215 PIXEL
	@ 064, 117 MSGET oRG VAR cRG SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 064, 190 SAY oSay6 PROMPT "Orgão:" SIZE 025, 009 OF oDlg FONT oAria10N COLORS 0, 16777215 PIXEL
	@ 064, 214 MSGET oOrgao VAR cOrgao SIZE 052, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 082, 006 SAY oSay7 PROMPT "*Nome:" SIZE 025, 012 OF oDlg FONT oArialV8 COLORS 8421504, 16777215 PIXEL
	@ 081, 029 MSGET oNomeResg VAR cNomeResg SIZE 149, 007 OF oDlg COLORS 0, 16777215 PIXEL

	@ 100, 002 GROUP oGroup3 TO 189, 274 PROMPT " Cremações: " OF oDlg COLOR 0, 16777215 PIXEL

	// caso não tenha encontrato enderecos
	if !RefreshGrid(oGrid,U00->U00_CODIGO)

		Alert("Não foram encontrados servicos para o contrato!")
		oDlg:End()

	endif

	@ 190, 002 GROUP oGroup4 TO 210, 274 OF oDlg COLOR 0, 16777215 PIXEL
	@ 194, 191 BUTTON oConfirmar PROMPT "Confirmar" SIZE 037, 012 Action(FWMsgRun(,{|oSay| ConfRetCinza(U00->U00_CODIGO,oGrid,oDlg,cCPF,cRG,cOrgao,cNomeResg) },'Aguarde...','Realizando Retirada de Cinza!')) OF oDlg PIXEL
	@ 194, 233 BUTTON oFechar PROMPT "Fechar" SIZE 037, 012 Action(oDlg:End()) OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} MsGridCTR
//TODO Função que cria o grid de enderecos
@author Raphael Martins
@since 30/07/2018
@version 1.0
@param 	oTela	 	- Dialog da Tela de consulta
@return oGrid		- MsNewGetdados criada dos enderecos consultados
@type function
/*/

Static Function MsGridCTR(oTela)

	Local oGrid			:= NIL
	Local nX			:= 1
	Local aHeaderEx 	:= {}
	Local aColsEx 		:= {}
	Local aFieldFill 	:= {}
	Local aFields 		:= {"MARK","ITEM","CREMATORIO","COLUMBARIO","DATA_INCLUSAO","DATA_UTILIZACAO","QUEM_UTIL","INVOLUCRO"}
	Local aAlterFields 	:= {"INVOLUCRO"}

	For nX := 1 To Len(aFields)

		if aFields[nX] == "MARK"
			Aadd(aHeaderEx, {"","MARK","@BMP",2,0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "ITEM"
			Aadd(aHeaderEx, {"Item","ITEM","@E 999",3,0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "CREMATORIO"
			Aadd(aHeaderEx, {"Crematorio","CREMATORIO",PesqPict("U39","U39_CREMAT"),TamSX3("U39_CREMAT")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "COLUMBARIO"
			Aadd(aHeaderEx, {"Nicho Columb","COLUMBARIO",PesqPict("U39","U39_NICHOC"),TamSX3("U39_NICHOC")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "DATA_INCLUSAO"
			Aadd(aHeaderEx, {"Dt. Inclusao.","DATA_INCLUSAO",PesqPict("U39","U39_DATA"),TamSX3("U39_DATA")[1],0,"","€€€€€€€€€€€€€€","D","","","",""})

		elseif aFields[nX] == "DATA_UTILIZACAO"
			Aadd(aHeaderEx, {"Dt. Utiliz.","DATA_UTILIZACAO",PesqPict("U39","U39_DTUTIL"),TamSX3("U39_DTUTIL")[1],0,"","€€€€€€€€€€€€€€","D","","","",""})

		elseif aFields[nX] == "QUEM_UTIL"
			Aadd(aHeaderEx, {"Quem usou","NOME",PesqPict("U39","U39_QUEMUT"),TamSX3("U39_QUEMUT")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "INVOLUCRO"
			Aadd(aHeaderEx, {"Num Involucro","INVOLUCRO","@!",TamSX3("U41_NORINV")[1],0,"","€€€€€€€€€€€€€€","C","","R","",""})

		endif


	Next nX


// Define field values
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

	oGrid :=  MsNewGetDados():New(110,005,183, 270,GD_UPDATE,"AllwaysTrue","AllwaysTrue",,aAlterFields,,999,;
		"AllwaysTrue","","AllwaysTrue",oTela, aHeaderEx, aColsEx)


Return(oGrid)
/*{Protheus.doc} RefreshGrid
//TODO Função chamada para preencher a grid de enderecos
@author Raphael Martins
@since 30/07/2018
@version 1.0
@param oGrid 			- Objeto da Grid de Contratos 
@param cContrato	 	- Codigo do Contrato em que sera consultado os seus servicos
@return lRet			- Encontrado contratos para reajustar
@type function
/*/
Static Function RefreshGrid(oGrid,cContrato)

Local aArea			:= GetArea()
Local aAreaU00		:= U00->(GetArea())
Local aAreaU04		:= U04->(GetArea())
Local cQry			:= ""
Local lRet			:= .F.
	
// verifico se não existe este alias criado
	If Select("QRY") > 0
	QRY->(DbCloseArea())
	EndIf

cQry += " SELECT "
cQry += " U04_ITEM 	 ITEM, "
cQry += " U04_CREMAT CREMATORIO, "
cQry += " U04_NICHOC NICHO_COLUMBARIO, "
cQry += " U04_DATA   DATA_INCLUSAO, " 
cQry += " U04_DTUTIL DATA_UTILIZACAO, "
cQry += " U04_QUEMUT QUEM_UTILIZOU "
cQry += " FROM "
cQry += + RetSQLName("U04") + " ENDERECO "
cQry += " WHERE "
cQry += " ENDERECO.D_E_L_E_T_ = ' ' "
cQry += " AND ENDERECO.U04_FILIAL = '" + xFilial("U04") + "' "
cQry += " AND ENDERECO.U04_CODIGO = '" + cContrato + "' "
cQry += " AND ENDERECO.U04_PREVIO <> 'S' "
cQry += " AND ENDERECO.U04_QUEMUT <> ' ' "
cQry += " AND ENDERECO.U04_CREMAT <> ' ' "
cQry += " ORDER BY ITEM "

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

oGrid:Acols := {}
aFieldFill 	:= {}

// se existir enderecamento para o contrato
	if QRY->(!Eof())
	
	lRet 		:= .T. 

		While QRY->(!Eof())
	
		
		aFieldFill := {}
		
		aadd(aFieldFill, "UNCHECKED")	
		aadd(aFieldFill, QRY->ITEM)
		aadd(aFieldFill, QRY->CREMATORIO)
		aadd(aFieldFill, QRY->NICHO_COLUMBARIO)
		aadd(aFieldFill, STOD(QRY->DATA_INCLUSAO))
		aadd(aFieldFill, STOD(QRY->DATA_UTILIZACAO))
		aadd(aFieldFill, Alltrim(QRY->QUEM_UTILIZOU))
		aadd(aFieldFill, Space(TamSx3("U00_NROINV")[1]))
		Aadd(aFieldFill, .F.)
		aadd(oGrid:Acols,aFieldFill) 
		
		QRY->(DbSkip())
		
		EndDo
	
	else
	
	aadd(aFieldFill, "UNCHECKED")
	aadd(aFieldFill, "")
	aadd(aFieldFill, "")
	aadd(aFieldFill, "")
	aadd(aFieldFill, CTOD(""))
	aadd(aFieldFill, CTOD(""))
	aadd(aFieldFill, "")
	aadd(aFieldFill, "")
	Aadd(aFieldFill, .F.)
	
	aadd(oGrid:Acols,aFieldFill) 
	
	endif

oGrid:oBrowse:Refresh()

RestArea(aArea)
RestArea(aAreaU00)
RestArea(aAreaU04)

Return(lRet)

/*/{Protheus.doc} DuoClique
//TODO Função chamada no duplo clique no grid
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param _obj	 			- Objeto da Grid de Contratos 
@return Sem Retorno
@type function
/*/

Static Function DuoClique(oObj)

	Local nPosMark	:= aScan(oObj:aHeader,{|x| AllTrim(x[2])== "MARK"})

	if oObj:aCols[oObj:nAt][nPosMark] == "CHECKED"

		oObj:aCols[oObj:nAt][nPosMark] 	:= "UNCHECKED"

	else

		oObj:aCols[oObj:nAt][nPosMark] 	:= "CHECKED"

	endif

	oObj:oBrowse:Refresh()

Return()

/*/{Protheus.doc} MarcaTodos
//TODO Função chamada pela ação de clicar no cabeçalho dos grids
para selecionar todos os checkbox
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param _obj	 			- Objeto da Grid de Enderecos 
@return Sem Retorno
@type function
/*/

Static Function MarcaTodos(_obj)

	Local nX		:= 1


	if __XVEZ == "0"
		__XVEZ := "1"
	else
		if __XVEZ == "1"
			__XVEZ := "2"
		endif
	endif

	If __XVEZ == "2"

		nGetTotal := 0
		nQtTotal  := 0

		If _nMarca == 0

			For nX := 1 TO Len(_obj:aCols)
				_obj:aCols[nX][1] := "CHECKED"
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

	Endif

Return()

/*/{Protheus.doc} ConfRetCinza
//TODO Funcao para confirmar a retirada de cinza
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param _obj	 			- Objeto da Grid de Enderecos 
@return Sem Retorno
@type function
/*/

Static Function ConfRetCinza(cContrato,oGrid,oDlg,cCPF,cRG,cOrgao,cNomeResg)

	Local lRet			:= .T.
	Local lContinua		:= .T.
	Local nPosMark		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])== "MARK"})
	Local nPosItem		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])== "ITEM"})
	Local nPosInVol		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])== "INVOLUCRO"})
	Local nMark			:= aScan(oGrid:aCols,{|x| AllTrim(x[1])== "CHECKED"})
	Local nX			:= 0
	Local cCodUsr		:= RetCodUsr()
	Local cNameFull		:= UsrFullName(cCodUsr)

	//verifico se algum item foi marcado
	if nMark > 0

		if !Empty(cCPF) .And. !Empty(cNomeResg)

			For nX := 1 To Len(oGrid:aCols)

				//verifico se o item esta marcado
				if oGrid:aCols[nX,nPosMark] == "CHECKED"

					cItem	:= oGrid:aCols[nX,nPosItem]
					U04->(DbSetOrder(1)) //U04_FILIAL+U04_CODIGO+U04_ITEM

					If U04->(DbSeek(xFilial("U04")+cContrato+cItem))

						// funcao para remover a taxa de loacao do cliente
						lContinua := U_RCPGE040( cContrato, U04->U04_CREMAT, U04->U04_NICHOC )

						// verifico se continuo com a retirra de cinzas
						if lContinua

							//gravo o historico do enderecamento
							cItemHist := RetLstHist(cContrato)

							RecLock("U30",.T.)

							U30->U30_FILIAL 	:= U04->U04_FILIAL
							U30->U30_CODIGO 	:= U04->U04_CODIGO
							U30->U30_ITEM		:= cItemHist
							U30->U30_CREMAT		:= U04->U04_CREMAT
							U30->U30_NICHOC		:= U04->U04_NICHOC
							U30->U30_DTUTIL 	:= U04->U04_DTUTIL
							U30->U30_QUEMUT 	:= U04->U04_QUEMUT
							U30->U30_TRANSF		:= "N" //transferencia
							U30->U30_DTHIST 	:= dDataBase
							U30->U30_RECU04		:= U04->(Recno())
							U30->U30_QUADRA 	:= ""
							U30->U30_MODULO 	:= ""
							U30->U30_JAZIGO 	:= ""
							U30->U30_GAVETA 	:= ""
							U30->U30_OSSARI 	:= ""
							U30->U30_NICHOO		:= ""
							U30->U30_TRANSF		:= "S" //transferencia
							U30->U30_APONTA		:= U04->U04_APONTA

							if U30->(FieldPos("U30_ORIGEM")) > 0
								U30->U30_ORIGEM	:= "RCPGE017"
							endIf

							U30->(MsUnlock())

							//Gravo no historico de retirada de cinzas
							cItemRetC	:= RetLstRetC(cContrato)

							RecLock("U41",.T.)

							U41->U41_FILIAL := xFilial("U41")
							U41->U41_CODIGO := cContrato
							U41->U41_ITEM   := cItemRetC
							U41->U41_DTRETI := dDataBase
							U41->U41_HORARE := Time()
							U41->U41_NORINV := oGrid:aCols[nX,nPosInVol]
							U41->U41_USER   := cCodUsr
							U41->U41_USRNOM	:= cNameFull
							U41->U41_CPF    := cCPF
							U41->U41_RG  	:= cRG
							U41->U41_NOMERE	:= cNomeResg
							U41->U41_ORGAO 	:= cOrgao
							U41->U41_RECU30 := U30->(Recno())

							U41->(MsUnlock())

							//deleto o enderecamento realizado
							RecLock("U04",.F.)
							U04->(DbDelete())
							U04->(MsUnlock())

						else

							lRet := .F.
							Help(,,'Help',,"Não foi possível excluir a locação de nicho, não será feita a retirada de cinzas!",1,0)

						endIf

					endif

				endif

			Next nX
		else

			lRet := .F.
			Help(,,'Help',,"Preenchimento do CPF e Nome do Resgatador são obrigatórios!",1,0)

		endif

	else


		lRet := .F.
		Help(,,'Help',,"Selecione ao menos uma cremação para realizar a retirada das cinzas",1,0)

	endif

	if lRet

		MsgInfo("Retirada de Cinzas Realizada com Sucesso!")
		oDlg:End()

	endif

Return(lRet)


/*/{Protheus.doc} RetLstHist
//Funcao que retorno o proximo item
U30 - Historico de Enderecamento
@author Raphael Martins
@since 07/08/2018
@version 1.0
@param _obj	 			- Objeto da Grid de Enderecos 
@return Sem Retorno
@type function
/*/
Static Function RetLstHist(cContrato)

	Local aArea		:= GetArea()
	Local aAreaU04	:= U04->(GetArea())
	Local cQry		:= ""
	Local cProxItem	:= ""

	cQry := " SELECT
	cQry += " ISNULL(MAX(U30_ITEM),'00') MAX_ITEM "
	cQry += " FROM "
	cQry += + RetSQLName("U30") + " HIST "
	cQry += " WHERE "
	cQry += " HIST.D_E_L_E_T_ = ' ' "
	cQry += " AND U30_FILIAL = '"+xFilial("U30")+"' "
	cQry += " AND U30_CODIGO = '"+cContrato+"' "

	// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)

	// crio o alias temporario
	TcQuery cQry New Alias "QRY"

	//proximo item da tabela de historico de enderecamento
	cProxItem := StrZero(Val(QRY->MAX_ITEM) + 1,2)

	RestArea(aArea)
	RestArea(aAreaU04)


Return(cProxItem)

/*/{Protheus.doc} ConfRetCinza
//Funcao que retorno o proximo item
U30 - Historico de Enderecamento
@author Raphael Martins
@since 07/08/2018
@version 1.0
@param _obj	 			- Objeto da Grid de Enderecos 
@return Sem Retorno
@type function
/*/
Static Function RetLstRetC(cContrato)

	Local aArea		:= GetArea()
	Local aAreaU04	:= U04->(GetArea())
	Local cQry		:= ""
	Local cProxItem	:= ""

	cQry := " SELECT
	cQry += " ISNULL(MAX(U41_ITEM),'00') MAX_ITEM "
	cQry += " FROM "
	cQry += + RetSQLName("U41") + " HIST "
	cQry += " WHERE "
	cQry += " HIST.D_E_L_E_T_ = ' ' "
	cQry += " AND U41_FILIAL = '"+xFilial("U41")+"' "
	cQry += " AND U41_CODIGO = '"+cContrato+"' "

	// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)

	// crio o alias temporario
	TcQuery cQry New Alias "QRY"

	//proximo item da tabela de historico de enderecamento
	cProxItem := StrZero(Val(QRY->MAX_ITEM) + 1,2)

	RestArea(aArea)
	RestArea(aAreaU04)


Return(cProxItem)
