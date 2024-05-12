#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#include "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"
#Include "Shell.ch"


/*/{Protheus.doc} RCPGR028
Impressao do carne proprio

@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 31/01/2019
@version 1.0
@Param  aTitulos 	- 
@Param 	lGeraCar    - 
@Param 	lView 		- 
@Param 	dRefIni  	- 
@Param 	dRefFim 	- 
@Param 	nQuebra    	- 
@Param 	lEnvMail   	- 
@Param 	nQtdBol		-
/*/

User Function RCPGR028(aTitulos,lGeraCar,lView,dRefIni,dRefFim,nQuebra,lEnvMail,nQtdBol)

Local oPrinter     :=	TmsPrinter():New("") 
Local aEnvMail	   := {}

Default lGeraCar   := .F.
Default lView      := .T. 
Default	dRefIni	   := CTOD("")
Default dRefFim	   := CTOD("")
Default lEnvMail   := .F.
Default nQtdBol	   := 3

oPrinter:Setup()
oPrinter:setPaperSize(DMPAPER_A4)
oPrinter:SetPortrait()///Define a orientacao da impressao como retrato

aEnvMail := PrintPage(aTitulos,lGeraCar,oPrinter,,,nQuebra,lEnvMail,nQtdBol)

If Len(aEnvMail) > 0  
	MsAguarde( {|| U_RCPGA24C(aEnvMail,oPrinter)}, "Aguarde", "Enviando e-mail dos boletos selecionados!...", .F. ) 
EndIf

If lView
	oPrinter:Preview()
EndIf

/*
TMSPrinter(): SaveAsHTML ( < cFile>, [ aRange] ) --> lOk
*/
  		
Return(oPrinter)

/*/{Protheus.doc} PrintPage
Impresso do reltorio

@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 31/01/2019
@version 1.0
@Param  aTitulos 	- 
@Param 	lGeraCar    - 
@Param 	lView 		- 
@Param 	dRefIni  	- 
@Param 	dRefFim 	- 
@Param 	nQuebra    	- 
@Param 	lEnvMail   	- 
@Param 	nQtdBol		-
/*/

