#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.1.1.79:2200/WS_CONTRLOC.apw?WSDL
Gerado em        11/08/16 14:02:22
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _TSMEQQB ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWS_CONTRLOC
------------------------------------------------------------------------------- */

WSCLIENT WSWS_CONTRLOC

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CONSCONTRLOC

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cCDATACONS                AS string
	WSDATA   cCONSCONTRLOCRESULT       AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWS_CONTRLOC
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160510 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWS_CONTRLOC
Return

WSMETHOD RESET WSCLIENT WSWS_CONTRLOC
	::cCDATACONS         := NIL 
	::cCONSCONTRLOCRESULT := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWS_CONTRLOC
Local oClone := WSWS_CONTRLOC():New()
	oClone:_URL          := ::_URL 
	oClone:cCDATACONS    := ::cCDATACONS
	oClone:cCONSCONTRLOCRESULT := ::cCONSCONTRLOCRESULT
Return oClone

// WSDL Method CONSCONTRLOC of Service WSWS_CONTRLOC

WSMETHOD CONSCONTRLOC WSSEND cCDATACONS WSRECEIVE cCONSCONTRLOCRESULT WSCLIENT WSWS_CONTRLOC
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CONSCONTRLOC xmlns="http://10.1.1.79:2200/">'
cSoap += WSSoapValue("CDATACONS", ::cCDATACONS, cCDATACONS , "string", .T. , .F., 0 , NIL, .F.) 
cSoap += "</CONSCONTRLOC>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://10.1.1.79:2200/CONSCONTRLOC",; 
	"DOCUMENT","http://10.1.1.79:2200/",,"1.031217",; 
	"http://10.1.1.79:2200/WS_CONTRLOC.apw")

::Init()
::cCONSCONTRLOCRESULT :=  WSAdvValue( oXmlRet,"_CONSCONTRLOCRESPONSE:_CONSCONTRLOCRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



