#include "protheus.ch"

#define DMPAPER_A4 9    // A4 210 x 297 mm

////////////////////////////////////////////
///// POSICOES DO ARRAY DE IMPRESSAO //////
////////////////////////////////////////////
#Define P_REALIZ	1
#Define P_HORA		2
#Define P_USER		3
#Define P_USRNOM	4
#Define P_INVOLU	5
#Define P_DTRETI	6
#Define P_DATASER	7
#Define P_NOMERES	8
#Define P_RG		9
#Define P_CPF		10
#Define P_ORGAO		11
#Define P_NOMEFALEC	12

/*/{Protheus.doc} RCPGR011
Impressão de Guia de Recebimento de Cinzas
@author TOTVS
@since 22/04/2016
@version P12
/*/

/********************************/
User Function RCPGR011(aRetiradas)
/********************************/        

	Local cStartPath	:= ""
	Local nLin			:= 80
	Local oRel			:= Nil

	cStartPath := GetPvProfString(GetEnvServer(),"StartPath","ERROR",GetAdv97())
	cStartPath += If(Right(cStartPath, 1) <> "\", "\", "")

	oRel := TmsPrinter():New("")
	oRel:SetPortrait()
	oRel:SetPaperSize(9) //A4

	// faco a impressao do corpo do relatorio
	ImpCorpo(@oRel, cStartPath, aRetiradas, nLin)

	oRel:Preview()

Return

/*/{Protheus.doc} ImpCorpo
funcao para realizar a impressao do corpo do relatorio
@type function
@version 
@author g.sampaio
@since 29/09/2020
@param aRetiradas, array, param_description
@param nLin, numeric, param_description
@return return_type, return_description
/*/
Static Function ImpCorpo(oRel, cStartPath, aRetiradas, nLin)

	Local cNomeEmp		:= AllTrim(U_RetInfSM0(cEmpAnt,cFilAnt,"M0_NOMECOM")) // Nome COmercial da Empresa Logada
	Local cMunicip		:= AllTrim(U_RetInfSM0(cEmpAnt,cFilAnt,"M0_CIDENT")) // Municipio da Empresa Logada
	Local nX			:= 0
	Local oFont10		:= TFont():New('Arial',,10,,.F.,,,,.F.,.F.) 				//Fonte 10 Normal
	Local oFont14N		:= TFont():New('Arial',,14,,.T.,,,,.F.,.F.) 				//Fonte 14 Negrito

	Default nLin		:= 80
	Default cStartPath	:= ""
	Default aRetiradas	:= {}

	For nX := 1 To Len(aRetiradas)

		oRel:StartPage() //Inicia uma nova pagina

		oRel:Box(nLin,120,nLin + 1480,2240)

		nLin+= 15
		oRel:SayBitMap(nLin,140,cStartPath + "LGMID01.png",400,214)

		nLin+= 80
		oRel:Say(nLin,820,"RECIBO DE ENTREGA DAS CINZAS",oFont14N)

		nLin += 280

		oRel:Say(nLin,140,"Data pré-estabelecida para cremação ("+IIF(aRetiradas[nX,P_REALIZ] == "C","somente com ordem judicial","sem ordem judicial")+") "+DToC(aRetiradas[nX,P_DATASER])+".",oFont10)
		oRel:Say(nLin,1650,"Horário: "+Transform(aRetiradas[nX,P_HORA],"@R 99:99")+"",oFont10)

		nLin+= 70
		oRel:Say(nLin,140,"Data de realização da cremação "+DToC(aRetiradas[nX,P_DATASER])+".",oFont10)
		oRel:Say(nLin,1650,"Horário: "+Transform(aRetiradas[nX,P_HORA],"@R 99:99")+"",oFont10)

		nLin+= 70
		oRel:Say(nLin,140,"Operador responsável: " + Alltrim(aRetiradas[nX,P_USER]) + " - " + Alltrim(aRetiradas[nX,P_USRNOM]) ,oFont10)

		nLin+= 70
		oRel:Say(nLin,140,"Número do invólucro da urna cinzária: " + Alltrim(aRetiradas[nX,P_INVOLU]),oFont10)		

		nLin+= 70
		oRel:Say(nLin,140,"Dias que as cinzas ficaram no columbário: " + cValToChar(aRetiradas[nX,P_DTRETI] - aRetiradas[nX,P_DATASER]),oFont10)

		nLin+= 70
		oRel:Say(nLin,140,"Nome do Falecido: " + aRetiradas[nX,P_NOMEFALEC],oFont10)

		nLin+= 70
		oRel:Say(nLin,140,"Data da entrega das cinzas para a família: "+DToC(aRetiradas[nX,P_DTRETI])+".",oFont10)

		nLin+= 70
		oRel:Say(nLin,140,"Pessoa que resgatou as cinzas: " + aRetiradas[nX,P_NOMERES],oFont10)

		nLin+= 70
		oRel:Say(nLin,140,"RG: " + Alltrim(aRetiradas[nX,P_RG]) + "" + if(!Empty(aRetiradas[nX,P_RG])," - " + Alltrim(aRetiradas[nX,P_ORGAO]),""),oFont10)

		nLin+= 70
		oRel:Say(nLin,140,"CPF: " + Transform(Alltrim(aRetiradas[nX,P_CPF]),"@R 999.999.999-99"),oFont10)

		nLin += 100
		oRel:Say(nLin,240,"Eu, declaro que recebi as cinzas da empresa " + cNomeEmp + ", em conformidade com os dados acima, assinando",oFont10)

		nLin+= 70
		oRel:Say(nLin,440,"conjuntamente com o funcionário responsável pela entrega das mesmas à mim.",oFont10)

		nLin+= 70
		oRel:Say(nLin,1000,cMunicip + "," + DToC(dDataBase),oFont10)

		nLin+= 70
		oRel:Say(nLin,840,"__________________________________",oFont10)

		nLin+= 70
		oRel:Say(nLin,940,"RESGATANTE DAS CINZAS",oFont10)

		ImpRod(@oRel)

		//retorno a linha para o inicio da pagina
		nLin := 80

	Next nX

Return(Nil)

/*/{Protheus.doc} ImpRod
Faco a impressao repositorio

@type function
@version 
@author g.sampaio
@since 29/09/2020
@return return_type, return_description
/*/
Static Function ImpRod(oRel)

	Local oFont8			:= TFont():New('Arial',,8,,.F.,,,,.F.,.F.) 					//Fonte 8 Normal

	oRel:Line(3320,0120,3320,2240)
	oRel:Say(3350,0110,"TOTVS - Protheus",oFont8)

	oRel:EndPage()

Return
