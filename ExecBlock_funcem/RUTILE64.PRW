#Include 'Protheus.ch'
#include "topconn.ch"

/*/{Protheus.doc} RUTILE64
Consulta Especifica TIPTIT para multselecao de TIPOS de titulos
Financeiros
@author Raphael Martins 
@type function
@since 21/09/2022
@version 1.0
@return logical, retorno da consulta
/*/
User Function RUTILE64()

Local lRet := .T.

Static cMvRetor := ""


&(ReadVar()) := U_RUTIL64A()


Return(lRet)

/*/{Protheus.doc} RUTILE64
Funcao para montar a logica de criacao da tela 
de multiselecao de tipos de titulos financeiros
utilizando a funcao F_Opcoes
@author Raphael Martins 
@type function
@since 21/09/2022
@version 1.0
@return logical, retorno da consulta
/*/
User Function RUTIL64A()

Local cTitulo	:= "Tipos de Titulos"
Local cMvParDef	:= ""
Local cVarIni	:= ""
Local nX		:= 1
Local nTamCod	:= TamSX3("E1_TIPO")[1]
Local aDados	:= {}

cVarIni := &(Alltrim(ReadVar()))

SX5->(DbSetOrder(1)) // X5_FILIAL + X5_TABELA + X5_CHAVE
If SX5->(DbSeek(xFilial("SX5")+"05"))

	While SX5->(!Eof()) .AND. SX5->X5_FILIAL == xFilial("SX5") .And. SX5->X5_TABELA == "05"
		
		aadd(aDados, PADR(AllTrim(SX5->X5_CHAVE),nTamCod) + " - " + AllTrim(SX5->X5_DESCRI))
		cMvParDef += PADR(AllTrim(SX5->X5_CHAVE),nTamCod)
		SX5->(DbSkip())
		
	Enddo
	
Endif

cMvRetor := ""

If F_Opcoes(@cVarIni, cTitulo, aDados, cMvParDef, 12, 49, .F., nTamCod, 36)
   
	For nX := 1 To Len(cVarIni) Step nTamCod
	
		If substr(cVarIni, nX, nTamCod) # "***"
			
			If !Empty(cMvRetor)
				cMvRetor += ";"
			EndIf
			
			cMvRetor += substr(cVarIni,nX,nTamCod)
			
		EndIf
		
	Next nX
	
EndIf

&(ReadVar()) := cMvRetor 

Return(.T.)

/*/{Protheus.doc} RUTIL64A
Funcao para retorno da consulta especifica
@type function
@version 1.0 
@author Raphael Martins
@since 21/09/2022
@return return_type, return_description
/*/
User Function RUTIL64B()
Return(cMvRetor)
