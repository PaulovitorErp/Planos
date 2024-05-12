#Include "totvs.CH"
#include "topconn.ch"  

/*/{Protheus.doc} RCPGE020
//Consulta Especifica de Produtos
//selecao de produtos pela tela de contrato cemiterio
@Author Raphael Martins
@Since 13/08/2018
@Version 1.0
@Return
@Type function
/*/

User Function RCPGE020(cGrid)
                        
Local oGroup1		:= NIL
Local oGroup2		:= NIL
Local oGroup3		:= NIL
Local oSay1			:= NIL
Local oSay2			:= NIL
Local oDlg			:= NIL
Local oCodigo		:= NIL
Local oNome			:= NIL
Local oConfirmar	:= NIL
Local oCancelar		:= NIL
Local oGrid			:= NIL
Local oArial 		:= TFont():New("Arial Narrow",,016,,.F.,,,,,.F.,.F.)
Local oArialCinza 	:= TFont():New("Arial",,016,,.T.,,,,,.F.,.F.)
Local oArialN 		:= TFont():New("Arial",,016,,.T.,,,,,.F.,.F.)
Local cCodigo		:= Space(TamSx3("B1_COD")[1])
Local cNome			:= Space(TamSx3("B1_DESC")[1])
Local lContinua		:= .T.
Local aRet			:= {}

Static cRet			:= ""

  	DEFINE MSDIALOG oDlg TITLE "Consulta Serviços" FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL

    @ 003, 003 GROUP oGroup1 TO 033, 298 PROMPT "Filtros" OF oDlg COLOR 8421504, 16777215 PIXEL
    @ 014, 008 SAY oSay1 PROMPT "Código:" SIZE 025, 007 OF oDlg FONT oArialN COLORS 0, 16777215 PIXEL
    @ 013, 032 MSGET oCodigo VAR cCodigo SIZE 087, 011 OF oDlg COLORS 0, 16777215 Picture PesqPict("SB1","B1_COD") FONT oArial PIXEL
    
    oCodigo:bLostFocus := {|| RefreshGrid(oGrid,cCodigo,cNome,cGrid)}
    
    @ 014, 125 SAY oSay2 PROMPT "Nome:" SIZE 027, 007 OF oDlg FONT oArialN COLORS 0, 16777215 PIXEL
    @ 013, 146 MSGET oNome VAR cNome SIZE 149, 011 OF oDlg COLORS 0, 16777215 Picture PesqPict("SB1","B1_DESC") FONT oArial PIXEL
    
    oNome:bLostFocus := {|| RefreshGrid(oGrid,cCodigo,cNome,cGrid)}
    
    @ 035, 003 GROUP oGroup2 TO 177, 298 PROMPT "Serviços do Contrato" OF oDlg COLOR 8421504, 16777215 PIXEL
    
    //monto a grid de servicos
    oGrid := MsGridCTR(oDlg)
    
    // duplo clique no grid
    oGrid:oBrowse:bLDblClick := {|| cRet := SelServico(oDlg,oGrid,cGrid)}

    @ 179, 003 GROUP oGroup3 TO 196, 298 OF oDlg COLOR 0, 16777215 PIXEL
    @ 183, 210 BUTTON oConfirmar PROMPT "Confirmar" SIZE 037, 010 OF oDlg Action( cRet := SelServico(oDlg,oGrid,cGrid) ) FONT oArialN PIXEL
    @ 183, 256 BUTTON oCancelar PROMPT "Cancelar" SIZE 037, 010 OF oDlg Action(lContinua := .F.,oDlg:End()) FONT oArialN PIXEL

    FWMsgRun(,{|oSay| lContinua := RefreshGrid(oGrid,cCodigo,cNome,cGrid) },'Aguarde...','Consultando Produtos!')
    
    // caso não tenha encontrato servicos
  	if !lContinua
		
  		Alert("Não foram encontrados servicos para o contrato!")
  		oDlg:End()
		
	endif
	
    ACTIVATE MSDIALOG oDlg CENTERED

    //posiciono no item selecionado na U04 para retorno da consulta
  	DBSelectArea("SB1")
  	SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD
  	
  	if lContinua .And. !SB1->(DbSeek(xFilial("SB1")+cRet))
    
  		lContinua := .F.
    
    else
    	
    	&(ReadVar()) := cRet
    	
    endif
    

  	
