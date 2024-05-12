#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'
#include 'topconn.ch'

/*/{Protheus.doc} RCPGA011
Rotina de geração de comissão de contrato de cemitério. 

@author Pablo Cavalcante
@since 11/03/2016
@version undefined
@param cU00_CODIGO, characters, Código do Contrato
@type function
/*/

User Function RCPGA011(cU00_CODIGO,cLog,lJob)
Local aArea		:= GetArea()
Local aAreaU00 	:= U00->(GetArea())
Local aAreaU18	:= U18->(GetArea())
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSA3	:= SA3->(GetArea())
Local aAreaSE3	:= SE3->(GetArea())

Local cPulaLinha:= chr(13)+chr(10)
Local aAuto 	:= {} //array do execauto
Local nValor 	:= U00->U00_VALOR //valor total do contrato "a vista"
//Local cCondPg 	:= U00->U00_CONDPG //condição de pagamento do contrato
Local nParcel 	:= 0 //numero de parcelas do contrato
Local nPComis	:= 0 //numero de parcelas de comissão
Local nVlrCtr 	:= 0 //valor total do contrato
Local aPgto   	:= {} //array de parcelas de pagamento
Local cPrefCtr	:= SuperGetMv("MV_XPREFCT",.F.,"CTR")  //prefixo do titulo de contrato
Local cTipoCtr	:= SuperGetMv("MV_XTIPOCT",.F.,"AT")   //tipo do titulo de contrato
Local cTipoEnt	:= SuperGetMv("MV_XTIPOEN",.F.,"ENT")  //tipo de titulo de entrada
Local cTipoE3	:= ""
Local nTotComis := 0 //valor total da comissao
Local nComissao := 0 //valor da comissão da parcela
Local lRet 		:= .T. //controle de transação
Local lContinua := .T.
Local lEntrada	:= .F. //controle de parcela de entrada

Private lMsErroAuto := .F.

