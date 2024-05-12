#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*/{Protheus.doc} RFUNA027
//TODO Rotina de geracao de adiantamento de parcelas.
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function RFUNA027()          
              
	Local oFont14 			:= TFont():New("Arial",,014,,.T.,,,,,.F.,.F.)
	Local oFont13 			:= TFont():New("Arial",,013,,.T.,,,,,.F.,.F.)
	Local oFont13N 			:= TFont():New("Arial",,013,,.T.,,,,,.F.,.F.)
	Local oDlg				:= NIL
	Local oGroup1			:= NIL
	Local oGroup2			:= NIL
	Local oGroup3			:= NIL
	Local oSay1				:= NIL
	Local oSay2				:= NIL
	Local oSay3				:= NIL
	Local oSay4				:= NIL
	Local oSay5				:= NIL
	Local oSay6				:= NIL
	Local oSay7				:= NIL
	Local oSay8				:= NIL
	Local oSay9				:= NIL
	Local oSay10			:= NIL
	Local oSay11			:= NIL
	Local oContrato			:= NIL
	Local oTitular			:= NIL
	Local oAtivacao			:= NIL
	Local oParcelas			:= NIL
	Local oParcPagas		:= NIL
	Local oParcVenc			:= NIL
	Local oParcRest			:= NIL
	Local oVlrParc			:= NIL
	Local cContrato			:= "" 
	Local cTitular			:= ""
	Local dAtivacao			:= CTOD("")
	Local nParcelas			:= 0
	Local nParPagas			:= 0
	Local nParcCarencia		:= 0
	Local nParcVencidas		:= 0
	Local nParcRestantes	:= 0
	Local nValorParc		:= 0
	Local nGetParc			:= 0
	Local nGetVlr			:= 0
	Local nGetParc			:= 0 

	//sera permitido apenas para contratos ativos realizar o adiantamento de parcelas
	if UF2->UF2_STATUS == 'A'
		
		//carrego as variaveis com os dados do contrato
		cContrato		:= UF2->UF2_CODIGO
		dAtivacao		:= UF2->UF2_DTATIV
		nParcelas		:= UF2->UF2_QTPARC
		nParPagas 		:= RetParcPagas(UF2->UF2_CODIGO)
		nParcCarencia 	:= UF2->UF2_QTPCAR
		nParcVencidas	:= RetParcVenc(UF2->UF2_CODIGO)
		nParcRestantes	:= nParcCarencia - nParPagas
		nValorParc		:= UF2->UF2_VALOR + UF2->UF2_VLADIC
		nGetVlr			:= nValorParc 
				
		// carrego os dados do Titular do contrato
		cTitular := Alltrim(UF2->UF2_CLIENT)
		cTitular += "/"
		cTitular += Alltrim(UF2->UF2_LOJA)
		cTitular += " - "
		cTitular += Alltrim( RetField("SA1",1,xFilial("SA1")+UF2->UF2_CLIENT+UF2->UF2_LOJA,"A1_NOME") )
	
	
		DEFINE MSDIALOG oDlg TITLE "Adiantamento de Parcelas" FROM 000, 000  TO 293, 597 COLORS 0, 16777215 PIXEL
	
		@ 003, 003 GROUP oGroup1 TO 084, 296 PROMPT " Dados do Contrato " OF oDlg COLOR 0, 16777215 PIXEL
		oGroup1:oFont := oFont14
	
		@ 015, 009 SAY oSay1 PROMPT "Contrato:" SIZE 025, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 015, 037 SAY oContrato PROMPT cContrato SIZE 025, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL
	
		@ 015, 068 SAY oSay2 PROMPT "Titular:" SIZE 025, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 015, 091 SAY oTitular PROMPT cTitular SIZE 134, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL
	
		@ 028, 009 SAY oSay3 PROMPT "Data Ativacao:" SIZE 050, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 028, 067 SAY oAtivacao PROMPT dAtivacao SIZE 035, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL
	
		@ 028, 110 SAY oSay4 PROMPT "Qtd Parcelas:" SIZE 045, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 028, 168 SAY oParcelas PROMPT nParcelas SIZE 025, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL
	
		@ 041, 009 SAY oSay5 PROMPT "Parcelas Pagas:" SIZE 052, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 041, 067 SAY oParcPagas PROMPT nParPagas SIZE 025, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL
	
		@ 041, 110 SAY oSay6 PROMPT "Parcelas Carencia: " SIZE 057, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 041, 168 SAY oParcCar PROMPT nParcCarencia SIZE 025, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL
	
		@ 054, 009 SAY oSay7 PROMPT "Parcelas Vencidas:" SIZE 055, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 054, 067 SAY oParcVenc PROMPT nParcVencidas SIZE 025, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL
	
		@ 054, 110 SAY oSay8 PROMPT "Restantes:" SIZE 031, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 054, 168 SAY oParcRest PROMPT nParcRestantes SIZE 025, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL
	
		@ 067, 009 SAY oSay09 PROMPT "Valor da Parcela:" SIZE 055, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 067, 067 SAY oVlrParc PROMPT  AllTrim(TransForm(nValorParc,"@E 999,999.99")) SIZE 037, 007 OF oDlg FONT oFont13 COLORS 8421504, 16777215 PIXEL
	
		@ 088, 003 GROUP oGroup2 TO 117, 296 PROMPT " Dados do Adiantamento " OF oDlg COLOR 0, 16777215 PIXEL
		oGroup2:oFont := oFont14
	
	
		@ 101, 009 SAY oSay10 PROMPT "Parcelas:" SIZE 031, 007 OF oDlg FONT oFont13N COLORS 0, 16777215 PIXEL
		@ 100, 038 MSGET oGet1 VAR nGetParc SIZE 050, 010 OF oDlg COLORS 8421504, 16777215 PICTURE "@E 99999" HASBUTTON PIXEL
	
		@ 101, 108 SAY oSay11 PROMPT "Valor:" SIZE 025, 007 OF oDlg FONT oFont13N COLORS 0, 16777215  PIXEL
		@ 100, 131 MSGET oGet2 VAR nGetVlr SIZE 050, 010 OF oDlg COLORS 8421504, 16777215 PICTURE "@E 999,999.99" HASBUTTON PIXEL
	
		@ 121, 003 GROUP oGroup3 TO 142, 296 OF oDlg COLOR 0, 16777215 PIXEL
	
		@ 126, 209 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 Action(FWMsgRun(,{|oSay| ConfirmaAdt(oSay,oDlg,nGetParc,nGetVlr,cContrato) },'Aguarde...','Carregando Dados para Geracao de Adiantamento...')) OF oDlg PIXEL
		@ 126, 252 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 Action( oDlg:End()) OF oDlg PIXEL
	
		ACTIVATE MSDIALOG oDlg CENTERED
		
	else
		
		Help(,,'Help',,"Permitido realizar adiantamento apenas para contratos ativos!",1,0)
		
	endif
	
	
