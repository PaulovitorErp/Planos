#Include "Totvs.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RUTILE34
Fonte para Classe para leitura de dicionario de dados
Antigo UGetSxFile.prw
@type function
@version 1.0
@author g.sampaio
@since 15/05/2021
/*/
User Function RUTILE34()
Return(nil)

/*/{Protheus.doc} UGetSxFile
Classe para leitura de dicionario de dados
@type class
@version 1.0
@author Leandro Rodrigues
@since 02/12/2019
/*/
	Class UGetSxFile

		Data aCampos

		Method New() Constructor	// Método Construtor
		Method GetInfoSX2() 	   	// Método que retorna informacoes da SX2
		Method GetInfoSX3() 	   	// Método que retorna informacoes da SX3
		Method GetInfoSIX() 	   	// Método que retorna informacoes da SIX
		Method GetInfoSX5() 	   	// Método que retorna informacoes da SX5
		Method GetInfoSX7() 	   	// Método que retorna informacoes da SX7
		Method GetInfoSXA() 	   	// Método que retorna informacoes da SXA

	EndClass

/*/######################################################################
	Metodos de retorno dos dicionarios
//#########################################################################*/

/*/{Protheus.doc} UGetSxFile::New
Construtor da Classe
@type method
@version 1.0
@author Leandro Rodrigues
@since 02/12/2019
/*/
Method New() Class UGetSxFile
Return(Nil)

/*/{Protheus.doc} UGetSxFile::GetInfoSX2
Metodo retorna informacoes SX2
@type method
@version 1.0
@author g.sampaio
@since 12/03/2024
@param cChave, character, Tabela que deverá ser retornada
@return array, Retorna array com campos da SX2
/*/
Method GetInfoSX2(cChave) Class UGetSxFile

	Local aArea     := GetArea()
	Local cSX2      := ""

	Default cChave  := ""

	// inicializo o array de campos
	Self:aCampos := {}

	cSX2 := " SELECT"
	cSX2 += "   X2_CHAVE AS CHAVE,"
	cSX2 += "   X2_ARQUIVO AS ARQUIVO,"
	cSX2 += "   X2_NOME AS NOME,"
	cSX2 += "   X2_MODO AS MODO,"
	cSX2 += "   X2_MODOUN AS MODOUN,"
	cSX2 += "   X2_MODOEMP AS MODOEMP,"
	cSX2 += "   X2_UNICO AS UNICO,"
	cSX2 += "   R_E_C_N_O_ AS RECNOSX2 "
	cSX2 += " FROM "+ RETSQLNAME("SX2")
	cSX2 += " WHERE D_E_L_E_T_ =  ''"

	//Se preenchido chave filtra
	if !Empty(cChave)
		cSX2 += "  AND X2_CHAVE = '" + cChave + "'"
	Endif

	cSX2 += "  ORDER BY X2_CHAVE"

	cSX2 := ChangeQuery(cSX2)

	If Select("QSX2") > 0
		QSX2->(DbCloseArea())
	endif

	MPSysOpenQuery(cSX2, "QSX2")

	While QSX2->(!EOF())

		// percorro os campos da SX3
		While QSX2->(!Eof())
			aadd(Self:aCampos , {AllTrim(QSX2->CHAVE), MontaStruct('SX2')})

			QSX2->(DbSkip())
		EndDo

		QSX2->(DbSkip())
	EndDo

	If Select("QSX2") > 0
		QSX2->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(Self:aCampos)

