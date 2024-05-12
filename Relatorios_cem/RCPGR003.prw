#INCLUDE "RWMAKE.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE P_RAZAO    		1 	// RAZAO SOCIAL
#DEFINE P_CODCLI   		2 	// CODIGO DO CLIENTE
#DEFINE P_END      		3 	// ENDERECO DO CLIENTE
#DEFINE P_MUN      		4 	// MUNICIPIO DO CLIENTE
#DEFINE P_EST      		5 	// ESTADO DO CLIENTE
#DEFINE P_CEP      		6 	// CEP DO CLIENTE
#DEFINE P_CGC      		7 	// CGC DO CLIENTE
#DEFINE P_PESSOA   		8 	// TIPO DE CLIENTE F=FISICA J=JURIDICA
#DEFINE P_BAIRRO   		9 	// BAIRRO DO CLIENTE
#DEFINE P_ROTA		  	11 	// ROTA DO CLIENTE
#DEFINE P_DESCR		  	12	// DESCRICAO DA ROTA
#DEFINE P_PTOREFE	  	13	// PONTO DE REFERENCIA DO ENDERECO
#DEFINE P_FANTASIA		14	// NOME FANTASIA (APELIDO)
#DEFINE P_COMPLEM	  	15	// COMPLEMENTO DE ENDERECO

/*/{Protheus.doc} RCPGR003
Fonte de Recibo de Geracao de Boleto 
@type function
@version 1.0
@author Raphael Martins - raphael.garcia@totvs.com.br
@since 15/03/2016
@param nLinhaIni, numeric, linha inicial da impressao
@param oPrinter, object, objeto de impressao
@param aCliente, array, dados do cliente
@param dRefInicial, date, data de referencia incicial
@param dRefFinal, date, data de referencia final
@param nPosCodBar, numeric, posicao do codigo de barras
@param cContrato, character, codigo do contrato
/*/
User Function RCPGR003(nLinhaIni, oPrinter, aCliente, dRefInicial, dRefFinal, nPosCodBar, cContrato, nRowCodBar, nColCodBar)

	Local lObj   	    := .F.

	Default aCliente    := {}
	Default dRefInicial := Stod("")
	Default dRefFinal   := Stod("")
	Default nLinhaIni	:= 0
	Default nPosCodBar	:= 1
	Default cContrato  	:= ""
	Default nRowCodBar	:= 0
	Default nColCodBar	:= 0

	If ValType(oPrinter) == 'U'
		Private oPrinter    := TmsPrinter():New()
		Private oBrush	    := TBrush():New(,CLR_BLACK)

		oPrinter:Setup()
		oPrinter:SetPortrait()
		oPrinter:StartPage()

		lObj := .T.
	EndIf

	PrintPage(nLinhaIni,aCliente,dRefInicial,dRefFinal,@oPrinter,nPosCodBar,cContrato,nRowCodBar,nColCodBar)

	If lObj
		oPrinter:Preview()
	EndIf

Return
//__________________________________________________________________________________________
//| Remetente                      COMLEXO VALE DO CERRADO                                  |
//|                     RODOVIA GO 060 KM 07 - GOIANIA/GO - CEP 7400000                     |
//|                        FONE/FAX: (062) 3251-1029 / (062) 3597-6433                      |
//|                                                                                         | 
//|_________________________________________________________________________________________|
// _________________________________________________________________________________________
//|Ocorrencia  										 |	1 Visita						    |
//|    [ ] MUDOU-SE            [ ] NAO EXISTE Nº     |  Data:___/___/___   HORA:________    |
//|	   [ ] DESCONHECIDO		   [ ] END INSUFIC.		 | 									    |
//|    [ ] RECUSADO            [ ] ____________      |  2 Visita                            |
//|    [ ] AUSENTE                                   |  Data:___/___/___   HORA:________    | 
//|                                                  |                                      |
//|													 |	3 Visita			    			|
//|													 |	Data:___/___/___   HORA:________   	|
//|__________________________________________________|______________________________________|
// ________________________________________________________________________________________
//|                                                                                        |
//|Destinatario:                                                                           |
//|Nome:                                                                                   |
//|End.:                                                                                   |
//|Cidade:                                      CEP:                                       |
//|Telefone:                                   Telefone 2:                  Telefone 3:    |
//|Dt Emissao:                                 (Refer: 10/03/2016 10/03/2016)              |
//|Area: APARECIDA DE GOIANIA                 Ponto de Referencia: XXXXXXXXXXXXXXXXXXX     |
//|________________________________________________________________________________________|
// ________________________________________________________________________________________
//| Data de Recebimento: __________________________________                                |
//|                                                                    |||||||||||||       |
//| Assinatura do Receptor:_____________________________________        *016226*           |
//|________________________________________________________________________________________|
/*/{Protheus.doc} PrintPage
impressao do recibo de boleto
@type function
@version 1.0
@author Raphael Martins - raphael.garcia@totvs.com.br
@since 15/03/2016
@param nRowsSalt, numeric, parametro de linhas a serem saltadas
@param aCliente, array, dados do cliente
@param dRefInicial, date, data de referencia incicial
@param dRefFinal, date, data de referencia final
@param oPrinter, object, objeto de impressao
@param nPosCodBar, numeric, posicao do codigo de barras
@param cContrato, character, codigo do contrato
/*/

