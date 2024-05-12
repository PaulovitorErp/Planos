#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE P_CODCLI   2 // CODIGO DO CLIENTE
#DEFINE P_END      3 // ENDERECO DO CLIENTE
#DEFINE P_NOME	   1 // NOME DO CLIENTE
#DEFINE P_TITULO   1 // Número do título
#DEFINE P_VALOR    5 // Valor do Titulo	
#DEFINE P_PREFIXO  7 // Prefixo do Titulo
#DEFINE P_TIPO     8 // Tipo do Titulo



/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Raphael Martins Garcia	                                 !
!                  ! E-Mail raphael.garcia@totvs.com.br                      !
+------------------+---------------------------------------------------------+
!Descricao         ! Impressao de Boleto Bancario Modelo 2, sendo 2 por      !
!                  ! pagina								                     !
+------------------+---------------------------------------------------------+
!Nome              ! RCPGR002	                                             !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 11/03/2016                                              !
+------------------+--------------------------------------------------------*/
User Function RCPGR002(aTitulos,lGeraCar,lView,oPrinter,dRefIni,dRefFim,nQuebra,lEnvMail)

Local aEnvMail		:= {}

Private oBrush	    := TBrush():New(,CLR_BLACK)


Default lGeraCar    := .F.
Default lView	    := .T.
Default	dRefIni		:= CTOD("")
Default dRefFim		:= CTOD("")

 
 If ValType(oPrinter) == 'U'
	
	Private oPrinter   :=	TmsPrinter():New("") 
	
	oPrinter:Setup()
	oPrinter:setPaperSize(DMPAPER_A4)
	oPrinter:SetPortrait()
 	
	
 EndIf
  
  aEnvMail := PrintPage(aTitulos,lGeraCar,oPrinter,dRefIni,dRefFim,nQuebra,lEnvMail)
  
  If Len(aEnvMail) > 0  
	MsAguarde( {|| U_RCPGA24C(aEnvMail,oPrinter)}, "Aguarde", "Enviando e-mail dos boletos selecionados!...", .F. ) 
  EndIf

  If lView
  	oPrinter:Preview()
  EndIf
   	
Return(oPrinter)
/*
aTitulos[nX][1] = Dados do Banco
aTitulos[nX][2] = Dados do Sacado
aTitulos[nX][3] = Dados do Codigo de Barra e Linha Digitavel
aTitulos[nX][4] = Dados da Empresa
aTitulos[nX][5] = Nosso Numero
aTitulos[nX][6] = Dados do Titulo a ser impresso
aTitulos[nX][7] = Sequecial do Carne a ser gerado
*/
Static Function PrintPage(aTitulos,lGeraCar,oPrinter,dRefIni,dRefFim,nQuebra,lEnvMail)

Local nLinRec     := 0         //Linha de Impressao da parte de Recibo do Boleto
Local nLinImpBol  := 0         //Linha de Impressao da parte do Boleto
Local nLinCodBar  := 011.2     //Linha de Impressao do Codigo de Barras  
Local nLocalImp	  := 1         //Variavel de Controle do Local de Impressao, sendo: 1 = Imprime na Parte Superior, 2 = Imprime na Parte Inferior da Pagina
Local nX		  := 0 
Local nCarne	  := 0
Local aDadosBanco := {}
Local aDatSacado  := {}
Local aCB_RN_NN   := {}
Local aDadosEmp   := {}
Local aDadosTit   := {}  
Local aCabec	  := {}
Local aItens	  := {}
Local aPgHtml	  := {}
Local cNossoNum   := ""
Local nPagIni     := 1
Local nPagFim	  := 1 
		
	oPrinter:StartPage()
	
	For nX := 1 To Len(aTitulos)
		
		nCarne := aTitulos[nX][2]
		
		nLinRec    := 0 
		nLinImpBol := 0  
		nLinCodBar := 011.2
		
		If nLocalImp == 2 
			nLinRec    := 1600 
			nLinImpBol := 1680 
			nLinCodBar := 025.4
		ElseIf nLocalImp == 3 
			oPrinter:EndPage()
			oPrinter:StartPage()
			nLocalImp := 1
			nPagFim++
		EndIf
		
		
		aDadosBanco := aClone(aTitulos[nX][1][1][1])
		aDatSacado  := aClone(aTitulos[nX][1][1][2])
		aCB_RN_NN	:= aClone(aTitulos[nX][1][1][3]) 
		aDadosEmp	:= aClone(aTitulos[nX][1][1][4]) 
		cNossoNum   := aTitulos[nX][1][1][5]
		aDadosTit	:= aClone(aTitulos[nX][1][1][6])
		
		ImpRecibo(nLinRec,aDadosBanco,aDatSacado,aCB_RN_NN,aDadosEmp,cNossoNum,aDadosTit,oPrinter)
		ImpBol(nLinImpBol,nLinCodBar,aDadosBanco,aDatSacado,aCB_RN_NN,aDadosEmp,cNossoNum,aDadosTit,oPrinter)
		nLocalImp++
		
		//Imprimo protocolo do carne
		If lGeraCar .And. ( nX + 1 > Len(aTitulos) .Or. nCarne <> aTitulos[nX+1][2] )
			
			If !Empty(dRefIni) 
				aTitulos[nX][3] := dRefIni   
				aTitulos[nX][4] := dRefFim
			EndIf
			
			If nLocalImp == 2
				U_RCPGR003(1600,oPrinter,aDatSacado,aTitulos[nX][3],aTitulos[nX][4])
				nLocalImp := 3
			Else
				oPrinter:EndPage()
				oPrinter:StartPage()
				U_RCPGR003(0,oPrinter,aDatSacado,aTitulos[nX][3],aTitulos[nX][4])
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
		
	Next nX
	If lEnvMail
		aAdd( aPgHtml,{aDatSacado[2] , nPagIni , nPagFim })
	EndIf

