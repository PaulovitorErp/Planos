#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RUTILR04
Rotina de processamento de comissões para :
Vendedor, Cobrador, Supervisor e Gerente 
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
/*/

User Function RUTILR04()

Local oReport
	
oReport:= ReportDef()
oReport:PrintDialog()

Return( Nil )

/*/{Protheus.doc} ReportDef
// Na seção de definição do relatório, função ReportDef(), devem ser criados os componentes de impressão, 
as seções e as células, os totalizadores e demais componentes que o usuário poderá personalizar no relatório.

@author Pablo Cavalcante
@since 12/04/2016
@version undefined

@type function
/*/
Static Function ReportDef()

Local cPerg 		:= "RUTILR04"
Local cTitle    	:= "Relatório de Comissão Gerente/Supervisor"
Local oReport       := Nil
Local oComissao     := Nil
Local oTotal        := Nil

//variaveis das perguntas
Private	cVendDe		:= "" 
Private	cVendAt		:= ""
Private	dEmisDe		:= Stod("")
Private	dEmisAt		:= Stod("")
Private	nConsPg		:= 0
Private	dPagaDe		:= Stod("")
Private	dPagaAt		:= Stod("")
Private nTipo		:= 0
Private lSaltPg		:= .F.

oReport:= TReport():New("RUTILR04",cTitle,"RUTILR04",{|oReport| PrintReport(oReport,oComissao,oTotal)},"Este relatório apresenta a relação de comissões por Supervisor ou Gerente.")
oReport:SetLandscape() 			// Orientação paisagem 
oReport:HideParamPage()			// Inibe impressão da pagina de parametros
oReport:SetUseGC( .F. ) 		// Desabilita o botão <Gestao Corporativa> do relatório
oReport:DisableOrientation()  	// Desabilita a seleção da orientação (retrato/paisagem)
//oReport:SetLineHeight(50) 
//oReport:SetColSpace(2) 
//oReport:nFontBody := 10 

AjustaSx1( cPerg ) // cria as perguntas para gerar o relatorio
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

TRCell():New(oComissao,"E3_VEND"		,"QRYCOMI", "Vendedor ", 		PesqPict("SE3","E3_VEND")	,TamSX3("E3_VEND")[1]+50)
TRCell():New(oComissao,"A3_NOME"		,"QRYCOMI", "Nome", 			PesqPict("SA3","A3_NOME")	,TamSX3("A3_NOME")[1]+50)
TRCell():New(oComissao,"E3_VENCTO"		,"QRYCOMI",	"Vencto",			PesqPict("SE3","E3_VENCTO")	,TamSX3("E3_VENCTO")[1]+35)
TRCell():New(oComissao,"E3_DATA"		,"QRYCOMI",	"Pag",				PesqPict("SE3","E3_DATA")	,TamSX3("E3_DATA")[1]+35)
TRCell():New(oComissao,"E3_BASE"		,"QRYCOMI",	"Vlr. Base",		PesqPict("SE3","E3_BASE")	,TamSX3("E3_BASE")[1]+50)
TRCell():New(oComissao,"E3_PORC"		,"QRYCOMI",	"%",				PesqPict("SE3","E3_PORC")	,TamSX3("E3_PORC")[1]+20)
TRCell():New(oComissao,"E3_COMIS"		,"QRYCOMI",	"Comissao",			PesqPict("SE3","E3_COMIS")	,TamSX3("E3_COMIS")[1]+50)

// Alinhamento a direita dos campos de valores
oComissao:Cell("E3_BASE"):SetHeaderAlign("RIGHT")
oComissao:Cell("E3_PORC"):SetHeaderAlign("RIGHT")
oComissao:Cell("E3_COMIS"):SetHeaderAlign("RIGHT")

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
oTotal := TRSection():New(oReport,"Total Geral",{}) //TRSection():New(oReport,"Total Geral",{},,,,,,,,,,,.T.,,,,,1)
oTotal:SetHeaderPage(.F.)
oTotal:SetHeaderSection(.T.)

TRCell():New(oTotal,"TotalGer", , "Total Geral   ", "!@", 30)
TRCell():New(oTotal,"nTotBase", , "Valor da Base ", PesqPict("SE3","E3_BASE"), TamSX3("E3_PORC")[1]+50)
TRCell():New(oTotal,"nTotPorc", , "% Percentual  ", PesqPict("SE3","E3_PORC"), TamSX3("E3_COMIS")[1]+50)
TRCell():New(oTotal,"nTotComis",, "Total Comissão", PesqPict("SE3","E3_COMIS"), TamSX3("E3_COMIS")[1]+50)

// Alinhamento a direita dos campos de valores
oTotal:Cell("nTotBase"):SetHeaderAlign("RIGHT")
oTotal:Cell("nTotPorc"):SetHeaderAlign("RIGHT")
oTotal:Cell("nTotComis"):SetHeaderAlign("RIGHT")

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Impressao do Cabecalho no topo da pagina
oReport:Section(1):SetHeaderPage()
oReport:Section(1):SetEdit(.T.)
oReport:Section(2):SetEdit(.T.)

Return( oReport )                                                               
 
/*/{Protheus.doc} PrintReport
// Inicia Logica Print Report

