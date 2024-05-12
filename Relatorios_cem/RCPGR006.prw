#Include "totvs.ch"
#Include 'Topconn.ch'

#define CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RCPGR006
Rotina de processamento para geração de Boletos
Bancarios

@type function
@version 1.0 
@author Raphael Martins
@since 24/03/2016
@param cCliente, character, Cliente do Titulo
@param cLoja, character, Loja do Cliente
@param cPrefixo, character, Prefixo do Titulo
@param cTitulo, character, Numero do Titulo
@param cParcela, character, Parcela do Titulo
@param cTipo, character, Tipo do Titulo
@param cBancoEsc, character, Banco Escolhido para Impressao
@param cAgenciaEsc, character, Agencia Escolhido para Impressao
@param cContaDesc, character, Conta Escolhido para Impressao
@param cRota, character, Rota
@param cDescRota, character, descricao da rota
@return array, [1] gerou boleto [2] dados do boleto
/*/
User Function RCPGR006(cCliente, cLoja, cPrefixo, cTitulo, cParcela, cTipo,cBancoEsc,cAgenciaEsc,cContaDesc,cRota,cDescRota)

	Local aArea        	:= GetArea()
	Local aAreaSE1     	:= SE1->( GetArea() )
	Local aAreaSEE     	:= SEE->( GetArea() )
	Local aAreaSA1     	:= SA1->( GetArea() )
	Local aDadosBanco  	:= {}
	Local aDatSacado   	:= {}
	Local aCB_RN_NN    	:= {}
	Local aRetorno     	:= {} //Array de retorno da funcao com os dados do boleto gerado
	Local aDadosEmp    	:= {}
	Local cNossoNum    	:= ""
	Local cNosNumVal   	:= ""
	Local cFaixaAtual	:= ""
	Local cTexto       	:= ""
	Local cDigNosso    	:= ""
	Local cContrato	   	:= ""
	Local cMesAno	   	:= ""
	Local cNossoSicredi	:= ""
	Local lGerou       	:= .T.
	Local lMstEndCob	:= SuperGetMV("MV_XENDCOB",,.T.) // .T. - Mostra End. Cobranca | .F. - Mostra End. Principal
	Local nValor       	:= 0
	Local oVirtusFin	:= Nil

	Default cBancoEsc   := "" //Banco Escolhido para Impressao do Boleto
	Default cAgenciaEsc := "" //Agencia Escolhido para impressão do boleto
	Default cContaDesc  := "" //Conta Escolhida para impressao do boleto
	Default cRota		:= "" //Codigo da Rota
	Default cDescRota	:= "" //Descricao da Rota de Entrega

	// alimento os dados da emaadmipresa
	aAdd(aDadosEmp, SM0->M0_NOMECOM ) 															//[1]Nome da Empresa
	aAdd(aDadosEmp, SM0->M0_ENDCOB ) 															//[2]Endereço
	aAdd(aDadosEmp, AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ) //[3]Complemento
	aAdd(aDadosEmp, "CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3) ) 			//[4]CEP
	aAdd(aDadosEmp, "PABX/FAX: "+SM0->M0_TEL ) 													//[5]Telefones
	aAdd(aDadosEmp, "CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+Subs(SM0->M0_CGC,6,3)+;
		"/"+Subs(SM0->M0_CGC,9,4)+"-"+Subs(SM0->M0_CGC,13,2) ) 									//[6]CGC
	aAdd(aDadosEmp, "I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+;
		Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3) )									//[7]I.E

	SE1->( DbSetOrder(2) )  //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If SE1->( MsSeek( xFilial("SE1") + cCliente + cLoja + cPrefixo + cTitulo + cParcela + cTipo ) )

		If Valida(cBancoEsc,cAgenciaEsc,cContaDesc)

			If SEE->EE_CODIGO == '341' //ITAU

				aDadosBanco  := {SEE->EE_CODIGO,;	    	             	// [1]Numero do Banco
				"Banco Itaú S.A.",;	                                 	 	// [2]Nome do Banco
				Substr(SEE->EE_AGENCIA,1,4),;		                     	// [3]Agência
				StrZero(Val(SEE->EE_CONTA),5),; 	                     	// [4]Conta Corrente -2
				Alltrim(SEE->EE_DVCTA),; 	                             	// [5]Dígito da conta corrente
				SEE->EE_CODCART ,;                                      	// [6]Codigo da Carteira
				"7" ,;                                                  	// [7] Digito do Banco
				"Até o vencimento, pague preferencialmente no Itaú." ,; 	// [8] Local de Pagamento1
				"Após o vencimento, pague somente no Itaú.",;           	// [9] Local de Pagamento2
				SEE->EE_DVAGE,;                                         	// [10] Digito Verificador da agencia
				SEE->EE_CODEMP,;	                                     	// [11] Código Cedente fornecido pelo Banco
				"itau.png"	}                                            	// [12] Nome da Imagem da Logo do Banco

			ElseIf SEE->EE_CODIGO == '033' // Santander
				aDadosBanco  := {SEE->EE_CODIGO          	,;	// [1]Numero do Banco
				"Santander S.A."     		,;  // [2]Nome do Banco
				AllTrim(SEE->EE_AGENCIA)   ,;	// [3]Agência
				Alltrim(SEE->EE_CONTA)     ,; 	// [4]Conta Corrente -2
				Alltrim(SEE->EE_DVCTA)     ,; 	// [5]Dígito da conta corrente ( e para ser vazio )
				SEE->EE_CODCART            ,;  // [6]Codigo da Carteira
				"7"                        ,;  // [7] Digito do Banco
				"PAGAR PREFERENCIALMENTE NO GRUPO SANTANDER - GC" ,; // [8] Local de Pagamento1
				""/*"APÓS O VENCIMENTO, SOMENTE NAS AGÊNCIAS DO SANTANDER"*/,; // [9] Local de Pagamento2
				SEE->EE_DVAGE              ,;	//[10] Digito Verificador da agencia
				SEE->EE_CODEMP,;	            //[11] Código Cedente fornecido pelo Banco
				"santander.png" }              //[12] Nome da Imagem da Logo do Banco

			ElseIf SEE->EE_CODIGO == '001' // Banco do Brasil - [tbc] g.sampaio - 03/12/2018
				aDadosBanco  := {SEE->EE_CODIGO          	,;	// [1]Numero do Banco
				"BANCO DO BRASIL"     		,;  // [2]Nome do Banco
				AllTrim(SEE->EE_AGENCIA)   ,;	// [3]Agência
				Alltrim(SEE->EE_CONTA)     ,; 	// [4]Conta Corrente -2
				Alltrim(SEE->EE_DVCTA)     ,; 	// [5]Dígito da conta corrente ( e para ser vazio )
				SEE->EE_CODCART            ,;  // [6]Codigo da Carteira
				"9"                        ,;  // [7] Digito do Banco
				"ATÉ O VENCIMENTO, PREFERENCIALMENTE EM TODA REDE BANCÁRIA" ,; // [8] Local de Pagamento1
				"APÓS O VENCIMENTO, SOMENTE NAS AGÊNCIAS DO BANCO DO BRASIL",; // [9] Local de Pagamento2
				SEE->EE_DVAGE              ,;	//[10] Digito Verificador da agencia
				SEE->EE_CODEMP				,;  //[11] Código Cedente fornecido pelo Banco
				"bb.bmp" }            			//[12] Nome da Imagem da Logo do Banco

			ElseIf SEE->EE_CODIGO == '104' // Caixa Economica Federeal - [tbc] g.sampaio - 03/12/2018
				aDadosBanco  := {SEE->EE_CODIGO          	,;	// [1]Numero do Banco
				"CAIXA"     				,;  // [2]Nome do Banco
				AllTrim(SEE->EE_AGENCIA)   ,;	// [3]Agência
				Alltrim(SEE->EE_CONTA)     ,; 	// [4]Conta Corrente -2
				Alltrim(SEE->EE_DVCTA)     ,; 	// [5]Dígito da conta corrente ( e para ser vazio )
				SEE->EE_CODCART            ,;  // [6]Codigo da Carteira
				"0"                        ,;  // [7] Digito do Banco
				"PREFERENCIALMENTE NAS CASAS LOTÉRICAS ATÉ O VALOR LIMITE." ,; // [8] Local de Pagamento1
				""							,;	// [9] Local de Pagamento2
				SEE->EE_DVAGE              ,;	//[10] Digito Verificador da agencia
				SEE->EE_CODEMP,;	            //[11] Código Cedente fornecido pelo Banco
				"caixa.bmp" }              	//[12] Nome da Imagem da Logo do Banco

			ElseIf SEE->EE_CODIGO == '237'  // Bradesco

				aDadosBanco  := {SEE->EE_CODIGO         		,;	// [1]Numero do Banco
				"BRADESCO"     					,;  // [2]Nome do Banco
				Substr(SEE->EE_AGENCIA,1,4)   	,;	// [3]Agência
				Alltrim(SEE->EE_CONTA)			,; 	// [4]Conta Corrente -2
				Alltrim(SEE->EE_DVCTA)			,; 	// [5]Dígito da conta corrente
				SEE->EE_CODCART					,;  // [6]Codigo da Carteira
				"2" 							,;  // [7] Digito do Banco
				"PREFERENCIALMENTE NAS AGÊNCIAS BRADESCO OU BRADESCO EXPRESSO" ,; 	// [8] Local de Pagamento1
				"",; 								// [9] Local de Pagamento2
				SEE->EE_DVAGE					,;	// [10] Digito Verificador da agencia
				SEE->EE_CODEMP					,;	// [11] Código Cedente fornecido pelo Banco
				"bradesco.bmp" }

			ElseIf SEE->EE_CODIGO == '756' // Sicoob

				aDadosBanco  := {SEE->EE_CODIGO         ,;	// [1]Numero do Banco
				"SICOOB"     					,;  // [2]Nome do Banco
				Substr(SEE->EE_AGENCIA,1,4)   	,;	// [3]Agência
				Alltrim(SEE->EE_CONTA)			,; 	// [4]Conta Corrente -2
				Alltrim(SEE->EE_DVCTA)			,; 	// [5]Dígito da conta corrente
				SEE->EE_CODCART					,;  // [6]Codigo da Carteira
				"0" 							,;  // [7] Digito do Banco
				"PREFERENCIALMENTE NAS AGÊNCIAS SICOOB" ,; 	// [8] Local de Pagamento1
				"",; 								// [9] Local de Pagamento2
				SEE->EE_DVAGE					,;	// [10] Digito Verificador da agencia
				SEE->EE_CODEMP					,;	// [11] Código Cedente fornecido pelo Banco
				"sicoob.png" }    // [12] Nome da Imagem da Logo do Banco

			ElseIf SEE->EE_CODIGO == '748'  // Sicredi
				aDadosBanco  := {SEE->EE_CODIGO         		,;	// [1]Numero do Banco
				"SICREDI"     					,;  // [2]Nome do Banco
				Substr(SEE->EE_AGENCIA,1,4)   	,;	// [3]Agência
				Alltrim(SEE->EE_CONTA)			,; 	// [4]Conta Corrente -2
				Alltrim(SEE->EE_DVCTA)			,; 	// [5]Dígito da conta corrente
				SEE->EE_CODCART					,;  // [6]Codigo da Carteira
				"X" 							,;  // [7] Digito do Banco
				SEE->EE_XOBSERV					,;  // [8] Observacoes
				""								,;  // [9] Local de Pagamento2
				""								,;	// [10] Digito Verificador da agencia
				SEE->EE_CODEMP					,;	// [11] Código Cedente fornecido pelo Banco
				"sicredi.png"					,;	// [12] Nome da Imagem da Logo do Banco
				AllTrim(SEE->EE_INSTSEC)}           // [13] Codigo do Benenficiario - Usado pelo Sicredi

			ElseIf SEE->EE_CODIGO == '999'  // Carnê proprio
				aDadosBanco  := {SEE->EE_CODIGO         		,;	// [1]Numero do Banco
				"CARNÊ"     					,;  // [2]Nome do Banco
				Substr(SEE->EE_AGENCIA,1,4)   	,;	// [3]Agência
				Alltrim(SEE->EE_CONTA)			,; 	// [4]Conta Corrente -2
				Alltrim(SEE->EE_DVCTA)			,; 	// [5]Dígito da conta corrente
				SEE->EE_CODCART					,;  // [6]Codigo da Carteira
				"9" 							,;  // [7] Digito do Banco
				SEE->EE_XOBSERV					,;  // [8] Observacoes
				""								,;  // [9] Local de Pagamento2
				SEE->EE_DVAGE					,;	//[10] Digito Verificador da agencia
				SEE->EE_CODEMP					,;	//[11] Código Cedente fornecido pelo Banco
				SEE->EE_XIMG}              		//[12] Nome da Imagem da Logo do Banco

			EndIf

			cContrato := iif( !Empty( SE1->E1_XCONTRA ) , SE1->E1_XCONTRA , iif(!Empty( SE1->E1_XCTRFUN ),SE1->E1_XCTRFUN, AllTrim(SA1->A1_COD )+SA1->A1_LOJA ) )

			If lMstEndCob .And. !Empty(SA1->A1_ENDCOB)
				aDatSacado   := {AllTrim(SA1->A1_NOME)            	,;   	// 	[1]Razão Social
				AllTrim(SA1->A1_COD )+SA1->A1_LOJA		            ,;   	// 	[2]Código
				AllTrim(SA1->A1_ENDCOB)								,;   	// 	[3]Endereço
				AllTrim(SA1->A1_MUNC )	                            ,;   	// 	[4]Cidade
				SA1->A1_ESTC	                                    ,;   	// 	[5]Estado
				SA1->A1_CEPC                                        ,;   	// 	[6]CEP
				SA1->A1_CGC											,;		// 	[7]CGC
				SA1->A1_PESSOA										,; 	    // 	[8]PESSOA
				AllTrim(SA1->A1_BAIRROC)						    ,;      // 	[9]Bairro
				cContrato											,; 		//	[10] Codigo do Contrato ou Codigo do Cliente
				cRota												,;		// 	[11]Codigo da Rota
				cDescRota  											,;		//	[12]//Descricao da Rota
				IIF(!Empty(SA1->A1_XREFCOB),SA1->A1_XREFCOB,SA1->A1_XREFERE),;	//  [13]Ponto de Referencia
				SA1->A1_NREDUZ,; 											//	[14]Nome Fantasia
				Alltrim(SA1->A1_XCOMPCO)}									//  [15]Complemento
			Else
				aDatSacado   := {AllTrim(SA1->A1_NOME)          ,;      	//	[1]Razão Social
				AllTrim(SA1->A1_COD )+SA1->A1_LOJA		        ,;      	//	[2]Código
				AllTrim(SA1->A1_END )							,;      	// 	[3]Endereço
				AllTrim(SA1->A1_MUN )                           ,;  		// 	[4]Cidade
				SA1->A1_EST                                     ,;     		// 	[5]Estado
				SA1->A1_CEP                                     ,;      	// 	[6]CEP
				SA1->A1_CGC										,;  		// 	[7]CGC
				SA1->A1_PESSOA									,; 	    	// 	[8]PESSOA
				AllTrim(SA1->A1_BAIRRO)						,;         	// 	[9]Bairro
				cContrato										,;			//	[10]Codigo do Contrato ou Codigo do Cliente
				cRota											,;			// 	[11]Codigo da Rota
				cDescRota										,;			//	[12]Descricao da Rota
				IIF(!Empty(SA1->A1_XREFERE),SA1->A1_XREFERE,SA1->A1_XREFCOB),;	//  [13]Ponto de Referencia
				SA1->A1_NREDUZ,; 											//	[14]Nome Fantasia
				Alltrim(SA1->A1_COMPLEM)}									//  [15]Complemento
			Endif

			////////////////////////////////////////////////////////////////////////
			// GERA NOSSO NUMERO E MONTA CODIGO DE BARRAS E LINHA DIGITAVEL		///
			///////////////////////////////////////////////////////////////////////
			If Empty(SE1->E1_NUMBCO) // quando o numero de campo ja tiver sido gerado

				// vou pegar a faixa atual e reservar a faixa atual
				cFaixaAtual := FaixaAtualValidacao( SEE->EE_CODIGO, SEE->EE_AGENCIA, SEE->EE_CONTA, SEE->EE_TPCOBRA, SEE->EE_CODEMP, SEE->EE_FAXATU )

				/////////////////////////////////
				// 		BANCO ITAU - 341	  //
				////////////////////////////////
				if SEE->EE_CODIGO == '341'

					cNossoNum := StrZero((Val(Alltrim(cFaixaAtual))+1),8)

					cTexto    := aDadosBanco[03] + aDadosBanco[04] + aDadosBanco[6] + cNossoNum

					cDigNosso := GeraDigNosNum(AllTrim(SEE->EE_CODIGO), cNossoNum, aDadosBanco )

					///////////////////////////////////
					// 		BANCO SANTANDER - 033	//
					///////////////////////////////////
				elseif SEE->EE_CODIGO == '033'

					cNossoNum := StrZero((Val(Alltrim(cFaixaAtual))+1),12)
					cDigNosso := Dig11Santander(cNossoNum)

					/////////////////////////////////////////
					/// 		BANCO CAIXA - 104		///
					/////////////////////////////////////////
				elseif SEE->EE_CODIGO $ '104'	// [tbc] g.sampaio - 03/12/2018

					/*************************************************************************************************
					Calculo do nosso numero da Caixa
					- NOTA 1 – NOSSO NÚMERO DO SIGCB:
					- É composto de 17 posições, sendo as 02 posições iniciais 
					para identificar a Carteira e a Entrega do Boleto, e as 15 
					posições restantes são para livre utilização pelo Beneficiário.
					- Está disposto no Código de Barras da seguinte maneira:
					- Constante 1: 1ª posição do Nosso Numero - Tipo de Cobrança (1-Registrada / 2-Sem Registro)
					- Constante 2: 2ª posição do Nosso Número - Identificador de Emissão do Boleto (4-Beneficiário)
					- Sequencia 1: 3ª a 5ª posição do Nosso Número
					- Sequencia 2: 6ª a 8ª posição do Nosso Número
					- Sequencia 3: 9ª a 17ª posição do Nosso Número
					*************************************************************************************************/				
					cNossoNum	:= SEE->EE_TPCOBRA + "4" + StrZero((Val(Alltrim(cFaixaAtual))+1),15)
					cDigNosso 	:= GeraDigNosNum(AllTrim(SEE->EE_CODIGO), cNossoNum, aDadosBanco )
				
				//////////////////////////////////
				//////// BANCO BRASIL - 001 //////
				//////////////////////////////////
				elseif SEE->EE_CODIGO == '001' // [tbc] g.sampaio - 03/12/2018
    		
					if Len( AllTrim(SEE->EE_CODEMP) ) < 7
		 			
						cNossoNum   := StrZero((Val(Alltrim(cFaixaAtual))+1),5)
						cDigNosso 	:= GeraDigNosNum(AllTrim(SEE->EE_CODIGO), cNossoNum, aDadosBanco )		
		 		
					elseif Len( AllTrim(SEE->EE_CODEMP) ) == 7
		 			
						cNossoNum   := StrZero((Val(Alltrim(cFaixaAtual))+1),10)
						cDigNosso 	:= GeraDigNosNum(AllTrim(SEE->EE_CODIGO), cNossoNum, aDadosBanco )	
					endif

				/////////////////////////////////////
				///////		BRADESCO - 237		/////
				/////////////////////////////////////
				elseif SEE->EE_CODIGO == '237'
		 		
					cNossoNum   := StrZero((Val(Alltrim(cFaixaAtual))+1),11)
					cDigNosso 	:= GeraDigNosNum(AllTrim(SEE->EE_CODIGO), cNossoNum, aDadosBanco )

				/////////////////////////////////////
				///////		SICOOB - 756		/////
				/////////////////////////////////////
				elseIf SEE->EE_CODIGO == '756'

					cNossoNum	:= StrZero((Val(Alltrim(cFaixaAtual))+1),7)
					cDigNosso 	:= GeraDigNosNum(AllTrim(SEE->EE_CODIGO), cNossoNum, aDadosBanco )

				/////////////////////////////////////
				///////		SICREDI - 748		/////
				/////////////////////////////////////
				elseIf SEE->EE_CODIGO == '748'

					// Sequencial nosso numero sicredi
					cNossoSicredi := StrZero((Val(Alltrim(cFaixaAtual))+1),6)

					// o nosso numero do sicredi e 
					cNossoNum	:= Substr(Str(Year(SE1->E1_EMISSAO),4),3,2) //->Ano
					cNossoNum	+= cNossoSicredi
					cDigNosso 	:= GeraDigNosNum(AllTrim(SEE->EE_CODIGO), cNossoNum, aDadosBanco )

				//////////////////////////////////////
				///////// Carnê Próprio - 999 ////////
				//////////////////////////////////////
				elseIf SEE->EE_CODIGO == '999'

		 			cNossoNum := StrZero((Val(Alltrim(cFaixaAtual))+1),8)
			
				endIf
		
				// nosso numero para validacao, por conta da caixa
				if alltrim(SEE->EE_CODIGO) $ '104'
					cNosNumVal := SubStr(cNossoNum,3)					
				else
					cNosNumVal := cNossoNum
				EndIf

				//controle de duplicidade do nosso numero, verifico se sera duplicado
				if VldNossNum(cNosNumVal,SEE->EE_CODIGO,SEE->EE_AGENCIA,SEE->EE_CONTA)
			   
					RecLock("SEE",.F.) 
					If SEE->EE_CODIGO == '748' // sicredi
						SEE->EE_FAXATU := cNossoSicredi
					Else
						SEE->EE_FAXATU := cNosNumVal
					EndIf
					SEE->( MsUnlock() )
			
				else

			   		lGerou := .F.
			
				endif
		
			else

				if AllTrim(SEE->EE_CODIGO) $ '104'
					cNossoNum := SEE->EE_TPCOBRA + "4" + Alltrim(SE1->E1_NUMBCO)			
				else
					cNossoNum := Alltrim(SE1->E1_NUMBCO)
				endIf
				
				If !Empty(Alltrim(SE1->E1_XDVNNUM))
					cDigNosso := Alltrim(SE1->E1_XDVNNUM)
				Else
					cDigNosso := GeraDigNosNum(AllTrim(SEE->EE_CODIGO), cNossoNum, aDadosBanco )
				EndIf
			   	
			Endif
		   			
			// chama a classe financeira do virtus
			oVirtusFin := VirtusFin():New()

			//retorna o saldo do titulo naquela data
			nValor := oVirtusFin:RetSaldoTitulo(dDataBase)

			// monto o codigo de barras
			aCB_RN_NN := MontCodBar( SE1->E1_PREFIXO , SE1->E1_NUM , SE1->E1_PARCELA , SE1->E1_TIPO ,;
		   							SubsTr( aDadosBanco[1] , 1 , 3 ), aDadosBanco[3], aDadosBanco[4]  , aDadosBanco[5] ,;
		   							cNossoNum ,aDadosBanco[6] , nValor , '9', cDigNosso, aDadosBanco[11] )
		   		   
		  
			//Mes e Ano de Referencia do Vencimento do Boleto, sera utilizado no campo de N Documento nos titulos de funeraria e 
			//Taxa de Manutencao do Cemiterio.
			cMesAno 	:= SubStr(DTOS(SE1->E1_VENCREA),5,2)+"/"+ SubStr(DTOS(SE1->E1_VENCREA),1,4)
		
			//Se o campo E1_XPARCON (Este Campo nao e obrigatorio no funeraria) esta preenchido, utilizo ele, caso contrario E1_PARCELA 
			if !Empty(SE1->E1_XPARCON)
			 
				cParcela := SE1->E1_XPARCON
		
			else
			
				cParcela := SE1->E1_PARCELA
			
			endif
		   
			aDadosTit	:= {  	SE1->E1_NUM + AllTrim(SE1->E1_PARCELA)	,;      // [1] Número do título
									SE1->E1_EMISSAO                         	,; 	// [2] Data da emissão do título
									dDataBase          							,;	// [3] Data da emissão do boleto
									SE1->E1_VENCTO                          	,; 	// [4] Data do vencimento
									(nValor) 									,;  // [5] Valor do título
									aCB_RN_NN[3]                       			,;  // [6] Nosso número (Ver fórmula para calculo) 
									SE1->E1_PREFIXO							    ,;  // [7] Prefixo da NF
									"DM"										,;	// [8] Tipo do Titulo
									nValor * (SE1->E1_DESCFIN/100)              ,;	// [9] Desconto financeiro							
									cParcela									,;  // [10] Controle de Parcela do Contrato Cemiterio
									cMesAno										,;  // [11] Mes e Ano de Vencimento do Titulo
									SE1->E1_TIPO}									// [12] Tipo do Titulo SE1
		   
			//gero bordero apenas se gerado os dados com sucesso e que possua bordero gerado
			if lGerou

				// para impressao do boleto caixa retiro codigo da carteira e operaca impressos no boleto - 14
				if Alltrim(SEE->EE_CODIGO) $ '104'
					cNossoNum := SubStr(cNossoNum,3)
				endIf

		   		//gero bordero do boleto impresso
				if Empty(SE1->E1_NUMBOR)

					// verifico se ja tem nosso numero gerado
					if Empty(SE1->E1_NUMBCO)

						// gero as informacoes bancarias do titulo
						GeraBord(cNossoNum,cDigNosso,aCB_RN_NN[1],aCB_RN_NN[2],SE1->(Recno()))

					endIf

				endif

		   		aAdd(aRetorno,{aDadosBanco,;  	// Dados do Banco Selecionado
		   					aDatSacado,;   		// Dados do Cliente
		   					aCB_RN_NN,;    		// Dados do Codigo de Barra e Linha Digitavel
		   					aDadosEmp,;    		// Dados da Empresa
		   					cNossoNum,;    		// Nosso Numero 
		   					aDadosTit} )   		// Dados do Titulo

			endif
		
		Else
			lGerou := .F.
			Help(,,'Help',,"Parametros Bancarios não configurado, Favor configura-lo",1,0)
		
		EndIf

	Else
		lGerou := .F.
		Help(,,'Help',,"Titulo não encontrado, verifique os dados digitados!",1,0)
	
	EndIf

	RestArea(aArea)
	RestArea(aAreaSE1)
	RestArea(aAreaSEE)
	RestArea(aAreaSA1)

