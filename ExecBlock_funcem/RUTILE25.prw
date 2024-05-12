#include 'totvs.ch'
#include 'parmtype.ch'
#INCLUDE "hbutton.ch"

/*/{Protheus.doc} RUTILE25
Tela de impressão da nota fiscal de serviço
@type function
@version 
@author Wellington Gonçalves
@since 07/11/2016
@return return_type, return_description
@history 07/06/2020, g.sampaio, VPDV-473 - Como o program é de uso para os modulos de
cemiterio e funerario foi implementado o fonte RUTILE25 para substituir o antigo 
RFUNA023, para melhor organização do projeto.
/*/
User Function RUTILE25(cFilServ)

    Local oSay1			:= NIL
    Local oSay2			:= NIL
    Local oSay3			:= NIL
    Local oGetInscri	:= NIL
    Local oGetNota		:= NIL
    Local oGetVer		:= NIL
    Local oButton1		:= NIL
    Local oGroup1		:= NIL
    Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
    Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)
    Local cGetInscri	:= ""
    Local cGetNota		:= Space(TamSX3("F2_NFELETR")[1]) // número da nota da prefeitura
    Local cGetVer		:= Space(TamSX3("F2_CODNFE")[1]) // código de verificação da nota
    Local cF3Nota		:= iif(lFuneraria,"F2FNFS",iif(lCemiterio,"F2CNFS","SF2"))
    Local cBkpFil       := cFilAnt

    Default cFilServ    := cFilAnt

    Static oDlg			:= NIL

    cFilAnt := cFilServ
    cGetInscri := AllTrim(RetDadosSM0(cEmpAnt,cFilAnt,"M0_INSCM")) // inscrição municipal da empresa

    DEFINE MSDIALOG oDlg TITLE "Impressão da NFS-e" FROM 000, 000  TO 100, 697 COLORS 0, 16777215 PIXEL

    @ 005, 005 GROUP oGroup1 TO 035, 345 PROMPT "  Parâmetros de impressão:  " OF oDlg COLOR 0, 16777215 PIXEL

    @ 018, 010 SAY oSay1 PROMPT "Inscrição Municipal:" SIZE 100, 006 OF oDlg COLORS 0, 16777215 PIXEL
    @ 016, 060 MSGET oGetInscri VAR cGetInscri SIZE 035, 010 OF oDlg COLORS 0, 16777215 PIXEL WHEN .F.

    @ 018, 105 SAY oSay2 PROMPT "Número da Nota:" SIZE 100, 006 OF oDlg COLORS 0, 16777215 PIXEL
    @ 016, 148 MSGET oGetNota VAR cGetNota SIZE 035, 010 F3 cF3Nota OF oDlg COLORS 0, 16777215 HASBUTTON PIXEL

    @ 018, 202 SAY oSay3 PROMPT "Cód. de Verificação:" SIZE 100, 006 OF oDlg COLORS 0, 16777215 PIXEL
    @ 016, 255 MSGET oGetVer VAR cGetVer SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 016, 302 BUTTON oButton1 PROMPT "Visualizar" Action(FWMsgRun(,{|oSay| iif(GoPageNFS(cGetInscri,cGetNota,cGetVer) , oDlg:End() , .F.)},'Aguarde...','Imprimindo Nota...')) SIZE 037, 012 OF oDlg PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

    cFilAnt := cBkpFil

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ GoPageNFS º Autor ³ Wellington Gonçalves        º Data³ 08/11/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que visualiza a nota no site da prefeitura				  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Cemitério e Funerária               			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GoPageNFS(cGetInscri,cGetNota,cGetVer)

Local lRet	:= .T.
Local cLink	:= SuperGetMV('MV_XLINKNF',,"")

    // valido se todos os campos foram preenchidos
    if !Empty(cGetInscri) .AND. !Empty(cGetNota) .AND. !Empty(cGetVer)

	    // se o link da prefeitura estiver correto
        if AT("#inscricao#",cLink) > 0 .AND. AT("#nota#",cLink) > 0 .AND. AT("#verificador#",cLink) > 0
		
		// atualizo o link de consulta na prefeitura
		cLink := StrTran(cLink,"#inscricao#",cGetInscri)
		cLink := StrTran(cLink,"#nota#",Alltrim(cGetNota))
		cLink := StrTran(cLink,"#verificador#",Alltrim(cGetVer))
		
		// atualizo o browser
		//oTIBrowser:Navigate(cLink)
		ShellExecute( "Open", cLink , "", "C:\", 1 )

		// dou um intervalo de 3 segundos para a página ser processada
		Sleep(3000)
	
        else
            MsgInfo("O parâmetro de configuração da nota (MV_XLINKNF) não existe ou está incorreto!","Atenção!")
            lRet := .F.		
        
        endif
	
    else
        MsgInfo("Informe os dados da nota!","Atenção!")
        lRet := .F.

    endif

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ RetDadosSM0 º Autor ³ Wellington Gonçalves      º Data³ 08/11/2016 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Função que retorna informações do cadastro de empresas			  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Cemitério e Funerária               			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function RetDadosSM0(cEmp,cFil,cCampo)
 
Local aArea		:= GetArea()       
Local aAreaSM0	:= SM0->(GetArea()) 
Local cRet		:= ""    

cRet := Posicione("SM0",1,cEmp + cFil,cCampo)

RestArea(aAreaSM0)
RestArea(aArea)

Return(cRet)