@author Pablo Cavalcante
@since 12/04/2016
@version undefined

@type function
/*/
Static Function PrintReport(oReport,oComissao,oTotal)

Local cQry 			:= "" //Query de busca
Local nOrdem		:= 0
Local nCont			:= 0
Local nTotBase		:= 0
Local nTotComis		:= 0
Local nTotPorc		:= 0
Local nTotPerVen 	:= 0

cVendDe := mv_par01
cVendAt := mv_par02
dEmisDe := mv_par03
dEmisAt := mv_par04
nConsPg := mv_par05
dPagaDe := mv_par06
dPagaAt := mv_par07
nTipo   := mv_par08
lSaltPg := Iif(mv_par09 == 1,.T.,.F.)

nOrdem := oComissao:GetOrder()
	
TRFunction():New(oComissao:Cell("E3_BASE"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T. /*lEndSection*/,.F. /*lEndReport*/,/*lEndPage*/)
TRFunction():New(oComissao:Cell("E3_PORC"),/* cID */,"ONPRINT",/*oBreak*/,/*cTitle*/,/*cPicture*/,{|| nTotPerVen },.T./*lEndSection*/,.F. /*lEndReport*/,.F.)
TRFunction():New(oComissao:Cell("E3_COMIS"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T. /*lEndSection*/,.F. /*lEndReport*/,/*lEndPage*/)

If Select("QRYCOMI") > 0
	QRYCOMI->(dbCloseArea())
EndIf
	
cQry := "select SE3.*, SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA3.A3_NOME"
cQry += " from " + RetSqlName("SE3") + " SE3"
cQry += " inner join " + RetSqlName("SA1") + " SA1 on (SA1.D_E_L_E_T_ <> '*' and SA1.A1_FILIAL = '" + xFilial("SA1") + "' and SA1.A1_COD = SE3.E3_CODCLI and SA1.A1_LOJA = SE3.E3_LOJA)"
cQry += " inner join " + RetSqlName("SA3") + " SA3 on (SA3.D_E_L_E_T_ <> '*' and SA3.A3_FILIAL = '" + xFilial("SA3") + "' and SA3.A3_COD = SE3.E3_VEND)"
cQry += " where SE3.D_E_L_E_T_ <> '*'"
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

// verifico o tipo 
If nTipo == 1
    cQry += " AND SE3.E3_PREFIXO IN ('SUP','GER') "
ElseIf nTipo == 2 // supervisor
    cQry += " AND SE3.E3_PREFIXO = 'SUP'"
ElseIf nTipo == 3 // gerente
	cQry += " AND SE3.E3_PREFIXO = 'GER'"
EndIf

// Ordem do Relatório:
If nOrdem == 1 //por Contrato
	cQry += " order by SE3.E3_FILIAL, SE3.E3_VEND, SE3.E3_XCONTRA"
ElseIf nOrdem == 2 //por Cliente + Loja
	cQry += " order by SE3.E3_FILIAL, SE3.E3_VEND, SE3.E3_CODCLI, SE3.E3_LOJA"
Else //por Nome Cliente
	cQry += " order by SE3.E3_FILIAL, SE3.E3_VEND, SA1.A1_NOME"
EndIf
		
cQry := Changequery(cQry)
	
TCQUERY cQry NEW ALIAS "QRYCOMI"
	
QRYCOMI->(dbEval({|| nCont++}))
QRYCOMI->(dbGoTop())

oReport:SetMeter(nCont)
	
nTotBase 	:= 0
nTotComis 	:= 0
nTotPorc	:= 0

// percorro os registros de comissao
While !oReport:Cancel() .And. QRYCOMI->(!EOF())
	
	oReport:IncMeter()

    // reinicio as variaveis
	cVend 		:= QRYCOMI->E3_VEND
	cNomeVend 	:= QRYCOMI->A3_NOME
	nAc1        := 0
    nAc2        := 0 
	nTotPerVen 	:= 0
			
	If oReport:Cancel()
		Exit
	EndIf    			

	oComissao:Init()
			
	// alimento o relatorio com os dados para impressao			
	oComissao:Cell("E3_VEND"):SetValue( Alltrim( cVend ) )
	oComissao:Cell("A3_NOME"):SetValue( Alltrim( cNomeVend ) )
	oComissao:Cell("E3_VENCTO"):SetValue( StoD(QRYCOMI->E3_VENCTO) )
	oComissao:Cell("E3_DATA"):SetValue( StoD(QRYCOMI->E3_DATA) )
	oComissao:Cell("E3_BASE"):SetValue( QRYCOMI->E3_BASE )
	oComissao:Cell("E3_PORC"):SetValue( QRYCOMI->E3_PORC )
	oComissao:Cell("E3_COMIS"):SetValue( QRYCOMI->E3_COMIS )

    // atualizo os valores	
	nBasePrt    :=	QRYCOMI->E3_BASE
	nComPrt     :=	QRYCOMI->E3_COMIS
	nAc1        += nBasePrt
	nAc2        += nComPrt
	nTotPerVen  += (nBasePrt*QRYCOMI->E3_PORC)/100
				
	nTotBase 	+= nAc1
	nTotComis 	+= nAc2
	nTotPorc	:= NoRound((nTotComis/nTotBase)*100,2)
	nTotPerVen  := NoRound((nTotPerVen/nAc1)*100,2)
			
	oComissao:PrintLine()

	oComissao:SetTotalText("Total do Vendedor: " + cVend + " - " + cNomeVend)		
	oReport:SkipLine()
	
	If lSaltPg
	   oComissao:SetPageBreak(.T.)
	EndIf			

	oComissao:Finish()

	QRYCOMI->( DbSkip() ) 
		
EndDo
	
oTotal:Init()
oTotal:Cell("nTotBase"):SetValue(nTotBase)
oTotal:Cell("nTotPorc"):SetValue(nTotPorc)
oTotal:Cell("nTotComis"):SetValue(nTotComis)
	
oTotal:PrintLine()
oTotal:Finish()
	
oTotal:SetPageBreak(.T.)
	
If Select("QRYCOMI") > 0
	QRYCOMI->(dbCloseArea())
EndIf

Return( Nil )

/*/{Protheus.doc} AjustaSX1
// Cria a tela de perguntas do relatorio
@author Pablo Cavalcante
@since 17/03/2016
@version undefined

@type function
/*/
Static Function AjustaSX1( cPerg )

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

Default cPerg   := ""

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

U_xPutSX1( cPerg, "08","Tipo?      ","","","mv_ch8","C",1,0,0,"C","","","","",;
"mv_par08","1=Ambos","1=Ambos","1=Ambos","1","2=Supervisor","2=Supervisor","2=Supervisor","3=Gerente","3=Gerente","3=Gerente","","","","","","",;
{'Informe se saltará página por vendedor. ','',''},aHelpEng,aHelpSpa) 

U_xPutSX1( cPerg, "09","Salta Pag por Vendedor ?      ","","","mv_ch9","C",1,0,0,"C","","","","",;
"mv_par09","Sim","Sim","Sim","1","Nao","Nao","Nao",,,,"","","","","","",;
{'Informe se saltará página por vendedor. ','',''},aHelpEng,aHelpSpa) 

Return( Nil )