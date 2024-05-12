#Include "PROTHEUS.CH"
#include "topconn.ch"

/*/{Protheus.doc} RCPGE016
//Consulta Especifica de Enderecamento do Contrato
//para transferencia de enderecamento
@Author Raphael Martins
@Since 14/05/2018
@Version 1.0
@Return
@Type function
/*/

User Function RCPGE016(cFilCtro,cContrato)

	Local aArea 		:= GetArea()
	Local aAreaU04		:= U04->(GetArea())
	Local oGroup1		:= NIL
	Local oGroup2		:= NIL
	Local oGroup3		:= NIL
	Local oSay1			:= NIL
	Local oSay2			:= NIL
	Local oDlg			:= NIL
	Local oConfirmar	:= NIL
	Local oCancelar		:= NIL
	Local oGrid			:= NIL
	Local oArial 		:= TFont():New("Arial Narrow",,013,,.F.,,,,,.F.,.F.)
	Local oArialCinza 	:= TFont():New("Arial",,016,,.T.,,,,,.F.,.F.)
	Local oArialN 		:= TFont():New("Arial",,013,,.T.,,,,,.F.,.F.)
	Local lRet			:= .T.
	Local cFilBkp		:= cFilAnt
	Static cRetEnd		:= ""

	Default cFilCtro	:= cFilAnt
	Default cContrato	:= GetContrato()

	// mudo a filial logada
	cFilAnt := cFilCtro

	DEFINE MSDIALOG oDlg TITLE "Consulta Endereços do Contrato" FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL

	@ 003, 003 GROUP oGroup2 TO 177, 298 PROMPT "Endereços do Contrato" OF oDlg COLOR 8421504, 16777215 PIXEL

	//monto a grid de enderecos
	oGrid := MsGridCTR(oDlg)

	// duplo clique no grid
	oGrid:oBrowse:bLDblClick := {|| cRetEnd := ConfirmaEnd(oDlg,oGrid) }

	@ 179, 003 GROUP oGroup3 TO 196, 298 OF oDlg COLOR 0, 16777215 PIXEL
	@ 183, 210 BUTTON oConfirmar PROMPT "Confirmar" SIZE 037, 010 OF oDlg Action( cRetEnd := ConfirmaEnd(oDlg,oGrid) ) FONT oArialN PIXEL
	@ 183, 256 BUTTON oCancelar PROMPT "Cancelar" SIZE 037, 010 OF oDlg Action(oDlg:End()) FONT oArialN PIXEL

	// caso não tenha encontrato enderecos
	if !RefreshGrid(oGrid,cFilCtro,cContrato)

		Alert("Não foram encontrados servicos para o contrato!")
		oDlg:End()

	endif

	ACTIVATE MSDIALOG oDlg CENTERED

	//posiciono no item selecionado na U04 para retorno da consulta
	U04->(DbSetOrder(1)) //U04_FILIAL + U04_CODIGO + U04_ITEM

	if !U04->(DbSeek(xFilial("U04")+cContrato+cRetEnd))

		lRet := .F.

	endif

	//restauro a filial logada
	cFilAnt := cFilAnt

	RestArea(aAreaU04)
	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} RCPGE16A
