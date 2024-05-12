#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RCPGR031
Relatorio de servicos
Imprime por tipo de endereco, servicos, apontamentos
Novo relatório que substitui o antigo (RCPGR019)
@type function
@version 
@author g.sampaio
@since 05/05/2020
@return nil
/*/
User Function RCPGR031()

	Local aArea     := GetArea()
	Local oReport   := Nil

	oReport:= ReportDef()
	oReport:PrintDialog()

	RestArea(aArea)

Return

/*/{Protheus.doc} ReportDef
Na seção de definição do relatório, função ReportDef(), 
devem ser criados os componentes de impressão,
as seções e as células, os totalizadores e demais componentes 
que o usuário poderá personalizar no relatório.
@type function
@version 
@author g.sampaio
@since 05/05/2020
@return objeto, retorna o objeto de impressao
/*/
Static Function ReportDef()

	Local aArea             := GetArea()
	Local cTitle    	    := "Relatório de Serviços - Contratos"
	Local cPerg		        := "RCPGR031"
	Local lHabTalona		:= SuperGetMV("MV_XHABTAL", .F., .F.)
	Local oReport           := Nil
	Local oTipo             := Nil
	Local oServico          := Nil
	Local oApontServAdd    	:= Nil
	Local oApontCremacao    := Nil
	Local oApontJazigo      := Nil
	Local oApontOssuario    := Nil
	Local oTotal            := Nil
	Local oTotalGer         := Nil

	// faco a execucao da clase TReport para a impressao do relatorio
	oReport	:= TReport():New( "RCPGR031", cTitle, cPerg, { |oReport| PrintReport( oReport, oTipo, oServico, oApontServAdd, oApontCremacao, oApontJazigo, oApontOssuario,  oTotalGer)},"Este relatório apresenta a relação dos Serviços executados.")
	oReport:SetLandscape()			// Orientação paisagem
	oReport:HideParamPage()			// Inibe impressão da pagina de parametros
	oReport:SetUseGC( .F. ) 		// Desabilita o botão <Gestao Corporativa> do relatório

	AjustaSX1(cPerg) // cria as perguntas para gerar o relatorio
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
	oTipo := TRSection():New(oReport,"Tipo Endereço",{"QRYSERV"})//,{"Por Contrato","Por Cod. Cliente","Por Nome Cliente"}/*Ordens do Relatório*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oTipo:SetTotalInLine(.T.) //Define se os totalizadores serão impressos em linha ou coluna

	TRCell():New( oTipo, "TIPOEND", "QRYSERV", " Tipo de Endereço ", "@!", 100)//, /*lPixel*/,{|| QRYSERV1->U07_DESCSE})

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oServico := TRSection():New(oTipo,"Serviços",{"QRYSERV"})//,{"Por Contrato","Por Cod. Cliente","Por Nome Cliente"}/*Ordens do Relatório*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oServico:SetTotalInLine(.T.) //Define se os totalizadores serão impressos em linha ou coluna

	TRCell():New( oServico, "SERVICO", "QRYSERV"," Serviço ", "@!", 100)//, /*lPixel*/,{|| QRYSERV1->U07_DESCSE})

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Apontamentos de serviço adicional
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oApontServAdd := TRSection():New(oServico,"Apontamentos de Serviços Adicionais",{"QRYSERV"})

	TRCell():New( oApontServAdd, "APONTAMENTO"	, "QRYSERV"     , "APONTAMENTO"		, PesqPict("UJV","UJV_CODIGO")  ,TamSX3("UJV_CONTRA"	)[1]+1)
	TRCell():New( oApontServAdd, "CONTRATO"	   	, "QRYSERV"     , "CONTRATO"		, PesqPict("UJV","UJV_CONTRA")  ,TamSX3("UJV_CONTRA"	)[1]+1)

	If lHabTalona
		TRCell():New( oApontServAdd, "TALONA"	    , "QRYSERV"     , "TALONA"		, PesqPict("U00","U00_TALONA")  ,TamSX3("U00_TALONA"	)[1]+1)
	EndIf

	TRCell():New( oApontServAdd, "PEDIDO"		, "QRYSERV"     , "PED.VENDAS"		, PesqPict("UJV","UJV_PEDIDO")  ,TamSX3("UJV_CONTRA"	)[1]+1)
	TRCell():New( oApontServAdd, "NOMECLI" 	    , "QRYSERV"     , "CESSIONARIO"	    , PesqPict("U00","U00_NOMCLI")  ,TamSX3("U00_NOMCLI"	)[1]+1)
	TRCell():New( oApontServAdd, "DESCPLANO"	, "QRYSERV"     , "PLANO"			, PesqPict("U00","U00_DESCPL")  ,TamSX3("U00_DESCPL"	)[1]+1)
	TRCell():New( oApontServAdd, "DATASERV"	    , "QRYSERV"     , "DATA"			, PesqPict("UJV","UJV_DTSEPU")  ,TamSX3("UJV_DTSEPU"	)[1]+3)
	TRCell():New( oApontServAdd, "NOMESERV"	    , "QRYSERV"     , "OBITO"			, PesqPict("UJV","UJV_NOME"	)   ,TamSX3("UJV_NOME"		)[1]+1)

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Apontamentos de serviço de cremação
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oApontCremacao := TRSection():New(oServico,"Apontamentos de Cremação",{"QRYSERV"})

	TRCell():New( oApontCremacao, "APONTAMENTO"	    , "QRYSERV"     , "APONTAMENTO"		, PesqPict("UJV","UJV_CODIGO")  ,TamSX3("UJV_CONTRA"	)[1]+1)
	TRCell():New( oApontCremacao, "CONTRATO"	    , "QRYSERV"     , "CONTRATO"		, PesqPict("UJV","UJV_CONTRA")  ,TamSX3("UJV_CONTRA"	)[1]+1)

	If lHabTalona
		TRCell():New( oApontCremacao, "TALONA"	    , "QRYSERV"     , "TALONA"		, PesqPict("U00","U00_TALONA")  ,TamSX3("U00_TALONA")[1]+1)
	EndIf

	TRCell():New( oApontCremacao, "PEDIDO"		    , "QRYSERV"     , "PED.VENDAS"		, PesqPict("UJV","UJV_PEDIDO")  ,TamSX3("UJV_CONTRA"	)[1]+1)
	TRCell():New( oApontCremacao, "NOMECLI" 	    , "QRYSERV"     , "CESSIONARIO"	    , PesqPict("U00","U00_NOMCLI")  ,TamSX3("U00_NOMCLI"	)[1]+1)
	TRCell():New( oApontCremacao, "DESCPLANO"	    , "QRYSERV"     , "PLANO"			, PesqPict("U00","U00_DESCPL")  ,TamSX3("U00_DESCPL"	)[1]+1)
	TRCell():New( oApontCremacao, "DATASERV"	    , "QRYSERV"     , "DATA"			, PesqPict("UJV","UJV_DTSEPU")   ,TamSX3("UJV_DTSEPU"	)[1]+3)
	TRCell():New( oApontCremacao, "NOMESERV"	    , "QRYSERV"     , "OBITO"			, PesqPict("UJV","UJV_NOME"	)   ,TamSX3("UJV_NOME"		)[1]+1)
	TRCell():New( oApontCremacao, "CREMATORIO"	    , "QRYSERV"     , "CREMATORIO"	    , PesqPict("UJV","UJV_CREMAT")  ,TamSX3("UJV_CREMAT"	)[1]+1)
	TRCell():New( oApontCremacao, "NICHOCREMA"	    , "QRYSERV"     , "N.COLUMBARIO"	, PesqPict("UJV","UJV_NICHOC")  ,TamSX3("UJV_NICHOC"	)[1]+1)

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Apontamentos de serviço de Jazigos
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oApontJazigo := TRSection():New(oServico,"Apontamentos de Jazigo",{"QRYSERV"})

	TRCell():New( oApontJazigo, "APONTAMENTO"	, "QRYSERV"     , "APONTAMENTO"		, PesqPict("UJV","UJV_CODIGO")  ,TamSX3("UJV_CONTRA"	)[1]+1)
	TRCell():New( oApontJazigo, "CONTRATO"	    , "QRYSERV"     , "CONTRATO"		, PesqPict("UJV","UJV_CONTRA")  ,TamSX3("UJV_CONTRA"	)[1]+1)

	If lHabTalona
		TRCell():New( oApontJazigo, "TALONA"	    , "QRYSERV"     , "TALONA"		, PesqPict("U00","U00_TALONA")  ,TamSX3("U00_TALONA"	)[1]+1)
	EndIf

	TRCell():New( oApontJazigo, "PEDIDO"		, "QRYSERV"     , "PED.VENDAS"		, PesqPict("UJV","UJV_PEDIDO")  ,TamSX3("UJV_CONTRA"	)[1]+1)
	TRCell():New( oApontJazigo, "NOMECLI" 	    , "QRYSERV"     , "CESSIONARIO"	    , PesqPict("U00","U00_NOMCLI")  ,TamSX3("U00_NOMCLI"	)[1]+1)
	TRCell():New( oApontJazigo, "DESCPLANO"	    , "QRYSERV"     , "PLANO"			, PesqPict("U00","U00_DESCPL")  ,TamSX3("U00_DESCPL"	)[1]+1)
	TRCell():New( oApontJazigo, "DATASERV"	    , "QRYSERV"     , "DATA"			, PesqPict("UJV","UJV_DTSEPU")  ,TamSX3("UJV_DTSEPU"	)[1]+3)
	TRCell():New( oApontJazigo, "NOMESERV"	    , "QRYSERV"     , "OBITO"			, PesqPict("UJV","UJV_NOME"	)   ,TamSX3("UJV_NOME"		)[1]+1)
	TRCell():New( oApontJazigo, "QUADRA"    	, "QRYSERV"     , "QUADRA"	        , PesqPict("UJV","UJV_QUADRA")  ,TamSX3("UJV_QUADRA"	)[1]+1)
	TRCell():New( oApontJazigo, "MODULO"    	, "QRYSERV"     , "MODULO"	        , PesqPict("UJV","UJV_MODULO")  ,TamSX3("UJV_MODULO"	)[1]+1)
	TRCell():New( oApontJazigo, "JAZIGO"   		, "QRYSERV"     , "JAZIGO"	        , PesqPict("UJV","UJV_JAZIGO")  ,TamSX3("UJV_JAZIGO"	)[1]+1)
	TRCell():New( oApontJazigo, "GAVETA"	    , "QRYSERV"     , "GAVETA"  	    , PesqPict("UJV","UJV_GAVETA")  ,TamSX3("UJV_GAVETA"	)[1]+1)

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Apontamentos de serviço de Ossuário
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oApontOssuario := TRSection():New(oServico,"Apontamentos de Ossuario",{"QRYSERV"})

	TRCell():New( oApontOssuario, "APONTAMENTO"	    , "QRYSERV"     , "APONTAMENTO"		, PesqPict("UJV","UJV_CODIGO")  ,TamSX3("UJV_CONTRA"	)[1]+1)
	TRCell():New( oApontOssuario, "CONTRATO"	    , "QRYSERV"     , "CONTRATO"		, PesqPict("UJV","UJV_CONTRA")  ,TamSX3("UJV_CONTRA"	)[1]+1)

	If lHabTalona
		TRCell():New( oApontOssuario, "TALONA"	    , "QRYSERV"     , "TALONA"		, PesqPict("U00","U00_TALONA")  ,TamSX3("U00_TALONA")[1]+1)
	EndIf


	TRCell():New( oApontOssuario, "PEDIDO"		    , "QRYSERV"     , "PED.VENDAS"		, PesqPict("UJV","UJV_PEDIDO")  ,TamSX3("UJV_CONTRA"	)[1]+1)
	TRCell():New( oApontOssuario, "NOMECLI" 	    , "QRYSERV"     , "CESSIONARIO"	    , PesqPict("U00","U00_NOMCLI")  ,TamSX3("U00_NOMCLI"	)[1]+1)
	TRCell():New( oApontOssuario, "DESCPLANO"	    , "QRYSERV"     , "PLANO"			, PesqPict("U00","U00_DESCPL")  ,TamSX3("U00_DESCPL"	)[1]+1)
	TRCell():New( oApontOssuario, "DATASERV"	    , "QRYSERV"     , "DATA"			, PesqPict("UJV","UJV_DTSEPU")  ,TamSX3("UJV_DTSEPU"		)[1]+3)
	TRCell():New( oApontOssuario, "NOMESERV"	    , "QRYSERV"     , "OBITO"			, PesqPict("UJV","UJV_NOME"	)   ,TamSX3("UJV_NOME"		)[1]+1)
	TRCell():New( oApontOssuario, "OSSARIO"	    	, "QRYSERV"     , "OSSUARIO"	    , PesqPict("UJV","UJV_OSSARI")  ,TamSX3("UJV_OSSARI"	)[1]+1)
	TRCell():New( oApontOssuario, "NICHOOSSUA"	    , "QRYSERV"     , "N.OSSUARIO"	    , PesqPict("UJV","UJV_NICHOO")  ,TamSX3("UJV_NICHOO"	)[1]+1)

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	oTipo:SetHeaderPage(.F.) //Define que imprime cabeçalho das células no topo da página. (Parâmetro) Se verdadeiro, aponta que imprime o cabeçalho no topo da página
	oTipo:SetHeaderSection(.T.) //Define que imprime cabeçalho das células na quebra de seção.(Parâmetro) Se verdadeiro, aponta que imprime cabeçalho na quebra da seção
	oTipo:SetTotalInLine(.T.) //Define que a impressão dos totalizadores será em linha. (Parâmetro) Se verdadeiro, imprime os totalizadores em linha

	oTotalGer := TRSection():New(oServico,"Total Geral",{}) //TRSection():New(oReport,"Total Geral",{},,,,,,,,,,,.T.,,,,,1)
	oTotalGer:SetHeaderPage(.F.) //Define que imprime cabeçalho das células no topo da página. (Parâmetro) Se verdadeiro, aponta que imprime o cabeçalho no topo da página
	oTotalGer:SetHeaderSection(.T.) //Define que imprime cabeçalho das células na quebra de seção.(Parâmetro) Se verdadeiro, aponta que imprime cabeçalho na quebra da seção
	oTotalGer:SetTotalInLine(.T.) //Define que a impressão dos totalizadores será em linha. (Parâmetro) Se verdadeiro, imprime os totalizadores em linha

	TRCell():New(oTotalGer,"nTotalGer", , " ", "!@", 30)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Impressao do Cabecalho no topo da pagina
