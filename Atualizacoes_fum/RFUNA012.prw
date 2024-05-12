#include "protheus.ch" 
#include "fwmvcdef.ch"
#include "topconn.ch"

/*/{Protheus.doc} RFUNA012
Rotina de geração de comissão de contrato de Funerario. 

@author Raphael Martins
@since 04/08/2016
@version undefined
@param cUF2_CODIGO, characters, Código do Contrato
@type function
/*/
User function RFUNA012(cUF2_CODIGO,cLog)   

Local lRet 		:= .T. 
Local nParcel	:= 0      
Local aVlrParc	:= {}
Local aArea		:= GetArea()
Local aAreaUF0 	:= UF0->( GetArea() )
Local aAreaUF2 	:= UF2->( GetArea() )
Local aAreaU18	:= U18->( GetArea() )
Local aAreaSA1	:= SA1->( GetArea() )
Local aAreaSA3	:= SA3->( GetArea() )
Local aAreaSE3	:= SE3->( GetArea() )

Default cUF2_CODIGO := UF2->UF2_CODIGO
Default cLog 		:= "" 
UF0->( DbSetOrder(1) ) //UF0_FILIAL+UF0_CODIGO 
UF2->( DbSetOrder(1) ) //UF2_FILIAL+UF2_CODIGO 
SA3->( DbSetOrder(1) ) //A3_FILIAL+A3_COD  
SA1->( DbSetOrder(1) ) //A1_FILIAL+A1_COD+A1_LOJA  
U18->( DbSetOrder(1) ) //U18_FILIAL+U18_CODIGO


