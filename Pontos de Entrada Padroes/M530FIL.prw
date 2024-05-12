#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} M530AGL
O ponto de entrada M530FIL existe na função fa530Processa "Atualização do Pagamento de Comissões (MATA530)" 
e será disparado para filtrar os vendedores conforme os parâmetros dos clientes.

Esta sendo utilizado para filtrar as comissões cujos os títulos já tenham sido recebidos (baixados).

@author pablocavalcante
@since 21/06/2016
@version undefined

@type function
/*/

User Function M530FIL()

Local cRet := "U_SE1FILTR()"
	
Return(cRet)

//
// Filtro para a SE3: somente os titulos da SE1 que ja tenham sido recebidos (baixados). 
//
User Function SE1FILTR()
Local aEstSE3 			:= SE3->(GetArea())
Local lRet 				:= .T.
Local lUsaNovaComissao	:= SuperGetMv("ES_NEWCOMI",,.F.)	// ativo o uso da nova comissao
Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)

// verifico se estou usando o novo modelo comissao
If !lUsaNovaComissao .And. (lCemiterio .Or. lFuneraria)

	DbSelectArea("SE1")
	SE1->(DbSetOrder(2))  //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If SE1->(DbSeek(xFilial("SE1")+SE3->(E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO)))
		If SE1->E1_SALDO > 0 .Or. VerFatura(SE1->E1_FATPREF,SE1->E1_FATURA,SE1->E1_TIPOFAT,)
			lRet := .F. 
		EndIF
	EndIF
Endif

RestArea(aEstSE3)
 
Return(lRet)

//
// Valida se a baixa do titulo foi pela geracao de fatura 
//

Static Function VerFatura(cPrefixoFat,cFatura,cTipoFat) 

Local aArea    := GetArea()
Local aAreaSE1 := SE1->( GetArea() )
Local lRet 	   := .F.
Local cSQL     := ""

cSQL := " SELECT R_E_C_N_O_ ID " 
cSQL += "  FROM "+RetSQLName("SE1")+" "
cSQL += " WHERE D_E_L_E_T_ = ' ' "
cSQL += "  AND E1_FILIAL   = '"+xFilial("SE1")+"' "
cSQL += "  AND E1_PREFIXO  = '" + cPrefixoFat + "' "
cSQL += "  AND E1_NUM      = '" + cFatura + "' "
cSQL += "  AND E1_TIPO     = '" + cTipoFat + "' "
cSQL += "  AND E1_FATURA   = 'NOTFAT' "
cSQL += "  AND E1_SALDO    > 0 "


If Select("QSE1") > 0                                            
	QSE1->( DbCloseArea() )
EndIf

cSQL := ChangeQuery(cSQL)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"QSE1",.F.,.F.)

QSE1->( DbGotop() )

If QSE1->( !EOF() )
	lRet := .T.
EndIf

RestArea(aArea)
RestArea(aAreaSE1)

QSE1->( DbCloseArea() )

Return(lRet)
