#include "totvs.ch"

/*/{Protheus.doc} RUTILE14
Rotina para abrir os alias a serem utilizados pela rotina
@author g.sampaio
@since 10/06/2019
@version P12
@param Nil
@return nulo
/*/

User Function RUTILE14()                        

Local cGet1			:= Space(3)
Local oButton1		:= Nil
Local oButton2		:= Nil
Local oButton3		:= Nil
Local oGet1			:= Nil
Local oGroup1		:= Nil
Local oGroup2		:= Nil	
Local oGroup3		:= Nil
Local oGroup4		:= Nil
Local oSay1			:= Nil

Static oDlg			:= Nil

Private aWBrwSIX	:= {{.F.,"","",""}}
Private aWBrwDe		:= {{"","",""}}
Private aWBrwPara	:= {{"","",""}}
Private cGet2		:= Space(300)	
Private oWBrwSIX	:= Nil
Private oWBrwDe		:= Nil
Private oWBrwPara	:= Nil
Private oGet2		:= Nil

Public __cCDOM		:= ""
Public __nORDEM		:= "0"
Public __cRELACI	:= ""
Public __cChave		:= ""

// verifica se a variavel publica, está populada
If !Empty(__cCDOM)
	
	// reinicio do conteudo da variavel publica
	__cCDOM := ""

EndIf

// verifica se a variavel publica, está populada
If !Empty(__nORDEM)
	
	// reinicio do conteudo da variavel publica
	__nORDEM := "0"

EndIf

// verifica se a variavel publica, está populada
If !Empty(__cRELACI)
	
	// reinicio do conteudo da variavel publica
	__cRELACI := ""

EndIf

If !Empty(__cChave)

	__cChave:= ""
Endif

DEFINE MSDIALOG oDlg TITLE "Relacionamento de Tabelas" FROM 000, 000  TO 500, 800 COLORS 0, 16777215 PIXEL

	@ 004, 004 GROUP oGroup1 TO 246, 394 PROMPT "Relacionamento de Tabelas" OF oDlg COLOR 0, 16777215 PIXEL
    @ 011, 007 GROUP oGroup2 TO 107, 391 PROMPT "Seleção da Tabela" OF oDlg COLOR 0, 16777215 PIXEL
    @ 109, 008 GROUP oGroup3 TO 207, 196 PROMPT "De" OF oDlg COLOR 0, 16777215 PIXEL
    @ 109, 203 GROUP oGroup4 TO 206, 390 PROMPT "Para" OF oDlg COLOR 0, 16777215 PIXEL
    @ 207, 008 GROUP oGroup5 TO 241, 289 PROMPT "Chave" OF oDlg COLOR 0, 16777215 PIXEL 

	@ 021, 014 SAY oSay1 PROMPT "Tabela" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL	
	
	// buscar
	@ 019, 065 MSGET oGet1 VAR cGet1 F3 "VIRSX2" PICTURE "@!" SIZE 185, 010 OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON

	// chave
    @ 219, 013 MSGET oGet2 VAR cGet2 WHEN .F. SIZE 271, 015 OF oDlg COLORS 0, 16777215 PIXEL

    @ 228, 351 BUTTON oButton1 PROMPT "Confirmar" 	SIZE 037, 012 OF oDlg PIXEL ACTION( Confirmar( cGet2 ) )
    @ 228, 309 BUTTON oButton2 PROMPT "Cancelar" 	SIZE 037, 012 OF oDlg PIXEL ACTION( oDlg:End() )
    @ 018, 268 BUTTON oButton3 PROMPT "Buscar" 		SIZE 037, 012 OF oDlg PIXEL	ACTION( BuscarSIX( cGet1 ) )

	// monta o brwose com os indices conforme a tabela digitada
    fWBrwSIX()

	// monta o browse com os itens selecionaveis do "De"
    fWBrwDe()

	// monta o browse com os itens selecionaveis do "Para"
    fWBrwPara()

ACTIVATE MSDIALOG oDlg CENTERED

Return(.T.)

/*/{Protheus.doc} fWBrwSIX
Rotina para abrir os alias a serem utilizados pela rotina
@author g.sampaio
@since 10/06/2019
@version P12
@param cSIXTabela	, caractere, tabela que sera buscaremos os indices
@return nulo
/*/

//------------------------------------------------ 
Static Function fWBrwSIX( cSIXTabela )
//------------------------------------------------ 

