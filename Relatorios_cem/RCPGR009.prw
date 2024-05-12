#include "totvs.ch"

#define DMPAPER_A4 9    // A4 210 x 297 mm

/*/{Protheus.doc} RCPGR009
Impressão de Guia de autorização de Cremação
@author TOTVS
@since 15/04/2016
@version P12
@param nulo
@return nulo
/*/

User Function RCPGR009( cCodServico, cCodApontamento, cCodContrato )

	Local aArea             := GetArea()
	Local aAreaSB1          := SB1->(GetArea())

	Default cCodServico     := ""
	Default cCodApontamento := ""
	Default cCodContrato    := ""

	// posicino no cadastro de produto para validar se o servico e de jazigo
	SB1->( DbSetOrder(1) )
	If SB1->( MsSeek( xFilial("SB1")+cCodServico ) )

		// verifico o campo de endereco
		If SB1->B1_XREQSER == "C"

			// faco a impressão do termo de autorização de sepultamento
			Imprime( cCodApontamento, cCodContrato )

		Else
			MsgAlert("Não é possível imprimir de autorização de cremação, o serviço executado não é destinado ao endereço Crematório!")
		EndIf

	EndIf

	RestArea( aAreaSB1 )
	RestArea( aArea )

Return( Nil )

/*/{Protheus.doc} Imprime
faco a impressao da guia de sepultamento
@type function
@version 
@author g.sampaio
@since 14/05/2020
@param cCodApontamento, character, codigo do apontamento
@param cCodContrato, character, codigo do contrato
@return Nil
/*/
Static Function Imprime( cCodApontamento, cCodContrato )

	Local nLin              := 0
	Local oRel              := Nil

	Default cCodApontamento := ""
	Default cCodContrato    := ""

	// inicio o objeto de impressao TmsPrinter
	oRel := TmsPrinter():New("")
	oRel:SetPortrait()
	oRel:SetPaperSize(9) //A4

	// imprimo o cabecalho do relatorio
	CabecRel( @oRel, @nLin )

	// imprimo o corpo do relatorio
	CorpoRel( @oRel, @nLin, cCodContrato, cCodApontamento )

	// imprimo o rodape do relatorio
	RodRel( @oRel, @nLin )

	oRel:Preview()

Return(Nil)

/*/{Protheus.doc} CabecRel
funcao que imprimo o cabecalho do relatorio
@type function
@version 
@author TOTVS
@since 14/04/2016
@param oRel, object, objeto do relatorio
@param nLin, numeric, variavel de linha do relatorio
@return nil
/*/
Static Function CabecRel( oRel, nLin )

	Local aArea         := GetArea()
	Local cStartPath    := ""
	Local oFont14N      := TFont():New('Arial',,14,,.T.,,,,.F.,.F.) 				//Fonte 14 Negrito

	Default nLin        := 0

	// inicio o valor da linha
	nLin := 80

	// pego o caminho da startpath
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")

	oRel:StartPage() //Inicia uma nova pagina

	// imprirmo a logo da empresa
	oRel:SayBitMap(nLin + 15,100,cStartPath + "LGMID01.png",400,214)

	// faco a impressao do titulo do relatorio
	oRel:Say(nLin + 80,880,"AUTORIZAÇÃO DE CREMAÇÃO",oFont14N)

	// faco um salto de linhas na impressao
	nLin += 300

	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} CorpoRel
