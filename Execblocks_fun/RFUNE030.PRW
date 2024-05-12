#include 'totvs.ch'
#include 'topconn.ch'

#define CRLF chr(13)+chr(10)

/*/{Protheus.doc} RFUNE030
Funcao para inclusao de dados na tabela UI1
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 21/12/2018
@version P12
@param Nao recebe parametros
@return nulo
/*/
user function RFUNE030( aDados, nHdlLog )
local lRet		:= .T.

default aDados	:= {}
default nHdlLog := 0

// verifico se a tabela de ranges de numero da sorte existe
if !msFile("UI1") 

	// verifico se existem dados para serem importados
	if len( aDados ) > 0

		dbSelectArea("UI1")

		// verifico se ja existe o numero da sorte
		If !fValida( aDados[2], aDados[3] )
													
			BEGIN TRANSACTION
						
				If UI1->(Reclock("UI1",.T.))

					UI1->UI1_FILIAL 	:= xFilial("UI1")
					UI1->UI1_PARCEI		:= allTrim( aDados[1] ) 
					UI1->UI1_NUMPRO		:= allTrim( aDados[2] ) 
					UI1->UI1_NUMSOR		:= allTrim( aDados[3] )
					UI1->UI1_CTRINT		:= allTrim( aDados[4] )
					UI1->UI1_EMPRES		:= allTrim( aDados[5] )
					UI1->UI1_UTIL		:= "2"	// o registro vai ser sempre gravado como nao utilizado

					UI1->(MsUnlock())
								
				Else
					UI1->( DisarmTransaction() )
				EndIf
							
			END TRANSACTION
		else

          	//verifico se arquivo de log existe 
			if nHdlLog > 0
				fWrite(nHdlLog ,  "Numero da sorte ja existente no sistema, numero da sorte : " + aDados[3] )
				fWrite(nHdlLog , CRLF )
			EndIf

			lRet := .F.
		endIf
	else'
		//verifico se arquivo de log existe 
		if nHdlLog > 0
			fWrite(nHdlLog ,  "Não existem dados a serem importados!" )
			fWrite(nHdlLog , CRLF )
		EndIf

		lRet := .F.
	endIf
else
	//verifico se arquivo de log existe 
	if nHdlLog > 0
		fWrite(nHdlLog ,  "Alias <UI1> Não existe no dicionario de dados, compatibilize a base de dados!" )
		fWrite(nHdlLog , CRLF )
	EndIf

	lRet := .F.
endIf

Return(lRet)

/*/{Protheus.doc} fValida
Funcao para validar se o numero da sorte ja existe
@author [tbc] g.sampaio - guilherme.sampaio@totvs.com.br
@since 10/01/2019
@version P12
@param 	cProposta, caracter, numero da proposta
		cNumSor, caracter, numero da sorte
@return nulo
/*/
static function fValida( cProposta, cNumSor )

local aArea 	:= getArea()
local cQuery	:= ""
local lRet 		:= .F.

default cProposta 	:= ""
default cNumSor		:= ""

// ao iniciar a funcao verifico se o alias temporario existe
if select("TRBSOR") > 0
	TRBSOR->( dbCloseAreA() ) // fecho o alias temporario
endIf

// query de conulta do numero da sorte
cQuery := " SELECT UI1_NUMSOR  						" + CRLF
cQuery += " FROM " + retSqlName("UI1") + " UI1 		" + CRLF
cQuery += " WHERE UI1.D_E_L_E_T_ = ' '				" + CRLF
cQuery += " AND UI1.UI1_NUMPRO = '" + cProposta + "'" + CRLF
cQuery += " AND UI1.UI1_NUMSOR = '" + cNumSor	+ "'" + CRLF

// crio o alias temporario com base na query
tcQuery cQuery new alias "TRBSOR"

// verifico se existem dados no alias temporario
if TRBSOR->( !eof() )
	lRet := .T.
endIf

// ao finalizar a funcao verifico se o alias temporario existe
if select("TRBSOR") > 0
	TRBSOR->( dbCloseAreA() ) // fecho o alias temporario
endIf

restArea( aArea )

return(lRet)