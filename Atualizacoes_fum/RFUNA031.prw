#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} RFUNA031
//TODO Rotina de reajuste de contratos da funerária - Modelo 2	
Essa rotina sera executada caso o parametro MV_XTPREAJ esteja com 
igual 2, ou seja, o reajuste nao ocorrera de acordo com a data de
aniversaio do contrato, mas sim de acordo com a quantidade de
parcelas que sera gerada na ativacao. Os reajustes serao utilizados	
para gerar as parcelas ate o final do ano subsequente
@author Raphael Martins
@since 08/05/2018
@version 1.0
@type function
/*/

User Function RFUNA031()

Local aArea			:= GetArea()
Local aAreaUF2		:= UF2->(GetArea())
Local cPerg 		:= "RFUNA031"
Local cContratoDe	:= ""
Local cContratoAte	:= ""
Local cPlano		:= ""
Local cIndice		:= ""
Local lContinua		:= .T.
Local nIndice		:= 0
Local lConsAniver	:= SuperGetMv("MV_XPARNIV",,.T.) 

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
		
		if ValidParam(cContratoDe,cContratoAte,cPlano,cIndice,@nIndice) 
			
			FWMsgRun(,{|oSay| ConsultaCTR(cContratoDe,cContratoAte,cPlano,cIndice,nIndice) },'Aguarde...','Consultando os contratos...')
			
		endif
		
	endif
	
EndDo

RestArea(aAreaUF2)
RestArea(aArea)

Return()

/*/{Protheus.doc} ValidParam
//TODO Função que valida os parâmetros informados.	
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param cContratoDe	 	- Intervalo inicial dos contratos que serao filtrados
@param cContratoAte		- Intervalo Final dos contratos que serao filtrados
@param cPlano			- planos que serao consultados 
@param cIndice	 		- Codigo do Indice de Reajuste
@param nIndice	 		- Percentual de Reajuste
@return lRet			- Valida parametros informados
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

/*/{Protheus.doc} ConsultaCTR
//TODOFunção que consulta os contratos aptos a serem reajustados
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param cContratoDe	 	- Intervalo inicial dos contratos que serao filtrados
@param cContratoAte		- Intervalo Final dos contratos que serao filtrados
@param cPlano			- planos que serao consultados 
@param cIndice	 		- Codigo do Indice de Reajuste
@param nIndice	 		- Percentual de Reajuste
@return lRet			- Sem Retorno
@type function
/*/

Static Function ConsultaCTR(cContratoDe,cContratoAte,cPlano,cIndice,nIndice)

Local oGrid		:= NIL
Local oGetTotal	:= NIL
Local oQtTotal	:= NIL
Local oPn1		:= NIL
Local nQtTotal	:= 0
Local nGetTotal	:= 0
Local aButtons	:= {}
Local aObjects 	:= {}
Local aSizeAut	:= MsAdvSize()
Local aInfo		:= {}
Local aPosObj	:= {}

Static oDlg

Private cCadastro := "Reajuste de Contrato - Funerária"

//Largura, Altura, Modifica largura, Modifica altura
aAdd( aObjects, { 100,	100, .T., .T. } ) //Browse

aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE "Contratos a serem reajustados" From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] COLORS 0, 16777215 PIXEL

//defino os panels da tela
@ 001,000 MSPANEL oPn1 SIZE 150, 050 OF oDlg
@ 001,000 MSPANEL oPn2 SIZE 150, 050 OF oPn1
@ 001,000 MSPANEL oPn3 SIZE 150, 050 OF oPn1

oPn1:Align  := CONTROL_ALIGN_ALLCLIENT
oPn2:Align  := CONTROL_ALIGN_TOP
oPn3:Align  := CONTROL_ALIGN_BOTTOM

oPn2:nHeight := (oMainWnd:nClientHeight / 2) + 150
oPn3:nHeight := (oMainWnd:nClientHeight - oPn2:nHeight ) - 100


EnchoiceBar(oDlg, {|| ConfirmaReajuste(oGrid,cIndice,nIndice)},{|| oDlg:End()},,aButtons)

//objetos totalizadores
@ 00, 05 SAY oTotal PROMPT "R$ Total Selecionado:" SIZE 100, 007 OF oPn3 Font oFont COLOR CLR_RED PIXEL
@ 00, 090 MSGET oGetTotal VAR nGetTotal SIZE 100, 007 When .F. OF oPn3 HASBUTTON PIXEL COLOR CLR_BLACK Picture "@E 999,999,999.99"

@ 00, 210 SAY oTotal PROMPT "Quantidade Selecionada:" SIZE 100, 007 OF oPn3 COLORS CLR_RED Font oFont COLOR CLR_BLACK PIXEL
@ 00, 300 MSGET oQtTotal VAR nQtTotal SIZE 100, 007 When .F. OF oPn3 HASBUTTON PIXEL COLOR CLR_BLACK Picture "@E 999999999"	