imprimo o corpo do relatorio
@type function
@version 
@author TOTVS
@since 14/04/2016
@param oRel, object, objeto de impressao do relatorio
@param nLin, numeric, numero da linha de impressao
@param cCodContrato, character, codigo do contrato
@param cCodApontamento, character, codigo do apontamento
@return return_type, return_description
/*/
Static Function CorpoRel( oRel, nLin, cCodContrato, cCodApontamento )

	Local aArea             := GetArea()
	Local aAreaU00          := U00->( GetArea() )
	Local aAreaUJV          := UJV->( GetArea() )
	Local aEstCivil 		:= RetSX3Box(GetSX3Cache("UJV_ESTCIV","X3_CBOX"),,,1)
	Local cCodTab			:= SuperGetMv("MV_XTABPAD",.F.,"001")
	Local cServLoc 			:= SuperGetMv("MV_XPRLOCF",.F.,"000245")
	Local cNomeEmp			:= AllTrim(U_RetInfSM0(cEmpAnt,cFilAnt,"M0_NOMECOM")) // Nome COmercial da Empresa Logada
	Local cMunicip			:= AllTrim(U_RetInfSM0(cEmpAnt,cFilAnt,"M0_CIDENT")) // Municipio da Empresa Logada
	Local cRetGrauPar		:= ""
	Local cGrauPar			:= ""
	Local cEstCivil			:= ""
	Local nPosEstCivil		:= 0
	Local nVlrLoc			:= Posicione("DA1",1,xFilial("DA1")+cCodTab+cServLoc,"DA1_PRCVEN")
	Local oFont10			:= TFont():New('Arial',,10,,.F.,,,,.F.,.F.) 				//Fonte 10 Normal
	Local oFont12			:= TFont():New('Arial',,12,,.F.,,,,.F.,.F.) 				//Fonte 12 Normal

	Default nLin            := 0
	Default cCodContrato    := ""
	Default cCodApontamento := ""

	// posiciono no cadastro de clientes
	U00->( DbSetOrder(1) )
	If U00->( MsSeek( xFilial("U00")+cCodContrato ) )

		// posiciono no apontamento
		UJV->( DbSetOrder(1) ) // UJV_FILIAL+UJV_CODIGO
		If UJV->( MsSeek(xFilial("UJV")+cCodApontamento) )

			// posiciono no cadastro do autorizado
			U02->( DbSetOrder(1) )
			U02->( MsSeek( xFilial("U02")+U00->U00_CODIGO+UJV->UJV_AUTORI ) )


			oRel:Box(nLin,120,nLin + 60,2240)// box numero da ordem de servicos-apontamento
			oRel:Box(nLin,1000,nLin + 60,2240)// box nome do atendente

			nLin+=15

			// numero da ordem de servicos-apontamento
			oRel:Say(nLin,140,"ORDEM DE SERVIÇO DE Nº.: " + cCodApontamento,oFont10)

			// nome do atendente
			oRel:Say(nLin,1020,"ATENDENTE: " + cUserName,oFont10)

			nLin+= 100

			//retorno a descricao do estado civil de acordo com a X3
			If !Empty(UJV->UJV_ESTCIV)

				// pego a descrição do estado civiil
				nPosEstCivil	:= aScan(aEstCivil,{|x| AllTrim(x[2]) == UJV->UJV_ESTCIV})

				// verifico se encontou o estado civil
				If nPosEstCivil > 0
					cEstCivil		:= aEstCivil[nPosEstCivil,3]
				EndIf

			EndIf

			// ===================================================
			// CAMPO 01
			// ===================================================

			oRel:Say(nLin,1100,"CAMPO 01",oFont12)

			nLin+=50
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"SERVIÇO PARTICULAR: ("+IIF(U00->U00_FAQUIS == "I","X",Space(2))+")   PLANO DE CREMAÇÃO ("+IIF(U00->U00_FAQUIS == "P","X",Space(2))+")",oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"CORPO: ("+IIF(UJV->UJV_TPCREM == "C","X",Space(2))+")" + Space(12) + "OSSOS ("+IIF(UJV->UJV_TPCREM == "O","X",Space(2))+")" + Space(12) + "VÍSCERAS ("+IIF(UJV->UJV_TPCREM == "V","X",Space(2))+")" + Space(12) + "OSSOS E VÍSCERAS ("+IIF(UJV->UJV_TPCREM == "E","X",Space(2))+")",oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"NOME: " + UJV->UJV_NOME,oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"DATA DO FALECIMENTO: " + DToC(UJV->UJV_DTOBT),oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"HORA: " + Transform(UJV->UJV_HORA,"@R 99:99"),oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"IDADE DO FALECIDO: " + cValToChar(Calc_Idade(dDataBase,UJV->UJV_DTNASC)) + " ANOS",oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"ESTADO CIVIL: " + Upper(Alltrim(cEstCivil)) ,oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"SEXO: ("+IIF(UJV->UJV_SEXO == "M","X",Space(2))+") MASCULINO" + Space(12) + "("+IIF(UJV->UJV_SEXO == "F","X",Space(2))+") FEMININO",oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"NATURALIDADE: " +AllTrim(UJV->UJV_MUN)+ "-" + Alltrim(UJV->UJV_UF) + Space(80) + "NACIONALIDADE: " + UJV->UJV_DESNAT,oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"CAUSA DE FALECIMENTO: " + UJV->UJV_CAUSA,oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"LOCAL E LOCALIDADE DO FALECIMENTO: " + UJV->UJV_LOCFAL,oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"NOME DA MÃE: " + UJV->UJV_NOMAE,oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"DATA DA CERTIDÃO DE ÓBITO: " + DToC(UJV->UJV_DTCERT),oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"EMPRESA FUNERÁRIA/CEMITÉRIO DE ORIGEM: " + UJV->UJV_FUNERA,oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"REALIZAÇÃO DA CREMAÇÃO: ("+IIF(UJV->UJV_REALIZ == "C","X",Space(2))+") SOMENTE COM ORDEM JUDICIAL" + Space(12) + "("+IIF(UJV->UJV_REALIZ == "S","X",Space(2))+") SEM ORDEM JUDICIAL",oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"DATA PREVISTA PARA CREMAÇÃO: " + DToC(UJV->UJV_DTSEPU),oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"VALOR DIÁRIO DA LOCAÇÃO DA CÂMARA FRIA: R$" + AllTrim(Transform(nVlrLoc,"@E 999,999.99")) + " (" + Lower(Extenso(nVlrLoc)) + ")",oFont10)

			nLin +=100
			oRel:Box(nLin,120,nLin + 120,2240)

			// ===================================================
			// CAMPO 02
			// ===================================================

			nLin+=15
			oRel:Say(nLin,1100,"CAMPO 02",oFont12)

			nLin+=60
			oRel:Say(nLin,850,"DADOS DO SOLICITANTE DO SERVIÇO",oFont12)

			nLin+=65
			oRel:Box(nLin,120,nLin + 70,2240)

			nLin+=15
			oRel:Say(nLin,140,"NOME: " + U02->U02_NOME,oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"C.I.: " + U02->U02_CI + Space(50) + "ÓRGÃO EXPEDIDOR: " + U02->U02_ORGAOE, oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"CPF/MF: " + U02->U02_CPF, oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			// grau de parentesco
			cRetGrauPar := U02->U02_GRAUPA

			If cRetGrauPar== "CO" //Conjuge
				cGrauPar := "Conjuge"
			ElseIf cRetGrauPar == "FI" //Filho(a)
				cGrauPar := "Filho(a)"
			ElseIf cRetGrauPar == "IR" //Irmao(a)
				cGrauPar := "Irmao(a)"
			ElseIf cRetGrauPar == "NE" //Neto(a)
				cGrauPar := "Neto(a)"
			ElseIf cRetGrauPar == "OU" //Outros
				cGrauPar := "Outros"
			Endif

			nLin+=15
			oRel:Say(nLin,140,"GRAU DE PARENTESCO: " + cGrauPar,oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"ENDEREÇO: " + AllTrim(U02->U02_END) + U02->U02_COMPLE,oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"CIDADE/ESTADO: " + AllTrim(U02->U02_MUN) + " - " + U02->U02_EST,oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"TELEFONE FIXO: " + U02->U02_FONE,oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"TELEFONE CELULAR: " + U02->U02_CELULA,oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"E-MAIL: " + U02->U02_EMAIL,oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,140,"PESSOA AUTORIZADA PELO SOLICITANTE PARA RETIRADA DAS CINZAS: " + U00->U00_PESRES,oFont10)

			nLin+=45
			oRel:Box(nLin,120,nLin + 60,2240)

			nLin+=15
			oRel:Say(nLin,850,"________________________________________",oFont10)

			nLin+=45
			oRel:Say(nLin,950,U02->U02_NOME,oFont10)

			nLin += 100
			oRel:Box(nLin,120,nLin + 600,2240)

			// ===================================================
			// DECLARACAO
			// ===================================================

			nLin+=15
			oRel:Say(nLin,1000,"DECLARAÇÃO",oFont12)

			nLin+=100
			oRel:Say(nLin,240,"Declaro junto a empresa " + cNomeEmp + ", que todos os dados disponíveis nos Campos 01 e 02 são verdadeiros",oFont10)

			nLin+=60
			oRel:Say(nLin,240,"autorizando a cremação do corpo/restos mortais entregue à esta empresa por mim, em conformidade com as",oFont10)

			nLin+=60
			oRel:Say(nLin,240,"cláusulas estipuladas no contrato de prestação de serviços e Regulamento do Crematório " + cNomeEmp + ",",oFont10)

			nLin+=60
			oRel:Say(nLin,240,"autorizando a pessoa no campo 02 a efetuar a retirada das cinzas, sob as penas da lei.",oFont10)

			nLin+=105
			oRel:Say(nLin,900, cMunicip + "," + DToC(dDataBase),oFont10)

			nLin+=105
			oRel:Say(nLin,850,"________________________________________",oFont10)

			nLin+=45
			oRel:Say(nLin,950,U02->U02_NOME,oFont10)

			nLin += 100			
			oRel:Say(nLin,140,"Testemunha:",oFont10)
			oRel:Say(nLin,1300,"Testemunha:",oFont10)

			nLin+=60
			oRel:Say(nLin,140,"RG:",oFont10)
			oRel:Say(nLin,1300,"RG:",oFont10)

			nLin+=60
			oRel:Say(nLin,140,"CPF:",oFont10)
			oRel:Say(nLin,1300,"CPF:",oFont10)

			nLin += 100

		EndIf

	EndIf

	RestArea( aAreaUJV )
	RestArea( aAreaU00 )
	RestArea( aArea )

Return(Nil)

/*/{Protheus.doc} RodRel
imprimo o rodape do relatorio
@type function
@version 
@author g.sampaio
@since 13/05/2020
@return return_type, return_description
/*/
Static Function RodRel( oRel, nLin)

	Local oFont8	:= TFont():New('Arial',,8,,.F.,,,,.F.,.F.) 					//Fonte 8 Normal

	Default nLin    := 0

	oRel:Line(nLin,0120,nLin,2240)
	oRel:Say(nLin,0110,"TOTVS - Protheus",oFont8)

	oRel:EndPage()

Return( Nil )
