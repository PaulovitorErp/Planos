#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} RUTILE07
Integra็ใo de cadastros pendentes de sincroniza็ใo junto ao servidor de dados (nuvem)
@author Maiki Perin
@since 29/08/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***************************************************/
User function RUTILE07(cTab,aRegTab,cEmpInt,cFilInt)
/***************************************************/

Local lInteg
Local lRet			:= .T.

Default cTab		:= ""
Default aRegTab		:= {}

Private nStart		:= 0
Private aAuxEmail	:= {}

If !IsBlind()
	If MsgYesNo("Confirma integra็ใo de dados cadastrais pendentes de sincroniza็ใo?")
		FWMsgRun(,{|oSay| lInteg := Integrar(oSay,cTab,aRegTab)},'Aguarde','Realizando integra็ใo...')
	EndIf
Else
	RpcSetType(3)
	If RpcSetEnv(cEmpInt,cFilInt)
		lInteg := Integrar(,cTad,aRegTab)
	Endif
EndIf

If lInteg

	If !IsBlind()
		MsgInfo("Sincroniza็ใo finalizada.","Aten็ใo")
	Else
		
		FwLogMsg("INFO",, "REST", FunName(), "", "01", "Sincroniza็ใo finalizada.", 0, (nStart - Seconds()), {})
	Endif
Else
	If !IsBlind()
		MsgInfo("Sincroniza็ใo nใo realizada.","Aten็ใo")
		lRet := .F.
	Else
		FwLogMsg("ERROR",, "REST", FunName(), "", "01", "Sincroniza็ใo nao realizada.", 0, (nStart - Seconds()), {})
		lRet := .F.
	Endif
Endif

Return lRet

/******************************************/
Static Function Integrar(oSay,cTab,aRegTab) 
/******************************************/

Local lRet			:= .T.
Local cQry			:= ""
Local cQry2			:= ""
Local cCpo			:= ""
Local aTab			:= {}
Local aTabFilha		:= {}
Local lContinua		:= .T.	

Private lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)

//Sele็ใo dos cadastros a serem integrados
If Select("QRYTAB") > 0
	QRYTAB->(DbCloseArea())
EndIf  

cQry := "SELECT U54.U54_CODIGO, U54.U54_TABELA, U54.U54_JSON, U54.U54_URL"
cQry += " FROM "+RetSqlName("U54")+" U54"
cQry += " WHERE U54.D_E_L_E_T_	<> '*'" 
cQry += " AND U54.U54_FILIAL 	= '"+xFilial("U54")+"'

If !Empty(cTab)
	cQry += " AND U54.U54_TABELA = '"+cTab+"'"
Else
	cQry += " AND U54.U54_TABELA <> 'SE1'" //Rotina pr๓pria
	cQry += " AND U54.U54_STATUS 	= 'A'" //Ativos
Endif
cQry += " ORDER BY U54.U54_ORDEM"

cQry := ChangeQuery(cQry)
//MemoWrite("c:\temp\QRYTAB.txt",cQry)
TcQuery cQry NEW Alias "QRYTAB"

While QRYTAB->(!EOF())

	aTab 		:= {}
	aTabFilha	:= {}
	
	//Valido se integracao ้ da Regra de contrato
	if QRYTAB->U54_TABELA == "UJ6"
		JsonUJ6(QRYTAB->U54_URL)
		Return .T.
	endif

	cCpo := IIF(SubStr(QRYTAB->U54_TABELA,1,1) == "S",SubStr(QRYTAB->U54_TABELA,2,2),QRYTAB->U54_TABELA)+"_XINTCA"
	
	If !(QRYTAB->U54_TABELA)->(FieldPos(cCpo)) > 0
		
		If !IsBlind()
			MsgInfo("O campo |"+IIF(SubStr(QRYTAB->U54_TABELA,1,1) == "S",SubStr(QRYTAB->U54_TABELA,2,2),QRYTAB->U54_TABELA)+"_XINTCA| nใo consta cadastrado na tabela |"+QRYTAB->U54_TABELA+"|. Opera็ใo cancelada.","Aten็ใo")
		Else
			FwLogMsg("ERROR",, "REST", FunName(), "", "01", "O campo |"+IIF(SubStr(QRYTAB->U54_TABELA,1,1) == "S",SubStr(QRYTAB->U54_TABELA,2,2),QRYTAB->U54_TABELA)+"_XINTCA| nใo consta cadastrado na tabela |"+QRYTAB->U54_TABELA+"|. Opera็ใo cancelada.", 0, (nStart - Seconds()), {})

		Endif
		
		lRet := .F.
		Exit
	Endif
	
	AAdd(aTab, QRYTAB->U54_CODIGO)			//1-Codigo
	AAdd(aTab, QRYTAB->U54_TABELA)			//2-Tabela
	AAdd(aTab, AllTrim(QRYTAB->U54_JSON))	//3-Desc.JSON
	AAdd(aTab, AllTrim(QRYTAB->U54_URL))	//4-URL

	//Sele็ใo das tabelas filhas a serem integradas
	If Select("QRYTAB_F") > 0
		QRYTAB_F->(DbCloseArea())
	EndIf  
	
	cQry2 := "SELECT U57.U57_ITEM, U57.U57_TABELA, U57.U57_JSON, U57.U57_CHAVE"
	cQry2 += " FROM "+RetSqlName("U57")+" U57"
	cQry2 += " WHERE U57.D_E_L_E_T_	<> '*'" 
	cQry2 += " AND U57.U57_FILIAL 	= '"+xFilial("U57")+"'
	cQry2 += " AND U57.U57_CODIGO 	= '"+QRYTAB->U54_CODIGO+"'
	
	cQry2 := ChangeQuery(cQry2)
	//MemoWrite("c:\temp\QRYTAB_F.txt",cQry2)
	TcQuery cQry2 NEW Alias "QRYTAB_F"
	
	While QRYTAB_F->(!EOF())
			
		cCpo := IIF(SubStr(QRYTAB_F->U57_TABELA,1,1) == "S",SubStr(QRYTAB_F->U57_TABELA,2,2),QRYTAB_F->U57_TABELA)+"_XINTCA"
		
		If !(QRYTAB_F->U57_TABELA)->(FieldPos(cCpo)) > 0
			
			If !IsBlind()
				MsgInfo("O campo |"+IIF(SubStr(QRYTAB_F->U57_TABELA,1,1) == "S",SubStr(QRYTAB_F->U57_TABELA,2,2),QRYTAB_F->U57_TABELA)+"_XINTCA| nใo consta cadastrado na tabela |"+QRYTAB_F->U57_TABELA+"|. Opera็ใo cancelada.","Aten็ใo")
			Else
				
				FwLogMsg("ERROR",, "REST", FunName(), "", "01", "O campo |"+IIF(SubStr(QRYTAB_F->U57_TABELA,1,1) == "S",SubStr(QRYTAB_F->U57_TABELA,2,2),QRYTAB_F->U57_TABELA)+"_XINTCA| nใo consta cadastrado na tabela |"+QRYTAB_F->U57_TABELA+"|. Opera็ใo cancelada.", 0, (nStart - Seconds()), {})

			Endif
			
			lContinua := .F.
			Exit
		Endif
		
		AAdd(aTabFilha,{QRYTAB_F->U57_ITEM,;			//1-Item
						QRYTAB_F->U57_TABELA,;			//2-Tabela
						AllTrim(QRYTAB_F->U57_JSON),;	//3-Desc.JSON
						QRYTAB_F->U57_CHAVE;			//4-Indice
						})
	
		QRYTAB_F->(DbSkip())
	EndDo
	
	If lContinua
		lRet := SincCad(oSay,aTab,aTabFilha,aRegTab)
	Else
		lRet := .F.
	Endif

	QRYTAB->(DbSkip())