@ 033, 014 LISTBOX oWBrwSIX Fields HEADER "","Tabela","Ordem","Indice" SIZE 363, 060 OF oDlg PIXEL ColSizes 50,50

// atualizo informacoes do objeto oWBrwSIX
BrwSIXObjeto()

// DoubleClick event
oWBrwSIX:bLDblClick := {|| aWBrwSIX[oWBrwSIX:nAt,1] := !aWBrwSIX[oWBrwSIX:nAt,1],;
    oWBrwSIX:DrawSelect(), BrwSIXValida( oWBrwSIX:nAt ), BrwDeAtualiza( oWBrwSIX:nAt ), BrwParaAtualiza() }

Return()

/*/{Protheus.doc} fWBrwDe
Rotina com os campos do indice
@author g.sampaio
@since 10/06/2019
@version P12
@param Nil
@return nulo
/*/

//------------------------------------------------ 
Static Function fWBrwDe()
//------------------------------------------------ 

@ 118, 011 LISTBOX oWBrwDe Fields HEADER "Sequencia","Campo","Descricao" SIZE 177, 082 OF oDlg PIXEL ColSizes 50,50

// vou atualizar o objeto oWBrwDe
BrwDeObjeto()

Return()

/*/{Protheus.doc} fWBrwPara
Rotina com os campos da tabela que ira montar a chave
@author g.sampaio
@since 10/06/2019
@version P12
@param Nil
@return nulo
/*/

//------------------------------------------------ 
Static Function fWBrwPara()
//------------------------------------------------ 

@ 118, 207 LISTBOX oWBrwPara Fields HEADER "Sequencia","Campo","Descricao" SIZE 178, 080 OF oDlg PIXEL ColSizes 50,50

// atualizo as informacoes do objeto oWBrwPara
BrwParaObjeto()

// DoubleClick event
oWBrwPara:bLDblClick := {|| SeqSeleciona( oWBrwPara:nAT ) }

Return()

/*/{Protheus.doc} RETF3UTIL14
Funcao de retorno da consulta especifica
@author g.sampaio
@since 10/06/2019
@version P12
@param Nil
@return __cRELACI	, caractere, variavel publica da user function UTIL17F3
/*/

User Function RETF3UTIL14( nTipo )

Local cRetorno := Nil

Default nTipo 	:= 0

If nTipo == 1
	cRetorno := __cCDOM
ElseIf nTipo == 2
	cRetorno := val(__nORDEM)
ElseIf nTipo == 3
	cRetorno := __cChave
ElseIf nTipo == 4
	cRetorno := __cRELACI		
EndIf

Return(cRetorno)

/*/{Protheus.doc} Confirma
Funcao para confirmar o retorno da chave
@author g.sampaio
@since 10/06/2019
@version P12
@param cRelacionamentoRetorno, caractere, chave que sera retornada para a consulta
@return nulo
/*/

Static Function Confirmar( cRelacionamentoRetorno )

Default cRelacionamentoRetorno := ""

// verifica se a variavel publica, está populada
If !Empty(__cCDOM)
	
	// reinicio do conteudo da variavel publica
	__cCDOM := ""

EndIf

// verifica se a variavel publica, está populada
If !Empty(__nORDEM)
	
	// reinicio do conteudo da variavel publica
	__nORDEM := "0"

EndIf

// verifica se a variavel publica, está populada
If !Empty(__cRELACI)
	
	// reinicio do conteudo da variavel publica
	__cRELACI := ""

EndIf

If Empty(__cChave)

	__cChave:= ""

Endif

// preencho de acordo com o array aWBrwSIX
// pego o indice marcado
nPos	:= AScan( aWBrwSIX, {|x| x[1] } )

If nPos > 0

	// pego o indice selecionado
	__cCDOM		:= aWBrwSIX[ nPos, 2]
	__nORDEM	:= aWBrwSIX[ nPos, 3]
	__cChave	:= aWBrwSIX[ nPos, 4]

EndIf

// verifica a chave que será retornada pela consulta
If !Empty(cRelacionamentoRetorno)

	// preencho a variável pública
	__cRELACI	:= cRelacionamentoRetorno

EndIf

// fecha a tela
oDlg:End()

Return()

/*/{Protheus.doc} SeqSeleciona
Altera a Sequencia conforme o necessario
@author g.sampaio
@since 10/06/2019
@version P12
@param Nil
@return nulo
/*/