Return({lGerou,aRetorno})

/*/{Protheus.doc} Valida
Funcao para Validar o cadastro de parametros bancarios
@type function
@version 1.0  
@author Raphael Martins
@since 24/03/2016
@param cBancoEsc, character, codigo do banco
@param cAgenciaEsc, character, codigo da agencia
@param cContaDesc, character, codigo da conta
@return logical, retorno se é um banco válido
/*/
Static Function Valida(cBancoEsc,cAgenciaEsc,cContaDesc)

	Local lRet      := .F.
	Local aDefault  := {}
	Local cBanco    := ""
	Local cAgencia  := ""
	Local cConta    := ""
	Local cSubConta := ""
	Local aBanco  	:= {"341","033","001","237","104","756","748","999"}

	SEE->( DbSetOrder( 1 ) ) //EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
	SA1->( DbSetOrder( 1 ) ) //A1_FILIAL+A1_COD+A1_LOJA
	SA6->( DbSetOrder( 1 ) ) //A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON

	If SA1->(MsSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA ))

		If !Empty(cBancoEsc) .And. SEE->(MsSeek( xFilial("SEE") + cBancoEsc + cAgenciaEsc + cContaDesc)) .And.;
				AScan ( aBanco, {|x| x == cBancoEsc } ) > 0

			lRet := .T.
			//Valido se o Titulo possui portador ja definido
		ElseIf !Empty(SE1->E1_PORTADO) .And. AScan ( aBanco, {|x| x == SE1->E1_PORTADO } ) > 0  .And.;
				SEE->(MsSeek( xFilial("SEE") + SE1->E1_PORTADO + SE1->E1_AGEDEP + SE1->E1_CONTA))

			lRet := .T.

			// Valido se o Cliente possui banco preenchido em seu cadastro
		ElseIf !Empty(SA1->A1_BCO1) .And. SEE->(MsSeek( xFilial("SEE") + SA1->A1_BCO1 )) .And. AScan ( aBanco, {|x| x == SEE->EE_CODIGO } ) > 0

			lRet := .T.

			//Valido se Possui Parametro Bancario Padrão Definido ( ES_PARASEE )
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
						Help(,,'Help',,"O Parametro Bancario Padrão definido não está homologado para impressao do Boleto, Favor corrija o cadastro!",1,0)
					EndIf

				Else
					Help(,,'Help',,"Parametro Bancario padrão não existe no cadastro de parametros bancarios, favor verifique o cadastro!",1,0)
				EndIf


			Else
				Help(,,'Help',,"Parametro Bancario padrão não configurado, Favor configura-lo!",1,0)
			EndIf

		EndIf

		//Valida se o Banco Definido existe no cadastro de Bancos (SA6)
		If lRet

			If !SA6->( MsSeek( xFilial("SA6") + SEE->EE_CODIGO + SEE->EE_AGENCIA + SEE->EE_CONTA ) )
				lRet := .F.
				Help(,,'Help',,"Banco configurado nos parametros bancarios nao cadastrado no sistema, Favor Relize o cadastro!",1,0)

			ElseIf Empty(SEE->EE_CODCART)

				lRet := .F.
				Help(,,'EE_CODCART',,"Campo Cod Carteira não preenchido, favor realize o preenchimento do mesmo antes de realizar a impressão do boleto!",1,0)

			ElseIf Empty(SEE->EE_CODEMP)
				lRet := .F.
				Help(,,'EE_CODEMP',,"Campo Cod Empresa não preenchido, favor realize o preenchimento do mesmo antes de realizar a impressão do boleto!",1,0)
			EndIf

		EndIf

	Else
		lRet := .F.
		Help(,,'',,"Cliente do Titulo não encontrado, favor verifique o cadastro de clientes!",1,0)
	EndIf

