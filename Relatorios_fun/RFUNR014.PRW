#include "totvs.ch"
#include "fwprintsetup.ch"
#include "fileio.ch"
#include "rptdef.ch"
#include "topconn.ch"

/*/{Protheus.doc} RFUNR014
Impressao do Termo de Ordem de Servico 
@type function
@version 1.0
@author g.sampaio
@since 05/11/2019
@param nRecnoUJ0, numeric, recno do apontamento de servicos
/*/
User Function RFUNR014( nRecnoUJ0 )

	Local aArea             := GetArea()
	Local cPerg             := "RFUNR014"
	Local dDtDeEmissao      := StoD("")
	Local dDtAteEmissao     := StoD("")
	Local nTipo             := 0
	Local cAdministradora   := ""
	Local lEnd              := .F.
	Local oProcess          := Nil

	Default nRecnoUJ0       := 0

// consulta de dados da rotina
	oProcess := MsNewProcess():New({|lEnd| ConsultaDeDados( nRecnoUJ0, @oProcess, @lEnd ) },"Buscando dados da O.S. ...","",.T.)
	oProcess:Activate()

	RestArea( aArea )

Return( Nil )


/*/{Protheus.doc} ConsultaDeDados
Consulta de dados para a impressao
@author g.sampaio
@since 05/11/2019
@version P12
@param nulo
@return lRetorno, logico, retorno se os parametros foram importados corretamente
@history 25/05/2020, Raphael Martins, ajuste para nao trazer os itens entregues com o UJ2_OK vazio.
/*/

