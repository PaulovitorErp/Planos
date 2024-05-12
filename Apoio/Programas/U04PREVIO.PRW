#include "totvs.ch"
#include "topconn.ch"

/*/{Protheus.doc} U04PREVIO
Programa para corrigir enderecamento previo
duplicado
@type function
@version 1.0
@author raphaelgarcia
@since 30/06/2022
/*/
User Function U04PREVIO()

	Local lEnd		:= .F.
	Local oProcess	:= Nil

	oProcess := MsNewProcess():New( { | lEnd | ProcU04Previo( @lEnd, @oProcess ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
	oProcess:Activate()

Return(Nil)

/*/{Protheus.doc} ProcU04Previo
Funcao para deletar duplicados 
@type function
@version 1.0
@author raphaelgarcia
@since 6/30/2022
@param lEnd, logical, variavel de controle de cancelamento
@param oProcess, object, objeto do loading da rotina
/*/
Static Function ProcU04Previo(lEnd,oProcess)

Local cQuery    := ""
Local nProccess := 0

if Select("TRBU04") > 0
    TRBU04->(DBCloseArea())
endIf

cQuery := " SELECT "
cQuery += " U04_QUADRA QUADRA, "
cQuery += " U04_MODULO MODULO, "
cQuery += " U04_JAZIGO JAZIGO, "
cQuery += " MAX(R_E_C_N_O_) REG "
cQuery += " FROM " 
cQuery += RetSQLName("U04") + " U04A "
cQuery += " INNER JOIN " 
cQuery += " ( "
cQuery += " SELECT U04_QUADRA QUADRA, "
cQuery += " U04_MODULO MODULO, "
cQuery += " U04_JAZIGO JAZIGO, "
cQuery += " COUNT(*) TOTAL  "
cQuery += " FROM  "
cQuery += RetSQLName("U04") + " U04 "
cQuery += " WHERE  "
cQuery += " U04.D_E_L_E_T_ = ''  "
cQuery += " AND U04_PREVIO = 'S' "
cQuery += " GROUP BY U04_QUADRA,U04_MODULO,U04_JAZIGO "
cQuery += " HAVING COUNT(*) > 1 "
cQuery += " ) DUPLICADO "
cQuery += " ON U04A.D_E_L_E_T_ = '' "
cQuery += " AND U04A.U04_QUADRA = DUPLICADO.QUADRA "
cQuery += " AND U04A.U04_MODULO = DUPLICADO.MODULO "
cQuery += " AND U04A.U04_JAZIGO = DUPLICADO.JAZIGO "
cQuery += " GROUP BY U04_QUADRA,U04_MODULO,U04_JAZIGO "

TcQuery cQuery New Alias "TRBU04"

// atualizo o objeto de processamento
oProcess:IncRegua1('Reprocessando U02...')

// atualizo o objeto de processamentp
oProcess:SetRegua2(TRBU04->(Reccount()))

TRBU04->(DbGoTop())

While TRBU04->(!Eof())

    nProccess++

    // atualizo o objeto de processamento
    oProcess:IncRegua2("Deletando duplicado da quadra: " +  TRBU04->QUADRA + "-" + TRBU04->MODULO + "-" + TRBU04->JAZIGO  )

    U04->(DbGoto(TRBU04->REG))
    
    RecLock("U04", .F.)
    
    U04->(DBDelete()) 
    
    U04->(MsUnlock())

    TRBU04->(DbSkip())

EndDo


Return()

