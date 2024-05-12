#include "protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} RFUNR010
Relatório Ordem de Serviço
@author TOTVS
@since 06/10/2016
@version P12
@param nulo
@return nulo
@history 20/05/2020, g.sampaio, realizada manutencao na funcao ImpOrdSrv
/*/

/******************************************/
User Function RFUNR010(cPv,cContrato,cApto)
/******************************************/

	Local nX

	Private oFont6			:= TFont():New("Arial",,6,.T.,.F.,5,.T.,5,.T.,.F.) 			//Fonte 6 Normal
	Private oFont6N 		:= TFont():New("Arial",,6,,.T.,,,,.T.,.F.) 					//Fonte 6 Negrito
	Private oFont8			:= TFont():New('Arial',,8,,.F.,,,,.F.,.F.) 					//Fonte 8 Normal
	Private oFont8N			:= TFont():New('Arial',,8,,.T.,,,,.F.,.F.) 				 	//Fonte 8 Negrito
	Private oFont9			:= TFont():New('Arial',,9,,.F.,,,,.F.,.F.) 					//Fonte 9 Normal
	Private oFont9N			:= TFont():New('Arial',,9,,.T.,,,,.F.,.F.) 				 	//Fonte 9 Negrito
	Private oFont8NI		:= TFont():New('Times New Roman',,8,,.T.,,,,.F.,.F.,.T.) 	//Fonte 8 Negrito e Itálico
	Private oFont10			:= TFont():New('Arial',,10,,.F.,,,,.F.,.F.) 				//Fonte 10 Normal
	Private oFont10N		:= TFont():New('Arial',,10,,.T.,,,,.F.,.F.) 				//Fonte 10 Negrito
	Private oFont10			:= TFont():New('Arial',,12,,.F.,,,,.F.,.F.) 				//Fonte 12 Normal
	Private oFont10N		:= TFont():New('Arial',,12,,.T.,,,,.F.,.F.) 			 	//Fonte 12 Negrito
	Private oFont13N		:= TFont():New('Arial',,13,,.T.,,,,.F.,.F.) 				//Fonte 13 Negrito
	Private oFont14			:= TFont():New('Arial',,14,,.F.,,,,.F.,.F.) 				//Fonte 14 Normal
	Private oFont14N		:= TFont():New('Arial',,14,,.T.,,,,.F.,.F.) 				//Fonte 14 Negrito
	Private oFont14NI		:= TFont():New('Times New Roman',,14,,.T.,,,,.F.,.F.,.T.) 	//Fonte 14 Negrito e Itálico
	Private oFont16N		:= TFont():New('Arial',,16,,.T.,,,,.F.,.F.) 				//Fonte 16 Negrito
	Private oFont16NI		:= TFont():New('Times New Roman',,16,,.T.,,,,.F.,.F.,.T.) 	//Fonte 16 Negrito e Itálico
	Private oFont18			:= TFont():New("Arial",,18,,.F.,,,,,.F.,.F.)				//Fonte 18 Negrito
	Private oFont18N		:= TFont():New("Arial",,18,,.T.,,,,,.F.,.F.)				//Fonte 18 Negrito
	Private oFont22			:= TFont():New("Arial",,22,,.F.,,,,,.F.,.F.)				//Fonte 26 Normal

	Private oBrush			:= TBrush():New(,CLR_HGRAY)

	Private cPerg			:= "RFUNR010"

	Private cStartPath
	Private nLin

	Private oRel			:= TmsPrinter():New("")

	Private aDados			:= {}

	If ValType(cPv) == "U"
		If !ValidPerg()
			Return
		Endif
	Endif

	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")

	oRel:SetPaperSize(DMPAPER_A4)

	oRel:SetPortrait() //Define a orientacao da impressao como retrato

	If ValType(cPv) == "U"
		aDados 		:= BuscaDados()
	Else
		aDados 		:= {{cPv,cContrato,cApto}}
	Endif

	For nX := 1 To Len(aDados)
		MsgRun("Imprimindo...","Aguarde",{||ImpOrdSrv(aDados[nX][1],aDados[nX][2],aDados[nX][3])})
	Next

	oRel:Preview()