Return

/*/{Protheus.doc} RFUNA027
//Funcao para consultar as parcelas pagas
do contrato
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return nQtdParc, Quantidade de Parcelas pagas
@type function
/*/
Static Function RetParcPagas(cContrato)

Local cPrefixo		:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
Local cTipoParc		:= SuperGetMv("MV_XTIPFUN",.F.,"AT")
Local cTipoAdt		:= SuperGetMv("MV_XTIPADT",.F.,"ADT")
Local cTipoRJ		:= SuperGetMv("MV_XTRJFUN",.F.,"RJ") 

Local cQry 			:= ""
Local cPulaLinha	:= Chr(13) + Chr(10)
Local nQtdParc		:= 0

cQry := " SELECT "
cQry += " COUNT(*) QTD_PARCELAS "
cQry += " FROM "
cQry += " " + RetSQLName("SE1") + " "
cQry += " WHERE "
cQry += " D_E_L_E_T_ = ' ' "
cQry += " AND E1_FILIAL = '" + xFilial("SE1") + "' "
cQry += " AND E1_PREFIXO = '" + cPrefixo + "'" 
cQry += " AND E1_TIPO IN ('" + cTipoParc + "','" + cTipoAdt + "','" + cTipoRJ + "')" 
cQry += " AND E1_XCTRFUN = '" + cContrato + "' "
cQry += " AND E1_SALDO = 0 "

If Select("QRYTIT") > 0
	QRYTIT->(dbCloseArea())
EndIf

cQry := Changequery(cQry)

TcQuery cQry New Alias "QRYTIT"

nQtdParc := QRYTIT->QTD_PARCELAS


Return(nQtdParc)

/*/{Protheus.doc} RFUNA027
//Funcao para consultar as parcelas vencidas
do contrato
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return nQtdParc, Quantidade de Parcelas vencidas
@type function
/*/
Static Function RetParcVenc(cContrato)

