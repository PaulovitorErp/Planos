#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RIMPC004
Rotina de Processamento de Importacoes de Enderecamento Cemiterio
@type function
@version 1.0
@author nata.queiroz
@since 24/09/2020
@param aEnderecos, array
@param nHdlLog, numeric
@return lRet, logical
/*/
User Function RIMPC004(aEnderecos, nHdlLog)
	Local aArea 			:= GetArea()
	Local aAreaU00			:= U00->(GetArea())
	Local aAreaSB1			:= SB1->(GetArea())
	Local aLinhaCt			:= {}
	Local lRet				:= .F.
	Local nX				:= 0

	Local nPosLeg			:= 0
	Local nPosServic        := 0
	Local nPosEndPrv        := 0
	Local nPosDtSepult      := 0

	Local cCodLeg			:= ""
	Local cCodServic        := ""
	Local cEndPrv           := ""
	Local cTipoEnd			:= "J"

	Local cErrorLog			:= ""

	BEGIN TRANSACTION

		For nX := 1 To Len(aEnderecos)

			aLinhaCt := aClone(aEnderecos[nX])

			nPosLeg := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "COD_ANT"})
			nPosServic := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_SERVIC"})
			nPosEndPrv := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "END_PREVIO"})
			nPosDtSepult := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_DTSEPU"})

			if ValCpos(@nHdlLog, nPosLeg, nPosServic, nPosEndPrv, nPosDtSepult)

				cCodLeg := AllTrim(aLinhaCt[nPosLeg,2])
				cCodServic := AllTrim(aLinhaCt[nPosServic,2])
				cEndPrv := AllTrim(aLinhaCt[nPosEndPrv,2])

				if !Empty(cCodLeg)

					U00->( DbOrderNickName("U00CODANT") ) //-- U00_FILIAL+U00_CODANT

					// Busca contrato
					if U00->( MsSeek( xFilial("U00") + cCodLeg) )

						//-- Endereçamento Prévio --//
						If !Empty(cEndPrv) .And. Upper(cEndPrv) == "S"

							nPosOssari := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_OSSARI"})

							if nPosOssari > 0 .And. !Empty(aLinhaCt[nPosOssari,2])
								cTipoEnd := "O"
							endif

							If ValTipoEnd(@nHdlLog, @aLinhaCt, cTipoEnd)

								If IncEnderec(@nHdlLog, @aLinhaCt, @cErrorLog, cTipoEnd, cEndPrv)
									lRet := .T.
									fWrite(nHdlLog , "Endereçamento realizado com sucesso!")
									fWrite(nHdlLog , CRLF )
								Else
									lRet := .F.
									fWrite(nHdlLog , "Erro ao realizar endereçamento!")
									fWrite(nHdlLog , CRLF )

									//-- Encerra toda transação  --//
									//-- Ignora linhas seguintes --//
									DisarmTransaction()
									BREAK
								EndIf

							EndIf

						Else

							//-- Apontamento Serviço/ Endereçamento --//
							If !Empty(cCodServic)

								SB1->( dbSetOrder(1) ) //-- B1_FILIAL+B1_COD
								If SB1->( MsSeek( xFilial("SB1") + cCodServic ) )

									If ValTipoEnd(@nHdlLog, @aLinhaCt, AllTrim(SB1->B1_XREQSER))

										//-- U00 e SB1 devem estar corretamente posicionados --//
										If IncEnderec(@nHdlLog, @aLinhaCt, @cErrorLog,;
												AllTrim(SB1->B1_XREQSER), cEndPrv, AllTrim(SB1->B1_XOCUGAV))

											lRet := .T.
											fWrite(nHdlLog , "Endereçamento realizado com sucesso!")
											fWrite(nHdlLog , CRLF )

										Else

											lRet := .F.
											fWrite(nHdlLog , "Erro ao realizar endereçamento!")
											fWrite(nHdlLog , CRLF )

											//-- Encerra toda transação  --//
											//-- Ignora linhas seguintes --//
											DisarmTransaction()
											BREAK

										EndIf

									EndIf

								Else
									lRet := .F.
									fWrite(nHdlLog , "Codigo do servico " + cCodServic + " nao encontrado!")
									fWrite(nHdlLog , CRLF )

								EndIf

							Else

								fWrite(nHdlLog , "Codigo do servico nao preenchido,";
									+ " campo obrigatório para a importação!" )
								fWrite(nHdlLog , CRLF )

							EndIf

						EndIf

					else

						fWrite(nHdlLog , "Contrato codigo legado " + cCodLeg + " nao encontrado!")
						fWrite(nHdlLog , CRLF )

					EndIf

				else

					fWrite(nHdlLog , "Codigo Legado nao preenchido,";
						+ " campo obrigatório para a importação!" )
					fWrite(nHdlLog , CRLF )

				endif

			endif

		Next nX

	END TRANSACTION

	RestArea(aArea)
	RestArea(aAreaU00)
	RestArea(aAreaSB1)

Return(lRet)

/*/{Protheus.doc} ValCpos
Valida se campos estao contido na estrutura de importacao
@type function
@version 1.0
@author nata.queiroz
@since 25/09/2020
@param nHdlLog, numeric
@param nPosLeg, numeric
@param nPosServic, numeric
@param nPosEndPrv, numeric
@param nPosDtSepult, numeric
@return lRet, logical
/*/
Static Function ValCpos(nHdlLog, nPosLeg, nPosServic, nPosEndPrv, nPosDtSepult)
	Local lRet := .T.

	If nPosLeg <= 0
		lRet := .F.
		fWrite(nHdlLog , "Layout de importação não possui campo Cod Legado,";
			+ " a definição do mesmo é obrigatória!" )
		fWrite(nHdlLog , CRLF )
	EndIf

	If nPosServic <= 0
		lRet := .F.
		fWrite(nHdlLog , "Layout de importação não possui campo Serviço,";
			+ " a definição do mesmo é obrigatória!" )
		fWrite(nHdlLog , CRLF )
	EndIf

	If nPosEndPrv <= 0
		lRet := .F.
		fWrite(nHdlLog , "Layout de importação não possui campo End Previo,";
			+ " a definição do mesmo é obrigatória!" )
		fWrite(nHdlLog , CRLF )
	EndIf

	If nPosDtSepult <= 0
		lRet := .F.
		fWrite(nHdlLog , "Layout de importação não possui campo Data Sepult.,";
			+ "a definição do mesmo é obrigatória!" )
		fWrite(nHdlLog , CRLF )
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

	nPosQuadra := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_QUADRA"})
	nPosModulo := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_MODULO"})
	nPosJazigo := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_JAZIGO"})
	nPosGaveta := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_GAVETA"})
	nPosCremat := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_CREMAT"})
	nPosNchCre := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_NICHOC"})
	nPosOssari := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_OSSARI"})
	nPosNchOss := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_NICHOO"})

	//-- Jazigo | Endereçamento Prévio --//
	If cTipoEnd == "J"

		//-- Quadra
		If nPosQuadra > 0
			If Empty( AllTrim(aLinhaCt[nPosQuadra,2]) )
				lRet := .F.
				fWrite(nHdlLog , "Codigo da Quadra nao preenchido,";
					+ " a definição do mesmo é obrigatória!" )
				fWrite(nHdlLog , CRLF )
			EndIf
		Else
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Quadra,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

		//-- Modulo
		If nPosModulo > 0
			If Empty( AllTrim(aLinhaCt[nPosModulo,2]) )
				lRet := .F.
				fWrite(nHdlLog , "Codigo do Modulo nao preenchido,";
					+ " a definição do mesmo é obrigatória!" )
				fWrite(nHdlLog , CRLF )
			EndIf
		Else
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Modulo,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

		//-- Jazigo
		If nPosJazigo > 0
			If Empty( AllTrim(aLinhaCt[nPosJazigo,2]) )
				lRet := .F.
				fWrite(nHdlLog , "Codigo do Jazigo nao preenchido,";
					+ " a definição do mesmo é obrigatória!" )
				fWrite(nHdlLog , CRLF )
			EndIf

			if lRet
				lRet := U_UVALCADEND(cTipoEnd, {aLinhaCt[nPosQuadra,2], aLinhaCt[nPosModulo,2], aLinhaCt[nPosJazigo,2]})
				if !lRet
					fWrite(nHdlLog , "Endereco de Jazigo nao cadastrado! ";
						+ " Quadra: " + aLinhaCt[nPosQuadra,2] + " - Modulo: " + aLinhaCt[nPosModulo,2];
						+ "- Jazigo: " + aLinhaCt[nPosJazigo,2])
					fWrite(nHdlLog , CRLF )
				endIf
			endIf
		Else
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Jazigo,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

		//-- Gaveta
		If nPosGaveta > 0
			If Empty( AllTrim(aLinhaCt[nPosGaveta,2]) )
				lRet := .F.
				fWrite(nHdlLog , "Codigo da Gaveta nao preenchido,";
					+ " a definição do mesmo é obrigatória!" )
				fWrite(nHdlLog , CRLF )
			EndIf
		Else
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Gaveta,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

	ElseIf cTipoEnd == "C" // Crematorio

		//-- Crematorio
		If nPosCremat > 0
			If Empty( AllTrim(aLinhaCt[nPosCremat,2]) )
				lRet := .F.
				fWrite(nHdlLog , "Codigo do Crematorio nao preenchido,";
					+ " a definição do mesmo é obrigatória!" )
				fWrite(nHdlLog , CRLF )
			EndIf
		Else
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Crematorio,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

		//-- Nicho Columbario
		If nPosNchCre > 0
			If Empty( AllTrim(aLinhaCt[nPosNchCre,2]) )
				lRet := .F.
				fWrite(nHdlLog , "Nicho Columbario nao preenchido,";
					+ " a definição do mesmo é obrigatória!" )
				fWrite(nHdlLog , CRLF )
			EndIf

			if lRet
				lRet := U_UVALCADEND(cTipoEnd, {aLinhaCt[nPosCremat,2], aLinhaCt[nPosNchCre,2]})
				if !lRet
					fWrite(nHdlLog , "Endereco de Crematorio nao cadastrado!";
						+ " Crematorio: " + aLinhaCt[nPosCremat,2] + " - Nicho: " + aLinhaCt[nPosNchCre,2])
					fWrite(nHdlLog , CRLF )
				endIf
			endIf
		Else
			lRet := .F.
			fWrite(nHdlLog , "Layout de importação não possui campo Nicho Columb,";
				+ " a definição do mesmo é obrigatória!" )
			fWrite(nHdlLog , CRLF )
		EndIf

	ElseIf cTipoEnd == "O" // Ossuario

		// verifico se nao e ossuario vinculado
		If nPosJazigo == 0

			//-- Ossario
			If nPosOssari > 0
				If Empty( AllTrim(aLinhaCt[nPosOssari,2]) )
					lRet := .F.
					fWrite(nHdlLog , "Codigo do Ossario nao preenchido,";
						+ " a definição do mesmo é obrigatória!" )
					fWrite(nHdlLog , CRLF )
				EndIf
			Else
				lRet := .F.
				fWrite(nHdlLog , "Layout de importação não possui campo Ossario,";
					+ " a definição do mesmo é obrigatória!" )
				fWrite(nHdlLog , CRLF )
			EndIf

			//-- Nicho Ossario
			If nPosNchOss > 0
				If Empty( AllTrim(aLinhaCt[nPosNchOss,2]) )
					lRet := .F.
					fWrite(nHdlLog , "Nicho Ossario nao preenchido,";
						+ " a definição do mesmo é obrigatória!" )
					fWrite(nHdlLog , CRLF )

					if lRet
						lRet := U_UVALCADEND(cTipoEnd, {aLinhaCt[nPosOssari,2], aLinhaCt[nPosNchOss,2]})
						if !lRet
							fWrite(nHdlLog , "Endereco de Ossario nao cadastrado! ";
								+ " Ossario: " + aLinhaCt[nPosOssari,2] + " - Nicho: " + aLinhaCt[nPosNchOss,2])
							fWrite(nHdlLog , CRLF )
						endIf
					endIf

				EndIf
			Else
				lRet := .F.
				fWrite(nHdlLog , "Layout de importação não possui campo N. Ossario,";
					+ " a definição do mesmo é obrigatória!" )
				fWrite(nHdlLog , CRLF )
			EndIf

		endIf

	EndIf

Return lRet

/*/{Protheus.doc} IncEnderec
Inclui enderecamento cemiterio
@type function
@version 1.0
@author nata.queiroz
@since 25/09/2020
@param nHdlLog, numeric
@param aLinhaCt, array
@param cErrorLog, character
@param cTipoEnd, character
@param cEndPrv, character
@return lRet, logical
/*/
Static Function IncEnderec(nHdlLog, aLinhaCt, cErrorLog, cTipoEnd, cEndPrv, cOcupaGaveta)

	Local aArea         := GetArea()
	Local aAreaUJV      := UJV->( GetArea() )
	Local aAreaU04      := U04->( GetArea() )
	Local cMsgRet		:= ""
	Local lRet          := .T.
	Local nPosQuadra 	:= 0
	Local nPosModulo 	:= 0
	Local nPosJazigo 	:= 0
	Local nPosGaveta 	:= 0
	Local nPosCremat 	:= 0
	Local nPosNchCre 	:= 0
	Local nPosOssari 	:= 0
	Local nPosNchOss 	:= 0

	Default nHdlLog         := 0
	Default aLinhaCt        := {}
	Default cErrorLog       := ""
	Default cTipoEnd        := ""
	Default cEndPrv         := ""
	Default cOcupaGaveta    := "S"

	nPosQuadra := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_QUADRA"})
	nPosModulo := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_MODULO"})
	nPosJazigo := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_JAZIGO"})
	nPosGaveta := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_GAVETA"})
	nPosCremat := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_CREMAT"})
	nPosNchCre := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_NICHOC"})
	nPosOssari := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_OSSARI"})
	nPosNchOss := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_NICHOO"})

	//-- Verifica se endereço já foi utilizado --//
	If EnderecUsado(@aLinhaCt, cTipoEnd, cEndPrv, cOcupaGaveta)
		lRet := .F.

		fWrite(nHdlLog , "Endereçamento já utilizado! Por favor verificar!")

		if cTipoEnd == "J" // jazigo

			if cOcupaGaveta == 'N'
				fWrite(nHdlLog , "Restos mortais com mesmo nome já importado, por favor verificar!")
			endif

			fWrite(nHdlLog , "Quadra:" + aLinhaCt[nPosQuadra, 2]  + " - Modulo:" +  aLinhaCt[nPosModulo, 2]  + " - Jazigo:" + aLinhaCt[nPosJazigo, 2]  + "!")

		elseIf cTipoEnd == "O" // ossuario
			if Len(aLinhaCt[nPosQuadra, 2]) = 0
				fWrite(nHdlLog , "Ossuario:" + aLinhaCt[nPosOssari, 2]  + " - Nicho Ossuario:" +  aLinhaCt[nPosNchOss, 2]  + " !")
			else
				fWrite(nHdlLog , "Ossuario Vinculado - Jazigo --> :" + aLinhaCt[nPosQuadra, 2]  + " !")
			endif

		elseIf cTipoEnd == "C" // crematorio
			fWrite(nHdlLog , "Crematorio:" + aLinhaCt[nPosCremat, 2]  + " - Nicho Crematorio:" +  aLinhaCt[nPosNchCre, 2]  + " !")
		endIf

		fWrite(nHdlLog , CRLF )
	EndIf

	If lRet

		BEGIN TRANSACTION

			If !Empty(cEndPrv) .And. Upper(cEndPrv) == "S"

				//-- Endereçamento Prévio --//
				lRet := EndPrevio(@nHdlLog, @aLinhaCt, @cErrorLog,cTipoEnd)

			Else

				//-- Apontamento de Serviço --//
				lRet := IncApontmt(@nHdlLog, @aLinhaCt, @cErrorLog)

				If lRet
					//-- Confirma Endereço --//
					//-- UJV (Apontamento) deve estar posicionado --//
					If !U_UConfEndereco(UJV->UJV_CODIGO, UJV->UJV_CONTRA, @cMsgRet)
						lRet := .F.
						fWrite(nHdlLog , "Erro ao confirmar endereçamento!")
						fWrite(nHdlLog , cMsgRet )
						fWrite(nHdlLog , CRLF )
					else
						lRet := .T.
						fWrite(nHdlLog , "Endereçamento feito com Sucesso!")
						fWrite(nHdlLog , cMsgRet)
						fWrite(nHdlLog , CRLF )
					EndIf
				EndIf

			EndIf

			if !lRet
				DisarmTransaction()
			endIf

		END TRANSACTION

	EndIf

	RestArea(aAreaUJV)
	RestArea(aAreaU04)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} IncApontmt
Inclui apontamento de serviço cemiterio
@type function
@version 1.0
@author nata.queiroz
@since 29/09/2020
@param nHdlLog, numeric
@param aLinhaCt, array
@param cErrorLog, character
@return lRet, logical
/*/
Static Function IncApontmt(nHdlLog, aLinhaCt, cErrorLog)
	Local lRet     		:= .T.
	Local cCodUJV  		:= ""
	Local cTipoEnd 		:= AllTrim(SB1->B1_XREQSER)
	Local cOssuVinc		:= ""
	Local cNichoVinc 	:= ""

	Local nPosCausa    := 0
	Local nPosNome     := 0
	Local nPosDtSepult := 0
	Local nPosHrSepult := 0
	Local nPosDtObt    := 0
	Local nPosDtCert   := 0
	Local nPosLocFal   := 0
	Local nPosDtNasc   := 0
	Local nPosSexo     := 0
	Local nPosEstCiv   := 0
	Local nPosUf       := 0
	Local nPosCodMun   := 0
	Local nPosMunicip  := 0
	Local nPosNacion   := 0
	Local nPosNoMae    := 0
	Local nPosFunera   := 0
	Local nPosRealiz   := 0
	Local nPosTpCrem   := 0

	Local nPosQuadra := 0
	Local nPosModulo := 0
	Local nPosJazigo := 0
	Local nPosGaveta := 0
	Local nPosCremat := 0
	Local nPosNchCre := 0
	Local nPosOssari := 0
	Local nPosNchOss := 0

	Local nTamGav	 := TamSX3("U04_GAVETA")[1]

	nPosCausa    := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_CAUSA"})
	nPosNome     := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_NOME"})
	nPosDtSepult := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_DTSEPU"})
	nPosHrSepult := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_HORASE"})
	nPosDtObt    := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_DTOBT"})
	nPosDtCert   := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_DTCERT"})
	nPosLocFal   := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_LOCFAL"})
	nPosDtNasc   := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_DTNASC"})
	nPosSexo     := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_SEXO"})
	nPosEstCiv   := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_ESTCIV"})
	nPosUf       := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_UF"})
	nPosCodMun   := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_CODMUN"})
	nPosMunicip  := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_MUN"})
	nPosNacion   := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_NACION"})
	nPosNoMae    := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_NOMAE"})
	nPosFunera   := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_FUNERA"})
	nPosRealiz   := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_REALIZ"})
	nPosTpCrem   := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_TPCREM"})

	nPosQuadra := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_QUADRA"})
	nPosModulo := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_MODULO"})
	nPosJazigo := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_JAZIGO"})
	nPosGaveta := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_GAVETA"})
	nPosCremat := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_CREMAT"})
	nPosNchCre := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_NICHOC"})
	nPosOssari := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_OSSARI"})
	nPosNchOss := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_NICHOO"})

	cCodUJV := GetSxeNum("UJV", "UJV_CODIGO")

	if Len(aLinhaCt) > 0

		//-- Grava Apontamento --//
		If RecLock("UJV", .T.)
			UJV->UJV_FILIAL := xFilial("UJV")
			UJV->UJV_CODIGO := cCodUJV
			UJV->UJV_CONTRA := U00->U00_CODIGO
			UJV->UJV_SERVIC := SB1->B1_COD
			UJV->UJV_USRATE := cUserName
			UJV->UJV_DATA   := aLinhaCt[nPosDtSepult, 2]
			UJV->UJV_HORA   := SubStr(Time(), 1, 5)

			If nPosDtObt > 0
				UJV->UJV_DTOBT  := aLinhaCt[nPosDtObt, 2]
			EndIf

			if nPosCausa > 0
				UJV->UJV_CAUSA  := aLinhaCt[nPosCausa, 2]
			endIf

			If nPosDtCert > 0
				UJV->UJV_DTCERT := aLinhaCt[nPosDtCert, 2]
			EndIf

			If nPosLocFal > 0
				UJV->UJV_LOCFAL := aLinhaCt[nPosLocFal, 2]
			EndIf

			if nPosNome > 0
				UJV->UJV_NOME   := aLinhaCt[nPosNome, 2]
			endIf

			UJV->UJV_TABPRC := U00->U00_TABPRE
			UJV->UJV_CLIENT := U00->U00_CLIENT
			UJV->UJV_LOJA   := U00->U00_LOJA

			If nPosDtNasc > 0
				UJV->UJV_DTNASC := aLinhaCt[nPosDtNasc, 2]
			EndIf

			If nPosSexo > 0
				UJV->UJV_SEXO := aLinhaCt[nPosSexo, 2]
			EndIf

			If nPosEstCiv > 0
				UJV->UJV_ESTCIV := aLinhaCt[nPosEstCiv, 2]
			EndIf

			If nPosUf > 0
				UJV->UJV_UF := aLinhaCt[nPosUf, 2]
			EndIf

			If nPosCodMun > 0
				UJV->UJV_CODMUN := aLinhaCt[nPosCodMun, 2]
			EndIf

			If nPosMunicip > 0
				UJV->UJV_MUN := aLinhaCt[nPosMunicip, 2]
			EndIf

			If nPosNoMae > 0
				UJV->UJV_NOMAE := aLinhaCt[nPosNoMae, 2]
			EndIf

			If nPosFunera > 0
				UJV->UJV_FUNERA := aLinhaCt[nPosFunera, 2]
			EndIf

			If cTipoEnd == "J" .And. nPosQuadra > 0 .And. nPosModulo > 0 .And. nPosJazigo > 0
				UJV->UJV_QUADRA := aLinhaCt[nPosQuadra, 2]
				UJV->UJV_MODULO := aLinhaCt[nPosModulo, 2]
				UJV->UJV_JAZIGO := aLinhaCt[nPosJazigo, 2]
				UJV->UJV_GAVETA := StrZero(Val(aLinhaCt[nPosGaveta, 2]), nTamGav)

			ElseIf cTipoEnd == "C" .And. nPosCremat > 0 .And. nPosNchCre > 0
				UJV->UJV_CREMAT := aLinhaCt[nPosCremat, 2]
				UJV->UJV_NICHOC := aLinhaCt[nPosNchCre, 2]

				If nPosRealiz > 0
					UJV->UJV_REALIZ := aLinhaCt[nPosRealiz, 2]
				EndIf

				If nPosTpCrem > 0
					UJV->UJV_TPCREM := aLinhaCt[nPosTpCrem, 2]
				EndIf

			ElseIf cTipoEnd == "O"

				if nPosQuadra > 0 .And. nPosOssari == 0 // para importar ossuario vinculado

					// importar ossuario vinculado
					ImpVincOssuario( aLinhaCt[nPosQuadra, 2], aLinhaCt[nPosModulo, 2], aLinhaCt[nPosJazigo, 2], @cOssuVinc, @cNichoVinc )

					if !Empty(cOssuVinc) .And. !Empty(cNichoVinc)

						UJV->UJV_QUADRA := aLinhaCt[nPosQuadra, 2]
						UJV->UJV_MODULO := aLinhaCt[nPosModulo, 2]
						UJV->UJV_JAZIGO := aLinhaCt[nPosJazigo, 2]
						UJV->UJV_GAVETA := StrZero(Val(aLinhaCt[nPosGaveta, 2]), nTamGav)
						UJV->UJV_OSSARI := cOssuVinc
						UJV->UJV_NICHOO := cNichoVinc
					else
						lRet := .F.
						fWrite(nHdlLog , "Endereco não possui ossuario vinculado " + aLinhaCt[nPosQuadra, 2] + " " + aLinhaCt[nPosModulo, 2] + " " + aLinhaCt[nPosJazigo, 2] + " " )
						fWrite(nHdlLog , CRLF )
					endIf

				elseIf nPosQuadra > 0 .And. nPosOssari > 0 // para importar ossuario vinculado

					UJV->UJV_QUADRA := aLinhaCt[nPosQuadra, 2]
					UJV->UJV_MODULO := aLinhaCt[nPosModulo, 2]
					UJV->UJV_JAZIGO := aLinhaCt[nPosJazigo, 2]
					UJV->UJV_GAVETA := StrZero(Val(aLinhaCt[nPosGaveta, 2]), nTamGav)

					UJV->UJV_OSSARI := aLinhaCt[nPosOssari, 2]
					UJV->UJV_NICHOO := aLinhaCt[nPosNchOss, 2]
				else

					UJV->UJV_OSSARI := aLinhaCt[nPosOssari, 2]
					UJV->UJV_NICHOO := aLinhaCt[nPosNchOss, 2]

				endIf
			EndIf

			if lRet

				UJV->UJV_NACION := "1"
				UJV->UJV_DESNAT := "BRASILEIRA"

				If nPosNacion > 0
					If !Empty(aLinhaCt[nPosNacion, 2])
						UJV->UJV_NACION := aLinhaCt[nPosNacion, 2]
						UJV->UJV_DESNAT := IIF(aLinhaCt[nPosNacion, 2] == "1", "BRASILEIRA", "ESTRANGEIRA")
					EndIf
				EndIf

				if nPosDtSepult
					UJV->UJV_DTSEPU := aLinhaCt[nPosDtSepult, 2]
				endIf

				If nPosHrSepult > 0
					UJV->UJV_HORASE := aLinhaCt[nPosHrSepult, 2]
				EndIf

				UJV->UJV_STATUS := "F" //-- E=Em Execucao; F=Finalizado
				UJV->UJV_STENDE := "R" //-- X=Não Selecionado; R=Resevado; E=Efetivado

				lRet := .T.
			endIf

			UJV->( MsUnlock() )
			UJV->( ConfirmSX8() )
		Else
			UJV->( RollBackSX8() )
			lRet := .F.
			fWrite(nHdlLog , "Erro ao gravar apontamento de serviço!")
			fWrite(nHdlLog , CRLF )
		EndIf

		if !lRet
			UJV->(DisarmTransaction())
		endIf

	else
		fWrite(nHdlLog , "Não foi possível realizar a inclusão do apontamento !")
		fWrite(nHdlLog , CRLF )
		lRet := .F.
	endIf


