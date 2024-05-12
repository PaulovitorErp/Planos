#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RCPGR018
Impress�o de Relat�rio de Jazigo
Orienta��o do tipo Paisagem
@author Andr� R. Barrero
@since 27/05/2016
@version P12
/*/
User Function RCPGR018()
Local oReport
	
	oReport:= ReportDef()
	oReport:PrintDialog()

Return

/*/=============================================================================================================//
{Protheus.doc} ReportDef
Na se��o de defini��o do relat�rio, fun��o ReportDef(), devem ser criados os componentes de impress�o, 
as se��es e as c�lulas, os totalizadores e demais componentes que o usu�rio poder� personalizar no relat�rio.
//=============================================================================================================/*/
Static Function ReportDef()
Local oReport
Local oJazigo
Local oDetalhe
Local oNEnd
Local oTotalGer
Local cTitle    	:= "Relat�rio Jazigos"

Local cTIPO			:= ""

Private cPerg		:= "RCPGR018"

oReport	:= TReport():New("RCPGR018",cTitle,"RCPGR018",{|oReport| PrintReport(oReport,oJazigo,oDetalhe,oNEnd,oTotalGer)},"Este relat�rio apresenta a rela��o de Jazigos.")
oReport:SetPortrait() 		// Orienta��o retrato
//oReport:SetLandscape()			// Orienta��o paisagem 
//oReport:HideHeader()  		// Nao imprime cabe�alho padr�o do Protheus
//oReport:HideFooter()			// Nao imprime rodap� padr�o do Protheus
oReport:HideParamPage()			// Inibe impress�o da pagina de parametros
oReport:SetUseGC( .F. ) 		// Desabilita o bot�o <Gestao Corporativa> do relat�rio
//oReport:DisableOrientation()  // Desabilita a sele��o da orienta��o (retrato/paisagem)
oReport:nFontBody	:= 10
oReport:SetLineHeight(50)
oReport:SetColSpace(2)

CriaSx1(cPerg) // cria as perguntas para gerar o relatorio
Pergunte(oReport:GetParam(),.F.)

//�������������������������������������������������������������������������
//Criacao da secao utilizada pelo relatorio                               
//                                                                        
//TRSection():New                                                         
//ExpO1 : Objeto TReport que a secao pertence                             
//ExpC2 : Descricao da se��o                                              
//ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   
//        sera considerada como principal para a se��o.                   
//ExpA4 : Array com as Ordens do relatorio                                
//ExpL5 : Carrega campos do SX3 como celulas                              
//        Default : False                                                 
//ExpL6 : Carrega ordens do Sindex                                        
//        Default : False                                                 
//                                                                        
//��������������������������������������������������������������������������
//�������������������������������������������������������������������������
//Criacao da celulas da secao do relatorio                                
//                                                                        
//TRCell():New                                                            
//ExpO1 : Objeto TSection que a secao pertence                            
//ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              
//ExpC3 : Nome da tabela de referencia da celula                          
//ExpC4 : Titulo da celula                                                
//        Default : X3Titulo()                                            
//ExpC5 : Picture                                                         
//        Default : X3_PICTURE                                            
//ExpC6 : Tamanho                                                         
//        Default : X3_TAMANHO                                            
//ExpL7 : Informe se o tamanho esta em pixel                              
//        Default : False                                                 
//ExpB8 : Bloco de c�digo para impressao.                                 
//        Default : ExpC2                                                 
//                                                                        
//��������������������������������������������������������������������������

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
oJazigo 	:= TRSection():New(oReport,"Jazigos",{"QRYJAZIG1"},{"Por Quadra + Modulo"}/*Ordens do Relat�rio*/,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oJazigo,"TIPO"	,,cTIPO	,PesqPict("U00","U00_DESCPL"),TamSX3("U00_DESCPL"	)[1]+1	)
		
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
oDetalhe := TRSection():New(oJazigo,"Detalhe",{"QRYJAZIG1"})