Static Function ConsultaDeDados( nRecnoUJ0, oProcess, lEnd )

	Local aArea             := GetArea()
	Local aAreaUJ0          := UJ0->( GetArea() )
	Local aAreaUJ2          := UJ2->( GetArea() )
	Local aAreaUF2          := UF2->( GetArea() )
	Local aAreaUF4          := UF4->( GetArea() )
	Local aAreaUJC          := UJC->( GetArea() )
	Local aAreaCC2          := CC2->( GetArea() )
	Local aAreaSB1          := SB1->( GetArea() )
	Local aAreaUJB          := UJB->( GetArea() )
	Local aAreaUG3          := UG3->( GetArea() )
	Local aAreaUF0          := UF0->( GetArea() )
	Local aDados            := {}
	Local aCabOS            := {}
	Local aItens            := {}
	Local aItensOS          := {}
	Local aProfOS           := {}
	Local cDescPlano        := ""
	Local lDescItemEnt      := SuperGetMV("MV_XDITENT", .F., .F.)

	Default nRecnoUJ0       := 0
	Default lEnd            := .F.

	// pego os dados do cabecalho da Ordem de Servico
	UJ0->( DbGoTo( nRecnoUJ0 ) )

	// posiciono no plnao entregue
	UF0->( DbSetOrder(1) )
	If UF0->( MsSeek( xFilial("UF0")+UJ0->UJ0_PLANOE ) )
		cDescPlano := UF0->UF0_DESCRI // descricao do plano entregue
	EndIf

	// adicionados os dados do cabecalho da ordem de servico
	Aadd( aCabOS, TipoServico(UJ0->UJ0_TPSERV) ) // tipo de servico
	Aadd( aCabOS, UJ0->UJ0_CONTRA ) // codigo do contrato
	Aadd( aCabOS, cDescPlano ) // plano de contrato entregue

	// vou pegar se esta em carencia ou nao
	UF4->( dbSetOrder(1) )
	If UF4->( MsSeek( xFilial("UF4")+UJ0->UJ0_CONTRA+UJ0->UJ0_CODBEN ) )

		// caso a data de cadastro for maior que a data de carencia, o contrato nao esta em carencia
		If UJ0->UJ0_DTCADA > UF4->UF4_CAREN

			Aadd( aCabOS, "NÃO" ) // carencia

		Else // caso o contrato esteja em carencia

			Aadd( aCabOS, "SIM" ) // carencia

		EndIf

	Else// caso nao consiga posicionar no beneficiario

		Aadd( aCabOS, "NÃO" ) // carencia

	Endif

	Aadd( aCabOS, UJ0->UJ0_NOMEFA ) // nome do falecido
	Aadd( aCabOS, UJ0->UJ0_CPF )    // cpf

	// posiciono no cadastro de religiao
	UG3->( DbSetOrder(1) )
	If UG3->( MsSeek( xFilial("UG3")+UJ0->UJ0_RELIGI ) )

		Aadd( aCabOS, UG3->UG3_DESC ) // religiao

	Else

		Aadd( aCabOS, "" ) // religiao

	EndIf

	Aadd( aCabOS, UJ0->UJ0_PESOFA ) // peso
	Aadd( aCabOS, UJ0->UJ0_ALTUFA ) // altura

	// pego os dados do local de remocao
	If !Empty( UJ0->UJ0_REMOCA )

		// posiciona nos locais de remocao
		UJC->( dbSetOrder(1) )
		If UJC->( MsSeek( xFilial("UJC")+UJ0->UJ0_REMOCA ) )

			Aadd( aCabOS, UJC->UJC_DESCRI ) // local de remocao

			// posiciono no cadstro de municipios
			CC2->( DbSetOrder(1) )
			If CC2->( MsSeek( xFilial("CC2")+UJC->UJC_ESTADO+UJC->UJC_CODMUN ) )

				Aadd( aCabOS, CC2->CC2_MUN + "/" + UJC->UJC_ESTADO ) // cidade/estado

			else// caso nao encontre o municipio

				Aadd( aCabOS, "" ) // cidade/estado

			EndIf

			Aadd( aCabOS, UJC->UJC_LOCREM ) // ponto de referencia

			// verifico se o campo bairro existe na base do cliente
			If UJC->( FieldPos("UJC_BAIREM") ) > 0

				Aadd( aCabOS, UJC->UJC_BAIREM ) // bairro do local de remocao

			Else// caso o campo nao exista

				Aadd( aCabOS, "" ) // bairro do local de remocao

			EndIf

		EndIf

	Else

		Aadd( aCabOS, UJ0->UJ0_LOCREM ) // local de remocao
		Aadd( aCabOS, "" ) // cidade/estado
		Aadd( aCabOS, "" ) // ponto de referencia
		Aadd( aCabOS, "" ) // bairro do local de remocao

	EndIf

	// verifico se o campo responsavel existe na base
	If UJ0->( FieldPos("UJ0_RESPOB") ) > 0

		Aadd( aCabOS, UJ0->UJ0_RESPOB ) // responsavel

	Else

		Aadd( aCabOS, "" ) // responsavel

	EndIf

	If UJ0->( FieldPos("UJ0_TELCI1") ) > 0
		Aadd( aCabOS, UJ0->UJ0_TELCI1 ) // telefone 1
	Else
		Aadd( aCabOS, "" ) // telefone 1
	EndIf

	If UJ0->( FieldPos("UJ0_TELCI2") ) > 0
		Aadd( aCabOS, UJ0->UJ0_TELCI2 ) // telefone 2
	Else
		Aadd( aCabOS, "" ) // telefone 2
	EndIf

	// pego os dados de itens de servicos
	UJ2->( DbSetOrder(1) )
	If UJ2->( MsSeek( xFilial("UJ2")+UJ0->UJ0_CODIGO ) )

		// percorro todos os itens da orgem de servicos
		While UJ2->( !Eof() ) .And. UJ2->UJ2_FILIAL == xFilial("UJ1") .And. UJ2->UJ2_CODIGO == UJ0->UJ0_CODIGO

			//valido se o item esta marcado
			if !Empty(UJ2->UJ2_OK)
				// adicionados os dados dos itens da ordem de servico
				aItens  := {}
				Aadd( aItens, UJ2->UJ2_ITEM )     // item
				Aadd( aItens, UJ2->UJ2_PRODUT )   // produto/servicos
				Aadd( aItens, Posicione( "SB1", 1, xFilial("SB1")+UJ2->UJ2_PRODUT, "B1_DESC" ) )   // descricao de produto/servicos
				Aadd( aItens, UJ2->UJ2_QUANT )    // quantidade
				Aadd( aItens, UJ2->UJ2_PRCVEN )   // preco de venda

				if lDescItemEnt
					Aadd( aItens, UJ2->UJ2_TOTAL )    // preco total da ordem de servicos com desconto
				else
					Aadd( aItens, UJ2->UJ2_SUBTOT )    // preco total
				endIf

				// adiciono os itens
				Aadd( aItensOS, aItens)

			endif

			UJ2->( DbSkip() )

		EndDo

	Endif

	// pego os profissionais da ordem de servicos
	// posiciono no cadastro de motoristas
	UJB->( DbSetOrder(1) )
	If UJB->( MsSeek( xFilial("UJB")+UJ0->UJ0_MOTREM ) )
		Aadd( aProfOS, UJB->UJB_NOME ) // agente 1
	Else
		Aadd( aProfOS, "" ) // agente 1
	EndIf

	// posiciono no cadastro de motoristas
	UJB->( DbSetOrder(1) )
	If UJB->( MsSeek( xFilial("UJB")+UJ0->UJ0_MOTRE2 ) )
		Aadd( aProfOS, UJB->UJB_NOME ) // agente 2
	Else
		Aadd( aProfOS, "" ) // agente 2
	EndIf

	// verificio se o campo placa existe
	If UJ0->( FieldPos("UJ0_XPLACA") ) > 0
		Aadd( aProfOS, UJ0->UJ0_XPLACA )
	Else
		Aadd( aProfOS, "" )
	EndIf

	// verificio se o campo placa existe 2
	If UJ0->( FieldPos("UJ0_XPLACA") ) > 0
		Aadd( aProfOS, UJ0->UJ0_XPLAC2 )
	Else
		Aadd( aProfOS, "" )
	EndIf

	// descricao do atendente
	Aadd( aProfOS, Upper( UJ0->UJ0_ATENDE ) )

	// verifico se os arrays de dados estao devidamente preenchidos
	If Len( aCabOS ) > 0 .And. Len( aItensOS ) > 0

		// dados para impressao
		Aadd( aDados, { aCabOS, aItensOS, UJ0->UJ0_OBSERV, aProfOS } )

	EndIf

	// verifico se existem dados para a impressao
	If Len( aDados ) > 0

		// chamo a funcao de impressao
		Imprimir( UJ0->UJ0_CODIGO, aDados, oProcess, lEnd )

	EndIf

	RestArea( aAreaUF0 )
	RestArea( aAreaUG3 )
	RestArea( aAreaUJB )
	RestArea( aAreaSB1 )
	RestArea( aAreaCC2 )
	RestArea( aAreaUJC )
	RestArea( aAreaUF4 )
	RestArea( aAreaUF2 )
	RestArea( aAreaUJ2 )
	RestArea( aAreaUJ0 )
	RestArea( aArea )

