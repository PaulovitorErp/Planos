#Include "PROTHEUS.CH"
#include "topconn.ch"

/*/{Protheus.doc} RFUNE028
//Consulta Especifica de Produtos
//selecao de produtos pela tela de contrato Funeraria
@Author Raphael Martins
@Since 13/08/2018
@Version 1.0
@Return
@Type function
/*/

User Function RFUNE028(cGrid)

	Local aArea			:= GetArea()
	Local aAreaSB1		:= SB1->( GetArea() )
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
	Local oProcess      := Nil
	Local oArial 		:= TFont():New("Arial Narrow",,016,,.F.,,,,,.F.,.F.)
	Local oArialCinza 	:= TFont():New("Arial",,016,,.T.,,,,,.F.,.F.)
	Local oArialN 		:= TFont():New("Arial",,016,,.T.,,,,,.F.,.F.)
	Local cCodigo		:= Space(TamSx3("B1_COD")[1])
	Local cNome			:= Space(TamSx3("B1_DESC")[1])
	Local lContinua		:= .T.
	Local lEnd			:= .F.
	Local aRet			:= {}

	Static cRet			:= ""

	Default cGrid		:= ""

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
	oGrid:oBrowse:bLDblClick := {|| cRet := SelServico(oDlg,oGrid)}

	@ 179, 003 GROUP oGroup3 TO 196, 298 OF oDlg COLOR 0, 16777215 PIXEL
	@ 183, 210 BUTTON oConfirmar PROMPT "Confirmar" SIZE 037, 010 OF oDlg Action( cRet := SelServico(oDlg,oGrid) ) FONT oArialN PIXEL
	@ 183, 256 BUTTON oCancelar PROMPT "Cancelar" SIZE 037, 010 OF oDlg Action(lContinua := .F.,oDlg:End()) FONT oArialN PIXEL

	// consulta de dados da rotina
	oProcess := MsNewProcess():New({|lEnd| lContinua := RefreshGrid( oGrid, cCodigo, cNome, cGrid, @oProcess, @lEnd ) },'Consultando Produtos!','Aguarde...',.T.)
	oProcess:Activate()

	// caso não tenha encontrato servicos
	if !lContinua

		Alert("Não foram encontrados servicos para o contrato!")
		oDlg:End()

	endif

	ACTIVATE MSDIALOG oDlg CENTERED

	//posiciono no item selecionado na U04 para retorno da consulta
	DBSelectArea("SB1")
	SB1->(DbSetOrder(1)) //B1_FILIAL + B1_COD

	if lContinua .And. !SB1->(MsSeek(xFilial("SB1")+cRet))

		lContinua := .F.

	else

		&(ReadVar()) := cRet

	endif

	RestArea( aAreaSB1 )
	RestArea( aArea )

Return(lContinua)

/*/{Protheus.doc} URetPRDCEM
//Retorno da consulta SERFUN
@Author Raphael Martins
@Since 13/08/2018
@Version 1.0
@Return
@Type function
/*/

