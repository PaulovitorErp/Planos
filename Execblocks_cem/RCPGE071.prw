#Include "topconn.ch"
#INCLUDE "totvs.ch"

/*/{Protheus.doc} RCPGE071
Rotina para realizar cobranca adicional por inclusao de 
autorizado
@type function
@version 1.0 
@author Raphael Martins
@since 3/16/2023
/*/
User Function RCPGE071()                        

Local cContrato         := ""
Local cCliente          := ""
Local cLoja             := ""
Local cNome             := ""
Local nValor            := 0 
Local aAutorizados      := {}
Local lRet              := .T.
Local oGridAutorizados  := NIL
Local oDlg              := NIL
Local oGrpDados         := NIL
Local oSyContrato       := NIL
Local oSyCliente        := NIL
Local oSyLoja           := NIL
Local oSyNome           := NIL
Local oGrpValor         := NIL
Local oSyValor          := NIL
Local oGrpAutorizado    := NIL
Local oContrato         := NIL
Local oCliente          := NIL
Local oLoja             := NIL
Local oNome             := NIL
Local oValor            := NIL

cContrato         := U00->U00_CODIGO
cCliente          := U00->U00_CLIENT
cLoja             := U00->U00_LOJA
cNome             := U00->U00_NOMCLI

if ConsultaAutorizados(cContrato,@aAutorizados)

  DEFINE MSDIALOG oDlg TITLE "Autorizados Adicionais" FROM 000, 000  TO 370, 500 COLORS 0, 16777215 PIXEL

    
    @ 003, 003 GROUP oGrpDados TO 059, 249 PROMPT "Dados do Contrato" OF oDlg COLOR 0, 16777215 PIXEL
    
    @ 015, 005 SAY oSyContrato PROMPT "Contrato:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 014, 033 MSGET oContrato VAR cContrato SIZE 040, 007 When .F. OF oDlg COLORS 0, 16777215 PIXEL
    
    @ 029, 005 SAY oSyCliente PROMPT "Cliente:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 033 MSGET oCliente VAR Alltrim(cCliente) SIZE 040, 007 When .F. OF oDlg COLORS 0, 16777215 PIXEL
    
    @ 029, 094 SAY oSyLoja PROMPT "Loja:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 028, 110 MSGET oLoja VAR cLoja SIZE 040, 007 When .F. OF oDlg COLORS 0, 16777215 PIXEL

    @ 044, 005 SAY oSyNome PROMPT "Nome:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 043, 033 MSGET oNome VAR cNome SIZE 125, 007 When .F. OF oDlg COLORS 0, 16777215 PIXEL

    @ 064, 003 GROUP oGrpValor TO 096, 249 PROMPT "Digite o valor de Cobranca Adicional por Acrescimo de Autorizado(s)" OF oDlg COLOR 0, 16777215 PIXEL
    
    @ 079, 006 SAY oSyValor PROMPT "R$ por Autorizado:" SIZE 056, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 078, 060 MSGET oValor VAR nValor SIZE 070, 007 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999,999,999.99"

    @ 097, 003 GROUP oGrpAutorizado TO 162, 249 PROMPT "Autorizados Inseridos" OF oDlg COLOR 0, 16777215 PIXEL
    
    CriaGridAut(oDlg,oGridAutorizados,@aAutorizados)
    
    @ 165, 161 BUTTON oConfirmar PROMPT "Confirmar" SIZE 045, 012 Action( FWMsgRun(,{|oSay| lRet := GeraTitulo(cContrato,aAutorizados,nValor,oDlg) },'Aguarde...','Gerando Cobranca Adicional...')) OF oDlg PIXEL
    @ 165, 211 BUTTON oFechar PROMPT "Fechar" SIZE 037, 012 Action(oDlg:End()) OF oDlg PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

endif

Return(lRet)

/*/{Protheus.doc} CriaGridAut
Funcao para criar objeto da grid de autorizados para cobranca
@type function
@version  1.0
@author raphaelgarcia
@since 3/16/2023
@param oDlg, object, Dialog da Tela Principal
@param oGridAutorizados, object, Objeto da Grid de Autorizados
@param aAutorizados, array, Array para setar no objeto da Grid
/*/
Static Function CriaGridAut(oDlg,oGridAutorizados,aAutorizados)

