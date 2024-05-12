#Include "Totvs.ch"

/*/{Protheus.doc} RFUNE043
Rotina para preparar liquidacao de titulos
Fonte para substituir o programa RFUNA050, apenas para seguir 
o modo correto de nomenclatura dos programas.
@author Leandro Rodrigues
@since 17/07/2019
@version P12
@param nulo
@return nulo
/*/
User Function RFUNE043(cContrato)

	Local aArea			:= GetArea()
	Local aAreaSE1		:= SE1->( GetArea() )
	Local aAreaUF2		:= UF2->( GetArea() )
	Local lContinua		:= .T.
	Local oVirtusFin	:= Nil

	Default cContrato	:= ""

	SE1->(DbSetOrder(1))

	// posiciono no contrato
	UF2->( DbSetOrder(1) )
	If !Empty(cContrato) .And. UF2->( MsSeek( xFilial("UF2")+cContrato ) )

		Do Case

		Case lContinua .And. UF2->UF2_STATUS == "P" //Pré-cadastro
			MsgInfo("O Contrato se encontra pré-cadastrado, operação não permitida.","Atenção")
			lContinua	:= .F.

		Case lContinua .And. UF2->UF2_STATUS == "C" //Cancelado
			MsgInfo("O Contrato se encontra Cancelado, operação não permitida.","Atenção")
			lContinua	:= .F.

		Case lContinua .And. cFilAnt != UF2->UF2_MSFIL
			MsgInfo("Esta operação deverá ser realizada na filial onde foi incluido o contrato.","Atenção")
			lContinua	:= .F.

		EndCase

		oVirtusFin := VirtusFin():New()

		//Posiciono no  titulo do contrato para que rotina de liquidacao
		//carrega informacoes do cliente na tela de filtro
		if lContinua .And. SE1->(oVirtusFin:SeekSE1("F", UF2->UF2_CODIGO))
			FINA460(2)
		Endif

	EndIf

	RestArea( aAreaUF2 )
	RestArea( aAreaSE1 )
	RestArea( aArea )

Return(Nil)
