#include "protheus.ch" 
#include "topconn.ch"
#include "tbiconn.ch" 

/*/{Protheus.doc} RCPGE002
Responsável pela comunicação de condolencias, executado via Schedule
@author TOTVS
@since 13/05/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RCPGE002()
/***********************/

Local lExec
Local lContinua	:= .F.	
Local cQry 		:= ""
Private nStart	:= 0


RpcSetType(3)
PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101" TABLES "U00","SA1","U04","U23"

FwLogMsg("INFO", , "REST", FunName(), "", "01", "INICIO DO JOB RCPGE002 - MENSAGEM DE CONDOLÊNCIA", 0, (nStart - Seconds()), {}) 


lExec := SuperGetMv("MV_XJOBCON",.F.,.T.) //Default ativo

If lExec

	DbSelectArea("U23")
	U23->(DbSetOrder(1)) //U23_FILIAL+U23-CODIGO
	U23->(DbGoTop())
	
	While U23->(!EOF()) .And. xFilial("U23") == U23->U23_FILIAL
	
		If U23->U23_CONDOL == "S" .And. U23->U23_STATUS == "A" //Mala direta de condolências e ativa
			lContinua	:= .T.
			cU23Bmp		:= U23->U23_BITMAP
			cU23Msg		:= U23->U23_MENSAG
			Exit
		Endif
		
		U23->(DbSkip())
	EndDo
	
	If lContinua
		
		FwLogMsg("INFO", , "REST", FunName(), "", "01", "Mala direta de condolências encontrada.", 0, (nStart - Seconds()), {}) 

		If Select("QRYCONDOL") > 0
			QRYCONDOL->(DbCloseArea())
		Endif
		
		cQry := "SELECT U00.U00_CLIENT, U00.U00_LOJA, SA1.A1_EMAIL, SA1.A1_NOME, U04.U04_QUEMUT, SIT = '07 DIAS'"
		cQry += " FROM "+RetSqlName("U04")+" U04 INNER JOIN "+RetSqlName("U00")+" U00 ON U04.U04_CODIGO 	= U00.U00_CODIGO"
		cQry += " 																		AND U00.D_E_L_E_T_	<> '*'"
		cQry += " 																		AND U00.U00_FILIAL	= '"+xFilial("U00")+"'"
		cQry += " 								INNER JOIN "+RetSqlName("SA1")+" SA1 ON U00.U00_CLIENT 		= SA1.A1_COD"
		cQry += " 																		AND U00.U00_LOJA	= SA1.A1_LOJA"
		cQry += " 																		AND SA1.D_E_L_E_T_	<> '*'"
		cQry += " 																		AND SA1.A1_FILIAL	= '"+xFilial("SA1")+"'"
		cQry += " 																		AND SA1.A1_XRECMSG	= 'S'" //Deseja receber msg de condolências
		cQry += " WHERE U04.D_E_L_E_T_ 						<> '*'"
		cQry += " AND U04.U04_FILIAL 						= '"+xFilial("U04")+"'"
		cQry += " AND U04.U04_TIPO							= 'J'" //Jazigo
		cQry += " AND CONVERT(CHAR(10),GETDATE() - 7,112)  	= U04.U04_DTUTIL" //7º Dia
		
		cQry := ChangeQuery(cQry)
	
		TcQuery cQry NEW Alias "QRYCONDOL"
		
		If QRYCONDOL->(!EOF())

			While QRYCONDOL->(!EOF())
			
				If !Empty(QRYCONDOL->A1_EMAIL)
			
					FwLogMsg("INFO", , "REST", FunName(), "", "01", "Envio de mensagem de condolência para o cliente: " + QRYCONDOL->U00_CLIENT + "/" + QRYCONDOL->U00_LOJA + " - " +QRYCONDOL->A1_NOME, 0, (nStart - Seconds()), {}) 

					EnvMsg(QRYCONDOL->A1_EMAIL,QRYCONDOL->A1_NOME,QRYCONDOL->U04_QUEMUT,cU23Bmp,cU23Msg)
				Else
					
					FwLogMsg("INFO", , "REST", FunName(), "", "01","E-mail não cadastrado para o cliente: " + QRYCONDOL->U00_CLIENT + "/" + QRYCONDOL->U00_LOJA + " - " +QRYCONDOL->A1_NOME, 0, (nStart - Seconds()), {}) 

				Endif
				
				QRYCONDOL->(DbSkip())
			EndDo
		Else
			
			FwLogMsg("INFO", , "REST", FunName(), "", "01","Nenhum sepultado localizado.", 0, (nStart - Seconds()), {}) 

		Endif

		If Select("QRYCONDOL") > 0
			QRYCONDOL->(DbCloseArea())
		Endif
	Else
		
		FwLogMsg("INFO", , "REST", FunName(), "", "01","Nenhuma Mala Direta de condolências configurada.", 0, (nStart - Seconds()), {}) 

	Endif
