#include 'totvs.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'
#include 'topconn.ch'

#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RCPGA037
Gera Comissao de Contrato Cemiterio
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
/*/

User Function RCPGA037(cU00_CODIGO,cLog,lJob)

Local aArea			:= GetArea()
Local aAreaU00 		:= U00->(GetArea())
Local aAreaU18		:= U18->(GetArea())
Local aAreaSA1		:= SA1->(GetArea())
Local aAreaSA3		:= SA3->(GetArea())
Local aAreaSE3		:= SE3->(GetArea())
Local cPrefCtr		:= SuperGetMv("MV_XPREFCT",.F.,"CTR")  //prefixo do titulo de contrato
Local cTipoCtr		:= SuperGetMv("MV_XTIPOCT",.F.,"AT")   //tipo do titulo de contrato
Local cTipoEnt		:= SuperGetMv("MV_XTIPOEN",.F.,"ENT")  //tipo de titulo de entrada
Local nVlrCtr 		:= 0 									// valor total do contrato
Local lRetorno 		:= .T. 									// controle de transação
Local lContinua 	:= .T.

Default cU00_CODIGO := U00->U00_CODIGO
Default cLog		:= ""
Default lJob		:= .F.

cLog += CRLF
cLog += " >> RCPGA037 [INICIO] - NOVA ROTINA DE GERAÇAO DE COMISSAO." + CRLF

U00->(dbSetOrder(1)) //U00_FILIAL+U00_CODIGO
If U00->(MsSeek(xFilial("U00")+cU00_CODIGO)) .and. !Empty(U00->U00_VENDED)
	
	// monto a data de emissao do contrato
	dE3_EMISSAO := Iif(Empty(U00->U00_DTATIV), dDataBase, U00->U00_DTATIV)

	nVlrCtr 	:= U00->U00_VALOR // -> Valor Total do Contrato (valor a vista, no ato da criacao do contrato)
	
    // gera os registros da comissao
	If lContinua .And. nVlrCtr > 0 
        
        // chama a funcao de geracao de registros
        lRetorno := U_RUTILE15( "C", cU00_CODIGO, U00->U00_VENDED, nVlrCtr, @cLog, dE3_EMISSAO, .T., U00->U00_CLIENTE, U00->U00_LOJA,;
			 /*lJob*/, /*nVlrComissao*/, /*nVlrTotal*/, /*nPerVend*/, cPrefCtr, cTipoCtr, cTipoEnt   )

	EndIf
	
Else
	
	// verifico se o vendedor esta preenchido no contrato
	If Empty(U00->U00_VENDED)
		
		// verifico se tem log preenchido
		If !Empty(cLog)

			// alimento a variavel de log
			cLog += CRLF
			cLog += "   >> CONTRATO SEM VENDEDOR..." + CRLF
		
		Else // quando nao houver log

			// se nao for job
			If !lJob

				// mensagem para o usuario
				MsgInfo("Contrato sem vendedor...","Atenção")
		
			EndIf
		
		EndIf

	Else // caso nao for o vendedor, e porque não encotrou o contrato

		// verifico se tem log preenchido
		If !Empty(cLog)

			// alimento a variavel de log
			cLog += CRLF
			cLog += "   >> CONTRATO NÃO LOCALIZADO..." + CRLF

		Else // quando nao houver log

			// se nao for job
			If !lJob

				// mensagem para o usuario
				MsgInfo("Contrato não localizado...","Atenção")

			EndIf

		EndIf

	EndIf

EndIf

cLog += CRLF
cLog += " >> RCPGA037 [FIM] - NOVA ROTINA DE GERAÇAO DE COMISSAO." + CRLF

// verifico se tem log para ser gerado
if !Empty( cLog )

	// crio log de comissao
	CriaLogComissao( cLog )

EndIf

RestArea(aAreaU00)
RestArea(aAreaU18)
RestArea(aAreaSA1)
RestArea(aAreaSA3)
RestArea(aAreaSE3)
RestArea(aArea)
	
Return(lRetorno)

/*/{Protheus.doc} CriaLogComissao
Funcao para criar o log de comissao
@author g.sampaio
@since 07/05/2019
@version P12
@param cTextoLog, caracter, texto da log a ser gerado
@return nulo
/*/

Static Function CriaLogComissao( cTextoLog )

Local cDestinoDiretorio := ""
Local cGeradoArquivo    := ""
Local cArquivo          := "rcpga037_logcomissao_" + CriaTrab(NIL, .F.) + ".txt"
Local oWriter           := Nil

Default cTextoLog       := ""

// vou gravar o log no diretorio de arquivos temporarios
cDestinoDiretorio := GetTempPath()

// arquivo gerado no diretorio
cGeradoArquivo := cDestinoDiretorio + iif( substr(alltrim(cDestinoDiretorio),len(alltrim(cDestinoDiretorio))) == iif(IsSrvUnix(),"/","\"),  cArquivo, iif(IsSrvUnix(),"/","\") + cArquivo )

// crio o objeto de escrita de arquivo
oWriter := FWFileWriter():New( cGeradoArquivo, .T.)

// se houve falha ao criar, mostra a mensagem
If !oWriter:Create()
    
    MsgStop("Houve um erro ao gerar o arquivo: " + CRLF + oWriter:Error():Message, "Atenção")
                      
Else// senão, continua com o processamento

    // escreve uma frase qualquer no arquivo
    oWriter:Write( cTextoLog + CRLF)
         
    // encerra o arquivo
    oWriter:Close()
         
    // pergunta se deseja abrir o arquivo
    If MsgYesNo("Arquivo gerado com sucesso (" + cGeradoArquivo + ")!" + CRLF + "Deseja abrir?", "Atenção")
        ShellExecute("OPEN", cArquivo, "", cDestinoDiretorio, 1 )
    EndIf

EndIf

Return()