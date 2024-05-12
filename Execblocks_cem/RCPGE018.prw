#include "protheus.ch"
#include "topconn.ch"


/*/{Protheus.doc} RCPGE018
Rotina de Exclusao de Retirada
de Cinzas
@author Raphael Martins
@since 30/07/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function RCPGE018()

Local oTela			:= NIL
Local oGroup1		:= NIL
Local oGroup2		:= NIL
Local oGroup3		:= NIL
Local oGroup4		:= NIL
Local oSay1			:= NIL
Local oSay2			:= NIL
Local oSay3			:= NIL
Local oSay4			:= NIL
Local oGrid			:= NIL 

Private __XVEZ 		:= "0"
Private __ASC       := .T.
Private _nMarca		:= 0

  DEFINE MSDIALOG oTela TITLE "Exclusao - Retirada de Cinzas" FROM 000, 000  TO 450,700 COLORS 0, 16777215 PIXEL

  	//monto a grid de enderecos
    oGrid := MsGridCTR(oTela)
    
    // duplo clique no grid
	bSvblDblClick := oGrid:oBrowse:bLDblClick
	oGrid:oBrowse:bLDblClick := {|| if(oGrid:oBrowse:nColPos <> 1,GdRstDblClick(@oGrid,@bSvblDblClick),DuoClique(oGrid))}
	
		
	// clique no cabecalho da grid
	oGrid:oBrowse:bHeaderClick := {|oBrw1,nCol| MarcaTodos(oGrid),oBrw1:SetFocus() }
	
	//Cabeçalho
	@ 005, 005 SAY oSay1 PROMPT "Contrato:" SIZE 070, 007 OF oTela COLORS 0, 16777215 PIXEL
	@ 005, 030 SAY oSay2 PROMPT U00->U00_CODIGO SIZE 200, 007 OF oTela COLORS 0, 16777215 PIXEL
	@ 018, 005 SAY oSay3 PROMPT "Cliente:" SIZE 070, 007 OF oTela  COLORS 0, 16777215 PIXEL
	@ 018, 030 SAY oSay4 PROMPT AllTrim(U00->U00_CLIENT) + "/" + AllTrim(U00->U00_LOJA) + " - " + U00->U00_NOMCLI SIZE 200, 007 OF oTela COLORS 0, 16777215 PIXEL
	
	//Linha horizontal
	@ 198, 005 SAY oSay5 PROMPT Repl("_",342) SIZE 342, 007 OF oTela COLORS CLR_GRAY, 16777215 PIXEL
	
	@ 208, 272 BUTTON oConfirmar PROMPT "Confirmar" SIZE 040, 010 Action(FWMsgRun(,{|oSay| ConfExcRetC(U00->U00_CODIGO,oGrid,oTela) },'Aguarde...','Realizando Exclusão de Retirada de Cinza!')) OF oTela PIXEL
    @ 208, 317 BUTTON oCancelar PROMPT "Fechar" SIZE 030, 010 Action(oTela:End()) OF oTela PIXEL
    
    
	// caso não tenha encontrato enderecos
  	if !RefreshGrid(oGrid,U00->U00_CODIGO)
		
  		Alert("Não foram encontrados servicos para o contrato!")
  		oTela:End()
		
	endif
	    
    
  ACTIVATE MSDIALOG oTela CENTERED
    
Return

/*/{Protheus.doc} MsGridCTR
//TODO Função que cria o grid de Retirada de Cinzas
@author Raphael Martins
@since 30/07/2018
@version 1.0
@param 	oTela	 	- Dialog da Tela de consulta
@return oGrid		- MsNewGetdados criada das Retirada de Cinzas
@type function
/*/

Static Function MsGridCTR(oTela)

Local oGrid			:= NIL
Local nX			:= 1
Local aHeadEx 		:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {"MARK","ITEM","CREMATORIO","COLUMBARIO","QUEM_UTIL","DTRETI","HORARE","NORINV","USER","USRNOM","CPF_RESG","RG","ORGAO","NOMERE","RECU30"}
Local aAlterFields 	:= {}

For nX := 1 To Len(aFields)
	
	if aFields[nX] == "MARK" 
		Aadd(aHeadEx, {"","MARK","@BMP",2,0,"","€€€€€€€€€€€€€€","C","","","",""})
	
	elseif aFields[nX] == "ITEM"
		Aadd(aHeadEx, {"Item","ITEM","@E 999",3,0,"","€€€€€€€€€€€€€€","C","","","",""})
	
	elseif aFields[nX] == "CREMATORIO"
		Aadd(aHeadEx, {"Crematorio","CREMATORIO",PesqPict("U39","U39_CREMAT"),TamSX3("U39_CREMAT")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	
	elseif aFields[nX] == "COLUMBARIO"
		Aadd(aHeadEx, {"Nicho Columb","COLUMBARIO",PesqPict("U39","U39_NICHOC"),TamSX3("U39_NICHOC")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	
	elseif aFields[nX] == "QUEM_UTIL"
		Aadd(aHeadEx, {"Quem usou","NOME",PesqPict("U39","U39_QUEMUT"),TamSX3("U39_QUEMUT")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	
	elseif aFields[nX] == "DTRETI"
		Aadd(aHeadEx, {"Dt. Retirada.","DTRETI",PesqPict("U41","U41_DTRETI"),TamSX3("U41_DTRETI")[1],0,"","€€€€€€€€€€€€€€","D","","","",""})
	
	elseif aFields[nX] == "HORARE"
		Aadd(aHeadEx, {"Hora Ret.","HORARE",PesqPict("U41","U41_HORARE"),TamSX3("U41_HORARE")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

	elseif aFields[nX] == "NORINV"
		Aadd(aHeadEx, {"Num Involucro","NORINV",PesqPict("U41","U41_NORINV"),TamSX3("U41_NORINV")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	
	elseif aFields[nX] == "USER"
		Aadd(aHeadEx, {"Cod Usuario","USER",PesqPict("U41","U41_USER"),TamSX3("U41_USER")[1],0,"","€€€€€€€€€€€€€€","C","","R","",""})
	
	elseif aFields[nX] == "USRNOM"
		Aadd(aHeadEx, {"Nome Usuario","USRNOM",PesqPict("U41","U41_USRNOM"),TamSX3("U41_USRNOM")[1],0,"","€€€€€€€€€€€€€€","C","","R","",""})

	elseif aFields[nX] == "CPF_RESG"
		Aadd(aHeadEx, {"CPF","CPF_RESG","@R 999.999.999-99",11,0,"","€€€€€€€€€€€€€€","C","","R","",""})
		
	elseif aFields[nX] == "RG"
		Aadd(aHeadEx, {"RG","RG",PesqPict("U41","U41_RG"),TamSX3("U41_RG")[1],0,"","€€€€€€€€€€€€€€","C","","R","",""})
	
	elseif aFields[nX] == "ORGAO"
		Aadd(aHeadEx, {"Orgao","ORGAO",PesqPict("U41","U41_ORGAO"),TamSX3("U41_ORGAO")[1],0,"","€€€€€€€€€€€€€€","C","","R","",""})
	
	elseif aFields[nX] == "NOMERE"
		Aadd(aHeadEx, {"Nome Resgatador","NOMERE",PesqPict("U41","U41_NOMERE"),TamSX3("U41_NOMERE")[1],0,"","€€€€€€€€€€€€€€","C","","R","",""})
	
	
	elseif aFields[nX] == "RECU30"
		Aadd(aHeadEx, {"Id Hist","RECU30",PesqPict("U41","U41_RECU30"),TamSX3("U41_RECU30")[1],0,"","€€€€€€€€€€€€€€","N","","R","",""})
		
	endif
		
Next nX


// Define field values
For nX := 1 To Len(aHeadEx)
	
	if aHeadEx[nX,2] == "MARK"
		Aadd(aFieldFill, "UNCHECKED")
	elseif aHeadEx[nX,8] == "C"
		Aadd(aFieldFill, "")
	elseif aHeadEx[nX,8] == "N"
		Aadd(aFieldFill, 0)
	elseif aHeadEx[nX,8] == "D"
		Aadd(aFieldFill, CTOD("  /  /    "))
	elseif aHeadEx[nX,8] == "L"
		Aadd(aFieldFill, .F.)
	endif
	
Next nX

Aadd(aFieldFill, .F.)
Aadd(aColsEx, aFieldFill)

FreeObj(oGrid)

oGrid :=  MsNewGetDados():New(030,005,190,348,GD_UPDATE,"AllwaysTrue","AllwaysTrue",,aAlterFields,,999,;
		"AllwaysTrue","","AllwaysTrue",oTela, aHeadEx, aColsEx) 


Return(oGrid)

/*{Protheus.doc} RefreshGrid
//TODO Função chamada para preencher a grid de Retiradas
@author Raphael Martins
@since 30/07/2018
@version 1.0
@param oGrid 			- Objeto da Grid de Retiradas 
@param cContrato	 	- Codigo do Contrato em que sera consultado os seus servicos
@return lRet			- Encontrado contratos para reajustar
@type function
@history 14/07/2020, g.sampaio, No NOT EXISTS foi adicionado o filtro por contrato para verificar
se as cinzas foram retiradas corretamente.
/*/
Static Function RefreshGrid(oGrid,cContrato)

