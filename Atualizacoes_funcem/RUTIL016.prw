#Include 'Protheus.ch'

Static cRetTabela

/*/{Protheus.doc} RUTIL016
Tela para seleção do Contrato para impressao de termos
@author g.sampaio
@since 04/06/2019
@version P12
@param nulo
@return nulo
/*/

User Function RUTIL016(cCodContrato)

	Local aArea       	:= GetArea()
	Local aAreaUF2    	:= {}
	Local aAreaUJJ   	:= UJJ->( GetArea() )
	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)

	Private cIndice     := ""
	Private cAlias      := ""
	Private cChave      := ""
	Private cF3		    := ""
	Private nRecSel     := 0

	Static cContrato 	:= ""
	Static cRotina 		:= ""
	Static lConsulta	:= .F.

	Default cCodContrato	:= ""

	// verifico a rotina e o parametro para verificar o modulo
	if lCemiterio .And. "CPG" $ AllTrim(FunName()) // para modulo de cemiterio
		cCodModulo := "C"
	elseIf lCemiterio .And. "FUN" $ AllTrim(FunName()) // para modulo de funeraria
		cCodModulo := "F"
	elseIf lCemiterio // para modulo de cemiterio
		cCodModulo := "C"
	elseIf lFuneraria // para modulo de funeraria
		cCodModulo := "F"
	endIf

	if cCodModulo == "C" // para cemiterio

		// impressao de termos para o modulo de cemiterio
		U_RUTILE28(cCodContrato)

	elseIf cCodModulo == "F"  // para funeraria

		UJJ->(DbSetorder(1))

		aAreaUF2  := UF2->( GetArea() )
		cContrato := UF2->UF2_CODIGO

		If !Pergunte("RUTIL016",.T.)
			MsgInfo("Abortado pelo Usuário!","Atenção!")
			Return
		Endif

		//Valido se Alias foi encontrato
		If Empty(cAlias) .AND. !lConsulta

			UJJ->(DbSetOrder(1))
			UJN->(DbSetOrder(1))

			//Posiciono pra pegar o codigo da rotina
			If UJJ->(DbSeek(xFilial("UJJ")+MV_PAR01))

				If UJN->(DbSeek(xFilial("UJN")+UJJ->UJJ_ROTINA))

					cAlias      := UJN->UJN_TABELA
					cIndice     := Val(UJN->UJN_INDICE)
					cChave      := Alltrim(UJN->UJN_CHAVE)
					cRotina		:= Alltrim(UJN->UJN_ROTINA)

					//Ordena pelo indice definido no cadastro
					(cAlias)->(DbSetOrder(cIndice))

					//Posiciona no registro para impressao
					If (cAlias)->(DbSeek(xFilial(cAlias)+MV_PAR02))

						nRecSel := (cAlias)->(Recno())

					Endif
				Endif
			Endif
			If Empty(cAlias)
				Alert("Alias para consulta nao foi encontrado, verifique a rotina de cadastro de termo !")
				Return
			Endif

			//Valido se contrato selecionado
			If cAlias == "UF2"
				if Alltrim(cContrato) != Alltrim(MV_PAR02)

					If MsgYesNo("Contrato selecionado é diferente do contrato posicionado!"+CRLF+"Deseja utilizar o contrato selecionado ?")
						cContrato:= Alltrim(MV_PAR02)
					Else
						MV_PAR02 := cContrato
					Endif
				Endif
			Endif
		Endif

		//Imprime Termo
		fImprimir( MV_PAR01,cContrato )

		RestArea( aAreaUF2 )

	endIf

	RestArea( aAreaUJJ )
	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} fImprimir
Funcao pra realizar a impressao
@author g.sampaio
@since 04/06/2019
@version P12
@param cContrato        , caractere     , numero do contrato
@param nComboModulo     , numerico      , numero do modulo selecionado
@param cLayout          , caractere     , codigo do layout
@param oDlg             , objeto        , objeto da tela
@return nulo
/*/
Static Function fImprimir(cLayout,cContrato )

	Local aArea     := GetArea()
	Local aAreaUJJ  := UJJ->( GetArea() )
	Local lContinua := .T.

	Default cLayout     := ""

	// verifico se o CODIGO foi preenchido
	If !Empty(cContrato)

		// posiciono na tabela de layouts
		UJJ->( DbSetOrder(1) )
		If UJJ->( DbSeek( xFilial("UJJ")+cLayout ) )

			//Posiciono no registro selecionado
			(cAlias)->(DbGoTo(nRecSel))

			// funcao de impressao de termos com macro
			FWMsgRun(,{|oCarrega| U_RUTILR02( cLayout, cContrato,cAlias,cIndice ) },'Aguarde...','Realizando a impressão do Layout Selecionado ...')

		EndIf

	Else // mensagem para o usuario quando o contrato estiver vazio

		MsgAlert("Nenhum Item foi selecionado")

	EndIf

	RestARea( aAreaUJJ )
	RestArea( aArea )

Return()

/*/{Protheus.doc} MontaTela
//Funcao consulta especifica
@Author Leandro Rodrigues
@Since 14/06/2019
@Version 1.0
@Return
@Type function
/*/
User Function RUTIL16A()

	Local lRetorno := .F.

	UJJ->(DbSetOrder(1))
	UJN->(DbSetOrder(1))

	//Posiciono pra pegar o codigo da rotina
	If UJJ->(DbSeek(xFilial("UJJ")+MV_PAR01))

		If UJN->(DbSeek(xFilial("UJN")+UJJ->UJJ_ROTINA))

			cF3			:= UJN->UJN_F3
			cAlias      := UJN->UJN_TABELA
			cIndice     := Val(UJN->UJN_INDICE)
			cChave      := Alltrim(UJN->UJN_CHAVE)
			cRotina		:= Alltrim(UJN->UJN_ROTINA)

			//Valido se é funeraria ou cemiterio
			if IsInCallStack("U_RFUNA002")
				cContrato := UF2->UF2_CODIGO

			Else
				cContrato := U00->U00_CODIGO

			Endif
		Endif
	Endif

	//Faz consulta conforme cadastro de termo
	lRetorno:= 	ConPad1(,,, cF3  ,,, .F.,,,,,,)

	//Se usuario confirmou
	If lRetorno
		nRecSel:= (cAlias)->(Recno())
	Endif

Return(lRetorno)
