#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'tbiconn.ch'
#INCLUDE 'topconn.ch'

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RCPGA017
Rotina de geração de comissão pela baixa dos títulos.
Cobranca: comissão de motoqueiros

@author Pablo Cavalcante
@since 19/04/2016
@version undefined

@type function
/*/

User Function RCPGA017(cVendedor, cLog)
Local aArea			:= GetArea()
Local aAreaSA3		:= SA3->(GetArea())
Local aAreaU18 		:= U18->(GetArea())
Local aAreaSE1		:= SE1->(GetArea())
Local aAreaSA1		:= SA1->(GetArea())
Local aAreaSE5  	:= SE5->(GetArea())

Local cPulaLinha	:= chr(13)+chr(10)
Local cPrefixo		:= ""
Local cTitulo		:= ""
Local cParcela		:= ""
Local cTipo			:= ""
Local cCliente		:= ""
Local cLoja			:= ""
Local cCxVend		:= "" 
						
Local aAuto 		:= {} //array do execauto

Local dDtEmis		:= CtoD("")
Local dVencto		:= CtoD("")

Local nParcel 		:= 0 //numero de titulos recebidos no mes de determinado vendedor
Local nPComis		:= 0 //numero de parcelas de comissão
Local nVlrBas 		:= 0 //valor total do contrato

Local nTotComis 	:= 0 //valor total da comissao
Local nComissao 	:= 0 //valor da comissão da parcela
Local lRet 			:= .T. //controle de transação
                         

Local aTmp			:= {}
Local cTmp			:= ""
Local nX			:= 0
Default cLog		:= ""

Private lMsErroAuto := .F.

	cLog += cPulaLinha
	cLog += " >> RCPGA017 [INICIO] - ROTINA DE GERAÇAO DE COMISSAO PELA BAIXA DOS TITULOS." + cPulaLinha

	//Posiciona no Vendedor
	SA3->(dbSetOrder(1)) //A3_FILIAL+A3_COD
	If SA3->(dbSeek(xFilial("SA3")+cVendedor))
		
		dDtEmis := dDataBase //SE1->E1_BAIXA //SE5->E5_DATA //SE5->E5_DTDISPO
				
		//Posiciona no Cliclo e Pgto de Comissão
		U18->(dbSetOrder(1)) //U18_FILIAL+U18_CODIGO
		
		//inicio a transacao 
		BeginTran()
		
		If U18->(dbSeek(xFilial("U18")+SA3->A3_XCICLO))
			
			//intervalo de um mes para considerar os titulos baixados
			dBaixaDe := FirstDate(dDtEmis) //Retorna a Data do Primeiro dia do mes da data passada
			dBaixaAt := LastDate(dDtEmis)  //Retorna a Data do ùltimo dia do mes da data passada
			
			cLog += cPulaLinha
			cLog += "   >> EXCLUSÃO DAS COMISSÕES EXISTENTES..." + cPulaLinha
			
			//exclui as comissões que não fazem parte dos titulos baixados no periodo de: dBaixaDe e dBaixaAt 
			cQry := "select SE3.*" + cPulaLinha
			cQry += " from " + RetSqlName("SE3") + " SE3" + cPulaLinha
			cQry += " where SE3.D_E_L_E_T_ <> '*'" + cPulaLinha
			cQry += " and SE3.E3_VEND = '" + SA3->A3_COD + "'" + cPulaLinha
			cQry += " and SE3.E3_XORIGEM = 'R'" + cPulaLinha
			cQry += " and SE3.E3_EMISSAO BETWEEN '" + DTOS(dBaixaDe) + "' AND '" + DTOS(dBaixaAt) + "'" + cPulaLinha
			
			cLog += cPulaLinha
			cLog += " >> QUERY: "
			cLog += cPulaLinha
			cLog += cQry
			cLog += cPulaLinha
			cLog += cPulaLinha
			
			If Select("QAUXSE3") > 0
				QAUXSE3->(dbCloseArea())
			EndIf
			
			cQry := Changequery(cQry)
			TCQUERY cQry NEW ALIAS "QAUXSE3"
			
			QAUXSE3->(dbGoTop())
			
			
			While QAUXSE3-> (!Eof())
				
				//posiciona na comissão
				SE3->(dbSetOrder(3)) //E3_FILIAL+E3_VEND+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO+E3_SEQ
				SE3->(dbGoTo(QAUXSE3->R_E_C_N_O_))
				
				cLog += cPulaLinha
				cLog += " >> CHAVE DA COMISSÃO EXCLUIDA: RECNO - " + PADL(cValToChar(QAUXSE3->R_E_C_N_O_) , 10) + cPulaLinha
				cLog += "   >> E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND = " + QAUXSE3->E3_FILIAL + QAUXSE3->E3_PREFIXO + QAUXSE3->E3_NUM + QAUXSE3->E3_PARCELA + QAUXSE3->E3_SEQ + QAUXSE3->E3_VEND + cPulaLinha
				cLog += "   >> VALOR DA BASE (R$)     = " + PADL(cValToChar(QAUXSE3->E3_BASE) , 10) + cPulaLinha 
				cLog += "   >> PERCENTUAL  (%)        = " + PADL(cValToChar(QAUXSE3->E3_PORC) , 10) + cPulaLinha
				cLog += "   >> VALOR DA COMISSAO (R$) = " + PADL(cValToChar(QAUXSE3->E3_COMIS) , 10) + cPulaLinha
				cLog += cPulaLinha
				
				aAuto := {}
				aAdd(aAuto,{"E3_VEND", SE3->E3_VEND, Nil})
				aAdd(aAuto,{"E3_CODCLI", SE3->E3_CODCLI, Nil})
				aAdd(aAuto,{"E3_LOJA", SE3->E3_LOJA, Nil})
				aAdd(aAuto,{"E3_PREFIXO", SE3->E3_PREFIXO, Nil})
				aAdd(aAuto,{"E3_NUM", SE3->E3_NUM, Nil})
				aAdd(aAuto,{"E3_PARCELA", SE3->E3_PARCELA, Nil})
				aAdd(aAuto,{"E3_TIPO", SE3->E3_TIPO, Nil})
				aAdd(aAuto,{"E3_SEQ", SE3->E3_SEQ, Nil})
				
				lMsErroAuto := .F.
				
				MSExecAuto({|x,y| Mata490(x,y)}, aAuto, 5) //Exclusão de Comissão
				
				If lMsErroAuto
				
					lRet	:= .F.
					cLog 	+= MostraErro("\temp") + cPulaLinha
					DisarmTransaction()
					
					Exit
						
				Endif
				
				QAUXSE3-> (dbSkip())
			EndDo
			
			//somente gero novas comissoes quando as anteriores foram excluidas com sucesso
			if lRet
			
				cLog += cPulaLinha
				cLog += "   >> GERAÇÃO DAS COMISSÕES DOS TITULOS BAIXADOS DO PERIODO DE: "+dToC(dBaixaDe)+" e "+dToC(dBaixaAt)+"..." + cPulaLinha
				
				//retorno o caixa do vendedor selecionado
				cCxVend	:= U_UxNumCx(SA3->A3_COD)
				
				//valido se existe caixa para o vendedor 
				If !Empty(cCxVend)
				
					//gera comissão para os titulos baixados no periodo de: dBaixaDe e dBaixaAt
					//remove os titulos do tipo abatimento
					aTmp := STRTOKARR(MVABATIM, "|")
					cTmp := " AND SE1.E1_TIPO NOT IN ("
					For nX:= 1 to Len(aTmp)
						If nX < Len(aTmp)
							cTmp += "'"+aTmp[nX]+"', "
						Else
							cTmp += "'"+aTmp[nX]+"'"
						EndIf
					Next nX
					cTmp += ") "
					
					cQry := "select SE1.* " + cPulaLinha
					cQry += " from " + RetSqlName("SE1") + " SE1" + cPulaLinha
					cQry += " where SE1.D_E_L_E_T_ <> '*'" + cPulaLinha
					cQry += " and SE1.E1_XFILVEN = '"  + xFilial("SA3") + "' " + cPulaLinha
					cQry += " and SE1.E1_XVENDCB = '" + SA3->A3_COD + "'" + cPulaLinha //vendedor da baixa
					cQry += " and SE1.E1_BAIXA BETWEEN '" + DTOS(dBaixaDe) + "' AND '" + DTOS(dBaixaAt) + "'" + cPulaLinha
					cQry += cTmp + CRLF //remove os titulos de abatimento
					cQry += " order by E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO" + cPulaLinha
					
					cLog += cPulaLinha
					cLog += " >> QUERY: "
					cLog += cPulaLinha
					cLog += cQry
					cLog += cPulaLinha
					cLog += cPulaLinha
					
					If Select("QAUXSE1") > 0
						QAUXSE1->(dbCloseArea())
					EndIf
					
					cQry := Changequery(cQry)
					TCQUERY cQry NEW ALIAS "QAUXSE1"
					
					QAUXSE1->(dbEval({|| nParcel++}))
					QAUXSE1->(dbGoTop())
					
					cLog += cPulaLinha
					cLog += "   >> N. DE TITULOS COBRADOS     = " + PADL(cValToChar(nParcel) , 10) + cPulaLinha
					cLog += cPulaLinha
					
					While QAUXSE1-> (!Eof())
						
						//Posiciona no Titulo
						SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
						SE1->(dbGoTo(QAUXSE1->R_E_C_N_O_))			
						
						//Posiciona no Cliente/Loja
						SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
						If SA1->(dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
						
							//Posiciona no Movimento de Baixa
							SE5->(dbSetOrder(7)) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
							If SE5->(dbSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+SE1->E1_LOJA)))
							    
								cPrefixo	:= SE5->E5_PREFIXO
								cTitulo		:= SE5->E5_NUMERO
								cParcela	:= SE5->E5_PARCELA
								cTipo		:= SE5->E5_TIPO
								cCliente	:= SE5->E5_CLIFOR
								cLoja		:= SE5->E5_LOJA
								                                                      
								//quando realizamos o recebimento de varios titulos, em varias formas de pagamento, esses valores sao rateados
								//na SE5, entao é necessário realizar a varredura desses movimentos para somar o valor correto.
								nVlrBas := RetMovSE5(cCxVend,cPrefixo,cTitulo,cParcela,cTipo,cCliente,cLoja)
								
								//apenas gero comissao caso exista movimento de baixa para o caixa
								if nVlrBas > 0 		
									
									cQry := "select * "
									cQry += " from " + RetSqlName("U15") + " U15"
									cQry += " inner join " + RetSqlName("U16") + " U16"
									cQry += 	" on (U15_FILIAL = U16_FILIAL and U15_CODIGO = U16_CATEGO and U16.D_E_L_E_T_ <> '*')"
									cQry += " inner join " + RetSqlName("U17") + " U17"
									cQry += 	" on (U15_FILIAL = U17_FILIAL and U15_CODIGO = U17_CATEGO and U16_CODIGO = U17_CONDIC and U17.D_E_L_E_T_ <> '*')"
									cQry += " where U15.D_E_L_E_T_ <> '*'"
									cQry += " and U15.U15_FILIAL = '" + xFilial("U15") + "'"
									cQry += " and U15.U15_CODIGO = '" + SA3->A3_XCATEGO + "'"
									cQry += " and U16.U16_NPARDE <= '" + STRZERO(nParcel,tamsx3('U16_NPARDE')[1],0) + "'"
									cQry += " and U16.U16_NPARAT >= '" + STRZERO(nParcel,tamsx3('U16_NPARAT')[1],0) + "'"
											
									If Select("QAUXU15") > 0
										QAUXU15->(dbCloseArea())
									EndIf
									
									cQry := Changequery(cQry)
									TCQUERY cQry NEW ALIAS "QAUXU15"
									
									QAUXU15->(dbEval({|| nPComis++}))
									QAUXU15->(dbGoTop())
											
									If QAUXU15->(!Eof())
										If QAUXU15->U15_TPVAL == "P" // % percentual
											nTotComis := nVlrBas * (QAUXU15->U15_PERC/100)
										ElseIf QAUXU15->U15_TPVAL == "V" // valor fixo
											nTotComis := QAUXU15->U15_VAL
										EndIf
									Else
										lRet := .F.
									EndIf 
									
									cE3_SEQ := PADL('0',tamsx3('E3_SEQ')[1],'0')
									
									While QAUXU15->(!Eof()) .and. lRet
									
										cE3_SEQ		:= Soma1(cE3_SEQ)
										
										dE3_DATA    := DaySum(dDtEmis, Val(QAUXU15->U17_PRAZO)) //data do possivel pagamento da comissão
										If Val(Day2Str(dE3_DATA)) <= U18->U18_DIAFEC //A3_DIA e A3_DDD (F - Fora Mes)
											dE3_VENCTO := CtoD(PADL(U18->U18_DIAFEC,2,"0")+"/"+Month2Str(dE3_DATA)+"/"+Year2Str(dE3_DATA))
										Else
											dE3_VENCTO := CtoD(PADL(U18->U18_DIAFEC,2,"0")+"/"+Month2Str(MonthSum(dE3_DATA,1))+"/"+Year2Str(MonthSum(dE3_DATA,1)))
										EndIf
										dE3_VENCTO	 := DataValida(dE3_VENCTO,.T.)
										
										If QAUXU15->U15_TPVAL == "V"
											nComissao := QAUXU15->U17_VALOR
										Else
											nComissao := nTotComis * (QAUXU15->U17_PERC/100)
										EndIf
										
										If nComissao > 0
										
											aAuto := {}
											aAdd(aAuto, {"E3_VEND",		SA3->A3_COD,				Nil}) //Vendedor
											aAdd(aAuto, {"E3_NUM",		SE1->E1_NUM,				Nil}) //No. Titulo
											aAdd(aAuto, {"E3_EMISSAO",	SE1->E1_BAIXA,				Nil}) //Data  de  emissão do título referente ao pagamento de comissão.
											aAdd(aAuto, {"E3_SERIE",	"",							Nil}) //Serie N.F.
											aAdd(aAuto, {"E3_CODCLI",	SE1->E1_CLIENTE,			Nil}) //Cliente
											aAdd(aAuto, {"E3_LOJA",		SE1->E1_LOJA,				Nil}) //Loja
											aAdd(aAuto, {"E3_BASE",		nVlrBas,					Nil}) //Valor base do título para cálculo de comissão.
											aAdd(aAuto, {"E3_PORC",		(nComissao/nVlrBas)*100, 	Nil}) //Percentual incidente ao valor do título para cálculo de comissão.
											aAdd(aAuto, {"E3_COMIS",	nComissao,					Nil}) //Valor da Comissão
											aAdd(aAuto, {"E3_PREFIXO",	SE1->E1_PREFIXO,			Nil}) //Prefixo
											aAdd(aAuto, {"E3_PARCELA",	SE1->E1_PARCELA,			Nil}) //Parcela
											aAdd(aAuto, {"E3_SEQ",		cE3_SEQ,					Nil}) //Sequencia
											aAdd(aAuto, {"E3_TIPO",		SE1->E1_TIPO,				Nil}) //Tipo do título que originou a comissão.
											aAdd(aAuto, {"E3_PEDIDO",	"",							Nil}) //No. Pedido
											aAdd(aAuto, {"E3_VENCTO",	dE3_VENCTO,					Nil}) //Data de vencimento da comissão.
											aAdd(aAuto, {"E3_PROCCOM",	"",							Nil}) //Proc. Com.
											aAdd(aAuto, {"E3_MOEDA",	"01",						Nil}) //Moeda
											aAdd(aAuto, {"E3_CCUSTO",	"",							Nil}) //Centro de Custo
											aAdd(aAuto, {"E3_BAIEMI",	"B",						Nil}) //Comissao gerada: B - Pela Baixa ou E - Pela Emissão 
											aAdd(aAuto, {"E3_ORIGEM",	"B",						Nil}) //Origem da Comissao
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
											aAdd(aAuto, {"E3_XCONTRA","",Nil}) //Codigo do Contrato
											aAdd(aAuto, {"E3_XPARCON","",Nil}) //Referencia do Parcelamento do Contrato
											aAdd(aAuto, {"E3_XPARCOM","",Nil}) //Referencia do Parcelamento da Comissao
											If SE3->(FieldPos("E3_XORIGEM"))>0
												aAdd(aAuto, {"E3_XORIGEM","R",Nil})
												/*****************************************
													Origem do SE3
													"C" //Cemiterio (Contrato)
													"F" //Funeraria (Contrato)
													"R" //Recebimento de Cobranca (Motoqueiro)
													"V" //Venda Avulsa (Pedido de Venda e/ou Venda Direta)
													"G" //Comissão de Gerente e Supervisor
												*****************************************/
											EndIf
											
											lMsErroAuto := .F.
											
											SE3->( DbOrderNickName("E3_XORIGEM") ) //E3_FILIAL+E3_VEND+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO+E3_SEQ+E3_XORIGEM
										
											If SE3->(dbSeek(xFilial("SE3")+SA3->A3_COD+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)+cE3_SEQ+"R"))
												MSExecAuto({|x,y| Mata490(x,y)}, aAuto, 4) //Alteração de Comissão
											Else
												MSExecAuto({|x,y| Mata490(x,y)}, aAuto, 3) //Inclusão de Comissão
											EndIf
											
											If lMsErroAuto
										
												cLog += MostraErro("\temp") + cPulaLinha
												DisarmTransaction()
												lRet := .F.
												Exit
												
											Else
										
												cLog += cPulaLinha
												cLog += " >> CHAVE DA COMISSÃO GERADA: RECNO - " + PADL(cValToChar(SE3->(RecNo())) , 10) + cPulaLinha
												cLog += "   >> E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND = " + SE3->E3_FILIAL + SE3->E3_PREFIXO + SE3->E3_NUM + SE3->E3_PARCELA + SE3->E3_SEQ + SE3->E3_VEND + cPulaLinha
												cLog += "   >> VALOR DA BASE (R$)     = " + PADL(cValToChar(SE3->E3_BASE) , 10) + cPulaLinha 
												cLog += "   >> PERCENTUAL  (%)        = " + PADL(cValToChar(SE3->E3_PORC) , 10) + cPulaLinha
												cLog += "   >> VALOR DA COMISSAO (R$) = " + PADL(cValToChar(SE3->E3_COMIS) , 10) + cPulaLinha
												cLog += cPulaLinha
										
											EndIf
										
										EndIf
										
										QAUXU15->(dbSkip())
									EndDo
								
									QAUXU15->(dbCloseArea())
								else
									cLog += cPulaLinha
									cLog += " >> RCPGA017 - NAO EXISTE MOVIMENTOS FINANCEIROS PARA O TITULO: "+cPrefixo+"/"+cTitulo+"/"+cParcela+" ." + cPulaLinha
								endif
								
							EndIf
						EndIf
						
						QAUXSE1->(dbSkip())
					
					EndDo
					
					QAUXSE1->(dbCloseArea())
			
				else
			
					cLog += cPulaLinha
					cLog += " >> RCPGA017 - O VENDEDOR: " +SA3->A3_COD+ " NAO POSSUI CAIXA VINCULADO AO SEU CADASTRO." + cPulaLinha
			
				endif
			
			endif
			
		EndIf
		
		//finalizado com sucesso 
		if lRet
			EndTran()
		endif
		
		
	EndIf
	
	cLog += cPulaLinha
	cLog += " >> RCPGA017 [FIM] - ROTINA DE GERAÇAO DE COMISSAO PELA BAIXA DOS TITULOS." + cPulaLinha
	
	
	RestArea(aAreaSE5)
	RestArea(aAreaSA1)
	RestArea(aAreaSE1)
	RestArea(aAreaU18)
	RestArea(aAreaSA3)
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} RetMovSE5
Funcao para retornar os movimentos da SE5 do titulo
selecionado
@author Raphael Martins
@since 10/03/2017
@version undefined