Return

/***************************/
Static Function BuscaDados()
/***************************/

	Local aRet 	:= {}

	Local cQry	:= ""

	If Select("QRYSRV") > 0
		QRYSRV->(DbCloseArea())
	Endif

	cQry := "SELECT C5_NUM, C5_XCTRFUN, C5_XAPTOFU"
	cQry += " FROM "+RetSqlName("SC5")+" SC5"
	cQry += " WHERE SC5.D_E_L_E_T_ 	<> '*'"
	cQry += " AND SC5.C5_FILIAL 	= '"+xFilial("SC5")+"'"
	cQry += " AND SC5.C5_XCTRFUN	BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"

	If !Empty(MV_PAR03)
		cQry += " AND SC5.C5_EMISSAO	>= '"+DToS(MV_PAR03)+"'"
	Endif
	If !Empty(MV_PAR04)
		cQry += " AND SC5.C5_EMISSAO	<= '"+DToS(MV_PAR04)+"'"
	Endif

	cQry += " AND SC5.C5_NUM		BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'"
	cQry += " AND SC5.C5_CLIENTE	BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR09+"'"
	cQry += " AND SC5.C5_LOJACLI	BETWEEN '"+MV_PAR08+"' AND '"+MV_PAR10+"'"

	cQry += " ORDER BY 1,2"

	cQry := ChangeQuery(cQry)

	TcQuery cQry NEW Alias "QRYSRV"

	While QRYSRV->(!EOF())

		AAdd(aRet,{QRYSRV->C5_NUM,QRYSRV->C5_XCTRFUN,QRYSRV->C5_XAPTOFU})

		QRYSRV->(dbSkip())
	EndDo

	If Select("QRYSRV") > 0
		QRYSRV->(DbCloseArea())
	Endif

Return aRet

/*/{Protheus.doc} ImpOrdSrv
description
@type function
@version 
@author g.sampaio
@since 21/05/2020
@param cPv, character, param_description
@param cContrato, character, param_description
@param cApto, character, param_description
@return return_type, return_description
@history 20/05/2020, g.sampaio, VPDV-469 - implementado o cabeçalho da função ImpOrdSrv e 
Alterado o uso das tabelas UG0 e UG1 (Apontamento de serviços antigo) para a o uso das tabelas UJ0 e UJ1 (Apontamento de serviços Mod.2)
/*/
/*********************************************/
Static Function ImpOrdSrv(cPv,cContrato,cApto)
/*********************************************/

	Local nPag			:= 1
	Local nSomaLin		:= 80
	Local nMargemV		:= 20
	Local nMargemD		:= 2328

	Local cQry			:= ""

	Local cNf			:= ""
	Local cDecObt		:= ""
	Local cCadObt		:= ""
	Local cNomeFa		:= ""
	Local cLocRem		:= ""
	Local cCli			:= ""
	Local cCliLoja		:= ""
	Local cCliNome		:= ""
	Local cDDD			:= ""
	Local cTel			:= ""
	Local cEnd			:= ""
	Local cComplem		:= ""
	Local cBairro		:= ""
	Local cPessoa		:= ""
	Local cCGC			:= ""
	Local cRG			:= ""
	Local cLocVel		:= ""
	Local cTpServ		:= ""
	Local cLocSer		:= ""
	Local cMotoriR		:= ""
	Local cMotoriV		:= ""
	Local cMotoriS		:= ""
	Local cReligiao		:= ""
	Local cAtendente	:= ""

	Local aItens		:= {}
	Local nI
	Local nTot			:= 0