Return( Nil )

/*/{Protheus.doc} Imprimir
@author g.sampaio
@since 104/09/2019
@version P12
@param nulo
@return nulo
/*/

Static Function Imprimir( cNumeroOS, aDados, oProcess, lEnd )

	Local aArea             := GetArea()
	Local cFilePrint        := ""
	Local nLin              := 0
	Local oPrintOS         := Nil

	Private nMargemL        := 0     	//margem a esquera ( -> )
	Private nMargemR        := 0   	//margem da esqueda para direta ( <- )
	Private nMargemT	    := 0     	//início da margem cabeçalho(topo)
	Private nCenterPg	    := 0
	Private nLinRodPe       := 0
	Private nPag            := 0

	Private oFont9          := TFONT():New("ARIAL",9 ,9 ,,.F.,,,,,.F.,.F.) ///Fonte 9 Normal
	Private oFont9N         := TFONT():New("ARIAL",9 ,9 ,,.T.,,,,,.F.,.F.) ///Fonte 9 Negrito
	Private oFont10         := TFONT():New("ARIAL",10,10,,.F.,,,,,.F.,.F.) ///Fonte 10 Normal
	Private oFont10N        := TFONT():New("ARIAL",10,10,,.T.,,,,,.F.,.F.) ///Fonte 10 Negrito
	Private oFont12         := TFONT():New("ARIAL",12,12,,.F.,,,,,.F.,.F.) ///Fonte 12 Normal
	Private oFont12N        := TFONT():New("ARIAL",12,12,,.T.,,,,,.F.,.F.) ///Fonte 12 Negrito
	Private oFont14         := TFONT():New("ARIAL",14,14,,.F.,,,,,.F.,.F.) ///Fonte 14 Normal
	Private oFont14NS       := TFONT():New("ARIAL",14,14,,.T.,,,,,.T.,.F.) ///Fonte 14 Negrito e Sublinhado
	Private oFont14N        := TFONT():New("ARIAL",14,14,,.T.,,,,,.F.,.F.) ///Fonte 14 Negrito
	Private oFont20N        := TFONT():New("ARIAL",20,20,,.T.,,,,,.F.,.F.) ///Fonte 20 Negrito
	Private oFont32N        := TFONT():New("ARIAL",32,32,,.T.,,,,,.F.,.F.) ///Fonte 32 Negrito

	Default aDados          := {}
	Default lEnd            := .F.
	Default cNumeroOS       := ""

	// nome do arquivo
	cFilePrint := "ordem_de_servico_" + cNumeroOS + "_" + cFilAnt + Str( Year( date() ),4) + StrZero( Month( date() ), 2) + StrZero( Day( date() ),2) + Left(Time(),2) + Substr(Time(),4,2) + Right(Time(),2)// adicionado o numero do titulo na descricao do arquivo - g.sampaio 11/04/2018

	oPrintOS := FWMSPrinter():New(cFilePrint /*Nome Arq*/, /*IMP_SPOOL/IMP_PDF*/, .T. /*3-Legado*/,;
                                        /*4-Dir. Salvar*/, .F. /*5-Não Exibe Setup*/, /*6-Classe TReport*/,;
                                        /*7-oPrintSetup*/, /*8-Impressora Forçada*/,;
		.T. /*lServer*/ )


	oPrintOS:SetResolution(78) //Tamanho estipulado para a Danfe
	oPrintOS:SetPortrait() // ou SetLandscape()
	oPrintOS:SetPaperSize(DMPAPER_A4)
	oPrintOS:SetViewPDF(.T.)
	oPrintOS:SetMargin(60,60,60,60)
	oPrintOS:GetViewPDF()

	// variaveis de relatorio
	nMargemL        := 5     	                //margem a esquera ( -> )
	nMargemR        := oPrintOS:nPageWidth   	//margem da esqueda para direta ( <- )
	nMargemT	    := 1     	                //início da margem cabeçalho(topo)
	nCenterPg	    := nMargemR / 2
	nLinRodPe       := oPrintOS:nPageHeight - 120
	nPag            := 1

	// gero as informacoes do relatorio
	GeraRelatorio( cNumeroOS, aDados, @oPrintOS, @nLin, @oProcess, @lEnd  )

	RestArea( aArea )

