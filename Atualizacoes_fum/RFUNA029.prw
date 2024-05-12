#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} RFUNA029
//TODO Geração da taxa de manutenção de contratos - Funeraria
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function RFUNA029()

Local aArea			:= GetArea()
Local aAreaUF2		:= UF2->(GetArea())
Local cPerg 		:= "RFUNA029"
Local cContratoDe	:= ""
Local cContratoAte	:= ""
Local cPlano		:= ""
Local cIndice		:= ""
Local lContinua		:= .T.
Local nIndice		:= 0

Private __XVEZ 		:= "0"
Private __ASC       := .T.
Private _nMarca		:= 0


// cria as perguntas na SX1
AjustaSx1(cPerg)

// enquanto o usuário não cancelar a tela de perguntas
While lContinua
	
	// chama a tela de perguntas
	lContinua := Pergunte(cPerg,.T.)
	
	if lContinua 
	
		cContratoDe 	:= MV_PAR01
		cContratoAte	:= MV_PAR02 
		cPlano			:= MV_PAR03
		cIndice			:= MV_PAR04  
		
		if ValidParam(cContratoDse,cContratoAte,cPlano,cIndice,@nIndice) 
					
			FWMsgRun(,{|oSay| ConsultaCTR(cContratoDe,cContratoAte,cPlano,cIndice,nIndice) },'Aguarde...','Consultando Contratos para Geração das Taxas...')
			
		endif
		
	endif
	
EndDo

RestArea(aAreaUF2)
RestArea(aArea)

Return()

/*/{Protheus.doc} ValidParam
//TODO Função que valida os parâmetros informados
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function ValidParam(cContratoDe,cContratoAte,cPlano,cIndice,nIndice) 

Local lRet := .F.

// verifico se foram preenchidos todos os parâmetros
if Empty(cContratoDe) .AND. Empty(cContratoAte) 
	Alert("Informe o intervalo dos contratos!")
elseif Empty(cPlano)
	Alert("Informe o plano!")
elseif Empty(cIndice)
	Alert("Informe o índice!")
else
	
	// chamo função pra encontrar o índice INCC que será aplicado
	nIndice := BuscaIndice(cIndice)
		
	// é obrigatório existir um índice para ser aplicado
	if nIndice > 0
		lRet := .T.
	else
		Alert("Não foi encontrado índice para os últimos 12 meses!")
	endif
	
endif

Return(lRet) 

/*/{Protheus.doc} ValidParam
//TODO Função que consulta os contratos que irão gerar taxa de manutenção
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function ConsultaCTR(cContratoDe,cContratoAte,cPlano,cIndice,nIndice)

Local oPn1			:= NIL
Local oPn2			:= NIL
Local oPn3			:= NIL
Local oTotal		:= NIL
Local oQtdMark		:= NIL
Local oGetTotal		:= NIL
Local oQtTotal		:= NIL
Local oGrid			:= NIL
Local aButtons		:= {}
Local aObjects 		:= {}
Local aSizeAut		:= MsAdvSize()
Local aInfo			:= {}
Local aPosObj		:= {}
Local nGetTotal		:= 0
Local nQtTotal		:= 0


Static oDlg

Private cCadastro := "Geração de Taxa de Manutenção"

//Largura, Altura, Modifica largura, Modifica altura
aAdd( aObjects, { 100,	100, .T., .T. } ) //Browse

aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE "Contratos para geração da taxa de manutenção" From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] COLORS 0, 16777215 PIXEL

aAdd(aButtons, {"", {|| GdSeek(oGrid,"Pesquisa"/*,aCposFind*/) }, "Pesquisa" })  

//defino os panels da tela
@ 001,000 MSPANEL oPn1 SIZE 150, 050 OF oDlg
@ 001,000 MSPANEL oPn2 SIZE 150, 050 OF oPn1
@ 001,000 MSPANEL oPn3 SIZE 150, 050 OF oPn1

oPn1:Align  := CONTROL_ALIGN_ALLCLIENT
oPn2:Align  := CONTROL_ALIGN_TOP
oPn3:Align  := CONTROL_ALIGN_BOTTOM

oPn2:nHeight := (oMainWnd:nClientHeight / 2) + 150
oPn3:nHeight := (oMainWnd:nClientHeight - oPn2:nHeight ) - 100


EnchoiceBar(oDlg, {|| FWMsgRun(,{|oSay| ConfirmaManut(oSay,oGrid,cIndice) },'Aguarde...','Confirmando Taxas de Manutenções selecionadas...')},{|| oDlg:End()},,aButtons)

//objetos totalizadores
@ 00, 05 SAY oTotal PROMPT "R$ Total Selecionado:" SIZE 100, 007 OF oPn3 Font oFont COLOR CLR_RED PIXEL
@ 00, 090 MSGET oGetTotal VAR nGetTotal SIZE 100, 007 When .F. OF oPn3 HASBUTTON PIXEL COLOR CLR_BLACK Picture "@E 999,999,999.99"

