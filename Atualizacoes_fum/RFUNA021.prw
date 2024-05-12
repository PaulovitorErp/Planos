#Include 'Protheus.ch'
#include "topconn.ch" 

// variável utilizada para retorno da consulta específica
Static cRetContrato := ""

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ RFUNA021 º Autor ³ Wellington Gonçalves         º Data³ 27/10/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Consulta específica de Contratos da Funerária					  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Funerária	                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function RFUNA021()

Local oButton1
Local oButton2
Local oButton3
Local oButton4
Local oGetCtr
Local oGetCPF
Local oGetNomTit
Local oGetNomBen
Local oGetUF
Local oGetCidade
Local oGetTelefone
Local oGroup1
Local oGroup2 
Local oGroup3
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Local oGrid, oGrid2
Local cGetCtr 		:= Space(TamSX3("UF2_CODIGO")[1])
Local cGetCPF 		:= Space(11)
Local cGetNomTit 	:= Space(TamSX3("A1_NOME")[1])
Local cGetNomBen	:= Space(TamSX3("UF4_NOME")[1])
Local cGetUF		:= Space(TamSX3("A1_EST")[1])
Local cGetCidade	:= Space(TamSX3("A1_MUN")[1])
Local cGetTelefone	:= Space(TamSX3("A1_TEL")[1])
Local lRet			:= .T.
Static oDlg

DEFINE MSDIALOG oDlg TITLE "Consulta de Contratos" FROM 000, 000  TO 600, 600 COLORS 0, 16777215 PIXEL

@ 005, 005 GROUP oGroup1 TO 107, 298 PROMPT "  Filtros  " OF oDlg COLOR 0, 16777215 PIXEL

@ 018, 010 SAY oSay3 PROMPT "Nome Titular:" SIZE 042, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 017, 052 MSGET oGetNomTit VAR cGetNomTit SIZE 238, 010 Picture PesqPict("SA1","A1_NOME") OF oDlg COLORS 0, 16777215 PIXEL

@ 035, 010 SAY oSay4 PROMPT "Nome Benef.:" SIZE 042, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 034, 052 MSGET oGetNomBen VAR cGetNomBen SIZE 238, 010 Picture PesqPict("UF4","UF4_NOME") OF oDlg COLORS 0, 16777215 PIXEL

@ 052, 010 SAY oSay1 PROMPT "Núm. Contrato:" SIZE 043, 006 OF oDlg COLORS 0, 16777215 PIXEL
@ 051, 052 MSGET oGetCtr VAR cGetCtr SIZE 070, 010 OF oDlg COLORS 0, 16777215 PIXEL

@ 052, 149 SAY oSay2 PROMPT "CNPJ/CPF Titular:" SIZE 032, 008 OF oDlg COLORS 0, 16777215 PIXEL
@ 051, 192 MSGET oGetCPF VAR cGetCPF SIZE 098, 010 Picture "@R 999.999.999-99" OF oDlg COLORS 0, 16777215 PIXEL

@ 072, 010 SAY oSay5 PROMPT "Estado:" SIZE 042, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 071, 034 MSGET oGetUF VAR cGetUF SIZE 033, 010 Picture PesqPict("SA1","A1_EST") F3 "12" OF oDlg COLORS 0, 16777215 PIXEL

@ 072, 075 SAY oSay6 PROMPT "Cidade:" SIZE 032, 008 OF oDlg COLORS 0, 16777215 PIXEL
@ 071, 098 MSGET oGetCidade VAR cGetCidade SIZE 072, 010 Picture PesqPict("SA1","A1_MUN") OF oDlg COLORS 0, 16777215 PIXEL

@ 072, 180 SAY oSay7 PROMPT "Telefone:" SIZE 032, 008 OF oDlg COLORS 0, 16777215 PIXEL
@ 071, 213 MSGET oGetTelefone VAR cGetTelefone SIZE 077, 010 Picture "@R 99999-9999" OF oDlg COLORS 0, 16777215 PIXEL

																							 
@ 089, 251 BUTTON oButton1 PROMPT "Atualizar" SIZE 037, 012 ACTION(FWMsgRun(,{|oSay| AtuGrid(oGrid,cGetCtr,cGetCPF,cGetNomTit,cGetNomBen,cGetUF,cGetCidade,cGetTelefone,oGrid2)},'Aguarde...','Consultando os contratos...')) OF oDlg PIXEL
@ 089, 208 BUTTON oButton2 PROMPT "Limpar" SIZE 037, 012 ACTION(LimpaCPO(@cGetCtr,@cGetCPF,@cGetNomTit,@cGetNomBen,@cGetUF,@cGetCidade,@cGetTelefone,oGetCtr,oGetCPF,oGetNomTit,oGetNomBen,oGetUF,oGetCidade,oGetTelefone),FWMsgRun(,{|oSay| AtuGrid(oGrid,cGetCtr,cGetCPF,cGetNomTit,cGetNomBen,cGetUF,cGetCidade,cGetTelefone,oGrid2)},'Aguarde...','Consultando os contratos...')) OF oDlg PIXEL

