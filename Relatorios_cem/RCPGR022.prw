#include "protheus.ch"

#define DMPAPER_A4 9    // A4 210 x 297 mm

/*/{Protheus.doc} RCPGR022
Impressão de Transferência - Em vida
@author TOTVS
@since 17/08/2016
@version P12
@param nulo
@return nulo
/*/

/****************************************/
User Function RCPGR022(cContr,cCodTransf)
/****************************************/        

Private oFont8			:= TFont():New('Arial',,8,,.F.,,,,,.F.,.F.)			//Fonte 8 Normal
Private oFont12			:= TFont():New('Courier new',,12,,.F.,,,,,.F.,.F.)	//Fonte 12 Normal
Private oFont12I		:= TFont():New('Courier new',,12,,.F.,,,,,.F.,.T.)	//Fonte 12 Normal e Itálico
Private oFont14N		:= TFont():New('Courier new',,14,,.T.,,,,,.F.,.F.) 	//Fonte 14 Negrito
Private oFont14NI		:= TFont():New('Courier new',,14,,.T.,,,,,.F.,.T.) 	//Fonte 14 Negrito e Itálico

Private cStartPath
Private nLin 			:= 80
Private oRel

cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")  

oRel := TmsPrinter():New("")
oRel:SetPortrait()
oRel:SetPaperSize(9) //A4

CabecRel()
CorpoRel(cContr,cCodTransf)
RodRel()  

oRel:Preview()

Return

/*************************/
Static Function CabecRel()
/*************************/

oRel:StartPage() //Inicia uma nova pagina

oRel:SayBitMap(nLin + 15,100,cStartPath + "LGMID01.png",400,214)

oRel:Say(nLin + 80,1150,"AUTORIZAÇÃO DE TRANSFERÊNCIA",oFont14NI,,,,2)

nLin += 400 

Return

/******************************************/
Static Function CorpoRel(cContr,cCodTransf)
/******************************************/

Local cTexto	:= ""
Local cNomeAnt	:= ""
Local cEndAnt	:= ""
Local cRgAnt	:= ""
Local cCpfAnt	:= ""
Local cNascAnt	:= ""
Local cEndJz	:= ""
Local cNomeAtu	:= ""
Local cEndAtu	:= ""
Local cRgAtu	:= ""
Local cCpfAtu	:= ""
Local cNomeFant	:= AllTrim(U_RetInfSM0(cEmpAnt,cFilAnt,"M0_NOMECOM")) // Nome COmercial da Empresa Logada
Local cMunicip	:= AllTrim(U_RetInfSM0(cEmpAnt,cFilAnt,"M0_CIDENT")) // Municipio da Empresa Logada
Local cAssinat	:= SuperGetMV("MV_XASSTRA",.F.,"Mantenedor") 
Local aTexto	:= {}
Local aEndJz	:= {}
Local nX		:= 1

DbSelectArea("U19")
U19->(DbSetOrder(1)) //U19_FILIAL+U19_CODIGO