/*/{Protheus.doc} UGetSxFile::GetInfoSX3
Metodo retorna informacoes SX3
@type method
@version 1.0
@author g.sampaio
@since 12/03/2024
@param cChave, character, Tabela que deverá ser retornada
@param cCampo, character, campo da SX3 que deverá ser retornado
@return array, Retorna array com campos
/*/
Method GetInfoSX3(cChave,cCampo,lValUSO) Class UGetSxFile

	Local aArea     := GetArea()
	Local cSX3      := ""
	Local lUsado	:= .T.

	Default cChave  := ""
	Default cCampo  := ""
	Default lValUSO := .F.

	// inicializo o array de campos
	Self:aCampos := {}

	cSX3 := " SELECT "
	cSX3 += "   X3_CAMPO    AS CAMPO, "
	cSX3 += "   X3_TIPO     AS TIPO, "
	cSX3 += '   X3_TAMANHO  AS "TAMANHO", '
	cSX3 += '   X3_DECIMAL  AS "DECIMAL", '
	cSX3 += "   X3_PICTURE  AS PICTURE, "
	cSX3 += "   X3_CONTEXT  AS CONTEXT, "
	cSX3 += "   X3_TITULO   AS TITULO, "
	cSX3 += "   X3_VALID    AS VALID, "
	cSX3 += "   X3_WHEN     AS MODO, "
	cSX3 += "   X3_WHEN     AS MODO, "
	cSX3 += "   X3_WHEN     AS MODO, "
	cSX3 += "   X3_USADO    AS USADO, "
	cSX3 += "   X3_F3       AS F3, "
	cSX3 += "   X3_CBOX     AS COMBO,"
	cSX3 += "   X3_RELACAO  AS RELACAO, "
	cSX3 += "   X3_DESCRIC  AS DESCRICAO,
	cSX3 += "   X3_ORDEM    AS ORDEM, "
	cSX3 += "   X3_PICTVAR  AS PICTVAR, "
	cSX3 += "   X3_VISUAL   AS VISUAL,  "
	cSX3 += "   X3_FOLDER   AS FOLDER,  "
	cSX3 += "   X3_INIBRW   AS INIBRW,  "
	cSX3 += "   X3_NIVEL    AS NIVEL,  "
	cSX3 += "   R_E_C_N_O_  AS RECNOSX3 "
	cSX3 += " FROM "+ RETSQLNAME("SX3")
	cSX3 += " WHERE D_E_L_E_T_ =  ''"

	//Se preenchido chave filtra registros
	if !Empty(cChave)
		cSX3 += "   AND X3_ARQUIVO = '" + cChave + "'"
	Endif

	//Se preenchido Campo filtra registros
	if !Empty(cCampo)
		cSX3 += "   AND X3_CAMPO = '" + cCampo + "'"
	Endif

	cSX3 += "  ORDER BY X3_ARQUIVO"

	cSX3 := ChangeQuery(cSX3)

	If Select("QSX3") > 0
		QSX3->(DbCloseArea())
	endif

	MPSysOpenQuery(cSX3, "QSX3")

	While QSX3->(!EOF())

		// percorro os campos da SX3
		While QSX3->(!Eof())

			lUsado := .T.

			If lValUSO .And. !X3Uso(QSX3->USADO) 
				lUsado := .F.
			EndIf

			If lUsado
				aadd(Self:aCampos , {AllTrim(QSX3->CAMPO) , MontaStruct('SX3')})
			EndIf

			QSX3->(DbSkip())
		EndDo

		QSX3->(DbSkip())
	EndDo

	If Select("QSX3") > 0
		QSX3->(DbCloseArea())
	endif

	RestArea(aArea)

Return(Self:aCampos)

/*/{Protheus.doc} UGetSxFile::GetInfoSIX
Metodo retorna informacoes SIX
@type method
@version 1.0
@author g.sampaio
@since 12/03/2024
@param cChave, character, Tabela que deverá ser retornada
@param cOrdem, character, Ordem do indice que deverá ser retornado
@return array, Retorna array com oos dados da SIX 
/*/
Method GetInfoSIX(cChave,cOrdem) Class UGetSxFile

	Local aArea     := GetArea()
	Local cSIX      := ""
	Local cDicEmp   := cEmpAnt+'0'

	Default cChave  := ""
	Default cOrdem  := ""

	// inicializo o array de campos
	Self:aCampos := {}

	cSIX := " SELECT"
	cSIX += "   INDICE,"
	cSIX += "   ORDEM,"
	cSIX += "   CHAVE,"
	cSIX += "   DESCRICAO,"
	cSIX += "   F3,"
	cSIX += "   NICKNAME,"
	cSIX += "   SHOWPESQ,"
	cSIX += "   R_E_C_N_O_ AS RECNOSIX"

	//Ajuste porque o RetSqlname
	//nao esta retornando a tabela SXA e SX7
	cSIX += " FROM SIX"+cDicEmp
	cSIX += " WHERE D_E_L_E_T_ =  ''"

	//Se preenchido chave filtra registros
	if !Empty(cChave)
		cSIX += "   AND INDICE = '" + cChave + "'"
	Endif

	//Se preenchido chave filtra registros
	if !Empty(cOrdem)
		cSIX += "   AND ORDEM = '" + cOrdem + "'"
	Endif

	cSIX += "  ORDER BY ORDEM"

	cSIX := ChangeQuery(cSIX)

	If Select("QSIX") > 0
		QSIX->(DbCloseArea())
	endif

	MPSysOpenQuery(cSIX, "QSIX")

	While QSIX->(!EOF())

		// percorro os campos da SX3
		While QSIX->(!Eof())

			aadd(Self:aCampos , {AllTrim(QSIX->INDICE) , MontaStruct('SIX')})

			QSIX->(DbSkip())
		EndDo

		QSIX->(DbSkip())
	EndDo

	If Select("QSIX") > 0
		QSIX->(DbCloseArea())
	endif

	RestArea(aArea)