// crio o grid de contratos
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
	
	Alert("Não foram encontrados contratos para serem reajustados!")
	oDlg:End()
	
endif

ACTIVATE MSDIALOG oDlg CENTERED

Return() 

/*/{Protheus.doc} MsGridCTR
//TODO Função que cria o grid de contratos
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param 	oPainel 	- Painel que sera criada a grid dos contratos
@return oGrid		- MsNewGetdados criada dos contratos consultados
@type function
/*/

Static Function MsGridCTR(oPainel)

Local oGrid			:= NIL
Local nX			:= 1
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {"MARK","CONTRATO","PARC_REST","CLIENTE","LOJA","NOME","VALOR_CONTRATO","PERCENTUAL","VALOR_REAJUSTE","VALOR_TOTAL","ULT_VENCTO","QTD_REAJ"}
Local aAlterFields 	:= {}

For nX := 1 To Len(aFields)
	
	if aFields[nX] == "MARK" 
		Aadd(aHeaderEx, {"","MARK","@BMP",2,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "CONTRATO"
		Aadd(aHeaderEx, {"Contrato","CONTRATO","@!",6,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "PARC_REST"
		Aadd(aHeaderEx, {"Parcelas Restantes","PARC_REST",PesqPict("UF2","UF2_QTPARC"),TamSX3("UF2_QTPARC")[1],0,"","€€€€€€€€€€€€€€","N","","","",""})
	elseif aFields[nX] == "NOME"
		Aadd(aHeaderEx, {"Nome","NOME",PesqPict("SA1","A1_NOME"),TamSX3("A1_NOME")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "CLIENTE"
		Aadd(aHeaderEx, {"Cliente","CLIENTE","@!",TamSX3("UF2_CLIENT")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "LOJA"
		Aadd(aHeaderEx, {"Loja","LOJA","@!",TamSX3("UF2_LOJA")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "VALOR_CONTRATO"
		Aadd(aHeaderEx, {"Valor Contrato","VALOR_CTR",PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1],TamSX3("E1_VALOR")[2],"","€€€€€€€€€€€€€€","N","","","",""})
	elseif aFields[nX] == "PERCENTUAL"
		Aadd(aHeaderEx, {"% Reajuste","PERCENTUAL","@E 999.99",6,2,"","€€€€€€€€€€€€€€","N","","","",""})
	elseif aFields[nX] == "VALOR_REAJUSTE"
		Aadd(aHeaderEx, {"Valor do Reajuste","VALOR_REAJUSTE",PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1],TamSX3("E1_VALOR")[2],"","€€€€€€€€€€€€€€","N","","","",""})
	elseif aFields[nX] == "VALOR_TOTAL"
		Aadd(aHeaderEx, {"Valor Total","VALOR_TOTAL",PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1],TamSX3("E1_VALOR")[2],"","€€€€€€€€€€€€€€","N","","","",""})		
	elseif aFields[nX] == "ULT_VENCTO"
		Aadd(aHeaderEx, {"Ultimo Titulo","ULT_VENCTO","@R 99/9999",6,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "QTD_REAJ"
		Aadd(aHeaderEx, {"Qtd p/ Reajustar","QTD_REAJ","@E 99999",6,0,"","€€€€€€€€€€€€€€","N","","","",""})
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
//TODO Função chamada no duplo clique no grid
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param oGrid 			- Objeto da Grid de Contratos 
@param cContratoDe	 	- Intervalo inicial dos contratos que serao filtrados
@param cContratoAte		- Intervalo Final dos contratos que serao filtrados
@param cPlano			- planos que serao consultados 
@param cIndice	 		- Codigo do Indice de Reajuste
@param nIndice	 		- Percentual de Reajuste
@param nGetTotal	 	- Totalizador de Valor de Reajuste
@param oQtTotal	 		- Objeto do Totalizador de Quantidade de Contratos selecionados 
@param nQtTotal	 		- Totalizador de Quantidade de Contratos selecionados
@return lRet			- Encontrado contratos para reajustar
@type function
/*/
Static Function RefreshGrid(oGrid,cContratoDe,cContratoAte,cPlano,cIndice,nIndice,oGetTotal,nGetTotal,oQtTotal,nQtTotal)

Local lRet				:= .F.
Local cQry 				:= ""
Local aFieldFill		:= {}
Local nValorAdicional	:= 0  
Local nQtdReajustar		:= 0   
Local cPulaLinha		:= chr(13)+chr(10)   
Local cTipoParc			:= SuperGetMv("MV_XTIPFUN",.F.,"AT")
Local cTipoRJ			:= SuperGetMv("MV_XTRJFUN",.F.,"RJ") // tipo do título
Local cTipoAdt			:= SuperGetMv("MV_XTIPADT",.F.,"ADT")
Local lUsaPrimVencto	:= SuperGetMv("MV_XPRIMVC",.F.,.F.) 
Local cProximoAno		:= StrZero(Year(MonthSum(dDataBase,12)),4) + "12"

// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf     

////////////////////////////////////////////////////////////////////////
////// 		CONSULTA CONTRATOS DE ACORDO COM OS PARAMETROS			////
////// E QUE NAO POSSUEM TITULOS ATE O FINAL DO ANO SUBSEQUENTE		////
////////////////////////////////////////////////////////////////////////

cQry += " SELECT  "                                                                                                     + cPulaLinha
cQry += " CONTRATOS.UF2_CODIGO AS CONTRATO,  "                                                                          + cPulaLinha
cQry += " CONTRATOS.UF2_CLIENT AS CLIENTE, "                                                                            + cPulaLinha
cQry += " CONTRATOS.UF2_LOJA AS LOJA, "                                                                                 + cPulaLinha
cQry += " CONTRATOS.UF2_VALOR AS VALOR_INICIAL, "                                                                       + cPulaLinha
cQry += " CONTRATOS.UF2_VLADIC AS VALOR_ADICIONAL, "                                                                    + cPulaLinha
cQry += " CONTRATOS.UF2_QTPARC AS QTD_PARCELAS, "                                                                       + cPulaLinha
cQry += " TITULOS_CONTRATO.PARCELAS_GERADAS AS PARCELAS_GERADAS, "                                                      + cPulaLinha
cQry += " TITULOS_ATIVACAO.ULTIMO_VENCIMENTO AS ULTIMO_VENCIMENTO, "                                                    + cPulaLinha
cQry += " CONTRATOS.UF2_QTPARC - TITULOS_CONTRATO.PARCELAS_GERADAS AS PARCELAS_RESTANTES "                              + cPulaLinha
cQry += " FROM "                                                                                                        + cPulaLinha
cQry += + RetSQLName("UF2") + " CONTRATOS "                                                                             + cPulaLinha
cQry += " LEFT JOIN "                                                                                                   + cPulaLinha
cQry += " ( "                                                                                                           + cPulaLinha
cQry += " 	SELECT "                                                                                                    + cPulaLinha
cQry += " 	SE1.E1_XCTRFUN AS CODIGO_CONTRATO, "                                                                        + cPulaLinha
cQry += " 	MAX(SUBSTRING(SE1.E1_VENCTO,1,6)) AS ULTIMO_VENCIMENTO "                                                    + cPulaLinha
cQry += " 	FROM "                                                                                                      + cPulaLinha
cQry += " 	" + RetSQLName("SE1") + " SE1 "                                                                             + cPulaLinha
cQry += " 	WHERE "                                                                                                     + cPulaLinha
cQry += " 	SE1.D_E_L_E_T_ <> '*' "                                                                                     + cPulaLinha
cQry += " 	AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "                                                              + cPulaLinha
cQry += " 	AND SE1.E1_TIPO IN ('" + cTipoParc + "','" + cTipoRJ + "') "                                                + cPulaLinha
cQry += " 	GROUP BY SE1.E1_XCTRFUN "                                                                                   + cPulaLinha
cQry += " ) TITULOS_ATIVACAO "                                                                                          + cPulaLinha
cQry += " ON CONTRATOS.UF2_CODIGO = TITULOS_ATIVACAO.CODIGO_CONTRATO "                                                  + cPulaLinha
cQry += " LEFT JOIN "                                                                                                   + cPulaLinha
cQry += " ( "                                                                                                           + cPulaLinha
cQry += " 	SELECT "                                                                                                    + cPulaLinha
cQry += " 	COUNT(*) AS PARCELAS_GERADAS, "                                                                             + cPulaLinha
cQry += " 	SE1.E1_XCTRFUN AS CODIGO_CONTRATO "                                                                         + cPulaLinha
cQry += " 	FROM "                                                                                                      + cPulaLinha
cQry += "	" + RetSQLName("SE1") + " SE1 "                                                                             + cPulaLinha
cQry += " 	WHERE "                                                                                                     + cPulaLinha
cQry += " 	SE1.D_E_L_E_T_ <> '*' "                                                                                     + cPulaLinha
cQry += " 	AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "                                                              + cPulaLinha
cQry += " 	AND SE1.E1_XCTRFUN <> ' ' "                                                                                 + cPulaLinha
cQry += " 	AND SE1.E1_TIPO IN ('" + cTipoParc + "','" + cTipoRJ + "','" + cTipoAdt + "') "								+ cPulaLinha
cQry += " 	GROUP BY SE1.E1_XCTRFUN "                                                                                   + cPulaLinha
cQry += " ) TITULOS_CONTRATO "                                                                                          + cPulaLinha
cQry += " ON TITULOS_CONTRATO.CODIGO_CONTRATO = CONTRATOS.UF2_CODIGO "                                                  + cPulaLinha
cQry += " WHERE "                                                                                                       + cPulaLinha
cQry += " CONTRATOS.D_E_L_E_T_ = ' ' "                                                                                  + cPulaLinha
cQry += " AND CONTRATOS.UF2_FILIAL = '" + xFilial("UF2") + "'  "                                                        + cPulaLinha
cQry += " AND CONTRATOS.UF2_STATUS = 'A' "                                                                              + cPulaLinha
cQry += " AND CONTRATOS.UF2_DTATIV <> ' ' "                                                                             + cPulaLinha
cQry += " AND UF2_VALOR > 0 "                                                                                           + cPulaLinha
cQry += " AND ISNULL(TITULOS_ATIVACAO.ULTIMO_VENCIMENTO,'') < '" + cProximoAno + "' "									+ cPulaLinha

cQry += " AND CONTRATOS.UF2_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' " 							+ cPulaLinha

if !Empty(cPlano)
	cQry += " 	AND CONTRATOS.UF2_PLANO IN " + FormatIn( AllTrim(cPlano),";") 											+ cPulaLinha 		 												
endif

if !Empty(cIndice)
	cQry += " 	AND CONTRATOS.UF2_INDICE IN " + FormatIn( AllTrim(cIndice),";") 										+ cPulaLinha		 													
endif

cQry += " ORDER BY CONTRATOS.UF2_CODIGO "																				+ cPulaLinha																						

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

// se existir contratos a serem reajustados
if QRY->(!Eof())

	oGrid:Acols := {}
	lRet 		:= .T. 

	While QRY->(!Eof()) 
	
		aFieldFill := {}
		 
		nValorContrato	:= QRY->VALOR_INICIAL + QRY->VALOR_ADICIONAL 
		nValorReajuste 	:= nValorContrato * (nIndice / 100)  
		
		//quantos meses ira reajustar
		nQtdReajustar	:= DateDiffMonth(STOD(cProximoAno + "01"),STOD(QRY->ULTIMO_VENCIMENTO + "01"))
		
		aadd(aFieldFill, "CHECKED")	
		aadd(aFieldFill, QRY->CONTRATO)
		aadd(aFieldFill, QRY->PARCELAS_RESTANTES)
		aadd(aFieldFill, QRY->CLIENTE)
		aadd(aFieldFill, QRY->LOJA)
		aadd(aFieldFill, Posicione("SA1",1,xFilial("SA1") + QRY->CLIENTE + QRY->LOJA,"A1_NOME"))
		aadd(aFieldFill, nValorContrato)
		aadd(aFieldFill, nIndice)
		aadd(aFieldFill, nValorReajuste)
		aadd(aFieldFill, nValorReajuste + nValorContrato)
		aadd(aFieldFill, SubStr(QRY->ULTIMO_VENCIMENTO,5,2) + SubStr(QRY->ULTIMO_VENCIMENTO,1,4))
		aadd(aFieldFill, nQtdReajustar)
		aadd(aFieldFill, )
		
		Aadd(aFieldFill, .F.)
		aadd(oGrid:Acols,aFieldFill) 
		
		// atualizo totalizadores
		nQtTotal++
		nGetTotal += nValorReajuste
		
		oGetTotal:Refresh()
		oQtTotal:Refresh()
			
		QRY->(DbSkip()) 
				
	EndDo
	
	oGrid:oBrowse:Refresh() 
		
endif

// fecho o alias temporario criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

Return(lRet)

/*/{Protheus.doc} DuoClique
//TODO Função chamada no duplo clique no grid
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param _obj	 			- Objeto da Grid de Contratos 
@param oGetTotal	 	- Objeto do Totalizador de Valor de Reajuste
@param nGetTotal	 	- Totalizador de Valor de Reajuste
@param oQtTotal	 		- Objeto do Totalizador de Quantidade de Contratos selecionados 
@param nQtTotal	 		- Totalizador de Quantidade de Contratos selecionados
@return Sem Retorno
@type function
/*/

Static Function DuoClique(oObj,oGetTotal,nGetTotal,oQtTotal,nQtTotal)

Local nPosMark	:= aScan(oObj:aHeader,{|x| AllTrim(x[2])== "MARK"})       
Local nPosVlr   := aScan(oObj:aHeader,{|x| AllTrim(x[2])== "VALOR_REAJUSTE"})  

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
@since 08/05/2018
@version 1.0
@param _obj	 			- Objeto da Grid de Contratos 
@param oGetTotal	 	- Objeto do Totalizador de Valor de Reajuste
@param nGetTotal	 	- Totalizador de Valor de Reajuste
@param oQtTotal	 		- Objeto do Totalizador de Quantidade de Contratos selecionados 
@param nQtTotal	 		- Totalizador de Quantidade de Contratos selecionados
@return Sem Retorno
@type function
/*/

Static Function MarcaTodos(_obj,oGetTotal,nGetTotal,oQtTotal,nQtTotal)

Local nX		:= 1
Local nPosVlr   := aScan(_obj:aHeader,{|x| AllTrim(x[2])== "VALOR_REAJUSTE"})  


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

/*/{Protheus.doc} ConfirmaReajuste
//TODO Função chamada na confirmação da tela
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param oGrid	 	- Objeto da Grid de Contratos 
@param cIndice	 	- Codigo do Indice de Reajuste
@param nIndice	 	- Percentual de Reajuste
@return Sem Retorno
@type function
/*/
Static Function ConfirmaReajuste(oGrid,cIndice,nIndice)

Local aArea			:= GetArea()
Local aAreaUF2		:= UF2->(GetArea())
Local nPosCtr		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CONTRATO"})
Local nPosCli		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CLIENTE"})
Local nPosLoja		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "LOJA"})
Local nPosVlAdi		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "VALOR_REAJUSTE"})
Local nPosVlTot		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "VALOR_TOTAL"})
Local nPosInd		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "PERCENTUAL"})
Local nPosParc		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "PARC_REST"})
Local nPosQtReaj	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "QTD_REAJ"})
Local nPosLstVenc	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "ULT_VENCTO"}) 
Local nIndice		:= 0
Local nValParc		:= 0
Local nValAdic		:= 0
Local nQtdParc		:= 0 
Local nX			:= 1
Local cDiaVenc		:= ""
Local cContrato		:= ""
Local cCliente		:= ""
Local cLoja			:= ""
Local cNatureza		:= "" 
Local cPrefixo 		:= SuperGetMv("MV_XPREFUN",.F.,"FUN") // prefixo do título
Local cTipo			:= SuperGetMv("MV_XTRJFUN",.F.,"RJ") // tipo do título
Local lUsaPrimVencto:= SuperGetMv("MV_XPRIMVC",.F.,.F.)
Local lContinua		:= .T.
Local dDtLstParc	:= CTOD("")
Local dDtAux		:= CTOD("")
Local nAnosRenov	:= SuperGetMv("MV_XANOREN",.F.,4 )

