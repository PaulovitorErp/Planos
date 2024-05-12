#include "topconn.ch"   
#INCLUDE 'Protheus.ch' 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RCPGE010 º Autor ³ Raphael Martins 	   º Data³ 28/07/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para inclusao de reajustes para contratos que nao   º±±
±±º			 ³ possui													  º±±	
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Vale do Cerrado                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RCPGE010(cContrato)

Local aArea		:= GetArea()
Local aAreaU20	:= U20->( GetArea() ) 
Local aAreaU00	:= U00->( GetArea() )
Local cUserAut	:= SuperGetMv("MV_XUSRREA",.F.,"000000;000090")

U00->( DbSetOrder(1) ) //U00_FILIAL + U00_CODIGO
U20->( DbSetOrder(2) ) //U20_FILIAL + U20_CONTRA

//valido se o usuario tem permissao de alterar o reajuste
If RetCodUsr() $ Alltrim( SuperGetMV("MV_XTUSRRE",,'000000/000001') )

	if U00->( DbSeek( xFilial("U00") + cContrato ) ) .And. !Empty(U00->U00_CODANT) 
		
		if !U20->( DbSeek( xFilial("U20") + cContrato ) )
			MontaTela(cContrato,U00->U00_DATA)
		else
			Help(,,'Help',,"Reajuste não poderá ser inserido, pois já existe outros reajustes para o contrato selecionado!",1,0)
		endif
	
	Else
		Help(,,'Help',,"Contrato não encontrado ou não proveniente de importação!",1,0)	
	EndIf
else
	Help(,,'Help',,"Usuário não possui permissão para execução da rotina!",1,0)
endif

RestArea(aArea) 
RestArea(aAreaU20) 
RestArea(aAreaU00) 
	
Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MontaTela º Autor ³ Raphael Martins 	   º Data³ 28/07/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para montar tela de alteracao de reajuste do contrato±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Vale do Cerrado                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MontaTela(cContrato,dDtInclusao)                        

Local oConfirmar	:= NIL	
Local oCancelar		:= NIL
Local oContrato		:= NIL
Local oDtInclusao	:= NIL	
Local oNextReaj		:= NIL
Local oSay1			:= NIL
Local oSay2			:= NIL
Local oSay3			:= NIL
Local oGroup1		:= NIL
Local oGroup2		:= NIL
Local oTela			:= NIL
Local oFont1		:= TFont():New("MS Sans Serif",,016,,.T.,,,,,.F.,.F.)
Local cNextReaj 	:= Space(TamSX3("U20_REFFIM")[1])

  DEFINE MSDIALOG oTela TITLE "Alterar Reajuste" FROM 000, 000  TO 160, 350 COLORS 0, 16777215 PIXEL

    @ 002, 003 GROUP oGroup1 TO 058, 173 OF oTela COLOR 0, 16777215 PIXEL
    
    @ 009, 007 SAY oSay1 PROMPT "Contrato:" SIZE 025, 007 OF oTela FONT oFont1 COLORS 0, 16777215 PIXEL
    @ 007, 061 MSGET oContrato VAR cContrato SIZE 060, 010 When .F. OF oTela COLORS 0, 16777215 PIXEL
    
    @ 024, 007 SAY oSay2 PROMPT "Data Inclusão:" SIZE 056, 007 OF oTela FONT oFont1 COLORS 0, 16777215 PIXEL
    @ 021, 061 MSGET oDtInclusao VAR dDtInclusao SIZE 060, 010 When .F. OF oTela COLORS 0, 16777215 PIXEL
    
    @ 038, 007 SAY oSay3 PROMPT "Proximo Reajuste:" SIZE 062, 007 OF oTela FONT oFont1 COLORS 0, 16777215 PIXEL
    @ 036, 061 MSGET oNextReaj VAR cNextReaj SIZE 060, 010 Picture "@R 99/9999" OF oTela COLORS 0, 16777215 PIXEL
    
    @ 059, 003 GROUP oGroup2 TO 076, 173 OF oTela COLOR 0, 16777215 PIXEL
    
    @ 063, 091 BUTTON oConfirmar PROMPT "Confirmar" SIZE 037, 010 Action( Confirma(cNextReaj,cContrato,oTela) ) OF oTela PIXEL
    @ 063, 132 BUTTON oCancelar PROMPT "Fechar" SIZE 037, 010 Action( oTela:End() ) OF oTela PIXEL

  ACTIVATE MSDIALOG oTela CENTERED


Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Confirma º Autor ³ Raphael Martins 	   º Data³ 28/07/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para confirmar a inclusao do reajuste do contrato    ±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Vale do Cerrado                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Confirma(cNextReaj,cContrato,oTela)

Local nMes		:= Val( SubStr(cNextReaj,1,2) )
Local nAno		:= Val( SubStr(cNextReaj,3,4) )
Local dRefIni	:= CTOD("")
Local cRefIni	:= ""	

U20->( DbSetOrder(1) ) //U20_FILIAL + U20_CODIGO 

//valido se a data informada e valida
If nMes > 0 .And. nMes <= 12 .And. nAno > 2000 

	if RecLock("U20",.T.)
			
		U20->U20_FILIAL := xFilial("U20")
		U20->U20_CODIGO := RetCodU20() 
		U20->U20_CONTRA := cContrato
		U20->U20_DATA   := dDataBase
		
		dRefIni := MonthSub( CTOD( "01/" + cValToChar( nMes ) + "/" + cValToChar( nAno ) ), 11 )
		cRefIni	:= SubStr(  DtoS( dRefIni ),5,2)  + SubStr( DtoS( dRefIni ),1,4)
				
		U20->U20_REFINI	:= cRefIni 
		U20->U20_REFFIM	:= cNextReaj
		U20->U20_IMPORT := "S"
		
		U20->( MsUnlock() )
		
		MsgInfo("Reajuste alterado com sucesso!")
		
		oTela:End()
		
		U20->( ConfirmSX8() )
		
	endif
	
else
	Help(,,'Help',,"Data Informada está incorreta, Favor a data digitada!",1,0)	
endif

Return()
//////////////////////////////////////////////////
///// FUNCAO PARA RETORNAR O CODIGO DA U20	/////
/////////////////////////////////////////////////
Static Function RetCodU20()

Local aAreaU20	:= U20->( GetArea() ) 
Local aArea		:= U20->( GetArea() )
Local cCodigo	:= GetSxeNum("U20","U20_CODIGO")

While U20->( DbSeek( xFilial("U20") + cCodigo ) )
	
	U20->( ConfirmSX8() )
	
	cCodigo	:= GetSxeNum("U20","U20_CODIGO")
	
EndDo  

U20->( ConfirmSX8() )
	
RestArea(aAreaU20)
RestArea(aArea)

Return( cCodigo )

