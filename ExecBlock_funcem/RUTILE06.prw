#include 'protheus.ch'

/*/{Protheus.doc} RUTILE06
Gera arquivo Excel contendo listagem de boletos bancários
@author TOTVS
@since 13/08/2018
@version P12
@param aDados (array)
@return nulo
/*/

#DEFINE __AHEADER_TITLE__		01	//01 -> Titulo 
#DEFINE __AHEADER_PICTURE__		03	//03 -> Picture
#DEFINE __AHEADER_TYPE__		08	//08 -> Tipo

/*****************************/
User Function RUTILE06(aDados)
/*****************************/
	
Local oFWMSExcel := FWMSExcel():New()

Local aHeader	 := {{"Linha digitável"		,,"@!"						,,,,,"C"},;	//1
					{"Vencimento"			,,"@D"						,,,,,"D"},;	//2
					{"Nosso número"			,,"@!"						,,,,,"C"},;	//3
					{"Valor do documento"	,,"@E 9,999,999,999,999.99"	,,,,,"N"},;	//4
					{"Data do documento"	,,"@D"						,,,,,"D"},;	//5
					{"Número do documento"	,,"@!"						,,,,,"C"},;	//6
					{"Data do processamento",,"@D"						,,,,,"D"},;	//7
					{"Sacado"				,,"@!"						,,,,,"C"},;	//8
					{"Inscrição"			,,"@!"						,,,,,"C"},;	//9
					{"CPF"					,,"@!"						,,,,,"C"},;	//10
					{"Endereço"				,,"@!"						,,,,,"C"},;	//11
					{"Bairro"				,,"@!"						,,,,,"C"},;	//12
					{"CEP"					,,"@!"						,,,,,"C"},;	//13
					{"Cidade"				,,"@!"						,,,,,"C"},;	//14
					{"Estado"				,,"@!"						,,,,,"C"};	//15
					}
Local nX
Local aCols		 := {}
    
Local oMsExcel

Local aCells

Local cType
Local cColumn

Local cFile
Local cFileTMP
    
Local cPicture

Local lTotal

Local nRow
Local nRows
Local nField
Local nFields
    
Local nAlign
Local nFormat
    
Local uCell
        
Local cWorkSheet := "Remessa"
Local cTable     := cWorkSheet
Local lTotalize  := .F.
Local lPicture   := .F.
    
BEGIN SEQUENCE
    
	oFWMSExcel:AddworkSheet(cWorkSheet)
	oFWMSExcel:AddTable(cWorkSheet,cTable)
	        
	nFields := Len(aHeader)

	For nField := 1 To nFields
		cType   := aHeader[nField][__AHEADER_TYPE__]
		nAlign  := IF(cType=="C",1,IF(cType=="N",3,2))
		nFormat := IF(cType=="D",4,IF(cType=="N",2,1))        
		cColumn := aHeader[nField][__AHEADER_TITLE__]
		lTotal  := (lTotalize .and. cType == "N")
		oFWMSExcel:AddColumn(@cWorkSheet,@cTable,@cColumn,@nAlign,@nFormat,@lTotal)
	Next nField
        
	aCells := Array(nFields)
	
	/*aCols := {{"Inf",;						//1 ADADOS[1][1][1][3][2]	"03399.65733 25800.000009 00040.001018 6 76070000014972"
				dDataBase,;						//2 ADADOS[1][1][1][6][4]	05/08/2018	
				"Inf",;							//3 ADADOS[1][1][1][3][3]	"000000000040-0"	
				0,;								//4 ADADOS[1][1][1][6][5]	149.72	
				dDataBase,;						//5 ADADOS[1][1][1][6][3]	15/08/2018	
				"Inf",;							//6 ADADOS[1][1][1][6][11]	"08/2018"	
				dDataBase,;						//7 ADADOS[1][1][1][6][2]	28/02/2018	
				"Inf",;							//8 ADADOS[1][1][1][2][1]	"NILZA DE ALMEIDA NEVES"	
				"Inf",;							//9 ADADOS[1][1][1][2][10]	"000033"	
				"Inf",;							//10 ADADOS[1][1][1][2][7]	"29970733915   "	
				"Inf",;							//11 ADADOS[1][1][1][2][3]	"RUA PATENTINS,74"	
				"Inf",;							//12 ADADOS[1][1][1][2][9]	""	
				"Inf",;							//13 ADADOS[1][1][1][2][6]	"80320270"	
				"Inf",;							//14 ADADOS[1][1][1][2][4]	"CURITIBA"	
				"Inf"}}							//15 ADADOS[1][1][1][2][5]	"PR" */
	
	For nX := 1 To Len(aDados)
		AAdd(aCols,{AllTrim(aDados[nX][1][1][3][2]),;
					aDados[nX][1][1][6][4],;
					aDados[nX][1][1][3][3],;
					aDados[nX][1][1][6][5],;
					aDados[nX][1][1][6][3],;
					aDados[nX][1][1][6][11],;
					aDados[nX][1][1][6][2],;
					aDados[nX][1][1][2][1],;
					aDados[nX][1][1][2][10],;
					aDados[nX][1][1][2][7],;
					aDados[nX][1][1][2][3],;
					aDados[nX][1][1][2][9],;
					Transform(aDados[nX][1][1][2][6],"@R 99999-999"),;
					aDados[nX][1][1][2][4],;
					aDados[nX][1][1][2][5];
		})
	Next nX	
	    
	nRows := Len(aCols)
	For nRow := 1 To nRows
		For nField := 1 To nFields
			uCell := aCols[nRow][nField]
			IF (lPicture)
				cPicture  := aHeader[nField][__AHEADER_PICTURE__]
				IF .NOT.(Empty(cPicture))
					uCell := Transform(uCell,cPicture)
				EndIF
			EndIF
			aCells[nField] := uCell
		Next nField
		oFWMSExcel:AddRow(@cWorkSheet,@cTable,aClone(aCells))
	Next nRow
	    
	oFWMSExcel:Activate()
	        
	cFile := (CriaTrab(NIL, .F.) + ".xml")
        
	While File(cFile)
		cFile := (CriaTrab(NIL, .F.) + ".xml")
	End While
        
	oFWMSExcel:GetXMLFile(cFile)
	oFWMSExcel:DeActivate()
                
	IF .NOT.(File(cFile))
		cFile := ""
		BREAK
	EndIF
        
	cFileTMP := (GetTempPath() + cFile)
	IF .NOT.(__CopyFile(cFile , cFileTMP))
		fErase(cFile)
		cFile := ""
		BREAK
	EndIF
        
	fErase(cFile)
        
	cFile := cFileTMP
        
	IF .NOT.(File(cFile))
		cFile := ""
		BREAK
	EndIF
        
	IF .NOT.(ApOleClient("MsExcel"))
		BREAK
	EndIF
        
	oMsExcel := MsExcel():New()
	oMsExcel:WorkBooks:Open( cFile )
	oMsExcel:SetVisible(.T.)
	oMsExcel := oMsExcel:Destroy()
        
END SEQUENCE
        
oFWMSExcel := FreeObj(oFWMSExcel)
        
Return