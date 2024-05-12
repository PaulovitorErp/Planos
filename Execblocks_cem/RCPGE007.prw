#Include 'Protheus.ch'
#Include 'Topconn.ch'

/*/{Protheus.doc} RCPGE007
Rotina para replicar os dados alterados do cliente
para os contratos do mesmo	
@type function
@version 1.0
@author Raphael Martins
@since 27/07/2016
@param cCliente, character, codigo do cliente
@param cLoja, character, loja do cliente
/*/
User Function RCPGE007(cCliente,cLoja)

	Local aArea		:= GetArea()
	Local aAreaSA1	:= SA1->( GetArea() )
	Local aAreaU00	:= U00->( GetArea() )
	Local aAreaU02	:= U02->( GetArea() )
	Local cQuery 	:= ""
	Local nStart	:= 0

	SA1->( DbSetOrder(1) ) //A1_FILIAL + A1_COD + A1_LOJA
	If SA1->( MsSeek( xFilial("SA1") + cCliente + cLoja ) )

		U00->( DbSetOrder(8) ) //U00_FILIAL + U00_CLIENT + U00_LOJA
		If U00->( MsSeek( xFilial("U00") + cCliente + cLoja ) )

			While U00->( !EOF() ) .And. U00->U00_CLIENT == cCliente .And. U00->U00_LOJA == cLoja

				RecLock("U00",.F.)

				U00->U00_NOMCLI		:= SA1->A1_NOME
				U00->U00_NATURA		:= RetField("CC2",1,xFilial("CC2")+SA1->A1_XESTNAS+SA1->A1_XMUNNAT,"CC2_MUN")
				U00->U00_ESTCIV		:= SA1->A1_XESTCIV
				U00->U00_DTNASC		:= SA1->A1_XDTNASC
				U00->U00_PROFIS		:= SA1->A1_XPROFIS
				U00->U00_RG    		:= SA1->A1_PFISICA
				U00->U00_CGC   		:= SA1->A1_CGC
				U00->U00_CONJUG		:= SA1->A1_XCONJUG
				U00->U00_DDD   		:= SA1->A1_DDD
				U00->U00_TEL   		:= SA1->A1_TEL
				U00->U00_CEL   		:= SA1->A1_XCEL
				U00->U00_CONTAT		:= SA1->A1_XCONTAT
				U00->U00_TELCON		:= SA1->A1_XTELCON
				U00->U00_HRCONT		:= SA1->A1_XHRCONT
				U00->U00_EMAIL 		:= SA1->A1_EMAIL
				U00->U00_END   		:= SA1->A1_END
				U00->U00_COMPLE		:= SA1->A1_COMPLEM
				U00->U00_BAIRRO		:= SA1->A1_BAIRRO
				U00->U00_REFERE		:= SA1->A1_XREFERE
				U00->U00_MUN   		:= SA1->A1_MUN
				U00->U00_UF    		:= SA1->A1_EST
				U00->U00_CEP   		:= SA1->A1_CEP
				U00->U00_ENDCOB		:= SA1->A1_ENDCOB
				U00->U00_COMPCO		:= SA1->A1_XCOMPCO
				U00->U00_BAICOB		:= SA1->A1_BAIRROC
				U00->U00_REFCOB		:= SA1->A1_XREFCOB
				U00->U00_MUNCOB		:= SA1->A1_MUNC
				U00->U00_ESTCOB		:= SA1->A1_ESTC
				U00->U00_CEPCOB		:= SA1->A1_CEPC
				U00->U00_PESSO 		:= SA1->A1_PESSOA

				// tratamento para ver se os campos existem no cliente e contrato
				if SA1->(FieldPos("A1_XNOMPAI")) > 0 .And. U00->(FieldPos("U00_XNOMPA")) > 0
					U00->U00_XNOMPA		:= SA1->A1_XNOMPAI
				endIf

				// tratamento para ver se os campos existem no cliente e contrato
				if SA1->(FieldPos("A1_XNOMAE")) > 0 .And. U00->(FieldPos("U00_XNOMAE")) > 0
					U00->U00_XNOMAE		:= SA1->A1_XNOMAE
				endIf

				U00->( MsUnlock() )

				U00->( DbSkip() )
			EndDo

		else

			FwLogMsg("INFO", , "REST", FunName(), "", "01", ">> RCPGE007 - CONTRATO DO CLIENTE: " + cCliente+ " / " + cLoja + " NAO ENCONTRADO, DADOS NAO ATUALIZADOS ", 0, (nStart - Seconds()), {})

		endif

		//====================================================================
		// atualizo o cadastro do autorizado do contrato vinculado ao cliente
		//====================================================================
		if Select("TRBU02") > 0
			TRBU02->(DBCloseArea())
		endIf

		cQuery := " SELECT U02.R_E_C_N_O_ RECU02 "
		cQuery += " FROM " + RetSqlName("U02") + " U02 "
		cQuery += " WHERE U02.D_E_L_E_T_ = ' ' "
		cQuery += " AND U02.U02_FILIAL = '" + xFilial("U02") + "' "
		cQuery += " AND U02.U02_CODCLI = '" + SA1->A1_COD  + "' "
		cQuery += " AND U02.U02_LOJCLI = '" + SA1->A1_LOJA + "' "

		MPSysOpenQuery( cQuery, "TRBU02" )

		While TRBU02->(!Eof())

			// verifico se o registro está posicionado
			if TRBU02->RECU02 > 0

				U02->(DBGoTo(TRBU02->RECU02))

				if U02->(RecLock("U02",.F.))
					U02->U02_NOME 	:= SA1->A1_NOME
					U02->U02_GRAUPA	:= "OU" // Outros
					U02->U02_CPF	:= SA1->A1_CGC
					U02->U02_CI		:= SA1->A1_PFISICA

					if !Empty(SA1->A1_XDTNASC)
						U02->U02_DTNASC	:= SA1->A1_XDTNASC
						U02->U02_IDADE	:= U_UAgeCalculate(SA1->A1_XDTNASC,dDataBase)
					EndIf

					U02->U02_SEXO 	:= SA1->A1_XSEXO
					U02->U02_ESTCIV	:= SA1->A1_XESTCIV
					U02->U02_END	:= SA1->A1_END
					U02->U02_COMPLE	:= SA1->A1_COMPLEM
					U02->U02_BAIRRO	:= SA1->A1_BAIRRO
					U02->U02_NATURA	:= POSICIONE("CC2",1,XFILIAL("CC2")+SA1->A1_XESTNAS+SA1->A1_XMUNNAT,"CC2_MUN")
					U02->U02_CEP 	:= SA1->A1_CEP
					U02->U02_EST	:= SA1->A1_EST
					U02->U02_CODMUN	:= SA1->A1_COD_MUN
					U02->U02_MUN 	:= SA1->A1_MUN
					U02->U02_DDD	:= SA1->A1_DDD
					U02->U02_FONE	:= SA1->A1_TEL	
					U02->U02_CELULA := SA1->A1_XCEL
					U02->U02_EMAIL	:= SA1->A1_EMAIL

					U02->(MsUnlock())
				else
					U02->(DisarmTransaction())
				endIf

			endIf

			TRBU02->(DbSkip())
		EndDo

		if Select("TRBU02") > 0
			TRBU02->(DBCloseArea())
		endIf

	endif

	RestArea(aAreaU02)
	RestArea(aAreaU00)
	RestArea(aAreaSA1)
	RestArea(aArea)

Return(Nil)