If UF2->( DbSeek( xFilial("UF2") +  cUF2_CODIGO ) ) 
  	
  	nParcel := UF2->UF2_QTPARC
  	nVlrCtr := UF2->UF2_VALOR	
  	
  	If !Empty(UF2->UF2_VEND)
  		//verifico se o plano do contrato gera comissao
  		If UF0->( DbSeek( xFilial("UF0") + UF2->UF2_PLANO  ) )
  		   	If UF0->UF0_COMISS == 'S'
  		   	   //valido se possui titulo para o contrato
  		   	   If PossuiTit(UF2->UF2_CODIGO)
  		   	      	If SA3->( DbSeek(xFilial("SA3") + UF2->UF2_VEND ) )
  		   	      		
  		   	      		If SA1->(dbSeek(xFilial("SA1")+UF2->UF2_CLIENT+UF2->UF2_LOJA) ) 
  		   	      			
  		   	      			if !Empty(SA3->A3_XCICLO) .And. !Empty(SA3->A3_XCATEGO)
	  		   	      			//valido o ciclo de cobrancao do vendedor
	  		   	      			If U18->( DbSeek( xFilial("U18") + SA3->A3_XCICLO ) ) 
	  		   	      		    
	  		   	      		    	lRet := GeraComiss(UF2->UF2_CODIGO,UF2->UF2_DTATIV,nParcel,UF2->UF2_VEND,SA3->A3_XCATEGO,UF2->UF2_CLIENT,UF2->UF2_LOJA,nVlrCtr,cLog,U18->U18_DIAFEC) 
	  		   	      			else
	  		   	      				If !Empty(cLog)
	  		   	      	   				cLog += CRLF
	  		   	      	   				cLog += "   >> CICLO DE COBRANCA DO VENDEDOR NAO ENCONTRADO..." + CRLF
	  		   	      	   			Else
	  		   	      	   				If !IsBlind()
	  		   	      	   					MsgInfo("O Ciclo de Cobranca do Vendedor nao encontrado!","Atenção")
	  		   	      	   				Endif
	  		   	      	   			EndIf
	  		   	      	   			lRet := .F. 
	  		   	      			endif
	  		   	      		else
	  		   	      			
	  		   	      			If !Empty(cLog)
	  		   	      			
	  		   	      				cLog += CRLF
	  		   	      	   			cLog += "   >> CICLO DE COBRANCA E CATEGORIA DE COMISSAO NAO PREENCHIDO PARA O VENDEDOR..." + CRLF
	  		   	      	   		
	  		   	      	   		Else
	  		   	      	   		
  		   	      	   				If !IsBlind() .And. !IsInCallStack("U_RUTIL21B")
  		   	      	   					MsgInfo("O Ciclo de Cobranca e/ou Categoria de Comissao não preenchido para o vendedor, não será gerado comissão!","Atenção")
  		   	      	   				Endif
	  		   	      	   		
	  		   	      	   		EndIf
	  		   	      	   			
	  		   	      		endif
	  		   	      			
  		   	      		Else
  		   	      	   		If !Empty(cLog)
  		   	      	   			cLog += CRLF
  		   	      	   			cLog += "   >> CLIENTE DO CONTRATO NAO ENCONTRADO..." + CRLF
  		   	      	   		Else
  		   	      	   			If !IsBlind()
  		   	      	   				MsgInfo("O Cliente do Contrato não foi encontrado!.","Atenção")
  		   	      	   			Endif
  		   	      	   		EndIf
  		   	      	   		lRet := .F. 
  		   	      		EndIf
  		   	      		
  		   	      	Else
  		   	      		If !Empty(cLog)
  		   	      			cLog += CRLF
  		   	      			cLog += "   >> VENDEDOR DO CONTRATO NAO ENCONTRADO..." + CRLF
  		   	      		Else
	   	      	   			If !IsBlind()
	   	      	   				MsgInfo("O Vendedor do contrato não foi encontrado!.","Atenção")
	   	      	   			Endif
  		   	      		EndIf
  		   	      		lRet := .F. 
  		   	      	EndIf
  		   	   Else
  		   	   	  
  		   	   	  If !Empty(cLog)
  		   	   	  	 cLog += CRLF
  		   	   	  	 cLog += "   >> NAO FORAM ENCONTRADOS TITULOS PARA O CONTRATO..." + CRLF
  		   	   	  Else
       	   			If !IsBlind()
       	   				MsgInfo("Não foram encontrados titulos para o contrato!.","Atenção")
       	   			Endif
  		   	   	  EndIf
  		   	   	  lRet := .F. 
  		   	   EndIf	
  		   	Else
  		   		If !Empty(cLog)
  		   			cLog += CRLF
  		   			cLog += "   >> PLANO DO CONTRATO NAO GERA COMISSAO..." + CRLF
  		   		EndIf
  		   	EndIf
  		Else
  			If !Empty(cLog)
  				cLog += CRLF
  				cLog += "   >> PLANO DO CONTRATO NAO ENCONTRADO..." + CRLF
	   		Else
   	   			If !IsBlind()
   	   				MsgInfo("O Plano do Contrato não foi encontrado!","Atenção")
   	   			Endif
	   		EndIf
	   		lRet := .F. 
  		EndIf
  		
  	Else
   		If !Empty(cLog)
   			cLog += CRLF
   			cLog += "   >> CONTRATO SEM VENDEDOR..." + CRLF
		Else
  		   	If !IsBlind()
  		   		MsgInfo("O contrato selecionado não possui vendedor, assim não será gerado comissão!","Atenção")
  		   	Endif
		EndIf
		
		lRet := .F. 
  	EndIf 		
Else
	lRet := .F. 
	If !Empty(cLog)
		cLog += CRLF	
		cLog += "   >> CONTRATO NÃO LOCALIZADO..." + CRLF
	Else
		If !IsBlind()
			MsgInfo("Contrato não foi encontrado!","Atenção")
		Endif
	EndIf
EndIf


RestArea(aArea) 
RestArea(aAreaUF0)
RestArea(aAreaUF2)
RestArea(aAreaU18)
RestArea(aAreaSA1)
RestArea(aAreaSA3)
RestArea(aAreaSE3)
	
Return(lRet)

/*/{Protheus.doc} PossuiTit
Funcao para validar se o contrato
possui titulos PossuiTit

@author Raphael Martins
@since 04/08/2016
@version undefined
@param cContrato , characters, Código do Contrato
@type function
/*/
Static Function PossuiTit(cContrato)

