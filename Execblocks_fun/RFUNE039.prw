#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
{Protheus.doc} RFUNE039
Rotina Automatica de
Inclusao/Alteracao/Exclusão
de Contratos convalescente

@author Leandro Rodrigues
@since 24/09/2019 */

User Function RFUNE039(aCabec,aItens,nOpcao,cLogError)

	Local oModel
	Local oModelMaster
	Local oStructMaster
	Local aStructMaster


    //***************
	// Cabecalho Convalescente
	//***************
	Local oModelUJI
	Local oStructUJI
	Local aStructUJI
    Local nStart    := 0
    Local cRet		:= ""
	Local nI 		:= 0
	Local nJ		:= 0
	Local lRet  	:= .T.
	Local nItErro	:= 0
	Local aAux		:= {}
    Local aErro     := {}

    Default aCabec  := {}
    Default aItens  := {}

    // Instancia do modelo de dados (Model)
	oModel := FWLoadModel('RFUNA044') 

    // Temos que definir qual a operação deseja: 3-Inclusão / 4-Alteração / 5-Exclusão
	oModel:SetOperation(nOpcao)

    //valido se é inclusao do cabecalho
    If Len(aItens) == 0
        oModel:GetModel('UJIDETAIL'):SetOptional( .T. )
    endif
    
    // Antes de atribuirmos os valores dos campos temos que ativar o modelo
	oModel:Activate()

   	// objetos da enchoice
	oModelMaster 	:= oModel:GetModel('UJHMASTER') // Instanciamos apenas referentes aos dados
	oStructMaster 	:= oModelMaster:GetStruct()     // Obtemos a estrutura de dados da enchoice
	aStructMaster	:= oStructMaster:GetFields()    // Obtemos os campos

    // objetos do grid da tabela UJH - Itens Convalescente
	oModelUJI		:= oModel:GetModel('UJIDETAIL') // Intanciamos apenas a parte do modelo referente ao grid
	oStructUJI		:= oModelUJI:GetStruct()        // Obtemos a estrutura de dados do grid
	aStructUJI		:= oStructUJI:GetFields()       // Obtemos os campos

    if Len(aCabec) > 0
        
        // percorro os campos do cabeçalho
        For nI := 1 To Len(aCabec)
            // Verifica se os campos passados existem na estrutura do modelo
            If ( aScan(aStructMaster,{|x| AllTrim( x[3] )== AllTrim(aCabec[nI][1]) } ) ) > 0
                // ?feita a atribui?o do dado ao campo do Model
                If !( oModel:SetValue( 'UJHMASTER', aCabec[nI][1], (aCabec[nI][2] )) )
                    lRet := .F.
                    Exit
                EndIf
            EndIf
        Next nI

    endif

    if Len(aItens) > 0

        // percorro os campos dos itens
        For nI := 1 To Len(aItens)
            // Verifica se os campos passados existem na estrutura do modelo
            If ( aScan(aStructUJI,{|x| AllTrim( x[3] )== AllTrim(aItens[nI][1]) } ) ) > 0
                // ?feita a atribui?o do dado ao campo do Model
                If !( oModel:SetValue( 'UJIDETAIL', aItens[nI][1], (aItens[nI][2] )) )
                    lRet := .F.
                    Exit
                EndIf
            EndIf
        Next nI

    endif

	// Faz-se a valida?o dos dados
	If lRet .And. ( lRet := oModel:VldData() )
		// Se o dados foram validados faz-se a grava?o efetiva dos dados (commit)
		oModel:CommitData()
	EndIf

    //Valido se todo processo foi finalizado com sucesso
    If !lRet
        
        // Se os dados n? foram validados obtemos a descri?o do erro para gerar LOG ou mensagem de aviso
		aErro := oModel:GetErrorMessage()

		AutoGrLog( "Id do formulário de origem:" 	+ ' [' + AllToChar( aErro[1] ) + ']' )
		AutoGrLog( "Id do campo de origem: " 		+ ' [' + AllToChar( aErro[2] ) + ']' )
		AutoGrLog( "Id do formulário de erro: " 	+ ' [' + AllToChar( aErro[3] ) + ']' )
		AutoGrLog( "Id do campo de erro: " 			+ ' [' + AllToChar( aErro[4] ) + ']' )
		AutoGrLog( "Id do erro: " 					+ ' [' + AllToChar( aErro[5] ) + ']' )
		AutoGrLog( "Mensagem do erro: " 			+ ' [' + AllToChar( aErro[6] ) + ']' )
		AutoGrLog( "Mensagem da solução: " 			+ ' [' + AllToChar( aErro[7] ) + ']' )
		AutoGrLog( "Valor atribuído: " 				+ ' [' + AllToChar( aErro[8] ) + ']' )
		AutoGrLog( "Valor anterior: " 				+ ' [' + AllToChar( aErro[9] ) + ']' )

		If !IsBlind() .And. !IsInCallStack("U_RIMPM008") .And. !IsInCallStack("U_RIMPM009")

			MostraErro()
		Else
	
    		FwLogMsg("ERROR", , "REST", FunName(), "", "01", "Erro na inclusão do Contrato.", 0, (nStart - Seconds()), {}) 
			
		Endif

    else
        if Len(aItens) > 0
        
            //Grava controle de locacao do equipamento.
            lRet := U_GeraBensTeceiro( Nil, oModelUJI )         
        endif

    Endif

    // Desativamos o Model
	oModel:DeActivate()

    //elimino os objetos da memoria
	FreeObj(oModelUJI)
	FreeObj(oStructUJI)
    FreeObj(oModelMaster)
	FreeObj(oStructMaster)
    
Return lRet
