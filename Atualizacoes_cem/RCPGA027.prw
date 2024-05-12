#include 'protheus.ch'
#include 'parmtype.ch'
#include 'tbiconn.ch'
#include 'topconn.ch'

/*/{Protheus.doc} RCPGA027
Reprocessa comissao de cobradores (Tabela SE3), para recebimentos efetuados no mes/ano informado.

@author pablocavalcante
@since 13/06/2016
@version undefined

@type function
/*/

User Function RCPGA027()

Local aArea		:= GetArea()
Local dBkpDtB	:= dDataBase
Local oProcess
Local lEnd 		:= .F.
Local cLog 		:= ""

Private cPerg 	:= "RCPGA027"

//variáveis das perguntas
Private	cVendDe
Private	cVendAt
Private	dRefenc

	AjustaSx1() // cria as perguntas do reprocessamento de comissão
	
	//Pergunte - Variável pública de pergunta ( cGroup [ lAsk ] [ cTitle ] [ lOnlyView ] ) --> lRet
	If !Pergunte(cPerg,.T.)
		Return
	EndIf
	
	cVendDe	:= mv_par01
	cVendAt := mv_par02
	dRefenc := mv_par03
	
	oProcess := MsNewProcess():New({|lEnd| UAJUSCOM(@oProcess, @lEnd, @cLog) },"Reprocessamento das Comissões - Contratos","Aguarde! Reprocessando as comissões...",.T.) 
	oProcess:Activate()
	
	If !Empty(cLog)
		
		cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cLog )
		Define Font oFont Name "Arial" Size 7, 16
		Define MsDialog oDlgDet Title "Log Gerado" From 3, 0 to 340, 417 Pixel

		@ 5, 5 Get oMemo Var cLog Memo Size 200, 145 Of oDlgDet Pixel
		oMemo:bRClicked := { || AllwaysTrue() }
		oMemo:oFont     := oFont

		Define SButton From 153, 175 Type  1 Action oDlgDet:End() Enable Of oDlgDet Pixel // Apaga
		Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
		MemoWrite( cFile, cLog ) ) ) Enable Of oDlgDet Pixel

		Activate MsDialog oDlgDet Center
	
	EndIf

	dDataBase := dBkpDtB
	
	RestArea(aArea)
	
Return

//
// Reprocessamento de comissões, conforme filtros informados.
//
Static Function UAJUSCOM(oProcess, lEnd, cLog)

Local aArea			:= GetArea()
Local cPulaLinha	:= chr(13)+chr(10)
Local cQry			:= ""
Local nCountSA3		:= 0

	cLog += ">> INICIO DO REPROCESSAMENTO DE COMISSÕES" + cPulaLinha
	cLog += cPulaLinha

	cLog += cPulaLinha
	cLog += "   >> SELEÇÃO DOS COBRADORES (VENDEDORES)..." + cPulaLinha
	
	cQry := "SELECT SA3.*" + cPulaLinha
	cQry += " FROM " + RetSqlName("SA3") + " SA3" + cPulaLinha
	cQry += " WHERE" + cPulaLinha
	cQry += " SA3.D_E_L_E_T_<> '*'" + cPulaLinha
	cQry += " AND A3_FILIAL = '" + xFilial("SA3") + "'" + cPulaLinha
	cQry += " AND A3_COD BETWEEN '" + cVendDe + "' AND '" + cVendAt + "'" + cPulaLinha
	cQry += " AND A3_MSBLQL <> '1'" + cPulaLinha
	cQry += " ORDER BY A3_FILIAL, A3_COD" + cPulaLinha
	
	cLog += cPulaLinha
	cLog += " >> QUERY: "
	cLog += cPulaLinha
	cLog += cQry
	cLog += cPulaLinha
	cLog += cPulaLinha
	
	If Select("QRYSA3") > 0
		QRYSA3->(DbCloseArea())
	EndIf
	
	cQry := ChangeQuery(cQry)
	TcQuery cQry New Alias "QRYSA3" // Cria uma nova area com o resultado do query
	
	QRYSA3->(dbEval({|| nCountSA3++}))
	QRYSA3->(dbGoTop())
	
	dDataBase := dRefenc
	
	oProcess:SetRegua1(nCountSA3)
	
	While QRYSA3->(!Eof())
	
		cLog += cPulaLinha
		cLog += "   >> REPROCESSANDO COMISSÃO DO COBRADOR (VENDEDOR) " + QRYSA3->A3_COD + "..." + cPulaLinha
		
		oProcess:IncRegua1("Comissões do Cobrador: " + QRYSA3->A3_COD)
		oProcess:IncRegua2("...")
		
		If lEnd	//houve cancelamento do processo
			Exit
		EndIf
		
		U_RCPGA017(QRYSA3->A3_COD, @cLog)
		
		QRYSA3->(dbSkip())
	EndDo

	If Select("QRYSA3") > 0
		QRYSA3->(DbCloseArea())
	EndIf
	
	cLog += cPulaLinha
	cLog += ">> FIM REPROCESSAMENTO DE COMISSÕES" + cPulaLinha

Return

/*/{Protheus.doc} AjustaSX1
// Cria a tela de perguntas do relatorio
@author Pablo Cavalcante
@since 03/06/2016
@version undefined

@type function
/*/
Static Function AjustaSX1()

Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

	U_xPutSX1( cPerg, "01","Do Vendedor ?                 ","","","mv_ch1","C",6,0,0,"G",'EMPTY(MV_PAR01) .OR. ExistCpo("SA3",MV_PAR01)',"SA3","","",;
	"mv_par01","","","","","","","","","","","","","","","","",;
	{'Informe o código inicial dos vendededore','s a serem processados.                  '},aHelpEng,aHelpSpa) 
	
	U_xPutSX1( cPerg, "02","Ate o Vendedor ?              ","","","mv_ch2","C",6,0,0,"G",'EMPTY(MV_PAR02) .OR. ExistCpo("SA3",MV_PAR02)',"SA3","","",;
	"mv_par02","","","","ZZZZZZ","","","","","","","","","","","","",;
	{'Informe o código final dos vendedores a ','serem processados.                      '},aHelpEng,aHelpSpa) 
	
	U_xPutSX1( cPerg, "03","Considera Data ?              ","","","mv_ch3","D",8,0,0,"G","","","","",;
	"mv_par03","","","","","","","","","","","","","","","","",;
	{'Informe a data de referência das comissõ','es a serem processadas.                 '},aHelpEng,aHelpSpa)
	
Return
