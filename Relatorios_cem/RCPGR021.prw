#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RCPGR021
// Relatório Carnes gerados 
// Orientação do tipo Retrato

@author Raphael Martins 
@since 30/06/2016
@version undefined

@type function
/*/
User Function RCPGR021()

Local oReport

Private cMod 		:= ""

cMod := U_RetModul()

If !Empty(cMod)
	oReport:= ReportDef()
	oReport:PrintDialog()
EndIf  

Return

/*/{Protheus.doc} ReportDef
// Na seção de definição do relatório, função ReportDef(), devem ser criados os componentes de impressão, 
as seções e as células, os totalizadores e demais componentes que o usuário poderá personalizar no relatório.

@author Raphael Martins
@since 30/06/2016
@version undefined

@type function
/*/
Static Function ReportDef()

Local oReport
Local oProtocolo
Local oDetalhe
Local oTotal
Local cTitle    	:= "Relatório de Carnês gerados"

Private cPerg 		:= "RCEMR021"

    If cMod == 'FUN'
    	cPerg := "RFUNR021"
    EndIf
    
	oReport:= TReport():New("RCPGR021",cTitle,cPerg,{|oReport| PrintReport(oReport,oProtocolo,oDetalhe,oTotal)},"Este relatório apresenta a relação protocolos/carnês gerados no sistema.")
	oReport:SetPortrait() 		// Orientação retrato
	//oReport:SetLandscape()			// Orientação paisagem 
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
	oProtocolo := TRSection():New(oReport,"Protocolos",{"QRYCPRT"},{"Por Contrato","Por Cod. Cliente","Por Nome Cliente"}/*Ordens do Relatório*/,/*Campos do SX3*/,/*Campos do SIX*/)
	oProtocolo:SetTotalInLine(.F.)
	
	TRCell():New(oProtocolo,"U32_CLIENT  ", "QRYCPROT", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,{|| QRYCPROT->CLIENTE })
	TRCell():New(oProtocolo,"U32_LOJA    ", "QRYCPROT", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,{|| QRYCPROT->LOJA })
	TRCell():New(oProtocolo,"U32_NOME    ", "QRYCPROT", /*Titulo*/, /*Picture*/, /*Tamanho*/, /*lPixel*/,{|| RetField("SA1",1,xFilial("SA1")+QRYCPROT->CLIENTE+QRYCPROT->LOJA,"A1_NOME")})
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oDetalhe := TRSection():New(oProtocolo,"Detalhe",{"QRYCPROT"})
	oDetalhe:SetHeaderPage(.F.)
	oDetalhe:SetHeaderSection(.T.) // Habilita Impressao Cabecalho no Topo da Pagina
	oDetalhe:SetTotalInLine(.F.)

	TRCell():New(oDetalhe,"U32_CODIGO"	,"QRYCPROT", "Código"		, 		PesqPict("U32","U32_CODIGO"),TamSX3("U32_CODIGO")[1]+1)
	TRCell():New(oDetalhe,"U32_DATA"	,"QRYCPROT", "Data"			, 		PesqPict("U32","U32_DATA")  ,TamSX3("U32_DATA")[1]+10)
	TRCell():New(oDetalhe,"U32_CONTRA"	,"QRYCPROT", "Contrato"		, 		PesqPict("U32","U32_CONTRA"),TamSX3("U32_CONTRA")[1]+1)
	TRCell():New(oDetalhe,"U32_STATUS"	,"QRYCPROT", "Status"		, 		PesqPict("U32","U32_STATUS"),TamSX3("U32_STATUS")[1]+15)
	TRCell():New(oDetalhe,"U32_REFINI"	,"QRYCPROT", "Ref.Inicial"	, 		PesqPict("U32","U32_REFINI"),TamSX3("U32_REFINI")[1]+10)
	TRCell():New(oDetalhe,"U32_REFFIM"	,"QRYCPROT", "Ref.Final"	, 		PesqPict("U32","U32_REFFIM"),TamSX3("U32_REFFIM")[1]+10) 
	TRCell():New(oDetalhe,"U32_DTRECE"	,"QRYCPROT", "Dt.Recebimento", 		PesqPict("U32","U32_DTRECE"),TamSX3("U32_DTRECE")[1]+10)
	TRCell():New(oDetalhe,"U32_RESPON"	,"QRYCPROT", "Responsavel"	, 		PesqPict("U32","U32_RESPON"),35)
	TRCell():New(oDetalhe,"U32_CODROT"	,"QRYCPROT", "Cod Rota"		, 		PesqPict("U32","U32_CODROT"),TamSX3("U32_CODROT")[1]+10)
	TRCell():New(oDetalhe,"U34_DESCRI"	,"QRYCPROT", "Desc Rota"	, 		PesqPict("U34","U34_DESCRI"),TamSX3("U34_DESCRI")[1]+10)
	TRCell():New(oDetalhe,"VALOR"	    ,"QRYCPROT", "Valor"		,		PesqPict("SE1","E1_VALOR")  ,TamSX3("E1_VALOR ")[1]+1)
	TRCell():New(oDetalhe,"QUANT"	    ,"QRYCPROT", "Quant."		,  		"@E 99999")
	
	// Alinhamento a direita dos campos de valores
	oDetalhe:Cell("VALOR"):SetHeaderAlign("RIGHT")
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	oTotal := TRSection():New(oReport,"Total Geral",{}) //TRSection():New(oReport,"Total Geral",{},,,,,,,,,,,.T.,,,,,1)
	oTotal:SetHeaderPage(.F.)
	oTotal:SetHeaderSection(.T.)
	
	TRCell():New(oTotal,"nTotal", , "Valor" ,PesqPict("SE1","E1_VALOR")  ,TamSX3("E1_VALOR ")[1]+1)
	TRCell():New(oTotal,"nQuant", , "Quantidade ", "!@", 30)
	
	// Alinhamento a direita dos campos de valores
	oTotal:Cell("nTotal"):SetHeaderAlign("RIGHT")
	oTotal:Cell("nQuant"):SetHeaderAlign("RIGHT")
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Impressao do Cabecalho no topo da pagina
	oReport:Section(1):SetHeaderPage()
	oReport:Section(1):SetEdit(.T.)
	oDetalhe:SetEdit(.T.)
	oReport:Section(2):SetEdit(.T.)