//Carrega as variáveis a serem utilizadas na impressão do relatório
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM

	If SC5->(DbSeek(xFilial("SC5")+cPv))

		cNf 		:= SC5->C5_NOTA
		cCli		:= SC5->C5_CLIENTE
		cCliLoja	:= SC5->C5_LOJACLI
		cCliNome	:= Posicione("SA1",1,xFilial("SA1")+cCli+cCliLoja,"A1_NOME")
		cDDD		:= Posicione("SA1",1,xFilial("SA1")+cCli+cCliLoja,"A1_DDD")
		cTel		:= Posicione("SA1",1,xFilial("SA1")+cCli+cCliLoja,"A1_TEL")
		cEnd		:= Posicione("SA1",1,xFilial("SA1")+cCli+cCliLoja,"A1_END")
		cComplem	:= Posicione("SA1",1,xFilial("SA1")+cCli+cCliLoja,"A1_COMPLEM")
		cBairro		:= Posicione("SA1",1,xFilial("SA1")+cCli+cCliLoja,"A1_BAIRRO")
		cPessoa		:= Posicione("SA1",1,xFilial("SA1")+cCli+cCliLoja,"A1_PESSOA")
		cCGC		:= Posicione("SA1",1,xFilial("SA1")+cCli+cCliLoja,"A1_CGC")
		cRG			:= Posicione("SA1",1,xFilial("SA1")+cCli+cCliLoja,"A1_PFISICA")

		If !Empty(cApto) //Derivou de Contrato

			// posiciono na nova tabela
			UJ0->(DbSetOrder(1)) //UJ0_FILIAL+UJ0_CODIGO
			If UJ0->(DbSeek(xFilial("UJ0")+cApto))

				cDecObt		:= UJ0->UJ0_DECOBT
				cCadObt		:= UJ0->UJ0_CADOBT

				// verifico o codigo do beneficiario esta preenchido
				If !Empty( UJ0->UJ0_CODBEN )
					cNomeFa		:= Posicione("UF4",1,xFilial("UF4")+cContrato+UJ0->UJ0_CODBEN,"UF4_NOME")
				EndIf

				cLocRem		:= UJ0->UJ0_LOCREM
				cLocVel		:= UJ0->UJ0_LOCVEL
				cTpServ		:= IIF(UJ0->UJ0_SERVIC == "S","Sepultamento","Cremação")
				cLocSer		:= UJ0->UJ0_LOCSER
				cMotoriR	:= Posicione("UF6",1,xFilial("UF6")+UJ0->UJ0_MOTREM,"UF6_NOME")				
				cMotoriV	:= Posicione("UF6",1,xFilial("UF6")+UJ0->UJ0_MOTORI,"UF6_NOME")
				cMotoriS	:= Posicione("UF6",1,xFilial("UF6")+UJ0->UJ0_MOTORS,"UF6_NOME")
				cReligiao	:= Posicione("UG3",1,xFilial("UG3")+UJ0->UJ0_RELIGI,"UG3_DESC")
				cAtendente	:= UJ0->UJ0_ATENDE

			Endif

		Else //Particular

			cDecObt		:= SC5->C5_XDECOBT
			cCadObt		:= SC5->C5_XCADOBT
			cNomeFa		:= SC5->C5_XNOMEFA
			cLocRem		:= SC5->C5_XLOCREM
			cLocVel		:= SC5->C5_XLOCVEL
			cTpServ		:= IIF(SC5->C5_XTPSERV == "S","Sepultamento","Cremação")
			cLocSer		:= SC5->C5_XLOCSER
			cMotoriR	:= Posicione("UF6",1,xFilial("UF6")+SC5->C5_XMOTORI,"UF6_NOME")
			cMotoriV	:= Posicione("UF6",1,xFilial("UF6")+SC5->C5_XMOTVER,"UF6_NOME")
			cMotoriS	:= Posicione("UF6",1,xFilial("UF6")+SC5->C5_XMOTSEP,"UF6_NOME")
			cReligiao	:= Posicione("UG3",1,xFilial("UG3")+SC5->C5_XRELIGI,"UG3_DESC")
			cAtendente	:= SC5->C5_XATENDE

		Endif

		//Itens
		DbSelectArea("UJ1")
		UJ1->(DbSetOrder(1)) //UJ1_FILIAL+UJ1_CODIGO+UJ1_ITEM

		If UJ1->(DbSeek(xFilial("UJ1")+cApto))

			While UJ1->(!EOF()) .And. UJ1->UJ1_FILIAL == xFilial("UJ1") .And. UJ1->UJ1_CODIGO == cApto

				If UJ1->UJ1_OK .And. UJ1->UJ1_PV == "N"

					AAdd(aItens,{AllTrim(UJ1->UJ1_PRODUT) + " - " + SubStr(Posicione("SB1",1,xFilial("SB1")+UJ1->UJ1_PRODUT,"B1_DESC"),1,36),;
						Posicione("SB1",1,xFilial("SB1")+UJ1->UJ1_PRODUT,"B1_XCODSEM"),;
						UJ1->UJ1_PRCVEN - UJ1->UJ1_VLRDES})

				Endif

				UJ1->(DbSkip())
			EndDo
		Endif

		DbSelectArea("SC6")
		SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM

		If SC6->(DbSeek(xFilial("SC6")+cPv))

			While SC6->(!EOF()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == cPv

				AAdd(aItens,{AllTrim(SC6->C6_PRODUTO) + " - " + SubStr(Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_DESC"),1,36),;
					Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_XCODSEM"),;
					SC6->C6_VALOR})

				SC6->(DbSkip())
			EndDo
		Endif
	Else
		MsgInfo("Pedido de Venda <"+cPv+"> não localizado, impressão cancelada.")
		Return
	Endif

	oRel:StartPage() //Inicia uma nova página

	nLin := 100

//Logo 
	oRel:SayBitMap(nLin,100,cStartPath + "LGMID01.png",400,214)

//Título e página
	oRel:Say(nLin + 120,1020,"Ordem de Serviço",oFont14N)

	nLin += 220

//Moldura 
//oRel:Box(nLin,0120,3266,2378)

//Dados
	oRel:Box(nLin,0120,nLin + nSomaLin,0872)
	oRel:Say(nLin + nMargemV,0155,"Data:",oFont10N)
	oRel:Say(nLin + nMargemV,0405,DToC(dDataBase),oFont10)
	oRel:Box(nLin,872,nLin + nSomaLin,1624)
	If !Empty(cContrato)
		oRel:Say(nLin + nMargemV,0907,"Contrato:",oFont10N)
		oRel:Say(nLin + nMargemV,1157,cContrato,oFont10)
	Else
		oRel:Say(nLin + nMargemV,0907,"Pedido:",oFont10N)
		oRel:Say(nLin + nMargemV,1157,cPv,oFont10)
	Endif
	oRel:Box(nLin,1624,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,1659,"Nota Fiscal:",oFont10N)
	oRel:Say(nLin + nMargemV,1959,cNf,oFont10)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + nSomaLin,1209)
	oRel:Say(nLin + nMargemV,0155,"Declaração de Óbito:",oFont10N)
	oRel:Say(nLin + nMargemV,0635,cDecObt,oFont10)
	oRel:Box(nLin,1209,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,1284,"Cadastro de Óbito:",oFont10N)
	oRel:Say(nLin + nMargemV,1724,cCadObt,oFont10)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + nSomaLin,0620)
	oRel:Say(nLin + nMargemV,0155,"Nome do Falecido:",oFont10N)
	oRel:Box(nLin,620,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,0700,cNomeFa,oFont10)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + nSomaLin,0620)
	oRel:Say(nLin + nMargemV,0155,"Local de Remoção:",oFont10N)
	oRel:Box(nLin,620,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,0700,cLocRem,oFont10)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + nSomaLin,0620)
	oRel:Say(nLin + nMargemV,0155,"Responsável:",oFont10N)
	oRel:Box(nLin,0620,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,0700,cCli + "-" + cCliLoja + "/" + cCliNome,oFont10)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + nSomaLin,0620)
	oRel:Say(nLin + nMargemV,0155,"Telefone:",oFont10N)
	oRel:Box(nLin,0620,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,0700,IIF(!Empty(cDDD),AllTrim(cDDD) + Space(1) + cTel,cTel),oFont10)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + (nSomaLin * 2),nMargemD)
	oRel:Box(nLin,0120,nLin + (nSomaLin * 2),0620)
	oRel:Say(nLin + nMargemV,0155,"Endereço Completo:",oFont10N)
	oRel:Say(nLin + nMargemV,0700,SubStr(cEnd,1,56),oFont10)
	nLin += nSomaLin
	oRel:Say(nLin + nMargemV,0700,IIF(!Empty(cComplem),SubStr(AllTrim(cComplem) + " - " + cBairro,1,56),cBairro),oFont10)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + nSomaLin,1209)
	oRel:Say(nLin + nMargemV,0155,"CPF/CNPJ:",oFont10N)
	If cPessoa == "F" //Pessoa Física
		oRel:Say(nLin + nMargemV,0445,Transform(cCGC,"@R 999.999.999-99"),oFont10)
	Else
		oRel:Say(nLin + nMargemV,0445,Transform(cCGC,"@R 99.999.999/9999-99"),oFont10)
	Endif
	oRel:Box(nLin,1209,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,1284,"RG:",oFont10N)
	oRel:Say(nLin + nMargemV,1454,cRG,oFont10)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + nSomaLin,0620)
	oRel:Say(nLin + nMargemV,0155,"Local do Velório:",oFont10N)
	oRel:Box(nLin,0620,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,0700,cLocVel,oFont10)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + nSomaLin,0620)
	oRel:Say(nLin + nMargemV,0155,cTpServ,oFont10N)
	oRel:Box(nLin,0620,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,0700,cLocSer,oFont10)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + nSomaLin,0620)
	oRel:Say(nLin + nMargemV,0155,"Motorista Remoção:",oFont10N)
	oRel:Box(nLin,0620,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,0700,cMotoriR,oFont10)

	If UJ0->(FieldPos("UJ0_MOTVER")) > 0

		nLin += nSomaLin

		oRel:Box(nLin,0120,nLin + nSomaLin,0620)
		oRel:Say(nLin + nMargemV,0155,"Motorista Velório:",oFont10N)
		oRel:Box(nLin,0620,nLin + nSomaLin,nMargemD)
		oRel:Say(nLin + nMargemV,0700,cMotoriV,oFont10)
	Endif

	If UJ0->(FieldPos("UJ0_MOTSEP")) > 0

		nLin += nSomaLin

		oRel:Box(nLin,0120,nLin + nSomaLin,0620)
		oRel:Say(nLin + nMargemV,0155,"Motorista Sepultamento:",oFont10N)
		oRel:Box(nLin,0620,nLin + nSomaLin,nMargemD)
		oRel:Say(nLin + nMargemV,0700,cMotoriS,oFont10)
	Endif

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + nSomaLin,0620)
	oRel:Say(nLin + nMargemV,0155,"Religião:",oFont10N)
	oRel:Box(nLin,0620,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,0700,cReligiao,oFont10)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + nSomaLin,0620)
	oRel:Say(nLin + nMargemV,0155,"Atendente:",oFont10N)
	oRel:Box(nLin,0620,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,0700,Upper(cAtendente),oFont10)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + nSomaLin,0620)
	oRel:Say(nLin + nMargemV,0155,"Forma de Pagamento: ",oFont10N)
	oRel:Box(nLin,0620,nLin + nSomaLin,nMargemD)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + nSomaLin,1209)
	oRel:Say(nLin + nMargemV,0155,"Nº do Cheque: ",oFont10N)
	oRel:Box(nLin,1209,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,1284,"Valor de cada Cheque: ",oFont10N)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,0155,"Vencimento: ",oFont10N)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + nSomaLin,0872)
	oRel:Say(nLin + nMargemV,0155,"Banco: ",oFont10N)
	oRel:Box(nLin,872,nLin + nSomaLin,1624)
	oRel:Say(nLin + nMargemV,0907,"Agência: ",oFont10N)
	oRel:Box(nLin,1624,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,1659,"Conta: ",oFont10N)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + nSomaLin,1400)
	oRel:Say(nLin + nMargemV,0155,"Produto",oFont10N)
	oRel:Box(nLin,1400,nLin + nSomaLin,1850)
	oRel:Say(nLin + nMargemV,1450,"Código SEMAS",oFont10N)
	oRel:Box(nLin,1850,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,2020,"Valor",oFont10N)

	nLin += nSomaLin

