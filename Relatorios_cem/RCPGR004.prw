#INCLUDE "topconn.ch" 
#INCLUDE "protheus.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "rwmake.ch"
#DEFINE CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} RCPGR004
// Relatório de Comissão por Vendedor (Analítico) - Funerária
// Orientação do tipo Retrato

@author Pablo Cavalcante
@since 17/03/2016
@version undefined

@type function
/*/
User Function RCPGR004()

Local cQry 			:= "" //Query de busca 

////////////////////// FONTES PARA SEREM UTILIZADAS NO RELATORIO ///////////////////////////
Private oFont6		:= TFONT():New("ARIAL",07,06,.T.,.F.,5,.T.,5,.T.,.F.	) //Fonte 6 Normal
Private oFont6N 	:= TFONT():New("ARIAL",06,06,,.T.,,,,.T.,.F.			) //Fonte 6 Negrito
Private oFont7		:= TFONT():New("ARIAL",08,07,.T.,.F.,5,.T.,5,.T.,.F.	) //Fonte 7 Normal
Private oFont8		:= TFONT():New("ARIAL",09,08,.T.,.F.,5,.T.,5,.T.,.F.	) //Fonte 8 Normal
Private oFont8N 	:= TFONT():New("ARIAL",08,08,,.T.,,,,.T.,.F.			) //Fonte 8 Negrito
Private oFont10 	:= TFONT():New("ARIAL",09,10,.T.,.F.,5,.T.,5,.T.,.F.	) //Fonte 10 Normal
Private oFont10S	:= TFONT():New("ARIAL",09,10,.T.,.F.,5,.T.,5,.T.,.T.	) //Fonte 10 Sublinhando
Private oFont10N 	:= TFONT():New("ARIAL",09,10,,.T.,,,,.T.,.F.			) //Fonte 10 Negrito
Private oFont11		:= TFONT():New("ARIAL",11,11,,.F.,,,,.T.,.F.        ) //Fonte 11 Normal
Private oFont12		:= TFONT():New("ARIAL",12,12,,.F.,,,,.T.,.F.		) //Fonte 12 Normal
Private oFont12NS	:= TFONT():New("ARIAL",12,12,,.T.,,,,.T.,.T.		) //Fonte 12 Negrito e Sublinhado
Private oFont12N	:= TFONT():New("ARIAL",12,12,,.T.,,,,.T.,.F.		) //Fonte 13 Negrito
Private oFont13N	:= TFONT():New("ARIAL",13,13,,.T.,,,,.T.,.F.		) //Fonte 13 Negrito
Private oFont13		:= TFONT():New("ARIAL",13,13,,.F.,,,,.T.,.F.   		) //Fonte 13 Normal
Private oFont14		:= TFONT():New("ARIAL",14,14,,.F.,,,,.T.,.F.		) //Fonte 14 Normal
Private oFont14NS	:= TFONT():New("ARIAL",14,14,,.T.,,,,.T.,.T.		) //Fonte 14 Negrito e Sublinhado
Private oFont14N	:= TFONT():New("ARIAL",14,14,,.T.,,,,.T.,.F.		) //Fonte 14 Negrito
Private oFont16 	:= TFONT():New("ARIAL",16,16,,.F.,,,,.T.,.F.		) //Fonte 16 Normal
Private oFont16N	:= TFONT():New("ARIAL",16,16,,.T.,,,,.T.,.F.		) //Fonte 16 Negrito
Private oFont16NS	:= TFONT():New("ARIAL",16,16,,.T.,,,,.T.,.T.		) //Fonte 16 Negrito e Sublinhado
Private oFont20N	:= TFONT():New("ARIAL",20,20,,.T.,,,,.T.,.F.		) //Fonte 20 Negrito
Private oFont22N	:= TFONT():New("ARIAL",22,22,,.T.,,,,.T.,.F.		) //Fonte 22 Negrito

////////////////////////////////////////////////////////////////////////////////////////////
Private cStartPath
Private nLin 		:= 50
Private oPrint		:= TMSPRINTER():New("")
Private nPag		:= 1
Private nCont 		:= 1
Private nCont2 		:= 1
Private aDados 		:={}
Private cPerg 		:= "RCPGR004"

//perguntas
Private	cVendDe
Private	cVendAt
Private	dEmisDe
Private	dEmisAt
Private	nConsPg
Private	dPagaDe
Private	dPagaAt
Private	cContDe
Private	cContAt

//Nro interno do chassi
Private cChaInt

//totais
Private nTotPec   	:= 0
Private nTotPecRes	:= 0
Private nTotal    	:= 0
Private nDesconto 	:= 0
Private aNfi      	:= {}

Private oBrush		:= TBrush():New( , CLR_HGRAY )
lPerguntaOK 		:= .F.

///////////////////// DEFINE O TAMANHO DO PAPEL /////////////////////////
#define DMPAPER_A4 9 //Papel A4
oPrint:setPaperSize( DMPAPER_A4 )

/////////////////// DEFINE A ORIENTACAO DO PAPEL ////////////////////////
oPrint:SetPortrait()///Define a orientacao da impressao como retrato
//oPrint:SetLandscape() ///Define a orientacao da impressao como paisagem

CriaPergun() // cria as perguntas para gerar o relatorio

// posicione no cadastro de veiculo
If lPerguntaOK

	cQry := "select SE3.*, SA1.R_E_C_N_O_ AS SA1R_E_C_N_O_, SA3.R_E_C_N_O_ AS SA3R_E_C_N_O_"
	cQry += " from " + RetSqlName("SE3") + " SE3"
	cQry += " inner join " + RetSqlName("SA1") + " SA1 on (SA1.D_E_L_E_T_ <> '*' and SA1.A1_FILIAL = '" + xFilial("SA1") + "' and SA1.A1_COD = SE3.E3_CODCLI and SA1.A1_LOJA = SE3.E3_LOJA)"
	cQry += " inner join " + RetSqlName("SA3") + " SA3 on (SA3.D_E_L_E_T_ <> '*' and SA3.A3_FILIAL = '" + xFilial("SA3") + "' and SA3.A3_COD = SE3.E3_VEND)"
	cQry += " where SE3.D_E_L_E_T_ <> '*'"
	cQry += " and SE3.E3_VEND BETWEEN '" + cVendDe + "' AND '" + cVendAt + "'"
	cQry += " and SE3.E3_EMISSAO BETWEEN '" + DTOS(dEmisDe) + "' AND '" + DTOS(dEmisAt) + "'"
	/* cConsPg -> Considera Pagamento da Comissão
		1 - Ambas
		2 - Em Aberta
		3 - Pagas
	*/
	If nConsPg == 2 
		cQry += " and SE3.E3_DATA = ''"
	ElseIf nConsPg == 3
		cQry += " and SE3.E3_DATA <> ''"
		cQry += " and SE3.E3_DATA BETWEEN '" + DTOS(dPagaDe) + "' AND '" + DTOS(dPagaAt) + "'"
	EndIf
	cQry += " and SE3.E3_XCONTRA BETWEEN '" + cContDe + "' AND '" + cContAt + "'"
	cQry += " order by SE3.E3_FILIAL, SE3.E3_VEND, SE3.E3_XCONTRA"
	
	If Select("QAUX") > 0
		QAUX->(dbCloseArea())
	EndIf
	
	cQry := Changequery(cQry)
	TCQUERY cQry NEW ALIAS "QAUX"
	
	If QAUX->(!Eof())
		
		cVend 		:= ""
		nTotCom 	:= 0
		nTotGeral 	:= 0
		
		While QAUX->(!Eof())
		
			SA3->(DbGoTo(QAUX->SA3R_E_C_N_O_))
			SE3->(DbGoTo(QAUX->R_E_C_N_O_))
			SA1->(DbGoTo(QAUX->SA1R_E_C_N_O_))
			
			If cVend <> SA3->A3_COD
				
				If !Empty(cVend)
					
					//imprime total geral
					oPrint:box(nLin,1745,nLin+40,2020)
					oPrint:box(nLin,2020,nLin+40,2300)
					nLin+=6
					oPrint:Say(nLin, 1750, "Total: ", oFont6N)
					oPrint:Say(nLin, 2290, Transform(nTotCom, "@E 99,999,999,999.99"), oFont6,,,,1)
					nLin+=34
					
					fRodape()
					NovaPagina()
					
				EndIf
			
				cVend 	:= SA3->A3_COD
				nTotCom := 0
				
				// Impressao do Cabecalho
				fCabec1()
				
				fCabec2()
				CabList()
				
			EndIf
			
			If nLin >= 3050 // Salto de Página
				fRodape()
				NovaPagina()
				
				// Impressao do Cabecalho
				fCabec1()
				
				fCabec2()
				CabList()
				
			EndIf
		
			oPrint:box(nLin,0155,nLin+40,0295)
			oPrint:box(nLin,0295,nLin+40,1065)
			oPrint:box(nLin,1065,nLin+40,1235)
			oPrint:box(nLin,1235,nLin+40,1405)
			oPrint:box(nLin,1405,nLin+40,1575)
			oPrint:box(nLin,1575,nLin+40,1745)
			oPrint:box(nLin,1745,nLin+40,2020)
			oPrint:box(nLin,2020,nLin+40,2300)
			nLin+=6
			oPrint:Say(nLin,0160,SE3->E3_XCONTRA,oFont6)
			oPrint:Say(nLin,0300,SA1->A1_COD+"/"+SA1->A1_LOJA+" - "+SA1->A1_NOME,oFont6)
			oPrint:Say(nLin,1072,SE3->E3_XPARCOM,oFont6)
			oPrint:Say(nLin,1242,SE3->E3_XPARCON,oFont6)
			oPrint:Say(nLin,1412,DtoC(SE3->E3_VENCTO),oFont6)
			oPrint:Say(nLin,1582,DtoC(SE3->E3_DATA),oFont6)
			oPrint:Say(nLin,2010,Transform(SE3->E3_BASE, "@E 99,999,999,999.99"),oFont6,,,,1)
			oPrint:Say(nLin,2290,Transform(SE3->E3_COMIS, "@E 99,999,999,999.99"),oFont6,,,,1)
			nLin+=34
		
			nTotCom 	+= SE3->E3_COMIS
			nTotGeral 	+= SE3->E3_COMIS
			
			QAUX->(dbSkip())
		EndDo
		
		//imprime total geral
		oPrint:box(nLin,1745,nLin+40,2020)
		oPrint:box(nLin,2020,nLin+40,2300)
		nLin+=6
		oPrint:Say(nLin, 1750, "Total: ", oFont6N)
		oPrint:Say(nLin, 2290, Transform(nTotCom, "@E 99,999,999,999.99"), oFont6,,,,1)
		nLin+=34
		
		// Impressao do Rodape
		fRodape()
		
		oPrint:Preview()
		
	EndIf

	QAUX->(dbCloseArea())
	