Return(oReport)                                                               
 
/*/{Protheus.doc} PrintReport
// Inicia Logica Print Report

@author Raphael Martins Garcia 
@since 30/06/2016
@version undefined

@type function
/*/
Static Function PrintReport(oReport,oProtocolo,oDetalhe,oTotal)

Local nOrdem		:= 0
Local nCont			:= 0
Local nTotal 		:= 0
Local nQuant		:= 0
Local cStatus		:= ""
Local cDescRota		:= ""
Local cQry 			:= "" //Query de busca
Private cClientDe 	:= ""   
Private cClientAte	:= ""   
Private cLojaDe   	:= ""   
Private cLojaAte  	:= ""   
Private cContraDe 	:= ""   
Private cContraAte	:= ""   
Private cCliLoja    := ""
Private cNomeCli	:= ""
Private dRefIniDe 	:= CTOD("")   
Private dRefIniAte	:= CTOD("")   
Private dRefFimDe 	:= CTOD("") 
Private dRefFimAte	:= CTOD("")
Private dEmissaoDe 	:= CTOD("")
Private dEmissaoAte	:= CTOD("")  
Private nStatus 	:= 0
Private cRotas		:= ""

	cClientDe 	:= MV_PAR01   
	cClientAte	:= MV_PAR02   
	cLojaDe   	:= MV_PAR03   
	cLojaAte  	:= MV_PAR04   
	cContraDe 	:= MV_PAR05   
	cContraAte	:= MV_PAR06  
	dEmissaoDe 	:= MV_PAR07
	dEmissaoAte	:= MV_PAR08 
	dRefIniDe 	:= MV_PAR09   
	dRefIniAte	:= MV_PAR10   
	dRefFimDe 	:= MV_PAR11   
	dRefFimAte	:= MV_PAR12
	nStatus     := MV_PAR13
	cRotas 		:= MV_PAR14
	
	//nOrdem := oProtocolo:GetOrder()
	
	TRFunction():New(oDetalhe:Cell("VALOR"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T. /*lEndSection*/,.F. /*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oDetalhe:Cell("QUANT"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T. /*lEndSection*/,.F. /*lEndReport*/,/*lEndPage*/)
	
	cQry := " SELECT " 
	cQry += " U32_FILIAL FILIAL,  "
	cQry += " U32_CODIGO CODIGO, "
	cQry += " U32_DATA DATA, "
	cQry += " U32_CONTRA CONTRATO, "
	cQry += " U32_CLIENT CLIENTE, "
	cQry += " U32_LOJA LOJA, "
	cQry += " U32_DTRECE DTRECE, "
	cQry += " U32_RESPON RESPONSAVEL, "
	cQry += " U32_STATUS STATUS, "
	cQry += " U32_REFINI REFINI, "
	cQry += " U32_REFFIM REFFIM, "
	cQry += " U32_CODROT ROTA, "
	cQry += " ISNULL(SUM(U33_VALOR),0) VALOR, "
	cQry += " COUNT(*) QUANT "
	cQry += "  FROM "
	cQry += + RetSQLName("U32") + " U32 "
	
	cQry += " LEFT JOIN "
	cQry += + RetSQLName("U33") + " U33  "
	cQry += " ON U32.D_E_L_E_T_ = ' ' "
	cQry += " AND U33.D_E_L_E_T_ = ' ' " 
	cQry += " AND U32.U32_FILIAL = '" + xFilial("U32") + "' "
	cQry += " AND U32.U32_FILIAL = U33.U33_FILIAL " 
	cQry += " AND U32.U32_CODIGO = U33.U33_CODIGO  "
	cQry += "  WHERE "
	cQry += "    U32_CLIENT Between '" + cClientDe + "' AND '" + cClientAte + "' "
	cQry += "    AND U32_LOJA BETWEEN '" + cLojaDe + "' AND '" + cLojaAte + "' "
	cQry += "    AND U32_CONTRA BETWEEN '" + cContraDe + "' AND '" + cContraAte + "' "
	cQry += "    AND U32_DATA BETWEEN '" + Dtos(dEmissaoDe) + "' AND '" + Dtos(dEmissaoAte) + "' "
	cQry += "    AND U32_REFINI BETWEEN '" + Dtos(dRefIniDe) + "' AND '" + Dtos(dRefIniAte) + "' "
	cQry += "    AND U32_REFFIM BETWEEN '" + Dtos(dRefFimDe) + "' AND '" + Dtos(dRefFimAte) + "' "
	
	If cValToChar(nStatus) <> '5'
		cQry += " AND U32_STATUS = '"+cValToChar(nStatus)+"' "
	EndIf
	
	//valido se rota esta preenchido
	if !Empty(cRotas)
		
		cQry += " AND U32_CODROT IN " + FormatIn( AllTrim(cRotas),";") + " 
		 
	endif
	
	cQry += " GROUP BY  U32_FILIAL,U32_CODIGO,U32_DATA,U32_CONTRA,U32_CLIENT,U32_LOJA,U32_DTRECE, "
	cQry += " 			U32_RESPON,U32_STATUS,U32_REFINI,U32_REFFIM,U32_CODROT "
	
	cQry += " ORDER BY CLIENTE,LOJA,CODIGO,DATA,CONTRATO,REFINI,REFFIM,DTRECE "

	If Select("QRYCPROT") > 0
		QRYCPROT->(dbCloseArea())
	EndIf
	
	cQry := Changequery(cQry)
	TCQUERY cQry NEW ALIAS "QRYCPROT"
	
	QRYCPROT->(dbEval({|| nCont++}))
	QRYCPROT->(dbGoTop())

	oReport:SetMeter(nCont)
	
	nTotal 		:= 0
	nQuant		:= 0

	While !oReport:Cancel() .And. QRYCPROT->(!EOF())
		
		cCliLoja	:= QRYCPROT->CLIENTE + QRYCPROT->LOJA  
		cNomeCli 	:= RetField("SA1", 1 , xFilial("SA1") + cCliLoja, "A1_NOME")
		cDescRota	:= RetField("U34",1,xFilial("U34") + QRYCPROT->ROTA,"U34_DESCRI")
		
		
		oProtocolo:Init()
		oProtocolo:PrintLine()
		
		If oReport:Cancel()
			Exit
		EndIf
		
		oDetalhe:Init()
		
		While QRYCPROT->(!Eof()) .And. xFilial("U32") == QRYCPROT->FILIAL .And. QRYCPROT->CLIENTE + QRYCPROT->LOJA == cCliLoja
		
			oReport:IncMeter()
			
			If oReport:Cancel()
				Exit
			EndIf
			
	        cStatus := If(QRYCPROT->STATUS=='1','1=Gerado',If(QRYCPROT->STATUS=='2',"2=Entregue",If(QRYCPROT->STATUS=='3',"3=Não Recebido",If(QRYCPROT->STATUS=='4',"4=Devolvido","5=Todos"))))
			
			oDetalhe:Cell("U32_CODIGO"):SetValue(QRYCPROT->CODIGO)
			
			oDetalhe:Cell("U32_DATA"):SetValue(StoD(QRYCPROT->DATA))
			
			oDetalhe:Cell("U32_STATUS"):SetValue(cStatus)
			
			oDetalhe:Cell("U32_REFINI"):SetValue(StoD(QRYCPROT->REFINI))
			
			oDetalhe:Cell("U32_REFFIM"):SetValue(StoD(QRYCPROT->REFFIM))
			
			oDetalhe:Cell("U32_DTRECE"):SetValue(StoD(QRYCPROT->DTRECE))
			
			oDetalhe:Cell("U32_RESPON"):SetValue(SubStr(Alltrim(QRYCPROT->RESPONSAVEL),1,35))
			
			oDetalhe:Cell("U32_CODROT"):SetValue(Alltrim(QRYCPROT->ROTA))
			
			oDetalhe:Cell("U34_DESCRI"):SetValue(Alltrim(cDescRota))
			
			oDetalhe:Cell("VALOR"):SetValue(QRYCPROT->VALOR)
			oDetalhe:Cell("QUANT"):SetValue(QRYCPROT->QUANT)
			
			nTotal += QRYCPROT->VALOR
			nQuant += QRYCPROT->QUANT
			
			oDetalhe:PrintLine()
		
			QRYCPROT->(dbSkip())
		EndDo
		
		oReport:SkipLine()
		
		oDetalhe:SetTotalText("Total do Cliente: " + cCliLoja + " - " + cNomeCli)
		oDetalhe:Finish()
		
		oReport:SkipLine()
		
		oProtocolo:Finish()
		
	EndDo
	
	// oReport:PrintText("Total Geral: ",,010) 
	oTotal:Init()
	oTotal:Cell("nTotal"):SetValue(Round(nTotal,2))
	oTotal:Cell("nQuant"):SetValue(nQuant)
	
	oTotal:PrintLine()
	oTotal:Finish()
	
	oTotal:SetPageBreak(.T.)
	
	QRYCPROT->(dbCloseArea())
	
Return

/*/{Protheus.doc} AjustaSX1
// Cria a tela de perguntas do relatorio
@author Raphael Martins Garcia
@since 04/07/2016
@version undefined

@type function
/*/
Static Function AjustaSX1()

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {} 
Local cF3		:= "UF2"              

	If cMod == "CEM"
		cF3 := "U00"
	EndIf
	
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
	
	U_xPutSX1( cPerg, "05","Do Contrato ?                 ","","","mv_ch5","C",6,0,0,"G",'',cF3,"","",;
	"mv_par08","","","","","","","","","","","","","","","","",;
	{'Informe o código inicial dos contratos a',' serem processados.                     '},aHelpEng,aHelpSpa) 
	
	U_xPutSX1( cPerg, "06","Ate o Contrato ?              ","","","mv_ch6","C",6,0,0,"G",'',cF3,"","",;
	"mv_par09","","","","ZZZZZZ","","","","","","","","","","","","",;
	{'Informe o código final dos contratos a s','erem processados.                       '},aHelpEng,aHelpSpa)
	
	
	U_xPutSX1( cPerg, "07","Cons. da Data de Geração?           ","","","mv_ch7","D",8,0,0,"G","","","","",;
	"mv_par03","","","","","","","","","","","","","","","","",;
	{'Informe a data inicial de emissão dos proto','colos a serem processados.            '},aHelpEng,aHelpSpa)
	
	U_xPutSX1( cPerg, "08","Até a Data ?                  ","","","mv_ch8","D",8,0,0,"G","(MV_PAR08 >= MV_PAR07)","","","",;
	"mv_par04","","","","","","","","","","","","","","","","",;
	{'Informe a data final de emissão dos proto','colos a serem processados.              '},aHelpEng,aHelpSpa)    
	
	U_xPutSX1( cPerg, "09","Cons. da Data de Ref.Inicial ?                  ","","","mv_ch9","D",8,0,0,"G","","","","",;
	"mv_par04","","","","","","","","","","","","","","","","",;
	{'Informe a data ref.inicial de emissão dos proto','colos a serem processados.              '},aHelpEng,aHelpSpa)    
	
	U_xPutSX1( cPerg, "10","Até a Data ?                  ","","","mv_ch10","D",8,0,0,"G","(MV_PAR10 >= MV_PAR09)","","","",;
	"mv_par04","","","","","","","","","","","","","","","","",;
	{'Informe a data ref.inicial de emissão dos proto','colos a serem processados.              '},aHelpEng,aHelpSpa)    
	
	U_xPutSX1( cPerg, "11","Cons. da Data de Ref.Final ?                  ","","","mv_ch11","D",8,0,0,"G","","","","",;
	"mv_par04","","","","","","","","","","","","","","","","",;
	{'Informe a data ref.final de emissão dos proto','colos a serem processados.              '},aHelpEng,aHelpSpa)    
	
	U_xPutSX1( cPerg, "12","Até a Data ?                  ","","","mv_ch12","D",8,0,0,"G","(MV_PAR12 >= MV_PAR11)","","","",;
	"mv_par04","","","","","","","","","","","","","","","","",;
	{'Informe a data ref.final de emissão dos proto','colos a serem processados.              '},aHelpEng,aHelpSpa)    

	U_xPutSX1( cPerg, "13","Status ?                  ","","","mv_ch13","C",8,0,0,"C","","","","",;
	"mv_par04","1-Gerado","","","","2-Entregue","","","3-Nao Recebido","","","4-Devolvido","","","5-Todos","","",;
	{'Informe o status do proto','colos a serem processados.              '},aHelpEng,aHelpSpa)   
	
	///////////// Rota ////////////////
	U_xPutSX1( cPerg, "14","Rota(s)?","Rota(s)?","Rota(s)?","Rota","C",20,0,0,"G","","U34MAR","","","MV_PAR14","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	
	
Return