Default cU00_CODIGO := U00->U00_CODIGO
Default cLog		:= ""
Default lJob		:= .F.

	U00->(dbSetOrder(1)) //U00_FILIAL+U00_CODIGO
	If U00->(dbSeek(xFilial("U00")+cU00_CODIGO)) .and. !Empty(U00->U00_VENDED)
		
		dE3_EMISSAO := Iif(Empty(U00->U00_DTATIV), dDataBase, U00->U00_DTATIV)
		nVlrCtr 	:= U00->U00_VALOR // -> Valor Total do Contrato (valor a vista, no ato da criacao do contrato)
		
		//aPgto   := Condicao(nValor,cCondPg,,dE3_EMISSAO) // Total para o calculo, cod. cond.pgto,data base
		//nParcel := Len(aPgto)
		//nParcel := U00->U00_QTDPAR 
	
		cQry := "select SUM(SE1.E1_VALOR + SE1.E1_SDACRES - SE1.E1_SDDECRE) AS VLRCTR," // -> Valor Total do Contrato, considerando acrescimo e decrescimo
		cQry += " COUNT(*) AS QTDPAR," //-> Quantidade de Parcelas do Contrato
		cQry += " SE1.E1_TIPO TIPO"
		cQry += " from " + RetSqlName("SE1") + " SE1"
		cQry += " where SE1.D_E_L_E_T_ <> '*'"
		cQry += " and SE1.E1_FILIAL = '" + xFilial('SE1') + "'"
		cQry += " and SE1.E1_PREFIXO = '" + cPrefCtr + "'"
		cQry += " and SE1.E1_TIPO IN ('" + cTipoCtr + "','" + cTipoEnt + "') "
		cQry += " and SE1.E1_NUM = '" + U00->U00_CODIGO + "'"
		cQry += " group by SE1.E1_TIPO "
		
		If Select("QAUX") > 0
			QAUX->(dbCloseArea())
		EndIf
		
		cQry := Changequery(cQry)
		TCQUERY cQry NEW ALIAS "QAUX"
		
		If QAUX->(!Eof())
			
			//faco a varredura nos titulos para verificar se possivel entrada, caso possua, a primeira parcela de comissao deve ser diferenciada
			While QAUX->(!Eof())
				
				nParcel += QAUX->QTDPAR
				
				//verifico se existe parcela de entrada 
				If Alltrim( QAUX->TIPO ) == Alltrim( cTipoEnt )
					lEntrada := .T.
				endif
				 
				QAUX->(DbSkip())
			EndDo 
		
		Else
		 	lRet := .F.
		 	If !Empty(cLog)
		 		cLog += cPulaLinha
		 		cLog += "   >> NAO FORAM ENCONTRADOS TITULOS PARA O CONTRATO..." + cPulaLinha
			Else
				If !lJob
					MsgInfo("Não foram encontrados títulos para o contrato.","Atenção")
				EndIf
			EndIf
		EndIf
		
		QAUX->(dbCloseArea())
		
		If lContinua .And. nVlrCtr > 0 
		 
			//Posiciona no Vendedor
			SA3->(dbSetOrder(1)) //A3_FILIAL+A3_COD
			SA3->(dbSeek(xFilial("SA3")+U00->U00_VENDED))
			
			//Posiciona no Cliente/Loja
			SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
			SA1->(dbSeek(xFilial("SA1")+U00->U00_CLIENT+U00->U00_LOJA))
			
			//Posiciona no Cliclo e Pgto de Comissão
			U18->(dbSetOrder(1)) //U18_FILIAL+U18_CODIGO
			U18->(dbSeek(xFilial("U18")+SA3->A3_XCICLO))
			
			cQry := " select * "
			cQry += " from " + RetSqlName("U15") + " U15"
			cQry += " inner join " + RetSqlName("U16") + " U16"
			cQry += 	" on (U15_FILIAL = U16_FILIAL and U15_CODIGO = U16_CATEGO and U16.D_E_L_E_T_ <> '*')"
			cQry += " inner join " + RetSqlName("U17") + " U17"
			cQry += 	" on (U15_FILIAL = U17_FILIAL and U15_CODIGO = U17_CATEGO and U16_CODIGO = U17_CONDIC and U17.D_E_L_E_T_ <> '*')"
			cQry += " where U15.D_E_L_E_T_ <> '*'"
			cQry += " and U15.U15_FILIAL = '" + xFilial("U15") + "'"
			cQry += " and U15.U15_CODIGO = '" + SA3->A3_XCATEGO + "'"

			// verifico se o novo modelo esta ativo com os campos
			If U16->( FieldPos("U16_FXINIC") ) > 0 .And. U16->( FieldPos("U16_FXFIM") ) > 0
				cQry += " and U16.U16_FXINIC <= '" + STRZERO(nParcel,tamsx3('U16_FXINIC')[1],0) + "'"
				cQry += " and U16.U16_FXFIM >= '" + STRZERO(nParcel,tamsx3('U16_FXFIM')[1],0) + "'"
			Else
				cQry += " and U16.U16_NPARDE <= '" + STRZERO(nParcel,tamsx3('U16_NPARDE')[1],0) + "'"
				cQry += " and U16.U16_NPARAT >= '" + STRZERO(nParcel,tamsx3('U16_NPARAT')[1],0) + "'"
			EndIf
			
			If Select("QAUX") > 0
				QAUX->(dbCloseArea())
			EndIf
			
			cQry := Changequery(cQry)
			TCQUERY cQry NEW ALIAS "QAUX"
			
			QAUX->(dbEval({|| nPComis++}))
			QAUX->(dbGoTop())
			
			cE3_PARCELA := PADL('0',tamsx3('E3_PARCELA')[1],'0')
			cE3_SEQ		:= PADL('0',tamsx3('E3_SEQ')[1],'0')
			
			If QAUX->(!Eof())
				If QAUX->U15_TPVAL == "P"
					nTotComis := nVlrCtr * (QAUX->U15_PERC/100)
				ElseIf QAUX->U15_TPVAL == "V"
					nTotComis := QAUX->U15_VAL
				EndIf
			Else
				lContinua := .F.
				If !Empty(cLog)
					cLog += cPulaLinha
					cLog += "   >> NAO FORAM ENCONTRADAS REGRAS DE CATEGORIA DE COMISSAO..." + cPulaLinha
				Else
					If !lJob
						MsgInfo("Não foram encontradas regras de categoria de comissão para o vendedor "+SA3->A3_COD+" - "+AllTrim(SA3->A3_NOME)+".","Atenção")
					EndIf
				EndIf
			EndIf 
			
			While QAUX->(!Eof()) .and. lContinua
			                                  
			
				cE3_PARCELA := Soma1(cE3_PARCELA)
				cE3_SEQ		:= Soma1(cE3_SEQ)
				
				dE3_DATA    := DaySum(dE3_EMISSAO, Val(QAUX->U17_PRAZO)) //data do possivel pagamento da comissão
				If Val(Day2Str(dE3_DATA)) <= U18->U18_DIAFEC 
					//valido se o dia de fechamento e maior que o ultimo dia do mes
					if Val(Day2Str( LastDay(dE3_DATA) ) ) >= U18->U18_DIAFEC
						dE3_VENCTO := CtoD(PADL(U18->U18_DIAFEC,2,"0")+"/"+Month2Str(dE3_DATA)+"/"+Year2Str(dE3_DATA))
					else
						dE3_VENCTO := CtoD(PADL(cValToChar(LastDay(dE3_DATA)),2,"0")+"/"+Month2Str(dE3_DATA)+"/"+Year2Str(dE3_DATA))
					endif
					
				Else
					
					//valido se o dia de fechamento e maior que o ultimo dia do mes
					if Val(Day2Str( LastDay(MonthSum(dE3_DATA,1)) ) ) >= U18->U18_DIAFEC
					
						dE3_VENCTO := CtoD(PADL(U18->U18_DIAFEC,2,"0")+"/"+Month2Str(MonthSum(dE3_DATA,1))+"/"+Year2Str(MonthSum(dE3_DATA,1))) 
					
					else
					
						dE3_VENCTO := CtoD(PADL(cValToChar(LastDay(MonthSum(dE3_DATA,1))),2,"0")+"/"+Month2Str(MonthSum(dE3_DATA,1))+"/"+Year2Str(MonthSum(dE3_DATA,1))) 
					
					endif
					    
					
				EndIf
				
				If QAUX->U15_TPVAL == "V"
					nComissao := QAUX->U17_VALOR
				Else
					nComissao := nTotComis * (QAUX->U17_PERC/100)
				EndIf
				
				If nComissao > 0
					
					aAuto := {}
					
					//verifico se gera parcela de entrada
					If lEntrada
						cTipoE3		:= cTipoEnt 
						lEntrada	:= .F.	
					else
						cTipoE3		:= cTipoCtr
					endif
					
					aAdd(aAuto, {"E3_VEND"		,SA3->A3_COD	,Nil}) //Vendedor
					aAdd(aAuto, {"E3_NUM"		,U00->U00_CODIGO,Nil}) //No. Titulo
					aAdd(aAuto, {"E3_EMISSAO"	,dE3_EMISSAO    ,Nil}) //Data  de  emissão do título referente ao pagamento de comissão.
					aAdd(aAuto, {"E3_SERIE"		,""				,Nil}) //Serie N.F.
					aAdd(aAuto, {"E3_CODCLI"	,SA1->A1_COD	,Nil}) //Cliente
					aAdd(aAuto, {"E3_LOJA"		,SA1->A1_LOJA	,Nil}) //Loja
					aAdd(aAuto, {"E3_BASE"		,nVlrCtr		,Nil}) //Valor base do título para cálculo de comissão.
					aAdd(aAuto, {"E3_PORC"		,(nComissao/nVlrCtr)*100, Nil}) //Percentual incidente ao valor do título para cálculo de comissão.
					aAdd(aAuto, {"E3_COMIS"		,nComissao		,Nil}) //Valor da Comissão
					aAdd(aAuto, {"E3_PREFIXO"	,cPrefCtr		,Nil}) //Prefixo
					aAdd(aAuto, {"E3_PARCELA"	,cE3_PARCELA	,Nil}) //Parcela
					aAdd(aAuto, {"E3_SEQ"		,cE3_SEQ		,Nil}) //Sequencia
					aAdd(aAuto, {"E3_TIPO"		,cTipoE3		,Nil}) //Tipo do título que originou a comissão.
					aAdd(aAuto, {"E3_PEDIDO"	,""				,Nil}) //No. Pedido
					aAdd(aAuto, {"E3_VENCTO"	,dE3_VENCTO		,Nil}) //Data de vencimento da comissão.
					aAdd(aAuto, {"E3_PROCCOM"	,""				,Nil}) //Proc. Com.
					aAdd(aAuto, {"E3_MOEDA"		,"01"			,Nil}) //Moeda
					aAdd(aAuto, {"E3_CCUSTO"	,""				,Nil}) //Centro de Custo
					aAdd(aAuto, {"E3_BAIEMI"	,"E"			,Nil}) //Comissao gerada: B - Pela Baixa ou E - Pela Emissão 
					aAdd(aAuto, {"E3_ORIGEM"	,"E"			,Nil}) //Origem da Comissao
					 	/*****************************************
						 	Origem do SE3
						 	"E" //Emissao Financeiro
						 	"B" //Baixa Financeiro
							"F" //Faturamento
							"D" //Devolucao de Venda
							"R" //Recalculo quando nao ha origem
							"L" //SigaLoja
							" " //Desconhecido
						*****************************************/
					aAdd(aAuto, {"E3_XCONTRA"	,U00->U00_CODIGO,Nil}) //Codigo do Contrato
					aAdd(aAuto, {"E3_XPARCON"	,Iif(nParcel>1, STRZERO(nParcel,tamsx3('E3_PARCELA')[1],0)+" X", "À VISTA"), Nil}) //Referencia do Parcelamento do Contrato
					aAdd(aAuto, {"E3_XPARCOM"	,cE3_PARCELA+"/"+STRZERO(nPComis,tamsx3('E3_PARCELA')[1],0), Nil}) //Referencia do Parcelamento da Comissao
					If SE3->(FieldPos("E3_XORIGEM"))>0
						aAdd(aAuto, {"E3_XORIGEM","C",Nil})
						/*****************************************
							Origem do SE3
							"C" //Cemiterio (Contrato)
							"F" //Funeraria (Contrato)
							"R" //Recebimento de Cobranca (Motoqueiro)
							"V" //Venda Avulsa (Pedido de Venda e/ou Venda Direta)
							"G" //Comissão de Gerente e Supervisor
						*****************************************/
					EndIf
					
					
					MSExecAuto({|x,y| Mata490(x,y)}, aAuto, 3) //Inclusão de Comissão
					
					If lMsErroAuto
						If !Empty(cLog)
							cLog += MostraErro("\temp") + cPulaLinha
						Else
							If !lJob
								MostraErro()
							EndIf
						EndIf
						//DisarmTransaction()
						lRet := .F.
						lContinua := .F.
					EndIf
					
				EndIf
				
				QAUX->(dbSkip())
			EndDo
			
			QAUX->(dbCloseArea())
		
		EndIf
	
	Else
		If !U00->(dbSeek(xFilial("U00")+cU00_CODIGO))
			If !Empty(cLog)
				cLog += cPulaLinha
				cLog += "   >> CONTRATO NÃO LOCALIZADO..." + cPulaLinha
			Else
				If !lJob
					MsgInfo("Contrato não localizado...","Atenção")
				EndIf
			EndIf
		ElseIf Empty(U00->U00_VENDED)
			If !Empty(cLog)
				cLog += cPulaLinha
				cLog += "   >> CONTRATO SEM VENDEDOR..." + cPulaLinha
			Else
				If !lJob
					MsgInfo("Contrato sem vendedor...","Atenção")
				EndIf
			EndIf
		EndIf
	EndIf
	
	RestArea(aAreaU00)
	RestArea(aAreaU18)
	RestArea(aAreaSA1)
	RestArea(aAreaSA3)
	RestArea(aAreaSE3)
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} RCPGB011
//Exclui as comissões do contrato.
@author Pablo Cavalcante
@since 15/03/2016
@version undefined
@param cU00_CODIGO, characters, Código do Contrato
@type function
/*/
User Function RCPGB011(cU00_CODIGO, nOpc)
Local aArea		:= GetArea()
Local aAreaU00 	:= U00->(GetArea())
Local aAreaSE3	:= SE3->(GetArea())

Local aAuto 	:= {} //array do execauto
Local lRet 		:= .T. //controle de transação

Local cQry		:= ""

Private lMsErroAuto := .F.

Default cU00_CODIGO := U00->U00_CODIGO
Default nOpc		:= 1

U00->(dbSetOrder(1)) //U00_FILIAL+U00_CODIGO
If U00->(dbSeek(xFilial("U00")+cU00_CODIGO))

	SE3->(DbOrderNickName("XCTRCEMSE3")) //E3_FILIAL+E3_XCONTRA 

	If Select("QRYSE3") > 0
		QRYSE3->(DbCloseArea())
	Endif

	If SE3->(dbSeek(xFilial("SE3")+U00->U00_CODIGO))
	
		While SE3->(!Eof()) .and. lRet .and. SE3->(E3_FILIAL+E3_XCONTRA) == (xFilial("SE3")+U00->U00_CODIGO)
			
			If nOpc == 2 .or. Empty(SE3->E3_DATA)
				
				aAuto := {}
				aAdd(aAuto, {"E3_VEND"		, SE3->E3_VEND		,Nil})
				aAdd(aAuto, {"E3_NUM" 		, SE3->E3_NUM		,Nil})
				aAdd(aAuto, {"E3_CODCLI"	, SE3->E3_CODCLI		,Nil})
				aAdd(aAuto, {"E3_LOJA"		, SE3->E3_LOJA		,Nil})
				aAdd(aAuto, {"E3_PREFIXO"	, SE3->E3_PREFIXO	,Nil})
				aAdd(aAuto, {"E3_PARCELA"	, SE3->E3_PARCELA	,Nil})
				aAdd(aAuto, {"E3_TIPO"		, SE3->E3_TIPO		,Nil})
				
				MSExecAuto({|x,y| Mata490(x,y)}, aAuto, 5) //Exclusão de Comissão
				
				If lMsErroAuto
					
					If !IsBlind()
						MostraErro()
					Endif

					//DisarmTransaction()
					lRet := .F.
				EndIf
			EndIf
			
			SE3->(dbSkip())
		EndDo
	EndIf
EndIf

If Select("QRYSE3") > 0
	QRYSE3->(DbCloseArea())
Endif

RestArea(aAreaU00)
RestArea(aAreaSE3)
RestArea(aArea)
	
Return lRet