#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RCPGR017
Impressão de Relatório Livro de Sepultamento
Orientação do tipo Paisagem
@type function
@version 1.0
@author André R. Barrero
@since 25/05/2016
/*/
User Function RCPGR017()
	Local oReport

	oReport:= ReportDef()
	oReport:PrintDialog()

Return(Nil)

/*/{Protheus.doc} ReportDef
Na seção de definição do relatório, função ReportDef(), 
devem ser criados os componentes de impressão,
as seções e as células, os totalizadores e demais 
componentes que o usuário poderá personalizar no relatório.
@type function
@version 1.0 
@author g.sampaio
@since 03/01/2024
/*/
Static Function ReportDef()
	Local oReport
	Local oSepulta
	Local oDetalhe
	Local oTotalGer
	Local cTitle    	:= "Relatório Livro de Sepultamento - Contratos"

	Private cPerg		:= "RCPGR017"

	oReport	:= TReport():New("RCPGR017",cTitle,"RCPGR017",{|oReport| PrintReport(oReport,oSepulta,oDetalhe,oTotalGer)},"Este relatório apresenta a relação de Sepultamento.")
	oReport:SetLandscape()			// Orientação paisagem
	oReport:HideParamPage()			// Inibe impressão da pagina de parametros
	oReport:SetUseGC( .F. ) 		// Desabilita o botão <Gestao Corporativa> do relatório
//oReport:nFontBody	:= 10
//oReport:SetLineHeight(50)
//oReport:SetColSpace(2)

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
	oSepulta 	:= TRSection():New(oReport,"Sepultamento",{"QRYSEPUL"})//,{"Por Contrato","Por Cod. Cliente","Por Nome Cliente"}/*Ordens do Relatório*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSepulta:SetTotalInLine(.T.) //Define se os totalizadores serão impressos em linha ou coluna

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oDetalhe := TRSection():New(oSepulta,"Detalhe",{"QRYSEPUL"})

	oDetalhe:SetHeaderPage(.T.) //Define que imprime cabeçalho das células no topo da página. (Parâmetro) Se verdadeiro, aponta que imprime o cabeçalho no topo da página
	oDetalhe:SetHeaderSection(.T.) //Define que imprime cabeçalho das células na quebra de seção.(Parâmetro) Se verdadeiro, aponta que imprime cabeçalho na quebra da seção
	oDetalhe:SetTotalInLine(.T.) //Define que a impressão dos totalizadores será em linha. (Parâmetro) Se verdadeiro, imprime os totalizadores em linha

	TRCell():New(oDetalhe,"U04_CODIGO"	,"QRYSEPUL","CONTRATO"		,	PesqPict("U04","U04_CODIGO"	),TamSX3("U04_CODIGO"	)[1]+1)
	TRCell():New(oDetalhe,"U04_QUEMUT"	,"QRYSEPUL","SEPULTADO"		,	PesqPict("U04","U04_QUEMUT"	),TamSX3("U04_QUEMUT"	)[1]+1)
	TRCell():New(oDetalhe,"U04_QUADRA"	,"QRYSEPUL","QUADRA"		, 	PesqPict("U04","U04_QUADRA"	),TamSX3("U04_QUADRA"	)[1]+1)
	TRCell():New(oDetalhe,"U04_MODULO"	,"QRYSEPUL","MODULO"		, 	PesqPict("U04","U04_MODULO"	),TamSX3("U04_MODULO"	)[1]+1)
	TRCell():New(oDetalhe,"U04_JAZIGO"	,"QRYSEPUL","JAZIGO"		, 	PesqPict("U04","U04_JAZIGO"	),TamSX3("U04_JAZIGO"	)[1]+1)
	TRCell():New(oDetalhe,"U04_GAVETA"	,"QRYSEPUL","GAVETA"		, 	PesqPict("U04","U04_GAVETA"	),TamSX3("U04_GAVETA"	)[1]+1)
	TRCell():New(oDetalhe,"U04_DTUTIL"	,"QRYSEPUL","DATA"			,	PesqPict("U04","U04_DATA"	),TamSX3("U04_DATA"		)[1]+3)
	TRCell():New(oDetalhe,"U00_NOMCLI"	,"QRYSEPUL","CESSIONARIO"	,	PesqPict("U00","U00_NOMCLI"	),TamSX3("U00_NOMCLI"	)[1]+1)

// Alinhamento a direita dos campos de valores
//oDetalhe:Cell("U00_VLRADE"):SetHeaderAlign("RIGHT")

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oTotalGer := TRSection():New(oReport,"Total Geral",{}) //TRSection():New(oReport,"Total Geral",{},,,,,,,,,,,.T.,,,,,1)
	oTotalGer:SetHeaderPage(.F.) //Define que imprime cabeçalho das células no topo da página. (Parâmetro) Se verdadeiro, aponta que imprime o cabeçalho no topo da página
	oTotalGer:SetHeaderSection(.T.) //Define que imprime cabeçalho das células na quebra de seção.(Parâmetro) Se verdadeiro, aponta que imprime cabeçalho na quebra da seção
	oTotalGer:SetTotalInLine(.T.) //Define que a impressão dos totalizadores será em linha. (Parâmetro) Se verdadeiro, imprime os totalizadores em linha

	TRCell():New(oTotalGer,"nTotalGer", , " ", "!@", 30)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Impressao do Cabecalho no topo da pagina
//oReport:Section(1):SetHeaderPage()
	oReport:Section(1):SetHeaderPage(.T.)
	oReport:Section(1):SetEdit(.T.)
	oReport:Section(2):SetEdit(.T.)
	oDetalhe:SetEdit(.T.)

Return(oReport)

/*/{Protheus.doc} PrintReport
Inicia Logica Print Report
//==============================
@type function()
@version 1.0
@author g.sampaio
@since 03/01/2024
@param oReport, object, objeto do relatorio
@param oSepulta, object, objeto da secao de sepultamento
@param oDetalhe, object, objeto de detalhes
@param oTotalGer, object, objeto de total
/*/
Static Function PrintReport(oReport,oSepulta,oDetalhe,oTotalGer)
	Local cQry 			:= "" //Query de busca
	Local nCont			:= 0
	Local nInd			:= 0
	Local nTotal		:= 0

	If Select("QRYSEPUL") > 0
		QRYSEPUL->(DbCloseArea())
	Endif

	cQry := "SELECT 'TABU04' AS TABELA,U04_FILIAL AS U04_FILIAL,U04.U04_CODIGO AS U04_CODIGO,U04.U04_ITEM AS U04_ITEM,"
	cQry += "	U04.U04_QUADRA AS U04_QUADRA,U04.U04_MODULO AS U04_MODULO,U04.U04_JAZIGO AS U04_JAZIGO,"
	cQry += "	U04.U04_GAVETA AS U04_GAVETA,U04.U04_DATA AS U04_DATA,U04.U04_DTUTIL AS U04_DTUTIL,"
	cQry += "	U04.U04_QUEMUT AS U04_QUEMUT,U00.U00_PLANO AS U00_PLANO,U00.U00_DESCPL AS U00_DESCPL,U00.U00_NOMCLI AS U00_NOMCLI"
	cQry += "FROM "+RetSqlName("U04")+" U04 INNER JOIN "+RetSqlName("U00")+" U00 "
	cQry += "	ON U04.U04_CODIGO = U00.U00_CODIGO "
	cQry += "	AND U00.D_E_L_E_T_ <> '*' "
	cQry += " 	AND U00.U00_FILIAL 	= '"+xFilial("U00")+"' "
	cQry += "WHERE  U04.D_E_L_E_T_ <> '*' "
	cQry += " 	AND U04.U04_FILIAL 	= '"+xFilial("U04")+"' "
	cQry += "	AND U04.U04_TIPO = 'J' "
	cQry += " 	AND U04.U04_OCUPAG = 'S'"
	cQry += "	AND U04.U04_DTUTIL <> '' "
	cQry += " 	AND U04.U04_CODIGO	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQry += " 	AND U00.U00_PLANO	BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "

	If !Empty(MV_PAR05) .And. !Empty(MV_PAR06)
		cQry += " 	AND U04.U04_DTUTIL 	BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' "
	EndIf

	 // imprime o historico
	If MV_PAR07 == 1

		cQry += " UNION ALL "

		cQry += "SELECT 'TABU30' AS TABELA,U30_FILIAL AS U04_FILIAL,U30.U30_CODIGO AS U04_CODIGO,U30.U30_ITEM AS U04_ITEM,"
		cQry += "	U30.U30_QUADRA AS U04_QUADRA,U30.U30_MODULO AS U04_MODULO,U30.U30_JAZIGO AS U04_JAZIGO,"
		cQry += "	U30.U30_GAVETA AS U04_GAVETA,U30.U30_DTHIST AS U04_DATA,U30.U30_DTUTIL AS U04_DTUTIL,"
		cQry += "	U30.U30_QUEMUT AS U04_QUEMUT,U00.U00_PLANO AS U00_PLANO,U00.U00_DESCPL AS U00_DESCPL,U00.U00_NOMCLI AS U00_NOMCLI"
		cQry += "FROM "+RetSqlName("U30")+" U30 INNER JOIN "+RetSqlName("U00")+" U00 "
		cQry += "	ON U30.U30_CODIGO = U00.U00_CODIGO "
		cQry += "	AND U00.D_E_L_E_T_ <> '*' "
		cQry += " 	AND U00.U00_FILIAL 	= '"+xFilial("U00")+"' "
		cQry += "WHERE  U30.D_E_L_E_T_ <> '*' "
		cQry += "	AND U30.U30_FILIAL = '"+xFilial("U04")+"' "
		cQry += "	AND U30.U30_DTUTIL <> ' ' "
		cQry += "	AND U30.U30_CODIGO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
		cQry += "	AND U00.U00_PLANO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "

		If !Empty(MV_PAR05) .And. !Empty(MV_PAR06)
			cQry += " 	AND U30.U30_DTUTIL 	BETWEEN '" + DTOS(MV_PAR05) + "' AND '" + DTOS(MV_PAR06) + "' "
		EndIf

	EndIf

	cQry += "ORDER BY U04_QUEMUT"

	cQry := ChangeQuery(cQry)
	//MemoWrite("c:\temp\"+cPerg+".txt",cQry)
	TcQuery cQry NEW Alias "QRYSEPUL"

	QRYSEPUL->(dbEval({|| nCont++}))
	QRYSEPUL->(dbGoTop())

	oReport:SetMeter(nCont)
	//oReport:Init()

	oSepulta:Init()

	oDetalhe:Init()
	TRFunction():New(oDetalhe:Cell("U04_CODIGO"),/* cID */,"COUNT",/*oBreak*/,"Quantidade",/*cPicture*/,/*uFormula*/,.T. /*lEndSection*/,.F. /*lEndReport*/,/*lEndPage*/)

	While !oReport:Cancel() .And. QRYSEPUL->(!EOF())

		oReport:IncMeter()

		If oReport:Cancel()
			Exit
		EndIf

		oDetalhe:Cell("U04_CODIGO"):SetValue(QRYSEPUL->U04_CODIGO)
		oDetalhe:Cell("U04_QUEMUT"):SetValue(AllTrim(QRYSEPUL->U04_QUEMUT))
		oDetalhe:Cell("U04_QUADRA"):SetValue(QRYSEPUL->U04_QUADRA)
		oDetalhe:Cell("U04_MODULO"):SetValue(QRYSEPUL->U04_MODULO)
		oDetalhe:Cell("U04_JAZIGO"):SetValue(QRYSEPUL->U04_JAZIGO)
		oDetalhe:Cell("U04_GAVETA"):SetValue(QRYSEPUL->U04_GAVETA)
		oDetalhe:Cell("U04_DTUTIL"):SetValue(StoD(QRYSEPUL->U04_DTUTIL))
		oDetalhe:Cell("U00_NOMCLI"):SetValue(AllTrim(QRYSEPUL->U00_NOMCLI))

		nInd++

		oDetalhe:PrintLine()

		QRYSEPUL->(dbSkip())
	EndDo

	oDetalhe:SetTotalText(" ")
	oDetalhe:Finish()

	oReport:SkipLine()	//Pula uma linha
	oReport:ThinLine()	//Imprime uma linha

	nTotal	+= nInd
	nInd	:= 0

	oSepulta:Finish()

	QRYSEPUL->(dbCloseArea())

