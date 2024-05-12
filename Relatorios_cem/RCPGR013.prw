#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RCPGR013
// Relatório de Comissão de Cobrança (Analítico)
// Orientação: Paisagem

@author Pablo Cavalcante
@since 10/06/2016
@version undefined

@type function
/*/
User Function RCPGR013()

Local oReport
	
	oReport:= ReportDef()
	oReport:PrintDialog()

Return

/*/{Protheus.doc} ReportDef
// Na seção de definição do relatório, função ReportDef(), devem ser criados os componentes de impressão, 
as seções e as células, os totalizadores e demais componentes que o usuário poderá personalizar no relatório.

@author Pablo Cavalcante
@since 10/06/2016
@version undefined

@type function
/*/
Static Function ReportDef()

Local oReport
Local oComissao
Local oDetalhe
Local oTotal
Local cTitle    	:= "Relatório de Comissão de Cobrança (Analítico)"

Private cPerg 		:= "RCPGR013"

//variaveis das perguntas
Private	cVendDe
Private	cVendAt
Private	dEmisDe
Private	dEmisAt
Private	nConsPg
Private	dPagaDe
Private	dPagaAt
Private	nTipoRe

	oReport:= TReport():New("RCPGR013",cTitle,"RCPGR013",{|oReport| PrintReport(oReport,oComissao,oDetalhe,oTotal)},"Este relatório apresenta a relação de comissões por Vendedor.")
	oReport:SetLandScape() 			// Orientação paisagem 
	//oReport:HideHeader()  		// Nao imprime cabeçalho padrão do Protheus
	//oReport:HideFooter()			// Nao imprime rodapé padrão do Protheus
	oReport:HideParamPage()			// Inibe impressão da pagina de parametros
	oReport:SetUseGC( .F. ) 		// Desabilita o botão <Gestao Corporativa> do relatório
	oReport:DisableOrientation()  // Desabilita a seleção da orientação (retrato/paisagem)
	//oReport:cFontBody := "Arial"
	//oReport:nFontBody := 8

	AjustaSx1() // cria as perguntas para gerar o relatorio
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
	oComissao := TRSection():New(oReport,"Comissão",{"QRYCOMI"},{"Por Contrato","Por Cod. Cliente","Por Nome Cliente"}/*Ordens do Relatório*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oComissao:SetTotalInLine(.F.)
	
	TRCell():New(oComissao,"E3_VEND  ", "QRYCOMI", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,{|| QRYCOMI->E3_VEND })
	TRCell():New(oComissao,"A3_NOME  ", "QRYCOMI", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,{|| QRYCOMI->A3_NOME })
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oDetalhe := TRSection():New(oComissao,"Detalhe",{"QRYCOMI"})
	oDetalhe:SetHeaderPage(.F.)
	oDetalhe:SetHeaderSection(.T.) // Habilita Impressao Cabecalho no Topo da Pagina
	oDetalhe:SetTotalInLine(.F.)

	TRCell():New(oDetalhe,"E3_PREFIXO"	,"QRYCOMI",	"Prefixo", 		PesqPict("SE3","E3_PREFIXO"),TamSX3("E3_PREFIXO")[1]+1)
	TRCell():New(oDetalhe,"E3_NUM"		,"QRYCOMI",	"No Titulo", 	PesqPict("SE3","E3_NUM    "),TamSX3("E3_NUM    ")[1]+1)
	TRCell():New(oDetalhe,"E3_PARCELA"	,"QRYCOMI",	"Parcela", 		PesqPict("SE3","E3_PARCELA"),TamSX3("E3_PARCELA")[1]+1)
	
	TRCell():New(oDetalhe,"A1_COD"		,"QRYCOMI", "Cliente", 		PesqPict("SA1","A1_COD    "),TamSX3("A1_COD    ")[1]+1)
	TRCell():New(oDetalhe,"A1_LOJA"		,"QRYCOMI", "Loja   ", 		PesqPict("SA1","A1_LOJA   "),TamSX3("A1_LOJA   ")[1]+1)
	TRCell():New(oDetalhe,"A1_NOME"		,"QRYCOMI", "Nome   ", 		PesqPict("SA1","A1_NOME   "),TamSX3("A1_NOME   ")[1]+1)
	
	TRCell():New(oDetalhe,"E1_VENCREA"	,"QRYCOMI",	"Vect Titulo",	PesqPict("SE1","E1_VENCREA"),TamSX3("E1_VENCREA")[1]+1)
	TRCell():New(oDetalhe,"E1_BAIXA"	,"QRYCOMI",	"Baix Titulo",	PesqPict("SE1","E1_BAIXA  "),TamSX3("E1_BAIXA  ")[1]+1)
	TRCell():New(oDetalhe,"E3_VENCTO"	,"QRYCOMI",	"Vecto Comis",	PesqPict("SE3","E3_VENCTO "),TamSX3("E3_VENCTO ")[1]+1)
	TRCell():New(oDetalhe,"E3_DATA"		,"QRYCOMI",	"Pagto Comis",	PesqPict("SE3","E3_DATA   "),TamSX3("E3_DATA   ")[1]+1)
	
	TRCell():New(oDetalhe,"E1_VLCRUZ"	,"QRYCOMI",	"Vlr. Titulo",	PesqPict("SE1","E1_VLCRUZ "),TamSX3("E1_VLCRUZ ")[1]+1)
	//TRCell():New(oDetalhe,"E3_BASE"		,"QRYCOMI",	"Vlr. Base",	PesqPict("SE3","E3_BASE   "),TamSX3("E3_BASE   ")[1]+1)
	//TRCell():New(oDetalhe,"E3_PORC"		,"QRYCOMI",	"% Percentual",	PesqPict("SE3","E3_PORC   "),TamSX3("E3_PORC   ")[1]+1)
	TRCell():New(oDetalhe,"E3_COMIS"	,"QRYCOMI",	"Comissao",		PesqPict("SE3","E3_COMIS  "),TamSX3("E3_COMIS  ")[1]+1)
	
	// Alinhamento a direita dos campos de valores
	oDetalhe:Cell("E1_VLCRUZ"):SetHeaderAlign("RIGHT")
	//oDetalhe:Cell("E3_BASE"):SetHeaderAlign("RIGHT")
	//oDetalhe:Cell("E3_PORC"):SetHeaderAlign("RIGHT")
	oDetalhe:Cell("E3_COMIS"):SetHeaderAlign("RIGHT")
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oTotal := TRSection():New(oReport,"Total Geral",{}) //TRSection():New(oReport,"Total Geral",{},,,,,,,,,,,.T.,,,,,1)
	oTotal:SetHeaderPage(.F.)
	oTotal:SetHeaderSection(.T.)
	
	TRCell():New(oTotal,"TotalGer", , "Total Geral   ", "!@", 30)
	TRCell():New(oTotal,"nNrTitul", , "Nr. de Titulos", "99999",  15)
	//TRCell():New(oTotal,"nTotBase", , "Valor da Base ", PesqPict("SE3","E3_BASE"),  TamSX3("E3_PORC   ")[1]+5)
	//TRCell():New(oTotal,"nTotPorc", , "% Percentual  ", PesqPict("SE3","E3_PORC"),  TamSX3("E3_COMIS  ")[1]+5)
	TRCell():New(oTotal,"nTotComis",, "Total Comissao", PesqPict("SE3","E3_COMIS"), TamSX3("E3_COMIS  ")[1]+5)
	
	// Alinhamento a direita dos campos de valores
	oTotal:Cell("nNrTitul"):SetHeaderAlign("RIGHT")
	//oTotal:Cell("nTotBase"):SetHeaderAlign("RIGHT")
	//oTotal:Cell("nTotPorc"):SetHeaderAlign("RIGHT")
	oTotal:Cell("nTotComis"):SetHeaderAlign("RIGHT")
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Impressao do Cabecalho no topo da pagina
	oReport:Section(1):SetHeaderPage()
	oReport:Section(1):SetEdit(.T.)
	oDetalhe:SetEdit(.T.)
	oReport:Section(2):SetEdit(.T.)

Return(oReport)                                                               
 
/*/{Protheus.doc} PrintReport
// Inicia Logica Print Report

