#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} UVIND12
Tela de Alteração da Forma de Pagamento do Contrato
@type function
@version 1.0
@author Wellington Gonçalves
@since 12/03/2019
@param cCodModulo, character, codigo do modulo
@return logical, retorno logico da funcao
/*/
User Function UVIND12(cCodModulo)

	Local oCodForPgto	:= NIL
	Local oDesForPgto	:= NIL
	Local oButton1		:= NIL
	Local oButton2		:= NIL
	Local aArea			:= GetArea()
	Local lContinua		:= .T.
	Local lRet			:= .T.
	Local cStatus		:= ""
	Local cContrato		:= ""
	Local cCodCli		:= ""
	Local cLoja			:= ""
	Local cOldForPg		:= ""
	Local cNewForPg		:= Space(TamSX3("E1_XFORPG")[1])
	Local cDescFor		:= Space(40)
	Local cFilInc		:= ""
	Local cIntContrato	:= ""
	Local oSX5			:= UGetSxFile():New
	Local aSX5			:= {}
	Static oDlgForPgto	:= NIL

	if cCodModulo == "F" // funerária

		cStatus 	:= UF2->UF2_STATUS
		cOldForPg	:= UF2->UF2_FORPG
		cContrato	:= UF2->UF2_CODIGO
		cCodCli		:= UF2->UF2_CLIENT
		cLoja		:= UF2->UF2_LOJA
		cFilInc		:= UF2->UF2_MSFIL
	elseif cCodModulo == "C" // cemitério

		cStatus 	:= U00->U00_STATUS
		cOldForPg	:= U00->U00_FORPG
		cContrato	:= U00->U00_CODIGO
		cCodCli		:= U00->U00_CLIENT
		cLoja		:= U00->U00_LOJA
		cFilInc		:= U00->U00_MSFIL

		if U00->(FieldPos("U00_TPCONT")) > 0
			cIntContrato := U00->U00_TPCONT
		endIf
	endif

	If cStatus == "C" //Cancelado
		MsgInfo("O Contrato já se encontra Cancelado, operação não permitida.","Atenção")
		lContinua := .F.
	ElseIf cStatus == "P" //Pré-cadastro
		MsgInfo("O Contrato se encontra Pré-cadastrado, operação não permitida.","Atenção")
		lContinua := .F.
	ElseIf cStatus == "F" //Finalizado
		MsgInfo("O Contrato se encontra Finalizado, operação não permitida.","Atenção")
		lContinua := .F.
	ElseIf cFilAnt != cFilInc
		MsgInfo("Alteracao da forma de pagamento so é permitida na filial onde foi incluido o contrato.","Atenção")
		lContinua := .F.
	EndIf

	// contrato de integracao de empresas
	if lContinua .And. cStatus == "A" .And. cIntContrato == "2"
		MsgInfo("O Contrato de Integração de Empresas, operação não permitida.","Atenção")
		lContinua := .F.
	endIf

	If lContinua

		//valido se o cliente possui titulos em aberto
		If  U_VlContra(cContrato,cCodModulo,cFilInc)

			// inicializo com a forma de pagamento atual do contrato
			cNewForPg 	:= cOldForPg
			aSX5		:= oSX5:GetInfoSX5("24",cNewForPg)
			cDescFor	:= aSX5[1,2]:cDescricao

			DEFINE MSDIALOG oDlgForPgto TITLE "Alteração da Forma de Pagamento" From 0,0 TO 120,600 PIXEL

			@ 005,005 SAY oSay1 PROMPT "Código" SIZE 030, 007 OF oDlgForPgto COLORS 0, 16777215 PIXEL
			@ 018,005 MSGET oCodForPgto VAR cNewForPg SIZE 040,007 PIXEL OF oDlgForPgto PICTURE "@!" Valid(ValForPgto(cNewForPg,@cDescFor,oCodForPgto)) F3 "24" HASBUTTON

			@ 005,055 SAY oSay2 PROMPT "Descrição" SIZE 030, 007 OF oDlgForPgto COLORS 0, 16777215 PIXEL
			@ 018,055 MSGET oDesForPgto VAR cDescFor SIZE 243,007 PIXEL OF oDlgForPgto PICTURE "@!" WHEN .F.

			//Linha horizontal
			@ 030, 005 SAY oSay3 PROMPT Repl("_",292) SIZE 292, 007 OF oDlgForPgto COLORS CLR_GRAY, 16777215 PIXEL

			//Botoes
			@ 045, 205 BUTTON oButton1 PROMPT "Confirmar" SIZE 040, 010 OF oDlgForPgto;
				ACTION FWMsgRun(,{|oSay| AltForPgto(cCodModulo,cContrato,cCodCli,cLoja,cOldForPg,cNewForPg)},;
				'Aguarde...','Alterando a Forma de Pagamento...') PIXEL
			@ 045, 255 BUTTON oButton2 PROMPT "Fechar" SIZE 040, 010 OF oDlgForPgto ACTION oDlgForPgto:End() PIXEL

			ACTIVATE MSDIALOG oDlgForPgto CENTERED

		endif
	Endif

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} AltForPgto
Tela de Alteração da Forma de Pagamento do Contrato
@type function
@version 1.0
@author g.sampaio
@since 12/03/2019
@param cCodModulo, character, codigo do modulo
@param cContrato, character, codigo do contrato
@param cCodCli, character, codigo do cliente
@param cLoja, character, loja do cliente
@param cOldForPg, character, forma de pagamento anterior
@param cNewForPg, character, forma de pagamento nova
@return logical, retorno logico da funcao
/*/
Static Function AltForPgto(cCodModulo,cContrato,cCodCli,cLoja,cOldForPg,cNewForPg)

	Local aArea				:= GetArea()
	Local aAreaU60			:= U60->(GetArea())
	Local lRet				:= .T.
	Local cOrigem			:= "UVIND12"
	Local cOrigemDesc		:= "Alteracao de Forma Pagamento"
	Local lMesmoContrato	:=  .F.

	if MsgYesNo("Deseja alterar a Forma de Pagamento do Contrato?","Atenção!")

		if cOldForPg <> cNewForPg

			Begin Transaction

				// se a forma de pagamento anterior está vinculada a um método de pagamento Vindi
				if !Empty(cOldForPg)

					U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
					if U60->(MsSeek(xFilial("U60") + cOldForPg))

						//-- Verifica se existe pendencias de processamentos VINDI --//
						lRet := U_PENDVIND(cContrato, cCodModulo)

						If lRet

							U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG

							//Em caso de cemiterio so arquivo o cliente se a taxa de manutencao nao for recorrente
							if !(cCodModulo == "C" .And. U60->(MsSeek(xFilial("U60") + U00->U00_FPTAXA)))

								// Envia arquivamento do cliente para Vindi
								lRet := U_UVIND20( cCodModulo, cContrato, cCodCli, cLoja, cOrigem, cOrigemDesc)

							elseif cCodModulo == "C"

								//excluo apenas os titulos da recorrencia
								lRet := U_UExcTitulosVindi(cContrato,.F.)

							endif

						EndIf

					endif

				endif

				if lRet

					U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
					if U60->(MsSeek(xFilial("U60") + cNewForPg))

						// se a nova forma de pagamento estiver vinculada a um metodo de pagamento VINDI.
						if !Empty(cNewForPg)

							// atualiza a forma de pagamento do contrato
							U_AtuCtr(cCodModulo,cContrato,cNewForPg)

							U60->(DbSetOrder(2)) // U60_FILIAL + U60_FORPG
							if U60->(MsSeek(xFilial("U60") + cNewForPg))

								// se o metodo de pagamento estiver ativo
								if U60->U60_STATUS == "A"

									lRet := U_RecNaoExist(cCodCli, cLoja,cContrato,@lMesmoContrato)

									//verifico se nao possui outro contrato do mesmo cliente na recorrencia, ou se o
									//contrato que esta na recorrencia e o atual
									If lRet .And. !lMesmoContrato
										// tela para preenchimento do perfil de pagamento
										FWMsgRun(,{|oSay| lRet := IncPerfil()},'Aguarde...','Abrindo Perfil de Pagamento...')
									EndIf

								endif

							endif

							if lRet

								// função que atualiza a forma de pagamento dos títulos a receber
								lRet := U_AtuTit(cCodModulo,cContrato,cOldForPg,cNewForPg)

								if lRet
									// função que altera a forma de pagamento dos títulos em aberto
									// envia a inclusao das faturas para vindi com a nova forma de pagamento
									U_IncFatVindi(cCodModulo,cContrato,cNewForPg)
								else

									DisarmTransaction()

								endif

							Else

								DisarmTransaction()
							endif

						endif

						//Nao é titulo da vindi
					else

						// atualiza a forma de pagamento do contrato
						U_AtuCtr(cCodModulo,cContrato,cNewForPg)

						// função que atualiza a forma de pagamento dos títulos a receber
						lRet := U_AtuTit(cCodModulo,cContrato,cOldForPg,cNewForPg)

						if !lRet

							DisarmTransaction()

						endif

					endif

				endif

			End Transaction

		endif

		oDlgForPgto:End()

	endif

	RestArea(aAreaU60)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} IncPerfil
