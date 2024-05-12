#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RCPGR018
Impressão de Relatório de Jazigo
Orientação do tipo Paisagem
@author André R. Barrero
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
Na seção de definição do relatório, função ReportDef(), devem ser criados os componentes de impressão, 
as seções e as células, os totalizadores e demais componentes que o usuário poderá personalizar no relatório.
//=============================================================================================================/*/
Static Function ReportDef()
Local oReport
Local oJazigo
Local oDetalhe
Local oNEnd
Local oTotalGer
Local cTitle    	:= "Relatório Jazigos"

Local cTIPO			:= ""

Private cPerg		:= "RCPGR018"

oReport	:= TReport():New("RCPGR018",cTitle,"RCPGR018",{|oReport| PrintReport(oReport,oJazigo,oDetalhe,oNEnd,oTotalGer)},"Este relatório apresenta a relação de Jazigos.")
oReport:SetPortrait() 		// Orientação retrato
//oReport:SetLandscape()			// Orientação paisagem 
//oReport:HideHeader()  		// Nao imprime cabeçalho padrão do Protheus
//oReport:HideFooter()			// Nao imprime rodapé padrão do Protheus
oReport:HideParamPage()			// Inibe impressão da pagina de parametros
oReport:SetUseGC( .F. ) 		// Desabilita o botão <Gestao Corporativa> do relatório
//oReport:DisableOrientation()  // Desabilita a seleção da orientação (retrato/paisagem)
oReport:nFontBody	:= 10
oReport:SetLineHeight(50)
oReport:SetColSpace(2)

CriaSx1(cPerg) // cria as perguntas para gerar o relatorio
Pergunte(oReport:GetParam(),.F.)

//ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//Criacao da secao utilizada pelo relatorio                               
//                                                                        
//TRSection():New                                                         
//ExpO1 : Objeto TReport que a secao pertence                             
//ExpC2 : Descricao da seção                                              
//ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   
//        sera considerada como principal para a seção.                   
//ExpA4 : Array com as Ordens do relatorio                                
//ExpL5 : Carrega campos do SX3 como celulas                              
//        Default : False                                                 
//ExpL6 : Carrega ordens do Sindex                                        
//        Default : False                                                 
//                                                                        
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
//ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//Criacao da celulas da secao do relatorio                                
//                                                                        
//TRCell():New                                                            
//ExpO1 : Objeto TSection que a secao pertence                            
//ExpC2 : Nome da celula do relatório. O SX3 será consultado              
//ExpC3 : Nome da tabela de referencia da celula                          
//ExpC4 : Titulo da celula                                                
//        Default : X3Titulo()                                            
//ExpC5 : Picture                                                         
//        Default : X3_PICTURE                                            
//ExpC6 : Tamanho                                                         
//        Default : X3_TAMANHO                                            
//ExpL7 : Informe se o tamanho esta em pixel                              
//        Default : False                                                 
//ExpB8 : Bloco de código para impressao.                                 
//        Default : ExpC2                                                 
//                                                                        
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
oJazigo 	:= TRSection():New(oReport,"Jazigos",{"QRYJAZIG1"},{"Por Quadra + Modulo"}/*Ordens do Relatório*/,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oJazigo,"TIPO"	,,cTIPO	,PesqPict("U00","U00_DESCPL"),TamSX3("U00_DESCPL"	)[1]+1	)
		
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
oDetalhe := TRSection():New(oJazigo,"Detalhe",{"QRYJAZIG1"})

TRCell():New(oDetalhe,"U10_QUADRA"	,"QRYJAZIG2","QUADRA"	 ,PesqPict("U10","U10_QUADRA"),TamSX3("U10_QUADRA"	)[1]+1)
TRCell():New(oDetalhe,"U10_MODULO"	,"QRYJAZIG2","MODULO"	 ,PesqPict("U10","U10_MODULO"),TamSX3("U10_MODULO"	)[1]+1)
TRCell():New(oDetalhe,"QTD"			,"QRYJAZIG2","QUANTIDADE","@E 999,999,999",20)
	
// Alinhamento a direita dos campos de valores //Tipo Caracter: "LEFT" – esquerda, "RIGHT" – direita e "CENTER" - centro
oDetalhe:Cell("QUADRA")	:SetHeaderAlign("CENTER")
oDetalhe:Cell("MODULO")	:SetHeaderAlign("CENTER")
oDetalhe:Cell("QTD")	:SetHeaderAlign("CENTER")

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
oTotalGer := TRSection():New(oReport,"Jazigos ativos",{}) //TRSection():New(oReport,"Total Geral",{},,,,,,,,,,,.T.,,,,,1)
oTotalGer:SetHeaderPage(.F.) //Define que imprime cabeçalho das células no topo da página. (Parâmetro) Se verdadeiro, aponta que imprime o cabeçalho no topo da página
oTotalGer:SetHeaderSection(.T.) //Define que imprime cabeçalho das células na quebra de seção.(Parâmetro) Se verdadeiro, aponta que imprime cabeçalho na quebra da seção
oTotalGer:SetTotalInLine(.T.) //Define que a impressão dos totalizadores será em linha. (Parâmetro) Se verdadeiro, imprime os totalizadores em linha

