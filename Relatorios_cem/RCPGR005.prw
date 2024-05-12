#Include 'Protheus.ch'
#Include 'Topconn.ch'
//--------------------------------------------------------------
/*/{Protheus.doc} RCPGR005
Description

Rotina para definição de parametro bancario padrão para impressão
do boleto bancario
@param xParam Parameter Description
@return xRet Return Description
@author  - Raphael Martins
@since 24/03/2016
/*/
//--------------------------------------------------------------
User Function RCPGR005(lPainel)

	Local oComboBo1
	Local oGroup1
	Local oGroup2
	Local oSay1
	Local oSay10
	Local oSay11
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local oSay8
	Local oSay9
	Local oDlg
	Local oFont1      := TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)
	Local oFont2      := TFont():New("MS Sans Serif",,018,,.F.,,,,,.F.,.F.)
	Local aButtons    := {}
	Local nComboBo1   := 1
	Local cBanco      := ""
	Local cAgencia    := ""
	Local cConta      := ""
	Local cConvenio   := ""
	Local cNossoNum   := ""
	Local aParam      := ConsParam(@cBanco,@cAgencia,@cConta,@cConvenio,@cNossoNum)

	Default lPainel	:= .F.

	If Len(aParam) > 0

		DEFINE MSDIALOG oDlg TITLE "Definição de Parametro Padrão" FROM 000, 000  TO 340, 600 COLORS 0, 16777215 PIXEL

		@ 032, 003 GROUP oGroup1 TO 160, 294 PROMPT "Parametro Bancario Padrão" OF oDlg COLOR 0, 16777215 PIXEL

		@ 040, 010 SAY oSay1 PROMPT "Informe Abaixo as informações de Banco/Agencia/conta cadastrados na rotina (Parametros Bancos)" SIZE 218, 019 OF oDlg FONT oFont1 COLORS 8388608, 16777215 PIXEL

		@ 057, 007 GROUP oGroup2 TO 154, 291 PROMPT "Parametros Ativos" OF oDlg COLOR 0, 16777215 PIXEL


		@ 073, 012 MSCOMBOBOX oComboBo1 VAR nComboBo1 ITEMS aParam SIZE 265, 010 OF oDlg COLORS 0,;
			16777215 ON CHANGE ( AtuLabels(aParam,oComboBo1,@cBanco,@cAgencia,@cConta,@cConvenio,@cNossoNum) ) PIXEL

		@ 095, 012 SAY oSay2 PROMPT "Banco:" SIZE 025, 007 OF oDlg FONT oFont2 COLORS 8421504, 16777215 PIXEL
		@ 095, 037 SAY oSay3 PROMPT cBanco SIZE 177, 007 OF oDlg FONT oFont1 COLORS 8388608, 16777215 PIXEL

		@ 114, 012 SAY oSay4 PROMPT "Agencia:" SIZE 028, 007 OF oDlg FONT oFont2 COLORS 8421504, 16777215 PIXEL
		@ 114, 042 SAY oSay5 PROMPT cAgencia SIZE 041, 007 OF oDlg FONT oFont1 COLORS 8388608, 16777215 PIXEL

		@ 114, 087 SAY oSay6 PROMPT "Conta:" SIZE 025, 007 OF oDlg FONT oFont2 COLORS 8421504, 16777215 PIXEL
		@ 114, 114 SAY oSay7 PROMPT cConta SIZE 025, 007 OF oDlg FONT oFont1 COLORS 8388608, 16777215 PIXEL

		@ 134, 013 SAY oSay8 PROMPT "Nr. Convenio:" SIZE 042, 007 OF oDlg FONT oFont2 COLORS 8421504, 16777215 PIXEL
		@ 134, 059 SAY oSay9 PROMPT cConvenio SIZE 060, 008 OF oDlg FONT oFont1 COLORS 8388608, 16777215 PIXEL

		@ 134, 118 SAY oSay10 PROMPT "Nosso Numero:" SIZE 053, 007 OF oDlg FONT oFont2 COLORS 8421504, 16777215 PIXEL
		@ 134, 174 SAY oSay11 PROMPT cNossoNum SIZE 087, 007 OF oDlg FONT oFont1 COLORS 8388608, 16777215 PIXEL

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| Confirma(oComboBo1,aParam,lPainel), oDlg:End() }, {|| oDlg:End()},,aButtons)

	Else
		Help(,,'Help',,"Não Existe Parametros Bancarios cadastrados, Favor realize o cadastro!",1,0)
	EndIf

Return

//--------------------------------------------------------------
/*/{Protheus.doc} ConsParam
Description
Funcao para pesquisar parametros bancarios ativos 
@param xParam Parameter Description
@return xRet Return Description
@author  - Raphael Martins
@since 24/03/2016
/*/
//--------------------------------------------------------------