//Retorno da Consulta 
@Author Raphael Martins
@Since 14/05/2018
@Version 1.0
@Return
@Type function
/*/
User Function RCPGE16A()
Return(cRetEnd)

/*/{Protheus.doc} MsGridCTR
//TODO Função que cria o grid de enderecos
@author Raphael Martins
@since 14/05/2018
@version 1.0
@param 	oTela	 	- Dialog da Tela de consulta
@return oGrid		- MsNewGetdados criada dos enderecos consultados
@type function
/*/

Static Function MsGridCTR(oTela)

	Local oGrid			:= NIL
	Local nX			:= 1
	Local aHeaderEx 	:= {}
	Local aColsEx 		:= {}
	Local aFieldFill 	:= {}
	Local aFields 		:= {"ITEM","DATA_UTILIZACAO","NOME","QUADRA","MODULO","JAZIGO","GAVETA","CREMATORIO","COLUMBARIO","OSSARIO","NICHOO","DATA","EXUMACAO"}
	Local aAlterFields 	:= {}

	For nX := 1 To Len(aFields)

		if aFields[nX] == "ITEM"
			Aadd(aHeaderEx, {"Item","ITEM","@E 999",3,0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "DATA_UTILIZACAO"
			Aadd(aHeaderEx, {"Dt. Utiliz.","DATA_UTILIZACAO",PesqPict("U04","U04_DTUTIL"),TamSX3("U04_DTUTIL")[1],0,"","€€€€€€€€€€€€€€","D","","","",""})

		elseif aFields[nX] == "NOME"
			Aadd(aHeaderEx, {"Quem usou","NOME",PesqPict("U04","U04_QUEMUT"),TamSX3("U04_QUEMUT")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "QUADRA"
			Aadd(aHeaderEx, {"Quadra","QUADRA",PesqPict("U04","U04_QUADRA"),TamSX3("U04_QUADRA")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "MODULO"
			Aadd(aHeaderEx, {"Modulo","MODULO",PesqPict("U04","U04_MODULO"),TamSX3("U04_MODULO")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "JAZIGO"
			Aadd(aHeaderEx, {"Jazigo","JAZIGO",PesqPict("U04","U04_JAZIGO"),TamSX3("U04_JAZIGO")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "GAVETA"
			Aadd(aHeaderEx, {"Gaveta","GAVETA",PesqPict("U04","U04_GAVETA"),TamSX3("U04_GAVETA")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "CREMATORIO"
			Aadd(aHeaderEx, {"Crematorio","CREMATORIO",PesqPict("U04","U04_CREMAT"),TamSX3("U04_CREMAT")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "COLUMBARIO"
			Aadd(aHeaderEx, {"Nicho Columb","COLUMBARIO",PesqPict("U04","U04_NICHOC"),TamSX3("U04_NICHOC")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "OSSARIO"
			Aadd(aHeaderEx, {"Ossario","OSSARIO",PesqPict("U04","U04_OSSARI"),TamSX3("U04_OSSARI")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "NICHOO"
			Aadd(aHeaderEx, {"Nicho Ossario","NICHOO",PesqPict("U04","U04_NICHOO"),TamSX3("U04_NICHOO")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

		elseif aFields[nX] == "DATA"
			Aadd(aHeaderEx, {"Data","DATA",PesqPict("U04","U04_DATA"),TamSX3("U04_DATA")[1],0,"","€€€€€€€€€€€€€€","D","","","",""})

		elseif aFields[nX] == "EXUMACAO"
			Aadd(aHeaderEx, {"Exumacao","EXUMACAO",PesqPict("U04","U04_PRZEXU"),TamSX3("U04_PRZEXU")[1],0,"","€€€€€€€€€€€€€€","D","","","",""})

		endif

	Next nX

// Define field values
	For nX := 1 To Len(aHeaderEx)

		if aHeaderEx[nX,8] == "C"
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

	oGrid := MsNewGetDados():New( 011,008,173, 293, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,;
		, 999, "AllwaysTrue", "", "AllwaysTrue",oTela, aHeaderEx, aColsEx)


Return(oGrid)

/*{Protheus.doc} RefreshGrid
//TODO Função chamada para preencher a grid de enderecos
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param oGrid 			- Objeto da Grid de Contratos 
@param cContrato	 	- Codigo do Contrato em que sera consultado os seus servicos
@param cFilCtro		 	- Filial do Contrato
@return lRet			- Encontrado contratos para reajustar
@type function
/*/
Static Function RefreshGrid(oGrid,cFilCtro,cContrato)

Local aArea			:= GetArea()
Local aAreaU00		:= U00->(GetArea())
Local aAreaU04		:= U04->(GetArea())
Local cQry			:= ""
Local lRet			:= .F.
Local aFields 		:= {"ITEM","DATA_UTILIZACAO","NOME","QUADRA","MODULO","JAZIGO","GAVETA","CREMATORIO","COLUMBARIO","OSSARIO","NICHOO","DATA","EXUMACAO"}
	
// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

