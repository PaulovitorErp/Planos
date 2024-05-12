#include "protheus.ch"
#include "topconn.ch"

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RCPGR026
Impressão de Relatório Contratos + Sepultados 
Orientação do tipo Paisagem
@author Maiki Perin
@since 04/08/2018
@version P12
/*/

/***********************/
User Function RCPGR026()
/***********************/

	Local oReport

	oReport:= ReportDef()
	oReport:PrintDialog()

Return

/**************************/
Static Function ReportDef()
/**************************/

	Local oReport
	Local oSepulta
	Local oDetalhe
	Local oTotal
	Local oTotalGer
	Local cTitle    	:= "Relatório Contratos + Sepultados"

	Private cPerg		:= "RCPGR026"

	oReport	:= TReport():New("RCPGR026",cTitle,"RCPGR026",{|oReport| PrintReport(oReport,oSepulta,oDetalhe,oTotalGer)},"Este relatório apresenta a relação de Sepultados.")
	oReport:SetLandscape()			// Orientação paisagem
	oReport:HideParamPage()			// Inibe impressão da pagina de parametros
	oReport:SetUseGC( .F. ) 		// Desabilita o botão <Gestao Corporativa> do relatório

	CriaSx1(cPerg) // cria as perguntas para gerar o relatorio
	Pergunte(oReport:GetParam(),.F.)

	oSepulta 	:= TRSection():New(oReport,"Sepultamento",{"QRYSEPUL"})//,{"Por Contrato","Por Cod. Cliente","Por Nome Cliente"}/*Ordens do Relatório*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oSepulta:SetTotalInLine(.T.) //Define se os totalizadores serão impressos em linha ou coluna

	oDetalhe := TRSection():New(oSepulta,"Detalhe",{"QRYSEPUL"})

	oDetalhe:SetHeaderPage(.T.) //Define que imprime cabeçalho das células no topo da página. (Parâmetro) Se verdadeiro, aponta que imprime o cabeçalho no topo da página
	oDetalhe:SetHeaderSection(.T.) //Define que imprime cabeçalho das células na quebra de seção.(Parâmetro) Se verdadeiro, aponta que imprime cabeçalho na quebra da seção
	oDetalhe:SetTotalInLine(.T.) //Define que a impressão dos totalizadores será em linha. (Parâmetro) Se verdadeiro, imprime os totalizadores em linha

	TRCell():New(oDetalhe,"U04_CODIGO"	,"QRYSEPUL","CONTRATO"		,	PesqPict("U04","U04_CODIGO"	),TamSX3("U04_CODIGO"	)[1]+1)
	TRCell():New(oDetalhe,"U04_QUEMUT"	,"QRYSEPUL","SEPULTADO"		,	PesqPict("U04","U04_QUEMUT"	),TamSX3("U04_QUEMUT"	)[1]+1)
	TRCell():New(oDetalhe,"U00_NOMCLI"	,"QRYSEPUL","CESSIONARIO"	,	PesqPict("U00","U00_NOMCLI"	),TamSX3("U00_NOMCLI"	)[1]+1)
	TRCell():New(oDetalhe,"U00_DDD"		,"QRYSEPUL","DDD"			, 	PesqPict("U00","U00_DDD"	),TamSX3("U00_DDD"	)[1]+1)
	TRCell():New(oDetalhe,"U00_TEL"		,"QRYSEPUL","TEL"			, 	PesqPict("U00","U00_TEL"	),TamSX3("U00_TEL"	)[1]+1)
	TRCell():New(oDetalhe,"U00_EMAIL"	,"QRYSEPUL","EMAIL"			, 	PesqPict("U00","U00_EMAIL"	),TamSX3("U00_EMAIL"	)[1]+1)

	oTotalGer := TRSection():New(oReport,"Total Geral",{}) //TRSection():New(oReport,"Total Geral",{},,,,,,,,,,,.T.,,,,,1)
	oTotalGer:SetHeaderPage(.F.) //Define que imprime cabeçalho das células no topo da página. (Parâmetro) Se verdadeiro, aponta que imprime o cabeçalho no topo da página
	oTotalGer:SetHeaderSection(.T.) //Define que imprime cabeçalho das células na quebra de seção.(Parâmetro) Se verdadeiro, aponta que imprime cabeçalho na quebra da seção
	oTotalGer:SetTotalInLine(.T.) //Define que a impressão dos totalizadores será em linha. (Parâmetro) Se verdadeiro, imprime os totalizadores em linha

	TRCell():New(oTotalGer,"nTotalGer", , " ", "!@", 30)

	oReport:Section(1):SetHeaderPage(.T.)
	oReport:Section(1):SetEdit(.T.)
	oReport:Section(2):SetEdit(.T.)
	oDetalhe:SetEdit(.T.)

