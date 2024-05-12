#Include "TOTVS.CH"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "FWBROWSE.CH"

#DEFINE LOGO_PACOTE "AVGBOX1.PNG"
#DEFINE CRLF		CHR(13)+CHR(10)

/*/{Protheus.doc} RUTIL018
Rotina de processamento de comissões para :
Vendedor, Cobrador, Supervisor e Gerente 
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
/*/

User Function RUTIL018()

	Local aObjects 			:= {}
	Local aSizeAut	   		:= MsAdvSize()
	Local aObjects			:= {}
	Local aPosObj			:= {}
	Local aCords			:= {}
	Local aIndiceTipo		:= {"TR_ITEM","TR_TIPO","TR_VEND"}
	Local aIndiceDetalhes	:= {"TR_ITEM","TR_ORIGEM","TR_RELAC","TR_CODIGO"}
	Local cTrbTipo			:= ""
	Local cTrbDetalhes		:= ""
	Local cGet1				:= Space( TamSX3("A3_COD")[1] )
	Local cGet2				:= Space( TamSX3("A3_COD")[1] )
	Local cLog				:= ""
	Local cPrefCtr			:= AllTrim(SuperGetMv("MV_XPREFCT",.F.,"CTR"))  //prefixo do titulo de contrato
	Local cTipoCtr			:= AllTrim(SuperGetMv("MV_XTIPOCT",.F.,"AT"))   //tipo do titulo de contrato
	Local cTipoEnt			:= AllTrim(SuperGetMv("MV_XTIPOEN",.F.,"ENT"))  //tipo de titulo de entrada
	Local cPrefFun 			:= Alltrim(SuperGetMv("MV_XPREFUN",.F.,"FUN"))
	Local cTipoFun			:= Alltrim(SuperGetMv("MV_XTIPFUN",.F.,"AT"))
	Local dGet3				:= CtoD("")
	Local dGet4				:= CtoD("")
	Local lRet				:= .F.
	Local nX				:= 0
	Local nComboBo1			:= 0
	Local oPanelCab			:= NIL
	Local oPanelRod			:= NIL
	Local oPanelFiltro		:= NIL
	Local oPanelTipo		:= NIL
	Local oPanelDetalhes	:= NIL
	Local oBrowseTipo		:= NIL
	Local oBrowseDetalhes	:= NIL
	Local oRelac			:= NIL
	Local oDlg				:= NIL
	Local oBut1				:= NIL
	Local oBut2				:= NIL
	Local oBut3				:= NIL
	Local oBut4				:= NIL
	Local oGroupCab			:= NIL
	Local oGroupRod			:= NIL
	Local oGroupFiltro		:= NIL
	Local oSay1				:= NIL
	Local oSay2				:= NIL
	Local oSay3				:= NIL
	Local oSay4				:= NIL
	Local oSay5				:= NIL
	Local oGet1				:= NIL
	Local oGet2				:= NIL
	Local oGet3				:= NIL
	Local oGet4				:= NIL
	Local oComboBo1			:= NIL
	Local oTempTipo			:= NIL
	Local oTempDetalhes		:= NIL

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

	DEFINE MSDIALOG oDlg TITLE "Processamento de Comissões" FROM aSizeAut[7], 0 TO aSizeAut[6], aSizeAut[5] COLORS 0, 16777215 PIXEL // STYLE DS_MODALFRAME

	@ aCords[1,1], aCords[1,2] MSPANEL oPanelCab 			PROMPT "" SIZE aCords[1,3], aCords[1,4] OF oDlg COLORS 0, 16777215

	@ aCords[2,1], aCords[2,2] MSPANEL oPanelRod 			PROMPT "" SIZE aCords[2,3], aCords[2,4] OF oDlg COLORS 0, 16777215

	@ aCords[3,1], aCords[3,2] MSPANEL oPanelFiltro 		PROMPT "" SIZE aCords[3,3], aCords[3,4] OF oDlg COLORS 0, 16777215

	@ aCords[4,1], aCords[4,2] MSPANEL oPanelTipo	 		PROMPT "" SIZE aCords[4,3], aCords[4,4] OF oDlg COLORS 0, 16777215

	@ aCords[5,1], aCords[5,2] MSPANEL oPanelDetalhes 		PROMPT "" SIZE aCords[5,3], aCords[5,4] OF oDlg COLORS 0, 16777215

	@ 013, 005 GROUP oGroupCab TO 014, aCords[1,3] - 5 		PROMPT "" OF oPanelCab COLOR 0, 16777215 PIXEL

	// tela de filtros
	@ 013, 005 GROUP oGroupFiltro TO aCords[3,4] , aCords[3,3] - 5	PROMPT "" OF oPanelFiltro COLOR 0, 16777215 PIXEL

	@ 020, 010 SAY oSay1 	PROMPT "Do Vendedor ?" 		SIZE 050, 007 OF oPanelFiltro COLORS 0, 16777215 PIXEL
	@ 040, 010 SAY oSay2 	PROMPT "Ate Vendedor ?" 	SIZE 050, 007 OF oPanelFiltro COLORS 0, 16777215 PIXEL
	@ 060, 010 SAY oSay3	PROMPT "Da Data ?"	 		SIZE 050, 007 OF oPanelFiltro COLORS 0, 16777215 PIXEL
	@ 080, 010 SAY oSay4	PROMPT "Até a Data ?" 		SIZE 050, 007 OF oPanelFiltro COLORS 0, 16777215 PIXEL
	@ 100, 010 SAY oSay5 	PROMPT "Para ?" 			SIZE 050, 007 OF oPanelFiltro COLORS 0, 16777215 PIXEL

	// preenche os campos automaticos
	cGet1 	:= Space( TamSX3("A3_COD")[1] )
	cGet2	:= Replicate( "Z", TamSX3("A3_COD")[1] )
	dGet3	:= FirstDate( dDataBase )
	dGet4	:= LastDate( dDataBase )

	@ 019, 060 MSGET oGet1 VAR cGet1 F3 "SA3" PICTURE "@!" 		SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON
	@ 039, 060 MSGET oGet2 VAR cGet2 F3 "SA3" PICTURE "@!" 		SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON
	@ 059, 060 MSGET oGet3 VAR dGet3 PICTURE "@D" 				SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON
	@ 079, 060 MSGET oGet4 VAR dGet4 PICTURE "@D" 				SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON
	@ 099, 060 MSCOMBOBOX oComboBo1 VAR nComboBo1 				ITEMS {"Ambos","Vendedor","Cobrador","Surpevisor","Gerente"} SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL

	// preenche os campos automaticos
	oComboBo1:nAt	:= 1

	@ 120, 010 BUTTON oBut3 PROMPT "Processar" 		SIZE 041, 012 OF oDlg PIXEL ACTION ProcessaComissao( cGet1, cGet2, dGet3, dGet4, oComboBo1:nAt,  @cLog, cTrbTipo,;
		cTrbDetalhes, @oBrowseTipo, @oBrowseDetalhes, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun, @oTempTipo, @oTempDetalhes )
	@ 140, 010 BUTTON oBut4 PROMPT "Visualizar Log" SIZE 041, 012 OF oDlg PIXEL ACTION ShowLog(@cLog)
	@ 160, 010 BUTTON oBut4 PROMPT "Imprimir" 		SIZE 041, 012 OF oDlg PIXEL ACTION U_RUTILR03( oTempTipo, oTempDetalhes, dGet3, dGet4 )

	@ 002, 005 GROUP oGroupRod TO 003 , aCords[2,3] - 5 	PROMPT "" OF oPanelRod COLOR 0, 16777215 PIXEL

	@ 007, (aCords[2,3] - 55) 	BUTTON oBut1 PROMPT "Confirmar" SIZE 050, 015 OF oPanelRod PIXEL ACTION (lRet := .T., ConfirmarTela( oDlg, @cLog, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun, oTempDetalhes, dGet4 ) )
	@ 007, (aCords[2,3] - 110)	BUTTON oBut2 PROMPT "Cancelar" SIZE 050, 015 OF oPanelRod PIXEL ACTION (lRet := .F.,oDlg:End())

	// monto o grid de associados
	GridTipo( oPanelTipo, @cTrbTipo, @aIndiceTipo, @oBrowseTipo, @oBrowseDetalhes, @oTempTipo )

	// monto o grid de serviços utilizados
	GridDetalhes( oPanelDetalhes, @cTrbDetalhes, @aIndiceDetalhes, @oBrowseDetalhes, @oBrowseTipo, @oTempDetalhes )

	oRelac := FWBrwRelation():New()
	oRelac:AddRelation( oBrowseTipo , oBrowseDetalhes , { { 'TR_RELAC', 'TR_VEND' } } )
	oRelac:Activate()

	ACTIVATE MSDIALOG oDlg CENTERED

Return(lRet)

/*/{Protheus.doc} GridDetalhes
Funcao para montar a grid de detalhes
@author g.sampaio
@since 13/06/2019
@version P12
@param oPanel
@param cArqTrb
@param aIndiceDetalhes
@param oBrowse
@return nulo
/*/

