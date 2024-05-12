#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'          
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
{Protheus.doc} RCPGA028
Rotina Automatica de 
Inclusao/Alteracao/Exclus�o
de Controle de Carn�s

@author Raphael Martins
@since 22/06/2016
@version 1.0
@Param
*/
User Function RCPGA030(aCabec,aItens,nOpc)


Local oModel			:= NIL
Local oModelMaster  	:= NIL
Local oModelDetail 		:= NIL
Local oStructMaster 	:= NIL
Local oStructDetail		:= NIL
Local aStructMaster		:= {}
Local aStructDetail 	:= {}
Local cRet				:= ""
Local nI 				:= 0
Local nJ				:= 0
Local lRet  			:= .T.
Local nItErro			:= 0   
Local aAux				:= {}
Default aCabec			:= {} 
Default aItens			:= {} 
Default nOpc			:= 3 // inclus�o 


// Aqui ocorre o inst?ciamento do modelo de dados (Model)
oModel := FWLoadModel( 'RCPGA028' ) // MVC do Cadastro de Carn�

// Temos que definir qual a opera��o deseja: 3-Inclus�o / 4-Altera��o / 5-Exclus�o
oModel:SetOperation(nOpc)

// Antes de atribuirmos os valores dos campos temos que ativar o modelo
oModel:Activate()

// objetos da enchoice
oModelMaster 	:= oModel:GetModel('U32MASTER') // Instanciamos apenas referentes aos dados
oStructMaster 	:= oModelMaster:GetStruct() // Obtemos a estrutura de dados da enchoice
aStructMaster	:= oStructMaster:GetFields() // Obtemos os campos     

// objetos do grid
oModelDetail	:= oModel:GetModel('U33DETAIL') // Intanciamos apenas a parte do modelo referente ao grid
oStructDetail	:= oModelDetail:GetStruct() // Obtemos a estrutura de dados do grid
aStructDetail	:= oStructDetail:GetFields() // Obtemos os campos 

// percorro os campos do cabe�alho
For nI := 1 To Len(aCabec)
	// Verifica se os campos passados existem na estrutura do modelo
	If ( aScan(aStructMaster,{|x| AllTrim( x[3] )== AllTrim(aCabec[nI][1]) } ) ) > 0
		// ?feita a atribui?o do dado ao campo do Model
		If !( oModel:SetValue( 'U32MASTER', aCabec[nI][1], (aCabec[nI][2] )) )
			lRet := .F.
			Exit
		EndIf
	EndIf
Next nI

// se os campos do cabe�alho foram setados com sucesso
If lRet  

	nItErro  := 0
	For nI := 1 To Len(aItens)  

		// Inclu�mos uma linha nova
		// ATENCAO: O itens s�o criados em uma estrura de grid (FORMGRID), portanto j� � criada uma primeira linha
		//branco automaticamente, desta forma come�amos a inserir novas linhas a partir da 2� vez
		If nI > 1
			// Incluimos uma nova linha de item
			If  ( nItErro := oModelDetail:AddLine() ) <> nI
				// Se por algum motivo o metodo AddLine() n�o consegue incluir a linha,
				// ele retorna a quantidade de linhas j�
				// existem no grid. Se conseguir retorna a quantidade mais 1
				lRet    := .F.
				Exit
			EndIf
		EndIf

		For nJ := 1 To Len( aItens[nI] )
			// Verifica se os campos passados existem na estrutura de item
			If ( aScan( aStructDetail, { |x| AllTrim( x[3] ) ==  AllTrim( aItens[nI][nJ][1] ) } ) ) > 0
				If !( oModel:SetValue('U33DETAIL', aItens[nI][nJ][1], aItens[nI][nJ][2] ) )

					// Caso a atribui��o n�o possa ser feita, por algum motivo (valida��o, por exemplo)
					// o m�todo SetValue retorna .F.
					lRet    := .F.
					nItErro := nI
					Exit

				EndIf 
			EndIf  
		Next

		If !lRet
			Exit
		EndIf
	Next
	
	// Faz-se a valida?o dos dados
	If ( lRet := oModel:VldData() )
		// Se o dados foram validados faz-se a grava?o efetiva dos dados (commit)
		oModel:CommitData()
	EndIf
	
EndIf

If !lRet
	// Se os dados n? foram validados obtemos a descri?o do erro para gerar LOG ou mensagem de aviso
	aErro := oModel:GetErrorMessage()
		
	AutoGrLog( "Id do formul�rio de origem:" 	+ ' [' + AllToChar( aErro[1] ) + ']' )
	AutoGrLog( "Id do campo de origem: " 		+ ' [' + AllToChar( aErro[2] ) + ']' )
	AutoGrLog( "Id do formul�rio de erro: " 	+ ' [' + AllToChar( aErro[3] ) + ']' )
	AutoGrLog( "Id do campo de erro: " 			+ ' [' + AllToChar( aErro[4] ) + ']' )
	AutoGrLog( "Id do erro: " 					+ ' [' + AllToChar( aErro[5] ) + ']' )
	AutoGrLog( "Mensagem do erro: " 			+ ' [' + AllToChar( aErro[6] ) + ']' )
	AutoGrLog( "Mensagem da solu��o: " 			+ ' [' + AllToChar( aErro[7] ) + ']' )
	AutoGrLog( "Valor atribu�do: " 				+ ' [' + AllToChar( aErro[8] ) + ']' )
	AutoGrLog( "Valor anterior: " 				+ ' [' + AllToChar( aErro[9] ) + ']' )
	
	MostraErro()
EndIf

	

// Desativamos o Model
oModel:DeActivate()

Return(lRet)