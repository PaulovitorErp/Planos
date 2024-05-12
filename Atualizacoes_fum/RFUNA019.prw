#include "protheus.ch"
#include "tbiconn.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} RFUNA019
Chama o Histório de Apontamentos de Serviço
@author TOTVS
@since 07/09/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RFUNA019()
/***********************/

	Local aArea 	    := GetArea()
	Local cRotApto 	    := SuperGetMv("MV_XROTAPT",.F.,"RFUNA034")
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local oButton1		:= Nil
	Local oButton2		:= Nil
	Local oButton3		:= Nil
	Local oGroup1		:= Nil
	Local oSay1			:= Nil
	Local oDlg			:= Nil
	Local oFontTitulo := TFont():New("Arial",,012,,.T.,,,,,.F.,.F.)

	if lPlanoPet

		if UF2->UF2_USO == "1" // ambos

			// CSS do objeto group para colorir a borda
			cCSSGroup := " QGroupBox { "
			cCSSGroup += " border: 2px solid #0076CE; "
			cCSSGroup += " padding-top: 0px; "
			cCSSGroup += " }

			// monto o CSS dos botoes
			cAzulBotaoCSS   	:= CSSAzulBotoes()
			cVerdeBotaoCSS   	:= CSSVerdeBotoes( )
			cVermelhoBotaoCSS   := CSSVermelhoBotoes()

			DEFINE MSDIALOG oDlg TITLE "Selecione" FROM 000, 000  TO 200, 400 COLORS 0, 16777215 PIXEL

			@ 002, 002 GROUP oGroup1 TO 100, 200 PROMPT "Selecione o uso do apontamento de serviços" OF oDlg COLOR 0, 16777215 PIXEL
			oGroup1:oFont := oFontTitulo
			oGroup1:SetCss(cCSSGroup)

			@ 021, 019 SAY oSay1 PROMPT "Para o uso do Contrato como ambos, selecione qual o tipo de apontamento, entre Humano e Pet." SIZE 147, 033 OF oDlg COLORS 0, 16777215 PIXEL

			@ 065, 018 BUTTON oButton1 PROMPT "Para Humano" SIZE 047, 012 OF oDlg PIXEL Action(ExecRotina("2"), oDlg:End())
			oButton1:SetCss(cAzulBotaoCSS)

			@ 065, 077 BUTTON oButton2 PROMPT "Para Pet" SIZE 047, 012 OF oDlg PIXEL Action(ExecRotina("3"), oDlg:End())
			oButton2:SetCss(cVerdeBotaoCSS)

			@ 065, 135 BUTTON oButton3 PROMPT "Sair" SIZE 047, 012 OF oDlg PIXEL Action(oDlg:End())
			oButton3:SetCss(cVermelhoBotaoCSS)

			ACTIVATE MSDIALOG oDlg CENTERED

		else
			ExecRotina(UF2->UF2_USO)
		endIf

	else
		ExecRotina()
	endIf

	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} ExecRotina
Funcao para executar a rotina conforme o uso
@type function
@version 1.0
@author g.sampaio
@since 11/08/2021
@param cUso, character, uso do contrato
/*/
Static Function ExecRotina(cUso)

	Local cRotApto	    := SuperGetMv("MV_XROTAPT",.F.,"RFUNA034")
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet

	Default cUso    := ""

	if lPlanoPet
		if cUso == "3" // caso for pet
			cRotApto := "RUTIL025"
		endIf
	endIf

	SetFunName(cRotApto)
	&("U_" + cRotApto +"()")
	SetFunName("RFUNA002")

Return(Nil)

/*/{Protheus.doc} CSSAzulBotoes
Funcao para gerar a estilizacao do botao azul
@type function
@version 1.0
@author g.sampaio
@since 28/07/2020
@return character, retorna a estilizacao css
/*/
Static Function CSSAzulBotoes( nTamanhoTela )

	Local cRetorno          as Char

	Default nTamanhoTela    := 0

	// implementacao do CSS
	cRetorno    := " QPushButton { background: #35ACCA; "
	cRetorno    += " border: 1px solid #1f6779;"
	cRetorno    += " outline:0;"
	cRetorno    += " border-radius: 5px;"
	cRetorno    += " font-family: Arial;"
	cRetorno    += " font-size: 10px;"
	cREtorno    += " font-weight: bold;"
	cRetorno    += " padding: 6px;"
	cRetorno    += " color: #ffffff;}"
	cRetorno    += " QPushButton:hover { background-color: #1f6779;"
	cRetorno    += " border-style: inset;"
	cRetorno    += " font-family: Arial;"
	cRetorno    += " font-size: 10px;"
	cREtorno    += " font-weight: bold;"
	cRetorno    += " border-color: #35ACCA;"
	cRetorno    += " color: #ffffff; }"

Return(cRetorno)

/*/{Protheus.doc} CSSVerdeBotoes
Funcao para gerar a estilizacao do botao verde
@type function
@version 1.0
@author g.sampaio
@since 28/07/2020
@return character, retorna a estilizacao css
/*/
Static Function CSSVerdeBotoes( nTamanhoTela )

	Local cRetorno          as Char

	Default nTamanhoTela    := 0

	// implementacao do CSS
	cRetorno    := " QPushButton { background: #1FD203; "
	cRetorno    += " border: 1px solid #107800;"
	cRetorno    += " outline:0;"
	cRetorno    += " border-radius: 5px;"
	cRetorno    += " font-family: Arial;"
	cRetorno    += " font-size: 10px;"
	cREtorno    += " font-weight: bold;"
	cRetorno    += " padding: 6px;"
	cRetorno    += " color: #ffffff;}"
	cRetorno    += " QPushButton:hover { background-color: #107800;"
	cRetorno    += " border-style: inset;"
	cRetorno    += " font-family: Arial;"
	cRetorno    += " font-size: 10px;"
	cREtorno    += " font-weight: bold;"
	cRetorno    += " border-color: #1FD203;"
	cRetorno    += " color: #ffffff; }"

Return(cRetorno)

/*/{Protheus.doc} CSSVermelhoBotoes
Funcao para gerar a estilizacao do botao vermelho
@type function
@version 1.0
@author g.sampaio
@since 28/07/2020
@return character, retorna a estilizacao css
/*/
Static Function CSSVermelhoBotoes()

	Local cRetorno          as Char

	Default nTamanhoTela    := 0

	// implementacao do CSS
	cRetorno    := " QPushButton { background: #FF0000; "
	cRetorno    += " border: 1px solid #8B1A1A;"
	cRetorno    += " outline:0;"
	cRetorno    += " border-radius: 5px;"
	cRetorno    += " font-family: Arial;"
	cRetorno    += " font-size: 10px;"
	cREtorno    += " font-weight: bold;"
	cRetorno    += " padding: 6px;"
	cRetorno    += " color: #ffffff;}"
	cRetorno    += " QPushButton:hover { background-color: #8B1A1A;"
	cRetorno    += " border-style: inset;"
	cRetorno    += " font-family: Arial;"
	cRetorno    += " font-size: 10px;"
	cREtorno    += " font-weight: bold;"
	cRetorno    += " border-color: #FF0000;"
	cRetorno    += " color: #ffffff; }"

Return(cRetorno)
