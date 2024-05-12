#include "protheus.ch" 
#include "fwmvcdef.ch"

/*/{Protheus.doc} PUTIL006
Pontos de Entradda - Cadastro Empresas Integração
@author TOTVS
@since 03/01/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

/***********************/
User function PUTIL006()
/***********************/

Local xRet 			:= .T.

Local aParam 		:= PARAMIXB
Local oObj			:= aParam[1]
Local cIdPonto		:= aParam[2]

If cIdPonto == 'MODELPOS' .And. oObj:GetOperation() == 5 //Confirmação da exclusão


ElseIf cIdPonto == 'MODELPOS' .And. oObj:GetOperation() == 4 //Confirmação da alteração

	
Endif

Return xRet
