#include "totvs.ch"
#include "tbiconn.ch"
#include "topconn.ch"

#DEFINE TIT_SELE  1			// Posicao logica.
#DEFINE TIT_PREF  2			// Prefixo do titulo.
#DEFINE TIT_NUME  3			// Titulo.
#DEFINE TIT_PARC  4			// Parcela.
#DEFINE TIT_VREA  5			// Vencimento real.
#DEFINE TIT_VALO  6			// Valor.
#DEFINE TIT_MULT  7			// Multa.
#DEFINE TIT_JURO  8			// Juros.
#DEFINE TIT_DESC  9			// Desconto.
#DEFINE TIT_RECE 10			// Recebimento.
#DEFINE TIT_TIPO 11 		// Tipo.
#DEFINE TIT_CONT 12			// Contrato.
#DEFINE TIT_CLIE 13			// Cliente.
#DEFINE TIT_LOJA 14			// Loja.
#DEFINE TIT_FILI 15       	// Filial.
#DEFINE TIT_RECN 16			// Recno.
#DEFINE TIT_ACRS 17			// Acrescimo financeiro.
#DEFINE TIT_CACR 18			// Posicao logica.
#DEFINE TIT_ABAT 19			// Abatimentos.
#DEFINE TIT_VENC 20			// Vencimento original.
#DEFINE TIT_LOCK 21			// Cod de uso do Registro
#DEFINE TIT_MOED 22			// Codigo da moeda do titulo
#DEFINE TIT_INTE 23			// Interes (Juros) - Posicao reservada
#DEFINE TIT_DTBX 24			// Dt. da baixa
#DEFINE TIT_SALD 25			// Saldo do titulo
#DEFINE TIT_VLIQ 26			// Valor Liquido

#DEFINE TEF_DISCADO             "4"
#DEFINE TEF_CLISITEF		 	"6"		//Utiliza a DLL CLISITEF
#DEFINE _FORMATEF				"CC;CD" //Formas de pagamento que utilizam operação TEF para validação
#DEFINE _FORMAPGDG				"PD/PX"	//Forma de pagamento considerado Pagamento Digital

Static lFinancComp //Controla se o SE1 e SE5 sao compartilhados
Static cCartao
Static cSerieRec	:= "" // Essa variavel era inicializada por Criavar("EL_SERIE" )
Static cRecibo		:= "" // Essa variavel era inicializada por Criavar("EL_RECIBO" )

Static aTitBxSE5
Static aTitDelSE5
Static cOper         := "1"				// Operacao
Static aTitVazio	 := {  .F.,;		// 1. Posicao logica.
"",;		// 2. Prefixo do titulo.
"",;		// 3. Titulo.
"",;		// 4. Parcela.
CToD(""),;	// 5. Vencimento real.
0,;			// 6. Valor.
0,;			// 7. Multa.
0,;			// 8. Juros.
0,;			// 9. Desconto.
0,;			// 10. Recebimento.
"",;		// 11. Tipo.
"",;		// 12. Contrato.
"",;		// 13. Cliente.
"",;		// 14. Loja.
"",;		// 15. Filial.
0,;			// 16. RecNo.
0,;			// 17. Acrescimo financeiro.
.F.,;		// 18. Posicao logica.
0,;			// 19. Abatimento.
CToD(""),;	// 20. Vencimento original.
"",;		// 21. Chave do registro
1 ,;		// 22. Codigo da moeda do titulo
0 ,;		// 23. Interes (Juros) - Posicao reservada
CToD(""),;	// 24. Data da Baixa
0 ,;		// 25. Saldo do titulo
0	}		// 26. Valor Liquido (ultimo valor baixado)

Static nModOrigem := 0		// Indica o codigo do Modulo de origem usando em web service
Static nOpSelBxa    := 0	// Guarda opcao com a sequencia a ser considerada no SE5, que foi escolhida pelo usuario no estorno da Recebimento
Static lLojxRec		:= .F.	// Utilizada na funcao A040DupRec para verificar se esta sendo recebido um titulo
Static lRecebNFCE   := nil	// Controle de Performance - função LjModNFis()

User Function RUTILE23()
Return(Nil)

/*/{Protheus.doc} VirtusFin
Classe com funcoes uteis do financeiro
para a Plataforma Virtus
@type Method
@version 1.0
@author g.sampaio
@since 05/03/2020
@history 25/05/2020, g.sampaio, manutenção no metodo ExcBordTit()
/*/
	Class VirtusFin

		Public Data aDadosEntrada		as Array
		Public Data aDadosParcelas		as Array
		Public Data aDadosRateio		as Array
		Public Data aDadosE1			as Array
		Public Data aDadosEV			as Array
		Public Data cCodContrato		as Character
		Public Data cCodCliente			as Character
		Public Data cCodLojaCliente		as Character
		Public Data cCodNatureza		as Character
		Public Data cPrefixo			as Character
		Public Data cTipoTitulo			as Character
		Public Data cTipoEntrada		as Character
		Public Data cFormaPagto			as Character
		Public Data dDataEntrada		as Date
		Public Data dPrimeiroVencto		as Date
		Public Data dDataCadastro		as Date
		Public Data lRetorno			as Logical
		Public Data lRecorrencia		as Logical
		Public Data lCemiterio    		as Logical
		Public Data lFuneraria    		as Logical
		Public Data nPercJuros			as Numeric
		Public Data nTaxaPermanencia	as Numeric
		Public Data nQtdParcelas		as Numeric
		Public Data nValorContrato		as Numeric
		Public Data nValorEntrada		as Numeric
		Public Data nPercRateio			as Numeric
		Public Data nValFinancParcela	as Numeric

		Method New() Constructor	            // metodo Construtor
		Method VldCobranca()					// metodo para validar se o titulo esta cobranca no Call Center(SK1)
		Method RetJurosTitulo()					// metodo para retornar o valor de juros do titulo
		Method RetMultaTitulo()					// metodo para retornar o valor de multa do titulo
		Method RetSaldoTitulo()					// metodo para retornar o saldo do titulo
		Method RetValortitulo()					// metodo para retornar o valor do titulo com acrescimo e decrescimo
		Method ExcBordTit()						// metodo para excluir o titulo do bordero
		Method MarcaExcessaoSK1()				// metodo para marcar o titulo como excessao na SK1
		Method LimpaBorderoCemiterio()			// metodo para limpar os dados do bordero para os contratos em suspensao
		Method BaixaFatura()					// metodo para a baixa de titulos de liquidacao ou fatura
		Method ExcluiTituloFin()				// metodo para a exclusao de titulos no financeiro
		Method ExecLiquidacao()					// metodo para executar a rotina de liquidacao
		Method ContratoAdimplente()             // metodo para verificar se o contrato esta em dias
		Method RetValParcelasFinanciamento()    // metodo para retornar o valor da parcelaa do financiamento
		Method GeraInstruBxCobranca()           // metodo para gerar as instrucoes de baixa do boleto no banco
		Method CRContratoCemiterio()			// metodo para tratar o financeiro do contas a receber do contrato de cemiterio
		Method GetRateioCemiterio() 			// metodo para retornar o rateio de multiplas naturezas para o contrato de cemiterio
		Method GetParcelasCemiterio()			// metodo para tratar as parcelas do financeiro do contrato
		Method GeraFinanceiroCR()				// metodo para gerar os titulos no financeiro
		Method ValidaRateio()					// metodo para validar o rateio de multiplas naturezas
		Method ExcluiMultiNatLiquidacao()		// metodo para excluir o rateio de multiplas naturezas da liquidacao
		Method SeekSE1()						// metodo para posicionar na SE1 atual
		Method ULJRecBX()						// metodo para baixar recebimento de título via loja (LjRecBXSE1)
		Method ULJEstBX()						// metodo para o estorno de baixas (STReverseDropTitles)
		Method RemoveDesconto()					// metodo para remover o desconto do titulo

	EndClass

/*/{Protheus.doc} New
Metodo construtor
@type Method
@version 1.0
@author g.sampaio
@since 05/03/2020
/*/
Method New() Class VirtusFin

	Local aArea := GetArea()

	// incio as variaveis utilizadas na classe
	::aDadosEntrada		:= {}
	::aDadosParcelas	:= {}
	::aDadosRateio		:= {}
	::aDadosE1			:= {}
	::aDadosEV			:= {}
	::cCodContrato		:= ""
	::cCodCliente		:= ""
	::cCodLojaCliente	:= ""
	::cCodNatureza		:= ""
	::cPrefixo			:= ""
	::cTipoTitulo		:= ""
	::cTipoEntrada		:= ""
	::cFormaPagto		:= ""
	::dDataEntrada		:= Stod("")
	::dPrimeiroVencto	:= Stod("")
	::dDataCadastro		:= Stod("")
	::lRetorno 			:= .T.
	::lRecorrencia		:= SuperGetMv("MV_XATVREC",.F.,.F.)
	::lCemiterio    	:= SuperGetMv("MV_XCEMI",.F.,.F.)
	::lFuneraria    	:= SuperGetMv("MV_XFUNE",.F.,.F.)
	::nPercJuros		:= 0
	::nQtdParcelas		:= 0
	::nValorContrato	:= 0
	::nValorEntrada		:= 0
	::nValFinancParcela	:= 0
	::nTaxaPermanencia	:= SuperGetMv("MV_TXPER",.F.,0)

	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} VirtusFin::VldCobranca
Funcao para validar se o titulo esta 
em cobranca
@type method
@version 1.0
@author g.sampaio
@since 05/03/2020
@param cFiltTit, character, param_description
@param cPrefixo, character, param_description
@param cTitulo, character, param_description
@param cParcela, character, param_description
@param cTipo, character, param_description
@param cCodConv, character, param_description
@return return_type, return_description
/*/
Method VldCobranca( cTipoMod, cFiltTit, cCodContrato, cPrefixo, cTitulo, cParcela, cTipo ) Class VirtusFin

	Local aArea		        := GetArea()
	Local aAreaSE1	        := SE1->( GetArea() )
	Local aAreaSK1	        := SK1->( GetArea() )
	Local cQry 		        := ""

	Default cTipoMod        := ""
	Default cFiltTit        := ""
	Default cCodContrato    := ""
	Default cPrefixo        := ""
	Default cTitulo         := ""
	Default cParcela        := ""
	Default cTipo           := ""

	// se o alias ja existir encero ele
	If Select("QRYCOB") > 0
		QRYCOB->(DbCloseArea())
	Endif

	// query de consulta no banco de dados
	cQry	:= " SELECT COUNT(*) QTD_COB "
	cQry 	+= " FROM "
	cQry	+= " 	" + RetSQLName("SK1") + " COBRANCA "
	cQry	+= " INNER JOIN "
	cQry 	+= "	" + RetSQLName("SE1") + " TITULO "
	cQry	+= " ON COBRANCA.D_E_L_E_T_ = ' ' "
	cQry	+= " AND TITULO.D_E_L_E_T_ = ' ' "
	cQry	+= " AND COBRANCA.K1_FILORIG    = TITULO.E1_FILIAL "
	cQry	+= " AND COBRANCA.K1_PREFIXO    = TITULO.E1_PREFIXO "
	cQry	+= " AND COBRANCA.K1_NUM        = TITULO.E1_NUM "
	cQry	+= " AND COBRANCA.K1_PARCELA    = TITULO.E1_PARCELA "
	cQry	+= " AND COBRANCA.K1_TIPO       = TITULO.E1_TIPO "
	cQry	+= " WHERE "
	cQry	+= " 	TITULO.E1_FILIAL = '" + cFiltTit + "' "

	// verifico se e convalescencia
	If !Empty(cCodContrato) .And. cTipoMod == "C"
		cQry	+= " AND TITULO.E1_XCONCTR	= '" + cCodContrato + "' " //-- Contrato Convalescencia
	elseIf !Empty(cCodContrato) .And. cTipoMod == "F"
		cQry	+= " AND TITULO.E1_XCTRFUN	= '" + cCodContrato + "' " //-- Contrato Convalescencia
	EndIf

	// verifico se o prefixo esta preenchida+
	If !Empty(cPrefixo)
		cQry	+= " 	AND TITULO.E1_PREFIXO = '" + cPrefixo + "' "
	EndIf

	// verifico se o numero esta preenchida
	If !Empty(cTitulo)
		cQry 	+= " 	AND TITULO.E1_NUM = '" + cTitulo + "' "
	EndIf

	// verifico se a parcela esta preenchida
	If !Empty(cParcela)
		cQry 	+= " 	AND TITULO.E1_PARCELA = '" + cParcela + "' "
	EndIf

	// verifico se o tipo esta preenchida
	If !Empty(cTipo)
		cQry 	+= " 	AND TITULO.E1_TIPO = '" + cTipo + "' "
	EndIf

	cQry 	+= " 	AND COBRANCA.K1_OPERAD	<> 'XXXXXX' " //XXXXXX Titulo marcado como excecao na cobranca

	// se o alias ja existir encero ele
	If Select("QRYCOB") > 0
		QRYCOB->(DbCloseArea())
	Endif

	cQry := ChangeQuery(cQry)

	TcQuery cQry NEW Alias "QRYCOB"

	// verifico se o alias tem dados
	If QRYCOB->(!Eof())

		// verifico se existem cobrancas
		If QRYCOB->QTD_COB > 0
			::lRetorno := .F.
		endif

	EndIf

	RestArea(aArea)
	RestArea(aAreaSE1)
	RestArea(aAreaSK1)

Return(::lRetorno)

/*/{Protheus.doc} VirtusFin::RetSaldoTitulo
Funcao para retornar o saldo atual do titulo
@type method
@version 1.0
@author g.sampaio
@since 19/03/2020
@param dDataAgenda, date, data de pagamento
@return numeric, saldo do titulo
/*/
Method RetSaldoTitulo(dDataAgenda) Class VirtusFin

	Local aArea		    := GetArea()
	Local aAreaSE1	    := SE1->(GetArea())
	Local nValor	    := 0
	Local nJuros	    := 0
	Local nMulta	    := 0
	Local nSaldoAt	    := 0
	Local nVlrAbat		:= 0

	Default dDataAgenda := dDatabase

	// abro a tabela corrente
	DbSelectArea("SE1")

	//retorna o saldo do titulo naquela data
	nValor := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,;
		SE1->E1_MOEDA,,dDataAgenda,SE1->E1_LOJA,,,1)

	// caso nao for maior que zero
	if .NOT. nValor > 0
		nValor := SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE
	endIf

	// verifico se tem saldo em aberto
	If nValor > 0

		// juros do titulo
		nJuros  := ::RetJurosTit(dDataAgenda)

		// juros do titulo
		nMulta  := ::RetMultaTit(dDataAgenda)

		// retorna o valor total de abatimentos
		nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

		//Saldo Atual do Titulo considerando Juros e Multa
		nSaldoAt := nValor + nJuros + nMulta - nVlrAbat

	EndIf

	RestArea(aArea)
	RestArea(aAreaSE1)

Return(nSaldoAt)

Method RetValortitulo() Class VirtusFin

	Local aArea		    := GetArea()
	Local aAreaSE1	    := SE1->(GetArea())
	Local nJuros	    := 0
	Local nMulta	    := 0
	Local nRetorno	    := 0
	Local nVlrAbat		:= 0

	Default dDataAgenda := dDatabase

	// abro a tabela corrente
	DbSelectArea("SE1")

	// juros do titulo
	nJuros  := ::RetJurosTitulo(dDataAgenda)

	// juros do titulo
	nMulta  := ::RetMultaTitulo(dDataAgenda)

	// retorna o valor total de abatimentos
	nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

	//Saldo Atual do Titulo considerando Juros e Multa
	nRetorno := SE1->E1_VALOR + SE1->E1_ACRESC + nJuros + nMulta - nVlrAbat - SE1->E1_DECRESC

	RestArea(aArea)
	RestArea(aAreaSE1)

Return(nRetorno)

/*/{Protheus.doc} VirtusFin::RetMultaTitulo
description
@type method
@version 
@author g.sampaio
@since 19/03/2020
@param dDataAgenda, date, param_description
@return return_type, return_description
/*/
Method RetMultaTitulo(dDataAgenda) Class VirtusFin

	Local aArea		    := GetArea()
	Local aAreaSE1	    := SE1->(GetArea())
	Local nMulta	    := 0

	Default dDataAgenda := dDatabase

	//Retorna a Multa em caso de atraso
	nMulta := LojxRMul( .F., , ,SE1->E1_SALDO, SE1->E1_ACRESC, SE1->E1_VENCREA, dDataAgenda , , SE1->E1_MULTA, ,;
		SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, "SE1",.T. )

	RestArea( aAreaSE1 )
	RestArea( aArea )

Return(nMulta)

/*/{Protheus.doc} VirtusFin::RetJurosTitulo
description
@type method
@version 
@author g.sampaio
@since 19/03/2020
@param dDataAgenda, date, param_description
@return return_type, return_description
/*/
Method RetJurosTitulo(dDataAgenda) Class VirtusFin

	Local aArea		    := GetArea()
	Local aAreaSE1	    := SE1->(GetArea())
	Local dDtBkp        := stod("")
	Local nJuros	    := 0

	Default dDataAgenda := dDatabase

	// salvo a database
	dDtBkp      := dDatabase

	// altero a database para a data de agendamento
	dDatabase   := dDataAgenda

	//retorna Juros
	nJuros := LojxRJur(, , , ,  SE1->E1_SALDO,;
		SE1->E1_ACRESC  , "SE1", SE1->(Recno()), SE1->E1_MOEDA, dDataAgenda,SE1->E1_VENCREA, ,SE1->E1_JUROS)

	dDatabase   := dDtBkp

	RestArea( aAreaSE1 )
	RestArea( aArea )

Return(nJuros)

/*/{Protheus.doc} VirtusFin::ExcBordTit
Remove títulos de borderô
@type method
@version 1.0 
@author g.sampaio
@since 26/03/2020
@param nRecSE1, numeric, param_description
@return return_type, return_description
@history 25/05/2020, g.sampaio, VPDV-473 - Ajustado a declaracao do campo E1_FILIAL com o alias SE1
/*/
Method ExcBordTit(nRecSE1) Class VirtusFin
	Local aArea     := GetArea()
	Local aAreaSE1  := SE1->( GetArea() )
	Local aAreaSEA  := SEA->( GetArea() )
	Local lRetorno  := .T.

	Default nRecSE1 := 0

	// posiciono no registro do titulo a receber
	SE1->(DbGoTo(nRecSE1))

	//-- EA_FILIAL+EA_NUMBOR+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA
	SEA->(DbSetOrder(1))

	//-- Se houver borderô associado, exclui --//
	If SEA->(MsSeek(SE1->E1_FILIAL+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))

		If SEA->(RecLock("SEA",.F.))

			SEA->(DbDelete())
			SEA->(MsUnlock())

		EndIf

	EndIf

	if lRetorno

		// gero a instrucao de baixa do boleto no banco
		::GeraInstruBxCobranca(SE1->(Recno()))

		// limpo os campos da SE1
		SE1->(DbGoTo(nRecSE1))
		If SE1->(RecLock("SE1",.F.))

			SE1->E1_SITUACA	:= "0"
			SE1->E1_OCORREN	:= ""
			SE1->E1_NUMBCO	:= ""
			SE1->E1_NUMBOR	:= ""
			SE1->E1_PORTADO := ""
			SE1->E1_CONTA   := ""
			SE1->E1_AGEDEP  := ""
			SE1->E1_DATABOR	:= Stod("")
			SE1->(MsUnLock())

		EndIf

	endIf

	RestArea(aAreaSEA)
	RestArea(aAreaSE1)
	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} VirtusFin::MarcaExcessaoSK1
Funcao para validar se o contrato
possui titulos em cobranca
@type method
@version 
@author g.sampaio
@since 26/03/2020
@param cFiltTit, character, param_description
@param cContrato, character, param_description
@return return_type, return_description
/*/
Method MarcaExcessaoSK1( nRecnoSE1 ) Class VirtusFin

	Local aArea		    := GetArea()
	Local aAreaSE1	    := SE1->( GetArea() )
	Local aAreaSK1	    := SK1->( GetArea() )
	Local lContinua		:= .T.
	Local lRet		    := .T.
	Local cQry 		    := ""
	local cFiltTit    	:= ""
	Local cContrato   	:= ""
	Local nTipo       	:= 0 // 1 - Ctr. Cemiterio / 2 - Ctr. Funeraria

	If nRecnoSE1 > 0

		SE1->(DbGoto(nRecnoSE1))

		cFiltTit := SE1->E1_FILIAL

		If !Empty(SE1->E1_XCONTRA) // contrato de cemiterio
			cContrato := SE1->E1_XCONTRA
			nTipo     := 1
		ElseIf !Empty(SE1->E1_XCTRFUN)
			cContrato := SE1->E1_XCTRFUN
			nTipo     := 2
		Else
			lContinua := .F.
		EndIf

	EndIf

	///////////////////////////////////////////////////////////////
	///// CONSULTO SE O CONTRATO POSSUI TITULOS EM COBRANCA	//////
	//////////////////////////////////////////////////////////////

	// verifico se o contrato foi informado
	If lContinua .And. !Empty(AllTrim(cContrato))

		cQry 	:= " SELECT "
		cQry 	+= " K1_FILIAL FILIAL, "
		cQry 	+= " K1_PREFIXO PREFIXO, "
		cQry 	+= " K1_NUM NUMERO, "
		cQry 	+= " K1_PARCELA PARCELA, "
		cQry 	+= " K1_TIPO TIPO, "
		cQry 	+= " K1_FILORIG FILORIG "
		cQry	+= " FROM "
		cQry	+= + RetSQLName("SK1") + " COBRANCA
		cQry 	+= " INNER JOIN "
		cQry 	+= + RetSQLName("SE1") + " TITULO
		cQry 	+= " ON "
		cQry 	+= " COBRANCA.K1_PREFIXO = TITULO.E1_PREFIXO "
		cQry	+= " AND COBRANCA.K1_NUM 	= TITULO.E1_NUM "
		cQry	+= " AND COBRANCA.K1_PARCELA = TITULO.E1_PARCELA "

		// para contrato de cemiterio
		If nTipo == 1

			cQry	+= " AND TITULO.E1_XCONTRA 	= '" + cContrato + "' "

		ElseIf nTipo == 2 // para contrato de funeraria

			cQry	+= " AND TITULO.E1_XCTRFUN 	= '" + cContrato + "' "

		EndIf

		cQry	+= " AND TITULO.E1_FILIAL 	= '" + cFiltTit + "' "
		cQry	+= " AND TITULO.D_E_L_E_T_ 	= ' ' "
		cQry	+= " WHERE "
		cQry	+= "	COBRANCA.D_E_L_E_T_ = ' '"
		cQry	+= " 	AND COBRANCA.K1_FILORIG = '" + cFiltTit + "' "
		cQry 	+= " 	AND COBRANCA.K1_OPERAD	<> 'XXXXXX' " //XXXXXX Titulo marcado como excecao na cobranca

		If Select("QRYCOB") > 0
			QRYCOB->(DbCloseArea())
		Endif

		cQry := ChangeQuery(cQry)
		TcQuery cQry NEW Alias "QRYCOB"

		//valido se possui cobranca para o contrato
		if QRYCOB->(!Eof())

			SK1->(DbSetOrder(1)) //K1_FILIAL+K1_PREFIXO+K1_NUM+K1_PARCELA+K1_TIPO+K1_FILORIG

			While QRYCOB->(!Eof())

				//marco o titulo como excecao de cobranca, assim o mesmo estara apto para exclusao
				if SK1->(MsSeek(QRYCOB->FILIAL+QRYCOB->PREFIXO+QRYCOB->NUMERO+QRYCOB->PARCELA+QRYCOB->TIPO+QRYCOB->FILORIG))

					RecLock("SK1",.F.)
					SK1->K1_OPERAD := 'XXXXXX'
					SK1->(MsUnlock())

				endif

				QRYCOB->(DbSkip())

			EndDo

		endif

	EndIf

	RestArea(aArea)
	RestArea(aAreaSE1)
	RestArea(aAreaSK1)

Return(lRet)

/*/{Protheus.doc} VirtusFin::LimpaBorderoCemiterio
funcao para limpar o bordero de titulos
com contrato de cemiterio suspenso
@type method
@version 
@author g.sampaio
@since 31/05/2020
@param cContrato, character, codigo do contrato
@return nil
/*/
Method LimpaBorderoCemiterio( cContrato ) Class VirtusFin

	Local aArea         := GetArea()
	Local cQuery        := ""
	Local lConsVencOri  := SuperGetMv("MV_XVEORIS",.F.,.F.)

	Default cContrato   := ""

	If Select("TRBBOR") > 0
		TRBBOR->( DbCloseArea() )
	EndIf

	cQuery := "SELECT U00.U00_CODIGO, SE1.R_E_C_N_O_ RECSE1"
	cQuery += " FROM "+RetSqlName("U00")+" U00 INNER JOIN "+RetSqlName("SE1")+" SE1 ON U00.U00_CODIGO 	= SE1.E1_XCONTRA"
	cQuery += " 																		AND SE1.D_E_L_E_T_	<> '*'"
	cQuery += " 																		AND SE1.E1_FILIAL	= '"+xFilial("SE1")+"'"
	cQuery += " 																		AND SE1.E1_SALDO	> 0" //Em aberto

	// considero o vencimento original
	If lConsVencOri

		cQuery += " 																		AND SE1.E1_VENCORI	< '"+DToS(dDataBase)+"'"

	Else // vencimento real

		cQuery += " 																		AND SE1.E1_VENCREA 	< '"+DToS(dDataBase)+"'"

	EndIf

	cQuery += " WHERE U00.D_E_L_E_T_ 	<> '*'"
	cQuery += " AND U00.U00_FILIAL 	= '"+xFilial("U00")+"'"
	cQuery += " AND U00.U00_STATUS	= 'S'" //Suspenso
	cQuery += " AND U00.U00_CODIGO  = '" + cContrato + "'"

	cQuery := ChangeQuery(cQuery)

	TcQuery cQuery NEW Alias "TRBBOR"

	While TRBBOR->(!Eof())

		// manndo o recno do titulo para limpeza do bordero
		::ExcBordTit(TRBBOR->RECSE1)

		TRBBOR->( DbSkip() )
	EndDo

	If Select("TRBBOR") > 0
		TRBBOR->( DbCloseArea() )
	EndIf

	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} BxFatura
