#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "TbiConn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºPrograma  ³ UREPROCUF2 º Autor ³ Raphael Martins			   º Data³ 22/11/2019 º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºDesc.     ³ Funcao para reprocessar contratos do plano 000030 				  º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±ºUso       ³ Rosa Master	                    			                      º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function UREPROCUF2()

Local cLocalErro	:= ""

// carrego o diretório do log de erro
cLocalErro := cGetFile(  , 'Informe o diretório onde será gravado log de importação...', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )

// verifico se foi cancelada a operação
if !Empty(cLocalErro)
	MsAguarde( {|| ReprocessaContratros(cLocalErro)}, "Aguarde", "Reprocessando contratos...", .F. )
endif

Return()

Static Function ReprocessaUF2(cLocalErro)

Local aRegra		:= {}
Local nHandle		:= 0
Local nValCobAd		:= 0
Local nVlrPlano		:= 0 
Local cDirDocs 		:= MsDocPath()
Local cArqLog		:= "Log de Reprocessaemnto.txt"
Local cDirLogServer	:= cDirDocs + iif(IsSrvUnix(),"/","\") + cArqLog
Local cContrato		:= ""
Local cQry			:= ""
Local cPulaLinha	:= chr(13)+chr(10) 
Local nX			:= 1
Local nStart		:= 0

// crio o arquivo de log no servidor
nHandle := MsfCreate( cDirLogServer ,0 )

FwLogMsg("INFO", , "REST", FunName(), "", "01", "REPROCESSAMENTO DOS VALORES DE CONTRATOS DA FUNERARIA DO PLANO 000030", 0, (nStart - Seconds()), {}) 
FwLogMsg("INFO", , "REST", FunName(), "", "01", "Arquivo Gerado: " + cArqLog, 0, (nStart - Seconds()), {}) 

fWrite(nHandle , "#########  REPROCESSAMENTO DOS VALORES DE CONTRATOS DA FUNERARIA  #############")
fWrite(nHandle , cPulaLinha )
fWrite(nHandle , " >> Hora Inicio: " + Time())
fWrite(nHandle , cPulaLinha )
////////////////////////////////////////////////////////////////////////////////////
///////////////////////// CONSULTA CONTRATOS DO PLANO 000030 ///////////////////////
////////////////////////////////////////////////////////////////////////////////////
cQry := " SELECT " 
cQry += " SE1.E1_XCTRFUN CONTRATO, "
cQry += " UF2.UF2_CODANT LEGADO, "
cQry += " SE1.E1_VENCREA VENCIMENTO, "
cQry += " SE1.E1_VALOR VALOR "
cQry += " FROM UF2010 UF2 "
cQry += " INNER JOIN SE1010 SE1 "
cQry += " ON UF2.D_E_L_E_T_ = ' '  "
cQry += " AND SE1.D_E_L_E_T_ = ' '  "
cQry += " AND UF2.UF2_MSFIL = SE1.E1_FILIAL "
cQry += " AND UF2.UF2_CODIGO = SE1.E1_XCTRFUN "
cQry += " AND SE1.E1_PREFIXO = 'FUN' "
cQry += " AND SE1.E1_TIPO = 'AT' "
cQry += " AND UF2_PLANO = '000030' "
cQry += " AND UF2_CODIGO = '000280' "
cQry += " WHERE SE1.E1_VENCREA = ( SELECT MAX(ULT.E1_VENCREA) " 
cQry += " 					   FROM SE1010 ULT  "
cQry += " 					   WHERE D_E_L_E_T_ = ' ' " 
cQry += " 					   AND ULT.E1_FILIAL = SE1.E1_FILIAL "
cQry += " 					   AND ULT.E1_PREFIXO = SE1.E1_PREFIXO "
cQry += " 					   AND ULT.E1_NUM = SE1.E1_NUM "
cQry += " 					   AND ULT.E1_TIPO = SE1.E1_TIPO) "

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

if Select("QRYSE1") > 0 

	DBCloseArea("QRYSE1")

endif
// crio o alias temporario
TcQuery cQry New Alias "QRYSE1" // Cria uma nova area com o resultado do query   

While QRYSE1->(!Eof())

	UF2->(DbSetOrder(1)) //UF2_FILIAL + UF2_CODIGO 

	if UF2->(DbSeek(xFilial("UF2") + QRYSE1->CONTRATO ))
		
		//////////////////////////////////////////////////////////////////////////////////////////////
		////////////////////////////// REPROCESSO AS REGRAS DOS BENEFICIARIOS ////////////////////////
		//////////////////////////////////////////////////////////////////////////////////////////////
		UF4->(DbSetOrder(1)) //UF4_FILIAL + UF4_CODIGO + UF4_ITEM

		if UF4->(DbSeek(xFilial("UF4") + UF2->UF2_CODIGO ))
			
			//deleto UJ9 - Cobranca Adicional 
			DeletaUJ9(UF2->UF2_CODIGO)

			While UF4->(!Eof()) .And. UF4->UF4_FILIAL = UF2->UF2_FILIAL .AND. UF4->UF4_CODIGO == UF2->UF2_CODIGO 
				
				cContrato 		:= UF4->UF4_CODIGO
				nIdadeTit		:= Calc_Idade(UF2->UF2_DTATIV,UF4->UF4_DTNASC)
				dDataFim		:= UF4->UF4_DTFIM
				dDataAtivacao	:= UF2->UF2_DTATIV
				dNascimento		:= UF4->UF4_DTNASC
				cTipoBenef		:= UF4->UF4_TIPO
				cRegra			:= UF4->UF4_REGRA
								
				//Pesquiso a regra do beneficiario 
				PesqValAdic(@aRegra,cContrato,nIdadeTit,dDataFim,dDataAtivacao,dNascimento,cTipoBenef,cRegra)

				For nX := 1 To Len(aRegras)

					RecLock("UJ9",.T.)

					UJ9->UJ9_FILIAL := xFilial("UJ9")
					UJ9->UJ9_ITEM	:= StrZero(nX,3)  
					UJ9->UJ9_CODIGO	:= cContrato
					UJ9->UJ9_REGRA	:= cRegra
					UJ9->UJ9_ITUJ5 	:= aRegras[nX , 02]
					UJ9->UJ9_TPREGR	:= aRegras[nX , 03]
					UJ9->UJ9_VLRINI	:= aRegras[nX , 04]
					UJ9->UJ9_VLRFIM	:= aRegras[nX , 05]
					UJ9->UJ9_VLUNIT	:= aRegras[nX , 06]
					UJ9->UJ9_QTD	:= aRegras[nX , 07]
					UJ9->UJ9_VLTOT	:= aRegras[nX , 08]
					UJ9->UJ9_ITUF	:= aRegras[nX , 09]
					UJ9->UJ9_NOME 	:= aRegras[nX , 10]
					
					UJ9->(MsUnlock())

					nValCobAd += aRegras[nX , 08]

				Next nX

				UF4->(DbSkip())

			EndDo

			//zero o contador de itens da UJ9 de acordo com a mudanca de contrato
			nItem := 0 
			
			///////////////////////////////////
			////////Corrige a UF3 ////////////
			//////////////////////////////////
			nVlrPlano := CorrigeUF3(cContrato,QRYSE1->VALOR,nValCobAd)

			//ATUALIZO O CONTRATO PARA A REGRA 000022 - PLANO C1 2010 
			RecLock("UF2",.F.)
			
			UF2->UF2_REGRA	:= '000022'
			UF2->UF2_VLCOB	:= nValCobAd
			UF2->UF2_VLBRU	:= nVlrPlano
			UF2->UF2_VALOR	:= nVlrPlano + nValCobAd

			UF2->(MsUnlock())
			
		endif
	
		//reunicio a variavel de controle de valores adicionais apos mudanca de contrato
		nValCobAd := 0

	endif

	fWrite(nHandle , " ----------------------------------------------- ")
	fWrite(nHandle , cPulaLinha )
	fWrite(nHandle , " | CONTRATO: " + QRYSE1->CONTRATO + " LEGADO: " + QRYSE1->LEGADO + "             | ")
	fWrite(nHandle , cPulaLinha )
	fWrite(nHandle , " ----------------------------------------------- ")
	fWrite(nHandle , cPulaLinha )
	fWrite(nHandle , " | Valor Atual do Contrato: " + nValMenParc + "                    | ")
	fWrite(nHandle , cPulaLinha )
	fWrite(nHandle , " | Valor Corrigido: " + nValMaiorParc + "                    | ")
	fWrite(nHandle , cPulaLinha )
	
	QRYSE1->(Dbskip())

EndDo

	
fWrite(nHandle , " >> Hora Fim: " + Time())

fClose(nHandle) // fecho o arquivo de log

// copio o arquivo gerado no servidor para o terminal
CpyS2T( cDirLogServer , AllTrim(cLocalErro), .T. )

// verifico se não existe este alias criado
If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf 
	
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PesqValAdic ºAutor³ Wellington Gonçalvesº Data³ 03/05/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função que pesqquisa as regras de contrato cobranças adic. º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Postumos			                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PesqValAdic(cContrato,nIdadeTit,dDataFim,dDataAtivacao,dNascimento,cTipoBenef,cRegra,dIdadeTit)

Local aArea 		:= GetArea()
Local aAreaUJ7 		:= UJ7->(GetArea())
Local aAreaUF4		:= UF4->(GetArea())
Local cPulaLinha	:= chr(13)+chr(10)
Local cQry			:= ""
Local cTipoBenef	:= ""
Local cTpRegra		:= ""
Local cPlano		:= "000030"
Local nQtdBenef		:= 0
Local nQtd			:= 0
Local nIdade		:= 0
Local nValor		:= 0
Local nNumDep		:= 0
Local aRegrasAux	:= {}
Local aAux			:= {}
Local aTipos		:= {}
Local aDependentes	:= {"1","2"} // 1 - Beneficiario 2 - Agregado 3 - Titular
Local lRegraValid	:= .T.
Local nX			:= 1

//////////////////////////////////////////////////////////////
////////////////// CONSULTA REGRAS POR IDADE /////////////////
//////////////////////////////////////////////////////////////

// se o beneficiario nao estiver deletado e estiver ativo 
if Empty(dDataFim) .Or. dDataFim >= dDatabase

	// se a data de nascimento estiver preenchida
	if !Empty(dNascimento)
				
		nIdade := Calc_Idade(dDataAtivacao,dNascimento)
				
		//valido o tipo de regra
		if cTipoBenef == '3'
			
			cTpRegra := "T"
			
		else
					
			cTpRegra := "I"
					
		endif
				
				
		// verifico se nao existe este alias criado
		If Select("QRYUJ5") > 0
			QRYUJ5->(DbCloseArea())
		EndIf

		//Valido se é regra especifica do beneficiario
		if Empty(cRegra)

			cQry := " SELECT "														+ cPulaLinha
			cQry += " UJ5_CODIGO AS CODIGO_REGRA, "                                 + cPulaLinha
			cQry += " UJ6_REGRA AS ITEM_REGRA, "                                    + cPulaLinha
			cQry += " UJ6_TPREGR AS TIPO_REGRA, "                                   + cPulaLinha
			cQry += " UJ6_VLRINI AS LIMITE_INICIAL, "                               + cPulaLinha
			cQry += " UJ6_VLRFIM AS LIMITE_FINAL, "                                 + cPulaLinha
			cQry += " UJ6_VLRCOB AS VALOR, "                                        + cPulaLinha
			cQry += " UJ6_INDIVI AS INDIVIDUAL "                                    + cPulaLinha
			cQry += " FROM "                                                        + cPulaLinha
			cQry += " " + RetSqlName("UF0") + " UF0 "                               + cPulaLinha
			cQry += " INNER JOIN "                                                  + cPulaLinha
			cQry += " " + RetSqlName("UJ5") + " UJ5 "                               + cPulaLinha
			cQry += " ON ( "                                                        + cPulaLinha
			cQry += " 	UJ5.D_E_L_E_T_ <> '*' "                                     + cPulaLinha
			cQry += " 	AND UJ5.UJ5_FILIAL = '" + xFilial("UJ5") + "' "             + cPulaLinha
			cQry += " 	AND UJ5.UJ5_CODIGO = UF0.UF0_REGRA "                        + cPulaLinha
			cQry += " ) "                                                           + cPulaLinha
			cQry += " INNER JOIN "                                                  + cPulaLinha
			cQry += " " + RetSqlName("UJ6") + " UJ6 "                               + cPulaLinha
			cQry += " ON ( "                                                        + cPulaLinha
			cQry += " 	UJ6.D_E_L_E_T_ <> '*' "                                     + cPulaLinha
			cQry += " 	AND UJ6.UJ6_FILIAL = '" + xFilial("UJ6") + "' "             + cPulaLinha
			cQry += " 	AND UJ6.UJ6_CODIGO = UF0.UF0_REGRA "                        + cPulaLinha
			cQry += " 	AND (  "                                                    + cPulaLinha
			cQry += " 		UJ6.UJ6_TPBENE = '" + cTipoBenef + "' "             	+ cPulaLinha
			cQry += "		AND UJ6.UJ6_TPREGR = '" + cTpRegra + "' "				+ cPulaLinha
			cQry += " 		AND UJ6.UJ6_VLRINI <= " + cValToChar(nIdade)         	+ cPulaLinha
			cQry += " 		AND UJ6.UJ6_VLRFIM >= " + cValToChar(nIdade)         	+ cPulaLinha
			cQry += " 	) "                                                         + cPulaLinha
			cQry += " ) "                                                           + cPulaLinha
			cQry += " WHERE "                                                       + cPulaLinha
			cQry += " UF0.D_E_L_E_T_ <> '*' "                                       + cPulaLinha
			cQry += " AND UF0.UF0_FILIAL = '" + xFilial("UF0") + "' "               + cPulaLinha
			cQry += " AND UF0.UF0_CODIGO = '" + cPlano + "' "                       + cPulaLinha
		else
			cQry := " SELECT" 														+ cPulaLinha
			cQry += " 	UJ5_CODIGO AS CODIGO_REGRA,"								+ cPulaLinha
			cQry += " 	UJ6_REGRA AS ITEM_REGRA,"									+ cPulaLinha
			cQry += " 	UJ6_TPREGR AS TIPO_REGRA,"									+ cPulaLinha
			cQry += " 	UJ6_VLRINI AS LIMITE_INICIAL,"								+ cPulaLinha
			cQry += " 	UJ6_VLRFIM AS LIMITE_FINAL,"								+ cPulaLinha	
			cQry += " 	UJ6_VLRCOB AS VALOR,"										+ cPulaLinha
			cQry += " 	UJ6_INDIVI AS INDIVIDUAL"									+ cPulaLinha
			cQry += " FROM " + RETSQLNAME("UJ5") + " UJ5" 							+ cPulaLinha
			cQry += " INNER JOIN " + RETSQLNAME("UJ6") + " UJ6" 					+ cPulaLinha
			cQry += " ON (UJ6.UJ6_FILIAL = UJ5.UJ5_FILIAL"							+ cPulaLinha
			cQry += " 		AND UJ6.UJ6_CODIGO = UJ5.UJ5_CODIGO"					+ cPulaLinha
			cQry += " 		AND (UJ6.UJ6_TPBENE = '" + cTipoBenef + "'" 			+ cPulaLinha
			cQry += " 		AND UJ6.UJ6_TPREGR  = '" + cTpRegra + "' "				+ cPulaLinha
			cQry += " 		AND UJ6.UJ6_VLRINI <=  " + cValToChar(nIdade)			+ cPulaLinha
			cQry += " 		AND UJ6.UJ6_VLRFIM >=  " + cValToChar(nIdade)			+ cPulaLinha 
			cQry += " 		AND UJ6.D_E_L_E_T_= ' '"								+ cPulaLinha 
			cQry += " 	) "                                             			+ cPulaLinha
			cQry += " ) "                                              				+ cPulaLinha
			cQry += " 	WHERE UJ5.D_E_L_E_T_= ' '"									+ cPulaLinha
			cQry += " 		AND UJ5_FILIAL = '" + xFilial("UJ5") 		+ "'"		+ cPulaLinha
			cQry += " 		AND UJ5_CODIGO = '" + FwFldGet("UF4_REGRA") + "'"		+ cPulaLinha

		Endif

		// funcao que converte a query generica para o protheus
		cQry := ChangeQuery(cQry)

		// crio o alias temporario
		TcQuery cQry New Alias "QRYUJ5"

		if QRYUJ5->(!Eof())

			While QRYUJ5->(!Eof())

				aAux := {}

				nValor := QRYUJ5->VALOR

				aadd(aAux , QRYUJ5->CODIGO_REGRA 			) // Código da Regra
				aadd(aAux , QRYUJ5->ITEM_REGRA 				) // Item da Regra
				aadd(aAux , QRYUJ5->TIPO_REGRA 				) // Tipo da Regra
				aadd(aAux , QRYUJ5->LIMITE_INICIAL 			) // Limite Inicial
				aadd(aAux , QRYUJ5->LIMITE_FINAL 			) // Limite Final
				aadd(aAux , nValor 							) // Valor Unitário
				aadd(aAux , 1	 							) // Quantidade
				aadd(aAux , nValor 							) // Valor Total
				aadd(aAux , UF4->UF4_ITEM					) // Item do Beneficiário
				aadd(aAux , UF4->UF4_NOME					) // Nome do Beneficiário

				aadd(aRegrasAux , aAux)

				QRYUJ5->(DbSkip())

			EndDo

		endif

		// verifico se nao existe este alias criado
		If Select("QRYUJ5") > 0
			QRYUJ5->(DbCloseArea())
		EndIf
				
		//titular e beneficiario com regra especificia nao entra para contagem de beneficiarios
		if cTipoBenef <> "3" .AND. Empty( cRegra )
				
			//valido se o tipo de beneficario ja existe no array de aTipos para pesquisar as regras por quantidade
			nPosTipo := aScan( aTipos, { |x| Alltrim(x[1]) == Alltrim(cTipoBenef) } )
				
			if nPosTipo > 0 
					
				aTipos[nPosTipo,2] += 1
					
			else
				
				Aadd(aTipos,{cTipoBenef,1})
					
			endif
					
		
		endif
	
	endif

	//verifico se existe regra para quantidade por tipo de beneficiario
	For nX := 1 To Len(aTipos) 

		//////////////////////////////////////////////////////////////
		/////////////// CONSULTA REGRAS POR QUANTIDADE ///////////////
		//////////////////////////////////////////////////////////////

		// verifico se nao existe este alias criado
		If Select("QRYUJ5") > 0
			QRYUJ5->(DbCloseArea())
		EndIf

		cQry := " SELECT "														+ cPulaLinha
		cQry += " UJ5.UJ5_CODIGO AS CODIGO_REGRA, "                             + cPulaLinha
		cQry += " UJ6.UJ6_REGRA AS ITEM_REGRA, "                                + cPulaLinha
		cQry += " UJ6.UJ6_TPREGR AS TIPO_REGRA, "                               + cPulaLinha
		cQry += " UJ6.UJ6_VLRINI AS LIMITE_INICIAL, "                           + cPulaLinha
		cQry += " UJ6.UJ6_VLRFIM AS LIMITE_FINAL, "                             + cPulaLinha
		cQry += " UJ6.UJ6_VLRCOB AS VALOR, "                                    + cPulaLinha
		cQry += " UJ6.UJ6_INDIVI AS INDIVIDUAL "                                + cPulaLinha
		cQry += " FROM "                                                        + cPulaLinha
		cQry += " " + RetSqlName("UF0") + " UF0 "                               + cPulaLinha
		cQry += " INNER JOIN "                                                  + cPulaLinha
		cQry += " " + RetSqlName("UJ5") + " UJ5 "                               + cPulaLinha
		cQry += " ON ( "                                                        + cPulaLinha
		cQry += " 	UJ5.D_E_L_E_T_ <> '*' "                                     + cPulaLinha
		cQry += " 	AND UJ5.UJ5_FILIAL = '" + xFilial("UJ5") + "' "             + cPulaLinha
		cQry += " 	AND UJ5.UJ5_CODIGO = UF0.UF0_REGRA "                        + cPulaLinha
		cQry += " ) "                                                           + cPulaLinha
		cQry += " INNER JOIN "                                                  + cPulaLinha
		cQry += " " + RetSqlName("UJ6") + " UJ6 "                               + cPulaLinha
		cQry += " ON ( "                                                        + cPulaLinha
		cQry += " 	UJ6.D_E_L_E_T_ <> '*' "                                     + cPulaLinha
		cQry += " 	AND UJ6.UJ6_FILIAL = '" + xFilial("UJ6") + "' "             + cPulaLinha
		cQry += " 	AND UJ6.UJ6_CODIGO = UF0.UF0_REGRA "                        + cPulaLinha
		cQry += " 	AND (  "                                                    + cPulaLinha
		cQry += "		UJ6.UJ6_TPREGR = 'N' "									+ cPulaLinha
		cQry += " 		AND UJ6.UJ6_TPBENE = '" + aTipos[nX,1] + "' "           + cPulaLinha
		cQry += " 		AND UJ6.UJ6_VLRINI <= " + cValToChar(aTipos[nX,2]) 	    + cPulaLinha
		cQry += " 		AND UJ6.UJ6_VLRFIM >= " + cValToChar(aTipos[nX,2])      + cPulaLinha
		cQry += " 	) "                                                         + cPulaLinha
		cQry += " ) "                                                           + cPulaLinha
		cQry += " WHERE "                                                       + cPulaLinha
		cQry += " UF0.D_E_L_E_T_ <> '*' "                                       + cPulaLinha
		cQry += " AND UF0.UF0_FILIAL = '" + xFilial("UF0") + "' "               + cPulaLinha
		cQry += " AND UF0.UF0_CODIGO = '" + cPlano + "' "                       + cPulaLinha

		// funcao que converte a query generica para o protheus
		cQry := ChangeQuery(cQry)

		// crio o alias temporario
		TcQuery cQry New Alias "QRYUJ5"

		if QRYUJ5->(!Eof())

			While QRYUJ5->(!Eof())

				aAux := {}

				if QRYUJ5->INDIVIDUAL == "S"
					nQtd := aTipos[nX,2] - QRYUJ5->LIMITE_INICIAL + 1
				else
					nQtd := 1
				endif

				aadd(aAux , QRYUJ5->CODIGO_REGRA 			) // Código da Regra
				aadd(aAux , QRYUJ5->ITEM_REGRA 				) // Item da Regra
				aadd(aAux , QRYUJ5->TIPO_REGRA 				) // Tipo da Regra
				aadd(aAux , QRYUJ5->LIMITE_INICIAL 			) // Limite Inicial
				aadd(aAux , QRYUJ5->LIMITE_FINAL 			) // Limite Final
				aadd(aAux , QRYUJ5->VALOR 					) // Valor Unitário
				aadd(aAux , nQtd	 						) // Quantidade
				aadd(aAux , QRYUJ5->VALOR * nQtd			) // Valor Total
				aadd(aAux , ""								) // Item do Beneficiário
				aadd(aAux , ""								) // Nome do Beneficiário

				aadd(aRegrasAux , aAux)

				QRYUJ5->(DbSkip())

			EndDo

		endif

	Next nX

	//////////////////////////////////////////////////////////////
	////////// VALIDAÇÃO DAS CONDIÇÕES DA COB. ADICIONAL /////////
	//////////////////////////////////////////////////////////////

	For nX := 1 To Len(aTipos)

		// verifico os tipos de beneficiários que são considerados como dependente
		if aScan( aDependentes, { |x| Alltrim(x) == Alltrim(aTipos[nX,1]) } ) > 0
			nNumDep += aTipos[nX,2]
		endif

	Next nX

	// verifico todas as regras consultadas
	For nX := 1 To Len(aRegrasAux)

		lRegraValid := .T.
		lIdadeDepOK	:= .F.

		// verifico se existe uma condição para a regra
		UJ7->(DbSetOrder(1)) // UJ7_FILIAL + UJ7_CODIGO + UJ7_REGRA + UJ7_ITEM 
		if UJ7->(DbSeek(xFilial("UJ7") + aRegrasAux[nX,1] + aRegrasAux[nX,2]))
		
			While UJ7->(!Eof()) .AND. UJ7->UJ7_FILIAL == xFilial("UJ7") ;
				.AND. UJ7->UJ7_CODIGO == aRegrasAux[nX,1] ;
				.AND. UJ7->UJ7_REGRA == aRegrasAux[nX,2]
				
				if UJ7->UJ7_TPCOND == "I" // Tipo de condição = Idade do Dependente

					UF4->(DbSetOrder(1)) //UF4_FILIAL + UF4_CODIGO + UF4_ITEM

					if UF4->(DbSeek(xFilial("UF4")+cContrato))
						
						// percorro o grid de beneficiarios
						While UF4->(!Eof()) .And. UF4->UF4_FILIAL == xFilial("UF2") .And. UF4->UF4_CODIGO = cContrato
					
							// verifico se o tipo do beneficiario é considerado como dependente
							if aScan( aDependentes, { |x| Alltrim(x) == Alltrim(UF4->UF4_TIPO) } ) > 0
								
								nAge := Calc_Idade(dDataAtivacao,UF4->UF4_DTNASC)

								// se a idade do dependente estiver no intervalo definido
								if nAge >= UJ7->UJ7_VLRINI .AND. nAge <= UJ7->UJ7_VLRFIM
									lIdadeDepOK := .T.
									Exit
								endif
								
							endif
							
							UF4->(DbSkip())
						EndDo
					
						// se não foram encontrados dependentes com idade dentro do intervalo da regra
						if !lIdadeDepOK
							lRegraValid := .F.
							Exit					
						endif
					endif

				elseif UJ7->UJ7_TPCOND == "T" // Tipo de condição = Idade do Titular
				
					
					// se a idade do titular não estiver no intervalo definido
					if !( nIdadeTit >= UJ7->UJ7_VLRINI .AND. nIdadeTit <= UJ7->UJ7_VLRFIM ) 
						lRegraValid := .F.
						Exit						
					endif
					
					
				elseif UJ7->UJ7_TPCOND == "N" // Tipo de condição = Numero de dependentes
				
					// se o número de dependentes não estiver no intervalo definido
					if !( nNumDep >= UJ7->UJ7_VLRINI .AND. nNumDep <= UJ7->UJ7_VLRFIM )
						lRegraValid := .F.
						Exit
					endif
				
				endif
				
				UJ7->(DbSkip())
			
			EndDo
		
		endif
		
		// se a regra foi validada
		if lRegraValid
			aadd(aRegras,aRegrasAux[nX])
		endif

	
	Next nX

endif


RestArea(aAreaUJ7)
RestArea(aArea)
RestArea(aAreaUF4)
	
Return()


/////////////////////////////////////////////
///// FUNCAO PARA DELETAR UJ9	    ////////
////////////////////////////////////////////
Static Function DeletaUJ9(cContrato)

Local aArea		:= GetArea()
Local aAreaUJ9	:= UJ9->(GetArea())
Local cQry 		:= ""

cQry := " DELETE FROM UJ9010 "
cQry += " WHERE D_E_L_E_T_ = ' ' "
cQry += " AND UJ9_FILIAL = '" + xFilial("UJ9") + "' "
cQry += " AND UJ9_CODIGO = '" + cContrato + "' "

TCSqlExec(cQry)

RestArea(aArea)
RestArea(aAreaUJ9)


Return()

/////////////////////////////////////////////
///// FUNCAO PARA DELETAR UJ9	    ////////
////////////////////////////////////////////
Static Function CorrigeUF3(cContrato,nValorUltimaParcela,nAdicional)

Local aArea 			:= GetArea()
Local aAreaUF3			:= UF3->(GetArea())
Local cQry 				:= ""
Local nValorProd		:= 0 
Local nValorTraslado	:= 0


//CONSULTO TODOS OS PRODUTOS DIFERENTES DE TRASLADO PARA AJUSTAR O VALOR DO MESMO
cQry := " SELECT "
cQry += " SUM(UF3_VLRTOT) TOTAL "
cQry += RetSQLName("UF3") 
cQry += " WHERE "
cQry += " D_E_L_E_T_ = ' ' "
cQry += " AND UF3_FILIAL = '" + xFilial("UF3") + "' "
cQry += " AND UF3_CODIGO = '" + cContrato + "' "
cQry += " AND UF3_PRODUT <> '000573' "

// função que converte a query genérica para o protheus
cQry := ChangeQuery(cQry)

if Select("QRYUF3") > 0 

	DBCloseArea("QRYUF3")

endif

TcQuery cQry New Alias "QRYUF3" // Cria uma nova area com o resultado do query 

UF3->(DbSetOrder(2)) //UF3_FILIAL + UF3_CODIGO + UF3_PROD

if QRYUF3->TOTAL > 0 .And. UF3->(DbSeek(xFilial("UF3")+cContrato+"000573"))

	//Valor que representa o que sera debitado do traslado para calcular correto o valor do plano
	nValorProd 		:= nValorUltimaParcela - nAdicional - QRYUF3->TOTAL

	nValorTraslado	:= UF3->UF3_VLRTOT
	
	nValorTraslado	-= nValorProd
	
	nVlrPlano		:= nValorProd + nValorTraslado


	RecLock("UF3",.F.)

	UF3->UF3_VLRUNI := nValorTraslado
	UF3->UF3_VLRTOT	:= nValorTraslado

	UF3->(MsUnlock())


endif


RestArea(aArea)
RestArea(aAreaUF3)

Return(nVlrPlano)