Static Function GridDetalhes(oPanel, cArqTrb, aIndiceDetalhes, oBrowse, oBrowseRelac, oTempDetalhes )

	Local aCampos			:= {}
	Local aSeek 			:= {}
	Local cCadastro 		:= "Detalhes Comissão:"
	Local oTR_BASEColumn	:= Nil
	Local oTR_CODIGOColumn	:= Nil
	Local oTR_COMISColumn	:= Nil
	Local oTR_DSCPROColumn	:= Nil
	Local oTR_DTCOMIColumn	:= Nil
	Local oTR_ITEMColumn	:= Nil
	Local oTR_HISTColumn	:= Nil
	Local oTR_NOMEColumn	:= Nil
	Local oTR_ORIGEMColumn	:= Nil
	Local oTR_PORCColumn	:= Nil
	Local oTR_PRCPVColumn	:= Nil
	Local oTR_PRODUTColumn	:= Nil
	Local oTR_QTDPVColumn	:= Nil
	Local oTR_RELACColumn	:= Nil
	Local oTR_VENDColumn	:= Nil
	Local oTR_VENCTOColumn	:= Nil

	Default aIndiceDetalhes	:= {}
	Default cArqTrb			:= ""

	// defino o nome do arquivo de trabalho
	If Empty(cArqTrb)
		cArqTrb := "TRB_DET"
	EndIf

	CriaTabDetalhes(cArqTrb, @oTempDetalhes)

	//------------------------------------
	// pego o nome do alias
	//------------------------------------
	cFwAlias := oTempDetalhes:GetAlias()

	// funcao para popular as tabelas
	GeraRegistros( aCampos, cFwAlias, .T. )

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

	// adicionar busca no browser
	//Campos que irão compor o combo de pesquisa na tela principal
	Aadd( aSeek, { "Item"					, { { "", "C", 3						, 0, "TR_ITEM"   , "@!" } }, 1, .T. } )
	Aadd( aSeek, { "Tipo"					, { { "", "C", 20						, 0, "TR_TIPO"   , "@!" } }, 2, .T. } )
	Aadd( aSeek, { "Codigo"					, { { "", "C", TamSX3("A3_COD")[1]		, 0, "TR_VEND"   , "@!" } }, 3, .T. } )
	Aadd( aSeek, { "Nome"					, { { "", "C", TamSX3("A3_NOME")[1]		, 0, "TR_NOME"	 , "@!" } }, 4, .T. } )
	Aadd( aSeek, { "Contrato"				, { { "", "C", 6						, 0, "TR_NOME"	 , "@!" } }, 5, .T. } )

	oBrowse:SetSeek(,aSeek)

	//Detalhes das colunas que serão exibidas
	// Coluna de Item
	oTR_ITEMColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_ITEMColumn:SetData( { || TR_ITEM } )		// campo referente a coluna
	oTR_ITEMColumn:SetTitle("Item")					// titulo da coluna
	oTR_ITEMColumn:SetSize(5)						// tamanho da coluna
	oTR_ITEMColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTR_ITEMColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Origem
	oTR_ORIGEMColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_ORIGEMColumn:SetData( { || TR_ORIGEM } )	// campo referente a coluna
	oTR_ORIGEMColumn:SetTitle("Origem")				// titulo da coluna
	oTR_ORIGEMColumn:SetSize(10)					// tamanho da coluna
	oTR_ORIGEMColumn:SetPicture("@!")				// mascara da coluna
	oBrowse:SetColumns({oTR_ORIGEMColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Codigo
	oTR_CODIGOColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_CODIGOColumn:SetData( { || TR_CODIGO } )	// campo referente a coluna
	oTR_CODIGOColumn:SetTitle("Contrato")			// titulo da coluna
	oTR_CODIGOColumn:SetSize(5)						// tamanho da coluna
	oTR_CODIGOColumn:SetPicture("@!")				// mascara da coluna
	oBrowse:SetColumns({oTR_CODIGOColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Data de Comissao
	oTR_DTCOMIColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_DTCOMIColumn:SetData( { || TR_DTCOMI } )	// campo referente a coluna
	oTR_DTCOMIColumn:SetTitle("Dt Comissao")		// titulo da coluna
	oTR_DTCOMIColumn:SetSize(5)						// tamanho da coluna
	oTR_DTCOMIColumn:SetPicture("@D")				// mascara da coluna
	oBrowse:SetColumns({oTR_DTCOMIColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Vendedor
	oTR_VENDColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_VENDColumn:SetData( { || TR_VEND } )		// campo referente a coluna
	oTR_VENDColumn:SetTitle("Vendedor")				// titulo da coluna
	oTR_VENDColumn:SetSize(5)						// tamanho da coluna
	oTR_VENDColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTR_VENDColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Nome do Vendedor
	oTR_NOMEColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_NOMEColumn:SetData( { || TR_NOME } )		// campo referente a coluna
	oTR_NOMEColumn:SetTitle("Nome")					// titulo da coluna
	oTR_NOMEColumn:SetSize(30)						// tamanho da coluna
	oTR_NOMEColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTR_NOMEColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Produto
	oTR_PRODUTColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_PRODUTColumn:SetData( { || TR_PRODUT } )	// campo referente a coluna
	oTR_PRODUTColumn:SetTitle("Produto")			// titulo da coluna
	oTR_PRODUTColumn:SetSize(5)						// tamanho da coluna
	oTR_PRODUTColumn:SetPicture("@!")				// mascara da coluna
	oBrowse:SetColumns({oTR_PRODUTColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Descricao do Produto
	oTR_DSCPROColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_DSCPROColumn:SetData( { || TR_DSCPRO } )	// campo referente a coluna
	oTR_DSCPROColumn:SetTitle("Desc.Prod")			// titulo da coluna
	oTR_DSCPROColumn:SetSize(30)					// tamanho da coluna
	oTR_DSCPROColumn:SetPicture("@!")				// mascara da coluna
	oBrowse:SetColumns({oTR_DSCPROColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Quantidade
	oTR_QTDPVColumn := FWBrwColumn():New()					// instancio da classe do objeto
	oTR_QTDPVColumn:SetData( { || TR_QTDPV } )				// campo referente a coluna
	oTR_QTDPVColumn:SetTitle("Quantidade")					// titulo da coluna
	oTR_QTDPVColumn:SetSize(10)								// tamanho da coluna
	oTR_QTDPVColumn:SetPicture(PesqPict("SC6","C6_QTDVEN"))	// mascara da coluna
	oBrowse:SetColumns({oTR_QTDPVColumn})					// adiciono o objeto da coluna no browse

	// Coluna de Preço de Venda
	oTR_PRCPVColumn := FWBrwColumn():New()					// instancio da classe do objeto
	oTR_PRCPVColumn:SetData( { || TR_PRCPV } )				// campo referente a coluna
	oTR_PRCPVColumn:SetTitle("Prc.Vend")					// titulo da coluna
	oTR_PRCPVColumn:SetSize(10)								// tamanho da coluna
	oTR_PRCPVColumn:SetPicture(PesqPict("SC6","C6_PRCVEN"))	// mascara da coluna
	oBrowse:SetColumns({oTR_PRCPVColumn})					// adiciono o objeto da coluna no browse


	// Coluna de Valor Base
	oTR_BASEColumn := FWBrwColumn():New()					// instancio da classe do objeto
	oTR_BASEColumn:SetData( { || TR_BASE } )				// campo referente a coluna
	oTR_BASEColumn:SetTitle("Vl Base")						// titulo da coluna
	oTR_BASEColumn:SetSize(10)								// tamanho da coluna
	oTR_BASEColumn:SetPicture(PesqPict("SE3","E3_BASE"))	// mascara da coluna
	oBrowse:SetColumns({oTR_BASEColumn})					// adiciono o objeto da coluna no browse

	// Coluna de Percentual de Comissao
	oTR_PORCColumn := FWBrwColumn():New()						// instancio da classe do objeto
	oTR_PORCColumn:SetData( { || TR_PORC } )					// campo referente a coluna
	oTR_PORCColumn:SetTitle("% Vl Base")						// titulo da coluna
	oTR_PORCColumn:SetSize(10)									// tamanho da coluna
	oTR_PORCColumn:SetPicture(PesqPict("SE3","E3_PORC"))		// mascara da coluna
	oBrowse:SetColumns({oTR_PORCColumn})						// adiciono o objeto da coluna no browse

	// Coluna de Valor da Comissao
	oTR_COMISColumn := FWBrwColumn():New()						// instancio da classe do objeto
	oTR_COMISColumn:SetData( { || TR_COMIS } )					// campo referente a coluna
	oTR_COMISColumn:SetTitle("Vl Comissao")						// titulo da coluna
	oTR_COMISColumn:SetSize(10)									// tamanho da coluna
	oTR_COMISColumn:SetPicture(PesqPict("SE3","E3_COMIS"))		// mascara da coluna
	oBrowse:SetColumns({oTR_COMISColumn})						// adiciono o objeto da coluna no browse

	// Coluna de Historico
	oTR_HISTColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_HISTColumn:SetData( { || TR_HIST } )		// campo referente a coluna
	oTR_HISTColumn:SetTitle("Historico")			// titulo da coluna
	oTR_HISTColumn:SetSize(30)						// tamanho da coluna
	oTR_HISTColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTR_HISTColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Relacionamento
	oTR_RELACColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_RELACColumn:SetData( { || TR_RELAC } )		// campo referente a coluna
	oTR_RELACColumn:SetTitle("Relacionamento")		// titulo da coluna
	oTR_RELACColumn:SetSize(5)						// tamanho da coluna
	oTR_RELACColumn:SetPicture("@!")				// mascara da coluna
	oBrowse:SetColumns({oTR_RELACColumn})			// adiciono o objeto da coluna no browse

	oBrowse:SetClrAlterRow(128128128)

	// edicao da celula
	//oBrowse:SetEditCell(.T., { || ValidCell() } )

	oBrowse:Activate()

Return(Nil)

/*/{Protheus.doc} GridTipo
Rotina de processamento de comissões para :
Vendedor, Cobrador, Supervisor e Gerente 
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
/*/

Static Function GridTipo( oPanel, cArqTrb, aIndiceTipo, oBrowse, oBrowseRelac, oTempTipo )

	Local aCampos				:= {}
	Local aSeek 				:= {}
	Local cCadastro 			:= "Tipos de Comissão:"
	Local oTR_COMISColumn		:= Nil
	Local oTR_PORCColumn		:= Nil
	Local oTR_BASEColumn		:= Nil
	Local oTR_VENCTOColumn		:= Nil
	Local oTR_NOMEColumn		:= Nil
	Local oTR_VENDColumn		:= Nil
	Local oTR_TIPOColumn		:= Nil
	Local oTR_ITEMColumn		:= Nil
	Local oTR_QUANTColumn		:= Nil

	Default aIndiceTipo		:= {}
	Default cArqTrb			:= ""

	// defino o nome do arquivo de trabalho
	If Empty(cArqTrb)
		cArqTrb := "TRB_TIPO"
	EndIf

	CriaTabTipo(cArqTrb, @oTempTipo)

	//------------------------------------
	// pego o nome do alias
	//------------------------------------
	cFwAlias := oTempTipo:GetAlias()

	// funcao para popular as tabelas
	GeraRegistros( aCampos, cFwAlias, .T. )

	///////////////////////////////////////////////////////////////////////////
	////////////////// 		      CRIO O GRID		     //////////////////////
	///////////////////////////////////////////////////////////////////////////

	oBrowse := FWBrowse():New(oPanel)
	oBrowse:SetDataTable(.T.)
	oBrowse:SetAlias( "TRB_TIPO" )
	oBrowse:SetDescription( cCadastro )

	// Desabilito a opção de impressão
	oBrowse:DisableReport()

	// Desabilito a opção de Salvar Configuração
	oBrowse:DisableSaveConfig()

	// Desabilito a opção de Configuração
	oBrowse:DisableConfig()

	// adicionar busca no browser
	//Campos que irão compor o combo de pesquisa na tela principal
	Aadd( aSeek, { "Item"					, { { "", "C", 3						, 0, "TR_ITEM"   , "@!"} }, 1, .T. } )
	Aadd( aSeek, { "Tipo"					, { { "", "C", 20						, 0, "TR_TIPO"   , "@!"} }, 2, .T. } )
	Aadd( aSeek, { "Codigo"					, { { "", "C", TamSX3("A3_COD")[1]		, 0, "TR_VEND"   , "@!"} }, 3, .T. } )
	Aadd( aSeek, { "Nome"					, { { "", "C", TamSX3("A3_NOME")[1]		, 0, "TR_NOME"	 , "@!"} }, 4, .T. } )
	Aadd( aSeek, { "Vencto Comis"			, { { "", "D", TamSX3("E3_VENCTO")[1]	, 0, "TR_VENCTO" , "@D"} }, 5, .T. } )

	oBrowse:SetSeek(,aSeek)

	//Detalhes das colunas que serão exibidas
	// Coluna de Item
	oTR_ITEMColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_ITEMColumn:SetData( { || TR_ITEM } )		// campo referente a coluna
	oTR_ITEMColumn:SetTitle("Item")					// titulo da coluna
	oTR_ITEMColumn:SetSize(5)						// tamanho da coluna
	oTR_ITEMColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTR_ITEMColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Tipo
	oTR_TIPOColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_TIPOColumn:SetData( { || TR_TIPO } )		// campo referente a coluna
	oTR_TIPOColumn:SetTitle("Tipo")					// titulo da coluna
	oTR_TIPOColumn:SetSize(10)						// tamanho da coluna
	oTR_TIPOColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTR_TIPOColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Codigo do Vendedor
	oTR_VENDColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_VENDColumn:SetData( { || TR_VEND } )		// campo referente a coluna
	oTR_VENDColumn:SetTitle("Codigo")				// titulo da coluna
	oTR_VENDColumn:SetSize(5)						// tamanho da coluna
	oTR_VENDColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTR_VENDColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Nome
	oTR_NOMEColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_NOMEColumn:SetData( { || TR_NOME } )		// campo referente a coluna
	oTR_NOMEColumn:SetTitle("Nome")					// titulo da coluna
	oTR_NOMEColumn:SetSize(30)						// tamanho da coluna
	oTR_NOMEColumn:SetPicture("@!")					// mascara da coluna
	oBrowse:SetColumns({oTR_NOMEColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Vencimento
	oTR_VENCTOColumn := FWBrwColumn():New()							// instancio da classe do objeto
	oTR_VENCTOColumn:SetData( { || TR_VENCTO } )					// campo referente a coluna
	oTR_VENCTOColumn:SetTitle("Vencto Comis")						// titulo da coluna
	oTR_VENCTOColumn:SetSize(15)									// tamanho da coluna
	oTR_VENCTOColumn:SetPicture("@D")								// mascara da coluna
	oTR_VENCTOColumn:SetEdit(.T.)									// coloco a coluna como editavel
	oTR_VENCTOColumn:SetReadVar("TR_VENCTO")						// adiciono a variavel em memoria para edicao
	oTR_VENCTOColumn:SetValid( { || VenctoValida( cArqTrb, oBrowse, oBrowseRelac ) } )
	oBrowse:SetColumns({oTR_VENCTOColumn})							// adiciono o objeto da coluna no browse

	// Coluna de quantidade
	oTR_QUANTColumn := FWBrwColumn():New()							// instancio da classe do objeto
	oTR_QUANTColumn:SetData( { || TR_QUANT } )					// campo referente a coluna
	oTR_QUANTColumn:SetTitle("Quant.Contratos")						// titulo da coluna
	oTR_QUANTColumn:SetSize(15)									// tamanho da coluna
	oTR_QUANTColumn:SetPicture("@E 999")								// mascara da coluna
	oBrowse:SetColumns({oTR_QUANTColumn})							// adiciono o objeto da coluna no browse

	// Coluna de Valor Base
	oTR_BASEColumn := FWBrwColumn():New()							// instancio da classe do objeto
	oTR_BASEColumn:SetData( { || TR_BASE } )						// campo referente a coluna
	oTR_BASEColumn:SetTitle("Vlr.Base")								// titulo da coluna
	oTR_BASEColumn:SetSize(15)										// tamanho da coluna
	oTR_BASEColumn:SetPicture(PesqPict("SE3","E3_BASE"))			// mascara da coluna
	oTR_BASEColumn:SetEdit(.T.)										// coloco a coluna como editavel
	oTR_BASEColumn:SetReadVar("TR_BASE")							// adiciono a variavel em memoria para edicao
	oTR_BASEColumn:SetValid( { || BaseValida( cArqTrb, oBrowse, oBrowseRelac ) } )
	oBrowse:SetColumns({oTR_BASEColumn})							// adiciono o objeto da coluna no browse

	// Coluna de Porcentagem do valor base
	oTR_PORCColumn := FWBrwColumn():New()							// instancio da classe do objeto
	oTR_PORCColumn:SetData( { || TR_PORC } )						// campo referente a coluna
	oTR_PORCColumn:SetTitle("% Vl Base")							// titulo da coluna
	oTR_PORCColumn:SetSize(15)										// tamanho da coluna
	oTR_PORCColumn:SetPicture(PesqPict("SE3","E3_PORC"))			// mascara da coluna
	oTR_PORCColumn:SetEdit(.T.)										// coloco a coluna como editavel
	oTR_PORCColumn:SetReadVar("TR_PORC")							// adiciono a variavel em memoria para edicao
	oTR_PORCColumn:SetValid( { || PorcValida( cArqTrb, oBrowse, oBrowseRelac ) } )
	oBrowse:SetColumns({oTR_PORCColumn})							// adiciono o objeto da coluna no browse

	// Coluna de Comissao
	oTR_COMISColumn := FWBrwColumn():New()							// instancio da classe do objeto
	oTR_COMISColumn:SetData( { || TR_COMIS } )						// campo referente a coluna
	oTR_COMISColumn:SetTitle("Comissao")							// titulo da coluna
	oTR_COMISColumn:SetSize(15)										// tamanho da coluna
	oTR_COMISColumn:SetPicture(PesqPict("SE3","E3_COMIS"))			// mascara da coluna
	oTR_COMISColumn:SetEdit(.T.)									// coloco a coluna como editavel
	oTR_COMISColumn:SetReadVar("TR_COMIS")							// adiciono a variavel em memoria para edicao
	oTR_COMISColumn:SetValid( { || ComisValida( cArqTrb, oBrowse, oBrowseRelac ) } )
	oBrowse:SetColumns({oTR_COMISColumn})							// adiciono o objeto da coluna no browse

	// edicao da celula
	oBrowse:SetEditCell(.T., { || ValidCell() } )

	oBrowse:SetClrAlterRow(128128128)

	oBrowse:Activate()

Return(Nil)

/*/{Protheus.doc} ConfirmarTela
Rotina de processamento de comissões para :
Vendedor, Cobrador, Supervisor e Gerente 
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
/*/

Static Function ConfirmarTela( oDlg, cLog, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun, oTempDetalhes, dDataAt )

	Local lRetorno			:= .T.
	Local lEnd				:= .F.
	Local oProcess			:= Nil

	Default cLog			:= ""
	Default cPrefCtr		:= ""
	Default cTipoCtr		:= ""
	Default cTipoEnt		:= ""
	Default cPrefFun		:= ""
	Default cTipoFun 		:= ""
	Default dDataAt			:= Stod("")

	cLog += CRLF
	cLog += ">> Funcao ConfirmarTela [Inicio] "

	// chamao o processamento de comissoes
	oProcess := MsNewProcess():New({|lEnd| lRetorno := ReprComissao( @oProcess, @lEnd, @cLog, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun, oTempDetalhes, dDataAt ) },"Reprocessamento de Comissões","Aguarde! Reprocessando as comissões...",.T.)
	oProcess:Activate()

	// se estiver tudo certo fecho a janela
	If lRetorno
		oDlg:End()
	EndIf

	cLog += CRLF
	cLog += ">> Funcao ConfirmarTela [Fim] "

	// gero a log de comissao
	If !Empty(cLog)
		CriaLogComissao(cLog)
	EndIf

Return(lRetorno)

/*/{Protheus.doc} GeraRegistros
Funcao para gerar os registros em alias temporarios
@author g.sampaio
@since 13/06/2019
@version P12
@param aCampos
@param cFwAlias
@return nulo
/*/

Static Function GeraRegistros( aCampos, cFwAlias, lGeraDados, oBrowseTipo, oBrowseDetalhes )

	Local aDados	:= {}
	Local aAux		:= {}
	Local cItem		:= ""
	Local nX		:= 0
	Local nI		:= 0

	Default aCampos		:= {}
	Default cFwAlias	:= ""
	Default lGeraDados	:= .F.

	// limpa os registros ja existentes
	LimpaDados( cFwAlias )

	// verifico se existe alias temporario
	If !Empty(cFwAlias)

		// caso forem gerados registros vazios
		If lGeraDados

			aAux := {}
			For nX := 1 To Len( aCampos )

				If aCampos[nX,2] == "C" // tipo caracter

					Aadd( aAux, { aCampos[nX, 1] , "" } )

				ElseIf aCampos[nX,2] == "D" // tipo data

					Aadd( aAux, { aCampos[nX, 1] , StoD("") } )

				ElseIf aCampos[nX,2] == "N" // tipo numerico

					Aadd( aAux, { aCampos[nX, 1] , 0 } )

				EndIf

			Next nX

			// monto o array aDados
			Aadd( aDados, aAux  )

		Else

			// a estrutura do aCampos se torna o aDados
			aDados := aCampos

		EndIf

		// posiciono no ultimo registro do alias
		(cFwAlias)->( DbGoBottom() )

		// inicio a transacao
		BEGIN TRANSACTION

			For nX := 1 To Len( aDados )

				// verifico se o item esta preenchido
				If Empty( cItem ) .And. Empty( &( cFwAlias + "->TR_ITEM" ) )

					cItem := StrZero( nX, 3 )

				Else

					cItem := Soma1( &( cFwAlias + "->TR_ITEM" ) )

				EndIf

				// travo o registro para gravacao
				If (cFwAlias)->( RecLock( cFwAlias, .T. ) )

					// gravo o item
					&( cFwAlias + "->TR_ITEM" ) := cItem

					For nI := 1 To Len( aDados[nX] )
						&( cFwAlias + "->" + aDados[nX,nI,1] ) := aDados[nX,nI,2]
					Next nI

					(cFwAlias)->( MsUnLock() )

				Else

					(cFwAlias)->( DisarmTransaction() )

				EndIf

			Next nX

		END TRANSACTION

		// posiciono no primeiro registro do alias
		(cFwAlias)->( DbGoTop() )


	EndIf

	// verifico se a variavel oBrowseTipo e objeto
	If ValType( oBrowseTipo ) == "O"

		// limpa os filtros
		oBrowseTipo:CleanExFilter()

		// atualizo o objeto
		oBrowseTipo:Refresh(.T.)

		// atualizo a construcao do browse
		oBrowseTipo:UpdateBrowse(.T.)

	EndIf

	// verifico se a variavel oBrowseDetalhes e objeto
	If ValType( oBrowseDetalhes ) == "O"

		// limpa os filtros
		oBrowseDetalhes:CleanExFilter()

		// atualizo o filtro
		oBrowseDetalhes:SetFilterDefault( oBrowseDetalhes:cAlias + "->TR_RELAC==" + oBrowseTipo:cAlias + "->TR_VEND" )

		// atualizo o objeto
		oBrowseDetalhes:Refresh(.T.)

		// atualizo a construcao do browse
		oBrowseDetalhes:UpdateBrowse(.T.)

	EndIf

Return(Nil)

/*/{Protheus.doc} ProcessaComissao
Funcao para gerar os registros em alias temporarios
@author g.sampaio
@since 13/06/2019
@version P12
@param cLog
@return nulo
/*/

Static Function ProcessaComissao( cVendDe, cVendAt, dDataDe, dDataAt, nOpc, cLog, cTrbTipo, cTrbDetalhes, oBrowseTipo,;
		oBrowseDetalhes, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun, oTempTipo, oTempDetalhes )

	Local oProcess
	Local lEnd 			:= .F.
	Private lProces

	Default cVendDe		:= ""
	Default cVendAt		:= ""
	Default dDataDe		:= ""
	Default dDataAt		:= ""
	Default nOpc		:= 0
	Default cLog 		:= ""
	Default cTrbTipo	:= ""
	Default cPrefCtr	:= ""
	Default cTipoCtr	:= ""
	Default cTipoEnt	:= ""
	Default cPrefFun	:= ""
	Default cTipoFun 	:= ""

	// Faco a validacao dos parametros
	If ValidParam( cVendDe, cVendAt, dDataDe, dDataAt, nOpc, @cLog, cTrbTipo, cTrbDetalhes, oBrowseTipo, oBrowseDetalhes )

		// chamao o processamento de comissoes
		oProcess := MsNewProcess():New({|lEnd| UAJUSCOM( @oProcess, @lEnd, @cLog, cVendDe, cVendAt, dDataDe, dDataAt, nOpc, cTrbTipo,;
			cTrbDetalhes, @oBrowseTipo, @oBrowseDetalhes, cPrefCtr, cTipoCtr, cTipoEnt,;
			cPrefFun, cTipoFun, @oTempTipo, @oTempDetalhes ) },"Processamento das Comissões","Aguarde! Processando as comissões...",.T.)
		oProcess:Activate()

	EndIf

Return(Nil)

/*/{Protheus.doc} ValidParam
Funcao para gerar os registros em alias temporarios
@author g.sampaio
@since 13/06/2019
@version P12
@param cLog
@return nulo
/*/

Static Function ValidParam( cVendDe, cVendAt, dDataDe, dDataAt, nOpc, cLog, cTrbTipo, cTrbDetalhes, oBrowseTipo, oBrowseDetalhes )

	Local lRetorno 			:= .T.

	Default cVendDe			:= ""
	Default	cVendAt			:= ""
	Default dDataDe			:= ""
	Default dDataAt			:= ""
	Default nOpc			:= 0
	Default cLog			:= ""
	Default cTrbTipo		:= ""
	Default cTrbDetalhes	:= ""

	// validacao do campo <De Vendedor ?>
	If !Empty(AllTrim( cVendDe ))

		// valido via existcpo
		lRetorno := ExistCpo( "SA3", cVendDe  )

	EndIf

	// validacao do campo <Ate Vendedor ?>
	If lRetorno .And. Empty(AllTrim( cVendAt ))

		// retorno mensagem para o usuario
		MsgAlert("Campo <Ate Vendedor ?> não pode estar vazio!")
		lRetorno := .F.

	EndIf

	// validacao do campo <Ate Vendedor ?>
	If lRetorno .And. !Empty(AllTrim( cVendAt )) .And. !( "Z" $ cVendAt .Or. "z" $ cVendAt )

		// valido via existcpo
		lRetorno := ExistCpo( "SA3", cVendAt )

	EndIf

	// validacao do campo <Da Data ?>
	If lRetorno .And. Empty( dDataDe )

		// retorno mensagem para o usuario
		MsgAlert("Campo <Da Data ?> não pode estar vazio!")
		lRetorno := .F.

	EndIf

	// validacao do campo <Ate a Data ?>
	If lRetorno .And. Empty( dDataAt )

		// retorno mensagem para o usuario
		MsgAlert("Campo <Ate a Data ?> não pode estar vazio!")
		lRetorno := .F.

	EndIf

	// validacao do preenchimento das datas
	If lRetorno .And. !Empty( dDataDe ) .And. !Empty( dDataAt )

		// verifico se a data de e maior que a data ate
		If dDataDe > dDataAt

			// retorno mensagem para o usuario
			MsgAlert("O conteúdo do campo <Da Data?> não pode ser maior que o conteúdo do campo  <Ate a Data ?> !")
			lRetorno := .F.

		EndIf

	EndIf

// validacao do campo <Para ?>
	If lRetorno .And. nOpc == 0

		// retorno mensagem para o usuario
		MsgAlert("Deve ser selecionado uma das opções do campo <Para ?>")
		lRetorno := .F.

	EndIf


Return(lRetorno)

/*/{Protheus.doc} UAJUSCOM
Funcao para gerar os registros em alias temporarios
@author g.sampaio
@since 13/06/2019
@version P12
@param cLog
@return nulo
/*/

Static Function UAJUSCOM( oProcess, lEnd, cLog, cVendDe, cVendAt, dDataDe, dDataAt, nOpc, cTrbTipo, cTrbDetalhes,;
		oBrowseTipo, oBrowseDetalhes, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun, oTempTipo, oTempDetalhes )

	Default lEnd			:= .F.
	Default cLog			:= ""
	Default cVendDe			:= ""
	Default cVendAt			:= ""
	Default	dDataDe			:= StoD("")
	Default	dDataAt			:= StoD("")
	Default nOpc			:= 0
	Default cTrbTipo		:= ""
	Default cTrbDetalhes	:= ""
	Default cPrefCtr		:= ""
	Default cTipoCtr		:= ""
	Default cTipoEnt	 	:= ""
	Default cPrefFun	 	:= ""
	Default cTipoFun 		:= ""

	//===========================
	// prencho a variavel de log
	//===========================
	cLog := ">> INICIO DO PROCESSAMENTO DE COMISSÕES" + CRLF
	cLog += CRLF
	cLog += " >> VENDEDORES: " + cVendDe + " ATE " + cVendAt + CRLF
	cLog += " >> DATA: " + DtoC(dDataDe) + " ATE " + DtoC(dDataAt) + CRLF
	cLog += CRLF

	// processamento de comissao
	PrComissao( oProcess, lEnd, @cLog, cVendDe, cVendAt, dDataDe, dDataAt, nOpc, cTrbTipo, cTrbDetalhes, @oBrowseTipo, @oBrowseDetalhes,;
		cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun, @oTempTipo, @oTempDetalhes )

	//===========================
	// prencho a variavel de log
	//===========================
	cLog += CRLF
	cLog += ">> FIM PROCESSAMENTO DE COMISSÕES" + CRLF

Return()

/*/{Protheus.doc} PrComissao
Funcao para gerar os registros em alias temporarios
@author g.sampaio
@since 13/06/2019
@version P12
@param cLog
@return nulo
/*/

Static Function PrComissao( oProcess, lEnd, cLog, cVendDe, cVendAt, dDataDe, dDataAt, nOpc, cTrbTipo, cTrbDetalhes, oBrowseTipo, oBrowseDetalhes,;
		cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun, oTempTipo, oTempDetalhes )

	Local aArea				:= GetArea()
	Local aAreaSA3			:= SA3->( GetArea() )
	Local aDadosTipo		:= {}
	Local aAuxTipo			:= {}
	Local aDadosDetalhes	:= {}
	Local aAuxDetalhes		:= {}
	Local aVendedores		:= {}
	Local cVendSub			:= ""
	Local cLstVend			:= ""
	Local nCountSA3			:= 0
	Local nTotDetBase 		:= 0
	Local nTotDetComis 		:= 0
	Local nTotDetPorc		:= 0
	Local nTotTipBase 		:= 0
	Local nTotTipComis 		:= 0
	Local nTotTipPorc		:= 0
	Local nPerVend			:= 0
	Local nX				:= 0

	Default lEnd			:= .F.
	Default cLog			:= ""
	Default cVendDe 		:= ""
	Default cVendAt			:= ""
	Default dDataDe			:= StoD("")
	Default dDataAt			:= StoD("")
	Default nOpc			:= 0
	Default cTrbTipo		:= ""
	Default cTrbDetalhes	:= ""
	Default cPrefCtr		:= ""
	Default cTipoCtr		:= ""
	Default cTipoEnt	 	:= ""
	Default cPrefFun	 	:= ""
	Default cTipoFun 		:= ""

// busco os vendedores cadastrados
	aVendedores := RetVendedores( @cLog, nOpc, cVendDe, cVendAt, dDataDe, dDataAt )

// pego a quantidade de registros do array aVendedores
	nCountSA3 := Len(aVendedores)

// atualizo o objeto de processamentp
	oProcess:SetRegua1(nCountSA3)

//===========================
// prencho a variavel de log
//===========================

	cLog += CRLF
	cLog += "  >> ARRAY aVendedores: " + CRLF + U_ToString(aVendedores)
	cLog += CRLF

// percorro os vendedores que seram gerados
	For nX := 1 to Len(aVendedores)

		If lEnd	//houve cancelamento do processo
			Exit
		EndIf

		// posiciono no registro do cadastro de vendedores
		SA3->( DbSetOrder(1) )
		If SA3->( MsSeek( xFilial("SA3")+aVendedores[nX,1] ) )

			If nOpc == 1 // ambos

				// verifico se e vendedor
				If SA3->A3_XFUNCAO == "V"

					// atualizo o objeto de processamento
					oProcess:IncRegua1("VENDEDOR: " 	+ aVendedores[nX,1] + " - " + SA3->A3_NOME )

					//===========================
					// prencho a variavel de log
					//===========================
					cLog += "   >> VENDEDOR: " + aVendedores[nX,1] + " - " + SA3->A3_NOME

					// chamo o processamento de commissao de vendedores
					ComVendedor( @oProcess, @cLog, nOpc, aVendedores[nX,1], dDataDe, dDataAt, cTrbTipo, cTrbDetalhes, @oBrowseTipo,;
						@oBrowseDetalhes, @aDadosTipo, @aDadosDetalhes, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun )

					// verifico se e cobrador
				ElseIf SA3->A3_XFUNCAO == "C"

					// atualizo o objeto de processamento
					oProcess:IncRegua1("COBRADOR: "		+ aVendedores[nX,1] + " - " + SA3->A3_NOME )

					//===========================
					// prencho a variavel de log
					//===========================
					cLog += "   >> COBRADOR: " + aVendedores[nX,1] + " - " + SA3->A3_NOME

					// chamo o processamento de commissao de cobradores
					ComCobrador( @oProcess, @cLog, nOpc, aVendedores[nX,1], dDataDe, dDataAt, cTrbTipo, cTrbDetalhes, @oBrowseTipo,;
						@oBrowseDetalhes, @aDadosTipo, @aDadosDetalhes, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun )

					// verifico se e supervisor
				ElseIf SA3->A3_XFUNCAO == "S"

					// atualizo o objeto de processamento
					oProcess:IncRegua1("SUPERVISOR: " 	+ aVendedores[nX,1] + " - " + SA3->A3_NOME )

					//===========================
					// prencho a variavel de log
					//===========================
					cLog += "   >> SUPERVISOR: " + aVendedores[nX][1] + " - " + SA3->A3_NOME

					// chamo o processamento de commissao de supervisores
					ComGerenteSupervisor( @oProcess, @cLog, 4, cVendDe, cVendAt, dDataDe, dDataAt, cTrbTipo, cTrbDetalhes, @oBrowseTipo,;
						@oBrowseDetalhes, aVendedores[nX][1], @aDadosTipo, @aDadosDetalhes, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun )

					// verifico se e gerente
				ElseIf SA3->A3_XFUNCAO == "G"

					// atualizo o objeto de processamento
					oProcess:IncRegua1("GERENTE: " 		+ aVendedores[nX,1] + " - " + SA3->A3_NOME )

					//===========================
					// prencho a variavel de log
					//===========================
					cLog += "   >> GERENTE: " + aVendedores[nX,1] + " - " + SA3->A3_NOME

					// chamo o processamento de commissao de gerentes
					ComGerenteSupervisor( @oProcess, @cLog, 5, cVendDe, cVendAt, dDataDe, dDataAt, cTrbTipo, cTrbDetalhes, @oBrowseTipo,;
						@oBrowseDetalhes, aVendedores[nX][1], @aDadosTipo, @aDadosDetalhes, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun )

				EndIf

			ElseIf nOpc	== 2		// vendedor

				// atualizo o objeto de processamento
				oProcess:IncRegua1("VENDEDOR: " 	+ aVendedores[nX,1] + " - " + SA3->A3_NOME )

				//===========================
				// prencho a variavel de log
				//===========================
				cLog += "   >> VENDEDOR: " + aVendedores[nX,1] + " - " + SA3->A3_NOME

				// chamo o processamento de commissao de vendedores
				ComVendedor( @oProcess, @cLog, nOpc, aVendedores[nX,1], dDataDe, dDataAt, cTrbTipo, cTrbDetalhes, @oBrowseTipo,;
					@oBrowseDetalhes, @aDadosTipo, @aDadosDetalhes, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun )

			ElseIf nOpc	== 3 	// cobrador

				// atualizo o objeto de processamento
				oProcess:IncRegua1("COBRADOR: "		+ aVendedores[nX,1] + " - " + SA3->A3_NOME )

				//===========================
				// prencho a variavel de log
				//===========================
				cLog += "   >> COBRADOR: " + aVendedores[nX,1] + " - " + SA3->A3_NOME

				// chamo o processamento de commissao de cobradores
				ComCobrador( @oProcess, @cLog, nOpc, aVendedores[nX,1], dDataDe, dDataAt, cTrbTipo, cTrbDetalhes, @oBrowseTipo,;
					@oBrowseDetalhes, @aDadosTipo, @aDadosDetalhes, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun )

			ElseIf nOpc == 4		// supervisor

				// atualizo o objeto de processamento
				oProcess:IncRegua1("SUPERVISOR: " 	+ aVendedores[nX,1] + " - " + SA3->A3_NOME )

				//===========================
				// prencho a variavel de log
				//===========================
				cLog += "   >> SUPERVISOR: " + aVendedores[nX][1] + " - " + SA3->A3_NOME

				// chamo o processamento de commissao de supervisores
				ComGerenteSupervisor( @oProcess, @cLog, 4, cVendDe, cVendAt, dDataDe, dDataAt, cTrbTipo, cTrbDetalhes, @oBrowseTipo,;
					@oBrowseDetalhes, aVendedores[nX][1], @aDadosTipo, @aDadosDetalhes, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun  )

			ElseIf nOpc == 5		// gerente

				// atualizo o objeto de processamento
				oProcess:IncRegua1("GERENTE: " 		+ aVendedores[nX,1] + " - " + SA3->A3_NOME )

				//===========================
				// prencho a variavel de log
				//===========================
				cLog += "   >> GERENTE: " + aVendedores[nX,1] + " - " + SA3->A3_NOME

				// chamo o processamento de commissao de gerentes
				ComGerenteSupervisor( @oProcess, @cLog, 5, cVendDe, cVendAt, dDataDe, dDataAt, cTrbTipo, cTrbDetalhes, @oBrowseTipo,;
					@oBrowseDetalhes, aVendedores[nX][1], @aDadosTipo, @aDadosDetalhes, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun )

			EndIf

		Else

			cLog += CRLF
			cLog += "  >> Vendedor " + aVendedores[nX,1] + " não encontrado!"
			cLog += CRLF

		EndIf

	Next nX

// vou popular a tabela de dados - tipo
	If Len( aDadosTipo ) > 0

		CriaTabTipo(cTrbTipo, @oTempTipo)

		// chama a funcao para gravar os registros de tipo
		GeraRegistros( aDadosTipo, cTrbTipo, /*lGeraDados*/, @oBrowseTipo, @oBrowseDetalhes )

		// vou popular a tabela de dados - detalhes
		If Len( aDadosDetalhes ) > 0

			CriaTabDetalhes(cTrbDetalhes, @oTempDetalhes)

			GeraRegistros( aDadosDetalhes, cTrbDetalhes, /*lGeraDados*/, @oBrowseTipo, @oBrowseDetalhes )
		EndIf

	EndIf

	RestArea(aAreaSA3)
	RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} RetVendedores
Retorna o array com os codigos dos gerentes/supervisores e subordinados
aVendedores
	{"XXXXXX",{"","","",...}}
	{"XXXXXX",{"","","",...}}
	...
@author g.sampaio
@since 13/06/2019
@version P12
@param cLog
@return nulo
/*/

Static Function RetVendedores( cLog, nOpc, cVendDe, cVendAt, dDataDe, dDataAt )

	Local aRetorno	 	:= {}
	Local cQuery 		:= ""

	Default cLog		:= ""
	Default nOpc		:= 0
	Default cVendDe		:= ""
	Default cVendAt 	:= ""
	Default dDataDe		:= StoD("")
	Default dDataAt		:= StoD("")

//===========================
// prencho a variavel de log
//===========================

	If nOpc == 2 		// vendedor
		cLog += "  >> SELEÇÃO DOS VENDEDORES..." + CRLF
	ElseIf nOpc == 3	// cobrador
		cLog += "  >> SELEÇÃO DOS COBRADORES..." + CRLF
	ElseIf nOpc == 4	// supervisor
		cLog += "  >> SELEÇÃO DOS SUPERVISORES..." + CRLF
	ElseIf nOpc == 5	// gerente
		cLog += "  >> SELEÇÃO DOS GERENTES..." + CRLF
	Else
		cLog += " >> SELEÇÃO DE REGISTROS DE VENDEDORES..."
	EndIf

//===========================
// Preencho a Query
//===========================

	If Select("QRYSA3") > 0
		QRYSA3->(DbCloseArea())
	EndIf

//===========================================
// prencho a query de consulta de vendedores
//===========================================

	cQuery := " SELECT SA3.A3_COD AS A3_COD" + CRLF
	cQuery += " FROM " + RetSqlName("SA3") + " SA3" + CRLF
	cQuery += " WHERE" + CRLF
	cQuery += " SA3.D_E_L_E_T_ <> '*'" + CRLF
	cQuery += " AND SA3.A3_FILIAL = '" + xFilial("SA3") + "'" + CRLF
	cQuery += " AND SA3.A3_COD BETWEEN '" + cVendDe + "' AND '" + cVendAt + "'" + CRLF
	cQuery += " AND SA3.A3_MSBLQL <> '1' " + CRLF
	cQuery += " AND SA3.A3_XFUNCAO <> '' " + CRLF

	If nOpc == 2 	// vendedor
		cQuery += " AND SA3.A3_XFUNCAO = 'V' " + CRLF
	ElseIf nOpc == 3	// cobrador
		cQuery += " AND SA3.A3_XFUNCAO = 'C' " + CRLF
	ElseIf nOpc == 4	// supervisor
		cQuery += " AND SA3.A3_XFUNCAO = 'S' " + CRLF
	ElseIf nOpc == 5	// gerente
		cQuery += " AND SA3.A3_XFUNCAO = 'G' " + CRLF
	EndIf

	cQuery += " ORDER BY SA3.A3_COD" + CRLF

	//===========================
	// prencho a variavel de log
	//===========================

	cLog += CRLF

	cLog += " >> QUERY: "

	cLog += CRLF
	cLog += CRLF

	cLog += cQuery // coloco a query na log

	cLog += CRLF
	cLog += CRLF

	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias "QRYSA3" // Cria uma nova area com o resultado do query

	QRYSA3->(dbGoTop())
	While QRYSA3->(!Eof())

		aadd(aRetorno, {QRYSA3->A3_COD})
		QRYSA3->(dbSkip())
	EndDo

	If Select("QRYSA3") > 0
		QRYSA3->(DbCloseArea())
	EndIf

Return(aRetorno)

/*/{Protheus.doc} ComGerenteSupervisor
Gera registros de comissao para Gerentes e Supervisores
@author g.sampaio
@since 13/06/2019
@version P12
@param cLog
@return nulo
/*/

Static Function ComGerenteSupervisor( oProcess, cLog, nOpc, cVendDe, cVendAt, dDataDe, dDataAt,;
		cTrbTipo, cTrbDetalhes, oBrowseTipo, oBrowseDetalhes, cCodVendedor, aDadosTipo, aDadosDetalhes,;
		cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun )

	Local aArea				:= GetArea()
	Local aAreaSA3			:= SA3->( GetArea() )
	Local aAuxTipo			:= {}
	Local aAuxDetalhes		:= {}
	Local aSubordinados		:= {}
	Local cVendSub			:= ""
	Local cLstVend			:= ""
	Local cNomeVendedor		:= ""
	Local lFuneraria	    := SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	    := SuperGetMV("MV_XCEMI",,.F.)
	Local nCountSA3			:= 0
	Local nTotDetBase 		:= 0
	Local nTotDetComis 		:= 0
	Local nTotDetPorc		:= 0
	Local nTotTipBase 		:= 0
	Local nTotTipComis 		:= 0
	Local nTotTipPorc		:= 0
	Local nPerVend			:= 0
	Local nY				:= 0
	Local nConta 			:= 0
	Local nTotQtdCtr		:= 0

	Default cLog			:= ""
	Default nOpc			:= 0
	Default cVendDe			:= ""
	Default cVendAt			:= ""
	Default dDataDe			:= ""
	Default dDataAt			:= ""
	Default cTrbTipo		:= ""
	Default cTrbDetalhes	:= ""
	Default cCodVendedor	:= ""
	Default aDadosTipo		:= {}
	Default aDadosDetalhes	:= {}
	Default cPrefCtr		:= ""
	Default cTipoCtr		:= ""
	Default cTipoEnt	 	:= ""
	Default cPrefFun	 	:= ""
	Default cTipoFun 		:= ""

//===========================
// prencho a variavel de log
//===========================
	cLog += CRLF
	cLog += "  >> Função ComGerenteSupervisor
	cLog += CRLF

// posiciono no registro do vendedor
	SA3->( DbSetOrder(1) )
	If SA3->( MsSeek( xFilial("SA3")+cCodVendedor ) )

		// percentual de comissao
		nPerVend := SA3->A3_COMIS

		// nome do vendedor
		cNomeVendedor := SA3->A3_NOME

		// subordinados de gerentes/supervisores
		aSubordinados := RetSubordinados( cCodVendedor, cLog, nOpc )

	EndIf
	// lista de vendedores
	cLstVend := ""

	// vou percorre o array de subordinados de gerentes/supervisores
	For nY := 1 to Len(aSubordinados)

		// verifico se a variavel esta vazia
		If Empty(cLstVend)

			cLstVend += "'" + aSubordinados[nY,1] + "'"

		Else

			cLstVend += ", '" + aSubordinados[nY,1] + "'"

		EndIf

	Next nY

//==============================
// VENDA DIRETA: SL1, SL2 e SB1
//==============================

// verifico se o alias esta em uso
	If Select("QRYSL1") > 0

		QRYSL1->(DbCloseArea())

	EndIf

//===========================
// prencho a variavel de log
//===========================
	cLog += CRLF
	cLog += "   >> SELEÇÃO DAS COMISSOES DE VENDAS AVULSAS (VENDA DIRETA) DOS VENDEDORES RELACIONADOS... " + CRLF

//===========================================================================
// prencho a query de consulta de commissoes do venda direta: SL1, SL2 e SB1
//===========================================================================

	cQuery := "SELECT SL1.*, SL2.*, SB1.*" + CRLF
	cQuery += " FROM " + RetSqlName("SL1") + " SL1" + CRLF
	cQuery += " INNER JOIN" + CRLF
	cQuery += " " + RetSqlName("SL2") + " SL2 ON (SL1.L1_FILIAL = SL2.L2_FILIAL AND SL1.L1_NUM = SL2.L2_NUM AND SL2.D_E_L_E_T_ <> '*')" + CRLF
	cQuery += " INNER JOIN" + CRLF
	cQuery += " " + RetSqlName("SB1") + " SB1 ON (SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SL2.L2_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ <> '*')" + CRLF
	cQuery += " WHERE" + CRLF
	cQuery += " SL1.D_E_L_E_T_ <> '*'" + CRLF

// verifico se montou a lista de subordinados
	If !Empty( cLstVend )
		cQuery += " AND SL1.L1_VEND IN (" + cLstVend + ")" + CRLF
	EndIf

	cQuery += " AND SL1.L1_EMISNF <> ''" + CRLF
	cQuery += " AND SL1.L1_EMISNF BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAt) + "'" + CRLF
	cQuery += " AND SB1.B1_XCOMISS = 'S'" + CRLF
	cQuery += " ORDER BY SL1.L1_FILIAL, SL1.L1_VEND, SL1.L1_NUM, SL1.L1_DOC, SL1.L1_SERIE, SL2.L2_ITEM" + CRLF

//===========================
// prencho a variavel de log
//===========================
	cLog += CRLF

	cLog += " >> QUERY: "

	cLog += CRLF
	cLog += CRLF

	cLog += cQuery // preencho a query na log

	cLog += CRLF
	cLog += CRLF

	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias "QRYSL1" // Cria uma nova area com o resultado do query

// limpo o vendedor subordinado
	cVendSub := ""

// vou alimentar a variavel contadora
	QRYSL1->(dbEval({|| nCountSA3++}))
	QRYSL1->(dbGoTop())

	oProcess:SetRegua2(nCountSA3)

// percorro o alias
	While QRYSL1->(!Eof())

		// incremento a variavel de contadora
		nConta++

		If lEnd	//houve cancelamento do processo
			Exit
		EndIf

		oProcess:IncRegua2("Processando os Registros de Venda Direta/Assistida...")

		// verifico se altero o conteudo da variavel de vendedor subordinado
		If cVendSub <> QRYSL1->L1_VEND

			//===========================
			// prencho a variavel de log
			//===========================

			cLog += CRLF
			cLog += "    >> VENDEDOR: " + QRYSL1->L1_VEND + " - " + Posicione("SA3",1,xFilial("SA3")+QRYSL1->L1_VEND,"A3_NOME")

			// alimento o vendedor subordinado
			cVendSub := QRYSL1->L1_VEND

		EndIf

		//===========================
		// prencho a variavel de log
		//===========================

		//>>> PRODUTO - DESCRICAO - QTD - VLR UNIT - VLR TOTAL - % COMISSAO - VALOR COMISSAO
		cLog += CRLF
		cLog += "     >> ORCAMENTO: 		" + QRYSL1->L1_NUM + CRLF
		cLog += "     >> PRODUTO: 			" + QRYSL1->L2_PRODUTO + CRLF
		cLog += "     >> DESCRICAO: 		" + QRYSL1->L2_DESCRI + CRLF
		cLog += "     >> QUANTIDADE: 		" + Transform(QRYSL1->L2_QUANT,"@E 9,999,999,999,999.99") + CRLF
		cLog += "     >> VALOR UNITARIA: 	" + Transform(QRYSL1->L2_VRUNIT,"@E 9,999,999,999,999.99") + CRLF
		cLog += "     >> VALOR TOTAL: 		" + Transform(QRYSL1->L2_VLRITEM,"@E 9,999,999,999,999.99") + CRLF
		cLog += "     >> % COMISSAO: 		" + Transform(nPerVend,"@E 999.99") + CRLF
		cLog += "     >> VLR COMISSAO: 		" + Transform(QRYSL1->L2_VLRITEM * (nPerVend/100),"@E 9,999,999,999,999.99") + CRLF

		// alimento as variaveis totalizadoras dos detalhes
		nTotDetBase  += QRYSL1->L2_VLRITEM						// base
		nTotDetComis += QRYSL1->L2_VLRITEM * (nPerVend/100)		// comissao

		//====================================
		// vou alimentar os dados da comissao
		//====================================

		aAuxDetalhes := {}
		//Aadd(aAuxDetalhes,{"TR_ITEM" 	, StrZero( nConta, 3 ) 											})
		Aadd(aAuxDetalhes,{"TR_ORIGEM" 	, OrigemRotina("V")												})
		Aadd(aAuxDetalhes,{"TR_CODIGO" 	, QRYSL1->L1_NUM												})
		Aadd(aAuxDetalhes,{"TR_DTCOMI" 	, StoD(QRYSL1->L1_EMISNF) 										})
		Aadd(aAuxDetalhes,{"TR_VEND" 	, QRYSL1->L1_VEND												})
		Aadd(aAuxDetalhes,{"TR_NOME"	, Posicione("SA3",1,xFilial("SA3")+QRYSL1->L1_VEND,"A3_NOME")	})
		Aadd(aAuxDetalhes,{"TR_PRODUT"	, QRYSL1->L2_PRODUTO 											})
		Aadd(aAuxDetalhes,{"TR_DSCPRO"	, QRYSL1->L2_DESCRI												})
		Aadd(aAuxDetalhes,{"TR_QTDPV"	, QRYSL1->L2_QUANT												})
		Aadd(aAuxDetalhes,{"TR_PRCPV"	, QRYSL1->L2_VRUNIT												})
		Aadd(aAuxDetalhes,{"TR_BASE"	, QRYSL1->L2_VLRITEM											})
		Aadd(aAuxDetalhes,{"TR_PORC"	, nPerVend														})
		Aadd(aAuxDetalhes,{"TR_COMIS"	, QRYSL1->L2_VLRITEM * (nPerVend/100)							})
		Aadd(aAuxDetalhes,{"TR_HIST"	, "COMISSOES DE VENDAS AVULSAS (VENDA DIRETA)"					})
		Aadd(aAuxDetalhes,{"TR_RELAC"	, cCodVendedor													})

		// alimento o array de comissoes
		Aadd( aDadosDetalhes,  aAuxDetalhes)

		// pego o total de contratos do vendedor
		nTotQtdCtr++

		QRYSL1->(dbSkip())
	EndDo

// pego o total de percentual
	nTotDetPorc	:= NoRound((nTotDetComis/nTotDetBase)*100,2)

//===========================
// prencho a variavel de log
//===========================

	cLog += CRLF
	cLog += "     >> TOTAIS COMISSOES VENDAS AVULSAS (VENDA DIRETA)" + CRLF
	cLog += "     >> BASE COMISSÃO: " + Transform(nTotDetBase,"@E 9,999,999,999,999.99") + CRLF
	cLog += "     >> % COMISSAO: 	" + Transform(nTotDetPorc,"@E 999.99") + CRLF
	cLog += "     >> VLR COMISSÃO: 	" + Transform(nTotDetComis,"@E 9,999,999,999,999.99") + CRLF
	cLog += CRLF

// verifico se o alias esta em uso
	If Select("QRYSL1") > 0

		QRYSL1->(DbCloseArea())

	EndIf

// incremento os totalizadores do tipo gerente/supervisor
	nTotTipBase 	+= nTotDetBase
	nTotTipComis 	+= nTotDetComis
//nTotTipPorc		:= NoRound((nTotTipComis/nTotTipBase)*100,2)

// zero as variaveis de comissao
	nTotDetBase 	:= 0
	nTotDetComis 	:= 0
	nTotDetPorc		:= 0

//===================================
//	PEDIDO DE VENDA: SC5, SC6 e SB1
//===================================

	If Select("QRYSC5") > 0

		QRYSC5->(DbCloseArea())

	EndIf

//===========================
// prencho a variavel de log
//===========================

	cLog += CRLF
	cLog += "   >> SELEÇÃO DAS COMISSOES DE VENDAS AVULSAS (PEDIDO DE VENDA : SC5, SC6 e SB1 ) DOS VENDEDORES RELACIONADOS... " + CRLF

//===========================================================================
// prencho a query de consulta de commissoes de pedido de vedas
//===========================================================================

	cQuery := "SELECT SC5.*, SC6.*, SB1.*" + CRLF
	cQuery += " FROM " + RetSqlName("SC5") + " SC5" + CRLF
	cQuery += " INNER JOIN" + CRLF
	cQuery += " " + RetSqlName("SC6") + " SC6 ON (SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM AND SC6.D_E_L_E_T_ <> '*')" + CRLF
	cQuery += " INNER JOIN" + CRLF
	cQuery += " " + RetSqlName("SB1") + "  SB1 ON (SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SC6.C6_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ <> '*')" + CRLF
	cQuery += " WHERE" + CRLF
	cQuery += " SC5.D_E_L_E_T_ <> '*'" + CRLF

	If !Empty( cLstVend )
		cQuery += " AND SC5.C5_VEND1 IN (" + cLstVend + ")" + CRLF
	EndIf

	cQuery += " AND SC5.C5_XCONTRA = ''" + CRLF
	cQuery += " AND SC5.C5_XCTRFUN = ''" + CRLF
	cQuery += " AND SC6.C6_NOTA <> ''" + CRLF
	cQuery += " AND SC6.C6_DATFAT BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAt) + "'" + CRLF
	cQuery += " AND SB1.B1_XCOMISS = 'S'" + CRLF
	cQuery += " ORDER BY SC5.C5_FILIAL, SC5.C5_VEND1, SC6.C6_NOTA, SC6.C6_SERIE, SC6.C6_ITEM" + CRLF

//===========================
// prencho a variavel de log
//===========================

	cLog += CRLF

	cLog += " >> QUERY: "

	cLog += CRLF
	cLog += CRLF

	cLog += cQuery // adiciono a query na log

	cLog += CRLF
	cLog += CRLF

	cQuery := ChangeQuery(cQuery)
	TcQuery cQuery New Alias "QRYSC5" // Cria uma nova area com o resultado do query

// zero a variavel de vendedores
	cVends := ""

// alimento a variavell contadora
	QRYSC5->(dbEval({|| nCountSA3++}))
	QRYSC5->(dbGoTop())

	oProcess:SetRegua2(nCountSA3)

	While QRYSC5->(!Eof())

		// incremento a variavel de contadora
		nConta++

		If lEnd	//houve cancelamento do processo
			Exit
		EndIf

		oProcess:IncRegua2("Processando os pedidos de vendas do vendedor...")

		// verifico se preciso trocar o conteudo do vendedor atik
		If cVends <> QRYSC5->C5_VEND1

			//===========================
			// prencho a variavel de log
			//===========================

			cLog += CRLF
			cLog += "    >> VENDEDOR: " + QRYSC5->C5_VEND1 + " - " + Posicione("SA3",1,xFilial("SA3")+QRYSC5->C5_VEND1,"A3_NOME") + CRLF

			// atualizo o conteudo do vendedor
			cVends := QRYSC5->C5_VEND1
		EndIf

		//===========================
		// prencho a variavel de log
		//===========================

		//>>> PRODUTO - DESCRICAO - QTD - VLR UNIT - VLR TOTAL - % COMISSAO - VALOR COMISSAO
		cLog += CRLF
		cLog += "     >> PEDIDO DE VENDA: 	" + QRYSC5->C5_NUM + CRLF
		cLog += "     >> PRODUTO: 			" + QRYSC5->C6_PRODUTO + CRLF
		cLog += "     >> DESCRICAO: 		" + QRYSC5->C6_DESCRI + CRLF
		cLog += "     >> QUANTIDADE: 		" + Transform(QRYSC5->C6_QTDVEN,"@E 9,999,999,999,999.99") + CRLF
		cLog += "     >> VALOR UNITARIA: 	" + Transform(QRYSC5->C6_PRCVEN,"@E 9,999,999,999,999.99") + CRLF
		cLog += "     >> VALOR TOTAL: 		" + Transform(QRYSC5->C6_VALOR,"@E 9,999,999,999,999.99") + CRLF
		cLog += "     >> % COMISSAO: 		" + Transform(nPerVend,"@E 999.99") + CRLF
		cLog += "     >> VLR COMISSAO: 		" + Transform(QRYSC5->C6_VALOR * (nPerVend/100),"@E 9,999,999,999,999.99") + CRLF

		// alimento as variaveis totalizadoras dos detalhes
		nTotDetBase 	+= QRYSC5->C6_VALOR						// base
		nTotDetComis 	+= QRYSC5->C6_VALOR * (nPerVend/100)	// comissao

		//====================================
		// vou alimentar os dados da comissao
		//====================================

		aAuxDetalhes := {}
		//Aadd(aAuxDetalhes,{"TR_ITEM" 	, StrZero( nConta, 3 ) 											})
		Aadd(aAuxDetalhes,{"TR_ORIGEM" 	, OrigemRotina("P")												})
		Aadd(aAuxDetalhes,{"TR_CODIGO" 	, QRYSC5->C5_NUM												})
		Aadd(aAuxDetalhes,{"TR_DTCOMI" 	, StoD(QRYSC5->C6_DATFAT) 										})
		Aadd(aAuxDetalhes,{"TR_VEND" 	, QRYSC5->C5_VEND1												})
		Aadd(aAuxDetalhes,{"TR_NOME"	, Posicione("SA3",1,xFilial("SA3")+QRYSC5->C5_VEND1,"A3_NOME")	})
		Aadd(aAuxDetalhes,{"TR_PRODUT"	, QRYSC5->C6_PRODUTO											})
		Aadd(aAuxDetalhes,{"TR_DSCPRO"	, QRYSC5->C6_DESCRI												})
		Aadd(aAuxDetalhes,{"TR_QTDPV"	, QRYSC5->C6_QTDVEN												})
		Aadd(aAuxDetalhes,{"TR_PRCPV"	, QRYSC5->C6_PRCVEN												})
		Aadd(aAuxDetalhes,{"TR_BASE"	, QRYSC5->C6_VALOR												})
		Aadd(aAuxDetalhes,{"TR_PORC"	, nPerVend														})
		Aadd(aAuxDetalhes,{"TR_COMIS"	, QRYSC5->C6_VALOR * (nPerVend/100)								})
		Aadd(aAuxDetalhes,{"TR_HIST"	, "COMISSOES DE VENDAS AVULSAS (PEDIDO DE VENDA)"				})
		Aadd(aAuxDetalhes,{"TR_RELAC"	, cCodVendedor													})

		// alimento o array de comissoes
		Aadd( aDadosDetalhes,  aAuxDetalhes)

		// pego o total de contratos do vendedor
		nTotQtdCtr++

		QRYSC5->(dbSkip())
	EndDo

// alimento o toal de percentual de comissao
	nTotDetPorc	:= NoRound((nTotDetComis/nTotDetBase)*100,2)

//===========================
// prencho a variavel de log
//===========================

	cLog += CRLF
	cLog += "     >> TOTAIS COMISSOES DE VENDAS AVULSAS (PEDIDO DE VENDA)" + CRLF
	cLog += "     >> BASE COMISSÃO	: 	" + Transform(nTotDetBase,"@E 9,999,999,999,999.99") + CRLF
	cLog += "     >> % COMISSAO		: 	" + Transform(nTotDetPorc,"@E 999.99") + CRLF
	cLog += "     >> VLR COMISSÃO	: 	" + Transform(nTotDetComis,"@E 9,999,999,999,999.99") + CRLF
	cLog += CRLF

// verifico se o alias esta em uso
	If Select("QRYSC5") > 0

		QRYSC5->(DbCloseArea())

	EndIf

// incremento os totalizadores do tipo gerente/supervisor
	nTotTipBase 	+= nTotDetBase
	nTotTipComis 	+= nTotDetComis
//nTotTipPorc		:= NoRound((nTotTipComis/nTotTipBase)*100,2)

// zero as variaveis de comissao
	nTotDetBase 	:= 0
	nTotDetComis 	:= 0
	nTotDetPorc		:= 0

//===================================
//	CONTRATO CEMITERIO: U00, U05
//===================================
	if lCemiterio

		// verifico se o alias esta em uso
		If Select("QRYU00") > 0

			QRYU00->(DbCloseArea())

		EndIf

//===========================
// prencho a variavel de log
//===========================

		cLog += CRLF
		cLog += "   >> SELEÇÃO DAS COMISSOES DE CONTRATOS (CEMITERIO : U00, U05 ) DOS VENDEDORES RELACIONADOS... " + CRLF

//===========================================================================
// prencho a query de consulta de commissoes de contratos cemiterio
//===========================================================================

		cQuery := "SELECT U00.*, U05.*" + CRLF
		cQuery += " FROM " + RetSqlName("U00") + " U00" + CRLF
		cQuery += " INNER JOIN" + CRLF
		cQuery += " " + RetSqlName("U05") + " U05 ON (U05.U05_FILIAL = '" + xFilial("U05") + "' AND U00.U00_PLANO = U05.U05_CODIGO AND U05.D_E_L_E_T_ <> '*')" + CRLF
		cQuery += " WHERE" + CRLF
		cQuery += " U00.D_E_L_E_T_ = ' '" + CRLF
		cQuery += " AND U00.U00_FILIAL = '" + xFilial("U00") + "' "

		If !Empty( cLstVend )
			cQuery += " AND U00.U00_VENDED IN (" + cLstVend + ")" + CRLF
		EndIf

		cQuery += " AND U00.U00_STATUS IN ('A','F')" + CRLF
		cQuery += " AND U00.U00_DTATIV <> ''" + CRLF
		cQuery += " AND U00.U00_DTATIV BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAt) + "'" + CRLF
		cQuery += " AND U05.U05_COMISS = 'S'" + CRLF
		cQuery += " ORDER BY U00.U00_FILIAL, U00.U00_VENDED, U00.U00_CODIGO" + CRLF

//===========================
// prencho a variavel de log
//===========================

		cLog += CRLF

		cLog += " >> QUERY: "

		cLog += CRLF
		cLog += CRLF

		cLog += cQuery // adiciono a query na log

		cLog += CRLF
		cLog += CRLF

		cQuery := ChangeQuery(cQuery)
		TcQuery cQuery New Alias "QRYU00" // Cria uma nova area com o resultado do query

// zero a variavel de vendedor
		cVends := ""

// alimento a variavell contadora
		QRYU00->(dbEval({|| nCountSA3++}))
		QRYU00->(dbGoTop())

		oProcess:SetRegua2(nCountSA3)

		While QRYU00->(!Eof())

			nConta++

			If lEnd	//houve cancelamento do processo
				Exit
			EndIf

			oProcess:IncRegua2("Processando os contratos do Módulo de Cemitério...")

			// verifico se atualizo o conteudo da variavel de vendedor
			If cVends <> QRYU00->U00_VENDED

				//===========================
				// prencho a variavel de log
				//===========================

				cLog += CRLF
				cLog += "    >> VENDEDOR: " + QRYU00->U00_VENDED + " - " + Posicione("SA3",1,xFilial("SA3")+QRYU00->U00_VENDED,"A3_NOME") + CRLF

				// atualizo o valor da variavel de vendedor
				cVends := QRYU00->U00_VENDED

			EndIf

			//===========================
			// prencho a variavel de log
			//===========================

			//>>> PRODUTO - DESCRICAO - QTD - VLR UNIT - VLR TOTAL - % COMISSAO - VALOR COMISSAO
			cLog += CRLF
			cLog += "     >> CONTRATO: 		" + QRYU00->U00_CODIGO + CRLF
			cLog += "     >> PLANO:		 	" + QRYU00->U00_PLANO + CRLF
			cLog += "     >> DESCRICAO: 	" + QRYU00->U05_DESCRI + CRLF
			cLog += "     >> VALOR TOTAL: 	" + Transform(QRYU00->U00_VALOR,"@E 9,999,999,999,999.99") + CRLF
			cLog += "     >> % COMISSAO: 	" + Transform(nPerVend,"@E 999.99") + CRLF
			cLog += "     >> VLR COMISSAO: 	" + Transform(QRYU00->U00_VALOR * (nPerVend/100),"@E 9,999,999,999,999.99") + CRLF

			// alimento as variaveis totalizadoras dos detalhes
			nTotDetBase 	+= QRYU00->U00_VALOR
			nTotDetComis 	+= QRYU00->U00_VALOR * (nPerVend/100)

			//====================================
			// vou alimentar os dados da comissao
			//====================================

			aAuxDetalhes := {}
			//Aadd(aAuxDetalhes,{"TR_ITEM" 	, StrZero( nConta, 3 ) 												})
			Aadd(aAuxDetalhes,{"TR_ORIGEM" 	, OrigemRotina("C")													})
			Aadd(aAuxDetalhes,{"TR_CODIGO" 	, QRYU00->U00_CODIGO												})
			Aadd(aAuxDetalhes,{"TR_DTCOMI" 	, StoD(QRYU00->U00_DTATIV) 											})
			Aadd(aAuxDetalhes,{"TR_VEND" 	, QRYU00->U00_VENDED												})
			Aadd(aAuxDetalhes,{"TR_NOME"	, Posicione("SA3",1,xFilial("SA3")+QRYU00->U00_VENDED,"A3_NOME")	})
			Aadd(aAuxDetalhes,{"TR_PRODUT"	, QRYU00->U00_PLANO													})
			Aadd(aAuxDetalhes,{"TR_DSCPRO"	, QRYU00->U05_DESCRI												})
			Aadd(aAuxDetalhes,{"TR_QTDPV"	, 1																	})
			Aadd(aAuxDetalhes,{"TR_PRCPV"	, QRYU00->U00_VALOR													})
			Aadd(aAuxDetalhes,{"TR_BASE"	, QRYU00->U00_VALOR													})
			Aadd(aAuxDetalhes,{"TR_PORC"	, nPerVend															})
			Aadd(aAuxDetalhes,{"TR_COMIS"	, QRYU00->U00_VALOR * (nPerVend/100)								})
			Aadd(aAuxDetalhes,{"TR_HIST"	, "COMISSOES DE CONTRATOS (CEMITERIO)"								})
			Aadd(aAuxDetalhes,{"TR_RELAC"	, cCodVendedor													})

			// alimento o array de comissoes
			Aadd( aDadosDetalhes,  aAuxDetalhes)

			// pego o total de contratos do vendedor
			nTotQtdCtr++

			QRYU00->(dbSkip())
		EndDo

// alimento o total de percentual de comissao
		nTotDetPorc	:= NoRound((nTotDetComis/nTotDetBase)*100,2)

//===========================
// prencho a variavel de log
//===========================

		cLog += CRLF
		cLog += "     >> TOTAIS COMISSOES DE CONTRATOS (CEMITERIO)" + CRLF
		cLog += "     >> BASE COMISSÃO: " + Transform(nTotDetBase,"@E 9,999,999,999,999.99") + CRLF
		cLog += "     >> % COMISSAO: 	" + Transform(nTotDetPorc,"@E 999.99") + CRLF
		cLog += "     >> VLR COMISSÃO: 	" + Transform(nTotDetComis,"@E 9,999,999,999,999.99") + CRLF
		cLog += CRLF

// verifico se o alias esta em uso
		If Select("QRYU00") > 0

			QRYU00->(DbCloseArea())

		EndIf

// incremento os totalizadores do tipo gerente/supervisor
		nTotTipBase 	+= nTotDetBase
		nTotTipComis 	+= nTotDetComis
//nTotTipPorc		:= NoRound((nTotTipComis/nTotTipBase)*100,2)

	endIf

// zero as variaveis de comissao
	nTotDetBase 	:= 0
	nTotDetComis 	:= 0
	nTotDetPorc		:= 0

//===================================
//	CONTRATO FUNERARIA: UF2, UF0
//===================================
	if lFuneraria

// verifico se o alias esta em uso
		If Select("QRYUF2") > 0

			QRYUF2->(DbCloseArea())

		EndIf

//===========================
// prencho a variavel de log
//===========================

		cLog += CRLF
		cLog += "   >> SELEÇÃO DAS COMISSOES DE CONTRATOS (FUNERARIOS: UF2, UF0) DOS VENDEDORES RELACIONADOS... " + CRLF

//===========================================================================
// prencho a query de consulta de commissoes de contratos cemiterio
//===========================================================================

		cQuery := "SELECT UF2.*, UF0.*" + CRLF
		cQuery += " FROM " + RetSqlName("UF2") + " UF2" + CRLF
		cQuery += " INNER JOIN" + CRLF
		cQuery += " " + RetSqlName("UF0") + " UF0 ON (UF2.UF2_FILIAL = UF0.UF0_FILIAL AND UF2.UF2_PLANO = UF0.UF0_CODIGO AND UF0.D_E_L_E_T_ <> '*')" + CRLF
		cQuery += " WHERE" + CRLF
		cQuery += " UF2.D_E_L_E_T_ <> '*'" + CRLF
		cQuery += " AND UF2.UF2_FILIAL = '" + xFilial("UF2") + "' " + CRLF

		If !Empty( cLstVend )
			cQuery += " AND UF2.UF2_VEND IN (" + cLstVend + ")" + CRLF
		EndIf

		cQuery += " AND UF2.UF2_DTATIV <> ''" + CRLF
		cQuery += " AND UF2.UF2_DTATIV BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAt) + "'" + CRLF
		cQuery += " AND UF2.UF2_STATUS IN ('A','F')" + CRLF
		cQuery += " AND UF0.UF0_COMISS = 'S'" + CRLF
		cQuery += " ORDER BY UF2.UF2_FILIAL, UF2.UF2_VEND, UF2.UF2_CODIGO" + CRLF

//===========================
// prencho a variavel de log
//===========================

		cLog += CRLF
		cLog += " >> QUERY: "

		cLog += CRLF
		cLog += CRLF

		cLog += cQuery // coloco a query na log

		cLog += CRLF
		cLog += CRLF

		cQuery := ChangeQuery(cQuery)
		TcQuery cQuery New Alias "QRYUF2" // Cria uma nova area com o resultado do query

// zero a variavel de vendedores
		cVends := ""

// 
		QRYUF2->( dbEval({|| nCountSA3++} ))
		QRYUF2->( DbGoTop() )

		oProcess:SetRegua2(nCountSA3)

		While QRYUF2->(!Eof())

			If lEnd	//houve cancelamento do processo
				Exit
			EndIf

			oProcess:IncRegua2("Processando os contratos do módulo de funerária...")

			If cVends <> QRYUF2->UF2_VEND
				cLog += CRLF
				cLog += "    >> VENDEDOR: " + QRYUF2->UF2_VEND + " - " + Posicione("SA3",1,xFilial("SA3")+QRYUF2->UF2_VEND,"A3_NOME") + CRLF
				cVends := QRYUF2->UF2_VEND
			EndIf

			//===========================
			// prencho a variavel de log
			//===========================

			//>>> PRODUTO - DESCRICAO - QTD - VLR UNIT - VLR TOTAL - % COMISSAO - VALOR COMISSAO
			cLog += CRLF
			cLog += "     >> CONTRATO		: " + QRYUF2->UF2_CODIGO + CRLF
			cLog += "     >> PLANO			: " + QRYUF2->UF2_PLANO + CRLF
			cLog += "     >> DESCRICAO		: " + QRYUF2->UF0_DESCRI + CRLF
			cLog += "     >> VALOR TOTAL	: " + Transform(QRYUF2->UF2_VALOR,"@E 9,999,999,999,999.99") + CRLF
			cLog += "     >> % COMISSAO		: " + Transform(nPerVend,"@E 999.99") + CRLF
			cLog += "     >> VLR COMISSAO	: " + Transform(QRYUF2->UF2_VALOR * (nPerVend/100),"@E 9,999,999,999,999.99") + CRLF

			// alimento as variaveis totalizadoras dos detalhes
			nTotDetBase 	+= QRYUF2->UF2_VALOR
			nTotDetComis 	+= QRYUF2->UF2_VALOR * (nPerVend/100)

			//====================================
			// vou alimentar os dados da comissao
			//====================================

			aAuxDetalhes := {}
			//Aadd(aAuxDetalhes,{"TR_ITEM" 	, StrZero( nConta, 3 ) 												})
			Aadd(aAuxDetalhes,{"TR_ORIGEM" 	, OrigemRotina("F")													})
			Aadd(aAuxDetalhes,{"TR_CODIGO" 	, QRYUF2->UF2_CODIGO												})
			Aadd(aAuxDetalhes,{"TR_DTCOMI" 	, StoD(QRYUF2->UF2_DTATIV) 											})
			Aadd(aAuxDetalhes,{"TR_VEND" 	, QRYUF2->UF2_VEND													})
			Aadd(aAuxDetalhes,{"TR_NOME"	, Posicione("SA3",1,xFilial("SA3")+QRYUF2->UF2_VEND,"A3_NOME")		})
			Aadd(aAuxDetalhes,{"TR_PRODUT"	, QRYUF2->UF2_PLANO													})
			Aadd(aAuxDetalhes,{"TR_DSCPRO"	, QRYUF2->UF0_DESCRI												})
			Aadd(aAuxDetalhes,{"TR_QTDPV"	, 1																	})
			Aadd(aAuxDetalhes,{"TR_PRCPV"	, QRYUF2->UF2_VALOR													})
			Aadd(aAuxDetalhes,{"TR_BASE"	, QRYUF2->UF2_VALOR													})
			Aadd(aAuxDetalhes,{"TR_PORC"	, nPerVend															})
			Aadd(aAuxDetalhes,{"TR_COMIS"	, QRYUF2->UF2_VALOR * (nPerVend/100)								})
			Aadd(aAuxDetalhes,{"TR_HIST"	, "COMISSOES DE CONTRATOS (FUNERARIA)"								})
			Aadd(aAuxDetalhes,{"TR_RELAC"	, cCodVendedor													})

			// alimento o array de comissoes
			Aadd( aDadosDetalhes,  aAuxDetalhes)

			// pego o total de contratos do vendedor
			nTotQtdCtr++

			QRYUF2->(dbSkip())
		EndDo

// alimento o total de percentual de comissao
		nTotDetPorc	:= NoRound((nTotDetComis/nTotDetBase)*100,2)

//===========================
// prencho a variavel de log
//===========================

		cLog += CRLF
		cLog += "     >> TOTAIS COMISSOES DE CONTRATOS (FUNERARIA)" + CRLF
		cLog += "     >> BASE COMISSÃO	: " + Transform(nTotDetBase,"@E 9,999,999,999,999.99") + CRLF
		cLog += "     >> % COMISSAO		: " + Transform(nTotDetPorc,"@E 999.99") + CRLF
		cLog += "     >> VLR COMISSÃO	: " + Transform(nTotDetComis,"@E 9,999,999,999,999.99") + CRLF
		cLog += CRLF

		If Select("QRYUF2") > 0
			QRYUF2->(DbCloseArea())
		EndIf

		// incremento os totalizadores do tipo gerente/supervisor
		nTotTipBase 	+= nTotDetBase
		nTotTipComis 	+= nTotDetComis
		nTotTipPorc		:= NoRound((nTotTipComis/nTotTipBase)*100,2)

	endIf

// zero as variaveis de comissao
	nTotDetBase 	:= 0
	nTotDetComis 	:= 0
	nTotDetPorc		:= 0

	// zero a variavel
	nDiaFec := 0

	//Posiciona no Cliclo e Pgto de Comissão
	U18->(dbSetOrder(1)) //U18_FILIAL+U18_CODIGO
	If U18->(MsSeek(xFilial("U18")+SA3->A3_XCICLO))
		nDiaFec := U18->U18_DIAFEC
	Else // se não houver ciclo pego o do codastro de vendedor
		nDiaFec := SA3->A3_DIA
	EndIf

	// caso o dia de fechamento por menor que zero
	If nDiaFec <= 0
		nDiaFec := Day(dDataBase)
	EndIf

	// coloco o vencimento com a database
	dE3_VENCTO := dDataBase

	If Val(Day2Str(dE3_VENCTO)) <= nDiaFec //U18->U18_DIAFEC //A3_DIA e A3_DDD (F - Fora Mes)
		dE3_VENCTO := CtoD(PADL(nDiaFec,2,"0")+"/"+Month2Str(dE3_VENCTO)+"/"+Year2Str(dE3_VENCTO))
	Else
		dE3_VENCTO := CtoD(PADL(nDiaFec,2,"0")+"/"+Month2Str(MonthSum(dE3_VENCTO,1))+"/"+Year2Str(MonthSum(dE3_VENCTO,1)))
	EndIf

	// preencho o array de dados
	aAuxTipo := {}

	// alimento as variaveis totalizadoras dos detalhes
	U_RUTILE15( "G", , cCodVendedor, nTotTipBase, @cLog, dDataBase, .F.,;
		, , .F., @nTotTipComis, @nTotTipBase, @nTotTipPorc, /*cPrefCtr*/, /*cTipoCtr*/, /*cTipoEnt*/, /*cParcTit*/, cLstVend, dDataAt )

	// verifico se tem valor base acumulado para gerar comissao
	If nTotTipBase > 0

		// para gerente
		If nOpc == 5

			Aadd( aAuxTipo, { "TR_TIPO" 	, TipoVendedor("G")			})

		ElseIf nOpc == 4 // para supervisor

			Aadd( aAuxTipo, { "TR_TIPO" 	, TipoVendedor("S")			})

		EndIf

		Aadd( aAuxTipo, { "TR_VEND" 	, cCodVendedor	})
		Aadd( aAuxTipo, { "TR_NOME"		, cNomeVendedor	})
		Aadd( aAuxTipo, { "TR_VENCTO"	, dE3_VENCTO	})
		Aadd( aAuxTipo, { "TR_QUANT"	, nTotQtdCtr	})
		Aadd( aAuxTipo, { "TR_BASE"		, nTotTipBase	})
		Aadd( aAuxTipo, { "TR_PORC"		, nTotTipPorc	})
		Aadd( aAuxTipo, { "TR_COMIS"	, nTotTipComis	})

		// preencho o array de dados
		Aadd( aDadosTipo, aAuxTipo )

	EndIf

	//===========================
	// prencho a variavel de log
	//===========================

	cLog += CRLF
	cLog += " >> TOTAIS GERAIS COMISSOES DO GERENTE	: " + cCodVendedor + " - " + cNomeVendedor + CRLF
	cLog += " >> BASE COMISSÃO						: " + Transform(nTotTipBase,"@E 9,999,999,999,999.99") + CRLF
	cLog += " >> % COMISSAO							: " + Transform(nTotTipPorc,"@E 999.99") + CRLF
	cLog += " >> VLR COMISSÃO						: " + Transform(nTotTipComis,"@E 9,999,999,999,999.99") + CRLF
	cLog += CRLF

	// zero as variaveis de comissao
	nTotTipBase 	:= 0
	nTotTipComis 	:= 0
	nTotTipPorc		:= 0

	RestArea( aAreaSA3 )
	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} ComCobrador
Gera registros de comissao para Gerentes de Cobradores
@author g.sampaio
@since 25/06/2019
@version P12
@param cLog
@return nulo
/*/

Static Function ComCobrador(  oProcess, cLog, nOpc, cCodVendedor, dDataDe, dDataAt, cTrbTipo, cTrbDetalhes, oBrowseTipo,;
		oBrowseDetalhes, aDadosTipo, aDadosDetalhes, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun )

	Local aArea				:= GetArea()
	Local aAreaSA3			:= SA3->(Getarea())
	Local aAuxDetalhes		:= {}
	Local aAuxTipo			:= {}
	Local aTmp				:= {}
	Local cQuery 			:= ""
	Local cNomeVendedor		:= ""
	Local cTmp				:= ""
	Local nCountSA3			:= 0
	Local nConta			:= 0
	Local nVlrBase			:= 0
	Local nVlrComissao		:= 0
	Local nTotDetPorc		:= 0
	Local nTotDetBase 		:= 0
	Local nTotDetComis 		:= 0
	Local nTotTipBase		:= 0
	Local nTotTipComis		:= 0
	Local nTotTipPorc		:= 0
	Local nPerVend			:= 0
	Local nI				:= 0
	Local nParcel			:= 0
	Local nTotQtdCtr		:= 0

	Default cLog 			:= ""
	Default cCodVendedor	:= ""
	Default dDataDe			:= StoD("")
	Default dDataAt			:= StoD("")
	Default cTrbTipo		:= ""
	Default cTrbDetalhes	:= ""
	Default aDadosTipo		:= {}
	Default aDadosDetalhes	:= {}
	Default cPrefCtr		:= ""
	Default cTipoCtr		:= ""
	Default cTipoEnt	 	:= ""
	Default cPrefFun	 	:= ""
	Default cTipoFun 		:= ""

//===========================
// prencho a variavel de log
//===========================
	cLog += CRLF
	cLog += "  >> Função ComCobrador
	cLog += CRLF

// posiciono no registro do vendedor
	SA3->( DbSetOrder(1) )
	If SA3->( MsSeek( xFilial("SA3")+cCodVendedor ) )

		// nome do vendedor
		cNomeVendedor := SA3->A3_NOME

		If Select("TRBSE1") > 0
			TRBSE1->(dbCloseArea())
		EndIf

		//gera comissão para os titulos baixados no periodo de: dBaixaDe e dBaixaAt
		//remove os titulos do tipo abatimento
		aTmp := STRTOKARR(MVABATIM, "|")

		cTmp := " AND SE1.E1_TIPO NOT IN ("

		For nI := 1 to Len(aTmp)

			If nI < Len(aTmp)

				cTmp += "'"+aTmp[nI]+"', "

			Else

				cTmp += "'"+aTmp[nI]+"'"

			EndIf

		Next nI

		cTmp += ") "

		cQuery := "SELECT SE1.* " + CRLF
		cQuery += " FROM " + RetSqlName("SE1") + " SE1" + CRLF
		cQuery += " WHERE SE1.D_E_L_E_T_ <> '*'" + CRLF
		cQuery += " AND SE1.E1_XFILVEN = '"  + xFilial("SA3") + "' " + CRLF
		cQuery += " AND SE1.E1_XVENDCB = '" + cCodVendedor + "'" + CRLF //vendedor da baixa
		cQuery += " AND SE1.E1_BAIXA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAt) + "'" + CRLF
		cQuery += cTmp + CRLF //remove os titulos de abatimento
		cQuery += " ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO" + CRLF

		cLog += CRLF
		cLog += " >> QUERY: "
		cLog += CRLF
		cLog += cQuery
		cLog += CRLF
		cLog += CRLF

		cQuery := Changequery(cQuery)
		TcQuery cQuery New Alias "TRBSE1"

		TRBSE1->(dbEval({|| nParcel++}))
		TRBSE1->(dbGoTop())

		cLog += CRLF
		cLog += "   >> N. DE TITULOS COBRADOS     = " + PADL(cValToChar(nParcel) , 10) + CRLF
		cLog += CRLF

		While TRBSE1->( !Eof() )

			If lEnd	//houve cancelamento do processo
				Exit
			EndIf

			oProcess:IncRegua2("Processando os Títulos Recebidos...")

			//===========================
			// prencho a variavel de log
			//===========================

			cLog += CRLF
			cLog += "    >> VENDEDOR: " + TRBSE1->E1_XVENDCB + " - " + Posicione("SA3",1,xFilial("SA3")+TRBSE1->E1_XVENDCB,"A3_NOME") + CRLF

			//===========================
			// prencho a variavel de log
			//===========================

			// alimento as variaveis totalizadoras dos detalhes
			U_RUTILE15( "R", TRBSE1->E1_NUM, TRBSE1->E1_XVENDCB, TRBSE1->E1_VALOR, @cLog, TRBSE1->E1_BAIXA, .F.,;
				TRBSE1->E1_CLIENTE, TRBSE1->E1_LOJA, .F., @nVlrComissao, @nVlrBase, @nPerVend, /*cPrefCtr*/, /*cTipoCtr*/, /*cTipoEnt*/,/*cParcTit*/, /*cLstVend*/, dDataAt )

			//>>> PRODUTO - DESCRICAO - QTD - VLR UNIT - VLR TOTAL - % COMISSAO - VALOR COMISSAO
			cLog += CRLF
			cLog += "     >> TITULO: 		" + TRBSE1->E1_NUM + CRLF
			cLog += "     >> PARCELA:	 	" + TRBSE1->E1_PARCELA + CRLF
			cLog += "     >> VALOR TOTAL: 	" + Transform(TRBSE1->E1_VALOR,"@E 9,999,999,999,999.99") + CRLF
			cLog += "     >> % COMISSAO: 	" + Transform(nPerVend,"@E 999.99") + CRLF
			cLog += "     >> VLR COMISSAO: 	" + Transform(nVlrComissao,"@E 9,999,999,999,999.99") + CRLF

			nTotDetBase 	+= nVlrBase
			nTotDetComis 	+= nVlrComissao

			//====================================
			// vou alimentar os dados da comissao
			//====================================

			aAuxDetalhes := {}
			//Aadd(aAuxDetalhes,{"TR_ITEM" 	, StrZero( nConta, 3 ) 												})
			Aadd(aAuxDetalhes,{"TR_ORIGEM" 	, OrigemRotina("R")													})
			Aadd(aAuxDetalhes,{"TR_CODIGO" 	, TRBSE1->E1_NUM													})
			Aadd(aAuxDetalhes,{"TR_DTCOMI" 	, StoD(TRBSE1->E1_BAIXA) 											})
			Aadd(aAuxDetalhes,{"TR_VEND" 	, TRBSE1->E1_XVENDCB												})
			Aadd(aAuxDetalhes,{"TR_NOME"	, Posicione("SA3",1,xFilial("SA3")+TRBSE1->E1_XVENDCB,"A3_NOME")	})
			Aadd(aAuxDetalhes,{"TR_PRODUT"	, TRBSE1->E1_CLIENTE													})
			Aadd(aAuxDetalhes,{"TR_DSCPRO"	, TRBSE1->E1_NOMCLI													})
			Aadd(aAuxDetalhes,{"TR_QTDPV"	, 1																	})
			Aadd(aAuxDetalhes,{"TR_PRCPV"	, TRBSE1->E1_VALOR													})
			Aadd(aAuxDetalhes,{"TR_BASE"	, nVlrBase															})
			Aadd(aAuxDetalhes,{"TR_PORC"	, nPerVend															})
			Aadd(aAuxDetalhes,{"TR_COMIS"	, nVlrComissao														})
			Aadd(aAuxDetalhes,{"TR_HIST"	, "RECEBIMENTO COBRADOR"											})
			Aadd(aAuxDetalhes,{"TR_RELAC"	, cCodVendedor														})

			// alimento o array de comissoes
			Aadd( aDadosDetalhes,  aAuxDetalhes)

			// incremento a variavel de total de contratos
			nTotQtdCtr++

			TRBSE1->( DbSkip() )
		EndDo

		// alimento o total de percentual de comissao
		nTotDetPorc	:= NoRound((nTotDetComis/nTotDetBase)*100,2)

		//===========================
		// prencho a variavel de log
		//===========================

		cLog += CRLF
		cLog += "     >> TOTAIS RECEBIMENTOS (COBRADOR)" + CRLF
		cLog += "     >> BASE COMISSÃO	: " + Transform(nTotDetBase,"@E 9,999,999,999,999.99") + CRLF
		cLog += "     >> % COMISSAO		: " + Transform(nTotDetPorc,"@E 999.99") + CRLF
		cLog += "     >> VLR COMISSÃO	: " + Transform(nTotDetComis,"@E 9,999,999,999,999.99") + CRLF
		cLog += CRLF

		If Select("TRBSE1") > 0
			TRBSE1->(dbCloseArea())
		EndIf

		// incremento os totalizadores do tipo gerente/supervisor
		nTotTipBase 	+= nTotDetBase
		nTotTipComis 	+= nTotDetComis
		nTotTipPorc		:= NoRound((nTotTipComis/nTotTipBase)*100,2)

		// zero as variaveis de comissao
		nTotDetBase 	:= 0
		nTotDetComis 	:= 0
		nTotDetPorc		:= 0

		// zero a variavel
		nDiaFec := 0

		//Posiciona no Cliclo e Pgto de Comissão
		U18->(dbSetOrder(1)) //U18_FILIAL+U18_CODIGO
		If U18->(MsSeek(xFilial("U18")+SA3->A3_XCICLO))
			nDiaFec := U18->U18_DIAFEC
		Else // se não houver ciclo pego o do codastro de vendedor
			nDiaFec := SA3->A3_DIA
		EndIf

		// caso o dia de fechamento por menor que zero
		If nDiaFec <= 0
			nDiaFec := Day(dDataBase)
		EndIf

		// coloco o vencimento com a database
		dE3_VENCTO := dDataBase

		If Val(Day2Str(dE3_VENCTO)) <= nDiaFec //U18->U18_DIAFEC //A3_DIA e A3_DDD (F - Fora Mes)
			dE3_VENCTO := CtoD(PADL(nDiaFec,2,"0")+"/"+Month2Str(dE3_VENCTO)+"/"+Year2Str(dE3_VENCTO))
		Else
			dE3_VENCTO := CtoD(PADL(nDiaFec,2,"0")+"/"+Month2Str(MonthSum(dE3_VENCTO,1))+"/"+Year2Str(MonthSum(dE3_VENCTO,1)))
		EndIf

		// verifico se tem valor brase calculado
		If nTotTipBase > 0

			// preencho o array de dados
			aAuxTipo := {}
			Aadd( aAuxTipo, { "TR_TIPO" 	, TipoVendedor("C")			})
			Aadd( aAuxTipo, { "TR_VEND" 	, cCodVendedor	})
			Aadd( aAuxTipo, { "TR_NOME"		, cNomeVendedor	})
			Aadd( aAuxTipo, { "TR_VENCTO"	, dE3_VENCTO	})
			Aadd( aAuxTipo, { "TR_QUANT"	, nTotQtdCtr	})
			Aadd( aAuxTipo, { "TR_BASE"		, nTotTipBase	})
			Aadd( aAuxTipo, { "TR_PORC"		, nTotTipPorc	})
			Aadd( aAuxTipo, { "TR_COMIS"	, nTotTipComis	})

			// preencho o array de dados
			Aadd( aDadosTipo, aAuxTipo )

		EndIf

		//===========================
		// prencho a variavel de log
		//===========================

		cLog += CRLF
		cLog += " >> TOTAIS GERAIS COMISSOES DO VENDEDOR	: " + cCodVendedor + " - " + cNomeVendedor + CRLF
		cLog += " >> BASE COMISSÃO							: " + Transform(nTotTipBase,"@E 9,999,999,999,999.99") + CRLF
		cLog += " >> % COMISSAO								: " + Transform(nTotTipPorc,"@E 999.99") + CRLF
		cLog += " >> VLR COMISSÃO							: " + Transform(nTotTipComis,"@E 9,999,999,999,999.99") + CRLF
		cLog += CRLF

		// zero as variaveis de comissao
		nTotTipBase 	:= 0
		nTotTipComis 	:= 0
		nTotTipPorc		:= 0

	EndIf

	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} ComVendedor
Gera registros de comissao para Gerentes e Supervisores
@author g.sampaio
@since 25/06/2019
@version P12
@param cLog
@return nulo
/*/

Static Function ComVendedor( oProcess, cLog, nOpc, cCodVendedor, dDataDe, dDataAt, cTrbTipo, cTrbDetalhes, oBrowseTipo,;
		oBrowseDetalhes, aDadosTipo, aDadosDetalhes, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun )

	Local aArea				:= GetArea()
	Local aAreaSA3			:= SA3->(Getarea())
	Local aAuxDetalhes		:= {}
	Local aAuxTipo			:= {}
	Local cQuery 			:= ""
	Local cNomeVendedor		:= ""
	Local lFuneraria	    := SuperGetMV("MV_XFUNE",,.F.)
	Local lCemiterio	    := SuperGetMV("MV_XCEMI",,.F.)
	Local nCountSA3			:= 0
	Local nConta			:= 0
	Local nVlrBase			:= 0
	Local nVlrComissao		:= 0
	Local nTotDetPorc		:= 0
	Local nTotDetBase 		:= 0
	Local nTotDetComis 		:= 0
	Local nTotTipBase		:= 0
	Local nTotTipComis		:= 0
	Local nTotTipPorc		:= 0
	Local nPerVend			:= 0
	Local nTotQtdCtr		:= 0

	Default cLog 			:= ""
	Default cCodVendedor	:= ""
	Default dDataDe			:= ""
	Default dDataAt			:= ""
	Default cTrbTipo		:= ""
	Default cTrbDetalhes	:= ""
	Default aDadosTipo		:= {}
	Default aDadosDetalhes	:= {}
	Default cPrefCtr		:= ""
	Default cTipoCtr		:= ""
	Default cTipoEnt	 	:= ""
	Default cPrefFun	 	:= ""
	Default cTipoFun 		:= ""

//===========================
// prencho a variavel de log
//===========================
	cLog += CRLF
	cLog += "  >> Função ComVendedor
	cLog += CRLF

// posiciono no registro do vendedor
	SA3->( DbSetOrder(1) )
	If SA3->( MsSeek( xFilial("SA3")+cCodVendedor ) )

		// nome do vendedor
		cNomeVendedor := SA3->A3_NOME

		//===========================
		// prencho a variavel de log
		//===========================

		if lCemiterio

			cLog += CRLF
			cLog += "   >> SELEÇÃO DAS COMISSOES DE CONTRATOS (CEMITERIO : U00, U05 ) DOS VENDEDORES RELACIONADOS... " + CRLF

			//===========================================================================
			// prencho a query de consulta de commissoes de contratos cemiterio
			//===========================================================================

			cQuery := "SELECT U00.*, U05.*" + CRLF
			cQuery += " FROM " + RetSqlName("U00") + " U00" + CRLF
			cQuery += " INNER JOIN" + CRLF
			cQuery += " " + RetSqlName("U05") + " U05 ON (U05.U05_FILIAL = '" + xFilial("U05") + "' AND U00.U00_PLANO = U05.U05_CODIGO AND U05.D_E_L_E_T_ <> '*')" + CRLF
			cQuery += " WHERE" + CRLF
			cQuery += " U00.D_E_L_E_T_ <> '*'" + CRLF
			cQuery += " AND U00.U00_FILIAL = '" + xFilial("U00") + "' "
			cQuery += " AND U00.U00_VENDED = '" + cCodVendedor + "' " + CRLF
			cQuery += " AND U00.U00_DTATIV <> ''" + CRLF
			cQuery += " AND U00.U00_DTATIV BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAt) + "'" + CRLF
			cQuery += " AND U05.U05_COMISS = 'S'" + CRLF
			cQuery += " AND U00.U00_STATUS IN ('A','F')" + CRLF
			cQuery += " AND NOT EXISTS (
			cQuery += " SELECT R_E_C_N_O_ RECSE3 FROM  " + RetSqlName("SE3") + " SE3B "
			cQuery += " WHERE SE3B.D_E_L_E_T_ =  ' ' "
			cQuery += " AND SE3B.E3_FILIAL = '" + xFilial("SE3") + "' "
			cQuery += " AND SE3B.E3_XCONTRA = U00.U00_CODIGO "
			cQuery += " AND SE3B.E3_DATA <> '' "
			cQuery += " AND SE3B.E3_COMIS > 0 )"
			cQuery += " ORDER BY U00.U00_FILIAL, U00.U00_VENDED, U00.U00_CODIGO" + CRLF

			//===========================
			// prencho a variavel de log
			//===========================

			cLog += CRLF

			cLog += " >> QUERY: "

			cLog += CRLF
			cLog += CRLF

			cLog += cQuery // adiciono a query na log

			cLog += CRLF
			cLog += CRLF

			cQuery := ChangeQuery(cQuery)
			TcQuery cQuery New Alias "QRYU00" // Cria uma nova area com o resultado do query

			// alimento a variavell contadora
			QRYU00->(dbEval({|| nCountSA3++}))
			QRYU00->(dbGoTop())

			oProcess:SetRegua2(nCountSA3)

			While QRYU00->(!Eof())

				nConta++

				If lEnd	//houve cancelamento do processo
					Exit
				EndIf

				oProcess:IncRegua2("Processando os contratos de cemitério...")

				//===========================
				// prencho a variavel de log
				//===========================

				cLog += CRLF
				cLog += "    >> VENDEDOR: " + QRYU00->U00_VENDED + " - " + Posicione("SA3",1,xFilial("SA3")+QRYU00->U00_VENDED,"A3_NOME") + CRLF

				//===========================
				// prencho a variavel de log
				//===========================

				//>>> PRODUTO - DESCRICAO - QTD - VLR UNIT - VLR TOTAL - % COMISSAO - VALOR COMISSAO
				cLog += CRLF
				cLog += "     >> CONTRATO: 		" + QRYU00->U00_CODIGO + CRLF
				cLog += "     >> PLANO:		 	" + QRYU00->U00_PLANO + CRLF
				cLog += "     >> DESCRICAO: 	" + QRYU00->U05_DESCRI + CRLF
				cLog += "     >> VALOR TOTAL: 	" + Transform(QRYU00->U00_VALOR,"@E 9,999,999,999,999.99") + CRLF
				cLog += "     >> % COMISSAO: 	" + Transform(nPerVend,"@E 999.99") + CRLF
				cLog += "     >> VLR COMISSAO: 	" + Transform(QRYU00->U00_VALOR * (nPerVend/100),"@E 9,999,999,999,999.99") + CRLF

				// alimento as variaveis totalizadoras dos detalhes
				U_RUTILE15( "C", QRYU00->U00_CODIGO, QRYU00->U00_VENDED, QRYU00->U00_VALOR, @cLog, QRYU00->U00_DTATIV, .F.,;
					QRYU00->U00_CLIENT, QRYU00->U00_LOJA, .F., @nVlrComissao, @nVlrBase, @nPerVend, cPrefCtr, cTipoCtr, cTipoEnt, /*cParcTit*/, /*cLstVend*/, dDataAt )

				nTotDetBase 	+= nVlrBase
				nTotDetComis 	+= nVlrComissao

				//====================================
				// vou alimentar os dados da comissao
				//====================================

				aAuxDetalhes := {}
				//Aadd(aAuxDetalhes,{"TR_ITEM" 	, StrZero( nConta, 3 ) 												})
				Aadd(aAuxDetalhes,{"TR_ORIGEM" 	, OrigemRotina("C")													})
				Aadd(aAuxDetalhes,{"TR_CODIGO" 	, QRYU00->U00_CODIGO												})
				Aadd(aAuxDetalhes,{"TR_DTCOMI" 	, StoD(QRYU00->U00_DTATIV) 											})
				Aadd(aAuxDetalhes,{"TR_VEND" 	, QRYU00->U00_VENDED												})
				Aadd(aAuxDetalhes,{"TR_NOME"	, Posicione("SA3",1,xFilial("SA3")+QRYU00->U00_VENDED,"A3_NOME")	})
				Aadd(aAuxDetalhes,{"TR_PRODUT"	, QRYU00->U00_PLANO													})
				Aadd(aAuxDetalhes,{"TR_DSCPRO"	, QRYU00->U05_DESCRI												})
				Aadd(aAuxDetalhes,{"TR_QTDPV"	, 1																	})
				Aadd(aAuxDetalhes,{"TR_PRCPV"	, QRYU00->U00_VALOR													})
				Aadd(aAuxDetalhes,{"TR_BASE"	, nVlrBase															})
				Aadd(aAuxDetalhes,{"TR_PORC"	, nPerVend															})
				Aadd(aAuxDetalhes,{"TR_COMIS"	, nVlrComissao														})
				Aadd(aAuxDetalhes,{"TR_HIST"	, "COMISSOES DE CONTRATOS (CEMITERIO)"								})
				Aadd(aAuxDetalhes,{"TR_RELAC"	, cCodVendedor														})

				// alimento o array de comissoes
				Aadd( aDadosDetalhes,  aAuxDetalhes)

				// incremento o total de contratos
				nTotQtdCtr++

				QRYU00->(dbSkip())
			EndDo

			// alimento o total de percentual de comissao
			nTotDetPorc	:= NoRound((nTotDetComis/nTotDetBase)*100,2)

			//===========================
			// prencho a variavel de log
			//===========================

			cLog += CRLF
			cLog += "     >> TOTAIS COMISSOES DE CONTRATOS (CEMITERIO)" + CRLF
			cLog += "     >> BASE COMISSÃO: " + Transform(nTotDetBase,"@E 9,999,999,999,999.99") + CRLF
			cLog += "     >> % COMISSAO: 	" + Transform(nTotDetPorc,"@E 999.99") + CRLF
			cLog += "     >> VLR COMISSÃO: 	" + Transform(nTotDetComis,"@E 9,999,999,999,999.99") + CRLF
			cLog += CRLF

			// verifico se o alias esta em uso
			If Select("QRYU00") > 0

				QRYU00->(DbCloseArea())

			EndIf

			// incremento os totalizadores do tipo gerente/supervisor
			nTotTipBase 	+= nTotDetBase
			nTotTipComis 	+= nTotDetComis
			nTotTipPorc		:= NoRound((nTotTipComis/nTotTipBase)*100,2)

		endIf

		// zero as variaveis de comissao
		nTotDetBase 	:= 0
		nTotDetComis 	:= 0
		nTotDetPorc		:= 0

		//===================================
		//	CONTRATO FUNERARIA: UF2, UF0
		//===================================

		if lFuneraria

			// verifico se o alias esta em uso
			If Select("QRYUF2") > 0

				QRYUF2->(DbCloseArea())

			EndIf

			//===========================
			// prencho a variavel de log
			//===========================

			cLog += CRLF
			cLog += "   >> SELEÇÃO DAS COMISSOES DE CONTRATOS (FUNERARIOS: UF2, UF0) DOS VENDEDORES RELACIONADOS... " + CRLF

			//===========================================================================
			// prencho a query de consulta de commissoes de contratos de funeraria
			//===========================================================================

			cQuery := "SELECT UF2.*, UF0.*" + CRLF
			cQuery += " FROM " + RetSqlName("UF2") + " UF2" + CRLF
			cQuery += " INNER JOIN" + CRLF
			cQuery += " " + RetSqlName("UF0") + " UF0 ON (UF2.UF2_FILIAL = UF0.UF0_FILIAL AND UF2.UF2_PLANO = UF0.UF0_CODIGO AND UF0.D_E_L_E_T_ <> '*')" + CRLF
			cQuery += " WHERE" + CRLF
			cQuery += " UF2.D_E_L_E_T_ <> '*'" + CRLF
			cQuery += " AND UF2.UF2_FILIAL = '" + xFilial("UF2") + "'" + CRLF
			cQuery += " AND UF2.UF2_VEND = '" + cCodVendedor + "' "  + CRLF
			cQuery += " AND UF2.UF2_DTATIV <> ''" + CRLF
			cQuery += " AND UF2.UF2_STATUS IN ('A','F')" + CRLF
			cQuery += " AND UF2.UF2_DTATIV BETWEEN '" + DtoS(dDataDe) + "' AND '" + DtoS(dDataAt) + "'" + CRLF
			cQuery += " AND UF0.UF0_COMISS = 'S'" + CRLF
			cQuery += " AND NOT EXISTS (
			cQuery += " SELECT R_E_C_N_O_ RECSE3 FROM  " + RetSqlName("SE3") + " SE3B "
			cQuery += " WHERE SE3B.D_E_L_E_T_ =  ' ' "
			cQuery += " AND SE3B.E3_FILIAL = '" + xFilial("SE3") + "' "
			cQuery += " AND SE3B.E3_XCTRFUN = UF2.UF2_CODIGO "
			cQuery += " AND SE3B.E3_DATA <> '' "
			cQuery += " AND SE3B.E3_COMIS > 0 )"
			cQuery += " ORDER BY UF2.UF2_FILIAL, UF2.UF2_VEND, UF2.UF2_CODIGO" + CRLF

			//===========================
			// prencho a variavel de log
			//===========================

			cLog += CRLF
			cLog += " >> QUERY: "

			cLog += CRLF
			cLog += CRLF

			cLog += cQuery // coloco a query na log

			cLog += CRLF
			cLog += CRLF

			cQuery := ChangeQuery(cQuery)
			TcQuery cQuery New Alias "QRYUF2" // Cria uma nova area com o resultado do query

			// zero a variavel de vendedores
			cVends := ""

			//
			QRYUF2->( dbEval({|| nCountSA3++} ))
			QRYUF2->( DbGoTop() )

			oProcess:SetRegua2(nCountSA3)

			While QRYUF2->(!Eof())

				If lEnd	//houve cancelamento do processo
					Exit
				EndIf

				oProcess:IncRegua2("Processando contratos do Módulo de Funerária...")

				If cVends <> QRYUF2->UF2_VEND
					cLog += CRLF
					cLog += "    >> VENDEDOR: " + QRYUF2->UF2_VEND + " - " + Posicione("SA3",1,xFilial("SA3")+QRYUF2->UF2_VEND,"A3_NOME") + CRLF
					cVends := QRYUF2->UF2_VEND
				EndIf

				//===========================
				// prencho a variavel de log
				//===========================

				//>>> PRODUTO - DESCRICAO - QTD - VLR UNIT - VLR TOTAL - % COMISSAO - VALOR COMISSAO
				cLog += CRLF
				cLog += "     >> CONTRATO		: " + QRYUF2->UF2_CODIGO + CRLF
				cLog += "     >> PLANO			: " + QRYUF2->UF2_PLANO + CRLF
				cLog += "     >> DESCRICAO		: " + QRYUF2->UF0_DESCRI + CRLF
				cLog += "     >> VALOR TOTAL	: " + Transform(QRYUF2->UF2_VALOR,"@E 9,999,999,999,999.99") + CRLF
				cLog += "     >> % COMISSAO		: " + Transform(nPerVend,"@E 999.99") + CRLF
				cLog += "     >> VLR COMISSAO	: " + Transform(QRYUF2->UF2_VALOR * (nPerVend/100),"@E 9,999,999,999,999.99") + CRLF

				// alimento as variaveis totalizadoras dos detalhes
				U_RUTILE15( "F", QRYUF2->UF2_CODIGO, QRYUF2->UF2_VEND, QRYUF2->UF2_VALOR, @cLog, QRYUF2->UF2_DTATIV, .F.,;
					QRYUF2->UF2_CLIENT, QRYUF2->UF2_LOJA, .F., @nVlrComissao, @nVlrBase, @nPerVend, cPrefFun, cTipoFun, cTipoEnt, /*cParcTit*/, /*cLstVend*/, dDataAt )

				nTotDetBase 	+= nVlrBase
				nTotDetComis 	+= nVlrComissao

				//====================================
				// vou alimentar os dados da comissao
				//====================================

				aAuxDetalhes := {}
				//Aadd(aAuxDetalhes,{"TR_ITEM" 	, StrZero( nConta, 3 ) 												})
				Aadd(aAuxDetalhes,{"TR_ORIGEM" 	, OrigemRotina("F")													})
				Aadd(aAuxDetalhes,{"TR_CODIGO" 	, QRYUF2->UF2_CODIGO												})
				Aadd(aAuxDetalhes,{"TR_DTCOMI" 	, StoD(QRYUF2->UF2_DTATIV) 											})
				Aadd(aAuxDetalhes,{"TR_VEND" 	, QRYUF2->UF2_VEND													})
				Aadd(aAuxDetalhes,{"TR_NOME"	, Posicione("SA3",1,xFilial("SA3")+QRYUF2->UF2_VEND,"A3_NOME")		})
				Aadd(aAuxDetalhes,{"TR_PRODUT"	, QRYUF2->UF2_PLANO													})
				Aadd(aAuxDetalhes,{"TR_DSCPRO"	, QRYUF2->UF0_DESCRI												})
				Aadd(aAuxDetalhes,{"TR_QTDPV"	, 1																	})
				Aadd(aAuxDetalhes,{"TR_PRCPV"	, QRYUF2->UF2_VALOR													})
				Aadd(aAuxDetalhes,{"TR_BASE"	, nVlrBase															})
				Aadd(aAuxDetalhes,{"TR_PORC"	, nPerVend															})
				Aadd(aAuxDetalhes,{"TR_COMIS"	, nVlrComissao														})
				Aadd(aAuxDetalhes,{"TR_HIST"	, "COMISSOES DE CONTRATOS (FUNERARIA)"								})
				Aadd(aAuxDetalhes,{"TR_RELAC"	, cCodVendedor														})

				// alimento o array de comissoes
				Aadd( aDadosDetalhes,  aAuxDetalhes)

				// incremento o total de contratos
				nTotQtdCtr++

				QRYUF2->(dbSkip())
			EndDo

			// alimento o total de percentual de comissao
			nTotDetPorc	:= NoRound((nTotDetComis/nTotDetBase)*100,2)

			//===========================
			// prencho a variavel de log
			//===========================

			cLog += CRLF
			cLog += "     >> TOTAIS COMISSOES DE CONTRATOS (FUNERARIA)" + CRLF
			cLog += "     >> BASE COMISSÃO	: " + Transform(nTotDetBase,"@E 9,999,999,999,999.99") + CRLF
			cLog += "     >> % COMISSAO		: " + Transform(nTotDetPorc,"@E 999.99") + CRLF
			cLog += "     >> VLR COMISSÃO	: " + Transform(nTotDetComis,"@E 9,999,999,999,999.99") + CRLF
			cLog += CRLF

			If Select("QRYUF2") > 0
				QRYUF2->(DbCloseArea())
			EndIf

			// incremento os totalizadores do tipo gerente/supervisor
			nTotTipBase 	+= nTotDetBase
			nTotTipComis 	+= nTotDetComis
			nTotTipPorc		:= NoRound((nTotTipComis/nTotTipBase)*100,2)

		endIf

		// zero as variaveis de comissao
		nTotDetBase 	:= 0
		nTotDetComis 	:= 0
		nTotDetPorc		:= 0

		// zero a variavel
		nDiaFec := 0

		//Posiciona no Cliclo e Pgto de Comissão
		U18->(dbSetOrder(1)) //U18_FILIAL+U18_CODIGO
		If U18->(MsSeek(xFilial("U18")+SA3->A3_XCICLO))
			nDiaFec := U18->U18_DIAFEC
		Else // se não houver ciclo pego o do codastro de vendedor
			nDiaFec := SA3->A3_DIA
		EndIf

		// caso o dia de fechamento por menor que zero
		If nDiaFec <= 0
			nDiaFec := Day(dDataBase)
		EndIf

		// coloco o vencimento com a database
		dE3_VENCTO := dDataBase

		If Val(Day2Str(dE3_VENCTO)) <= nDiaFec //U18->U18_DIAFEC //A3_DIA e A3_DDD (F - Fora Mes)
			dE3_VENCTO := CtoD(PADL(nDiaFec,2,"0")+"/"+Month2Str(dE3_VENCTO)+"/"+Year2Str(dE3_VENCTO))
		Else
			dE3_VENCTO := CtoD(PADL(nDiaFec,2,"0")+"/"+Month2Str(MonthSum(dE3_VENCTO,1))+"/"+Year2Str(MonthSum(dE3_VENCTO,1)))
		EndIf

		// verifico se tem valor brase calculado
		If nTotTipBase > 0

			// preencho o array de dados
			aAuxTipo := {}
			Aadd( aAuxTipo, { "TR_TIPO" 	, TipoVendedor("V")			})
			Aadd( aAuxTipo, { "TR_VEND" 	, cCodVendedor	})
			Aadd( aAuxTipo, { "TR_NOME"		, cNomeVendedor	})
			Aadd( aAuxTipo, { "TR_VENCTO"	, dE3_VENCTO	})
			Aadd( aAuxTipo, { "TR_QUANT"	, nTotQtdCtr	})
			Aadd( aAuxTipo, { "TR_BASE"		, nTotTipBase	})
			Aadd( aAuxTipo, { "TR_PORC"		, nTotTipPorc	})
			Aadd( aAuxTipo, { "TR_COMIS"	, nTotTipComis	})

			// preencho o array de dados
			Aadd( aDadosTipo, aAuxTipo )

		EndIf

		//===========================
		// prencho a variavel de log
		//===========================

		cLog += CRLF
		cLog += " >> TOTAIS GERAIS COMISSOES DO VENDEDOR	: " + cCodVendedor + " - " + cNomeVendedor + CRLF
		cLog += " >> BASE COMISSÃO							: " + Transform(nTotTipBase,"@E 9,999,999,999,999.99") + CRLF
		cLog += " >> % COMISSAO								: " + Transform(nTotTipPorc,"@E 999.99") + CRLF
		cLog += " >> VLR COMISSÃO							: " + Transform(nTotTipComis,"@E 9,999,999,999,999.99") + CRLF
		cLog += CRLF

		// zero as variaveis de comissao
		nTotTipBase 	:= 0
		nTotTipComis 	:= 0
		nTotTipPorc		:= 0

	Endif

	RestArea( aAreaSA3 )
	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} RetSubordinados
Gera registros de comissao para Gerentes e Supervisores
@author g.sampaio
@since 25/06/2019
@version P12
@param cLog
@return nulo
/*/

Static Function RetSubordinados( cCodVendedor, cLog, nOpc )

	Local aArea				:= GetArea()
	Local aAreaSA3			:= SA3->( GetArea() )
	Local cQuery			:= ""
	Local aRetorno 			:= {}

	Default	cCodVendedor	:= ""
	Default cLog			:= ""
	Default nOpc			:= 0

// posiciono no registro do cadastro de vendedores
	SA3->( DbSetOrder(1) )
	If SA3->( MsSeek( xFilial("SA3")+cCodVendedor ) )

		//===========================
		// prencho a variavel de log
		//===========================

		cLog += CRLF

		// verifico qual o tipo de vendedor
		If nOpc == 4 // supervisores

			cLog += "  >> SELEÇÃO DOS SUBORDINADOS DO SUPERVISOR " + SA3->A3_COD + " - " + SA3->A3_NOME + "..." + CRLF

		ElseIf nOpc == 5 // gerentes

			cLog += "  >> SELEÇÃO DOS SUBORDINADOS DO GERENTE " + SA3->A3_COD + " - " + SA3->A3_NOME + "..." + CRLF

		EndIf

		// verifico se o alias esta em uso
		If Select("QRYSUBO") > 0

			QRYSUBO->(DbCloseArea())

		EndIf

		//===========================
		// monto a query de dados
		//===========================

		cQuery := " SELECT SA3.*" + CRLF
		cQuery += " FROM " + RetSqlName("SA3") + " SA3" + CRLF
		cQuery += " WHERE" + CRLF
		cQuery += " SA3.D_E_L_E_T_ <> '*'" + CRLF
		cQuery += " AND SA3.A3_FILIAL = '" + xFilial("SA3") + "'" + CRLF

		// verifico qual o tipo de vendedor
		If nOpc == 4 // subordinados

			cQuery += " AND SA3.A3_SUPER = '" + SA3->A3_COD + "'" + CRLF

		ElseIf nOpc == 5 // gerentes

			cQuery += " AND SA3.A3_GEREN = '" + SA3->A3_COD + "'" + CRLF

		EndIf

		cQuery += " ORDER BY SA3.A3_FILIAL, SA3.A3_COD" + CRLF

		//===========================
		// prencho a variavel de log
		//===========================

		cLog += CRLF
		cLog += " >> QUERY: "

		cLog += CRLF
		cLog += CRLF

		// coloco a query na log
		cLog += cQuery

		cLog += CRLF
		cLog += CRLF

		cQuery := ChangeQuery(cQuery)
		TcQuery cQuery New Alias "QRYSUBO" // Cria uma nova area com o resultado do query

		// limpo o array
		aRetorno := {}

		QRYSUBO->(dbGoTop())
		While QRYSUBO->(!Eof())

			// alimento o array de subordinados para retorno da funcao
			Aadd( aRetorno, {QRYSUBO->A3_COD} )

			QRYSUBO->(dbSkip())

		EndDo

		// verifico se o alias esta em uso
		If Select("QRYSUBO") > 0

			QRYSUBO->(DbCloseArea())

		EndIf

	EndIf

	RestArea( aAreaSA3 )
	RestArea( aArea )

Return(aRetorno)

/*/{Protheus.doc} ShowLog
Mostra o log do ultimo processamento

@author g.sampaio
@since 19/07/2016
@version undefined
@param cLog, characters, descricao
@type function
/*/

Static Function ShowLog(cLog)

	Local cFileLog	:= ""
	Local cFile		:= ""
	Local cMask		:= ""
	Local oMemo		:= NIL
	Local oFont		:= NIL
	Local oDlgDet	:= NIL

	Default cLog	:= ""

	// verifico se tem log preenchido
	If !Empty(cLog)

		// gero o arquivo de log
		cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cLog )

		// monto a tela de log
		Define Font oFont Name "Arial" Size 7, 16
		Define MsDialog oDlgDet Title "Log Gerado - último procesamento" From 3, 0 to 340, 417 Pixel

		@ 5, 5 Get oMemo Var cLog Memo Size 200, 145 Of oDlgDet Pixel
		oMemo:bRClicked := { || AllwaysTrue() }
		oMemo:oFont     := oFont

		Define SButton From 153, 175 Type  1 Action oDlgDet:End() Enable Of oDlgDet Pixel // Apaga
		Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cLog ) ) ) Enable Of oDlgDet Pixel

		Activate MsDialog oDlgDet Center

	Else // retorno mensagem caso não exista log

		MsgAlert("Não existem logs a serem mostrados.","Atenção")

	EndIf

Return()

/*/{Protheus.doc} OrigemRotina
Mostra o log do ultimo processamento

@author g.sampaio
@since 19/07/2016
@version undefined
@param cLog, characters, descricao
@type function
/*/

Static Function OrigemRotina( cOrigem )

	Local cRetorno	:= ""

// valido a origem
	If cOrigem == "V" // origem venda direta

		cRetorno := "VD DIRETA"

	ElseIf cOrigem == "P" // origem pedido de venda

		cRetorno :="PD VENDA"

	ElseIf cOrigem == "C" // origem contrato cemiterio

		cRetorno := "CTR CEMITERIO"

	ElseIf cOrigem == "F" // origem contrato funeraria

		cRetorno := "CTR FUNERARIA"

	ElseIF cOrigem == "R" // recebimento

		cRetorno	:= "RECEBE TITULO"

	EndIf

Return( cRetorno )

/*/{Protheus.doc} LimpaDados
Mostra o log do ultimo processamento

@author g.sampaio
@since 19/07/2016
@version undefined
@param cLog, characters, descricao
@type function
/*/

Static Function LimpaDados( cFwAlias )

	// posiciono no primeiro registro
	(cFwAlias)->( DbGoTop() )

	// percorro todo o alias ate o seu fim
	While ( cFwAlias )->( !Eof() )

		BEGIN TRANSACTION

			If ( cFwAlias )->( RecLock( cFwAlias, .F. ) )

				// deleto o registro do alias
				( cFwAlias )->( DbDelete() )

			Else
				( cFwAlias )->( MsUnLock() )
			EndIf

		END TRANSACTION

		( cFwAlias )->( DbSkip() )
	EndDo

Return(Nil)

/*/{Protheus.doc} TipoVendedor
Mostra o log do ultimo processamento

@author g.sampaio
@since 19/07/2016
@version undefined
@param cLog, characters, descricao
@type function
/*/

Static Function TipoVendedor( cTipoVendedor )

	Local cRetorno 			:= ""

	Default cTipoVendedor	:= ""

	If cTipoVendedor == "S"
		cRetorno := "S - Supervisor"
	ElseIf cTipoVendedor == "G"
		cRetorno := "G - Gerente"
	ElseIf cTipoVendedor == "V"
		cRetorno := "V - Vendedor"
	ElseIf cTipoVendedor == "C"
		cRetorno := "C - Cobrador"
	EndIf

Return( cRetorno )

/*/{Protheus.doc} ValidCell
Mostra o log do ultimo processamento

@author g.sampaio
@since 19/07/2016
@version undefined
@param cLog, characters, descricao
@type function
/*/

Static Function ValidCell()

	Local lRetorno := .T.

Return( lRetorno )

/*/{Protheus.doc} BaseValida
Mostra o log do ultimo processamento

@author g.sampaio
@since 19/07/2016
@version undefined
@param cLog, characters, descricao
@type function
/*/

Static Function BaseValida( cAliasTRB, oBrowse, oBrowseRelac )

	Local lRetorno 		:= .T.
	Local nSoma			:= 0

	Default cAliasTRB	:= ""

// caso nao for gerente ou supervisor nao altero os dados
	If !(SubStr( TRB_TIPO->TR_TIPO, 1, 1 ) $ "G/S")
		MsgAlert("Só é permitido alterar a comissao dos vendedores, para calcular a comissao dos gerentes/supervisores!")
		lRetorno := .F.
	EndIf

	If lRetorno

		BEGIN TRANSACTION

			If TRB_TIPO->(RecLock("TRB_TIPO",.F.))

				TRB_TIPO->TR_COMIS	:= TR_BASE * (TRB_TIPO->TR_PORC/100)
				TRB_TIPO->( MsUnLock() )

			Else

				TRB_TIPO->( DisarmTransaction() )

			EndIf

		END TRANSACTION

		//TRB_TIPO->( DbGoTop() )

		oBrowse:Refresh()

	EndIf

Return( lRetorno )

/*/{Protheus.doc} PorcValida
Mostra o log do ultimo processamento

@author g.sampaio
@since 19/07/2016
@version undefined
@param cLog, characters, descricao
@type function
/*/

Static Function PorcValida( cAliasTRB, oBrowse, oBrowseRelac )

	Local lRetorno 		:= .T.
	Local nSoma			:= 0

	Default cAliasTRB	:= ""

// caso nao for gerente ou supervisor nao altero os dados
	If !(SubStr( TRB_TIPO->TR_TIPO, 1, 1 ) $ "G/S")
		MsgAlert("Só é permitido alterar a comissao dos vendedores, para calcular a comissao dos gerentes/supervisores!")
		lRetorno := .F.
	EndIf

	If lRetorno

		BEGIN TRANSACTION

			If TRB_TIPO->(RecLock("TRB_TIPO",.F.))

				TRB_TIPO->TR_COMIS	:= TRB_TIPO->TR_BASE * (TR_PORC/100)
				TRB_TIPO->( MsUnLock() )

			Else

				TRB_TIPO->( DisarmTransaction() )

			EndIf

		END TRANSACTION

		//TRB_TIPO->( DbGoTop() )

		oBrowse:Refresh()

	EndIf

Return( lRetorno )

/*/{Protheus.doc} VenctoValida
Mostra o log do ultimo processamento

(nComissao/nVlrCtr)*100

@author g.sampaio
@since 19/07/2016
@version undefined
@param cLog, characters, descricao
@type function
/*/

Static Function VenctoValida()

	Local lRetorno := .T.

Return( lRetorno )

/*/{Protheus.doc} ComisValida
Mostra o log do ultimo processamento

(nComissao/nVlrCtr)*100

@author g.sampaio
@since 19/07/2016
@version undefined
@param cLog, characters, descricao
@type function
/*/

Static Function ComisValida( cAliasTRB, oBrowse, oBrowseRelac )

	Local lRetorno 		:= .T.
	Local nSoma			:= 0

	Default cAliasTRB	:= ""

// caso nao for gerente ou supervisor nao altero os dados
	If !(SubStr( TRB_TIPO->TR_TIPO, 1, 1 ) $ "G/S")
		MsgAlert("Só é permitido alterar a comissao dos vendedores, para calcular a comissao dos gerentes/supervisores!")
		lRetorno := .F.
	EndIf

	If lRetorno

		BEGIN TRANSACTION

			If TRB_TIPO->(RecLock("TRB_TIPO",.F.))

				TRB_TIPO->TR_PORC	:= (TR_COMIS/TRB_TIPO->TR_BASE) * 100
				TRB_TIPO->( MsUnLock() )

			Else

				TRB_TIPO->( DisarmTransaction() )

			EndIf

		END TRANSACTION

		//TRB_TIPO->( DbGoTop() )

		oBrowse:Refresh()

	EndIf

Return( lRetorno )

/*/{Protheus.doc} CriaLogComissao
Funcao para criar o log de comissao
@author g.sampaio
@since 07/05/2019
@version P12
@param cTextoLog, caracter, texto da log a ser gerado
@return nulo
/*/

Static Function CriaLogComissao( cTextoLog )

	Local cDestinoDiretorio := ""
	Local cGeradoArquivo    := ""
	Local cArquivo          := "rutil018_logcomissao_" + CriaTrab(NIL, .F.) + ".txt"
	Local oWriter           := Nil

	Default cTextoLog       := ""

// vou gravar o log no diretorio de arquivos temporarios
	cDestinoDiretorio := GetTempPath()

// arquivo gerado no diretorio
	cGeradoArquivo := cDestinoDiretorio + iif( substr(alltrim(cDestinoDiretorio),len(alltrim(cDestinoDiretorio))) == iif(IsSrvUnix(),"/","\"),  cArquivo, iif(IsSrvUnix(),"/","\") + cArquivo )

// crio o objeto de escrita de arquivo
	oWriter := FWFileWriter():New( cGeradoArquivo, .T.)

// se houve falha ao criar, mostra a mensagem
	If !oWriter:Create()

		MsgStop("Houve um erro ao gerar o arquivo: " + CRLF + oWriter:Error():Message, "Atenção")

	Else// senão, continua com o processamento

		// escreve uma frase qualquer no arquivo
		oWriter:Write( cTextoLog + CRLF)

		// encerra o arquivo
		oWriter:Close()

	EndIf

Return()

/*/{Protheus.doc} ReprComissao
Funcao para criar o log de comissao
@author g.sampaio
@since 07/05/2019
@version P12
@param cTextoLog, caracter, texto da log a ser gerado
@return nulo
/*/

Static Function ReprComissao( oProcess, lEnd, cLog, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun, oTempDetalhes, dDataAt )

	Local aArea				:= GetArea()
	Local lRetorno 			:= .T.
	Local cCodSE3			:= ""
	Local cE3_PARCELA		:= ""
	Local cE3_SEQ			:= ""
	Local cPrefixo			:= ""
	Local cCodCli			:= ""
	Local cLojaCli			:= ""
	Local cTipoCom			:= ""
	Local cLogRep			:= ""
	Local cQuery			:= ""
	Local nCount			:= 0

	Default cLog			:= ""
	Default lEnd			:= .F.
	Default cPrefCtr		:= ""
	Default cTipoCtr		:= ""
	Default cTipoEnt		:= ""
	Default cPrefFun		:= ""
	Default cTipoFun 		:= ""
	Default dDataAt			:= Stod("")

	cLog += CRLF
	cLog += ">> Funcao ReprComissao [Inicio] "

	// parcela e sequencia
	cE3_PARCELA := PADL( '1', tamsx3('E3_PARCELA')[1],'0') 	// 	-> parcela
	cE3_SEQ		:= PADL( '1', tamsx3('E3_SEQ')[1],'0')		//	-> sequencia

	// pego a quantidade de registros do array aVendedores
	nCount := TRB_TIPO->(RECCOUNT())

	// volto para o primeiro registro
	TRB_TIPO->( DbGoTop() )

	// atualizo o objeto de processamentp
	oProcess:SetRegua1(nCount)

	While TRB_TIPO->( !Eof() )

		// Tipo de Comissao
		cTipoCom := SubStr( TRB_TIPO->TR_TIPO, 1, 1 )

		// codigo da SE3 sequencial
		cCodSE3 := GetSxeNum("SE3","E3_NUM")

		// para gerente e supervisor
		If cTipoCom $ "G/S" .And. TRB_TIPO->TR_COMIS <> 0

			oProcess:IncRegua2("Reprocessando comissao de Gerente/Supervisor...")

			cLogRep += CRLF
			cLogRep += ">> Reprocessando comissao de Gerente/Supervisor... "

			// defino o prefixo do titulo
			cPrefixo := Iif(SubStr( TRB_TIPO->TR_TIPO, 1, 1 ) == "G","GER","SUP")

			//Posiciona no Vendedor
			SA3->( DbSetOrder(1) ) //A3_FILIAL+A3_COD
			If SA3->( MsSeek( xFilial("SA3")+TRB_TIPO->TR_VEND ) )

				//Posiciona no Cliclo e Pgto de Comissão
				U18->( DbSetOrder(1) ) //U18_FILIAL+U18_CODIGO
				If U18->( MsSeek( xFilial("U18")+SA3->A3_XCICLO ) )

					// deleto as comissoes existentes
					lRetorno := U_UTILE15B( TRB_TIPO->TR_VEND, U18->U18_DIAFEC, /*cTipModulo*/, @cLog )

					If lRetorno

						// gero a comissao para gerente/supervisor
						lRetorno := U_UTILE15A( cCodSE3, TRB_TIPO->TR_VEND, TRB_TIPO->TR_BASE, cE3_PARCELA, cE3_SEQ, dDataBase, /*cPrazo*/, TRB_TIPO->TR_COMIS,;
							U18->U18_DIAFEC, cPrefixo, /*cTipoCtr*/, /*cTipoEnt*/, cCodCli, cLojaCli, @cLog, /*lJob*/, "G", /*nPComis*/,;
								/*nVlrBase*/, /*cTpComissao*/, TRB_TIPO->TR_PORC, TRB_TIPO->TR_VENCTO )

					EndIf

				EndIf

			EndIf

			// se estiver tudo certo confirmo a geracao da comissao
			If lRetorno

				cLogRep += CRLF
				cLogRep += "=====================================================" + CRLF
				cLogRep += ">> Comissao de Gerente/Supervisor reprocessada com sucesso!" + CRLF
				cLogRep += "+ Funcao		:" + Iif(SubStr( TRB_TIPO->TR_TIPO, 1, 1 ) == "G","Gerente","Supervisor") + CRLF
				cLogRep += "+ Codigo 		:" + TRB_TIPO->TR_VEND + CRLF
				cLogRep += "+ Nome 			:" + TRB_TIPO->TR_NOME + CRLF
				cLogRep += "+ Vencimento	:" + Dtoc( TRB_TIPO->TR_VENCTO ) + CRLF
				cLogRep += "+ Valor			:" + AllTrim( Transform( TRB_TIPO->TR_COMIS, "@E 999,999,999.99" ) ) + CRLF
				cLogRep += "=====================================================" + CRLF
				cLogRep += CRLF

				ConfirmSx8()
			Else

				cLogRep += CRLF
				cLogRep += "=====================================================" + CRLF
				cLogRep += ">> Comissao de Gerente/Supervisor Não foi Reprocessada!" + CRLF
				cLogRep += "+ Funcao		:" + Iif(SubStr( TRB_TIPO->TR_TIPO, 1, 1 ) == "G","Gerente","Supervisor") + CRLF
				cLogRep += "+ Codigo 		:" + TRB_TIPO->TR_VEND + CRLF
				cLogRep += "+ Nome 			:" + TRB_TIPO->TR_NOME + CRLF
				cLogRep += "=====================================================" + CRLF
				cLogRep += CRLF

			EndIf

		ElseIf cTipoCom == "V" .And. TRB_TIPO->TR_COMIS <> 0// para vendedor

			oProcess:IncRegua2("Reprocessando comissao de vendedor...")

			cLog += CRLF
			cLog += ">> Reprocessando comissao de Vendedor... "

			//Posiciona no Vendedor
			SA3->( DbSetOrder(1) ) //A3_FILIAL+A3_COD
			If SA3->( MsSeek( xFilial("SA3")+TRB_TIPO->TR_VEND ) )

				//Posiciona no Cliclo e Pgto de Comissão
				U18->( DbSetOrder(1) ) //U18_FILIAL+U18_CODIGO
				If U18->( MsSeek( xFilial("U18")+SA3->A3_XCICLO ) )

					// deleto as comissoes existentes
					lRetorno := U_UTILE15B( TRB_TIPO->TR_VEND, U18->U18_DIAFEC, /*cTipModulo*/, @cLog )

				Else

					lRetorno := .F.

				EndIf

			Else

				lRetorno := .F.

			EndIf

			// verifico se posso continuar
			If lRetorno

				//------------------------------------
				//Executa query para leitura da tabela
				//------------------------------------
				If Select("TRBTMP") > 0
					TRBTMP->( DbCloseArea() )
				EndIf

				cQuery := " SELECT * FROM "+ oTempDetalhes:GetRealName()
				cQuery += " WHERE TR_ORIGEM LIKE '%CEMITERIO%'"
				cQuery += " AND TR_RELAC = '" + TRB_TIPO->TR_VEND + "'"

				MPSysOpenQuery( cQuery, 'TRBTMP' )

				// reprocesso os contratos de cemiterio
				While lRetorno .And. TRBTMP->( !Eof() )

					// posiciono no cadastro de contratos de cemiterio
					U00->( DbSetOrder(1) )
					If U00->( MsSeek( xFilial("U00")+TRBTMP->TR_CODIGO ) )

						cCodCli 	:= U00->U00_CLIENT	// codigo do cliente
						cLojaCli 	:= U00->U00_LOJA 	// codigo da loja do cliente

						lRetorno := U_RUTILE15( "C", TRBTMP->TR_CODIGO, TRBTMP->TR_RELAC, TRBTMP->TR_BASE, @cLog, U00->U00_DTATIV, .T.,;
							cCodCli, cLojaCli, .F., /*nVlrComissao*/, /*nVlrTotal*/, /*nPerVend*/, cPrefCtr, cTipoCtr, cTipoEnt,/*cParcTit*/, /*cLstVend*/, dDataAt )

					EndIf

					TRBTMP->( DbSkip() )
				EndDo

				// verifico se esta tudo certo
				If lRetorno

					//------------------------------------
					//Executa query para leitura da tabela
					//------------------------------------
					If Select("TRBTMP") > 0
						TRBTMP->( DbCloseArea() )
					EndIf

					cQuery := " SELECT * FROM "+ oTempDetalhes:GetRealName()
					cQuery += " WHERE TR_ORIGEM LIKE '%FUNERARIA%'"
					cQuery += " AND TR_RELAC = '" + TRB_TIPO->TR_VEND + "'"

					MPSysOpenQuery( cQuery, 'TRBTMP' )

					// reprocesso os contratos de funeraria
					While lRetorno .And. TRBTMP->( !Eof() )

						// posiciono no cadastro de contratos funerarios
						UF2->( DbSetOrder(1) )
						If UF2->( MsSeek( xFilial("UF2")+TRBTMP->TR_CODIGO ) )

							cCodCli 	:= UF2->UF2_CLIENT	// codigo do cliente
							cLojaCli 	:= UF2->UF2_LOJA 	// codigo loja do cliente

							lRetorno := U_RUTILE15( "F", TRBTMP->TR_CODIGO, TRBTMP->TR_RELAC, TRBTMP->TR_BASE, @cLog, UF2->UF2_DTATIV, .T.,;
								cCodCli, cLojaCli, .F., /*nVlrComissao*/, /*nVlrTotal*/, /*nPerVend*/, cPrefFun, cTipoFun, cTipoEnt, /*cParcTit*/, /*cLstVend*/, dDataAt )

						EndIf

						TRBTMP->( DbSkip() )
					EndDo

				EndIf

				If Select("TRBTMP") > 0
					TRBTMP->( DbCloseArea() )
				EndIf

				if lRetorno

					cLogRep += CRLF
					cLogRep += "=====================================================" + CRLF
					cLogRep += ">> Comissao de Vendedor reprocessada com sucesso!" + CRLF
					cLogRep += "+ Codigo 		:" + TRB_TIPO->TR_VEND + CRLF
					cLogRep += "+ Nome 			:" + TRB_TIPO->TR_NOME + CRLF
					cLogRep += "=====================================================" + CRLF
					cLogRep += CRLF

				Else

					cLogRep += CRLF
					cLogRep += "=====================================================" + CRLF
					cLogRep += ">> Comissao de Vendedor Não foi Reprocessada!" + CRLF
					cLogRep += "+ Codigo 		:" + TRB_TIPO->TR_VEND + CRLF
					cLogRep += "+ Nome 			:" + TRB_TIPO->TR_NOME + CRLF
					cLogRep += "=====================================================" + CRLF
					cLogRep += CRLF

				EndIf

			EndIf

		ElseIf cTipoCom == "C" .And. TRB_TIPO->TR_COMIS <> 0// para cobrador

			oProcess:IncRegua2("Reprocessando comissao de Cobrador...")

			cLog += CRLF
			cLog += ">> Reprocessando comissao de Cobrador... "

			//Posiciona no Vendedor
			SA3->( DbSetOrder(1) ) //A3_FILIAL+A3_COD
			If SA3->( MsSeek( xFilial("SA3")+TRB_TIPO->TR_VEND ) )

				//Posiciona no Cliclo e Pgto de Comissão
				U18->( DbSetOrder(1) ) //U18_FILIAL+U18_CODIGO
				If U18->( MsSeek( xFilial("U18")+SA3->A3_XCICLO ) )

					// deleto as comissoes existentes
					lRetorno := U_UTILE15B( TRB_TIPO->TR_VEND, U18->U18_DIAFEC, /*cTipModulo*/, @cLog )

				else


					lRetorno := .F.

				EndIf

			Else

				lRetorno := .F.

			EndIf

			// verifico se posso continuar
			If lRetorno

				//------------------------------------
				//Executa query para leitura da tabela
				//------------------------------------
				If Select("TRBTMP") > 0
					TRBTMP->( DbCloseArea() )
				EndIf

				cQuery := " SELECT * FROM "+ oTempDetalhes:GetRealName()
				cQuery += " WHERE TR_ORIGEM LIKE '%TITULO%'"
				cQuery += " AND TR_RELAC = '" + TRB_TIPO->TR_VEND + "'"
				MPSysOpenQuery( cQuery, 'TRBTMP' )

				// reprocesso os contratos de cemiterio
				While lRetorno .And. TRBTMP->( !Eof() )

					cCodCli 	:= AllTrim(TRBTMP->TR_PRODUT)

					lRetorno := U_RUTILE15( "R", TRBTMP->TR_CODIGO, TRBTMP->TR_RELAC, TRBTMP->TR_BASE, @cLog, TRBTMP->TR_DTCOMI, .T.,;
						cCodCli, cLojaCli, .F., /*nVlrComissao*/, /*nVlrTotal*/, /*nPerVend*/, cPrefCtr, cTipoCtr, cTipoEnt,/*cParcTit*/, /*cLstVend*/, dDataAt )

					TRBTMP->( DbSkip() )
				EndDo

			EndIf

			If Select("TRBTMP") > 0
				TRBTMP->( DbCloseArea() )
			EndIf

			// reprocesso as comissoes de cobrador
			if lRetorno

				cLogRep += CRLF
				cLogRep += "=====================================================" + CRLF
				cLogRep += ">> Comissao de Cobrador reprocessada com sucesso!" + CRLF
				cLogRep += "+ Codigo 		:" + TRB_TIPO->TR_VEND + CRLF
				cLogRep += "+ Nome 			:" + TRB_TIPO->TR_NOME + CRLF
				cLogRep += "=====================================================" + CRLF
				cLogRep += CRLF

			Else

				cLogRep += CRLF
				cLogRep += "=====================================================" + CRLF
				cLogRep += ">> Comissao de Cobrador Não foi Reprocessada!" + CRLF
				cLogRep += "+ Codigo 		:" + TRB_TIPO->TR_VEND + CRLF
				cLogRep += "+ Nome 			:" + TRB_TIPO->TR_NOME + CRLF
				cLogRep += "=====================================================" + CRLF
				cLogRep += CRLF

			EndIf


		EndIf

		TRB_TIPO->( DbSkip() )
	EndDo

	// mostro o log de reprocessamento
	if !Empty( cLogRep )
		ShowLog( cLogRep )
	EndIf

	cLog += cLogRep

	cLog += CRLF
	cLog += ">> Funcao ReprComissao [Fim] "

	RestArea( aArea )

Return( lRetorno )

/*/{Protheus.doc} CriaTabTipo
description
@type function
@version 1.0
@author g.sampaio
@since 01/06/2021
@param cArqTrb, character, param_description
@param oTempTipo, object, param_description
@return return_type, return_description
/*/
Static Function CriaTabTipo( cArqTrb, oTempTipo )

	Local aCampos             := {}
	Local aIndiceTipo		  := {"TR_ITEM","TR_TIPO","TR_VEND"}

	Default cArqTrb             := "TRBEND"
	Default oTempEnderecados    := Nil

	///////////////////////////////////////////////////////////////////////////
	//////////////////    MONTO A ESTRUTURA DA TABELA    //////////////////////
	///////////////////////////////////////////////////////////////////////////

	//Array contendo os campos da tabela temporária
	Aadd( aCampos, { "TR_ITEM" 		, "C" , 3 						, 0						})
	Aadd( aCampos, { "TR_TIPO" 		, "C" , 20 						, 0						})
	Aadd( aCampos, { "TR_VEND" 		, "C" , TamSX3("A3_COD")[1] 	, 0						})
	Aadd( aCampos, { "TR_NOME"		, "C" , TamSX3("A3_NOME")[1] 	, 0						})
	Aadd( aCampos, { "TR_VENCTO"	, "D" , 8 						, 0						})
	Aadd( aCampos, { "TR_QUANT"		, "N" , 3 						, 0						})
	Aadd( aCampos, { "TR_BASE"		, "N" , TamSX3("E3_BASE")[1] 	, TamSX3("E3_BASE")[2]	})
	Aadd( aCampos, { "TR_PORC"		, "N" , TamSX3("E3_PORC")[1] 	, TamSX3("E3_PORC")[2]	})
	Aadd( aCampos, { "TR_COMIS"		, "N" , TamSX3("E3_COMIS")[1] 	, TamSX3("E3_COMIS")[2]	})

	///////////////////////////////////////////////////////////////////////////
	//////////////////      CRIO A TABELA TEMPORARIA     //////////////////////
	///////////////////////////////////////////////////////////////////////////

	//Antes de criar a tabela, verificar se a mesma já foi aberta
	If Select( cArqTrb ) > 0
		(cArqTrb)->(DbCloseArea())
	Endif

	// zero o objeto
	if oTempTipo <> NIL
		FreeObj(oTempTipo)
	endIf

	//-------------------
	//Criação do objeto
	//-------------------
	oTempTipo := FWTemporaryTable():New( cArqTrb )

	oTempTipo:SetFields( aCampos )
	oTempTipo:AddIndex("01", aIndiceTipo )

	//------------------
	//Criação da tabela
	//------------------
	oTempTipo:Create()

Return(Nil)

/*/{Protheus.doc} CriaTabDetalhes
description
@type function
@version  
@author g.sampaio
@since 01/06/2021
@param cTrbDetalhes, character, param_description
@param oTempDetalhes, object, param_description
@return return_type, return_description
/*/
Static Function CriaTabDetalhes(cArqTrb, oTempDetalhes)

	Local aCampos             := {}
	Local aIndiceDetalhes	  := {"TR_ITEM","TR_ORIGEM","TR_RELAC","TR_CODIGO"}

	Default cArqTrb             := "TRBEND"
	Default oTempDetalhes    	:= Nil

	///////////////////////////////////////////////////////////////////////////
	//////////////////    MONTO A ESTRUTURA DA TABELA    //////////////////////
	///////////////////////////////////////////////////////////////////////////

	//Array contendo os campos da tabela temporária
	Aadd( aCampos, { "TR_ITEM" 		, "C" , 3 						, 0							})
	Aadd( aCampos, { "TR_ORIGEM" 	, "C" , 20 						, 0							})
	Aadd( aCampos, { "TR_CODIGO" 	, "C" , 6					 	, 0							})
	Aadd( aCampos, { "TR_DTCOMI" 	, "D" , 8 						, 0							})
	Aadd( aCampos, { "TR_VEND" 		, "C" , TamSX3("A3_COD")[1] 	, 0							})
	Aadd( aCampos, { "TR_NOME"		, "C" , TamSX3("A3_NOME")[1] 	, 0							})
	Aadd( aCampos, { "TR_PRODUT"	, "C" , TamSX3("B1_COD")[1] 	, 0							})
	Aadd( aCampos, { "TR_DSCPRO"	, "C" , TamSX3("B1_DESC")[1] 	, 0							})
	Aadd( aCampos, { "TR_QTDPV"		, "N" , TamSX3("C6_QTDVEN")[1] 	, TamSX3("C6_QTDVEN")[2]	})
	Aadd( aCampos, { "TR_PRCPV"		, "N" , TamSX3("C6_PRCVEN")[1] 	, TamSX3("C6_PRCVEN")[2]	})
	Aadd( aCampos, { "TR_BASE"		, "N" , TamSX3("E3_BASE")[1] 	, TamSX3("E3_BASE")[2]		})
	Aadd( aCampos, { "TR_PORC"		, "N" , TamSX3("E3_PORC")[1] 	, TamSX3("E3_PORC")[2]		})
	Aadd( aCampos, { "TR_COMIS"		, "N" , TamSX3("E3_COMIS")[1] 	, TamSX3("E3_COMIS")[2]		})
	Aadd( aCampos, { "TR_HIST"		, "C" , 50					 	, 0							})
	Aadd( aCampos, { "TR_RELAC"		, "C" , TamSX3("A3_COD")[1]	 	, 0							})

///////////////////////////////////////////////////////////////////////////
//////////////////      CRIO A TABELA TEMPORARIA     //////////////////////
///////////////////////////////////////////////////////////////////////////

	//Antes de criar a tabela, verificar se a mesma já foi aberta
	If Select( cArqTrb ) > 0
		(cArqTrb)->(DbCloseArea())
	Endif

	// zero o objeto
	if oTempDetalhes <> NIL
		FreeObj(oTempDetalhes)
	endIf

	//-------------------
	//Criação do objeto
	//-------------------
	oTempDetalhes := FWTemporaryTable():New( cArqTrb )

	oTempDetalhes:SetFields( aCampos )
	oTempDetalhes:AddIndex("01", aIndiceDetalhes )

	//------------------
	//Criação da tabela
	//------------------
	oTempDetalhes:Create()

Return(Nil)
