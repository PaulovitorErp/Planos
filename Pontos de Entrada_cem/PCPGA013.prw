#INCLUDE 'PROTHEUS.CH'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PCPGA013 �Autor �Wellington Gon�alves � Data �  01/09/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada do cadastro de historico de reajuste 	  ���
���          � de contratos do cemit�rio                                  ���
�������������������������������������������������������������������������͹��
���Uso       � Cemit�rio	                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function PCPGA013()

Local aParam 		:= PARAMIXB
Local oObj			:= aParam[1]
Local cIdPonto		:= aParam[2]
Local cIdModel		:= IIf( oObj<> NIL, oObj:GetId(), aParam[3] )
Local cClasse		:= IIf( oObj<> NIL, oObj:ClassName(), '')
Local oModelU20		:= oObj:GetModel('U20MASTER')
Local oModelU21		:= oObj:GetModel('U21DETAIL')
Local lRet 			:= .T.
Local aArea			:= GetArea()
Local cCodigo		:= ""

if cIdPonto == "MODELVLDACTIVE" // ponto de entrada na abertura da tela

	// se a opera��o for de exclus�o
	// devo validar se os t�tulos do reajuste n�o foram baixados
	if oObj:GetOperation() == 5

		// percorro todos os itens do reajuste
		U21->(DbSetOrder(1)) // U21_FILIAL + U21_CODIGO + U21_ITEM        
		if U21->(DbSeek(xFilial("U21") + U20->U20_CODIGO))
		
			While U21->(!Eof()) .AND. U21->U21_FILIAL == xFilial("U21") .And. U20->U20_CODIGO == U21->U21_CODIGO
				
				// posiciono no respectivo t�tulo a receber
				SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
				if SE1->(DbSeek(xFilial("SE1") + U21->U21_PREFIX + U21->U21_NUM + U21->U21_PARCEL + U21->U21_TIPO))
					
					if !VldCobranca(U21->U21_PREFIX,U21->U21_NUM,U21->U21_PARCEL,U21->U21_TIPO)
						lRet := .F.
						Help( ,, "Help - MODELVLDACTIVE",, "N�o � poss�vel excluir este reajuste pois existem t�tulos em processo de cobran�a!", 1, 0 )
						Exit
					elseIf SE1->E1_VALOR <> SE1->E1_SALDO // se o t�tulo j� teve alguma baixa
						lRet := .F.
						Help( ,, "Help - MODELVLDACTIVE",, "N�o � poss�vel excluir este reajuste pois existem t�tulos que j� foram baixados!", 1, 0 )
						Exit
					endif
				
				endif
				
				U21->(DbSkip())
			
			EndDo
		
		endif
		
	endif

elseIf cIdPonto == "MODELCOMMITTTS" // confirma��o do cadastro
	
	if oObj:GetOperation() == 5 // se for exclus�o
	
		cCodigo := oModelU20:GetValue('U20_CODIGO')
			
		// Inicio o controle de transa��o
		BeginTran()
				
		// estorno o reajuste
		FWMsgRun(,{|oSay| lRet := EstornaReaj(oSay,cCodigo,oModelU21)},'Aguarde...','Estornando o reajuste...')
				
		// se todo o processamento foi conclu�do com sucesso
		if lRet   
			// finalizo o controle de transa��o
			EndTran()
		else				
			// aborto a transa��o
			DisarmTransaction()		
		endif	
		
	endif
	
EndIf

RestArea(aArea)

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �EstornaReaj� Autor� Wellington Gon�alves � Data� 01/09/2016 ���
�������������������������������������������������������������������������͹��
���Desc.     � Fun��o que faz o estorno do reajuste do cemit�rio		  ���
�������������������������������������������������������������������������͹��
���Uso       � Cemit�rio	                                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function EstornaReaj(oSay,cCodigo,oModelU21)

Local aArea			:= GetArea()
Local aAreaU21		:= U21->(GetArea())
Local aAreaSE1		:= SE1->(GetArea())
Local lRet 			:= .T.
Local aFin040		:= {}
Local nX			:= 0
Local nLinhaAtual	:= oModelU21:GetLine()
Local cPrefixo		:= ""
Local cNumero		:= ""
Local cParcela		:= ""
Local cTipo			:= ""
					
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