Return(lRet)


/*/{Protheus.doc} Modu10
Funcao para Calcular o Digito Verificador do Nosso Numero 
Método (Módulo 10)
Conforme demonstrado no item “4” deste manual (http://download.itau.com.br/bankline/cobranca_cnab240.pdf), 
a representação numérica do código de barras é composta,
por cinco campos: 1, 2, 3 4 e 5, sendo os três primeiros amarrados por DAC's, calculados pelo módulo 10,
conforme mostramos abaixo:
a) Multiplica-se cada algarismo do campo pela seqüência de multiplicadores 2, 1, 2, 1, 2, 1..., posicionados
da direita para a esquerda;
b) Some individualmente, os algarismos dos resultados dos produtos, obtendo-se o total (N);
c) Divida o total encontrado (N) por 10, e determine o resto da divisão como MOD 10 (N);
d) Encontre o DAC através da seguinte expressão:
DAC = 10 – Mod 10 (N)
OBS.: Se o resultado da etapa d for 10, considere o DAC = 0.
@type function
@version 1.0
@author Raphael Martins
@since 24/03/2016
@param cLinha, character, Nosso Numero
@return character, retorno o digito no modulo 10
/*/
Static Function Modu10(cLinha)

	Local nSoma    := 0
	Local nResto   := 0
	Local nCont    := 0
	Local nResult  := 0
	Local lDobra   := .f.
	Local cValor   := ""
	Local nAux     := ""
	Local cDigRet  := ""

	For nCont:= Len(cLinha) To 1 Step -1
		lDobra:= !lDobra

		If lDobra
			cValor:= AllTrim(Str(Val(Substr(cLinha, nCont, 1)) * 2))
		Else
			cValor:= AllTrim(Str(Val(Substr(cLinha, nCont, 1))))
		EndIf

		For nAux:= 1 To Len(cValor)
			nSoma += Val(Substr(cValor, nAux, 1))
		Next n
	Next nCont

	nResto:= MOD(nSoma, 10)

	nResult:= 10 - nResto

	If nResult == 10
		cDigRet:= "0"
	Else
		cDigRet:= StrZero(10 - nResto, 1)
	EndIf

Return(cDigRet)

/*/{Protheus.doc} MontCodBar
Funcao para Montar Codigo de Barras, Representacao Numerica.
@type function
@version 1.0 
@author Raphael Martins
@since 24/03/2016
@param cPrefixo, character, Prefixo do Titulo
@param cNumero, character, Numero do Titulo
@param cParcela, character, Parcela do Titulo
@param cTipo, character, Tipo do Titulo (BOL)
@param cBanco, character, Banco
@param cAgencia, character, Agencia
@param cConta, character, Conta
@param cDAcCC, character, DÍGITO DE AUTO-CONFERÊNCIA AG./CONTA EMPRESA
@param cNossoNum, character, Nosso Numero do Boleto
@param cCart, character, Codigo da Carteira do Banco (Cad Parametros Bancarios (EE_CODCART))
@param nValor, numeric, Valor do Titulo
@param cMoeda, character, Moeda (Constante "9")
@param cDigNosso, character, Digito Verificador do Nosso Numero
@param cConvenio, character, Numero do convenio com o Banco
@return array, aRetorno[1] - codigo de barras; aRetorno[2] - Linha digitavel; aRetorno[3] - Nosso Numero do boleto
/*/

