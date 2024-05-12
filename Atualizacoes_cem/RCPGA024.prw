#include "protheus.ch"
#include "totvs.ch"
#include "topconn.ch"

#define SW_SHOWNORMAL       1 // Normal

/*/{Protheus.doc} RCPGA024
Rotinas de Impress„o de Boletos
Bancarios

@author TOTVS
@since 03/06/2016
@version P12
@param Nao recebe parametros
@return nulo
/*/
User Function RCPGA024()

	Local aParamVal				:= {}
	Local cPerg         		:= ""
	Local lContinua     		:= .T.
	Local lConsulta				:= .T.
	Local lPadBolInternoPadrao	:= SuperGetMv("MV_XIMPBPA",.F.,.F.)
	Local cContratoIni  		:= ""
	Local cContratoFim  		:= ""
	Local dVencIni     			:= CTOD("")
	Local dVencFim				:= CTOD("")
	Local dReajIni				:= CTOD("")
	Local dReajFim				:= CTOD("")
	Local dEmiIni				:= CTOD("")
	Local dEmiFim				:= CTOD("")
	Local cBanco				:= ""
	Local cAgencia	    		:= ""
	Local cConta 				:= ""
	Local cRotas				:= ""
	Local nTipoImp				:= 2 //Padrao modelo de Parcelas
	Local nQuebra       		:= 0
	Local nQtdBol				:= 0 //Quantidade de boletos por pagina
	Local nCustomizado			:= 0
	Local nProtGerado			:= 0 //Considera apenas boletos com boleto gerado
	Local nCustomizado			:= 0
	Local lPcpGr028				:= ExistBlock("PCPGR028")

	Private __XVEZ 				:= "0"
	Private cMod				:= ""
	Private __ASC       		:= .T.
	Private _nMarca				:= 0

	cMod := U_RetModul()

	If !Empty(cMod)

		cPerg := If(cMod=='CEM','CPGCEM24','CPGFUN24')

		AjustaSX1(cPerg)

		// enquanto o usu·rio n„o cancelar a tela de perguntas
		While lContinua

			// chama a tela de perguntas
			lContinua := Pergunte(cPerg,.T.)

			if lContinua

				cContratoIni := MV_PAR01
				cContratoFim := MV_PAR02
				dEmiIni		 := MV_PAR03
				dEmiFim		 := MV_PAR04
				dVencIni     := MV_PAR05
				dVencFim     := MV_PAR06
				dReajIni     := MV_PAR07
				dReajFim	 := MV_PAR08
				cBanco		 := MV_PAR09
				cAgencia     := MV_PAR10
				cConta       := MV_PAR11

				If cMod =='CEM'

					nTipoImp	:= MV_PAR12
					nQuebra		:= MV_PAR13
					nQtdBol		:= MV_PAR14
					cRotas		:= MV_PAR15
					nExcel		:= MV_PAR16
					nProtGerado	:= MV_PAR17

					//verifico se a impressao sera matricial, caso possua o ponto de entrada
					if lPcpGr028 .And. lPadBolInternoPadrao

						nCustomizado := MV_PAR18

					endif

				Else

					nQuebra		:= MV_PAR12
					nQtdBol		:= MV_PAR13
					cRotas		:= MV_PAR14
					nExcel		:= MV_PAR15
					nProtGerado	:= MV_PAR16

					//verifico se a impressao sera matricial, caso possua o ponto de entrada
					if lPcpGr028.And. lPadBolInternoPadrao

						nCustomizado := MV_PAR17

					endif


				EndIf

				aParamVal := {} // reinicio o array de parametros
				aAdd(aParamVal, cContratoFim )
				aAdd(aParamVal, dEmiFim		 )
				aAdd(aParamVal, dVencFim     )
				aAdd(aParamVal, dReajIni	 )
				aAdd(aParamVal, dReajFim	 )
				aAdd(aParamVal, cBanco		 )
				aAdd(aParamVal, cAgencia     )
				aAdd(aParamVal, cConta       )

				if ValidParam(aParamVal)

					//consulto titulos de acordo com os parametros informados
					FWMsgRun(,{|oSay| lConsulta := ConsultaTit(cContratoIni,cContratoFim,dEmiIni,dEmiFim,dVencIni,dVencFim,dReajIni,dReajFim,cBanco,nTipoImp,cRotas,nProtGerado)  },'Aguarde...','Consultando Titulos a serem impressos...')

					If lConsulta
						FWMsgRun(,{|oSay| MontaTela(cBanco,cAgencia,cConta,nTipoImp,nQuebra,nQtdBol,nExcel,nCustomizado) },'Aguarde...','Consultando Titulos a serem impressos...')
					Else
						Aviso( "", "A Consulta realizada n„o retornou registros, favor verifique os parametros digitados!", {"Ok"} )
					Endif

				endIf

			endif

		EndDo

	EndIf

Return

