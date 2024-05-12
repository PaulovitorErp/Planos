#include 'totvs.ch'
#include 'topconn.ch'
#include 'tbiConn.ch'
#include 'fileio.ch'

#define CRLF chr(13)+chr(10)  

/*/{Protheus.doc} RFUNA052
Tela de multiselecao para impressao do cartao
@author g.sampaio
@since 12/09/2019
@version 1.0
@param Nil
@return Nil
@type function
/*/
User Function RFUNA052()

Local aArea			    := GetArea()
Local aAreaUF2		    := UF2->( GetArea() )
Local cPerg 		    := "RFUNA052"
Local cDeContrato       := ""
Local cAteContrato      := ""
Local cPlano		    := ""
Local cRota	            := ""
Local nTipo	            := 0
Local dDtDaAtivacao     := stod("")
Local dDtAteAtivacao    := stod("")
Local lContinua		    := .T.
Local nTipo 		    := 0

Private __XVEZ 		    := "0"
Private __ASC           := .T.
Private _nMarca		    := 0

// cria as perguntas na SX1
AjustaSx1(cPerg)

// enquanto o usuário não cancelar a tela de perguntas
While lContinua
	
	// chama a tela de perguntas
	lContinua := Pergunte(cPerg,.T.)
    
    // se estiver tudo certo
	if lContinua 
	
		dDtDaAtivacao 	:= MV_PAR01
		dDtAteAtivacao	:= MV_PAR02 
        cDeContrato     := MV_PAR03
        cAteContrato    := MV_PAR04
		cPlano			:= MV_PAR05
		cRota			:= MV_PAR06  
        nTipo           := MV_PAR07
		
        // vou fazer a validacao dos parametros preenchidos
		if ValidParam( dDtDaAtivacao, dDtAteAtivacao, cDeContrato, cAteContrato, cPlano, cRota, nTipo ) 
            
            // chamo a consulta de contratos para retornar a grid
			FWMsgRun(,{|oSay| ConsultaContratos( dDtDaAtivacao, dDtAteAtivacao, cDeContrato, cAteContrato, cPlano, cRota, nTipo ) },'Aguarde...','Consultando Dados para a impressão...')
			
		endif
		
	endif
	
EndDo

RestArea(aAreaUF2)
RestArea(aArea)

Return( Nil )

/*/{Protheus.doc} ValidParam
//TODO Função que valida os parâmetros informados
@author g.sampaio
@since 12/09/2019
@version 1.0
@param dDtDaAtivacao    , data      , da data de ativacao
@param dDtAteAtivacao   , data      , ate a data de ativacao
@param cPlano           , caractere , planos 
@param cRota            , caractere , rotas
@param nTipo        , caractere , situacao dos planos
@return Nil 
@type function
/*/

Static Function ValidParam( dDtDaAtivacao, dDtAteAtivacao, cPlano, cRota, nTipo ) 

Local lRetorno              := .T.

Default dDtDaAtivacao       := stod("")
Default dDtAteAtivacao      := stod("")
Default cPlano              := ""
Default cRota               := ""
Default nTipo           := 0

// verifico se foram preenchidos todos os parâmetros
If Empty(dDtDaAtivacao)// verifico se a data de inicio do range esta preenchido
    Alert("Informe o parametro <Da Ativacao ?>")
    lRetorno := .F.

ElseIf Empty(dDtAteAtivacao)// verifico se a data do fim do range esta preenchido
    Alert("Informe o parametro <Até a Ativacao ?>")
    lRetorno := .F.

endif

Return( lRetorno ) 