Abertura de cadastro MVC de Perfil de Pagamento	
@type function
@version 1.0
@author Wellington Gonçalves
@since 12/03/2019
@return logical, retorno logico da funcao
/*/
Static Function IncPerfil()

	Local lRet := .T.

	nInc := FWExecView('INCLUIR','UVIND07',3,,{|| .T. })

	if nInc <> 0
		MsgInfo("A Inclusão do Perfil de Pagamento não foi realizada. Não será possível realizar a alteração da Forma de Pagamento!","Atenção!")
		lRet := .F.
	endif

Return(lRet)

/*/{Protheus.doc} IncFatVindi
Função que inclui as Faturas na Vindi
@type function
@version 1.0
@author Wellington Gonçalves
@since 12/03/2019
@param cCodModulo, character, codigo do modulo
@param cContrato, character, codigo do contrato
@param cForPgto, character, forma de pagamento
@return logical, retorno logico da funcao
/*/
User Function IncFatVindi(cCodModulo,cContrato,cForPgto)

	Local aArea 		:= GetArea()
	Local aAreaSE1 		:= SE1->(GetArea())
	Local cQry			:= ""
	Local cPulaLinha	:= chr(13)+chr(10)
	Local oVindi		:= NIL
	Local cOrigem		:= "UVIND12"
	Local cOrigemDesc	:= "Alteracao para Recorrencia"
	Local cTipoMnt		:= SuperGetMv("MV_XTIPOMN",.F.,"MNT")

	// verifico se existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	cQry := " SELECT "										   + cPulaLinha
	cQry += " SE1.E1_FILIAL AS FIL_TIT, "                      + cPulaLinha
	cQry += " SE1.E1_PREFIXO AS PREFIXO, "                     + cPulaLinha
	cQry += " SE1.E1_NUM AS NUM, "                             + cPulaLinha
	cQry += " SE1.E1_PARCELA AS PARCELA, "                     + cPulaLinha
	cQry += " SE1.E1_TIPO AS TIPO, "                           + cPulaLinha
	cQry += " SE1.E1_CLIENTE AS CLIENTE, "                     + cPulaLinha
	cQry += " SE1.E1_LOJA AS LOJA "                            + cPulaLinha
	cQry += " FROM "                                           + cPulaLinha
	cQry += " " + RetSqlName("SE1") + " SE1 "                  + cPulaLinha
	cQry += " WHERE "                                          + cPulaLinha
	cQry += " SE1.D_E_L_E_T_ <> '*' "                          + cPulaLinha
	cQry += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "   + cPulaLinha
	cQry += " AND SE1.E1_XFORPG = '" + cForPgto + "' "         + cPulaLinha
	cQry += " AND SE1.E1_SALDO  > 0 "                          + cPulaLinha
	cQry += " AND SE1.E1_VENCTO > '"+ dTos(dDataBase)  + "'"   + cPulaLinha
	cQry += " AND SE1.E1_XCONCTR = ' ' "                       + cPulaLinha
	cQry += " AND SE1.E1_TIPO NOT IN ( "                       + cPulaLinha
	cQry += " 	'AB-','FB-','FC-','FU-','IR-', "               + cPulaLinha
	cQry += " 	'IN-','IS-','PI-','CF-','CS-', "               + cPulaLinha
	cQry += " 	'FE-','IV-','PR','PA','RA','NCC','NDC' "       + cPulaLinha
	cQry += " ) "                                              + cPulaLinha

	if cCodModulo == "C" // cemitério
		cQry += " AND SE1.E1_XCONTRA = '" + cContrato + "' "   	+ cPulaLinha

		//se chamado de alteracao de forma de pagamento, nao modifico titulos de manutencao
		if IsInCallStack("AltForPgto")

			cQry += " AND SE1.E1_TIPO <> '" + cTipoMnt + "' "		+ cPulaLinha

		endif

	elseif cCodModulo == "F" // funerária
		cQry += " AND SE1.E1_XCTRFUN = '" + cContrato + "' "   + cPulaLinha
	endif

	// crio o alias temporario
	TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query

	// se existir contratos da funerária vinculados ao cliente
	if QRY->(!Eof())

		// crio o objeto de integracao com a vindi
		oVindi := IntegraVindi():New()

		While QRY->(!Eof())

			// envia exclusão do título na vindi
			oVindi:IncluiTabEnvio(cCodModulo,"3","I",1,QRY->FIL_TIT + QRY->PREFIXO + QRY->NUM + QRY->PARCELA + QRY->TIPO,/*aProc*/,cOrigem,cOrigemDesc)

			QRY->(DbSkip())

		Enddo

	endif

	// verifico se existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	RestArea(aAreaSE1)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} AtuTit