Local cPrefixo 	:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
Local cTipo		:= SuperGetMv("MV_XTIPFUN",.F.,"AT")
Local nParcel	:= 0
Local nVlrCtr	:= 0
Local lRet		:= .F. 

cQry := "select SUM(SE1.E1_VALOR + SE1.E1_SDACRES - SE1.E1_SDDECRE) AS VLRCTR," // -> Valor Total do Contrato, considerando acrescimo e decrescimo
cQry += " COUNT(*) AS QTDPAR" //-> Quantidade de Parcelas do Contrato
cQry += " from " + RetSqlName("SE1") + " SE1"
cQry += " where SE1.D_E_L_E_T_ <> '*'"
cQry += " and SE1.E1_FILIAL = '" + xFilial('SE1') + "'"
cQry += " and SE1.E1_PREFIXO = '" + cPrefixo + "'"
cQry += " and SE1.E1_TIPO = '" + cTipo + "'"
cQry += " and SE1.E1_NUM = '" + cContrato + "'"

If Select("QAUX") > 0
	QAUX->(dbCloseArea())
EndIf
		
cQry := Changequery(cQry)
TCQUERY cQry NEW ALIAS "QAUX"

If QAUX->( !Eof() )
	lRet := .T.
EndIf

QAUX->( DbCloseArea() )
					
Return(lRet)

/*/{Protheus.doc} GeraComiss
Funcao de Geracao de COmissao de acordo com os 
parametros recebidos 

@author Raphael Martins
@since 04/08/2016
@version undefined
@param cContrato , characters, Código do Contrato
	   dDataAtiva, Date, Data de Ativacao do Contrato
	   nParcel, Number, Numero de Parcelas do Contrato
	   cVendedor,characters, Vendedor do Contrato
	   cCategoria,characters, Categoria de Cobranca do Vendedor
	   cCliente,characters, Cliente do Contrato
	   cLoja,characters, Loja do Cliente do Contrato 
	   nVlrCtr, Number, Valor do Contrato  
	   cLog,characters, Controle de Mensagens do processamento 
@type function
/*/
Static Function GeraComiss(cContrato,dDataAtiva,nParcel,cVendedor,cCategoria,cCliente,cLoja,nVlrCtr,cLog,nDiaFech)

Local cQry         := "" 
Local cE3_PARCELA  := "" 
Local cE3_SEQ      := ""  
Local cPrefixo 	   := SuperGetMv("MV_XPREFUN",.F.,"FUN")
Local cTipo	   	   := SuperGetMv("MV_XTIPFUN",.F.,"AT")
Local nTotComis	   := 0 
Local nComissao	   := 0   
Local nPComis	   := 0 
Local lRet 		   := .T.
Local dEmissao	   := If(!Empty(dDataAtiva),dDataAtiva,dDataBase)  
Local dE3_DATA	   := CTOD(" / / ") 
Local dE3_VENCTO   := CTOD(" / / ") 
Local aAuto		   := {}
                    
Private lMsErroAuto := .F.

//pesquiso a categoria de cobranca do vendedor
cQry := " select * "
cQry += " from " + RetSqlName("U15") + " U15"
cQry += " inner join " + RetSqlName("U16") + " U16"
cQry += 	" on (U15_FILIAL = U16_FILIAL and U15_CODIGO = U16_CATEGO and U16.D_E_L_E_T_ <> '*')"
cQry += " inner join " + RetSqlName("U17") + " U17"
cQry += 	" on (U15_FILIAL = U17_FILIAL and U15_CODIGO = U17_CATEGO and U16_CODIGO = U17_CONDIC and U17.D_E_L_E_T_ <> '*')"
cQry += " where U15.D_E_L_E_T_ <> '*'"
cQry += " and U15.U15_FILIAL = '" + xFilial("U15") + "'"
cQry += " and U15.U15_CODIGO = '" + cCategoria + "'"
cQry += " and U16.U16_FXINIC <= '" + STRZERO(nParcel,tamsx3('U16_FXINIC')[1],0) + "'"
cQry += " and U16.U16_FXFIM >= '" + STRZERO(nParcel,tamsx3('U16_FXFIM')[1],0) + "'"
			
 
If Select("QAUX") > 0
	QAUX->( DbCloseArea() )
