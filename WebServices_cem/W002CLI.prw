#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://10.1.1.79:2200/WS_CADCONTRCEM.apw?WSDL
Gerado em        11/08/16 14:10:02
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _QNMZSSS ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSWS_CADCONTRCEM
------------------------------------------------------------------------------- */

WSCLIENT WSWS_CADCONTRCEM

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD CADCONTRCEM

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSAESTCLI                AS WS_CADCONTRCEM_ADADOSCLI
	WSDATA   oWSAESTCONTR              AS WS_CADCONTRCEM_ADADOSCONTR
	WSDATA   cCADCONTRCEMRESULT        AS string

	// Estruturas mantidas por compatibilidade - NÃO USAR
	WSDATA   oWSADADOSCLI              AS WS_CADCONTRCEM_ADADOSCLI
	WSDATA   oWSADADOSCONTR            AS WS_CADCONTRCEM_ADADOSCONTR

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSWS_CADCONTRCEM
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160510 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSWS_CADCONTRCEM
	::oWSAESTCLI         := WS_CADCONTRCEM_ADADOSCLI():New()
	::oWSAESTCONTR       := WS_CADCONTRCEM_ADADOSCONTR():New()

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSADADOSCLI       := ::oWSAESTCLI
	::oWSADADOSCONTR     := ::oWSAESTCONTR
Return

WSMETHOD RESET WSCLIENT WSWS_CADCONTRCEM
	::oWSAESTCLI         := NIL 
	::oWSAESTCONTR       := NIL 
	::cCADCONTRCEMRESULT := NIL 

	// Estruturas mantidas por compatibilidade - NÃO USAR
	::oWSADADOSCLI       := NIL
	::oWSADADOSCONTR     := NIL
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSWS_CADCONTRCEM
Local oClone := WSWS_CADCONTRCEM():New()
	oClone:_URL          := ::_URL 
	oClone:oWSAESTCLI    :=  IIF(::oWSAESTCLI = NIL , NIL ,::oWSAESTCLI:Clone() )
	oClone:oWSAESTCONTR  :=  IIF(::oWSAESTCONTR = NIL , NIL ,::oWSAESTCONTR:Clone() )
	oClone:cCADCONTRCEMRESULT := ::cCADCONTRCEMRESULT

	// Estruturas mantidas por compatibilidade - NÃO USAR
	oClone:oWSADADOSCLI  := oClone:oWSAESTCLI
	oClone:oWSADADOSCONTR := oClone:oWSAESTCONTR
Return oClone

// WSDL Method CADCONTRCEM of Service WSWS_CADCONTRCEM

WSMETHOD CADCONTRCEM WSSEND oWSAESTCLI,oWSAESTCONTR WSRECEIVE cCADCONTRCEMRESULT WSCLIENT WSWS_CADCONTRCEM
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CADCONTRCEM xmlns="http://10.1.1.79:2200/">'
cSoap += WSSoapValue("AESTCLI", ::oWSAESTCLI, oWSAESTCLI , "ADADOSCLI", .T. , .F., 0 , NIL, .F.) 
cSoap += WSSoapValue("AESTCONTR", ::oWSAESTCONTR, oWSAESTCONTR , "ADADOSCONTR", .T. , .F., 0 , NIL, .F.) 
cSoap += "</CADCONTRCEM>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://10.1.1.79:2200/CADCONTRCEM",; 
	"DOCUMENT","http://10.1.1.79:2200/",,"1.031217",; 
	"http://10.1.1.79:2200/WS_CADCONTRCEM.apw")