Função que atualiza a forma de pagamento dos titulos	
@type function
@version 1.0
@author Wellington Gonçalves
@since 12/03/2019
@param cCodModulo, character, codigo do modulo
@param cContrato, character, codigo do contrato
@param cOldForPg, character, forma de pagamento anterior
@param cNewForPg, character, forma de pagamento nova
@param cErro, character, erro
@return logical, retorno logico da funcao
/*/
User Function AtuTit(cCodModulo,cContrato,cOldForPg,cNewForPg,cErro)
	Local aArea 		:= GetArea()
	Local aAreaSE1		:= SE1->(GetArea())
	Local cQry			:= ""
	Local cPulaLinha	:= chr(13)+chr(10)
	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local cTipoMnt		:= SuperGetMv("MV_XTIPOMN",.F.,"MNT")
	Local lConsMesAtual	:= SuperGetMv("MV_XCONMAT",,.T.)
	Local lRet			:= .T.
	Local lContinua		:= .T.
	Local nNovoVlr		:= 0
	Local oVirtusFin 	:= Nil

	// verifico se existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	cQry := " SELECT "										   + cPulaLinha
	cQry += " SE1.E1_FILIAL AS FIL_TIT, "                      + cPulaLinha
	cQry += " SE1.E1_PREFIXO AS PREFIXO, "                     + cPulaLinha
	cQry += " SE1.E1_NUM AS NUM, "                             + cPulaLinha
	cQry += " SE1.E1_PARCELA AS PARCELA, "                     + cPulaLinha
	cQry += " SE1.E1_TIPO AS TIPO, "                           + cPulaLinha
	cQry += " SE1.E1_CLIENTE AS CLIENTE, "                     + cPulaLinha
	cQry += " SE1.E1_LOJA AS LOJA "                            + cPulaLinha
	cQry += " FROM "                                           + cPulaLinha
	cQry += " " + RetSqlName("SE1") + " SE1 "                  + cPulaLinha
	cQry += " WHERE "                                          + cPulaLinha
	cQry += " SE1.D_E_L_E_T_ <> '*' "                          + cPulaLinha
	cQry += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "   + cPulaLinha
	cQry += " AND SE1.E1_SALDO > 0 "                           + cPulaLinha
	cQry += " AND SE1.E1_XCONCTR = ' ' "                       + cPulaLinha
	cQry += " AND SE1.E1_TIPO NOT IN ( "                       + cPulaLinha
	cQry += " 	'AB-','FB-','FC-','FU-','IR-', "               + cPulaLinha
	cQry += " 	'IN-','IS-','PI-','CF-','CS-', "               + cPulaLinha
	cQry += " 	'FE-','IV-','PR','PA','RA','NCC','NDC' "       + cPulaLinha
	cQry += " ) "                                              + cPulaLinha

	if cCodModulo == "C" // cemitério
		cQry += " AND SE1.E1_XCONTRA = '" + cContrato + "' "   + cPulaLinha
		cQry += " AND SE1.E1_TIPO <> '" + cTipoMnt + "' "

	elseif cCodModulo == "F" // funerária
		cQry += " AND SE1.E1_XCTRFUN = '" + cContrato + "' "   + cPulaLinha
	endif

	//valido se considera o mes atual atual ou somente o mes subsequente para alterar as parcelas
	if lConsMesAtual
		cQry += " AND SUBSTRING(SE1.E1_VENCTO,1,6) >= '" + AnoMes(dDataBase) + "' "	+ cPulaLinha
	else
		cQry += " AND SUBSTRING(SE1.E1_VENCTO,1,6) > '" + AnoMes(dDataBase) + "' "	+ cPulaLinha
	endif

	// crio o alias temporario
	MPSysOpenQuery(cQry, "QRY") // Cria uma nova area com o resultado do query

	// se existir contratos da funerária vinculados ao cliente
	if QRY->(!Eof())

		//-- Verifica se existe regra de desconto para nova forma de pagamento
		//-- Obtem o novo valor descontado conforme regra
		if lFuneraria
			nNovoVlr := RegraDescon(cContrato,cNewForPg,cOldForPg)
		endif

		While QRY->(!Eof())

			oVirtusFin := VirtusFin():New()

			SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
			if SE1->(MsSeek(QRY->FIL_TIT + QRY->PREFIXO + QRY->NUM + QRY->PARCELA + QRY->TIPO))

				lContinua := oVirtusFin:MarcaExcessaoSK1(SE1->(Recno()))

				If lContinua

					lContinua := oVirtusFin:ExcBordTit(SE1->(Recno()))

					If lContinua

						//-- Novo valor das parcelas segundo regras de desconto
						if nNovoVlr > 0 .And. lRet

							lRet := AltVlrSE1(nNovoVlr, cNewForPg, @oVirtusFin, @cErro)

							//se ocorreu erro na atualizacao do titulo, aborto a transacao
							if !lRet
								Exit
							endif

						endif

						//-- Devido a ponto de entrada recorrencia
						if SE1->(MsSeek(QRY->FIL_TIT + QRY->PREFIXO + QRY->NUM + QRY->PARCELA + QRY->TIPO))
							RecLock("SE1", .F.)
							SE1->E1_XFORPG	:= AllTrim(cNewForPg) //-- Atualiza a forma de pagamento
							SE1->(MsUnLock())
						endif

					Else
						lRet := .F.
						Exit

					EndIf

				Else
					lRet := .F.
					Exit
				EndIf

			endif

			FreeObj(oVirtusFin)
			oVirtusFin := Nil

			QRY->(DbSkip())
		Enddo

	endif

	// verifico se existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	RestArea(aAreaSE1)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} AtuCtr
Função que atualiza a forma de pagamento do contrato	
@type function
@version 1.0
@author Wellington Gonçalves
@since 12/03/2019
@param cCodModulo, character, param_description
@param cContrato, character, param_description
@param cFormPgto, character, param_description
@return variant, return_description
/*/
User Function AtuCtr(cCodModulo,cContrato,cFormPgto)

	Local lRet 			:= .F.

	if cCodModulo == "F"

		if RecLock("UF2",.F.)

			UF2->UF2_FORPG := cFormPgto
			UF2->(MsUnLock())

			lRet := .T.

		endif

	elseif cCodModulo == "C"

		if RecLock("U00",.F.)

			U00->U00_FORPG := cFormPgto
			U00->(MsUnLock())

			lRet := .T.

		endif

	endif