Return(oReport)

/***************************************************************/
Static Function PrintReport(oReport,oSepulta,oDetalhe,oTotalGer)
/***************************************************************/

	Local cQry 			:= ""
	Local nCont			:= 0
	Local nCont1		:= 0
	Local nTotBase		:= 0
	Local nTotalGer		:= 0
	Local nInd			:= 0
	Local nTotal		:= 0

	If Select("QRYSEPUL") > 0
		QRYSEPUL->(DbCloseArea())
	Endif

	cQry := "SELECT U04.U04_CODIGO AS U04_CODIGO,U04.U04_QUEMUT AS U04_QUEMUT,U00.U00_NOMCLI AS U00_NOMCLI,U00.U00_DDD,U00.U00_TEL,"
	cQry += " U00.U00_EMAIL"
	cQry += " FROM "+RetSqlName("U04")+" U04 INNER JOIN "+RetSqlName("U00")+" U00 "
	cQry += "	ON U04.U04_CODIGO = U00.U00_CODIGO "
	cQry += "	AND U00.D_E_L_E_T_ <> '*' "
	cQry += " 	AND U00.U00_FILIAL 	= '"+xFilial("U00")+"' "
	cQry += " 	AND U00.U00_CODIGO	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQry += " 	AND U00.U00_CLIENT	BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' "
	cQry += " 	AND U00.U00_LOJA	BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' "
	cQry += " WHERE  U04.D_E_L_E_T_ <> '*' "
	cQry += " 	AND U04.U04_FILIAL 	= '"+xFilial("U04")+"' "
	cQry += "	AND U04.U04_TIPO = 'J' "
	cQry += "	AND U04.U04_DTUTIL <> ' ' "

	If !Empty(MV_PAR07) .And. !Empty(MV_PAR08)
		cQry += " 	AND U04.U04_DTUTIL 	BETWEEN '" + DTOS(MV_PAR07) + "' AND '" + DTOS(MV_PAR08) + "' "
	EndIf

	If !Empty(MV_PAR09) //Nome sepultado
		cQry += " 	AND U04.U04_QUEMUT	LIKE '%"+AllTrim(MV_PAR09)+"%' "
	Endif

	// impressao 
	If MV_PAR10 == 1

		cQry += " UNION ALL "
		cQry += " SELECT U30.U30_CODIGO AS U04_CODIGO,U30.U30_QUEMUT AS U04_QUEMUT,U00.U00_NOMCLI AS U00_NOMCLI,U00.U00_DDD,U00.U00_TEL,"
		cQry += " U00.U00_EMAIL"
		cQry += " FROM "+RetSqlName("U30")+" U30 INNER JOIN "+RetSqlName("U00")+" U00 "
		cQry += "	ON U30.U30_CODIGO = U00.U00_CODIGO "
		cQry += "	AND U00.D_E_L_E_T_ <> '*' "
		cQry += " 	AND U00.U00_FILIAL 	= '"+xFilial("U00")+"' "
		cQry += " 	AND U00.U00_CODIGO	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
		cQry += " 	AND U00.U00_CLIENT	BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' "
		cQry += " 	AND U00.U00_LOJA	BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' "
		cQry += "WHERE  U30.D_E_L_E_T_ <> '*' "
		cQry += "	AND U30.U30_FILIAL = '"+xFilial("U04")+"' "
		cQry += "	AND U30.U30_DTUTIL <> ' ' "

		If !Empty(MV_PAR07) .And. !Empty(MV_PAR08)
			cQry += " 	AND U30.U30_DTUTIL 	BETWEEN '" + DTOS(MV_PAR07) + "' AND '" + DTOS(MV_PAR08) + "' "
		EndIf

		If !Empty(MV_PAR09) //Nome sepultado
			cQry += " 	AND U30.U30_QUEMUT LIKE '%"+AllTrim(MV_PAR09)+"%' "
		Endif

	EndIf

	cQry += "ORDER BY U04_QUEMUT"

	cQry := ChangeQuery(cQry)

	//MemoWrite("c:\temp\RCPGR026.txt",cQry)
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
		oDetalhe:Cell("U00_NOMCLI"):SetValue(AllTrim(QRYSEPUL->U00_NOMCLI))
		oDetalhe:Cell("U04_QUEMUT"):SetValue(AllTrim(QRYSEPUL->U04_QUEMUT))
		oDetalhe:Cell("U00_DDD"):SetValue(QRYSEPUL->U00_DDD)
		oDetalhe:Cell("U00_TEL"):SetValue(QRYSEPUL->U00_TEL)
		oDetalhe:Cell("U00_EMAIL"):SetValue(QRYSEPUL->U00_EMAIL)

		nInd++

		oDetalhe:PrintLine()

		QRYSEPUL->(DbSkip())

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

