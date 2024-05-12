#INCLUDE 'PROTHEUS.CH'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} PFUNA044
//TODO Ponto de entrada da rotina de Convalescencia
@author Leandro Rodrigues
@since 31/05/2019
@version 1.0
@return 
@type function
/*/

User Function PFUNA044()

Local aArea			:= GetArea()
Local aAreaUJH		:= UJH->(GetArea())
Local aParam 		:= PARAMIXB
Local oObj			:= aParam[1]
Local cIdPonto		:= aParam[2]
Local cIdModel		:= IIf( oObj<> NIL, oObj:GetId(), aParam[3] )
Local cClasse		:= IIf( oObj<> NIL, oObj:ClassName(), '' )
Local oModelUJH		:= oObj:GetModel('UJHMASTER')
Local oModelUJI		:= oObj:GetModel('UJIDETAIL')
Local cQry          := ""
Local lRet 			:= .T.
Local oVindi        := Nil
Local cPulaLinha	:= chr(13)+chr(10) 
Local cErroVindi    := ""

if cIdPonto == "MODELVLDACTIVE" // ponto de entrada na abertura da tela

	// se a operação for de exclusão
	//Valida se ja foi retornado ou tem titulos gerados
	if oObj:GetOperation() == 5 .OR. (oObj:GetOperation() == 4 .AND. !IsInCallStack("U_RetornoRemessa") .And. !IsInCallStack("U_RFUNE039"))

        //Valido se tem retorno parcial ou total
        if UJH->UJH_STATUS == "P" .OR. UJH->UJH_STATUS == "D" 
            
            Help( ,, 'Atencao',, "Solicitacao nao e permitida para equipamentos que ja foram retornados.", 1, 0 )
			lRet := .F.

        else

            //Valido se tem titulos gerados
            cQry := " SELECT " 														+ cPulaLinha
            cQry += " 	COUNT(E1_NUM) QTDTITULOS"									+ cPulaLinha
            cQry += " FROM " 														+ cPulaLinha
            cQry += " " + RetSqlName("SE1") + " SE1 "								+ cPulaLinha
            cQry += " WHERE " 														+ cPulaLinha
            cQry += " SE1.D_E_L_E_T_	 <> '*' " 									+ cPulaLinha
            cQry += " AND SE1.E1_SALDO 	 > 0"										+ cPulaLinha
            cQry += " AND SE1.E1_FILIAL  = '" + xFilial("SE1")  + "' " 				+ cPulaLinha
            cQry += " AND SE1.E1_XCONCTR = '" + UJH->UJH_CODIGO + "' "    		    + cPulaLinha
            cQry += " AND SE1.E1_TIPO NOT IN ('AB-','FB-','FC-','FU-' " 			+ cPulaLinha
            cQry += " ,'PR','IR-','IN-','IS-','PI-','CF-','CS-','FE-' "				+ cPulaLinha
            cQry += " ,'IV-','RA','NCC','NDC') "									+ cPulaLinha

            cQry := ChangeQuery(cQry)

            If Select("QSE1") >1
                QSE1->(DbCloseArea())
            Endif

            TcQuery cQry New Alias "QSE1"

            //Valido se query retornou registros
            If QSE1->QTDTITULOS > 0
                
                Help( ,, 'Atencao',, "Alteração so é permitido para locação que ainda nao foi ativada!.", 1, 0 )
			    lRet := .F.

            Endif
		endif
	
	endif

//Na confirmacao da inclusao ou alteracao
ElseIf cIdPonto == 'MODELPOS' .And. oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4 

    U60->(DbSetOrder(2))
    U61->(DbSetOrder(1))
    U64->(DbSetOrder(2))
    UF2->(DbSetOrder(1))
    
    //Se nao for retorno ou troca
    If !IsInCallStack("U_RetornoRemessa") 

        //Posiciono no contrato funerario
        If UF2->(DbSeek(xFilial("UF2")+FwFldGet("UJH_CONTRA")))
            
            //Valido se a forma de pagamento d2o convalescente é Recorrencia
            If U60->(DbSeek(xFilial("U60")+FwFldGet("UJH_FORPG")))
                
                oVindi := IntegraVindi():New()

                //validop se nao existe perfil de pagamento cadastrado para o cliente
                If  !U64->(DbSeek(xFilial("U64")+UF2->UF2_CODIGO+UF2->UF2_CLIENT+UF2->UF2_LOJA+"A"))
        
                    // tela para preenchimento do perfil de pagamento
                    FWMsgRun(,{|oSay| lRet := IncPerfil()},'Aguarde...','Abrindo Perfil de Pagamento...')
                    
                endif

            endif
        Endif
    endif
ElseIf cIdPonto == 'MODELCOMMITNTTS' //Após a gravação dos dados

	If oObj:GetOperation() == 3 
		
        if !IsInCallStack("U_RIMPM008")

            //Geracao de PV contra cliente
            If MsgYesNo("Deseja Ativar o contrato Convalescencia?") 
            
                U_GerarRemessa()  
            
            endif
        endif
    endif
	
EndIf

RestArea(aAreaUJH)
RestArea(aArea)

Return(lRet)


/*###########################################################################
#############################################################################
## Programa  | IncPerfil |Autor| Wellington Gonçalves 	|Data|  25/01/2019 ##
##=========================================================================##
## Desc.     | Abertura de cadastro MVC de Perfil de Pagamento			   ##
##=========================================================================##
## Uso       | Póstumos		                                               ##
#############################################################################
###########################################################################*/

Static Function IncPerfil()

	Local lRet := .T.

	nInc := FWExecView('INCLUIR','UVIND07',3,,{|| .T. })

	if nInc <> 0
		MsgInfo("A Inclusão do Perfil de Pagamento não foi realizada. Não será possível ativar o contrato!","Atenção!")
		lRet := .F.
	endif

Return(lRet)