Return(lRet)

/*/{Protheus.doc} EndPrevio
Realiza enderecamento previo cemiterio
@type function
@version 1.0
@author nata.queiroz
@since 29/09/2020
@param nHdlLog, numeric, log do historico de importacao
@param aLinhaCt, array, linha de importacao
@param cErrorLog, character, errorlog
@param cTipoEnd, character, tipo de enderecamento
@return logical, retorno logico
/*/
Static Function EndPrevio(nHdlLog, aLinhaCt, cErrorLog, cTipoEnd)

	Local aArea 		:= GetArea()
	Local aAreaU04		:= U04->(GetArea())
	Local lRet  		:= .T.
	Local nPosQuadra 	:= 0
	Local nPosModulo 	:= 0
	Local nPosJazigo 	:= 0
	Local nPosOssario	:= 0 
	Local nPosNichoO	:= 0

	// posicao dos campos
	nPosQuadra 	:= AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_QUADRA"})
	nPosModulo 	:= AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_MODULO"})
	nPosJazigo 	:= AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_JAZIGO"})
	nPosOssario := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_OSSARI"})
	nPosNichoO	:= AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_NICHOO"})

	// posicao da quadra, modulo e jazigo
	If nPosQuadra > 0 .And. nPosModulo > 0 .And. nPosJazigo > 0

		BEGIN TRANSACTION

			If U04->(RecLock("U04", .T.))
				U04->U04_FILIAL := xFilial("U04")
				U04->U04_CODIGO	:= U00->U00_CODIGO
				U04->U04_ITEM	:= StrZero(1,3)
				U04->U04_TIPO	:= cTipoEnd
				U04->U04_QUADRA	:= aLinhaCt[nPosQuadra, 2]
				U04->U04_MODULO	:= aLinhaCt[nPosModulo, 2]
				U04->U04_JAZIGO	:= aLinhaCt[nPosJazigo, 2]
				U04->U04_GAVETA	:= StrZero(1,2)
				U04->U04_CREMAT	:= ""
				U04->U04_NICHOC	:= ""
				U04->U04_OSSARI	:= iif(nPosOssario > 0, aLinhaCt[nPosOssario, 2], "")
				U04->U04_NICHOO	:= iif(nPosNichoO > 0, aLinhaCt[nPosNichoO, 2], "")
				U04->U04_DATA	:= dDataBase
				U04->U04_DTUTIL	:= CToD("")
				U04->U04_QUEMUT	:= ""
				U04->U04_PRZEXU	:= CToD("")
				U04->U04_PREVIO	:= "S"
				U04->U04_OCUPAG := "S"
				U04->U04_LOCACA	:= "N"
				U04->(MsUnlock())
				lRet := .T.
			Else
				U04->(DisarmTransaction())
				lRet := .F.
				fWrite(nHdlLog , "Erro ao realizar endereçamento prévio!")
				fWrite(nHdlLog , CRLF )
			EndIf

		END TRANSACTION

	Else
		lRet := .F.
		fWrite(nHdlLog , "Nao foram informados os dados do endereco do jazgio")
		fWrite(nHdlLog , CRLF )
	EndIf

	RestArea(aAreaU04)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} EnderecUsado
