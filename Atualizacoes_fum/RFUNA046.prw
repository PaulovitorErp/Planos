#include "protheus.ch" 
#include "tbiconn.ch"
#include "topconn.ch"
#include "fwmvcdef.ch"


/*/{Protheus.doc} RFUNA046
Rotina para  inclusao de um novo ciclo de cobranca convalescente
@author TOTVS
@since 04/06/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RFUNA046()

Local aArea 	:= GetArea()
Local aAreaUF2		:= UF2->(GetArea())
Local aAreaUJH		:= UJH->(GetArea())
Local cPerg 		:= "RFUNA046"
Local cContratoDe	:= ""
Local cContratoAte	:= ""
Local cConvalDe		:= ""
Local cConvalAte 	:= ""
Local lContinua		:= .T.

// cria as perguntas na SX1
AjustaSx1(cPerg)

// enquanto o usuário não cancelar a tela de perguntas
While lContinua
	
	// chama a tela de perguntas
	lContinua := Pergunte(cPerg,.T.)
	
	if lContinua 
	
		cContratoDe 	:= MV_PAR01
		cContratoAte	:= MV_PAR02 
		cConvalDe 		:= MV_PAR03
        cConvalAte   	:= MV_PAR04
 
		if ValidParam(cContratoDe,cContratoAte,cConvalDe,cConvalAte) 
					
			MsAguarde( {|| ConsultaCTR(cContratoDe,cContratoAte,cConvalDe,cConvalAte)}, "Aguarde", "Consultando os contratos de convalescencia...", .F. )
		
		endif
		
	endif
	
EndDo

RestArea(aAreaUF2)
RestArea(aArea)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ ValidParam º Autor ³ Leandro Rodrigues    	   º Data³ 02/08/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que valida os parâmetros informados.						  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Vale do Cerrado                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ValidParam(cContratoDe,cContratoAte,cConvalDe,cConvalAte) 

Local lRet 	:= .T.

// verifico se foram preenchidos todos os parâmetros
if Empty(cContratoDe) .AND. Empty(cContratoAte) 
	Alert("Informe o intervalo dos contratos!")
elseif Empty(cConvalDe) .AND. Empty(cConvalAte) 
	Alert("Informe o intervalo dos codigos Convalescencia!")
endif


Return(lRet) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ ConsultaCTR º Autor ³ Leandro Rodrigues  	   º Data³ 02/08/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que consulta os contratos aptos a serem reajustados		  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Vale do Cerrado                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ConsultaCTR(cContratoDe,cContratoAte,cConvalDe,cConvalAte)

Local aButtons	:= {}
Local aObjects 	:= {}
Local aSizeAut	:= MsAdvSize()
Local aInfo		:= {}
Local aPosObj	:= {}
Local oGrid

Static oDlg

//Largura, Altura, Modifica largura, Modifica altura
aAdd( aObjects, { 100,	100, .T., .T. } ) //Browse

aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE "Contratos Convalescencia a reajustar" From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] COLORS 0, 16777215 PIXEL

EnchoiceBar(oDlg, {|| ConfirmaReajuste(oGrid)},{|| oDlg:End()},,aButtons)

// crio o grid de contratos
oGrid := MsGridCTR(aPosObj)

// duplo clique no grid
oGrid:oBrowse:bLDblClick := {|| DuoClique(oGrid)}

// Colorir linhas com reajustes negativos
oGrid:oBrowse:lUseDefaultColors := .F.
oGrid:oBrowse:SetBlkBackColor( {|| CorLinha(oGrid)} )
oGrid:oBrowse:SetBlkColor( {|| CorTexto(oGrid)} )

// caso não tenha encontrato títulos
if !RefreshGrid(oGrid,cContratoDe,cContratoAte,cConvalDe,cConvalAte)
	
	Alert("Não foram encontrados contratos para serem reajustados!")
	oDlg:End()
	
endif

ACTIVATE MSDIALOG oDlg CENTERED

Return() 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ MsGridCTR º Autor ³ Leandro Rodrigues	   		 Data³ 02/08/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que cria o grid de contratos								  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Vale do Cerrado                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function MsGridCTR(aPosObj)

Local nX			:= 1
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {"MARK","CONTRATO","CONVALESCENTE","CLIENTE","LOJA","NOME","VALOR_CONTRATO","PARCELAS_RESTANTES","REAJUSTE","VALOR_TOTAL"}
Local aAlterFields 	:= {}

For nX := 1 To Len(aFields)
	
	if aFields[nX] == "MARK" 
		Aadd(aHeaderEx, {"","MARK","@BMP",2,0,"","€€€€€€€€€€€€€€","C","","","",""})
		
	elseif aFields[nX] == "CONTRATO"
		Aadd(aHeaderEx, {"Contrato","CONTRATO","@!",6,0,"","€€€€€€€€€€€€€€","C","","","",""})
		
	elseif aFields[nX] == "CONVALESCENTE"
		Aadd(aHeaderEx, {"Convalescencia","CONVALESCENTE","@R 999999",6,0,"","€€€€€€€€€€€€€€","C","","","",""})
		
	elseif aFields[nX] == "NOME"
		Aadd(aHeaderEx, {"Nome","NOME",PesqPict("SA1","A1_NOME"),TamSX3("A1_NOME")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
		
	elseif aFields[nX] == "CLIENTE"
		Aadd(aHeaderEx, {"Cliente","CLIENTE","@!",TamSX3("UF2_CLIENT")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
		
	elseif aFields[nX] == "LOJA"
		Aadd(aHeaderEx, {"Loja","LOJA","@!",TamSX3("UF2_LOJA")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
		
	elseif aFields[nX] == "VALOR_CONTRATO"
		Aadd(aHeaderEx, {"Valor Contrato","VALOR_CTR",PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1],TamSX3("E1_VALOR")[2],"","€€€€€€€€€€€€€€","N","","","",""})
		
	elseif aFields[nX] == "PARCELAS_RESTANTES"
		Aadd(aHeaderEx, {"Parcelas Restantes","PARCELAS_RESTANTES","@!",TamSX3("E1_PARCELA")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})		
	
	elseif aFields[nX] == "REAJUSTE"
		Aadd(aHeaderEx, {"Valor do Reajuste","REAJUSTE",PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1],TamSX3("E1_VALOR")[2],"","€€€€€€€€€€€€€€","N","","","",""})

	elseif aFields[nX] == "VALOR_TOTAL"
		Aadd(aHeaderEx, {"Valor Total","VALOR_TOTAL",PesqPict("SE1","E1_VALOR"),TamSX3("E1_VALOR")[1],TamSX3("E1_VALOR")[2],"","€€€€€€€€€€€€€€","N","","","",""})		
	
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

Return(MsNewGetDados():New( aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ RefreshGrid º Autor ³ Leandro Rodrigues   		 Data³ 15/04/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função atualiza o grid de contratos								  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Vale do Cerrado                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function RefreshGrid(oGrid,cContratoDe,cContratoAte,cConvalDe,cConvalAte)

Local lRet				:= .F.
Local cQry 				:= ""
Local aFieldFill		:= {}
Local nValorAdicional	:= 0     
Local cPulaLinha		:= chr(13)+chr(10)   


// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

cQry := " SELECT"
cQry += " UF2.UF2_CODIGO 				AS CONTRATO, "
cQry += " UJH.UJH_CODIGO 				AS CONVALESCENTE, "
cQry += " UF2.UF2_CLIENT	 			AS CLIENTE, "
cQry += " UF2.UF2_LOJA  				AS LOJA, "
cQry += " SA1.A1_NOME 					AS NOME, "
cQry += " UJH.UJH_VALCON	 			AS VALOR_CONTRATADO, "
cQry += " SUM(QUANTIDADE * PRECOVENDA) 	AS VALOR_REAJUSTADO, "
cQry += " PARCELAS.QTD_PARCELAS			AS QTD_PARCELAS "

cQry += " FROM " 
cQry += RetSQLName("UF2")+ " UF2 "

cQry += " INNER JOIN " 
cQry += RetSQLName("UJH") + " UJH "
cQry += " ON UJH_FILIAL 	= '" + xFilial("UJH") + "' "
cQry += " AND UJH.D_E_L_E_T_ <> '*' "
cQry += " AND UJH_CONTRA	= UF2_CODIGO"
cQry += " AND UJH_STATUS IN ('L','P') "

cQry += " INNER JOIN " 
cQry += + RetSQLName("SA1")   + " SA1 "
cQry += " ON A1_FILIAL 			= '" + xFilial("SA1") + "'"
cQry += " AND SA1.A1_COD 		= UF2.UF2_CLIENT"
cQry += " AND SA1.A1_LOJA		= UF2.UF2_LOJA"
cQry += " AND SA1.D_E_L_E_T_	= ' '"
cQry += " LEFT JOIN"
cQry += " ("
cQry += " 	SELECT"
cQry += " 	COUNT(*) AS QTD_PARCELAS,"
cQry += "   SE1.E1_XCONCTR CONVALESCENTE,"
cQry += "   SE1.E1_XCTRFUN CONTRATO_FUN"
cQry += " 	FROM " + RetSQLName("SE1") + " SE1"
cQry += " 	WHERE SE1.D_E_L_E_T_ <> '*'"
cQry += " 		AND SE1.E1_FILIAL = '" + xFilial("SE1") + "'"
cQry += " 		AND SE1.E1_SALDO  > 0"
cQry += " 		AND SE1.E1_XCTRFUN <> ' '"
cQry += " 		AND SE1.E1_XCONCTR <> ' ' "
cQry += " 	GROUP BY SE1.E1_XCTRFUN,SE1.E1_XCONCTR   ) AS PARCELAS"
cQry += " ON PARCELAS.CONTRATO_FUN = UF2_CODIGO"
cQry += " AND PARCELAS.CONVALESCENTE = UJH.UJH_CODIGO "
cQry += " LEFT JOIN" 
cQry += "  ( SELECT"
cQry += " 		UJI.UJI_VLTOTA VALORTOTAL,"
cQry += " 		UJI.UJI_CODIGO CODIGO,
cQry += " 		UJI.UJI_QUANT QUANTIDADE,"
cQry += " 		(	SELECT"
cQry += " 				DA1.DA1_PRCVEN"
cQry += " 			FROM " + RetSQLName("DA1") + " DA1"
cQry += " 			WHERE DA1.D_E_L_E_T_ = ' '"
cQry += " 				AND DA1.DA1_FILIAL = '" + xFilial("DA1") + "'"
cQry += " 				AND DA1.DA1_DATVIG < '" + dTos(dDataBase) + "'"
cQry += " 				AND DA1.DA1_CODPRO = SN1.N1_PRODUTO"
cQry += " 				AND DA1.DA1_CODTAB = XUJH.UJH_TABPRC"
cQry += " 			GROUP BY DA1.DA1_PRCVEN) AS PRECOVENDA"
cQry += " 			FROM " + RetSQLName("UJI") + " UJI"
cQry += " 			INNER JOIN " + RetSQLName("UJH") + " XUJH"
cQry += " 			ON XUJH.UJH_FILIAL      = UJI.UJI_FILIAL"
cQry += " 				AND XUJH.UJH_CODIGO = UJI.UJI_CODIGO"
cQry += " 				AND XUJH.D_E_L_E_T_ =' '"
cQry += " 				AND XUJH.UJH_STATUS IN ('L','P') "
cQry += " 			INNER JOIN " + RetSQLName("SN1") + " SN1"
cQry += " 			ON  SN1.N1_FILIAL = SN1.N1_FILIAL"
cQry += " 				AND SN1.N1_CHAPA  = UJI.UJI_CHAPA"
cQry += " 				AND SN1.D_E_L_E_T_ = ' '"
cQry += "		WHERE UJI.D_E_L_E_T_ <> '*'"
cQry += "		AND UJI.UJI_FILIAL = '" + xFilial("UJI") + "' "
cQry += " 		AND UJI.UJI_DATARE = ' ' ) PRECOVENDA"
cQry += " 	ON PRECOVENDA.CODIGO  = UJH.UJH_CODIGO"
cQry += " WHERE UF2.D_E_L_E_T_ <> '*'"
cQry += " 	 AND UF2.UF2_FILIAL = '" + xFilial("UF2") + "'"
cQry += " 	 AND UF2.UF2_STATUS IN ('A')"
cQry += " 	 AND UF2.UF2_DTATIV <> ' '"
cQry += " 	 AND UF2.UF2_CODIGO BETWEEN '"+ cContratoDe  +"' AND '" + cContratoAte  + "'"
cQry += " 	 AND UJH.UJH_CODIGO BETWEEN '"+ cConvalDe 	 +"' AND '" + cConvalAte 	+ "'"

//Gera novo ciclo de parcelas quando faltar 6 parcelas a pagar
cQry += " 	AND ISNULL(QTD_PARCELAS,0) <= " + cValtoChar(SuperGetMv("MV_XREJPAR",,6))

cQry += " GROUP BY UF2.UF2_CODIGO,UJH.UJH_CODIGO,UF2.UF2_CLIENT,UF2.UF2_LOJA,SA1.A1_NOME,UJH.UJH_VALCON,PARCELAS.QTD_PARCELAS"

 MemoWrite("C:\Temp\Reajuste_convalescencia.txt",cQry)

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
		 		
		aadd(aFieldFill, "CHECKED"										)		
		aadd(aFieldFill, QRY->CONTRATO									)
		aadd(aFieldFill, QRY->CONVALESCENTE								)
		aadd(aFieldFill, QRY->CLIENTE									)
		aadd(aFieldFill, QRY->LOJA										)
		aadd(aFieldFill, QRY->NOME										)
		aadd(aFieldFill, QRY->VALOR_CONTRATADO							)
		aadd(aFieldFill, QRY->QTD_PARCELAS								)
		aadd(aFieldFill, QRY->VALOR_REAJUSTADO - QRY->VALOR_CONTRATADO	)
		aadd(aFieldFill, QRY->VALOR_REAJUSTADO							)
		Aadd(aFieldFill, .F.)
		aadd(oGrid:Acols,aFieldFill) 
			
		QRY->(DbSkip()) 
		
	EndDo
	
	oGrid:oBrowse:Refresh() 
		
endif

// fecho o alias temporario criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ DuoClique º Autor ³ Leandro Rodrigues		   º Data³ 15/04/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função chamada no duplo clique no grid							  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Vale do Cerrado                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function DuoClique(oGrid)

if oGrid:aCols[oGrid:oBrowse:nAt][1] == "CHECKED"
	oGrid:aCols[oGrid:oBrowse:nAt][1] := "UNCHECKED"
else
	oGrid:aCols[oGrid:oBrowse:nAt][1] := "CHECKED"
endif

oGrid:oBrowse:Refresh()

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ ConfirmaReajuste º Autor ³ Wellington Gonçalves º Data³ 02/08/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função chamada na confirmação da tela							  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Vale do Cerrado                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ConfirmaReajuste(oGrid,cIndice,nIndice)

Local lContinua	:= .T.
Local nX		:= 1
Local aArea		:= GetArea()
Local aAreaUF2	:= UF2->(GetArea())
Local nPosCtr	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CONTRATO"				})
Local nPosConv	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CONVALESCENTE"		})
Local nPosCli	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CLIENTE"				})
Local nPosLoja	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "LOJA"					})
Local nPosNome	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "NOME"					})
Local nPosVlAdi	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "REAJUSTE"				})
Local nPosVlTot	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "VALOR_TOTAL"			})
Local nPosParc	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "PARCELAS_RESTANTES"	})
Local nValParc  := 0
Local cContrato	:= ""
Local cConvales	:= ""
Local cCliente	:= ""
Local cLoja		:= ""
Local cPrefixo 	:= SuperGetMv("MV_XPRFCON",,"CVL")   // prefixo do título
Local cTipo		:= SuperGetMv("MV_XTIPOCV",,"EQ")    // tipo do título
Local cNatureza	:= &(SuperGetMV("MV_NATCONV"))       // natureza financeira


if Empty(cPrefixo)
	MsgAlert("Não foi informado o prefixo do título no parâmetro 'MV_XPRFCON'. ")

elseif Empty(cTipo)
	MsgAlert("Não foi informado o tipo do título no parâmetro 'MV_XTIPOCV'. ")

elseif Empty(cNatureza)
	MsgAlert("Não foi informada a natureza no parametro MV_NATCONV. ")
	
else

	if MsgYesNo("Deseja executar o reajuste dos contratos Convalescencia? ")
	
		// percorro todo o grid
		For nX := 1 To Len(oGrid:aCols)
		
			// se a linha estiver marcada
			if oGrid:aCols[nX][1] == "CHECKED"
			
				// se o Convalescencia estiver preenchido
				if !Empty(oGrid:aCols[nX][nPosConv])

					//-- Verifica se reajuste tem valor positivo
					If oGrid:aCols[nX][nPosVlAdi] >= 0
				
						UJH->(DbSetOrder(1)) // UJH_FILIAL + UJH_CODIGO
						if UJH->(DbSeek(xFilial("UJH") + oGrid:aCols[nX][nPosConv]))
						
							cContrato 		:= oGrid:aCols[nX][nPosCtr]	
							cConvales	 	:= oGrid:aCols[nX][nPosConv]	
					
							//Busco ultimo titulo para gerar proximas parcelas
							nRecSE1 := UltimoTitulo(cPrefixo,cContrato,cConvales,cTipo)
																					
							cCliente	:= oGrid:aCols[nX][nPosCli]
							cLoja		:= oGrid:aCols[nX][nPosLoja]  
							cNome		:= oGrid:aCols[nX][nPosNome]
							nValParc	:= oGrid:aCols[nX][nPosVlTot]			
										
							Begin Transaction

							// chamo função do incluir nova parcela	
							FWMsgRun(,{|oSay| lContinua := ProcReajuste(oSay,cContrato,cConvales,cCliente,cLoja,cPrefixo,cTipo,cNatureza,nRecSE1,nValParc)},'Aguarde...','Reajustando os contratos...')
							
							if !lContinua
								DisarmTransaction()
							endif

							End Transaction

							if !lContinua
								Exit
							endif
		
						endif	

					Else
						MsgAlert("Contrato " + AllTrim(oGrid:aCols[nX][nPosCtr]);
							+ " Convalescencia " + AllTrim(oGrid:aCols[nX][nPosConv]);
							+ " está com valor de reajuste inconsistente. Por favor verificar e processar novamente.")
					EndIf

				endif 
			
			endif	
		
		Next nX
		
		if lContinua
			MsgInfo("Processamento concluído!")
		endif
		
		// fecho a janela
		oDlg:End() 
	
	endif

endif

RestArea(aAreaUF2)
RestArea(aArea)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ ProcReajuste º Autor ³Leandro Rodrigues		   º Data³ 02/08/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que faz o processamento do reajuste						  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Vale do Cerrado                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ProcReajuste(oSay,cContrato,cConvales,cCliente,cLoja,cPrefixo,cTipo,cNatureza,nRecSE1,nValParc)

Local aArea 		:= GetArea()
Local aAreaSE1		:= SE1->(GetArea())
Local aHistorico	:= {}
Local cParcela		:= ""
Local cFormaPgto	:= ""
Local dVencimento	:= cTod(" ")
Local nQtdParc		:= SuperGetMv("MV_XPCONVA",,12)
Local nX			:= 1
Local cNomeCliente	:= ""

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

Begin Transaction


//Posiciono no titulo 
SE1->(DbGoTo(nRecSE1))
						
//Data Vencimento Proximo tiulo
dVencimento		:= SE1->E1_VENCTO 
cParcela		:= SE1->E1_PARCELA
cFormaPgto		:= SE1->E1_XFORPG
cNomeCliente	:= SE1->E1_NOMCLI

For nX := 1 To nQtdParc

	dVencimento := DataValida(MonthSum(dVencimento,1)) 
	cParcela	:= Soma1(cParcela)
			
	aDados 		:= {}
	lMsErroAuto	:= .F.	
	
	oSay:cCaption := ("Convalescente: " + AllTrim(cConvales) + ", gerando parcela " + cParcela + ", vencimento " + DTOC(dVencimento) + " ...")

	ProcessMessages()
	
	AAdd(aDados, {"E1_FILIAL"	, xFilial("SE1")							, Nil } )
	AAdd(aDados, {"E1_PREFIXO"	, cPrefixo          						, Nil } )
	AAdd(aDados, {"E1_NUM"		, cConvales		 	   						, Nil } )
	AAdd(aDados, {"E1_PARCELA"	, cParcela									, Nil } )
	AAdd(aDados, {"E1_TIPO"		, cTipo		 								, Nil } )
	AAdd(aDados, {"E1_NATUREZ"	, cNatureza									, Nil } )
	AAdd(aDados, {"E1_CLIENTE"	, cCliente									, Nil } )
	AAdd(aDados, {"E1_LOJA"		, cLoja										, Nil } )
	AAdd(aDados, {"E1_EMISSAO"	, dDataBase									, Nil } )
	AAdd(aDados, {"E1_VENCTO"	, dVencimento								, Nil } )
	AAdd(aDados, {"E1_VENCREA"	, dVencimento								, Nil } )
	AAdd(aDados, {"E1_VALOR"	, nValParc									, Nil } )			
	AAdd(aDados, {"E1_XCTRFUN"	, cContrato									, Nil } )
	AAdd(aDados, {"E1_XFORPG"	, cFormaPgto								, Nil } )
	AAdd(aDados, {"E1_XPARCON"	, cParcela + "/" + StrZero(nQtdParc,3) 		, Nil } )
	AAdd(aDados, {"E1_XCONCTR"	, cConvales									, Nil } )
	AAdd(aDados, {"E1_NOMCLI"	, cNomeCliente								, Nil } )
			
	MSExecAuto({|x,y| FINA040(x,y)},aDados,3)
			
	if lMsErroAuto
		MostraErro()
		DisarmTransaction()	
		lOK := .F.
		Exit
	else
		// array de historico de manutenção
		AAdd(aHistorico,{cPrefixo,cConvales,cParcela,cTipo,nValParc})
		
		lOK := .T.
	endif

Next nX

End Transaction 

if lOK
	
	lOK := GravaHistorico(cContrato,aHistorico,cConvales)

Else

	MsgAlert("Ocorreu um problema ao gerar as parcelas do novo clico do Convalescente " + AllTrim(cContrato),"Atenção!")		
	
	if MsgYesNo("Deseja continuar gerando as parcelas para os demais contratos de Convalescencia?")
		lOK := .T.		
	endif
	
endif

RestArea(aAreaSE1)
RestArea(aArea)

Return(lOK)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ AjustaSX1 º Autor ³ Leandro Rodrigues		   º Data³ 02/08/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que cria as perguntas na SX1.								  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Vale do Cerrado                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relatório

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

//////////// Contrato ///////////////

U_xPutSX1( cPerg, "01","Contrato De?","Contrato De?","Contrato De?","mv_ch1","C",6,0,0,"G","","UF2ESP","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "02","Contrato Ate?","Contrato Ate?","Contrato Ate?","mv_ch2","C",6,0,0,"G","","UF2ESP","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

///////////// Codigo Convalescencia /////////////////

U_xPutSX1( cPerg, "03","Convalescente De?" ,"Convalescente De?" ,"Convalescente De?" ,"mv_ch3","C",6,0,0,"G","","UJH","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "04","Convalescente Ate?","Convalescente Ate?","Convalescente Ate?","mv_ch4","C",6,0,0,"G","","UJH","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)


Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ RetParcela º Autor ³ Wellington Gonçalves	   º Data³ 02/08/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que retorna a próxima parcela do título a ser utilizada	  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Vale do Cerrado                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function UltimoTitulo(cPrefixo,cContrato,cConvales,cTipo)

Local cRet 			:= ""
Local cQry			:= ""
Local aArea			:= GetArea()
Local cPulaLinha	:= chr(13)+chr(10) 

// verifico se não existe este alias criado
If Select("QRYSE1") > 0
	QRYSE1->(DbCloseArea())
EndIf     

cQry := " SELECT"
cQry += " 	MAX(R_E_C_N_O_) RECNOE1""
cQry += " FROM " + RETSQLNAME("SE1") + " E1"
cQry += " WHERE E1.D_E_L_E_T_ = ' '""
cQry += " AND E1_FILIAL		= '" + xFilial("SE1") 	+"'"
cQry += " AND E1_XCTRFUN 	= '" + cContrato 		+"'"
cQry += " AND E1_XCONCTR	= '" + cConvales 		+"'"
cQry += " AND E1_TIPO 		= '" + cTipo	 		+"'"


// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

// fecho o alias temporario criado
If Select("QRYSE1") > 0
	QRYSE1->(DbCloseArea())
EndIf 

// crio o alias temporario
TcQuery cQry New Alias "QRYSE1" // Cria uma nova area com o resultado do query   

RestArea(aArea)

Return QRYSE1->RECNOE1


/*/{Protheus.doc} GravaHistorico
//TODO Função que grava o histórico do reajuste
@author Leandro Rodrigues
@since 10/05/2019
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

