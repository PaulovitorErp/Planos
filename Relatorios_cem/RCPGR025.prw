#include "protheus.ch"
#include "topconn.ch"


/*/{Protheus.doc} RCPGR025
Relatorio de Inadimplencia Contratos Cemiterio
@author TOTVS
@since 05/01/2018
@version P12
@param nulo
@return nulo
/*/
User Function RCPGR025()

	Local oReport

	oReport:= ReportDef()
	oReport:PrintDialog()

Return()

/*/{Protheus.doc} ReportDef
// Na seção de definição do relatório, função ReportDef(), devem ser criados os componentes de impressão, 
as seções e as células, os totalizadores e demais componentes que o usuário poderá personalizar no relatório.

@author Raphael Martins
@since 05/01/2018
@version 1.0

@type function
/*/
Static Function ReportDef()

	Local oReport		:= NIL
	Local oContratos	:= NIL
	Local oTotal		:= NIL
	Local cTitle		:= "Relatório de Inadimplencia Contratos Cemiterio"
	Local cPerg			:= "RCPGR025"

	oReport:= TReport():New(cPerg,cTitle,"RCPGR025",{|oReport| PrintReport(oReport,oContratos,oTotal)},"Este relatório apresenta a relacao de contratos inadimplentes")
	oReport:SetPortrait() 			// Orientação retrato
	//oReport:SetLandscape()		// Orientação paisagem
	//oReport:HideHeader()  		// Nao imprime cabeçalho padrão do Protheus
	//oReport:HideFooter()			// Nao imprime rodapé padrão do Protheus
	oReport:HideParamPage()			// Inibe impressão da pagina de parametros
	oReport:SetUseGC( .F. ) 		// Desabilita o botão <Gestao Corporativa> do relatório
	oReport:DisableOrientation()  	// Desabilita a seleção da orientação (retrato/paisagem)
	//oReport:cFontBody := "Arial"
	//oReport:nFontBody := 8

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

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oContratos := TRSection():New(oReport,"Contratos",{"QRYCTR"})
	oContratos:SetHeaderPage(.F.)
	oContratos:SetHeaderSection(.T.) // Habilita Impressao Cabecalho no Topo da Pagina
	oContratos:SetTotalInLine(.F.)

	TRCell():New(oContratos,"CODIGO_PLANO"		,"QRYCPROT", "Cod Plano"		, 		PesqPict("U00","U00_PLANO")		,TamSX3("U00_PLANO")[1]+5)
	TRCell():New(oContratos,"DESC_PLANO"		,"QRYCPROT", "Desc Plano"		, 		PesqPict("U00","U00_DESCPL")	,TamSX3("U00_DESCPL")[1]-30)
	TRCell():New(oContratos,"CONTRATO"			,"QRYCPROT", "Contrato"			, 		PesqPict("U00","U00_CODIGO")	,TamSX3("U00_CODIGO")[1]+5)
	TRCell():New(oContratos,"DATA_ATIVACAO"		,"QRYCPROT", "Data Ativacao"	, 		PesqPict("U00","U00_DTATIV")	,TamSX3("U00_DTATIV")[1]+15)
	TRCell():New(oContratos,"COD_CLIENTE"		,"QRYCPROT", "Cliente"			, 		PesqPict("U00","U00_CLIENT")	,TamSX3("U00_CLIENT")[1]+10)
	TRCell():New(oContratos,"LOJA"				,"QRYCPROT", "Loja"				, 		PesqPict("U00","U00_LOJA")		,TamSX3("U00_LOJA")[1]+10)
	TRCell():New(oContratos,"NOME_CLIENTE"		,"QRYCPROT", "Nome"				, 		PesqPict("U00","U00_NOMCLI")	,TamSX3("U00_NOMCLI")[1]+5)
	TRCell():New(oContratos,"TELEFONE"			,"QRYCPROT", "Telefone"			, 		"@R (99)9999 - 99999"			,TamSX3("U00_TEL")[1]+10)
	TRCell():New(oContratos,"VALOR"	   			,"QRYCPROT", "Valor"			,		PesqPict("SE1","E1_VALOR")  	,TamSX3("E1_VALOR ")[1]+1)
	TRCell():New(oContratos,"QTD_VENCIDO"	    ,"QRYCPROT", "Parc. Vencidas"	,  		"@E 99999"						,20)
	TRCell():New(oContratos,"SLD_VENCIDO"	   	,"QRYCPROT", "Saldo Vencido"	,		PesqPict("SE1","E1_VALOR")  	,TamSX3("E1_VALOR ")[1]+1)


	// Alinhamento a direita dos campos de valores
	oContratos:Cell("VALOR"):SetHeaderAlign("RIGHT")
	oContratos:Cell("QTD_VENCIDO"):SetHeaderAlign("RIGHT")
	oContratos:Cell("SLD_VENCIDO"):SetHeaderAlign("RIGHT")


	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oTotal := TRSection():New(oReport,"Total Geral",{}) //TRSection():New(oReport,"Total Geral",{},,,,,,,,,,,.T.,,,,,1)
	oTotal:SetHeaderPage(.F.)
	oTotal:SetHeaderSection(.T.)

	TRCell():New(oTotal,"nTotal", , "Valor" ,PesqPict("SE1","E1_VALOR")  ,TamSX3("E1_VALOR ")[1]+1)
	TRCell():New(oTotal,"nQuant", , "Quantidade ", "!@", 30)
	TRCell():New(oTotal,"nContratos", , "Contratos ", "!@", 30)

	// Alinhamento a direita dos campos de valores
	oTotal:Cell("nTotal"):SetHeaderAlign("RIGHT")
	oTotal:Cell("nQuant"):SetHeaderAlign("RIGHT")
	oTotal:Cell("nContratos"):SetHeaderAlign("RIGHT")

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Impressao do Cabecalho no topo da pagina
	oReport:Section(1):SetHeaderPage()
	oReport:Section(1):SetEdit(.T.)
	oContratos:SetEdit(.T.)
	oReport:Section(2):SetEdit(.T.)

