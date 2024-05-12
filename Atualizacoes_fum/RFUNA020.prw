#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} RFUNA020
Rotina para exclusão de reajustes em lote da funerária
@type function
@version 1.0
@author Wellington Gonçalves
@since 07/10/2016
/*/
User Function RFUNA020()

	Local aArea			:= GetArea()
	Local cPerg 		:= "RFUNA020"
	Local dDataDe		:= CTOD("  /  /    ")
	Local dDataAte		:= CTOD("  /  /    ")
	Local cContratoDe	:= ""
	Local cContratoAte	:= ""
	Local cPlano		:= ""
	Local cIndice		:= ""
	Local lContinua		:= .T.

// cria as perguntas na SX1
	AjustaSx1(cPerg)

// enquanto o usuário não cancelar a tela de perguntas
	While lContinua

		// chama a tela de perguntas
		lContinua := Pergunte(cPerg,.T.)

		if lContinua

			dDataDe			:= MV_PAR01
			dDataAte		:= MV_PAR02
			cContratoDe 	:= MV_PAR03
			cContratoAte	:= MV_PAR04
			cPlano			:= MV_PAR05
			cIndice			:= MV_PAR06

			if MsgYesNo("Deseja realmente excluir os reajustes?")
				MsAguarde( {|| ExcluiReaj(dDataDe,dDataAte,cContratoDe,cContratoAte,cPlano,cIndice)}, "Aguarde", "Consultando os reajustes...", .F. )
			endif

		endif

	EndDo

	RestArea(aArea)

Return()

/*/{Protheus.doc} ExcluiReaj
Função que faz a exclusão dos reajustes em lote
@type function
@version 1.0
@author Wellington Gonçalves
@since 07/10/2016
@param dDataDe, date, param_description
@param dDataAte, date, param_description
@param cContratoDe, character, param_description
@param cContratoAte, character, param_description
@param cPlano, character, param_description
@param cIndice, character, param_description
@return variant, return_description
/*/
Static Function ExcluiReaj(dDataDe,dDataAte,cContratoDe,cContratoAte,cPlano,cIndice)

	Local cQry 		   	:= ""
	lOCAL cLogReajuste	:= ""
	Local cPulaLinha	:= chr(13)+chr(10)
	Local oModel 		:= Nil
	Local lContinua		:= .F.
	Local lOK			:= .T.
	Local lActivate		:= .F.
	Local lCommit		:= .F.

// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	cQry := " SELECT "                                                         					+ cPulaLinha
	cQry += " UF7.UF7_CODIGO, "                                                					+ cPulaLinha
	cQry += " UF7.UF7_DATA, "                                                  					+ cPulaLinha
	cQry += " UF7.UF7_CONTRA "                                                 					+ cPulaLinha
	cQry += " FROM "                                                           					+ cPulaLinha
	cQry += + RetSqlName("UF7") + " UF7 "                                      					+ cPulaLinha
	cQry += " INNER JOIN "                                                     					+ cPulaLinha
	cQry += 	+ RetSqlName("UF2") + " UF2 "                                  					+ cPulaLinha
	cQry += " 	ON UF2.D_E_L_E_T_ <> '*' "                                     					+ cPulaLinha
	cQry += " 	AND UF2.UF2_FILIAL = '" + xFilial("UF2") + "' "                					+ cPulaLinha
	cQry += " 	AND UF2.UF2_CODIGO = UF7.UF7_CONTRA "                          					+ cPulaLinha

	if !Empty(cPlano)
		cQry += " 	AND UF2.UF2_PLANO IN " + FormatIn( AllTrim(cPlano),";") 		 			+ cPulaLinha
	endif

	cQry += " AND UF2.UF2_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' "     + cPulaLinha
	cQry += " WHERE "                                                          					+ cPulaLinha
	cQry += " UF7.D_E_L_E_T_ <> '*' "                                          					+ cPulaLinha
	cQry += " AND UF7.UF7_FILIAL = '" + xFilial("UF7") + "' "                                   + cPulaLinha
	cQry += " AND UF7.UF7_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "   + cPulaLinha

	if !Empty(cIndice)
		cQry += " AND UF7.UF7_TPINDI = '" + cIndice + "' "                         				+ cPulaLinha
	endif

// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)

// crio o alias temporario
	TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query

// se existir contratos a serem reajustados
	if QRY->(!Eof())

		// Inicio o controle de transação
		BEGIN TRANSACTION

			While QRY->(!Eof())

				UF7->(DbSetOrder(1)) // UF7_FILIAL + UF7_CODIGO
				if UF7->(DbSeek(xFilial("UF7") + QRY->UF7_CODIGO))

					lActivate 	:= .F.
					lCommit		:= .F.
					oModel 		:= FWLoadModel("RFUNA011")

					// seto a operação de exclusão
					oModel:SetOperation(5)

					// ativo o modelo
					lActivate := oModel:Activate()

					// se o modelo foi ativado com sucesso
					if lActivate

						// comito a operação
						lCommit := oModel:CommitData()

						// desativo o modelo
						oModel:DeActivate()

					else

						if !lContinua .And. !MsgYesNo("Ocorreu um erro na exclusão do reajuste referente ao contrato " + AllTrim(UF7->UF7_CONTRA) + "." + cPulaLinha + "Deseja continuar?","Atenção!")

							cLogReajuste += "Ocorreu um erro na exclusão do reajuste referente ao contrato " + AllTrim(UF7->UF7_CONTRA) + "." + cPulaLinha

							// aborto a transação
							DisarmTransaction()

							lOK := .F.
							Exit

						Else
							lContinua 	 := .T.
							cLogReajuste += "Ocorreu um erro na exclusão do reajuste referente ao contrato " + AllTrim(UF7->UF7_CONTRA) + "." + cPulaLinha
						endif

					endif

					FreeObj(oModel)
					oModel := Nil

				endif

				QRY->(DbSkip())

			EndDo

			If !Empty(cLogReajuste)
				MemoWrite( GetTempPath() + "exclusaodoreajuste_" + CriaTrab(, .F.) + ".txt" ,cLogReajuste)
			EndIf

			// finalizo o controle de transação
		END TRANSACTION

	else
		MsgAlert("Não foram encontrados reajustes para o filtro informado!")
	endif

// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

Return(lOK)

/*/{Protheus.doc} AjustaSX1
Função que cria as perguntas na SX1.	
@type function
@version 1.0
@author Wellington Gonçalves
@since 24/02/2016
@param cPerg, character, param_description
@return variant, return_description
/*/
Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relatório

	Local aHelpPor	:= {}
	Local aHelpEng	:= {}
	Local aHelpSpa	:= {}

///////////// Data do reajuste ////////////////
	U_xPutSX1( cPerg, "01","Data do reajuste de?","Data do reajuste de?","Data do reajuste de?","dDataDe","D",8,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	U_xPutSX1( cPerg, "02","Data do reajuste ate?","Data do reajuste ate?","Data do reajuste ate?","dDataAte","D",8,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// Contrato ///////////////

	U_xPutSX1( cPerg, "03","Contrato De?","Contrato De?","Contrato De?","cContratoDe","C",6,0,0,"G","","UF2","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	U_xPutSX1( cPerg, "04","Contrato Ate?","Contrato Ate?","Contrato Ate?","cContratoAte","C",6,0,0,"G","","UF2","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

///////////// Plano /////////////////

	U_xPutSX1( cPerg, "05","Plano?","Plano?","Plano?","cPlano","C",99,0,0,"G","","UF0MRK","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// Índice ///////////////

	U_xPutSX1( cPerg, "06","Índice?","Índice?","Índice?","cIndice","C",3,0,0,"G","","U22","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return(Nil)