Static Function ConsParam(cBanco,cAgencia,cConta,cConvenio,cNossoNum)

	Local aRetorno     := {}
	Local aDefault     := StrTokArr( GetMV( "ES_PARASEE" , .F./*lHelp*/, '' ),'/' )
	Local cBcoDfaut    := ""
	Local cAgDfaut     := ""
	Local cCtaDfaut    := ""
	Local cNoBanco     := ""
	Local cSubDfaut    := ""
	Local cConDfault   := ""
	Local cNosNumDft   := ""

	SEE->( DbSetOrder( 1 ) ) //EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
	// Parametro Default, definido no prametro
	If Len(aDefault) == 4

		cBcoDfaut  := Padr( Alltrim( aDefault[1] ),TamSX3('A6_COD')[1] )
		cAgDfaut   := Padr( Alltrim( aDefault[2] ),TamSX3('A6_AGENCIA')[1] )
		cCtaDfaut  := Padr( Alltrim( aDefault[3] ),TamSX3('A6_NUMCON')[1] )
		cSubDfaut  := Padr( Alltrim( aDefault[4] ),TamSX3('EE_SUBCTA')[1] )
		cNoBanco   := Alltrim( RetField('SA6', 1 , xFilial("SA6") + cBcoDfaut + cAgDfaut + cCtaDfaut , 'A6_NOME' ) )

		If SEE->( DbSeek( xFilial("SEE") + cBcoDfaut + cAgDfaut + cCtaDfaut + cSubDfaut ) )

			cConDfault := Alltrim( SEE->EE_CODEMP )
			cNosNumDft := Alltrim( SEE->EE_FAXATU )

			cBanco    := cBcoDfaut + '/' + cNoBanco
			cAgencia  := cAgDfaut
			cConta    := cCtaDfaut
			cConvenio := cConDfault
			cNossoNum := cNosNumDft


			Aadd(aRetorno,cValToChAR( SEE->( Recno() ) ) +;
				'/Banco:' + AllTrim(cBcoDfaut) + '-->' + cNoBanco +;
				'Ag:' + Alltrim( cAgDfaut) + '/' +;
				'Conta:' + Alltrim( cCtaDfaut ) +'/' +;
				'SubConta:'+cSubDfaut+ '/ Convenio: '+cConDfault )

		EndIf

	EndIf

	If SEE->( DbSeek( xFilial("SEE") ) )

		If Empty(cBanco)
			cBanco    := AllTrim(SEE->EE_CODIGO) + '/' + Alltrim( RetField('SA6', 1 , xFilial("SA6") + SEE->EE_CODIGO + SEE->EE_AGENCIA + SEE->EE_CONTA, 'A6_NOME' ) )
			cAgencia  := Alltrim( SEE->EE_AGENCIA)
			cConta    := Alltrim( SEE->EE_CONTA)
			cConvenio := SEE->EE_CODEMP
			cNossoNum := SEE->EE_FAXATU
		EndIf

		While SEE->( !Eof() ) .And. SEE->EE_FILIAL == xFilial("SEE")

			If ( cBcoDfaut + cAgDfaut + cCtaDfaut + cSubDfaut ) <> ( SEE->EE_CODIGO + SEE->EE_AGENCIA + SEE->EE_CONTA )

				cNoBanco := Alltrim( RetField('SA6', 1 , xFilial("SA6") + SEE->EE_CODIGO + SEE->EE_AGENCIA + SEE->EE_CONTA, 'A6_NOME' ) )

				Aadd(aRetorno, cValToChAR( SEE->( Recno() ) ) +;
					'/Banco:' + AllTrim(SEE->EE_CODIGO) + "-->" + cNoBanco +;
					"/Ag:" + Alltrim( SEE->EE_AGENCIA) + "/" +;
					"Conta:" + Alltrim( SEE->EE_CONTA) +;
					"/" + "SubConta:"+SEE->EE_SUBCTA+;
					"/ Convenio: "+Alltrim(SEE->EE_CODEMP) )
			EndIf

			SEE->( DbSkip() )

		EndDo
	EndIf



Return( aClone( aRetorno ) )

//********************************************************
// Funcao para Atualizar Labels do Parametro posicionado
//********************************************************
Static Function AtuLabels(aCombo,oCombo,cBanco,cAgencia,cConta,cConvenio,cNossoNum)

	Local nRegistro := Val( SubStr( aCombo[oCombo:Nat] , AT("/",aCombo[oCombo:Nat] ) - 1 ) )

	If nRegistro > 0

		SEE->( DbGoto(nRegistro) )

		cBanco	   := AllTrim(SEE->EE_CODIGO) + '/' + Alltrim( RetField('SA6', 1 , xFilial("SA6") + SEE->EE_CODIGO + SEE->EE_AGENCIA + SEE->EE_CONTA, 'A6_NOME' ) )
		cAgencia   := SEE->EE_AGENCIA
		cConta 	   := SEE->EE_CONTA
		cConvenio  := SEE->EE_CODEMP
		cNossoNum  := SEE->EE_FAXATU

	Endif

Return(Nil)

//***************************************************************
// Funcao ao Confirmar a Seleção do Parametro Bancario Padrão
//***************************************************************
Static Function Confirma(oCombo,aCombo,lPainel)

	Local nRegistro := Val( SubStr( aCombo[oCombo:Nat] , AT("/",aCombo[oCombo:Nat] ) - 1 ) )

	Default lPainel	:= .F.

	If nRegistro > 0

		SEE->( DbGoto(nRegistro) )
		PutMV('ES_PARASEE',Alltrim( SEE->EE_CODIGO ) + '/' + Alltrim( SEE->EE_AGENCIA ) + '/' + Alltrim( SEE->EE_CONTA ) + '/' + Alltrim(SEE->EE_SUBCTA) )

		If !lPainel
			MsgInfo("Parametro Bancario Padrão alterado com sucesso!")
		EndIf

	EndIf

Return(Nil)