Static Function PrintPage(aTitulos,lGeraCar,oPrinter,dRefIni,dRefFim,nQuebra,lEnvMail,nQtdBol)
 
 Local aDadosBanco	:= {}
 Local aDatSacado	:= {}
 Local aCB_RN_NN	:= {}
 Local aDadosEmp	:= {}
 Local aDadosTit	:= {}
 Local aPgHtml      := {}
 Local cNossoNum	:= ""       
 Local nLinImpBol   := -1108     //Linha de Impressao da parte do Boleto
 Local nLinCodBar   := 007.5     //Linha de Impressao do Codigo de Barras  
 Local nLocalImp	:= 1         //Variavel de Controle do Local de Impressao, sendo: 1 = Imprime na Parte Superior, 2 = Imprime na Parte do Meio da Pagina,3 = Imprime na Parte Inferior da Pagina
 Local nX           := 0
 Local nCarne	    := 0  
 Local nPagIni      := 1
 Local nPagFim	    := 0
 Local nPagImp		:= 0 
 
 Default nQuebra    := 2  
 Default lEnvMail	:= .F.
 
 	For nX := 1 To Len(aTitulos)
 		
 		nCarne := aTitulos[nX][2]
 		
 		nLinImpBol := -1108   
		nLinCodBar := 007.5
		
		aDadosBanco := aClone(aTitulos[nX][1][1][1])
		aDatSacado  := aClone(aTitulos[nX][1][1][2])
		aCB_RN_NN	:= aClone(aTitulos[nX][1][1][3]) 
		aDadosEmp	:= aClone(aTitulos[nX][1][1][4]) 
		cNossoNum   := aTitulos[nX][1][1][5]
		aDadosTit	:= aClone(aTitulos[nX][1][1][6])
		 
		///////////////////////////////////////////////////////
		////////// IMPRESSAO COM 1 BOLETO POR PAGINA   /////////
		//////////////////////////////////////////////////////
		if nQtdBol == 1
		
			//inicio uma nova pagina
			oPrinter:StartPage()
			
			//realizo a impressao do boleto 
			ImpressBol(nLinImpBol,nLinCodBar,aDadosBanco,aDatSacado,aCB_RN_NN,aDadosEmp,cNossoNum,aDadosTit,oPrinter)
			
			//incremento o numero de paginas impressas
			nPagImp++
					
			//imprimo o rodape com o controle de paginas
			ImpRodape(oPrinter,nPagImp)
			
			//finalizo a pagina
			oPrinter:EndPage()
					
			//valido se sera impresso o protocolo
			If lGeraCar .And. ( nX + 1 > Len(aTitulos) .Or. nCarne <> aTitulos[nX+1][2] )
				
				//inicio uma nova pagina
				oPrinter:StartPage()
			
				//incremento o numero de paginas impressas
				nPagImp++
			
				//realizo a impressao do protocolo
				U_RCPGR003(0,oPrinter,aDatSacado,aTitulos[nX][3],aTitulos[nX][4],1,aDatSacado[10])
				
				//imprimo o rodape com o controle de paginas
				ImpRodape(oPrinter,nPagImp)
		
		
				//finalizo a pagina
				oPrinter:EndPage()
			
			endif
			
		///////////////////////////////////////////////////////
		////////// IMPRESSAO COM 3 BOLETOS POR PAGINA  ////////
		//////////////////////////////////////////////////////
		else
		
			If nLocalImp == 1   
				nPagFim++
				oPrinter:StartPage()
			ElseIf nLocalImp == 2 //Impressao no Meio da Pagina
				nLinImpBol := 0   
				nLinCodBar := 016.8
			ElseIf nLocalImp == 3 //Impressao na parte Inferior da Pagina
				nLinImpBol := 1108   
				nLinCodBar := 026.2
			ElseIf nLocalImp == 4 //Pular Pagina
		 	
				//incremento o numero de paginas impressas
				nPagImp++
					
				//imprimo o rodape com o controle de paginas
				ImpRodape(oPrinter,nPagImp)
		
				oPrinter:EndPage()
				oPrinter:StartPage()
				nPagFim++
				nLocalImp := 1 
			EndIf
		
			nLocalImp++
			ImpressBol(nLinImpBol,nLinCodBar,aDadosBanco,aDatSacado,aCB_RN_NN,aDadosEmp,cNossoNum,aDadosTit,oPrinter)
 		
			//Imprimo protocolo do carne
			If lGeraCar .And. ( nX + 1 > Len(aTitulos) .Or. nCarne <> aTitulos[nX+1][2] )
			
				If !Empty(dRefIni) 
					aTitulos[nX][3] := dRefIni   
					aTitulos[nX][4] := dRefFim
				EndIf
			
				If nLocalImp == 2 //meio da pagina
			
					U_RCPGR003(1158,oPrinter,aDatSacado,aTitulos[nX][3],aTitulos[nX][4],2,aDatSacado[10])
					nLocalImp := 3
			
				ElseIf nLocalImp == 3 //fim da pagina
				
					U_RCPGR003(2128,oPrinter,aDatSacado,aTitulos[nX][3],aTitulos[nX][4],3,aDatSacado[10])
				
					//incremento o numero de paginas impressas
					nPagImp++
					
					//imprimo o rodape com o controle de paginas
					ImpRodape(oPrinter,nPagImp)
				
					oPrinter:EndPage()
				
					nLocalImp := 1  
				
				Else	
				
					//incremento o numero de paginas impressas
					nPagImp++
					
					//imprimo o rodape com o controle de paginas
					ImpRodape(oPrinter,nPagImp)
				
					oPrinter:EndPage()
					oPrinter:StartPage()
					U_RCPGR003(0,oPrinter,aDatSacado,aTitulos[nX][3],aTitulos[nX][4],1,aDatSacado[10])
					nLocalImp := 2 
			
				EndIf
				
			EndIf
		
			//Pula Pagina ao trocar de cliente, caso esteja definido para envio de boleto por e-mail, ou no parametro 
			//esteja marcado para quebra de pagina por cliente.
			If nLocalImp <> 1 .And.  Len(aTitulos) >= nX + 1 .And. nQuebra == 1 .And. aDatSacado[2] <> aTitulos[nX+1][1][1][2][2]
				
				oPrinter:EndPage()
				nLocalImp := 1
			
				If lEnvMail
				
					aAdd( aPgHtml,{aDatSacado[2] , nPagIni , nPagFim })
				
					nPagIni := nPagFim + 1
			
				EndIf
			
			EndIf
		
 		endif
 		
 	Next nX
 	
 	//impressao de 3 boletos por pagina, deve ser impresso o rodape no final 
 	if nQtdBol == 3
 	
 		//incremento o numero de paginas impressas
 		nPagImp++
					
 		//imprimo o rodape com o controle de paginas
 		ImpRodape(oPrinter,nPagImp)
	
	endif
				
	If lEnvMail
		aAdd( aPgHtml,{aDatSacado[2] , nPagIni , nPagFim })
	EndIf
			