TRCell():New(oDetalhe,"U10_QUADRA"	,"QRYJAZIG2","QUADRA"	 ,PesqPict("U10","U10_QUADRA"),TamSX3("U10_QUADRA"	)[1]+1)
TRCell():New(oDetalhe,"U10_MODULO"	,"QRYJAZIG2","MODULO"	 ,PesqPict("U10","U10_MODULO"),TamSX3("U10_MODULO"	)[1]+1)
TRCell():New(oDetalhe,"QTD"			,"QRYJAZIG2","QUANTIDADE","@E 999,999,999",20)
	
// Alinhamento a direita dos campos de valores //Tipo Caracter: "LEFT" � esquerda, "RIGHT" � direita e "CENTER" - centro
oDetalhe:Cell("QUADRA")	:SetHeaderAlign("CENTER")
oDetalhe:Cell("MODULO")	:SetHeaderAlign("CENTER")
oDetalhe:Cell("QTD")	:SetHeaderAlign("CENTER")

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
oTotalGer := TRSection():New(oReport,"Jazigos ativos",{}) //TRSection():New(oReport,"Total Geral",{},,,,,,,,,,,.T.,,,,,1)
oTotalGer:SetHeaderPage(.F.) //Define que imprime cabe�alho das c�lulas no topo da p�gina. (Par�metro) Se verdadeiro, aponta que imprime o cabe�alho no topo da p�gina
oTotalGer:SetHeaderSection(.T.) //Define que imprime cabe�alho das c�lulas na quebra de se��o.(Par�metro) Se verdadeiro, aponta que imprime cabe�alho na quebra da se��o
oTotalGer:SetTotalInLine(.T.) //Define que a impress�o dos totalizadores ser� em linha. (Par�metro) Se verdadeiro, imprime os totalizadores em linha

TRCell():New(oTotalGer,"nTotalGer", , " ", "!@", 100)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
oNEnd := TRSection():New(oReport,"Jazigos n�o endere�ados",{}) //TRSection():New(oReport,"Total Geral",{},,,,,,,,,,,.T.,,,,,1)
oNEnd:SetHeaderPage(.F.) //Define que imprime cabe�alho das c�lulas no topo da p�gina. (Par�metro) Se verdadeiro, aponta que imprime o cabe�alho no topo da p�gina
oNEnd:SetHeaderSection(.T.) //Define que imprime cabe�alho das c�lulas na quebra de se��o.(Par�metro) Se verdadeiro, aponta que imprime cabe�alho na quebra da se��o
oNEnd:SetTotalInLine(.T.) //Define que a impress�o dos totalizadores ser� em linha. (Par�metro) Se verdadeiro, imprime os totalizadores em linha

TRCell():New(oNEnd,"nNEnd", , " ", "!@", 100)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Impressao do Cabecalho no topo da pagina
oReport:Section(1):SetHeaderPage(.F.) //Define que imprime cabe�alho das c�lulas no topo da p�gina
oReport:Section(1):SetHeaderBreak(.F.) //Define se imprime cabe�alho das c�lulas ap�s uma quebra (TRBreak).
oReport:Section(1):SetHeaderSection(.F.) //Define que imprime cabe�alho das c�lulas na quebra de se��o
oReport:Section(1):SetLineStyle(.T.) //Define se imprime as c�lulas da se��o em linhas
oReport:Section(1):SetEdit(.F.) //Define se o relat�rio poder� ser configurado pelo usu�rio no caso de verdadeiro

oJazigo:SetHeaderPage(.F.) //Define que imprime cabe�alho das c�lulas no topo da p�gina
oJazigo:SetHeaderBreak(.F.) //Define se imprime cabe�alho das c�lulas ap�s uma quebra (TRBreak).
oJazigo:SetHeaderSection(.F.) //Define que imprime cabe�alho das c�lulas na quebra de se��o
oJazigo:SetLineStyle(.T.) //Define se imprime as c�lulas da se��o em linhas
oJazigo:SetTotalInLine(.F.) //Define se os totalizadores ser�o impressos em linha ou coluna
oJazigo:SetEdit(.F.) //Define se o relat�rio poder� ser configurado pelo usu�rio no caso de verdadeiro

