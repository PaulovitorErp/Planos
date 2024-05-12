#include "ap5mail.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"
#include "TBICONN.CH"
#Include "FONT.CH"
#Include "COLORS.CH"
#Include "winapi.ch" 
#include "TbiCode.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLSendMail  บAutor  ณClแudio Ferreira    บ Data ณ  12/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Classe para enviar email                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                  										  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

CLASS LSendMail 

	DATA cFile 
	DATA cSubject 
	DATA cBody    
	DATA lShedule 
	DATA cTo     
	DATA cCc      
	DATA cFrom      
	DATA cLogMsg     
	DATA lEchoMsg 
	
	METHOD new() constructor
	METHOD SetAttachment(_cFile)
	METHOD SetSubject(_cSubject)
	METHOD SetTo(_cTo)
	METHOD SetCc(_cCc)
	METHOD SetFrom(_cFrom)
	METHOD SetBody(_cBody)
	METHOD SetShedule(_lDef)
	METHOD SetEchoMsg(_lDef)
	METHOD Edit()
	METHOD Send()
	
ENDCLASS

//------------------------------------------------------------------------//
// metodo construtor da classe
//------------------------------------------------------------------------//
METHOD new(cEmail, cAssunto, cCorpo) CLASS LSendMail
	
	Default cEmail := space(100)
	Default cAssunto := "Rede Maraj๓" 
	Default cCorpo := space(240)
	
	::cFile := ""
	::cSubject := cAssunto
	::cBody    := cCorpo
	::lShedule := .F.
	::cTo      := cEmail
	::cCc      := space(100) 
	::cFrom    := space(100)
	::cLogMsg  := ""
	::lEchoMsg :=  .T.
	
Return Self

//------------------------------------------------------------------------//
// seta nome do arquivo anexo do email 
//------------------------------------------------------------------------//
METHOD SetAttachment(_cFile) CLASS LSendMail

	::cFile := _cFile
	
Return     

//------------------------------------------------------------------------//
// seta assunto do email
//------------------------------------------------------------------------//
METHOD SetSubject(_cSubject) CLASS LSendMail

	::cSubject := padr(_cSubject,100)
	
Return     

//------------------------------------------------------------------------//
// seta destinatแrio do email
//------------------------------------------------------------------------//
METHOD SetTo(_cTo) CLASS LSendMail

	::cTo := _cTo
	
Return     

//------------------------------------------------------------------------//
// seta email destinatแio para c๓pia CC
//------------------------------------------------------------------------//
METHOD SetCc(_cCc) CLASS LSendMail

	::cCc := _cCc
	
Return     

//------------------------------------------------------------------------//
// seta emitente do email
//------------------------------------------------------------------------//
METHOD SetFrom(_cFrom) CLASS LSendMail

	::cFrom := _cFrom
	
Return  

//------------------------------------------------------------------------//
// seta html de corpo do email
//------------------------------------------------------------------------//
METHOD SetBody(_cBody) CLASS LSendMail
	
	::cBody := _cBody
	
Return  

//------------------------------------------------------------------------//
// seta se estแ sendo enviado por rotina automแtica
//------------------------------------------------------------------------//
METHOD SetShedule(_lDef) CLASS LSendMail
	
	::lShedule := _lDef
	
Return  

//------------------------------------------------------------------------//
// seta se deve ser mostradas mensagens 
//------------------------------------------------------------------------//
METHOD SetEchoMsg(_lDef) CLASS LSendMail

	::lEchoMsg := _lDef
	
Return  

