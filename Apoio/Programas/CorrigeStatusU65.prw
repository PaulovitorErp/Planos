#Include "totvs.ch"
#Include "TopConn.ch"
#INCLUDE "TbiConn.ch" 

/*/{Protheus.doc} 
Reprocessa Status de Titulos na U65
Consulta todas as U65 Duplicadas no Protheus 
e verifica status na Vindi para corrigir status no Protheus.
@author Raphael Martins 
@since 27/01/2020
@version P12
@param nulo
@return nulo
/*/
User Function CorrigeU65() 

FWMsgRun(,{|oSay| AjustaStatus(oSay)},'Aguarde...','Ajustando Status da U65...')

Return()

Static Function AjustaStatus(oSay)

Local cQry          := ""
Local cQryU65       := " "
Local cErro         := ""
Local cStatus       := ""
Local cCodRet       := ""
Local cDescRetorno  := ""
Local cDadosRetorno := ""
Local lConnect      := .T.
Local oVindi        := NIL

// crio o objeto de integracao com a vindi
oVindi := IntegraVindi():New()

if lConnect 

    cQry := "SELECT DISTINCT U65_FILIAL FILIAL, "
    cQry += "U65_CONTRA CONTRATO, "
    cQry += "U65_STATUS STATUS_FATURA "
    cQry += "FROM U65010 "
    cQry += "WHERE D_E_L_E_T_ <> '*' " 
    cQry += "AND U65_FILIAL = '010101' "
    cQry += "AND U65_STATUS = 'A' "
    cQry += "AND EXISTS(SELECT SUBSTRING(U62_CHAVE, 7, 6) "
    cQry += "            FROM U62010 "
    cQry += "            WHERE D_E_L_E_T_ <> '*' "
    cQry += "            AND U62_MSFIL = U65_FILIAL "
    cQry += "            AND U62_ENT = '1' "
    cQry += "            AND U62_OPER = 'E' "
    cQry += "            AND SUBSTRING(U62_CHAVE, 7, 6) = U65_CONTRA) "
    cQry += "GROUP BY U65_FILIAL,U65_CONTRA,U65_PREFIX,U65_NUM,U65_PARCEL,U65_TIPO,U65_STATUS "

    If Select("QU65") > 1
		QU65->(DbCloseArea())
	endif

	TcQuery cQry New Alias "QU65"

    While QU65->(!Eof())

        oSay:cCaption := ("Ajustando Contrato:  " + QU65->CONTRATO)
	    ProcessMessages()

        cQryU65 := " SELECT"
        cQryU65 += "	U65_CODVIN,"
        cQryU65 += "	U65_STATUS,"
        cQryU65 += "	R_E_C_N_O_ RECU65"
        cQryU65 += " FROM "+ RETSQLNAME("U65")
        cQryU65 += " WHERE D_E_L_E_T_ = ' '"
        cQryU65 += " AND U65_STATUS = 'A'"
        cQryU65 += " AND U65_FILIAL = '"+ QU65->FILIAL +"'"
        cQryU65 += " AND U65_CONTRA = '"+ QU65->CONTRATO +"'"
        
        If Select("QDUP") > 1
		    QDUP->(DbCloseArea())
    	endif

	    TcQuery cQryU65 New Alias "QDUP"

        While QDUP->(!Eof())
            
            U65->(DbGoto(QDUP->RECU65))

            cStatus         := ""
            cErro           := ""
            cDescRetorno    := ""
            cCodRet         := ""
            cDescRetorno    := ""
            cDadosRetorno   := ""

            //consulto status na Vindi
            cStatus := oVindi:ConsultaFatura("F",@cErro,U65->U65_CODVIN,@cCodRet,@cDescRetorno,@cDadosRetorno)

            //Valido fatura esta arquivada na VINDI e no protheus esta Ativo
            if cStatus == "canceled" .AND. U65->U65_STATUS == "A"

                //Atualizo status da Fatura no Protheus
                Reclock("U65",.F.)
        
                U65->U65_STATUS := "I"
                
                U65->(MsUnLock())
            
            Endif
        
            
            QDUP->(DbSkip() )
            
        EndDo

        QU65->(DbSkip())

    EndDo

endif


Return()
