#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} RREPUF7
description
@type function
@version 1.0
@author g.sampaio
@since 23/06/2021
@return return_type, return_description
/*/
User Function RREPUF7()

	Local aArea := GetArea()

	AjustaSX1("RREPUF7")

	if Pergunte("RREPUF7", .T.)
		MsAguarde( {|| Reproc()}, "Aguarde", "Processando registros...", .F. )
	endIf

	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} Reproc
description
@type function
@version  
@author g.sampaio
@since 23/06/2021
@return return_type, return_description
/*/
Static Function Reproc()

	Local aArea 		:= GetArea()
	Local cQuery 		:= ""
	Local cForPg		:= ""
	Local cDeContrato	:= ""
	Local cAteContrato	:= ""
	Local dDtProc		:= Stod("")
	Local nProcess 		:= 0

	dDtProc 		:= MV_PAR01
	cForPg			:= MV_PAR02
	cDeContrato		:= MV_PAR03
	cAteContrato	:= MV_PAR04

	if !Empty(dDtProc)

		if Select("TMPDUP") > 0
			TMPDUP->(DBCloseArea())
		endIf

		cQuery := " SELECT UF7_CONTRA, COUNT(*) FROM " + RetSQLName("UF7") + " UF7 WHERE UF7.D_E_L_E_T_ = ' '
		cQuery += " AND UF7.UF7_HISALT <> ' '
		cQuery += " AND UF7.UF7_DATA = '" + Dtos(dDtProc) + "'"

		if !Empty(cForPg)
			cQuery += " AND EXISTS (SELECT * FROM " + RetSQLName("UF2") + " UF2 WHERE UF2.D_E_L_E_T_ = ' ' AND UF2.UF2_CODIGO = UF7.UF7_CONTRA AND UF2.UF2_FORPG = '" + cForPg + "')
		endIf

		if !Empty(cAteContrato)
			cQuery += " AND UF7.UF7_CONTRA BETWEEN '" + cDeContrato + "' AND '" + cAteContrato + "' "
		endIf

		cQuery += " GROUP BY UF7_CONTRA
		cQuery += " HAVING COUNT(*) > 1
		cQuery += " ORDER BY UF7_CONTRA"

		// executo a query e crio o alias temporario
		MPSysOpenQuery( cQuery, 'TMPDUP' )

		while TMPDUP->(!Eof())

			if ExcReajDup(TMPDUP->UF7_CONTRA)
				nProcess++
			endIf

			TMPDUP->(DbSkip())
		endDo	

		if nProcess > 0
			MsgInfo("Processamento concluído com " + cValToChar(nProcess) + " registros processados!" )
		else
			MsgAlert("Não houveram registro processados!")
		endIf

		if Select("TMPDUP") > 0
			TMPDUP->(DBCloseArea())
		endIf

	else
		MsgAlert("Não é possível reprocessar sem informa a data do Reajuste!")
	endIf

	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} ExcReajDup