Return( AClone(aPgHtml) )
/*
LOGO BANCO ITAU S.A. LOGO BANCO ITAU S.A |341-7|34191.75900 28392.396587 00989.260005 9 67800000002492
____________________ ___________________________________________________________|______________________
N Documento          Local de Pagamento						                    |Vencimento 		
										                                        |
____________________ ___________________________________________________________|______________________
Vencimento           Beneficiario						                        |Agencia/Cod Benefeciario
									                                            |
____________________ ___________________________________________________________|______________________
Nosso Numero         Data Doc.| N Doc | Esp Doc | Aceite | Data Processamento   |Nosso Numero
____________________ _________|_______|_________|________|______________________|______________________
Agencia/Cod Cedente  Uso Banco| Carteira| Especie Moeda| Quantidade | Valor     | (=) Valor Documento
____________________ _________|_________|______________|____________|___________|______________________
(-) Desconto/Abat    Instrucoes - Instrucoes                                    |(-) Desconto/Abat 
____________________                                                            |______________________
(-) Outras Deducoes                                                             |(-) Outras Deducoes 
____________________                                                            |______________________
(-) Mora/Multa                                                                  |(-) Mora/Multa 
____________________                                                            |______________________
(+) Outros Acresc                                                               |(-) Outros Acresc 
____________________                                                            |______________________
(=) Valr Cobrado                                                                |(=) Valr Cobrado 
____________________ ___________________________________________________________|______________________
Pagador               Pagador
  08025432            Maria Helena Mamede Cecilio 
MARIA HELENA MAMEDE   RUA VC 16 QD 24 LT 14
____________________  CNJ VERA CRUZ I 
Beneficiario                      
NOME DO BENEFICIARIO  Sacador/Avalista
99.999.999/9999-99   _______________________________________________________________Codigo de Baixa____
ENDERECO DO CLIENTE  |||||||||||||||||||||||||||||||||||||||||||||||||||||         Ficha de Compensacao
*/
Static Function ImpressBol(nSaltRow,nRowBar,aDadosBanco,aDatSacado,aCB_RN_NN,aDadosEmp,cNossoNum,aDadosTit,oPrinter)

Local cStartPath	:= GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
Local cCpfCnpj		:= ""
Local cLogoBco		:=	aDadosBanco[12]
Local oArial10N		:=	TFont():New("Arial",,10,,.T.,,,,,.F.,.F.)
Local oArial10		:=	TFont():New("Arial",,10,,.F.,,,,,.F.,.F.)
Local oArial15  	:=	TFont():New("Arial",,15,,.F.,,,,,.F.,.F.)
Local oArial6N 		:=	TFont():New("Arial",,6,,.T.,,,,,.F.,.F.)    
Local oArial6 		:=	TFont():New("Arial",,6,,.F.,,,,,.F.,.F.)       
Local oArial7 		:=	TFont():New("Arial",,7,,.F.,,,,,.F.,.F.)
Local oArial8		:=	TFont():New("Arial",,8,,.F.,,,,,.F.,.F.)
Local oArial9N		:=	TFont():New("Arial",,9,,.T.,,,,,.F.,.F.)
Local oFont7    	:=	TFont():New("",,7,,.F.,,,,,.F.,.F.)
Local oFont7N   	:=	TFont():New("",,7,,.T.,,,,,.F.,.F.)
Local oFont5 		:=	TFont():New("",,5,,.F.,,,,,.F.,.F.)
Local oArial5N		:=	TFont():New("Arial Narrow",,5,,.T.,,,,,.F.,.F.)
Local oBrush		:= 	TBrush():New(,CLR_BLACK)  
Local nTxPerm		:= 	AllTrim(Transform(SuperGetMV("MV_TXPER",,0),"@R 99.999%"))  
Local nMulta		:= 	AllTrim(Transform(SuperGetMV("MV_LJMULTA",,0),"@R 99.99%"))
Local nMoraDia		:= 	0
Local nVlrMulta		:=  0
Local lMulJurPer	:= 	SuperGetMV("MV_XMJPER",,.T.)		  	// Define se o Juros e multa serao impressão em valores reais no boleto
Local lCodEmp		:= 	SuperGetMV("MV_XCODEMP",,.F.)		  	// Define se no codigo beneficario utiliza cod da empresa EE_CODEMP	