Return(Self:aCampos)

/*/{Protheus.doc} UGetSxFile::GetInfoSX5
Metodo retorna informacoes SX5
@type method
@version 1.0
@author g.sampaio
@since 12/03/2024
@param cTabela, character, Tabela que deverá ser retornada
@param cChave, character, Chave da SX5 que deverá ser retornado
@return array, Retorna array com campos da SX5
/*/
Method GetInfoSX5(cTabela,cChave) Class UGetSxFile

	Local aArea     := GetArea()
	Local cSX5      := ""

	Default cChave  := ""

	// inicializo o array de campos
	Self:aCampos := {}

	cSX5 := " SELECT"
	cSX5 += "   X5_FILIAL AS FILIAL,"
	cSX5 += "   X5_TABELA AS TABELA,"
	cSX5 += "   X5_CHAVE AS CHAVE,"
	cSX5 += "   X5_DESCRI AS DESCRICAO,"
	cSX5 += "   R_E_C_N_O_ AS RECNOSX5"
	cSX5 += " FROM "+ RETSQLNAME("SX5")
	cSX5 += " WHERE D_E_L_E_T_ =  ''"
	cSX5 += "   AND X5_FILIAL = '" + xFilial("SX5") + "'"

	//Se preenchcTabelaido chave filtra registros
	if !Empty(cTabela)
		cSX5 += "   AND X5_TABELA = '" + cTabela + "'"
	Endif

	//Se preenchido chave filtra registros
	if !Empty(cChave)
		cSX5 += "   AND X5_CHAVE = '" + cChave + "'"
	Endif

	cSX5 += "  ORDER BY X5_TABELA"

	cSX5 := ChangeQuery(cSX5)

	If Select("QSX5") > 0
		QSX5->(DbCloseArea())
	endif

	MPSysOpenQuery(cSX5, "QSX5")

	While QSX5->(!EOF())

		// percorro os campos da SX5
		While QSX5->(!Eof())

			aadd(Self:aCampos , {AllTrim(QSX5->TABELA) , MontaStruct('SX5')})

			QSX5->(DbSkip())
		EndDo

		QSX5->(DbSkip())
	EndDo

	If Select("QSX5") > 0
		QSX5->(DbCloseArea())
	endif

	RestArea(aArea)

Return(Self:aCampos)

