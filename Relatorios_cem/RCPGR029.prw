#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} RCPGR029
Relatorio de Situacao de Pagamento
@author Raphael Martins
@since 19/07/2019
@version P12
@param nulo
@return nulo
/*/
User Function RCPGR029()

	Local oReport

	oReport:= ReportDef()
	oReport:PrintDialog()

Return()

/*/{Protheus.doc} ReportDef
// Na seção de definição do relatório, função ReportDef(), devem ser criados os componentes de impressão,
as seções e as células, os totalizadores e demais componentes que o usuário poderá personalizar no relatório.

@author Raphael Martins
@since 19/07/2019
@version 1.0

@type function
/*/
Static Function ReportDef()

	Local oReport		:= NIL
	Local oContratos	:= NIL
	Local oTotal		:= NIL
	Local cTitle		:= "Relatório de Situação de Pagamento de Contratos Cemiterio"
	Local cPerg			:= "RCPGR029"

	oReport:= TReport():New(cPerg,cTitle,"RCPGR029",{|oReport| PrintReport(oReport,oContratos,oTotal)},"Este relatório apresenta a situação financeira dos contratos")
	//oReport:SetPortrait() 			// Orientação retrato
	oReport:SetLandscape()		// Orientação paisagem
	//oReport:HideHeader()  		// Nao imprime cabeçalho padrão do Protheus
	//oReport:HideFooter()			// Nao imprime rodapé padrão do Protheus
	oReport:HideParamPage()			// Inibe impressão da pagina de parametros
	oReport:SetUseGC( .F. ) 		// Desabilita o botão <Gestao Corporativa> do relatório
	//oReport:DisableOrientation()  	// Desabilita a seleção da orientação (retrato/paisagem)
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

	oContratos := TRSection():New(oReport,"Contratos",{"QRYCTR"})
	oContratos:SetHeaderPage(.F.)
	oContratos:SetHeaderSection(.T.) // Habilita Impressao Cabecalho no Topo da Pagina
	oContratos:SetTotalInLine(.F.)

	//////////////////////////////////////////////////////////////////////////
	////////////////// COLUNAS QUE SERAO IMPRESSAS //////////////////////////
	//////////////////////////////////////////////////////////////////////////

	TRCell():New(oContratos,"CONTRATO"			,"QRYCPROT", "Contrato"			, 		PesqPict("U00","U00_CODIGO")	,TamSX3("U00_CODIGO")[1]+10)
	TRCell():New(oContratos,"DESC_PLANO"		,"QRYCPROT", "Descrição"		, 		PesqPict("U00","U00_DESCPL")	,TamSX3("U00_DESCPL")[1]-25)
	TRCell():New(oContratos,"DATA_ATIVACAO"		,"QRYCPROT", "Data "			, 		PesqPict("U00","U00_DTATIV")	,TamSX3("U00_DTATIV")[1]+15)
	TRCell():New(oContratos,"COD_CLIENTE"		,"QRYCPROT", "Cliente"			, 		PesqPict("U00","U00_CLIENT")	,TamSX3("U00_CLIENT")[1]+10)
	TRCell():New(oContratos,"LOJA"				,"QRYCPROT", "Loja"				, 		PesqPict("U00","U00_LOJA")		,TamSX3("U00_LOJA")[1]+5)
	TRCell():New(oContratos,"NOME_CLIENTE"		,"QRYCPROT", "Nome"				, 		PesqPict("U00","U00_NOMCLI")	,TamSX3("U00_NOMCLI")[1])
	TRCell():New(oContratos,"PARCELAS"	   		,"QRYCPROT", "Parcelas"			,		"@E 99999"  					,20)
	TRCell():New(oContratos,"ENTRADA"	   		,"QRYCPROT", "Entrada"			,		PesqPict("SE1","E1_VALOR")  	,TamSX3("E1_VALOR ")[1]+1)
	TRCell():New(oContratos,"VALOR_TOTAL"  		,"QRYCPROT", "R$ Total"			,		PesqPict("SE1","E1_VALOR")  	,TamSX3("E1_VALOR ")[1]+1)
	TRCell():New(oContratos,"VALOR_BAIXADO" 	,"QRYCPROT", "R$ Pago"			,		PesqPict("SE1","E1_VALOR")  	,TamSX3("E1_VALOR ")[1]+1)
	TRCell():New(oContratos,"ABERTOS"		   	,"QRYCPROT", "Aberto"			,		PesqPict("SE1","E1_VALOR")  	,TamSX3("E1_VALOR ")[1]+1)

	//////////////////////////////////////////////////////////////////////////
	////////////////// 		TOTALIZADORES GERAIS	//////////////////////////
	//////////////////////////////////////////////////////////////////////////

	// Alinhamento a direita dos campos de valores
	oContratos:Cell("VALOR_TOTAL"):SetHeaderAlign("RIGHT")
	oContratos:Cell("ENTRADA"):SetHeaderAlign("RIGHT")
	oContratos:Cell("VALOR_BAIXADO"):SetHeaderAlign("RIGHT")
	oContratos:Cell("ABERTOS"):SetHeaderAlign("RIGHT")
	oContratos:Cell("PARCELAS"):SetHeaderAlign("CENTER")
	
	oTotal := TRSection():New(oReport,"Total Geral",{}) //TRSection():New(oReport,"Total Geral",{},,,,,,,,,,,.T.,,,,,1)
	oTotal:SetHeaderPage(.F.)
	oTotal:SetHeaderSection(.T.)

	TRCell():New(oTotal,"nTotal"	, , "R$ Total" 		,PesqPict("SE1","E1_VALOR")  ,TamSX3("E1_VALOR ")[1]+1)
	TRCell():New(oTotal,"nEntrada"	, , "R$ Entrada"	,PesqPict("SE1","E1_VALOR")  ,TamSX3("E1_VALOR ")[1]+1)
	TRCell():New(oTotal,"nBaixado"	, , "R$ Baixado"	,PesqPict("SE1","E1_VALOR")  ,TamSX3("E1_VALOR ")[1]+1)
	TRCell():New(oTotal,"nAberto"	, , "R$ Aberto"		,PesqPict("SE1","E1_VALOR")  ,TamSX3("E1_VALOR ")[1]+1)

	// Alinhamento a direita dos campos de valores
	oTotal:Cell("nTotal"):SetHeaderAlign("RIGHT")
	oTotal:Cell("nEntrada"):SetHeaderAlign("RIGHT")
	oTotal:Cell("nBaixado"):SetHeaderAlign("RIGHT")
	oTotal:Cell("nAberto"):SetHeaderAlign("RIGHT")
	
	//Impressao do Cabecalho no topo da pagina
	oReport:Section(1):SetHeaderPage()
	oReport:Section(1):SetEdit(.T.)
	oContratos:SetEdit(.T.)
	oReport:Section(2):SetEdit(.T.)

Return(oReport)

/*/{Protheus.doc} PrintReport
// Inicia Logica Print Report

