#Include 'Protheus.ch'
#include "topconn.ch"

/*/{Protheus.doc} RUTILE65
Consulta Especifica TPFINM para multselecao de PREFIXOS de titulos
Financeiros
@author Raphael Martins 
@type function
@since 21/09/2022
@version 1.0
@return logical, retorno da consulta
/*/
User Function RUTILE65()

Local lRet := .T.

Static cMvRetor := ""


&(ReadVar()) := U_RUTIL65A()



Return(lRet)

/*/{Protheus.doc} RUTILE65
Funcao para montar a logica de criacao da tela 
de multiselecao de tipos de titulos financeiros
utilizando a funcao F_Opcoes
@author Raphael Martins 
@type function
@since 21/09/2022
@version 1.0
@return logical, retorno da consulta
/*/
User Function RUTIL65A()

Local cTitulo	:= "Prefixos de Titulos"
Local cMvParDef	:= ""
Local cVarIni	:= ""
Local nX		:= 1
Local nTamCod	:= TamSX3("E1_PREFIXO")[1]
Local aDados	:= {}

cVarIni := &(Alltrim(ReadVar()))

SX5->(DbSetOrder(1)) // X5_FILIAL + X5_TABELA + X5_CHAVE
If SX5->(DbSeek(xFilial("SX5")+"UP"))

	While SX5->(!Eof()) .AND. SX5->X5_FILIAL == xFilial("SX5") .And. SX5->X5_TABELA == "UP"
		
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

/*/{Protheus.doc} RUTIL65B
Funcao para retorno da consulta especifica
@type function
@version 1.0 
@author Raphael Martins
@since 21/09/2022
/*/
User Function RUTIL65B()
Return(cMvRetor)
