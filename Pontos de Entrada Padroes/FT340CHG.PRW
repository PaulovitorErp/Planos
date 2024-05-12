#include "totvs.ch"

/*/{Protheus.doc} FT340CHG
Ponto de Entrada para mudar o nome do arquivo durante
a gravação do arquivo no banco de conhecimento.
@type function
@version 1.0
@author g.sampaio
@since 03/04/2024
@return character, retorno o nome do arquivo
/*/
User Function FT340CHG()

	Local cRetorno      := ""   
    Local cDirDocs      := MsDocPath()
	Local cNomeArquivo  := ParamIXB[01]

    If File(cDirDocs + cNomeArquivo)
        cRetorno := cNomeArquivo + "_" + DToS(Date()) + "_" + StrTran(Time(),":","") 
    Else
        cRetorno := cNomeArquivo
    EndIf

Return(cRetorno)