Static Function MontCodBar(cPrefixo, cNumero, cParcela, cTipo, cBanco, cAgencia, cConta, cDAcCC, cNossoNum, cCart, nValor, cMoeda, cDigNosso, cConvenio)

	Local aRetorno     	:= {}
	Local cTexto       	:= ""
	Local cTexto2      	:= ""
	Local cDigCC       	:= ""
	Local cFatorValor  	:= ""
	Local cCdBarra     	:= ""
	Local cCampo1      	:= ""
	Local cCampo2     	:= ""
	Local cCampo3      	:= ""
	Local cCampo4      	:= ""
	Local cCampo5      	:= ""
	Local cDigCdBarra  	:= ""
	Local cRepNum      	:= ""
	local cNosso		:= ""
	local cCampoL		:= ""
	local cDvCampoL		:= ""
	local cDigBarra		:= ""
	local cBarra		:= ""
	local cLivre		:= ""
	local cDig1			:= ""
	local cDig2			:= ""
	local cDig3			:= ""
	local cDigital		:= ""
	local cLivreBb		:= ""
	Local cFimBarras	:= ""
	Local lMVParcUnica	:= SuperGetMv("MV_XPARUNI",,.F.) // considera parcela única no boleto

	default nValor 		:= 0
	default cMoeda		:= ""
	default cDigNosso	:= ""
	default cPrefixo	:= ""
	default cNumero		:= ""
	default cParcela	:= ""
	default cTipo		:= ""
	default cBanco		:= ""
	default cAgencia	:= ""
	default cConta		:= ""
	default cDAcCC		:= ""
	default cNossoNum 	:= ""
	default cCart		:= ""
	Default cConvenio  	:= ""

	If cBanco == '341' //Itau

		If cCart $ '126/131/146/150/168'
			cTexto := cCart + cNossoNum
		Else
			cTexto := cAgencia + cConta + cCart + cNossoNum
		EndIf

		cTexto2 := cAgencia + cConta

		cDigCC  := Modu10(cTexto2)

		cNosso    := cCart + '/' + cNossoNum + '-' + cDigNosso
		cCart     := cCart

		If nValor > 0
			cFatorValor  := Fator(SE1->E1_VENCTO,cBanco) + StrZero(nValor*100,10)
		Endif

		/* Calculo do codigo de barras 
		
		POSIÇÃO TAMANHO PICTURE CONTEÚDO
		01 a 03 03 9(03) Código do Banco na Câmara de Compensação = '341'
		04 a 04 01 9(01) Código da Moeda = '9'
		05 a 05 01 9(01) DAC código de Barras (Anexo 2)
		06 a 09 04 9(04) Fator de Vencimento (Anexo 6)
		10 a 19 10 9(08)V(2) Valor
		20 a 22 03 9(03) Carteira
		23 a 30 08 9(08) Nosso Número
		31 a 31 01 9(01) DAC [Agência /Conta/Carteira/Nosso Número] (Anexo 4)
		32 a 35 04 9(04) N.º da Agência BENEFICIÁRIO
		36 a 40 05 9(05) N.º da Conta Corrente
		41 a 41 01 9(01) DAC [Agência/Conta Corrente] (Anexo 3)
		42 a 44 03 9(03) Zeros
		*/
					cCdBarra	:= cBanco + cMoeda + cFatorValor + Alltrim(cCart) + cNossoNum + cDigNosso + cAgencia + cConta + cDigCC + "000"

					cDigCdBarra	:= Modu11(cCdBarra,9)

					cCdBarra 	:= Left(cCdBarra,4) + cDigCdBarra + Substr(cCdBarra,5,40)

		/* Calculo da representacao numerica */
					cCampo1	:= cBanco+cMoeda+Substr(cCdBarra,20,5)
					cCampo2	:= Substr(cCdBarra,25,10)
					cCampo3	:= Substr(cCdBarra,35,10)

					cCampo4	:= Substr(cCdBarra, 5, 1)
					cCampo5	:= cFatorValor

		/* Calculando os DACs dos campos 1, 2 e 3 */
					cCampo1 += Modu10(cCampo1)
					cCampo2 += Modu10(cCampo2)
					cCampo3 += Modu10(cCampo3)

					cRepNum := Substr(cCampo1, 1, 5) + "." + Substr(cCampo1, 6, 5) + "  "
					cRepNum += Substr(cCampo2, 1, 5) + "." + Substr(cCampo2, 6, 6) + "  "
					cRepNum += Substr(cCampo3, 1, 5) + "." + Substr(cCampo3, 6, 6) + "  "
					cRepNum += cCampo4 + "  "
					cRepNum += cCampo5

					Aadd(aRetorno,cCdBarra)
					Aadd(aRetorno,cRepNum)
					Aadd(aRetorno,cNosso)

				ElseIf cBanco == '033' //Santander

					cNosso    := cNossoNum + '-' + cDigNosso

					//campo livre do codigo de barra                   // verificar a conta
					If nValor > 0
						cFatorValor  := Fator(SE1->E1_VENCTO,cBanco) + Strzero(nValor*100,10)
					Else
						//cFatorValor  := Fator(SE1->E1_VENCTO,cBanco) + Strzero(nValor*100,10)
						cFatorValor := fator(SE1->E1_VENCTO,cBanco)+strzero((SE1->E1_SALDO+SE1->E1_ACRESC)*100,10) // considero o saldo + acrescimos - [tbc] g.sampaio - 03/12/2018
					Endif

		/**************************************************************************
						COMPOSICAO DO CODIGO DE BARRAS 
		***************************************************************************				
		Posição Tamanho Picture Conteúdo
		01-03 3 9 (03) Identificação do Banco = 033
		04-04 1 9 (01) Código da moeda = 9 (real)
		05-05 1 9 (01) DV do código de barras (cálculo abaixo)
		06-09 4 9 (04) Fator de vencimento
		10-19 10 9 (08)V99 Valor nominal
		20-20 1 9 (01) Fixo “9”
		21-27 7 9 (07) Código do cedente padrão Santander
		28-40 13 9 (13) Nosso Número
		41-41 1 9 (01) IOS – Seguradoras (Se 7% informar 7. Limitado a 9%)
		Demais clientes usar 0 (zero)
		42-44 3 9 (03) Tipo de Modalidade Carteira
		101-Cobrança Simples Rápida COM Registro
		102- Cobrança simples – SEM Registro
		201- Penhor Rápida com Registro 
		*/

					cBarra := cBanco 										//Codigo do banco na camara de compensacao
					cBarra += cMoeda  										//Codigo da Moeda
					cBarra += Fator(SE1->E1_VENCTO,cBanco)	  	    		//Fator Vencimento
					cBarra += strzero(nValor*100,10)						//Strzero(Round(SE1->E1_SALDO,2)*100,10)
					cBarra += "9"                                           //Sistema - Fixo
					cBarra += Alltrim(SubStr(cConvenio,1,7))				//Código Cedente
					cBarra += cNossoNum + cDigNosso							//Nosso numero
					cBarra += "0"											//IOS
					cBarra += cCart	  					     			    //Tipo de Cobrança

					cDigBarra := Modu11(cBarra)								//DAC codigo de barras

					cBarra := SubStr(cBarra,1,4) + cDigBarra + SubStr(cBarra,5,39)

		/***************************************************************************************
								COMPOSICAO DA LINHA DIGITAVEL DO BANCO
		****************************************************************************************
		1o. campo: composto pelo código do banco, código da moeda, campo fixo "9", quatro
		primeiras posições do código do cedente padrão Santander e dígito verificador deste
		campo.
		
		2o. campo: composto pelas 3 primeiras posições restante do código do cedente
		Santander, nosso número (N/N) com as 07 primeiras posições e dígito verificador
		deste campo.
		
		3o. campo: composto pelas 6 primeiras posições restante do N/N, 01 posição
		referente ao IOS, 03 Posições referente ao Tipo de Modalidade da Carteira mais o
		dígito verificador deste campo.
		
		4o. campo: dígito verificador do código de barras(DAC)
		
		5o. campo: composto pelas 04 primeiras posições do fator vencimento (*) e as 10
		últimas com o valor nominal do documento, com indicação de zeros a esquerda e sem
		edição (sem ponto e vírgula).
		Quando se tratar de valor zerado, a representação deve ser 0000000000 (Dez zeros). 
		****************************************************************************************/
	
		// composicao da linha digitavel  1 PARTE DE 1
		cParte1 := cBanco 		 				     	//Codigo do banco na camara de compensacao
		cParte1 += cMoeda								//Cod. Moeda
		cParte1 += "9"									//Fixo "9" conforme manual Santander
		cParte1 += Substr(cConvenio,1,4)				//Código do Cedente (Posição 1 a 4)
		
		cDig1 := Substr(cParte1,1,9)                    //Pega variavel sem o '.'
		
		cParte1 += Modu10(cDig1)				  	    //Digito verificador do campo
				
		// composicao da linha digitavel 1 PARTE DE 2
		cParte2 := Substr(cConvenio,5,3)			    //Código do Cedente (Posição 5 a 7)
		cParte2 += Substr(cNossoNum + cDigNosso,1,7)	//Nosso Numero (Posição 1 a 7)
		
		cDig2 := Substr(cParte2,1,10)					//Pega variavel sem o '.'
		
		cParte2 += Modu10(cDig2)						//Digito verificador do campo
			
		// composicao da linha digitavel 2 PARTE DE 1
		cParte3 := SubStr(cNossoNum + cDigNosso,8,6)  		//Nosso Numero (Posição 8 a 13)
		cParte3 +="0"									    //IOS (Fixo "0")
		cParte3 += cCart 									//Tipo Cobrança (101-Cobrança Simples Rápida Com Registro)
		
		cDig3 := Substr(cParte3,1,10) 			            //Pega variavel sem o '.'
		
		cParte3 += Modu10(cDig3)				     	    //Digito verificador do campo
		
		// composicao da linha digitavel 4 PARTE
		cParte4 := SubStr(cBarra,5,1)				       //Digito Verificador do Código de Barras
		
		// composicao da linha digitavel 5 PARTE
		cParte5 := Fator(SE1->E1_VENCTO,cBanco)		       //Fator de vencimento
		cParte5 += Strzero(nValor*100,10)			       //Valor do titulo (Saldo no E1)
		
		cDigital :=  substr(cParte1,1,5)+"."+substr(cParte1,6,5)+" "+;
		substr(cParte2,1,5)+"."+substr(cParte2,6,6)+" "+;
		substr(cParte3,1,5)+"."+substr(cParte3,6,6)+" "+;
		cParte4+" "+cParte5
			
		Aadd(aRetorno,cBarra)
		Aadd(aRetorno,cDigital)
		Aadd(aRetorno,cNosso)

	elseif cBanco == "104" // caixa economica federal - [tbc] g.sampaio - 03/12/2018
		
		// nosso numero para ser retornado
		cNosso    := cNossoNum + '-' + cDigNosso

					/*
					Posição Tamanho Picture Conteúdo 							Observação
					01 – 03 3 		9 (3) 	Identificação do banco (104)
					04 – 04 1 		9 		Código da moeda (9 - Real)
					05 – 05 1 		9 		DV Geral do Código de Barras		Nota 2 / Anexo I (sera calculado apos a montagem da varaivel cLivre)
					*/
					cLivre 		:= cBanco + cMoeda

					/* 
					// composicao da variavel cFatorValor
					Posição Tamanho Picture Conteúdo 							Observação
					06 - 09 4 		9 		Fator de Vencimento Anexo II
					10 - 19 10 		9 (8) 	V99 Valor do Documento
					*/

					//fator e valor
					If nValor > 0
						cFatorValor  := fator(SE1->E1_VENCTO,cBanco)+strzero(nValor*100,10)
					Else
						cFatorValor  := fator(SE1->E1_VENCTO,cBanco)+strzero((SE1->E1_SALDO+SE1->E1_ACRESC)*100,10)
					Endif

					// vou incrementando o codigo de barras conforme as variaveis
					cLivre 		+= cFatorValor

					/**
					// composicao da variavel cCampoL
					Posição Tamanho Picture Conteúdo 							Observação
					20 – 25 6 		9 (6) 	Código do Beneficiário Campo Livre
					26 – 26 1 		9 (1) 	DV do Código do Beneficiário 		Nota 3 / Anexo VI
					27 – 29 3 		9 (3) 	Nosso Número - Seqüência 1 			Nota 1
					30 – 30 1 		9 (1) 	Constante 1 						Nota 1
					31 – 33 3 		9 (3) 	Nosso Número - Seqüência 2 			Nota 1
					34 – 34 1 		9 (1) 	Constante 2 						Nota 1
					35 – 43 9 		9 (9) 	Nosso Número - Seqüência 3 			Nota 1
					44 – 44 1 		9 (1) 	DV do Campo Livre 					Nota 4 / Anexo III 
					
					// Nota 1
					* Constante 1: 1ª posição do Nosso Numero - Tipo de Cobrança (1-Registrada / 2-Sem Registro)
					* Constante 2: 2ª posição do Nosso Número - Identificador de Emissão do Boleto (4-Beneficiário)
					* Sequencia 1: 3ª a 5ª posição do Nosso Número
					* Sequencia 2: 6ª a 8ª posição do Nosso Número
					* Sequencia 3: 9ª a 17ª posição do Nosso Número
					*/

					// Monto o campo livre
					cCampoL    	:= StrZero( Val(cConvenio),6)
					cCampoL		+= Modu11(cCampoL,,"CX",2)
					cCampoL 	+= subStr(cNossoNum,3,3) + "1" + subStr(cNossoNum,6,3) + "4" + subStr(cNossoNum,9,9)

					// faco o campo do digito verificador do campo livre
					cDvCampoL	:= Modu11(cCampoL,,"CX",2)

					// monto o campo livre
					cCampoL	   	:= cCampoL + cDvCampoL

					// campo do digito verificador do codigo de barra
					cLivre 		+= cCampoL

					// digito verificador do codigo de barras
					cDigBarra 	:= Modu11(cLivre,9,"CX",1)

					// campo do codigo de barra
					cCdBarra	:= SubStr(cLivre,1,4) + cDigBarra + SubStr(cLivre,5,39)

					// composicao da linha digitavel - parte 1
					/**
					Campo 		Conteúdo 							Tamanho
					Campo 1 	Pos 01 a 04 e pos 20 a 24			09
							Dígito verificador Módulo 10		01
					*/
					cParte1  	:= cBanco + cMoeda + substr(cLivre,19,5)
					cDig1    	:= Modu10( cParte1 )
					cParte1  	:= cParte1 + cDig1

					/**
					Campo 		Conteúdo 							Tamanho
					Campo 2 	Pos 25 a 34							10
								Dígito verificador Módulo 10		01	
					*/	
					// composicao da linha digitavel - parte 2
					cParte2  	:= substr(cLivre,24,10)
					cDig2    	:= Modu10( cParte2 )
					cParte2  	:= cParte2 + cDig2

					/**
					Campo 		Conteúdo 							Tamanho
					Campo 3 	Pos 35 a 44							10
								Dígito verificador Módulo 10		01		
					*/
					// composicao da linha digitavel - parte 3
					cParte3  	:= substr(cLivre,34,10)
					cDig3    	:= Modu10( cParte3 )
					cParte3  	:= cParte3 + cDig3

					/**
					Campo 		Conteúdo 							Tamanho
					Campo 4 	Pos 05 (DV Geral) 					01	 
					*/			
					// composicao da linha digitavel - parte 4
					cParte4 	:= cDigBarra

					/**
					Campo 5 	Pos 06 a 09 Fator de vencimento		04
								Pos 10 a 19 (Valor do Título)		10
					*/			
					// composicao da linha digitavel - parte 5
					cParte5  	:= cFatorValor

					// monta a linha digitatevel
					cDigital 	:=  substr( cParte1, 1, 5 )+"."+substr( cParte1, 6, 5 )+" "+;
						substr( cParte2, 1, 5 )+"."+substr( cParte2, 6, 6 )+" "+;
						substr( cParte3, 1, 5 )+"."+substr( cParte3, 6, 6 )+" "+;
						cParte4+" "+;
						cParte5

					Aadd( aRetorno, cCdBarra )
					Aadd( aRetorno, cDigital )
					Aadd( aRetorno, cNosso )

				elseIf cBanco == "001" .and. len( AllTrim( cConvenio ) ) == 6 // banco do brasil - [tbc] g.sampaio - 03/12/2018

					//
					// CONVENIO 6 POSICOES
					//

					/**
					Posição Tamanho Picture Conteúdo
					01 a 03 03 		9(03) 	Código do Banco na Câmara de Compensação = '001'
					04 a 04 01 		9(01) 	Código da Moeda = 9 (Real)
					05 a 05 01 		9(01) 	Digito Verificador (DV) do código de Barras*
					06 a 09 04 		9(04) 	Fator de Vencimento **
					10 a 19 10 		9(08)	V(2) Valor
					20 a 44 03 		9(03) 	Campo Livre ***

					*/

					// nosso numero para ser retorna
					cNosso    	:= cConvenio + cNossoNum

					//campo livre do codigo de barra                   // verificar a conta
					If nValor > 0
						cFatorValor  := fator(SE1->E1_VENCTO,cBanco)+strzero(nValor*100,10)
					Else
						cFatorValor  := fator(SE1->E1_VENCTO,cBanco)+strzero((SE1->E1_SALDO+SE1->E1_ACRESC)*100,10)
					Endif

					// campo livre
					cCampoL    := cConvenio + cNossoNum + cAgencia + cConta + Alltrim( cCart )

					// campo do digito verificador do codigo de barra
					cLivre 		:= cBanco+cMoeda+cFatorValor+cCampoL
					cDigBarra 	:= Modu11Bb(cLivre,9)

					// campo do codigo de barra
					cBarra    	:= Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,39)

					// composicao da linha digitavel
					cParte1  	:= cBanco + cMoeda + Substr(cConvenio,1,5)
					cDig1    	:= Modu10( cParte1 )
					cParte1  	:= cParte1 + cDig1

					cParte2  	:= SUBSTR(cCampoL,6,10)	//cNossoNum + cAgencia
					cDig2    	:= Modu10( cParte2 )
					cParte2  	:= cParte2 + cDig2

					cParte3  	:= SUBSTR(cCampoL,16,10)
					cDig3    	:= Modu10( cParte3 )
					cParte3  	:= cParte3 + cDig3

					cParte4  	:= cDigBarra
					cParte5  	:= cFatorValor

					cDigital 	:=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
						substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
						substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
						cParte4+" "+;
						cParte5

					Aadd( aRetorno, cBarra )
					Aadd( aRetorno, cDigital )
					Aadd( aRetorno, cNosso )

				elseIf cBanco == '001' .and. len( AllTrim(cConvenio) ) == 7 // banco do brasil - [tbc] g.sampaio - 03/12/2018

					//
					// CONVENIO 7 POSICOES
					//

					/**
					Posição Tamanho Picture Conteúdo
					01 a 03 03 		9(03) 	Código do Banco na Câmara de Compensação = '001'
					04 a 04 01 		9(01) 	Código da Moeda = 9 (Real)
					05 a 05 01 		9(01) 	Digito Verificador (DV) do código de Barras*
					06 a 09 04 		9(04) 	Fator de Vencimento **
					10 a 19 10 		9(08)	V(2) Valor
					20 a 44 03 		9(03) 	Campo Livre ***

					*/

					// nosso numero para ser retorna
					cNosso     := StrZero(Val(cConvenio),7)+StrZero(Val(cNossoNum),10)

					// campo livre
					cCampoL    := StrZero(Val(cConvenio),13)+strzero(Val(cNossoNum),10)+ Alltrim( cCart )

					//campo livre do codigo de barra                   // verificar a conta
					If nValor > 0
						cFatorValor  := fator(SE1->E1_VENCTO)+strzero(nValor*100,10)
					Else
						cFatorValor  := fator(SE1->E1_VENCTO)+strzero(SE1->E1_SALDO*100,10)
					Endif

					// campo do digito verificador do codigo de barra
					cLivre 		:= cBanco+cMoeda+cFatorValor+cCampoL
					cLivreBb	:= Substr(cLivre,1,4)+Space(1)+Substr(cLivre,5,39)
					cDigBarra 	:= Modu11Bb( cLivreBb ,9)

					// campo do codigo de barra
					cBarra    	:= Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,39)

					// composicao da linha digitavel
					cParte1  	:= cBanco+cMoeda+Strzero(val(Substr(cBarra,4,1)),6)
					cDig1    	:= Modu10( cParte1 )

					cParte2  	:= SUBSTR(cCampoL,6,10) // alterado aqui cParte2  := SUBSTR(cCampoL,7,10)
					cDig2    	:= Modu10( cParte2 )
					cParte2  	:= cParte2 + cDig2

					cParte3  	:= SUBSTR(cCampoL,16,10)
					cDig3    	:= Modu10( cParte3 )
					cParte3  	:= cParte3 + cDig3

					cParte4  	:= cDigBarra
					cParte5  	:= cFatorValor

					cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
						substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
						substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
						cParte4+" "+;
						cParte5

					Aadd( aRetorno, cBarra )
					Aadd( aRetorno, cDigital )
					Aadd( aRetorno, cNosso )

				elseif cBanco == "237" // bradesco

					// montagem do nosso numero
					cNosso     := alltrim(cCart) + '/' + cNossoNum + '-' + cDigNosso

					/**
					As posições do campo livre ficam a critério de cada Banco arrecadador, sendo que o padrão do Bradesco é:

					Posição 	Tamanho 	Conteúdo
					20 a 23 	4 			Agência Beneficiária (Sem o digito verificador, completar com zeros
											a esquerda quando necessário).
					24 a 25 	2 			Modalidade Cobrança Interna
					26 a 36 	11 			Identificação do Documento - Número do Nosso Número (Sem o
											digito verificador)
					37 a 43 	7 			Conta do Favorecido (Sem o digito verificador, completar com zeros
											a esquerda quando necessário).
					44 a 44 	1 			Zero

					*/

					// campo livre
					cCampoL    := cAgencia+alltrim(cCart)+cNossoNum+StrZero(Val(cConta),7)+'0'

					/**
					MONTAGEM DOS DADOS DO CÓDIGO DE BARRAS
					O código de barra para cobrança contém 44 posições dispostas da seguinte forma:
					Posição 	Tamanho 	Conteúdo
					01 a 03 	3			Identificação do Banco (Vide Nota Abaixo)
					04 a 04 	1			Código da Moeda (Real = 9, Outras=0)
					05 a 05	 	1			Dígito verificador do Código de Barras
					06 a 09 	4			Fator de Vencimento (Vide Nota)
					10 a 19 	10			Valor
					20 a 44 	25			Campo Livre

					Notas:
						> A Cobrança Interna, por ser um produto que somente poderá ser pago na rede do Banco
						Bradesco, no código de barras.
						> (posição – 1 a 3 Códigos do Banco), deverá obrigatoriamente ser preenchido com zeros “000”
					*/

					//campo livre do codigo de barra                   // verificar a conta
					If nValor > 0
						cFatorValor  := fator(SE1->E1_VENCTO)+strzero(nValor*100,10)
					Else
						cFatorValor  := fator(SE1->E1_VENCTO)+strzero(SE1->E1_SALDO*100,10)
					Endif

					// campo do digito verificador do codigo de barra
					cLivre 		:= cBanco+cMoeda+cFatorValor+cCampoL

					// digito verificador do codigo de barras
					cDigBarra 	:= Modu11( cLivre )

					// campo do codigo de barra
					cBarra    	:= Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,39)

					/**
					1º campo
					Composto pelo código de Banco, código da moeda, as cinco primeiras posições do campo livre e o dígito
					verificador deste campo;
					*/
					// composicao da linha digitavel
					cParte1  	:= cBanco+cMoeda+Substr(cBarra,20,5)
					cDig1    	:= Modu10( cParte1 )
					cParte1  	:= cParte1 + cDig1

					/**
					2º campo
					Composto pelas posições 6ª a 15ª do campo livre e o dígito verificador deste campo;
					*/

					cParte2  	:= SUBSTR(cBarra,25,10) // alterado aqui cParte2  := SUBSTR(cCampoL,7,10)
					cDig2    	:= Modu10( cParte2 )
					cParte2  	:= cParte2 + cDig2

					/**
					3º campo
					Composto pelas posições 16ª a 25ª do campo livre e o dígito verificador deste campo;
					*/

					cParte3  	:= SUBSTR(cBarra,35,10)
					cDig3    	:= Modu10( cParte3 )
					cParte3  	:= cParte3 + cDig3

					/**
					4º campo
					Composto pelo dígito verificador do código de barras, ou seja, a 5ª posição do código de barras;
					*/

					cParte4  	:= cDigBarra

					/**
					5º campo
					Composto pelo fator de vencimento com 4(quatro) caracteres e o valor do documento com 10(dez)
					caracteres, sem separadores e sem edição.	
					*/
					cParte5  	:= cFatorValor

					cDigital 	:= substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
						substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
						substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
						cParte4+" "+;
						cParte5

					Aadd(aRetorno,cBarra)
					Aadd(aRetorno,cDigital)
					Aadd(aRetorno,cNosso)

				elseIf cBanco == '756' // Sicoob

					// considera parcela unica no boleto
					if lMVParcUnica
						cParcela := "001"
					endIf

					cConta	:= StrZero( val(cConta),8)
					cNosso 	:= cNossoNum + '-' + cDigNosso
					cCart  	:= cCart

					//campo livre do codigo de barra                   // verificar a conta
					If nValor > 0
						cFatorValor  := fator()+strzero(nValor*100,10)
					Else
						cFatorValor  := fator()+strzero(SE1->E1_SALDO*100,10)
					Endif

					// campo livre
					cCampoL    := Right(cCart,1) + cAgencia + Right(cCart,2) + StrZero( Val(cConvenio),7) + cNossoNum + cDigNosso + StrZero( Val(cParcela),3)

					// campo do digito verificador do codigo de barra
					cLivre := cBanco + cMoeda + cFatorValor + cCampoL
					cDigBarra := Modu11(cLivre)

					// campo do codigo de barra
					cBarra    := SubStr(cLivre,1,4) + cDigBarra + SubStr(cLivre,5,39)

					// composicao da linha digitavel
					cParte1  := cBanco + cMoeda + RIGHT(cCart,1) + cAgencia
					cDig1    := Modu10( cParte1 )
					cParte1  := cParte1 + cDig1

					cParte2  := Right(cCart,2) + StrZero( Val(SEE->EE_CODEMP), 7) +	Left(cNossoNum,1)
					cDig2    := Modu10( cParte2 )
					cParte2  := cParte2 + cDig2

					cParte3  := Right(cNossoNum,6) + cDigNosso + StrZero( Val(cParcela),3)
					cDig3    := Modu10( cParte3 )
					cParte3  := cParte3 + cDig3

					cParte4  := cDigBarra
					cParte5  := cFatorValor

					cDigital :=  substr(cParte1,1,5)+"."+substr(cparte1,6,5)+" "+;
						substr(cParte2,1,5)+"."+substr(cparte2,6,6)+" "+;
						substr(cParte3,1,5)+"."+substr(cparte3,6,6)+" "+;
						cParte4+" "+;
						cParte5

					Aadd(aRetorno,cBarra)
					Aadd(aRetorno,cDigital)
					Aadd(aRetorno,cNosso)

				elseif cBanco == "748" // sicredi

					//Fator do valor.
					If nValor > 0
						cFatorValor  := Fator(SE1->E1_VENCTO)+strzero(nValor*100,10)
					Else
						cFatorValor  := Fator(SE1->E1_VENCTO)+strzero(SE1->E1_SALDO*100,10)
					Endif

					//-> Montagem do Codigo de Barras
					cBarra := "748"
					cBarra += "9"
					cBarra += cFatorValor

					//-> campo livre da 20 ate 44
					cLivre := "1" 					//-> Cobranca Registrada
					cLivre += "1" 					//-> Carteira Simples
					cLivre += cNossoNum + cDigNosso	//->Nosso nœmero com 9 d’gitos
					cLivre += cAgencia 	//->Agencia
					cLivre += AllTrim(SEE->EE_INSTSEC) 	//-> Posto
					cLivre += AllTrim(SEE->EE_CODEMP)	//-> Cedente
					cLivre += "1"
					cLivre += "0"

					cDVLiv := DigLivSicredi(cLivre)
					cLivre += cDVLiv
					cBarra += cLivre
					cDigBarra  := DigBarSicredi(cBarra)

					//Codigo de barras.
					cFimBarras	:= Substr(cBarra,1,4) + cDigBarra + Substr(cBarra,5,39)

					// composicao da linha digitavel
					cParte1  := Substr(cFimBarras,01,03) + Substr(cFimBarras,04,01) + Substr(cFimBarras,20,5)
					cDig1    := Modu10( cParte1 )
					cParte1  := cParte1 + cDig1

					cParte2  := Substr(cFimBarras,25,10)
					cDig2    := Modu10( cParte2 )
					cParte2  := cParte2 + cDig2

					cParte3  := Substr(cFimBarras,35,10)
					cDig3    := Modu10( cParte3 )
					cParte3  := cParte3 + cDig3

					cParte4  := cDigBarra
					cParte5  := cFatorValor

					cDigital :=  SubStr(cParte1,1,5)+"."+ SubStr(cparte1,6,5)+" "+;
						SubStr(cParte2,1,5)+"."+ SubStr(cParte2,6,6)+" "+;
						SubStr(cParte3,1,5)+"."+ SubStr(cParte3,6,6)+" "+;
						cParte4+" "+;
						cParte5

					Aadd(aRetorno,cFimBarras)
					Aadd(aRetorno,cDigital)
					Aadd(aRetorno,cNossoNum+cDigNosso)

				elseif cBanco == "999" // Carnê Próprio

					//campo livre do codigo de barra
					If nValor > 0
						cFatorValor  := fator(SE1->E1_VENCTO)+strzero(nValor*100,10)
					Else
						cFatorValor  := fator(SE1->E1_VENCTO)+strzero(SE1->E1_SALDO*100,10)
					Endif

					// nosso numero para carne proprio
					cNosso		:= cNossoNum
					cCdBarra	:= cNossoNum + alltrim(SE1->E1_NUM) + alltrim(SE1->E1_PARCELA) + cFatorValor

					Aadd(aRetorno,cCdBarra)
					Aadd(aRetorno,cCdBarra)
					Aadd(aRetorno,cNosso)

				EndIf

				Return( aClone(aRetorno) )