func
@type function
@version 
@author g.sampaio
@since 29/05/2020
@param nRecnoSE1, numeric, param_description
@return return_type, return_description
/*/
Method BaixaFatura(nRecnoSE1) Class VirtusFin

	Local aArea 	    := GetArea()
	Local aAreaSE1  	:= SE1->(GetArea())
	Local aBaixa	    := {}
	Local lRet		    := .T.

	Default nRecnoSE1   := 0

	Private lMsErroAuto := .F.

	DbSelectArea("SE1")
	SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(DbGoTo(nRecnoSE1))

	aBaixa := {;
		{"E1_PREFIXO"   ,SE1->E1_PREFIXO										,Nil},;
		{"E1_NUM"       ,SE1->E1_NUM											,Nil},;
		{"E1_PARCELA"   ,SE1->E1_PARCELA										,Nil},;
		{"E1_TIPO"      ,SE1->E1_TIPO											,Nil},;
		{"E1_CLIENTE" 	,SE1->E1_CLIENTE										,Nil},;
		{"E1_LOJA" 		,SE1->E1_LOJA											,Nil},;
		{"AUTMOTBX"     ,"DAC"													,Nil},;
		{"AUTDTBAIXA"   ,dDatabase												,Nil},;
		{"AUTDTCREDITO" ,dDatabase												,Nil},;
		{"AUTHIST"      ,"BAIXA POR CANCELAMENTO CEM"							,Nil},;
		{"AUTJUROS"     ,0      												,Nil,.T.},;
		{"AUTMULTA"     ,0      												,Nil,.T.},;
		{"AUTVALREC"    ,SE1->E1_SALDO	+ SE1->E1_SDACRES - SE1->E1_SDDECRE		,Nil}}

	MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3) //Baixa conta a receber

	// verifico se teve na baixa da fatura
	If lMsErroAuto

		MostraErro()

		lRet := .F.
		DisarmTransaction()

	endif

	RestArea(aArea)
	RestArea(aAreaSE1)

Return(lRet)

/*/{Protheus.doc} VirtusFin::ExcluiTituloFin
Funcao para exclusao do titulo
@type method
@version 1.0
@author g.sampaio
@since 29/05/2020
@param nRecSE1, numeric, param_description
@return return_type, return_description
/*/
Method ExcluiTituloFin( nRecSE1, oProcess, lEnd, cErro) Class VirtusFin

	Local aArea			:= GetArea()
	Local aAreaSE1		:= SE1->(GetArea())
	Local aFin040		:= {}
	Local lRet 			:= .T.

	Default nRecSE1     := 0
	Default cErro       := ""

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	DbSelectArea("SE1")

	// posiciono no registro do titulo
	SE1->(DbGoTo(nRecSE1))

	// verifico se o objeto existe
	If Type( "oProcess" ) <> "U"

		// atualizo a mensagem do processamento
		oProcess:IncRegua1( "Excluindo parcela do contrato " + SE1->E1_NUM + "/" + SE1->E1_PARCELA )

	EndIf

	AAdd(aFin040, {"E1_FILIAL"  , SE1->E1_FILIAL  	,Nil})
	AAdd(aFin040, {"E1_PREFIXO" , SE1->E1_PREFIXO 	,Nil})
	AAdd(aFin040, {"E1_NUM"     , SE1->E1_NUM	   	,Nil})
	AAdd(aFin040, {"E1_PARCELA" , SE1->E1_PARCELA	,Nil})
	AAdd(aFin040, {"E1_TIPO"    , SE1->E1_TIPO  	,Nil})

	MSExecAuto({|x,y| Fina040(x,y)},aFin040,5)

	// verifico se houve erro
	If lMsErroAuto

		lRet := .F.

		If !IsBlind()
			MostraErro()
		Else
			cErro := AllTrim( MostraErro('/temp') )
		EndIf

		DisarmTransaction()

	Else

		// verifico se o objeto existe
		If Type( "oProcess" ) <> "U"

			// atualizo a mensagem do processamento

			// tela de processamento
			oProcess:SetRegua2( 1 )
			oProcess:IncRegua2( "Parcela " + SE1->E1_NUM + "/" + SE1->E1_PARCELA + " excluída com sucesso!" )

		EndIf

	EndIf

	RestArea(aAreaSE1)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} VirtusFin::ExecLiquidacao
funcao para executar a rotina de liquidacao
conforme o tipo
nTipo : 1 - Gerar Liquidacao
2 - Visualizar / Detalhar
3 - Cancelar
cTipModulo : C - Cemiterio
F - Funeraria
@type method
@version 1.0
@author g.sampaio
@since 08/06/2020
@param nTipo, numeric, operacao
@param cTipModulo, character, modulo
@param cContrato, character, contrato
@param cPrefTit, character, prefixo de titulo
@param cNumTit, character, numero de titulo
@param cParcTit, character, parcela do titulo
@param cTipTit, character, tipo do tituilo
/*/
Method ExecLiquidacao( nTipo, cTipModulo, cContrato, cPrefTit, cNumTit, cParcTit, cTipTit ) Class VirtusFin

	Local aArea         := GetArea()
	Local aAreaSE1      := SE1->( GetArea() )
	Local aAreaFO0      := FO0->( GetArea() )
	Local aAreaU00      := {}
	Local aAreaUF2      := {}
	Local cCliente      := ""
	Local cLojaCli      := ""
	Local cBkpFunName	:= FunName()

	Private lOpcAuto    := .F.  // declaro a variavel private de execauto da FINA460 como falso

	Default nTipo       := 0
	Default cTipModulo  := ""
	Default cContrato   := ""
	Default cPrefTit    := ""
	Default cNumTit     := ""
	Default cParcTit    := ""
	Default cTipTit     := ""

	if ::lCemiterio  .And. cTipModulo == "C" // cemiterio

		aAreaU00 := U00->( GetArea() )

		U00->(DbSetOrder(1))
		if U00->( MsSeek( xFilial("U00")+cContrato ) )
			cCliente    := U00->U00_CLIENT
			cLojaCli    := U00->U00_LOJA
		endIf

		RestArea( aAreaU00 )

	elseIf ::lFuneraria .And. cTipModulo == "F" // funeraria

		aAreaUF2 := UF2->( GetArea() )

		UF2->(DbSetOrder(1))
		if UF2->( MsSeek( xFilial("UF2")+cContrato ) )
			cCliente    := UF2->UF2_CLIENT
			cLojaCli    := UF2->UF2_LOJA
		endIf

		RestArea( aAreaUF2 )

	endIf

	if nTipo == 1   // Gerar Liquidacao

		if ::lCemiterio  .And. cTipModulo == "C" // cemiterio

			// executo a rotina de liquidacao do cemiterio
			U_RCPGE034(cContrato)

		elseIf ::lFuneraria .And. cTipModulo == "F" // funeraria

			// executo a rotina de liquidacao do funeraria
			U_RFUNE043(cContrato)

		endIf

	elseIf nTipo == 2   // Visuliar/Detalhar Liquidacao

		// verifico se o alias esta ativo
		if Select("TRBSE1") > 0
			TRBSE1->( DbCloseArea() )
		endIf

		// query para identificar a liquidacao
		cQuery := " SELECT SE1.E1_FILIAL, SE1.E1_NUMLIQ "
		cQuery += " FROM " + RetSQLName("SE1") + " SE1 "
		cQuery += " WHERE SE1.D_E_L_E_T_    = ' ' "
		cQuery += " AND SE1.E1_FILIAL       = '" + xFilial("SE1") + "' "
		cQuery += " AND SE1.E1_PREFIXO      = '" + cPrefTit + "' "
		cQuery += " AND SE1.E1_NUM          = '" + cNumTit  + "' "
		cQuery += " AND SE1.E1_PARCELA      = '" + cParcTit + "' "
		cQuery += " AND SE1.E1_TIPO         = '" + cTipTit  + "' "
		cQuery += " AND SE1.E1_CLIENTE      = '" + cCliente + "' "
		cQuery += " AND SE1.E1_LOJA         = '" + cLojaCli + "' "
		cQuery += " AND SE1.E1_NUMLIQ       <> '' "

		if ::lCemiterio  .And. cTipModulo == "C" // cemiterio

			cQuery += " AND SE1.E1_XCONTRA      = '" + cContrato + "' "

		elseIf ::lFuneraria .And. cTipModulo == "F" // funeraria

			cQuery += " AND SE1.E1_XCTRFUN      = '" + cContrato + "' "

		endIf

		cQuery += " GROUP BY SE1.E1_FILIAL, SE1.E1_NUMLIQ "

		TcQuery cQuery New Alias "TRBSE1"

		// verifico se tem dados para a liquidacao
		If TRBSE1->(!Eof())

			// posiciono no cadastro da liquidacao
			FO0->( DbSetOrder(2) )
			if FO0->( MsSeek( xFilial("FO0")+TRBSE1->E1_NUMLIQ+cCliente+cLojaCli ) )

				// visualizar a liquidacao
				F460VerSim()

			endIf

		Else

			// mensagem para o usuario
			MsgAlert("Não existem liquidação para este contrato!")

		EndIf

		// verifico se o alias esta ativo
		if Select("TRBSE1") > 0
			TRBSE1->( DbCloseArea() )
		endIf

	elseIf nTipo == 3 .Or. nTipo == 4 // Cancelar

		// verifico se o alias esta ativo
		if Select("TRBSE1") > 0
			TRBSE1->( DbCloseArea() )
		endIf

		// query para identificar a liquidacao
		cQuery := " SELECT SE1.R_E_C_N_O_ RECSE1 "
		cQuery += " FROM " + RetSQLName("SE1") + " SE1 "
		cQuery += " WHERE SE1.D_E_L_E_T_    = ' ' "
		cQuery += " AND SE1.E1_FILIAL       = '" + xFilial("SE1") + "' "
		cQuery += " AND SE1.E1_PREFIXO      = '" + cPrefTit + "' "
		cQuery += " AND SE1.E1_NUM          = '" + cNumTit  + "' "
		cQuery += " AND SE1.E1_PARCELA      = '" + cParcTit + "' "
		cQuery += " AND SE1.E1_TIPO         = '" + cTipTit  + "' "
		cQuery += " AND SE1.E1_CLIENTE      = '" + cCliente + "' "
		cQuery += " AND SE1.E1_LOJA         = '" + cLojaCli + "' "
		cQuery += " AND SE1.E1_NUMLIQ       <> '' "

		if ::lCemiterio  .And. cTipModulo == "C" // cemiterio

			cQuery += " AND SE1.E1_XCONTRA      = '" + cContrato + "' "

		elseIf ::lFuneraria .And. cTipModulo == "F" // funeraria

			cQuery += " AND SE1.E1_XCTRFUN      = '" + cContrato + "' "

		endIf

		TcQuery cQuery New Alias "TRBSE1"

		// verifico se tem dados para a liquidacao
		If TRBSE1->(!Eof())

			// posiciono no titulo da liquidacao
			SE1->( DbGoTo(TRBSE1->RECSE1) )

			If nTipo == 3 // Cancelar Liquidacao

				SetFunName("FINA460")

				// crio o grupo de perguntas da rotina padrao
				pergunte("AFI460",.T.)

				FINA460(4,,,5,,SE1->E1_NUMLIQ,)

				SetFunName(cBkpFunName)


			ElseIf nTipo == 4 //Reliquidacao

				// chamo a rotina de reliquidacao
				FINA460(3)

			EndIf

		Else

			// mensagem para o usuario
			MsgAlert("Não existem liquidação para este contrato!")

		EndIf

		// verifico se o alias esta ativo
		if Select("TRBSE1") > 0
			TRBSE1->( DbCloseArea() )
		endIf

	endIf

	RestArea( aAreaFO0 )
	RestArea( aAreaSE1 )
	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} VirtusFin::ContratoAdimplente
metodo para verficar se para o contrato existem parcelas em aberto

@type method
@version 
@author g.sampaio
@since 04/09/2020
@return return_type, return_description
/*/
Method ContratoAdimplente(cCodContrato, cTipModulo) Class VirtusFin

	Local cQuery            := ""
	Local lRetorno          := .T.

	Default cCodContrato    := ""
	Default cTipModulo      := ""

	if Select("TRBFIN") > 0
		TRBFIN->( DbCloseArea() )
	endIf

	// query para verificar se existem titulos em aberto
	// para o contrato de cemiterio ou funeraria
	// --
	cQuery := " SELECT R_E_C_N_O_ RECSE1 FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "

	if AllTrim(cTipModulo) == "C" // cemiterio
		cQuery += " AND SE1.E1_XCONTRA = '" + cCodContrato + "' "
	elseIf AllTrim(cTipModulo) == "F" // funeraria
		cQuery += " AND SE1.E1_XCTRFUN = '" + cCodContrato + "' "
	endIf

	cQuery += " AND SE1.E1_SALDO > 0 "
	cQuery += " AND SE1.E1_VENCREA < '" + Dtos(dDatabase) + "' "

	cQuery := ChangeQuery(cQuery)

	MPSysOpenQuery(cQuery, 'TRBFIN')

	// se caso retornar registros o contrato não está adimplente
	if TRBFIN->(!Eof())
		lRetorno := .F.
	endIf

	if Select("TRBFIN") > 0
		TRBFIN->( DbCloseArea() )
	endIf

Return(lRetorno)

/*/{Protheus.doc} VirtusFin::RetValParcelasFinanciamento
funcao para retornar o valor da parcela no financiamento

@type method
@version 1.0
@author g.sampaio
@since 22/09/2020
@param nVlrContr, numeric, valor do contrato
@param nVlrEnt, numeric, valor da entrada
@param nQtdParcelas, numeric, quantidade de parcelas
@return numeric, valor da parcela com juros
/*/
Method RetValParcelasFinanciamento( nVlrContr, nVlrEnt, nParcelas, nJuros, lEntrada ) Class VirtusFin

	Local nRetorno          := 0
	Local nCoeficiente      := 0

	Default nVlrContr       := 0
	Default nVlrEnt         := 0
	Default nParcelas    	:= 0
	Default nJuros          := 0
	Default lEntrada        := .F.

	If ::nQtdParcelas > 0
		If lEntrada
			nParcelas := ::nQtdParcelas - 1
		else
			nParcelas := ::nQtdParcelas
		endIf
	EndIf

	// caso o valor contrato seja o valor da entrada, retornar o valor da parcela zerado
	If nParcelas == 1 .And. nVlrEnt == nVlrContr
		nRetorno := 0
	Else

		// calculo do coeficiente de finaciamento
		nCoeficiente	:= (nJuros / (1 - (1 / ((1 + nJuros) ^ nParcelas) ) ) )

		Conout("")
		Conout("[VirtusFin - RUTILE23 - RetValParcelasFinanciamento]")
		Conout("Tem Entrada? " + iif(lEntrada, "Tem", "Nao tem") )
		Conout("Qtd.Parcelas: " + AllTrim(Transform(nParcelas, "@E 999")) )
		Conout("Juros: " + AllTrim(Transform(nJuros, "@E 999,999.999")) )
		Conout("Coeficiente: " + AllTrim(Transform(nCoeficiente, "@E 9.9999999999")) )
		Conout("Valor do Contrato: " + AllTrim(Transform(nVlrContr, "@E 999,999.99")) )
		Conout("Valor de Entrada: " + AllTrim(Transform(nVlrEnt, "@E 999,999.99")) )

		If nJuros == 0
			nRetorno := Round( nVlrContr / nParcelas, TamSX3("E1_VALOR")[2] )
		Else

			// caso tenha entrada e utilize a entrada no calculo
			If nVlrEnt > 0 .And. lEntrada

				// verifico se conseguiu
				If nCoeficiente > 0
					nRetorno := Round((nVlrContr - nVlrEnt) * nCoeficiente,2)
				Else
					nRetorno := Round((nVlrContr - nVlrEnt) / nParcelas,2)
				Endif

			Else
				nRetorno := Round((nVlrContr * nCoeficiente),2)//Round((nVlrContr * nCoeficiente) / (1 + nCoeficiente),2)
			Endif

		Endif

	EndIf

	Conout("Valor da Parcela: " + Transform(nRetorno, "@E 999,999.99") )

Return(nRetorno)

/*/{Protheus.doc} GeraInstruBxCobranca
Gera instrução de cobrança para baixar o título no banco
Obs.: A tabela SE1 deve estar posicionada no título antes da chamada da função
@type function
@version 1.0
@author nata.queiroz
@since 17/04/2020
/*/
Method GeraInstruBxCobranca(nRecnoSE1) Class VirtusFin

	Local aArea     := GetArea()
	Local aAreaFI2  := FI2->( GetArea() )
	Local aAreaSE1  := SE1->( GetArea() )
	Local cMVForBol := Alltrim( SuperGetMv("MV_XFORBOL", .F., "BO") )
	Local cCodOcorr := Alltrim( SuperGetMv("MV_XOCORBX", .F., "02") )  //-- PEDIDO/SOLICITACAO DE BAIXA
	Local cGerado   := "2"

	// posicino no recno do titulo
	SE1->( DbGoTo( nRecnoSE1 ) )

	// verifico se o tiutlo é boleto e possui nosso numero e ID CNAB
	If AllTrim(SE1->E1_XFORPG) == cMVForBol;
			.And. !Empty(SE1->E1_NUMBCO);
			.And. !Empty(SE1->E1_IDCNAB)

		FI2->( DbSetOrder(1) )
		//FI2_FILIAL+FI2_CARTEI+FI2_NUMBOR+FI2_PREFIX+FI2_TITULO
		//+FI2_PARCEL+FI2_TIPO+FI2_CODCLI+FI2_LOJCLI+FI2_OCORR+FI2_GERADO
		If !FI2->(MsSeek(xFilial("FI2")+SE1->E1_SITUACA;
				+SE1->(E1_NUMBOR+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA+cCodOcorr+cGerado)))

			If RecLock("FI2", .T.)
				FI2->FI2_FILIAL := SE1->E1_FILIAL
				FI2->FI2_DTOCOR := dDataBase
				FI2->FI2_OCORR  := cCodOcorr
				FI2->FI2_DESCOC := "SOLICITACAO DE BAIXA"
				FI2->FI2_PREFIX := SE1->E1_PREFIXO
				FI2->FI2_TITULO := SE1->E1_NUM
				FI2->FI2_PARCEL := SE1->E1_PARCELA
				FI2->FI2_TIPO   := SE1->E1_TIPO
				FI2->FI2_CODCLI := SE1->E1_CLIENTE
				FI2->FI2_LOJCLI := SE1->E1_LOJA
				FI2->FI2_TIPCPO := "C"
				FI2->FI2_CAMPO  := "E1_HIST   "
				FI2->FI2_VALANT := "00"
				FI2->FI2_VALNOV := cCodOcorr
				FI2->FI2_NUMBOR := SE1->E1_NUMBOR
				FI2->FI2_CARTEI := SE1->E1_SITUACA
				FI2->FI2_DTGER  := Date()
				FI2->FI2_GERADO := cGerado
				FI2->FI2_SEQ    := ""
				FI2->(MsUnLock())
			EndIf

		EndIf

	EndIf

	RestAreA( aAreaSE1 )
	RestArea( aAreaFI2 )
	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} VirtusFin::CRContratoCemiterio
Metodo para gerar o financeiro do contrato de 
cemiterio 
@type method
@version 1.0
@author g.sampaio
@since 11/05/2021
@param nRecnoU00, numeric, recno do contrato
@param lGeraFinanceiro, logical, gera o financeiro do contrato
@return logical, retorna se gerou tudo certo
/*/
Method CRContratoCemiterio(nRecnoU00, lGeraFinanceiro) Class VirtusFin

	Local aArea 		:= GetArea()
	Local aAreaU00 		:= U00->(GetArea())
	Local lEntParcelas	:= SuperGetMv("MV_XPARENT", .F., .T.) // parametro para determinar se a entrada e considerada na quantidade de parcelas
	Local lEntrada		:= .F.
	Local lAtivMultNat	:= SuperGetMV("MV_XMULNPA",.F.,.F.)	// rateio de multiplas naturezas virtus
	Local lMulNatR		:= SuperGetMV("MV_MULNATR",.F.,.F.)	// rateio de multiplas naturezas padrão

	Default nRecnoU00 		:= 0
	Default lGeraFinanceiro := .T.

	if nRecnoU00 > 0

		// posiciono no registro do contrato
		U00->(DbGoTo(nRecnoU00))

		// pego os dados do contrato
		::cCodContrato		:= U00->U00_CODIGO
		::cCodCliente		:= U00->U00_CLIENT
		::cCodLojaCliente	:= U00->U00_LOJA
		::cCodNatureza		:= U00->U00_NATURE
		::dDataCadastro		:= U00->U00_DATA
		::nValorContrato 	:= U00->U00_VALOR
		::nValorEntrada 	:= U00->U00_VLRENT
		::nPercJuros		:= U00->U00_JUROS/100
		::cFormaPagto		:= U00->U00_FORPG
		::cPrefixo			:= SuperGetMv("MV_XPREFCT",.F.,"CEM")
		::cTipoTitulo		:= SuperGetMv("MV_XTIPOCT",.F.,"AT")
		::cTipoEntrada		:= SuperGetMv("MV_XTIPOEN",.F.,"ENT")

		If !Empty(U00->U00_DTENTR) .And. U00->U00_VLRENT == U00->U00_VALOR
			::nQtdParcelas	 := 1
		Elseif !lEntParcelas .And. !Empty(U00->U00_DTENTR) .And. U00->U00_VLRENT > 0
			::nQtdParcelas		:= U00->U00_QTDPAR + 1
		else
			::nQtdParcelas		:= U00->U00_QTDPAR
		endIf

		::dDataEntrada		:= U00->U00_DTENTR
		::dPrimeiroVencto	:= U00->U00_PRIMVE

		if ::nValorEntrada > 0 .And. !Empty(::dDataEntrada)
			lEntrada := .T.
		endIf

		// pego o parcelamento do cemiterio
		::GetParcelasCemiterio(lEntrada)

		// verifico se o rateio de multiplas naturezas esta habilitado
		if lAtivMultNat .And. lMulNatR
			::GetRateioCemiterio()
		endIf

		// gero os titulos do contas a receber
		if lGeraFinanceiro .And. Len(::aDadosParcelas) > 0
			::GeraFinanceiroCR(lEntrada)
		endIf

	elseIf FWIsInCallStack("U_RCPGA001")

		// pego os dados do contrato
		::cCodContrato		:= M->U00_CODIGO
		::cCodCliente		:= M->U00_CLIENT
		::cCodLojaCliente	:= M->U00_LOJA
		::cCodNatureza		:= M->U00_NATURE
		::dDataCadastro		:= M->U00_DATA
		::nValorContrato 	:= M->U00_VALOR
		::nValorEntrada 	:= M->U00_VLRENT
		::nPercJuros		:= M->U00_JUROS/100
		::cFormaPagto		:= M->U00_FORPG
		::cPrefixo			:= SuperGetMv("MV_XPREFCT",.F.,"CTR")
		::cTipoTitulo		:= SuperGetMv("MV_XTIPOCT",.F.,"AT")
		::cTipoEntrada		:= SuperGetMv("MV_XTIPOEN",.F.,"ENT")

		If !Empty(M->U00_DTENTR) .And. M->U00_VLRENT == M->U00_VALOR
			::nQtdParcelas	 := 1
		Elseif !lEntParcelas .And. !Empty(M->U00_DTENTR) .And. M->U00_VLRENT > 0
			::nQtdParcelas		:= M->U00_QTDPAR + 1
		else
			::nQtdParcelas		:= M->U00_QTDPAR
		endIf

		::dDataEntrada		:= M->U00_DTENTR
		::dPrimeiroVencto	:= M->U00_PRIMVE

		if ::nValorEntrada > 0 .And. !Empty(::dDataEntrada)
			lEntrada := .T.
		endIf

		// pego o parcelamento do cemiterio
		::GetParcelasCemiterio(lEntrada)

	endIf

	RestArea(aAreaU00)
	RestArea(aArea)

Return(::lRetorno)

/*/{Protheus.doc} VirtusFin::GetParcelasCemiterio
Metodo para gerar os dados das parcelas 
de cemiterio
@type method
@version 1.0  
@author g.sampaio
@since 10/05/2021
@param lEntrada, logical, para logico para definir que considera a entrada
@return array, array de dados da parcela do cemiterio
/*/
Method GetParcelasCemiterio( lEntrada ) Class VirtusFin

	Local aRetorno				:= {}
	Local cDiaVencimento		:= ""
	Local cQtdTotParcelas		:= ""
	Local dDtVencimento			:= Stod("")
	Local lDiaAlt				:= .F.
	Local nParcela				:= 0
	Local nValOrigParcela		:= 0

	Default lEntrada		:= .T.

	//=============================
	// inicio de vales das variveis
	//=============================

	// determino o valor original da parcela
	if lEntrada .And. ::nValorEntrada > 0 // verifico se tem entrada para o contrato
		nValOrigParcela		:= Round((::nValorContrato - ::nValorEntrada) / (::nQtdParcelas - 1), TamSX3("E1_VALOR")[2])
	else // valor do contrato sem entrada
		nValOrigParcela		:= Round(::nValorContrato / ::nQtdParcelas, TamSX3("E1_VALOR")[2])
	endIf

	if ::nPercJuros > 0
		::nValFinancParcela	:= ::RetValParcelasFinanciamento( ::nValorContrato, ::nValorEntrada, ::nQtdParcelas, ::nPercJuros, lEntrada )
	else
		::nValFinancParcela := nValOrigParcela
	endIf

	cDiaVencimento 		:= Day2Str(::dPrimeiroVencto)// dia do vencimento
	cQtdTotParcelas		:= StrZero(::nQtdParcelas,TamSX3("E1_PARCELA")[1])

	For nParcela := 1 To ::nQtdParcelas

		cParcela 		:= StrZero(nParcela,TamSX3("E1_PARCELA")[1])
		cParcContrato	:= cParcela + "/" + cQtdTotParcelas

		If lEntrada .And. nParcela == 1
			AAdd(::aDadosParcelas,{ xFilial("U00"), ::cCodContrato, ::dDataCadastro, cParcela, cParcContrato, ::dDataEntrada, ::nValorEntrada, ::nValorEntrada})
		Else

			// defino a data de vencimento da primeira parcela
			// e todos os vencimentos assumiram o mesmo dia de vencimento da primeira parcela
			if !Empty(dDtVencimento)

				//valido se o dia de vencimento e maior que o ultimo dia do proximo mes
				if Val(Day2Str( dDtVencimento ) ) > Val(Day2Str( LastDay(MonthSum(dDtVencimento,1)) ) )
					dDtVencimento	:= MonthSum(dDtVencimento,1)
					lDiaAlt	:= .T.
				else

					//Se o ultimo dia foi alterado, o proximo mes assume o dia de vencimento da primeira parcela novamente
					if lDiaAlt
						dDtVencimento	:= CtoD( cDiaVencimento + "/" + Month2Str( MonthSum(dDtVencimento,1)) + "/" + Year2Str(MonthSum(dDtVencimento,1) ) )
						lDiaAlt	:= .F.
					else
						dDtVencimento	:= MonthSum(dDtVencimento,1)
					endif
				endif
			else
				dDtVencimento	:= ::dPrimeiroVencto
			endif

			// alimento o array de dados de parcela
			AAdd(::aDadosParcelas,{ xFilial("U00"), ::cCodContrato, ::dDataCadastro	, cParcela, cParcContrato, dDtVencimento, nValOrigParcela, ::nValFinancParcela })

		Endif

	Next nParcela

	if Len(::aDadosParcelas) > 0
		aRetorno := ::aDadosParcelas
	endIf

Return(aRetorno)

/*/{Protheus.doc} VirtusFin::GeraFinanceiroCR
Metodo de criação de parcelas no contas a receber
@type method
@version 1.0 
@author g.sampaio
@since 11/05/2021
@param lEntrada, logical, define se é a entrada de parcelamento
@return logical, retorno sobre a inclusao do titulo
/*/
Method GeraFinanceiroCR(lEntrada) Class VirtusFin

	Local aFin040			:= 0
	Local aRatEv			:= {}
	Local aAuxEV			:= {}
	Local cNatTerreno		:= ""
	Local dDataAux			:= Stod("")
	Local nRateio			:= 0
	Local nParcela 			:= 0
	Local nAcrescimo		:= 0
	Local nValorRateio		:= 0
	Local nSomaTerreno		:= 0
	Local nVAlorTerreno		:= 0

	Private lMsErroAuto := .F.

	Default lEntrada := .F.

	// natureza do terreno
	cNatTerreno	:= BuscaTerreno(::cCodContrato)

	// valor do terreno
	nValorTerreno := PrcTerreno(::cCodContrato)

	BEGIN TRANSACTION

		// percorro a inclusao dos titulos a receber de acordo com a quantidade de parcelas
		for nParcela := 1 to ::nQtdParcelas

			if ::lRetorno

				aFin040 	:= {}
				aRatEv		:= {}
				nAcrescimo 	:= 0

				if dDataBase > ::aDadosParcelas[nParcela, 3]
					dDataAux 	:= dDataBase
					dDataBase 	:= ::aDadosParcelas[nParcela, 3]
				endIf

				if ::lCemiterio .And. ::aDadosParcelas[nParcela, 8] > ::aDadosParcelas[nParcela, 7]
					nAcrescimo	:= Round(::aDadosParcelas[nParcela, 8] - ::aDadosParcelas[nParcela, 7], TamSX3("E1_ACRESC")[2])
				endIf

				AAdd(aFin040, {"E1_FILIAL"	, ::aDadosParcelas[nParcela, 1]	, Nil } )
				AAdd(aFin040, {"E1_PREFIXO"	, ::cPrefixo          			, Nil } )
				AAdd(aFin040, {"E1_EMISSAO"	, ::aDadosParcelas[nParcela, 3]	, Nil } )
				AAdd(aFin040, {"E1_NUM"		, ::aDadosParcelas[nParcela, 2]	, Nil } )
				AAdd(aFin040, {"E1_PARCELA"	, ::aDadosParcelas[nParcela, 4]	, Nil } )
				AAdd(aFin040, {"E1_XPARCON"	, ::aDadosParcelas[nParcela, 5]	, Nil } )

				if ::lCemiterio .And. lEntrada .And. nParcela == 1
					AAdd(aFin040, {"E1_TIPO"	, ::cTipoEntrada			, Nil } )
				else
					AAdd(aFin040, {"E1_TIPO"	, ::cTipoTitulo		 		, Nil } )
				endIf

				AAdd(aFin040, {"E1_NATUREZ"	, ::cCodNatureza				, Nil } )
				AAdd(aFin040, {"E1_CLIENTE"	, ::cCodCliente					, Nil } )
				AAdd(aFin040, {"E1_LOJA"	, ::cCodLojaCliente				, Nil } )
				AAdd(aFin040, {"E1_VENCTO"	, ::aDadosParcelas[nParcela, 6]	, Nil } )
				AAdd(aFin040, {"E1_VENCREA"	, DataValida(::aDadosParcelas[nParcela, 6])			, Nil } )
				AAdd(aFin040, {"E1_VALOR"	, ::aDadosParcelas[nParcela, 7]	, Nil } )

				if ::lRecorrencia
					AAdd(aFin040, {"E1_XFORPG"	, ::cFormaPagto				, Nil } )
				endif

				If ::lCemiterio .And. nAcrescimo > 0
					AAdd(aFin040, {"E1_ACRESC"	, nAcrescimo		, Nil } )
					AAdd(aFin040, {"E1_SDACRES"	, nAcrescimo		, Nil } )
				Endif

				AAdd(aFin040, {"E1_PORCJUR"	, ::nTaxaPermanencia			, Nil } )
				AAdd(aFin040, {"E1_VALJUR"	, Round(::aDadosParcelas[nParcela, 7] * (::nTaxaPermanencia / 100),2)			, Nil } )

				if ::lCemiterio
					AAdd(aFin040, {"E1_XCONTRA"	, ::cCodContrato		, Nil } )
				elseIf ::lFuneraria
					AAdd(aFin040, {"E1_XCTRFUN"	, ::cCodContrato		, Nil } )
				endIf

				// verifico se tenho dados para o rateio de multiplas naturezas
				if Len(::aDadosRateio) > 0

					aAdd(aFin040, {"E1_MULTNAT"	, "1"	,NIL})

					for nRateio := 1 to Len(::aDadosRateio)
						aAuxEV 			:= {}
						nValorRateio	:= 0
						nValorRateio 	:= Round(::aDadosRateio[nRateio, 2] * ::aDadosParcelas[nParcela, 7],TamSX3("EV_VALOR")[2])
						aAdd( aAuxEV, {"EV_NATUREZ"	, ::aDadosRateio[nRateio, 1]		, Nil })
						aAdd( aAuxEV, {"EV_VALOR"	, nValorRateio						, Nil })
						aAdd( aAuxEV, {"EV_PERC"	, Round(::aDadosRateio[nRateio, 2]*100,TamSX3("EV_PERC")[2])	, Nil })
						aAdd( aRatEv, aAuxEv )
					next nRateio

				endIf

				//incluo o titulo a receber
				if Len(aRatEv) > 0 // para quando houver rateio de multiplas naturezas

					// validacao dos itens do rateio
					aRatEv := ::ValidaRateio(aRatEv, ::aDadosParcelas[nParcela, 7], cNatTerreno, @nSomaTerreno, nValorTerreno, (nParcela==::nQtdParcelas) )

					MSExecAuto({|x,y,z,a| FINA040(x,y,z,a)},aFin040,3,,aRatEv)
				else
					MSExecAuto({|x,y| FINA040(x,y)},aFin040,3)
				endIf

				If lMsErroAuto

					If !IsBlind()
						MostraErro()
					Endif

					DisarmTransaction()
					::lRetorno := .F.
					BREAK

				EndIf

				if !Empty(dDataAux)
					dDataBase := dDataAux
				endIf

			endIf

		next nI

	END TRANSACTION