@author Raphael Martins Garcia
@since 19/07/2019
@version undefined

@type function
/*/
Static Function PrintReport(oReport,oContratos,oTotal)

	Local nOrdem		:= 0
	Local nCont			:= 0
	Local nTotal 		:= 0
	Local nQuant		:= 0
	Local nStatus 		:= 0
	Local nTotal		:= 0
	Local nEntrada		:= 0
	Local nBaixado		:= 0
	Local nAberto		:= 0
		
	Local cQry 			:= ""
	Local cClientDe 	:= ""
	Local cClientAte	:= ""
	Local cLojaDe   	:= ""
	Local cLojaAte  	:= ""
	Local cContraDe 	:= ""
	Local cContraAte	:= ""
	Local cPlano		:= ""
	Local cStatus		:= ""
	Local dAtivaIni		:= CTOD("")
	Local dAtivaFim		:= CTOD("")
	
	Local cPrefixo 		:= Alltrim(SuperGetMv("MV_XPREFCT",.F.,"CTR"))
	Local cTipo			:= Alltrim(SuperGetMv("MV_XTIPOCT",.F.,"AT"))
	Local cTipoEnt		:= Alltrim(SuperGetMv("MV_XTIPOEN",.F.,"ENT"))
	Local cPulaLinha	:= Chr(13) + Chr(10)

	cClientDe 	:= MV_PAR01
	cClientAte	:= MV_PAR02
	cLojaDe   	:= MV_PAR03
	cLojaAte  	:= MV_PAR04
	cContraDe 	:= MV_PAR05
	cContraAte	:= MV_PAR06
	cPlano		:= MV_PAR07
	cStatus		:= MV_PAR08
	dAtivaIni	:= MV_PAR09
	dAtivaFim	:= MV_PAR10
	
	//nOrdem := oProtocolo:GetOrder()

	//////////////////////////////////////////////////////////////////////////
	////// CONSULTO OS TITULOS DE ACORDO COM OS PARAMETROS INFORMADOS ///////
	/////////////////////////////////////////////////////////////////////////

	cQry := " SELECT "
	cQry += " U00_CODIGO	AS  CONTRATO, "
	cQry += " U00_PLANO		AS 	COD_PLANO, "
	cQry += " U00_DESCPL	AS 	DESC_PLANO, "
	cQry += " U00_CLIENT	AS 	COD_CLIENTE, "
	cQry += " U00_LOJA		AS 	LOJA, "
	cQry += " U00_NOMCLI	AS 	NOME_CLIENTE, "
	cQry += " U00_DATA		AS 	DATA_VENDA, "
	cQry += " U00_QTDPAR 	AS  PARCELAS, "

	//////////////////////////////////////////
	/////      CONSULTO ENTRADA    //////////
	//////////////////////////////////////////

	cQry += " ISNULL((SELECT SUM(E1_VALOR + E1_ACRESC) FROM " + RetSQLName("SE1") + " E1 WHERE E1.D_E_L_E_T_ = ' ' AND E1.E1_FILIAL = '" + xFilial("SE1") + "'  "
	cQry += " AND E1.E1_PREFIXO = '" + cPrefixo + "' AND E1.E1_XCONTRA = CONTRATOS.U00_CODIGO AND E1.E1_TIPO = '" + cTipoEnt + "' ),0) AS ENTRADA, "

	//////////////////////////////////////////
	/////      CONSULTO VALOR TOTAL //////////
	//////////////////////////////////////////

	cQry += " ISNULL((SELECT SUM(E1_VALOR + E1_ACRESC) FROM " + RetSQLName("SE1") + " E1 WHERE E1.D_E_L_E_T_ = ' ' AND E1.E1_FILIAL = '" + xFilial("SE1") + "'  "
	cQry += " 	AND E1.E1_PREFIXO = '" + cPrefixo + "' AND E1.E1_XCONTRA = CONTRATOS.U00_CODIGO 
	cQry += "   AND E1.E1_TIPO IN ('" + cTipo + "','" + cTipoEnt + "') )
	cQry += " ,0) AS VALOR_TOTAL, "

	//////////////////////////////////////////
	/////      CONSULTO BAIXADOS	//////////
	//////////////////////////////////////////
	cQry += " ISNULL((SELECT Sum(E5_VALOR) " 
    cQry += "			FROM " + RetSQLName("SE1") + " E1 "
	cQry += "			INNER JOIN " + RetSQLName("SE5") + " E5 "
	cQry += " 		   	ON E1.D_E_L_E_T_ = ' '  "
	cQry += " 		   	AND E5.D_E_L_E_T_ = ' ' "
	cQry += " 		   	AND E1.E1_FILIAL = E5_FILIAL "
	cQry += " 		   	AND E1.E1_PREFIXO = E5.E5_PREFIXO "
	cQry += " 		   	AND E1.E1_NUM = E5.E5_NUMERO "
	cQry += " 		   	AND E1.E1_PARCELA = E5.E5_PARCELA "
	cQry += " 		   	AND E1.E1_TIPO = E5.E5_TIPO "
    cQry += "           WHERE   "
    cQry += "           	E1.E1_FILIAL = '" + xFilial("SE5") + "' " 
    cQry += "               AND E1.E1_PREFIXO = '" + cPrefixo + "'  "
    cQry += "               AND E1.E1_XCONTRA = CONTRATOS.U00_CODIGO  "
    cQry += "              	AND E1.E1_TIPO IN ('" + cTipo + "','" + cTipoEnt + "') "
	cQry += " 				AND E5.E5_RECPAG = 'R'  "
	cQry += " 				AND E5.E5_SITUACA <> 'C' "
	cQry += " 				AND ( (E5_TIPODOC = 'VL' AND E5_MOTBX = 'NOR' AND E5_ORIGEM <> 'LOJXREC' ) OR (E5_TIPODOC = 'BA' AND E5_MOTBX <> 'LIQ') ) "
   	cQry += " 				AND E5.E5_TIPODOC NOT IN ('MT','JR','ES','M2','J2','IB','AP','BL','C2','CB','CM','D2','DC','DV','NCC','SG','TC') "
    cQry += "               AND E1.E1_SALDO = 0), 0)               AS BAIXADOS,  "


	//////////////////////////////////////////
	/////      CONSULTO ABERTOS		//////////
	//////////////////////////////////////////

	cQry += " ISNULL((SELECT SUM(E1_VALOR + E1_ACRESC) FROM " + RetSQLName("SE1") + " E1 WHERE E1.D_E_L_E_T_ = ' ' AND E1.E1_FILIAL = '" + xFilial("SE1") + "'  "
	cQry += " 	AND E1.E1_PREFIXO = '" + cPrefixo + "' AND E1.E1_XCONTRA = CONTRATOS.U00_CODIGO 
	cQry += "   AND E1.E1_TIPO IN ('" + cTipo + "','" + cTipoEnt + "') "
	cQry += " 	AND E1.E1_SALDO > 0 ),0) AS ABERTOS "

	cQry += " FROM "
	cQry += RetSQLName("U00") + " CONTRATOS "

	cQry += " WHERE  "
	cQry += " CONTRATOS.D_E_L_E_T_ = ' ' "
	cQry += " AND U00_FILIAL = '" + xFilial("U00") + "' "

	//filtro por cliente
	if !Empty(cClientAte)
		cQry += " AND CONTRATOS.U00_CLIENT BETWEEN '" + Alltrim(cClientDe) + "' AND '" + Alltrim(cClientAte) + "' "
	endif

	//filtro por loja do cliente
	if !Empty(cLojaAte)
		cQry += " AND CONTRATOS.U00_LOJA BETWEEN '" + Alltrim(cLojaDe) + "' AND '" + Alltrim(cLojaAte) + "' " + cPulaLinha
	endif

	//filtro por contrato
	if !Empty(cContraAte)
		cQry += " AND CONTRATOS.U00_CODIGO BETWEEN '" + Alltrim(cContraDe) + "' AND '" + Alltrim(cContraAte) + "' " + cPulaLinha
	endif

	//filtro por plano
	if !Empty(cPlano)
		cQry += " 	AND CONTRATOS.U00_PLANO IN " + FormatIn( AllTrim(cPlano),";") + cPulaLinha
	endif
	
	if !Empty(cStatus)
		cQry += " AND CONTRATOS.U00_STATUS IN " + FormatIn( AllTrim(cStatus),";") 	+ cPulaLinha
	endif
	
	//filtro por Ativacao
	if !Empty(dAtivaFim)
		cQry += " AND CONTRATOS.U00_DTATIV BETWEEN '" + DTOS(dAtivaIni) + "' AND '" + DTOS(dAtivaFim) + "' " + cPulaLinha
	endif
		
	cQry += " ORDER BY DATA_VENDA, CONTRATO "
	
	If Select("QRYTIT") > 0
		QRYTIT->(dbCloseArea())
	EndIf

	cQry := Changequery(cQry)
	TcQuery cQry NEW ALIAS "QRYTIT"

	QRYTIT->(dbEval({|| nCont++}))
	QRYTIT->(DbGoTop())

	oReport:SetMeter(nCont)

	nTotal		:= 0
	nEntrada	:= 0
	nBaixado	:= 0
	nAberto		:= 0
	
	While !oReport:Cancel() .And. QRYTIT->(!EOF())

		oContratos:Init()
		oReport:IncMeter()

		If oReport:Cancel()
			Exit
		EndIf

		oContratos:Cell("CONTRATO"):SetValue(QRYTIT->CONTRATO)

		oContratos:Cell("DESC_PLANO"):SetValue(QRYTIT->DESC_PLANO)

		oContratos:Cell("DATA_ATIVACAO"):SetValue(STOD(QRYTIT->DATA_VENDA))

		oContratos:Cell("COD_CLIENTE"):SetValue(QRYTIT->COD_CLIENTE)

		oContratos:Cell("LOJA"):SetValue(QRYTIT->LOJA)

		oContratos:Cell("NOME_CLIENTE"):SetValue(QRYTIT->NOME_CLIENTE)

		oContratos:Cell("PARCELAS"):SetValue(QRYTIT->PARCELAS)

		oContratos:Cell("ENTRADA"):SetValue(QRYTIT->ENTRADA)

		oContratos:Cell("VALOR_TOTAL"):SetValue(QRYTIT->VALOR_TOTAL)

		oContratos:Cell("VALOR_BAIXADO"):SetValue(QRYTIT->BAIXADOS)

		oContratos:Cell("ABERTOS"):SetValue(QRYTIT->ABERTOS)

		oContratos:PrintLine()

		nTotal		+= QRYTIT->VALOR_TOTAL
		nEntrada	+= QRYTIT->ENTRADA
		nBaixado	+= QRYTIT->BAIXADOS
		nAberto		+= QRYTIT->ABERTOS

		oReport:SkipLine()

		QRYTIT->(DbSkip())

	EndDo

	oContratos:Finish()

	oTotal:Init()
	oTotal:Cell("nTotal"):SetValue(Round(nTotal,2))
	oTotal:Cell("nEntrada"):SetValue(nEntrada)
	oTotal:Cell("nBaixado"):SetValue(nBaixado)
	oTotal:Cell("nAberto"):SetValue(nAberto)

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

	Local aHelpPor	:= {}
	Local aHelpEng	:= {}
	Local aHelpSpa	:= {}

	U_xPutSX1( cPerg, "01","Do Cliente ?                 ","","","mv_ch1","C",6,0,0,"G",'',"SA1","","",;
	"mv_par01","","","","","","","","","","","","","","","","",;
	{'Informe o código inicial dos clientes','s a serem processados.                  '},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg, "02","Ate o Cliente ?              ","","","mv_ch2","C",6,0,0,"G",'',"SA1","","",;
	"mv_par02","","","","ZZZZZZ","","","","","","","","","","","","",;
	{'Informe o código final dos clientes a ','serem processados.                      '},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg, "03","Da Loja ?                 ","","","mv_ch3","C",2,0,0,"G",'',"","","",;
	"mv_par01","","","","","","","","","","","","","","","","",;
	{'Informe o código inicial das lojas','s a serem processados.                  '},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg, "04","Ate a Loja ?              ","","","mv_ch4","C",2,0,0,"G",'',"","","",;
	"mv_par02","","","","ZZ","","","","","","","","","","","","",;
	{'Informe o código final das lojas a ','serem processados.                      '},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg, "05","Do Contrato ?                 ","","","mv_ch5","C",6,0,0,"G",'',"U00","","",;
	"mv_par08","","","","","","","","","","","","","","","","",;
	{'Informe o código inicial dos contratos a',' serem processados.                     '},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg, "06","Ate o Contrato ?              ","","","mv_ch6","C",6,0,0,"G",'',"U00","","",;
	"mv_par09","","","","ZZZZZZ","","","","","","","","","","","","",;
	{'Informe o código final dos contratos a s','erem processados.                       '},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg, "07","Plano?","Plano?","Plano?","cPlano","C",99,0,0,"G","","U05MRK","","","MV_PAR07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	U_xPutSX1(cPerg,"08","Status Contrato?" 	,"","","mv_ch08","C",10,0,0,"G","","STFUN"	,"","","MV_PAR08","","","","","","","","","","","","","","","","",{"",""},{"",""},{"",""})
	
	U_xPutSX1( cPerg, "09","Da Ativação ?                  ","","","mv_ch9","D",8,0,0,"G","","","","",;
	"mv_par09","","","","","","","","","","","","","","","","",;
	{'Informe a data inicial de Ativacao dos Contra','tos a serem processados.              '},aHelpEng,aHelpSpa)
	
	U_xPutSX1( cPerg, "10","Ate Ativação ?                  ","","","mv_ch10","D",8,0,0,"G","","","","",;
	"mv_par10","","","","","","","","","","","","","","","","",;
	{'Informe a data Final de Ativacao dos Contra','tos a serem processados.              '},aHelpEng,aHelpSpa)
	
	
Return()