Static Function GravaHistorico(cContrato,aDados,cConvales)

Local oAux
Local oStruct
Local cMaster 		:= "UJP"
Local cDetail		:= "UJQ"
Local aCpoMaster	:= {}
Local aLinha		:= {}
Local aCpoDetail	:= {}
Local oModel  		:= FWLoadModel("RFUNA047") // instanciamento do modelo de dados
Local nX			:= 1
Local nI       		:= 0
Local nJ       		:= 0
Local nPos     		:= 0
Local lRet     		:= .T.
Local aAux	   		:= {}
Local nItErro  		:= 0
Local lAux     		:= .T.
Local cItem 		:= PADL("1",TamSX3("UJQ_ITEM")[1],"0")
Local nQtdParcela	:= SuperGetMv("MV_XPCONVA",,12)  					//Quantidade de parcelas que deverão ser geradas
Local nQdParRest	:= SuperGetMv("MV_XREJPAR",,6)	 					//quando faltar 'X' Parcelas a pagar gera novo ciclo
Local dDataProx		:= MonthSum( dDatabase , nQtdParcela - nQdParRest ) //Soma Meses em Uma Data		
Local cProxReaj		:= StrZero(Month (dDataProx),2) + cValTochar(YEAR(dDataProx))

SE1->(DbSetorder(1))