EndDo

If Select("QRYTAB") > 0
	QRYTAB->(DbCloseArea())
EndIf 

If Select("QRYTAB_F") > 0
	QRYTAB_F->(DbCloseArea())
EndIf 

Return lRet

/***************************************************/
Static Function SincCad(oSay,aTab,aTabFilha,aRegTab) 
/***************************************************/

Local lRet			:= .T.

Local nI, nJ, nK, nX, nZ, nAux

Local cRegIn		:= ""

Local cQry			:= ""
Local cQry2			:= ""

Local nCont			:= 0 

Local lAux			:= .T. 
Local cJSON			:= "" 

Local aRegs			:= {}	
Local aRegsF		:= {}	

Local aCpos			:= {}
Local aSuf			:= {}
Local lWhere		:= .F.

Local cURL			:= ""
Local cChaveVirt	:= GetMv("MV_XKEYAPP")
Local nTimeOut		:= 120
Local aHeadOut		:= {}
Local cHeadRet		:= ""
Local cPostRet		:= ""   

oObj				:= Nil

//chave de autenticacao de integracacao com o Virtus App
aadd(aHeadOut,"Content-Type:application/json")
aadd(aHeadOut,"Authorization: " + cChaveVirt)
	
If Len(aTab) > 0
	
	If Select("QRYREG") > 0
		QRYREG->(DbCloseArea())
	EndIf  

	cQry := "SELECT "+aTab[2]+".R_E_C_N_O_ AS "+aTab[2]+"RECNO"
	cQry += " FROM "+RetSqlName(aTab[2])+" "+aTab[2]+""
	cQry += " WHERE "+aTab[2]+".D_E_L_E_T_ <> '*'" 
	cQry += " AND "+aTab[2]+"."+IIF(SubStr(aTab[2],1,1) == "S",SubStr(aTab[2],2,2),aTab[2])+"_XINTCA <> 'S'" //Diferente de integrado/sincronizado
	
	//Se produto
	If aTab[2] == "SB1"
		cQry += " AND SB1.B1_XSINCRO = 'S'" //Configurado para sincronizar
	
	//Se cobran็a
	ElseIf aTab[2] == "SE1"

		For nAux := 1 To Len(aRegTab)
			If nAux == Len(aRegTab)
				cRegIn += "'" + cValToChar(aRegTab[nAux]) + "'"
			Else
				cRegIn += "'" + cValToChar(aRegTab[nAux]) + "',"
			Endif
		Next nAux
		
		cQry += " AND SE1.R_E_C_N_O_ IN ("+cRegIn+")"
	Endif
	
	cQry := ChangeQuery(cQry)
	//MemoWrite("c:\temp\QRYREG.txt",cQry)
	TcQuery cQry NEW Alias "QRYREG"
	
	While QRYREG->(!EOF())
	
		//Se cliente, verifica se o mesmo estแ relacionado a contratos (cemit้rio e/ou funerแria)
		If aTab[2] == "SA1"
			
			SA1->(DbGoTo(QRYREG->&(aTab[2]+"RECNO")))
			
			If !PossuiCont(SA1->A1_COD,SA1->A1_LOJA)
				QRYREG->(DbSkip())
				Loop
			Endif
		Endif

		AAdd(aRegs,{aTab[1],;						//1-Codigo
		 			aTab[2],;						//2-Tabela
		 			QRYREG->&(aTab[2]+"RECNO"),;	//3-R_E_C_N_O_
		 			aTab[3];						//4-JSON
		 			})
		nCont++
		
		QRYREG->(DbSkip())
	EndDo
         
	If nCont == 0
		
		If !IsBlind()
			MsgInfo("Nenhum registro pendente de sincroniza็ใo para a tabela "+aTab[2]+".","Aten็ใo")
		Else
			
			FwLogMsg("INFO",, "REST", FunName(), "", "01", "Nenhum registro pendente de sincroniza็ใo para a tabela "+aTab[2]+".", 0, (nStart - Seconds()), {})

		EndIf
		
		lAux := .F.
	Endif
	
	If lAux
	
		If Len(aTabFilha) == 0
	
			For nI := 1 To Len(aRegs)
			
				If !IsBlind()
					oSay:cCaption := ("Sincronizando tabela "+aRegs[nI][2]+", registro "+cValToChar(aRegs[nI][3])+" ...")
					ProcessMessages()
				Else
					
					FwLogMsg("INFO",, "REST", FunName(), "", "01", "Sincronizando tabela "+aRegs[nI][2]+", registro "+cValToChar(aRegs[nI][3])+" ...", 0, (nStart - Seconds()), {})

				EndIf
				
								   //Codigo	  	 Tabela		   R_E_C_N_O_    Desc.JSON
	        	cJSON := MontaJSON(aRegs[nI][1], aRegs[nI][2], aRegs[nI][3], aRegs[nI][4])
	        	//cJSON := FWJsonSerialize(cJSON,.F.,.F.)
	        	
	        	If !Empty(cJSON)
	        	
	            	cURL := AllTrim(Lower(aTab[4]))
	            	
	            	cPostRet := HTTPSPost(cURL,"","","","",cJSON,nTimeOut,aHeadOut,@cHeadRet)
	            	//cPostRet := HTTPPost(cURL,"",cJSON,nTimeOut,aHeadOut,@cHeadRet)
	            		            	
	                //Inclui log da integra็ใo
	        		RecLock("U56",.T.)
	        		U56->U56_FILIAL := xFilial("U56")
	        		U56->U56_CODIGO	:= GetSX8Num("U56","U56_CODIGO")
	        		U56->U56_TABELA	:= aRegs[nI][2]
	        		U56->U56_RECNO	:= aRegs[nI][3]
	        		U56->U56_JSON	:= cJSON 
	        		U56->U56_RETORN	:= cPostRet 
	        		U56->U56_DATA	:= dDataBase
	        		U56->U56_HORA	:= Time()
	        		U56->U56_USER	:= cUserName
	        		U56->(MsUnlock())	 
	        		
	        		ConfirmSX8()
	            
	        		//Flag sincroniza็ใo do registro
	        		If !Empty(cPostRet) .And. FWJsonDeserialize(cPostRet,@oObj)
	        			
	        			If Lower(oObj:code) == "200" //ok

		        			RecLock(aRegs[nI][2],.F.)
		        			(aRegs[nI][2])->&(IIF(SubStr(aRegs[nI][2],1,1) == "S",SubStr(aRegs[nI][2],2,2),aRegs[nI][2])+"_XINTCA") := "S"
		        			(aRegs[nI][2])->(MsUnlock())
		        		Endif
	        		Endif
	            Else
	            	//Se vendedor/usuแrio
	            	If aRegs[nI][2] == "SA3"
	        			RecLock(aRegs[nI][2],.F.)
	        			(aRegs[nI][2])->&(IIF(SubStr(aRegs[nI][2],1,1) == "S",SubStr(aRegs[nI][2],2,2),aRegs[nI][2])+"_XINTCA") := "S"
	        			(aRegs[nI][2])->(MsUnlock())
	            	Endif
	            Endif
			Next nI
		Else //Sincroniza็ใo possuindo tabelas filhas

			For nI := 1 To Len(aRegs)
			
				aRegsF := {}

				For nJ := 1 To Len(aTabFilha)
					
					lWhere := .F.

					If Select("QRYREG_F") > 0
						QRYREG_F->(DbCloseArea())
					EndIf  
					
					cQry2 := "SELECT "+aTabFilha[nJ][2]+".R_E_C_N_O_ AS "+aTabFilha[nJ][2]+"RECNO"
					cQry2 += " FROM "+RetSqlName(aTabFilha[nJ][2])+" "+aTabFilha[nJ][2]+" INNER JOIN "+RetSqlName(aRegs[nI][2])+" "+aRegs[nI][2]+" ON"

					aCpos := StrToKArr(aTabFilha[nJ][4],"+")
					
					For nK := 1 To Len(aCpos)
						
						aSuf := StrToKArr(aCpos[nK],"_")
						
						If (aRegs[nI][2])->(FieldPos(IIF(SubStr(aRegs[nI][2],1,1) == "S",SubStr(aRegs[nI][2],2,2),aRegs[nI][2]) + "_"+ aSuf[2])) > 0
							If !lWhere
								cQry2 += " "+aTabFilha[nJ][2]+"."+aCpos[nK]+" = "+aRegs[nI][2]+"."+IIF(SubStr(aRegs[nI][2],1,1) == "S",SubStr(aRegs[nI][2],2,2),aRegs[nI][2]) + "_" + aSuf[2]+""
								lWhere := .T.
							Else
								cQry2 += " AND "+aTabFilha[nJ][2]+"."+aCpos[nK]+" = "+aRegs[nI][2]+"."+IIF(SubStr(aRegs[nI][2],1,1) == "S",SubStr(aRegs[nI][2],2,2),aRegs[nI][2]) + "_" + aSuf[2]+""
							Endif
						Endif						
					Next nK
					cQry2 += " AND "+aRegs[nI][2]+".D_E_L_E_T_ <> '*'"
					cQry2 += " AND "+aRegs[nI][2]+".R_E_C_N_O_ = "+cValToChar(aRegs[nI][3])+""

					cQry2 += " WHERE "+aTabFilha[nJ][2]+".D_E_L_E_T_ <> '*'" 
					cQry2 += " AND "+aTabFilha[nJ][2]+"."+IIF(SubStr(aTabFilha[nJ][2],1,1) == "S",SubStr(aTabFilha[nJ][2],2,2),aTabFilha[nJ][2])+"_FILIAL = "+aRegs[nI][2]+"."+IIF(SubStr(aRegs[nI][2],1,1) == "S",SubStr(aRegs[nI][2],2,2),aRegs[nI][2])+"_FILIAL"
					cQry2 += " AND "+aTabFilha[nJ][2]+"."+IIF(SubStr(aTabFilha[nJ][2],1,1) == "S",SubStr(aTabFilha[nJ][2],2,2),aTabFilha[nJ][2])+"_XINTCA <> 'S'" //Diferente de integrado/sincronizado
					
					cQry2 := ChangeQuery(cQry2)
					//MemoWrite("c:\temp\QRYREG_F.txt",cQry2)
					TcQuery cQry2 NEW Alias "QRYREG_F"
					
					While QRYREG_F->(!EOF())
				
						AAdd(aRegsF,{aTabFilha[nJ][1],;						//1-Item
						 			aTabFilha[nJ][2],;						//2-Tabela
						 			QRYREG_F->&(aTabFilha[nJ][2]+"RECNO"),;	//3-R_E_C_N_O_
						 			aTabFilha[nJ][3];						//4-JSON
						 			})
					
						QRYREG_F->(DbSkip())
					EndDo
				Next nJ

	        	cJSON := MontaJSONF(aRegs[nI],aRegsF)
	        	//cJSON := FWJsonSerialize(cJSON,.F.,.F.)
	        	
	        	If !Empty(cJSON)
	        	
	            	cURL := AllTrim(Lower(aTab[4]))
	            	
	            	cPostRet := HTTPSPost(cURL,"","","","",cJSON,nTimeOut,aHeadOut,@cHeadRet)
	            	//cPostRet := HTTPPost(cURL,"",cJSON,nTimeOut,aHeadOut,@cHeadRet)
	            		            	
	                //Inclui log da integra็ใo (pai)
	        		RecLock("U56",.T.)
	        		U56->U56_FILIAL := xFilial("U56")
	        		U56->U56_CODIGO	:= GetSX8Num("U56","U56_CODIGO")
	        		U56->U56_TABELA	:= aRegs[nI][2]
	        		U56->U56_RECNO	:= aRegs[nI][3]
	        		U56->U56_JSON	:= cJSON 
	        		U56->U56_RETORN	:= cPostRet 
	        		U56->U56_DATA	:= dDataBase
	        		U56->U56_HORA	:= Time()
	        		U56->U56_USER	:= cUserName
	        		U56->(MsUnlock())	 
	        		
	        		ConfirmSX8()
	            
	        		//Flag sincroniza็ใo do registro
	        		If !Empty(cPostRet) .And. FWJsonDeserialize(cPostRet,@oObj)
	        			
	        			If Lower(oObj:code)== "200" //ok

	        				DbSelectArea(aRegs[nI][2])
	        				(aRegs[nI][2])->(DbGoTo(aRegs[nI][3]))	        		
	
		        			RecLock(aRegs[nI][2],.F.)
		        			(aRegs[nI][2])->&(IIF(SubStr(aRegs[nI][2],1,1) == "S",SubStr(aRegs[nI][2],2,2),aRegs[nI][2])+"_XINTCA") := "S"
		        			(aRegs[nI][2])->(MsUnlock())
		        		Endif
	        		Endif
	        		
	        		For nZ := 1 To Len(aRegsF)
	        		
		                //Inclui log da integra็ใo (filhas)
		        		RecLock("U56",.T.)
		        		U56->U56_FILIAL := xFilial("U56")
		        		U56->U56_CODIGO	:= GetSX8Num("U56","U56_CODIGO")
		        		U56->U56_TABELA	:= aRegsF[nZ][2]
		        		U56->U56_RECNO	:= aRegsF[nZ][3]
		        		U56->U56_JSON	:= cJSON 
		        		U56->U56_RETORN	:= cPostRet 
		        		U56->U56_DATA	:= dDataBase
		        		U56->U56_HORA	:= Time()
		        		U56->U56_USER	:= cUserName
		        		U56->(MsUnlock())	 
		        		
		        		ConfirmSX8()
		            
		        		//Flag sincroniza็ใo do registro
		        		If !Empty(cPostRet) .And. FWJsonDeserialize(cPostRet,@oObj)
		        			
		        			If Lower(oObj:code) == "200" //ok 

		        				DbSelectArea(aRegsF[nZ][2])
		        				(aRegsF[nZ][2])->(DbGoTo(aRegsF[nZ][3]))	        		
		
			        			RecLock(aRegsF[nZ][2],.F.)
			        			(aRegsF[nZ][2])->&(IIF(SubStr(aRegsF[nZ][2],1,1) == "S",SubStr(aRegsF[nZ][2],2,2),aRegsF[nZ][2])+"_XINTCA") := "S"
			        			(aRegsF[nZ][2])->(MsUnlock())
			        		Endif
		        		Endif
		        	Next nZ        			
	            Endif
	        Next nI
		Endif
	Else
		lRet := .F.
	Endif
