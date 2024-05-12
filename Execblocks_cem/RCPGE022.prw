#Include 'Protheus.ch'
#include "topconn.ch" 

// variável utilizada para retorno da consulta específica
Static cRetContrato := ""

/*/{Protheus.doc} RCPGE022
Consulta específica de Contratos do Cemiterio	
@author Raphael Martins 
@since 23/11/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function RCPGE022()

Local oButton1
Local oButton2
Local oButton3
Local oButton4
Local oGetCtr
Local oGetCPF
Local oGetNomTit
Local oGetNomAut
Local oGroup1
Local oGroup2 
Local oGroup3
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oGrid, oGrid2
Local cGetCtr 		:= Space(TamSX3("U00_CODIGO")[1])
Local cGetCPF 		:= Space(11)
Local cGetNomTit 	:= Space(TamSX3("A1_NOME")[1])
Local cGetNomAut	:= Space(TamSX3("U02_NOME")[1])
Local lRet			:= .T.
Static oDlg

DEFINE MSDIALOG oDlg TITLE "Consulta de Contratos" FROM 000, 000  TO 600, 550 COLORS 0, 16777215 PIXEL

@ 005, 005 GROUP oGroup1 TO 087, 272 PROMPT "  Filtros  " OF oDlg COLOR 0, 16777215 PIXEL

@ 018, 010 SAY oSay1 PROMPT "Núm. Contrato:" SIZE 043, 006 OF oDlg COLORS 0, 16777215 PIXEL
@ 017, 052 MSGET oGetCtr VAR cGetCtr SIZE 070, 010 OF oDlg COLORS 0, 16777215 PIXEL

@ 018, 149 SAY oSay2 PROMPT "CNPJ/CPF Titular:" SIZE 032, 008 OF oDlg COLORS 0, 16777215 PIXEL
@ 017, 192 MSGET oGetCPF VAR cGetCPF SIZE 072, 010 Picture "@R 999.999.999-99" OF oDlg COLORS 0, 16777215 PIXEL

@ 035, 010 SAY oSay3 PROMPT "Nome Titular:" SIZE 042, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 034, 052 MSGET oGetNomTit VAR cGetNomTit SIZE 212, 010 Picture PesqPict("SA1","A1_NOME") OF oDlg COLORS 0, 16777215 PIXEL

@ 052, 010 SAY oSay4 PROMPT "Nome Autor.:" SIZE 042, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 051, 052 MSGET oGetNomAut VAR cGetNomAut SIZE 212, 010 Picture PesqPict("U02","U02_NOME") OF oDlg COLORS 0, 16777215 PIXEL

@ 069, 225 BUTTON oButton1 PROMPT "Atualizar" SIZE 037, 012 ACTION(FWMsgRun(,{|oSay| AtuGrid(oGrid,cGetCtr,cGetCPF,cGetNomTit,cGetNomAut,oGrid2)},'Aguarde...','Consultando os contratos...')) OF oDlg PIXEL
@ 069, 182 BUTTON oButton2 PROMPT "Limpar" SIZE 037, 012 ACTION(LimpaCPO(@cGetCtr,@cGetCPF,@cGetNomTit,@cGetNomAut,oGetCtr,oGetCPF,oGetNomTit,oGetNomAut),FWMsgRun(,{|oSay| AtuGrid(oGrid,cGetCtr,cGetCPF,cGetNomTit,cGetNomAut,oGrid2)},'Aguarde...','Consultando os contratos...')) OF oDlg PIXEL

@ 092, 005 SAY oSay5 PROMPT "Contratos" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 099, 005 GROUP oGroup4 TO 100, 272 OF oDlg COLOR 0, 16777215 PIXEL
// crio o grid de contratos
oGrid := bGridCTR()
oGrid:bChange := {|| BuscaAut(oGrid,oGrid2)}   

@ 172, 005 SAY oSay6 PROMPT "Autorizados" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 179, 005 GROUP oGroup3 TO 180, 272 OF oDlg COLOR 0, 16777215 PIXEL
// crio o grid de Autorizados
oGrid2 := bGridAut()

@ 228, 005 GROUP oGroup2 TO 229, 272 OF oDlg COLOR 0, 16777215 PIXEL
@ 284, 234 BUTTON oButton3 PROMPT "Confirmar" Action(iif(Confirmar(oGrid),oDlg:End(),MsgAlert("Selecione um contrato!","Anteção!"))) SIZE 037, 012 OF oDlg PIXEL
@ 284, 190 BUTTON oButton4 PROMPT "Cancelar" Action(cRetContrato := "",oDlg:End()) SIZE 037, 012 OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ bGridCTR º Autor ³ Wellington Gonçalves         º Data³ 27/10/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que monta o grid de contratos								  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Cemiterio	                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function bGridCTR()
 
Local nX
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {"CONTRATO","DATA","NOME","CGC"}
Local aAlterFields 	:= {}
Local oGrid

For nX := 1 To Len(aFields)
	
	if aFields[nX] == "CONTRATO"
		Aadd(aHeaderEx, {"Contrato","CONTRATO","@!",TamSX3("U00_CODIGO")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "DATA"
		Aadd(aHeaderEx, {"Data","DATA","",8,0,"","€€€€€€€€€€€€€€","D","","","",""})
	elseif aFields[nX] == "NOME"
		Aadd(aHeaderEx, {"Nome","NOME",PesqPict("SA1","A1_NOME"),TamSX3("A1_NOME")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "CGC"
		Aadd(aHeaderEx, {"CNPJ/CPF","CGC","@!",TamSX3("A1_CGC")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
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

oGrid := MsNewGetDados():New( 105, 005, 170/*223*/, 272,GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return(oGrid)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ bGridAut º Autor ³ Wellington Gonçalves         º Data³ 27/10/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que monta o grid de Autorizados							  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Cemiterio	                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function bGridAut()
 