Return(Aclone(aPgHtml))
/*
																										Recibo do Sacado
___________________________________________________________________________________________________________________________
|Cedente																					    |Vencimento      		   |
| CPG EMPREENDIMENTOS S/A - COMPLEXO VALE DO CERRADO											|20/07/2016         	   |	
|_______________________________________________________________________________________________|__________________________|
|Sacado											|N Documento	  Nosso Numero                  | (=) Valor do Documento   |
| ADEVALDO AMERICO DA SILVA						|    07/10 	  175/90304640-8					|	 47,26		           |
|_______________________________________________|_______________________________________________|__________________________|
| Instrucoes					    	           							                                               |
|								    	           							                                               |
|__________________________________________________________________________________________________________________________|								    	           							
								    	           								 Autenticar no verso
								    	           						____________________________________________________
							 	                                       |													|

*/


Static Function ImpRecibo(nSaltRow,aDadosBanco,aDatSacado,aCB_RN_NN,aDadosEmp,cNossoNum,aDadosTit,oPrinter)

Local oArial10N	:=	TFont():New("Arial",,10,,.T.,,,,,.F.,.F.)
Local oArial7N	:=	TFont():New("Arial",,7,,.T.,,,,,.F.,.F.)
Local oArial8N	:=	TFont():New("Arial",,8,,.T.,,,,,.F.,.F.)    
Local oArial8	:=	TFont():New("Arial",,8,,.F.,,,,,.F.,.F.)
Local o6N       :=	TFont():New("",,6,,.T.,,,,,.F.,.F.)


