#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} RIMPM007

    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
user Function RIMPM007( aBenCtr, nHdlLog )

local aArea         := getArea()
local aAreaUF4      := UF4->( getArea() )
local aDadosCtr		:= {}
local aLinhaCtr     := {}
local aCabCtr       := {}
local lRet			:= .F.
local nX			:= 0
local nPosCod   	:= 0
local nPosBen       := 0
local cCodCtr   	:= ""
local cNmBenef   	:= ""
local cErroExec		:= ""
local cPulaLinha	:= Chr(13) + Chr(10)
local cDirLogServer	:= ""
local cArqLog		:= "log_imp.log"
local nJ            := 1
Local lRFune002     := existblock("RFUNE002")

// variavel interna da rotina automatica
Private lMsErroAuto := .F. 
Private lMsHelpAuto := .F.

// valores do default dos parametros
default aBenCtr  := {}
default nHdlLog := 0

//diretorio no server que sera salvo o retorno do execauto
cDirLogServer := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
cDirLogServer += If(Right(cDirLogServer, 1) <> "\", "\", "")

for nX := 1 to len( aBenCtr )    

    UF4->( dbSetOrder(1) ) //UF4_FILIAL+UF4_CODIGO+UF4_ITEM                                                                                                                                  
        
    aLinhaCtr	:= aClone(aBenCtr[nX])
        
    // pego a posicoes do campo 
    nPosCod     := AScan(aLinhaCtr,{|x| AllTrim(x[1]) == "UF4_CODIGO"})
    nPosBen     := AScan(aLinhaCtr,{|x| AllTrim(x[1]) == "UF4_NOME"})
        
    //importo apenas vendedor com codigo anterior
    if nPosCod > 0 .and. nPosBen > 0

        // pego o codigo do contrato a ser importado
        cCodCtr	:= Alltrim(aLinhaCtr[nPosCod,2])

        // pego o item a ser importado
        cNmBenef := Alltrim(aLinhaCtr[nPosBen,2])
            
        if !Empty(cCodCtr) .and.!Empty(cNmBenef) 
            
            //verifico se o codigo anterior do vendedor ja possui no sistema 
            if !fValBen( cCodCtr, cNmBenef )
                    
                DbSelectArea("UF4")
                UF4->( dbSetOrder(1) ) //UF4_FILIAL+UF4_CODIGO+UF4_ITEM

                // para o codigo do item
                aAdd(aDadosCtr, {"UF4_ITEM",	fMaxItem( cCodCtr ) ,NIL})
                    
                //monto array com os dados do cliente
                For nJ := 1 To Len(aLinhaCtr)
                
                    aAdd(aDadosCtr, {Alltrim(aLinhaCtr[nJ,1]),	aLinhaCtr[nJ,2],NIL})
                    
                Next nJ
                
                UF2->( DbSetOrder(3) ) //UF4_FILIAL + UF4_CODANT

                If UF2->( DbSeek( xFilial("UF2") + PadL(Alltrim(cCodCtr),TamSX3("UF2_CODIGO")[1],"0") ) )  
	
	                aAdd(aCabCtr, {"UF2_CODIGO"	,UF2->UF2_CODIGO} )	//Codigo do Contrato

                    // verifico se a rotina de contratos esta compilada                                            
                    if lRFune002

                        // inclui os beneficiarios
                        U_RFUNE002(aCabCtr,aDadosCtr,,4)                    
                        
                        If lMsErroAuto
                                
                            //verifico se arquivo de log existe 
                            if nHdlLog > 0 
                                
                                cErroExec := MostraErro(cDirLogServer + cArqLog )
                                    
                                FErase(cDirLogServer + cArqLog )
                                        
                                fWrite(nHdlLog , "Erro na Inclusao do Beneficiário no Contrato:" )
                                    
                                fWrite(nHdlLog , cPulaLinha )
                                
                                fWrite(nHdlLog , cErroExec )
                                
                                fWrite(nHdlLog , cPulaLinha )
                                
                            endif
                                                                    
                            UF4->(DisarmTransaction())
                                
                        else
                                
                            //verifico se arquivo de log existe 
                            if nHdlLog > 0 
                                
                                fWrite(nHdlLog , "Beneficiario Cadastrado com sucesso no Contrato!" )
                                
                                fWrite(nHdlLog , cPulaLinha )
                                
                                fWrite(nHdlLog , "Contrato do Beneficiario: " + Alltrim(UF4->UF4_CODIGO) + " - Nome : " + alltrim(UF4->UF4_NOME) )
                                
                                fWrite(nHdlLog , cPulaLinha )
                                    
                                lRet := .T.
                                    
                            endif
                                        
                        endif
                    endif                    
                else
                        
                    //verifico se arquivo de log existe 
                    if nHdlLog > 0 
                                    
                        fWrite(nHdlLog , "Nome do Beneficario: " + Alltrim(cNmBenef) + " já cadastrado na base de dados! " )
                            
                        fWrite(nHdlLog , cPulaLinha )
                        
                    endif
                        
                endif
            endIf
        else
                
            fWrite(nHdlLog , "Vendedor sem Codigo Anterior preenchido, campo obrigatório para a importação!" )
                        
            fWrite(nHdlLog , cPulaLinha )
                
        endif
            
    else
            
        fWrite(nHdlLog , "Layout de importação não possui campo Codigo Anterior, a definição do mesmo é obrigatória!" )
                        
        fWrite(nHdlLog , cPulaLinha )
                                
    endif

next nX 

restArea( aAreaSA3 )
restArea( aArea )

return lRet

/*/{Protheus.doc} fValBen
    
    valido se o nome do beneficiario esta presente no contrato

    @type  Static Function
    @author [tbc] g.sampaio
    @since 13/12/2018
    @version 1.0
    @param cCodCtr, caracter, codigo do contrato do beneficiario
    @param cNmBenef, caracter, nome do beneficiario
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fValBen( cCodCtr, cNmBenef )

local aArea         := getArea()
local lRet          := .T.
local cQuery        := ""

default cCodCtr     := ""
default cNmBenef    := ""

if select("TRBUF4") > 0
    TRBUF4->( dbCloseArea() )
endIf

// monto a query
cQuery := " SELECT UF4.UF4_CODIGO FROM " + retSqlName("UF4") + " UF4    "
cQuery += " WHERE UF4.D_E_L_E_T_ = ' '                                  "
cQuery += " AND UF4.UF4_CODIGO = '" + alltrim(cCodCtr) +"'              "
cQuery += " AND UF4.UF4_NOME = '" + alltrim(cNmBenef) + "'              "
cQuery += " ORDER BY UF4.UF4_CODIGO, UF4_NOME                           "

cQuery  := changeQuery( cQuery )

tcQuery cQuery new alias "TRBUF4"

// verifico se existe registro
if TRBUF4->( !eof() )    
    lRet := .F.
endIf

TRBUF4->( dbCloseArea() )

restArea( aArea )

return lRet

/*/{Protheus.doc} fMaxItem
    
    retorna o codigo do item

    @type  Static Function
    @author [tbc] g.sampaio
    @since 13/12/2018
    @version 1.0
    @param cCodCtr, caracter, codigo do contrato do beneficiario
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fMaxItem( cCodCtr )

local aArea         := getArea()
local cRet          := ""
local cQuery        := ""

default cCodCtr     := ""

if select("TRBUF4") > 0
    TRBUF4->( dbCloseArea() )
endIf

// monto a query
cQuery := " SELECT MAX( UF4.UF4_ITEM ) MAXITEM FROM " + retSqlName("UF4") + " UF4    "
cQuery += " WHERE UF4.D_E_L_E_T_ = ' '                                  "
cQuery += " AND UF4.UF4_CODIGO = '" + alltrim(cCodCtr) +"'              "

cQuery  := changeQuery( cQuery )

tcQuery cQuery new alias "TRBUF4"

// verifico se existe registro
if TRBUF4->( !eof() )    
    cRet := soma1( TRBUF4->MAXITEM )
endIf

TRBUF4->( dbCloseArea() )

restArea( aArea )

return cRet