#INCLUDE 'PROTHEUS.CH'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} RFUNA028
//TODO Ponto de entrada do cadastro de historico de taxa de
manutenção de contratos - Funeraria
@author Raphael Martins
@since 03/04/2018
@version 1.0
@return 
@type function
/*/


User Function PFUNA028()

Local aArea			:= GetArea()
Local aAreaUH1		:= UH1->(GetArea())
Local aParam 		:= PARAMIXB
Local oObj			:= aParam[1]
Local cIdPonto		:= aParam[2]
Local cIdModel		:= IIf( oObj<> NIL, oObj:GetId(), aParam[3] )
Local cClasse		:= IIf( oObj<> NIL, oObj:ClassName(), '' )
Local oModelUH0		:= oObj:GetModel('UH0MASTER')
Local oModelUH1		:= oObj:GetModel('UH1DETAIL')
Local lRet 			:= .T.
Local cCodigo		:= ""
Local cContrato		:= ""
Local nVlAdicional	:= 0

if cIdPonto == "MODELVLDACTIVE" // ponto de entrada na abertura da tela

	// se a operação for de exclusão
	// devo validar se os títulos da manutenção não foram baixados	
	if oObj:GetOperation() == 5 // se for exclusão

		UH1->(DbSetOrder(1)) // UH1_FILIAL + UH1_CODIGO + UH1_ITEM                
		if UH1->(DbSeek(xFilial("UH1") + UH0->UH0_CODIGO))
		
			While UH1->(!Eof()) .AND. UH1->UH1_FILIAL == xFilial("UH1") .AND. UH1->UH1_CODIGO == UH0->UH0_CODIGO
			
				SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
				if SE1->(DbSeek(xFilial("SE1") + UH1->UH1_PREFIX + UH1->UH1_NUM + UH1->UH1_PARCEL + UH1->UH1_TIPO))
					
					//valido se o titulo ja se encontra em cobranca
					If !VldCobranca(xFilial("SE1"),UH1->UH1_PREFIX,UH1->UH1_NUM,UH1->UH1_PARCEL,UH1->UH1_TIPO)
				
						Help( ,, 'Atenção',, "O título " + AllTrim(SE1->E1_NUM) + " parcela " + AllTrim(SE1->E1_PARCELA) + " se encontra em processo de cobranca. Não será possível continuar a operação.", 1, 0 )
						lRet := .F.
						Exit
				
					elseIf SE1->E1_VALOR <> SE1->E1_SALDO // se o título já teve alguma baixa
				
						lRet := .F.
						Help( ,, "Help - MODELVLDACTIVE",, "Não é possível excluir esta manutenção pois existem títulos que já foram baixados!", 1, 0 )
						Exit
				
					endif
					
				endif
				
				UH1->(DbSkip())
			
			EndDo 
		
		endif
	
	endif
	
elseIf cIdPonto == "MODELCOMMITTTS" // confirmação do cadastro
	
	if oObj:GetOperation() == 5 // se for exclusão
	
		cCodigo 		:= oModelUH0:GetValue('UH0_CODIGO')
		cContrato 		:= oModelUH0:GetValue('UH0_CONTRA')
		nVlAdicional	:= oModelUH0:GetValue('UH0_VLADIC')
			
		// Inicio o controle de transação
		BeginTran()
				
		// excluo os títulos
		FWMsgRun(,{|oSay| lRet := ExcluiManut(oSay,cCodigo,oModelUH1)},'Aguarde...','Excluindo as taxas de manutenção...')

		// se foi realizada a exclusão dos títulos com sucesso
		if lRet
				
			UF2->(DbSetOrder(1)) // UF2_FILIAL + UF2_CODIGO
			if UF2->(DbSeek(xFilial("UF2") + cContrato))
				
				// volto o valor anterior da taxa de manutenção
				if RecLock("UF2",.F.)		
					UF2->UF2_ADIMNT -= nVlAdicional
					UF2->(MsUnLock()) 		
				endif
					
			else
				lRet := .F.	
			endif
						
		endif
				
		// se todo o processamento foi concluído com sucesso
		if lRet   
			// finalizo o controle de transação
			EndTran()
		else				
			// aborto a transação
			DisarmTransaction()		
		endif	
		
	endif
	
EndIf

RestArea(aAreaUH1)
RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} RFUNA028
//TODO Função que faz a exclusão dos títulos da manutençãos - Funeraria
@author Raphael Martins
@since 03/04/2018
@version 1.0
@return 
@type function
/*/

Static Function ExcluiManut(oSay,cCodigo,oModelUH1)

Local aArea			:= GetArea()
Local aAreaSE1		:= SE1->(GetArea())
Local lRet 			:= .T.
Local aFin040		:= {}
Local nX			:= 0
Local nLinhaAtual	:= oModelUH1:GetLine()
Local cPrefixo		:= ""
Local cNumero		:= ""
Local cParcela		:= ""
Local cTipo			:= ""
					
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