//------------------------------------------------------------------------//
// chama tela para editar dados de envio do email
//------------------------------------------------------------------------//
METHOD Edit() CLASS LSendMail 

   LOCAL oDlg, nOP, nCol1, nCol2, nSize, nLinha, nLinAux    

   DO WHILE !::lShedule

	   nOp  :=0
	   nCol1:=8
	   nCol2:=33
	   nSize:=225  
	   nLinha:=15 
	
	   DEFINE MSDIALOG oDlg OF oMainWnd FROM 0,0 TO 350,544 PIXEL TITLE "Envio de E-mail"
	
	        nLinAux:=nLinha
	        nLinha+=10
	
	  		@ nLinha,nCol1 Say   "De:"      Size 012,08             OF oDlg PIXEL 
	  		@ nLinha,nCol2 MSGET ::cFrom      Size nSize,10  F3 "_EM" OF oDlg PIXEL 
	        nLinha+=15
	
	  		@ nLinha,nCol1 Say   "Para:"    Size 016,08             OF oDlg PIXEL
	  		@ nLinha,nCol2 MSGET ::cTo        Size nSize,10  F3 "_EM" OF oDlg PIXEL
	        nLinha+=15
	
	  		@ nLinha,nCol1 Say   "CC:"      Size 016,08             OF oDlg PIXEL
	  		@ nLinha,nCol2 MSGET ::cCC        Size nSize,10  F3 "_EM" OF oDlg PIXEL
	        nLinha+=15
	
	  		@ nLinha,nCol1 Say   "Assunto:" Size 021,08             OF oDlg PIXEL
	  		@ nLinha,nCol2 MSGET ::cSubject   Size nSize,10           OF oDlg PIXEL
	        nLinha+=15
	
	  		@ nLinha,nCol1 Say   "Mensagem:"   Size 016,08             OF oDlg PIXEL
	  		@ nLinha,nCol2 Get   ::cBody      Size nSize,20  MEMO     OF oDlg PIXEL HSCROLL
	
	  		@ nLinAux,nCol1-4 To nLinha+28,268 LABEL " Dados de Envio " OF oDlg PIXEL 
	        nLinha+=35
	
	    DEFINE SBUTTON FROM nLinha,(oDlg:nClientWidth-4)/2-90 TYPE 1 ACTION (If(Empty(::cTo),Help("",1,"AVG0001054"),(oDlg:End(),nOp:=1))) ENABLE OF oDlg PIXEL
	    DEFINE SBUTTON FROM nLinha,(oDlg:nClientWidth-4)/2-45 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg PIXEL
	
	   ACTIVATE MSDIALOG oDlg CENTERED
	
	   IF nOp = 0
	      RETURN .f.
	   ENDIF
	
	   EXIT

   ENDDO

Return .t. 

