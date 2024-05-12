#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} RCPGR012
Impressão de Relatório Exumação
@author André R. Barrero
@since 05/05/2016
@version P12
/*/

/***********************/
User Function RCPGR012()
/***********************/
	Local oReport

	oReport	:= ReportDef()
	oReport	:PrintDialog()

Return

/**************************/
Static Function ReportDef()
/**************************/
	Local oReport
	Local oSection1
	Local cTitle    := "Relatório Exumação"
	Private cPerg	:= "RCPGR012"

	oReport	:= TReport():New("RCPGR012",cTitle,"RCPGR012",{|oReport| PrintReport(oReport)},"Este relatório apresenta uma relação de Tempo para Exumação dos Contratos selecionados.")
	oReport:SetPortrait()
	oReport:HideParamPage()
	oReport:SetUseGC(.F.) //Desabilita o botão <Gestao Corporativa> do relatório

	CriaSx1(cPerg)
	Pergunte(oReport:GetParam(),.F.)

	oSection1 := TRSection():New(oReport,"Exumação",{"QRYU04"})
	oSection1:SetHeaderPage(.F.)
	oSection1:SetHeaderSection(.T.)

	TRCell():New(oSection1,"U04_CODIGO"	,"QRYU04",	"CONTRATO", 		PesqPict("U04","U04_CODIGO"),TamSX3("U04_CODIGO")[1]+1)
	TRCell():New(oSection1,"U00_NOMCLI"	,"QRYU04", 	"CESSIONÁRIO", 		PesqPict("U00","U00_NOMCLI"),TamSX3("U00_NOMCLI")[1]+1)
	TRCell():New(oSection1,"U00_DESCPL"	,"QRYU04", 	"PLANO", 			PesqPict("U00","U00_DESCPL"),TamSX3("U00_NOMCLI")[1]+1)
	TRCell():New(oSection1,"U04_QUADRA"	,"QRYU04", 	"QUADRA", 			PesqPict("U04","U04_QUADRA"),TamSX3("U04_QUADRA")[1]+1)
	TRCell():New(oSection1,"U04_MODULO"	,"QRYU04",	"MÓDULO", 			PesqPict("U04","U04_MODULO"),TamSX3("U04_MODULO")[1]+1)
	TRCell():New(oSection1,"U04_JAZIGO"	,"QRYU04",	"JAZIDO",			PesqPict("U04","U04_JAZIGO"),TamSX3("U04_JAZIGO")[1]+1)
	TRCell():New(oSection1,"U04_GAVETA"	,"QRYU04",	"GAVETA",			PesqPict("U04","U04_GAVETA"),TamSX3("U04_GAVETA")[1]+2)
	TRCell():New(oSection1,"U04_DTUTIL"	,"QRYU04",	"DT SEPULTAMENTO",	PesqPict("U04","U04_DTUTIL"),TamSX3("U04_DTUTIL")[1]+3)
	TRCell():New(oSection1,"U04_QUEMUT"	,"QRYU04",	"SEPULTADO",		PesqPict("U04","U04_QUEMUT"),TamSX3("U04_QUEMUT")[1]+2)
	TRCell():New(oSection1,"U04_PRZEXU"	,"QRYU04",	"DT EXUMAÇÃO",		PesqPict("U04","U04_PRZEXU"),TamSX3("U04_PRZEXU")[1]+9)

Return(oReport)