/*********************************/
Static Function CriaSx1(cPergunta)
/*********************************/

	Local aP 		:= {}
	Local i 		:= 0
	Local cSeq
	Local cMvCh
	Local cMvPar
	Local aHelp 	:= {}
	Local nTamSX1   := 10
	Local ind		:= 0 //Contador para deletar SX1

	AAdd(aP,{"Contrato de       ?","C",06,0,"G",""					  ,"U00","      ","","","","",""})
	AAdd(aP,{"Contrato até      ?","C",06,0,"G","(mv_par02>=mv_par01)","U00","ZZZZZZ","","","","",""})
	AADD(aP,{"Cliente de       	?","C",06,0,"G",""						,"SA1","      ","","","","",""})
	AADD(aP,{"Loja de       	?","C",02,0,"G",""						,""	  ,"  "	   ,"","","","",""})
	AADD(aP,{"Cliente até      	?","C",06,0,"G","(mv_par05>=mv_par03)"	,"SA1","ZZZZZZ","","","","",""})
	AADD(aP,{"Loja até       	?","C",02,0,"G","(mv_par06>=mv_par04)"	,""	  ,"ZZ"	   ,"","","","",""})
	AAdd(aP,{"Data de			?","D",08,0,"G",""					  ,""   ,""		 ,"","","","",""})
	AAdd(aP,{"Data até			?","D",08,0,"G","(mv_par08>=mv_par07)",""   ,""		 ,"","","","",""})
	AAdd(aP,{"Nome sepultado    ?","C",40,0,"G",""					  ,"",Space(40),"","","","",""})
	AADD(aP,{"Considera Historico 	?","N",01,0,"C",""					  ,""	,"1"	,"Sim","Não","","",""})

	AAdd(aHelp,{"Informe o código do contrato.","inicial."})
	AAdd(aHelp,{"Informe o código do contrato.","final."})
	AAdd(aHelp,{"Informe o código do cliente.","inicial."})
	AAdd(aHelp,{"Informe o código da loja.","inicial."})
	AAdd(aHelp,{"Informe o código do cliente.","final."})
	AAdd(aHelp,{"Informe o código da loja.","inicial."})
	AAdd(aHelp,{"Informe a data sepultamento.","inicial."})
	AAdd(aHelp,{"Informe a data sepultamento.","final."})
	AAdd(aHelp,{"Informe o nome do sepultado.",""})
	AADD(aHelp,{"Considero o Historico do Contrato.","Historico."})

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
