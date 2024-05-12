#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "topconn.ch"
 
/*
IDs dos Pontos de Entrada
-------------------------

MODELPRE 			Antes da altera��o de qualquer campo do modelo. (requer retorno l�gico)
MODELPOS 			Na valida��o total do modelo (requer retorno l�gico)

FORMPRE 			Antes da altera��o de qualquer campo do formul�rio. (requer retorno l�gico)
FORMPOS 			Na valida��o total do formul�rio (requer retorno l�gico)

FORMLINEPRE 		Antes da altera��o da linha do formul�rio GRID. (requer retorno l�gico)
FORMLINEPOS 		Na valida��o total da linha do formul�rio GRID. (requer retorno l�gico)

MODELCOMMITTTS 		Apos a grava��o total do modelo e dentro da transa��o
MODELCOMMITNTTS 	Apos a grava��o total do modelo e fora da transa��o

FORMCOMMITTTSPRE 	Antes da grava��o da tabela do formul�rio
FORMCOMMITTTSPOS 	Apos a grava��o da tabela do formul�rio

FORMCANCEL 			No cancelamento do bot�o.

BUTTONBAR 			Para acrescentar botoes a ControlBar

MODELVLDACTIVE 		Para validar se deve ou nao ativar o Model

Parametros passados para os pontos de entrada:
PARAMIXB[1] - Objeto do formul�rio ou model, conforme o caso.
PARAMIXB[2] - Id do local de execu��o do ponto de entrada
PARAMIXB[3] - Id do formul�rio

Se for uma FORMGRID
PARAMIXB[4] - Linha da Grid
PARAMIXB[5] - Acao da Grid

*/

/*/{Protheus.doc} PFID023
	
@author Raphael Martins
@since 24/06/2016
@version 1.0		

@description

Ponto de Entrada da Tela de Controle de Carn�s
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

Ponto de Entrada na validacao da tela de controle de carn�s
/*/
Static Function MODELPOS(oObj)

Local lRet		 := .T.
Local oModelU32  := oObj:GetModel( 'U32MASTER' ) 


//valido o conteudo dos campos de responsavel do recebimento e status do carn�
If oModelU32:GetValue('U32_STATUS') == '2' .And. ( Empty(oModelU32:GetValue('U32_RESPON')) .Or. Empty(oModelU32:GetValue('U32_DTRECE')) ) //ENTREGUE
	lRet := .F.
	Help(,,'Help',,"Informe o respons�vel e data de recebimento dos boletos!",1,0)
EndIf



Return(lRet)



 