/*/{Protheus.doc} UGetSxFile::GetInfoSX7
Metodo retorna informacoes SX7
@type method
@version 1.0
@author g.sampaio
@since 12/03/2024
@param cCampo, character, campo da SX7 que deverá ser retornado
@param cSequencia, character, sequencia da SX7 que deverá ser retornado
@return array, Retorna array com campos da SX7
/*/
Method GetInfoSX7(cCampo,cSequencia) Class UGetSxFile

	Local aArea     := GetArea()
	Local cSX7      := ""
	Local cDicEmp   := cEmpAnt+'0'

	Default cCampo      := ""
	Default cSequencia  := ""

	// inicializo o array de campos
	Self:aCampos := {}

	cSX7 := " SELECT"
	cSX7 += "   X7_CAMPO AS CAMPO,"
	cSX7 += "   X7_SEQUENC AS SEQUENC,"
	cSX7 += "   X7_REGRA AS REGRA,"
	cSX7 += "   X7_CDOMIN AS CDOMIN,"
	cSX7 += "   X7_TIPO AS TIPO,"
	cSX7 += "   X7_SEEK AS SEEK,"
	cSX7 += "   X7_ALIAS AS TABELA,"
	cSX7 += "   X7_ORDEM AS ORDEM,"
	cSX7 += "   X7_CHAVE AS CHAVE,"
	cSX7 += "   X7_CONDIC AS CONDIC,"
	cSX7 += "   R_E_C_N_O_ AS RECNOSX7"

	//Ajuste porque o RetSqlname
	//nao esta retornando a tabela SXA e SX7
	cSX7 += " FROM SX7"+ cDicEmp
	cSX7 += " WHERE D_E_L_E_T_ =  ''"

	//Se preenchcTabelaido chave filtra registros
	if !Empty(cCampo)
		cSX7 += "   AND X7_CAMPO = '" + cCampo + "'"
	Endif

	//Se preenchido chave filtra registros
	if !Empty(cSequencia)
		cSX7 += "   AND X7_SEQUENC = '" + cSequencia + "'"
	Endif

	cSX7 += "  ORDER BY X7_CAMPO"

	cSX7 := ChangeQuery(cSX7)

	If Select("QSX7") > 0
		QSX7->(DbCloseArea())
	endif

	MPSysOpenQuery(cSX7, "QSX7")

	While QSX7->(!EOF())

		// percorro os campos da SX5
		While QSX7->(!Eof())

			aadd(Self:aCampos , {AllTrim(QSX7->CAMPO) , MontaStruct('SX7')})

			QSX7->(DbSkip())
		EndDo

		QSX7->(DbSkip())
	EndDo

	If Select("QSX7") > 0
		QSX7->(DbCloseArea())
	endif

	RestArea(aArea)

Return(Self:aCampos)

/*/{Protheus.doc} UGetSxFile::GetInfoSXA
Metodo retorna informacoes SXA
@type method
@version 1.0
@author g.sampaio
@since 12/03/2024
@param cTabela, character, Tabela que deverá ser retornada
@param cOrdem, character, Ordem da SXA que deverá ser retornado
@return array, retornar array com campos da SXA
/*/
Method GetInfoSXA(cTabela,cOrdem) Class UGetSxFile

	Local aArea     := GetArea()
	Local cSXA      := ""
	Local cDicEmp   := cEmpAnt+'0'

	Default cTabela := ""
	Default cOrdem  := ""

	// inicializo o array de campos
	Self:aCampos := {}

	cSXA := " SELECT"
	cSXA += "   XA_ALIAS AS TABELA,"
	cSXA += "   XA_ORDEM AS ORDEM,"
	cSXA += "   XA_DESCRIC AS DESCRIC,"
	cSXA += "   XA_AGRUP AS AGRUP,"
	cSXA += "   XA_TIPO AS TIPO,"
	cSXA += "   R_E_C_N_O_ AS RECNOSXA"

	//Ajuste porque o RetSqlname
	//nao esta retornando a tabela SXA e SX7
	cSXA += " FROM SXA"+cDicEmp
	cSXA += " WHERE D_E_L_E_T_ =  ''"

	//Se preenchcTabelaido chave filtra registros
	if !Empty(cTabela)
		cSXA += "   AND XA_ALIAS = '" + cTabela + "'"
	Endif

	//Se preenchido chave filtra registros
	if !Empty(cOrdem)
		cSXA += "   AND XA_ORDEM = '" + cOrdem + "'"
	Endif

	cSXA += "  ORDER BY XA_ALIAS"

	cSXA := ChangeQuery(cSXA)

	If Select("QSXA") > 0
		QSXA->(DbCloseArea())
	endif

	MPSysOpenQuery(cSXA, "QSXA")

	While QSXA->(!EOF())

		// percorro os campos da SX5
		While QSXA->(!Eof())

			aadd(Self:aCampos , {AllTrim(QSXA->TABELA) , MontaStruct('SXA')})

			QSXA->(DbSkip())
		EndDo

		QSXA->(DbSkip())
	EndDo

	If Select("QSXA") > 0
		QSXA->(DbCloseArea())
	endif

	RestArea(aArea)

Return(Self:aCampos)

/*/######################################################################
	Instancia classes dos dicionarios
	#########################################################################*/

/*/{Protheus.doc} SX3StrDic
Classe de estrutura da SX3
@type class
@version 1.0
@author g.sampaio
@since 12/03/2024
/*/
	Class SX3StrDic

		Data cTitulo
		Data cCampo
		Data cOrdem
		Data cDescri
		Data cPicture
		Data nTamanho
		Data nDecimal
		Data cContext
		Data cValid
		Data cWhen
		Data cUsado
		Data cTipo
		Data cF3
		Data cCBox
		Data cRelacao
		Data cPictVar
		Data cVisual
		Data cFolder
		Data cIniBrw
		Data nNivel
		Data cRecnoSX3

		Method New() Constructor

	EndClass