Return(::lRetorno)

/*/{Protheus.doc} VirtusFin::GetRateioCemiterio
Metodo para retornar o rateio de naturezas
@type method
@version 1.0 
@author g.sampaio
@since 11/05/2021
/*/
Method GetRateioCemiterio() Class VirtusFin

	Local cQuery 		:= ""
	Local nPercRateio 	:= 0

	if Select("TRBRAT") > 0
		TRBRAT->(DbCloseArea())
	endIf

	cQuery := " SELECT "
	cQuery += " SB1.B1_XNATURE NATUREZA, "
	cQuery += " SUM(U01.U01_VLRTOT) VALOR "
	cQuery += " FROM " + RetSQLName("U01") + " U01 "
	cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 ON SB1.D_E_L_E_T_  = ' ' "
	cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += " AND SB1.B1_COD = U01.U01_PRODUT "
	cQuery += " AND B1_XNATURE <> ' ' "
	cQuery += " WHERE U01.D_E_L_E_T_ = ' ' "
	cQuery += " AND U01.U01_FILIAL = '" + xFilial("U01") + "' "
	cQuery += " AND U01.U01_CODIGO = '" + ::cCodContrato + "' "
	cQuery += " AND U01.U01_VLRTOT > 0 "
	cQuery += " GROUP BY SB1.B1_XNATURE "

	TcQuery cQuery New Alias "TRBRAT"

	while TRBRAT->(!Eof())

		// percentual do rateio conforme o valor do item sobre o valor do contrato
		nPercRateio := TRBRAT->VALOR / ::nValorContrato

		aAdd( ::aDadosRateio, {TRBRAT->NATUREZA, nPercRateio })

		TRBRAT->(DbSkip())
	endDo

	if Select("TRBRAT") > 0
		TRBRAT->(DbCloseArea())
	endIf

Return(Nil)

/*/{Protheus.doc} VirtusFin::ValidaRateio
metodo para validar os dados do rateio de 
multiplas naturezas, validando se existe alguma 
diferenca entre o valor rateado e o valor da parcela

Realizando o baleanceamento dos valores e percentuais do rateio

@type method
@version 1.0 
@author g.sampaio
@since 13/05/2021
@param aRateio, array, Array com os dados do rateio
@param nValorParcela, numeric, valor da parcela
@return array, dados validados do rateio de multiplas naturezas
/*/
Method ValidaRateio(aRateio, nValorParcela, cNatTerreno, nSomaTerreno, nValorTerreno, lUltima) Class VirtusFin

	Local aRetorno 				:= {}
	Local lPrecoTabelaTerreno	:= SuperGetMV("MV_XPTBTER",.F.,.F.)
	Local nValorAux	 			:= 0
	Local nPercAux				:= 0
	Local nDiferenca			:= 0
	Local nDifPerc				:= 0
	Local nTamArray				:= 0
	Local nPosTerreno			:= 0

	Default aRateio 		:= {}
	Default nValorParcela 	:= 0
	Default cNatTerreno		:= ""
	Default nSomaTerreno	:= 0
	Default nValorTerreno	:= 0
	Default lUltima			:= .F. // ultima parcela

	//=======================================
	// faco o tratamento do valor do terreno
	//=======================================

	if lPrecoTabelaTerreno

		nPosTerreno := AScan(aRateio, {|x| AllTrim(x[1][2]) == AllTrim(cNatTerreno) })

		if nPosTerreno > 0
			nSomaTerreno += aRateio[nPosTerreno][2][2] // soma o total do terreno

			if lUltima

				if nSomaTerreno > nValorTerreno

					nDiferenca := nSomaTerreno - nValorTerreno

					// retiro a diferenca do item de terreno
					aRateio[nPosTerreno, 2, 2] := aRateio[nPosTerreno, 2, 2] - nDiferenca

				elseIf nValorTerreno > nSomaTerreno

					nDiferenca := nValorTerreno - nSomaTerreno

					// adciono a diferenca a diferenca do item de terreno
					aRateio[nPosTerreno, 2, 2] := aRateio[nPosTerreno, 2, 2] + nDiferenca

				endIf

			endIf

		endIf

	endIf

	nTamArray := Len(aRateio) // tamanho do array (ultima posicao do array)
	AEval( aRateio, { |x,y| nValorAux += x[2][2] },/*nStart*/,/*nCount*/) // total do valor do rateio
	AEval( aRateio, { |x,y| nPercAux += x[3][2] },/*nStart*/,/*nCount*/) // total do percentual do rateio

	// verifico se tem terreno no rateio de multiplas naturezas
	if nPosTerreno > 0 .And. lUltima

		// verifico se a ultima posicao do array e igual ao terreno e se e maior que 1
		if nTamArray == nPosTerreno .And. nTamArray > 1
			nTamArray := nPosTerreno - 1
		endIf

	endIf

	// trato o valor do rateio
	if nValorAux > nValorParcela
		nDiferenca := nValorAux - nValorParcela

		// retiro a diferenca do ultimo item
		aRateio[nTamArray, 2, 2] := aRateio[nTamArray, 2, 2] - nDiferenca

	elseIf nValorParcela > nValorAux
		nDiferenca := nValorParcela - nValorAux

		// adciono a diferenca a diferenca do ultimo item
		aRateio[nTamArray, 2, 2] := aRateio[nTamArray, 2, 2] + nDiferenca

	endIf

	// trato o percentual do rateio
	if nPercAux > 100
		nDifPerc := nPercAux - 100

		// retiro a diferenca do ultimo item
		aRateio[nTamArray, 3, 2] := aRateio[nTamArray, 3, 2] - nDifPerc

	elseif 100 > nPercAux
		nDifPerc := 100 - nPercAux

		// retiro a diferenca do ultimo item
		aRateio[nTamArray, 3, 2] := aRateio[nTamArray, 3, 2] + nDifPerc

	endIf

	aRetorno := aRateio

Return(aRetorno)

/*/{Protheus.doc} VirtusFin::ExcluiMultiNatLiquidacao
metodo para excluir o rateio de multiplas naturezas
@type method
@version 1.0 
@author g.sampaio
@since 26/05/2021
@param nRecnoSE1, numeric, recno do titulo
/*/
Method ExcluiMultiNatLiquidacao(nRecnoSE1) Class VirtusFin

	Local aArea		:= GetArea()
	Local aAreaSE1	:= SE1->(GetArea())
	Local aAreaSEV	:= SEV->(GetArea())

	Default nRecnoSE1	:= 0

	if nRecnoSE1 > 0

		SE1->(DBGoTo(nRecnoSE1))

		SEV->(DbSetOrder(1))
		if SEV->(MsSeek(xFilial("SEV")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA))

			BEGIN TRANSACTION

				while SEV->(!Eof()) .And.;
						SEV->(EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA) == xFilial("SEV")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA

					if SEV->(RecLock("SEV"))
						SEV->(DbDelete())
						SEV->(MsUnLock())
					else
						SEV->(DisarmTransaction())
					endIf

					SEV->(DbSkip())
				endDo

			END TRANSACTION

		endIf

	endIf

	RestArea(aAreaSEV)
	RestArea(aAreaSE1)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} VirtusFin::SeekSE1
Funcao para posicionar
@type method
@version 1.0
@author g.sampaio
@since 16/07/2021
@param cModulo, character, modulo utilizado
@param cContrato, character, codigo do contrato
@return logical, retorno do posicionamento na tabela
/*/
Method SeekSE1(cModulo, cContrato) Class VirtusFin

	Local cQuery 	:= ""
	Local lRetorno	:= .F.

	Default cModulo		:= ""
	Default cContrato	:= ""

	if Select("TRBSE1") > 0
		TRBSE1->(DbCloseArea())
	endIf

	cQuery := " SELECT SE1.R_E_C_N_O_ RECSE1 "
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += " WHERE SE1.D_E_L_E_T_  = ' ' "
	cQuery += " AND SE1.E1_SALDO > 0 "

	if cModulo == "C" // cemtierio
		cQuery += " AND SE1.E1_XCONTRA  = '"+cContrato+"' "
	else// funeraria
		cQuery += " AND SE1.E1_XCTRFUN  = '"+cContrato+"' "
	endIf

	MPSysOpenQuery(cQuery, 'TRBSE1')

	if TRBSE1->(!Eof())
		if TRBSE1->RECSE1 > 0
			SE1->(DBGoTo(TRBSE1->RECSE1))
			lRetorno := .T.
		endIf
	endIf

	if Select("TRBSE1") > 0
		TRBSE1->(DbCloseArea())
	endIf

Return(lRetorno)

/*/{Protheus.doc} VirtusFin::RemoveDesconto
Remove o desconto do titulo a receber
@type method
@version 1.0
@author g.sampaio
@since 31/03/2024
@param cChvSE1, character, chave do titulo SE1
@param cFormPag, character, forma de pagamento
@return logical, retorno da remocao do desconto
/*/
Method RemoveDesconto(nRecnoSE1, cFormPag, cErro) Class VirtusFin

	Local aArea	 		As Array
	Local aAreaSE1		As Array
	Local aAreaUF2		As Array
	Local aTitulos		As Array
	Local aFin040		As Array
	Local cTpDesc		As Character
	Local dDataAtual 	As Date
	Local dDataEmissao	As Date
	Local lRetorno		As Logical
	Local lContinua		As Logical

	Private lMsErroAuto	As Logical
	Private lMsHelpAuto	As Logical

	Default nRecnoSE1	:= 0
	Default cFormPag	:= ""
	Default cErro		:= ""

	// atribui valor as variaveis
	aArea 		:= GetArea()
	aAreaSE1 	:= SE1->(GetArea())
	aAreaUF2 	:= UF2->(GetArea())
	aTitulos	:= {}
	aFin040		:= {}
	dDataAtual	:= dDataBase
	lRetorno 	:= .F.
	lContinua	:= .T.
	lMsErroAuto	:= .F.

	If nRecnoSE1 > 0

		SE1->(DbGoTo(nRecnoSE1))

		UF2->(DbSetOrder(1))
		If UF2->(MsSeek(xFilial("UF2")+SE1->E1_XCTRFUN))

			//-- pego o desconto de regra, caso houver regra cadastrada
			UJZ->( dbSetOrder(2) ) //-- UJZ_FILIAL+UJZ_CODIGO+UJZ_FORPG
			If UJZ->( MsSeek(xFilial("UJZ") + UF2->UF2_REGRA + UF2->UF2_FORPG) )

				cTpDesc 	:= UJZ->UJZ_TPDESC
				nVlrRegra 	:= ValVlrRegra( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, UF2->UF2_DESREG, cTpDesc, UJZ->UJZ_VALOR, SE1->E1_VALOR )
				nVlrReal 	:= (UF2->UF2_VALOR + UF2->UF2_VLADIC)

				If cTpDesc == "R"
					nValor := nVlrReal + nVlrRegra
				Else
					nValor := (100 * nVlrRegra) / UJZ->UJZ_VALOR
				EndIf

				dDataEmissao := SE1->E1_EMISSAO

				// preencho o array de títulos para incluí-los novamente com o valor reajustado
				aFin040 := {}
				aadd(aFin040, {"E1_FILIAL"	, SE1->E1_FILIAL , Nil } )
				aadd(aFin040, {"E1_PREFIXO"	, SE1->E1_PREFIXO, Nil } )
				aadd(aFin040, {"E1_NUM"		, SE1->E1_NUM    , Nil } )
				aadd(aFin040, {"E1_PARCELA"	, SE1->E1_PARCELA, Nil } )
				aadd(aFin040, {"E1_TIPO"	, SE1->E1_TIPO   , Nil } )
				aadd(aFin040, {"E1_CLIENTE"	, SE1->E1_CLIENTE, Nil } )
				aadd(aFin040, {"E1_LOJA"	, SE1->E1_LOJA   , Nil } )
				aadd(aFin040, {"E1_XPARCON"	, SE1->E1_XPARCON, Nil } )
				aadd(aFin040, {"E1_NATUREZ"	, SE1->E1_NATUREZ, Nil } )
				aadd(aFin040, {"E1_EMISSAO"	, SE1->E1_EMISSAO, Nil } )
				aadd(aFin040, {"E1_VENCTO"	, SE1->E1_VENCTO , Nil } )
				aadd(aFin040, {"E1_VENCREA"	, SE1->E1_VENCREA, Nil } )
				aadd(aFin040, {"E1_VALOR"	, nValor       	 , Nil } )
				aadd(aFin040, {"E1_XCTRFUN"	, SE1->E1_XCTRFUN, Nil } )
				aadd(aFin040, {"E1_XFORPG"	, cFormPag 		 , Nil } )
				aadd(aFin040, {"E1_VEND1"  	, SE1->E1_VEND1  , Nil } )
				aadd(aFin040, {"E1_PORTADO"	, SE1->E1_PORTADO, Nil } )
				aadd(aFin040, {"E1_AGEDEP" 	, SE1->E1_AGEDEP , Nil } )
				aadd(aFin040, {"E1_CONTA"  	, SE1->E1_CONTA  , Nil } )
				aadd(aFin040, {"E1_IDCNAB" 	, SE1->E1_IDCNAB , Nil } )
				aadd(aFin040, {"E1_CODBAR" 	, SE1->E1_CODBAR , Nil } )

				BEGIN TRANSACTION

					// retiro da excessao de cobranca
					lContinua := Self:MarcaExcessaoSK1(SE1->(Recno()))

					If lContinua

						// excluo o título do bordero
						lContinua := Self:ExcBordTit(SE1->(Recno()))

						If lContinua

							// excluo o título
							lContinua := Self:ExcluiTituloFin(SE1->(Recno()))

							If lContinua

								lMsErroAuto := .F.
								lMsHelpAuto	:= .T.

								// mudo a data base para a data do vencimento
								dDatabase := dDataEmissao

								//===============================================================================
								// == PONTO DE ENTRADA PARA MANIPULACAO DO FINANCEIRO DA ATIVACAO DO CONTRATO ==
								//==============================================================================
								if ExistBlock("UF040PCO")

									aFin040 := AClone(ExecBlock( "UF040PCO", .F. ,.F., { aFin040 } ))

									// valido o conteudo retornado pelo
									if len(aFin040) == 0 .Or. ValType( aFin040 ) <> "A"
										lRetorno 	:= .F.
										MsgAlert("Estrutura do Array de títulos da Ativacao inválida.", "UF040PCO")
									endIf

								endIf

								MSExecAuto({|x,y| FINA040(x,y)},aFin040,3)

								If lMsErroAuto
									lRetorno 	:= .F.

									If !IsBlind()
										MostraErro()
									Else
										cErro := AllTrim( MostraErro('/temp') )
									EndIf

									SE1->(DisarmTransaction())
								Else
									lRetorno := .T.
								EndIf

								dDataBase := dDataAtual

							Else
								lRetorno 	:= .F.
								SE1->(DisarmTransaction())
								BREAK
							EndIf

						Else
							lRetorno 	:= .F.
							SE1->(DisarmTransaction())
							BREAK
						EndIf

					Else
						lRetorno 	:= .F.
						SE1->(DisarmTransaction())
						BREAK
					EndIf

				END TRANSACTION

			EndIf

		EndIf

	EndIf

	RestArea(aAreaUF2)
	RestArea(aAreaSE1)
	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} VirtusFin::ULJRecBX
Geracao efetiva dos registros no SE5(Mov. Bancario) correspondentes a baixa dos titulos recebidos e atualizacao do ti-
tulo a receber(SE1)

@type function
@version 12.1.33
@author Pablo C Nunes
@since 01/06/2022
/*/
	Method ULJRecBX(  nVlrMulta		, nVlrJuros		,;
		nVlrDesconto	, nVlrRecebido	, cCartFrt		,;
		cFilialTit		, cFrmPag		, lPrimBaixa	, nPrimMulta	,;
		nPrimJuros		, nPrimDescon	, nTotReceb		, aSE5Dados		,;
		lPgTef			, cNomeUser		, nValAbat		, aSE5Bxas		,;
		aTitBxSE5		, cNumCheque	, aTitDelSE5	, nValTroco		,;
		nMoeda			, nRecnoSE5 	, lWS			, cNumMov		,;
		aNsuVndTef		, cIdCart		, aPagDig						) Class VirtusFin

	Local lAchou		:= .F.
	Local lRet			:= .T.
	Local lRecFilial	:= SuperGetMV( "MV_LJRECFI", NIL, .F. )
	Local lTefMult		:= SuperGetMV("MV_TEFMULT",.F.)				// Verifica se esta configurado multiplas transacoes
	Local aBaixa		:= {}
	Local aDadosSE5		:= {}
	Local aAreaSA6		:= SA6->(GetArea())							//Area da Tabela SA6
	Local cFilAntBkp	:= cFilAnt
	Local cNatureza		:= ""
	Local cForma		:= ""										// Guarda forma de pagamento
	Local cCodCaixa		:= ""										// Codigo do Caixa
	Local cFilBkp		:= ""
	Local cFilSA6		:= ""
	Local nCount		:= SE5->( FCount() )
	Local nRecnoSE1		:= 0										// Recno do titulo baixado
	Local nX			:= 0
	Local nY			:= 0										// Posicao da array de cartoes
	Local cSeq			:= Space(TamSX3("E5_SEQ")[1])
	Local cMvTpRec		:= SuperGetMV("MV_LJCTRET",,"RI|RG|RB|RS")
	Local lAliasMDM		:= AliasIndic("MDM")		// indica se existe Alias MDM
	Local lAliasMDN     := AliasIndic("MDN")		// indica se existe Alias MDN
	Local lLjRecBxFim   := ExistBlock("LJRECBXFIM")					// Ponto de entrada chamado no final da gravacao na retaguarda
	Local nPosRetCart 	:= 0
	Local cNSUTEFAux 	:= ""
	Local cAutTEFAux 	:= ""
	Local nPosAux 		:= 0
	Local lAcreDecre	:= .T.										//verifica se existem os campos de valores de acrescimo e decrescimo no SE5
	Local lAjustaAcres	:= .F.										// Tratamento necessário para recebimentos com baixas parciais
	Local nVlDiferenca	:= 0										// Tratamento necessário para recebimentos com baixas parciais
	Local lAjustaJuros	:= .F.
	Local nVlDifJuros	:= 0
	Local aOrdSE5		:= {}
	Local lF070TRAVA	:= ExistBlock("F070TRAVA")
	Local lF040TRVSA1	:= ExistBlock("F040TRVSA1")
	Local lTravaSA1		:= .T.										// Se trava ou não o registro de cliente para baixa do titulo
	Local nValVL		:= 0
	Local nLjTrDin		:= SuperGetMV("MV_LJTRDIN",,0)
	Local aAuxDados		:= {}										//variavel Generica que guarda varios valores temporarios
	Local lGestao       := FWSizeFilial() > 2
	Local lSe1Exc       := lGestao .And. FWModeAccess("SE1",3) == "E"
	Local cFilOrig      := ""
	Local lTroco		:= IIF(cPaisLoc == "BRA",SuperGetMV("MV_LJTROCO",,.F.),SuperGetMV("MV_LJTRLOC",,.F.))
	Local cCampo		:= ""

	Local cMV_LJRECEB := SuperGetMv("MV_LJRECEB",.F.,"1")		// Parametro de controle do Recebimento
	Local cPrefixo := SE1->E1_PREFIXO
	Local cNum := SE1->E1_NUM
	Local cParcela := SE1->E1_PARCELA
//Local dVencimento := SE1->E1_VENCTO
//Local nValor := SE1->E1_VALOR
	Local cTipo := SE1->E1_TIPO

	DEFAULT nPrimMulta  := 0
	DEFAULT nPrimJuros  := 0
	DEFAULT nPrimDescon := 0
	DEFAULT nTotReceb   := 0
	DEFAULT lPgTef		:= .F.
	DEFAULT aSE5Dados   := {}
	DEFAULT cNomeUser   := cUserName
	DEFAULT nValAbat    := 0
	DEFAULT aSE5Bxas    := {}
	DEFAULT aTitBxSE5	:= {}
	DEFAULT cNumCheque	:= ""
	DEFAULT aTitDelSE5	:= {}
	DEFAULT nValTroco	:= 0
	DEFAULT nMoeda		:= 1
	DEFAULT nRecnoSE5   := 0
	Default lWs			:= .F.						// Informa se esta executando via Web Service
	Default nVlrJuros	:= 0
	Default cNumMov		:= ""
	Default aNsuVndTef	:= {}
	Default cIdCart		:= ""
	Default aPagDig 	:= {}

	cNatureza := SuperGetMV("MV_NATRECE", NIL, "")
//LjGrvLog("Recebimento_Titulo", "Conteudo MV_NATRECE(Padrao = RECEBIMENTO). Utilizado na gravacao SE5->E5_NATUREZ:",cNatureza)
	cNatureza := If(Empty(cNatureza),'RECEBIMENTO',&(cNatureza))

//LjGrvLog("Recebimento_Titulo", "Conteudo Param: cMV_LJRECEB:",cMV_LJRECEB)

	If lFinancComp == NIL
		lFinancComp := 	LjRecFinComp()
		//LjGrvLog("Recebimento_Titulo", "Verifica SE1 e SE5 compatilhados. Se exclusivo deve gerar SE5 tipo BA na filial de origem do titulo. lFinancComp:",lFinancComp)
	Endif

	If !Empty( cCartFrt )
		cCartao := cCartFrt
		nValRec := nVlrRecebido
	Endif

	DbSelectArea("SE1")
	SE1->(DbSetOrder(1))
	lAchou := SE1->(DbSeek(cFilialTit + cPrefixo + cNum + cParcela + cTipo))

	cFilOrig := IIF(lSe1Exc, cFilialTit, SE1->E1_FILORIG)

// mensagens no console log 
	FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", " ###################################################### " )
	FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", " INICIO DO PROCESSO DE BAIXA DE TITULOS: ULJRecBX " )
	FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", " DATA: " + DTOC( Date() ) + " HORA: " + Time() + " " )
	FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", " EMPRESA: " + Alltrim(CEMPANT) + " FILIAL: " + Alltrim(CFILANT) + " " )
	FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", " ###################################################### " )

