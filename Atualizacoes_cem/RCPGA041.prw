#include "totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} RCPGA041
rotina para gerar a taxa de locacao para nicho crematorio e ossario
@type function
@version 
@author g.sampaio
@since 28/02/2020
@return Nil
/*/
User Function RCPGA041()

	Local aObjects 			:= {}
	Local aSizeAut	   		:= MsAdvSize()
	Local aObjects			:= {}
	Local aPosObj			:= {}
	Local aCords			:= {}
	Local cTrbContrato		:= ""
	Local cTrbParcelas		:= ""
	Local cGet1				:= Space( TamSX3("U00_CODIGO")[1] )
	Local cGet2				:= Space( TamSX3("U00_CODIGO")[1] )
	Local cGet3             := Space(70)
	Local cGet4             := Space(3)
	Local cLog				:= ""
	Local dGet1             := Stod("")
	Local dGet2             := Stod("")
	Local lRet				:= .F.
	Local nX				:= 0
	Local nComboBo1			:= 0
	Local nComboBo2			:= 0
	Local nComboBo3			:= 0
	Local nTotReaj          := 0
	Local nTotLocacao       := 0
	Local oPanelCab			:= NIL
	Local oPanelRod			:= NIL
	Local oPanelFiltro		:= NIL
	Local oPanelTipo		:= NIL
	Local oPanelDetalhes	:= NIL
	Local oBrowseContrato	:= NIL
	Local oBrowseParcelas	:= NIL
	Local oRelac			:= NIL
	Local oDlg				:= NIL
	Local oBut1				:= NIL
	Local oBut2				:= NIL
	Local oBut3				:= NIL
	Local oBut4				:= NIL
	Local oGroupCab			:= NIL
	Local oGroupRod			:= NIL
	Local oGroupFiltro		:= NIL
	Local oSay              := NIL
	Local oSay1				:= NIL
	Local oSay2				:= NIL
	Local oSay3				:= NIL
	Local oSay4				:= NIL
	Local oSay5             := Nil
	Local oSay6             := Nil
	Local oSay7             := Nil
	Local oSay8             := Nil
	Local oSay9             := Nil
	Local oSay10            := Nil
	Local oGet1				:= NIL
	Local oGet2				:= NIL
	Local oGet3				:= NIL
	Local oGet4				:= NIL
	Local oComboBo1 		:= NIL	
	Local oComboBo3 		:= NIL
	Local oTempContrato		:= NIL
	Local oTempParcelas		:= Nil
	Local oTotLocacao       := Nil
	Local oTotReajust       := Nil

	// Largura, Altura, Modifica largura, Modifica altura
	Aadd( aObjects, { 100,	100, .T., .T. } ) // PANEL COM AS ABAS

	aInfo  	:= { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 2, 2 }
	aPosObj := MsObjSize( aInfo, aObjects, .T. , .T.)

	// {linha inicial,coluna inicial,largura,altura}
	Aadd(aCords,{000						,	000																	, (aSizeAut[5] / 2) + 3																								,	020}) // Panel Cabeçalho
	Aadd(aCords,{( aSizeAut[6] / 2 ) - 25	,	000																	, (aSizeAut[5] / 2) + 3																								,	025}) // Panel Rodapé
	Aadd(aCords,{000						,	000																	, ( (aSizeAut[6] / 2) - (aCords[1,4] + aCords[2,4]) - 5 ) * 0.5														,	aSizeAut[4] }) // Panel Serviços Disponíveis
	Aadd(aCords,{aCords[1,4]				,	( (aSizeAut[6] / 2) - (aCords[1,4] + aCords[2,4]) ) * 0.5			, ( (aSizeAut[5] / 2) - aCords[3,3] + aSizeAut[4] + ( aSizeAut[2] * 7 ) + (aCords[1,4] + aCords[2,4]) ) * 0.5 		,	( (aSizeAut[6] / 2) - (aCords[1,4] + aCords[2,4]) ) * 0.5}) // Panel Serviços Disponíveis
	Aadd(aCords,{aCords[4,1] + aCords[4,4]	,	aCords[4,2]															, aCords[4,3] 																										,	aCords[4,4]}) // Panel Serviços Disponíveis

	DEFINE MSDIALOG oDlg TITLE "Controle de Financeiro - Nicho e Ossario" FROM aSizeAut[7], 0 TO aSizeAut[6], aSizeAut[5] COLORS 0, 16777215 PIXEL // STYLE DS_MODALFRAME

	@ aCords[1,1], aCords[1,2] MSPANEL oPanelCab 			PROMPT "" SIZE aCords[1,3], aCords[1,4] OF oDlg COLORS 0, 16777215

	@ aCords[2,1], aCords[2,2] MSPANEL oPanelRod 			PROMPT "" SIZE aCords[2,3], aCords[2,4] OF oDlg COLORS 0, 16777215

	@ aCords[3,1], aCords[3,2] MSPANEL oPanelFiltro 		PROMPT "" SIZE aCords[3,3], aCords[3,4] OF oDlg COLORS 0, 16777215

	@ aCords[4,1], aCords[4,2] MSPANEL oPanelTipo	 		PROMPT "" SIZE aCords[4,3], aCords[4,4] OF oDlg COLORS 0, 16777215

	@ aCords[5,1], aCords[5,2] MSPANEL oPanelDetalhes 		PROMPT "" SIZE aCords[5,3], aCords[5,4] OF oDlg COLORS 0, 16777215

	@ 013, 005 GROUP oGroupCab TO 014, aCords[1,3] - 5 		PROMPT "" OF oPanelCab COLOR 0, 16777215 PIXEL

	// tela de filtros
	@ 013, 005 GROUP oGroupFiltro TO aCords[3,4] , aCords[3,3] - 5	PROMPT "" OF oPanelFiltro COLOR 0, 16777215 PIXEL

	@ 020, 010 SAY oSay1 	PROMPT "Contrato de ?" 		                SIZE 100, 007 OF oPanelFiltro COLORS 0, 16777215 PIXEL
	@ 050, 010 SAY oSay2 	PROMPT "Contrato ate ?" 	                SIZE 100, 007 OF oPanelFiltro COLORS 0, 16777215 PIXEL
	@ 080, 010 SAY oSay3	PROMPT "Plano ?"	 		                SIZE 100, 007 OF oPanelFiltro COLORS 0, 16777215 PIXEL
	@ 110, 010 SAY oSay4	PROMPT "Indice ?" 		                    SIZE 100, 007 OF oPanelFiltro COLORS 0, 16777215 PIXEL
	@ 140, 010 SAY oSay5 	PROMPT "Para ?" 			                SIZE 100, 007 OF oPanelFiltro COLORS 0, 16777215 PIXEL
	@ 170, 010 SAY oSay6 	PROMPT "Considera Dt.Locacao ?" 		    SIZE 100, 007 OF oPanelFiltro COLORS 0, 16777215 PIXEL
	@ 200, 010 SAY oSay6 	PROMPT "Data De ?" 		                    SIZE 100, 007 OF oPanelFiltro COLORS 0, 16777215 PIXEL
	@ 230, 010 SAY oSay7 	PROMPT "Data Ate ?" 		                SIZE 100, 007 OF oPanelFiltro COLORS 0, 16777215 PIXEL
	
	// preenche os campos automaticos
	cGet1   := Space( TamSX3("U00_CODIGO")[1] )
	cGet2   := Replicate( "Z", TamSX3("U00_CODIGO")[1] )

	@ 029, 009 MSGET oGet1 VAR cGet1 F3 "U00"       PICTURE "@!" 		SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON
	@ 059, 009 MSGET oGet2 VAR cGet2 F3 "U00"       PICTURE "@!" 		SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON
	@ 089, 009 MSGET oGet3 VAR cGet3 F3 "U05MRK"    PICTURE "@!" 		SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON
	@ 119, 009 MSGET oGet4 VAR cGet4 F3 "U22"       PICTURE "@!" 		SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON
	@ 149, 009 MSCOMBOBOX oComboBo1 VAR nComboBo1 	ITEMS {"Ambos","Crematório","Ossário"} SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 179, 009 MSCOMBOBOX oComboBo3 VAR nComboBo3 	ITEMS {"Sim","Não"} SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 209, 009 MSGET oGet5 VAR dGet1                PICTURE "@D" 		SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON
	@ 239, 009 MSGET oGet6 VAR dGet2                PICTURE "@D" 		SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON

	// preenche os campos automaticos
	oComboBo1:nAt	:= 1	
	oComboBo3:nAt	:= 2

	@ 290, 010 BUTTON oBut3 PROMPT "Processar" 		SIZE 041, 012 OF oDlg PIXEL ACTION ProcessRegistros( cGet1, cGet2, cGet3, cGet4, oComboBo1:nAt, dGet1, dGet2, oComboBo3:nAt, @cLog, cTrbContrato, cTrbParcelas,;
		@oTempContrato, @oTempParcelas, @oBrowseContrato, @oBrowseParcelas, @nTotLocacao, @oTotLocacao, @nTotReaj, @oTotReajust )

	@ 002, 005 GROUP oGroupRod TO 003 , aCords[2,3] - 5 	PROMPT "" OF oPanelRod COLOR 0, 16777215 PIXEL

	@ 009, (aCords[2,3] - 350) SAY oSay8 	        PROMPT "Qnt.Locação" 		    SIZE 050, 007 OF oPanelRod COLORS 0, 16777215 PIXEL
	@ 008, (aCords[2,3] - 250) MSGET oTotLocacao 	VAR nTotLocacao 		        WHEN .F. SIZE 050, 010 OF oPanelRod COLORS 0, 16777215 PIXEL HASBUTTON

	@ 009, (aCords[2,3] - 750) SAY oSay9 	        PROMPT "Qnt.Reaj.Locação" 		SIZE 050, 007 OF oPanelRod COLORS 0, 16777215 PIXEL
	@ 008, (aCords[2,3] - 650) MSGET oTotReajust 	VAR nTotReaj 		            WHEN .F. SIZE 050, 010 OF oPanelRod COLORS 0, 16777215 PIXEL HASBUTTON

	@ 007, (aCords[2,3] - 55) 	BUTTON oBut1 PROMPT "Confirmar" SIZE 050, 015 OF oPanelRod PIXEL ACTION (lRet := .T., ConfirmarTela( cGet1, cGet2, cGet3, cGet4, oComboBo1:nAt, dGet1, dGet2, oComboBo3:nAt, @cLog, cTrbContrato, cTrbParcelas,;
		@oTempContrato, @oTempParcelas, @oBrowseContrato, @oBrowseParcelas, @oDlg ) )

	@ 007, (aCords[2,3] - 110)	BUTTON oBut2 PROMPT "Cancelar" SIZE 050, 015 OF oPanelRod PIXEL ACTION (lRet := .F.,oDlg:End())

	// monto o grid de contratos
	ContratoGrid( oPanelTipo, @cTrbContrato, @oBrowseContrato, @oBrowseParcelas, @oTempContrato, @nTotLocacao, @oTotLocacao, @nTotReaj, @oTotReajust )

	// monto o grid de parcelas
	ParcelasGrid( oPanelDetalhes, @cTrbParcelas, @oBrowseParcelas, @oBrowseContrato, @oTempParcelas )

	oRelac := FWBrwRelation():New()
	oRelac:AddRelation( oBrowseContrato , oBrowseParcelas , { { 'TMP_CODIGO', 'TR_CODIGO' } } )
	oRelac:Activate()

	ACTIVATE MSDIALOG oDlg CENTERED

	// verifico se o objeto do alias temproario de contratos no banco
	If ValType( oTempContrato ) == "O"
		oTempContrato:Delete()
	EndIf

	// verifico se o objeto do alias temproario de parcelas no banco
	If ValType( oTempParcelas ) == "O"
		oTempParcelas:Delete()
	EndIf

Return( Nil )

/*/{Protheus.doc} ContratoGrid
description
@type function
@version 
@author g.sampaio
@since 28/02/2020
@param oPanel, object, param_description
@param cArqTrb, character, param_description
@param aIndContrato, array, param_description
@param oBrowse, object, param_description
@param oBrowseRelac, object, param_description
@param oTempContrato, object, param_description
@return return_type, return_description
/*/
Static Function ContratoGrid( oPanel, cArqTrb, oBrowse, oBrowseRelac, oTempContrato, nTotLocacao, oTotLocacao, nTotReaj, oTotReajust )

	Local aSeek 				:= {}
	Local cCadastro 			:= "Contratos:"
	Local oTR_TXLOCNColumn		:= Nil
	Local oTR_INDICColumn		:= Nil
	Local oTR_CLIENTEColumn		:= Nil
	Local oTR_CODCLIColumn		:= Nil
	Local oTR_LOJCLIColumn		:= Nil
	Local oTR_CODIGOColumn	    := Nil
	Local oTR_CONTRATColumn	    := Nil
	Local oTR_DIAVENCColumn		:= Nil
	Local oTR_STATUSColumn      := Nil
	Local oTR_TXINDIolumn       := Nil
	Local oTR_VLADICColumn      := Nil

	Default cArqTrb			    := ""
	Default nTotLocacao         := 0
	Default nTotReaj            := 0

	// defino o nome do arquivo de trabalho
	If Empty(cArqTrb)
		cArqTrb := "TRBCTR"
	EndIf

	// crio a estrutura do alias de contrato
	U_RCPGA41A( cArqTrb, @oTempContrato )

	///////////////////////////////////////////////////////////////////////////
	////////////////// 		      CRIO O GRID		     //////////////////////
	///////////////////////////////////////////////////////////////////////////
	oBrowse := FWBrowse():New(oPanel)
	oBrowse:SetDataTable(.T.)
	oBrowse:SetAlias( cArqTrb )
	oBrowse:SetDescription( cCadastro )

	// Desabilito a opção de impressão
	oBrowse:DisableReport()

	// Desabilito a opção de Salvar Configuração
	oBrowse:DisableSaveConfig()

	// Desabilito a opção de Configuração
	oBrowse:DisableConfig()

	// Adiciono o MARK
	oBrowse:AddMarkColumns({||Iif((cArqTrb)->TR_MARK,'CHECKED','UNCHECKED')},{|oBrowse| DbClickDisp( oBrowse, cArqTrb, .F., @nTotLocacao, @oTotLocacao, @nTotReaj, @oTotReajust )},;
		{|oBrowse| FWMsgRun(,{|oSay| HdClickDisp( oBrowse, cArqTrb, @nTotLocacao, @oTotLocacao, @nTotReaj, @oTotReajust ) },'Aguarde...','Marcando ou desmarcando todos os registros...') })

	// status da locacao
	oTR_STATUSColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_STATUSColumn:SetData( { || TR_STATUS } )	// campo referente a coluna
	oTR_STATUSColumn:SetTitle("Status")			    // titulo da coluna
	oTR_STATUSColumn:SetSize(5)						// tamanho da coluna
	oTR_STATUSColumn:SetPicture("@!")				// mascara da coluna
	oBrowse:SetColumns({oTR_STATUSColumn})			// adiciono o objeto da coluna no browse

	// Coluna de locacao
	oTR_CODIGOColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_CODIGOColumn:SetData( { || TR_CODIGO } )	// campo referente a coluna
	oTR_CODIGOColumn:SetTitle("Codigo")			    // titulo da coluna
	oTR_CODIGOColumn:SetSize(5)						// tamanho da coluna
	oTR_CODIGOColumn:SetPicture("@!")				// mascara da coluna
	oBrowse:SetColumns({oTR_CODIGOColumn})			// adiciono o objeto da coluna no browse

	// Coluna de contrato
	oTR_CONTRATColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_CONTRATColumn:SetData( { || TR_CONTRAT } )    // campo referente a coluna
	oTR_CONTRATColumn:SetTitle("Contrato")				// titulo da coluna
	oTR_CONTRATColumn:SetSize(5)						// tamanho da coluna
	oTR_CONTRATColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTR_CONTRATColumn})			// adiciono o objeto da coluna no browse

	// Coluna de codigo do cliente
	oTR_CODCLIColumn := FWBrwColumn():New()			    // instancio da classe do objeto
	oTR_CODCLIColumn:SetData( { || TR_CODCLI } )		// campo referente a coluna
	oTR_CODCLIColumn:SetTitle("Cod.Cliente")			// titulo da coluna
	oTR_CODCLIColumn:SetSize(5)						// tamanho da coluna
	oTR_CODCLIColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTR_CODCLIColumn})			    // adiciono o objeto da coluna no browse

	// Coluna de loja do cliente
	oTR_LOJCLIColumn := FWBrwColumn():New()			    // instancio da classe do objeto
	oTR_LOJCLIColumn:SetData( { || TR_LOJCLI } )		// campo referente a coluna
	oTR_LOJCLIColumn:SetTitle("Loj.Cliente")			// titulo da coluna
	oTR_LOJCLIColumn:SetSize(2)						// tamanho da coluna
	oTR_LOJCLIColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTR_LOJCLIColumn})			    // adiciono o objeto da coluna no browse

	// Coluna de nome do cliente
	oTR_CLIENTEColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_CLIENTEColumn:SetData( { || TR_CLIENTE } )		// campo referente a coluna
	oTR_CLIENTEColumn:SetTitle("Nome Cliente")			// titulo da coluna
	oTR_CLIENTEColumn:SetSize(30)						// tamanho da coluna
	oTR_CLIENTEColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTR_CLIENTEColumn})				// adiciono o objeto da coluna no browse

	// Coluna de tipo de enderecamento
	oTR_TIPOENDColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_TIPOENDColumn:SetData( { || TR_TIPOEND } )		// campo referente a coluna
	oTR_TIPOENDColumn:SetTitle("Tipo Enderecamento")	// titulo da coluna
	oTR_TIPOENDColumn:SetSize(5)						// tamanho da coluna
	oTR_TIPOENDColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTR_TIPOENDColumn})				// adiciono o objeto da coluna no browse

	// Coluna de tipo de enderecamento
	oTR_CREMOSColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_CREMOSColumn:SetData( { || TR_CREMOS } )		// campo referente a coluna
	oTR_CREMOSColumn:SetTitle("Crematorio/Ossuario")	// titulo da coluna
	oTR_CREMOSColumn:SetSize(5)						// tamanho da coluna
	oTR_CREMOSColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTR_CREMOSColumn})				// adiciono o objeto da coluna no browse

	// Coluna de tipo de enderecamento
	oTR_NICHOColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_NICHOColumn:SetData( { || TR_NICHO } )		// campo referente a coluna
	oTR_NICHOColumn:SetTitle("End.Nicho")	// titulo da coluna
	oTR_NICHOColumn:SetSize(5)						// tamanho da coluna
	oTR_NICHOColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTR_NICHOColumn})				// adiciono o objeto da coluna no browse

	// Coluna de diavenc
	oTR_DIAVENCColumn := FWBrwColumn():New()		    // instancio da classe do objeto
	oTR_DIAVENCColumn:SetData( { || TR_DIAVENC } )		// campo referente a coluna
	oTR_DIAVENCColumn:SetTitle("Dia Venc.")				// titulo da coluna
	oTR_DIAVENCColumn:SetSize(5)						// tamanho da coluna
	oTR_DIAVENCColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTR_DIAVENCColumn})				// adiciono o objeto da coluna no browse

	// Coluna de Indice
	oTR_INDICColumn := FWBrwColumn():New()				// instancio da classe do objeto
	oTR_INDICColumn:SetData( { || TR_INDIC } )		// campo referente a coluna
	oTR_INDICColumn:SetTitle("Indice")					// titulo da coluna
	oTR_INDICColumn:SetSize(5)						// tamanho da coluna
	oTR_INDICColumn:SetPicture("@!")	// mascara da coluna
	oBrowse:SetColumns({oTR_INDICColumn})				// adiciono o objeto da coluna no browse

	// Coluna de Indice
	oTR_TXINDIolumn := FWBrwColumn():New()				// instancio da classe do objeto
	oTR_TXINDIolumn:SetData( { || TR_TXINDI } )		// campo referente a coluna
	oTR_TXINDIolumn:SetTitle("Tx Indice")					// titulo da coluna
	oTR_TXINDIolumn:SetSize(5)						// tamanho da coluna
	oTR_TXINDIolumn:SetPicture("@E 99.99")	// mascara da coluna
	oBrowse:SetColumns({oTR_TXINDIolumn})				// adiciono o objeto da coluna no browse

	// Coluna de Indice
	oTR_VLADICColumn := FWBrwColumn():New()				// instancio da classe do objeto
	oTR_VLADICColumn:SetData( { || TR_VLADIC } )		// campo referente a coluna
	oTR_VLADICColumn:SetTitle("Vlr.Adicional")					// titulo da coluna
	oTR_VLADICColumn:SetSize(5)						// tamanho da coluna
	oTR_VLADICColumn:SetPicture("@E 999,999,999.99")	// mascara da coluna
	oBrowse:SetColumns({oTR_VLADICColumn})				// adiciono o objeto da coluna no browse

	// Coluna de taxa atual
	oTR_TXLOCNColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_TXLOCNColumn:SetData( { || TR_TXLOCN } )		// campo referente a coluna
	oTR_TXLOCNColumn:SetTitle("Taxa Locacao")			// titulo da coluna
	oTR_TXLOCNColumn:SetSize(5)						// tamanho da coluna
	oTR_TXLOCNColumn:SetPicture("@E 999,999,999.99")	// mascara da coluna
	oBrowse:SetColumns({oTR_TXLOCNColumn})				// adiciono o objeto da coluna no browse

	oBrowse:SetClrAlterRow(128128128)

	// edicao da celula
	oBrowse:SetEditCell(.T., { || ValidCell() } )

	oBrowse:Activate()

Return( Nil )

/*/{Protheus.doc} ParcelasGrid
description
@type function
@version 
@author g.sampaio
@since 01/03/2020
@param oPanel, object, param_description
@param cArqTrb, character, param_description
@param aIndiceDetalhes, array, param_description
@param oBrowse, object, param_description
@param oBrowseRelac, object, param_description
@param oTempParcelas, object, param_description
@return return_type, return_description
/*/
Static Function ParcelasGrid( oPanel, cArqTrb, oBrowse, oBrowseRelac, oTempParcelas )

	Local aSeek 			:= {}
	Local cCadastro 		:= "Parcelas:"
	Local oTMP_CODIGOColumn := Nil
	Local oTMP_NUMColumn	:= Nil
	Local oTMP_PARCELColumn	:= Nil
	Local oTMP_VALORColumn	:= Nil
	Local oTMP_PREFColumn	:= Nil
	Local oTMP_TIPOColumn	:= Nil
	Local oTMP_VENCTOColumn	:= Nil
	Local oTMP_NATUREColumn := Nil

	Default cArqTrb			:= ""

	// defino o nome do arquivo de trabalho
	If Empty(cArqTrb)
		cArqTrb := "TRBFIN"
	EndIf

	// gero arquivo temporario para as parcelas
	U_RCPGA41B( cArqTrb, @oTempParcelas )

	///////////////////////////////////////////////////////////////////////////
	////////////////// 		      CRIO O GRID		     //////////////////////
	///////////////////////////////////////////////////////////////////////////
	oBrowse := FWBrowse():New(oPanel)
	oBrowse:SetDataTable(.T.)
	oBrowse:SetAlias( cArqTrb )
	oBrowse:SetDescription( cCadastro )

	// Desabilito a opção de impressão
	oBrowse:DisableReport()

	// Desabilito a opção de Salvar Configuração
	oBrowse:DisableSaveConfig()

	// Desabilito a opção de Configuração
	oBrowse:DisableConfig()

	// Coluna de Prefixo
	oTMP_CODIGOColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTMP_CODIGOColumn:SetData( { || TMP_CODIGO } )	// campo referente a coluna
	oTMP_CODIGOColumn:SetTitle("Codigo")				// titulo da coluna
	oTMP_CODIGOColumn:SetSize(10)					// tamanho da coluna
	oTMP_CODIGOColumn:SetPicture("@!")				// mascara da coluna
	oBrowse:SetColumns({oTMP_CODIGOColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Prefixo
	oTMP_PREFColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTMP_PREFColumn:SetData( { || TMP_PREF } )	// campo referente a coluna
	oTMP_PREFColumn:SetTitle("Prefixo")				// titulo da coluna
	oTMP_PREFColumn:SetSize(10)					// tamanho da coluna
	oTMP_PREFColumn:SetPicture("@!")				// mascara da coluna
	oBrowse:SetColumns({oTMP_PREFColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Numero
	oTMP_NUMColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTMP_NUMColumn:SetData( { || TMP_NUM } )	// campo referente a coluna
	oTMP_NUMColumn:SetTitle("Numero")			// titulo da coluna
	oTMP_NUMColumn:SetSize(10)						// tamanho da coluna
	oTMP_NUMColumn:SetPicture("@!")				// mascara da coluna
	oBrowse:SetColumns({oTMP_NUMColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Data de Comissao
	oTMP_PARCELColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTMP_PARCELColumn:SetData( { || TMP_PARCEL } )	// campo referente a coluna
	oTMP_PARCELColumn:SetTitle("Parcela")		// titulo da coluna
	oTMP_PARCELColumn:SetSize(5)						// tamanho da coluna
	oTMP_PARCELColumn:SetPicture("@D")				// mascara da coluna
	oBrowse:SetColumns({oTMP_PARCELColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Vendedor
	oTMP_TIPOColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTMP_TIPOColumn:SetData( { || TMP_TIPO } )		// campo referente a coluna
	oTMP_TIPOColumn:SetTitle("Tipo")				// titulo da coluna
	oTMP_TIPOColumn:SetSize(5)						// tamanho da coluna
	oTMP_TIPOColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTMP_TIPOColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Vendedor
	oTMP_NATUREColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTMP_NATUREColumn:SetData( { || TMP_NATURE } )		// campo referente a coluna
	oTMP_NATUREColumn:SetTitle("Tipo")				// titulo da coluna
	oTMP_NATUREColumn:SetSize(5)						// tamanho da coluna
	oTMP_NATUREColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTMP_NATUREColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Nome do Vendedor
	oTMP_VALORColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTMP_VALORColumn:SetData( { || TMP_VALOR } )		// campo referente a coluna
	oTMP_VALORColumn:SetTitle("Valor")					// titulo da coluna
	oTMP_VALORColumn:SetSize(30)						// tamanho da coluna
	oTMP_VALORColumn:SetPicture(PesqPict("SE1","E1_VALOR"))					// mascara da coluna
	oBrowse:SetColumns({oTMP_VALORColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Nome do Vendedor
	oTMP_VENCTOColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTMP_VENCTOColumn:SetData( { || TMP_VENCTO} )		// campo referente a coluna
	oTMP_VENCTOColumn:SetTitle("Dt.Vencto")					// titulo da coluna
	oTMP_VENCTOColumn:SetSize(30)						// tamanho da coluna
	oTMP_VENCTOColumn:SetPicture("@D")					// mascara da coluna
	oBrowse:SetColumns({oTMP_VENCTOColumn})			// adiciono o objeto da coluna no browse

	oBrowse:SetClrAlterRow(128128128)

	// edicao da celula
	oBrowse:SetEditCell(.T., { || ValidCell() } )

	oBrowse:Activate()

Return( Nil )

/*/{Protheus.doc} DbClickDisp
funcao para duplo clique
@type function
@version 
@author g.sampaio
@since 28/02/2020
@param oBrowse, object, param_description
@param aRegr, param_type, param_description
@param aRegr, param_type, param_description
@param aRegraGrp, array, param_description
@return return_type, return_description
/*/

Static Function DbClickDisp( oBrowse, cArqTrb, lTodos, nTotLocacao, oTotLocacao, nTotReaj, oTotReajust )

	Default cArqTrb         := ""
	Default lTodos          := .F.
	Default nTotLocacao     := 0
	Default nTotReaj        := 0

	// vejo se o alias esta preenchido
	If !Empty( cArqTrb )

		BEGIN TRANSACTION

			// atualizo o registro atual
			if (cArqTrb)->(RecLock( cArqTrb,.F.))
				(cArqTrb)->TR_MARK := iif( (cArqTrb)->TR_MARK, .F., .T. )
				(cArqTrb)->(MsUnLock())
			endif

		END TRANSACTION

		if (cArqTrb)->TR_MARK .And. SubStr((cArqTrb)->TR_STATUS,1,1) == "N"
			nTotLocacao++
		elseif !(cArqTrb)->TR_MARK .And. SubStr((cArqTrb)->TR_STATUS,1,1) == "N" .And. nTotLocacao > 0
			nTotLocacao--
		elseif (cArqTrb)->TR_MARK .And. SubStr((cArqTrb)->TR_STATUS,1,1) == "R"
			nTotReaj++
		elseif !(cArqTrb)->TR_MARK .And. SubStr((cArqTrb)->TR_STATUS,1,1) == "R" .And. nTotReaj > 0
			nTotReaj--
		endIf

		// verifico se estou marcando todos
		if !lTodos

			// Atualizo os dados do Browse
			oBrowse:Refresh(.F.)
			oTotLocacao:Refresh()
			oTotReajust:Refresh()

		EndIf

	EndIf

Return( Nil )

/*/{Protheus.doc} HdClickDisp
Função do clique no header da coluna
@type function
@version 
@author g.sampaio
@since 28/02/2020
@param oBrowse, object, param_description
@param aRegr, param_type, param_description
@param aRegr, param_type, param_description
@param aRegraGrp, array, param_description
@return return_type, return_description
/*/
Static Function HdClickDisp( oBrowse, cArqTrb, nTotLocacao, oTotLocacao, nTotReaj, oTotReajust )

	Local nX		        := 1
	Local lMark		        := .T.
	Local lOK		        := .T.

	Default cArqTrb         := ""
	Default nTotLocacao     := 0
	Default nTotReaj        := 0

	// verifico se o alias esta preenchido
	If !Empty(cArqTrb)

		(cArqTrb)->(DbGoTop())
		While (cArqTrb)->(!Eof())

			DbClickDisp( oBrowse, cArqTrb, .T., @nTotLocacao, @oTotLocacao, @nTotReaj, @oTotReajust )

			(cArqTrb)->(DbSkip())
		EndDo

		// posiciono no primeiro registro
		(cArqTrb)->(DbGoTop())

		// Atualizo os dados do Browse
		oBrowse:Refresh(.F.)
		oTotLocacao:Refresh()
		oTotReajust:Refresh()

	EndIf

Return( Nil )

/*/{Protheus.doc} ProcessRegistros
description
@type function
@version 
@author g.sampaio
@since 03/03/2020
@param cDeContrato, character, param_description
@param cAteContrato, character, param_description
@param cPlanos, character, param_description
@param cIndice, character, param_description
@param cLog, character, param_description
@param cTrbContrato, character, param_description
@param cTrbParcelas, character, param_description
@param oBrowseContrato, object, param_description
@param oBrowseParcelas, object, param_description
@return return_type, return_description
/*/
Static Function ProcessRegistros(  cDeContrato, cAteContrato, cPlanos, cIndice, nTipo, dDataDe, dDataAt, nDataLoc, cLog, cTrbContrato, cTrbParcelas,;
		oTempContrato, oTempParcelas, oBrowseContrato, oBrowseParcelas, nTotLocacao, oTotLocacao, nTotReaj, oTotReajust )

	Local aParam        := {}
	Local oProcess      := NIL
	Local lEnd 			:= .F.

	Private lProces

	Default cDeContrato		:= ""
	Default cAteContrato	:= ""
	Default cPlanos		    := ""
	Default cIndice		    := ""
	Default nTipo           := 0
	Default dDataDe         := Stod("")
	Default dDataAte        := Stod("")
	Default nStatus         := 0
	Default nDataLoc        := 0
	Default cLog 		    := ""
	Default cTrbParcelas    := ""
	Default cTrbContrato	:= ""
	Default nTotLocacao     := 0
	Default nTotReaj        := 0

	// preencho o array de parametros
	aAdd( aParam, cDeContrato )
	aAdd( aParam, cAteContrato )
	aAdd( aParam, cPlanos )
	aAdd( aParam, cIndice )
	aAdd( aParam, nTipo )
	aAdd( aParam, dDataDe )
	aAdd( aParam, dDataAt )
	aAdd( aParam, nDataLoc )

	// Faco a validacao dos parametros
	If ValidParam( aParam, @cLog, cTrbContrato, cTrbParcelas, oBrowseContrato, oBrowseParcelas )

        nTotLocacao := 0
        nTotReaj    := 0

		// chamao o processamento de comissoes
		oProcess := MsNewProcess():New({|lEnd| U_RCPGE029( cTrbContrato, cTrbParcelas, aParam, @cLog, @oTempContrato,;
			@oTempParcelas, @oBrowseContrato, @oBrowseParcelas, @oProcess, @lEnd, @nTotLocacao, @nTotReaj, ) },"Processamento dados","Aguarde! Processando...",.T.)

		oTotLocacao:Refresh()
		oTotReajust:Refresh()

		oProcess:Activate()

	EndIf

Return(Nil)

/*/{Protheus.doc} ValidParam
funcao para validacao dos parametros da rotina
@type function
@version 
@author g.sampaio
@since 03/03/2020
@param cVendDe, character, param_description
@param cVendAt, character, param_description
@param dDataDe, date, param_description
@param dDataAt, date, param_description
@param nOpc, numeric, param_description
@param cLog, character, param_description
@param cTrbContrato, character, param_description
@param cTrbParcelas, character, param_description
@param oBrowseContrato, object, param_description
@param oBrowseParcelas, object, param_description
@return return_type, return_description
/*/
Static Function ValidParam( aParam, cLog, cTrbContrato, cTrbParcelas, oBrowseContrato, oBrowseParcelas )

	Local lRetorno 			:= .T.
	Local cDeContrato       := ""
	Local cAteContrato      := ""
	Local cPlanos           := ""
	Local cIndice           := ""
	Local dDataDe           := Stod("")
	Local dDataAt           := Stod("")
	Local nTipo             := 0
	Local nStatus           := 0
	Local nDataLoc          := 0

	Default aParam          := {}
	Default cLog 		    := ""
	Default cTrbContrato    := ""
	Default cTrbParcelas    := ""
	Default cTrbContrato	:= ""

	// verifico se o array de parametros tem dados
	If Len( aParam ) > 0

		// preencho as variaveis de acordo com o array de parametros se houver dados
		If Len( aParam ) >= 1 .And. !Empty(aParam[1])
			cDeContrato     := aParam[1]
		EndIf

		// preencho as variaveis de acordo com o array de parametros se houver dados
		If Len( aParam ) >= 2 .And. !Empty(aParam[2])
			cAteContrato    := aParam[2]
		EndIf

		// preencho as variaveis de acordo com o array de parametros se houver dados
		If Len( aParam ) >= 3 .And. !Empty(aParam[3])
			cPlanos         := aParam[3]
		EndIf

		// preencho as variaveis de acordo com o array de parametros se houver dados
		If Len( aParam ) >= 4 .And. !Empty(aParam[4])
			cIndice         := aParam[4]
		EndIf

		// preencho as variaveis de acordo com o array de parametros se houver dados
		If Len( aParam ) >= 5 .And. aParam[5] > 0
			nTipo           := aParam[5]
		EndIf

		// preencho as variaveis de acordo com o array de parametros se houver dados
		If Len( aParam ) >= 6 .And. !Empty(aParam[6])
			dDataDe         := aParam[6]
		EndIf

		// preencho as variaveis de acordo com o array de parametros se houver dados
		If Len( aParam ) >= 7 .And. !Empty(aParam[7])
			dDataAt         := aParam[7]
		EndIf

		// preencho as variaveis de acordo com o array de parametros se houver dados
		If Len( aParam ) >= 8 .And. !Empty(aParam[8])
			nStatus         := aParam[8]
		EndIf

	EndIf

	// validacao do campo <Ate Vendedor ?>
	If lRetorno .And. Empty(AllTrim( cAteContrato ))

		// retorno mensagem para o usuario
		MsgAlert("Campo <Contrato Ate ?> não pode estar vazio!")
		lRetorno := .F.

	EndIf

Return(lRetorno)

/*/{Protheus.doc} RCPGA41A
funcao para gerar a estrutura do alias temporario
de contratos para a locacao de nicho
@type function
@version 
@author g.sampaio
@since 04/03/2020
@param cArqTrb, character, alias temporario de contrato
@param oTempContrato, object, objeto da estrutura do alias temporario de contratos
@return return_type, return_description
/*/
User Function RCPGA41A( cArqTrb, oTempContrato, lVazio )

	Local aCampos           := {}
	Local aIndContrato		:= {"TR_CODIGO","TR_CONTRAT","TR_CODCLI","TR_LOJCLI"}
	Local cFwAlias          := ""

	Default cArqTrb         := "TRBCTR"
	Default lVazio          := .T.

	///////////////////////////////////////////////////////////////////////////
	//////////////////    MONTO A ESTRUTURA DA TABELA    //////////////////////
	///////////////////////////////////////////////////////////////////////////

	//Array contendo os campos da tabela temporária
	Aadd( aCampos, { "TR_MARK" 		, "L" , 1 						, 0	})
	Aadd( aCampos, { "TR_STATUS"	, "C" , 20 						, 0	})
	Aadd( aCampos, { "TR_CODIGO"	, "C" , 6 						, 0	})
	Aadd( aCampos, { "TR_CONTRAT"	, "C" , 6 						, 0	})
	Aadd( aCampos, { "TR_CODCLI"	, "C" , TamSX3("A1_COD")[1] 	, 0	})
	Aadd( aCampos, { "TR_LOJCLI"	, "C" , TamSX3("A1_LOJA")[1]	, 0 })
	Aadd( aCampos, { "TR_CLIENTE"	, "C" , TamSX3("A1_NOME")[1]	, 0	})
	Aadd( aCampos, { "TR_TIPOEND"	, "C" , 15 						, 0	})
	Aadd( aCampos, { "TR_CREMOS"	, "C" , 2 						, 0	})
	Aadd( aCampos, { "TR_NICHO" 	, "C" , 4 						, 0	})
	Aadd( aCampos, { "TR_DIAVENC"	, "C" , 2 						, 0	})
	Aadd( aCampos, { "TR_INDIC"	    , "C" , 3 	                    , 0	})
	Aadd( aCampos, { "TR_TXINDI"    , "N" , 5 	                    , 2	})
	Aadd( aCampos, { "TR_VLADIC"    , "N" , 12 	                    , 2	})
	Aadd( aCampos, { "TR_TXLOCN"    , "N" , 9 	                    , 2	})

	///////////////////////////////////////////////////////////////////////////
	//////////////////      CRIO A TABELA TEMPORARIA     //////////////////////
	///////////////////////////////////////////////////////////////////////////

	//Antes de criar a tabela, verificar se a mesma já foi aberta
	If Select( cArqTrb ) > 0
		(cArqTrb)->(DbCloseArea())
	Endif

	// zero o objeto
	if oTempContrato <> NIL
		FreeObj(oTempContrato)
        oTempContrato := NIL
	endIf

	//-------------------
	//Criação do objeto
	//-------------------
	oTempContrato := FWTemporaryTable():New( cArqTrb )
	oTempContrato:SetFields( aCampos )
	oTempContrato:AddIndex("01", aIndContrato )

	//------------------
	//Criação da tabela
	//------------------
	oTempContrato:Create()

	//------------------------------------
	// pego o nome do alias
	//------------------------------------
	cFwAlias := oTempContrato:GetAlias()

	// funcao para validar se crio o alias vazio
	if lVazio

		// funcao para popular as tabelas
		U_RCPGE29A( aCampos, cFwAlias, .T. )

	endIf

Return( Nil )

/*/{Protheus.doc} RCPGA41B
funcao para gerar a estrutura do alias temporario
de parcelas para a locacao de nicho
@type function
@version 
@author g.sampaio
@since 04/03/2020
@param cArqTrb, character, alias temporario de parcelas
@param oTempContrato, object, objeto da estrutura do alias temporario de parcelas
@return return_type, return_description
/*/
User Function RCPGA41B( cArqTrb, oTempParcelas )

	Local aCampos			:= {}
	Local aIndParcelas	    := {"TMP_PREF","TMP_NUM","TMP_PARCEL","TMP_TIPO"}
	Local cFwAlias          := ""

	Default cArqTrb         := "TRBPAR"

	///////////////////////////////////////////////////////////////////////////
	//////////////////    MONTO A ESTRUTURA DA TABELA    //////////////////////
	///////////////////////////////////////////////////////////////////////////

	//Array contendo os campos da tabela temporária
	Aadd( aCampos, { "TMP_CODIGO" 	    , "C" , 6                       , 0	})
	Aadd( aCampos, { "TMP_PARCEL" 	    , "C" , TamSX3("E1_PARCELA")[1]	, 0	})
	Aadd( aCampos, { "TMP_PREF" 	    , "C" , TamSX3("E1_TIPO")[1]	, 0	})
	Aadd( aCampos, { "TMP_NUM" 	        , "C" , TamSX3("E1_NUM")[1] 	, 0	})
	Aadd( aCampos, { "TMP_TIPO" 		, "C" , TamSX3("E1_TIPO")[1] 	, 0	})
	Aadd( aCampos, { "TMP_NATURE" 		, "C" , TamSX3("E1_NATUREZ")[1] , 0	})
	Aadd( aCampos, { "TMP_VALOR"		, "N" , TamSX3("E1_VALOR")[1] 	, TamSX3("E1_VALOR")[2]	})
	Aadd( aCampos, { "TMP_VENCTO"		, "D" , TamSX3("E1_VENCTO")[1]  , 0	})

	///////////////////////////////////////////////////////////////////////////
	//////////////////      CRIO A TABELA TEMPORARIA     //////////////////////
	///////////////////////////////////////////////////////////////////////////

	//Antes de criar a tabela, verificar se a mesma já foi aberta
	If Select( cArqTrb ) > 0
		(cArqTrb)->(DbCloseArea())
	Endif

	//-------------------
	//Criação do objeto
	//-------------------
	oTempParcelas := FWTemporaryTable():New( cArqTrb )
	oTempParcelas:SetFields( aCampos )
	oTempParcelas:AddIndex("01", aIndParcelas )

	//------------------
	//Criação da tabela
	//------------------
	oTempParcelas:Create()

	//------------------------------------
	// pego o nome do alias
	//------------------------------------
	cFwAlias := oTempParcelas:GetAlias()

	// funcao para popular as tabelas
	U_RCPGE29A( aCampos, cFwAlias, .T. )

Return( Nil )

/*/{Protheus.doc} ConfirmarTela
Executo a rotina de processamento
@type function
@version 
@author g.sampaio
@since 04/03/2020
@param cTrbContrato, character, param_description
@param cTrbParcelas, character, param_description
@param cLog, character, param_description
@return return_type, return_description
/*/
Static Function ConfirmarTela( cDeContrato, cAteContrato, cPlanos, cIndice, nTipo, dDataDe, dDataAt,nDataLoc, cLog, cTrbContrato, cTrbParcelas,;
		oTempContrato, oTempParcelas, oBrowseContrato, oBrowseParcelas, oDlg )


	Local lOK               := .T.
	Local oProcess			:= Nil

	Default cDeContrato     := ""
	Default cAteContrato    := ""
	Default cPlanos         := ""
	Default cIndice         := ""
	Default nTipo           := 0
	Default dDataDe         := stod("")
	Default dDataAt         := stod("")
	Default cTrbContrato    := ""
	Default cTrbParcelas    := ""
	Default cLog            := ""
	Default nStatus         := 0
	Default nDataLoc        := 0

	// chamao o processamento de comissoes
	oProcess := MsNewProcess():New({|lEnd| lOK := U_RCPGE030( cTrbContrato, cTrbParcelas, @cLog, oTempContrato, oTempParcelas, @oProcess ) },"Processamento de Taxa de Locacao","Aguarde! Gerando taxas de ...",.T.)
	oProcess:Activate()

	// verifico se a geracao da taxa aconteceu sem problemas
	If lOK

		// mensagem de retorno positivo
		MsgInfo("Parcelas de locação de nicho geradas com sucesso!")
		oDlg:End()

	Else

		// mensagem de retorno negativo
		MsgAlert("Existem problemas para a geração da taxa de locação, favor verificar o log!")

	EndIf

Return(Nil)