Local aArea			:= GetArea()
Local aAreaU00		:= U00->(GetArea())
Local aAreaU04		:= U04->(GetArea())
Local cQry			:= ""
Local cPulaLinha	:= Chr(13) + Chr(10)
Local lRet			:= .F.
	
// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

cQry := " SELECT "                                                                  + cPulaLinha
cQry += " U41_ITEM ITEM, "                                                          + cPulaLinha
cQry += " U30_CREMAT CREMAT, "                                                      + cPulaLinha
cQry += " U30_NICHOC COLUMBARIO, "                                                  + cPulaLinha
cQry += " U30_QUEMUT QUEM_UTIL, "                                                   + cPulaLinha
cQry += " U41_DTRETI DT_RETI, "                                                     + cPulaLinha
cQry += " U41_HORARE HORA_RET, "                                                    + cPulaLinha
cQry += " U41_NORINV INVOLUCRO, "                                                   + cPulaLinha
cQry += " U41_USER COD_USER, "                                                      + cPulaLinha
cQry += " U41_USRNOM NOME_USER, "                                                   + cPulaLinha
cQry += " U41_CPF CPF_RESG, "                                                       + cPulaLinha
cQry += " U41_RG RG, "                                                              + cPulaLinha
cQry += " U41_NOMERE RESGATADOR, "                                                  + cPulaLinha
cQry += " U41_ORGAO ORGAO, "                                                        + cPulaLinha
cQry += " U41_RECU30 RECNO_U30 "                                                    + cPulaLinha
cQry += " FROM  "                                                                   + cPulaLinha
cQry += + RetSQLName("U41") + " RETIRADA "                                          + cPulaLinha
cQry += " INNER JOIN "                                                              + cPulaLinha
cQry += + RetSQLName("U30") + " HISTORICO "                                         + cPulaLinha
cQry += " ON RETIRADA.D_E_L_E_T_ = ' ' "                                            + cPulaLinha
cQry += " AND HISTORICO.D_E_L_E_T_ = ' '  "                                         + cPulaLinha
cQry += " AND RETIRADA.U41_FILIAL = HISTORICO.U30_FILIAL "                          + cPulaLinha
cQry += " AND RETIRADA.U41_CODIGO = HISTORICO.U30_CODIGO "                          + cPulaLinha
cQry += " AND RETIRADA.U41_RECU30 = HISTORICO.R_E_C_N_O_ "                          + cPulaLinha
cQry += " WHERE "                                                                   + cPulaLinha
cQry += " 	RETIRADA.U41_FILIAL = '" + xFilial("U41") + "' "                        + cPulaLinha
cQry += " 	AND RETIRADA.U41_CODIGO = '" + cContrato + "' "                         + cPulaLinha
cQry += " 	AND NOT EXISTS ( SELECT U04_CODIGO "                                    + cPulaLinha
cQry += " 					FROM " + RetSQLName("U04") + " ENDERECO "               + cPulaLinha
cQry += " 					WHERE ENDERECO.D_E_L_E_T_ = ' ' "                       + cPulaLinha
cQry += " 					AND ENDERECO.U04_FILIAL = '" + xFilial("U04") + "' "    + cPulaLinha
cQry += " 					AND ENDERECO.U04_CODIGO = RETIRADA.U41_CODIGO"    		+ cPulaLinha // filtro o contrato para caso existam mais de uma cinza por nicho
cQry += " 					AND ENDERECO.U04_CREMAT = HISTORICO.U30_CREMAT "        + cPulaLinha
cQry += " 					AND ENDERECO.U04_NICHOC = HISTORICO.U30_NICHOC) "       + cPulaLinha
cQry += " ORDER BY ITEM "                                                           + cPulaLinha

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
		
		
		aadd(aFieldFill, "UNCHECKED")	
		aadd(aFieldFill, QRY->ITEM)
		aadd(aFieldFill, QRY->CREMAT)
		aadd(aFieldFill, QRY->COLUMBARIO)
		aadd(aFieldFill, QRY->QUEM_UTIL)
		aadd(aFieldFill, STOD(QRY->DT_RETI))
		aadd(aFieldFill, QRY->HORA_RET)
		aadd(aFieldFill, QRY->INVOLUCRO)
		aadd(aFieldFill, QRY->COD_USER)
		aadd(aFieldFill, QRY->NOME_USER)
		aadd(aFieldFill, QRY->CPF_RESG)
		aadd(aFieldFill, Alltrim(QRY->RG))
		aadd(aFieldFill, Alltrim(QRY->ORGAO))
		aadd(aFieldFill, Alltrim(QRY->RESGATADOR))
		aadd(aFieldFill, QRY->RECNO_U30)
		
		Aadd(aFieldFill, .F.)
		aadd(oGrid:Acols,aFieldFill) 
		
		QRY->(DbSkip())
		
	EndDo
	