//LjGrvLog("Recebimento_Titulo","Pesquisa titulo: SE1->(DbSeek(cFilialTit + cPrefixo + cNum + cParcela + cTipo))->("+cFilialTit+"/"+cPrefixo+"/"+cNum+"/"+cParcela+"/"+cTipo+") lAchou:",lAchou)
	FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Pesquisa titulo: SE1->(DbSeek(cFilialTit + cPrefixo + cNum + cParcela + cTipo))->("+cFilialTit+"/"+cPrefixo+"/"+cNum+"/"+cParcela+"/"+cTipo+") lAchou: "+toString(lAchou) )

	If lAchou .And. SE1->(E1_SALDO) <= 0
		//LjGrvLog("Recebimento_Titulo", "Titulo nao possui saldo:SE1->(E1_SALDO) <= 0")
		FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Titulo nao possui saldo:SE1->(E1_SALDO) <= 0" )
		lAchou := .F.
		lRet	:= .F.
	EndIf

	If lAchou
		//Ponto de entrada que indica se irá alocar o cliente para atualização dos seus valores ou ira ignorar a atualização.
		If lF070TRAVA .And. lF040TRVSA1
			//LjGrvLog("Recebimento_Titulo","Antes da Chamada dos Pontos de Entrada:F070TRAVA e F040TRVSA1")
			FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Antes da Chamada dos Pontos de Entrada:F070TRAVA e F040TRVSA1" )
			lTravaSA1 := ExecBlock("F070TRAVA", .F., .F.) .Or. ExecBlock("F040TRVSA1", .F., .F.)
			//LjGrvLog("Recebimento_Titulo","Apos a Chamada dos Pontos de Entrada:F070TRAVA e F040TRVSA1. Return(lTravaSA1)",lTravaSA1)
			FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Apos a Chamada dos Pontos de Entrada:F070TRAVA e F040TRVSA1. Return(lTravaSA1): "+toString(lTravaSA1) )
		Else
			//LjGrvLog("Recebimento_Titulo", "Verifica se possui PE:F070TRAVA  - Permite baixa com registro SA1 alocado",lF070TRAVA)
			FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Verifica se possui PE:F070TRAVA  - Permite baixa com registro SA1 alocado. lF070TRAVA: "+toString(lF070TRAVA) )
			//LjGrvLog("Recebimento_Titulo", "Verifica se possui PE:F040TRVSA1 - Permite baixa com registro SA1 alocado",lF040TRVSA1)
			FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Verifica se possui PE:F040TRVSA1 - Permite baixa com registro SA1 alocado. lF040TRVSA1: "+toString(lF040TRVSA1) )
		EndIf

		//Rotinas do financeiro nao atualizam SA1 quando possui PE configurado.
		If lTravaSA1
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
				If SA1->(Rlock())		// Funcao que tenta alocar sem chamar tela
					SA1->(MsUnlock())
				Else
					lRet := .F.
					//LjGrvLog("Recebimento_Titulo",	"Não foi possível alocar o cliente: " +;
						//							SA1->A1_FILIAL+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA+"|"+SA1->A1_NOME)
					FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Não foi possível alocar o cliente: " +;
						SA1->A1_FILIAL+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA+"|"+SA1->A1_NOME)
					//LjGrvLog("Recebimento_Titulo",	"Verificar os pontos de entrada 'F070TRAVA' e 'F040TRVSA1' para baixa com cliente alocado.")
					FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Verificar os pontos de entrada 'F070TRAVA' e 'F040TRVSA1' para baixa com cliente alocado." )
				EndIf
			EndIf
		EndIf
	EndIf

	If lAchou .AND. lRet
		nRecnoSE1  := SE1->(Recno())

    /* Capturo a filial aqui pois caso o cFilAnt seja 
     alterado e o  compartilhamento da SE1 <> SA6, 
     ele achará*/
    cFilSA6		:= xFilial("SA6")
    
	If !lRecFilial
	    If lAliasMDM .AND. lAliasMDN
			AAdd(aBaixa, TrazCodMot("LOJ"))
		Else
			AAdd(aBaixa, TrazCodMot("NOR"))
		EndIf
	Else
		If cFilAnt <> cFilOrig
			AAdd(aBaixa, TrazCodMot("LOJ"))
			cFilBkp    := cFilAnt

			If !Empty(cFilialTit)
				cFilAnt    := IIF(lSe1Exc,cFilialTit,cFilOrig)
				//LjGrvLog("Recebimento_Titulo", "Filial do título | cFilAnt", cFilAnt)
                FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Filial do título | cFilAnt: "+cFilAnt )
			EndIf

			If xFilial("SA6") <> cFilSA6
				//LjGrvLog("RECEBIMENTO"," Filial SA6 (backup):" + cFilSA6)
                FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", " Filial SA6 (backup): " + cFilSA6 )
				//LjGrvLog("RECEBIMENTO"," Filial SA6 (atual):" + xFilial("SA6"))
                FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", " Filial SA6 (atual): " + xFilial("SA6") )
				//LjGrvLog("RECEBIMENTO"," Filial SE1:" + cFilialTit)
                FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", " Filial SE1: " + cFilialTit )
			EndIf
		Else
		    If lAliasMDM .AND. lAliasMDN
				AAdd(aBaixa, TrazCodMot("LOJ"))
			Else
				AAdd(aBaixa, TrazCodMot("NOR"))
			EndIf
		Endif
	Endif

	SA6->(dbSetOrder(2))
	If SA6->(dbSeek(xFilial("SA6")+Upper(cNomeUser)))
 		cCodCaixa := SA6->A6_COD
 		//LjGrvLog("RECEBIMENTO","Pesquisa do banco - Indice (Filial + Nome Caixa) :" + cFilSA6 + Upper(cNomeUser) + " / Retorno : " + cCodCaixa)
         FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Pesquisa do banco - Indice (Filial + Nome Caixa) :" + cFilSA6 + Upper(cNomeUser) + " / Retorno : " + cCodCaixa )
    ElseIf SA6->(dbSeek(xFilial("SA6",cFilBkp) + Upper(cNomeUser))) // Caso SA6 exclusivo ou "semi-compartilhado" com gestão de empresas via partes de cFilBkp
      	cCodCaixa := SA6->A6_COD
      	//LjGrvLog("RECEBIMENTO","Pesquisa do banco - Indice (Filial + Nome Caixa) :" + cFilBkp + Upper(cNomeUser) + " / Retorno : " + cCodCaixa)
        FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Pesquisa do banco - Indice (Filial + Nome Caixa) :" + cFilBkp + Upper(cNomeUser) + " / Retorno : " + cCodCaixa)
    EndIf

    // Tratamento para o estorno da baixa parcial com juros e com compensação
   	If nVlrJuros == 0 .And. SE1->E1_JUROS > 0
		aOrdSE5 := SE5->(GetArea())
		DbSelectArea("SE5")
		SE5->(DbSetOrder(2)) //E5_FILIAL, E5_TIPODOC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_CLIFOR, E5_LOJA, E5_SEQ
		If SE5->(DbSeek(xFilial("SE5")+"CP"+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
			//LjGrvLog("Recebimento_Titulo", "Antes de atualizar SE5(Tratamento para o estorno da baixa parcial com juros e com compensacao) - SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)",SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
            FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Antes de atualizar SE5(Tratamento para o estorno da baixa parcial com juros e com compensacao) - SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO): "+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) )
			If Reclock("SE5", .F.)
				SE5->E5_VLJUROS += SE1->E1_JUROS
				SE5->(MSUnlock())
			EndIf
			//LjGrvLog("Recebimento_Titulo", "Apos atualizar SE5(Tratamento para o estorno da baixa parcial com juros e com compensacao)")
            FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Apos atualizar SE5(Tratamento para o estorno da baixa parcial com juros e com compensacao)" )
		EndIf
		RestArea(aOrdSE5)
	EndIf

    // Tratamento necessário para recebimentos com baixas parciais e com descontos
	If SE1->E1_SDACRES > 0
		If nVlrRecebido < SE1->(E1_SALDO+E1_SDACRES-nVlrDesconto)
			lAjustaAcres := .T.
			nVlDiferenca := nVlrRecebido - SE1->E1_SALDO
			nVlDiferenca := SE1->E1_SDACRES - nVlDiferenca - nVlrDesconto
		Else
			lAjustaJuros := .T.
			nVlDifJuros	 := SE1->E1_SDACRES
			nVlrJuros += nVlDifJuros
		EndIf
	EndIf

	//Array com os dados para baixa
	AAdd(aBaixa, cCodCaixa)
	AAdd(aBaixa, PadR(SA6->A6_AGENCIA,TamSX3("A6_AGENCIA")[1]))
	AAdd(aBaixa, PadR(SA6->A6_NUMCON,TamSX3("A6_NUMCON ")[1]))
	AAdd(aBaixa, dDataBase)
	AAdd(aBaixa, dDataBase)
	//"Recebimento do Titulo "
	AAdd(aBaixa, "LOJ-"+"Recebimento do Titulo "+cPrefixo+"/"+cNum+"/"+cParcela)
	AAdd(aBaixa, nVlrDesconto)
	AAdd(aBaixa, nVlrMulta)
	AAdd(aBaixa, nVlrJuros)
	AAdd(aBaixa, 0)
	AAdd(aBaixa, nVlrRecebido)
	AAdd(aBaixa, SE1->E1_NUMBCO)

	DbSelectArea("SE1")

	Begin Transaction

	//LjGrvLog("Recebimento_Titulo", "FaBaixaCR - Antes de executar rotina de baixa do financeiro")
    FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "FaBaixaCR - Antes de executar rotina de baixa do financeiro" )

	If cPaisLoc == "BRA"
		cSeq := FaBaixaCR({ nValAbat ,0,0}, aBaixa)  //Gera SE5
	Else
	 	cSeq := FaBaixaCR({ nVlrDesconto,0,0}, aBaixa) //Gera SE5
	EndIf
	
	//LjGrvLog("Recebimento_Titulo", "FaBaixaCR - Apos executar rotina de baixa do financeiro")
    FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "FaBaixaCR - Apos executar rotina de baixa do financeiro" )

	If nValTroco > 0 .And. nLjTrDin != 1 .AND. lTroco
        //Volta a filial do título para a filial corrente para não dar erro no troco que consulta o banco vinculado ao caixa
        If lRecFilial .AND. !Empty(cFilBkp) .And. cFilAnt <> cFilBkp
            cFilAnt    := cFilBkp
        Endif

		//LjGrvLog("Recebimento_Titulo", "Antes de executar a funcao de geracao de troco")
        FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Antes de executar a funcao de geracao de troco" )

		If ExistFunc("LjNewGrvTC") .And. LjNewGrvTC() //Verifica se o sistema está atualizado para executar o novo procedimento para gravação dos movimentos de troco.
			lRet :=  LjTrocoInc(nValTroco	, 1 			 , 3    		, dDatabase		 ,;
								cCodCaixa	, Nil			 , Nil			, SE1->E1_PREFIXO,;
								SE1->E1_NUM	, SE1->E1_PARCELA, Nil 			, Nil			 ,;
								Nil			, Nil			 , SE1->E1_LOJA , SE1->E1_CLIENTE )
			If !lRet
				Disarmtransaction()
			EndIf
		Else
			AtuaTroco(	nValTroco		,1				,3				,SE1->E1_CLIENTE	,;
						SE1->E1_LOJA	,/*aTitulo*/	,cCodCaixa 	,Nil				,;
						Nil				)
		EndIf
		//LjGrvLog("Recebimento_Titulo", "Apos executar a funcao de geracao de troco")
        FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Apos executar a funcao de geracao de troco" )
		
		//Volta a filial do título
		If lRecFilial .AND. cFilAnt <> cFilialTit .AND. !lFinancComp
			cFilBkp    := cFilAnt

			If !Empty(cFilialTit)
				cFilAnt    := cFilialTit
				//LjGrvLog("Recebimento_Titulo", "Volta a filial do título | cFilAnt",cFilAnt)
			EndIf

		Endif
	EndIf
	
	If lRet

		//LjGrvLog("Recebimento_Titulo", "Antes de atualizar dados da Tabela SE5. SE5->(Recno()):",SE5->(Recno()) )
        FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Antes de atualizar dados da Tabela SE5. SE5->(Recno()): " + toString(SE5->(Recno())) )
		
		RecLock("SE5",.F.)
		REPLACE SE5->E5_MOEDA	WITH AllTrim(cFrmPag)
		REPLACE SE5->E5_BANCO	WITH cCodCaixa
		REPLACE SE5->E5_AGENCIA	WITH SA6->A6_AGENCIA
		REPLACE SE5->E5_CONTA	WITH SA6->A6_NUMCON
		REPLACE SE5->E5_FORMAPG	WITH AllTrim(cFrmPag)
		If cPaisLoc <> "BRA"
			REPLACE SE5->E5_ORDREC WITH LjGetStation("LG_PDV") + SubStr(cRecibo, 5, 8)//cRecibo
			REPLACE SE5->E5_SERREC WITH cSerieRec
		EndIf
		If Empty(SE5->E5_FILORIG)
			REPLACE SE5->E5_FILORIG WITH cFilAntBkp
		EndIf
		If	AllTrim(cFrmPag) == AllTrim(MVCHEQUE) .And. ;
			!Empty(cNumCheque)
			REPLACE SE5->E5_NUMCHEQ WITH cNumCheque
		EndIf

		REPLACE SE5->E5_ORIGEM WITH "LOJXREC"

		If lAcreDecre
			Replace E5_VLACRES   With Round(NoRound(xMoeda(SE1->E1_SDACRES,SE1->E1_MOEDA,1,SE1->E1_MOVIMEN,3,SE1->E1_TXMOEDA),3),2)
			Replace E5_VLDECRE   With Round(NoRound(xMoeda(SE1->E1_SDDECRE,SE1->E1_MOEDA,1,SE1->E1_MOVIMEN,3,SE1->E1_TXMOEDA),3),2)
		Endif

		If nVlrMulta > 0
			Replace SE5->E5_VLMULTA With nVlrMulta
		Endif

		If nVlrJuros > 0
			Replace SE5->E5_VLJUROS With nVlrJuros
		Endif

		If nVlrDesconto > 0
			Replace SE5->E5_VLDESCO With nVlrDesconto
		Endif

		REPLACE SE5->E5_NUMMOV	WITH cNumMov

		SE5->( MsUnlock() )
		nRecnoSE5  := SE5->( Recno() )
		
		// Se tiver Juros, Multa e/ou Deconto grava a Forma de pagamento nos demais registros
		If nVlrMulta > 0 .OR. nVlrJuros > 0 .OR. nVlrDesconto > 0
		
		LjGrFormPg( nRecnoSE5, cFrmPag, SE5->E5_ORIGEM , SE5->E5_FILIAL )
		
		EndIf
		
		//LjGrvLog("Recebimento_Titulo", "Apos de atualizar dados da Tabela SE5")
        FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Apos de atualizar dados da Tabela SE5" )

		SE1->(DbSetOrder(1))
		SE1->(DbGoto(nRecnoSE1))
		
		//LjGrvLog("Recebimento_Titulo", "Antes de atualizar dados da Tabela SE1. SE1->(Recno()):",nRecnoSE1)
        FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Antes de atualizar dados da Tabela SE1. SE1->(Recno()): "+toString(nRecnoSE1) )
		Reclock("SE1",.F.)

		// Tratamento necessário para recebimentos com baixas parciais
		If lAjustaAcres
			nVlDiferenca := iIf(SE1->E1_SDACRES < nVlDiferenca, SE1->E1_SDACRES, nVlDiferenca)
			SE1->E1_SALDO += nVlDiferenca
		EndIf
		If lAjustaJuros
			SE1->E1_JUROS -= nVlDifJuros
		EndIf
		SE1->E1_SDACRES	:= 0
		SE1->( MsUnlock() )
		
		//LjGrvLog("Recebimento_Titulo", "Apos atualizar dados da Tabela SE1. SE1->E1_SALDO",SE1->E1_SALDO)
        FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Apos atualizar dados da Tabela SE1. SE1->E1_SALDO: "+toString(SE1->E1_SALDO) )

		//================================
		//Atualiza saldo do BANCO Caixa
		//================================

		If IsMoney(SE5->E5_MOEDA)
			//LjGrvLog("Recebimento_Titulo", "AtuSalBco - Antes de executar rotina AtuSalBco - Tabelas envolvidas: SA6 e SE8")
            FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "AtuSalBco - Antes de executar rotina AtuSalBco - Tabelas envolvidas: SA6 e SE8" )
			AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,"+")
			//LjGrvLog("Recebimento_Titulo", "AtuSalBco - Apos executar rotina AtuSalBco")
            FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "AtuSalBco - Apos executar rotina AtuSalBco" )
		EndIf	

		//Somente alimenta aqui o array aSE5Dados, caso nao seja executado via Web Service
		//Quando executado via Web Service, o array aSE5Dados eh alimentado em outro momento
		If lPgTef .AND. !lWS 

			For nX = 1 To Len(aPgtos)

				cForma  := AllTrim(aPgtos[nX,3])

				//ID do Cartao               // CC;CD
				If (Empty(aPgtos[nX, 8]) .AND. !(cForma $ _FORMATEF)) .Or. ;
				( AllTrim(cForma) <> alltrim(cFrmPag) .OR. ( !lTEFMult .or. Empty(cIdCart) .or. (cIdCart <> aPgtos[nX][8]) ) )
					Loop
				EndIf

				nPosRetCart := 0
				aAuxDados	:= {}

				If cForma $ _FORMATEF .And. cTipTef == TEF_CLISITEF  .AND. lUsaTef
					nPosRetCart := Iif(lTefMult, aScan(oTef:aRetCartao, {|x| x:CIDCART == aPgtos[nX][8] } ), 1)
				ElseIf lUsaTef .AND. cForma $ _FORMATEF .And. cTipTef == TEF_DISCADO
					nPosRetCart := Iif(lTefMult, aScan(aTEFDados, {|x| x[19] == aPgtos[nX][8] } ), 1)
				EndIf

				LjxRTefDa(	@aAuxDados	,	aPgtos	,	aNSUVndTef	,	lUsaTef ,;
							cTipTef		,	8	 	,	nPosRetCart , 	nX		,;
							aPagDig		)

				nY			:= 1
				cNSUTEFAux	:= aAuxDados[nY][6]
				cAutTEFAux	:= aAuxDados[nY][4]
				nPosAux		:= aScan(aSE5Dados , {|x| (x[1]+x[2]+x[3]+x[4]+x[7]+x[8]+x[5]+x[16]+x[14]) ==;
								(SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIENTE+SE5->E5_LOJA+SE5->E5_SEQ+cNSUTEFAux+cAutTEFAux) } )

				If nPosAux == 0
					AADD(aSE5Dados,	{	SE5->E5_PREFIXO		,;				//01-E5_PREFIXO
										SE5->E5_NUMERO 		,;				//02-E5_NUMERO
										SE5->E5_PARCELA		,;				//03-E5_PARCELA
										SE5->E5_TIPO		,;				//04-E5_TIPO
										SE5->E5_SEQ			,;				//05-E5_SEQ
										SE5->E5_FILORIG		,;				//06-E5_FILORIG
										SE5->E5_CLIENTE		,;				//07-E5_CLIENTE
										SE5->E5_LOJA		,;				//08-E5_LOJA
										cForma				,;				//09-Forma Pgto.
										aPgtos[nX, 2]		,;				//10-Valor
										aAuxDados[nY][1]	,;				//11-Data
										aAuxDados[nY][2]	,;				//12-Hora
										aAuxDados[nY][3]	,;				//13-Doc
										aAuxDados[nY][4]	,;				//14-Autorizacao
										aAuxDados[nY][5]	,;				//15-Instituicao
										aAuxDados[nY][6]	,;				//16-NSU
										aAuxDados[nY][7]	,;				//17-Tipo do cartao
										"" 					,;				//18-SEQOPER
										nRecnoSE5 			,;				//19-RECSE5 - Recno do registro SE5
										"" 					,; 				//20-Doc Cancelamento TEF
										"" 					,; 				//21-Hora Cancelamento TEF
										"" 					,; 				//22-Data Cancelamento TEF
										Iif(Len(aAuxDados[nY])>=10,aAuxDados[nY][ 9],"")	,;	//23-Código da Bandeira
										Iif(Len(aAuxDados[nY])>=10,aAuxDados[nY][10],"")	,;	//24-Código Rede (Adquirência)
										Iif(Len(aAuxDados[nY])>10, aAuxDados[nY][11],"")	,;	//25-Id da transação do Totvs Pagamento Digital (TRNID)
										Iif(Len(aAuxDados[nY])>10, aAuxDados[nY][12],"")	,;	//26-Id da transação do processador do Totvs Pagamento Digital (TRNPCID)
										Iif(Len(aAuxDados[nY])>10, aAuxDados[nY][13],"")	})	//27-Id externa da transação do Totvs Pagamento Digital (TRNEXID)
				Else
					aSE5Dados[nPosAux][10] += aPgtos[nX, 2] //10-Valor
				EndIf
			Next nX
		EndIf

		//======================================================================
		// Guarda o Recno dos registro de baixas gerados sendo ou noa TEF     
		//======================================================================
		aAdd( aSE5Bxas		, { SE5->( Recno() ) } )
		aAdd( aTitBxSE5		, { SE5->( Recno() ) } )
		aAdd( aTitDelSE5	, {	SE5->( Recno() )	, SE5->E5_PREFIXO	, SE5->E5_NUMERO	, SE5->E5_PARCELA	,;
								SE5->E5_TIPO		, SE5->E5_CLIFOR	, SE5->E5_LOJA		, SE5->E5_SEQ		} )

		//======================================================================
		// Incluida a gravacao da moeda, para possibilitar a demonstracao dos 
		// detalhes dos titulos Recebidos por essa rotina no Resumo de Caixa  
		//======================================================================
		If ( lRecFilial .AND. aBaixa[1] == TrazCodMot("LOJ") .AND. !Empty( cFilBkp ) ) .OR.;
			( cFilAnt == cFilialTit .AND. Empty( cFilBkp ) .AND. ( IsMoney(cFrmPag) .OR. (AllTrim(cFrmPag) $ cMvTpRec) ) ) .OR.;
			( lFinancComp .AND. cFilAnt <> cFilialTit .AND. ( IsMoney(cFrmPag) .OR. (AllTrim(cFrmPag) $ cMvTpRec) ) )

			//LjGrvLog("Recebimento_Titulo", "Entrou na condicao para tratamento de baixa entre filiais - 1",cPrefixo+"/"+cNum+"/"+cParcela+"/"+cTipo)
			FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Entrou na condicao para tratamento de baixa entre filiais - 1: "+cPrefixo+"/"+cNum+"/"+cParcela+"/"+cTipo )

			DbSelectArea( "SE5" )
			SE5->(DbSetOrder( 2 ))
			SE5->(DbGoto(nRecnoSE5)) 		// Alteracao para pegar o correto alias

			If	( ( lRecFilial .AND. (cMV_LJRECEB == "3" .OR. cMV_LJRECEB == "1") ) .OR.;
				( lFinancComp .AND. !lRecFilial .AND. (cMV_LJRECEB == "3" .OR. cMV_LJRECEB == "1") ) ) .OR.;
				( ( xFilial( "SE5" ) == SE5->E5_FILORIG .And. IsMoney(SE5->E5_MOEDA) .And. (cMV_LJRECEB == "3" .OR. cMV_LJRECEB == "1") ) )
				// A condicao "E5_FILIAL=E5_FILORIG e E5_MOEDA=DINHEIRO e cMV_LJRECEB=1 OU 3",
				// segue as orientacoes acima descritas no fonte, para geracao dos registros "BA" e "VL",
				//LjGrvLog("Recebimento_Titulo", "Entrou na condicao para tratamento de gravacao dos registros SE5 'BA' e 'VL'")
				FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Entrou na condicao para tratamento de gravacao dos registros SE5 'BA' e 'VL'" )

				While SE5->( !Eof() ) .AND. ;
					xFilial( "SE5" )	== xFilial( "SE5" ) 	.AND. ;
					"BA" 		 		== SE5->E5_TIPODOC		.AND. ;
					cPrefixo         	== SE5->E5_PREFIXO		.AND. ;
					cNum             	== SE5->E5_NUMERO 		.AND. ;
					cParcela         	== SE5->E5_PARCELA 		.AND. ;
					cTipo 		 		== SE5->E5_TIPO

					//LjGrvLog("Recebimento_Titulo", "Entrou no While SE5 TIPODOC = BA. cPrefixo/cNum/cParcela/cTipo",cPrefixo+"/"+cNum+"/"+cParcela+"/"+cTipo)
                    FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Entrou no While SE5 TIPODOC = BA. cPrefixo/cNum/cParcela/cTipo: "+cPrefixo+"/"+cNum+"/"+cParcela+"/"+cTipo )
					//=============================================================================
					// Incluir um titulo para a filal corrente exatamente igual ao titulo tipo BA  
					// lancado para a filial que originou o titulo.                                
					//=============================================================================
					If (SE5->E5_VALOR <> nVlrRecebido .AND. ( (SE5->E5_VALOR - nVlrRecebido) > 0.01 .OR. (nVlrRecebido - SE5->E5_VALOR) > 0.01 ) ) .OR. nRecnoSE5 <> SE5->(Recno())
						//LjGrvLog("Recebimento_Titulo", "Realizou SE5->(Dbskip()). SE5->(Recno()): ",SE5->(Recno()))
                        FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Realizou SE5->(Dbskip()). SE5->(Recno()): "+toString(SE5->(Recno())) )
						SE5->(Dbskip())
						Loop
					Endif

					If SE5->E5_SITUACA <> "C" .AND. SE5->E5_RECPAG == "R"

						//LjGrvLog("Recebimento_Titulo", "Entrou If SE5->E5_SITUACA <> 'C' .AND. SE5->E5_RECPAG == 'R'. Antes de Atualizar SE5")
                        FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Entrou If SE5->E5_SITUACA <> 'C' .AND. SE5->E5_RECPAG == 'R'. Antes de Atualizar SE5" )
						//====================================================================
						//| Grava no mov. bancario (baixa) a filial que originou o titulo  |
						//====================================================================
						SE1->(DbGoto(nRecnoSE1))
						RecLock("SE5",.F.)
						SE5->E5_FILORIG := SE1->E1_FILORIG
						SE5->( MsUnlock() )
						//LjGrvLog("Recebimento_Titulo", "Entrou If SE5->E5_SITUACA <> 'C' .AND. SE5->E5_RECPAG == 'R'. Apos Atualizar SE5")
                        FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Entrou If SE5->E5_SITUACA <> 'C' .AND. SE5->E5_RECPAG == 'R'. Apos Atualizar SE5" )
						
                        For nX := 1 to nCount
							cCampo := SE5->(FieldName(nX))
							If !Upper(RTrim(cCampo)) $ "E5_IDORIG\E5_MOVFKS\E5_TABORI"
								AAdd( aDadosSE5, {cCampo,SE5->(FieldGet(nX))} )
							EndIf
						Next nX

						If Len(aDadosSE5) > 0
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_FILIAL "} ) ][2] := FwxFilial("SE5",IIf( Empty( cFilBkp ), cFilialTit, cFilBkp))
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_TIPODOC"} ) ][2] := IIf( (IsMoney(cFrmPag) .OR. (AllTrim(cFrmPag) $ cMvTpRec) ), "VL", "BA" )
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_MOTBX  "} ) ][2] := IIf( (IsMoney(cFrmPag) .OR. (AllTrim(cFrmPag) $ cMvTpRec) ), TrazCodMot("NOR"), TrazCodMot("LOJ") )
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_FILORIG"} ) ][2] := IIf( Empty( cFilBkp ), cFilOrig, cFilBkp )
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_SEQ    "} ) ][2] := cSeq
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_MOEDA  "} ) ][2] := AllTrim(cFrmPag)
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_ORIGEM "} ) ][2] := "LOJXREC"
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_FORMAPG"} ) ][2] := AllTrim(cFrmPag)
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_KEY    "} ) ][2] := aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == PadR("E5_PREFIXO",10)} ) ][2] + ;
																									aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == PadR("E5_NUMERO",10)} ) ][2] + ;
																									aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == PadR("E5_PARCELA",10)} ) ][2] + ;
																									aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == PadR("E5_TIPO",10)} ) ][2] +;
																									aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == PadR("E5_CLIENTE",10)} ) ][2] + ;
																									aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == PadR("E5_LOJA",10)} ) ][2]
							nValVL := SE5->E5_VALOR 
							If nLjTrDin = 0 .AND. lTroco
								nValVL += nValTroco
							EndIf
							aDadosSE5[ aScan( aDadosSE5,{|x| PadR(x[1],10) == "E5_VALOR  "} ) ][2] := IIF(nMoeda > 1, xMoeda(nValVL, 1, nMoeda, dDataBase, 3), nValVL)
							RecLock( "SE5",.T. )
							For nX := 1 to Len( aDadosSE5 )
								FieldPut( ColumnPos( aDadosSE5[nX][1] ) , aDadosSE5[nX][2] )
							Next nX
							SE5->( MsUnlock() )  
							
							//Gera FKs com base na SE5 gerada
							FINXSE5( SE5->( Recno() ) , 1 )	//Movimento Bancario

							//Compatibiliza as Fks com padrao do loja
							LjCompFKs()
	
							aAdd( aTitBxSE5		, { SE5->( Recno() ) } )
							aAdd( aTitDelSE5	, {	SE5->( Recno() )	, SE5->E5_PREFIXO	, SE5->E5_NUMERO	, SE5->E5_PARCELA	,;
													SE5->E5_TIPO		, SE5->E5_CLIFOR	, SE5->E5_LOJA		, SE5->E5_SEQ		} )	//
							Exit
						EndIf
					EndIf
					SE5->( DbSkip() )
				End
			EndIf
		EndIf

		//====================================================================
		// Grava os valores de desconto, multa e juros no titulo baixado. 
		// Preve a situacao em que duas ou mais parcelas baixam o mesmo   
		// titulo - BOPS 90.118                                           
		//====================================================================
		If !lPrimBaixa
		SE1->(DbSetOrder(1))
		SE1->(DbGoto(nRecnoSE1))
		Reclock("SE1",.F.)
		REPLACE SE1->E1_VALLIQ WITH nTotReceb
		If nPrimMulta > 0 .OR. nPrimJuros > 0 .OR. nPrimDescon > 0
			REPLACE SE1->E1_DESCONT WITH nPrimDescon
			REPLACE SE1->E1_MULTA   WITH nPrimMulta
			REPLACE SE1->E1_JUROS   WITH nPrimJuros
		Endif
		SE1->( MsUnlock() )
		Endif
	
	EndIf

	End Transaction

	cFilAnt   := cFilAntBkp
ElseIf cMV_LJRECEB == "4"
	//======================================================================================
	// Se nao encontrar o SE1 e for baixa de titulo EMS cria uma movimentacao bancaria SE5 
	//======================================================================================
	Reclock("SE5",.T.)
	Replace SE5->E5_FILIAL	WITH xFilial("SE5")
	Replace SE5->E5_DATA	WITH dDataBase
	Replace SE5->E5_TIPO	WITH "FI"
	Replace SE5->E5_BANCO	WITH xNumCaixa()
	Replace SE5->E5_AGENCIA	WITH SA6->A6_AGENCIA
	Replace SE5->E5_CONTA	WITH SA6->A6_NUMCON
	Replace SE5->E5_RECPAG	WITH "R"
	//======================================================================================
	// Recebimento do Titulo                                                                
	//======================================================================================
	Replace SE5->E5_HISTOR	WITH "Recebimento do Titulo "+cPrefixo+"/"+cNum+"/"+cParcela
	Replace SE5->E5_TIPODOC	WITH "VL"
	Replace SE5->E5_MOEDA	WITH AllTrim(cFrmPag)
	If SE5->(FieldPos("E5_FORMAPG")) > 0
		REPLACE SE5->E5_FORMAPG	WITH AllTrim(cFrmPag)
	EndIf
	If SE5->(FieldPos("E5_ORIGEM")) > 0
		REPLACE SE5->E5_ORIGEM	WITH "LOJXREC"
	EndIf
	Replace SE5->E5_VALOR	WITH nValRec
	Replace SE5->E5_DTDIGIT	WITH dDataBase
	Replace SE5->E5_BENEF	WITH Space(15)
	Replace SE5->E5_DTDISPO	WITH SE5->E5_DATA
	Replace SE5->E5_NATUREZ	WITH cNatureza

	If SE5->(FieldPos("E5_NUMMOV")) > 0
		REPLACE SE5->E5_NUMMOV	WITH cNumMov
	EndIf

	SE5->( dbCommit() )
	SE5->( MsUnLock() )
	lRet := .T.
EndIf

//================================================================
// Ponto de entrada chamado no final da gravacao na retaguarda
//================================================================
If lLjRecBxFim
	ExecBlock( "LJRECBXFIM", .F., .F., { aSE5Bxas } )
Endif

SE5->(DbCloseArea())
SE1->(DbCloseArea())

SA6->(RestArea(aAreaSA6)) //Deve retornar a área da SA6 para evitar que na ExecAuto do FINA040 seja pesquisado um índice errado

//LjGrvLog( "RECEBIMENTO", "Fim da baixa do título: "+cFilialTit+"/"+cPrefixo+"/"+cNum+"/"+cParcela+"/"+cTipo, SE1->E1_SALDO)
FwLogMsg("INFO", /*cTransactionId*/,  "ULJRECBX", FunName(), "", "01", "Fim da baixa do título: "+cFilialTit+"/"+cPrefixo+"/"+cNum+"/"+cParcela+"/"+cTipo+": "+toString(SE1->E1_SALDO) )

Return(lRet)

//--------------------------------------------
// Funcao para transformar variavis em string
// muito util para conouts, ver arrays.
//--------------------------------------------
Static Function toString(xValue)

	Local cRet, nI, cType

	cType := valType(xValue)

	DO CASE
		case cType == "C"
			return '"'+ xValue +'"'
		case cType == "N"
			return CvalToChar(xValue)
		case cType == "L"
			return if(xValue,"true","false")
		case cType == "D"
			return '"'+ DtoC(xValue) +'"'
		case cType == "U"
			return "null"
		case cType == "A"
			cRet := '['
			For nI := 1 to len(xValue)
				if(nI != 1)
					cRet += ', '
				endif
				cRet += U_toString(xValue[nI])
			Next
			return cRet + ']'
		case cType == "B"
			return '"Type Block"'
		case cType == "M"
			return '"Type Memo"'
		case cType =="O"
  			return '"Type Object"'
  		case cType =="H"
	  		return '"Type Object"'
	ENDCASE


return "invalid type"

/*/{Protheus.doc} LjRecFinComp
Verifica se os arquivos SE1 e SE5 sao compartilhados. Esta
informacao sera utilizada para determinar se deve gerar um 
registro no SE5 do tipo BA(E5_TIPODOC) na filial em que foi
gerado o titulo a receber. Se forem exclusivos, deve gerar.
@type function
@version 1.0
@author g.sampaio
@since 14/12/2023
@return variant, return_description
/*/
Static Function LjRecFinComp()

Local lCompartil := .F.   //Verifica se os arquivos SE1 e SE5 sao compartilhados

lCompartil := FWModeAccess("SE1",3) == "C"
If lCompartil
	lCompartil := FWModeAccess("SE5",3) == "C"
Endif

Return lCompartil

//--------------------------------------------------------
/*/{Protheus.doc} LjGrFormPg
Responsável por gravar os campos E5_FORMAPG, E_ORIGEM e E5_FILORIG referene aos registros de Juros, Multa e Desconto
no Recebimento de Titulo
    
@author  João Marcos Martins
@version P12.1.17
@since   15/03/2018
@return  
/*/
//--------------------------------------------------------
Static Function LjGrFormPg( nRecnoSE5, cFrmPag, cOrigem ,cFilAntSE5 )

Local aAreaSE5 := SE5->( GetArea() )
Local cChave   := SE5->E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_CLIFOR + SE5->E5_LOJA

SE5->( dbSetOrder(7) )
    
If SE5->( dbSeek(cChave) )  
    
    While SE5->(!EOF()) .AND. SE5->E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_CLIFOR + SE5->E5_LOJA == cChave
        
        If Empty(SE5->E5_FORMAPG)           
            RecLock("SE5",.F.)
            SE5->E5_FORMAPG := AllTrim(cFrmPag)
            SE5->E5_ORIGEM  := cOrigem
            If Empty(SE5->E5_FILORIG)
                SE5->E5_FILORIG := cFilAntSE5
            EndIf
            SE5->( MsUnlock() ) 
        EndIf
        
        SE5->( dbSkip() )   
            
    EndDo
        
EndIf
        
RestArea( aAreaSE5 )

Return

//--------------------------------------------------------
/*/{Protheus.doc} LjCompFKs
Altera os campos para utilizar o padrao do SigaLoja
	
@author  Leandro Kenji
@version P12.1.17
@since   13/11/2017
@return  n/a
/*/
//--------------------------------------------------------
Static Function LjCompFKs()

Local aArea			:= GetArea()
Local aAreaFKA		:= FKA->( GetArea() )
Local cProcFKA		:= FKA->FKA_IDPROC
Local cRotBx		:= "LOJXREC" 

