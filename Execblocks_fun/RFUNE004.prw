#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFUNE004 � Autor � Wellington Gon�alves � Data� 20/02/2017 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o chamada na valida��o do c�digo do produto do pedido ���
��			 � de venda, est� sendo utilizado para preencher gatilhar o   ���
��			 � c�digo ISS do item, de acordo com a classifica��o do pedido���
�������������������������������������������������������������������������͹��
���Uso       � Funer�ria	                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function RFUNE004(cProd)
	
Local lRet 			:= .T.
Local cCodIss		:= ""
Local cMsgErro		:= ""
Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local nLinhaSC6		:= N
Local cClassif		:= M->C5_XCLASSI 

// valida��o apenas para o m�dulo da funer�ria
if lFuneraria

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

		If cClassif == "E" .Or. cClassif == "I" //Carente Ou Indigente
			
			If Posicione("SB1",1,xFilial("SB1")+cProd,"B1_TIPO") == "SV" //Servi�o
				cOper := SuperGetMv("MV_XOPFNEN",.F.,"10") //Opera��o n�o gera Financeiro, n�o movimenta Estoque
			Else
				cOper := SuperGetMv("MV_XOPFNES",.F.,"11") //Opera��o n�o gera Financeiro, movimenta Estoque
			Endif
		Else
			
			If Posicione("SB1",1,xFilial("SB1")+cProd,"B1_TIPO") == "SV" //Servi�o
				cOper := SuperGetMv("MV_XOPFSEN",.F.,"08") //Opera��o gera Financeiro, n�o movimenta Estoque
			Else
				cOper := SuperGetMv("MV_XOPFSES",.F.,"09") //Opera��o gera Financeiro, movimenta Estoque
			Endif
		Endif
	
		//Linha necess�ria para atualiza��o da informa��o de TES no Browse
		cTes := MaTesInt(2,AllTrim(cOper),M->C5_CLIENTE,M->C5_LOJACLI,IIf(M->C5_TIPO$'DB',"F","C"),cProd,"C6_TES")

		GdFieldPut("C6_OPER", cOper,nLinhaSC6) 
		GdFieldPut("C6_TES", cTes,nLinhaSC6) 
		GdFieldPut("C6_CODISS", cCodIss, nLinhaSC6)
	endif	
endif
	
Return(lRet)