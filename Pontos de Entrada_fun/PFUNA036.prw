#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} PFUNA036

Ponto de entrada da rotina RFUNA036 - Cadastro de Plano de Seguro

@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 11/01/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function PFUNA036()
/***********************/

Local aArea			:= GetArea()
Local aAreaUI2		:= UI2->(GetArea())
Local aAreaUI3		:= UI3->(GetArea())
Local aParam 		:= PARAMIXB
Local oObj			:= aParam[1]
Local cIdPonto		:= aParam[2]
Local oModelUI2		:= oObj:GetModel("UI2MASTER")
Local oModelUI3		:= oObj:GetModel("UI3DETAIL")
Local lRet			:= .T.
local nLinhaAtu     := 0
local nI            := 0

// Na validação total do modelo
If cIdPonto == 'MODELPOS' .And. (oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4) //Confirmação da Inclusão ou Alteração
    
    // caso o tipo de plano de contrato for diferente de faixa etaria, desabilito a grid
    if oModelUI2:GetValue("UI2_TIPO") == "2"
        
        // salvo a linha atual
        nLinhaAtu := oModelUI3:GetLine()

        // vou percorrer as linhas da grid
        For nI := 1 To oModelUI3:Length()
            
            // posiciono na linha percorrida
            oModelUI3:GoLine(nI)

            // verifico se e inclusao ou alteracao
            If oModelUI3:IsInserted() .Or. oModelUI3:IsUpdated()  

                // valido o preenchimento do campo idade inicial
                if oModelUI3:GetValue("UI3_IDAINI") == 0 .and. lRet
                	Help( ,, 'Help - MODELPOS',, 'Nenhum item apontado, operação não permitida.', 1, 0 )
		            lRet := .F.
                endIf
            EndIf
        Next nI

        // retorno para linha que estava posicionado antes
        oModelUI3:GoLine(nLinhaAtu)
    
    elseIf oModelUI2:GetValue("UI2_TIPO") == "1" // validacao para quando o tipo for 1 - Fixo

        // verifico se a quantidade de remissivo foi preenchida
        if oModelUI2:GetValue("UI2_QTDREM") <= 0
            Help( ,, 'Help - MODELPOS',, 'Campo <b>Qt Remissivo</b> com valor menor ou igual a Zero, preencha ', 1, 0 )
		    lRet := .F.       
        endIf

    endIf
Endif

RestArea(aAreaUI2)
RestArea(aAreaUI3)
RestArea(aArea)

Return lRet