Local cPrefixo		:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
Local cTipoParc		:= SuperGetMv("MV_XTIPFUN",.F.,"AT")
Local cTipoAdt		:= SuperGetMv("MV_XTIPADT",.F.,"ADT")
Local cTipoRJ		:= SuperGetMv("MV_XTRJFUN",.F.,"RJ") 
Local cQry 			:= ""
Local nQtdParc		:= 0

cQry := " SELECT "
cQry += " COUNT(*) QTD_PARCELAS "
cQry += " FROM "
cQry += " " + RetSQLName("SE1") + " "
cQry += " WHERE "
cQry += " D_E_L_E_T_ = ' ' "
cQry += " AND E1_FILIAL = '" + xFilial("SE1") + "' "
cQry += " AND E1_PREFIXO = '" + cPrefixo + "'" 
cQry += " AND E1_TIPO IN ('" + cTipoParc + "','" + cTipoAdt + "','" + cTipoRJ + "') " 
cQry += " AND E1_XCTRFUN = '" + cContrato + "'
cQry += " AND E1_SALDO > 0 "
cQry += " AND E1_VENCREA < '" + DTOS( dDataBase ) + "'" 

If Select("QRYTIT") > 0
	QRYTIT->(dbCloseArea())
EndIf

cQry := Changequery(cQry)

TcQuery cQry New Alias "QRYTIT"

nQtdParc := QRYTIT->QTD_PARCELAS


Return(nQtdParc)

/*/{Protheus.doc} RFUNA027
//Funcao para gerar os adiantamentos das parcelas
do contrato
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return lRet, Gerado ou nao adiantamento
@type function
/*/
Static Function ConfirmaAdt(oSay,oDlg,nQtdParc,nVlrParc,cContrato)

Local aArea			:= GetArea() 
Local aAreaSE1		:= SE1->(GetArea())
Local aAreaUF2		:= UF2->(GetArea())
Local aDados		:= {}
Local aHistorico	:= {}
Local lRet			:= .T.
Local cPrefixo 		:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
Local cTipo			:= SuperGetMv("MV_XTIPADT",.F.,"ADT")
Local cNatureza		:= UF2->UF2_NATURE 
Local cMesAno		:= ""
Local cParcela		:= ""
Local lUsaPrimVencto:= SuperGetMv("MV_XPRIMVC",.F.,.F.)
Local lReajustaAdt	:= SuperGetMv("MV_XREJADT",.F.,.F.) 
Local nX			:= 0 
Local dLastVencto	:= CTOD("")
Local dVencimento	:= CTOD("")

Private lMsErroAuto	:= .F.

