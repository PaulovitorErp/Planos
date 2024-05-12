#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} PCPGA021
Pontos de Entrada do Cadastro Controle de Locação de Salas
@author TOTVS
@since 28/10/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/

/***********************/
User Function PCPGA021()
/***********************/

Local aParam 		:= PARAMIXB
Local oObj			:= aParam[1]
Local cIdPonto		:= aParam[2]
Local oModelU25		:= oObj:GetModel("U25MASTER")

Local cCod			:= ""
Local dData			:= CToD("")
Local cSala			:= ""
Local cHrIni		:= ""
Local cHrFim		:= ""

Local xRet 			:= .T.

If cIdPonto == 'MODELPOS'

	If oObj:GetOperation() == 3 .Or. oObj:GetOperation() == 4 //Confirmação das operações de inclusão ou alteração

		cCod 	:= oModelU25:GetValue('U25_CODIGO') 
		dData 	:= oModelU25:GetValue('U25_DATA') 
		cSala 	:= oModelU25:GetValue('U25_SALA') 
		cHrIni 	:= oModelU25:GetValue('U25_HRINIC') 
		cHrFim	:= oModelU25:GetValue('U25_HRFIM')
		
		If ExistRes(cCod,dData,cSala,cHrIni,cHrFim)
			xRet := .F.
			Help( ,, 'Help - MODELPOS',, 'Já há 01 (uma) reserva de sala nesta data e intercedendo o horário desta reserva. Operação não permitida.', 1, 0 )
		Endif
	Endif
Endif

Return xRet

/*******************************************************/
Static Function ExistRes(cCod,dData,cSala,cHrIni,cHrFim)
/*******************************************************/

Local lRet 	:= .F.
Local cQry	:= ""

If Select("QRYU25") > 0
	QRYU25->(DbCloseArea())
Endif

cQry := "SELECT U25_CODIGO"
cQry += " FROM "+RetSqlName("U25")+""
cQry += " WHERE D_E_L_E_T_ 	<> '*'"
cQry += " AND U25_FILIAL 	= '"+xFilial("U25")+"'"
cQry += " AND U25_CODIGO	<> '"+cCod+"'"
cQry += " AND (U25_DATA = '"+DToS(dData)+"' OR U25_DATAF = '"+DToS(dData)+"')"
cQry += " AND U25_SALA 		= '"+cSala+"'"
cQry += " AND (
cQry += " (U25_HRINIC 	>= '"+cHrIni+"' AND U25_HRFIM <= '"+cHrFim+"') 
cQry += " OR (U25_HRINIC <= '"+cHrIni+"' AND U25_HRFIM >= '"+cHrFim+"')
cQry += " OR (U25_HRINIC <= '"+cHrIni+"' AND U25_HRFIM <= '"+cHrFim+"' AND U25_HRFIM >= '"+cHrIni+"')
cQry += " OR (U25_HRINIC >= '"+cHrIni+"' AND U25_HRFIM >= '"+cHrFim+"' AND U25_HRINIC <= '"+cHrFim+"')
cQry += " )"
cQry += " ORDER BY 1"

cQry := ChangeQuery(cQry)
TcQuery cQry NEW Alias "QRYU25"

If QRYU25->(!EOF())
	lRet := .T.
Endif

If Select("QRYU25") > 0
	QRYU25->(DbCloseArea())
Endif

Return lRet