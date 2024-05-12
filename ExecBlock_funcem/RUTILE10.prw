#include "protheus.ch" 

/*/{Protheus.doc} RUTILE10
Altera flag de sincronização de dados
@author TOTVS
@since 13/09/2018
@version P12
@param Nao recebe parametros            
@return nulo
/*/

/***********************************************************/
User Function RUTILE10(cOper,cTab,nRecnoTab,lCadastro,cPath)
/***********************************************************/

Local lRet			:= .T.
Local cCpo 			:= ""

Local cHost			:= SuperGetMv("MV_XENHOST",.F.,"virtus-homolg.herokuapp.com")
Local oRestClient

Default cPath		:= ""

If cOper <> "E" //Operação diferente de exclusão
	
	cCpo := IIF(SubStr(cTab,1,1) == "S",SubStr(cTab,2,2),cTab)+"_XINTCA"

	If (cTab)->(FieldPos(cCpo)) > 0 //Existe o campo de flag

		If !lCadastro

			DbSelectArea(cTab)
			(cTab)->(DbGoTo(nRecnoTab))
		
			//Atualiza o registro para haver sincronização
			RecLock(cTab,.F.)
			&(cTab + "->" + cCpo) := Space(1)
			(cTab)->(MsUnlock())
		Else
			//Atualiza o registro para haver sincronização
			&("M->" + cCpo) := Space(1)
		Endif
	Endif
Else

	oRestClient := FWRest():New(cHost)
	oRestClient:setPath("/"+cPath+"/" + cValToChar(nRecnoTab))
	
	If oRestClient:Delete()
		            	
        //Inclui log da integração
		RecLock("U56",.T.)
		U56->U56_FILIAL := xFilial("U56")
		U56->U56_CODIGO	:= GetSX8Num("U56","U56_CODIGO")
		U56->U56_TABELA	:= cTab
		U56->U56_RECNO	:= nRecnoTab
		U56->U56_JSON	:= "DELETE" 
		U56->U56_RETORN	:= oRestClient:GetResult() 
		U56->U56_DATA	:= dDataBase
		U56->U56_HORA	:= Time()
		U56->U56_USER	:= cUserName
		U56->(MsUnlock())	 
		
		ConfirmSX8()
	Endif
Endif

Return lRet