Return(lRet)

Static Function ValForPgto(cNewForPg,cDescFor,oCodForPgto)

	Local lRet 			:= .T.
	Local oSX5			:= UGetSxFile():New
	Local aSX5			:= {}

// limpo o campo da descrição do cancelamento
	cDescFor := Space(40)

// se o código estiver preenchido
	If !Empty(cNewForPg)

		aSX5 := oSX5:GetInfoSX5("24",cNewForPg)

		if Len(aSX5) > 0

			cDescFor	:= aSX5[1,2]:cDescricao
		Else
			MsgInfo("Forma de Pagamento Inválida.","Atenção")
			lRet := .F.
		Endif

	Endif

	oCodForPgto:Refresh()

Return(lRet)

/*/{Protheus.doc} ExcBord
Função que exclui o titulo do bordero	
@type function
@version 1.0
@author Wellington Gonçalves
@since 12/03/2019
/*/
Static Function ExcBord()

	Local aArea		:= GetArea()
	Local aAreaSEA	:= SEA->(GetArea())

	SEA->(DbSetOrder(1)) //EA_FILIAL+EA_NUMBOR+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA
	If SEA->(MsSeek(xFilial("SEA") + SE1->E1_NUMBOR + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO))

		if RecLock("SEA",.F.)
			SEA->(DbDelete())
			SEA->(MsUnlock())
		endif

	Endif

	RestArea(aArea)
	RestArea(aAreaSEA)

Return(Nil)