//------------------------------------------------------------------------//
// faz envio do email de acordo com parametros passados
//------------------------------------------------------------------------//
METHOD Send(cServer, cAccount, cPassword, lAutentica, cUserAut, cPassAut) CLASS LSendMail 

	Local nStart	:= 0
	Default cServer := ""
	Default cAccount := ""
	Default cPassword := ""
	Default lAutentica := GetMv("MV_RELAUTH",,.F.) //Determina se o Servidor de Email necessita de Autentica็ใo
	Default cUserAut := ""
	Default cPassAut := ""
	
	IF empty(cServer) .AND. EMPTY((cServer:=AllTrim(GetNewPar("MV_RELSERV",""))))
		::cLogMsg := "Nome do Servidor de Envio de E-mail nao definido no 'MV_RELSERV'"
		if ::lEchoMsg 
			IF !::lShedule
	        	MSGINFO(::cLogMsg)
			ELSE
				FwLogMsg("ERROR", , "REST", FunName(), "", "01", ::cLogMsg, 0, (nStart - Seconds()), {})
			ENDIF
		endif  
		RETURN .F.
	ENDIF

	IF empty(cAccount) .AND. EMPTY((cAccount:=AllTrim(GetNewPar("MV_RELACNT",""))))
		::cLogMsg := "Conta para acesso ao Servidor de E-mail nao definida no 'MV_RELACNT'"
		if ::lEchoMsg 
			IF !::lShedule
				MSGINFO(::cLogMsg)
			ELSE
				FwLogMsg("ERROR", , "REST", FunName(), "", "01", ::cLogMsg, 0, (nStart - Seconds()), {})
			ENDIF
		endif  
		RETURN .F.   
	ENDIF   

	IF EMPTY(::cTo)
		::cLogMsg := "E-mail para envio, nao informado."
		if ::lEchoMsg 
			IF !::lShedule
				MSGINFO(::cLogMsg)
			ELSE
				FwLogMsg("ERROR", , "REST", FunName(), "", "01", ::cLogMsg, 0, (nStart - Seconds()), {})
			ENDIF
		endif  
		RETURN .F.   
	ENDIF   
	
	IF EMPTY(::cFrom)
		IF EMPTY((::cFrom:=GetMV("MV_RELFROM")))
			::cLogMsg := "E-mail do remetente nao informado ou nao definido no parametro MV_RELFROM "
			if ::lEchoMsg 
				IF !::lShedule
					MSGINFO(::cLogMsg)
				ELSE
					FwLogMsg("ERROR", , "REST", FunName(), "", "01", ::cLogMsg, 0, (nStart - Seconds()), {})
				ENDIF
			endif
			RETURN .F.
		ENDIF
	ENDIF

	::cCC  		:= ::cCC + SPACE(200)
	::cTo  		:= ::cTo + SPACE(200)
	::cSubject	:= ::cSubject+SPACE(100)

	cAttachment:=::cFile
	
	if empty(cPassword) 
		cPassword := AllTrim(GetNewPar("MV_RELPSW"," "))         
	endif
	if empty(cUserAut)
		cUserAut  := Alltrim(GetMv("MV_RELAUSR",," "))//Usuแrio para Autentica็ใo no Servidor de Email
	endif
	if empty(cPassAut)
		cPassAut  := Alltrim(GetMv("MV_RELAPSW",," "))//Senha para Autentica็ใo no Servidor de Email
	endif

	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOK

	If !lOK
		::cLogMsg := "Falha na Conexใo com Servidor de E-Mail"
		if ::lEchoMsg 
			IF !::lShedule
				MSGINFO(::cLogMsg)
			ELSE
				FwLogMsg("ERROR", , "REST", FunName(), "", "01", ::cLogMsg, 0, (nStart - Seconds()), {})
			ENDIF
		endif  
		RETURN .F.    
	ELSE                                     
   
		If lAutentica
			If !MailAuth(cUserAut,cPassAut)
				::cLogMsg := "Falha na Autenticacao do Usuario"
				if ::lEchoMsg 
					IF !::lShedule
						MSGINFO(::cLogMsg)
					ELSE
						FwLogMsg("ERROR", , "REST", FunName(), "", "01", ::cLogMsg, 0, (nStart - Seconds()), {})
					ENDIF
				endif  
				DISCONNECT SMTP SERVER RESULT lOk
				RETURN .F.           
			EndIf
		EndIf 
	    
		IF !EMPTY(::cCC)
			SEND MAIL FROM ::cFrom TO ::cTo CC ::cCC SUBJECT ::cSubject BODY ::cBody ATTACHMENT cAttachment RESULT lOK
		ELSE
			SEND MAIL FROM ::cFrom TO ::cTo SUBJECT ::cSubject BODY ::cBody ATTACHMENT cAttachment RESULT lOK
		ENDIF   
		
		If !lOK 
			::cLogMsg := "Falha no Envio do E-Mail: "+ALLTRIM(::cTo)
			if ::lEchoMsg 
				IF !::lShedule
					MSGINFO(::cLogMsg)
				ELSE
					FwLogMsg("ERROR", , "REST", FunName(), "", "01", ::cLogMsg, 0, (nStart - Seconds()), {})
				ENDIF
			endif  
			DISCONNECT SMTP SERVER
			RETURN .F.        
		ENDIF

	ENDIF 

	DISCONNECT SMTP SERVER

	IF lOk 
		::cLogMsg := "E-mail enviado com sucesso."
		if ::lEchoMsg 
			IF !::lShedule
				MSGINFO(::cLogMsg)
			ELSE
				FwLogMsg("INFO", , "REST", FunName(), "", "01", ::cLogMsg, 0, (nStart - Seconds()), {})
			ENDIF
		endif  
	ENDIF   

RETURN lOk 