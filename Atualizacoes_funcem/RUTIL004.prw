#Include 'Protheus.ch'
#Include 'Topconn.ch'

/*/{Protheus.doc} RUTIL004
//Consulta padrao de rotas via multi-selecao.
@author Raphael Martins	
@since 16/04/2018
@version 1.0
@type function
/*/
User Function RUTIL004()

Local cTitulo	:= "Rotas"
Local MvParDef	:= ""
Local MvRetor	:= ""      
Local cVarIni	:= ""
Local nX		:= 1
Local nTamCod	:= TamSX3("U34_CODIGO")[1]
Local aDados	:= {}

cVarIni := &(Alltrim(ReadVar()))

U34->(DbSetOrder(1)) // U34_FILIAL + U34_CODIGO 
If U34->(DbSeek(xFilial("U34")))

	While U34->(!Eof()) .AND. U34->U34_FILIAL == xFilial("U34")
		
		aadd(aDados, AllTrim(U34->U34_CODIGO) + " - " + AllTrim(U34->U34_DESCRI))
		MvParDef += AllTrim(U34->U34_CODIGO)
		U34->(DbSkip())
		
	Enddo
	
Endif

If F_Opcoes(@cVarIni, cTitulo, aDados, MvParDef, 12, 49, .F., nTamCod, 36)
	
	For nX := 1 To Len(cVarIni) Step nTamCod
	
		If substr(cVarIni, nX, nTamCod) # "******"
			
			If !Empty(MvRetor)
				MvRetor += ";"
			EndIf
			
			MvRetor += substr(cVarIni,nX,nTamCod)
			
		EndIf
		
	Next nX
	
EndIf

&(ReadVar()) := MvRetor 

Return(.T.)
