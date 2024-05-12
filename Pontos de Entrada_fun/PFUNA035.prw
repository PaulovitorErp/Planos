#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} PFUNA035

Ponto de entrada da rotina RFUNA035 - Numeros da Sorte

@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 11/01/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function PFUNA035()
/***********************/

Local aArea			:= GetArea()
Local aAreaUI1		:= UI1->(GetArea())
Local aParam 		:= PARAMIXB
Local oObj			:= aParam[1]
Local cIdPonto		:= aParam[2]
Local oModelUI1		:= oObj:GetModel("UI1MASTER")
Local lRet			:= .T.
local nLinhaAtu     := 0
local nI            := 0

// Na validação total do modelo
If cIdPonto == 'MODELPOS' .And. (oObj:GetOperation() == 5) //Confirmação da Inclusão ou Alteração
    
    // verifico o campo UI1_UTIL
    If val( oModelUI1:GetValue("UI1_UTIL") ) == 1
        // mensagem de help para o usuario
        Help( ,, 'Help - MODELPOS',, 'Numero da sorte ja utilizado, não é possível excluir o registro.', 1, 0 )
        lRet := .F.
    Endif

Endif

RestArea(aAreaUI1)
RestArea(aArea)

Return lRet