cQry += " SELECT "
cQry += " U04_ITEM 	 ITEM, "
cQry += " U04_QUADRA QUADRA, "
cQry += " U04_MODULO MODULO, "
cQry += " U04_JAZIGO JAZIGO, "
cQry += " U04_GAVETA GAVETA, "
cQry += " U04_CREMAT CREMATORIO, "
cQry += " U04_NICHOC NICHO_COLUMBARIO, "
cQry += " U04_OSSARI OSSARIO, "
cQry += " U04_NICHOO NICHO_OSSARIO, "
cQry += " U04_DATA   DATA_INCLUSAO, " 
cQry += " U04_DTUTIL DATA_UTILIZACAO, "
cQry += " U04_QUEMUT QUEM_UTILIZOU, "
cQry += " U04_PRZEXU EXUMACAO "
cQry += " FROM "
cQry += + RetSQLName("U04") + " ENDERECO "
cQry += " WHERE "
cQry += " ENDERECO.D_E_L_E_T_ = ' ' "
cQry += " AND ENDERECO.U04_FILIAL = '" + xFilial("U04") + "' "
cQry += " AND ENDERECO.U04_CODIGO = '" + cContrato + "' "
cQry += " AND ENDERECO.U04_QUEMUT <> ' ' "

cQry += " ORDER BY ITEM "

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

oGrid:Acols := {}
aFieldFill 	:= {}

// se existir enderecamento para o contrato
if QRY->(!Eof())
	
	lRet 		:= .T. 

	While QRY->(!Eof()) 
		
		aFieldFill := {}
		
		aadd(aFieldFill, QRY->ITEM)
		aadd(aFieldFill, STOD(QRY->DATA_UTILIZACAO))
		aadd(aFieldFill, Alltrim(QRY->QUEM_UTILIZOU))
		aadd(aFieldFill, QRY->QUADRA)
		aadd(aFieldFill, QRY->MODULO)
		aadd(aFieldFill, QRY->JAZIGO)
		aadd(aFieldFill, QRY->GAVETA)
		aadd(aFieldFill, QRY->CREMATORIO)
		aadd(aFieldFill, QRY->NICHO_COLUMBARIO)
		aadd(aFieldFill, QRY->OSSARIO)
		aadd(aFieldFill, QRY->NICHO_OSSARIO)
		aadd(aFieldFill, STOD(QRY->DATA_INCLUSAO))
		aadd(aFieldFill, STOD(QRY->EXUMACAO))
		Aadd(aFieldFill, .F.)
		aadd(oGrid:Acols,aFieldFill) 
		
		QRY->(DbSkip())
		
	EndDo
	
else
	
	aadd(aFieldFill, "")
	aadd(aFieldFill, "")
	aadd(aFieldFill, CTOD(""))
	aadd(aFieldFill, "")
	aadd(aFieldFill, "")
	aadd(aFieldFill, "")
	aadd(aFieldFill, "")
	aadd(aFieldFill, "")
	aadd(aFieldFill, "")
	aadd(aFieldFill, "")
	aadd(aFieldFill, "")
	aadd(aFieldFill, "")
	aadd(aFieldFill, CTOD(""))
	aadd(aFieldFill, CTOD(""))
	
	Aadd(aFieldFill, .F.)
	
	aadd(oGrid:Acols,aFieldFill) 
	
endif

oGrid:oBrowse:Refresh()

RestArea(aArea)
RestArea(aAreaU00)
RestArea(aAreaU04)

Return(lRet)