/*/{Protheus.doc} Modu11
Funcao para Montar o Módulo 11 da Representação Numerica
Por definição da FEBRABAN e do Banco Central do Brasil, na 5ª posição do Código de Barras, deve ser
indicado obrigatoriamente o “dígito verificador” (DAC), calculado através do módulo 11.
@type function
@version 1.0 
@author Raphael Martins
@since 24/03/2016
@param cLinha, character, nosso numero
@param cBase, character, base do calculo do modulo 11
@param cTipo, character, digito a considerar caso tenha
@return character, retorna o digito do modulo 11
/*/
Static Function Modu11(cLinha,cBase,cTipo,nOper)

	Local cDigRet  := ""
	Local nSoma    := 0
	Local nResto   := 0
	Local nCont    := 0
	Local nFator   := 9
	Local nResult  := 0

	Default cLinha 	:= ""
	Default cBase	:= 9
	Default	cTipo	:= ""
	Default nOper 	:= 1

	//-------------------------------------
	// Para Caixa Economica Federal
	//-------------------------------------
	// nOper = 	1 (Codigo de Barras)
	//			2 (Nosso Numero e outros)
	//-------------------------------------

	// faco o calculo com base no nosso numero
	For nCont:= Len(cLinha) TO 1 Step -1
		nFator++
		If nFator > cBase
			nFator:= 2
		EndIf

		nSoma += Val(Substr(cLinha, nCont, 1)) * nFator
	Next nCont

	// resto da soma
	nResto:= Mod(nSoma, 11)

	// verifico qual o resultado da subtracao de 11 com o resto da soma
	nResult:= 11 - nResto

	If cTipo = "P"   // Bradesco
		If nResto == 0
			cDigRet:= "0"
		ElseIf  nResto == 1
			cDigRet:= "P"
		Else
			cDigRet:= StrZero(11 - nResto, 1)
		EndIf
	elseIf cTipo == "CX" // para caixa economica federal

		/**
		Calculado através do Modulo 11, conforme ANEXO VI.
		ATENÇÃO: Admite 0 (zero), diferentemente do DV Geral do Código de Barras.
		*/
		if nOper == 1 // (Codigo de Barras)

			if nResult == 11 .Or. nResult == 10
				cDigRet:= "1"
			else
				cDigRet:= cValToChar(nResult)
			endIf

		elseIf nOper == 2 // (Nosso Numero e outros)
			/** 
			ANEXO VI – CÁLCULO DO DÍGITO VERIFICADOR DO CÓDIGO DO CEDENTE 
			- O DV do Código do Cedente é calculado através do MÓDULO 11, com peso de 2 a 9; 
			- Para calcular o Dígito Verificador considerar apenas as 06 posições do Código do Cedente
			ANEXO IV – CÁLCULO DO DÍGITO VERIFICADOR DO NOSSO NÚMERO 
			- O DV do Nosso Número é calculado através do MÓDULO 11, com peso de 2 a 9; 
			- Para cálculo do DV do Nosso Número são consideradas as 17 posições.
			*/

			if nResult > 9
				cDigRet:= "0"
			else
				cDigRet:= cValToChar(nResult)
			endIf

		endIf

	Else
		If nResult == 0 .Or. nResult == 1 .Or. nResult == 10 .Or. nResult == 11
			cDigRet:= "1"
		Else
			cDigRet:= StrZero(11 - nResto, 1)
		EndIf
	EndIf