Endif

Return

/*/{Protheus.doc} fCabec1
// Funcao que cria o cabecalho do relatorio.

@author Pablo Cavalcante
@since 17/03/2016
@version undefined

@type function
/*/
Static Function fCabec1()

Local aArea := GetArea()
Local aAreaSM0 := SM0->(GetArea())

	oPrint:StartPage() // Inicia uma nova pagina
	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")
	nLin       := 147

	SM0->(DbSetOrder(1))
	SM0->(DbSeek(cEmpAnt+cFilAnt)) //cEmpAnt -> empresa que esta logado e cFilAnt -> filial que esta logado
	
	_cCNPJCli := SM0->M0_CGC
	_cNMent   := SM0->M0_NOMECOM
	_cEndent  := SM0->M0_ENDENT
	_cBaiEnt  := SM0->M0_BAIRENT
	_cCidEnt  := SM0->M0_CIDENT
	_cEstEnt  := SM0->M0_ESTENT
	_cCepEnt  := SM0->M0_CEPENT       
	_cInscri  := SM0->M0_INSC
	
	oPrint:SayBitmap(nLin+30, 165, cStartPath + "lgmid0101.png", 368, 198) //Impressao da Logo
	
	cTodaStr := "Comissão por Vendedor (Analítico)"
	oPrint:Say(nLin+20, 1380, cTodaStr, oFont14n ,,,,2)
	nLin+=260
	
	oPrint:Line(nLin,150,nLin,2300)
	nLin+=20
	
	cTodaStr := AllTrim(DtoC(dDataBase))
	oPrint:Say(nLin, 0150, cTodaStr, oFont8N)
	cTodaStr := AllTrim(SM0->M0_NOMECOM)
	oPrint:Say(nLin, 1225, cTodaStr, oFont8n,,,,2)
	cTodaStr := AllTrim(TIME() + " - " + SubStr(cUsuario,7,15)) //hora + nome do usuario logado
	oPrint:Say(nLin, 2300, cTodaStr, oFont8N,,,,1)
	
	nLin+=50
	oPrint:Line(nLin,150,nLin,2300)