EndIf

cQry := Changequery(cQry)
TCQUERY cQry NEW ALIAS "QAUX"

QAUX->(dbGoTop())
			
cE3_PARCELA := PADL('0',TamSx3('E3_PARCELA')[1],'0')
cE3_SEQ		:= PADL('0',TamSx3('E3_SEQ')[1],'0')

If QAUX->(!Eof())
	If QAUX->U15_TPVAL == "P"
		nTotComis := nVlrCtr * (QAUX->U15_PERC/100)
	ElseIf QAUX->U15_TPVAL == "V"
		nTotComis := QAUX->U15_VAL
	EndIf
Else
	lRet := .F.
	If !Empty(cLog)
		cLog += CRLF
		cLog += "   >> NAO FORAM ENCONTRADAS REGRAS DE CATEGORIA DE COMISSAO..." + CRLF
	Else
		MsgInfo("Não foram encontradas regras de categoria de comissão, assim não será gerado comissão!","Atenção")
	EndIf
	
EndIf 

QAUX->( DbEval({|| nPComis++}) )
QAUX->( DbGotop() ) 
		
If lRet 
	While QAUX->( !Eof() )
				
		cE3_PARCELA := Soma1(cE3_PARCELA)
		cE3_SEQ		:= Soma1(cE3_SEQ)
		
		dE3_DATA    := DaySum(dEmissao, Val(QAUX->U17_PRAZO)) //data do possivel pagamento da comissão
		If Val(Day2Str(dE3_DATA)) <= nDiaFech //A3_DIA e A3_DDD (F - Fora Mes)
			dE3_VENCTO := DataValida( CtoD(PADL(nDiaFech,2,"0")+"/"+Month2Str(dE3_DATA)+"/"+Year2Str(dE3_DATA)) )
		Else
			dE3_VENCTO := DataValida(CtoD(PADL(nDiaFech,2,"0")+"/"+Month2Str(MonthSum(dE3_DATA,1))+"/"+Year2Str(MonthSum(dE3_DATA,1))))
		EndIf
		
		If QAUX->U15_TPVAL == "V"
			nComissao := QAUX->U17_VALOR
		Else
			nComissao := nTotComis * (QAUX->U17_PERC/100)
		EndIf
		
		If nComissao > 0
			
			aAuto := {}
			aAdd(aAuto, {"E3_VEND"		,cVendedor		,Nil}) //Vendedor
			aAdd(aAuto, {"E3_NUM"		,UF2->UF2_CODIGO,Nil}) //No. Titulo
			aAdd(aAuto, {"E3_EMISSAO"	,dEmissao	    ,Nil}) //Data  de  emissão do título referente ao pagamento de comissão.
			aAdd(aAuto, {"E3_SERIE"		,""				,Nil}) //Serie N.F.
			aAdd(aAuto, {"E3_CODCLI"	,cCliente  		,Nil}) //Cliente
			aAdd(aAuto, {"E3_LOJA"		,cLoja			,Nil}) //Loja
			aAdd(aAuto, {"E3_BASE"		,nVlrCtr		,Nil}) //Valor base do título para cálculo de comissão.
			aAdd(aAuto, {"E3_PORC"		,(nComissao/nVlrCtr)*100, Nil}) //Percentual incidente ao valor do título para cálculo de comissão.
			aAdd(aAuto, {"E3_COMIS"		,nComissao		,Nil}) //Valor da Comissão
			aAdd(aAuto, {"E3_PREFIXO"	,cPrefixo		,Nil}) //Prefixo
			aAdd(aAuto, {"E3_PARCELA"	,cE3_PARCELA	,Nil}) //Parcela
			aAdd(aAuto, {"E3_SEQ"		,cE3_SEQ		,Nil}) //Sequencia
			aAdd(aAuto, {"E3_TIPO"		,cTipo			,Nil}) //Tipo do título que originou a comissão.
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
			aAdd(aAuto, {"E3_XCTRFUN"	,UF2->UF2_CODIGO,Nil}) //Codigo do Contrato
			aAdd(aAuto, {"E3_XPARCON"	,Iif(nParcel>1, STRZERO(nParcel,tamsx3('E3_PARCELA')[1],0)+" X", "À VISTA"), Nil}) //Referencia do Parcelamento do Contrato
			aAdd(aAuto, {"E3_XPARCOM"	,cE3_PARCELA+"/"+STRZERO(nPComis,tamsx3('E3_PARCELA')[1],0), Nil}) //Referencia do Parcelamento da Comissao
			If SE3->(FieldPos("E3_XORIGEM"))>0
				aAdd(aAuto, {"E3_XORIGEM","F",Nil})
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
					cLog += MostraErro("\temp")
				Else
					MostraErro()
				EndIf
				lRet := .F.
				Exit
			Else
				cLog += " >> COMISSAO DO CONTRATO: "+Alltrim(UF2->UF2_CODIGO)+" GERADA COM SUCESSO >> " + CRLF
			EndIf
			
		EndIf
		
		QAUX->(dbSkip())
	EndDo
	
	QAUX->(dbCloseArea())
	
