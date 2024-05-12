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


/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Raphael Martins 			                             !
!                  ! E-Mail raphael.garcia@totvs.com.br                      !
+------------------+---------------------------------------------------------+
!Descricao         ! Rotina de Geracao de Boleto Itau e Santander            !
!                  ! Criação de relatórios gráficos.                         !
+------------------+---------------------------------------------------------+
!Nome              ! RCPGR001	                                             !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 03/03/2016                                              !
+------------------+--------------------------------------------------------*/

User Function RCPGR001(aTitulos,lGeraCar,lView,dRefIni,dRefFim,nQuebra,lEnvMail,nQtdBol)

Local oPrinter     :=	TmsPrinter():New("") 
Local aEnvMail	   := {}

Default lGeraCar   := .F.
Default lView      := .T. 
Default	dRefIni	   := CTOD("")
Default dRefFim	   := CTOD("")
Default nQuebra	   := 2  
Default lEnvMail   := .F.
Default nQtdBol	   := 3

	oPrinter:Setup()
	oPrinter:setPaperSize(DMPAPER_A4)
	oPrinter:SetPortrait()///Define a orientacao da impressao como retrato

	aEnvMail := PrintPage(aTitulos,lGeraCar,oPrinter,dRefIni,dRefFim,nQuebra,lEnvMail,nQtdBol)

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
/*---------------------------------------------------------------------------+
!                       FICHA TECNICA DO PROGRAMA                            !
+----------------------------------------------------------------------------+
!                          DADOS DO PROGRAMA                                 !
+------------------+---------------------------------------------------------+
!Autor             ! Raphael Martins 			                             !
!                  ! E-Mail raphael.garcia@totvs.com.br                      !
+------------------+---------------------------------------------------------+
!Descricao         ! Impressao de Boleto de Acordo com os Parametros         !
!                  ! Recebidos					                             !
+------------------+---------------------------------------------------------+
!Nome              ! ImpressBol	                                             !
+------------------+---------------------------------------------------------+
!Data de Criacao   ! 03/03/2016                                              !
+------------------+--------------------------------------------------------*/

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
			
				If !Empty(dRefIni) .and. !Empty(dRefFim)
					aTitulos[nX][3] := dRefIni   
					aTitulos[nX][4] := dRefFim
				EndIf
			
				If nLocalImp == 2 //meio da pagina
			
					U_RCPGR003(1200,oPrinter,aDatSacado,aTitulos[nX][3],aTitulos[nX][4],2,aDatSacado[10])
					nLocalImp := 3
			
				ElseIf nLocalImp == 3 //fim da pagina
				
					U_RCPGR003(2170,oPrinter,aDatSacado,aTitulos[nX][3],aTitulos[nX][4],3,aDatSacado[10])
				
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
			If nLocalImp <> 1 .And.  Len(aTitulos) >= nX + 1 .And. nQuebra == 1 .And. aDatSacado[2] + aDatSacado[10] <> aTitulos[nX+1][1][1][2][2] + aTitulos[nX+1][1][1][2][10]
				
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
	Local cLogoBco		:= aDadosBanco[12]
	Local oArial10N		:= TFont():New("Arial",,10,,.T.,,,,,.F.,.F.)
	Local oArial10		:= TFont():New("Arial",,10,,.F.,,,,,.F.,.F.)
	Local oArial15  	:= TFont():New("Arial",,15,,.F.,,,,,.F.,.F.)
	Local oArial6N 		:= TFont():New("Arial",,6,,.T.,,,,,.F.,.F.)
	Local oArial6 		:= TFont():New("Arial",,6,,.F.,,,,,.F.,.F.)
	Local oArial7 		:= TFont():New("Arial",,7,,.F.,,,,,.F.,.F.)
	Local oArial8		:= TFont():New("Arial",,8,,.F.,,,,,.F.,.F.)
	Local oArial9N		:= TFont():New("Arial",,9,,.T.,,,,,.F.,.F.)
	Local oFont7    	:= TFont():New("",,7,,.F.,,,,,.F.,.F.)
	Local oFont5 		:= TFont():New("",,5,,.F.,,,,,.F.,.F.)
	Local oArial5N		:= TFont():New("Arial Narrow",,5,,.T.,,,,,.F.,.F.)
	Local oBrush		:= TBrush():New(,CLR_BLACK)
	Local nTxPerm		:= AllTrim(Transform(SuperGetMV("MV_TXPER",,0),"@R 99.999%"))
	Local nMulta		:= AllTrim(Transform(SuperGetMV("MV_LJMULTA",,0),"@R 99.99%"))
	Local nMoraDia		:= 0
	Local nVlrMulta		:= 0
	Local lMulJurPer	:= SuperGetMV("MV_XMJPER",,.T.)		  			// Define se o Juros e multa serao impressão em valores reais no boleto
	Local lCodEmp		:= SuperGetMV("MV_XCODEMP",,.F.)		  		// Define se no codigo beneficario utiliza cod da empresa EE_CODEMP
	Local cBcoCodEmp	:= SuperGetMV("MV_XBCOEMP",,"756")				// Passo os codigo dos bancos que emprimem o codigo da empresa (EE_CODEMP)
	Local cMsgPad1		:= Alltrim(SuperGetMV("MV_XMSPAD1",,"")) 		// Mensagem de Instrucoes do boleto - Primeira Linha
	Local cMsgPad2	 	:= Alltrim(SuperGetMV("MV_XMSPAD2",,"")) 		// Mensagem de Instrucoes do boleto - Segunda Linha
	Local cMsgPad3	 	:= Alltrim(SuperGetMV("MV_XMSPAD3",,"")) 		// Mensagem de Instrucoes do boleto - Terceira Linha
	Local cTipoMnt		:= AllTrim(SuperGetMv("MV_XTIPOMN",.F.,"MNT"))  // tipo do titulo de manutencao
	Local cTipoPar		:= AllTrim(SuperGetMv("MV_XTIPOCT",.F.,"AT"))	// tipo do titulo parcela
	Local cLocPag		:= ""											// Local de pagamento
	Local cPagador		:= ""											// Pagador
	Local cNmBenef		:= ""											// Nome do Beneficiario
	Local cCNPJBenef	:= ""											// CNPJ do Beneficiario
	Local cEndBenef		:= ""											// Endereço Beneficiario
	Local cNosNumImp	:= ""											// Nosso Numero de Impressao
	Local nLin			:= 0											// Quantidade de Linhas
	Local nLinha		:= 0											// Linha de impressão
	Local i 			:= 0											// Variavel contadora
	Local lCemiterio 	:= SuperGetMV("MV_XCEMI",,.F.)					// verifico se e cemiterio

	Default nSaltRow := 0
	Default nRowBar  := 0

	If !Empty(aCB_RN_NN[3])
		If AllTrim(aDadosBanco[1]) $ "748" // para impressao do SICREDI
			cNosNumImp := SubStr(aCB_RN_NN[3],1,2) + "/" + SubStr(aCB_RN_NN[3],3,6) + "-" + SubStr(aCB_RN_NN[3],9,1)
		Else
			cNosNumImp := aCB_RN_NN[3]
		EndIf
	EndIf

	//TMSPrinter(): Box ( [ nRow], [ nCol], [ nBottom], [ nRight], [ uParam5] ) -->
	//TMSPrinter(): Line ( [ nTop], [ nLeft], [ nBottom], [ nRight], [ uParam5] ) -->
	//TMSPrinter(): FillRect ({ [ nTop], [ nLeft], [ nBottom], [ nRight]}, [ Objeto] ) -->

	//**************************************************************************************************************
	//LOGO(1) BANCO ITAU (1) LOGO(2) BANCO ITAU (2) |341-7|34191.75900 28392.396587 00989.260005 9 67800000002492
	//**************************************************************************************************************
	//____________________ ______________________________________________________________________________________
	if aDadosBanco[1] $ "001/756/748" // para o banco do brasil - sicoob
		oPrinter:SayBitMap(1175+nSaltRow,0063,cStartPath+if(Right(cStartPath, 1) <> "\", "\", "")+aDadosBanco[12],0229,0038) //LOGO1

	/*|341-7|*/
		oPrinter:FillRect( {1168+nSaltRow, 0300, 1234+nSaltRow, 0304}, oBrush ) //|

		oPrinter:Say(1184+nSaltRow,0310,Alltrim(aDadosBanco[1])+'-'+Alltrim(aDadosBanco[7]),oArial10,,0) //341-7
	else
		oPrinter:SayBitMap(1150+nSaltRow,0063,cStartPath+if(Right(cStartPath, 1) <> "\", "\", "")+aDadosBanco[12],0070,0071) //LOGO1
	endIf

	if aDadosBanco[1] $ "001/756/748" // para o banco do brasil - sicoob
		oPrinter:SayBitMap(1160+nSaltRow,0455,cStartPath+if(Right(cStartPath, 1) <> "\", "\", "")+aDadosBanco[12],0369,0062) //LOGO2
	else
		oPrinter:SayBitMap(1150+nSaltRow,0455,cStartPath+if(Right(cStartPath, 1) <> "\", "\", "")+aDadosBanco[12],0067,0073) //LOGO2
	endIf

	oPrinter:FillRect( {1232+nSaltRow, 0065, 1240+nSaltRow, 0410}, oBrush ) //____________________

	// quando for banco do brasil ou sicoob, só imprimi o nome do banco se a logo nao existir
	if aDadosBanco[1] $ "001/756/748"
		if !File(cStartPath+if(Right(cStartPath, 1) <> "\", "\", "")+aDadosBanco[12])
			oPrinter:Say(1188+nSaltRow,0172,Alltrim(aDadosBanco[2]),oArial10N,,0) //BANCO ITAU (1)

			oPrinter:Say(1188+nSaltRow,0571,Alltrim(aDadosBanco[2]),oArial10N,,0) //BANCO ITAU (2)
		endIf
	else
		oPrinter:Say(1188+nSaltRow,0172,Alltrim(aDadosBanco[2]),oArial10N,,0) //BANCO ITAU (1)

		oPrinter:Say(1188+nSaltRow,0571,Alltrim(aDadosBanco[2]),oArial10N,,0) //BANCO ITAU (2)

	endIf

	oPrinter:FillRect( {1232+nSaltRow, 0457, 1240+nSaltRow, 2290}, oBrush )//______________________________________________________________________________________

  /*|341-7|*/
	oPrinter:FillRect( {1168+nSaltRow, 0858, 1234+nSaltRow, 0864}, oBrush ) //|

	oPrinter:Say(1173+nSaltRow,0870,Alltrim(aDadosBanco[1])+'-'+Alltrim(aDadosBanco[7]),oArial15,,0) //341-7

	//oPrinter:FillRect( {0124, 0858, 0130, 1015}, oBrush )

	oPrinter:FillRect( {1168+nSaltRow, 1012, 1234+nSaltRow, 1018}, oBrush )//|

	oPrinter:Say(1173+nSaltRow,1031,aCB_RN_NN[2],oArial10N,,0) //34191.75900 28392.396587 00989.260005 9 67800000002492
	//------------------------------------------------------------------------------------------------------------------------------------------------------

  /*************************************************************************************************************
  N Documento          Local de Pagamento						                    |Vencimento 		
	04/16					ATE O VENCIMENTO, PREFERENCIALMENTE NO ITAU...          | 30/05/2016
  ____________________ _____________________________________________________________|______________________
  *************************************************************************************************************/
  
  oPrinter:Say(1236+nSaltRow,0063,"N Documento",oArial6N,,0) //N Documento
  
  oPrinter:Say(1263+nSaltRow,0180,Alltrim(aDadosTit[10]),oArial8,,0) //04/16
  
  oPrinter:FillRect({1305+nSaltRow,0063,1307+nSaltRow,0410},oBrush) //____________________
  
  oPrinter:Say(1236+nSaltRow,0462,"Local de Pagamento",oArial6N,,0) //Local de Pagamento	

  // pego as informacoes de local de pagamento
  cLocPag := Alltrim(aDadosBanco[8])+space(1)+Alltrim(aDadosBanco[9])
  
  // vou contar quantas linhas serao impressas
  nLin := mlcount(cLocPag,80)
  nLinha := 0   
  
  // vou deixar imprimir apenas duas linhas
	if nLin > 2
	nLin := 2
	endIf
   
  // percorro o resultado mlcount e utilizo o memoline para imprimir
	For i := 1 to nLin
    oPrinter:Say(1261+nLinha+nSaltRow,0513, memoline(cLocPag,80,i),oArial6N,,0) //ATE O VENCIMENTO, PREFERENCIALMENTE NO ITAU... 
	nLinha += 17
	Next i

  oPrinter:Say(1241+nSaltRow,1839,"Vencimento",oArial6N,,0) //Vencimento
  oPrinter:Say(1276+nSaltRow,1845,DTOC(aDadosTit[4]),oArial8,,0) //30/05/2016
  
  oPrinter:FillRect({1305+nSaltRow,0455,1307+nSaltRow,2290},oBrush) //___________________________________________________________________________________
  
  /******************************************************************************************************************
   Vencimento           Beneficiario						                        |Agencia/Cod Benefeciario
	30/05/2016			 FUNERARIA VALE DO CERRADO LTDA.					        | 6580/09892 - 6
   ____________________ ____________________________________________________________|______________________
 
  ********************************************************************************************************************/
  oPrinter:Say(1310+nSaltRow,0063,"Vencimento",oArial6N,,0) //Vencimento

  oPrinter:Say(1332+nSaltRow,0116,DTOC(aDadosTit[4]),oArial8,,0) //30/05/2016

  oPrinter:FillRect({1365+nSaltRow,0060,1367+nSaltRow,0408},oBrush) //____________________

  oPrinter:Say(1310+nSaltRow,0457,"Beneficiario",oArial6N,,0) //Beneficiario
  
  oPrinter:Say(1310+nSaltRow,0580,SubStr( Alltrim(aDadosEmp[1]),1,28),oArial8,,0) //FUNERARIA VALE DO CERRADO LTDA.
                                                                                                     
  oPrinter:Say(1310+nSaltRow,1150,Alltrim(aDadosEmp[6]),oArial8,,0) //CNPJ.
  
  oPrinter:Say(1335+nSaltRow,0457,"Endereço Beneficiário/Sacador/Avalista:",oArial6N,,0) //Endereço Benefeciário/Sacador/Avalista
  oPrinter:Say(1335+nSaltRow,890,Alltrim(aDadosEmp[3])+","+Alltrim(aDadosEmp[4]),oArial7,,0) //RUA ....
   
  oPrinter:Say(1312+nSaltRow,1841,"Agencia / Codigo do Beneficiario",oArial6N,,0) //Agencia/Cod Benefeciario
 
	//verifico se imprime codigo do beneficiario por EE_CODEMP
	if lCodEmp .And. aDadosBanco[1] $ cBcoCodEmp
  
		oPrinter:Say(1336+nSaltRow,1841,Alltrim(aDadosBanco[3])+"/"+Alltrim(aDadosBanco[11]),oArial8,,0) //6580/09892 - 6  		

	ElseIf aDadosBanco[1] == "748" // sicredi

		oPrinter:Say(1336+nSaltRow,1841,Alltrim(aDadosBanco[3])+"."+Alltrim(aDadosBanco[13])+"."+Alltrim(aDadosBanco[11]),oArial8,,0) //6580/09892 - 6  		
  
	else
  	
  		oPrinter:Say(1336+nSaltRow,1841,Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]),oArial8,,0) //6580/09892 - 6
  
	endif
  
  oPrinter:FillRect({1365+nSaltRow,0452,1367+nSaltRow,2290},oBrush) //__________________________________________________________________________________
  
  /******************************************************************************************************************
   Nosso Numero         Data Doc.| N Doc | Esp Doc | Aceite | Data Processamento   |Nosso Numero
   175/90283924-7       03/03    | 04/16 | CT      |  N     | 03/03/2016           | 175/90283924-7
   ____________________ _________|_______|_________|________|______________________|______________________
  *******************************************************************************************************************/
  oPrinter:Say(1374+nSaltRow,0060,"Nosso Numero",oArial6N,,0) //Nosso Numero 

  oPrinter:Say(1399+nSaltRow,0105,cNosNumImp,oArial8,,0) //175/90283924-7
 
  oPrinter:FillRect({1428+nSaltRow,0058,1430+nSaltRow,0410},oBrush) //____________________

  oPrinter:Say(1372+nSaltRow,0455,"Data do Documento",oArial6N,,0) //Data Doc.

  oPrinter:Say(1392+nSaltRow,0469,DTOC(aDadosTit[2]),oArial8,,0) //03/03
  
  oPrinter:FillRect({1369+nSaltRow,0676,1430+nSaltRow,0678},oBrush) //|

  oPrinter:Say(1376+nSaltRow,0690,"N Documento",oArial6N,,0) //  N Doc

  oPrinter:Say(1391+nSaltRow,0790,Alltrim(aDadosTit[10]),oArial8,,0) //04/16

  oPrinter:FillRect({1369+nSaltRow,1061,1430+nSaltRow,1063},oBrush) //|

  oPrinter:Say(1370+nSaltRow,1078,"Especie Doc",oArial6N,,0) //Esp Doc

  oPrinter:Say(1394+nSaltRow,1089,aDadosTit[8],oArial8,,0) // CT 

  oPrinter:FillRect({1369+nSaltRow,1323,1430+nSaltRow,1325},oBrush) //|

  oPrinter:Say(1370+nSaltRow,1330,"Aceite",oArial6N,,0) //Aceite

  oPrinter:Say(1394+nSaltRow,1362,"N",oArial8,,0) //N

  oPrinter:FillRect({1369+nSaltRow,1420,1430+nSaltRow,1422},oBrush) //|

  oPrinter:Say(1370+nSaltRow,1500,"Data do Processamento",oArial6N,,0) //Data Processamento

  oPrinter:Say(1390+nSaltRow,1528,DTOC(aDadosTit[3]),oArial8,,0) //03/03/2016

  oPrinter:Say(1372+nSaltRow,1838,"Nosso Numero",oArial6N,,0) //Nosso Numero

  oPrinter:Say(1394+nSaltRow,1841,cNosNumImp,oArial8,,0) //175/90283924-7

 oPrinter:FillRect({1428+nSaltRow,0445,1430+nSaltRow,2290},oBrush) //_________________________________________________________________
 
 /***************************************************************************************************************
 Agencia/Cod Cedente  Uso Banco| Carteira| Especie Moeda| Quantidade | Valor     | (=) Valor Documento
 ____________________ _________|_________|______________|____________|___________|______________________
 ***************************************************************************************************************/
 oPrinter:Say(1436+nSaltRow,0060,"Agencia/Codigo do Beneficiário",oArial6N,,0)

//verifico se imprime codigo do beneficiario por EE_CODEMP
if lCodEmp .And. aDadosBanco[1] $ cBcoCodEmp

	oPrinter:Say(1461+nSaltRow,0144,Alltrim(aDadosBanco[3]+"/"+Alltrim(aDadosBanco[11])),oArial8,,0)
 	
else

 	oPrinter:Say(1461+nSaltRow,0144,Alltrim(aDadosBanco[3]+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]),oArial8,,0)
	 
endif
 	
 oPrinter:FillRect({1490+nSaltRow,0060,1492+nSaltRow,0410},oBrush)
 
 oPrinter:Say(1432+nSaltRow,0448,"Uso Banco",oArial6N,,0)
 oPrinter:FillRect({1428+nSaltRow,0676,1492+nSaltRow,0678},oBrush)
  
 oPrinter:Say(1430+nSaltRow,0686,"Carteira",oArial6N,,0)
 oPrinter:Say(1450+nSaltRow,0758,aDadosBanco[6],oArial8,,0)
 oPrinter:FillRect({1428+nSaltRow,0910,1492+nSaltRow,0912},oBrush)
 
 
 oPrinter:Say(1432+nSaltRow,0919,"Especie Moeda",oArial6N,,0)
 oPrinter:Say(1450+nSaltRow,0989,"R$",oArial8,,0)
 oPrinter:FillRect({1428+nSaltRow,1136,1492+nSaltRow,1138},oBrush)
 
 oPrinter:Say(1434+nSaltRow,1148,"Quantidade",oArial6N,,0)
 oPrinter:Say(1434+nSaltRow,1376,"Valor",oArial6N,,0)
 oPrinter:FillRect({1428+nSaltRow,1369,1492+nSaltRow,1371},oBrush)
 
  
 oPrinter:Say(1432+nSaltRow,1839,"(=) Valor do Documento",oArial6N,,0)
 oPrinter:Say(1451+nSaltRow,2060,Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99")),oArial8,,0)
 
 oPrinter:FillRect({1492+nSaltRow,0445,1494+nSaltRow,2290},oBrush)
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
 
  oPrinter:Say(1499+nSaltRow,0450,"Instrucoes - Instrucoes de Responsabilidade do Beneficiario",oArial5N,,0)
  oPrinter:Say(1499+nSaltRow,0980,"Qualquer duvida sobre este boleto, Contate o Beneficiario",oArial5N,,0)
  
  //mensagens de instrucoes do boleto, parametros MV_XMSPAD1 e MV_XMSPAD2
  oPrinter:Say(1520+nSaltRow,0457,cMsgPad1,oFont7,,0)
  oPrinter:Say(1557+nSaltRow,0459,cMsgPad2,oFont7,,0)
  oPrinter:Say(1594+nSaltRow,0459,cMsgPad3,oFont7,,0)
  
  
    //imprime a mensagem de juros  
	If SuperGetMV("MV_TXPER",,0) > 0
		
		//verifico se os valores serao impressos em valores reais ou percentual
		if lMulJurPer
			oPrinter:Say(1631+nSaltRow,0459,"APOS VENCIMENTO COBRAR "+nTxPerm+" POR DIA DE ATRASO",oFont7,,0)
		else
			
			nMoraDia := Round(aDadosTit[5] * (SuperGetMV("MV_TXPER",,0) / 100),2)
			
			//se for inferior a 1 centavo, arrendondar para 1 centavo
			if nMoraDia < 0.01
				
				nMoraDia := 0.01 
			
			endif
			
			oPrinter:Say(1631+nSaltRow,0459,"APÓS O VENCIMENTO COBRAR JUROS DE R$ " + Alltrim(Transform(nMoraDia,"@E 99,999.99")) + " AO DIA",oFont7,,0)
			
		endif
			
	endif
	  
	//imprime mensagem de multa 
	if SuperGetMV("MV_LJMULTA",,0) > 0
	
		//verifico se os valores serao impressos em valores reais ou percentual
		if lMulJurPer
			oPrinter:Say(1668+nSaltRow,0459,"APOS VENCIMENTO COBRAR MULTA DE "+nMulta+" ",oFont7,,0)
		else
			
			nVlrMulta := Round(aDadosTit[5] * (SuperGetMV("MV_LJMULTA",,0) / 100),2)
			
			//se for inferior a 1 centavo, arrendondar para 1 centavo
			if nVlrMulta < 0.01
				
				nVlrMulta := 0.01 
			
			endif
			oPrinter:Say(1668+nSaltRow,0459,"APOS VENCIMENTO COBRAR MULTA DE R$ "+Alltrim(Transform(nVlrMulta,"@E 99,999.99"))+" ",oFont7,,0)
			
		endif
		
	endif

	if lCemiterio

		// mens*agem do tipo do titulo
		if AllTrim(aDadosTit[12]) == cTipoMnt // taxa de manutencao
			oPrinter:Say(1699+nSaltRow,0459,"PARCELA DE TAXA DE MANUTENCAO, PARCELA " + aDadosTit[10],oFont7,,0)
		elseIf AllTrim(aDadosTit[12]) == cTipoPar // tipo de parcela
			oPrinter:Say(1699+nSaltRow,0459,"PARCELA DE FINANCIAMENTO DE CONTRATO, PARCELA " + aDadosTit[10],oFont7,,0)
		endIf

	endIf
	
  oPrinter:Say(1499+nSaltRow,0065,"(=) Valor do Documento",oArial6N,,0)
  oPrinter:Say(1521+nSaltRow,0240,PadL( Alltrim(Transform(aDadosTit[5],"@E 999,999,999.99")),14),oArial8,,0)
  oPrinter:FillRect({1550+nSaltRow,0058,1552+nSaltRow,0410},oBrush)
  
  oPrinter:Say(1499+nSaltRow,1839,"(-) Desconto/Abatimento",oArial6N,,0)
	If aDadosTit[9] > 0
  	oPrinter:Say(1521+nSaltRow,2060,PadL( Alltrim(Transform(aDadosTit[9],"@E 999,999,999.99")),14),oArial8,,0)
	EndIf
  
  oPrinter:FillRect({1550+nSaltRow,1830,1552+nSaltRow,2290},oBrush)
  //--------------------------------------------------------------------------------  
  oPrinter:Say(1562+nSaltRow,0065,"(-) Desconto/Abatimento",oArial6N,,0)
  oPrinter:Say(1580+nSaltRow,0303,'',oArial8,,0)
  oPrinter:FillRect({1607+nSaltRow,0063,1607+nSaltRow,0410},oBrush)
  
  oPrinter:Say(1562+nSaltRow,1839,"(-) Outras Deducoes",oArial6N,,0)
  oPrinter:Say(1580+nSaltRow,2060,'',oArial8,,0)
  oPrinter:FillRect({1607+nSaltRow,1830,1609+nSaltRow,2290},oBrush)
  
//----------------------------------------------------------------------------------
  oPrinter:Say(1625+nSaltRow,0067,"(-) Outras Deducoes",oArial6N,,0)
  oPrinter:Say(1643+nSaltRow,0298,'',oArial8,,0)
  oPrinter:FillRect({1670+nSaltRow,0058,1672+nSaltRow,0410},oBrush)

  oPrinter:Say(1625+nSaltRow,1839,"(+) Mora / Multa",oArial6N,,0)
  oPrinter:Say(1643+nSaltRow,2060,'',oArial8,,0)
  oPrinter:FillRect({1670+nSaltRow,1830,1672+nSaltRow,2290},oBrush)
  
//----------------------------------------------------------------------------------
  oPrinter:Say(1688+nSaltRow,0065,"(+) Mora / Multa",oArial6N,,0)
  oPrinter:Say(1706+nSaltRow,0294,'',oArial8,,0)
  oPrinter:FillRect({1733+nSaltRow,0058,1735+nSaltRow,0410},oBrush)
  
  oPrinter:Say(1688+nSaltRow,1839,"(+) Outros Acrescimos",oArial6N,,0)
  oPrinter:Say(1706+nSaltRow,2060,'',oArial8,,0)
  oPrinter:FillRect({1733+nSaltRow,1830,1735+nSaltRow,2290},oBrush)
  
//----------------------------------------------------------------------------------
  oPrinter:Say(1751+nSaltRow,0063,"(+) Outros Acrescimos",oArial6N,,0)
  oPrinter:Say(1769+nSaltRow,0298,'',oArial8,,0)
  oPrinter:FillRect({1796+nSaltRow,0056,1798+nSaltRow,0410},oBrush)

  oPrinter:Say(1751+nSaltRow,1839,"(=) Valor Cobrado",oArial6N,,0)
  oPrinter:Say(1769+nSaltRow,2060,'',oArial8,,0)
  oPrinter:FillRect({1796+nSaltRow,445,1798+nSaltRow,2290},oBrush)
  

//----------------------------------------------------------------------------------

  oPrinter:Say(1814+nSaltRow,0063,"(=) Valor Cobrado",oArial6N,,0)
  oPrinter:Say(1828+nSaltRow,0294,'',oArial8,,0)
  oPrinter:FillRect({1859+nSaltRow,0053,1861+nSaltRow,0410},oBrush)
 
/******************************************************************************************
Sacado               Pagador
  08025432            Maria Helena Mamede Cecilio 
MARIA HELENA MAMEDE   RUA VC 16 QD 24 LT 14
____________________  CNJ VERA CRUZ I 
                      
                      Sacador/Avalista
                     _______________________________________________________________Codigo de Baixa____
                     |||||||||||||||||||||||||||||||||||||||||||||||||||||         Ficha de Compensacao

******************************************************************************************/  

oPrinter:Say(1873+nSaltRow,0063,"Pagador",oArial6N,,0)
oPrinter:Say(1873+nSaltRow,0155,aDatSacado[10],oArial6N,,0)

// pego a descricao do pagador
cPagador := aDatSacado[1]

// vou contar quantas linhas serao impressas
nLin	:= 0
nLinha 	:= 0
nLin 	:= mlcount(cPagador,20)   
  
// vou deixar imprimir apenas duas linhas
	if nLin > 2
	nLin := 2
	endIf
   
// percorro o resultado mlcount e utilizo o memoline para imprimir
	For i := 1 to nLin
    oPrinter:Say(1908+nLinha+nSaltRow,0063, memoline(cPagador,20,i),oArial8,,0)
	nLinha += 22
	Next i

oPrinter:FillRect({1960+nSaltRow,0053,1960+nSaltRow,0410},oBrush)

// Beneficiario
oPrinter:Say(1974+nSaltRow, 0063, "Beneficiario",oArial6N,,0) 

// nome do beneficiario
cNmBenef := Alltrim(aDadosEmp[1])

// vou contar quantas linhas serao impressas
nLin	:= 0
nLinha 	:= 0
nLin 	:= mlcount(cNmBenef,20)   
  
// vou deixar imprimir apenas duas linhas
	if nLin > 2
	nLin := 2
	endIf

// percorro o resultado mlcount e utilizo o memoline para imprimir
	For i := 1 to nLin
    oPrinter:Say(2009+nLinha+nSaltRow,0063, memoline(cNmBenef,20,i),oArial6,,0)
	nLinha += 22
	Next i

// cnpj do beneficiario
cCNPJBenef := Alltrim(SubStr(aDadosEmp[6],6))

// vou contar quantas linhas serao impressas
nLin	:= 0
nLin 	:= mlcount(cCNPJBenef,20)   
  
// vou deixar imprimir apenas duas linhas
	if nLin > 2
	nLin := 2
	endIf

// percorro o resultado mlcount e utilizo o memoline para imprimir
	For i := 1 to nLin
    oPrinter:Say(2009+nLinha+nSaltRow,0063, memoline(cCNPJBenef,20,i),oArial6,,0)
	nLinha += 22
	Next i

// endereco do beneficiario
cEndBenef := Alltrim(aDadosEmp[3])+","+Alltrim(aDadosEmp[4])

// vou contar quantas linhas serao impressas
nLin	:= 0
nLin 	:= mlcount(cEndBenef,20)   
  
// vou deixar imprimir apenas duas linhas
	if nLin > 2
	nLin := 2
	endIf

// percorro o resultado mlcount e utilizo o memoline para imprimir
	For i := 1 to nLin
    oPrinter:Say(2009+nLinha+nSaltRow,0063, memoline(cEndBenef,20,i),oArial6,,0)
	nLinha += 22
	Next i

oPrinter:Say(1815+nSaltRow,0455,"Pagador",oArial6N,,0)
  
oPrinter:Say(1840+nSaltRow,0865,Alltrim(aDatSacado[1]) +  " - " + Alltrim(aDatSacado[2])  ,oArial8,,0)
oPrinter:Say(1865+nSaltRow,0865,Alltrim(aDatSacado[3]),oArial8,,0)
oPrinter:Say(1890+nSaltRow,0865,SubStr(Alltrim(aDatSacado[4]),1,14),oArial8,,0)
oPrinter:Say(1890+nSaltRow,1170,Alltrim(aDatSacado[9])+"  "+SubsTr(Alltrim(aDatSacado[6]),1,5)+"-"+Alltrim(SubsTr(aDatSacado[6],6,3)),oArial8,,0)
  
oPrinter:FillRect({1965+nSaltRow,0450,1967+nSaltRow,2290/*2050*/},oBrush)
oPrinter:Say(1935+nSaltRow,0455,"Pagador/Avalista",oArial6N,,0)

	If Alltrim( aDatSacado[8] ) == 'J'
	cCpfCnpj := "CNPJ: "+Alltrim(Transform(Alltrim(aDatSacado[7]),"@R 99.999.999/9999-99"))
	Else
	cCpfCnpj := "CPF: "+Alltrim(Transform(Alltrim(aDatSacado[7]),"@R 999.999.999-99"))
	EndIf

oPrinter:Say(1935+nSaltRow,0865,Alltrim(cCpfCnpj),oArial8,,0)

oPrinter:Say(1971+nSaltRow,1840,"Autenticação Mecânica - Ficha de Compensação",oArial6,,0)

//oPrinter:Say(1965+nSaltRow,2054,"Código de Baixa",oFont5,,0)
//oPrinter:FillRect({1965+nSaltRow,2136,1967+nSaltRow,2290},oBrush)
 
MSBAR3("INT25"/*cTypeBar*/,nRowBar/*nRow*/,004/*nCol*/,aCB_RN_NN[1]/*cCode*/,oPrinter/*oPrint*/,.F./*lCheck*/,/*Color*/,.T./*lHorz*/,0.027/*nWidth*/,0.86/*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)

//oPrinter:Say(1977+nSaltRow,1950,"Ficha de Compensação",oArial9N,,0)
//oPrinter:Say(2015+nSaltRow,1965,"Autenticar no verso",oFont5,,0)
   
/********************************************
*LINHA VERTIFICAL DA ULTIMA COLUNA DO BOLETO
********************************************/
oPrinter:FillRect({1234+nSaltRow,1830,1798+nSaltRow,1832},oBrush) //

oPrinter:Say((2015+nSaltRow)+105,0063,Replicate("- -",150),,,0)
  
Return()

///////////////////////////////////////////////////
////// IMPRESSAO DO RODAPE DA PAGINA 	  /////////
//////////////////////////////////////////////////
Static Function ImpRodape(oPrinter,nPagImp)

Local oFont8	 :=	TFont():New("Arial",,8,,.F.,,,,,.F.,.F.)    


oPrinter:Line(3320,0120,3320,2240) 
oPrinter:Say(3350,0110,"Página: " + StrZero(nPagImp,4) + " - TOTVS - Protheus",oFont8)

Return()



