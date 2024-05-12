#include "protheus.ch"

#define DMPAPER_A4 9    // A4 210 x 297 mm

/*/{Protheus.doc} RCPGR023
Termo de Quita��o
@author TOTVS
@since 17/08/2016
@version P12
@param nulo
@return nulo
/*/

/***********************/
User Function RCPGR024()
/***********************/

Private oFont8			:= TFont():New('Arial',,8,,.F.,,,,,.F.,.F.)			//Fonte 8 Normal
Private oFont12			:= TFont():New('Courier new',,12,,.F.,,,,,.F.,.F.)	//Fonte 12 Normal
Private oFont12N		:= TFont():New('Courier new',,12,,.T.,,,,,.F.,.F.)	//Fonte 12 Negrito
Private oFont12I		:= TFont():New('Courier new',,12,,.F.,,,,,.F.,.T.)	//Fonte 12 Normal e It�lico
Private oFont14N		:= TFont():New('Courier new',,14,,.T.,,,,,.F.,.F.) 	//Fonte 14 Negrito
Private oFont14NS		:= TFont():New('Courier new',,14,,.T.,,,,,.T.,.F.) 	//Fonte 14 Negrito e Sublinhado
Private oFont14NI		:= TFont():New('Courier new',,14,,.T.,,,,,.F.,.T.) 	//Fonte 14 Negrito e It�lico

Private cStartPath
Private nLin 			:= 80
Private oRel

cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")  

oRel := TmsPrinter():New("")
oRel:SetPortrait()
oRel:SetPaperSize(9) //A4

CabecRel()
CorpoRel()
RodRel()  

oRel:Preview()

Return

/*************************/
Static Function CabecRel()
/*************************/

oRel:StartPage() //Inicia uma nova pagina

oRel:SayBitMap(nLin + 15,100,cStartPath + "LGMID01.png",400,214)

oRel:Say(nLin + 80,1050,"TERMO DE QUITA��O",oFont14NS)

nLin += 400 

Return

/*************************/
Static Function CorpoRel()
/*************************/

Local cTexto 	:= ""
Local cEnd		:= ""
Local cEnd2		:= ""
Local cNomeFant	:= AllTrim(U_RetInfSM0(cEmpAnt,cFilAnt,"M0_NOMECOM")) // Nome COmercial da Empresa Logada
Local cMunicip	:= AllTrim(U_RetInfSM0(cEmpAnt,cFilAnt,"M0_CIDENT")) // Municipio da Empresa Logada

	
oRel:Say(nLin,100,"REFERENTE AO CONTRATO DE CESS�O DE DIREITO DE USO DE JAZIGO N� " + U00->U00_CODIGO + ".",oFont12N)

nLin += 100

cTexto := "A " + AllTrim(SM0->M0_FILIAL) + ", pessoa jur�dica inscrita no CNPJ sob"
oRel:Say(nLin,350,Justif(cTexto + (Space(72 - Len(cTexto)))),oFont12)

nLin += 70

cEnd	:= AllTrim(SM0->M0_ENDCOB) + ", " + AllTrim(SM0->M0_BAIRCOB) + ", "
cEnd2	:= AllTrim(SM0->M0_COMPCOB) + ", " + AllTrim(SM0->M0_CIDCOB) + "-" + AllTrim(SM0->M0_ESTCOB) + ","
cTexto := "n�. " + Transform(AllTrim(SM0->M0_CGC),"@R 99.999.999/9999-99") + ", com sede na " + cEnd
oRel:Say(nLin,100,Justif(cTexto + (Space(82 - Len(cTexto)))),oFont12)

nLin += 70

cTexto := cEnd2 + " mantenedora da empresa " + cNomeFant 
oRel:Say(nLin,100,Justif(cTexto + (Space(82 - Len(cTexto)))),oFont12)

nLin += 70

cTexto := "outrora denominada CEDENTE, declara ter recebido o Valor Total"
oRel:Say(nLin,100,Justif(cTexto + (Space(82 - Len(cTexto)))),oFont12)

nLin += 70

cTexto := "do pre�o da aquisi��o do direito de uso de jazigo em ep�grafe,"
oRel:Say(nLin,100,Justif(cTexto + (Space(82 - Len(cTexto)))),oFont12)

