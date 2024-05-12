#Include "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} RFUNA015
Rotina de cancelamento de contrato da funerária
@type function
@version 1.0
@author Wellington Gonçalves
@since 02/09/2016
/*/
User Function RFUNA015()

	Local oCodCan
	Local oMotCan
	Local cCodCan	:= Space(TamSX3("U31_CODIGO")[1])
	Local cMotCan	:= Space(TamSX3("U31_DESCRI")[1])
	Local lContinua	:= .T.
	Local aArea     := GetArea()
	Local aAreaUF2	:= UF2->(GetArea())
	Local cContrato	:= UF2->UF2_CODIGO
	Local cStatus	:= UF2->UF2_STATUS
	Local lIntEmp	:= SuperGetMV("MV_XINTEMP", .F., .F.) // habilito o uso da integracao de empresas
	Static oDlgCan

	If cStatus == "C" //Cancelado
		MsgInfo("O Contrato já se encontra Cancelado, operação não permitida.","Atenção")
		lContinua := .F.
	ElseIf cStatus == "P" //Pré-cadastro
		MsgInfo("O Contrato se encontra Pré-cadastrado, operação não permitida.","Atenção")
		lContinua := .F.
	ElseIf cStatus == "F" //Finalizado
		MsgInfo("O Contrato se encontra Finalizado, operação não permitida.","Atenção")
		lContinua := .F.
	ElseIf cFilAnt != UF2->UF2_MSFIL
		MsgInfo("O cancelamento do contrato so é permitida na filial onde ele foi incluido.","Atenção")
		lContinua := .F.
	EndIf

	if lContinua .And. lIntEmp
		if UF2->UF2_TPCONT == "2" // contrato de integracao
			lContinua := ValContratoInt( UF2->UF2_MSFIL, UF2->UF2_CODIGO, 1 )
		endIf
	endIf

	If lContinua

		DEFINE MSDIALOG oDlgCan TITLE "Cancelamento de Contrato" From 0,0 TO 140,600 PIXEL

		@ 005,005 SAY oSay1 PROMPT "Motivo" SIZE 030, 007 OF oDlgCan COLORS 0, 16777215 PIXEL
		@ 018,005 MSGET oCodCan VAR cCodCan SIZE 040,007 PIXEL OF oDlgCan PICTURE "@!" Valid(ValMotCan(cCodCan,@cMotCan,oMotCan)) F3 "U31" HASBUTTON

		@ 005,055 SAY oSay2 PROMPT "Descrição" SIZE 030, 007 OF oDlgCan COLORS 0, 16777215 PIXEL
		@ 018,055 MSGET oMotCan VAR cMotCan SIZE 240,007 PIXEL OF oDlgCan PICTURE "@!" WHEN .F.

		//Linha horizontal
		@ 040, 005 SAY oSay3 PROMPT Repl("_",292) SIZE 292, 007 OF oDlgCan COLORS CLR_GRAY, 16777215 PIXEL

		//Botoes
		@ 051, 200 BUTTON oButton1 PROMPT "Confirmar" SIZE 040, 010 OF oDlgCan ACTION CancelaCTR(cContrato,cCodCan) PIXEL
		@ 051, 250 BUTTON oButton2 PROMPT "Fechar" SIZE 040, 010 OF oDlgCan ACTION oDlgCan:End() PIXEL

		ACTIVATE MSDIALOG oDlgCan CENTERED

	Endif

	RestArea(aArea)
	RestArea(aAreaUF2)

Return(Nil)

/*/{Protheus.doc} CancelaCTR
Função de cancelamento do contrato
@type function
@version 1.0
@author Wellington Gonçalves
@since 02/09/2016
@param cContrato, character, codigo do contrato
@param cCodCan, character, codigo do cancelamento
@return logical, retorno sobre o cancelamento
/*/
Static Function CancelaCTR(cContrato,cCodCan)

	Local cMsg			:= ""
	Local cPrefixo 		:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
	Local cTipo			:= SuperGetMv("MV_XTCAFUN",.F.,"CAN")
	Local cNatureza		:= SuperGetMv("MV_XNCANFU",.F.,"10101")
	Local cOrigem		:= "RFUNA015"
	Local cOrigemDesc	:= "Cancelamento de Contrato"
	Local lIntEmp		:= SuperGetMV("MV_XINTEMP", .F., .F.) // habilito o uso da integracao de empresas
	Local lRet 			:= .T.
	Local lRecorrencia	:= SuperGetMv("MV_XATVREC",.F.,.F.)
	Local nMVCanDif		:= SuperGetMV("MV_XCANDIF",.F.,1) // parametro para verificar se gera o valro do ressarcimento para o cliente 1=Gera o Titulo de diferenca;2=Pergunta ao Usuario se deseja gerar;3=Nao gera o titulo da diferenca
	Local nValUtilizado := 0
	Local nValPago		:= 0
	Local nDiferenca	:= 0

	If Empty(cCodCan)

		MsgInfo("Campo Motivo de Cancelamento não preenchido, favor preenche-lo! ","Atenção")
		lRet := .F.

	elseif MsgYesNo("Deseja realmente cancelar o contrato?","Atenção!")

		// Inicio o controle de transação
		BEGIN TRANSACTION

			// nao gero o titulo da diferenca
			if nMVCanDif <> 3

				// procuro pelos seviços utilizados do contrato
				nValUtilizado := RetVlrUtil(cContrato)

				// procuro pelos valores pagos do contrato
				nValPago := RetVlrPago(cContrato)

				// diferença do valor utilizado (NOTAS) e o valor pago (TÍTULOS)
				nDiferenca := nValUtilizado - nValPago

				// verifico se calculo a diferenca entre valor pago e valor utilizado
				if nMVCanDif == 2 .And. nDiferenca > 0

					if !MsgNoYes("O valor dos serviços utilizados é maior que o valor dos títulos pagos, deseja gerar o título a receber do cliente? ", "Diferença")
						nDiferenca := 0
					endIf

				endIf

			endIf

			if nDiferenca > 0

				if TitAberto(cContrato,cPrefixo,cTipo)
					cMsg := "Existe um título de cancelamento em aberto para este contrato." + chr(13)+chr(10)
					cMsg += "Exclua o título ou realize a baixa para prosseguir com o cancelamento."
					MsgInfo(cMsg,"Atenção!")
				else

					cMsg := "O valor dos serviços utilizados é maior que o valor dos títulos pagos!" + chr(13)+chr(10)
					cMsg += "Valor utilizado: " + AllTrim(TransForm(nValUtilizado,"@E 999,999.99")) + chr(13)+chr(10)
					cMsg += "Valor pago: " + AllTrim(TransForm(nValPago,"@E 999,999.99")) + chr(13)+chr(10)
					cMsg += "Diferença: " + AllTrim(TransForm(nDiferenca,"@E 999,999.99")) + chr(13)+chr(10)
					cMsg += "Deseja gerar um título a receber para o cliente?"

					if MsgYesNo(cMsg,"Atenção!")
						FWMsgRun(,{|oSay| lRet := GeraTitulo(nDiferenca,cPrefixo,cTipo,cNatureza)},'Aguarde...','Gerando título a receber para o cliente...')
					else
						MsgAlert("Processo de cancelamento encerrado pelo usuário", "Cancelamento")
					endif

				endif

			else

				U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
				If lRecorrencia .And. U60->(MsSeek(xFilial("U60") + UF2->UF2_FORPG ))

					// Envia arquivamento do cliente para Vindi
					lRet := ArqClient("F", UF2->UF2_CODIGO, UF2->UF2_CLIENT, UF2->UF2_LOJA)

				endIf

				if lRet

					// chamo função que faz a exclusão dos títulos em aberto
					FWMsgRun(,{|oSay| lRet := ExcluiTitulos(oSay,cContrato)},'Aguarde...','Excluindo os títulos a receber em aberto...')

				endIf

				if lRet

					// gravo os flags de cancelamento do contrato
					if RecLock("UF2",.F.)

						UF2->UF2_STATUS := "C"
						UF2->UF2_CODCAN	:= cCodCan
						UF2->UF2_DTCANC	:= dDataBase
						UF2->UF2_USRCAN := cUserName
						UF2->(MsUnLock())

						MsgInfo("Contrato cancelado com sucesso!","Atenção")
						lRet := .T.

					endif

					MsgInfo("Contrato cancelado com sucesso!","Atenção")
					lRet := .T.

				endif

				if !lRet
					// aborto a transação
					DisarmTransaction()
				endif

			endIf

		END TRANSACTION

		oDlgCan:End()

	endif

Return( lRet )

/*/{Protheus.doc} ValMotCan
Função que valida o motivo de cancelamento informado
@type function
@version 1.0
@author Wellington Gonçalves
@since 02/09/2016
@param cCodCan, character, codigo do cancelamento
@param cMotCan, character, motivo do cancelamento
@param oMotCan, object, objeto do motivo de cancelamento
@return logical, retorno da validacao do motivo de cancelamento
/*/
Static Function ValMotCan(cCodCan,cMotCan,oMotCan)

	Local lRet := .T.

	// limpo o campo da descrição do cancelamento
	cMotCan := Space(TamSX3("U31_DESCRI")[1])

	// se o código estiver preenchido
	If !Empty(cCodCan)

		U31->(DbSetOrder(1)) // U31_FILIAL + U31_CODIGO
		If U31->(MsSeek(xFilial("U31") + cCodCan))
			cMotCan := U31->U31_DESCRI
		Else
			MsgInfo("Motivo de Cancelamento inválido.","Atenção")
			lRet := .F.
		Endif

	Endif

	oMotCan:Refresh()

Return(lRet)

/*/{Protheus.doc} RetVlrUtil
Função que retorna o valor dos serviços utilizados pelo
cliente na funerária	
@type function 
@version 1.0 
@author Wellington Gonçalves
@since 02/09/2016
@param cContrato, character, codigo do contrato
@return numeric, retorna o valor dos servicos
/*/
Static Function RetVlrUtil(cContrato)

	Local aArea 		:= GetArea()
	Local cQry			:= ""
	Local nValServico	:= 0

	// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	cQry := " SELECT "
	cQry += " SUM(SF2.F2_VALMERC) AS VALOR_SERVICOS "
	cQry += " FROM "
	cQry += " " + RetSqlName("SF2") + " SF2 "
	cQry += " INNER JOIN  " + RetSqlName("SC5") + " SC5 ON SC5.D_E_L_E_T_ = ' ' "
	cQry += " AND SC5.C5_FILIAL 	= '" + xFilial("SC5") + "' "
	cQry += " AND SC5.C5_NOTA 		= SF2.F2_DOC "
	cQry += " AND SC5.C5_SERIE 		= SF2.F2_SERIE "
	cQry += " AND SC5.C5_XCTRFUN 	= '" + cContrato + "' "
	cQry += " WHERE "
	cQry += " SF2.D_E_L_E_T_ = ' ' "
	cQry += " AND SF2.F2_FILIAL = '" + xFilial("SF2") + "' "

	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)

	// crio o alias temporario
	TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query

	// se existir contratos a serem reajustados
	if QRY->(!Eof())
		nValServico := QRY->VALOR_SERVICOS
	endif

	// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(nValServico)

/*/{Protheus.doc} RetVlrPago
Função que retorna o valor do contrato pago pelo cliente
@type function
@version 1.0
@author Wellington Gonçalves
@since 02/09/2016
@param cContrato, character, codigo do contrato
@return numeric, retorna o valor pago do contrato
/*/
Static Function RetVlrPago(cContrato)

	Local aArea 		:= GetArea()
	Local cQry			:= ""
	Local nVlrBaixa		:= 0

	// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	cQry := " SELECT "
	cQry += " SUM(E5_VALOR) VALOR_BAIXA "
	cQry += " FROM "
	cQry += RetSQLName("SE5") + " SE5 "
	cQry += " INNER JOIN "
	cQry += RetSQLName("SE1") + " SE1 "
	cQry += " ON SE1.D_E_L_E_T_ <> '*' "
	cQry += " AND SE1.E1_FILIAL = '" + xFilial("SE1")+ "' "
	cQry += " AND SE1.E1_XCTRFUN = '" + cContrato + "' "
	cQry += " AND SE5.E5_PREFIXO  = SE1.E1_PREFIXO "
	cQry += " AND SE5.E5_NUMERO = SE1.E1_NUM "
	cQry += " AND SE5.E5_PARCELA  = SE1.E1_PARCELA "
	cQry += " AND SE5.E5_TIPO = SE1.E1_TIPO "
	cQry += " WHERE "
	cQry += " SE5.D_E_L_E_T_ <> '*' "
	cQry += " AND SE5.E5_FILIAL = '"+ xFilial("SE5")+ "' "
	cQry += " AND E5_SITUACA <> 'C' "
	cQry += " AND E5_FATURA = ' ' "
	cQry += " AND E5_RECPAG = 'R' "
	cQry += " AND ( "
	cQry += " 	E5_TIPODOC = 'VL' "
	cQry += " 	OR (E5_MOTBX = 'DAC' AND E5_TIPODOC NOT IN ('MT','JR','ES','M2','J2','IB','AP','BL','C2','CB','CM','D2','DC','DV','NCC','SG','TC')) "
	cQry += " ) "

	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)

	// crio o alias temporario
	TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query

	if QRY->(!Eof())
		nVlrBaixa := QRY->VALOR_BAIXA
	endif

	// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(nVlrBaixa)

/*/{Protheus.doc} GeraTitulo
Função que gera o título a receber da diferença que o
cliente deve pagar	
@type function
@version 1.0 
@author Wellington Gonçalves
@since 06/09/2016
@param nValor, numeric, valor do titulo
@param cPrefixo, character, prefixo do titulo
@param cTipo, character, tipo do titulo
@param cNatureza, character, natureza do titulo
@return logical, retorno sobre a criacao do titulo
/*/
Static Function GeraTitulo(nValor,cPrefixo,cTipo,cNatureza)

	Local aArea			:= GetArea()
	Local aAreaUF2		:= UF2->(GetArea())
	Local cContrato		:= UF2->UF2_CODIGO
	Local cCliente		:= UF2->UF2_CLIENT
	Local cLoja			:= UF2->UF2_LOJA
	Local lRet			:= .T.
	Local cMesAno		:= ""
	Local cParcela		:= ""
	Local aFin040 		:= {}

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	cParcela 	:= RetParcela(xFilial("SE1"),cPrefixo,cContrato,cTipo)
	cMesAno 	:= SubStr(DTOC(dDataBase),4,7)

	aadd(aFin040, {"E1_FILIAL"	, xFilial("SE1")											, Nil } )
	aadd(aFin040, {"E1_PREFIXO"	, cPrefixo         						   					, Nil } )
	aadd(aFin040, {"E1_NUM"		, cContrato		 	   										, Nil } )
	aadd(aFin040, {"E1_PARCELA"	, cParcela								   					, Nil } )
	aadd(aFin040, {"E1_XPARCON"	, cMesAno													, Nil } )
	aadd(aFin040, {"E1_TIPO"	, cTipo		 							   					, Nil } )
	aadd(aFin040, {"E1_NATUREZ"	, cNatureza													, Nil } )
	aadd(aFin040, {"E1_CLIENTE"	, cCliente								   					, Nil } )
	aadd(aFin040, {"E1_LOJA"	, cLoja									   					, Nil } )
	aadd(aFin040, {"E1_EMISSAO"	, dDataBase								   					, Nil } )
	aadd(aFin040, {"E1_VENCTO"	, dDataBase													, Nil } )
	aadd(aFin040, {"E1_VENCREA"	, DataValida(dDataBase)										, Nil } )
	aadd(aFin040, {"E1_VALOR"	, nValor								   					, Nil } )
	aadd(aFin040, {"E1_XCTRFUN"	, cContrato								   					, Nil } )
	aadd(aFin040, {"E1_XFORPG"	, UF2->UF2_FORPG						   					, Nil } )

	MSExecAuto({|x,y| FINA040(x,y)},aFin040,3)

	If lMsErroAuto
		MostraErro()
		MsgInfo("Ocorreu um problema na geração do título a receber, operação cancelada.","Atenção")
		lRet := .F.
	else
		MsgInfo("Título gerado com sucesso!","Atenção")
	EndIf

	RestArea(aArea)
	RestArea(aAreaUF2)

Return(lRet)

/*/{Protheus.doc} RetParcela
Função que retorna a próxima parcela do título a ser utilizada
@type function
@version 1.0
@author Wellington Gonçalves
@since 06/08/2016
@param cFilSE1, character, filial do titulo
@param cPrefixo, character, prefixo do titulo
@param cNumero, character, numero do titulo
@param cTipo, character, tipo do titulo
@return variant, retorna a parcela
/*/
Static Function RetParcela(cFilSE1,cPrefixo,cNumero,cTipo)

	Local cRet 			:= ""
	Local cQry			:= ""
	Local aArea			:= GetArea()
	Local cPulaLinha	:= chr(13)+chr(10)

	// verifico se não existe este alias criado
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	EndIf

	cQry := " SELECT "											+ cPulaLinha
	cQry += " MAX(SE1.E1_PARCELA) AS ULTIMA_PARCELA "			+ cPulaLinha
	cQry += " FROM " 											+ cPulaLinha
	cQry += " " + RetSqlName("SE1") + " SE1 " 					+ cPulaLinha
	cQry += " WHERE " 											+ cPulaLinha
	cQry += " SE1.D_E_L_E_T_ <> '*' " 							+ cPulaLinha
	cQry += " AND SE1.E1_FILIAL = '" + cFilSE1 + "' "			+ cPulaLinha
	cQry += " AND SE1.E1_PREFIXO = '" + cPrefixo + "' " 		+ cPulaLinha
	cQry += " AND SE1.E1_XCTRFUN = '" + cNumero + "' " 			+ cPulaLinha
	cQry += " AND SE1.E1_TIPO = '" + cTipo + "' " 				+ cPulaLinha

	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)

	// crio o alias temporario
	TcQuery cQry New Alias "QRYSE1" // Cria uma nova area com o resultado do query

	// se existir títulos com este tipo
	if QRYSE1->(!Eof()) .AND. !Empty(QRYSE1->ULTIMA_PARCELA)
		cRet := Soma1(QRYSE1->ULTIMA_PARCELA)
	else
		cRet := Padl("1",TamSX3("E1_PARCELA")[1],"0")
	endif

	// fecho o alias temporario criado
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(cRet)

/*/{Protheus.doc} TitAberto
Função que retorna se existe título de cancelamento em
aberto
@type function
@version 1.0 
@author Wellington Gonçalves
@since 06/09/2016
@param cContrato, character, codigo do contrato
@param cPrefixo, character, prefixo do titulo
@param cTipo, character, tipo do titulo
@return logical, retorna sobre os titulos em aberto
/*/
Static Function TitAberto(cContrato,cPrefixo,cTipo)

	Local aArea 		:= GetArea()
	Local cQry			:= ""
	Local cPulaLinha	:= chr(13)+chr(10)
	Local lRet			:= .F.

	// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	cQry := " SELECT " 												+ cPulaLinha
	cQry += " SE1.E1_NUM " 											+ cPulaLinha
	cQry += " FROM " 												+ cPulaLinha
	cQry += " " + RetSqlName("SE1") + " SE1 " 						+ cPulaLinha
	cQry += " WHERE " 												+ cPulaLinha
	cQry += " SE1.D_E_L_E_T_ <> '*' " 								+ cPulaLinha
	cQry += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "		+ cPulaLinha
	cQry += " AND SE1.E1_XCTRFUN = '" + cContrato + "' " 			+ cPulaLinha
	cQry += " AND SE1.E1_PREFIXO = '" + cPrefixo + "' " 			+ cPulaLinha
	cQry += " AND SE1.E1_TIPO = '" + cTipo + "' " 					+ cPulaLinha
	cQry += " AND SE1.E1_SALDO > 0 " 								+ cPulaLinha

	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)

	// crio o alias temporario
	TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query

	// se existir contratos a serem reajustados
	if QRY->(!Eof())
		lRet := .T.
	endif

	// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(lRet)


/*/{Protheus.doc} ExcluiTitulos
Função que faz a exclusão dos títulos em aberto do cliente
@type function
@version 1.0
@author Wellington Gonçalves
@since 07/09/2016
@param oSay, object, param_description
@param cContrato, character, param_description
@return logical, retorna se a exclusao de titulos deu certo
@history 02/07/2020, g.sampaio, VPDV-473 - Manutencao na geracao do estorno de comissao,
para evitar duplicidade no momento de estornar a comissao, devido a passar mais de uma vez
pela funcao.
@history 20/08/2020, g.sampaio, VPDV-508 - Implementado o parametro MV_XESTCOM, para
habilitar e desabilitar o estonrno de comissao. 
/*/
Static Function ExcluiTitulos(oSay,cContrato)

	Local aArea 				:= GetArea()
	Local aAreaUF2				:= UF2->(GetArea())
	Local aAreaSE1				:= SE1->( GetArea() )
	Local lRet					:= .T.
	Local lUsaNovaComissao		:= SuperGetMv("ES_NEWCOMI",,.F.)	// ativo o uso da nova comissao
	Local lUsaEstornoComissao   := SuperGetMV("MV_XESTCOM",,.F.)
	Local lComisExc				:= .T.
	Local nOpcA					:= 0
	Local aFin040				:= {}

	// posiciono nos titulos do contrato de funeraria
	SE1->(DbOrderNickName("E1_XCTRFUN")) // E1_FILIAL + E1_XCTRFUN
	if SE1->(MsSeek(xFilial("SE1") + cContrato))

		//valido se o contrato esta em cobranca
		If !VldCobranca(SE1->E1_FILIAL,cContrato)
			MsgInfo("O Contrato possui titulos em cobrança, operação cancelada.","Atenção")
			DisarmTransaction()
			lRet := .F.
		else

			// verifico se usa a nova comissao
			if lUsaNovaComissao

				// verifico se utilizo o estorno de comissao
				if lUsaEstornoComissao

					// estorno de comissao de contrato funerario
					lRet := U_UTILE15C( cContrato, "F", @cLog )

					// verifico se deu tudo certo com o estorno da comissao
					If lRet
						cMensComis := "Foi gerado estorno ou exclusão da comissão do vendedor!"
					Else // caso tenha dado errado
						cMensComis := "Não possível realizar o estorno ou exclusão da comissão do Vendedor, favor anliasar o 'Log'"
					EndIf

					// aviso de comissao
					nOpcA := Aviso("Exclusão/Estorno de Comissão", cMensComis, { "Log","Fechar"}, 2)

					// gero o log do estorno
					If nOpcA == 1

						// crio o objeto para a log
						oLogVirtus := LogVirtus():New()

						// gero o arquivo de log
						cArqLog := oLogVirtus:Crialog( cLog )

						// verifico se tem arquivo de log
						If !Empty(cArqLog)

							// abro o arquivo de log
							ShellExecute("open",cArqLog,"",cArqLog, 1 )

						EndIf

					EndIf

				endIf

			endIf

			While SE1->(!Eof()) .AND. SE1->E1_FILIAL == xFilial("SE1") .AND. SE1->E1_XCTRFUN == cContrato

				aFin040		:= {}
				lMsErroAuto := .F.
				lMsHelpAuto := .T.

				oSay:cCaption := ("Excluindo parcela " + AllTrim(SE1->E1_PARCELA) + "...")
				ProcessMessages()

				If SE1->E1_VALOR == SE1->E1_SALDO // somente título que não teve baixa

					// verifico se usa a nova comissao
					if !lUsaNovaComissao

						// faco a exclusao da comissao
						lComisExc := ExcComiss(SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_XCTRFUN)

					endIf

					//excluo parcelas de comissao
					If lComisExc

						// faço a exclusão do título do bordero
						ExcBord( SE1->( Recno() ) )

						//caso seja fatura, sera realizado a baixa por dacao e nao a exclusao do titulo
						if Alltrim(SE1->E1_FATURA) == 'NOTFAT'

							lRet := BxFatura(SE1->(Recno()))

						else

							// faço a exclusão do título a receber
							AAdd(aFin040, {"E1_FILIAL"  , SE1->E1_FILIAL  	, Nil})
							AAdd(aFin040, {"E1_PREFIXO" , SE1->E1_PREFIXO 	, Nil})
							AAdd(aFin040, {"E1_NUM"     , SE1->E1_NUM	   	, Nil})
							AAdd(aFin040, {"E1_PARCELA" , SE1->E1_PARCELA	, Nil})
							AAdd(aFin040, {"E1_TIPO"    , SE1->E1_TIPO  	, Nil})

							MSExecAuto({|x,y| Fina040(x,y)},aFin040,5)

							If lMsErroAuto
								MostraErro()
								lRet := .F.
								Exit
							EndIf

						endif

					EndIf

				endif

				SE1->(DbSkip())

			EndDo
		endif
	endif

	RestArea(aAreaSE1)
	RestArea(aArea)
	RestArea(aAreaUF2)
Return(lRet)

/*/{Protheus.doc} ExcComiss
Função que faz a exclusão dos títulos de comissão
@type function
@version 1.0
@author Raphael Martiins Garcia
@since 04/11/2016
@param cCliente, character, param_description
@param cLoja, character, param_description
@param cPrefixo, character, param_description
@param cTitulo, character, param_description
@param cParcela, character, param_description
@param cTipo, character, param_description
@param cContrato, character, param_description
@return return_type, return_description
@history 28/05/2020, g.sampaio, VPDV-473 - Implementado a variavel de log 'cLog' 
- Implementado a tela de Aviso para estorno/exclusao da comissao
/*/
Static Function ExcComiss(cCliente,cLoja,cPrefixo,cTitulo,cParcela,cTipo,cContrato)

	Local aArea				:= GetArea()
	Local aAreaSE1 	    	:= SE1->( GetArea() )
	Local aAreaSE3 	    	:= SE3->( GetArea() )
	Local aAuto				:= {}
	Local cVendedor			:= RetField("UF2",1, xFilial("UF2") +  cContrato, "UF2_VEND")
	Local cMensComis		:= ""
	Local cLog				:= ""
	Local cArqLog			:= ""
	Local lRet		 		:= .T.
	Local lUsaNovaComissao	:= SuperGetMv("ES_NEWCOMI",,.F.)	// ativo o uso da nova comissao
	Local nOpcA				:= 0
	Local oLogVirtus		:= Nil

	Private lMsErroAuto 	:= .F.

	// verifico se o vendedor esta preenchido
	If !Empty( cVendedor ) .And. !lUsaNovaComissao

		SE3->( DbSetOrder( 3 ) ) //E3_FILIAL+E3_VEND+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO+E3_SEQ

		//encontro parcela da comissao de acordo com a parcela do titulo
		If SE3->( MsSeek( xFilial("SE3") + cVendedor + cCliente + cLoja + cPrefixo + cTitulo + cParcela + cTipo ) )

			//valido se a comissao foi paga
			If Empty(SE3->E3_DATA)

				aAuto := {}
				aAdd(aAuto, {"E3_VEND"		, SE3->E3_VEND		,Nil})
				aAdd(aAuto, {"E3_NUM" 		, SE3->E3_NUM		,Nil})
				aAdd(aAuto, {"E3_CODCLI"	, SE3->E3_CODCLI	,Nil})
				aAdd(aAuto, {"E3_LOJA"		, SE3->E3_LOJA		,Nil})
				aAdd(aAuto, {"E3_PREFIXO"	, SE3->E3_PREFIXO	,Nil})
				aAdd(aAuto, {"E3_PARCELA"	, SE3->E3_PARCELA	,Nil})
				aAdd(aAuto, {"E3_TIPO"		, SE3->E3_TIPO		,Nil})

				MSExecAuto({|x,y| Mata490(x,y)}, aAuto, 5) //Exclusão de Comissão

				If lMsErroAuto
					MostraErro()
					lRet := .F.
				EndIf
			Else
				MsgInfo("Comissão da Parcela: ( "+cParcela+" ) já encontra-se baixada, não será possivel estornar a comissão!","Atenção")
				lRet := .F.
			EndIf

		EndIf

	EndIf

	// atualizo o valor da variavel de erro do execauto
	lMsErroAuto := .F.

	RestArea( aAreaSE1 )
	RestArea( aAreaSE3 )
	RestArea( aArea )

Return( lRet )

////////////////////////////////////////////////////////////////////
////// FUNCAO PARA VALIDAR SE O TITULO ESTA EM COBRANCA		///////
///////////////////////////////////////////////////////////////////	
Static Function VldCobranca(cFiltTit,cContrato)

	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local aAreaSE1	:= SE1->( GetArea() )
	Local aAreaSK1	:= SK1->( GetArea() )
	Local cQry 		:= ""

///////////////////////////////////////////////////////////////
///// CONSULTO SE O CONTRATO POSSUI TITULOS EM COBRANCA	//////
//////////////////////////////////////////////////////////////

	cQry 	:= " SELECT "
	cQry 	+= " K1_FILIAL FILIAL, "
	cQry 	+= " K1_PREFIXO PREFIXO, "
	cQry 	+= " K1_NUM NUMERO, "
	cQry 	+= " K1_PARCELA PARCELA, "
	cQry 	+= " K1_TIPO TIPO, "
	cQry 	+= " K1_FILORIG FILORIG "
	cQry	+= " FROM "
	cQry	+= + RetSQLName("SK1") + " COBRANCA
	cQry 	+= " INNER JOIN "
	cQry 	+= + RetSQLName("SE1") + " TITULO
	cQry 	+= " ON "
	cQry 	+= " COBRANCA.K1_PREFIXO = TITULO.E1_PREFIXO "
	cQry	+= " AND COBRANCA.K1_NUM 	= TITULO.E1_NUM "
	cQry	+= " AND COBRANCA.K1_PARCELA = TITULO.E1_PARCELA "
	cQry	+= " AND TITULO.E1_XCTRFUN 	= '" + cContrato + "' "
	cQry	+= " AND TITULO.E1_FILIAL 	= '" + cFiltTit + "' "
	cQry	+= " AND TITULO.D_E_L_E_T_ 	= ' ' "
	cQry	+= " WHERE "
	cQry	+= "	COBRANCA.D_E_L_E_T_ = ' '"
	cQry	+= " 	AND COBRANCA.K1_FILORIG = '" + cFiltTit + "' "
	cQry 	+= " 	AND COBRANCA.K1_OPERAD	<> 'XXXXXX' " //XXXXXX Titulo marcado como excecao na cobranca


	If Select("QRYCOB") > 0
		QRYCOB->(DbCloseArea())
	Endif

	cQry := ChangeQuery(cQry)
	TcQuery cQry NEW Alias "QRYCOB"

	QRYCOB->( DbGotop() )

//valido se possui cobranca para o contrato
	if QRYCOB->(!Eof())

		if MsgYesNo("O Contrato selecionado possui titulo(s) em cobrança.deseja continuar a operação? "+;
				Chr(13) + Chr(10) + " Os Titulos do contrato serão marcado como exceção no módulo de CallCenter.")


			SK1->(DbSetOrder(1)) //K1_FILIAL+K1_PREFIXO+K1_NUM+K1_PARCELA+K1_TIPO+K1_FILORIG

			While QRYCOB->(!Eof())

				//marco o titulo como excecao de cobranca, assim o mesmo estara apto para exclusao
				if SK1->(MsSeek(QRYCOB->FILIAL+QRYCOB->PREFIXO+QRYCOB->NUMERO+QRYCOB->PARCELA+QRYCOB->TIPO+QRYCOB->FILORIG))

					RecLock("SK1",.F.)
					SK1->K1_OPERAD := 'XXXXXX'
					SK1->(MsUnlock())

				endif


				QRYCOB->(DbSkip())

			EndDo


		else
			lRet := .F.
		endif


	endif


	RestArea(aArea)
	RestArea(aAreaSE1)
	RestArea(aAreaSK1)

Return( lRet )

/*/{Protheus.doc} BxFatura
Funcao para realizar a baixa de Fatura por DACAO para o
cancelamento dos contratos
@type function
@version 1.0
@author Raphael Martiins Garcia
@since 04/11/2016
@param nRecnoSE1, numeric, codigo do recno
@return logical, retorna sobre a baixa da fatura do cliente
/*/
Static Function BxFatura(nRecnoSE1)

	Local aArea 	:= GetArea()
	Local aAreaSE1	:= SE1->(GetArea())
	Local aBaixa	:= {}
	Local lRet		:= .T.

	Private lMsErroAuto := .F.

	DbSelectArea("SE1")
	SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	SE1->(DbGoTo(nRecnoSE1))

	// faço a exclusão do título do bordero
	ExcBord( SE1->( Recno() ) )

	// percorro o titulo enquanto houver saldo, por conta do calculo de juros
	While SE1->E1_SALDO > 0

		// limpo o array de baixa
		aBaixa := {}

		// array de baixa
		aBaixa := {;
			{"E1_PREFIXO"   ,SE1->E1_PREFIXO										,Nil},;
			{"E1_NUM"       ,SE1->E1_NUM											,Nil},;
			{"E1_PARCELA"   ,SE1->E1_PARCELA										,Nil},;
			{"E1_TIPO"      ,SE1->E1_TIPO											,Nil},;
			{"E1_CLIENTE" 	,SE1->E1_CLIENTE										,Nil},;
			{"E1_LOJA" 		,SE1->E1_LOJA											,Nil},;
			{"AUTMOTBX"     ,"DAC"													,Nil},;
			{"AUTDTBAIXA"   ,dDatabase												,Nil},;
			{"AUTDTCREDITO" ,dDatabase												,Nil},;
			{"AUTHIST"      ,"BAIXA POR CANCELAMENTO FUN"							,Nil},;
			{"AUTJUROS"     ,0      												,Nil,.T.},;
			{"AUTMULTA"     ,0      												,Nil,.T.},;
			{"AUTVALREC"    ,SE1->E1_SALDO											,Nil}}

		MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3) //Baixa conta a receber

		If lMsErroAuto

			MostraErro()

			lRet := .F.
			DisarmTransaction()

		endif

		// posiciono novamente no registro que esta sendo baixado
		SE1->(DbGoTo(nRecnoSE1))

	EndDo

	RestArea(aArea)
	RestArea(aAreaSE1)

Return(lRet)

/*/{Protheus.doc} ExcBord
Funcao para exclusao do bordero
@type function
@version 1.0 
@author g.sampaio
@since 18/11/2021
@param nRecSE1, numeric, numero do recno do titulo
/*/
Static Function ExcBord(nRecSE1)

	Local aArea		:= GetArea()
	Local aAreaSE1	:= SE1->( GetArea() )
	Local aAreaSEA	:= SEA->( GetArea() )

	DbSelectArea("SE1")
	SE1->(DbGoTo(nRecSE1))

	DbSelectArea("SEA")
	SEA->(DbSetOrder(1)) //EA_FILIAL+EA_NUMBOR+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA

	// faço a exclusão do título do bordero
	SEA->(DbSetOrder(1)) // EA_FILIAL + EA_NUMBOR + EA_PREFIXO + EA_NUM + EA_PARCELA + EA_TIPO + EA_FORNECE + EA_LOJA
	If SEA->(MsSeek(xFilial("SEA") + SE1->E1_NUMBOR + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO))

		if RecLock("SEA",.F.)
			SEA->(DbDelete())
			SEA->(MsUnlock())
		else
			SE1->(DisarmTransaction())
			BREAK
		endif

	Endif

	// limpa os dados de bordero do titulo
	if RecLock("SE1",.F.)
		SE1->E1_SITUACA	:= "0"
		SE1->E1_OCORREN	:= ""
		SE1->E1_NUMBCO	:= ""
		SE1->E1_NUMBOR	:= ""
		SE1->E1_PORTADO := ""
		SE1->E1_CONTA   := ""
		SE1->E1_AGEDEP  := ""
		SE1->E1_DATABOR	:= Stod("")
		SE1->(MsUnLock())
	else
		SE1->(DisarmTransaction())
		BREAK
	endIf

	RestArea(aArea)
	RestArea(aAreaSE1)
	RestArea(aAreaSEA)

Return(Nil)

/*/{Protheus.doc} ArqClient
Envia arquivamento do cliente para Vindi
Inativa faturas
@type function
@version 1.0
@author nata.queiroz
@since 07/04/2020
@param cCodMod, character, cCodMod
@param cCodCtr, character, cCodCtr
@param cCodCli, character, cCodCli
@param cLoja, character, cLoja
@param cOrigem, character, cOrigem
@param cOrigemDesc, character, cOrigemDesc
@return logical, lRet
/*/
Static Function ArqClient(cCodMod, cCodCtr, cCodCli, cLoja, cOrigem, cOrigemDesc)
	Local lRet 			:= .T.
	Local aArea 		:= GetArea()
	Local aAreaUF2		:= UF2-> (GetArea() )
	Local aAreaU61 		:= U61->( GetArea() )
	Local aAreaU65 		:= U65->( GetArea() )
	Local oVindi 		:= Nil
	Local cErroVindi 	:= ""
	Local cMsg 			:= ""
	Local cStatus		:= ""

	Default cCodMod		:= "F"
	Default cCodCtr		:= ""
	Default cCodCli		:= ""
	Default cLoja		:= ""
	Default cOrigem		:= "RFUNA015"
	Default cOrigemDesc	:= "Arquivamento de Cliente"

	// posiciono no cliente da vindi
	U61->(DbSetOrder(3)) // U61_FILIAL + U61_CLIENT + U61_LOJA
	if U61->(MsSeek(xFilial("U61") + cCodCli + cLoja)) .And. U61->U61_STATUS == "A"

		oVindi := IntegraVindi():New()

		cMsg := "Enviando Arquivamento do Cliente para Plataforma Vindi..."
		FWMsgRun(,{|oSay| lRet := oVindi:CliOnline("E", cCodMod, @cErroVindi, cOrigem, cOrigemDesc)}, "Aguarde...", cMsg)

		//Se cliente na vindi foi arquivado, inativa faturas
		If lRet

			// Finaliza operacoes na tabela de envio Vindi (U62)
			FinU62(U61->U61_MSFIL, cCodMod, U61->U61_CONTRA)

			//Posiciono nas faturas do contrato para inativar
			U65->( DbSetOrder(4) ) //U65_FILIAL + U65_CONTRA + U65_CLIENT + U65_LOJA
			U65->( dbGoTop() )
			If U65->( MsSeek(xFilial("U65") + cCodCtr + cCodCli + cLoja) )
				While U65->(!EOF());
						.And. 	U65->U65_FILIAL + U65->U65_CONTRA + U65->U65_CLIENT + AllTrim(U65->U65_LOJA);
						== xFilial("U65") + cCodCtr + cCodCli + cLoja

					//Consulto status da fatura na VINDI
					cStatus := oVindi:ConsultaFatura(cCodMod,@cErroVindi,U65->U65_CODVIN,/*cCodRet*/,/*cDescRetorno*/,/*cDadosRetorno*/)

					If AllTrim(cStatus) == "canceled" .AND. U65->U65_STATUS == "A"
						If Reclock("U65",.F.)
							U65->U65_STATUS := "I"
							U65->(MsUnLock())
						EndIf
					ElseIf AllTrim(cStatus) <> "canceled" .AND. U65->U65_STATUS == "I"
						If Reclock("U65",.F.)
							U65->U65_STATUS := "A"
							U65->(MsUnLock())
						EndIf
					EndIf

					U65->(DbSkip())
				EndDo
			EndIf
			
		Else

			cMsg := "Não foi possível realizar o arquivamento do cliente na Vindi!"
			Help(NIL, NIL, "Atenção!", NIL, cMsg, 1, 0, NIL, NIL, NIL, NIL, NIL, {cErroVindi})

		EndIf

	else

		lRet := .F.
		cMsg := "Não foi possível localizar o cliente vindi, ou cliente vindi desativado!"
		Help(NIL, NIL, "Atenção!", NIL, cMsg, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o cadastro do cliente vindi."})

	EndIf

	RestArea(aArea)
	RestArea(aAreaU61)
	RestArea(aAreaU65)
	RestArea(aAreaUF2)

Return(lRet)

/*/{Protheus.doc} FinU62
Finaliza todas operações de envio para contrato (Job Envio Vindi)
@type function
@version 1.0
@author nata.queiroz
@since 08/04/2020
@param cFilCtr
@param cCodMod
@param cContrato
/*/
Static Function FinU62(cFilCtr, cCodMod, cContrato)
	Local cQry := ""
	Local nQtdReg := 0
	Local aArea := GetArea()
	Local aAreaU62 := U62->( GetArea() )

	cQry := "SELECT R_E_C_N_O_ RECNO "
	cQry += "FROM " + RetSqlName("U62")
	cQry += "WHERE D_E_L_E_T_ <> '*' "
	cQry += "AND U62_MSFIL = '"+ cFilCtr +"' "
	cQry += "AND U62_MODULO = '"+ cCodMod +"' "
	cQry += "AND U62_STATUS <> 'C' "
	cQry += "AND TRIM(U62_CHAVE) LIKE '%"+ AllTrim(cContrato) +"%' "
	cQry := ChangeQuery(cQry)

	If Select("U62FIN") > 0
		U62FIN->( dbCloseArea() )
	EndIf
	
	MPSysOpenQuery(cQry, "U62FIN")

	If U62FIN->( !EOF() )
		
		While U62FIN->( !EOF() )

			U62->( dbGoTo(U62FIN->RECNO) )
			RecLock("U62", .F.)
			U62->U62_STATUS := "C"
			U62->U62_DTPROC := dDatabase
			U62->U62_HRPROC := SubStr(Time(), 1, 5)
			U62->U62_CODRET := "200"
			U62->U62_DESRET := "Cliente arquivado na plataforma Vindi"
			U62->( MsUnLock() )

			U62FIN->( dbSkip() )
		EndDo
	EndIf

	U62FIN->( dbCloseArea() )

	RestArea(aArea)
	RestArea(aAreaU62)

Return

/*/{Protheus.doc} ValContratoInt
Funcao para validar o contrato de integracao
@type function
@version 1.0 
@author g.sampaio
@since 08/08/2021
@param cFilialOri, character, filial de origem da integracao
@param cContratoOri, character, contrato de origem da integracao
@param nOperacao, numeric, operacao realizada (1=validacao do cancelamento;2=cancelamento)
@return logical, retorno sobre a validacao
/*/
Static Function ValContratoInt( cFilialOri, cContratoOri, nOperacao, cCodCan )

	Local lRetorno 			:= .T.
	Local oIntegraEmpresas	:= Nil

	Default cFilialOri		:= ""
	Default cContratoOri	:= ""
	Default nOperacao		:= 0
	Default cContrato		:= ""

	// inicio a classe de integracao de empresas
	oIntegraEmpresas	:= IntegraEmpresas():New(cFilialOri, cContratoOri)

	// valido se existe integracao
	if oIntegraEmpresas:ValidaIntegracao()

		// valido se existe enderecamento
		if nOperacao == 1 .And. oIntegraEmpresas:EnderecoIntegracao()
			lRetorno := .F.
			Help(,,'Help - INTEGRACAOEMPRESAS',,"Existe endereçamento ativo para o contrato na filial de cemitério, operação não permitida!",1,0)
		elseIf nOperacao == 2 // cancelo o contrato
			oIntegraEmpresas:CancelaContrato(cCodCan)
		endIf

	endIf

	FreeObj(oIntegraEmpresas)
	oIntegraEmpresas := Nil

Return(lRetorno)
