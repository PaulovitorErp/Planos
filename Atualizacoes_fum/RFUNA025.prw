#Include "PROTHEUS.CH"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFUNA025 º Autor ³ Wellington Gonçalves º Data³ 15/02/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de reativação de contrato da funerária			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funerária	                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/*/{Protheus.doc} RFUNA025
Rotina de reativação de contrato da funerária
@type function
@version 1.0
@author Wellington Gonçalves
@since 15/02/2017
@return variant, return_description
/*/
User Function RFUNA025()

	Local aArea			:= getArea()
	Local aAreaUF0		:= UF0->( getArea() )
	Local aAreaUF2		:= UF2->( getArea() )
	Local cPermitidos	:= Alltrim(SuperGetMv("MV_XGRPCAR",,"")) //Grupos de Usuarios que podem alterar a carencia do contrato
	Local lContinua 	:= .T.
	Local nI			:= 0

	Do Case

	Case UF2->UF2_STATUS == "P" //Pré-cadastro
		MsgInfo("O Contrato se encontra pré-cadastrado, operação não permitida.","Atenção")
		lContinua := .F.

	Case UF2->UF2_STATUS == "A" //Ativo
		MsgInfo("O Contrato já se encontra Ativo, operação não permitida.","Atenção")
		lContinua := .F.

	Case UF2->UF2_STATUS == "C" //Cancelado
		MsgInfo("O Contrato se encontra Cancelado, operação não permitida.","Atenção")
		lContinua := .F.

	Case UF2->UF2_STATUS == "F" //Finalizado
		MsgInfo("O Contrato se encontra Finalizado, operação não permitida.","Atenção")
		lContinua := .F.

	EndCase

	if lContinua

		//Retorno o grupo do usuario logado
		aGrupoUsr := UsrRetGrp(RetCodUsr())

		for nI := 1 To Len(aGrupoUsr)

			if aGrupoUsr[nI] $ cPermitidos

				lContinua := .T.

			else

				lContinua := .F.

			endif

		next nI

		if !lContinua
			MsgAlert("Usuário sem permissão para reativar o contrato!", "Reativação")
		endIf

	endIf

	If lContinua

		If MsgYesNo("O Contrato será reativado, deseja continuar?")

			if RecLock("UF2",.F.)
				UF2->UF2_STATUS := "A" //Ativo
				UF2->(MsUnlock())
			endif

		Endif

		MsgInfo("Contrato reativado.","Atenção")

	Endif

	restArea( aAreaUF2 )
	restArea( aAreaUF0 )
	restArea( aArea )

Return(Nil)
