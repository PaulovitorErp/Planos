#Include "PROTHEUS.CH"
#include "topconn.ch"   
#INCLUDE 'FWMVCDEF.CH' 

/*/{Protheus.doc} RFUNA047
Rotina de Historico de inclusao de novos ciclos de cobranca de convalescencia.
@author Leandro Rodrigues
@since 10/06/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
User Function RFUNA047()      

Local oBrowse
Local cName := Funname()

// Altero o nome da rotina para considerar o menu deste MVC
SetFunName("RFUNA047")

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'UJP' )
oBrowse:SetDescription( 'Histórico Ciclo Cobranca Convalescente' ) 

oBrowse:AddLegend("Empty(UJP_DTESTO)" , "BLUE","Titulos Gerados")
oBrowse:AddLegend("!Empty(UJP_DTESTO)", "RED" ,"Titulos Estornados")

oBrowse:Activate()

// Retorno o nome da rotina
SetFunName(cName)

Return NIL 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MenuDef º Autor ³ Leandro Rodrigues    º Data ³ 10/06/2019 º±±
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

//valido se o usuario tem permissao de alterar o reajuste
ADD OPTION aRotina Title 'Pesquisar'   			Action 'PesqBrw'          	OPERATION 01 ACCESS 0
ADD OPTION aRotina Title 'Visualizar'  			Action 'VIEWDEF.RFUNA047' 	OPERATION 02 ACCESS 0
ADD OPTION aRotina Title 'Excluir'     			Action 'VIEWDEF.RFUNA047' 	OPERATION 05 ACCESS 0
ADD OPTION aRotina Title 'Imprimir'    			Action 'VIEWDEF.RFUNA047' 	OPERATION 08 ACCESS 0
ADD OPTION aRotina Title 'Estorna Titulos'		Action 'U_RFUNA47E()'	 	OPERATION 08 ACCESS 0

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ModelDef º Autor ³ Wellington Gonçalves º Data ³02/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que cria o objeto model							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Vale do Cerrado                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ModelDef()

Local oStruUJP := FWFormStruct( 1, 'UJP', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruUJQ := FWFormStruct( 1, 'UJQ', /*bAvalCampo*/, /*lViewUsado*/ ) 
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PFUNA047', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

/////////////////////////  CABEÇALHO - REAJUSTE  ////////////////////////////

// Crio a Enchoice com os campos do reajuste
oModel:AddFields( 'UJPMASTER', /*cOwner*/, oStruUJP )

// Adiciona a chave primaria da tabela principal
oModel:SetPrimaryKey({ "UJP_FILIAL" , "UJP_CODIGO" })    

// Preencho a descrição da entidade
oModel:GetModel('UJPMASTER'):SetDescription('Dados da Cobranca:')

///////////////////////////  ITENS - TITULOS GERADOS  //////////////////////////////

// Crio o grid de titulos
oModel:AddGrid( 'UJQDETAIL', 'UJPMASTER', oStruUJQ, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )    

// Faço o relaciomaneto entre o cabeçalho e os itens
oModel:SetRelation( 'UJQDETAIL', { { 'UJQ_FILIAL', 'xFilial( "UJQ" )' } , { 'UJQ_CODIGO', 'UJP_CODIGO' } } , UJQ->(IndexKey(1)) )  

// Seto a propriedade de obrigatoriedade do preenchimento do grid
oModel:GetModel('UJQDETAIL'):SetOptional( .F. ) 

// Preencho a descrição da entidade
oModel:GetModel('UJQDETAIL'):SetDescription('Títulos Gerados:') 

// Não permitir duplicar a chave da parcela
oModel:GetModel('UJQDETAIL'):SetUniqueLine( {'UJQ_PREFIX','UJQ_NUM','UJQ_PARCEL','UJQ_TIPO'} ) 

//////////////////////////  TOTALIZADORES  //////////////////////////////////
  
oModel:AddCalc( 'CALC1', 'UJPMASTER', 'UJQDETAIL', 'UJQ_VALOR', 'TOTAL'	, 'SUM'		,,,'Valor Total' )

Return(oModel)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ViewDef º Autor ³ Wellington Gonçalves º Data ³ 02/08/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que cria o objeto View							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Vale do Cerrado                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ViewDef()

Local oStruUJP 	:= FWFormStruct(2,'UJP')
Local oStruUJQ 	:= FWFormStruct(2,'UJQ') 
Local oModel   	:= FWLoadModel('RFUNA047')
Local oView
Local oCalc1

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

// crio o totalizador
oCalc1 := FWCalcStruct( oModel:GetModel( 'CALC1') )

