#Include "protheus.CH"
#include "topconn.ch"

/*/{Protheus.doc} RIMPC001
Rotina de Processamento de Importacoes de Contrato Cemiterio
@type function
@version 1.0
@author nata.queiroz
@since 28/02/2020
@param aContratos, array, Contratos
@param nHdlLog, numeric
@return lRet, logic
/*/
User Function RIMPC001(aContratos, nHdlLog)
	Local aArea 			:= GetArea()
	Local aAreaU00			:= U00->(GetArea())
	Local aLinhaCt			:= {}
	Local lRet				:= .F.
	Local nX				:= 0

	Local nPosCGCCli		:= 0
	Local nPosLeg			:= 0
	Local nPosVend			:= 0
	Local nPosData          := 0

	Local cCpfCnpj			:= ""
	Local cCodLeg			:= ""
	Local cVendLeg			:= ""
	Local cErrLog			:= ""
	Local cPulaLinha		:= Chr(13) + Chr(10)
	Local dDtEmis           := STOD(Space(8))
	Local dDataBkp			:= dDatabase

	// variavel interna da rotina automatica
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.

	For nX := 1 To Len(aContratos)

		Begin Transaction

			U00->( DbOrderNickName("U00CODANT") ) //-- U00_FILIAL+U00_CODANT

			aLinhaCt := aClone(aContratos[nX])

			nPosCGCCli := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "CGC"})
			nPosLeg := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U00_CODANT"})
			nPosVend := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U00_VENDED"})
			nPosData := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U00_DATA"})

			//importo apenas contratos com codigo legado
			if nPosLeg > 0

				cCodLeg := AllTrim(aLinhaCt[nPosLeg,2])

				if nPosCGCCli > 0
					cCpfCnpj := AllTrim(aLinhaCt[nPosCGCCli,2])
				else
					fWrite(nHdlLog , "Contrato sem CPF/CNPJ do cliente preenchido, campo obrigatório para a importação!" )
					fWrite(nHdlLog , cPulaLinha )
				endIf

				if nPosVend > 0
					cVendLeg := DeParaVend(aLinhaCt[nPosVend,2])
				else
					fWrite(nHdlLog , "Contrato sem Vendedor preenchido, campo obrigatório para a importação!" )
					fWrite(nHdlLog , cPulaLinha )
				endIf

				if nPosData > 0

					dDtEmis := aLinhaCt[nPosData,2]

				else

					dDtEmis := dDatabase

					fWrite(nHdlLog , "Campo U00_DATA não informado, utilizando a database " + DToC(dDatabase) + "!" )
					fWrite(nHdlLog , cPulaLinha )
				endIf

				//-- Altera data base para data de emissao do contrato --//
				dDatabase := dDtEmis

				if !Empty(cCodLeg)

					SA1->( DbSetOrder(3) ) //A1_FILIAL + A1_CGC

					if SA1->( MsSeek( xFilial("SA1") + cCpfCnpj) )

						//verifico se possui encontrou o vendedor
						if !Empty(cVendLeg)

							//altero para o vendedor do Protheus
							aLinhaCt[nPosVend,2] := cVendLeg

							//verifico se o contrato ja esta cadastrado sistema
							if !U00->( MsSeek( xFilial("U00") + cCodLeg) )

								DbSelectArea("U00")
								U00->( DbSetOrder(1) ) //-- U00_FILIAL + U00_CODIGO

								//preenchimento atraves dos campos chaves do layout
								aAdd( aLinhaCt, {"U00_CLIENT"      , SA1->A1_COD 	} )
								aAdd( aLinhaCt, {"U00_LOJA"        , SA1->A1_LOJA 	} )

								//-- Inclusao do contrato cemiterio
								If !U_RCPGE004(aLinhaCt,,, 3,,, @cErrLog)

									//verifico se arquivo de log existe
									if nHdlLog > 0

										fWrite(nHdlLog , "Erro na Inclusao do Contrato Cemiterio:" )

										fWrite(nHdlLog , cPulaLinha )

										fWrite(nHdlLog , cErrLog )

										fWrite(nHdlLog , cPulaLinha )

										cErrLog := ""

									endif

									DisarmTransaction()
									U00->( RollBackSX8() )

								else

									//verifico se arquivo de log existe
									if nHdlLog > 0

										fWrite(nHdlLog , "Contrato Cemiterio Cadastrado com sucesso!" )

										fWrite(nHdlLog , cPulaLinha )

										fWrite(nHdlLog , "Codigo: " + Alltrim(U00->U00_CODIGO) )

										fWrite(nHdlLog , cPulaLinha )

										lRet := .T.

									endif

									U00->( ConfirmSX8() )

								endif

							else

								//verifico se arquivo de log existe
								if nHdlLog > 0

									fWrite(nHdlLog , "Contrato Cemiterio: " + Alltrim(cCodLeg) + " já cadastrado na base de dados! " )

									fWrite(nHdlLog , cPulaLinha )

								endif

							endif

						else

							//verifico se arquivo de log existe
							if nHdlLog > 0

								fWrite(nHdlLog , "Vendedor do Contrato nao encontrado! " )

								fWrite(nHdlLog , cPulaLinha )

							endif


						endif

					else

						//verifico se arquivo de log existe
						if nHdlLog > 0

							fWrite(nHdlLog , "Cpf/Cnpj: " + Alltrim(cCpfCnpj) + " não cadastrado na base de dados! " )

							fWrite(nHdlLog , cPulaLinha )

						endif


					endif

				else

					fWrite(nHdlLog , "Contrato sem Codigo Legado preenchido, campo obrigatório para a importação!" )

					fWrite(nHdlLog , cPulaLinha )

				endif

			else

				fWrite(nHdlLog , "Layout de importação não possui campo Cod Legado, a definição do mesmo é obrigatória!" )

				fWrite(nHdlLog , cPulaLinha )


			endif

		End Transaction

	Next nX

	//restauro bkp da database do sistema
	dDatabase := dDataBkp

	RestArea(aArea)
	RestArea(aAreaU00)

Return lRet

/*/{Protheus.doc} DeParaVend
Retorna o Vendedor do Protheus de Acordo com o Legado
@type function
@version 1.0
@author nata.queiroz
@since 28/02/2020
@param cVendLeg, character
@return cVendProtheus, character
/*/
Static Function DeParaVend(cVendLeg)
	Local aArea			:= GetArea()
	Local aAreaSA3		:= SA3->(GetArea())
	Local cVendProtheus	:= cVendLeg


	SA3->(DbOrderNickName("XCODANT")) //A3_FILIAL+A3_CODANT

	if SA3->(DbSeek(xFilial("SA3")+Alltrim(cVendLeg)))

		cVendProtheus := SA3->A3_COD

    else

        cVendProtheus := cVendLeg

	endif

	RestArea(aArea)
	RestArea(aAreaSA3)

Return(cVendProtheus)
