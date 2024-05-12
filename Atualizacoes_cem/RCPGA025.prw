#Include 'Protheus.ch'
#include "topconn.ch" 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ RCPGA025 บ Autor ณ Wellington Gon็alves         บ Dataณ 08/06/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Tela para consulta de sepultados									  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function RCPGA025()
                    
Local oBtn1
Local oBtn2
Local oBtn3
Local oBtn4
Local oGet1
Local oGet2
Local oGet3
Local oGet4
Local oGroup1
Local oGroup2
Local oGroup3
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local cGet1 	:= Space(TamSX3("U04_QUEMUT")[1])
Local cGet2 	:= CTOD("  /  /    ")
Local cGet3 	:= Space(TamSX3("U00_NOMCLI")[1])
Local cGet4 	:= Space(TamSX3("U00_CGC")[1])
Local aRetorno	:= Array(4)
Local oGridSepult
Static oDlg

DEFINE MSDIALOG oDlg TITLE "Localiza็ใo de jazigos" FROM 000, 000  TO 430, 600 COLORS 0, 16777215 PIXEL

@ 005, 005 GROUP oGroup1 TO 045, 297 PROMPT "  Filtros - Sepultamento  " OF oDlg COLOR 0, 16777215 PIXEL

@ 014, 015 SAY oSay5 PROMPT "Nome do sepultado:" SIZE 054, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 024, 015 MSGET oGet1 VAR cGet1 SIZE 195, 010 OF oDlg COLORS 0, 16777215 PIXEL

@ 014, 220 SAY oSay6 PROMPT "Data de sepultamento:" SIZE 063, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 024, 220 MSGET oGet2 VAR cGet2 SIZE 067, 010 OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON

@ 050, 005 GROUP oGroup2 TO 090, 297 PROMPT "  Filtros - Contrato" OF oDlg COLOR 0, 16777215 PIXEL

@ 060, 015 SAY oSay7 PROMPT "Nome do contratante:" SIZE 061, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 070, 015 MSGET oGet3 VAR cGet3 SIZE 195, 010 OF oDlg COLORS 0, 16777215 PIXEL

@ 060, 220 SAY oSay8 PROMPT "CPF/CNPJ:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 070, 220 MSGET oGet4 VAR cGet4 SIZE 067, 010 OF oDlg COLORS 0, 16777215 PIXEL

@ 095, 259 BUTTON oBtn1 PROMPT "Consultar" SIZE 037, 012 OF oDlg ACTION(MsAguarde( {|| AtuGrid(oGridSepult,cGet1,cGet2,cGet3,cGet4)}, "Aguarde", "Consultando registros...", .F. )) PIXEL
@ 095, 215 BUTTON oBtn2 PROMPT "Limpar" SIZE 037, 012 OF oDlg ACTION(LimpaCPO(@cGet1,@cGet2,@cGet3,@cGet4,oGet1,oGet2,oGet3,oGet4),MsAguarde( {|| AtuGrid(oGridSepult,cGet1,cGet2,cGet3,cGet4)}, "Aguarde", "Consultando registros...", .F. )) PIXEL

oGridSepult := GridSepult()

@ 111, 005 GROUP oGroup3 TO 112, 297 OF oDlg COLOR 0, 16777215 PIXEL

@ 197, 259 BUTTON oBtn3 PROMPT "Confirmar" SIZE 037, 012 OF oDlg ACTION(iif(Confirmar(oGridSepult,aRetorno) , oDlg:End() , aRetorno := Array(4) )) PIXEL
@ 197, 215 BUTTON oBtn4 PROMPT "Cancelar" SIZE 037, 012 OF oDlg ACTION(oDlg:End()) PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Return(aRetorno)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ GridSepult บ Autor ณ Wellington Gon็alves	   บ Dataณ 10/06/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que cria o grid de hist๓rico de sepultamento				  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
 
Static Function GridSepult()

Local nX			:= 1
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {"U04_CODIGO","U04_QUADRA","U04_MODULO","U04_JAZIGO","U04_GAVETA","U04_DTUTIL","U04_QUEMUT"}
Local aAlterFields 	:= {}
Local oGrid
Local oSX3			:= UGetSxFile():New
Local aSX3			:= {}