oView:AddField('VIEW_UJP'	, oStruUJP	, 'UJPMASTER') // cria o cabeçalho
oView:AddGrid('VIEW_UJQ'	, oStruUJQ	, 'UJQDETAIL') // Cria o grid
oView:AddField('VIEW_CALC1'	, oCalc1	, 'CALC1' ) 

// Crio os Panel's horizontais 
oView:CreateHorizontalBox('PANEL_CABECALHO' , 20)
oView:CreateHorizontalBox('PANEL_ITENS'		, 70)   
oView:CreateHorizontalBox('PANEL_CALC'		, 10)   

// Relaciona o ID da View com os panel's
oView:SetOwnerView('VIEW_UJP' , 'PANEL_CABECALHO')
oView:SetOwnerView('VIEW_UJQ' , 'PANEL_ITENS')    
oView:SetOwnerView('VIEW_CALC1' , 'PANEL_CALC') 

// Ligo a identificacao do componente
oView:EnableTitleView('VIEW_UJP')
oView:EnableTitleView('VIEW_UJQ') 

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_UJQ', 'UJQ_ITEM' )

// Define fechamento da tela ao confirmar a operação
oView:SetCloseOnOk({||.T.})

Return(oView)


/*/{Protheus.doc} RFUNA047
Estornar Titulos Convalescente
@author Leandro Rodrigues
@since 10/06/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/

User Function RFUNA47E()

Local lRet := .T.

UJQ->(DbSetOrder(1))
SE1->(DbSetOrder(1))

//Valido se ja foi estornado
If !Empty(UJP->UJP_DTESTO) 
	Alert("Ciclo de cobranca ja foi estornado !","Atencao")
	Return
Endif

If MsgYesNo("Confirma estorno dos titulos gerados historico "+UJP->UJP_CODIGO + " ?")
	
	//Posiciono nos dados de titulo gerados
	If UJQ->(DbSeek(xFilial("UJQ")+UJP->UJP_CODIGO))
		
		Begin Transaction 
	
		While UJQ->(!EOF()) ;
			.AND. UJQ->UJQ_FILIAL+UJQ->UJQ_CODIGO == UJP->UJP_FILIAL+UJP->UJP_CODIGO
		
			aTitulos:= {}
			
			//Posiciono no titulo para verificar se esta baixado
			If SE1->(DbSeek(xFilial("SE1")+UJQ->UJQ_PREFIX+UJQ->UJQ_NUM+UJQ->UJQ_PARCEL+UJQ->UJQ_TIPO)) .AND. SE1->E1_SALDO > 0
				
				//Chamo funcao para estornar titulos
				FWMsgRun(,{|oSay| lRet := EstTitulos(oSay) },'Aguarde...',"Estornando titulo : " + ALltrim(SE1->E1_NUM) + " parcela " + Alltrim(SE1->E1_PARCELA) + " ...")
				
				If !lRet
					DisarmTransaction()
					Exit
				Endif
			Else
				Alert("Ciclo de cobranca ja possui titulos baixados !","Atenção")
				DisarmTransaction()
				Exit
			Endif
			
			UJQ->(DbSkip())
		EndDo
		
		//se estornou com sucesso grava data de estorno
		If lRet	
			If Reclock("UJP",.F.)
				UJP->UJP_DTESTO := dDatabase
				UJP->(MsUnLock())
			Endif
		Endif
		
		End Transaction 
		
		
		
		MsgInfo("Processamento finalizado !")
	Endif
Endif
	
Return 

/*/{Protheus.doc} RFUNA047
Estornar Titulos Convalescente
@author Leandro Rodrigues
@since 10/06/2019
@version P12
@param Nao recebe parametros            
@return nulo
/*/
Static Function EstTitulos()

Local aTitulos	:= {}

Private lMsErroAuto 	:= .F.

//Preparo array para estornar titulos
AAdd(aTitulos, {"E1_FILIAL"  , SE1->E1_FILIAL  	, Nil})
AAdd(aTitulos, {"E1_PREFIXO" , SE1->E1_PREFIXO 	, Nil})
AAdd(aTitulos, {"E1_NUM"     , SE1->E1_NUM	   	, Nil})
AAdd(aTitulos, {"E1_PARCELA" , SE1->E1_PARCELA	, Nil})
AAdd(aTitulos, {"E1_TIPO"    , SE1->E1_TIPO  	, Nil})
						
		
MSExecAuto({|x,y| Fina040(x,y)},aTitulos, 5)
						
If lMsErroAuto
						
	MostraErro()
	DisarmTransaction()						
Endif

Return !lMsErroAuto