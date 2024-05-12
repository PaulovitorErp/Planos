#Include "PROTHEUS.CH"
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RFUNA025 � Autor � Wellington Gon�alves � Data� 15/02/2017 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina de reativa��o de contrato da funer�ria			  ���
�������������������������������������������������������������������������͹��
���Uso       � Funer�ria	                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
/*/{Protheus.doc} RFUNA025
Rotina de reativa��o de contrato da funer�ria
@type function
@version 1.0
@author Wellington Gon�alves
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

	Case UF2->UF2_STATUS == "P" //Pr�-cadastro
		MsgInfo("O Contrato se encontra pr�-cadastrado, opera��o n�o permitida.","Aten��o")
		lContinua := .F.

	Case UF2->UF2_STATUS == "A" //Ativo
		MsgInfo("O Contrato j� se encontra Ativo, opera��o n�o permitida.","Aten��o")
		lContinua := .F.

	Case UF2->UF2_STATUS == "C" //Cancelado
		MsgInfo("O Contrato se encontra Cancelado, opera��o n�o permitida.","Aten��o")
		lContinua := .F.

	Case UF2->UF2_STATUS == "F" //Finalizado
		MsgInfo("O Contrato se encontra Finalizado, opera��o n�o permitida.","Aten��o")
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
			MsgAlert("Usu�rio sem permiss�o para reativar o contrato!", "Reativa��o")
		endIf

	endIf

	If lContinua

		If MsgYesNo("O Contrato ser� reativado, deseja continuar?")

			if RecLock("UF2",.F.)
				UF2->UF2_STATUS := "A" //Ativo
				UF2->(MsUnlock())
			endif

		Endif

		MsgInfo("Contrato reativado.","Aten��o")

	Endif

	restArea( aAreaUF2 )
	restArea( aAreaUF0 )
	restArea( aArea )

Return(Nil)
