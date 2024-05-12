/*/{Protheus.doc} MT120FIL
Filtro da FilBrowse do Pedido de Compras (MATA120)

@type function
@version 1.0  
@author TOTVS
@since 21/10/2022
/*/

User Function MT120FIL()

	Local cRet := ""

	If FwIsInCallStack("U_RFUNA002") .or. FwIsInCallStack("U_RFUNA034")

        If MsgYesNo("Deseja filtrar os pedidos de compras do apontamento de serviço posicionado?","Atenção")
            DbSelectArea("UJ2")
            UJ2->(DbSetOrder(1)) //UJ2_FILIAL+UJ2_CODIGO+UJ2_ITEM
            If UJ2->(DbSeek(xFilial("UJ2")+UJ0->UJ0_CODIGO))
                cRet := "("
                While UJ2->(!EOF()) .And. xFilial("UJ2") == UJ2->UJ2_FILIAL .And. UJ2->UJ2_CODIGO == UJ0->UJ0_CODIGO
                    If UJ2->UJ2_OK .And. !Empty(UJ2->UJ2_PEDCOM)
                        cRet := cRet + Iif(cRet=="(","",".or.") + " C7_NUM = '"+UJ2->UJ2_PEDCOM+"' "
                    EndIf
                    UJ2->(DbSkip())
                EndDo
                cRet += ")"
            EndIf
        EndIf
        
	EndIf

Return cRet