TRCell():New(oTotalGer,"nTotalGer", , " ", "!@", 100)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
oNEnd := TRSection():New(oReport,"Jazigos não endereçados",{}) //TRSection():New(oReport,"Total Geral",{},,,,,,,,,,,.T.,,,,,1)
oNEnd:SetHeaderPage(.F.) //Define que imprime cabeçalho das células no topo da página. (Parâmetro) Se verdadeiro, aponta que imprime o cabeçalho no topo da página
oNEnd:SetHeaderSection(.T.) //Define que imprime cabeçalho das células na quebra de seção.(Parâmetro) Se verdadeiro, aponta que imprime cabeçalho na quebra da seção
oNEnd:SetTotalInLine(.T.) //Define que a impressão dos totalizadores será em linha. (Parâmetro) Se verdadeiro, imprime os totalizadores em linha

TRCell():New(oNEnd,"nNEnd", , " ", "!@", 100)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Impressao do Cabecalho no topo da pagina
oReport:Section(1):SetHeaderPage(.F.) //Define que imprime cabeçalho das células no topo da página
oReport:Section(1):SetHeaderBreak(.F.) //Define se imprime cabeçalho das células após uma quebra (TRBreak).
oReport:Section(1):SetHeaderSection(.F.) //Define que imprime cabeçalho das células na quebra de seção
oReport:Section(1):SetLineStyle(.T.) //Define se imprime as células da seção em linhas
oReport:Section(1):SetEdit(.F.) //Define se o relatório poderá ser configurado pelo usuário no caso de verdadeiro

oJazigo:SetHeaderPage(.F.) //Define que imprime cabeçalho das células no topo da página
oJazigo:SetHeaderBreak(.F.) //Define se imprime cabeçalho das células após uma quebra (TRBreak).
oJazigo:SetHeaderSection(.F.) //Define que imprime cabeçalho das células na quebra de seção
oJazigo:SetLineStyle(.T.) //Define se imprime as células da seção em linhas
oJazigo:SetTotalInLine(.F.) //Define se os totalizadores serão impressos em linha ou coluna
oJazigo:SetEdit(.F.) //Define se o relatório poderá ser configurado pelo usuário no caso de verdadeiro

oDetalhe:SetHeaderPage(.F.) //Define que imprime cabeçalho das células no topo da página. (Parâmetro) Se verdadeiro, aponta que imprime o cabeçalho no topo da página
oDetalhe:SetHeaderSection(.T.) //Define que imprime cabeçalho das células na quebra de seção.(Parâmetro) Se verdadeiro, aponta que imprime cabeçalho na quebra da seção
oDetalhe:SetTotalInLine(.F.) //Define que a impressão dos totalizadores será em linha. (Parâmetro) Se verdadeiro, imprime os totalizadores em linha

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

	oReport:SetMeter(nCont) //Define o limite da régua de progressão do relatório.

	//Inicializa as Seções	
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
				
				oDetalhe:Init() //Inicializa seção oDetalhe
			EndIf

			oReport:SkipLine()	//Pula uma linha			
			oJazigo:Cell("TIPO"):SetValue(QRYJAZIG2->TABELA) //imprime seçao do prefixo
			oJazigo:PrintLine() //Imprime linha
			
			// atualiza a variavel do cTipo
		    cTipo := QRYJAZIG2->TABELA
		EndIf
		
		oDetalhe:Cell("U10_QUADRA"):SetValue(QRYJAZIG2->U10_QUADRA)
		oDetalhe:Cell("U10_MODULO"):SetValue(QRYJAZIG2->U10_MODULO)
		oDetalhe:Cell("QTD"):SetValue(QRYJAZIG2->QTD_JAZIGOS)
		
		nJzEnd += QRYJAZIG2->QTD_JAZIGOS

		oDetalhe:PrintLine()
		
		oReport:IncMeter() //Incrementa a régua de progressão do relatório

		QRYJAZIG2->(DbSkip())		
	EndDo
	
	oDetalhe:SetTotalText(" ")
	oDetalhe:Finish()
	oReport:ThinLine() //Imprime uma linha	
	oReport:SkipLine()	//Pula uma linha

	oNEnd:Init()
	oNEnd:Cell("nNEnd"):SetValue("Total de Jazigos não endereçados: "+cValToChar(QRYJAZIG1->ATIVOS - nJzEnd))
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
        //1					  ,2  ,3 ,4,5  ,6					  ,7	,8 		 ,9 ,10,11,12,13
AADD(aP,{"Quadra de     	?","C",06,0,"G",""					  ,"U08","      ","","","","",""})
AADD(aP,{"Quadra até	 ?"   ,"C",06,0,"G","(mv_par02>=mv_par01)","U08","ZZZZZZ","","","","",""})
AADD(aP,{"Módulo de        	?","C",06,0,"G",""					  ,"U09","      ","","","","",""})
AADD(aP,{"Módulo até       	?","C",06,0,"G","(mv_par04>=mv_par03)","U09","ZZZZZZ","","","","",""})

AADD(aHelp,{"Informe a quadra.","inicial."})
AADD(aHelp,{"Informe a quadra.","final."})
AADD(aHelp,{"Informe o módulo.","inicial."})
AADD(aHelp,{"Informe o módulo.","final."})

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