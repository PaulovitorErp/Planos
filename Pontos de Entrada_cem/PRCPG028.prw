#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "topconn.ch"
 
/*
IDs dos Pontos de Entrada
-------------------------

MODELPRE 			Antes da alteração de qualquer campo do modelo. (requer retorno lógico)
MODELPOS 			Na validação total do modelo (requer retorno lógico)

FORMPRE 			Antes da alteração de qualquer campo do formulário. (requer retorno lógico)
FORMPOS 			Na validação total do formulário (requer retorno lógico)

FORMLINEPRE 		Antes da alteração da linha do formulário GRID. (requer retorno lógico)
FORMLINEPOS 		Na validação total da linha do formulário GRID. (requer retorno lógico)

MODELCOMMITTTS 		Apos a gravação total do modelo e dentro da transação
MODELCOMMITNTTS 	Apos a gravação total do modelo e fora da transação

FORMCOMMITTTSPRE 	Antes da gravação da tabela do formulário
FORMCOMMITTTSPOS 	Apos a gravação da tabela do formulário

FORMCANCEL 			No cancelamento do botão.

BUTTONBAR 			Para acrescentar botoes a ControlBar

MODELVLDACTIVE 		Para validar se deve ou nao ativar o Model

Parametros passados para os pontos de entrada:
PARAMIXB[1] - Objeto do formulário ou model, conforme o caso.
PARAMIXB[2] - Id do local de execução do ponto de entrada
PARAMIXB[3] - Id do formulário

Se for uma FORMGRID
PARAMIXB[4] - Linha da Grid
PARAMIXB[5] - Acao da Grid

*/

/*/{Protheus.doc} PFID023
	
@author Raphael Martins
@since 24/06/2016
@version 1.0		

@description

Ponto de Entrada da Tela de Controle de Carnês
/*/

User Function PRCPG028()

Local xRet     := .T.
Local aParam   := PARAMIXB
Local cIdPonto := ""   
Local oObj 

If aParam <> NIL 
	oObj       := aParam[1]
	cIdPonto   := aParam[2]
    
	If cIdPonto == 'MODELPOS'
		xRet := MODELPOS(oObj)
	EndIf
   
 EndIf
 
 Return(xRet)
 
 /*/{Protheus.doc} PFID023
	
@author Raphael Martins
@since 24/06/2016
@version 1.0		

@description

Ponto de Entrada na validacao da tela de controle de carnês
/*/
Static Function MODELPOS(oObj)

Local lRet		 := .T.
Local oModelU32  := oObj:GetModel( 'U32MASTER' ) 


//valido o conteudo dos campos de responsavel do recebimento e status do carnê
If oModelU32:GetValue('U32_STATUS') == '2' .And. ( Empty(oModelU32:GetValue('U32_RESPON')) .Or. Empty(oModelU32:GetValue('U32_DTRECE')) ) //ENTREGUE
	lRet := .F.
	Help(,,'Help',,"Informe o responsável e data de recebimento dos boletos!",1,0)
EndIf



Return(lRet)



 