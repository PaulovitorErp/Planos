#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͺ��
���Programa  � RCPGA032 � Autor � Wellington Gon�alves		   � Data� 14/10/2016 ���
���������������������������������������������������������������������������������ͺ��
���Desc.     � Rotina para exclus�o de reajustes em lote do cemit�rio			  ���
���������������������������������������������������������������������������������ͺ��
���Uso       � Cemit�rio	                    			                      ���
���������������������������������������������������������������������������������ͺ��
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/

User Function RCPGA032()

Local aArea			:= GetArea()
Local cPerg 		:= "RCPGA032"
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
		
		if MsgYesNo("Deseja realmente excluir os reajustes?")
			MsAguarde( {|| ExcluiReaj(dDataDe,dDataAte,cContratoDe,cContratoAte,cPlano,cIndice)}, "Aguarde", "Consultando os reajustes...", .F. )    
		endif
		
	endif
	
EndDo

RestArea(aArea)

Return()

/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͺ��
���Programa  � ExcluiReaj � Autor � Wellington Gon�alves	   � Data� 14/10/2016 ���
���������������������������������������������������������������������������������ͺ��
���Desc.     � Fun��o que faz a exclus�o dos reajustes em lote					  ���
���������������������������������������������������������������������������������ͺ��
���Uso       � Vale do Cerrado                    			                      ���
���������������������������������������������������������������������������������ͺ��
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/

Static Function ExcluiReaj(dDataDe,dDataAte,cContratoDe,cContratoAte,cPlano,cIndice)

Local aArea			:= GetArea()
Local cQry 		   	:= ""     
Local cPulaLinha	:= chr(13)+chr(10) 
Local oModel 		:= FWLoadModel("RCPGA013")
Local lOK			:= .T.

// verifico se n�o existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf  

cQry := " SELECT "                                                         					+ cPulaLinha
cQry += " U20.U20_CODIGO, "                                                					+ cPulaLinha
cQry += " U20.U20_DATA, "                                                  					+ cPulaLinha
cQry += " U20.U20_CONTRA "                                                 					+ cPulaLinha
cQry += " FROM "                                                           					+ cPulaLinha
cQry += + RetSqlName("U20") + " U20 "                                      					+ cPulaLinha
cQry += " INNER JOIN "                                                     					+ cPulaLinha
cQry += 	+ RetSqlName("U00") + " U00 "                                  					+ cPulaLinha
cQry += " 	ON U00.D_E_L_E_T_ <> '*' "                                     					+ cPulaLinha
cQry += " 	AND U00.U00_FILIAL = '" + xFilial("U00") + "' "                					+ cPulaLinha
cQry += " 	AND U00.U00_CODIGO = U20.U20_CONTRA "                          					+ cPulaLinha

if !Empty(cPlano)
	cQry += " 	AND U00.U00_PLANO IN " + FormatIn( AllTrim(cPlano),";") 		 			+ cPulaLinha		
endif

cQry += " AND U00.U00_CODIGO BETWEEN '" + cContratoDe + "' AND '" + cContratoAte + "' "     + cPulaLinha
cQry += " WHERE "                                                          					+ cPulaLinha
cQry += " U20.D_E_L_E_T_ <> '*' "                                          					+ cPulaLinha
cQry += " AND U20.U20_FILIAL = '" + xFilial("U20") + "' "                                   + cPulaLinha
cQry += " AND U20.U20_DATA BETWEEN '" + DTOS(dDataDe) + "' AND '" + DTOS(dDataAte) + "' "   + cPulaLinha

if !Empty(cIndice)
	cQry += " AND U20.U20_TPINDI = '" + cIndice + "' "                         				+ cPulaLinha
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

		U20->(DbSetOrder(1)) // U20_FILIAL + U20_CODIGO
		if U20->(DbSeek(xFilial("U20") + QRY->U20_CODIGO)) 
		
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
			
				if !MsgYesNo("Ocorreu um erro na exclus�o do reajuste referente ao contrato " + AllTrim(U20->U20_CONTRA) + "." + cPulaLinha + "Deseja continuar?","Aten��o!")
					
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
	MsgAlert("N�o foram encontrados reajustes para o filtro informado!")	
endif

// verifico se n�o existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf  

RestArea(aArea) 

Return(lOK) 

/*�����������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������ͺ��
���Programa  � AjustaSX1 � Autor � Wellington Gon�alves		   � Data� 14/10/2016 ���
���������������������������������������������������������������������������������ͺ��
���Desc.     � Fun��o que cria as perguntas na SX1.								  ���
���������������������������������������������������������������������������������ͺ��
���Uso       � Vale do Cerrado                    			                      ���
���������������������������������������������������������������������������������ͺ��
�������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������*/

Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relat�rio

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

///////////// Data do reajuste ////////////////
U_xPutSX1( cPerg, "01","Data do reajuste de?","Data do reajuste de?","Data do reajuste de?","dDataDe","D",8,0,0,"G","","U08","","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "02","Data do reajuste ate?","Data do reajuste ate?","Data do reajuste ate?","dDataAte","D",8,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// Contrato ///////////////

U_xPutSX1( cPerg, "03","Contrato De?","Contrato De?","Contrato De?","cContratoDe","C",6,0,0,"G","","U00","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
U_xPutSX1( cPerg, "04","Contrato Ate?","Contrato Ate?","Contrato Ate?","cContratoAte","C",6,0,0,"G","","U00","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

///////////// Plano /////////////////

U_xPutSX1( cPerg, "05","Plano?","Plano?","Plano?","cPlano","C",99,0,0,"G","","U05MRK","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

//////////// �ndice ///////////////

U_xPutSX1( cPerg, "06","�ndice?","�ndice?","�ndice?","cIndice","C",3,0,0,"G","","U22","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)


Return() 