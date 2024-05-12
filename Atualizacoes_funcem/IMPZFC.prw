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
//aAdd(aSay, "pelo usuário.                              		  								  ")

// botoes
aAdd(aBut, {14, .T., {|| cArquivo := RetPasta()} })		// Pega endereço compelto com nome do arquivo
aAdd(aBut, {01, .T., {|| (lOk := .T., FechaBatch())} })	// Confirma
aAdd(aBut, {02, .T., {|| (lOk := .F., FechaBatch())} })	// Cancela

// abre a tela
FormBatch("Importação de Bairros", aSay, aBut)

If lOk
	If Empty(cArquivo)
		msgAlert("Arquivos de importação não encontrado '" + cArquivo + "'" + " - " + StrZero(ProcLine(), 5))
	Else
		Processa({|lEnd| ImpBairro(@lEnd, cArquivo)}, NIL, NIL, .T.)
		If plFim
			msgInfo("Importação cancelada pelo usuário!!", "Informação")
		Else
			If nRegImp > 0
				msgInfo("Importação concluída. "+CHR(13)+CHR(10)+AllTrim(STR(nRegImp))+" Bairros(es) Importado(s)!", "Informação")
			Else
				msgInfo("Nenhum registro importado.", "Informação")
			Endif
		EndIf
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma³RetPasta     ºAutor³André R. Barrero        º Data ³  08/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³Importacao de Bairro						                     º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.  ³Nao ha                                                           º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno ³Nao ha                                                           º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso     ³Programa chamado user function IMPZFC                            º±±
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetPasta()                                                        //C:\Users\Ricardo\Documents\backup\totvs\Documents\Clientes\Marajo\docs\Importacao\cliente\

Local cArquivo	:= cGetFile( '*.xls*' , 'Selecione o arquivo para importação', 16, , .F.,GETF_LOCALHARD,.F., .T. )

Return(cArquivo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma³ImpBairro     ºAutor³André R. Barrero       º Data ³  08/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.   ³Importacao de bairro						                     º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParam.  ³Nao ha                                                           º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno ³Nao ha                                                           º±±
±±ÌÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso     ³Programa chamado user function IMPZFC                            º±±
±±ÈÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpBairro(lEnd, cArquivo)

Local cPasta	:= SubStr(cArquivo,1,RAt("\",cArquivo))
Local cLog		:= "IMPZFC_"+DtoS(dDataBase)+"_"+SubStr(Time(),1,2)+"-"+SubStr(Time(),4,2)+"-"+SubStr(Time(),7,2)+".log"
Local i			:= 1

	//cria objeto
	oXls2Csv := XLS2CSV():New( cArquivo )
	If oXls2Csv:Import() //processa importação dos dados, gerando arquivo CSV
	   aDados := oXls2Csv:GetArray(1) //transforma arquivo CSV em array
	//fazer leitura dos dados
	EndIf

	//abre transacao
	//BeginTran()
	
		U_CriaLog(cPasta,cLog,"========================================================================================================")
		U_CriaLog(cPasta,cLog,">>>>>>>>>>>>>>> Log da Função Importa Bairro - IMPZFC:"+cValToChar(dDataBase)+" "+cValToChar(time())+" <<<<<<<<<<<<<<<")
	
		If Len(aDados) > 0
			ProcRegua(Len(aDados))
			For i:=1 to Len(aDados)
				IncProc("Importando Bairros... Registro:" + cValToChar(i))
				
				DbSelectArea("ZFC")
				ZFC->( DbSetOrder(2) )//ZFC_FILIAL+ZFC_EST+ZFC_CODMUN+ZFC_BAIRRO
				If ZFC->( DbSeek(xFilial("ZFC")+aDados[i,2]+aDados[i,3]+aDados[i,5]) )
					U_CriaLog(cPasta,cLog,"JÁ IMPORTADO - Código do Munícipio IBGE:'"+aDados[i,3]+"', Código Bairro:'"+aDados[i,4]+"' e Desc.Bairro:'"+AllTrim(aDados[i,5])+"'")
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
						U_CriaLog(cPasta,cLog,"Código do Munícipio IBGE:'"+aDados[i,3]+"', Código Bairro:'"+aDados[i,4]+"' e Desc.Bairro:'"+AllTrim(aDados[i,5])+"' Não localizado!!!")
					EndIf
				EndIf
			Next i
		Else
			MsgInfo("Não retornou informações do arquivo selecionado!")
		EndIf		
	//fecha transacao
	//EndTran()
	
	If nRegImp > 0
		U_CriaLog(cPasta,cLog,"Importação de Bairro concluída! Importado '"+cValToChar(nRegImp)+"' registros!")
	EndIf

Return

