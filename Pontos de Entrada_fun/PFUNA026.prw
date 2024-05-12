#INCLUDE 'PROTHEUS.CH'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} RFUNA027
//TODO Ponto de Entrada da rotina
de cadastro de historico de adiantamentos
@author Raphael Martins
@since 02/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

User Function PFUNA026()

Local aParam 		:= PARAMIXB
Local oObj			:= aParam[1]
Local cIdPonto		:= aParam[2]
Local cIdModel		:= IIf( oObj<> NIL, oObj:GetId(), aParam[3] )
Local cClasse		:= IIf( oObj<> NIL, oObj:ClassName(), '' )
Local oModelUG8		:= oObj:GetModel( 'UG8MASTER' )
Local oModelUG9		:= oObj:GetModel( 'UG9DETAIL' )
Local lRet 			:= .T.
Local aArea			:= GetArea()
Local cCodigo		:= ""
Local cContrato		:= ""

if cIdPonto == "MODELVLDACTIVE" // ponto de entrada na abertura da tela

	// se a operação for de exclusão
	// devo validar se os títulos do adiantamento não foram baixados
	if oObj:GetOperation() == 5

		// percorro todos os itens do reajuste
		UG9->(DbSetOrder(1)) // UG9_FILIAL + UG9_CODIGO + UG9_ITEM        
		if UG9->(DbSeek(xFilial("UG9") + UG8->UG8_CODIGO))
			
			While UG9->(!Eof()) .AND. UG9->UG9_FILIAL == xFilial("UG9") .And. UG9->UG9_CODIGO == UG8->UG8_CODIGO

				// posiciono no respectivo título a receber
				SE1->(DbSetOrder(1)) // E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
				if SE1->(DbSeek(xFilial("SE1") + UG9->UG9_PREFIX + UG9->UG9_NUM + UG9->UG9_PARCEL + UG9->UG9_TIPO))
					
					//valido se o titulo esta em cobranca
					if !VldCobranca(UG9->UG9_PREFIX,UG9->UG9_NUM,UG9->UG9_PARCEL,UG9->UG9_TIPO)
						lRet := .F.
						Help( ,, "Help - MODELVLDACTIVE",, "Não é possível excluir este reajuste pois existem títulos em processo de cobrança!", 1, 0 )
						Exit
					elseIf SE1->E1_VALOR <> SE1->E1_SALDO // se o título já teve alguma baixa
						lRet := .F.
						Help( ,, "Help - MODELVLDACTIVE",, "Não é possível excluir este adiantamento pois existem títulos que já foram baixados!", 1, 0 )
						Exit
					endif
				
				endif
				
				UG9->(DbSkip())
			
			EndDo
		
		endif
		
	endif

elseIf cIdPonto ==  'MODELCOMMITTTS' // confirmação do cadastro
	
	if oObj:GetOperation() == 5 // se for exclusão
		
		cCodigo			:= oModelUG8:GetValue('UG8_CODIGO')
		cContrato 		:= oModelUG8:GetValue('UG8_CONTRA')
			
		// Inicio o controle de transação
		BeginTran()
				
		// gero os títulos
		FWMsgRun(,{|oSay| lRet := ExcluiAdt(oSay,cCodigo,oModelUG9)},'Aguarde...','Excluindo o adiantamento do contrato...')
				
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

RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} RFUNA027
//TODO Funcao para excluir o adiantamento
@author Raphael Martins
@since 02/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function ExcluiAdt(oSay,cCodigo,oModelUG9)

Local aArea			:= GetArea()
Local aAreaUG9		:= UG9->(GetArea())
Local aAreaSE1		:= SE1->(GetArea())
Local lRet 			:= .T.
Local aFin040		:= {}
Local nX			:= 1
Local nLinhaAtual	:= oModelUG9:GetLine()
Local cPrefixo		:= ""
Local cNumero		:= ""
Local cParcela		:= ""
Local cTipo			:= ""
					
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

For nX := 1 To oModelUG9:Length()

	// posiciono na linha atual
	oModelUG9:Goline(nX)
	
	cPrefixo	:= oModelUG9:GetValue('UG9_PREFIX')
	cNumero		:= oModelUG9:GetValue('UG9_NUM')
	cParcela	:= oModelUG9:GetValue('UG9_PARCEL')
	cTipo		:= oModelUG9:GetValue('UG9_TIPO')
	
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
				Help( ,, 'Atenção',, "Ocorreu um erro na exclusão do título " + AllTrim(SE1->E1_NUM) + " parcela " + AllTrim(SE1->E1_PARCELA) + ". Não será possível continuar a operação.", 1, 0 )                  
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
oModelUG9:Goline(nLinhaAtual)

RestArea(aAreaSE1)
RestArea(aAreaUG9)
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