Return(cDigRet)

/*/{Protheus.doc} Modu11Bb
Funcao para Montar o Módulo 11 da Representação Numerica para o Banco do Brasil
Por definição da FEBRABAN e do Banco Central do Brasil, na 5ª posição do Código de Barras, deve ser
indicado obrigatoriamente o “dígito verificador” (DAC), calculado através do módulo 11.
@type function
@version 1.0 
@author g.sampaio
@since 11/11/2018
@param cLinha, character, nosso numero
@param cBase, character, base do calculo do modulo 11
@param cTipo, character, digito a considerar caso tenha
@return character, retorna o digito do modulo 11
/*/
Static Function Modu11Bb(cLinha,cBase,cTipo)

	Local cDigRet  := ""
	Local nSoma    := 0
	Local nResto   := 0
	Local nCont    := 0
	Local nFator   := 9
	Local nResult  := 0
	Local _cBase   := If( cBase = Nil , 9 , cBase )

	For nCont:= Len(cLinha) TO 1 Step -1

		// quando for a posicao 5 o programa nao faz nada
		if nCont # 5
			nFator++
			If nFator > _cBase
				nFator:= 2
			EndIf

			nSoma += Val(Substr(cLinha, nCont, 1)) * nFator
		endIf

	Next nCont

	nResto:= Mod(nSoma, 11)

	nResult:= 11 - nResto

	If nResult == 0 .Or. nResult == 1 .Or. nResult == 10 .Or. nResult == 11
		cDigRet:= "1"
	Else
		cDigRet:= StrZero(11 - nResto, 1)
	EndIf

Return(cDigRet)

/*/{Protheus.doc} Fator
Funcao para Calcular Fator de Vencimento 

Utilizar-se de uma tabela de correlação DATA x FATOR, iniciando-se pelo fator “1000” correspondente à
data de vencimento 03.07.2000, adicionando-se “1” a cada dia subseqüente a este fator.

FATOR VENCIMENTO
1000  03/07/2000
1001  04/07/2000
1002  05/07/2000
1003  06/07/2000
1004  07/07/2000
:        :
:        :
1667  01/05/2002
4789  17/11/2010
9999  21/02/2025

Santander

Fator vencimento: Quantidade de dias entre 07/10/1997 até a data de vencimento:
Ex: 1º 06/12/2000 = 1156
2º 15/12/2000 = 1165
3º 30/12/2000 = 1180 
@type function
@version 1.0
@author Raphael Martins
@since 24/03/2016
@param dVencimento, date, data de vencimetno
@param cBanco, character, codigo do banco
@return character, fator de conversao da data
/*/
Static function Fator(dVencimento,cBanco)

	Local cFator  := ""

	Default dVencimento	:= SE1->E1_VENCTO
	Default cBanco		:= ""

	if cBanco == '033' //Santander
		cFator := STR(dVencimento-STOD("19971007"),4)
	else// para os demais bancos
		if dVencimento > Stod("20250222")
			cFator := STR(1000+(dVencimento-STOD("20250222")),4)
		else
			cFator := STR(1000+(dVencimento-STOD("20000703")),4)
		endIf
	EndIf

