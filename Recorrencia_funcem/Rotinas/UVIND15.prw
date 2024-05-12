#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

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

/*/{Protheus.doc} UVIND15
Funcao que realiza o estorno da baixa de titulos do loja
@type function
@version 12.1.27
@author Wellington Goncalves
@since 11/03/2019
@param cCodFil, character, cCodFil
@param cPrefixo, character, cPrefixo
@param cNum, character, cNum
@param cParcela, character, cParcela
@param cTipo, character, cTipo
@param cErro, character, cErro
@return logical, lRet
/*/
User Function UVIND15(cCodFil,cPrefixo,cNum,cParcela,cTipo,cErro)
	Local aRet		:= {}
	Local aTitulo 	:= {}
	Local lRet 		:= .F.

	Default cErro := ""

	oVirtusFin := VirtusFin():New()

	SE1->(DbSetOrder(1)) // // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	If SE1->(DbSeek(cCodFil + cPrefixo + cNum + cParcela + cTipo ))

		// Validações para realizar estorno correto do título
		If ValidaTit(SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO,;
				SE1->E1_CLIENTE, SE1->E1_LOJA, @cErro)

			AADD(aTitulo,{})
			aTitulo[1] := Array(26)
			aTitulo[1][TIT_CONT] := ""
			aTitulo[1][TIT_FILI] := SE1->E1_FILIAL
			aTitulo[1][TIT_LOJA] := SE1->E1_LOJA
			aTitulo[1][TIT_NUME] := SE1->E1_NUM
			aTitulo[1][TIT_PARC] := SE1->E1_PARCELA
			aTitulo[1][TIT_PREF] := SE1->E1_PREFIXO
			aTitulo[1][TIT_TIPO] := SE1->E1_TIPO
			aTitulo[1][TIT_VREA] := SE1->E1_VENCREA
			aTitulo[1][TIT_VENC] := SE1->E1_VENCORI
			aTitulo[1][TIT_CACR] := .F.
			aTitulo[1][TIT_RECN] := SE1->(Recno())
			aTitulo[1][TIT_ABAT] := 0
			aTitulo[1][TIT_VALO] := SE1->E1_VALOR
			aTitulo[1][TIT_ACRS] := 0
			aTitulo[1][TIT_DESC] := 0
			aTitulo[1][TIT_MULT] := 0
			aTitulo[1][TIT_JURO] := 0
			aTitulo[1][TIT_RECE] := 0
			aTitulo[1][TIT_SELE] := .T.
			aTitulo[1][TIT_DTBX] := SE1->E1_BAIXA
			aTitulo[1][TIT_SALD] := SE1->E1_SALDO
			aTitulo[1][TIT_VLIQ] := 0

			//aRet := STReverseDropTitles(aTitulo)
			aRet := oVirtusFin:ULJEstBX(aTitulo)

			If Len(aRet) >= 5 .AND. aRet[5] > 0
				lRet := .T.
			Else
				cErro := "Erro no estorno do titulo"
			EndIf

		EndIf

	EndIf

	FreeObj(oVirtusFin)
	oVirtusFin := Nil

Return lRet

/*/{Protheus.doc} ValidaTit
Validações para realizar estorno correto do título
@type function
@version 12.1.27
@author nata.queiroz
@since 01/07/2021
@param cCodFil, character, cCodFil
@param cPrefixo, character, cPrefixo
@param cNum, character, cNum
@param cParcela, character, cParcela
@param cTipo, character, cTipo
@param cCodCli, character, cCodCli
@param cLoja, character, cLoja
@param cErro, character, cErro
@return logical, lRet
/*/
Static Function ValidaTit(cCodFil, cPrefixo, cNum, cParcela, cTipo, cCodCli, cLoja, cErro)
	Local lRet := .T.

	Default cCodFil := ""
	Default cPrefixo := ""
	Default cNum := ""
	Default cParcela := ""
	Default cTipo := ""
	Default cCodCli := ""
	Default cLoja := ""

	// Verifica se título foi baixado em lote conjunto
	lRet := TitMDMLote(cCodFil, cPrefixo, cNum, cParcela, cTipo, @cErro)

	If lRet
		// Verifica se título está conciliado
		lRet := TitConcil(cCodFil, cPrefixo, cNum, cParcela, cTipo, cCodCli, cLoja, @cErro)
	EndIf

Return lRet

