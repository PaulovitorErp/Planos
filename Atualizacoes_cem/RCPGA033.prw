#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ RCPGA033 บ Autor ณ Wellington Gon็alves		   บ Dataณ 19/10/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Rotina para exclusใo de manuten็๕es em lote do cemit้rio			  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Cemit้rio	                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function RCPGA033()

Local aArea			:= GetArea()
Local cPerg 		:= "RCPGA033"
Local dDataDe		:= CTOD("  /  /    ")
Local dDataAte		:= CTOD("  /  /    ")
Local cContratoDe	:= ""
Local cContratoAte	:= ""
Local cPlano		:= ""
Local cIndice		:= ""
Local lContinua		:= .T.
Local lAtivaRegra	:= SuperGetMv("MV_XREGCEM",,.F.)

// cria as perguntas na SX1
AjustaSx1(cPerg)

// enquanto o usuแrio nใo cancelar a tela de perguntas
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

		If lAtivaRegra
			cRegra		:= MV_PAR07
		EndIf
		
		if MsgYesNo("Deseja realmente excluir as taxas de manuten็ใo?")
			MsAguarde( {|| U_ExcluiReaj( dDataDe,dDataAte,cContratoDe,cContratoAte,cPlano,cIndice,cRegra)}, "Aguarde", "Consultando as taxas de manuten็ใo...", .F. )    
		endif
		
	endif
	
EndDo

RestArea(aArea)

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ ExcluiReaj บ Autor ณ Wellington Gon็alves	   บ Dataณ 19/10/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que faz a exclusใo das taxas de manuten็ใo em lote		  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

User Function ExcluiReaj(dDataDe,dDataAte,cContratoDe,cContratoAte,cPlano,cIndice,cRegra)

Local aArea			:= GetArea()
Local cQry 		   	:= ""     
Local cPulaLinha	:= chr(13)+chr(10) 
Local oModel 		:= FWLoadModel("RCPGA023")
Local lOK			:= .T.
Local lAtivaRegra	:= SuperGetMv("MV_XREGCEM",,.F.)

// verifico se nใo existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf  

cQry := " SELECT "                                                         					+ cPulaLinha
cQry += " U26.U26_CODIGO, "                                                					+ cPulaLinha
cQry += " U26.U26_DATA, "                                                  					+ cPulaLinha
cQry += " U26.U26_CONTRA "                                                 					+ cPulaLinha
cQry += " FROM "                                                           					+ cPulaLinha
cQry += + RetSqlName("U26") + " U26 "                                      					+ cPulaLinha
cQry += " INNER JOIN "                                                     					+ cPulaLinha
cQry += 	+ RetSqlName("U00") + " U00 "                                  					+ cPulaLinha
cQry += " 	ON U00.D_E_L_E_T_ <> '*' "                                     					+ cPulaLinha
cQry += " 	AND U00.U00_FILIAL = '" + xFilial("U00") + "' "                					+ cPulaLinha
cQry += " 	AND U00.U00_CODIGO = U26.U26_CONTRA "                          					+ cPulaLinha

if !Empty(cPlano)
	cQry += " 	AND U00.U00_PLANO IN " + FormatIn( AllTrim(cPlano),";") 		 			+ cPulaLinha		
endif

cQry += " AND U00.U00_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' "     + cPulaLinha
cQry += " WHERE "                                                          					+ cPulaLinha
cQry += " U26.D_E_L_E_T_ <> '*' "                                          					+ cPulaLinha
cQry += " AND U26.U26_FILIAL = '" + xFilial("U26") + "' "                                   + cPulaLinha
cQry += " AND U26.U26_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "   + cPulaLinha

if !Empty(cIndice)
	cQry += " AND U26.U26_TPINDI = '" + cIndice + "' "                         				+ cPulaLinha
endif

If lAtivaRegra .And. !Empty(cRegra)
	cQry += " AND U26.U26_REGRA = '" + cRegra + "' "                         				+ cPulaLinha
EndIf

// fun็ใo que converte a query gen้rica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

// se existir contratos a serem reajustados
if QRY->(!Eof())

	// Inicio o controle de transa็ใo
	BeginTran()
	
	While QRY->(!Eof())

		U26->(DbSetOrder(1)) // U26_FILIAL + U26_CODIGO
		if U26->(DbSeek(xFilial("U26") + QRY->U26_CODIGO)) 
		
			lActivate 	:= .F.
			lCommit		:= .F.
		
			// seto a opera็ใo de exclusใo 
			oModel:SetOperation(5) 
			
			// ativo o modelo
			lActivate := oModel:Activate()
			
			// se o modelo foi ativado com sucesso
			if lActivate
			
				// comito a opera็ใo
				lCommit := oModel:CommitData()
				
				// desativo o modelo
				oModel:DeActivate()
				
			else
			
				if !MsgYesNo("Ocorreu um erro na exclusใo da taxa de manuten็ใo referente ao contrato " + AllTrim(U26->U26_CONTRA) + "." + cPulaLinha + "Deseja continuar?","Aten็ใo!")
					
					// aborto a transa็ใo
					DisarmTransaction()
					
					lOK := .F.
					Exit
					
				endif
				
			endif
		
		endif	
		
		QRY->(DbSkip())
	
	EndDo
	
	if lOK
		// finalizo o controle de transa็ใo
		EndTran()
	endif
	
else
	MsgAlert("Nใo foram encontradas taxas de manuten็ใo para o filtro informado!")	
endif

// verifico se nใo existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf  

RestArea(aArea) 

Return(lOK) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบPrograma  ณ AjustaSX1 บ Autor ณ Wellington Gon็alves		   บ Dataณ 19/10/2016 บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบDesc.     ณ Fun็ใo que cria as perguntas na SX1.								  บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑบUso       ณ Vale do Cerrado                    			                      บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออบฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relat๓rio

Local aHelpPor		:= {}
Local aHelpEng		:= {}
Local aHelpSpa		:= {}
Local lAtivaRegra	:= SuperGetMv("MV_XREGCEM",,.F.)

///////////// Data do reajuste ////////////////
U_xPutSX1( cPerg, "01","Data da taxa de?","Data da taxa de?","Data da taxa de?","dDataDe","D",8,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "02","Data da taxa ate?","Data da taxa ate?","Data da taxa ate?","dDataAte","D",8,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// Contrato ///////////////
U_xPutSX1( cPerg, "03","Contrato De?","Contrato De?","Contrato De?","cContratoDe","C",6,0,0,"G","","U00","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "04","Contrato Ate?","Contrato Ate?","Contrato Ate?","cContratoAte","C",6,0,0,"G","","U00","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

///////////// Plano /////////////////
U_xPutSX1( cPerg, "05","Plano?","Plano?","Plano?","cPlano","C",99,0,0,"G","","U05MRK","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// อndice ///////////////
U_xPutSX1( cPerg, "06","อndice?","อndice?","อndice?","cIndice","C",3,0,0,"G","","U22","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// Regra ///////////////
If lAtivaRegra
	U_xPutSX1( cPerg, "07","Regra?","Regra?","Regra?","cRegra","C",6,0,0,"G","","U79","","","MV_PAR07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
EndIf

Return(Nil) 