/*/{Protheus.doc} SX3StrDic::New
Método Construtor da Classe SX3Struct
@type method
@version 1.0
@author g.sampaio
@since 12/03/2024
/*/
Method New() Class SX3StrDic
Return(Nil)

/*/{Protheus.doc} SX2StrDic
Classe de estrutura da SX2
@type class
@version 1.0
@author g.sampaio
@since 12/03/2024
/*/
	Class SX2StrDic

		Data cChave
		Data cArquivo
		Data cNome
		Data cModo
		Data cModoUn
		Data cModoEmp
		Data cUnico
		Data cRecnoSX2

		Method New() Constructor

	EndClass

/*/{Protheus.doc} SX2StrDic::New
Método Construtor da Classe SX2Struct
@type method
@version 1.0
@author g.sampaio
@since 12/03/2024
/*/
Method New() Class SX2StrDic
Return(Nil)

/*/{Protheus.doc} SIXStrDic
Classe de estrutura da SIX
@type class
@version 1.0
@author g.sampaio
@since 12/03/2024
/*/
	Class SIXStrDic

		Data cIndice
		Data cOrdem
		Data cChave
		Data cDescricao
		Data cF3
		Data cNickname
		Data cShowPesq
		Data cRecnoSIX

		Method New() Constructor

	EndClass

/*/{Protheus.doc} SIXStrDic::New
Método Construtor da Classe SIXStruct
@type method
@version 1.0
@author g.sampaio
@since 12/03/2024
/*/
Method New() Class SIXStrDic
Return(Nil)

/*/{Protheus.doc} SX5StrDic
Classe de estrutura da SX5
@type class
@version 1.0
@author g.sampaio
@since 12/03/2024
/*/
	Class SX5StrDic

		Data cFilUsr
		Data cTabela
		Data cChave
		Data cDescricao
		Data cRecnoSX5

		Method New() Constructor

	EndClass

/*/{Protheus.doc} SX5StrDic::New
Método Construtor da Classe SX5StrDic
@type method
@version 1.0
@author g.sampaio
@since 12/03/2024
/*/
Method New() Class SX5StrDic
Return(Nil)

/*/{Protheus.doc} SX7StrDic
Classe de estrutura da SX7
@type class
@version 1.0
@author g.sampaio
@since 12/03/2024
/*/
	Class SX7StrDic

		Data cCampo
		Data cSequenc
		Data cRegra
		Data cCDomin
		Data cTipo
		Data cSeek
		Data cAlias
		Data cOrdem
		Data cChave
		Data cCondic
		Data cRecnoSX7

		Method New() Constructor

	EndClass

/*/{Protheus.doc} SX7StrDic::New
Método Construtor da Classe SX7StrDic
@type method
@version 1.0
@author g.sampaio
@since 12/03/2024
/*/
Method New() Class SX7StrDic
Return(Nil)

/*/{Protheus.doc} SXAStrDic
Classe de estrutura da SXA
@type class
@version 1.0
@author g.sampaio
@since 12/03/2024
/*/
	Class SXAStrDic

		Data cAlias
		Data cOrdem
		Data cDescric
		Data cAgrup
		Data cTipo
		Data cRecnoSXA

		Method New() Constructor

	EndClass

/*/{Protheus.doc} SXAStrDic::New
Método Construtor da Classe SXAStrDic
@type method
@version 1.0
@author g.sampaio
@since 12/03/2024
/*/
Method New() Class SXAStrDic
Return(Nil)

/*/######################################################################
	Monta estruturas de retorno
	##########################################################################*/