if Empty(cPrefixo)
	MsgAlert("Não foi informado o prefixo do título no parâmetro 'MV_XPREFUN'. ")
elseif Empty(cTipo)
	MsgAlert("Não foi informado o tipo do título no parâmetro 'MV_XTRJFUN'. ")
else

	if MsgYesNo("Deseja executar o reajuste dos contratos?")
	
		// percorro todo o grid
		For nX := 1 To Len(oGrid:aCols)
		
			// se a linha estiver marcada
			if oGrid:aCols[nX][1] == "CHECKED"
			
				// se o contrato estiver preenchido
				if !Empty(oGrid:aCols[nX][nPosCtr])
				
					UF2->(DbSetOrder(1)) // UF2_FILIAL + UF2_CODIGO
					if UF2->(DbSeek(xFilial("UF2") + oGrid:aCols[nX][nPosCtr]))
					
						//quantidade de parcelas que sera gerada
						nQtdParc := oGrid:aCols[nX][nPosQtReaj] 
						
						// se a quantidade de parcelas default for maior que a quantidade de parcelas restantes
						if nQtdParc > oGrid:aCols[nX][nPosParc]
							nQtdParc := oGrid:aCols[nX][nPosParc] 
						endif
					
						//Valido se é necessario criar um novo ciclo para beneficiario do contrato
						If UF4->(DbSeek(xFilial("UF4")+UF2->UF2_CODIGO))

							While UF4->(!EOF()) ;
								.AND. UF4->UF4_FILIAL+UF4->UF4_CODIGO == UF2->UF2_FILIAL+UF2->UF2_CODIGO

								//Valido se beneficiario ja esta falecido
								if Empty(UF4->UF4_FALECI)	
								
									//Valido se o reajuste esta no periodo de renovacao do ciclo
									If Year(UF4->UF4_DTFIM) <= Year(dDataBase)

										If RecLock("UF4",.F.)
											UF4->UF4_DTFIM := YearSum(UF4->UF4_DTFIM , nAnosRenov )
											UF4->(MsUnLock())
										Endif	

									Endif
								Endif
								
								UF4->(DbSkip())
							EndDo

						Endif

						cContrato 	:= oGrid:aCols[nX][nPosCtr]
						
						if lUsaPrimVencto 
							cDiaVenc	:= If(!Empty(UF2->UF2_PRIMVE),SubStr(DTOS(UF2->UF2_PRIMVE),7,2),UF2->UF2_DIAVEN)
						else
							cDiaVenc	:= UF2->UF2_DIAVEN
						endif
						cCliente	:= oGrid:aCols[nX][nPosCli]
						cLoja		:= oGrid:aCols[nX][nPosLoja]  
						nValAdic	:= oGrid:aCols[nX][nPosVlAdi]
						nValParc	:= oGrid:aCols[nX][nPosVlTot]   
						nIndice		:= oGrid:aCols[nX][nPosInd] 
						
						// O calculo do proximo reajuste sera com base no ultimo reajuste
						dDtLstParc	:= STOD(SubStr(oGrid:aCols[nX][nPosLstVenc],3,4) + SubStr(oGrid:aCols[nX][nPosLstVenc],1,2) + "01")
						dDtAux		:= MonthSum(dDtLstParc,nQtdParc) // somo a quantidade de meses para a próxima manutenção  
						cProxReaj	:= StrZero(Month(dDtAux),2) + StrZero(Year(dDtAux),4)   
						cNatureza	:= UF2->UF2_NATURE
						
						if Empty(cNatureza)
							MsgAlert("Não foi informada a natureza financeira do contrato " + AllTrim(cContrato) + ". ")						
						else
						
							// chamo função do reajuste	
							FWMsgRun(,{|oSay| lContinua := ProcReajuste(oSay,cContrato,cCliente,cLoja,cIndice,nIndice,nQtdParc,nValParc,nValAdic,cProxReaj,cPrefixo,cTipo,cNatureza,cDiaVenc,dDtLstParc)},'Aguarde...','Reajustando os contratos...')
						
							if !lContinua
								Exit
							endif
							
						endif
					
					endif
				
				endif 
			
			endif	
		
		Next nX
		
		if lContinua
			MsgInfo("Reajuste concluído!")
		endif
		
		// fecho a janela
		oDlg:End() 
	
	endif