Default nSaltRow := 0 


 //TMSPrinter(): Box ( [ nRow], [ nCol], [ nBottom], [ nRight], [ uParam5] ) -->
 //TMSPrinter(): Line ( [ nTop], [ nLeft], [ nBottom], [ nRight], [ uParam5] ) -->
 //TMSPrinter(): FillRect ({ [ nTop], [ nLeft], [ nBottom], [ nRight]}, [ Objeto] ) -->
 

  oPrinter:Say(nSaltRow+0051,1960,"Recibo do Pagador",oArial10N,,0)

  oPrinter:Box(nSaltRow+0093,0123,nSaltRow+0168,2286)
  /*******************************************************/
  oPrinter:Say(nSaltRow+0095,0133,"Beneficiário:",oArial7N,,0)

  oPrinter:Say(nSaltRow+0095,0350,Alltrim(aDadosEmp[1]),oArial8,,0)
  
  oPrinter:Say(nSaltRow+0131,0133,"Endereço Beneficiário/Pagador/Avalista:",oArial7N,,0)
  oPrinter:Say(nSaltRow+0131,790,Alltrim(aDadosEmp[3])+","+Alltrim(aDadosEmp[4]),oArial8,,0)
 
  /*******************************************************/
  oPrinter:Box(nSaltRow+0095,1799,nSaltRow+0166,1801)
  oPrinter:Say(nSaltRow+0100,1813,"Vencimento",oArial7N,,0)
  oPrinter:Say(nSaltRow+0128,1820,DTOC(aDadosTit[4]),oArial8N,,0)
  /*******************************************************/
  
  oPrinter:Box(nSaltRow+0171,0123,nSaltRow+0246,2286)
  oPrinter:Say(nSaltRow+0173,0130,"Pagador",oArial7N,,0)
  oPrinter:Say(nSaltRow+0208,0144,Alltrim(aDatSacado[1]),oArial8N,,0)

  /*******************************************************/
  oPrinter:Box(nSaltRow+0171,0814,nSaltRow+0246,0816)
  oPrinter:Say(nSaltRow+0175,0830,"N Documento",oArial7N,,0)
  oPrinter:Say(nSaltRow+0206,0919,Alltrim(aDadosTit[11]),oArial8N,,0)
  oPrinter:Say(nSaltRow+0175,1299,"Nosso Numero",oArial7N,,0)
  oPrinter:Say(nSaltRow+0204,1292,aCB_RN_NN[3],oArial8N,,0)
  /******************************************************/ 
  oPrinter:Box(nSaltRow+0168,1799,nSaltRow+0246,1801)
  oPrinter:Say(nSaltRow+0177,1820,"(=) Valor do Documento",oArial7N,,0)
  oPrinter:Say(nSaltRow+0206,1999,Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99")),oArial8N,,0)
  /******************************************************/
  
  /*
  	 Autenticar no verso
     ____________________________________________________
	|													|
  */
  
  oPrinter:FillRect({nSaltRow+0274,1264,nSaltRow+0276,2286},oBrush)

  oPrinter:FillRect({nSaltRow+0276,1264,nSaltRow+0318,1267},oBrush)

  oPrinter:FillRect({nSaltRow+0274,2289,nSaltRow+0318,2291},oBrush)

  oPrinter:Say(nSaltRow+0256,1726,"Autenticar no verso",o6N,,0)

  oPrinter:FillRect({nSaltRow+0340,0123,nSaltRow+0342,2289},oBrush)

  oPrinter:Say(nSaltRow+0320,0123,"Pagador/Avalista",o6N,,0)

Return
/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Raphael Martins Garcia	                                 !
!                  ! E-Mail raphael.garcia@totvs.com.br                      !
+------------------+---------------------------------------------------------+
!Descricao         ! Impressao de Boleto Bancario Modelo 2, sendo 2 por      !
!                  ! pagina								                     !
+------------------+---------------------------------------------------------+
!Nome              ! ImpBol	                                             !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 11/03/2016                                              !
+------------------+--------------------------------------------------------*/
Static Function ImpBol(nSaltRow,nRowBar,aDadosBanco,aDatSacado,aCB_RN_NN,aDadosEmp,cNossoNum,aDadosTit,oPrinter)

Local cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
Local cLogoBco	 :=	aDadosBanco[12]

Local oArial11N	 :=	TFont():New("Arial",,10,,.T.,,,,,.F.,.F.)
Local oArial15   :=	TFont():New("Arial",,15,,.F.,,,,,.F.,.F.)
Local oArial6N 	 :=	TFont():New("Arial",,6,,.T.,,,,,.F.,.F.)
Local oArial9	 :=	TFont():New("Arial",,9,,.F.,,,,,.F.,.F.)
Local oArial9N	 :=	TFont():New("Arial",,9,,.T.,,,,,.F.,.F.)
Local oArial15N	 :=	TFont():New("Arial",,15,,.T.,,,,,.F.,.F.)
Local oArial5	 :=	TFont():New("Arial",,5,,.F.,,,,,.F.,.F.)
Local oFont7     :=	TFont():New("",,7,,.F.,,,,,.F.,.F.)
Local oFont5 	 :=	TFont():New("",,5,,.F.,,,,,.F.,.F.)
Local oBrush	 := TBrush():New(,CLR_BLACK)
Local nTxPerm	 := AllTrim(Transform(SuperGetMV("MV_TXPER",,0),"@R 99.999%"))  
Local nMulta	 := AllTrim(Transform(SuperGetMV("MV_LJMULTA",,0),"@R 99.99%"))


Default nSaltRow := 0 
Default nRowBar  := 0 

/********************************************
*LINHA VERTIFICAL DA PRIMEIRA COLUNA DO BOLETO
********************************************/
/*Aqui*/oPrinter:FillRect({0479+nSaltRow,113,1302+nSaltRow,115},oBrush) 


 //**************************************************************************************************************  
 //LOGO(1) BANCO ITAU S.A. |341-7|34191.75900 28392.396587 00989.260005 9 67800000002492
 //**************************************************************************************************************
oPrinter:SayBitMap(0400+nSaltRow,0133,cStartPath+"/"+cLogoBco,0070,0071) //LOGO1
oPrinter:FillRect( {0479+nSaltRow, 0113, 481+nSaltRow, 0490}, oBrush ) //____________________
oPrinter:Say(0415+nSaltRow,0220,Alltrim(aDadosBanco[2]),oArial11N,,0) //BANCO ITAU (1)
 
/*|341-7|*/
oPrinter:FillRect( {0479+nSaltRow, 0490, 413+nSaltRow, 0492}, oBrush ) //|
oPrinter:Say(0420+nSaltRow,0497,Alltrim(aDadosBanco[1])+'-'+Alltrim(aDadosBanco[7]),oArial15,,0) //341-7
oPrinter:FillRect( {0479+nSaltRow, 0490, 0481+nSaltRow, 2290}, oBrush )//______________________________________________________________________________________
oPrinter:FillRect( {0479+nSaltRow, 0640, 413+nSaltRow, 0642}, oBrush )//|
oPrinter:Say(0400+nSaltRow,0680,aCB_RN_NN[2],oArial15N,,0) //34191.75900 28392.396587 00989.260005 9 67800000002492

//*************************************************************************************************************************************************************
// Local de Pagamento																			| Vencimento   |	
//   ATE O VENCIMENTO, PREFERENCIALMENTE NO ITAU, APOS O VENCIMENTO SOMENTE NO ITAU             |  20/07/2016  |
//______________________________________________________________________________________________|______________|

oPrinter:Say(0485+nSaltRow,0133,"Local de Pagamento",oArial6N,,0) //Local de Pagamento
oPrinter:Say(0520+nSaltRow,0140,Alltrim(aDadosBanco[8])+Alltrim(aDadosBanco[9]),oArial9,,0)

oPrinter:Say(0485+nSaltRow,1855,"Vencimento",oArial6N,,0) //Vencimento
oPrinter:Say(520+nSaltRow,1845,DTOC(aDadosTit[4]),oArial9,,0) //30/05/2016
  
oPrinter:FillRect( {0553+nSaltRow, 0133, 0555+nSaltRow, 2290}, oBrush )

//********************************************************************************************************************************
// Cedente                                                                                | Agencia / Codigo do Cedente
//  CPG EMPREENDIMENTOS S/A - COMPLEXO VALE DO CERRADO                                    |   6580 / 02448-4
//________________________________________________________________________________________|______________________________
//********************************************************************************************************************************
oPrinter:Say(0560+nSaltRow,0133,"Beneficiário",oArial6N,,0) //Beneficiario

oPrinter:Say(0595+nSaltRow,0137,Alltrim(aDadosEmp[1]),oArial9,,0) //FUNERARIA VALE DO CERRADO LTDA.

//oPrinter:Say(0560+nSaltRow,0500,"CPF/CNPJ",oArial6N,,0) //Beneficiario

oPrinter:Say(0595+nSaltRow,0700,Alltrim(aDadosEmp[6]),oArial9,,0) //FUNERARIA VALE DO CERRADO LTDA.
  
oPrinter:Say(0560+nSaltRow,1855,"Agencia/Codigo do Beneficiário",oArial6N,,0) //Vencimento
oPrinter:Say(0595+nSaltRow,1845,Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]),oArial9,,0) //30/05/2016

