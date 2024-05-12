#Include 'Protheus.ch'

User Function IMPZFC()

Local aSay		:= {}
Local aBut		:= {}
Local lOk		:= .F.
Local cArquivo	:= ""

Private plFim	:= .F.
Private nReg    := 0
Private nRegImp	:= 0

// texto explicativo da rotina
aAdd(aSay, "Esta rotina tem por objetivo importar bairros para a tabela ZFC	  ")
//aAdd(aSay, "pelo usu�rio.                              		  								  ")

// botoes
aAdd(aBut, {14, .T., {|| cArquivo := RetPasta()} })		// Pega endere�o compelto com nome do arquivo
aAdd(aBut, {01, .T., {|| (lOk := .T., FechaBatch())} })	// Confirma
aAdd(aBut, {02, .T., {|| (lOk := .F., FechaBatch())} })	// Cancela

// abre a tela
FormBatch("Importa��o de Bairros", aSay, aBut)

If lOk
	If Empty(cArquivo)
		msgAlert("Arquivos de importa��o n�o encontrado '" + cArquivo + "'" + " - " + StrZero(ProcLine(), 5))
	Else
		Processa({|lEnd| ImpBairro(@lEnd, cArquivo)}, NIL, NIL, .T.)
		If plFim
			msgInfo("Importa��o cancelada pelo usu�rio!!", "Informa��o")
		Else
			If nRegImp > 0
				msgInfo("Importa��o conclu�da. "+CHR(13)+CHR(10)+AllTrim(STR(nRegImp))+" Bairros(es) Importado(s)!", "Informa��o")
			Else
				msgInfo("Nenhum registro importado.", "Informa��o")
			Endif
		EndIf
	EndIf
EndIf

Return

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa�RetPasta     �Autor�Andr� R. Barrero        � Data �  08/08/2016 ���
����������������������������������������������������������������������������͹��
���Desc.   �Importacao de Bairro						                     ���
����������������������������������������������������������������������������͹��
���Param.  �Nao ha                                                           ���
����������������������������������������������������������������������������͹��
���Retorno �Nao ha                                                           ���
����������������������������������������������������������������������������͹��
���Uso     �Programa chamado user function IMPZFC                            ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function RetPasta()                                                        //C:\Users\Ricardo\Documents\backup\totvs\Documents\Clientes\Marajo\docs\Importacao\cliente\

Local cArquivo	:= cGetFile( '*.xls*' , 'Selecione o arquivo para importa��o', 16, , .F.,GETF_LOCALHARD,.F., .T. )

Return(cArquivo)

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������ͻ��
���Programa�ImpBairro     �Autor�Andr� R. Barrero       � Data �  08/08/2016 ���
����������������������������������������������������������������������������͹��
���Desc.   �Importacao de bairro						                     ���
����������������������������������������������������������������������������͹��
���Param.  �Nao ha                                                           ���
����������������������������������������������������������������������������͹��
���Retorno �Nao ha                                                           ���
����������������������������������������������������������������������������͹��
���Uso     �Programa chamado user function IMPZFC                            ���
����������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/
Static Function ImpBairro(lEnd, cArquivo)

Local cPasta	:= SubStr(cArquivo,1,RAt("\",cArquivo))
Local cLog		:= "IMPZFC_"+DtoS(dDataBase)+"_"+SubStr(Time(),1,2)+"-"+SubStr(Time(),4,2)+"-"+SubStr(Time(),7,2)+".log"
Local i			:= 1

	//cria objeto
	oXls2Csv := XLS2CSV():New( cArquivo )
	If oXls2Csv:Import() //processa importa��o dos dados, gerando arquivo CSV
	   aDados := oXls2Csv:GetArray(1) //transforma arquivo CSV em array
	//fazer leitura dos dados
	EndIf

	//abre transacao
	//BeginTran()
	
		U_CriaLog(cPasta,cLog,"========================================================================================================")
		U_CriaLog(cPasta,cLog,">>>>>>>>>>>>>>> Log da Fun��o Importa Bairro - IMPZFC:"+cValToChar(dDataBase)+" "+cValToChar(time())+" <<<<<<<<<<<<<<<")
	
		If Len(aDados) > 0
			ProcRegua(Len(aDados))
			For i:=1 to Len(aDados)
				IncProc("Importando Bairros... Registro:" + cValToChar(i))
				
				DbSelectArea("ZFC")
				ZFC->( DbSetOrder(2) )//ZFC_FILIAL+ZFC_EST+ZFC_CODMUN+ZFC_BAIRRO
				If ZFC->( DbSeek(xFilial("ZFC")+aDados[i,2]+aDados[i,3]+aDados[i,5]) )
					U_CriaLog(cPasta,cLog,"J� IMPORTADO - C�digo do Mun�cipio IBGE:'"+aDados[i,3]+"', C�digo Bairro:'"+aDados[i,4]+"' e Desc.Bairro:'"+AllTrim(aDados[i,5])+"'")
				Else
					DbSelectArea("CC2")
					CC2->( DbSetOrder(1) )	//CC2_FILIAL+CC2_EST+CC2_CODMUN 
					If CC2->( DbSeek(xFilial("CC2")+aDados[i,2]+aDados[i,3]) )	//ExistChav('CC2',aDados[i,2]+aDados[i,3])
						
						//abre transacao
						BeginTran()
						
							//Grava Bairro
							RecLock("ZFC",.T.)
								ZFC->ZFC_FILIAL := xFilial("ZFC") 
								ZFC->ZFC_EST 	:= aDados[i,2]
								ZFC->ZFC_CODMUN := aDados[i,3]
								ZFC->ZFC_MUN	:= Posicione("CC2",1,xFilial("CC2")+aDados[i,2]+aDados[i,3],"CC2_MUN")
								ZFC->ZFC_CODBAI := CriaVar("ZFC_CODBAI")		
								ZFC->ZFC_BAIRRO := aDados[i,5]
							ZFC->(MsUnlock())
							
							nRegImp++
						
						//fecha transacao
						EndTran()
						
					Else
						U_CriaLog(cPasta,cLog,"C�digo do Mun�cipio IBGE:'"+aDados[i,3]+"', C�digo Bairro:'"+aDados[i,4]+"' e Desc.Bairro:'"+AllTrim(aDados[i,5])+"' N�o localizado!!!")
					EndIf
				EndIf
			Next i
		Else
			MsgInfo("N�o retornou informa��es do arquivo selecionado!")
		EndIf		
	//fecha transacao
	//EndTran()
	
	If nRegImp > 0
		U_CriaLog(cPasta,cLog,"Importa��o de Bairro conclu�da! Importado '"+cValToChar(nRegImp)+"' registros!")
	EndIf

Return

