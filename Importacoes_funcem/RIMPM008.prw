#Include "protheus.CH"
#include "topconn.ch"  

/*/{Protheus.doc} RIMPM008
Rotina de Processamento de Importacoes 
de Convalescente
@author Leandro Rodrigues
@since 23/09/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RIMPM008( aConval, nHdlLog, cCodigo )

Local cPulaLinha	:= Chr(13) + Chr(10)
Local cDirLogServer	:= ""
Local cArqLog		:= "log_imp.log"
Local cLogError     := ""
Local cDePara       := ""
Local nPosCod       := 0
Local nPosCtt       := 0
Local nPosIdBen     := 0
Local aDadosConv    := {}
Local nJ            := 1
Local nX            := 1

// variavel interna da rotina automatica
Private lMsErroAuto := .F. 
Private lMsHelpAuto := .F.

Default aConval := {}

//diretorio no server que sera salvo o retorno do execauto
cDirLogServer := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
cDirLogServer += If(Right(cDirLogServer, 1) <> "\", "\", "")

UJH->( dbSetOrder(1) )

For nX := 1 to len( aConval )  

    cLogError   := ""
    aLinhaCtr	:= aClone(aConval[nX])

    nPosCtt     := AScan(aLinhaCtr,{|x| AllTrim(x[1]) == "COD_ANT"    })
    nPosCod     := AScan(aLinhaCtr,{|x| AllTrim(x[1]) == "UJH_CODLEG" })
    nPosIdBen   := AScan(aLinhaCtr,{|x| AllTrim(x[1]) == "BEN_ANT"    })
    
    //importo convalescente com codigo contrato funerario e contrato convalescente
    if nPosCtt > 0 .and. nPosCod > 0 .and. nPosIdBen > 0 

        // pego o codigo do contrato a ser importado
        cCodCtr	        := Alltrim(aLinhaCtr[nPosCtt,2])
        cBeneficiario   := Alltrim(aLinhaCtr[nPosIdBen,2])
        cCodLeg         := Alltrim(aLinhaCtr[nPosCod,2])

        //Valida e existe beneficiario para contrato
        lRet :=  ValidaBenef(cCodCtr,cBeneficiario,@cLogError,cCodLeg)

        //Valido se existo contrato e beneficiario
        If lRet            

            //Adiciono os campos chaves da tabela para gravacao
            aAdd(aDadosConv, {"UJH_CONTRA", UF2->UF2_CODIGO          })        
            aAdd(aDadosConv, {"UJH_CODBEN", UF4->UF4_ITEM            })        
            aAdd(aDadosConv, {"UJH_NOMBEN", Alltrim(UF4->UF4_NOME)   })        
            aAdd(aDadosConv, {"UJH_PLANO" , UF2->UF2_PLANO           })        
            aAdd(aDadosConv, {"UJH_CAREN" , iif(UF2->UF2_CARENC <= dDataBase,"S","N")})        
            aAdd(aDadosConv, {"UJH_STATUS", "L"                      })        
                
            //monto array com os dados do Contrato Convalescente
            For nJ := 1 To Len(aLinhaCtr)

                //Valido se existe De - Para no campo
                cDePara := GetDePara(cCodigo,Alltrim(aLinhaCtr[nJ,1]),Alltrim(aLinhaCtr[nJ,2]))

                aAdd(aDadosConv, {Alltrim(aLinhaCtr[nJ,1]),	iif(Empty(cDePara),aLinhaCtr[nJ,2],cDePara),NIL})
                                                
            Next nJ

            //Chama execauto da rotina de inclusao
            lRet := U_RFUNE039(aDadosConv,,3)
            
            //Se nao houve falha na gravacao 
            if !lRet

                //verifico se arquivo de log existe 
                if nHdlLog > 0 
                                        
                    fWrite(nHdlLog , cLogError )
                                
                    fWrite(nHdlLog , cPulaLinha )
                   
                endif 
            Endif

            If lMsErroAuto

                //verifico se arquivo de log existe 
                if nHdlLog > 0 
                    
                    cErroExec := MostraErro(cDirLogServer + cArqLog )
                                        
                    FErase(cDirLogServer + cArqLog )
                                            
                    fWrite(nHdlLog , "Erro na Inclusao do Contrato Convalescente:" )
                        
                    fWrite(nHdlLog , cPulaLinha )
                    
                    fWrite(nHdlLog , cErroExec  )
                    
                    fWrite(nHdlLog , cPulaLinha )

                endif

            endif
        else
            
            //verifico se arquivo de log existe 
            if nHdlLog > 0 
                                        
                fWrite(nHdlLog , cLogError)
                        
                fWrite(nHdlLog , cPulaLinha )
                    
            endif
        endif
    else
        
        fWrite(nHdlLog , "Layout de importação não possui campo Codigo Anterior, a definição do mesmo é obrigatória!" )
                        
        fWrite(nHdlLog , cPulaLinha )

    endif

Next nX 

Return lRet

/*/{Protheus.doc} RIMPM008
Funcao validar se existe o beneficiario no contrato informado
@author Leandro Rodrigues
@since 23/09/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

