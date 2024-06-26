#include "topconn.ch"   
#INCLUDE 'Protheus.ch' 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RCPGE009 � Autor � Raphael Martins 	   � Data� 28/07/2017 ���
�������������������������������������������������������������������������͹��
���Desc.     � Rotina para alterar a data do proximo reajusto do contrato ���
�������������������������������������������������������������������������͹��
���Uso       � Vale do Cerrado                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function RCPGE009()

Local aArea		:= GetArea()
Local aAreaU20	:= U20->( GetArea() ) 

//valido se o reajuste gerado e proveniente do reprocessamento realizado, depois verifico se ja existe reajuste gerado pela rotina
If U20->U20_IMPORT == 'S' 

	If FindReaj(U20->U20_CODIGO,U20->U20_CONTRA)
		MontaTela(U20->U20_CODIGO,U20->U20_CONTRA,U20->U20_REFFIM)
	else
		Help(,,'Help',,"Reajuste n�o poder� ser alterado, pois j� existe outros reajustes superiores a este!",1,0)
	endif

Else
	Help(,,'Help',,"Reajuste n�o poder� ser alterado, pois n�o proveniente de importa��o!",1,0)	
EndIf

RestArea(aArea) 
RestArea(aAreaU20) 
	
Return()
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MontaTela � Autor � Raphael Martins 	   � Data� 28/07/2017 ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para montar tela de alteracao de reajuste do contrato��
�������������������������������������������������������������������������͹��
���Uso       � Vale do Cerrado                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MontaTela(cCodigo,cContrato,cRefFim)                        

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
Local cReajAtual 	:= cRefFim
Local cNextReaj 	:= Space(TamSX3("U20_REFFIM")[1])

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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FindReaj � Autor � Raphael Martins 	   � Data� 28/07/2017 ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para validar se existe outros reajustes do mesm contrato�
�������������������������������������������������������������������������͹��
���Uso       � Vale do Cerrado                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FindReaj(cCodigo,cContrato)

Local aArea		:= GetArea()
Local aAreaU20	:= U20->( GetArea() ) 
Local cQry 		:= "" 
Local lRet 		:= .T.

cQry := " SELECT COUNT(*) TOTAL "
cQry += " FROM " 
cQry += " " + RetSQLName("U20") + " "
cQry += " WHERE "
cQry += " D_E_L_E_T_ = ' ' 
cQry += " AND U20_FILIAL = '"+ xFilial("U20") +"' "
cQry += " AND U20_CODIGO <> '" + cCodigo + "' "
cQry += " AND U20_CONTRA = '" + cContrato + "' "

If Select("QRYU20") > 0
	QRYU20->(DbCloseArea())
Endif

TcQuery cQry NEW Alias "QRYU20"
	
If QRYU20->TOTAL > 0
	lRet := .F.
Endif 
	
RestArea(aArea) 
RestArea(aAreaU20) 

Return(lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � Confirma � Autor � Raphael Martins 	   � Data� 28/07/2017 ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para confirmar a alteracao do reajuste do contrato   ��
�������������������������������������������������������������������������͹��
���Uso       � Vale do Cerrado                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Confirma(cNextReaj,cCodigo,oTela)

Local nMes		:= Val( SubStr(cNextReaj,1,2) )
Local nAno		:= Val( SubStr(cNextReaj,3,4) )
Local dRefIni	:= CTOD("")
Local cRefIni	:= ""	

U20->( DbSetOrder(1) ) //U20_FILIAL + U20_CODIGO 

//valido se a data informada e valida
If nMes > 0 .And. nMes <= 12 .And. nAno > 2000 

	If U20->( DbSeek( xFilial("U20") + cCodigo ) )	
	
		RecLock("U20",.F.)
			
			dRefIni := MonthSub( CTOD( "01/" + cValToChar( nMes ) + "/" + cValToChar( nAno ) ), 11 )
			cRefIni	:= SubStr(  DtoS( dRefIni ),5,2)  + SubStr( DtoS( dRefIni ),1,4)
			
				
			U20->U20_REFINI	:= cRefIni 
			U20->U20_REFFIM	:= cNextReaj
	
		U20->( MsUnlock() )
		
		MsgInfo("Reajuste alterado com sucesso!")
		
		oTela:End()
		
	else
		Help(,,'Help',,"Reajuste n�o encontrado, verifique se o mesmo foi excluido da base!!",1,0)
	endif
		
else
	Help(,,'Help',,"Data Informada est� incorreta, Favor a data digitada!",1,0)	
endif

Return()

