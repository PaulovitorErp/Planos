#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} RCPGR032
Relatorio de Ossuario
@type function
@version 1,0 
@author g.sampaio
@since 30/10/2020
/*/
User Function RCPGR032()

	Local oReport

	oReport:= ReportDef()
	oReport:PrintDialog()

Return(Nil)

/*/{Protheus.doc} ReportDef
// Na seção de definição do relatório, função ReportDef(), devem ser criados os componentes de impressão,
as seções e as células, os totalizadores e demais componentes que o usuário poderá personalizar no relatório.

@author g.sampaio
@since 05/02/2019
@version 1.0

@type function
/*/
Static Function ReportDef()

	Local oReport		:= NIL
	Local oNichoOssario	:= NIL
	Local oTotal		:= NIL
	Local cTitle		:= "Relatório de Nicho Ossario"
	Local cPerg			:= "RCPGR032"

	oReport:= TReport():New(cPerg,cTitle,"RCPGR032",{|oReport| PrintReport(oReport,oNichoOssario,oTotal)},"Este relatório apresenta a situação de cada nicho ossario.")
	//oReport:SetPortrait() 			// Orientação retrato
	oReport:SetLandscape()		    // Orientação paisagem
    oReport:DisableOrientation()  	// Desabilita a seleção da orientação (retrato/paisagem)
    oReport:oPage:SetPaperSize(9)
	//oReport:HideHeader()  		// Nao imprime cabeçalho padrão do Protheus
	//oReport:HideFooter()			// Nao imprime rodapé padrão do Protheus
	oReport:HideParamPage()			// Inibe impressão da pagina de parametros
	oReport:SetUseGC( .F. ) 		// Desabilita o botão <Gestao Corporativa> do relatório	
	//oReport:cFontBody := "Arial"
	oReport:nFontBody := 9

	AjustaSx1(cPerg) // cria as perguntas para gerar o relatorio
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

	oNichoOssario := TRSection():New(oReport,"Nicho Ossario",{"TRBOSS'"})
	oNichoOssario:SetHeaderPage(.F.)
	oNichoOssario:SetHeaderSection(.T.) // Habilita Impressao Cabecalho no Topo da Pagina
	oNichoOssario:SetTotalInLine(.F.)

	//////////////////////////////////////////////////////////////////////////
	////////////////// COLUNAS QUE SERAO IMPRESSAS //////////////////////////
	//////////////////////////////////////////////////////////////////////////

	TRCell():New(oNichoOssario,"OSSARIO"	        ,"TRBOSS", "Ossario"	        , 		PesqPict("U13","U13_CODIGO")	, TamSX3("U13_CODIGO")[1]+10)
	TRCell():New(oNichoOssario,"DESC_OSSARIO"	    ,"TRBOSS", "Desc.Ossario"       , 		PesqPict("U13","U13_DESC")	    , TamSX3("U13_DESC")[1]+10)
	TRCell():New(oNichoOssario,"NICHO"		        ,"TRBOSS", "Nicho"	            , 		PesqPict("U14","U14_CODIGO")	, TamSX3("U14_CODIGO")[1]+10)
	TRCell():New(oNichoOssario,"DESC_NICHO"	        ,"TRBOSS", "Desc.Nicho"		    , 		PesqPict("U14","U14_DESC")	    , TamSX3("U14_DESC")[1]+10)
	TRCell():New(oNichoOssario,"CAPACIDADE"	        ,"TRBOSS", "Capacidade"	        ,		PesqPict("U14","U14_CAPACI")  	, TamSX3("U14_CAPACI")[1]+10)
	TRCell():New(oNichoOssario,"CONTRATO"	        ,"TRBOSS", "Cod.Contrato"	    ,		PesqPict("U04","U04_CODIGO")  	, TamSX3("U04_CODIGO")[1]+20)
	TRCell():New(oNichoOssario,"DATA_UTILIZACAO"  	,"TRBOSS", "Dt.Utilizacao"	    ,		PesqPict("U04","U04_DTUTIL")  	, TamSX3("U04_DTUTIL")[1]+30)
	TRCell():New(oNichoOssario,"FALECIDO"  	        ,"TRBOSS", "Falecido"	        ,		PesqPict("U04","U04_QUEMUT")  	, TamSX3("U04_QUEMUT")[1]+40)

	//////////////////////////////////////////////////////////////////////////
	////////////////// 		TOTALIZADORES GERAIS	//////////////////////////
	//////////////////////////////////////////////////////////////////////////
	oTotal := TRSection():New(oReport,"Total Geral",{}) //TRSection():New(oReport,"Total Geral",{},,,,,,,,,,,.T.,,,,,1)
	oTotal:SetHeaderPage(.F.)
	oTotal:SetHeaderSection(.T.)

    TRCell():New(oTotal,"nTotOssadas"	, , "Total de Ossadas" 	    , "@E 999 999", TamSX3("E1_VALOR ")[1]+20)
	TRCell():New(oTotal,"nNichoOcupa"	, , "Tot.Nicho Ocupado" 	, "@E 999 999", TamSX3("E1_VALOR ")[1]+20)
	TRCell():New(oTotal,"nNichoLivre"	, , "Tot.Nicho Livre"	    , "@E 999 999", TamSX3("E1_VALOR ")[1]+20)

	// Alinhamento a direita dos campos de valores
	oTotal:Cell("nTotOssadas"):SetHeaderAlign("RIGHT")
	oTotal:Cell("nNichoOcupa"):SetHeaderAlign("RIGHT")
	oTotal:Cell("nNichoLivre"):SetHeaderAlign("RIGHT")

	//Impressao do Cabecalho no topo da pagina
	oReport:Section(1):SetHeaderPage()
	oReport:Section(1):SetEdit(.T.)
	oNichoOssario:SetEdit(.T.)
	oReport:Section(2):SetEdit(.T.)

Return(oReport)

/*/{Protheus.doc} PrintReport
// Inicia Logica Print Report

