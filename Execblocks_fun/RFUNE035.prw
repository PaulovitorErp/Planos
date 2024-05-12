#Include 'Protheus.ch'
#Include 'TopConn.ch'
#include "fwmvcdef.ch"

/*/{Protheus.doc} RFUNE035
Rotina de Cancelamento de OS
@author Raphael Martins Garcia
@since 06/08/2019
@version P12
@param nulo
@return nulo
/*/
User Function RFUNE035(nOpc)

Local lRet 			:= .T.
Local bExecRot 		:= {|| UFUNA34OK() }

INCLUI := nOpc == 1
ALTERA := nOpc == 2

//inclusao Orcamento
If nOpc == 1 

	FWExecView("ORCAMENTO",'RFUNA034', 3,, { || .T. })

elseif nOpc == 2

	If UJ0->UJ0_TPSERV == '3'

		FWExecView("EFETIVAR ORCAMENTO",'RFUNA034', 4,, { || .T. },bExecRot)
	else
		
		MsgInfo("Serviço não é um orcamento !")
	endif
else

	If UJ0->UJ0_TPSERV == '3'

		if Empty(UJ0->UJ0_CODCAN)

			CancelaOrcamento() // chamo rotina de cancelamento da OS
		else
			MsgInfo("Orcamento já esta cancelado !")
		Endif
		
	endif
endif

Return lRet

/*/{Protheus.doc} UFUNA034OK
Rotina executada na confirmacao da rotina de efetivacao de orcamento
@author Leandro Rodrigues
@since 06/08/2019
@version P12
@param nulo
@return nulo
/*/
Static Function UFUNA34OK()

Local oModel  	 	:= FWModelActive()
Local oModelUJ0	 	:= oModel:GetModel("UJ0MASTER")


//Atulizo o tipo do orcamento para 2=Particular
oModelUJ0:LoadValue("UJ0_TPSERV","2")

return .T.


/*/{Protheus.doc} CancelaOrcamento
Rotina para cancelamento de orcamento
@author Leandro Rodrigues
@since 06/08/2019
@version P12
@param nulo
@return nulo
/*/

Static Function CancelaOrcamento()


Local oCodCan	:= NIL
Local oMotCan	:= NIL
Local oDlgCan	:= NIL
Local cCodCan	:= Space(TamSX3("U31_CODIGO")[1])
Local cMotCan	:= Space(TamSX3("U31_DESCRI")[1])
Local lContinua	:= .T.
Local aArea     := GetArea()
Local aAreaUF2	:= UF2->(GetArea())
Local aAreaUJ0	:= UJ0->(GetArea())

 
DEFINE MSDIALOG oDlgCan TITLE "Cancelamento de Orcamento" From 0,0 TO 140,600 PIXEL
	
@ 005,005 SAY oSay1 PROMPT "Motivo" SIZE 030, 007 OF oDlgCan COLORS 0, 16777215 PIXEL
@ 018,005 MSGET oCodCan VAR cCodCan SIZE 040,007 PIXEL OF oDlgCan PICTURE "@!" Valid(ValidaMotivo(cCodCan,@cMotCan,oMotCan)) F3 "U31" HASBUTTON
	
@ 005,055 SAY oSay2 PROMPT "Descrição" SIZE 030, 007 OF oDlgCan COLORS 0, 16777215 PIXEL
@ 018,055 MSGET oMotCan VAR cMotCan SIZE 240,007 PIXEL OF oDlgCan PICTURE "@!" WHEN .F.
			
//Linha horizontal
@ 040, 005 SAY oSay3 PROMPT Repl("_",292) SIZE 292, 007 OF oDlgCan COLORS CLR_GRAY, 16777215 PIXEL
		
//Botoes
@ 051, 200 BUTTON oButton1 PROMPT "Confirmar" SIZE 040, 010 OF oDlgCan ACTION CancelaOS(cCodCan,cMotCan,oDlgCan) PIXEL  
@ 051, 250 BUTTON oButton2 PROMPT "Fechar" SIZE 040, 010 OF oDlgCan ACTION oDlgCan:End() PIXEL  
		
ACTIVATE MSDIALOG oDlgCan CENTERED
	
	
RestArea(aArea)
RestArea(aAreaUF2)
RestArea(aAreaUJ0)

Return()

/*/{Protheus.doc} CancelaOS
Confirmacao de Cancelamento de OS
@author Raphael Martins Garcia
@since 06/06/2019
@version P12
@param nulo
@return nulo
/*/
Static Function CancelaOS(cCodCan,cMotCan,oDlgCan)

Local lRet := .T.

// se o código estiver preenchido
If Empty(cCodCan)
	
	MsgInfo("Motivo de Cancelamento inválido.","Atenção")	
	lRet := .F.

else
	
	RecLock("UJ0",.F.)
	
	UJ0->UJ0_DTCA	:= dDatabase
	UJ0->UJ0_CODCAN	:= cCodCan
	UJ0->UJ0_DESCAN	:= cMotCan
	UJ0->UJ0_USRCAN	:= cUserName
	
	
	UJ0->(MsUnlock())
	
	MsgInfo("Cancelamento realizado com sucesso!","Atenção")	
	oDlgCan:End()
endif


Return()

/*/{Protheus.doc} MotivoCancelamentoValida
Confirmacao de Cancelamento de OS
@author Raphael Martins Garcia
@since 06/06/2019
@version P12
@param nulo
@return nulo
/*/
Static Function ValidaMotivo(cCodCan,cMotCan,oMotCan)

Local lRet := .T.

// limpo o campo da descrição do cancelamento
cMotCan := Space(TamSX3("U31_DESCRI")[1])

// se o código estiver preenchido
If !Empty(cCodCan)
	
	U31->(DbSetOrder(1)) // U31_FILIAL + U31_CODIGO
	If U31->(DbSeek(xFilial("U31") + cCodCan))
		cMotCan := U31->U31_DESCRI	
	Else
		MsgInfo("Motivo de Cancelamento inválido.","Atenção")	
		lRet := .F.
	Endif
		
Endif

oMotCan:Refresh()

Return lRet