/*/{Protheus.doc} RecNaoExist
Verifica se existe contrato em recorrência ativo para cliente
@type function
@version 1.0
@author nata.queiroz
@since 10/04/2020
@param cCodCli, character
@param cLoja, character
@param cContrato, character
@param lMesmoContrato, Logical

@return lRet, logic
/*/
User Function RecNaoExist(cCodCli, cLoja,cContrato,lMesmoContrato)
	Local lRet := .T.
	Local cQry := ""
	Local cFilCtr := cFilAnt
	Local cMsg := ""
	Local aSoluc := {}

	Default cContrato	:= ""
	Default lMesmoContrato	:= .F.

	cQry := "SELECT U61_CONTRA CONTRATO "
	cQry += "FROM " + RetSqlName("U61")
	cQry += "WHERE D_E_L_E_T_ <> '*' "
	cQry += "AND U61_MSFIL = '"+ cFilCtr +"' "
	cQry += "AND U61_STATUS = 'A' " //-- Ativo
	cQry += "AND U61_CLIENT = '"+ cCodCli +"' "
	cQry += "AND U61_LOJA = '"+ cLoja +"' "

	cQry := ChangeQuery(cQry)

	If Select("U61REC") > 0
		U61REC->( dbCloseArea() )
	EndIf

	MPSysOpenQuery(cQry, "U61REC")

	If U61REC->(!Eof())

		cCodCtr := AllTrim(U61REC->CONTRATO)

		if cCodCtr <> cContrato

			lRet := .F.

			cMsg := "Já existe contrato em recorrência para o cliente informado. Nr. Ctr.: " + cCodCtr
			aSoluc := {"Retire o contrato vigente da recorrência para poder incluir novo contrato."}
			Help(Nil, Nil, "Atenção!", Nil, cMsg, 1, 0, Nil, Nil, Nil, Nil, Nil, aSoluc)
		else
			lMesmoContrato := .T.
		endif

	EndIf

	If Select("U61REC") > 0
		U61REC->( dbCloseArea() )
	EndIf

Return(lRet)

/*/{Protheus.doc} GrInstCob
Gera instrução de cobrança para baixar o título no banco
Obs.: A tabela SE1 deve estar posicionada no título antes da chamada da função
@type function
@version 1.0
@author nata.queiroz
@since 17/04/2020
/*/
Static Function GrInstCob()
	Local aAreaFI2  := FI2->( GetArea() )
	Local cMVForBol := Alltrim( SuperGetMv("MV_XFORBOL", .F., "BO") )
	Local cCodOcorr := "02" //-- PEDIDO/SOLICITACAO DE BAIXA
	Local cGerado   := "2"

	If AllTrim(SE1->E1_XFORPG) == cMVForBol;
			.And. !Empty(SE1->E1_NUMBCO);
			.And. !Empty(SE1->E1_IDCNAB)

		FI2->( DbSetOrder(1) )
		//FI2_FILIAL+FI2_CARTEI+FI2_NUMBOR+FI2_PREFIX+FI2_TITULO
		//+FI2_PARCEL+FI2_TIPO+FI2_CODCLI+FI2_LOJCLI+FI2_OCORR+FI2_GERADO
		If !FI2->(MsSeek(xFilial("FI2")+SE1->E1_SITUACA;
				+SE1->(E1_NUMBOR+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA+cCodOcorr+cGerado)))

			If RecLock("FI2", .T.)
				FI2->FI2_FILIAL := SE1->E1_FILIAL
				FI2->FI2_DTOCOR := dDataBase
				FI2->FI2_OCORR  := cCodOcorr
				FI2->FI2_DESCOC := "SOLICITACAO DE BAIXA"
				FI2->FI2_PREFIX := SE1->E1_PREFIXO
				FI2->FI2_TITULO := SE1->E1_NUM
				FI2->FI2_PARCEL := SE1->E1_PARCELA
				FI2->FI2_TIPO   := SE1->E1_TIPO
				FI2->FI2_CODCLI := SE1->E1_CLIENTE
				FI2->FI2_LOJCLI := SE1->E1_LOJA
				FI2->FI2_TIPCPO := "C"
				FI2->FI2_CAMPO  := "E1_HIST   "
				FI2->FI2_VALANT := "00"
				FI2->FI2_VALNOV := cCodOcorr
				FI2->FI2_NUMBOR := SE1->E1_NUMBOR
				FI2->FI2_CARTEI := SE1->E1_SITUACA
				FI2->FI2_DTGER  := Date()
				FI2->FI2_GERADO := cGerado
				FI2->FI2_SEQ    := ""
				FI2->(MsUnLock())
			EndIf

		EndIf

	EndIf

	RestArea( aAreaFI2 )

Return

