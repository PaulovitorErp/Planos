#include "protheus.ch"
#include "apwebsrv.ch" 
#include "tbiconn.ch" 
#include "topconn.ch"

/*/{Protheus.doc} RCPGW001
WebService para Controle de Salas de Locação
@author TOTVS
@since 01/11/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RCPGW001()
/***********************/

WSSERVICE WS_CONTRLOC DESCRIPTION "Serviço para consulta de Reservas de Salas de Velório"

// Método
WSMETHOD ConsContrLoc Description "Consulta Reservas de Salas de Velório"

//Dados de entrada
WSDATA cDataCons	as String

//Dados de resposta
WSDATA cRet			as String

ENDWSSERVICE

WSMETHOD ConsContrLoc WSRECEIVE cDataCons WSSEND cRet WSSERVICE WS_CONTRLOC

Local cQry 		:= ""

Local cInf		:= ""
Local cMsgErr	:= ""
Local aRet		:= {}

If !Empty(::cDataCons)

	If Select("SX2") == 0
		RpcSetType(3)
		Reset Environment
		RpcSetEnv("01","0101")
	Endif
	
	If Select("QRYU25") > 0
		QRYU25->(DbCloseArea())
	Endif
	
	cQry := "SELECT U25_DESCSA, U25_NOMOBT, U25_HRINIC, U25_HRFIM, U25_DESCSE, U25_QUADRA, U25_MODULO, U25_JAZIGO, U25_CREMAT"
	cQry += " FROM "+RetSqlName("U25")+""
	cQry += " WHERE D_E_L_E_T_ 	<> '*'"
	cQry += " AND U25_FILIAL 	= '"+xFilial("U25")+"'"
	cQry += " AND U25_DATA 		= '"+DToS(CToD(::cDataCons))+"'"
	//cQry += " AND U25_HRINIC 	<= '"+SubStr(StrTran(Time(),':'),1,4)+"'
	//cQry += " AND U25_HRFIM 	>= '"+SubStr(StrTran(Time(),':'),1,4)+"'
	cQry += " ORDER BY 1"
	
	cQry := ChangeQuery(cQry)
	//MemoWrite("c:\temp\RCPGW001.txt",cQry)
	TcQuery cQry NEW Alias "QRYU25"
	
	If QRYU25->(!EOF())
	
		While QRYU25->(!EOF())
			
			cInf += U_UXmlTag("RESERVA",;
						U_UXmlTag("SALA",AllTrim(QRYU25->U25_DESCSA),.F.)+;
						U_UXmlTag("OBITO",AllTrim(QRYU25->U25_NOMOBT),.F.)+;
						U_UXmlTag("HORAINI",Transform(QRYU25->U25_HRINIC,"@R 99:99"),.F.)+;
						U_UXmlTag("HORAFIM",Transform(QRYU25->U25_HRFIM,"@R 99:99"),.F.)+;
						U_UXmlTag("SERVICO",AllTrim(QRYU25->U25_DESCSE),.F.)+;
						U_UXmlTag("QUADRA",AllTrim(QRYU25->U25_QUADRA),.F.)+;
						U_UXmlTag("MODULO",AllTrim(QRYU25->U25_MODULO),.F.)+;
						U_UXmlTag("JAZIGO",AllTrim(QRYU25->U25_JAZIGO),.F.)+;
						U_UXmlTag("CREMATORIO",AllTrim(QRYU25->U25_CREMAT),.F.);
					,.T.)
			
			QRYU25->(DbSkip())
		EndDo
	Else
		cMsgErr := "NENHUMA RESERVA DE SALA ENCONTRADA."
	Endif
Else
	cMsgErr := "INFORMACAO |DATA| OBRIGATORIA."
Endif

If Select("QRYU25") > 0
	QRYU25->(DbCloseArea())
Endif

aRet := {!Empty(cMsgErr),cMsgErr,cInf}

::cRet := TrataRet(aRet)

Return .T.    

/*****************************/
Static Function TrataRet(aRet)
/*****************************/

Local cCabXml	:= '<?xml version="1.0" encoding="ISO-8859-1"?>' + CHR(13)+CHR(10) 
Local cErro 	:= ""

cErro := U_UXmlTag("ERRO",;
			U_UXmlTag("STATUS",IIF(aRet[1],"TRUE","FALSE"))+;
			U_UXmlTag("MENSAGEM",aRet[2]);
		,.T.)

Return cCabXml + "<RETORNOPROTHEUS>" + chr(13)+chr(10) + cErro + aRet[3] + "</RETORNOPROTHEUS>"