Static Function PrintPage(nRowsSalt, aCliente, dRefInicial, dRefFinal, oPrinter, nPosCodBar, cContrato, nRowCodBar, nColCodBar)

	Local cStartPath      := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	Local cLogoProtocolo	:= SuperGetMV("MV_XLGPREN",.F.,"lgrl01.bmp")// parametro para determinar a logo a ser impressa no protocolog de entrega
	Local cFoneSM0		    := ""
	Local cRota			      := ""
	Local oArial9N		    := TFont():New("Arial",,9,,.T.,,,,,.F.,.F.)
	Local oArial13N		    := TFont():New("Arial",,13,,.T.,,,,,.F.,.F.)
	Local oArial10N		    := TFont():New("Arial",,10,,.T.,,,,,.F.,.F.)
	Local oArial10		    := TFont():New("Arial",,10,,.F.,,,,,.F.,.F.)
	Local oArial11N		    := TFont():New("Arial",,11,,.T.,,,,,.F.,.F.)
	Local aTelefones	    := {}

	Default nRowsSalt     	:= 0
	Default aCliente      	:= {}
	Default dRefInicial   	:= Stod("")
	Default dRefFinal     	:= Stod("")
	Default nPosCodBar    	:= 1
	Default cContrato     	:= ""
	Default nColCodBar		:= 0
	Default nRowCodBar		:= 0

	//__________________________________________________________________________________________
	//| Remetente                      COMLEXO VALE DO CERRADO                                  |
	//|                     RODOVIA GO 060 KM 07 - GOIANIA/GO - CEP 7400000                     |
	//|                        FONE/FAX: (062) 3251-1029 / (062) 3597-6433                      |
	//|                                                                                         |
	//|_________________________________________________________________________________________|
	oPrinter:SayBitMap(nRowsSalt+0075,0464,cStartPath+'/'+cLogoProtocolo,0217,0093)

	oPrinter:Box(nRowsSalt+0053,0206,nRowsSalt+0197,2186)

	oPrinter:Say(nRowsSalt+0055,0263,"Remetente",oArial9N,,0)

	oPrinter:Say(nRowsSalt+0055,0770,SubStr(Alltrim(SM0->M0_NOMECOM),1,43),oArial13N,,0)

	oPrinter:Say(nRowsSalt+0110,0770,Alltrim(SM0->M0_ENDENT)+"-" +Alltrim(SM0->M0_CIDENT)+ "/"+Alltrim(SM0->M0_ESTENT)+ " - CEP:"+Alltrim(SM0->M0_CEPENT),oArial10,,0)

	cFoneSM0 := If( Len( Alltrim(SM0->M0_TEL) ) > 9,"("+SubStr(SM0->M0_TEL,1,3)+")"+SubStr(SM0->M0_TEL,4,Len( Alltrim(SM0->M0_TEL) ) ), Alltrim(SM0->M0_TEL)  )

	oPrinter:Say(nRowsSalt+0151,0770,"Fone/Fax: "+cFoneSM0+" ",oArial10,,0)

	//******************************************************************************************
	//|Ocorrencia  										 |	1 Visita						    |
	//|    [ ] MUDOU-SE            [ ] NAO EXISTE Nº     |  Data:___/___/___   HORA:________    |
	//|	   [ ] DESCONHECIDO		   [ ] END INSUFIC.		 | 									    |
	//|    [ ] RECUSADO            [ ] ____________      |  2 Visita                            |
	//|    [ ] AUSENTE                                   |  Data:___/___/___   HORA:________    |
	//|                                                  |                                      |
	//|													 |	3 Visita			    			|
	//|													 |	Data:___/___/___   HORA:________   	|
	//|__________________________________________________|______________________________________|
	oPrinter:Box(nRowsSalt+0206,0206,nRowsSalt+0506,1239)
	oPrinter:Say(nRowsSalt+0217,0266,"Ocorrencia",oArial11N,,0)

	oPrinter:Say(nRowsSalt+0262,0303,"[  ] MUDOU-SE",oArial10,,0)

	oPrinter:Say(nRowsSalt+0308,0303,"[  ] DESCONHECIDO",oArial10,,0)

	oPrinter:Say(nRowsSalt+0355,0303,"[  ] RECUSADO",oArial10,,0)

	oPrinter:Say(nRowsSalt+0406,0303,"[  ] AUSENTE",oArial10,,0)

	oPrinter:Say(nRowsSalt+0260,0844,"[  ] NAO EXISTE N",oArial10,,0)

	oPrinter:Say(nRowsSalt+0306,0844,"[  ] END. INSUFIC.",oArial10,,0)

	oPrinter:Say(nRowsSalt+0353,0844,"[  ] ______________",oArial10,,0)

	oPrinter:Box(nRowsSalt+0206,1239,nRowsSalt+0506,2186)
	oPrinter:Say(nRowsSalt+0213,1257,"1ª Visita:",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0257,1276,"Data: ____/____/____",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0255,1670,"Hora: ____________",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0304,1257,"2ª Visita",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0344,1670,"Hora: ____________",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0344,1276,"Data: ___/____/____",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0402,1257,"3ª Visita",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0442,1276,"Data: ___/___/____",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0442,1670,"Hora: ____________",oArial10N,,0)


	//***************************************************************************************
	// ________________________________________________________________________________________
	//|                                                                                        |
	//|Destinatario:                				 Rota: 000001 - Rota 001                     |
	//|Nome:                                                                                   |
	//|End.:                                                                                   |
	//|Cidade:                                      CEP:                                       |
	//|Telefone:                                   Telefone 2:                  Telefone 3:    |
	//|Dt Emissao:                                 (Refer: 10/03/2016 10/03/2016)              |
	//|Area: APARECIDA DE GOIANIA                                                              |
	//|________________________________________________________________________________________|
	oPrinter:Box(nRowsSalt+0515,0206,nRowsSalt+0828,2186)
	oPrinter:Say(nRowsSalt+0526,0256,"Destinatario:",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0528,0482,"Inscr.: "+aCliente[P_CODCLI],oArial10,,0)

	cRota	:=  Alltrim(aCliente[P_DESCR])

	oPrinter:Say(nRowsSalt+0528,0875,"Rota: " + cRota  ,oArial10N,,0)

	oPrinter:Say(nRowsSalt+0564,0256,"Nome:",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0566,0380,Alltrim(aCliente[P_RAZAO]) + " (" + Alltrim(aCliente[P_FANTASIA]) + ")",oArial10,,0)

	oPrinter:Say(nRowsSalt+0606,0259,"End.:",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0608,0353,Alltrim(aCliente[P_END])+" " + aCliente[P_COMPLEM] + " " + iif(!Empty(aCliente[P_CEP]),"CEP: " + aCliente[P_CEP], " " ),oArial10,,0)

	oPrinter:Say(nRowsSalt+0651,0254,"Cidade:",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0653,0390,aCliente[P_MUN]+"/"+aCliente[P_EST],oArial10,,0)

	oPrinter:Say(nRowsSalt+0651,1344,"Vendedor:",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0653,1560,RetNomVend(cContrato),oArial10,,0)

	oPrinter:Say(nRowsSalt+0695,0254,"Telefone:",oArial10N,,0)

	aTelefones := RetFone(aCliente[P_CODCLI])

	oPrinter:Say(nRowsSalt+0697,0420,aTelefones[1],oArial10,,0)

	oPrinter:Say(nRowsSalt+0735,0259,"Dt. Emissao:",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0737,0480,DTOC(dDataBase),oArial10,,0)

	oPrinter:Say(nRowsSalt+0780,0261,"Area:",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0782,0357,Alltrim( aCliente[P_BAIRRO] ),oArial10,,0)

	oPrinter:Say(nRowsSalt+0695,0875,"Celular 1:",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0697,1065,aTelefones[2],oArial10,,0)

	oPrinter:Say(nRowsSalt+0695,1344,"Celular 2:",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0695,1560,aTelefones[3],oArial10,,0)

	oPrinter:Say(nRowsSalt+0731,0900,"(REFER: "+DTOC(dRefInicial)+"  -  "+DTOC(dRefFinal)+")",oArial10,,0)

	oPrinter:Say(nRowsSalt+0780,0875,"Ponto de Referencia:",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0780,1290,Alltrim( aCliente[P_PTOREFE] ),oArial10,,0)


	//******************************************************************************************
	//| Data de Recebimento: __________________________________                                |
	//|                                                                    |||||||||||||       |
	//| Assinatura do Receptor:_____________________________________        *016226*           |
	//|________________________________________________________________________________________|
	oPrinter:Box(nRowsSalt+0837,0206,nRowsSalt+0971,2186)
	oPrinter:Say(nRowsSalt+0844,0256,"Data do Recebimento: _____/______/______",oArial10N,,0)

	oPrinter:Say(nRowsSalt+0906,0254,"Assinatura do Receptor: __________________________________________",oArial10N,,0)

	//inicio da pagina
	If nPosCodBar == 1

		nRowCodBar	:= 007.3
		nColCodBar	:= 015

		//meio da pagina
	elseif nPosCodBar == 2

		nRowCodBar	:= 017.4
		nColCodBar	:= 015

		//fim da pagina
	elseIf nPosCodBar == 3

		nRowCodBar	:= 025.7
		nColCodBar	:= 015

	endif

	//codigo de barras
	MsBar3( 'CODE128', nRowCodBar , nColCodBar	, Alltrim(xFilial("U32")) + Alltrim(cContrato) , oPrinter, .F., , .T., 0.018, 0.5, .T., 'TAHOMA', 'B', .F. )