else
	
		aadd(aFieldFill, "UNCHECKED")	
		aadd(aFieldFill, "")
		aadd(aFieldFill, "")
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
		aadd(aFieldFill, 0)
		
	Aadd(aFieldFill, .F.)
	
	aadd(oGrid:Acols,aFieldFill) 
	
endif

oGrid:oBrowse:Refresh()

RestArea(aArea)
RestArea(aAreaU00)
RestArea(aAreaU04)

Return(lRet)

/*/{Protheus.doc} DuoClique
//TODO Função chamada no duplo clique no grid
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param _obj	 			- Objeto da Grid de Contratos 
@return Sem Retorno
@type function
/*/

Static Function DuoClique(oObj)

Local nPosMark	:= aScan(oObj:aHeader,{|x| AllTrim(x[2])== "MARK"})       

if oObj:aCols[oObj:nAt][nPosMark] == "CHECKED"
	
	oObj:aCols[oObj:nAt][nPosMark] 	:= "UNCHECKED" 

else

	oObj:aCols[oObj:nAt][nPosMark] 	:= "CHECKED" 

endif

oObj:oBrowse:Refresh()

Return()

/*/{Protheus.doc} MarcaTodos
//TODO Função chamada pela ação de clicar no cabeçalho dos grids
para selecionar todos os checkbox
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param _obj	 			- Objeto da Grid de Enderecos 
@return Sem Retorno
@type function
/*/

