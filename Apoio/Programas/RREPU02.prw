#include "totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} RREPU02
Funcao para reprocessar os autorizados
@type function
@version 1.0
@author g.sampaio
@since 29/05/2021
/*/
User Function RREPU02()

	Local lEnd		:= .F.
	Local oProcess	:= Nil

	oProcess := MsNewProcess():New( { | lEnd | ProcU02( @lEnd, @oProcess ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
	oProcess:Activate()

Return(Nil)

/*/{Protheus.doc} ProcU02
Funcao para processamento da U02
@type function
@version 1.0  
@author g.sampaio
@since 29/05/2021
/*/
Static Function ProcU02(lEnd, oProcess)

	Local cQuery 	:= ""
	Local nProccess := 0

	if Select("TRBU02") > 0
		TRBU02->(DBCloseArea())
	endIf

	cQuery := " SELECT "
	cQuery += " U02A.U02_CODIGO CONTRATO, "
	cQuery += " U02A.U02_ITEM	ITEM, "
	cQuery += " U02A.U02_CODCLI	CLIENTE, "
	cQuery += " U02A.U02_LOJCLI	LOJA, "
	cQuery += " U02A.U02_NOME	NOME, "
	cQuery += " A1_CGC			CPF,"
	cQuery += " A1_COD			CODCLI,"
	cQuery += " A1_LOJA			LOJCLI,"
	cQuery += " A1_NOME			NOMECLI"
	cQuery += " FROM " + RetSQLName("U02") + " U02A"
	cQuery += " INNER JOIN " + RetSQLName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = ' '"
	cQuery += " AND SA1.A1_CGC = U02A.U02_CPF"
	cQuery += " AND SA1.A1_XCEMAUT <> '2' "
	cQuery += " WHERE U02A.D_E_L_E_T_  = ' '"
	cQuery += " AND U02A.U02_CPF <> ' '"
	cQuery += " AND U02A.U02_CODCLI = ' '"
	cQuery += " AND NOT EXISTS ( SELECT U00.U00_CGC FROM " + RetSQLName("U00") + " U00 WHERE U00.D_E_L_E_T_ = ' ' AND U00.U00_CGC = U02A.U02_CPF )"
	cQuery += " UNION"
	cQuery += " SELECT"
	cQuery += " U00.U00_CODIGO	CONTRATO,"
	cQuery += " '' 				ITEM,"
	cQuery += " U00.U00_CLIENT 	CLIENTE,"
	cQuery += " U00.U00_LOJA	LOJA,"
	cQuery += " U00.U00_NOMCLI	NOME,"
	cQuery += " SA1.A1_CGC		CPF,"
	cQuery += " SA1.A1_COD		CODCLI,"
	cQuery += " SA1.A1_LOJA		LOJCLI,"
	cQuery += " SA1.A1_NOME 	NOMECLI "
	cQuery += " FROM " + RetSQLName("U00") + " U00
	cQuery += " INNER JOIN " + RetSQLName("SA1") + " SA1 ON SA1.D_E_L_E_T_ = ' '"
	cQuery += " AND SA1.A1_CGC = U00.U00_CGC"
	cQuery += " AND SA1.A1_XCEMAUT <> '2' "
	cQuery += " WHERE U00.D_E_L_E_T_  = ' '"
	cQuery += " AND U00.U00_CGC <> ' '"
	cQuery += " AND NOT EXISTS ( SELECT U02B.U02_CPF FROM " + RetSQLName("U02") + " U02B WHERE U02B.D_E_L_E_T_ = ' ' AND U02B.U02_CPF = U00.U00_CGC ) "
	cQuery += " ORDER BY CLIENTE, LOJA "

	TcQuery cQuery New Alias "TRBU02"

	// atualizo o objeto de processamento
	oProcess:IncRegua1('Reprocessando U02...')

	// atualizo o objeto de processamentp
	oProcess:SetRegua2(TRBU02->(Reccount()))

	TRBU02->(DbGoTop())

	while TRBU02->(!Eof())

		nProccess++

		// atualizo o objeto de processamento
		oProcess:IncRegua2("Atualizando Autorizado: " +  TRBU02->NOME )

		BEGIN TRANSACTION

			if !Empty(TRBU02->ITEM) .And. Empty(TRBU02->CLIENTE) .And. !Empty(TRBU02->CODCLI)

				U02->(DBSetOrder(1))
				if U02->(MsSeek(xFilial("U02")+TRBU02->CONTRATO+TRBU02->ITEM))
					if U02->(Reclock("U02", .F.))
						U02->U02_CODCLI := TRBU02->CODCLI
						U02->U02_LOJCLI	:= TRBU02->LOJCLI
						U02->(MsUnlock())
					else
						U02->(DisarmTransaction())
					endIf
				endIf

			else

				SA1->(DBSetOrder(1))
				if SA1->(MsSeek(xFilial("SA1")+TRBU02->CODCLI+TRBU02->LOJCLI))

					if U02->(RecLock("U02",.T.))
						U02->U02_FILIAL := xFilial("U02")
						U02->U02_CODIGO	:= TRBU02->CONTRATO
						U02->U02_ITEM 	:= ProxItemU02( TRBU02->CONTRATO )
						U02->U02_CODCLI	:= SA1->A1_COD
						U02->U02_LOJCLI	:= SA1->A1_LOJA
						U02->U02_NOME 	:= SA1->A1_NOME
						U02->U02_GRAUPA	:= "OU" // Outros
						U02->U02_CPF	:= SA1->A1_CGC
						U02->U02_CI		:= SA1->A1_PFISICA

						if !Empty(SA1->A1_XDTNASC)
							U02->U02_DTNASC	:= SA1->A1_XDTNASC
							U02->U02_IDADE	:= U_UAgeCalculate(SA1->A1_XDTNASC,dDataBase)
						EndIf

						U02->U02_SEXO 	:= SA1->A1_XSEXO
						U02->U02_ESTCIV	:= SA1->A1_XESTCIV
						U02->U02_END	:= SA1->A1_ENDCOB
						U02->U02_COMPLE	:= SA1->A1_COMPLEM
						U02->U02_BAIRRO	:= SA1->A1_BAIRROC
						U02->U02_CEP 	:= SA1->A1_CEP
						U02->U02_EST	:= SA1->A1_EST
						U02->U02_CODMUN	:= SA1->A1_CODMUN
						U02->U02_MUN 	:= SA1->A1_MUN
						U02->U02_DDD	:= SA1->A1_DDD
						U02->U02_FONE	:= SA1->A1_XTELCON
						U02->U02_CELULA := SA1->A1_XCEL
						U02->U02_EMAIL	:= SA1->A1_EMAIL
						U02->U02_STATUS	:= "2" // titular

						U02->(MsUnlock())
					else
						U02->(DisarmTransaction())
					endIf

				endIf

			endIf

		END TRANSACTION

		TRBU02->(DBSkip())
	endDo

	MsgInfo("Fim do Processamento! Itens processados " + cValToChar(nProccess))

	if Select("TRBU02") > 0
		TRBU02->(DBCloseArea())
	endIf

Return(Nil)

/*/{Protheus.doc} ProxItemU02
funcao para retornar o proximo item da U02
@type function
@version 1.0
@author g.sampaio
@since 16/12/2020
@param cCodContrato, character, codigo do contrato
@return character, retorna o proximo item do autorizado
/*/
Static Function ProxItemU02( cCodContrato )

	Local cQuery As Char

	// atribuo valor das variaveis
	cQuery := ""

	if Select("TRBITEM") > 0
		TRBITEM->(DbCloseArea())
	endIf

	cQuery := " SELECT MAX(U02_ITEM) MAXITEM FROM " + RetSqlName("U02") + " U02 "
	cQuery += " WHERE U02.D_E_L_E_T_ = ' '"
	cQuery += " AND U02.U02_FILIAL = '" + xFilial("U02") + "'"
	cQuery += " AND U02.U02_CODIGO = '" + cCodContrato + "' "

	TcQuery cQuery New Alias "TRBITEM"

	if TRBITEM->(!Eof())
		cRetorno	:= Soma1(AllTrim(TRBITEM->MAXITEM))
	endIf

	if Empty(cRetorno)
		cRetorno := StrZero(1,TamSX3("U02_ITEM")[1])
	endIf

	if Select("TRBITEM") > 0
		TRBITEM->(DbCloseArea())
	endIf

Return(cRetorno)