@ 00, 210 SAY oTotal PROMPT "Quantidade Selecionada:" SIZE 100, 007 OF oPn3 COLORS CLR_RED Font oFont COLOR CLR_BLACK PIXEL
@ 00, 300 MSGET oQtTotal VAR nQtTotal SIZE 100, 007 When .F. OF oPn3 HASBUTTON PIXEL COLOR CLR_BLACK Picture "@E 999999999"	


// crio o grid de bicos
oGrid := MsGridCTR(oPn2)

// duplo clique no grid
oGrid:oBrowse:bLDblClick := {|| DuoClique(oGrid,oGetTotal,@nGetTotal,oQtTotal,@nQtTotal)}

// clique no cabecalho da grid
oGrid:oBrowse:bHeaderClick := {|oBrw1,nCol| if(oGrid:oBrowse:nColPos <> 111 .And. nCol == 1,(MarcaTodos(oGrid,oGetTotal,@nGetTotal,oQtTotal,@nQtTotal),;
							  oBrw1:SetFocus()),(U_OrdGrid(oGrid,nCol) , nColOrder := nCol ))}


// objeto ocupa todo panel
oGrid:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

// atualizo o objeto
oGrid:oBrowse:Refresh()


// caso não tenha encontrato títulos
if !RefreshGrid(oGrid,cContratoDe,cContratoAte,cPlano,cIndice,nIndice,oGetTotal,@nGetTotal,oQtTotal,@nQtTotal)
	
	Alert("Não foram encontrados contratos para geração da taxa de manutenção!")
	oDlg:End()
	
endif

ACTIVATE MSDIALOG oDlg CENTERED

Return() 

