#include "protheus.ch"
#include "topconn.ch"

#DEFINE CRLF CHR(10)+CHR(13)

/*/{Protheus.doc} PFUNA017
Pontos de Entrada do Apontamentos de Serviço
@author TOTVS
@since 26/08/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function PFUNA017()
/***********************/

Local aArea			:= GetArea()
Local aAreaUF2		:= UF2->(GetArea())
Local aAreaUF4		:= UF4->(GetArea())
Local aParam 		:= PARAMIXB
Local oObj			:= aParam[1]
Local cIdPonto		:= aParam[2]
Local oModelUG0		:= oObj:GetModel("UG0MASTER")
Local oModelUG1		:= oObj:GetModel("UG1DETAIL")
Local xRet 			:= .T.
Local lAux			:= .F.
Local lRet			:= .F.
Local cPv			:= ""

Local nI

If cIdPonto == 'MODELPOS' .And. (oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4) //Confirmação da Inclusão ou Alteração

	//Valida a seleção de ao menos um item
	For nI := 1 To oModelUG1:Length()

		// posiciono na linha atual
		oModelUG1:Goline(nI)  
	
		If !oModelUG1:IsDeleted()
		
			If oModelUG1:GetValue("UG1_OK")
				lAux := .T.
				Exit
			Endif 
		Endif
		
	Next
	
	If !lAux
		Help( ,, 'Help - MODELPOS',, 'Nenhum item apontado, operação não permitida.', 1, 0 )
		xRet := .F.
	Endif

	If xRet
		
		If oModelUG0:GetValue("UG0_CARENC") == "S"
		
			//Valida percentual de desconto informado
			If oModelUG0:GetValue("UG0_PERCDE") > nGetCalc
				Help( ,, 'Help - MODELPOS',, 'O percentual de desconto informado nos itens é menor que o percentual definido pelo Contrato, operação não permitida.', 1, 0 )
				xRet := .F.
			Endif
		Endif
	Endif

	
ElseIf cIdPonto == 'MODELCOMMITNTTS' //Após a gravação dos dados

	If oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4 //Inclusão ou Alteração
	
		If Empty(UG0->UG0_PV) //Não tenha gerado PV
		
			lAux := .F.
			
			//Valida a seleção de ao menos um item p/ PV
			For nI := 1 To oModelUG1:Length()
		
				// posiciono na linha atual
				oModelUG1:Goline(nI)  
			
				If !oModelUG1:IsDeleted()
				
					If oModelUG1:GetValue("UG1_OK") .And. oModelUG1:GetValue("UG1_PV") == "S" 
						lAux := .T.
						Exit
					Endif 
				Endif
			Next		
			
			If lAux
		
				If MsgYesNo("Deseja gerar Pedido de Venda?")
					
					BEGIN TRANSACTION
					
						MsgRun("Gerando Pedido de Venda...","Aguarde",{|| lRet := U_GeraPV_F(@cPv)})
						
						//Atualiza status
						If lRet
							RecLock("UG0",.F.)
							UG0->UG0_PV 	:= cPv
							UG0->UG0_STATUS := "P" //Gerou PV
							UG0->(MsUnlock())
						Endif
					
					END TRANSACTION

				Endif
			Endif
		Endif
		
		DbSelectArea("UF4")
		UF4->(DbSetOrder(1)) //UF4_FILIAL+UF4_CODIGO+UF4_ITEM
		
		If UF4->(DbSeek(xFilial("UF4")+UG0->UG0_CONTRA+UG0->UG0_CODBEN))
		
			RecLock("UF4",.F.)
			UF4->UF4_FALECI := UG0->UG0_DTFALE
			UF4->(MsUnlock())
			
		Endif
		
		// apenas se for a inclusão de um apontamento
		If oObj:GetOperation() == 3
		
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			/////////////////////////  CHAMO FUNÇÃO QUE VERIFICA SE O CONTRATO PODE SER FINALIZADO //////////////////////////
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			FWMsgRun(,{|oSay| U_RFUNA024(UG0->UG0_CONTRA)},'Aguarde...','Verificando o Status do Contrato da Funerária...')		
		
		endif		
	
	ElseIf oObj:GetOperation() == 5 //Exclusão

		DbSelectArea("UF4")
		UF4->(DbSetOrder(1)) //UF4_FILIAL+UF4_CODIGO+UF4_ITEM
		
		If UF4->(DbSeek(xFilial("UF4")+UG0->UG0_CONTRA+UG0->UG0_CODBEN))
		
			RecLock("UF4",.F.)
			UF4->UF4_FALECI := CToD("")
			UF4->(MsUnlock())
			
		Endif
		
		// posiciono no conrato
		UF2->(DbSetOrder(1)) // UF2_FILIAL + UF2_CODIGO
		if UF2->(DbSeek(xFilial("UF2") + UG0->UG0_CONTRA))
		
			// se o contrato estava com status de F=FINALIZADO
			// e está sendo excluido um apontamento
			if UF2->UF2_STATUS == "F"
	
				// volto seu status para A=ATIVO
				if RecLock("UF2",.F.)
					UF2->UF2_STATUS := "A"
					UF2->(MsUnlock())
					MsgInfo("Este contrato foi retornado para o Status Ativo!","Finalização de Contrato")
				endif
			
			endif
		
		endif
				
	Endif 
	
	//reprocesso saldo do contrato dos itens do contrato
	RepContrato(UG0->UG0_CONTRA)
	