Verifica se endereço já foi utilizado
@type function
@version 1.0
@author nata.queiroz
@since 29/09/2020
@param aLinhaCt, array
@param cTipoEnd, character
@param cEndPrv, character
@return lRet, logical
/*/
Static Function EnderecUsado(aLinhaCt, cTipoEnd, cEndPrv, cOcupaGaveta)

	Local aArea		:= GetArea()
	Local aAreaU04	:= U04->(GetArea())
	Local aAreaU14 	:= U14->(GetArea())
	Local aAreaU12	:= U12->(GetArea())
	Local lRet 		:= .F.
	Local cQry 		:= ""
	Local cQuadra	:= ""
	Local cModulo	:= ""
	Local cJazigo	:= ""
	Local cGaveta 	:= ""
	Local cCremat	:= ""
	Local cNichoCre	:= ""
	Local cOssario 	:= ""
	Local cNichoOss := ""
	Local cQryOss	:= ""
	Local cFalecido	:= ""
	Local nQtdReg 	:= 0
	Local nTamGav	:= TamSX3("U04_GAVETA")[1]

	Local nPosQuadra 	:= 0
	Local nPosModulo 	:= 0
	Local nPosJazigo 	:= 0
	Local nPosGaveta 	:= 0
	Local nPosCremat 	:= 0
	Local nPosNchCre 	:= 0
	Local nPosOssari 	:= 0
	Local nPosNchOss 	:= 0
	Local nPosQuemUt	:= 0

	Local oOssuarioVinculado := NIL

	Default aLinhaCt		:= {}
	Default cTipoEnd		:= ""
	Default cEndPrv			:= ""
	Default cOcupaGaveta	:= "S"

	// posicoes layout
	nPosQuadra := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_QUADRA"})
	nPosModulo := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_MODULO"})
	nPosJazigo := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_JAZIGO"})
	nPosGaveta := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_GAVETA"})
	nPosCremat := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_CREMAT"})
	nPosNchCre := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_NICHOC"})
	nPosOssari := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_OSSARI"})
	nPosNchOss := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_NICHOO"})
	nPosQuemUt := AScan(aLinhaCt,{|x| AllTrim(x[1]) == "UJV_NOME"})

	// verifico se tem a quadra preenchida no layout
	If nPosQuadra > 0
		cQuadra	:= aLinhaCt[nPosQuadra, 2]
	EndIf

	// verifico se tem a modulo preenchida no layout
	If nPosModulo > 0
		cModulo	:= aLinhaCt[nPosModulo, 2]
	EndIf

	// verifico se tem a jazigo preenchida no layout
	If nPosJazigo > 0
		cJazigo	:= aLinhaCt[nPosJazigo, 2]
	EndIf

	// verifico se tem a gaveta preenchida no layout
	If nPosGaveta > 0
		cGaveta	:= aLinhaCt[nPosGaveta, 2]
	EndIf

	// verifico se tem a falecido preenchida no layout
	If nPosQuemUt > 0
		cFalecido	:= aLinhaCt[nPosQuemUt, 2]
	EndIf

	// verifico se tem a ossario preenchida no layout
	If nPosOssari > 0
		cOssario := aLinhaCt[nPosOssari, 2]
	EndIf

	// verifico se tem a Nicho Ossario preenchida no layout
	If nPosNchOss > 0
		cNichoOss := aLinhaCt[nPosNchOss, 2]
	EndIf

	// verifico se tem a crematorio preenchida no layout
	If nPosCremat > 0
		cCremat := aLinhaCt[nPosCremat, 2]
	EndIf

	// verifico se tem a Niccho Crematorio preenchida no layout
	If nPosNchCre > 0
		cNichoCre := aLinhaCt[nPosNchCre, 2]
	EndIf

	//verifico ossario vinculado para verificar disponibilidade
	if Upper(cTipoEnd) == "O" .And. !Empty(cQuadra)

		oOssuarioVinculado	:= OssuarioVinculado():New(.F., cQuadra, cModulo, cJazigo)

		oOssuarioVinculado:Ossuarios()

		if Len(oOssuarioVinculado:aOssuarios) > 0

			cOssario := oOssuarioVinculado:aOssuarios[1, 4]
			cQryOss += "    AND U04_OSSARI = '"+ cOssario +"' "

		endif

	elseif Upper(cTipoEnd) == "O" // ossario

		If nPosOssari > 0
			cOssario := aLinhaCt[nPosOssari, 2]
		EndIf

		If nPosNchOss > 0
			cNichoOss := aLinhaCt[nPosNchOss, 2]
		EndIf

		cQryOss := "    AND U04_OSSARI = '" + cOssario + "' "
		cQryOss += "    AND U04_NICHOO = '" + cNichoOss + "' "

	endif

	//-- Endereçamento Prévio --//
	If !Empty(cEndPrv) .And. Upper(cEndPrv) == "S" .And. Empty(cOssario)
		cTipoEnd := "J"
	EndIf

	if Select("U04ENDUSD") > 0
		U04ENDUSD->( dbCloseArea() )
	endIf

	cQry := "SELECT U04_CODIGO CONTRATO, "
	cQry += "    U04_ITEM ITEM "
	cQry += "FROM " + RetSqlName("U04")
	cQry += "WHERE D_E_L_E_T_ <> '*' "
	cQry += "    AND U04_FILIAL = '"+ xFilial("U04") +"' "
	cQry += "    AND U04_TIPO = '"+ Upper(cTipoEnd) +"' "

	If Upper(cTipoEnd) == "J" // jazigo
		cQry += "    AND U04_QUADRA = '"+ cQuadra +"' "
		cQry += "    AND U04_MODULO = '"+ cModulo +"' "
		cQry += "    AND U04_JAZIGO = '"+ cJazigo +"' "
		cQry += "    AND U04_GAVETA = '"+ StrZero(Val(cGaveta), nTamGav) +"' "
	EndIf

	If Upper(cTipoEnd) == "C" // crematorio
		cQry += "    AND U04_CREMAT = '"+ cCremat +"' "
		cQry += "    AND U04_NICHOC = '"+ cNichoCre +"' "
	EndIf

	If Upper(cTipoEnd) == "O" // ossario

		//concateno com a condicao de ossario, dependendo se e ossario vinculado
		cQry += cQryOss

	EndIf

	if AllTrim(cOcupaGaveta) <> "S" // Ocupa Gaveta
		cQry += "    AND U04_QUEMUT = '"+ Alltrim(cFalecido) +"' "
	else
		cQry += "    AND U04_OCUPAG = 'S' "
	endif

	cQry := ChangeQuery(cQry)

	MPSysOpenQuery( cQry, 'U04ENDUSD' )

	//-- Endereço já utilizado --//
	If U04ENDUSD->(!Eof())
		lRet := .T.

		if Upper(cTipoEnd) == "O" .And. Upper(cEndPrv) <> "S" // tratamento para ossario
			While U04ENDUSD->(!Eof())
				nQtdReg++
				U04ENDUSD->(DbSkip())
			endDo

			U14->(DbSetOrder(1))
			if U14->(MsSeek(xFilial("U14") + cOssario + Alltrim(cNichoOss) ))
				if nQtdReg >= U14->U14_CAPACI
					lRet := .T.
				else
					lRet := .F.
				endIf
			endIf

		endIf

	EndIf

	if Select("U04ENDUSD") > 0
		U04ENDUSD->( dbCloseArea() )
	endIf

	RestArea(aAreaU12)
	RestArea(aAreaU14)
	RestArea(aAreaU04)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} ImpVincOssuario
Importacao para ossuario vinculado
@type function
@version 1.0
@author g.sampaio
@since 27/04/2022
@param cQuadra, character, quadra do ossuario vinculado
@param cModulo, character, modulo do ossuario vinculado
@param cJazigo, character, jazigo do ossuario vinculado
@param cOssuVinc, character, osssuario vinculado a ser infornmado
@param cNichoVinc, character, nicho vinculado a ser informado
/*/
Static Function ImpVincOssuario( cQuadra, cModulo, cJazigo, cOssuVinc, cNichoVinc)

	Local aArea					:= GetArea()
	Local cQuery 				:= ""
	Local nI 					:= 0
	Local oOssuarioVinculado 	:= Nil

	Default cQuadra				:= ""
	Default cModulo				:= ""
	Default cJazigo				:= ""
	Default cOssuVinc			:= ""
	Default cNichoVinc			:= ""

	// limpa as variaveis
	cOssuVinc	:= ""
	cNichoVinc	:= ""

	// -- Verifica se o Ossuario já está vinculado -- //
	oOssuarioVinculado	:= OssuarioVinculado():New(.F., cQuadra, cModulo, cJazigo)

	oOssuarioVinculado:Ossuarios()

	if Len(oOssuarioVinculado:aOssuarios) > 0

		For nI := 1 To Len(oOssuarioVinculado:aOssuarios)

			if !Empty(cOssuVinc) .And. !Empty(cNichoVinc)
				Exit
			endIf

			if Select("TMPOSS") > 0
				TMPOSS->(dbCloseArea())
			endIf

			cQuery := " SELECT U14.U14_OSSARI, U14.U14_CODIGO, U14.U14_STATUS, U14.U14_CAPACI "
			cQuery += " FROM " + RetSqlName("U14") + " U14 WHERE U14.D_E_L_E_T_ = ' ' "
			cQuery += " AND U14.U14_STATUS = 'S' "
			cQuery += " AND U14.U14_OSSARI = '" + oOssuarioVinculado:aOssuarios[nI, 4] + "' "

			cQuery := ChangeQuery(cQuery)

			// executo a query e crio o alias temporario
			MPSysOpenQuery( cQuery, 'TMPOSS' )

			While TMPOSS->(!Eof())

				if Select("TMPU04") > 0
					TMPU04->(dbCloseArea())
				endIf

				cQuery := " SELECT COUNT(*) QTDUSADO FROM " + RetSqlName("U04") + " U04 "
				cQuery += " WHERE U04.D_E_L_E_T_ = ' ' "
				cQuery += " AND U04.U04_TIPO = 'O' "
				cQuery += " AND U04.U04_OSSARI = '" + TMPOSS->U14_OSSARI + "' "
				cQuery += " AND U04.U04_NICHOO = '" + TMPOSS->U14_CODIGO + "' "
				cQuery += " AND U04.U04_QUEMUT <> '' "

				cQuery := ChangeQuery(cQuery)

				// executo a query e crio o alias temporario
				MPSysOpenQuery( cQuery, 'TMPU04' )

				if TMPU04->(!Eof())
					if TMPU04->QTDUSADO <= TMPOSS->U14_CAPACI
						cOssuVinc 	:= TMPOSS->U14_OSSARI
						cNichoVinc 	:= TMPOSS->U14_CODIGO
						Exit
					endIf
				endIf

				if Select("TMPU04") > 0
					TMPU04->(dbCloseArea())
				endIf

				if !Empty(cOssuVinc) .And. !Empty(cNichoVinc)
					Exit
				endIf

				TMPOSS->(DbSkip())
			EndDo

			if Select("TMPOSS") > 0
				TMPOSS->(dbCloseArea())
			endIf

		Next nI

	endIf

	RestArea(aArea)

Return(Nil)
