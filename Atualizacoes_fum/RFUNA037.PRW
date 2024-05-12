#include 'totvs.ch'
#include 'topconn.ch'
#include 'tbiConn.ch'
#include 'fileio.ch'

#define CRLF chr(13)+chr(10)  

/*/{Protheus.doc} RFUNA037
//TODO Geração dos arquivos de envio para a Seguradora Mongeral
@author g.sampaio
@since 02/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function RFUNA037()

Local aArea			:= GetArea()
Local aAreaUF2		:= UF2->(GetArea())
Local cPerg 		:= "RFUNA037"
Local cContratoDe	:= ""
Local cContratoAte	:= ""
Local cPlano		:= ""
Local cDiretorio    := ""
Local dDtAtivAte    := stod("")
Local dDtAtivDe     := stod("")
Local lContinua		:= .T.
Local nTipo 		:= 0

Private __XVEZ 		:= "0"
Private __ASC       := .T.
Private _nMarca		:= 0

// cria as perguntas na SX1
AjustaSx1(cPerg)

// enquanto o usuário não cancelar a tela de perguntas
While lContinua
	
	// chama a tela de perguntas
	lContinua := Pergunte(cPerg,.T.)
	
	if lContinua 
	
		cContratoDe 	:= MV_PAR01
		cContratoAte	:= MV_PAR02 
		cPlano			:= MV_PAR03
		nTipo			:= MV_PAR04  
        cDiretorio      := MV_PAR05
        dDtAtivDe       := MV_PAR06
        dDtAtivAte      := MV_PAR07
		
        // vou fazer a validacao dos parametros preenchidos
		if ValidParam(cContratoDse,cContratoAte,cPlano,nTipo,cDiretorio,dDtAtivDe,dDtAtivAte) 
					
			FWMsgRun(,{|oSay| ConsultaCTR(oSay,cContratoDe,cContratoAte,cPlano,nTipo,cDiretorio,dDtAtivDe,dDtAtivAte) },'Aguarde...','Consultando Contratos para Geração do Arquivo da Seguradora ...')
			
		endif
		
	endif
	
EndDo

RestArea(aAreaUF2)
RestArea(aArea)

Return()

/*/{Protheus.doc} ValidParam
//TODO Função que valida os parâmetros informados
@author g.sampaio
@since 02/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function ValidParam(cContratoDe, cContratoAte, cPlano, nTipo, cDiretorio, dDtAtivDe, dDtAtivAte) 

Local lRet := .T.

Default cContratoDe     := ""
Default cContratoAte    := ""
Default cPlano          := ""
Default nTipo           := 0
Default cDiretorio      := ""
Default dDtAtivDe       := stod("")
Default dDtAtivAte      := stod("")

// verifico se foram preenchidos todos os parâmetros
if empty(cContratoDe) .AND. empty(cContratoAte) 
	Alert("Informe o intervalo dos contratos!")
    lRet := .F. // retorno falso para o preenchimento correto

elseif empty(cPlano) // verifico se o plano foi preenchido
	Alert("Informe o plano!")
    lRet := .F. // retorno falso para o preenchimento correto

elseif nTipo == 0 // verifico se o tipo foi preenchido
	Alert("Informe o tipo!")
    lRet := .F. // retorno falso para o preenchimento correto

elseif empty(cDiretorio)// verifico se o diretorio foi preenchido
	Alert("Informe o diretorio!")
    lRet := .F. // retorno falso para o preenchimento correto

elseif !ExistDir(cDiretorio )// verifico se o diretorio existe
    Alert("Informe um diretorio que exista no computador!")
    lRet := .F. // retorno falso para o preenchimento correto

elseIf empty(dDtAtivDe)// verifico se a data de inicio do range esta preenchido
    Alert("Informe o parametro <Data de Ativacao de ?>")
    lRet := .F.

elseIf empty(dDtAtivAte)// verifico se a data do fim do range esta preenchido
    Alert("Informe o parametro <Data de Ativacao ate ?>")
    lRet := .F.

endif

Return(lRet) 

/*/{Protheus.doc} ConsultaCTR
//TODO Função que consulta os contratos que irão gerar o arquivo da seguradora
@author g.sampaio
@since 02/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function ConsultaCTR(oSay,cContratoDe,cContratoAte,cPlano,nTipo,cDiretorio,dDtAtivDe,dDtAtivAte)

Local oPn1			:= NIL
Local oPn2			:= NIL
Local oPn3			:= NIL
Local oTotal		:= NIL
Local oQtdMark		:= NIL
Local oGetTotal		:= NIL
Local oQtTotal		:= NIL
Local oGrid			:= NIL
Local aButtons		:= {}
Local aObjects 		:= {}
Local aSizeAut		:= MsAdvSize()
Local aInfo			:= {}
Local aPosObj		:= {}
Local nGetTotal		:= 0
Local nQtTotal		:= 0
Local lRet          := .T.

Static oDlg

Default cContratoDe     := ""
Default cContratoAte    := ""
Default cPlano          := ""
Default cDiretorio      := ""
Default dDtAtivDe       := stod("")
Default dDtAtivAte      := stod("")
Default nTipo           := 0

Private cCadastro := "Geração do Arquivo da Seguradora"

//Largura, Altura, Modifica largura, Modifica altura
aAdd( aObjects, { 100,	100, .T., .T. } ) //Browse

aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE "Contratos para geração do Arquivo da Seguradora" From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] COLORS 0, 16777215 PIXEL

//defino os panels da tela
@ 001,000 MSPANEL oPn1 SIZE 150, 050 OF oDlg
@ 001,000 MSPANEL oPn2 SIZE 150, 050 OF oPn1
@ 001,000 MSPANEL oPn3 SIZE 150, 050 OF oPn1

oPn1:Align  := CONTROL_ALIGN_ALLCLIENT
oPn2:Align  := CONTROL_ALIGN_TOP
oPn3:Align  := CONTROL_ALIGN_BOTTOM

oPn2:nHeight := (oMainWnd:nClientHeight / 2) + 150
oPn3:nHeight := (oMainWnd:nClientHeight - oPn2:nHeight ) - 100

EnchoiceBar(oDlg, {|| FWMsgRun(,{|oSay| GeraArq(oSay,oGrid) },'Aguarde...','Confirmando contratos selecionados...')},{|| oDlg:End()},,aButtons)

//objetos totalizadores
@ 00, 05 SAY oTotal PROMPT "R$ Total Selecionado:" SIZE 100, 007 OF oPn3 Font oFont COLOR CLR_RED PIXEL
@ 00, 090 MSGET oGetTotal VAR nGetTotal SIZE 100, 007 When .F. OF oPn3 HASBUTTON PIXEL COLOR CLR_BLACK Picture "@E 999,999,999.99"

@ 00, 210 SAY oTotal PROMPT "Quantidade Selecionada:" SIZE 100, 007 OF oPn3 COLORS CLR_RED Font oFont COLOR CLR_BLACK PIXEL
@ 00, 300 MSGET oQtTotal VAR nQtTotal SIZE 100, 007 When .F. OF oPn3 HASBUTTON PIXEL COLOR CLR_BLACK Picture "@E 999999999"	

// crio o grid de contratos
oGrid := MsGridCTR(oPn2)

// duplo clique no grid
oGrid:oBrowse:bLDblClick := {|| DuoClique(oGrid,oGetTotal,@nGetTotal,oQtTotal,@nQtTotal)}

// clique no cabecalho da grid
oGrid:oBrowse:bHeaderClick := {|oBrw1,nCol| if(oGrid:oBrowse:nColPos <> 111 .And. nCol == 1,(MarcaTodos(oGrid,oGetTotal,@nGetTotal,oQtTotal,@nQtTotal),;
							  oBrw1:SetFocus()),(U_OrdGrid(oGrid,nCol) , nColOrder := nCol ))}


// objeto ocupa todo panel
oGrid:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

// atualizo o objeto
oGrid:oBrowse:Refresh()

FWMsgRun(,{|oSay| lRet := RefreshGrid(oSay,oGrid,cContratoDe,cContratoAte,cPlano,nTipo,oGetTotal,@nGetTotal,oQtTotal,@nQtTotal,dDtAtivDe,dDtAtivAte) },'Aguarde...','Consultando Contratos para Geração do Arquivo da Seguradora ...')

// caso não tenha encontrato títulos
if !lRet
	
	Alert("Não foram encontrados contratos para geração dos arquivos para a seguradora!")
	oDlg:End()
	
endif

ACTIVATE MSDIALOG oDlg CENTERED

Return() 

/*/{Protheus.doc} MsGridCTR
//TODO Função que cria o grid de contratos
@author g.sampaio
@since 02/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function MsGridCTR(oPainel)