aadd(aCpoMaster,{"UJP_FILIAL"	, xFilial("UJP")	})
aadd(aCpoMaster,{"UJP_DATA"		, dDataBase			})
aadd(aCpoMaster,{"UJP_CONTRA"	, cContrato			})
aadd(aCpoMaster,{"UJP_CODCON"	, cConvales			})
aadd(aCpoMaster,{"UJP_PROCIC"	, cProxReaj			})


For nX := 1 To Len(aDados)
		
	aLinha := {}
		
	aadd(aLinha,{"UJQ_FILIAL"	, xFilial("UJQ")	})
	aadd(aLinha,{"UJQ_ITEM"		, cItem				})
	aadd(aLinha,{"UJQ_PREFIX"	, aDados[nX,1]		})
	aadd(aLinha,{"UJQ_NUM"		, aDados[nX,2]		})
	aadd(aLinha,{"UJQ_PARCEL"	, aDados[nX,3]		})
	aadd(aLinha,{"UJQ_TIPO"		, aDados[nX,4]		})
	aadd(aLinha,{"UJQ_VALOR"	, aDados[nX,5]		})
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

/*/{Protheus.doc} CorLinha
Funcao para altera cor da linha
@type function
@version 1.0
@author nata.queiroz
@since 20/02/2020
@param oGrid, object
@return nCor, numeric
/*/
Static Function CorLinha(oGrid)
	Local nCor := RGB(240, 240, 240) //-- Orange claro
	Local nPosReaj := aScan(oGrid:aHeader, {|x| AllTrim(x[2])=="REAJUSTE"})

	If oGrid:aCols[oGrid:nAt][nPosReaj] < 0
		nCor := RGB(128, 0, 0) //-- Vermelho
	EndIf

Return nCor

/*/{Protheus.doc} CorTexto
Funcao para alterar cor do texto
@type function
@version 1.0
@author nata.queiroz
@since 20/02/2020
@param oGrid, object
@return nCor, numeric
/*/
Static Function CorTexto(oGrid)
	Local nCor := RGB(0, 0, 0) //-- Preto
	Local nPosReaj := aScan(oGrid:aHeader, {|x| AllTrim(x[2])=="REAJUSTE"})

	If oGrid:aCols[oGrid:nAt][nPosReaj] < 0
		nCor := RGB(255, 255, 255) //-- Branco
	EndIf

Return nCor
