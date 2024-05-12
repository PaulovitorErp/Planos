#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RUTIL002 º Autor ³ André R. Barrero		ºData³ 10/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de cadastro de rotas.								  º±±
±±º          ³ - Atualizações >> Cadastros >> Rotas                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Vale do Cerrado                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function RUTIL002()      

Local oBrowse

Private aRotina := {}

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("U34")
oBrowse:SetDescription("Cadastro de Rotas")

// adiciona legenda no Browser
oBrowse:AddLegend("U34_STATUS == 'A'"	, "GREEN", "Ativo")
oBrowse:AddLegend("U34_STATUS == 'I'"	, "RED"  , "Inativo")  

oBrowse:Activate()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MenuDef º Autor ³ André R. Barrero		ºData³ 10/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que cria os menus									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Vale do Cerrado                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef() 

Local aRotina := {}

ADD OPTION aRotina Title 'Pesquisar'   	Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  	Action 'VIEWDEF.RUTIL002' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Incluir'     	Action 'VIEWDEF.RUTIL002' 	OPERATION 03 ACCESS 0
ADD OPTION aRotina Title 'Alterar'     	Action 'VIEWDEF.RUTIL002' 	OPERATION 04 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     	Action 'VIEWDEF.RUTIL002' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    	Action 'VIEWDEF.RUTIL002' 	OPERATION 08 ACCESS 0
ADD OPTION aRotina Title 'Copiar'      	Action 'VIEWDEF.RUTIL002' 	OPERATION 09 ACCESS 0  
ADD OPTION aRotina Title 'Legenda'     	Action 'U_UTIL002LEG()' 	OPERATION 10 ACCESS 0    

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ModelDef º Autor ³ André R. Barrero		ºData³ 10/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que cria o objeto model							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Vale do Cerrado                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ModelDef()

Local oStruU34 := FWFormStruct( 1, 'U34', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruU35 := FWFormStruct( 1, 'U35', /*bAvalCampo*/, /*lViewUsado*/ ) 
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PUTIL002', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABEÇALHO - ROTAS  ////////////////////////////

// Crio a Enchoice com os campos do cadastro das Rotas
oModel:AddFields( 'U34MASTER', /*cOwner*/, oStruU34 )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "U34_FILIAL" , "U34_CODIGO" })    

// Preencho a descrição da entidade
oModel:GetModel('U34MASTER'):SetDescription('Rotas:')

///////////////////////////  ITENS - BAIRROS  //////////////////////////////

