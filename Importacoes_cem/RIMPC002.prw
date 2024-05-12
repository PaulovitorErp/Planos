#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} RIMPC002
Rotina de Processamento de Importacoes de Autorizados do Contrato
@type function
@version 1.0
@author nata.queiroz
@since 03/03/2020
@param aAutCtr, array
@param nHdlLog, numeric
@return lRet, logic
/*/
User Function RIMPC002(aAutCtr, nHdlLog)
	Local aArea         	:= GetArea()
	Local aAreaU02      	:= U02->( GetArea() )
	Local aAreaU00      	:= U00->( GetArea() )
	Local aItensAut			:= {}
	Local aAutorizados      := {}
	Local aLinhaCtr     	:= {}
	Local aCabCtr       	:= {}
	Local lRet				:= .F.
	Local nX				:= 0
	Local nY				:= 0

	Local nPosCod   		:= 0
	Local nPosAut       	:= 0
	Local nPosGrau			:= 0

	Local cCodCtr   		:= ""
	Local cNmAutoriz   		:= ""
	Local cErrLog			:= ""
	Local cPulaLinha		:= Chr(13) + Chr(10)
	Local cGrauParent       := ""

	//-- Variavel interna da rotina automatica
	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .F.

	Default aAutCtr  		:= {}
	Default nHdlLog 		:= 0

	For nX := 1 To Len(aAutCtr)

		BEGIN TRANSACTION

			U02->( dbSetOrder(1) ) //-- U02_FILIAL+U02_CODIGO+U02_ITEM

			aLinhaCtr	:= aClone(aAutCtr[nX])

			nPosCod     := AScan(aLinhaCtr,{|x| AllTrim(x[1]) == "COD_ANT"})
			nPosAut     := AScan(aLinhaCtr,{|x| AllTrim(x[1]) == "U02_NOME"})
			nPosGrau	:= AScan(aLinhaCtr,{|x| AllTrim(x[1]) == "U02_GRAUPA"})

			//-- Importo apenas contrato com codigo anterior e nome do autorizado preenchido --//
			If nPosCod > 0 .And. nPosAut > 0

				//-- Codigo do contrato a ser importado
				cCodAnt	:= AllTrim(aLinhaCtr[nPosCod,2])

				//-- Item a ser importado
				cNmAutoriz := AllTrim(aLinhaCtr[nPosAut,2])

				//-- Grau de parentesco do autorizado se existir
				If nPosGrau > 0
					cGrauParent := Alltrim(aLinhaCtr[nPosGrau,2])
				EndIf

				If !Empty(cCodAnt) .And. !Empty(cNmAutoriz)

					U00->( DbOrderNickName("U00CODANT") ) //-- U00_FILIAL+U00_CODANT

					If U00->( MsSeek( xFilial("U00") + Alltrim(cCodAnt) ) )

						//-- Codigo do contrato do protheus
						cCodCtr := U00->U00_CODIGO
						aAdd(aCabCtr, {"U00_CODIGO", cCodCtr} )	//-- Codigo do Contrato

						//-- Verifico se no contrato ja existe o autorizado
						If !ExistAut(cCodCtr, cNmAutoriz, cGrauParent)

							DbSelectArea("U02")
							U02->( dbSetOrder(1) ) //U02_FILIAL+U02_CODIGO+U02_ITEM

							//-- Codigo do item
							aAdd(aItensAut, {"U02_ITEM", ProxItem(cCodCtr) })

							For nY := 1 To Len(aLinhaCtr)

								//-- Codigo anterior pula para o proximo
								If AllTrim(aLinhaCtr[nY, 1]) == "COD_ANT"
									Loop
								EndIf

								aAdd(aItensAut, {Alltrim(aLinhaCtr[nY,1]),	aLinhaCtr[nY,2]} )

							Next nY

							If Len(aItensAut) > 0
								aAdd(aAutorizados, aItensAut)
							EndIf

							If Len(aAutorizados) > 0

								//-- Inclusao dos Autorizados --//
								If !U_RCPGE004(aCabCtr, aAutorizados,, 4,,, @cErrLog)

									//-- Verifico se arquivo de log existe
									If nHdlLog > 0

										fWrite(nHdlLog , "Erro na Inclusao do Autorizado no Contrato:")

										fWrite(nHdlLog , cPulaLinha )

										fWrite(nHdlLog , cErrLog )

										fWrite(nHdlLog , cPulaLinha )

										cErrLog := ""

									EndIf

									DisarmTransaction()

								Else

									//-- Verifico se arquivo de log existe
									If nHdlLog > 0

										fWrite(nHdlLog , "Autorizado Cadastrado com sucesso no Contrato!")

										fWrite(nHdlLog , cPulaLinha )

										fWrite(nHdlLog , "Contrato do Autorizado: " + cCodAnt;
											+ " - Nome : " + cNmAutoriz )

										fWrite(nHdlLog , cPulaLinha )

										lRet := .T.

									EndIf

								EndIf

							EndIf

						Else

							//-- Verifico se arquivo de log existe
							If nHdlLog > 0

								fWrite(nHdlLog , "Nome do Autorizado: ";
									+ AllTrim(cNmAutoriz) + " já cadastrado na base de dados";
									+ " para Contrato " + cCodAnt)

								fWrite(nHdlLog , cPulaLinha )

							EndIf

						EndIf

					Else

						//-- Verifico se arquivo de log existe
						If nHdlLog > 0

							fWrite(nHdlLog , "Contrato: ";
								+ AllTrim(cCodAnt) + " não encontrado no sistema!")

							fWrite(nHdlLog , cPulaLinha )

						EndIf

					EndIf
				Else

					fWrite(nHdlLog , "Nome do autorizado ou ";
						+ "codigo anterior do contrato não preenchidos,";
						+ " campo obrigatório para a importação!")

					fWrite(nHdlLog , cPulaLinha )

				EndIf

			Else

				fWrite(nHdlLog , "Layout de importação não possui campo Codigo Anterior,";
					+ " a definição do mesmo é obrigatória!")

				fWrite(nHdlLog , cPulaLinha )

			EndIf

		END TRANSACTION

		//-- Limpa dados para proxima linha --//
		aCabCtr := {}
		aItensAut := {}
		aAutorizados := {}

	Next nX

	RestArea(aAreaU00)
	RestArea(aAreaU02)
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} ExistAut
Verifica se existe nome do autorizado cadastrado
@type function
@version 1.0
@author nata.queiroz
@since 03/03/2020
@param cCodCtr, character
@param cNmAutoriz, character
@param cGrauParent, character
@return lRet, logic
/*/
Static Function ExistAut(cCodCtr, cNmAutoriz, cGrauParent)
	Local aArea         := GetArea()
	Local lRet          := .F.
	Local cQry          := ""
	Local nQtdReg       := 0

	Default cCodCtr     := ""
	Default cNmAutoriz  := ""
	Default cGrauParent := ""

	cQry := "SELECT U02_CODIGO "
	cQry += "FROM " + RetSqlName("U02")
	cQry += "WHERE D_E_L_E_T_ <> '*' "
	cQry += "AND U02_FILIAL = '"+ xFilial("U02") +"' "
	cQry += "AND U02_CODIGO = '"+ AllTrim(cCodCtr) +"' "

	//-- RTRIM/LTRIM usado devido compatibilidade SQL Server abaixo do 2017 --//
	cQry += "AND RTRIM(LTRIM(U02_NOME)) = '"+ AllTrim(cNmAutoriz) +"' "

	If !Empty(cGrauParent)
		cQry += "AND U02_GRAUPA = '"+ cGrauParent +"' "
	EndIf

	cQry += "ORDER BY U02_CODIGO, U02_NOME "
	cQry := ChangeQuery(cQry)

	If Select("TRBU02") > 0
		TRBU02->( dbCloseArea() )
	EndIf

	MPSysOpenQuery(cQry, "TRBU02")

	//-- Existe registros na tabela --//
	If TRBU02->(!Eof())
		lRet := .T.
	EndIf

	If Select("TRBU02") > 0
		TRBU02->( dbCloseArea() )
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} ProxItem
Retorna proximo item para cadastro de autorizados do contrato
@type function
@version 1.0
@author nata.queiroz
@since 03/03/2020
@param cCodCtr, character
@return cProxItm, character
/*/
Static Function ProxItem(cCodCtr)
	Local aArea     := GetArea()
	Local cProxItm  := "01"
	Local cQry      := ""	

	Default cCodCtr := ""

	cQry := "SELECT MAX(U02_ITEM) MAXITEM "
	cQry += "FROM " + RetSqlName("U02")
	cQry += "WHERE D_E_L_E_T_ <> '*' "
	cQry += "AND U02_FILIAL = '"+ xFilial("U02") +"' "
	cQry += "AND U02_CODIGO = '"+ AllTrim(cCodCtr) +"' "
	
    cQry := ChangeQuery(cQry)

	If Select("TRBU02") > 0
		TRBU02->( dbCloseArea() )
	EndIf
	
    MPSysOpenQuery(cQry, "TRBU02")

	//-- Existe registros na tabela --//
	If TRBU02->(!Eof())
		cProxItm := Soma1(TRBU02->MAXITEM)
	EndIf

	If Select("TRBU02") > 0
		TRBU02->( dbCloseArea() )
	EndIf

	RestArea(aArea)

Return cProxItm