oDetalhe:SetHeaderPage(.F.) //Define que imprime cabe�alho das c�lulas no topo da p�gina. (Par�metro) Se verdadeiro, aponta que imprime o cabe�alho no topo da p�gina
oDetalhe:SetHeaderSection(.T.) //Define que imprime cabe�alho das c�lulas na quebra de se��o.(Par�metro) Se verdadeiro, aponta que imprime cabe�alho na quebra da se��o
oDetalhe:SetTotalInLine(.F.) //Define que a impress�o dos totalizadores ser� em linha. (Par�metro) Se verdadeiro, imprime os totalizadores em linha

Return(oReport)                                                               
 
/*/=======================================================================================//
{Protheus.doc} PrintReport
Inicia Logica Print Report
//=======================================================================================/*/
Static Function PrintReport(oReport,oJazigo,oDetalhe,oNEnd,oTotalGer)
Local cQry 			:= "" //Query de busca
//Local nOrdem		:= 0
Local nCont			:= 0
Local nCont1		:= 0
Local nTotBase		:= 0
Local nTotalGer		:= 0
Local nInd			:= 0
Local nTotal		:= 0

Local cTipo			:= ""

Local nJzEnd		:= 0


	//Pega os Jazigos contruidos
	If Select("QRYJAZIG1") > 0
		QRYJAZIG1->(DbCloseArea())
	Endif
	
	cQry := "SELECT COUNT(*) ATIVOS "
	cQry += " FROM "+RetSqlName("U10")+" U10 " 
	cQry += " WHERE U10.D_E_L_E_T_ 	<> '*' "
	cQry += " 	AND U10.U10_FILIAL 	= '"+xFilial("U10")+"' "
	cQry += " 	AND U10.U10_STATUS 	= 'S' "
	cQry += " 	AND U10.U10_QUADRA BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQry += " 	AND U10.U10_MODULO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	
	cQry := ChangeQuery(cQry)
	//MemoWrite("c:\temp\"+cPerg+"-1.txt",cQry)
	TcQuery cQry NEW Alias "QRYJAZIG1"
	
	//QRYJAZIG1->(dbEval({|| nCont++}))
	//QRYJAZIG1->(dbGoTop())

	//Pega os Jazigos Livres e Ocupados
	If Select("QRYJAZIG2") > 0
		QRYJAZIG2->(DbCloseArea())
	Endif
	
	cQry := "SELECT 'ENDERECADOS E LIVRES' AS TABELA, U10.U10_QUADRA, U10.U10_MODULO, COUNT(*) AS QTD_JAZIGOS"
	cQry += " FROM "+RetSqlName("U10")+" U10"
	cQry += " WHERE U10.D_E_L_E_T_	<> '*' "
	cQry += " AND U10.U10_FILIAL 	= '"+xFilial("U10")+"' "
	cQry += " AND U10.U10_QUADRA 	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQry += " AND U10.U10_MODULO 	BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	cQry += " AND U10.U10_STATUS 	= 'S' "
	cQry += " AND U10.U10_QUADRA + U10.U10_MODULO + U10.U10_CODIGO IN ("
	cQry += " 	SELECT DISTINCT U04.U04_QUADRA + U04.U04_MODULO + U04.U04_JAZIGO"
	cQry += " 	FROM "+RetSqlName("U04")+" U04 "
	cQry += " 	WHERE U04.D_E_L_E_T_	<> '*' "
	cQry += " 	AND U04.U04_FILIAL		= '"+xFilial("U04")+"' "
	cQry += " 	AND U04.U04_QUADRA		= U10.U10_QUADRA "
	cQry += " 	AND U04.U04_MODULO		= U10.U10_MODULO "
	cQry += " 	AND U04.U04_TIPO		= 'J' "
	cQry += " 	AND U04.U04_DTUTIL 		= '        ' "
	cQry += " 	AND U04.U04_QUADRA + U04.U04_MODULO + U04.U04_JAZIGO NOT IN ("
	cQry += " 		SELECT DISTINCT U04AUX.U04_QUADRA + U04AUX.U04_MODULO + U04AUX.U04_JAZIGO"
	cQry += " 		FROM "+RetSqlName("U04")+" U04AUX "
	cQry += " 		WHERE U04AUX.D_E_L_E_T_	<> '*' "
	cQry += " 		AND U04AUX.U04_FILIAL	= '"+xFilial("U04")+"' "
	cQry += " 		AND U04AUX.U04_QUADRA	= U10.U10_QUADRA "
	cQry += " 		AND U04AUX.U04_MODULO	= U10.U10_MODULO "
	cQry += " 		AND U04AUX.U04_TIPO		= 'J' "
	cQry += " 		AND U04AUX.U04_DTUTIL 	<> '        ')) "
	cQry += " GROUP BY U10.U10_QUADRA, U10.U10_MODULO"
	
	cQry += "UNION"

	cQry += "SELECT 'ENDERECADOS E OCUPADOS' AS TABELA, U10.U10_QUADRA, U10.U10_MODULO, COUNT(*) AS QTD_JAZIGOS"
	cQry += " FROM "+RetSqlName("U10")+" U10"
	cQry += " WHERE U10.D_E_L_E_T_ 	<> '*' "
	cQry += " AND U10.U10_FILIAL 	= '"+xFilial("U10")+"' "
	cQry += " AND U10.U10_QUADRA 	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQry += " AND U10.U10_MODULO 	BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	cQry += " AND U10.U10_STATUS 	= 'S' "
	cQry += " AND U10.U10_QUADRA + U10.U10_MODULO + U10.U10_CODIGO IN ("
	cQry += " 	SELECT DISTINCT U04.U04_QUADRA + U04.U04_MODULO + U04.U04_JAZIGO"
	cQry += " 	FROM "+RetSqlName("U04")+" U04 "
	cQry += " 	WHERE U04.D_E_L_E_T_ 	<> '*' "
	cQry += " 	AND U04.U04_FILIAL 		= '"+xFilial("U04")+"' "
	cQry += " 	AND U04.U04_QUADRA 		= U10.U10_QUADRA "
	cQry += " 	AND U04.U04_MODULO 		= U10.U10_MODULO "
	cQry += " 	AND U04.U04_TIPO 		= 'J' "
	cQry += " 	AND U04.U04_DTUTIL 		<> '        ') "
	cQry += " GROUP BY U10.U10_QUADRA, U10.U10_MODULO"

	cQry += " ORDER BY 1,2,3,4"
	
	cQry := ChangeQuery(cQry)
	//MemoWrite("c:\temp\"+cPerg+"-2.txt",cQry)
	TcQuery cQry NEW Alias "QRYJAZIG2"

	QRYJAZIG2->(dbEval({|| nCont++}))
	QRYJAZIG2->(dbGoTop())

	oReport:SetMeter(nCont) //Define o limite da r�gua de progress�o do relat�rio.

	//Inicializa as Se��es	
	//oReport:Init()
	oJazigo:Init()
	oDetalhe:Init()

	//Cria os totalizadores
	TRFunction():New(oDetalhe:Cell("QTD")		,/* cID */,"SUM"	,/*oBreak*/,"Total",/*cPicture*/,/*uFormula*/,.T. /*lEndSection*/,.F. /*lEndReport*/,/*lEndPage*/)
	
	While !oReport:Cancel() .And. QRYJAZIG2->(!EOF())
		
		If oReport:Cancel()
			Exit
		EndIf

		If cTipo <> QRYJAZIG2->TABELA
			If ! Empty(AllTrim(cTipo))
				oDetalhe:SetTotalText(" ")
				oDetalhe:Finish()
				
				oReport:ThinLine() //Imprime uma linha
				
				oDetalhe:Init() //Inicializa se��o oDetalhe
			EndIf

			oReport:SkipLine()	//Pula uma linha			
			oJazigo:Cell("TIPO"):SetValue(QRYJAZIG2->TABELA) //imprime se�ao do prefixo
			oJazigo:PrintLine() //Imprime linha
			
			// atualiza a variavel do cTipo
		    cTipo := QRYJAZIG2->TABELA
		EndIf
		
		oDetalhe:Cell("U10_QUADRA"):SetValue(QRYJAZIG2->U10_QUADRA)
		oDetalhe:Cell("U10_MODULO"):SetValue(QRYJAZIG2->U10_MODULO)
		oDetalhe:Cell("QTD"):SetValue(QRYJAZIG2->QTD_JAZIGOS)
		
		nJzEnd += QRYJAZIG2->QTD_JAZIGOS

		oDetalhe:PrintLine()
		
		oReport:IncMeter() //Incrementa a r�gua de progress�o do relat�rio

		QRYJAZIG2->(DbSkip())		
	EndDo
	
	oDetalhe:SetTotalText(" ")
	oDetalhe:Finish()
	oReport:ThinLine() //Imprime uma linha	
	oReport:SkipLine()	//Pula uma linha

	oNEnd:Init()
	oNEnd:Cell("nNEnd"):SetValue("Total de Jazigos n�o endere�ados: "+cValToChar(QRYJAZIG1->ATIVOS - nJzEnd))
	oNEnd:PrintLine()
	//oNEnd:SetTotalText(" ")
	oNEnd:Finish()
	
	oTotalGer:Init()
	oTotalGer:Cell("nTotalGer"):SetValue("Total de Jazigos ativos: "+cValToChar(QRYJAZIG1->ATIVOS))
	oTotalGer:PrintLine()
	//oTotalGer:SetTotalText(" ")
	oTotalGer:Finish()
	
	oTotalGer:SetPageBreak(.T.)
	
	oJazigo:Finish()
	
	QRYJAZIG1->(DbCloseArea())
	QRYJAZIG2->(DbCloseArea())