Return(cFator)

/*/{Protheus.doc} Dig11Santander
Para o cálculo, utilizar módulo 11, peso 2 a 9
Composição do Nosso Número: NNNNNNNNNNNN D onde:
N = Faixa seqüencial de 000000000001 a 999999999999
D = Dígito de controle.
Exemplo de cálculo do dígito:
Supondo-se que: Nosso Número = 566612457800
Inverter da direita para a esquerda na vertical.
0 X 2 = 0
0 X 3 = 0
8 X 4 = 32
7 X 5 = 35
5 X 6 = 30
4 X 7 = 28
2 X 8 = 16
1 X 9 = 9
6 X 2 = 12
6 X 3 = 18
6 X 4 = 24
 5 X 5 = 25
Total 229 / 11 = 20 resto 9 11-9 2
Resto = 9 Ex.: 56612457800-2
EFETUAR
Módulo 11 - Multiplicar da direita para a esquerda, aplicando o peso de 2 até 9,
até o final do número, reiniciando em 2 se necessário.
Somar os resultados obtidos e dividi-lo por 11 (onze). Se o resto desta divisão
	for igual a 10(dez) o dígito será = 1 (um), se for igual a 0 (zero) ou 1 (um) o digito
será 0 (zero).
Qualquer “Resto” diferente de “0,1 ou 10” subtrair o resto de 11 para obter o
dígito.
@type function
@version 1.0 
@author Raphael Martins
@since 24/03/2016
@param cData, character, data
@return numeric, retorna o Dig11 para o Banco Santander
/*/
Static Function Dig11Santander(cData)

	Local nAuxi     := 0
	Local nSumdig   := 0
	Local cBase     := cData
	Local nLenB     := Len(cBase)
	Local nX        := Len(cBase)
	Local nBase     := 2

	for nX := nLenB to 1 Step -1

		if nBase == 9
			nBase := 2
		endIf

		nAuxi   := Val( SubStr( cBase, nX, 1)) * nBase
		nSumdig := nSumdig + nAuxi
		nBase   += 1

	next nX

	nAuxi := mod(nSumdig,11)

	If nAuxi == 10
		nAuxi := "1"
	ElseIf nAuxi == 1 .or. nAuxi == 0
		nAuxi := "0"
	Else
		nAuxi := str( 11 - nAuxi , 1 , 0 )
	EndIf

Return(nAuxi)

/*/{Protheus.doc} GeraBord
Funcao para Gerar o Bordero dos Boletos
impressos
@type function
@version 1.0
@author Raphael Martins
@since 24/03/2016
@param cNossoNum, character, Nosso Numero para o Banco
@param cDigNosso, character, Digito Verificador do Nosso Numero
@param cCodBar, character, Codigo de Barras
@param cLinhaDig, character, Linha Digitavel
/*/
Static Function GeraBord(cNossoNum, cDigNosso, cCodBar, cLinhaDig, nRecnoSE1,cNossoSicredi)

	Local cBanco  		:= ""
	Local cBordero 		:= ""
	Local lFindSEA 		:= .T.
	Local cIdCnab		:= ""
	Local lGeraBordero 	:= SuperGetMv("MV_XGERBOR",.F.,.T.)

	Default cNossoNum		:= ""
	Default cDigNosso		:= ""
	Default cCodBar			:= ""
	Default cLinhaDig		:= ""
	Default nRecnoSE1		:= 0

	// Linha digitavel sem pontos e espacos
	If !Empty(cLinhaDig)
		cLinhaDig := StrTran(cLinhaDig, ".")
		cLinhaDig := StrTran(cLinhaDig, " ")
	EndIf

	// valido se gera bordero na impressao do boleto
	if lGeraBordero

		// Itau
		if SEE->EE_CODIGO == '341'

			cBanco := 'I'

			// Santander
		elseif SEE->EE_CODIGO == '033'

			cBanco := 'S'

			// Caixa Economica Federal
		elseif SEE->EE_CODIGO == '104'

			cBanco := 'C'

			// Banco do Brasil
		elseif SEE->EE_CODIGO == '001'

			cBanco := 'B'

			// Bradesco
		elseif SEE->EE_CODIGO == '237'

			cBanco := 'R'

			// sicoob
		elseif SEE->EE_CODIGO == '756'

			cBanco := 'O'

			// sicredi
		elseif SEE->EE_CODIGO == '748'

			cBanco := 'D'

			//Carnê Próprio
		elseif SEE->EE_CODIGO == '999'

			cBanco := 'P'

		endif

		////////////////////////////////////////////
		// X - Codigo Banco
		// XX - Ano Bordero
		// X - Codigo Mes
		// XX - Dias
		////////////////////////////////////////////

		//gero o numero do bordero
		cBordero := cBanco + StrZero( day( dDataBase ),2 ) + Upper(chr( 64+Month( dDataBase ) ) ) + Right( Str( Year( dDataBase ),4 ), 2 )

		//gero o idcnab para o titulo
		cIdCnab	:= CodigoCNAB()

		//garanto que estara posicionado no titulo corrreto
		SE1->(DbGoto( nRecnoSE1 ))

		RecLock("SE1",.F.)
		SE1->E1_PORTADO	:= SEE->EE_CODIGO
		SE1->E1_AGEDEP	:= SEE->EE_AGENCIA
		SE1->E1_CONTA	:= SEE->EE_CONTA
		SE1->E1_SITUACA	:= '1'
		SE1->E1_OCORREN	:= '01'
		SE1->E1_NUMBOR	:= cBordero
		SE1->E1_DATABOR	:= dDataBase
		SE1->E1_NUMBCO  := cNossoNum
		SE1->E1_XDVNNUM := cDigNosso
		SE1->E1_CODBAR  := cCodBar
		SE1->E1_IDCNAB	:= cIdCnab
		SE1->E1_CODDIG	:= SubStr(cLinhaDig, 1, TamSX3("E1_CODDIG")[1])

		SE1->( MsUnlock() )

		//Inclui o Titulo no Bordero
		lFindSEA := SEA->( MsSeek( xFilial( "SEA" )+SE1->E1_NUMBOR+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA,.F. ) )


		RecLock( "SEA",!lFindSEA )

		if !lFindSEA

			SEA->EA_FILIAL  := xFilial( "SEA" )
			SEA->EA_PREFIXO := SE1->E1_PREFIXO
			SEA->EA_NUM     := SE1->E1_NUM
			SEA->EA_PARCELA := SE1->E1_PARCELA
			SEA->EA_FILORIG := xFilial("SEA")

		endif

		SEA->EA_NUMBOR  := SE1->E1_NUMBOR
		SEA->EA_TIPO    := SE1->E1_TIPO
		SEA->EA_CART    := "R"
		SEA->EA_PORTADO := SE1->E1_PORTADO
		SEA->EA_AGEDEP  := SE1->E1_AGEDEP
		SEA->EA_DATABOR := SE1->E1_DATABOR
		SEA->EA_NUMCON  := SE1->E1_CONTA
		SEA->EA_SITUACA := SE1->E1_SITUACA
		SEA->EA_TRANSF  := 'S'
		SEA->EA_SITUANT := '0'

		SEA->( msUnLock() )

	else

		//gero o idcnab para o titulo
		cIdCnab	:= CodigoCNAB()

		//garanto que estara posicionado no titulo corrreto
		SE1->(DbGoto( nRecnoSE1 ))

		RecLock("SE1",.F.)
		SE1->E1_PORTADO	:= SEE->EE_CODIGO
		SE1->E1_AGEDEP	:= SEE->EE_AGENCIA
		SE1->E1_CONTA	:= SEE->EE_CONTA
		SE1->E1_OCORREN	:= '01'
		SE1->E1_NUMBCO  := cNossoNum
		SE1->E1_XDVNNUM := cDigNosso
		SE1->E1_CODBAR  := cCodBar
		SE1->E1_IDCNAB	:= cIdCnab
		SE1->E1_CODDIG	:= SubStr(cLinhaDig, 1, TamSX3("E1_CODDIG")[1])

		SE1->( MsUnlock() )

	endif

Return(Nil)

/*/{Protheus.doc} VldNossNum
VALIDO SE O NOSSO NUMERO GERADO ESTA DUPLICADO	
@type function
@version 1.0
@author g.sampaio
@since 23/02/2021
@param cNossoNum, character, Codigo do Nosso Numero
@param cBancoBol, character, Codigo do Banco
@param cAgenciaBol, character, Agencia do Boleto
@param cContaBol, character, Conta do Boleto
@return logical, retorno se o nosso numero ja existe ou nao
/*/
Static Function VldNossNum(cNossoNum,cBancoBol,cAgenciaBol,cContaBol)

	Local aArea		:= GetArea()
	Local aAreaSE1	:= SE1->( GetArea() )
	Local aAreaSEE	:= SEE->( GetArea() )
	Local cQry 		:= ""
	Local lRet		:= .T.


	cQry := " SELECT "
	cQry += " COUNT(*) QTD_DUPLI "
	cQry += " FROM  "
	cQry += " " + RetSQLName("SE1") + " SE1 (NOLOCK) "
	cQry += " WHERE "
	cQry += " D_E_L_E_T_ = ' ' "
	cQry += " AND E1_FILIAL = '" + xFilial("SE1") + "'  "
	cQry += " AND E1_NUMBCO = '"  + cNossoNum + "' "
	cQry += " AND E1_PORTADO = '" + cBancoBol + "' "
	cQry += " AND E1_AGEDEP = '" + cAgenciaBol + "' "
	cQry += " AND E1_CONTA = '" + cContaBol + "' "

	// verifico se não existe este alias criado
	If Select("QRYNBCO") > 0
		QRYNBCO->(DbCloseArea())
	EndIf

	cQry := ChangeQuery(cQry)

	// crio o alias temporario
	TcQuery cQry New Alias "QRYNBCO"

	If QRYNBCO->QTD_DUPLI > 0
		lRet	:= .F.
		Help(,,'Help',,"O Nosso Número Gerado já existe no sistema, a geração do boleto será cancelada, favor verifique o campo Faixa Atual da rotina parametros de bancos!",1,0)
	endif

	RestArea(aArea)
	RestArea(aAreaSE1)
	RestArea(aAreaSEE)

Return(lRet)

/*/{Protheus.doc} CodigoCNAB
Funcao para Gerar o ID_CNAB do titulo impresso
impressos
@type function
@version 1.0 
@author Raphael Martins
@since 14/11/2017
@return character, retorno o ID CNAB
/*/
Static Function CodigoCNAB()

	Local aArea      	:= GetArea()
	Local aAreaSE1   	:= SE1->( GetArea() )
	Local lNewIndex  	:= FaVerInd()

	cCodigo := GetSxENum("SE1","E1_IDCNAB","E1_IDCNAB"+cEmpAnt,If(lNewIndex,19,16))

	SE1->( DbSetOrder(16)) // E1_FILIAL+E1_IDCNAB

	While SE1->(MsSeek( xFilial("SE1") + cCodigo))
		ConfirmSX8()
		cCodigo := GetSxENum("SE1","E1_IDCNAB","E1_IDCNAB"+cEmpAnt,If(lNewIndex,19,16))
	EndDo

	ConfirmSX8()


	RestArea(aArea)
	RestArea(aAreaSE1)