/*/{Protheus.doc} AjustaSX1
FunÁ„o que cria as perguntas na SX1.
@type function
@version 1.0
@author Raphael Martins
@since 03/06/2016
@param cPerg, character, grupo de pergunta
@history 22/07/2020, g.sampaio, VPV-209 - Implementado mais uma nova opcao no parametro MV_PAR12 - 3 - Locao de Nicho
/*/
Static Function AjustaSX1(cPerg)  // cria a tela de perguntas do relatÛrio

	Local aHelpPor				:= {}
	Local aHelpEng				:= {}
	Local aHelpSpa				:= {}
	Local cF3 					:= If(cPerg=='CPGCEM24','U00','UF2')
	Local lPadBolInternoPadrao	:= SuperGetMv("MV_XIMPBPA",.F.,.F.)
	Local lPcpGr028				:= ExistBlock("PCPGR028")

	///////////// Contrato ////////////////
	U_xPutSX1( cPerg, "01","Do Contrato?","Do Contrato","Do Contrato","cContratoIni","C",6,0,0,"G","",cF3,"","","MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	U_xPutSX1( cPerg, "02","AtÈ Contrato?","AtÈ Contrato?","AtÈ Contrato?","cContratoFim","C",6,0,0,"G","",cF3,"","","MV_PAR02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	///////////// Intervalo de Emissao ////////////////
	U_xPutSX1( cPerg, "03","Da Emissao?","Da Emissao?","Da Emissao?","dEmiIni","D",8,0,0,"G","","","","","MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	U_xPutSX1( cPerg, "04","AtÈ Emissao?","AtÈ Emissao?","AtÈ Emissao?","dEmiFim","D",8,0,0,"G","","","","","MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	///////////// Intervalo de Vencimento ////////////////
	U_xPutSX1( cPerg, "05","Do Vencimento?","Do Vencimento?","Do Vencimento?","dVencIni","D",8,0,0,"G","","","","","MV_PAR05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	U_xPutSX1( cPerg, "06","AtÈ Vencimento?","AtÈ Vencimento?","AtÈ Vencimento?","dVencFim","D",8,0,0,"G","","","","","MV_PAR06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	///////////// Reajuste ////////////////
	U_xPutSX1( cPerg, "07","Do Reajuste?","Do Reajuste?","Do Reajuste?","dReajuste","D",8,0,0,"G","","","","","MV_PAR07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	U_xPutSX1( cPerg, "08","AtÈ Reajuste?","AtÈ Reajuste?","AtÈ Reajuste?","dReajuste","D",8,0,0,"G","","","","","MV_PAR08","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	///////////// Agente Cobrador ////////////////

	U_xPutSX1( cPerg, "09","Banco?","Banco?","Banco?","Banco","C",3,0,0,"G","","SA6","","","MV_PAR09","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	U_xPutSX1( cPerg, "10","Agencia?","Agencia?","Agencia?","Agencia","C",5,0,0,"G","","","","","MV_PAR10","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	U_xPutSX1( cPerg, "11","Conta?","Agencia?","Agencia?","Conta","C",10,0,0,"G","","","","","MV_PAR11","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	///////////// Status ////////////////
	If cPerg == 'CPGCEM24' //Funeraria È sempre boleto do tipo parcela
		U_xPutSX1( cPerg, "12","Tipo de Titulo?","Tipo de Titulo?","Tipo de Titulo?","nTipo","N",1,0,0,"C","","","","","MV_PAR12",'1-Taxa de ManutenÁ„o',;
			'1-Taxa de ManutenÁ„o','1-Taxa de ManutenÁ„o','1-Taxa de ManutenÁ„o','2-Parcelas','2-Parcelas','2-Parcelas',"3-Loc.Nicho","3-Loc.Nicho","3-Loc.Nicho","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	EndIf

	///////////// Quebra p·gina por cliente? ////////////////
	U_xPutSX1( cPerg, "13","Quebra pag. p/ cliente?","Quebra pag. p/ cliente?","Quebra pag. p/ cliente?","nQuebra","N",1,0,0,"C","","","","","MV_PAR13",'S-Sim',;
		'S-Sim','S-Sim','S-Sim','N-N„o','N-N„o','N-N„o',"","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	///////////// Quantos boletos por Pagina ////////////////
	U_xPutSX1( cPerg, "14","Quantos Boletos por Pag?","Quantos Boletos por Pag?","Quantos Boletos por Pag?","nBolPg","N",1,0,0,"C","","","","","MV_PAR14",'1-Um Boleto',;
		'1-Um Boleto','1-Um Boleto','1-Um Boleto','3-Tres Boletos','3-Tres Boletos','3-Tres Boletos',"","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	///////////// Rota ////////////////
	U_xPutSX1( cPerg, "15","Rota(s)?","Rota(s)?","Rota(s)?","Rota","C",20,0,0,"G","","U34MAR","","","MV_PAR15","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

	///////////// Tipo impress„o ////////////////
	U_xPutSX1( cPerg, "16","Tipo impressao?","Tipo impressao?","Tipo impressao?","nExcel","N",1,0,0,"C","","","","","MV_PAR16","Relatorio","","","","Excel","","","","","","","","","","","",;
		aHelpPor,aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg, "17","Sem CarnÍ Gerado?","Sem CarnÍ Gerado?","Sem CarnÍ Gerado?","nProtGerado","N",1,0,0,"C","","","","","MV_PAR17","Sim","","","","Nao","","","","","","","","","","","",;
		aHelpPor,aHelpEng,aHelpSpa)

	///////////////////////////////////////////////////////////////////////////////////////////////////////////
	///////////// Valido se imprime boleto interno padrao mesmo como ponto de entrada  PCPGR028 aplicado//////
	///////////////////////////////////////////////////////////////////////////////////////////////////////////
	If lPcpGr028 .And. lPadBolInternoPadrao

		U_xPutSX1( cPerg, "18","Imp. Padrao ou Customizada?","Imp. Customizada ou Padr„o?","Imp. Customizada ou Padr„o?","nCustomizado","N",1,0,0,"C","","","","","MV_PAR18","Customizado","","","","Padr„o","","","","","","","","","","","",;
			aHelpPor,aHelpEng,aHelpSpa)

	endif

Return(Nil)

/*/{Protheus.doc} ConsultaTit
Funcao para Realizar a consulta dos Titulos de Acordo com os param
@type function
@version 
@author Raphael Martins 
@since 03/06/2016
@param cContratoIni, character, param_description
@param cContratoFim, character, param_description
@param dEmiIni, date, param_description
@param dEmiFim, date, param_description
@param dVencIni, date, param_description
@param dVencFim, date, param_description
@param dReajIni, date, param_description
@param dReajFim, date, param_description
@param cBanco, character, param_description
@param nTipoImp, numeric, param_description
@param cRotas, character, param_description
@return return_type, return_description
@history 22/07/2020, g.sampaio, VPDV-209 - Adicionado os parametros de tipo e prefixo de locacao de nicho e implementado na consulta.
- feito tratamento para considerar o reajuste da taxa de locacao de nicho
- criado parametro MV_XPREFBO para ser preenchido os prefixos para a impress„o de boletos
/*/
Static Function ConsultaTit(cContratoIni,cContratoFim,dEmiIni,dEmiFim,dVencIni,dVencFim,dReajIni,dReajFim,cBanco,nTipoImp,cRotas,nProtGerado)

	Local cSQL			:= ""
	Local lRet			:= .T.
	Local cTipoPar		:= Alltrim(SuperGetMv("MV_XTIPOCT",.F.,"AT"))  //Tipo de Titulo de Parcela
	Local cPrefBoleto	:= AllTrim(SuperGetMV("MV_XPREFBO",.F.,"MNT;CVL;LOC;CTR;FUN")) // Prefixo para impress„o de boleto
	Local cTipoMnt		:= Alltrim(SuperGetMv("MV_XTIPOMN",.F.,"CT"))  //Tipo de Titulo de Taxa de ManutenÁ„o
	Local cBolInt 		:= Alltrim(SuperGetMv("MV_XFORCRN",.F.,"BI"))  //Forma de Pagamento Boleto Interno
	Local cBolBco		:= Alltrim(SuperGetMv("MV_XFORBOL",.F.,"BO"))  //Forma de Pagamento Boleto Bancario
	Local cBolDom		:= Alltrim(SuperGetMv("MV_XFORDOM",.F.,"DO"))  //Forma de Pagamento Cobranca Domicilio
	Local cTipoLoc      := AllTrim(SuperGetMv("MV_XTIPLOC",.F.,"AT"))	// tipo de locacao de nicho
	Local cPulaLinha 	:= Chr(13)+(Chr(10))

	cSQL := " SELECT DISTINCT "                                                                             + cPulaLinha
	cSQL += " E1_CLIENTE, "                                                                                 + cPulaLinha
	cSQL += " E1_LOJA,  "                                                                                   + cPulaLinha
	cSQL += " E1_NUM, "                                                                                     + cPulaLinha
	cSQL += " E1_PARCELA, "                                                                                 + cPulaLinha
	cSQL += " E1_TIPO, "                                                                                    + cPulaLinha
	cSQL += " E1_XCONTRA, "					                                                                + cPulaLinha
	cSQL += " E1_PREFIXO, "			                                                                        + cPulaLinha
	cSQL += " E1_EMISSAO,     "                                                                             + cPulaLinha
	cSQL += " E1_VENCTO,    "                                                                               + cPulaLinha
	cSQL += " E1_VALOR,   "                                                                                 + cPulaLinha
	cSQL += " E1_SALDO, "                                                                                   + cPulaLinha
	cSQL += " E1_XCTRFUN, "                                                                                 + cPulaLinha
	cSQL += " E1_ACRESC, "				                                                                    + cPulaLinha
	cSQL += " E1_XFORPG, "				                                                                    + cPulaLinha
	cSQL += " ROTA.U34_CODIGO COD_ROTA, "																	+ cPulaLinha
	cSQL += " ROTA.U34_DESCRI DESC_ROTA "
	cSQL += " FROM "                                                                                        + cPulaLinha
	cSQL += + RetSQLName("SE1")+" E1 "                                                                      + cPulaLinha
	cSQL += " INNER JOIN "																					+ cPulaLinha
	cSQL += + RetSQLName("SA1") + " CLIENTES "																+ cPulaLinha
	cSQL += " ON "																							+ cPulaLinha
	cSQL += " CLIENTES.D_E_L_E_T_ = ' ' "																	+ cPulaLinha
	cSQL += " AND CLIENTES.A1_FILIAL = '" + xFilial("SA1") + "' "											+ cPulaLinha
	cSQL += " AND E1.E1_CLIENTE = CLIENTES.A1_COD "															+ cPulaLinha
	cSQL += " AND E1.E1_LOJA = CLIENTES.A1_LOJA "															+ cPulaLinha

	// vou tratar qual modulo esta executando a impressao de boletos - [tbc] g.sampaio - 04/12/2018
	if cMod == "CEM"// cemiterio
		cSQL += " INNER JOIN "                                                                                   + cPulaLinha
		cSQL += " " + RetSQLName("U00") + " CEMITERIO "															+ cPulaLinha
		cSQL += " ON  E1.D_E_L_E_T_ = ' ' "  																	+ cPulaLinha
		cSQL += " AND CEMITERIO.D_E_L_E_T_ = ' ' "																+ cPulaLinha

		// tratamento para considerar os titulos da filial logada, devido ao compartilhamento das tabelas de cemiterio
		// poder ser diferente do compartilhamento do financeiro - [tbc] g.sampaio - 04/12/2018
		cSQL += " AND E1.E1_FILIAL = '" + xFilial("SE1") + "' " 												+ cPulaLinha
		cSQL += " AND E1.E1_XCONTRA = CEMITERIO.U00_CODIGO "													+ cPulaLinha
		cSQL += " AND CEMITERIO.U00_STATUS = 'A' "																+ cPulaLinha

	elseIf cMod == "FUN"// funeraria

		cSQL += " INNER JOIN "																					+ cPulaLinha
		cSQL += " " + RetSQLName("UF2") + " FUNERARIA "															+ cPulaLinha
		cSQL += " ON E1.D_E_L_E_T_ = ' ' " 																		+ cPulaLinha

		// tratamento para considerar os titulos da filial logada, devido ao compartilhamento das tabelas de funeararia
		// poder ser diferente do compartilhamento do financeiro - [tbc] g.sampaio - 04/12/2018
		cSQL += " AND E1.E1_FILIAL = '" + xFilial("SE1") + "' "													+ cPulaLinha
		cSQL += " AND E1.E1_XCTRFUN = FUNERARIA.UF2_CODIGO "													+ cPulaLinha
		cSQL += " AND FUNERARIA.UF2_STATUS = 'A' "																+ cPulaLinha

	endIf

	// ponto de entrada para adicionar tratativas ao JOIN com as tabelas
	// de contratos de cemiterio e planos funerarios
	If ExistBlock("PEBLJOIN")
		cSQL += " " + ExecBlock( "PEBLJOIN", .F. ,.F., {cMod} )
	EndIf

	cSQL += " LEFT JOIN "																					+ cPulaLinha
	cSQL += + RetSQLName("ZFC") + " BAIRROS "																+ cPulaLinha
	cSQL += " ON "																							+ cPulaLinha
	cSQL += " BAIRROS.D_E_L_E_T_ = ' ' "																	+ cPulaLinha
	cSQL += " AND BAIRROS.ZFC_FILIAL = '" + xFilial("ZFC") + "' "											+ cPulaLinha
	cSQL += " AND CLIENTES.A1_XCODBAI = BAIRROS.ZFC_CODBAI "												+ cPulaLinha

	cSQL += " LEFT JOIN "																					+ cPulaLinha
	cSQL += + RetSQLName("U35") + " ITENS_ROTA "															+ cPulaLinha
	cSQL += " ON "																							+ cPulaLinha
	cSQL += " ITENS_ROTA.D_E_L_E_T_ = ' ' "																	+ cPulaLinha
	cSQL += " AND ITENS_ROTA.U35_FILIAL = '" + xFilial("U35") + "'"  										+ cPulaLinha
	cSQL += " AND BAIRROS.ZFC_CODBAI = ITENS_ROTA.U35_CODBAI "												+ cPulaLinha

	cSQL += " LEFT JOIN "																					+ cPulaLinha
	cSQL += + RetSQLName("U34") + " ROTA "																	+ cPulaLinha
	cSQL += " ON "																							+ cPulaLinha
	cSQL += " ROTA.D_E_L_E_T_ = ' ' "																		+ cPulaLinha
	cSQL += " AND ITENS_ROTA.U35_FILIAL = ROTA.U34_FILIAL " 		 										+ cPulaLinha
	cSQL += " AND ITENS_ROTA.U35_CODIGO = ROTA.U34_CODIGO "													+ cPulaLinha

	cSQL += "   WHERE "                                                                                 	+ cPulaLinha
	cSQL += " 	E1.D_E_L_E_T_ = ' ' "																		+ cPulaLinha
	cSQL += "   AND E1_FILIAL = '"+xFilial("SE1")+"' "														+ cPulaLinha

	If cMod == 'CEM'

		cSQL += "    AND E1_XCONTRA BETWEEN '" + cContratoIni + "' AND '" + cContratoFim + "' "         	+ cPulaLinha

	Else

		cSQL += "    AND ( E1_XCTRFUN BETWEEN '" + cContratoIni + "' AND '" + cContratoFim + "' "         	+ cPulaLinha
		cSQL += "    OR    E1_XCONCTR BETWEEN '" + cContratoIni + "' AND '" + cContratoFim + "' )"         	+ cPulaLinha

	EndIf

	cSQL += " 	 AND E1_EMISSAO BETWEEN '" + DTOS(dEmiIni) + "' AND '" + DTOS(dEmiFim) + "' "	        	+ cPulaLinha
	cSQL += "    AND E1_VENCTO BETWEEN '" + DTOS(dVencIni) + "' AND '" + DTOS(dVencFim) + "' "          	+ cPulaLinha
	cSQL += "    AND E1_SALDO > 0 "                                                                     	+ cPulaLinha
	cSQL += "    AND E1_PREFIXO IN " + FormatIn( AllTrim(cPrefBoleto),";")   + "" 	 												+ cPulaLinha

	If nTipoImp == 1 .And. cMod == "CEM" // taxa de manutencao

		cSQL += "    AND E1_TIPO = '"+cTipoMnt+"' "															+ cPulaLinha

	elseIf nTipoImp == 3 .And. cMod == "CEM" // locao de nicho

		cSQL += "    AND E1_TIPO = '"+cTipoLoc+"' "															+ cPulaLinha

	Else

		//Na funeraria os tipos dos titulos sao diferente, quando sao reajustados
		//entao para impressao do boleto indifere o tipo
		If cMod == 'CEM'
			cSQL += "    AND E1_TIPO = '"+cTipoPar+"' "														+ cPulaLinha
		EndIf

	EndIf

	If !Empty(dReajIni) .And. !Empty(dReajFim)

		// vou tratar qual modulo esta executando a impressao de boletos - [tbc] g.sampaio - 04/12/2018
		if cMod == "CEM"// cemiterio

			if nTipoImp == 3 // para taxa de locacao

				cSQL += "	AND ( E1_XCONTRA <> ' ' AND E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
				cSQL += "	IN (
				cSQL += "														SELECT U75.U75_PREFIX+U75_NUM+U75_PARCEL+U75_TIPO FROM "+ RetSQLName("U75") +" U75
				cSQL += "																	INNER JOIN "+ RetSQLName("U78") +" U78 ON U78.D_E_L_E_T_ = ' '
				cSQL += "																	AND U78.U78_FILIAL = '" + xFilial("U78") + "'
				cSQL += "																	AND U78.U78_CODLOC = U75.U75_CODIGO
				cSQL += "   																AND U78.U78_DATA BETWEEN '"+ DTOS(dReajIni) + "' AND '" + DTOS(dReajFim) + "' " + cPulaLinha
				cSQL += "																 )"
				cSQL += "        ) "

			else

				//Pesquiso titulos que tiveramm reajustes de contratos de cemiterio
				cSQL += " AND ( E1_XCONTRA <> ' ' AND  E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO "      					 + cPulaLinha
				cSQL += "   	   IN ( "																			 + cPulaLinha
				cSQL += "        	 SELECT U21_PREFIX+U21_NUM+U21_PARCEL+U21_TIPO CHV_TIT  "             			 + cPulaLinha
				cSQL += "           	FROM "+RetSQLName("U20")+"  U20 " 											 + cPulaLinha
				cSQL += "				INNER JOIN "+RetSQLName("U21")+" U21 "		 								 + cPulaLinha
				cSQL += "   			ON U20.D_E_L_E_T_ = ' ' AND U21.D_E_L_E_T_ = ' ' "                           + cPulaLinha
				cSQL += "               AND U20.U20_FILIAL = '"+xFilial("U20")+"' "                                  + cPulaLinha
				cSQL += "   			AND U20.U20_FILIAL = U21.U21_FILIAL "                                        + cPulaLinha
				cSQL += "   			AND U20.U20_CODIGO = U21.U21_CODIGO "                                        + cPulaLinha
				cSQL += "   			AND U20.U20_DATA BETWEEN '"+ DTOS(dReajIni) + "' AND '" + DTOS(dReajFim) + "' " + cPulaLinha
				cSQL += "           ) "																				 + cPulaLinha
				cSQL += "        ) "

			endIf

		elseIf cMod == "FUN"// funeraria
			// Pesquiso titulos que foram reajustados do contrato de funeraria
			cSQL += " AND ( E1_XCTRFUN <> '' AND E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO "	 						 + cPulaLinha
			cSQL += "         IN ( "																			 + cPulaLinha
			cSQL += "             SELECT UF8_PREFIX+UF8_NUM+UF8_PARCEL+UF8_TIPO CHV_TIT "			 			 + cPulaLinha
			cSQL += "               FROM "+RetSQLName("UF7")+"  UF7 										" 	 + cPulaLinha
			cSQL += "				INNER JOIN "+RetSQLName("UF8")+" UF8  " 	 								 + cPulaLinha
			cSQL += "   			ON UF7.D_E_L_E_T_ = ' ' AND UF8.D_E_L_E_T_ = ' ' "                           + cPulaLinha
			cSQL += "               AND UF7.UF7_FILIAL = '"+ xFilial("UF7") +"' "								 + cPulaLinha
			cSQL += "   			AND UF7.UF7_FILIAL = UF8.UF8_FILIAL "                                        + cPulaLinha
			cSQL += "   			AND UF7.UF7_CODIGO = UF8.UF8_CODIGO "                                        + cPulaLinha
			cSQL += "   			AND UF7.UF7_DATA BETWEEN '"+ DTOS(dReajIni) + "' AND '" + DTOS(dReajFim) + "'" + cPulaLinha
			cSQL += "           )"																				 + cPulaLinha
			cSQL += "     )"																			         + cPulaLinha

		endIf

	EndIf

	//valido se as rotas foram preenchidas
	if !Empty(cRotas)
		cSQL += " AND ITENS_ROTA.U35_CODIGO IN " + FormatIn( AllTrim(cRotas),";")  							+ cPulaLinha
	endif

	//boleto interno
	if cBanco == '999'

		cSQL += " AND E1_XFORPG IN ('','"+cBolInt+"', '"+cBolDom+"') "	+ cPulaLinha

		//boleto Bancario
	else

		// trato as formas de pagamento para a impressao de boleto
		cBolBco := FormatIn(AllTrim(cBolBco) + ";", ";")

		cSQL += " AND E1_XFORPG IN " + cBolBco	+ cPulaLinha

	endif

	//----------------------------------------------------------------------------
	// VALIDO SE CONSIDERO APENAS TITULOS QUE NAO POSSUI PROTOCOLOS GERADOS
	//----------------------------------------------------------------------------
	if nProtGerado == 1

		cSQL += " AND NOT EXISTS ( SELECT U33_CODIGO " + cPulaLinha
		cSQL += " 			 FROM " + cPulaLinha
		cSQL += " 			 " + RetSQLName("U33") + " U33 " + cPulaLinha
		cSQL += " 			 WHERE " + cPulaLinha
		cSQL += " 			 U33.D_E_L_E_T_ = ' ' " + cPulaLinha
		cSQL += " 			 AND U33_FILIAL = '" + xFilial("U33") + "' " + cPulaLinha
		cSQL += " 			 AND U33.U33_PREFIX = E1.E1_PREFIXO " + cPulaLinha
		cSQL += " 			 AND U33.U33_NUM = E1.E1_NUM " + cPulaLinha
		cSQL += " 			 AND U33.U33_PARCEL = E1.E1_PARCELA " + cPulaLinha
		cSQL += " 			 AND U33.U33_TIPO = E1.E1_TIPO " + cPulaLinha
		cSQL += " 			) "  + cPulaLinha

	endif

	// ponto de entrada para customizacao do where da consulta de boleto
	If ExistBlock("PEBLWHERE")
		cSQL += " " + ExecBlock( "PEBLWHERE", .F. ,.F., {cMod} )
	EndIf

	cSQL += " ORDER BY E1_CLIENTE,E1_LOJA, E1_XCONTRA,E1_XCTRFUN,E1_NUM,E1_PARCELA,E1_TIPO  "			 	+ cPulaLinha

	If Select("QSE1") > 0
		QSE1->( DbCloseArea() )
	EndIf

	MemoWrite( GetTempPath() + "boleto_rcpga024_" + DtoS(dDataBase) + StrTran(Time(),":","") + ".txt", cSQL)

	cSQL := ChangeQuery(cSQL)

	MPSysOpenQuery( cSQL, "QSE1" )

	QSE1->( DbGotop() )

	If QSE1->( EOF() )
		lRet := .F.
	EndIf

Return(lRet)

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±∫ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ∫±±
±±∫Programa  ≥ MontaTela ∫ Autor ≥ Raphael Martins  		   ∫ Data≥ 03/06/2016 ∫±±
±±∫ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ∫±±
±±∫Desc.     ≥ Funcao para montar a tela de selecao de tit. para impressao		  ∫±±
±±∫ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ∫±±
±±∫Uso       ≥ Vale do Cerrado                    			                      ∫±±
±±∫ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ∫±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/

Static Function MontaTela(cBanco,cAgencia,cConta,nTipoImp,nQuebra,nQtdBol,nExcel,nCustomizado)

	Local oPn1
	Local oPn2
	Local oPn3
	Local oTotal
	Local oQtdMark
	Local oGetTotal
	Local oQtTotal
	Local oGrid
	Local oFont      :=	TFont():New('Courier New',,-12,.T.)
	Local aSizeAut   := {}
	Local cTitulo    := "Boletos para Impress„o"
	Local nGetTotal  := 0
	Local nQtTotal   := 0
	local nColOrder	 := 0

	Default nQuebra  := 1

	Private aButtons := {}

	aSizeAut := MsAdvSize()

	DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

	aAdd(aButtons, {"", {|| GdSeek(oGrid,"Pesquisa"/*,aCposFind*/) }, "Pesquisa" })

	@ 001,000 MSPANEL oPn1 SIZE 150, 050 OF oDlg
	@ 001,000 MSPANEL oPn2 SIZE 150, 050 OF oPn1
	@ 001,000 MSPANEL oPn3 SIZE 150, 050 OF oPn1

	oPn1:Align  := CONTROL_ALIGN_ALLCLIENT
	oPn2:Align  := CONTROL_ALIGN_TOP
	oPn3:Align  := CONTROL_ALIGN_BOTTOM

	oPn2:nHeight := (oMainWnd:nClientHeight / 2) + 150
	oPn3:nHeight := (oMainWnd:nClientHeight - oPn2:nHeight ) - 100

	@ 00, 05 SAY oTotal PROMPT "R$ Total Selecionado:" SIZE 100, 007 OF oPn3 Font oFont COLOR CLR_RED PIXEL
	@ 00, 090 MSGET oGetTotal VAR nGetTotal SIZE 100, 007 When .F. OF oPn3 HASBUTTON PIXEL COLOR CLR_BLACK Picture "@E 999,999,999.99"

	@ 00, 210 SAY oTotal PROMPT "Quantidade Selecionada:" SIZE 100, 007 OF oPn3 COLORS CLR_RED Font oFont COLOR CLR_BLACK PIXEL
	@ 00, 300 MSGET oQtTotal VAR nQtTotal SIZE 100, 007 When .F. OF oPn3 HASBUTTON PIXEL COLOR CLR_BLACK Picture "@E 999999999"

	oGrid := MontaGrid(oPn2,oGetTotal,@nGetTotal,oQtTotal,@nQtTotal)

	oGrid:oBrowse:bLDblClick := {|| Clique(oGrid,oGetTotal,@nGetTotal,oQtTotal,@nQtTotal) }
	oGrid:oBrowse:bHeaderClick := {|oBrw1,nCol| if(oGrid:oBrowse:nColPos <> 111 .And. nCol == 1,(MarcaTodos(oGrid,oGetTotal,@nGetTotal,oQtTotal,@nQtTotal),;
	oBrw1:SetFocus()),(U_OrdGrid(oGrid,nCol) , nColOrder := nCol ))}

	oGrid:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oGrid:oBrowse:Refresh()
	
	EnchoiceBar(oDlg, {|| FWMsgRun(,{|oSay| Confirma(oSay,oDlg,oGrid,cBanco,cAgencia,cConta,nTipoImp,nQuebra,oGetTotal,@nGetTotal,;
	oQtTotal,@nQtTotal,nQtdBol,nExcel,nCustomizado) },'Aguarde...','Realizando a GeraÁ„o do(s) Boleto(s) selecionados...')},{|| oDlg:End()},,aButtons)
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	
Return()

//********************************************************
// Funcao para montar Grid de VisualizaÁ„o dos Titulos
//********************************************************

Static Function MontaGrid(oPainel,oGetTotal,nGetTotal,oQtTotal,nQtTotal)

	Local oGrid
	Local aHeader       := {}
	Local aCols         := {}
	Local aAlterFields  := {}

	aHeader := NewHeader()
	aAcols  := NewAcols(@nGetTotal,@nQtTotal)

	oGrid := MsNewGetDados():New( 05,05,000, 000, , "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,;
	, 999, "AllwaysTrue", "", "AllwaysTrue",oPainel, aHeader, aAcols)

	oGetTotal:Refresh()
	oQtTotal:Refresh()

Return(oGrid)

/*/{Protheus.doc} NewHeader
Funcao para Montar aHeader da Grid
@author Raphael Martins
@since 03/06/2016
@version P11
@param
@return nulo
/*/
Static Function NewHeader()

	Local aHeaderEx		:= {}
	Local nX            := 0
	Local aFields		:= {"A1_COD","A1_LOJA","A1_NOME","E1_XCONTRA",;
		"E1_PREFIXO", "E1_TIPO", "E1_NUM","E1_PARCELA",;
		'E1_EMISSAO','E1_VENCTO','E1_VALOR','E1_SALDO',;
		"U34_CODIGO","U34_DESCRI","E1_XFORPG"}
	Local oSX3			:= UGetSxFile():New
	Local aSX3			:= {}


	Aadd(aHeaderEx, {"","MARK","@BMP",2,0,"","ÄÄÄÄÄÄÄÄÄÄÄÄÄÄ","C","","","",""})

	For nX := 1 to Len(aFields)

		aSX3 := oSX3:GetInfoSX3(,aFields[nX])

		If Len(aSX3) > 0
			Aadd(aHeaderEx, {aSX3[1,2]:cTITULO,aSX3[1,2]:cCAMPO,aSX3[1,2]:cPICTURE,aSX3[1,2]:nTAMANHO,aSX3[1,2]:nDECIMAL,aSX3[1,2]:cVALID,;
				aSX3[1,2]:cUSADO,aSX3[1,2]:cTIPO,aSX3[1,2]:cF3,aSX3[1,2]:cCONTEXT,aSX3[1,2]:cCBOX,aSX3[1,2]:cRELACAO})
		Endif

	Next nX

Return( aClone(aHeaderEx) )

/*/{Protheus.doc} NewAcols
Funcao para Montar aCols da Grid
@author Raphael Martins
@since 03/06/2016
@version P12
@param
@return nulo
/*/
Static Function NewAcols(nGetTotal,nQtTotal)

	Local aColsEx     := {}
	Local aFieldFill  := {}

	QSE1->( DbGotop() )

	While QSE1->( !EOF() )
		//{"A1_COD","A1_LOJA","A1_NREDUZ","E1_PREFIXO", "E1_TIPO", "E1_NUM","E1_PARCELA",'E1_EMISSAO','E1_VENCTO','E1_VALOR','E1_SALDO'}

		Aadd(aFieldFill,"CHECKED")
		Aadd(aFieldFill,QSE1->E1_CLIENTE)
		Aadd(aFieldFill,QSE1->E1_LOJA)
		Aadd(aFieldFill,RetField("SA1",1, xFilial("SA1") + QSE1->E1_CLIENTE + QSE1->E1_LOJA,'A1_NOME') )

		If !Empty(QSE1->E1_XCONTRA)
			Aadd(aFieldFill,QSE1->E1_XCONTRA)
		Else
			Aadd(aFieldFill,QSE1->E1_XCTRFUN)
		EndIf

		Aadd(aFieldFill,QSE1->E1_PREFIXO)
		Aadd(aFieldFill,QSE1->E1_TIPO )
		Aadd(aFieldFill,QSE1->E1_NUM )
		Aadd(aFieldFill,QSE1->E1_PARCELA)
		Aadd(aFieldFill,STOD(QSE1->E1_EMISSAO ) )
		Aadd(aFieldFill,STOD(QSE1->E1_VENCTO ) )
		Aadd(aFieldFill,QSE1->E1_VALOR +  QSE1->E1_ACRESC)
		Aadd(aFieldFill,QSE1->E1_SALDO +  QSE1->E1_ACRESC)
		Aadd(aFieldFill,QSE1->COD_ROTA )
		Aadd(aFieldFill,QSE1->DESC_ROTA )
		Aadd(aFieldFill,QSE1->E1_XFORPG)

		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)

		aFieldFill := {}

		nQtTotal++
		nGetTotal += QSE1->E1_VALOR + QSE1->E1_ACRESC
		QSE1->( DbSkip() )

	EndDo

Return( aClone(aColsEx) )

/*/{Protheus.doc} Clique
FunÁ„o chamada no duplo clique da linha do grid
@type function
@version 1.0 
@author Raphael Martins
@since 08/06/2016
@param oObj, object, objeto da gride
@param oGetTotal, object, objeto da totalizador 
@param nGetTotal, numeric, o valor total
@param oQtTotal, object, objeto da quantidade total
@param nQtTotal, numeric, quantidade total de itens marcados
/*/
Static Function Clique(oObj,oGetTotal,nGetTotal,oQtTotal,nQtTotal)

	Local nPosMark	:= aScan(oObj:aHeader,{|x| AllTrim(x[2])== "MARK"})
	Local nPosVlr   := aScan(oObj:aHeader,{|x| AllTrim(x[2])== "E1_VALOR"})

	if oObj:aCols[oObj:nAt][nPosMark] == "CHECKED"
		oObj:aCols[oObj:nAt][nPosMark] 	:= "UNCHECKED"
		nGetTotal -= oObj:aCols[oObj:nAt][nPosVlr]
		nQtTotal--
	else
		oObj:aCols[oObj:nAt][nPosMark] 	:= "CHECKED"
		nGetTotal += oObj:aCols[oObj:nAt][nPosVlr]
		nQtTotal++
	endif

	oGetTotal:Refresh()
	oQtTotal:Refresh()

	oObj:oBrowse:Refresh()

Return(Nil)

/*/{Protheus.doc} MarcaTodos
FunÁ„o chamada pela aÁ„o de clicar no cabeÁalho
dos grids para selecionar todos os checkbox
@type function
@version 1.0
@author Raphael Martins
@since 08/06/2016
@param oObj, object, objeto da gride
@param oGetTotal, object, objeto da totalizador 
@param nGetTotal, numeric, o valor total
@param oQtTotal, object, objeto da quantidade total
@param nQtTotal, numeric, quantidade total de itens marcados
/*/
Static Function MarcaTodos(_obj,oGetTotal,nGetTotal,oQtTotal,nQtTotal)

	Local nX		:= 1
	Local nPosVlr   := aScan(_obj:aHeader,{|x| AllTrim(x[2])== "E1_VALOR"})

	if __XVEZ == "0"
		__XVEZ := "1"
	else
		if __XVEZ == "1"
			__XVEZ := "2"
		endif
	endif

	If __XVEZ == "2"

		nGetTotal := 0
		nQtTotal  := 0

		If _nMarca == 0

			For nX := 1 TO Len(_obj:aCols)
				_obj:aCols[nX][1] := "CHECKED"
				nGetTotal += _obj:aCols[nX][nPosVlr]
				nQtTotal++
			Next

			_nMarca := 1

		Else

			FOR nX := 1 TO LEN(_obj:aCols)
				_obj:aCols[nX][1] := "UNCHECKED"
			Next

			_nMarca := 0

		Endif

		__XVEZ:="0"

		_obj:oBrowse:Refresh()
		oGetTotal:Refresh()
		oQtTotal:Refresh()

	Endif

Return(Nil)

/*/{Protheus.doc} Confirma
Funcao executada no confirma da tela
para geracao dos boletos do titulos
selecionados
@author Raphael Martins
@since 03/06/2016
@version P11
@param
@return nulo
/*/
Static Function Confirma(oSay,oDlg,oGrid,cBanco,cAgencia,cConta,nTipoImp,nQuebra,oGetTotal,nGetTotal,oQtTotal,nQtTotal,nQtdBol,nExcel,nCustomizado)

	Local nPosMark	 				:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])=="MARK"})
	Local nPosCli	 				:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])=="A1_COD"})
	Local nPosLoja	 				:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])=="A1_LOJA"})
	Local nPosNoCli	 				:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])=="A1_NOME"})
	Local nPosPref   				:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])=="E1_PREFIXO"})
	Local nPosTipo   				:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])=="E1_TIPO"})
	Local nPosTit    				:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])=="E1_NUM"})
	Local nPosParc   				:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])=="E1_PARCELA"})
	Local nItemMark  				:= aScan(oGrid:aCols,{|x| AllTrim(x[nPosMark])=="CHECKED"})
	Local nPosVenc   				:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])=="E1_VENCTO"})
	Local nPosEmi    				:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])=="E1_EMISSAO"})
	Local nPosValor  				:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])=="E1_VALOR"})
	Local nPosContra 				:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])=="E1_XCONTRA"})
	Local nPosRota					:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])=="U34_CODIGO"})
	Local nPosDescR					:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])=="U34_DESCRI"})
	Local nPosForPg					:= aScan(oGrid:aHeader,{|x| AllTrim(x[2])=="E1_XFORPG"})
	Local cCliente	 				:= ""
	Local cLoja		 				:= ""
	Local cPrefixo   				:= ""
	Local cTitulo	 				:= ""
	Local cParcela 	 				:= ""
	Local cTipo 	 				:= ""
	Local cCliLoja   				:= ""
	Local cContAtu   				:= ""
	Local cRota						:= ""
	Local cDescRota					:= ""
	Local cForPagto					:= ""
	Local cCodigoProt				:= ""
	Local lAtEmail					:= SuperGetMV("MV_XBOLEMA",,.F.)
	Local lPadBolInternoPadrao		:= SuperGetMv("MV_XIMPBPA",.F.,.F.)
	Local lGeraCar					:= SuperGetMV("MV_XPROTOC",,.T.)
	Local cTipoRJ					:= SuperGetMv("MV_XTRJFUN",.F.,"RJ")
	Local dRefIni	 				:= STOD("")
	Local dRefFim	 				:= STOD("")
	Local lRet       				:= .T.
	Local lCarn		 				:= .F.
	Local lNovosCarne				:= .T.
	Local nCarne     				:= 1
	Local nX         				:= 0
	Local nItem		 				:= 1
	Local nTotMark	 				:= 0
	Local nTotImp	 				:= 0
	Local nOpcaoProt				:= 0
	Local nTamCliente				:= 0
	Local nTamLoja					:= 0
	Local aDados	 				:= {}
	Local aItem		 				:= {}
	Local aItens     				:= {}
	Local aCabec	 				:= {}
	Local aClientes 				:= {}
	Local lEnvMail	 				:= .F.
	Local lExistProt				:= .F.
	Local lPCPGR028					:= ExistBlock("PCPGR028")
	Local lRCPGR028					:= ExistBlock("RCPGR028")

	//Ordena por Cliente + Vencimento
	ASORT(oGrid:aCols,,,{|x, y| x[nPosMark]+x[nPosCli]+x[nPosLoja]+x[nPosContra]+DTOS(x[nPosVenc]) < y[nPosMark]+y[nPosCli]+y[nPosLoja]+y[nPosContra]+DTOS(y[nPosVenc]) }) //ordenaÁ„o crescente
	aEval(oGrid:aCols,{|e| If(e[nPosMark] =='CHECKED',nTotMark++,0)})

	If nTotMark > 0

		//para enviar boleto por e-mail sera necessario ativar o parametro MV_XBOLEMA
		If nExcel == 1 .And. lAtEmail .And. MsgYesNo("Deseja enviar os boletos por e-mail?")

			lEnvMail := .T.
			lGeraCar := .F. //Quando o envio for por e-mail nao gera protocolo
			nQuebra	 := 1   //Envio por e-mail quebra pagina por cliente

			//para utilizar o controle de carne o parametro MV_XPROTOC deve estar ativado
		ElseIf nExcel == 1 .And. lGeraCar .And. !MsgYesNo("Deseja Realizar a GeraÁ„o de CarnÍs para os boletos a serem impressos?")

			lGeraCar := .F.

		EndIf

		// funÁ„o para validacao das informacoes de banco
		if ValidaBanco(cBanco,cAgencia,cConta)

			For nX := 1 To Len(oGrid:aCols)

				If oGrid:aCols[nX][nPosMark] == 'CHECKED'

					BEGIN TRANSACTION
				
					cCliente 	:= oGrid:aCols[nX][nPosCli]
					cLoja	 	:= oGrid:aCols[nX][nPosLoja]
					cNomeCli 	:= oGrid:aCols[nX][nPosNoCli]
					cPrefixo 	:= oGrid:aCols[nX][nPosPref]
					cTitulo	 	:= oGrid:aCols[nX][nPosTit]
					cParcela 	:= oGrid:aCols[nX][nPosParc]
					cTipo	 	:= oGrid:aCols[nX][nPosTipo]
					cContAtu 	:= oGrid:aCols[nX][nPosContra]
					cRota	 	:= oGrid:aCols[nX][nPosRota]
					cDescRota	:= oGrid:aCols[nX][nPosDescR]
					cForPagto	:= oGrid:aCols[nX][nPosForPg]

					oSay:cCaption := ("Gerando Boletos do Contrato: " + Alltrim( cContAtu ) + " Parcela: " + Alltrim(cParcela) + " ")
					ProcessMessages()

					If Empty(cCliLoja)

						cCliLoja   := oGrid:aCols[nX][nPosCli] + oGrid:aCols[1][nPosLoja]
						dRefIni	   := oGrid:aCols[nX][nPosVenc]
						cContrato  := oGrid:aCols[nX][nPosContra]
						Aadd(aClientes,{cCliente,cLoja,cContrato})

					EndIf

					aRetorno := U_RCPGR006(cCliente, cLoja, cPrefixo, cTitulo, cParcela, cTipo,cBanco,cAgencia,cConta,cRota,cDescRota)

					// valido se gerou os dados do boleto corretamente
					If aRetorno[1]

						//valido se houve impressao de reajutes, o carne nao sera completo, sera apenas para boletos
						if lNovosCarne .And. Alltrim(cTipo) == cTipoRJ
							lNovosCarne := .F.
						endif

						///gera carnes apenas para impressoa em tela
						if nExcel == 1

							If cCliLoja+cContrato <> cCliente+cLoja+cContAtu

								//adiciono o cliente para impressao dos dados em excel
								Aadd(aClientes,{cCliente,cLoja,cContAtu})

									//realiza a geracao dos carnes
									if lGeraCar .And. Len( aItens ) > 0 .And. nTotMark <> nTotImp

										aAdd( aCabec, {'U32_REFFIM'    , dRefFim } )
										aAdd( aCabec, {'U32_BOLETO'    , .T. } )

										if lNovosCarne

											aAdd( aCabec, {'U32_GUIA'    , .T. } )
											aAdd( aCabec, {'U32_CARTE'   , .T. } )

										else

											aAdd( aCabec, {'U32_GUIA'    , .F. } )
											aAdd( aCabec, {'U32_CARTE'   , .F. } )

										endif

										//realizo a inclusao do carne
										GeraProtocolo(aCabec,aItens)

										//reseto variaveis com os dados do carne
										aCabec		:= {}
										aItens		:= {}
										lNovosCarne	:= .T.
										nItem		:= 1
										nCarne++

									endIf

									cCliLoja   := cCliente+cLoja
									dRefIni	   := oGrid:aCols[nX][nPosVenc]
									dRefFim	   := oGrid:aCols[nX][nPosVenc]
									cContrato  := oGrid:aCols[nX][nPosContra]

								EndIf

								If lGeraCar

									// valido se o boleto ja esta possui protocolo vinculado ao mesmo
									ValidCarne(cCliente, cLoja , cNomeCli, cPrefixo , cTitulo , cParcela , cTipo , nExcel , @nOpcaoProt , @lExistProt )

									//valido se gera protocolo
									if !lExistProt .Or. nOpcaoProt == 2 .Or. nOpcaoProt == 3

										If Len(aCabec) == 0

											//tamanho dos campos de cliente e loja
											nTamCliente 	:= TamSX3("U32_CLIENT")[1]
											nTamLoja		:= TamSX3("U32_LOJA")[1]

											cCodigoProt		:= U_RCPGA28A()

											aAdd( aCabec, {'U32_FILIAL'    	, xFilial("U32") } )
											aAdd( aCabec, {'U32_CODIGO'    	, cCodigoProt } )
											aAdd( aCabec, {'U32_DATA'		, dDataBase } )
											aAdd( aCabec, {'U32_CONTRA'    	, cContrato  } )
											aAdd( aCabec, {'U32_CLIENT'    	, SubStr(cCliLoja,1,nTamCliente) } )
											aAdd( aCabec, {'U32_LOJA'      	, SubStr(cCliLoja,nTamCliente + 1 , nTamLoja ) } )
											aAdd( aCabec, {'U32_REFINI'    	, dRefIni } )
											aAdd( aCabec, {'U32_CODROT'   	, cRota } )
											aAdd( aCabec, {'U32_STATUS'   	, "1" } )

										EndIf

										aItem := {}

										aAdd( aItem, {'U33_FILIAL', xFilial("U33")			   })
										aAdd( aItem, {'U33_CODIGO', cCodigoProt				   })
										aAdd( aItem, {'U33_CLIENT', oGrid:aCols[nX][nPosCli]   })
										aAdd( aItem, {'U33_LOJA'  , oGrid:aCols[nX][nPosLoja]  })
										aAdd( aItem, {'U33_EMISS' , oGrid:aCols[nX][nPosEmi]   })
										aAdd( aItem, {'U33_VENCTO', oGrid:aCols[nX][nPosVenc]  })
										aAdd( aItem, {'U33_PREFIX', oGrid:aCols[nX][nPosPref]  })
										aAdd( aItem, {'U33_NUM'   , oGrid:aCols[nX][nPosTit]   })
										aAdd( aItem, {'U33_PARCEL', oGrid:aCols[nX][nPosParc]  })
										aAdd( aItem, {'U33_TIPO'  , oGrid:aCols[nX][nPosTipo]  })
										aAdd( aItem, {'U33_VALOR' , oGrid:aCols[nX][nPosValor] })

										dRefFim	:= oGrid:aCols[nX][nPosVenc]

										aAdd( aItens, aItem )

										nItem++

										lCarn := .T. //ao menos um carnÍ sera gerado

									endIf

								endif

								aAdd(aDados,{aClone(aRetorno[2]),nCarne,dRefIni,dRefFim} )

								nTotImp++

							endif

					Else

						Aviso( "", "O Boleto do Cliente:"+cCliente+"/"+cLoja+" - "+Alltrim(oGrid:aCols[nX][nPosNoCli])+" Titulo: "+Alltrim(cTitulo)+"/"+Alltrim(cParcela)+;
								" n„o foi gerado com sucesso, verifique os dados do titulo ", {"Ok"} )
					EndIf

					oGrid:aCols[nX][nPosMark] := 'UNCHECKED'

					lExistProt	:= .F.

					END TRANSACTION

				else

					Exit

				EndIf

			Next nX

			If Len(aItens) > 0

				aAdd( aCabec, {'U32_REFFIM'    , dRefFim } )
				aAdd( aCabec, {'U32_BOLETO'    , .T. } )

				if lNovosCarne

					aAdd( aCabec, {'U32_GUIA'    , .T. } )
					aAdd( aCabec, {'U32_CARTE'   , .T. } )

				else

					aAdd( aCabec, {'U32_GUIA'    , .F. } )
					aAdd( aCabec, {'U32_CARTE'   , .F. } )

				endif

				//gero protocoloco de entrega
				GeraProtocolo(aCabec,aItens)

			EndIf

			//realizo a impressao do boleto
			if Len( aDados ) > 0 .And. nExcel == 1

				if cBanco == "999" // quando for impressao de carne proprio

					/////////////////////////////////////////////////////////////////////
					////// PONTOS DE ENTRADA PARA PERSONALIZACAO DO BOLETO INTERNO 	/////
					/////////////////////////////////////////////////////////////////////
					If lPCPGR028.And. nCustomizado <> 2

						FWMsgRun(,{|oSay| U_PCPGR028(aDados) },'Aguarde...','Realizando a impress„o dos boletos..')

						// verifico se a impressao de boleto interno esta compilada, so realizo a impressao do padrao caso o
						// ponto de entrada n„do esteja compilado ou o parametro MV_XIMPBPA esteja ativo
					elseIf lRCPGR028 .And. lPadBolInternoPadrao

						FWMsgRun(,{|oSay| U_RCPGR028(aDados,lCarn,nQuebra,lEnvMail,nQtdBol) },'Aguarde...','Realizando Impressao do CarnÍ dos tÌtulos Selecionados...')

					else

						MsgAlert("Impress„o de carnÍ proprio n„o habilitada!")

					endIf

				else// quando for impressao de boleto

					//
					// PCPGR001 - Ponto de Entrada para substituir a funÁ„o de impress„o de boleto (relatÛrio gr·fico)
					//
					If ExistBlock("PCPGR001")
						FWMsgRun(,{|oSay| ExecBlock("PCPGR001",.F.,.F.,{aDados,lCarn,.T.,CTOD(""),CTOD(""),nQuebra,lEnvMail,nQtdBol}) },'Aguarde...','Realizando a impress„o dos boletos..')
					Else
						FWMsgRun(,{|oSay| U_RCPGR001(aDados,lCarn,,,,nQuebra,lEnvMail,nQtdBol) },'Aguarde...','Realizando Impressao dos Boletos Selecionados...')
					EndIf

				endIf

			elseif nExcel == 2 //Gera Excel

				FWMsgRun(,{|oSay| U_RUTILE06(aDados) },'Aguarde...','Gerando planilha dos Boletos Selecionados...')

			endif

			oGrid:Refresh()

			If nExcel == 1 .And. Len(aClientes) > 0 .And. MsgYesNo("Deseja exportar os dados do(s) cliente(s) do(s) boleto(s) para excel?")

				MsAguarde( {|| ExpExcel(aClientes) }, "Aguarde", "Exportando para Excel os dados dos clientes!...", .F. )

			endif

			nQtTotal := 0
			nGetTotal:= 0

			oGetTotal:Refresh()
			oQtTotal:Refresh()

		endIf

	Else
		lRet := .F.
		Aviso( "", "Marque pelo menos um contato para geraÁ„o dos Boletos Bancarios!", {"Ok"} )
	EndIf