Return

//Fun��o para gerar o grupo de par�metros no SX1
//+-----------------------------------------------------------------+
//| Rotina | CriaSX1 | Autor | Andr� R. Barrero | Data | 05.05.16 |
//+-----------------------------------------------------------------+
//| Descr. | Rotina para criar o grupo de par�metros. |
//+-----------------------------------------------------------------+
//| Uso | Relat�rios. |
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
Par�metros da fun��o padr�o
---------------------------
Nome		Tipo		Descri��o													Obrigat�rio
1-cGrupo	Caracter	Nome do grupo de pergunta									X	
2-cOrdem	Caracter	Ordem de apresenta��o das perguntas na tela					X	
3-cPergunt	Caracter	Texto da pergunta a ser apresentado na tela					X	
4-cPergSpa	Caracter	Texto em espanhol da pergunta a ser apresentado na tela.	X	
5-cPergEng	Caracter	Texto em ingl�s da pergunta a ser apresentado na tela.		X	
6-cVar		Caracter	Vari�vel do item											X	
7-cTipo		Caracter	Tipo do conte�do de resposta da pergunta.					X	
08-nTamanho	Num�rico	Tamanho do campo para resposta								X	
09-nDecimal	Num�rico	N�mero de casas decimais da resposta, se houver		
10-nPreSel	Num�rico	Valor que define qual o item do combo estar� selecionado na 
						apresenta��o da tela. Este par�metro somente dever� ser 
						preenchido quando o par�metro cGSC for preenchido com "C".		