Return( Nil )

/*/{Protheus.doc} GeraRelatorio
Rotina de processamento de comissões para :
Vendedor, Cobrador, Supervisor e Gerente 
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
/*/

Static Function GeraRelatorio( cNumeroOS, aDados, oPrintOS, nLin, oProcess, lEnd  )

	Local aArea         := GetArea()
	Local aTotCartao    := {}
	Local nI            := 0

	Default cNumeroOS   := ""
	Default aDados      := {}
	Default nLin        := 0
	Default lEnd        := .F.

	// tela de processamento
	oProcess:SetRegua1( 4 )
	oProcess:IncRegua1( "Realizando a impressão do relatório..." )

	// faco a impressao do cabecalho
	Cabecalho( cNumeroOS, @oPrintOS, @nLin, @oProcess, @lEnd )
	nLin+=40

	// faco a impressao dos dados do obito
	ImpDadosObito( aDados[1][1], @oPrintOS, @nLin, @oProcess, @lEnd )

	nLin+=60

	oPrintOS:Line(nLin, nMargemL, nLin, nMargemR)

	nLin+=60

	// faco a impressao dos itens
	ImpItenServicos( aDados[1][2], @oPrintOS, @nLin, @oProcess, @lEnd )

	nLin+=60

	oPrintOS:Line(nLin, nMargemL, nLin, nMargemR)

	nLin+=60

	// faco a impressao das observacoes
	ImpObservacoes( aDados[1][3], @oPrintOS, @nLin, @oProcess, @lEnd )

	nLin+=60

	oPrintOS:Line(nLin, nMargemL, nLin, nMargemR)

	nLin+=60

	// faco a impressao dos agentes
	ImpProfissionais( aDados[1][4], @oPrintOS, @nLin, @oProcess, @lEnd )

	nLin+=60

	oPrintOS:Line(nLin, nMargemL, nLin, nMargemR)

	nLin+=60

	// faco a impressao do rodape
	ImpRodape( @oPrintOS, @nLin )

	oPrintOS:Print()

Return( Nil )

/*/{Protheus.doc} Cabecalho
Rotina de processamento de comissões para :
Vendedor, Cobrador, Supervisor e Gerente 
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
/*/

Static Function Cabecalho( cNumeroOS, oPrintOS, nLin, oProcess, lEnd )

	Local aArea         := GetArea()
	Local cLogoRel      := SuperGetMV("MV_XLOGOOS", .F.,"logoos.png")
	Local nLogoLargura  := SuperGetMV("MV_XLARGOS", .F., 150)
	Local nLogoAltura   := SuperGetMV("MV_XALTUOS", .F., 150)

	Default cNumeroOS   := ""
	Default nLin        := 0
	Default lEnd        := .F.

	oProcess:SetRegua2( 1 )
	oProcess:IncRegua2( "Imprimindo o cabecalho..." )

	oPrintOS:StartPage() // Inicia uma nova pagina

	oPrintOS:Line(nLin, nMargemL, nLin, nMargemR)

	nLin+=20

	// impressao da logo
	oPrintOS:SayBitmap( nLin, nMargemL, cLogoRel, nLogoLargura, nLogoAltura)

	nLin+=10

	// impressao de data
	oPrintOS:Say( nLin, nMargemR-200, Dtoc( Date() ), oFont10N )
	nLin+=30

	// impressao de hora
	oPrintOS:Say( nLin, nMargemR-200, Time(), oFont10N )

	nLin+=60

	// impressao do titulo
	oPrintOS:Say( nLin, 650, "ORDEM DE SERVIÇO", oFont32N )

	nLin+=60

	oPrintOS:Line(nLin, nMargemL, nLin, nMargemR)

	nLin+=90

	// imprimo numero da ordem de servicos
	oPrintOS:Say( nLin, 750, "N° O.S.: " + cNumeroOS, oFont32N )

	nLin+=30

	oPrintOS:Line(nLin, nMargemL, nLin, nMargemR)

	RestArea( aArea )

