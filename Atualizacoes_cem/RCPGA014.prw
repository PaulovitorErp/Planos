#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ RCPGA014 บ Autor ณ Wellington Gon็alves		   บ Dataณ 06/04/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Rotina de reajuste de contratos									  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function RCPGA014()

Local aArea			:= GetArea()
Local aAreaU00		:= U00->(GetArea())
Local cPerg 		:= "RCPGA014"
Local cContratoDe	:= ""
Local cContratoAte	:= ""
Local cPlano		:= ""
Local cIndice		:= ""
Local lContinua		:= .T.
Local nIndice		:= 0

// cria as perguntas na SX1
AjustaSx1(cPerg)

// enquanto o usuแrio nใo cancelar a tela de perguntas
While lContinua
	
	// chama a tela de perguntas
	lContinua := Pergunte(cPerg,.T.)
	
	if lContinua 
	
		cContratoDe 	:= MV_PAR01
		cContratoAte	:= MV_PAR02 
		cPlano			:= MV_PAR03
		cIndice			:= MV_PAR04  
		
		if ValidParam(cContratoDe,cContratoAte,cPlano,cIndice,@nIndice) 
					
			MsAguarde( {|| ConsultaCTR(cContratoDe,cContratoAte,cPlano,cIndice,nIndice)}, "Aguarde", "Consultando os contratos...", .F. )
		
		endif
		
	endif
	
EndDo

RestArea(aAreaU00)
RestArea(aArea)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ ValidParam บ Autor ณ Wellington Gon็alves	   บ Dataณ 06/04/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que valida os parโmetros informados.						  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ValidParam(cContratoDe,cContratoAte,cPlano,cIndice,nIndice) 

Local lRet := .F.

// verifico se foram preenchidos todos os parโmetros
if Empty(cContratoDe) .AND. Empty(cContratoAte) 
	Alert("Informe o intervalo dos contratos!")
elseif Empty(cPlano)
	Alert("Informe o plano!")
elseif Empty(cIndice)
		Alert("Informe o ํndice!")
else
	
	// chamo fun็ใo pra encontrar o ํndice INCC que serแ aplicado
	nIndice := BuscaIndice(cIndice)
		
	// ้ obrigat๓rio existir um ํndice para ser aplicado
	if nIndice > 0
		lRet := .T.
	else
		Alert("Nใo foi encontrado ํndice para os ๚ltimos 12 meses!")
	endif
	
endif

Return(lRet) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ ConsultaCTR บ Autor ณ Wellington Gon็alves	   บ Dataณ 06/04/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que consulta os contratos aptos a serem reajustados		  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ConsultaCTR(cContratoDe,cContratoAte,cPlano,cIndice,nIndice)

Local aButtons	:= {}
Local aObjects 	:= {}
Local aSizeAut	:= MsAdvSize()
Local aInfo		:= {}
Local aPosObj	:= {}
Local oGrid
Static oDlg

//Largura, Altura, Modifica largura, Modifica altura
aAdd( aObjects, { 100,	100, .T., .T. } ) //Browse

aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE "Contratos a serem reajustados" From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] COLORS 0, 16777215 PIXEL

EnchoiceBar(oDlg, {|| ConfirmaReajuste(oGrid,cIndice,nIndice)},{|| oDlg:End()},,aButtons)

// crio o grid de bicos
oGrid := MsGridCTR(aPosObj)

// duplo clique no grid
oGrid:oBrowse:bLDblClick := {|| DuoClique(oGrid)}

// caso nใo tenha encontrato tํtulos
if !RefreshGrid(oGrid,cContratoDe,cContratoAte,cPlano,cIndice,nIndice)
	
	Alert("Nใo foram encontrados contratos para serem reajustados!")
	oDlg:End()
	
endif

ACTIVATE MSDIALOG oDlg CENTERED

Return() 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ MsGridCTR บ Autor ณ Wellington Gon็alves	   		 Dataณ 15/04/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que cria o grid de contratos								  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function MsGridCTR(aPosObj)

Local nX			:= 1
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {"MARK","CONTRATO","PARCINI","PARCFIM","PERCENTUAL","ACRINI","ACRFIM","VALADIC"}
Local aAlterFields 	:= {}