Return(lRet)

/*/{Protheus.doc} ValidCarne
Valida se o Boleto ja esta vinculado
ao CarnÍ
@author Raphael Martins
@since 24/03/2016
@version 1.0
@Param
/*/
Static Function ValidCarne(cCliente,cLoja,cNomeCli,cPrefixo,cTitulo,cParcela,cTipo,nExcel,nOpcaoProt, lExistProt)

	local aArea		:= getArea()
	Local aAreaSE1  := SE1->( GetArea() )
	Local nOpcao    := 0
	Local aOpcoes	:= {"N„o", "Sim p/ Todos","Sim","N„o p/ todos"}
	Local cQry      := ""

	cQry := " SELECT
	cQry += " U33_CODIGO COD_CARNE "
	cQry += " FROM "
	cQry += RetSQLName("U33") +" U33 (NOLOCK) "
	cQry += " INNER JOIN "
	cQry += RetSQLName("U32") +" U32  (NOLOCK) "
	cQry += " ON U32.D_E_L_E_T_ = ' '
	cQry += " AND U33.D_E_L_E_T_ = ' ' "
	cQry += " AND U33.U33_FILIAL = U32.U32_FILIAL "
	cQry += " AND U33.U33_CODIGO = U32.U32_CODIGO "
	cQry += " WHERE "
	cQry += "	U33.U33_FILIAL	= '"+xFilial("U33")+"' "
	cQry += "	AND U33_CLIENT	= '" + cCliente + "' "
	cQry += "	AND U33_LOJA	= '" + cLoja + "' "
	cQry += "	AND U33_PREFIX	= '" + cPrefixo + "' "
	cQry += "	AND U33_NUM		= '" + cTitulo + "' "
	cQry += " 	AND U33_PARCEL	= '" + cParcela + "' "
	cQry += "	AND U33_TIPO	= '" + cTipo + "' "
	cQry += "	AND U32_STATUS	<> '3' " //Nao Recebido
	cQry += " ORDER BY U33_CODIGO "

	If Select("QU33") > 0
		QU33->( DbCloseArea() )
	EndIf

	cQry := ChangeQuery(cQry)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QU33",.F.,.F.)

	QU33->( DbGotop() )

	If nExcel == 1 .And. !Empty( QU33->COD_CARNE )

		//sinalizo que existe protocolo para o boleto consultado
		lExistProt := .T.

		//mostro a mensagem caso a opcao ja selecionada seja diferente de Sim P/ todos ou Nao P/ Todos
		if nOpcaoProt <> 2 .And. nOpcaoProt <> 4

			nOpcaoProt := Aviso("AtenÁ„o!","O Boleto: "+Alltrim(cTitulo)+"/"+cParcela+" do Cliente:"+Alltrim(cCliente+cLoja) +"/"+Alltrim(cNomeCli)+;
				" j· se encontra vinculado ao carnÍ: "+Alltrim(QU33->COD_CARNE)+", deseja vincular o mesmo a este carnÍ?", aOpcoes, 3)
		endif

	endif

	restArea( aAreaSE1 )
	restArea( aArea )