Else
	lRet := .F.
Endif

If Select("QRYREG") > 0
	QRYREG->(DbCloseArea())
EndIf  

If Select("QRYREG_F") > 0
	QRYREG_F->(DbCloseArea())
EndIf  

Return lRet

/***************************************************/
Static Function MontaJSON(cCod,cTab,nRecnoTab,cDesc) 
/***************************************************/

Local cRet 			:= ""

Local aCab 			:= {}
Local aLin 			:= {}

Local cQry			:= ""
Local cQry2			:= ""

Local cCliente		:= ""
Local cVendedor		:= ""

Local aCnpjs		:= {}
Local nI

DbSelectArea(cTab)
(cTab)->(DbGoTo(nRecnoTab))

//Tratamento para entidade vendedor/usuแrio
If cTab == "SA3"
	
	If Len(aAuxEmail) == 0
		AAdd(aAuxEmail,SA3->A3_XEMAIL)
	Else
		If aScan(aAuxEmail,{|x| x == SA3->A3_XEMAIL}) > 0
			Return cRet
		Endif
	Endif
Endif

If !Empty(cDesc)
	cRet :=  '{' + CRLF
Endif

//Associa os CNPJs vinculados ao registro
If Select("QRYPERT") > 0
	QRYPERT->(DbCloseArea())