EndIf										

Return(lRet)

/*/{Protheus.doc} RFUNB12
//Exclui as comissões do contrato funerario.
@author Raphael Martins
@since 09/08/2016
@version undefined
@param cUF2_CODIGO, characters, Código do Contrato
@type function
/*/
User Function RFUNB12(cUF2_CODIGO)   

Local aArea		:= GetArea()
Local aAreaUF2 	:= UF2->(GetArea())
Local aAreaSE3	:= SE3->(GetArea())

Local aAuto 	:= {} //array do execauto
Local lRet 		:= .T. //controle de transação

Private lMsErroAuto := .F.

Default cUF2_CODIGO := UF2->UF2_CODIGO

	UF2->( DbSetOrder(1) ) //UF2_FILIAL+UF2_CODIGO
	
	If UF2->( DbSeek( xFilial("UF2") + cUF2_CODIGO ) )
	
		SE3->(DbOrderNickName("XCTRFUN")) //E3_FILIAL+E3_XCONTRA 
		If SE3->( DbSeek( xFilial("SE3") + UF2->UF2_CODIGO ) )
		
			While SE3->( !Eof() ) .And.  SE3->(E3_FILIAL+E3_XCTRFUN) == ( xFilial("UF2")+UF2->UF2_CODIGO )
				
				If Empty(SE3->E3_DATA)
					
					aAuto := {}
					aAdd(aAuto, {"E3_VEND"		, SE3->E3_VEND		,Nil})
					aAdd(aAuto, {"E3_NUM" 		, SE3->E3_NUM		,Nil})
					aAdd(aAuto, {"E3_CODCLI"	, SE3->E3_CODCLI	,Nil})
					aAdd(aAuto, {"E3_LOJA"		, SE3->E3_LOJA		,Nil})
					aAdd(aAuto, {"E3_PREFIXO"	, SE3->E3_PREFIXO	,Nil})
					aAdd(aAuto, {"E3_PARCELA"	, SE3->E3_PARCELA	,Nil})
					aAdd(aAuto, {"E3_TIPO"		, SE3->E3_TIPO		,Nil})
					
					MSExecAuto({|x,y| Mata490(x,y)}, aAuto, 5) //Exclusão de Comissão
					
					If lMsErroAuto
						MostraErro()
						lRet := .F.
					EndIf
				Else //
					lRet := .F.	
				EndIf
				
				SE3->(dbSkip())
			EndDo
			
		EndIf
		
	EndIf

	RestArea(aAreaUF2)
	RestArea(aAreaSE3)
	RestArea(aArea)
	
Return lRet