Default oGridAutorizados  := NIL
Default aAutorizados      := {}

    @ 108, 006 LISTBOX oGridAutorizados Fields HEADER "Item","Nome" SIZE 238, 048 OF oDlg PIXEL ColSizes 50,50
	oGridAutorizados:SetArray(aAutorizados)
	oGridAutorizados:bLine := {|| {;
		aAutorizados[oGridAutorizados:nAt,1],;
		aAutorizados[oGridAutorizados:nAt,2],;
		}}
    // DoubleClick event
    oGridAutorizados:bLDblClick := {|| aAutorizados[oGridAutorizados:nAt,1] := !aAutorizados[oGridAutorizados:nAt,1],;
    oGridAutorizados:DrawSelect()}

Return

/*/{Protheus.doc} ConsultaAutorizados
Funcao para consultar autorizados com pendencias de cobranca adicional
@type function
@version 1.0 
@author Raphael Martins
@since 3/16/2023
@param cContrato, character, Codigo do Contrato
@param aAutorizados, array, Arrau aAutorizados para preenchimento da GRID
@return logical, Retorna se encontrou autorizado para cobrar
/*/
Static Function ConsultaAutorizados(cContrato,aAutorizados)

Local aArea     := GetArea()
Local aAreaU00  := U00->(GetArea())
Local aAreaU02  := U02->(GetArea())
Local lRet      := .F.
Local cQuery    := ""

cQuery := "SELECT "
cQuery += " R_E_C_N_O_ ID_REG, "
cQuery += " U02_ITEM ITEM, " 
cQuery += " U02_NOME NOME "
cQuery += " FROM "
cQuery += RetSQLName("U02") 
cQuery += " WHERE "
cQuery += " D_E_L_E_T_ = '' "
cQuery += " AND U02_FILIAL = '" + xFilial("U02") + "' "
cQuery += " AND U02_CODIGO = '" + cContrato + "' "
cQuery += " AND U02_COBAUT = 'S' "
cQuery += " AND U02_VLRAUT = 0 "
cQuery += " ORDER BY U02_ITEM "

if Select("QU02") > 0 
    QU02->(DbCloseArea())
endif

TcQuery cQuery New Alias "QU02"

if QU02->(!Eof())

    lRet := .T.
    While QU02->(!Eof())

        AAdd(aAutorizados,{QU02->ITEM,QU02->NOME,QU02->ID_REG})
        
        QU02->(DbSkip())
    Enddo

endif

QU02->(DbCloseArea())

RestArea(aArea)
RestArea(aAreaU00)
RestArea(aAreaU02)

Return(lRet)

/*/{Protheus.doc} GeraTitulo
Funcao para gerar titulo de cobranca adicional de acrescimo de autorizados
@type function
@version 1.p 
@author raphaelgarcia
@since 3/20/2023
@param cContrato, character, Codigo do Contrato
@param aAutorizados, array, Array com os autorizados inseridos
@param nValor, numeric, valor de cobranca adicional
@param oDlg, object, Dialog da Tela
@return logical, Titulo gerado, sim ou nao
/*/
Static Function GeraTitulo(cContrato,aAutorizados,nValor,oDlg)

Local aArea     := GetArea()
Local aAreaU00  := U00->(GetArea())
Local aAreaSE1  := SE1->(GetArea())
Local cTipoTaxa := SuperGetMV("MV_XTPTXAU",.F.,"AUT")
Local cNatTaxa  := SuperGetMV("MV_XNATXAU",.F.,"AUT")
Local cPrefixo  := SuperGetMv("MV_XPREFCT",.F.,"CTR")
Local cParcela  := ""
Local aFin040   := {}
Local lRet      := .T.
Local nTotalAut := Len(aAutorizados)

Private lMsErroAuto := .F.

U00->(DBSetOrder(1)) //U00_FILIAL + U00_CODIGO 