/*/{Protheus.doc} MontaStruct
Funcao monta estrutura do dicionario (SX2, SX3, SIX, SX5, SX7, SXA)
@type function
@version 1.0
@author g.sampaio
@since 12/03/2024
@param cStrSx, character, tabela que deverá ser retornada
@return object, retorno o objeto da estrutura do dicionario
/*/
Static Function MontaStruct(cStrSx)

	Local oStruct := NIL

	//Estrutura de qual dicionario
	if cStrSx == "SX2"

		// crio o objeto com a estrutura da SX3
		oStruct             := SX2StrDic():New()

		oStruct:cChave      := AllTrim(QSX2->CHAVE)
		oStruct:cArquivo    := AllTrim(QSX2->ARQUIVO)
		oStruct:cNome       := AllTrim(QSX2->NOME)
		oStruct:cModo       := AllTrim(QSX2->MODO)
		oStruct:cModoUn     := AllTrim(QSX2->MODOUN)
		oStruct:cModoEmp    := AllTrim(QSX2->MODOEMP)
		oStruct:cUnico      := AllTrim(QSX2->UNICO)
		oStruct:cRecnoSX2   := QSX2->RECNOSX2

	Elseif cStrSx == "SX3"

		// crio o objeto com a estrutura da SX3
		oStruct := SX3StrDic():New()

		oStruct:cTitulo     := AllTrim(QSX3->TITULO)
		oStruct:cCampo      := AllTrim(QSX3->CAMPO)
		oStruct:cOrdem      := QSX3->ORDEM
		oStruct:cDescri     := QSX3->DESCRICAO
		oStruct:cPicture    := QSX3->PICTURE
		oStruct:nTamanho    := QSX3->TAMANHO
		oStruct:nDecimal    := QSX3->DECIMAL
		oStruct:cContext    := QSX3->CONTEXT
		oStruct:cValid      := QSX3->VALID
		oStruct:cWhen       := QSX3->MODO
		oStruct:cUsado      := QSX3->USADO
		oStruct:cTipo       := QSX3->TIPO
		oStruct:cF3         := QSX3->F3
		oStruct:cCBox       := QSX3->COMBO
		oStruct:cRelacao    := QSX3->RELACAO
		oStruct:cPictVar    := QSX3->PICTVAR
		oStruct:cVisual     := QSX3->VISUAL
		oStruct:cFolder     := QSX3->FOLDER
		oStruct:cIniBrw     := QSX3->INIBRW
		oStruct:nNivel      := QSX3->NIVEL
		oStruct:cRecnoSX3   := QSX3->RECNOSX3

	elseif cStrSx == "SIX"

		// crio o objeto com a estrutura da SX3
		oStruct := SIXStrDic():New()

		oStruct:cIndice      := QSIX->INDICE
		oStruct:cOrdem       := QSIX->ORDEM
		oStruct:cChave       := Alltrim(QSIX->CHAVE)
		oStruct:cDescricao   := Alltrim(QSIX->DESCRICAO)
		oStruct:cF3          := QSIX->F3
		oStruct:cNickname    := QSIX->NICKNAME
		oStruct:cRecnoSIX    := QSIX->RECNOSIX

	elseif cStrSx == "SX5"

		// crio o objeto com a estrutura da SX3
		oStruct := SX5StrDic():New()

		oStruct:cFilUsr      := QSX5->FILIAL
		oStruct:cTabela      := Alltrim(QSX5->TABELA)
		oStruct:cChave       := Alltrim(QSX5->CHAVE)
		oStruct:cDescricao   := Alltrim(QSX5->DESCRICAO)
		oStruct:cRecnoSX5    := QSX5->RECNOSX5

	elseif cStrSx == "SX7"

		// crio o objeto com a estrutura da SX3
		oStruct := SX7StrDic():New()

		oStruct:cCampo        := QSX7->CAMPO
		oStruct:cSequenc      := QSX7->SEQUENC
		oStruct:cRegra        := QSX7->REGRA
		oStruct:cCDomin       := QSX7->CDOMIN
		oStruct:cTipo         := QSX7->TIPO
		oStruct:cSeek         := QSX7->SEEK
		oStruct:cAlias        := QSX7->TABELA
		oStruct:cOrdem        := QSX7->ORDEM
		oStruct:cChave        := QSX7->CHAVE
		oStruct:cCondic       := QSX7->CONDIC
		oStruct:cRecnoSX7     := QSX7->RECNOSX7

	elseif cStrSx == "SXA"

		// crio o objeto com a estrutura da SX3
		oStruct := SXAStrDic():New()

		oStruct:cAlias        := QSXA->TABELA
		oStruct:cOrdem        := QSXA->ORDEM
		oStruct:cDescric      := QSXA->DESCRIC
		oStruct:cAgrup        := QSXA->AGRUP
		oStruct:cTipo         := QSXA->TIPO
		oStruct:cRecnoSXA     := QSXA->RECNOSXA

	Endif

Return(oStruct)