@ 112, 005 SAY oSay8 PROMPT "Contratos" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 119, 005 GROUP oGroup4 TO 120, 298 OF oDlg COLOR 0, 16777215 PIXEL
// crio o grid de contratos
oGrid := bGridCTR()
oGrid:bChange := {|| BuscaBen(oGrid,oGrid2)}   

@ 192, 005 SAY oSay9 PROMPT "Beneficiarios" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
@ 199, 005 GROUP oGroup3 TO 200, 298 OF oDlg COLOR 0, 16777215 PIXEL
// crio o grid de beneficiarios
oGrid2 := bGridBEN()

@ 228, 005 GROUP oGroup2 TO 229, 298 OF oDlg COLOR 0, 16777215 PIXEL
@ 284, 255 BUTTON oButton3 PROMPT "Confirmar" Action(iif(Confirmar(oGrid),oDlg:End(),MsgAlert("Selecione um contrato!","Anteção!"))) SIZE 037, 012 OF oDlg PIXEL
@ 284, 211 BUTTON oButton4 PROMPT "Cancelar" Action(cRetContrato := "",oDlg:End()) SIZE 037, 012 OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ bGridCTR º Autor ³ Wellington Gonçalves         º Data³ 27/10/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que monta o grid de contratos								  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Funerária	                    			                      º±±
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
		Aadd(aHeaderEx, {"Contrato","CONTRATO","@!",TamSX3("UF2_CODIGO")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
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

oGrid := MsNewGetDados():New( 125, 005, 190/*223*/, 298,GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return(oGrid)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ bGridBEN º Autor ³ Wellington Gonçalves         º Data³ 27/10/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que monta o grid de beneficiarios							  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Funerária	                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function bGridBEN()
 
Local nX
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {}
Local aAlterFields 	:= {}
Local oGrid

aFields := {"GRAUPARENTE","TIPO","NOME","FALECI"}

For nX := 1 To Len(aFields)
	
	if aFields[nX] == "GRAUPARENTE"
		Aadd(aHeaderEx, {"Grau parente","GRAUPARENTE","@!",TamSX3("UF4_GRAU")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "TIPO"
		Aadd(aHeaderEx, {"Tipo","TIPO","@!",20,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "NOME"
		Aadd(aHeaderEx, {"Nome","NOME","@!",TamSX3("UF4_NOME")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "FALECI"
		Aadd(aHeaderEx, {"Falecimento","FALECI","",8,0,"","€€€€€€€€€€€€€€","D","","","",""})
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

oGrid := MsNewGetDados():New( 205, 005, 280, 298,GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return(oGrid)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ LimpaCPO º Autor ³ Wellington Gonçalves	   	   º Data³ 27/10/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que limpa os campos do dialog								  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Funerária	                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function LimpaCPO(cGetCtr,cGetCPF,cGetNomTit,cGetNomBen,cGetUF,cGetCidade,cGetTelefone,oGetCtr,oGetCPF,oGetNomTit,oGetNomBen,oGetUF,oGetCidade,oGetTelefone)

cGetCtr 		:= Space(TamSX3("UF2_CODIGO")[1])
cGetCPF 		:= Space(TamSX3("A1_CGC")[1])
cGetNomTit 		:= Space(TamSX3("A1_NOME")[1])
cGetNomBen		:= Space(TamSX3("A1_NOME")[1])
cGetUF			:= Space(TamSX3("A1_EST")[1])
cGetCidade		:= Space(TamSX3("A1_MUN")[1])
cGetTelefone	:= Space(TamSX3("A1_TEL")[1])


oGetCtr:Refresh()
oGetCPF:Refresh()
oGetNomTit:Refresh()
oGetNomBen:Refresh()
oGetUF:Refresh()
oGetCidade:Refresh()
oGetTelefone:Refresh()

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ AtuGrid º Autor ³ Wellington Gonçalves	 		 Data³ 27/10/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que atualiza o grid										  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Funerária	                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function AtuGrid(oGrid,cContrato,cCpf,cNomeTit,cNomeBenef,cGetUF,cGetCidade,cGetTelefone,oGrid2)
																			
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
cQry += " UF2.UF2_FILIAL, "                                           		+ cPulaLinha
cQry += " UF2.UF2_CODIGO AS CONTRATO, "                               		+ cPulaLinha
cQry += " UF2.UF2_DATA AS DATA, "                                     		+ cPulaLinha
cQry += " UF2.UF2_CLIENT AS CLIENTE, "                                		+ cPulaLinha
cQry += " UF2.UF2_LOJA AS LOJA, "                                     		+ cPulaLinha
cQry += " SA1.A1_NOME AS NOME, "                                       		+ cPulaLinha
cQry += " SA1.A1_PESSOA, "		                                       		+ cPulaLinha
cQry += " SA1.A1_CGC AS CGC "                                       		+ cPulaLinha
cQry += " FROM "                                                      		+ cPulaLinha
cQry +=   + RetSqlName("UF2") + " UF2 "                       	      		+ cPulaLinha
cQry += " 	INNER JOIN "                                              		+ cPulaLinha
cQry +=  	+ RetSqlName("SA1") + " SA1 "                             		+ cPulaLinha
cQry += " 	ON ( "                                                    		+ cPulaLinha
cQry += " 		SA1.D_E_L_E_T_ <> '*' "                               		+ cPulaLinha
cQry += " 		AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "        		+ cPulaLinha
cQry += " 		AND UF2.UF2_CLIENT = SA1.A1_COD "                     		+ cPulaLinha
cQry += " 		AND UF2.UF2_LOJA = SA1.A1_LOJA "                      		+ cPulaLinha

if !Empty(cNomeTit)
	cQry += " 		AND SA1.A1_NOME LIKE '%" + AllTrim(cNomeTit) + "%' "	+ cPulaLinha
endif


if !Empty(cCpf)
	cQry += " 		AND SA1.A1_CGC LIKE '" + AllTrim(cCpf) + "%' " 			+ cPulaLinha
endif

if !Empty(cGetUF)
	cQry += " 		AND ( SA1.A1_EST LIKE '%" + AllTrim(cGetUF) + "%' "	+ cPulaLinha
	cQry += " 		OR A1_ESTC LIKE '%" + AllTrim(cGetUF) + "%' ) "
endif

if !Empty(cGetCidade)
	cQry += " 		AND ( SA1.A1_MUN LIKE '%" + AllTrim(cGetCidade) + "%' "	+ cPulaLinha
	cQry += " 		OR A1_MUNC LIKE '%" + AllTrim(cGetCidade) + "%' ) "
endif

if !Empty(cGetTelefone)
	cQry += " 		AND ( SA1.A1_TEL LIKE '%" + AllTrim(cGetTelefone) + "%' "	+ cPulaLinha
	cQry += " 		OR A1_XCEL LIKE '%" + AllTrim(cGetTelefone) + "%' ) "
endif

cQry += " 	) "                                                       		+ cPulaLinha
cQry += " 	INNER JOIN "                                              		+ cPulaLinha
cQry +=  	+ RetSqlName("UF4") + " UF4 "                             		+ cPulaLinha
cQry += " 	ON ( "                                                    		+ cPulaLinha
cQry += " 		UF4.D_E_L_E_T_ <> '*' "                               		+ cPulaLinha
cQry += " 		AND UF4.UF4_FILIAL = '" + xFilial("UF4") + "' "       		+ cPulaLinha
cQry += " 		AND UF2.UF2_CODIGO = UF4.UF4_CODIGO "                 		+ cPulaLinha

if !Empty(cNomeBenef)
	cQry += " 		AND UF4.UF4_NOME LIKE '%" + AllTrim(cNomeBenef) + "%' "	+ cPulaLinha
endif

cQry += " 	) "	                                                      		+ cPulaLinha
cQry += " WHERE "                                                     		+ cPulaLinha
cQry += " UF2.D_E_L_E_T_ <> '*' "                                     		+ cPulaLinha
cQry += " AND UF2.UF2_FILIAL = '" + xFilial("UF2") + "' "             		+ cPulaLinha

if !Empty(cContrato)
	cQry += " AND UF2.UF2_CODIGO LIKE '" + AllTrim(cContrato) + "%' "		+ cPulaLinha
endif

cQry += " GROUP BY "                                                  		+ cPulaLinha
cQry += " UF2.UF2_FILIAL, "                                           		+ cPulaLinha
cQry += " UF2.UF2_CODIGO, "                                           		+ cPulaLinha
cQry += " UF2.UF2_DATA, "                                             		+ cPulaLinha
cQry += " UF2.UF2_CLIENT, "                                           		+ cPulaLinha
cQry += " UF2.UF2_LOJA, "                                             		+ cPulaLinha
cQry += " SA1.A1_NOME, "                                               		+ cPulaLinha
cQry += " SA1.A1_PESSOA, "                                             		+ cPulaLinha
cQry += " SA1.A1_CGC "                                               		+ cPulaLinha
cQry += " ORDER BY UF2.UF2_FILIAL , UF2.UF2_CODIGO "                  		+ cPulaLinha


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

BuscaBen(oGrid,oGrid2)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ AtuGrid º Autor ³ Wellington Gonçalves	 		 Data³ 03/11/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que posiciona no contrato selecionado						  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Funerária	                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function Confirmar(oGrid)

Local lRet		:= .F.
Local cContrato := oGrid:aCols[oGrid:oBrowse:nAt,aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CONTRATO"})]

if !Empty(cContrato)

	UF2->(DbGoTop())
	// tento posicionar no contrato, caso não consiga, volto o registro posicionado anteriormente
	UF2->(DbSetOrder(1)) // UF2_FILIAL + UF2_CODIGO
	if UF2->(DbSeek(xFilial("UF2") + cContrato))
		lRet := .T.
		cRetContrato := UF2->UF2_CODIGO
	endif

endif

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ FUNA021RET º Autor ³ Wellington Gonçalves 		 Data³ 04/11/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que retorna o código do contrato							  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Funerária	                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function FUNA021RET()

Local cRet := cRetContrato 

Return(cRet)

/*************************************/
Static Function BuscaBen(oGrid,oGrid2)
/*************************************/

Local cQry := ""
Local aFieldFill	:= {}   
Local aAuxAcols		:= {}
Local nY			:= 1
Local nX			:= 1

Local cContrato 	:= oGrid:aCols[oGrid:oBrowse:nAt,aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CONTRATO"})]

Local cGrau			:= ""
Local cTipo			:= ""

If Select("QRYBEN") > 0
	QRYBEN->(DbCloseArea())
Endif  

cQry := "SELECT UF4_GRAU,"
cQry += " UF4_TIPO,"
cQry += " UF4_NOME,"
cQry += " UF4_FALECI"
cQry += " FROM "+RetSqlName("UF4")+""
cQry += " WHERE D_E_L_E_T_	<> '*'"
cQry += " AND UF4_FILIAL	= '"+xFilial("UF4")+"'"
cQry += " AND UF4_CODIGO	= '"+cContrato+"'"
cQry += " ORDER BY UF4_ITEM"

cQry := ChangeQuery(cQry)
TcQuery cQry New Alias "QRYBEN" // Cria uma nova area com o resultado do query   

If QRYBEN->(!Eof())

	While QRYBEN->(!Eof())
	
		aFieldFill := {}

		For nY := 1 to Len(oGrid2:aHeader)
			
			If oGrid2:aHeader[nY,2] == "GRAUPARENTE"
				Do Case
					Case QRYBEN->UF4_GRAU == "CO"
						cGrau := "Conjuge"
					Case QRYBEN->UF4_GRAU == "FI"
						cGrau := "Filho(a)"
					Case QRYBEN->UF4_GRAU == "IR"
						cGrau := "Irmao(a)"
					Case QRYBEN->UF4_GRAU == "NE"
						cGrau := "Neto(a)"
					Case QRYBEN->UF4_GRAU == "OU"
						cGrau := "Outros"
					Case QRYBEN->UF4_GRAU == "PA"
						cGrau := "Pai"
					Case QRYBEN->UF4_GRAU == "MA"
						cGrau := "Mae"
						
				EndCase
				
				Aadd(aFieldFill , cGrau)
			ElseIf oGrid2:aHeader[nY,2] == "TIPO"
				Do Case
					Case QRYBEN->UF4_TIPO == "1"
						cTipo := "Beneficiario"
					Case QRYBEN->UF4_TIPO == "2"
						cTipo := "Agregado"
					Case QRYBEN->UF4_TIPO == "3"
						cTipo := "Titular"
				EndCase
			
				Aadd(aFieldFill , cTipo)
			
			ElseIf oGrid2:aHeader[nY,2] == "NOME"
			
				Aadd(aFieldFill , QRYBEN->UF4_NOME)
			
			ElseIf oGrid2:aHeader[nY,2] == "FALECI"
			
				Aadd(aFieldFill , SToD(QRYBEN->UF4_FALECI))
			
			Endif

		Next nY
		
		AAdd(aFieldFill,.F.)
		AAdd(aAuxAcols,aFieldFill)
		
		QRYBEN->(DbSkip())
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

If Select("QRYBEN") > 0
	QRYBEN->(DbCloseArea())
Endif  

Return