@type function
/*/

Static Function RetMovSE5(cBancoCX,cPrefixo,cTitulo,cParcela,cTipo,cCliente,cLoja) 

Local cQry 		:= "" 
Local nRetMov	:= 0  

If !Empty(cBancoCX)
	cQry := " SELECT SUM(E5_VALOR) VALOR " 
	cQry += " FROM " 
	cQry += "  " + RetSQLName("SE5") + " SE5 " 
	cQry += " WHERE " 
	cQry += "  SE5.D_E_L_E_T_ = ' ' " 
	cQry += "  AND SE5.E5_FILIAL  = '" + xFilial("SE5") + "' " 
	cQry += "  AND SE5.E5_PREFIXO = '" + cPrefixo + "' " 
	cQry += "  AND SE5.E5_NUMERO  = '" + cTitulo + "' " 
	cQry += "  AND SE5.E5_PARCELA = '" + cParcela + "' "
	cQry += "  AND SE5.E5_CLIFOR  = '" + cCliente + "' " 
	cQry += "  AND SE5.E5_LOJA 	  = '" + cLoja + "' " 
	cQry += "  AND SE5.E5_TIPODOC <> 'ES' " 
	cQry += "  AND SE5.E5_RECPAG = 'R' "    
	cQry += "  AND SE5.E5_SITUACA <> 'C' "
	cQry += "  AND SE5.E5_BANCO = '"+cBancoCX+"'

	If Select("QSE5") > 0
		QSE5->(dbCloseArea())
	EndIf
	
	TcQuery cQry New Alias "QSE5"
	
	nRetMov := QSE5->VALOR

endif
	
Return(nRetMov)