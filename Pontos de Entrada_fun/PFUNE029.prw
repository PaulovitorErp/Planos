#include "protheus.ch" 
#include "fwmvcdef.ch"
#include "topconn.ch"

/*/{Protheus.doc} PFUNE029
Pontos de Entrada
Personalizacao de Planos
@author Raphael Martins 
@since 23/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function PFUNE029()

	Local aParam 		:= PARAMIXB
	Local oObj			:= aParam[1]
	Local cIdPonto		:= aParam[2]
	Local lRet 			:= .T.
	

	// confirmação do cadastro
	If cIdPonto == "MODELCOMMITTTS" 
		
		//atualizo os campos de valor negociado
		if lRet 
			
			RecLock("UH2",.F.)
			
			UH2->UH2_VLRANT := oResumoTotal:nValAtual
			UH2->UH2_NEWVLR := oResumoTotal:nNewValor
			
			UH2->(MsUnlock())
			
			//reseto os valores de reajuste, pois ha uma nova negociacao
			RecLock("UF2",.F.)
			
			UF2->UF2_VLADIC := 0 
			
			UF2->(MsUnlock())
			
		endif
		
	ElseIf cIdPonto == 'MODELPOS'
	
		if oObj:GetOperation() == 3 //Confirmação da inclusao
		
			FWMsgRun(,{|oSay| lRet := ValidaPer(oObj)},'Aguarde...','Validando Dados da Personalizacao')
			
			if lRet
			
				// gero os títulos
				FWMsgRun(,{|oSay| lRet := ConfirmaPer(oSay,oObj)},'Aguarde...','Confirmando a Personalizacao do Contrato!')
			
			endif
			
		
		endif
		
	endif

	
Return(lRet)

/*/{Protheus.doc} ValidaPer
Funcao para validar a consistencia
dos dados digitados no cadastro
@author Raphael Martins 
@since 23/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

Static Function ValidaPer(oObj)

	Local oModelUH2		:= oObj:GetModel("UH2MASTER")
	Local lRet			:= .F.	
	Local nX			:= 0 
	Local lAlt			:= .T.
	Local lIncProd		:= .T.
	Local lExcProd		:= .T.
	
	//valido se as grids de alteracao estao corretas
	if Empty(oModelUH2:GetValue("UH2_PLANNO"))
		
		//alteracao de produtos
		lAlt := VerAlt(oObj,"UH3DETAIL","UH3_PRODUT","UH3_QUANT","UH6DETAIL","UH6_PRODUT","UH6_QUANT","Alteração de Produtos")
		
	else
		
		//alteracao de produtos
		lAlt := VerAlt(oObj,"UH4DETAIL","UH4_PRODUT","UH4_QUANT","UH6DETAIL","UH6_PRODUT","UH6_QUANT","Alteração de Produtos")
		
	endif
	
	if lAlt
	
		//caso nao tenha alteracao de plano, tenho que verificar se houve inclusao ou exclusao de produtos e servicos
		if Empty(oModelUH2:GetValue("UH2_PLANNO"))
			
			//valido se houve inclusao de produtos
			lIncProd := VerGrid(oObj,"UH5DETAIL","UH5_PRODUT")
			
				
			//valido se houve exclusao de produtos
			lExcProd := VerGrid(oObj,"UH7DETAIL","UH7_PRODUT")
				
			
			if !lIncProd .And. !lExcProd
				Help(,,'Help',,"Não será possivel salvar a personalização do contrato, pois não houve modificação, favor verifique os dados digitados!",1,0)	
			else
				lRet := .T.
			endif
		
		else
			lRet := .T.
		endif
	
	endif
	

Return(lRet)

