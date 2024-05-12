#include "totvs.ch"
#include "fwprintsetup.ch"
#include "fileio.ch"
#include "rptdef.ch"

/*/{Protheus.doc} RUTILR03
Rotina de processamento de comissões para :
Vendedor, Cobrador, Supervisor e Gerente 
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
/*/

User Function RUTILR03( oTempTipo, oTempDetalhes, dDeData, dAteData )

	Local aDados		:= {}
	Local cRelatorio	:= "Processamento de Comissão"

	Default oTempTipo		:= Nil
	Default oTempDetalhes	:= Nil
	Default dDeData			:= Stod("")
	Default dAteData		:= Stod("")

	// gero os dados para o relatorio
	aDados := GeraDados(oTempTipo, oTempDetalhes)

	// verifico se tenho dados para a impressao
	if Len(aDados)

		oProcess := MsNewProcess():New( { | lEnd | PrintRel( aDados, cRelatorio, dDeData, dAteData) }, cRelatorio, "Aguarde, processando os dados do relatorio...", .F. )
		oProcess:Activate()

	else
		MsgAlert("Não existem dados para serem impressos!", cRelatorio)
	endIf

Return(Nil)

/*/{Protheus.doc} PrintRel
Funcao para impressao do relatorio
@type function
@version 1.0
@author g.sampaio
@since 28/06/2021
@param cTrbTipo, character, param_description
@param cTrbDetalhes, character, param_description
@return variant, return_description
/*/
Static Function PrintRel( aDados, cRelatorio, dDeData, dAteData)

	Local aColunas				As Array
	Local aTitVendedor          As Array
	Local aTitContratos			As Array
	Local aDadosVendedor		As Array
	Local aDadosContratos		As Array
	Local aColVendedor			As Array
	Local aColContratos			As Array
	Local nMVTamanhoFonte		As Numeric
	Local nLinVendedor			As Numeric
	Local oGeraPDF				As Object
	Local oPDFPrint				As Object

	Default aDados		:= {}
	Default cRelatorio	:= ""
	Default dDeData		:= Stod("")
	Default dAteData	:= Stod("")

	// atribuo valor as variaveis
	oGeraPDF		:= Nil
	oPDFPrint 		:= Nil
	nMVTamanhoFonte	:= SuperGetMV("MV_XFONTV1",,1)
	aColunas      	:= {}
	aDadosAux		:= {}
	aTitVendedor 	:= {"Tipo", "Codigo", "Descrição", "Qtd.Vendido", "Vlr.Vendido", "Comissão"}
	aTitContratos 	:= {"Item", "Contrato", "Cliente", "Data", "Produto/Plano", "Descrição", "Valor", "Comissão"}
	aDadosVendedor	:= {}
	aDadosContratos	:= {}
	aColContratos	:= {}
	aColContratos	:= {}
	nLinVendedor	:= 0

	// atualizo o objeto de processamento
	oProcess:IncRegua2('Iniciando objeto de impressão...')

	// inicio a classe de geracao de planilha
	oGeraPDF := VirtusRelPDF():New(@oPDFPrint, cRelatorio, Nil, nMVTamanhoFonte)

	aColVendedor  := { oGeraPDF:nMargemL, 200, 400, 1400, 2000, oGeraPDF:nMargemR-375 }
	aColContratos := { oGeraPDF:nMargemL, 100, 200, 600, 800, 1000, 2000, oGeraPDF:nMargemR-375 }

	//------------------------
	// impresso do cabecalho
	//------------------------

	// atualizo o objeto de processamento
	oProcess:IncRegua2('Impressão do cabeçalho...')

	oGeraPDF:ImpCabecalho(@oPDFPrint, cRelatorio, dDeData, dAteData)

	// salto a linha
	oGeraPDF:nLinha += 100

	//--------------------------------
	// faco a impressao do relatorio
	//-------------------------------

	if Len(aDados) > 0

		// faco tratamento dos dados
		aDadosVendedor :=  U_UTrataDados(aTitVendedor, aDados)

		For nLinVendedor := 1 to Len(aDadosVendedor)

			// faco a impressao do conteudo do relatorio
			oGeraPDF:ImpRelatorio( @oProcess, @lEnd, @oPDFPrint, cRelatorio, aTitVendedor, aColVendedor, {aDadosVendedor[nLinVendedor]})

			// verifico se tem dados de contratos para serem impressos
			if Len(aDados[nLinVendedor, 7]) > 0

				// faco tratamento dos dados
				aDadosContratos :=  U_UTrataDados(aTitContratos, aDados[nLinVendedor, 7])

				// faco a impressao do conteudo do relatorio
				oGeraPDF:ImpRelatorio( @oProcess, @lEnd, @oPDFPrint, cRelatorio, aTitContratos, aColContratos, aDadosContratos )

			endIf

			// salto a linha
			oGeraPDF:nLinha += 100

		Next nLinVendedor

	endIf

	//------------------------
	// impresso do rodape
	//------------------------

	// atualizo o objeto de processamento
	oProcess:IncRegua2('Impressão do rodape...')

	// faco a impressao do rodape
	oGeraPDF:ImpRodape(@oPDFPrint)

	//------------------------
	// gera o relatorio
	//------------------------

	// atualizo o objeto de processamento
	oProcess:IncRegua2('Gerando o PDF do relatorio...')

	// faco a impressao do relatorio
	oGeraPDF:Imprimir(@oPDFPrint)