RestArea(aAreaSM0)
RestArea(aArea)
Return


/*/{Protheus.doc} fCabec2
// Informações do Vendedor e cabecalho das colunas.
@author Pablo Cavalcante
@since 17/03/2016
@version undefined

@type function
/*/
Static Function fCabec2()
	
	oPrint:box(nLin, 0155, nLin+080,2300)
 
	nLin+=5
	oPrint:Say(nLin,170,"Vendedor:", oFont8N)
	oPrint:Say(nLin,335,SA3->A3_COD+" - "+SA3->A3_NOME, oFont8)
	nLin+=41
	
	oPrint:Say(nLin,430,"Dt. Emissão De:", oFont6N,,,,1)
	oPrint:Say(nLin,440,DtoC(dEmisDe), oFont6)
	oPrint:Say(nLin,1460,"Dt. Emissão Até:", oFont6N,,,,1)
	oPrint:Say(nLin,1470,DtoC(dEmisAt), oFont6)
	nLin+=34

Return

/*/{Protheus.doc} cablist
// Imprime cabecalho dos itens.
@author Pablo Cavalcante
@since 17/03/2016
@version undefined

@type function
/*/
Static Function CabList()

	oPrint:box(nLin,0155,nLin+40,0295)
	oPrint:box(nLin,0295,nLin+40,1065)
	oPrint:box(nLin,1065,nLin+40,1235)
	oPrint:box(nLin,1235,nLin+40,1405)
	oPrint:box(nLin,1405,nLin+40,1575)
	oPrint:box(nLin,1575,nLin+40,1745)
	oPrint:box(nLin,1745,nLin+40,2020)
	oPrint:box(nLin,2020,nLin+40,2300)
	nLin+=6
	oPrint:Say(nLin,0160,"Contrato",oFont6N)
	oPrint:Say(nLin,0300,"Cliente",oFont6N)
	oPrint:Say(nLin,1070,"Par.Comis.",oFont6N)
	oPrint:Say(nLin,1240,"Par.Contr.",oFont6N)
	oPrint:Say(nLin,1410,"Vencto",oFont6N)
	oPrint:Say(nLin,1580,"Pagto",oFont6N)
	oPrint:Say(nLin,1750,"Vlr Base",oFont6N)
	oPrint:Say(nLin,2025,"Comissão",oFont6N)
	nLin+=34
	
