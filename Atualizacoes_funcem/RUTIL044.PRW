#Include "TOTVS.CH"
#include "topconn.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE "FWBROWSE.CH"

#DEFINE LOGO_PACOTE "AVGBOX1.PNG"
#DEFINE CRLF		CHR(13)+CHR(10)

/*/{Protheus.doc} RUTIL044
Rotina de processamento de comissões para :
Vendedor, Cobrador, Supervisor e Gerente 
@author g.sampaio
@since 13/06/2019
@version P12
@param nulo
@return nulo
/*/

User Function RUTIL044()

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
	Local oComissaoVirtus 	:= Nil

	// inicio a classe de comissao virtus
	oComissaoVirtus := ComissaoVirtus():New()

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
	@ 060, 010 SAY oSay5 	PROMPT "Para ?" 			SIZE 050, 007 OF oPanelFiltro COLORS 0, 16777215 PIXEL

	// preenche os campos automaticos
	cGet1 	:= Space( TamSX3("A3_COD")[1] )
	cGet2	:= Replicate( "Z", TamSX3("A3_COD")[1] )
	dGet3	:= FirstDate( dDataBase )
	dGet4	:= LastDate( dDataBase )

	@ 019, 060 MSGET oGet1 VAR cGet1 F3 "SA3" PICTURE "@!" 		SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON
	@ 039, 060 MSGET oGet2 VAR cGet2 F3 "SA3" PICTURE "@!" 		SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL HASBUTTON
	@ 059, 060 MSCOMBOBOX oComboBo1 VAR nComboBo1 				ITEMS {"Ambos","Vendedor","Cobrador","Surpevisor","Gerente", "Atendente"} SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL

	// preenche os campos automaticos
	oComboBo1:nAt	:= 1

	@ 120, 010 BUTTON oBut3 PROMPT "Processar" 		SIZE 041, 012 OF oDlg PIXEL ACTION ProcessaComissao( cGet1, cGet2, dGet3, dGet4, oComboBo1:nAt,  @cLog, cTrbTipo,;
		cTrbDetalhes, @oBrowseTipo, @oBrowseDetalhes, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun, @oTempTipo, @oTempDetalhes, @oComissaoVirtus )
	@ 140, 010 BUTTON oBut4 PROMPT "Visualizar Log" SIZE 041, 012 OF oDlg PIXEL ACTION ShowLog(@cLog)
	@ 160, 010 BUTTON oBut4 PROMPT "Imprimir" 		SIZE 041, 012 OF oDlg PIXEL ACTION U_RUTILR10( oTempTipo, oTempDetalhes, oComissaoVirtus:dDataDe, oComissaoVirtus:dDataAte )

	@ 002, 005 GROUP oGroupRod TO 003 , aCords[2,3] - 5 	PROMPT "" OF oPanelRod COLOR 0, 16777215 PIXEL

	@ 007, (aCords[2,3] - 55) 	BUTTON oBut1 PROMPT "Confirmar" SIZE 050, 015 OF oPanelRod PIXEL ACTION (lRet := .T., ConfirmarTela( oDlg, @cLog, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun, oTempDetalhes, dGet4, @oComissaoVirtus ) )
	@ 007, (aCords[2,3] - 110)	BUTTON oBut2 PROMPT "Cancelar" SIZE 050, 015 OF oPanelRod PIXEL ACTION (lRet := .F.,oDlg:End())

	// monto o grid de associados
	GridTipo( oPanelTipo, @cTrbTipo, @aIndiceTipo, @oBrowseTipo, @oBrowseDetalhes, @oTempTipo )

	// monto o grid de serviços utilizados
	GridDetalhes( oPanelDetalhes, @cTrbDetalhes, @aIndiceDetalhes, @oBrowseDetalhes, @oBrowseTipo, @oTempDetalhes )

	oRelac := FWBrwRelation():New()
	oRelac:AddRelation( oBrowseTipo , oBrowseDetalhes , { { 'TR_RELAC', 'TR_VEND' } } )
	oRelac:Activate()

	ACTIVATE MSDIALOG oDlg CENTERED

	FreeObj(oComissaoVirtus)
	oComissaoVirtus := Nil

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
	Local oTR_PARCELAColumn	:= Nil
	Local oTR_COMISColumn	:= Nil
	Local oTR_DSCPROColumn	:= Nil
	Local oTR_DTCOMIColumn	:= Nil
	Local oTR_ITEMColumn	:= Nil
	Local oTR_HISTColumn	:= Nil
	Local oTR_ORIGEMColumn	:= Nil
	Local oTR_PORCColumn	:= Nil
	Local oTR_PRCPVColumn	:= Nil
	Local oTR_PRODUTColumn	:= Nil
	Local oTR_QTDPVColumn	:= Nil
	Local oTR_RELACColumn	:= Nil
	Local oTR_DTPAGColumn	:= Nil

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

	// Coluna de Codigo
	oTR_PARCELAColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_PARCELAColumn:SetData( { || TR_PARCELA } )	// campo referente a coluna
	oTR_PARCELAColumn:SetTitle("Parcela")			// titulo da coluna
	oTR_PARCELAColumn:SetSize(5)						// tamanho da coluna
	oTR_PARCELAColumn:SetPicture("@!")				// mascara da coluna
	oBrowse:SetColumns({oTR_PARCELAColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Data de Comissao
	oTR_DTCOMIColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_DTCOMIColumn:SetData( { || TR_DTCOMI } )	// campo referente a coluna
	oTR_DTCOMIColumn:SetTitle("Dt Comissao")		// titulo da coluna
	oTR_DTCOMIColumn:SetSize(5)						// tamanho da coluna
	oTR_DTCOMIColumn:SetPicture("@D")				// mascara da coluna
	oBrowse:SetColumns({oTR_DTCOMIColumn})			// adiciono o objeto da coluna no browse

	// Coluna de Data de Comissao
	oTR_DTPAGColumn := FWBrwColumn():New()			// instancio da classe do objeto
	oTR_DTPAGColumn:SetData( { || TR_DTPAG } )	// campo referente a coluna
	oTR_DTPAGColumn:SetTitle("Dt Pagamento")		// titulo da coluna
	oTR_DTPAGColumn:SetSize(5)						// tamanho da coluna
	oTR_DTPAGColumn:SetPicture("@D")				// mascara da coluna
	oBrowse:SetColumns({oTR_DTPAGColumn})			// adiciono o objeto da coluna no browse

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
	Local oTR_BASEColumn		:= Nil
	Local oTR_NOMEColumn		:= Nil
	Local oTR_VENDColumn		:= Nil
	Local oTR_TIPOColumn		:= Nil
	Local oTR_ITEMColumn		:= Nil
	Local oTR_QUANTColumn		:= Nil
	Local oTR_PORCColumn        := Nil

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

	// Coluna de quantidade
	oTR_QUANTColumn := FWBrwColumn():New()						// instancio da classe do objeto
	oTR_QUANTColumn:SetData( { || TR_QUANT } )					// campo referente a coluna
	oTR_QUANTColumn:SetTitle("Quantidade")						// titulo da coluna
	oTR_QUANTColumn:SetSize(15)									// tamanho da coluna
	oTR_QUANTColumn:SetPicture("@E 999")						// mascara da coluna
	oBrowse:SetColumns({oTR_QUANTColumn})						// adiciono o objeto da coluna no browse

	// Coluna de Valor Base
	oTR_BASEColumn := FWBrwColumn():New()							// instancio da classe do objeto
	oTR_BASEColumn:SetData( { || TR_BASE } )						// campo referente a coluna
	oTR_BASEColumn:SetTitle("Vlr.Base (R$)")								// titulo da coluna
	oTR_BASEColumn:SetSize(15)										// tamanho da coluna
	oTR_BASEColumn:SetPicture(PesqPict("SE3","E3_BASE"))			// mascara da coluna
	oTR_BASEColumn:SetEdit(.T.)										// coloco a coluna como editavel
	oTR_BASEColumn:SetReadVar("TR_BASE")							// adiciono a variavel em memoria para edicao
	oTR_BASEColumn:SetValid( { || BaseValida( cArqTrb, oBrowse, oBrowseRelac ) } )
	oBrowse:SetColumns({oTR_BASEColumn})							// adiciono o objeto da coluna no browse

	// Coluna de Valor Base
	oTR_PORCColumn := FWBrwColumn():New()							// instancio da classe do objeto
	oTR_PORCColumn:SetData( { || TR_PORC } )						// campo referente a coluna
	oTR_PORCColumn:SetTitle("Percentual (%)")								// titulo da coluna
	oTR_PORCColumn:SetSize(15)										// tamanho da coluna
	oTR_PORCColumn:SetPicture(PesqPict("SE3","E3_BASE"))			// mascara da coluna
	oTR_PORCColumn:SetEdit(.T.)										// coloco a coluna como editavel
	oTR_PORCColumn:SetReadVar("TR_PORC")							// adiciono a variavel em memoria para edicao
	oTR_PORCColumn:SetValid( { || BaseValida( cArqTrb, oBrowse, oBrowseRelac ) } )
	oBrowse:SetColumns({oTR_PORCColumn})							// adiciono o objeto da coluna no browse

	// Coluna de Comissao
	oTR_COMISColumn := FWBrwColumn():New()							// instancio da classe do objeto
	oTR_COMISColumn:SetData( { || TR_COMIS } )						// campo referente a coluna
	oTR_COMISColumn:SetTitle("Comissao (R$)")							// titulo da coluna
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

Static Function ConfirmarTela( oDlg, cLog, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun, oTempDetalhes, dDataAt, oComissaoVirtus )

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

	oComissaoVirtus:cLogComissao += CRLF
	oComissaoVirtus:cLogComissao += ">> Funcao ConfirmarTela [Inicio] "

	// execuco a comissao
	oComissaoVirtus:oProcess := MsNewProcess():New({|lEnd| lRetorno := oComissaoVirtus:Efetiva(@lEnd) },"Processamento das Comissões","Aguarde! Gerando so Registros de comissões...",.T.)
	oComissaoVirtus:oProcess:Activate()

	// se estiver tudo certo fecho a janela
	If lRetorno
		oDlg:End()
	EndIf

	oComissaoVirtus:cLogComissao += CRLF
	oComissaoVirtus:cLogComissao += ">> Funcao ConfirmarTela [Fim] "

	// gero a log de comissao
	If !Empty(oComissaoVirtus:cLogComissao)
		CriaLogComissao(oComissaoVirtus:cLogComissao)
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
		oBrowseDetalhes, cPrefCtr, cTipoCtr, cTipoEnt, cPrefFun, cTipoFun, oTempTipo, oTempDetalhes, oComissaoVirtus )

	Local aDadosTipo        := {}
	Local aDadosDetalhes    := {}
	Local oProcess			:= Nil
	Local lEnd 				:= .F.
	Local nVendedor			:= 0
	Local nDetalhes         := 0

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

		// limpa os registros ja existentes
		LimpaDados( cTrbTipo )

		// limpa os registros ja existentes
		LimpaDados( cTrbDetalhes )

		// atribui valores as variaveis da classe
		oComissaoVirtus:cVendeDe 			:= cVendDe
		oComissaoVirtus:cVendeAte 			:= cVendAt
		oComissaoVirtus:dDataDe 			:= dDataDe
		oComissaoVirtus:dDataAte 			:= dDataAt
		oComissaoVirtus:nOpc				:= nOpc
		oComissaoVirtus:oProcess			:= oProcess

		// execuco a comissao
		oComissaoVirtus:oProcess := MsNewProcess():New({|lEnd| oComissaoVirtus:InitComissao(@lEnd) },"Processamento das Comissões","Aguarde! Processando as comissões...",.T.)
		oComissaoVirtus:oProcess:Activate()

		// vou popular a tabela de dados - tipo
		If Len( oComissaoVirtus:aCalcVend ) > 0

			For nVendedor := 1 To Len(oComissaoVirtus:aCalcVend)

				// preencho o array de dados
				aAuxTipo := {}
				Aadd( aAuxTipo, { "TR_TIPO" 	, TipoVendedor(oComissaoVirtus:aCalcVend[nVendedor, 1])			})
				Aadd( aAuxTipo, { "TR_VEND" 	, oComissaoVirtus:aCalcVend[nVendedor, 2]	})
				Aadd( aAuxTipo, { "TR_NOME"		, oComissaoVirtus:aCalcVend[nVendedor, 3]	})
				Aadd( aAuxTipo, { "TR_QUANT"	, oComissaoVirtus:aCalcVend[nVendedor, 4]	})
				Aadd( aAuxTipo, { "TR_BASE"		, oComissaoVirtus:aCalcVend[nVendedor, 5]	})
				Aadd( aAuxTipo, { "TR_PORC"		, oComissaoVirtus:aCalcVend[nVendedor, 7]	})
				Aadd( aAuxTipo, { "TR_COMIS"	, oComissaoVirtus:aCalcVend[nVendedor, 6]	})

				// preencho o array de dados
				Aadd( aDadosTipo, aAuxTipo )

				CriaTabTipo(cTrbTipo, @oTempTipo)

				// chama a funcao para gravar os registros de tipo
				GeraRegistros( aDadosTipo, cTrbTipo, /*lGeraDados*/, @oBrowseTipo, @oBrowseDetalhes )

				// verifico se tem detalhes da comissao
				If Len(oComissaoVirtus:aCalcVend[nVendedor, 8]) > 0

					// array de detalhes da composicao
					aDetalhes := oComissaoVirtus:aCalcVend[nVendedor, 8]

					// percorro os dados de comissao
					For nDetalhes := 1 To Len(aDetalhes)

						aAuxDetalhes := {}
						Aadd(aAuxDetalhes,{"TR_ORIGEM" 	, OrigemRotina(aDetalhes[nDetalhes, 1])		})
						Aadd(aAuxDetalhes,{"TR_CODIGO" 	, aDetalhes[nDetalhes, 2]					})
						Aadd(aAuxDetalhes,{"TR_PARCELA"	, aDetalhes[nDetalhes, 3]					})
						Aadd(aAuxDetalhes,{"TR_DTCOMI" 	, aDetalhes[nDetalhes, 4] 					})
						Aadd(aAuxDetalhes,{"TR_DTPAG" 	, aDetalhes[nDetalhes, 5] 					})
						Aadd(aAuxDetalhes,{"TR_PRODUT"	, aDetalhes[nDetalhes, 6] 					})
						Aadd(aAuxDetalhes,{"TR_DSCPRO"	, aDetalhes[nDetalhes, 7]					})
						Aadd(aAuxDetalhes,{"TR_QTDPV"	, aDetalhes[nDetalhes, 8]					})
						Aadd(aAuxDetalhes,{"TR_PRCPV"	, aDetalhes[nDetalhes, 9]					})
						Aadd(aAuxDetalhes,{"TR_BASE"	, aDetalhes[nDetalhes, 10]					})
						Aadd(aAuxDetalhes,{"TR_PORC"	, aDetalhes[nDetalhes, 11]					})
						Aadd(aAuxDetalhes,{"TR_COMIS"	, aDetalhes[nDetalhes, 12]					})
						Aadd(aAuxDetalhes,{"TR_HIST"	, aDetalhes[nDetalhes, 13]				    })
						Aadd(aAuxDetalhes,{"TR_RELAC"	, aDetalhes[nDetalhes, 14]					})

						// alimento o array de comissoes
						Aadd( aDadosDetalhes,  aAuxDetalhes)

					Next nDetalhes

				EndIf

				// vou popular a tabela de dados - detalhes
				If Len( aDadosDetalhes ) > 0

					CriaTabDetalhes(cTrbDetalhes, @oTempDetalhes)

					GeraRegistros( aDadosDetalhes, cTrbDetalhes, /*lGeraDados*/, @oBrowseTipo, @oBrowseDetalhes )

				EndIf

			Next nVendedor

		EndIf

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

		cRetorno := "VENDA DE SERVICOS"

	ElseIf cOrigem == "P" // origem pedido de venda

		cRetorno :="PD VENDA"

	ElseIf cOrigem == "C" // origem contrato cemiterio

		cRetorno := "CTR CEMITERIO"

	ElseIf cOrigem == "F" // origem contrato funeraria

		cRetorno := "CTR FUNERARIA"

	ElseIF cOrigem == "R" // recebimento

		cRetorno	:= "RECEBE TITULO"

	ElseIF cOrigem == "G"

		cRetorno := "MENSAL PLN EMP"

	ElseIF cOrigem == "V"

		cRetorno := "VENDA PLN EMP"

	ElseIF cOrigem == "M"

		cRetorno := "MIGRACAO"
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
	ElseIf cTipoVendedor == "A"
		cRetorno := "A - ATENDENTE"
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

Return(Nil)

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
	Aadd( aCampos, { "TR_PARCELA" 	, "C" , TamSX3("E3_PARCELA")[1]	, 0							})
	Aadd( aCampos, { "TR_DTCOMI" 	, "D" , 8 						, 0							})
	Aadd( aCampos, { "TR_DTPAG" 	, "D" , 8 						, 0							})
	Aadd( aCampos, { "TR_PRODUT"	, "C" , TamSX3("B1_COD")[1] 	, 0							})
	Aadd( aCampos, { "TR_DSCPRO"	, "C" , TamSX3("B1_DESC")[1] 	, 0							})
	Aadd( aCampos, { "TR_QTDPV"		, "N" , TamSX3("C6_QTDVEN")[1] 	, TamSX3("C6_QTDVEN")[2]	})
	Aadd( aCampos, { "TR_PRCPV"		, "N" , TamSX3("C6_PRCVEN")[1] 	, TamSX3("C6_PRCVEN")[2]	})
	Aadd( aCampos, { "TR_BASE"		, "N" , TamSX3("E3_BASE")[1] 	, TamSX3("E3_BASE")[2]		})
	Aadd( aCampos, { "TR_PORC"		, "N" , TamSX3("E3_PORC")[1] 	, TamSX3("E3_PORC")[2]		})
	Aadd( aCampos, { "TR_COMIS"		, "N" , TamSX3("E3_COMIS")[1] 	, TamSX3("E3_COMIS")[2]		})
	Aadd( aCampos, { "TR_HIST"		, "C" , 150					 	, 0							})
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