Return()

/*
SIM = 3
SIM P/ TODOS = 2
NAO = 1
NAO PARA TODOS = 4
*/

/*/{Protheus.doc} RCPGA24A
Funcao para realizar a impressao do
boleto a partir da tela de painel
financeiro do Contrato
@author Raphael Martins
@since 24/06/2016
@version P11
@param
Private aCabec		:= {"","","Filial","Tipo","DescriÁ„o","Prefixo","N˙mero","Parcela","Natureza","Portador","Depositaria","Num da Conta",;
"Nome Banco","Cliente","Loja","Nome","Dt. Emiss„o","Dt. Vencimento","Valor","Saldo","Desconto","Multa","Juros",;
"AcrÈscimo","DecrÈscimo","Fatura","R_E_C_N_O_","Parc.Titulo"}
@return nulo
/*/
User Function RCPGA24A(cContrato,aTitulosPnl)

	Local oPrinter
	Local nPosMark	 := 1
	Local nX 		 := 0
	Local nItem		 := 0
	Local dRefIni	 := CTOD("")
	Local dRefFim	 := CTOD("")
	Local nPosCli	 := 14
	Local nPosLoja	 := 15
	Local nPosPref   := 6
	Local nPosTipo   := 4
	Local nPosTit    := 7
	Local nPosParc   := 27
	Local nPosVencto := 18
	Local nPosEmi	 := 17
	Local nPosValor	 := 20
	Local nPosBanco	 := 10
	Local nPosAgencia:= 11
	Local nPosConta	 := 12
	Local cTipoPar	 := ""
	Local cNomeCli   := ""
	Local cCodCarne	 := ""
	Local cBancoTit	 := ""
	Local cAgenciTit := ""
	Local cContaTit	 := ""
	Local cMensagem	 := ""
	Local lCemiterio := SuperGetMV("MV_XCEMI",,.F.)
	Local lFuneraria := SuperGetMV("MV_XFUNE",,.F.)
	Local lImpBolPnl := SuperGetMV("MV_XBOLPNL",,.F.)
	Local lMVEscbco  := SuperGetMV("MV_XESCBCO",.F.,.T.)
	Local aBolPar 	 := {}
	Local aBolMnt	 := {}
	Local aRetorno	 := {}
	Local aItem		 := {}
	Local aItens	 := {}
	Local aCabec 	 := {}
	Local aClientes  := {}
	Local aArray	 := aClone(aTitulosPnl)
	Local lImpBol	 := .F.
	Local lBolInt	 := .F.
	Local cFormaPgto := ""
	Local lPCPGR028	 := ExistBlock("PCPGR028")

	// decide qual a conta sera gerado o boleto
	If lMVEscbco
		U_RCPGR005(.T.)
	EndIf

	// verifico se estou utilizando as rotinas de funeraria
	If lFuneraria

		// vejo se o campo forma de pagamento existe
		if UF2->( FieldPos("UF2_FORPG") ) > 0
			cFormaPgto := UF2->UF2_FORPG
		EndIF

	ElseIf lCemiterio // para cemiterio

		// vejo se o campo forma de pagamento existe
		If U00->( FieldPos("U00_FORPG") ) > 0
			cFormaPgto := U00->U00_FORPG
		EndIf

		cPrefPar := Alltrim(SuperGetMv("MV_XPREFCT",.F.,"CTR")) //Prefixo de Titulo de Parcela
		cTipoPar := Alltrim(SuperGetMv("MV_XTIPOCT",.F.,"CT"))  //Tipo de Titulo de Parce

	EndIf

	// verifico se o alias existe no dicionario
	If !Empty( AllTrim( FWSX2Util():GetPath( "U60" ) ) )

		// verifico a forma de pagamento na recorrencia
		U60->(DbSetOrder(2))
		If U60->(DbSeek(xFilial("U60")+cFormaPgto)) .AND. U60->U60_STATUS == "A"

			MsgAlert("Forma de Pagamento do contrato esta vinculada a Assinatura."+CRLF+"Boleto n„o È permitido!")
			Return

		EndIf

	EndIf

	// Novo Painel Financeiro
	If IsInCallStack("U_RUTILE46")
		nPosPref := 2
		nPosTit := 3
		nPosParc := 4
		nPosTipo := 5
		nPosCli := 6
		nPosLoja := 7
		nPosBanco := 8
		nPosAgencia := 9
		nPosConta := 10
	EndIf

	//cliente posicionado no painel
	cCliente   := aArray[1][nPosCli]
	cLoja      := aArray[1][nPosLoja]

	If Len(aArray) > 0

		For nX := 1 To Len(aArray)

			If aArray[nX][1]

				lImpBol		:= .T.
				cCliente   	:= aArray[nX][nPosCli]
				cLoja      	:= aArray[nX][nPosLoja]
				cPrefixo   	:= aArray[nX][nPosPref]
				cTitulo    	:= aArray[nX][nPosTit]
				cParcela 	:= SubStr(aArray[nX][nPosParc],1,TamSX3("E1_PARCELA")[1])
				cTipo		:= aArray[nX][nPosTipo]
				cBancoTit  	:= aArray[nX][nPosBanco]
				cAgenciaTit	:= aArray[nX][nPosAgencia]
				cContaTit	:= aArray[nX][nPosConta]
				cNomeCli   	:= RetField("SA1",1,xFilial("SA1")+aArray[nX][nPosCli]+aArray[nX][nPosLoja],"A1_NOME")

				//nao permito imprimir boleto proprio com boleto bancario
				if cBancoTit == "999"

					lBolInt := .T.

				elseif lBolInt

					Help( ,, 'Help - Boletos',,'N„o È possivel imprimir boletos bancarios com boletos internos!' + chr(13)+ chr(10) + cMensagem , 1, 0 )
					aBolPar := {}
					Exit

				endif

				//valido se o titulo possui portador definido ou se a geracao de boletos pelo painel esta ativa
				if lImpBolPnl .Or. !Empty(cBancoTit)

					aRetorno := {}

					aRetorno := U_RCPGR006(cCliente, cLoja, cPrefixo, cTitulo, cParcela, cTipo, cBancoTit, cAgenciaTit , cContaTit )

					If Len(aRetorno) > 0 .And. aRetorno[1]
						aAdd(aBolPar,{aClone(aRetorno[2]),1,dRefIni,dRefFim} )
					EndIf
				else
					//titulos que nao foram impressos
					cMensagem	+= "Prefixo: "		+ cPrefixo
					cMensagem	+= " - N˙mero: "	+ cTitulo
					cMensagem	+= " - Parcela: "	+ cParcela
					cMensagem	+= " - Tipo: "		+ cTipo
					cMensagem	+= chr(13)+ chr(10)
				endif

			EndIf

		Next nX

		If Len(aBolPar) > 0

			//valido o banco selecionado
			if aBolPar[1,1,1,1,1] == "999"
				lBolInt := .T.
			endif

			//valido se imprimo boleto proprio ou boleto bancario
			if !lBolInt

				//
				// PCPGR001 - Ponto de Entrada para substituir funÁ„o de impress„o de boleto (relatÛrio gr·fico)
				//
				If ExistBlock("PCPGR001")
					FWMsgRun(,{|oSay| oPrinter := ExecBlock("PCPGR001",.F.,.F.,{aBolPar,.F.,.T.,dRefIni,dRefFim,2,.F.,3}) },'Aguarde...','Realizando a impress„o dos boletos..')
					If ValType( oPrinter ) == "O"
						oPrinter:EndPage()
					EndIf
				Else
					FWMsgRun(,{|oSay| oPrinter := U_RCPGR001(aBolPar,.F.,.T.,dRefIni,dRefFim) },'Aguarde...','Realizando a impress„o dos boletos..')
					oPrinter:EndPage()
				EndIf

			else

				// verifico se existe o ponto de entrada de impressao de boleto interno customizado
				If ExistBlock("PCPGR028")
					FWMsgRun(,{|oSay| U_PCPGR028(aBolPar) },'Aguarde...','Realizando a impress„o dos boletos..')
				else
					FWMsgRun(,{|oSay| U_RCPGR028(aBolPar,.F.,,,,2,.F.,3) },'Aguarde...','Realizando a impress„o dos boletos..')
				endIf

			endif

			If MsgYesNo("Deseja exportar os dados do(s) cliente(s) do(s) boleto(s) para excel?")

				Aadd(aClientes,{cCliente,cLoja,cContrato})

				MsAguarde( {|| ExpExcel(aClientes) }, "Aguarde", "Exportando para Excel os dados dos clientes!...", .F. )
			EndIf

		EndIf

		if !Empty(cMensagem)
			Help( ,, 'Help - Boletos',,;
				'O Titulos abaixo n„o ser„o reimpressos, devem ser gerados pela rotina de impress„o de boleto!.' + chr(13)+ chr(10) + cMensagem , 1, 0 )
		endif

	EndIf

	//valido se foi marcado ao menos um item da grid
	if !lImpBol
		Aviso( "", "Marque pelo menos um titulo para geraÁ„o dos Boletos Bancarios!", {"Ok"} )
	endif