/*/{Protheus.doc} MsGridCTR
//TODO Função que cria o grid de contratos
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function MsGridCTR(oPainel)

Local oGrid			:= NIL
Local nX			:= 1
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {"MARK","CONTRATO","DATA","CLIENTE","LOJA","DIA_VENCIMENTO","TXATU","INDICE","VLREAJ","TXREAJ"}
Local aAlterFields 	:= {}

For nX := 1 To Len(aFields)
	
	if aFields[nX] == "MARK" 
		Aadd(aHeaderEx, {"","MARK","@BMP",2,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "CONTRATO"
		Aadd(aHeaderEx, {"Contrato","CONTRATO","@!",6,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "DATA"
		Aadd(aHeaderEx, {"Manutenção","DATA","",8,0,"","€€€€€€€€€€€€€€","D","","","",""})
	elseif aFields[nX] == "CLIENTE"
		Aadd(aHeaderEx, {"Cliente","CLIENTE","@!",TamSX3("UF2_CLIENT")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "LOJA"
		Aadd(aHeaderEx, {"Loja","LOJA","@!",TamSX3("UF2_LOJA")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "DIA_VENCIMENTO"
		Aadd(aHeaderEx, {"Dia Venc.","DIA_VENCIMENTO","@!",2,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "TXATU"
		Aadd(aHeaderEx, {"Taxa atual","TXATU",PesqPict("UF2","UF2_TXMNT"),TamSX3("UF2_TXMNT")[1],TamSX3("UF2_TXMNT")[2],"","€€€€€€€€€€€€€€","N","","","",""})
	elseif aFields[nX] == "INDICE"
		Aadd(aHeaderEx, {"Índice","INDICE",PesqPict("U29","U29_INDICE"),TamSX3("U29_INDICE")[1],TamSX3("U29_INDICE")[2],"","€€€€€€€€€€€€€€","N","","","",""})
	elseif aFields[nX] == "VLREAJ"
		Aadd(aHeaderEx, {"Valor Reajuste","VLREAJ",PesqPict("UF2","UF2_TXMNT"),TamSX3("UF2_TXMNT")[1],TamSX3("UF2_TXMNT")[2],"","€€€€€€€€€€€€€€","N","","","",""})		
	elseif aFields[nX] == "TXREAJ"
		Aadd(aHeaderEx, {"Taxa reajustada","TXREAJ",PesqPict("UF2","UF2_TXMNT"),TamSX3("UF2_TXMNT")[1],TamSX3("UF2_TXMNT")[2],"","€€€€€€€€€€€€€€","N","","","",""})
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

oGrid := MsNewGetDados():New( 05,05,000, 000, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,;
		 , 999, "AllwaysTrue", "", "AllwaysTrue",oPainel, aHeaderEx, aColsEx)                          


Return(oGrid)

/*/{Protheus.doc} RefreshGrid
//TODO Função atualiza o grid de contratos
@author Raphael Martins
@since 29/03/2018
@version 1.0
@type function
@return logical, retorno lógico para determinar
@history 18/05/2020, g.sampaio, Issue VPDV-17 - Alteração para o uso da tabela UJ0 no lugar da tabela UG0
/*/

Static Function RefreshGrid(oGrid,cContratoDe,cContratoAte,cPlano,cIndice,nIndice,oGetTotal,nGetTotal,oQtTotal,nQtTotal)

Local aArea			:= GetArea()
Local lRet			:= .F.
Local cQry 			:= ""
Local aFieldFill	:= {}
Local nValReaj		:= 0
Local nTaxaReaj		:= 0 
Local cPulaLinha	:= chr(13)+chr(10)  
Local nIndAplic		:= 0 
Local lUsaPrimVencto:= SuperGetMv("MV_XPRIMVC",.F.,.F.)
Local nMesesMan		:= cValToChar(SuperGetMv("MV_XINTTXA",.F.,6)) 

// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf      

cQry := " SELECT " 																												+ cPulaLinha
cQry += " UF2.UF2_CODIGO AS CONTRATO, "																							+ cPulaLinha
cQry += " UF2.UF2_CLIENT AS CLIENTE, "																							+ cPulaLinha
cQry += " UF2.UF2_LOJA AS LOJA, "																								+ cPulaLinha
If lUsaPrimVencto
	cQry += " ( CASE WHEN UF2.UF2_PRIMVE <> ' ' THEN SUBSTRING(UF2_PRIMVE,7,2) ELSE UF2.UF2_DIAVEN END ) AS DIA_VENCIMENTO, "	+ cPulaLinha
Else
	cQry += " UF2.UF2_DIAVEN AS DIA_VENCIMENTO, "																				+ cPulaLinha
Endif
cQry += " MANUTENCAO.DATA_MANUTENCAO AS DATA_MANUTENCAO, "																		+ cPulaLinha
cQry += " (UF2.UF2_TXMNT + UF2.UF2_ADIMNT) AS TAXA " 																			+ cPulaLinha
cQry += " FROM " 																												+ cPulaLinha
cQry += + RetSqlName("UF2") + " UF2 " 																							+ cPulaLinha

cQry += " INNER JOIN " 																											+ cPulaLinha
cQry += " ( " 																													+ cPulaLinha
cQry += " 	SELECT " 																											+ cPulaLinha
cQry += " 	UF2.UF2_CODIGO AS CODIGO_CONTRATO, " 																				+ cPulaLinha
cQry += " 	ISNULL(ULTIMA_MANUTENCAO.DATA_PROXIMA_MANUTENCAO,SEPULTAMENTO.DATA_UTILIZACAO) AS DATA_MANUTENCAO " 				+ cPulaLinha
cQry += " 	FROM " 																												+ cPulaLinha
cQry += + 	RetSqlName("UF2") + " UF2 " 																						+ cPulaLinha

////////////////////////////////////////////////////////////////
/////// CONSULTO O PRIMEIRO SERVICO COM OBITO EXECUTADO ///////
///////////////////////////////////////////////////////////////

cQry += " 	INNER JOIN " 																										+ cPulaLinha
cQry += "   	( " 																											+ cPulaLinha
cQry += "        	SELECT " 																									+ cPulaLinha
cQry += "         	UJ0.UJ0_CONTRA AS CODIGO_CONTRATO, "  																		+ cPulaLinha
cQry += "       	MIN(LEFT(CONVERT(varchar, DateAdd(Month,5,CAST(UJ0.UJ0_DTCADA AS DATETIME)) ,112),"+ nMesesMan +")) AS DATA_UTILIZACAO "  + cPulaLinha
cQry += "         	FROM " 																										+ cPulaLinha
cQry += +		  	RetSqlName("UJ0") + " UJ0 " 																				+ cPulaLinha
cQry += "         	WHERE " 																									+ cPulaLinha 
cQry += "         	UJ0.D_E_L_E_T_ <> '*' " 																					+ cPulaLinha
cQry += " 		  	AND UJ0.UJ0_FILIAL = '" + xFilial("UJ0") + "' " 															+ cPulaLinha
cQry += "         	AND UJ0.UJ0_DTCADA <> ' ' "																					+ cPulaLinha
cQry += "         	AND UJ0.UJ0_DTFALE <> ' ' "																					+ cPulaLinha
cQry += "         	GROUP BY UJ0.UJ0_CONTRA " 																					+ cPulaLinha 
cQry += "     	) AS SEPULTAMENTO " 																							+ cPulaLinha
cQry += "   ON SEPULTAMENTO.CODIGO_CONTRATO = UF2.UF2_CODIGO " 																	+ cPulaLinha


///////////////////////////////////////////////////////////////////////////
/////// CONSULTO A ULTIMA TAXA DE MANUTENCAO GERADA PARA O CONTRATO ///////
//////////////////////////////////////////////////////////////////////////

cQry += " LEFT JOIN " 																											+ cPulaLinha
cQry += " 		( " 																											+ cPulaLinha 
cQry += "         	SELECT " 																									+ cPulaLinha
cQry += "         	UH0.UH0_CONTRA AS CODIGO_CONTRATO, " 																		+ cPulaLinha
cQry += "         	MAX(SUBSTRING(UH0_PROMAN,3,4) + SUBSTRING(UH0_PROMAN,1,2)) AS DATA_PROXIMA_MANUTENCAO " 					+ cPulaLinha
cQry += "         	FROM " 																										+ cPulaLinha 
cQry += +		  	RetSqlName("UH0") + " UH0 " 																				+ cPulaLinha
cQry += "         	WHERE " 																									+ cPulaLinha
cQry += "         	UH0.D_E_L_E_T_ <> '*' " 																					+ cPulaLinha
cQry += " 		  	AND UH0.UH0_FILIAL = '" + xFilial("UH0") + "' " 															+ cPulaLinha
cQry += "         	GROUP BY UH0.UH0_CONTRA " 																					+ cPulaLinha
cQry += "     	) AS ULTIMA_MANUTENCAO " 																						+ cPulaLinha
cQry += "     ON ULTIMA_MANUTENCAO.CODIGO_CONTRATO = UF2.UF2_CODIGO " 															+ cPulaLinha

cQry += " 	WHERE " 																											+ cPulaLinha
cQry += " 	UF2.D_E_L_E_T_ <> '*' " 																							+ cPulaLinha
cQry += " 	AND UF2.UF2_FILIAL = '" + xFilial("UF2") + "' " 																	+ cPulaLinha
cQry += " 	AND UF2.UF2_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' " 										+ cPulaLinha

if !Empty(cPlano)
	cQry += " 	AND UF2.UF2_PLANO IN " + FormatIn( AllTrim(cPlano),";") 		 												+ cPulaLinha		
endif

cQry += " ) AS MANUTENCAO " 																									+ cPulaLinha

cQry += " ON MANUTENCAO.CODIGO_CONTRATO = UF2.UF2_CODIGO " 																		+ cPulaLinha
cQry += " AND MANUTENCAO.DATA_MANUTENCAO <= '" + AnoMes(dDataBase) + "' "														+ cPulaLinha
cQry += " WHERE " 																												+ cPulaLinha
cQry += " UF2.D_E_L_E_T_ <> '*' " 																								+ cPulaLinha
cQry += " AND UF2.UF2_FILIAL = '" + xFilial("UF2") + "' " 																		+ cPulaLinha
cQry += " AND UF2.UF2_INDICE = '" + cIndice + "' "												 								+ cPulaLinha
cQry += " AND UF2.UF2_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' " 										+ cPulaLinha
if !Empty(cPlano)
	cQry += " AND UF2.UF2_PLANO IN " + FormatIn( AllTrim(cPlano),";") 		 													+ cPulaLinha		
endif

cQry += " AND UF2.UF2_TXMNT > 0 " 																								+ cPulaLinha
// verifico se o campo [UF2_ATMNT] "ativa cobrança de taxa de manutanção" existe na tabela de contrato funenário
If UF2->(FieldPos("UF2_ATMNT")) > 0
	cQry += " AND UF2.UF2_ATMNT <> 'N' " + CRLF // Ativa Cobrança Tx. Manutenção - S/N
EndIf
cQry += " ORDER BY TAXA,UF2.UF2_CODIGO "																						+ cPulaLinha

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

MemoWrite("C:\temp\Taxa_Manutencaoo.txt",cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   


// se existir contratos a serem reajustados
if QRY->(!Eof())

	oGrid:Acols := {}
	lRet 		:= .T. 

	While QRY->(!Eof()) 
	
		aFieldFill := {}
		
		// verifico se já existe historico de manutenção
		// caso exista, será aplicado o índice
		UH0->(DbSetOrder(2)) // UH0_FILIAL + UH0_CONTRA
		if UH0->(DbSeek(xFilial("UH0") + QRY->CONTRATO))
			nIndAplic := nIndice 
		endif
		
		nValReaj	:= QRY->TAXA  * (nIndAplic / 100)  
		nTaxaReaj 	:= QRY->TAXA + nValReaj 
		
		aadd(aFieldFill, "CHECKED")	
		aadd(aFieldFill, QRY->CONTRATO)
		aadd(aFieldFill, SubStr(QRY->DATA_MANUTENCAO,5,2) + "/" + SubStr(QRY->DATA_MANUTENCAO,1,4))
		aadd(aFieldFill, QRY->CLIENTE)
		aadd(aFieldFill, QRY->LOJA)
		aadd(aFieldFill, QRY->DIA_VENCIMENTO)
		aadd(aFieldFill, QRY->TAXA)
		aadd(aFieldFill, nIndAplic)
		aadd(aFieldFill, nValReaj)
		aadd(aFieldFill, nTaxaReaj)
		aadd(aFieldFill, .F.)
		aadd(oGrid:Acols,aFieldFill) 
		
		// atualizo totalizadores
		nQtTotal++
		nGetTotal += nTaxaReaj
		
		QRY->(DbSkip()) 
		
	EndDo
	
	oGrid:oBrowse:Refresh() 
		
endif

// fecho o alias temporario criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} DuoClique
//TODO Função chamada no duplo clique no grid
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function DuoClique(oObj,oGetTotal,nGetTotal,oQtTotal,nQtTotal)

Local nPosMark	:= aScan(oObj:aHeader,{|x| AllTrim(x[2])== "MARK"})       
Local nPosVlr   := aScan(oObj:aHeader,{|x| AllTrim(x[2])== "TXREAJ"})  

if oObj:aCols[oObj:nAt][nPosMark] == "CHECKED"
	
	oObj:aCols[oObj:nAt][nPosMark] 	:= "UNCHECKED" 
	nGetTotal -= oObj:aCols[oObj:nAt][nPosVlr] 
	nQtTotal--

else

	oObj:aCols[oObj:nAt][nPosMark] 	:= "CHECKED" 
	nGetTotal += oObj:aCols[oObj:nAt][nPosVlr]
	nQtTotal++

endif

oGetTotal:Refresh()
oQtTotal:Refresh()

oObj:oBrowse:Refresh()

Return()

/*/{Protheus.doc} MarcaTodos
//TODO Função chamada pela ação de clicar no cabeçalho dos grids
para selecionar todos os checkbox
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function MarcaTodos(_obj,oGetTotal,nGetTotal,oQtTotal,nQtTotal)