oPrinter:FillRect( {628+nSaltRow, 0133, 0630+nSaltRow, 2290}, oBrush )

//********************************************************************************************************************************
// Data Documento | N Documento | Especie Doc       | Aceite | Data do Processamento        |                              |                                                               | Agencia / Codigo do Cedente
//  03/03/2016    |  04/16      |   CT              |  N     |  03/03/2016                  |                              |
//********************************************************************************************************************************
oPrinter:Say(637+nSaltRow,0133,"Data do Documento",oArial6N,,0) //Data Doc.
oPrinter:Say(672+nSaltRow,0136,DTOC(aDadosTit[2]),oArial9,,0) //03/03
oPrinter:FillRect({628+nSaltRow,0350,701+nSaltRow,0352},oBrush) //|

oPrinter:Say(637+nSaltRow,0360,"Nº Documento",oArial6N,,0) 
oPrinter:Say(670+nSaltRow,0400,Alltrim(aDadosTit[11]),oArial9,,0) 
oPrinter:FillRect({628+nSaltRow,0772,701+nSaltRow,0774},oBrush) //|
 	
oPrinter:Say(637+nSaltRow,0787,"Espécie Doc.",oArial6N,,0) 
oPrinter:Say(670+nSaltRow,0790,aDadosTit[8],oArial9,,0) 
oPrinter:FillRect({628+nSaltRow,0982,701+nSaltRow,0984},oBrush) //|

