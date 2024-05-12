#INCLUDE 'Protheus.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} UPCPA001

Leitor de imagens do RPO protheus

@author thebr
@since 09/08/2018
@version 1.0
@return Nil

@type function
/*/
User function UIMGRPO()

	//dimensionamento de tela e componentes
	Local aSize 	:= MsAdvSize() // Retorna a área útil das janelas Protheus
	Local aInfo 	:= {aSize[1], aSize[2], aSize[3], aSize[4], 2, 2}
	Local aObjects 	:= {{100,100,.T.,.T.},{100,0,.T.,.T.}}
	Local aPObj 	:= MsObjSize( aInfo, aObjects, .T. )

	Private cCadastro	:= "Ver Imagem Protheus"
	Private oDlgPlan
	Private oList1, oImg
	Private nList := 1
	Private cBmp := ""

	//ajusto dimensões desconsiderando espaço da enchoicebar
	aPObj[1,1] -= 30
	aPObj[1,3] -= 5

	DEFINE MSDIALOG oDlgPlan TITLE cCadastro FROM aSize[7],aSize[1] TO aSize[6],aSize[5] PIXEL

	TButton():New(  aPObj[1,1], aPObj[1,2], "Fechar", oDlgPlan, {|| oDlgPlan:End() }, 40, 12,,,.F.,.T.,.F.,,.F.,,,.F. )

	oList1 := TListBox():New(aPObj[1,1]+30,aPObj[1,2],{|u|if(Pcount()>0,nList:=u,nList)},;
                         {},300,250,{|| oImg:SetBmp(oList1:GetSelText()), oImg:Refresh() },oDlgPlan,,,,.T.)

    @ aPObj[1,1]+30, 350 BITMAP oImg ResName cBmp SIZE 300, 300 OF oDlgPlan PIXEL NOBORDER

	oDlgPlan:bInit := {|| Processa({|| AddFundicao() },"Lendo imagens RPO...","Aguarde...") }
	oDlgPlan:lCentered := .T.
	oDlgPlan:Activate()

Return


//--------------------------------------------------------------------------------
// Adiciona os itens marcados a tela de fundiçao para planejamento
//--------------------------------------------------------------------------------
Static Function AddFundicao()

  Local aListCon := Nil

  // Resgata a lista dos resources no formato *.PER
  aListCon := GetResArray("*.PNG")

  oList1:SetArray(aListCon)
  oList1:Refresh()
  oList1:GoTop()

Return

