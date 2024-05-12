#Include "Totvs.ch"

/*/{Protheus.doc} RCPGE034
Rotina para preparar liquidacao de titulos
@author g.sampaio
@since 29/05/2020
@version P12
@param nulo
@return nulo
/*/
User Function RCPGE034( cContrato )

    Local aArea         := GetArea()
    Local aAreaU00      := U00->( GetArea() )
    Local aAreaSE1      := SE1->( GetArea() )
    Local cPrefixo 		:= SuperGetMv("MV_XPREFCT",.F.,"CEM")
    Local lContinua     := .T.

    Default cContrato   := ""

    // posiciono no contrato
    U00->( DbSetOrder(1) )
    If !Empty(cContrato) .And. U00->( MsSeek( xFilial("U00")+cContrato ) )

        Do Case

        Case lContinua .And. U00->U00_STATUS == "P" //Pré-cadastro
            
            // mensagem para o usuario
            MsgAlert("O Contrato se encontra pré-cadastrado, operação não permitida.","Atenção")
            lContinua   := .F.

        Case lContinua .And. U00->U00_STATUS == "C" //Cancelado

            // mensagem para o usuario
            MsgAlert("O Contrato se encontra Cancelado, operação não permitida.","Atenção")
            lContinua   := .F.

        Case lContinua .And. cFilAnt <> U00->U00_MSFIL // se filial e diferente

            // mensagem para o usuario
            MsgAlert("Esta operação deverá ser realizada na filial onde foi incluido o contrato.","Atenção")
            lContinua   := .F.

        EndCase

        //Posiciono no  titulo do contrato para que rotina de liquidacao
        //carrega informacoes do cliente na tela de filtro
		oVirtusFin := VirtusFin():New()

		if lContinua .And. SE1->(oVirtusFin:SeekSE1("C", U00->U00_CODIGO))
			FINA460(2)
		Endif

    Else

        // mensagem para o usuario
        MsgAlert("Contrato não encontrado, por favor tente novamente!")

    Endif

    RestArea( aAreaSE1 )
    RestArea( aAreaU00 )    
    RestArea( aArea )

Return(Nil)