EndIf  

If !Empty((cTab)->&(IIF(SubStr(cTab,1,1) == "S",SubStr(cTab,2,2),cTab)+"_FILIAL"))

	//Se vendedor/usuแrio
	If cTab == "SA3"
		cQry := "SELECT UJ3.UJ3_CGC"
		cQry += " FROM "+RetSqlName("UJ3")+" UJ3 INNER JOIN "+RetSqlName("SA3")+" SA3 ON UJ3.UJ3_CODFIL 	= SA3.A3_FILIAL"
		cQry += " 																		AND SA3.A3_XEMAIL	= '"+SA3->A3_XEMAIL+"'" 
		cQry += " 																		AND SA3.D_E_L_E_T_	<> '*'" 
		cQry += " WHERE UJ3.D_E_L_E_T_	<> '*'" 
	Else
		cQry := "SELECT UJ3.UJ3_CGC"
		cQry += " FROM "+RetSqlName("UJ3")+" UJ3"
		cQry += " WHERE UJ3.D_E_L_E_T_	<> '*'" 
		cQry += " AND UJ3.UJ3_CODFIL 	LIKE '"+AllTrim((cTab)->&(IIF(SubStr(cTab,1,1) == "S",SubStr(cTab,2,2),cTab)+"_FILIAL"))+"%'"
	Endif
	
	cQry := ChangeQuery(cQry)
	//MemoWrite("c:\temp\QRYPERT.txt",cQry)
	TcQuery cQry NEW Alias "QRYPERT"

	While QRYPERT->(!EOF())
		AAdd(aCnpjs,QRYPERT->UJ3_CGC)
		QRYPERT->(DbSkip())
	EndDo
Else
	cQry := "SELECT UJ3.UJ3_CGC"
	cQry += " FROM "+RetSqlName("UJ3")+" UJ3"
	cQry += " WHERE UJ3.D_E_L_E_T_	<> '*'" 
	
	cQry := ChangeQuery(cQry)
	//MemoWrite("c:\temp\QRYPERT.txt",cQry)
	TcQuery cQry NEW Alias "QRYPERT"
	
	While QRYPERT->(!EOF())
		AAdd(aCnpjs,QRYPERT->UJ3_CGC)
		QRYPERT->(DbSkip())
	EndDo
Endif

//R_E_C_N_O_
AAdd(aCab,"id")
AAdd(aLin,nRecnoTab)

If Select("QRYCPOS") > 0
	QRYCPOS->(DbCloseArea())
EndIf  

cQry2 := "SELECT U55.U55_CAMPO, U55.U55_JSON"
cQry2 += " FROM "+RetSqlName("U55")+" U55"
cQry2 += " WHERE U55.D_E_L_E_T_	<> '*'" 
cQry2 += " AND U55.U55_FILIAL 	= '"+xFilial("U55")+"'
cQry2 += " AND U55.U55_CODIGO 	= '"+cCod+"'

cQry2 := ChangeQuery(cQry2)

TcQuery cQry2 NEW Alias "QRYCPOS"

While QRYCPOS->(!EOF())

	AAdd(aCab,AllTrim(Lower(QRYCPOS->U55_JSON)))
	If GetSx3Cache(AllTrim(QRYCPOS->U55_CAMPO),"X3_TIPO") == "M" 
		AAdd(aLin,Encode64(&(AllTrim(cTab) + "->" + AllTrim(QRYCPOS->U55_CAMPO))))
	Else
		AAdd(aLin,&(AllTrim(cTab) + "->" + AllTrim(QRYCPOS->U55_CAMPO)))
	Endif	
	
	QRYCPOS->(DbSkip())
EndDo