//valido se foi digitado a quantidade de parcelas e valores
if nQtdParc > 0 .And. nVlrParc > 0 
	
	//dia de vencimento das parcelas
	cDiaVencto	:= if(!Empty(UF2->UF2_DIAVEN),UF2->UF2_DIAVEN,SubStr(DTOC(UF2->UF2_PRIMVE),1,2))
	dLastVencto	:= LastVencto(cContrato)
	cParcela	:= LastParcela(cContrato)
	
	Begin Transaction 
				
	For nX := 1 To nQtdParc 
		
		//valido se o dia de vencimento e maior que o ultimo dia do proximo mes
		if Val(cDiaVencto) > Val(Day2Str( LastDay(MonthSum(dLastVencto,1) ) ) ) 
		
			dVencimento := CtoD( cValToChar(Day(LastDay(MonthSum(dLastVencto,1)))) + "/" + Month2Str( MonthSum(dLastVencto,1)) + "/" + Year2Str(MonthSum(dLastVencto,1) ) )
		
		else
		
			dVencimento := CtoD( cDiaVencto + "/" + Month2Str( MonthSum(dLastVencto,1)) + "/" + Year2Str(MonthSum(dLastVencto,1) ) )
		
		endif
		
		oSay:cCaption := ("Contrato: " + AllTrim(cContrato) + ", gerando parcela " + cParcela + ", vencimento " + DTOC(dVencimento) + " ...")
		ProcessMessages()
		
		
		cMesAno 	:= SubStr(DTOC(dVencimento),4,7)  
		aDados		:= {}
		
		AAdd(aDados, {"E1_FILIAL"	, xFilial("SE1")					, Nil } )
		AAdd(aDados, {"E1_PREFIXO"	, cPrefixo          				, Nil } )
		AAdd(aDados, {"E1_NUM"		, cContrato		 	   				, Nil } )
		AAdd(aDados, {"E1_PARCELA"	, cParcela							, Nil } )
		AAdd(aDados, {"E1_TIPO"		, cTipo		 						, Nil } )
		AAdd(aDados, {"E1_NATUREZ"	, cNatureza							, Nil } )
		AAdd(aDados, {"E1_CLIENTE"	, UF2->UF2_CLIENT					, Nil } )
		AAdd(aDados, {"E1_LOJA"		, UF2->UF2_LOJA						, Nil } )
		AAdd(aDados, {"E1_EMISSAO"	, dDataBase							, Nil } )
		AAdd(aDados, {"E1_VENCTO"	, dVencimento						, Nil } )
		AAdd(aDados, {"E1_VENCREA"	, DataValida(dVencimento)			, Nil } )
		AAdd(aDados, {"E1_VALOR"	, nVlrParc							, Nil } )			
		AAdd(aDados, {"E1_XCTRFUN"	, cContrato							, Nil } )
		AAdd(aDados, {"E1_XPARCON"	, cMesAno							, Nil } )
		AAdd(aDados, {"E1_XFORPG"	, UF2->UF2_FORPG					, Nil } )
		
		// array de historico de adiantamento
		AAdd(aHistorico,{cPrefixo,cContrato,cParcela,cTipo,nVlrParc})
		
		//o ultimo vencimento sempre assume a data da ultima parcela
		dLastVencto := dVencimento 
		cParcela	:= Soma1(cParcela)
		
		lMsErroAuto := .F.
				
		MSExecAuto({|x,y| FINA040(x,y)},aDados,3)
				
		if lMsErroAuto
		
			MostraErro()
			DisarmTransaction()	
			lRet := .F.
			Exit
			
		else
			lRet := .T.
		endif
		
	Next nX
	
	End Transaction 
	
	//se gravou os titulos corretamente, gravo historico de adiantamentos
	if lRet
	
		lRet := GravaHistorico(cContrato,UF2->UF2_CLIENT,UF2->UF2_LOJA,aHistorico)
	
	endif
	
	/////////////////////////////////////////////////////////////////////////////////////////////
	//Valido se atualiza a data do proximo reajuste de acordo com a data de vencimento da ultima 
	//parcela do adiantamento
	/////////////////////////////////////////////////////////////////////////////////////////////
	if lReajustaAdt

		ProcPrxReaj(cContrato,dLastVencto)
	
	endif

	//adiantamento gerado com sucesso
	if lRet
		MsgInfo("Titulo(s) de Adiantamento gerados com sucesso!")
		oDlg:End()
	endif
	
	 
else

	Help(,,'Help',,"Os campos Quantidade de Parcelas e Valor das Parcelas é obrigatório, Favor digite-os antes de confirmar!",1,0)
	
	
endif
 
 

RestArea(aArea)
RestArea(aAreaSE1)
RestArea(aAreaUF2)

Return(lRet)

/*/{Protheus.doc} RFUNA027
//Funcao para consultar a data de vencimento
da ultima parcela do contrato
do contrato
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return lRet, Gerado ou nao adiantamento
@type function
/*/
Static Function LastVencto(cContrato)

Local cPrefixo		:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
Local cTipoADT		:= SuperGetMv("MV_XTIPADT",.F.,"ADT")
Local cTipoParc		:= SuperGetMv("MV_XTIPFUN",.F.,"AT")
Local cTipoRJ		:= SuperGetMv("MV_XTRJFUN",.F.,"RJ") // tipo do título
Local cQry 			:= ""
Local dLastVencto	:= CTOD("")
Local cLastParc		:= ""

cQry := " SELECT "
cQry += " MAX(E1_VENCTO) VENCIMENTO "
cQry += " FROM "
cQry += " " + RetSQLName("SE1") + " "
cQry += " WHERE "
cQry += " D_E_L_E_T_ = ' ' "
cQry += " AND E1_FILIAL = '" + xFilial("SE1") + "' "
cQry += " AND E1_PREFIXO = '" + cPrefixo + "'" 
cQry += " AND E1_TIPO IN ('" + cTipoADT + "','" + cTipoParc+ "','" + cTipoRJ + "') " 
cQry += " AND E1_XCTRFUN = '" + cContrato + "' "

