#include 'totvs.ch'
#include 'topconn.ch'

/*/{Protheus.doc} RIMPF003

importacao de beneficiario de contrato

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
user Function RIMPF003( aBenCtr, nHdlLog )

	Local aArea         	:= getArea()
	Local aAreaUF4      	:= UF4->( getArea() )
	Local aAreaUF2      	:= UF2->( getArea() )
	Local aDadosCtr			:= {}
	Local aImpBen       	:= {}
	Local aLinhaCtr     	:= {}
	Local aCabCtr       	:= {}
	Local lRet				:= .F.
	Local nX				:= 0
	Local nPosCod   		:= 0
	Local nPosBen       	:= 0
	Local nPosGrau			:= 0
	Local cCodCtr   		:= ""
	Local cNmBenef   		:= ""
	Local cErroExec			:= ""
	Local cPulaLinha		:= Chr(13) + Chr(10)
	Local cDirLogServer		:= ""
	Local cArqLog			:= "log_imp.log"
	Local cGrauParentesco	:= ""
	Local nJ				:= 1
	Local lRFUNE002			:= Existblock("RFUNE002") 
	
	// variavel interna da rotina automatica
	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto 	:= .F.

	// valores do default dos parametros
	default aBenCtr  		:= {}
	default nHdlLog 		:= 0

	//diretorio no server que sera salvo o retorno do execauto
	cDirLogServer := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	cDirLogServer += If(Right(cDirLogServer, 1) <> "\", "\", "")
	
	for nX := 1 to len( aBenCtr )
		
		UF4->( dbSetOrder(1) ) //UF4_FILIAL+UF4_CODIGO+UF4_ITEM

		aLinhaCtr	:= aClone(aBenCtr[nX])

		// pego a posicoes do campo
		nPosCod     := AScan(aLinhaCtr,{|x| AllTrim(x[1]) == "COD_ANT"})
		nPosBen     := AScan(aLinhaCtr,{|x| AllTrim(x[1]) == "UF4_NOME"})
		nPosGrau	:= AScan(aLinhaCtr,{|x| AllTrim(x[1]) == "UF4_GRAU"})

		//importo apenas contrato com codigo anterior e nome do beneficiario preenchido
		if nPosCod > 0 .and. nPosBen > 0

			// pego o codigo do contrato a ser importado
			cCodAnt	:= Alltrim(aLinhaCtr[nPosCod,2])

			// pego o item a ser importado
			cNmBenef := Alltrim(aLinhaCtr[nPosBen,2])

			// pego o grau de parentesco do beneficiario se existir
			if nPosGrau > 0 
				cGrauParentesco := Alltrim(aLinhaCtr[nPosGrau,2])
			endIf
			
			if !Empty(cCodAnt) .and.!Empty(cNmBenef)
				
				UF2->( DbSetOrder(3) ) //UF4_FILIAL + UF4_CODANT

				If UF2->( DbSeek( xFilial("UF2") + PadL(Alltrim(cCodAnt),TamSX3("UF2_CODIGO")[1],"0") ) )
					
					// pego o codigo do contrato do protheus
					cCodCtr := UF2->UF2_CODIGO
					aAdd(aCabCtr, {"UF2_CODIGO"	,cCodCtr } )	//Codigo do Contrato

					//verifico se no contrato ja existe o beneficiario
					if !fValBen( cCodCtr, cNmBenef, cGrauParentesco )

						DbSelectArea("UF4")
						UF4->( dbSetOrder(1) ) //UF4_FILIAL+UF4_CODIGO+UF4_ITEM

						// para o codigo do item
						aAdd(aDadosCtr, {"UF4_ITEM",	fMaxItem( cCodCtr )})

						//monto array com os dados do contrato
						For nJ := 1 To Len(aLinhaCtr)

							if Alltrim(aLinhaCtr[nJ,1]) == "COD_ANT" // se for codigo anterior pula para o proximo
								Loop
							elseIf Alltrim(aLinhaCtr[nJ,1]) == "UF4_TIPO" // para tipo de beneficiario
								if alltrim(aLinhaCtr[nJ,2]) == "3" // nao importo mais de um titular para o contrato

									// limpo o array de dados do contrato
									aDadosCtr := {}

									//verifico se arquivo de log existe
									if nHdlLog > 0

										fWrite(nHdlLog , "Contrato : " + Alltrim(cCodCtr) + " - Nome : " + alltrim(cNmBenef) )

										fWrite(nHdlLog , cPulaLinha )

										fWrite(nHdlLog , "Não é possível ter mais de um titular por contrato!" )

										fWrite(nHdlLog , cPulaLinha )

										lRet := .F.

									endif
									exit
								endIf
							endIf

							aAdd(aDadosCtr, {Alltrim(aLinhaCtr[nJ,1]),	aLinhaCtr[nJ,2]})

						Next nJ

						if len(aDadosCtr) > 0
							aAdd(aImpBen,aDadosCtr)
						endIf
						
						// verifico se a rotina de contratos esta compilada
						if lRFUNE002.and. len(aImpBen) > 0
							
							// inclui os beneficiarios
							If !U_RFUNE002(aCabCtr,aImpBen,,4)
							
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

									fWrite(nHdlLog , "Contrato do Beneficiario: " + Alltrim(cCodCtr) + " - Nome : " + alltrim(cNmBenef) )

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

					endIf
				
				else
					
					//verifico se arquivo de log existe
					if nHdlLog > 0

						fWrite(nHdlLog , "Contrato: " + Alltrim(cCodAnt) + " não encontrado no sistema! " )

						fWrite(nHdlLog , cPulaLinha )

					endif
					
				endIf
			else

				fWrite(nHdlLog , "Nome do beneficiario ou codigo anterior do contrato não preenchidos, campo obrigatório para a importação!" )

				fWrite(nHdlLog , cPulaLinha )

			endif

		else

			fWrite(nHdlLog , "Layout de importação não possui campo Codigo Anterior, a definição do mesmo é obrigatória!" )

			fWrite(nHdlLog , cPulaLinha )

		endif

	next nX

	restArea( aAreaUF2 )
	restArea( aAreaUF4 )
	restArea( aArea )

return lRet

/*/{Protheus.doc} fValBen