endif

RestArea(aAreaUF2)
RestArea(aArea)

Return()

/*/{Protheus.doc} ProcReajuste
//TODO Função que faz o processamento do reajuste
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param oSay 		- Objeto da regua de processamento
@param cContrato 	- Codigo do Contrato
@param cCliente 	- Codigo do Cliente
@param cLoja	 	- Loja do Cliente
@param cIndice	 	- Codigo do Indice de Reajuste
@param nIndice	 	- Percentual de Reajuste
@param nQtdParc	 	- Quantidade de Parcelas que serao reajustadas
@param nValParc	 	- Valor das Parcelas Reajustadas
@param nValAdic	 	- Valor Adicionado as parcelas
@param cProxReaj	- Ano e mes do proximo reajuste
@param cPrefixo		- Prefixo dos Titulos de Contrato
@param cTipo		- Tipo de Titulo de Parcelas
@param cNatureza	- Natureza financeira das Titulo de Parcelas
@param cDiaVenc		- Dia de Vencimento das parcelas
@param dDtLstParc	- Data de Vencimento da ultima parcela gerada do Contrato

@return lOk - Processado com sucesso
@type function
/*/
Static Function ProcReajuste(oSay,cContrato,cCliente,cLoja,cIndice,nIndice,nQtdParc,nValParc,nValAdic,cProxReaj,cPrefixo,cTipo,cNatureza,cDiaVenc,dDtLstParc)

