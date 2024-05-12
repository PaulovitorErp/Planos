#include "totvs.ch"
#include "fwmvcdef.ch"
#include "topconn.ch"

#Define CRLF Chr(13)+Chr(10)

/*/{Protheus.doc} RFUNA049
Gera Comissao de Contrato Funerario
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
/*/

User Function RFUNA049(cUF2_CODIGO,cLog)

Local aArea		    := GetArea()
Local aAreaUF0 	    := UF0->( GetArea() )
Local aAreaUF2 	    := UF2->( GetArea() )
Local aAreaU18	    := U18->( GetArea() )
Local aAreaSA1	    := SA1->( GetArea() )
Local aAreaSA3	    := SA3->( GetArea() )
Local aAreaSE3	    := SE3->( GetArea() )
Local cPrefixo 	    := SuperGetMv("MV_XPREFUN",.F.,"FUN")
Local cTipo	   	    := SuperGetMv("MV_XTIPFUN",.F.,"AT")
Local dE3_EMISSAO   := StoD("")  
Local lRetorno 		:= .T. 
Local nParcel	    := 0

Default cUF2_CODIGO := UF2->UF2_CODIGO
Default cLog 		:= "" 

UF0->( DbSetOrder(1) ) //UF0_FILIAL+UF0_CODIGO 
UF2->( DbSetOrder(1) ) //UF2_FILIAL+UF2_CODIGO 
SA3->( DbSetOrder(1) ) //A3_FILIAL+A3_COD  
SA1->( DbSetOrder(1) ) //A1_FILIAL+A1_COD+A1_LOJA  
U18->( DbSetOrder(1) ) //U18_FILIAL+U18_CODIGO

cLog += CRLF
cLog += " >> RFUNA049 [INICIO] - NOVA ROTINA DE GERAÇAO DE COMISSAO." + CRLF

If UF2->( MsSeek( xFilial("UF2") +  cUF2_CODIGO ) ) 
  	
  	nParcel := UF2->UF2_QTPARC
  	nVlrCtr := UF2->UF2_VALOR	
  	
  	If !Empty(UF2->UF2_VEND)

        //verifico se o plano do contrato gera comissao
  		If UF0->( MsSeek( xFilial("UF0") + UF2->UF2_PLANO  ) )

            // verifico se gero comissao
            If UF0->UF0_COMISS == 'S'

                //valido se possui titulo para o contrato
                If PossuiTit(UF2->UF2_CODIGO)

	                // monto a data de emissao do contrato
	                dE3_EMISSAO := Iif(Empty(UF2->UF2_DTATIV), dDataBase, UF2->UF2_DTATIV)

                    // gero os registros de comissao
                    lRetorno := U_RUTILE15( "F", UF2->UF2_CODIGO, UF2->UF2_VEND, nVlrCtr, @cLog, dE3_EMISSAO, .T., UF2->UF2_CLIENT, UF2->UF2_LOJA,;
                                /*lJob*/, /*nVlrComissao*/, /*nVlrTotal*/, /*nPerVend*/, cPrefixo, cTipo, /*cTipoEnt*/   )
                
                Else
                    
                    If !Empty(cLog)
                        
                        cLog += CRLF
                        cLog += "   >> NAO FORAM ENCONTRADOS TITULOS PARA O CONTRATO..." + CRLF
                        
                    Else

                        If !IsBlind()

                            MsgInfo("Não foram encontrados titulos para o contrato!.","Atenção")

                        Endif
                    
                    EndIf
                        
                    lRetorno := .F. 
                    
                EndIf	
  		   	Else

                If !Empty(cLog)

                    cLog += CRLF
                    cLog += "   >> PLANO DO CONTRATO NAO GERA COMISSAO..." + CRLF

                EndIf
  		   	EndIf
  		Else

  			If !Empty(cLog)

  				cLog += CRLF
  				cLog += "   >> PLANO DO CONTRATO NAO ENCONTRADO..." + CRLF

	   		Else

   	   			If !IsBlind()

   	   				MsgInfo("O Plano do Contrato não foi encontrado!","Atenção")

   	   			Endif

	   		EndIf

	   		lRetorno := .F. 

  		EndIf
  		
  	Else

   		If !Empty(cLog)

   			cLog += CRLF
   			cLog += "   >> CONTRATO SEM VENDEDOR..." + CRLF

		Else

  		   	If !IsBlind()
  		   		MsgInfo("O contrato selecionado não possui vendedor, assim não será gerado comissão!","Atenção")
  		   	Endif

		EndIf
		
		lRetorno := .F. 
  	EndIf 
      		
Else

	lRetorno := .F. 

	If !Empty(cLog)

		cLog += CRLF	
		cLog += "   >> CONTRATO NÃO LOCALIZADO..." + CRLF

	Else

		If !IsBlind()

			MsgInfo("Contrato não foi encontrado!","Atenção")

		Endif

	EndIf
    
EndIf

cLog += CRLF
cLog += " >> RFUNA049 [FIM] - NOVA ROTINA DE GERAÇAO DE COMISSAO." + CRLF

// verifico se tem log para ser gerado
if !Empty( cLog )

	// crio log de comissao
	CriaLogComissao( cLog )

EndIf

RestArea(aAreaUF0)
RestArea(aAreaUF2)
RestArea(aAreaU18)
RestArea(aAreaSA1)
RestArea(aAreaSA3)
RestArea(aAreaSE3)
RestArea(aArea) 
	
Return(lRetorno)

/*/{Protheus.doc} PossuiTit
Funcao para validar se o contrato
possui titulos PossuiTit

@author Raphael Martins
@since 04/08/2016
@version undefined
@param cContrato , characters, Código do Contrato
@type function
/*/
Static Function PossuiTit(cContrato)

Local cPrefixo 	:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
Local cTipo		:= SuperGetMv("MV_XTIPFUN",.F.,"AT")
Local nParcel	:= 0
Local nVlrCtr	:= 0
Local lRetorno		:= .F. 

If Select("TRBSE1") > 0
	TRBSE1->(dbCloseArea())
EndIf

cQry := "select SUM(SE1.E1_VALOR + SE1.E1_SDACRES - SE1.E1_SDDECRE) AS VLRCTR," // -> Valor Total do Contrato, considerando acrescimo e decrescimo
cQry += " COUNT(*) AS QTDPAR" //-> Quantidade de Parcelas do Contrato
cQry += " from " + RetSqlName("SE1") + " SE1"
cQry += " where SE1.D_E_L_E_T_ <> '*'"
cQry += " and SE1.E1_FILIAL = '" + xFilial('SE1') + "'"
cQry += " and SE1.E1_PREFIXO = '" + cPrefixo + "'"
cQry += " and SE1.E1_TIPO = '" + cTipo + "'"
cQry += " and SE1.E1_NUM = '" + cContrato + "'"
		
cQry := Changequery(cQry)
TCQUERY cQry NEW ALIAS "TRBSE1"

If TRBSE1->( !Eof() )
	lRetorno := .T.
EndIf

If Select("TRBSE1") > 0
	TRBSE1->(dbCloseArea())
EndIf
					
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
Local cArquivo          := "rfuna0149_logcomissao_" + CriaTrab(NIL, .F.) + ".txt"
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
         
EndIf

Return()