Return(Nil)

/*/{Protheus.doc} RetFone
Funcao para Retornar Telefones do Clientes
@type function
@version 1.0  
@author nata queiroz
@since 21/01/2021
@param cCliente, character, codigo+loja do cliente
@return array, retora o telefone dos cliemtes
/*/
Static Function RetFone(cCliente)
	Local aArea		  := GetArea()
	Local aAreaSA1	:= SA1->( GetArea() )
	Local cFone1	  := ""
	Local cFone2	  := ""
	Local cFone3	  := ""

	Default cCliente  := ""

	SA1->( DbSetOrder(1) ) //A1_FILIAL + A1_COD
	if SA1->( MsSeek( xFilial("SA1") + cCliente ) )

		cFone1 := iif(!Empty(SA1->A1_DDD) .And. !Empty(SA1->A1_TEL), "("+Alltrim(SA1->A1_DDD)+") ","") + Alltrim(SA1->A1_TEL)
		cFone2 := iif(!Empty(SA1->A1_XDDDCEL) .And. !Empty(SA1->A1_XCEL), "("+Alltrim(SA1->A1_XDDDCEL)+") ","") + Alltrim(SA1->A1_XCEL)
		cFone3 := iif(!Empty(SA1->A1_XDDDCEL) .And. !Empty(SA1->A1_XCEL2), "("+Alltrim(SA1->A1_XDDDCEL)+") ","") + Alltrim(SA1->A1_XCEL2)

	endIf

	RestArea(aAreaSA1)
	RestArea(aArea)