Return

/*/{Protheus.doc} fRodape
// Funcao para criar o rodape do relatorio.
@author Pablo Cavalcante
@since 17/03/2016
@version undefined

@type function
/*/
Static Function fRodape()
nLin:=3300

	oPrint:Line(nLin,150,nLin,2300)
	nLin+=20
	//oPrint:SayBitmap(nLin-10, 150, cStartPath + "logo_totvs.bmp", 228, 050) //Impressao da Logo
	//oPrint:Say(nLin, 150, "Dt Emissão: "+DtoC(dDataBase)+" "+TIME(), oFont8N)
	oPrint:Say(nLin, 0150, "Microsiga Protheus", oFont8N)
	oPrint:Say(nLin, 2300, "Página: "+strzero(nPag,3), oFont8N,,,,1)
	nLin+=50
	oPrint:Line(nLin,150,nLin,2300)
	
oPrint:EndPage()

Return

/*/{Protheus.doc} NovaPagina
// Funcao que cria uma nova pagina montando o cabecalho
@author Pablo Cavalcante
@since 17/03/2016
@version undefined

@type function
/*/
Static Function NovaPagina()
	
	oPrint:endPage()
	nLin := 50
	nPag += 1
	
Return

/*/{Protheus.doc} CriaPergun
// Funcao para criar as perguntas do relatorio
@author Pablo Cavalcante
@since 17/03/2016
@version undefined

@type function
/*/
Static Function CriaPergun()

	AjustaSx1()
	If pergunte(cPerg,.T.) //Chama a tela de parametros
	
		cVendDe := mv_par01
		cVendAt := mv_par02
		dEmisDe := mv_par03
		dEmisAt := mv_par04
		nConsPg := mv_par05
		dPagaDe := mv_par06
		dPagaAt := mv_par07
		cContDe := mv_par08
		cContAt := mv_par09
	
		lPerguntaOK := .T.
	Else
		lPerguntaOK := .F.
	EndIf