Local aArea 		:= GetArea()
Local aAreaSE1		:= SE1->(GetArea())
Local aParcelas		:= {}
Local aDados		:= {}
Local aHistorico	:= {}
Local aRegras		:= {}
Local nDiaVenc		:= 0
Local nX			:= 1
Local cParcela		:= ""
Local dVencimento	:= CTOD("  /  /    ")
Local lOK			:= .F.
Local cMesAno		:= ""
Local lConsAniver	:= SuperGetMv("MV_XPARNIV",,.T.) 

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

BeginTran()

dVencimento := MonthSum(dDtLstParc,1)

cParcela := RetParcela(xFilial("SE1"),cPrefixo,cContrato,cTipo)

For nX := 1 To nQtdParc

	if cDiaVenc > StrZero(Day(LastDate(dVencimento)),2) 
		dVencimento := LastDate(dVencimento)
	else
		dVencimento := CTOD(cDiaVenc + "/" + StrZero(Month(dVencimento),2) + "/" + StrZero(Year(dVencimento),4))	
	endif
		
	aDados 		:= {}
	lMsErroAuto	:= .F.	
	cMesAno 	:= SubStr(DTOC(dVencimento),4,7)  
	
	oSay:cCaption := ("Contrato: " + AllTrim(cContrato) + ", gerando parcela " + cParcela + ", vencimento " + DTOC(dVencimento) + " ...")
	ProcessMessages()
	
	//Valido se parametro que considera aniversarios no calculo da parcela
	if lConsAniver
		aRegras  := {}					
		nValParc := U_RFUNE040(dVencimento,cContrato,@aRegras)
		nValAdic := Round(nValParc * (nIndice / 100),TamSx3("UF2_VLADIC")[1])
		nValParc := nValParc + nValAdic  
	Endif
		
	
	AAdd(aDados, {"E1_FILIAL"	, xFilial("SE1")					, Nil } )
	AAdd(aDados, {"E1_PREFIXO"	, cPrefixo          				, Nil } )
	AAdd(aDados, {"E1_NUM"		, cContrato		 	   				, Nil } )
	AAdd(aDados, {"E1_PARCELA"	, cParcela							, Nil } )
	AAdd(aDados, {"E1_TIPO"		, cTipo		 						, Nil } )
	AAdd(aDados, {"E1_NATUREZ"	, cNatureza							, Nil } )
	AAdd(aDados, {"E1_CLIENTE"	, cCliente							, Nil } )
	AAdd(aDados, {"E1_LOJA"		, cLoja								, Nil } )
	AAdd(aDados, {"E1_EMISSAO"	, dDataBase							, Nil } )
	AAdd(aDados, {"E1_VENCTO"	, dVencimento						, Nil } )
	AAdd(aDados, {"E1_VENCREA"	, DataValida(dVencimento)			, Nil } )
	AAdd(aDados, {"E1_VALOR"	, nValParc							, Nil } )			
	AAdd(aDados, {"E1_XCTRFUN"	, cContrato							, Nil } )
	AAdd(aDados, {"E1_XPARCON"	, cMesAno							, Nil } )
	AAdd(aDados, {"E1_XFORPG"	, UF2->UF2_FORPG					, Nil } )
	
	// array de historico de manutenção
	AAdd(aHistorico,{cPrefixo,cContrato,cParcela,cTipo,nValParc})
			
	MSExecAuto({|x,y| FINA040(x,y)},aDados,3)
			
	if lMsErroAuto
		MostraErro()
		DisarmTransaction()	
		lOK := .F.
		Exit
	else
		lOK := .T.

		//Gravo composicao do valor da parcela se parametro 
		//por parcela idade estiver habilitado
		if lConsAniver

			U_RFUN40OK(cContrato,aRegras)
		Endif
	endif
	
	// incremento a parcela
	cParcela	:= Soma1(cParcela)
	dVencimento := MonthSum(dVencimento,1)

