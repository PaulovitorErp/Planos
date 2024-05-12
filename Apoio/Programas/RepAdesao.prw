#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE CRLF CHR(13)+CHR(10)

User Function RepAdesao() //-- U_RepAdesao()
	Local oRest := Nil
	Local oAdesoes := Nil
	Local cBaseUrl := "http://api-virtus-prod.herokuapp.com"
	Local cAuthKey := "ntRhwvtdtjOTECnWb7Rp2fPOGa32" //-- ROSA MASTER
	Local nPage := 3
	Local cPage := cValToChar(nPage)
	Local aHeader := {}
	Local cLogs := ""

	AADD(aHeader, "Content-Type:application/json")
	AADD(aHeader, "Authorization: " + cAuthKey)

	oRest := FWRest():New(cBaseUrl)
	oRest:nTimeOut := 30
	oRest:SetPath("/conferencia/adesao/" + cPage)

	MsgInfo("Iniciando processamento!")

	If oRest:Get(aHeader)
		FWJsonDeserialize(oRest:GetResult(), @oAdesoes)

		While Len(oAdesoes) > 0
			//-- Envia 50 contratos para processamento
			Processa( {|| ProcAdesao(oAdesoes, @cLogs) }, "Reprocessando Adesoes", "Aguarde...", .F.)

			MemoWrite("C:\Users\marcos\Desktop\Logs\page"+cPage+"-cLogsRepAdesao.txt", cLogs)
			cLogs := ""

			//-- Pula para proxima pagina de contratos
			nPage++
			cPage := cValToChar(nPage)
			oRest:SetPath("/conferencia/adesao/" + cPage)
			If oRest:Get(aHeader)
				FreeObj(oAdesoes)
				FWJsonDeserialize(oRest:GetResult(), @oAdesoes)
			Else
				FreeObj(oAdesoes)
				oAdesoes := {}
			EndIf
		EndDo
	Else
		MsgAlert( oRest:GetLastError() )
	EndIf

	MsgInfo("Processamento finalizado!")

Return

Static Function ProcAdesao(oAdesoes, cLogs)
	Local lRet := .T.
	Local nX := 0
	Local aArea := GetArea()
	Local aAreaUF2 := UF2->( GetArea() )
	Local aAreaSE1 := SE1->( GetArea() )
	Local cPrefix := "FUN"
	Local cTipo := "AT "
	Local cLogError := ""
	Local nDescontoAdesao := 0
	Local aFPagto := {}
	Local dDataAnt := dDatabase

	ProcRegua( Len(oAdesoes) )
	For nX := 1 To Len(oAdesoes)

		IncProc()

		//-- Pula adesoes com valor zerado
		If (oAdesoes[nX]:adesao:fpagtos[1]:valor <= 0)
			cLogs += "Contrato: "+ oAdesoes[nX]:id +" esta com valor zerado" + CRLF
			Loop
		EndIf

		UF2->( dbSetOrder(6) ) //-- UF2_FILIAL+UF2_IDMOBI
		If UF2->( MsSeek(xFilial("UF2") + oAdesoes[nX]:id) )

			SE1->( dbSetOrder(1) ) //-- E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If SE1->( MsSeek(xFilial("SE1") + cPrefix + PADR(UF2->UF2_CODIGO, 9) + "001" + cTipo) ) //-- Parcela da Adesao

				//-- Processa apenas titulos com desconto 100 porcento
				If (SE1->E1_VALOR <> SE1->E1_DESCONT)
					cLogs += "Contrato: "+ oAdesoes[nX]:id +" nao tem desconto de 100 porcento" + CRLF
					Loop
				EndIf

				//-- Retroge data base
				dDataAnt := dDatabase
				dDatabase := SToD(oAdesoes[nX]:adesao:data_de_recebimento)

				//-- Estorna baixa pelo Loja
				If !Empty(SE1->E1_BAIXA)
					lRet := RemoveBx(SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO)
				EndIf

				If lRet
					//-- faz o calculo do desconto concedido na adesao
					nDescontoAdesao := UF2->UF2_ADESAO - oAdesoes[nX]:adesao:fpagtos[1]:valor
					nDescontoAdesao := IIF(nDescontoAdesao < 0, 0, nDescontoAdesao)

					AAdd(aFPagto,{oAdesoes[nX]:adesao:fpagtos[1]:formapagto,; //1
					oAdesoes[nX]:adesao:fpagtos[1]:gateway,;			//2
					oAdesoes[nX]:adesao:fpagtos[1]:nrocheque,;			//3
					oAdesoes[nX]:adesao:fpagtos[1]:portador,;			//4
					oAdesoes[nX]:adesao:fpagtos[1]:agencia,;			//5
					oAdesoes[nX]:adesao:fpagtos[1]:conta,;				//6
					cValToChar(oAdesoes[nX]:adesao:fpagtos[1]:valor),;	//7
					oAdesoes[nX]:adesao:fpagtos[1]:qtparcelas,;			//8
					oAdesoes[nX]:adesao:fpagtos[1]:vencch,;				//9
					oAdesoes[nX]:adesao:fpagtos[1]:bandeira})			//10

					//-- Realiza baixa da Adesao
					lRet := U_RecAdesao(;
						cPrefix,;
						SE1->E1_NUM,;
						cTipo,;
						SToD(oAdesoes[nX]:adesao:data_de_recebimento),;
						Posicione("SA3",3,xFilial("SA3") + oAdesoes[nX]:cpf_vendedor, "A3_COD"),;
						nDescontoAdesao,;
						aFPagto,;
						@cLogError)

					//-- Grava valor e percentual de desconto
					If lRet
						RecLock("UF2", .F.)
						UF2->UF2_XPERAD := IIF(nDescontoAdesao > 0,;
							cValToChar(((nDescontoAdesao * 100) / UF2->UF2_ADESAO)), "")
						UF2->UF2_XVLDES := nDescontoAdesao
						UF2->( MsUnLock() )
						cLogs += "Contrato: " + oAdesoes[nX]:id + " reprocessado com sucesso!" + CRLF
					Else
						cLogs += "Erro baixar adesao para contrato " + oAdesoes[nX]:id + ": " + cLogError + CRLF
					EndIf

				Else
					cLogs += "Erro ao estornar adesao para contrato " + oAdesoes[nX]:id + CRLF
				EndIf

				//-- Atualiza data base
				dDatabase := dDataAnt

			Else
				cLogs += "Parcela adesao nao encontrada para contrato " + oAdesoes[nX]:id + CRLF
			EndIf

		Else
			cLogs += "Contrato: " + oAdesoes[nX]:id + " nao encontrado!" + CRLF
		EndIf

		nDescontoAdesao := 0
		aFPagto := {}
		cLogError := ""

	Next nX

	RestArea(aArea)
	RestArea(aAreaUF2)
	RestArea(aAreaSE1)