//Atualiza campos das FKs
dbSelectArea("FKA")
FKA->( dbSetOrder(2) )
FKA->( dbSeek( xFilial("FKA") + cProcFKA ) )
While FKA->( !EOF() ) .AND. ( xFilial("FKA") + cProcFKA == FKA->FKA_FILIAL + FKA->FKA_IDPROC )

	If FKA->FKA_TABORI == "FK1"
	
		//Posiciona na tabela e altera os campos
		DbSelectArea("FK1")
		FK1->( dbSetOrder(1) )
		If FK1->( dbSeek( xFilial("FK1") + FKA->FKA_IDORIG ) )

			RecLock("FK1",.F.)
			FK1->FK1_ORIGEM := cRotBx
			FK1->( MsUnLock() )

		EndIf

	ElseIf FKA->FKA_TABORI == "FK5"

		//Posiciona na tabela e altera os campos
		DbSelectArea("FK5")
		FK5->( dbSetOrder(1) )
		If FK5->( dbSeek( xFilial("FK5") + FKA->FKA_IDORIG ) )

			RecLock("FK5",.F.)
			FK5->FK5_ORIGEM := cRotBx
			FK5->( MsUnLock() )

		EndIf

	ElseIf FKA->FKA_TABORI == "FK3"
	
		//Posiciona na tabela e altera os campos
		DbSelectArea("FK3")
		FK3->( dbSetOrder(1) )
		If FK3->( dbSeek( xFilial("FK3") + FKA->FKA_IDORIG ) )

			RecLock("FK3",.F.)
			FK3->FK3_ORIGEM := cRotBx
			FK3->( MsUnLock() )

		EndIf


	ElseIf FKA->FKA_TABORI == "FK4"

		//Posiciona na tabela e altera os campos
		DbSelectArea("FK4")
		FK4->( dbSetOrder(1) )
		If FK4->( dbSeek( xFilial("FK4") + FKA->FKA_IDORIG ) )

			RecLock("FK4",.F.)
			FK4->FK4_ORIGEM := cRotBx
			FK4->( MsUnLock() )

		EndIf


	EndIf

	FKA->( dbSkip() )

End

RestArea(aAreaFKA)
RestArea(aArea)

Return

/*/{Protheus.doc} BuscaTerreno
Funcao para retornar a natureza do produto de terreno
@type function
@version 1.0 
@author g.sampaio
@since 04/10/2021
@param cCodContrato, character, codigo do contrato
@return character, natureza do produto de terreno
/*/
Static Function BuscaTerreno(cCodContrato)

	Local cQuery 		:= ""
	Local cRetorno		:= ""

	cQuery := " SELECT "
	cQuery += " SB1.B1_XNATURE NATUREZA "
	cQuery += " FROM " + RetSQLName("U01") + " U01 "
	cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 ON SB1.D_E_L_E_T_  = ' ' "
	cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += " AND SB1.B1_COD = U01.U01_PRODUT "
	cQuery += " AND SB1.B1_XTPCEM = '4'"
	cQuery += " AND SB1.B1_XNATURE <> ' ' "
	cQuery += " WHERE U01.D_E_L_E_T_ = ' ' "
	cQuery += " AND U01.U01_FILIAL = '" + xFilial("U01") + "' "
	cQuery += " AND U01.U01_CODIGO = '" + cCodContrato + "' "
	cQuery += " AND U01.U01_VLRTOT > 0 "
	cQuery += " GROUP BY SB1.B1_XNATURE "

	MPSysOpenQuery( cQuery, "TRBTER" )

	if TRBTER->(!Eof())
		cRetorno := TRBTER->NATUREZA
	endIf

Return(cRetorno)

/*/{Protheus.doc} PrcTerreno
Funcao para retornar o preco do produto de terreno
@type function
@version 1.0
@author g.sampaio
@since 04/10/2021
@param cCodContrato, character, codigo do contrato
@return numeric, preco do produto de terreno
/*/
Static Function PrcTerreno(cCodContrato)

	Local aArea			:= GetArea()
	Local aAreaU00		:= U00->(GetArea())
	Local cQuery 		:= ""
	Local cCodTabela  	:= SuperGetMV("MV_XTABPAD",.F.,"001") // tabela de preco padrao
	Local cProduto		:= ""
	Local nRetorno		:= 0

	cQuery := " SELECT "
	cQuery += " SB1.B1_COD PRODUTO "
	cQuery += " FROM " + RetSQLName("U01") + " U01 "
	cQuery += " INNER JOIN " + RetSQLName("SB1") + " SB1 ON SB1.D_E_L_E_T_  = ' ' "
	cQuery += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery += " AND SB1.B1_COD = U01.U01_PRODUT "
	cQuery += " AND SB1.B1_XTPCEM = '4'"
	cQuery += " AND SB1.B1_XNATURE <> ' ' "
	cQuery += " WHERE U01.D_E_L_E_T_ = ' ' "
	cQuery += " AND U01.U01_FILIAL = '" + xFilial("U01") + "' "
	cQuery += " AND U01.U01_CODIGO = '" + cCodContrato + "' "
	cQuery += " AND U01.U01_VLRTOT > 0 "
	cQuery += " GROUP BY SB1.B1_COD "

	MPSysOpenQuery( cQuery, "TRBTER" )

	if TRBTER->(!Eof())
		cProduto := TRBTER->PRODUTO
	endIf

	// posiciono no cadastro do contrato
	U00->(DbSetOrder(1))
	if U00->( MsSeek( xFilial("U00")+cCodContrato ) )

		// codigo da tabel de preco do plnao
		cCodTabela := Posicione("U05",1,xFilial("U05")+U00->U00_PLANO,"U05_TABPRE")

	endIf

	// retorno o preco do produto da tabela de precos
	nRetorno := U_RetPrecoVenda( cCodTabela, cProduto, .F. )

	RestArea(aAreaU00)
	RestArea(aArea)

Return(nRetorno)

/*/{Protheus.doc} VirtusFin::ULJEstBx
Realiza o estorno de baixas, sendo chamado do PDV e executado na retaguarda via compontente de comunicacao do POS

@type function
@version 12.1.33
@author Pablo C Nunes
@since 01/06/2022

@param	aListDropTitles	Array com a lista de titulos baixados que deseja estornar
@param	cCashier		Codigo do caixa
/*/
Method ULJEstBx(aListDropTitles, cCashier, aMDMLote, aListTit) Class VirtusFin

Local lSemErro	:= .F.
Local nValor	:= 0
Local aVlCompEst:= {}
Local aSe5Est	:= {}
Local cErro		:= ""
Local aRetorno	:= {}

Default aListDropTitles   	:= {}
Default cCashier 			:= ""
Default aMDMLote			:= {}
Default aListTit			:= aClone(aListDropTitles)

// Alterna tipo de operacao: Recebimento/Estorno
cOper	:= "2"
aTitulo := Aclone(aListDropTitles)

// mensagens no console log 
FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", " ###################################################### " )
FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", " INICIO DO PROCESSO DE ESTORNO DE BAIXA DE TITULOS: ULJEstBx " )
FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", " DATA: " + DTOC( Date() ) + " HORA: " + Time() + " " )
FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", " EMPRESA: " + Alltrim(CEMPANT) + " FILIAL: " + Alltrim(CFILANT) + " " )
FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", " ###################################################### " )

//LjGrvLog( "Recebimento_Titulo", "Processo de ESTORNO - Inicio - aListDropTitles",aListDropTitles)
FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "Processo de ESTORNO - Inicio - aListDropTitles: "+toString(aListDropTitles) )

LjRecCancBx(	@nValor		, lSemErro 	, @cErro		, {}	,;
				.F.			, .T.		, cCashier	, .T.	,;
				@aVlCompEst	, @aSe5Est	, aMDMLote  , aListTit)
				
//LjGrvLog( "Recebimento_Titulo", "Processo de ESTORNO - Final  - aRetorno ",aRetorno)
FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "Processo de ESTORNO - Final  - aRetorno: "+toString(aRetorno) )

aRetorno := {aVlCompEst,aSe5Est, cErro, aMDMLote, nValor}

Return aRetorno

/*/{Protheus.doc} LjRecCancBx
Estorna as baixas dos titulos selecionados   
LjRecCancBx(ExpN1, ExpL2, ExpC3, ExpA4, ExpL5)  
ExpN1 - valor total das baixas estornadas	
ExpL2 - controla se houve erro no estorno de alguma baixa
ExpC3 - dados dos titulos cujo estorno nao foi executado	
ExpA4 - dados dos recebimentos estornados     
ExpL5 - indica se e cancelam. de cupom Tef (opcional)  
@type function
@version  
@author g.sampaio
@since 14/12/2023
@param nValorTot, numeric, param_description
@param lSemErro, logical, param_description
@param cErros, character, param_description
@param aDadosEst, array, param_description
@param lCancTef, logical, param_description
@param lWs, logical, param_description
@param cNomeUser, character, param_description
@param lSelecTit, logical, param_description
@param aVlCompEst, array, param_description
@param aSe5Est, array, param_description
@param aLotesMDM, array, param_description
@param aListTit, array, param_description
@return variant, return_description
/*/
Static Function LjRecCancBx(	nValorTot	, lSemErro	, cErros	, aDadosEst	,;
		lCancTef	, lWs		, cNomeUser	, lSelecTit	,;
		aVlCompEst	, aSe5Est	,aLotesMDM  , aListTit)

	Local aBaixa     	:= {}                     	//Array do SE1 para chamada da rotina automatica
	Local aBaixaTit  	:= {}                     	//Array com os dados das baixas de um mesmo titulo
	Local aBxTit		:= {}
	Local aAreaSE1		:= {}
	Local aAreaSE5		:= {}
	Local nX         	:= 0                        //Controle de loop
	Local nY			:= 0
	Local nOpBaixa   	:= 0                      	//Baixa selecionada quando ha mais de uma baixa para um mesmo titulo
	Local nTamSE5Num 	:= TamSX3("E5_NUMERO")[1]  	//Tamanho do campo E5_NUMERO
	Local cListBox                              	//List box com os dados dos titulos a receber que tem mais de uma baixa
	Local oDlg                                  	//Caixa de dialogo quando ha mais de uma baixa para o titulo a receber
	Local lFoundSE5  	:= .F.                     	//Controla se o registro da baixa do titulo foi encontrado
	Local lChkslv     	:= ChkFile("SLV")			//Retorna se o arquivo SLV foi criado
	Local cNumCaixa		:= xNumCaixa()				//Caixa que efetuou o estorno.
	Local cMDMOper		:= "2"						// Tipo de gravacao no MDM 1=Inclusao 2= Alteracao
	Local lRecFilial	:= SuperGetMV("MV_LJRECFI",,.F. ) 		// Controla se trata todas as filiais(Logico)
	Local lAliasMDM		:= AliasIndic("MDM")
	Local lAliasMDN     := AliasIndic("MDN")
	Local cMDMLote		:= IIf(lAliasMDM, Space(TamSX3("MDM_LOTE")[1]), Space(6))
	Local cTipoDoc		:= ""
	Local lEstParc      := .F.                      //Verifica se foi feito estorno parcial
	Local cOrdRec		:= ""
	Local cSerRec		:= ""
	Local nPosTit		:= 1
	Local aBxSE5Bkp		:= {}
	Local lTroco		:= .F.
	Local nValTroco		:= 0
	Local nPosDelSE5	:= 1
	Local cLjOpEst		:= SuperGetMV("MV_LJOPEST",,"1" )// Controla se fara ou não o estorno de compesações de crédito
	Local aTotaisBkp	:= IIF(Type("aTotais") == "A", aClone(aTotais), NIL) //Backup da variavel private aTotais
	Local nEstTroco     := 0  //Guarda o Recno do Troco para usar após a conclusão do processo de estorno
	Local lSelLot		:= .f. //Lote já selecionado
	Local cMsgErro		:= "" //mensagem de erro do estorno TEF
	Local aSE5Selec 	:= {}
	Local lGestao       := FWSizeFilial() > 2
	Local lSe1Exc       := lGestao .And. FWModeAccess("SE1",3) == "E"
	Local lRetGrvMDX	:= .T. // Retorno da Função LjxGrvMDX
	Local aTitBaixad	:= {}  // Array com Títulos Baixados que não podem ser Estornados
	Local cTextBaix		:= ""  // Texto com Títulos já Baixados que será apresentado, após tentativa de Estorno
	Local aTitEstorn	:= {}  // Array com Títulos Estornados
	Local cTextEston 	:= ""  // Texto com Títulos Estornados será apresentado


	Private lMsErroAuto := .F.                  	//Controle de erro na rotina automatica
	Private aBaixaSE5   := {}                   	//Array utilizado na rotina de selecao das baixas para estorno do recebimento(FINA070)
	Default lCancTef	:= .F.						// Indica se o estorno da baixa eh por motivo de cancelam. de cupom TEF
	Default lWs			:= .F.						// Informa se está utilizando WS
	Default lSelecTit	:= .T.
	Default aVlCompEst	:= {}						//Valor de estorno da compensação de NCC
	Default aSe5Est		:= {}						//SE5 que será estornadas pelo Totvs pdv
	Default aLotesMDM	:= {}
	Default aListTit	:= aClone(aTitulo)

	If cPaisLoc == "BRA"
		lTroco  := SuperGetMV("MV_LJTROCO",,.F.)
	Else
		lTroco  := SuperGetMV("MV_LJTRLOC",,.F.)
	EndIf

	If ValType(cNomeUser) <> "U"
		cNumCaixa := cNomeUser
	EndIf

	For nX := 1 to Len(aTitulo)
		lFoundSE5  := .F.
		DbSelectArea("SE1")
		SE1->( DbSetOrder(1) )
		If aTitulo[nX][TIT_SELE]
			aBaixa      := {}
			aBaixaSE5   := {}
			lMsErroAuto := .F.

			//LjGrvLog( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO), "LjRecCancBx  - Processando titulo ")
			FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "LjRecCancBx  - Processando titulo: "+SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) )

			SE1->( DbGoto(aTitulo[nX][TIT_RECN]) )

			AADD(aBaixa , {"E1_FILIAL"    , SE1->E1_FILIAL		, NIL})
			AADD(aBaixa , {"E1_PREFIXO"   , SE1->E1_PREFIXO		, NIL})
			AADD(aBaixa , {"E1_NUM"       , SE1->E1_NUM			, NIL})
			AADD(aBaixa , {"E1_PARCELA"   , SE1->E1_PARCELA		, NIL})
			AADD(aBaixa , {"E1_TIPO"      , SE1->E1_TIPO		, NIL})
			AADD(aBaixa , {"E1_CLIENTE"   , SE1->E1_CLIENTE		, NIL})
			AADD(aBaixa , {"E1_LOJA"      , SE1->E1_LOJA		, NIL})
			AADD(aBaixa , {"E1_DESCONT"   , SE1->E1_DESCONT	, NIL})

			//===================================================================
			//  Funcao para estorno dos titulos que tem baixas por compensacao.  
			//===================================================================
			If cLjOpEst == "1" // Processará estorno de todas as compensações referentes ao titulo
				aBaixaSE5 := {}
				Sel070Baixa( "CP"	,SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA,   SE1->E1_TIPO	 ,NIL	  , .T.	, SE1->E1_CLIENTE,     SE1->E1_LOJA	  ,NIL ,NIL  ,NIL , NIL  ,.T. ,.T.	)
				If Len(aBaixaSE5) > 0
					aAdd(aVlCompEst, aClone(aBaixaSE5))
				EndIf
				aBaixaSE5 := {}
				U_UEstoBxNCC(nX)

			ElseIf cLjOpEst == "2"  // Verifica se há titulos baixados e perguntará se processa estorno
				aBaixaTit := Sel070Baixa( "CP"	,SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA,   SE1->E1_TIPO	 ,NIL	  , .T.	, SE1->E1_CLIENTE,     SE1->E1_LOJA	  ,NIL ,NIL  ,NIL , NIL  ,.T. ,.T.	)
				If Len(aBaixaTit) > 0
					If MsgYesNo("Há Baixas por Compensação no Financeiro , Processa o Estorno das compensações?", "Atenção")//"Há Baixas por Compensação no Financeiro , Processa o Estorno das compensações?","Atenção"
						U_UEstoBxNCC(nX)
					Else
						cLjOpEst := "3" // Alterado para "3" Decosiderar a NCC, para que não seja feita a baixa total do Titulo do Cliente.
					EndIf
				EndIf
			EndIf


			//==================================================
			//Busca as baixas do titulo 						
			//==================================================

			// Verifica se foi aplicado o update U_UPDLOJ33
			If lAliasMDM .AND. lAliasMDN
				If SE1->E1_FILIAL == xFilial("SE5")
					cTipoDoc := "V2 /BA /RA /CP /LJ /"
				Else
					cTipoDoc := "VL /V2 /BA /RA /CP /LJ /"
				EndIf
			Else
				cTipoDoc := "VL /V2 /BA /RA /CP /LJ /"
			EndIf

			aBxTit := Sel070Baixa( cTipoDoc+MV_CRNEG						,SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA,;
				SE1->E1_TIPO						,NIL				,NIL			,SE1->E1_CLIENTE,;
				SE1->E1_LOJA						,NIL				,NIL			,NIL,;
				NIL									,.T.	)

			aBaixaSE5 := {}

			aBaixaTit := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /"+MV_CRNEG	,SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA,;
				SE1->E1_TIPO						,NIL				,NIL			,SE1->E1_CLIENTE,;
				SE1->E1_LOJA						,NIL				,NIL			,NIL,;
				NIL									,.T.	)
			lSelLot := .f.
			//Verifica se o título está vinculado a um lote de baixa
			If !lSelecTit
				If nPosDelSE5 <= Len(aTitDelSE5)
					nOpBaixa := aScan( aBaixaSE5 , { |x| ( x[1] + x[2] + x[3] + x[4] + x[5] + x[6] + x[9] + x[25] ) == ( aTitDelSE5[nPosDelSE5][2] +;
						( aTitDelSE5[nPosDelSE5][3] + Iif( Len(aTitDelSE5[nPosDelSE5][3]) == TamSX3("E5_NUMERO")[1], Space(TamSX3("E5_NUMERO")[1]), "" ) ) +;
						aTitDelSE5[nPosDelSE5][4] + aTitDelSE5[nPosDelSE5][5] + aTitDelSE5[nPosDelSE5][6] + aTitDelSE5[nPosDelSE5][7] +;
						aTitDelSE5[nPosDelSE5][8] + "BA" ) } )
					nPosDelSE5 += 2
				EndIf
			Else
				If  (nPosLtMDM := aScan(aLotesMDM, { |l| l[1] == SE1->E1_FILIAL .AND. l[2] == SE1->E1_PREFIXO	 .AND. l[3] == SE1->E1_NUM	 .and. l[4] == SE1->E1_PARCELA .AND. l[5] ==  SE1->E1_TIPO })  ) > 0
					//LjGrvLog( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO), "LjRecCancBx - Localizou lote de baixa "+ aLotesMDM[nPosLtMDM][7] + "Seq Baixa " + aLotesMDM[nPosLtMDM][6])
					FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "LjRecCancBx - Localizou lote de baixa "+ aLotesMDM[nPosLtMDM][7] + "Seq Baixa " + aLotesMDM[nPosLtMDM][6]+" - "+SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) )
					//Localiza a sequencia da baixa
					nOpBaixa := aScan( aBaixaSE5 , { |x| ( x[1] +  Substr(x[2],1,nTamSE5Num)  + x[3] + x[4] + x[5] + x[6] + x[9] + x[25] ) == ( SE1->E1_PREFIXO +;
						SE1->E1_NUM + SE1->E1_PARCELA +  SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA + aLotesMDM[nPosLtMDM, 06] +;
						"BA" ) } )
					lSelLot :=  nOpBaixa  > 0

					//LjGrvLog( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO), "LjRecCancBx - Posicao de baixa"+ aLotesMDM[nPosLtMDM][7] + "Seq Baixa " + cValToChar(nOpBaixa))
					FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "LjRecCancBx - Posicao de baixa"+ aLotesMDM[nPosLtMDM][7] + "Seq Baixa " + cValToChar(nOpBaixa)+" - "+SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) )
				EndIf

			EndIf

			aSort(aBaixaSE5,,, {|x,y| x[9] < y[9] } )

			//=========================================================================
			// Permite selecionar a sequencia da baixa do titulo, se tiver mais de uma
			//=========================================================================
			If lSelecTit .AND. !lSelLot
				If Len(aBaixaTit) > 1 .AND. !lCancTef
					nOpBaixa := 1
					If !lWs
						If !lAliasMDM .AND. !lAliasMDN
							lEstParc := .T.
						EndIf
						cListBox := aBxTit[1]
						nOpBaixa := 0
						DEFINE MSDIALOG oDlg FROM 5, 5 TO 14, 55 TITLE "Escolha a Baixa"  //"Escolha a Baixa"

						@  .5, 2 LISTBOX cListBox ITEMS aBxTit SIZE 170 , 40 Font oDlg:oFont
						DEFINE SBUTTON FROM 055,112    TYPE 1 ACTION (nOpBaixa := 1,oDlg:End()) ENABLE OF oDlg
						DEFINE SBUTTON FROM 055,139.1  TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

						ACTIVATE MSDIALOG oDlg CENTERED
						If nOpBaixa == 0
							Loop
						Else
							aSE5Selec := LjEstSelE5(cListBox)

							nOpBaixa := aScan( aBaixaSE5 , { |x| ( x[1] + Substr(x[2],1,nTamSE5Num)  + x[3] + x[4] + x[5] + x[6] + x[9] ) ==;
								(aSE5Selec[1] + aSE5Selec[2]  + aSE5Selec[3] + aSE5Selec[4] + aSE5Selec[5] + aSE5Selec[6] + aSE5Selec[9] ) } )

							nOpSelBxa := Ascan(aBxTit,cListBox)
						EndIf

					Else
						// Tratamento necessário para recebimentos com baixas parciais
						aSort(aBaixaTit)
						nOpBaixa	:= Len(aBaixaTit)

					EndIf
				Else
					nOpBaixa := 1
				EndIf
			EndIf

			If Len(aBaixaSE5) == 0
				//Somente quando o total do recebimento foi feito via compensação
				If cLjOpEst == "1" .And. SE1->E1_SALDO == SE1->E1_VALOR .And. RecLock("SE1", .F.)
					SE1->E1_BAIXA	:= Ctod("  /  /  ")
					SE1->E1_MOVIMEN := Ctod("  /  /  ")
					SE1->E1_JUROS	:= 0
					SE1->E1_MULTA	:= 0
					SE1->E1_DESCONT := 0
					SE1->( MsUnlock() )
				EndIf
				LOOP
			EndIf

			//=======================================================================================
			// Verifica se pode efetuar a baixa do titulo, pois nao e possivel efetuar o estorno    |
			//| se a filial do SE5 nao for a filial corrente.										
			//=======================================================================================
			If lRecFilial .AND. Len(aBaixaSE5) > 0
				If !LJXBXSE5VL(aBaixa , 1, aBaixaSE5[nOpBaixa][9] )			// Pesquisa se pode fazer o cancelamento Filial do VL = xFilial("SE5")
					Return Nil
				EndIf
			EndIf

			If lChkslv .AND. Len(aBaixaSE5) > 0
				DbSelectArea("SE5")
				DbSetOrder(7)
				If DbSeek(xFilial("SE5")+aBaixaSE5[nOpBaixa][1]+Substr(aBaixaSE5[nOpBaixa][2],1,nTamSE5Num)+aBaixaSE5[nOpBaixa][3]+;
						aBaixaSE5[nOpBaixa][4]+aBaixaSE5[nOpBaixa][5]+aBaixaSE5[nOpBaixa][6]+aBaixaSE5[nOpBaixa][9])
					//Verifique se título vinculado ao lote não foi processado para estornar o TEF, pois o estorno do TEF é por lote de recebimento
					cMsgErro := ""
					If (nPosLtMDM := aScan(aLotesMDM, { |l| l[1] == SE1->E1_FILIAL .AND. l[2] == SE1->E1_PREFIXO	 .AND. l[3] == SE1->E1_NUM	 .and. l[4] == SE1->E1_PARCELA .AND. l[5] ==  SE1->E1_TIPO })  ) = 0
						lSemErro 	:= LJXGrvSLV( "C", Nil,aBaixa[1][2], aListTit, nX, lUsaTef, @cMsgErro )
						//LjGrvLog( SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO), "LjRecCancBx - retorno da validação/cancelamento TEF [ "+cMsgErro + "]", lSemErro)
						FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "LjRecCancBx - retorno da validação/cancelamento TEF [ "+cMsgErro + "]: "+toString(lSemErro) )
						If !lSemErro
							cErros   += SE1->E1_PREFIXO	+ "-" 		+ SE1->E1_NUM 	+ "/" + ;
								SE1->E1_PARCELA	+ "  Tipo: " 	+ SE1->E1_TIPO 	+ CRLF + CRLF + " Mensagem [" + cMsgErro + "]" //" Mensagem ["
							Return Nil
						EndIf
					EndIf
				EndIf
			EndIf

			aBxSE5Bkp := aClone(aBaixaSE5)
			If lAliasMDM .AND. lAliasMDN
				MDM->(DbSetOrder(1))//MDM_FILIAL+MDM_BXFILI+MDM_PREFIX+MDM_NUM+MDM_PARCEL+MDM_TIPO+MDM_SEQ+MDM_LOTE
				If MDM->(DBSeek( xFilial("MDM") + aBaixa[1][2] + aBaixaSE5[nOpBaixa][1] + Substr(aBaixaSE5[nOpBaixa][2],1,nTamSE5Num) + aBaixaSE5[nOpBaixa][3] + aBaixaSE5[nOpBaixa][4] + aBaixaSE5[nOpBaixa][9] ))
					cMDMLote	:= MDM->MDM_LOTE
					cMDMPrfNum	:= MDM->(MDM_PREFIX + MDM_NUM)
					lRetGrvMDX  := LjxGrvMDX(	cMDMOper				, NIL		, NIL, NIL,;
						NIL						, NIL		, NIL, NIL,;
						NIL			, NIL		, NIL, NIL,;
						NIL			, cMDMLote,.T.)

					If lRetGrvMDX
						MDM->( DbSetOrder(2) )
						MDM->( DBSeek( xFilial("MDM") + cMDMLote ) )
						While !MDM->( EOF() ) .AND. MDM->MDM_LOTE == cMDMLote

							If MDM->(aScan(aLotesMDM, { |l| l[1] == MDM_BXFILI .AND. l[2] == MDM_PREFIX .AND. l[3] == MDM_NUM .and. l[4] == MDM_PARCEL .AND. l[5] ==  MDM_TIPO .and. l[6] == MDM_SEQ }) )  = 0
								MDM->( aAdd( aLotesMDM, { MDM_BXFILI, MDM_PREFIX, MDM_NUM, MDM_PARCEL, MDM_TIPO, MDM_SEQ, cMDMLote}) )
							EndIf
							If cPaisLoc == "ARG"
								cOrdRec := aBaixaSE5[nOpBaixa][27]
								cSerRec := aBaixaSE5[nOpBaixa][28]
								nPosTit := aScan( aBaixaSE5, { |x| x[9] == MDM->MDM_SEQ .AND. x[25] == "BA" .AND. cOrdRec == x[27] .AND. cSerRec == x[28] } )
								If nPosTit > 0
									nValorTot += aBaixaSE5[nPosTit][8]
									aAreaSE5 := SE5->( GetArea() )
									MSExecAuto({|x, y, z, v| Fina070(x, y, z, v)}, aBaixa, 5, .F., nPosTit )
									RestArea( aAreaSE5 )
									aBaixaSE5 := {}
									aBaixaTit := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /"+MV_CRNEG	,SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA,;
										SE1->E1_TIPO						,NIL				,NIL			,SE1->E1_CLIENTE,;
										SE1->E1_LOJA						,NIL				,NIL			,NIL,;
										NIL									,.T.	)
								EndIf
							Else

								For nY := 1 To Len(aBaixaSE5)
									If ( aBaixaSE5[nY][1] == MDM->MDM_PREFIX .AND. Substr(aBaixaSE5[nY][2],1,nTamSE5Num) == MDM->MDM_NUM .AND. aBaixaSE5[nY][3] == MDM->MDM_PARCEL .AND.;
											aBaixaSE5[nY][4] == MDM->MDM_TIPO .AND. aBaixaSE5[nY][9] == MDM->MDM_SEQ .AND.;
											( ( aBaixaSE5[nY][25] $ "BA" .AND. !LjxDMoney( "SE5", aBaixaSE5[nY][24], aBaixaSE5[nY][26] ) ) ) )
										MSExecAuto({|x, y, z, v| Fina070(x, y, z, v)}, aBaixa, 5, .F., nY )
										nValorTot  += aBaixaSE5[nY][8]
										If (lGestao .AND. !lSE1Exc) .AND. (SE1->E1_SALDO == SE1->E1_VALOR)	//Caso totalmente estornado ao utilizar gestão de empresas e tabela SE1 não exclusiva, evitando loops
											Exit
										EndIf
									EndIf
								Next nY
							EndIf
							MDM->( DBSkip() )
						End
						Aadd(aTitEstorn, Alltrim(aTitulo[nx][2]) + " - " + Alltrim(aTitulo[nx][3]) + " - " + Alltrim(aTitulo[nx][4]) + " - " + DtoC(aTitulo[nx][5]) + " - " + Str(aTitulo[nx][6],10,2))
					Else
						Aadd(aTitBaixad, Alltrim(aTitulo[nx][2]) + " - " + Alltrim(aTitulo[nx][3]) + " - " + Alltrim(aTitulo[nx][4]) + " - " + DtoC(aTitulo[nx][5]) + " - " + Str(aTitulo[nx][6],10,2))
					EndIf
				Else
					If cPaisLoc == "ARG"
						cOrdRec := aBaixaSE5[nOpBaixa][27]
						cSerRec := aBaixaSE5[nOpBaixa][28]
						cParcRec:= aBaixaSE5[nOpBaixa][3]
						cNumRec := aBaixaSE5[nOpBaixa][2]
						cSeqRec := aBaixaSE5[nOpBaixa][9]
						SE5->( DbSetOrder(8) )
						SE5->( DbSeek( xFilial("SE5") + cOrdRec + cSerRec ) )
						While !SE5->( EOF() ) .AND. SE5->E5_ORDREC == cOrdRec .AND. SE5->E5_SERREC == cSerRec
							If SE5->E5_TIPODOC == "BA"
								nPosTit := aScan( aBaixaSE5, { |x| x[9] == SE5->E5_SEQ .AND. x[25] == "BA" .AND. cOrdRec == x[27] .AND. cSerRec == x[28] } )
								If nPosTit > 0
									nValorTot += aBaixaSE5[nPosTit][8]
									aAreaSE5 := SE5->( GetArea() )
									MSExecAuto({|x, y, z, v| Fina070(x, y, z, v)}, aBaixa, 5, .F., nPosTit )
									RestArea( aAreaSE5 )
									aBaixaSE5 := {}
									aBaixaTit := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /"+MV_CRNEG	,SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA,;
										SE1->E1_TIPO						,NIL				,NIL			,SE1->E1_CLIENTE,;
										SE1->E1_LOJA						,NIL				,NIL			,NIL,;
										NIL									,.T.	)
								EndIf
							EndIf
							SE5->( DBSkip() )
						End
					Else
						MSExecAuto({|x, y, z, v| Fina070(x, y, z, v)}, aBaixa, 5, .F., nOpBaixa )
						nValorTot  += aBaixaSE5[nOpBaixa][8]
					EndIf
				EndIf
			Else
				//=================================================
				// Executa o Cancelamento da Baixa do Titulo    
				//=================================================
				MSExecAuto({|x, y, z, v| Fina070(x, y, z, v)}, aBaixa, 5, .F., nOpBaixa )
				If Len(aBaixaSE5) > 0
					nValorTot  += aBaixaSE5[nOpBaixa][8]
				EndIf
			EndIf
			aBaixaSE5 := aClone(aBxSE5Bkp)
			aSe5Est := aClone(aBaixaSE5) //utilizado para controlar o estorno no totvs pdv
			nEstTroco := 0

			//=============================================================================================
			// Alteracao necessaria para correcao do Saldo do Titulo,pois o fina070() atualiza o saldo  
			// com o valor do troco (somente para dinheiro) e eh necessario ajustar esse valor			 
			//=============================================================================================
			If lAliasMDM .AND. lAliasMDN .AND. lRetGrvMDX
				If (((nModulo == 12 .OR. nModulo == 23) .OR. (nModulo <> 23 .AND. LJModNFis()) .OR. FunName()$"RPC") .AND. lTroco .AND. cPaisLoc == "BRA")
					nValTroco := ValTroco(aBaixa[2][2],aBaixa[3][2],aBaixa[4][2],aBaixa[5][2],aBaixa[6][2],aBaixa[7][2],aBaixaSE5[nOpBaixa][9],@nEstTroco)
					// Garante que esteja posicionado no registro correto
					DbSelectArea("SE1")
					DbGoto(aTitulo[nX][TIT_RECN])
					If nValTroco > 0
						Reclock("SE1",.F.)
						SE1->E1_SALDO := SE1->E1_SALDO - nValTroco
						MsUnLock()
					EndIf
				EndIf
			EndIf

			If lMsErroAuto
				lSemErro := .F.
				//=================
				//| "  Tipo: "   |
				//=================
				cErros   += SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"/"+SE1->E1_PARCELA+"  Tipo: "+SE1->E1_TIPO+CRLF
				DisarmTransaction()
				//LjGrvLog("Recebimento_Titulo", "LjRecCancBx - DisarmTransaction")
				FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "LjRecCancBx - DisarmTransaction" )
				MostraErro()
			Else
				If lRetGrvMDX
					aAreaSE1 := SE1->(GetArea())
					DBSelectArea("SE1")
					DbSetOrder(1)

					//Estorno do valor de acrescimo
					Dbseek( aBaixa[1][2] + aBaixa[2][2] + aBaixa[3][2] + aBaixa[4][2] + aBaixa[5][2] )

					If SE1->(Found()) .AND. SE1->E1_SDACRES > 0  .AND.  ( SE1->E1_SALDO  == SE1->E1_VALOR + SE1->E1_SDACRES)
						Reclock("SE1", .F.)
						SE1->E1_SALDO -= SE1->E1_SDACRES
						SE1->( MsUnlock() )
					EndIf

					If Dbseek( aBaixa[1][2] + aBaixa[2][2] + aBaixa[3][2] + aBaixa[4][2] + aBaixa[5][2] ) .AND. !lEstParc
						If SE1->E1_SALDO >= SE1->E1_VALOR .Or. (Len(aBxTit) == 1 .AND. cLjOpEst != "3") //Se Saldo for maior ou igual ao valor do titulo ou foi estornado o titulo por completo, zera os campos de multa, juros, desconto.
							Reclock("SE1", .F.)
							SE1->E1_BAIXA      := Ctod("  /  /  ")
							SE1->E1_MOVIMEN    := Ctod("  /  /  ")
							SE1->E1_JUROS      := 0
							SE1->E1_MULTA      := 0
							SE1->E1_SALDO	   := SE1->E1_VALOR
							SE1->( MsUnlock() )
						EndIf
					EndIf
					RestArea(aAreaSE1)

					//==================================================================
					// Efetua o estorno da baixa, foi criada esta rotina pois o FINA070
					// nao estorna o tilulo na filial de origem quando o recebimento do
					// titulo foi feito em uma filial diferente da que o gerou.        
					//==================================================================
					If lRecFilial
						If lAliasMDM .AND. lAliasMDN
							MDM->(DbSetOrder(2))
							If !Empty(cMDMLote) .AND. MDM->(DBSeek( xFilial("MDM") + cMDMLote ))
								While !MDM->(EOF()) .AND. MDM->MDM_LOTE == cMDMLote
									If MDM->MDM_PARCEL == aBaixa[4][2] .AND. MDM->(MDM_PREFIX + MDM_NUM) == cMDMPrfNum
										LJXBXSE5VL(aBaixa, 2, MDM->MDM_SEQ )
									EndIf
									MDM->(DBSkip())
								End
							Else
								If cPaisLoc == "ARG"
									SE5->( DbSetOrder(8) )
									SE5->( DbSeek( xFilial("SE5") + cOrdRec + cSerRec ) )
									While !SE5->( EOF() ) .AND. SE5->E5_ORDREC == cOrdRec .AND. SE5->E5_SERREC == cSerRec
										If SE5->E5_TIPODOC == "BA"
											aAreaSE5 := SE5->( GetArea() )
											LJXBXSE5VL(aBaixa, 2, SE5->E5_SEQ )
											RestArea( aAreaSE5 )
										EndIf
										SE5->( DBSkip() )
									End
								Else
									LJXBXSE5VL(aBaixa, 2, aBaixaSE5[nOpBaixa][9] )
								EndIf
							EndIf
						ElseIf Len(aBaixaSE5) > 0
							//=============================================
							// Executa o Cancelamento da Baixa do Titulo   
							//=============================================
							LJXBXSE5VL(aBaixa, 2, aBaixaSE5[nOpBaixa][9] )
						EndIf
					EndIf

					//=============================================------------------------
					// Preenche o array aDadosEst com os dados dos recebimentos estornados 
					//=============================================------------------------
					DbSelectArea("SE5")
					DbSetOrder(7)
					If Len(aBaixaSE5) > 0
						DbSeek(xFilial("SE5")+aBaixaSE5[nOpBaixa][1]+Substr(aBaixaSE5[nOpBaixa][2],1,nTamSE5Num)+aBaixaSE5[nOpBaixa][3]+;
							aBaixaSE5[nOpBaixa][4]+aBaixaSE5[nOpBaixa][5]+aBaixaSE5[nOpBaixa][6]+aBaixaSE5[nOpBaixa][9])
					EndIf

					//====================================================================================================
					//|     Filial              Prefixo                                Numero                            |
					//|        Parcela                   Tipo                      Cliente                   Loja        |
					//|     Sequencia                                                                                    |
					//====================================================================================================
					If Len(aBaixaSE5) > 0
						While !Eof() 														.AND. ;
								xFilial("SE5")                             	== SE5->E5_FILIAL 	.AND. ;
								aBaixaSE5[nOpBaixa][1]                     	== SE5->E5_PREFIXO	.AND. ;
								Substr(aBaixaSE5[nOpBaixa][2],1,nTamSE5Num) == SE5->E5_NUMERO 	.AND. ;
								aBaixaSE5[nOpBaixa][3]                     	== SE5->E5_PARCELA	.AND. ;
								aBaixaSE5[nOpBaixa][4]                     	== SE5->E5_TIPO   	.AND. ;
								aBaixaSE5[nOpBaixa][5] 			    		== SE5->E5_CLIFOR  	.AND. ;
								aBaixaSE5[nOpBaixa][6]                     	== SE5->E5_LOJA   	.AND. ;
								aBaixaSE5[nOpBaixa][9]                     	== SE5->E5_SEQ

							//====================================================================
							// Se o titulo foi estornado por um caixa diferente do caixa que o   
							// baixou, o sistema tem que corrigir o banco. A funcao FINA070 cria 
							// o estorno para o banco que o baixou, quando deveria cria-lo para o
							// caixa local.                                                      
							//====================================================================
							If SE5->E5_TIPODOC == "ES" .AND. SE5->E5_BANCO <> cNumCaixa
								AtuSalBco(SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dDataBase, SE5->E5_VALOR, "+")
								RecLock("SE5", .F.)
								REPLACE SE5->E5_BANCO WITH cNumCaixa
								MsUnLock()
								AtuSalBco(SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dDataBase, SE5->E5_VALOR, "-")
							Endif

							If !lFoundSE5 .AND. SE5->E5_TIPODOC == "VL"
								AADD(aDadosEst, {SE5->E5_PREFIXO ,;           //1.Prefixo
								SE5->E5_NUMERO  ,;           //2.Numero
								SE5->E5_PARCELA ,;           //3.Parcela
								SE5->E5_TIPO    ,;           //4.Tipo
								SE5->E5_CLIFOR  ,;           //5.Codigo do cliente
								SE5->E5_LOJA    ,;           //6.Loja do cliente
								SE5->E5_SEQ     ,;           //7.Sequencia de baixa
								SE5->E5_VALOR   ,;           //8.Valor da baixa
								SE5->E5_MOEDA   ,;           //9.Forma de recebimento
								SE5->E5_VLJUROS ,;           //10.Juros
								SE5->E5_VLMULTA ,;           //11.Multa
								SE5->E5_VLDESCO })           //12.Desconto

								lFoundSE5 := .T.
							Endif

							DbSkip()
						End
					EndIf
				Endif

				If nEstTroco > 0 .AND. lRetGrvMDX
					LJEstTroco(nEstTroco,1)
				EndIf
			Endif
		Endif
	Next nX
	aTitDelSE5 := {}

	If Len(aTitBaixad) > 0
		cTextBaix := "Estorno não Permitido para o(s) seguinte(s) Título(s) já Baixado(s):" + CRLF + CRLF				//   "Estorno não Permitido para o(s) seguinte(s) Título(s) já Baixado(s):"
		For nX := 1 to Len(aTitBaixad)
			cTextBaix += aTitBaixad[nX] + CRLF
		Next

		MsgInfo( cTextBaix, "Títulos não Estornados")					// "Títulos não Estornados"

		If Len(aTitEstorn) > 0
			cTextEston += "Título(s) Estornado(s) com Sucesso: " + CRLF + CRLF   		// "Título(s) Estornado(s) com Sucesso: "
			For nX := 1 to Len(aTitEstorn)
				cTextEston += aTitEstorn[nX] + CRLF
			Next

			MsgInfo( cTextEston, "Títulos Estornados")    			// "Títulos Estornados"

		EndIf

	Endif