/*/{Protheus.doc} VerAlt
Verifico a consistencia das
grids de alteracao, verifico
se houve alteracao de quantidade 
do produto ou servico
@author Raphael Martins 
@since 23/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function VerAlt(oObj,cModelOrig,cProdOrig,cQuantOrig,cModelAlt,cProdAlt,cQuantAlt,cGrid)

	Local oModelOrig	:= oObj:GetModel(cModelOrig)
	Local oModelAlt		:= oObj:GetModel(cModelAlt)
	Local nX			:= 0 
	Local nJ			:= 0 
	Local lRet			:= .T.
	
	For nX := 1 To oModelAlt:Length()
		
		oModelAlt:GoLine(nX)
		
		if !oModelAlt:IsDeleted() 
		
			For nJ := 1 To oModelOrig:Length()
				
				oModelOrig:GoLine(nJ)
							
				if !oModelOrig:IsDeleted() 
							
					if oModelOrig:GetValue(cProdOrig) == oModelAlt:GetValue(cProdAlt) 
								
						if oModelOrig:GetValue(cQuantOrig) == oModelAlt:GetValue(cQuantAlt)
										
							lRet := .F.
							
							Help(,,'Help',,cGrid + Chr(13) + Chr(10) +;
								"O Produto: " + Alltrim(oModelAlt:GetValue(cProdAlt)) +;
								 " está contido na Grid de Alteração, porém sua quantidade não foi modificada!",1,0)	
										
							Exit
										
						endif
								
					endif
								
				endif
							
			Next nJ 
		
		endif
		
	Next nX
	
Return(lRet)

/*/{Protheus.doc} VerAlt
Funcao para verificar se a grid
possui item valido
@author Raphael Martins 
@since 23/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function VerGrid(oObj,cModelGrid,cCampoProd)

Local oModelGrid	:= oObj:GetModel(cModelGrid)
Local nX			:= 0 
Local lRet			:= .F.
Local nJ			:= 1

	For nJ := 1 To oModelGrid:Length()
		
		oModelGrid:GoLine(nX)
					
		if !oModelGrid:IsDeleted() .And. !Empty(oModelGrid:GetValue(cCampoProd)) 
			
			lRet := .T.
			Exit
			
		endif
		
	Next nX
	
Return(lRet)