Local oGrid			:= NIL
Local nX			:= 1
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {"MARK","CONTRATO","TIPO","NOME","DATANASC","DATAATIV","CGC","CAPITAL","NUMSORTE","SORTEIO","PLANO","PREMIO"}
Local aAlterFields 	:= {}

For nX := 1 To Len(aFields)
	
	if aFields[nX] == "MARK" 
		Aadd(aHeaderEx, {"","MARK","@BMP",2,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "CONTRATO"
		Aadd(aHeaderEx, {"Contrato","CONTRATO","@!",6,0,"","€€€€€€€€€€€€€€","C","","","",""})
    elseif aFields[nX] == "TIPO"
		Aadd(aHeaderEx, {"Tipo","TIPO","@!",10,0,"","€€€€€€€€€€€€€€","C","","","",""})
    elseif aFields[nX] == "NOME"
        Aadd(aHeaderEx, {"Nome","NOME","@!",80,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "DATANASC"
		Aadd(aHeaderEx, {"Data de Nasc.","DATANASC","@D",8,0,"","€€€€€€€€€€€€€€","D","","","",""})
	elseif aFields[nX] == "DATAATIV"
		Aadd(aHeaderEx, {"Data de Ativ.","DATAATIV","@D",8,0,"","€€€€€€€€€€€€€€","D","","","",""})
	elseif aFields[nX] == "CGC"
		Aadd(aHeaderEx, {"CPF","CGC","@R 999.999.999-99",11,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "CAPITAL"
		Aadd(aHeaderEx, {"Capital","CAPITAL",PesqPict("UI2","UI2_MORTE"),TamSX3("UI2_MORTE")[1],TamSX3("UI2_MORTE")[2],"","€€€€€€€€€€€€€€","N","","","",""})
	elseif aFields[nX] == "NUMSORTE" // .and. MV_PAR04 <> 3 // exibe o tipo quando for diferente de remissivo
		Aadd(aHeaderEx, {"Num.Sorte","NUMSORTE","@!",5,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "SORTEIO" //.and. MV_PAR04 <> 3 // exibe o tipo quando for diferente de remissivo
		Aadd(aHeaderEx, {"Sorteio","SORTEIO",PesqPict("UI2","UI2_SORTE"),TamSX3("UI2_SORTE")[1],TamSX3("UI2_SORTE")[2],"","€€€€€€€€€€€€€€","N","","","",""})
	elseif aFields[nX] == "PLANO" //.and. MV_PAR04 <> 3 // exibe o tipo quando for diferente de remissivo
		Aadd(aHeaderEx, {"Plano","PLANO","@!",6,0,"","€€€€€€€€€€€€€€","N","","","",""})
	elseif aFields[nX] == "PREMIO"
		Aadd(aHeaderEx, {"Premio","PREMIO",PesqPict("UI3","UI3_VALOR"),TamSX3("UI3_VALOR")[1],0,"","€€€€€€€€€€€€€€","N","","","",""})		
	endif
	
Next nX

// Define field values
For nX := 1 To Len(aHeaderEx)
	
	if aHeaderEx[nX,2] == "MARK"
		Aadd(aFieldFill, "UNCHECKED")
	elseif aHeaderEx[nX,8] == "C"
		Aadd(aFieldFill, "")
	elseif aHeaderEx[nX,8] == "N"
		Aadd(aFieldFill, 0)
	elseif aHeaderEx[nX,8] == "D"
		Aadd(aFieldFill, CTOD("  /  /    "))
	elseif aHeaderEx[nX,8] == "L"
		Aadd(aFieldFill, .F.)
	endif
	
Next nX

Aadd(aFieldFill, .F.)
Aadd(aColsEx, aFieldFill)

oGrid := MsNewGetDados():New( 05,05,000, 000, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,;
		 , 999, "AllwaysTrue", "", "AllwaysTrue",oPainel, aHeaderEx, aColsEx)                          


Return(oGrid)

/*/{Protheus.doc} RefreshGrid
//TODO Função atualiza o grid de contratos
@author g.sampaio
@since 02/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function RefreshGrid(oSay,oGrid,cContratoDe,cContratoAte,cPlano,nTipo,oGetTotal,nGetTotal,oQtTotal,nQtTotal,dDtAtivDe,dDtAtivAte)

Local aArea			    := GetArea()
Local aTaxas            := {}
Local aFieldFill	    := {}

Local cTipPln                                                                                                  := ""
Local cPlnSeg           := ""
Local cQry 			    := ""
Local cTipoRem          := ""

Local dDataToleravel    := CTOD("")

Local lRet			    := .F.
Local lRemiss           := .F.
Local lCredito          := .F.


Local nCapital          := 0
Local nSorte            := 0
Local nTxRem            := 0
Local nIdade            := 0
Local nPremio           := 0
Local nPos              := 0
Local nDiasTolerancia   := SuperGetMv("MV_XDIATLM",.F.,0)


Default cContratoDe     := ""
Default cContratoAte    := ""
Default cPlano          := ""
Default nTipo           := 0
Default nGetTotal       := 0
Default nQtTotal        := 0
Default dDtAtivDe       := stod("")
Default dDtAtivAte      := stod("")

//////////////////////////////////////////////////////////////////////////
//// CALCULO A TOLERANCIA PARA CONSIDERAR INADIMPLENCIA     /////////////
////////////////////////////////////////////////////////////////////////
if nDiasToleravel > 0 
    dDataToleravel      := RetDataToleravel(nDiasTolerancia)
else
    dDataToleravel := LastDate( MonthSub( dDataBase, 1 ) )
endif

// verifico se não existe este alias criado
If Select("TRBCTR") > 0
	TRBCTR->(DbCloseArea())
EndIf     

cQry := " SELECT " 																												+ CRLF
cQry += " UF2.UF2_CODIGO AS CONTRATO, "																							+ CRLF
cQry += " UF2.UF2_CLIENT AS CLIENTE, "																							+ CRLF
cQry += " UF2.UF2_LOJA AS LOJA, "																								+ CRLF

// pego a data de nascimento do beneficiario titular do contrato
cQry += " SA1.A1_XDTNASC DATANASC, "                                                                                            + CRLF                                                                                                   
cQry += " SA1.A1_NOME NOME, "                                                                                                   + CRLF                                                                                                   
cQry += " SA1.A1_CGC CGC, "                                                                                                     + CRLF                                                                                                   
cQry += " UF2.UF2_NUMSOR NUMSOR, "                         																	    + CRLF
cQry += " UF2.UF2_PLNSEG PLNSEG,    " + CRLF
cQry += " UF2.UF2_DTATIV DTATIV,    " + CRLF    // taxa paga pela funeraria   
cQry += " UI2.UI2_MORTE,            " + CRLF    // valor do seguro por morte
cQry += " UI2.UI2_SORTE,            " + CRLF    // valor do seguro por sorteio
cQry += " UI2.UI2_NOMSEG,           " + CRLF    // descricao do plano de seguro
cQry += " UI2.UI2_TIPO,             " + CRLF    // tipo do plnao de seguro
cQry += " UI2.UI2_QTDREM,           " + CRLF    // quantidade de remissivo
cQry += " UI2.UI2_REMISS,           " + CRLF    // taxa do remissivo
cQry += " UI2.UI2_VLREMI,           " + CRLF    // Valor do remissivo
cQry += " UI2.UI2_TAXA,             " + CRLF    // taxa paga pela funeraria   
cQry += " UF2.UF2_PLANO PLANO,      " + CRLF
cQry += " UF2.UF2_VALOR VLRPARC     " + CRLF
cQry += " FROM " 																												+ CRLF
cQry += RetSqlName("UF2") + " UF2 " 																							+ CRLF
cQry += " INNER JOIN "

// tabela de plano de seguro
cQry += RetSqlName("UI2") + " UI2 " 																							+ CRLF
cQry += " ON UI2.UI2_CODIGO = UF2.UF2_PLNSEG "                                                                                  + CRLF

// tabela de cadastro de clientes
cQry += " INNER JOIN "
cQry += RetSqlName("SA1") + " SA1 " 																							+ CRLF
cQry += " ON SA1.A1_COD     = UF2.UF2_CLIENT "                                                                                  + CRLF
cQry += " AND SA1.A1_LOJA   = UF2_LOJA "                                                                                        + CRLF
cQry += " AND SA1.D_E_L_E_T_ = ' ' "
cQry += " WHERE " 																												+ CRLF
cQry += " UF2.D_E_L_E_T_ <> '*' " 																								+ CRLF
cQry += " AND UF2.UF2_FILIAL = '" + xFilial("UF2") + "' " 																		+ CRLF
cQry += " AND UF2.UF2_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' " 										+ CRLF

// verifico se o plano esta preenchido
if !Empty( Alltrim(cPlano) )
	cQry += " AND UF2.UF2_PLANO IN " + FormatIn( AllTrim(cPlano),";") 		 													+ CRLF		
endif

cQry += " AND UI2.D_E_L_E_T_ = ' ' " + CRLF		
cQry += " AND UI2.UI2_FILIAL = '" + xFilial("UI2") + "'     " + CRLF		
cQry += " AND UF2.UF2_PLNSEG <> ' '" + CRLF		
cQry += " AND UF2.UF2_STATUS = 'A' " + CRLF

if nTipo == 1
    cQry += " AND UI2.UI2_TIPO = '1' " + CRLF
elseIf nTipo == 2
    cQry += " AND UI2.UI2_TIPO = '2' " + CRLF
endIf

cQry += " AND UF2.UF2_DTATIV BETWEEN '" + dtos(dDtAtivDe) + "' AND '" + dtos(dDtAtivAte) + "'" + CRLF

///////////////////////////////////////////////////////////////////////////////////
//////// NAO CONSULTA CONTRATOS COM TITULOS VENCIDOS OU                 //////////
//////// QUE O ULTIMO TITULO TENHA SIDO PAGO FORA DO MES DE VENCIMENTO  /////////
////////////////////////////////////////////////////////////////////////////////
cQry += " AND NOT EXISTS (
cQry += " 				SELECT "         
cQry += " 				SE1.E1_XCTRFUN "    
cQry += " 				FROM  " + RetSQLName("SE1") + " SE1 (NOLOCK)    
cQry += " 				WHERE "         
cQry += " 				SE1.D_E_L_E_T_	<> '*' "         
cQry += " 				AND SE1.E1_FILIAL 	= '" + xFilial("UF2") + "' "         
cQry += " 				AND SE1.E1_FILIAL = UF2.UF2_MSFIL " 
cQry += " 				AND SE1.E1_XCTRFUN = UF2.UF2_CODIGO " 
cQry += " 				AND ( SE1.E1_SALDO	> 0 OR E1_BAIXA > '" + Dtos( dDataToleravel ) + "' )        
cQry += " 				AND SE1.E1_VENCTO	<= '" + Dtos( LastDate( MonthSub( dDataBase, 1 ) ) ) + "'        
cQry += " 				AND SE1.E1_TIPO NOT IN ('AB-','FB-','FC-','FU-',
cQry += " 									'PR','IR-','IN-','IS-','PI-',
cQry += " 									'CF-','CS-','FE-','IV-','RA','NCC','NDC')
cQry += "             )

cQry += " GROUP BY UF2.UF2_CODIGO,UF2.UF2_CLIENT ,UF2.UF2_LOJA,SA1.A1_XDTNASC,A1_NOME,A1_CGC,UF2.UF2_NUMSOR,UF2.UF2_PLNSEG,"+ CRLF
cQry += "       UF2.UF2_DTATIV,UI2.UI2_MORTE,UI2.UI2_SORTE,UI2.UI2_NOMSEG,UI2.UI2_TIPO,UI2.UI2_QTDREM,"+ CRLF
cQry += "       UI2.UI2_REMISS,UI2.UI2_VLREMI,UI2.UI2_TAXA,UF2.UF2_PLANO,UF2.UF2_VALOR"+ CRLF
cQry += " ORDER BY UF2.UF2_CODIGO "+ CRLF

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "TRBCTR" // Cria uma nova area com o resultado do query   

// se existir contratos a serem reajustados
if TRBCTR->(!Eof())

	oGrid:Acols := {}
	lRet 		:= .T. 

	While TRBCTR->(!Eof()) 
	
        oSay:cCaption := ("Processando consulta contrato " + Alltrim(TRBCTR->CONTRATO) + " ...") 
		ProcessMessages()

		aFieldFill  := {}
        lRemiss     := .F.
        nTxRem      := 0
        nPremio     := 0
        aTaxas      := {}
        lCredito    := .F.

        // verifico o campo data de nascimento
        if !empty(TRBCTR->DATANASC) //.and. lCredito 
                
            nCapital    := TRBCTR->UI2_MORTE   // valor remissivo
            nSorte      := TRBCTR->UI2_SORTE   // valor do seguro por sorteio
            cPlnSeg     := TRBCTR->UI2_NOMSEG  // descricao do plano de seguro
            cTipPln     := TRBCTR->UI2_TIPO    // tipo do plnao de seguro
            nQtdRem     := TRBCTR->UI2_QTDREM  // quantidade de remissivo
            nTxRem      := TRBCTR->UI2_REMISS  // taxa do remissivo
            nPremio     := TRBCTR->UI2_TAXA    // taxa do plano de seguro 

            // vejo se o plano de seguro e remissivo
            if cTipPln == "1" .and. nTxRem > 0
                lRemiss := .T.
            elseIf cTipPln == "1" .and. nTxRem > 0 .and. ( nTipo == 3 .Or. nTipo == 4 )
                lRemiss := .T.            
            endIf

            // vou posicionar na tabela de taxas se houver
            UI3->( DbSetOrder(1) )
            if UI3->( dbSeek( xFilial("UI3")+TRBCTR->PLNSEG ) )
                while UI3->(!eof()) .and. UI3->UI3_FILIAL == xFilial("UI3") .and. UI3->UI3_CODIGO == TRBCTR->PLNSEG                      

                   // preencho o array de taxas
                    aAdd( aTaxas, {UI3->UI3_IDAINI, UI3->UI3_IDAFIM, UI3->UI3_VALOR, UI3->UI3_TXREMI,UI3->UI3_TIPO} )

                    UI3->( dbSkip() )
                endDo                    
            endIf

            // verifico se o array esta preenchido
            if cTipPln == "2" .and. len(aTaxas) > 0
                    
                // quando for plano de faixa etaria zero o Premio por seguranca
                nPremio := 0

                // vou calcular a idade de acordo com a data de nascimento e data atual
                // utilizando a funcao DateDiffYear()
                nIdade  := DateDiffYear( stod(TRBCTR->DATANASC), dDataBase )

                // vou buscar a posicao no array da faixa etaria
                nPos    := aScan( aTaxas, {|x| x[2] >= nIdade .and. x[1] <= nIdade  } ) 

                // caso tenha encontrado uma posicao eu preencho o premio
                if nPos > 0
                    nPremio := aTaxas[nPos][3]
                    lRemiss := aTaxas[nPos][4] > 0
                    nTxRem  := aTaxas[nPos][4]
                    cTipoRem:= aTaxas[nPos][5]
                endIf

            endIf   
                    
            // verifico se tem remissivo para o contrato
            if lRemiss
                        
                // tipo quando for diferente do tipo remissivo
                if nTipo <> 3

                    // fixo ou faixa etaria - monto o array de dados para montar a Grid
                    aadd(aFieldFill, "CHECKED")	
                    aadd(aFieldFill, TRBCTR->CONTRATO)

                    // vou preencher o tipo de contrato
                    if cTipPln == "1"
                        aadd(aFieldFill, "FIXO")
                    elseIf cTipPln == "2"
                        aadd(aFieldFill, "FAIXA ETARIA")
                    endIf

                        aadd(aFieldFill, TRBCTR->NOME   )
                        aadd(aFieldFill, stod(TRBCTR->DATANASC))
                        aadd(aFieldFill, stod(TRBCTR->DTATIV))
                        aadd(aFieldFill, TRBCTR->CGC )
                        aadd(aFieldFill, nCapital)            
                        aadd(aFieldFill, TRBCTR->NUMSOR)
                        aadd(aFieldFill, nSorte)            
                        aadd(aFieldFill, cPlnSeg)                           
                        aadd(aFieldFill, nPremio)            
                        aadd(aFieldFill, .F.)
                        aadd(oGrid:Acols,aFieldFill)
                        nQtTotal++
                        nGetTotal+=nPremio
                endIf

                // zero as variaveis
                nPremio     := 0
                aFieldFill  := {}
                    
                // vou pegar o valor do premio para o remissivo
                /*
                +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                NO REMISSIVO A TAXA É A MESMA PARA TODOS 1,44
                PORÉM, O QUE MUDA É  O VALOR DO PLANO
                CÁLCULO É O VALOR TOTAL DO PLANO NO ANO X A TAXA / 1000
                No caso do Protheus vamos utilizar o calculo da seguinte maneira
                nPremio := (([Valor da Parcela do contrato -> UF2_VALOR]*[Quantidade de meses de Remissivo do Plano de seguro ->UI2_QTDREM])*[Taxa do remissivo ->UI2_REMISS ou UI3_TXREMI])/1000
                +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                */
                // para os tipos ambos e remissivo
                if nTipo == 4 .or. nTipo == 3

                    // fixo ou faixa etaria - monto o array de dados para montar a Grid
                    aadd(aFieldFill, "CHECKED")	
                    aadd(aFieldFill, TRBCTR->CONTRATO)
                    
                    // vou preencher o tipo de contrato
                    If cTipPln == "1"
                        aadd(aFieldFill, "REMISSIVO/FIXO")

                        nPremio := TRBCTR->UI2_REMISS
                       

                    ElseIf cTipPln == "2"

                        aadd(aFieldFill, "REMISSIVO/FAIXA ETARIA")
                        
                        //Valido valor é fixo ou deverá ser calculado
                        If cTipoRem == "1" //Valor Fixo
                            
                            nPremio     := nTxRem
                        Else

                            // taxa de remissivo faixa etaria
                            if nQtdRem > 0 .and. nTxRem > 0
                                
                                nPremio     := (TRBCTR->VLRPARC * nQtdRem) * nTxRem
                            EndIf

                        Endif
                    EndIf

                    aadd(aFieldFill, TRBCTR->NOME)
                    aadd(aFieldFill, stod(TRBCTR->DATANASC))
                    aadd(aFieldFill, stod(TRBCTR->DTATIV))
                    aadd(aFieldFill, TRBCTR->CGC)
                    aadd(aFieldFill, TRBCTR->UI2_VLREMI )                            
                    aadd(aFieldFill, "")
                    aadd(aFieldFill, 0)            
                    aadd(aFieldFill, "")                            
                    aadd(aFieldFill, nPremio)            
                    aadd(aFieldFill, .F.)
                    aadd(oGrid:Acols,aFieldFill)
                    nQtTotal++
                    nGetTotal+=nPremio
                endIf
            elseif nTipo <> 3 // verifico se vou exportar os contratos e parametro nao for de apenas remissivo
                
                // fixo ou faixa etaria - monto o array de dados para montar a Grid
                aadd(aFieldFill, "CHECKED")	
                aadd(aFieldFill, TRBCTR->CONTRATO)

                // vou preencher o tipo de contrato
                If cTipPln == "1"
                    aadd(aFieldFill, "FIXO")
                ElseIf cTipPln == "2"
                    aadd(aFieldFill, "FAIXA ETARIA")
                EndIf

                aadd(aFieldFill, TRBCTR->NOME)
                aadd(aFieldFill, stod(TRBCTR->DATANASC))
                aadd(aFieldFill, stod(TRBCTR->DTATIV))
                aadd(aFieldFill, TRBCTR->CGC)
                aadd(aFieldFill, nCapital)            
                aadd(aFieldFill, TRBCTR->NUMSOR)
                aadd(aFieldFill, nSorte)            
                aadd(aFieldFill, cPlnSeg)                           
                aadd(aFieldFill, nPremio)            
                aadd(aFieldFill, .F.)
                aadd(oGrid:Acols,aFieldFill)
                nQtTotal++
                nGetTotal+=nPremio

            endIf

        endIf

		TRBCTR->(DbSkip()) 
		
	EndDo
	
	oGrid:oBrowse:Refresh() 
		
endif

// fecho o alias temporario criado
If Select("TRBCTR") > 0
	TRBCTR->(DbCloseArea())
EndIf 

RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} DuoClique
//TODO Função chamada no duplo clique no grid
@author g.sampaio
@since 02/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function DuoClique(oObj,oGetTotal,nGetTotal,oQtTotal,nQtTotal)

Local nPosMark	    := aScan(oObj:aHeader,{|x| AllTrim(x[2])== "MARK"})       
Local nPosPremio    := aScan(oObj:aHeader,{|x| AllTrim(x[2])== "PREMIO"})  

// verifico se o registro esta selecionado
if oObj:aCols[oObj:nAt][nPosMark] == "CHECKED"
    
    // se nao estiver selecionado diminuo dos contadores
	oObj:aCols[oObj:nAt][nPosMark] 	:= "UNCHECKED" 
	nGetTotal -= oObj:aCols[oObj:nAt][nPosPremio] 
	nQtTotal--

else

    // se nao estiver selecionado aumento os contatadores
	oObj:aCols[oObj:nAt][nPosMark] 	:= "CHECKED" 
	nGetTotal += oObj:aCols[oObj:nAt][nPosPremio]
	nQtTotal++

endif

oGetTotal:Refresh()
oQtTotal:Refresh()

oObj:oBrowse:Refresh()

Return()

/*/{Protheus.doc} MarcaTodos
//TODO Função chamada pela ação de clicar no cabeçalho dos grids
para selecionar todos os checkbox
@author g.sampaio
@since 02/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function MarcaTodos(_obj,oGetTotal,nGetTotal,oQtTotal,nQtTotal)

Local nX		    := 1
Local nPosPremio    := aScan(_obj:aHeader,{|x| AllTrim(x[2])== "PREMIO"})  

if __XVEZ == "0"
	__XVEZ := "1"
else
	if __XVEZ == "1"
		__XVEZ := "2"
	endif
endif

If __XVEZ == "2"
	
	nGetTotal := 0 
	nQtTotal  := 0 

	If _nMarca == 0
		
		For nX := 1 TO Len(_obj:aCols)
			_obj:aCols[nX][1] := "CHECKED"
			nGetTotal += _obj:aCols[nX][nPosPremio]
			nQtTotal++
		Next
		
		_nMarca := 1
		
	Else
		
		For nX := 1 To Len(_obj:aCols)
			_obj:aCols[nX][1] := "UNCHECKED"
		Next
		
		_nMarca := 0
		
	Endif
	
	__XVEZ:="0"
	
	// atualizo objetos
	_obj:oBrowse:Refresh()
	oGetTotal:Refresh()
	oQtTotal:Refresh()
	
	
Endif

Return()

/*/{Protheus.doc} GeraArq
//TODO Função chamada na confirmação da tela
@author g.sampaio
@since 02/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function GeraArq(oSay,oGrid)

Local aDados        := {}
Local aLinRemFix    := {}
Local aLinRemFax    := {}
Local aLinFixo      := {}
Local aLinFaixa     := {}
Local cArqFixo      := "mongeral_fixo" + dtos(date())+strTran(time(),":","")
Local cArqFaixa     := "mongeral_faixaetaria" + dtos(date())+strTran(time(),":","")
Local cArqRemFix    := "mongeral_remissivo_fixo" + dtos(date())+strTran(time(),":","")
Local cArqRemFax    := "mongeral_remissivo_faixa" + dtos(date())+strTran(time(),":","")
Local cLinha        := ""
Local cAviso        := ""
Local lContinua	    := .T.
Local nX		    := 0
Local nY            := 0 
Local nPosTipo	    := aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "TIPO"})   
Local nPosNome	    := aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "NOME"})
Local nPosDtNasc    := aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "DATANASC"})
Local nPosDtAtiv    := aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "DATAATIV"})
Local nPosCGC	    := aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CGC"})
Local nPosCapita    := aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CAPITAL"})
Local nPosNumSor    := aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "NUMSORTE"})
Local nPosSorte     := aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "SORTEIO"})
Local nPosPlano	    := aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "PLANO"})
Local nPosPremio    := aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "PREMIO"})
Local nHandle       := 0
local nPos          := 0