oPrinter:Say(637+nSaltRow,1014,"Aceite",oArial6N,,0)
oPrinter:Say(670+nSaltRow,1018,"N",oArial9,,0) 
oPrinter:FillRect({628+nSaltRow,1209,701+nSaltRow,1211},oBrush) //|

oPrinter:Say(637+nSaltRow,1212,"Data do Processamento",oArial6N,,0)
oPrinter:Say(670+nSaltRow,1215,DTOC(aDadosTit[3]),oArial9,,0) 

oPrinter:Say(637+nSaltRow,1855,"Nosso Numero",oArial6N,,0) 
oPrinter:Say(670+nSaltRow,1845,aCB_RN_NN[3],oArial9,,0) 

oPrinter:FillRect( {705+nSaltRow, 0133, 707+nSaltRow, 2290}, oBrush )

//********************************************************************************************************************************
// Uso Banco     | Carteira | Espécie Moeda   | Quantidade             | Valor             |  (=) Valor do Documento             |                                                               | Agencia / Codigo do Cedente
//               |  175     |   R$            |                        |                   |                                     |
//********************************************************************************************************************************
oPrinter:Say(716+nSaltRow,0133,"Uso Banco",oArial6N,,0) 
oPrinter:FillRect({705+nSaltRow,600,778+nSaltRow,0602},oBrush)

oPrinter:Say(716+nSaltRow,0606,"Espécie Moeda",oArial6N,,0) 
oPrinter:Say(747+nSaltRow,0640,"R$",oArial9,,0) 
oPrinter:FillRect({705+nSaltRow,1000,778+nSaltRow,1002},oBrush)

oPrinter:Say(716+nSaltRow,1011,"Carteira",oArial6N,,0) 
oPrinter:Say(747+nSaltRow,1017,aDadosBanco[6],oArial9,,0) 
oPrinter:FillRect({705+nSaltRow,1100,778+nSaltRow,1102},oBrush)

oPrinter:Say(716+nSaltRow,1110,"Quantidade",oArial6N,,0) 
oPrinter:FillRect({705+nSaltRow,1320,778+nSaltRow,1320},oBrush)

oPrinter:Say(716+nSaltRow,1330,"Valor",oArial6N,,0) 