Endif

RestArea(aAreaUF2)
RestArea(aAreaUF4)
RestArea(aArea)

Return xRet

/*/{Protheus.doc} RepContrato
Reprocessa saldo do contrato
@author TOTVS
@since 03/09/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function RepContrato(cContrato)

Local aArea 	:= GetArea()
Local aAreaUF2	:= UF2->(GetArea())
Local aAreaUG0	:= UG0->(GetArea())
Local aAreaUG1	:= UG1->(GetArea())
Local cQry 		:= ""

cQry := " SELECT " 
cQry += " UF3_PROD PRODUTO, "
cQry += " UF3_QUANT QTD_CONTRATO, "
cQry += " COALESCE(SUM(UG1_QUANT),0) QTD_OS " 
cQry += " FROM  "
cQry += " " + RetSQLName("UF3") + " UF3 "
cQry += " LEFT JOIN " + RetSQLName("UG0") + " UG0 "
cQry += " ON "
cQry += " UG0.D_E_L_E_T_ = ' ' " 
cQry += " AND UF3_FILIAL = UG0.UG0_FILIAL "
cQry += " AND UF3_CODIGO = UG0.UG0_CONTRA "
cQry += " LEFT JOIN " + RetSQLName("UG1") + " UG1 "
cQry += " ON "
cQry += " UG1.D_E_L_E_T_ = ' ' " 
cQry += " AND UG0_FILIAL = UG1.UG1_FILIAL "
cQry += " AND UG0_CODIGO = UG1.UG1_CODIGO "
cQry += " WHERE  "
cQry += " UF3.D_E_L_E_T_ = ' ' "
cQry += " AND UF3_FILIAL = '" + xFilial("UF3") + "' "
cQry += " AND UF3_CODIGO = '" + cContrato + "' "
cQry += " GROUP BY UF3_PROD,UF3_QUANT "

If Select("QSERV") > 0 
	QSERV->(DbCloseArea())
endif

TcQuery cQry New Alias "QSERV" 

UF3->(DbSetOrder(2)) //UF3_FILIAL+UF3_CODIGO+UF3_PRODUT

While QSERV->(!Eof())

	if UF3->(DbSeek(xFilial("UF3" ) + cContrato + QSERV->PRODUTO)) .And. UF3->UF3_CTRSLD == 'S'
		
		RecLock("UF3",.F.)
		
		UF3->UF3_SALDO := QSERV->QTD_CONTRATO - QSERV->QTD_OS 
		
		UF3->(MsUnlock())
		
	endif
	
	QSERV->(DbSkip())
	
EndDo


Return()