Else
	
	FwLogMsg("WARN", , "REST", FunName(), "", "01","JOB RCPGE002 desabilitado.", 0, (nStart - Seconds()), {}) 

Endif

FwLogMsg("INFO", , "REST", FunName(), "", "01","FIM DO JOB RCPGE002 - MENSAGEM DE CONDOLÊNCIA ", 0, (nStart - Seconds()), {}) 

RESET ENVIRONMENT

Return

/*********************************************************/
Static Function EnvMsg(_cTo,_cNome,_cFalecido,_cBmp,_cMsg)
/*********************************************************/

Local cServer 		:= AllTrim(GetNewPar("MV_RELSERV","")) //Servidor de envio de E-mail: smtp.gmail.com:587
Local cFrom			:= AllTrim(SuperGetMv("MV_XCTAMLD",.F.,"protheus.md@valedocerrado.com.br")) //Conta Servidor de E-mail: protheus.md@valedocerrado.com.br
Local cAccount		:= Alltrim(SuperGetMv("MV_XUSRMLD",.F.,"protheus.md@valedocerrado.com.br")) //Usuário para autenticação no Servidor de E-mail: protheus.md@valedocerrado.com.br
Local cPassword		:= Alltrim(SuperGetMv("MV_XPASMDL",.F.,"totvs*1234")) //Senha para autenticação no Servidor de E-mail: totvs*1904/totvs*1234
Local lAutentica	:= GetMv("MV_RELAUTH") //Determina se o Servidor de Email necessita de Autenticação. Atualmente igual a .T.
Local cSubject		:= "Comunicado - " + AllTrim(U_RetInfSM0(cEmpAnt,cFilAnt,"M0_NOMECOM")) // Nome COmercial da Empresa Logada
Local cBody			:= ""
Local cTo			:= _cTo

Local cNome			:= ""

Local lOk
Local lContinua		:= .T.
Local nCont			:= 0

Private cStartPath

cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")  

if Empty(cServer)
	
	FwLogMsg("ERROR", , "REST", FunName(), "", "01","Servidor de Envio de E-mail não definido no parâmetro <MV_RELSERV>.", 0, (nStart - Seconds()), {}) 

	lContinua := .F.
Endif

If lContinua
	
	If Empty(cFrom)

		FwLogMsg("ERROR", , "REST", FunName(), "", "01","Conta para acesso ao Servidor de E-mail não definida no parâmetro <MV_RELACNT>.", 0, (nStart - Seconds()), {}) 

		lContinua := .F.
	Endif
Endif

If lContinua

	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lOk
	
	If !lOk
		
		FwLogMsg("ERROR", , "REST", FunName(), "", "01","Falha na conexão com Servidor de E-Mail.", 0, (nStart - Seconds()), {}) 

	Else
		If lAutentica .And. !MailAuth(cAccount,cPassword)
			
			FwLogMsg("ERROR", , "REST", FunName(), "", "01","Falha na autenticação do usuário.", 0, (nStart - Seconds()), {}) 

			DISCONNECT SMTP SERVER
			Return
		Endif
		
		If !Empty(_cBmp)
		
			If !RetDispImg(_cBmp)
				DISCONNECT SMTP SERVER
				Return
			Endif						
		Endif
		
		cBody := RetBody(_cNome,_cFalecido,_cBmp,_cMsg)
		
		SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody RESULT lOK
		
		If !lOK
			
			FwLogMsg("ERROR", , "REST", FunName(), "", "01","Falha no envio do destinatário: "+AllTrim(cNome)+".", 0, (nStart - Seconds()), {}) 

		Else
	    	nCont++
		Endif
	Endif
	
	DISCONNECT SMTP SERVER
