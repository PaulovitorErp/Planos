#include 'totvs.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE 'tbiconn.ch'
#INCLUDE 'topconn.ch'

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RCPGA038
Gera Comissao de Contrato Cemiterio (Motoqueiros)
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
/*/

User Function RCPGA038(cVendedor,cLog)

Local aArea			:= GetArea()
Local aAreaSA3		:= SA3->(GetArea())
Local aAreaU18 		:= U18->(GetArea())
Local aAreaSE1		:= SE1->(GetArea())
Local aAreaSA1		:= SA1->(GetArea())
Local aAreaSE5  	:= SE5->(GetArea())

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
Local lRetorno 			:= .T. //controle de transação
                         

Local aTmp			:= {}
Local cTmp			:= ""
Local nX			:= 0
Default cLog		:= ""

Private lMsErroAuto := .F.

	cLog += CRLF
	cLog += " >> RCPGA038 [INICIO] - NOVA ROTINA DE GERAÇAO DE COMISSAO PELA BAIXA DOS TITULOS." + CRLF

	//Posiciona no Vendedor
	SA3->(dbSetOrder(1)) //A3_FILIAL+A3_COD
	If SA3->(MsSeek(xFilial("SA3")+cVendedor))
		
		dDtEmis := dDataBase //SE1->E1_BAIXA //SE5->E5_DATA //SE5->E5_DTDISPO
				
		//Posiciona no Cliclo e Pgto de Comissão
		U18->(dbSetOrder(1)) //U18_FILIAL+U18_CODIGO
		
		//inicio a transacao 
		BEGIN TRANSACTION
		
		If U18->(MsSeek(xFilial("U18")+SA3->A3_XCICLO))

            // chamo a rotina de exclusao de comissao
            lRetorno := U_UTILE15B( SA3->A3_COD, U18->U18_DIAFEC, "R", @cLog )
			
			//somente gero novas comissoes quando as anteriores foram excluidas com sucesso
			if lRetorno
			
				cLog += CRLF
				cLog += "   >> GERAÇÃO DAS COMISSÕES DOS TITULOS BAIXADOS DO PERIODO DE: "+dToC(dBaixaDe)+" e "+dToC(dBaixaAt)+"..." + CRLF
				
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
					
					cQuery := "SELECT SE1.* " + CRLF
					cQuery += " FROM " + RetSqlName("SE1") + " SE1" + CRLF
					cQuery += " WHERE SE1.D_E_L_E_T_ <> '*'" + CRLF
					cQuery += " AND SE1.E1_XFILVEN = '"  + xFilial("SA3") + "' " + CRLF
					cQuery += " AND SE1.E1_XVENDCB = '" + SA3->A3_COD + "'" + CRLF //vendedor da baixa
					cQuery += " AND SE1.E1_BAIXA BETWEEN '" + DTOS(dBaixaDe) + "' AND '" + DTOS(dBaixaAt) + "'" + CRLF
					cQuery += cTmp + CRLF //remove os titulos de abatimento
					cQuery += " ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO" + CRLF
					
					cLog += CRLF
					cLog += " >> QUERY: "
					cLog += CRLF
					cLog += cQuery
					cLog += CRLF
					cLog += CRLF
					
					If Select("TRBSE1") > 0
						TRBSE1->(dbCloseArea())
					EndIf
					
					cQuery := Changequery(cQuery)
					TcQuery cQuery New Alias "TRBSE1"
					
					TRBSE1->(dbEval({|| nParcel++}))
					TRBSE1->(dbGoTop())
					
					cLog += CRLF
					cLog += "   >> N. DE TITULOS COBRADOS     = " + PADL(cValToChar(nParcel) , 10) + CRLF
					cLog += CRLF
					
					While TRBSE1-> (!Eof())
						
						//Posiciona no Titulo
						SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
						SE1->(dbGoTo(TRBSE1->R_E_C_N_O_))			
						
						//Posiciona no Cliente/Loja
						SA1->(dbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
						If SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
						
							//Posiciona no Movimento de Baixa
							SE5->(dbSetOrder(7)) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
							If SE5->(MsSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+SE1->E1_LOJA)))
							    
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

                                    // chamo a rotina de calculo de comissao
                                	U_RUTILE15( "R", SE1->E1_NUM, SA3->A3_COD, nVlrBas, @cLog, SE1->E1_BAIXA, .T., SE1->E1_CLIENTE, SE1->E1_LOJA,;
									/*lJob*/, /*nVlrComissao*/, /*nVlrTotal*/, /*nPerVend*/, SE1->E1_PREFIXO, SE1->E1_TIPO, /*cTipoEnt*/, SE1->E1_PARCELA  )
	
	                            EndIf

                            EndIf

						EndIf
						
						TRBSE1->(dbSkip())					
					EndDo
					
					TRBSE1->(dbCloseArea())
			
				else
			
					cLog += CRLF
					cLog += " >> RCPGA038 - O VENDEDOR: " + SA3->A3_COD + " NAO POSSUI CAIXA VINCULADO AO SEU CADASTRO." + CRLF
			
				endif
			
			endif
			
		EndIf
		
		END TRANSACTION		
		
	EndIf
	
	cLog += CRLF
	cLog += " >> RCPGA038 [FIM] - ROTINA DE GERAÇAO DE COMISSAO PELA BAIXA DOS TITULOS." + CRLF
	
	RestArea(aAreaSE5)
	RestArea(aAreaSA1)
	RestArea(aAreaSE1)
	RestArea(aAreaU18)
	RestArea(aAreaSA3)
	RestArea(aArea)
	
Return lRetorno

/*/{Protheus.doc} RetMovSE5
Funcao para retornar os movimentos da SE5 do titulo
selecionado
@author Raphael Martins
@since 10/03/2017
@version undefined

@type function
/*/

Static Function RetMovSE5(cBancoCX,cPrefixo,cTitulo,cParcela,cTipo,cCliente,cLoja) 

Local cQuery 		:= "" 
Local nRetMov	:= 0  

If !Empty(cBancoCX)
	cQuery := " SELECT SUM(E5_VALOR) VALOR " 
	cQuery += " FROM " 
	cQuery += "  " + RetSQLName("SE5") + " SE5 " 
	cQuery += " WHERE " 
	cQuery += "  SE5.D_E_L_E_T_ = ' ' " 
	cQuery += "  AND SE5.E5_FILIAL  = '" + xFilial("SE5") + "' " 
	cQuery += "  AND SE5.E5_PREFIXO = '" + cPrefixo + "' " 
	cQuery += "  AND SE5.E5_NUMERO  = '" + cTitulo + "' " 
	cQuery += "  AND SE5.E5_PARCELA = '" + cParcela + "' "
	cQuery += "  AND SE5.E5_CLIFOR  = '" + cCliente + "' " 
	cQuery += "  AND SE5.E5_LOJA 	  = '" + cLoja + "' " 
	cQuery += "  AND SE5.E5_TIPODOC <> 'ES' " 
	cQuery += "  AND SE5.E5_RECPAG = 'R' "    
	cQuery += "  AND SE5.E5_SITUACA <> 'C' "
	cQuery += "  AND SE5.E5_BANCO = '"+cBancoCX+"'

	If Select("QSE5") > 0
		QSE5->(dbCloseArea())
	EndIf
	
	TcQuery cQuery New Alias "QSE5"
	
	nRetMov := QSE5->VALOR

endif
	
Return(nRetMov)