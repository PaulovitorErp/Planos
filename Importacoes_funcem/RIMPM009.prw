#Include "protheus.CH"
#include "topconn.ch"  

/*/{Protheus.doc} RIMPM009
Rotina de Processamento de Importacoes 
de Itens Convalescente
@author Leandro Rodrigues
@since 23/09/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RIMPM009( aItensCon, nHdlLog, cCodigo )

Local cPulaLinha	:= Chr(13) + Chr(10)
Local cDirLogServer	:= ""
Local cArqLog		:= "log_imp.log"
Local cLogError     := ""
Local cDePara       := ""
Local cChapa        := ""
Local cLocal        := ""
Local cDesChapa     := ""
Local aDadosConv    := {}

Local nPosConv      := 0
Local nPosChapa     := 0

Local lRet          := .T.
Local nJ            := 1
Local nX            := 1

// variavel interna da rotina automatica
Private lMsErroAuto := .F. 
Private lMsHelpAuto := .F.

Default aItensCon := {}

//diretorio no server que sera salvo o retorno do execauto
cDirLogServer := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
cDirLogServer += If(Right(cDirLogServer, 1) <> "\", "\", "")

UJH->( dbSetOrder(1) )

For nX := 1 to len( aItensCon )  


    cLogError   := ""
    aLinhaCtr	:= aClone(aItensCon[nX])

    nPosConv    := AScan(aLinhaCtr,{|x| AllTrim(x[1]) == "COD_ANT"    })
    nPosChapa   := AScan(aLinhaCtr,{|x| AllTrim(x[1]) == "UJI_CHAPA"  })

    //Valido se foi localizado o codigo legado do contrato Convalescente
    if nPosConv > 0 .and. nPosChapa > 0
        
        cCodConv    := Alltrim(aLinhaCtr[nPosConv,2])
        cChapa      := Alltrim(aLinhaCtr[nPosChapa,2])

        //Valido se o contrato convalescente ja foi importado
        lRet := RetContConv(cCodConv,@cLogError)
         
        //Se nao foi localizado o contrato Convalescente
        If lRet
               
            //Chamo funcao para validar Chapa do bem
            lRet := ValidaChapa( cChapa, @cLogError )

             
            //Valido se chapa foi encontrada
            If lRet
               
                //Proximo Item
                nItem := MaxItem( UJH->UJH_CODIGO )

                //Adiciono os campos chaves da tabela para gravacao
                aAdd(aDadosConv, {"UJI_CODIGO", UJH->UJH_CODIGO                 }) 
                aAdd(aDadosConv, {"UJI_ITEM"  , StrZero(nItem,TamSx3("UJI_ITEM")[1]) })  
                aAdd(aDadosConv, {"UJI_CHAPA" , SN1->N1_CHAPA                   })  
                aAdd(aDadosConv, {"UJI_DESC"  , Alltrim(SN1->N1_DESCRIC)        })  
                aAdd(aDadosConv, {"UJI_LOCAL" , SN1->N1_LOCAL                   })  

                //monto array com os dados do Contrato Convalescente
                For nJ := 1 To Len(aLinhaCtr)

                     //Valido se existe De - Para no campo
                     cDePara := GetDePara(cCodigo,Alltrim(aLinhaCtr[nJ,1]),Alltrim(aLinhaCtr[nJ,2]))

                    aAdd(aDadosConv, {Alltrim(aLinhaCtr[nJ,1]),	iif(Empty(cDePara),aLinhaCtr[nJ,2],cDePara),NIL})

                Next nJ
    
                Begin Transaction 
                
                //Chama execauto da rotina de inclusao
                lRet := U_RFUNE039(,aDadosConv,4,@cLogError)
                
                //Se nao houve falha na gravacao 
                if !lRet

                    //verifico se arquivo de log existe 
                    if nHdlLog > 0 
                                        
                        fWrite(nHdlLog , cLogError )
                                
                        fWrite(nHdlLog , cPulaLinha )
                    
                    endif 

                    DisarmTransaction()
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

                End Transaction   
            else
                
                //verifico se arquivo de log existe 
                if nHdlLog > 0 
                                        
                    fWrite(nHdlLog , cLogError )
                            
                    fWrite(nHdlLog , cPulaLinha )
                    
                endif 

            endif
             
        else

            //verifico se arquivo de log existe 
            if nHdlLog > 0 
                                        
                fWrite(nHdlLog , cLogError )
                        
                fWrite(nHdlLog , cPulaLinha )
                    
            endif

        Endif
        
    else
        
        fWrite(nHdlLog , "Layout de importação não possui campo Codigo Anterior, a definição do mesmo é obrigatória!" )
                        
        fWrite(nHdlLog , cPulaLinha )    
    endif

Next nX


Return lRet

/*/{Protheus.doc} RIMPM009
Valido se foi importado o contrato convalescente
@author Leandro Rodrigues
@since 23/09/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/
Static Function RetContConv(cCodLeg,cLogError)