Local cReferencia	:= ""
Local cValDoc		:= ""
Local cObservacoes	:= ""

Local cWebSite		:= SuperGetMV("ES_WEBSITE",,"")				// website da empresa
Local cNomeEmp		:= SuperGetMV("ES_EMPBOLP",,"")				// nome da empresa para o boleto 
Local cLocPag		:= ""										// Local de pagamento
Local cPagador		:= ""										// Pagador
Local cNmBenef		:= ""										// Nome do Beneficiario
Local cCNPJBenef	:= ""										// CNPJ do Beneficiario
Local cEndBenef		:= ""										// Endereço Beneficiario
Local nLin			:= 0										// Quantidade de Linhas
Local nLinha		:= 0										// Linha de impressão
Local i 			:= 0										// Variavel contadora

// variaveis de linha
Local nRowL			:= 1150		// coluna da esquerda
Local nRowC			:= 1150		// coluna central
Local nRowR			:= 0		// coluna da direita
Local nRowEnd		:= 2015		// ultima linha do boleto
Local nRowAux		:= 0
Local nColVertM		:= 0
Local nRowPagad		:= 0

Default nSaltRow := 0 
Default nRowBar  := 0 

// referencia - mes/ano
cReferencia 	:= alltrim(MesExtenso(aDadosTit[4]))+"/"+Alltrim(cValToChar(Ano(aDadosTit[4])))    

// valor do documento 
cValDoc			:= Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))

// mascara do CNPJ/CPF
If Alltrim( aDatSacado[8] ) == 'J'
	cCpfCnpj := "CNPJ: "+Alltrim(Transform(Alltrim(aDatSacado[7]),"@R 99.999.999/9999-99"))
Else
	cCpfCnpj := "CPF: "+Alltrim(Transform(Alltrim(aDatSacado[7]),"@R 999.999.999-99"))
EndIf

//+----------------------------------------------------------------+
//|///////// FACO A IMPRESSAO DA COLUNA DA ESQUERDA ///////////////|
//+----------------------------------------------------------------+