Return()
/*/{Protheus.doc} ExpExcel
Funcao para realizar a exportaÁ„o dos
dados do(s) cliente(s) para excel
@author Raphael Martins
@since 04/07/2016
@version P11
@param
@return nulo
/*/
Static Function ExpExcel(aClientes,oSay)

	Local oExcel
	Local cSaveFile  := ""
	Local nHandle 	 := 0
	Local nX 		 := 0
	Local aCabec 	 := {}
	Local aItens	 := {}
	Local aAreaSA1   := SA1->( GetArea() )
	Local lRet		 := .T.

	Default oSay	:= NIL

	cSaveFile := cGetFile( '*.xls' , 'Selecione o diretÛrio', 16, , .F.,GETF_LOCALHARD,.F., .T. )

	DbSelectArea("CC2")
	CC2->( DbSetOrder(1) )//CC2_FILIAL + CC2_EST+CC2_CODMUN

	SA1->( DbSetOrder(1) ) //A1_FILIAL+A1_COD+A1_LOJA
	If !Empty(cSaveFile)

		nHandle := MsfCreate(cSaveFile,0) //Cria Arquivo

		If nHandle > - 1

			oExcel 	 := FWMSEXCEL():New()

			oExcel:AddworkSheet("Clientes")
			oExcel:AddTable ("Clientes","Clientes")

			oExcel:AddColumn("Clientes","Clientes","Contrato",1,1)
			oExcel:AddColumn("Clientes","Clientes","Codigo/Loja",1,1)
			oExcel:AddColumn("Clientes","Clientes","Nome",1,1)
			oExcel:AddColumn("Clientes","Clientes","EndereÁo CobranÁa",1,1)
			oExcel:AddColumn("Clientes","Clientes","Cidade",1,1)
			oExcel:AddColumn("Clientes","Clientes","Estado",1,1)
			oExcel:AddColumn("Clientes","Clientes","Fone",1,1)

			For nX := 1 To Len(aClientes)

				If SA1->( DbSeek( xFilial("SA1") + aClientes[nX][1]+aClientes[nX][2] ) )

					if oSay <> NIL
						oSay:cCaption := ("Exportando Dados do Cliente: " + Alltrim(SA1->A1_COD) + " / " + Alltrim( SA1->A1_LOJA ) + " ")
						ProcessMessages()
					endif

					cMunic := Alltrim(SA1->A1_COD_MUN)+"/"+Alltrim(RetField("CC2",1,xFilial("CC2")+SA1->A1_EST+SA1->A1_COD_MUN,"CC2_MUN"))

					cFone  := If(!Empty(SA1->A1_DDD),Alltrim(StrTran(SA1->A1_DDD,"0","")),"")+SA1->A1_TEL

					//valido se possui telefone celular, caso nao possua pega o A1_TEL
					if !Empty(SA1->A1_XCEL)

						cFone  := If(!Empty(SA1->A1_XDDDCEL),Alltrim(StrTran(SA1->A1_XDDDCEL,"0","")),"")+SA1->A1_XCEL
					else

						cFone  := If(!Empty(SA1->A1_DDD),Alltrim(StrTran(SA1->A1_DDD,"0","")),"")+SA1->A1_TEL

					endif

					oExcel:AddRow("Clientes","Clientes",{aClientes[nX][3],;
						aClientes[nX][1]+"/"+aClientes[nX][2],;
						SA1->A1_NOME,;
						SA1->A1_ENDCOB,;
						cMunic,;
						SA1->A1_EST,;
						cFone})
				EndIf

			Next nX

			oExcel:Activate()
			oExcel:GetXMLFile(cSaveFile+".XML")
			ShellExecute("Open", cSaveFile+".XML", " ", "C:\", SW_SHOWNORMAL )
			fClose(cSaveFile)

		Else
			lRet := .F.
			Aviso( "", "N„o foi possivel a criaÁ„o do arquivo no local especificado!", {"Ok"} )
		EndIf

	EndIf

	RestArea(aAreaSA1)

Return(lRet)

/*/{Protheus.doc} SX1RCPG
// Cria a tela de perguntas da
funcao de exportaÁ„o para excel
@author Raphael Martins Garcia
@since 04/07/2016
@version undefined

@type function
/*/
Static Function SX1RCPG(cPerg1)

	Local aHelpPor	:= {}
	Local aHelpEng	:= {}
	Local aHelpSpa	:= {}
	Local cF3		:= ""

	U_xPutSX1( cPerg1, "01","Do Cliente ?                 ","","","mv_ch1","C",6,0,0,"G",'',"SA1","","",;
		"mv_par01","","","","","","","","","","","","","","","","",;
		{'Informe o cÛdigo inicial dos clientes','s a serem processados.                  '},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg1, "02","Ate o Cliente ?              ","","","mv_ch2","C",6,0,0,"G",'',"SA1","","",;
		"mv_par02","","","","ZZZZZZ","","","","","","","","","","","","",;
		{'Informe o cÛdigo final dos clientes a ','serem processados.                      '},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg1, "03","Da Loja ?                 ","","","mv_ch3","C",2,0,0,"G",'',"","","",;
		"mv_par03","","","","","","","","","","","","","","","","",;
		{'Informe o cÛdigo inicial das lojas','s a serem processados.                  '},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg1, "04","Ate a Loja ?              ","","","mv_ch4","C",2,0,0,"G",'',"","","",;
		"mv_par04","","","","ZZ","","","","","","","","","","","","",;
		{'Informe o cÛdigo final das lojas a ','serem processados.                      '},aHelpEng,aHelpSpa)

	cF3 := If(cPerg1=='RCPG024C','U00','UF2')

	U_xPutSX1( cPerg1, "05","Do Contrato  ?                 ","","","mv_ch5","C",6,0,0,"G",'',cF3,"","",;
		"mv_par05","","","","","","","","","","","","","","","","",;
		{'Informe o cÛdigo inicial dos contratos a',' serem processados.                     '},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg1, "06","Ate o Contrato  ?              ","","","mv_ch6","C",6,0,0,"G",'',cF3,"","",;
		"mv_par06","","","","ZZZZZZ","","","","","","","","","","","","",;
		{'Informe o cÛdigo final dos contratos a s','erem processados.                       '},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg1, "07","Cons. da Data de Vencimento?           ","","","mv_ch7","D",8,0,0,"G","","","","",;
		"mv_par07","","","","","","","","","","","","","","","","",;
		{'Informe a data inicial de emiss„o dos titu','los a serem processados.            '},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg1, "08","AtÈ a Data ?                  ","","","mv_ch8","D",8,0,0,"G","(MV_PAR08 >= MV_PAR07)","","","",;
		"mv_par04","","","","","","","","","","","","","","","","",;
		{'Informe a data final de emiss„o dos titu','los a serem processados.              '},aHelpEng,aHelpSpa)

	U_xPutSX1( cPerg1, "09","Status ?                  ","","","mv_ch9","C",8,0,0,"C","","","","",;
		"mv_par04","Ambos","","","","Em Aberto","","","Baixado","","","","","","","","",;
		{'Informe o status dos Titu','los a serem processados.              '},aHelpEng,aHelpSpa)

Return

/*/{Protheus.doc} RCPGA24C
Funcao de Envio de Email dos Boletos
selecionados na Tela
@author Raphael Martins Garcia
@since 04/07/2016
@version undefined

@type function
/*/
User Function RCPGA24C(aEnvMail,oPrinter)

	Local nX 		 := 0
	Local cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	Local cCliente 	 := ""
	Local cNomeCli	 := ""
	Local cDirFile	 := ""
	Local cEmail	 := ""

	For nX := 1 To Len(aEnvMail)

		cDirFile := cStartPath + "\" + aEnvMail[nX][1] + ".html"
		cCliente := aEnvMail[nX][1]
		If oPrinter:SaveAsHTML( cDirFile , {aEnvMail[nX][2],aEnvMail[nX][3]} )

			cEmail   :=  RetField("SA1",1,xFilial("SA1")+cCliente,"A1_EMAIL")
			If !Empty(cEmail)
				oMail := LSendMail():New(cEmail, "Boleto Bancario Vale do Cerrado "+dtoc(date())+' '+time(), "INSEIR TEXTO DE ACORDO COM O DEFINIDO PELA VALE!")
				oMail:SetShedule(.T.)
				oMail:SetAttachment(cDirFile)
				oMail:Send()
			EndIf
			Ferase(cDirFile) //Deleta arquivo do servidor
		Else
			cCliente  := aEnvMail[nX][1]
			cNomeCli  := RetField("SA1",1,xFilial("SA1")+cCliente,"A1_NREDUZ")
			MsgAlert("N„o foi possivel criar o boleto do cliente:"+Alltrim(cCliente)+"/"+Alltrim(cNomeCli)+", verifique suas permissıes no servidor do sistema! ")
		EndIf

	Next nX

Return()

/*/{Protheus.doc} GeraProtocolo
Funcao para Gerar Protocolo dos titulos
selecionados na Tela
@author Raphael Martins Garcia
@since 20/08/2019
@type function
/*/
Static Function GeraProtocolo(aCabec,aItens)

	Local aArea		:= GetArea()
	Local aAreaU32	:= U32->(GetArea())
	Local aAreaSE1	:= SE1->(GetArea())
	Local nX		:= 0
	Local nI		:= 0
	Local lRet		:= .T.

	DbSelectArea("U32")

	//incluo o cabecalho do protocolo gerado
	RecLock("U32",.T.)

	For nX := 1 To Len(aCabec)

		cNomeCampo		:= aCabec[nX,1]
		cConteudoCpo	:= aCabec[nX,2]
		nPosCampo		:= FieldPos(cNomeCampo)

		FieldPut(nPosCampo,cConteudoCpo)

	Next nX

	U32->(MsUnlock())

	U32->(ConfirmSX8()) // confirmo o uso da numeracao

	//incluo os titulos do protocolo gerado
	For nX := 1 To Len(aItens)

		DbSelectArea("U33")

		RecLock("U33",.T.)

		For nI := 1 To Len(aItens[nX])

			cNomeCampo		:= aItens[nX,nI,1]
			cConteudoCpo	:= aItens[nX,nI,2]
			nPosCampo		:= FieldPos(cNomeCampo)

			FieldPut(nPosCampo,cConteudoCpo)

		Next nI

		U33->(MsUnlock())

	Next nX

	RestArea(aArea)
	RestArea(aAreaU32)
	RestArea(aAreaSE1)

Return(lRet)

/*/{Protheus.doc} RCPG024B
Funcao para realizar a exportaÁ„o dos 
dados do(s) cliente(s) para excel 
a partir da tela de contrato
@type function
@version 1.0  
@author Raphael Martins
@since 04/07/2016
/*/
User Function RCPG024B()

	FWMsgRun(,{|oSay| DadosCliExcel(oSay) },'Aguarde...','Carregando Dados para ExportaÁ„o...')

Return(Nil)

/*/{Protheus.doc} DadosCliExcel
Funcao para gerar os dados em excel.
@type function
@version 1.0 
@author totvs
@since 04/07/2016
@param oSay, object, objeto da label do processamento
/*/
Static Function DadosCliExcel(oSay)

	Local cPerg1          := "RCPG024C"
	Local cQry 			  := ""
	Local cPulaLinha	  := CRLF
	Local aClientes		  := {}
	Private cClienteDe    := ""
	Private cClieteAte    := ""
	Private cLojaDe 	  := ""
	Private cLojaAte 	  := ""
	Private cCtrCemitDe	  := ""
	Private cCtrCemitAte  := ""
	Private cCtrFunDe	  := ""
	Private cCtrFunAte	  := ""
	Private cMod		  := ""
	Private dVencDe 	  := CTOD("")
	Private dVencAte 	  := CTOD("")
	Private nStatus 	  := 0

	cMod := U_RetModul()

	If cMod == "FUN"
		cPerg1 := "RCPG024F"
	EndIf

	SX1RCPG(cPerg1)

	If Pergunte(cPerg1,.T.)

		cClienteDe    := MV_PAR01
		cClieteAte    := MV_PAR02
		cLojaDe 	  := MV_PAR03
		cLojaAte 	  := MV_PAR04

		cCtrCemitDe   := MV_PAR05
		cCtrCemitAte  := MV_PAR06
		cCtrFunDe     := MV_PAR05
		cCtrFunAte	  := MV_PAR06

		dVencDe 	  := MV_PAR07
		dVencAte 	  := MV_PAR08
		nStatus 	  := MV_PAR09

		cQry := " SELECT DISTINCT "                                                                             + cPulaLinha
		cQry += " E1A.E1_CLIENTE CLIENTE, "                                                                     + cPulaLinha
		cQry += " E1A.E1_LOJA LOJA , "                                                                          + cPulaLinha
		cQry += " E1A.E1_XCONTRA CEM_CONTRATO, "                                                                + cPulaLinha
		cQry += " E1A.E1_XCTRFUN FUN_CONTRATO "                                                                 + cPulaLinha
		cQry += "  FROM "                                                                                       + cPulaLinha
		cQry += " " + RetSQLName("SE1") + " E1A "                                                               + cPulaLinha

		//modulo de cemiterio
		if cMod == "CEM"

			cQry += " INNER JOIN "																					+ cPulaLinha
			cQry += " " + RetSQLName("U00") + " CEMITERIO "															+ cPulaLinha
			cQry += " ON  E1A.D_E_L_E_T_ = ' ' "  																	+ cPulaLinha
			cQry += " AND CEMITERIO.D_E_L_E_T_ = ' ' "																+ cPulaLinha
			cQry += " AND E1A.E1_FILIAL = CEMITERIO.U00_FILIAL " 													+ cPulaLinha
			cQry += " AND E1A.E1_XCONTRA = CEMITERIO.U00_CODIGO "													+ cPulaLinha
			cQry += " AND CEMITERIO.U00_CODIGO BETWEEN '" + cCtrCemitDe + "' AND '" + cCtrCemitAte + "' "			+ cPulaLinha
			cQry += " AND CEMITERIO.U00_STATUS IN ('A','S') "														+ cPulaLinha

			//modulo de funeraria
		else

			cQry += " INNER JOIN "																					+ cPulaLinha
			cQry += " " + RetSQLName("UF2") + " FUNERARIA "															+ cPulaLinha
			cQry += " ON E1A.D_E_L_E_T_ = ' ' " 																	+ cPulaLinha
			cQry += " AND E1A.E1_FILIAL = FUNERARIA.UF2_FILIAL "													+ cPulaLinha
			cQry += " AND E1A.E1_XCTRFUN = FUNERARIA.UF2_CODIGO "													+ cPulaLinha
			cQry += " AND FUNERARIA.UF2_STATUS IN ('A','S') "														+ cPulaLinha
			cQry += " AND FUNERARIA.UF2_CODIGO BETWEEN '" + cCtrFunDe + "' AND '" + cCtrFunAte + "' "				+ cPulaLinha

		endif
		cQry += " 	WHERE E1A.D_E_L_E_T_ = ' ' "																	+ cPulaLinha
		cQry += "     AND E1A.E1_FILIAL = '"+ xFilial("SE1") +"' "													+ cPulaLinha
		cQry += "     AND E1A.E1_CLIENTE BETWEEN '"+cClienteDe+"' AND '"+cClieteAte+"' "                        	+ cPulaLinha
		cQry += "     AND E1A.E1_LOJA BETWEEN '"+cLojaDe+"' AND '"+cLojaAte+"'  "                               	+ cPulaLinha
		cQry += "     AND E1A.E1_VENCREA BETWEEN '" + DTOS(dVencDe) + "' AND '" + DTOS(dVencAte) + "' "         	+ cPulaLinha

		//titulos em aberto
		If nStatus == 2
			cQry += " AND E1A.E1_SALDO > 0    "					                                                  	+ cPulaLinha
			//titulos baixados
		elseif nStatus == 3
			cQry += " AND E1A.E1_SALDO = 0    "					                                                  	+ cPulaLinha
		endif

		cQry += " ORDER BY E1A.E1_CLIENTE,E1A.E1_LOJA	"															+ cPulaLinha

		If Select("QCLI") > 0
			QCLI->( DbCloseArea() )
		EndIf

		cQry := ChangeQuery(cQry)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QCLI",.F.,.F.)

		QCLI->( DbGotop() )

		If QCLI->( !Eof() )

			While QCLI->( !EOF() )

				Aadd(aClientes,{QCLI->CLIENTE,QCLI->LOJA,If(!Empty(QCLI->CEM_CONTRATO),QCLI->CEM_CONTRATO,QCLI->FUN_CONTRATO)})

				QCLI->( DbSkip() )

			EndDo
			ExpExcel(aClientes,oSay)
		Else
			Aviso( "", "A Consulta realizada n„o retornou registros, favor verifique os parametros digitados!", {"Ok"} )
		EndIf

		QCLI->( DbCloseArea() )
	Else
		Aviso( "", "Abortado pelo usu·rio!", {"Ok"} )
	EndIf

Return(Nil)

/*/{Protheus.doc} ValidParam
Funcao para validar os parametros
@type function
@version 1.0 
@author g.sampaio
@since 03/04/2021
@param aParam, array, parametros preenchidos para impressao do boleto
@return logical, retorna se est· tudo certo
/*/
Static Function ValidParam(aParam)

	Local lRetorno	:= .T.

	Default aParam  := {}

	if Len(aParam) > 0

		if Empty(Alltrim(aParam[1]))
			lRetorno := .F.
			MsgAlert("O parametro 'AtÈ Contrato?' n„o pode estar vazio!")
		endIf

		if lRetorno .And. Empty(aParam[2])
			lRetorno := .F.
			MsgAlert("O parametro 'AtÈ Emiss„o?' n„o pode estar vazio!")
		endIf

		if lRetorno .And. Empty(aParam[3])
			lRetorno := .F.
			MsgAlert("O parametro 'AtÈ Vencimento?' n„o pode estar vazio!")
		endIf

		if lRetorno .And. Empty(aParam[6])
			lRetorno := .F.
			MsgAlert("O parametro 'Banco?' n„o pode estar vazio!")
		endIf

		if lRetorno .And. Empty(aParam[7])
			lRetorno := .F.
			MsgAlert("O parametro 'Agencia?' n„o pode estar vazio!")
		endIf

		if lRetorno .And. Empty(aParam[8])
			lRetorno := .F.
			MsgAlert("O parametro 'Conta?' n„o pode estar vazio!")
		endIf

		if lRetorno .And. !Empty(aParam[4]) .And. !Empty(aParam[5])
			MsgInfo("AtenÁ„o! Os parametros de data do reajuste est„o preenchidos, somente titulos de reajuste ser„o impressos!")
		endIf
	endIf

Return(lRetorno)

/*/{Protheus.doc} Valida
Funcao para Validar o cadastro de parametros bancarios
@type function
@version 1.0  
@author Raphael Martins
@since 24/03/2016
@param cBancoEsc, character, codigo do banco
@param cAgenciaEsc, character, codigo da agencia
@param cContaDesc, character, codigo da conta
@return logical, retorno se È um banco v·lido
/*/
Static Function ValidaBanco(cBancoEsc,cAgenciaEsc,cContaDesc)

	Local lRet      := .F.
	Local aDefault  := {}
	Local cBanco    := ""
	Local cAgencia  := ""
	Local cConta    := ""
	Local cSubConta := ""
	Local aBanco  	:= {"341","033","001","237","104","756","748","999"}

	SEE->( DbSetOrder( 1 ) ) //EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
	SA6->( DbSetOrder( 1 ) ) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON

	If !Empty(cBancoEsc) .And. SEE->(MsSeek( xFilial("SEE") + cBancoEsc + cAgenciaEsc + cContaDesc)) .And.;
			AScan ( aBanco, {|x| x == cBancoEsc } ) > 0

		lRet := .T.

		//Valido se Possui Parametro Bancario Padr„o Definido ( ES_PARASEE )
	Else

		aDefault     := StrTokArr( GetMV( "ES_PARASEE" ),'/' )

		If Len(aDefault) == 4

			cBanco     := Padr( Alltrim( aDefault[1] ),TamSX3('A6_COD')[1] )
			cAgencia   := Padr( Alltrim( aDefault[2] ),TamSX3('A6_AGENCIA')[1] )
			cConta     := Padr( Alltrim( aDefault[3] ),TamSX3('A6_NUMCON')[1] )
			cSubConta  := Padr( Alltrim( aDefault[4] ),TamSX3('EE_SUBCTA')[1] )

			If SEE->(MsSeek( xFilial("SEE") + cBanco + cAgencia + cConta + cSubConta ))
				If AScan ( aBanco, {|x| x == SEE->EE_CODIGO } ) > 0
					lRet := .T.
				Else
					Help(,,'Help',,"O Parametro Bancario Padr„o definido n„o est· homologado para impressao do Boleto, Favor corrija o cadastro!",1,0)
				EndIf

			Else
				Help(,,'Help',,"Parametro Bancario padr„o n„o existe no cadastro de parametros bancarios, favor verifique o cadastro!",1,0)
			EndIf


		Else
			Help(,,'Help',,"Parametro Bancario padr„o n„o configurado, Favor configura-lo!",1,0)
		EndIf

	EndIf

	//Valida se o Banco Definido existe no cadastro de Bancos (SA6)
	If lRet

		If !SA6->( MsSeek( xFilial("SA6") + SEE->EE_CODIGO + SEE->EE_AGENCIA + SEE->EE_CONTA ) )
			lRet := .F.
			Help(,,'Help',,"Banco configurado nos parametros bancarios nao cadastrado no sistema, Favor Relize o cadastro!",1,0)

		ElseIf Empty(SEE->EE_CODCART)

			lRet := .F.
			Help(,,'EE_CODCART',,"Campo Cod Carteira n„o preenchido, favor realize o preenchimento do mesmo antes de realizar a impress„o do boleto!",1,0)

		ElseIf Empty(SEE->EE_CODEMP)
			lRet := .F.
			Help(,,'EE_CODEMP',,"Campo Cod Empresa n„o preenchido, favor realize o preenchimento do mesmo antes de realizar a impress„o do boleto!",1,0)
		EndIf

	EndIf

Return(lRet)
