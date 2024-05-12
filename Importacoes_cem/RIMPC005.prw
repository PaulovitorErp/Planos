#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RIMPC005
Rotina de Processamento de Importacoes de Historico Transferencias Cemiterio
@type function
@version 1.0
@author nata.queiroz
@since 02/10/2020
@param aHistTransf, array
@param nHdlLog, numeric
@return lRet, logical
/*/
User Function RIMPC005(aHistTransf, nHdlLog)
	Local aArea 			:= GetArea()
	Local aAreaU00			:= U00->(GetArea())
	Local aAreaSB1			:= SB1->(GetArea())
	Local aLinhaCt			:= {}
	Local lRet				:= .F.
	Local nX				:= 0

	Local nPosLeg			:= 0
	Local nPosCodImp        := 0
	Local nPosServic        := 0
	Local nPosDestino		:= 0 

	Local cCodLeg			:= ""
	Local cCodImp			:= ""
	Local cCodServic        := ""
	Local cCodDestino		:= ""

	Local cErrorLog			:= ""

	BEGIN TRANSACTION

		For nX := 1 To Len(aHistTransf)

			aLinhaCt := aClone(aHistTransf[nX])

			nPosLeg := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "COD_ANT"})
			nPosCodImp := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "COD_IMP"})
			nPosServic := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_SERVDE"})
			nPosDestino	:= AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_CTRDES"})

			cCodLeg := AllTrim(aLinhaCt[nPosLeg,2])
			cCodImp := AllTrim(aLinhaCt[nPosCodImp,2])
			cCodServic := AllTrim(aLinhaCt[nPosServic,2])
			cCodDestino := AllTrim(aLinhaCt[nPosDestino,2])

			if !Empty(cCodLeg) .And. !Empty(cCodImp) .And. !Empty(cCodServic)

				U00->( DbOrderNickName("U00CODANT") ) //-- U00_FILIAL+U00_CODANT

				// Busca contrato
				if U00->( MsSeek( xFilial("U00") + cCodLeg) )

					SB1->( dbSetOrder(1) ) //-- B1_FILIAL+B1_COD
					If SB1->( MsSeek( xFilial("SB1") + cCodServic ) )

						//-- Inclui Historico de Transferencia de Enderecamento
						If IncHistTransf(@nHdlLog, @aLinhaCt, @cErrorLog, AllTrim(SB1->B1_XREQSER),cCodDestino)
							lRet := .T.
							fWrite(nHdlLog , "Historico de Transferencia Gravado com Sucesso!")
							fWrite(nHdlLog , CRLF )
						Else
							fWrite(nHdlLog , "Erro ao Realizar Gravação do Historico de Transferencia!")
							fWrite(nHdlLog , CRLF )

							//-- Encerra toda transação  --//
							//-- Ignora linhas seguintes --//
							DisarmTransaction()
							BREAK
						EndIf

					Else

						fWrite(nHdlLog , "Codigo do servico " + cCodServic + " nao encontrado!")
						fWrite(nHdlLog , CRLF )

					EndIf

				else

					fWrite(nHdlLog , "Contrato codigo legado " + cCodLeg + " nao encontrado!")
					fWrite(nHdlLog , CRLF )

				EndIf

			else

				If Empty(cCodLeg)
					fWrite(nHdlLog , "Codigo Legado nao preenchido,";
						+ " campo obrigatório para a importação!" )
					fWrite(nHdlLog , CRLF )
				ElseIf Empty(cCodImp)
					fWrite(nHdlLog , "Codigo Importação nao preenchido,";
						+ " campo obrigatório para a importação!" )
					fWrite(nHdlLog , CRLF )
				Else
					fWrite(nHdlLog , "Codigo do Serviço Destino nao preenchido,";
						+ " campo obrigatório para a importação!" )
					fWrite(nHdlLog , CRLF )
				EndIf

			endif

		Next nX

	END TRANSACTION

	RestArea(aArea)
	RestArea(aAreaU00)
	RestArea(aAreaSB1)

Return lRet

/*/{Protheus.doc} IncHistTransf
Inclui Historico de Transferencia de Enderecamento
@type function
@version 1.0
@author nata.queiroz
@since 05/10/2020
@param nHdlLog, numeric
@param aLinhaCt, array
@param cErrorLog, character
@param cTipoEnd, character
@return lRet, logical
/*/
Static Function IncHistTransf(nHdlLog, aLinhaCt, cErrorLog, cTipoEnd,cCodDestino)
	Local lRet := .T.

	lRet := ValCposObg(@nHdlLog, @aLinhaCt, @cErrorLog, cTipoEnd)
	If lRet
		lRet := IncTransf(@nHdlLog, @aLinhaCt, @cErrorLog, cTipoEnd,cCodDestino)
		If lRet
			//-- Posicionado no registro U38 --//
			lRet := IncHistoric(@nHdlLog, @aLinhaCt, @cErrorLog)
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} IncTransf
Inclui Dados da Transferencia
@type function
@version 1.0
@author nata.queiroz
@since 05/10/2020
@param nHdlLog, numeric
@param aLinhaCt, array
@param cErrorLog, character
@return lRet, logical
/*/
Static Function IncTransf(nHdlLog, aLinhaCt, cErrorLog, cTipoEnd,cCodDestino)

	Local cCodU38       := ""
	Local cTabPad       := SuperGetMv("MV_XTABPAD",,"001")
	Local cCodAptServic := ""

	Local lRet          := .T.
	Local nPosTpTran    := 0
	Local nPosObs       := 0
	Local nPosData      := 0
	Local nPosAutori    := 0
	Local nPosQueMut    := 0
	Local nPosServic	:= 0

	//-- Origem
	Local nPosQuadra    := 0
	Local nPosModulo    := 0
	Local nPosJazigo    := 0
	Local nPosGaveta    := 0
	Local nPosOssari    := 0
	Local nPosNchOss    := 0
	Local nPosDtServ    := 0
	Local nPosDtUtil    := 0
	Local nPosPrzExu    := 0
	Local nPosLacOss    := 0

	//-- Destino
	Local nPosQdDest    := 0
	Local nPosMdDest    := 0
	Local nPosJzDest    := 0
	Local nPosGvDest    := 0
	Local nPosCrDest    := 0
	Local nPosNcDest    := 0
	Local nPosOsDest    := 0
	Local nPosNoDest    := 0

	Default nHdlLog     := 0
	Default aLinhaCt    := {}
	Default cErrorLog   := ""
	Default cTipoEnd    := ""

	nPosCodImp := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "COD_IMP"})
	nPosTpTran := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_TPTRAN"})
	nPosObs    := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_OBSERV"})
	nPosData   := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_DATA"})
	nPosAutori := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_AUTORI"})
	nPosQueMut := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_QUEMUT"})
	nPosServic := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_SERVDE"})

	//-- Origem
	nPosQuadra := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_QUADRA"})
	nPosModulo := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_MODULO"})
	nPosJazigo := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_JAZIGO"})
	nPosGaveta := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_GAVETA"})
	nPosOssari := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_OSSARI"})
	nPosNchOss := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_NICHOO"})
	nPosLacOri := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_LACORI"})
	nPosDtServ := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_DTSERV"})
	nPosDtUtil := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_DTUTIL"})
	nPosPrzExu := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_PRZEXU"})

	//-- Destino
	nPosQdDest := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_QDDEST"})
	nPosMdDest := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_MDDEST"})
	nPosJzDest := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_JZDEST"})
	nPosGvDest := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_GVDEST"})
	nPosCrDest := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_CRDEST"})
	nPosNcDest := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_NCDEST"})
	nPosOsDest := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_OSDEST"})
	nPosNoDest := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_NODEST"})
	nPosLacDst := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_LACDST"})

	//-- Avalia se dados já foram registrados --//
	U38->( dbSetOrder(2) ) //-- U38_FILIAL+U38_CODANT
	If U38->( MsSeek(xFilial("U38") + aLinhaCt[nPosCodImp, 2]) )
		lRet := .F.
		fWrite(nHdlLog , "Dados da transferencia já importados!")
		fWrite(nHdlLog , CRLF )
	EndIf

	If lRet

		if !Empty(cCodDestino)
			cCodDestino := CodDestinoProtheus(cCodDestino)
		else
			cCodDestino := U00->U00_CODIGO
		endif
		
		if Empty(cCodDestino)

			lRet := .F.
			fWrite(nHdlLog , "Contrato de Destino nao informado ou nao encontrado na base do sistema!")
			fWrite(nHdlLog , CRLF )
		
		endif

		if lRet

			cCodU38 := GetSxeNum("U38", "U38_CODIGO")

			//-- Grava Apontamento --//
			If RecLock("U38", .T.)
				U38->U38_FILIAL := xFilial("U38")
				U38->U38_CODIGO := cCodU38
				U38->U38_CODANT := aLinhaCt[nPosCodImp, 2]

				if nPosData > 0
					U38->U38_DATA   := aLinhaCt[nPosData, 2]
				endIf

				U38->U38_USER   := __cUserID
				U38->U38_NOMUSR := cUserName
				U38->U38_FILORI := cFilAnt
				U38->U38_CTRORI := U00->U00_CODIGO

				if nPosServic > 0
					U38->U38_SERVDE	:= aLinhaCt[nPosServic, 2]
				endIf

				If nPosAutori > 0
					U38->U38_AUTORI := aLinhaCt[nPosAutori, 2]
				EndIf

				U38->U38_TPTRAN := aLinhaCt[nPosTpTran, 2]
				U38->U38_FILDES := cFilAnt
				U38->U38_CTRDES := cCodDestino
				U38->U38_ITEMEN := "001"

				If nPosObs > 0
					U38->U38_OBSERV := aLinhaCt[nPosObs, 2]
				EndIf

				If nPosQueMut > 0
					U38->U38_QUEMUT := aLinhaCt[nPosQueMut, 2]
				EndIf

				if nPosQuadra > 0
					U38->U38_QUADRA := aLinhaCt[nPosQuadra, 2]
					U38->U38_MODULO := aLinhaCt[nPosModulo, 2]
					U38->U38_JAZIGO := aLinhaCt[nPosJazigo, 2]
					U38->U38_GAVETA := aLinhaCt[nPosGaveta, 2]
				endIf

				if nPosOssari > 0
					U38->U38_OSSARI := aLinhaCt[nPosOssari, 2]
					U38->U38_NICHOO := aLinhaCt[nPosNchOss, 2]

					if nPosLacOri > 0
						U38->U38_LACORI := aLinhaCt[nPosLacOri,2]
					endIf
				endIf

				If nPosDtServ > 0
					U38->U38_DTSERV := aLinhaCt[nPosDtServ, 2]
				EndIf

				If nPosDtUtil
					U38->U38_DTUTIL := aLinhaCt[nPosDtUtil, 2]
				EndIf

				If nPosPrzExu > 0
					U38->U38_PRZEXU := aLinhaCt[nPosPrzExu, 2]
				EndIf

				If Upper(aLinhaCt[nPosTpTran, 2]) == "I" //-- I=Interno; E=Externa
					if nPosQdDest > 0
						U38->U38_QDDEST := aLinhaCt[nPosQdDest, 2]
						U38->U38_MDDEST := aLinhaCt[nPosMdDest, 2]
						U38->U38_JZDEST := aLinhaCt[nPosJzDest, 2]
						U38->U38_GVDEST := aLinhaCt[nPosGvDest, 2]
					endIf

					if nPosCrDest > 0
						U38->U38_CRDEST := aLinhaCt[nPosCrDest, 2]
						U38->U38_NCDEST := aLinhaCt[nPosNcDest, 2]
					endIf

					if nPosOsDest > 0
						U38->U38_OSDEST := aLinhaCt[nPosOsDest, 2]
						U38->U38_NODEST := aLinhaCt[nPosNoDest, 2]

						if nPosLacDst > 0
							U38->U38_LACDST := aLinhaCt[nPosLacDst, 2]
						endIf
					endIf
				EndIf

				U38->(MsUnlock())
				U38->(ConfirmSX8())

				//====================================================================
				// crio o apontamento de servico para a transfrencia de enderecamento
				//====================================================================
				cCodAptServic	:= GetSXENum("UJV","UJV_CODIGO")

				if UJV->(Reclock("UJV", .T.))

					// vou gerar o apontamento de servicos
					UJV->UJV_FILIAL	:= xFilial("UJV")
					UJV->UJV_CODIGO	:= cCodAptServic
					UJV->UJV_CONTRA	:= U38->U38_CTRORI
					UJV->UJV_SERVIC	:= U38->U38_SERVDE

					// pego os dados do contrato
					U00->(DbSetOrder(1))
					if U00->(MsSeek( xFilial("U00")+U38->U38_CTRORI ))
						UJV->UJV_CODCLI	:= U00->U00_CLIENT
						UJV->UJV_LOJCLI := U00->U00_LOJA
					endIf

					UJV->UJV_AUTORI	:= U38->U38_AUTORI
					UJV->UJV_USRATE	:= cUserName
					UJV->UJV_DATA	:= U38->U38_DATA
					UJV->UJV_HORA	:= StrTran(SubStr(Time(),1,5),":","")
					UJV->UJV_DTSEPU	:= U38->U38_DTSERV
					UJV->UJV_HORASE	:= StrTran(SubStr(Time(),1,5),":","")
					UJV->UJV_TABPRC	:= cTabPad
					UJV->UJV_NOME	:= U38->U38_QUEMUT
					UJV->UJV_OBS	:= U38->U38_OBSERV

					if cTipoEnd == "J"// Jazigo
						UJV->UJV_QUADRA := U38->U38_QDDEST	 // quadra destino
						UJV->UJV_MODULO := U38->U38_MDDEST 	 // modulo destino
						UJV->UJV_JAZIGO := U38->U38_JZDEST	 // jazigo destino
						UJV->UJV_GAVETA := U38->U38_GVDEST	 // gaveta destino

					elseIf cTipoEnd == "C"// Crematorio
						UJV->UJV_CREMAT := U38->U38_CRDEST	 // crematorio destino
						UJV->UJV_NICHOC := U38->U38_NCDEST	 // nicho crematorio destino

					elseIf cTipoEnd == "O"// Ossario
						UJV->UJV_OSSARI := U38->U38_OSDEST	 // ossario destino
						UJV->UJV_NICHOO := U38->U38_NODEST	 // nicho ossario destino

						// verifico se o campo lacre existe
						if UJV->(FieldPos("UJV_LACOSS")) > 0 .And. U38->(FieldPos("U38_LACDST")) > 0
							UJV->UJV_LACOSS := U38->U38_LACDST
						endIf

					endIf

					UJV->UJV_STATUS := "F" //-- E=Em Execucao; F=Finalizado
					UJV->UJV_STENDE := "E" //-- X=Não Selecionado; R=Resevado; E=Efetivado

					UJV->UJV_ORIGEM := "RCPGA034"

					UJV->(MsUnlock())
					UJV->(ConfirmSX8())
				else
					lRet := .F.
					UJV->(DisarmTransaction())
				endIf

			Else
				U38->( RollBackSX8() )
				lRet := .F.
				fWrite(nHdlLog , "Erro ao gravar dados da transferencia!")
				fWrite(nHdlLog , CRLF )
			EndIf
		
		endif

	EndIf