// vou verificar se existem registros marcados
nPos := aScan( oGrid:aCols, { |x| x[1] == "CHECKED" } )

// caso conter pelo menos um registro marcado
if nPos > 0

    // monto a descricao do caminho arquivo a ser gerado
    if !empty(alltrim(MV_PAR05)) // vejo se o parametro de diretorio do cliente esta preenchido        
        cArqFixo        := alltrim(MV_PAR05) + If(Right(alltrim(MV_PAR05), 1) <> "\", "\", "") + cArqFixo       + ".csv"   // diretorio + barra invertida + descricao do arquivo csv
        cArqRemFix      := alltrim(MV_PAR05) + If(Right(alltrim(MV_PAR05), 1) <> "\", "\", "") + cArqRemFix     + ".csv"   // diretorio + barra invertida + descricao do arquivo csv    
        cArqFaixa       := alltrim(MV_PAR05) + If(Right(alltrim(MV_PAR05), 1) <> "\", "\", "") + cArqFaixa      + ".csv"   // diretorio + barra invertida + descricao do arquivo csv
        cArqRemFax      := alltrim(MV_PAR05) + If(Right(alltrim(MV_PAR05), 1) <> "\", "\", "") + cArqRemFax     + ".csv"   // diretorio + barra invertida + descricao do arquivo csv
    endIf

    // percuro ao usuario se gero o arquivo
    if MsgYesNo("Deseja gerar o arquivo de envio de contratos para a Seguradora ?")
                
        // percorro todo o grid
        For nX := 1 To Len(oGrid:aCols)

            // alimenta a caption			
            oSay:cCaption := (" Gerando os dados do arquivo da Seguradora ")

            // se a linha estiver marcada
            if oGrid:aCols[nX][1] == "CHECKED"
                    
                aDados  := {}
                if "REMISSIVO/FAIXA" $ alltrim(oGrid:aCols[nX][nPosTipo])                  

                    aadd(aDados,oGrid:aCols[nX][nPosNome])
                    aadd(aDados,oGrid:aCols[nX][nPosDtNasc])
                    aadd(aDados,oGrid:aCols[nX][nPosDtAtiv])
                    aadd(aDados,oGrid:aCols[nX][nPosCGC])
                    aadd(aDados,oGrid:aCols[nX][nPosCapita])                    
                    aadd(aDados,oGrid:aCols[nX][nPosPremio])
                    
                    // alimento o array de linhas
                    aadd(aLinRemFax,aDados)
                
                elseIf "REMISSIVO/FIXO" $ alltrim(oGrid:aCols[nX][nPosTipo])                  

                    aadd(aDados,oGrid:aCols[nX][nPosNome])
                    aadd(aDados,oGrid:aCols[nX][nPosDtNasc])
                    aadd(aDados,oGrid:aCols[nX][nPosCGC])
                    aadd(aDados,oGrid:aCols[nX][nPosCapita])                    
                    aadd(aDados,oGrid:aCols[nX][nPosPremio])
                    
                    // alimento o array de linhas
                    aadd(aLinRemFix,aDados)

                elseif "FIXO" $ alltrim(oGrid:aCols[nX][nPosTipo])
                    
                    aadd(aDados,oGrid:aCols[nX][nPosNome])
                    aadd(aDados,oGrid:aCols[nX][nPosDtNasc])
                    aadd(aDados,oGrid:aCols[nX][nPosCGC])
                    aadd(aDados,oGrid:aCols[nX][nPosCapita])           
                    aadd(aDados,oGrid:aCols[nX][nPosNumSor])
                    aadd(aDados,oGrid:aCols[nX][nPosSorte])
                    aadd(aDados,oGrid:aCols[nX][nPosPlano])                                    
                    aadd(aDados,oGrid:aCols[nX][nPosPremio])
                
                    // alimento o array de linhas
                    aadd(aLinFixo,aDados)

                elseif "FAIXA" $ alltrim(oGrid:aCols[nX][nPosTipo])

                    aadd(aDados,oGrid:aCols[nX][nPosNome])
                    aadd(aDados,oGrid:aCols[nX][nPosDtNasc])
                    aadd(aDados,oGrid:aCols[nX][nPosDtAtiv])
                    aadd(aDados,oGrid:aCols[nX][nPosCGC])
                    aadd(aDados,oGrid:aCols[nX][nPosCapita])           
                    aadd(aDados,oGrid:aCols[nX][nPosNumSor])
                    aadd(aDados,oGrid:aCols[nX][nPosSorte])
                    aadd(aDados,oGrid:aCols[nX][nPosPlano])                                    
                    aadd(aDados,oGrid:aCols[nX][nPosPremio])
                
                    // alimento o array de linhas
                    aadd(aLinFaixa,aDados)

                endIf
                    
            endIf	
            
        Next nX

        // verifico se o array tem conteudo para geracao do arquivo de remissivo fixo
        if Len(aLinRemFix) > 0

            // alimenta a caption			
            oSay:cCaption := (" Gerando o arquivo de Plano Remissivo Fixo! ")

            nHandle := 0
            // vejo se a variavel do arquivo esta preenchida
            if !empty( alltrim(cArqRemFix) )
                nHandle := fCreate( cArqRemFix )
            endIf

            // verifico se conseguiu criar o arquivo
            if nHandle > 0

                // escrevo o cabecalho
                FWrite(nHandle, "Nome;Nascimento;CPF;Capital;Premio" + CRLF)
                
                // percorro a linha 
                for nX := 1 to Len(aLinRemFix)
                
                    cLinha := "" // zero a variavel de linha
                    
                    // percorro a linha
                    for nY := 1 to len(aLinRemFix[nX])
                        if ny==len(aLinRemFix[nX])
                            if valtype(aLinRemFix[nX,nY])=="N"// para o tipo numerico
                                cLinha += alltrim(strTran(strTran(cValToChar(aLinRemFix[nX,nY]),",",""),".",","))
                            elseif valtype(aLinRemFix[nX,nY])=="D"// para o tipo data
                                cLinha += alltrim(dtoc(aLinRemFix[nX,nY]))
                            else// demais tipos
                                cLinha += alltrim(aLinRemFix[nX,nY])
                            endIf
                        else
                            if valtype(aLinRemFix[nX,nY])=="N"// para o tipo numerico
                                cLinha += alltrim(strTran(strTran(cValToChar(aLinRemFix[nX,nY]),",",""),".",",")) + ";"
                            elseif valtype(aLinRemFix[nX,nY])=="D"// para o tipo data
                                cLinha += alltrim(dtoc(aLinRemFix[nX,nY])) + ";"
                            else// demais tipos
                                cLinha += alltrim(aLinRemFix[nX,nY]) + ";"
                            endIf
                        endIf
                    next nY 

                    // escrevo a linha no arquivo
                    FWrite(nHandle, cLinha + CRLF)

                next nX

                // encerro a criacao do arquivo 
                fClose(nHandle)
            else
                msgAlert("Não foi possível gerar o arquivo de plano remissivo fixo para a seguradora")
                lContinua := .F.
            endIf
        endIf

        // verifico se o array tem conteudo para geracao do arquivo de remissivo fixo
        if Len(aLinRemFax) > 0

            // alimenta a caption			
            oSay:cCaption := (" Gerando o arquivo de Plano Remissivo Faixa Etaria! ")

            nHandle := 0
            // vejo se a variavel do arquivo esta preenchida
            if !empty( alltrim(cArqRemFax) )
                nHandle := fCreate( cArqRemFax )
            endIf

            // verifico se conseguiu criar o arquivo
            if nHandle > 0

                // escrevo o cabecalho
                FWrite(nHandle, "Nome;Nascimento;Data de Início no Plano;CPF;Capital;Premio" + CRLF)
                
                // percorro a linha 
                for nX := 1 to Len(aLinRemFax)
                
                    cLinha := "" // zero a variavel de linha
                    
                    // percorro a linha
                    for nY := 1 to len(aLinRemFax[nX])
                        if ny==len(aLinRemFax[nX])
                            if valtype(aLinRemFax[nX,nY])=="N"// para o tipo numerico
                                cLinha += alltrim(strTran(strTran(cValToChar(aLinRemFax[nX,nY]),",",""),".",","))
                            elseif valtype(aLinRemFax[nX,nY])=="D"// para o tipo data
                                cLinha += alltrim(dtoc(aLinRemFax[nX,nY]))
                            else// demais tipos
                                cLinha += alltrim(aLinRemFax[nX,nY])
                            endIf
                        else
                            if valtype(aLinRemFax[nX,nY])=="N"// para o tipo numerico
                                cLinha += alltrim(strTran(strTran(cValToChar(aLinRemFax[nX,nY]),",",""),".",",")) + ";"
                            elseif valtype(aLinRemFax[nX,nY])=="D"// para o tipo data
                                cLinha += alltrim(dtoc(aLinRemFax[nX,nY])) + ";"
                            else// demais tipos
                                cLinha += alltrim(aLinRemFax[nX,nY]) + ";"
                            endIf
                        endIf
                    next nY 

                    // escrevo a linha no arquivo
                    FWrite(nHandle, cLinha + CRLF)

                next nX

                // encerro a criacao do arquivo 
                fClose(nHandle)
            else
                msgAlert("Não foi possível gerar o arquivo de planos remissivo de faixa etaria para a seguradora")
                lContinua := .F.
            endIf
        endIf

        // verifico se o array tem conteudo para geracao do arquivo de plano fixo
        If len(aLinFixo)

            // alimenta a caption			
            oSay:cCaption := (" Gerando o arquivo de Planos Fixos! ")

            nHandle := 0
            // vejo se a variavel do arquivo esta preenchida
            if !empty( alltrim(cArqFixo) )
                nHandle := fCreate( cArqFixo )
            endIf

            // verifico se conseguiu criar o arquivo
            if nHandle > 0

                // escrevo o cabecalho
                FWrite(nHandle, "Nome;Data de Nascimento;CPF;Capital Morte;Nº da Sorte;Sorteio;Plano;Premio" + CRLF)
                
                // percorro a linha 
                for nX := 1 to Len(aLinFixo)
                
                    cLinha := "" // zero a variavel de linha
                    
                    // percorro a linha
                    for nY := 1 to len(aLinFixo[nX])
                        if ny==len(aLinFixo[nX])
                            if valtype(aLinFixo[nX,nY])=="N"// para o tipo numerico
                                cLinha += alltrim(strTran(strTran(cValToChar(aLinFixo[nX,nY]),",",""),".",","))
                            elseif valtype(aLinFixo[nX,nY])=="D"// para o tipo data
                                cLinha += alltrim(dtoc(aLinFixo[nX,nY]))
                            else// demais tipos
                                cLinha += alltrim(aLinFixo[nX,nY])
                            endIf
                        else
                            if valtype(aLinFixo[nX,nY])=="N"// para o tipo numerico
                                cLinha += alltrim(strTran(strTran(cValToChar(aLinFixo[nX,nY]),",",""),".",",")) + ";"
                            elseif valtype(aLinFixo[nX,nY])=="D"// para o tipo data
                                cLinha += alltrim(dtoc(aLinFixo[nX,nY])) + ";"
                            else// demais tipos
                                cLinha += alltrim(aLinFixo[nX,nY]) + ";"
                            endIf
                        endIf
                    next nY

                    // escrevo a linha no arquivo
                    FWrite(nHandle, cLinha + CRLF)

                next nX

                // encerro a criacao do arquivo 
                fClose(nHandle)
            else
                msgAlert("Não foi possível gerar o arquivo de planos fixos para a seguradora")
                lContinua := .F.
            endIf
        endIf

        // verifico se o array tem conteudo para geracao do arquivo de plano de faixa etaria
        If len(aLinFaixa)

            // alimenta a caption			
            oSay:cCaption := (" Gerando o arquivo de Planos de Faixa Etária! ")    
            
            nHandle := 0
            // vejo se a variavel do arquivo esta preenchida
            if !empty( alltrim(cArqFaixa) )
                nHandle := fCreate( cArqFaixa )
            endIf

            // verifico se conseguiu criar o arquivo
            if nHandle > 0

                // escrevo o cabecalho
                FWrite(nHandle, "Nome;Data de Nascimento;Data de Início no Plano;CPF;Capital Morte;Nº da Sorte;Sorteio;Plano;Premio" + CRLF)
                
                // percorro a linha 
                for nX := 1 to Len(aLinFaixa)
                
                    cLinha := "" // zero a variavel de linha
                    
                    // percorro a linha
                    for nY := 1 to len(aLinFaixa[nX])
                        if ny==len(aLinFaixa[nX])
                            if valtype(aLinFaixa[nX,nY])=="N"// para o tipo numerico
                                cLinha += alltrim(strTran(strTran(cValToChar(aLinFaixa[nX,nY]),",",""),".",","))
                            elseif valtype(aLinFaixa[nX,nY])=="D"// para o tipo data
                                cLinha += alltrim(dtoc(aLinFaixa[nX,nY]))
                            else// demais tipos
                                cLinha += alltrim(aLinFaixa[nX,nY])
                            endIf
                        else
                            if valtype(aLinFaixa[nX,nY])=="N"// para o tipo numerico
                                cLinha += alltrim(strTran(strTran(cValToChar(aLinFaixa[nX,nY]),",",""),".",",")) + ";"
                            elseif valtype(aLinFaixa[nX,nY])=="D"// para o tipo data
                                cLinha += alltrim(dtoc(aLinFaixa[nX,nY])) + ";"
                            else// demais tipos
                                cLinha += alltrim(aLinFaixa[nX,nY]) + ";"
                            endIf
                        endIf
                    next nY

                    // escrevo a linha no arquivo
                    FWrite(nHandle, cLinha + CRLF)

                next nX

                // encerro a criacao do arquivo 
                fClose(nHandle)
            else
                msgAlert("Não foi possível gerar o arquivo de planos de faixa etaria para a seguradora")
                lContinua := .F.
            endIf

        endIf

        // verifico se deu tudo certo ate aqui
        if lContinua

            cAviso := "Arquivos da seguradora Mongeral gerados com sucesso!" + CRLF
            
            // para arquivo fixo
            if !empty(cArqFixo) .and. len(aLinFixo)
                cAviso += "Arquivo de Planos Fixos: " + cArqFixo + CRLF 
            endIf

            // para arquivo de faixa etaria
            if !empty(cArqFaixa) .and. len(aLinFaixa)
                cAviso += "Arquivo de Planos por Faixa Etaria: " + cArqFaixa + CRLF 
            endIf

            // para arquivo remissivo - faixa etaria
            if !empty(cArqRemFax) .and. len(aLinRemFax)
                cAviso += "Arquivo de Planos Remissivos: " + cArqRemFax + CRLF 
            endIf

            // para arquivo remissivo - fixo
            if !empty(cArqRemFix) .and. len(aLinRemFix)
                cAviso += "Arquivo de Planos Remissivos: " + cArqRemFix + CRLF 
            endIf

            // vou exibir o aviso mostrado
            Aviso("Sucesso!", cAviso, {"OK"}, 2)
        endif
            
        // fecho a janela
        oDlg:End() 
    endif
else
    // help para o usuario
    msgAlert("Não existem registros selecionados para a geração do arquivo!")
endIf

Return()

/*/{Protheus.doc} AjustaSX1
//TODO Função que cria as perguntas na SX1.	
@author g.sampaio
@since 02/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relatório

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

//////////// Contrato ///////////////

U_xPutSX1( cPerg, "01","Contrato De?","Contrato De?","Contrato De?","cContratoDe","C",6,0,0,"G","","UF2","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "02","Contrato Ate?","Contrato Ate?","Contrato Ate?","cContratoAte","C",6,0,0,"G","","UF2","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

///////////// Plano /////////////////

U_xPutSX1( cPerg, "03","Plano?","Plano?","Plano?","cPlano","C",99,0,0,"G","","UF0MRK","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// Tipo ///////////////

U_xPutSX1( cPerg, "04","Tipo?","Tipo?","Tipo?","nTipo","N",1,0,4,"C","","","","","MV_PAR04","Fixo","Fixo","Fixo","","Faixa Etaria","Faixa Etaria","Faixa Etaria","Remissivo","Remissivo","Remissivo","Ambos","Ambos","Ambos","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// Tipo ///////////////

U_xPutSX1( cPerg, "05","Diretorio?","Diretorio?","Diretorio?","cDiretorio","C",99,0,0,"G","","HSSDIR","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// Data de Ativacao ///////////////

U_xPutSX1( cPerg, "06","Data de Ativacao de ?"  ,"Data de Ativacao de ?"    ,"Data de Ativacao de ?"    ,"cDtAtivDe","D",6,0,0,"G","","","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "07","Data de Ativacao ate ?" ,"Data de Ativacao ate ?"   ,"Data de Ativacao ate ?"   ,"cDtAtivAte","D",6,0,0,"G","","","","","MV_PAR07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return()

/*/{Protheus.doc} RetDataToleravel
Funcao para retornar data valida de acordo 
com os dias de tolerancia
@author Raphael Martins
@since 02/12/2019
@param nDiasTolerancia
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function RetDataToleravel(nDiasTolerancia)

Local dDataToleraval    := FirstDate(dDatabase)  
Local nDias             := 1 
  
While nDiasTolerancia > 0  

    //caso o proximo dia seja util, somo o mesmo, caso contrato acrescento na variavel nDias ate que chegue no proximo
    //dia util
    if DataValida(DaySum(dDataToleraval,nDias))
        
        dDataToleraval := DataValida(DaySum(dDataToleraval,nDias))
        nDiasTolerancia--
        nDias   := 1 
            
    else
        
        nDias++

    endif
 
EndDo

Return(dDataToleraval)