/*/{Protheus.doc} ConsultaContratos
Função que consulta os contratos que irão ser cancelados
@author g.sampaio
@since 12/09/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function ConsultaContratos( dDtDaAtivacao, dDtAteAtivacao, cDeContrato, cAteContrato, cPlano, cRota, nTipo )

Local aButtons		        := {}
Local aObjects 		        := {}
Local aSizeAut		        := MsAdvSize()
Local aInfo			        := {}
Local aPosObj		        := {}
Local lContinua             := .T.
Local nQtTotal		        := 0
Local oPn1			        := Nil
Local oPn2			        := Nil
Local oPn3			        := Nil
Local oTotal		        := Nil
Local oQtTotal		        := Nil
Local oGrid			        := Nil
Local oDlg                  := Nil
Local oBrw1					:= Nil

Private	nColOrder			:= 0

Default dDtDaAtivacao       := stod("")
Default dDtAteAtivacao      := stod("")
Default cDeContrato			:= ""
Default cAteContrato		:= ""
Default cPlano              := ""
Default cRota               := ""
Default nTipo           	:= 0

Private cCadastro           := "Impressão de Cartão"

//Largura, Altura, Modifica largura, Modifica altura
aAdd( aObjects, { 100,	100, .T., .T. } ) //Browse

aInfo 	:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] COLORS 0, 16777215 PIXEL

    //defino os panels da tela
    @ 001,000 MSPANEL oPn1 SIZE 150, 050 OF oDlg
    @ 001,000 MSPANEL oPn2 SIZE 150, 050 OF oPn1
    @ 001,000 MSPANEL oPn3 SIZE 150, 050 OF oPn1

    oPn1:Align  := CONTROL_ALIGN_ALLCLIENT
    oPn2:Align  := CONTROL_ALIGN_TOP
    oPn3:Align  := CONTROL_ALIGN_BOTTOM

    oPn2:nHeight := (oMainWnd:nClientHeight / 2) + 150
    oPn3:nHeight := (oMainWnd:nClientHeight - oPn2:nHeight ) - 100

    EnchoiceBar(oDlg, {|| FWMsgRun(,{|oSay| Confirmar(oSay,oGrid,oDlg) },'Aguarde...','Realizando a impressão dos cartões selecionados...')},{|| oDlg:End()},,aButtons)

    @ 000, 005 SAY oTotal PROMPT "Quantidade Selecionada:" SIZE 100, 007 OF oPn3 COLORS CLR_RED Font oFont COLOR CLR_BLACK PIXEL
    @ 000, 090 MSGET oQtTotal VAR nQtTotal SIZE 100, 007 When .F. OF oPn3 HASBUTTON PIXEL COLOR CLR_BLACK Picture "@E 999999999"	

    // crio o grid de contratos
    oGrid := MsGridCTR(oPn2)

    // duplo clique no grid
    oGrid:oBrowse:bLDblClick := {|| DuoClique(oGrid,oQtTotal,@nQtTotal)}

    // clique no cabecalho da grid
    oGrid:oBrowse:bHeaderClick := {|oBrw1,nCol| if(oGrid:oBrowse:nColPos <> 111 .And. nCol == 1,(MarcaTodos(oGrid,oQtTotal,@nQtTotal),;
                                oBrw1:SetFocus()),(U_OrdGrid(oGrid,nCol) , nColOrder := nCol ))}


    // objeto ocupa todo panel
    oGrid:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

    // atualizo o objeto
    oGrid:oBrowse:Refresh()

    // caso não tenha encontrato títulos
    lContinua := RefreshGrid( @oGrid, dDtDaAtivacao, dDtAteAtivacao, cDeContrato, cAteContrato, cPlano, cRota, nTipo, oQtTotal, @nQtTotal )

	// caso eu deva fechar a tela
	If !lContinua

		// mensagem para o usuario
		Alert("Não foram encontrados registros para a impressão de cartão!")
		oDlg:End()
		
	endif

ACTIVATE MSDIALOG oDlg CENTERED

Return() 

/*/{Protheus.doc} MsGridCTR
//TODO Função que cria o grid de contratos
@author g.sampaio
@since 12/09/2019
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
Local aFields 		:= {"MARK","CONTRATO","CLIENTE","LOJA","TITULAR","PLANO","DESCPLANO","DTCAD","DTATIV","ITEM","GRAU","TIPO","NOMEBENEF","CPFBENEF"}
Local aAlterFields 	:= {}