Return( Nil )

/*/{Protheus.doc} GeraDados
funcao para a geracao de dados
@type function
@version 1.0
@author g.sampaio
@since 28/06/2021
@param oTempTipo, object, objeto do tipo de vendedores
@param oTempDetalhes, object, objeto do tipo de detalhes
@return array, array de dados do retorno
/*/
Static Function GeraDados(oTempTipo, oTempDetalhes)

	Local aArea             := GetArea()
	Local aDadosVendedor    := {}
	Local aRetorno          := {}
	Local cNomeCliente      := ""

	if ValType( oTempTipo ) == "O" .And. ValType( oTempDetalhes ) == "O"

		//------------------------------------
		//Executa query para leitura da tabela
		//------------------------------------
		If Select("TMPTIPO") > 0
			TMPTIPO->( DbCloseArea() )
		EndIf

		cQuery := " SELECT TR_TIPO, TR_VEND, TR_NOME, TR_QUANT, TR_BASE, TR_COMIS FROM "+ oTempTipo:GetRealName()
		MPSysOpenQuery( cQuery, 'TMPTIPO' )

		While TMPTIPO->(!Eof())

			// limpo array de dados do vendedor
			aDadosVendedor := {}

			//------------------------------------
			//Executa query para leitura da tabela
			//------------------------------------
			If Select("TMPVEND") > 0
				TMPVEND->( DbCloseArea() )
			EndIf

			cQuery := " SELECT TR_ORIGEM, TR_ITEM, TR_CODIGO, TR_DTCOMI, TR_PRODUT, TR_DSCPRO, TR_BASE, TR_COMIS FROM "+ oTempDetalhes:GetRealName()
			cQuery += " WHERE TR_RELAC = '" + TMPTIPO->TR_VEND + "'"
			MPSysOpenQuery( cQuery, 'TMPVEND' )

			While TMPVEND->( !Eof() )

				if "CEMITERIO" $ TMPVEND->TR_ORIGEM // cemiterio

					U00->(DBSetOrder(1))
					if U00->(MsSeek(xFilial("U00")+TMPVEND->TR_CODIGO))
						cNomeCliente := U00->U00_NOMCLI
					endIf

				elseIf "FUNERARIA" $ TMPVEND->TR_ORIGEM // funeraria

					UF2->(DBSetOrder(1))
					if UF2->(MsSeek(xFilial("UF2")+TMPVEND->TR_CODIGO))
						cNomeCliente := Posicione("SA1",1,xFilial("SA1")+UF2->UF2_CLIENT+UF2->UF2_LOJA,"A1_NOME")
					endIf

				endIf

				// faco a impressao dos dados do vendedor
				aAdd( aDadosVendedor, {TMPVEND->TR_ITEM, TMPVEND->TR_CODIGO, cNomeCliente, Stod(TMPVEND->TR_DTCOMI), TMPVEND->TR_PRODUT, TMPVEND->TR_DSCPRO, TMPVEND->TR_BASE, TMPVEND->TR_COMIS} )

				TMPVEND->( DbSkip() )
			EndDo

			If Select("TMPVEND") > 0
				TMPVEND->( DbCloseArea() )
			EndIf

			aAdd(aRetorno, {TMPTIPO->TR_TIPO, TMPTIPO->TR_VEND, TMPTIPO->TR_NOME, TMPTIPO->TR_QUANT, TMPTIPO->TR_BASE, TMPTIPO->TR_COMIS, aDadosVendedor})

			TMPTIPO->(DbSkip())
		endDo

		If Select("TMPTIPO") > 0
			TMPTIPO->( DbCloseArea() )
		EndIf

	endIf

	RestArea(aArea)

Return(aRetorno)