//Restaura a variavel private aTotais, necessario pois Fina070 possui variavel com mesmo nome causando erro
//Acontece quando LP 527 esta habilitada na contabilizacao do estorno
//Esta variavel nao deve ser alterada no estorno de titulo, assim recupera valor original
	If ValType(aTotaisBkp) <> NIL
		aTotais := aClone(aTotaisBkp)
	Endif

Return NIL

/*/{Protheus.doc} LjxGrvMDX
Grava tabela Log de Titulos Baixados (MDM)
Log. de Titulos Gerados (MDN)   e Contas a Receber (SE1) 

	cOper : 1=Inclusao, 2=estorno
@type function
@version  
@author g.sampaio
@since 14/12/2023
@param cMDMOper, character, param_description
@param aPgto, array, param_description
@param aPgtoS, array, param_description
@param aTit, array, param_description
@param cFilialG, character, param_description
@param cPrefixo, character, param_description
@param cNumero, character, param_description
@param cParcela, character, param_description
@param cTipo, character, param_description
@param cCdCLi, character, param_description
@param cLjCli, character, param_description
@param dDate, date, param_description
@param cSeq, character, param_description
@param cLote, character, param_description
@param lRotinaWs, logical, param_description
@param cNumUse, character, param_description
@param aSE5Bxas, array, param_description
@param aMoedas, array, param_description
@param aTefpgto, array, param_description
@param aNsuVndTef, array, param_description
@param aPagDig, array, param_description
@return variant, return_description
/*/
Static Function LjxGrvMDX(	cMDMOper	, aPgto		, aPgtoS	, aTit		,;
							cFilialG	, cPrefixo	, cNumero	, cParcela	,;
							cTipo		, cCdCLi	, cLjCli 	, dDate		,;
							cSeq		, cLote		, lRotinaWs	, cNumUse	,;
							aSE5Bxas	, aMoedas	, aTefpgto	, aNsuVndTef,;
							aPagDig		)

Local lTitGerado		:= .F.
Local aSE1	   			:= {}
Local aArea				:= {}
Local lRet          	:= .T.								// variavel de retorno da funcao
Local nX				:= 0 								// Veriavel para controle de loop
Local nY				:= 0 								// Veriavel para controle de loop
Local nZ				:= 0 								// Veriavel para controle de loop
Local cNumTitGer		:= ""								// Numero do titulo gerado.
Local cNumTitAux		:= ""											// Numero do titulo gerado. (auxiliar)
Local cPrefTit	 		:= ""								// Armazena o prefixo do titulo que sera gerado, quem eh configurado via parametro
Local nTamE1_PARCELA	:= 0							// Tamanho do campo E1_PARCELA
Local cNature			:= ""
Local cPortador			:= ""
Local nTamDoc			:= TamSx3("E1_NUM")[1]				   	// Tamanho do E1_NUM
Local nTamTipo			:= TamSx3("E1_TIPO")[1]				   	// Tamanho do E1_TIPO
Local aMDM				:= {}									// Armazena dados que serçao gravados na tabela MDN
Local aMDN				:= {}									// Armazena dados que serçao gravados na tabela MDM
Local cGRParc			:= "0"									// Numero de parcelas geradas
Local nPosFPgto			:= 0
Local cLoteBx			:= ""                                   // Armazena o numero do lote
Local nTamAeCod			:= TamSx3("AE_COD")[1]					// Tamanho do campo AE_COD
Local aPgtosL			:= {}									// aPgtos local
Local aPgtosSL			:= {}                                  // aPgtosSint local
Local aTituloL			:= {}									// aTitulo local
Local lAliasMDM			:= AliasIndic("MDM")					// Indica se existe a tabela do
Local lAliasMDN     	:= AliasIndic("MDN")
Local cCodCLi			:= ""
Local cLojCli			:= ""
Local cNomeCli			:= ""
Local nDias				:= 0
Local nTaxa				:= 0
Local nI                := 0
Local cMvTpRet      	:= SuperGetMV("MV_LJCTRET",,"RI|RG|RB|RS")
Local aAreaE1 			:= {} 									// Salva area do SE1
Local aX				:= {}									// Manipula titulo para aclone do aTit
Local nCont             := 0                                    // Contador
Local cTitNum			:= ""
Local nTroco			:= 0
Local lTroco			:= .F.
Local cCliOri			:= ""
Local cLojOri			:= ""
Local lTefMult		    := SuperGetMV("MV_TEFMULT", ,.F.)	            // Identifica se o cliente utiliza m=ltiplas transações TEF
Local nPosRetCart 		:= 0
Local lUsaTef			:= LJProFile(2)				// Configuracao do caixa
Local aPgtosId			:= {} //Array apagtos ordenado
Local lTEFD				:= ExistFunc("L010TefD")
Local cDocTEF			:= "" //Documento TEF
Local cNSUTEF			:= "" //NSU TEF
Local cAUTORIZ			:= ""
Local lGrvMEP			:= .F.                                  //Verifica se está sendo utilizada a tabela de parcelamentos SITEF
Local nParcMEP			:= 0									//Parcela SITEF
Local nTamParTEF		:= 0									//Tamanho do Campo Parcela SITEF
Local aCampMEP      	:= {}									//Array para retornar o tamanho do campo MEP_PARTEF
Local aOldPgtosSl		:= {}									//Backup do array aPgtosSL
Local nMaxParc			:= 0									//Numero de Parcelas da forma de pagamento
Local cCodSA2			:= ""									//codigo do fornecedor (SA2)
Local aVetorSE2			:= {}									//vetor com os campos para ExecAuto do Contas a Pagar
Local nValorTaxa		:= 0									//valor da taxa da administradora financeira
Local lMvLjGerTx		:= SuperGetMV( "MV_LJGERTX",, .F. )		//indica se deve-se descontar a taxa da adm do titulo a receber
Local dDataVenc			:= Nil
Local aAuxDados			:= {}
Local aDadosBanc 		:= {}									//array com dados de ag e conta CADASTRADOS NA SA6
Local nTxPagto		    := 0
Local aAdmValTax		:= {}
Local lNewMDM			:= .T.                                  //Controla novo registro pra alias MDM
Local aFina070			:= {}									// Array para a baixa automatica 
Local cTipoBx           := AllTrim(SuperGetMV( "MV_LJBXTIT",.F.,"" ))
Local cHistor			:= "BAIXA AUTOMATICA" //"BAIXA AUTOMATICA"
Local aParamLj 		    := {{"2"},{"2"}} 	// Mostra Lanc Contabil? 1=SIM, 2=NÃO / Contabiliza On-line? 1=SIM, 2=NÃO 
Local aTaxaAdm 			:= {}

Private	lMsErroAuto	:= .F.

DEFAULT	cFilialG 	:= ""
DEFAULT cPrefixo 	:= ""
DEFAULT cNumero 	:= ""
DEFAULT	cParcela	:= ""
DEFAULT	cTipo		:= ""
DEFAULT cCdCLi		:= ""
DEFAULT cLjCLi		:= ""
DEFAULT dDate		:= dDataBase
DEFAULT cSeq		:= Space(TamSX3("E5_SEQ")[1])
DEFAULT cLote		:= IIf(lAliasMDM, Space(TamSX3("MDM_LOTE")[1]), Space(6))
DEFAULT lRotinaWs	:= .F. 					// INDICA FOI chamaDA de ws
DEFAULT cNumUse		:= '' 					// Usuario
DEFAULT aSE5Bxas	:= {}
DEFAULT aMoedas		:= {}
DEFAULT aTefpgto	:= {}
DEFAULT aPagDig 	:= {}

If cPaisLoc == "BRA"
	lTroco  := SuperGetMV("MV_LJTROCO",,.F.)
Else
	lTroco  := SuperGetMV("MV_LJTRLOC",,.F.)
EndIf