Local nX		:= 1
Local nPosVlr   := aScan(_obj:aHeader,{|x| AllTrim(x[2])== "TXREAJ"})  


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
			nGetTotal += _obj:aCols[nX][nPosVlr]
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
	oGetTotal:Refresh()
	oQtTotal:Refresh()
	
	
Endif

Return()

/*/{Protheus.doc} ConfirmaManut
//TODO Função chamada na confirmação da tela
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function ConfirmaManut(oSay,oGrid,cIndice)

Local nX		:= 1
Local nPosCtr	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CONTRATO"})
Local nPosVReaj	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "VLREAJ"})
Local nPosTxAtu	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "TXATU"})
Local nPosTaxa	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "TXREAJ"})
Local nPosCli	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CLIENTE"})
Local nPosLoja	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "LOJA"})
Local nPosInd	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "INDICE"})
Local nPosData	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "DATA"})
Local nPosDia	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "DIA_VENCIMENTO"})
Local nIndice	:= 0
Local nTaxa		:= 0
Local nValAdic	:= 0
Local nMesesMan	:= SuperGetMv("MV_XINTTXA",.F.,6) // intervalo de meses para geração da segunda taxa
Local nQtdManut	:= SuperGetMv("MV_XQTDTXA",.F.,2) // quantidade de taxas de manutenção que serão geradas
Local cContrato	:= ""
Local cCliente	:= ""
Local cLoja		:= ""
Local cProxReaj	:= ""
Local dDtAux	:= CTOD("  /  /    ")
Local lContinua	:= .T.

if MsgYesNo("Deseja gerar a taxa de manutenção para os contratos?")

	//inicio a transacao
	Begintran()
	
	// percorro todo o grid
	For nX := 1 To Len(oGrid:aCols)
	
		// se a linha estiver marcada
		if oGrid:aCols[nX][1] == "CHECKED"
		
			// se o contrato estiver preenchido
			if !Empty(oGrid:aCols[nX][nPosCtr])
			
				cContrato 	:= oGrid:aCols[nX][nPosCtr] 
				cCliente	:= oGrid:aCols[nX][nPosCli]
				cLoja		:= oGrid:aCols[nX][nPosLoja]
				nTaxa		:= oGrid:aCols[nX][nPosTaxa]
				nValAdic	:= oGrid:aCols[nX][nPosVReaj]
				cDiaVenc	:= oGrid:aCols[nX][nPosDia]   
				nIndice		:= oGrid:aCols[nX][nPosInd] 
				
				//A data do proximo reajuste sera de acordo com a data de geracao da taxa
				//nao sera mais gerada de acordo com a data de enderecamento ou ultima taxa de manutencao gerada
				dDtAux 		:= dDataBase
				dDtAux		:= MonthSum(dDtAux,(nMesesMan * nQtdManut)) // somo a quantidade de meses para a próxima manutenção  
				cProxReaj	:= StrZero(Month(dDtAux),2) + StrZero(Year(dDtAux),4)   
				
				// chamo função do reajuste				
				oSay:cCaption := (" Gerando Taxa(s) do contrato: " + cContrato + " ")
				ProcessMessages()
				
				lContinua := ProcManut(cContrato,cCliente,cLoja,nTaxa,nValAdic,cDiaVenc,cIndice,nIndice,cProxReaj)
				
			endif 
			
			//caso nao inclui a taxa com sucesso, aborto o processo
			if !lContinua
				DisarmTransaction()
				Alert("Não foi possível concluir o processo de geração das taxas de manutenções, favor corrigir o erro especificado na mensagem anterior! " )
				Exit
			endif
			
		endif	
	
	Next nX
	
	if lContinua
		EndTran()
		Aviso("Sucesso!" , "Geração da taxa concluída!" , {"OK"} , 1)
	endif
	
	// fecho a janela
	oDlg:End() 

endif

Return()

/*/{Protheus.doc} ProcManut
//TODO Função que gera o título da taxa de manutenção
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function ProcManut(cContrato,cCliente,cLoja,nTaxa,nValAdic,cDiaVenc,cIndice,nIndice,cProxReaj)