/***********************************/
Static Function PrintReport(oReport)
/***********************************/
	Local oSection1	:= oReport:Section(1)
	Local cQry 		:= ""
	Local nCont		:= 0
	Local nAux		:= 0

	oSection1:Init()

	If Select("QRYU04") > 0
		QRYU04->(DbCloseArea())
	Endif

	cQry := "SELECT U04_CODIGO,U00.U00_NOMCLI,U00.U00_DESCPL,U04.U04_QUADRA,U04.U04_MODULO,U04.U04_JAZIGO,U04.U04_GAVETA,U04.U04_DTUTIL,U04.U04_QUEMUT,U04.U04_PRZEXU "
	cQry += " FROM "+RetSqlName("U04")+" U04 INNER JOIN "+RetSqlName("U00")+" U00 "
	cQry += " 	ON (U04.U04_FILIAL 	= U00.U00_FILIAL)"
	cQry += " 	AND (U04.U04_CODIGO	= U00.U00_CODIGO)"
	cQry += " WHERE (U04.D_E_L_E_T_	<> '*' OR U04.D_E_L_E_T_ IS NULL)"
	cQry += " 	AND (U00.D_E_L_E_T_	<> '*' OR U00.D_E_L_E_T_ IS NULL)"
	cQry += " 	AND (U04.U04_FILIAL	= '"+xFilial("U04")+"' )"
	cQry += " 	AND (U00.U00_FILIAL	= '"+xFilial("U00")+"' )"
	cQry += "	AND U04.U04_PRZEXU	<> '' "
	cQry += "	AND U04.U04_TIPO = 'J' "
	cQry += " 	AND U04.U04_OCUPAG = 'S'"
	cQry += " 	AND U04.U04_QUEMUT <> ' ' "
	cQry += " 	AND (U04.U04_CODIGO	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' OR U04.U04_CODIGO IS NULL)"
	cQry += " 	AND U00.U00_PLANO	BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'"

	If ! Empty(MV_PAR05) .And. ! Empty(MV_PAR06)
		cQry += " 	AND U04.U04_PRZEXU 	BETWEEN '"+DtoS(MV_PAR05)+"' AND '"+DtoS(MV_PAR06)+"'"
	EndIf
	cQry += " ORDER BY U04.U04_PRZEXU,U04_CODIGO"

	cQry := ChangeQuery(cQry)
	MemoWrite("c:\temp\RCPGR012.txt",cQry)
	TcQuery cQry NEW Alias "QRYU04"

	QRYU04->(dbEval({|| nCont++}))
	QRYU04->(dbGoTop())

	oReport:SetMeter(nCont)

	While !oReport:Cancel() .And. QRYU04->(!EOF())

		oReport:IncMeter()

		If oReport:Cancel()
			Exit
		EndIf

		oSection1:Cell("U04_CODIGO"):SetValue(QRYU04->U04_CODIGO)
		oSection1:Cell("U00_NOMCLI"):SetValue(AllTrim(QRYU04->U00_NOMCLI))
		oSection1:Cell("U00_DESCPL"):SetValue(AllTrim(QRYU04->U00_DESCPL))
		oSection1:Cell("U04_QUADRA"):SetValue(QRYU04->U04_QUADRA)
		oSection1:Cell("U04_MODULO"):SetValue(QRYU04->U04_MODULO)
		oSection1:Cell("U04_JAZIGO"):SetValue(QRYU04->U04_JAZIGO)
		oSection1:Cell("U04_GAVETA"):SetValue(QRYU04->U04_GAVETA)
		oSection1:Cell("U04_DTUTIL"):SetValue(StoD(QRYU04->U04_DTUTIL))
		oSection1:Cell("U04_QUEMUT"):SetValue(AllTrim(QRYU04->U04_QUEMUT))
		oSection1:Cell("U04_PRZEXU"):SetValue(StoD(QRYU04->U04_PRZEXU))
		oSection1:PrintLine()

		oReport:IncMeter()

		QRYU04->(dbSkip())
	EndDo

	oSection1:Finish()

	If Select("QRYU04") > 0
		QRYU04->(DbCloseArea())
	Endif

Return

//Função para gerar o grupo de parâmetros no SX1
//+-----------------------------------------------------------------+
//| Rotina | CriaSX1 | Autor | André R. Barrero | Data | 05.05.16 |
//+-----------------------------------------------------------------+
//| Descr. | Rotina para criar o grupo de parâmetros. |
//+-----------------------------------------------------------------+
//| Uso | Relatórios. |
//+-----------------------------------------------------------------+
Static Function CriaSx1(cPergunta)
	Local aP 		:= {}
	Local i 		:= 0
	Local cSeq
	Local cMvCh
	Local cMvPar
	Local aHelp 	:= {}
	Local nTamSX1   := 10
	Local ind		:= 0 //Contador para deletar SX1
