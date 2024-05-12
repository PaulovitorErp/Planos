#include "protheus.ch" 
#include "topconn.ch"
#include "fwmvcdef.ch"

#define DMPAPER_A4 9    // A4 210 x 297 mm

/*/{Protheus.doc} RCPGA021
Controle de Locação de Salas
@author TOTVS
@since 04/05/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function RCPGA021()
/***********************/ 

Local oBrowse

Private aRotina := {}

oBrowse := FWmBrowse():New()
oBrowse:SetAlias("U25")
oBrowse:SetDescription("Controle de Locacao de Salas")   
oBrowse:AddLegend("(U25_DATA == dDataBase .Or. U25_DATAF == dDataBase) .And. SubStr(StrTran(Time(),':'),1,4) >= U25_HRINIC .And. SubStr(StrTran(Time(),':'),1,4) <= U25_HRFIM", "GREEN", "Vigente")
oBrowse:AddLegend("U25_DATA < dDataBase .Or. U25_DATAF > dDataBase .Or. SubStr(StrTran(Time(),':'),1,4) < U25_HRINIC .Or. SubStr(StrTran(Time(),':'),1,4) > U25_HRFIM", "RED", "Não vigente")
oBrowse:Activate()

Return Nil

/************************/
Static Function MenuDef()
/************************/

aRotina 	:= {}

ADD OPTION aRotina Title 'Visualizar' 								Action "VIEWDEF.RCPGA021"	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title "Incluir"    								Action "VIEWDEF.RCPGA021"	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title "Alterar"    								Action "VIEWDEF.RCPGA021"	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title "Excluir"    								Action "VIEWDEF.RCPGA021"	OPERATION 5 ACCESS 0
ADD OPTION aRotina Title "Impressao da ficha de identificacao"		Action "U_CPGA021I()"		OPERATION 6 ACCESS 0
ADD OPTION aRotina Title "Monitor"									Action "U_CPGA021M()"		OPERATION 6 ACCESS 0
ADD OPTION aRotina Title 'Legenda'     								Action 'U_CPGA021L()' 		OPERATION 6 ACCESS 0    

Return aRotina