If cTab == "SE1"
	
	cCliente := Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_CGC")
	
	If !Empty(SE1->E1_XCOBMOB)
		cVendedor := Posicione("SA3",1,xFilial("SA3")+SE1->E1_XCOBMOB,"A3_CGC")
	Endif
	
	AAdd(aCab,"cliente")
	AAdd(aLin,cCliente)
	AAdd(aCab,"vendedor")
	AAdd(aLin,cVendedor)
	AAdd(aCab,"datacob")
	AAdd(aLin,SE1->E1_XDTCOB)
	AAdd(aCab,"horacob")
	AAdd(aLin,SE1->E1_XHRCOB)
Endif

//cRet += ConfJSON({Lower(cDesc),aCab,{aLin}})
cRet += ConfJSONF({1,Lower(cDesc),aCab,{aLin},.T.,.F.,.F.})

For nI := 1 To Len(aCnpjs)

	aCab := {}
	aLin := {}
	
	AAdd(aCab,"cnpj")
	AAdd(aLin,aCnpjs[nI])

	If nI == 1 .Or. Len(aCnpjs) == 1 //Somente para o primeiro item ้ informada a descri็ใo
		cRet += ConfJSONF({2,"cnpjs",aCab,{aLin},Len(aCnpjs) > 0,/*.F.*/Len(aCnpjs) == 1,Len(aCnpjs) == 1})
	ElseIf nI > 1 .And. nI == Len(aCnpjs)
		cRet += ConfJSONF({3,"",aCab,{aLin},Len(aCnpjs) > 0,.T.,.T.})
	Else
		cRet += ConfJSONF({3,"",aCab,{aLin},Len(aCnpjs) > 0,.F.,.F.})
	Endif
	
Next nI


If !Empty(cDesc)
	cRet += CRLF + '}'
Endif

If Select("QRYPERT") > 0
	QRYPERT->(DbCloseArea())
EndIf  

If Select("QRYCPOS") > 0
	QRYCPOS->(DbCloseArea())
EndIf 

Return cRet

/**************************************/
Static Function MontaJSONF(aReg,aRegsF) 
/**************************************/

Local cRet 			:= ""

Local lContinua		:= .T.

Local cQry			:= ""
Local cQry2			:= ""

Local aCab 			:= {}
Local aLin 			:= {}

Local aCnpjs		:= {}
Local nI			:= 0
Local nJ			:= 0

DbSelectArea(aReg[2])
(aReg[2])->(DbGoTo(aReg[3]))

//Se nใo haverแ sincroniza็ใo de tabelas filhas, verifica necessidade de sincronizar o pai
If Len(aRegsF) == 0
	
	If (aReg[2])->&((IIF(SubStr(aReg[2],1,1) == "S",SubStr(aReg[2],2,2),aReg[2])+"_XINTCA")) == 'S' //Integrado/sincronizado
		lContinua := .F.
	Endif
	 
Endif

If lContinua

	//Associa os CNPJs vinculados ao registro
	If Select("QRYPERT") > 0
		QRYPERT->(DbCloseArea())
	EndIf  

	If !Empty((aReg[2])->&((IIF(SubStr(aReg[2],1,1) == "S",SubStr(aReg[2],2,2),aReg[2])+"_FILIAL")))
	
		cQry := "SELECT UJ3.UJ3_CGC"
		cQry += " FROM "+RetSqlName("UJ3")+" UJ3"
		cQry += " WHERE UJ3.D_E_L_E_T_	<> '*'" 
		cQry += " AND UJ3.UJ3_CODFIL 	LIKE '"+AllTrim((aReg[2])->&((IIF(SubStr(aReg[2],1,1) == "S",SubStr(aReg[2],2,2),aReg[2])+"_FILIAL")))+"%'"
		
		cQry := ChangeQuery(cQry)
		//MemoWrite("c:\temp\QRYPERT.txt",cQry)
		TcQuery cQry NEW Alias "QRYPERT"
		
		While QRYPERT->(!EOF())
			AAdd(aCnpjs,QRYPERT->UJ3_CGC)
			QRYPERT->(DbSkip())
		EndDo
	Else
		cQry := "SELECT UJ3.UJ3_CGC"
		cQry += " FROM "+RetSqlName("UJ3")+" UJ3"
		cQry += " WHERE UJ3.D_E_L_E_T_	<> '*'" 
		
		cQry := ChangeQuery(cQry)
		//MemoWrite("c:\temp\QRYPERT.txt",cQry)
		TcQuery cQry NEW Alias "QRYPERT"
		
		While QRYPERT->(!EOF())
			AAdd(aCnpjs,QRYPERT->UJ3_CGC)
			QRYPERT->(DbSkip())
		EndDo
	Endif
	
	//R_E_C_N_O_
	AAdd(aCab,"id")
	AAdd(aLin,aReg[3])

	//Sele็ใo dos campos a serem integrados (pai)
	If Select("QRYCPOS") > 0
		QRYCPOS->(DbCloseArea())
	EndIf  
	
	cQry := "SELECT U55.U55_CAMPO, U55.U55_JSON"
	cQry += " FROM "+RetSqlName("U55")+" U55"
	cQry += " WHERE U55.D_E_L_E_T_	<> '*'" 
	cQry += " AND U55.U55_FILIAL 	= '"+xFilial("U55")+"'
	cQry += " AND U55.U55_CODIGO 	= '"+aReg[1]+"'
	
	cQry := ChangeQuery(cQry)
	//MemoWrite("c:\temp\QRYCPOS.txt",cQry)
	TcQuery cQry NEW Alias "QRYCPOS"
	
	While QRYCPOS->(!EOF())
	
		AAdd(aCab,AllTrim(Lower(QRYCPOS->U55_JSON)))
		If GetSx3Cache(AllTrim(QRYCPOS->U55_CAMPO),"X3_TIPO") == "M" 
			AAdd(aLin,Encode64(&(AllTrim(aReg[2]) + "->" + AllTrim(QRYCPOS->U55_CAMPO))))
		Else
			AAdd(aLin,&(AllTrim(aReg[2]) + "->" + AllTrim(QRYCPOS->U55_CAMPO)))
		Endif	
		
		QRYCPOS->(DbSkip())
	EndDo

	cRet += ConfJSONF({1,Lower(aReg[4]),aCab,{aLin},Len(aRegsF) > 0,.T.,.F.})
	
	For nI := 1 To Len(aRegsF)

		aCab := {}
		aLin := {}
	
		DbSelectArea(aRegsF[nI][2])
		(aRegsF[nI][2])->(DbGoTo(aRegsF[nI][3]))

		//R_E_C_N_O_
		AAdd(aCab,"id")
		AAdd(aLin,aRegsF[nI][3])
	
		//Sele็ใo dos campos a serem integrados (pai)
		If Select("QRYCPOS") > 0
			QRYCPOS->(DbCloseArea())
		EndIf  
		
		cQry2 := "SELECT U58.U58_CAMPO, U58.U58_JSON"
		cQry2 += " FROM "+RetSqlName("U58")+" U58"
		cQry2 += " WHERE U58.D_E_L_E_T_	<> '*'" 
		cQry2 += " AND U58.U58_FILIAL 	= '"+xFilial("U58")+"'
		cQry2 += " AND U58.U58_CODIGO 	= '"+aReg[1]+"'
		cQry2 += " AND U58.U58_TABFIL 	= '"+aRegsF[nI][1]+"'
		
		cQry2 := ChangeQuery(cQry2)
		//MemoWrite("c:\temp\QRYCPOS.txt",cQry2)
		TcQuery cQry2 NEW Alias "QRYCPOS"
		
		While QRYCPOS->(!EOF())
		
			AAdd(aCab,AllTrim(Lower(QRYCPOS->U58_JSON)))
			AAdd(aLin,&(AllTrim(aRegsF[nI][2]) + "->" + AllTrim(QRYCPOS->U58_CAMPO)))
			
			QRYCPOS->(DbSkip())
		EndDo

		If nI == 1 .Or. Len(aRegsF) == 1 //Somente para o primeiro item ้ informada a descri็ใo
			cRet += ConfJSONF({2,Lower(aRegsF[nI][4]),aCab,{aLin},Len(aRegsF) > 0,.F.,.F.})
		ElseIf nI > 1 .And. nI == Len(aRegsF)
			cRet += ConfJSONF({3,"",aCab,{aLin},Len(aRegsF) > 0,.T.,.F.})
		Else
			cRet += ConfJSONF({3,"",aCab,{aLin},Len(aRegsF) > 0,.F.,.F.})
		Endif
	Next nI

	For nJ := 1 To Len(aCnpjs)
	
		aCab := {}
		aLin := {}
		
		AAdd(aCab,"cnpj")
		AAdd(aLin,aCnpjs[nJ])
	
		If nJ == 1 .Or. Len(aCnpjs) == 1 //Somente para o primeiro item ้ informada a descri็ใo
			cRet += ConfJSONF({2,"cnpjs",aCab,{aLin},Len(aCnpjs) > 0,/*.F.*/Len(aCnpjs) == 1,Len(aCnpjs) == 1})
		ElseIf nJ > 1 .And. nJ == Len(aCnpjs)
			cRet += ConfJSONF({3,"",aCab,{aLin},Len(aCnpjs) > 0,.T.,.T.})
		Else
			cRet += ConfJSONF({3,"",aCab,{aLin},Len(aCnpjs) > 0,.F.,.F.})
		Endif
	Next nJ

	If Select("QRYPERT") > 0
		QRYPERT->(DbCloseArea())
	EndIf  
	
	If Select("QRYCPOS") > 0
		QRYCPOS->(DbCloseArea())
	EndIf 
	
	If Select("QRYINF") > 0
		QRYINF->(DbCloseArea())
	EndIf