/*/{Protheus.doc} ConfirmaPer
Funcao para Confirmar a personalizacao
do Contrato.
Realiza a Alteracao do Contrato
e das parcelas no Financeiro
@author Raphael Martins 
@since 23/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

Static Function ConfirmaPer(oSay,oObj)

Local oModelUH2			:= oObj:GetModel("UH2MASTER")
Local aProdutos			:= {}
Local aCamposProd		:= {}
Local aContratos		:= {}
Local lRet				:= .T.
Local cDiaVenc			:= ""
Local lUsaPrimVencto	:= SuperGetMv("MV_XPRIMVC",.F.,.F.)


if Empty(oModelUH2:GetValue("UH2_PLANNO"))
	
	aCamposProd := {"UH3_TIPO","UH3_PRODUT","UH3_DESCRI","UH3_VLRUNI","UH3_QUANT","UH3_VLRTOT","UH3_SALDO","UH3_CTRSLD"}
				
	aProdutos	:= aClone(RetProdCont(oObj,"UH3DETAIL",aCamposProd))
	
else
	
	aCamposGrid := {"UH4_TIPO","UH4_PRODUT","UH4_DESCRI","UH4_VLRUNI","UH4_QUANT","UH4_VLRTOT","UH4_SALDO","UH4_CTRSLD"}
				
	aProdutos	:= aClone(RetProdCont(oObj,"UH4DETAIL",aCamposGrid))
	
endif

Begin Transaction 

	if Len(aProdutos) > 0 
		
		aAdd( aContratos, {'UF2_CODIGO'		, UF2->UF2_CODIGO } ) 
		aAdd( aContratos, {'UF2_VALOR'      , oResumoTotal:nNewValor } ) 
		aAdd( aContratos, {'UF2_DESCON'     , 0 } )
		aAdd( aContratos, {'UF2_VLADIC'     , 0 } ) 
		
		
		//verfico se houve alteracao de plano
		if !Empty(oModelUH2:GetValue("UH2_PLANNO"))
			
			aAdd( aContratos, {'UF2_PLANO'      , oModelUH2:GetValue("UH2_PLANNO") } ) 
			
		endif
		
		//Deleto os produtos e servicos existentes atualmente no contrato
		DelProdServ(UF2->UF2_CODIGO)
		
		
		//execauto de alteracao de contratos
		if !U_RFUNE002(aContratos,,,4,aProdutos)
			
			lRet := .F.
			MostraErro()
			
			//cancelo a transacao 
			DisarmTransaction()
			
		elseif UF2->UF2_STATUS == 'A'
			
			cDiaVenc := if(lUsaPrimVencto,SubStr(DTOC(UF2->UF2_PRIMVE),1,2),UF2->DIAVEN)
			
			//reprocesso parcelas do contrato 
			AlterParcelas(oSay,oObj,UF2->UF2_CODIGO,UF2->UF2_QTPARC, cDiaVenc,UF2->UF2_NATURE,UF2->UF2_CLIENT,UF2->UF2_LOJA)
			
		endif
		
	endif

End Transaction 

Return(lRet)

/*/{Protheus.doc} RetProdCont
Funcao para retornar os produtos
que serao salvos no contratos
@author Raphael Martins 
@since 23/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function RetProdCont(oObj,cModelGrid,aCamposGrid)

	Local oModelGrid	:= oObj:GetModel(cModelGrid)
	Local oModelUH5		:= oObj:GetModel("UH5DETAIL")
	Local oModelUH6		:= oObj:GetModel("UH6DETAIL")
	Local oModelUH7		:= oObj:GetModel("UH7DETAIL")
	Local nX			:= 0
	Local nJ			:= 0 
	Local nY			:= 0 
	Local nItemUF3		:= 0
	Local aDadosProd	:= {}
	Local aItem			:= {}
	Local lExcluido		:= .F.
	 
	
	//verifico se houve alteracao do item
	For nX := 1 To oModelGrid:Length()
		
		oModelGrid:GoLine(nX)
		aItem := {}
					
		if !oModelGrid:IsDeleted() .And. !Empty(oModelGrid:GetValue(aCamposGrid[2])) 
			
			//verifico se o item esta na tabela de exclusao 
			For nY := 1 To oModelUH7:Length()
			
				oModelUH7:GoLine(nY)
				
				if !oModelUH7:IsDeleted() .And. !Empty(oModelUH7:GetValue("UH7_PRODUT"))
					
					if oModelUH7:GetValue("UH7_PRODUT") == oModelGrid:GetValue(aCamposGrid[2])
						
						lExcluido := .T.
					
					endif
					
						
				endif
				
			Next nY
		
			
			if !lExcluido
			
				//verifico se o produto foi alterado, caso sim, sera gravado as informacoes da alteracao
				For nJ := 1 To oModelUH6:Length()
				
					oModelUH6:GoLine(nJ)
					
					aItem := {}
					
					if !oModelUH6:IsDeleted() .And. !Empty(oModelUH6:GetValue("UH6_PRODUT"))
						
						if oModelGrid:GetValue(aCamposGrid[2]) == oModelUH6:GetValue("UH6_PRODUT") 
							
							
							nItemUF3++ 
							
							aAdd(aItem, {"UF3_ITEM"		,StrZero(nItemUF3,TamSx3("UF3_ITEM")[1])	} )
							aAdd(aItem, {"UF3_TIPO"		,oModelUH6:GetValue("UH6_TIPO") 	} )			
							aAdd(aItem, {"UF3_PROD"		,oModelUH6:GetValue("UH6_PRODUT") 	} )
							aAdd(aItem, {"UF3_DESC"		,oModelUH6:GetValue("UH6_DESCRI")	} )
							aAdd(aItem, {"UF3_VLRUNI"	,oModelUH6:GetValue("UH6_VLRUNI") 	} )
							aAdd(aItem, {"UF3_QUANT"	,oModelUH6:GetValue("UH6_QUANT") 	} )
							aAdd(aItem, {"UF3_VLRTOT"	,oModelUH6:GetValue("UH6_VLRTOT") 	} )
							aAdd(aItem, {"UF3_SALDO"	,oModelUH6:GetValue("UH6_SALDO") 	} )
							aAdd(aItem, {"UF3_CTRSLD"	,oModelUH6:GetValue("UH6_CTRSLD") 	} )
							
							Aadd(aDadosProd,aItem)
							
							Exit 
							
						endif
						
					endif
					
				Next nJ
				
				//senao houve alteracao para o item, adiciono o original
				if Len(aItem) == 0
					
					nItemUF3++ 
					
					aItem := {}
					
					aAdd(aItem, {"UF3_ITEM"		,StrZero(nItemUF3,TamSx3("UF3_ITEM")[1])	} )
					aAdd(aItem, {"UF3_TIPO"		,oModelGrid:GetValue(aCamposGrid[1]) 		} )			
					aAdd(aItem, {"UF3_PROD"		,oModelGrid:GetValue(aCamposGrid[2]) 		} )
					aAdd(aItem, {"UF3_DESC"		,oModelGrid:GetValue(aCamposGrid[3]) 		} )
					aAdd(aItem, {"UF3_VLRUNI"	,oModelGrid:GetValue(aCamposGrid[4]) 		} )
					aAdd(aItem, {"UF3_QUANT"	,oModelGrid:GetValue(aCamposGrid[5]) 		} )
					aAdd(aItem, {"UF3_VLRTOT"	,oModelGrid:GetValue(aCamposGrid[6]) 		} )
					aAdd(aItem, {"UF3_SALDO"	,oModelGrid:GetValue(aCamposGrid[7]) 		} )
					aAdd(aItem, {"UF3_CTRSLD"	,oModelGrid:GetValue(aCamposGrid[8]) 		} )
							
					Aadd(aDadosProd,aItem)
					
				endif
			
			endif
				
		endif
		
	Next nX
	
	//verifico se houve inclusao de produtos 
	For nX := 1 To oModelUH5:Length()
		
		aItem := {}
			
		oModelUH5:GoLine(nX)
				
		if !oModelUH5:IsDeleted() .And. !Empty(oModelUH5:GetValue("UH5_PRODUT"))
			
			nItemUF3++
			
			
			aAdd(aItem, {"UF3_ITEM"		,StrZero(nItemUF3,TamSx3("UF3_ITEM")[1])	} )
			aAdd(aItem, {"UF3_TIPO"		,oModelUH5:GetValue("UH5_TIPO") 			} )			
			aAdd(aItem, {"UF3_PROD"		,oModelUH5:GetValue("UH5_PRODUT") 			} )
			aAdd(aItem, {"UF3_DESC"		,oModelUH5:GetValue("UH5_DESCRI") 			} )
			aAdd(aItem, {"UF3_VLRUNI"	,oModelUH5:GetValue("UH5_VLRUNI") 			} )
			aAdd(aItem, {"UF3_QUANT"	,oModelUH5:GetValue("UH5_QUANT") 			} )
			aAdd(aItem, {"UF3_VLRTOT"	,oModelUH5:GetValue("UH5_VLRTOT") 			} )
			aAdd(aItem, {"UF3_SALDO"	,oModelUH5:GetValue("UH5_SALDO") 			} )
			aAdd(aItem, {"UF3_CTRSLD"	,oModelUH5:GetValue("UH5_CTRSLD") 			} )
				
			Aadd(aDadosProd,aItem)
								
		endif 
		
	Next nX
	