Return(oReport)

/*/{Protheus.doc} PrintReport
// Inicia Logica Print Report

@author Raphael Martins Garcia 
@since 05/01/2018
@version undefined

@type function
/*/
Static Function PrintReport(oReport,oContratos,oTotal)

	Local cQry 			:= ""
	Local cClientDe 	:= ""
	Local cClientAte	:= ""
	Local cLojaDe   	:= ""
	Local cLojaAte  	:= ""
	Local cContraDe 	:= ""
	Local cContraAte	:= ""
	Local cPlano		:= ""
	Local cStatCtr		:= ""
	Local cTiposTit		:= ""
	Local dVencIni 		:= CTOD("")
	Local dVencFim		:= CTOD("")
	Local nOrdem		:= 0
	Local nCont			:= 0
	Local nTotal 		:= 0
	Local nQuant		:= 0
	Local nStatus 		:= 0
	Local nContratos	:= 0
	
	cClientDe 	:= MV_PAR01
	cClientAte	:= MV_PAR02
	cLojaDe   	:= MV_PAR03
	cLojaAte  	:= MV_PAR04
	cContraDe 	:= MV_PAR05
	cContraAte	:= MV_PAR06
	cPlano		:= MV_PAR07
	dVencIni	:= MV_PAR08
	dVencFim	:= MV_PAR09
	nStatus		:= MV_PAR10
	cStatCtr	:= MV_PAR11
	cTiposTit	:= MV_PAR12

	//nOrdem := oProtocolo:GetOrder()

	TRFunction():New(oContratos:Cell("SLD_VENCIDO"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T. /*lEndSection*/,.F. /*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oContratos:Cell("QTD_VENCIDO"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T. /*lEndSection*/,.F. /*lEndReport*/,/*lEndPage*/)

	//////////////////////////////////////////////////////////////////////////
	////// CONSULTO OS TITULOS DE ACORDO COM OS PARAMETROS INFORMADOS ///////
	/////////////////////////////////////////////////////////////////////////
	cQry := " SELECT "
	cQry += " 	 VENCIDOS.U00_PLANO 			AS CODIGO_PLANO, "
	cQry += " 	 VENCIDOS.U00_DESCPL 			AS DESC_PLANO, "
	cQry += " 	 VENCIDOS.U00_CODIGO 			AS CONTRATO, "
	cQry += " 	 VENCIDOS.U00_DTATIV 			AS DATA_ATIVACAO, "
	cQry += " 	 VENCIDOS.U00_CLIENT 			AS COD_CLIENTE, "
	cQry += " 	 VENCIDOS.U00_LOJA				AS LOJA, "
	cQry += " 	 VENCIDOS.U00_NOMCLI 			AS NOME_CLIENTE, "
	cQry += " 	 VENCIDOS.U00_DDD 				AS DDD, "
	cQry += " 	 VENCIDOS.U00_TEL 				AS TELEFONE, "
	cQry += " 	 VENCIDOS.U00_VALOR 			AS VALOR, "
	cQry += " 	 SUM(VENCIDOS.SALDO_VENCIDO)	AS SLD_VENCIDO, "
	cQry += " 	 COUNT(*)						AS QTD_VENCIDO "
	cQry += " 	 FROM  "
	cQry += " 	 ( "
	cQry += " 		SELECT  "
	cQry += " 		 CONTRATOS.U00_PLANO, "
	cQry += " 		 CONTRATOS.U00_DESCPL, "
	cQry += " 		 CONTRATOS.U00_CODIGO, "
	cQry += " 		 CONTRATOS.U00_DTATIV, "
	cQry += " 		 CONTRATOS.U00_CLIENT, "
	cQry += " 		 CONTRATOS.U00_LOJA, "
	cQry += " 		 CONTRATOS.U00_NOMCLI, "
	cQry += " 		 CONTRATOS.U00_DDD, "
	cQry += " 		 CONTRATOS.U00_TEL, "
	cQry += " 		 CONTRATOS.U00_VALOR, "
	cQry += " 		 CASE  "
	cQry += " 			WHEN E1_BAIXA <> ' ' THEN E1_SALDO "
	cQry += " 		 ELSE "
	cQry += " 			E1_VALOR + E1_ACRESC  "
	cQry += " 		 END AS SALDO_VENCIDO "
	cQry += " 		 FROM "
	cQry +=  		 RetSQLName("U00") + " CONTRATOS (NOLOCK) "
	cQry += " 		 INNER JOIN "
	cQry +=  		 RetSQLName("SE1") + " TITULOS (NOLOCK) "
	cQry += " 		 ON CONTRATOS.D_E_L_E_T_ = ' ' "
	cQry += " 		 AND TITULOS.D_E_L_E_T_ = ' ' "
	cQry += " 		 AND CONTRATOS.U00_CODIGO = TITULOS.E1_XCONTRA "
	cQry += " 		 WHERE "
	cQry += " 		 CONTRATOS.U00_FILIAL = '" + xFilial("U00")+ "' "
	cQry += " 		 AND TITULOS.E1_FILIAL = '" +xFilial("SE1") + "' "
	cQry += " 		 AND TITULOS.E1_XCONTRA <> ' ' "
	cQry += " 		 AND TITULOS.E1_SALDO > 0 "

	//filtro por plano
	if !Empty(cTiposTit)
		cQry += " 		 AND TITULOS.E1_TIPO IN " + FormatIn( AllTrim(cTiposTit),";") + " "
	endif

	cQry += " 		 AND TITULOS.E1_VENCREA < '" + DTOS(dDatabase)+ "' "

	//filtro por cliente
	if !Empty(cClientAte)
		cQry += " 	AND CONTRATOS.U00_CLIENT BETWEEN '" + Alltrim(cClientDe) + "' AND '" + Alltrim(cClientAte) + "' "
	endif

	//filtro por loja do cliente
	if !Empty(cLojaAte)
		cQry += " 	AND CONTRATOS.U00_LOJA BETWEEN '" + Alltrim(cLojaDe) + "' AND '" + Alltrim(cLojaAte) + "' "
	endif

	//filtro por contrato
	if !Empty(cContraAte)
		cQry += " 	AND CONTRATOS.U00_CODIGO BETWEEN '" + Alltrim(cContraDe) + "' AND '" + Alltrim(cContraAte) + "' "
	endif

	//filtro por plano
	if !Empty(cPlano)
		cQry += " 	AND CONTRATOS.U00_PLANO IN " + FormatIn( AllTrim(cPlano),";") + " "
	endif

	//filtro por vencimento
	if !Empty(dVencFim)
		cQry += " 	AND TITULOS.E1_VENCREA BETWEEN '" + DTOS(dVencIni) + "' AND '" + DTOS(dVencFim) + "' "
	endif

	//diferente de todos os tipos de contrato
	if nStatus <> 4

		//sem enderecamento
		if nStatus == 1

			cQry += " AND NOT EXISTS "
			cQry += " ("
			cQry += " 	SELECT U04_CODIGO "
			cQry += " 	FROM "
			cQry += " 	" + RetSQLName("U04") + " ENDERECO "
			cQry += " 	WHERE "
			cQry += " 	ENDERECO.D_E_L_E_T_ = ' ' "
			cQry += " 	AND ENDERECO.U04_FILIAL = '" + xFilial("U04") + "' "
			cQry += " 	AND ENDERECO.U04_CODIGO = TITULOS.E1_XCONTRA "
			cQry += " ) "


			//com enderecamento
		else

			cQry += " AND EXISTS "
			cQry += " ("
			cQry += " 	SELECT U04_CODIGO "
			cQry += " 	FROM "
			cQry += " 	" + RetSQLName("U04") + " ENDERECO "
			cQry += " 	WHERE "
			cQry += " 	ENDERECO.D_E_L_E_T_ = ' ' "
			cQry += " 	AND ENDERECO.U04_FILIAL = '" + xFilial("U04") + "' "
			cQry += " 	AND ENDERECO.U04_CODIGO = TITULOS.E1_XCONTRA "

			//com enderecamento previo
			if nStatus == 2

				cQry += " AND ENDERECO.U04_PREVIO = 'S' "
				cQry += " AND ENDERECO.U04_QUEMUT = ' ' "
				cQry += " ) "

				//enderecamento com sepultamento
			else

				cQry += " AND ENDERECO.U04_QUEMUT <> ' ' "
				cQry += " AND ENDERECO.U04_DTUTIL <> ' ' "
				cQry += " ) "

			endif

		endif

	endif

	//status do contrato
	if !Empty(cStatCtr)
		cQry += " AND CONTRATOS.U00_STATUS IN " + FormatIn( AllTrim(cStatCtr),";") 	+ " "
	endif

	cQry += " 	 ) VENCIDOS "
	cQry += " 	 GROUP BY "
	cQry += " 	 VENCIDOS.U00_PLANO, "
	cQry += " 	 VENCIDOS.U00_DESCPL, "
	cQry += "    VENCIDOS.U00_CODIGO, "
	cQry += "    VENCIDOS.U00_DTATIV, "
	cQry += "    VENCIDOS.U00_CLIENT, "
	cQry += "    VENCIDOS.U00_LOJA, "
	cQry += "    VENCIDOS.U00_NOMCLI, "
	cQry += "    VENCIDOS.U00_DDD, "
	cQry += "    VENCIDOS.U00_TEL, "
	cQry += "    VENCIDOS.U00_VALOR "
	cQry += " ORDER BY CONTRATO "

	If Select("QRYTIT") > 0
		QRYTIT->(dbCloseArea())
	EndIf

	MemoWrite("C:\Temp\Inadimplencia.sql",cQry)

	cQry := Changequery(cQry)
	TcQuery cQry NEW ALIAS "QRYTIT"

	QRYTIT->(dbEval({|| nCont++}))
	QRYTIT->(DbGoTop())

	oReport:SetMeter(nCont)

	nTotal 		:= 0
	nQuant		:= 0
	nContratos	:= 0

	While !oReport:Cancel() .And. QRYTIT->(!EOF())

		oContratos:Init()
		oReport:IncMeter()

		If oReport:Cancel()
			Exit
		EndIf

		cTelefone	:= "(" + Alltrim(QRYTIT->DDD) + ") " + Alltrim(QRYTIT->TELEFONE)

		oContratos:Cell("CODIGO_PLANO"):SetValue(QRYTIT->CODIGO_PLANO)
		oContratos:Cell("DESC_PLANO"):SetValue(QRYTIT->DESC_PLANO)
		oContratos:Cell("CONTRATO"):SetValue(QRYTIT->CONTRATO)
		oContratos:Cell("DATA_ATIVACAO"):SetValue(STOD(QRYTIT->DATA_ATIVACAO))
		oContratos:Cell("COD_CLIENTE"):SetValue(QRYTIT->COD_CLIENTE)
		oContratos:Cell("LOJA"):SetValue(QRYTIT->LOJA)
		oContratos:Cell("NOME_CLIENTE"):SetValue(QRYTIT->NOME_CLIENTE)
		oContratos:Cell("TELEFONE"):SetValue(cTelefone)
		oContratos:Cell("VALOR"):SetValue(QRYTIT->VALOR)
		oContratos:Cell("QTD_VENCIDO"):SetValue(QRYTIT->QTD_VENCIDO)
		oContratos:Cell("SLD_VENCIDO"):SetValue(QRYTIT->SLD_VENCIDO)

		oContratos:PrintLine()

		nTotal += QRYTIT->SLD_VENCIDO
		nQuant += QRYTIT->QTD_VENCIDO
		nContratos++

		oReport:SkipLine()

		QRYTIT->(DbSkip())

	EndDo

	oContratos:Finish()

	oTotal:Init()
	oTotal:Cell("nTotal"):SetValue(Round(nTotal,2))
	oTotal:Cell("nQuant"):SetValue(nQuant)
	oTotal:Cell("nContratos"):SetValue(nContratos)

	oTotal:PrintLine()
	oTotal:Finish()

	oTotal:SetPageBreak(.T.)

	QRYTIT->(DbCloseArea())

Return

/*/{Protheus.doc} AjustaSX1
// Cria a tela de perguntas do relatorio
@author Raphael Martins Garcia
@since 05/01/2018
@version undefined

@type function
/*/
Static Function AjustaSX1(cPerg)

	Local aRegs		:= {}

	Default cPerg	:= ""
	
	// verifico se o nome do grupo de pergunta foi passado
	if !Empty(cPerg)

	        // parametros SX1
        aAdd(aRegs,{cPerg,'01','Do Cliente ?  '                	,'','','mv_ch1','C', TamSx3("A1_COD")[1]    	, 0, 0,'G','','mv_par01','','','','','','SA1'})
        aAdd(aRegs,{cPerg,'02','Ate o Cliente ? '              	,'','','mv_ch2','C', TamSx3("A1_COD")[1]    	, 0, 0,'G','','mv_par02','','','','','','SA1'})
        aAdd(aRegs,{cPerg,'03','Da Loja ?  '                 	,'','','mv_ch3','C', TamSx3("A1_LOJA")[1]    	, 0, 0,'G','','mv_par03','','','','','',''})
        aAdd(aRegs,{cPerg,'04','Ate a Loja ? '                 	,'','','mv_ch4','C', TamSx3("A1_LOJA")[1]    	, 0, 0,'G','','mv_par04','','','','','',''})
        aAdd(aRegs,{cPerg,'05','Do Contrato ?'                  ,'','','mv_ch5','C', TamSx3("U00_CODIGO")[1]    , 0, 0,'G','','mv_par05','','','','','','U00'})
        aAdd(aRegs,{cPerg,'06','Ate o Contrato ?'               ,'','','mv_ch6','C', TamSx3("U00_CODIGO")[1]    , 0, 0,'G','','mv_par06','','','','','','U00'})
        aAdd(aRegs,{cPerg,'07','Plano? '                  		,'','','mv_ch7','C', 99                         , 0, 0,'G','','mv_par07','','','','','','U05MRK'})
		aAdd(aRegs,{cPerg,'08','Do Vencimento ?'                ,'','','mv_ch8','D', 08                         , 0, 0,'G','','mv_par08','','','','','',''})
		aAdd(aRegs,{cPerg,'09','Ate Vencimento ? '              ,'','','mv_ch9','D', 08                         , 0, 0,'G','','mv_par09','','','','','',''})
		aAdd(aRegs,{cPerg,'10','Enderecamento ?  '              ,'','','mv_cha','C', 01                         , 0, 0,'C','','mv_par10','1-Sem Enderecamento','2-Enderecamento Previo','3-Com Sepultamento','4-Todos','',''})
		aAdd(aRegs,{cPerg,'11','Status Contrato? '              ,'','','mv_chb','C', 99                         , 0, 0,'G','','mv_par11','','','','','','STFUN'})
		aAdd(aRegs,{cPerg,'12','Tipo de Titulo? '               ,'','','mv_chc','C', 99                         , 0, 0,'G','','mv_par12','','','','','','TIPTIT'})

        // cria os dados da SX1
        U_CriaSX1( aRegs )

	endIf

Return(Nil)