@author Pablo Cavalcante
@since 03/06/2016
@version undefined

@type function
/*/
Static Function PrintReport(oReport,oComissao,oDetalhe,oTotal)

Local cQry 			:= "" //Query de busca
Local nOrdem		:= 0
Local nCont			:= 0
Local nTotBase		:= 0
Local nTotComis		:= 0
Local nTotPorc		:= 0
Local nTotPerVen 	:= 0
Local nNrTitul		:= 0

	cVendDe := mv_par01
	cVendAt := mv_par02
	dEmisDe := mv_par03
	dEmisAt := mv_par04
	nConsPg := mv_par05
	dPagaDe := mv_par06
	dPagaAt := mv_par07
	nTipoRe := mv_par08

	nOrdem := oComissao:GetOrder()
	
	//TRFunction():New(oDetalhe:Cell("E3_BASE"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T. /*lEndSection*/,.F. /*lEndReport*/,/*lEndPage*/)
	//TRFunction():New(oDetalhe:Cell("E3_PORC"),/* cID */,"ONPRINT",/*oBreak*/,/*cTitle*/,/*cPicture*/,{|| nTotPerVen },.T./*lEndSection*/,.F. /*lEndReport*/,.F.)
	TRFunction():New(oDetalhe:Cell("E3_COMIS"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T. /*lEndSection*/,.F. /*lEndReport*/,/*lEndPage*/)
	
	cQry := "select SE3.*, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA3.A3_NOME, SE1.E1_VENCREA, SE1.E1_BAIXA, SE1.E1_VLCRUZ "
	cQry += " from " + RetSqlName("SE3") + " SE3"
	cQry += " inner join " + RetSqlName("SA1") + " SA1 on (SA1.D_E_L_E_T_ <> '*' and SA1.A1_FILIAL  = '" + xFilial("SA1") + "' and SA1.A1_COD = SE3.E3_CODCLI and SA1.A1_LOJA = SE3.E3_LOJA)"
	cQry += " inner join " + RetSqlName("SA3") + " SA3 on (SA3.D_E_L_E_T_ <> '*' and SA3.A3_FILIAL  = '" + xFilial("SA3") + "' and SA3.A3_COD = SE3.E3_VEND)"
	cQry += " inner join " + RetSqlName("SE1") + " SE1 on (SE1.D_E_L_E_T_ <> '*' and SE1.E1_XFILVEN = '"  + xFilial("SE1") + "' and SE1.E1_CLIENTE = SE3.E3_CODCLI and SE1.E1_LOJA = SE3.E3_LOJA and SE1.E1_PREFIXO = SE3.E3_PREFIXO and SE1.E1_NUM = SE3.E3_NUM and SE1.E1_PARCELA = SE3.E3_PARCELA and SE1.E1_TIPO = SE3.E3_TIPO)"
	cQry += " where SE3.D_E_L_E_T_ <> '*'"
	cQry += " and SE3.E3_XORIGEM = 'R' " //Recebimento de Titulos
	cQry += " and SE3.E3_FILIAL = '" + xFilial('SE3') + "'"
	cQry += " and SE3.E3_VEND BETWEEN '" + cVendDe + "' AND '" + cVendAt + "'"
	cQry += " and SE3.E3_EMISSAO BETWEEN '" + DTOS(dEmisDe) + "' AND '" + DTOS(dEmisAt) + "'"
	
	/* cConsPg -> Considera Pagamento da Comissão
		1 - Ambas
		2 - Em Aberta
		3 - Pagas
	*/
	If nConsPg == 2 
		cQry += " and SE3.E3_DATA = ''"
	ElseIf nConsPg == 3
		cQry += " and SE3.E3_DATA <> ''"
		cQry += " and SE3.E3_DATA BETWEEN '" + DTOS(dPagaDe) + "' AND '" + DTOS(dPagaAt) + "'"
	EndIf
	
	// Ordem do Relatório:
	If nOrdem == 1 //por Contrato
		cQry += " order by SE3.E3_FILIAL, SE3.E3_VEND, SE3.E3_XCONTRA"
	ElseIf nOrdem == 2 //por Cliente + Loja
		cQry += " order by SE3.E3_FILIAL, SE3.E3_VEND, SE3.E3_CODCLI, SE3.E3_LOJA"
	Else //por Nome Cliente
		cQry += " order by SE3.E3_FILIAL, SE3.E3_VEND, SA1.A1_NOME"
	EndIf
	
	If Select("QRYCOMI") > 0
		QRYCOMI->(dbCloseArea())
	EndIf
	
	cQry := Changequery(cQry)
	TCQUERY cQry NEW ALIAS "QRYCOMI"
	
	QRYCOMI->(dbEval({|| nCont++}))
	QRYCOMI->(dbGoTop())

	oReport:SetMeter(nCont)
	
	nTotBase 	:= 0
	nTotComis 	:= 0
	nTotPorc	:= 0

	While !oReport:Cancel() .And. QRYCOMI->(!EOF())
		
		cVend 		:= QRYCOMI->E3_VEND
		cNomeVend 	:= QRYCOMI->A3_NOME
		nAc1 := nAc2 := 0 
		//nTotPerVen 	:= 0
		//nNrTitul 	:= 0
		
		oComissao:Init()
		oComissao:PrintLine()
		
		If oReport:Cancel()
			Exit
		EndIf
		
		oDetalhe:Init()
		
		While QRYCOMI->(!Eof()) .And. xFilial("SE3") == QRYCOMI->E3_FILIAL .And. QRYCOMI->E3_VEND == cVend
			
			oReport:IncMeter()
			
			If oReport:Cancel()
				Exit
			EndIf
			
			oDetalhe:Cell("E3_PREFIXO"):SetValue(QRYCOMI->E3_PREFIXO)
			oDetalhe:Cell("E3_NUM"):SetValue(QRYCOMI->E3_NUM)
			oDetalhe:Cell("E3_PARCELA"):SetValue(QRYCOMI->E3_PARCELA)
			oDetalhe:Cell("A1_COD"):SetValue(QRYCOMI->A1_COD)
			oDetalhe:Cell("A1_LOJA"):SetValue(QRYCOMI->A1_LOJA)
			oDetalhe:Cell("A1_NOME"):SetValue(QRYCOMI->A1_NOME)
			oDetalhe:Cell("E1_VENCREA"):SetValue(StoD(QRYCOMI->E1_VENCREA))
			oDetalhe:Cell("E1_BAIXA"):SetValue(StoD(QRYCOMI->E1_BAIXA))
			oDetalhe:Cell("E3_VENCTO"):SetValue(StoD(QRYCOMI->E3_VENCTO))
			oDetalhe:Cell("E3_DATA"):SetValue(StoD(QRYCOMI->E3_DATA))
			oDetalhe:Cell("E1_VLCRUZ"):SetValue(QRYCOMI->E1_VLCRUZ)
			//oDetalhe:Cell("E3_BASE"):SetValue(QRYCOMI->E3_BASE)
			//oDetalhe:Cell("E3_PORC"):SetValue(QRYCOMI->E3_PORC)
			oDetalhe:Cell("E3_COMIS"):SetValue(QRYCOMI->E3_COMIS)
					
			nBasePrt :=	QRYCOMI->E3_BASE
			nComPrt  :=	QRYCOMI->E3_COMIS
			nAc1 += nBasePrt
			nAc2 += nComPrt
			nTotPerVen += (nBasePrt*QRYCOMI->E3_PORC)/100
			
			oDetalhe:PrintLine()
			
			nNrTitul++
			
			QRYCOMI->(dbSkip())
		EndDo
		
		nTotBase 	+= nAc1
		nTotComis 	+= nAc2
		nTotPorc	:= NoRound((nTotComis/nTotBase)*100,2)
		nTotPerVen  := NoRound((nTotPerVen/nAc1)*100,2)
		
		oReport:SkipLine()
		
		oDetalhe:SetTotalText("Total do Vendedor: " + cVend + " - " + cNomeVend)
		oDetalhe:Finish()
		
		oReport:SkipLine()
		
		//salta pagina por vendedor
		oComissao:SetPageBreak(.T.)
		
		oComissao:Finish()
		
	EndDo
	
	// oReport:PrintText("Total Geral: ",,010) 
	oTotal:Init()
	oTotal:Cell("nNrTitul"):SetValue(nNrTitul)
	//oTotal:Cell("nTotBase"):SetValue(nTotBase)
	//oTotal:Cell("nTotPorc"):SetValue(nTotPorc)
	oTotal:Cell("nTotComis"):SetValue(nTotComis)
	
	oTotal:PrintLine()
	oTotal:Finish()
	
	oTotal:SetPageBreak(.T.)
	
	QRYCOMI->(dbCloseArea())
	
Return

/*/{Protheus.doc} AjustaSX1
// Cria a tela de perguntas do relatorio
@author Pablo Cavalcante
@since 03/06/2016
@version undefined

@type function
/*/
Static Function AjustaSX1()

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

	U_xPutSX1( cPerg, "01","Do Vendedor ?                 ","","","mv_ch1","C",6,0,0,"G",'',"SA3","","",;
	"mv_par01","","","","","","","","","","","","","","","","",;
	{'Informe o código inicial dos vendededore','s a serem processados.                  '},aHelpEng,aHelpSpa) 
	
	U_xPutSX1( cPerg, "02","Ate o Vendedor ?              ","","","mv_ch2","C",6,0,0,"G",'',"SA3","","",;
	"mv_par02","","","","ZZZZZZ","","","","","","","","","","","","",;
	{'Informe o código final dos vendedores a ','serem processados.                      '},aHelpEng,aHelpSpa) 
	
	U_xPutSX1( cPerg, "03","Considera da Data ?           ","","","mv_ch3","D",8,0,0,"G","","","","",;
	"mv_par03","","","","","","","","","","","","","","","","",;
	{'Informe a data inicial de emissão das co','missões a serem processadas.            '},aHelpEng,aHelpSpa)
	
	U_xPutSX1( cPerg, "04","Até a Data ?                  ","","","mv_ch4","D",8,0,0,"G","(MV_PAR04 >= MV_PAR03)","","","",;
	"mv_par04","","","","","","","","","","","","","","","","",;
	{'Informe a data final de emissão das comi','ssões a serem processadas.              '},aHelpEng,aHelpSpa)    
	
	U_xPutSX1( cPerg, "05","Considera comissão ?          ","","","mv_ch5","C",1,0,0,"C","","","","",;
	"mv_par05","Ambas","Ambas","Ambas","1","Em Aberto","Em Aberto","Em Aberto","Pagas","Pagas","Pagas","","","","","","",;
	{'Indica quais as comissões devem ser ','consideradas no relatório: Em Aberto,',' Pagas ou Ambas.'},aHelpEng,aHelpSpa) 
	
	U_xPutSX1( cPerg, "06","Pagamento da Data ?           ","","","mv_ch6","D",8,0,0,"G","","","","",;
	"mv_par06","","","","","","","","","","","","","","","","",;
	{'Informe a data inicial de pagamento das ','comissões a serem processadas.          '},aHelpEng,aHelpSpa)
	
	U_xPutSX1( cPerg, "07","Até a Data ?                  ","","","mv_ch7","D",8,0,0,"G","(MV_PAR07 >= MV_PAR06)","","","",;
	"mv_par07","","","","","","","","","","","","","","","","",;
	{'Informe a data final de pagamento das co','missões a serem processadas.            '},aHelpEng,aHelpSpa)
	
	U_xPutSX1( cPerg, "08","Analitico ou Sintetico ?      ","","","mv_ch8","C",1,0,0,"C","","","","",;
	"mv_par10","Analitico","Analitico","Analitico","1","Sintetico","Sintetico","Sintetico",,,,"","","","","","",;
	{'Informe se rel. Analitico ou Sintetico. ','',''},aHelpEng,aHelpSpa) 

	
Return