Return( Nil )

/*/{Protheus.doc} ImpDadosObito
Impressao dos dados do obito
@author g.sampaio
@since 06/11/2019
@version P12
@param nulo
@return lRetorno, logico, retorno se os parametros foram importados corretamente
/*/

Static Function ImpDadosObito( aDadosObito, oPrintOS, nLin, oProcess, lEnd )

	Local nCol1         := nMargemL+20
	Local nCol2         := nMargemL+600
	Local nCol3         := nMargemL+1200
	Local nCol4         := nMargemL+1800

	Default aDadosObito := {}
	Default nLin        := 0
	Default lEnd        := .F.

	oProcess:SetRegua2( 1 )
	oProcess:IncRegua2( "Imprimindo dados do obito..." )

	// impressao do titulo
	oPrintOS:Say( nLin, nMargemL, "DADOS ÓBITO", oFont14N )
	nLin+=20

	// faco a impressao do box de dados do obito
	oPrintOS:Box( nLin, nMargemL, nLin+350, nMargemR )
	nLin+=30

	// Linha 1
	oPrintOS:Say( nLin, nCol1, "TP SERVICO:", oFont10N )
	oPrintOS:Say( nLin, nCol1+200, aDadosObito[1], oFont10 )

	oPrintOS:Say( nLin, nCol2, "CONTRATO:", oFont10N )
	oPrintOS:Say( nLin, nCol2+180, aDadosObito[2], oFont10 )

	oPrintOS:Say( nLin, nCol3, "PLANO:", oFont10N )
	oPrintOS:Say( nLin, nCol3+130, aDadosObito[3], oFont10 )

	nLin+=40

	// Linha 2
	oPrintOS:Say( nLin, nCol1, "FALECIDO:", oFont10N )
	oPrintOS:Say( nLin, nCol1+180, aDadosObito[5], oFont10 )

	oPrintOS:Say( nLin, nCol3, "C.P.F.:", oFont10N )
	oPrintOS:Say( nLin, nCol3+100, TransForm( aDadosObito[6], "@R 999.999.999-99" ), oFont10 )

	oPrintOS:Say( nLin, nCol4, "CARÊNCIA:", oFont10N )
	oPrintOS:Say( nLin, nCol4+180, aDadosObito[4], oFont10 )

	nLin+=40

	// Linha 3
	oPrintOS:Say( nLin, nCol1, "RELIGIÃO:", oFont10N )
	oPrintOS:Say( nLin, nCol1+160, aDadosObito[7], oFont10 )

	oPrintOS:Say( nLin, nCol2, "PESO(KG):", oFont10N )
	oPrintOS:Say( nLin, nCol2+150, TrataTipo(aDadosObito[8]), oFont10 )

	oPrintOS:Say( nLin, nCol3, "ALTURA(M):", oFont10N )
	oPrintOS:Say( nLin, nCol3+200, TrataTipo(aDadosObito[9]), oFont10 )
	nLin+=40

	// Linha 4
	oPrintOS:Say( nLin, nCol1, "LOCAL DA REMOÇÃO:", oFont10N )
	oPrintOS:Say( nLin, nCol1+320, aDadosObito[10], oFont10 )
	nLin+=40

	// Linha 5
	oPrintOS:Say( nLin, nCol1, "CIDADE:", oFont10N )
	oPrintOS:Say( nLin, nCol1+140, aDadosObito[11], oFont10 )

	oPrintOS:Say( nLin, nCol2, "BAIRRO:", oFont10N )
	oPrintOS:Say( nLin, nCol2+160, aDadosObito[12], oFont10 )
	nLin+=40

	// linha 6
	oPrintOS:Say( nLin, nCol1, "PONTO DE REFERENCIA:", oFont10N )
	oPrintOS:Say( nLin, nCol1+370, aDadosObito[13], oFont10 )
	nLin+=40

	// linha 7
	oPrintOS:Say( nLin, nCol1, "RESPONSAVEL:", oFont10N )
	oPrintOS:Say( nLin, nCol1+250, aDadosObito[14], oFont10 )
	nLin+=40

	// linha 8
	oPrintOS:Say( nLin, nCol1, "TELEFONE1:", oFont10N )
	oPrintOS:Say( nLin, nCol1+200, aDadosObito[15], oFont10 )

	oPrintOS:Say( nLin, nCol2, "TELEFONE2:", oFont10N )
	oPrintOS:Say( nLin, nCol2+200, aDadosObito[16], oFont10 )
	nLin+=40

