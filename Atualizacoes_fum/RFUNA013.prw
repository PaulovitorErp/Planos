#Include 'Protheus.ch'

/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͺ��
���Programa  � RFUNA013 � Autor � Wellington Gon�alves		   � Data� 05/08/2016 ���
���������������������������������������������������������������������������������ͺ��
���Desc.     � Consulta espec�fica Multi sele��o de planos da funer�ria			  ���
���������������������������������������������������������������������������������ͺ��
���Uso       � Vale do Cerrado                    			                      ���
���������������������������������������������������������������������������������ͺ��
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/

User Function RFUNA013()

Local cTitulo	:= "Cadastro de Planos"
Local MvParDef	:= ""
Local MvRetor	:= ""      
Local cVarIni	:= ""
Local nX		:= 1
Local nTamCod	:= TamSX3("UF0_CODIGO")[1]
Local aDados	:= {}

cVarIni := &(Alltrim(ReadVar()))

UF0->(DbSetOrder(1)) // UF0_FILIAL + UF0_CODIGO 
If UF0->(DbSeek(xFilial("UF0")))

	While UF0->(!Eof()) .AND. UF0->UF0_FILIAL == xFilial("UF0")
		
		aadd(aDados, AllTrim(UF0->UF0_CODIGO) + " - " + AllTrim(UF0->UF0_DESCRI))
		MvParDef += AllTrim(UF0->UF0_CODIGO)
		UF0->(DbSkip())
		
	Enddo
	
Endif

If F_Opcoes(@cVarIni, cTitulo, aDados, MvParDef, 12, 49, .F., nTamCod, 36)
	
	For nX := 1 To Len(cVarIni) Step nTamCod
	
		If substr(cVarIni, nX, nTamCod) # "******"
			
			If !Empty(MvRetor)
				MvRetor += ";"
			EndIf
			
			MvRetor += substr(cVarIni,nX,nTamCod)
			
		EndIf
		
	Next nX
	
EndIf

&(ReadVar()) := MvRetor 

Return(.T.)
