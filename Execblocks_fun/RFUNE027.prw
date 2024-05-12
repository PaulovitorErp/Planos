#include "topconn.ch"   
#INCLUDE 'Protheus.ch' 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RFUNE027 º Autor ³ Raphael Martins 	   º Data³ 28/07/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para alterar a data do proximo reajusto do contrato º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funeraria                                            	   ±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RFUNE027()

Local aArea		:= GetArea()
Local aAreaUF7	:= UF7->( GetArea() ) 

//valido se o reajuste gerado e proveniente do reprocessamento realizado, depois verifico se ja existe reajuste gerado pela rotina
If UF7->UF7_IMPORT == 'S' 

	If FindReaj(UF7->UF7_CODIGO,UF7->UF7_CONTRA)
		MontaTela(UF7->UF7_CODIGO,UF7->UF7_CONTRA,UF7->UF7_PROREA)
	else
		Help(,,'Help',,"Reajuste não poderá ser alterado, pois já existe outros reajustes superiores a este!",1,0)
	endif

Else
	Help(,,'Help',,"Reajuste não poderá ser alterado, pois não proveniente de importação!",1,0)	
EndIf

RestArea(aArea) 
RestArea(aAreaUF7) 
	
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MontaTela º Autor ³ Raphael Martins 	   º Data³ 28/07/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para montar tela de alteracao de reajuste do contrato±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funeraria		                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaTela(cCodigo,cContrato,cReajste)                        

Local oConfirmar	:= NIL	
Local oCancelar		:= NIL
Local oContrato		:= NIL
Local oReajAtual	:= NIL	
Local oNextReaj		:= NIL
Local oSay1			:= NIL
Local oSay2			:= NIL
Local oSay3			:= NIL
Local oGroup1		:= NIL
Local oGroup2		:= NIL
Local oTela			:= NIL
Local oFont1		:= TFont():New("MS Sans Serif",,016,,.T.,,,,,.F.,.F.)
Local cContrato 	:= cContrato
Local cReajAtual 	:= cReajste
Local cNextReaj 	:= Space(TamSX3("UF7_PROREA")[1])

  DEFINE MSDIALOG oTela TITLE "Alterar Reajuste" FROM 000, 000  TO 160, 350 COLORS 0, 16777215 PIXEL

    @ 002, 003 GROUP oGroup1 TO 058, 173 OF oTela COLOR 0, 16777215 PIXEL
    
    @ 009, 007 SAY oSay1 PROMPT "Contrato:" SIZE 025, 007 OF oTela FONT oFont1 COLORS 0, 16777215 PIXEL
    @ 007, 061 MSGET oContrato VAR cContrato SIZE 060, 010 When .F. OF oTela COLORS 0, 16777215 PIXEL
    
    @ 024, 007 SAY oSay2 PROMPT "Reajuste Atual:" SIZE 056, 007 OF oTela FONT oFont1 COLORS 0, 16777215 PIXEL
    @ 021, 061 MSGET oReajAtual VAR cReajAtual SIZE 060, 010 When .F. Picture "@R 99/9999" OF oTela COLORS 0, 16777215 PIXEL
    
    @ 038, 007 SAY oSay3 PROMPT "Proximo Reajuste:" SIZE 062, 007 OF oTela FONT oFont1 COLORS 0, 16777215 PIXEL
    @ 036, 061 MSGET oNextReaj VAR cNextReaj SIZE 060, 010 Picture "@R 99/9999" OF oTela COLORS 0, 16777215 PIXEL
    
    @ 059, 003 GROUP oGroup2 TO 076, 173 OF oTela COLOR 0, 16777215 PIXEL
    
    @ 063, 091 BUTTON oConfirmar PROMPT "Confirmar" SIZE 037, 010 Action( Confirma(cNextReaj,cCodigo,oTela) ) OF oTela PIXEL
    @ 063, 132 BUTTON oCancelar PROMPT "Fechar" SIZE 037, 010 Action( oTela:End() ) OF oTela PIXEL

  ACTIVATE MSDIALOG oTela CENTERED


Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FindReaj º Autor ³ Raphael Martins 	   º Data³ 28/07/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para validar se existe outros reajustes do mesm contrato±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Funeraria		                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FindReaj(cCodigo,cContrato)

Local aArea		:= GetArea()
Local aAreaUF7	:= UF7->( GetArea() ) 
Local cQry 		:= "" 
Local lRet 		:= .T.

cQry := " SELECT COUNT(*) TOTAL "
cQry += " FROM " 
cQry += " " + RetSQLName("UF7") + " "
cQry += " WHERE "
cQry += " D_E_L_E_T_ = ' ' 
cQry += " AND UF7_FILIAL = '"+ xFilial("UF7") +"' "
cQry += " AND UF7_CODIGO <> '" + cCodigo + "' "
cQry += " AND UF7_CONTRA = '" + cContrato + "' "

If Select("QRYUF7") > 0
	QRYUF7->(DbCloseArea())
Endif

TcQuery cQry NEW Alias "QRYUF7"
	
If QRYUF7->TOTAL > 0
	lRet := .F.
Endif 
	
RestArea(aArea) 
RestArea(aAreaUF7) 

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Confirma º Autor ³ Raphael Martins 	   º Data³ 28/07/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para confirmar a alteracao do reajuste do contrato   ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Vale do Cerrado                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Confirma(cNextReaj,cCodigo,oTela)

Local nMes		:= Val( SubStr(cNextReaj,1,2) )
Local nAno		:= Val( SubStr(cNextReaj,3,4) )
Local cRefIni	:= ""	

UF7->( DbSetOrder(1) ) //UF7_FILIAL + UF7_CODIGO 

//valido se a data informada e valida
If nMes > 0 .And. nMes <= 12 .And. nAno > 2000 

	If UF7->( DbSeek( xFilial("UF7") + cCodigo ) )	
	
		RecLock("UF7",.F.)
		
		UF7->UF7_PROREA	:= cNextReaj
	
		UF7->( MsUnlock() )
		
		MsgInfo("Reajuste alterado com sucesso!")
		
		oTela:End()
		
	else
		Help(,,'Help',,"Reajuste não encontrado, verifique se o mesmo foi excluido da base!!",1,0)
	endif
		
else
	Help(,,'Help',,"Data Informada está incorreta, Favor a data digitada!",1,0)	
endif

Return()