//oReport:Section(1):SetHeaderPage()
//oReport:Section(1):SetHeaderPage(.T.)
//oReport:Section(1):SetEdit(.T.)
//oReport:Section(2):SetEdit(.T.)
//oApontamento:SetEdit(.T.)

	RestArea(aArea)

Return(oReport)

/*/{Protheus.doc} PrintReport
funcao para preencher os dados a serem impressos
no relatorio
@type function
@version 
@author g.sampaio
@since 05/05/2020
@param oReport, object, objeto de impressao do relatorio
@param oTipo, object, objeto de impressao da Section do tipo de endereco
@param oServico, object, objeto de impressao da Section do servico
@param oApontCremacao, object, objeto de impressao da Section para cremacao
@param oApontJazigo, object, objeto de impressao da Section para jazigos
@param oApontOssuario, object, objeto de impressao da Section para ossuario
@param oTotalGer, object, objeto de impressao do totalizador
@return nil
/*/
Static Function PrintReport( oReport, oTipo, oServico, oApontServAdd, oApontCremacao, oApontJazigo, oApontOssuario, oTotalGer)

	Local aArea         := GetArea()
	Local cQuery 		:= "" //Query de busca
	Local cTipoEnd		:= ""
	Local cContratoDe	:= ""
	Local cContratoAte	:= ""
	Local cPlanoDe		:= ""
	Local cPlanoAte		:= ""
	Local cServico		:= ""
	Local dDataDe		:= ""
	Local dDataAte		:= ""
	Local lHabTalona	:= SuperGetMV("MV_XHABTAL", .F., .F.)
	Local nTemPedido	:= 0
	Local nEndereco		:= 0
	Local nCont			:= 0
	Local nCont1		:= 0
	Local nTotBase		:= 0
	Local nTotalGer		:= 0
	Local nInd			:= 0
	Local nTotal		:= 0

	// faco a validacao dos parametros do relatorio
	If ValidParam( @cContratoDe, @cContratoAte, @cPlanoDe, @cPlanoAte, @cServico, @dDataDe, @dDataAte, @nTemPedido, @nEndereco )

		If Select("QRYSERV") > 0
			QRYSERV->(DbCloseArea())
		Endif

		// query de consulta do relatorio
		cQuery := " SELECT "
		cQuery += " 	'SERVICO' DESCRI, "
		cQuery += " 	UJV.UJV_CODIGO 	APONTAMENTO, "
		cQuery += " 	UJV.UJV_CONTRA	CONTRATO, "

		If lHabTalona
			cQuery += " 	U00.U00_TALONA	TALONA, "
		EndIf

		cQuery += " 	UJV.UJV_PEDIDO 	PEDIDO, "
		cQuery += " 	UJV.UJV_SERVIC	SERVICO, "
		cQuery += " 	SB1.B1_DESC 	DESCSERVICO, "
		cQuery += " 	U00.U00_PLANO 	PLANO, "
		cQuery += " 	U05.U05_DESCRI  DESCPLANO, "
		cQuery += " 	U00.U00_CLIENT	CODCLIENTE, "
		cQuery += " 	U00.U00_LOJA 	LOJACLI, "
		cQuery += " 	SA1.A1_NOME 	NOMECLI, "
		cQuery += " 	(CASE WHEN UJV.UJV_QUADRA <> ' ' THEN 'J' ELSE (CASE WHEN UJV.UJV_CREMAT <> ' ' THEN 'C' ELSE 'O'END ) END ) TIPOEND, "
		cQuery += " 	UJV.UJV_QUADRA  QUADRA, "
		cQuery += " 	UJV.UJV_MODULO 	MODULO, "
		cQuery += " 	UJV.UJV_JAZIGO	JAZIGO, "
		cQuery += " 	UJV.UJV_GAVETA 	GAVETA, "
		cQuery += " 	UJV.UJV_CREMAT 	CREMATORIO, "
		cQuery += " 	UJV.UJV_NICHOC 	NICHOCREMA, "
		cQuery += " 	UJV.UJV_OSSARI 	OSSUARIO, "
		cQuery += " 	UJV.UJV_NICHOO  NICHOOSSUA, "
		cQuery += " 	UJV.UJV_DTSEPU 	DATASERV, "
		cQuery += " 	UJV.UJV_NOME	NOMESERV "
		cQuery += " FROM " + RetSqlName("UJV") + " UJV INNER JOIN " + RetSqlName("U00") + " U00 ON U00.D_E_L_E_T_ = ' ' "
		cQuery += " AND U00.U00_FILIAL = '" + xFilial("U00") + "' "
		cQuery += " AND U00.U00_CODIGO = UJV.UJV_CONTRA "

		// contrato
		cQuery += " AND U00.U00_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' "

		cQuery += " INNER JOIN " + RetSqlName("U05") + " U05 ON U05.D_E_L_E_T_ = ' ' "
		cQuery += " AND U05.U05_FILIAL = '" + xFilial("U05") + "' "
		cQuery += " AND U05.U05_CODIGO = U00.U00_PLANO "

		// plano
		cQuery += " AND U05.U05_CODIGO BETWEEN '" + cPlanoDe + "' AND '" + cPlanoAte + "' "

		cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = ' ' "
		cQuery += " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery += " AND SA1.A1_COD  = U00.U00_CLIENT "
		cQuery += " AND SA1.A1_LOJA = U00.U00_LOJA "
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = ' ' "
		cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery += " AND SB1.B1_COD = UJV.UJV_SERVIC "
		cQuery += " WHERE UJV.D_E_L_E_T_ = ' ' "
		cQuery += " AND UJV.UJV_SERVIC <> ' ' "
		cQuery += " AND UJV.UJV_FILIAL = '" + xFilial("UJV") + "' "

		// data do servico
		cQuery += " AND UJV.UJV_DTSEPU BETWEEN '" + dDataDe + "' AND  '" + dDataAte + "' "

		// verifico se o servico esta preenchido
		If !Empty( cServico )
			cQuery += " AND UJV.UJV_SERVIC = '" + cServico  + "' "
		EndIf

		// verifico se filtro apenas com pedido
		If nTemPedido == 1
			cQuery += " AND UJV.UJV_PEDIDO <> ' ' "
		EndIf

		If nEndereco == 2 // Crematorio

			// campo crematorio diferente de vazio
			cQuery += " AND UJV.UJV_CREMAT <> ' ' "

		ElseIf nEndereco == 3 // Jazigo

			// campo quadra diferente de vazio
			cQuery += " AND UJV.UJV_QUADRA <> ' ' "

		ElseIf nEndereco == 4 // Osssuario

			// campo ossuario diferente de vazio
			cQuery += " AND UJV.UJV_OSSARI <> ' ' "

		ElseIf nEndereco == 5 // Servicos adicionais
			cQuery += " AND UJV.UJV_CREMAT = ' ' " // campo crematorio igual a vazio
			cQuery += " AND UJV.UJV_QUADRA = ' ' " // campo quadra igual a vazio
			cQuery += " AND UJV.UJV_OSSARI = ' ' " // campo ossuario igual a vazio
		EndIf

		//==============================================================
		// Faço o Union com a UJX para trazer os serviços adicionais
		//==============================================================

		cQuery += " UNION ALL "
		cQuery += " SELECT "
		cQuery += " 'SERVICOADICIONAL' DESCRI, "
		cQuery += " 	UJV.UJV_CODIGO 	APONTAMENTO, "
		cQuery += " 	UJV.UJV_CONTRA	CONTRATO, "

		If lHabTalona
			cQuery += " 	U00.U00_TALONA	TALONA, "
		EndIf

		cQuery += " 	UJV.UJV_PEDIDO 	PEDIDO, "
		cQuery += " 	UJX.UJX_SERVIC 	SERVICO, "
		cQuery += " 	SB1.B1_DESC 	DESCSERVICO, "
		cQuery += " 	U00.U00_PLANO 	PLANO, "
		cQuery += " 	U05.U05_DESCRI  DESCPLANO, "
		cQuery += " 	U00.U00_CLIENT	CODCLIENTE, "
		cQuery += " 	U00.U00_LOJA 	LOJACLI, "
		cQuery += " 	SA1.A1_NOME 	NOMECLI, "
		cQuery += "		'A'  			TIPOEND, "
		cQuery += " 	UJV.UJV_QUADRA  QUADRA, "
		cQuery += " 	UJV.UJV_MODULO 	MODULO, "
		cQuery += " 	UJV.UJV_JAZIGO	JAZIGO, "
		cQuery += " 	UJV.UJV_GAVETA 	GAVETA, "
		cQuery += " 	UJV.UJV_CREMAT 	CREMATORIO, "
		cQuery += " 	UJV.UJV_NICHOC 	NICHOCREMA, "
		cQuery += " 	UJV.UJV_OSSARI 	OSSUARIO, "
		cQuery += " 	UJV.UJV_NICHOO  NICHOOSSUA, "
		cQuery += " 	UJV.UJV_DTSEPU 	DATASERV, "
		cQuery += " 	UJV.UJV_NOME	NOMESERV "
		cQuery += " FROM " + RetSqlName("UJV") + " UJV INNER JOIN " + RetSqlName("UJX") + " UJX ON UJX.D_E_L_E_T_ = ' ' "
		cQuery += " AND UJX.UJX_FILIAL = '" + xFilial("UJX") + "' "
		cQuery += " AND UJX.UJX_CODIGO = UJV.UJV_CODIGO "

		// verifico se o servico esta preenchido
		If !Empty( cServico )
			cQuery += " AND UJX.UJX_SERVIC = '" + cServico  + "' "
		EndIf

		cQuery += " LEFT JOIN " + RetSqlName("U00") + " U00 ON U00.D_E_L_E_T_ = ' ' "
		cQuery += " AND U00.U00_FILIAL = '" + xFilial("U00") + "' "
		cQuery += " AND U00.U00_CODIGO = UJV.UJV_CONTRA "

		// contrato
		cQuery += " AND U00.U00_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' "

		cQuery += " LEFT JOIN " + RetSqlName("U05") + " U05 ON U05.D_E_L_E_T_ = ' ' "
		cQuery += " AND U05.U05_FILIAL = '" + xFilial("U05") + "' "
		cQuery += " AND U05.U05_CODIGO = U00.U00_PLANO "

		// plano
		cQuery += " AND U05.U05_CODIGO BETWEEN '" + cPlanoDe + "' AND '" + cPlanoAte + "' "

		cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = ' ' "
		cQuery += " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery += " AND SA1.A1_COD  = U00.U00_CLIENT "
		cQuery += " AND SA1.A1_LOJA = U00.U00_LOJA "
		cQuery += " LEFT JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_ = '' "
		cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery += " AND SB1.B1_COD = UJX.UJX_SERVIC "
		cQuery += " WHERE UJV.D_E_L_E_T_ = ' ' "
		cQuery += " AND UJV.UJV_SERVIC = ' ' "
		cQuery += " AND UJV.UJV_FILIAL = '" + xFilial("UJV") + "' "

		// data do servico
		cQuery += " AND UJV.UJV_DATA BETWEEN '" + dDataDe + "' AND  '" + dDataAte + "' "

		// verifico se filtro apenas com pedido
		If nTemPedido == 1
			cQuery += " AND UJV.UJV_PEDIDO <> ' ' "
		EndIf

		If nEndereco == 2 // Crematorio

			// campo crematorio diferente de vazio
			cQuery += " AND UJV.UJV_CREMAT <> ' ' "

		ElseIf nEndereco == 3 // Jazigo

			// campo quadra diferente de vazio
			cQuery += " AND UJV.UJV_QUADRA <> ' ' "

		ElseIf nEndereco == 4 // Osssuario

			// campo ossuario diferente de vazio
			cQuery += " AND UJV.UJV_OSSARI <> ' ' "

		ElseIf nEndereco == 5 // Servicos adicionais
			cQuery += " AND UJV.UJV_CREMAT = ' ' " // campo crematorio igual a vazio
			cQuery += " AND UJV.UJV_QUADRA = ' ' " // campo quadra igual a vazio
			cQuery += " AND UJV.UJV_OSSARI = ' ' " // campo ossuario igual a vazio
		EndIf

		cQuery += " ORDER BY TIPOEND, SERVICO, DATASERV "

		MemoWrite("c:\temp\RCPGR031.txt",cQuery)

		// compatibilziacao da query
		cQuery := ChangeQuery(cQuery)

		TcQuery cQuery New Alias "QRYSERV"

		QRYSERV->(dbEval({|| nCont++}))
		QRYSERV->(dbGoTop())

		// incremento a quantidade de registros total
		oReport:SetMeter(nCont)

		oTipo:Init()
		oServico:Init()

		// percorro todos os dados de impressao
		While !oReport:Cancel() .And. QRYSERV->(!Eof())

			// incremento a quantida de registros a serem impressos
			oReport:IncMeter()

			If oReport:Cancel()
				Exit
			EndIf

			// verifico se o tipo de endereco
			If AllTrim( cTipoEnd ) <> AllTrim( QRYSERV->TIPOEND )

				If nInd <> 0

					If cTipoEnd == "A"
						oApontServAdd:SetTotalText(" ")
						oApontServAdd:Finish()
						oTipo:Finish()
					ElseIf cTipoEnd == "C"
						oApontCremacao:SetTotalText(" ")
						oApontCremacao:Finish()
						oTipo:Finish()
					ElseIf cTipoEnd == "J"
						oApontJazigo:SetTotalText(" ")
						oApontJazigo:Finish()
						oTipo:Finish()
					ElseIf cTipoEnd == "O"
						oApontOssuario:SetTotalText(" ")
						oApontOssuario:Finish()
						oTipo:Finish()
					EndIf

					oTipo:Init()

				EndIf

				cTipoEnd := QRYSERV->TIPOEND // atualizo o tipo de endereco que sera impresso

				// imprimo o tipo de servico
				oTipo:Cell("TIPOEND"):SetValue( DescTipoEnd( cTipoEnd ) )
				oTipo:PrintLine()

				If cTipoEnd == "A"
					oApontServAdd:Init()
					TRFunction():New(oApontServAdd:Cell("APONTAMENTO"),/* cID */,"COUNT",/*oBreak*/,"Quantidade - Serviço Adicional",/*cPicture*/,/*uFormula*/,.T. /*lEndSection*/,.F. /*lEndReport*/,/*lEndPage*/)
				ElseIf cTipoEnd == "C"
					oApontCremacao:Init()
					TRFunction():New(oApontCremacao:Cell("APONTAMENTO"),/* cID */,"COUNT",/*oBreak*/,"Quantidade - Crematório",/*cPicture*/,/*uFormula*/,.T. /*lEndSection*/,.F. /*lEndReport*/,/*lEndPage*/)
				ElseIf cTipoEnd == "J"
					oApontJazigo:Init()
					TRFunction():New(oApontJazigo:Cell("APONTAMENTO"),/* cID */,"COUNT",/*oBreak*/,"Quantidade - Jazigo",/*cPicture*/,/*uFormula*/,.T. /*lEndSection*/,.F. /*lEndReport*/,/*lEndPage*/)
				ElseIf cTipoEnd == "O"
					oApontOssuario:Init()
					TRFunction():New(oApontOssuario:Cell("APONTAMENTO"),/* cID */,"COUNT",/*oBreak*/,"Quantidade - Ossuário",/*cPicture*/,/*uFormula*/,.T. /*lEndSection*/,.F. /*lEndReport*/,/*lEndPage*/)
				EndIf

			EndIf

			// verifico o servio que esta sendo impresso
			If AllTrim( cServico ) <> AllTrim( QRYSERV->SERVICO )

				if nInd <> 0
					oServico:Finish()
					oReport:ThinLine()
					oServico:Init()
					TRFunction():New(oServico:Cell("SERVICO"),/* cID */,"COUNT",/*oBreak*/,"Serviço - " + QRYSERV->DESCSERVICO ,/*cPicture*/,/*uFormula*/,.T. /*lEndSection*/,.F. /*lEndReport*/,/*lEndPage*/)
				EndIf

				cServico := QRYSERV->SERVICO  // atualizo o codigo do servico

				oServico:Cell("SERVICO"):SetValue( QRYSERV->DESCSERVICO )
				oServico:PrintLine()

			Endif

			// imprimo de acordo com o tipo
			If cTipoEnd == "A" // servicos adicionais

				oApontServAdd:Init()

				oApontServAdd:Cell("APONTAMENTO"):SetValue(QRYSERV->APONTAMENTO)
				oApontServAdd:Cell("CONTRATO"):SetValue(QRYSERV->CONTRATO)

				If lHabTalona
					oApontServAdd:Cell("TALONA"):SetValue(QRYSERV->TALONA)
				EndIf

				oApontServAdd:Cell("PEDIDO"):SetValue(QRYSERV->PEDIDO)
				oApontServAdd:Cell("NOMECLI"):SetValue(QRYSERV->NOMECLI)
				oApontServAdd:Cell("DESCPLANO"):SetValue(QRYSERV->DESCPLANO)
				oApontServAdd:Cell("DATASERV"):SetValue(DtoC(StoD(QRYSERV->DATASERV)))
				oApontServAdd:Cell("NOMESERV"):SetValue(QRYSERV->NOMESERV)

				oApontServAdd:PrintLine()

			ElseIf cTipoEnd == "C" // cremacao

				oApontCremacao:Init()

				oApontCremacao:Cell("APONTAMENTO"):SetValue(QRYSERV->APONTAMENTO)
				oApontCremacao:Cell("CONTRATO"):SetValue(QRYSERV->CONTRATO)

				If lHabTalona
					oApontCremacao:Cell("TALONA"):SetValue(QRYSERV->TALONA)
				EndIf

				oApontCremacao:Cell("PEDIDO"):SetValue(QRYSERV->PEDIDO)
				oApontCremacao:Cell("NOMECLI"):SetValue(QRYSERV->NOMECLI)
				oApontCremacao:Cell("DESCPLANO"):SetValue(QRYSERV->DESCPLANO)
				oApontCremacao:Cell("DATASERV"):SetValue(DtoC(StoD(QRYSERV->DATASERV)))
				oApontCremacao:Cell("NOMESERV"):SetValue(QRYSERV->NOMESERV)
				oApontCremacao:Cell("CREMATORIO"):SetValue(QRYSERV->CREMATORIO)
				oApontCremacao:Cell("NICHOCREMA"):SetValue(QRYSERV->NICHOCREMA)

				oApontCremacao:PrintLine()

			ElseIf cTipoEnd == "J" // jazigo

				oApontJazigo:Init()

				oApontJazigo:Cell("APONTAMENTO"):SetValue(QRYSERV->APONTAMENTO)
				oApontJazigo:Cell("CONTRATO"):SetValue(QRYSERV->CONTRATO)

				If lHabTalona
					oApontJazigo:Cell("TALONA"):SetValue(QRYSERV->TALONA)
				EndIf

				oApontJazigo:Cell("PEDIDO"):SetValue(QRYSERV->PEDIDO)
				oApontJazigo:Cell("NOMECLI"):SetValue(QRYSERV->NOMECLI)
				oApontJazigo:Cell("DESCPLANO"):SetValue(QRYSERV->DESCPLANO)
				oApontJazigo:Cell("DATASERV"):SetValue(DtoC(StoD(QRYSERV->DATASERV)))
				oApontJazigo:Cell("NOMESERV"):SetValue(QRYSERV->NOMESERV)
				oApontJazigo:Cell("QUADRA"):SetValue(QRYSERV->QUADRA)
				oApontJazigo:Cell("MODULO"):SetValue(QRYSERV->MODULO)
				oApontJazigo:Cell("JAZIGO"):SetValue(QRYSERV->JAZIGO)
				oApontJazigo:Cell("GAVETA"):SetValue(QRYSERV->GAVETA)

				oApontJazigo:PrintLine()

			ElseIf cTipoEnd == "O" // ossuario

				oApontOssuario:Init()

				oApontOssuario:Cell("APONTAMENTO"):SetValue(QRYSERV->APONTAMENTO)
				oApontOssuario:Cell("CONTRATO"):SetValue(QRYSERV->CONTRATO)

				If lHabTalona
					oApontOssuario:Cell("TALONA"):SetValue(QRYSERV->TALONA)
				EndIf

				oApontOssuario:Cell("PEDIDO"):SetValue(QRYSERV->PEDIDO)
				oApontOssuario:Cell("NOMECLI"):SetValue(QRYSERV->NOMECLI)
				oApontOssuario:Cell("DESCPLANO"):SetValue(QRYSERV->DESCPLANO)
				oApontOssuario:Cell("DATASERV"):SetValue(DtoC(StoD(QRYSERV->DATASERV)))
				oApontOssuario:Cell("NOMESERV"):SetValue(QRYSERV->NOMESERV)
				oApontOssuario:Cell("OSSUARIO"):SetValue(QRYSERV->OSSUARIO)
				oApontOssuario:Cell("NICHOOSSUA"):SetValue(QRYSERV->NICHOOSSUA)

				oApontOssuario:PrintLine()

			EndIf

			nInd++

			oReport:SkipLine()	//Pula uma linha

			QRYSERV->(dbSkip())
		EndDo

		oServico:Finish()
		oReport:ThinLine()

		oTotalGer:Init()
		oTotalGer:Cell("nTotalGer"):SetValue("Total dos Serviços: "+cValToChar(nTotal))
		oTotalGer:PrintLine()
		oTotalGer:SetTotalText(" ")
		oTotalGer:Finish()

		oTotalGer:SetPageBreak(.T.)

		If Select("QRYSERV") > 0
			QRYSERV->(DbCloseArea())
		Endif

	EndIf

	RestArea( aArea )

