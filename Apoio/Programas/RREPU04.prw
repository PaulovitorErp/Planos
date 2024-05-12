#include "totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} RREPU04
programas para processar as duplicidades
do campo U04_ITEM
@type function
@version 1.0
@author g.sampaio
@since 30/05/2021
/*/
User Function RREPU04()

	Local lEnd		:= .F.
	Local oProcess	:= Nil

	oProcess := MsNewProcess():New( { | lEnd | ProcU04( @lEnd, @oProcess ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
	oProcess:Activate()

Return(Nil)

/*/{Protheus.doc} ProcU04
Processamento dos registros duplicdados na U04
@type function
@version 1.0
@author g.sampaio
@since 30/05/2021
@param lEnd, logical, param_description
@param oProcess, object, param_description
/*/
Static Function ProcU04( lEnd, oProcess )

	Local cQuery    := ""
    Local nProccess := 0

	if Select("TRBU04") > 0
		TRBU04->(DBCloseArea())
	endIf

	cQuery  := " SELECT "
	cQuery  += "    COUNT(*) QUANTIDADE, "
	cQuery  += "    U04.U04_CODIGO CONTRATO, "
	cQuery  += "    U04.U04_QUADRA QUADRA, "
	cQuery  += "    U04.U04_MODULO MODULO, "
	cQuery  += "    U04.U04_JAZIGO JAZIGO "
	cQuery  += " FROM " + RetSQLName("U04") + " U04 "
	cQuery  += " WHERE D_E_L_E_T_ = ' ' "
	cQuery  += " GROUP BY U04.U04_ITEM, U04.U04_CODIGO, U04.U04_QUADRA, U04.U04_MODULO, U04.U04_JAZIGO "
	cQuery  += " HAVING COUNT(*) > 1 "

	TcQuery cQuery New Alias "TRBU04"

	// atualizo o objeto de processamento
	oProcess:IncRegua1('Reprocessando U02...')

	// atualizo o objeto de processamentp
	oProcess:SetRegua2(TRBU04->(Reccount()))

	TRBU04->(DbGoTop())

	While TRBU04->(!Eof())

		nProccess++

		// atualizo o objeto de processamento
		oProcess:IncRegua2("Atualizando Endereço do contrato: " +  TRBU04->CONTRATO )

		// reprocessa o endereco do contrato
		RepEndItem( lEnd, oProcess, TRBU04->CONTRATO, TRBU04->QUADRA, TRBU04->MODULO, TRBU04->JAZIGO )

		TRBU04->(DBSkip())
	EndDo

	if Select("TRBU04") > 0
		TRBU04->(DBCloseArea())
	endIf

Return(Nil)

/*/{Protheus.doc} RepEndItem
description
@type function
@version 1.0  
@author g.sampaio
@since 30/05/2021
@param cContrato, character, param_description
@param cQuadra, character, param_description
@param cModulo, character, param_description
@param cJazigo, character, param_description
@return return_type, return_description
/*/
Static Function RepEndItem( lEnd, oProcess, cContrato, cQuadra, cModulo, cJazigo )

	Local cQuery := ""

	if Select("TRBITEM") > 0
		TRBITEM->(DBCloseArea())
	endIf

	cQuery  := " SELECT "
	cQuery  += "    R_E_C_N_O_ RECU04 "
	cQuery  += " FROM " + RetSQLName("U04") + " (NOLOCK) U04 "
	cQuery  += " WHERE D_E_L_E_T_ = ' ' "
	cQuery  += " AND U04.U04_CODIGO = '" + cContrato + "' "
	cQuery  += " AND U04.U04_QUADRA = '" + cQuadra + "' "
	cQuery  += " AND U04.U04_MODULO = '" + cModulo + "' "
	cQuery  += " AND U04.U04_JAZIGO = '" + cJazigo + "' "

	TcQuery cQuery New Alias "TRBITEM"

	while TRBITEM->(!Eof())

		U04->(DBGoTo(TRBITEM->RECU04))

		BEGIN TRANSACTION

			if U04->(Reclock("U04", .F.))
				U04->U04_ITEM := NextU04(U04->U04_CODIGO)
				U04->(MsUnlock())
			else
				U04->(DisarmTransaction())
			endIf

		END TRANSACTION

		TRBITEM->(DbSkip())
	endDo

	if Select("TRBITEM") > 0
		TRBITEM->(DBCloseArea())
	endIf

Return(Nil)

/*/{Protheus.doc} NextU04
Funcao para consultar Proximo item
que sera gerado no enderecamento
@author g.sampaio 
@since 24/01/2020
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function NextU04(cContrato)

	Local aArea			:= GetArea()
	Local aAreaU04		:= U04->(GetArea())
	Local cQry			:= ""
	Local cProxItem		:= ""
	Local nTamU04Item	:= TamSX3("U04_ITEM")[1]

	cQry := " SELECT
	cQry += " ISNULL(MAX(U04_ITEM),'" + cValToChar(nTamU04Item) + "') MAX_ITEM "
	cQry += " FROM "
	cQry += + RetSQLName("U04") + " (NOLOCK) HIST "
	cQry += " WHERE "
	cQry += " HIST.D_E_L_E_T_ = ' ' "
	cQry += " AND U04_FILIAL = '"+xFilial("U04")+"' "
	cQry += " AND U04_CODIGO = '" + cContrato + "' "

	// verifico se não existe este alias criado
	If Select("QRYU04") > 0
		QRYU04->(DbCloseArea())
	EndIf

	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)

	// crio o alias temporario
	TcQuery cQry New Alias "QRYU04"

	//proximo item da tabela de historico de enderecamento
	cProxItem := StrZero(Val(QRYU04->MAX_ITEM) + 1,TamSX3("U04_ITEM")[1])

	RestArea(aArea)
	RestArea(aAreaU04)

Return(cProxItem)