/*/{Protheus.doc} RegraDescon
Verifica regras de desconto para forma de pagamento e calcula novo valor do contrato
@type function
@version 12.1.25
@author nata.queiroz
@since 27/06/2020
@param cContrato, character, codigo do contrato
@param cNewForPg, character, nova forma de pagamento
@param cOldForPg, character, antiga forma de pagamento
@return numeric, novo valor da parcela do contrato
/*/
Static Function RegraDescon(cContrato,cNewForPg,cOldForPg)

	Local aArea 		:= GetArea()
	Local aAreaUF2 		:= UF2->( GetArea() ) //-- Contratos
	Local aAreaUJZ 		:= UJZ->( GetArea() ) //-- Regras Desconto Forma Pagto
	Local nValor 		:= 0
	Local cRegra 		:= ""
	Local cTpDesc 		:= ""
	Local nVlrRegra 	:= 0
	Local nVlrReal 		:= 0
	Local nDescon 		:= 0
	Local aHistDados 	:= {}
	Local aCampos 		:= {}
	Local nX 			:= 0

	UF2->( dbSetOrder(1) ) //-- UF2_FILIAL+UF2_CODIGO
	If UF2->( MsSeek(xFilial("UF2") + cContrato) )
		cRegra := UF2->UF2_REGRA

		//-- Obtem valores para historico de alteracao
		AADD(aHistDados, { "UF2", UF2->UF2_CODIGO, "UF2_VALOR", UF2->UF2_VALOR, Nil })
		AADD(aHistDados, { "UF2", UF2->UF2_CODIGO, "UF2_DESCON", UF2->UF2_DESCON, Nil })
		AADD(aHistDados, { "UF2", UF2->UF2_CODIGO, "UF2_DESREG", UF2->UF2_DESREG, Nil })
		AADD(aHistDados, { "UF2", UF2->UF2_CODIGO, "UF2_FORPG", cOldForPg, Nil })

		//-- Remove desconto de regra
		If UF2->UF2_DESREG > 0
			RecLock("UF2", .F.)
			UF2->UF2_VALOR += UF2_DESREG
			UF2->UF2_DESCON -= UF2_DESREG
			UF2->UF2_DESREG := 0
			UF2->( MsUnLock() )

			//-- Novo valor do contrato
			nValor := UF2->UF2_VALOR
		EndIf

		//-- Aplica desconto de regra, caso houver regra cadastrada
		UJZ->( dbSetOrder(2) ) //-- UJZ_FILIAL+UJZ_CODIGO+UJZ_FORPG
		If UJZ->( MsSeek(xFilial("UJZ") + cRegra + cNewForPg) )

			cTpDesc 	:= UJZ->UJZ_TPDESC
			nVlrRegra 	:= UJZ->UJZ_VALOR
			nVlrReal 	:= (UF2->UF2_VALOR + UF2->UF2_VLADIC)

			If cTpDesc == "R"
				nDescon := nVlrRegra
			Else
				nDescon := ((nVlrReal * nVlrRegra) / 100)
			EndIf

			If !IsBlind() .And. !FWIsInCallStack("U_RUTIL22A")
				MsgInfo('Este contrato receberá um desconto de R$ ';
					+ AllTrim(TRANSFORM(nDescon, PesqPict('SE1', 'E1_VALOR')));
					+ ' segundo regras de desconto vigentes.', 'Regras de Contrato')
			EndIf

			//-- Novo valor do contrato
			nValor := nVlrReal - nDescon

			If nValor > 0
				RecLock("UF2", .F.)
				UF2->UF2_VALOR	-= nDescon
				UF2->UF2_DESCON += nDescon
				UF2->UF2_DESREG := nDescon
				UF2->( MsUnlock() )
			EndIf
		EndIf

		//-- Obtem valores alterados para historico
		aHistDados[1][5] := UF2->UF2_VALOR
		aHistDados[2][5] := UF2->UF2_DESCON
		aHistDados[3][5] := UF2->UF2_DESREG
		aHistDados[4][5] := AllTrim(cNewForPg)

		For nX := 1 To Len(aHistDados)
			If aHistDados[nX][4] <> aHistDados[nX][5]
				AADD(aCampos, RetAltCpo(aHistDados[nX][1], aHistDados[nX][2],;
					aHistDados[nX][3], aHistDados[nX][4], aHistDados[nX][5]) )
			EndIf
		Next nX

		//-- Se houve alteracao, grava historico
		GravaHist(aCampos)

	EndIf

	RestArea(aArea)
	RestArea(aAreaUF2)
	RestArea(aAreaUJZ)

Return(nValor)

/*/{Protheus.doc} GravaHist
Grava historico de alteracoes realizadas no cabecalho do contrato
@type function
@version 12.1.25
@author nata.queiroz
@since 30/06/2020
@param aCampos, array
/*/
Static Function GravaHist(aCampos)
	Local aArea 		:= GetArea()
	Local cCodigo		:= ""
	Local cUsuario		:= RetCodUsr()
	Local nX			:= 0
	Local nY			:= 0

	Default aCampos := {}

	if Len(aCampos) > 0

		cCodigo := GetSXENum("U68","U68_CODIGO")

		///////////////////////////////////////////////////////////////////////
		/////////////////////   CABEÇALHO DA ALTERAÇÃO   //////////////////////
		///////////////////////////////////////////////////////////////////////
		if RecLock("U68",.T.)
			U68->U68_FILIAL 	:= xFilial("U68")
			U68->U68_CODIGO 	:= cCodigo
			U68->U68_DATA  		:= dDataBase
			U68->U68_HORA  		:= SubStr(Time(),1,5)
			U68->U68_TIPO		:= "C" // C=Contrato;R=Reajuste;E=Exclusao do Reajuste
			U68->U68_CONTRA		:= UF2->UF2_CODIGO
			U68->U68_CLIENT		:= UF2->UF2_CLIENT
			U68->U68_LOJA		:= UF2->UF2_LOJA
			U68->U68_CODUSR		:= cUsuario

			// confirmo a numeração
			U68->(ConfirmSx8())
		endif

		///////////////////////////////////////////////////////////////////////
		/////////////////////////   CAMPOS ALTERADOS   ////////////////////////
		///////////////////////////////////////////////////////////////////////
		For nX := 1 To Len(aCampos)

			if RecLock("U73",.T.)

				U73->U73_FILIAL := xFilial("U73")
				U73->U73_CODIGO	:= cCodigo

				For nY := 1 To Len(aCampos[nX])
					U73->&(aCampos[nX,nY,1]) := aCampos[nX,nY,2]
				Next nY

				U73->(MsUnLock())

			endif

		Next nX

	endif

	RestArea(aArea)
Return