Return( Nil )

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
	Local nI        := 0

	Default cPerg   := ""

	// parametros SX1
	aAdd(aRegs,{cPerg,'01','Contrato De  '         	,'','','mv_ch1','C', TamSX3("U00_CODIGO")[1]    , 0, 0,'G','','mv_par01','','','','','','U00'})
	aAdd(aRegs,{cPerg,'02','Contrato Até '          ,'','','mv_ch2','C', TamSX3("U00_CODIGO")[1]    , 0, 0,'G','','mv_par02','','','','','','U00'})
	aAdd(aRegs,{cPerg,'03','Plano De '              ,'','','mv_ch3','C', TamSX3("U05_CODIGO")[1]    , 0, 0,'G','','mv_par03','','','','','','U05'})
	aAdd(aRegs,{cPerg,'04','Plano Ate'             	,'','','mv_ch4','C', TamSX3("U05_CODIGO")[1]    , 0, 0,'G','','mv_par04','','','','','','U05'})
	aAdd(aRegs,{cPerg,'05','Data De'              	,'','','mv_ch5','D', TamSX3("UJV_DTSEPU")[1]    	, 0, 0,'G','','mv_par05','','','','','',''})
	aAdd(aRegs,{cPerg,'06','Data Ate'             	,'','','mv_ch6','D', TamSX3("UJV_DTSEPU")[1]   	, 0, 0,'G','','mv_par06','','','','','',''})
	aAdd(aRegs,{cPerg,'07','Serviço '              	,'','','mv_ch7','C', TamSX3("B1_COD")[1]    	, 0, 0,'G','','mv_par07','','','','','','SB1SRV'})
	aAdd(aRegs,{cPerg,'08','Considera Pedido '     	,'','','mv_ch8','N', 01    						, 0, 2,'N','','mv_par08','1=Sim','2=Não','','','',''})
	aAdd(aRegs,{cPerg,'09','Considera Endereco '   	,'','','mv_ch9','N', 01    						, 0, 1,'N','','mv_par09','1=Ambos','2=Crematório','3=Jazigo','4=Ossuário','5=Serviços Adicionais',''})

	dbSelectArea('SX1')
	SX1->(dbSetOrder(1))

	// percorro os parametros a serem criados
	For nI := 1 to Len(aRegs)

		If  RecLock('SX1',Iif(!SX1->(DbSeek(PadR(aRegs[nI][01],10)+aRegs[nI][02])),.T.,.F.))

			Replace SX1->X1_GRUPO       With aRegs[nI][01]
			Replace SX1->X1_ORDEM       With aRegs[nI][02]
			Replace SX1->X1_PERGUNT    With aRegs[nI][03]
			Replace SX1->X1_PERSPA      With aRegs[nI][04]
			Replace SX1->X1_PERENG      With aRegs[nI][05]
			Replace SX1->X1_VARIAVL     With aRegs[nI][06]
			Replace SX1->X1_TIPO        With aRegs[nI][07]
			Replace SX1->X1_TAMANHO     With aRegs[nI][08]
			Replace SX1->X1_DECIMAL     With aRegs[nI][09]
			Replace SX1->X1_PRESEL      With aRegs[nI][10]
			Replace SX1->X1_GSC         With aRegs[nI][11]
			Replace SX1->X1_VALID       With aRegs[nI][12]
			Replace SX1->X1_VAR01       With aRegs[nI][13]
			Replace SX1->X1_DEF01       With aRegs[nI][14]
			Replace SX1->X1_DEF02       With aRegs[nI][15]
			Replace SX1->X1_DEF03       With aRegs[nI][16]
			Replace SX1->X1_DEF04       With aRegs[nI][17]
			Replace SX1->X1_DEF05       With aRegs[nI][18]
			Replace SX1->X1_F3          With aRegs[nI][19]
			MsUnlock('SX1')

		Else

			Help('',1,'REGNOIS')

		Endif

	Next nI

	RestArea( aArea )