Static Function SeqSeleciona( nPosLin )

Local nPos 		:= 0

Default nPosLin	:= 0

// verifico se ja existe conteudo marcado
nPos := AScan( aWBrwPara, {|x| x[1] == aWBrwDe[oWBrwDe:nAT,1] } )

// verifico se o conteudo foi preenchido e nao esta na mesma linha
If nPos > 0 .And. nPos <> nPosLin 	
	aWBrwPara[nPos,1] := ""
EndIf

// altera a sequencia
aWBrwPara[oWBrwPara:nAT,1] := aWBrwDe[oWBrwDe:nAT,1]

// atualizo o objeto oWBrwPara
oWBrwPara:Refresh()

// vou montar a chave do indice
FormaChave()

Return(.T.)

/*/{Protheus.doc} BrwDeAtualiza
Atualiza o Browse da funcao fWBrwDe
@author g.sampaio
@since 10/06/2019
@version P12
@param Nil
@return nulo
/*/

Static Function BrwDeAtualiza( nPosLin )

Local aIndice	:= {}
Local cIndice	:= ""
Local nPos		:= 0
Local nX		:= 0

Default nPosLin := 0

// pego o indice marcado
nPos	:= AScan( aWBrwSIX, {|x| x[1] } )

// verifico se encontrou o registro
If nPos > 0
    
    // pego o indice selecionado
    cIndice	:= aWBrwSIX[ nPos, 4]

EndIf

// verifico se o indice esta preenchido
If !Empty( cIndice )

	// monto de campos de acordo com os indices
	aIndice := StrToKarr( cIndice, "+" )

	// zero o array
	aWBrwDe := {}

	// percorro os campos
	For nX := 1 To Len( aIndice )

		// monto o array de campos "De"
		Aadd( aWBrwDe, { StrZero( nX, 3 ), aIndice[nX], FWSX3Util():GetDescription( aIndice[nX] ) } )

	Next nX

Else// caso nao encontrar o indice

	// zero o array novamente
	aWBrwDe := {{"","",""}}

EndIf

// verifico se o array aWBrwDe foi preenchido
If Len( aWBrwDe ) > 0

	// atualizo o objeto oWBrwDe
	BrwDeObjeto()

	oWBrwDe:Refresh()
EndIf

Return(.T.)

/*/{Protheus.doc} BrwSIXValida
Funcao para validar o browse da SIX e nao 
permitir que esteja mais de um indice marcado
@author g.sampaio
@since 10/06/2019
@version P12
@param Nil
@return 
/*/

Static Function BrwSIXValida( nPosLin )

Local nPos		:= 0

Default nPosLin := 0

// verifico se existem registros preenchidos
nPos	:= AScan( aWBrwSIX, {|x| x[1] } )

// caso esteja marcado eu desmarco o registro
If nPos > 0 .And. nPos <> nPosLin

	// desmarco o registro, com valor .F. (false)
	aWBrwSIX[ nPos, 1 ] := .F.

EndIf

oWBrwSIX:Refresh()

Return(.T.)

/*/{Protheus.doc} BrwParaAtualiza
Atualiza o Browse da funcao fWBrwPara
@author g.sampaio
@since 10/06/2019
@version P12
@param Nil
@return 
/*/

Static Function BrwParaAtualiza()

Local aSX3Tabela	:= {}
Local cAliasTab		:= FWFldGet("UJN_TABELA")
Local nI			:= 1

// verifico se a tabela esta preenhcida
If !Empty( cAliasTab )

	// retorna todos os campos da tabela, exceto os campos virtuais
	aSX3Tabela := FWSX3Util():GetAllFields( cAliasTab, .F. ) 

	// zero o array
	aWBrwPara := {}

	// percorro os campos da tabela 
	For nI := 1 To Len( aSX3Tabela )

		// preencho o o conteudo do array aWBrwPara
		Aadd( aWBrwPara, { "", aSX3Tabela[nI], FWSX3Util():GetDescription( aSX3Tabela[nI] ) } )

	Next nI

	// verifico se o array foi preenchido
	If Len( aWBrwPara ) > 0

		// atualizo as informacoes do objeto oWBrwPara
		BrwParaObjeto()

		oWBrwPara:Refresh()
	EndIf

Else

	MsgAlert(" Campo <Tabela> não está preenchido!")