Return(Nil)

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
AADD(aP,{"Contrato de       	?","C",06,0,"G",""					  ,"U00","      ","","","","",""})
AADD(aP,{"Contrato até      	?","C",06,0,"G","(mv_par02>=mv_par01)","U00","ZZZZZZ","","","","",""})
AADD(aP,{"Plano de        		?","C",06,0,"G",""					  ,"U05","      ","","","","",""})
AADD(aP,{"Plano até        		?","C",06,0,"G","(mv_par04>=mv_par03)","U05","ZZZZZZ","","","","",""})
AADD(aP,{"Data de				?","D",08,0,"G",""					  ,""   ,""		 ,"","","","",""})
AADD(aP,{"Data até				?","D",08,0,"G","(mv_par06>=mv_par05)",""   ,""		 ,"","","","",""})
AADD(aP,{"Considera Historico 	?","N",01,0,"C",""					  ,""	,"1"	,"Sim","Não","","",""})

AADD(aHelp,{"Informe o código do contrato.","inicial."})
AADD(aHelp,{"Informe o código do contrato.","final."})
AADD(aHelp,{"Informe o código do plano.","inicial."})
AADD(aHelp,{"Informe o código do plano.","final."})
AADD(aHelp,{"Informe a data.","inicial."})
AADD(aHelp,{"Informe a data.","final."})
AADD(aHelp,{"Considero o Historico do Contrato.","Historico."})

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

	For i := 1 To Len(aP)

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

Return(Nil)