Local cQry  := ""
Local lRet  := .T.

cQry := " SELECT" 
cQry += "     UJH.R_E_C_N_O_ RECNOUJH"
cQry += " FROM "
cQry += " " + RETSQLNAME("UJH") + " UJH"
cQry += " WHERE D_E_L_E_T_ = ' '"
cQry += "   AND UJH_FILIAL = '" + xFilial("UJH")+ "'"
cQry += "   AND UJH_CODLEG = '" + cCodLeg       + "'"

cQry := ChangeQuery(cQry)

If Select("QUJH") > 0
    QUJH->(DbCloseArea())
Endif

TcQuery cQry New Alias "QUJH"

If QUJH->(!EOF())

    //Posiciono no Contrato Convalescente
    UJH->(DbGoTo( QUJH->RECNOUJH ))
else

    cLogError := "Contrato Convalescente referente ao codigo legado"+ cCodLeg + " nao foi localizado !"
    lRet := .F.
Endif

Return lRet

/*/{Protheus.doc} RIMPM009
Valido a chapa de identificacao do bem 
@author Leandro Rodrigues
@since 23/09/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

Static Function ValidaChapa( cChapa,cLogError )

Local cQry  := ""
Local lRet  := .T.

cQry := " SELECT" 
cQry += "   SN1.R_E_C_N_O_ RECNOSN1"
cQry += " FROM" 
cQry += "" + RETSQLNAME("SN1") + " SN1"
cQry += " WHERE SN1.D_E_L_E_T_ = ' '"
cQry += "   AND N1_FILIAL = '"+ xFilial("SN1")  + "'"
cQry += "   AND N1_CHAPA  = '"+ cChapa          + "'"

cQry := ChangeQuery(cQry)

If Select("QSN1") > 1
    QSN1->(DbCloseArea())
endif

TcQuery cQry New Alias "QSN1"

//Valido se encontrou chapa
if QSN1->(!EOF()) 

    //Posiciono no registro
    SN1->(DbGoTo(QSN1->RECNOSN1))

    //Valido se chapa esta vinculada a um produto
    if Empty(SN1->N1_PRODUTO)

        cLogError := "Chapa do bem informado nao possui produto vinculado !"
        lRet := .F.

    elseif !Empty(SN1->N1_BAIXA)
    
        cLogError := "Nao é possível fazer o controle em terceiros de um bem baixado"
        lRet := .F.

    elseif SN1->N1_TPCTRAT == '3'

        cLogError := "Equipamento selecionado chapa "+ cChapa + " se encontra locado para outro contrato"
        lRet := .F.
        
    endif
    
else
    
    cLogError := "Chapa do bem informado nao foi localizada no cadastro de Ativos !"
    lRet := .F.
endif

Return lRet

/*/{Protheus.doc} MaxItem
//Funcao para Max de itens 
@author TOTVS
@since 04/05/2019
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@type function
/*/
Static Function MaxItem(cCodigo)

Local cQMax := ""

cQMax := " SELECT MAX(UJI_ITEM) MAXITEM" 
cQMax += " FROM " + RETSQLNAME("UJI")
cQMax += " WHERE D_E_L_E_T_ = ' '"
cQMax += " AND UJI_FILIAL = '" + xFilial("UJI") + "'"
cQMax += " AND UJI_CODIGO = '" + cCodigo 		+ "'"

cQMax := ChangeQuery(cQMax)

If Select("QUJI") > 1
	QUJI->(DbCloseArea())
Endif

TcQuery cQMax New Alias "QUJI"


Return Val(Soma1(QUJI->MAXITEM))

/*/{Protheus.doc} RIMPM009
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
Endif

TcQuery cQryDp New Alias "QUI0"

If QUI0->(!EOF())
    cRetorno := QUI0->UI0_CONTPR
EndIf

Return cRetorno