11-cGSC		Caracter	Estilo de apresenta��o da pergunta na tela: - "G" - formato 
						que permite editar o conte�do da pergunta. - "S" - formato 
						de texto que n�o permite altera��o. - "C" - formato que 
						permite a sele��o de dados para a pergunta.					X	
12-cValid	Caracter	Valida��o do item de pergunta		
13-cF3		Caracter	Nome da consulta F3 que poder� ser acionada pela pergunta.		
14-cGrpSXG	Caracter	C�digo do grupo de campos relacionado a pergunta.		
15-cPyme	Caracter	Define se a pergunta poder� ser apresentada em aplica��es do tipo Express.		
16-cVar01	Caracter	Nome do MV_PAR para a utiliza��o nos programas.	X	
17-cDef01	Caracter	Conte�do em portugu�s do primeiro item do objeto, caso seja do tipo Combo.		
18-cDefSpa1	Caracter	Conte�do em espanhol do primeiro item do objeto, caso seja do tipo Combo.		
19-cDefEng1	Caracter	Conte�do em ingl�s do primeiro item do objeto, caso seja do tipo Combo.		
20-cCnt01	Caracter	Conte�do padr�o da pergunta.		
21-cDef02	Caracter	Conte�do em portugu�s do segundo item do objeto, caso seja do tipo Combo.		
22-cDefSpa2	Caracter	Conte�do em espanhol do segundo item do objeto, caso seja do tipo Combo.		
23-cDefEng2	Caracter	Conte�do em ingl�s do segundo item do objeto, caso seja do tipo Combo.		
24-cDef03	Caracter	Conte�do em portugu�s do terceiro item do objeto, caso seja do tipo Combo.		
25-cDefSpa3	Caracter	Conte�do em espanhol do terceiro item do objeto, caso seja do tipo Combo.		
26-cDefEng3	Caracter	Conte�do em ingl�s do terceiro item do objeto, caso seja do tipo Combo.		
27-cDef04	Caracter	Conte�do em portugu�s do quarto item do objeto, caso seja do tipo Combo.		
28-cDefSpa4	Caracter	Conte�do em espanhol do quarto item do objeto, caso seja do tipo Combo.		
29-cDefEng4	Caracter	Conte�do em ingl�s do quarto item do objeto, caso seja do tipo Combo.		
30-cDef05	Caracter	Conte�do em portugu�s do quinto item do objeto, caso seja do tipo Combo.		
31-cDefSpa5	Caracter	Conte�do em espanhol do quinto item do objeto, caso seja do tipo Combo.		
32-cDefEng5	Caracter	Conte�do em ingl�s do quinto item do objeto, caso seja do tipo Combo.		
33-aHelpPor	Vetor		Help descritivo da pergunta em Portugu�s.		
34-aHelpEng	Vetor		Help descritivo da pergunta em Ingl�s.		
35-aHelpSpa	Vetor		Help descritivo da pergunta em Espanhol.		
36-cHelp	Caracter	Nome do help equivalente, caso j� exista um no sistema.