Endif  

Return cRet

/*********************************/
Static function ConfJSON(aGeraXML)
/*********************************/

Local nI,nJ 

Local cJSON  := ""                   

Local cTable := aGeraXML[1]                    
Local aCab   := aGeraXML[2]  
Local aLin   := aGeraXML[3]

If !Empty(cTable) 
	cJSON += '"'+cTable+'": [' 
Endif 
 
For nI := 1 To Len(aLin)
 
    cJSON += '{' + CRLF
 
    For nJ := 1 To Len(aCab) 
     
        If ValType(aLin[nI][nJ]) = "C"  
        	cConteudo := AllTrim(aLin[nI][nJ])
        ElseIf ValType(aLin[nI][nJ]) = "N"
            cConteudo := cValToChar(aLin[nI][nJ])
        ElseIf ValType(aLin[nI][nJ]) = "D"
            cConteudo := IIF(!Empty(aLin[nI][nJ]),DToC(aLin[nI][nJ]),"")
        ElseIf ValType(aLin[nI][nJ]) = "L"
            cConteudo := IIf(aLin[nI][nJ],"verdadeiro","falso") 
        Else
            cConteudo := AllTrim(aLin[nI][nJ])
        Endif               
 
        cJSON += '"'+aCab[nJ]+'":' + '"'+cConteudo+'"'
 
        If nJ < Len(aCab)
           cJSON += ',' + CRLF
        Endif
 
    Next nJ
    
   	cJSON += CRLF + '}'
    
    If nI < Len(aLin)
       cJSON += ','
    Endif         
Next nI
 
If !Empty(cTable)
	cJSON += ']'
Endif
 
Return cJSON

/**********************************/
Static function ConfJSONF(aGeraXML)
/**********************************/

Local nI,nJ 

Local cJSON  	:= ""                   

Local nTipo  	:= aGeraXML[1]                    
Local cTable 	:= aGeraXML[2]                    
Local aCab   	:= aGeraXML[3]  
Local aLin   	:= aGeraXML[4]
Local lFilhas	:= aGeraXML[5]
Local lUltIt	:= aGeraXML[6]
Local lFecha	:= aGeraXML[7]

If !Empty(cTable) 
	cJSON += '"'+cTable+'": [' 
Endif 
 
For nI := 1 To Len(aLin)
 
    cJSON += '{' + CRLF
 
    For nJ := 1 To Len(aCab) 
     
        If ValType(aLin[nI][nJ]) = "C"  
        	cConteudo := AllTrim(aLin[nI][nJ])
        ElseIf ValType(aLin[nI][nJ]) = "N"
            cConteudo := cValToChar(aLin[nI][nJ])
        ElseIf ValType(aLin[nI][nJ]) = "D"
            cConteudo := IIF(!Empty(aLin[nI][nJ]),DToC(aLin[nI][nJ]),"")
        ElseIf ValType(aLin[nI][nJ]) = "L"
            cConteudo := IIf(aLin[nI][nJ],"verdadeiro","falso") 
        Else
            cConteudo := AllTrim(aLin[nI][nJ])
        Endif               
 
        cJSON += '"'+aCab[nJ]+'":' + '"'+cConteudo+'"'
 
        If (nJ < Len(aCab)) .Or. (nTipo == 1 .And. lFilhas)
           cJSON += ',' + CRLF
        Endif
 
    Next nJ
    
    If (nTipo == 1 .And. !lFilhas) .Or. nTipo > 1 
    	cJSON += CRLF + '}'
    Endif
    
    If (nI < Len(aLin) .Or. (nTipo > 1 .And. !lUltIt))
       cJSON += ','
    Endif         
Next nI
 
If (!Empty(cTable) .And. lUltIt) .Or. (nTipo == 3 .And. lUltIt)
	
	cJSON += ']' + CRLF
    
    If !lFecha 
    	cJSON += ','
    EndIf
Endif

If lFecha 
	cJSON += '}'
Endif
 
Return cJSON

/********************************************/
Static Function PossuiCont(cCliente,cLojaCli)
/********************************************/