If lAliasMDM .AND. lAliasMDN

	If cMDMOper == "1"
		// lLojxRec   := .T.---> Indica para funcao A040DupRec que esta sendo feito um Recebimento de Titulo
	    lLojxRec   := .T.
		aCampMEP:= TamSX3("MEP_PARTEF")

		If Len(aCampMEP) > 0
			lGrvMEP := .T.
			nTamParTEF := aCampMEP[1]
		EndIf

		If nModulo == 12 .OR. ( (nModulo <> 23 .AND. LJModNFis()) .And. !lRotinaWs) .Or. (nModulo == 23 .And. !lRotinaWs) //Tratamento para o TOTVS PDV

			If  cTipTEF == TEF_DISCADO .AND. lUsaTef .AND. L010IsDirecao(L010GetGPAtivo())
				aPgtosId := LJLoadDTEF()
			EndIf

			//==============================================================
			// Prepara array´s aPgtos, aPgtosSint e aTitulo para uso local  
			//==============================================================
			For nX := 1 to Len(aTit)
				AAdd( aTituloL , {	aTit[nX][TIT_SELE] , aTit[nX][TIT_RECN] , aTit[nX][TIT_TIPO] , aTit[nX][TIT_NUME] ,;
									aTit[nX][TIT_CLIE] , aTit[nX][TIT_LOJA] })
			Next nX

			//===============================
			//Estrutura do array aPgtosL  
			//1 - Vencimento 			   
			//2 - Forma de pagamento 	   
			//3 - Valor				   
			//4 - Banco do cheque		   
			//5 - Agencia do cheque	   
			//6 - Conta do cheque 		   
			//7 - Cod. adm.			   
			//8 - Moeda 				   
			//9 - Ult. Nr Comprov. ADM FIN
			//10- N=mero do Cartão/CH     
			//11- NSUTEF				   
			//12- NSUDOC                  
			//13- ID do Cartao            
			//14- Emitente do Cheque      
			//15- Autorizacao             
			//===============================
			For nX := 1 to Len(aPgto)

				nPosRetCart := 0
				aAuxDados	:= {}
				cDocTEF		:= "" //Documento TEF
				cNSUTEF		:= "" //NSU TEF
				cAUTORIZ 	:= "" //Autorizacao

				If Alltrim(aPgto[nX][3]) $ _FORMAPGDG //Pagamento Digital
					LjxRTefDa(	@aAuxDados	,	aPgto	,	Nil		,	NIL 	,;
								NIL 		,	8	 	,	NIL 	, 	nX		,;
								aPagDig )
					cDocTEF	:= aAuxDados[1][3]
					cNSUTEF	:= aAuxDados[1][6]
					cAUTORIZ:= aAuxDados[1][3]
				ElseIf Len(aTefpgto) > 0

				  	If (nPosRetCart := aScan(aTefpgto, {|x| x[1] == aPgto[nX][08]})) > 0
				  		cDocTEF := aTefpgto[nPosRetCart][2]
				  		cNSUTEF := aTefpgto[nPosRetCart][3]
						cAUTORIZ:= IIf(Len(aTefpgto[nPosRetCart])>3,aTefpgto[nPosRetCart][4],aTefpgto[nPosRetCart][2])
				  	EndIf

				ElseIf Alltrim(aPgto[nX][3]) $ _FORMATEF
					If Len(aNsuVndTef) > 0 //a prioridade será o TEF manual (digitação do NSU)
						LjxRTefDa(	@aAuxDados	,	aPgto	,	aNSUVndTef	,	NIL 	,;
									NIL 		,	8	 	,	NIL 		, 	nX		)
						cDocTEF	:= aAuxDados[1][3]
						cNSUTEF	:= aAuxDados[1][6]
						cAUTORIZ:= aAuxDados[1][4]
				 
					ElseIf cTipTef == TEF_CLISITEF
						If (nPosRetCart := Iif(lTefMult, aScan(oTef:aRetCartao, {|x| x:CIDCART == aPgto[nX][8] } ), 1) )  > 0
							cDocTEF := oTef:aRetcartao[nPosRetCart]:CNSUAUTOR
							cNSUTEF := oTef:aRetcartao[nPosRetCart]:CNSUSITEF
							cAUTORIZ:= oTef:aRetCartao[nPosRetCart]:CAUTORIZA
						EndIf

					ElseIf cTipTEF == TEF_DISCADO .AND. lUsaTef 
						If L010IsDirecao(L010GetGPAtivo()) .AND. Len(aPgtosId) > 12

						  	nPosRetCart := aScan(aPgtosId, {|p| p[14] == IIF(!Empty(aPgto[nX][08]), aPgto[nX][08], "1") })
		
							If nPosRetCart > 0
								cNSUTEF :=  aPgtosId[nPosRetCart][13]  //Autorizacao
								cDocTEF :=  Right(aPgtosId[nPosRetCart][7],6) //NSU TEF
								cAUTORIZ:=  Right(aPgtosId[nPosRetCart][7],6)
							Endif
							
						ElseIf lTEFD

							aPgtosId := L010TefD()

							If Len(aPgtosId) > 0 .AND. Len(aPgtosId[1]) >= 19
								
								nPosRetCart := aScan(aPgtosId, {|x| x[19] == IIF(!Empty(aPgto[nX][08]), aPgto[nX][08], "1") })

								If nPosRetCart > 0
									cNSUTEF := aPgtosId[nPosRetCart][09]
									cDocTEF := aPgtosId[nPosRetCart][05]
									cAUTORIZ:= aPgtosId[nPosRetCart][05]
								EndIf
		                    EndIf 
		                EndIf
		            EndIf
				Endif

				If Len(aPgto[nX][4]) > 0 .And. ValType(aPgto[nX][4][1]) == 'A' .AND. Len(aPgto[nX][4][1]) >= 11
					For nI := 1 To Len(aPgto[nX][4])
						AAdd(aPgtosL ,{	aPgto[nX][1] 													,;	//01-Vencimento
										aPgto[nX][3] 													,;	//02-Forma de pagamento
										aPgto[nX][2] 													,;	//03-Valor
						    			IIf(AllTrim(aPgto[nX][3]) $ MVCHEQUE , aPgto[nX][4][nI][4], "") ,;	//04-Banco do cheque
						    			IIf(AllTrim(aPgto[nX][3]) $ MVCHEQUE , aPgto[nX][4][nI][5], "") ,;	//05-Agencia do cheque
										IIf(AllTrim(aPgto[nX][3]) $ MVCHEQUE , aPgto[nX][4][nI][6], "") ,;	//06-Conta do cheque
										IIf(AllTrim(aPgto[nX][3]) $ "CC|CD"  , aPgto[nX][4][nI][5], "") ,;	//07-Cod. Adm. Financeira
						   				aPgto[nX][6] 													,;	//08-Moeda
										"" 																,;	//09-Ult. Nr Comprov. ADM FIN
										IIf(AllTrim(aPgto[nX][3]) $ "CC|CD" , aPgto[nX][4][nI][4], "")	,;	//10-N=mero do Cartão/CH
						   				cNSUTEF															,;	//11-NSU TEF
						   				cDocTEF															,;	//12-NSU DOC
						   				aPgto[nX][8]													,;	//13-ID do Cartao
						   				IIf(AllTrim(aPgto[nX][3]) $ MVCHEQUE .And. aPgto[nX][4][nI][12], aPgto[nX][4][nI][14], ""),; //14-Emitente do Cheque
										cAUTORIZ } )														//15-Autorizacao
											
					Next
				Else
					AAdd(aPgtosL , {aPgto[nX][1] 														,;	//01-Vencimento
									aPgto[nX][3] 														,;	//02-Forma de pagamento
									aPgto[nX][2] 														,;	//03-Valor
					    			IIf(AllTrim(aPgto[nX][3]) $ MVCHEQUE , aPgto[nX][4][4], "") 		,;	//04-Banco do cheque
					    			IIf(AllTrim(aPgto[nX][3]) $ MVCHEQUE , aPgto[nX][4][5], "") 		,;	//05-Agencia do cheque
									IIf(AllTrim(aPgto[nX][3]) $ MVCHEQUE , aPgto[nX][4][6], "") 		,;	//06-Conta do cheque
									IIf(AllTrim(aPgto[nX][3]) $ "CC|CD|PD|PX"  , aPgto[nX][4][5], "") 	,;	//07-Cod. Adm. Financeira
					   				aPgto[nX][6] 														,;	//08-Moeda
									"" 																	,;	//09-Ult. Nr Comprov. ADM FIN
									IIf(AllTrim(aPgto[nX][3]) $ "CC|CD" , aPgto[nX][4][4], "")			,;	//10-N=mero do Cartão/CH
					   				cNSUTEF																,;	//11-NSU TEF
					   				cDocTEF																,;	//12-NSU DOC
					   				aPgto[nX][8]														,;	//13-ID do Cartao
					   				IIf(AllTrim(aPgto[nX][3]) $ MVCHEQUE .And. aPgto[nX][4][12], aPgto[nX][4][14], ""),; //14-Emitente do Cheque
									cAUTORIZ } )															//15-Autorizacao
				EndIf

	   		Next nX

			For nX := 1 to Len(aPgtoS)
				AAdd(aPgtosSL , { aPgtoS[nX][1] , aPgtoS[nX][2] })
			Next nX
		Else
			For nX := 1 to Len(aTit:VerArray)
				AAdd( aTituloL , { aTit:VERARRAY[nX]:TSELE , aTit:VERARRAY[nX]:TRECNO , aTit:VERARRAY[nX]:TTIPO, "", "", "" } )
			Next nX

			//======================================
			// Carrega codigo do modulo de origem.
			//======================================
			If Len(aTit:VerArray) > 0
				nModOrigem := aTit:VERARRAY[1]:MODULO
			Endif

			//======================================================================================================
			// Carrega o aTit com dos valores do seu registro, para nao ocasionar erro mais a baixo na comparacao.
			//======================================================================================================
			aTit  	:= {}
			aAreaE1 :=  SE1->( GetArea() )
			aX := aClone(aTituloL)
			DBSelectArea("SE1")
			For nX := 1 to Len(aTituloL)
				//Posiciona no registro requerido
				SE1->(DbGoto(aTituloL[nX][2]))

				aTitVazio[TIT_PREF] := SE1->E1_PREFIXO
				aTitVazio[TIT_NUME] := SE1->E1_NUM
				aTitVazio[TIT_PARC] := SE1->E1_PARCELA
				aTitVazio[TIT_TIPO] := SE1->E1_TIPO
				aTitVazio[TIT_CLIE] := SE1->E1_CLIENTE
				aTitVazio[TIT_LOJA] := SE1->E1_LOJA

				aX[nX] := aClone(aTitVazio)
				aTituloL[nX][4]	:= IIf (Empty(aTituloL[nX][4]) , SE1->E1_NUM, 	aTituloL[nX][4])
				aTituloL[nX][5]	:= IIf (Empty(aTituloL[nX][5]) , SE1->E1_CLIENTE, aTituloL[nX][5])
				aTituloL[nX][6]	:= IIf (Empty(aTituloL[nX][6]) , SE1->E1_LOJA, 	aTituloL[nX][6])
			Next nX

			RestArea(aAreaE1)

			aTit  := aClone(aX)

	 		For	nX := 1 to Len(aPgto:VerArray)
				AAdd( aPgtosL , { aPgto:VerArray[nX]:VENCTO 													,;	//01-Vencimento
								  aPgto:VerArray[nX]:TIPO   													,;	//02-Forma de pagamento
								  aPgto:VerArray[nX]:VALOR  													,;	//03-Valor
								  aPgto:VerArray[nX]:BCOCHQ 													,;	//04-Banco do cheque
								  aPgto:VerArray[nX]:AGECHQ														,;	//05-Agencia do cheque
								  aPgto:VerArray[nX]:CTACHQ 													,;	//06-Conta do cheque
								  aPgto:VerArray[nX]:CODADM 													,;	//07-Cod. Adm. Financeira
								  1  																			,;	//08-Moeda
								  "" 																			,;	//09-Ult. Nr Comprov. ADM FIN
								  aPgto:VerArray[nX]:NUMERO														,;	//10-N=mero do Cartão/CH
								  Iif(ValType(aPgto:VerArray[nX]:NSUTEF) <>"U", aPgto:VerArray[nX]:NSUTEF , "")	,;	//11-NSU TEF
								  Iif(ValType(aPgto:VerArray[nX]:NSUDOC) <>"U", aPgto:VerArray[nX]:NSUDOC , "")	,;	//12-NSU DOC
								  Iif(ValType(aPgto:VerArray[nX]:CIDCART)<>"U", aPgto:VerArray[nX]:CIDCART, "")	,;	//13-ID do Cartao
								  Iif(ValType(aPgto:VerArray[nX]:ECHETER)<>"U", aPgto:VerArray[nX]:ECHETER, "")	,;	//14-Emitente do Cheque
								  Iif(ValType(aPgto:VerArray[nX]:AUTORIZ)<>"U", aPgto:VerArray[nX]:AUTORIZ, "") })	//15-Autorizacao
			Next nX

			For nX := 1 to Len(aPgtoS:VerArray)
				AAdd(aPgtosSL , { aPgtoS:VerArray[nX]:FORMAST , aPgtoS:VerArray[nX]:PARCELAST } )
			Next nX


			SE1->(DbSetOrder(1))
			SE1->(DBSeek(cFilialG + cPrefixo + cNumero + cParcela + cTipo))
		EndIf

		cPrefTit := PadR( SuperGetMV( "MV_LJTITGR", Nil, "REC" ), TamSx3("E1_PREFIXO")[1] )

		nTamE1_PARCELA	:=	TamSX3("E1_PARCELA")[1]

		If lRotinaWs
			cPortador	:= cNumUse
		Else
			cPortador	:= xNumCaixa()
			If !Empty(cNumUse)
				cPortador := cNumUse
			EndIf
		EndIf

		//==============================================================
		// Gera numero do lote somando + 1 no ultimo lote encontrado    
		//==============================================================

		cLoteBx	:= GetSx8Num("MDN","MDN_LOTE",,2)

		Begin Transaction
		//LjGrvLog("Recebimento_Titulo", "LjxGrvMDX - Begin Transaction - 1")
        FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "LjxGrvMDX - Begin Transaction - 1" )
			For nX := 1 to Len(aTituloL)
				If aTituloL[nX][1]
					cCliOri := aTituloL[nX][5]
					cLojOri := aTituloL[nX][6]
					cTitNum := aTituloL[nX][4]
					SE1->(DBGoTo(aTituloL[nX][2]))
					SE5->(DBSetOrder(7))//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
					SE5->(DBSeek(xFilial("SE5") + SE1->E1_PREFIXO +  SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA + Replicate("Z", TamSx3("E5_SEQ")[1]), .T. ))
					SE5->(DBSkip(-1))
					MDM->(DBSetOrder(1))
					While (	!SE5->(BOF()) .AND. SE5->E5_PREFIXO == aTit[nX][TIT_PREF] .AND. SE5->E5_NUMERO == aTit[nX][TIT_NUME] .AND. SE5->E5_PARCELA == aTit[nX][TIT_PARC] .AND.;
							SE5->E5_TIPO == aTit[nX][TIT_TIPO] .AND. SE5->E5_CLIFOR == aTit[nX][TIT_CLIE] .AND. SE5->E5_LOJA == aTit[nX][TIT_LOJA] )
						
						//LjGrvLog(xFilial("SE5") + SE1->E1_PREFIXO +  SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO, "LjxGrvMDX - Lendo SE5",SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) )
                        FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "LjxGrvMDX - Lendo SE5: "+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) )
						If (SE5->E5_FILIAL == xFilial("SE5")) .AND.;
							( ( SE5->E5_TIPODOC $ "BA" .AND. !LjxDMoney( "SE5", SE5->E5_MOEDA, NIL ) ) ) .AND.;
							!TemBxCanc(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)) .AND.;
							!MDM->( DBSeek( xFilial("MDM") + xFilial("SE5") + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_SEQ ) ) .AND.;
							(ValType(aTitBxSE5) == "U" .OR. aScan(aTitBxSE5, { |x| x[1] == SE5->( Recno() ) } ) > 0)

							//LjGrvLog(xFilial("SE5") + SE1->E1_PREFIXO +  SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO, "LjxGrvMDX - Gravando mdm",SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) )
							//LjGrvLog(xFilial("SE5") + SE1->E1_PREFIXO +  SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO, "LjxGrvMDX - RECNO SE5: ",SE5->(Recno()) )
                            FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "LjxGrvMDX - Gravando mdm: "+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) )
                            FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "LjxGrvMDX - RECNO SE5: "+toString(SE5->(Recno()))  )


							Aadd( aMDM, {	{"MDM_FILIAL"	, xFilial( "MDM" )	},;
									{"MDM_BXFILI"	, SE1->E1_FILIAL				},;
									{"MDM_PREFIX"	, SE1->E1_PREFIXO				},;
									{"MDM_NUM"		, SE1->E1_NUM					},;
 									{"MDM_PARCEL"	, SE1->E1_PARCELA				},;
									{"MDM_TIPO"		, SE1->E1_TIPO					},;
									{"MDM_SEQ"		, SE5->E5_SEQ					},;
									{"MDM_DATA"		, dDate			  				},;
									{"MDM_LOTE"		, cLoteBx						},;
									{"MDM_ESTORN"	, "2"			  				}} )
						EndIf
						SE5->(DBSkip(-1))
					End

					//==================================
					// Grava informacoes na tabela MDM  
					//==================================
					For nY := 1 to Len(aMDM)
						DBSelectArea( "MDM" )
						MDM->(DBSetOrder( 1 ))//MDM_FILIAL+MDM_BXFILI+MDM_PREFIX+MDM_NUM+MDM_PARCEL+MDM_TIPO+MDM_SEQ+MDM_LOTE
						If DbSeek( aMDM[nY][1][2] + aMDM[nY][2][2] + aMDM[nY][3][2]+ aMDM[nY][4][2]+ aMDM[nY][5][2]+ aMDM[nY][6][2]+ aMDM[nY][7][2]+ aMDM[nY][9][2]   )
							lNewMDM := .F.
						Else
							lNewMDM := .T.
						EndIf
						
						If RecLock("MDM" , lNewMDM )
							For nZ := 1 To Len(aMDM[nY])
								REPLACE &("MDM->" + aMDM[nY][nZ][1])	WITH	aMDM[nY][nZ][2]
							Next nZ
							MDM->(MsUnlock())
						EndIf
							
					Next nY
					aMDM := {}
				EndIf
			Next nX

			If cPaisLoc <> "BRA"
				LjxGrvSEL( aTit )
			EndIf
			aArea	:= SE1->(GetArea())

			RestArea(aArea)
			aOldPgtosSl := aClone(aPgtosSL)

			For nX := 1 to Len(aPgtosL)

				If (aPgtosL[nX][2] $ cMvTpRet) .AND. cPaisLoc <> "BRA"

					cNumTitAux := U_GetNumMDM(cPrefTit)//GetNumSE1(cPrefTit)			// Alteracao para pegar numeracao SE1
					cNumTitGer	:= PadR( cNumTitAux , nTamDoc )

				ElseIf !IsMoney(AllTrim(aPgtosL[nX][2]))
				
					If AllTrim(aPgtosL[nX][2]) $ "CC|VA|CO|CD|FI|PD|PX" .OR. ( !Empty(aPgtosL[nX][7]) .AND. !AllTrim(aPgtosL[nX][2]) $ "CH")

						DbSelectArea("SAE")
						SAE->( DBSetOrder(1) )
						If SAE->( DBSeek(xFilial("SAE") + SubStr(aPgtosL[nX][7], 1, nTamAeCod)) )

							//se nao for Financiamento Proprio
							If SAE->AE_FINPRO == "N"

								If AllTrim(aPgtosL[nX][2]) $ "VA|CO"
									nDias := SAE->AE_DIAS
								ElseIf AllTrim(aPgtosL[nX][2]) $ "CC|CD" 
									dDataVenc	:= LJCalcVenc(Nil, aPgtosL[nX][1], .F.)
									nDias		:= dDataVenc - aPgtosL[nX][1]
								Else
									nDias := 0
								EndIf

                                If SAE->( ColumnPos("AE_LOJCLI") ) > 0 .And. !Empty(SAE->AE_CODCLI) .And. !Empty(SAE->AE_LOJCLI)

                                    cCodCLi	 := SAE->AE_CODCLI
                                    cLojCli	 := SAE->AE_LOJCLI
                                Else

                                    //Inclui Administradora como cliente para geração do contas a receber
                                    L070IncSA1()

                                    cCodCLi	:= SAE->AE_COD
                                    cLojCli	:= "01"
                                EndIf
								cNomeCli	:= SAE->AE_DESC

								// inclui Administradora como Fornecedor para Geracao do Contas a Pagar
								If lMvLjGerTx .AND. AllTrim(aPgtosL[nX][2]) $ "CC|CD|PX"
									cCodSA2 := L070IncSA2()	//retorna o código do Fornecedor(SA2)
								EndIf

							Else
								cCodCLi		:= cCdCli
								cLojCli		:= cLjCli
								cNomeCli	:= ""
							EndIf
						
							nTxPagto := aScan(aOldPgtosSl, { |x| AllTrim(x[01]) ==  AllTrim(aPgtosL[nX,02]) })

							If ExistFunc("LjTxAdmFin")
								aTaxaAdm := LjTxAdmFin(SAE->AE_COD, aOldPgtosSl[nTxPagto,02])

								// Calcula o valor da Taxa da Adm. Financeira
								If aTaxaAdm[2] > 0
									nValorTaxa 	:= aTaxaAdm[2]
								Else
									nTaxa 		:= aTaxaAdm[1]
									nValorTaxa 	:= aPgtosL[nX][3] * ( nTaxa / 100 )
								EndIf		
							Else

								///////////////////////////////////////////////////////////////////////
								//Chamada da rotina LJ7_TxAdm para cálculo da taxa da Adm Financeira // 
								//de acordo com o cadastrado na tabela MEN							  //
								//Parâmetros utilizados:						    						  //
								// aOldPgtosSl[nTxPagto,02] - Quantidade de parcelas					  //
								// aOldPgtosSl[nX,03] - Valor total das parcelas						  //
								//////////////////////////////////////////////////////////////////////
								aAdmValTax := LJ7_TxAdm( SAE->AE_COD, aOldPgtosSl[nTxPagto,02], aPgtosL[nX,03] )
							
								nTaxa := Iif(aAdmValTax[03] > 0,aAdmValTax[03],SAE->AE_TAXA)

								nValorTaxa := (aPgtosL[nX][3] * nTaxa) / 100
							EndIf
						EndIf

					Else
						cCodCLi		:= cCdCli
						cLojCli		:= cLjCli
						cNomeCli	:= ""
						nDias		:= 0
						nTaxa		:= 0 
						nValorTaxa	:= 0
					EndIf

					// Tratamento para gerar um unico numero de titulo e suas parcelas
				 	If nPosFPgto > 0

				 		If nCont < nMaxParc
							cGRParc := AllTrim(Soma1(cGRParc, nTamE1_PARCELA))
							nCont++
				 		Else
				 			nPosFPgto := 0
				 		EndIf

				 	EndIf

					// Tratamento para gerar um unico numero de titulo e suas parcelas
				 	If nPosFPgto == 0
 					 	nCont		:= 1
					 	nPosFPgto	:= aScan( aPgtosSL, { |x| x[1] $ aPgtosL[nX][2] } )
 					 	nMaxParc	:= aPgtosSL[nPosFPgto][2]

						If nPosFPgto > 0
							aDel(aPgtosSL, nPosFPgto)
				    		aSize(aPgtosSL, Len(aPgtosSL)-1)
						EndIf

			 			cGRParc		:= StrZero( 1 , nTamE1_PARCELA)
			 			cNumTitAux	:= U_GetNumMDM(cPrefTit)//GetNumSE1(cPrefTit)			// Alteracao para pegar numeracao SE1
						cNumTitGer	:= PadR( cNumTitAux , nTamDoc )
				 	EndIf

				 	//Eh forma de pagamento de conciliador e alterou a forma, a administradora e  cartão, reinicia MEP
				  	If lGrvMEP .and. AllTrim(aPgtosL[nX][02]) $ "CC/CD" .and. nX > 1 .and.;
				  		!( aPgtosL[nX][02]   +	aPgtosL[nX][07]      + aPgtosL[nX][13] == ;
				  	       aPgtosL[nX - 1][02] +   aPgtosL[nX - 1][07] + aPgtosL[nX - 1][13])

						nParcMEP := 0
				  	EndIf

					aMDN:= {{"MDN_FILIAL"		, xFilial("MDN")			},;
							{"MDN_GRFILI"		, xFilial("SE1")			},;
							{"MDN_PREFIX"		, cPrefTit					},;
 							{"MDN_NUM"			, cNumTitGer				},;
							{"MDN_PARCEL"		, cGRParc					},;
							{"MDN_TIPO"			, aPgtosL[nX][2]			},;
							{"MDN_LOTE"			, cLoteBx					}}

					//===================================
					// Grava informacoes na tabela MDN 
					//===================================
					RecLock("MDN" , .T.)
					For nY := 1 to Len(aMDN)
						REPLACE &("MDN->" + aMDN[nY][1])	WITH	aMDN[nY][2]
					Next nY
					MDN->( MsUnlock() )
					aMDN := {}

					Do Case
						Case AllTrim(aPgtosL[nX][2]) == "VA"
							cNature	:= LjMExeParam("MV_NATVALE")
						Case AllTrim(aPgtosL[nX][2]) == "CC"
							cNature	:= LjMExeParam("MV_NATCART")
						Case AllTrim(aPgtosL[nX][2]) == "CH"
							cNature	:= LjMExeParam("MV_NATCHEQ")
						Case AllTrim(aPgtosL[nX][2]) == "CD"
							cNature	:= LjMExeParam("MV_NATTEF")
						Case AllTrim(aPgtosL[nX][2]) == "CO"
							cNature	:= LjMExeParam("MV_NATCONV")
						Case AllTrim(aPgtosL[nX][2]) == "FI"
							cNature := LjMExeParam("MV_NATFIN")
						Case AllTrim(aPgtosL[nX][2]) == "PD"
							cNature := LjMExeParam("MV_NATPGDG", .F. , "PAGDIGITAL")
						Case AllTrim(aPgtosL[nX][2]) == "PX"
							cNature := LjMExeParam("MV_NATPGPX", .F. , "PAGTOPIX")
						Otherwise
							cNature := LjMExeParam("MV_NATOUTR")
					EndCase

					//==============================================================
					// Monta o array com as informacoes para a gravacao do titulo 
					//==============================================================
					aSE1 := {{"E1_FILIAL"	,xFilial("SE1")											,Nil},;
							{"E1_PREFIXO"	,cPrefTit												,Nil},;
							{"E1_NUM"	  	,cNumTitGer												,Nil},;
							{"E1_PARCELA" 	,cGRParc 												,Nil},;
							{"E1_TIPO"	 	,PadR(aPgtosL[nX][2],nTamTipo)							,Nil},;
							{"E1_NATUREZ" 	,cNature												,Nil},;
							{"E1_PORTADO" 	,cPortador												,Nil},;
				    	   	{"E1_CLIENTE" 	,PadR(cCodCLi,TamSx3("E1_CLIENTE")[1])					,Nil},;
				    	   	{"E1_EMITCHQ"	,IIf(aPgtosL[nX][2] $ MVCHEQUE .And. !Empty(aPgtosL[nX][14]), PadR(aPgtosL[nX][14],TamSx3("E1_EMITCHQ")[1]), "" ), NIL},;
				        	{"E1_LOJA"	  	,cLojCli												,Nil},;
						    {"E1_EMISSAO" 	,dDate	 												,Nil},;
							{"E1_VENCTO"  	,(aPgtosL[nX][1] + nDias)								,Nil},;
							{"E1_VENCREA" 	,(aPgtosL[nX][1] + nDias)								,Nil},;
							{"E1_MOEDA" 	,1														,Nil},;
							{"E1_ORIGEM"	,"LOJA701"												,Nil},;
							{"E1_FLUXO"		,"S"													,Nil},;
							{"E1_VALOR"	  	,( aPgtosL[nX][3] - iIf(!lMvLjGerTx,nValorTaxa,0) )		,Nil},;
							{"E1_VLRREAL"  	,aPgtosL[nX][3]											,Nil},;
							{"E1_HIST"		,""														,Nil},;
							IIf (aPgtosL[nX][2] $ MVCHEQUE , {"E1_BCOCHQ" ,	aPgtosL[nX][4]	,Nil},  {"E1_BCOCHQ" 	, ""	,Nil}),;
							IIf (aPgtosL[nX][2] $ MVCHEQUE , {"E1_AGECHQ" ,	aPgtosL[nX][5]	,Nil},	{"E1_AGECHQ"	, ""	,Nil}),;
							IIf (aPgtosL[nX][2] $ MVCHEQUE , {"E1_CTACHQ" ,	aPgtosL[nX][6]	,Nil},  {"E1_CTACHQ"	, ""	,Nil}),;
							IIf (aPgtosL[nX][2] $ MVCHEQUE	.OR. aPgtosL[nX][2] $ "CC|CD",;
								{"E1_NUMCART",	aPgtosL[nX][10]	,Nil},  {"E1_NUMCART", "", Nil})}

					If cPaisLoc <> "BRA"
					   Aadd(aSE1, {"E1_RECIBO",cRecibo   ,Nil} )
					   Aadd(aSE1, {"E1_SERREC",cSerieRec ,Nil} )

						If Alltrim(aPgtosL[nX][2])=="CH"
					    	aDadosBanc := GetAdvFVal( "SA6", { "A6_AGENCIA", "A6_NUMCON" },xFilial("SA6")+cPortador, 1, { ".", "."} )		//  Busca AG e conta cadastrados na SA6
					      
					    	aadd(aSE1, {"E1_AGEDEP", If(aPgtosL[nX][8]==1,PadR(aDadosBanc[1],TamSX3("E1_AGEDEP")[1]),MV_SIMB1 ), Nil})
					    	aadd(aSE1, {"E1_CONTA" , PadR(aDadosBanc[2],TamSX3("E1_CONTA")[1]) , NIL } )
						Endif
					Endif

					If Alltrim(aPgtosL[nX][2]) $ _FORMATEF .Or. Alltrim(aPgtosL[nX][2]) $ _FORMAPGDG
 					    Aadd(aSE1, {"E1_DOCTEF"	,	aPgtosL[nX][12]   ,Nil} )
					    Aadd(aSE1, {"E1_NSUTEF"	,	aPgtosL[nX][11]   ,Nil} )
						Aadd(aSE1, {"E1_CARTAUT",	aPgtosL[nX][15]   ,Nil} )
					Endif

					//Inclusao do Titulo a Receber
					MSExecAuto({|x,y| Fina040(x,y)},aSE1, 3) //Inclusao

					If lMsErroAuto
						DisarmTransaction()
						//LjGrvLog("Recebimento_Titulo", "LjxGrvMDX - DisarmTransaction() - Fina040(aSE1)")
                        FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "LjxGrvMDX - DisarmTransaction() - Fina040(aSE1)" )
						RollBackSx8()
						lRet := .F.

						If nModulo == 12 .OR. ( (nModulo <> 23 .AND. LJModNFis()) .And. !lRotinaWs)	// Coloca o erro no console.log para ser visto quando eh frontloja
							MostraErro()
						Else
							Conout( MostraErro("\") )
						EndIf
					Else
						If AllTrim(SE1->E1_TIPO) $ cTipoBx
							If Len(aDadosBanc) == 0
								aDadosBanc :=  GetAdvFVal( "SA6", { "A6_AGENCIA", "A6_NUMCON" },xFilial("SA6")+cPortador, 1, { ".", "."} )		// Busca AG e conta cadastrados na SA6
							EndIf	

							//Monta array para a ExecAuto
							aFina070 := {	{"E1_PREFIXO"  ,cPrefTit  ,Nil 	},;
							{"E1_NUM"      ,cNumTitGer	           ,Nil    	},;
							{"E1_TIPO"     ,PadR(aPgtosL[nX][2],nTamTipo)   ,Nil  	},;
							{"E1_PARCELA"  ,cGRParc			       ,Nil    	},;
							{"AUTMOTBX"    ,"NOR"                  ,Nil    	},;
							{"AUTBANCO"    ,cPortador 	           ,Nil    	},;
							{"AUTAGENCIA"  ,aDadosBanc[1]          ,Nil   	},;
							{"AUTCONTA"    ,aDadosBanc[2]          ,Nil    	},;
							{"AUTDTBAIXA"  ,dDate	     		   ,Nil    	},;
							{"AUTDTCREDITO",dDate		           ,Nil   	},;
							{"AUTHIST"     ,cHistor			       ,Nil   	},; 
							{"AUTJUROS"    ,0                      ,Nil		},;
							{"AUTVALREC"   ,(aPgtosL[nX][3] - iIf(!lMvLjGerTx,nValorTaxa,0)) ,Nil  }}

							//Chama ExecAuto FINA070 para baixa automatica do titulo	
							MSExecAuto({|a,b,c,d,e,f| Fina070(a,b,c,d,e,f)},aFina070, 3,,,, aParamLj)

							If lMsErroAuto
								DisarmTransaction()
								//LjGrvLog("Recebimento_Titulo", "LjxGrvMDX - DisarmTransaction() - Fina070(aFina070)")
                                FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "LjxGrvMDX - DisarmTransaction() - Fina070(aFina070)" )
								RollBackSx8()
								lRet := .F.
								
								If isblind()
									Conout( MostraErro("\") )
								Else									
									MostraErro()
								EndIf								
							EndIf

						EndIf
					EndIf

					
					If !Empty(cNomeCli)
						// Salva a área para não perder o registro salvo anteriormente
						// e para que a numeração dos títulos continue sequencial e correta evitando erro por inclusão de mesmo registro
						aArea	:= SE1->(GetArea())
						DbSelectArea("SE1")
						SE1->(DbSetOrder(1))
						If SE1->(DbSeek(aSE1[1][2] + aSE1[2][2] + aSE1[3][2] + aSE1[4][2] + aSE1[5][2]))
							RecLock( "SE1",.F.)
							SE1->E1_NOMCLI  := cNomeCli
							Aadd(aSE1, {"E1_NOMCLI"	,	cNomeCli   ,Nil} )
							SE1->( MsUnlock() )
						EndIf
						RestArea(aArea)
		    	    EndIf
					If ExistBlock("LJRECSE1")	 
						ExecBlock( "LJRECSE1", .F., .F., { aSE1,aTit} ) 
					Endif

					If !lMsErroAuto  .AND. lGrvMEP .and. AllTrim(aPgtosL[nX][02]) $ "CC/CD"
						//Realiza a gravacao da MEP
						nParcMEP++ //Incrementa o contador TEF
						SE1->( DbSetOrder(1) )
						If SE1->(DbSeek( aSE1[1][2] + aSE1[2][2] + aSE1[3][2] + PadR(aSE1[4][2],nTamE1_PARCELA) + aSE1[5][2] ))
					   		RecLock("MEP", .T.)
					   		REPLACE MEP->MEP_FILIAL WITH xFilial("MEP")
					   		REPLACE MEP->MEP_PREFIX WITH SE1->E1_PREFIXO
					   		REPLACE MEP->MEP_NUM 	WITH SE1->E1_NUM
					   		REPLACE MEP->MEP_PARCEL WITH SE1->E1_PARCELA
					   		REPLACE MEP->MEP_TIPO   WITH SE1->E1_TIPO
					   		REPLACE MEP->MEP_PARTEF WITH StrZero(nParcMEP, nTamParTEF)

					   		MEP->( MsUnLock() )
						EndIf
					EndIf

					//
					//indica que deve incluir um Titulo no Contas a Pagar (taxa da Administradora Financeira) MCL
					//
					If !lMsErroAuto .AND. !Empty(cCodSA2) .AND. lMvLjGerTx

						nValorTaxa := A410Arred( nValorTaxa, "L2_VRUNIT" )

						// Proteção para não deixar gerar o MSExecAuto do Fina050 (abaixo) sem valor.
						// A variável nValorTaxa chegará aqui zerada se o campo "Taxa de Cobrança" no SAE estiver 0(zero) e
						// o parametro MV_LJGERTX estiver = .T.
						If nValorTaxa > 0 
						
							aVetorSE2 :={	{"E2_PREFIXO"	, SE1->E1_PREFIXO		, Nil}	,;
											{"E2_NUM"	   	, SE1->E1_NUM    		, Nil}	,;
											{"E2_PARCELA"	, SE1->E1_PARCELA		, Nil}	,;
											{"E2_TIPO"		, SE1->E1_TIPO   		, Nil}	,;
											{"E2_NATUREZ"	, SE1->E1_NATUREZ		, Nil}	,;
											{"E2_FORNECE"	, cCodSA2	 			, Nil}	,;
											{"E2_LOJA"		, SE1->E1_LOJA   		, Nil}	,;
											{"E2_EMISSAO"	, DDATABASE      		, NIL}	,;
											{"E2_VENCTO"	, SE1->E1_VENCTO 		, NIL}	,;
											{"E2_VENCREA"	, SE1->E1_VENCREA		, NIL}	,;
											{"E2_VALOR"		, nValorTaxa 			, NIL}	,;
											{"E2_HIST"		, AllTrim(SE1->E1_NUM)	, NIL}	}

							lMsErroAuto := .F.
							cCodSA2		:= ""

							// Faz a INCLUSAO do CONTAS A PAGAR via ExecAuto
							MSExecAuto( {|x,y,z| FINA050(x,y,z)}, aVetorSE2, Nil, 3 )

							// Verifica se houve algum durante a execucao da rotina automatica
							If lMsErroAuto
								DisarmTransaction()
								//LjGrvLog("Recebimento_Titulo", "LjxGrvMDX - DisarmTransaction() - Fina050(aVetorSE2)" )
                                FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "LjxGrvMDX - DisarmTransaction() - Fina050(aVetorSE2)" )
								RollBackSx8()
								lRet:= .F.

								If nModulo == 12 .OR. ( (nModulo <> 23 .AND. LJModNFis()) .And. !lRotinaWs )
									MostraErro()
								Else
									conout( MostraErro() )
								EndIf
							EndIf
						Endif
					EndIf
					aSE1 := {}
				EndIf

				If cPaisLoc <> "BRA"
					nTroco := 0
					If lTroco
						nPosMoeda := ascan(aMoedas, { |x| x[6] == aPgtosL[nX][8]} )
						If nPosMoeda > 0
							nTroco := aMoedas[nPosMoeda][3]
						EndIf
					Else
						If IsMoney(aPgtosL[nX][2])
							If aPgtosL[nX][8] > 1
								nTroco := xMoeda(Lj7T_Troco(2), 1, aPgtosL[nX][8], dDataBase, 3)
							Else
								nTroco := Lj7T_Troco(2)
							EndIf
						EndIf
					EndIf

					If  ( aPgtosL[nX][3]-nTroco < 0 )
						nTroco := 0
					EndIf

					SEL->( RecLock("SEL",.T.) )
					SEL->EL_FILIAL		:= xFilial("SEL")
					SEL->EL_TIPODOC		:= AllTrim( aPgtosL[nX][2] )
					SEL->EL_PREFIXO		:= SE1->E1_PREFIXO
					SEL->EL_NUMERO		:= IIf( !( IsMoney(aPgtosL[nX][2]) .OR. (Alltrim(aPgtosL[nX][2]) $ cMvTpRet) ), SE1->E1_NUM, cTitNum )
					SEL->EL_PARCELA		:= SE1->E1_PARCELA
					SEL->EL_TIPO		:= AllTrim( aPgtosL[nX][2] )
					SEL->EL_BCOCHQ		:= SE1->E1_BCOCHQ
					SEL->EL_AGECHQ		:= SE1->E1_AGECHQ
					SEL->EL_CTACHQ		:= SE1->E1_CTACHQ
					SEL->EL_EMISSAO		:= SE1->E1_EMISSAO
					SEL->EL_EMISREC		:= dDataBase
					SEL->EL_DTDIGIT		:= dDataBase
					SEL->EL_DTVCTO		:= SE1->E1_VENCTO
					SEL->EL_NATUREZ		:= SE1->E1_NATUREZ
					SEL->EL_MOEDA		:= STRZERO(SE1->E1_MOEDA,2)
					SEL->EL_VLMOED1		:= IIf( IsMoney(aPgtosL[nX][2]), aPgtosL[nX][3]-nTroco, aPgtosL[nX][3] )
					SEL->EL_DESCONT		:= SE1->E1_DESCONT

				    If SEL->(FieldPos("EL_MULTA")) > 0
				       SEL->EL_MULTA	:= SE1->E1_MULTA
				    EndIf

				    If SEL->(FieldPos("EL_JUROS")) > 0
				       SEL->EL_JUROS	:= SE1->E1_VALJUR
				    EndIf

					SEL->EL_VALOR		:= IIf( IsMoney(aPgtosL[nX][2]), aPgtosL[nX][3]-nTroco, aPgtosL[nX][3] )
					SEL->EL_CLIENTE		:= SE1->E1_CLIENTE
					SEL->EL_LOJA		:= SE1->E1_LOJA
					SEL->EL_SERIE		:= cSerieRec
					SEL->EL_RECIBO		:= LjGetStation("LG_PDV") + SubStr(cRecibo, 5, 8)
					SEL->EL_CLIORIG		:= cCliOri
					SEL->EL_LOJORIG		:= cLojOri

					SEL->( MsUnlock() )
				EndIf

				If Alltrim(aPgtosL[nX][2]) == "CH"
					//========================================================
					// Quando for loja ou faturamento, não usar objeto de ws
					//========================================================
					If nModulo == 12 .OR. ( (nModulo <> 23 .AND. LJModNFis()) .And. !lRotinaWs) .Or. (nModulo == 23 .And. !lRotinaWs) //Tratamento para o TOTVS PDV
						If ValType(aPgto[nX][4][1]) == 'A' .AND. Len(aPgto[nX][4][1]) >= 11
							For nI := 1 To Len(aPgto[nX][4])
								LJRecGrvCH(aPgto[nX][4][nI][4]	,;	// Banco
											aPgto[nX][4][nI][5]	,;	// Agencia
											aPgto[nX][4][nI][6]	,;	// Conta
											aPgto[nX][4][nI][7]	,;	// Numero
											aPgto[nX][4][nI][1]	,;	// Valor
											aPgto[nX][4][nI][2]	,;	// Data
											aPgto[nX][4][nI][8]	,;	// Compensacao
											aPgto[nX][4][nI][9]	,;	// RG
											aPgto[nX][4][nI][10]	,;	// Telefone
											aPgto[nX][4][nI][12]	,;	// Chq Terceiro
											SE1->E1_PREFIXO		,;	// Prefixo 2
											SE1->E1_NUM			,;	// Titulo 3
											SE1->E1_PARCELA		,;	// Parcela 4
											SE1->E1_TIPO			,;	// Tipo
											SE1->E1_CLIENTE		,;	// Cliente
											SE1->E1_LOJA		,;	// Loja
											iif(Len(aPgto[nX][4][nI]) > 13, aPgto[nX][4][nI][14] , ""))	// Emitente Terceiro
							Next
						Else
							LJRecGrvCH( aPgto[nX][4][4] ,;	// Banco
										aPgto[nX][4][5],;	// Agencia
										aPgto[nX][4][6],;	// Conta
										aPgto[nX][4][7],;	// Numero
										aPgto[nX][4][1],;	// Valor
										aPgto[nX][4][2],;	// Data
										aPgto[nX][4][8],;	// Compensacao
										aPgto[nX][4][9],;	// RG
										aPgto[nX][4][10],;	// Telefone
										aPgto[nX][4][12],;	// Chq Terceiro
										SE1->E1_PREFIXO,;	// Prefixo 2
										SE1->E1_NUM,;		// Titulo 3
										SE1->E1_PARCELA,;	// Parcela 4
										SE1->E1_TIPO,;		// Tipo
										SE1->E1_CLIENTE,;	// Cliente
										SE1->E1_LOJA   ,;	// Loja
										iif(Len(aPgto[nX][4]) > 13, aPgto[nX][4][14] , ""))	// Emitente Terceiro
						EndIf
					Else
						LJRecGrvCH( aPgto:VerArray[nX]:BCOCHQ ,;	// Banco
									aPgto:VerArray[nX]:AGECHQ,;		// Agencia
									aPgto:VerArray[nX]:CTACHQ,;		// Conta
									aPgto:VerArray[nX]:NUMERO,;		// Numero
									aPgto:VerArray[nX]:VALOR,;		// Valor
									aPgto:VerArray[nX]:DATACH,;		// Data
									aPgto:VerArray[nX]:COMPENS,;	// Compensacao
									aPgto:VerArray[nX]:RG ,;		// RG
									aPgto:VerArray[nX]:TEL,;		// Telefone
									aPgto:VerArray[nX]:CHETER,;	// Chq Terceiro
									SE1->E1_PREFIXO,;			// Prefixo 2
									SE1->E1_NUM,;				// Titulo 3
									SE1->E1_PARCELA,;			// Parcela 4
									SE1->E1_TIPO,;				// Tipo
									SE1->E1_CLIENTE,;			// Cliente
									SE1->E1_LOJA   ,;			// Loja
									aPgto:VerArray[nX]:ECHETER)	// Emitente Terceiro
					EndIf
				EndIf

				If cPaisLoc <> "BRA"
					LjxGrvSFE()
				EndIf

			Next nX

			aPgtosSL := aClone(aOldPgtosSl)
			aSize(aOldPgtosSl, 0)
			aOldPgtosSl := Nil

		End Transaction
		//LjGrvLog("Recebimento_Titulo", "LjxGrvMDX - End Transaction - 1")
        FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "LjxGrvMDX - End Transaction - 1" )
		ConfirmSX8()

		//========================================
		// Retornando valor padrao de nModOrigem. 
		//========================================
		nModOrigem := 0
		//========================================
		// Retornando valor padrao de lLojxRec.	 
		//========================================
		lLojxRec   := .F.
	Else

		//=======================================================================
		// O estorno só é executado na venda assistida, por isto usa o aTitulo.
		//=======================================================================

		Begin Transaction
		//LjGrvLog("Recebimento_Titulo", "LjxGrvMDX - Begin Transaction - 2")
        FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "LjxGrvMDX - Begin Transaction - 2" )

			DBSelectArea("MDM")
			MDM->(DBSetOrder(2))
			For nX := 1 to Len(aTitulo)
				If aTitulo[nX][TIT_SELE]
			MDM->(DBSeek(xFilial("MDM")+cLote))
			While !MDM->(Eof()) .AND. (MDM->MDM_LOTE == clote )
		
				If MDM->MDM_ESTORN == "1"
					MDM->(DbSkip())
					Loop
				EndIf

				RecLock("MDM" , .F.)
				//Adicionado tratamento para marcar como estornado apenas o cartao correto						
				REPLACE	MDM->MDM_ESTORN	WITH	"1"
				MDM->(MsUnlock())
				lTitGerado	:= .T.
				MDM->(DbSkip())
			End
				EndIf
			Next nX

			If lTitGerado
				DbSelectArea( "MDN" )
				MDN->(DbSetOrder( 2 ))
				If MDN->(DBSeek(xFilial( "MDN" ) + cLote ))
					While !MDN->(Eof()) .AND. MDN->MDN_LOTE == cLote

							DbSelectArea("SE1")
							SE1->(DbSetOrder(1))
							If SE1->(DBSeek(MDN->MDN_GRFILI + MDN->MDN_PREFIX + MDN->MDN_NUM + MDN->MDN_PARCEL + MDN->MDN_TIPO))
								While !SE1->(Eof()) .AND. (SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM ) ==;
									(MDN->MDN_GRFILI + MDN->MDN_PREFIX + MDN->MDN_NUM )
	
									aSE1  := {{"E1_FILIAL"	,xFilial("SE1")		,Nil},;
										{"E1_PREFIXO"	,SE1->E1_PREFIXO  		,Nil},;
										{"E1_NUM"	  	,SE1->E1_NUM			,Nil},;
										{"E1_PARCELA" 	,SE1->E1_PARCELA		,Nil},;
										{"E1_TIPO"	 	,AllTrim(SE1->E1_TIPO)	   		,Nil} }
																	
									//======================================================
									// Exclui registro do contas a pagar de			
									// taxa adminstrativa. parametro MV_LJGERTX = .T.
									//======================================================
									If lMvLjGerTx
										Lj140ExCap()    
									EndIf
																	
									MSExecAuto({|x,y| Fina040(x,y)},aSE1, 5) // Exclusao
									
									If  lMsErroAuto
									    DisarmTransaction()
									    //LjGrvLog("Recebimento_Titulo", "LjxGrvMDX - DisarmTransaction() - Fina040()- 2")
                                        FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "LjxGrvMDX - DisarmTransaction() - Fina040()- 2" )
										lRet:= .F.
										If nModulo == 12 .OR. ( (nModulo <> 23 .AND. LJModNFis()) .And. !lRotinaWs)
											MostraErro()
										// Coloca o erro no console.log para ser visto quando eh frontloja
										Else
											Conout( MostraErro() )
										EndIf
									EndIf								
									
									SE1->(DBSkip())
								End
							EndIf
						MDN->(DBSkip())
					End
				EndIf
			EndIf
		End Transaction
		//LjGrvLog("Recebimento_Titulo", "LjxGrvMDX - End Transaction - 2")
        FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "LjxGrvMDX - End Transaction - 2" )
	EndIf