For nX := 1 To Len(aFields)
	
	if aFields[nX] == "MARK" 
		Aadd(aHeaderEx, {"","MARK","@BMP",2,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "CONTRATO"
		Aadd(aHeaderEx, {"Contrato","CONTRATO","@!",6,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "PARCINI"
		Aadd(aHeaderEx, {"Parcela inicial","PARCINI",PesqPict("SE1","E1_PARCELA"),TamSX3("E1_PARCELA")[1],TamSX3("E1_PARCELA")[2],"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "PARCFIM"
		Aadd(aHeaderEx, {"Parcela final","PARCFIM",PesqPict("SE1","E1_PARCELA"),TamSX3("E1_PARCELA")[1],TamSX3("E1_PARCELA")[2],"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "PERCENTUAL"
		Aadd(aHeaderEx, {"% Reajuste","PERCENTUAL","@E 999.99",6,2,"","€€€€€€€€€€€€€€","N","","","",""})
	elseif aFields[nX] == "ACRINI"
		Aadd(aHeaderEx, {"Valor atual acrescimo","ACRINI",PesqPict("SE1","E1_ACRESC"),TamSX3("E1_ACRESC")[1],TamSX3("E1_ACRESC")[2],"","€€€€€€€€€€€€€€","N","","","",""})
	elseif aFields[nX] == "ACRFIM"
		Aadd(aHeaderEx, {"Valor acresicmo reajustado","ACRFIM",PesqPict("SE1","E1_ACRESC"),TamSX3("E1_ACRESC")[1],TamSX3("E1_ACRESC")[2],"","€€€€€€€€€€€€€€","N","","","",""})
	elseif aFields[nX] == "VALADIC"
		Aadd(aHeaderEx, {"Valor adicional","VALADIC",PesqPict("SE1","E1_ACRESC"),TamSX3("E1_ACRESC")[1],TamSX3("E1_ACRESC")[2],"","€€€€€€€€€€€€€€","N","","","",""})		
	endif
	
Next nX

// Define field values
For nX := 1 To Len(aHeaderEx)
	
	if aHeaderEx[nX,2] == "MARK"
		Aadd(aFieldFill, "UNCHECKED")
	elseif aHeaderEx[nX,8] == "C"
		Aadd(aFieldFill, "")
	elseif aHeaderEx[nX,8] == "N"
		Aadd(aFieldFill, 0)
	elseif aHeaderEx[nX,8] == "D"
		Aadd(aFieldFill, CTOD("  /  /    "))
	elseif aHeaderEx[nX,8] == "L"
		Aadd(aFieldFill, .F.)
	endif
	
Next nX

Aadd(aFieldFill, .F.)
Aadd(aColsEx, aFieldFill)

Return(MsNewGetDados():New( aPosObj[1,1], aPosObj[1,2], aPosObj[1,3], aPosObj[1,4], GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx))

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ RefreshGrid บ Autor ณ Wellington Gon็alves  		 Dataณ 15/04/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo atualiza o grid de contratos								  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function RefreshGrid(oGrid,cContratoDe,cContratoAte,cPlano,cIndice,nIndice)

Local lRet				:= .F.
Local cQry 				:= ""
Local aFieldFill		:= {}
Local nValorAdicional	:= 0

// fun็ใo que cria a string com a query de contratos a serem reajustados
cQry := QryCTR(cContratoDe,cContratoAte,cIndice,cPlano,.T.)

// verifico se nใo existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

// fun็ใo que converte a query gen้rica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

// se existir contratos a serem reajustados
if QRY->(!Eof())

	oGrid:Acols := {}
	lRet 		:= .T. 

	While QRY->(!Eof()) 
	
		aFieldFill := {}
		
		nValorAdicional := (QRY->VALOR + QRY->ACRESCIMO) * (nIndice / 100)  
		
		aadd(aFieldFill, "CHECKED")	
		aadd(aFieldFill, QRY->CONTRATO)
		aadd(aFieldFill, QRY->PARCELA_INICIAL)
		aadd(aFieldFill, QRY->PARCELA_FINAL)
		aadd(aFieldFill, nIndice)
		aadd(aFieldFill, QRY->ACRESCIMO)
		aadd(aFieldFill, QRY->ACRESCIMO + nValorAdicional)
		aadd(aFieldFill, nValorAdicional)
		Aadd(aFieldFill, .F.)
		aadd(oGrid:Acols,aFieldFill) 
			
		QRY->(DbSkip()) 
		
	EndDo
	
	oGrid:oBrowse:Refresh() 
		
endif

// fecho o alias temporario criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ QryCTR บ Autor ณ Wellington Gon็alves  			 Dataณ 15/04/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que monta a consutla SQL									  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function QryCTR(cContratoDe,cContratoAte,cIndice,cPlano,lAgrupa)

Local cQry 		   	:= ""     
Local cPulaLinha	:= chr(13)+chr(10)     
Local cTipoTitCTR	:= SuperGetMv("MV_XTIPOCT",.F.,"AT") // tipo do tํtulo que serแ reajustado 
Local nModReajuste	:= SuperGetMv("MV_XMODREA",.F.,1) // Modelo de Reajuste 1 = Considera Financeiro, 2=Considera Ativacao


//--------------------------------------------------------------------------------------------------------------
// Considera parcelas do financeiro para saber a data de pr๓ximo reajuste e quais a parcelas serao reajustadas
// Esse modelo deve ser utilizado para clientes que possuem todos historico financeiro importado
//--------------------------------------------------------------------------------------------------------------
if nModReajuste == 1
	
	cQry := " SELECT " 																										+ cPulaLinha
	cQry += " U00.U00_CODIGO CONTRATO, "																					+ cPulaLinha

	if lAgrupa
		cQry += " MIN(SE1.E1_PARCELA) AS PARCELA_INICIAL, " 																+ cPulaLinha
		cQry += " MAX(SE1.E1_PARCELA) AS PARCELA_FINAL, " 																	+ cPulaLinha 
		cQry += " SUM(SE1.E1_VALOR) AS VALOR, " 																			+ cPulaLinha 
		cQry += " SUM(SE1.E1_ACRESC) AS ACRESCIMO " 																		+ cPulaLinha
	else
		cQry += " SE1.E1_PREFIXO PREFIXO, " 																				+ cPulaLinha
		cQry += " SE1.E1_NUM NUMERO, " 																						+ cPulaLinha
		cQry += " SE1.E1_PARCELA PARCELA, " 																				+ cPulaLinha
		cQry += " SE1.E1_TIPO TIPO, " 																						+ cPulaLinha
		cQry += " SE1.E1_VENCTO VENCIMENTO, " 																				+ cPulaLinha
		cQry += " SE1.E1_VALOR VALOR, " 																					+ cPulaLinha
		cQry += " SE1.E1_SALDO SALDO, " 																					+ cPulaLinha
		cQry += " SE1.E1_ACRESC ACRESCIMO, " 																				+ cPulaLinha
		cQry += " SE1.E1_DECRESC DECRESCIMO " 																				+ cPulaLinha
	endif

	cQry += " FROM " 																										+ cPulaLinha
	cQry += + RetSqlName("U00") + " U00 " 																					+ cPulaLinha
	cQry += " INNER JOIN " 																									+ cPulaLinha
	cQry += + RetSqlName("SE1") + " SE1 " 																					+ cPulaLinha
	cQry += " INNER JOIN " 																									+ cPulaLinha
	cQry += "     ( " 																										+ cPulaLinha
	cQry += " 		SELECT " 																								+ cPulaLinha 
	cQry += " 		U00.U00_CODIGO AS CONTRATO, " 																			+ cPulaLinha 
	cQry += " 		MIN(ISNULL(REAJUSTES.ULTIMO_REAJUSTE,SUBSTRING(SE1.E1_VENCTO,1,4) + " 									+ cPulaLinha 
	cQry += " 		SUBSTRING(SE1.E1_VENCTO,5,2))) AS ULTIMA_REFERENCIA  " 												+ cPulaLinha 
	cQry += " 		FROM " 																									+ cPulaLinha 
	cQry += +		RetSqlName("U00") + " U00 " 																			+ cPulaLinha
	cQry += " 		INNER JOIN " 																							+ cPulaLinha
	cQry += +		RetSqlName("SE1") + " SE1 " 																			+ cPulaLinha
	cQry += " 			ON( " 																								+ cPulaLinha
	cQry += " 				SE1.D_E_L_E_T_ <> '*' " 																		+ cPulaLinha 
	cQry += " 				AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' " 													+ cPulaLinha	 
	cQry += " 				AND U00.U00_CODIGO = SE1.E1_XCONTRA " 															+ cPulaLinha 
	cQry += " 				AND U00.U00_DTATIV <> SE1.E1_VENCTO " 															+ cPulaLinha
	cQry += " 				AND SE1.E1_TIPO = '" + cTipoTitCTR + "' " 														+ cPulaLinha
	cQry += " 			) " 																								+ cPulaLinha
	cQry += " 		LEFT JOIN " 																							+ cPulaLinha 
	cQry += " 			( " 																								+ cPulaLinha
	cQry += " 				SELECT " 																						+ cPulaLinha 
	cQry += " 				MAX(SUBSTRING(U20_REFINI,3,4) || SUBSTRING(U20_REFINI,1,2) ) ULTIMO_REAJUSTE, " 				+ cPulaLinha 
	cQry += " 				U20.U20_CONTRA AS CONTRATO " 																	+ cPulaLinha 
	cQry += " 				FROM " 																							+ cPulaLinha 
	cQry += +				RetSqlName("U20") + " U20 " 																	+ cPulaLinha 
	cQry += " 				WHERE " 																						+ cPulaLinha 
	cQry += " 				U20.D_E_L_E_T_ <> '*' " 																		+ cPulaLinha 
	cQry += " 				AND U20.U20_FILIAL = '" + xFilial("U20") + "' " 												+ cPulaLinha 
	cQry += " 				GROUP BY U20.U20_CONTRA " 																		+ cPulaLinha 
	cQry += " 			) REAJUSTES " 																						+ cPulaLinha 
	cQry += " 		ON REAJUSTES.CONTRATO = U00.U00_CODIGO " 																+ cPulaLinha 
	cQry += " 		WHERE " 																								+ cPulaLinha 
	cQry += " 		U00.D_E_L_E_T_ <> '*' " 																				+ cPulaLinha 
	cQry += " 		AND U00.U00_FILIAL = '" + xFilial("U00") + "' " 														+ cPulaLinha 
	cQry += " 		AND U00.U00_REAJUS = 'V' " 																				+ cPulaLinha 
	cQry += " 		AND U00.U00_STATUS IN ('A','S') "	 																	+ cPulaLinha 

	// tratamento para a integracao de empresas
	if U00->(FieldPos("U00_TPCONT")) > 0
		cQry += " 		AND U00.U00_TPCONT <> '2' "	 																	+ cPulaLinha 
	endIf

	cQry += " 		AND U00.U00_DTATIV <> ' ' " 																			+ cPulaLinha 
	cQry += " 		AND U00.U00_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' " 							+ cPulaLinha 

	if !Empty(cPlano)
		cQry += " 	AND U00.U00_PLANO IN " + FormatIn( AllTrim(cPlano),";") 		 										+ cPulaLinha		
	endif

	cQry += " 		GROUP BY U00.U00_CODIGO "													 							+ cPulaLinha
	cQry += " 	) AS REFERENCIA " 																							+ cPulaLinha
	cQry += " 	ON( " 																										+ cPulaLinha
	cQry += " 		SE1.E1_XCONTRA = REFERENCIA.CONTRATO " 																	+ cPulaLinha
	cQry += "       AND LEFT(CONVERT(varchar, DateAdd(Month,-12,CAST(SE1.E1_VENCTO AS DATETIME)) ,112),6) " 				+ cPulaLinha
	cQry += " 		>= REFERENCIA.ULTIMA_REFERENCIA  " 																		+ cPulaLinha	 
	cQry += "       AND LEFT(CONVERT(varchar, DateAdd(Month,-11,CAST('" + DTOS(dDataBase) + "' AS DATETIME)) ,112),6) "  	+ cPulaLinha 
	cQry += " 		>= REFERENCIA.ULTIMA_REFERENCIA " 																		+ cPulaLinha
	cQry += " 	) " 																										+ cPulaLinha
	cQry += " 	ON( " 																										+ cPulaLinha
	cQry += " 		SE1.D_E_L_E_T_ <> '*' " 																				+ cPulaLinha 
	cQry += " 		AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' " 															+ cPulaLinha 
	cQry += " 		AND SE1.E1_XCONTRA = U00.U00_CODIGO " 																	+ cPulaLinha 
	cQry += " 		AND SE1.E1_VENCTO <> U00.U00_DTATIV " 																	+ cPulaLinha
	cQry += " 		AND SE1.E1_SALDO > 0 " 																					+ cPulaLinha 
	cQry += " 		AND SE1.E1_TIPO = '" + cTipoTitCTR + "' " 																+ cPulaLinha
	cQry += " 		AND SE1.E1_PARCELA >= '013'	"																			+ cPulaLinha		
	cQry += " 	) " 																										+ cPulaLinha
	cQry += " WHERE " 																										+ cPulaLinha
	cQry += " U00.D_E_L_E_T_ <> '*' " 																						+ cPulaLinha
	cQry += " AND U00.U00_FILIAL = '" + xFilial("U00") + "' " 																+ cPulaLinha
	cQry += " AND U00.U00_INDICE = '" + cIndice + "' "												 						+ cPulaLinha
	cQry += " AND U00.U00_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' " 								+ cPulaLinha 
	cQry += " AND U00.U00_REAJUS = 'V' " 																					+ cPulaLinha 
	cQry += " AND U00.U00_STATUS IN ('A','S') "	 																			+ cPulaLinha 

	// tratamento para a integracao de empresas
	if U00->(FieldPos("U00_TPCONT")) > 0
		cQry += " 		AND U00.U00_TPCONT <> '2' "	 																	+ cPulaLinha 
	endIf

	cQry += " AND U00.U00_DTATIV <> ' ' " 																					+ cPulaLinha

	if !Empty(cPlano)
		cQry += " 	AND U00.U00_PLANO IN " + FormatIn( AllTrim(cPlano),";") 		 										+ cPulaLinha		
	endif

	if lAgrupa
		cQry += " GROUP BY U00.U00_CODIGO " 																				+ cPulaLinha
		cQry += " ORDER BY VALOR,U00.U00_CODIGO " 																			+ cPulaLinha
	else
		cQry += " ORDER BY SE1.E1_VENCREA,VALOR,SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO " 									+ cPulaLinha
	endif

//------------------------------------------------------------------------------------------------------------------------
// Considera historico de reajuste e caso nao tenha considera data de ativacao do contrato
// Esse modelo deve ser utilizado para clientes que NAO possuem todos historico financeiro importado dos sistemas legados
//------------------------------------------------------------------------------------------------------------------------
else
	cQry := " SELECT " 		
	cQry += " U00.U00_CODIGO CONTRATO, "																					+ cPulaLinha

	if lAgrupa
		cQry += " MIN(SE1.E1_PARCELA) AS PARCELA_INICIAL, " 																+ cPulaLinha
		cQry += " MAX(SE1.E1_PARCELA) AS PARCELA_FINAL, " 																	+ cPulaLinha 
		cQry += " SUM(SE1.E1_VALOR) AS VALOR, " 																			+ cPulaLinha 
		cQry += " SUM(SE1.E1_ACRESC) AS ACRESCIMO " 																		+ cPulaLinha
	else
		cQry += " SE1.E1_PREFIXO PREFIXO, " 																				+ cPulaLinha
		cQry += " SE1.E1_NUM NUMERO, " 																						+ cPulaLinha
		cQry += " SE1.E1_PARCELA PARCELA, " 																				+ cPulaLinha
		cQry += " SE1.E1_TIPO TIPO, " 																						+ cPulaLinha
		cQry += " SE1.E1_VENCTO VENCIMENTO, " 																				+ cPulaLinha
		cQry += " SE1.E1_VALOR VALOR, " 																					+ cPulaLinha
		cQry += " SE1.E1_SALDO SALDO, " 																					+ cPulaLinha
		cQry += " SE1.E1_ACRESC ACRESCIMO, " 																				+ cPulaLinha
		cQry += " SE1.E1_DECRESC DECRESCIMO " 																				+ cPulaLinha
	endif
	cQry += " FROM  "
	cQry += RetSQLName("U00") + " U00 "
	cQry += " LEFT JOIN " 
	cQry += " ( "
	
	//--------------------------------------------------------------------------------------------
	// Busco a referencia, sendo por Ulimo Reajuste realizado ou por data de Ativacao do contrato
	//--------------------------------------------------------------------------------------------
	cQry += " 	SELECT "
	cQry += " 	MAX( "
	cQry += " 	CASE "
	cQry += " 	WHEN U20_REFINI IS NULL  THEN SUBSTRING(UU0B.U00_DTATIV,1,4) + SUBSTRING(UU0B.U00_DTATIV,5,2) "
	cQry += " 	ELSE SUBSTRING(U20_REFINI,3,4) + SUBSTRING(U20_REFINI,1,2) "
	cQry += " 	END) DATA_REAJUSTE, "
	cQry += " 	UU0B.U00_CODIGO AS CONTRATO  "
	cQry += " 	FROM " + RetSQLName("U00") + " UU0B "
	cQry += " 		LEFT JOIN  "  
	cQry += " 	" + RetSQLName("U20") + " U20 " 
	cQry += "	ON U20.D_E_L_E_T_ = ' ' "
	cQry += "	AND U20.U20_FILIAL = UU0B.U00_FILIAL "
	cQry += "	AND U20.U20_CONTRA = UU0B.U00_CODIGO  "
	cQry += "	AND U20.U20_FILIAL = '" + xFilial("U20") + "' "
	cQry += "		WHERE " 
	cQry += "		UU0B.D_E_L_E_T_ = ' ' "
	cQry += "	GROUP BY UU0B.U00_CODIGO "
	cQry += " ) REFERENCIA "
	cQry += " ON U00.D_E_L_E_T_ = '' "
	cQry += " AND U00.U00_FILIAL = '" + xFilial("U00") + "'  "
	cQry += " AND U00.U00_CODIGO = REFERENCIA.CONTRATO "
	//--------------------------------------------------------------------------------------------------------------

	cQry += " INNER JOIN " + RetSQLName("SE1") + " SE1 "
	cQry += " ON SE1.D_E_L_E_T_ <> '*' 
	cQry += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' 
	cQry += " AND SE1.E1_XCONTRA = U00.U00_CODIGO  "
	cQry += " AND SE1.E1_VENCTO > U00.U00_DTATIV  "
	cQry += " AND SE1.E1_SALDO > 0  "
	cQry += " AND SE1.E1_TIPO = '" + cTipoTitCTR + "' "  

	cQry += " WHERE 
	cQry += " U00.U00_FILIAL = '" + xFilial("U00") + "' " 																
	cQry += " AND U00.U00_INDICE = '" + cIndice + "' "												 						
	cQry += " AND U00.U00_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' " 								
	cQry += " AND U00.U00_REAJUS = 'V' " 																					
	cQry += " AND U00.U00_STATUS IN ('A','S') "	 																			

	// tratamento para a integracao de empresas
	if U00->(FieldPos("U00_TPCONT")) > 0
		cQry += " AND U00.U00_TPCONT <> '2' "	 																	
	endIf

	cQry += " AND U00.U00_DTATIV <> ' ' " 																					

	if !Empty(cPlano)
		cQry += " 	AND U00.U00_PLANO IN " + FormatIn( AllTrim(cPlano),";") 		 												
	endif

	cQry += " AND LEFT(CONVERT(varchar, DateAdd(Month,-12,CAST(SE1.E1_VENCTO AS DATETIME)) ,112),6) >= REFERENCIA.DATA_REAJUSTE  " 
	cQry += " AND LEFT(CONVERT(varchar, DateAdd(Month,-11,CAST('"+ DTOS(dDataBase) +"' AS DATETIME)) ,112),6) >= REFERENCIA.DATA_REAJUSTE "

	if lAgrupa
		cQry += " GROUP BY U00.U00_CODIGO " 																				+ cPulaLinha
		cQry += " ORDER BY VALOR,U00.U00_CODIGO " 																			+ cPulaLinha
	else
		cQry += " ORDER BY SE1.E1_VENCREA,VALOR,SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO " 									+ cPulaLinha
	endif

endif

MemoWrite("C:\Temp\reajuste.txt",cQry)

	
Return(cQry)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ DuoClique บ Autor ณ Wellington Gon็alves		   บ Dataณ 15/04/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo chamada no duplo clique no grid							  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function DuoClique(oGrid)

if oGrid:aCols[oGrid:oBrowse:nAt][1] == "CHECKED"
	oGrid:aCols[oGrid:oBrowse:nAt][1] := "UNCHECKED"
else
	oGrid:aCols[oGrid:oBrowse:nAt][1] := "CHECKED"
endif

oGrid:oBrowse:Refresh()

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ ConfirmaReajuste บ Autor ณ Wellington Gon็alves บ Dataณ 15/04/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo chamada na confirma็ใo da tela							  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ConfirmaReajuste(oGrid,cIndice,nIndice)

Local nX		:= 1
Local nPosCtr	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CONTRATO"})

if MsgYesNo("Deseja executar o reajuste dos contratos?")

	// percorro todo o grid
	For nX := 1 To Len(oGrid:aCols)
	
		// se a linha estiver marcada
		if oGrid:aCols[nX][1] == "CHECKED"
		
			// se o contrato estiver preenchido
			if !Empty(oGrid:aCols[nX][nPosCtr])
			
				// chamo fun็ใo do reajuste
				MsAguarde( {|| ProcReajuste(oGrid:aCols[nX][nPosCtr],cIndice,nIndice)}, "Aguarde", "Reajustando contrato (" + oGrid:aCols[nX][nPosCtr] + ")...", .F. )	
			
			endif 
		
		endif	
	
	Next nX
	
	MsgInfo("Reajuste concluํdo com sucesso!")
	
	// fecho a janela
	oDlg:End() 

endif

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ ProcReajuste บ Autor ณ Wellington Gon็alves 	   บ Dataณ 15/04/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que faz o processamento do reajuste						  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function ProcReajuste(cContrato,cIndice,nIndice)

Local lOK			:= .T.
Local aArea 		:= GetArea()
Local aAreaSE1		:= SE1->(GetArea())
Local cQry 			:= "" 
Local aDados		:= {}
Local aHistorico	:= {}
Local nAdicional	:= 0
Local cProxReaj		:= ""
Local dProxReaj		:= CTOD("  /  /    ")
Local cParcIni		:= ""
Local dParcIni		:= CTOD("  /  /    ")
Private lMsErroAuto := .F.

// fun็ใo que cria a string com a query de contratos a serem reajustados
cQry := QryCTR(cContrato,cContrato,cIndice,"",.F.)

// verifico se nใo existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

// fun็ใo que converte a query gen้rica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

// se existir contratos a serem reajustados
if QRY->(!Eof())

	// inicio o controle de transa็ใo
	BeginTran()
	
	// pego o vencimento do primeiro tํtulo
	dParcIni 	:= STOD(QRY->VENCIMENTO)
	cParcIni	:= StrZero(Month(dParcIni),2) + StrZero(Year(dParcIni),4)
	
	// pego a data do proximo reajuste = vencimento do primeiro tํtulo + 11 meses
	dProxReaj 	:= MonthSum(STOD(QRY->VENCIMENTO),11)
	cProxReaj 	:= StrZero(Month(dProxReaj),2) + StrZero(Year(dProxReaj),4)

	While QRY->(!Eof())
	
		SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
		if SE1->(DbSeek(xFilial("SE1") + QRY->PREFIXO + QRY->NUMERO + QRY->PARCELA + QRY->TIPO))
	
			lMsErroAuto := .F.
			nAdicional 	:= (SE1->E1_VALOR + SE1->E1_ACRESC) * (nIndice/100)  
			aDados		:= {}
		
			AAdd(aDados, {"E1_FILIAL"	, SE1->E1_FILIAL				,Nil } )
			AAdd(aDados, {"E1_PREFIXO"	, SE1->E1_PREFIXO  				,Nil } ) 
			AAdd(aDados, {"E1_NUM"		, SE1->E1_NUM	 				,Nil } ) 
			AAdd(aDados, {"E1_PARCELA"	, SE1->E1_PARCELA				,Nil } )
			AAdd(aDados, {"E1_TIPO"		, SE1->E1_TIPO 					,Nil } )
			AAdd(aDados, {"E1_ACRESC"	, SE1->E1_ACRESC + nAdicional	,Nil } )
			AAdd(aDados, {"E1_SDACRES"	, SE1->E1_SDACRES + nAdicional	,Nil } )
			
			// array de hist๓rico
			AAdd(aHistorico,{SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_VALOR,SE1->E1_ACRESC,nAdicional,SE1->E1_ACRESC + nAdicional})
			
			MSExecAuto({|x,y| FINA040(x,y)},aDados,4)
			
			If lMsErroAuto
				MostraErro()                    
				DisarmTransaction()
				lOK := .F.
				Exit		
			endif 
		
		endif
				
		QRY->(DbSkip()) 
		
	EndDo
	
	if lOK
		if GravaHistorico(cContrato,cIndice,nIndice,cParcIni,cProxReaj,aHistorico)
			EndTran()
		else
			DisarmTransaction()
		endif
	endif
		
endif

// fecho o alias temporario criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

RestArea(aAreaSE1)
RestArea(aArea)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ GravaHistorico บ Autor ณ Wellington Gon็alves   บ Dataณ 15/04/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que grava o hist๓rico do reajuste							  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function GravaHistorico(cContrato,cIndice,nIndice,cParcIni,cProxReaj,aDados)

Local oAux
Local oStruct
Local cMaster 		:= "U20"
Local cDetail		:= "U21"
Local aCpoMaster	:= {}
Local aLinha		:= {}
Local aCpoDetail	:= {}
Local oModel  		:= FWLoadModel("RCPGA013") // instanciamento do modelo de dados
Local nX			:= 1
Local nI       		:= 0
Local nJ       		:= 0
Local nPos     		:= 0
Local lRet     		:= .T.
Local aAux	   		:= {}
Local nItErro  		:= 0
Local lAux     		:= .T.
Local cItem 		:= PADL("1",TamSX3("U21_ITEM")[1],"0")

aadd(aCpoMaster,{"U20_FILIAL"	, xFilial("U20")	})
aadd(aCpoMaster,{"U20_DATA"		, dDataBase			})
aadd(aCpoMaster,{"U20_CONTRA"	, cContrato			})
aadd(aCpoMaster,{"U20_TPINDI"	, cIndice			})
aadd(aCpoMaster,{"U20_INDICE"	, nIndice			})
aadd(aCpoMaster,{"U20_REFINI"	, cParcIni			})
aadd(aCpoMaster,{"U20_REFFIM"	, cProxReaj			})

For nX := 1 To Len(aDados)
		
	aLinha := {}
		
	aadd(aLinha,{"U21_FILIAL"	, xFilial("U21")	})
	aadd(aLinha,{"U21_ITEM"		, cItem				})
	aadd(aLinha,{"U21_PREFIX"	, aDados[nX,1]		})
	aadd(aLinha,{"U21_NUM"		, aDados[nX,2]		})
	aadd(aLinha,{"U21_PARCEL"	, aDados[nX,3]		})
	aadd(aLinha,{"U21_TIPO"		, aDados[nX,4]		})
	aadd(aLinha,{"U21_VALOR"	, aDados[nX,5]		})
	aadd(aLinha,{"U21_ACRINI"	, aDados[nX,6]		})
	aadd(aLinha,{"U21_VLADIC"	, aDados[nX,7]		})
	aadd(aLinha,{"U21_ACRFIM"	, aDados[nX,8]		})
	aadd(aCpoDetail,aLinha)
	
	cItem := SOMA1(cItem)
	
Next nX

(cDetail)->(DbSetOrder(1))
(cMaster)->(DbSetOrder(1))

// defino a opera็ใo de inclusใo
oModel:SetOperation(3)

// Antes de atribuirmos os valores dos campos temos que ativar o modelo
lRet := oModel:Activate()

If lRet
	
	// Instanciamos apenas a parte do modelo referente aos dados de cabe็alho
	oAux := oModel:GetModel( cMaster + 'MASTER' )
	
	// Obtemos a estrutura de dados do cabe็alho
	oStruct := oAux:GetStruct()
	aAux := oStruct:GetFields()
	
	If lRet
		
		For nI := 1 To Len(aCpoMaster)
			
			// Verifica se os campos passados existem na estrutura do cabe็alho
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoMaster[nI][1] ) } ) ) > 0
				
				// ศ feita a atribuicao do dado aos campo do Model do cabe็alho
				If !( lAux := oModel:SetValue( cMaster + 'MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )
					
					// Caso a atribui็ใo nใo possa ser feita, por algum motivo (valida็ใo, por exemplo)
					// o m้todo SetValue retorna .F.
					lRet    := .F.
					Exit
					
				EndIf
				
			EndIf
			
		Next nI
		
	EndIf
	
EndIf

If lRet
	
	// Intanciamos apenas a parte do modelo referente aos dados do item
	oAux := oModel:GetModel( cDetail + 'DETAIL' )
	
	// Obtemos a estrutura de dados do item
	oStruct := oAux:GetStruct()
	aAux := oStruct:GetFields()
	
	nItErro  := 0
	
	For nI := 1 To Len(aCpoDetail)
		
		// Incluํmos uma linha nova
		// ATENCAO: O itens sใo criados em uma estrura de grid (FORMGRID), portanto jแ ้ criada uma primeira linha
		//branco automaticamente, desta forma come็amos a inserir novas linhas a partir da 2ช vez
		
		If nI > 1
			
			// Incluimos uma nova linha de item
			
			If  ( nItErro := oAux:AddLine() ) <> nI
				
				// Se por algum motivo o metodo AddLine() nใo consegue incluir a linha,
				// ele retorna a quantidade de linhas jแ
				// existem no grid. Se conseguir retorna a quantidade mais 1
				lRet    := .F.
				Exit
				
			EndIf
			
		EndIf
		
		For nJ := 1 To Len( aCpoDetail[nI] )
			
			// Verifica se os campos passados existem na estrutura de item
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0
				
				If !( lAux := oModel:SetValue( cDetail + 'DETAIL', aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )
					
					// Caso a atribui็ใo nใo possa ser feita, por algum motivo (valida็ใo, por exemplo)
					// o m้todo SetValue retorna .F.
					lRet    := .F.
					nItErro := nI
					Exit
					
				EndIf
				
			EndIf
			
		Next nJ
		
		If !lRet
			Exit
		EndIf
		
	Next nI
	
EndIf

If lRet
	
	// Faz-se a valida็ใo dos dados, note que diferentemente das tradicionais "rotinas automแticas"
	// neste momento os dados nใo sใo gravados, sใo somente validados.
	If ( lRet := oModel:VldData() )
		
		// Se o dados foram validados faz-se a grava็ใo efetiva dos dados (commit)
		lRet := oModel:CommitData()
		//FreeObj(oModel)
	EndIf
	
EndIf

If !lRet
	
	// Se os dados nใo foram validados obtemos a descri็ใo do erro para gerar LOG ou mensagem de aviso
	aErro   := oModel:GetErrorMessage()
	
	// A estrutura do vetor com erro ้:
	//  [1] Id do formulแrio de origem
	//  [2] Id do campo de origem
	//  [3] Id do formulแrio de erro
	//  [4] Id do campo de erro
	//  [5] Id do erro
	//  [6] mensagem do erro
	//  [7] mensagem da solu็ใo
	//  [8] Valor atribuido
	//  [9] Valor anterior
	
	AutoGrLog( "Id do formulแrio de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
	AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
	AutoGrLog( "Id do formulแrio de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
	AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
	AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
	AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
	AutoGrLog( "Mensagem da solu็ใo:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
	AutoGrLog( "Valor atribuido:           " + ' [' + AllToChar( aErro[8]  ) + ']' )
	AutoGrLog( "Valor anterior:            " + ' [' + AllToChar( aErro[9]  ) + ']' )
	
	If nItErro > 0
		AutoGrLog( "Erro no Item:              " + ' [' + AllTrim( AllToChar( nItErro  ) ) + ']' )
	EndIf
	
	MostraErro()
	
EndIf

// Desativamos o Model
oModel:DeActivate()

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ BuscaIndice บ Autor ณ Wellington Gon็alves	   บ Dataณ 20/04/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que calcula a m้dia do ํndice								  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function BuscaIndice(cIndice)

Local cQry 		   	:= ""     
Local cPulaLinha	:= chr(13)+chr(10) 
Local nRet			:= 0
Local dDataRef		:= dDataBase

// verifico se nใo existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf        

cQry := " SELECT " 																				+ cPulaLinha
cQry += " SUM(U29.U29_INDICE) AS INDICE " 														+ cPulaLinha 
cQry += " FROM " 																				+ cPulaLinha 
cQry += + RetSqlName("U22") + " U22 " 															+ cPulaLinha 
cQry += " INNER JOIN " 																			+ cPulaLinha 
cQry += + RetSqlName("U28") + " U28 " 															+ cPulaLinha
cQry += "    INNER JOIN " 																		+ cPulaLinha
cQry += + 	 RetSqlName("U29") + " U29 " 														+ cPulaLinha
cQry += "    ON ( " 																			+ cPulaLinha
cQry += "        U29.D_E_L_E_T_ <> '*' " 														+ cPulaLinha
cQry += "        AND U28.U28_CODIGO = U29.U29_CODIGO " 											+ cPulaLinha
cQry += "        AND U28.U28_ITEM = U29.U29_IDANO " 											+ cPulaLinha 
cQry += " 		 AND U29.U29_FILIAL = '" + xFilial("U29") + "' " 								+ cPulaLinha
cQry += "    ) " 																				+ cPulaLinha
cQry += " ON ( " 																				+ cPulaLinha
cQry += "    U28.D_E_L_E_T_ <> '*' " 															+ cPulaLinha
cQry += "    AND U22.U22_CODIGO = U28.U28_CODIGO " 												+ cPulaLinha
cQry += " 	 AND U28.U28_FILIAL = '" + xFilial("U28") + "' " 									+ cPulaLinha
cQry += "    ) " 																				+ cPulaLinha
cQry += " WHERE " 																				+ cPulaLinha 
cQry += " U22.D_E_L_E_T_ <> '*' " 																+ cPulaLinha
cQry += " AND U22.U22_FILIAL = '" + xFilial("U22") + "' " 										+ cPulaLinha 
cQry += " AND U22.U22_STATUS = 'A' " 															+ cPulaLinha

if !Empty(cIndice)
	cQry += " AND U22.U22_CODIGO = '" + cIndice + "' " 											+ cPulaLinha
endif
 
cQry += " AND U28.U28_ANO + U29.U29_MES " 														+ cPulaLinha 
cQry += " BETWEEN '" + AnoMes(MonthSub(dDataRef,11)) + "'  AND  '" + AnoMes(dDataRef) + "' " 	+ cPulaLinha

// fun็ใo que converte a query gen้rica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

// se existir contratos a serem reajustados
if QRY->(!Eof())
	nRet := Round(QRY->INDICE,TamSX3("U29_INDICE")[2])
endif

// verifico se nใo existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf  

Return(nRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ AjustaSX1 บ Autor ณ Wellington Gon็alves		   บ Dataณ 24/02/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que cria as perguntas na SX1.								  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relat๓rio

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

//////////// Contrato ///////////////

U_xPutSX1( cPerg, "01","Contrato De?","Contrato De?","Contrato De?","cContratoDe","C",6,0,0,"G","","U00","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "02","Contrato Ate?","Contrato Ate?","Contrato Ate?","cContratoAte","C",6,0,0,"G","","U00","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

///////////// Plano /////////////////

U_xPutSX1( cPerg, "03","Plano?","Plano?","Plano?","cPlano","C",99,0,0,"G","","U05MRK","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// อndice ///////////////

U_xPutSX1( cPerg, "04","อndice?","อndice?","อndice?","cIndice","C",3,0,0,"G","","U22","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return() 
