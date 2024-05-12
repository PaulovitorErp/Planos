#INCLUDE 'totvs.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} CRMA980
Ponto de Entrada da rotina de cadastro de cliente em modelo MVC
A rotina MATA030 esta descontinuada.
@type function
@version 1.0
@author Raphael Martins
@since 18/09/2022
/*/

User Function CRMA980()
	Local aParam        := PARAMIXB
	Local xRet          := .T.
	Local cIDPonto      := ''
	Local cIDModel      := ''
	Local oObj          := NIL
	Local aArea			:= GetArea()
	Local lRecorrencia	:= SuperGetMv("MV_XATVREC",.F.,.F.)
	Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)

	If aParam <> NIL

		oObj        := aParam[1]
		cIDPonto    := aParam[2]
		nOperation := oObj:GetOperation()

		if cIdPonto == "MODELPOS" // na validação na confirmação do cadastro

			if nOperation == 5

				//funcao para nao permitir excluir clientes com contratos vinculados
				if ExistBlock("RUTILE63")
					xRet := U_RUTILE63()
				endif

			endif

		elseif cIDPonto == 'MODELCOMMITTTS'

			//alteracao do registro
			If nOperation == 3

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

			Elseif nOperation == 4

				If lCemiterio

					//altero os dados do contrato do cliente
					If ExistBlock("RCPGE007")
						U_RCPGE007(SA1->A1_COD,SA1->A1_LOJA)
					EndIf

				elseif lFuneraria

					//altero os dados do contrato do cliente
					If ExistBlock("RFUNE034")
						U_RFUNE034(SA1->A1_COD,SA1->A1_LOJA)
					EndIf

				Endif

				if lRecorrencia
					// função que verifica os contratos do cliente, para envio à vindi
					FWMsgRun(,{|oSay| U_UVIND10(SA1->A1_COD,SA1->A1_LOJA)},'Aguarde...','Verificando Contratos vinculados ao cliente...')
				endif

			endif

		endif

	endif

	RestArea(aArea)

Return xRet