For nX := 1 To oModelUH1:Length()

	// posiciono na linha atual
	oModelUH1:Goline(nX)
	
	cPrefixo	:= oModelUH1:GetValue('UH1_PREFIX')
	cNumero		:= oModelUH1:GetValue('UH1_NUM')
	cParcela	:= oModelUH1:GetValue('UH1_PARCEL')
	cTipo		:= oModelUH1:GetValue('UH1_TIPO')
	
	SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	if SE1->(DbSeek(xFilial("SE1") + cPrefixo + cNumero + cParcela + cTipo))
	
		aFin040		:= {}
		lMsErroAuto := .F.
		lMsHelpAuto := .T.
			
		oSay:cCaption := ("Excluindo parcela " + AllTrim(SE1->E1_PARCELA) + "...")
		ProcessMessages()
			
		If SE1->E1_VALOR == SE1->E1_SALDO // somente título que não teve baixa
			
			// faço a exclusão do título do bordero
			SEA->(DbSetOrder(1)) // EA_FILIAL + EA_NUMBOR + EA_PREFIXO + EA_NUM + EA_PARCELA + EA_TIPO + EA_FORNECE + EA_LOJA
			If SEA->(DbSeek(xFilial("SEA") + SE1->E1_NUMBOR + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO))
	
				if RecLock("SEA",.F.)
					SEA->(DbDelete())
					SEA->(MsUnlock())
				endif
			
				if RecLock("SE1",.F.)
					
					SE1->E1_SITUACA	:= "0"
					SE1->E1_OCORREN	:= ""
					SE1->E1_NUMBOR	:= ""
					SE1->E1_DATABOR	:= CTOD("  /  /    ")
					SE1->(MsUnLock())
				
				endif
				
			Endif
			 
			// faço a exclusão do título a receber					
			AAdd(aFin040, {"E1_FILIAL"  , SE1->E1_FILIAL  	, Nil})
			AAdd(aFin040, {"E1_PREFIXO" , SE1->E1_PREFIXO 	, Nil}) 
			AAdd(aFin040, {"E1_NUM"     , SE1->E1_NUM	   	, Nil})
			AAdd(aFin040, {"E1_PARCELA" , SE1->E1_PARCELA	, Nil})
			AAdd(aFin040, {"E1_TIPO"    , SE1->E1_TIPO  	, Nil})
					
			MSExecAuto({|x,y| Fina040(x,y)},aFin040,5)
				
			If lMsErroAuto
				MostraErro()                    
				lRet := .F.
				Exit
			EndIf
		
		else
			Help( ,, 'Atenção',, "Foi realizada uma baixa para o título " + AllTrim(SE1->E1_NUM) + " parcela " + AllTrim(SE1->E1_PARCELA) + ". Não será possível continuar a operação.", 1, 0 )
			lRet := .F.
			Exit
		endif
			
	endif
		
Next nX

// volto para a linha original
oModelUH1:Goline(nLinhaAtual)

RestArea(aAreaSE1)
RestArea(aArea)

Return(lRet)
//////////////////////////////////////////////////////////////////////////
//////    FUNCAO PARA VALIDAR SE O TITULO ESTA EM COBRANCA       ////////
////////////////////////////////////////////////////////////////////////	
Static Function VldCobranca(cFiltTit,cPrefixo,cTitulo,cParcela,cTipo)

Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaSE1	:= SE1->( GetArea() )
Local aAreaSK1	:= SK1->( GetArea() )
Local cQry 		:= "" 

cQry	:= " SELECT COUNT(*) QTD_COB "
cQry 	+= " FROM " 
cQry	+= " 	" + RetSQLName("SK1") + " COBRANCA " 
cQry	+= " INNER JOIN "
cQry 	+= "	" + RetSQLName("SE1") + " TITULO "
cQry	+= " ON COBRANCA.D_E_L_E_T_ = ' ' " 
cQry	+= " AND TITULO.D_E_L_E_T_ = ' ' " 
cQry	+= " AND COBRANCA.K1_FILORIG = TITULO.E1_FILIAL "
cQry	+= " AND COBRANCA.K1_PREFIXO = TITULO.E1_PREFIXO "
cQry	+= " AND COBRANCA.K1_NUM = TITULO.E1_NUM "
cQry	+= " AND COBRANCA.K1_PARCELA = TITULO.E1_PARCELA "
cQry	+= " WHERE " 
cQry	+= " 	TITULO.E1_FILIAL = '" + cFiltTit + "' "
cQry	+= " 	AND TITULO.E1_PREFIXO = '" + cPrefixo + "' "
cQry 	+= " 	AND TITULO.E1_NUM = '" + cTitulo + "' " 
cQry 	+= " 	AND TITULO.E1_PARCELA = '" + cParcela + "' " 
cQry 	+= " 	AND TITULO.E1_TIPO = '" + cTipo + "' "
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
 