Return(aDadosProd)


/*/{Protheus.doc} DelProdServ
Funcao para deletar os itens
existentes no contrato
@author Raphael Martins 
@since 23/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function DelProdServ(cContrato)

Local aArea		:= GetArea()
Local aAreaUF3	:= UF3->(GetArea())

UF3->(DbSetOrder(1)) //UF3_FILIAL + UF3_CODIGO + UF3_ITEM

//deleto os produtos do contrato
if UF3->(DbSeek(xFilial("UF3")+cContrato))
	
	While UF3->(!Eof()) .And. UF3->UF3_FILIAL == xFilial("UF3") .And. UF3->UF3_CODIGO == cContrato
	
		RecLock("UF3",.F.)
		
		UF3->(DbDelete())
		
		UF3->(MsUnlock())
		
		UF3->(DbSkip())
		
	EndDo
	
endif


RestArea(aArea)
RestArea(aAreaUF3)


Return()


/*/{Protheus.doc} AlterParcelas
Funcao para alterar as parcelas
do contrato personalizado
existentes no contrato
@author Raphael Martins 
@since 23/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function AlterParcelas(oSay,oObj,cContrato,nQtdParc,cDiaVenc,cNat,cCliente,cLoja)

	Local aArea			:= GetArea()
	Local aAreaUF2		:= UF2->(GetArea())
	Local aAreaSE1		:= SE1->(GetArea())

	Local aFin040		:= {}
	Local aRet			:= {}
	Local lRet			:= .T.
	Local cQry 			:= ""
	Local cPrefixo 		:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
	Local cTipo			:= SuperGetMv("MV_XTIPFUN",.F.,"AT")
	Local nVlrParc		:= 0 
	Local nParcGer		:= 0
	Local nQtdGeradas	:= 0 
	Local nVlrParc		:= 0 
	Local nPercJuros	:= GetMV("MV_TXPER")
	Local nX			:= 1
	
	Private	lMsErroAuto := .F.
	
	//retiro os titulos da cobranca
	lRet := VldCobranca(xFilial("SE1"),cContrato)
	
	
	if lRet
		
		//verifico a quantidade de parcelas do plano, e vejo se a quantidade a ser gerada e superior ao restante do plano
		nQtdRestCon := ParcelCont(cContrato,oObj)
		
		//deleto as parcelas em aberto do contrato
		FWMsgRun(,{|oSay| aRet := DelParcRest(cContrato)},'Aguarde...','Excluindo Parcelas do Contrato') 
		
		nParcGer := aRet[1]
		lRet 	 := aRet[2]
		
	endif
	
	if lRet
		
		//verifico a quantidade de parcelas a serem geradas.
		//Sera a quantidade que estava em aberto 
		//ou 12 parcelas, neste caso devera alterar a data do proximo reajuste 
		
		if nQtdRestCon > 12
			
			nParcGer := if(nParcGer==0,12,nParcGer)
			
		else
			
			nParcGer := nQtdRestCon
		
		endif
				
		//defino data de vencimento das proximas parcelas 
		
		dDataAux 	:= CToD("01/" + StrZero(Month(dDatabase),2) + "/" + StrZero(Year(dDatabase),4))
		
		//caso a parcela do mes nao esteja vencida, o vencimento da proxima sera dentro do proprio mes
		if Val(cDiaVenc) < Day(dDatabase)
		
			dDataAux	:= MonthSum(dDataAux,1) //Soma um mês na data auxiliar 
		
		endif
		
		//Se o dia de vencimento for maior que o último dia do mês considera o último dia do mês
		If Val(cDiaVenc) > Day(LastDate(dDataAux))
			dVencto := CToD(StrZero(Day(LastDate(dDataAux)),2) + "/" + StrZero(Month(dDataAux),2) + "/" + StrZero(Year(dDataAux),4))  
		Else
			dVencto := CToD(cDiaVenc + "/" + StrZero(Month(dDataAux),2) + "/" + StrZero(Year(dDataAux),4))   	
		Endif	

		//retorno a ultima parcela gerada do contrato
		cParc := RetLstParc(cContrato)
		
		For nX := 1 To nParcGer
			
			oSay:cCaption := ("Gerando parcelas da nova negociação: Parcela: " + cParc + " >>>")
			ProcessMessages()
			
			nVlrParc := oResumoTotal:nNewValor + UF2->UF2_VLADAG - UF2->UF2_DESCON
					
			AAdd(aFin040, {"E1_FILIAL"	, xFilial("SE1")					,Nil } )
			AAdd(aFin040, {"E1_PREFIXO"	, cPrefixo         					,Nil } ) 
			AAdd(aFin040, {"E1_NUM"		, cContrato		 	   				,Nil } ) 
			AAdd(aFin040, {"E1_PARCELA"	, cParc								,Nil } )
			AAdd(aFin040, {"E1_TIPO"	, cTipo		 						,Nil } )
			AAdd(aFin040, {"E1_NATUREZ"	, UF2->UF2_NATURE					,Nil } )
			AAdd(aFin040, {"E1_CLIENTE"	, cCliente							,Nil } )
			AAdd(aFin040, {"E1_LOJA"	, cLoja								,Nil } )
			AAdd(aFin040, {"E1_EMISSAO"	, dDataBase							,Nil } )
			AAdd(aFin040, {"E1_VENCTO"	, dVencto							,Nil } )
			AAdd(aFin040, {"E1_VENCREA"	, DataValida(dVencto)				,Nil } )
			AAdd(aFin040, {"E1_VALOR"	, nVlrParc							,Nil } )
			AAdd(aFin040, {"E1_PORCJUR"	, nPercJuros						,Nil } )
			AAdd(aFin040, {"E1_XCTRFUN"	, cContrato							,Nil } )
			AAdd(aFin040, {"E1_XFORPG"	, UF2->UF2_FORPG					,Nil } )
			
				
			MSExecAuto({|x,y| FINA040(x,y)},aFin040,3)
		
			If lMsErroAuto
				MostraErro()                    
				DisarmTransaction()
				lRet := .F.
				Exit
			EndIf
			
			cParc	:= StrZero(Val(cParc) + 1,TamSX3("E1_PARCELA")[1])
			
			dVencto := MonthSum(dVencto,1)
			
		Next nX 
		
		//o proximo reajuste sera de acordo com a ultima parcela gerada da renegociacao
		ProcPrxReaj(cContrato,dVencto)
		
	endif
			