EndIf

Return  lRet


/*/{Protheus.doc} LJModNFis
Verifica recebimento por Modulo sem ECF
@type function
@version  
@author g.sampaio
@since 14/12/2023
@param , variant, param_description
@return variant, Logico (.T. se modulo sem uso de ECF  
/*/
Static Function LJModNFis( )
	Local lAutomato		:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
	Local lRet := .F.

	If (nModulo == 12 .OR. nModulo == 23)	//Recebimento pelo Loja/Front com NFC-e
		If lRecebNFCE == NIL				//Variável Static
			lRecebNFCE := Iif(!lAutomato .AND. GetAPOInfo("LOJA121.PRW")[4] >= Ctod("16/03/2017"),;
				!(Lj121IsFis(LjGetStation("LG_IMPFISC"))),;		//Função do LOJA121.PRW - .T. retorna se Fiscal, mas o que estamos querendo é .T. se não-fiscal. Por isso o "!"
			LjEmitNFCe())
		EndIf
		lRet := lRecebNFCE
	ElseIf (nModulo == 5 .OR. nModulo == 6)		//Recebimento pelo Venda Direta
		lRet := .T.
	EndIf

Return lRet

/*/{Protheus.doc} ValTroco
Retorna o Valor do Troco Referente ao Título  
@type function
@version  
@author g.sampaio
@since 14/12/2023
@param cPrefixo, character, param_description
@param cNum, character, param_description
@param cParcela, character, param_description
@param cTipo, character, param_description
@param cCliente, character, param_description
@param cLoja, character, param_description
@param cSeq, character, param_description
@param nEstTroco, numeric, param_description
@return variant, return_description
/*/
Static Function ValTroco(cPrefixo,cNum,cParcela,cTipo,cCliente,cLoja,cSeq,nEstTroco)

Local aAreaAtu 	:= GetArea()      //Guarda area atual
Local aAreaSE5 	:= GetArea("SE5") //Guarda area da tabela SE5
Local nRet		:= 0              //Valor retornado pela função quando o titulo que gerou o troco for E5_TIPO = "VL"
Local nVlTroco  := 0              //Valor do troco encontrado na sequencia de baixas 
Local cChaveSE5 := xFilial("SE5")+cPrefixo+cNum+cParcela+Space(TamSX3("E5_TIPO")[1])
Local lAchouSE5 := .F.
Local cCodCli	:= cCliente
Local cCodLoj	:= cLoja

DbSelectArea("SE5")
SE5->( DbSetOrder(7) ) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
//Primeiro posiciona para procurar o registro de troco referente ao titulo
If !( lAchouSE5 := SE5->( DbSeek( cChaveSE5 + cCodCli + cCodLoj ) ) )
	
	//Se o sistema estiver atualizado com o novo tratamento de gravacao do troco, o troco não é mais gravado com informações do codigo do cliente e loja (os campos ficam em branco)
	If ExistFunc("LjNewGrvTC") .And. LjNewGrvTC() //Verifica se o sistema está atualizado para executar o novo procedimento para gravação dos movimentos de troco.
		//Faz a busca considerando o codigo do cliente e loja em branco
		cCodCli := Space(TamSX3("E5_CLIFOR")[1])
		cCodLoj := Space(TamSX3("E5_LOJA")[1])
		lAchouSE5 := SE5->( DbSeek( cChaveSE5 + cCodCli + cCodLoj ) )
	EndIf
EndIf

If lAchouSE5
	cChaveSE5 := cChaveSE5 + cCodCli + cCodLoj
    While !SE5->(Eof()) .AND. cChaveSE5 == SE5->E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_CLIFOR + SE5->E5_LOJA

        If SE5->E5_MOEDA <> "TC" .OR. SE5->E5_TIPODOC <> "VL" .OR.;
                SE5->E5_RECPAG <> "P" .OR. SE5->E5_SEQ <> cSeq
            SE5->(DbSkip())
            Loop
        EndIf

        nVlTroco  := SE5->E5_VALOR
        nEstTroco := SE5->(Recno())
        Exit
    EndDo
EndIf

//============================================================================
// Depois deve procurar se existe o registro do tipo "VL" ,pois			    
// somente o registro VL deve atualizar o saldo subtraindo o valor do troco 
//============================================================================
DbSelectArea("SE5")
SE5->(DbSetOrder(2))
If nVlTroco > 0 .And. SE5->(DbSeek(xFilial("SE5")+"VL"+cPrefixo+cNum+cParcela+cTipo))

	While !SE5->(Eof()) .and. SE5->E5_FILIAL==xFilial("SE5") .and. ;
	SE5->E5_TIPODOC+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO=="VL"+cPrefixo+cNum+cParcela+cTipo

		If SE5->E5_CLIFOR <> cCliente .OR. SE5->E5_LOJA <> cLoja .OR. SE5->E5_SEQ <> cSeq
			DbSkip()
			Loop
		EndIf

        nRet := nVlTroco

		Exit
	EndDo
EndIf

RestArea(aAreaSE5)
RestArea(aAreaAtu)

Return nRet

/*/{Protheus.doc} LjxGrvSEL
Como e chamado de varias vezes para chamar uma vez so 
@type function
@version  
@author g.sampaio
@since 14/12/2023
@param aTitulo, array, param_description
@param lGrvPgtos, logical, param_description
@return variant, return_description
/*/
Static Function LjxGrvSEL( aTitulo, lGrvPgtos )

	Local nX		:= 0
	Local nTroco	:= 0
	Local nTrocoLoc	:= 0

	DEFAULT	lGrvPgtos 	:= .F.

	If cPaisLoc <> "BRA"
		For nX := 1 to Len(aTitulo)
			If  aTitulo[nX][TIT_SELE]
				SE1->(DBGoTo(aTitulo[nX][TIT_RECN]))

				SEL->( RecLock("SEL", .T.) )
				SEL->EL_FILIAL		:= xFilial("SEL")
				SEL->EL_TIPODOC		:= "TB"
				SEL->EL_PREFIXO		:= SE1->E1_PREFIXO
				SEL->EL_NUMERO		:= SE1->E1_NUM
				SEL->EL_PARCELA		:= SE1->E1_PARCELA
				SEL->EL_TIPO		:= AllTrim(SE1->E1_TIPO)
				SEL->EL_BCOCHQ		:= SE1->E1_BCOCHQ
				SEL->EL_AGECHQ		:= SE1->E1_AGECHQ
				SEL->EL_CTACHQ		:= SE1->E1_CTACHQ
				SEL->EL_EMISSAO		:= SE1->E1_EMISSAO
				SEL->EL_DTDIGIT		:= SE1->E1_MOVIMEN
				SEL->EL_DTVCTO		:= SE1->E1_VENCTO
				SEL->EL_EMISREC		:= SE1->E1_MOVIMEN
				SEL->EL_NATUREZ		:= SE1->E1_NATUREZ
				SEL->EL_MOEDA		:= STRZERO(SE1->E1_MOEDA,2)
				SEL->EL_VLMOED1		:= aTitulo[nX][TIT_RECE]
				SEL->EL_DESCONT		:= aTitulo[nX][TIT_DESC]

				If SEL->(FieldPos("EL_MULTA")) > 0
					SEL->EL_MULTA	:= aTitulo[nX][TIT_MULT]
				EndIf

				If SEL->(FieldPos("EL_JUROS")) > 0
					SEL->EL_JUROS	:=  aTitulo[nX][TIT_JURO]
				EndIf

				SEL->EL_VALOR		:= aTitulo[nX][TIT_RECE]
				SEL->EL_CLIENTE		:= SE1->E1_CLIENTE
				SEL->EL_LOJA		:= SE1->E1_LOJA
				SEL->EL_SERIE		:= cSerieRec
				SEL->EL_RECIBO		:= LjGetStation("LG_PDV") + SubStr(cRecibo, 5, 8)
				SEL->EL_CLIORIG		:= aTitulo[nX][TIT_CLIE]
				SEL->EL_LOJORIG		:= aTitulo[nX][TIT_LOJA]

				SEL->( MsUnlock() )
			EndIf
		Next nX

		If lGrvPgtos
			For nX := 1 to Len(aPgtos)

				If IsMoney(aPgtos[nX][3]) .AND. nTroco == 0
					If aPgtos[nX][6] > 1
						nTrocoLoc := xMoeda(Lj7T_Troco(2), 1, aPgtos[nX][6], dDataBase, 3)
						nTroco := Lj7T_Troco(2)
						nTaxa := &("SM2->M2_MOEDA"+AllTrim(Str(aPgtos[nX][6])))
					Else
						nTroco := Lj7T_Troco(2)
					EndIf
				Else
					nTroco := 0
				EndIf

				SEL->( RecLock("SEL",.T.) )
				SEL->EL_FILIAL		:= xFilial("SEL")
				SEL->EL_TIPODOC		:= AllTrim( aPgtos[nX][3] )
				SEL->EL_PREFIXO		:= SE1->E1_PREFIXO
				SEL->EL_NUMERO		:= SE1->E1_NUM
				SEL->EL_PARCELA		:= SE1->E1_PARCELA
				SEL->EL_TIPO		:= AllTrim( aPgtos[nX][3] )
				SEL->EL_BCOCHQ		:= SE1->E1_BCOCHQ
				SEL->EL_AGECHQ		:= SE1->E1_AGECHQ
				SEL->EL_CTACHQ		:= SE1->E1_CTACHQ
				SEL->EL_EMISSAO		:= SE1->E1_EMISSAO
				SEL->EL_EMISREC		:= dDataBase
				SEL->EL_DTDIGIT		:= dDataBase
				SEL->EL_DTVCTO		:= SE1->E1_VENCTO
				SEL->EL_NATUREZ		:= SE1->E1_NATUREZ
				SEL->EL_MOEDA		:= STRZERO(SE1->E1_MOEDA,2)
				If aPgtos[nX][6] > 1
					SEL->EL_VLMOED1		:= IIf( IsMoney(aPgtos[nX][3]), aPgtos[nX][10]-nTroco, aPgtos[nX][2] )
				Else
					SEL->EL_VLMOED1		:= IIf( IsMoney(aPgtos[nX][3]), aPgtos[nX][2]-nTroco, aPgtos[nX][2] )
				EndIf
				SEL->EL_DESCONT		:= SE1->E1_DESCONT

				If SEL->(FieldPos("EL_MULTA")) > 0
					SEL->EL_MULTA	:= SE1->E1_MULTA
				EndIf

				If SEL->(FieldPos("EL_JUROS")) > 0
					SEL->EL_JUROS	:= SE1->E1_VALJUR
				EndIf

				If aPgtos[nX][6] > 1
					SEL->EL_VALOR		:= IIf( IsMoney(aPgtos[nX][3]), aPgtos[nX][2]-nTrocoLoc, aPgtos[nX][2] )
				Else
					SEL->EL_VALOR		:= IIf( IsMoney(aPgtos[nX][3]), aPgtos[nX][2]-nTroco, aPgtos[nX][2] )
				EndIf
				SEL->EL_CLIENTE		:= SE1->E1_CLIENTE
				SEL->EL_LOJA		:= SE1->E1_LOJA
				SEL->EL_SERIE		:= cSerieRec
				SEL->EL_RECIBO		:= LjGetStation("LG_PDV") + SubStr(cRecibo, 5, 8)
				SEL->EL_CLIORIG		:= aTitulo[nX][TIT_CLIE]
				SEL->EL_LOJORIG		:= aTitulo[nX][TIT_LOJA]

				If aPgtos[nX][6] > 1
					&("SEL->EL_TXMOE0"+AllTrim(Str(aPgtos[nX][6]))) := nTaxa
				EndIf

				SEL->( MsUnlock() )
			Next nX
		EndIf
	EndIf

Return

/*/{Protheus.doc} LjxGrvSFE
Grava a tabela SFE (Retencoes)  
@type function
@version  
@author g.sampaio
@since 14/12/2023
@return variant, return_description
/*/
Static Function LjxGrvSFE()

	Local nX		:= 0
	Local cMvTpRet	:= SuperGetMV("MV_LJCTRET",,"RI|RG|RB|RS")

	For nX := 1 to Len(aPgtos)
		If Alltrim(aPgtos[nX][3]) $ cMvTpRet
			Do Case
			Case IsMoney(aPgtos[nX][3])					// Dinheiro
				cTipPgtoEx := AllTrim(aPgtos[nX][3])
				cTipoDocEx := "TB"
			Case AllTrim(aPgtos[nX][3]) == "CH"		// Cheque
				cTipPgtoEx := AllTrim(aPgtos[nX][3])
				cTipoDocEx := AllTrim(aPgtos[nX][3])
			Case (AllTrim(aPgtos[nX][3]) $"CC|CD|VA|CO") .OR. ( Alltrim(aPgtos[nX][3]) $ cMvTpRet )
				cTipPgtoEx := AllTrim(aPgtos[nX][3])
				cTipoDocEx := AllTrim(aPgtos[nX][3])
			EndCase

			If SFE->( !DbSeek(xFilial("SFE") + IIf( !EMPTY( aPgtos[NX][4]), aPgtos[nx][4][4], "" ) ) )
				RecLock("SFE", .T.)
				SFE->FE_FILIAL	:= xFilial("SFE")
				SFE->FE_NROCERT	:= aPgtos[nX][4][4]								// N=mero do certificado
				SFE->FE_EMISSAO	:= dDataBase										// Data da operacao
				SFE->FE_CLIENTE	:= M->LQ_CLIENTE									// Cliente
				SFE->FE_LOJCLI	:= M->LQ_LOJA										// Loja
				SFE->FE_TIPO		:= Substr(aPgtos[nX][3],2,1)						// B(Ingresos Brutos); I(IVA); S(SUSS); G(Ganancias)
				SFE->FE_RECIBO	:= LjGetStation("LG_PDV") + SubStr(cRecibo, 5, 8)	// Numero do recibo
				SFE->FE_NFISCAL	:= SE1->E1_NUM										// Numero do titulo do SE1
				SFE->FE_PARCELA	:= SE1->E1_PARCELA
				SFE->FE_RETENC	:= (aPgtos[nX][2] - ((aPgtos[nX][2] * IIf(!Empty(SAE->AE_TAXA), SAE->AE_TAXA , 0	)) /100) )	// Valor da retencao
				SFE->( MsUnlock() )
			Endif
		EndIf
	Next nX

Return

//--------------------------------------------------------------
/*/{Protheus.doc} LjEstSelE5
Transcreve de string para array, os dados de identificação do título que será estornado.

@type 		Function
@author  	Alberto Deviciente
@since   	30/03/2020
@version 	P12
@param 		cListBox, Caractere, String com os dados de identificação do título que será estornado.
@return  	Array, Array com os dados de identificação do título que será estornado. Estrutura do array de retorno:
					aRet[1] //01-Prefixo
					aRet[2] //02-Numero
					aRet[3] //03-Parcela
					aRet[4] //04-Tipo
					aRet[5] //05-Cliete
					aRet[6] //06-Loja
					aRet[7] //07-Data
					aRet[8] //08-Valor
					aRet[9] //09-Sequencia
/*/
//---------------------------------------------------------------
Static Function LjEstSelE5(cListBox)
	Local aRet 		:= {}
	Local nPosIni	:= 1
	Local nPosFim 	:= 1
	Local cCharDe 	:= Space(2)
	Local cCharPara	:= Space(1)
	Local nTamCampo := 0

	nTamCampo 	:= TamSX3("E5_PREFIXO")[1]
	aAdd( aRet, PadR(SubStr(cListBox,1,nTamCampo), nTamCampo) ) //01-Prefixo
	cListBox	:= SubStr(cListBox,nTamCampo+2)

	nTamCampo 	:= TamSX3("E5_NUMERO")[1]
	aAdd( aRet, PadR(SubStr(cListBox,1,nTamCampo), nTamCampo) )	//02-Numero
	cListBox	:= SubStr(cListBox,(nTamCampo*2)+2) //Multiplica por 2 para considerar o dobro do tamanho do campo E5_NUMERO, pois é assim que vem da função Sel070Baixa do FINA070

	nTamCampo 	:= TamSX3("E5_PARCELA")[1]
	aAdd( aRet, PadR(SubStr(cListBox,1,nTamCampo), nTamCampo) ) //03-Parcela
	cListBox	:= SubStr(cListBox,nTamCampo+2)

	nTamCampo 	:= TamSX3("E5_TIPO")[1]
	aAdd( aRet, PadR(SubStr(cListBox,1,nTamCampo), nTamCampo) ) //04-Tipo
	cListBox	:= SubStr(cListBox,nTamCampo+2)

	nTamCampo 	:= TamSX3("E5_CLIFOR")[1]
	aAdd( aRet, PadR(SubStr(cListBox,1,nTamCampo), nTamCampo) ) //05-Cliete
	cListBox	:= SubStr(cListBox,nTamCampo+2)

	nTamCampo 	:= TamSX3("E5_LOJA")[1]
	aAdd( aRet, PadR(SubStr(cListBox,1,nTamCampo), nTamCampo) ) //06-Loja
	cListBox	:= SubStr(cListBox,nTamCampo+2)

//Substitui 2 espaços por apenas 1 espaço para facilitar e agilizar no laço while a seguir usando a função AT()
	While ( At(cCharDe , cListBox ) ) > 0
		cListBox := Replace(cListBox,cCharDe,cCharPara)
	End

	cListBox := cListBox + " " //Adiciona um espaço no final como separador de conte=do.

//Adiciona as posições 7, 8 e 9 no array aRet
	While ( nPosFim := At(" " , cListBox, nPosIni ) ) > 0
		aAdd( aRet, SubStr(cListBox,nPosIni,nPosFim-nPosIni) )
		nPosFim ++
		nPosIni := nPosFim
	End

	aRet[9] := PadR(aRet[9], TamSX3("E5_SEQ"	)[1])	//09-Sequencia

Return aRet

/*/{Protheus.doc} UEstoBxNCC
Funcao para estorno dos titulos que tem baixas por
compensacao.	
@type function
@version  
@author g.sampaio
@since 14/12/2023
@param nPosTit, numeric, param_description
@return variant, return_description
/*/
User Function UEstoBxNCC(nPosTit)

Local aArea := GetArea()
Local lRet  := .T.

lMsErroAuto := .F.

DbSelectArea("SE5")
DbSetOrder(2)
If !DbSeek(xFilial("SE5")+"CP"+aTitulo[nPosTit][TIT_PREF]+aTitulo[nPosTit][TIT_NUME];
			+aTitulo[nPosTit][TIT_PARC]+aTitulo[nPosTit][TIT_TIPO])
	lRet := .F.
EndIf

If lRet
	//================================================
	// Posiciona no SE1 antes de executar o FINA330.  
	//================================================
	DbSelectArea("SE1")
	DbSetOrder(1)
	//========================================
	//  Verifica se titulo esta selecionado.  
	//========================================
	If aTitulo[nPosTit][TIT_SELE]
		If DbSeek(xFilial("SE1") + aTitulo[nPosTit][TIT_PREF] + aTitulo[nPosTit][TIT_NUME] +;
					 aTitulo[nPosTit][TIT_PARC] + aTitulo[nPosTit][TIT_TIPO])
		   	//=================
			// Fina330         
			//  5  - Estorno   
			// .T.- Automatico 
			//=================
			MSExecAuto({|x, y| Fina330(x, y)},5,.T.)

			If lMsErroAuto
				lSemErro := .F.
				//================
				//| "  Tipo: "   |
				//================
				DisarmTransaction()
				//LjGrvLog("Recebimento_Titulo", "EstoBxNCC - DisarmTransaction() - 2")
				FwLogMsg("INFO", /*cTransactionId*/,  "ULJEstBx", FunName(), "", "01", "EstoBxNCC - DisarmTransaction() - 2" )
				MostraErro()

				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} ValVlrRegra
Funcao para validar se existe reajuste
para validar o valor de desconto da regra
@type function
@version 1.0
@author g.sampaio
@since 05/04/2024
@param cPrefixo, character, param_description
@param cNumTitulo, character, param_description
@param cParcela, character, param_description
@param cTipo, character, param_description
@param nDescRegra, numeric, param_description
@param cTpDesc, character, param_description
@param nValorRegra, numeric, param_description
@return variant, return_description
/*/
Static Function ValVlrRegra( cPrefixo, cNumTitulo, cParcela, cTipo, nDescRegra, cTpDesc, nValorRegra, nValorAtual )

	Local aArea 		:= GetArea()
	Local aAreaUF8 		:= UF8->(GetArea())
	Local nRetorno 		:= 0
	Local nValorTit 	:= 0
	Local nValorOrig	:= 0

	Default cPrefixo	:= ""
	Default cNumTitulo	:= ""
	Default cParcela 	:= ""
	Default cTipo		:= ""
	Default nDescRegra	:= 0
	Default cTpDesc		:= ""
	Default nValorRegra	:= 0
	Default nValorAtual	:= 0

	UF8->(DbSetOrder(2))
	If UF8->(MsSeek(xFilial("UF8")+cPrefixo+cNumTitulo+cParcela+cTipo))
		
		If nValorAtual > 0 .And. UF8->UF8_VALOR > nValorAtual
			nValorTit := nValorAtual
		Else
			nValorTit := UF8->UF8_VALOR
		EndIf

		If cTpDesc == "P"
			nValorOrig := nValorTit / (1-(nValorRegra/100))
			nRetorno := nValorOrig * (nValorRegra/100)
		Else
			nRetorno := nValorRegra
		EndIf

	Else
		nRetorno := nDescRegra
	EndIf

	RestArea(aAreaUF8)
	RestArea(aArea)

Return(nRetorno)
