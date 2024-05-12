#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} RFUNA028
//TODO Rotina para exclus�o de manuten��es em lote da Funeraria
@author Raphael Martins
@since 03/04/2018
@version 1.0
@return 
@type function
/*/

User Function RFUNA030()

Local aArea			:= GetArea()
Local cPerg 		:= "RFUNA030"
Local dDataDe		:= CTOD("  /  /    ")
Local dDataAte		:= CTOD("  /  /    ")
Local cContratoDe	:= ""
Local cContratoAte	:= ""
Local cPlano		:= ""
Local cIndice		:= ""
Local lContinua		:= .T.

// cria as perguntas na SX1
AjustaSx1(cPerg)

// enquanto o usu�rio n�o cancelar a tela de perguntas
While lContinua
	
	// chama a tela de perguntas
	lContinua := Pergunte(cPerg,.T.)
	
	if lContinua 
	
		dDataDe			:= MV_PAR01
		dDataAte		:= MV_PAR02 
		cContratoDe 	:= MV_PAR03
		cContratoAte	:= MV_PAR04 
		cPlano			:= MV_PAR05
		cIndice			:= MV_PAR06   
		
		if MsgYesNo("Deseja realmente excluir as taxas de manuten��o?")
		
			FWMsgRun(,{|oSay| ExcluiReaj(oSay,dDataDe,dDataAte,cContratoDe,cContratoAte,cPlano,cIndice)},'Aguarde...','"Consultando as taxas de manuten��o...')
		
		endif
		
	endif
	
EndDo

RestArea(aArea)

Return()

/*/{Protheus.doc} RFUNA028
//TODO Fun��o que faz a exclus�o das taxas de manuten��o em lote - Funeraria
@author Raphael Martins
@since 03/04/2018
@version 1.0
@return 
@type function
/*/

Static Function ExcluiReaj(oSay,dDataDe,dDataAte,cContratoDe,cContratoAte,cPlano,cIndice)

Local aArea			:= GetArea()
Local cQry 		   	:= ""     
Local cPulaLinha	:= chr(13)+chr(10) 
Local oModel 		:= FWLoadModel("RFUNA028")
Local lOK			:= .T.

// verifico se n�o existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf  

cQry := " SELECT "                                                         					+ cPulaLinha
cQry += " UH0.UH0_CODIGO, "                                                					+ cPulaLinha
cQry += " UH0.UH0_DATA, "                                                  					+ cPulaLinha
cQry += " UH0.UH0_CONTRA "                                                 					+ cPulaLinha
cQry += " FROM "                                                           					+ cPulaLinha
cQry += + RetSqlName("UH0") + " UH0 "                                      					+ cPulaLinha
cQry += " INNER JOIN "                                                     					+ cPulaLinha
cQry += 	+ RetSqlName("UF2") + " UF2 "                                  					+ cPulaLinha
cQry += " 	ON UF2.D_E_L_E_T_ <> '*' "                                     					+ cPulaLinha
cQry += " 	AND UF2.UF2_FILIAL = '" + xFilial("UF2") + "' "                					+ cPulaLinha
cQry += " 	AND UF2.UF2_CODIGO = UH0.UH0_CONTRA "                          					+ cPulaLinha

if !Empty(cPlano)
	cQry += " 	AND UF2.UF2_PLANO IN " + FormatIn( AllTrim(cPlano),";") 		 			+ cPulaLinha		
endif

cQry += " AND UF2.UF2_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' "     + cPulaLinha
cQry += " WHERE "                                                          					+ cPulaLinha
cQry += " UH0.D_E_L_E_T_ <> '*' "                                          					+ cPulaLinha
cQry += " AND UH0.UH0_FILIAL = '" + xFilial("UH0") + "' "                                   + cPulaLinha
cQry += " AND UH0.UH0_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "   + cPulaLinha

if !Empty(cIndice)
	cQry += " AND UH0.UH0_TPINDI = '" + cIndice + "' "                         				+ cPulaLinha
endif

// fun��o que converte a query gen�rica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

// se existir contratos a serem reajustados
if QRY->(!Eof())

	// Inicio o controle de transa��o
	BeginTran()
	
	While QRY->(!Eof())
		
		oSay:cCaption := ("Excluindo Taxa do Contrato: " + AllTrim(QRY->UH0_CONTRA) + "...")
		ProcessMessages()
		
		UH0->(DbSetOrder(1)) // UH0_FILIAL + UH0_CODIGO
		if UH0->(DbSeek(xFilial("UH0") + QRY->UH0_CODIGO)) 
		
			lActivate 	:= .F.
			lCommit		:= .F.
		
			// seto a opera��o de exclus�o 
			oModel:SetOperation(5) 
			
			// ativo o modelo
			lActivate := oModel:Activate()
			
			// se o modelo foi ativado com sucesso
			if lActivate
			
				// comito a opera��o
				lCommit := oModel:CommitData()
				
				// desativo o modelo
				oModel:DeActivate()
				
			else
			
				if !MsgYesNo("Ocorreu um erro na exclus�o da taxa de manuten��o referente ao contrato " + AllTrim(UH0->UH0_CONTRA) + "." + cPulaLinha + "Deseja continuar?","Aten��o!")
					
					// aborto a transa��o
					DisarmTransaction()
					
					lOK := .F.
					Exit
					
				endif
				
			endif
		
		endif	
		
		QRY->(DbSkip())
	
	EndDo
	
	if lOK
		// finalizo o controle de transa��o
		EndTran()
	endif
	
else
	MsgAlert("N�o foram encontradas taxas de manuten��o para o filtro informado!")	
endif

// verifico se n�o existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf  

RestArea(aArea) 

Return(lOK) 

/*/{Protheus.doc} RFUNA028
//TODO Fun��o que cria as perguntas na SX1. - Funeraria
@author Raphael Martins
@since 03/04/2018
@version 1.0
@return 
@type function
/*/
Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relat�rio

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

///////////// Data do reajuste ////////////////
U_xPutSX1( cPerg, "01","Data da taxa de?","Data da taxa de?","Data da taxa de?","dDataDe","D",8,0,0,"G","","U08","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "02","Data da taxa ate?","Data da taxa ate?","Data da taxa ate?","dDataAte","D",8,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// Contrato ///////////////
U_xPutSX1( cPerg, "03","Contrato De?","Contrato De?","Contrato De?","cContratoDe","C",6,0,0,"G","","UF2","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "04","Contrato Ate?","Contrato Ate?","Contrato Ate?","cContratoAte","C",6,0,0,"G","","UF2","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

///////////// Plano /////////////////
U_xPutSX1( cPerg, "05","Plano?","Plano?","Plano?","cPlano","C",99,0,0,"G","","UF0MRK","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// �ndice ///////////////
U_xPutSX1( cPerg, "06","�ndice?","�ndice?","�ndice?","cIndice","C",3,0,0,"G","","U22","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)


Return() 