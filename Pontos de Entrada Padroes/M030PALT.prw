#include 'protheus.ch'

/*/{Protheus.doc} M030PALT
Realiza validação de usuário, após a confirmação da alteração do cliente.
@author TOTVS
@since 19/09/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function M030PALT()
/***********************/
	
Local lRet			:=  .T.
Local nOpcao		:= PARAMIXB[1]
Local aArea			:= GetArea()
Local lRecorrencia	:= SuperGetMv("MV_XATVREC",.F.,.F.)

If nOpcao == 1 

	if lRecorrencia
		
		// função que verifica os contratos do cliente, para envio à vindi
		FWMsgRun(,{|oSay| U_UVIND10(SA1->A1_COD,SA1->A1_LOJA)},'Aguarde...','Verificando Contratos vinculados ao cliente...')
	
	endif
	
EndIf

RestArea(aArea)	

Return lRet
