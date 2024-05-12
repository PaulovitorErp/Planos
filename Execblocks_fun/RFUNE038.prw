#Include "Protheus.ch"
#Include "TopConn.ch"
#include "FWMVCDef.ch"
#INCLUDE 'FWEditPanel.CH'

/*/{Protheus.doc} RFUNE038
Rotina Visualizar regras que fizeram parte da composicao 
do valor das parcelas financeiras
@author Leandro Rodrigues
@since 24/08/2019
@param nao recece
@return Nil
/*/
User Function RFUNE038()

Local oBrowse
Local cName     := Funname()

Private oTotais	:= NIL
Private aRotina := {}

SetFunName("RFUNE038")

oBrowse := FWmBrowse():New()

oBrowse:SetAlias("UF2")
oBrowse:SetDescription("Parcelas x Regras")  

oBrowse:Activate()

Return Nil


/*/{Protheus.doc} MenuDef
Função que cria os menus			
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo.
/*/
Static Function MenuDef()

Local aRotina 	:= {}

ADD OPTION aRotina Title 'Visualizar' 			Action "VIEWDEF.RFUNE038"				OPERATION 2 ACCESS 0
ADD OPTION aRotina Title "Alterar"    			Action "VIEWDEF.RFUNE038"				OPERATION 4 ACCESS 0
ADD OPTION aRotina Title "Excluir"    			Action "VIEWDEF.RFUNE038"				OPERATION 5 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Função que cria o objeto model			
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruUF2 		:= DefStrModel("UF2")
Local oStruUJR 		:= DefStrModel("UJR")						//FWFormStruct(1,"UJR",/*bAvalCampo*/,/*lViewUsado*/ )
Local oStruSE1 		:= DefStrModel("SE1") 
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("PFUNE38P",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("UF2MASTER",/*cOwner*/,oStruUF2)

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({"UF2_FILIAL","UF2_CODIGO"})

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid("SE1DETAIL","UF2MASTER",oStruSE1,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

oModel:AddGrid("UJRDETAIL","UF2MASTER",oStruUJR,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation("SE1DETAIL", {{"E1_FILIAL", 'xFilial("SE1")'},{"E1_XCTRFUN","UF2_CODIGO"}},SE1->(IndexKey(1)))
oModel:SetRelation("UJRDETAIL", {{"UJR_FILIAL",'xFilial("UJR")'},{"UJR_CODIGO","UF2_CODIGO"}},UJR->(IndexKey(1)))


// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel("UF2MASTER"):SetDescription("Dados do Contrato")
oModel:GetModel("SE1DETAIL"):SetDescription("Dados Financeiro")
oModel:GetModel("UJRDETAIL"):SetDescription("Regras de Contrato")

// não permite receber inserção de linha.
oModel:GetModel('UF2MASTER'):SetOnlyQuery()
oModel:GetModel('UF2MASTER'):SetOnlyView()

oModel:GetModel('SE1DETAIL'):SetOptional( .T. )
oModel:GetModel('SE1DETAIL'):SetOnlyQuery()
oModel:GetModel('SE1DETAIL'):SetNoInsertLine(.T.)

oModel:GetModel('UJRDETAIL'):SetOptional( .T. )
oModel:GetModel('UJRDETAIL'):SetOnlyQuery()
oModel:GetModel('UJRDETAIL'):SetOnlyView()
oModel:GetModel('UJRDETAIL'):SetNoInsertLine(.T.)


Return oModel


/*/{Protheus.doc} ModelDef
Função que cria o objeto View			
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function ViewDef()


// Cria a estrutura a ser usada na View
Local oStruUF2 		:= DefStrView("UF2")
Local oStruUJR		:= DefStrView("UJR")		// FWFormStruct(2,"UJR")
Local oStruSE1 		:= DefStrView("SE1")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   		:= FWLoadModel("RFUNE038")
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_UF2",oStruUF2,"UF2MASTER")

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid("VIEW_SE1",oStruSE1,"SE1DETAIL")
oView:AddGrid("VIEW_UJR",oStruUJR,"UJRDETAIL")

// Cria componentes nao MVC
oView:AddOtherObject("RESUMO", {|oPanel| RefreshParcela(oPanel) })


oView:CreateVerticalBox("PANEL_ESQUERDA"		, 100)   
oView:CreateVerticalBox("PANEL_DIREITA"			, 100,,.T.)

oView:CreateHorizontalBox("PAINEL_CABEC",	0	,	"PANEL_ESQUERDA")    
oView:CreateHorizontalBox("PAINEL_ITENS",	100	,	"PANEL_ESQUERDA") 

oView:CreateVerticalBox("PAINEL_ITENS_C", 50, "PAINEL_ITENS")
oView:CreateVerticalBox("PAINEL_ITENS_E", 50, "PAINEL_ITENS")

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView("VIEW_UF2"	,"PAINEL_CABEC")
oView:SetOwnerView("VIEW_SE1"	,"PAINEL_ITENS_C")
oView:SetOwnerView("VIEW_UJR"	,"PAINEL_ITENS_E")
oView:SetOwnerView("RESUMO"		,"PANEL_DIREITA")

// Liga a identificacao do componente
oView:EnableTitleView("VIEW_SE1","Dados Financeiro")
oView:EnableTitleView("VIEW_UJR","Regras de Contrato")

oView:SetAfterViewActivate({|oView| U_IniCpoTela(oView)  } )

oView:SetViewProperty('VIEW_SE1', "CHANGELINE", {{|oView| AtualRegra(oView) }}) 

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk( {||.T.} )

// Habilito a barra de progresso na abertura da tela
oView:SetProgressBar(.T.)


Return oView          

/*/{Protheus.doc} ModelDef
Função que cria estrutura da SE1 par model			
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function DefStrModel(cAlias)

Local aArea    		:= GetArea()
Local bValid   		:= { || }
Local bWhen    		:= { || }
Local bRelac   		:= { || }
Local aAux     		:= {}
Local aCampos		:= {}
Local oStruct 		:= FWFormModelStruct():New()
Local aSX2			:= {}
Local aSIX			:= {}
Local aSX3			:= {}
Local aSX7			:= {}
Local nX			:= 1
Local oSX			:= UGetSxFile():New
//--------
// Campos
//--------
If cAlias == "SE1"
    aCampos	:= {"E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO",;
				"E1_EMISSAO","E1_VENCTO","E1_VALOR","E1_SALDO"} 

elseif cAlias == "UJR"

	aCampos	:= {"UJR_CODBEN","UJR_NOMBEN","UJR_REGRA","UJR_DESREG","UJR_ITEMRE","UJR_TIPORE",;
				"UJR_PREFIX","UJR_NUM","UJR_TIPO","UJR_VLRINI","UJR_VLRFIM","UJR_QTDE","UJR_VLTOT","UJR_PARCDE","UJR_PARCAT","UJR_DTREAJ" } 

else
    aCampos	:= {"UF2_CODIGO"} 
endif

//--------
// Tabela
//--------
aSX2:= oSX:GetInfoSX2(cAlias)

oStruct:AddTable(aSX2[1,2]:cCHAVE,StrTokArr(Alltrim(aSX2[1,2]:cUNICO), '+') ,Alltrim(aSX2[1,2]:cNOME))

aSIX:= oSX:GetInfoSIX(cAlias)
	
//---------                                             	
// Indices
//---------
nOrdem := 0
For nX:= 1 to Len(aSIX)
	
	oStruct:AddIndex(nOrdem++,aSIX[nX,2]:cORDEM,aSIX[nX,2]:cCHAVE,SIXDescricao(),aSIX[nX,2]:cF3,aSIX[nX,2]:cNICKNAME ,(aSIX[nX,2]:cSHOWPESQ <> 'N'))
Next nX

//--------
// Campos
//--------

For nX := 1 To Len(aCampos)

	aSX3:= oSX:GetInfoSX3(,aCampos[nX])

	if Len(aSX3) > 0		

		bValid 	:= Nil
		bWhen  	:= Nil

		//Carregp inicializador padrao para o campo
		if aCampos[nX] == "UJR_REGRA"
			
			bRelac := {|| Posicione("UJ5",1,xFilial("UJ5")+UJR->UJR_REGRA,"UJ5_DESCRI")}
		Elseif aCampos[nX] == "UJR_CODBEN"
			
			bRelac := {|| Posicione("UF4",1,xFilial("UF4")+UJR->UJR_CODIGO+UJR->UJR_CODBEN,"UF4_NOME")}
		Endif

		aBox	:= StrTokArr(AllTrim(aSX3[1,2]:cCBOX),';' )
			
		oStruct:AddField( 			;
		AllTrim(aSX3[1,2]:cTITULO), ;	// [01] Titulo do campo
		AllTrim(aSX3[1,2]:cDESCRI), ;	// [02] ToolTip do campo
		aSX3[1,2]:cCAMPO,	 		;	// [03] Id do Field
		aSX3[1,2]:cTIPO, 			;	// [04] Tipo do campo
		aSX3[1,2]:nTAMANHO,			;	// [05] Tamanho do campo
		aSX3[1,2]:nDECIMAL,			;	// [06] Decimal do campo
		bValid, 					;	// [07] Code-block de valida?o do campo
		bWhen, 						;	// [08] Code-block de valida?o When do campo
		aBox, 						;	// [09] Lista de valores permitido do campo
		.F., 						;	// [10] Indica se o campo tem preenchimento obrigat?io
		bRelac, 					;	// [11] Code-block de inicializacao do campo
		NIL, 						;	// [12] Indica se trata-se de um campo chave
		NIL, 						;	// [13] Indica se o campo pode receber valor em uma opera?o de update.
		(aSX3[1,2]:cCONTEXT == 'V'))    // [14] Indica se o campo ?virtual	
	Endif
Next nX


RestArea(aArea)

Return oStruct


/*/{Protheus.doc} ModelDef
Função que cria estrutura da SE1 par View			
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

Static Function DefStrView(cAlias)

Local oStruct   	:= FWFormViewStruct():New()
Local aArea     	:= GetArea()
Local aCampos		:= {}
Local aEdit			:= {}
Local aCombo    	:= {}
Local aAux      	:= {}
Local nInitCBox 	:= 0
Local nMaxLenCb 	:= 0
Local nI        	:= 1  
Local nX			:= 1
Local cGSC      	:= ''  
Local oSX			:= UGetSxFile():New

//--------
// Campos
//--------
If cAlias == "SE1"
    aCampos	:= {"E1_PREFIXO","E1_NUM","E1_PARCELA","E1_TIPO",;
				"E1_EMISSAO","E1_VENCTO","E1_VALOR"} 

elseif cAlias == "UJR"

	aCampos	:= {"UJR_CODBEN","UJR_NOMBEN","UJR_REGRA","UJR_DESREG","UJR_ITEMRE","UJR_TIPORE",;
				"UJR_PREFIX","UJR_NUM","UJR_TIPO","UJR_VLRINI","UJR_VLRFIM","UJR_QTDE","UJR_VLTOT","UJR_PARCDE","UJR_PARCAT","UJR_DTREAJ" } 
else
    aCampos	:= {"UF2_CODIGO"} 
endif

For nX := 1 To Len(aCampos)

	aSX3:= oSX:GetInfoSX3(,aCampos[nX])

	If Len(aSX3) > 0
		
		aCombo := {}
		
		If !Empty(aSX3[1,2]:cCBOX)
			
			nInitCBox := 0
			nMaxLenCb := 0
			
			aAux := RetSX3Box( aSX3[1,2]:cCBOX , @nInitCBox, @nMaxLenCb,aSX3[1,2]:nTAMANHO )
			
			For nI := 1 To Len(aAux)
				aAdd( aCombo, aAux[nI][1] )
			Next nI
			
		EndIf
		
		bPictVar := FwBuildFeature( 4, aSX3[1,2]:cPICTVAR )
		cGSC     := IIf( Empty(aSX3[1,2]:cCBOX) , IIf( aSX3[1,2]:cTIPO == 'L', 'CHECK', 'GET' ) , 'COMBO' )
		
		oStruct:AddField( 			;
		aSX3[1,2]:cCAMPO, 			;	// [01] Campo
		aSX3[1,2]:cORDEM,			;	// [02] Ordem
		AllTrim(aSX3[1,2]:cTITULO),	;	// [03] Titulo
		AllTrim(aSX3[1,2]:cDESCRI), 		;	// [04] Descricao
		NIL, 						;	// [05] Help
		cGSC, 						;	// [06] Tipo do campo   COMBO, Get ou CHECK
		aSX3[1,2]:cPICTURE,			;	// [07] Picture
		bPictVar, 					;	// [08] PictVar
		aSX3[1,2]:cF3, 				;	// [09] F3
		aSX3[1,2]:cVISUAL <> 'V', 	;	// [10] Editavel
		aSX3[1,2]:cFOLDER, 			;	// [11] Folder
		aSX3[1,2]:cFOLDER, 			;	// [12] Group
		aCombo,						;	// [13] Lista Combo
		nMaxLenCb, 					;	// [14] Tam Max Combo
		aSX3[1,2]:cINIBRW, 			;	// [15] Inic. Browse
		(aSX3[1,2]:cCONTEXT == 'V'))   	// [16] Virtual
	
	endif
	
Next nX

//---------
// Folders
//---------

aSXA:= oSX:GetInfoSXA(cAlias)

For nX:= 1 To Len(aSXA)

	oStruct:AddFolder(aSXA[nX,2]:cORDEM,aSXA[nX,2]:cDESCRIC)
		
Next nX

RestArea(aArea)

Return oStruct

/*/{Protheus.doc} RFUNE038
Rotina carregar dados da rotina
@author Leandro Rodrigues
@since 24/08/2019
@param nao recece
@return Nil
/*/
User Function IniCpoTela(oView)

Local nOperation 	:= oView:GetOperation()
Local oModel   		:= FWLoadModel("RFUNE038")


//atualiza grid de regras x Parcela para a primeira parcela
AtualRegra(oView,FwFldGet("E1_PARCELA",1),FwFldGet("E1_TIPO",1))


Return 

/*/{Protheus.doc} RFUNE038
Rotina para montar tela de visualizacao
das parcelas x Regras
@author Leandro Rodrigues
@since 24/08/2019
@param nao recece
@return Nil
/*/

User Function RFUNE38P()

Private oTable	:= Nil

FWExecView('Parcelas x Regras',"RFUNE038",1,,{|| .T. })


Return 
  
/*/{Protheus.doc} RFUNE038
Funcao para atualizar regras por parcela
das parcelas x Regras
@author Leandro Rodrigues
@since 24/08/2019
@param nao recece
@return Nil
/*/

Static Function AtualRegra(oView,cParcela,cTipo)

Local oModel	:= FWModelActive()   
Local oModelUJR	:= oModel:GetModel("UJRDETAIL")
Local oModelSE1	:= oModel:GetModel("SE1DETAIL")

Default cParcela:= oModelSE1:GetValue("E1_PARCELA")
Default cTipo	:= oModelSE1:GetValue("E1_TIPO")

oModel:DeActivate()

oModel:GetModel( 'UJRDETAIL' ):SetLoadFilter(, " ( " + cParcela + ">= UJR_PARCDE"  + " AND " + cParcela +" <= UJR_PARCAT) AND UJR_TIPO = '"+ cTipo +"'" )

oModel:Activate()
oView:Refresh("VIEW_UJR")

//Atualiza resumo
oTotais:RefreshParc(cParcela,cTipo)

Return 


/*/{Protheus.doc} RefreshTotais
Função que cria o Other Object de Totalizadores
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function RefreshParcela(oPanel)

oTotais := ObjParcela():New(oPanel)  

Return() 

/*/{Protheus.doc} ObjParcela
Classe do totalizador
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

Class ObjParcela
 
	Data oVlrPlano
	Data oVlrReajuste
	Data oVlrAdicionais
	Data oVlrServicos
	Data oVlrDesconto
	Data oVlrParcela
	
	Data nVlrPlano
	Data nVlrReajuste
	Data nVlrAdicionais
	Data nVlrServicos
	Data nVlrDesconto
	Data nVlrParcela

   	//Metodo Construtor da Classe
   	Method New() Constructor 
    
    //Metodo para Atualizar os totalizadores da rotina
    Method RefreshParc()
    
EndClass

/*/{Protheus.doc} ObjParcela
Método construtor da classe ObjParcela
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

Method New(oPanel) Class ObjParcela   

Local oPanelCpo		:= NIL
Local oPanelCont	:= NIL
Local oPanelEnt		:= NIL
Local oPanelDesc	:= NIL
Local oPanelRec		:= NIL
Local oSay1			:= NIL
Local oSay2			:= NIL
Local oModel 		:= FWModelActive()        
Local oView			:= FWViewActive()
Local oFont10N	   	:= TFont():New("Verdana",,10,,.T.,,,,.T.,.F.,.T.) // Fonte 12 Negrito, Itálico
Local oFont12N	   	:= TFont():New("Verdana",,12,,.T.,,,,.T.,.F.,.T.) // Fonte 12 Negrito, Itálico
Local oFont14N	   	:= TFont():New("Verdana",,14,,.T.,,,,.T.,.F.,.F.) // Fonte 14 Negrito
Local oFont14S	   	:= TFont():New("Verdana",,14,,.T.,,,,.T.,.F.,.T.) // Fonte 14 Negrito
Local oFont16N	   	:= TFont():New("Verdana",,16,,.T.,,,,.T.,.F.,.T.) // Fonte 28 Negrito
Local oFontNum	   	:= TFont():New("Verdana",08,18,,.F.,,,,.T.,.F.) ///Fonte 14 Negrito
Local nHeigth		:= oPanel:nClientHeight / 2
Local nWhidth		:= oPanel:nClientWidth / 2  
Local nOperation 	:= oModel:GetOperation() 
Local nLin			:= 5
Local nClrPanes		:= 16777215 
Local nClrSay		:= 7303023
Local nAltPanels	:= 0


// inicializo os novos totais zerados
::nVlrPlano		:= 0 
::nVlrReajuste	:= 0
::nVlrAdicionais:= 0
::nVlrServicos	:= 0
::nVlrDesconto	:= 0
::nVlrParcela	:= 0
	
	
//////////////////////////////////////////////////////////
////////////////	PAINEL PRINCIPAL 	/////////////////
/////////////////////////////////////////////////////////


@ 002, 002 MSPANEL oPanelCpo SIZE nWhidth - 2 , nHeigth -2 OF oPanel COLORS 0, 12961221 RAISED

@ nLin 		, 006 SAY oSay1 PROMPT "Composição Parcela" SIZE 040, 020 OF oPanelCpo FONT oFont12N COLORS 0, 16777215 PIXEL CENTER
@ nLin + 12 , 001 SAY oSay5 PROMPT Replicate("- ",25) SIZE nWhidth - 4, 020 OF oPanelCpo FONT oFont12N COLORS 10197915, 16777215 PIXEL CENTER

nLin += 20

nAltPanels := INT(nHeigth - nLin - 4) / 6


/////////////////////////////////////////////////////////////////
////////////////	PANEL VALOR CONTRATADO		////////////////
////////////////////////////////////////////////////////////////


@ nLin , 002 MSPANEL oPanelCont SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED 
@ 000 , 000 SAY oSay1 PROMPT "Plano" SIZE nWhidth - 6, 015 OF oPanelCont FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
@ 008 , 001 SAY oSay2 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPanelCont FONT oFont10N COLORS 10197915, 16777215 PIXEL CENTER

@ (nAltPanels / 2) - 3, 001 SAY oSay5 PROMPT "R$" SIZE 045, 010 OF oPanelCont FONT oFont16N COLORS 0, 16777215 PIXEL CENTER
@ (nAltPanels / 2) + 5, 001 SAY ::oVlrPlano PROMPT AllTrim(Transform(::nVlrPlano,"@E 999,999.99")) SIZE 45, 010 OF oPanelCont FONT oFontNum COLORS 0, 16777215 PIXEL CENTER


nLin += nAltPanels

/////////////////////////////////////////////////////////////////
////////////////	PANEL VALOR TOTAL PAGO		////////////////
////////////////////////////////////////////////////////////////

@ nLin , 002 MSPANEL oPanelEnt SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED 
@ 000 , 000 SAY oSay1 PROMPT "Reajuste" SIZE nWhidth - 6, 015 OF oPanelEnt FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
@ 008 , 001 SAY oSay2 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPanelEnt FONT oFont10N COLORS 10197915, 16777215 PIXEL CENTER

@ (nAltPanels / 2) - 3, 001 SAY oSay5 PROMPT "R$" SIZE 045, 010 OF oPanelEnt FONT oFont16N COLORS 0, 16777215 PIXEL CENTER
@ (nAltPanels / 2) + 5, 001 SAY ::oVlrReajuste PROMPT AllTrim(Transform(::nVlrReajuste,"@E 999,999.99")) SIZE 45, 010 OF oPanelEnt FONT oFontNum COLORS 0, 16777215 PIXEL CENTER


nLin += nAltPanels

/////////////////////////////////////////////////////////////////
////////////////	PANEL VALOR ADICIONAL		////////////////
////////////////////////////////////////////////////////////////

@ nLin , 002 MSPANEL oPanelDesc SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED 
@ 000 , 000 SAY oSay1 PROMPT "Adicionais" SIZE nWhidth - 6, 015 OF oPanelDesc FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
@ 008 , 001 SAY oSay2 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPanelDesc FONT oFont10N COLORS 10197915, 16777215 PIXEL CENTER

@ (nAltPanels / 2) - 3, 001 SAY oSay5 PROMPT "R$" SIZE 045, 010 OF oPanelDesc FONT oFont16N COLORS 0, 16777215 PIXEL CENTER
@ (nAltPanels / 2) + 5, 001 SAY ::oVlrAdicionais PROMPT AllTrim(Transform(::nVlrAdicionais,"@E 999,999.99")) SIZE 45, 010 OF oPanelDesc FONT oFontNum COLORS 0, 16777215 PIXEL CENTER


nLin += nAltPanels

/////////////////////////////////////////////////////////////////
////////////////	PANEL VALOR SERVICOS		////////////////
////////////////////////////////////////////////////////////////

@ nLin , 002 MSPANEL oPanelDesc SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED 
@ 000 , 000 SAY oSay1 PROMPT "Servicos" SIZE nWhidth - 6, 015 OF oPanelDesc FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
@ 008 , 001 SAY oSay2 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPanelDesc FONT oFont10N COLORS 10197915, 16777215 PIXEL CENTER

@ (nAltPanels / 2) - 3, 001 SAY oSay5 PROMPT "R$" SIZE 045, 010 OF oPanelDesc FONT oFont16N COLORS 0, 16777215 PIXEL CENTER
@ (nAltPanels / 2) + 5, 001 SAY ::oVlrServicos PROMPT AllTrim(Transform(::nVlrServicos,"@E 999,999.99")) SIZE 45, 010 OF oPanelDesc FONT oFontNum COLORS 0, 16777215 PIXEL CENTER


nLin += nAltPanels

/////////////////////////////////////////////////////////////////
////////////////	PANEL VALOR DESCONTO		////////////////
////////////////////////////////////////////////////////////////

@ nLin , 002 MSPANEL oPanelRec SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, nClrPanes RAISED 
@ 000 , 000 SAY oSay1 PROMPT "Desconto" SIZE nWhidth - 6, 015 OF oPanelRec FONT oFont14N COLORS nClrSay, 16777215  PIXEL CENTER
@ 008 , 001 SAY oSay2 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPanelRec FONT oFont10N COLORS 10197915, 16777215 PIXEL CENTER

@ (nAltPanels / 2) - 3, 001 SAY oSay5 PROMPT "R$" SIZE 045, 010 OF oPanelRec FONT oFont16N COLORS 0, 16777215 PIXEL CENTER
@ (nAltPanels / 2) + 5, 001 SAY ::oVlrDesconto PROMPT AllTrim(Transform(::nVlrDesconto,"@E 999,999.99")) SIZE 45, 010 OF oPanelRec FONT oFontNum COLORS 0, 16777215 PIXEL CENTER

nLin += nAltPanels

/////////////////////////////////////////////////////////////////
////////////////	PANEL VALOR TOTAL PARCELA	////////////////
////////////////////////////////////////////////////////////////

@ nLin , 002 MSPANEL oPanelRec SIZE nWhidth - 6 , nAltPanels OF oPanelCpo COLORS 0, 12961221 RAISED 
@ 000 , 000 SAY oSay1 PROMPT "Valor Parcela" SIZE nWhidth - 6, 015 OF oPanelRec FONT oFont14S COLORS 0, 16777215  PIXEL CENTER
@ 008 , 001 SAY oSay2 PROMPT Replicate("- ",14) SIZE nWhidth - 6, 015 OF oPanelRec FONT oFont10N COLORS 10197915, 16777215 PIXEL CENTER

@ (nAltPanels / 2) - 3, 001 SAY oSay5 PROMPT "R$" SIZE 045, 010 OF oPanelRec FONT oFont16N COLORS 0, 16777215 PIXEL CENTER
@ (nAltPanels / 2) + 5, 001 SAY ::oVlrParcela PROMPT AllTrim(Transform(::nVlrParcela,"@E 999,999.99")) SIZE 45, 010 OF oPanelRec FONT oFontNum COLORS 0, 16777215 PIXEL CENTER

Return()

/*/{Protheus.doc} ObjParcela
Método Refresh do Totais da composicao parcela
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

Method RefreshParc(cParcela,cTipo) Class ObjParcela   

Local oModel		:= FWModelActive() 
Local oView			:= FWViewActive() 
Local oModelUJR		:= oModel:GetModel("UJRDETAIL")
Local oModelSE1		:= oModel:GetModel("SE1DETAIL")
Local dDataReaj		:= cTod("")
Local nIndice		:= 0
Local nI			:= 1

Default cParcela	:= oModelSE1:GetValue("E1_PARCELA")
Default cTipo		:= oModelSE1:GetValue("E1_TIPO")

::nVlrAdicionais	:= 0
::nVlrPlano			:= UF2->UF2_VLRBRU
::nVlrReajuste	 	:= 0
::nVlrServicos	 	:= UF2->UF2_VLSERV
::nVlrDesconto		:= UF2->UF2_DESCON
::nVlrParcela		:= (UF2->UF2_VLRBRU+UF2->UF2_VLSERV) - UF2->UF2_DESCON


//Atualizando o valor adicional
For nI := 1 To oModelUJR:Length()
	
	oModelUJR:Goline(nI)  

	if Empty(dDataReaj)
		dDataReaj := oModelUJR:GetValue("UJR_DTREAJ") 
	Endif
	
	//valido se regra fez parte da forma de preco da parcela
	if ( cParcela >= oModelUJR:GetValue("UJR_PARCDE") .AND.  cParcela <= oModelUJR:GetValue("UJR_PARCAT")).AND. oModelUJR:GetValue("UJR_TIPO") == cTipo
	
		::nVlrAdicionais += oModelUJR:GetValue("UJR_VLTOT") 

	Endif
Next nI

::nVlrParcela += ::nVlrAdicionais

//Verifico se foi parcela de reajuste
If !Empty(dDataReaj)

	//pego percentual que foi usado para reajustar
	nIndice := BuscaReajuste(dDataReaj)
	::nVlrReajuste  := ROUND(::nVlrParcela * (nIndice/100 ),TamSx3("UF2_VLADIC")[1])
	::nVlrParcela 	+= ::nVlrReajuste 
Endif

//atualizo totalizadores
::oVlrPlano:Refresh()
::oVlrReajuste:Refresh()
::oVlrAdicionais:Refresh()
::oVlrDesconto:Refresh()
::oVlrParcela:Refresh()

Return()



/*/{Protheus.doc} ObjParcela
Busca indice de reajuste
@author Leandro Rodrigues
@since 22/05/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

Static Function BuscaReajuste(dDataReaj)

Local nIndice := 0
Local cQryIn := ""

cQryIn:= " SELECT"
cQryIn+= " 	UF7_INDICE"
cQryIn+= " FROM " + RETSQLNAME("UF7") 
cQryIn+= " WHERE D_E_L_E_T_= ' '"
cQryIn+= " 	AND UF7_CONTRA = '" + UF2->UF2_CODIGO   + "'" 
cQryIn+= " 	AND UF7_DATA   = '" + dTos(dDataReaj)	+ "'"

cQryIn:= ChangeQuery(cQryIn)

If select("QUF7")>1
	QUF7->(DbCloseArea())
Endif

TcQuery cQryIn New Alias "QUF7"

nIndice := QUF7->UF7_INDICE

Return nIndice