Next nX

if lOK

	lOK := GravaHistorico(cContrato,cIndice,nIndice,cProxReaj,nValAdic,aHistorico)

	if lOK
		
		UF2->(DbSetOrder(1)) // UF2_FILIAL + UF2_CODIGO
		if UF2->(DbSeek(xFilial("UF2") + cContrato))
			
			if RecLock("UF2",.F.)
				UF2->UF2_VLADIC += nValAdic 
				UF2->(MsUnLock())
				EndTran()
			endif
		
		endif
		
	else
	
		// aborto a transação
		DisarmTransaction()
		
	endif

endif

if !lOK

	MsgAlert("Ocorreu um problema no reajuste do contrato " + AllTrim(cContrato),"Atenção!")		
	
	if MsgYesNo("Deseja continuar reajustando os contratos?")
		lOK := .T.		
	endif
	
endif

RestArea(aAreaSE1)
RestArea(aArea)

Return(lOK)
/*/{Protheus.doc} GravaHistorico
//TODO Função que grava o histórico do reajuste
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param cContrato 	- Codigo do Contrato
@param cIndice	 	- Codigo do Indice de Reajuste
@param nIndice	 	- Percentual de Reajuste
@param cProxReaj	- Ano e mes do proximo reajuste
@param nValAdic	 	- Valor Adicionado as parcelas
@param aDados	 	- Titulos gerados pelo reajuste do contrato 
@return lOk - Processado com sucesso
@type function
/*/
Static Function GravaHistorico(cContrato,cIndice,nIndice,cProxReaj,nValAdic,aDados)