description
@type function
@version 1.0  
@author g.sampaio
@since 23/06/2021
@param cCodContrato, character, param_description
@return return_type, return_description
/*/
Static Function ExcReajDup(cCodContrato)

	Local aArea         := GetArea()
	Local aAreaUF7      := UF7->(GetArea())
	Local cQuery        := ""
	Local oModel        := FWLoadModel("RFUNA011")
	Local lRetorno      := .F.
	Local lActivate		:= .F.
	Local lCommit		:= .F.

	if Select("TMPUF7") > 0
		TMPUF7->(DBCloseArea())
	endIf

	cQuery := " SELECT MAX(UF7_CODIGO) CODIGO FROM " + RetSQLName("UF7") + " UF7 WHERE UF7.D_E_L_E_T_ = ' '
	cQuery += " AND UF7.UF7_HISALT <> ' '
	cQuery += " AND UF7.UF7_CONTRA = '" + cCodContrato + "'"

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TMPUF7' )

	while TMPUF7->(!Eof())

		if ValHistorico(cCodContrato)

			BEGIN TRANSACTION

				UF7->(DbSetOrder(1)) // UF7_FILIAL + UF7_CODIGO
				if UF7->(MsSeek(xFilial("UF7") + TMPUF7->CODIGO))

					lActivate 	:= .F.
					lCommit		:= .F.

					// seto a operação de exclusão
					oModel:SetOperation(5)

					// ativo o modelo
					lActivate := oModel:Activate()

					// se o modelo foi ativado com sucesso
					if lActivate

						// comito a operação
						lCommit := oModel:CommitData()

						if lCommit
							lRetorno := .T.
						endIf

						// desativo o modelo
						oModel:DeActivate()

					else

						if !MsgYesNo("Ocorreu um erro na exclusão do reajuste referente ao contrato " + AllTrim(UF7->UF7_CONTRA) + "." + "Deseja continuar?","Atenção!")

							// aborto a transação
							DisarmTransaction()

						endif

					endif

				endif

			END TRANSACTION

		endIf

		TMPUF7->(DbSkip())
	endDo

	if Select("TMPUF7") > 0
		TMPUF7->(DBCloseArea())
	endIf

	RestArea(aAreaUF7)
	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} ValHistorico
description
@type function
@version 1.0
@author g.sampaio
@since 23/06/2021
@param cCodContrato, character, param_description
@return return_type, return_description
/*/
Static Function ValHistorico(cCodContrato)

	Local aArea 	:= GetArea()
	Local cQuery    := ""
	Local lRetorno  := .F.

	if Select("TMPHIST") > 0
		TMPHIST->(DBCloseArea())
	endIf

	cQuery := " SELECT MAX(U68.U68_CODIGO) CODIGO FROM " + RetSQLName("U68") + " U68 WHERE U68.D_E_L_E_T_ = ' '
	cQuery += " AND U68.U68_FILIAL = '" + xFilial("U68") + "' "
	cQuery += " AND U68.U68_CONTRA = '" + cCodContrato + "' "

	// executo a query e crio o alias temporario
	MPSysOpenQuery( cQuery, 'TMPHIST' )

	if TMPHIST->(!Eof())

		U68->(DBSetOrder(1))
		If U68->(MsSeek(xFilial("U68")+TMPHIST->CODIGO))

			if U68->U68_TIPO == "R"
				lRetorno := .T.
			endIf

		endIf

	endIf

	if Select("TMPHIST") > 0
		TMPHIST->(DBCloseArea())
	endIf

	RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} AjustaSX1
Função que cria as perguntas na SX1.	
@type function
@version 1.0  
@author Wellington Gonçalves
@since 24/02/2016
@param cPerg, character, Grupo de Perguntas
/*/
Static Function AjustaSX1(cPerg)

	Local aRegs			  := {}

	Default cPerg	:= ""

	// verifico se o nome do grupo de pergunta foi passado
	if !Empty(cPerg)

		// parametros SX1
		aAdd(aRegs,{cPerg,'01','Data de Reajuste'        	,'','','mv_ch1','D', 8    							, 0, 0,'G','','mv_par01','','','','','',''})
		aAdd(aRegs,{cPerg,'02','Forma de Pag.'           	,'','','mv_ch2','C', TamSx3("UF2_FORPG")[1]    		, 0, 0,'G','','mv_par02','','','','','','24'})
		aAdd(aRegs,{cPerg,'03','De Contrato'           		,'','','mv_ch3','C', TamSx3("UF2_CODIGO")[1]    	, 0, 0,'G','','mv_par03','','','','','','UF2'})
		aAdd(aRegs,{cPerg,'04','Ate Contrato'           	,'','','mv_ch4','C', TamSx3("UF2_CODIGO")[1]    	, 0, 0,'G','','mv_par04','','','','','','UF2'})

		// cria os dados da SX1
		U_CriaSX1( aRegs )

	endIf

Return(Nil)