Static Function MarcaTodos(_obj)

Local nX		:= 1


if __XVEZ == "0"
	__XVEZ := "1"
else
	if __XVEZ == "1"
		__XVEZ := "2"
	endif
endif

If __XVEZ == "2"
	
	nGetTotal := 0 
	nQtTotal  := 0 

	If _nMarca == 0
		
		For nX := 1 TO Len(_obj:aCols)
			_obj:aCols[nX][1] := "CHECKED"
		Next
		
		_nMarca := 1
		
	Else
		
		For nX := 1 To Len(_obj:aCols)
			_obj:aCols[nX][1] := "UNCHECKED"
		Next
		
		_nMarca := 0
		
	Endif
	
	__XVEZ:="0"
	
	// atualizo objetos
	_obj:oBrowse:Refresh()

Endif

Return()

/*/{Protheus.doc} ConfExcRetC
//TODO Funcao para confirmar 
a exclusao retirada de cinza
@author Raphael Martins
@since 08/08/2018
@version 1.0
@param _obj	 			- Objeto da Grid de Retiradas 
@return Sem Retorno
@type function
/*/

Static Function ConfExcRetC(cContrato,oGrid,oTela)

Local lRet			:= .T.
Local nPosMark		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])== "MARK"}) 
Local nPosItem		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])== "ITEM"}) 
Local nPosCremat	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])== "CREMATORIO"}) 
Local nPosNihoC		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])== "COLUMBARIO"}) 
Local nPosRecU30	:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])== "RECU30"}) 
Local nMark			:= aScan(oGrid:aCols,{|x| AllTrim(x[1])== "CHECKED"})
Local nX			:= 0
Local nRecnoU30		:= 0
Local cCremat		:= ""
Local cNichoC		:= ""
Local cItemEnd		:= ""