@author g.sampaio
@since 05/02/2020
@version undefined

@type function
/*/
Static Function PrintReport(oReport,oNichoOssario,oTotal)

	Local cAntChave     := ""
	Local cAtuChave     := ""
	Local cQuery 		:= ""
	Local cOssariDe 	:= ""
	Local cOssariAte	:= ""
	Local cNichoDe   	:= ""
	Local cNichoAte  	:= ""
	Local nCont			:= 0
	Local nTotOssadas 	:= 0
	Local nNichoLivre	:= 0
	Local nNichoOcupa	:= 0
	Local nSituacao     := 0
	Local nTipoOssa		:= 0

	// alimento as variaveis
	cOssariDe 	:= MV_PAR01
	cOssariAte	:= MV_PAR02
	cNichoDe    := MV_PAR03
	cNichoAte   := MV_PAR04
	nSituacao	:= MV_PAR05
	nTipoOssa	:= MV_PAR06

	// verifico se o alias esta em uso
	If Select("TRBOSS") > 0
		TRBOSS->( dbCloseArea() )
	EndIf

	//////////////////////////////////////////////////////////////////////////
	////// consulto os enderecamentos, ocupados, enderecados, livres ////////
	/////////////////////////////////////////////////////////////////////////

	cQuery := " SELECT "
	cQuery += " U13.U13_CODIGO OSSARIO, "
	cQuery += " U13.U13_DESC DESC_OSSARIO, "
	cQuery += " U14.U14_CODIGO NICHO, "
	cQuery += " U14.U14_DESC DESC_NICHO, "
	cQuery += " U14.U14_CAPACI CAPACIDADE, "
	cQuery += " ISNULL(U04.U04_CODIGO,'') CONTRATO, "	
	cQuery += " ISNULL(U04.U04_DTUTIL,'') DATA_UTILIZACAO, "
	cQuery += " ISNULL(U04.U04_QUEMUT,'') FALECIDO "
	cQuery += " FROM " + RetSqlName("U13") + " (NOLOCK) U13 "
	cQuery += " INNER JOIN " + RetSqlName("U14") + " (NOLOCK)  U14 ON U14.D_E_L_E_T_ = ' ' "
	cQuery += " AND U14.U14_FILIAL = '" + xFilial("U14") + "'"
	cQuery += " AND U14.U14_OSSARI = U13.U13_CODIGO "
	cQuery += " LEFT JOIN " + RetSqlName("U04") + " (NOLOCK)  U04 ON U04.D_E_L_E_T_ = ' ' "
	cQuery += " AND U04.U04_FILIAL = '" + xFilial("U14") + "'"
	cQuery += " AND U04.U04_TIPO = 'O' "
	cQuery += " AND U04.U04_OSSARI = U14.U14_OSSARI "
	cQuery += " AND U04.U04_NICHOO = U14.U14_CODIGO "
	cQuery += " AND U04.U04_QUEMUT <> ' ' "
	cQuery += " WHERE U13.D_E_L_E_T_ = ' '"
    cQuery += " AND U13.U13_FILIAL = '" + xFilial("U13") + "' "

	if nTipoOssa == 2 // ossario coletivo
		cQuery += " AND U13.U13_TPOSS = '1'
	elseiF nTipoOssa == 3 // ossario de jazigo
		cQuery += " AND U13.U13_TPOSS = '2'
	endIf

	// verifico se o ossario ate esta preenchido
	if !empty(cOssariAte)
		cQuery += " AND U14.U14_OSSARI BETWEEN '"+ cOssariDe +"' AND '" + cOssariAte + "' "
	endIf

	// verifico se o nicho ate esta preenchido
	if !empty(cNichoAte)
		cQuery += " AND U14.U14_CODIGO BETWEEN '"+ cNichoDe +"' AND '" + cNichoAte + "' "
	endIf

	// verifico se o parametro de situacao e maior que 1 ou diferente de ambos
	if nSituacao > 1

		if nSituacao == 2 // ocupados
			cQuery += "   AND EXISTS (SELECT SEPULT.U04_OSSARI "
		elseIf nSituacao == 3 // livres
			cQuery += "   AND NOT EXISTS (SELECT SEPULT.U04_OSSARI "
		endIf

		cQuery += " 					FROM " + RetSqlName("U04") + " SEPULT "
		cQuery += " 					WHERE SEPULT.D_E_L_E_T_ = ' ' "
		cQuery += " 					AND SEPULT.U04_FILIAL = '" + xFilial("U04") + "' "
		cQuery += " 					AND SEPULT.U04_OSSARI = U13.U13_CODIGO "
		cQuery += " 					AND SEPULT.U04_NICHOO = U14.U14_CODIGO ) "

	endIf

	cQuery += " ORDER BY OSSARIO ASC, NICHO ASC

	cQuery := Changequery(cQuery)
	TcQuery cQuery NEW ALIAS "TRBOSS"

	TRBOSS->(dbEval({|| nCont++}))
	TRBOSS->(DbGoTop())

	oReport:SetMeter(nCont)

	nNichoOcupa	:= 0
	nNichoLivre	:= 0

	// vou percorrer os registros de endereco
	While !oReport:Cancel() .And. TRBOSS->(!EOF())

		oNichoOssario:Init()
		oReport:IncMeter()

		If oReport:Cancel()
			Exit
		EndIf

		cAtuChave := TRBOSS->OSSARIO+TRBOSS->NICHO

		// faco a impressao do enderecamento
		oNichoOssario:Cell("OSSARIO"):SetValue(TRBOSS->OSSARIO)
		oNichoOssario:Cell("DESC_OSSARIO"):SetValue(TRBOSS->DESC_OSSARIO)
		oNichoOssario:Cell("NICHO"):SetValue(TRBOSS->NICHO)
		oNichoOssario:Cell("DESC_NICHO"):SetValue(TRBOSS->DESC_NICHO)
		oNichoOssario:Cell("CAPACIDADE"):SetValue(TRBOSS->CAPACIDADE)
		oNichoOssario:Cell("CONTRATO"):SetValue(TRBOSS->CONTRATO)	
		oNichoOssario:Cell("DATA_UTILIZACAO"):SetValue(Stod(TRBOSS->DATA_UTILIZACAO))
		oNichoOssario:Cell("FALECIDO"):SetValue(TRBOSS->FALECIDO)
		oNichoOssario:PrintLine()

		//===========================================
		// TOTALIZAODRES DE JAZIGOS
		//===========================================
		If !Empty(TRBOSS->FALECIDO)

			nTotOssadas++ // variavel contado

			// verifico se e o mesmo nicho
			if cAtuChave == cAntChave
				nNichoOcupa++
			endIf

			// guardo o valor da chave atual, para comparar com o proximo registro
			cAntChave   := cAtuChave

		ElseIf Empty(TRBOSS->FALECIDO)

			nNichoLivre++ // variavel contado

			// guardo o valor da chave atual, para comparar com o proximo registro
			cAntChave   := cAtuChave

		endIf

		oReport:SkipLine()

		TRBOSS->(DbSkip())

	EndDo

	oNichoOssario:Finish()

	oTotal:Init()
	oTotal:Cell("nTotOssadas"):SetValue(nTotOssadas)
	oTotal:Cell("nNichoOcupa"):SetValue(nNichoOcupa)
	oTotal:Cell("nNichoLivre"):SetValue(nNichoLivre)

	oTotal:PrintLine()
	oTotal:Finish()

	oTotal:SetPageBreak(.T.)

	// verifico se o alias esta em uso
	If Select("TRBOSS") > 0
		TRBOSS->( dbCloseArea() )
	EndIf

Return(Nil)

/*/{Protheus.doc} AjustaSX1
Altero as informacoes do grupo de perguntas SX1
@author g.sampaio
@since 04/09/2019
@version P12
@param nulo
@return nulo
/*/

Static Function AjustaSX1( cPerg )

	Local aArea     := GetArea()
	Local aRegs     := {}

	Default cPerg   := ""

	// verifico se se foi preenchido a tabela
	If !Empty( cPerg )

		// parametros SX1
		aAdd(aRegs,{cPerg,'01','Ossario De  '               ,'','','mv_ch1','C', TamSx3("U04_OSSARI")[1]    , 0, 0,'G','','mv_par01','','','','','','U08'})
		aAdd(aRegs,{cPerg,'02','Ossario Até '               ,'','','mv_ch2','C', TamSx3("U04_OSSARI")[1]    , 0, 0,'G','','mv_par02','','','','','','U08'})
		aAdd(aRegs,{cPerg,'03','Nicho De '                  ,'','','mv_ch3','C', TamSx3("U04_NICHOO")[1]    , 0, 0,'G','','mv_par03','','','','','','U09'})
		aAdd(aRegs,{cPerg,'04','Nicho Ate'                  ,'','','mv_ch4','C', TamSx3("U04_NICHOO")[1]    , 0, 0,'G','','mv_par04','','','','','','U09'})
		aAdd(aRegs,{cPerg,'05','Situacao '                  ,'','','mv_ch5','N', 01                         , 0, 0,'N','','mv_par05','1=Ambos','2=End.Ocupado','3=Livres','','',''})
		aAdd(aRegs,{cPerg,'06','Tipo Ossario?'              ,'','','mv_ch6','N', 01                         , 0, 0,'N','','mv_par06','1=Ambos','2=Coletivo','3=Jazigo','','',''})

		// cria os dados da SX1
		U_CriaSX1( aRegs )

	EndIf

	RestArea( aArea )

Return( Nil )
