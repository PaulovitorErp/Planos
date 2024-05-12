#include "totvs.ch"
#include "topconn.ch"   


/*/{Protheus.doc} RFUNE031
Funcao para retornar o numero da sorte disponivel
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 28/12/2018
@version P12
@param Nao recebe parametros
@return cRet, caracter, numero da sorte
/*/
User Function RFUNE031( cNumSor, cHist )

Local aArea		:= getArea()
Local cQuery 	:= ""
Local cNumBkp	:= ""
Local cRet 		:= ""
Local nStart	:= 0

Default cNumSor	:= ""
Default	cHist	:= ""

// verifico se o alias temporarios esta em uso
if select("TRBSOR") > 0
	TRBSOR->( dbCloseArea() )
endIf

// vou alimentando um historico, se houver
if !empty(alltrim(cNumSor))
	if empty(alltrim(cHist))
		cNumBkp := "'" + cNumSor + "'"
	else
		cNumBkp := cHist + ",'" + cNumSor + "'"
	endIf
endIf

// monto a query de consulta no banco de dados
cQuery := " SELECT TOP 1 UI1.UI1_NUMSOR NUMSOR		"
cQuery += " FROM " + retSqlName("UI1") + " UI1 		"
cQuery += " WHERE UI1.D_E_L_E_T_ = ' ' 				"
cQuery += " AND UI1.UI1_UTIL = '2'					" // pego os numeros da sorte nao utilizados

// verifico se tem o cNumSor
if !empty(alltrim(cNumBkp))
	cQuery += " AND UI1.UI1_NUMSOR NOT IN (" + cNumBkp + ")"
endIf

cQuery := ChangeQuery(cQuery)

tcQuery cQuery new alias "TRBSOR"

// verifico se o alias temporario tem dados
if TRBSOR->(!eof())
	cRet := TRBSOR->NUMSOR // preencho o retorno com os numeros da sorte disponiveis
else

	// mensagem de help para o usuario
	Help(,,'Help',,'Não existe range de números da sorte disponivel no momento, ';
	+ 'faça a importação do arquivo de números da sorte da Mongeral!',1,0)
	
endIf

// verifico se o cRet esta preenchido
if !empty( alltrim(cRet) )
	
	// liberos os registros reservados
	FreeUsedCode()

	// se ja estiver em uso eu pego um novo numero da sorte
	While !MayIUseCode("UI1"+xFilial("UI1")+cRet )
		cRet := U_RFUNE031(cRet, @cNumBkp)
	EndDo
	
endIf

if select("TRBSOR") > 0
	TRBSOR->( dbCloseArea() )
endIf

restArea( aArea )

Return(cRet)

/*/{Protheus.doc} RFUNE31A
Funcao para gravar na tabela UI1 - Range de Num da Sorte Mongeral o campo UI1_UTIL
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br.
@since 21/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RFUNE31A( cNumSorte, cContrato )

Local aArea			:= GetArea()
Local aAreaUI1		:= UI1->( GetArea() )
Local cQuery 		:= ""

Default cNumSorte 	:= ""
Default	cContrato	:= ""

// monto a query de consulta no banco de dados
cQuery := " SELECT 
cQuery += " UI1.R_E_C_N_O_ RECUI1 "
cQuery += " FROM " 
cQuery += RetSQLName("UI1") + " UI1 "
cQuery += " WHERE 
cQuery += " UI1.D_E_L_E_T_ = ' ' "
cQuery += " AND UI1.UI1_UTIL = '2' " // pego os numeros da sorte nao utilizados
cQuery += " AND UI1.UI1_CONTRA = ' ' "
cQuery += " AND UI1.UI1_NUMSOR = '" + cNumSorte + "'"

// verifico se o alias temporarios esta em uso
if select("QRUI1") > 0
	QRUI1->( DbCloseArea() )
endIf
	
TcQuery cQuery new alias "QRUI1"

if QRUI1->(!Eof())
	
	// posiciono no registro do número da sorte.
	UI1->( DbGoTo(QRUI1->RECUI1) )

	// gravo os dados na tabela UI1
	UI1->( Reclock("UI1",.F.) )
	
	UI1->UI1_UTIL 	:= "1"
	UI1->UI1_DTATIV	:= dDatabase
	UI1->UI1_CONTRA	:= cContrato
	
	UI1->( MsUnlock() )

endif
		
RestArea( aAreaUI1 )
RestArea( aArea )

Return()

/*/{Protheus.doc} RFUNE31B
Verifica se o plano de seguro tem sorteio cadastrado
@type function
@version 1.0
@author nata.queiroz
@since 23/04/2020
@param cPlnSeg, character, Plano de Seguro
@return lRet, logical
/*/
User Function RFUNE31B(cPlnSeg)
	Local lRet := .F.
	Local nVlSorte := 0
	Local aAreaUI2 := UI2->( GetArea() )

	Default cPlnSeg := ""

	UI2->( dbSetOrder(1) ) //-- UI2_FILIAL+UI2_CODIGO
	If UI2->( MsSeek(xFilial("UI2") + cPlnSeg) )
		nVlSorte := UI2->UI2_SORTE
		lRet := IIF(nVlSorte > 0, .T., .F.)
	EndIf

	RestArea(aAreaUI2)

Return lRet