/*/{Protheus.doc} RetAltCpo
Retorna array estruturado para gravacao do historico de alteracao de campo
@type function
@version 12.1.25
@author nata.queiroz
@since 30/06/2020
@param cAliasUtil, character
@param cChave, character
@param cCampoAlias, character
@param xVlrAnt, dynamic
@param xVlrPos, dynamic
@return aItens, array
/*/
Static Function RetAltCpo(cAliasUtil, cChave, cCampoAlias, xVlrAnt, xVlrPos)
	Local cTipo := TamSX3(cCampoAlias)[3]
	Local aItens := {}

	Default cAliasUtil := ""
	Default cChave := ""
	Default cCampoAlias := ""
	Default xVlrAnt := Nil
	Default xVlrPos := Nil

	if !Empty(cAliasUtil) .And. !Empty(cTipo)
		aadd(aItens,{"U73_ALIAS"	, cAliasUtil})
		aadd(aItens,{"U73_CHAVE"	, cChave})
		aadd(aItens,{"U73_TIPCPO"	, cTipo})
		aadd(aItens,{"U73_CAMPO"	, cCampoAlias })

		if cTipo == "C"

			aadd(aItens,{"U73_CVLANT"	, xVlrAnt})
			aadd(aItens,{"U73_CVLPOS"	, xVlrPos})

		elseif cTipo == "N"

			aadd(aItens,{"U73_NVLANT"	, xVlrAnt})
			aadd(aItens,{"U73_NVLPOS"	, xVlrPos})

		elseif cTipo == "D"

			aadd(aItens,{"U73_DVLANT"	, xVlrAnt})
			aadd(aItens,{"U73_DVLPOS"	, xVlrPos})

		elseif cTipo == "L"

			aadd(aItens,{"U73_LVLANT"	, xVlrAnt})
			aadd(aItens,{"U73_LVLPOS"	, xVlrPos})

		elseif cTipo == "M"

			aadd(aItens,{"U73_MVLANT"	, xVlrAnt})
			aadd(aItens,{"U73_MVLPOS"	, xVlrPos})

		endif
	endif

Return aItens

/*/{Protheus.doc} AltVlrSE1
Altera valor do titulo na tabela SE1 (ExecAuto FINA040)
Registro deve estar posicionado na tabela antes de chamar a funcao
@type function
@version 12.1.25
@author nata.queiroz
@since 01/07/2020
@param nNovoVlr, numeric, nNovoVlr
@param cErro, character, cErro
@return logical, lRet
/*/
Static Function AltVlrSE1(nNovoVlr, cNewForPg, oVirtusFin, cErro)

	Local aArea			:= GetArea()
	Local aAreaSE1		:= SE1->(GetArea())
	Local lRet 			:= .T.
	Local aTitulo		:= {}

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	Default nNovoVlr 	:= 0
	Default cNewForPg 	:= ""
	Default cErro 		:= ""

	aadd(aTitulo, {"E1_FILIAL"	, SE1->E1_FILIAL 	, Nil } )
	aadd(aTitulo, {"E1_PREFIXO"	, SE1->E1_PREFIXO	, Nil } )
	aadd(aTitulo, {"E1_NUM"		, SE1->E1_NUM    	, Nil } )
	aadd(aTitulo, {"E1_PARCELA"	, SE1->E1_PARCELA	, Nil } )
	aadd(aTitulo, {"E1_TIPO"	, SE1->E1_TIPO   	, Nil } )
	aadd(aTitulo, {"E1_CLIENTE"	, SE1->E1_CLIENTE	, Nil } )
	aadd(aTitulo, {"E1_LOJA"	, SE1->E1_LOJA   	, Nil } )
	aadd(aTitulo, {"E1_XPARCON"	, SE1->E1_XPARCON	, Nil } )
	aadd(aTitulo, {"E1_NATUREZ"	, SE1->E1_NATUREZ	, Nil } )
	aadd(aTitulo, {"E1_EMISSAO"	, SE1->E1_EMISSAO	, Nil } )
	aadd(aTitulo, {"E1_VENCTO"	, SE1->E1_VENCTO 	, Nil } )
	aadd(aTitulo, {"E1_VENCREA"	, SE1->E1_VENCREA	, Nil } )
	aadd(aTitulo, {"E1_VALOR"	, nNovoVlr       	, Nil } )
	aadd(aTitulo, {"E1_XCTRFUN"	, SE1->E1_XCTRFUN	, Nil } )
	aadd(aTitulo, {"E1_XFORPG"	, cNewForPg 		, Nil } )
	aadd(aTitulo, {"E1_VEND1"  	, SE1->E1_VEND1  	, Nil } )
	aadd(aTitulo, {"E1_PORTADO"	, SE1->E1_PORTADO	, Nil } )
	aadd(aTitulo, {"E1_AGEDEP" 	, SE1->E1_AGEDEP 	, Nil } )
	aadd(aTitulo, {"E1_CONTA"  	, SE1->E1_CONTA  	, Nil } )
	aadd(aTitulo, {"E1_IDCNAB" 	, SE1->E1_IDCNAB 	, Nil } )
	aadd(aTitulo, {"E1_CODBAR" 	, SE1->E1_CODBAR 	, Nil } )

	//-- Exclui titulo
	lRet := oVirtusFin:ExcluiTituloFin(SE1->(Recno()), Nil, Nil, @cErro) 

	if lRet

		lMsErroAuto := .F.
		lMsHelpAuto := .T.

		//-- Inclui titulo novamente com valor ajustado
		MSExecAuto({|x,y| FINA040(x,y)}, aTitulo, 3) //-- 3 – Inclusao, 4 – Alteração, 5 – Exclusão

		if lMsErroAuto
			lRet := .F.

			If !IsBlind()
				MostraErro()
			Else
				cErro := AllTrim( MostraErro('/temp') )
			EndIf

			DisarmTransaction()
		endif
	endif

	RestArea(aAreaSE1)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} ExcTitulosVindi
