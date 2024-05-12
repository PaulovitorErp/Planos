#include "protheus.ch"

/*/{Protheus.doc} RCPGA040
Rotina Inclusão do Apontamento de Serviço a partir do Contrato
@author Leandro Rodrigues
@since 16/12/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function RCPGA040(nOpc, lConsCliente)

	Local aArea 	    := GetArea()
	Local cName         := Funname()
	Local lCadContrato  := iif( AllTrim(cName) $ "RCPGA001", .T., .F. ) // verifico se estou no cadastro de contratos
	Local lContinua     := .T.

	Default lConsCliente    := .F.

	//Chama rotina de apontamento do contrato
	if nOpc == 1

		Do Case

		Case U00->U00_STATUS == "P" //Pré-cadastro
			MsgInfo("O Contrato se encontra pré-cadastrado, operação não permitida.","Atenção")
			lContinua := .F.

		Case U00->U00_STATUS == "C" //Cancelado
			MsgInfo("O Contrato se encontra Cancelado, operação não permitida.","Atenção")
			lContinua := .F.

		Case U00->U00_STATUS == "S" //Suspenso
			MsgInfo("O Contrato se encontra Suspenso, operação não permitida.","Atenção")
			lContinua := .F.

		Case ExigTxManu(U00->U00_PLANO) .And. U00->U00_TXMANU <= 0 //contrato sem taxa de manutencao
			MsgAlert("O Contrato não possui valor de taxa de manutenção definido, operação não permitida.","Atenção")
			lContinua := .F.

		EndCase

		INCLUI := .T.
		ALTERA := .F.

		// valido se devo continuar a executar a rotina
		if lContinua

			SetFunName("RCPGA039")
			FWExecView('INCLUIR',"RCPGA039",3,,{|| .T. })

			If !lConsCliente

				// apos a inclusao abro a rotina de historico, para facilitar o uso e continuidade do processo
				U_RCPGA039(lCadContrato, U00->U00_CODIGO) // passo o parametro .T. que

			EndIf

			SetFunName(cName)

		endIf

	else

		SetFunName("RCPGA039")
		U_RCPGA039(lCadContrato) // passo o parametro .T. que
		SetFunName(cName)

	endif

	RestArea(aArea)

Return

/*/{Protheus.doc} RCPGA040
Rotina para verificar se Plano exige 
preenchimento de taxa de manutencao
@author Leandro Rodrigues
@since 16/12/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

Static Function ExigTxManu( cPlanoCtr )

	Local aArea			:= GetArea()
	Local aAreaU00		:= U00->( GetArea() )
	Local aAreaU05		:= U05->( GetArea() )
	Local lExigeTxMnt	:= .F.

	U05->( DbSetOrder(1) ) //U05_FILIAL + U05_CODIGO

	//valido se o plano exige o preenchimento do campo de taxa de manutencao
	If U05->( DbSeek( xFilial("U05") + cPlanoCtr ) ) .And. U05->U05_EXIMNT == 'S'
		lExigeTxMnt	:= .T.
	EndIf

	RestArea(aArea)
	RestArea(aAreaU00)
	RestArea(aAreaU05)

Return(lExigeTxMnt)