oPrinter:Say(716+nSaltRow,1855,"(=) Valor do Documento",oArial6N,,0) 
oPrinter:Say(747+nSaltRow,1845,Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99")),oArial9,,0) 

oPrinter:FillRect( {779+nSaltRow, 0133, 781+nSaltRow, 2290}, oBrush )

//********************************************************************************************************************************
//| (-) Desconto/Abatimento |
//|_________________________|
//| (-) Outras Deduções     |
//|_________________________|
//| (+) Mora / Multa        |
//|_________________________|
//| (+) Outros Acrescimos   |
//|_________________________|
//| (=) Valor Cobrado       |
//|_________________________|

oPrinter:Say(790+nSaltRow,1855,"(-) Desconto/Abatimento",oArial6N,,0) 
If aDadosTit[9] > 0 
	oPrinter:Say(819+nSaltRow,1845,PadL( Alltrim(Transform(aDadosTit[9],"@E 999,999,999.99")),14),oArial9,,0) 
EndIf
oPrinter:FillRect( {853+nSaltRow, 1830, 855+nSaltRow, 2290}, oBrush )

oPrinter:Say(864+nSaltRow,1855,"(-) Outras Deduções",oArial6N,,0) 
oPrinter:Say(893+nSaltRow,1845," ",oArial9,,0) 
oPrinter:FillRect( {927+nSaltRow, 1830, 929+nSaltRow, 2290}, oBrush )

oPrinter:Say(938+nSaltRow,1855,"(+) Mora/Multa",oArial6N,,0) 
oPrinter:Say(967+nSaltRow,1845," ",oArial9,,0) 
oPrinter:FillRect( {1001+nSaltRow, 1830, 1003+nSaltRow, 2290}, oBrush )

oPrinter:Say(1012+nSaltRow,1855,"(+) Outros Acréscimos",oArial6N,,0) 
oPrinter:Say(1043+nSaltRow,1845," ",oArial9,,0) 
oPrinter:FillRect( {1075+nSaltRow, 1830, 1077+nSaltRow, 2290}, oBrush )

oPrinter:Say(1086+nSaltRow,1855,"(=) Valor Cobrado",oArial6N,,0) 
oPrinter:Say(1117+nSaltRow,1845," ",oArial9,,0) 
oPrinter:FillRect( {1149+nSaltRow, 113, 1151+nSaltRow, 2290}, oBrush )

//***************************************************************************************************
// Instruções 
// APOS O VENCIMENTO COBRAR 00,34% POR DIA DE ATRASO
// APOS O VENCIMENTO COBRAR MULTA DE 2%
// EM CASO DE DÚVIDAS ENTRE EM CONTATO CONOSCO 4006-0033 DEP. DE COBRANÇA
//***************************************************************************************************
oPrinter:Say(791+nSaltRow,0140,"Instrucoes - Instrucoes de Responsabilidade do Beneficiario",oArial6N,,0)
oPrinter:Say(826+nSaltRow,0140,"APOS VENCIMENTO COBRAR "+nTxPerm+" POR DIA DE ATRASO",oArial9,,0)
oPrinter:Say(867+nSaltRow,0140,"APOS VENCIMENTO COBRAR MULTA DE "+nMulta+" ",oArial9,,0)
oPrinter:Say(908+nSaltRow,0140,"EM CASO DE DÚVIDAS ENTRE EM CONTATO CONOSCO 4006-0033 DEP. DE COBRANÇA",oArial9,,0)



//*************************************************************************************************************************************
//________________________________________________________________________________
//|Sacado                                                                         |
//|                                                                               |
//|                   3C 002803     ADEVANIO AMERICO DA SILVA                     |
//|                   AV. SÃO DOMINGOS QD 07 LT 24                                |
//|                   74480-110       GOIANIA      VILA MULTIRAO                  |
//|_______________________________________________________________________________|

oPrinter:Say(1162+nSaltRow,0140,"Pagador",oArial6N,,0)

oPrinter:Say(1162+nSaltRow,0300,aDatSacado[10]+Space(10)+Alltrim(aDatSacado[1]),oArial9,,0)
oPrinter:Say(1198+nSaltRow,0300,Alltrim(aDatSacado[3]),oArial9,,0)
oPrinter:Say(1229+nSaltRow,0300,Alltrim(aDatSacado[6]),oArial9,,0)
oPrinter:Say(1229+nSaltRow,0600,Alltrim(aDatSacado[4]),oArial9,,0)
oPrinter:Say(1229+nSaltRow,0900,Alltrim(aDatSacado[9]),oArial9,,0)
oPrinter:FillRect( {1300+nSaltRow, 113, 1302+nSaltRow, 2290}, oBrush )


/********************************************
*LINHA VERTIFICAL DA PENULTIMA COLUNA DO BOLETO
********************************************/
oPrinter:FillRect({0479+nSaltRow,1830,1151+nSaltRow,1832},oBrush) //

/********************************************
*LINHA VERTIFICAL DA ULTIMA COLUNA DO BOLETO
********************************************/
oPrinter:FillRect({0479+nSaltRow,2290,1302+nSaltRow,2292},oBrush) 


MSBAR3("INT25"/*cTypeBar*/,nRowBar/*nRow*/,001/*nCol*/,aCB_RN_NN[1]/*cCode*/,oPrinter/*oPrint*/,.F./*lCheck*/,/*Color*/,.T./*lHorz*/,0.027/*nWidth*/,0.86/*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)

oPrinter:Say(1320+nSaltRow,1745,"Autenticação Mecânica - Ficha de Compensação",oArial6N,,0)
 
//oPrinter:Say(1320+nSaltRow,1845,"Ficha de Compensação",oArial9N,,0)
//oPrinter:Say(1350+nSaltRow,1845,"Autenticar no verso",oArial5,,0)

  
Return()




		