Return( Nil )

/*/{Protheus.doc} ImpItenServicos
Impressao dos itens e servicos
@author g.sampaio
@since 06/11/2019
@version P12
@param nulo
@return lRetorno, logico, retorno se os parametros foram importados corretamente
/*/

Static Function ImpItenServicos( aDadosItenServicos, oPrintOS, nLin, oProcess, lEnd )

	Local aColunas              := {;
		{0, 250},;
		{250, 400},;
		{400, 1400},;
		{1400, 1600},;
		{1600, 1900},;
		{1900, nMargemR}}
	Local aTitulos              := {"ORD","COD","DESCRIÇÃO","QTD","V.UN","VALOR" }
	Local nCol1                 := nMargemL+20
	Local nCol2                 := nMargemL+600
	Local nCol3                 := nMargemL+1200
	Local nCol4                 := nMargemL+1800
	Local nTotOS                := 0
	Local nI                    := 0
	Local nJ                    := 0

	Default aDadosItenServicos  := {}
	Default nLin                := 0
	Default lEnd                := .F.

	oProcess:SetRegua2( 1 )
	oProcess:IncRegua2( "Imprimindo itens e servicos..." )

	// impressao do titulo
	oPrintOS:Say( nLin, nMargemL, "ITENS/SERVIÇOS", oFont14N )
	nLin+=20

	// cabecalho
	For nI := 1 To Len( aColunas )

		oPrintOS:Box( nLin, aColunas[nI,1], nLin+50, iif(nI==len(aColunas), aColunas[nI,2], aColunas[nI,2]+1) )
		oPrintOS:Say( nLin+35, aColunas[nI,1]+5, aTitulos[nI], oFont10N )

	Next nI

	nLin+=50

	// percorro o array de pedidos
	For nJ := 1 To Len( aDadosItenServicos )

		// totalizadores
		nTotOS  += aDadosItenServicos[nJ, 6]

		// percorro as colunas para impressao
		For nI := 1 To Len( aColunas )

			// faco a impressao dos detalhes do pedido
			oPrintOS:Box( nLin, aColunas[nI,1], nLin+50, iif(nI==len(aColunas), aColunas[nI,2], aColunas[nI,2]+1) )
			oPrintOS:Say( nLin+35, aColunas[nI,1]+5, TrataTipo( aDadosItenServicos[nJ, nI] ), oFont10 )

		Next nI

		// verifico se preciso realizar a impressao de um novo relatorio
		If nLin+100 > nLinRodPe
			ImpNovaPagina( @oPrintOS, @nLin )
		EndIf

		nLin+=50

	Next nJ

	nLin+=50

	// imprime o totalizador
	oPrintOS:Say( nLin, 1600,"TOTAL A RECEBER", oFont10N )
	oPrintOS:Say( nLin, 1900,TrataTipo( nTotOS ), oFont10N )

Return( Nil )

/*/{Protheus.doc} ImpObservacoes
Faco a validacao dos parametros
@author g.sampaio
@since 06/11/2019
@version P12
@param nulo
@return lRetorno, logico, retorno se os parametros foram importados corretamente
/*/

Static Function ImpObservacoes( cObservacoes, oPrintOS, nLin, oProcess, lEnd )

	Local aDados	:= {}
	Local nAtual	:= 0
	Local nLenBox 	:= 0

	Default cObservacoes    := ""
	Default nLin            := 0
	Default lEnd            := .F.

	// impressao do titulo
	oPrintOS:Say( nLin, nMargemL, "OBSERVACOES", oFont14N )
	nLin+=20

	//Agora será utilizado nossa zMemoToA, que quebra além dos -Enters-, qualquer expressão procurada, como por exemplo ';' (o que difere ela da função padrão MemoLine)
	if !empty(cObservacoes)
		aDados := ImpMemo(cObservacoes, 130, , .T.)

		if Len(aDados) > 5
			nLenBox := 200 + ( (Len(aDados)-5) * 50 )
		endIf

	endIf

	// faco a impressao do box de observacoes
	oPrintOS:Box( nLin, nMargemL, nLin+nLenBox, nMargemR )
	nLin+=10

	//Percorrendo as linhas geradas
	For nAtual := 1 To Len(aDados)

		oPrintOS:Say( nLin+35, nMargemL+20, aDados[nAtual], oFont10 )		

		// verifico se preciso realizar a impressao de um novo relatorio
		If nLin+100 > nLinRodPe
			ImpNovaPagina( @oPrintOS, @nLin )
		EndIf

		nLin+=30

	Next nAtual

	// faco a impressao das observacoes
	//oPrintOS:Say( nLin+35, nMargemL+20, cObservacoes, oPrintOS )

	nLin+=200

