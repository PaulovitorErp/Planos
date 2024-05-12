#Include 'Protheus.ch'
#include "topconn.ch"

/*/{Protheus.doc} RCPGE025
Consulta Especifica para multselecao de servicos
@author Raphael Martins
@since 06/11/2019
@version P12
@param nulo
@return nulo
/*/
User Function RCPGE025()

Local cColuna	:= "Servicos"
Local MvParDef	:= ""
Local MvRetor	:= ""      
Local cVarIni	:= ""
Local cQry      := ""
Local nX		:= 1
Local nTamCod	:= TamSX3("B1_COD")[1]
Local aDados	:= {}

Private cRotina := "Servicos"
//////////////////////////////////////////////////////////
///////////// CONSULTO OS SERVICOS CADASTRADOS //////////
/////////////////////////////////////////////////////////
cQry := " SELECT "
cQry += " B1_COD    AS CODIGO, "
cQry += " B1_DESC   AS DESCRICAO "
cQry += " FROM "
cQry += RetSQLName("SB1")
cQry += " WHERE "
cQry += " D_E_L_E_T_ = ' ' "
cQry += " AND B1_FILIAL = '" + xFilial("SB1") + "' "
cQry += " AND B1_TIPO = 'SV' "
cQry += " ORDER BY CODIGO "

If Select("QRYSB1") > 0
    QRYSB1->(dbCloseArea())
EndIf

cQry := Changequery(cQry)
TcQuery cQry NEW ALIAS "QRYSB1"
    
cVarIni := &(Alltrim(ReadVar()))
 

While QRYSB1->(!Eof())
		
    aadd(aDados, QRYSB1->CODIGO + " - " + AllTrim(QRYSB1->DESCRICAO))
    MvParDef += QRYSB1->CODIGO 

    QRYSB1->(DbSkip())
		
Enddo

DbSelectArea("SB1")
SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD

If F_Opcoes(@cVarIni, cColuna, aDados, MvParDef,  12, 49, .F., nTamCod, 36)
	
	For nX := 1 To Len(cVarIni) Step nTamCod
	
		If substr(cVarIni, nX, nTamCod) # Replicate("*",nTamCod)
			
			If !Empty(MvRetor)
				MvRetor += ";"
			EndIf
			
			MvRetor += substr(cVarIni,nX,nTamCod)
			
		EndIf
		
	Next nX
	
EndIf

&(ReadVar()) := MvRetor 

Return(.T.)