//Itens
	For nI := 1 To Len(aItens)

		If nLin > 2400

			//Rodapé
			nLin := 3280

			oRel:Line(nLin,0120,nLin,nMargemD)
			oRel:Say(nLin + nMargemV + 10,0110,"TOTVS - Protheus",oFont8)
			oRel:Say(nLin + nMargemV + 10,nMargemD - 140,"Página " + cValToChar(nPag),oFont8)

			oRel:EndPage() //Finaliza página
			oRel:StartPage() //Inicia uma nova página

			nPag++

			nLin := 100

			//Logo
			oRel:SayBitMap(nLin,100,cStartPath + "LGMID01.png",400,214)

			//Título e página
			oRel:Say(nLin + 120,1020,"Ordem de Serviço",oFont14N)

			nLin += 220
		Endif

		oRel:Box(nLin,0120,nLin + nSomaLin,1400)
		oRel:Say(nLin + nMargemV,0155,aItens[nI][1],oFont10)
		oRel:Box(nLin,1400,nLin + nSomaLin,1850)
		oRel:Say(nLin + nMargemV,1450,aItens[nI][2],oFont10)
		oRel:Box(nLin,1850,nLin + nSomaLin,nMargemD)
		oRel:Say(nLin + nMargemV,1970,Transform(aItens[nI][3],"@E 999,999,999.99"),oFont10)

		nTot += aItens[nI][3]

		nLin += nSomaLin
	Next

	oRel:Box(nLin,0120,nLin + nSomaLin,nMargemD)
	oRel:Say(nLin + nMargemV,0155,"TOTAL: " + Transform(nTot,"@E 999,999,999.99"),oFont10N)

	nLin += nSomaLin

	oRel:Box(nLin,0120,nLin + (nSomaLin * 8),nMargemD)
	oRel:Say(nLin + nMargemV,1080,"Observações",oFont10N)