// Crio o grid de Bairros
oModel:AddGrid( 'U35DETAIL', 'U34MASTER', oStruU35, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faço o relaciomaneto entre o Rotas e os Bairros
oModel:SetRelation( 'U35DETAIL', { { 'U35_FILIAL', 'xFilial( "U35" )' } , { 'U35_CODIGO', 'U34_CODIGO' } } , U35->(IndexKey(1)) )  

// Seto a propriedade de não obrigatoriedade do preenchimento do grid
oModel:GetModel('U35DETAIL'):SetOptional( .T. ) 

// Preencho a descrição da entidade
oModel:GetModel('U35DETAIL'):SetDescription('Bairros:') 

// Não permitir duplicar o código do Bairro
oModel:GetModel('U35DETAIL'):SetUniqueLine( {'U35_CODBAI'} ) 

Return(oModel)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ViewDef º Autor ³ André R. Barrero		ºData³ 10/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que cria o objeto View							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Vale do Cerrado                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ViewDef()

Local oStruU34 	:= FWFormStruct(2,'U34')
Local oStruU35 	:= FWFormStruct(2,'U35') 
Local oModel   	:= FWLoadModel('RUTIL002')
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

oView:AddField('VIEW_U34'	, oStruU34, 'U34MASTER') // Cria o cabeçalho - Rotas
oView:AddGrid('VIEW_U35'	, oStruU35, 'U35DETAIL') // Cria o grid - Bairros

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_ROTAS' 	, 20)
oView:CreateHorizontalBox('PANEL_BAIRROS'	, 80)    

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_U34' , 'PANEL_ROTAS')
oView:SetOwnerView('VIEW_U35' , 'PANEL_BAIRROS')    

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_U34')
oView:EnableTitleView('VIEW_U35') 

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk({||.T.})

// Define campos que terao Auto Incremento
oView:AddIncrementField("VIEW_U35","U35_ITEM")

Return(oView)                         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ UTIL002ROTA º Autor ³ André R. Barrero	ºData³ 10/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para seleção das Rotas para impressão				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Vale do Cerrado                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function UTIL002ROTA()
Local oButton1
Local oButton2
Local oGroup1

Local lContinua		:= .T.

Static oDlg
Static oSay

Private oWBrowse1
Private aWBrowse1 	:= {}
Private lChk 		:= .F.
Private cPerg 		:= "RUTIL002"

While lContinua

//Exibe as Rotas
//DEFINE MSDIALOG oDlg TITLE "Reaj.Salario" FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL
DEFINE MSDIALOG oDlg TITLE "ROTAS" FROM 000, 000  TO 400, 800 COLORS 0, 16777215 PIXEL

//@ 002, 003 GROUP oGroup1 TO 195, 295 PROMPT "Funcionário" OF oDlg COLOR 0, 16777215 PIXEL
@ 002, 003 GROUP oGroup1 TO 195, 400 PROMPT "Rotas" OF oDlg COLOR 0, 16777215 PIXEL
fWBrowse1()
//@ 175, 207 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF oDlg PIXEL ACTION (lContinua:=fConf())
@ 175, 310 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF oDlg PIXEL ACTION (lContinua:=fConf())
//@ 175, 252 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlg PIXEL ACTION (lContinua:=.F.,oDlg:End())
@ 175, 355 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlg PIXEL ACTION (lContinua:=.F.,oDlg:End())

//@ 175, 265 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 060,007 PIXEL OF oDlg;
//@ 175, 235 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 060,012 PIXEL OF oDlg;
@ 175, 050 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 060,012 PIXEL OF oDlg;
ON CLICK(Iif(lChk,Marca(lChk),Marca(lChk)))

ACTIVATE MSDIALOG oDlg CENTERED    

EndDo

Return
//=============================================================//
// Funcao que marca ou desmarca todos os objetos
//=============================================================//
Static Function Marca(lMarca)
Local nX := 0 

For nX := 1 To Len(aWBrowse1)
	aWBrowse1[nX,1] := lMarca
Next nX

oWBrowse1:Refresh()

Return
//=============================================================//
// Browser para Mostrar as ROTAS, retorno da Query
//=============================================================//
Static Function fWBrowse1()
Local oNo 		:= LoadBitmap( GetResources(), "LBNO")
Local oOk 		:= LoadBitmap( GetResources(), "LBOK")

aWBrowse1 := ROTAS()
										 //"","Código","Rota","Status"
@ 012, 011 LISTBOX oWBrowse1 Fields HEADER "","Código","Rota","Status" SIZE 380, 158 OF oDlg PIXEL ColSizes 10,20,40,30
oWBrowse1:SetArray(aWBrowse1)

oWBrowse1:bLine := {|| {;
If(aWBrowse1[oWBrowse1:nAT,1],oOk,oNo),;
aWBrowse1[oWBrowse1:nAt,2],;
aWBrowse1[oWBrowse1:nAt,3],;
aWBrowse1[oWBrowse1:nAt,4],;
}}

// DoubleClick event
oWBrowse1:bLDblClick := {|| aWBrowse1[oWBrowse1:nAt,1] := !aWBrowse1[oWBrowse1:nAt,1],;
oWBrowse1:DrawSelect(),/*ValMark(oWBrowse1:nAt)*/}

Return
//=======================================================//
//Valida a linha marcada
//=======================================================//
Static Function ValMark(nLin)
Local lRet 		:= .T.
Local nPos		:= 0            

Default nLin 	:= 0

//nPos := aScan(aWBrowse1,{|x| x[1]})

//If nPos > 0 .And. nPos <> nLin                            
	//MsgAlert("Marque apenas um cliente para ser o pagante.")	
	//lRet := .F.	
	//aWBrowse1[oWBrowse1:nAT,1] := lRet
	//oWBrowse1:Refresh()
//EndIf

Return lRet
//=======================================================//
//Preenche o array de clientes
//=======================================================//
Static Function ROTAS() 
Local cAliasTrb	:= ""
Local aArea		:= GetArea()
Local aRet 		:= {}

cQuery := " SELECT U34.* " + cPulalinha
cQuery += " FROM "+RetSqlName("U34")+" U34 " + cPulalinha
cQuery += " WHERE U34.D_E_L_E_T_ <> '*' " + cPulalinha
cQuery += " 	AND U34.U34_FILIAL = '"+xFilial("U34")+"' " + cPulalinha
//cQuery += " 	AND U34.U34_MAT  BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' " + cPulalinha
//cQuery += " 	AND U34.U34_DATA LIKE '"+sDtRef+"%' " + cPulalinha
//cQuery += " ORDER BY "+IIF(MV_PAR10=1,'U34.U34_MAT','SRA.RA_NOME')+" " + cPulalinha

//Crio o Alias Temporario
cAliasTrb := GetNextAlias()
cQuery    := ChangeQuery( cQuery )
DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasTrb, .T., .F. )

//Volto ao inicio do alias temporario
(cAliasTrb)->(DbGoTop() )

While (cAliasTrb1)->(!Eof()) //"","Código","Rota","Status"

	aAdd(aRet,{.F.,(cAliasTrb)->U34_CODIGO,(cAliasTrb)->U34_DESCRI,IIF((cAliasTrb)->U34_STATUS=="A","ATIVO","INATIVO")})
	
	(cAliasTrb1)->(DbSkip())
	
EndDo

If Len(aRet) = 0 //Inicia o retorno com uma linha em branco.
	aRet := {{.F.,"","",""}}
EndIf

(cAliasTrb)->(DbCloseArea())

RestArea(aArea)

Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ UTIL002LEG º Autor ³ André R. Barrero	ºData³ 10/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Legenda do browser de cadastro de Rotas					  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Vale do Cerrado                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function UTIL002LEG()

BrwLegenda("Status da Rota","Legenda",{ {"BR_VERDE","Ativo"},{"BR_VERMELHO","Inativo"} })

Return()


User Function RetDsMun(cCodBairro)

Local aAreaCC2 := CC2->( GetArea() )
Local aArea	   := GetArea() 
Local aAreaZFC := ZFC->( GetArea() )

Local cDesMun := ""

ZFC->( DbSetOrder(3) ) //XFILIAL("ZFC")+cCodBairro

If ZFC->( DbSeek( xFilial("ZFC") + cCodBairro ) )
	cDesMun := POSICIONE("CC2",1,XFILIAL("CC2")+ZFC->ZFC_EST+ZFC->ZFC_CODMUN,"CC2_MUN")
EndIf

RestArea(aAreaCC2)
RestArea(aArea)
RestArea(aAreaZFC)

Return(cDesMun)