If Select("QRYTIT") > 0
	QRYTIT->(dbCloseArea())
EndIf

cQry := Changequery(cQry)

TcQuery cQry New Alias "QRYTIT"

dLastVencto := STOD(QRYTIT->VENCIMENTO)

Return(dLastVencto)

/*/{Protheus.doc} RFUNA027
//Funcao para consultar a data de vencimento
da ultima parcela do contrato
do contrato
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return lRet, Gerado ou nao adiantamento
@type function
/*/
Static Function LastParcela(cContrato)

Local cPrefixo		:= Alltrim(SuperGetMv("MV_XPREFUN",.F.,"FUN"))
Local cTipoADT		:= Alltrim(SuperGetMv("MV_XTIPADT",.F.,"ADT"))
Local cTipoParc		:= Alltrim(SuperGetMv("MV_XTIPFUN",.F.,"AT")) 
Local cTipoRJ		:= Alltrim(SuperGetMv("MV_XTRJFUN",.F.,"RJ")) 
Local cQry 			:= ""
Local cLastParc		:= ""

cQry := " SELECT "
cQry += " MAX(E1_PARCELA) PARCELA "
cQry += " FROM "
cQry += " " + RetSQLName("SE1") + " "
cQry += " WHERE "
cQry += " D_E_L_E_T_ = ' ' "
cQry += " AND E1_FILIAL = '" + xFilial("SE1") + "' "
cQry += " AND E1_PREFIXO = '" + cPrefixo + "'" 
cQry += " AND E1_TIPO IN ('" + cTipoADT + "','" + cTipoParc+ "','" + cTipoRJ + "') " 
cQry += " AND E1_XCTRFUN = '" + cContrato + "' "

If Select("QRYTIT") > 0
	QRYTIT->(dbCloseArea())
EndIf

cQry := Changequery(cQry)

TcQuery cQry New Alias "QRYTIT"

// se existir títulos com este tipo
if QRYTIT->(!Eof()) .AND. !Empty(QRYTIT->PARCELA)
	cLastParc := STRZERO(Val(Soma1(QRYTIT->PARCELA)),3)	
else
	cLastParc := Padl("1",TamSX3("E1_PARCELA")[1],"0")		
endif


Return(cLastParc)


/*/{Protheus.doc} GravaHistorico
//Funcao para gerar o historico do adiantamento gerado
da ultima parcela do contrato
do contrato
@author Raphael Martins
@since 29/03/2018
@version 1.0
@return lRet, Gerado ou nao adiantamento
@type function
/*/
Static Function GravaHistorico(cContrato,cCliente,cLoja,aDados)

Local oAux
Local oStruct
Local cMaster 		:= "UG8"
Local cDetail		:= "UG9"
Local aCpoMaster	:= {}
Local aLinha		:= {}
Local aCpoDetail	:= {}
Local oModel  		:= FWLoadModel("RFUNA026") // instanciamento do modelo de dados
Local nX			:= 1
Local nI       		:= 0
Local nJ       		:= 0
Local nPos     		:= 0
Local lRet     		:= .T.
Local aAux	   		:= {}
Local nItErro  		:= 0
Local lAux     		:= .T.
Local cItem 		:= PADL("1",TamSX3("UG9_ITEM")[1],"0")

aadd(aCpoMaster,{"UG8_FILIAL"	, xFilial("UG8")	})
aadd(aCpoMaster,{"UG8_DATA"		, dDataBase			})
aadd(aCpoMaster,{"UG8_CONTRA"	, cContrato			})
aadd(aCpoMaster,{"UG8_CLIENT"	, cCliente			})
aadd(aCpoMaster,{"UG8_LOJA"		, cLoja				})
aadd(aCpoMaster,{"UG8_USER"		, cUserName			})



For nX := 1 To Len(aDados)
		
	aLinha := {}
		
	aadd(aLinha,{"UG9_FILIAL"	, xFilial("UG9")	})
	aadd(aLinha,{"UG9_ITEM"		, cItem				})
	aadd(aLinha,{"UG9_PREFIX"	, aDados[nX,1]		})
	aadd(aLinha,{"UG9_NUM"		, aDados[nX,2]		})
	aadd(aLinha,{"UG9_PARCEL"	, aDados[nX,3]		})
	aadd(aLinha,{"UG9_TIPO"		, aDados[nX,4]		})
	aadd(aLinha,{"UG9_VALOR"	, aDados[nX,5]		})
	
	aadd(aCpoDetail,aLinha)
	
	cItem := SOMA1(cItem)
	
		
