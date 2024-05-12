#include 'protheus.ch'

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//FUNCAO PARA RETORNAR O PROXIMO CODIGO.        ?
//DEVE SER PASSADO O ALIAS E O CAMPO DO CODIGO. ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

User Function UPROXIMO(_alias, _campo, _filial, _ntam, _where)

Local _cLocal	:= GETAREA()
Local _nProx	:= ''
Local _cCampo	:= _campo
Local _cAlias	:= _alias
Local _cFilial	:= _filial
Default _nTam	:= TamSx3(_campo)[1]
Default _where  := ''

If Empty(_cCampo) .or. Empty(_cAlias)
	Return nil
Endif

cQry := "SELECT MAX(CAST("+_cCampo+" AS FLOAT)) PROX "
cQry += " FROM " + RetSqlName(_cAlias)
//cQry += " WHERE D_E_L_E_T_ <> '*' "
cQry += " WHERE B1_COD <> 'MANUTENCAO' AND B1_COD <> 'TERCEIROS' AND SUBSTRING(B1_COD,1,3) <> 'MOD'"

If !Empty(_cFilial)
	//preenche filial do alias
	If Left(_cAlias,1)<>"S"
		cQry += " WHERE "+_cAlias+"_FILIAL = '"+_cFilial+"' " //ZZZ_FILIAL := xfilial("ZZZ")
	Else
		cQry += " WHERE "+right(_cAlias,2)+"_FILIAL = '"+_cFilial+"' " //Z1_FILIAL := xfilial("SZ1")
	Endif
EndIf
If !Empty(_where)
	cQry += " AND " + _where
EndIf

If Select("QAUX") > 0
	QAUX->(dbCloseArea())
EndIf
	
cQry := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQry), "QAUX", .F., .T.)

If Empty(QAUX->PROX)
	_nProx := strzero( 1, _nTam )
Else
	_nProx := strzero( QAUX->PROX+1, _nTam )
	_nAux  := val( _nProx )
	FreeUsedCode()
	While !MayIUseCode( _cAlias + xFilial(_cAlias) + strzero( _nAux,_nTam ) )
		_nAux += 1
	EndDo
	_nProx:=strzero( _nAux, _nTam )
EndIf

QAUX->(dbClosearea())

restarea( _cLocal )

Return _nProx