RestArea(aArea)
RestArea(aAreaUF2)
RestArea(aAreaSE1)

Return(lRet)

/*/{Protheus.doc} DelParcRest
Funcao para deletar as parcelas 
atuais do contrato 
@author Raphael Martins 
@since 23/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function DelParcRest(cContrato)

	Local aArea				:= GetArea()
	Local aAreaUF2			:= UF2->(GetArea())
	Local aAreaSE1			:= SE1->(GetArea())
	Local cQry				:= ""
	Local cPrefixo 			:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
	Local cTipo				:= SuperGetMv("MV_XTIPFUN",.F.,"AT")
	Local cTipoRJ			:= SuperGetMv("MV_XTRJFUN",.F.,"RJ") 
	Local nRet				:= 0
	Local lRet				:= .T.
	
	
	////////////////////////////////////////////
	////// CONSULTO AS PARCELAS RESTANTES //////
	///////////////////////////////////////////
		
	cQry := " SELECT  " 
	cQry += " E1_PREFIXO PREFIXO, " 
	cQry += " E1_NUM NUMERO, " 
	cQry += " E1_PARCELA PARCELA, " 
	cQry += " E1_TIPO TIPO, " 
	cQry += " R_E_C_N_O_ REGISTRO " 
	cQry += " FROM "  
	cQry += " " + RetSQLName("SE1") + " TITULOS " 
	cQry += " WHERE " 
	cQry += " 	TITULOS.D_E_L_E_T_ = ' '  " 
	cQry += " 	AND TITULOS.E1_FILIAL = '" + xFilial("SE1") + "' " 
	cQry += " 	AND TITULOS.E1_PREFIXO = '" + cPrefixo + "' " 
	cQry += " 	AND TITULOS.E1_XCTRFUN = '" + cContrato + "' " 
	cQry += " 	AND TITULOS.E1_TIPO IN ('" + cTipo + "', '" + cTipoRJ + "') " 
	cQry += " 	AND TITULOS.E1_BAIXA = ' ' " 	
	
	If Select("QRYREST") > 0 
		QRYREST->(DbCloseArea())
	endif
	
	cQry := ChangeQuery(cQry)
	
	TcQuery cQry NEW Alias "QRYREST"

	While QRYREST->(!Eof())
		
		nRet++ 
		
		ExcBord(QRYREST->REGISTRO) 
		
		if !ExcTit(QRYREST->REGISTRO)
			
			lRet := .F.
			Exit
			
		endif
		
		QRYREST->(DbSkip())
	EndDo
	
	RestArea(aArea)
	RestArea(aAreaUF2)
	RestArea(aAreaSE1)

Return({nRet,lRet})

/*/{Protheus.doc} VldCobranca
Funcao para validar se o contrato
possui titulos em cobranca
@author Raphael Martins 
@since 23/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

