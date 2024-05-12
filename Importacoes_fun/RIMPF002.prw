#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*/{Protheus.doc} RIMPF002
Rotina de Geracao de Historico de 
Reajuste de Contratos Funerarios
@author Raphael Martins
@since 14/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RIMPF002()

If MsgYesNo("Deseja Reprocessar os contratos importados?")
	FWMsgRun(,{|oSay| RepContratos(oSay)},'Aguarde...','Gerando histórico de Reajustes de Contratos!...')
EndIf

Return()                                                                                    

/*/{Protheus.doc} RIMPF002
Funcao para reprocessar historico 
de reajuste de contratos
@author Raphael Martins
@since 14/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function RepContratos(oSay)

Local cQry 			:= ""  
Local cNextReaj		:= ""  
Local cStartPath 	:= "" 
Local cContrato		:= ""
Local cLog			:= "REPROCESSAMENTO_NOSSO_NUMERO_FUNERARIA.LOG"
Local lAtu			:= .F.
Local cPulaLinha	:= ""
Local cPrefixo 		:= SuperGetMv("MV_XPREFUN",.F.,"FUN")
Local cTipo			:= SuperGetMv("MV_XTIPFUN",.F.,"AT")

cStartPath 	:= GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")  		

nHdlLog := MsfCreate(cStartPath + cLog , 0 ) 

//verifico se criou arquivo de log de processamento 
if nHdlLog > 0 
	
	fWrite(nHdlLog , "#########  GERACAO DE HISTORICO DE REAJUSTES - FUNERARIA  #############")
	fWrite(nHdlLog , cPulaLinha )
	fWrite(nHdlLog , " >> Data Inicio: " + DTOC( Date() ) )
	fWrite(nHdlLog , cPulaLinha )
	fWrite(nHdlLog , " >> Hora Inicio: " + Time() )
	fWrite(nHdlLog , cPulaLinha ) 
				                                          
	UF2->( DbSetOrder(1) ) //UF2_FILIAL + UF2_CODIGO
	UF7->( DbSetOrder(2) ) //UF7_FILIAL + UF7_CONTRA
	 
	cQry := " SELECT "
	cQry += "   DISTINCT "
	cQry += " 	UF2_CODIGO CODIGO_PROTHEUS, "
	cQry += " 	UF2_CODANT CODIGO_LEGADO, " 
	cQry += " 	( SELECT MAX( E1_VENCTO ) "  
	cQry += "			FROM " + RetSQLName("SE1") + " E1 (NOLOCK) "  
	cQry += "			WHERE D_E_L_E_T_ = ' ' "  
	cQry += " 			AND E1_PREFIXO = '" + cPrefixo +"' "
	cQry += " 			AND E1_TIPO = '" + cTipo + "' "
	cQry += "			AND E1.E1_NUM = UF2.UF2_CODIGO "
	cQry += "			AND E1.E1_XCTRFUN = UF2.UF2_CODIGO   ) LAST_VENC "
	cQry += "	FROM  "
	cQry += " 		" + RetSQLName("UF2") + " UF2 " 
	cQry += " INNER JOIN "
	cQry += RetSQLName("SE1") + " TIT (NOLOCK) "
	cQry += " ON "
	cQry += " TIT.D_E_L_E_T_ = ' ' "
	cQry += " AND TIT.E1_FILIAL = '" + xFilial("SE1")+ "' "
	cQry += " AND TIT.E1_XCTRFUN = UF2.UF2_CODIGO "
	cQry += "	WHERE "
	cQry += " 		UF2.D_E_L_E_T_ = ' ' " 
	cQry += "		AND UF2.UF2_STATUS = 'A' "
	cQry += "		AND UF2.UF2_FILIAL = '" + xFilial("UF2") + "' "
	cQry += " 		AND UF2_CODANT <> ' ' "
	cQry += " 		AND NOT EXISTS " 
	cQry += " 		( "
	cQry += "     		SELECT UF7_CONTRA "
	cQry += " 			FROM "
	cQry += "			" + RetSQLName("UF7") + " HIST " 
	cQry += " 			WHERE "
	cQry += " 			HIST.D_E_L_E_T_ = ' ' "
	cQry += " 			AND HIST.UF7_FILIAL = '" + xFilial("UF7")+ "' "
	cQry += "			AND HIST.UF7_CONTRA = UF2.UF2_CODIGO "
	cQry += " 		) "	
	cQry += " ORDER BY LAST_VENC,CODIGO_PROTHEUS "
	
	If Select("QRYUF2") > 0
		QRYUF2->( DbCloseArea() )
	Endif
	
	TcQuery cQry NEW Alias "QRYUF2"
	
	While QRYUF2->( !Eof() ) 
	    
	    oSay:cCaption := ("Processando Contrato: " + Alltrim( QRYUF2->CODIGO_PROTHEUS ) + " ")
		ProcessMessages()
		
		If UF2->( DbSeek( xFilial("UF2") + QRYUF2->CODIGO_PROTHEUS ) )
				
			//verifico se ja existe reajuste definido para o contrato, caso sim, apenas atualizo o mesmo
			If !UF7->( DbSeek( xFilial("UF7") + UF2->UF2_CODIGO ) )
			
			  	lAtu	:= .T.
			  	cCodigo	:= GetSxENum("UF7","UF7_CODIGO")		
			
			else
			
				cCodigo  := UF7->UF7_CODIGO
				lAtu	 := .F.
			
			endif                                                                                       
				
			//proximo reajuste do contrato
			cNextReaj	:= SubStr( QRYUF2->LAST_VENC , 5 , 2) + SubStr( QRYUF2->LAST_VENC , 1 , 4) 	
				
			fWrite(nHdlLog , "------------------------------------------------------------------" )
			fWrite(nHdlLog , "Contrato: " + UF2->UF2_CODIGO )
			fWrite(nHdlLog , cPulaLinha ) 
				
			fWrite(nHdlLog , "Legado: " + UF2->UF2_CODANT )
			fWrite(nHdlLog , cPulaLinha ) 
				
			fWrite(nHdlLog , "Proximo Reajuste: " + cNextReaj )
			fWrite(nHdlLog , cPulaLinha ) 
			fWrite(nHdlLog , "------------------------------------------------------------------" )
			fWrite(nHdlLog , cPulaLinha ) 
				
			RecLock("UF7",lAtu) 
				
				UF7->UF7_FILIAL := xFilial("UF7")
				UF7->UF7_CODIGO := cCodigo
				UF7->UF7_CONTRA := UF2->UF2_CODIGO
				UF7->UF7_DATA   := dDataBase
				UF7->UF7_PROREA := PadL(Alltrim( cNextReaj ),TamSX3("UF7_PROREA")[1],"0" )
				UF7->UF7_IMPORT := "S"  
				UF7->UF7_TPINDI := UF2->UF2_INDICE
			
			UF7->( MsUnlock() )		
			    
		else
				
			fWrite(nHdlLog , "------------------------------------------------------------------" )
			fWrite(nHdlLog , "Contrato: " + UF2->UF2_CODIGO + " nao encontrado!")
			fWrite(nHdlLog , cPulaLinha ) 
			
		endif
	
		QRYUF2->( DbSkip() )                
	
	EndDo

else
	
	lRet := .F.
	Help(,,'Help',,"Não foi possivel criar o arquivo de relatorio de reprocessamento, favor o diretorio selecionado!",1,0)	

endif


Return(lRet)