valido se o nome do beneficiario esta presente no contrato

@type  Static Function
@author [tbc] g.sampaio
@since 13/12/2018
@version 1.0
@param cCodCtr, 		caracter, codigo do contrato do beneficiario
@param cNmBenef, 		caracter, nome do beneficiario
@param cGrauParentesco, caracter, grau de parentesco do beneficiario
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function fValBen( cCodCtr, cNmBenef, cGrauParentesco )

	Local aArea         	:= getArea()
	Local lRet          	:= .F.
	Local cQuery        	:= ""

	Default cCodCtr     	:= ""
	Default cNmBenef    	:= ""
	Default cGrauParentesco	:= ""

	if select("TRBUF4") > 0
		TRBUF4->( dbCloseArea() )
	endIf

	// monto a query
	cQuery := " SELECT UF4.UF4_CODIGO "
	cQuery += " FROM " + retSqlName("UF4") + " UF4    "
	cQuery += " WHERE UF4.D_E_L_E_T_    = ' '                                  "
	cQuery += " AND UF4.UF4_CODIGO      = '" + alltrim(cCodCtr) +"'              "
	cQuery += " AND TRIM(UF4.UF4_NOME)  = '" + alltrim(cNmBenef) + "'              "
	cQuery += " AND UF4.UF4_FILIAL      = '" + xFilial("UF9") +"'                "

	// caso tenha grau de parentesco
	if !Empty(cGrauParentesco)
		cQuery += "AND UF4.UF4_GRAU		= '" + cGrauParentesco + "'"
	endIf

	cQuery += " ORDER BY UF4.UF4_CODIGO, UF4_NOME                           "

	cQuery  := changeQuery( cQuery )

	tcQuery cQuery new alias "TRBUF4"

	// verifico se existe registro
	if TRBUF4->( !eof() )
		lRet := .T.
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
	cQuery += " AND UF4.UF4_FILIAL = '" + xFilial("UF9") +"'                "

	cQuery  := changeQuery( cQuery )

	tcQuery cQuery new alias "TRBUF4"

	// verifico se existe registro
	if TRBUF4->( !eof() )
		cRet := soma1( TRBUF4->MAXITEM )
	endIf

	TRBUF4->( dbCloseArea() )

	restArea( aArea )

return cRet