Local aArea 		:= GetArea()
Local aAreaSE1		:= SE1->(GetArea())
Local aAreaUF2		:= UF2->(GetArea())
Local cPrefixo 		:= SuperGetMv("MV_XPRFMNF",.F.,"FUN")
Local cTipo			:= SuperGetMv("MV_XTPMNF",.F.,"MNT")
Local cNat			:= SuperGetMv("MV_XNATMNF",.F.,"10101") // natureza da taxa de manutencao
Local aDados		:= {}
Local aHistorico	:= {}
Local nMesesMan		:= SuperGetMv("MV_XINTTXA",.F.,6) // intervalo de meses para geração da segunda taxa
Local nQtdManut		:= SuperGetMv("MV_XQTDTXA",.F.,2) // quantidade de taxas de manutenção que serão geradas
Local nX			:= 1
Local nVlrAux		:= 0
Local cParcela		:= ""
Local cNewDiaVenc	:= SuperGetMv("MV_XNEWVEN",.F.,"  ")
Local dDataAux		:= CTOD("  /  /    ")
Local dVencimento	:= CTOD("  /  /    ")
Local lOk			:= .F.

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

	// o vencimento da parcela será para o próximo mês
	// o dia de vencimento será de acordo com o informado no contrato
	dDataAux := MonthSum(dDataBase,1)
		
	if cDiaVenc > StrZero(Day(LastDay(dDataAux)),2) 
		dVencimento := LastDay(dDataAux) 
	else
		dVencimento := CTOD(cDiaVenc + "/" + StrZero(Month(dDataAux),2) + "/" + StrZero(Year(dDataAux),4))  
	endif


	For nX := 1 To nQtdManut
			
		if Empty(cParcela)
			cParcela 	:= RetParcela(xFilial("SE1"),cPrefixo,cContrato,cTipo)
		else
			cParcela := Soma1(cParcela)
		endif
		
		aDados 		:= {}
		lMsErroAuto	:= .F.	
		cMesAno 	:= SubStr(DTOC(dVencimento),4,7)  
			
		AAdd(aDados, {"E1_FILIAL"	, xFilial("SE1")					, Nil } )
		AAdd(aDados, {"E1_PREFIXO"	, cPrefixo          				, Nil } )
		AAdd(aDados, {"E1_NUM"		, cContrato		 	   				, Nil } )
		AAdd(aDados, {"E1_PARCELA"	, cParcela							, Nil } )
		AAdd(aDados, {"E1_TIPO"		, cTipo		 						, Nil } )
		AAdd(aDados, {"E1_NATUREZ"	, cNat								, Nil } )
		AAdd(aDados, {"E1_CLIENTE"	, cCliente							, Nil } )
		AAdd(aDados, {"E1_LOJA"		, cLoja								, Nil } )
		AAdd(aDados, {"E1_EMISSAO"	, dDataBase							, Nil } )
		AAdd(aDados, {"E1_VENCTO"	, dVencimento						, Nil } )
		AAdd(aDados, {"E1_VENCREA"	, DataValida(dVencimento)			, Nil } )
		AAdd(aDados, {"E1_VALOR"	, nTaxa								, Nil } )			
		AAdd(aDados, {"E1_XCTRFUN"	, cContrato							, Nil } )
		AAdd(aDados, {"E1_XPARCON"	, cMesAno							, Nil } )
		AAdd(aDados, {"E1_XFORPG"	, UF2->UF2_FORPG					, Nil } )
		
		// array de historico de manutenção
		AAdd(aHistorico,{cPrefixo,cContrato,cParcela,cTipo,nTaxa,dVencimento})
				
		MSExecAuto({|x,y| FINA040(x,y)},aDados,3)
				
		if lMsErroAuto
			MostraErro()
			lOK := .F.
			Exit
		else
			lOK := .T.
		endif
		
		// somo X meses para a próxima taxa
		dVencimento := MonthSum(dVencimento,nMesesMan)
	
	Next nX
	
	if lOK
	
		if GravaHistorico(cContrato,cIndice,nIndice,nTaxa,nValAdic,cProxReaj,aHistorico)
		
			UF2->(DbSetOrder(1)) // UF2_FILIAL + UF2_CODIGO
			if UF2->(DbSeek(xFilial("UF2") + cContrato))
				
				if RecLock("UF2",.F.)
					UF2->UF2_ADIMNT += nValAdic 
					UF2->(MsUnLock())
				endif
			
			endif
		
		else
			lOk	:= .F.
			Alert("Não foi possível gerar a taxa de manutenção do contrato " + AllTrim(cContrato))
		endif
	
	endif