if U00->(MsSeek(xFilial("U00")+cContrato))
  
  cParcela := RetProxParcela(cContrato,cPrefixo,cTipoTaxa)

  AAdd(aFin040, {"E1_PREFIXO"	, cPrefixo         			    , Nil })
  AAdd(aFin040, {"E1_EMISSAO"	, dDatabase	                , Nil })
  AAdd(aFin040, {"E1_NUM"		  , cContrato	                , Nil })
  AAdd(aFin040, {"E1_PARCELA"	, cParcela	                , Nil })
  AAdd(aFin040, {"E1_TIPO"	  , cTipoTaxa			            , Nil })
  AAdd(aFin040, {"E1_NATUREZ"	, cNatTaxa				          , Nil })
  AAdd(aFin040, {"E1_CLIENTE"	, U00->U00_CLIENT				    , Nil })
  AAdd(aFin040, {"E1_LOJA"	  , U00->U00_LOJA				      , Nil })
  AAdd(aFin040, {"E1_VENCTO"	, dDatabase	                , Nil })
  AAdd(aFin040, {"E1_VENCREA"	, DataValida(dDatabase)			, Nil })
  AAdd(aFin040, {"E1_VALOR"	  , nValor * nTotalAut	      , Nil })
  AAdd(aFin040, {"E1_XFORPG"	, U00->U00_FORPG			      , Nil })
  AAdd(aFin040, {"E1_XCONTRA"	, cContrato		              , Nil })

  MSExecAuto({|x,y| FINA040(x,y)},aFin040,3)

  // verifico se teve a inclusao do titulo
	If lMsErroAuto

    Help(NIL, NIL, "Atenção!", NIL,;
     "Não foi possivel Gerar o Titulo de Cobranca Adicional, veja o motivo a seguir!", 1,;
     0, NIL, NIL, NIL, NIL, NIL)

    MostraErro()

    lRet := .F.
		DisarmTransaction()
  
  else

      //flag valor de cobranca adicional
      AtAutorizado(cContrato,aAutorizados,nValor)
      Help(NIL, NIL, "Sucesso!", NIL,;
      "Taxa de Inclusao de Autorizado gerado com sucesso!", 1,;
     0, NIL, NIL, NIL, NIL, NIL)

      oDlg:End()
  endif

else
    Help(NIL, NIL, "Atenção!", NIL, "Contrato não encontrado, taxa nao gerada!", 1, 0, NIL, NIL, NIL, NIL, NIL)
    lRet := .F.
endif


RestArea(aArea)
RestArea(aAreaU00)
RestArea(aAreaSE1)
Return(lRet)

/*/{Protheus.doc} RetProxParcela
funcao para buscar a ultima parcela
@type function
@version 1.0
@author Raphael Martins
@since 20/03/2023
@param cContrato, character, codigo do contrato
@param cPref, character, prefixo do titulo
@param cTipo, character, tipo do titulo
@return character, proxima parcela
/*/
Static Function RetProxParcela(cContrato, cPref, cTipo)
	
  Local cQuery		:= ""
  Local cRetorno  := ""

	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	Endif

	cQuery := "SELECT MAX(E1_PARCELA) AS NROPARC"
	cQuery += " FROM "+RetSqlName("SE1")+""
	cQuery += " WHERE D_E_L_E_T_ 	<> '*'"
	cQuery += " AND E1_FILIAL 	= '"+xFilial("SE1")+"'"
	cQuery += " AND E1_XCONTRA 	= '"+cContrato+"'"
	cQuery += " AND E1_PREFIXO 	= '"+cPref+"'"
	cQuery += " AND E1_TIPO 	= '"+cTipo+"'"

	TcQuery cQuery NEW Alias "QRYSE1"

	If QRYSE1->(!EOF())
		cRetorno := Soma1(QRYSE1->NROPARC)
	Else
		cRetorno := "001"
	Endif

	If Select("QRYSE1") > 0
		QRYSE1->(DbCloseArea())
	Endif

Return(cRetorno)


/*/{Protheus.doc} AtAutorizado
Atualiza o autorizado com o valor de cobranca
@type function
@version 1.0 
@author raphaelgarcia
@since 3/20/2023
@param cContrato, character, Codigo do Contrato
@param aAutorizados, array, Array com os autorizados inseridos
@param nValor, numeric, Valor Total 
/*/
Static Function AtAutorizado(cContrato,aAutorizados,nValor)

Local aAreaU02  := U02->(GetArea())
Local nX        := 0 

For nX := 1 To Len(aAutorizados)

    U02->(DbGoto(aAutorizados[nX,3]))

    RecLock("U02",.F.)

    U02->U02_VLRAUT := nValor

    U02->(MsUnlock())

Next nX 

RestArea(aAreaU02)
Return()