/*************************/
Static Function ModelDef()
/*************************/

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruU25 := FWFormStruct(1,"U25",/*bAvalCampo*/,/*lViewUsado*/ )

Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("PCPGA021",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("U25MASTER",/*cOwner*/,oStruU25)

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({"U25_FILIAL","U25_CODIGO"})

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel("U25MASTER"):SetDescription("Controle de Locacao de Salas")

Return oModel

/************************/
Static Function ViewDef()
/************************/

// Cria a estrutura a ser usada na View
Local oStruU25 := FWFormStruct(2,"U25")

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel("RCPGA021")
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField("VIEW_U25",oStruU25,"U25MASTER")

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox("PAINEL_CABEC", 100)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView("VIEW_U25","PAINEL_CABEC")

// Liga a identificacao do componente
oView:EnableTitleView("VIEW_U25","Controle de Locacao de Salas")

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk( {||.T.} )

Return oView                                           

/***********************/
User Function CPGA021L()
/***********************/

BrwLegenda("Status do Controle de Locacao","Legenda",{{"BR_VERDE","Vigente"},{"BR_VERMELHO","Não vigente"}})

Return

/***********************/
User Function CPGA021I()
/***********************/

Private oFont8			:= TFont():New('Arial',,8,,.F.,,,,.F.,.F.) 					//Fonte 8 Normal
Private oFont14			:= TFont():New('Arial',,14,,.F.,,,,.F.,.F.) 				//Fonte 14
Private oFont14N		:= TFont():New('Arial',,14,,.T.,,,,.F.,.F.) 				//Fonte 14 Negrito
Private oFont14NS		:= TFont():New('Arial',,14,,.T.,,,,.T.,.F.) 				//Fonte 14 Negrito e Sublinhado
Private oFont14NI		:= TFont():New('Times New Roman',,14,,.T.,,,,.F.,.F.,.T.) 	//Fonte 14 Negrito e Itálico
Private oFont16N		:= TFont():New('Arial',,16,,.T.,,,,.F.,.F.) 				//Fonte 16 Negrito
Private oFont16NI		:= TFont():New('Times New Roman',,16,,.T.,,,,.F.,.F.,.T.) 	//Fonte 16 Negrito e Itálico
Private oFont18			:= TFont():New("Arial",,18,,.F.,,,,,.F.,.F.)				//Fonte 18
Private oFont18N		:= TFont():New("Arial",,18,,.T.,,,,,.F.,.F.)				//Fonte 18 Negrito
Private oFont20			:= TFont():New("Arial",,20,,.F.,,,,,.F.,.F.)				//Fonte 20
Private oFont20N		:= TFont():New("Arial",,20,,.T.,,,,,.F.,.F.)				//Fonte 20 Negrito
Private oFont22			:= TFont():New("Arial",,22,,.F.,,,,,.F.,.F.)				//Fonte 22
Private oFont22N		:= TFont():New("Arial",,22,,.T.,,,,,.F.,.F.)				//Fonte 22 Negrito
Private oFont24			:= TFont():New("Arial",,24,,.F.,,,,,.F.,.F.)				//Fonte 24
Private oFont24N		:= TFont():New("Arial",,24,,.T.,,,,,.F.,.F.)				//Fonte 24 Negrito
Private oFont26			:= TFont():New("Arial",,26,,.F.,,,,,.F.,.F.)				//Fonte 26
Private oFont26N		:= TFont():New("Arial",,26,,.T.,,,,,.F.,.F.)				//Fonte 26 Negrito

Private oBrush			:= TBrush():New(,CLR_HGRAY)

Private cStartPath
Private nLin 			:= 80
Private oRel

cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")  

oRel := TmsPrinter():New("")
oRel:SetPortrait()
oRel:SetPaperSize(9) //A4

ImpCorpo()
ImpRod()

oRel:Preview()

Return

/*************************/
Static Function ImpCorpo()
/*************************/

oRel:StartPage() //Inicia uma nova pagina

oRel:Box(nLin,120,nLin + 3200,2240)

oRel:SayBitMap(nLin + 15,140,cStartPath + "LGMID01.png",400,214)

nLin += 600 

oRel:Say(nLin,1180,AllTrim(U25->U25_NOMOBT),oFont26N,,,,2)

nLin += 700

oRel:Say(nLin,200,"INÍCIO DO VELÓRIO: " + Transform(U25->U25_HRINIC,"@R 99:99") + " HS",oFont24)

nLin += 300

oRel:Say(nLin,200,AllTrim(U25->U25_DESCSE) + ": " + Transform(U25->U25_HRFIM,"@R 99:99") + " HS",oFont24)

nLin += 700

oRel:Say(nLin,1180,"LOCALIZAÇÃO",oFont22N,,,,2)

nLin += 200

If !Empty(U25->U25_QUADRA)
	oRel:Say(nLin,1180,"QUADRA: " + U25->U25_QUADRA + Space(10) + "MÓDULO: " + U25->U25_MODULO + Space(10) + "JAZIGO: " + U25->U25_JAZIGO,oFont20,,,,2)
Else
	oRel:Say(nLin,1180,"CREMATÓRIO: " + U25->U25_CREMAT,oFont20,,,,2)
Endif

Return

/***********************/
Static Function ImpRod()
/***********************/                                       

oRel:Line(3320,0120,3320,2240) 
oRel:Say(3350,0110,"TOTVS - Protheus",oFont8)

oRel:EndPage()

Return

/***********************/
User Function CPGA021M()
/***********************/

Local cTitulo 		:= ""

Local nTimerM		:= 10000 
 
Local aResolucao	:= GETSCREENRES() // Retorna a resolução da área de trabalho do usuário logado
Local nAltura		:= aResolucao[2] // Resolução vertical do monitor
Local nLargura		:= aResolucao[1] // Resolução horizontal do monitor

Local oFont22		:= TFONT():New("Arial",,22,,.F.,,,,.T.,.F.)		///Fonte 22 Normal
Local oFont22N		:= TFONT():New("Arial",,22,,.T.,,,,.T.,.F.)		///Fonte 22 Negrito
Local oFont24		:= TFONT():New("Arial",,24,,.F.,,,,.T.,.F.)		///Fonte 24 Normal
Local oFont24N		:= TFONT():New("Arial",,24,,.T.,,,,.T.,.F.)		///Fonte 24 Negrito
Local oFont26		:= TFONT():New("Arial",,26,,.F.,,,,.T.,.F.)		///Fonte 26 Normal
Local oFont26N		:= TFONT():New("Arial",,26,,.T.,,,,.T.,.F.)		///Fonte 26 Negrito
Local oFont28		:= TFONT():New("Arial",,28,,.F.,,,,.T.,.F.)		///Fonte 28 Normal
Local oFont28N		:= TFONT():New("Arial",,28,,.T.,,,,.T.,.F.)		///Fonte 28 Negrito
Local oFont30		:= TFONT():New("Arial",,30,,.F.,,,,.T.,.F.)		///Fonte 30 Normal
Local oFont30N		:= TFONT():New("Arial",,30,,.T.,,,,.T.,.F.)		///Fonte 30 Negrito
Local oFont32		:= TFONT():New("Arial",,32,,.F.,,,,.T.,.F.)		///Fonte 32 Normal
Local oFont32N		:= TFONT():New("Arial",,32,,.T.,,,,.T.,.F.)		///Fonte 32 Negrito

Private oTimerM, oTimerT

Private oSay1, oSay2, oSay3, oSay4, oSay5, oSay6, oSay7, oSay8, oSay9, oSay10

Private cSala 		:= ""
Private cNomObt		:= ""
Private cHrIni		:= ""
Private cServ		:= ""
Private cHrFim		:= ""
Private cQuadra		:= ""
Private cModulo		:= ""
Private cJazigo		:= ""
Private cCremat		:= ""
Private cNRes		:= ""

Private lParar		:= .F.

Static oDlgM

DEFINE MSDIALOG oDlgM TITLE cTitulo FROM 000, 000  TO nAltura, nLargura PIXEL OF GetWndDefault() STYLE nOr(WS_VISIBLE, WS_POPUP)

@ 030,((nLargura/2)/2) - 100 SAY oSay1 PROMPT "SALA " + cSala SIZE 200, 012 OF oDlgM FONT oFont32N COLORS 0, 16777215 PIXEL CENTER
oSay1:lVisible := .F.
@ 080,050 SAY oSay2 PROMPT "SENDO VELADO: " + cNomObt SIZE 400, 014 OF oDlgM FONT oFont30 COLORS 0, 16777215 PIXEL
oSay2:lVisible := .F.
@ 140,050 SAY oSay3 PROMPT "INÍCIO DO VELÓRIO: " + Transform(cHrIni,"@R 99:99") SIZE 400, 010 OF oDlgM  FONT oFont28 COLORS 0, 16777215 PIXEL
oSay3:lVisible := .F.
@ 160,050 SAY oSay4 PROMPT cServ + ": " + Transform(cHrFim,"@R 99:99")  SIZE 400, 010 OF oDlgM FONT oFont28 COLORS 0, 16777215 PIXEL
oSay4:lVisible := .F.
@ 220,((nLargura/2)/2) - 50 SAY oSay5 PROMPT "LOCALIZAÇÃO" SIZE 100, 014 OF oDlgM FONT oFont30N COLORS 0, 16777215 PIXEL CENTER
oSay5:lVisible := .F.
@ 260,100 SAY oSay6 PROMPT "QUADRA: " + cQuadra SIZE 200, 010 OF oDlgM FONT oFont26 COLORS 0, 16777215 PIXEL
oSay6:lVisible := .F.
@ 260,300 SAY oSay7 PROMPT "MÓDULO: " + cModulo SIZE 200, 010 OF oDlgM FONT oFont26 COLORS 0, 16777215 PIXEL
oSay7:lVisible := .F.
@ 260,500 SAY oSay8 PROMPT "JAZIGO: " + cJazigo SIZE 200, 010 OF oDlgM FONT oFont26 COLORS 0, 16777215 PIXEL
oSay8:lVisible := .F.
@ 260,100 SAY oSay9 PROMPT "CREMATÓRIO: " + cCremat SIZE 200, 010 OF oDlgM FONT oFont26 COLORS 0, 16777215 PIXEL
oSay9:lVisible := .F.

@ 050,050 SAY oSay10 PROMPT cNRes SIZE 200, 012 OF oDlgM FONT oFont32N COLORS 0, 16777215 PIXEL
oSay10:lVisible := .F.

BuscaDados()

oTimerM := TTimer():New(nTimerM,{|| MostraSala()},oDlgM)
oTimerM:Activate()

SetKey(VK_F12,{|| FechaM()})

ACTIVATE MSDIALOG oDlgM CENTERED

SetKey(VK_F12,{|| Nil})

Return

/***************************/
Static Function BuscaDados()
/***************************/
Local cQry 	:= ""

If Select("QRYU25") > 0
	QRYU25->(DbCloseArea())
Endif

cQry := "SELECT U25_DESCSA, U25_NOMOBT, U25_HRINIC, U25_DESCSE, U25_HRFIM, U25_QUADRA, U25_MODULO, U25_JAZIGO, U25_CREMAT"
cQry += " FROM "+RetSqlName("U25")+""
cQry += " WHERE D_E_L_E_T_ 	<> '*'"
cQry += " AND U25_FILIAL 	= '"+xFilial("U25")+"'"
cQry += " AND (U25_DATA = '"+DToS(dDataBase)+"' OR U25_DATAF = '"+DToS(dDataBase)+"')"
//cQry += " AND U25_HRINIC 	<= '"+SubStr(StrTran(Time(),':'),1,4)+"'
//cQry += " AND U25_HRFIM 	>= '"+SubStr(StrTran(Time(),':'),1,4)+"'
cQry += " ORDER BY 1"

cQry := ChangeQuery(cQry)
TcQuery cQry NEW Alias "QRYU25"

Return

/***************************/
Static Function MostraSala()
/***************************/

If QRYU25->(!EOF())

	cNRes := ""
	oSay10:Refresh()
	oSay10:lVisible := .F.	
	
	cSala 	:= QRYU25->U25_DESCSA
	cNomObt	:= QRYU25->U25_NOMOBT
	cHrIni	:= QRYU25->U25_HRINIC
	cServ	:= AllTrim(QRYU25->U25_DESCSE)
	cHrFim	:= QRYU25->U25_HRFIM
	cQuadra	:= QRYU25->U25_QUADRA
	cModulo	:= QRYU25->U25_MODULO
	cJazigo	:= QRYU25->U25_JAZIGO
	cCremat	:= QRYU25->U25_CREMAT

	oSay1:Refresh()
	oSay2:Refresh()
	oSay3:Refresh()
	oSay4:Refresh()
	oSay5:Refresh()

	oSay1:lVisible := .T.
	oSay2:lVisible := .T.
	oSay3:lVisible := .T.
	oSay4:lVisible := .T.
	oSay5:lVisible := .T.
	
	If Empty(cCremat)
	
		oSay6:lVisible := .T.
		oSay7:lVisible := .T.
		oSay8:lVisible := .T.
		oSay9:lVisible := .F.

		oSay6:Refresh()
		oSay7:Refresh()
		oSay8:Refresh()
		oSay9:Refresh()

	Else

		oSay6:lVisible := .F.
		oSay7:lVisible := .F.
		oSay8:lVisible := .F.
		oSay9:lVisible := .T.

		oSay6:Refresh()
		oSay7:Refresh()
		oSay8:Refresh()
		oSay9:Refresh()
	Endif

	QRYU25->(DbSkip())
	
	If QRYU25->(EOF())
		BuscaDados()
	Endif
Else
	
	If Empty(cNRes)
		
		cNRes := "NENHUMA RESERVA DE SALA CADASTRADA."
	
		oSay1:lVisible := .F.
		oSay2:lVisible := .F.
		oSay3:lVisible := .F.
		oSay4:lVisible := .F.
		oSay5:lVisible := .F.
		oSay6:lVisible := .F.
		oSay7:lVisible := .F.
		oSay8:lVisible := .F.
		oSay9:lVisible := .F.
	
		oSay10:Refresh()
		oSay10:lVisible := .T.
	Endif

	BuscaDados()
Endif

Return

/***********************/
Static Function FechaM()
/***********************/

If Select("QRYU25") > 0
	QRYU25->(DbCloseArea())
Endif

oDlgM:End()

Return

/***********************************/
User Function VLDDTLOC(dData,dDataF)
/***********************************/

Local lRet := .T.

If !Empty(dData) .And. !Empty(dDataF)

	If dDataF < dData
		Help( ,, 'Help',, 'Data final inferior a data inicial. Operação não permitida.', 1, 0 )
		lRet := .F.
	Endif
Endif

Return lRet