EndIf

Return(.T.)

/*/{Protheus.doc} BuscarSIX
Busca os registros da SIX
@author g.sampaio
@since 10/06/2019
@version P12
@param Nil
@return 
/*/

Static Function BuscarSIX( cSIXTabela )

Default cSIXTabela := ""

// zero o array
aWBrwSIX := {}

// posiciono na tabela de indices
SIX->( DbSetOrder(1) )
If SIX->( DbSeek( (AllTrim(cSIXTabela)) ) )

	// percorro os indices da tabela
	While SIX->( !Eof() ) .And. SIX->INDICE == cSIXTabela

		// alimento o array aWBrwSIX com os dados do indice
		Aadd( aWBrwSIX,{ .F., SIX->INDICE, SIX->ORDEM, SIX->CHAVE } )

        SIX->( DbSkip() )
	EndDo

Else// retorno o array vazio

	Aadd(aWBrwSIX,{.F.,"","",""})

EndIf

// atualizo as informacoes do objeto oWBrwSIX
BrwSIXObjeto()
oWBrwSIX:Refresh()

Return()

/*/{Protheus.doc} BrwDeObjeto
Funcao para atualizar o objeto BrwDeObjeto
@author g.sampaio
@since 10/06/2019
@version P12
@param Nil
@return 
/*/

Static Function BrwDeObjeto()

oWBrwDe:SetArray(aWBrwDe)
oWBrwDe:bLine := {|| {;
    aWBrwDe[oWBrwDe:nAt,1],;
    aWBrwDe[oWBrwDe:nAt,2],;
    aWBrwDe[oWBrwDe:nAt,3];
    }}

Return()

/*/{Protheus.doc} BrwParaObjeto
Funcao para atualizar o objeto oWBrwPara
@author g.sampaio
@since 10/06/2019
@version P12
@param Nil
@return 
/*/

Static Function BrwParaObjeto()

oWBrwPara:SetArray(aWBrwPara)
oWBrwPara:bLine := {|| {;
    aWBrwPara[oWBrwPara:nAt,1],;
    aWBrwPara[oWBrwPara:nAt,2],;
    aWBrwPara[oWBrwPara:nAt,3];
    }}

Return()	

/*/{Protheus.doc} BrwSIXObjeto
Funcao para atualizar o objeto oWBrwSIX
@author g.sampaio
@since 10/06/2019
@version P12
@param Nil
@return 
/*/

Static Function BrwSIXObjeto()

Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")

oWBrwSIX:SetArray(aWBrwSIX)
oWBrwSIX:bLine := {|| {;
      If(aWBrwSIX[oWBrwSIX:nAT,1],oOk,oNo),;
      aWBrwSIX[oWBrwSIX:nAt,2],;
      aWBrwSIX[oWBrwSIX:nAt,3],;
      aWBrwSIX[oWBrwSIX:nAt,4];
    }}

Return()

/*/{Protheus.doc} FormaChave
Funcao para montar a chave conforme a tabela de referencia da rotina
@author g.sampaio
@since 10/06/2019
@version P12
@param Nil
@return 
/*/

Static Function FormaChave()

Local aAux 		:= {}
Local cCampo	:= ""
Local nI		:= 0
Local nPos		:= 0

// vou alimentar o array aAux conforme o necessario
AEval( aWBrwPara, { |x| iif( !Empty(x[1]), aAdd( aAux,{ x[1], x[2] } ),  ) } )

// vou ordenar o array auxiliar
ASort( aAux, , , { | x,y | x[1] < y[1] } )

// vou limpar o cGet2 que recebe a chave
cGet2 := ""

For nI := 1 To Len( aAux )

	// defino o campo que estou tratando	
	If "FILIAL" $ aAux[nI,2] // verifico se e campo filial
	
		cCampo := 'xFilial("'+AllTrim(aWBrwSIX[oWBrwSIX:nAT, 2])+'")'
	
	Else // campo comum
	
		cCampo := AllTrim(aAux[nI,2])
	
	EndIf

	// vou fazer a montagem do cGet2
	If !Empty(Alltrim(cGet2)) // verifico se ja esta preenchido
		
		cGet2 += "+" + AllTrim(cCampo)
	
	Else
	
		cGet2 += AllTrim(cCampo)
	
	EndIf

Next nI

oGet2:Refresh()

Return()