User Function URetPrdFun()

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
			Aadd(aFieldFill, Stod(""))
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
@return lRet			- Encontrado produtos
@type function
/*/
Static Function RefreshGrid( oGrid, cServico, cDescricao, cGrid, oProcess, lEnd )

	Local aArea			:= GetArea()
	Local aAreaUF2		:= UF2->(GetArea())
	Local aFields 		:= {"ITEM","CODIGO","DESCRICAO","CTR_SALDO","PRECO"}
	Local cQry			:= ""
	Local cCodTab		:= ""
	Local cGrpSrv		:= SuperGetMv("MV_XGRPSVC",.F.,"999") 
	Local lRet			:= .F.
	Local lConsulta		:= .T.
	Local nItem			:= 0
	Local oModel		:= FWModelActive()
	Local nX			:= 1

	Default cServico	:= ""
	Default	cDescricao	:= "" 
	Default lEnd		:= .F.

	//verifico se a chamada da consulta e feita pela tela de personalizacao de planos
	if cGrid == "PER"

		aSaveLines	:= FWSaveRows() 
		oModel		:= FWModelActive() 
		oView		:= FWViewActive() 
		oModelUH2	:= oModel:GetModel("UH2MASTER") 
		oModelUH3	:= oModel:GetModel("UH3DETAIL") 
		oModelUH4	:= oModel:GetModel("UH4DETAIL")
		oModelUH6	:= oModel:GetModel("UH6DETAIL")
	
		//verifico se o campo de alteracao de plano esta preenchido
		//caso sim, a consulta sera realizada na tabela de produtos do novo plano 
		if Empty(oModelUH2:GetValue("UH2_PLANNO"))
			
			oGrid:aCols := {}
			
			For nX := 1 To oModelUH3:Length()
			
				oModelUH3:GoLine(nX)
				
				if !oModelUH3:isDeleted()
				
					//filtro de acordo com os campos digitados
					if !Empty(cServico) .And. !(Alltrim(cServico) $ oModelUH3:GetValue("UH3_PRODUT"))
						lConsulta := .F.
					endif
					
					if !Empty(cDescricao) .And. !(Alltrim(cDescricao) $ oModelUH3:GetValue("UH3_DESCRI"))
						lConsulta := .F.
					endif
					
					if lConsulta
						
						nItem++ 
						
						aFieldFill := {}
						
						cItem := StrZero(nItem,3)
						
						aadd(aFieldFill, cItem)
						aadd(aFieldFill, oModelUH3:GetValue("UH3_PRODUT"))
						aadd(aFieldFill, oModelUH3:GetValue("UH3_DESCRI"))
						aadd(aFieldFill, oModelUH3:GetValue("UH3_CTRSLD"))
						aadd(aFieldFill, oModelUH3:GetValue("UH3_VLRUNI"))
					
						Aadd(aFieldFill, .F.)
						aadd(oGrid:Acols,aFieldFill) 
							
						lRet 		:= .T.
						
					endif
					
					lConsulta := .T.
				
				endif
				
			Next nX
			
		else
		
			oGrid:aCols := {}
			
			For nX := 1 To oModelUH4:Length()
				
				oModelUH4:GoLine(nX)
				
				if !oModelUH4:isDeleted()
					
					//filtro de acordo com os campos digitados
					if !Empty(cServico) .And. !(Alltrim(cServico) $ oModelUH4:GetValue("UH4_PRODUT"))
						lConsulta := .F.
					endif
					
					if !Empty(cDescricao) .And. !(Alltrim(cDescricao) $ oModelUH4:GetValue("UH4_DESCRI"))
						lConsulta := .F.
					endif
					
					if lConsulta
					
						nItem++ 
						
						aFieldFill := {}
						
						cItem := StrZero(nItem,3)
						
						aadd(aFieldFill, cItem)
						aadd(aFieldFill, oModelUH4:GetValue("UH4_PRODUT"))
						aadd(aFieldFill, oModelUH4:GetValue("UH4_DESCRI"))
						aadd(aFieldFill, oModelUH4:GetValue("UH4_CTRSLD"))
						aadd(aFieldFill, oModelUH4:GetValue("UH4_VLRUNI"))
					
						Aadd(aFieldFill, .F.)
						aadd(oGrid:Acols,aFieldFill) 
						
						lRet 		:= .T.
						
					endif
					
					lConsulta := .T.
				
				endif
				
			Next nX
	
		endif
	
	else
	
		//verifico a se a rotina foi chamado da personalizacao do plano
		cCodTab := if( Alltrim(oModel:cSource) == "RFUNE029" ,M->UH2_TABPRE,M->UF2_TABPRE)
	
		// verifico se não existe este alias criado
		If Select("QRY") > 0
			QRY->(DbCloseArea())
		EndIf
	
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
		cQry += " AND PRODUTOS.B1_FILIAL = '" + xFilial("SB1") + "'  "
		cQry += " AND ITENSTAB.DA1_FILIAL = '" + xFilial("DA1") + "' "
		cQry += " AND PRODUTOS.B1_COD = ITENSTAB.DA1_CODPRO "
		cQry += " INNER JOIN  "
		cQry += RetSQLName("DA0") + " TABELA (NOLOCK) "
		cQry += " ON TABELA.D_E_L_E_T_ = ' '  "
		cQry += " AND ITENSTAB.DA1_FILIAL = TABELA.DA0_FILIAL "
		cQry += " AND ITENSTAB.DA1_CODTAB = TABELA.DA0_CODTAB "
		cQry += " WHERE  "
		cQry += " PRODUTOS.B1_MSBLQL <> '1' "
		cQry += " AND (TABELA.DA0_DATATE = ' ' OR TABELA.DA0_DATATE >= '" + DTOS(dDatabase) + "' ) "
		cQry += " AND TABELA.DA0_ATIVO <> '2' "
		cQry += " AND TABELA.DA0_CODTAB = '" + cCodTab + "' "
	
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

	// verifico se não existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	RestArea(aAreaUF2)
	RestArea(aArea)	

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

Static Function SelServico(oDlg,oGrid)

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

/*/{Protheus.doc} VldProdFun
Funcao para validar o produto digitado
@type function
@version 1.0
@author Raphael Martins
@since 13/08/2018
@return logical, retorno da validacao do campo
/*/
User Function VldProdFun()

	Local aArea			:= GetArea()
	Local aAreaSB1		:= SB1->(GetArea())
	Local aAreaUF3		:= UF3->(GetArea())
	Local oView			:= FWViewActive()
	Local oModel		:= FWModelActive()
	Local oModelUF3		:= oModel:GetModel("UF3DETAIL")
	Local oModelUF2		:= oModel:GetModel("UF2MASTER")
	Local oModelUF4		:= oModel:GetModel("UF4DETAIL")
	Local oModelUK2		:= Nil
	Local cProduto		:= oModelUF3:GetValue("UF3_PROD")
	Local cRegra		:= oModelUF2:GetValue("UF2_REGRA")
	Local cPlano		:= oModelUF2:GetValue("UF2_PLANO")
	Local cContr		:= oModelUF2:GetValue("UF2_CODIGO")
	Local cTabPreco		:= ""
	Local cTipo			:= ""
	Local cIconProdAv	:= "AVGBOX1.PNG"
	Local lRet			:= .T.
	Local lPlanoPet		:= SuperGetMV("MV_XPLNPET", .F., .F.) // habilito o uso do plano pet
	Local nX			:= 1
	Local nValServ		:= 0
	Local nValProd		:= 0
	Local nVlrLiq		:= 0

	Local aCarencia	:= {}

	//realizo as validacoes da grid de itens quando nao for executado pela rotina de confirmacao de personalizacao de planos
	if !IsInCallStack("U_PFUNE029" ) .And. !IsInCallStack("U_RIMPF005" )

		//valido se o produto existe no cadastro de produtos
		SB1->(DBSetOrder(1)) //B1_FILIAL + B1_COD

		if !Empty(cProduto)

			cTabPreco := if(IsInCallStack("U_RFUNE029"),M->UH2_TABPRE,M->UF2_TABPRE)

			if SB1->(MsSeek(xFilial("SB1")+cProduto))

				if ( nPreco := RetPrecoVenda(cTabPreco,cProduto) ) > 0

					UF1->(DbSetOrder(2)) //UF1_FILIAL+UF1_CODIGO+UF1_PRODUT

					if UF1->(MsSeek(xFilial("UF1")+cPlano+cProduto))

						oModelUF3:LoadValue("UF3_TIPO"	, "AVGBOX1.PNG" )
						oModelUF3:LoadValue("UF3_QUANT"	, UF1->UF1_QUANT )
						oModelUF3:LoadValue("UF3_SALDO"	, UF1->UF1_QUANT )
						oModelUF3:LoadValue("UF3_VLRTOT", nPreco * UF1->UF1_QUANT)

					else

						oModelUF3:LoadValue("UF3_TIPO"	, "ADDITENS.PNG" )
						oModelUF3:LoadValue("UF3_QUANT"	, 1 )
						oModelUF3:LoadValue("UF3_SALDO"	, 1 )
						oModelUF3:LoadValue("UF3_VLRTOT"	, nPreco)

					endif

					oModelUF3:LoadValue("UF3_DESC"		, SB1->B1_DESC )
					oModelUF3:LoadValue("UF3_VLRUNI"	, nPreco)
					oModelUF3:LoadValue("UF3_CTRSLD"	, If(!Empty(SB1->B1_XDEBPRE),SB1->B1_XDEBPRE,'N'))

					//Valido se o produto é personalizado ou seja nao pertence ao plano
					if 	Alltrim(oModelUF3:GetValue("UF3_TIPO")) == "AVGBOX1.PNG"
						cTipo := ""
					else
						cTipo := "P/T"

						//Se for personalizacao verifica carencia do produto
						aCarencia := U_RetCaren(cContr,cRegra,dDataBase,cTipo,,,cProduto)
					endif

					If Len(aCarencia) == 2
						oModelUF3:LoadValue("UF3_CARENC"	, aCarencia[1] )
						oModelUF3:LoadValue("UF3_ITREGC"	, aCarencia[2] )
					Endif

					// percorro o grid de produtos
					For nX := 1 To oModelUF3:Length()

						oModelUF3:GoLine(nX)

						if !oModelUF3:IsDeleted()

							// serviços avulsos
							if AllTrim(oModelUF3:GetValue( "UF3_TIPO" )) <> cIconProdAv
								nValServ += oModelUF3:GetValue( "UF3_VLRTOT" )
							else
								nValProd += oModelUF3:GetValue( "UF3_VLRTOT" )
							endif

						endif

					Next nX

					// Valor Liquido do Contrato
					nVlrLiq := ( nValProd + nValServ + oModelUF2:GetValue("UF2_VLCOB") ) - oModelUF2:GetValue("UF2_DESCON")

					oModelUF2:LoadValue("UF2_VALOR"		, nVlrLiq )
					oModelUF2:LoadValue("UF2_VLRBRU"	, nValProd )
					oModelUF2:LoadValue("UF2_VLSERV"	, nValServ )

					// casoo o plano estiver habilitado
					if lPlanoPet

						// preencho o uso do produto 
						oModelUF3:LoadValue("UF3_USOSRV", SB1->B1_XUSOSRV ) 

						// para contratos sem uso defindo ou humano || ou para servico ambos e pet
						if oModelUF2:GetValue("UF2_USO") $ " |2" .Or. SB1->B1_XUSOSRV $ "1|3"

							oModelUK2 := oModel:GetModel("UK2DETAIL")

							if SB1->B1_XUSOSRV $ "1|3" // para ambos e pet

								oModelUK2:SetNoInsertLine(.F.)
								oModelUK2:SetNoUpdateLine(.F.)
								oModelUK2:SetNoDeleteLine(.F.)

								if SB1->B1_XUSOSRV $ "1"

									oModelUF4:SetNoInsertLine(.F.)
									oModelUF4:SetNoUpdateLine(.F.)
									oModelUF4:SetNoDeleteLine(.F.)

									// incluo o titular como beneficiario
									U_IncTitBen(oModelUF2:GetValue("UF2_CLIENT"), oModelUF2:GetValue("UF2_LOJA"))

								endIf
															
							else

								oModelUK2:SetNoInsertLine(.T.)
								oModelUK2:SetNoUpdateLine(.T.)
								oModelUK2:SetNoDeleteLine(.T.)

							endIf

							// altero o uso do contrato para ambos
							if oModelUF2:GetValue("UF2_USO") $ " |2" 
								oModelUF2:LoadValue("UF2_USO", "1")
							endIf

						endIf

					endIf

				else

					lRet := .F.

				endif

			else

				lRet := .F.
				Help(,,'Help',,"Produto não encontrado no cadastro de produtos!",1,0)

			endif

		else

			oModelUF3:LoadValue("UF3_TIPO"		, "" )
			oModelUF3:LoadValue("UF3_QUANT"		, 0	 )
			oModelUF3:LoadValue("UF3_SALDO"		, 0  )
			oModelUF3:LoadValue("UF3_VLRTOT"	, 0  )
			oModelUF3:LoadValue("UF3_DESC"		, "" )
			oModelUF3:LoadValue("UF3_VLRUNI"	, 0  )
			oModelUF3:LoadValue("UF3_CTRSLD"	, "" )
			oModelUF3:LoadValue("UF3_CARENC"	, CToD("") )

		endif
		
		//reprocesso valor do contrato
		U_UVlrLiqFun()

	endif

	RestArea(aAreaSB1)
	RestArea(aAreaUF3)
	RestArea(aArea)

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