//Rodapé
	nLin := 3280

	oRel:Line(nLin,0120,nLin,nMargemD)
	oRel:Say(nLin + nMargemV + 10,0110,"TOTVS - Protheus",oFont8)
	oRel:Say(nLin + nMargemV + 10,nMargemD - 140,"Página " + cValToChar(nPag),oFont8)

	oRel:EndPage() //Finaliza página

Return

/**************************/
Static Function ValidPerg()
/**************************/

	Local aHelpPor := {}

	U_xPutSX1(cPerg,"01",OemToAnsi("Contrato De       	?"),"","","mv_ch1","C",06,0,0,"G","","UF2","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,{},{})
	U_xPutSX1(cPerg,"02",OemToAnsi("Contrato Ate       ?"),"","","mv_ch2","C",06,0,0,"G","","UF2","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,{},{})
	U_xPutSX1(cPerg,"03",OemToAnsi("Emissao Pedido De  ?"),"","","mv_ch3","D",08,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,{},{})
	U_xPutSX1(cPerg,"04",OemToAnsi("Emissao PedidoAte  ?"),"","","mv_ch4","D",08,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,{},{})
	U_xPutSX1(cPerg,"05",OemToAnsi("Pedido De       	?"),"","","mv_ch5","C",06,0,0,"G","","SC5","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,{},{})
	U_xPutSX1(cPerg,"06",OemToAnsi("Pedido Ate         ?"),"","","mv_ch6","C",06,0,0,"G","","SC5","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,{},{})
	U_xPutSX1(cPerg,"07",OemToAnsi("Cliente De       	?"),"","","mv_ch7","C",06,0,0,"G","","SA1","","","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,{},{})
	U_xPutSX1(cPerg,"08",OemToAnsi("Loja De            ?"),"","","mv_ch8","C",02,0,0,"G","","","","","mv_par08","","","","","","","","","","","","","","","","",aHelpPor,{},{})
	U_xPutSX1(cPerg,"09",OemToAnsi("Cliente Ate       	?"),"","","mv_ch9","C",06,0,0,"G","","SA1","","","mv_par09","","","","","","","","","","","","","","","","",aHelpPor,{},{})
	U_xPutSX1(cPerg,"10",OemToAnsi("Loja Ate           ?"),"","","mv_ch10","C",02,0,0,"G","","","","","mv_par10","","","","","","","","","","","","","","","","",aHelpPor,{},{})

Return Pergunte(cPerg,.T.)