For nX := 1 To oModelU21:Length()

	// posiciono na linha atual
	oModelU21:Goline(nX)
	
	cPrefixo	:= oModelU21:GetValue('U21_PREFIX')
	cNumero		:= oModelU21:GetValue('U21_NUM')
	cParcela	:= oModelU21:GetValue('U21_PARCEL')
	cTipo		:= oModelU21:GetValue('U21_TIPO')
	
	SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	if SE1->(DbSeek(xFilial("SE1") + cPrefixo + cNumero + cParcela + cTipo))
	
		aFin040		:= {}
		lMsErroAuto := .F.
		lMsHelpAuto := .T.
		
		oSay:cCaption := ("Ajustando parcela " + AllTrim(SE1->E1_PARCELA) + "...")
		ProcessMessages()
				 
		// fa�o a altera��o do t�tulo a receber					
		AAdd(aFin040, {"E1_FILIAL"  , SE1->E1_FILIAL  	, Nil})
		AAdd(aFin040, {"E1_PREFIXO" , SE1->E1_PREFIXO 	, Nil}) 
		AAdd(aFin040, {"E1_NUM"     , SE1->E1_NUM	   	, Nil})
		AAdd(aFin040, {"E1_PARCELA" , SE1->E1_PARCELA	, Nil})
		AAdd(aFin040, {"E1_TIPO"    , SE1->E1_TIPO  	, Nil})
		AAdd(aFin040, {"E1_ACRESC"	, U21->U21_ACRINI	, Nil})
		AAdd(aFin040, {"E1_SDACRES"	, U21->U21_ACRINI	, Nil})
				
		MSExecAuto({|x,y| Fina040(x,y)},aFin040,4)
					
		If lMsErroAuto
			MostraErro()     
			Help( ,, 'Aten��o',, "Ocorreu um erro na altera��o do t�tulo " + AllTrim(SE1->E1_NUM) + " parcela " + AllTrim(SE1->E1_PARCELA) + ". N�o ser� poss�vel continuar a opera��o.", 1, 0 )               
			lRet := .F.
			Exit
		EndIf
			
	endif

Next nX

// volto para a linha original
oModelU21:Goline(nLinhaAtual)

RestArea(aAreaSE1)
RestArea(aAreaU21)
RestArea(aArea)

Return(lRet) 
////////////////////////////////////////////////////////////////////
////// FUNCAO PARA VALIDAR SE O TITULO ESTA EM COBRANCA		///////
///////////////////////////////////////////////////////////////////	
Static Function VldCobranca(cPrefixo,cTitulo,cParcela,cTipo)

Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaSE1	:= SE1->( GetArea() )
Local aAreaSK1	:= SK1->( GetArea() )
Local cQry 		:= "" 

cQry	:= " SELECT COUNT(*) QTD_COB "
cQry 	+= " FROM " 
cQry	+= " 	" + RetSQLName("SK1") + " COBRANCA " 
cQry	+= " WHERE " 
cQry	+= " 	COBRANCA.K1_FILORIG = '" + xFilial("SK1") + "' "
cQry	+= " 	AND COBRANCA.K1_PREFIXO = '" + cPrefixo + "' "
cQry	+= " 	AND COBRANCA.K1_NUM 	= '" + cTitulo + "' "
cQry	+= " 	AND COBRANCA.K1_PARCELA = '" + cParcela + "' "
cQry	+= " 	AND COBRANCA.K1_TIPO	= '" + cTipo + "' "
cQry 	+= " 	AND COBRANCA.K1_OPERAD	<> 'XXXXXX' " //XXXXXX Titulo marcado como excecao na cobranca

If Select("QRYCOB") > 0
	QRYCOB->(DbCloseArea())
Endif
	
cQry := ChangeQuery(cQry)
TcQuery cQry NEW Alias "QRYCOB"

QRYCOB->( DbGotop() )

If QRYCOB->QTD_COB > 0
	lRet	:= .F.
endif

RestArea(aArea) 
RestArea(aAreaSE1) 
RestArea(aAreaSK1) 

Return( lRet )