nLin += 70

cTexto := "dando � " + AllTrim(U00->U00_NOMCLI) + ", portador de"
oRel:Say(nLin,100,Justif(cTexto + (Space(82 - Len(cTexto)))),oFont12)

nLin += 70

cTexto := "C�dula de Identidade de n�. " + AllTrim(U00->U00_RG) + ", inscrito (a) no CPF/MF sob"
oRel:Say(nLin,100,Justif(cTexto + (Space(82 - Len(cTexto)))),oFont12)

nLin += 70

cTexto := "o n�. " + AllTrim(U00->U00_CGC) + " a mais ampla, geral, irrevog�vel e irretrat�vel"
oRel:Say(nLin,100,Justif(cTexto + (Space(82 - Len(cTexto)))),oFont12)

nLin += 70

cTexto := "QUITA��O da import�ncia recebida, na forma do artigo 320 do C�digo Civil."
oRel:Say(nLin,100,Justif(cTexto + (Space(82 - Len(cTexto)))),oFont12)

nLin += 100

cTexto := "Dessa forma, permanecem v�lidos e inalterados os demais termos,"
oRel:Say(nLin,350,Justif(cTexto + (Space(72 - Len(cTexto)))),oFont12)

nLin += 70

cTexto := "condi��es e contribui��es pecuni�rias estabelecidas no Contrato em ep�grafe,"
oRel:Say(nLin,100,Justif(cTexto + (Space(82 - Len(cTexto)))),oFont12)

nLin += 70

cTexto := " mormente no que se refere ao Pagamento da Taxa de Conserva��o."
oRel:Say(nLin,100,cTexto,oFont12)

nLin += 100

cTexto := "Por ser verdade, firmamos e assinamos o presente, dando ci�ncia em uma"
oRel:Say(nLin,350,Justif(cTexto + (Space(72 - Len(cTexto)))),oFont12)

nLin += 70

cTexto := "via de igual teor o(a) CESSION�RIO(A) neste ato."
oRel:Say(nLin,100,cTexto,oFont12)

nLin += 150

oRel:Say(nLin,900,cMunicip + ", " + DToC(dDataBase) + ".",oFont12)

nLin += 400

oRel:Say(nLin,900,AllTrim(SM0->M0_FILIAL),oFont12)

nLin += 300

oRel:Say(nLin,900,AllTrim(U00->U00_NOMCLI),oFont12)

Return
      
/***********************/
Static Function RodRel()
/***********************/                                       

oRel:Line(3320,0120,3320,2240) 
oRel:Say(3350,0110,"TOTVS - Protheus",oFont8)

oRel:EndPage()

Return

/******************************/
Static Function Justif(cString)
/******************************/

Local cRetorno
Local nTam
Local cSpacs
Local nWinter 
Local nCont
Local cJustString

nTam   	:= Len(AllTrim(cString))
cSpacs	:= Len(cString) - nTam

If cSpacs <= 0
   Return cString
Endif

cString	:= AllTrim(cString)
nWinter	:= 0
nCont  	:= Len(cString)

Do While nCont > 0

   	If SubStr(cString,nCont,1) = Space(1)

      	nWinter++

      	Do While SubStr(cString,nCont,1) = Space(1) .And. nCont > 0
          	--nCont
      	EndDo
   	Else
      	nCont--
	Endif
EndDo

If nWinter = 0
	Return cString
Endif

Do While cSpacs > 0

   	cRetorno	:= ""
   	nCont   	:= Len(cString)

   	Do While nCont>0

      	If SubStr(cString,nCont,1) = Space(1)
         	If cSpacs > 0
            	cRetorno += SPACE(1)
            	--cSpacs
         	Endif
      	Endif

      	cRetorno += SubStr(cString,nCont,1) 
      	nCont--
   	EndDo

   	cString := ""

	For nCont = Len(cRetorno) To 1 Step -1
		cString += SubStr(cRetorno,nCont,1)
   	Next
EndDo

cJustString := ""

For nCont = Len(cRetorno) To 1 Step -1
	cJustString += SubStr(cRetorno,nCont,1)
Next

Return cJustString