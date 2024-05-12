#INCLUDE 'PROTHEUS.CH'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PFUNA001 ºAutor ³Wellington Gonçalves º Data ³  23/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada do cadastro de planos da funerária		  º±±
±±º          ³ 			                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funerária	                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PFUNA001()

	Local aArea			:= GetArea()
	Local aAreaUF2		:= UF2->(GetArea())
	Local aParam 		:= PARAMIXB
	Local oObj			:= aParam[1]
	Local cIdPonto		:= aParam[2]
	Local cIdModel		:= IIf( oObj<> NIL, oObj:GetId(), aParam[3] )
	Local cClasse		:= IIf( oObj<> NIL, oObj:ClassName(), '' )
	Local oModelUF0		:= oObj:GetModel( 'UF0MASTER' )
	Local lRet 			:= .T.
	Local lPlanoPet 	:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet

	If cIdPonto == "MODELVLDACTIVE" // abertura da tela

		if oObj:GetOperation() == 5 // se for exclusão

			UF2->(DbSetOrder(4)) // UF2_FILIAL + UF2_PLANO
			if UF2->(DbSeek(xFilial("UF2") + UF0->UF0_CODIGO))

				lRet := .F.
				Help(,1,"PFUNA001","PFUNA001")

			endif

		endif

	ElseIf cIdPonto == 'MODELPOS'

		If oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4 //Confirmação da alteração e inclusao

			// para o plano pet
			if lPlanoPet

				// verifico se o uso do plano
				if Empty(oModelUF0:GetValue("UF0_USO"))

					lRet := .F.
					Help( ,, 'PLANO',, 'O uso do plano deve ser definido, deve ser preenchido o campo '+ GetSx3Cache("UF0_USO","X3_TITULO") +'!', 1, 0 )
					
				endIf

			endIf

		endIf

	Endif

	RestArea(aAreaUF2)
	RestArea(aArea)

Return(lRet)