//verifico se algum item foi marcado
if nMark > 0
	
	Begin Transaction 
	
	For nX := 1 To Len(oGrid:aCols)
		
		//verifico se o item esta marcado
		if oGrid:aCols[nX,nPosMark] == "CHECKED"
		
			cItem		:= oGrid:aCols[nX,nPosItem]
			cCremat		:= oGrid:aCols[nX,nPosCremat]
			cNichoC		:= oGrid:aCols[nX,nPosNihoC]
			nRecnoU30	:= oGrid:aCols[nX,nPosRecU30]
			
			U04->(DbSetOrder(3)) //U04_FILIAL+U04_CREMAT+U04_NICHOC 
		
			If !U04->(DbSeek(xFilial("U04")+cCremat+cNichoC))
				
				//posiciono no historico de retirada para retornar os dados do enderecamento
				U30->(DbGoto(nRecnoU30))
				
				cItemEnd := RetLstEnd(cContrato)
				
				U41->(DbSetOrder(1)) //U41_FILIAL+U41_CODIGO+U41_ITEM
				
				//deleto a retirada de cinzas
				if U41->(DbSeek(xFilial("U41")+cContrato+cItem))
					
					RecLock("U41",.F.)
					
					U41->(DbDelete())
					
					U41->(MsUnlock())
				
					RecLock("U04",.T.)
					
					U04->U04_FILIAL := xFilial("U04")
					U04->U04_CODIGO	:= cContrato
					U04->U04_ITEM	:= cItemEnd
					U04->U04_TIPO	:= "C" //Jazigo
					U04->U04_QUADRA	:= ""
					U04->U04_MODULO	:= ""		
					U04->U04_JAZIGO	:= ""	
					U04->U04_GAVETA := ""
					U04->U04_DTUTIL	:= U30->U30_DTUTIL 
					U04->U04_QUEMUT	:= U30->U30_QUEMUT
					U04->U04_PRZEXU	:= dDatabase	
					U04->U04_CREMAT	:= U30->U30_CREMAT
					U04->U04_NICHOC	:= U30->U30_NICHOC 				
					U04->U04_DATA	:= U41->U41_DTRETI
					
					U04->(MsUnlock())
				
					//deleto o historico gerado
					RecLock("U30",.F.)
				
						U30->(DbDelete())
					
					U30->(MsUnlock())
				
				endif
				
			elseif !MsgYesNo("O Endereço utilizado pelo item: " + cItem + " está sendo utilizado pelo contrato: " + U04->U04_CODIGO + Chr(13) + Chr(10) + ;
			 				"Portanto não será possivel estornar esta retirada, deseja continuar a retirada para os demais itens?","Atenção!")
				
				lRet := .F.
				DisarmTransaction()
				Exit 
				
			endif
			
		endif
		
	Next nX
	
	End Transaction 
	
else

	
	lRet := .F.
	Help(,,'Help',,"Selecione ao menos uma cremação para realizar o estorno da retirada das cinzas",1,0)
	
endif

if lRet
	
	MsgInfo("Retirada de Cinzas Realizada com Sucesso!")
	oTela:End()
	
endif

Return(lRet)

/*/{Protheus.doc} ProxU04
Funcao para consultar o ultimo 
item da U04 - Enderecamento
@author Raphael Martins 
@since 08/08/2018
@version P12
@param cContrato - Contrato 
@return nulo
/*/

Static Function RetLstEnd(cContrato)

	Local aArea		:= GetArea()
	Local aAreaU04	:= U04->(GetArea())
	Local cQry		:= ""
	Local cProxItem	:= ""
	
	cQry := " SELECT 
	cQry += " ISNULL(MAX(U04_ITEM),'00') MAX_ITEM "
	cQry += " FROM "
	cQry += + RetSQLName("U04") + " ENDERECO "
	cQry += " WHERE "
	cQry += " ENDERECO.D_E_L_E_T_ = ' ' " 
	cQry += " AND ENDERECO.U04_FILIAL = '"+xFilial("U04")+"' "
	cQry += " AND ENDERECO.U04_CODIGO = '"+cContrato+"' "
	
	// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf
	
	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)
	
	// crio o alias temporario
	TcQuery cQry New Alias "QRY"
	
	//proximo item da tabela de enderecamento
	cProxItem := StrZero(VAL(QRY->MAX_ITEM) + 1,3)
	
	RestArea(aArea)
	RestArea(aAreaU04)

Return(cProxItem)


