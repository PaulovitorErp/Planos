#include "totvs.ch"

/*/{Protheus.doc} RIMPM005
    
    Importacao do cadastro de vendedores - TSP

    @type  Function
    @author [tbc] g.sampaio
    @since 12/12/2018
    @version 1.0
    @param aVende, array, dados para importacao de vendedores
    @param nHdlLog, numeric, variavel para gravar o log
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

user Function RIMPM005( aVende, nHdlLog )

local aArea         := getArea()
local aAreaSA3      := SA3->( getArea() )
local aDadosVnd		:= {}
local aLinhaVnd     := {}
local lRet			:= .F.
local nX			:= 0
local nPosCodAnt	:= 0
local cCodAnt   	:= ""
local cErroExec		:= ""
local cPulaLinha	:= Chr(13) + Chr(10)
local cDirLogServer	:= ""
local cArqLog		:= "log_imp.log"
Local nJ            := 1

// variavel interna da rotina automatica
Private lMsErroAuto := .F. 
Private lMsHelpAuto := .F.

// valores do default dos parametros
default aVende  := {}
default nHdlLog := 0

//diretorio no server que sera salvo o retorno do execauto
cDirLogServer := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
cDirLogServer += If(Right(cDirLogServer, 1) <> "\", "\", "") 

SetFunName("MATA040")

for nX := 1 to len( aVende )
	
    BEGIN TRANSACTION

        SA3->( dbOrderNickame("XCODANT") ) //A3_FILIAL+A3_XCODANT
        
        aLinhaVnd	:= aClone(aVende[nX])
        
        nPosCodAnt := AScan(aLinhaVnd,{|x| AllTrim(x[1]) == "A3_XCODANT"})
        
        //importo apenas vendedor com codigo anterior
        if nPosCodAnt > 0 
        
            cCodAnt		:= Alltrim(aLinhaVnd[nPosCodAnt,2])
            
            if !Empty(cCodAnt)
            
                //verifico se o codigo anterior do vendedor ja possui no sistema 
                if !SA3->( DbSeek( xFilial("SA3") + cCodAnt) )
                    
                    DbSelectArea("SA3")
                    SA3->( dbOrderNickame("XCODANT") )//A3_FILIAL+A3_XCODANT				
                    
                    //monto array com os dados do vendedor
                    For nJ := 1 To Len(aLinhaVnd)
                
                        aAdd(aDadosVnd, {Alltrim(aLinhaVnd[nJ,1]),	aLinhaVnd[nJ,2],NIL})
                    
                    Next nJ
                    
                    //inclui o vendedor 
                    MSExecAuto({|x, y| MATA040(x, y)}, aDadosVnd, 3) //3- Inclusão, 4- Alteração, 5- Exclusão 
                    
                    If lMsErroAuto
                        
                        //verifico se arquivo de log existe 
                        if nHdlLog > 0 
                        
                            cErroExec := MostraErro(cDirLogServer + cArqLog )
                            
                            FErase(cDirLogServer + cArqLog )
                                
                            fWrite(nHdlLog , "Erro na Inclusao do Vendedor:" )
                            
                            fWrite(nHdlLog , cPulaLinha )
                        
                            fWrite(nHdlLog , cErroExec )
                        
                            fWrite(nHdlLog , cPulaLinha )
                        
                        endif
                                                            
                        SA3->(DisarmTransaction())
                        SA3->( RollBackSX8() )
                        
                    else
                        
                        //verifico se arquivo de log existe 
                        if nHdlLog > 0 
                        
                            fWrite(nHdlLog , "Vendedor Cadastrado com sucesso!" )
                        
                            fWrite(nHdlLog , cPulaLinha )
                        
                            fWrite(nHdlLog , "Codigo do Vendedor: " + Alltrim(SA3->A3_COD) )
                        
                            fWrite(nHdlLog , cPulaLinha )
                            
                            lRet := .T.
                            
                        endif
                        
                        SA3->( ConfirmSX8() )
                                
                    endif
                    
                else
                    
                    //verifico se arquivo de log existe 
                    if nHdlLog > 0 
                                
                        fWrite(nHdlLog , "Codigo Anterior: " + Alltrim(cCodAnt) + " já cadastrado na base de dados! " )
                        
                        fWrite(nHdlLog , cPulaLinha )
                    
                    endif
                    
                endif
            
            else
                
                fWrite(nHdlLog , "Vendedor sem Codigo Anterior preenchido, campo obrigatório para a importação!" )
                        
                fWrite(nHdlLog , cPulaLinha )
                
            endif
            
        else
            
            fWrite(nHdlLog , "Layout de importação não possui campo Codigo Anterior, a definição do mesmo é obrigatória!" )
                        
            fWrite(nHdlLog , cPulaLinha )
                                
        endif
        
    END TRANSACTION

next nX 

restArea( aAreaSA3 )
restArea( aArea )

return lRet