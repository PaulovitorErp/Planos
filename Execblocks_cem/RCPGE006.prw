#include "protheus.ch" 

/*/{Protheus.doc} RCPGE006
Valida situa��o financeira do Contrato e chama impress�o do Termo de Quita��o
@author TOTVS
@since 19/08/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RCPGE006()
/***********************/

Local lContinua		:= .F.
Local aProdJazigo 	:= StrTokArr2(SuperGetMv("MV_XPRDJZG",.F.,"000238"),"/")

DbSelectArea("U01")
U01->(DbSetOrder(1)) //U01_FILIAL+U01_CODIGO+U01_ITEM

If U01->(DbSeek(xFilial("U01")+U00->U00_CODIGO))

	While U01->(!EOF()) .And. U01->U01_FILIAL == xFilial("U01") .And. U01->U01_CODIGO == U00->U00_CODIGO
	
		If aScan(aProdJazigo,{|x| x == AllTrim(U01->U01_PRODUT)}) > 0
			 lContinua := .T.
			 Exit
		Endif
		
		U01->(DbSkip())
	EndDo
	
	If !lContinua
		MsgInfo("N�o se trata de um contrato de jazigo, situa��o necess�ria para impress�o do termo.","Aten��o")
	Endif
Endif

If lContinua

	If !ContrQuit(U00->U00_CODIGO)
		MsgInfo("O contrato n�o se encontra quitado, situa��o necess�ria para impress�o do termo.","Aten��o")
	Else
		U_RCPGR024()	
	Endif
Endif

Return

/*********************************/
Static Function ContrQuit(cContrato)
/*********************************/

Local lRet 		:= .T.

Local cTipo		:= Alltrim(SuperGetMv("MV_XTIPOCT",.F.,"AT"))
Local cTipoEnt	:= Alltrim(SuperGetMv("MV_XTIPOEN",.F.,"ENT"))

DbSelectArea("SE1")
SE1->(DbOrderNickName("XCTRCEM")) //E1_FILIAL+E1_XCONTRA
SE1->(DbGoTop())

If SE1->(DbSeek(xFilial("SE1")+U00->U00_CODIGO))

	While SE1->(!EOF()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_XCONTRA == U00->U00_CODIGO

		If SE1->E1_SALDO > 0 .And. (Alltrim(SE1->E1_TIPO) == cTipo .Or. Alltrim(SE1->E1_TIPO) == cTipoEnt) //T�tulo em aberto E ser parcela do Contrato
			lRet := .F.
			Exit
		Endif
		
		SE1->(DbSkip())
	EndDo
Endif

Return lRet