Static Function VldCobranca(cFiltTit,cContrato)


	Local lRet		:= .T.
	Local aArea		:= GetArea()
	Local aAreaSE1	:= SE1->( GetArea() )
	Local aAreaSK1	:= SK1->( GetArea() )
	Local cQry 		:= "" 
	
	///////////////////////////////////////////////////////////////
	///// CONSULTO SE O CONTRATO POSSUI TITULOS EM COBRANCA	//////
	//////////////////////////////////////////////////////////////
	
	cQry 	:= " SELECT "  
	cQry 	+= " K1_FILIAL FILIAL, "
	cQry 	+= " K1_PREFIXO PREFIXO, "
	cQry 	+= " K1_NUM NUMERO, "
	cQry 	+= " K1_PARCELA PARCELA, "
	cQry 	+= " K1_TIPO TIPO, "
	cQry 	+= " K1_FILORIG FILORIG " 
	cQry	+= " FROM "
	cQry	+= + RetSQLName("SK1") + " COBRANCA 
	cQry 	+= " INNER JOIN " 
	cQry 	+= + RetSQLName("SE1") + " TITULO  
	cQry 	+= " ON "
	cQry 	+= " COBRANCA.K1_PREFIXO = TITULO.E1_PREFIXO "
	cQry	+= " AND COBRANCA.K1_NUM 	= TITULO.E1_NUM "
	cQry	+= " AND COBRANCA.K1_PARCELA = TITULO.E1_PARCELA "
	cQry	+= " AND TITULO.E1_XCTRFUN 	= '" + cContrato + "' "
	cQry	+= " AND TITULO.E1_FILIAL 	= '" + cFiltTit + "' "
	cQry	+= " AND TITULO.D_E_L_E_T_ 	= ' ' " 
	cQry	+= " WHERE " 
	cQry	+= "	COBRANCA.D_E_L_E_T_ = ' '"	
	cQry	+= " 	AND COBRANCA.K1_FILORIG = '" + cFiltTit + "' "
	cQry 	+= " 	AND COBRANCA.K1_OPERAD	<> 'XXXXXX' " //XXXXXX Titulo marcado como excecao na cobranca
	
	
	If Select("QRYCOB") > 0
		QRYCOB->(DbCloseArea())
	Endif
		
	cQry := ChangeQuery(cQry)
	TcQuery cQry NEW Alias "QRYCOB"
	
	QRYCOB->( DbGotop() )
	
	//valido se possui cobranca para o contrato
	if QRYCOB->(!Eof())
			
		SK1->(DbSetOrder(1)) //K1_FILIAL+K1_PREFIXO+K1_NUM+K1_PARCELA+K1_TIPO+K1_FILORIG
		
		While QRYCOB->(!Eof())
		
			//marco o titulo como excecao de cobranca, assim o mesmo estara apto para exclusao
			if SK1->(DbSeek(QRYCOB->FILIAL+QRYCOB->PREFIXO+QRYCOB->NUMERO+QRYCOB->PARCELA+QRYCOB->TIPO+QRYCOB->FILORIG))
		
				RecLock("SK1",.F.)
				SK1->K1_OPERAD := 'XXXXXX'
				SK1->(MsUnlock())
			
			endif
			
		
			QRYCOB->(DbSkip())
		
		EndDo
		
	endif
	
	
	RestArea(aArea) 
	RestArea(aAreaSE1) 
	RestArea(aAreaSK1) 