Return

Static Function RemoveBx(cCodFil,cPrefixo,cNum,cParcela,cTipo)
	Local lRet := .F.
	Local aAreaSE5 := SE5->( GetArea() )
	Local aAreaMDM := MDM->( GetArea() )

	//-- Remove movimentos financeiros na SE5 --//
	SE5->( dbSetOrder(7) ) //-- E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
	If SE5->( MsSeek(cCodFil + cPrefixo + cNum + cParcela + cTipo) )
		lRet := .T.
		While SE5->( !EOF() );
				.And. SE5->E5_FILIAL == cCodFil;
				.And. SE5->E5_PREFIXO == cPrefixo;
				.And. SE5->E5_NUMERO == cNum;
				.And. SE5->E5_PARCELA == cParcela;
				.And. SE5->E5_TIPO == cTipo

			RecLock("SE5", .F.)
			SE5->( dbDelete() )
			SE5->( MsUnLock() )

			SE5->( dbSkip() )
		EndDo
	Else
		lRet := .F.
	EndIf

	If lRet
		//-- Remove logs de baixa do Loja --//
		MDM->( dbSetOrder(1) ) //-- MDM_FILIAL+MDM_BXFILI+MDM_PREFIX+MDM_NUM+MDM_PARCEL+MDM_TIPO+MDM_SEQ+MDM_LOTE
		If MDM->( MsSeek(xFilial("MDM") + cCodFil + cPrefixo + cNum + cParcela + cTipo) )
			lRet := .T.
			RecLock("MDM", .F.)
			MDM->( dbDelete() )
			MDM->( MsUnLock() )
		Else
			lRet := .F.
		EndIf
	EndIf

	If lRet
		//-- Estorna valores no titulo --//
		RecLock("SE1", .F.)
		SE1->E1_SALDO := SE1->E1_VALOR
		SE1->E1_BAIXA := STOD( Space(8) )
		SE1->E1_DESCONT := 0
		SE1->E1_VALLIQ := 0
		SE1->E1_STATUS := "A"
		SE1->( MsUnLock() )
	EndIf

	RestArea(aAreaSE5)
	RestArea(aAreaMDM)

Return lRet