Local nX
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {"GRAUPARENTE","NOME"}
Local aAlterFields 	:= {}
Local oGrid

For nX := 1 To Len(aFields)
	
	if aFields[nX] == "GRAUPARENTE"
		Aadd(aHeaderEx, {"Grau parente","GRAUPARENTE","@!",TamSX3("U02_GRAUPA")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "NOME"
		Aadd(aHeaderEx, {"Nome","NOME","@!",TamSX3("U02_NOME")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
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

oGrid := MsNewGetDados():New( 185, 005, 280, 272,GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return(oGrid)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ LimpaCPO º Autor ³ Wellington Gonçalves	   	   º Data³ 27/10/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que limpa os campos do dialog								  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Cemiterio	                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LimpaCPO(cGetCtr,cGetCPF,cGetNomTit,cGetNomAut,oGetCtr,oGetCPF,oGetNomTit,oGetNomAut)

cGetCtr 	:= Space(TamSX3("U00_CODIGO")[1])
cGetCPF 	:= Space(TamSX3("A1_CGC")[1])
cGetNomTit 	:= Space(TamSX3("A1_NOME")[1])
cGetNomAut	:= Space(TamSX3("A1_NOME")[1])

oGetCtr:Refresh()
oGetCPF:Refresh()
oGetNomTit:Refresh()
oGetNomAut:Refresh()

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ AtuGrid º Autor ³ Wellington Gonçalves	 		 Data³ 27/10/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que atualiza o grid										  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Cemiterio	                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function AtuGrid(oGrid,cContrato,cCpf,cNomeTit,cNomeAut,oGrid2)

Local cQry 			:= ""
Local aFieldFill	:= {}   
Local cPulaLinha	:= chr(13)+chr(10)  
Local aAuxAcols		:= {}
Local nY			:= 1
Local nX			:= 1

// tempo para mostrar a mensagem de aguarde
Sleep(1000)

// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf    

cQry := " SELECT "                                                    		+ cPulaLinha
cQry += " U00.U00_FILIAL, "                                           		+ cPulaLinha
cQry += " U00.U00_CODIGO AS CONTRATO, "                               		+ cPulaLinha
cQry += " U00.U00_DATA AS DATA, "                                     		+ cPulaLinha
cQry += " U00.U00_CLIENT AS CLIENTE, "                                		+ cPulaLinha
cQry += " U00.U00_LOJA AS LOJA, "                                     		+ cPulaLinha
cQry += " SA1.A1_NOME AS NOME, "                                       		+ cPulaLinha
cQry += " SA1.A1_PESSOA, "		                                       		+ cPulaLinha
cQry += " SA1.A1_CGC AS CGC "                                       		+ cPulaLinha
cQry += " FROM "                                                      		+ cPulaLinha
cQry +=   + RetSqlName("U00") + " U00 "                       	      		+ cPulaLinha
cQry += " 	INNER JOIN "                                              		+ cPulaLinha
cQry +=  	+ RetSqlName("SA1") + " SA1 "                             		+ cPulaLinha
cQry += " 	ON ( "                                                    		+ cPulaLinha
cQry += " 		SA1.D_E_L_E_T_ <> '*' "                               		+ cPulaLinha
cQry += " 		AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "        		+ cPulaLinha
cQry += " 		AND U00.U00_CLIENT = SA1.A1_COD "                     		+ cPulaLinha
cQry += " 		AND U00.U00_LOJA = SA1.A1_LOJA "                      		+ cPulaLinha

if !Empty(cNomeTit)
	cQry += " 		AND SA1.A1_NOME LIKE '%" + AllTrim(cNomeTit) + "%' "	+ cPulaLinha
endif

if !Empty(cCpf)
	cQry += " 		AND SA1.A1_CGC LIKE '" + AllTrim(cCpf) + "%' " 			+ cPulaLinha
endif

cQry += " 	) "                                                       		+ cPulaLinha
cQry += " 	LEFT JOIN "                                              		+ cPulaLinha
cQry +=  	+ RetSqlName("U02") + " U02 "                             		+ cPulaLinha
cQry += " 	ON ( "                                                    		+ cPulaLinha
cQry += " 		U02.D_E_L_E_T_ <> '*' "                               		+ cPulaLinha
cQry += " 		AND U02.U02_FILIAL = '" + xFilial("U02") + "' "       		+ cPulaLinha
cQry += " 		AND U00.U00_CODIGO = U02.U02_CODIGO "                 		+ cPulaLinha

cQry += " 	) "	                                                      		+ cPulaLinha
cQry += " WHERE "                                                     		+ cPulaLinha
cQry += " U00.D_E_L_E_T_ <> '*' "                                     		+ cPulaLinha
cQry += " AND U00.U00_FILIAL = '" + xFilial("U00") + "' "             		+ cPulaLinha

if !Empty(cNomeAut)
	cQry += " 		AND U02.U02_NOME LIKE '%" + AllTrim(cNomeAut) + "%' "	+ cPulaLinha
endif


if !Empty(cContrato)
	cQry += " AND U00.U00_CODIGO LIKE '" + AllTrim(cContrato) + "%' "		+ cPulaLinha
endif

cQry += " GROUP BY "                                                  		+ cPulaLinha
cQry += " U00.U00_FILIAL, "                                           		+ cPulaLinha
cQry += " U00.U00_CODIGO, "                                           		+ cPulaLinha
cQry += " U00.U00_DATA, "                                             		+ cPulaLinha
cQry += " U00.U00_CLIENT, "                                           		+ cPulaLinha
cQry += " U00.U00_LOJA, "                                             		+ cPulaLinha
cQry += " SA1.A1_NOME, "                                               		+ cPulaLinha
cQry += " SA1.A1_PESSOA, "                                             		+ cPulaLinha
cQry += " SA1.A1_CGC "                                               		+ cPulaLinha
cQry += " ORDER BY U00.U00_FILIAL , U00.U00_CODIGO "                  		+ cPulaLinha

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

// se existir contratos a serem reajustados
if QRY->(!Eof())

	While QRY->(!Eof())
	
		aFieldFill := {}

		For nY := 1 to Len(oGrid:aHeader)
			
			If oGrid:aHeader[nY,2] == "CONTRATO"
				Aadd(aFieldFill , QRY->CONTRATO)
			elseif oGrid:aHeader[nY,2] == "DATA"
				Aadd(aFieldFill , SToD(QRY->DATA))
			elseif oGrid:aHeader[nY,2] == "NOME"
				Aadd(aFieldFill , QRY->NOME)
			elseif oGrid:aHeader[nY,2] == "CGC"
				If QRY->A1_PESSOA == "J" //Juridica
					Aadd(aFieldFill , Transform(QRY->CGC,"@R 99.999.999/9999-99"))
				Else
					Aadd(aFieldFill , Transform(QRY->CGC,"@R 999.999.999-99"))
				Endif
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

// faço um refresh no grid
oGrid:oBrowse:Refresh() 

If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf  

BuscaAut(oGrid,oGrid2)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ AtuGrid º Autor ³ Wellington Gonçalves	 		 Data³ 03/11/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que posiciona no contrato selecionado						  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Cemiterio	                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Confirmar(oGrid)

Local lRet		:= .F.
Local cContrato := oGrid:aCols[oGrid:oBrowse:nAt,aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CONTRATO"})]

if !Empty(cContrato)

	U00->(DbGoTop())

	// tento posicionar no contrato, caso não consiga, volto o registro posicionado anteriormente
	U00->(DbSetOrder(1)) // U00_FILIAL + U00_CODIGO
	if U00->(DbSeek(xFilial("U00") + cContrato))
		lRet := .T.
		cRetContrato := U00->U00_CODIGO
	endif

endif

Return(lRet)

/*************************************/
Static Function BuscaAut(oGrid,oGrid2)
/*************************************/

Local cQry := ""
Local aFieldFill	:= {}   
Local aAuxAcols		:= {}
Local nY			:= 1
Local nX			:= 1

Local cContrato 	:= oGrid:aCols[oGrid:oBrowse:nAt,aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CONTRATO"})]

Local cGrau			:= ""
Local cTipo			:= ""

If Select("QRYAUT") > 0
	QRYAUT->(DbCloseArea())
Endif  

cQry := "SELECT U02_GRAUPA,"
cQry += " U02_NOME"
cQry += " FROM "+RetSqlName("U02")+""
cQry += " WHERE D_E_L_E_T_	<> '*'"
cQry += " AND U02_FILIAL	= '"+xFilial("U02")+"'"
cQry += " AND U02_CODIGO	= '"+cContrato+"'"
cQry += " ORDER BY U02_ITEM"

cQry := ChangeQuery(cQry)
TcQuery cQry New Alias "QRYAUT" // Cria uma nova area com o resultado do query   

If QRYAUT->(!Eof())

	While QRYAUT->(!Eof())
	
		aFieldFill := {}

		For nY := 1 to Len(oGrid2:aHeader)
			
			If oGrid2:aHeader[nY,2] == "GRAUPARENTE"
				Do Case
					Case QRYAUT->U02_GRAUPA == "CO"
						cGrau := "Conjuge"
					Case QRYAUT->U02_GRAUPA == "FI"
						cGrau := "Filho(a)"
					Case QRYAUT->U02_GRAUPA == "IR"
						cGrau := "Irmao(a)"
					Case QRYAUT->U02_GRAUPA == "NE"
						cGrau := "Neto(a)"
					Case QRYAUT->U02_GRAUPA == "OU"
						cGrau := "Outros"
				EndCase
				
				Aadd(aFieldFill , cGrau)
	
			ElseIf oGrid2:aHeader[nY,2] == "NOME"
	
				Aadd(aFieldFill , QRYAUT->U02_NOME)
	
			Endif
	
		Next nY
		
		AAdd(aFieldFill,.F.)
		AAdd(aAuxAcols,aFieldFill)
		
		QRYAUT->(DbSkip())
	EndDo
	
Else

	For nX := 1 To Len(oGrid2:aHeader)
	
		If oGrid2:aHeader[nX,8] == "N"
			AAdd(aFieldFill,0)
		Elseif oGrid2:aHeader[nX,8] == "D"
			AAdd(aFieldFill,CTOD(""))
		Elseif oGrid2:aHeader[nX,8] == "L"
			AAdd(aFieldFill,.F.)
		Else
			AAdd(aFieldFill,"")
		Endif
	Next nX
	
	AAdd(aFieldFill,.F.)
	AAdd(aAuxAcols,aFieldFill)
Endif

oGrid2:aCols := aClone(aAuxAcols)
oGrid2:oBrowse:Refresh() 

If Select("QRYAUT") > 0
	QRYAUT->(DbCloseArea())
Endif  

Return