Return({cFone1,cFone2,cFone3})

/*/{Protheus.doc} RetNomVend
Busca nome do vendedor do contrato
@type function
@version 12.1.27
@author nata.queiroz
@since 16/06/2021
@param cContrato, character, cContrato
@return character, cNomVend
/*/
Static Function RetNomVend(cContrato)
	Local aArea := GetArea()
	Local aAreaUF2 := {}
	Local aAreaU00 := {}
	Local aAreaSA3 := SA3->( GetArea() )
	Local cNomVend := ""
	Local lFuneraria := SuperGetMV("MV_XFUNE", .F., .F.)
	Local lCemiterio := SuperGetMV("MV_XCEMI", .F., .F.)

	Default cContrato := ""

	If lFuneraria

		aAreaUF2 := UF2->( GetArea() )

		UF2->( DbSetOrder(1) ) // UF2_FILIAL+UF2_CODIGO
		If UF2->( MsSeek(xFilial("UF2") + cContrato) )

			SA3->( DbSetOrder(1) ) // A3_FILIAL+A3_COD
			If SA3->( MsSeek(xFilial("SA3") + UF2->UF2_VEND) )
				cNomVend := AllTrim(SA3->A3_NOME)
			EndIf

		EndIf

		RestArea(aAreaUF2)

	ElseIf lCemiterio

		aAreaU00 := U00->( GetArea() )

		U00->( DbSetOrder(1) ) // U00_FILIAL+U00_CODIGO
		If U00->( MsSeek(xFilial("U00") + cContrato) )

			SA3->( DbSetOrder(1) ) // A3_FILIAL+A3_COD
			If SA3->( MsSeek(xFilial("SA3") + U00->U00_VENDED) )
				cNomVend := AllTrim(SA3->A3_NOME)
			EndIf

		EndIf

		RestArea(aAreaU00)

	EndIf

	RestArea(aAreaSA3)
	RestArea(aArea)

Return cNomVend