Return(cCodigo)

/*/{Protheus.doc} FaixaAtualValidacao
funcao para validar se a faixa atual esta 
disponivel para uso
@type function
@version 1.0
@author g.sampaio
@since 23/02/2021
@param cSEEBanco, character, Codigo do Banco
@param cSEEAgencia, character, Codigo da Agencia no Banco
@param cSEEConta, character, Codigo da Conta
@param cSEETpCobra, character, Tipo de Cobranca
@param cSEECodemp, character, Codigo da Empresa
@param cSEEFaixaAtual, character, Faixa atual do boleto
@return character, retorno a faixa atual
/*/
Static Function FaixaAtualValidacao( cSEEBanco, cSEEAgencia, cSEEConta, cSEETpCobra, cSEECodemp, cSEEFaixaAtual )

	Local aArea 			:= GetArea()
	Local cRet				:= ""
	Local cQuery			:= ""
	Local cLength			:= ""
	Local cBancoDeDados		:= ""

	Default cSEEBanco		:= ""
	Default cSEEAgencia		:= ""
	Default cSEEConta		:= ""
	Default cSEETpCobra		:= ""
	Default cSEECodemp		:= ""
	Default cSEEFaixaAtual 	:= ""

	// pego o banco de dados da aplicacao
	cBancoDeDados := TcGetDB()

	// caso nao tenha retorno coloco o conteudo padrao
	if Empty(cBancoDeDados)
		cBancoDeDados	:= "MSSQL" // conteudo padrao para SQL Server
	endIf

	// ponto de entrada criado para tratar faixa atual especifica
	// tratamento para a vale do cerrado
	if ExistBlock("TSPFXATU")

		cSEEFaixaAtual := ExecBlock( "TSPFXATU", .F. ,.F., { cSEEBanco, cSEEAgencia, cSEEConta, cSEETpCobra, cSEECodemp, cSEEFaixaAtual } )

	else
		// pego o tamanho do E1_NUMBCO, de acordo com o banco
		if cSEEBanco == "341"
			cLength := "8"
		elseif cSEEBanco == "033"
			cLength := "12"
		elseif cSEEBanco == "104"
			cLength := "15"
		elseif cSEEBanco == "237"
			cLength := "11"
		elseif cSEEBanco == "756"
			cLength	:= "7"
		elseif cSEEBanco == "748"
			cLength	:= "6"
		elseif cSEEBanco == "999"
			cLength := "8"
		elseif cSEEBanco == "001" .and. len(alltrim(cSEECodemp)) < 7
			cLength := "5"
		elseif cSEEBanco == "001" .and. len(alltrim(cSEECodemp)) == 7
			cLength := "10"
		endIf

		If Select("TRBMAX") > 0
			TRBMAX->( DbCloseArea() )
		EndIf

		// query para consultar o maior nosso numero utilizado
		cQuery := " SELECT "
		cQuery += " 	MAX(SE1.E1_NUMBCO) FAIXAMAX "
		cQuery += " FROM "
		cQuery += RetSQLName("SE1") + " SE1 (NOLOCK) "
		cQuery += " WHERE SE1.D_E_L_E_T_ 	= ' ' "
		cQuery += " AND SE1.E1_FILIAL 		= '" + xFilial("SE1")	+ "' "
		cQuery += " AND SE1.E1_PORTADO 		= '" + cSEEBanco		+ "' "
		cQuery += " AND SE1.E1_AGEDEP 		= '" + cSEEAgencia		+ "' "
		cQuery += " AND SE1.E1_CONTA 		= '" + cSEEConta		+ "' "
		cQuery += " AND SE1.E1_NUMBCO		<> ' ' "

		If cSEEBanco == "748" // tratativa para o sicredi
			cQuery += " AND SE1.E1_NUMBCO		BETWEEN '" + AllTrim(cSEEFaixaAtual) + "' AND '" + SubStr(cSEEFaixaAtual,1,1) + Replicate("9", 5 )+ "' "
		Else
			cQuery += " AND SE1.E1_NUMBCO		BETWEEN '" + AllTrim(cSEEFaixaAtual) + "' AND '" +Replicate("9", Val(cLength))+ "' "
		EndIf

	// variavel para terminar o tamanho do campo E1_NUMBCO
		if !empty(alltrim(cLength))
			if cBancoDeDados == "MSSQL"
				cQuery += " AND LEN(SE1.E1_NUMBCO)	= " + cLength + " "
			elseif cBancoDeDados == "ORACLE"
				cQuery += " AND LENGTH(SE1.E1_NUMBCO) = " + cLength + " "
			endIf
		endIf

		cQuery := ChangeQuery(cQuery)

		TcQuery cQuery New Alias "TRBMAX"

		If TRBMAX->(!Eof())
			if !Empty(Alltrim(TRBMAX->FAIXAMAX))
				cSEEFaixaAtual := Alltrim(TRBMAX->FAIXAMAX)
			endIf
		EndIf

	endif

	// verifico se o codigo esta em uso
	FreeUsedCode()
	While !MayIUseCode( "SEE"+xFilial("SEE")+cSEEBanco+cSEEAgencia+cSEEConta+cSEEFaixaAtual )
		// gero um novo nosso numero
		cSEEFaixaAtual := Soma1( Alltrim(cSEEFaixaAtual) )
	EndDo

	// variavel de retorno com a Faixa Atual que esta livre
	cRet := cSEEFaixaAtual

	If Select("TRBMAX") > 0
		TRBMAX->( DbCloseArea() )
	EndIf

	RestArea( aArea )

Return(cRet)

/*/{Protheus.doc} DigNNSicoob
Funcao para gerar o digito verificador do nosso numero
do banco 756-SICOOB
@type function
@version 1.0 
@author g.sampaio
@since 22/02/2021
@param cNossoNum, character, nosso numero gerado
@param cCodEmp, character, codigo da empresa
@param cCodCoop, character, codigo da cooperativa
@param cParcela, character, codigo da parcela
@return character, retorna o digito verificador
/*/
Static Function DigNNSicoob(cNossoNum, cCodEmp, cCodCoop, cParcela)

	Local aConstantes	:= {}
	Local cSequencia	:= ""
	Local cDigit		:= ""
	Local nMod   		:= 11
	Local nI			:= 0
	Local nSoma   		:= 0
	Local nDigit		:= 0

	Default cNossoNum 	:= "0000001"
	Default cCodEmp		:= ""
	Default cCodCoop	:= ""
	Default cParcela	:= "001"

	// refaco o codigo da empresa
	cCodEmp := StrZero(Val(cCodEmp),10)

	// constantes para a geracao do digito verificador
	aConstantes := {3,1,9,7,3,1,9,7,3,1,9,7,3,1,9,7,3,1,9,7,3}

	cSequencia := cCodCoop + cCodEmp + cNossoNum

	For nI := 1 to Len(cSequencia)
		nSoma += Val(SubStr(cSequencia,nI,1)) * aConstantes[nI]
	Next

	nDigit := (nSoma % nMod)

	if nDigit <= 1
		cDigit := '0'
	else
		cDigit := AllTrim(Str(nMod - nDigit))
	endif

Return(cDigit)

Static Function DigNNSicredi(xBaseCDV)

	Local i
	Local nCont 		:= 0
	Local nPeso			:= 9
	Local nResto		:= 0
	Local XDV			:= 0
	Default xBaseCDV 	:= ""

	For i := 19 To 1 Step -1
		nPeso := nPeso + 1
		If nPeso > 9
			nPeso := 2
		Endif
		nCont := nCont + (Val(SUBSTR(xBaseCDV,i,1))) * nPeso
	Next i

	nResto := ( nCont % 11 )
	XDV = 11 - nResto

	If XDV > 9
		XDV = 0
	Endif

Return(Str(XDV,1))

Static Function DigLivSicredi(cLivre)

	Local cRet		:= ""
	Local i			:= 0
	Local nCont 	:= 0
	Local nPeso		:= 9
	Local nResto	:= 0
	Local nResult	:= 0

	For i := 1 To 24
		nCont := nCont + (Val(SUBSTR(cLivre,i,1))) * nPeso
		nPeso := nPeso - 1
		If nPeso == 1
			nPeso := 9
		Endif
	Next

	nResto  := Round( nCont / 11, 2 )
	nResult := nCont - ( Int( nResto ) * 11 )

	If nResult < 2
		cRet := "0"
	Else
		cRet := Str( 11 - nResult,1)
	EndIf

Return(cRet)

Static Function DigBarSicredi(cBarra)

	Local cRet		:= ""
	Local i			:= 0
	Local nCont 	:= 0
	Local nPeso		:= 2
	Local nResto	:= 0
	Local nResult	:= 0

	nCont := 0
	nPeso := 2
	For i := 43 To 1 Step -1
		nCont := nCont + ( Val( SUBSTR( cBarra,i,1 )) * nPeso )
		nPeso := nPeso + 1
		If nPeso >  9
			nPeso := 2
		Endif
	Next
	nResto  := ( nCont % 11 )
	nResult := ( 11 - nResto )

	If nResult < 2 .OR. nResult > 9
		cRet := "1"
	Else
		cRet := Str(nResult,1)
	EndIf

Return(cRet)

Static Function GeraDigNosNum(cCodBanco, cNossoNum, aDadosBanco )

	Local cRetorno := ""

	Default cCodBanco	:= ""
	Default cNossoNum	:= ""
	Default aDadosBanco	:= {}

	if SEE->EE_CODIGO == '341'

		cTexto    := aDadosBanco[03] + aDadosBanco[04] + aDadosBanco[6] + cNossoNum

		cRetorno := Modu10(cTexto)

		///////////////////////////////////
		// 		BANCO SANTANDER - 033	//
		///////////////////////////////////
	elseif SEE->EE_CODIGO == '033'

		cRetorno := Dig11Santander(cNossoNum)

		/////////////////////////////////////////
		/// 		BANCO CAIXA - 104		///
		/////////////////////////////////////////
	elseif SEE->EE_CODIGO $ '104'

		cRetorno 	:= Modu11(cNossoNum,,"CX",2)

		//////////////////////////////////
		//////// BANCO BRASIL - 001 //////
		//////////////////////////////////
	elseif SEE->EE_CODIGO == '001'

		if Len( AllTrim(SEE->EE_CODEMP) ) < 7

			cRetorno 	:= Dig11BB(AllTrim(SEE->EE_CODEMP)+cNossoNum )

		elseif Len( AllTrim(SEE->EE_CODEMP) ) == 7

			cRetorno 	:= ""
		endif

		/////////////////////////////////////
		///////		BRADESCO - 237		/////
		/////////////////////////////////////
	elseif SEE->EE_CODIGO == '237'

		cRetorno 	:= Modu11( Alltrim(aDadosBanco[6]) + cNossoNum, 7 , "P")

		/////////////////////////////////////
		///////		SICOOB - 756		/////
		/////////////////////////////////////
	elseIf SEE->EE_CODIGO == '756'

		cRetorno 	:= DigNNSicoob(cNossoNum, AllTrim(SEE->EE_CODEMP),AllTrim(SEE->EE_AGENCIA))

		/////////////////////////////////////
		///////		SICREDI - 748		/////
		/////////////////////////////////////
	elseIf SEE->EE_CODIGO == '748'

		cRetorno 	:= DigNNSicredi(AllTrim(SEE->EE_AGENCIA)+AllTrim(SEE->EE_INSTSEC)+AllTrim(SEE->EE_CODEMP)+cNossoNum)

	endIf

Return(cRetorno)
