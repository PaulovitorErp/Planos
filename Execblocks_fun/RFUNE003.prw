#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*/{Protheus.doc} RFUNE003
Atualiza o Browse do Pedido de Vendas, em fun��o da altera��o da informa��o do campo Classifica��o (C5_XCLASSI)
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

	If cClassif == "A" .Or. cClassif == "C" //Car�ncia Ou Contrato 
		MsgInfo("Op��o permitida somente para Pedido de Venda derivado de Apontamentos de Contrato.","Aten��o")
		lRet := .F.
	Endif	
Endif

If lRet

	//////////////////////////////////////////////////////////////////////////
	//                 PREENCHIMENTO DO CODIGO SERVICO ISS				  	//
	//////////////////////////////////////////////////////////////////////////
	// Na nota fiscal de servi�o, deve existir apenas 1 item.				//
	// Para que os itens do pedido de vendas sejam aglutinados, todos os	// 
	// itens da SC6 devem ter o mesmo c�digo ISS.							//
	// O c�digo ISS referente � todos os itens do contrato ir� variar de	//
	// acordo com a classifica��o do pedido.								// 
	//////////////////////////////////////////////////////////////////////////
	// A=Carencia (MV_XISSCTC);												//
	// C=Contrato (MV_XISSCT);												//
	// E=Carente (MV_XISSCAR);												//
	// I=Indigente (MV_XISSIND);											//
	// P=Particular (MV_XISSPAR);											//
	//////////////////////////////////////////////////////////////////////////
			
	if cClassif == "A" // contrato em car�ncia  
		cCodIss := SuperGetMv("MV_XISSCTC",,"") 
	elseif cClassif == "C" // contrato sem car�ncia  
		cCodIss := SuperGetMv("MV_XISSCT",,"")
	elseif cClassif == "E" // servi�o para carente
		cCodIss := SuperGetMv("MV_XISSCAR",,"")
	elseif cClassif == "I" // servi�o para indigente
		cCodIss := SuperGetMv("MV_XISSIND",,"")
	elseif cClassif == "P" // servi�o particular
		cCodIss := SuperGetMv("MV_XISSPAR",,"")
	endif
	
	if Empty(cCodIss)
	
		lRet 		:= .F.
		cMsgErro	:= "N�o foi informado o c�digo ISS referente � esta classifica��o do pedido de vendas." + chr(13)+chr(10)
		cMsgErro	+= "Solicite ao administrador do sistema para a verifica��o dos seguintes par�metros:" + chr(13)+chr(10)
		cMsgErro 	+= "A=Carencia - (MV_XISSCTC)" + chr(13)+chr(10)
		cMsgErro 	+= "C=Contrato - (MV_XISSCT)" + chr(13)+chr(10)
		cMsgErro 	+= "E=Carente - (MV_XISSCAR)" + chr(13)+chr(10)
		cMsgErro 	+= "I=Indigente - (MV_XISSIND)" + chr(13)+chr(10)
		cMsgErro 	+= "P=Particular - (MV_XISSPAR)" + chr(13)+chr(10)		
		
		MsgInfo(cMsgErro,"Aten��o")
		
	else

		For nX := 1 To Len(aCols)
			
			n := nX
		
			If !Empty(aCols[n,GdFieldPos("C6_PRODUTO")]) .And. !aCols[nX,nUsado + 1]
	
				If cClassif == "E" .Or. cClassif == "I" //Carente Ou Indigente
					
					If Posicione("SB1",1,xFilial("SB1")+aCols[n,GdFieldPos("C6_PRODUTO")],"B1_TIPO") == "SV" //Servi�o
						cOper := Alltrim(cOpNFinNEst) //Opera��o n�o gera Financeiro, n�o movimenta Estoque
					Else
						cOper :=Alltrim(cOpNFinCEst) //Opera��o n�o gera Financeiro, movimenta Estoque
					Endif
				Else
					
					If Posicione("SB1",1,xFilial("SB1")+aCols[n,GdFieldPos("C6_PRODUTO")],"B1_TIPO") == "SV" //Servi�o
						cOper := Alltrim(cOpFinSEst) //Opera��o gera Financeiro, n�o movimenta Estoque
					Else
						cOper := Alltrim(cOpFinCEst) //Opera��o gera Financeiro, movimenta Estoque
					Endif
				Endif
			
				//Linha necess�ria para atualiza��o da informa��o de TES no Browse
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