::Init()
::cCADCONTRCEMRESULT :=  WSAdvValue( oXmlRet,"_CADCONTRCEMRESPONSE:_CADCONTRCEMRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure ADADOSCLI

WSSTRUCT WS_CADCONTRCEM_ADADOSCLI
	WSDATA   oWSACLI                   AS WS_CADCONTRCEM_ARRAYOFWSESTRCLI
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_CADCONTRCEM_ADADOSCLI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_CADCONTRCEM_ADADOSCLI
Return

WSMETHOD CLONE WSCLIENT WS_CADCONTRCEM_ADADOSCLI
	Local oClone := WS_CADCONTRCEM_ADADOSCLI():NEW()
	oClone:oWSACLI              := IIF(::oWSACLI = NIL , NIL , ::oWSACLI:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_CADCONTRCEM_ADADOSCLI
	Local cSoap := ""
	cSoap += WSSoapValue("ACLI", ::oWSACLI, ::oWSACLI , "ARRAYOFWSESTRCLI", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ADADOSCONTR

WSSTRUCT WS_CADCONTRCEM_ADADOSCONTR
	WSDATA   oWSACONTR                 AS WS_CADCONTRCEM_ARRAYOFWSESTRCONTR
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_CADCONTRCEM_ADADOSCONTR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_CADCONTRCEM_ADADOSCONTR
Return

WSMETHOD CLONE WSCLIENT WS_CADCONTRCEM_ADADOSCONTR
	Local oClone := WS_CADCONTRCEM_ADADOSCONTR():NEW()
	oClone:oWSACONTR            := IIF(::oWSACONTR = NIL , NIL , ::oWSACONTR:Clone() )
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_CADCONTRCEM_ADADOSCONTR
	Local cSoap := ""
	cSoap += WSSoapValue("ACONTR", ::oWSACONTR, ::oWSACONTR , "ARRAYOFWSESTRCONTR", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure ARRAYOFWSESTRCLI

WSSTRUCT WS_CADCONTRCEM_ARRAYOFWSESTRCLI
	WSDATA   oWSWSESTRCLI              AS WS_CADCONTRCEM_WSESTRCLI OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_CADCONTRCEM_ARRAYOFWSESTRCLI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_CADCONTRCEM_ARRAYOFWSESTRCLI
	::oWSWSESTRCLI         := {} // Array Of  WS_CADCONTRCEM_WSESTRCLI():New()
Return

WSMETHOD CLONE WSCLIENT WS_CADCONTRCEM_ARRAYOFWSESTRCLI
	Local oClone := WS_CADCONTRCEM_ARRAYOFWSESTRCLI():NEW()
	oClone:oWSWSESTRCLI := NIL
	If ::oWSWSESTRCLI <> NIL 
		oClone:oWSWSESTRCLI := {}
		aEval( ::oWSWSESTRCLI , { |x| aadd( oClone:oWSWSESTRCLI , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_CADCONTRCEM_ARRAYOFWSESTRCLI
	Local cSoap := ""
	aEval( ::oWSWSESTRCLI , {|x| cSoap := cSoap  +  WSSoapValue("WSESTRCLI", x , x , "WSESTRCLI", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure ARRAYOFWSESTRCONTR

WSSTRUCT WS_CADCONTRCEM_ARRAYOFWSESTRCONTR
	WSDATA   oWSWSESTRCONTR            AS WS_CADCONTRCEM_WSESTRCONTR OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_CADCONTRCEM_ARRAYOFWSESTRCONTR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_CADCONTRCEM_ARRAYOFWSESTRCONTR
	::oWSWSESTRCONTR       := {} // Array Of  WS_CADCONTRCEM_WSESTRCONTR():New()
Return

WSMETHOD CLONE WSCLIENT WS_CADCONTRCEM_ARRAYOFWSESTRCONTR
	Local oClone := WS_CADCONTRCEM_ARRAYOFWSESTRCONTR():NEW()
	oClone:oWSWSESTRCONTR := NIL
	If ::oWSWSESTRCONTR <> NIL 
		oClone:oWSWSESTRCONTR := {}
		aEval( ::oWSWSESTRCONTR , { |x| aadd( oClone:oWSWSESTRCONTR , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_CADCONTRCEM_ARRAYOFWSESTRCONTR
	Local cSoap := ""
	aEval( ::oWSWSESTRCONTR , {|x| cSoap := cSoap  +  WSSoapValue("WSESTRCONTR", x , x , "WSESTRCONTR", .F. , .F., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure WSESTRCLI

WSSTRUCT WS_CADCONTRCEM_WSESTRCLI
	WSDATA   cCBAIRRO                  AS string
	WSDATA   cCCEP                     AS string
	WSDATA   cCCGC                     AS string
	WSDATA   cCCODMUN                  AS string
	WSDATA   cCCOMPL                   AS string
	WSDATA   cCDDD                     AS string
	WSDATA   cCEMAIL                   AS string
	WSDATA   cCEND                     AS string
	WSDATA   cCEST                     AS string
	WSDATA   cCINSCEST                 AS string
	WSDATA   cCINSCMUN                 AS string
	WSDATA   cCNOME                    AS string
	WSDATA   cCNREDUZ                  AS string
	WSDATA   cCPTOREF                  AS string
	WSDATA   cCRG                      AS string
	WSDATA   cCTEL                     AS string
	WSDATA   cCTPPESSOA                AS string
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_CADCONTRCEM_WSESTRCLI
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_CADCONTRCEM_WSESTRCLI
Return

WSMETHOD CLONE WSCLIENT WS_CADCONTRCEM_WSESTRCLI
	Local oClone := WS_CADCONTRCEM_WSESTRCLI():NEW()
	oClone:cCBAIRRO             := ::cCBAIRRO
	oClone:cCCEP                := ::cCCEP
	oClone:cCCGC                := ::cCCGC
	oClone:cCCODMUN             := ::cCCODMUN
	oClone:cCCOMPL              := ::cCCOMPL
	oClone:cCDDD                := ::cCDDD
	oClone:cCEMAIL              := ::cCEMAIL
	oClone:cCEND                := ::cCEND
	oClone:cCEST                := ::cCEST
	oClone:cCINSCEST            := ::cCINSCEST
	oClone:cCINSCMUN            := ::cCINSCMUN
	oClone:cCNOME               := ::cCNOME
	oClone:cCNREDUZ             := ::cCNREDUZ
	oClone:cCPTOREF             := ::cCPTOREF
	oClone:cCRG                 := ::cCRG
	oClone:cCTEL                := ::cCTEL
	oClone:cCTPPESSOA           := ::cCTPPESSOA
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_CADCONTRCEM_WSESTRCLI
	Local cSoap := ""
	cSoap += WSSoapValue("CBAIRRO", ::cCBAIRRO, ::cCBAIRRO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCEP", ::cCCEP, ::cCCEP , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCGC", ::cCCGC, ::cCCGC , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCODMUN", ::cCCODMUN, ::cCCODMUN , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CCOMPL", ::cCCOMPL, ::cCCOMPL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CDDD", ::cCDDD, ::cCDDD , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CEMAIL", ::cCEMAIL, ::cCEMAIL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CEND", ::cCEND, ::cCEND , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CEST", ::cCEST, ::cCEST , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CINSCEST", ::cCINSCEST, ::cCINSCEST , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CINSCMUN", ::cCINSCMUN, ::cCINSCMUN , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CNOME", ::cCNOME, ::cCNOME , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CNREDUZ", ::cCNREDUZ, ::cCNREDUZ , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CPTOREF", ::cCPTOREF, ::cCPTOREF , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CRG", ::cCRG, ::cCRG , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CTEL", ::cCTEL, ::cCTEL , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CTPPESSOA", ::cCTPPESSOA, ::cCTPPESSOA , "string", .T. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure WSESTRCONTR

WSSTRUCT WS_CADCONTRCEM_WSESTRCONTR
	WSDATA   cCDIAVENC                 AS string
	WSDATA   cCDTINC                   AS string
	WSDATA   cCFAQUI                   AS string
	WSDATA   cCPLANO                   AS string
	WSDATA   cCTPCOB                   AS string
	WSDATA   cCTPREA                   AS string
	WSDATA   nNQTDPARC                 AS float
	WSDATA   nNVALOR                   AS float
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT WS_CADCONTRCEM_WSESTRCONTR
	::Init()
Return Self

WSMETHOD INIT WSCLIENT WS_CADCONTRCEM_WSESTRCONTR
Return

WSMETHOD CLONE WSCLIENT WS_CADCONTRCEM_WSESTRCONTR
	Local oClone := WS_CADCONTRCEM_WSESTRCONTR():NEW()
	oClone:cCDIAVENC            := ::cCDIAVENC
	oClone:cCDTINC              := ::cCDTINC
	oClone:cCFAQUI              := ::cCFAQUI
	oClone:cCPLANO              := ::cCPLANO
	oClone:cCTPCOB              := ::cCTPCOB
	oClone:cCTPREA              := ::cCTPREA
	oClone:nNQTDPARC            := ::nNQTDPARC
	oClone:nNVALOR              := ::nNVALOR
Return oClone

WSMETHOD SOAPSEND WSCLIENT WS_CADCONTRCEM_WSESTRCONTR
	Local cSoap := ""
	cSoap += WSSoapValue("CDIAVENC", ::cCDIAVENC, ::cCDIAVENC , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CDTINC", ::cCDTINC, ::cCDTINC , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CFAQUI", ::cCFAQUI, ::cCFAQUI , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CPLANO", ::cCPLANO, ::cCPLANO , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CTPCOB", ::cCTPCOB, ::cCTPCOB , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("CTPREA", ::cCTPREA, ::cCTPREA , "string", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NQTDPARC", ::nNQTDPARC, ::nNQTDPARC , "float", .T. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NVALOR", ::nNVALOR, ::nNVALOR , "float", .T. , .F., 0 , NIL, .F.) 
Return cSoap