Next nX

(cDetail)->(DbSetOrder(1))
(cMaster)->(DbSetOrder(1))

// defino a operação de inclusão
oModel:SetOperation(3)

// Antes de atribuirmos os valores dos campos temos que ativar o modelo
lRet := oModel:Activate()

If lRet
	
	// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
	oAux := oModel:GetModel( cMaster + 'MASTER' )
	
	// Obtemos a estrutura de dados do cabeçalho
	oStruct := oAux:GetStruct()
	aAux := oStruct:GetFields()
	
	If lRet
		
		For nI := 1 To Len(aCpoMaster)
			
			// Verifica se os campos passados existem na estrutura do cabeçalho
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoMaster[nI][1] ) } ) ) > 0
				
				// È feita a atribuicao do dado aos campo do Model do cabeçalho
				If !( lAux := oModel:SetValue( cMaster + 'MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )
					
					// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
					// o método SetValue retorna .F.
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
		
		// Incluímos uma linha nova
		// ATENCAO: O itens são criados em uma estrura de grid (FORMGRID), portanto já é criada uma primeira linha
		//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2ª vez
		
		If nI > 1
			
			// Incluimos uma nova linha de item
			
			If  ( nItErro := oAux:AddLine() ) <> nI
				
				// Se por algum motivo o metodo AddLine() não consegue incluir a linha,
				// ele retorna a quantidade de linhas já
				// existem no grid. Se conseguir retorna a quantidade mais 1
				lRet    := .F.
				Exit
				
			EndIf
			
		EndIf
		
		For nJ := 1 To Len( aCpoDetail[nI] )
			
			// Verifica se os campos passados existem na estrutura de item
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) ==  AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0
				
				If !( lAux := oModel:SetValue( cDetail + 'DETAIL', aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )
					
					// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
					// o método SetValue retorna .F.
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
	
	// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
	// neste momento os dados não são gravados, são somente validados.
	If ( lRet := oModel:VldData() )
		
		// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
		lRet := oModel:CommitData()
		
	EndIf
	
EndIf

If !lRet
	
	// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
	aErro   := oModel:GetErrorMessage()
	
	// A estrutura do vetor com erro é:
	//  [1] Id do formulário de origem
	//  [2] Id do campo de origem
	//  [3] Id do formulário de erro
	//  [4] Id do campo de erro
	//  [5] Id do erro
	//  [6] mensagem do erro
	//  [7] mensagem da solução
	//  [8] Valor atribuido
	//  [9] Valor anterior
	
	AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
	AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
	AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
	AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
	AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
	AutoGrLog( "Mensagem do erro:          " + ' [' + AllToChar( aErro[6]  ) + ']' )
	AutoGrLog( "Mensagem da solução:       " + ' [' + AllToChar( aErro[7]  ) + ']' )
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

/*/{Protheus.doc} ProcPrxReaj
Altera o historico de reajuste 
para a ultima parcela alterada
@type function
@version 1.0 
@author Raphael Martins
@since 03/02/2021
@param cContrato, character, Codigo do contrato a ser alterado
@param dVencto, date, data de vencimento da ultima parcela de adiantamento
/*/
Static Function ProcPrxReaj(cContrato,dVencto)

Local aArea		:= GetArea()
Local aAreaUF2	:= UF2->(GetArea())

cQry := " SELECT " 
cQry += " MAX(R_E_C_N_O_) ID_RECNO " 
cQry += " FROM "
cQry += " " + RetSQLName("UF7") +  " UF7 "
cQry += " WHERE "
cQry += " UF7.D_E_L_E_T_ <> '*' "
cQry += " AND UF7.UF7_FILIAL = '" + xFilial("UF7")+ "' "
cQry += " AND UF7.UF7_CONTRA = '" + cContrato +"' " 

// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

// Altero o proximo reajuste de acordo com as parcelas geradas da personalizacao 
if QRY->ID_RECNO > 0 
	
	UF7->(DbGoto(QRY->ID_RECNO ))
	
	Reclock("UF7",.F.)
	
	UF7->UF7_PROREA := StrZero(Month(dVencto),2) + StrZero(Year(dVencto),4)
	
	UF7->(MsUnlock())
	
	
endif



RestArea(aArea)
RestArea(aAreaUF2)


Return()

