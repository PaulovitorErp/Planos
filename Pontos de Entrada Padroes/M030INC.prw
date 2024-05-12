
#INCLUDE "TOTVS.CH"

User Function M030INC()
	
    // se esta na rotina de agendamento
	If FWIsInCallStack("U_RUTIL49B")

		If U92->U92_TIPO $ "3|8" // cessionario ou responsavel financeiro

			BEGIN TRANSACTION

				If U92->(Reclock("U92", .F.))
					U92->U92_CLINOV := SA1->A1_COD
					U92->U92_LOJNOV := SA1->A1_LOJA
					U92->U92_NMCLIN	:= SA1->A1_NOME
					U92->(MsUnlock())
				Else
					lContinua := .F.
					U92->(DisarmTransaction())
					BREAK
				EndIf

			END TRANSACTION

		EndIf

	EndIf

Return( Nil )
