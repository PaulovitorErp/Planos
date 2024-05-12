#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFUNE004 º Autor ³ Wellington Gonçalves º Data³ 20/02/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função chamada na validação do código do produto do pedido º±±
±±			 ³ de venda, está sendo utilizado para preencher gatilhar o   º±±
±±			 ³ código ISS do item, de acordo com a classificação do pedidoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funerária	                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RFUNE004(cProd)
	
Local lRet 			:= .T.
Local cCodIss		:= ""
Local cMsgErro		:= ""
Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local nLinhaSC6		:= N
Local cClassif		:= M->C5_XCLASSI 

// validação apenas para o módulo da funerária
if lFuneraria

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

		If cClassif == "E" .Or. cClassif == "I" //Carente Ou Indigente
			
			If Posicione("SB1",1,xFilial("SB1")+cProd,"B1_TIPO") == "SV" //Serviço
				cOper := SuperGetMv("MV_XOPFNEN",.F.,"10") //Operação não gera Financeiro, não movimenta Estoque
			Else
				cOper := SuperGetMv("MV_XOPFNES",.F.,"11") //Operação não gera Financeiro, movimenta Estoque
			Endif
		Else
			
			If Posicione("SB1",1,xFilial("SB1")+cProd,"B1_TIPO") == "SV" //Serviço
				cOper := SuperGetMv("MV_XOPFSEN",.F.,"08") //Operação gera Financeiro, não movimenta Estoque
			Else
				cOper := SuperGetMv("MV_XOPFSES",.F.,"09") //Operação gera Financeiro, movimenta Estoque
			Endif
		Endif
	
		//Linha necessária para atualização da informação de TES no Browse
		cTes := MaTesInt(2,AllTrim(cOper),M->C5_CLIENTE,M->C5_LOJACLI,IIf(M->C5_TIPO$'DB',"F","C"),cProd,"C6_TES")

		GdFieldPut("C6_OPER", cOper,nLinhaSC6) 
		GdFieldPut("C6_TES", cTes,nLinhaSC6) 
		GdFieldPut("C6_CODISS", cCodIss, nLinhaSC6)
	endif	
endif
	
Return(lRet)