RestArea(aAreaSE1)
RestArea(aAreaUF2)
RestArea(aArea)

Return(lOk)

/*/{Protheus.doc} GravaHistorico
//TODO Função que grava o histórico da taxa de manutenção
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function GravaHistorico(cContrato,cIndice,nIndice,nTaxa,nValAdic,cProxReaj,aDados)

Local oAux
Local oStruct
Local cMaster 		:= "UH0"
Local cDetail		:= "UH1"
Local aCpoMaster	:= {}
Local aLinha		:= {}
Local aCpoDetail	:= {}
Local oModel  		:= FWLoadModel("RFUNA028") // instanciamento do modelo de dados
Local nX			:= 1
Local nI       		:= 0
Local nJ       		:= 0
Local nPos     		:= 0
Local lRet     		:= .T.
Local aAux	   		:= {}
Local nItErro  		:= 0
Local lAux     		:= .T.
Local cItem 		:= PADL("1",TamSX3("UH1_ITEM")[1],"0")

aadd(aCpoMaster,{"UH0_FILIAL"	, xFilial("UH0")	})
aadd(aCpoMaster,{"UH0_DATA"		, dDataBase			})
aadd(aCpoMaster,{"UH0_CONTRA"	, cContrato			})
aadd(aCpoMaster,{"UH0_TPINDI"	, cIndice			})
aadd(aCpoMaster,{"UH0_INDICE"	, nIndice			})
aadd(aCpoMaster,{"UH0_TAXA"		, nTaxa				})
aadd(aCpoMaster,{"UH0_VLADIC"	, nValAdic			})
aadd(aCpoMaster,{"UH0_PROMAN"	, cProxReaj			})

For nX := 1 To Len(aDados)
		
	aLinha := {}
		
	aadd(aLinha,{"UH1_FILIAL"	, xFilial("UH1")	})
	aadd(aLinha,{"UH1_ITEM"		, cItem				})
	aadd(aLinha,{"UH1_PREFIX"	, aDados[nX,1]		})
	aadd(aLinha,{"UH1_NUM"		, aDados[nX,2]		})
	aadd(aLinha,{"UH1_PARCEL"	, aDados[nX,3]		})
	aadd(aLinha,{"UH1_TIPO"		, aDados[nX,4]		})
	aadd(aLinha,{"UH1_VALOR"	, aDados[nX,5]		})
	aadd(aLinha,{"UH1_VENC"		, aDados[nX,6]		})
	aadd(aCpoDetail,aLinha)
	
	cItem := SOMA1(cItem)
	
Next nX

(cDetail)->(DbSetOrder(1))
(cMaster)->(DbSetOrder(1))

// defino a operação de inclusão
oModel:SetOperation(3)

// Antes de atribuirmos os valores dos campos temos que ativar o modelo
lRet := oModel:Activate()

If lRet
	
	// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
	oAux := oModel:GetModel( cMaster + 'MASTER' )
	
	// Obtemos a estrutura de dados do cabeçalho
	oStruct := oAux:GetStruct()
	aAux := oStruct:GetFields()
	
	If lRet
		
		For nI := 1 To Len(aCpoMaster)
			
			// Verifica se os campos passados existem na estrutura do cabeçalho
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoMaster[nI][1] ) } ) ) > 0
				
				// È feita a atribuicao do dado aos campo do Model do cabeçalho
				If !( lAux := oModel:SetValue( cMaster + 'MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )
					
					// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
					// o método SetValue retorna .F.
					lRet    := .F.
					Exit
					
				EndIf
				
			EndIf
			
		Next nI
		
	EndIf
	
EndIf

If lRet
	
	// Intanciamos apenas a parte do modelo referente aos dados do item
	oAux := oModel:GetModel( cDetail + 'DETAIL' )
	
	// Obtemos a estrutura de dados do item
	oStruct := oAux:GetStruct()
	aAux := oStruct:GetFields()
	
	nItErro  := 0
	
	For nI := 1 To Len(aCpoDetail)
		
		// Incluímos uma linha nova
		// ATENCAO: O itens são criados em uma estrura de grid (FORMGRID), portanto já é criada uma primeira linha
		//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
		
		If nI > 1
			
			// Incluimos uma nova linha de item
			
			If  ( nItErro := oAux:AddLine() ) <> nI
				
				// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
				// ele retorna a quantidade de linhas já
				// existem no grid. Se conseguir retorna a quantidade mais 1
				lRet    := .F.
				Exit
				
			EndIf
			
		EndIf
		
		For nJ := 1 To Len( aCpoDetail[nI] )
			
			// Verifica se os campos passados existem na estrutura de item
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0
				
				If !( lAux := oModel:SetValue( cDetail + 'DETAIL', aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )
					
					// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
					// o método SetValue retorna .F.
					lRet    := .F.
					nItErro := nI
					Exit
					
				EndIf
				
			EndIf
			
		Next nJ
		
		If !lRet
			Exit
		EndIf
		
	Next nI
	
EndIf

If lRet
	
	// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
	// neste momento os dados não são gravados, são somente validados.
	If ( lRet := oModel:VldData() )
		
		// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
		lRet := oModel:CommitData()
	
	EndIf
	
EndIf

If !lRet
	
	// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
	aErro   := oModel:GetErrorMessage()
	
	// A estrutura do vetor com erro é:
	//  [1] Id do formulário de origem
	//  [2] Id do campo de origem
	//  [3] Id do formulário de erro
	//  [4] Id do campo de erro
	//  [5] Id do erro
	//  [6] mensagem do erro
	//  [7] mensagem da solução
	//  [8] Valor atribuido
	//  [9] Valor anterior
	
	AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
	AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
	AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
	AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
	AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
	AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
	AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
	AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
	AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
	
	If nItErro > 0
		AutoGrLog( "Erro no Item:              " + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' )
	EndIf
	
	MostraErro()
	
EndIf

// Desativamos o Model
oModel:DeActivate()

Return(lRet)

/*/{Protheus.doc} ValidParam
//TODO Função que calcula a média do índice
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function BuscaIndice(cIndice)