Local oAux
Local oStruct
Local cMaster 		:= "UF7"
Local cDetail		:= "UF8"
Local aCpoMaster	:= {}
Local aLinha		:= {}
Local aCpoDetail	:= {}
Local oModel  		:= FWLoadModel("RFUNA011") // instanciamento do modelo de dados
Local nX			:= 1
Local nI       		:= 0
Local nJ       		:= 0
Local nPos     		:= 0
Local lRet     		:= .T.
Local aAux	   		:= {}
Local nItErro  		:= 0
Local lAux     		:= .T.
Local cItem 		:= PADL("1",TamSX3("UF8_ITEM")[1],"0")

aadd(aCpoMaster,{"UF7_FILIAL"	, xFilial("UF7")	})
aadd(aCpoMaster,{"UF7_DATA"		, dDataBase			})
aadd(aCpoMaster,{"UF7_CONTRA"	, cContrato			})
aadd(aCpoMaster,{"UF7_INDICE"	, nIndice			})
aadd(aCpoMaster,{"UF7_PROREA"	, cProxReaj			})
aadd(aCpoMaster,{"UF7_VLADIC"	, nValAdic			})
aadd(aCpoMaster,{"UF7_TPINDI"	, cIndice			})

For nX := 1 To Len(aDados)
		
	aLinha := {}
		
	aadd(aLinha,{"UF8_FILIAL"	, xFilial("UF8")	})
	aadd(aLinha,{"UF8_ITEM"		, cItem				})
	aadd(aLinha,{"UF8_PREFIX"	, aDados[nX,1]		})
	aadd(aLinha,{"UF8_NUM"		, aDados[nX,2]		})
	aadd(aLinha,{"UF8_PARCEL"	, aDados[nX,3]		})
	aadd(aLinha,{"UF8_TIPO"		, aDados[nX,4]		})
	aadd(aLinha,{"UF8_VALOR"	, aDados[nX,5]		})
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
		//FreeObj(oModel)
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