Return( Nil )

/*/{Protheus.doc} ImpProfissionais
Faco a impressao dos profissionais da ordem de servicos
@author g.sampaio
@since 06/11/2019
@version P12
@param nulo
@return lRetorno, logico, retorno se os parametros foram importados corretamente
/*/

Static Function ImpProfissionais( aProfOS, oPrintOS, nLin, oProcess, lEnd )

	Default aProfOS         := {}
	Default nLin            := 0
	Default lEnd            := .F.

	// agente 01
	oPrintOS:Say( nLin, nMargemL+20, "AGENTE01:", oFont10N )
	oPrintOS:Say( nLin, nMargemL+220, aProfOS[1], oFont10 )

	oPrintOS:Say( nLin, nMargemL+1600, "ATENDENTE:", oFont10N )
	oPrintOS:Say( nLin, nMargemL+1800, aProfOS[5], oFont10 )
	nLin+=40

	// agente 02
	oPrintOS:Say( nLin, nMargemL+20, "AGENTE02:", oFont10N )
	oPrintOS:Say( nLin, nMargemL+220, aProfOS[2], oFont10 )
	nLin+=40

	// veiculo 1
	oPrintOS:Say( nLin, nMargemL+20, "VEICULO:", oFont10N )
	oPrintOS:Say( nLin, nMargemL+220, aProfOS[3], oFont10 )
	nLin+=40

	// verifico se existe segundo veiculo
	If !Empty( AllTrim( aProfOS[4] ) )

		// veiculo 2
		oPrintOS:Say( nLin, nMargemL+20, "VEICULO2:", oFont10N )
		oPrintOS:Say( nLin, nMargemL+220, aProfOS[4], oFont10 )
		nLin+=40

	EndIf

Return( Nil )

/*/{Protheus.doc} Rodape
Faco a validacao dos parametros
@author g.sampaio
@since 04/09/2019
@version P12
@param nulo
@return lRetorno, logico, retorno se os parametros foram importados corretamente
/*/

Static Function ImpRodape( oPrintOS, nLin )

	Local aDadosEmp := {}

	Default nLin    := 0

	// pego a posicao da linha do rodape
	nLin := nLinRodPe

	// pego as informacoes da empresa
	aDadosEmp   := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_NOMECOM", "M0_CGC", "M0_ENDCOB", "M0_BAIRCOB", "M0_CIDCOB", "M0_ESTCOB" } )

	oPrintOS:Line(nLin, nMargemL, nLin, nMargemR)
	nLin+=30

	oPrintOS:Say(nLin, nMargemR-200, "Pagina: " + strzero(nPag++,3), oFont9)

	// imprimo os dados da empresa
	If Len( aDadosEmp ) == 6

		// nome da empresa + cnpj
		oPrintOS:Say(nLin, nMargemL+20, AllTrim( aDadosEmp[1][2] ) + " - " + TransForm( aDadosEmp[2][2], "@R 99.999.999/9999-99" ) , oFont9N)

		nLin+=30

		// endereco + bairro + cidade/uf
		oPrintOS:Say(nLin, nMargemL+20, AllTrim( aDadosEmp[3][2] ) + " - " + AllTrim( aDadosEmp[4][2] ) + " - " + AllTrim( aDadosEmp[5][2] ) + "/" + AllTrim( aDadosEmp[6][2] ) , oFont9N)

	EndIf

	oPrintOS:EndPage() //finaliza pagina

Return( Nil )

/*/{Protheus.doc} ImpNovaPagina
Faco a validacao dos parametros
@author g.sampaio
@since 04/09/2019
@version P12
@param nulo
@return lRetorno, logico, retorno se os parametros foram importados corretamente
/*/

Static Function ImpNovaPagina( oPrintOS, nLin )

	Default nLin    := 0
	Default lEnd    := .F.

	ImpRodape( oPrintOS, nLin )
	oPrintOS:StartPage() // Inicia uma nova pagina
	nLin := 0

Return( Nil )