For nX := 1 to Len(aFields)

	aSX3 := oSX3:GetInfoSX3(,aFields[nX])

		If Len(aSX3) > 0
			Aadd(aHeaderEx, {aSX3[1,2]:cTITULO,aSX3[1,2]:cCAMPO,aSX3[1,2]:cPICTURE,aSX3[1,2]:nTAMANHO,aSX3[1,2]:nDECIMAL,aSX3[1,2]:cVALID,;
			aSX3[1,2]:cUSADO,aSX3[1,2]:cTIPO,aSX3[1,2]:cF3,aSX3[1,2]:cCONTEXT,aSX3[1,2]:cCBOX,aSX3[1,2]:cRELACAO})
		
			Aadd(aFieldFill, CriaVar(aSX3[1,2]:cCAMPO))
		Endif
	
Next nX

Aadd(aFieldFill, .F.)
Aadd(aColsEx, aFieldFill)

oGrid := MsNewGetDados():New( 117, 005, 192, 297,GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return(oGrid)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ AtuGrid บ Autor ณ Wellington Gon็alves	 		 Dataณ 24/03/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que atualiza o grid com o status das gavetas				  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function AtuGrid(oGrid,cNomeSepult,dDataSepult,cNomeContratante,cCGC)

Local cQry 			:= ""
Local aFieldFill	:= {}   
Local cPulaLinha	:= chr(13)+chr(10)  
Local aAuxAcols		:= {}
Local nY			:= 1
Local nX			:= 1

// tempo para mostrar a mensagem de aguarde
Sleep(1000)

// verifico se nใo existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf    

cQry := " SELECT "																		+ cPulaLinha
cQry += " 'ATUAL' AS TIPO, "															+ cPulaLinha
cQry += " U04_CODIGO AS CONTRATO, "														+ cPulaLinha
cQry += " U04_QUADRA AS QUADRA, "														+ cPulaLinha
cQry += " U04_MODULO AS MODULO, "														+ cPulaLinha
cQry += " U04_JAZIGO AS JAZIGO, "														+ cPulaLinha
cQry += " U04_GAVETA AS GAVETA, "														+ cPulaLinha
cQry += " U04_DTUTIL AS DATA_UTILIZACAO, "												+ cPulaLinha
cQry += " U04_QUEMUT AS NOME_SEPULTADO "												+ cPulaLinha
cQry += " FROM "																		+ cPulaLinha
cQry += + RetSqlName("U04") + " U04 " 													+ cPulaLinha
cQry += " INNER JOIN  "																	+ cPulaLinha
cQry +=   RetSqlName("U00") + " U00 " 													+ cPulaLinha
cQry += " 	INNER JOIN "																+ cPulaLinha
cQry += 	RetSqlName("SA1") + " SA1 "													+ cPulaLinha
cQry += " 		ON ( "																	+ cPulaLinha
cQry += " 			SA1.D_E_L_E_T_ <> '*' "												+ cPulaLinha
cQry += " 			AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "						+ cPulaLinha 
cQry += " 			AND SA1.A1_COD = U00.U00_CLIENT "									+ cPulaLinha
cQry += " 			AND SA1.A1_LOJA = U00.U00_LOJA "									+ cPulaLinha

if !Empty(cNomeContratante)
	cQry += " 			AND SA1.A1_NOME LIKE '%" + AllTrim(cNomeContratante) + "%' "	+ cPulaLinha
endif

if !Empty(cCGC)
	cQry += " 			AND SA1.A1_CGC = '" + AllTrim(cCGC) + "' "						+ cPulaLinha
endif

cQry += " 			) "																	+ cPulaLinha
cQry += " 	ON ( "																		+ cPulaLinha
cQry += " 		U00.D_E_L_E_T_ <> '*' "													+ cPulaLinha
cQry += " 		AND U00.U00_FILIAL = '" + xFilial("U00") + "' "							+ cPulaLinha 
cQry += " 		AND U00.U00_CODIGO = U04.U04_CODIGO "									+ cPulaLinha
cQry += " 		) "																		+ cPulaLinha
cQry += " WHERE "																		+ cPulaLinha
cQry += " U04.D_E_L_E_T_ <> '*' "														+ cPulaLinha
cQry += " AND U04.U04_FILIAL = '" + xFilial("U04") + "' " 								+ cPulaLinha
cQry += " AND (U04.U04_DTUTIL <> ' ' OR U04.U04_PREVIO = 'S') "							+ cPulaLinha

if !Empty(cNomeSepult)
	cQry += " AND U04.U04_QUEMUT LIKE '%" + AllTrim(cNomeSepult) + "%' "				+ cPulaLinha
endif

if !Empty(dDataSepult)
	cQry += " AND U04.U04_DTUTIL = '" + DTOS(dDataSepult) + "' "						+ cPulaLinha
endif

cQry += " UNION " 																		+ cPulaLinha
cQry += " SELECT "																		+ cPulaLinha
cQry += " 'HISTORICO' AS TIPO, "														+ cPulaLinha
cQry += " U30_CODIGO AS CONTRATO, "														+ cPulaLinha
cQry += " U30_QUADRA AS QUADRA, "														+ cPulaLinha
cQry += " U30_MODULO AS MODULO, "														+ cPulaLinha
cQry += " U30_JAZIGO AS JAZIGO, "														+ cPulaLinha
cQry += " U30_GAVETA AS GAVETA, "														+ cPulaLinha
cQry += " U30_DTUTIL AS DATA_UTILIZACAO, "												+ cPulaLinha
cQry += " U30_QUEMUT AS NOME_SEPULTADO "												+ cPulaLinha
cQry += " FROM "																		+ cPulaLinha
cQry += + RetSqlName("U30") + " U30 " 													+ cPulaLinha
cQry += " INNER JOIN "																	+ cPulaLinha 
cQry +=   RetSqlName("U00") + " U00 "													+ cPulaLinha
cQry += " 	INNER JOIN "																+ cPulaLinha
cQry += 	RetSqlName("SA1") + " SA1 "													+ cPulaLinha
cQry += " 		ON ( "																	+ cPulaLinha
cQry += " 			SA1.D_E_L_E_T_ <> '*' "												+ cPulaLinha
cQry += " 			AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "						+ cPulaLinha 
cQry += " 			AND SA1.A1_COD = U00.U00_CLIENT "									+ cPulaLinha
cQry += " 			AND SA1.A1_LOJA = U00.U00_LOJA "									+ cPulaLinha

if !Empty(cNomeContratante)
	cQry += " 			AND SA1.A1_NOME LIKE '%" + AllTrim(cNomeContratante) + "%' "	+ cPulaLinha
endif

if !Empty(cCGC)
	cQry += " 			AND SA1.A1_CGC = '" + AllTrim(cCGC) + "' "						+ cPulaLinha
endif

cQry += " 			) "																	+ cPulaLinha
cQry += " 	ON ( "																		+ cPulaLinha
cQry += " 		U00.D_E_L_E_T_ <> '*' "													+ cPulaLinha
cQry += " 		AND U00.U00_FILIAL = '" + xFilial("U00") + "' "							+ cPulaLinha 
cQry += " 		AND U00.U00_CODIGO = U30.U30_CODIGO "									+ cPulaLinha
cQry += " 		) "																		+ cPulaLinha
cQry += " WHERE "																		+ cPulaLinha
cQry += " U30.D_E_L_E_T_ <> '*' "														+ cPulaLinha
cQry += " AND U30.U30_FILIAL = '" + xFilial("U30") + "' " 								+ cPulaLinha
cQry += " AND U30.U30_DTUTIL <> ' ' " 													+ cPulaLinha

//nao retorno historico de transferencias
cQry += " AND U30.U30_TRANSF <> 'S' "													+ cPulaLinha

if !Empty(cNomeSepult)
	cQry += " AND U30.U30_QUEMUT LIKE  '%" + AllTrim(cNomeSepult) + "%' "				+ cPulaLinha
endif

if !Empty(dDataSepult)
	cQry += " AND U30.U30_DTUTIL = '" + DTOS(dDataSepult) + "' "						+ cPulaLinha
endif

cQry += " ORDER BY DATA_UTILIZACAO DESC,CONTRATO,QUADRA,MODULO,JAZIGO,GAVETA " 			+ cPulaLinha 

// fun็ใo que converte a query gen้rica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

if QRY->(!Eof())

	While QRY->(!Eof())
	
		aFieldFill := {}

		For nY := 1 to Len(oGrid:aHeader)
			
			If oGrid:aHeader[nY,2] == "U04_CODIGO"
				Aadd(aFieldFill , QRY->CONTRATO)
			elseif oGrid:aHeader[nY,2] == "U04_QUADRA"
				Aadd(aFieldFill , QRY->QUADRA)
			elseif oGrid:aHeader[nY,2] == "U04_MODULO"
				Aadd(aFieldFill , QRY->MODULO)
			elseif oGrid:aHeader[nY,2] == "U04_JAZIGO"
				Aadd(aFieldFill , QRY->JAZIGO)
			elseif oGrid:aHeader[nY,2] == "U04_GAVETA"
				Aadd(aFieldFill , QRY->GAVETA)
			elseif oGrid:aHeader[nY,2] == "U04_DTUTIL"
				Aadd(aFieldFill , STOD(QRY->DATA_UTILIZACAO))
			elseif oGrid:aHeader[nY,2] == "U04_QUEMUT"
				Aadd(aFieldFill , QRY->NOME_SEPULTADO)
			Endif
			
		Next nY
		
		aadd(aFieldFill,.F.)
		aadd(aAuxAcols,aFieldFill)
		
		QRY->(DbSkip())
	
	EndDo
	
else

	// crio a primeira linha em branco
	For nX := 1 To Len(oGrid:aHeader)
	
		if oGrid:aHeader[nX,8] == "N"
			Aadd(aFieldFill,0)
		elseif oGrid:aHeader[nX,8] == "D"
			Aadd(aFieldFill,CTOD(""))
		elseif oGrid:aHeader[nX,8] == "L"
			Aadd(aFieldFill,.F.)
		else
			Aadd(aFieldFill,"")
		endif
		
	Next nX
	
	aadd(aFieldFill,.F.)
	aadd(aAuxAcols,aFieldFill)

endif

// atualizo o array do grid
oGrid:aCols := aClone(aAuxAcols)

// fa็o um refresh no grid
oGrid:oBrowse:Refresh() 

If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf  

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ LimpaCPO บ Autor ณ Wellington Gon็alves	   	   บ Dataณ 15/06/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que limpa os campos 										  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function LimpaCPO(cGet1,cGet2,cGet3,cGet4,oGet1,oGet2,oGet3,oGet4)

cGet1 := Space(TamSX3("U04_QUEMUT")[1])
cGet2 := CTOD("  /  /    ")
cGet3 := Space(TamSX3("U00_NOMCLI")[1])
cGet4 := Space(TamSX3("U00_CGC")[1])

oGet1:Refresh()
oGet2:Refresh()
oGet3:Refresh()
oGet4:Refresh()

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ Confirmar บ Autor ณ Wellington Gon็alves	   	   บ Dataณ 15/06/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo chamada na confirma็ใo da tela							  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function Confirmar(oGrid,aRetorno)

Local lRet 		:= .T.
Local cContrato := oGrid:aCols[oGrid:oBrowse:nAt,aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "U04_CODIGO"})] 
Local cQuadra 	:= oGrid:aCols[oGrid:oBrowse:nAt,aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "U04_QUADRA"})] 
Local cModulo 	:= oGrid:aCols[oGrid:oBrowse:nAt,aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "U04_MODULO"})] 
Local cJazigo 	:= oGrid:aCols[oGrid:oBrowse:nAt,aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "U04_JAZIGO"})] 

if Empty(cJazigo)	
	Alert("Selecione um jazigo!")
	lRet := .F.
else
	aRetorno := {cContrato,cQuadra,cModulo,cJazigo} 
endif

Return(lRet)