/*/{Protheus.doc} TitMDMLote
Verifica se título foi baixado em lote conjunto
@type function
@version 12.1.27
@author nata.queiroz
@since 01/07/2021
@param cCodFil, character, cCodFil
@param cPrefixo, character, cPrefixo
@param cNum, character, cNum
@param cParcela, character, cParcela
@param cTipo, character, cTipo
@param cErro, character, cErro
@return logical, lRet
/*/
Static Function TitMDMLote(cCodFil, cPrefixo, cNum, cParcela, cTipo, cErro)
	Local lRet := .T.
	Local cLote := ""
	Local cQry := ""
	Local nQtdReg := 0

	Default cCodFil := ""
	Default cPrefixo := ""
	Default cNum := ""
	Default cParcela := ""
	Default cTipo := ""

	// Verifica lote da baixa do título
	cQry := "SELECT MDM_LOTE LOTE "
	cQry += "FROM " + RetSqlName("MDM")
	cQry += "WHERE D_E_L_E_T_ <> '*' "
	cQry += "AND MDM_BXFILI = '"+ cCodFil +"' "
	cQry += "AND MDM_PREFIX = '"+ cPrefixo +"' "
	cQry += "AND MDM_NUM = '"+ cNum +"' "
	cQry += "AND MDM_PARCEL = '"+ cParcela +"' "
	cQry += "AND MDM_TIPO = '"+ cTipo +"' "
	cQry := ChangeQuery(cQry)

	If Select("TMPMDM1") > 0
		TMPMDM1->( DbCloseArea() )
	EndIf

	TcQuery cQry New Alias "TMPMDM1"

	If TMPMDM1->( !EOF() )
		cLote := AllTrim(TMPMDM1->LOTE)
	EndIf

	TMPMDM1->( DbCloseArea() )

	If !Empty(cLote)

		// Verifica se existe mais títulos no mesmo lote
		cQry := "SELECT MDM_LOTE LOTE "
		cQry += "FROM " + RetSqlName("MDM")
		cQry += "WHERE D_E_L_E_T_ <> '*' "
		cQry += "AND MDM_BXFILI = '"+ cCodFil +"' "
		cQry += "AND MDM_LOTE = '"+ cLote +"' "
		cQry := ChangeQuery(cQry)

		If Select("TMPMDM2") > 0
			TMPMDM2->( DbCloseArea() )
		EndIf

		MPSysOpenQuery(cQry, "TMPMDM2")

		If TMPMDM2->(!Eof())
			lRet := .F.
			cErro := "Titulo baixado em lote conjunto no loja"
		EndIf

		If Select("TMPMDM2") > 0
			TMPMDM2->( DbCloseArea() )
		EndIf

	EndIf

Return(lRet)

/*/{Protheus.doc} TitConcil
Verifica se título está conciliado
@type function
@version 12.1.27
@author nata.queiroz
@since 01/07/2021
@param cCodFil, character, cCodFil
@param cPrefixo, character, cPrefixo
@param cNum, character, cNum
@param cParcela, character, cParcela
@param cTipo, character, cTipo
@param cCodCli, character, cCodCli
@param cLoja, character, cLoja
@param cErro, character, cErro
@return logical, lRet
/*/
Static Function TitConcil(cCodFil, cPrefixo, cNum, cParcela, cTipo, cCodCli, cLoja, cErro)
	Local lRet := .T.
	Local cQry := ""
	Local nQtdReg := 0

	Default cCodFil := ""
	Default cPrefixo := ""
	Default cNum := ""
	Default cParcela := ""
	Default cTipo := ""
	Default cCodCli := ""
	Default cLoja := ""

	cQry := "SELECT SE5.E5_PREFIXO PREFIXO, "
	cQry += "	SE5.E5_NUMERO NUMERO, "
	cQry += "	SE5.E5_PARCELA PARCELA, "
	cQry += "	SE5.E5_TIPO TIPO, "
	cQry += "	SE5.E5_RECONC RECONC "
	cQry += "FROM "+ RetSqlName("SE1") +" SE1 "
	cQry += "INNER JOIN "+ RetSqlName("SE5") +" SE5 "
	cQry += "	ON SE5.D_E_L_E_T_ <> '*' "
	cQry += "	AND SE5.E5_FILIAL = SE1.E1_FILIAL "
	cQry += "	AND SE5.E5_PREFIXO = SE1.E1_PREFIXO "
	cQry += "	AND SE5.E5_NUMERO = SE1.E1_NUM "
	cQry += "	AND SE5.E5_PARCELA = SE1.E1_PARCELA "
	cQry += "	AND SE5.E5_TIPO = SE1.E1_TIPO "
	cQry += "	AND SE5.E5_CLIENTE = SE1.E1_CLIENTE "
	cQry += "	AND SE5.E5_LOJA = SE1.E1_LOJA "
	cQry += "	AND SE5.E5_RECONC = 'x' " // Titulo Conciliado
	cQry += "WHERE SE1.D_E_L_E_T_ <> '*' "
	cQry += "	AND SE1.E1_FILIAL = '"+ cCodFil +"' "
	cQry += "	AND SE1.E1_PREFIXO = '"+ cPrefixo +"' "
	cQry += "	AND SE1.E1_NUM = '"+ cNum +"' "
	cQry += "	AND SE1.E1_PARCELA = '"+ cParcela +"' "
	cQry += "	AND SE1.E1_TIPO = '"+ cTipo +"' "
	cQry += "	AND SE1.E1_CLIENTE = '"+ cCodCli +"' "
	cQry += "	AND SE1.E1_LOJA = '"+ cLoja +"' "
	cQry := ChangeQuery(cQry)

	If Select("TMPSE5") > 0
		TMPSE5->( DbCloseArea() )
	EndIf

	MPSysOpenQuery(cQry, "TMPSE5")

	If TMPSE5->(!Eof())
		lRet := .F.
		cErro := "Titulo esta conciliado no financeiro"
	EndIf

	If Select("TMPSE5") > 0
		TMPSE5->( DbCloseArea() )
	EndIf

Return(lRet)