/*
{Protheus.doc} ConfirmaEnd
//TODO Funcao para adicionar os enderecos 
selecionados na grid de enderecos de origem
@author Raphael Martins
@since 15/05/2018
@version 1.0
@param oDlg	 			- Dialog da tela de consulta enderecos
@param oGrid 			- Objeto da Grid de enderecos
@return Sem Retorno
@type function
/*/
Static Function ConfirmaEnd(oDlg,oGrid)

	Local oModel			:= FWModelActive()     
	Local oView				:= FWViewActive()
	Local oModelU38 		:= Nil
	Local oModelU92			:= Nil
	Local aSaveLines  		:= FWSaveRows() 
	Local nPosItem			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "ITEM"}) 
	Local nPosDtUt			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "DATA_UTILIZACAO"}) 
	Local nPosNome			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "NOME"}) 
	Local nPosQuadra		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "QUADRA"}) 
	Local nPosModulo		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "MODULO"}) 
	Local nPosJazigo		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "JAZIGO"}) 
	Local nPosGaveta		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "GAVETA"}) 
	Local nPosCremat		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CREMATORIO"}) 
	Local nPosColumb		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "COLUMBARIO"}) 
	Local nPosOssario		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "OSSARIO"}) 
	Local nPosNichoO		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "NICHOO"}) 
	Local nPosData			:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "DATA"}) 
	Local nPosExumacao		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "EXUMACAO"}) 
	Local cRet				:= ""
			
	If FWIsInCallStack("U_RCPGA034") // transferencia de enderecos

		oModelU38 := oModel:GetModel("U38MASTER") // Enderecos de origem 

		oModelU38:LoadValue("U38_ITEMEN"	, oGrid:aCols[oGrid:nAT,nPosItem])
		oModelU38:LoadValue("U38_QUADRA"	, oGrid:aCols[oGrid:nAT,nPosQuadra])
		oModelU38:LoadValue("U38_MODULO"	, oGrid:aCols[oGrid:nAT,nPosModulo])
		oModelU38:LoadValue("U38_JAZIGO"	, oGrid:aCols[oGrid:nAT,nPosJazigo])
		oModelU38:LoadValue("U38_GAVETA"	, oGrid:aCols[oGrid:nAT,nPosGaveta])
		oModelU38:LoadValue("U38_OSSARI"	, oGrid:aCols[oGrid:nAT,nPosOssario])
		oModelU38:LoadValue("U38_NICHOO"	, oGrid:aCols[oGrid:nAT,nPosNichoO])
		oModelU38:LoadValue("U38_DTSERV"	, oGrid:aCols[oGrid:nAT,nPosData])
		oModelU38:LoadValue("U38_DTUTIL"	, oGrid:aCols[oGrid:nAT,nPosDtUt])
		oModelU38:LoadValue("U38_QUEMUT"	, oGrid:aCols[oGrid:nAT,nPosNome])
		oModelU38:LoadValue("U38_PRZEXU"	, oGrid:aCols[oGrid:nAT,nPosExumacao])

	ElseIf FWIsInCallStack("U_RUTIL049") // agendamento

		oModelU92 := oModel:GetModel("U92MASTER") // Enderecos de origem 

		oModelU92:LoadValue("U92_ITEM"		, oGrid:aCols[oGrid:nAT,nPosItem])
		oModelU92:LoadValue("U92_QUADRA"	, oGrid:aCols[oGrid:nAT,nPosQuadra])
		oModelU92:LoadValue("U92_MODULO"	, oGrid:aCols[oGrid:nAT,nPosModulo])
		oModelU92:LoadValue("U92_JAZIGO"	, oGrid:aCols[oGrid:nAT,nPosJazigo])
		oModelU92:LoadValue("U92_GAVETA"	, oGrid:aCols[oGrid:nAT,nPosGaveta])
		oModelU92:LoadValue("U92_OSSUAR"	, oGrid:aCols[oGrid:nAT,nPosOssario])
		oModelU92:LoadValue("U92_NICHOO"	, oGrid:aCols[oGrid:nAT,nPosNichoO])
		oModelU92:LoadValue("U92_DTSERV"	, oGrid:aCols[oGrid:nAT,nPosData])
		oModelU92:LoadValue("U92_DTUTIL"	, oGrid:aCols[oGrid:nAT,nPosDtUt])
		oModelU92:LoadValue("U92_NOME"		, oGrid:aCols[oGrid:nAT,nPosNome])
		oModelU92:LoadValue("U92_PRZEXU"	, oGrid:aCols[oGrid:nAT,nPosExumacao])

	EndIf
	
	cRet := oGrid:aCols[oGrid:nAT,nPosItem]
	
	If oView <> nil
		oView:Refresh()
	EndIf
		
	oDlg:End()

	//restauro as linhas posicionadas
	FWRestRows( aSaveLines )
		
Return(cRet)

Static Function GetContrato()

	Local cRetorno			:= ""
	Local oModel			:= FWModelActive()     
	Local oModelU38 		:= Nil
	Local oModelU92			:= Nil

	If FWIsInCallStack("U_RCPGA034") // transferencia de enderecos

		oModelU38 := oModel:GetModel("U38MASTER") 

		cRetorno := oModelU38:GetValue("U38_CTRORI")

	ElseIf FWIsInCallStack("U_RUTIL049") // agendamento

		oModelU92 := oModel:GetModel("U92MASTER") 

		cRetorno := oModelU92:GetValue("U92_CONTRA")
	EndIf

Return(cRetorno)