Funcao para excluir os titulos da recorrencia
em caso de retirada da recorrencia apenas da forma de pagamento
das parcelas e continuacao em recorrencia da taxa de manutencao
@type function
@version 12.1.27
@author Raphael Martins
@since 24/01/2022
@param cContrato, character, cContrato
@param lManutencao, Logical, cContrato
@param cOrigem, character, cOrigem
@param cOrigemDesc, character, cOrigemDesc

@return logical, lRet
/*/

User Function UExcTitulosVindi(cContrato,lManutencao,cOrigem,cOrigemDesc)
	Local aArea			:= GetArea()
	Local aAreaU00		:= U00->(GetArea())
	Local aDadosProc	:= {}
	Local cQry			:= ""
	Local cTipoMnt		:= SuperGetMv("MV_XTIPOMN",.F.,"MNT")
	Local oVindi 		:= NIL
	Local cErro 		:= ""
	Local cJsonEnvio 	:= ""
	Local cCodRet 		:= ""
	Local cDescRetorno 	:= ""
	Local cDadosRetorno := ""
	Local cPulaLinha	:= chr(13)+chr(10)
	Local nIndice 		:= 1
	Local lRet			:= .T.

	Default cOrigem		:= "UVIND12"
	Default cOrigemDesc	:= "Alteracao Forma Pagamento(ExcTitulosVindi)"
	Default lManutencao	:= .F.

	oVindi := IntegraVindi():New()

// verifico se existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	cQry := " SELECT "										   	+ cPulaLinha
	cQry += " SE1.E1_FILIAL AS FIL_TIT, "                      	+ cPulaLinha
	cQry += " SE1.E1_PREFIXO AS PREFIXO, "                     	+ cPulaLinha
	cQry += " SE1.E1_NUM AS NUM, "                             	+ cPulaLinha
	cQry += " SE1.E1_PARCELA AS PARCELA, "                     	+ cPulaLinha
	cQry += " SE1.E1_TIPO AS TIPO, "                           	+ cPulaLinha
	cQry += " SE1.E1_CLIENTE AS CLIENTE, "                     	+ cPulaLinha
	cQry += " SE1.E1_LOJA AS LOJA "                            	+ cPulaLinha
	cQry += " FROM "                                           	+ cPulaLinha
	cQry += " " + RetSqlName("SE1") + " SE1 "                  	+ cPulaLinha
	cQry += " WHERE "                                         	+ cPulaLinha
	cQry += " SE1.D_E_L_E_T_ <> '*' "                          	+ cPulaLinha
	cQry += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "   	+ cPulaLinha
	cQry += " AND SE1.E1_SALDO > 0 "                           	+ cPulaLinha
	cQry += " AND SE1.E1_XCONCTR = ' ' "                       	+ cPulaLinha
	cQry += " AND SE1.E1_TIPO NOT IN ( "                       	+ cPulaLinha
	cQry += " 	'AB-','FB-','FC-','FU-','IR-', "               	+ cPulaLinha
	cQry += " 	'IN-','IS-','PI-','CF-','CS-', "               	+ cPulaLinha
	cQry += " 	'FE-','IV-','PR','PA','RA','NCC','NDC' "       	+ cPulaLinha
	cQry += " ) "                                              	+ cPulaLinha
	cQry += " AND SE1.E1_XCONTRA = '" + cContrato + "' "		+ cPulaLinha

	if !lManutencao
		cQry += " AND SE1.E1_TIPO <> '" + cTipoMnt + "' "			+ cPulaLinha
	else
		cQry += " AND SE1.E1_TIPO = '" + cTipoMnt + "' "			+ cPulaLinha
	endif

// verifico se existe este alias criado
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	EndIf

// crio o alias temporario
	TcQuery cQry New Alias "QRYSE1" // Cria uma nova area com o resultado do query

// se existir contratos da funerária vinculados ao cliente
	if QRYSE1->(!Eof())

		While QRYSE1->(!Eof())

			cChave := QRYSE1->FIL_TIT + QRYSE1->PREFIXO + QRYSE1->NUM + QRYSE1->PARCELA + QRYSE1->TIPO

			lRet := oVindi:ExcluiFatura("C",@cErro,@cJsonEnvio,@cCodRet,@cDescRetorno,@cDadosRetorno,nIndice,cChave)

			if lRet

				//-- Inclui historico de exclusão --//
				aDadosProc := {}
				AADD(aDadosProc , "C") // Status
				AADD(aDadosProc , cJsonEnvio) // Json Envio
				AADD(aDadosProc , cDadosRetorno) // Json Retorno
				AADD(aDadosProc , cCodRet) // Codigo do retorno
				AADD(aDadosProc , cDescRetorno) // Descrição do retorno

				oVindi:IncluiTabEnvio("C", "3", "E", nIndice, cChave, aDadosProc, cOrigem, cOrigemDesc)

				// Finaliza operacoes na tabela de envio Vindi (U62)
				U_UFinU62(xFilial("U61"), "C", cChave)

			else
				MsgAlert("Não foi possível remover o título " + cChave + " da recorrência.")
				lRet := .F.
				Exit
			endif

			QRYSE1->(DbSkip())
		EndDo

	endif

// verifico se existe este alias criado
	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	EndIf

	RestArea(aArea)
	RestArea(aAreaU00)

Return(lRet)
