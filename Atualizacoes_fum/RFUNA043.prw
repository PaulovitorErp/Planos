#include "protheus.ch" 
#include "topconn.ch" 

/*/{Protheus.doc} RFUNA043
Realiza a inclusão do Locacao de equipamentos de Convalescencia
@author TOTVS
@since 04/06/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function RFUNA043()

Local lRet  := .T.

Do Case

	Case UF2->UF2_STATUS == "P" //Pré-cadastro
		MsgInfo("O Contrato se encontra pré-cadastrado, operação não permitida.","Atenção")
		Return

	Case UF2->UF2_STATUS == "C" //Cancelado
		MsgInfo("O Contrato se encontra Cancelado, operação não permitida.","Atenção")
		Return

	Case UF2->UF2_STATUS == "P" //Suspenso
		MsgInfo("O Contrato se encontra pré-cadastrado, operação não permitida.","Atenção")
		Return
			
EndCase

INCLUI := .T.
ALTERA := .F.

if !IsInCallStack("U_RIMPM008")

	//Valido se existe titulos vencidos para o contrato
	lRet := U_VlContra(UF2->UF2_CODIGO,"F",UF2->UF2_MSFIL)

	If lRet 

		FWExecView('INCLUIR',"RFUNA044",3,,{|| .T. })

	EndIf
Endif

Return lRet

/*/{Protheus.doc} RFUNA043
Funcao para validar se existe titulos em aberto
@author TOTVS
@since 04/06/2019
@version P12
@param Nao recebe parametros
@return nulo
/*/

User Function VlContra(cContrato,cCodModulo,cFilInc)

Local cQry          := ""
Local aArea			:= GetArea()
Local aAreaUF2		:= UF2->( GetArea() )
Local lOk           := .T.

//Consulta se contrato possui titulos vencidos
cQry := " SELECT COUNT(*) QTDVENC" 
cQry += " FROM " + RETSQLNAME("SE1") + " SE1"
cQry += " WHERE D_E_L_E_T_ = ' '"
cQry += " AND SE1.E1_SALDO > 0"
cQry += " AND SE1.E1_FILIAL    = '" + xFilial("SE1")  + "' " 

if cCodModulo == "F" // funerária

	cQry += " AND SE1.E1_XCTRFUN   = '" + cContrato       + "' "
else

	cQry += " AND SE1.E1_XCONTRA   = '" + cContrato       + "' "
endif

cQry += " AND SE1.E1_VENCREA   < '" + dTos(dDataBase) + "'"
cQry += " AND SE1.E1_TIPO NOT IN ('AB-','FB-','FC-','FU-' " 			
cQry += "  ,'PR','IR-','IN-','IS-','PI-','CF-','CS-','FE-' "				
cQry += " ,'IV-','RA','NCC','NDC') "	

cQry := ChangeQuery(cQry)

If Select("QSE1") > 1
    QSE1->(DbCloseArea())
Endif

TcQuery cQry New Alias "QSE1"

//Quantidade titulos vencidos
If QSE1->QTDVENC > 0

    MsgInfo("O Contrato possui titulos em atraso, operação não permitida.","Atenção")
    lOk := .F.
Endif

RestArea(aArea)
RestArea(aAreaUF2)

Return lOk