/*/{Protheus.doc} TrataTipo
Faco a validacao dos parametros
@author g.sampaio
@since 05/11/2019
@version P12
@param nulo
@return lRetorno, logico, retorno se os parametros foram importados corretamente
/*/

Static Function TrataTipo( xTipo )

	Local xRetorno := Nil

	Default xTipo   := Nil

	Do Case
	Case AllTrim(ValType(xTipo)) == "D"
		xRetorno := DtoC( StoD( xTipo ) )
	Case AllTrim(ValType(xTipo)) == "N"
		xRetorno := AllTrim( TransForm( xTipo, "@E 999,999,999.99" ) )
	Case xTipo == Nil
		xRetorno := ""
	Otherwise
		xRetorno := xTipo
	EndCase

Return(xRetorno)

/*/{Protheus.doc} TipoServico
Faco a validacao dos parametros
@author g.sampaio
@since 06/11/2019
@version P12
@param nulo
@return lRetorno, logico, retorno se os parametros foram importados corretamente
/*/

Static Function TipoServico( cTpServico )

	Local aArea		    := GetArea()
	Local aOpcao	    := {}
	Local cRetorno 	    := ""
	Local cOpcao	    := ""
	Local nPos 		    := 0

	Default cTpServico	:= ""

	// pego o conteudo do campo X3_CBOX do campo UJ0_TPSERV
	cOpcao 	:= GetSx3Cache("UJ0_TPSERV","X3_CBOX")

	// alimento o array de dados
	aOpcao	:= StrToKarr( cOpcao, ";" )

	// pego os dados a posicao do tipo de servico para buscar a descricao conforme na X3_CBOX
	nPos 	:= aScan( aOpcao, { |x| SubStr( x, 1, 1 ) == cTpServico } )

	// verifico se encontrei o tipo de servico
	If nPos > 0

		// pego o array de opcao
		cRetorno := Upper( SubStr( aOpcao[nPos], AT("=", aOpcao[nPos])+1 ) )

	EndIf

Return( cRetorno )

/*/{Protheus.doc} ImpMemo
Quebra de campo memo
@type function
@version 1.0 
@author g.sampaio
@since 08/02/2022
@param cTexto, character, texto do campo memo
@param nMaxCol, numeric, maximo de colunas
@param cQuebra, character, quebra
@param lTiraBra, logical, indica se tiro os espacos em branco
@return array, retprna as quebras do texto
/*/
Static Function ImpMemo(cTexto, nMaxCol, cQuebra, lTiraBra)

	Local aTexto    := {}
	Local aAux      := {}
	Local nAtu      := 0

	Default cTexto  := ''
	Default nMaxCol := 80
	Default cQuebra := ';'
	Default lTiraBra:= .T.

	//Quebrando o Array, conforme -Enter-
	aAux := StrTokArr(cTexto,Chr(13))

	//Correndo o Array e retirando o tabulamento
	For nAtu:=1 TO Len(aAux)
		aAux[nAtu] := StrTran(aAux[nAtu],Chr(10),'')
	Next

	//Correndo as linhas quebradas
	For nAtu:=1 To Len(aAux)

		//Se o tamanho de Texto, for maior que o número de colunas
		If (Len(aAux[nAtu]) > nMaxCol)

			//Enquanto o Tamanho for Maior
			While (Len(aAux[nAtu]) > nMaxCol)
				//Pegando a quebra conforme texto por parâmetro
				nUltPos:=RAt(cQuebra,SubStr(aAux[nAtu],1,nMaxCol))

				//Caso não tenha, a última posição será o último espaço em branco encontrado
				If nUltPos == 0
					nUltPos:=Rat(' ',SubStr(aAux[nAtu],1,nMaxCol))
				EndIf

				//Se não encontrar espaço em branco, a última posição será a coluna máxima
				If(nUltPos==0)
					nUltPos:=nMaxCol
				EndIf

				//Adicionando Parte da Sring (de 1 até a Úlima posição válida)
				aAdd(aTexto,SubStr(aAux[nAtu],1,nUltPos))

				//Quebrando o resto da String
				aAux[nAtu] := SubStr(aAux[nAtu], nUltPos+1, Len(aAux[nAtu]))
			EndDo

			//Adicionando o que sobrou
			aAdd(aTexto,aAux[nAtu])
		Else
			//Se for menor que o Máximo de colunas, adiciona o texto
			aAdd(aTexto,aAux[nAtu])
		EndIf
	Next

	//Se for para tirar os brancos
	If lTiraBra
		//Percorrendo as linhas do texto e aplica o AllTrim
		For nAtu:=1 To Len(aTexto)
			aTexto[nAtu] := Alltrim(aTexto[nAtu])
		Next
	EndIf

Return(aTexto)
