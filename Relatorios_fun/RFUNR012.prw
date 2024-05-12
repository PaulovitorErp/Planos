#INCLUDE "rwmake.ch"
#Include "PROTHEUS.CH" 
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} RFUNR012
Impressão de Cartão
@author g.sampaio
@since 01/09/2019
@version 1.0
@param Nil
@return Nil
@type function
/*/

User Function RFUNR012( aImpDados )    

Local aArea     	:= GetArea()
Local aAreaUF2  	:= UF2->( GetArea() )
Local nI 			:= 0
Local oPrnCar   	:= Nil

Default aImpDados 	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do lay-out / impressao                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oPrnCar := TMSPrinter():New()
oPrnCar:Setup()
oPrnCar:SetLandsCape()//SetPortrait() //SetLansCape()
oPrnCar:SETPAPERSIZE(9) // <==== ajuste para papel A4

//gera a impressão com todos os dependentes selecionados
For nI := 1 To Len( aImpDados )	

	// realizo a impressao do cartao
	Processa({|| Imprimir(oPrnCar,aImpDados[nI][1],aImpDados[nI][2],aImpDados[nI][3],aImpDados[nI][4],aImpDados[nI][5],aImpDados[nI][6],aImpDados[nI][7],aImpDados[nI][8])}, "Processando...") 

Next nI

oPrnCar:End()        

// manda direto para impressora
oPrnCar:Print() 

RestArea(aAreaUF2)
RestArea(aArea)

Return(Nil)

/*/{Protheus.doc} RFUNR012
Impressão de Cartão
@author g.sampaio
@since 01/09/2019
@version 1.0
@param Nil
@return Nil
@type function
/*/

Static Function Imprimir( oPrnCar, cContrato, cTitular, cEndComp, cBairroCep, cMunEst, cDependente, cNumSorte, cValidade ) 

Local nLin			:=	0
Local oFont06   	:= TFont():New("Arial Black",06,06,,.F.,,,,.T.,.F.)
Local oFont06N  	:= TFont():New("Arial Black",06,06,,.T.,,,,.T.,.F.)
Local oFont08		:= TFont():New("Arial Black",08,08,,.F.,,,,.T.,.F.)
Local oFont08N  	:= TFont():New("Arial Black",08,08,,.T.,,,,.T.,.F.) 
Local oFont09		:= TFont():New("Arial Black",09,09,,.F.,,,,.T.,.F.)
Local oFont09N  	:= TFont():New("Arial Black",09,09,,.T.,,,,.T.,.F.)
Local oFont10		:= TFont():New("Arial Black",10,10,,.F.,,,,.T.,.F.) 
Local oFont10N  	:= TFont():New("Arial Black",10,10,,.T.,,,,.T.,.F.)
Local oFont11   	:= TFont():New("Arial Black",11,11,,.F.,,,,.T.,.F.)
Local oFont11N  	:= TFont():New("Arial Black",11,11,,.T.,,,,.T.,.F.)
Local oFont12   	:= TFont():New("Arial Black",12,12,,.F.,,,,.T.,.F.)
Local oFont12N  	:= TFont():New("Arial Black",12,12,,.T.,,,,.T.,.F.)
Local oFont13   	:= TFont():New("Arial",13,13,,.F.,,,,.T.,.F.)
Local oFont13N  	:= TFont():New("Arial Black",13,13,,.T.,,,,.T.,.F.)
Local oFont14		:= TFont():New("Arial Black",14,14,,.F.,,,,.T.,.F.)
Local oFont14N  	:= TFont():New("Arial Black",14,14,,.T.,,,,.T.,.F.)
Local oFont15		:= TFont():New("Arial Black",15,15,,.F.,,,,.T.,.F.)
Local oFont15N  	:= TFont():New("Arial Black",15,15,,.T.,,,,.T.,.F.)
Local oFont16		:= TFont():New("Arial Black",16,16,,.F.,,,,.T.,.F.)
Local oFont16N  	:= TFont():New("Arial Black",16,16,,.T.,,,,.T.,.F.)

Default cContrato	:= ""
Default cTitular	:= ""
Default cEndComp	:= ""
Default cBairroCep	:= ""
Default cMunEst		:= ""
Default cDependente	:= ""
Default cNumSorte	:= ""
Default cValidade	:= ""

oPrnCar:StartPage()

nLin := 10

// imprimo o codigo do contrato
oPrnCar:Say( nLin, 050, "INSCRIÇÃO: " + cContrato, oFont10N )
nLin += 040

// imprimo o titular do contrato
oPrnCar:Say( nLin, 050, "TITULAR: " + cTitular, oFont10N)
nLin += 040

// imprimo o endereco e o complemento
oPrnCar:Say( nLin, 050, cEndComp, oFont10N)
nLin += 040

// imprimo o bairro e o cep
oPrnCar:Say( nLin, 050, cBairroCep, oFont10N)
nLin += 040

// imprimo o municipio e o estado
oPrnCar:Say( nLin, 050, cMunEst, oFont10N)
nLin += 040

// verifico se a descricao do dependente esta preenchido
If !Empty( AllTrim( cDependente ) )
	
	// imprimo o dependente
	oPrnCar:Say( nLin, 050, "DEP.:" + cDependente, oFont10N)

EndIf

nLin += 290

// imprimo a chamado do numero da sorte
oPrnCar:Say( nLin, 050, "NUMERO DA SORTE", oFont10N)
nLin += 040

// imprimo o numero da sorte
oPrnCar:Say( nLin, 050, cNumSorte, oFont10N)

// imprimo a validade
oPrnCar:Say( nLin, 600, "VALIDADE: " + cValidade, oFont10N)

oPrnCar:EndPage() //Finaliza a página 

Return(Nil)