Return lRet

/*/{Protheus.doc} CodDestinoProtheus
Busca codigo do contrato destino de acordo com o codigo informado no layout 
@type function
@version 1.0   
@author raphaelgarcia
@since 11/9/2023
@param cCodLegado, character, codigo do contrato no legado
@return charactere, codigo do contrato no protheus
/*/
Static Function CodDestinoProtheus(cCodLegado)

Local aAreaU00 			:= U00->(GetArea())
Local cCodigoProtheus	:= ""

U00->( DbOrderNickName("U00CODANT") ) //-- U00_FILIAL+U00_CODANT

if U00->(MsSeek( xFilial("U00") +  cCodLegado ))

	cCodigoProtheus := U00->U00_CODIGO

endif

RestArea(aAreaU00)

Return(cCodigoProtheus)

/*/{Protheus.doc} IncHistoric
Inclui Historico da Transferencia
@type function
@version 1.0
@author nata.queiroz
@since 05/10/2020
@param nHdlLog, numeric
@param aLinhaCt, array
@param cErrorLog, character
@return lRet, logical
/*/
Static Function IncHistoric(nHdlLog, aLinhaCt, cErrorLog)
	Local lRet := .T.
	Local cProxItemU30 := ""

	cProxItemU30 := MaxItemU30(U38->U38_CTRORI)

	If RecLock("U30", .T.)
		U30->U30_FILIAL := xFilial("U30")
		U30->U30_CODIGO := U38->U38_CTRORI
		U30->U30_ITEM   := cProxItemU30
		U30->U30_QUADRA := U38->U38_QUADRA
		U30->U30_MODULO := U38->U38_MODULO
		U30->U30_JAZIGO := U38->U38_JAZIGO
		U30->U30_GAVETA := U38->U38_GAVETA
		U30->U30_CREMAT := Space(1)
		U30->U30_NICHOC := Space(1)
		U30->U30_OSSARI := U38->U38_OSSARI
		U30->U30_NICHOO := U38->U38_NICHOO
		U30->U30_DTUTIL := U38->U38_DTUTIL
		U30->U30_QUEMUT := U38->U38_QUEMUT
		U30->U30_TRANSF := "S" //-- Transferencia
		U30->U30_DTHIST := dDataBase
		U30->U30_APONTA := Space(1)
		U30->( MsUnlock() )
	Else
		lRet := .F.
		fWrite(nHdlLog , "Erro ao gravar historico da transferencia!")
		fWrite(nHdlLog , CRLF )
	EndIf