Local aArea			:= GetArea()
Local lRet			:= .F.
Local cQry			:= ""
Local cPulaLinha	:= chr(13)+chr(10)

// verifico se existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

cQry := " SELECT " 										+ cPulaLinha
cQry += " UF2.UF2_FILIAL AS FILIAL, " 					+ cPulaLinha
cQry += " UF2.UF2_CODIGO AS CONTRATO " 					+ cPulaLinha
cQry += " FROM " 										+ cPulaLinha
cQry += " " + RetSqlName("UF2") + " UF2 " 				+ cPulaLinha
cQry += " WHERE " 										+ cPulaLinha
cQry += " UF2.D_E_L_E_T_ <> '*' " 						+ cPulaLinha
cQry += " AND UF2.UF2_CLIENT = '" + cCliente + "' " 	+ cPulaLinha
cQry += " AND UF2.UF2_LOJA = '" + cLojaCli + "' " 		+ cPulaLinha
cQry += " UNION " 										+ cPulaLinha
cQry += " SELECT " 										+ cPulaLinha
cQry += " UF5.UF5_FILIAL AS FILIAL, " 					+ cPulaLinha
cQry += " UF5.UF5_CTRFUN AS CONTRATO " 					+ cPulaLinha
cQry += " FROM " 										+ cPulaLinha
cQry += " " + RetSqlName("UF5") + " UF5 " 				+ cPulaLinha
cQry += " WHERE " 										+ cPulaLinha
cQry += " UF5.D_E_L_E_T_ <> '*' " 						+ cPulaLinha
cQry += " AND UF5.UF5_CLIANT = '" + cCliente + "' "		+ cPulaLinha
cQry += " AND UF5.UF5_LOJANT = '" + cLojaCli + "' "		+ cPulaLinha	   

// fun็ใo que converte a query gen้rica para o protheus
cQry := ChangeQuery(cQry)

// crio o alias temporario
TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   

// se existir contratos da funerแria vinculados ao cliente
if QRY->(!Eof()) 
	lRet := .T.
endif

// fecho a แrea criada
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 

if !lRet

	// verifico se existe este alias criado
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf 
	
	cQry := " SELECT " 										+ cPulaLinha
	cQry += " U00.U00_FILIAL AS FILIAL, " 					+ cPulaLinha
	cQry += " U00.U00_CODIGO AS CONTRATO " 					+ cPulaLinha
	cQry += " FROM " 										+ cPulaLinha
	cQry += " " + RetSqlName("U00") + " U00 " 				+ cPulaLinha
	cQry += " WHERE " 										+ cPulaLinha
	cQry += " U00.D_E_L_E_T_ <> '*' " 						+ cPulaLinha
	cQry += " AND U00.U00_CLIENT = '" + cCliente + "' " 	+ cPulaLinha
	cQry += " AND U00.U00_LOJA = '" + cLojaCli + "' " 	+ cPulaLinha
	cQry += " UNION " 										+ cPulaLinha
	cQry += " SELECT " 										+ cPulaLinha
	cQry += " U19.U19_FILIAL AS FILIAL, " 					+ cPulaLinha
	cQry += " U19.U19_CONTRA AS CONTRATO "					+ cPulaLinha
	cQry += " FROM " 										+ cPulaLinha
	cQry += " " + RetSqlName("U19") + " U19 " 				+ cPulaLinha
	cQry += " WHERE " 										+ cPulaLinha
	cQry += " U19.D_E_L_E_T_ <> '*' " 						+ cPulaLinha
	cQry += " AND U19.U19_CLIANT = '" + cCliente + "' " 	+ cPulaLinha
	cQry += " AND U19.U19_LOJANT = '" + cLojaCli + "' "	+ cPulaLinha	   
	
	// fun็ใo que converte a query gen้rica para o protheus
	cQry := ChangeQuery(cQry)
	
	// crio o alias temporario
	TcQuery cQry New Alias "QRY" // Cria uma nova area com o resultado do query   
	
	// se existir contratos da funerแria vinculados ao cliente
	if QRY->(!Eof()) 
		lRet := .T.
	endif
	
	// fecho a แrea criada
	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf 

endif

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ JsonUF6 บ Autor ณ Leandro Rodrigues     บ Dataณ 03/05/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao para montar json do cadastro de Regra de Contrato	  บฑฑ
ฑฑบ		     ณ															  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Postumos	                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function JsonUJ6(cUrl)

Local lRet
Local cQry 			:= ""
Local cEmp			:= ""
Local cJson			:= ""
Local cChave		:= ""
Local cHeadRet		:= ""
Local cPostRet		:= ""
Local cChaveVirt	:= GetMv("MV_XKEYAPP")
Local aHeadOut		:= {}
Local aRecUJ6		:= {}
lOCAL aRecUJ7		:= {}
Local nTimeOut		:= 150
Local oOBJ			:= Nil
Local nX			:= 1

//chave de autenticacao de integracacao com o Virtus App
aadd(aHeadOut,"Content-Type:application/json")
aadd(aHeadOut,"Authorization: " + cChaveVirt)

//---------------------------------------------------------
//Busco Regras que ainda nao foram sincronizadas.
//---------------------------------------------------------
cQry := " SELECT"
cQry += " 	UJ6_CODIGO,"
cQry += " 	UJ6_REGRA,"
cQry += " 	R_E_C_N_O_ RECUJ6"
cQry += " FROM " + RETSQLNAME("UJ6") + " UJ6"
cQry += " WHERE UJ6.D_E_L_E_T_ = ' '"
cQry += " AND UJ6_FILIAL =  '"+ xFilial("UJ6") + "'"
cQry += " AND UJ6_XINTCA <> 'S'"
cQry += " AND UJ6_TPBENE <>'2'"


cQry += " ORDER BY UJ6_CODIGO,UJ6_REGRA"

cQry := ChangeQuery(cQry)

//Valido se tabela esta aberta
if Select("QUJ6") > 0
	QUJ6->(DbCloseArea())
endif

TcQuery cQry New Alias "QUJ6"

UJ7->(DbSetOrder(1))

