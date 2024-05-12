#include 'protheus.ch'

/*/{Protheus.doc} M410STTS
Executado após todas as alterações no arquivo de pedidos terem sido feitas.
@author TOTVS
@since 21/07/2016
@version P11
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function M410STTS()
/***********************/

Local aArea := GetArea()

Local lFuneraria	:= SuperGetMV("MV_XFUNE",,.F.)
Local lCemiterio	:= SuperGetMV("MV_XCEMI",,.F.)

If lCemiterio

	If !Inclui .And. !Altera //Exclusão
	
		If !Empty(SC5->C5_XCTRFUN) //Deriva de Contrato Funerário
			
			DbSelectArea("UF4")
			UF4->(DbSetOrder(2)) //UF4_FILIAL+UF4_PEDIDO
			
			If UF4->(DbSeek(xFilial("UF4")+SC5->C5_NUM))
				
				RecLock("UF4",.F.)
				UF4->UF4_PEDIDO := Space(TamSX3("UF4_PEDIDO")[1])
				UF4->UF4_CLIENT := Space(TamSX3("UF4_CLIENT")[1])
				UF4->UF4_LOJA 	:= Space(TamSX3("UF4_LOJA")[1])
				UF4->(MsUnlock())
			Endif
		Endif
	Endif
Endif

RestArea(aArea)

Return