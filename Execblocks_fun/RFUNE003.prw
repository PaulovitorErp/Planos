#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*/{Protheus.doc} RFUNE003
Atualiza o Browse do Pedido de Vendas, em função da alteração da informação do campo Classificação (C5_XCLASSI)
@author TOTVS
@since 10/11/2016
@version P12
@param cClassif
@return nulo
/*/

/*******************************/
User Function RFUNE003(cClassif)
/*******************************/

Local lRet			:= .T.
Local cOper			:= ""
Local cTes			:= ""
Local nUsado		:= Len(aHeader)
Local nPosOper		:= GdFieldPos("C6_OPER")
Local nLinBkp		:= n
Local cCodIss		:= ""	
Local cMsgErro		:= ""
Local nX			:= 1
Local cOpFinSEst	:= SuperGetMv("MV_XOPFSEN",.F.,"08") 
Local cOpFinCEst	:= SuperGetMv("MV_XOPFSES",.F.,"09")
Local cOpNFinNEst	:= SuperGetMv("MV_XOPFNEN",.F.,"10") 
Local cOpNFinCEst	:= SuperGetMv("MV_XOPFNES",.F.,"11")

If Empty(M->C5_XCTRFUN) 

	If cClassif == "A" .Or. cClassif == "C" //Carência Ou Contrato 
		MsgInfo("Opção permitida somente para Pedido de Venda derivado de Apontamentos de Contrato.","Atenção")
		lRet := .F.
	Endif	
Endif

If lRet

	//////////////////////////////////////////////////////////////////////////
	//                 PREENCHIMENTO DO CODIGO SERVICO ISS				  	//
	//////////////////////////////////////////////////////////////////////////
	// Na nota fiscal de serviço, deve existir apenas 1 item.				//
	// Para que os itens do pedido de vendas sejam aglutinados, todos os	// 
	// itens da SC6 devem ter o mesmo código ISS.							//
	// O código ISS referente à todos os itens do contrato irá variar de	//
	// acordo com a classificação do pedido.								// 
	//////////////////////////////////////////////////////////////////////////
	// A=Carencia (MV_XISSCTC);												//
	// C=Contrato (MV_XISSCT);												//
	// E=Carente (MV_XISSCAR);												//
	// I=Indigente (MV_XISSIND);											//
	// P=Particular (MV_XISSPAR);											//
	//////////////////////////////////////////////////////////////////////////
			
	if cClassif == "A" // contrato em carência  
		cCodIss := SuperGetMv("MV_XISSCTC",,"") 
	elseif cClassif == "C" // contrato sem carência  
		cCodIss := SuperGetMv("MV_XISSCT",,"")
	elseif cClassif == "E" // serviço para carente
		cCodIss := SuperGetMv("MV_XISSCAR",,"")
	elseif cClassif == "I" // serviço para indigente
		cCodIss := SuperGetMv("MV_XISSIND",,"")
	elseif cClassif == "P" // serviço particular
		cCodIss := SuperGetMv("MV_XISSPAR",,"")
	endif
	
	if Empty(cCodIss)
	
		lRet 		:= .F.
		cMsgErro	:= "Não foi informado o código ISS referente à esta classificação do pedido de vendas." + chr(13)+chr(10)
		cMsgErro	+= "Solicite ao administrador do sistema para a verificação dos seguintes parâmetros:" + chr(13)+chr(10)
		cMsgErro 	+= "A=Carencia - (MV_XISSCTC)" + chr(13)+chr(10)
		cMsgErro 	+= "C=Contrato - (MV_XISSCT)" + chr(13)+chr(10)
		cMsgErro 	+= "E=Carente - (MV_XISSCAR)" + chr(13)+chr(10)
		cMsgErro 	+= "I=Indigente - (MV_XISSIND)" + chr(13)+chr(10)
		cMsgErro 	+= "P=Particular - (MV_XISSPAR)" + chr(13)+chr(10)		
		
		MsgInfo(cMsgErro,"Atenção")
		
	else

		For nX := 1 To Len(aCols)
			
			n := nX
		
			If !Empty(aCols[n,GdFieldPos("C6_PRODUTO")]) .And. !aCols[nX,nUsado + 1]
	
				If cClassif == "E" .Or. cClassif == "I" //Carente Ou Indigente
					
					If Posicione("SB1",1,xFilial("SB1")+aCols[n,GdFieldPos("C6_PRODUTO")],"B1_TIPO") == "SV" //Serviço
						cOper := Alltrim(cOpNFinNEst) //Operação não gera Financeiro, não movimenta Estoque
					Else
						cOper :=Alltrim(cOpNFinCEst) //Operação não gera Financeiro, movimenta Estoque
					Endif
				Else
					
					If Posicione("SB1",1,xFilial("SB1")+aCols[n,GdFieldPos("C6_PRODUTO")],"B1_TIPO") == "SV" //Serviço
						cOper := Alltrim(cOpFinSEst) //Operação gera Financeiro, não movimenta Estoque
					Else
						cOper := Alltrim(cOpFinCEst) //Operação gera Financeiro, movimenta Estoque
					Endif
				Endif
			
				//Linha necessária para atualização da informação de TES no Browse
				cTes := MaTesInt(2,AllTrim(cOper),M->C5_CLIENTE,M->C5_LOJACLI,IIf(M->C5_TIPO$'DB',"F","C"),aCols[n,GdFieldPos("C6_PRODUTO")],"C6_TES")
		
				GdFieldPut("C6_OPER", cOper, n)
				//M->C6_OPER := cOper 
				
				GdFieldPut("C6_TES", cTes, n) 
				//M->C6_TES := cTes 

				GdFieldPut("C6_CODISS", cCodIss, n)
				//M->C6_CODISS := cCodIss 
				
				/*If ExistTrigger("C6_OPER")
					RunTrigger(2,n,nil,,"C6_OPER")
				EndIf 
		
				If ExistTrigger("C6_TES")
					RunTrigger(2,n,nil,,"C6_TES")
				EndIf */ 
					
				oGetDad:Refresh()
			Endif
		Next
	
		n := nLinBkp
		GetdRefresh() //Refresh no browse
	Endif
Endif

Return(lRet)