Return(lRet)



/*{Protheus.doc}
Funcao para Excluir Titulos 
existentes do contrato
@author Raphael Martins 
@since 23/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function ExcTit(nRecSE1)


	Local lRet 			:= .T.
	Local aFin040		:= {}
	Local aArea			:= GetArea()
	Local aAreaSE1		:= SE1->( GetArea() )
		
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	
	DbSelectArea("SE1")
	SE1->(DbGoTo(nRecSE1))
		
	AAdd(aFin040, {"E1_FILIAL"  , SE1->E1_FILIAL  	,Nil})
	AAdd(aFin040, {"E1_PREFIXO" , SE1->E1_PREFIXO 	,Nil}) 
	AAdd(aFin040, {"E1_NUM"     , SE1->E1_NUM	   	,Nil})
	AAdd(aFin040, {"E1_PARCELA" , SE1->E1_PARCELA	,Nil})
	AAdd(aFin040, {"E1_TIPO"    , SE1->E1_TIPO  	,Nil})
	
	MSExecAuto({|x,y| Fina040(x,y)},aFin040,5)
		
	If lMsErroAuto
		MostraErro()                    
		DisarmTransaction()
		lRet := .F.
	EndIf
	
	RestArea(aArea)
	RestArea(aAreaSE1)

Return lRet



/*{Protheus.doc} 
Funcao para Excluir Borderos 
existentes do contrato
@author Raphael Martins 
@since 23/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function ExcBord(nRecSE1)

	Local aArea		:= GetArea()
	Local aAreaSE1	:= SE1->( GetArea() )
	Local aAreaSEA	:= SEA->( GetArea() )
	
	DbSelectArea("SE1")
	SE1->(DbGoTo(nRecSE1))
	
	DbSelectArea("SEA")
	SEA->(DbSetOrder(1)) //EA_FILIAL+EA_NUMBOR+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA
	
	//Se houver borderô associado, exclui
	If SEA->(DbSeek(xFilial("SEA")+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
	
		RecLock("SEA")
		SEA->(DbDelete())
		SEA->(MsUnlock())
	 Endif
	
	SE1->(DbGoTo(nRecSE1))
	RecLock("SE1")
	SE1->E1_SITUACA	:= "0"
	SE1->E1_OCORREN	:= ""
	SE1->E1_NUMBCO	:= ""
	SE1->E1_NUMBOR	:= ""
	SE1->E1_DATABOR	:= CToD("")
	SE1->(MsUnLock())
	
	RestArea(aArea)
	RestArea(aAreaSE1)
	RestArea(aAreaSEA)

Return


/*/{Protheus.doc} RetLstParc
Retorno a ultima parcela do contratos
@author Raphael Martins 
@since 23/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function RetLstParc(cContrato,cTipo)

	Local cQry 			:= ""
	Local cProxParc		:= ""
	Local cPref 		:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
	Local cTipoRJ		:= SuperGetMv("MV_XTRJFUN",.F.,"RJ") // tipo do título
	
	Default cTipo		:= SuperGetMv("MV_XTIPOCT",.F.,"AT")

	
	cQry := " SELECT " 
	cQry += " MAX(E1_PARCELA) MAX_PARC " 
	cQry += " FROM  "
	cQry += " " + RetSQLName("SE1") + " TITULOS "
	cQry += " WHERE "
	cQry += " 	TITULOS.D_E_L_E_T_ = ' ' " 
	cQry += " 	AND TITULOS.E1_FILIAL = '" + xFilial("SE1") + "' "
	cQry += " 	AND TITULOS.E1_PREFIXO = '" + cPref + "' "
	cQry += " 	AND TITULOS.E1_XCTRFUN = '" + cContrato + "' "
	cQry += " 	AND TITULOS.E1_TIPO IN ('" + cTipo + "','" + cTipoRJ + "') "
	
	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)
	
	if Select("QRY") > 0 
		
		QRY->(DbCloseArea())
		
	endif
	
	// crio o alias temporario
	TcQuery cQry New Alias "QRY"
	
	//proximo item da tabela de historico de enderecamento
	cProxParc := StrZero(Val(QRY->MAX_PARC) + 1,TamSX3("E1_PARCELA")[1])