/*/{Protheus.doc} BuscaIndice
//TODO Função que calcula a média do índice	e
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param cIndice	 	- Codigo do Indice de Reajuste
@return lOk - Processado com sucesso
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
cQry += " AND U22.U22_STATUS = 'A' " 															+ cPulaLinha

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

/*/{Protheus.doc} AjustaSX1
//TODO Função que cria as perguntas na SX1
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param cPerg - Codigo da Pergunta na SX1
@return Sem Retorno
@type function
/*/

Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relatório

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

//////////// Contrato ///////////////

U_xPutSX1( cPerg, "01","Contrato De?","Contrato De?","Contrato De?","cContratoDe","C",6,0,0,"G","","UF2ESP","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "02","Contrato Ate?","Contrato Ate?","Contrato Ate?","cContratoAte","C",6,0,0,"G","","UF2ESP","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

///////////// Plano /////////////////

U_xPutSX1( cPerg, "03","Plano?","Plano?","Plano?","cPlano","C",99,0,0,"G","","UF0MRK","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// Índice ///////////////

U_xPutSX1( cPerg, "04","Índice?","Índice?","Índice?","cIndice","C",3,0,0,"G","","U22","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return()

/*/{Protheus.doc} RetParcela
//TODO Função que retorna a próxima parcela do título a ser utilizada
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param cFilSE1	 	- Filial do Contrato
@param cPrefixo		- Prefixo dos Titulos de Contrato
@param cNumero		- Numero dos Titulos do Contrato
@param cTipo		- Tipo de Titulo de Parcelas

@return lOk - Processado com sucesso
@type function
/*/

Static Function RetParcela(cFilSE1,cPrefixo,cNumero,cTipo)

Local cRet 			:= ""
Local cQry			:= ""
Local aArea			:= GetArea()
Local cPulaLinha	:= chr(13)+chr(10) 

// verifico se não existe este alias criado
If Select("QRYSE1") > 0
	QRYSE1->(DbCloseArea())
EndIf     

cQry := " SELECT "											+ cPulaLinha
cQry += " MAX(SE1.E1_PARCELA) AS ULTIMA_PARCELA "			+ cPulaLinha
cQry += " FROM " 											+ cPulaLinha
cQry += " " + RetSqlName("SE1") + " SE1 " 					+ cPulaLinha
cQry += " WHERE " 											+ cPulaLinha
cQry += " SE1.D_E_L_E_T_ <> '*' " 							+ cPulaLinha
cQry += " AND SE1.E1_FILIAL = '" + cFilSE1 + "' "			+ cPulaLinha
cQry += " AND SE1.E1_PREFIXO = '" + cPrefixo + "' " 		+ cPulaLinha
cQry += " AND SE1.E1_XCTRFUN = '" + cNumero + "' " 			+ cPulaLinha
cQry += " AND SE1.E1_TIPO = '" + cTipo + "' " 				+ cPulaLinha
cQry += " AND ( SE1.E1_PARCELA < '900' OR E1_XIMP = ' ' )"	+ cPulaLinha	

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRYSE1" // Cria uma nova area com o resultado do query   

// se existir títulos com este tipo
if QRYSE1->(!Eof()) .AND. !Empty(QRYSE1->ULTIMA_PARCELA)
	cRet := Soma1(QRYSE1->ULTIMA_PARCELA)	
else
	cRet := Padl("1",TamSX3("E1_PARCELA")[1],"0")		
endif

// fecho o alias temporario criado
If Select("QRYSE1") > 0
	QRYSE1->(DbCloseArea())
EndIf 

RestArea(aArea)

Return(cRet) 