Caracter�stica do vetor p/ utiliza��o da fun��o SX1
---------------------------------------------------
[n,1] --> texto da pergunta
[n,2] --> tipo do dado
[n,3] --> tamanho
[n,4] --> decimal
[n,5] --> objeto G=get ou C=choice
[n,6] --> valida��o
[n,7] --> F3
[n,8] --> Inicializador padr�o
[n,9] --> defini��o 1
[n,10] -> defini��o 2
[n,11] -> defini��o 3
[n,12] -> defini��o 4
[n,13] -> defini��o 5
***/
        //1					  ,2  ,3 ,4,5  ,6					  ,7	,8 		 ,9 ,10,11,12,13
AADD(aP,{"Quadra de     	?","C",06,0,"G",""					  ,"U08","      ","","","","",""})
AADD(aP,{"Quadra at�	 ?"   ,"C",06,0,"G","(mv_par02>=mv_par01)","U08","ZZZZZZ","","","","",""})
AADD(aP,{"M�dulo de        	?","C",06,0,"G",""					  ,"U09","      ","","","","",""})
AADD(aP,{"M�dulo at�       	?","C",06,0,"G","(mv_par04>=mv_par03)","U09","ZZZZZZ","","","","",""})

AADD(aHelp,{"Informe a quadra.","inicial."})
AADD(aHelp,{"Informe a quadra.","final."})
AADD(aHelp,{"Informe o m�dulo.","inicial."})
AADD(aHelp,{"Informe o m�dulo.","final."})

//��������������������������������������������������������������Ŀ
//� Ajusta grupo de perguntas "cPerg"	                         �
//����������������������������������������������������������������
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