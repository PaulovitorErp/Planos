#Include 'Protheus.ch'

/*/{Protheus.doc} RCPGA018
Consulta específica Multi seleção de tipos de planos
de cemiterio
@type function
@version 
@author Wellington Gonçalves
@since 20/04/2016
@return logico, retorno verdadeiro fixo
/*/
User Function RCPGA018()

	Local cTitulo	:= "Tipos de Planos"
	Local cMvParDef	:= ""
	Local cVarIni	:= ""
	Local nX		:= 1
	Local nTamCod	:= TamSX3("U05_CODIGO")[1]
	Local aDados	:= {}

	Static cMvRetor	:= ""

	// verifico se a variavel ja tem conteudo
	If !Empty(cMvRetor)

		// limpo o conteudo da variavel
		cMvRetor := ""

	EndIf

	U05->(DbSetOrder(1)) // U05_FILIAL + U05_CODIGO
	If U05->(DbSeek(xFilial("U05")))

		While U05->(!Eof()) .AND. U05->U05_FILIAL == xFilial("U05")

			aadd(aDados, AllTrim(U05->U05_CODIGO) + " - " + AllTrim(U05->U05_DESCRI))
			cMvParDef += AllTrim(U05->U05_CODIGO)
			U05->(DbSkip())

		Enddo

	Endif

	If F_Opcoes(@cVarIni, cTitulo, aDados, cMvParDef, 12, 49, .F., nTamCod, 36)

		For nX := 1 To Len(cVarIni) Step nTamCod

			If substr(cVarIni, nX, nTamCod) # "******"

				If !Empty(cMvRetor)
					cMvRetor += ";"
				EndIf

				cMvRetor += substr(cVarIni,nX,nTamCod)

			EndIf

		Next nX

	EndIf

Return(.T.)

/*/{Protheus.doc} RCPGA18A
Funcao para retorno da consulta especifica
@type function
@version 
@author g.sampaio
@since 04/03/2020
@return return_type, return_description
/*/
User Function RCPGA18A()
Return(cMvRetor)