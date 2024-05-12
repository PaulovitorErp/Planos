#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} RFUNA006
Transfer�ncia de Titularidade
@author TOTVS
@since 21/07/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RFUNA006()
	/***********************/

	Local lContinua 	:= .T.

	Private nLinNewTit	:= 0

	Do Case

		Case UF2->UF2_STATUS == "P" //Pr�-cadastro
		MsgInfo("O Contrato se encontra pr�-cadastrado, opera��o n�o permitida.","Aten��o")
		lContinua := .F.

		Case UF2->UF2_STATUS == "S" //Suspenso
		MsgInfo("O Contrato se encontra Suspenso, opera��o n�o permitida.","Aten��o")
		lContinua := .F.

		Case UF2->UF2_STATUS == "C" //Cancelado
		MsgInfo("O Contrato se encontra Cancelado, opera��o n�o permitida.","Aten��o")
		lContinua := .F.

		Case UF2->UF2_STATUS == "F" //Finalizado
		MsgInfo("O Contrato se encontra Finalizado, opera��o n�o permitida.","Aten��o")
		lContinua := .F.

	EndCase

	If lContinua

		//-- Verifica se existe pendencias de processamentos VINDI --//
		If U_PENDVIND(UF2->UF2_CODIGO, "F")
		
			//valido se o contrato possui titulo em cobranca, caso possua nao sera possivel realizar a transferencia
			if U_VldCobranca(xFilial("SE1"),UF2->UF2_CODIGO)

				If U_AdimpFun(UF2->UF2_CODIGO) //Se adimplente
				
					FWExecView('TRANSFERENCIA DE TITULARIDADE',"RFUNA002",4,,{|| .T. })

					MsgInfo("Transfer�ncia de Titularidade Finalizada.","Aten��o")
				Else
					MsgInfo("O Titular atual se encontra inadimplente, opera��o n�o permitida.","Aten��o")
				Endif
			
			else
				
				lContinua := .F.
				MsgInfo("O Contrato possui titulos em cobran�a, opera��o cancelada.","Aten��o")

			endif

		EndIf

	Endif

Return

/********************************/
User Function AdimpFun(cContrato)
/********************************/

Local lRet := .T.

DbSelectArea("SE1")
SE1->(DbOrderNickName("E1_XCTRFUN")) //E1_FILIAL+E1_XCTRFUN
SE1->(DbGoTop())

If SE1->(MsSeek(xFilial("SE1")+UF2->UF2_CODIGO))

	While SE1->(!EOF()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_XCTRFUN == UF2->UF2_CODIGO

		If SE1->E1_VENCREA < dDataBase .And. SE1->E1_SALDO > 0 //Inadimplente
			lRet := .F.
		Endif
		
		SE1->(DbSkip())
	EndDo
Endif

Return lRet