// percorro os campos definidos previamente
For nX := 1 To Len(aFields)
	
	if aFields[nX] == "MARK"

		Aadd(aHeaderEx, {"", aFields[nX] ,"@BMP",2,0,"","€€€€€€€€€€€€€€","C","","","",""})

	elseif aFields[nX] == "CONTRATO"

		Aadd(aHeaderEx, {"Contrato",aFields[nX],"@!",6,0,"","€€€€€€€€€€€€€€","C","","","",""})

    elseif aFields[nX] == "CLIENTE"

		Aadd(aHeaderEx, {"Cliente",aFields[nX],"@!",TamSX3("UF2_CLIENT")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

    elseif aFields[nX] == "LOJA"
        
        Aadd(aHeaderEx, {"Loja",aFields[nX],"@!",TamSX3("UF2_LOJA")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})

	elseif aFields[nX] == "TITULAR"
		
        Aadd(aHeaderEx, {"Nome Titular",aFields[nX],"@!",50,0,"","€€€€€€€€€€€€€€","C","","","",""})
	
    elseif aFields[nX] == "PLANO"
	
    	Aadd(aHeaderEx, {"Plano",aFields[nX],"@!",6,0,"","€€€€€€€€€€€€€€","C","","","",""})
	
    elseif aFields[nX] == "DESCPLANO"
	
    	Aadd(aHeaderEx, {"Descrição",aFields[nX],"@!",20,0,"","€€€€€€€€€€€€€€","C","","","",""})
	
    elseif aFields[nX] == "DTCAD"
	
    	Aadd(aHeaderEx, {"Dt.Cadastro",aFields[nX],"@D",6,0,"","€€€€€€€€€€€€€€","D","","","",""})
	
    elseif aFields[nX] == "DTATIV" // .and. MV_PAR04 <> 3 // exibe o tipo quando for diferente de remissivo
	
    	Aadd(aHeaderEx, {"Dt.Ativação",aFields[nX],"@D",6,0,"","€€€€€€€€€€€€€€","D","","","",""})
	
    elseif aFields[nX] == "ITEM" //.and. MV_PAR04 <> 3 // exibe o tipo quando for diferente de remissivo
	
    	Aadd(aHeaderEx, {"Item",aFields[nX],"@!",5,0,"","€€€€€€€€€€€€€€","C","","","",""})
	
    elseif aFields[nX] == "GRAU" //.and. MV_PAR04 <> 3 // exibe o tipo quando for diferente de remissivo
	
    	Aadd(aHeaderEx, {"Grau",aFields[nX],"@!",10,0,"","€€€€€€€€€€€€€€","C","","","",""})
	
    elseif aFields[nX] == "TIPO"
	
    	Aadd(aHeaderEx, {"Tipo",aFields[nX],"@!",12,0,"","€€€€€€€€€€€€€€","C","","","",""})		

    elseif aFields[nX] == "NOMEBENEF"
	
    	Aadd(aHeaderEx, {"Nome Beneficiario",aFields[nX],"@!",50,0,"","€€€€€€€€€€€€€€","C","","","",""})
	
	elseif aFields[nX] == "CPFBENEF"
	
    	Aadd(aHeaderEx, {"CPF Beneficiario",aFields[nX],"@R 999.999.999-99",14,0,"","€€€€€€€€€€€€€€","C","","","",""})

    endif
	
Next nX

// defino valor default de acordo com o tipo do campo
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
@since 12/09/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function RefreshGrid( oGrid, dDtDaAtivacao, dDtAteAtivacao, cDeContrato, cAteContrato, cPlano, cRota, nTipo, oQtTotal, nQtTotal )

Local aArea				:= GetArea()
Local aFieldFill		:= {}
Local aQtdParcSemPagar	:= 0
Local cQuery 			:= ""
Local lRetorno			:= .T.

Default cPlano          := ""
Default cRota			:= ""
Default cDeContrato		:= ""
Default cAteContrato	:= ""
Default nQtTotal        := 0
Default nTipo	    	:= 0
Default dDtDaAtivacao   := stod("")
Default dDtAteAtivacao  := stod("")

// verifico se não existe este alias criado
If Select("TRBCTR") > 0
	TRBCTR->(DbCloseArea())
EndIf     

cQuery := " SELECT " 																											
cQuery += "  			UF2.UF2_CODIGO     AS CONTRATO, 
cQuery += "             UF2.UF2_CLIENT     AS CLIENTE, 
cQuery += "             UF2.UF2_LOJA       AS LOJA, 
cQuery += "             CLIENTES.A1_NOME   AS TITULAR, 
cQuery += "             UF2.UF2_PLANO      AS PLANO, 
cQuery += "             PLANO.UF0_DESCRI   AS DESCPLANO, 
cQuery += "             UF2.UF2_DTCAD      AS DTCAD, 
cQuery += "             UF2.UF2_DTATIV     AS DTATIV, 
cQuery += "             BENEF.UF4_ITEM     AS ITEM,
cQuery += "             BENEF.UF4_GRAU     AS GRAU, 
cQuery += "             BENEF.UF4_TIPO     AS TIPO, 
cQuery += "             BENEF.UF4_NOME     AS NOMEBENEF, "
cQuery += "             BENEF.UF4_CPF      AS CPFBENEF "
cQuery += " FROM "
cQuery += RetSqlName("UF2") + " UF2 " 
																							
cQuery += " INNER JOIN "																				
cQuery += + RetSQLName("SA1") + " CLIENTES "															
cQuery += " ON "																						
cQuery += " CLIENTES.D_E_L_E_T_ = ' ' "																
cQuery += " AND CLIENTES.A1_FILIAL = '" + xFilial("SA1") + "' "										
cQuery += " AND CLIENTES.A1_COD = UF2.UF2_CLIENT "													
cQuery += " AND CLIENTES.A1_LOJA = UF2.UF2_LOJA  "													

cQuery += " INNER JOIN "																				
cQuery += + RetSQLName("UF0") + " PLANO "															
cQuery += " ON "																						
cQuery += " PLANO.D_E_L_E_T_ = ' ' "																
cQuery += " AND PLANO.UF0_FILIAL = '" + xFilial("UF0") + "' "										
cQuery += " AND PLANO.UF0_CODIGO = UF2.UF2_PLANO "

// verifico se a rota esta preenchida
If !Empty( Alltrim(cRota) )
	
	cQuery += " LEFT JOIN "																				
	cQuery += + RetSQLName("ZFC") + " BAIRROS "															
	cQuery += " ON "																						
	cQuery += " BAIRROS.D_E_L_E_T_ = ' ' "																
	cQuery += " AND BAIRROS.ZFC_FILIAL = '" + xFilial("ZFC") + "' "										
	cQuery += " AND CLIENTES.A1_XCODBAI = BAIRROS.ZFC_CODBAI "											

	cQuery += " LEFT JOIN "																				
	cQuery += + RetSQLName("U35") + " ITENS_ROTA "														
	cQuery += " ON "																						
	cQuery += " ITENS_ROTA.D_E_L_E_T_ = ' ' "																
	cQuery += " AND ITENS_ROTA.U35_FILIAL = '" + xFilial("U35") + "'"  										
	cQuery += " AND BAIRROS.ZFC_CODBAI = ITENS_ROTA.U35_CODBAI "											

	cQuery += " LEFT JOIN "																					
	cQuery += + RetSQLName("U34") + " ROTA "																
	cQuery += " ON "																						
	cQuery += " ROTA.D_E_L_E_T_ = ' ' "																	
	cQuery += " AND ITENS_ROTA.U35_FILIAL = ROTA.U34_FILIAL " 		 									
	cQuery += " AND ITENS_ROTA.U35_CODIGO = ROTA.U34_CODIGO "	

EndIf

cQuery += " LEFT JOIN "
cQuery += + RetSQLName("UF4") + " BENEF "
cQuery += " ON "																
cQuery += " BENEF.D_E_L_E_T_ = ' ' "
cQuery += " AND BENEF.UF4_CODIGO = UF2.UF2_CODIGO"																

cQuery += " WHERE " 																											
cQuery += " UF2.D_E_L_E_T_ <> '*' " 																							
cQuery += " AND UF2.UF2_FILIAL = '" + xFilial("UF2") + "' " 																	

// verifico se o plano esta preenchido
if !Empty( Alltrim(cPlano) )
	cQuery += " AND UF2.UF2_PLANO IN " + FormatIn( AllTrim(cPlano),";") 		 													
endif

// verifico se o rota esta preenchido
if !Empty( Alltrim(cRota) )
	cQuery += " AND ROTA.U34_CODIGO IN " + FormatIn( AllTrim(cRota),";") 		 													
endif

If nTipo == 1 // titular

	cQuery += " AND BENEF.UF4_TIPO = '3' 	"

ElseIf nTipo == 2 // beneficiarios

	cQuery += " AND BENEF.UF4_TIPO <> '3' 	"

EndIf

cQuery += " AND UF2.UF2_CODIGO BETWEEN '" + cDeContrato + "' AND '" + cAteContrato + "'" 
cQuery += " AND UF2.UF2_DTATIV BETWEEN '" + dtos(dDtDaAtivacao) + "' AND '" + dtos(dDtAteAtivacao) + "'" 
cQuery += " AND UF2.UF2_STATUS = 'A' "
cQuery += " ORDER BY UF2.UF2_CODIGO ASC, BENEF.UF4_TIPO DESC "     																						

// função que converte a query genérica para o protheus
cQuery := ChangeQuery(cQuery)

// crio o alias temporario
TcQuery cQuery New Alias "TRBCTR" // Cria uma nova area com o resultado do query  

If TRBCTR->(!Eof())

	// zero o acols
	oGrid:Acols := {}

	// se existir contratos a serem reajustados
	While TRBCTR->(!Eof())

		// zero as variaveis	
		aFieldFill  := {}

		// fixo ou faixa etaria - monto o array de dados para montar a Grid
		aadd(aFieldFill, "CHECKED" )	
		aadd(aFieldFill, TRBCTR->CONTRATO )
		aadd(aFieldFill, TRBCTR->CLIENTE )
		aadd(aFieldFill, TRBCTR->LOJA )
		aadd(aFieldFill, TRBCTR->TITULAR )
		aadd(aFieldFill, TRBCTR->PLANO )
		aadd(aFieldFill, TRBCTR->DESCPLANO )
		aadd(aFieldFill, Stod( TRBCTR->DTCAD ) )
		aadd(aFieldFill, Stod( TRBCTR->DTATIV ) )
		
		aadd(aFieldFill, TRBCTR->ITEM )
		aadd(aFieldFill, DescGrau( TRBCTR->GRAU ) )
		aadd(aFieldFill, DescTipo( TRBCTR->TIPO ) )
		
		//So imprime beneficiario se nao for o titular.
		If TRBCTR->TIPO != '3'

			aadd(aFieldFill, TRBCTR->NOMEBENEF )
			aadd(aFieldFill, TRBCTR->CPFBENEF )
		else
			aadd(aFieldFill, "" )
			aadd(aFieldFill, "" )
		endif

		aadd(aFieldFill, .F.)
		aadd(oGrid:Acols,aFieldFill)
		
		TRBCTR->( DbSkip() )
	EndDo

Else

	// retorno falso pois nao existem dados para serem exibidos	
	lRetorno	:= .F.

EndIf

// fecho o alias temporario criado
If Select("TRBCTR") > 0
	TRBCTR->(DbCloseArea())
EndIf 

RestArea(aArea)

Return(lRetorno)

/*/{Protheus.doc} DuoClique
//TODO Função chamada no duplo clique no grid
@author g.sampaio
@since 12/09/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function DuoClique(oObj,oQtTotal,nQtTotal)

Local nPosMark	    := aScan(oObj:aHeader,{|x| AllTrim(x[2])== "MARK"})       

// verifico se o registro esta selecionado
if oObj:aCols[oObj:nAt][nPosMark] == "CHECKED"
    
    // se nao estiver selecionado diminuo dos contadores
	oObj:aCols[oObj:nAt][nPosMark] 	:= "UNCHECKED" 
	nQtTotal--

else

    // se nao estiver selecionado aumento os contatadores
	oObj:aCols[oObj:nAt][nPosMark] 	:= "CHECKED" 
	nQtTotal++

endif

oQtTotal:Refresh()

oObj:oBrowse:Refresh()

Return()

/*/{Protheus.doc} MarcaTodos
//TODO Função chamada pela ação de clicar no cabeçalho dos grids
para selecionar todos os checkbox
@author g.sampaio
@since 12/09/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function MarcaTodos(_obj,oQtTotal,nQtTotal)

Local nX		    := 1

if __XVEZ == "0"
	__XVEZ := "1"
else
	if __XVEZ == "1"
		__XVEZ := "2"
	endif
endif

If __XVEZ == "2"
	
	nQtTotal  := 0 

	If _nMarca == 0
		
		For nX := 1 TO Len(_obj:aCols)
			_obj:aCols[nX][1] := "CHECKED"
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
	oQtTotal:Refresh()
	
	
Endif

Return()

/*/{Protheus.doc} AjustaSX1
//TODO Função que cria as perguntas na SX1.	
@author g.sampaio
@since 12/09/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relatório

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

//////////// Ativação ///////////////

U_xPutSX1( cPerg, "01","Da Ativação?"       , "Da Ativação?"     , "Da Ativação?"   , "dDtDaAtivacao"       , "D" , 8, 0, 0, "G" ,"","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "02","Até a Ativação?"    , "Até a Ativação?"  , "Até a Ativação?", "dDtAteAtivacao"      , "D" , 8, 0, 0, "G" ,"","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// Contrato ///////////////

U_xPutSX1( cPerg, "03","Contrato De?"       , "Contrato De?"     , "Contrato De?"   , "cDeContrato"         , "C" , 6, 0, 0, "C" ,"","UF2","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "04","Contrato Até?"      , "Contrato Até?"    , "Contrato Até?"  , "cAteContrato"        , "C" , 6, 0, 0, "C" ,"","UF2","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

///////////// Plano /////////////////

U_xPutSX1( cPerg, "05","Plano(s):"          ,"Plano(s):"        ,"Plano(s):"        ,"cPlano"               ,"C",99,0,0,"G","","UF0MRK","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// Rota ///////////////

U_xPutSX1( cPerg, "06","Rota(s):"           ,"Rota(s):"         ,"Rota(s):"         ,"cRota"                ,"C",99,0,0,"G","","U34MAR","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// Stiuação ///////////////

U_xPutSX1( cPerg, "07","Tipo:"              ,"Tipo:"            ,"Tipo:"            ,"cTipo"                ,"N",1,0,0,"C","","","","","MV_PAR07","1=Titular","","","","2=Beneficiario(a)","","","3=Ambos","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

Return( Nil )

/*/{Protheus.doc} DescGrau
Funcao para retornar o X3_CBOX do campo UF4_GRAU
@author g.sampaio
@since 13/09/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function DescGrau( cGrau )

Local aArea		:= GetArea()
Local aOpcao	:= {}
Local cRetorno	:= ""
Local cOpcao	:= ""
Local nPos		:= 0

Default cGrau	:= ""

// pego o conteudo do campo X3_CBOX do campo UF4_GRAU
cOpcao 	:= GetSx3Cache("UF4_GRAU","X3_CBOX")

// alimento o array de dados
aOpcao	:= StrToKarr( cOpcao, ";" )

// pego os dados a posicao do tipo de servico para buscar a descricao conforme na X3_CBOX
nPos 	:= aScan( aOpcao, { |x| SubStr( x, 1, 2 ) == cGrau } )

// verifico se encontrei o tipo de servico
If nPos > 0

	// pego o array de opcao
	cRetorno := SubStr(aOpcao[nPos], AT("=",aOpcao[nPos])+1)

EndIf

RestArea( aArea )

Return( cRetorno )

/*/{Protheus.doc} DescTipo
Funcao para retornar o X3_CBOX do campo UF4_TIPO
@author g.sampaio
@since 13/09/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function DescTipo( cTipo )

Local aArea		:= GetArea()
Local aOpcao	:= {}
Local cRetorno	:= ""
Local cOpcao	:= ""
Local nPos		:= ""

Default cTipo	:= ""

// pego o conteudo do campo X3_CBOX do campo UF4_TIPO
cOpcao 	:= GetSx3Cache("UF4_TIPO","X3_CBOX")

// alimento o array de dados
aOpcao	:= StrToKarr( cOpcao, ";" )

// pego os dados a posicao do tipo de servico para buscar a descricao conforme na X3_CBOX
nPos 	:= aScan( aOpcao, { |x| SubStr( x, 1, 1 ) == cTipo } )

// verifico se encontrei o tipo de servico
If nPos > 0

	// pego o array de opcao
	cRetorno := SubStr(aOpcao[nPos], AT("=",aOpcao[nPos])+1)

EndIf

RestArea( aArea )

Return( cRetorno )

/*/{Protheus.doc} Confirmar
Funcao para validar os dados e realizar as informacoes

@author g.sampaio
@since 16/09/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function Confirmar(oSay,oGrid,oDlg)

Local aArea 	:= GetArea()
Local aDados	:= {}
Local nPos		:= 0

// verifico se no acols existem itens marcados
nPos := Ascan( oGrid:Acols, { |x| Upper( AllTrim(x[1]) ) == "CHECKED" } )

// caso nao encontrar itens
If nPos == 0

	// mensagem para o usuario
	MsgAlert(" Não foram selecionados itens para a impressão de cartão! ")

	// retorno falso para a rotina
	lContinua := .F.

ElseIf nPos > 0 // verifico se existem dados

	// percorro todo o acols
	AEval( oGrid:Acols,  { | x | IIF( AllTrim(x[1]) == "CHECKED", Aadd( aDados, { x[2],x[3],x[4],x[12],x[13] } ),) } ) // Contrato - Cliente - Loja - Tipo - Nome Beneficiario

EndIf

// verifico se existem dados para a impressao
If Len( aDados ) > 0

	// trato a impressao 
	TrataImpressao( aDados )

EndIf

oDlg:End()

RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} TrataImpressao
Funcao para mandar os dados para a impressao 
de cartao

layout aDados - 
[1]Contrato 
[2]Cliente 
[3]Loja 
[4]Tipo 
[5]Nome Beneficiario

@author g.sampaio
@since 16/09/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/

Static Function TrataImpressao( aDados )

Local aArea 		:= GetArea()
Local aAreaUF2		:= UF2->( GetArea() )
Local aAreaSA1		:= SA1->( GetArea() )
Local aImpressao	:= {}
Local cValidade		:= ""
Local nI			:= 0
Local nAnosValidade	:= SuperGetMV("MV_XVALCAR",,5)			

Default aDados		:= {}

// monto a validade do cartao
If nAnosValidade > 0

	// monto a validade do cartao com base no parametro MV_XVALCAR e database da emissao
	cValidade := StrZero( Month( dDatabase ), 2 ) + "/" + StrZero( Year( dDatabase ) + nAnosValidade, 4 )

EndIf

// verifico se tenho dados para impressao
For nI := 1 To Len(aDados)
	
	// pego os dados do contrato
	UF2->( DbSetOrder(1) )
	If UF2->( MsSeek( xFilial("UF2")+aDados[nI][1] ) )

		// pego os dados do cliente
		SA1->( DbSetOrder(1) )
		If SA1->( MsSeek( xFilial("SA1")+aDados[nI][2]+aDados[nI][3] ) )

			// adicionando dados para a impressao
			Aadd( aImpressao, { AllTrim( UF2->UF2_CODIGO ),;
								AllTrim( SA1->A1_NOME ),;
								Alltrim( SA1->A1_END ) + Iif( !Empty( AllTrim( SA1->A1_COMPLEM ) ), ", " + AllTrim( SA1->A1_COMPLEM ),""),;
								Alltrim( SA1->A1_BAIRRO ) + Iif( !Empty( AllTrim( SA1->A1_CEP ) ), " - " + AllTrim( Transform( SA1->A1_CEP, "@R 99.999-999" ) ), "" ),;
								Alltrim( SA1->A1_MUN ) + " - " + AllTrim( SA1->A1_EST ),;
								AllTrim( Iif(AllTrim( SubStr( aDados[nI][4], 1, 1 ) ) <> "3", aDados[nI][5], "" ) ),;// verifico e dependente			
								AllTrim( UF2->UF2_NUMSOR ),;
								AllTrim( cValidade ) } )

		EndIf

	EndIf

Next nI

// verifico se tenho dados para impressao
If Len( aImpressao ) > 0

	// chamo a impressao do relatorio
	U_RFUNR012( aImpressao )

EndIf

RestArea( aAreaSA1 )
RestArea( aAreaUF2 )
RestArea( aArea )

Return(Nil)