Local cQry 		   	:= ""     
Local cPulaLinha	:= chr(13)+chr(10) 
Local nRet			:= 0
Local dDataRef		:= dDataBase

// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf        

cQry := " SELECT " 																				+ cPulaLinha
cQry += " SUM(U29.U29_INDICE) AS INDICE " 														+ cPulaLinha 
cQry += " FROM " 																				+ cPulaLinha 
cQry += + RetSqlName("U22") + " U22 " 															+ cPulaLinha 
cQry += " INNER JOIN " 																			+ cPulaLinha 
cQry += + RetSqlName("U28") + " U28 " 															+ cPulaLinha
cQry += "    INNER JOIN " 																		+ cPulaLinha
cQry += + 	 RetSqlName("U29") + " U29 " 														+ cPulaLinha
cQry += "    ON ( " 																			+ cPulaLinha
cQry += "        U29.D_E_L_E_T_ <> '*' " 														+ cPulaLinha
cQry += "        AND U28.U28_CODIGO = U29.U29_CODIGO " 											+ cPulaLinha
cQry += "        AND U28.U28_ITEM = U29.U29_IDANO " 											+ cPulaLinha 
cQry += " 		 AND U29.U29_FILIAL = '" + xFilial("U29") + "' " 								+ cPulaLinha
cQry += "    ) " 																				+ cPulaLinha
cQry += " ON ( " 																				+ cPulaLinha
cQry += "    U28.D_E_L_E_T_ <> '*' " 															+ cPulaLinha
cQry += "    AND U22.U22_CODIGO = U28.U28_CODIGO " 												+ cPulaLinha
cQry += " 	 AND U28.U28_FILIAL = '" + xFilial("U28") + "' " 									+ cPulaLinha
cQry += "    ) " 																				+ cPulaLinha
cQry += " WHERE " 																				+ cPulaLinha 
cQry += " U22.D_E_L_E_T_ <> '*' " 																+ cPulaLinha
cQry += " AND U22.U22_FILIAL = '" + xFilial("U22") + "' " 										+ cPulaLinha 
cQry += " AND U22.U22_STATUS IN ('A','S') "														+ cPulaLinha