Static Function ValidaBenef(cCodAntCtt,cCodAntBen,cLogError,cCodLeg)

Local cQry := ""
Local cImp := ""
Local lRet := .T.

cQry := " SELECT"
cQry += "   UF2_CODIGO,"
cQry += "   UF2.R_E_C_N_O_ RECNOUF2,"
cQry += "   UF4_ITEM,"
cQry += "   UF4.R_E_C_N_O_ RECNOUF4"
cQry += " FROM " + RETSQLNAME("UF2") + " UF2"
cQry += " LEFT JOIN " + RETSQLNAME("UF4") + " UF4"
cQry += " ON UF4_FILIAL     = UF2_FILIAL" 
cQry += "   AND UF4_CODIGO  = UF2_CODIGO"
cQry += "   AND UF4_BENLEG     = '" + cCodAntBen + "'"
cQry += "   AND UF4.D_E_L_E_T_ = ' '"
cQry += " WHERE UF2.D_E_L_E_T_ = ' '"
cQry += "   AND UF2_FILIAL = '" + xFilial("UF2") + "'"
cQry += "   AND UF2_CODANT = '" + cCodAntCtt     + "'"

cQry := ChangeQuery(cQry)

If Select("QUF2") > 1
    QUF2->(DbCloseArea())
EndIf

TcQuery cQry New Alias "QUF2"

If QUF2->(!EOF())

    If Empty(QUF2->UF2_CODIGO)
        
        cLogError :=  "Contrato: " + Alltrim(cCodAntCtt) + " nao foi encontrato! "
        lRet := .F.

    Elseif Empty(QUF2->UF4_ITEM)

        cLogError :=  "Beneficiario: " + Alltrim(cCodAntBen) + " nao foi encontrato no contrato "+QUF2->UF2_CODIGO + "! "
        lRet := .F.        
    
    Endif 
    
else

    cLogError :=  "Contrato: " + Alltrim(cCodAntCtt) + " nao foi encontrato! "
    lRet := .F.
Endif

If lRet

    //posiciona no contrato
    UF2->(DbGoTo(QUF2->RECNOUF2))

    //posiciona no beneficiario
    UF4->(DbGoTo(QUF2->RECNOUF4))

    //Valido se contrato ja foi importado
    cImp := " SELECT "
    cImp += "   UJH_CODIGO"
    cImp += " FROM " 
    cImp += " " + RETSQLNAME("UJH") + " UJH"
    cImp += " WHERE UJH.D_E_L_E_T_ = ' '"
    cImp += " AND UJH_CODLEG = '" +cCodLeg + "'"

    cImp := ChangeQuery(cImp)

    If Select("QUJH") > 1
        QUJH->(DbCloseArea())
    EndIf

    TcQuery cImp New Alias "QUJH"

    if QUJH->(!EOF())
        cLogError :=  "Contrato Convalescente codigo Legado " + Alltrim(cCodLeg) + " ja foi importado "
        lRet := .F.
    endif
Endif

Return lRet

/*/{Protheus.doc} RIMPM008
Funcao que verifica se existe De-Para no campo
@author Leandro Rodrigues
@since 23/09/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function GetDePara(cCodigo,cCampo,cConteudo)

Local cQryDp    := ""
Local cRetorno  := ""

cQryDp := " SELECT" 
cQryDp += "     UI0_CONTPR"
cQryDp += " FROM" 
cQryDp += " " + RETSQLNAME("UI0") + " UI0"
cQryDp += " WHERE UI0.D_E_L_E_T_ = ' '"
cQryDp += "     AND UI0_FILIAL = '"+ xFilial("UI0") + "'"
cQryDp += "     AND UI0_CODIGO = '"+ cCodigo        + "'"
cQryDp += "     AND UI0_CAMPO  = '"+ cCampo         + "'"
cQryDp += "     AND UI0_CONTLE LIKE '%"+ cConteudo  + "%'"

cQryDp := ChangeQuery(cQryDp)

If Select("QUI0")>1
    QUI0->(DbCloseArea())
endif 

TcQuery cQryDp New Alias "QUI0"

If QUI0->(!EOF())
    cRetorno := Alltrim(QUI0->UI0_CONTPR)
endif

Return cRetorno