Return(cProxParc)

/*/{Protheus.doc} ParcelCont
Retorna a quantidade de parcelas
geradas do contrato
@author Raphael Martins 
@since 23/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function ParcelCont(cContrato,oObj)

Local aArea			:= GetArea()
Local aAreaUF2		:= UF2->(Getarea())
Local cPulaLinha	:= chr(13)+chr(10)  
Local cQry 			:= ""
Local lFinaliza		:= .F.
Local nQtdParc		:= 0
Local oModelUH2		:= oObj:GetModel("UH2MASTER")
Local cPlanoNew		:= oModelUH2:GetValue("UH2_PLANNO")
Local cPrefixo 		:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
	

// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

cQry += " SELECT " 															+ cPulaLinha
cQry += " COUNT(*) AS PARCELAS_GERADAS, " 									+ cPulaLinha
cQry += " SE1.E1_XCTRFUN AS CODIGO_CONTRATO " 								+ cPulaLinha
cQry += " FROM " 															+ cPulaLinha
cQry += " " + RetSqlName("SE1") + " SE1 " 									+ cPulaLinha
cQry += " WHERE " 															+ cPulaLinha
cQry += " SE1.D_E_L_E_T_ <> '*' " 											+ cPulaLinha
cQry += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "					+ cPulaLinha
cQry += " AND SE1.E1_PREFIXO = '" + cPrefixo + "' "							+ cPulaLinha
cQry += " AND SE1.E1_XCTRFUN = '" + cContrato + "'  "						+ cPulaLinha
cQry += " GROUP BY SE1.E1_XCTRFUN " 										+ cPulaLinha	

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

// verifico quantas parcelas já foram geradas para este contrato
if QRY->(!Eof())
	nQtdParc := QRY->PARCELAS_GERADAS
endif

if !Empty(cPlanoNew)
	
	nParcPlano := RetField("UF0",1,xFilial("UF0")+cPlanoNew,"UF0_QTDPAR")

else
	
	nParcPlano := UF2->UF2_QTPARC
	
endif

//quantidade de parcelas restantes do contrato
nQtdParc := nParcPlano - nQtdParc

RestArea(aArea)
RestArea(aAreaUF2)

Return(nQtdParc)

/*/{Protheus.doc} ProcPrxReaj
Altera o historico de reajuste 
para a ultima parcela alterada
@author Raphael Martins 
@since 23/08/2018
@version P12
@param Nao recebe parametros
@return nulo
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