While QUJ6->(!EOF())

	//Posiciono no registro da UJ6
	UJ6->(DbGoTo(QUJ6->RECUJ6))
	
	//Salvo recno do registro para confirmar integracao
	AADD(aRecUJ6,{UJ6->(RECNO()) })

	//---------------------------------------------------------
	//Inicio montagem json
	//---------------------------------------------------------

	If Empty(cJson)
		cJson := '{'												 + CRLF
		cJson += '"codigo": "' + UJ6->UJ6_CODIGO + '",'				 + CRLF
		cJson += '"regras_contrato"' + ': ['						 + CRLF
		
		//Inicializado a chave do primeiro registro
		cChave:= UJ6->UJ6_CODIGO
	endif

	//---------------------------------------------------------
	//Inclui as regas de contrato
	//---------------------------------------------------------

	cJson += ' {'													  + CRLF
	cJson += ' "id": "'			 + cValToChar(QUJ6->RECUJ6)		+ '",'+ CRLF	
	cJson += ' "regra": "' 	 	 + Alltrim(UJ6->UJ6_REGRA)		+ '",'+ CRLF
	cJson += ' "tiporegra": "'	 + Alltrim(UJ6->UJ6_TPREGR)		+ '",'+ CRLF
	cJson += ' "valorinicial": "'+ cValToChar(UJ6->UJ6_VLRINI)	+ '",'+ CRLF
	cJson += ' "valorfinal": "'  + cValToChar(UJ6->UJ6_VLRFIM)	+ '",'+ CRLF
	cJson += ' "valor": "'  	 + cValToChar(UJ6->UJ6_VLRCOB)	+ '",'+ CRLF
	cJson += ' "individual": "'  + UJ6->UJ6_INDIVI				+ '",'+ CRLF
	cJson += ' "regras": ['										

	//---------------------------------------------------------
	//Busco condicao da regra
	//---------------------------------------------------------

	if UJ7->(DbSeek(xFilial("UJ7")+UJ6->UJ6_CODIGO+UJ6->UJ6_REGRA))

		While UJ7->(!EOF()) ;
			.AND. UJ7->UJ7_FILIAL+UJ7->UJ7_CODIGO+UJ7->UJ7_REGRA == xFilial("UJ7")+UJ6->UJ6_CODIGO+UJ6->UJ6_REGRA
			
				//Salvo recno do registro para confirmar integracao
				AADD(aRecUJ7,{UJ7->(RECNO()) })

				//--------------------------------------------------------------
				//Add as condicoes de cada regra de contrato
				//--------------------------------------------------------------
				cJson += '{'														  + CRLF		
				cJson += ' "id":  "'			+ cValToChar(UJ7->(Recno())) 	+ '",'+ CRLF
				cJson += ' "item": "' 			+ Alltrim(UJ7->UJ7_ITEM)		+ '",'+ CRLF
				cJson += ' "tiporegra": "'		+ Alltrim(UJ7->UJ7_TPCOND)		+ '",'+ CRLF
				cJson += ' "valorinicial": "' 	+ cValToChar(UJ7->UJ7_VLRINI)	+ '",'+ CRLF
				cJson += ' "valorfinal": "'		+ cValToChar(UJ7->UJ7_VLRFIM)	+ '"' + CRLF
																			  
				UJ7->(DbSkip())

				//valido se tem mais itens para adicionar
				if UJ7->UJ7_FILIAL+UJ7->UJ7_CODIGO+UJ7->UJ7_REGRA == xFilial("UJ6")+UJ6->UJ6_CODIGO+UJ6->UJ6_REGRA
					cJson += '},'
				else
					cJson += '}'
				endif	
				

		EndDo
	endif


	QUJ6->(DbSkip())
	
	//fecho array das condicoes
	cJson += "]"+ CRLF 

	//---------------------------------------------------------
	//Valido se mudou a regra
	//---------------------------------------------------------

	if QUJ6->UJ6_CODIGO == cChave 

		//fecho chave da regra_contrato
		cJson += "},"+ CRLF  
	else
		//Fecha array de regra contrato
		cJson += ' }],'

		//-------------------------------------------------------
		//Valido empresas que deverao ser integradas
		//-------------------------------------------------------

		cEmp := " SELECT"
		cEmp += " 	UJ3_CGC"
		cEmp += " FROM "+RETSQLNAME("UJ3")+" UJ3"
		cEmp += " WHERE UJ3.D_E_L_E_T_	<> '*'" 

		if !Empty(UJ6->UJ6_FILIAL)
			cEmp += " AND UJ3.UJ3_CODFIL LIKE '" + UJ6->UJ6_FILIAL +"%'"
		endif

		cEmp := ChangeQuery(cEmp)
	
		//Valido se tabela esta aberta
		if Select("QUJ3") > 0
			QUJ3->(DbCloseArea())
		endif

		//inicia array de cnpj
		cJson += ' "cnpjs": ['

		TcQuery cEmp NEW Alias "QUJ3"
		
		While QUJ3->(!EOF())

			cJson += '{' + CRLF
			cJson += ' 	"cnpj": "' + QUJ3->UJ3_CGC + '"' + CRLF

			QUJ3->(DbSkip())

			if QUJ3->(!EOF())

				cJson += '},'+ CRLF
			else

				//finaliza array de cnpj
				cJson += '}]'+ CRLF
			endif

		EndDo

		cJson   += '}'
		cChave  := UJ6->UJ6_CODIGO
	
		
		cPostRet := HTTPSPost(Alltrim(Lower(cURL)),"","","","",cJSON,nTimeOut,aHeadOut,@cHeadRet)
	
		//---------------------------------------------------------
		//Inclui log da integra็ใo
		//---------------------------------------------------------
		if RecLock("U56",.T.)

			U56->U56_FILIAL := xFilial("U56")
			U56->U56_CODIGO	:= GetSX8Num("U56","U56_CODIGO")
			U56->U56_TABELA	:= "UJ6"
			U56->U56_RECNO	:= QUJ6->RECUJ6
			U56->U56_JSON	:= cJSON 
			U56->U56_RETORN	:= cPostRet 
			U56->U56_DATA	:= dDataBase
			U56->U56_HORA	:= Time()
			U56->U56_USER	:= cUserName

			U56->(MsUnlock())	 
		endif

		ConfirmSX8()
	
		//---------------------------------------------------------
		//limpo variavel json para novo registro
		//---------------------------------------------------------
		cJson:= ""

		//---------------------------------------------------------
		//Flag sincroniza็ใo do registro
		//---------------------------------------------------------

		If !Empty(cPostRet) .And. FWJsonDeserialize(cPostRet,@oObj)
	        			
			If Lower(oObj:code) == "200" // - Retorno ok

				//---------------------------------------------------------
				//Confirma UJ6 como integrado
				//---------------------------------------------------------
				For nX:= 1 to Len(aRecUJ6)
					
					//Posiciono no registro
					UJ6->(Dbgoto(aRecUJ6[nX,1]))

					if RecLock("UJ6",.F.)
						UJ6->UJ6_XINTCA  := "S"
						UJ6->(MsUnlock())
					endif
				Next nX

				//---------------------------------------------------------
				//Confirma UJ7 como integrado
				//---------------------------------------------------------
				For nX:= 1 to Len(aRecUJ7)
					
					//Posiciono no registro
					UJ7->(Dbgoto(aRecUJ7[nX,1]))

					if RecLock("UJ7",.F.)
						UJ7->UJ7_XINTCA  := "S"
						UJ7->(MsUnlock())
					endif
				Next nX
			Endif
		Endif
	endif

EndDo

Return 