/******
Parâmetros da função padrão
---------------------------
Nome		Tipo		Descrição													Obrigatório
1-cGrupo	Caracter	Nome do grupo de pergunta									X	
2-cOrdem	Caracter	Ordem de apresentação das perguntas na tela					X	
3-cPergunt	Caracter	Texto da pergunta a ser apresentado na tela					X	
4-cPergSpa	Caracter	Texto em espanhol da pergunta a ser apresentado na tela.	X	
5-cPergEng	Caracter	Texto em inglês da pergunta a ser apresentado na tela.		X	
6-cVar		Caracter	Variável do item											X	
7-cTipo		Caracter	Tipo do conteúdo de resposta da pergunta.					X	
08-nTamanho	Numérico	Tamanho do campo para resposta								X	
09-nDecimal	Numérico	Número de casas decimais da resposta, se houver		
10-nPreSel	Numérico	Valor que define qual o item do combo estará selecionado na 
						apresentação da tela. Este parâmetro somente deverá ser 
						preenchido quando o parâmetro cGSC for preenchido com "C".		
11-cGSC		Caracter	Estilo de apresentação da pergunta na tela: - "G" - formato 
						que permite editar o conteúdo da pergunta. - "S" - formato 
						de texto que não permite alteração. - "C" - formato que 
						permite a seleção de dados para a pergunta.					X	
12-cValid	Caracter	Validação do item de pergunta		
13-cF3		Caracter	Nome da consulta F3 que poderá ser acionada pela pergunta.		
14-cGrpSXG	Caracter	Código do grupo de campos relacionado a pergunta.		
15-cPyme	Caracter	Define se a pergunta poderá ser apresentada em aplicações do tipo Express.		
16-cVar01	Caracter	Nome do MV_PAR para a utilização nos programas.	X	
17-cDef01	Caracter	Conteúdo em português do primeiro item do objeto, caso seja do tipo Combo.		
18-cDefSpa1	Caracter	Conteúdo em espanhol do primeiro item do objeto, caso seja do tipo Combo.		
19-cDefEng1	Caracter	Conteúdo em inglês do primeiro item do objeto, caso seja do tipo Combo.		
20-cCnt01	Caracter	Conteúdo padrão da pergunta.		
21-cDef02	Caracter	Conteúdo em português do segundo item do objeto, caso seja do tipo Combo.		
22-cDefSpa2	Caracter	Conteúdo em espanhol do segundo item do objeto, caso seja do tipo Combo.		
23-cDefEng2	Caracter	Conteúdo em inglês do segundo item do objeto, caso seja do tipo Combo.		
24-cDef03	Caracter	Conteúdo em português do terceiro item do objeto, caso seja do tipo Combo.		
25-cDefSpa3	Caracter	Conteúdo em espanhol do terceiro item do objeto, caso seja do tipo Combo.		
26-cDefEng3	Caracter	Conteúdo em inglês do terceiro item do objeto, caso seja do tipo Combo.		
27-cDef04	Caracter	Conteúdo em português do quarto item do objeto, caso seja do tipo Combo.		
28-cDefSpa4	Caracter	Conteúdo em espanhol do quarto item do objeto, caso seja do tipo Combo.		
29-cDefEng4	Caracter	Conteúdo em inglês do quarto item do objeto, caso seja do tipo Combo.		
30-cDef05	Caracter	Conteúdo em português do quinto item do objeto, caso seja do tipo Combo.		
31-cDefSpa5	Caracter	Conteúdo em espanhol do quinto item do objeto, caso seja do tipo Combo.		
32-cDefEng5	Caracter	Conteúdo em inglês do quinto item do objeto, caso seja do tipo Combo.		
33-aHelpPor	Vetor		Help descritivo da pergunta em Português.		
34-aHelpEng	Vetor		Help descritivo da pergunta em Inglês.		
35-aHelpSpa	Vetor		Help descritivo da pergunta em Espanhol.		
36-cHelp	Caracter	Nome do help equivalente, caso já exista um no sistema.

Característica do vetor p/ utilização da função SX1
---------------------------------------------------
[n,1] --> texto da pergunta
[n,2] --> tipo do dado
[n,3] --> tamanho
[n,4] --> decimal
[n,5] --> objeto G=get ou C=choice
[n,6] --> validação
[n,7] --> F3
[n,8] --> Inicializador padrão
[n,9] --> definição 1
[n,10] -> definição 2
[n,11] -> definição 3
[n,12] -> definição 4
[n,13] -> definição 5
***/
        //1						,2	,3 ,4,5	 ,6						  ,7	,8 		 ,9 ,10,11,12,13