if !Empty(cIndice)
	cQry += " AND U22.U22_CODIGO = '" + cIndice + "' " 											+ cPulaLinha
endif
 
cQry += " AND U28.U28_ANO + U29.U29_MES " 														+ cPulaLinha 
cQry += " BETWEEN '" + AnoMes(MonthSub(dDataRef,11)) + "'  AND  '" + AnoMes(dDataRef) + "' " 	+ cPulaLinha

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

// se existir contratos a serem reajustados
if QRY->(!Eof())
	nRet := Round(QRY->INDICE,TamSX3("U29_INDICE")[2])
endif

// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf  

Return(nRet)


/*/{Protheus.doc} RFUNA029
//TODO Função que cria as perguntas na SX1.	
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relatório

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

//////////// Contrato ///////////////

U_xPutSX1( cPerg, "01","Contrato De?","Contrato De?","Contrato De?","cContratoDe","C",6,0,0,"G","","UF2","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "02","Contrato Ate?","Contrato Ate?","Contrato Ate?","cContratoAte","C",6,0,0,"G","","UF2","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

///////////// Plano /////////////////

U_xPutSX1( cPerg, "03","Plano?","Plano?","Plano?","cPlano","C",99,0,0,"G","","UF0MRK","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// Índice ///////////////

U_xPutSX1( cPerg, "04","Índice?","Índice?","Índice?","cIndice","C",3,0,0,"G","","U22","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return() 

/*/{Protheus.doc} RetParcela
//TODO Função que retorna a próxima parcela do título a ser utilizada
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function RetParcela(cFilSE1,cPrefixo,cNumero,cTipo)

Local cRet 		:= ""
Local aArea		:= GetArea()
Local aAreaSE1	:= SE1->(GetArea())


cQry := " SELECT "
cQry += " MAX(E1_PARCELA) PARCELA "
cQry += " FROM "
cQry += " " + RetSQLName("SE1") + " "
cQry += " WHERE "
cQry += " D_E_L_E_T_ = ' ' "
cQry += " AND E1_FILIAL = '" + cFilSE1 + "' "
cQry += " AND E1_PREFIXO = '" + cPrefixo + "'" 
cQry += " AND E1_TIPO = '" + cTipo + "' " 
cQry += " AND E1_XCTRFUN = '" + cNumero + "' "

If Select("QRYTIT") > 0
	QRYTIT->(dbCloseArea())
EndIf

cQry := Changequery(cQry)

TcQuery cQry New Alias "QRYTIT"

// se existir títulos com este tipo
if QRYTIT->(!Eof()) .AND. !Empty(QRYTIT->PARCELA)
	cRet := Soma1(QRYTIT->PARCELA)	
else
	cRet := Padl("1",TamSX3("E1_PARCELA")[1],"0")		
endif

RestArea(aAreaSE1)
RestArea(aArea)

Return(cRet)
