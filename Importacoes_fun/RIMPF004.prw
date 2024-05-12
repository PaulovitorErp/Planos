#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} RIMPF004

    importacao de mensagens de contrato

    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
user Function RIMPF004( aMenCtr, nHdlLog )

	local aArea         := getArea()
	local aAreaUF9      := UF9->( getArea() )
	local aAreaUF2      := UF2->( getArea() )
	local aDadosCtr		:= {}
	local aImpMen       := {}
	local aLinhaCtr     := {}
	local aCabCtr       := {}
	local lRet			:= .F.
	local nX			:= 0
	local nPosCod   	:= 0
	local nPosTit       := 0
	local cCodCtr   	:= ""
	local cDscTit       := ""
	local cErroExec		:= ""
	local cPulaLinha	:= Chr(13) + Chr(10)
	local cDirLogServer	:= ""
	local cArqLog		:= "log_imp.log"
	local nJ            := 1
	Local lRFUNE002			:= Existblock("RFUNE002")

// variavel interna da rotina automatica
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.

// valores do default dos parametros
	default aMenCtr  := {}
	default nHdlLog := 0

//diretorio no server que sera salvo o retorno do execauto
	cDirLogServer := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	cDirLogServer += If(Right(cDirLogServer, 1) <> "\", "\", "")

	for nX := 1 to len( aMenCtr )

		// limpo o array de mensagem
		aImpMen := {}

		UF9->( dbSetOrder(1) ) //UF9_FILIAL+UF9_CODIGO+UF9_ITEM

		aLinhaCtr	:= aClone(aMenCtr[nX])

		// pego a posicoes do campo
		nPosCod     := aScan(aLinhaCtr,{|x| AllTrim(x[1]) == "COD_ANT"})
		nPosTit     := aScan(aLinhaCtr,{|x| AllTrim(x[1]) == "UF9_HISTOR"})

		//importo apenas mensagem com o codigo anterior do contrato
		if nPosCod > 0 .and. nPosTit > 0

			// pego o codigo do contrato a ser importado
			cCodAnt	:= Alltrim(aLinhaCtr[nPosCod,2])
			cDscTit	:= Alltrim(aLinhaCtr[nPosTit,2])

			// verifico se o Codigo Anterior e o Titulo da Mensagem estao preenchidos e valido se existe duplicidade
			if !Empty(cCodAnt) .and. !Empty(cDscTit)

				UF2->( DbSetOrder(3) ) //UF9_FILIAL + UF9_CODANT

				If UF2->( DbSeek( xFilial("UF2") + PadL(Alltrim(cCodAnt),TamSX3("UF2_CODIGO")[1],"0") ) )

					// pego o codigo do contrato do protheus
					cCodCtr := UF2->UF2_CODIGO

					// valido se ja existe a mensagem no contrato
					if !fValHist(cCodCtr, cDscTit)

						// array de cabecalho do execauto
						aAdd(aCabCtr, {"UF2_CODIGO"	,cCodCtr } )	//Codigo do Contrato

						DbSelectArea("UF9")
						UF9->( dbSetOrder(1) ) //UF9_FILIAL+UF9_CODIGO+UF9_ITEM

						// para o codigo do item
						aAdd(aDadosCtr, {"UF9_ITEM",	fMaxItem( cCodCtr )})

						//monto array com os dados do contrato
						For nJ := 1 To Len(aLinhaCtr)

							if Alltrim(aLinhaCtr[nJ,1]) == "COD_ANT" // se for codigo anterior pula para o proximo
								Loop
							endIf

							aAdd(aDadosCtr, {Alltrim(aLinhaCtr[nJ,1]),	aLinhaCtr[nJ,2]})

						Next nJ

						if len(aDadosCtr) > 0
							aAdd(aImpMen,aDadosCtr)
						endIf

						// verifico se a rotina de contratos esta compilada
						if lRFUNE002 .and. len(aImpMen) > 0

							BEGIN TRANSACTION

								// execauto de contrato
								If !U_RFUNE002(aCabCtr,,aImpMen,4)

									//verifico se arquivo de log existe
									if nHdlLog > 0

										cErroExec := MostraErro(cDirLogServer + cArqLog )

										FErase(cDirLogServer + cArqLog )

										fWrite(nHdlLog , "Erro na Inclusao da Mensagem no Contrato:" )

										fWrite(nHdlLog , cPulaLinha )

										fWrite(nHdlLog , cErroExec )

										fWrite(nHdlLog , cPulaLinha )

									endif

									UF9->(DisarmTransaction())

								else

									//verifico se arquivo de log existe
									if nHdlLog > 0

										fWrite(nHdlLog , "Mensagem Cadastrada com sucesso no Contrato!" )

										fWrite(nHdlLog , cPulaLinha )

										fWrite(nHdlLog , "Mensagem do contrato: " + Alltrim( cCodCtr ) + " " )

										fWrite(nHdlLog , cPulaLinha )

										lRet := .T.

									endif

								endif

							END TRANSACTION

						endif
					else
						fWrite(nHdlLog , "Mensagem: " + cDscTit + " já existe no contrato!" )

						fWrite(nHdlLog , cPulaLinha )

					endIf
				else

					//verifico se arquivo de log existe
					if nHdlLog > 0

						fWrite(nHdlLog , "Contrato: " + Alltrim(cCodAnt) + " não encontrado no sistema! " )

						fWrite(nHdlLog , cPulaLinha )

					endif

				endIf
			else

				fWrite(nHdlLog , "Layout de importação não possui campo Codigo Anterior, a definição do mesmo é obrigatória!" )

				fWrite(nHdlLog , cPulaLinha )

			endIf
		else

			fWrite(nHdlLog , "Layout de importação não possui campo Codigo Anterior, a definição do mesmo é obrigatória!" )

			fWrite(nHdlLog , cPulaLinha )

		endif

	next nX

	restArea( aAreaUF2 )
	restArea( aAreaUF9 )
	restArea( aArea )

return lRet

/*/{Protheus.doc} fMaxItem
    
    retorna o codigo do item

    @type  Static Function
    @author [tbc] g.sampaio
    @since 13/12/2018
    @version 1.0
    @param cCodCtr, caracter, codigo do contrato do beneficiario
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fMaxItem( cCodCtr )

	local aArea         := getArea()
	local cRet          := strzero(1,TamSX3("UF9_ITEM")[1])
	local cQuery        := ""

	default cCodCtr     := ""

	if select("TRBUF9") > 0
		TRBUF9->( dbCloseArea() )
	endIf

// monto a query
	cQuery := " SELECT MAX( UF9.UF9_ITEM ) MAXITEM FROM " + retSqlName("UF9") + " UF9    "
	cQuery += " WHERE UF9.D_E_L_E_T_ = ' '                                  "
	cQuery += " AND UF9.UF9_CODIGO = '" + alltrim(cCodCtr) +"'              "
	cQuery += " AND UF9.UF9_FILIAL = '" + xFilial("UF9") +"'                "

	cQuery  := changeQuery( cQuery )

	tcQuery cQuery new alias "TRBUF9"

// verifico se existe registro
	if TRBUF9->( !eof() )
		cRet := soma1( TRBUF9->MAXITEM )
	endIf

	TRBUF9->( dbCloseArea() )

	restArea( aArea )

return cRet

/*/{Protheus.doc} fValHist
    
    valido sea mensagem ja esta presente no contrato

    @type  Static Function
    @author [tbc] g.sampaio
    @since 13/12/2018
    @version 1.0
    @param cCodCtr, caracter, codigo do contrato da mensagem
    @param cDscTit, caracter, titulo da mensagem
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fValHist( cCodCtr, cDscTit )

	local aArea         := getArea()
	local lRet          := .F.
	local cQuery        := ""

	default cCodCtr     := ""
	default cDscTit     := ""

	if select("TRBUF9") > 0
		TRBUF9->( dbCloseArea() )
	endIf

// monto a query
	cQuery := " SELECT UF9.UF9_CODIGO
	cQuery += " FROM " + retSqlName("UF9") + " UF9    "
	cQuery += " WHERE UF9.D_E_L_E_T_        = ' '                                  "
	cQuery += " AND UF9.UF9_CODIGO          = '" + alltrim(cCodCtr) +"'              "
	cQuery += " AND TRIM(UF9.UF9_HISTOR)    = '" + alltrim(cDscTit) + "'              "
	cQuery += " AND UF9.UF9_FILIAL          = '" + xFilial("UF9") +"'                "
	cQuery += " ORDER BY UF9.UF9_CODIGO, UF9_HISTOR                           "

	cQuery  := changeQuery( cQuery )

	tcQuery cQuery new alias "TRBUF9"

// verifico se existe registro
	if TRBUF9->( !eof() )
		lRet := .T.
	endIf

	TRBUF9->( dbCloseArea() )

	restArea( aArea )

Return(lRet)
