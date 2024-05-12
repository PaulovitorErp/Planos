#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} RFUNA028
//TODO Rotina para exclusão de manutenções em lote da Funeraria
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

// enquanto o usuário não cancelar a tela de perguntas
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
		
		if MsgYesNo("Deseja realmente excluir as taxas de manutenção?")
		
			FWMsgRun(,{|oSay| ExcluiReaj(oSay,dDataDe,dDataAte,cContratoDe,cContratoAte,cPlano,cIndice)},'Aguarde...','"Consultando as taxas de manutenção...')
		
		endif
		
	endif
	
EndDo

RestArea(aArea)

Return()

/*/{Protheus.doc} RFUNA028
//TODO Função que faz a exclusão das taxas de manutenção em lote - Funeraria
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

// verifico se não existe este alias criado
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

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

// se existir contratos a serem reajustados
if QRY->(!Eof())

	// Inicio o controle de transação
	BeginTran()
	
	While QRY->(!Eof())
		
		oSay:cCaption := ("Excluindo Taxa do Contrato: " + AllTrim(QRY->UH0_CONTRA) + "...")
		ProcessMessages()
		
		UH0->(DbSetOrder(1)) // UH0_FILIAL + UH0_CODIGO
		if UH0->(DbSeek(xFilial("UH0") + QRY->UH0_CODIGO)) 
		
			lActivate 	:= .F.
			lCommit		:= .F.
		
			// seto a operação de exclusão 
			oModel:SetOperation(5) 
			
			// ativo o modelo
			lActivate := oModel:Activate()
			
			// se o modelo foi ativado com sucesso
			if lActivate
			
				// comito a operação
				lCommit := oModel:CommitData()
				
				// desativo o modelo
				oModel:DeActivate()
				
			else
			
				if !MsgYesNo("Ocorreu um erro na exclusão da taxa de manutenção referente ao contrato " + AllTrim(UH0->UH0_CONTRA) + "." + cPulaLinha + "Deseja continuar?","Atenção!")
					
					// aborto a transação
					DisarmTransaction()
					
					lOK := .F.
					Exit
					
				endif
				
			endif
		
		endif	
		
		QRY->(DbSkip())
	
	EndDo
	
	if lOK
		// finalizo o controle de transação
		EndTran()
	endif
	
else
	MsgAlert("Não foram encontradas taxas de manutenção para o filtro informado!")	
endif

// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf  

RestArea(aArea) 

Return(lOK) 

/*/{Protheus.doc} RFUNA028
//TODO Função que cria as perguntas na SX1. - Funeraria
@author Raphael Martins
@since 03/04/2018
@version 1.0
@return 
@type function
/*/
Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relatório

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

//////////// Índice ///////////////
U_xPutSX1( cPerg, "06","Índice?","Índice?","Índice?","cIndice","C",3,0,0,"G","","U22","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)


Return() 