oPrinter:SayBitMap(nRowL+nSaltRow,0060,cStartPath+if(Right(cStartPath, 1) <> "\", "\", "")+aDadosBanco[12],0070,0071) //LOGO1
oPrinter:Say(nRowL+nSaltRow,0134,cNomeEmp,oArial6N,,0) // conrato
nRowL+=29
oPrinter:Say(nRowL+nSaltRow,0134,Alltrim(aDadosEmp[6]),oArial6N,,0) // conrato
nRowL+=50
oPrinter:Say(nRowL+nSaltRow,0060,AllTrim(cWebSite),oArial6N,,0) // conrato
nRowL+=29
oPrinter:FillRect({nRowL+nSaltRow,0058,nRowL+2+nSaltRow,0410},oBrush) //____________________
nRowL+=3

oPrinter:Say(nRowL+nSaltRow,0060,"Contrato/Parcela",oArial6N,,0) // conrato
nRowL+=29
oPrinter:Say(nRowL+nSaltRow,0070,alltrim(aDatSacado[10]) + " / " + Alltrim(aDadosTit[10]),oArial8,,0)
nRowL+=29

// igualo os tres alinhamentos de linha
nRowR := nRowAux := nRowL

oPrinter:FillRect({nRowL+nSaltRow,0058,nRowL+2+nSaltRow,0410},oBrush) //____________________
nRowL+=3

//----------------------------------------------------------------------------------
oPrinter:Say(nRowL+nSaltRow,0060,"Vencimento",oArial6N,,0) // vencimento
nRowL+=29
oPrinter:Say(nRowL+nSaltRow,0070,DTOC(aDadosTit[4]),oArial8,,0) //175/90283924-7
nRowL+=29
nColVertM := nRowL
oPrinter:FillRect({nRowL+nSaltRow,0058,nRowL+2+nSaltRow,0410},oBrush)//____________________
oPrinter:FillRect({nRowL+nSaltRow,0445,nRowL+2+nSaltRow,2290},oBrush) //_________________________________________________________________
nRowL+=3

//----------------------------------------------------------------------------------

oPrinter:Say(nRowL+nSaltRow,0060,"Nosso Número",oArial6N,,0)
nRowL+=29
oPrinter:Say(nRowL+nSaltRow,0070,Alltrim(cNossoNum),oArial8,,0)
nRowL+=29
oPrinter:FillRect({nRowL+nSaltRow,0058,nRowL+2+nSaltRow,0410},oBrush)
nRowL+=3

//----------------------------------------------------------------------------------

oPrinter:Say(nRowL+nSaltRow,0060,"Referência",oArial6N,,0)
nRowL+=29
oPrinter:Say(nRowL+nSaltRow,0070,cReferencia,oArial8,,0)
nRowL+=29
oPrinter:FillRect({nRowL+nSaltRow,0058,nRowL+2+nSaltRow,0410},oBrush)
nRowL+=3

//----------------------------------------------------------------------------------

oPrinter:Say(nRowL+nSaltRow,0060,"Pagador",oArial6N,,0)
nRowL+=29

//----------------------------------------------------------------------------------

// pagador
cPagador := aDatSacado[10] + "-" + aDatSacado[1] + "-" + cCpfCnpj + "-" + aDatSacado[3] + "-" 
cPagador += aDatSacado[6] + "-" + aDatSacado[4] + "-" + aDatSacado[5] 

// vou contar quantas linhas serao impressas
nLin	:= 0
nLin 	:= mlcount(cPagador,20)   
  
// vou deixar imprimir apenas duas linhas

// percorro o resultado mlcount e utilizo o memoline para imprimir
For i := 1 to nLin
    oPrinter:Say(nRowL+nSaltRow,0063, memoline(cPagador,20,i),oArial8,,0)
	nRowL += 29
Next i

oPrinter:FillRect({nRowL+nSaltRow,0058,nRowL+2+nSaltRow,0410},oBrush)
nRowL+=3

//----------------------------------------------------------------------------------

oPrinter:Say(nRowL+nSaltRow,0060,"(=) Valor do Documento",oArial6N,,0)
nRowL+=29
oPrinter:Say(nRowL+nSaltRow,0070,cValDoc,oArial8,,0)
nRowL+=29
oPrinter:FillRect({nRowL+nSaltRow,0058,nRowL+2+nSaltRow,0410},oBrush)
nRowL+=3

//----------------------------------------------------------------------------------

oPrinter:Say(nRowL+nSaltRow,0060,"(-) Desconto/Abatimento",oArial6N,,0)
nRowL+=29
oPrinter:Say(nRowL+nSaltRow,2060,'',oArial8,,0)
nRowL+=29
oPrinter:FillRect({nRowL+nSaltRow,0058,nRowL+2+nSaltRow,0410},oBrush)  
nRowL+=3

//----------------------------------------------------------------------------------

oPrinter:Say(nRowL+nSaltRow,0060,"(+) Mora / Multa",oArial6N,,0)
nRowL+=29
oPrinter:Say(nRowL+nSaltRow,2060,'',oArial8,,0)
nRowL+=29
oPrinter:FillRect({nRowL+nSaltRow,0058,nRowL+2+nSaltRow,0410},oBrush)
nRowL+=3

//----------------------------------------------------------------------------------

oPrinter:Say(nRowL+nSaltRow,0060,"(+) Outros Acrescimos",oArial6N,,0)
nRowL+=29
oPrinter:Say(nRowL+nSaltRow,0298,'',oArial8,,0)
nRowL+=29
oPrinter:FillRect({nRowL+nSaltRow,0058,nRowL+2+nSaltRow,0410},oBrush)
nRowL+=3

//----------------------------------------------------------------------------------

oPrinter:Say(nRowL+nSaltRow,0060,"(=) Valor Cobrado",oArial6N,,0)
nRowL+=29
oPrinter:Say(nRowL+nSaltRow,2060,'',oArial8,,0)
nRowL+=29
oPrinter:FillRect({nRowL+nSaltRow,0058,nRowL+2+nSaltRow,0410},oBrush)

//+----------------------------------------------------------------+
//|///////// FACO A IMPRESSAO DA COLUNA DA DIREITA  ///////////////|
//+----------------------------------------------------------------+
// impressao da referencia - coluna da esquerda

oPrinter:Say(nRowR+nSaltRow,1838,"Vencimento",oArial6N,,0) // vencimento
nRowR+=29
oPrinter:Say(nRowR+nSaltRow,1841,DTOC(aDadosTit[4]),oArial8,,0) //175/90283924-7
nRowR+=32

//--------------------------------------------------------------------------------    

oPrinter:Say(nRowR+nSaltRow,1839,"(=) Valor do Documento",oArial6N,,0)
nRowR+=29
oPrinter:Say(nRowR+nSaltRow,2060,cValDoc,oArial8,,0)    
nRowR+=29
oPrinter:FillRect({nRowR+nSaltRow,1830,nRowR+2+nSaltRow,2290},oBrush)
nRowR+=3

//--------------------------------------------------------------------------------    

oPrinter:Say(nRowR+nSaltRow,1839,"(-) Desconto/Abatimento",oArial6N,,0)
nRowR+=29
oPrinter:Say(nRowR+nSaltRow,2060,'',oArial8,,0)
nRowR+=29
oPrinter:FillRect({nRowR+nSaltRow,1830,nRowR+2+nSaltRow,2290},oBrush)
nRowR+=3

//----------------------------------------------------------------------------------

oPrinter:Say(nRowR+nSaltRow,1839,"(+) Mora / Multa",oArial6N,,0)
nRowR+=29
oPrinter:Say(nRowR+nSaltRow,2060,'',oArial8,,0)
nRowR+=29
oPrinter:FillRect({nRowR+nSaltRow,1830,nRowR+2+nSaltRow,2290},oBrush)
nRowR+=3

//----------------------------------------------------------------------------------
  
oPrinter:Say(nRowR+nSaltRow,1839,"(+) Outros Acrescimos",oArial6N,,0)
nRowR+=29
oPrinter:Say(nRowR+nSaltRow,2060,'',oArial8,,0)
nRowR+=29
oPrinter:FillRect({nRowR+nSaltRow,1830,nRowR+2+nSaltRow,2290},oBrush)
nRowR+=3

//----------------------------------------------------------------------------------

oPrinter:Say(nRowR+nSaltRow,1839,"(=) Valor Cobrado",oArial6N,,0)
nRowR+=29
oPrinter:Say(nRowR+nSaltRow,2060,'',oArial8,,0)
nRowR+=29

// linha vertifical antes do pagador
nRowPagad := nRowR
oPrinter:FillRect({nRowR+nSaltRow,445,nRowR+2+nSaltRow,2290},oBrush)
nRowR+=3

/********************************************
*LINHA VERTIFICAL DA ULTIMA COLUNA DO BOLETO
********************************************/
oPrinter:FillRect({nRowAux+nSaltRow,1830,nRowPagad+nSaltRow,1832},oBrush) //

//+----------------------------------------------------------------+
//|/////// FACO A IMPRESSAO DO CORPO CETRAL DO BOLETO /////////////|
//+----------------------------------------------------------------+

oPrinter:SayBitMap(nRowC+nSaltRow,0455,cStartPath+if(Right(cStartPath, 1) <> "\", "\", "")+aDadosBanco[12],0250,0168) //LOGO1
oPrinter:Say(nRowC+nSaltRow,0770,cNomeEmp + " - " + Alltrim(aDadosEmp[6]),oArial10N,,0) // conrato
nRowC+=29
oPrinter:Say(nRowC+nSaltRow,0770,AllTrim(cWebSite),oArial10N,,0) // conrato
nRowC+=91

nRowC := nRowAux
oPrinter:FillRect({nRowC+nSaltRow,0445,nRowC+2+nSaltRow,2290},oBrush) //_________________________________________________________________
nRowC += 3

//----------------------------------------------------------------------------------

oPrinter:Say(nRowC+nSaltRow,0455,"Cliente",oArial6N,,0) // contrato
oPrinter:Say(nRowC+20+nSaltRow,0469,alltrim(substr(aDatSacado[2],1,TamSX3("A1_COD")[1])),oArial8,,0) //03/03
oPrinter:FillRect({nRowC+nSaltRow,0676,nColVertM+nSaltRow,0678},oBrush)

oPrinter:Say(nRowC+nSaltRow,0690,"Nosso Número",oArial6N,,0) // nosso numero
oPrinter:Say(nRowC+20+nSaltRow,0770,Alltrim(cNossoNum),oArial8,,0) //04/16
oPrinter:FillRect({nRowC+nSaltRow,0910,nColVertM+nSaltRow,0912},oBrush) //|

oPrinter:Say(nRowC+nSaltRow,0930,"Referencia",oArial6N,,0) // referencia
oPrinter:Say(nRowC+20+nSaltRow,1049,cReferencia,oArial8,,0) // CT 
oPrinter:FillRect({nRowC+nSaltRow,1400,nColVertM+nSaltRow,1402},oBrush) //|

oPrinter:Say(nRowC+nSaltRow,1440,"Espécie",oArial6N,,0) // especie
oPrinter:Say(nRowC+20+nSaltRow,1460,"R$",oArial8,,0) //N
oPrinter:FillRect({nRowC+nSaltRow,1546,nColVertM+nSaltRow,1548},oBrush) //|

oPrinter:Say(nRowC+nSaltRow,1576,"Data do Processamento",oArial6N,,0) // data processamento
oPrinter:Say(nRowC+20+nSaltRow,1586,DTOC(aDadosTit[3]),oArial8,,0) //03/03/2016
//oPrinter:FillRect({1428+nSaltRow,1369,1492+nSaltRow,1371},oBrush)
 
/****************************************************************************************************************************

(-) Desconto/Abat    Instrucoes - Instrucoes                                    |(-) Desconto/Abat 
____________________                                                            |______________________
(-) Outras Deducoes                                                             |(-) Outras Deducoes 
____________________                                                            |______________________
(-) Mora/Multa                                                                  |(-) Mora/Multa 
____________________                                                            |______________________
(+) Outros Acresc                                                               |(-) Outros Acresc 
____________________                                                            |______________________
(=) Valr Cobrado                                                                |(=) Valr Cobrado 
____________________ ___________________________________________________________|______________________

 
******************************************************************************************************************************/
nRowC := nColVertM + 3
oPrinter:Say(nRowC+nSaltRow,0450,"Observações",oArial5N,,0)
nRowC+=29

// vou imprimir as observacoes
cObservacoes := Upper(aDadosBanco[8])

// vou contar quantas linhas serao impressas
nLin	:= 0
nLin 	:= mlcount(cObservacoes,80)   
nLinha	:= 0

// percorro o resultado mlcount e utilizo o memoline para imprimir
For i := 1 to nLin
    oPrinter:Say(nRowC+nLinha+nSaltRow,0457, memoline(cObservacoes,80,i),oFont7N,,0)
	nLinha += 29
Next i

//imprime a mensagem de juros  
If SuperGetMV("MV_TXPER",,0) > 0 
		
	//verifico se os valores serao impressos em valores reais ou percentual
	if lMulJurPer
		oPrinter:Say(nRowC+nLinha+nSaltRow,0459,"APOS VENCIMENTO COBRAR "+nTxPerm+" POR DIA DE ATRASO",oFont7,,0)
		nLinha += 29
	else
			
		nMoraDia := Round(aDadosTit[5] * (SuperGetMV("MV_TXPER",,0) / 100),2)
			
		//se for inferior a 1 centavo, arrendondar para 1 centavo
		if nMoraDia < 0.01 
				
			nMoraDia := 0.01 
			
		endif
			
		oPrinter:Say(nRowC+nLinha+nSaltRow,0459,"APÓS O VENCIMENTO COBRAR JUROS DE R$ " + Alltrim(Transform(nMoraDia,"@E 99,999.99")) + " AO DIA",oFont7,,0)
		nLinha += 29
			
	endif
			
endif
	  
//imprime mensagem de multa 
if SuperGetMV("MV_LJMULTA",,0) > 0  
		
	//verifico se os valores serao impressos em valores reais ou percentual
	if lMulJurPer
		oPrinter:Say(nRowC+nLinha+nSaltRow,0459,"APOS VENCIMENTO COBRAR MULTA DE "+nMulta+" ",oFont7,,0)
		nLinha += 29
	else
			
		nVlrMulta := Round(aDadosTit[5] * (SuperGetMV("MV_LJMULTA",,0) / 100),2)
			
		//se for inferior a 1 centavo, arrendondar para 1 centavo
		if nVlrMulta < 0.01 
				
			nVlrMulta := 0.01 
			
		endif
		
		oPrinter:Say(nRowC+nLinha+nSaltRow,0459,"APOS VENCIMENTO COBRAR MULTA DE R$ "+Alltrim(Transform(nVlrMulta,"@E 99,999.99"))+" ",oFont7,,0)
		nLinha += 29
			
	endif
		
endif
     
/******************************************************************************************
Sacado               Pagador
  08025432            Maria Helena Mamede Cecilio 
MARIA HELENA MAMEDE   RUA VC 16 QD 24 LT 14
____________________  CNJ VERA CRUZ I 
                      
                      Sacador/Avalista
                     _______________________________________________________________Codigo de Baixa____
                     |||||||||||||||||||||||||||||||||||||||||||||||||||||         Ficha de Compensacao

******************************************************************************************/  
nRowC := nRowPagad + 5

oPrinter:Say(nRowC+nSaltRow,0455,"Pagador",oArial6N,,0)
nRowC+=25  
oPrinter:Say(nRowC+nSaltRow,0865,Alltrim(aDatSacado[1]),oArial8,,0)
nRowC+=25  
oPrinter:Say(nRowC+nSaltRow,0455,"Endereço",oArial6N,,0)
oPrinter:Say(nRowC+nSaltRow,0865,Alltrim(aDatSacado[3]),oArial8,,0)
nRowC+=25  
oPrinter:Say(nRowC+nSaltRow,0455,"Municipio/Estado",oArial6N,,0)
oPrinter:Say(nRowC+nSaltRow,0865,SubStr(Alltrim(aDatSacado[4]),1,14),oArial8,,0)
oPrinter:Say(nRowC+nSaltRow,1170,Alltrim(aDatSacado[9])+"  "+SubsTr(Alltrim(aDatSacado[6]),1,5)+"-"+Alltrim(SubsTr(aDatSacado[6],6,3)),oArial8,,0)
nRowC+=45
//----------------------------------------------------------------------------------  

oPrinter:Say(nRowC+nSaltRow,0455,"Pagador/Avalista",oArial6N,,0)
oPrinter:Say(nRowC+nSaltRow,0865,Alltrim(cCpfCnpj),oArial8,,0)
nRowC+=30
oPrinter:FillRect({nRowC+nSaltRow,0450,nRowC+2+nSaltRow,2290/*2050*/},oBrush)
nRowC+=29

// impressao do codigo de barras
oPrinter:Say(nRowC+nSaltRow,0455,"Autenticação Mecânica - Ficha de Compensação",oArial6,,0)
nRowC+=29
oPrinter:Say(nRowC+nSaltRow,0455,aCB_RN_NN[1],oArial6,,0) 

MSBAR3("INT25"/*cTypeBar*/,nRowBar/*nRow*/,004/*nCol*/,aCB_RN_NN[1]/*cCode*/,oPrinter/*oPrint*/,.F./*lCheck*/,/*Color*/,.T./*lHorz*/,0.027/*nWidth*/,0.86/*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)

oPrinter:Say((nRowEnd+nSaltRow)+105,0063,Replicate("- -",165),oFont5,,0)
  
Return()

///////////////////////////////////////////////////
////// IMPRESSAO DO RODAPE DA PAGINA 	  /////////
//////////////////////////////////////////////////
Static Function ImpRodape(oPrinter,nPagImp)

Local oFont8	 :=	TFont():New("Arial",,8,,.F.,,,,,.F.,.F.)    

oPrinter:Line(3320,0120,3320,2240) 
oPrinter:Say(3350,0110,"Página: " + StrZero(nPagImp,4) + " - TOTVS - Protheus",oFont8)

Return()