Endif   

If nCont == 0

	FwLogMsg("ERROR", , "REST", FunName(), "", "01","Nenhum registro selecionado.", 0, (nStart - Seconds()), {}) 

ElseIf nCont > 0

	FwLogMsg("ERROR", , "REST", FunName(), "", "01",cValToChar(nCont) + " e-mail´s enviados com sucesso.", 0, (nStart - Seconds()), {}) 

Endif

Return

/********************************/
Static Function RetDispImg(_cBmp)
/********************************/

Local lOk			:= .T.

Local oFTPClient	:= TFTPClient():New()

Local cEndFtp		:= SuperGetMv("MV_XFTPEND",.F.,"ftp.valedocerrado.com.br")
Local nPortFtp		:= SuperGetMv("MV_XFTPPOR",.F.,21)
Local cUserFtp		:= SuperGetMv("MV_XFTPUSE",.F.,"teste@valedocerrado.com.br")
Local cPassFtp		:= SuperGetMv("MV_XFTPPAS",.F.,"cpg*159357")
Local cPathFtp		:= SuperGetMv("MV_XFTPPAT",.F.,"/img/")

Local cEntry		:= _cBmp
Local cNameFile		:= "img_md.jpg"
Local cFileLocal	:= cStartPath + "img_md.jpg"

If File(cStartPath + "img_md.jpg")
	FErase(cStartPath + "img_md.jpg") //Deleta arquivo
Endif

If RepExtract(cEntry,cFileLocal)

	If oFTPClient:FTPConnect(cEndFtp,nPortFtp,cUserFtp,cPassFtp) == 0
	
		If oFTPClient:ChDir(cPathFtp) == 0

			oFTPClient:DeleteFile(cNameFile)
			oFTPClient:bFireWallMode := .F. //default - Ativo
			oFTPClient:nTransferMode := 0 //default - stream
			oFTPClient:nTransferType := 1 //default - image
		
			If oFTPClient:SendFile(cFileLocal,cNameFile) <> 0
		
				FwLogMsg("ERROR", , "REST", FunName(), "", "01","Falha no upload do arquivo de imagem.", 0, (nStart - Seconds()), {}) 

				oFTPClient:Close()
				lOk := .F.
			EndIf
		Else
		
			FwLogMsg("ERROR", , "REST", FunName(), "", "01","O diretório <"+cPath+"> não foi localizado no FTP.", 0, (nStart - Seconds()), {}) 

			oFTPClient:Close()
			lOk := .F.
		Endif

		oFTPClient:Close()
	Else

		FwLogMsg("ERROR", , "REST", FunName(), "", "01","Falha na conexão com o Servidor FTP <"+cEndFtp+"> e Porta <"+cPortFtp+">.", 0, (nStart - Seconds()), {}) 

		lOk := .F.
	Endif
Else

	FwLogMsg("ERROR", , "REST", FunName(), "", "01","Não foi possível a extração da imagem.", 0, (nStart - Seconds()), {}) 

	lOk := .F.
Endif

Return lOk

/*****************************************************/
Static Function RetBody(_cNome,_cFalecido,_cBmp,_cMsg)
/*****************************************************/

Local cHtml 	:= ""
Local cEndFile	:= SuperGetMv("MV_XIMGMD",.F.,"http://www.valedocerrado.com.br/valedocerrado.com.br/img_md/img/img_md.jpg")

cHtml := '<html>'
cHtml += '	<head>'
cHtml += '		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
cHtml += '	</head>'
cHtml += '	<body>'

If !Empty(_cBmp)
	cHtml += '		<center><img src="'+cEndFile+'" width="400" height="300" hspace="0" border="0"></center>'
Endif

cHtml += '		<p align="left"><b><font face="Arial" size="3">Sr(a) '+AllTrim(_cNome)+',</b></p>'
cHtml += '		<p align="left"><font face="Arial" size="3">A empresa '+ Alltrim( SM0->M0_NOMECOM ) +' solidariza-se com a família do Sr(a) '+AllTrim(_cFalecido)+'.</p>'
cHtml += '		<p align="center"><font face="Arial" size="2">'+AllTrim(_cMsg)+'</p>'
cHtml += '	</body>'
cHtml += '</html>'

Return cHtml