AADD(aP,{"Contrato de 			?"	,"C",06,0,"G",""					  ,"U00","      ","","","","",""})
AADD(aP,{"Contrato até			?"	,"C",06,0,"G","(mv_par02>=mv_par01)"  ,"U00","ZZZZZZ","","","","",""})
AADD(aP,{"Plano de				?"	,"C",06,0,"G",""					  ,"U05","      ","","","","",""})
AADD(aP,{"Plano até     		?"	,"C",06,0,"G","(mv_par04>=mv_par03)"  ,"U05","ZZZZZZ","","","","",""})
AADD(aP,{"Data de				?"	,"D",08,0,"G",""					  ,""   ,""		 ,"","","","",""})
AADD(aP,{"Data Até 				?"	,"D",08,0,"G","(mv_par06>=mv_par05)"  ,""   ,""		 ,"","","","",""})

AADD(aHelp,{"Informe o código do contrato."	,"inicial."})
AADD(aHelp,{"Informe o código do contrato."	,"final."})
AADD(aHelp,{"Informe o código do plano."	,"inicial."})
AADD(aHelp,{"Informe o código do plano."	,"final."})
AADD(aHelp,{"Informe a data de Exumação."	,"inicial."})
AADD(aHelp,{"Informe a data de Exumação."	,"final."})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta grupo de perguntas "cPerg"	                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX1")
SX1->( DbGoTop() )
While SX1->( ! EOF() )
	ind++
	If DbSeek( PADR(cPergunta,nTamSX1)+StrZero(ind,2,0) )
		Reclock("SX1",.f.)
			dbDelete()
		MsUnlock()
	Else
		Exit
	EndIf
EndDo

For i:=1 To Len(aP)
	cSeq 	:= StrZero(i,2,0)
	cMvPar 	:= "mv_par"+cSeq
	cMvCh 	:= "mv_ch"+IIF(i<=9,Chr(i+48),Chr(i+87))

/*01*/	U_xPutSX1(cPergunta,;
/*02*/	cSeq,;
/*03*/	aP[i,1],;
/*04*/	aP[i,1],;
/*05*/	aP[i,1],;
/*06*/	cMvCh,;
/*07*/	aP[i,2],;
/*08*/	aP[i,3],;
/*09*/	aP[i,4],;
/*10*/	0,;
/*11*/	aP[i,5],;
/*12*/	aP[i,6],;
/*13*/	aP[i,7],;
/*14*/	"",;
/*15*/	"",;
/*16*/	cMvPar,;
/*17*/	aP[i,9],;
/*18*/	aP[i,9],;
/*19*/	aP[i,9],;
/*20*/	aP[i,8],;
/*21*/	aP[i,10],;
/*22*/	aP[i,10],;
/*23*/	aP[i,10],;
/*24*/	aP[i,11],;
/*25*/	aP[i,11],;
/*26*/	aP[i,11],;
/*27*/	aP[i,12],;
/*28*/	aP[i,12],;
/*29*/	aP[i,12],;
/*30*/	aP[i,13],;
/*31*/	aP[i,13],;
/*32*/	aP[i,13],;
/*33*/	aHelp[i],;
/*34*/	{},;
/*35*/	{},;
/*36*/	"")
Next i

Return
