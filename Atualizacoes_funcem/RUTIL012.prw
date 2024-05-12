#include "totvs.CH"
#include "rwmake.ch"
#include "topconn.ch"

/*/{Protheus.doc} RUTIL012
UVIRTUSDOC
Gera tabelas dos campos para fazer documentação.		 	

nTipo: Tipo da documentação:								  
 		1 =	Completa (tabela, campos, indices, gatilhos)	  
 		2 =	Tabela (SX2)									  
 		3 =	Campos (SX3)									  
 		4 =	Indices (SIX)									  
 		5 =	Gatilhos (SX7)							  		  
 		6 =	Consulta Padrão (SXB)						  	  
cChave: Alias para gerar documentação, ou nome da Consulta 
 		Padrão (caso tipo 6)							  	 

Exemplos de Uso:
U_CFGTODOC(1,"SZ1")                                       
U_CFGTODOC(3,"SZ2")                                        
U_CFGTODOC(6,"SB1ESP")                                     

@type  User Function
@author Danilo Brito 
@since 21/10/2013 
@version 1.0
@param nTipo, numeric, tipo de documentacao 
@param cChave, characters, alias a ser utilizado para retornar as tabelas
@return lRet, logico, retorno logico da validacao
@example
(examples)
@see (links_or_references)
/*/
User Function RUTIL012(nTipo, cChave, cPasta, aSX2, aSX3, aSX6, aSXB, lLevaSIX, lLevaSX7, lLevaSXA, lLevaSXB)

	Local nI			:= 0
	Local cArquivo		:= ""

	Private nHandle		:= 0
	Private aStructSX2	:= {}
	Private aStructSX3	:= {}
	Private aStructSIX  := {}
	Private aStructSX7  := {}
	Private aStructSXB	:= {}

	Default nTipo		:= 0
	Default cChave		:= ""
	Default cPasta		:= ""
	Default aSX2		:= {}
	Default aSX3		:= {}
	Default aSX6		:= {}
	Default aSXB		:= {}
	Default lLevaSIX	:= .F.
	Default lLevaSX7	:= .F.
	Default lLevaSXA	:= .F.
	Default lLevaSXB	:= .F.

	// atribuo o valor do parametro para a variavel cPath
	if !empty(alltrim(cPasta))

		// valido a barra ou contra barraADMIN
		cPasta += If(Right(cPasta, 1) <> "\", "\", "")

		// percorro os dados de SX3
		if Len(aSX2) > 0

			For nI := 1 to Len( aSX2 )

				// pego como chave o alias da tabela
				cChave := aSX2[nI]

				// coloco nome do arquivo
				cArquivo := cPasta + "VIRTUSDOC_" + cChave + "_" + dtos(date()) + strTran(time(),":","") + "_" + criatrab(,.F.)

				// chamo a funcao para gerar o arquivo
				GerarArqHtml( nTipo, cChave, cArquivo, aSX2, aSX3, aSX6, aSXB, lLevaSIX, lLevaSX7, lLevaSXA, lLevaSXB )

			next nI

		elseif !empty(cChave) // para quando nao for pela rotina UTBCDIC

			// coloco nome do arquivo
			cArquivo := cPasta + "VIRTUSDOC_" + cChave + "_" + dtos(date()) + strTran(time(),":","") + "_" + criatrab(,.F.)

			// chamo a funcao para gerar o arquivo
			GerarArqHtml( nTipo, cChave, cArquivo, aSX2, aSX3, aSX6, aSXB, lLevaSIX, lLevaSX7, lLevaSXA, lLevaSXB )

		endif

	endif

Return(Nil)

/*/{Protheus.doc} GerarArqHtml
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function GerarArqHtml( nTipo, cChave, cArquivo, aSX2, aSX3, aSX6, aSXB, lLevaSIX, lLevaSX7, lLevaSXA, lLevaSXB )

	Local cPulaLinha	:= chr(13)+chr(10)
	Local cBody	   		:= ""
	Local cPrefix 		:= ""
	Local cNomeTabela	:= ""
	Local cQuery		:= ""
	Local cAliasSXB		:= ""
	Local nPosX3		:= 1
	Local nPosX7		:= 1
	Local nI			:= 0
	Local aSX7			:= {}
	Local aSXA			:= {}

	Default nTipo		:= 0
	Default cChave		:= ""
	Default cArquivo	:= ""
	Default aSX2		:= {}
	Default aSX3		:= {}
	Default aSX6		:= {}
	Default aSXB		:= {}
	Default lLevaSIX	:= .F.
	Default lLevaSX7	:= .F.
	Default lLevaSXA	:= .F.
	Default lLevaSXB	:= .F.

	// verifico se a variavel cArquivo esta preenchida
	if empty(cArquivo)
		return
	elseif UPPER(right(cArquivo,5)) != ".HTML"
		cArquivo += ".html"
	endif

	// inicio o arquivo
	nHandle := FCreate(cArquivo)

	// caso o arquivo tenha sido criado corretamente
	if nHandle > 0

		cBody := ' <html> ' 																									+ cPulaLinha
		cBody += ' 	<head> ' 																									+ cPulaLinha
		cBody += '		<title> Virtus - Dicionario de Dados - Tabela : '+cChave+' </title> ' 																		+ cPulaLinha
		cBody += '	</head> ' 																	   								+ cPulaLinha
		cBody += ' 	<style type="text/css"> ' 																					+ cPulaLinha
		cBody += '		body, td {font: normal 13px Calibri,Trebuchet MS,Tahoma; } '						   					+ cPulaLinha
		cBody += '		.borda1 {border: 1px solid #000000; border-bottom: 0px; border-right: 0px; padding-left: 4px;} '		+ cPulaLinha
		cBody += '		.borda2 {border: 1px solid #000000; border-top: 0px; border-left: 0px;} '								+ cPulaLinha
		cBody += '	</style> ' 																									+ cPulaLinha
		cBody += '	<body> ' 																	   								+ cPulaLinha

		FWRITE(nHandle, cBody)

		//------------------------------------------------------------------------//
		//			IMPRIMINDO SX2												  //
		//------------------------------------------------------------------------//
		if nTipo == 1 .OR. nTipo == 2

			aStructSX2	:= StructSX2()

			dbSelectArea("SX2")
			SX2->(dbSetOrder(1))
			if !SX2->(dbSeek(cChave))
				Alert("Alias não encontrado na SX2")
				return
			endif

			// descricao da tabela que serao detalhados os campos
			cBody := 'Abaixo estão detalhados os dados da tabela '+cChave+' - ' + cNomeTabela + ': <br />' + cPulaLinha

			cBody += '	<table style="width: 675px;" class="borda2" border="0" cellpadding="1" cellspacing="0"> ' 	   	  		+ cPulaLinha

			// peogo o nome da tabela
			cNomeTabela	:= Capital(SX2->X2_NOME)

			// percorro
			for nI := 1 to len(aStructSX2)

				cConteudo := &(aStructSX2[nI][2])

				if !empty(cConteudo)
					cBody += '		<tr> ' 																						+ cPulaLinha
					cBody += '			<td width="120" class="borda1" bgcolor="DDDDDD">'+aStructSX2[nI][1]+'</td> '   			+ cPulaLinha
					cBody += '			<td class="borda1">'+ cConteudo +'</td> ' 												+ cPulaLinha
					cBody += '		</tr> '
				endif

			next nI

			cBody += '	</table><br> '	   															   							+ cPulaLinha

			FWRITE(nHandle, cBody)

		endif

		//------------------------------------------------------------------------//
		//			IMPRIMINDO SX3												  //
		//------------------------------------------------------------------------//
		if nTipo == 1 .OR. nTipo == 3

			// pego a estrutura da SX3
			aStructSX3	:= StructSX3()

			// descricao da tabela que serao detalhados os campos
			cBody := 'Abaixo estão detalhados os campos da tabela '+cChave+' - ' + cNomeTabela + ': <br />' + cPulaLinha

			FWRITE(nHandle, cBody)

			dbSelectArea("SX3")
			SX3->(dbSetOrder(1))
			SX3->(dbSeek(cChave))
			while SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == cChave

				// verifico se o array esta preenchido
				if len(aSX3) > 0
					nPosX3 := aScan( aSX3, {|x| alltrim(x) == SX3->X3_CAMPO } )
				endIf

				// caso for levar as SX7
				if lLevaSX7
					// valido se o campo tem gatilhos
					dbSelectArea("SX7")
					SX7->(dbSetOrder(1))
					if SX7->(dbSeek(SX3->X3_CAMPO))
						aadd(aSX7,SX3->X3_CAMPO) // adiciono os campos
					endIf
				endIf

				// se for campo filial ou nao tiver sido passado para impressao pulo o registro
				if "FILIAL" $ SX3->X3_CAMPO .Or. nPosX3 == 0
					SX3->(DbSkip())
					LOOP
				endif

				cBody := '	<table style="width: 675px;" class="borda2" border="0" cellpadding="1" cellspacing="0"> ' 	   		+ cPulaLinha

				for nI:=1 to len(aStructSX3)

					cConteudo := &(aStructSX3[nI][2])

					if !empty(cConteudo)
						cBody += '		<tr> ' 																   					+ cPulaLinha
						cBody += '			<td width="120" class="borda1" bgcolor="DDDDDD">'+aStructSX3[nI][1]+'</td> ' 		+ cPulaLinha
						cBody += '			<td class="borda1">'+ cConteudo +'</td> ' 											+ cPulaLinha
						cBody += '		</tr> '																					+ cPulaLinha
					endif

				next nI

				cBody += '	</table><br> '	   																   					+ cPulaLinha

				FWRITE(nHandle, cBody)

				SX3->(DbSkip())
			enddo

		endif

		//------------------------------------------------------------------------//
		//			IMPRIMINDO SIX												  //
		//------------------------------------------------------------------------//
		if (nTipo == 1 .OR. nTipo == 4) .and. lLevaSIX

			aStructSIX	:= StructSIX()

			cBody := 'Índices da Tabela: <br />' 															   					+ cPulaLinha
			FWRITE(nHandle, cBody)

			dbSelectArea("SIX")
			SIX->(dbSetOrder(1))
			SIX->(dbSeek(cChave))
			while SIX->(!EOF()) .AND. SIX->INDICE == cChave

				cBody := '	<table style="width: 675px;" class="borda2" border="0" cellpadding="1" cellspacing="0"> ' 	   		+ cPulaLinha

				for nI:=1 to len(aStructSIX)

					cConteudo := &(aStructSIX[nI][2])

					if !empty(cConteudo)
						cBody += '		<tr> ' 																					+ cPulaLinha
						cBody += '			<td width="120" class="borda1" bgcolor="DDDDDD">'+aStructSIX[nI][1]+'</td> ' 		+ cPulaLinha
						cBody += '			<td class="borda1">'+ cConteudo +'</td> ' 											+ cPulaLinha
						cBody += '		</tr> '																   					+ cPulaLinha
					endif

				next nI

				cBody += '	</table><br> '	   																   					+ cPulaLinha

				FWRITE(nHandle, cBody)

				SIX->(DbSkip())
			enddo

		endif

		//------------------------------------------------------------------------//
		//			IMPRIMINDO SX7												  //
		//------------------------------------------------------------------------//
		if (nTipo == 1 .OR. nTipo == 5) .and. lLevaSX7

			cPrefix := iif(left(cChave,1) <> "S", cChave, right(cChave,2)) + "_"
			aStructSX7	:= StructSX7()

			cBody := 'Gatilhos de Campos: <br />' 															   					+ cPulaLinha
			FWRITE(nHandle, cBody)

			dbSelectArea("SX7")
			SX7->(dbSetOrder(1))
			SX7->(dbSeek(cPrefix))
			while SX7->(!EOF()) .AND. cPrefix == substr(SX7->X7_CAMPO,1,len(cPrefix))

				// verifico se o array esta preenchido
				if len(aSX7) > 0
					nPosX7 := aScan( aSX7, {|x| substr(alltrim(x),1,len(cPrefix)) == cPrefix } )
				endIf

				// se nao houver registros para o gatilho, pulo o registro
				if nPosX7 == 0
					LOOP
					SX7->( DbSkip() )
				endIf

				cBody := '	<table style="width: 675px;" class="borda2" border="0" cellpadding="1" cellspacing="0"> ' 	   		+ cPulaLinha

				for nI:=1 to len(aStructSX7)

					cConteudo := &(aStructSX7[nI][2])

					if !empty(cConteudo)
						cBody += '		<tr> ' 																					+ cPulaLinha
						cBody += '			<td width="120" class="borda1" bgcolor="DDDDDD">'+aStructSX7[nI][1]+'</td> ' 		+ cPulaLinha
						cBody += '			<td class="borda1">'+ cConteudo +'</td> ' 											+ cPulaLinha
						cBody += '		</tr> '																   					+ cPulaLinha
					endif

				next nI

				cBody += '	</table><br> '	   																   					+ cPulaLinha

				FWRITE(nHandle, cBody)

				SX7->(DbSkip())
			enddo

		endif

		//------------------------------------------------------------------------//
		//			IMPRIMINDO SXB												  //
		//------------------------------------------------------------------------//
		if (nTipo == 1 .Or. nTipo == 6) .and. lLevaSXB

			// abro o alias
			dbSelectArea("SXB")

			If Select("TRBSXB") > 0
				TRBSXB->( DbCloseArea() )
			EndIf

			// query para buscar os registros da SXB
			cQuery := " SELECT XB_ALIAS CONSULTA FROM " + RetSqlName("SXB") + " SXB "
			cQuery += " WHERE SXB.D_E_L_E_T_ = ' ' "
			cQuery += " AND (SXB.XB_ALIAS LIKE '%" + cChave + "%' OR XB_CONTEM = '" + cChave + "') "
			cQuery += " GROUP BY XB_ALIAS "

			TcQuery cQuery New Alias "TRBSXB"

			// percorro as consulta SXB
			While TRBSXB->(!Eof())

				// alias da consulta padrao
				cAliasSXB := TRBSXB->CONSULTA

				SXB->(dbSetOrder(1))
				if SXB->(dbSeek(cAliasSXB))

					cBody := 'Consulta Padrão: <br />' 															   				   	+ cPulaLinha
					cBody += '	<table style="width: 675px;" class="borda2" border="0" cellpadding="1" cellspacing="0"> ' 	   		+ cPulaLinha
					
					FWRITE(nHandle, cBody)
					
					cBody := ""					

					//imprimindo tipo 1 - Descrição
					aStructSXB := StructSXB("1")

					for nI:=1 to len(aStructSXB)

						cConteudo := &(aStructSXB[nI][2])

						if !empty(cConteudo)
							cBody += '		<tr> ' 																					+ cPulaLinha
							cBody += '			<td width="120" class="borda1" bgcolor="DDDDDD">'+aStructSXB[nI][1]+'</td> ' 		+ cPulaLinha
							cBody += '			<td class="borda1">'+ cConteudo +'</td> ' 											+ cPulaLinha
							cBody += '		</tr> '																   					+ cPulaLinha
						endif
					next nI

					FWRITE(nHandle, cBody)
					
					cBody := ""

					//imprimindo tipo 3 - Hab. Inclusão
					if SXB->(dbSeek(cAliasSXB+'3'))
						
						aStructSXB := StructSXB("3")
						
						for nI:=1 to len(aStructSXB)

							cConteudo := &(aStructSXB[nI][2])
							if !empty(cConteudo)
								cBody += '		<tr> ' 																					+ cPulaLinha
								cBody += '			<td width="120" class="borda1" bgcolor="DDDDDD">'+aStructSXB[nI][1]+'</td> ' 		+ cPulaLinha
								cBody += '			<td class="borda1">'+ cConteudo +'</td> ' 											+ cPulaLinha
								cBody += '		</tr> '																   					+ cPulaLinha
							endif

						next nI

					endif

					FWRITE(nHandle, cBody)
					
					cBody := ""

					//imprimindo tipo 2 - Indices e Campos
					if SXB->(dbSeek(cAliasSXB+'2'))
						
						// pego a estrutura da SXB
						aStructSXB := StructSXB("2")
						
						cBody += '		<tr> ' 																					+ cPulaLinha
						cBody += '			<td width="120" class="borda1" bgcolor="DDDDDD">'+aStructSXB[1][1]+'</td> ' 		+ cPulaLinha
						cBody += '			<td class="borda1">'																+ cPulaLinha
						
						FWRITE(nHandle, cBody)
						
						cBody := ""

						while SXB->(!EOF()) .AND. SXB->(XB_ALIAS+XB_TIPO) == cAliasSXB+'2'
							
							nRecno2 := SXB->(Recno())

							for nI:=1 to len(aStructSXB) //imprimindo tipo 2 - Indices

								cConteudo := &(aStructSXB[nI][2])
							
								if !empty(cConteudo)
									cBody += cConteudo + "<br/>"																+ cPulaLinha
								endif
							
							next nI

							FWRITE(nHandle, cBody)

							cBody := ""

							//imprimindo tipo 4 - Campos Tela
							cChave4 := cAliasSXB+'4'+SXB->XB_SEQ

							if SXB->(dbSeek(cChave4))

								cBody += '	<table style="width: 100%;" class="borda2" border="0" cellpadding="1" cellspacing="0"> ' 	+ cPulaLinha

								while SXB->(!EOF()) .AND. SXB->(XB_ALIAS+XB_TIPO+XB_SEQ) == cChave4

									aStrcSXB2 := StructSXB("4")

									for nI:=1 to len(aStrcSXB2) //imprimindo tipo 4 - Campos Tela
										cBody += '		<tr> ' 																					+ cPulaLinha
										cBody += '			<td width="120" class="borda1" bgcolor="DDDDDD">'+&(aStrcSXB2[nI][1])+'</td> ' 		+ cPulaLinha
										cBody += '			<td class="borda1">'+ &(aStrcSXB2[nI][2]) +'</td> ' 								+ cPulaLinha
										cBody += '		</tr> '																   					+ cPulaLinha
									next nI

									SXB->(DbSkip())
								enddo

								cBody += '	</table><br> '	   																   					+ cPulaLinha
								
								FWRITE(nHandle, cBody)

								cBody := ""
							endif

							SXB->(DbGoTo(nRecno2))
							SXB->(DbSkip())
						enddo

						cBody += '		</td></tr> '																   				+ cPulaLinha
						
						FWRITE(nHandle, cBody)
						
						cBody := ""
					endif

					//imprimindo tipo 6 - Filtro
					if SXB->(dbSeek(cAliasSXB+'6'))
						
						// pego a estrutura da SXB
						aStructSXB := StructSXB("6")
						
						for nI:=1 to len(aStructSXB)

							cConteudo := &(aStructSXB[nI][2])

							if !empty(cConteudo)

								cBody += '		<tr> ' 																					+ cPulaLinha
								cBody += '			<td width="120" class="borda1" bgcolor="DDDDDD">'+aStructSXB[nI][1]+'</td> ' 		+ cPulaLinha
								cBody += '			<td class="borda1">'+ cConteudo +'</td> ' 											+ cPulaLinha
								cBody += '		</tr> '																   					+ cPulaLinha
							
							endif

						next nI

					endif

					FWRITE(nHandle, cBody)
					cBody := ""

					//imprimindo tipo 5 - Retorno
					if SXB->(dbSeek(cAliasSXB+'5'))

						// pego a estrutura da SXB
						aStructSXB := StructSXB("5")

						// percorro a estrutura 
						for nI:=1 to len(aStructSXB)
							
							cBody += '		<tr> ' 																					+ cPulaLinha
							cBody += '			<td width="120" class="borda1" bgcolor="DDDDDD">'+aStructSXB[nI][1]+'</td> ' 		+ cPulaLinha
							cBody += '			<td class="borda1">'					 											+ cPulaLinha
							
							while SXB->(!Eof()) .AND. SXB->(XB_ALIAS+XB_TIPO) == cAliasSXB+'5'
								cConteudo := &(aStructSXB[nI][2])
								if !empty(cConteudo)
									if nI > 1
										cBody += ", "
										nI++
									endif
									cBody += cConteudo
								endif
								SXB->(DbSkip())
							enddo

							cBody += '			</td> '									 											+ cPulaLinha
							cBody += '		</tr> '																   					+ cPulaLinha

						next nI
						
					endif

					FWRITE(nHandle, cBody)
					
					cBody := ""

					cBody += '	</table><br> '	   																   					+ cPulaLinha
					
					FWRITE(nHandle, cBody)

					If Select("TRBSXB") > 0
						TRBSXB->( DbCloseArea() )
					EndIf

				else
					Alert("Consulta SXB nao encontrada!")
				endif

			TRBSXB->( DbSkip() )
		EndDo

	endif

	//rodape
	cBody := '	</body> ' 					+ cPulaLinha
	cBody += ' </html> ' 					+ cPulaLinha

	FWRITE(nHandle, cBody)

	fClose(nHandle)

	nRet := ShellExecute("open",cArquivo,"",cArquivo, 1 )

	If nRet <= 32
		Aviso( "Atencao!", "Nao foi possivel abrir o objeto '" + cArquivo + "'!", { "Ok" }, 2 )
	EndIf

endif

//------------------------------------------------------------------------//
//	Função para montar estrutura dos campos da SX2						  //
//------------------------------------------------------------------------//
Static Function StructSX2()

	Local aStruct := {}

	aadd(aStruct, {"Tabela"		,"SX2->X2_CHAVE"})
	aadd(aStruct, {"Descrição"	,"Capital(SX2->X2_NOME)"})
	aadd(aStruct, {"Filial"		,"iif(SX2->X2_MODO=='E','Exclusivo','Compartilhado')"})
	aadd(aStruct, {"Unidade"	,"iif(SX2->X2_MODOUN=='E','Exclusivo','Compartilhado')"})
	aadd(aStruct, {"Empresa"	,"iif(SX2->X2_MODOEMP=='E','Exclusivo','Compartilhado')"})

return aStruct

//------------------------------------------------------------------------//
//	Função para montar estrutura dos campos da SX3						  //
//------------------------------------------------------------------------//
Static Function StructSX3()

	Local aStruct := {}

	aadd(aStruct, {"Campo"		,"SX3->X3_CAMPO"})
	aadd(aStruct, {"Tipo"		,"iif(SX3->X3_TIPO=='C','Caractere',iif(SX3->X3_TIPO=='N','Numérico',iif(SX3->X3_TIPO=='D','Data',iif(SX3->X3_TIPO=='M','Memo','Lógico'))))"})
	aadd(aStruct, {"Tamanho"	,"alltrim(cValtoChar(SX3->X3_TAMANHO)) + iif(SX3->X3_DECIMAL>0, ', '+alltrim(cValToChar(SX3->X3_DECIMAL)), '')"})
	aadd(aStruct, {"Formato"	,"SX3->X3_PICTURE"})
	aadd(aStruct, {"Contexto"	,"iif(SX3->X3_CONTEXT=='R','Real, ','Virtual, ') + iif(SX3->X3_VISUAL=='A','Alterar','Visualizar')"})
	aadd(aStruct, {"Título"		,"SX3->X3_TITULO"})
	aadd(aStruct, {"Descrição"	,"SX3->X3_DESCRIC"})
	aadd(aStruct, {"Lista Opções","SX3->X3_CBOX"})
	aadd(aStruct, {"Inic.Padrao","SX3->X3_RELACAO"})
	aadd(aStruct, {"Inic.Browse","SX3->X3_INIBRW"})
	aadd(aStruct, {"Modo Ediçao","SX3->X3_WHEN"})
	aadd(aStruct, {"Cons.Padrao","SX3->X3_F3"})
	aadd(aStruct, {"Validacao"	,"SX3->X3_VLDUSER"})
	aadd(aStruct, {"Uso"		,"'['+iif(empty(SX3->X3_OBRIGAT),' ','X')+'] Obrigatório &nbsp; ['+iif(SX3->X3_USADO=='€€€€€€€€€€€€€€€',' ','X')+'] Usado &nbsp; ['+iif(SX3->X3_BROWSE<>'S',' ','X')+'] Browse'"})

Return aStruct

//------------------------------------------------------------------------//
//	Função para montar estrutura dos campos da SIX						  //
//------------------------------------------------------------------------//
Static Function StructSIX()

	Local aStruct := {}

	aadd(aStruct, {"Índice"		,"SIX->INDICE"})
	aadd(aStruct, {"Ordem" 		,"SIX->ORDEM"})
	aadd(aStruct, {"Chave"		,"SIX->CHAVE"})
	aadd(aStruct, {"Mostra Pesq.","iif(SIX->SHOWPESQ=='S','Sim','Não')"})

return aStruct

//------------------------------------------------------------------------//
//	Função para montar estrutura dos campos da SX7						  //
//------------------------------------------------------------------------//
Static Function StructSX7()

	Local aStruct := {}

	aadd(aStruct, {"Campo"			,"SX7->X7_CAMPO"})
	aadd(aStruct, {"Sequência"		,"SX7->X7_SEQUENC"})
	aadd(aStruct, {"Cnt. Dominio" 	,"SX7->X7_CDOMIN"})
	aadd(aStruct, {"Tipo"			,"iif(SX7->X7_TIPO=='P','Primário',iif(SX7->X7_TIPO=='X','Posicionamento',iif(SX7->X7_TIPO=='E','Estrangeiro','')))"})
	aadd(aStruct, {"Regra" 			,"SX7->X7_REGRA"})
	aadd(aStruct, {"Posiciona"		,"iif(SX7->X7_SEEK=='S','Sim','')"})
	aadd(aStruct, {"Alias"			,"SX7->X7_ALIAS"})
	aadd(aStruct, {"Ordem"			,"iif(SX7->X7_ORDEM > 0, alltrim(cValToChar(SX7->X7_ORDEM)), '')"})
	aadd(aStruct, {"Chave"			,"SX7->X7_CHAVE"})
	aadd(aStruct, {"Condição"		,"SX7->X7_CONDIC"})

return aStruct

//------------------------------------------------------------------------//
//	Função para montar estrutura dos campos da SXB						  //
//------------------------------------------------------------------------//
Static Function StructSXB(cTipo)

	Local aStruct := {}

	if cTipo == '1' //alias
		aadd(aStruct, {"Consulta"		,"SXB->XB_ALIAS"})
		aadd(aStruct, {"Descrição"		,"SXB->XB_DESCRI"})
		aadd(aStruct, {"Tabela"			,"alltrim(SXB->XB_CONTEM)"})
	elseif cTipo == '2' //indices                    '
		aadd(aStruct, {"Índices/Campos" ,"SXB->XB_COLUNA + ' - ' + alltrim(SXB->XB_DESCRI)"})
	elseif cTipo == '3' //Habilita Inclusao
		aadd(aStruct, {"Hab. Inclusao"	,"'Sim'"})
	elseif cTipo == '4' //campos do indice
		aadd(aStruct, {"alltrim(SXB->XB_DESCRI)", "alltrim(SXB->XB_CONTEM)"})
	elseif cTipo == '5' //campos para retorno
		aadd(aStruct, {"Retorno", "alltrim(SXB->XB_CONTEM)"})
	elseif cTipo == '6' //filtro
		aadd(aStruct, {"Filtro", "alltrim(SXB->XB_CONTEM)"})
	endif

return aStruct