Return lRet

/*/{Protheus.doc} MaxItemU30
Funcao para consultar Proximo item
que sera gerado no historico da gaveta
@author Raphael Martins
@since 17/05/2018
@version 1.0
@param cContrato, character
@return cProxItem, character
/*/
Static Function MaxItemU30(cContrato)
	Local cQry      := ""
	Local cProxItem := ""

	cQry := " SELECT "
	cQry += " ISNULL(MAX(U30_ITEM),'00') MAX_ITEM "
	cQry += " FROM " + RetSQLName("U30") + " HIST "
	cQry += " WHERE "
	cQry += " HIST.D_E_L_E_T_ = ' ' "
	cQry += " AND U30_FILIAL = '"+xFilial("U30")+"' "
	cQry += " AND U30_CODIGO = '" + cContrato + "' "
	cQry := ChangeQuery(cQry)

	If Select("QRYU30") > 0
		QRYU30->(DbCloseArea())
	EndIf

	TcQuery cQry New Alias "QRYU30"

	cProxItem := StrZero(Val(QRYU30->MAX_ITEM) + 1, TamSX3("U30_ITEM")[1])

	QRYU30->(DbCloseArea())

Return cProxItem

/*/{Protheus.doc} ValCposObg
Valida campos obrigatorios importacao
@type function
@version 1.0
@author nata.queiroz
@since 05/10/2020
@param nHdlLog, numeric
@param aLinhaCt, array
@param cErrorLog, character
@param cTipoEnd, character
@return lRet, logical
/*/
Static Function ValCposObg(nHdlLog, aLinhaCt, cErrorLog, cTipoEnd)
	Local lRet          := .T.

	Local nPosTpTran    := 0

	//-- Origem
	Local nPosQuadra    := 0
	Local nPosModulo    := 0
	Local nPosJazigo    := 0
	Local nPosGaveta    := 0
	Local nPosOssari    := 0
	Local nPosNchOss    := 0

	Default nHdlLog     := 0
	Default aLinhaCt    := {}
	Default cErrorLog   := ""
	Default cTipoEnd    := ""

	nPosTpTran := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_TPTRAN"})

	//-- Origem
	nPosQuadra := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_QUADRA"})
	nPosModulo := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_MODULO"})
	nPosJazigo := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_JAZIGO"})
	nPosGaveta := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_GAVETA"})
	nPosOssari := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_OSSARI"})
	nPosNchOss := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_NICHOO"})

	//-- Tipo Transferencia
	If nPosTpTran > 0
		If Empty( AllTrim(aLinhaCt[nPosTpTran,2]) )
			lRet := .F.
			fWrite(nHdlLog , "Tipo Transferencia nao preenchido,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf
	Else
		lRet := .F.
		fWrite(nHdlLog , "Layout de importação não possui campo Tp Transf,";
			+ " a definição do mesmo é obrigatória!" )
		fWrite(nHdlLog , CRLF )
	EndIf

	// tipo de jazigo
	if cTipoEnd == "J"

		//-- Quadra
		If nPosQuadra <= 0
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Quadra,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

		//-- Modulo
		If nPosModulo <= 0
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Modulo,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

		//-- Jazigo
		If nPosJazigo <= 0
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Jazigo,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

		//-- Gaveta
		If nPosGaveta <= 0
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Gaveta,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf
	endIf

	// tipo de servico em ossario
	if cTipoEnd == "O"

		//-- Ossario
		If nPosOssari <= 0
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Ossario,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

		//-- Nicho Ossario
		If nPosNchOss <= 0
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Nicho Ossario,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf
	endIf

	//-- Tipo de Transferencia
	If Upper(aLinhaCt[nPosTpTran, 2]) == "I" //-- I=Interno; E=Externa

		//-- Valida tipo de enderecamento
		lRet := ValTipoEnd(@nHdlLog, @aLinhaCt, cTipoEnd)

	EndIf

Return lRet

/*/{Protheus.doc} ValTipoEnd
Valida tipo de enderecamento
@type function
@version 1.0
@author nata.queiroz
@since 25/09/2020
@param nHdlLog, numeric
@param aLinhaCt, array
@param cTipoEnd, character
@return lRet, logical
/*/
Static Function ValTipoEnd(nHdlLog, aLinhaCt, cTipoEnd)
	Local lRet := .T.

	Local nPosQuadra := 0
	Local nPosModulo := 0
	Local nPosJazigo := 0
	Local nPosGaveta := 0
	Local nPosCremat := 0
	Local nPosNchCre := 0
	Local nPosOssari := 0
	Local nPosNchOss := 0

	//-- Endereco Destino
	nPosQuadra := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_QDDEST"})
	nPosModulo := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_MDDEST"})
	nPosJazigo := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_JZDEST"})
	nPosGaveta := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_GVDEST"})
	nPosCremat := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_CRDEST"})
	nPosNchCre := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_NCDEST"})
	nPosOssari := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_OSDEST"})
	nPosNchOss := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "U38_NODEST"})

	//-- Jazigo | Endereçamento Prévio --//
	If cTipoEnd == "J"

		//-- Quadra
		If nPosQuadra > 0
			If Empty( AllTrim(aLinhaCt[nPosQuadra,2]) )
				lRet := .F.
				fWrite(nHdlLog , "Codigo da Quadra Dest nao preenchido,";
					+ " a definição do mesmo é obrigatória!" )
				fWrite(nHdlLog , CRLF )
			EndIf
		Else
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Quadra Dest,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

		//-- Modulo
		If nPosModulo > 0
			If Empty( AllTrim(aLinhaCt[nPosModulo,2]) )
				lRet := .F.
				fWrite(nHdlLog , "Codigo do Modulo Dest nao preenchido,";
					+ " a definição do mesmo é obrigatória!" )
				fWrite(nHdlLog , CRLF )
			EndIf
		Else
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Modulo Dest,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

		//-- Jazigo
		If nPosJazigo > 0
			If Empty( AllTrim(aLinhaCt[nPosJazigo,2]) )
				lRet := .F.
				fWrite(nHdlLog , "Codigo do Jazigo Dest nao preenchido,";
					+ " a definição do mesmo é obrigatória!" )
				fWrite(nHdlLog , CRLF )
			EndIf
		Else
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Jazigo Dest,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

		//-- Gaveta
		If nPosGaveta > 0
			If Empty( AllTrim(aLinhaCt[nPosGaveta,2]) )
				lRet := .F.
				fWrite(nHdlLog , "Codigo da Gaveta Dest nao preenchido,";
					+ " a definição do mesmo é obrigatória!" )
				fWrite(nHdlLog , CRLF )
			EndIf
		Else
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Gaveta Dest,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

	ElseIf cTipoEnd == "C" // Crematorio

		//-- Crematorio
		If nPosCremat > 0
			If Empty( AllTrim(aLinhaCt[nPosCremat,2]) )
				lRet := .F.
				fWrite(nHdlLog , "Codigo do Crematorio Dest nao preenchido,";
					+ " a definição do mesmo é obrigatória!" )
				fWrite(nHdlLog , CRLF )
			EndIf
		Else
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Crematorio Dest,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

		//-- Nicho Columbario
		If nPosNchCre > 0
			If Empty( AllTrim(aLinhaCt[nPosNchCre,2]) )
				lRet := .F.
				fWrite(nHdlLog , "Nicho Columbario Dest nao preenchido,";
					+ " a definição do mesmo é obrigatória!" )
				fWrite(nHdlLog , CRLF )
			EndIf
		Else
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Nicho Columb Dest,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

	ElseIf cTipoEnd == "O" // Ossuario

		//-- Ossario
		If nPosOssari > 0
			If Empty( AllTrim(aLinhaCt[nPosOssari,2]) )
				lRet := .F.
				fWrite(nHdlLog , "Codigo do Ossario Dest nao preenchido,";
					+ " a definição do mesmo é obrigatória!" )
				fWrite(nHdlLog , CRLF )
			EndIf
		Else
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Ossario Dest,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

		//-- Nicho Ossario
		If nPosNchOss > 0
			If Empty( AllTrim(aLinhaCt[nPosNchOss,2]) )
				lRet := .F.
				fWrite(nHdlLog , "Nicho Ossario Dest nao preenchido,";
					+ " a definição do mesmo é obrigatória!" )
				fWrite(nHdlLog , CRLF )
			EndIf
		Else
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo N. Ossario Dest,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

	EndIf

Return lRet