Return(lContinua)

/*/{Protheus.doc} URetPRDCEM
//Retorno da consulta PRDCEM
@Author Raphael Martins
@Since 13/08/2018
@Version 1.0
@Return
@Type function
/*/

User Function URetPRDCEM()
Return(cRet)

/*/{Protheus.doc} MsGridCTR
//TODO Função que cria o grid de servicos
@author Raphael Martins
@since 14/05/2018
@version 1.0	
@param 	oTela	 	- Dialog da Tela de consulta
@return oGrid		- MsNewGetdados criada dos servicos consultados
@type function
/*/

Static Function MsGridCTR(oTela)

Local oGrid			:= NIL
Local nX			:= 1
Local aHeaderEx 	:= {}
Local aColsEx 		:= {}
Local aFieldFill 	:= {}
Local aFields 		:= {"ITEM","CODIGO","DESCRICAO","CTR_SALDO","PRECO"}
Local aAlterFields 	:= {}

For nX := 1 To Len(aFields)
	
	if aFields[nX] == "ITEM"
		Aadd(aHeaderEx, {"Item","ITEM","@E 999",3,0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "CODIGO"
		Aadd(aHeaderEx, {"Codigo","CODIGO",PesqPict("SB1","B1_COD"),TamSX3("B1_COD")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "DESCRICAO"
		Aadd(aHeaderEx, {"Descricao","DESCRICAO",PesqPict("SB1","B1_DESC"),TamSX3("B1_DESC")[1],0,"","€€€€€€€€€€€€€€","C","","","",""})
	elseif aFields[nX] == "CTR_SALDO"
		Aadd(aHeaderEx, {"Controla Saldo","CTR_SALDO",PesqPict("SB1","B1_XDEBPRE"),TamSX3("B1_XDEBPRE")[1],0,"","€€€€€€€€€€€€€€","C","","","S=Sim;N=Nao",""})
	elseif aFields[nX] == "PRECO"
		Aadd(aHeaderEx, {"Preco Venda","PRECO",PesqPict("DA1","DA1_PRCVEN"),TamSX3("DA1_PRCVEN")[1],TamSX3("DA1_PRCVEN")[2],"","€€€€€€€€€€€€€€","N","","","",""})
	
	endif
		
Next nX

// Define field values
For nX := 1 To Len(aHeaderEx)
	
	if aHeaderEx[nX,8] == "C"
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

oGrid := MsNewGetDados():New( 044,008,173, 293, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,;
		 , 999, "AllwaysTrue", "", "AllwaysTrue",oTela, aHeaderEx, aColsEx)                          


Return(oGrid)

/*{Protheus.doc} RefreshGrid
//TODO Função chamada para preencher a grid de produtos/servicos
@author Raphael Martins
@since 08/05/2018
@version 1.0
@param oGrid 			- Objeto da Grid de Contratos 
@param cServico		 	- Codigo do Servico do Contrato
@param cDescricao	 	- Descricao do Servico do Contrato
@param cGrid		 	- Grid utilizada na consulta especifica
@return lRet			- Encontrado produtos
@type function
/*/
Static Function RefreshGrid(oGrid,cServico,cDescricao,cGrid)

Local aArea			:= GetArea()
Local aAreaU00		:= U00->(GetArea())
Local cQry			:= ""
Local cCodTab		:= ""
Local cGrpSrv		:= SuperGetMv("MV_XGRPSVC",.F.,"999") 
Local lRet			:= .F.
Local lConsulta		:= .T.
Local nItem			:= 0
Local aFields 		:= {"ITEM","CODIGO","DESCRICAO","CTR_SALDO","PRECO"}
Local aSaveLines	:= {}
Local oModel		:= FWModelActive()
Local oView			:= FWViewActive()
Local oView			:= NIL
Local nX			:= 1

Default cServico	:= ""
Default	cDescricao	:= "" 
	
// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

//valido se foi chamado da tela de personalizacao de planos
if cGrid == "PPROD" .Or. cGrid == "PSERV"
	
	aSaveLines	:= FWSaveRows() 
	oModelU43	:= oModel:GetModel("U43MASTER") 
	oModelU44	:= oModel:GetModel("U44DETAIL") 
	oModelU45	:= oModel:GetModel("U45DETAIL")
	oModelU46	:= oModel:GetModel("U46DETAIL")
	oModelU47	:= oModel:GetModel("U47DETAIL")
	
	//grid de Alteracao e Exclusao de Produtos
	if cGrid == "PPROD"  
	
		//verifico se o campo de alteracao de plano esta preenchido
		//caso sim, a consulta sera realizada na tabela de produtos do novo plano 
		if Empty(oModelU43:GetValue("U43_PLANNO"))
			
			oGrid:aCols := {}
			
			For nX := 1 To oModelU44:Length()
				
				oModelU44:GoLine(nX)
				
				if !oModelU44:isDeleted()	
					//filtro de acordo com os campos digitados
					if !Empty(cServico) .And. !(Alltrim(cServico) $ oModelU44:GetValue("U44_PRODUT"))  
						lConsulta := .F.
					endif
					
					if !Empty(cDescricao) .And. !(Alltrim(cDescricao) $ oModelU44:GetValue("U44_DESCRI")) 
						lConsulta := .F.
					endif
					
					if lConsulta
						
						nItem++ 
					
						aFieldFill := {}
					
						cItem := StrZero(nItem,3)
					
						aadd(aFieldFill, cItem)
						aadd(aFieldFill, oModelU44:GetValue("U44_PRODUT"))
						aadd(aFieldFill, oModelU44:GetValue("U44_DESCRI"))
						aadd(aFieldFill, oModelU44:GetValue("U44_CTRSLD"))
						aadd(aFieldFill, oModelU44:GetValue("U44_VLRUNI"))
					
						Aadd(aFieldFill, .F.)
						aadd(oGrid:Acols,aFieldFill) 
						
						lRet 		:= .T.
						
					endif
					
					lConsulta := .T.
				
				endif
				
			Next nX
			
		else
		
			oGrid:aCols := {}
			
			For nX := 1 To oModelU46:Length()
				
				oModelU46:GoLine(nX)
				
				if !oModelU46:isDeleted()	
					
					//filtro de acordo com os campos digitados
					if !Empty(cServico) .And. !(Alltrim(cServico) $ oModelU46:GetValue("U46_PRODUT"))  
						lConsulta := .F.
					endif
					
					if !Empty(cDescricao) .And. !(Alltrim(cDescricao) $ oModelU46:GetValue("U46_DESCRI")) 
						lConsulta := .F.
					endif
					
					if lConsulta
						
						nItem++ 
					
						aFieldFill := {}
					
						cItem := StrZero(nItem,3)
					
						aadd(aFieldFill, cItem)
						aadd(aFieldFill, oModelU46:GetValue("U46_PRODUT"))
						aadd(aFieldFill, oModelU46:GetValue("U46_DESCRI"))
						aadd(aFieldFill, oModelU46:GetValue("U46_CTRSLD"))
						aadd(aFieldFill, oModelU46:GetValue("U46_VLRUNI"))
					
						Aadd(aFieldFill, .F.)
						aadd(oGrid:Acols,aFieldFill) 
						
						lRet 		:= .T.
						
					endif
					
					lConsulta := .T.
				
				endif
				
			Next nX
	
		endif
	
	else
		
		//verifico se o campo de alteracao de plano esta preenchido
		//caso sim, a consulta sera realizada na tabela de servicos do novo plano 
		if Empty(oModelU43:GetValue("U43_PLANNO"))
			
			oGrid:aCols := {}
			
			For nX := 1 To oModelU45:Length()
				
				if !oModelU45:isDeleted()
				
					oModelU45:GoLine(nX)
						
					//filtro de acordo com os campos digitados
					if !Empty(cServico) .And. !(Alltrim(cServico) $ oModelU45:GetValue("U45_PRODUT"))  
						lConsulta := .F.
					endif
					
					if !Empty(cDescricao) .And. !(Alltrim(cDescricao) $ oModelU45:GetValue("U45_DESCRI")) 
						lConsulta := .F.
					endif
					
					if lConsulta
						
						nItem++ 
					
						aFieldFill := {}
					
						cItem := StrZero(nItem,3)
					
						aadd(aFieldFill, cItem)
						aadd(aFieldFill, oModelU45:GetValue("U45_PRODUT"))
						aadd(aFieldFill, oModelU45:GetValue("U45_DESCRI"))
						aadd(aFieldFill, oModelU45:GetValue("U45_CTRSLD"))
						aadd(aFieldFill, oModelU45:GetValue("U45_VLRUNI"))
					
						Aadd(aFieldFill, .F.)
						aadd(oGrid:Acols,aFieldFill) 
						
						lRet 		:= .T.
						
					endif
					
					lConsulta := .T.
				
				endif
				
			Next nX
			
		else
		
			oGrid:aCols := {}
			
			For nX := 1 To oModelU47:Length()
				
				oModelU47:GoLine(nX)
				
				if !oModelU47:isDeleted()
					
					//filtro de acordo com os campos digitados
					if !Empty(cServico) .And. !(Alltrim(cServico) $ oModelU47:GetValue("U47_PRODUT"))  
						lConsulta := .F.
					endif
					
					if !Empty(cDescricao) .And. !(Alltrim(cDescricao) $ oModelU47:GetValue("U47_DESCRI")) 
						lConsulta := .F.
					endif
					
					if lConsulta
						
						nItem++ 
					
						aFieldFill := {}
					
						cItem := StrZero(nItem,3)
					
						aadd(aFieldFill, cItem)
						aadd(aFieldFill, oModelU47:GetValue("U47_PRODUT"))
						aadd(aFieldFill, oModelU47:GetValue("U47_DESCRI"))
						aadd(aFieldFill, oModelU47:GetValue("U47_CTRSLD"))
						aadd(aFieldFill, oModelU47:GetValue("U47_VLRUNI"))
					
						Aadd(aFieldFill, .F.)
						aadd(oGrid:Acols,aFieldFill) 
						
						lRet 		:= .T.
						
					endif
					
					lConsulta := .T.
				
				endif
				
			Next nX
	
		endif
	
	endif
	
else
	
	//verifico a se a rotina foi chamado da personalizacao do plano
	cCodTab := if( Alltrim(oModel:cSource) == "RCPGE021" ,M->U43_TABPRE,M->U00_TABPRE)
	
	cQry := " SELECT " 
	cQry += " PRODUTOS.B1_COD PRODUTO, "
	cQry += " PRODUTOS.B1_DESC DESCRICAO, "
	cQry += " (CASE WHEN PRODUTOS.B1_XDEBPRE <> 'S'THEN 'N' ELSE 'S' END)  CTR_SALDO, "
	cQry += " ITENSTAB.DA1_PRCVEN PRECO "
	cQry += " FROM " 
	cQry += RetSQLName("SB1") + " PRODUTOS (NOLOCK) "
	cQry += " INNER JOIN  "
	cQry += RetSQLName("DA1") + " ITENSTAB (NOLOCK) "
	cQry += " ON PRODUTOS.D_E_L_E_T_ = ' '  "
	cQry += " AND ITENSTAB.D_E_L_E_T_ = ' '  "
	cQry += " AND PRODUTOS.B1_FILIAL = '"+xFilial("SB1")+"'  "
	cQry += " AND ITENSTAB.DA1_FILIAL = '"+xFilial("DA1")+"' "
	cQry += " AND PRODUTOS.B1_COD = ITENSTAB.DA1_CODPRO "
	cQry += " INNER JOIN " 
	cQry += RetSQLName("DA0") + " TABELA (NOLOCK) "
	cQry += " ON TABELA.D_E_L_E_T_ = ' '  "
	cQry += " AND ITENSTAB.DA1_FILIAL = TABELA.DA0_FILIAL "
	cQry += " AND ITENSTAB.DA1_CODTAB = TABELA.DA0_CODTAB "
	cQry += " WHERE " 
	cQry += " PRODUTOS.B1_MSBLQL <> '1' "
	cQry += " AND (TABELA.DA0_DATATE = ' ' OR TABELA.DA0_DATATE >= '" + DTOS(dDatabase) + "' ) "
	cQry += " AND TABELA.DA0_ATIVO <> '2' "
	cQry += " AND TABELA.DA0_CODTAB = '" + cCodTab + "' "
	
	//valido se a consulta e de produtos ou servicos do cemiterio
	if cGrid == 'U01'
		cQry += " AND PRODUTOS.B1_GRUPO <> '" + cGrpSrv + "' " 
	else
		cQry += " AND PRODUTOS.B1_GRUPO = '" + cGrpSrv + "' " 
	endif
	
	//filtro de acordo com os campos digitados
	if !Empty(cServico)
		
		cQry += " AND PRODUTOS.B1_COD LIKE '%" +Alltrim(cServico)+ "%' "
		
	endif
	
	if !Empty(cDescricao)
		
		cQry += " AND PRODUTOS.B1_DESC LIKE '%" +Alltrim(cDescricao)+ "%' "
		
	endif
	
	cQry += " ORDER BY PRODUTOS.B1_COD "
	
	
	// função que converte a query genérica para o protheus
	cQry := ChangeQuery(cQry)
	
	// crio o alias temporario
	TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   
	
	oGrid:Acols := {}
	aFieldFill 	:= {}
	
	if QRY->(!Eof())
		
		lRet 		:= .T. 
	
		While QRY->(!Eof()) 
		
			nItem++ 
			
			aFieldFill := {}
			
			cItem := StrZero(nItem,3)
			
			aadd(aFieldFill, cItem)
			aadd(aFieldFill, QRY->PRODUTO)
			aadd(aFieldFill, QRY->DESCRICAO)
			aadd(aFieldFill, QRY->CTR_SALDO)
			aadd(aFieldFill, QRY->PRECO)
			
			Aadd(aFieldFill, .F.)
			aadd(oGrid:Acols,aFieldFill) 
			
			QRY->(DbSkip())
			
		EndDo
		
	else
		
		Aadd(aFieldFill, "")
		Aadd(aFieldFill, "")
		Aadd(aFieldFill, "")
		Aadd(aFieldFill, "")
		Aadd(aFieldFill, 0)
		Aadd(aFieldFill, .F.)
		
		aadd(oGrid:Acols,aFieldFill) 
		
	endif

endif

oGrid:oBrowse:Refresh()

RestArea(aArea)
RestArea(aAreaU00)

Return(lRet)

/*/{Protheus.doc} SelServico
//TODO Funcao para confirmar do servico selecionado

@author Raphael Martins
@since 08/05/2018
@version 1.0
@param oDlg	 			- Objeto Dialog
@param oGrid		 	- Grid de Servicos
@return cRet			- Servico Selecionado
@type function
/*/

Static Function SelServico(oDlg,oGrid,cGrid)
  
Local cTipo				:= ""
Local oModel			:= FWModelActive()     
Local oView				:= FWViewActive()
Local aSaveLines  		:= FWSaveRows() 
Local nPosProdut		:= aScan(oGrid:aHeader,{|x| AllTrim(x[2]) == "CODIGO"}) 
Local cRet				:= ""

oDlg:End()

cRet := oGrid:aCols[oGrid:nAT,nPosProdut]

If oView <> nil
	oView:Refresh()
EndIf
		
oDlg:End()

//restauro as linhas posicionadas
FWRestRows( aSaveLines )
	
Return(cRet)


/*/{Protheus.doc} VldProdCem
//TODO Funcao para validar o produto digitado
@author Raphael Martins
@since 13/08/2018
@version 1.0
@param oDlg	 			- Objeto Dialog
@param oGrid		 	- Grid de Servicos
@return lRet			- Produto Validado
@type function
/*/

User Function VldProdCem()

Local aArea		:= GetArea()
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaU01	:= U01->(GetArea())
Local oModel	:= FWModelActive()     
Local oView		:= FWViewActive()
Local oModelU01	:= oModel:GetModel("U01DETAIL") 
Local oModelU00	:= oModel:GetModel("U00MASTER") 
Local cProduto	:= oModelU01:GetValue("U01_PRODUT")
Local cGrpSrv	:= SuperGetMv("MV_XGRPSVC",.F.,"999")
Local cPlano	:= oModelU00:GetValue("U00_PLANO")
Local cTabPre	:= oModelU00:GetValue("U00_TABPRE")
Local lRet		:= .T.

//valido se o produto existe no cadastro de produtos
SB1->(DBSetOrder(1)) //B1_FILIAL + B1_COD

if !Empty(cProduto)
	
	if SB1->(DbSeek(xFilial("SB1")+cProduto))
		
		//verifico se esta contido no parametro de servico cemiterio
		if SB1->B1_GRUPO <> cGrpSrv
			
			if ( nPreco := RetPrecoVenda(cTabPre,cProduto) ) > 0 
				
				U06->(DbSetOrder(2)) //U06_FILIAL+U06_CODIGO+U06_PRODUT
		
				if U06->(DbSeek(xFilial("U06")+cPlano+cProduto))
					
					oModelU01:LoadValue("U01_TIPO"	, "AVGBOX1.PNG" )
					oModelU01:LoadValue("U01_QUANT"	, U06->U06_QUANT )
					oModelU01:LoadValue("U01_SALDO"	, U06->U06_QUANT )
					oModelU01:LoadValue("U01_VLRTOT"	, nPreco * U06->U06_QUANT)
					
				else
					
					oModelU01:LoadValue("U01_TIPO"		, "ADDITENS.PNG" )
					oModelU01:LoadValue("U01_QUANT"	, 1 )
					oModelU01:LoadValue("U01_SALDO"	, 1 )
					oModelU01:LoadValue("U01_VLRTOT"	, nPreco)
					
				endif
				
				oModelU01:LoadValue("U01_DESCRI"	, SB1->B1_DESC ) 
				oModelU01:LoadValue("U01_VLRUNI"	, nPreco) 
				oModelU01:LoadValue("U01_CTRSLD"	, If(!Empty(SB1->B1_XDEBPRE),SB1->B1_XDEBPRE,'N')) 
				
				
			else
			
				lRet := .F.
			
			endif
			
			
		else
			
			lRet := .F.
			Help(,,'Help',,"Produto definido como serviço cemitério, favor seleciona-lo em Serviços Habilitados!",1,0)	
		
		
		endif
		
	else
		
		lRet := .F.
		Help(,,'Help',,"Produto não encontrado no cadastro de produtos!",1,0)	
		
	endif

else
	
	oModelU01:LoadValue("U01_TIPO"	, "" )
	oModelU01:LoadValue("U01_QUANT"	, 0	 )
	oModelU01:LoadValue("U01_SALDO"	, 0  )
	oModelU01:LoadValue("U01_VLRTOT"	, 0  )
	oModelU01:LoadValue("U01_DESCRI"	, "" ) 
	oModelU01:LoadValue("U01_VLRUNI"	, 0  ) 
	oModelU01:LoadValue("U01_CTRSLD"	, "" ) 
				
endif

//reprocesso valor do contrato 
U_UCalcLiqCem()


RestArea(aArea)
RestArea(aAreaSB1)
RestArea(aAreaU01)



Return(lRet)
/*/{Protheus.doc} VldServCem
//TODO Funcao para validar o servico digitado
@author Raphael Martins
@since 13/08/2018
@version 1.0
@param oDlg	 			- Objeto Dialog
@param oGrid		 	- Grid de Servicos
@return lRet			- Produto Validado
@type function
/*/

User Function VldServCem()

Local aArea		:= GetArea()
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaU37	:= U37->(GetArea())

Local oModel	:= FWModelActive()     
Local oView		:= FWViewActive()
Local oModeU37	:= oModel:GetModel("U37DETAIL") 
Local oModelU00	:= oModel:GetModel("U00MASTER") 
Local cProduto	:= oModeU37:GetValue("U37_SERVIC")
Local cGrpSrv	:= SuperGetMv("MV_XGRPSVC",.F.,"999")
Local cTabPre	:= oModelU00:GetValue("U00_TABPRE")
Local cPlano	:= M->U00_PLANO

Local lRet		:= .T.

//valido se o produto existe no cadastro de produtos
SB1->(DBSetOrder(1)) //B1_FILIAL + B1_COD

if !Empty(cProduto)
	
	if SB1->(DbSeek(xFilial("SB1")+cProduto))
		
		//verifico se esta contido no parametro de servico cemiterio
		if SB1->B1_GRUPO == cGrpSrv
			
			if ( nPreco := RetPrecoVenda(cTabPre,cProduto) ) > 0 
				
				U36->(DbSetOrder(2)) //U36_FILIAL+U36_CODIGO+U36_PRODUT
		
				if U36->(DbSeek(xFilial("U36")+cPlano+cProduto))
					
					oModeU37:LoadValue("U37_TIPO"	, "AVGBOX1.PNG" )
					oModeU37:LoadValue("U37_QUANT"	, U36->U36_QUANT )
					oModeU37:LoadValue("U37_SALDO"	, U36->U36_QUANT )
					oModeU37:LoadValue("U37_VLRTOT"	, nPreco * U36->U36_QUANT)
					
				else
					
					oModeU37:LoadValue("U37_TIPO"		, "ADDITENS.PNG" )
					oModeU37:LoadValue("U37_QUANT"	, 1 )
					oModeU37:LoadValue("U37_SALDO"	, 1 )
					oModeU37:LoadValue("U37_VLRTOT"	, nPreco)
					
				endif
				
				oModeU37:LoadValue("U37_DESCRI"	, SB1->B1_DESC ) 
				oModeU37:LoadValue("U37_VLRUNI"	, nPreco) 
				oModeU37:LoadValue("U37_CTRSLD"	, If(!Empty(SB1->B1_XDEBPRE),SB1->B1_XDEBPRE,'N')) 
				
				
			else
			
				lRet := .F.
			
			endif
			
			
		else
			
			lRet := .F.
			Help(,,'Help',,"Produto NÃO está definido como serviço cemitério, favor seleciona-lo em Itens do Contrato!",1,0)	
		
		
		endif
		
	else
		
		lRet := .F.
		Help(,,'Help',,"Produto não encontrado no cadastro de produtos!",1,0)	
		
	endif

else
	
	oModeU37:LoadValue("U37_TIPO"	, "" )
	oModeU37:LoadValue("U37_QUANT"	, 0	 )
	oModeU37:LoadValue("U37_SALDO"	, 0  )
	oModeU37:LoadValue("U37_VLRTOT"	, 0  )
	oModeU37:LoadValue("U37_DESCRI"	, "" ) 
	oModeU37:LoadValue("U37_VLRUNI"	, 0  ) 
	oModeU37:LoadValue("U37_CTRSLD"	, "" ) 
				
endif

//reprocesso valor do contrato 
U_UCalcLiqCem()

RestArea(aArea)
RestArea(aAreaSB1)
RestArea(aAreaU37)

Return(lRet)

/*/{Protheus.doc} RetPrecoVenda
Funcao para retornar o preco de venda do item
de acordo com a tabela
@author Raphael Martins 
@since 21/05/2018
@version P12
@return nPreco - Preco de Venda da Tabela
/*/
Static Function RetPrecoVenda(cCodTab,cProduto)

Local aAreaDA1	:= DA1->(GetArea())
Local cQry 		:= ""
Local nPreco	:= 0

cQry := " SELECT "
cQry += " DA1_PRCVEN PRECO, "
cQry += " DA1_DATVIG VIGENCIA " 
cQry += " FROM  "
cQry += + RetSQLName("DA1")
cQry += " WHERE "
cQry += " D_E_L_E_T_ = ' '  "
cQry += " AND DA1_FILIAL = '"+xFilial("DA1")+"' "
cQry += " AND DA1_CODPRO = '"+cProduto+"'
cQry += " AND DA1_CODTAB = '"+cCodTab+"'
cQry += " ORDER BY DA1_DATVIG DESC

if Select("QRYTAB") > 0 
	QRYTAB->(DbCloseArea())
endif

cQry := ChangeQuery(cQry)

TcQuery cQry NEW Alias "QRYTAB"

//verifico se o preco esta vigente
if STOD(QRYTAB->VIGENCIA) <= dDataBase
	nPreco := QRYTAB->PRECO
else 
 	Help( ,, 'Help',, 'O Produto/Servico: '+ Alltrim(cProduto) +' não possui preço vigente na tabela: ' +Alltrim(cCodTab)+'', 1, 0 ) 
endif

RestArea(aAreaDA1)

Return(nPreco)