Return

/*/{Protheus.doc} AjustaSX1
// Cria a tela de perguntas do relatorio
@author Pablo Cavalcante
@since 17/03/2016
@version undefined

@type function
/*/
Static Function AjustaSX1()

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

	U_xPutSX1( cPerg, "01","Do Vendedor ?                 ","","","mv_ch1","C",6,0,0,"G",'',"SA3","","",;
	"mv_par01","","","","","","","","","","","","","","","","",;
	{'Informe o código inicial dos vendededore','s a serem processados.                  '},aHelpEng,aHelpSpa) 
	
	U_xPutSX1( cPerg, "02","Ate o Vendedor ?              ","","","mv_ch2","C",6,0,0,"G",'',"SA3","","",;
	"mv_par02","","","","ZZZZZZ","","","","","","","","","","","","",;
	{'Informe o código final dos vendedores a ','serem processados.                      '},aHelpEng,aHelpSpa) 
	
	U_xPutSX1( cPerg, "03","Considera da Data ?           ","","","mv_ch3","D",8,0,0,"G","","","","",;
	"mv_par03","","","","","","","","","","","","","","","","",;
	{'Informe a data inicial de emissão das co','missões a serem processadas.            '},aHelpEng,aHelpSpa)
	
	U_xPutSX1( cPerg, "04","Até a Data ?                  ","","","mv_ch4","D",8,0,0,"G","(MV_PAR04 >= MV_PAR03)","","","",;
	"mv_par04","","","","","","","","","","","","","","","","",;
	{'Informe a data final de emissão das comi','ssões a serem processadas.              '},aHelpEng,aHelpSpa)    
	
	U_xPutSX1( cPerg, "05","Considera comissão ?          ","","","mv_ch5","C",1,0,0,"C","","","","",;
	"mv_par05","Ambas","Ambas","Ambas","1","Em Aberto","Em Aberto","Em Aberto","Pagas","Pagas","Pagas","","","","","","",;
	{'Indica quais as comissões devem ser ','consideradas no relatório: Em Aberto,',' Pagas ou Ambas.'},aHelpEng,aHelpSpa) 
	
	U_xPutSX1( cPerg, "06","Pagamento da Data ?           ","","","mv_ch6","D",8,0,0,"G","","","","",;
	"mv_par06","","","","","","","","","","","","","","","","",;
	{'Informe a data inicial de pagamento das ','comissões a serem processadas.          '},aHelpEng,aHelpSpa)
	
	U_xPutSX1( cPerg, "07","Até a Data ?                  ","","","mv_ch7","D",8,0,0,"G","(MV_PAR07 >= MV_PAR06)","","","",;
	"mv_par07","","","","","","","","","","","","","","","","",;
	{'Informe a data final de pagamento das co','missões a serem processadas.            '},aHelpEng,aHelpSpa)
	
	U_xPutSX1( cPerg, "08","Do Contrato ?                 ","","","mv_ch8","C",6,0,0,"G",'',"U00","","",;
	"mv_par08","","","","","","","","","","","","","","","","",;
	{'Informe o código inicial dos contratos a',' serem processados.                     '},aHelpEng,aHelpSpa) 
	
	U_xPutSX1( cPerg, "09","Ate o Contrato ?              ","","","mv_ch9","C",6,0,0,"G",'',"U00","","",;
	"mv_par09","","","","ZZZZZZ","","","","","","","","","","","","",;
	{'Informe o código final dos contratos a s','erem processados.                       '},aHelpEng,aHelpSpa) 

Return