If U19->(DbSeek(xFilial("U19")+cCodTransf))

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA	
	
	//Cessionário antigo
	If SA1->(DbSeek(xFilial("SA1")+U19->U19_CLIANT+U19->U19_LOJANT))
		cNomeAnt	:= AllTrim(SA1->A1_NOME)
		cEndAnt		:= AllTrim(SA1->A1_END) + Space(1) + AllTrim(SA1->A1_BAIRRO) + Space(1) + AllTrim(SA1->A1_MUN) + "-" + AllTrim(SA1->A1_EST)
		cRgAnt		:= AllTrim(SA1->A1_PFISICA)
		cCpfAnt		:= AllTrim(Transform(SA1->A1_CGC,""))
		cNascAnt	:= DToC(SA1->A1_XDTNASC)
	Endif
	
	//Cessionário atual
	If SA1->(DbSeek(xFilial("SA1")+U19->U19_CLIATU+U19->U19_LOJATU))
		cNomeAtu	:= AllTrim(SA1->A1_NOME)
		cEndAtu		:= AllTrim(SA1->A1_END) + Space(1) + AllTrim(SA1->A1_BAIRRO) + Space(1) + AllTrim(SA1->A1_MUN) + "-" + AllTrim(SA1->A1_EST)
		cRgAtu		:= AllTrim(SA1->A1_PFISICA)
		cCpfAtu		:= AllTrim(Transform(SA1->A1_CGC,"@R 999.999.999-99"))
	Endif
	
	DbSelectArea("U04")
	U04->(DbSetOrder(1)) //U04_FILIAL+U04_CODIGO+U04_ITEM
	
	If U04->(DbSeek(xFilial("U04")+cContr))
	
		While U04->(!EOF()) .And. U04->U04_FILIAL == xFilial("U04") .And. U04->U04_CODIGO == cContr
			
			If Len(aEndJz) > 0
			
				If aScan(aEndJz,{|x| x[1] == U04->U04_QUADRA .And. x[2] == U04->U04_MODULO .And. x[3] == U04->U04_JAZIGO}) == 0
					AAdd(aEndJz,{U04->U04_QUADRA,U04->U04_MODULO,U04->U04_JAZIGO})
				Endif
			Else
				AAdd(aEndJz,{U04->U04_QUADRA,U04->U04_MODULO,U04->U04_JAZIGO})
			Endif
		
			U04->(DbSkip())
		EndDo
	Endif	
	
	cTexto := "Eu, " + cNomeAnt + " brasileiro(a), Residente a "	
	cTexto += cEndAnt + ", " 
	cTexto += "portador do RG: " + cRgAnt + ", e do CPF: " + cCpfAnt + ", nascido em " 
	cTexto += cNascAnt + " autorizo a empresa " + AllTrim(cNomeFant )+", a efetuar a " 
	cTexto += "transferência do Contrato de Direito de Cessão de Uso do Jazigo " 

	If Len(aEndJz) > 0
		cTexto += " " + IIF(Len(aEndJz) == 1,"3","6") + " Gavetas Conjugado nº " + cContr + ", localizado na " 
		cEndJz := "Quadra " + aEndJz[1][1] + " Módulo " + aEndJz[1][2] + " Jazigo " + aEndJz[1][3] + IIF(Len(aEndJz) > 1," e " + aEndJz[2][3],"") + ", "
		cTexto += cEndJz + Space(1) 
	Endif

	cTexto += "para o(a) Sr(a) " + cNomeAtu + " brasileiro(a), Residente a " + cEndAtu + ", "  
	cTexto += "portador do RG: " + cRgAtu + " e do CPF: " + cCpfAtu + " permanecendo o mesmo contrato original."   
	aTexto := U_UQuebraTexto(cTexto,70)
	
	For nX := 1 To Len(aTexto)
		oRel:Say(nLin,300,Justif(aTexto[nX] + (Space(70 - Len(aTexto[nX])))),oFont12I)
		nLin += 70
	Next nX

	nLin += 30

	oRel:Say(nLin,2120,"As demais cláusulas do contrato original ficarão mantidas.",oFont12,,,,1)

	nLin += 100

	oRel:Say(nLin,2120,cMunicip + "," + StrZero(Day(dDataBase),2) + " de " + MesExtenso(dDataBase) + " de " + cValToChar(Year(dDataBase)) + ".",oFont12I,,,,1)

	nLin += 200

	oRel:Say(nLin,300,"Firmo o presente TERMO DE TRANSFERÊNCIA em 3 (três) vias de igual teor.",oFont12I)

	nLin += 300

	oRel:Line(nLin,650,nLin,1700)

	nLin += 20

	oRel:Say(nLin,1150,cNomeAnt,oFont14NI,,,,2)
	nLin += 60
	oRel:Say(nLin,1150,"Atual Cessionário",oFont14N,,,,2)

	nLin += 300

	oRel:Line(nLin,650,nLin,1700)

	nLin += 20

	oRel:Say(nLin,1150,cNomeAtu,oFont14NI,,,,2)
	nLin += 60
	oRel:Say(nLin,1150,"Novo Cessionário",oFont14N,,,,2)

	nLin += 300

	oRel:SayBitMap(nLin - 120,850,cStartPath + "assinatura_mantenedor.png",600,160)
	oRel:Line(nLin,650,nLin,1700)

	nLin += 20

	oRel:Say(nLin,1150,cAssinat,oFont14NI,,,,2)

	nLin += 300

	oRel:Line(nLin,500,nLin,1000)
	oRel:Line(nLin,1300,nLin,1800)

	nLin += 20

	oRel:Say(nLin,600,"TESTEMUNHA",oFont14NI)
	oRel:Say(nLin,1400,"TESTEMUNHA",oFont14NI)
Endif

Return
      
/***********************/
Static Function RodRel()
/***********************/                                       

oRel:Line(3320,0120,3320,2240) 
oRel:Say(3350,1150,"TOTVS - Protheus",oFont8,,,,2)

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