Return( Nil )

/*/{Protheus.doc} ValidParam
funcao para validar os parametros do relatorio
@type function
@version 
@author g.sampaio
@since 12/05/2020
@param cContratoDe, character, parametro de inicio de range de contrato 
@param cContratoAte, character, parametro de fim de range de contrato 
@param cPlanoDe, character, parametro de inicio de range de plano 
@param cPlanoAte, character, parametro de fim de range de plano 
@param cServico, character, parametro em que preenche o servico espefico 
@param dDataDe, date, parametro de inicio de range de data do servico 
@param dDataAte, date, parametro de inicio de range de data do servico 
@return return_type, return_description
/*/
Static Function ValidParam( cContratoDe, cContratoAte, cPlanoDe, cPlanoAte, cServico, dDataDe, dDataAte, nTemPedido, nEndereco )

	Local aArea 			:= GetArea()
	Local lRetorno			:= .T.

	Default cContratoDe		:= ""
	Default cContratoAte	:= ""
	Default cPlanoDe		:= ""
	Default cPlanoAte		:= ""
	Default cServico		:= ""
	Default dDataDe			:= Stod("")
	Default dDataAte		:= Stdo("")
	Default nTemPedido		:= 0
	Default nEndereco		:= 0

	// atribuo os valores das variaveis
	cContratoDe		:= MV_PAR01
	cContratoAte	:= MV_PAR02
	cPlanoDe		:= MV_PAR03
	cPlanoAte		:= MV_PAR04
	dDataDe			:= MV_PAR05
	dDataAte		:= MV_PAR06
	cServico		:= MV_PAR07
	nTemPedido		:= MV_PAR08
	nEndereco		:= MV_PAR09

	// verifico os dados do contrato
	If lRetorno .And. Empty( cContratoDe ) .And. Empty( cContratoAte )
		cContratoDe		:= Replicate(" ",TamSX3("U00_CODIGO")[1]) // atribuo o valor vazio
		cContratoAte	:= Replicate("Z",TamSX3("U00_CODIGO")[1]) // atrubuo o valor "ZZZZZZ"
	EndIf

	// verifico os dados do plano
	If lRetorno .And. Empty( cPlanoDe ) .And. Empty( cPlanoAte )
		cPlanoDe	:= Replicate(" ",TamSX3("U05_CODIGO")[1]) // atribuo o valor vazio
		cPlanoAte	:= Replicate("Z",TamSX3("U05_CODIGO")[1]) // atrubuo o valor "ZZZZZZ"
	EndIf

	// faco a validacao da data
	If lRetorno .And. dDataAte > dDataAte
		// retorno negativo para a rotina
		lRetorno	:= .F.
		MsgAlert("O parametro <Data De> não pode ser maior que o campo <Data Ate>, preencha corretamente e tente imprirmir novamente!")
	EndIf

	// verifico os dados de data
	If lRetorno .And. ValType(dDataDe) == "D"
		dDataDe := Dtos(dDataDe)
	EndIf

	// verifico os dados de data
	If lRetorno .And. ValType(dDataAte) == "D"
		dDataAte := Dtos(dDataAte)
	EndIf

	// valor default do parametro de pedido
	If lRetorno .And. nTemPedido > 0
		nTemPedido := 2 // 2=Nao
	EndIf

	// valor default do parametro de endereco
	If lRetorno .And. nEndereco > 0
		nEndereco := 1 // 1=Ambos
	EndIf

	RestArea( aArea )

Return(lRetorno)

/*/{Protheus.doc} DescTipoEnd
description
@type function
@version 
@author g.sampaio
@since 12/05/2020
@param cTipoEnd, character, param_description
@return return_type, return_description
/*/
Static Function DescTipoEnd( cTipoEnd )

	Local aArea 		:= GetArea()
	Local cRetorno		:= ""

	Default cTipoEnd	:= ""

	// verifico os tipos
	If cTipoEnd	== "A"
		cRetorno	:= "SERVIÇOS ADICIONAIS"
	ElseIf cTipoEnd	== "C"
		cRetorno	:= "CREMATÓRIO"
	ElseIf cTipoEnd	== "J"
		cRetorno	:= "JAZIGO"
	ElseIf cTipoEnd	== "O"
		cRetorno	:= "OSSUÁRIO"
	EndIf

	RestArea( aArea )

Return( cRetorno )
