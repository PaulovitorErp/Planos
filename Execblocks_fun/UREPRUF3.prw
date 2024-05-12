#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ UREPRUF3 º Autor ³ Wellington Gonçalves		   º Data³ 09/06/2017 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que reprocessa os itens do plano no contrato				  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Funerária	                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function UREPRUF3()

Local cLocalErro	:= ""

// carrego o diretório do log de erro
cLocalErro := cGetFile(  , 'Informe o diretório onde será gravado log de reprocessamento...', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )

// verifico se foi cancelada a operação
if !Empty(cLocalErro)
	MsAguarde( {|| ReprocessaUF3(cLocalErro)}, "Aguarde", "Reprocessando contratos...", .F. )
endif

Return()

Static Function ReprocessaUF3(cLocalErro)

Local nHandle		:= 0
Local cDirDocs 		:= MsDocPath()
Local cArqLog		:= "Log de Reprocessaemnto dos Itens.txt"
Local cDirLogServer	:= cDirDocs + iif(IsSrvUnix(),"/","\") + cArqLog
Local cContrato		:= ""
Local cLegado		:= "" 
Local cItem			:= ""
Local cQry			:= ""
Local cPulaLinha	:= chr(13)+chr(10) 
Local nStart		:= 0

// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

cQry := " SELECT "													+ cPulaLinha
cQry += " UF2.UF2_PLANO AS PLANO, "                                 + cPulaLinha
cQry += " UF2.UF2_CODIGO AS CONTRATO, "                             + cPulaLinha
cQry += " UF2.UF2_CODANT AS LEGADO, "                               + cPulaLinha
cQry += " BENEFICIARIOS.ULTIMO_ITEM AS ITEM "                       + cPulaLinha
cQry += " FROM "                                                    + cPulaLinha
cQry += " " + RetSqlName("UF2") +  " UF2 "                          + cPulaLinha
cQry += " INNER JOIN "                                              + cPulaLinha
cQry += " 	( "                                                     + cPulaLinha
cQry += " 	SELECT "                                                + cPulaLinha
cQry += " 	UF3.UF3_CODIGO AS CONTRATO, "                           + cPulaLinha
cQry += " 	MAX(UF3.UF3_ITEM) AS ULTIMO_ITEM "                      + cPulaLinha
cQry += " 	FROM "                                                  + cPulaLinha
cQry += " 	" + RetSqlName("UF3") + " UF3 "                         + cPulaLinha
cQry += " 	WHERE "                                                 + cPulaLinha
cQry += " 	UF3.D_E_L_E_T_ <> '*' "                                 + cPulaLinha
cQry += " 	AND UF3.UF3_FILIAL = '" + xFilial("UF3") + "' "         + cPulaLinha
cQry += " 	GROUP BY UF3.UF3_CODIGO "                               + cPulaLinha
cQry += " 	) BENEFICIARIOS "                                       + cPulaLinha
cQry += " 	ON BENEFICIARIOS.CONTRATO = UF2.UF2_CODIGO "            + cPulaLinha
cQry += " WHERE "                                                   + cPulaLinha
cQry += " UF2.D_E_L_E_T_ <> '*' "                                   + cPulaLinha
cQry += " AND UF2.UF2_FILIAL = '" + xFilial("UF2") + "' "           + cPulaLinha
cQry += " AND UF2.UF2_CODANT <> ' ' "                               + cPulaLinha
cQry += " AND NOT EXISTS "                                          + cPulaLinha
cQry += " ( "                                                       + cPulaLinha
cQry += " 	SELECT "                                                + cPulaLinha
cQry += " 	UF3.UF3_CODIGO "                                        + cPulaLinha
cQry += " 	FROM "                                                  + cPulaLinha
cQry += " 	" + RetSqlName("UF3") + " UF3 "                         + cPulaLinha
cQry += " 	WHERE "                                                 + cPulaLinha
cQry += " 	UF3.D_E_L_E_T_ <> '*' "                                 + cPulaLinha
cQry += " 	AND UF3.UF3_FILIAL = '" + xFilial("UF3") + "' "         + cPulaLinha
cQry += " 	AND UF3.UF3_CODIGO = UF2.UF2_CODIGO "                   + cPulaLinha
cQry += " 	AND UF3.UF3_PROD IN ('002201','002200') "               + cPulaLinha
cQry += " 	GROUP BY UF3.UF3_CODIGO "                               + cPulaLinha
cQry += " ) "                                                       + cPulaLinha
cQry += " ORDER BY UF2.UF2_PLANO,UF2.UF2_CODIGO "                   + cPulaLinha

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

// se existir contratos a serem reajustados
if QRY->(!Eof())

	// crio o arquivo de log no servidor
	nHandle := MsfCreate( cDirLogServer ,0 )

	FwLogMsg("INFO", , "REST", FunName(), "", "01","REPROCESSAMENTO DOS ITENS DO CONTRATO" , 0, (nStart - Seconds()), {}) 
	FwLogMsg("INFO", , "REST", FunName(), "", "01","Arquivo Gerado: " + cArqLog , 0, (nStart - Seconds()), {}) 


	fWrite(nHandle , "#########  REPROCESSAMENTO DOS ITENS DO CONTRATO  #############")
	fWrite(nHandle , cPulaLinha )
	fWrite(nHandle , " >> Hora Inicio: " + Time())
	fWrite(nHandle , cPulaLinha )

	While QRY->(!EOF())
	
		cContrato	:= QRY->CONTRATO
		cLegado		:= QRY->LEGADO 
		cItem		:= SOMA1(QRY->ITEM) 
		
		fWrite(nHandle , "  - Contrato: " + cContrato + " Legado: " + cLegado)
		fWrite(nHandle , cPulaLinha )
		
		//////////////////////////////////////  GRAVO O PRIMEIRO PRODUTO  ////////////////////////////////
		
		// pego o código do próximo Item 
		UF3->(DbSetOrder(1)) // UF3_FILIAL + UF3_CODIGO + UF3_ITEM 
		While UF3->(DbSeek(xFilial("UF3") + cContrato + cItem))
			cItem := SOMA1(cItem)
		EndDo
		
		fWrite(nHandle , "  - Inserido Item: " + cItem + " Produto: 002200")
		fWrite(nHandle , cPulaLinha )
		
		if RecLock("UF3",.T.)
		
			UF3->UF3_FILIAL := xFilial("UF3")
			UF3->UF3_CODIGO := cContrato
			UF3->UF3_ITEM	:= cItem
			UF3->UF3_PROD	:= '002200'  
			UF3->(MsUnLock())
		
		endif
		
		//////////////////////////////////////  GRAVO O SEGUNDO PRODUTO  ////////////////////////////////

		// incremento o Item
		cItem := SOMA1(cItem) 
		
		fWrite(nHandle , "  - Inserido Item: " + cItem + " Produto: 002201")
		fWrite(nHandle , cPulaLinha )
		
		if RecLock("UF3",.T.)
		
			UF3->UF3_FILIAL := xFilial("UF3")
			UF3->UF3_CODIGO := cContrato
			UF3->UF3_ITEM	:= cItem
			UF3->UF3_PROD	:= '002201'  
			UF3->(MsUnLock())
		
		endif
		
		QRY->(DbSkip())
		
	EndDo
	
	fWrite(nHandle , " >> Hora Fim: " + Time())

	fClose(nHandle) // fecho o arquivo de log
	
	// copio o arquivo gerado no servidor para o terminal
	CpyS2T( cDirLogServer , AllTrim(cLocalErro), .T. )

endif

// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 
	
Return()